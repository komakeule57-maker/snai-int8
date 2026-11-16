<?php
// Dateiname: train_cluster.php
// Funktion: Orchestriert das verteilte Training (BPE-Worker), verwaltet Epochen und verschmilzt Tensoren (OOM Zero Stream).

/**
 * SYMBIO NANO-AI FRAMEWORK (Code-4372)
 * Modul: Distributed Cluster Training (Phase VII.1 - Heisenbug Patch)
 * -------------------------------------------------------------------------
 * MAXIME: E > H. Orchestriert BPE-Worker für parallelisiertes Training.
 * FIX: 'average_models' lädt nichts mehr in den RAM, sondern streamt und 
 * verschmilzt die Tensoren Chunk für Chunk direkt von der SSD (Zero OOM).
 * AUDIT-FIX: Darwin-Entropie-Patch. Zirkuläres Chunk-Reading anhand des 
 * Hostnames verhindert identische Klon-Tensoren beim FedAvg über P2P!
 * AUDIT-V9.4: Event-Driven Pipe Polling (stream_select), I/O Telemetry-Spam eliminiert, Batch-Pack.
 * AUDIT-PHASE-VII.1: Exitcode-Caching (verhindert Heisenbug-Crashes), 
 * Zombie-Prozess-Terminierung und Division-by-Zero Protection.
 */

// AUDIT-FIX (2026-08-11): wie im Steuer-Daemon - date.timezone-Ini steht auf
// UTC statt Europe/Berlin, betrifft hier v.a. die "[H:i:s] Worker..."-Zeilen.
date_default_timezone_set('Europe/Berlin');
// SPEICHERGRENZE DES CLUSTERS.
//
// Hier stand '1024M' mit dem Kommentar "Limit extrem reduziert, wir brauchen
// keinen RAM mehr". Das galt fuer dim 128/256. Bei dim 512 sprengt der MERGE
// diese Grenze: merge_v6_models() dequantisiert jeden Tensor in ein PHP-Array,
// und die Embedding-Matrix hat dort 8192*512 = 4.194.304 Elemente. unpack()
// legt dafuer rund 134 MB an - je Modell, zusaetzlich zum Mittelwertspeicher.
//
// Beobachtet am 2026-09-03 im Rauchtest des Produktivlaufs: beide Arbeiter
// waren fertig und hatten ihre Gewichte geschrieben, dann starb der Merge mit
// "Allowed memory size of 1073741824 bytes exhausted (tried to allocate
// 134217736 bytes)". Der Fehler faellt also GANZ AM ENDE eines Segments an -
// im Produktivlauf waeren das 27 Stunden Rechenzeit gewesen, bevor er
// auftritt.
//
// Ueber SNAI_CLUSTER_MEM einstellbar, damit kleinere Geometrien nicht
// unnoetig viel reservieren muessen.
$_mem = getenv('SNAI_CLUSTER_MEM');
ini_set('memory_limit', ($_mem !== false && $_mem !== '') ? $_mem : '3072M');

chdir(__DIR__);
require_once 'tensor_io.php';
require_once 'tensor_ffi_adapter.php';
require_once __DIR__ . '/tensor_utils_ffi.php';
require_once 'snai_tokenizer.php';
require_once __DIR__ . '/head_config.php';
require_once __DIR__ . '/growth_config.php';
require_once __DIR__ . '/revival_config.php';
require_once __DIR__ . '/train_defaults.php';

/**
 * AUDIT-FIX: fread() liefert auf Netzwerk-Mounts (GVFS/SMB/NFS) regelmaessig
 * weniger Bytes als angefordert, ohne dass ein Fehler auftritt. Header wurden
 * dadurch als "inkompatibel" verworfen, obwohl sie identisch sind.
 */
function cluster_robust_fread($fp, int $length): string {
    $data = '';
    while (strlen($data) < $length && !feof($fp)) {
        $chunk = fread($fp, $length - strlen($data));
        if ($chunk === false || $chunk === '') break;
        $data .= $chunk;
    }
    return $data;
}

/**
 * Update 2026-08-09 ("Engine-/Framework-Verbesserungen",
 * Punkt 3): waehrend des Watchdog-Tests entdeckt - proc_terminate() allein
 * beendet NUR den direkten Kindprozess von proc_open(). Da die Worker-
 * Kommandos hier IMMER "2>&1" enthalten (Shell-Redirection), fuehrt PHP sie
 * ueber "sh -c ..." aus - proc_terminate() traf bisher also nur die
 * Shell-Huelle, nicht den eigentlichen "php train_worker.php"-Prozess
 * darunter, der als Waise WEITERLIEF (empirisch verifiziert: "sleep 999"
 * ueberlebte einen proc_terminate() auf den Wrapper-Prozess klaglos).
 * Betraf nicht nur den neuen Watchdog unten, sondern auch die BESTEHENDE
 * Zombie-Kill-Logik beim Worker-Absturz (siehe beide Aufrufstellen unten) -
 * seit jeher. Fix: erst die direkten Kinder des Wrapper-Prozesses per
 * "pkill -P" beenden, dann den Wrapper selbst.
 */
function cluster_kill_worker_tree($process): void {
    if (!is_resource($process)) return;
    $status = proc_get_status($process);
    $wrapper_pid = $status['pid'] ?? null;
    if ($wrapper_pid) {
        @shell_exec('pkill -TERM -P ' . (int)$wrapper_pid . ' 2>/dev/null');
    }
    proc_terminate($process);
    proc_close($process);
}

/**
 * AUDIT-FIX: Die Head-Zahl liegt in einer .heads-Sidecar-Datei neben dem Modell
 * (siehe head_config.php). Beim Merge und beim finalen rename ging sie bisher
 * verloren -> resolve_num_heads() fiel danach auf den Legacy-Wert 1 zurueck und
 * deutete die trainierten Attention-Gewichte um.
 *
 * Bewusst NICHT ueber resolve_num_heads(): die Funktion schreibt bei fehlendem
 * Sidecar selbst den Legacy-Wert fest. Hier wird nur weitergereicht, was da ist.
 */
function propagate_head_sidecar(string $src_model, string $dst_model): void {
    $src = head_sidecar_path($src_model);
    if (!file_exists($src)) return;
    @copy($src, head_sidecar_path($dst_model));
}

function move_head_sidecar(string $src_model, string $dst_model): void {
    $src = head_sidecar_path($src_model);
    if (!file_exists($src)) return;
    @rename($src, head_sidecar_path($dst_model));
}

/**
 * LoRA (2026-08-29): die Adapterdatei ist ein Beiwagen wie die Kopfzahl - nur
 * ein ungleich folgenschwererer. Bei eingefrorener Basis steckt das GESAMTE
 * Trainingsergebnis darin; bliebe sie beim finalen rename() liegen, waere das
 * Endmodell die unveraenderte Basis und der Lauf umsonst gewesen. Der erste
 * End-to-End-Lauf hat genau das gezeigt: Checkpoint und Adapter da, Endmodell
 * ohne Adapter.
 *
 * Der Fingerabdruck muss mitwandern, denn das Ziel ist byteweise dieselbe
 * Datei wie die Quelle - deshalb reicht Verschieben, kein Neustempeln.
 */
function move_lora_sidecar(string $src_model, string $dst_model): void {
    $src = snai_lora_path($src_model);
    if (!file_exists($src)) return;
    if (!@rename($src, snai_lora_path($dst_model))) {
        echo "🚨 [Fatal] LoRA-Adapter $src liess sich nicht nach "
           . snai_lora_path($dst_model) . " verschieben - das Ergebnis waere verloren.\n";
        exit(1);
    }
}

function copy_lora_sidecar(string $src_model, string $dst_model): void {
    $src = snai_lora_path($src_model);
    if (!file_exists($src)) return;
    if (!@copy($src, snai_lora_path($dst_model))) {
        echo "🚨 [Fatal] LoRA-Adapter $src liess sich nicht nach "
           . snai_lora_path($dst_model) . " kopieren.\n";
        exit(1);
    }
    // Quelle und Ziel sind byteweise gleich - der Fingerabdruck stimmt also
    // weiterhin. Er wird trotzdem neu gesetzt, weil der Best-Checkpoint eine
    // EIGENE Datei ist und sein Adapter auf genau sie zeigen soll.
    snai_lora_restamp_base(snai_lora_path($dst_model), $dst_model);
}

if ($argc < 6) {
    echo "Nutzung: php train_cluster.php <input.txt> <output.snai> <num_workers> <max_epochs> <base_model> [datatype] [custom_lr] [target_loss] [start_epoch] [weight_decay] [dropout_rate] [lr_schedule_epochs] [label_smoothing]\n";
    exit(1);
}

$input_file   = $argv[1];
$output_model = $argv[2];
$num_workers  = (int)$argv[3];
$max_epochs   = (int)$argv[4];
$base_model   = $argv[5];
$target_dtype = isset($argv[6]) ? (int)$argv[6] : 1;
$custom_lr    = isset($argv[7]) ? $argv[7] : "0.0005";
$target_loss  = isset($argv[8]) ? (float)$argv[8] : 0.0; // NEU: Target Loss Notbremse
// AUDIT-FIX (2026-08-07): Fortsetzung nach Absturz/Abbruch ab einem Checkpoint
// startete das LR-Schedule (Warmup+Decay, siehe Schleife unten) bisher immer
// bei Epoche 1 neu, unabhaengig davon, welchen Trainingsstand der uebergebene
// <base_model>-Checkpoint tatsaechlich hat - injiziert einen ungewollten LR-
// Warm-Restart statt nahtlos fortzusetzen. start_epoch (Default 1, bestehende
// Aufrufe unveraendert) erlaubt, die Schleife an der richtigen Stelle wieder
// aufzusetzen; max_epochs bleibt der Bezugspunkt fuer die Decay-Kurve.
$start_epoch  = isset($argv[9]) ? max(1, (int)$argv[9]) : 1;
// Optionale Regularisierung, durchgereicht an jeden Worker (siehe
// train_worker.php). Default 0.0 = No-Op, bestehende Aufrufe ohne diese
// Argumente (z.B. die automatische Pipeline der Destille) bleiben
// unveraendert.
$weight_decay = isset($argv[10]) ? (float)$argv[10] : 0.0;
$dropout_rate = isset($argv[11]) ? (float)$argv[11] : 0.0;
// Update 2026-08-14: entkoppelt die
// Warmup+Cosine-Decay-Kurve vom Schleifen-Ende DIESES Prozesses. Noetig, weil
// die Destille ab Matriarchin/Empress jetzt einzelne Epochen als
// getrennte train_cluster.php-Prozesse verkettet (jede mit frischem statt
// wiederverwendetem Nektar, siehe execute_calibration()), aber die Decay-
// Kurve trotzdem ueber den GESAMTEN verketteten Lauf glatt verlaufen soll,
// nicht bei jedem Einzelaufruf neu ab Epoche 1 anfangen. Default = $max_epochs,
// also exakt das bisherige Verhalten fuer jeden Aufrufer, der dieses Argument
// nicht mitgibt (alle bestehenden Aufrufstellen).
$lr_schedule_epochs = isset($argv[12]) ? max(1, (int)$argv[12]) : $max_epochs;
// Update 2026-08-15 ("Naechste Schritte" Punkt 7): als
// letzter positioneller Arg angehaengt statt zwischen dropout_rate und
// lr_schedule_epochs eingefuegt - sonst verschiebt sich lr_schedule_epochs'
// bereits etablierte Position 12 und es entstehen stille Off-by-one-Bugs bei
// bestehenden Aufrufstellen.
$label_smoothing = isset($argv[13]) ? (float)$argv[13] : 0.0;

if ($num_workers <= 0 || $max_epochs <= 0) {
    echo "🚨 [Fatal] num_workers und max_epochs müssen > 0 sein.\n";
    exit(1);
}

// Update 2026-08-09: Gesamtlaufzeit fuer die Abschluss-
// Logs (cluster_drones.log + train_<session>.jsonl-Summary unten) - bisher
// stand dort nur EIN Zeitpunkt (Fertigstellung), keine Dauer. Bewusst vor
// dem Net2Net-Merge-Block erfasst, damit auch dessen Laufzeit in die
// Gesamtzeit einfliesst, nicht nur die reine Epochenschleife.
$run_start_time = microtime(true);

$session_id = pathinfo($output_model, PATHINFO_FILENAME);

if (!file_exists($input_file)) {
    echo "[Fatal] Input-Datei $input_file fehlt.\n";
    exit(1);
}

$file_size = filesize($input_file);
// AUDIT-FIX: Division by Zero verhindern, falls die Nektar-Datei komplett leergefiltert wurde
if ($file_size <= 0) {
    echo "🚨 [Fatal] Input-Datei $input_file ist leer! (Vielleicht durch Aegis-Filter komplett gelöscht?).\n";
    exit(1);
}

$checkpoint_dir = './factory/checkpoints/';
if (!is_dir($checkpoint_dir)) @mkdir($checkpoint_dir, 0777, true);

// Update 2026-08-08 ("Best-Checkpoint-Retention"): haelt
// zusaetzlich zum aktuellsten Checkpoint den mit dem bisher besten Held-out-
// Loss auf. Bewusst hier oben geladen (nicht erst in der Epochenschleife) -
// bei einem fortgesetzten Lauf (start_epoch > 1) muss der bisherige beste
// Wert aus einer FRUEHEREN Prozess-Instanz bekannt sein, sonst wuerde ein
// Wiedereinstieg einen tatsaechlich besseren alten Checkpoint stillschweigend
// mit einem schlechteren ueberschreiben.
$best_state_path = $checkpoint_dir . "best_{$session_id}.json";
$best_heldout_loss = INF;
if (file_exists($best_state_path)) {
    $best_state_raw = @json_decode(file_get_contents($best_state_path), true);
    if (is_array($best_state_raw) && isset($best_state_raw['heldout_loss'])) {
        $best_heldout_loss = (float)$best_state_raw['heldout_loss'];
        echo "  > [Best-Checkpoint] Bisheriger bester Held-out-Loss (fortgesetzter Lauf): " .
             round($best_heldout_loss, 6) . " (Epoche " . ($best_state_raw['epoch'] ?? '?') . ")\n";
    }
}

echo "=== [CLUSTER MASTER | SESSION: $session_id] INITIALISIERUNG ===\n";

// FULL-INT8-PORT (2026-08-24): Schalter fuer den vollstaendigen Ganzzahl-Stack.
// Default leer = bisheriges Verhalten.
$int8_full_mode = strtolower(trim((string)getenv('SNAI_INT8_FULL')));
if ($int8_full_mode !== '' && $int8_full_mode !== '0') {
    if ($target_dtype !== SNAI_CLI_DTYPE_INT8) {
        echo "⚠️  [FULL-INT8] SNAI_INT8_FULL=$int8_full_mode gesetzt, aber dtype=$target_dtype ist nicht INT8 - ignoriert.\n";
        $int8_full_mode = '';
    } else {
        echo "[FULL-INT8] Modus '$int8_full_mode' aktiv - Worker rechnen mit dem vollstaendigen Ganzzahl-Stack.\n";
    }
} else {
    $int8_full_mode = '';
}

// --- SMART FORGE (Die Anti-Lobotomie-Schutzschicht) ---
if ($base_model === 'none') {
    if (file_exists($output_model)) {
        echo "[Forge] Ziel-Modell existiert bereits. Nutze es als Basis (Fine-Tuning)...\n";
        $base_model = $output_model;
    } else {
        $tokenizer = new SnaiTokenizer('symbio_vocab.json');
        $dynamic_vocab_size = $tokenizer->getVocabSize();
        
        echo "[Forge] Kein Basismodell gefunden. Erschaffe Multi-Layer Genesis-Matrix (Vocab: $dynamic_vocab_size)...\n";
        $base_model = $checkpoint_dir . "genesis_{$session_id}.snai";
        $init_dim = 128;
        // 2026-10-18: Format nach Ziel-dtype. int8 bekommt die V6-Genesis (spart dem Worker das Float-Modell beim
        // ersten Segment, Doku 6ao), FP32 die V5-Genesis - eine V6-Basis lehnt der Worker bei dtype=1 ab. Vom
        // 2026-10-15 bis 2026-10-18 war V6 die Vorgabe von init_base.php und jeder FP32-Lauf ab Genesis brach hier ab.
        $init_cmd = sprintf("%sphp init_base.php %s %d %d 512 2 2>&1",
            $target_dtype === SNAI_CLI_DTYPE_INT8 ? 'SNAI_GENESIS_V6=1 ' : '',
            escapeshellarg($base_model), $dynamic_vocab_size, $init_dim);
        // exec statt shell_exec, damit der Exitcode ankommt: eine abgebrochene Genesis hinterliess frueher eine
        // Teildatei, und file_exists() allein hielt sie fuer gelungen.
        $init_lines = [];
        $init_rc = 0;
        exec($init_cmd, $init_lines, $init_rc);
        echo implode("\n", $init_lines), "\n";
        if ($init_rc !== 0 || !file_exists($base_model)) {
            echo "🚨 [Fatal] Genesis-Modell konnte nicht erstellt werden (init_base.php rc=$init_rc)!\n";
            exit(1);
        }

        // Ab hier ist gesichert: dieser Lauf hat seine Basis selbst gegossen,
        // es ist also eine echte Genesis. Nur hier darf der Tying-Default
        // greifen (Begruendung in train_defaults.php bei
        // snai_ist_genesis_lauf). Die Arbeiter erben die Variable.
        putenv('SNAI_GENESIS_RUN=1');

        // Head-Sidecar SOFORT bei Geburt festschreiben (siehe head_config.php).
        // Fuer ein frisches, untrainiertes Modell gibt es nichts zu migrieren -
        // write_num_heads() direkt statt migrate_heads(), die Warnschranke ist
        // nur fuer bereits trainierte Checkpoints gedacht.
        require_once __DIR__ . '/head_config.php';
        $genesis_heads = suggest_num_heads($init_dim);
        write_num_heads($base_model, $genesis_heads);
        echo "[Forge] Head-Staffelung: $genesis_heads Heads bei dim=$init_dim (headSize=" .
             intdiv($init_dim, $genesis_heads) . ") festgeschrieben.\n";
    }
} elseif (!file_exists($base_model)) {
    echo "🚨 [Fatal] Angegebenes Basismodell $base_model fehlt.\n";
    exit(1);
}
// -----------------------------------------------------------

// 1. DATA PREP: Chunking mit Darwin-Entropie (Zirkulärer Puffer)
$min_chunk_size = 2048; 
if ($file_size < ($min_chunk_size * $num_workers)) {
    $num_workers = max(1, floor($file_size / $min_chunk_size));
}

$chunk_size = ceil($file_size / $num_workers);

// VETO-FIX: Der Darwin-Entropie-Patch!
// Wir erzeugen einen deterministischen Offset basierend auf dem PC-Namen.
// Desktop und Laptop fangen dadurch an völlig unterschiedlichen Stellen an zu lesen!
$host_hash = crc32(gethostname() . $session_id);
$entropy_offset = $host_hash % $file_size;

// A/B-FIX (2026-08-29): der Offset haengt an $session_id, also am DATEINAMEN
// des Ausgabemodells. Fuer den normalen Schwarmbetrieb ist das genau richtig
// (verschiedene Rechner/Laeufe sehen verschiedene Ausschnitte), fuer einen
// kontrollierten Vergleich ist es ein Stoerfaktor: jeder Arm haette eine
// andere Datenreihenfolge, und ein Teil des gemessenen Unterschieds waere
// diese Reihenfolge statt die Methode.
// SNAI_START_OFFSET pinnt ihn. Ohne die Variable bleibt alles wie bisher.
$offset_env = trim((string)getenv('SNAI_START_OFFSET'));
if ($offset_env !== '' && is_numeric($offset_env)) {
    $entropy_offset = ((int)$offset_env) % max(1, $file_size);
    echo "  > [A/B] Start-Offset per SNAI_START_OFFSET auf $entropy_offset gepinnt "
       . "(sonst waere er aus Hostname+Sessionname abgeleitet).\n";
}

// AUDIT-FIX: Der rohe Byte-Offset konnte mitten in einem Wort oder sogar
// mitten in einem UTF-8-Mehrbyte-Zeichen (Umlaute!) landen - Trainingschunks
// starteten dadurch teils mit kaputten/abgeschnittenen ersten Zeichen. Wir
// schieben den Offset bis zum naechsten Whitespace vor, damit jeder Chunk an
// einer sauberen Wortgrenze beginnt (Ringpuffer-Suche, falls das Fenster ans
// Dateiende laeuft - analog zum eigentlichen Chunk-Lesen weiter unten).
$scan_window = min($file_size, 4096);
$boundary_fp = fopen($input_file, 'r');
fseek($boundary_fp, $entropy_offset);
$probe = fread($boundary_fp, $scan_window);
if (strlen($probe) < $scan_window) {
    rewind($boundary_fp);
    $probe .= fread($boundary_fp, $scan_window - strlen($probe));
}
fclose($boundary_fp);
$ws_pos = strcspn($probe, " \n\t\r");
if ($ws_pos < strlen($probe)) {
    $entropy_offset = ($entropy_offset + $ws_pos + 1) % $file_size;
}

echo "[I/O] Splitting $file_size Bytes in $num_workers Chunks\n";
echo "  > [Darwin-Patch] Host-Entropie aktiviert. Start-Offset: $entropy_offset Bytes.\n";

$fp = fopen($input_file, 'r');
fseek($fp, $entropy_offset); // Wir springen an unseren individuellen Startpunkt!

$chunk_files = [];
for ($i = 0; $i < $num_workers; $i++) {
    $chunk_data = "";
    $bytes_to_read = $chunk_size;

    while ($bytes_to_read > 0) {
        $read = fread($fp, $bytes_to_read);
        if ($read === false || strlen($read) === 0) {
            // Wenn wir am Ende der Datei sind, springen wir einfach wieder an den Anfang! (Ringpuffer)
            rewind($fp);
            $read = fread($fp, $bytes_to_read);
            if ($read === false || strlen($read) === 0) break; // Notfall-Abbruch
        }
        $chunk_data .= $read;
        $bytes_to_read -= strlen($read);
    }
    
    $chunk_name = $checkpoint_dir . "chunk_{$session_id}_{$i}.txt"; 
    file_put_contents($chunk_name, $chunk_data);
    $chunk_files[] = $chunk_name;
}
fclose($fp);

/**
 * LoRA (2026-08-29): Adapterdateien der Arbeiter mitverschmelzen.
 *
 * DAS HIER DARF NICHT STILL AUSFALLEN. Bei eingefrorener Basis sind ALLE
 * Worker-Modelle in ihren Gewichten identisch - das gesamte Ergebnis einer
 * Epoche steckt ausschliesslich in den `.lora`-Dateien. Wuerde dieser Schritt
 * fehlen, mergte der Cluster vier identische Basen zu derselben Basis und der
 * Lauf saehe nach einem Training aus, in dem nichts passiert. Deshalb: alle
 * Adapter da -> mergen; keiner da -> kein LoRA-Lauf, in Ordnung; EINIGE da ->
 * harter Abbruch, denn das ist ein Zustand, den niemand gewollt haben kann.
 *
 * Zum Vorbehalt gegen das Mitteln von Niedrigrang-Faktoren siehe
 * merge_lora_files() in tensor_io.php.
 */
function merge_worker_loras(array $worker_models, string $output_path): void {
    $loras = [];
    foreach ($worker_models as $m) {
        $p = snai_lora_path($m);
        if (file_exists($p)) $loras[] = $p;
    }
    if (empty($loras)) return;
    if (count($loras) !== count($worker_models)) {
        echo "🚨 [Fatal] " . count($loras) . " von " . count($worker_models)
           . " Arbeitern haben eine Adapterdatei. Bei eingefrorener Basis steckt das\n"
           . "   gesamte Trainingsergebnis in den Adaptern - ein Teilmerge waere ein\n"
           . "   stiller Datenverlust.\n";
        exit(1);
    }
    $out = snai_lora_path($output_path);
    if (!merge_lora_files($loras, $out)) {
        echo "🚨 [Fatal] merge_lora_files() fehlgeschlagen.\n";
        exit(1);
    }
    // Der verschmolzene Adapter gehoert zur verschmolzenen Basis. Der
    // Fingerabdruck aus dem Kopf der ersten Quelldatei zeigt noch auf das
    // Modell EINES Arbeiters - ohne dieses Neustempeln wuerde die naechste
    // Epoche ihren eigenen Adapter als "fremde Basis" ablehnen.
    if (!snai_lora_restamp_base($out, $output_path)) {
        echo "🚨 [Fatal] Basis-Fingerabdruck des verschmolzenen Adapters nicht schreibbar.\n";
        exit(1);
    }
    printf("[Merge] %d LoRA-Adapter verschmolzen -> %s (%s Bytes, Fingerabdruck auf die neue Basis gesetzt).\n",
           count($loras), basename($out), number_format(filesize($out)));
}

// 2. FEDERATED AVERAGING (STREAM-MODUS - OOM ZERO)
function average_models_stream(array $worker_models, string $output_path) {
    if (empty($worker_models)) {
        echo "🚨 [Fatal] Keine Worker-Outputs zum Mergen vorhanden!\n";
        exit(1);
    }

    // PHASE 5 DES INT8-UMBAUS:
    // SNAI_V6 (INT8) mischt INT8-Bloecke mit
    // Skalen-Praefixen und Float32-Resten (rms_*) - der blinde 8192-Float-
    // Byte-Chunk-Merge unten funktioniert nur bei SNAI_V5s durchgehend
    // homogenem Float32-Layout. Erkennung ueber den Magic-String der ersten
    // Worker-Datei, Dispatch an den tensor-bewussten Merge (tensor_io.php),
    // der bestehende V5-Pfad darunter bleibt komplett unveraendert.
    $first_magic = null;
    $fp_probe = @fopen($worker_models[0], 'rb');
    if ($fp_probe) {
        $first_magic = rtrim(fread($fp_probe, 8), "\0");
        fclose($fp_probe);
    }
    // FULLINT8 Stufe 10: SNAI_V8 mit einem Worker = Kopie (merge_v6_models kopiert bei einer Datei); mehrere Worker
    // mittelt nur der float32-Weg fuer V6/V7 - fuer V8 gibt es keinen, also laut abbrechen statt in den V5-Pfad zu fallen.
    if ((string)$first_magic === SNAI_MAGIC_V8 && count($worker_models) !== 1) {
        // FULLINT8 Stufe 11 (2026-11-16): ganzzahliger Merge, nur mit Schalter (fragt libcortex.so); sonst wie bisher.
        if (!snai_gz_merge_an()) {
            echo "🚨 [Fatal] SNAI_V8-Checkpoints mehrerer Worker lassen sich (noch) nicht mitteln - Abbruch.\n";
            exit(1);
        }
        if (!merge_v8_models($worker_models, $output_path)) {
            echo "🚨 [Fatal] merge_v8_models() (Stufe 11) fehlgeschlagen.\n";
            exit(1);
        }
        propagate_head_sidecar($worker_models[0], $output_path);
        propagate_growth_sidecar($worker_models[0], $output_path);
        echo "[Merge] SNAI_V8 ganzzahlig gemittelt (Stufe 11): int8-Gewichte, 8-Bit-Momente, float32-Tensoren.\n";
        merge_worker_loras($worker_models, $output_path);
        return;
    }
    if (snai_is_int8_magic((string)$first_magic) || (string)$first_magic === SNAI_MAGIC_V8) {
        if (!merge_v6_models($worker_models, $output_path)) {
            echo "🚨 [Fatal] merge_v6_models() (INT8) fehlgeschlagen.\n";
            exit(1);
        }
        propagate_head_sidecar($worker_models[0], $output_path);
        propagate_growth_sidecar($worker_models[0], $output_path);
        echo "[Merge] INT8-Tensoren (Pro-Zeile-Skala, neu abgeleitet) + Adam-Gedächtnis tensor-bewusst verschmolzen.\n";
        merge_worker_loras($worker_models, $output_path);
        return;
    }

    $num_models = count($worker_models);

    $expected_size = filesize($worker_models[0]);
    foreach ($worker_models as $file) {
        if (!file_exists($file) || filesize($file) !== $expected_size) {
            echo "🚨 [Fatal] Inkonsistente oder fehlende Worker-Dateien vor dem Merge: $file\n";
            exit(1);
        }
    }

    if ($num_models === 1) {
        // AUDIT-FIX: Rueckgabewert wurde nie geprueft. Genau dieser Pfad laeuft
        // bei jeder Destillation (execute_calibration nutzt $workers = 1).
        // Schlug die Kopie fehl - auf Netzwerk-Mounts durchaus moeglich - lief
        // alles weiter, bis am Ende stumm kein Modell da war.
        if (!copy($worker_models[0], $output_path)) {
            echo "🚨 [Fatal] Konnte Worker-Modell nicht nach $output_path kopieren!\n";
            exit(1);
        }
        propagate_head_sidecar($worker_models[0], $output_path);
        propagate_growth_sidecar($worker_models[0], $output_path);
        return;
    }

    $handles = [];
    $headers = [];
    foreach ($worker_models as $file) {
        $fp = fopen($file, 'rb');
        if (!$fp) {
            echo "🚨 [Fatal] Kann Worker-Modell nicht lesen: $file\n";
            exit(1);
        }
        $handles[] = $fp;
        $headers[] = cluster_robust_fread($fp, 28); // Magic + 5 Params
    }

    if (count(array_unique($headers)) > 1) {
        echo "🚨 [Fatal] Worker-Modelle haben inkonsistente Header (Vocab/Dimension Mismatch)!\n";
        exit(1);
    }

    $out_fp = fopen($output_path, 'wb');
    if (!$out_fp) {
        foreach ($handles as $h) fclose($h);
        echo "🚨 [Fatal] Kann Output-Modell nicht schreiben: $output_path\n";
        exit(1);
    }

    fwrite($out_fp, $headers[0]);

    // AUDIT: vorher PHP-seitiges unpack()/Schleifen-Mitteln pro einzelnem
    // Float (siehe tensor_utils_ffi.php) - jetzt ein nativer Aufruf pro Chunk
    // wie schon in merge_tributes() der Destille.
    $chunk_floats = 8192;
    $chunk_bytes = $chunk_floats * 4;

    while (!feof($handles[0])) {
        $chunks = [];
        for ($i = 0; $i < $num_models; $i++) {
            $chunks[] = fread($handles[$i], $chunk_bytes);
        }

        if (strlen($chunks[0]) === 0) break;

        // AUDIT-FIX: nur volle Float-Elemente an die native Mittelung geben -
        // ungleich lange Chunks wuerden FFI::memcpy() sonst ueber das Ende
        // des kuerzeren PHP-Strings hinauslesen lassen (siehe merge_tributes()).
        $min_len = min(array_map('strlen', $chunks));
        $usable_len = $min_len - ($min_len % 4);
        if ($usable_len === 0) break;
        if ($usable_len !== strlen($chunks[0])) {
            $chunks = array_map(fn($c) => substr($c, 0, $usable_len), $chunks);
        }

        fwrite($out_fp, SnaiTensorUtils::merge($chunks));
    }

    foreach ($handles as $h) fclose($h);
    fclose($out_fp);

    // AUDIT-FIX: Head-Zahl an den Checkpoint weiterreichen. Alle Worker teilen
    // dieselbe Head-Zahl (sie starten vom selben Basismodell), daher genuegt der
    // erste als Quelle.
    propagate_head_sidecar($worker_models[0], $output_path);
    propagate_growth_sidecar($worker_models[0], $output_path);

    echo "[Merge] Multi-Layer Tensoren & Adam-Gedächtnis erfolgreich via Stream verschmolzen.\n";
}

// 3. DIE EPOCHEN-SCHLEIFE

// Einmal je Lauf ansagen, welche Standardeinstellung gegriffen hat. Wichtig
// ist der Fall "Basis uebergeben, Absicht nicht angesagt, kein LoRA": das war
// bis 2026-09-02 der stille Normalfall und ist nach der Messung vom selben Tag
// die um 0,32 nats schlechtere Wahl. $argv[5] ist der uebergebene Pfad, 'none'
// heisst Vortraining von Grund auf.
snai_train_mode_hinweis($argv[5] !== 'none');

$checkpoint_state = "";
$current_epoch_loss = 999.0;
$base_lr = (float)str_replace(',', '.', $custom_lr); 

// RAM-Cache für die Telemetrie
$telemetry_cache = [];
$telemetry_dir = './factory/telemetry';
if (!is_dir($telemetry_dir)) @mkdir($telemetry_dir, 0777, true);
$telemetry_file = $telemetry_dir . '/race_data.json';

// Update 2026-08-09: expliziter Zaehler statt den
// Endwert von $epoch nach der Schleife zurueckzurechnen - bei einem
// vorzeitigen `break` (Notbremse/Killswitch weiter unten) behaelt $epoch den
// Wert der zuletzt abgeschlossenen Epoche, bei normalem Schleifenende steht
// es dagegen schon einen Schritt WEITER (max_epochs+1) - zwei verschiedene
// Faelle, die sich aus dem Endwert allein nicht sauber unterscheiden lassen.
$epochs_completed = 0;

/**
 * Laufzeit als H:i:s formatieren, OHNE Tagesueberlauf.
 *
 * WARUM NICHT gmdate("H:i:s", $sec): gmdate formatiert einen ZEITPUNKT, keine
 * DAUER. "H" ist die Stunde eines Tages und laeuft bei 24 h auf 0 zurueck. Die
 * Bilanzzeile von prod512_s1 meldete deshalb "04:07:17" fuer einen Lauf, der
 * in Wahrheit 28:07:17 gedauert hat - wer die Laufzeit aus dem Log liest, lag
 * um einen ganzen Tag daneben. Aufgefallen erst, weil ms/Schritt mal Schritte
 * nicht zur angezeigten Dauer passte; die Dauer allein sah plausibel aus.
 *
 * Segmente dieses Laufs dauern ~28 h, ein Mehr-Epochen-Lauf entsprechend mehr -
 * der Ueberlauf ist hier also der Normalfall, nicht der Sonderfall.
 *
 * Die Stundenstelle waechst unbegrenzt und wird weiterhin zweistellig
 * aufgefuellt, damit Zeilen unter 24 h zeichengleich zu den alten Logs bleiben.
 */
function cluster_format_duration(float $seconds): string {
    if ($seconds < 0) $seconds = 0.0;
    $t = (int)$seconds;
    return sprintf('%02d:%02d:%02d', intdiv($t, 3600), intdiv($t % 3600, 60), $t % 60);
}

/**
 * Segment-Schrittplan ausgeben, sobald alle Worker ihre Fensterzahl gemeldet
 * haben (Update 2026-09-04). Beantwortet die Frage "wie viele Schritte laufen
 * in diesem Segment" VOR dem ersten Schritt statt hinterher aus dem Log.
 *
 * Bewusst OHNE Zeitprognose: ms/Schritt ist erst nach ein paar Schritten
 * bekannt und haengt an Geometrie und Maschinenlast. Eine Hochrechnung hier
 * waere genau die Sorte Schaetzung, die dieser Plan ersetzen soll - die echte
 * Dauer steht nach der Epoche in der Bilanz darunter.
 */
function cluster_print_step_plan(array $plan_steps, array $plan_tokens, int $epoch, int $max_epochs): void {
    ksort($plan_steps);
    $sum_steps  = array_sum($plan_steps);
    $sum_tokens = array_sum($plan_tokens);
    echo "\n[Plan] Schrittplan Epoche $epoch/$max_epochs (exakt, aus der Fensterliste der Worker):\n";
    foreach ($plan_steps as $wid => $steps) {
        echo "  > Worker $wid: " . number_format($plan_tokens[$wid] ?? 0, 0, ',', '.') . " Token"
           . " -> " . number_format($steps, 0, ',', '.') . " Schritte\n";
    }
    echo "  > Epoche gesamt: " . number_format($sum_steps, 0, ',', '.') . " Schritte"
       . " ueber " . number_format($sum_tokens, 0, ',', '.') . " Token"
       . " (" . count($plan_steps) . " Worker parallel, laengster Worker "
       . number_format(max($plan_steps), 0, ',', '.') . " Schritte)\n";
    echo "PLAN_EPOCH_STEPS=$sum_steps PLAN_EPOCH_TOKENS=$sum_tokens\n\n";
}

// Update 2026-08-09 ("Engine-/Framework-Verbesserungen",
// Punkt 3): einmalig VOR der Epochen-Schleife definiert (nicht darin - ein
// erneutes define() derselben Konstante in Epoche 2 waere ein Fatal Error).
define('WORKER_STALL_TIMEOUT_SEC', 600);

for ($epoch = $start_epoch; $epoch <= $max_epochs; $epoch++) {
    // Update 2026-08-09 (Nachruest-Paket #8 "Backend-/Hardware-
    // Telemetrie"): Wall-Clock-Dauer der Epoche fuer train_<session>.jsonl unten.
    $epoch_start_time = microtime(true);

    $warmup_epochs = max(1, floor($lr_schedule_epochs * 0.15));
    $active_lr = 0.0;

    if ($epoch <= $warmup_epochs) {
        $active_lr = $base_lr * ($epoch / $warmup_epochs);
    } else {
        $progress = ($epoch - $warmup_epochs) / ($lr_schedule_epochs - $warmup_epochs);
        $active_lr = $base_lr * (0.5 * (1 + cos(pi() * $progress)));
    }
    
    $active_lr = max($active_lr, $base_lr * 0.1);
    $lr_display = number_format($active_lr, 6, '.', '');

    echo "\n>>> EPOCHE $epoch/$lr_schedule_epochs | LR: $lr_display | Starte $num_workers Worker...\n";
    
    $processes = [];
    $pipes = [];
    $worker_outputs = [];
    $epoch_losses = [];
    // Update 2026-08-09 (Nachruest-Paket #8/#9): pro Worker
    // der zuletzt gemeldete Wert - gleiches "letzter Stand gewinnt"-Muster wie
    // $epoch_losses oben, da bei stream_select mehrere Zeilen pro Poll ankommen
    // koennen.
    $epoch_backends = [];
    $epoch_grad_norms = [];
    // Update 2026-08-09: Loss der letzten
    // RECENT_LOSS_WINDOW Schritte pro Worker (siehe RECENT_LOSS= in
    // train_worker.php) - anders als $epoch_losses (Epochendurchschnitt) ein
    // Snapshot des tatsaechlichen Endstands der Epoche, direkt vergleichbar
    // mit dem Held-out-Loss (der auch immer den fertigen Epochenstand misst).
    $epoch_recent_losses = [];

    // Update 2026-09-04 (Segment-Schrittplan): PLAN_STEPS=/PLAN_TOKENS= meldet
    // jeder Worker EINMAL, sobald sein Chunk tokenisiert ist - also vor seinem
    // ersten Trainingsschritt. STEPS_DONE= kommt am Epochenende dazu.
    // Bewusst aus dem Worker gemeldet statt im Cluster nachgerechnet: der
    // Worker tokenisiert den Chunk ohnehin, eine zweite Tokenisierung hier
    // haette bei den Produktivsegmenten ~30 s je Segment gekostet UND waere
    // eine zweite Fassung derselben Rechnung gewesen.
    $epoch_plan_steps = [];
    $epoch_plan_tokens = [];
    $epoch_steps_done = [];
    $epoch_plan_printed = false;
    // stream_get_contents() liefert, was gerade in der Pipe steht - nicht
    // zwingend ganze Zeilen. Eine Zeile, die zwischen PLAN_STEPS= und
    // PLAN_TOKENS= auf zwei Polls faellt, wuerde von einem Regex auf dem
    // Einzel-Poll nie gefunden. Deshalb je Worker ein kleiner Mitschnitt
    // (Ende genuegt), gegen den gematcht wird.
    $worker_tail = [];

    // AUDIT-FIX: Heisenbug Exitcode-Cache initialisieren
    $worker_exitcodes = [];

    // Update 2026-08-09 ("Engine-/Framework-Verbesserungen",
    // Punkt 3): die stream_select-Schleife unten hatte bisher kein
    // Gesamt-Zeitlimit - ein HAENGENDER (nicht abgestuerzter) Worker
    // (Treiber-Deadlock, Endlosschleife) blockierte die Epoche fuer immer,
    // ohne Fehler, ohne Log. Zeitstempel des letzten Lebenszeichens pro
    // Worker, initial auf den Spawn-Zeitpunkt gesetzt (damit auch ein Worker
    // erfasst wird, der von Anfang an NIE etwas ausgibt).
    $worker_last_output_time = [];

    for ($i = 0; $i < $num_workers; $i++) {
        $worker_out = $checkpoint_dir . "worker_{$session_id}_{$i}_e{$epoch}.snai"; 
        $worker_outputs[] = $worker_out;
        // AUDIT-FIX (2026-08-07): war hart gegen Epoche 1 geprueft - bei einer
        // Fortsetzung ueber start_epoch (z.B. 11) ist $checkpoint_state in dieser
        // frischen Prozess-Instanz noch leer, das echte Basismodell steckt in
        // $base_model. Vergleich muss gegen den tatsaechlichen Startpunkt laufen.
        $start_model = ($epoch === $start_epoch) ? $base_model : $checkpoint_state;
        
        // FULL-INT8-PORT: den Schalter explizit an den Worker weiterreichen.
        // Vererbung ueber die Prozessumgebung wuerde zwar auch funktionieren,
        // aber explizit ist es im Log sichtbar und ueberlebt einen Wechsel der
        // Startmethode.
        $int8_full_prefix = ($int8_full_mode !== '' ? 'SNAI_INT8_FULL=' . escapeshellarg($int8_full_mode) . ' ' : '');
        // Code-Review 2026-11-05 (L1, Altbefund C3): %F schreibt 6 Nachkommastellen.
        // Eine LR unter 5e-7 kam beim Worker als 0 an und wurde dort still zu
        // DEFAULT_LR; 1,25e-5 kam als 1,3e-5 an. Das Format bleibt (sonst aendert
        // sich die LR bisheriger Laeufe mit Cosinus-Werten in der 7. Stelle), aber
        // eine Abweichung ueber 1 % bricht jetzt laut ab statt still zu verfaelschen.
        foreach (['active_lr' => $active_lr, 'base_lr' => $base_lr] as $_lrname => $_lrwert) {
            $_lrbeim_worker = (float)sprintf('%F', $_lrwert);
            if ($_lrwert > 0 && abs($_lrbeim_worker - $_lrwert) > 0.01 * $_lrwert) {
                fwrite(STDERR, sprintf("🚨 [Cluster] %s=%.10g kommt per %%F als %s beim Worker an (Abweichung %.1f %%). Abbruch.\n",
                    $_lrname, $_lrwert, sprintf('%F', $_lrwert), 100.0 * abs($_lrbeim_worker - $_lrwert) / $_lrwert));
                exit(1);
            }
        }
        $cmd = sprintf(
            "%sphp train_worker.php %s %s 1 %s %d %F %d %F %F %F %F 2>&1",
            $int8_full_prefix,
            escapeshellarg($chunk_files[$i]),
            escapeshellarg($worker_out),
            escapeshellarg($start_model),
            $target_dtype,
            $active_lr,
            $epoch,
            $base_lr,
            $weight_decay,
            $dropout_rate,
            $label_smoothing
        );

        // TEMP-DEBUG: Zeigt das komplette, tatsaechlich ausgefuehrte Kommando.
        // Nach der Diagnose wieder entfernen oder auskommentieren.
        echo "[DEBUG] Worker-Kommando: $cmd\n";

        $process = proc_open($cmd, [0 => ["pipe", "r"], 1 => ["pipe", "w"], 2 => ["pipe", "w"]], $pipes_arr);
        
        if (is_resource($process)) {
            stream_set_blocking($pipes_arr[1], false);
            stream_set_blocking($pipes_arr[2], false);
            $processes[$i] = $process;
            $pipes[$i] = $pipes_arr;
            $worker_last_output_time[$i] = microtime(true);
        }
    }

    $active_workers = $num_workers;
    
    // Event-Driven Orchestration via stream_select
    while ($active_workers > 0) {
        $read_pipes = [];
        foreach ($processes as $i => $process) {
            if (is_resource($pipes[$i][1])) $read_pipes[] = $pipes[$i][1];
        }

        $write_pipes = null; $except_pipes = null;
        $num_changed = 0;
        
        if (!empty($read_pipes)) {
            $num_changed = stream_select($read_pipes, $write_pipes, $except_pipes, 0, 200000);
        }

        if ($num_changed > 0) {
            $telemetry_updated = false;
            foreach ($read_pipes as $ready_pipe) {
                $worker_id = -1;
                foreach ($pipes as $idx => $p) {
                    if ($p[1] === $ready_pipe) { $worker_id = $idx; break; }
                }
                
                if ($worker_id === -1) continue;

                $output = stream_get_contents($ready_pipe);
                if ($output) {
                    echo "[" . date('H:i:s') . "] " . trim($output) . "\n";
                    // Update 2026-08-09 ("Engine-/Framework-Verbesserungen",
                    // Punkt 3): Lebenszeichen fuer den Stall-Watchdog unten.
                    $worker_last_output_time[$worker_id] = microtime(true);

                    // Update 2026-08-09 (Nachruest-Paket #8/#9): letzter Stand
                    // reicht - beide Werte aendern sich innerhalb einer Epoche
                    // kaum/gar nicht (Backend steht beim Start fest, GradNorm
                    // schwankt nur leicht), kein Grund fuer eine eigene
                    // Match-Iteration wie beim Loss oben.
                    if (preg_match('/GPU_BACKEND=(\w+)/', $output, $bm)) {
                        $epoch_backends[$worker_id] = $bm[1];
                    }
                    if (preg_match_all('/GradNorm:\s*([0-9.]+)/', $output, $gm)) {
                        $epoch_grad_norms[$worker_id] = (float)end($gm[1]);
                    }
                    // RECENT_LOSS= wird genau EINMAL pro Worker/Epoche ausgegeben
                    // (am Ende der Mini-Batch-Schleife) - kein "letzter Treffer
                    // gewinnt" noetig, aber schadet nicht, falls die Zeile ueber
                    // zwei Polls gesplittet an derselben Stelle nochmal matcht.
                    if (preg_match('/RECENT_LOSS=([0-9.]+)/', $output, $rm)) {
                        $epoch_recent_losses[$worker_id] = (float)$rm[1];
                    }
                    $worker_tail[$worker_id] = substr(($worker_tail[$worker_id] ?? '') . $output, -4096);
                    if (preg_match('/PLAN_STEPS=(\d+)\s+PLAN_TOKENS=(\d+)/', $worker_tail[$worker_id], $pm)) {
                        $epoch_plan_steps[$worker_id]  = (int)$pm[1];
                        $epoch_plan_tokens[$worker_id] = (int)$pm[2];
                    }
                    if (preg_match('/STEPS_DONE=(\d+)/', $worker_tail[$worker_id], $sm)) {
                        $epoch_steps_done[$worker_id] = (int)$sm[1];
                    }
                    // Sobald ALLE Worker gemeldet haben, steht der Plan der
                    // Epoche fest - einmal ausgeben, nicht bei jedem Poll.
                    if (!$epoch_plan_printed && count($epoch_plan_steps) === $num_workers) {
                        $epoch_plan_printed = true;
                        cluster_print_step_plan($epoch_plan_steps, $epoch_plan_tokens, $epoch, $max_epochs);
                    }

                    if (preg_match_all('/Step\s+(\d+)\s*\|\s*Avg Loss:\s*([0-9\.]+)/', $output, $matches)) {
                        $last_idx = count($matches[0]) - 1;
                        $step = (int)$matches[1][$last_idx];
                        $avg_loss = (float)$matches[2][$last_idx];
                        $epoch_losses[$worker_id] = $avg_loss;

                        $status = proc_get_status($processes[$worker_id]);

                        // AUDIT-FIX: Sichere den Exitcode sofort, wenn der Worker genau JETZT gestorben ist
                        if (!$status['running'] && !isset($worker_exitcodes[$worker_id])) {
                            $worker_exitcodes[$worker_id] = $status['exitcode'];
                        }

                        $telemetry_cache["Worker_" . $worker_id] = [
                            'loss' => round($avg_loss, 5),
                            'step' => $step,
                            'epoch' => $epoch,
                            'pid' => $status['pid'] ?? 0
                        ];
                        $telemetry_updated = true;
                    } elseif (preg_match('/Avg Loss:\s*([0-9\.]+)/', $output, $matches)) {
                        $epoch_losses[$worker_id] = (float)$matches[1];
                    }
                }
            }
            
            if ($telemetry_updated) {
                file_put_contents($telemetry_file, json_encode($telemetry_cache, JSON_PRETTY_PRINT), LOCK_EX);
            }
        }
        
        // Status der Prozesse prüfen & Bereinigen
        foreach ($processes as $i => $process) {
            if (!is_resource($process)) continue;
            
            $status = proc_get_status($process);
            if (!$status['running']) {
                // AUDIT-FIX: Caching des echten Exitcodes, um den -1 Bug von proc_get_status zu umgehen
                $exitcode = $worker_exitcodes[$i] ?? $status['exitcode'];
                if (!isset($worker_exitcodes[$i])) $worker_exitcodes[$i] = $exitcode;
                
                $final_out = stream_get_contents($pipes[$i][1]);
                if ($final_out) {
                    echo trim($final_out) . "\n";

                    // AUDIT-FIX: Diese Rest-Ausgabe wurde bisher nur ausgegeben,
                    // aber nie geparst. Ein schneller Worker, dessen komplette
                    // Ausgabe erst nach Prozessende ankommt, lieferte dadurch
                    // NIE einen Loss -> Epochen-Loss fiel auf den 999er-Default.
                    if (preg_match_all('/Avg Loss:\s*([0-9\.]+)/', $final_out, $fm)) {
                        $epoch_losses[$i] = (float)$fm[1][count($fm[1]) - 1];
                    }
                    // Update 2026-08-09 (Nachruest-Paket #8/#9): gleiche
                    // Nachhol-Logik wie beim Loss oben, falls Backend-/GradNorm-
                    // Zeilen erst nach Prozessende in den Pipes ankommen.
                    if (!isset($epoch_backends[$i]) && preg_match('/GPU_BACKEND=(\w+)/', $final_out, $fbm)) {
                        $epoch_backends[$i] = $fbm[1];
                    }
                    if (preg_match_all('/GradNorm:\s*([0-9.]+)/', $final_out, $fgm)) {
                        $epoch_grad_norms[$i] = (float)end($fgm[1]);
                    }
                    if (!isset($epoch_recent_losses[$i]) && preg_match('/RECENT_LOSS=([0-9.]+)/', $final_out, $frm)) {
                        $epoch_recent_losses[$i] = (float)$frm[1];
                    }
                    // Gleiche Nachhol-Logik fuer den Schrittplan: ein sehr
                    // schneller Worker (Mini-Chunk, Rauchtest) kann seine
                    // KOMPLETTE Ausgabe erst nach Prozessende in der Pipe
                    // haben - ohne das hier fiele der Plan dort still aus.
                    if (!isset($epoch_plan_steps[$i]) && preg_match('/PLAN_STEPS=(\d+)\s+PLAN_TOKENS=(\d+)/', $final_out, $fpm)) {
                        $epoch_plan_steps[$i]  = (int)$fpm[1];
                        $epoch_plan_tokens[$i] = (int)$fpm[2];
                    }
                    if (!isset($epoch_steps_done[$i]) && preg_match('/STEPS_DONE=(\d+)/', $final_out, $fsm)) {
                        $epoch_steps_done[$i] = (int)$fsm[1];
                    }
                }

                foreach ($pipes[$i] as $pipe) {
                    if (is_resource($pipe)) fclose($pipe);
                }
                
                proc_close($process); 
                unset($processes[$i]);
                $active_workers--;

                if ($exitcode !== 0) {
                    echo "🚨 [Cluster] Fatal: Worker $i ist abgestürzt (Exit-Code: $exitcode). Breche Epoche sofort ab.\n";
                    
                    // AUDIT-FIX: Zombie-Prozesse der übrigen Worker hart töten
                    // (cluster_kill_worker_tree() statt proc_terminate() allein
                    // - siehe Funktionskommentar oben, 2026-08-09)
                    foreach ($processes as $j => $other_process) {
                        if (is_resource($other_process)) {
                            echo "  > Terminiere verwaisten Zombie-Worker $j...\n";
                            cluster_kill_worker_tree($other_process);
                        }
                    }
                    exit(1);
                }
            }
        }

        // Update 2026-08-09 ("Engine-/Framework-Verbesserungen",
        // Punkt 3): Stall-Watchdog. Ein haengender (nicht abgestuerzter) Worker
        // (Treiber-Deadlock, Endlosschleife, blockierender FFI-Aufruf) wird von
        // der obigen Bereinigung nie erfasst - proc_get_status() meldet
        // weiterhin "running", stream_select() liefert einfach nie wieder
        // etwas. Ohne diese Pruefung wuerde die Epoche fuer immer blockieren,
        // ohne jeden Fehler. Gleiche Reaktion wie bei einem echten Absturz
        // (alle Worker terminieren, Fatal-Log, exit(1)) - kein automatischer
        // Neustart, da die Ursache (z.B. GPU-Treiber-Deadlock) vermutlich
        // fortbesteht und ein Automatik-Retry nur denselben Hang wiederholen
        // wuerde.
        foreach ($processes as $i => $process) {
            if (!is_resource($process)) continue;
            // AUDIT-FIX (Projekt-Review 2026-08-09): Fallback war "?? 0" -
            // ein fehlender Zeitstempel haette damit ein Idle von ~1,7 Mrd.
            // Sekunden (Unix-Epoch) ergeben und SOFORT den Notaus ausgeloest,
            // obwohl gar kein Stall vorliegt. Aktuell nicht erreichbar
            // ($worker_last_output_time und $processes werden gemeinsam
            // gesetzt), aber der sichere Default ist "jetzt" = kein Stall,
            // nicht "vor 55 Jahren" = sofort toeten.
            $idle_sec = microtime(true) - ($worker_last_output_time[$i] ?? microtime(true));
            if ($idle_sec > WORKER_STALL_TIMEOUT_SEC) {
                echo "🚨 [Cluster] Fatal: Worker $i haengt (" . round($idle_sec) . "s ohne Lebenszeichen, "
                   . "Limit " . WORKER_STALL_TIMEOUT_SEC . "s). Breche Epoche sofort ab.\n";

                foreach ($processes as $j => $other_process) {
                    if (is_resource($other_process)) {
                        echo "  > Terminiere Worker $j (Stall-Watchdog)...\n";
                        cluster_kill_worker_tree($other_process);
                    }
                }
                exit(1);
            }
        }
    }

    // Update 2026-09-04: Schritt-Bilanz der Epoche. Plan gegen Ausfuehrung -
    // eine Abweichung waere ein echter Befund (der Worker haette Fenster
    // uebersprungen), keine Rundung. Und ms/Schritt ist die Zahl, aus der sich
    // die Restdauer eines Segmentlaufs OHNE Schaetzen ergibt.
    if (!empty($epoch_steps_done)) {
        $done_sum = array_sum($epoch_steps_done);
        $plan_sum = array_sum($epoch_plan_steps);
        $wall     = microtime(true) - $epoch_start_time;
        $slowest  = !empty($epoch_steps_done) ? max($epoch_steps_done) : 0;
        echo "[Bilanz] Epoche $epoch: " . number_format($done_sum, 0, ',', '.') . " Schritte gelaufen"
           . ($plan_sum > 0 ? " (geplant " . number_format($plan_sum, 0, ',', '.') . ")" : "")
           . " in " . cluster_format_duration($wall)
           . ($slowest > 0 ? " -> " . number_format(($wall * 1000) / $slowest, 1, ',', '.') . " ms/Schritt (laengster Worker)" : "")
           . "\n";
        if ($plan_sum > 0 && $done_sum !== $plan_sum) {
            echo "⚠️  [Bilanz] Plan und Ausfuehrung weichen ab (" . ($done_sum - $plan_sum)
               . " Schritte). Erwartet ist Gleichstand - siehe snai_window_offsets() in train_defaults.php.\n";
        }
    }

    $checkpoint_state = $checkpoint_dir . "cp_{$session_id}_e{$epoch}.snai";
    average_models_stream($worker_outputs, $checkpoint_state);
    
    foreach ($worker_outputs as $wo) {
        @unlink($wo);
        @unlink(head_sidecar_path($wo)); // AUDIT-FIX: Sidecar mit entfernen
        @unlink(growth_sidecar_path($wo));
    }

    // Update 2026-08-14 (Neuron-Revival, siehe diagnose/snai_neuron_revival.php):
    // per Config-Flag (revival_config.json) ein-/ausschaltbarer Hook - scannt
    // den frisch geschriebenen Epochen-Checkpoint auf tote Neuronen und
    // ersetzt deren Zeilen durch frisches Genesis-Skala-Rauschen (inkl.
    // Adam-m/v-Reset fuer genau diese Zeilen). Laeuft SYNCHRON im selben
    // Prozess direkt nach average_models_stream() - kein externer, parallel
    // laufender Prozess, der den Checkpoint gleichzeitig lesen und
    // ueberschreiben koennte (das war der ursprüngliche Grund, warum ein
    // automatischer Hook zurueckgestellt wurde: load_model() nimmt beim
    // Lesen kein flock()). Additiv wie der Held-out-Eval-Block direkt
    // darunter: ein Fehlschlag hier bricht den Trainingslauf NIE ab, nur
    // eine Warnung, der unrevivte Checkpoint bleibt unangetastet bestehen.
    // Schreibt in eine temporaere Datei und tauscht sie erst per rename()
    // (atomar) ein - der Checkpoint existiert also nie in einem halb
    // geschriebenen Zustand.
    // BEFUND 2026-08-29 (Arm B r4 brach daran ab, Arm C wurde still verfaelscht):
    // Revival schreibt den GEMERGTEN CHECKPOINT NEU - also auch Zeilen in
    // Tensoren, die der laufende Arm eingefroren hat. Zwei Schaeden, der zweite
    // schlimmer als der erste:
    //
    //  1. Bei LoRA zeigt der eben in average_models_stream() gesetzte
    //     Basis-Fingerabdruck des Adapters danach auf Bytes, die es nicht mehr
    //     gibt. Die naechste Epoche lehnt den eigenen Adapter als "fremde Basis"
    //     ab und der Lauf stirbt. (Gemessen: cp_ab_B_r4_e1.snai 6bfc106c gegen
    //     gestempelte 639a137c.)
    //  2. Schlimmer: die eingefrorene Basis ist dann NICHT mehr eingefroren.
    //     Bei Arm C lagen 16 von 19 revivten Zeilen in den Schichten 0 und 1,
    //     die der Arm gar nicht trainieren darf. Ein solcher Lauf misst "letzte
    //     Schicht PLUS ein paar neu ausgewuerfelte Zeilen anderswo" - genau die
    //     Sorte stiller Beimischung, die einen Armvergleich verfaelscht.
    //
    // Deshalb: bei aktiver Freeze-Maske wird Revival UEBERSPRUNGEN, nicht
    // reparaturgestempelt. Ein Neustempeln haette Schaden 1 behoben und
    // Schaden 2 stehen lassen - also die Fehlermeldung beseitigt und den
    // Messfehler behalten.
    //
    // Kein neuer Schalter: die Maske selbst ist die Bedingung. Wer ohne Maske
    // faehrt (Arm 0, Arm A, der ganze Schwarmbetrieb), bekommt Revival
    // unveraendert - dort ist jede Zeile trainierbar und die Wiederbelebung
    // genau das, wofuer sie gebaut wurde.
    // Dieselbe Ableitung wie im Worker - ueber die gemeinsame Quelle, nicht
    // ueber eine zweite getenv()-Kopie. Seit SNAI_TRAIN_MODE=adapt einen
    // Default-Rang setzt, waere eine eigene Kopie hier still falsch geworden:
    // der Worker haette die Basis eingefroren, der Cluster haette das Revival
    // trotzdem darueberlaufen lassen.
    $freeze_lora = snai_lora_basis_eingefroren();
    $freeze_last = (int)trim((string)getenv('SNAI_TRAIN_LAST_LAYERS')) > 0;
    $revival_cfg = load_revival_config();
    if ($revival_cfg['enabled'] && ($freeze_lora || $freeze_last)) {
        printf("  > [Neuron-Revival] UEBERSPRUNGEN - dieser Arm hat eine eingefrorene "
             . "Menge (%s). Revival wuerde sie veraendern und den Arm verfaelschen.\n",
               $freeze_lora ? 'LoRA, Basis eingefroren' : 'nur letzte Schicht(en)');
    } elseif ($revival_cfg['enabled']) {
        $revival_tmp = $checkpoint_state . '.revival_tmp';
        // REPARATUR 2026-10-12: EIN Protokoll je Lauf. Mit dem Sitzungsnamen des
        // Segments (..._s<N>) begann jedes Segment bei Runde 1 - die Schutzfrist
        // (cooldown) konnte nie greifen.
        $revival_log = $checkpoint_dir . "revival_log_" . preg_replace('/_s\d+$/', '', $session_id) . ".json";
        // Update 2026-10-10: feste Saat. Ohne sie zieht das Revival seine neuen
        // Zeilen aus mt_rand() ohne Saat - zwei gleich konfigurierte Laeufe
        // waren nie bitgleich (gemessen: 3 von 7 Laeufen mit eigener Pruefsumme,
        // genau die mit Revival). "seed" in revival_config.json schaltet es ein;
        // Sitzungsname und Epoche gehen mit ein, damit nicht jedes Segment
        // dieselbe Zahlenfolge in seine Zeilen schreibt.
        $revival_seed_arg = '';
        if (isset($revival_cfg['seed']) && $revival_cfg['seed'] !== null && $revival_cfg['seed'] !== '') {
            $revival_seed = ((int)$revival_cfg['seed'] + crc32($session_id) + $epoch) & 0x7fffffff;
            $revival_seed_arg = ' --seed=' . $revival_seed;
            echo "  > [Neuron-Revival] feste Saat $revival_seed (Konfiguration {$revival_cfg['seed']}, Sitzung $session_id, Epoche $epoch).\n";
        }
        $revival_cmd = sprintf(
            'php %s %s %s --tensors=%s --scale=%F --norm-anteil=%F --log=%s --cooldown=%d%s 2>&1',
            escapeshellarg(__DIR__ . '/diagnose/snai_neuron_revival.php'),
            escapeshellarg($checkpoint_state),
            escapeshellarg($revival_tmp),
            escapeshellarg($revival_cfg['tensors']),
            $revival_cfg['scale'],
            (float)($revival_cfg['norm_anteil'] ?? 0.5),
            escapeshellarg($revival_log),
            $revival_cfg['cooldown'],
            $revival_seed_arg
        );
        $revival_output = @shell_exec($revival_cmd);
        $revival_ok = $revival_output !== null
            && file_exists($revival_tmp)
            && filesize($revival_tmp) === filesize($checkpoint_state);

        if ($revival_ok && rename($revival_tmp, $checkpoint_state)) {
            @unlink($revival_tmp . '.heads'); // Checkpoint behaelt seine eigene, unveraenderte .heads-Sidecar
            if (preg_match('/Gesamt:\s*(\d+)\s*\/\s*(\d+)\s*Neuronen revivt/', $revival_output, $rm) && (int)$rm[1] > 0) {
                echo "  > [Neuron-Revival] {$rm[1]} tote Neuronen revivt (von {$rm[2]} geprueft, "
                   . (($revival_cfg['norm_anteil'] ?? 0.5) > 0 ? "neue Zeile " . ($revival_cfg['norm_anteil'] ?? 0.5) . " x Median-Zeilennorm" : "Skala ±{$revival_cfg['scale']}") . ").\n";
            }
        } else {
            echo "⚠️ [Neuron-Revival] übersprungen/fehlgeschlagen (Trainingslauf läuft unbeeinflusst mit dem unrevivten Checkpoint weiter):\n";
            if ($revival_output !== null) echo "  " . trim($revival_output) . "\n";
            @unlink($revival_tmp);
            @unlink($revival_tmp . '.heads');
        }
    }

    // AUDIT-FIX: Kein einziger gemeldeter Loss bedeutet, dass KEIN Worker auch nur
    // einen Trainingsschritt ausgefuehrt hat. Bisher wurde daraus der Platzhalter
    // 999.0, der als echter Messwert weitergereicht und in den Drohnennamen
    // geschrieben wurde (_L999.0000) - ein untrainierter Klon sah damit aus wie
    // ein regulaerer Experte. Das ist ein Fehlschlag, kein Messwert.
    if (count($epoch_losses) === 0) {
        echo "🚨 [Fatal] Epoche $epoch hat keinen einzigen Loss gemeldet - es wurde nicht trainiert.\n";
        echo "  > Haeufigste Ursache: Chunk enthaelt zu wenige Tokens fuer einen Batch.\n";
        exit(1);
    }

    $current_epoch_loss = array_sum($epoch_losses) / count($epoch_losses);
    echo "[Metrik] Globaler Avg Loss: " . round($current_epoch_loss, 5) . "\n";

    // Update 2026-08-08 ("Held-out-Set + periodische Eval"):
    // reiner Forward-Pass-Loss auf einem separaten, nie trainierten Korpus
    // (factory/holdout/) - opt-in (laeuft nur, wenn der Ordner tatsaechlich
    // Dateien enthaelt, kein Pflicht-Setup fuer bestehende Aufrufer/Laeufe),
    // rein additiv, und NIE fatal fuer den eigentlichen Trainingslauf - ein
    // Fehlschlag hier wird nur als Warnung geloggt, bricht die Epochenschleife
    // nicht ab. eval_held_out.php schreibt sein eigenes strukturiertes Log
    // (factory/checkpoints/heldout_<session>.jsonl), hier nur eine kurze
    // STDOUT-Zeile neben dem Trainingsloss.
    // Explizit pro Epoche zurueckgesetzt (nicht nur implizit "unset"): sonst
    // wuerde eine Epoche ohne Held-out-Lauf (fehlender Ordner) oder mit
    // fehlgeschlagenem Parse stillschweigend den Wert der VORHERIGEN Epoche in
    // das gleich folgende train_<session>.jsonl uebernehmen.
    $heldout_loss_val = null;
    // Update 2026-08-09: eval_held_out.php gibt seit
    // Nachruest-Paket #11 auch HELDOUT_PPL= aus (siehe eval_held_out.php),
    // landete bisher aber nur in heldout_<session>.jsonl - im Konsolen-/
    // Cluster-Log tauchte nie mehr als der rohe Loss auf. Kann "INF" sein
    // (is_finite()-Guard in eval_held_out.php bei entartetem Loss), deshalb
    // Zahl ODER "INF" im Regex.
    $heldout_ppl_val = null;

    // ======================================================================
    // ARGMAX-FIX 2026-09-02 (unabhaengig bestaetigt vom Hauptzweig).
    //
    // DER DEFEKT. Die Auswahl lief fest verdrahtet gegen ./factory/holdout/ -
    // den generischen GEN-Pruefsatz - AUCH wenn der Lauf auf etwas ganz anderes
    // adaptiert (SFT). Auf GEN gemessen ist bei einem Adaptionslauf der am
    // wenigsten angepasste Stand zwangslaeufig der beste, weil jede weitere
    // Epoche Allgemeinwissen vergisst. Folge: in JEDER best_*.json dieses
    // Zweigs steht "epoch":1 - r4/r8/r16/r32, Arm D, A/A-Arm, ausnahmslos.
    // best_*.snai war damit systematisch der SCHLECHTESTE Stand, nicht der
    // beste. Das ist keine Unschaerfe, sondern eine Umkehrung.
    //
    // Erschwerend lief die Messung ueber den Ein-Fenster-Indikator
    // (eval_held_out_i8.php, +/-0,29 nats). Die Epochenunterschiede, um die es
    // geht, liegen bei 0,01 - der Indikator kann sie nicht aufloesen.
    //
    // DIE REPARATUR, zwei Teile:
    //   SNAI_BEST_HOLDOUT=<dir>  Pruefsatz, gegen den ausgewaehlt wird. Muss dem
    //                            LERNZIEL des Laufs folgen, nicht dem Default.
    //   SNAI_BEST_WINDOWS=<n>    Fensterzahl fuer den vollen Evaluator (Default
    //                            32, 0 = alle).
    // Ist SNAI_BEST_HOLDOUT gesetzt, laeuft eval_held_out_full_i8.php auf diesem
    // Verzeichnis. Die Kappung nimmt deterministisch die ERSTEN n Fenster
    // (eval_held_out_full_i8.php Z. 228) - ueber alle Epochen also dieselben.
    // Genau das macht den Epochenvergleich effektiv GEPAART, und die Paarung ist
    // der Grund, warum 92 feste Fenster 0,0011 nats auf 2,12 sigma aufloesen
    // konnten, waehrend die ungepaarte Streuung bei 0,29 liegt. 32 Fenster
    // kosten ~2 min je Epoche statt ~7 min fuer alle 92.
    //
    // WARUM KEIN AUTOMATISCHER DEFAULT. train_cluster.php bekommt einen Korpus,
    // keinen Pruefsatz - das Lernziel ist hier nicht ableitbar. Raten waere
    // derselbe Fehler noch einmal. Bleibt die Variable ungesetzt, laeuft das
    // alte Verhalten weiter, aber NICHT mehr stillschweigend: es warnt, und die
    // Herkunft der Auswahl steht ab jetzt in best_*.json. Ein best_*.snai ohne
    // 'auswahl'-Feld stammt aus der Zeit vor diesem Fix und ist verdaechtig.
    // (Stille Ausfaelle sind ein eigenes Thema: eine
    // Pruefung, die nichts meldet, sieht aus wie eine bestandene.)
    // ======================================================================
    $best_holdout   = getenv('SNAI_BEST_HOLDOUT');
    $best_windows   = getenv('SNAI_BEST_WINDOWS');
    $best_windows   = ($best_windows === false || $best_windows === '') ? 32 : max(0, (int)$best_windows);
    $auswahl_quelle = null;

    $ho_probe = @fopen($checkpoint_state, 'rb');
    $ho_magic = $ho_probe ? rtrim((string)fread($ho_probe, 8), "\0") : '';
    if ($ho_probe) fclose($ho_probe);
    $ist_int8 = snai_is_int8_ladbar($ho_magic);   // FULLINT8 Stufe 10: V8 misst eval_held_out_i8.php nativ

    if ($best_holdout !== false && $best_holdout !== '') {
        if (!is_dir($best_holdout) || count((array)glob(rtrim($best_holdout, '/') . '/*.txt')) === 0) {
            echo "🚨 [Best-Checkpoint] SNAI_BEST_HOLDOUT=\"$best_holdout\" ist kein Verzeichnis mit *.txt - " .
                 "Abbruch statt stiller Rueckfall auf den falschen Pruefsatz.\n";
            exit(1);
        }
        if (!$ist_int8) {
            echo "🚨 [Best-Checkpoint] SNAI_BEST_HOLDOUT gesetzt, aber der Checkpoint ist kein INT8 " .
                 "($ho_magic). Der volle Evaluator deckt nur V6/V7 ab.\n";
            exit(1);
        }
        $holdout_probe = [1]; // Pruefsatz ist verifiziert, Schleife darf laufen.
        // Eigenes Protokoll (SNAI_EVAL_LOG_TAG): diese Messung ist GEKAPPT und
        // dient nur der Epochenwahl. In der autoritativen
        // heldout_full_i8_<session>.jsonl haette sie nichts verloren - dort
        // stehen Voll-Korpus-Ergebnisse, und weil der Checkpoint dem Schema
        // cp_<session>_e<N>.snai folgt, waere sie dort sogar mit Epochenfeld
        // gelandet und von einem echten Messpunkt nicht zu unterscheiden.
        $heldout_cmd = 'SNAI_EVAL_LOG_TAG=argmax php ' . escapeshellarg(__DIR__ . '/eval_held_out_full_i8.php') . ' ' .
                       escapeshellarg($checkpoint_state) . ' ' . escapeshellarg($best_holdout) . ' ' .
                       // "auto" ist der dokumentierte Platzhalter (Z. 76-82 dort):
                       // Kopfzahl aus dem .heads-Sidecar aufloesen lassen. Hier eine
                       // Zahl zu raten waere die Falle, die das Skript selbst
                       // beschreibt - eine falsche Kopfzahl stuerzt nicht ab, sie
                       // liefert stillschweigend eine andere Zahl.
                       escapeshellarg('auto') . ' ' .
                       escapeshellarg((string)$best_windows) . ' 2>&1';
        $auswahl_quelle = ['pruefsatz' => $best_holdout, 'fenster' => $best_windows, 'evaluator' => 'full_i8'];
    } else {
        $holdout_probe = glob('./factory/holdout/*.txt');
        if ($holdout_probe !== false && count($holdout_probe) > 0) {
            echo "⚠️  [Best-Checkpoint] SNAI_BEST_HOLDOUT ist nicht gesetzt - die Auswahl laeuft gegen " .
                 "./factory/holdout/ (generisches GEN) mit dem Ein-Fenster-Indikator (+/-0,29 nats).\n";
            echo "    Bei einem ADAPTIONSLAUF waehlt das systematisch die ERSTE Epoche, also den " .
                 "schlechtesten Stand. best_{$session_id}.snai ist dann irrefuehrend benannt.\n";
            $auswahl_quelle = ['pruefsatz' => './factory/holdout/', 'fenster' => 1,
                               'evaluator' => $ist_int8 ? 'ein_fenster_i8' : 'ein_fenster_v5',
                               'warnung' => 'Pruefsatz folgt nicht dem Lernziel des Laufs'];
        }
    }

    if ($holdout_probe !== false && count($holdout_probe) > 0) {
        // INT8-NACHZUG 2026-08-19: eval_held_out.php versteht nur SNAI_V5.
        // Fuer INT8-Checkpoints das V6-Pendant nehmen, sonst meldet die
        // Held-out-Auswertung bei jedem INT8-Lauf nur "Korruptes Format" und
        // der Lauf laeuft dauerhaft ohne Qualitaetsmetrik.
        if ($auswahl_quelle['evaluator'] !== 'full_i8') {
            $ho_script = $ist_int8 ? '/eval_held_out_i8.php' : '/eval_held_out.php';
            $heldout_cmd = 'php ' . escapeshellarg(__DIR__ . $ho_script) . ' ' . escapeshellarg($checkpoint_state) . ' 2>&1';
        }
        $heldout_output = @shell_exec($heldout_cmd);
        // Der volle Evaluator meldet HELDOUT_FULL_LOSS=, der Ein-Fenster-
        // Indikator HELDOUT_LOSS=. Beide Formen annehmen, sonst faellt der
        // Fix stillschweigend in den "uebersprungen"-Zweig.
        if ($heldout_output !== null && preg_match('/HELDOUT(?:_FULL)?_LOSS=([0-9.]+)/', $heldout_output, $hm)) {
            $heldout_loss_val = (float)$hm[1];
            $ppl_display = 'n/a';
            if (preg_match('/HELDOUT(?:_FULL)?_PPL=([0-9.]+|INF)/', $heldout_output, $pm)) {
                $ppl_display = $pm[1];
                $heldout_ppl_val = is_numeric($pm[1]) ? (float)$pm[1] : null;
            }
            echo "[Metrik] Held-out Loss: {$hm[1]} | Perplexity: {$ppl_display}\n";

            // Update 2026-08-08 ("Best-Checkpoint-Retention"):
            // zusaetzlich zum aktuellen Epochen-Checkpoint (bleibt wie bisher
            // Startmodell der naechsten Epoche) eine STABIL benannte Kopie
            // best_{session}.snai halten, sobald ein neuer bester Held-out-
            // Loss erreicht wird - ohne Early Stopping gaebe es sonst nichts,
            // worauf man zurueckfallen koennte, falls ein spaeterer Lauf
            // schlechter wird. Platzbedarf skaliert stark mit dem Tier (siehe
            // Tabelle im Nachruest-Paket-Abschnitt) - deshalb ein Freiplatz-
            // Check VOR dem Kopieren statt eines pauschalen Tier-Schwellwerts:
            // reduziert sich bei kleinen Tiers (immer genug Platz) automatisch
            // auf "immer halten", bei grossen Tiers auf "nur den Wert loggen,
            // wenn's eng wird" - exakt die in der Roadmap vorgesehene
            // Ausweichoption, ohne eine zweite, separate Codepfad-Verzweigung.
            if ($heldout_loss_val < $best_heldout_loss) {
                $best_snai = $checkpoint_dir . "best_{$session_id}.snai";
                $needed_bytes = @filesize($checkpoint_state);
                $free_bytes = @disk_free_space($checkpoint_dir);
                $has_room = ($needed_bytes !== false && $free_bytes !== false && $free_bytes > $needed_bytes * 2);

                $best_heldout_loss = $heldout_loss_val;
                $best_state = [
                    'epoch'        => $epoch,
                    'heldout_loss' => $heldout_loss_val,
                    'checkpoint'   => null,
                    'timestamp'    => date('c'),
                    // Herkunft der Auswahl mitschreiben (Argmax-Fix 2026-09-02).
                    // Ohne dieses Feld ist einer best_*.json nicht anzusehen,
                    // GEGEN WAS ausgewaehlt wurde - und die Altbestaende dieses
                    // Zweigs wurden alle gegen den falschen Pruefsatz gewaehlt.
                    // Fehlendes 'auswahl' heisst deshalb: vor dem Fix entstanden,
                    // Epochenwahl unglaubwuerdig.
                    'auswahl'      => $auswahl_quelle,
                ];

                if ($has_room && @copy($checkpoint_state, $best_snai)) {
                    @copy(head_sidecar_path($checkpoint_state), head_sidecar_path($best_snai));
                    @copy(growth_sidecar_path($checkpoint_state), growth_sidecar_path($best_snai));
                    copy_lora_sidecar($checkpoint_state, $best_snai);
                    $best_state['checkpoint'] = basename($best_snai);
                    echo "  > [Best-Checkpoint] Neuer bester Held-out-Loss ($heldout_loss_val) -> " .
                         basename($best_snai) . " aktualisiert.\n";
                } else {
                    // Grossmodell-Ausweichoption aus der Roadmap: kein Platz (oder
                    // filesize/disk_free_space fehlgeschlagen) fuer eine zweite
                    // volle Kopie - nur der Wert wird fuer kuenftige Vergleiche
                    // und einen fortgesetzten Lauf festgehalten.
                    echo "  > [Best-Checkpoint] Neuer bester Held-out-Loss ($heldout_loss_val), aber zu wenig " .
                         "Plattenplatz fuer eine zweite Kopie - nur der Wert wird geloggt.\n";
                }
                @file_put_contents($best_state_path, json_encode($best_state));
            }
        } else {
            echo "⚠️ [Held-out-Eval] übersprungen/fehlgeschlagen (Trainingslauf läuft unbeeinflusst weiter):\n";
            if ($heldout_output !== null) echo "  " . trim($heldout_output) . "\n";
        }
    }

    // Update 2026-08-09 (Nachruest-Paket #7/#8/#9/#10):
    // strukturiertes Pendant zu heldout_<session>.jsonl (siehe oben) fuer den
    // Trainingsloss selbst plus Werte, die bisher nur im Stdout-Log
    // (Epochendauer, LR) bzw. gar nicht (Backend, GradNorm) sichtbar waren -
    // Grundlage fuer spaeteres Plotten von Train- gegen Held-out-Kurve, ohne
    // manuelle ps aux/Log-Archaeologie. Rein additiv, kein Einfluss auf den
    // eigentlichen Trainingslauf.
    // Update 2026-08-09: Loss der letzten N Schritte statt
    // des Epochendurchschnitts, als eigenes Feld NEBEN 'train_loss' - nicht als
    // Ersatz, damit die Bedeutung von 'train_loss' ueber die gesamte JSONL-
    // Historie hinweg konsistent bleibt (bestehende Zeilen vor diesem Update
    // haben dort schon den Epochendurchschnitt stehen, ein stiller
    // Bedeutungswechsel im selben Feldnamen waere fuer eine spaetere
    // Auswertung nicht mehr unterscheidbar). $current_epoch_loss (treibt
    // Notbremse/cluster_drones.log) bleibt bewusst unveraendert auf dem
    // Epochendurchschnitt - nur die Metrik-Ausgabe hier aendert sich.
    $train_loss_recent_val = count($epoch_recent_losses) > 0
        ? round(array_sum($epoch_recent_losses) / count($epoch_recent_losses), 6)
        : null;

    $train_log_entry = [
        'timestamp'          => date('c'),
        'epoch'              => $epoch,
        'train_loss'         => round($current_epoch_loss, 6),
        'train_loss_recent'  => $train_loss_recent_val,
        'lr'                 => round($active_lr, 6),
        'heldout_loss'       => $heldout_loss_val,
        'heldout_ppl'        => $heldout_ppl_val,
        'gpu_backend'        => count($epoch_backends) > 0 ? implode(',', array_unique($epoch_backends)) : 'NONE',
        'grad_norm'          => count($epoch_grad_norms) > 0 ? round(array_sum($epoch_grad_norms) / count($epoch_grad_norms), 4) : null,
        'epoch_duration_sec' => round(microtime(true) - $epoch_start_time, 2),
    ];
    @file_put_contents($checkpoint_dir . "train_{$session_id}.jsonl", json_encode($train_log_entry) . "\n", FILE_APPEND);
    $epochs_completed++;

    // AUDIT-FIX: Checkpoint der Vorepoche freigeben (sonst waechst checkpoints/
    // mit jeder Epoche jeder Drohne weiter). Der aktuelle bleibt - er ist das
    // Startmodell der naechsten Epoche und das spaetere Endergebnis.
    //
    // SNAI_KEEP_EPOCHS=1 (2026-09-02) haelt die Epochenstaende zurueck.
    // WOZU: bei einem LoRA-Arm ueberlebt der Epochenzustand in der .lora-Sidecar
    // (die Loeschung hier trifft nur .snai), jeder Zwischenstand ist also
    // nachtraeglich aus Basis + Adapter rekonstruierbar - genau davon lebt
    // run_epochenkurve_clipgains.sh. Bei einer VOLL-Feinabstimmung gibt es keine
    // Sidecar: was hier geloescht wird, ist unwiederbringlich weg. Deshalb hat
    // Arm A (ab_A_voll) keine Epochenkurve, und deshalb ist sein wahres
    // SFT-Optimum bis heute unbekannt - der einzige offene Vorbehalt gegen die
    // Kernaussage "LoRA schlaegt die Voll-Feinabstimmung".
    // Kosten: ~59 MB je Epoche auf dieser Geometrie. Default bleibt aus, damit
    // bestehende Laeufe checkpoints/ nicht volllaufen lassen.
    $keep_epochs = (getenv('SNAI_KEEP_EPOCHS') === '1');
    if ($epoch > 1 && !$keep_epochs) {
        $prev_cp = $checkpoint_dir . "cp_{$session_id}_e" . ($epoch - 1) . ".snai";
        if (file_exists($prev_cp)) {
            @unlink($prev_cp);
            @unlink(head_sidecar_path($prev_cp));
            @unlink(growth_sidecar_path($prev_cp));
        }
    } elseif ($epoch > 1) {
        echo "  > [Epochen-Aufbewahrung] cp_{$session_id}_e" . ($epoch - 1) .
             ".snai bleibt erhalten (SNAI_KEEP_EPOCHS=1).\n";
    }
    
    // =========================================================================
    // DIE SYMBIO-NOTBREMSE (DYNAMIC EARLY STOPPING)
    // =========================================================================
    if ($target_loss > 0.0 && $current_epoch_loss <= $target_loss) {
        echo "\n=================================================================\n";
        echo "[👑 QUEEN] ABSOLUTE KONVERGENZ ERREICHT! Loss liegt bei: " . round($current_epoch_loss, 5) . "\n";
        echo "[👑 QUEEN] Leite Notbrems-Protokoll ein. Gefriere Gewichte der Titanin...\n";
        echo "=================================================================\n";
        break; 
    }

    // WOZU DIESE BREMSE DA IST (nachgetragen 2026-08-29, weil sie beim
    // LoRA-A/B zugeschlagen hat und niemand mehr an sie dachte):
    // Sie schuetzt die DROHNEN im Schwarm-Betrieb. Eine Drohne wird nach dem
    // Training gemorpht/hochskaliert, nicht direkt benutzt - ein auf ihrem
    // kleinen Korpus ueberangepasstes Modell taugt dafuer nicht mehr. Der
    // Schwellwert 2,5 ist das Entropie-Minimum, ab dem das droht.
    //
    // Sie greift NUR ohne explizites $target_loss. Wer einen kontrollierten
    // Vergleich faehrt, muss sie ausschalten (positive, unerreichbare Schwelle
    // als argv[8]) - sonst laufen die Arme verschieden lange: ein Vollarm
    // erreicht 2,5 und bricht ab, ein LoRA-Arm mit einem Fuenfzigstel der
    // trainierbaren Parameter nie. Der Vergleich waere dann einer zwischen
    // 6 und 10 Epochen und saehe trotzdem aus wie ein Methodenvergleich.
    // Siehe run_lora_ab.sh.
    if ($epoch > 1 && $current_epoch_loss < 2.5 && $target_loss == 0.0) {
        echo "[Killswitch] Entropie-Minimum für BPE erreicht. Beende vorzeitig.\n";
        break;
    }
}

// 4. CLEANUP & LOGGING
$log_file = './factory/cluster_drones.log';
$timestamp = date('Y-m-d H:i:s');
$caste_tag = 'GEN';
if (preg_match('/expert_([A-Z]+)_/', basename($output_model), $m)) {
    $caste_tag = $m[1];
}
$uid = str_replace(['expert_', $caste_tag, '_', '.snai'], '', basename($output_model));

// Update 2026-08-09: Gesamtlaufzeit des kompletten Laufs
// (nicht nur einzelne Epochendauern, siehe train_<session>.jsonl) - bisher
// stand im Endlog nur der Fertigstellungs-Zeitpunkt, keine Dauer, das
// Terminal zeigte nur Zeit-pro-Step. $run_start_time oben vor dem Merge-
// Block erfasst, deckt also den kompletten Lauf ab, nicht nur die
// Epochenschleife.
$total_duration_sec = round(microtime(true) - $run_start_time, 1);
$dur_h = (int)($total_duration_sec / 3600);
$dur_m = (int)(($total_duration_sec % 3600) / 60);
$dur_s = (int)($total_duration_sec % 60);
$duration_display = $dur_h > 0 ? sprintf('%dh %dm %ds', $dur_h, $dur_m, $dur_s) : sprintf('%dm %ds', $dur_m, $dur_s);

$log_entry = sprintf("[%s] KASTE: %-8s | UID: %-12s | END-LOSS: %.5f | EPOCHEN: %d | DAUER: %s\n", $timestamp, $caste_tag, $uid, $current_epoch_loss, $max_epochs, $duration_display);
file_put_contents($log_file, $log_entry, FILE_APPEND | LOCK_EX);

// Update 2026-08-09: abschliessende Zusammenfassungszeile
// in train_<session>.jsonl - dieselbe Datei wie die Pro-Epoche-Zeilen aus dem
// Nachruest-Paket #7, per "epoch":"TOTAL" von den normalen Eintraegen
// unterscheidbar, damit ein Parser beides klar auseinanderhalten kann. Fasst
// fuer eine Gesamtuebersicht zusammen, was bisher ueber viele Einzelzeilen
// verstreut war (Epochendauern) bzw. gar nicht vorlag (Gesamtdauer). Bewusst
// dieselbe Datei statt einer neuen - ein Parser muss nur eine Quelle lesen.
$train_log_path = $checkpoint_dir . "train_{$session_id}.jsonl";
$summary_entry = [
    'timestamp'          => date('c'),
    'epoch'              => 'TOTAL',
    'epochs_run'         => $epochs_completed,
    'final_train_loss'   => round($current_epoch_loss, 6),
    'final_train_loss_recent' => $train_loss_recent_val ?? null,
    'final_heldout_loss' => is_finite($best_heldout_loss) ? $best_heldout_loss : null,
    'gpu_backend'        => count($epoch_backends ?? []) > 0 ? implode(',', array_unique($epoch_backends)) : 'NONE',
    'total_duration_sec' => $total_duration_sec,
    'total_duration'     => $duration_display,
];
@file_put_contents($train_log_path, json_encode($summary_entry) . "\n", FILE_APPEND);

foreach ($chunk_files as $chunk) @unlink($chunk);

// AUDIT-FIX: Vorher wurde der rename bei fehlendem Checkpoint stumm uebersprungen
// und danach trotzdem "Schwarm-Modell bereit" mit exit(0) gemeldet. Der Aufrufer
// (Destille / Steuer-Daemon) sah einen Erfolg ohne Modelldatei.
if (!file_exists($checkpoint_state)) {
    echo "🚨 [Fatal] Kein Checkpoint vorhanden - es wurde kein Modell erzeugt.\n";
    exit(1);
}

$output_dir = dirname($output_model);
if (!is_dir($output_dir) && !mkdir($output_dir, 0777, true)) {
    echo "🚨 [Fatal] Zielordner $output_dir konnte nicht angelegt werden.\n";
    exit(1);
}

if (!rename($checkpoint_state, $output_model)) {
    echo "🚨 [Fatal] Konnte $checkpoint_state nicht nach $output_model verschieben.\n";
    exit(1);
}

// Head-Zahl wandert mit dem Modell mit.
move_head_sidecar($checkpoint_state, $output_model);
move_growth_sidecar($checkpoint_state, $output_model);
// ...und der LoRA-Adapter erst recht: ohne ihn waere das Endmodell die
// unveraenderte Basis (siehe move_lora_sidecar()).
move_lora_sidecar($checkpoint_state, $output_model);

if (strpos(basename($output_model), 'expert_') === 0) {
    if (strpos($base_model, 'genesis_') !== false) {
        @unlink($base_model);
    }
}

// Speicherhoechststand mitschreiben. Bei einem Lauf ueber 40 Segmente
// unbeaufsichtigt ist das die Zahl, an der man sieht, ob die Grenze aus
// Zeile 39 noch traegt - der Merge ist der teuerste Punkt und faellt GANZ AM
// ENDE eines Segments an (am 2026-09-03 im Rauchtest bei dim 512 gegen die
// alte 1024M-Grenze gelaufen, nach vollstaendigem Training beider Arbeiter).
printf("[System] PHP-Speicherspitze: %.0f MB von %s\n",
    memory_get_peak_usage(true) / 1048576, ini_get('memory_limit'));
echo "\n[System] Schwarm-Modell bereit: $output_model\n";
exit(0);