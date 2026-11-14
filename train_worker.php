<?php
/**
 * Datei: train_worker.php
 * Funktion: Lokaler CLI-Worker für das Training der SNAI-Modelle. 
 * Liest Text-Chunks, tokenisiert sie, füttert die C-Bridge 
 * und speichert die Gewichte per Stream.
 * * SYMBIO NANO-AI FRAMEWORK (Code-4372)
 * Modul: Worker Training Node (Phase V - OOM Zero Edition)
 * -------------------------------------------------------------------------
 * MAXIME: E > H. Verarbeitet Chunks dynamischer Länge. 
 * AUDIT-V9.4: Array-Slice GC-Shredder in der Hot-Loop eliminiert.
 * AUDIT-FIX: UTF-8 Notfall-Cut repariert, Header-Validierung hinzugefügt.
 * VERSION: V2.1 - Initialisierungsreihenfolge korrigiert (num_heads vor Konstruktor).
 */

// AUDIT-FIX (2026-08-11): wie im Steuer-Daemon - date.timezone-Ini steht auf
// UTC statt Europe/Berlin (betrifft hier tensor_ffi_adapter.php's date()-Aufrufe).
date_default_timezone_set('Europe/Berlin');
// Limit auf 2048M hochgesetzt, da extract_state() am Ende kurzzeitig RAM für das gesamte Modell benötigt (E>H Sweetspot)
ini_set('memory_limit', '2048M');
require_once 'snai_tokenizer.php';
require_once 'tensor_io.php';
require_once 'tensor_ffi_adapter.php';
require_once __DIR__ . '/head_config.php';
require_once __DIR__ . '/growth_config.php';
require_once __DIR__ . '/train_defaults.php';

// LR-Boost fuer frisch Net2Net-expandierte Parameter.
// Faktor bewusst moderat gewaehlt als Startwert - Feintuning folgt empirisch.
define('GROWTH_LR_BOOST', 3.0);

/**
 * AUDIT-FIX: fread() liefert auf Netzwerk-Mounts (GVFS/SMB/NFS) regelmaessig
 * weniger Bytes als angefordert, ohne Fehler zu melden. Der Header-Read lief
 * dadurch in "Basismodell ist korrupt", obwohl die Datei in Ordnung war.
 */
function worker_robust_fread($fp, int $length): string {
    $data = '';
    while (strlen($data) < $length && !feof($fp)) {
        $chunk = fread($fp, $length - strlen($data));
        if ($chunk === false || $chunk === '') break;
        $data .= $chunk;
    }
    return $data;
}

/**
 * 2026-10-18: Abbruch mit Exitcode 1. Ersetzt die() im ganzen Worker - die() endet mit Exitcode 0, und
 * train_cluster.php wertet nur den Exitcode aus (Fehlersuche 2026-10-16, Befund A3). Die Meldung geht wie bei die()
 * nach stdout, damit sie im Cluster-Log an derselben Stelle steht wie bisher.
 */
function worker_abbruch(string $meldung): never {
    echo $meldung;
    exit(1);
}

// Konstanten für Magic Numbers (Wartbarkeit)
define('MIN_FILE_SIZE', 10);
define('DEFAULT_LR', 0.0005);
// Update 2026-08-09: Fenstergroesse fuer den "Loss der
// letzten N Schritte" (siehe RECENT_LOSS= unten) - bewusst deutlich kleiner
// als typische Epochenlaengen (haeufig mehrere hundert bis tausend Schritte),
// damit der Wert den Endstand der Epoche widerspiegelt statt vom
// Epochenanfang verwaessert zu werden.
define('RECENT_LOSS_WINDOW', 20);

if ($argc < 6) {
    worker_abbruch("Nutzung: php train_worker.php <input.txt> <output.snai> <epochs> <base_model> <dtype> [custom_lr] [global_epoch] [base_lr] [weight_decay] [dropout_rate] [label_smoothing]\n");
}

$input_file  = $argv[1];
$output_file = $argv[2];
$epochs      = (int)$argv[3];
$base_model  = $argv[4];
$dtype       = (int)$argv[5];
$custom_lr   = isset($argv[6]) ? (float)$argv[6] : DEFAULT_LR;
$global_epoch = isset($argv[7]) ? (int)$argv[7] : 1;
$base_lr     = isset($argv[8]) ? (float)$argv[8] : DEFAULT_LR;
// Optionale Regularisierung (Engine-Hooks existierten bereits in cortex.nim,
// wurden aber nirgends aufgerufen - Punkt 2 der
// Memorierungs-Gegenmassnahmen). Default 0.0 = No-Op, damit bestehende
// Aufrufe ohne diese Argumente exakt gleich verhalten wie bisher.
$weight_decay = isset($argv[9]) ? (float)$argv[9] : 0.0;
$dropout_rate = isset($argv[10]) ? (float)$argv[10] : 0.0;
// Update 2026-08-15 ("Naechste Schritte" Punkt 7): als
// letzter positioneller Arg angehaengt statt mittendrin eingefuegt - sonst
// verschieben sich alle nachfolgenden argv[N]-Indizes.
$label_smoothing = isset($argv[11]) ? (float)$argv[11] : 0.0;
// Update 2026-10-09 (docs/BUGFIXES.md §25): linearer SCHRITT-Warmup ueber die
// ersten N Adam-Schritte. Der Warmup in train_cluster.php zaehlt in Epochen
// und greift bei "eine Epoche je Aufruf" (Segmentlauf) gar nicht - Epoche 1
// lief dort immer mit voller Lernrate. Gezaehlt wird ueber adam_t aus dem
// Checkpoint, nicht ueber den Schrittzaehler dieses Prozesses: der Warmup
// laeuft damit EINMAL ab dem Kaltstart und setzt ueber Segmentgrenzen fort,
// statt an jeder Grenze neu anzulaufen. Als Umgebungsvariable statt argv,
// damit sich keine etablierte Argumentposition verschiebt. 0 = aus = exakt
// das bisherige Verhalten. Im LoRA-Modus ohne Wirkung, solange die Basis
// warm ist (adam_t der Basis liegt dann laengst ueber N).
$warmup_steps = max(0, (int)(trim((string)getenv('SNAI_WARMUP_STEPS')) ?: 0));
$warmup_t0 = null;
$warmup_n  = 0;
// Update 2026-10-10: Cosinus-Abklingen ueber SCHRITTE (SNAI_LR_DECAY_STEPS=N,
// N = Gesamtschritte des Laufs je Arbeiter). Der Epochen-Scheduler in
// train_cluster.php greift im Segmentlauf aus demselben Grund nicht wie sein
// Warmup (max_epochs=1). Laeuft ueber adam_t vom Warmup-Ende bis N von der
// Ziel-LR auf SNAI_LR_MIN_RATIO (Default 0.1, wie der Boden im Cluster) und
// bleibt danach dort. 0 = aus = exakt das bisherige Verhalten.
$lr_decay_steps = max(0, (int)(trim((string)getenv('SNAI_LR_DECAY_STEPS')) ?: 0));
$lr_min_ratio = getenv('SNAI_LR_MIN_RATIO');
$lr_min_ratio = ($lr_min_ratio === false || trim($lr_min_ratio) === '') ? 0.1 : min(1.0, max(0.0, (float)$lr_min_ratio));
// 2026-11-04 Warmup-Stable-Decay (messbuch snai/stell-reparatur27 e531, snai/stell-wsd e527): SNAI_LR_DECAY_START=S laesst
// den Cosinus erst bei adam_t=S beginnen (davor konstante Ziel-LR). Ohne Variable S = SNAI_WARMUP_STEPS = exakt das bisherige
// Verhalten. Bestes Knirps-Rezept 128x4/27k: SNAI_WARMUP_STEPS=2000, SNAI_LR_DECAY_START=0,9*N, SNAI_LR_DECAY_STEPS=N.
// 2026-11-05 (messbuch snai/stell-lr-leiter e548): Spitzen-LR fuer 128x4 0,0015 statt 0,003
// (Argument 6 und 8). Bei 9k und 27k je -0,048 nats, 8/8 Saaten; 0,00075-0,0015 gleich gut, 0,0005 schlechter.
// Gilt nur fuer Breite 128; andere Breiten brauchen eine eigene kurze Leiter (Richtung etwa 1/Breite). DEFAULT_LR bleibt.
$lr_decay_start_env = trim((string)getenv('SNAI_LR_DECAY_START'));
$lr_decay_start = ($lr_decay_start_env === '') ? $warmup_steps : max($warmup_steps, (int)$lr_decay_start_env);
if ($lr_decay_steps > 0 && $lr_decay_steps <= $lr_decay_start) {
    worker_abbruch("🚨 SNAI_LR_DECAY_STEPS=$lr_decay_steps liegt nicht hinter SNAI_LR_DECAY_START=$lr_decay_start - Abbruch.\n");
}
if ($lr_decay_steps > 0 && $lr_decay_steps <= $warmup_steps) {
    worker_abbruch("🚨 SNAI_LR_DECAY_STEPS=$lr_decay_steps liegt nicht hinter SNAI_WARMUP_STEPS=$warmup_steps - das Abklingen liefe nie. Abbruch statt stiller konstanter Lernrate.\n");
}
// Update 2026-10-10 (Segmentpruefung): Telemetrie und Zwischenstaende.
// SNAI_TELEMETRY_STEPS=N (Default 100, 0 = aus) schreibt alle N Schritte eine
// [Telemetrie]-Zeile: tatsaechliche Lernrate, Anteil geclippter Schritte und
// die Gradientenanteile je Tensorgruppe (Mittel ueber das Intervall). Eigene
// Zeile statt Anhang an die Step-Zeile, weil train_cluster.php die parst.
// SNAI_SNAPSHOT_STEPS="500,1000,2000" schreibt beim Erreichen dieser adam_t
// einen vollen Checkpoint snap_<Ausgabename>_t<adam_t>.snai neben die
// Ausgabedatei (nur INT8-Pfad). Anlass: die Attention saettigte im alten Lauf
// binnen ~500 Schritten, ein Segment dauert aber ueber einen Tag.
$telemetry_env = getenv('SNAI_TELEMETRY_STEPS');
$telemetry_steps = ($telemetry_env === false || trim($telemetry_env) === '') ? 100 : max(0, (int)$telemetry_env);
$snapshot_steps = array_values(array_filter(array_map('intval', explode(',', (string)getenv('SNAI_SNAPSHOT_STEPS'))), fn($v) => $v > 0));
$tm = ['n' => 0, 'clip' => 0, 'grp' => [0.0, 0.0, 0.0, 0.0, 0.0], 'qk' => [], 'ng' => 0];
$tm_flush = function (int $adam_t, float $lr) use (&$tm) {
    if ($tm['n'] === 0) return;
    $line = "  > [Telemetrie] adam_t=$adam_t LR=" . sprintf('%.7f', $lr)
          . " clip=" . sprintf('%.1f', 100.0 * $tm['clip'] / $tm['n']) . "% n=" . $tm['n'];
    // 'ng' zaehlt nur Schritte MIT Gradientenanteilen (ein Schritt ohne
    // trainierbare Position oder mit NaN-Norm liefert keine), sonst zoege
    // jeder solche Schritt die Mittel nach unten.
    if ($tm['ng'] > 0) {
        $names = ['emb', 'qk', 'vo', 'ffn', 'rest'];
        $line .= " | grad";
        foreach ($names as $g => $nm) $line .= " $nm=" . sprintf('%.2f', 100.0 * $tm['grp'][$g] / $tm['ng']) . "%";
        $line .= " | qk/Schicht";
        foreach ($tm['qk'] as $v) $line .= " " . sprintf('%.3f', 100.0 * $v / $tm['ng']);
    }
    echo $line . "\n";
    $tm = ['n' => 0, 'clip' => 0, 'grp' => [0.0, 0.0, 0.0, 0.0, 0.0], 'qk' => [], 'ng' => 0];
};

echo "=== [WORKER " . getmypid() . "] INITIALISIERE SCHMIEDE ===\n";

// Sanity Check Lernrate
if ($custom_lr <= 0) $custom_lr = DEFAULT_LR;
if ($base_lr <= 0.00001) {
    echo "  > [Worker " . getmypid() . "] 🌙 Traum-Modus aktiv (Experience Replay).\n";
}

if (!file_exists($base_model)) {
    worker_abbruch("🚨 Fatal: Basismodell konnte nicht gefunden werden -> $base_model\n");
}

if (!file_exists($input_file) || filesize($input_file) < MIN_FILE_SIZE) {
    echo "  > 🚨 Warnung: Chunk ist leer oder fehlt. Kopiere Basismodell als Fallback...\n";
    if (!copy($base_model, $output_file)) {
        worker_abbruch("🚨 Fatal: Konnte Basismodell nicht kopieren!\n");
    }
    // AUDIT-FIX: Ohne die Sidecar faellt der naechste Ladevorgang auf den
    // Legacy-Wert 1 Head zurueck und deutet die Attention-Gewichte um.
    $fallback_sidecar = head_sidecar_path($base_model);
    if (file_exists($fallback_sidecar)) {
        @copy($fallback_sidecar, head_sidecar_path($output_file));
    }
    propagate_growth_sidecar($base_model, $output_file);
    exit(0);
}

$tokenizer = new SnaiTokenizer('symbio_vocab.json');
$vocab_limit = $tokenizer->getVocabSize();

// Loss-Masking (Stichwort "Loss-Masking auf [USER]-Tokens"): [USER]
// und [SYMBIO] sind registrierte Einzel-Tokens (siehe snai_tokenizer.php),
// hier einmalig aufgeloest statt pro Chunk neu zu encoden.
$user_token_ids = $tokenizer->encode('[USER]');
$symbio_token_ids = $tokenizer->encode('[SYMBIO]');
$user_token_id = $user_token_ids[0];
$symbio_token_id = $symbio_token_ids[0];

// ============================================================================
// FIX V2.1: Header UND Head-Zahl muessen VOR dem Konstruktor feststehen.
// In V2 stand der Header-Read weiterhin hinter "new SnaiCortexBridge(...)",
// waehrend der Konstruktor bereits $num_heads erwartete -> "Undefined variable"
// und sofortiger Fatal Error in jedem Worker.
// ============================================================================

// --- 1. Header lesen (vor allem anderen) ---
$fp = fopen($base_model, 'rb');
worker_robust_fread($fp, 8); // Skip Magic
$h_data = worker_robust_fread($fp, 20);
fclose($fp);

// AUDIT-FIX: Harte Header-Validierung, um undefinierte Arrays und falsche CPU-Fallbacks zu verhindern
if ($h_data === false || strlen($h_data) !== 20) {
    worker_abbruch("🚨 [Fatal] Basismodell ist korrupt oder unvollständig (Header < 28 Bytes)!\n");
}

$p = unpack('Vvocab/Vdim/Vffn/Vctx/Vlayers', $h_data);
$model_dim = $p['dim'];

// --- 2. Head-Zahl aufloesen ---
// num_heads ist NICHT im .cortex-Header persistiert. Ein bereits trainierter
// Checkpoint hat headSize implizit in seinen Gewichten "eingebrannt" - wird er
// mit einer anderen Head-Zahl geladen, bleiben die Zahlen gleich, ihre Bedeutung
// (RoPE-Rotation, Attention-Segmentierung) aendert sich komplett. Deshalb liegt
// die Head-Zahl in einer Sidecar-Datei neben dem Modell und wird NIE aus der
// Modellgroesse neu geraten, sobald sie einmal feststeht.
require_once __DIR__ . '/head_config.php';
$num_heads = resolve_num_heads($base_model, $model_dim);
echo "  > [Heads] $num_heads Attention-Heads (headSize=" . intdiv($model_dim, $num_heads) . ") fuer dieses Modell.\n";

// --- 3. DER INJEKTOR (jetzt mit gueltigem $num_heads) ---
// PHASE 6 DES INT8-UMBAUS ("Kleinigkeiten"-Nachzug):
// $base_model kann bereits selbst ein
// SNAI_V6-Checkpoint (INT8) sein - Fortsetzung eines mehrepochigen INT8-Laufs
// (train_cluster.php reicht in Epoche 2+ den Vorepochen-Checkpoint als neues
// $base_model durch, siehe dortige $start_model-Logik). In dem Fall NICHT
// erst als FP32 laden + quantisieren (quantize_to_int8() wuerde auf einer
// V6-Datei ohnehin scheitern, cortex_load_stream() versteht das Format gar
// nicht), sondern direkt nativ per cortex_load_stream_i8()
// (SnaiCortexBridge $native_int8=true, Phase 6). Der Byte-Skip-Header-Read
// weiter oben funktioniert fuer beide Formate identisch (SNAI_V6s Header hat
// dieselben ersten 28 Bytes wie SNAI_V5, nur 4 Byte laenger) - keine Aenderung
// dort noetig.
$fp_magic = fopen($base_model, 'rb');
$base_model_magic = rtrim(fread($fp_magic, 8), "\0");
fclose($fp_magic);
$base_already_int8 = snai_is_int8_magic($base_model_magic);
$dtype_requested_int8 = ($dtype === SNAI_CLI_DTYPE_INT8);

if ($base_already_int8 && !$dtype_requested_int8) {
    worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": Basismodell ist bereits INT8 ($base_model_magic), aber dtype=$dtype fordert FP32 an - nicht unterstuetzt.\n");
}

// ============================================================================
// SNAI_V7 / WEIGHT TYING (2026-08-29)
// ----------------------------------------------------------------------------
// Schaltbar ueber SNAI_TIE_EMBEDDINGS. STANDARD SEIT 2026-09-02: AN (INT8).
// Vorher war der Default AUS. Begruendung und Messwerte in train_defaults.php;
// kurz: gebundenes Vortraining endet 0,034 nats hinter dem ungebundenen
// (4,7215 gegen 4,6879, 192 Fenster), Adaption darauf 5,3983 gegen 5,3991 -
// bei 32 % weniger Bytes. SNAI_TIE_EMBEDDINGS=0 schaltet es wieder aus.
//
// Ist das Basismodell bereits eine V7-Datei, ist es per Definition gebunden;
// die Umgebungsvariable braucht es dann nicht (und ein Weglassen darf die
// Bindung NICHT stillschweigend aufloesen - sonst waechst ein gebundenes
// Modell ab der zweiten Epoche als ungebundenes weiter und niemand merkt es).
// Das gilt auch fuer ein ausdrueckliches =0: die Bindung einer V7-Datei laesst
// sich nicht per Umgebungsvariable aufloesen, dafuer gibt es kein w_out.
$base_already_tied = ($base_model_magic === SNAI_MAGIC_V7);
[$tie_default_on, $tie_explicit] = snai_tie_embeddings();

// GRENZE DES DEFAULTS, und sie ist nicht kosmetisch: nachtraegliches Binden
// eines bereits trainierten UNGEBUNDENEN INT8-Modells ist kein Standardfall,
// sondern der Weg, auf dem base_prin_int8_s13_tied.snai entstanden ist -
// Held-out 10,23, also zerstoert (es dient diesem Zweig seither als
// Positivkontrolle). Auf dem LoRA-Pfad faengt Zeile 697 das mit einem harten
// Abbruch ab; ohne LoRA gaebe es nicht einmal den. Ein Default, der je nach
// Pfad abbricht oder zerstoert, ist keiner.
//
// Der Default greift deshalb dort, wo die Messung herkommt: an der GENESIS.
// prin_tied_s13 ist von Segment 0 an gebunden gewachsen und endet bei 4,7215
// gegen 4,6879 des ungebundenen Laufs. Wer ein vorhandenes V6 dennoch binden
// will, muss SNAI_TIE_EMBEDDINGS=1 ausdruecklich setzen - dann gilt sein
// Wille, samt der Pruefungen weiter unten.
//
// NACHTRAG 2026-09-03: die erste Fassung dieser Schranke fragte
// `$base_already_int8` ab - und liess damit den FP32-Fall offen. Gemessen:
// ein trainiertes SNAI_V5 (best_langb_fp32_s7) als Basis, dtype=INT8, LoRA
// aus -> die Ausgabe war SNAI_V7, das trainierte w_out also verworfen.
// Held-out 7,6383 gegen 6,8467 desselben Laufs mit SNAI_TIE_EMBEDDINGS=0:
// 0,79 nats Schaden, ohne Warnung, mit rc 0. Auf dem LoRA-Pfad faengt Zeile
// 697 das ab; ohne LoRA fiel es durch - genau die Konstellation, die ein
// Vergleichsarm braucht.
//
// Die Schranke haengt jetzt am ausdruecklichen Genesis-Signal des Clusters
// statt an einer Eigenschaft der Basisdatei. Aus der Datei ist es auch nicht
// ablesbar: eine frische Genesis und ein trainiertes FP32-Modell sind beide
// SNAI_V5.
if ($tie_default_on && !$tie_explicit && !$base_already_tied
        && !snai_ist_genesis_lauf()) {
    $tie_default_on = false;
}

$tie_requested = $tie_default_on || $base_already_tied;

if ($tie_requested && !($dtype_requested_int8 || $base_already_int8)) {
    // Nur meckern, wenn jemand es ausdruecklich verlangt hat. Der blosse
    // Default soll nicht bei jedem FP32-Lauf eine Warnung erzeugen - eine
    // Warnung, die immer kommt, wird nicht mehr gelesen.
    if ($tie_explicit) {
        fwrite(STDERR, "⚠️  [V7] SNAI_TIE_EMBEDDINGS gesetzt, aber dtype=$dtype ist nicht INT8 - ignoriert.\n");
    }
    $tie_requested = false;
}

// ============================================================================
// FULL-INT8-PORT (2026-08-24): Anbindung an die Pipeline.
// ----------------------------------------------------------------------------
// Der vollstaendige Ganzzahl-Stack (Backward, Gradienten-Akkumulation,
// Adam-Momente, FFN-Aktivierungen, SiLU-Tabelle) ist ueber SNAI_INT8_FULL
// schaltbar. Default AUS - ohne die Variable verhaelt sich der Worker exakt
// wie bisher (Hybrid-Pfad), laufende Trainings sind also unberuehrt.
//
// Werte:
//   SNAI_INT8_FULL=1      alles an (Rechenkern + beide Speicherumbauten)
//   SNAI_INT8_FULL=compute nur der Rechenkern (kein Speicherumbau) - nuetzlich,
//                          wenn die Checkpoint-Kompatibilitaet wichtiger ist
//                          als der RAM-Gewinn
//   nicht gesetzt / 0     bisheriges Verhalten
//
// WICHTIG: die beiden Speicherumbauten (Adam-Momente, FFN-Aktivierungen)
// entscheiden sich in cortex_init() und muessen deshalb ueber den KONSTRUKTOR
// gesetzt werden - nachtraeglich wirken sie nicht (Full-INT8-Port,
// Schritt 3).
$int8_full_env = strtolower(trim((string)getenv('SNAI_INT8_FULL')));
$int8_full     = ($int8_full_env === '1' || $int8_full_env === 'compute');
$int8_full_mem = ($int8_full_env === '1');
$is_int8_planned = $dtype_requested_int8 || $base_already_int8;

if ($int8_full && !$is_int8_planned) {
    // Ohne INT8-dtype gibt es keinen Ganzzahl-Pfad, den man erweitern koennte.
    fwrite(STDERR, "⚠️  [FULL-INT8] SNAI_INT8_FULL gesetzt, aber dtype=$dtype ist nicht INT8 - ignoriert.\n");
    $int8_full = false;
    $int8_full_mem = false;
}
// PUNKT 3 (2026-08-24): der Speicherumbau laeuft jetzt auch beim FORTGESETZTEN
// Training auf einem SNAI_V6-Basismodell. Vorher war er dort abgeschaltet, weil
// der Ladepfad cortex_load_stream_i8() nicht eigens geprueft war - zu Recht: er
// las den Adam-Zustand direkt nach m_*.data, das beim Umbau legitim nil ist
// (SIGSEGV). Behoben, nachgewiesen von diagnose/verify_fullint8_resume.php.
// LoRA-Umgebung MUSS vor dem Konstruktor gelesen werden: der Speicherarm
// (Adam-Zustand der Basis gar nicht erst anlegen) entscheidet sich in
// cortex_init() und wirkt nachtraeglich nicht mehr. Nachtraegliches Freigeben
// wurde gemessen und bringt NICHTS - der Spitzenverbrauch entsteht beim Laden.
// Rang aus der gemeinsamen Quelle: bei SNAI_TRAIN_MODE=adapt ist r8 der
// Standard, sonst 0. Eine ausdrueckliche SNAI_LORA_RANK schlaegt beides.
// Der Cluster leitet denselben Wert ueber dieselbe Funktion ab - er muss die
// eingefrorene Basis kennen, um das Neuron-Revival zu sperren.
$lora_rank      = snai_lora_rank();
$lora_requested = $lora_rank > 0;
$lora_freeze    = snai_lora_freeze();
// Vorladen nur auf dem NATIVEN INT8-Ladeweg: bei einem FP32-Basismodell legt
// cortex_load_stream() den Adam-Zustand ohnehin auf dem anderen Pfad an.
$lora_preload   = $lora_requested && $lora_freeze && $base_already_int8;

$cortex = new SnaiCortexBridge(
    $base_model, $num_heads, $base_already_int8,
    $int8_full_mem,   // Adam-Momente als 8 Bit
    $int8_full_mem,   // act_ffn_out als int8
    $int8_full_mem,   // act_ffn_in als int8
    $lora_preload     // LoRA-Speicherarm: Basis-Adam gar nicht erst anlegen
);
$is_int8 = $dtype_requested_int8 || $base_already_int8;

// --- 3a. INT8-Quantisierung nur noetig, wenn NOCH NICHT quantisiert (erste
// INT8-Epoche eines Laufs, Basismodell war FP32) - bei einem bereits
// SNAI_V6-Basismodell hat der Konstruktor oben schon nativ INT8 geladen. ---
if ($is_int8 && !$base_already_int8) {
    if (!$cortex->quantize_to_int8()) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": cortex_quantize_from_fp32() fehlgeschlagen.\n");
    }
    $validate_flags = $cortex->validate_i8();
    if ($validate_flags !== 0) {
        fwrite(STDERR, "⚠️  [INT8] cortex_validate_i8() meldet Flags=$validate_flags direkt nach Quantisierung.\n");
    }
    echo "  > [INT8] Gewichte in-memory quantisiert (Design-Entscheidung #1: Per-Zeile-Skala).\n";
} elseif ($base_already_int8) {
    $validate_flags = $cortex->validate_i8();
    if ($validate_flags !== 0) {
        fwrite(STDERR, "⚠️  [INT8] cortex_validate_i8() meldet Flags=$validate_flags direkt nach nativem SNAI_V6-Laden.\n");
    }
    echo "  > [INT8] Basismodell bereits $base_model_magic - nativ geladen (fortgesetztes INT8-Training).\n";
}

// --- 3a-ter. SNAI_V7: Weight Tying herstellen ---
// Muss NACH der Quantisierung stehen (vorher gibt es keinen INT8-Zustand zum
// Binden) und VOR dem ersten Trainingsschritt. Ein aus einer V7-Datei
// geladenes Modell ist bereits gebunden - cortex_tie_embeddings() ist dann
// folgenlos, der Aufruf bleibt trotzdem stehen, damit der Pfad nur eine
// einzige Stelle hat.
if ($tie_requested && $is_int8) {
    $cortex->tie_embeddings();
    // Die WIRKUNG abfragen, nicht den Wunsch (Lehre aus dem
    // i8_error_feedback_active-Befund, 2026-08-25): laut scheitern
    // ist hier zwingend, denn ein still ungebunden weiterlaufendes Training
    // wuerde ein V6 schreiben und die Bindung waere ab dieser Epoche weg.
    if (!$cortex->tied_embeddings_active()) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": Weight Tying angefordert, kam aber nicht zustande.\n");
    }
    echo "  > [V7] Weight Tying aktiv - w_out ist die Embedding-Matrix (SNAI_V7).\n";
}

// ============================================================================
// EMB-EINGANG und FFN-AUS (2026-11-03, messbuch snai/engine-emb-eingang und
// snai/engine-ffn-weg). Beides sind Eigenschaften des MODELLS, keine Lauf-
// Stellraeder: der Faktor steht als SNAI_V7 Flags Bit 1 in der Datei, ein
// abgeschalteter FFN-Zweig als rms_ffn = 0 und w_down = 0 in den Gewichten.
// Einschalten geht deshalb nur an der GENESIS: snai_ist_genesis_lauf() UND
// die Basis hat noch keinen Adam-Schritt gesehen (adam_t 0). Das zweite
// Kriterium faengt den Fall ab, dass SNAI_GENESIS_RUN von Hand gesetzt ist,
// die Basis aber trainiert. Ab dem zweiten Segment traegt die Basis den
// Zustand selbst; dann wird nur geprueft, dass er noch da ist.
//
//   SNAI_EMB_EIN=1        Faktor sqrt(dim) am Eingang (nur INT8 mit Tying)
//   SNAI_FFN_AUS=1,2,3    FFN-Zweig dieser Schichten exakt 0 (nur INT8)
//   SNAI_FFN_SKIP=0       Engine-Erkennung aus (Pruefung, cortex.nim)
// ============================================================================
$genesis_basis = snai_ist_genesis_lauf() && $is_int8 && $cortex->get_adam_t() === 0;
$emb_env = trim((string)getenv('SNAI_EMB_EIN'));
$emb_neu = false;
if (!in_array($emb_env, ['', '0', '1'], true)) {
    worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": SNAI_EMB_EIN='$emb_env' ungueltig (1 = an der Genesis einschalten).\n");
}
$emb_aktiv = $is_int8 ? $cortex->emb_eingang_aktiv() : false;   // null = Bibliothek kennt den Faktor nicht
if ($emb_env === '1' && $emb_aktiv !== true) {
    if ($emb_aktiv === null) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": SNAI_EMB_EIN=1, aber libcortex.so kennt den Embedding-Eingangsfaktor nicht.\n");
    }
    if (!$is_int8 || !$cortex->tied_embeddings_active()) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": SNAI_EMB_EIN=1 geht nur mit INT8 und Weight Tying (SNAI_V7).\n");
    }
    if (!$genesis_basis) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": SNAI_EMB_EIN=1, aber die Basis " . basename($base_model)
          . " ist keine Genesis (SNAI_GENESIS_RUN=" . var_export(getenv('SNAI_GENESIS_RUN'), true)
          . ", adam_t=" . $cortex->get_adam_t() . ") und traegt das Bit nicht. Den Faktor nachtraeglich an ein "
          . "trainiertes Modell zu haengen, aendert seine Rechnung (gemessen: alte Modelle mit Faktor -0,05 nats). "
          . "Eine Genesis als Basis uebergeben (bei eigener Genesis-Datei: SNAI_GENESIS_RUN=1).\n");
    }
    if ($cortex->emb_eingang_setzen() !== true || $cortex->emb_eingang_aktiv() !== true) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": Embedding-Eingangsfaktor angefordert, kam aber nicht zustande.\n");
    }
    $emb_neu = true;
    $emb_aktiv = true;
    // Nur bei Breite 128 gemessen (messbuch snai/engine-emb-eingang). Bei d=512 startet EE erheblich schlechter
    // (Schritt 1 12,43 statt 5,75, messbuch e495/e496: das eigene Token bekommt ueber den gebundenen Ausgang ein
    // Logit ~ g*d*RMS(E), linear in der Breite). Festgelegt 2026-11-03: nur Warnung, keine Sperre.
    // Nachtrag 2026-11-03 abends (Warnung um den 512er-Befund ergaenzt): messbuch snai/multistack-ee-512,
    // L8, F 22,6, 3 Saaten: mehr tote FFN-Gains als ohne EE (B/A 1,3-2,7, Richtung 3/3), Attention-Gains von
    // Schicht 0 zu 68-76 % tot, Held-out Gleichstand. Bei 512 also keine Reparatur, sondern Schaden.
    if ((int)$cortex->hidden_dim !== 128) {
        fwrite(STDERR, "⚠️⚠️ [EMBEIN] WARNUNG: Embedding-Eingangsfaktor bei Breite " . $cortex->hidden_dim
          . " eingeschaltet - als Reparatur belegt ist er nur bei Breite 128. Bei 512 (L8, 3 Saaten) starben "
          . "damit MEHR FFN-Gains als ohne (Richtung 3/3), die Attention-Gains von Schicht 0 zu 68-76 %, "
          . "Held-out ohne Gewinn (messbuch snai/multistack-ee-512); der Start war erheblich schlechter "
          . "(Schritt 1: 12,43 statt 5,75; snai/ee512-kopierbias).\n");
    }
} elseif ($emb_env === '0' && $emb_aktiv === true) {
    fwrite(STDERR, "⚠️  [EMBEIN] SNAI_EMB_EIN=0 hat keine Wirkung: die Basis traegt Bit 1, der Faktor gehoert zum Modell.\n");
}
if ($emb_aktiv === true) {
    printf("  > [EMBEIN] Embedding-Eingangsfaktor aktiv: F = %.6f (%s).\n", $cortex->emb_eingang_faktor(),
           $emb_neu ? "an der Genesis eingeschaltet" : "aus der Basis, SNAI_V7 Bit 1");
}

$ffn_env = trim((string)getenv('SNAI_FFN_AUS'));
$ffn_neu = [];
if ($ffn_env !== '') {
    if (!$is_int8) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": SNAI_FFN_AUS geht nur mit INT8.\n");
    }
    $ffn_schichten = [];
    foreach (explode(',', $ffn_env) as $ffn_teil) {
        $ffn_teil = trim($ffn_teil);
        if (!preg_match('/^\d+$/', $ffn_teil) || (int)$ffn_teil >= $p['layers'] || in_array((int)$ffn_teil, $ffn_schichten, true)) {
            worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": SNAI_FFN_AUS='$ffn_env' ungueltig (Schichten 0.."
              . ($p['layers'] - 1) . ", durch Komma getrennt, ohne Wiederholung).\n");
        }
        $ffn_schichten[] = (int)$ffn_teil;
    }
    if ($cortex->ffn_zweig_null($ffn_schichten[0]) === null) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": SNAI_FFN_AUS gesetzt, aber libcortex.so kennt cortex_ffn_aus nicht.\n");
    }
    foreach ($ffn_schichten as $ffn_l) {
        if ($cortex->ffn_zweig_null($ffn_l) === true) continue;     // schon aus (Basis traegt es)
        if (!$genesis_basis) {
            worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": SNAI_FFN_AUS nennt Schicht $ffn_l, deren FFN-Zweig in der "
              . "Basis " . basename($base_model) . " nicht aus ist, und dies ist keine Genesis (adam_t="
              . $cortex->get_adam_t() . "). Nullsetzen nur an der Genesis. Wurde der Zweig wiederbelebt "
              . "(Neuron-Revival auf w_down, SNAI_GAIN_GUARD)?\n");
        }
        if ($cortex->ffn_aus($ffn_l) !== true) {
            worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": FFN-Zweig Schicht $ffn_l liess sich nicht nullsetzen.\n");
        }
        $ffn_neu[] = $ffn_l;
    }
    $ffn_skip = [];
    foreach ($ffn_schichten as $ffn_l) {
        if ($cortex->ffn_zweig_uebersprungen($ffn_l) === true) $ffn_skip[] = $ffn_l;
    }
    printf("  > [FFN-AUS] FFN-Zweig exakt 0 in Schicht %s (%s); die Engine ueberspringt Schicht %s.\n",
           implode(',', $ffn_schichten), $ffn_neu ? "an der Genesis genullt: " . implode(',', $ffn_neu) : "aus der Basis",
           $ffn_skip ? implode(',', $ffn_skip) : "keine");
}

// ============================================================================
// LoRA (2026-08-29)
// ----------------------------------------------------------------------------
// Schaltbar ueber SNAI_LORA_RANK. Default AUS - ohne die Variable verhaelt sich
// der Worker exakt wie bisher.
//
//   SNAI_LORA_RANK=<n>     Rang der Adapter, >0 schaltet LoRA ein
//   SNAI_LORA_ALPHA=<f>    Skalierung ist alpha/rank, 0 = alpha:=rank (Default)
//   SNAI_LORA_SLOTS=<n>    Bitmaske: 1=w_q 2=w_k 4=w_v 8=w_o 16=w_up 32=w_down
//                          Default 63 (alle). 5 = nur Q und V.
//   SNAI_LORA_FREEZE=0     Basis MIT trainieren (eigener Vergleichsarm)
//   SNAI_LORA_SEED=<n>     Saat der A-Initialisierung, gleiche Saat = gleiche
//                          Adapter (fuer den A/B Bedingung, nicht Komfort)
//
// Der Adapter zu `X.snai` heisst `X.lora` (snai_lora_path()). Existiert er
// neben dem Basismodell, wird er geladen - ein LoRA-Lauf setzt damit ueber
// Epochengrenzen fort, ohne dass die Basis ein zweites Mal geschrieben werden
// muesste.
// $lora_rank/$lora_requested/$lora_freeze stehen schon oben - sie werden vor
// dem Konstruktor gebraucht (Speicherarm).
if ($lora_requested && !$is_int8) {
    fwrite(STDERR, "⚠️  [LoRA] SNAI_LORA_RANK gesetzt, aber dtype=$dtype ist nicht INT8 - ignoriert.\n");
    $lora_requested = false;
}
$lora_active = false;
if ($lora_requested) {
    $lora_alpha  = (float)(trim((string)getenv('SNAI_LORA_ALPHA')) ?: 0.0);
    $lora_slots  = (int)(trim((string)getenv('SNAI_LORA_SLOTS')) ?: SnaiCortexBridge::LORA_ALL);
    $lora_seed   = (int)(trim((string)getenv('SNAI_LORA_SEED')) ?: 1234567);

    // Der gebuendelte Pfad ist Pflicht - der Positions-major-Spiegel kennt die
    // Adapter nicht und wuerde ohne sie trainieren. cortex.nim bricht dort laut
    // ab; hier wird der Schalter vorsorglich gesetzt, damit es gar nicht erst
    // dazu kommt.
    $cortex->set_batched_i8(1);

    if (!$cortex->lora_enable($lora_rank, $lora_alpha, $lora_slots, $lora_freeze, $lora_seed)) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": cortex_lora_enable() abgelehnt (Rang $lora_rank, Maske $lora_slots).\n");
    }
    // WIRKUNG abfragen, nicht den Wunsch - gleiche Linie wie beim Tying oben.
    // Ein still ohne Adapter weiterlaufendes Training saehe wie ein LoRA-Lauf
    // aus und waere keiner.
    if (!$cortex->lora_active()) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": LoRA angefordert, kam aber nicht zustande.\n");
    }
    $lora_active = true;

    $lora_in = snai_lora_path($base_model);
    if (file_exists($lora_in)) {
        $lora_state = load_lora_stream($lora_in, $base_model);
        if ($lora_state === null) {
            worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": Adapterdatei $lora_in nicht ladbar - "
              . "lieber abbrechen als mit frischen Adaptern weiterrechnen und es Fortsetzung nennen.\n");
        }
        if (!$cortex->apply_lora_state($lora_state)) {
            worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": Adapterzustand passt nicht zur Einrichtung "
              . "(Rang/Maske). Datei: Rang {$lora_state['rank']}, Maske {$lora_state['mask']}.\n");
        }
        echo "  > [LoRA] Adapter aus " . basename($lora_in) . " fortgesetzt "
           . "(adam_t={$lora_state['adam_t']}).\n";
    } else {
        echo "  > [LoRA] Neue Adapter angelegt (keine Datei " . basename($lora_in) . ").\n";
    }
    printf("  > [LoRA] Rang %d, Maske %d, Basis %s, %s trainierbare Parameter, Basis-Optimierer %s.\n",
           $cortex->lora_rank(), $cortex->lora_mask(),
           $cortex->lora_base_frozen() ? 'EINGEFROREN' : 'wird mittrainiert',
           number_format($cortex->lora_params()),
           $cortex->lora_base_opt_freed()
               ? ($lora_preload ? 'gar nicht erst angelegt' : 'freigegeben')
               : 'vorhanden');
}

// --- 3a-ter. ARM C: nur die letzten n Schichten trainieren ---
// LoRA-Armvergleich, "nur letzte Schicht trainieren" - die billige
// Baseline, die LoRA schlagen muss. Geschaltet ueber SNAI_TRAIN_LAST_LAYERS.
// Default AUS: ohne die Variable verhaelt sich der Worker exakt wie bisher.
//
//   SNAI_TRAIN_LAST_LAYERS=1   nur die letzte Transformer-Schicht
//
// Eingefroren ist damit alles ausser den sechs Gewichtsmatrizen dieser
// Schichten - auch Embeddings, w_out, rms_final und alle RMSNorm-Gains. Das ist
// dieselbe Tensor-Menge, die LoRA ueber seine Slots adressiert.
$train_last_raw = trim((string)getenv('SNAI_TRAIN_LAST_LAYERS'));
if ($train_last_raw !== '') {
    $train_last = (int)$train_last_raw;
    if (!$is_int8) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": SNAI_TRAIN_LAST_LAYERS gesetzt, "
          . "aber dtype=$dtype ist nicht INT8. Die Maske haengt an den INT8-Gewichten - "
          . "lieber abbrechen als still den Vollpfad fahren und es Arm C nennen.\n");
    }
    if ($lora_active) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": SNAI_TRAIN_LAST_LAYERS und SNAI_LORA_RANK "
          . "zugleich gesetzt. Das sind zwei verschiedene Arme des Messaufbaus; "
          . "welcher gemeint ist, muss der Aufrufer entscheiden, nicht dieses Skript.\n");
    }
    $params_full = $cortex->count_trainable();     // vor dem Setzen, als Bezugsgroesse
    try {
        $cortex->set_train_last_layers($train_last);
    } catch (RuntimeException $e) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": " . $e->getMessage() . "\n");
    }
    // WIRKUNG abfragen, nicht den Wunsch - gleiche Linie wie bei LoRA und Tying.
    // Ein Schalter, der gesetzt ist, muss nicht wirken (Befund 2026-08-25).
    $eff = $cortex->get_train_last_layers();
    if ($eff !== $train_last) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": Arm-C-Maske angefordert ($train_last), "
          . "Engine meldet $eff.\n");
    }
    $params_armc = $cortex->count_trainable();
    if ($params_armc >= $params_full) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": Arm-C-Maske aendert die Zahl der "
          . "trainierbaren Parameter nicht ($params_armc von $params_full) - "
          . "sie wirkt also nicht.\n");
    }
    printf("  > [Arm C] Nur die letzten %d Schicht(en) trainierbar: %s statt %s Parameter (%.1f %%).\n",
           $eff, number_format($params_armc), number_format($params_full),
           100.0 * $params_armc / max(1, $params_full));
}

// --- 3a-bis. FULL-INT8: Rechenkern-Schalter setzen ---
// Muessen NACH der Quantisierung stehen (vorher gibt es keinen INT8-State) und
// gelten fuer diesen Prozess. Der gebuendelte Pfad ist Pflicht: der
// Ganzzahl-Backward und die quantisierten Aktivierungen sind nur dort
// umgesetzt (der Einzelpfad scheitert sonst laut, siehe cortex.nim).
if ($int8_full && $is_int8) {
    $cortex->set_batched_i8(1);
    $cortex->set_i8_int_backward(1);
    $cortex->set_i8_int_gradacc(1);
    $cortex->set_i8_quant_adam(1);
    // 2026-10-13: Ganzzahl-Rueckwaerts und Gradienten-Akkumulation auf der Karte (OpenCL oder CUDA).
    // Vorgabe AUS wie im Kern. Nur wirksam, wenn die GPU fuer dieses Modell ueberhaupt aktiv wird.
    if (in_array(trim((string)getenv('SNAI_I8_GPU_BACKWARD')), ['1','ja','yes','true'], true)) {
        $cortex->set_i8_gpu_backward(1);
        echo "  > [FULL-INT8] Ganzzahl-Rueckwaerts auf der Karte EIN (SNAI_I8_GPU_BACKWARD).\n";
    }
    // Die Tabelle setzt act_ffn_in als int8 voraus - und NUR das. Bis 2026-08-25
    // stand hier zusaetzlich `&& !$base_already_int8`, womit sie nur im ersten
    // Segment griff: ab Segment 1 rechnete der FFN-Forward eine andere Mathematik
    // (SiLU auf dem Float-Wert statt auf dem quantisierten Eingang). Das war ein
    // Ueberbleibsel aus der Zeit vor dem Fortsetzungs-Umbau (PUNKT 3, s.o.) - die
    // Bedingung wurde damals nicht mitgezogen. Gemessen von
    // diagnose/probe_silu_lut_switch.php: das Umschalten an der Grenze kostet
    // +0,0015 (nichts), der Guard erklaert den Segmentsprung also NICHT. Weg
    // kommt er, weil er das falsche Merkmal prueft, nicht weil er teuer waere.
    $silu_lut_on = 0;
    if ($int8_full_mem && $cortex->get_quant_acts_in_memory()) {
        $cortex->set_i8_silu_lut(1);
        $silu_lut_on = 1;
    }
    printf("  > [FULL-INT8] Ganzzahl-Stack aktiv (Backward, Gradienten, Adam%s).\n",
        $int8_full_mem ? ", Speicherumbau" : "");
    if ($int8_full_mem) {
        printf("  > [FULL-INT8] Momente quantisiert: %d | FFN-Aktivierungen: %d/%d | SiLU-Tabelle: %d\n",
            $cortex->get_quant_adam_memory(),
            $cortex->get_quant_acts_memory(), $cortex->get_quant_acts_in_memory(),
            $silu_lut_on);
    }
}

// --- 3b. Net2Net-Wachstumsgrenze aufloesen (LR-Boost fuer frische Parameter) ---
// Sidecar existiert nur, wenn $base_model aus einer Expansion in dieser
// Synthese-Session stammt (siehe growth_config.php) - sonst kein Boost,
// identisch zum bisherigen Verhalten.
$growth = resolve_growth_boundary($base_model);
if ($growth !== null && method_exists($cortex, 'set_growth_boundary')) {
    [$g_old_dim, $g_old_ffn, $g_old_layers] = $growth;
    $cortex->set_growth_boundary($g_old_dim, $g_old_ffn, $g_old_layers, GROWTH_LR_BOOST);
    echo "  > [Growth] Net2Net-Grenze erkannt (alt: dim=$g_old_dim, ffn=$g_old_ffn, layers=$g_old_layers) -> LR-Boost " . GROWTH_LR_BOOST . "x fuer frische Parameter aktiv.\n";
}

// --- 3c. Regularisierung (Weight-Decay/Dropout), nur falls explizit > 0 ---
if ($weight_decay > 0.0 && method_exists($cortex, 'set_weight_decay')) {
    $cortex->set_weight_decay($weight_decay);
    echo "  > [Regularisierung] AdamW-Weight-Decay aktiv: $weight_decay\n";
}
// Weight-Decay auf den Embeddings und der Ausgabematrix w_out (bei Bindung dieselbe Matrix): STANDARDMAESSIG AN.
// SNAI_WD_EMBEDDINGS=0 schaltet ihn dort ab, alle anderen Matrizen behalten global_weight_decay.
// Verlauf: 2026-10-16 Vorgabe AUS (Decay + int8-Training laesst die Embedding-Zeilen verkuemmern);
// 2026-10-17 zurueck auf AN (ohne Decay zerfaellt das Training in langen Laeufen ab Genesis, LANG64).
// 2026-10-18: Der Schalter wirkt nur im int8-Adam (applyGlobalAdamUpdateI8); der FP32-Adam nimmt global_weight_decay
// fuer alle Matrizen. Vorher meldete das Log bei FP32 "AUS", obwohl der Decay weiterlief, und bei Weight-Decay 0 "AN",
// obwohl es gar keinen Decay gab. Gleiches Muster wie SNAI_TIE_EMBEDDINGS/SNAI_INT8_FULL: ohne int8 "ignoriert".
$wd_emb_an = trim((string)getenv('SNAI_WD_EMBEDDINGS')) !== '0';
if (!$is_int8) {
    if (!$wd_emb_an) {
        fwrite(STDERR, "⚠️  [Regularisierung] SNAI_WD_EMBEDDINGS=0 gesetzt, aber dtype=$dtype ist nicht INT8 - ignoriert "
            . "(FP32 nimmt den globalen Weight-Decay fuer alle Matrizen).\n");
    }
} else {
    $ok = $cortex->set_wd_embeddings($wd_emb_an);
    // exit(1) statt die(): die() endet mit Exitcode 0 (Fehlersuche 2026-10-16, Befund A3).
    if ($ok === null) { fwrite(STDERR, "🚨 libcortex.so kennt cortex_set_wd_embeddings nicht - Bibliothek zu alt.\n"); exit(1); }
    if ($ok !== true) { fwrite(STDERR, "🚨 Schalter fuer Weight-Decay auf den Embeddings meldet keine Wirkung.\n"); exit(1); }
    if (!($weight_decay > 0.0)) {
        echo "  > [Regularisierung] Weight-Decay ist aus (0) - der Schalter fuer die Embeddings ("
           . ($wd_emb_an ? "an" : "aus") . ") hat nichts zu tun.\n";
    } else {
        echo $wd_emb_an ? "  > [Regularisierung] Weight-Decay auf den Embeddings AN (Vorgabe).\n"
                        : "  > [Regularisierung] Weight-Decay auf den Embeddings AUS (SNAI_WD_EMBEDDINGS=0; ungebunden auch w_out).\n";
    }
}
if ($dropout_rate > 0.0 && method_exists($cortex, 'set_dropout_rate')) {
    $cortex->set_dropout_rate($dropout_rate);
    echo "  > [Regularisierung] FFN-Dropout aktiv: $dropout_rate\n";
}
if ($label_smoothing > 0.0 && method_exists($cortex, 'set_label_smoothing')) {
    $cortex->set_label_smoothing($label_smoothing);
    echo "  > [Regularisierung] Label-Smoothing aktiv: $label_smoothing\n";
}

// --- 4. ⚡ PHASE VI: OpenCL JIT (Schwelle einstellbar seit 2026-09-03) ---
//
// Die Schwelle lag fest verdrahtet bei dim >= 512, ohne jede Abschaltung. Fuer
// jede Geometrie unterhalb davon war das folgenlos; ab dim 512 war es ein
// Zwang. Gemessen am 2026-09-03 auf der Renoir-iGPU dieses Laptops
// (diagnose/bench_dim512_cpu_vs_gpu.php, echte dim-512/L6-Geometrie,
// 40 Schritte je Pfad):
//
//     CPU     2118,3 ms/Schritt   121 Token/s
//     OpenCL  3406,5 ms/Schritt    75 Token/s   -> Faktor 0,62x
//
// Die GPU ist hier also 38 % LANGSAMER. Auf einen 44-Tage-Vortrainingslauf
// gerechnet waeren das rund 27 verlorene Tage - erzwungen von einer Zeile,
// die man nicht abschalten konnte. (Die aeltere Phase-8-Messung wies 0,85x
// aus; die Lage hat sich seither verschlechtert, nicht verbessert.)
//
// Ein Teil des Grundes steckt in der Elementschwelle des Dispatchers: sie
// liegt bei 1.000.000, und bei dim 512 fallen die Attention-Matrizen
// (512x512 = 262.144) darunter. Nur die FFN-Matrizen gehen ueberhaupt auf die
// GPU - der Lauf zahlt Kopierkosten fuer einen Teil der Arbeit.
//
// Zwei Schalter, beide bewusst ausdruecklich:
//   SNAI_FORCE_CPU=1     schaltet die GPU ab, unabhaengig von der Dimension.
//   SNAI_GPU_MIN_DIM=<n> verschiebt die Schwelle (Vorgabe 512, also das
//                        bisherige Verhalten bei ungesetzter Variable).
//
// Der gewaehlte Weg wird protokolliert. Bei einem Lauf ueber Wochen muss im
// Log nachlesbar sein, WARUM er auf der CPU lief - sonst ist die Frage
// "hat der Schalter gegriffen?" nach vier Wochen nicht mehr beantwortbar.
$force_cpu   = in_array(trim((string)getenv('SNAI_FORCE_CPU')), ['1','ja','yes','true'], true);
$gpu_min_raw = trim((string)getenv('SNAI_GPU_MIN_DIM'));
$gpu_min_dim = ($gpu_min_raw !== '' && is_numeric($gpu_min_raw)) ? (int)$gpu_min_raw : 512;

if ($force_cpu) {
    echo "  > [CPU] SNAI_FORCE_CPU=1 gesetzt - GPU bleibt aus (Modell hat {$model_dim} Dim).\n";
} elseif (method_exists($cortex, 'init_gpu') && $model_dim >= $gpu_min_dim) {
    echo "  > [VRAM] Modell hat {$model_dim} Dim (>= {$gpu_min_dim}). Aktiviere GPU-Beschleunigung...\n";
    $cortex->init_gpu();
} else {
    // AUDIT-FIX: Meldung sagte "(< 256)", die tatsaechliche Schwelle war 512 -
    // Copy-Paste-Rest einer alten Version, hat nichts mit der Gate-Logik zu tun.
    echo "  > [CPU] Modell hat {$model_dim} Dim (< {$gpu_min_dim}). Bleibe auf CPU (PCIe-Overhead Schutz)...\n";
}

// Update 2026-08-09 (Nachruest-Paket #8 "Backend-/Hardware-
// Telemetrie"): parsebare Zeile fuer train_cluster.php, unabhaengig davon, ob
// oben ueberhaupt init_gpu() gerufen wurde (dann bleibt es beim Default 0/NONE).
if (method_exists($cortex, 'get_gpu_backend')) {
    $backend_names = [0 => 'NONE', 1 => 'OPENCL', 2 => 'CUDA'];
    $backend_id = $cortex->get_gpu_backend();
    echo "GPU_BACKEND=" . ($backend_names[$backend_id] ?? 'UNKNOWN') . "\n";
}


$ctx = property_exists($cortex, 'ctx_size') ? $cortex->ctx_size : 512;
if ($ctx <= 0) worker_abbruch("🚨 Fatal: Ungültige ctx_size ($ctx) vom Cortex gemeldet!\n");

// HINWEIS: $initial_lr ist die vom Master vorgegebene, bereits decay'te Rate für DIESE Epoche!
$initial_lr = $custom_lr; 
$global_step = 0;

for ($e = 1; $e <= $epochs; $e++) {
    $loss_sum = 0;
    $steps = 0;
    // Update 2026-08-09: rollierender Puffer der letzten
    // RECENT_LOSS_WINDOW Einzelschritt-Losses - siehe RECENT_LOSS= am Ende der
    // Mini-Batch-Schleife unten. Pro Epoche zurueckgesetzt (kein
    // epochenuebergreifender Puffer), damit der Wert immer den Endstand
    // GENAU DIESER Epoche zeigt.
    $recent_losses = [];

    // AUDIT-FIX ("Batch-Shuffling zwischen Epochen"): die
    // Chunk-Datei wird jetzt einmalig komplett gelesen und am Stueck
    // tokenisiert statt in 1-MB-Leseputtern - dadurch entfaellt der bisherige
    // Whitespace-/UTF-8-Notfall-Cut an Pufferrgrenzen (unnoetig, sobald keine
    // Puffergrenzen mehr existieren) UND es steht die vollstaendige
    // Fenster-Liste vor dem ersten Trainingsschritt fest, sodass ihre
    // Reihenfolge gemischt werden kann. Chunk-Dateien sind bereits von
    // train_cluster.php pro Worker vorab aufgeteilt (typischerweise
    // niedrige einstellige MB) - unproblematisch fuer den 2048M-Limit oben.
    $full_text = file_get_contents($input_file);
    if ($full_text === false) {
        worker_abbruch("🚨 Fatal: Konnte Input-File nicht lesen: $input_file\n");
    }

    if (strlen(trim($full_text)) >= 2) {
        $tokens = $tokenizer->encode($full_text);
        unset($full_text);
        $total_tokens = count($tokens);
        $batch_size = $ctx;

        // Loss-Masking: Rollen-Scan ueber den kompletten Token-Stream, EINMAL
        // pro Chunk statt pro Fenster. Default true (trainierbar) - GEN-Chunks
        // ohne [USER]/[SYMBIO]-Marker bleiben dadurch automatisch komplett
        // trainierbar, keine Sonderbehandlung nach Tier noetig. Das Marker-
        // Token selbst bekommt die NEUE Rolle (der Rollenwechsel ist selbst
        // ein lernbares Signal).
        $role = [];
        $current_role = true;
        foreach ($tokens as $idx => $tok) {
            if ($tok === $user_token_id) $current_role = false;
            elseif ($tok === $symbio_token_id) $current_role = true;
            $role[$idx] = $current_role;
        }

        // Fenster-Startpositionen (0, ctx, 2*ctx, ...) sammeln, dann
        // deterministisch pro (globaler Epoche, interner Epoche, Chunk-Datei)
        // mischen - deterministisch statt echt zufaellig, damit ein Neustart
        // mit demselben global_epoch dieselbe Reihenfolge reproduziert (es
        // gibt keinen Intra-Epochen-Fortschritts-State, ein Neustart
        // wiederholt die Epoche ohnehin komplett).
        $offsets = snai_window_offsets($total_tokens, $batch_size);

        // Update 2026-09-04: die Schrittzahl dieser Epoche steht hier bereits
        // fest - der Chunk ist tokenisiert, die Fensterliste vollstaendig. Sie
        // erst im Nachhinein aus "Step 5315"-Zeilen abzulesen (oder aus der
        // Dateigroesse zu schaetzen) war unnoetig: als parsebare Zeile kostet
        // sie nichts und train_cluster.php macht daraus den Segment-Plan.
        // Muster wie GPU_BACKEND=/RECENT_LOSS= oben.
        echo "PLAN_STEPS=" . count($offsets) . " PLAN_TOKENS=$total_tokens PLAN_CTX=$batch_size\n";

        mt_srand(crc32($global_epoch . ':' . $e . ':' . $input_file));
        shuffle($offsets);

        // === MINI-BATCH SCHLEIFE (VETO-FIX: Array Slice GC-Shredder behoben) ===
        foreach ($offsets as $i) {
            // AUDIT-FIX: Vorher wurde erst ein voller Batch geschnitten und dann
            // per "$i + $actual_len >= $total_tokens" abgebrochen. Bei
            // $total_tokens <= $batch_size galt das schon im ERSTEN Durchlauf
            // (0 + total >= total) -> null Trainingsschritte, das Modell wurde
            // trotzdem als fertiger Experte gespeichert. Zusaetzlich fiel bei
            // langen Texten immer der letzte Teil-Batch unter den Tisch.
            //
            // Jetzt wird die Laenge vorab begrenzt: fuer ein Paar (in, out) mit
            // out = in um 1 verschoben stehen ab Position $i genau
            // ($total_tokens - 1 - $i) Tokens zur Verfuegung.
            $actual_len = min($batch_size, $total_tokens - 1 - $i);
            if ($actual_len < 1) continue;

            $batch_in  = array_slice($tokens, $i, $actual_len);
            $batch_out = array_slice($tokens, $i + 1, $actual_len);
            // Maske beschreibt die Rolle des ZIEL-Tokens ($batch_out), nicht
            // des Input-Tokens - genau das wird vorhergesagt und soll bei
            // [USER]-Text nicht in den Loss/Gradienten einfliessen.
            $batch_mask = array_slice($role, $i + 1, $actual_len);

            $global_step++;
            $current_lr = $initial_lr;
            {
                if ($warmup_t0 === null) {
                    $warmup_t0 = (int)$cortex->get_adam_t();
                    if ($warmup_steps > 0) echo "  > [Warmup] $warmup_steps Schritte, Start bei adam_t=$warmup_t0, Ziel-LR $initial_lr\n";
                    if ($lr_decay_steps > 0) echo "  > [LR-Decay] Cosinus ab adam_t=$lr_decay_start bis adam_t=$lr_decay_steps, Boden " . sprintf('%.7f', $initial_lr * $lr_min_ratio) . ", Start bei adam_t=$warmup_t0\n";
                }
                $warmup_n++;
                $warmup_t = $warmup_t0 + $warmup_n;
                if ($warmup_t < $warmup_steps) {
                    $current_lr = $initial_lr * $warmup_t / $warmup_steps;
                } elseif ($lr_decay_steps > $warmup_steps) {
                    $lr_progress = min(1.0, max(0.0, ($warmup_t - $lr_decay_start) / ($lr_decay_steps - $lr_decay_start)));
                    $current_lr = $initial_lr * ($lr_min_ratio + (1.0 - $lr_min_ratio) * 0.5 * (1.0 + cos(M_PI * $lr_progress)));
                }
                if ($warmup_steps > 0 && ($warmup_n === 1 || $warmup_t === $warmup_steps)) {
                    echo "  > [Warmup] adam_t=$warmup_t LR=" . sprintf('%.7f', $current_lr) . "\n";
                }
                if ($lr_decay_steps > 0 && ($warmup_n === 1 || $warmup_t === $lr_decay_start || $warmup_t === $lr_decay_steps)) {
                    echo "  > [LR-Decay] adam_t=$warmup_t LR=" . sprintf('%.7f', $current_lr) . "\n";
                }
            }

            // Bounds Check
            $max_id = max($batch_in);
            $min_id = min($batch_in);
            if ($min_id < 0 || $max_id >= $vocab_limit) {
                echo "🚨 [Worker Debug] ILLEGALE TOKENS! Min: $min_id, Max: $max_id (Limit: $vocab_limit)\n";
                exit(1);
            }

            // Inferenz / Training in der C-Engine
            if ($is_int8) {
                $loss = $cortex->train_step_i8($batch_in, $batch_out, $batch_mask, $current_lr);
                if ($loss === null) $loss = 0.001;
                // GATE-BEFUND (Phase 2, diagnose/gate_int8_vs_fp32.php): Re-Scaling
                // nach JEDEM Schritt noetig, sonst saettigen kleinskalige Zeilen
                // (v.a. w_out) dauerhaft auf +-128 und der Loss bleibt haengen.
                $cortex->rescale_weights_i8();
            } elseif (method_exists($cortex, 'train_step')) {
                $loss = $cortex->train_step($batch_in, $batch_out, $batch_mask, $current_lr);
                if ($loss === null) $loss = 0.001;
            } else {
                echo "⚠️ [Worker " . getmypid() . "] train_step() fehlt! Simuliere...\n";
                $loss = max(0.001, 0.99 * (1.0 / (($global_step * 0.01) + 1)));
            }

            // AUDIT-FIX: Off-by-one Logging Bug behoben
            if (is_nan($loss) || is_infinite($loss)) {
                $err_step = $steps + 1;
                echo "🚨 [Fatal] Worker " . getmypid() . " | Exploding Gradients (NaN) bei Step $err_step! Breche ab.\n";
                exit(1);
            }

            $loss_sum += $loss;
            $steps++;
            $recent_losses[] = $loss;

            if ($telemetry_steps > 0 && method_exists($cortex, 'get_last_grad_norm')) {
                $tm['n']++;
                // GradNorm ist auf die Clip-Schwelle normiert: > 1 heisst geclippt.
                if ($cortex->get_last_grad_norm() > 1.0) $tm['clip']++;
                if (method_exists($cortex, 'get_last_grad_share') && ($tm_sh0 = $cortex->get_last_grad_share(0)) !== null) {
                    $tm['ng']++;
                    $tm['grp'][0] += $tm_sh0;
                    for ($tm_g = 1; $tm_g < 5; $tm_g++) $tm['grp'][$tm_g] += (float)$cortex->get_last_grad_share($tm_g);
                    for ($tm_l = 0; ($tm_shl = $cortex->get_last_grad_share(100 + $tm_l)) !== null; $tm_l++) {
                        $tm['qk'][$tm_l] = ($tm['qk'][$tm_l] ?? 0.0) + $tm_shl;
                    }
                }
                if ($tm['n'] >= $telemetry_steps) $tm_flush($warmup_t, $current_lr);
            }
            if ($is_int8 && in_array($warmup_t, $snapshot_steps, true)) {
                // Ein gescheiterter Zwischenstand (Platte voll, eingefrorene
                // LoRA-Basis ohne Optimierer-Zustand) darf das Training nicht
                // beenden: melden und weiterlaufen.
                $snap_file = dirname($output_file) . '/snap_' . basename($output_file, '.snai') . "_t$warmup_t.snai";
                try {
                    // RAM-AUFRAEUMEN 2026-10-15: direkt aus Nim, alter PHP-Weg nur ohne das Symbol.
                    $snap_ok = $cortex->save_stream_i8($snap_file . '.tmp');
                    if ($snap_ok === null) $snap_ok = save_model_stream_i8($cortex->extract_state_i8(), $snap_file . '.tmp');
                    if (!$snap_ok) throw new RuntimeException("Schreiben gescheitert");
                    // save_model_stream_i8() prueft seine fwrite()-Aufrufe nicht: bei
                    // voller Platte entstuende eine abgeschnittene Datei. Bytebilanz
                    // gegen die Geometrie halten, bevor der Stand seinen Namen bekommt.
                    clearstatcache(true, $snap_file . '.tmp');
                    $snap_hdr = load_model_header_any($snap_file . '.tmp');
                    $snap_soll = $snap_hdr ? snai_v6_expected_sizes($snap_hdr['vocab_size'], $snap_hdr['hidden_dim'], $snap_hdr['ffn_dim'], $snap_hdr['num_layers'], $snap_hdr['flags'] ?? 0, $snap_hdr['magic'])[1] : -1;
                    if (filesize($snap_file . '.tmp') !== $snap_soll) throw new RuntimeException("Datei hat " . filesize($snap_file . '.tmp') . " statt $snap_soll Bytes");
                    if (!rename($snap_file . '.tmp', $snap_file)) throw new RuntimeException("rename gescheitert");
                    write_num_heads($snap_file, $num_heads);
                    echo "  > [Zwischenstand] adam_t=$warmup_t -> $snap_file\n";
                } catch (\Throwable $snap_err) {
                    // NICHT $e: das ist der Epochenzaehler der umgebenden Schleife.
                    @unlink($snap_file . '.tmp');
                    echo "  > ⚠️ [Zwischenstand] adam_t=$warmup_t NICHT geschrieben: " . $snap_err->getMessage() . "\n";
                }
            }

            if ($steps <= 5 || $steps % 5 === 0) {
                // Update 2026-08-09 (Nachruest-Paket #9
                // "Gradient-Norm-Logging"): GradNorm haengt an dieselbe Zeile wie
                // Avg Loss an - die bestehende "Avg Loss:"-Regex in
                // train_cluster.php bleibt dadurch unveraendert gueltig, ein
                // neuer Regex greift zusaetzlich das Feld danach ab.
                // AUDIT-FIX (2026-08-09): number_format() ohne
                // explizite Trenner-Argumente setzt ab 1000 ein Tausender-Komma
                // (z.B. "1,042.7545") - der Parse-Regex in train_cluster.php
                // ([0-9.]+) brach dort ab und lieferte nur "1" statt des echten
                // Werts. GradNorm liegt in der Praxis oft > 1000. Explizit ohne
                // Trenner formatieren, wie $active_lr in train_cluster.php.
                $grad_norm_str = method_exists($cortex, 'get_last_grad_norm')
                    ? number_format($cortex->get_last_grad_norm(), 4, '.', '')
                    : 'n/a';
                echo "Worker " . str_pad((string)getmypid(), 5, " ", STR_PAD_LEFT) . " | Epoch $global_epoch | Step " . str_pad((string)$steps, 3, " ", STR_PAD_LEFT) . " | Avg Loss: " . number_format($loss_sum / $steps, 6) . " | GradNorm: $grad_norm_str\n";
            }

            // GC explizit entlasten
            unset($batch_in, $batch_out);
        }

        // Update 2026-08-09: Loss der letzten
        // RECENT_LOSS_WINDOW Schritte statt des Epochendurchschnitts -
        // $loss_sum/$steps (siehe "Avg Loss" oben) ist ueber die GANZE Epoche
        // gemittelt, verwaesert also von den anfangs noch schlechteren
        // Schritten. Fuer einen direkten Vergleich mit dem Held-out-Loss
        // (der immer den FERTIGEN Epochenstand misst) ist dieser Wert die
        // passendere Grundlage. Eigene KEY=VALUE-Zeile (Muster wie
        // GPU_BACKEND= oben), garantiert am tatsaechlichen Ende der
        // Mini-Batch-Schleife berechnet - unabhaengig davon, ob der letzte
        // Schritt zufaellig auf eine "Step % 5 === 0"-Log-Zeile fiel.
        if (count($recent_losses) > 0) {
            $recent_window = array_slice($recent_losses, -RECENT_LOSS_WINDOW);
            $recent_avg = array_sum($recent_window) / count($recent_window);
            echo "RECENT_LOSS=" . number_format($recent_avg, 6, '.', '') . " RECENT_LOSS_N=" . count($recent_window) . "\n";
        }
        // Gegenstueck zu PLAN_STEPS= oben: was TATSAECHLICH gelaufen ist. Ein
        // Plan, den niemand gegen die Ausfuehrung haelt, ist eine Behauptung -
        // dieselbe Lehre wie bei cortex_i8_error_feedback_active() (2026-08-25):
        // wo Ansage und Wirkung auseinanderfallen koennen, gehoert die Wirkung
        // abgefragt. train_cluster.php vergleicht beide und meldet Abweichungen.
        if ($steps > 0) $tm_flush($warmup_t, $current_lr);
        echo "STEPS_DONE=$steps\n";
        unset($tokens, $offsets, $recent_losses);
    }
}

// AUDIT-FIX: Ohne einen einzigen Schritt waere das Ergebnis eine unveraenderte
// Kopie des Basismodells - die Pipeline hat solche Klone bisher als vollwertige
// Experten verbucht (Loss-Platzhalter 999). Lieber laut scheitern.
if ($global_step === 0) {
    echo "🚨 [Fatal] Worker " . getmypid() . ": kein einziger Trainingsschritt ausgefuehrt.\n";
    echo "  > Der Chunk enthaelt zu wenige Tokens (mindestens 2 noetig).\n";
    exit(1);
}

echo "  > [Worker " . getmypid() . "] Training abgeschlossen. Extrahiere aktualisierte Gewichte...\n";

// ============================================================================
// LoRA mit eingefrorener Basis: die Basis wird KOPIERT, nicht neu geschrieben.
// ----------------------------------------------------------------------------
// Drei Gruende, und der dritte ist der wichtigste:
//  1. Sie hat sich nachweislich nicht veraendert - neu serialisieren waere
//     Arbeit fuer ein Ergebnis, das schon auf der Platte liegt.
//  2. Der RAM-Spike der Extraktion (bei echten Modellgroessen das Doppelte der
//     Gewichte) faellt weg. Das ist Teil des Speicherarms.
//  3. Seit dem Freigeben des Basis-Optimierers waere die Extraktion sogar
//     FALSCH: cortex_extract_adam_layer() liefert dann Nullen, und die
//     geschriebene Datei haette ein geloeschtes Adam-Gedaechtnis - vollstaendig
//     aussehend, still kaputt. extract_state_i8() verweigert deshalb den Dienst;
//     hier ist der richtige Weg.
if ($lora_active && $cortex->lora_base_opt_freed()) {
    // BEFUND 2026-08-30 (beim Aufsetzen von Arm D gefunden, bevor er lief):
    // Kopiert wird die BASISDATEI. Ist das Modell im Speicher gebunden, die
    // Datei aber ein ungebundenes SNAI_V6, dann schreibt dieser Zweig die
    // Bindung still weg - das Artefakt ist V6, die Adapter sind aber gegen
    // einen GEBUNDENEN Forward trainiert. Der Basis-Fingerabdruck schlaegt
    // nicht an, weil er genau auf diese Datei zeigt; die spaetere Auswertung
    // misst also ein Modell, das im Training nie existiert hat.
    // Richtiger Weg fuer Arm D: eine echte V7-Basisdatei vorbauen und die als
    // $base_model uebergeben (Arm D).
    if ($cortex->tied_embeddings_active() && $base_model_magic !== SNAI_MAGIC_V7) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": Weight Tying ist aktiv, die Basisdatei "
          . "ist aber $base_model_magic. Der Kopier-Kurzschluss wuerde ein UNGEBUNDENES "
          . "Artefakt schreiben, waehrend die Adapter gegen einen gebundenen Forward "
          . "trainiert wurden - plausibel und falsch. Eine echte V7-Basis uebergeben.\n");
    }
    // EMB-EINGANG / FFN-AUS: hier eingeschaltet heisst, die Basisdatei traegt es NICHT - die Kopie verloere es.
    if ($emb_neu || $ffn_neu) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": Embedding-Eingangsfaktor oder FFN-AUS wurde in diesem "
          . "Arbeiter eingeschaltet, der Kopier-Kurzschluss schriebe aber die unveraenderte Basis.\n");
    }
    if (!copy($base_model, $output_file)) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": Basismodell liess sich nicht nach $output_file kopieren.\n");
    }
    if (md5_file($base_model) !== md5_file($output_file)) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": Kopie der Basis stimmt nicht mit dem Original ueberein.\n");
    }
    write_num_heads($output_file, $num_heads);
    echo "  > ✅ [LoRA] Basis unveraendert uebernommen (kopiert statt neu serialisiert).\n";

    $lora_state_out = $cortex->extract_lora_state(true);
    if ($lora_state_out === null) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": extract_lora_state() lieferte nichts - "
          . "das Ergebnis der Epoche waere verloren.\n");
    }
    $lora_out = snai_lora_path($output_file);
    if (!save_lora_stream($lora_state_out, $lora_out, $base_model)) {
        worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": Adapterdatei $lora_out nicht schreibbar.\n");
    }
    printf("  > ✅ [LoRA] Adapter gesichert unter %s (%s Bytes, %.1f%% der Modellgroesse)\n",
           $lora_out, number_format(filesize($lora_out)),
           100.0 * filesize($lora_out) / max(1, filesize($output_file)));
    exit(0);
}

// RAM-AUFRAEUMEN 2026-10-15 (Doku 6ao): int8 schreibt Nim direkt, Tensor fuer Tensor. Der alte Weg (ganzer Zustand
// als PHP-Array, dann save_model_stream_i8) war die RAM-Spitze am Ende jedes Segments; er bleibt nur fuer FP32 und
// fuer eine alte libcortex.so ohne cortex_save_stream_i8 (dann mit Warnzeile).
$nim_save = $is_int8 ? $cortex->save_stream_i8($output_file) : null;
if ($nim_save === false) {
    worker_abbruch("🚨 [Worker " . getmypid() . "] FATAL: cortex_save_stream_i8() konnte $output_file nicht vollstaendig schreiben!\n");
}
if ($nim_save === null) {
    if ($is_int8) {
        $state_array = $cortex->extract_state_i8();
    } elseif (method_exists($cortex, 'extract_state')) {
        $state_array = $cortex->extract_state();
    } else {
        worker_abbruch("🚨 [Worker " . getmypid() . "] FATAL: Konnte Gewichte nicht aus C-RAM extrahieren (Methode fehlt)!\n");
    }
    if ($state_array === false || $state_array === null) {
        worker_abbruch("🚨 [Worker " . getmypid() . "] FATAL: extract_state" . ($is_int8 ? "_i8" : "") . "() lieferte ungültiges Ergebnis!\n");
    }
}

try {
    if ($nim_save === true) {
        // schon geschrieben (cortex_save_stream_i8)
    } elseif ($is_int8) {
        if (!function_exists('save_model_stream_i8')) {
            worker_abbruch("🚨 Fatal: 'save_model_stream_i8' nicht in tensor_io.php gefunden!\n");
        }
        save_model_stream_i8($state_array, $output_file);
    } else {
        if (!function_exists('save_model_stream')) {
            worker_abbruch("🚨 Fatal: 'save_model_stream' nicht in tensor_io.php gefunden!\n");
        }
        save_model_stream($state_array, $output_file);
    }
    // Head-Zahl fuer den NAECHSTEN Ladevorgang festschreiben, damit sie nie
    // wieder aus $model_dim neu geraten werden kann/muss.
    write_num_heads($output_file, $num_heads);
    // EMB-EINGANG: WIRKUNG in der Datei pruefen - rechnet die Engine mit Faktor, muss Bit 1 im Header stehen.
    if ($is_int8 && $cortex->emb_eingang_aktiv() === true) {
        $emb_hdr = load_model_header_any($output_file);
        if (!$emb_hdr || !snai_emb_eingang($emb_hdr)) {
            worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": $output_file traegt Bit 1 (Embedding-Eingangsfaktor) nicht, "
              . "obwohl die Engine mit Faktor trainiert hat.\n");
        }
    }
    echo "  > ✅ [Erfolg] Arbeiter-Gewichte via Stream gesichert unter $output_file\n";

    // LoRA: die Adapter kommen in eine eigene Datei NEBEN das Modell.
    //
    // Der Fingerabdruck zeigt auf $base_model, NICHT auf $output_file. Das war
    // beim ersten Cluster-Lauf der Unterschied zwischen "laeuft" und "bricht
    // ab": jeder Arbeiter schreibt eine eigene Ausgabedatei, die sich schon
    // im adam_t unterscheidet - gegen die eigene Ausgabe gestempelt haetten
    // zwei Arbeiter desselben Laufs verschiedene Fingerabdruecke, und der
    // Merge haette sie zu Recht als "aus verschiedenen Laeufen" abgelehnt.
    // Der Bezugspunkt eines Adapters ist die Basis, GEGEN die er trainiert
    // wurde. Der verschmolzene Adapter wird danach im Cluster auf die
    // verschmolzene Basis umgestempelt (snai_lora_restamp_base()).
    //
    // Scheitert das Schreiben, ist die ganze Epoche verloren - bei
    // eingefrorener Basis steckt das gesamte Ergebnis in dieser Datei.
    // Deshalb ein harter Abbruch und keine Warnung.
    if ($lora_active) {
        $lora_state_out = $cortex->extract_lora_state(true);
        if ($lora_state_out === null) {
            worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": extract_lora_state() lieferte nichts - "
              . "das Modell waere ohne seine Adaption gespeichert.\n");
        }
        $lora_out = snai_lora_path($output_file);
        if (!save_lora_stream($lora_state_out, $lora_out, $base_model)) {
            worker_abbruch("🚨 [Fatal] Worker " . getmypid() . ": Adapterdatei $lora_out nicht schreibbar.\n");
        }
        printf("  > ✅ [LoRA] Adapter gesichert unter %s (%s Bytes, %.1f%% der Modellgroesse)\n",
               $lora_out, number_format(filesize($lora_out)),
               100.0 * filesize($lora_out) / max(1, filesize($output_file)));
    }
} catch (Exception $e) {
    worker_abbruch("🚨 Fatal: Fehlschlag beim Speichern des Modells: " . $e->getMessage() . "\n");
}

exit(0);