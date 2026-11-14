<?php
// Dateiname: eval_held_out_full.php
// Funktion: Vollstaendiger Forward-Pass-Loss ueber den GESAMTEN Held-out-
// Korpus (alle Dateien in factory/holdout/, keine Token-Obergrenze) - im
// Gegensatz zu eval_held_out.php, das absichtlich auf max_tokens (Default
// 1000) gekappt ist, um pro Epoche "vernachlaessigbar" billig zu bleiben
// (Stichwort "Held-out-Set + periodische Eval"). Dieses Skript
// ist NICHT fuer den Pro-Epoche-Aufruf aus train_cluster.php gedacht -
// bewusst separates Skript, separates Log, damit der bestehende, guenstige
// Pfad unangetastet bleibt. Gedacht fuer den manuellen/on-demand Einsatz,
// z.B. nach Abschluss eines Tiers.
//
// Kosten: der gesamte Held-out-Korpus (aktuell ~632k Token) wird Token fuer
// Token per Forward-Pass bewertet - das ist grob 630x teurer als der
// Pro-Epoche-Indikator und kann je nach Modellgroesse mehrere zehn Minuten
// dauern. Deshalb kein Aufruf im Trainings-Hot-Path.
//
// Nutzung: php eval_held_out_full.php <checkpoint.snai> [holdout_dir] [num_heads]
//   <checkpoint.snai>  zu bewertendes Modell
//   [holdout_dir]      Default: ./factory/holdout/
//   [num_heads]        Default: automatisch ueber head_config.php aufgeloest
//
// Der Korpus wird in nicht-ueberlappende Fenster von ctx_size Token
// zerlegt (reset_cache() zwischen den Fenstern) - dasselbe Prinzip wie die
// Trainings-Fenster in train_worker.php, nur ohne Shuffling (Reihenfolge ist
// fuer einen Loss-Mittelwert irrelevant, deterministische Reihenfolge macht
// den Lauf reproduzierbar). Cross-Entropy wird global ueber ALLE Fenster
// aufsummiert, nicht pro Fenster gemittelt.
//
// Ausgabe bei Erfolg: eine Zeile
// "HELDOUT_FULL_LOSS=<float> HELDOUT_FULL_PPL=<float|INF> HELDOUT_FULL_TOKENS=<int> HELDOUT_FULL_WINDOWS=<int>"
// auf STDOUT, Exit-Code 0. Fortschritt waehrenddessen auf STDERR. Bei jedem
// Fehler: Meldung auf STDERR, Exit-Code 1.
//
// Zusaetzlich: eigenes strukturiertes Log
// factory/checkpoints/heldout_full_<session_id>.jsonl (separat von
// heldout_<session>.jsonl - andere Granularitaet, sollen nicht vermischt
// werden).

// AUDIT-FIX (2026-08-11): wie im Steuer-Daemon - date.timezone-Ini steht auf
// UTC statt Europe/Berlin.
date_default_timezone_set('Europe/Berlin');

chdir(__DIR__);
require_once 'snai_tokenizer.php';
require_once 'tensor_io.php';
require_once 'tensor_ffi_adapter.php';
require_once __DIR__ . '/head_config.php';

function heldout_full_fail(string $msg): void {
    fwrite(STDERR, "🚨 [Held-out-Full-Eval] $msg\n");
    exit(1);
}

function heldout_full_progress(string $msg): void {
    fwrite(STDERR, "  > [Held-out-Full-Eval] $msg\n");
}

if ($argc < 2) {
    heldout_full_fail("Nutzung: php eval_held_out_full.php <checkpoint.snai> [holdout_dir] [num_heads]");
}

$start_time = microtime(true);

$checkpoint         = $argv[1];
$holdout_dir        = $argv[2] ?? './factory/holdout/';
$num_heads_override = isset($argv[3]) ? (int)$argv[3] : null;

if (!file_exists($checkpoint)) {
    heldout_full_fail("Checkpoint nicht gefunden: $checkpoint");
}

$holdout_files = glob(rtrim($holdout_dir, '/') . '/*.txt');
if ($holdout_files === false || count($holdout_files) === 0) {
    heldout_full_fail("Kein Held-out-Korpus in $holdout_dir gefunden (*.txt).");
}

// Im Gegensatz zu eval_held_out.php: KEIN fruehzeitiger Byte-Abbruch - der
// komplette Korpus wird geladen und tokenisiert.
$text = '';
foreach ($holdout_files as $f) {
    $text .= file_get_contents($f) . "\n";
}
if (strlen(trim($text)) < 2) {
    heldout_full_fail("Held-out-Korpus ist leer.");
}

$header = load_model_header($checkpoint);
if (!$header) {
    heldout_full_fail("Konnte Modell-Header nicht lesen: $checkpoint");
}
$num_heads = $num_heads_override ?? resolve_num_heads($checkpoint, $header['hidden_dim']);
$ctx_size = $header['ctx_size'];
if ($ctx_size < 2) {
    heldout_full_fail("Ungueltige ctx_size im Checkpoint-Header: $ctx_size");
}

heldout_full_progress("Tokenisiere Korpus (" . count($holdout_files) . " Datei(en), " . strlen($text) . " Bytes)...");
$tokenizer = new SnaiTokenizer('symbio_vocab.json');
$tokens = $tokenizer->encode($text);
$total_tokens = count($tokens);
if ($total_tokens < 2) {
    heldout_full_fail("Zu wenige Token nach Tokenisierung fuer eine Loss-Berechnung.");
}
heldout_full_progress("$total_tokens Token, ctx_size=$ctx_size -> " . ceil($total_tokens / $ctx_size) . " Fenster.");

$cortex = new SnaiCortexBridge($checkpoint, $num_heads);

// SNAI_FORCE_CPU / SNAI_GPU_MIN_DIM - identisch zu train_worker.php und
// eval_held_out_full_i8.php. Nachgezogen am 2026-09-03: diese Datei trug die
// Schwelle noch fest verdrahtet, die Schalter griffen hier also nicht.
$_fcpu = in_array(trim((string)getenv('SNAI_FORCE_CPU')), ['1','ja','yes','true'], true);
$_gmin = trim((string)getenv('SNAI_GPU_MIN_DIM'));
$_gmin = ($_gmin !== '' && is_numeric($_gmin)) ? (int)$_gmin : 512;
if (!$_fcpu && method_exists($cortex, 'init_gpu') && $header['hidden_dim'] >= $_gmin) {
    $cortex->init_gpu();
}

$vocab_size = $cortex->vocab_size;
$total_loss = 0.0;
$total_count = 0;
$windows = 0;

for ($offset = 0; $offset < $total_tokens - 1; $offset += $ctx_size) {
    $window = array_slice($tokens, $offset, $ctx_size);
    if (count($window) < 2) break; // Restfenster zu kurz fuer ein Vorhersagepaar

    $windows++;
    $cortex->reset_cache();
    $logits = $cortex->forward([$window[0]]);

    for ($i = 1; $i < count($window); $i++) {
        $target = $window[$i];

        // Numerisch stabiler Log-Softmax nur fuer das Zieltoken - identisch
        // zu eval_held_out.php.
        $max_val = -INF;
        for ($v = 0; $v < $vocab_size; $v++) {
            if ($logits[$v] > $max_val) $max_val = $logits[$v];
        }
        $sum_exp = 0.0;
        for ($v = 0; $v < $vocab_size; $v++) {
            $sum_exp += exp($logits[$v] - $max_val);
        }
        $log_prob_target = ($logits[$target] - $max_val) - log($sum_exp);
        $total_loss += -$log_prob_target;
        $total_count++;

        $logits = $cortex->forward([$target]);
    }

    if ($windows % 20 === 0) {
        $elapsed = round(microtime(true) - $start_time, 1);
        heldout_full_progress("Fenster $windows fertig, $total_count Token bewertet ({$elapsed}s)...");
    }
}

if ($total_count === 0) {
    heldout_full_fail("Keine Positionen bewertet (Korpus zu kurz fuer ein einziges Fenster).");
}

$avg_loss = $total_loss / $total_count;
$perplexity = exp($avg_loss);
$ppl_display = is_finite($perplexity) ? round($perplexity, 4) : 'INF';
$duration_sec = round(microtime(true) - $start_time, 1);

echo "HELDOUT_FULL_LOSS=" . round($avg_loss, 6) . " HELDOUT_FULL_PPL=$ppl_display HELDOUT_FULL_TOKENS=$total_count HELDOUT_FULL_WINDOWS=$windows\n";

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
$log_path = $log_dir . "heldout_full_{$session_id}.jsonl";
$entry = [
    'timestamp'            => date('c'),
    'epoch'                => $epoch,
    'checkpoint'           => $basename,
    'heldout_full_loss'    => round($avg_loss, 6),
    'heldout_full_ppl'     => is_finite($perplexity) ? round($perplexity, 4) : null,
    'heldout_full_tokens'  => $total_count,
    'heldout_full_windows' => $windows,
    'duration_sec'         => $duration_sec,
];
@file_put_contents($log_path, json_encode($entry) . "\n", FILE_APPEND);

heldout_full_progress("Fertig in {$duration_sec}s.");
exit(0);
