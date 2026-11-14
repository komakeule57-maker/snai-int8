<?php
// Dateiname: eval_held_out_i8.php
// Funktion: PHASE 6 DES INT8-UMBAUS
// - INT8-Pendant zu eval_held_out.php. Reiner
// nativer INT8-Forward-Pass-Loss (cortex_load_stream_i8()/cortex_forward_i8(),
// kein Umweg über FP32) auf einem Held-out-Korpus für einen SNAI_V6-
// Checkpoint (z.B. aus train_worker.php/train_cluster.php mit dtype=3,
// nach dem tensor-bewussten Merge in merge_v6_models()). Schließt die in
// Phase 5 dokumentierte Lücke ("eval_held_out.php versteht nur SNAI_V5").
//
// Bewusst ein SEPARATES Skript statt eval_held_out.php zu verändern: hält
// den bestehenden, produktiv genutzten FP32-Eval-Pfad unangetastet.
//
// Nutzung: php eval_held_out_i8.php <checkpoint.v6> [holdout_dir] [max_tokens] [num_heads]
//
// Ausgabe bei Erfolg: "HELDOUT_LOSS=<float> HELDOUT_PPL=<float|INF> HELDOUT_TOKENS=<int>"
// auf STDOUT, Exit-Code 0. Bei jedem Fehler: STDERR, Exit-Code 1.

date_default_timezone_set('Europe/Berlin');

chdir(__DIR__);
require_once 'snai_tokenizer.php';
require_once 'tensor_io.php';
require_once 'tensor_ffi_adapter.php';
require_once __DIR__ . '/head_config.php';

function heldout_i8_fail(string $msg): void {
    fwrite(STDERR, "🚨 [Held-out-Eval-INT8] $msg\n");
    exit(1);
}

if ($argc < 2) {
    heldout_i8_fail("Nutzung: php eval_held_out_i8.php <checkpoint.v6> [holdout_dir] [max_tokens] [num_heads]");
}

$checkpoint          = $argv[1];
$holdout_dir         = $argv[2] ?? './factory/holdout/';
$max_tokens          = isset($argv[3]) ? max(2, (int)$argv[3]) : 1000;
$num_heads_override  = isset($argv[4]) ? (int)$argv[4] : null;

if (!file_exists($checkpoint)) {
    heldout_i8_fail("Checkpoint nicht gefunden: $checkpoint");
}

$header = load_model_header_any($checkpoint);
if (!$header) {
    heldout_i8_fail("Konnte Modell-Header nicht lesen: $checkpoint");
}
if (!snai_is_int8_magic($header['magic'])) {
    heldout_i8_fail("Kein SNAI_V6/V7-Checkpoint (Magic: {$header['magic']}) - fuer FP32 eval_held_out.php verwenden.");
}

$holdout_files = glob(rtrim($holdout_dir, '/') . '/*.txt');
if ($holdout_files === false || count($holdout_files) === 0) {
    heldout_i8_fail("Kein Held-out-Korpus in $holdout_dir gefunden (*.txt).");
}

$text = '';
foreach ($holdout_files as $f) {
    $text .= file_get_contents($f) . "\n";
    if (strlen($text) > $max_tokens * 8) break;
}
if (strlen(trim($text)) < 2) {
    heldout_i8_fail("Held-out-Korpus ist leer.");
}

$num_heads = $num_heads_override ?? resolve_num_heads($checkpoint, $header['hidden_dim']);

$tokenizer = new SnaiTokenizer('symbio_vocab.json');
$tokens = $tokenizer->encode($text);
if (count($tokens) > $max_tokens) {
    $tokens = array_slice($tokens, 0, $max_tokens);
}
if (count($tokens) < 2) {
    heldout_i8_fail("Zu wenige Token nach Tokenisierung fuer eine Loss-Berechnung.");
}

// $native_int8=true: laedt SNAI_V6 direkt nativ ueber cortex_load_stream_i8(),
// forward() dispatcht intern automatisch an cortex_forward_i8() (siehe
// SnaiCortexBridge::$is_int8 in tensor_ffi_adapter.php).
$cortex = new SnaiCortexBridge($checkpoint, $num_heads, true);

// LoRA (2026-08-29): liegt neben dem Checkpoint eine Adapterdatei, MUSS sie
// eingespielt werden - sonst misst dieser Indikator die Basis und meldet sie
// als Ergebnis des LoRA-Laufs.
try {
    $lh = $cortex->attach_lora_if_present($checkpoint);
    if ($lh !== null) {
        fwrite(STDERR, sprintf("  > [Held-out-Eval-INT8] LoRA-Adapter eingespielt (Rang %d, Maske %d).\n",
               $lh['rank'], $lh['mask']));
    }
} catch (RuntimeException $e) {
    heldout_i8_fail($e->getMessage());
}

if (count($tokens) > $cortex->ctx_size) {
    $tokens = array_slice($tokens, 0, $cortex->ctx_size);
}

$cortex->reset_cache();
$vocab_size = $cortex->vocab_size;

// AUDIT 2026-08-19: Ohne diese Pruefung endet ein Modell, dessen Vokabular
// kleiner ist als das des Tokenizers (z.B. ein mit explizitem vocab_size
// gegossenes Testmodell gegen das 8192er symbio_vocab.json), in einem
// nackten "FFI\Exception: C array index out of bounds" beim Zugriff auf
// $logits[$target] - der Logit-Puffer hat nur vocab_size Eintraege, die
// Token-IDs laufen aber bis zur Tokenizer-Groesse. Dieselbe Falle steckt
// unveraendert in eval_held_out.php (FP32) - dort bewusst nicht angefasst,
// um den produktiven Pfad nicht zu beruehren.
$max_tok = max($tokens);
if ($max_tok >= $vocab_size) {
    heldout_i8_fail(
        "Token-ID $max_tok liegt ausserhalb des Modell-Vokabulars ($vocab_size). " .
        "Der Held-out-Korpus wurde mit einem groesseren Tokenizer-Vokabular kodiert " .
        "als das Modell kennt - Checkpoint und symbio_vocab.json passen nicht zusammen."
    );
}

$logits = $cortex->forward([$tokens[0]]);

$total_loss = 0.0;
$count = 0;
for ($i = 1; $i < count($tokens); $i++) {
    $target = $tokens[$i];

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

    $logits = $cortex->forward([$target]);
}

if ($count === 0) {
    heldout_i8_fail("Keine Positionen bewertet (Korpus nach Kontextfenster-Kappung zu kurz).");
}

$avg_loss = $total_loss / $count;
$perplexity = exp($avg_loss);
$ppl_display = is_finite($perplexity) ? round($perplexity, 4) : 'INF';
echo "HELDOUT_LOSS=" . round($avg_loss, 6) . " HELDOUT_PPL=$ppl_display HELDOUT_TOKENS=$count\n";

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
$log_path = $log_dir . "heldout_i8_{$session_id}.jsonl";
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
