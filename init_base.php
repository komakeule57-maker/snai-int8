<?php
/**
 * SYMBIO NANO-AI FRAMEWORK (Code-4372)
 * Modul: Base Model Initializer (Phase VIII - Adam Persistence)
 * -------------------------------------------------------------------------
 * MAXIME: E > H. Gießt die komplexe Architektur direkt in einen 
 * sequentiellen, C/Nim-kompatiblen Binär-Stream (Little Endian).
 * UPDATE: Schreibt nun das SNAI_V5 Format. Generiert interleaved
 * Zero-Arrays für das Momentum (m) und die Varianz (v) des Adam-Optimizers.
 */
require_once 'snai_tokenizer.php';

// 2026-10-18: Abbruch mit Exitcode 1 statt die() (die() endet mit 0, Fehlersuche 2026-10-16 Befund A3). Eine halb
// geschriebene Genesis wird entfernt, sonst hielte train_cluster.php sie wegen file_exists() fuer gelungen.
$genesis_angelegt = false;
function genesis_abbruch(string $meldung): never {
    global $fp, $output_file, $genesis_angelegt;
    echo $meldung;
    if ($genesis_angelegt) {
        if (is_resource($fp)) fclose($fp);
        @unlink($output_file);
    }
    exit(1);
}

if ($argc < 2) {
    genesis_abbruch("Nutzung: php init_base.php <output.snai> [vocab_size=8192] [hidden_dim=128] [ctx_size=512] [num_layers=2] [ffn_dim=auto] [saat]\n");
}

$output_file = $argv[1];

if (!isset($argv[2]) || $argv[2] == 0) {
    $tokenizer = new SnaiTokenizer('symbio_vocab.json');
    $vocab_size = $tokenizer->getVocabSize(); 
    echo "> Automatische Vocab-Größe erkannt: $vocab_size\n";
} else {
    $vocab_size = (int)$argv[2];
}

$hidden_dim  = isset($argv[3]) ? (int)$argv[3] : 128;
$ctx_size    = isset($argv[4]) ? (int)$argv[4] : 512;
$num_layers  = isset($argv[5]) ? (int)$argv[5] : 2;

// AUDIT-FIX: Explizite FFN-Dim Unterstützung (Für Llama/Mistral Architektur-Treue)
$ffn_dim = isset($argv[6]) ? (int)$argv[6] : ($hidden_dim * 4);

// Optionale Saat fuer die Gewichtsinitialisierung (2026-08-25). Ohne Angabe
// bleibt alles wie bisher: PHP saet mt_rand() selbst aus Entropie, jede Genesis
// ist eine andere. Mit Angabe wird sie reproduzierbar - noetig, sobald man
// denselben Vergleichslauf mit einem ANDEREN Seed wiederholen und die beiden
// Laeufe spaeter noch auseinanderhalten will. Das Trainings-Skript selbst hat
// keine weitere Zufallsquelle (kein Shuffle, dropout_rate=0), die Genesis ist
// also der einzige Seed, den ein Lauf ueberhaupt hat.
if (isset($argv[7]) && $argv[7] !== '') {
    $init_seed = (int)$argv[7];
    mt_srand($init_seed);
    echo "> Saat der Gewichtsinitialisierung: $init_seed (reproduzierbar)\n";
}

// RAM-AUFRAEUMEN 2026-10-15 (Doku 6ao): SNAI_GENESIS_V6=1 schreibt SNAI_V6 (int8 + Zeilenskalen, m/v Nullen). Gleiche
// Zufallsfolge wie V5, jeder Tensor wird sofort mit der Quantisierung der Engine umgerechnet (cortex_quantize_rows_q8 =
// quantizeMatrixToQ8, dieselbe Funktion, die der Worker nach dem Laden einer V5-Genesis aufruft). Training ab V6 ist
// bytegleich zu Training ab V5 gleicher Saat; der Worker braucht beim ersten Segment kein Float-Modell mehr.
// Ungebunden geschrieben (mit w_out): ob gebunden wird, entscheidet wie bisher der Worker.
//
// VORGABE seit 2026-10-18 wieder V5. Vom 2026-10-15 bis 2026-10-18 war V6 die Vorgabe; damit brach jeder FP32-Lauf ab
// Genesis ab (der Worker lehnt eine int8-Basis bei dtype=1 ab, train_cluster.php und die Destille nehmen ohne
// Angabe FP32), und rund 20 Pruefstaende in diagnose/ laden ihre Genesis mit dem FP32-Lader cortex_load_stream()
// (gemessen: gate_int8_vs_fp32.php "Magic 'SNAI_V6' != 'SNAI_V5'", rc 255). V6 verlangt jetzt, wer weiss, dass er
// int8 trainiert: train_cluster.php bei dtype=3. SNAI_GENESIS_V5=1 bleibt gueltig und ist jetzt die Vorgabe.
$genesis_v6_an  = in_array(trim((string)getenv('SNAI_GENESIS_V6')), ['1', 'ja'], true);
$genesis_v5_an  = in_array(trim((string)getenv('SNAI_GENESIS_V5')), ['1', 'ja'], true);
if ($genesis_v6_an && $genesis_v5_an) {
    genesis_abbruch("❌ [Fehler] SNAI_GENESIS_V5 und SNAI_GENESIS_V6 sind beide gesetzt - unklar, welches Format gemeint ist.\n");
}
$genesis_v5 = !$genesis_v6_an;
// V6 zaehlt die Zeilen jedes int8-Tensors in einem uint16 (wie cortex_save_stream_i8). Ab 65536 Zeilen liefe pack('v')
// still ueber und die Datei waere unlesbar (Fehlersuche 2026-10-16, Befund B9).
if (!$genesis_v5 && max($vocab_size, $hidden_dim, $ffn_dim) > 65535) {
    genesis_abbruch("❌ [Fehler] SNAI_V6 kann hoechstens 65535 Zeilen je Tensor zaehlen (Vocab=$vocab_size, Dim=$hidden_dim, "
        . "FFN=$ffn_dim). Ohne SNAI_GENESIS_V6 als V5 giessen.\n");
}
$q8_ffi = null;
if (!$genesis_v5) {
    $q8_ffi = FFI::cdef("int cortex_quantize_rows_q8(float* src, int rows, int cols, signed char* out_i8, float* out_scale);",
        getenv('SNAI_CORTEX_LIB') ?: (__DIR__ . '/libcortex.so'));
}
echo "=== INITIALISIERE MULTI-LAYER CORTEX (STREAM-MODUS - " . ($genesis_v5 ? "V5" : "V6 int8") . ") ===\n";
echo "Parameter: Vocab=$vocab_size | Dim=$hidden_dim | FFN=$ffn_dim | Ctx=$ctx_size | Layers=$num_layers\n";

/**
 * Generiert und schreibt Tensor-Daten direkt in Chunks auf die Festplatte.
 * Schreibt bei V5 IMMER drei Blobs nacheinander: Gewichte (w), Momentum (m), Varianz (v).
 */
function write_tensor_with_adam($fp, int $size, bool $is_ones = false, float $scale = 0.02) {
    $chunk_size = 8192; 
    
    // 1. Die tatsächlichen Gewichte (w) schreiben
    $buffer_w = '';
    for ($i = 0; $i < $size; $i++) {
        $val = $is_ones ? 1.0 : ((mt_rand() / mt_getrandmax()) * 2 - 1) * $scale;
        $buffer_w .= pack('g', $val); 
        
        if (($i + 1) % $chunk_size === 0) {
            fwrite($fp, $buffer_w);
            $buffer_w = ''; 
        }
    }
    if (strlen($buffer_w) > 0) fwrite($fp, $buffer_w);

    // 2. Das Momentum (m) für Adam mit Nullen (0.0) überschreiben
    $buffer_zero = '';
    $zero_val = pack('g', 0.0);
    for ($i = 0; $i < $size; $i++) {
        $buffer_zero .= $zero_val;
        if (($i + 1) % $chunk_size === 0) {
            fwrite($fp, $buffer_zero); // Schreibe Momentum (m)
            $buffer_zero = '';
        }
    }
    if (strlen($buffer_zero) > 0) fwrite($fp, $buffer_zero);
    
    // 3. Die Varianz (v) für Adam mit Nullen (0.0) überschreiben
    $buffer_zero = '';
    for ($i = 0; $i < $size; $i++) {
        $buffer_zero .= $zero_val;
        if (($i + 1) % $chunk_size === 0) {
            fwrite($fp, $buffer_zero); // Schreibe Varianz (v)
            $buffer_zero = '';
        }
    }
    if (strlen($buffer_zero) > 0) fwrite($fp, $buffer_zero);
}

/**
 * V6-Gegenstueck zu write_tensor_with_adam(): zieht dieselben Zufallswerte in derselben Reihenfolge, legt sie als
 * float32 in einen FFI-Puffer (gleiche Rundung double->float wie pack('g')) und schreibt int8-Tensoren als
 * [uint16 Zeilen][float Skalen][int8 Daten], RMS-Gains als float32 - danach m und v als float32-Nullen
 * (Format save_model_stream_i8). $rows = 0 heisst RMS-Gain (bleibt float).
 */
function write_tensor_v6($fp, $ffi, int $size, int $rows, bool $is_ones = false, float $scale = 0.02) {
    $buf = FFI::new("float[" . max(1, $size) . "]");
    for ($i = 0; $i < $size; $i++) {
        $buf[$i] = $is_ones ? 1.0 : ((mt_rand() / mt_getrandmax()) * 2 - 1) * $scale;
    }
    if ($rows > 0) {
        $q = FFI::new("signed char[" . max(1, $size) . "]");
        $s = FFI::new("float[" . max(1, $rows) . "]");
        if ($ffi->cortex_quantize_rows_q8(FFI::addr($buf[0]), $rows, intdiv($size, $rows), FFI::addr($q[0]), FFI::addr($s[0])) !== 1) {
            genesis_abbruch("❌ [Fehler] cortex_quantize_rows_q8 gescheitert ($rows Zeilen).\n");
        }
        fwrite($fp, pack('v', $rows) . FFI::string($s, $rows * 4));
        fwrite($fp, FFI::string($q, $size));
    } else {
        fwrite($fp, FFI::string($buf, $size * 4));
    }
    $zero = str_repeat("\0", 4 * 8192);
    for ($k = 0; $k < 2; $k++) {
        for ($rest = $size * 4; $rest > 0; $rest -= strlen($zero)) fwrite($fp, substr($zero, 0, min($rest, strlen($zero))));
    }
}

$start_time = microtime(true);

$dir = dirname($output_file);
if (!is_dir($dir) && $dir !== '.') {
    mkdir($dir, 0777, true);
}

$fp = fopen($output_file, 'wb');
if (!$fp) {
    genesis_abbruch("❌ [Fehler] Konnte Datei nicht öffnen: $output_file\n");
}
$genesis_angelegt = true;

if ($genesis_v5) {
echo "> Schreibe V5-Header...\n";
// V5 Magic String (auf 8 Bytes gepaddet)
fwrite($fp, str_pad('SNAI_V5', 8, "\0"));
fwrite($fp, pack('VVVVV', $vocab_size, $hidden_dim, $ffn_dim, $ctx_size, $num_layers));

echo "> Gieße Globale Tensoren (Embeddings & Output) + Adam State...\n";
write_tensor_with_adam($fp, $vocab_size * $hidden_dim, false, 1.0 / sqrt($hidden_dim));
write_tensor_with_adam($fp, $vocab_size * $hidden_dim, false, 0.0001); // w_out (Softmax-Schutz)
write_tensor_with_adam($fp, $hidden_dim, true); // rms_final

// AUDIT-FIX (2026-08-16): GPT-2-artige Tiefenskalierung der beiden
// "Rueckschreib"-Projektionen pro Block (w_o fuer Attention, w_down fuer FFN). Ohne
// diesen Faktor waechst die Varianz des Residual-Streams mit der Layerzahl an (jeder
// Layer addiert unveraendert auf den Stream) - reiner Init-Zeitpunkt-Effekt, macht
// tiefere Genesis-Netze von Anfang an optimierungsfreundlicher (weniger Warmup/kleinere
// noetige LR bei mehr Tiefe), ohne die Forward-Architektur zu aendern. Bei den aktuell
// 2 Drohnen-Layern kaum spuerbar, zahlt sich erst aus, falls Genesis-Init je tiefer wird.
$depth_scale = 1.0 / sqrt(2.0 * $num_layers);

for ($l = 0; $l < $num_layers; $l++) {
    echo "> Gieße Layer $l (QKV, Attention, FFN, RMSNorm) + Adam State...\n";
    write_tensor_with_adam($fp, $hidden_dim, true); // rms_att
    write_tensor_with_adam($fp, $hidden_dim, true); // rms_ffn
    write_tensor_with_adam($fp, $hidden_dim * $hidden_dim, false, 1.0 / sqrt($hidden_dim)); // w_q
    write_tensor_with_adam($fp, $hidden_dim * $hidden_dim, false, 1.0 / sqrt($hidden_dim)); // w_k
    write_tensor_with_adam($fp, $hidden_dim * $hidden_dim, false, 1.0 / sqrt($hidden_dim)); // w_v
    write_tensor_with_adam($fp, $hidden_dim * $hidden_dim, false, (1.0 / sqrt($hidden_dim)) * $depth_scale); // w_o (Residual-Rueckschreib -> tiefenskaliert)
    write_tensor_with_adam($fp, $ffn_dim * $hidden_dim, false, 0.02); // w_up
    write_tensor_with_adam($fp, $hidden_dim * $ffn_dim, false, 0.02 * $depth_scale); // w_down (Residual-Rueckschreib -> tiefenskaliert)
}
} else {
// Reihenfolge, Skalen und Zufallsfolge wie der V5-Zweig oben; Zeilen = Ausgabe-Kanal (snai_tensor_shape in tensor_io.php).
echo "> Schreibe V6-Header (int8)...\n";
fwrite($fp, str_pad('SNAI_V6', 8, "\0"));
fwrite($fp, pack('VVVVV', $vocab_size, $hidden_dim, $ffn_dim, $ctx_size, $num_layers));
fwrite($fp, pack('V', 1));   // dtype INT8

echo "> Gieße Globale Tensoren (Embeddings & Output) + Adam State...\n";
write_tensor_v6($fp, $q8_ffi, $vocab_size * $hidden_dim, $vocab_size, false, 1.0 / sqrt($hidden_dim));
write_tensor_v6($fp, $q8_ffi, $vocab_size * $hidden_dim, $vocab_size, false, 0.0001); // w_out (Softmax-Schutz)
write_tensor_v6($fp, $q8_ffi, $hidden_dim, 0, true); // rms_final

$depth_scale = 1.0 / sqrt(2.0 * $num_layers);

for ($l = 0; $l < $num_layers; $l++) {
    echo "> Gieße Layer $l (QKV, Attention, FFN, RMSNorm) + Adam State...\n";
    write_tensor_v6($fp, $q8_ffi, $hidden_dim, 0, true); // rms_att
    write_tensor_v6($fp, $q8_ffi, $hidden_dim, 0, true); // rms_ffn
    write_tensor_v6($fp, $q8_ffi, $hidden_dim * $hidden_dim, $hidden_dim, false, 1.0 / sqrt($hidden_dim)); // w_q
    write_tensor_v6($fp, $q8_ffi, $hidden_dim * $hidden_dim, $hidden_dim, false, 1.0 / sqrt($hidden_dim)); // w_k
    write_tensor_v6($fp, $q8_ffi, $hidden_dim * $hidden_dim, $hidden_dim, false, 1.0 / sqrt($hidden_dim)); // w_v
    write_tensor_v6($fp, $q8_ffi, $hidden_dim * $hidden_dim, $hidden_dim, false, (1.0 / sqrt($hidden_dim)) * $depth_scale); // w_o
    write_tensor_v6($fp, $q8_ffi, $ffn_dim * $hidden_dim, $ffn_dim, false, 0.02); // w_up
    write_tensor_v6($fp, $q8_ffi, $hidden_dim * $ffn_dim, $hidden_dim, false, 0.02 * $depth_scale); // w_down
}
fwrite($fp, pack('V', 0));   // adam_t
}

fclose($fp);

$duration = round(microtime(true) - $start_time, 2);
$mb = round(filesize($output_file) / 1024 / 1024, 2);

echo "✅ [Erfolg] Genesis-Cortex (" . ($genesis_v5 ? "V5" : "V6 int8") . ") gegossen: $output_file ($mb MB) in $duration Sekunden.\n";