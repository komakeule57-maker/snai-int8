<?php
// Dateiname: eval_held_out.php
// Funktion: Reiner Forward-Pass-Loss auf einem Held-out-Korpus (siehe
// Stichwort "Held-out-Set + periodische Eval") - kein Training, keine
// Gewichtsaenderung, kein Backward-Pass, kein Adam-Schritt.
//
// Nutzung: php eval_held_out.php <checkpoint.snai> [holdout_dir] [max_tokens] [num_heads]
//   <checkpoint.snai>  zu bewertendes Modell
//   [holdout_dir]      Default: ./factory/holdout/
//   [max_tokens]       Obergrenze fuer bewertete Token (Default 1000) - haelt die
//                       Eval-Kosten "vernachlaessigbar" (Roadmap-Formulierung),
//                       unabhaengig davon wie gross der Held-out-Korpus ist.
//   [num_heads]        Default: automatisch ueber head_config.php aufgeloest
//                       (wie bei train_worker.php).
//
// Ausgabe bei Erfolg: eine Zeile "HELDOUT_LOSS=<float> HELDOUT_TOKENS=<int>"
// auf STDOUT (fuer einfaches Scraping durch train_cluster.php), Exit-Code 0.
// Bei jedem Fehler: Meldung auf STDERR, Exit-Code 1 - nie fatal fuer den
// Aufrufer, ein fehlgeschlagener Eval-Lauf darf einen echten Trainingslauf
// nie stoppen.
//
// Zusaetzlich: Anhaengen einer JSONL-Zeile an
// factory/checkpoints/heldout_<session_id>.jsonl (Session-ID/Epoche aus dem
// Checkpoint-Dateinamen geparst, Muster "cp_<session>_e<epoch>.snai" -
// passt zu train_cluster.php's Checkpoint-Namensschema). Bei abweichendem
// Dateinamen (z.B. Genesis-/Basismodell) wird der Dateiname selbst als
// Session-ID verwendet, Epoche bleibt null.

// AUDIT-FIX (2026-08-11): wie im Steuer-Daemon - date.timezone-Ini steht auf
// UTC statt Europe/Berlin.
date_default_timezone_set('Europe/Berlin');

chdir(__DIR__);
require_once 'snai_tokenizer.php';
require_once 'tensor_io.php';
require_once 'tensor_ffi_adapter.php';
require_once __DIR__ . '/head_config.php';

function heldout_fail(string $msg): void {
    fwrite(STDERR, "🚨 [Held-out-Eval] $msg\n");
    exit(1);
}

if ($argc < 2) {
    heldout_fail("Nutzung: php eval_held_out.php <checkpoint.snai> [holdout_dir] [max_tokens] [num_heads]");
}

$checkpoint          = $argv[1];
$holdout_dir         = $argv[2] ?? './factory/holdout/';
$max_tokens          = isset($argv[3]) ? max(2, (int)$argv[3]) : 1000;
$num_heads_override  = isset($argv[4]) ? (int)$argv[4] : null;

if (!file_exists($checkpoint)) {
    heldout_fail("Checkpoint nicht gefunden: $checkpoint");
}

$holdout_files = glob(rtrim($holdout_dir, '/') . '/*.txt');
if ($holdout_files === false || count($holdout_files) === 0) {
    heldout_fail("Kein Held-out-Korpus in $holdout_dir gefunden (*.txt).");
}

// Nur so viel Text laden, wie fuer $max_tokens realistisch noetig ist (grobe
// Obergrenze in Bytes, ~8 Byte/Token als konservativer Worst Case) - die
// exakte Kappung auf $max_tokens passiert nach dem Tokenisieren.
$text = '';
foreach ($holdout_files as $f) {
    $text .= file_get_contents($f) . "\n";
    if (strlen($text) > $max_tokens * 8) break;
}
if (strlen(trim($text)) < 2) {
    heldout_fail("Held-out-Korpus ist leer.");
}

$header = load_model_header($checkpoint);
if (!$header) {
    heldout_fail("Konnte Modell-Header nicht lesen: $checkpoint");
}
$num_heads = $num_heads_override ?? resolve_num_heads($checkpoint, $header['hidden_dim']);

$tokenizer = new SnaiTokenizer('symbio_vocab.json');
$tokens = $tokenizer->encode($text);
if (count($tokens) > $max_tokens) {
    $tokens = array_slice($tokens, 0, $max_tokens);
}
if (count($tokens) < 2) {
    heldout_fail("Zu wenige Token nach Tokenisierung fuer eine Loss-Berechnung.");
}

$cortex = new SnaiCortexBridge($checkpoint, $num_heads);

// Kontextfenster des Modells respektieren - cortex_forward() bricht
// stillschweigend ab, sobald die Position den KV-Cache ueberlaeuft (siehe
// cortex.nim, cortex_forward: "if pos >= state.ctxSize: break"), was sonst
// zu stillen, falschen (veralteten) Logits fuehren wuerde.
if (count($tokens) > $cortex->ctx_size) {
    $tokens = array_slice($tokens, 0, $cortex->ctx_size);
}

// SNAI_FORCE_CPU / SNAI_GPU_MIN_DIM - identisch zu train_worker.php und
// eval_held_out_full_i8.php. Nachgezogen am 2026-09-03: diese Datei trug die
// Schwelle noch fest verdrahtet, die Schalter griffen hier also nicht.
$_fcpu = in_array(trim((string)getenv('SNAI_FORCE_CPU')), ['1','ja','yes','true'], true);
$_gmin = trim((string)getenv('SNAI_GPU_MIN_DIM'));
$_gmin = ($_gmin !== '' && is_numeric($_gmin)) ? (int)$_gmin : 512;
if (!$_fcpu && method_exists($cortex, 'init_gpu') && $header['hidden_dim'] >= $_gmin) {
    $cortex->init_gpu();
}

$cortex->reset_cache();
$vocab_size = $cortex->vocab_size;

// Erstes Token in den (frisch genullten) Cache fuettern - liefert die
// Logits fuer die Vorhersage von tokens[1], die erste auswertbare Position.
$logits = $cortex->forward([$tokens[0]]);

$total_loss = 0.0;
$count = 0;
for ($i = 1; $i < count($tokens); $i++) {
    $target = $tokens[$i];

    // Numerisch stabiler Log-Softmax NUR fuer das Zieltoken - log(p_target) =
    // (logit_target - max) - log(sum_exp). Kein voller Wahrscheinlichkeits-
    // vektor noetig, nur der eine Wert fuer die Cross-Entropy.
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
    $count++;

    // Zieltoken selbst in den Cache fuettern - liefert die Logits fuer die
    // NAECHSTE Position im naechsten Schleifendurchlauf.
    $logits = $cortex->forward([$target]);
}

if ($count === 0) {
    heldout_fail("Keine Positionen bewertet (Korpus nach Kontextfenster-Kappung zu kurz).");
}

$avg_loss = $total_loss / $count;

// Update 2026-08-09 (Nachruest-Paket Punkt 11 "Perplexity als
// abgeleitete Metrik"): reine exp()-Transformation des bereits berechneten
// Loss, menschlich leichter einzuordnen als der rohe Cross-Entropy-Wert.
// is_finite()-Guard: bei einem sehr hohen Loss (z.B. frisch initialisiertes/
// entartetes Modell) kippt exp() nach +INF - JSON kennt kein INF, json_encode()
// wuerde das Feld sonst stillschweigend zu null verwerfen bzw. false liefern.
$perplexity = exp($avg_loss);
$ppl_display = is_finite($perplexity) ? round($perplexity, 4) : 'INF';
echo "HELDOUT_LOSS=" . round($avg_loss, 6) . " HELDOUT_PPL=$ppl_display HELDOUT_TOKENS=$count\n";

// --- Strukturiertes Log (Grundlage fuer das noch offene Run-Manifest-Item) ---
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
$log_path = $log_dir . "heldout_{$session_id}.jsonl";
$entry = [
    'timestamp'      => date('c'),
    'epoch'          => $epoch,
    'checkpoint'     => $basename,
    'heldout_loss'   => round($avg_loss, 6),
    'heldout_ppl'    => is_finite($perplexity) ? round($perplexity, 4) : null,
    'heldout_tokens' => $count,
];
@file_put_contents($log_path, json_encode($entry) . "\n", FILE_APPEND);

exit(0);
