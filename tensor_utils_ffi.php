<?php
// Dateiname: tensor_utils_ffi.php
// Funktion: FFI-Bruecke zu snai_tensor_utils.nim (libtensorutils.so).
//           Ersetzt die PHP-seitigen pack()/unpack()-Schleifen in
//           der Destille (merge_tributes()/upscale_matrix_stream())
//           durch native Aufrufe - gleiches Verhalten (inkl. der drei
//           Fuellwert-Faelle beim Upscale: Adam->0.0, Gewichte->Rauschen um
//           0.0, RMSNorm-Gains->Rauschen um 1.0 via pad_center), aber ohne
//           den Umweg ueber PHP-Arrays pro einzelnem Float.
//
// AUDIT-FIX: dieselbe libgomp-Exit-Race wie bei tensor_ffi_adapter.php /
// snai_inference.php (siehe deren Kommentare) - snai_tensor_utils.nim nutzt
// ebenfalls OpenMP ("||"-Schleifen). Ohne PASSIVE-Policy segfaultet der
// Prozess beim Beenden kurz nach dem letzten Kernel-Aufruf, weil libgomp
// seinen Worker-Thread-Pool noch im Uebergang in den Idle-Zustand hat.
// MUSS vor dem FFI::cdef()-Laden von libtensorutils.so gesetzt sein.
putenv('OMP_WAIT_POLICY=PASSIVE');

class SnaiTensorUtils {
    const SNAI_TYPE_FP32 = 1;
    const SNAI_TYPE_FP16 = 2;

    private static ?FFI $ffi = null;

    private static function ffi(): FFI {
        if (self::$ffi === null) {
            $lib_path = __DIR__ . '/libtensorutils.so';
            self::$ffi = FFI::cdef("
                void snai_tensor_merge(void* out_buf, void** in_buffers, int num_models, size_t elements, int dtype);
                void snai_tensor_upscale(void* in_buf, void* out_buf, int old_r, int old_c, int new_r, int new_c,
                                         float scale, float noise_factor, float pad_center, int is_adam, int dtype);
            ", $lib_path);
        }
        return self::$ffi;
    }

    // Eigene FFI-Instanz fuer den INT8-Weg: FFI::cdef loest jedes Symbol beim
    // Laden auf. Staenden die neuen Funktionen in der cdef oben, liesse sich mit
    // einer alten Lib auch merge()/upscale() nicht mehr laden.
    private static ?FFI $ffi_i8 = null;

    private static function ffi_i8(): FFI {
        if (self::$ffi_i8 === null) {
            self::$ffi_i8 = FFI::cdef("
                void snai_i8_dequant(void* q_in, void* scales, int rows, int cols, void* out_buf);
                void snai_i8_quant(void* in_buf, int rows, int cols, void* q_out, void* scales_out);
                void snai_i8_merge(void** q_in, void** scales_in, int num_models, int rows, int cols,
                                   void* q_out, void* scales_out);
                void snai_f32_avg(void** in_buffers, int num_models, size_t elements, void* out_buf);
            ", __DIR__ . '/libtensorutils.so');
        }
        return self::$ffi_i8;
    }

    // ---------------------------------------------------------------------
    // INT8-WEG (2026-11-08, messbuch snai/merge-int8-nim): Nim rechnet, PHP
    // orchestriert. Bytegleich zu den PHP-Fassungen in tensor_io.php
    // (dequantize_tensor_i8_php, quantize_tensor_i8_php, merge_v6_models_php).
    // ---------------------------------------------------------------------

    private static ?bool $verfuegbar = null;

    /**
     * true, wenn der Nim-Weg nutzbar ist: FFI da, Lib ladbar und neu genug
     * (kennt alle snai_i8_*). SNAI_TENSORUTILS_PHP=1 erzwingt den PHP-Weg
     * (Gegenprobe, Rueckfall). Ergebnis wird je Prozess einmal ermittelt.
     */
    public static function verfuegbar(): bool {
        if (getenv('SNAI_TENSORUTILS_PHP') === '1') return false;
        if (self::$verfuegbar === null) {
            try {
                // Alte Lib ohne INT8-Weg: FFI::cdef wirft beim Aufloesen der Symbole.
                self::$verfuegbar = class_exists('FFI') && is_file(__DIR__ . '/libtensorutils.so')
                    && self::ffi_i8() !== null;
            } catch (\Throwable $e) {
                self::$verfuegbar = false;
            }
        }
        return self::$verfuegbar;
    }

    /** Legt $n Puffer als void*[n] an; haelt die cdata in $halter am Leben. */
    private static function zeiger_feld(array $bufs, array &$halter): FFI\CData {
        $ffi = self::ffi_i8();
        $n = count($bufs);
        $feld = $ffi->new("void*[{$n}]");
        foreach (array_values($bufs) as $i => $b) {
            $len = strlen($b);
            $c = $ffi->new("char[" . max(1, $len) . "]");
            if ($len > 0) FFI::memcpy($c, $b, $len);
            $halter[] = $c;
            $feld[$i] = FFI::cast("void*", FFI::addr($c[0]));
        }
        return $feld;
    }

    /** Wie dequantize_tensor_i8_php(): INT8-Blob + Skalen (double) -> float32-Blob. */
    public static function i8_dequant(string $data, array $scales, int $rows, int $cols): string {
        $ffi = self::ffi_i8();
        $n = $rows * $cols;
        $q = $ffi->new("char[{$n}]"); FFI::memcpy($q, $data, $n);
        $sb = pack('e*', ...$scales);
        $s = $ffi->new("char[" . strlen($sb) . "]"); FFI::memcpy($s, $sb, strlen($sb));
        $o = $ffi->new("char[" . ($n * 4) . "]");
        $ffi->snai_i8_dequant(FFI::addr($q[0]), FFI::addr($s[0]), $rows, $cols, FFI::addr($o[0]));
        return FFI::string($o, $n * 4);
    }

    /** Wie quantize_tensor_i8_php(): float32-Blob -> ['data' => INT8-Blob, 'scales' => double[]]. */
    public static function i8_quant(string $binary, int $rows, int $cols): array {
        $ffi = self::ffi_i8();
        $n = $rows * $cols;
        $f = $ffi->new("char[" . ($n * 4) . "]"); FFI::memcpy($f, $binary, $n * 4);
        $q = $ffi->new("char[{$n}]");
        $s = $ffi->new("char[" . ($rows * 8) . "]");
        $ffi->snai_i8_quant(FFI::addr($f[0]), $rows, $cols, FFI::addr($q[0]), FFI::addr($s[0]));
        return ['data' => FFI::string($q, $n), 'scales' => array_values(unpack("e{$rows}", FFI::string($s, $rows * 8)))];
    }

    /**
     * Mischt N INT8-Tensoren. $qs: INT8-Blobs, $scale_raws: float32-Zeilenskalen
     * roh aus der Datei (ohne uint16-Zaehler). Rueckgabe [INT8-Blob, float32-Skalen roh].
     */
    public static function i8_merge(array $qs, array $scale_raws, int $rows, int $cols): array {
        $ffi = self::ffi_i8();
        $halter = [];
        $pq = self::zeiger_feld($qs, $halter);
        $ps = self::zeiger_feld($scale_raws, $halter);
        $n = $rows * $cols;
        $q = $ffi->new("char[{$n}]");
        $s = $ffi->new("char[" . ($rows * 4) . "]");
        $ffi->snai_i8_merge(FFI::cast("void**", FFI::addr($pq[0])), FFI::cast("void**", FFI::addr($ps[0])),
                            count($qs), $rows, $cols, FFI::addr($q[0]), FFI::addr($s[0]));
        return [FFI::string($q, $n), FFI::string($s, $rows * 4)];
    }

    /** Elementweises Mittel von N float32-Blobs, Summe in double (wie avg_floats in merge_v6_models_php). */
    public static function f32_avg(array $bufs): string {
        $len = strlen($bufs[0]);
        $el = intdiv($len, 4);
        if ($el === 0) return '';
        $ffi = self::ffi_i8();
        $halter = [];
        $p = self::zeiger_feld($bufs, $halter);
        $o = $ffi->new("char[{$len}]");
        $ffi->snai_f32_avg(FFI::cast("void**", FFI::addr($p[0])), count($bufs), $el, FFI::addr($o[0]));
        return FFI::string($o, $len);
    }

    /**
     * Mittelt N gleich lange Rohdaten-Buffer (Float32- oder Float16-Bytes)
     * elementweise. $buffers: Array von PHP-Binaerstrings, gleiche Laenge,
     * Laenge muss ein Vielfaches der Elementgroesse sein (4 Byte FP32 /
     * 2 Byte FP16). Rueckgabe: gemittelter Buffer, gleiche Laenge.
     */
    public static function merge(array $buffers, int $dtype = self::SNAI_TYPE_FP32): string {
        $num_models = count($buffers);
        if ($num_models === 0) return '';

        $bytes_per_elem = ($dtype === self::SNAI_TYPE_FP16) ? 2 : 4;
        $len = strlen($buffers[0]);
        $elements = intdiv($len, $bytes_per_elem);
        if ($elements === 0) return '';

        $ffi = self::ffi_i8();

        // AUDIT-FIX: FFI::cast("void*", $chardata) auf ein char[N]-Array
        // interpretiert die Array-Repraesentation selbst als Zeiger-Wert
        // (Muell) statt einen Zeiger AUF die Daten zu liefern - SIGSEGV bei
        // der ersten echten Nutzung. Richtig ist FFI::addr() auf das erste
        // Element, das liefert einen echten char*/void* auf den Puffer.
        $in_cdata = [];
        $in_ptrs = $ffi->new("void*[{$num_models}]");
        for ($i = 0; $i < $num_models; $i++) {
            $in_cdata[$i] = $ffi->new("char[{$len}]"); // owned=true (Default): PHP raeumt selbst auf
            FFI::memcpy($in_cdata[$i], $buffers[$i], $len);
            $in_ptrs[$i] = FFI::cast("void*", FFI::addr($in_cdata[$i][0]));
        }

        $out_cdata = $ffi->new("char[{$len}]");
        $ffi->snai_tensor_merge($out_cdata, FFI::cast("void**", $in_ptrs), $num_models, $elements, $dtype);

        return FFI::string($out_cdata, $len);
    }

    /**
     * Expandiert eine Matrix (Net2Net-Upscale). $in_buffer: alte Matrix,
     * roh, old_r*old_c Elemente. Rueckgabe: neue Matrix, roh, new_r*new_c
     * Elemente. $pad_center: neutrales Element fuer frisch expandierte
     * Zellen (0.0 fuer Gewichte, 1.0 fuer RMSNorm-Gains) - wird bei
     * $is_adam=true ignoriert (Adam-Zustand bekommt immer exakt 0.0).
     */
    public static function upscale(
        string $in_buffer, int $old_r, int $old_c, int $new_r, int $new_c,
        float $scale, float $noise_factor, float $pad_center, bool $is_adam,
        int $dtype = self::SNAI_TYPE_FP32
    ): string {
        $bytes_per_elem = ($dtype === self::SNAI_TYPE_FP16) ? 2 : 4;
        $ffi = self::ffi_i8();

        $in_len = strlen($in_buffer);
        $in_cdata = $ffi->new("char[{$in_len}]"); // owned=true (Default): PHP raeumt selbst auf
        if ($in_len > 0) FFI::memcpy($in_cdata, $in_buffer, $in_len);

        $out_len = $new_r * $new_c * $bytes_per_elem;
        $out_cdata = $ffi->new("char[{$out_len}]");

        $ffi->snai_tensor_upscale(
            $in_cdata, $out_cdata, $old_r, $old_c, $new_r, $new_c,
            $scale, $noise_factor, $pad_center, $is_adam ? 1 : 0, $dtype
        );

        return FFI::string($out_cdata, $out_len);
    }
}
