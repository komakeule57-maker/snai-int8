<?php
// Dateiname: eval_held_out_full_i8.php
// Funktion: INT8-Pendant zu eval_held_out_full.php - vollstaendiger nativer
// INT8-Forward-Pass-Loss ueber den GESAMTEN Held-out-Korpus, zerlegt in
// nicht-ueberlappende Fenster von ctx_size Token.
//
// WARUM DIESES SKRIPT EXISTIERT (2026-08-29, snai_edge_int8_lora):
// eval_held_out_i8.php kappt den Korpus hart auf EIN Kontextfenster
// (dort Zeile 83/84: array_slice($tokens, 0, $cortex->ctx_size)). Ein
// $max_tokens oberhalb von ctx_size hat keinerlei Wirkung. Damit stammte
// JEDE INT8-Held-out-Zahl dieses Projekts bislang aus einem einzigen
// 1024-Token-Fenster. Fuer den Pro-Epoche-Indikator im Trainingslauf ist das
// bewusst so und voellig in Ordnung - billig sein ist dort der Zweck. Fuer
// einen A/B, dessen erwartete Unterschiede in Hundertsteln liegen, ist es zu
// wenig Aufloesung: ein einzelnes Fenster misst zu einem grossen Teil, wie
// schwer zufaellig gerade dieser Textabschnitt ist.
//
// Das FP32-Gegenstueck eval_held_out_full.php macht es richtig, versteht aber
// nur SNAI_V5. Dieses Skript schliesst die Luecke fuer SNAI_V6/V7.
//
// Bewusst ein SEPARATES Skript, kein Umbau von eval_held_out_i8.php: der
// guenstige Pro-Epoche-Pfad wird von train_cluster.php produktiv aufgerufen
// und bleibt unangetastet. Gleiche Begruendung wie damals bei
// eval_held_out_full.php gegenueber eval_held_out.php.
//
// Nutzung: php eval_held_out_full_i8.php <checkpoint.v6|v7> [holdout_dir] [num_heads] [max_windows]
//   <checkpoint>    SNAI_V6- oder SNAI_V7-Modell
//   [holdout_dir]   Default: ./factory/holdout/
//   [num_heads]     Default: automatisch ueber head_config.php
//   [max_windows]   0 = alle Fenster (Default). >0 kappt - und die Kappung
//                   wird IMMER berichtet, nie still angewendet.
//
// Ausgabe bei Erfolg, eine Zeile auf STDOUT:
//   HELDOUT_FULL_LOSS=<float> HELDOUT_FULL_PPL=<float|INF>
//   HELDOUT_FULL_TOKENS=<int> HELDOUT_FULL_WINDOWS=<int>
// Dasselbe Schluesselschema wie eval_held_out_full.php, damit auswertende
// Skripte nicht zwischen FP32 und INT8 unterscheiden muessen.
// Fortschritt auf STDERR. Bei jedem Fehler: STDERR, Exit-Code 1.
//
// Log: factory/checkpoints/heldout_full_i8_<session_id>.jsonl - eigener
// Dateiname, damit die Ein-Fenster-Zahlen aus heldout_i8_*.jsonl und die
// Voll-Korpus-Zahlen nie in derselben Reihe landen und versehentlich
// miteinander verglichen werden.
//
// Im Log steht zusaetzlich 'window_losses': der Loss JEDES Fensters einzeln.
// Das ist fuer den LoRA-A/B der eigentliche Gewinn: zwei Modelle Fenster fuer
// Fenster gepaart zu vergleichen ist deutlich empfindlicher als zwei
// Mittelwerte zu vergleichen, weil die Schwierigkeit der Fenster stark
// streut und sich in der Paarung herauskuerzt.

// SPEICHERGRENZE. Ohne diese Zeile gilt PHPs Default von 128 MB, und das
// reicht nicht: der Pruefsatz wird VOLLSTAENDIG tokenisiert, bevor die
// Fensterkappung greift. Beim Produktiv-Pruefsatz (8,4 MB, 2,5 Mio Token)
// starb der Auswerter am 2026-09-03 mitten in encode() - obwohl er von den
// Token nur 64 Fenster (65.536 Stueck) ueberhaupt benutzt.
//
// Bewusst nicht "nur so viel tokenisieren wie noetig" als Fix: die
// Fensterauswahl haengt an der vollstaendigen Tokenfolge, und ein
// vorzeitiger Abbruch der Tokenisierung wuerde die Fenstergrenzen
// verschieben - dann waeren die Kurven ueber die Segmente nicht mehr
// gepaart, und genau die Paarung ist der Grund fuer die feste Fensterzahl.
$_mem = getenv('SNAI_EVAL_MEM');
ini_set('memory_limit', ($_mem !== false && $_mem !== '') ? $_mem : '1024M');

date_default_timezone_set('Europe/Berlin');

chdir(__DIR__);
require_once 'snai_tokenizer.php';
require_once 'tensor_io.php';
require_once 'tensor_ffi_adapter.php';
require_once __DIR__ . '/head_config.php';

function heldout_full_i8_fail(string $msg): void {
    fwrite(STDERR, "🚨 [Held-out-Full-Eval-INT8] $msg\n");
    exit(1);
}

function heldout_full_i8_progress(string $msg): void {
    fwrite(STDERR, "  > [Held-out-Full-Eval-INT8] $msg\n");
}

if ($argc < 2) {
    heldout_full_i8_fail("Nutzung: php eval_held_out_full_i8.php <checkpoint.v6|v7> [holdout_dir] [num_heads] [max_windows]");
}

$start_time = microtime(true);

$checkpoint         = $argv[1];
$holdout_dir        = $argv[2] ?? './factory/holdout/';
// "", "-" und "auto" heissen ausdruecklich "automatisch aufloesen". Ohne diesen
// Platzhalter koennte man max_windows nicht setzen, ohne num_heads von Hand
// anzugeben - und genau das wuerde zum Raten einladen (siehe die Kopf-Falle
// weiter unten).
$heads_arg          = $argv[3] ?? null;
$num_heads_override = ($heads_arg === null || $heads_arg === '' || $heads_arg === '-' || $heads_arg === 'auto')
                      ? null : (int)$heads_arg;
$max_windows        = isset($argv[4]) ? max(0, (int)$argv[4]) : 0;

if (!file_exists($checkpoint)) {
    heldout_full_i8_fail("Checkpoint nicht gefunden: $checkpoint");
}

$header = load_model_header_any($checkpoint);
if (!$header) {
    heldout_full_i8_fail("Konnte Modell-Header nicht lesen: $checkpoint");
}
if (!snai_is_int8_magic($header['magic'])) {
    heldout_full_i8_fail(
        "Kein SNAI_V6/V7-Checkpoint (Magic: {$header['magic']}) - " .
        "fuer FP32 eval_held_out_full.php verwenden."
    );
}

// Argument-Falle absichern: in diesem Projekt ist schon mehrfach ein Pfad oder
// eine Toleranz an der Stelle gelandet, an der eine Zahl erwartet wurde
// (dokumentiert fuer verify_int8_reference.php und diag_int8_roundtrip.php).
// num_heads muss hidden_dim teilen - ein Fehlgriff faellt hier laut auf statt
// spaeter als stille Falschmessung.
if ($num_heads_override !== null) {
    if ($num_heads_override < 1 || $header['hidden_dim'] % $num_heads_override !== 0) {
        heldout_full_i8_fail(
            "num_heads=$num_heads_override teilt hidden_dim={$header['hidden_dim']} nicht. " .
            "Argumentreihenfolge ist <checkpoint> [holdout_dir] [num_heads] [max_windows]."
        );
    }
    // BEFUND 2026-08-29, beim Bau dieses Skripts aufgefallen: eine falsche
    // Kopfzahl stuerzt NICHT ab, sie liefert eine andere Zahl. Auf diesem
    // Modell ergab num_heads=2 statt 4 einen Held-out-Loss von 6.029 statt
    // 4.623 - 1,4 nats Unterschied, plausibel aussehend, komplett falsch.
    // Genau die Sorte leiser Falschantwort, gegen die dieses Projekt sonst
    // ueberall absichert. Deshalb: Widerspruch zur aufgeloesten Kopfzahl ist
    // ein Abbruch, kein Hinweis.
    $resolved = resolve_num_heads($checkpoint, $header['hidden_dim']);
    if ($num_heads_override !== $resolved && getenv('SNAI_EVAL_FORCE_HEADS') !== '1') {
        heldout_full_i8_fail(
            "num_heads=$num_heads_override widerspricht der aufgeloesten Kopfzahl $resolved " .
            "(aus {$checkpoint}.heads bzw. head_config.php). Eine falsche Kopfzahl aendert den " .
            "Held-out-Loss um Groessenordnungen, ohne zu scheitern. Argument weglassen (oder '-' " .
            "setzen), um automatisch aufzuloesen; SNAI_EVAL_FORCE_HEADS=1 erzwingt den Wert."
        );
    }
}

$holdout_files = glob(rtrim($holdout_dir, '/') . '/*.txt');
if ($holdout_files === false || count($holdout_files) === 0) {
    heldout_full_i8_fail("Kein Held-out-Korpus in $holdout_dir gefunden (*.txt).");
}
// Explizit sortieren statt sich auf die glob()-Reihenfolge zu verlassen: die
// Fenstergrenzen haengen von der Reihenfolge der Dateien ab, und ein A/B, der
// auf verschiedenen Maschinen unterschiedlich schneidet, vergleicht nicht mehr
// dasselbe.
sort($holdout_files, SORT_STRING);

// Kein frueher Byte-Abbruch - der komplette Korpus wird geladen.
$text = '';
foreach ($holdout_files as $f) {
    $text .= file_get_contents($f) . "\n";
}
if (strlen(trim($text)) < 2) {
    heldout_full_i8_fail("Held-out-Korpus ist leer.");
}

$num_heads = $num_heads_override ?? resolve_num_heads($checkpoint, $header['hidden_dim']);

heldout_full_i8_progress(
    "Tokenisiere Korpus (" . count($holdout_files) . " Datei(en), " . strlen($text) . " Bytes)..."
);
$tokenizer = new SnaiTokenizer('symbio_vocab.json');
$tokens = $tokenizer->encode($text);
$total_tokens = count($tokens);
if ($total_tokens < 2) {
    heldout_full_i8_fail("Zu wenige Token nach Tokenisierung fuer eine Loss-Berechnung.");
}

// $native_int8=true: laedt SNAI_V6/V7 direkt ueber cortex_load_stream_i8(),
// forward() dispatcht intern an cortex_forward_i8() - kein Umweg ueber FP32.
$cortex = new SnaiCortexBridge($checkpoint, $num_heads, true);

// LoRA: liegt neben dem Checkpoint eine Adapterdatei, MUSS sie eingespielt
// werden. Ohne sie misst man die Basis und traegt die Zahl in die LoRA-Zeile
// der Auswertung ein - plausibel und falsch.
try {
    $lh = $cortex->attach_lora_if_present($checkpoint);
    if ($lh !== null) {
        heldout_full_i8_progress(sprintf(
            "LoRA-Adapter eingespielt: Rang %d, Maske %d, alpha %.3f (%s).",
            $lh['rank'], $lh['mask'], $lh['alpha'], basename(snai_lora_path($checkpoint))));
    }
} catch (RuntimeException $e) {
    heldout_full_i8_fail($e->getMessage());
}

$ctx_size   = $cortex->ctx_size;
$vocab_size = $cortex->vocab_size;
if ($ctx_size < 2) {
    heldout_full_i8_fail("Ungueltige ctx_size im geladenen Modell: $ctx_size");
}

// Dropout ist ein Prozess-Global und greift laut cortex.nim nur in
// cortex_train_step(). Dieses Skript setzt es nie, es steht also auf 0.0.
// Die Pruefung kostet nichts und haelt fest, dass die Messung nicht zufaellig
// ist - waere sie es, waere jeder A/B wertlos.
if (method_exists($cortex, 'get_dropout_rate')) {
    $dr = $cortex->get_dropout_rate();
    if ($dr > 0.0) {
        heldout_full_i8_fail("Dropout ist aktiv ($dr) - eine Eval-Messung muss deterministisch sein.");
    }
}

// Gleiche Schwelle wie train_worker.php - und seit 2026-09-03 auch dieselben
// Schalter. Der Grund ist gemessen: auf der Renoir-iGPU dieses Laptops ist der
// OpenCL-Pfad bei dim 512 mit Faktor 0,62x LANGSAMER als die CPU
// (diagnose/bench_dim512_cpu_vs_gpu.php). Ohne Schalter lief AUCH die
// Auswertung dort - im Produktivlauf 40 mal, je einmal nach jedem Segment.
//
// Aufgefallen ist es nur, weil der Auswerter seine GPU-Uebernahme meldet
// ("Stateful OpenCL JIT eingerastet auf: AMD Radeon Graphics"). Ohne diese
// Zeile im Log waere es als "die Auswertung dauert halt" durchgegangen.
$_fcpu = in_array(trim((string)getenv('SNAI_FORCE_CPU')), ['1','ja','yes','true'], true);
$_gmin = trim((string)getenv('SNAI_GPU_MIN_DIM'));
$_gmin = ($_gmin !== '' && is_numeric($_gmin)) ? (int)$_gmin : 512;
if (!$_fcpu && method_exists($cortex, 'init_gpu') && $header['hidden_dim'] >= $_gmin) {
    $cortex->init_gpu();
}

// Uebernommen aus eval_held_out_i8.php (AUDIT 2026-08-19): ohne diese Pruefung
// endet ein Modell mit kleinerem Vokabular als der Tokenizer in einem nackten
// "FFI\Exception: C array index out of bounds" beim Zugriff auf
// $logits[$target]. eval_held_out_full.php (FP32) hat diese Absicherung nicht.
$max_tok = max($tokens);
if ($max_tok >= $vocab_size) {
    heldout_full_i8_fail(
        "Token-ID $max_tok liegt ausserhalb des Modell-Vokabulars ($vocab_size). " .
        "Der Held-out-Korpus wurde mit einem groesseren Tokenizer-Vokabular kodiert " .
        "als das Modell kennt - Checkpoint und symbio_vocab.json passen nicht zusammen."
    );
}

$planned_windows = (int)ceil(($total_tokens - 1) / $ctx_size);
$capped = ($max_windows > 0 && $max_windows < $planned_windows);
heldout_full_i8_progress(
    "$total_tokens Token, ctx_size=$ctx_size -> $planned_windows Fenster" .
    ($capped ? " (auf $max_windows gekappt, siehe max_windows)" : "") . "."
);

// SNAI_EVAL_VERTEILT=1 (2026-09-28): die max_windows Fenster gleichmaessig ueber
// alle VOLLEN Fenster verteilen statt die ersten zu nehmen. Die ersten 64 sind
// ~10 % des Pruefsatzes und nur wenige Artikel; Segmentgewinne hingen damit am
// Themenzufall dieses Ausschnitts (gemessen: Fenstergewinn gegen Naehe zum
// Segment rho 0,67). Eigene Protokolldatei, damit die Reihen nie vermischt werden.
$auswahl = null;
if (getenv('SNAI_EVAL_VERTEILT') === '1') {
    if (!$capped) {
        heldout_full_i8_fail("SNAI_EVAL_VERTEILT braucht max_windows < Fensterzahl ($planned_windows).");
    }
    $voll = intdiv($total_tokens, $ctx_size);
    $auswahl = [];
    for ($i = 0; $i < $max_windows; $i++) {
        $auswahl[intdiv((2 * $i + 1) * $voll, 2 * $max_windows)] = true;
    }
    if (count($auswahl) !== $max_windows) {
        heldout_full_i8_fail("Verteilte Auswahl nicht eindeutig: $max_windows aus $voll vollen Fenstern.");
    }
    heldout_full_i8_progress("Fensterauswahl VERTEILT: $max_windows aus $voll vollen Fenstern.");
}

$total_loss    = 0.0;
$total_count   = 0;
$windows       = 0;
$window_losses = [];

for ($offset = 0; $offset < $total_tokens - 1; $offset += $ctx_size) {
    if ($max_windows > 0 && $windows >= $max_windows) break;
    if ($auswahl !== null && !isset($auswahl[intdiv($offset, $ctx_size)])) continue;

    $window = array_slice($tokens, $offset, $ctx_size);
    if (count($window) < 2) break; // Restfenster zu kurz fuer ein Vorhersagepaar

    $windows++;
    $win_loss  = 0.0;
    $win_count = 0;

    // reset_cache() zwischen den Fenstern: jedes Fenster startet ohne
    // Kontext aus dem vorherigen - dasselbe Prinzip wie die Trainingsfenster
    // in train_worker.php.
    $cortex->reset_cache();
    $logits = $cortex->forward([$window[0]]);

    $n = count($window);
    for ($i = 1; $i < $n; $i++) {
        $target = $window[$i];

        // Numerisch stabiler Log-Softmax nur fuer das Zieltoken - Zeile fuer
        // Zeile identisch zu eval_held_out_i8.php, damit beide Skripte auf
        // demselben Fenster garantiert dieselbe Zahl liefern.
        $max_val = -INF;
        for ($v = 0; $v < $vocab_size; $v++) {
            if ($logits[$v] > $max_val) $max_val = $logits[$v];
        }
        $sum_exp = 0.0;
        for ($v = 0; $v < $vocab_size; $v++) {
            $sum_exp += exp($logits[$v] - $max_val);
        }
        $log_prob_target = ($logits[$target] - $max_val) - log($sum_exp);
        $win_loss += -$log_prob_target;
        $win_count++;

        $logits = $cortex->forward([$target]);
    }

    // Global aufsummieren, NICHT pro Fenster mitteln: das letzte Fenster ist
    // in der Regel kuerzer und darf nicht dasselbe Gewicht bekommen wie ein
    // volles.
    $total_loss  += $win_loss;
    $total_count += $win_count;
    $window_losses[] = $win_count > 0 ? round($win_loss / $win_count, 6) : null;

    if ($windows % 20 === 0) {
        $elapsed = round(microtime(true) - $start_time, 1);
        $running = $total_count > 0 ? round($total_loss / $total_count, 4) : 0.0;
        heldout_full_i8_progress(
            "Fenster $windows/$planned_windows, $total_count Token, Loss bisher $running ({$elapsed}s)..."
        );
    }
}

if ($total_count === 0) {
    heldout_full_i8_fail("Keine Positionen bewertet (Korpus zu kurz fuer ein einziges Fenster).");
}

$avg_loss     = $total_loss / $total_count;
$perplexity   = exp($avg_loss);
$ppl_display  = is_finite($perplexity) ? round($perplexity, 4) : 'INF';
$duration_sec = round(microtime(true) - $start_time, 1);

// Kappung nie stillschweigend: wer diese Zahl spaeter liest, muss sehen, dass
// sie nicht ueber den ganzen Korpus geht.
if ($capped) {
    heldout_full_i8_progress(
        "ACHTUNG: gekappt auf $windows von $planned_windows Fenstern - " .
        "diese Zahl deckt NICHT den ganzen Korpus ab."
    );
}

echo "HELDOUT_FULL_LOSS=" . round($avg_loss, 6)
   . " HELDOUT_FULL_PPL=$ppl_display"
   . " HELDOUT_FULL_TOKENS=$total_count"
   . " HELDOUT_FULL_WINDOWS=$windows\n";

$basename = basename($checkpoint);
if (preg_match('/^cp_(.+)_e(\d+)\.snai$/', $basename, $m)) {
    $session_id = $m[1];
    $epoch = (int)$m[2];
} else {
    $session_id = pathinfo($basename, PATHINFO_FILENAME);
    $epoch = null;
}

$log_dir = './factory/checkpoints/';
if (!is_dir($log_dir)) @mkdir($log_dir, 0777, true);
// SNAI_EVAL_LOG_TAG (2026-09-02, mit dem Argmax-Fix): haengt ein Suffix an den
// Protokollnamen. WOZU: der Argmax in train_cluster.php ruft dieses Skript pro
// Epoche mit GEKAPPTER Fensterzahl auf. Ohne Trennung landen diese
// Auswahlmessungen in derselben heldout_full_i8_<session>.jsonl wie die
// autoritativen Voll-Korpus-Messungen - und weil $checkpoint dabei dem Schema
// cp_<session>_e<N>.snai folgt, sogar mit gesetztem epoch-Feld, also
// strukturell ununterscheidbar. Wer die Epochenkurve dann ohne Filter auf
// heldout_full_windows liest, mischt 32-Fenster-Auswahlwerte unter
// 92-Fenster-Ergebnisse. Genau diese Sorte Vermischung hat am 02.09. beinahe
// eine falsche Kernaussage erzeugt.
$log_tag = (string)getenv('SNAI_EVAL_LOG_TAG');
$log_tag = preg_replace('/[^A-Za-z0-9_-]/', '', $log_tag);
if ($auswahl !== null) $log_tag = 'verteilt' . ($log_tag !== '' ? "_$log_tag" : '');
$log_path = $log_dir . "heldout_full_i8_{$session_id}" . ($log_tag !== '' ? "_$log_tag" : '') . ".jsonl";
$entry = [
    'timestamp'            => date('c'),
    'epoch'                => $epoch,
    'checkpoint'           => $basename,
    'magic'                => $header['magic'],
    'flags'                => $header['flags'] ?? 0,
    'ctx_size'             => $ctx_size,
    'heldout_full_loss'    => round($avg_loss, 6),
    'heldout_full_ppl'     => is_finite($perplexity) ? round($perplexity, 4) : null,
    'heldout_full_tokens'  => $total_count,
    'heldout_full_windows' => $windows,
    'planned_windows'      => $planned_windows,
    'capped'               => $capped,
    'holdout_dir'          => $holdout_dir,
    'holdout_files'        => array_map('basename', $holdout_files),
    // Code-Review 2026-11-05 (L5/K3): Basisname allein unterscheidet gleichnamige
    // Staende aus verschiedenen Ordnern nicht, und dieselben Prueftexte koennen je
    // Rechner verschieden tokenisiert werden (NFKC nur mit php-intl, snai_tokenizer.php).
    // Pfad, Pruefsumme des Checkpoints und der Tokenfolge machen beides sichtbar;
    // compare_full_paired.php bricht bei abweichender token_md5 ab.
    'checkpoint_pfad'      => realpath($checkpoint) ?: $checkpoint,
    'checkpoint_md5'       => (@md5_file($checkpoint)) ?: null,
    'korpus_tokens'        => $total_tokens,
    'token_md5'            => md5(implode(',', $tokens)),
    'nfkc'                 => class_exists('Normalizer'),
    'duration_sec'         => $duration_sec,
    'window_losses'        => $window_losses,
];
if ($auswahl !== null) {
    $entry['fenster_auswahl'] = 'verteilt';
    $entry['fenster_index']   = array_keys($auswahl);
}
@file_put_contents($log_path, json_encode($entry) . "\n", FILE_APPEND);

heldout_full_i8_progress("Fertig in {$duration_sec}s -> $log_path");
exit(0);
