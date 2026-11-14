<?php
// NIM-WEG fuer INT8 (2026-11-08, messbuch snai/merge-int8-nim): (de)quantisieren und mischen rechnet
// libtensorutils.so, sonst die *_php-Fassungen unten (Rueckfall, SNAI_TENSORUTILS_PHP=1 erzwingt sie).
require_once __DIR__ . '/tensor_utils_ffi.php';
// Dateiname: tensor_io.php
// Funktion: Behandelt das Laden (Header) und Speichern (Stream) von Tensormodellen (Zero OOM).

/**
 * SYMBIO NANO-AI FRAMEWORK (Code-4372)
 * Modul: Tensor I/O (Phase VIII - The Adam Persistence Update)
 * -------------------------------------------------------------------------
 * MAXIME: E > H. PHP liest nur noch den 28-Byte Header.
 * AUDIT-FIX: rtrim für Magic-Bytes, Filesize-Precheck, Race-Condition bei mkdir.
 * UPDATE (Phase VIII): Magic-Byte auf SNAI_V5 angehoben. Speichert nun neben 
 * den Gewichten (w) auch nahtlos das Momentum (m) und die Varianz (v) von Adam!
 */

// Neuer Magic-String trennt V4-Gewichte von V5-Gedächtnis-Modellen
define('SNAI_MAGIC', 'SNAI_V5');
define('SNAI_HEADER_SIZE', 28); // 8 Bytes Magic + 20 Bytes Parameter

/**
 * INT8-Erweiterung (SNAI_V6), Projekt-Vision "Der INT8 Nano-Tensor".
 * Phase 1: nur Format + Referenz-Quantisierung, NICHT in den Trainings-/Inferenz-Pfad
 * verdrahtet (cortex_load_stream() kennt SNAI_V6 noch nicht - das ist Phase 2).
 * Die 8 Gewichtstypen in SNAI_INT8_TENSOR_TYPES werden zeilenweise (Per-Ausgabe-Kanal)
 * symmetrisch auf INT8 (-128..127) quantisiert, ein Float32-Skalenfaktor pro Zeile.
 * RMSNorm-Gains (rms_final/rms_att/rms_ffn) und - sobald Adam-Zustand in V6 dazukommt -
 * m/v bleiben immer Float32 (Design-Entscheidung #2/#7 im Plan).
 */
define('SNAI_MAGIC_V6', 'SNAI_V6');
define('SNAI_HEADER_SIZE_V6', 32); // 8 Bytes Magic + 20 Bytes Parameter + 4 Bytes dtype_version
define('SNAI_DTYPE_FP32', 0);
define('SNAI_DTYPE_INT8', 1);

/**
 * SNAI_V7 (2026-08-29) - Weight Tying.
 *
 * Anlass: das A/B des Hauptzweigs hat Weight Tying in allen vier Epochen
 * gewinnen sehen (gebundener Arm mit 2,6 % weniger Parametern besser, Abstand
 * monoton wachsend). Der erwartete GROESSENVORTEIL blieb aber aus - im
 * Gegenteil, die gebundene Datei war mit 41,7 MB groesser als die ungebundene
 * mit 29,9 MB, weil SNAI_V6 den `w_out`-Block trotz Bindung redundant
 * mitschreibt. V7 raeumt genau das weg.
 *
 * Layout = V6 plus ein 4-Byte-Flags-Feld am Header-Ende (deshalb 36 statt 32
 * Bytes). Ist SNAI_FLAG_TIED_EMBEDDINGS gesetzt, FEHLT der komplette
 * w_out-Block (Skalen + Daten + m + v) in der Datei; w_out ist dann per
 * Definition dasselbe Gewicht wie `embeddings` (nicht eine Kopie davon - siehe
 * cortex.nim, `tiedEmbeddings`).
 *
 * Bewusst ein FLAGS-Feld statt eines eigenen Magic je Variante: V7 kann beide
 * Faelle ausdruecken (gebunden und ungebunden), und kuenftige Formatvarianten
 * brauchen kein drittes Magic. Das Feld ist absichtlich hinter dtype_version
 * angehaengt, damit ein FP32-Zweig dasselbe Layout mit dtype_version=0 nutzen
 * kann - der Hauptzweig uebernimmt dieses Muster.
 */
define('SNAI_MAGIC_V7', 'SNAI_V7');
define('SNAI_HEADER_SIZE_V7', 36); // V6-Header + 4 Bytes flags
define('SNAI_FLAG_TIED_EMBEDDINGS', 1);

/**
 * EMB-EINGANG (2026-11-03, messbuch snai/engine-emb-eingang): Bit 1 = Embedding-Eingangsfaktor. Die Engine
 * multipliziert das gebundene Embedding am EINGANG mit sqrt(hidden_dim), die Ausgabeseite (w_out) nicht. Nur
 * zusammen mit Bit 0. Eigenschaft des MODELLS: ein mit Faktor trainiertes Modell ohne ihn gerechnet ist zerstoert.
 * Jeder Leser/Schreiber muss das Bit erhalten oder laut abbrechen, nie still verwerfen. Fremde Bits: Abbruch.
 */
define('SNAI_FLAG_EMB_EINGANG', 2);
define('SNAI_V7_FLAGS_BEKANNT', SNAI_FLAG_TIED_EMBEDDINGS | SNAI_FLAG_EMB_EINGANG);

/** Fehlertext, wenn V7-Flags ungueltig sind (unbekannte Bits, Bit 1 ohne Bit 0), sonst null. */
function snai_v7_flags_fehler(int $flags): ?string {
    if (($flags & ~SNAI_V7_FLAGS_BEKANNT) !== 0) {
        return "SNAI_V7-Flags $flags enthalten unbekannte Bits (bekannt: " . SNAI_V7_FLAGS_BEKANNT . ")";
    }
    if (($flags & SNAI_FLAG_EMB_EINGANG) && !($flags & SNAI_FLAG_TIED_EMBEDDINGS)) {
        return "SNAI_V7-Flags $flags: Bit 1 (Embedding-Eingangsfaktor) ohne Bit 0 (Tying)";
    }
    return null;
}

/** true, wenn Header oder State den Embedding-Eingangsfaktor tragen (Flags Bit 1). */
function snai_emb_eingang(array $header_oder_state): bool {
    return ((int)($header_oder_state['flags'] ?? 0) & SNAI_FLAG_EMB_EINGANG) !== 0;
}

/**
 * Reihenfolge der GLOBALEN Tensoren im Datei-Layout, abhaengig von den Flags.
 * Einzige Wahrheitsquelle - alle Leser/Schreiber/Bilanzrechner fragen hier,
 * statt die Liste ein zehntes Mal auszuschreiben (vor V7 stand sie woertlich
 * an neun Stellen, was genau die Art von Drift einlaedt, die ein Formatumbau
 * nicht gebrauchen kann).
 */
function snai_global_types(int $flags): array {
    return ($flags & SNAI_FLAG_TIED_EMBEDDINGS)
        ? ['embeddings', 'rms_final']
        : ['embeddings', 'w_out', 'rms_final'];
}

/** Reihenfolge der Tensoren INNERHALB eines Layers - in V5/V6/V7 identisch. */
function snai_layer_types(): array {
    return ['rms_att', 'rms_ffn', 'w_q', 'w_k', 'w_v', 'w_o', 'w_up', 'w_down'];
}

/** true, wenn dieses Magic ein INT8-Format mit Skalen-Bloecken ist (V6 oder V7). */
function snai_is_int8_magic(string $magic): bool {
    return $magic === SNAI_MAGIC_V6 || $magic === SNAI_MAGIC_V7;
}

/* =============================================================================
 * SNAILORA - Adapterdatei (2026-08-29)
 * -----------------------------------------------------------------------------
 * BEWUSST EINE EIGENE DATEI NEBEN DEM BASISMODELL, kein neues Modellformat:
 * bei eingefrorener Basis ist die Basisdatei bitgenau die alte. Sie ein zweites
 * Mal zu schreiben, nur um ein paar Adapter unterzubringen, waere bei 57 MB je
 * Checkpoint pure Verschwendung - und es wuerde die Zusage verwischen, dass die
 * Basis unangetastet bleibt. Eine Adapterdatei bei Rang 8 ist 1,7 MB.
 *
 * DIE WICHTIGSTE KOPFZEILE IST DER BASIS-FINGERABDRUCK. Ein Adapter, der auf
 * die falsche Basis gelegt wird, stuerzt nicht ab - er rechnet plausiblen
 * Unsinn. Deshalb steht die md5 der Basisdatei im Header und wird beim Laden
 * geprueft.
 *
 * Layout (Little-Endian, wie V5/V6/V7):
 *   0   8   Magic "SNAILORA" (nullgepolstert)
 *   8   4   format_version (=1)
 *  12   4   rank
 *  16   4   slot_mask
 *  20   4   num_layers
 *  24   4   hidden_dim
 *  28   4   ffn_dim
 *  32   4   vocab_size
 *  36   4   flags   (Bit 0 = Adam-Bloecke vorhanden)
 *  40   4   adam_t
 *  44   4   alpha   (float32)
 *  48  16   md5 der Basisdatei (roh)
 *  64  64   Dateiname der Basis (nullgepolstert, nur Diagnose)
 * 128       Nutzdaten
 *
 * Nutzdaten: erst ALLE Gewichte (je Slot A dann B, Slots aufsteigend, Layer
 * aufsteigend), danach - falls Bit 0 - ALLE Momente in derselben Reihenfolge
 * (m_A, v_A, m_B, v_B). Weil die Gewichte vorn stehen, ist eine Adam-freie
 * Datei ein echtes PRAEFIX der vollen - dasselbe Prinzip wie beim
 * Adam-freien SNAI_V6-Deployment-Artefakt.
 * ========================================================================== */
define('SNAI_MAGIC_LORA', 'SNAILORA');
define('SNAI_LORA_HEADER_SIZE', 128);
define('SNAI_LORA_FORMAT_VERSION', 1);
define('SNAI_LORA_FLAG_ADAM', 1);
define('SNAI_LORA_SLOTS', 6);

/** Slot-Namen in der Reihenfolge der Slot-Nummern aus cortex.nim. */
function snai_lora_slot_names(): array {
    return ['w_q', 'w_k', 'w_v', 'w_o', 'w_up', 'w_down'];
}

/** (rows, cols) des Basisgewichts eines Slots. */
function snai_lora_slot_shape(int $slot, int $dim, int $ffn): array {
    return match ($slot) {
        0, 1, 2, 3 => [$dim, $dim],
        4          => [$ffn, $dim],
        5          => [$dim, $ffn],
        default    => [0, 0],
    };
}

/** Elementzahl von A ($is_b=false) bzw. B ($is_b=true). */
function snai_lora_slot_size(int $slot, bool $is_b, int $rank, int $dim, int $ffn): int {
    [$rows, $cols] = snai_lora_slot_shape($slot, $dim, $ffn);
    return $is_b ? $rows * $rank : $rank * $cols;
}

/** Erwartete Dateigroesse in Bytes - dieselbe Rolle wie snai_v6_expected_sizes(). */
function snai_lora_expected_size(int $rank, int $mask, int $layers, int $dim,
                                 int $ffn, bool $with_adam): int {
    $per = 0;
    for ($s = 0; $s < SNAI_LORA_SLOTS; $s++) {
        if (($mask & (1 << $s)) === 0) continue;
        $per += snai_lora_slot_size($s, false, $rank, $dim, $ffn);
        $per += snai_lora_slot_size($s, true,  $rank, $dim, $ffn);
    }
    // Faktor 3, nicht 5: je Matrix (A und B) steht ein Gewicht und je ein
    // m- und ein v-Moment in der Datei. $per zaehlt A und B bereits zusammen.
    $floats = $layers * $per * ($with_adam ? 3 : 1);
    return SNAI_LORA_HEADER_SIZE + $floats * 4;
}

/**
 * Der Adapter zu `X.snai` heisst `X.lora` - eine Konvention, damit Basis und
 * Adapter nicht ueber getrennte Parameter auseinanderlaufen koennen.
 */
function snai_lora_path(string $model_path): string {
    if (preg_match('/\.snai$/i', $model_path)) {
        return preg_replace('/\.snai$/i', '.lora', $model_path);
    }
    return $model_path . '.lora';
}

function load_lora_header(string $filepath): ?array {
    if (!file_exists($filepath)) return null;
    $fp = fopen($filepath, 'rb');
    if (!$fp) return null;
    $head = fread($fp, SNAI_LORA_HEADER_SIZE);
    fclose($fp);
    if (strlen($head) !== SNAI_LORA_HEADER_SIZE) {
        echo "🚨 [LoRA-I/O] Unvollstaendiger Header in $filepath\n";
        return null;
    }
    if (rtrim(substr($head, 0, 8), "\0") !== SNAI_MAGIC_LORA) {
        echo "🚨 [LoRA-I/O] Kein SNAILORA-Magic in $filepath\n";
        return null;
    }
    $h = unpack('Vformat_version/Vrank/Vmask/Vnum_layers/Vhidden_dim/Vffn_dim/'
              . 'Vvocab_size/Vflags/Vadam_t/falpha', substr($head, 8, 40));
    $h['base_md5']  = bin2hex(substr($head, 48, 16));
    $h['base_name'] = rtrim(substr($head, 64, 64), "\0");
    $h['has_adam']  = ($h['flags'] & SNAI_LORA_FLAG_ADAM) !== 0;
    $h['magic']     = SNAI_MAGIC_LORA;
    return $h;
}

function save_lora_stream(array $lora, string $filepath, string $base_path): bool {
    $need = ['rank', 'mask', 'num_layers', 'hidden_dim', 'ffn_dim', 'vocab_size',
             'adam_t', 'tensors'];
    foreach ($need as $k) {
        if (!array_key_exists($k, $lora)) {
            echo "🚨 [LoRA-I/O] Feld '$k' fehlt im Adapterzustand.\n";
            return false;
        }
    }
    if (!file_exists($base_path)) {
        echo "🚨 [LoRA-I/O] Basismodell nicht gefunden: $base_path\n";
        return false;
    }
    $with_adam = !empty($lora['has_adam']);
    $alpha = (float)($lora['alpha'] ?? $lora['rank']);

    $fp = fopen($filepath, 'wb');
    if (!$fp) { echo "🚨 [LoRA-I/O] Kann $filepath nicht schreiben.\n"; return false; }

    fwrite($fp, str_pad(SNAI_MAGIC_LORA, 8, "\0"));
    fwrite($fp, pack('VVVVVVVVV',
        SNAI_LORA_FORMAT_VERSION, $lora['rank'], $lora['mask'], $lora['num_layers'],
        $lora['hidden_dim'], $lora['ffn_dim'], $lora['vocab_size'],
        $with_adam ? SNAI_LORA_FLAG_ADAM : 0, $lora['adam_t']));
    fwrite($fp, pack('f', $alpha));
    fwrite($fp, md5_file($base_path, true));                  // 16 Bytes roh
    fwrite($fp, str_pad(substr(basename($base_path), 0, 63), 64, "\0"));

    // Erst alle Gewichte, dann alle Momente - siehe Praefix-Begruendung oben.
    $blocks = $with_adam ? [['a', 'b'], ['ma', 'va', 'mb', 'vb']] : [['a', 'b']];
    foreach ($blocks as $keys) {
        for ($l = 0; $l < $lora['num_layers']; $l++) {
            for ($s = 0; $s < SNAI_LORA_SLOTS; $s++) {
                if (($lora['mask'] & (1 << $s)) === 0) continue;
                $entry = $lora['tensors']["$l.$s"] ?? null;
                if ($entry === null) {
                    fclose($fp); @unlink($filepath);
                    echo "🚨 [LoRA-I/O] Adapter $l.$s fehlt im Zustand - halbe Datei waere schlimmer als keine.\n";
                    return false;
                }
                foreach ($keys as $k) {
                    $is_b = str_ends_with($k, 'b');
                    $n = snai_lora_slot_size($s, $is_b, $lora['rank'], $lora['hidden_dim'], $lora['ffn_dim']);
                    if (!isset($entry[$k]) || strlen($entry[$k]) !== $n * 4) {
                        fclose($fp); @unlink($filepath);
                        echo "🚨 [LoRA-I/O] Block '$k' von Adapter $l.$s hat die falsche Groesse.\n";
                        return false;
                    }
                    fwrite($fp, $entry[$k]);
                }
            }
        }
    }
    fclose($fp);

    $expect = snai_lora_expected_size((int)$lora['rank'], (int)$lora['mask'],
                  (int)$lora['num_layers'], (int)$lora['hidden_dim'],
                  (int)$lora['ffn_dim'], $with_adam);
    $got = filesize($filepath);
    if ($got !== $expect) {
        echo "🚨 [LoRA-I/O] Groessenbilanz stimmt nicht: $got statt $expect Bytes.\n";
        return false;
    }
    return true;
}

/**
 * Liest eine Adapterdatei. $base_path ist NICHT optional: ohne die Basis laesst
 * sich der Fingerabdruck nicht pruefen, und ein Adapter auf der falschen Basis
 * ist genau der Fehler, den man nicht bemerkt. SNAI_LORA_IGNORE_BASE=1 hebt die
 * Pruefung auf - fuer den Fall, dass jemand die Basis bewusst ersetzt.
 */
/**
 * Verschmilzt die Adapterdateien mehrerer Arbeiter elementweise (Mittelwert) -
 * das Gegenstueck zu merge_v6_models() fuer die Adapterschicht.
 *
 * EHRLICHER VORBEHALT, der in jede Auswertung gehoert: der Mittelwert von A und
 * der Mittelwert von B ergeben NICHT den Mittelwert von B·A. Bei zwei Arbeitern
 * mit gegenlaeufigen Adaptern kann das Produkt der Mittel deutlich neben dem
 * Mittel der Produkte liegen. Fuer volle Gewichte macht dieses Projekt genau
 * dasselbe (Federated Averaging ist immer eine Naeherung) - bei einem
 * Niedrigrang-Produkt ist die Naeherung aber prinzipiell schlechter. Wer im A/B
 * mehrere Arbeiter fahren will, sollte das mitmessen, nicht voraussetzen.
 *
 * Kopfzeilen muessen exakt uebereinstimmen, einschliesslich des
 * Basis-Fingerabdrucks: Adapter zu verschiedenen Basen zu mitteln waere in
 * jeder Rolle falsch.
 */
function merge_lora_files(array $files, string $out_path): bool {
    if (empty($files)) return false;
    $heads = [];
    foreach ($files as $f) {
        $h = load_lora_header($f);
        if ($h === null) return false;
        $heads[] = $h;
    }
    $ref = $heads[0];
    foreach ($heads as $i => $h) {
        foreach (['rank', 'mask', 'num_layers', 'hidden_dim', 'ffn_dim', 'vocab_size',
                  'flags', 'base_md5'] as $k) {
            if ($h[$k] !== $ref[$k]) {
                echo "🚨 [LoRA-Merge] '$k' unterscheidet sich zwischen {$files[0]} und {$files[$i]}"
                   . " - Adapter aus verschiedenen Laeufen lassen sich nicht mitteln.\n";
                return false;
            }
        }
    }
    if (count($files) === 1) return @copy($files[0], $out_path);

    $n = count($files);
    $handles = [];
    foreach ($files as $f) {
        $fp = fopen($f, 'rb');
        if (!$fp) { foreach ($handles as $x) fclose($x); return false; }
        fseek($fp, SNAI_LORA_HEADER_SIZE);
        $handles[] = $fp;
    }
    $outFp = fopen($out_path, 'wb');
    if (!$outFp) { foreach ($handles as $x) fclose($x); return false; }

    // Header der ersten Datei uebernehmen - adam_t inklusive. Er ist bei allen
    // Arbeitern gleich, weil sie denselben Ausgangszustand und dieselbe
    // Schrittzahl haben; unterschieden sie sich, waere das ein Fehler weiter
    // oben und kein Fall fuer eine Mittelung.
    $hFp = fopen($files[0], 'rb');
    fwrite($outFp, fread($hFp, SNAI_LORA_HEADER_SIZE));
    fclose($hFp);

    $CHUNK = 8192 * 4;   // 8192 Floats je Runde
    while (true) {
        $bufs = [];
        foreach ($handles as $fp) $bufs[] = fread($fp, $CHUNK);
        $len = strlen($bufs[0]);
        if ($len === 0) break;
        foreach ($bufs as $b) {
            if (strlen($b) !== $len) {
                fclose($outFp); @unlink($out_path);
                foreach ($handles as $x) fclose($x);
                echo "🚨 [LoRA-Merge] Dateien laufen unterschiedlich weit - abgebrochen.\n";
                return false;
            }
        }
        $acc = array_values(unpack('g*', $bufs[0]));
        for ($m = 1; $m < $n; $m++) {
            $cur = array_values(unpack('g*', $bufs[$m]));
            foreach ($cur as $i => $v) $acc[$i] += $v;
        }
        foreach ($acc as $i => $v) $acc[$i] = $v / $n;
        fwrite($outFp, pack('g*', ...$acc));
    }
    fclose($outFp);
    foreach ($handles as $x) fclose($x);

    if (filesize($out_path) !== filesize($files[0])) {
        echo "🚨 [LoRA-Merge] Groessenbilanz stimmt nicht.\n";
        return false;
    }
    return true;
}

/**
 * Schreibt den Basis-Fingerabdruck einer Adapterdatei neu.
 *
 * Gebraucht wird das an genau EINER Stelle: nach dem Cluster-Merge. Die
 * verschmolzene Adapterdatei gehoert zur verschmolzenen Basis, nicht mehr zur
 * Basis irgendeines einzelnen Arbeiters - der Fingerabdruck aus dem Kopf der
 * ersten Quelldatei waere dort schlicht falsch.
 *
 * Das ist bewusst eine BEHAUPTUNG statt einer Pruefung, und deshalb steht sie
 * hier als eigene, benannte Funktion und nicht versteckt im Merge: wer sie
 * aufruft, uebernimmt die Verantwortung dafuer, dass die neue Basis wirklich
 * die richtige ist.
 */
function snai_lora_restamp_base(string $lora_path, string $base_path): bool {
    if (!file_exists($lora_path) || !file_exists($base_path)) return false;
    $fp = fopen($lora_path, 'r+b');
    if (!$fp) return false;
    fseek($fp, 48);
    $ok = fwrite($fp, md5_file($base_path, true)) === 16;
    fseek($fp, 64);
    $ok = $ok && fwrite($fp, str_pad(substr(basename($base_path), 0, 63), 64, "\0")) === 64;
    fclose($fp);
    return $ok;
}

function load_lora_stream(string $filepath, string $base_path): ?array {
    $h = load_lora_header($filepath);
    if ($h === null) return null;
    if ($h['format_version'] !== SNAI_LORA_FORMAT_VERSION) {
        echo "🚨 [LoRA-I/O] Unbekannte Formatversion {$h['format_version']}.\n";
        return null;
    }
    if (getenv('SNAI_LORA_IGNORE_BASE') !== '1') {
        if (!file_exists($base_path)) {
            echo "🚨 [LoRA-I/O] Basismodell nicht gefunden: $base_path\n";
            return null;
        }
        $actual = md5_file($base_path);
        if ($actual !== $h['base_md5']) {
            echo "🚨 [LoRA-I/O] Der Adapter gehoert zu einer ANDEREN Basis.\n"
               . "   Datei erwartet {$h['base_md5']} ({$h['base_name']}),\n"
               . "   vorgelegt wurde $actual (" . basename($base_path) . ").\n"
               . "   Ein Adapter auf der falschen Basis stuerzt nicht ab, er rechnet Unsinn.\n"
               . "   SNAI_LORA_IGNORE_BASE=1 setzt die Pruefung ausser Kraft.\n";
            return null;
        }
    }
    $expect = snai_lora_expected_size($h['rank'], $h['mask'], $h['num_layers'],
                  $h['hidden_dim'], $h['ffn_dim'], $h['has_adam']);
    $got = filesize($filepath);
    if ($got !== $expect) {
        echo "🚨 [LoRA-I/O] Groessenbilanz stimmt nicht: $got statt $expect Bytes.\n";
        return null;
    }

    $fp = fopen($filepath, 'rb');
    if (!$fp) return null;
    fseek($fp, SNAI_LORA_HEADER_SIZE);
    $lora = $h;
    $lora['tensors'] = [];
    $blocks = $h['has_adam'] ? [['a', 'b'], ['ma', 'va', 'mb', 'vb']] : [['a', 'b']];
    foreach ($blocks as $keys) {
        for ($l = 0; $l < $h['num_layers']; $l++) {
            for ($s = 0; $s < SNAI_LORA_SLOTS; $s++) {
                if (($h['mask'] & (1 << $s)) === 0) continue;
                foreach ($keys as $k) {
                    $is_b = str_ends_with($k, 'b');
                    $n = snai_lora_slot_size($s, $is_b, $h['rank'], $h['hidden_dim'], $h['ffn_dim']);
                    $bin = fread($fp, $n * 4);
                    if ($bin === false || strlen($bin) !== $n * 4) {
                        fclose($fp);
                        echo "🚨 [LoRA-I/O] Datei bricht bei Adapter $l.$s / '$k' ab.\n";
                        return null;
                    }
                    $lora['tensors']["$l.$s"][$k] = $bin;
                }
            }
        }
    }
    fclose($fp);
    return $lora;
}

// ACHTUNG - ZWEI VERSCHIEDENE dtype-Zahlenraeume, nicht verwechseln:
// SNAI_DTYPE_* oben = internes dtype_version-Feld im SNAI_V6-Dateiheader.
// SNAI_CLI_DTYPE_* unten = der $dtype/$target_dtype-CLI-Parameter von
// train_worker.php/train_cluster.php - historisch identisch zu
// SnaiTensorUtils' Merge-dtype-Code (snai_tensor_utils.nim: SNAI_TYPE_FP32=1,
// SNAI_TYPE_FP16=2 - deshalb der bisherige Default 1 in train_cluster.php,
// obwohl das Argument bislang nirgends ausgewertet wurde). INT8 bekommt hier
// bewusst 3 (naechste freie Zahl in dieser Reihe), NICHT 1.
define('SNAI_CLI_DTYPE_INT8', 3);

const SNAI_INT8_TENSOR_TYPES = ['embeddings', 'w_out', 'w_q', 'w_k', 'w_v', 'w_o', 'w_up', 'w_down'];

/**
 * Liefert [rows, cols] fuer einen Tensor-Typ-Namen, gegeben die Modell-Geometrie.
 * Rows = Ausgabe-Kanal (die Achse, auf der die Per-Zeile-Skala liegt) - muss exakt
 * spiegeln, wie cortex.nim die Matrix im GEMM indiziert (out[r] = Sum_c W[r,c]*in[c]).
 */
function snai_tensor_shape(string $type, int $vocab, int $dim, int $ffn): array {
    switch ($type) {
        case 'embeddings':
        case 'w_out':   return [$vocab, $dim];
        case 'w_up':    return [$ffn, $dim];
        case 'w_down':  return [$dim, $ffn];
        case 'rms_final':
        case 'rms_att':
        case 'rms_ffn': return [1, $dim];
        default:        return [$dim, $dim]; // w_q, w_k, w_v, w_o
    }
}

/**
 * Quantisiert einen Float32-Tensor-Blob (row-major, 'g'-Format LE) zeilenweise nach
 * INT8. Symmetrisch: scale = max(|row|)/127, real_value(r,c) = int8[r,c] * scale[r].
 * Rueckgabe: ['data' => rows*cols Bytes signed INT8, 'scales' => rows Floats].
 */
function quantize_tensor_i8(string $binary, int $rows, int $cols): array {
    if (SnaiTensorUtils::verfuegbar()) return SnaiTensorUtils::i8_quant($binary, $rows, $cols);
    return quantize_tensor_i8_php($binary, $rows, $cols);
}

/** PHP-Fassung von quantize_tensor_i8() (Bezug fuer die Bytegleichheit des Nim-Wegs, Rueckfall). */
function quantize_tensor_i8_php(string $binary, int $rows, int $cols): array {
    $n = $rows * $cols;
    $floats = unpack("g{$n}", $binary); // 1-indexiert: Keys 1..n

    $data = '';
    $scales = [];
    for ($r = 0; $r < $rows; $r++) {
        $base = $r * $cols;
        $maxAbs = 0.0;
        for ($c = 1; $c <= $cols; $c++) {
            $a = abs($floats[$base + $c]);
            if ($a > $maxAbs) $maxAbs = $a;
        }
        $scale = $maxAbs > 0.0 ? ($maxAbs / 127.0) : 1.0;
        $scales[] = $scale;
        for ($c = 1; $c <= $cols; $c++) {
            $q = (int) round($floats[$base + $c] / $scale);
            if ($q > 127) $q = 127;
            elseif ($q < -128) $q = -128;
            $data .= pack('c', $q);
        }
    }
    return ['data' => $data, 'scales' => $scales];
}

/**
 * Kehrt quantize_tensor_i8() um: INT8-Blob + Pro-Zeile-Skalen -> Float32-Blob.
 */
function dequantize_tensor_i8(string $data, array $scales, int $rows, int $cols): string {
    if (SnaiTensorUtils::verfuegbar()) return SnaiTensorUtils::i8_dequant($data, $scales, $rows, $cols);
    return dequantize_tensor_i8_php($data, $scales, $rows, $cols);
}

/** PHP-Fassung von dequantize_tensor_i8() (Bezug fuer die Bytegleichheit des Nim-Wegs, Rueckfall). */
function dequantize_tensor_i8_php(string $data, array $scales, int $rows, int $cols): string {
    $n = $rows * $cols;
    $ints = unpack("c{$n}", $data); // 1-indexiert, signed char

    $out = '';
    for ($r = 0; $r < $rows; $r++) {
        $scale = $scales[$r];
        $base = $r * $cols;
        for ($c = 1; $c <= $cols; $c++) {
            $out .= pack('g', $ints[$base + $c] * $scale);
        }
    }
    return $out;
}

/** Schreibt einen Skalen-Block: [uint16 count][count * float32 LE]. */
function pack_scale_block(array $scales): string {
    $out = pack('v', count($scales));
    foreach ($scales as $s) $out .= pack('g', $s);
    return $out;
}

/** Liest einen Skalen-Block (Gegenstueck zu pack_scale_block()) aus einem offenen fp. */
function read_scale_block($fp): array {
    $count = unpack('v', fread($fp, 2))[1];
    $scales = [];
    if ($count > 0) {
        $raw = unpack("g{$count}", fread($fp, $count * 4));
        for ($i = 1; $i <= $count; $i++) $scales[] = $raw[$i];
    }
    return $scales;
}

/**
 * Wie load_model_header(), erkennt aber zusaetzlich SNAI_V6 (INT8). Liefert immer
 * 'magic', 'dtype_version' und 'header_size' mit zurueck, damit Aufrufer nicht selbst
 * zwischen V5/V6 unterscheiden muessen.
 */
function load_model_header_any(string $filepath): ?array {
    if (!file_exists($filepath)) {
        echo "🚨 [I/O] Fatal: Datei nicht gefunden -> $filepath\n";
        return null;
    }
    $fp = fopen($filepath, 'rb');
    if (!$fp) return null;
    $magic = rtrim(fread($fp, 8), "\0");

    if ($magic === SNAI_MAGIC) {
        $data = fread($fp, 20);
        fclose($fp);
        if (strlen($data) !== 20) {
            echo "🚨 [I/O] Fatal: Unvollständiger Header in $filepath\n";
            return null;
        }
        $h = unpack('Vvocab_size/Vhidden_dim/Vffn_dim/Vctx_size/Vnum_layers', $data);
        $h['magic'] = SNAI_MAGIC;
        $h['dtype_version'] = SNAI_DTYPE_FP32;
        $h['header_size'] = SNAI_HEADER_SIZE;
        return $h;
    }

    if ($magic === SNAI_MAGIC_V6) {
        $data = fread($fp, 24); // 20 Bytes Parameter + 4 Bytes dtype_version
        fclose($fp);
        if (strlen($data) !== 24) {
            echo "🚨 [I/O] Fatal: Unvollständiger V6-Header in $filepath\n";
            return null;
        }
        $h = unpack('Vvocab_size/Vhidden_dim/Vffn_dim/Vctx_size/Vnum_layers/Vdtype_version', $data);
        $h['magic'] = SNAI_MAGIC_V6;
        $h['header_size'] = SNAI_HEADER_SIZE_V6;
        $h['flags'] = 0; // V6 kennt kein Tying - immer ungebunden
        return $h;
    }

    if ($magic === SNAI_MAGIC_V7) {
        $data = fread($fp, 28); // 20 Bytes Parameter + 4 dtype_version + 4 flags
        fclose($fp);
        if (strlen($data) !== 28) {
            echo "🚨 [I/O] Fatal: Unvollständiger V7-Header in $filepath\n";
            return null;
        }
        $h = unpack('Vvocab_size/Vhidden_dim/Vffn_dim/Vctx_size/Vnum_layers/Vdtype_version/Vflags', $data);
        $h['magic'] = SNAI_MAGIC_V7;
        $h['header_size'] = SNAI_HEADER_SIZE_V7;
        // EMB-EINGANG: unbekannte Bits und Bit 1 ohne Bit 0 abweisen, statt das Modell anders zu deuten.
        if (($fehler = snai_v7_flags_fehler((int)$h['flags'])) !== null) {
            echo "🚨 [I/O] Fatal: $fehler in $filepath\n";
            return null;
        }
        return $h;
    }

    fclose($fp);
    echo "🚨 [I/O] Fatal: Unbekanntes Format in $filepath (Magic: $magic)\n";
    return null;
}

/**
 * Referenz-Konvertierung: liest ein bestehendes SNAI_V5-Checkpoint (via load_model())
 * und schreibt ein neues SNAI_V6-Gewichts-Artefakt. Quantisiert nur die 8 Typen aus
 * SNAI_INT8_TENSOR_TYPES, RMSNorm-Gains bleiben Float32. Adam-Zustand (m/v) wird
 * bewusst NICHT mitgeschrieben - reines Gewichts-Artefakt fuer den Phase-1-Rundlauftest,
 * spaeter Vorstufe zum ~1,5-MB-Deployment-Artefakt aus Plan-Phase 6.
 */
function convert_v5_to_v6(string $srcPath, string $dstPath): bool {
    $model = load_model($srcPath);
    if ($model === null) return false;

    $vocab = $model['vocab_size'];
    $dim = $model['hidden_dim'];
    $ffn = $model['ffn_dim'];

    $dir = dirname($dstPath);
    if (!is_dir($dir) && $dir !== '.') @mkdir($dir, 0777, true);

    $fp = fopen($dstPath, 'wb');
    if (!$fp) return false;
    flock($fp, LOCK_EX);

    fwrite($fp, str_pad(SNAI_MAGIC_V6, 8, "\0"));
    fwrite($fp, pack('VVVVV', $vocab, $dim, $ffn, $model['ctx_size'], $model['num_layers']));
    fwrite($fp, pack('V', SNAI_DTYPE_INT8));

    $write_tensor = function(string $type, string $binary) use ($fp, $vocab, $dim, $ffn) {
        if (in_array($type, SNAI_INT8_TENSOR_TYPES, true)) {
            [$rows, $cols] = snai_tensor_shape($type, $vocab, $dim, $ffn);
            $q = quantize_tensor_i8($binary, $rows, $cols);
            fwrite($fp, pack_scale_block($q['scales']));
            fwrite($fp, $q['data']);
        } else {
            fwrite($fp, $binary); // rms_* bleibt Float32, unveraendert
        }
    };

    $g = $model['tensors']['global'];
    $write_tensor('embeddings', $g['embeddings']);
    $write_tensor('w_out', $g['w_out']);
    $write_tensor('rms_final', $g['rms_final']);

    for ($l = 0; $l < $model['num_layers']; $l++) {
        $ly = $model['tensors']['layers'][$l];
        foreach (['rms_att', 'rms_ffn', 'w_q', 'w_k', 'w_v', 'w_o', 'w_up', 'w_down'] as $type) {
            $write_tensor($type, $ly[$type]);
        }
    }

    flock($fp, LOCK_UN);
    fclose($fp);
    return true;
}

/**
 * Laedt ein SNAI_V6-Gewichts-Artefakt vollstaendig in ein PHP-Array und dequantisiert
 * alle INT8-Tensoren sofort zurueck nach Float32 - liefert dieselbe
 * ['global'=>..., 'layers'=>[...]]-Struktur wie load_model(), plus 'tensor_scales' fuer
 * Diagnosezwecke. Nur fuer Diagnose-Tools (Rundlauftest), kein OOM-Zero-Stream, kein
 * Adam-Zustand (siehe convert_v5_to_v6()).
 */
function load_v6_model(string $filepath): ?array {
    $header = load_model_header_any($filepath);
    if ($header === null || !snai_is_int8_magic($header['magic'])) return null;

    $vocab = $header['vocab_size'];
    $dim = $header['hidden_dim'];
    $ffn = $header['ffn_dim'];
    $layers = $header['num_layers'];
    $tied = ((int)($header['flags'] ?? 0) & SNAI_FLAG_TIED_EMBEDDINGS) !== 0;

    $fp = fopen($filepath, 'rb');
    fseek($fp, $header['header_size']);

    $read_tensor = function(string $type) use ($fp, $vocab, $dim, $ffn): array {
        [$rows, $cols] = snai_tensor_shape($type, $vocab, $dim, $ffn);
        if (in_array($type, SNAI_INT8_TENSOR_TYPES, true)) {
            $scales = read_scale_block($fp);
            $data = fread($fp, $rows * $cols);
            return ['data' => dequantize_tensor_i8($data, $scales, $rows, $cols), 'scales' => $scales];
        }
        return ['data' => fread($fp, $rows * $cols * 4), 'scales' => null];
    };

    $emb = $read_tensor('embeddings');
    $wout = $tied ? $emb : $read_tensor('w_out'); // bei Tying nur gespiegelt, s. load_v6_model_full()
    $rmsf = $read_tensor('rms_final');
    $global = ['embeddings' => $emb['data'], 'w_out' => $wout['data'], 'rms_final' => $rmsf['data']];
    $global_scales = ['embeddings' => $emb['scales'], 'w_out' => $wout['scales']];

    $layer_tensors = [];
    $layer_scales = [];
    for ($l = 0; $l < $layers; $l++) {
        $t = [];
        $s = [];
        foreach (snai_layer_types() as $type) {
            $r = $read_tensor($type);
            $t[$type] = $r['data'];
            if ($r['scales'] !== null) $s[$type] = $r['scales'];
        }
        $layer_tensors[$l] = $t;
        $layer_scales[$l] = $s;
    }
    fclose($fp);

    return [
        'magic' => $header['magic'], 'dtype_version' => SNAI_DTYPE_INT8,
        'flags' => (int)($header['flags'] ?? 0),
        'vocab_size' => $vocab, 'hidden_dim' => $dim, 'ffn_dim' => $ffn,
        'ctx_size' => $header['ctx_size'], 'num_layers' => $layers,
        'tensors' => ['global' => $global, 'layers' => $layer_tensors],
        'tensor_scales' => ['global' => $global_scales, 'layers' => $layer_scales],
    ];
}

/**
 * Liest NUR die Architektur-Metadaten aus dem Binär-Stream.
 * RAM-Verbrauch: Unter 1 Kilobyte!
 */
function load_model_header(string $filepath): ?array {
    if (!file_exists($filepath)) {
        echo "🚨 [I/O] Fatal: Datei nicht gefunden -> $filepath\n";
        return null;
    }

    if (filesize($filepath) < SNAI_HEADER_SIZE) {
        echo "🚨 [I/O] Fatal: Datei zu klein für einen Header -> $filepath\n";
        return null;
    }

    $fp = fopen($filepath, 'rb');
    if (!$fp) return null;

    $magic = rtrim(fread($fp, 8), "\0");
    if ($magic !== SNAI_MAGIC) {
        echo "🚨 [I/O] Fatal: Korruptes oder veraltetes Format in $filepath (Erwartet: " . SNAI_MAGIC . ", Gefunden: $magic)\n";
        fclose($fp);
        return null;
    }

    $data = fread($fp, 20);
    fclose($fp);

    if (strlen($data) !== 20) {
        echo "🚨 [I/O] Fatal: Unvollständiger Header in $filepath\n";
        return null;
    }

    $header = unpack('Vvocab_size/Vhidden_dim/Vffn_dim/Vctx_size/Vnum_layers', $data);
    
    return $header;
}

/**
 * Laedt ein KOMPLETTES Modell (Header + alle Tensoren) in ein PHP-Array.
 * Spiegelbild von save_model_stream() - liest exakt die Blob-Reihenfolge, die
 * dort geschrieben wird. Erkennt automatisch, ob die Datei Adam-Zustand (m, v)
 * enthaelt (SNAI_V5-Vollformat) oder nur Gewichte (Legacy-Format); im Legacy-
 * Fall fehlen die "m_"- und "v_"-Praefix-Schluessel im Rueckgabe-Array komplett, statt sie
 * mit Nullen aufzufuellen (spart RAM, Aufrufer die nur 'w' brauchen wie
 * snai_xray.php merken davon nichts).
 *
 * AUDIT-FIX: Diese Funktion fehlte komplett, obwohl snai_xray.php sie aufruft
 * (Fatal Error: Call to undefined function). royal_api.php hatte denselben
 * Aufruf, ist aber mittlerweile geloescht (unbenutzt, aus anderen Gruenden
 * kaputt).
 *
 * WARNUNG: Laedt das GESAMTE Modell in den PHP-Heap (kein OOM-Zero-Stream wie
 * cortex_load_stream in der Nim-Engine) - nur fuer Diagnose-Tools gedacht,
 * niemals im heissen Trainings-/Inferenz-Pfad verwenden.
 */
function load_model(string $filepath): ?array {
    if (!file_exists($filepath)) {
        echo "🚨 [I/O] Fatal: Datei nicht gefunden -> $filepath\n";
        return null;
    }

    $fp = fopen($filepath, 'rb');
    if (!$fp) return null;

    $magic = rtrim(fread($fp, 8), "\0");
    if ($magic !== SNAI_MAGIC) {
        echo "🚨 [I/O] Fatal: Korruptes oder veraltetes Format in $filepath (Erwartet: " . SNAI_MAGIC . ", Gefunden: $magic)\n";
        fclose($fp);
        return null;
    }

    $header_data = fread($fp, 20);
    if (strlen($header_data) !== 20) {
        echo "🚨 [I/O] Fatal: Unvollständiger Header in $filepath\n";
        fclose($fp);
        return null;
    }
    $h = unpack('Vvocab_size/Vhidden_dim/Vffn_dim/Vctx_size/Vnum_layers', $header_data);

    $vocab  = $h['vocab_size'];
    $dim    = $h['hidden_dim'];
    $ffn    = $h['ffn_dim'];
    $ctx    = $h['ctx_size'];
    $layers = $h['num_layers'];

    $size_emb = $vocab * $dim;
    $size_rms = $dim;
    $size_qkv = $dim * $dim;
    $size_up  = $ffn * $dim;

    $elems_per_layer = (2 * $size_rms) + (4 * $size_qkv) + (2 * $size_up);
    $elems_total = (2 * $size_emb) + $size_rms + ($layers * $elems_per_layer);
    $w_bytes = $elems_total * 4;

    $payload = filesize($filepath) - SNAI_HEADER_SIZE;

    if ($payload === $w_bytes * 3 || $payload === $w_bytes * 3 + 4) {
        $with_adam = true;
        $has_adam_t_trailer = ($payload === $w_bytes * 3 + 4);
    } elseif ($payload === $w_bytes || $payload === $w_bytes + 4) {
        $with_adam = false;
        $has_adam_t_trailer = ($payload === $w_bytes + 4);
    } else {
        echo "🚨 [I/O] Fatal: Groessen-Mismatch in $filepath. Payload=" . number_format($payload) .
             " B. Erwartet: " . number_format($w_bytes) . " (nur W) oder " . number_format($w_bytes * 3) . " (W+m+v).\n";
        fclose($fp);
        return null;
    }

    // Liest ein Tensor (Gewicht + optional Momentum/Varianz) und haengt die
    // vorhandenen Bloecke unter $prefix/m_$prefix/v_$prefix in $bucket ein.
    $read_tensor = function(string $prefix, int $floats) use ($fp, $with_adam, &$bucket) {
        $bytes = $floats * 4;
        $bucket[$prefix] = fread($fp, $bytes);
        if ($with_adam) {
            $bucket['m_' . $prefix] = fread($fp, $bytes);
            $bucket['v_' . $prefix] = fread($fp, $bytes);
        }
    };

    $bucket = [];
    $read_tensor('embeddings', $size_emb);
    $read_tensor('w_out', $size_emb);
    $read_tensor('rms_final', $size_rms);
    $global = $bucket;

    $layer_tensors = [];
    for ($l = 0; $l < $layers; $l++) {
        $bucket = [];
        $read_tensor('rms_att', $size_rms);
        $read_tensor('rms_ffn', $size_rms);
        $read_tensor('w_q', $size_qkv);
        $read_tensor('w_k', $size_qkv);
        $read_tensor('w_v', $size_qkv);
        $read_tensor('w_o', $size_qkv);
        $read_tensor('w_up', $size_up);
        $read_tensor('w_down', $size_up);
        $layer_tensors[$l] = $bucket;
    }

    // AUDIT-FIX (2026-08-14, im Rahmen des Neuron-Revival-Live-Hooks entdeckt):
    // der Adam-Bias-Correction-Schrittzaehler (adam_t, optionaler int32-Trailer
    // - siehe save_model_stream()) wurde bisher nur zur With-Adam-Erkennung per
    // Dateigroesse benutzt, aber nie selbst gelesen/zurueckgegeben. Jeder
    // load_model() -> save_model_stream() Rundlauf (z.B. snai_neuron_revival.php)
    // schrieb dadurch STILLSCHWEIGEND adam_t=0 zurueck, obwohl m/v "warm" sind -
    // cortex.nim faengt diese Inkonsistenz zwar mit einem WARN+Fallback
    // (adam_t=1000) ab, das setzt aber bei jedem Rundlauf erneut die effektive
    // Bias-Correction fuer ALLE Parameter zurueck, nicht nur die absichtlich
    // veraenderten Zeilen - ein Seiteneffekt, der nur durch den Fallback
    // verdeckt, nie behoben wurde.
    $adam_t = 0;
    if ($has_adam_t_trailer) {
        $trailer = fread($fp, 4);
        if (strlen($trailer) === 4) {
            $adam_t = unpack('V', $trailer)[1];
        }
    }

    fclose($fp);

    return [
        'magic' => SNAI_MAGIC,
        'vocab_size' => $vocab, 'hidden_dim' => $dim, 'ffn_dim' => $ffn,
        'ctx_size' => $ctx, 'num_layers' => $layers,
        'with_adam' => $with_adam, 'adam_t' => $adam_t,
        'tensors' => ['global' => $global, 'layers' => $layer_tensors],
    ];
}

/**
 * Speichert ein extrahiertes Netzwerk-Array samt Adam-Historie als reinen Binär-Stream.
 */
function save_model_stream(array $state, string $filepath): bool {
    $required = ['vocab_size', 'hidden_dim', 'ctx_size', 'num_layers', 'tensors'];
    foreach ($required as $req) {
        if (!isset($state[$req])) {
            echo "🚨 [I/O] Error: Fehlender Key '$req' im State-Array.\n";
            return false;
        }
    }

    $dir = dirname($filepath);
    
    if (!is_dir($dir) && $dir !== '.') {
        @mkdir($dir, 0777, true);
    }

    $fp = fopen($filepath, 'wb');
    if (!$fp) return false;

    flock($fp, LOCK_EX);

    $ffn_dim = $state['ffn_dim'] ?? ($state['hidden_dim'] * 4);

    // Header schreiben (SNAI_V5)
    fwrite($fp, str_pad(SNAI_MAGIC, 8, "\0"));
    fwrite($fp, pack('VVVVV', 
        $state['vocab_size'], $state['hidden_dim'], 
        $ffn_dim, $state['ctx_size'], $state['num_layers']
    ));

    // --- GLOBALE TENSOREN (w, m, v interleaved) ---
    $g = $state['tensors']['global'];
    
    fwrite($fp, $g['embeddings']); fwrite($fp, $g['m_embeddings']); fwrite($fp, $g['v_embeddings']);
    fwrite($fp, $g['w_out']);      fwrite($fp, $g['m_w_out']);      fwrite($fp, $g['v_w_out']);
    fwrite($fp, $g['rms_final']);  fwrite($fp, $g['m_rms_final']);  fwrite($fp, $g['v_rms_final']);

    // --- LAYER TENSOREN (w, m, v interleaved) ---
    for ($l = 0; $l < $state['num_layers']; $l++) {
        $ly = $state['tensors']['layers'][$l];
        
        fwrite($fp, $ly['rms_att']);  fwrite($fp, $ly['m_rms_att']);  fwrite($fp, $ly['v_rms_att']);
        fwrite($fp, $ly['rms_ffn']);  fwrite($fp, $ly['m_rms_ffn']);  fwrite($fp, $ly['v_rms_ffn']);
        
        fwrite($fp, $ly['w_q']);      fwrite($fp, $ly['m_w_q']);      fwrite($fp, $ly['v_w_q']);
        fwrite($fp, $ly['w_k']);      fwrite($fp, $ly['m_w_k']);      fwrite($fp, $ly['v_w_k']);
        fwrite($fp, $ly['w_v']);      fwrite($fp, $ly['m_w_v']);      fwrite($fp, $ly['v_w_v']);
        fwrite($fp, $ly['w_o']);      fwrite($fp, $ly['m_w_o']);      fwrite($fp, $ly['v_w_o']);
        
        fwrite($fp, $ly['w_up']);     fwrite($fp, $ly['m_w_up']);     fwrite($fp, $ly['v_w_up']);
        fwrite($fp, $ly['w_down']);   fwrite($fp, $ly['m_w_down']);   fwrite($fp, $ly['v_w_down']);
    }

    // Update 2026-08-09 ("Engine-/Framework-Verbesserungen", Punkt 1):
    // Adam-Bias-Correction-Schrittzaehler als optionaler int32-Trailer -
    // der Nim-Loader erkennt ihn rein anhand der Dateigroesse (Payload =
    // W+m+v-Bytes + genau 4 zusaetzliche Bytes, siehe cortex.nim "withT").
    // Kein neues Format, keine Versions-Aenderung - nur der bisher fehlende
    // letzte Baustein eines bereits vom Loader unterstuetzten Layouts.
    // Default 0 (= "kein Adam-State"/Cold-Start-Verhalten), falls
    // 'adam_t' im State-Array fehlt - haelt bestehende Aufrufer sicher.
    fwrite($fp, pack('V', $state['adam_t'] ?? 0));

    flock($fp, LOCK_UN);
    fclose($fp);

    return true;
}

// ============================================================================
// PHASE 5 DES INT8-UMBAUS
// Trainings-Loop-Integration: SNAI_V6-Schreiben/Lesen MIT Adam-Zustand (m/v) -
// im Gegensatz zu convert_v5_to_v6()/load_v6_model() aus Phase 1, die bewusst
// ein reines Gewichts-Artefakt fuer den Rundlauftest waren. Layout pro Tensor:
// bei den 8 quantisierbaren Typen [Skalen-Block][INT8-Daten][m: Float32][v:
// Float32], bei rms_* (und den ihnen entsprechenden globalen Typen) wie im
// V5-Format [w: Float32][m: Float32][v: Float32].
// ============================================================================

/**
 * Speichert ein per SnaiCortexBridge::extract_state_i8() gewonnenes INT8-
 * State-Array (inkl. 'tensor_scales') als SNAI_V6-Datei mit vollem
 * Adam-Zustand - das produktive Pendant zu save_model_stream() (V5).
 */
function save_model_stream_i8(array $state, string $filepath): bool {
    $required = ['vocab_size', 'hidden_dim', 'ctx_size', 'num_layers', 'tensors', 'tensor_scales'];
    foreach ($required as $req) {
        if (!isset($state[$req])) {
            echo "🚨 [I/O] Error: Fehlender Key '$req' im INT8-State-Array.\n";
            return false;
        }
    }
    // EMB-EINGANG: Flags 2 (Faktor ohne Tying) wuerde unten still zu einem V6 ohne Bit - lieber gar nicht schreiben.
    if (($fehler = snai_v7_flags_fehler((int)($state['flags'] ?? 0))) !== null) {
        echo "🚨 [I/O] Fatal: $fehler - $filepath nicht geschrieben.\n";
        return false;
    }

    $dir = dirname($filepath);
    if (!is_dir($dir) && $dir !== '.') @mkdir($dir, 0777, true);

    $fp = fopen($filepath, 'wb');
    if (!$fp) return false;
    flock($fp, LOCK_EX);

    $ffn_dim = $state['ffn_dim'] ?? ($state['hidden_dim'] * 4);

    // V7 (Tying) nur, wenn der State es ausdruecklich anfordert - ein State ohne
    // 'flags' schreibt weiterhin bitgleiches V6. Damit bleibt jeder bestehende
    // Aufrufer (train_worker, merge, Destille) unveraendert gueltig.
    $flags = (int)($state['flags'] ?? 0);
    $tied  = ($flags & SNAI_FLAG_TIED_EMBEDDINGS) !== 0;

    if ($tied) {
        fwrite($fp, str_pad(SNAI_MAGIC_V7, 8, "\0"));
        fwrite($fp, pack('VVVVV', $state['vocab_size'], $state['hidden_dim'], $ffn_dim, $state['ctx_size'], $state['num_layers']));
        fwrite($fp, pack('V', SNAI_DTYPE_INT8));
        fwrite($fp, pack('V', $flags));
    } else {
        fwrite($fp, str_pad(SNAI_MAGIC_V6, 8, "\0"));
        fwrite($fp, pack('VVVVV', $state['vocab_size'], $state['hidden_dim'], $ffn_dim, $state['ctx_size'], $state['num_layers']));
        fwrite($fp, pack('V', SNAI_DTYPE_INT8));
    }

    $write_tensor = function(string $type, array $tensors, array $scales) use ($fp) {
        if (in_array($type, SNAI_INT8_TENSOR_TYPES, true)) {
            fwrite($fp, pack_scale_block($scales[$type]));
            fwrite($fp, $tensors[$type]);
        } else {
            fwrite($fp, $tensors[$type]); // rms_* bleibt Float32, unveraendert
        }
        fwrite($fp, $tensors['m_' . $type]);
        fwrite($fp, $tensors['v_' . $type]);
    };

    $g = $state['tensors']['global'];
    $gs = $state['tensor_scales']['global'];
    foreach (snai_global_types($flags) as $type) {
        $write_tensor($type, $g, $gs);
    }

    for ($l = 0; $l < $state['num_layers']; $l++) {
        $ly = $state['tensors']['layers'][$l];
        $lys = $state['tensor_scales']['layers'][$l];
        foreach (snai_layer_types() as $type) {
            $write_tensor($type, $ly, $lys);
        }
    }

    fwrite($fp, pack('V', $state['adam_t'] ?? 0));

    flock($fp, LOCK_UN);
    fclose($fp);
    return true;
}

/**
 * Gegenstueck zu save_model_stream_i8(): laedt eine SNAI_V6-Datei MIT
 * Adam-Zustand vollstaendig in ein PHP-Array, dequantisiert die INT8-Gewichte
 * sofort nach Float32 - liefert dieselbe Struktur wie load_model() (V5), plus
 * 'tensor_scales'. Nur fuer Diagnose/Merge (siehe merge_v6_models() unten),
 * kein OOM-Zero-Stream.
 */
/**
 * Erwartete Dateigroesse eines SNAI_V6 aus der Geometrie - einmal ohne und
 * einmal mit Adam-Zustand (+4 Byte adam_t-Abschluss).
 *
 * BEFUND 2026-08-24 (Full-INT8-Port, Punkt 3): load_v6_model_full() las
 * blind per fread() und pruefte nie, ob die Datei ueberhaupt so lang ist.
 * Eine auf 10 % abgeschnittene Datei lieferte deshalb "Daten" - und
 * validate_tensor_file() der Destille, das genau an diese Funktion
 * delegiert, winkte sie durch. Da die Aufrufer abgelehnte Dateien LOESCHEN
 * und akzeptierte weiterverwenden, waere ein abgebrochener Schreibvorgang
 * (volle Platte, Absturz) als gueltiger Checkpoint in den Schwarm gewandert.
 * Der Nim-Lader cortex_load_stream_i8() macht diese Bilanz laengst - hier
 * fehlte sie.
 *
 * @return array{0:int,1:int} [nur Gewichte, mit Adam+Trailer]
 */
function snai_v6_expected_sizes(int $vocab, int $dim, int $ffn, int $layers,
                                int $flags = 0, ?string $magic = null): array {
    $magic = $magic ?? (($flags & SNAI_FLAG_TIED_EMBEDDINGS) ? SNAI_MAGIC_V7 : SNAI_MAGIC_V6);
    $headerSize = ($magic === SNAI_MAGIC_V7) ? SNAI_HEADER_SIZE_V7 : SNAI_HEADER_SIZE_V6;

    // Bei gesetztem Tying-Flag fehlt der w_out-Block komplett - snai_global_types()
    // ist die einzige Stelle, die das entscheidet.
    $types = snai_global_types($flags);
    for ($l = 0; $l < $layers; $l++) {
        foreach (snai_layer_types() as $t) {
            $types[] = $t;
        }
    }
    $weights = 0; $adam = 0;
    foreach ($types as $t) {
        [$rows, $cols] = snai_tensor_shape($t, $vocab, $dim, $ffn);
        $n = $rows * $cols;
        // int8-Tensoren: [uint16 Zeilenzahl][float32 je Zeile][int8-Daten]
        $weights += in_array($t, SNAI_INT8_TENSOR_TYPES, true)
            ? (2 + $rows * 4 + $n)
            : ($n * 4);
        $adam += 2 * $n * 4;   // m und v, laut Design-Entscheidung #2 immer float32
    }
    $base = $headerSize + $weights;
    return [$base, $base + $adam + 4];
}

function load_v6_model_full(string $filepath): ?array {
    $header = load_model_header_any($filepath);
    if ($header === null || !snai_is_int8_magic($header['magic'])) return null;

    $vocab = $header['vocab_size'];
    $dim = $header['hidden_dim'];
    $ffn = $header['ffn_dim'];
    $layers = $header['num_layers'];
    $flags = (int)($header['flags'] ?? 0);
    $tied  = ($flags & SNAI_FLAG_TIED_EMBEDDINGS) !== 0;

    // Bytebilanz VOR dem Lesen (siehe snai_v6_expected_sizes): eine zu kurze
    // Datei wuerde sonst still mit Nullen aufgefuellte Tensoren liefern.
    $actual = (int)filesize($filepath);
    [$sizeWeights, $sizeAdam] = snai_v6_expected_sizes($vocab, $dim, $ffn, $layers, $flags, $header['magic']);
    if ($actual !== $sizeWeights && $actual !== $sizeAdam) {
        fwrite(STDERR, sprintf(
            "🚨 [%s] '%s' hat %d Bytes, erwartet %d (nur Gewichte) oder %d (+Adam). Datei unvollstaendig.\n",
            $header['magic'], basename($filepath), $actual, $sizeWeights, $sizeAdam));
        return null;
    }

    $fp = fopen($filepath, 'rb');
    fseek($fp, $header['header_size']);

    $read_tensor = function(string $type) use ($fp, $vocab, $dim, $ffn): array {
        [$rows, $cols] = snai_tensor_shape($type, $vocab, $dim, $ffn);
        $bytes = $rows * $cols * 4;
        if (in_array($type, SNAI_INT8_TENSOR_TYPES, true)) {
            $scales = read_scale_block($fp);
            $data = fread($fp, $rows * $cols);
            $w = dequantize_tensor_i8($data, $scales, $rows, $cols);
        } else {
            $scales = null;
            $w = fread($fp, $bytes);
        }
        $m = fread($fp, $bytes);
        $v = fread($fp, $bytes);
        return ['w' => $w, 'm' => $m, 'v' => $v, 'scales' => $scales];
    };

    $emb = $read_tensor('embeddings');
    // Bei Tying steht kein w_out in der Datei. Nach aussen wird es trotzdem
    // gespiegelt ausgeliefert - so bleiben alle Verbraucher dieser Struktur
    // (merge_v6_models, convert_v6_to_v5_full, upscale_cortex der Destille,
    // snai_neuron_revival) unveraendert lauffaehig. Wer wieder V7 schreibt, gibt
    // 'flags' mit und der Spiegel faellt beim Schreiben still weg.
    $wout = $tied ? $emb : $read_tensor('w_out');
    $rmsf = $read_tensor('rms_final');
    $global = [
        'embeddings' => $emb['w'], 'm_embeddings' => $emb['m'], 'v_embeddings' => $emb['v'],
        'w_out' => $wout['w'], 'm_w_out' => $wout['m'], 'v_w_out' => $wout['v'],
        'rms_final' => $rmsf['w'], 'm_rms_final' => $rmsf['m'], 'v_rms_final' => $rmsf['v'],
    ];
    $global_scales = ['embeddings' => $emb['scales'], 'w_out' => $wout['scales']];

    $layer_tensors = [];
    $layer_scales = [];
    for ($l = 0; $l < $layers; $l++) {
        $t = [];
        $s = [];
        foreach (snai_layer_types() as $type) {
            $r = $read_tensor($type);
            $t[$type] = $r['w'];
            $t['m_' . $type] = $r['m'];
            $t['v_' . $type] = $r['v'];
            if ($r['scales'] !== null) $s[$type] = $r['scales'];
        }
        $layer_tensors[$l] = $t;
        $layer_scales[$l] = $s;
    }

    $adam_t = 0;
    $trailer = fread($fp, 4);
    if (strlen($trailer) === 4) $adam_t = unpack('V', $trailer)[1];
    fclose($fp);

    return [
        'magic' => $header['magic'], 'dtype_version' => SNAI_DTYPE_INT8, 'flags' => $flags,
        'vocab_size' => $vocab, 'hidden_dim' => $dim, 'ffn_dim' => $ffn,
        'ctx_size' => $header['ctx_size'], 'num_layers' => $layers, 'adam_t' => $adam_t,
        'tensors' => ['global' => $global, 'layers' => $layer_tensors],
        'tensor_scales' => ['global' => $global_scales, 'layers' => $layer_scales],
    ];
}

/**
 * Tensor-bewusstes Federated Averaging fuer SNAI_V6-Dateien (Design-
 * Entscheidung: Skala wird beim Merge FRISCH aus dem gemittelten Float-
 * Akkumulator neu abgeleitet, statt Skalen-Konsistenz zwischen Workern
 * vorauszusetzen). Bewusst NICHT die bestehende average_models_stream()
 * (train_cluster.php) - die mergt blind in 8192-Float-Chunks, was nur bei
 * SNAI_V5s durchgehend homogenem Float32-Layout funktioniert. SNAI_V6 mischt
 * INT8-Bloecke mit Skalen-Praefixen und Float32-Resten (rms_*) - braucht
 * echtes Tensor-Wissen, deshalb hier ueber load_v6_model_full()/
 * snai_tensor_shape() statt Byte-Offsets.
 */
function merge_v6_models(array $paths, string $output_path): bool {
    // NIM-WEG (2026-11-08, messbuch snai/merge-int8-nim): liest die Dateien
    // TENSOR FUER TENSOR und laesst Nim rechnen, statt alle N Modelle ganz
    // dequantisiert in den Speicher zu legen (gemessen PHP-Fassung bei
    // 512/6/8: rund 340 MB je Modell, snai/merge-int8-zeit). Speicher jetzt:
    // N x groesster Tensor. Bytegleich zu merge_v6_models_php(), die bleibt
    // Rueckfall: ohne Nim-Lib und fuer Dateien ohne Adam-Zustand (deren
    // Verhalten dort wird hier nicht nachgebaut).
    if (empty($paths)) {
        echo "🚨 [I/O] merge_v6_models(): keine Eingabedateien.\n";
        return false;
    }
    if (count($paths) === 1) {
        return copy($paths[0], $output_path);
    }
    if (!SnaiTensorUtils::verfuegbar()) return merge_v6_models_php($paths, $output_path);

    $heads = [];
    foreach ($paths as $p) {
        $h = load_model_header_any($p);
        if ($h === null || !snai_is_int8_magic($h['magic'])) {
            echo "🚨 [I/O] merge_v6_models(): konnte $p nicht laden.\n";
            return false;
        }
        $heads[] = $h;
    }
    $first = $heads[0];
    foreach ($heads as $h) {
        if ($h['vocab_size'] !== $first['vocab_size'] || $h['hidden_dim'] !== $first['hidden_dim']
            || $h['ffn_dim'] !== $first['ffn_dim'] || $h['num_layers'] !== $first['num_layers']) {
            echo "🚨 [I/O] merge_v6_models(): inkonsistente Modell-Geometrie.\n";
            return false;
        }
        // Begruendung siehe merge_v6_models_php(): gebunden und ungebunden nicht mitteln.
        if ((int)($h['flags'] ?? 0) !== (int)($first['flags'] ?? 0)) {
            echo "🚨 [I/O] merge_v6_models(): Modelle mischen gebundene und ungebundene Embeddings.\n";
            return false;
        }
    }
    $vocab = $first['vocab_size']; $dim = $first['hidden_dim']; $ffn = $first['ffn_dim'];
    $layers = $first['num_layers']; $flags = (int)($first['flags'] ?? 0);
    if (($fehler = snai_v7_flags_fehler($flags)) !== null) {
        echo "🚨 [I/O] Fatal: $fehler - $output_path nicht geschrieben.\n";
        return false;
    }
    foreach ($paths as $i => $p) {
        [$sizeWeights, $sizeAdam] = snai_v6_expected_sizes($vocab, $dim, $ffn, $layers, $flags, $heads[$i]['magic']);
        $actual = (int)filesize($p);
        if ($actual === $sizeWeights) return merge_v6_models_php($paths, $output_path);
        if ($actual !== $sizeAdam) {
            fwrite(STDERR, sprintf("🚨 [%s] '%s' hat %d Bytes, erwartet %d (nur Gewichte) oder %d (+Adam). Datei unvollstaendig.\n",
                $heads[$i]['magic'], basename($p), $actual, $sizeWeights, $sizeAdam));
            echo "🚨 [I/O] merge_v6_models(): konnte $p nicht laden.\n";
            return false;
        }
    }

    $fps = [];
    foreach ($paths as $i => $p) {
        $fps[$i] = fopen($p, 'rb');
        fseek($fps[$i], $heads[$i]['header_size']);
    }
    $lies = function($fp, int $len) {
        $b = $len > 0 ? fread($fp, $len) : '';
        if ($b === false || strlen($b) !== $len) throw new RuntimeException("merge_v6_models(): Lesefehler ($len Bytes)");
        return $b;
    };

    $dir = dirname($output_path);
    if (!is_dir($dir) && $dir !== '.') @mkdir($dir, 0777, true);
    $out = fopen($output_path, 'wb');
    if (!$out) return false;
    flock($out, LOCK_EX);
    // Kopf genau wie save_model_stream_i8() ihn fuer den gemischten State schreibt.
    $tied = ($flags & SNAI_FLAG_TIED_EMBEDDINGS) !== 0;
    fwrite($out, str_pad($tied ? SNAI_MAGIC_V7 : SNAI_MAGIC_V6, 8, "\0"));
    fwrite($out, pack('VVVVV', $vocab, $dim, $ffn, $first['ctx_size'], $layers));
    fwrite($out, pack('V', SNAI_DTYPE_INT8));
    if ($tied) fwrite($out, pack('V', $flags));

    $types = snai_global_types($flags);
    for ($l = 0; $l < $layers; $l++) foreach (snai_layer_types() as $t) $types[] = $t;

    try {
        foreach ($types as $type) {
            [$rows, $cols] = snai_tensor_shape($type, $vocab, $dim, $ffn);
            $n = $rows * $cols;
            if (in_array($type, SNAI_INT8_TENSOR_TYPES, true)) {
                $qs = []; $ss = [];
                foreach ($fps as $i => $fp) {
                    $count = unpack('v', $lies($fp, 2))[1];
                    if ($count !== $rows) throw new RuntimeException("merge_v6_models(): $type hat $count Skalen, erwartet $rows");
                    $ss[$i] = $lies($fp, $rows * 4);
                    $qs[$i] = $lies($fp, $n);
                }
                [$q, $s] = SnaiTensorUtils::i8_merge($qs, $ss, $rows, $cols);
                fwrite($out, pack('v', $rows) . $s);
                fwrite($out, $q);
            } else {
                $ws = [];
                foreach ($fps as $i => $fp) $ws[$i] = $lies($fp, $n * 4);
                fwrite($out, SnaiTensorUtils::f32_avg($ws));
            }
            unset($qs, $ss, $ws, $q, $s);
            foreach (['m', 'v'] as $_) {
                $bs = [];
                foreach ($fps as $i => $fp) $bs[$i] = $lies($fp, $n * 4);
                fwrite($out, SnaiTensorUtils::f32_avg($bs));
                unset($bs);
            }
        }
        $adam_t = 0;
        foreach ($fps as $fp) $adam_t = max($adam_t, unpack('V', $lies($fp, 4))[1]);
        fwrite($out, pack('V', $adam_t));
    } catch (RuntimeException $e) {
        echo "🚨 [I/O] " . $e->getMessage() . "\n";
        flock($out, LOCK_UN); fclose($out); @unlink($output_path);
        foreach ($fps as $fp) fclose($fp);
        return false;
    }
    flock($out, LOCK_UN);
    fclose($out);
    foreach ($fps as $fp) fclose($fp);
    return true;
}

/** PHP-Fassung von merge_v6_models() (Bezug fuer die Bytegleichheit des Nim-Wegs, Rueckfall). */
function merge_v6_models_php(array $paths, string $output_path): bool {
    if (empty($paths)) {
        echo "🚨 [I/O] merge_v6_models(): keine Eingabedateien.\n";
        return false;
    }
    if (count($paths) === 1) {
        return copy($paths[0], $output_path);
    }

    $models = [];
    foreach ($paths as $p) {
        $m = load_v6_model_full($p);
        if ($m === null) {
            echo "🚨 [I/O] merge_v6_models(): konnte $p nicht laden.\n";
            return false;
        }
        $models[] = $m;
    }

    $first = $models[0];
    foreach ($models as $m) {
        if ($m['vocab_size'] !== $first['vocab_size'] || $m['hidden_dim'] !== $first['hidden_dim']
            || $m['ffn_dim'] !== $first['ffn_dim'] || $m['num_layers'] !== $first['num_layers']) {
            echo "🚨 [I/O] merge_v6_models(): inkonsistente Modell-Geometrie.\n";
            return false;
        }
        // Gebunden und ungebunden lassen sich nicht mitteln: beim gebundenen Arm
        // IST w_out die Embedding-Matrix, beim ungebundenen ist es ein eigener,
        // anders gelernter Tensor. Ein Mittel daraus waere in beiden Rollen
        // falsch - lieber laut scheitern als still Unsinn schreiben.
        if ((int)($m['flags'] ?? 0) !== (int)($first['flags'] ?? 0)) {
            echo "🚨 [I/O] merge_v6_models(): Modelle mischen gebundene und ungebundene Embeddings.\n";
            return false;
        }
    }
    $flags = (int)($first['flags'] ?? 0);
    $n = count($models);

    // Mittelt N gleich lange Float32-Blobs elementweise (identische Semantik
    // zu ffi_average_layer() in tensor_ffi_adapter.php, hier ohne FFI - reine
    // PHP-Fallback-Implementierung, ausreichend fuer Cluster-Groessen dieser
    // Phase; eine FFI-beschleunigte Variante ist ein spaeterer Perf-Nachzug).
    $avg_floats = function(array $blobs): string {
        $n = count($blobs);
        $count = intdiv(strlen($blobs[0]), 4);
        $sum = array_fill(0, $count, 0.0);
        foreach ($blobs as $b) {
            $vals = unpack("g{$count}", $b);
            for ($i = 1; $i <= $count; $i++) $sum[$i - 1] += $vals[$i];
        }
        $out = '';
        foreach ($sum as $s) $out .= pack('g', $s / $n);
        return $out;
    };

    // INT8-Tensor ueber N Modelle mergen: jede Zeile dequantisieren (mit der
    // JEWEILS EIGENEN Skala des Modells), Float-Mittel bilden, dann NEUE Skala
    // aus dem gemittelten Ergebnis ableiten (siehe Funktionskommentar oben).
    $merge_i8_tensor = function(string $type, array $per_model_tensors, array $per_model_scales, int $vocab, int $dim, int $ffn) use ($n): array {
        [$rows, $cols] = snai_tensor_shape($type, $vocab, $dim, $ffn);
        $avg_floats_flat = array_fill(0, $rows * $cols, 0.0);
        foreach ($per_model_tensors as $idx => $w_blob) {
            $vals = unpack("g" . ($rows * $cols), $w_blob);
            for ($i = 1; $i <= $rows * $cols; $i++) $avg_floats_flat[$i - 1] += $vals[$i];
        }
        for ($i = 0; $i < $rows * $cols; $i++) $avg_floats_flat[$i] /= $n;

        $data = '';
        $scales = [];
        for ($r = 0; $r < $rows; $r++) {
            $off = $r * $cols;
            $maxAbs = 0.0;
            for ($c = 0; $c < $cols; $c++) {
                $a = abs($avg_floats_flat[$off + $c]);
                if ($a > $maxAbs) $maxAbs = $a;
            }
            $scale = $maxAbs > 0.0 ? ($maxAbs / 127.0) : 1.0;
            $scales[] = $scale;
            for ($c = 0; $c < $cols; $c++) {
                $q = (int) round($avg_floats_flat[$off + $c] / $scale);
                if ($q > 127) $q = 127;
                elseif ($q < -128) $q = -128;
                $data .= pack('c', $q);
            }
        }
        return ['w' => $data, 'scales' => $scales];
    };

    $vocab = $first['vocab_size']; $dim = $first['hidden_dim']; $ffn = $first['ffn_dim'];

    $merged = [
        'vocab_size' => $vocab, 'hidden_dim' => $dim, 'ffn_dim' => $ffn,
        'ctx_size' => $first['ctx_size'], 'num_layers' => $first['num_layers'],
        'adam_t' => max(array_column($models, 'adam_t')),
        'flags' => $flags,
        'tensors' => ['global' => [], 'layers' => []],
        'tensor_scales' => ['global' => [], 'layers' => []],
    ];

    // Global - bei Tying entfaellt w_out hier komplett (snai_global_types()),
    // sonst wuerde der gespiegelte Tensor unnoetig ein zweites Mal gemittelt
    // und danach beim Schreiben ohnehin verworfen.
    foreach (array_diff(snai_global_types($flags), ['rms_final']) as $type) {
        $blobs = array_map(fn($m) => $m['tensors']['global'][$type], $models);
        $r = $merge_i8_tensor($type, $blobs, [], $vocab, $dim, $ffn);
        $merged['tensors']['global'][$type] = $r['w'];
        $merged['tensor_scales']['global'][$type] = $r['scales'];
        $merged['tensors']['global']['m_' . $type] = $avg_floats(array_map(fn($m) => $m['tensors']['global']['m_' . $type], $models));
        $merged['tensors']['global']['v_' . $type] = $avg_floats(array_map(fn($m) => $m['tensors']['global']['v_' . $type], $models));
    }
    foreach (['rms_final'] as $type) {
        $merged['tensors']['global'][$type] = $avg_floats(array_map(fn($m) => $m['tensors']['global'][$type], $models));
        $merged['tensors']['global']['m_' . $type] = $avg_floats(array_map(fn($m) => $m['tensors']['global']['m_' . $type], $models));
        $merged['tensors']['global']['v_' . $type] = $avg_floats(array_map(fn($m) => $m['tensors']['global']['v_' . $type], $models));
    }

    for ($l = 0; $l < $merged['num_layers']; $l++) {
        $lt = []; $ls = [];
        foreach (['w_q', 'w_k', 'w_v', 'w_o', 'w_up', 'w_down'] as $type) {
            $blobs = array_map(fn($m) => $m['tensors']['layers'][$l][$type], $models);
            $r = $merge_i8_tensor($type, $blobs, [], $vocab, $dim, $ffn);
            $lt[$type] = $r['w'];
            $ls[$type] = $r['scales'];
            $lt['m_' . $type] = $avg_floats(array_map(fn($m) => $m['tensors']['layers'][$l]['m_' . $type], $models));
            $lt['v_' . $type] = $avg_floats(array_map(fn($m) => $m['tensors']['layers'][$l]['v_' . $type], $models));
        }
        foreach (['rms_att', 'rms_ffn'] as $type) {
            $lt[$type] = $avg_floats(array_map(fn($m) => $m['tensors']['layers'][$l][$type], $models));
            $lt['m_' . $type] = $avg_floats(array_map(fn($m) => $m['tensors']['layers'][$l]['m_' . $type], $models));
            $lt['v_' . $type] = $avg_floats(array_map(fn($m) => $m['tensors']['layers'][$l]['v_' . $type], $models));
        }
        $merged['tensors']['layers'][$l] = $lt;
        $merged['tensor_scales']['layers'][$l] = $ls;
    }

    return save_model_stream_i8($merged, $output_path);
}

/**
 * PHASE 6 DES INT8-UMBAUS
 * Deployment-Export: entfernt den Adam-Zustand (m/v) aus einem bereits
 * trainierten SNAI_V6-Checkpoint (save_model_stream_i8()-Format) - liefert
 * das reine INT8-Gewichts-Artefakt aus der urspruenglichen Projekt-
 * Vision ("Eine vollwertige Drohne wiegt exakt 1,5 Megabyte"). Arbeitet auf
 * den ROHEN Bytes (kein Dequantisieren/Requantisieren, kein Praezisions-
 * verlust) - im Gegensatz zu load_v6_model_full()/merge_v6_models(), die
 * fuer Mittelwertbildung zwingend durch Float gehen muessen.
 */
function export_int8_deployment(string $src_path, string $dst_path): bool {
    $header = load_model_header_any($src_path);
    if ($header === null || !snai_is_int8_magic($header['magic'])) {
        echo "🚨 [I/O] export_int8_deployment(): $src_path ist kein SNAI_V6/V7-Checkpoint.\n";
        return false;
    }
    $vocab = $header['vocab_size']; $dim = $header['hidden_dim']; $ffn = $header['ffn_dim'];
    $layers = $header['num_layers'];
    $flags = (int)($header['flags'] ?? 0);

    $in = fopen($src_path, 'rb');
    if (!$in) return false;
    fseek($in, $header['header_size']);

    $dir = dirname($dst_path);
    if (!is_dir($dir) && $dir !== '.') @mkdir($dir, 0777, true);
    $out = fopen($dst_path, 'wb');
    if (!$out) { fclose($in); return false; }
    flock($out, LOCK_EX);

    // Magic/Flags des Quellartefakts erhalten - ein gebundenes Modell bleibt
    // gebunden, sonst koennte der Lader das fehlende w_out nicht erklaeren.
    fwrite($out, str_pad($header['magic'], 8, "\0"));
    fwrite($out, pack('VVVVV', $vocab, $dim, $ffn, $header['ctx_size'], $layers));
    fwrite($out, pack('V', SNAI_DTYPE_INT8));
    if ($header['magic'] === SNAI_MAGIC_V7) fwrite($out, pack('V', $flags));

    $copy_tensor = function(string $type) use ($in, $out, $vocab, $dim, $ffn) {
        [$rows, $cols] = snai_tensor_shape($type, $vocab, $dim, $ffn);
        $bytes = $rows * $cols * 4;
        if (in_array($type, SNAI_INT8_TENSOR_TYPES, true)) {
            $scale_block = read_scale_block($in);
            $data = fread($in, $rows * $cols);
            fwrite($out, pack_scale_block($scale_block));
            fwrite($out, $data);
        } else {
            fwrite($out, fread($in, $bytes)); // w (rms_*, bleibt Float32)
        }
        fseek($in, $bytes, SEEK_CUR); // m ueberspringen (immer Float32)
        fseek($in, $bytes, SEEK_CUR); // v ueberspringen (immer Float32)
    };

    foreach (snai_global_types($flags) as $type) {
        $copy_tensor($type);
    }
    for ($l = 0; $l < $layers; $l++) {
        foreach (snai_layer_types() as $type) {
            $copy_tensor($type);
        }
    }
    // Kein adam_t-Trailer im Deployment-Artefakt - reines Gewichts-Artefakt,
    // kein Adam-Zustand vorhanden, den ein Trailer beschreiben koennte.

    fclose($in);
    flock($out, LOCK_UN);
    fclose($out);
    return true;
}
/**
 * INT8-NACHZUG 2026-08-19: SNAI_V5 -> SNAI_V6 MIT Adam-Zustand.
 *
 * Unterschied zu convert_v5_to_v6(): jenes erzeugt ein reines Gewichts-
 * Artefakt (Phase-1-Diagnosewerkzeug). Fuer den Net2Net-Wachstumspfad in
 * der Destille muss der Adam-Zustand erhalten bleiben, sonst verliert
 * jede Stufenerweiterung das Optimierer-Gedaechtnis.
 */
function convert_v5_to_v6_full(string $srcPath, string $dstPath, int $flags = 0): bool {
    $m = load_model($srcPath);
    if ($m === null) return false;
    $vocab = $m['vocab_size']; $dim = $m['hidden_dim']; $ffn = $m['ffn_dim'];

    // $flags mit SNAI_FLAG_TIED_EMBEDDINGS erzeugt ein GEBUNDENES V7. Das
    // w_out des V5-Eingangs wird dabei bewusst VERWORFEN, nicht mit den
    // Embeddings verrechnet: bei Tying ist w_out per Definition die
    // Embedding-Matrix. Wichtig fuer den V7->V5->V7-Umweg in
    // upscale_cortex() der Destille - dort muss der Aufrufer die
    // urspruenglichen Flags zurueckgeben, sonst waechst ein gebundenes Modell
    // als ungebundenes weiter.
    $state = [
        'vocab_size' => $vocab, 'hidden_dim' => $dim, 'ffn_dim' => $ffn,
        'ctx_size' => $m['ctx_size'], 'num_layers' => $m['num_layers'],
        'adam_t' => $m['adam_t'] ?? 0,
        'flags' => $flags,
        'tensors' => ['global' => [], 'layers' => []],
        'tensor_scales' => ['global' => [], 'layers' => []],
    ];

    $conv = function(string $type, array $src, array &$dstT, array &$dstS) use ($vocab, $dim, $ffn) {
        if (in_array($type, SNAI_INT8_TENSOR_TYPES, true)) {
            [$rows, $cols] = snai_tensor_shape($type, $vocab, $dim, $ffn);
            $q = quantize_tensor_i8($src[$type], $rows, $cols);
            $dstT[$type] = $q['data'];
            $dstS[$type] = $q['scales'];
        } else {
            $dstT[$type] = $src[$type];           // rms_* bleibt Float32
        }
        // Adam-Momente unveraendert uebernehmen (Design-Entscheidung #2)
        $dstT['m_' . $type] = $src['m_' . $type];
        $dstT['v_' . $type] = $src['v_' . $type];
    };

    $g = $m['tensors']['global'];
    foreach (snai_global_types($flags) as $t) {
        $conv($t, $g, $state['tensors']['global'], $state['tensor_scales']['global']);
    }
    for ($l = 0; $l < $m['num_layers']; $l++) {
        $lt = []; $ls = [];
        foreach (snai_layer_types() as $t) {
            $conv($t, $m['tensors']['layers'][$l], $lt, $ls);
        }
        $state['tensors']['layers'][$l] = $lt;
        $state['tensor_scales']['layers'][$l] = $ls;
    }
    return save_model_stream_i8($state, $dstPath);
}

/**
 * Gegenrichtung: SNAI_V6 -> SNAI_V5 (dequantisiert, Adam-Zustand erhalten).
 * EMB-EINGANG: V5 hat kein Flags-Feld, die FP32-Engine keinen Faktor. Traegt die Quelle Bit 1, wird nur
 * gewandelt, wenn der Aufrufer ausdruecklich zusagt, die Flags beim Rueckweg (convert_v5_to_v6_full) wieder
 * mitzugeben und die V5-Datei nicht selbst zu rechnen ($emb_eingang_rueckweg = true). Sonst Abbruch.
 */
function convert_v6_to_v5_full(string $srcPath, string $dstPath, bool $emb_eingang_rueckweg = false): bool {
    $m = load_v6_model_full($srcPath);
    if ($m === null) return false;
    if (snai_emb_eingang($m) && !$emb_eingang_rueckweg) {
        echo "🚨 [I/O] Fatal: $srcPath traegt SNAI_V7 Bit 1 (Embedding-Eingangsfaktor). SNAI_V5 kann es nicht "
           . "tragen und die FP32-Engine rechnet ohne Faktor - Wandlung verweigert.\n";
        return false;
    }
    return save_model_stream([
        'vocab_size' => $m['vocab_size'], 'hidden_dim' => $m['hidden_dim'],
        'ffn_dim' => $m['ffn_dim'], 'ctx_size' => $m['ctx_size'],
        'num_layers' => $m['num_layers'], 'adam_t' => $m['adam_t'],
        'tensors' => $m['tensors'],
    ], $dstPath);
}
