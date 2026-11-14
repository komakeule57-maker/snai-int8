<?php
/**
 * Dateiname: snai_inference.php
 * Funktion: SYMBIO NANO-AI FRAMEWORK - API Inference Worker (Phase VIII)
 * -------------------------------------------------------------------------
 * MAXIME: E > H. Nackte Latenz. Umgeht PHP komplett beim Laden der Gewichte.
 * FIX: Repetition Penalty (Anti-Loop Korsett) hinzugefügt.
 * FIX: NaN-Tripwire. Bricht hart ab, wenn das Modell korrupte Gewichte hat.
 * UPDATE (Phase VIII): Volle SNAI_V5 Kompatibilität! Das Aegis-Shield weiß nun,
 * dass Trainings-Artefakte ihre Adam-States (m, v) mitschleppen (x3 Dateigröße).
 * UPDATE (2026-08-14): Optionaler Beam-Search-Modus (drittes CLI-Arg) als
 * Alternative zum reinen Temperature-Sampling gegen Wiederhol-/Spam-Kollaps.
 * Rein PHP-seitig via mehrfachem cortex_load_stream() (ein unabhaengiger
 * KV-Cache pro Beam) - kein cortex.nim-Eingriff, kein libcortex.so-Rebuild
 * noetig. Siehe beam_topk_logprobs() und den Beam-Zweig weiter unten.
 */

error_reporting(E_ALL & ~E_NOTICE & ~E_WARNING);
ini_set('display_errors', '0');
ini_set('memory_limit', '128M'); // OOM Safe, da PHP keine Arrays mehr hält!

// AUDIT-FIX: cortex.nim's matVecMul() nutzt OpenMP (`||`-Schleifen, -fopenmp).
// libgomp haelt danach einen idlen Worker-Thread-Pool offen. Beendet sich dieser
// Prozess (wie hier: ein Forward-Pass, dann sofortiges Skript-Ende) sehr kurz nach
// dem letzten Kernel-Aufruf, faengt der Prozess-Exit die Threads oft noch im
// Uebergang in den Idle-Zustand - Segfault in libgomp selbst (verifiziert per gdb-
// Backtrace, reproduzierbar 10/10 ohne diesen Fix). PASSIVE laesst die Worker
// per futex schlafen statt zu spinnen und vermeidet das Zeitfenster (10/10 sauber
// mit diesem Fix). Muss VOR dem FFI::cdef()-Laden von libcortex.so gesetzt werden.
putenv('OMP_WAIT_POLICY=PASSIVE');

require_once 'snai_tokenizer.php';
require_once 'head_config.php';
// LoRA (2026-08-29): fuer snai_lora_path()/load_lora_stream(). Dieses Skript
// haelt bewusst eine EIGENE cdef() (keine SnaiCortexBridge) - die Formatschicht
// darf es trotzdem mitbenutzen, sie ist reines PHP ohne FFI.
require_once 'tensor_io.php';

if ($argc < 3) {
    fwrite(STDERR, "Nutzung: php snai_inference.php <modell.snai> <prompt> [beam_width]\n");
    fwrite(STDERR, "  beam_width weggelassen oder <=1: normales Temperature-/Min-P-Sampling (Default).\n");
    fwrite(STDERR, "  beam_width >=2: Beam-Search ueber N parallele Kandidatenpfade.\n");
    exit(1);
}

$model_file = $argv[1];
$user_input = $argv[2];
$beam_width = isset($argv[3]) ? max(1, (int)$argv[3]) : 1; // >=2 aktiviert Beam-Search (siehe unten)
$temperature = 0.25;         // E>H Sweet-Spot für präzise SFT-Inferenz
$repetition_penalty = 1.15;  // E>H Anti-Loop Korsett (Zwingt das Modell, neue Worte zu finden)
$repetition_window = 64;     // Nur die letzten N Tokens penalisieren, nicht die ganze History
$min_p = 0.05;                // Kappt den Rausch-Tail relativ zum wahrscheinlichsten Token (Füllwort-/<unk>-Spam)
$max_new_tokens = 256;

// Laengenstrafe der Beam-Siegerauswahl (Wu et al. 2016, GNMT Abschnitt 7).
// Ausfuehrliche Herleitung an der Auswertungsstelle weiter unten.
//
// 1,5 ist GEMESSEN, nicht gewaehlt: auf prod512_s1 wurden die Beam-Kandidaten
// mit SNAI_BEAM_DUMP=1 ausgelesen und die Schwelle ausgerechnet, ab der die
// lange Fortsetzung den kurzen Abbruch schlaegt. Sie liegt bei alpha* = 1,4321
// (Prompt "Das Wohnhaus...", len 2 gegen len 256); der zweite Problemfall
// kippt schon bei 1,1927. 1,5 haelt Abstand ueber beide (Abstand 0,111 im
// straffen Fall) statt knapp auf der Kante zu sitzen.
// Siehe docs/PRODUKTIVLAUF_DIM512.md §13 fuer die volle Rechnung.
//
// Ueberschreibbar per SNAI_BEAM_ALPHA (fuer Messungen und Gegenproben).
define('SNAI_BEAM_ALPHA_DEFAULT', 1.5);

// Bewertungsparameter des BEAM-Zweigs - bewusst getrennt von den
// Sampling-Parametern oben (2026-09-07, docs/PRODUKTIVLAUF_DIM512.md §15).
//
// Bis 2026-09-07 rankte der Beam durch dieselbe Pipeline wie das Sampling:
// temperature 0,25, min_p 0,05, repetition_penalty 1,15. Fuer einen Beam ist
// das falsch - er soll die ECHTE Log-Wahrscheinlichkeit des Modells
// vergleichen. Gemessene Folgen des alten Standes:
//   - temperature 0,25 vervierfacht alle Logit-Abstaende, jede Abweichung vom
//     Greedy-Pfad kostet das Vierfache;
//   - min_p 0,05 laesst bei dieser Temperatur nur Tokens innerhalb von 0,749
//     Logit vom Spitzentoken zu -> schon in Schritt 0 kamen nur 2 Kandidaten
//     fuer 3 Slots durch, ab ~Schritt 10 lief reines Greedy;
//   - beam_width war dadurch WIRKUNGSLOS: 3, 5 und 8 lieferten bitgleich
//     dasselbe Ergebnis.
// Entscheidend: die Verzerrung waechst mit der Sicherheit des Modells. Sie sah
// deshalb wie Modellverhalten aus (Ausgaben wurden Segment fuer Segment
// kuerzer) und war keines.
//
// Defaults sind jetzt neutral. Die alten Werte sind ueber die Umgebung
// wiederherstellbar, damit sich Spuren von vor dem 2026-09-07 reproduzieren
// lassen: SNAI_BEAM_TEMP=0.25 SNAI_BEAM_MINP=0.05 SNAI_BEAM_REP=1.15
// Sperre gegen wortwoertliche Wiederholung im Beam (no_repeat_ngram).
// Ein Beam, der die echte Log-Wahrscheinlichkeit maximiert, laeuft bei einem
// schwachen Sprachmodell in Schleifen - der Schnitt je Token VERBESSERT sich
// mit jeder Wiederholung. Gemessen an prod512_s2: 36x "Der Filmfestival",
// Schnitt von -6,28 (len 1) auf -1,92 (len 127) steigend. Das ist eine
// Eigenschaft des Ziels, kein Suchfehler.
// Die Antwort darauf ist eine harte Sperre statt einer Score-Verzerrung: ein
// Kandidat, der ein bereits vorhandenes n-Gramm woertlich wiederholen wuerde,
// wird ausgeschlossen. Die Rangfolge der uebrigen bleibt unangetastet - anders
// als bei repetition_penalty, die jeden Score verbiegt.
// 0 = aus.
define('SNAI_BEAM_NOREPEAT_DEFAULT', 0);
define('SNAI_BEAM_TEMP_DEFAULT', 1.0);
define('SNAI_BEAM_MINP_DEFAULT', 0.0);
// BLEIBT auf dem Sampling-Wert 1,15, und das ist eine bewusste Abweichung von
// der reinen Log-Wahrscheinlichkeit (2026-09-07, gemessen, siehe §16).
// Ohne sie laeuft der korrigierte Beam in wortwoertliche Schleifen - das Ziel
// selbst ist entartet, nicht die Suche. Gegenmessung auf prod512_s2,
// "Der Film handelt von", Vielfalt und Lesbarkeit:
//   rein (rep=1,0)          0,157  ->  36x "Der Filmfestival"
//   rep=1,15                0,695  ->  zusammenhaengende Saetze, Daten, ISBN
//   n-Gramm-Sperre n=4      0,795  ->  Bruchstueckliste ("Hochbach Hochberg
//                                      Hochmann Hermann"), Schleife zwar weg
// Die Kennzahl waehlt die Sperre, das Lesen waehlt die Penalty: Wortsalat hat
// maximale Vielfalt. Deshalb ist rep die Voreinstellung und die Sperre nur ein
// Angebot (SNAI_BEAM_NOREPEAT).
// Die Penalty verbiegt die Rangfolge - sie ist der EINE bewusst in Kauf
// genommene Eingriff, nachdem temperature (0,25) und min_p (0,05) aus dem
// Ranking raus sind. Wer die reine Log-Wahrscheinlichkeit will: SNAI_BEAM_REP=1.0
define('SNAI_BEAM_REP_DEFAULT',  1.15);
// Kalibrierte Kopiersperre im Beam (2026-10-24, messbuch snai/schleife-einstieg und
// snai/kopiersperre-promptfrei).
// Die Absatzschleifen entstehen im Beam: Nach einer Wortfolge, die schon einmal
// dastand, ist das Token, das damals folgte (der Kopierkandidat), oft das argmax,
// und der Beam setzt die Uebereinstimmung weit oefter fort als echter Text. Die
// Sperre nimmt den Kandidaten mit Wahrscheinlichkeit 1 - Durchlass_k aus der
// Auswahl (k = Laenge der Uebereinstimmung, Faecher 1, 2, 3, 4-7, 8-16; Durchlass
// = Fortsetzungsrate echten Textes / Rate im Beam, geschaetzt an prod512b_s4).
// Paare (letztes Token, Kandidat), die im Prompt stehen, bleiben frei: einen Namen
// aus dem Prompt wieder aufzugreifen ist erwuenscht. Ohne diese Ausnahme kostete
// die Sperre Namen ("Provinz Jorik Tannhusen" -> "Provinz Jorik zustaendig").
// prod512b_s4, Beam 3: Schleifenanteil U 0,55 -> 0,11 (12 Prompts), Namen aus dem
// Prompt 7/40 -> 12/40 (Grundform ohne Ausnahme: 2/40).
// SNAI_KOPIE_F=aus schaltet ab, fuenf Werte setzen einen anderen Durchlass,
// SNAI_KOPIE_PROMPTFREI=0 ist die Grundform (nur zum Messen), SNAI_KOPIE_SAAT (1)
// die Saat der Zufallsentscheidung. Der Beam bleibt damit wiederholbar.
// Seit 2026-10-26 die staerkere Dosis DS (Durchlass aus 12 Prompts, vorher D4 aus 4:
// 0.4174,0.6245,0.8671,0.7404,0.7988). prod512b_s5: Schleife 0,64 x D4, Namen aus dem
// Prompt hoechstens 2,2 von 100 weniger (360 Paare, messbuch snai/kopiersperre-gross).
define('SNAI_KOPIE_F_DEFAULT', '0.3613,0.5620,0.5627,0.7051,0.7978');

/**
 * Reproduziert exakt die Temperature/Repetition-Penalty/Min-P-Pipeline des
 * Sampling-Pfads weiter unten, gibt aber Log-Wahrscheinlichkeiten statt eines
 * gezogenen Samples zurueck - Kandidatenbewertung fuer den Beam-Search-Zweig.
 * $top_k begrenzt die Rueckgabe auf die wahrscheinlichsten Kandidaten (staerker
 * gefiltert als min_p allein, haelt den Kandidatenpool pro Beam klein).
 */
// Code-Review 2026-11-05 (L4): (float)"1,5" ergibt still 1.0. Zahlen aus der Umgebung
// laufen deshalb hier durch: leer/ungesetzt -> null (Vorgabe greift), Komma wird als
// Dezimalzeichen genommen und gemeldet, alles andere Nicht-Numerische bricht laut ab.
function snai_env_zahl(string $name): ?float {
    $e = getenv($name);
    if ($e === false || trim($e) === '') return null;
    $w = trim($e);
    if (strpos($w, ',') !== false && strpos($w, '.') === false) {
        fwrite(STDERR, "⚠️ $name='$w' mit Komma - gelesen als " . str_replace(',', '.', $w) . "\n");
        $w = str_replace(',', '.', $w);
    }
    if (!is_numeric($w)) {
        fwrite(STDERR, "🚨 $name='$e' ist keine Zahl - Abbruch.\n");
        exit(1);
    }
    return (float)$w;
}

function beam_topk_logprobs($c_logits, int $vocab_size, float $temperature, float $repetition_penalty, array $recent_history, float $min_p, int $top_k): array {
    $vals = [];
    for ($v = 0; $v < $vocab_size; $v++) {
        $vals[$v] = $c_logits[$v] / $temperature;
    }

    foreach (array_unique($recent_history) as $prev_tok) {
        if ($vals[$prev_tok] > 0) {
            $vals[$prev_tok] /= $repetition_penalty;
        } else {
            $vals[$prev_tok] *= $repetition_penalty;
        }
    }

    $max_val = max($vals);

    $unnorm = [];
    foreach ($vals as $v => $x) {
        $p = exp($x - $max_val);
        if ($min_p > 0.0 && $p < $min_p) continue; // Rausch-Tail raus, wie im Sampling-Pfad
        $unnorm[$v] = $p;
    }
    if (empty($unnorm)) {
        // Sicherheitsnetz: min_p hat alles gekappt (praktisch nie, da der Top-Token
        // exp(0)=1 immer >= min_p ueberlebt) - Top-Token roh zurueckgeben.
        $unnorm[array_search($max_val, $vals, true)] = 1.0;
    }

    $log_sum = log(array_sum($unnorm));
    $logprobs = [];
    foreach ($unnorm as $v => $p) {
        $logprobs[$v] = ($vals[$v] - $max_val) - $log_sum;
    }

    arsort($logprobs);
    return array_slice($logprobs, 0, $top_k, true);
}

if (!file_exists($model_file)) {
    fwrite(STDERR, "🚨 Fehler: Matrix nicht gefunden: $model_file\n");
    echo "System-Fehler: Cortex-Artefakt nicht gefunden.";
    exit(1);
}

// 1. DYNAMISCHE HEADER-ANALYSE (SNAI_V5/SNAI_V6 Binär-Format)
// -------------------------------------------------------------------------
// PHASE 6 DES INT8-UMBAUS ("Kleinigkeiten"-Nachzug):
// SNAI_V6 (INT8) wird jetzt neben SNAI_V5
// (FP32, unveraendertes Verhalten) erkannt und ueber cortex_load_stream_i8()/
// cortex_forward_i8() bedient - Sampling-/Beam-Search-Logik ist dtype-
// unabhaengig, nur der Lade-/Forward-Aufruf dispatcht.
$fp = fopen($model_file, 'rb');
$magic = trim(fread($fp, 8));
$is_int8 = ($magic === 'SNAI_V6' || $magic === 'SNAI_V7');
if ($magic !== 'SNAI_V5' && !$is_int8) {
    fwrite(STDERR, "🚨 Fatal: Invalider Header. Kein SNAI_V5/SNAI_V6/SNAI_V7 Artefakt!\n");
    echo "System-Fehler: Artefakt-Generation inkompatibel.";
    exit(1);
}
// 'V' = 32-bit unsigned Integer (Little Endian)
$params = unpack('Vvocab/Vhidden/Vffn/Vctx/Vlayers', fread($fp, 20));
$v7_flags = 0;
if ($is_int8) {
    fread($fp, 4); // dtype_version (SNAI_V6-Header ist 4 Byte laenger), hier nicht ausgewertet
    // EMB-EINGANG: SNAI_V7 traegt dahinter 4 Byte Flags; Bit 1 muss die Engine nach dem Laden gesetzt haben.
    if ($magic === 'SNAI_V7') $v7_flags = unpack('V', fread($fp, 4))[1];
}
fclose($fp);

$vocab_size = $params['vocab'];
$hidden_dim = $params['hidden'];
$ctx_size = $params['ctx'];
$num_layers = $params['layers'];
$ffn_dim = $params['ffn'];
// AUDIT-FIX: Vorher eine vom Sidecar-System unabhaengige Heuristik (dim/64), die
// mit dem tatsaechlich beim Training verwendeten resolve_num_heads() auseinanderlaufen
// konnte -> falsche Head-Zahl beim Laden reinterpretiert die gelernten Attention-
// Gewichte komplett (bis hin zu Segfaults bei Modellen, die mit weniger Heads
// trainiert wurden). Jetzt dieselbe Quelle wie Training/Synthese.
$num_heads = resolve_num_heads($model_file, $hidden_dim);

fwrite(STDERR, "[System] " . ($is_int8 ? "V6 (INT8)" : "V5 (FP32)") . " Binär-Artefakt decodiert: " . basename($model_file) . "\n");
fwrite(STDERR, "  > Architektur: $hidden_dim Dim | $num_layers Layers | $num_heads Heads\n");
if ($beam_width >= 2) {
    fwrite(STDERR, "  > Beam-Search aktiv: Breite $beam_width (statt Sampling)\n");
}

// =========================================================================
// 🚨 VETO-AUDIT (Phase VIII): Strikte V5 Dateigrößen-Validierung (Aegis-Shield)
// Jedes Array existiert jetzt im Triplet (Gewicht, Momentum, Varianz).
// NUR fuer SNAI_V5 (FP32) - SNAI_V6 (INT8) hat ein heterogenes Layout
// (INT8-Bloecke mit Skalen-Praefixen + Float32-Reste), das dieselbe simple
// Byte-Formel nicht abbilden kann. cortex_load_stream_i8() (cortex.nim)
// macht dieselbe Pruefung bereits INTERN (eigene Byte-Bilanz, siehe dortigen
// Kommentar) und liefert bei einem Mismatch nil zurueck - der bestehende
// Null-Pointer-Check nach dem Laden weiter unten faengt das ab.
// =========================================================================
if (!$is_int8) {
    $expected_size = 28; // Header
    $expected_size += ($vocab_size * $hidden_dim * 4) * 3; // embeddings
    $expected_size += ($vocab_size * $hidden_dim * 4) * 3; // w_out
    $expected_size += ($hidden_dim * 4) * 3;               // rms_final

    $layer_size = ($hidden_dim * 4) * 3 * 2;                 // rms_att, rms_ffn
    $layer_size += ($hidden_dim * $hidden_dim * 4) * 3 * 4;  // q, k, v, o
    $layer_size += ($ffn_dim * $hidden_dim * 4) * 3 * 2;     // up, down

    $expected_size += $layer_size * $num_layers;
    // Der adam_t-Trailer (int32, Adam-Bias-Correction-Schrittzähler) ist OPTIONAL:
    // tensor_io.php::save_model_stream() schreibt ihn, init_base.php (Genesis-Init)
    // nicht - siehe tensor_io.php::load_model(), das dieselbe Wahl trifft. Vorher
    // wurde hier bedingungslos +4 verlangt, was jede frische Genesis-Datei als
    // "korrupt" abwies (docs/BUGFIXES.md, Nebenbefund zur GPU-Weichen-Suche).

    $actual_size = filesize($model_file);
    if ($actual_size !== $expected_size && $actual_size !== $expected_size + 4) {
        fwrite(STDERR, "\n🚨 [SYMBIO VETO] KORRUPTION ENTDECKT!\n");
        fwrite(STDERR, "  > Artefakt ist unvollständig (Trainings-Abbruch / OOM beim Speichern).\n");
        fwrite(STDERR, "  > Ist-Größe:  " . number_format($actual_size) . " Bytes\n");
        fwrite(STDERR, "  > Soll-Größe: " . number_format($expected_size) . " oder " . number_format($expected_size + 4) . " Bytes (V5, mit/ohne adam_t-Trailer)\n\n");
        echo "System-Fehler: Corrupt Cortex Artifact (Incomplete Write).";
        exit(1);
    }
}

// 2. DIE FFI-BRÜCKE (Zero-Copy)
// -------------------------------------------------------------------------
$ffi = FFI::cdef(
    "void cortex_init_gpu();
     void* cortex_load_stream(const char* filepath, int num_heads);
     void cortex_forward(void* state, int* tokens, int num_tokens, float* logits);
     void cortex_reset_cache(void* state);
     void cortex_free(void* state);
     void* cortex_load_stream_i8(const char* filepath, int num_heads);
     void cortex_forward_i8(void* state, int* tokens, int num_tokens, float* logits);
     int cortex_lora_enable(void* state, int rank, float alpha, int slot_mask, int freeze_base, int seed);
     int cortex_lora_active(void* state);
     int cortex_lora_load(void* state, int layer, int slot, int is_b, float* raw, int size);",
    "./libcortex.so"
);

// Dispatch-Helfer statt 5 einzelner if($is_int8)-Verzweigungen an jeder
// cortex_forward()-Aufrufstelle (Sampling-Pfad + Beam-Search-Pfad) - siehe
// SnaiCortexBridge::forward() in tensor_ffi_adapter.php fuer dasselbe Muster.
$do_forward = function($state, $tok_buf, int $count, $logits_buf) use ($ffi, $is_int8): void {
    if ($is_int8) {
        $ffi->cortex_forward_i8($state, $tok_buf, $count, $logits_buf);
    } else {
        $ffi->cortex_forward($state, $tok_buf, $count, $logits_buf);
    }
};

// Wecke die GPU auf - sofern sie erwuenscht ist.
//
// SNAI_FORCE_CPU=1 haelt sie aus. Nachgeruestet am 2026-09-03: diese Stelle
// rief init_gpu() BEDINGUNGSLOS, ohne jede Dimensionsschwelle. Auf der
// Renoir-iGPU dieses Laptops ist der OpenCL-Pfad bei dim 512 gemessen
// LANGSAMER als die CPU (Training 0,62x, Auswertung 0,24x - siehe
// diagnose/bench_dim512_cpu_vs_gpu.php). Fuer den dim-512-Produktivlauf ist
// das der Pfad, ueber den das fertige Modell spaeter BENUTZT wird.
//
// Bewusst OHNE Dimensionsschwelle: ohne Schwelle laeuft heute auch bei
// dim 256 die w_out-Matrix (8192*256 = 2,1 Mio Elemente, ueber der
// GPU-Schwelle von 1 Mio) auf der GPU. Eine Schwelle nachtraeglich
// einzuziehen wuerde das Verhalten aller bisherigen Modelle aendern - das
// waere eine eigene Messung, kein Nebeneffekt dieses Schalters.
if (in_array(trim((string)getenv('SNAI_FORCE_CPU')), ['1','ja','yes','true'], true)) {
    fwrite(STDERR, "  > [CPU] SNAI_FORCE_CPU=1 gesetzt - GPU bleibt aus.\n");
} else {
    fwrite(STDERR, "  > Initiiere OpenCL JIT-Compiler...\n");
    $ffi->cortex_init_gpu();
}

// Stream Load: Die C-Library zieht die Datei direkt in den VRAM/Heap.
// Beam-Search braucht pro Beam einen eigenen, unabhaengigen KV-Cache -> das
// Modell wird $beam_width mal geladen (bei Default-Breite 1: genau einmal,
// identisch zum bisherigen Verhalten). Fuer die Modellgroessen dieses Projekts
// (Edge-Skala) ist die doppelte/mehrfache Gewichtskopie im
// RAM/VRAM vernachlaessigbar gegenueber dem Nutzen paralleler Kandidatenpfade.
// LoRA (2026-08-29): liegt neben dem Modell eine Adapterdatei, MUSS sie
// eingespielt werden. Ohne sie generierte man aus der nackten Basis: leise
// falsch, plausibel aussehend, nicht als Fehler erkennbar. Ein vorhandener,
// aber nicht einspielbarer Adapter ist deshalb ein Abbruch.
$lora_path  = snai_lora_path($model_file);
$lora_state = null;
if (file_exists($lora_path)) {
    if (!$is_int8) {
        fwrite(STDERR, "🚨 Fatal: LoRA-Adapter neben einem NICHT-INT8-Modell - die Adapter haengen an den INT8-Gewichten.\n");
        exit(1);
    }
    $lora_state = load_lora_stream($lora_path, $model_file);
    if ($lora_state === null) {
        fwrite(STDERR, "🚨 Fatal: Adapterdatei $lora_path passt nicht zum Modell.\n");
        exit(1);
    }
}

/** Spielt den geladenen Adapterzustand in EINEN Cortex-Zustand ein. */
$attach_lora = function($state) use ($ffi, $lora_state): void {
    if ($lora_state === null) return;
    $ok = $ffi->cortex_lora_enable($state, $lora_state['rank'], (float)$lora_state['alpha'],
              $lora_state['mask'], 1, 1);
    if ($ok !== 1 || $ffi->cortex_lora_active($state) !== 1) {
        fwrite(STDERR, "🚨 Fatal: LoRA liess sich nicht einrichten (Rang {$lora_state['rank']}).\n");
        exit(1);
    }
    foreach ($lora_state['tensors'] as $key => $entry) {
        [$l, $slot] = array_map('intval', explode('.', $key));
        foreach ([false, true] as $is_b) {
            $n = snai_lora_slot_size($slot, $is_b, $lora_state['rank'],
                     $lora_state['hidden_dim'], $lora_state['ffn_dim']);
            $k = $is_b ? 'b' : 'a';
            $buf = $ffi->new("float[$n]");
            FFI::memcpy($buf, $entry[$k], $n * 4);
            if ($ffi->cortex_lora_load($state, $l, $slot, $is_b ? 1 : 0,
                    $ffi->cast("float*", $buf), $n) !== $n) {
                fwrite(STDERR, "🚨 Fatal: Adapter $key/$k liess sich nicht einspielen.\n");
                exit(1);
            }
        }
    }
    // Adam-Momente bleiben bewusst draussen: fuer reine Inferenz wirkungslos,
    // und sie kosten das Vierfache an Kopierarbeit je Beam.
};

$states = [];
for ($b = 0; $b < $beam_width; $b++) {
    $states[$b] = $is_int8
        ? $ffi->cortex_load_stream_i8($model_file, $num_heads)
        : $ffi->cortex_load_stream($model_file, $num_heads);
    if ($states[$b] == null) {
        fwrite(STDERR, "🚨 Fatal: C-Stream-Loader gescheitert (Unbekannter I/O Fehler, Beam $b).\n");
        echo "System-Fehler: Memory Allocation Error.";
        exit(1);
    }
    // Jeder Beam haelt seine eigene Gewichtskopie - also braucht auch jeder
    // seinen eigenen Adapter. Nur den ersten zu versorgen waere ein Fehler,
    // der sich als "Beam-Search ist schlechter als Sampling" tarnen wuerde.
    $attach_lora($states[$b]);
    // EMB-EINGANG: Bit 1 in der Datei -> die Engine MUSS den Faktor gesetzt haben. Eine aeltere libcortex.so
    // uebergeht das Bit wortlos und rechnete ohne Faktor (Ausgabe waere Unsinn).
    if ($v7_flags & 2) {
        try {
            $ffi_emb = $ffi_emb ?? FFI::cdef("int cortex_get_emb_eingang(void* state);", "./libcortex.so");
            $emb_ok = $ffi_emb->cortex_get_emb_eingang($ffi_emb->cast("void*", $states[$b])) === 1;
        } catch (\Throwable $e) {
            $emb_ok = false;
        }
        if (!$emb_ok) {
            fwrite(STDERR, "🚨 Fatal: Modell traegt SNAI_V7 Bit 1 (Embedding-Eingangsfaktor), die Engine rechnet ohne ihn (libcortex.so zu alt?).\n");
            echo "System-Fehler: Artefakt-Generation inkompatibel.";
            exit(1);
        }
    }
}
if ($lora_state !== null) {
    fwrite(STDERR, "  > LoRA-Adapter eingespielt: Rang {$lora_state['rank']}, Maske "
         . "{$lora_state['mask']} (" . basename($lora_path) . ", $beam_width Beam(s)).\n");
}
$state_ptr = $states[0]; // Alias fuer den klassischen Sampling-Pfad (beam_width == 1)

// 3. TOKENIZER & PROMPT-ENGINEERING (SFT Korsett)
// -------------------------------------------------------------------------
$tokenizer = new SnaiTokenizer('symbio_vocab.json');

// Wir rahmen den Input des Dashboards strikt ein, damit die Drohne antwortet!
//
// SNAI_ROHPROMPT=1 nimmt dieses Korsett weg und schickt den Prompt roh ins
// Modell. NUR fuer Vortrainingsstaende gedacht (2026-09-06):
// [USER]/[SYMBIO] sind zwar echte Vokabular-Tokens (ID 5 und 6), kommen im
// Vortrainingskorpus aber nur als Rauschen vor (195/214 Treffer in pseg00,
// 0/19 in pseg01, bei ~19 MB pro Chunk). Ein Modell, das nur Wikipedia-Fliess-
// text gesehen hat, findet nach [SYMBIO] als wahrscheinlichste Fortsetzung
// einen Absatzumbruch - und der schneidet den Prompt ab. Gemessen an
// prod512_s1: mit Korsett faengt JEDE Antwort mit "\n\nDie Liste der..." an,
// ohne Korsett haengt sie grammatisch am Prompt ("...ist" -> " ein neues
// Gebiet der Stadt.").
//
// DEFAULT BLEIBT DAS KORSETT. dashboard.php, run_definitionssonde.sh und
// run_entartungssonde.py setzen die Variable nicht und messen unveraendert
// weiter - eine SFT-Drohne OHNE Korsett zu fragen waere der umgekehrte Fehler.
//
// KEIN trim() im Rohpfad: der Prompt ist hier ein Textanfang, der fortgesetzt
// wird, keine Frage. Ein getrimmter Prompt aendert das erste erzeugte Token.
$formatted_prompt = (getenv('SNAI_ROHPROMPT') === '1')
    ? $user_input
    : "[USER] " . trim($user_input) . "\n[SYMBIO]";
$tokens = $tokenizer->encode($formatted_prompt);

if (count($tokens) > $ctx_size - $max_new_tokens) {
    $tokens = array_slice($tokens, -($ctx_size - $max_new_tokens)); // Context Window erzwingen
}

// AUDIT-FIX (2026-08-14): Hardcoded ID 2 war im aktuellen Vokabular <s> (BOS),
// nicht </s> (EOS) - stammte offenbar noch vom alten 16k-Vokabular, in dem ID 2
// tatsaechlich der Stop-Token war. Jetzt dynamisch aufgeloest wie [USER].
$stop_tokens = [];
if (isset($tokenizer->encode("</s>")[0])) $stop_tokens[] = $tokenizer->encode("</s>")[0]; // EOS Token
if (isset($tokenizer->encode("[USER]")[0])) $stop_tokens[] = $tokenizer->encode("[USER]")[0];

// 4. INFERENZ (Autoregressiver Loop)
// -------------------------------------------------------------------------
$start_time = microtime(true);

if ($beam_width <= 1) {
    // -------------------------------------------------------------------
    // 4a. KLASSISCHER PFAD: ein Kandidatenpfad, Temperature/Min-P-Sampling.
    // Unveraendert gegenueber dem bisherigen Verhalten (Default).
    // -------------------------------------------------------------------
    $c_tokens = $ffi->new("int[" . $ctx_size . "]");
    $c_logits = $ffi->new("float[" . $vocab_size . "]");
    $history = []; // Tracking für Repetition Penalty

    $ffi->cortex_reset_cache($state_ptr);
    foreach ($tokens as $i => $tok) {
        $c_tokens[$i] = $tok;
        $history[] = $tok; // Prompt-Tokens ebenfalls penalisieren
    }

    $do_forward($state_ptr, $c_tokens, count($tokens), $c_logits);
    $prompt_time = round((microtime(true) - $start_time) * 1000);
    fwrite(STDERR, "  > Prompt verdaut in {$prompt_time}ms. Beginne Synthese...\n");

    $generated_text = "";

    for ($i = 0; $i < $max_new_tokens; $i++) {
        $best_token = 0;

        // =========================================================================
        // 🚨 VETO-AUDIT: NaN Tripwire
        // Wenn der C-Kernel kollabiert ist, fangen wir das hier ab!
        // =========================================================================
        if (is_nan($c_logits[0])) {
            fwrite(STDERR, "\n🚨 [SYMBIO VETO] KERNEL PANIC: Cortex spuckt NaNs! Die Matriarchin hat korrupte Gewichte (Explodierte Gradienten beim Merge).\n");
            break;
        }

        // Temperatur Scaling (In-Place)
        for ($v = 0; $v < $vocab_size; $v++) {
            $c_logits[$v] = $c_logits[$v] / $temperature;
        }

        // =========================================================================
        // 🛡️ REPETITION PENALTY (Verhindert das \n Koma)
        // Nur Sliding Window, sonst penalisiert eine lange Antwort irgendwann fast
        // den ganzen genutzten Vokab und die Verteilung rutscht in den Rausch-Tail.
        // =========================================================================
        $recent_history = array_slice($history, -$repetition_window);
        foreach (array_unique($recent_history) as $prev_tok) {
            if ($c_logits[$prev_tok] > 0) {
                $c_logits[$prev_tok] /= $repetition_penalty;
            } else {
                $c_logits[$prev_tok] *= $repetition_penalty;
            }
        }

        // Max-Wert für numerisch stabiles Softmax (Dynamischer Startwert)
        $max_val = -INF;
        for ($v = 0; $v < $vocab_size; $v++) {
            if ($c_logits[$v] > $max_val) {
                $max_val = $c_logits[$v];
                if ($temperature <= 0.01) $best_token = $v; // Greedy Fallback
            }
        }

        // Softmax & Sampling
        if ($temperature > 0.01) {
            $sum = 0.0;
            $probs = [];
            for ($v = 0; $v < $vocab_size; $v++) {
                $p = exp($c_logits[$v] - $max_val);
                $probs[$v] = $p;
                $sum += $p;
            }

            // =====================================================================
            // 🎯 MIN-P SAMPLING (Kappt den Rausch-Tail: Füllwörter/<unk>/Interpunktion)
            // $max_val ist per Konstruktion (s.o.) das Logit-Maximum, daher hat der
            // wahrscheinlichste Token hier immer unnormalisiertes p = exp(0) = 1.
            // min_p wirkt also direkt als Schwelle relativ zum Top-Token, ohne dass
            // wir vorher normalisieren müssen.
            // =====================================================================
            if ($min_p > 0.0) {
                $sum = 0.0;
                foreach ($probs as $v => $p) {
                    if ($p < $min_p) {
                        $probs[$v] = 0.0;
                    } else {
                        $sum += $p;
                    }
                }
            }

            $rand = (mt_rand() / mt_getrandmax()) * $sum;
            $cumulative = 0.0;
            for ($v = 0; $v < $vocab_size; $v++) {
                $cumulative += $probs[$v];
                if ($cumulative >= $rand) {
                    $best_token = $v;
                    break;
                }
            }
        }

        // Abbruchbedingungen prüfen
        if (in_array($best_token, $stop_tokens)) break;

        $history[] = $best_token;
        $word = $tokenizer->decode([$best_token]);

        // Halluzinations-Notbremse
        if (strpos($word, "[USER]") !== false) break;

        // Ausgabe (Fängt das Dashboard per STDOUT ab)
        echo $word;
        $generated_text .= $word;

        // Feedback Loop: Nächstes Token berechnen
        $c_tokens[0] = $best_token;
        $do_forward($state_ptr, $c_tokens, 1, $c_logits);

        if (count($tokens) + $i >= $ctx_size - 1) break;
    }

    fwrite(STDERR, "\n[⚙️ Metrik: " . mb_strlen($generated_text) . " Chars generiert]\n");

} else {
    // -------------------------------------------------------------------
    // 4b. BEAM SEARCH: $beam_width parallele Kandidatenpfade, je ein
    // physischer FFI-State (= eigener KV-Cache) pro Beam-"Slot". Ein Slot
    // repraesentiert ueber die Zeit nicht immer denselben Beam - wenn ein
    // Elternpfad mehrere Top-Kandidaten gleichzeitig stellt (Fork), wird ein
    // freier Slot per Replay (cortex_reset_cache + kompletter Tokenverlauf
    // neu durch cortex_forward) auf den neuen Pfad synchronisiert. Kein
    // natives Cache-Cloning noetig, daher keine cortex.nim-Aenderung - Preis
    // ist die O(Laenge)-Kosten eines Replays bei jedem Fork statt O(1).
    // -------------------------------------------------------------------
    // 2k Kandidaten je aktivem Beam. Der Faktor 2 ist kein Puffer, sondern die
    // Garantie, dass nach dem Aussortieren der Stopp-Token noch k Fortsetzungen
    // uebrig sind - sonst schrumpft die Suchbreite bei jedem Satzende dauerhaft.
    $top_k = 2 * $beam_width;

    $beam_temp = (($e = snai_env_zahl('SNAI_BEAM_TEMP')) !== null) ? max(0.01, $e) : SNAI_BEAM_TEMP_DEFAULT;
    $beam_minp = (($e = snai_env_zahl('SNAI_BEAM_MINP')) !== null) ? max(0.0,  $e) : SNAI_BEAM_MINP_DEFAULT;
    $beam_rep  = (($e = snai_env_zahl('SNAI_BEAM_REP'))  !== null) ? max(0.01, $e) : SNAI_BEAM_REP_DEFAULT;
    $beam_norep = (($e = getenv('SNAI_BEAM_NOREPEAT')) !== false && $e !== '') ? max(0, (int)$e) : SNAI_BEAM_NOREPEAT_DEFAULT;
    $kopie_f = null; $kopie_zaehler = [0, 0, 0]; $kopie_pbi = [];
    $kopie_promptfrei = getenv('SNAI_KOPIE_PROMPTFREI') !== '0';
    $e = getenv('SNAI_KOPIE_F'); $e = ($e === false || $e === '') ? SNAI_KOPIE_F_DEFAULT : $e;
    if ($e !== 'aus') {
        $kopie_f = array_map('floatval', explode(',', $e));
        if (count($kopie_f) !== 5) { fwrite(STDERR, "SNAI_KOPIE_F braucht 5 Werte oder 'aus'\n"); exit(1); }
        mt_srand((int)(getenv('SNAI_KOPIE_SAAT') ?: 1));
        if ($kopie_promptfrei) for ($ki = 0; $ki + 1 < count($tokens); $ki++) $kopie_pbi[$tokens[$ki] . ',' . $tokens[$ki + 1]] = true;
        fwrite(STDERR, "  > [KOPIE] Sperre f=" . implode('/', $kopie_f) . ($kopie_promptfrei ? ", Prompt-Paare frei: " . count($kopie_pbi) : ", Grundform") . "\n");
    }

    // Liefert die Tokens, die nach $seq ein bereits vorhandenes n-Gramm
    // woertlich schliessen wuerden. Betrachtet wird nur der generierte Text,
    // nicht der Prompt: ein Prompt-Wort erneut aufzugreifen ist erlaubt und oft
    // richtig, sich selbst abzuschreiben nicht.
    $gesperrte_tokens = function(array $seq) use ($beam_norep): array {
        if ($beam_norep < 2 || count($seq) < $beam_norep) return [];
        $praefix = array_slice($seq, -($beam_norep - 1));
        $gesperrt = [];
        $grenze = count($seq) - $beam_norep + 1;
        for ($i = 0; $i < $grenze; $i++) {
            if (array_slice($seq, $i, $beam_norep - 1) === $praefix) {
                $gesperrt[$seq[$i + $beam_norep - 1]] = true;
            }
        }
        return $gesperrt;
    };
    fwrite(STDERR, "  > Beam-Bewertung: temp=$beam_temp min_p=$beam_minp rep=$beam_rep norepeat=$beam_norep top_k=$top_k (Breite $beam_width)\n");

    $c_tokens = [];
    $c_logits = [];
    for ($b = 0; $b < $beam_width; $b++) {
        $c_tokens[$b] = $ffi->new("int[" . $ctx_size . "]");
        $c_logits[$b] = $ffi->new("float[" . $vocab_size . "]");
    }

    // Initialer Forward Pass: Prompt auf jedem Beam-Slot identisch verdauen.
    foreach ($c_tokens as $b => $buf) {
        $ffi->cortex_reset_cache($states[$b]);
        foreach ($tokens as $i => $tok) {
            $buf[$i] = $tok;
        }
        $do_forward($states[$b], $buf, count($tokens), $c_logits[$b]);
    }
    $prompt_time = round((microtime(true) - $start_time) * 1000);
    fwrite(STDERR, "  > Prompt verdaut in {$prompt_time}ms (x$beam_width Beams). Beginne Beam-Synthese...\n");

    if (is_nan($c_logits[0][0])) {
        fwrite(STDERR, "\n🚨 [SYMBIO VETO] KERNEL PANIC: Cortex spuckt NaNs! Die Matriarchin hat korrupte Gewichte (Explodierte Gradienten beim Merge).\n");
        $beam_gen = [0 => []];
        $active = [];
        $finished = [['tokens' => [], 'score' => 0.0, 'len' => 0]];
    } else {
        $beam_gen = array_fill(0, $beam_width, []);   // generierte Tokens je Slot
        $beam_score = array_fill(0, $beam_width, 0.0); // kumulierte Log-Wahrscheinlichkeit je Slot
        $active = range(0, $beam_width - 1);
        $finished = []; // abgeschlossene Kandidaten: ['tokens'=>[], 'score'=>float, 'len'=>int]

        for ($step = 0; $step < $max_new_tokens; $step++) {
            if (empty($active)) break;

            $step_len = count($tokens) + count($beam_gen[$active[0]]); // alle aktiven Beams gleich lang
            if ($step_len >= $ctx_size - 1) break; // Kontextfenster voll -> Rest als "aktiv am Cutoff" unten uebernehmen

            // Runde 0: alle Slots tragen noch den identischen Prompt-Forward-Pass ->
            // nur EINEN Slot als Quelle nehmen, sonst B identische Kandidatensaetze.
            $sources = ($step === 0) ? [$active[0]] : $active;

            $candidates = [];
            foreach ($sources as $slot) {
                if (is_nan($c_logits[$slot][0])) {
                    fwrite(STDERR, "\n🚨 [SYMBIO VETO] KERNEL PANIC: Cortex spuckt NaNs (Beam-Slot $slot)!\n");
                    continue;
                }
                $recent = array_slice(array_merge($tokens, $beam_gen[$slot]), -$repetition_window);
                $logprobs = beam_topk_logprobs($c_logits[$slot], $vocab_size, $beam_temp, $beam_rep, $recent, $beam_minp, $top_k);
                $sperre = $gesperrte_tokens($beam_gen[$slot]);
                // Kopiersperre (SNAI_KOPIE_F_DEFAULT): laengste Uebereinstimmung des Endstuecks von Prompt+Erzeugtem
                // mit einer frueheren Stelle (bis 16 Token, juengste bei Gleichstand); Kandidat = das Token danach.
                if ($kopie_f !== null) {
                    $kx = array_merge($tokens, $beam_gen[$slot]); $kt = count($kx);
                    $bk = 0; $bj = -1;
                    for ($kp = $kt - 2; $kp >= 0; $kp--) {
                        if ($kx[$kp] !== $kx[$kt - 1]) continue;
                        $kk = 1;
                        while ($kk < 16 && $kp - $kk >= 0 && $kx[$kp - $kk] === $kx[$kt - 1 - $kk]) $kk++;
                        if ($kk > $bk) { $bk = $kk; $bj = $kp + 1; }
                        if ($bk >= 16) break;
                    }
                    if ($bk >= 1) {
                        $fk = $kopie_f[$bk >= 8 ? 4 : ($bk >= 4 ? 3 : $bk - 1)];
                        if (mt_rand() / mt_getrandmax() >= $fk) {
                            if ($kopie_promptfrei && isset($kopie_pbi[$kx[$kt - 1] . ',' . $kx[$bj]])) $kopie_zaehler[2]++;
                            else { $sperre[$kx[$bj]] = true; $kopie_zaehler[0]++; }
                        }
                        $kopie_zaehler[1]++;
                    }
                }
                foreach ($logprobs as $tok => $lp) {
                    if (isset($sperre[$tok])) continue;
                    $candidates[] = ['src' => $slot, 'tok' => $tok, 'score' => $beam_score[$slot] + $lp];
                }
            }
            if (empty($candidates)) break;

            usort($candidates, fn($a, $b) => $b['score'] <=> $a['score']);

            // Kandidaten in "beendet" (Stop-Token / Halluzinations-Fang) und
            // "wird fortgesetzt" trennen. Ein Stop braucht keinen physischen
            // Slot-Umbau - der Tokenverlauf des Elternpfads reicht zur Bewertung.
            //
            // BIS 2026-09-07 lief das ueber genau count($active) Kandidaten.
            // Damit nahm jeder Stopp-Token seinen Slot dauerhaft mit: die
            // Suchbreite konnte nur fallen, nie zurueckkommen, und nach dem
            // ersten Satzende lief die Suche als Greedy weiter. Jetzt wird ein
            // Pool von 2k durchgegangen:
            //   - ein Stopp zaehlt nur dann als Abschluss, wenn er unter den
            //     besten k liegt (sonst wuerden beliebig viele kurze Stummel
            //     in die Siegerauswahl geraten),
            //   - fortgesetzt werden die ersten k Nicht-Stopps, unabhaengig
            //     davon, wie viele Stopps vor ihnen lagen.
            // Die Breite bleibt damit erhalten, solange der Pool k Nicht-Stopps
            // hergibt. Siehe docs/PRODUKTIVLAUF_DIM512.md §15.
            $breite = count($active);
            $pool = array_slice($candidates, 0, min(2 * $breite, count($candidates)));

            // SNAI_BEAM_TRACE=1 zeigt, ob der Beam seine Breite ueberhaupt
            // haelt. Genau diese Spur hat den Defekt vom 2026-09-07 sichtbar
            // gemacht: "aktiv 3 | Kandidaten 2" in Schritt 0 heisst, dass die
            // Suche nie drei Pfade hatte, egal was beam_width sagt.
            $trace = getenv('SNAI_BEAM_TRACE') === '1';

            $continue_picks = [];
            foreach ($pool as $rang => $p) {
                $is_stop = in_array($p['tok'], $stop_tokens, true);
                if (!$is_stop) {
                    $word = $tokenizer->decode([$p['tok']]);
                    if (strpos($word, "[USER]") !== false) $is_stop = true;
                }
                if ($is_stop) {
                    if ($rang < $breite) {
                        $finished[] = [
                            'tokens' => $beam_gen[$p['src']],
                            'score' => $p['score'],
                            'len' => count($beam_gen[$p['src']]),
                        ];
                    }
                } elseif (count($continue_picks) < $breite) {
                    $continue_picks[] = $p;
                }
            }

            if ($trace) {
                fwrite(STDERR, sprintf("[BEAM-SPUR] Schritt %3d | aktiv %d | Kandidaten %2d | Pool %2d | fortgesetzt %d | beendet gesamt %d\n",
                    $step, $breite, count($candidates), count($pool), count($continue_picks), count($finished)));
            }

            if (empty($continue_picks)) { $active = []; break; }

            // Physische Slot-Zuordnung: erste Wiederverwendung eines Quell-Slots
            // laeuft in-place (Cache schon synchron, nur 1 Token anhaengen).
            // Jede weitere Verwendung derselben Quelle (Fork) braucht einen
            // freien Slot + vollstaendigen Replay ihres Tokenverlaufs.
            $reuse_idx_for_src = [];
            foreach ($continue_picks as $idx => $p) {
                if (!isset($reuse_idx_for_src[$p['src']])) {
                    $reuse_idx_for_src[$p['src']] = $idx;
                }
            }
            $used_as_src = array_values(array_unique(array_column($continue_picks, 'src')));
            $free_pool = array_values(array_diff($active, $used_as_src));

            $new_beam_gen = [];
            $new_beam_score = [];
            $new_active = [];

            foreach ($continue_picks as $idx => $p) {
                $tok = $p['tok'];
                if ($reuse_idx_for_src[$p['src']] === $idx) {
                    // In-Place: Cache ist bereits exakt auf $p['src']'s Verlauf synchron.
                    $slot = $p['src'];
                    $c_tokens[$slot][0] = $tok;
                    $do_forward($states[$slot], $c_tokens[$slot], 1, $c_logits[$slot]);
                } else {
                    // Fork: freien Slot per Replay auf den neuen Pfad synchronisieren.
                    $slot = array_shift($free_pool);
                    if ($slot === null) {
                        // Kann bei intakter Buchhaltung nicht eintreten
                        // (count($continue_picks) <= count($active)). Wenn doch,
                        // dann lieber laut abbrechen als auf $states[null]
                        // zugreifen und eine plausible falsche Ausgabe liefern.
                        fwrite(STDERR, "\n🚨 [BEAM] Kein freier Slot fuer Fork - Slot-Buchhaltung defekt.\n");
                        exit(1);
                    }
                    $ffi->cortex_reset_cache($states[$slot]);
                    $replay = array_merge($tokens, $beam_gen[$p['src']], [$tok]);
                    foreach ($replay as $ri => $rt) {
                        $c_tokens[$slot][$ri] = $rt;
                    }
                    $do_forward($states[$slot], $c_tokens[$slot], count($replay), $c_logits[$slot]);
                }

                $new_beam_gen[$slot] = array_merge($beam_gen[$p['src']], [$tok]);
                $new_beam_score[$slot] = $p['score'];
                $new_active[] = $slot;
            }

            $beam_gen = $new_beam_gen;
            $beam_score = $new_beam_score;
            $active = $new_active;
        }

        // Beams, die bis zum Token-/Kontextlimit durchliefen ohne Stop-Token,
        // zaehlen ebenfalls als Abschluss-Kandidaten (nur eben unbeendet).
        foreach ($active as $slot) {
            $finished[] = ['tokens' => $beam_gen[$slot], 'score' => $beam_score[$slot], 'len' => count($beam_gen[$slot])];
        }
    }

    // Gewinner: hoechste laengenbestrafte Log-Wahrscheinlichkeit.
    //
    // BIS 2026-09-06 stand hier der glatte Schnitt $f['score'] / $f['len'].
    // Der Kommentar behauptete, das verhindere, dass kurze Pfade allein durch
    // Kuerze gewinnen - er tat das Gegenteil. Der Schnitt pro Token belohnt
    // genau die kurzen, sehr sicheren Pfade: auf prod512_s1 gewann der Pfad
    // "." mit Score/Token -0,321 gegen -0,4869 einer 1011-Zeichen-Fortsetzung.
    //
    // Jetzt die Laengenstrafe nach Wu et al. 2016 (GNMT, Abschnitt 7):
    //     lp(Y)  = ((5 + |Y|) / 6) ^ alpha
    //     score' = logP(Y) / lp(Y)
    //
    // alpha = 0   : keine Normalisierung, die rohe kumulierte Log-Wahrschein-
    //               lichkeit entscheidet - kurze Pfade gewinnen fast immer.
    // alpha = 1   : ungefaehr das alte Verhalten (Schnitt pro Token).
    // alpha > 1   : lp waechst schneller als die Laenge. Ein negativer Score
    //               wird durch eine groessere Zahl geteilt, wird also WENIGER
    //               negativ - laengere Pfade gewinnen. Das ist die Richtung,
    //               die den "."-Abbruch behebt.
    //
    // Die 5 und die 6 sind die Konstanten aus der Veroeffentlichung; sie
    // daempfen die Strafe bei sehr kurzen Sequenzen, damit lp(1) nicht 0 wird.
    //
    // Der Default steht in SNAI_BEAM_ALPHA_DEFAULT (siehe Kopf der Datei) und
    // gilt fuer ALLE Aufrufer, dashboard.php eingeschlossen - bewusst, siehe
    // docs/PRODUKTIVLAUF_DIM512.md §13.
    $beam_alpha_env = snai_env_zahl('SNAI_BEAM_ALPHA');
    $beam_alpha = ($beam_alpha_env === null) ? SNAI_BEAM_ALPHA_DEFAULT : $beam_alpha_env;
    if ($beam_alpha < 0) $beam_alpha = 0.0;

    $winner = null;
    $winner_norm = -INF;
    foreach ($finished as $f) {
        $len = max(1, $f['len']);
        $lp   = pow((5.0 + $len) / 6.0, $beam_alpha);
        $norm = $f['score'] / $lp;
        if ($norm > $winner_norm) {
            $winner_norm = $norm;
            $winner = $f;
        }
    }

    // SNAI_BEAM_DUMP=1 legt die Kandidatenliste offen (Rohscore und Laenge),
    // damit sich alpha aus Messwerten waehlen laesst statt aus dem Gefuehl.
    // Ohne die Rohwerte sieht man nur den Sieger und nicht, wie knapp er war.
    if (getenv('SNAI_BEAM_DUMP') === '1') {
        fwrite(STDERR, "\n[BEAM-DUMP] alpha=$beam_alpha, " . count($finished) . " Kandidaten:\n");
        foreach ($finished as $i => $f) {
            $len = max(1, $f['len']);
            $lp  = pow((5.0 + $len) / 6.0, $beam_alpha);
            fwrite(STDERR, sprintf(
                "[BEAM-DUMP]  #%d len=%d score=%.4f schnitt=%.4f lp=%.4f norm=%.4f%s\n",
                $i, $f['len'], $f['score'], $f['score'] / $len, $lp, $f['score'] / $lp,
                ($f === $winner ? "  <== SIEGER" : "")
            ));
        }
    }

    $generated_text = $winner ? $tokenizer->decode($winner['tokens']) : "";
    echo $generated_text;

    fwrite(STDERR, "\n[⚙️ Metrik: " . mb_strlen($generated_text) . " Chars generiert, " . count($finished) . " Beam-Kandidaten verglichen, Laenge=" . ($winner['len'] ?? 0) . " Token, alpha=" . $beam_alpha . ", Score/lp=" . round($winner_norm, 4) . "]\n");
    if ($kopie_f !== null) fwrite(STDERR, "[KOPIE] Kandidaten {$kopie_zaehler[1]}, gesperrt {$kopie_zaehler[0]}, prompt-frei {$kopie_zaehler[2]}\n");
}

foreach ($states as $s) {
    $ffi->cortex_free($s);
}
