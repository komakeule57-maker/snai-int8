<?php
// Dateiname: tensor_ffi_adapter.php
// Funktion: FFI Adapter & Cortex Bridge zur Nim-Engine (Memory Edition)

/**
 * SYMBIO NANO-AI FRAMEWORK (Code-4372)
 * Modul: FFI Adapter & Cortex Bridge (Phase VIII - The Adam Persistence Update)
 * -------------------------------------------------------------------------
 * Info: Enthält OOM-Sicherheits-Checks & O(1) Speed-Boosts aus Audit-Phase.
 * AUDIT-FIX (V10): Adam-State (m, v) Extraktion vollständig implementiert!
 * AUDIT-FIX (V10.1): FFI::isNull() Guard verhindert stille Segfaults.
 * AUDIT-FIX (V10.2): Numerische Softmax-Stabilisierung gegen Float-Overflows.
 * AUDIT-FIX: OMP_WAIT_POLICY=PASSIVE gegen libgomp-Exit-Race (siehe snai_inference.php).
 *   Muss vor jedem FFI::cdef()-Laden von libcortex.so gesetzt sein, deshalb hier
 *   auf Datei-Ebene statt im Konstruktor - require_once laeuft garantiert zuerst.
 */

putenv('OMP_WAIT_POLICY=PASSIVE');

class SnaiCortexBridge {
    public $ffi;
    public $state_ptr;
    public $vocab_size, $hidden_dim, $ctx_size, $num_layers, $ffn_dim, $num_heads;
    /** PHASE 6 DES INT8-UMBAUS: true, wenn per $native_int8=true konstruiert
     *  (cortex_load_stream_i8() statt cortex_load_stream()) - steuert, ob
     *  forward()/train_step() intern die INT8- oder FP32-FFI-Funktion rufen. */
    public $is_int8 = false;

    private $global_map = [
        0 => ['w' => 'embeddings', 'm' => 'm_embeddings', 'v' => 'v_embeddings'],
        1 => ['w' => 'w_out', 'm' => 'm_w_out', 'v' => 'v_w_out'],
        2 => ['w' => 'rms_final', 'm' => 'm_rms_final', 'v' => 'v_rms_final']
    ];

    private $layer_map = [
        10 => ['w' => 'rms_att', 'm' => 'm_rms_att', 'v' => 'v_rms_att'],
        11 => ['w' => 'rms_ffn', 'm' => 'm_rms_ffn', 'v' => 'v_rms_ffn'],
        12 => ['w' => 'w_q', 'm' => 'm_w_q', 'v' => 'v_w_q'],
        13 => ['w' => 'w_k', 'm' => 'm_w_k', 'v' => 'v_w_k'],
        14 => ['w' => 'w_v', 'm' => 'm_w_v', 'v' => 'v_w_v'],
        15 => ['w' => 'w_o', 'm' => 'm_w_o', 'v' => 'v_w_o'],
        16 => ['w' => 'w_up', 'm' => 'm_w_up', 'v' => 'v_w_up'],
        17 => ['w' => 'w_down', 'm' => 'm_w_down', 'v' => 'v_w_down']
    ];

    // Caching für FFI Buffer (Verhindert GC Thrashing in der Generierungs-Schleife)
    private $cached_c_logits = null;

     /**
     * Lädt das Modell direkt über Nim von der Festplatte (OOM-Sicher).
     *
     * PHASE 6 DES INT8-UMBAUS:
     * $native_int8=true laedt eine SNAI_V6-Datei
     * DIREKT nativ in INT8 (cortex_load_stream_i8()) statt sie erst als FP32
     * zu laden und dann zu quantisieren (quantize_to_int8() - der Phase-5-Weg
     * fuer FRISCH trainierte Checkpoints). Fuer bereits INT8-trainierte
     * SNAI_V6-Checkpoints (z.B. aus train_worker.php/train_cluster.php) ist
     * dies der richtige, direkte Ladeweg - $filepath muss dann eine
     * SNAI_V6-Datei sein, sonst schlaegt das Laden fehl.
     */
    public function __construct(string $filepath, int $num_heads = 1, bool $native_int8 = false,
                                bool $quant_adam_memory = false,
                                bool $quant_acts_memory = false,
                                bool $quant_acts_in_memory = false,
                                bool $lora_preload = false) {
        // Diagnose-Ausweg: erlaubt einen Debug-Build (ohne -d:danger, mit
        // Bounds-Checks) zu laden, ohne die produktive libcortex.so zu
        // ersetzen - wichtig, solange nebenher ein Trainingslauf darauf
        // zugreift.
        $lib_path = getenv('SNAI_CORTEX_LIB') ?: (__DIR__ . '/libcortex.so');
        
        $this->ffi = FFI::cdef("
            void* cortex_init(int vocab_size, int hidden_dim, int ffn_dim, int ctx_size, int num_layers, int num_heads);
            void* cortex_load_stream(const char* filepath, int num_heads);
            float cortex_train_step(void* state, int* raw_inputs, int* raw_targets, int* raw_mask, int num_tokens, float lr);
            void cortex_free(void* state);
            void cortex_reset_cache(void* state);
            void cortex_forward(void* state, int* raw_tokens, int num_tokens, float* raw_logits);
            void cortex_extract_layer(void* state, int layer_idx, int tensor_type, float* raw_weights, int num_weights);
            void cortex_extract_adam_layer(void* state, int layer_idx, int tensor_type, bool is_variance, float* raw, int size);
            void cortex_load_layer(void* state, int layer_idx, int tensor_type, float* raw_weights, int num_weights);
            
            // --- NEU: Phase VI (OpenCL & Utils) ---
            void cortex_init_gpu();
            int get_vocab_size(void* state);
            int get_ctx_size(void* state);

            // --- NEU: 2026-08-09 ('Engine-/Framework-
            // Verbesserungen', Punkt 1) - adam_t writer-seitig persistieren ---
            int cortex_get_adam_t(void* state);

            // --- NEU: Phase XI (Diagnose & Guards, seit V11.2-V11.8) ---
            // Bislang in der .so vorhanden, aber aus PHP nicht aufrufbar -
            // Ursache dreier Fehlmessungen.
            int   cortex_get_load_error();
            int   cortex_validate(void* state);
            float cortex_bench_gpu(void* state, int iters);
            void  cortex_profile_reset();
            float cortex_profile_get(int idx);
            int   cortex_get_threads();
            void  cortex_set_gpu_threshold(int elems);
            int   cortex_get_gpu_threshold();
            void  cortex_set_gain_guard(int enabled);

            // --- NEU: V11.9 (Etappe 1 - gebuendeltes w_out) ---
            void  cortex_set_batched_wout(int enabled);
            int   cortex_get_batched_wout();

            // --- AUDIT: gebuendelte Attention (layer-major statt position-major) ---
            void  cortex_set_batched_attention(int enabled);
            int   cortex_get_batched_attention();

            // --- AUDIT: LR-Boost fuer frisch Net2Net-expandierte Parameter ---
            void  cortex_set_growth_boundary(int old_dim, int old_ffn, int old_layers, float boost);

            // --- Update 2026-08-09 (Nachruest-Paket #8/#9):
            // Backend-/Gradient-Norm-Telemetrie. Kein aktiver Trainingslauf zum
            // Zeitpunkt dieser Ergaenzung - Deklaration und .so-Rebuild laufen
            // zusammen, kein Wiederholungsfall des Weight-Decay-Vorfalls von oben.
            int   cortex_get_gpu_backend();
            float cortex_get_last_grad_norm();

            // --- Update 2026-08-09: cortex_set_weight_decay()/
            // cortex_get_weight_decay() waren seit dem Vorfall vom 2026-08-07
            // (siehe Kommentar direkt unten) absichtlich NICHT deklariert -
            // die Wrapper-Methoden set_weight_decay()/get_weight_decay()
            // weiter unten in dieser Klasse existierten dadurch, waren aber
            // nie wirklich aufrufbar. libcortex.so wurde seither
            // mehrfach neu gebaut (adam_t-Getter, GradNorm,
            // GPU-Backend, Dropout) - Deklaration und .so sind jetzt wieder
            // synchron, dieselbe Regel wie beim GradNorm-Update angewendet.
            void  cortex_set_weight_decay(float wd);
            float cortex_get_weight_decay();

            // --- Update 2026-08-09 (Nachruest-Paket #6
            // 'Dropout', umgesetzt im Rahmen 'Engine-/Framework-
            // Verbesserungen'): Deklaration und .so-Rebuild liefen wieder
            // zusammen, kein Trainingslauf aktiv zum Zeitpunkt dieser
            // Aenderung (der laufende Lauf wurde dafuer
            // beendet).
            void  cortex_set_dropout_rate(float rate);
            float cortex_get_dropout_rate();

            // --- Update 2026-08-15 ('Naechste Schritte' Punkt 7
            // 'Label-Smoothing'): gleiches Muster wie Weight-Decay/Dropout oben -
            // Deklaration und .so-Rebuild laufen zusammen (kein aktiver
            // Trainingslauf zum Zeitpunkt dieser Aenderung, der laufende
            // Lauf wurde dafuer abgebrochen), kein Wiederholungsfall
            // des Weight-Decay-Vorfalls von oben.
            void  cortex_set_label_smoothing(float eps);
            float cortex_get_label_smoothing();

            // --- PHASE 5 DES INT8-UMBAUS - Deklaration und .so-Rebuild liefen
            // zusammen (siehe AUDIT-FIX-Kommentar oben zum Weight-Decay-
            // Vorfall, gleiche Disziplin hier angewendet). ---
            int   cortex_quantize_from_fp32(void* state);
            float cortex_train_step_i8(void* state, int* raw_inputs, int* raw_targets, int* raw_mask, int num_tokens, float lr);
            void  cortex_rescale_weights(void* state);
            int   cortex_validate_i8(void* state);
            void  cortex_extract_layer_i8(void* state, int layer_idx, int tensor_type, signed char* raw_i8, float* raw_scale, int size);
            void  cortex_set_i8_float_adam(int on);
            int   cortex_get_i8_float_adam();
            void  cortex_set_i8_error_feedback(int on);
            int   cortex_get_i8_error_feedback();

            // --- FULL-INT8 SCHRITT 1: ganzzahliger Backward-Pfad ---
            void  cortex_set_i8_int_backward(int on);
            int   cortex_get_i8_int_backward();
            void  cortex_set_batched_i8(int on);
            void  cortex_set_i8_int_gradacc(int on);
            int   cortex_get_i8_int_gradacc();
            void  cortex_set_i8_grad_stochastic(int on);
            void  cortex_set_i8_quant_adam(int on);
            int   cortex_get_i8_quant_adam();
            void  cortex_set_quant_adam_memory(int on);
            void  cortex_set_i8_quant_acts(int on);
            void  cortex_set_quant_acts_memory(int on);
            int   cortex_get_quant_acts_memory(void* state);

            // --- ARM C (LoRA-Armvergleich): nur letzte n Schichten ---
            int   cortex_set_train_last_layers(void* state, int n);
            int   cortex_get_train_last_layers(void* state);
            int   cortex_count_trainable_i8(void* state);
            void  cortex_set_quant_acts_in_memory(int on);
            void  cortex_set_i8_silu_lut(int on);
            void  cortex_set_i8_gpu_backward(int on);
            void  cortex_set_i8_cpu_only(int on);
            int   cortex_get_gpu_bw_calls();
            int   cortex_i8_error_feedback_active(void* state);
            int   cortex_tie_embeddings(void* state);
            int   cortex_get_tied_embeddings(void* state);
            void  cortex_reset_i8_error_feedback(void* state);
            float cortex_gpu_weight_drift(void* state);
            int   cortex_get_gpu_gradacc_calls();
            int   cortex_get_quant_acts_in_memory(void* state);
            int   cortex_get_i8_quant_acts();
            int   cortex_get_quant_adam_memory(void* state);

            // --- PHASE 6 DES INT8-UMBAUS: natives SNAI_V6-Laden + INT8-Forward-Pass
            // (Inferenz/Held-out-Eval ohne FP32-Zwischenstand). ---
            void* cortex_load_stream_i8(const char* filepath, int num_heads);
            void  cortex_forward_i8(void* state, int* raw_tokens, int num_tokens, float* raw_logits);

            // --- LoRA (2026-08-29) ---
            int   cortex_lora_enable(void* state, int rank, float alpha, int slot_mask, int freeze_base, int seed);
            int   cortex_lora_active(void* state);
            int   cortex_lora_rank(void* state);
            int   cortex_lora_mask(void* state);
            int   cortex_lora_base_frozen(void* state);
            int   cortex_lora_params(void* state);
            int   cortex_lora_extract(void* state, int layer, int slot, int is_b, float* raw, int size);
            int   cortex_lora_load(void* state, int layer, int slot, int is_b, float* raw, int size);
            int   cortex_lora_extract_adam(void* state, int layer, int slot, int is_b, int is_v, float* raw, int size);
            int   cortex_lora_load_adam(void* state, int layer, int slot, int is_b, int is_v, float* raw, int size);
            int   cortex_lora_set_adam_t(void* state, int t);
            int   cortex_lora_base_opt_freed(void* state);
            void  cortex_set_lora_preload(int on);
            int   cortex_get_lora_preload();
            void  cortex_lora_disable(void* state);
        ", $lib_path);
        // AUDIT-FIX (2026-08-07): cortex_set_weight_decay()/cortex_get_weight_decay()
        // NICHT in cdef() deklarieren, solange die deployte libcortex.so nicht neu
        // gebaut ist - FFI::cdef() resolved ALLE deklarierten Symbole SOFORT beim
        // Laden, auch wenn sie nie aufgerufen werden. Hat den laufenden 256-Dim-
        // Trainingslauf bei Epoche 11 mit "Failed resolving C function
        // 'cortex_set_weight_decay'" abstuerzen lassen. Stand damals
        // "Deploy OFFEN" - erst nach echtem .so-Rebuild wieder aktivieren.

        require_once __DIR__ . '/tensor_io.php';
        // PHASE 6 DES INT8-UMBAUS: $native_int8 braucht load_model_header_any()
        // (versteht SNAI_V5 UND SNAI_V6) statt des bestehenden load_model_header()
        // (nur SNAI_V5, wuerde bei einer V6-Datei sofort sterben).
        $header = $native_int8 ? load_model_header_any($filepath) : load_model_header($filepath);
        // Code-Review 2026-11-05 (A3-Rest): die() endet mit Exitcode 0; exit(1) meldet den Fehler dem Aufrufer.
        if (!$header) { fwrite(STDERR, "🚨 Fatal: Konnte Modell-Header nicht lesen.\n"); exit(1); }
        if ($native_int8 && !snai_is_int8_magic($header['magic'])) {
            fwrite(STDERR, "🚨 Fatal: \$native_int8=true erwartet eine SNAI_V6/V7-Datei, gefunden: {$header['magic']}\n");
            exit(1);
        }

        $this->vocab_size = $header['vocab_size'];
        $this->hidden_dim = $header['hidden_dim'];
        $this->ctx_size   = $header['ctx_size'];
        $this->num_layers = $header['num_layers'];
        $this->ffn_dim    = $header['ffn_dim'];
        $this->num_heads  = $num_heads;
        $this->is_int8    = $native_int8;

        // SCHRITT 3 (Speicherumbau): MUSS zwischen cdef() und dem Laden stehen -
        // cortex_init() entscheidet dort ueber die Allokation der Momente, und
        // der Schalter wirkt nur ueber DIESE FFI-Instanz (siehe Kommentar bei
        // set_quant_adam_memory weiter unten).
        if ($quant_adam_memory) {
            $this->ffi->cortex_set_quant_adam_memory(1);
        }
        if ($quant_acts_memory) {
            $this->ffi->cortex_set_quant_acts_memory(1);
        }
        if ($quant_acts_in_memory) {
            $this->ffi->cortex_set_quant_acts_in_memory(1);
        }
        // LoRA-SPEICHERARM: muss ebenfalls VOR dem Laden stehen. Der erste
        // Anlauf gab die Puffer nach dem Laden wieder frei und sparte
        // nachweislich NICHTS - der Spitzenverbrauch entsteht beim Laden, und
        // deallocShared() gibt die Seiten an Nims Arena zurueck, nicht ans
        // Betriebssystem. Wirksam ist nur, sie gar nicht erst anzulegen.
        if ($lora_preload) {
            $this->ffi->cortex_set_lora_preload(1);
        }

        $this->state_ptr = $native_int8
            ? $this->ffi->cortex_load_stream_i8($filepath, $this->num_heads)
            : $this->ffi->cortex_load_stream($filepath, $this->num_heads);

        if ($lora_preload) {
            $this->ffi->cortex_set_lora_preload(0);
        }

        // Globalen Schalter sofort zuruecksetzen, damit ein spaeter erzeugtes
        // Modell in derselben Instanz nicht unbeabsichtigt mitquantisiert.
        if ($quant_adam_memory) {
            $this->ffi->cortex_set_quant_adam_memory(0);
        }
        if ($quant_acts_memory) {
            $this->ffi->cortex_set_quant_acts_memory(0);
        }
        if ($quant_acts_in_memory) {
            $this->ffi->cortex_set_quant_acts_in_memory(0);
        }

        // AUDIT-FIX: Sauberer Null-Pointer Check via FFI::isNull
        // PHP-FFI liefert fuer NULL aus void* ein PHP-null, FFI::isNull() wirft darauf einen TypeError.
        if ($this->state_ptr === null || FFI::isNull($this->state_ptr)) {
            // exit(1) statt die(): die() mit Text endet mit Status 0, der Abbruch waere fuer den Aufrufer ein Erfolg.
            fwrite(STDERR, "🚨 Fatal: Nim C-Core konnte den Binär-Stream nicht laden (Pointer ist NULL, Fehlercode " . $this->ffi->cortex_get_load_error() . ")!\n");
            exit(1);
        }
        // EMB-EINGANG: traegt die Datei Bit 1, MUSS die Engine den Faktor gesetzt haben. Eine aeltere libcortex.so
        // uebergeht unbekannte Flags wortlos und rechnete das Modell ohne Faktor (gemessen: 6,68 statt 2,62).
        if ($native_int8 && snai_emb_eingang($header) && $this->emb_eingang_aktiv() !== true) {
            fwrite(STDERR, "🚨 Fatal: $filepath traegt SNAI_V7 Bit 1 (Embedding-Eingangsfaktor), die Engine hat ihn "
                 . "nicht gesetzt (libcortex.so zu alt?). Ohne Faktor waere jede Rechnung falsch.\n");
            exit(1);
        }

        // Update 2026-08-09 ("Engine-/Framework-Verbesserungen",
        // Punkt 2): cortex_validate() existierte bereits vollstaendig (prueft
        // tote Gain-Kanaele, NaN/Inf in Gewichten, adam_t=0 trotz warmem m/v),
        // wurde aber nirgends im PHP-Code aufgerufen - eine fertige Pruefung, die
        // niemand nutzte. Nicht fatal (gleiche Vorsicht wie beim Held-out-Eval):
        // ein auffaelliger Befund soll sichtbar werden, aber keinen laufenden
        // Trainings-/Inferenzlauf abwuergen, der trotzdem funktionsfaehig sein
        // kann (z.B. adam_t=0 bremst nur, sprengt nichts, siehe V11.2b-Kommentar
        // in cortex.nim).
        if ($native_int8) {
            // PHASE 6 DES INT8-UMBAUS: cortex_validate() (FP32-Felder) passt
            // nicht auf einen INT8-State - cortex_validate_i8() stattdessen.
            $validation_flags = $this->ffi->cortex_validate_i8($this->state_ptr);
            if ($validation_flags > 0) {
                fwrite(STDERR, "⚠️  [Validate-INT8] Checkpoint '$filepath' auffaellig (Flags=$validation_flags, Bit 1=ungueltige Zeilen-Skala, Bit 2=NaN/Inf in Gains).\n");
            }
        } else {
            $validation_flags = $this->ffi->cortex_validate($this->state_ptr);
            if ($validation_flags > 0) {
                $issues = [];
                if ($validation_flags & 1) $issues[] = 'tote Gain-Kanaele';
                if ($validation_flags & 2) $issues[] = 'NaN/Inf in Gewichten';
                if ($validation_flags & 4) $issues[] = 'adam_t=0 trotz warmem m/v';
                fwrite(STDERR, "⚠️  [Validate] Checkpoint '$filepath' auffaellig (Flags=$validation_flags): " . implode(', ', $issues) . "\n");
            }
        }

        // Buffer einmalig allokieren
        $this->cached_c_logits = $this->ffi->new("float[{$this->vocab_size}]");
    }

    public function init_gpu() {
        $this->ffi->cortex_init_gpu();
    }

    // Update 2026-08-09 (Nachruest-Paket #8 "Backend-/Hardware-
    // Telemetrie" und #9 "Gradient-Norm-Logging"): 0=keins, 1=OpenCL, 2=CUDA.
    public function get_gpu_backend(): int {
        return $this->ffi->cortex_get_gpu_backend();
    }

    public function get_last_grad_norm(): float {
        return $this->ffi->cortex_get_last_grad_norm();
    }

    // Update 2026-10-10 (Segmentpruefung): Anteil einer Tensorgruppe an der
    // Gradienten-Quadratsumme des letzten Schritts (0 Embedding, 1 Q/K, 2 V/O,
    // 3 FFN, 4 Rest, 100+l Q/K der Schicht l). Eigenes cdef() statt einer Zeile
    // im grossen Block oben: cdef() loest eager auf, eine aeltere libcortex.so
    // ohne das Symbol soll weiter ladbar bleiben. null = Symbol fehlt oder
    // Index unbekannt.
    // RAM-AUFRAEUMEN 2026-10-15 (Doku 6ao): Speichern direkt aus Nim, bytegleich zu
    // save_model_stream_i8($this->extract_state_i8(), $pfad), aber ohne den ganzen Zustand im PHP-Speicher.
    // Eigenes cdef() wie bei get_last_grad_share(): eine aeltere libcortex.so ohne das Symbol bleibt ladbar.
    // true = geschrieben, false = Schreiben gescheitert, null = nicht verfuegbar (Aufrufer nimmt den alten Weg).
    private $ffi_save = null;
    public function save_stream_i8(string $pfad): ?bool {
        // LoRA-Speicherarm: der alte Weg wirft dort die passende Fehlermeldung, also ihm ueberlassen.
        if ($this->lora_base_opt_freed()) return null;
        if ($this->ffi_save === null) {
            try {
                $this->ffi_save = FFI::cdef("int cortex_save_stream_i8(void* state, const char* pfad, int vocab, int dim, int ffn, int ctx, int layers);",
                    getenv('SNAI_CORTEX_LIB') ?: (__DIR__ . '/libcortex.so'));
            } catch (\Throwable $e) {
                $this->ffi_save = false;
                fwrite(STDERR, "⚠️  [Speichern] libcortex.so ohne cortex_save_stream_i8 - alter PHP-Weg (ganzer Zustand im Speicher).\n");
            }
        }
        if ($this->ffi_save === false) return null;
        return $this->ffi_save->cortex_save_stream_i8($this->ffi_save->cast("void*", $this->state_ptr), $pfad,
            $this->vocab_size, $this->hidden_dim, $this->ffn_dim, $this->ctx_size, $this->num_layers) === 1;
    }

    // EMB-EINGANG / FFN-SKIP (2026-11-03): eigenes cdef() wie bei save_stream_i8 - eine aeltere libcortex.so ohne
    // die Symbole bleibt ladbar, die Methoden liefern dann null. null heisst "kann die Bibliothek nicht", nie "aus".
    private $ffi_neu = null;
    private function ffi_neu() {
        if ($this->ffi_neu === null) {
            try {
                $this->ffi_neu = FFI::cdef("
                    int   cortex_set_emb_eingang(void* state, int an);
                    int   cortex_get_emb_eingang(void* state);
                    float cortex_get_emb_eingang_faktor(void* state);
                    int   cortex_ffn_aus(void* state, int layer);
                    int   cortex_ffn_zweig_null(void* state, int layer);
                    int   cortex_ffn_zweig_uebersprungen(void* state, int layer);",
                    getenv('SNAI_CORTEX_LIB') ?: (__DIR__ . '/libcortex.so'));
            } catch (\Throwable $e) {
                $this->ffi_neu = false;
            }
        }
        return $this->ffi_neu;
    }
    /** EMB-EINGANG einschalten (nur INT8 mit Tying, nur an der Genesis - das prueft train_worker.php). Wirkung danach. */
    public function emb_eingang_setzen(): ?bool {
        $f = $this->ffi_neu();
        return $f ? $f->cortex_set_emb_eingang($f->cast("void*", $this->state_ptr), 1) === 1 : null;
    }
    /** WIRKUNG: rechnet die Engine das Embedding am Eingang mal sqrt(dim)? null = Bibliothek kennt das nicht. */
    public function emb_eingang_aktiv(): ?bool {
        $f = $this->ffi_neu();
        return $f ? $f->cortex_get_emb_eingang($f->cast("void*", $this->state_ptr)) === 1 : null;
    }
    public function emb_eingang_faktor(): ?float {
        $f = $this->ffi_neu();
        return $f ? (float)$f->cortex_get_emb_eingang_faktor($f->cast("void*", $this->state_ptr)) : null;
    }
    /** FFN-AUS an der Genesis: rms_ffn und w_down der Schicht exakt 0. Wirkung (Werte null) danach. */
    public function ffn_aus(int $layer): ?bool {
        $f = $this->ffi_neu();
        return $f ? $f->cortex_ffn_aus($f->cast("void*", $this->state_ptr), $layer) === 1 : null;
    }
    public function ffn_zweig_null(int $layer): ?bool {
        $f = $this->ffi_neu();
        return $f ? $f->cortex_ffn_zweig_null($f->cast("void*", $this->state_ptr), $layer) === 1 : null;
    }
    /** Ueberspringt die Engine den Zweig (Erkennung an, Werte null, kein Dropout, kein LoRA auf w_up/w_down)? */
    public function ffn_zweig_uebersprungen(int $layer): ?bool {
        $f = $this->ffi_neu();
        return $f ? $f->cortex_ffn_zweig_uebersprungen($f->cast("void*", $this->state_ptr), $layer) === 1 : null;
    }

    private $ffi_grad_share = null;
    public function get_last_grad_share(int $idx): ?float {
        if ($this->ffi_grad_share === null) {
            try {
                $this->ffi_grad_share = FFI::cdef("float cortex_get_last_grad_share(int idx);",
                    getenv('SNAI_CORTEX_LIB') ?: (__DIR__ . '/libcortex.so'));
            } catch (\Throwable $e) {
                $this->ffi_grad_share = false;
            }
        }
        if ($this->ffi_grad_share === false) return null;
        $v = $this->ffi_grad_share->cortex_get_last_grad_share($idx);
        return $v < 0 ? null : (float)$v;
    }

    // Update 2026-08-08 ("Held-out-Set + periodische Eval"):
    // reset_cache()/forward() waren als C-Symbole bereits seit Laengerem in
    // cdef() deklariert (siehe oben, cortex_reset_cache/cortex_forward -
    // genutzt intern von generate_next_token()), aber nie als eigene
    // oeffentliche Methoden freigelegt. Reine Ergaenzung, kein neues
    // cdef()-Symbol, kein .so-Rebuild-Risiko (siehe AUDIT-FIX-Kommentar beim
    // weight_decay-Vorfall oben).

    public function reset_cache(): void {
        $this->ffi->cortex_reset_cache($this->state_ptr);
    }

    /**
     * Reiner Forward-Pass ohne Training - fuettert $tokens sequentiell in den
     * bestehenden KV-Cache (siehe reset_cache()) und liefert die Logits fuer
     * die Vorhersage NACH dem letzten uebergebenen Token zurueck. Dieselbe
     * Semantik wie generate_next_token(), nur ohne Sampling/Penalty - der
     * Aufrufer bekommt den rohen FFI-Puffer (kein PHP-Array-Kopieren, siehe
     * "VETO-FIX" bei $cached_c_logits oben). Fuer eine ganze Sequenz: Token
     * fuer Token aufrufen (siehe eval_held_out.php), nicht das Array am
     * Stueck uebergeben - cortex_forward() liefert nur Logits fuer die
     * JEWEILS LETZTE Position.
     */
    public function forward(array $tokens): FFI\CData {
        $num = count($tokens);
        $c_in = $this->ffi->new("int[$num]");
        foreach ($tokens as $i => $v) $c_in[$i] = $v;
        $c_logits = $this->cached_c_logits;
        // PHASE 6 DES INT8-UMBAUS: bei $native_int8-Konstruktion laeuft der
        // echte INT8-Forward-Pass (cortex_forward_i8, matVecMulI8 intern) -
        // sonst unveraendert der bestehende FP32-Pfad.
        if ($this->is_int8) {
            $this->ffi->cortex_forward_i8($this->state_ptr, $this->ffi->cast("int*", $c_in), $num, $this->ffi->cast("float*", $c_logits));
        } else {
            $this->ffi->cortex_forward($this->state_ptr, $this->ffi->cast("int*", $c_in), $num, $this->ffi->cast("float*", $c_logits));
        }
        return $c_logits;
    }

    public function set_growth_boundary(int $old_dim, int $old_ffn, int $old_layers, float $boost): void {
        $this->ffi->cortex_set_growth_boundary($old_dim, $old_ffn, $old_layers, $boost);
    }

    // --- Diagnose-Wrapper (Phase XI) ---

    public function get_threads(): int {
        return $this->ffi->cortex_get_threads();
    }

    public function get_load_error(): int {
        return $this->ffi->cortex_get_load_error();
    }

    /** Bitmaske: 1=tote Gain-Kanaele 2=NaN/Inf 4=adam_t=0 trotz warmem m/v. -1=kein State. */
    public function validate(): int {
        return $this->ffi->cortex_validate($this->state_ptr);
    }

    /** Reine GPU-Roundtrip-Latenz in ms (Mittel ueber $iters Aufrufe). */
    public function bench_gpu(int $iters = 1000): float {
        return $this->ffi->cortex_bench_gpu($this->state_ptr, $iters);
    }

    public function profile_reset(): void {
        $this->ffi->cortex_profile_reset();
    }

    /** idx: 0 matVecMul-GPU 1 matVecMul-CPU 2 backwardAcc-GPU 3 backwardAcc-CPU
     *       4 Attention-Backward 5 Clip+Adam 6 Step gesamt. Rueckgabe in ms. */
    public function profile_get(int $idx): float {
        return $this->ffi->cortex_profile_get($idx);
    }

    public function set_gpu_threshold(int $elems): void {
        $this->ffi->cortex_set_gpu_threshold($elems);
    }

    public function get_gpu_threshold(): int {
        return $this->ffi->cortex_get_gpu_threshold();
    }

    public function set_gain_guard(bool $enabled): void {
        $this->ffi->cortex_set_gain_guard($enabled ? 1 : 0);
    }

    /** V11.9: schaltet den gebuendelten w_out-Pfad ein (Standard: aus). */
    public function set_batched_wout(bool $enabled): void {
        $this->ffi->cortex_set_batched_wout($enabled ? 1 : 0);
    }

    public function get_batched_wout(): int {
        return $this->ffi->cortex_get_batched_wout();
    }

    /** AUDIT: schaltet den gebuendelten (layer-major) Attention-Pfad ein (Standard: aus). */
    public function set_batched_attention(bool $enabled): void {
        $this->ffi->cortex_set_batched_attention($enabled ? 1 : 0);
    }

    /** AdamW-Style Weight-Decay, dekorreliert vom Adam-Update. Default 0.0
     *  (kein Aufruf) verhaelt sich identisch zum bisherigen reinen Adam. */
    public function set_weight_decay(float $wd): void {
        $this->ffi->cortex_set_weight_decay($wd);
    }

    public function get_weight_decay(): float {
        return $this->ffi->cortex_get_weight_decay();
    }

    /** Dropout-Rate fuer die FFN-Aktivierung (0.0 = No-Op, Default). Greift
     *  NUR in train_step(), nie in forward() - siehe cortex.nim-Kommentar zu
     *  applyDropoutForward(). Obergrenze 0.9 wird engine-seitig erzwungen. */
    public function set_dropout_rate(float $rate): void {
        $this->ffi->cortex_set_dropout_rate($rate);
    }

    public function get_dropout_rate(): float {
        return $this->ffi->cortex_get_dropout_rate();
    }

    /** 2026-10-16: Weight-Decay auf den Embeddings (1 = an, Vorgabe; 0 = aus). null = alte Bibliothek ohne Symbol. */
    public function set_wd_embeddings(bool $an): ?bool {
        static $f = null;
        if ($f === null) {
            $lib = getenv('SNAI_CORTEX_LIB') ?: (__DIR__ . '/libcortex.so');
            try { $f = FFI::cdef("void cortex_set_wd_embeddings(int e); int cortex_get_wd_embeddings();", $lib); }
            catch (\Throwable $e) { $f = false; }
        }
        if ($f === false) return null;
        $f->cortex_set_wd_embeddings($an ? 1 : 0);
        return $f->cortex_get_wd_embeddings() === ($an ? 1 : 0);
    }

    public function set_label_smoothing(float $eps): void {
        $this->ffi->cortex_set_label_smoothing($eps);
    }

    public function get_label_smoothing(): float {
        return $this->ffi->cortex_get_label_smoothing();
    }

    /** Adam-Bias-Correction-Schrittzaehler, siehe extract_state()/adam_t. */
    public function get_adam_t(): int {
        return $this->ffi->cortex_get_adam_t($this->state_ptr);
    }

    public function get_batched_attention(): int {
        return $this->ffi->cortex_get_batched_attention();
    }

    public function __destruct() {
        if ($this->state_ptr !== null && !FFI::isNull($this->state_ptr)) {
            try { $this->ffi->cortex_free($this->state_ptr); } catch (Throwable $e) {}
            $this->state_ptr = null;
        }
    }

    public function extract_state(): array {
        $state = [
            'magic' => 'SNAI_V5',
            'vocab_size' => $this->vocab_size, 'hidden_dim' => $this->hidden_dim,
            'ffn_dim' => $this->ffn_dim,
            'ctx_size' => $this->ctx_size, 'num_layers' => $this->num_layers,
            'num_heads' => $this->num_heads,
            // Update 2026-08-09 ("Engine-/Framework-Verbesserungen", Punkt 1):
            // Adam-Bias-Correction-Schrittzaehler - vorher nie extrahiert,
            // ging bei jedem Speichern verloren. save_model_stream() schreibt
            // ihn als den vom Loader bereits erwarteten optionalen
            // int32-Trailer (siehe cortex.nim, "withT"-Logik).
            'adam_t' => $this->ffi->cortex_get_adam_t($this->state_ptr),
            'tensors' => ['global' => [], 'layers' => []]
        ];

        $size_emb = $this->vocab_size * $this->hidden_dim;
        $size_rms = $this->hidden_dim;
        $size_qkv = $this->hidden_dim * $this->hidden_dim;
        $size_up = $this->ffn_dim * $this->hidden_dim;
        
        $sizes = [
            0 => $size_emb, 1 => $size_emb, 2 => $size_rms,
            10 => $size_rms, 11 => $size_rms,
            12 => $size_qkv, 13 => $size_qkv, 14 => $size_qkv, 15 => $size_qkv,
            16 => $size_up, 17 => $size_up
        ];

        // AUDIT-FIX: Extrahiere nun Gewichte (w), Momentum (m) UND Varianz (v) für Adam!
        foreach ($this->global_map as $type => $keys) {
            $c_array = $this->ffi->new("float[{$sizes[$type]}]");
            
            // 1. Gewichte
            $this->ffi->cortex_extract_layer($this->state_ptr, -1, $type, $this->ffi->cast("float*", $c_array), $sizes[$type]);
            $state['tensors']['global'][$keys['w']] = FFI::string($c_array, $sizes[$type] * 4);
            
            // 2. Adam Momentum (m)
            $this->ffi->cortex_extract_adam_layer($this->state_ptr, -1, $type, false, $this->ffi->cast("float*", $c_array), $sizes[$type]);
            $state['tensors']['global'][$keys['m']] = FFI::string($c_array, $sizes[$type] * 4);
            
            // 3. Adam Variance (v)
            $this->ffi->cortex_extract_adam_layer($this->state_ptr, -1, $type, true, $this->ffi->cast("float*", $c_array), $sizes[$type]);
            $state['tensors']['global'][$keys['v']] = FFI::string($c_array, $sizes[$type] * 4);
        }

        for ($l = 0; $l < $this->num_layers; $l++) {
            $layer = [];
            foreach ($this->layer_map as $type => $keys) {
                $c_array = $this->ffi->new("float[{$sizes[$type]}]");
                
                // 1. Gewichte
                $this->ffi->cortex_extract_layer($this->state_ptr, $l, $type, $this->ffi->cast("float*", $c_array), $sizes[$type]);
                $layer[$keys['w']] = FFI::string($c_array, $sizes[$type] * 4);
                
                // 2. Adam Momentum (m)
                $this->ffi->cortex_extract_adam_layer($this->state_ptr, $l, $type, false, $this->ffi->cast("float*", $c_array), $sizes[$type]);
                $layer[$keys['m']] = FFI::string($c_array, $sizes[$type] * 4);
                
                // 3. Adam Variance (v)
                $this->ffi->cortex_extract_adam_layer($this->state_ptr, $l, $type, true, $this->ffi->cast("float*", $c_array), $sizes[$type]);
                $layer[$keys['v']] = FFI::string($c_array, $sizes[$type] * 4);
            }
            $state['tensors']['layers'][$l] = $layer;
        }

        return $state;
    }

    public function train_step(array $inputs, array $targets, array $mask, float $lr): float {
        $num_tokens = count($inputs);
        if ($num_tokens > $this->ctx_size) {
            $num_tokens = $this->ctx_size;
            $inputs = array_slice($inputs, -$num_tokens);
            $targets = array_slice($targets, -$num_tokens);
            $mask = array_slice($mask, -$num_tokens);
        }

        if ($num_tokens === 0) return 0.0;

        $c_in = $this->ffi->new("int[$num_tokens]");
        $c_tg = $this->ffi->new("int[$num_tokens]");
        $c_mask = $this->ffi->new("int[$num_tokens]");
        foreach ($inputs as $i => $v) $c_in[$i] = $v;
        foreach ($targets as $i => $v) $c_tg[$i] = $v;
        foreach ($mask as $i => $v) $c_mask[$i] = $v ? 1 : 0;

        return $this->ffi->cortex_train_step($this->state_ptr, $this->ffi->cast("int*", $c_in), $this->ffi->cast("int*", $c_tg), $this->ffi->cast("int*", $c_mask), $num_tokens, $lr);
    }

    // --- PHASE 5 DES INT8-UMBAUS ---

    /** Quantisiert die aktuell geladenen FP32-Gewichte in-memory nach INT8
     *  (Design-Entscheidung #1: Per-Zeile-Skala). NACH diesem Aufruf nur noch
     *  train_step_i8()/extract_state_i8() verwenden, NICHT mehr train_step()/
     *  extract_state() - der State ist jetzt ein INT8-State. */
    public function quantize_to_int8(): bool {
        $ok = $this->ffi->cortex_quantize_from_fp32($this->state_ptr) === 1;
        // Nach erfolgreicher Quantisierung IST der State int8 - das Flag muss
        // mitziehen, sonst dispatcht forward() weiter an cortex_forward() und
        // liest FP32-Schattengewichte, die dabei freigegeben worden sein
        // koennen (SIGSEGV). train_worker.php war davon nie betroffen, weil es
        // ausschliesslich die expliziten _i8-Methoden aufruft.
        if ($ok) $this->is_int8 = true;
        return $ok;
    }

    /** INT8-Pendant zu train_step() - identische Signatur/Semantik, nutzt
     *  intern das echte int8xint8->int32-GEMM + Rounded-Integer-Step Adam
     *  (cortex_train_step_i8(), siehe cortex.nim). */
    /**
     * Schaltet zwischen den beiden INT8-Adam-Varianten um (Default: 1/Float).
     *   1 = Adam-Schritt in Float auf dem dequantisierten Gewicht, danach
     *       Zeile mit frischer Skala requantisiert.
     *   0 = alter "Rounded-Integer-Step" mit MAX_LSB_STEP_PER_UPDATE-Kappung.
     * Nur fuer Vergleichsmessungen gedacht - der Produktivpfad laesst den
     * Default stehen.
     */
    public function set_i8_float_adam(int $on): void {
        $this->ffi->cortex_set_i8_float_adam($on);
    }

    /**
     * Fehler-Rueckfuehrung an/aus (Default: 1/an). Hebt den Rundungsrest jedes
     * Requantisierens auf und addiert ihn im naechsten Schritt wieder dazu.
     * Ohne sie addieren sich die Rundungsfehler ueber tausende Schritte als
     * Random Walk auf (gemessen an der w_out-Zeilendrift). 0 stellt das alte
     * Verhalten her - nur fuer Vergleichsmessungen gedacht.
     */
    public function set_i8_error_feedback(int $on): void {
        $this->ffi->cortex_set_i8_error_feedback($on);
    }

    /**
     * FULL-INT8 SCHRITT 1: schaltet den ganzzahligen Backward-Pfad
     * (d_in = W^T . d_out als echtes int8xint8->int32-GEMM, backwardDInI8()
     * in cortex.nim) an/aus. Default AUS - der Pfad ist noch in Erprobung.
     * Wirkt derzeit nur im NICHT-gebuendelten Pfad, also zusammen mit
     * set_batched_i8(0).
     */
    public function set_i8_int_backward(int $on): void {
        $this->ffi->cortex_set_i8_int_backward($on);
    }

    public function get_i8_int_backward(): int {
        return $this->ffi->cortex_get_i8_int_backward();
    }

    /** Gebuendelter (layer-major) INT8-Pfad an/aus. Default AN. */
    public function set_batched_i8(int $on): void {
        $this->ffi->cortex_set_batched_i8($on);
    }

    /**
     * ARM C des LoRA-Armvergleichs - "nur letzte Schicht trainieren",
     * die billige Baseline, die LoRA schlagen muss.
     *
     * $n = 0 schaltet ab (unveraendertes Verhalten, alles trainierbar).
     * $n > 0 friert alles ein AUSSER den sechs Gewichtsmatrizen der letzten $n
     * Transformer-Schichten - also auch Embeddings, w_out, rms_final und
     * saemtliche RMSNorm-Gains. Das ist genau die Tensor-Menge, die LoRA ueber
     * seine Slots adressiert; nur so vergleicht der A/B "eine Schicht, voller
     * Rang" gegen "alle Schichten, niedriger Rang".
     *
     * Wirft, wenn die Engine ablehnt - ein still ignorierter Arm-Schalter
     * waere ein Messfehler, der wie ein Ergebnis aussieht.
     */
    public function set_train_last_layers(int $n): void {
        if ($this->ffi->cortex_set_train_last_layers($this->state_ptr, $n) !== 1) {
            throw new RuntimeException(
                "cortex_set_train_last_layers($n) abgelehnt (num_layers={$this->num_layers})."
            );
        }
    }

    /** Was die Engine tatsaechlich gesetzt hat - nicht was angefordert wurde. */
    public function get_train_last_layers(): int {
        return $this->ffi->cortex_get_train_last_layers($this->state_ptr);
    }

    /**
     * Kennzahl des LoRA-Armvergleichs: trainierbare Parameter, aus dem
     * tatsaechlichen Engine-Zustand gezaehlt (LoRA-Raenge, Arm-C-Maske und
     * Tying inbegriffen) statt aus der Geometrie nachgeschlagen.
     */
    public function count_trainable(): int {
        return $this->ffi->cortex_count_trainable_i8($this->state_ptr);
    }

    /**
     * FULL-INT8 SCHRITT 2: ganzzahlige Gradienten-Akkumulation
     * (gm += d_out (x) i_v als int8xint8->int32-Aussenprodukt mit Skalen je
     * Zeile/Spalte). Default AUS. Wirkt nur im gebuendelten Pfad - der
     * Einzelpfad hat die Positionsachse nicht vorliegen und kann die ueber
     * Positionen konstanten Skalen daher nicht bilden.
     */
    public function set_i8_int_gradacc(int $on): void {
        $this->ffi->cortex_set_i8_int_gradacc($on);
    }

    public function get_i8_int_gradacc(): int {
        return $this->ffi->cortex_get_i8_int_gradacc();
    }

    /** Stochastisches Runden im Gradientenpfad. Default AUS. */
    public function set_i8_grad_stochastic(int $on): void {
        $this->ffi->cortex_set_i8_grad_stochastic($on);
    }

    /**
     * FULL-INT8 SCHRITT 3: Adam-Momente (m/v) auf 8-Bit-Log-Auflösung.
     * Derzeit eine SIMULATION - quantisiert und dequantisiert sofort zurueck,
     * der Praezisionsverlust ist also exakt der des spaeteren int8-Formats,
     * der Speicherverbrauch aber unveraendert. Zweck: die Qualitaetsfrage
     * klaeren, bevor der Umbau der m/v-Felder auf int8+Blockskala (Allokation,
     * extract/load, SNAI_V6-Serialisierung, Merge) investiert wird.
     */
    public function set_i8_quant_adam(int $on): void {
        $this->ffi->cortex_set_i8_quant_adam($on);
    }

    public function get_i8_quant_adam(): int {
        return $this->ffi->cortex_get_i8_quant_adam();
    }

    /**
     * FULL-INT8 SCHRITT 3, ECHTER SPEICHERUMBAU - wird ueber den
     * KONSTRUKTOR-Parameter $quant_adam_memory aktiviert, nicht hierueber.
     *
     * FALLSTRICK, der zwei Fehlversuche gekostet hat: der Schalter muss VOR
     * cortex_init() wirken (dort faellt die Allokationsentscheidung), und
     * cortex_init() laeuft bereits im Konstruktor. Eine Instanzmethode kommt
     * also immer zu spaet. Eine STATISCHE Methode mit eigenem FFI::cdef()
     * funktioniert ebenfalls NICHT: PHP-FFI teilt globale Variablen zwischen
     * zwei cdef()-Handles auf dieselbe .so nicht zuverlaessig - gemessen:
     * ueber EIN Handle gesetzt wirkt der Schalter (quantAdam=1), ueber zwei
     * getrennte nicht (quantAdam=0). Deshalb der Konstruktor-Parameter, der
     * den Schalter ueber DIESELBE Instanz zwischen cdef() und dem Laden setzt.
     */

    /**
     * FULL-INT8 SCHRITT 4b: FFN-Aktivierungshistorien auf int8-Aufloesung
     * (Pro-Position-Skala). Derzeit SIMULATION - quantisiert und dequantisiert
     * sofort, Speicher unveraendert. Klaert die Qualitaetsfrage, bevor der
     * Umbau investiert wird; dieser waere hier teurer als bei den Momenten,
     * weil beide Puffer im aktiven Rechenweg liegen.
     */
    public function set_i8_quant_acts(int $on): void {
        $this->ffi->cortex_set_i8_quant_acts($on);
    }

    /** 1 = dieser State haelt seine Momente quantisiert. */
    public function get_quant_adam_memory(): int {
        return $this->ffi->cortex_get_quant_adam_memory($this->state_ptr);
    }

    /** 1 = dieser State haelt act_ffn_out quantisiert (Schritt 4b). */
    public function get_quant_acts_memory(): int {
        return $this->ffi->cortex_get_quant_acts_memory($this->state_ptr);
    }

    /**
     * FULL-INT8 SCHRITT 5a: SiLU aus einer 256er-Tabelle statt elementweisem
     * exp(). Setzt Schritt 4c voraus (act_ffn_in muss int8 vorliegen) - dann
     * ist die Tabelle exakt, weil es je Position nur 256 moegliche
     * Eingabewerte gibt.
     */
    public function set_i8_silu_lut(int $on): void {
        $this->ffi->cortex_set_i8_silu_lut($on);
    }

    /** Notschalter: erzwingt den reinen CPU-Pfad trotz aktiver GPU. */
    public function set_i8_cpu_only(int $on): void {
        $this->ffi->cortex_set_i8_cpu_only($on);
    }

    /** Ganzzahl-Backward auf der GPU (OpenCL). Default AUS. */
    public function set_i8_gpu_backward(int $on): void {
        $this->ffi->cortex_set_i8_gpu_backward($on);
    }

    /** Wie oft der GPU-Gradienten-Akkumulationskernel abgesetzt wurde. */
    public function get_gpu_gradacc_calls(): int {
        return $this->ffi->cortex_get_gpu_gradacc_calls();
    }

    /** Diagnose: Abweichung der w_out-int8-Daten zwischen Host und Geraet. */
    public function gpu_weight_drift(): float {
        return $this->ffi->cortex_gpu_weight_drift($this->state_ptr);
    }

    /** Nullt das Rueckfuehrungs-Residuum - bildet einen Checkpoint-Uebergang nach. */
    public function reset_i8_error_feedback(): void {
        $this->ffi->cortex_reset_i8_error_feedback($this->state_ptr);
    }

    /** 1 = Fehler-Rueckfuehrung wirkt wirklich (Schalter UND Rest-Puffer da). */
    /**
     * SNAI_V7: bindet w_out an die Embeddings (Weight Tying). Nach
     * quantize_to_int8() bzw. auf einem geladenen V6-Modell aufzurufen, das
     * gebunden weitertrainiert werden soll. Ein aus einer V7-Datei geladener
     * Zustand ist bereits gebunden - der Aufruf ist dann folgenlos.
     */
    public function tie_embeddings(): bool {
        return $this->ffi->cortex_tie_embeddings($this->state_ptr) === 1;
    }

    /**
     * Fragt die WIRKUNG ab, nicht den Wunsch: die Nim-Seite prueft zusaetzlich,
     * ob die Zeiger tatsaechlich geteilt sind. Lehre aus dem
     * i8_error_feedback_active()-Befund - ein gesetzter Schalter ist kein
     * Beleg dafuer, dass der Mechanismus laeuft.
     */
    public function tied_embeddings_active(): bool {
        return $this->ffi->cortex_get_tied_embeddings($this->state_ptr) === 1;
    }

    public function i8_error_feedback_active(): int {
        return $this->ffi->cortex_i8_error_feedback_active($this->state_ptr);
    }

    // =========================================================================
    // LoRA (2026-08-29)
    // =========================================================================

    /** Slot-Nummern der adaptierbaren Gewichte - Reihenfolge wie in cortex.nim. */
    public const LORA_SLOTS = ['w_q' => 0, 'w_k' => 1, 'w_v' => 2,
                               'w_o' => 3, 'w_up' => 4, 'w_down' => 5];
    public const LORA_ALL   = 63;
    /** Der in der Literatur uebliche Minimalsatz - nur Q und V. */
    public const LORA_QV    = 5;   // Bit 0 | Bit 2

    /**
     * Richtet die Adapter ein. A wird zufaellig, B exakt null initialisiert -
     * das Modell ist direkt danach mathematisch die unveraenderte Basis.
     *
     * $freeze_base=true ist der eigentliche LoRA-Arm: die INT8-Basis bekommt
     * keinen Adam-Schritt, kein Re-Scaling und keine Gradientenakkumulation.
     * $freeze_base=false ist ein eigener Vergleichsarm (Adapter ZUSAETZLICH
     * zum vollen Finetune), kein Standardfall.
     *
     * $seed steuert einen eigenen Generator in cortex.nim, NICHT den globalen
     * RNG - der treibt das Dropout, und ein Eingriff dort wuerde zwei sonst
     * identische Arme auseinanderlaufen lassen.
     */
    public function lora_enable(int $rank, float $alpha = 0.0, int $slot_mask = self::LORA_ALL,
                                bool $freeze_base = true, int $seed = 1234567): bool {
        return $this->ffi->cortex_lora_enable($this->state_ptr, $rank, $alpha,
                   $slot_mask, $freeze_base ? 1 : 0, $seed) === 1;
    }

    /**
     * Fragt die WIRKUNG ab: Rang gesetzt, Scratch da UND jede Matrix des
     * aktiven Slots allokiert. Gleiche Linie wie tied_embeddings_active().
     */
    public function lora_active(): bool {
        return $this->ffi->cortex_lora_active($this->state_ptr) === 1;
    }

    /**
     * 1 = der Optimierer-Zustand der Basis (m/v/g/res) ist freigegeben. Das ist
     * der Speicherarm von LoRA. Die GEWICHTE stehen unveraendert - nur trainieren
     * laesst sich die Basis danach nicht mehr.
     */
    public function lora_base_opt_freed(): bool {
        return $this->ffi->cortex_lora_base_opt_freed($this->state_ptr) === 1;
    }

    public function lora_rank(): int         { return $this->ffi->cortex_lora_rank($this->state_ptr); }
    public function lora_mask(): int         { return $this->ffi->cortex_lora_mask($this->state_ptr); }
    public function lora_base_frozen(): bool { return $this->ffi->cortex_lora_base_frozen($this->state_ptr) === 1; }

    /** Zahl der trainierbaren Adapter-Parameter - im A/B immer mitberichten. */
    public function lora_params(): int       { return $this->ffi->cortex_lora_params($this->state_ptr); }

    public function lora_disable(): void     { $this->ffi->cortex_lora_disable($this->state_ptr); }

    /**
     * Liest eine Adaptermatrix aus. $is_b=false liefert A (rank x cols),
     * $is_b=true liefert B (rows x rank). Gibt null zurueck, wenn es den
     * Adapter nicht gibt - kein Teilergebnis, keine stille Naeherung.
     */
    public function lora_extract(int $layer, int $slot, bool $is_b, int $size): ?array {
        $buf = $this->ffi->new("float[$size]");
        $n = $this->ffi->cortex_lora_extract($this->state_ptr, $layer, $slot,
                 $is_b ? 1 : 0, $this->ffi->cast("float*", $buf), $size);
        if ($n !== $size) return null;
        $out = [];
        for ($i = 0; $i < $size; $i++) $out[$i] = $buf[$i];
        return $out;
    }

    public function lora_load(int $layer, int $slot, bool $is_b, array $vals): bool {
        $size = count($vals);
        $buf = $this->ffi->new("float[$size]");
        $i = 0;
        foreach ($vals as $v) { $buf[$i++] = $v; }
        return $this->ffi->cortex_lora_load($this->state_ptr, $layer, $slot,
                   $is_b ? 1 : 0, $this->ffi->cast("float*", $buf), $size) === $size;
    }

    /**
     * Spielt die Adapterdatei ein, die neben $checkpoint liegt - falls es eine
     * gibt. Liefert den Header (zur Anzeige), null wenn keine Datei da ist,
     * und wirft eine RuntimeException, wenn eine da ist, aber nicht passt.
     *
     * DAS IST DIE WICHTIGSTE STELLE FUER DIE MESSUNG. Wer ein LoRA-Modell
     * auswertet, ohne die Adapter einzuspielen, misst die Basis und schreibt
     * das Ergebnis in die LoRA-Zeile seiner Tabelle. Es faellt nicht auf: die
     * Zahl ist plausibel, sie ist nur die falsche. Deshalb ist ein vorhandener,
     * aber unpassender Adapter hier ein Fehler und keine Warnung.
     */
    public function attach_lora_if_present(string $checkpoint): ?array {
        $path = snai_lora_path($checkpoint);
        if (!file_exists($path)) return null;
        $h = load_lora_header($path);
        if ($h === null) {
            throw new RuntimeException("Adapterdatei $path ist nicht lesbar.");
        }
        $this->set_batched_i8(1);
        if (!$this->lora_enable($h['rank'], (float)$h['alpha'], $h['mask'], true, 1)) {
            throw new RuntimeException("cortex_lora_enable() abgelehnt fuer $path (Rang {$h['rank']}).");
        }
        $state = load_lora_stream($path, $checkpoint);
        if ($state === null) {
            throw new RuntimeException("Adapterdatei $path passt nicht zum Modell $checkpoint.");
        }
        if (!$this->apply_lora_state($state)) {
            throw new RuntimeException("Adapterzustand aus $path liess sich nicht einspielen.");
        }
        return $h;
    }

    /** (rows, cols) des Basisgewichts eines Slots - eine Quelle, siehe cortex.nim. */
    public function lora_slot_shape(int $slot): array {
        return match ($slot) {
            0, 1, 2, 3 => [$this->hidden_dim, $this->hidden_dim],
            4          => [$this->ffn_dim,    $this->hidden_dim],
            5          => [$this->hidden_dim, $this->ffn_dim],
            default    => [0, 0],
        };
    }

    public function lora_slot_size(int $slot, bool $is_b): int {
        [$rows, $cols] = $this->lora_slot_shape($slot);
        return $is_b ? $rows * $this->lora_rank() : $this->lora_rank() * $cols;
    }

    /**
     * Zustand aller Adapter als BINAERSTRINGS (nicht als PHP-Arrays). Bei Rang 32
     * auf dem echten Modell waeren das 2,2 Mio Floats - als PHP-Array rund
     * 176 MB, als gepackter String 8,8 MB. Dieselbe Entscheidung wie in
     * extract_state_i8().
     */
    public function extract_lora_state(bool $with_adam = true): ?array {
        if (!$this->lora_active()) return null;
        $rank = $this->lora_rank();
        $mask = $this->lora_mask();
        $out = [
            'rank' => $rank, 'alpha_over_rank_note' => null,
            'mask' => $mask,
            'num_layers' => $this->num_layers,
            'hidden_dim' => $this->hidden_dim,
            'ffn_dim'    => $this->ffn_dim,
            'vocab_size' => $this->vocab_size,
            'adam_t'     => $this->ffi->cortex_get_adam_t($this->state_ptr),
            'has_adam'   => $with_adam,
            'tensors'    => [],
        ];
        unset($out['alpha_over_rank_note']);

        for ($l = 0; $l < $this->num_layers; $l++) {
            for ($s = 0; $s < 6; $s++) {
                if (($mask & (1 << $s)) === 0) continue;
                $entry = [];
                foreach ([false, true] as $is_b) {
                    $n = $this->lora_slot_size($s, $is_b);
                    $buf = $this->ffi->new("float[$n]");
                    $got = $this->ffi->cortex_lora_extract($this->state_ptr, $l, $s,
                               $is_b ? 1 : 0, $this->ffi->cast("float*", $buf), $n);
                    if ($got !== $n) return null;
                    $entry[$is_b ? 'b' : 'a'] = FFI::string($buf, $n * 4);
                    if (!$with_adam) continue;
                    foreach ([false, true] as $is_v) {
                        $mb = $this->ffi->new("float[$n]");
                        $g2 = $this->ffi->cortex_lora_extract_adam($this->state_ptr, $l, $s,
                                  $is_b ? 1 : 0, $is_v ? 1 : 0, $this->ffi->cast("float*", $mb), $n);
                        if ($g2 !== $n) return null;
                        $entry[($is_v ? 'v' : 'm') . ($is_b ? 'b' : 'a')] = FFI::string($mb, $n * 4);
                    }
                }
                $out['tensors']["$l.$s"] = $entry;
            }
        }
        return $out;
    }

    /**
     * Gegenstueck zu extract_lora_state(). Erwartet, dass lora_enable() mit
     * DEMSELBEN Rang und derselben Maske bereits gelaufen ist - andernfalls
     * passen die Groessen nicht und der Aufruf scheitert, statt still eine
     * halbe Adaption zu laden.
     */
    public function apply_lora_state(array $lora): bool {
        if (!$this->lora_active()) return false;
        if ((int)$lora['rank'] !== $this->lora_rank()) return false;
        if ((int)$lora['mask'] !== $this->lora_mask()) return false;

        foreach ($lora['tensors'] as $key => $entry) {
            [$l, $s] = array_map('intval', explode('.', $key));
            foreach ([false, true] as $is_b) {
                $n = $this->lora_slot_size($s, $is_b);
                $k = $is_b ? 'b' : 'a';
                if (!isset($entry[$k]) || strlen($entry[$k]) !== $n * 4) return false;
                $buf = $this->ffi->new("float[$n]");
                FFI::memcpy($buf, $entry[$k], $n * 4);
                if ($this->ffi->cortex_lora_load($this->state_ptr, $l, $s, $is_b ? 1 : 0,
                        $this->ffi->cast("float*", $buf), $n) !== $n) return false;
                foreach ([false, true] as $is_v) {
                    $mk = ($is_v ? 'v' : 'm') . $k;
                    if (!isset($entry[$mk])) continue;   // Datei ohne Adam-Block
                    if (strlen($entry[$mk]) !== $n * 4) return false;
                    $mb = $this->ffi->new("float[$n]");
                    FFI::memcpy($mb, $entry[$mk], $n * 4);
                    if ($this->ffi->cortex_lora_load_adam($this->state_ptr, $l, $s,
                            $is_b ? 1 : 0, $is_v ? 1 : 0,
                            $this->ffi->cast("float*", $mb), $n) !== $n) return false;
                }
            }
        }
        // Schrittzaehler nur setzen, wenn auch Momente da waren - sonst waere die
        // Bias-Korrektur auf einen Zustand gestellt, den es gar nicht gibt.
        if (!empty($lora['has_adam'])) {
            $this->ffi->cortex_lora_set_adam_t($this->state_ptr, (int)$lora['adam_t']);
        }
        return true;
    }

    /** Wie oft der GPU-Backward-Kernel wirklich abgesetzt wurde. */
    public function get_gpu_bw_calls(): int {
        return $this->ffi->cortex_get_gpu_bw_calls();
    }

    /** 1 = dieser State haelt act_ffn_in quantisiert (Schritt 4c). */
    public function get_quant_acts_in_memory(): int {
        return $this->ffi->cortex_get_quant_acts_in_memory($this->state_ptr);
    }

    public function train_step_i8(array $inputs, array $targets, array $mask, float $lr): float {
        $num_tokens = count($inputs);
        if ($num_tokens > $this->ctx_size) {
            $num_tokens = $this->ctx_size;
            $inputs = array_slice($inputs, -$num_tokens);
            $targets = array_slice($targets, -$num_tokens);
            $mask = array_slice($mask, -$num_tokens);
        }
        if ($num_tokens === 0) return 0.0;

        $c_in = $this->ffi->new("int[$num_tokens]");
        $c_tg = $this->ffi->new("int[$num_tokens]");
        $c_mask = $this->ffi->new("int[$num_tokens]");
        foreach ($inputs as $i => $v) $c_in[$i] = $v;
        foreach ($targets as $i => $v) $c_tg[$i] = $v;
        foreach ($mask as $i => $v) $c_mask[$i] = $v ? 1 : 0;

        return $this->ffi->cortex_train_step_i8($this->state_ptr, $this->ffi->cast("int*", $c_in), $this->ffi->cast("int*", $c_tg), $this->ffi->cast("int*", $c_mask), $num_tokens, $lr);
    }

    /** Periodisches Re-Scaling der INT8-Gewichtszeilen (Plan, "Skalen-
     *  Lebenszyklus"). GATE-BEFUND (siehe cortex.nim-Kommentar bei
     *  cortex_rescale_weights()): muss nach JEDEM train_step_i8()-Aufruf
     *  laufen, nicht nur an Epochengrenzen - sonst saettigen kleinskalige
     *  Zeilen (v.a. w_out) dauerhaft und der Loss bleibt auf Zufallsniveau
     *  haengen. */
    public function rescale_weights_i8(): void {
        $this->ffi->cortex_rescale_weights($this->state_ptr);
    }

    /** Bitmaske: 1=nicht-endliche/nicht-positive Zeilen-Skala irgendwo.
     *  8=Aufruf auf einem Nicht-INT8-State. -1=kein State. */
    public function validate_i8(): int {
        return $this->ffi->cortex_validate_i8($this->state_ptr);
    }

    /** INT8-Pendant zu extract_state(): zieht die 8 quantisierbaren
     *  Gewichtstypen als INT8+Pro-Zeile-Skala, rms_* weiterhin als Float32.
     *  Adam-Momente (m/v) werden IMMER extrahiert (Design-Entscheidung #2 -
     *  liegen in denselben FP32-Feldern wie im FP32-Pfad, cortex_extract_adam_layer()
     *  funktioniert dafuer unveraendert). Ergebnis passt direkt zu
     *  save_model_stream_i8()/merge_v6_models() (tensor_io.php). */
    /**
     * $weights_only=true laesst die Adam-Bloecke aus. Gebraucht wird das seit
     * dem LoRA-Speicherarm: ist der Optimierer-Zustand der Basis freigegeben,
     * liefert cortex_extract_adam_layer() stillschweigend NULLEN - eine so
     * geschriebene SNAI_V6-Datei saehe vollstaendig aus und haette ein
     * geloeschtes Adam-Gedaechtnis. Deshalb ist der volle Modus in diesem Fall
     * gesperrt und der Aufrufer muss sich entscheiden.
     */
    public function extract_state_i8(bool $weights_only = false): array {
        if (!$weights_only && $this->lora_base_opt_freed()) {
            throw new RuntimeException(
                "extract_state_i8(): der Optimierer-Zustand der Basis ist fuer einen "
              . "LoRA-Lauf freigegeben - die Adam-Bloecke waeren Nullen. Entweder "
              . "extract_state_i8(true) fuer reine Gewichte nutzen, oder (richtig fuer "
              . "die Pipeline) die unveraenderte Basisdatei kopieren statt sie neu zu "
              . "serialisieren.");
        }
        return $this->extract_state_i8_impl($weights_only);
    }

    private function extract_state_i8_impl(bool $weights_only): array {
        // SNAI_V7: ist der Zustand gebunden, gibt es kein eigenes w_out zu
        // extrahieren - seine m/v-Felder sind auf der Nim-Seite freigegeben,
        // ein cortex_extract_adam_layer(type=1) liefe in einen Nullzeiger.
        // Die Wirkung wird abgefragt, nicht ein Merker (s. tied_embeddings_active()).
        $tied = $this->tied_embeddings_active();

        $state = [
            'magic' => $tied ? 'SNAI_V7' : 'SNAI_V6',
            // EMB-EINGANG: Bit 1 aus der WIRKUNG der Engine, nicht neu erfunden (sonst ginge es hier still verloren).
            'flags' => ($tied ? SNAI_FLAG_TIED_EMBEDDINGS : 0)
                     | ($this->emb_eingang_aktiv() === true ? SNAI_FLAG_EMB_EINGANG : 0),
            'vocab_size' => $this->vocab_size, 'hidden_dim' => $this->hidden_dim,
            'ffn_dim' => $this->ffn_dim,
            'ctx_size' => $this->ctx_size, 'num_layers' => $this->num_layers,
            'num_heads' => $this->num_heads,
            'adam_t' => $this->ffi->cortex_get_adam_t($this->state_ptr),
            'tensors' => ['global' => [], 'layers' => []],
            'tensor_scales' => ['global' => [], 'layers' => []],
        ];

        $size_emb = $this->vocab_size * $this->hidden_dim;
        $size_rms = $this->hidden_dim;
        $size_qkv = $this->hidden_dim * $this->hidden_dim;
        $size_up = $this->ffn_dim * $this->hidden_dim;

        $sizes = [
            0 => $size_emb, 1 => $size_emb, 2 => $size_rms,
            10 => $size_rms, 11 => $size_rms,
            12 => $size_qkv, 13 => $size_qkv, 14 => $size_qkv, 15 => $size_qkv,
            16 => $size_up, 17 => $size_up
        ];
        $rows_of = [
            0 => $this->vocab_size, 1 => $this->vocab_size,
            12 => $this->hidden_dim, 13 => $this->hidden_dim, 14 => $this->hidden_dim, 15 => $this->hidden_dim,
            16 => $this->ffn_dim, 17 => $this->hidden_dim,
        ];
        $int8_types = [0, 1, 12, 13, 14, 15, 16, 17];

        $extract_weight = function(int $type, int $layer_idx) use ($sizes, $rows_of, $int8_types): array {
            if (in_array($type, $int8_types, true)) {
                $rows = $rows_of[$type];
                $c_i8 = $this->ffi->new("signed char[{$sizes[$type]}]");
                $c_scale = $this->ffi->new("float[$rows]");
                $this->ffi->cortex_extract_layer_i8($this->state_ptr, $layer_idx, $type, $this->ffi->cast("signed char*", $c_i8), $this->ffi->cast("float*", $c_scale), $sizes[$type]);
                $scales = [];
                for ($r = 0; $r < $rows; $r++) $scales[] = $c_scale[$r];
                return ['w' => FFI::string($c_i8, $sizes[$type]), 'scales' => $scales];
            }
            $c_array = $this->ffi->new("float[{$sizes[$type]}]");
            $this->ffi->cortex_extract_layer($this->state_ptr, $layer_idx, $type, $this->ffi->cast("float*", $c_array), $sizes[$type]);
            return ['w' => FFI::string($c_array, $sizes[$type] * 4), 'scales' => null];
        };

        foreach ($this->global_map as $type => $keys) {
            if ($tied && $type === 1) continue; // w_out: gebunden, steht nicht in der Datei
            $r = $extract_weight($type, -1);
            $state['tensors']['global'][$keys['w']] = $r['w'];
            if ($r['scales'] !== null) $state['tensor_scales']['global'][$keys['w']] = $r['scales'];

            if ($weights_only) continue;   // LoRA-Speicherarm: keine Adam-Bloecke
            $c_m = $this->ffi->new("float[{$sizes[$type]}]");
            $this->ffi->cortex_extract_adam_layer($this->state_ptr, -1, $type, false, $this->ffi->cast("float*", $c_m), $sizes[$type]);
            $state['tensors']['global'][$keys['m']] = FFI::string($c_m, $sizes[$type] * 4);

            $c_v = $this->ffi->new("float[{$sizes[$type]}]");
            $this->ffi->cortex_extract_adam_layer($this->state_ptr, -1, $type, true, $this->ffi->cast("float*", $c_v), $sizes[$type]);
            $state['tensors']['global'][$keys['v']] = FFI::string($c_v, $sizes[$type] * 4);
        }

        for ($l = 0; $l < $this->num_layers; $l++) {
            $layer = [];
            $layer_scales = [];
            foreach ($this->layer_map as $type => $keys) {
                $r = $extract_weight($type, $l);
                $layer[$keys['w']] = $r['w'];
                if ($r['scales'] !== null) $layer_scales[$keys['w']] = $r['scales'];

                if ($weights_only) continue;   // LoRA-Speicherarm: keine Adam-Bloecke
                $c_m = $this->ffi->new("float[{$sizes[$type]}]");
                $this->ffi->cortex_extract_adam_layer($this->state_ptr, $l, $type, false, $this->ffi->cast("float*", $c_m), $sizes[$type]);
                $layer[$keys['m']] = FFI::string($c_m, $sizes[$type] * 4);

                $c_v = $this->ffi->new("float[{$sizes[$type]}]");
                $this->ffi->cortex_extract_adam_layer($this->state_ptr, $l, $type, true, $this->ffi->cast("float*", $c_v), $sizes[$type]);
                $layer[$keys['v']] = FFI::string($c_v, $sizes[$type] * 4);
            }
            $state['tensors']['layers'][$l] = $layer;
            $state['tensor_scales']['layers'][$l] = $layer_scales;
        }

        return $state;
    }

    public function generate_next_token(array $input_tokens, float $temp = 0.7, int $top_k = 40, float $top_p = 0.9, float $rep_pen = 1.15): int {
        $num = count($input_tokens);
        if ($num > $this->ctx_size) {
            $input_tokens = array_slice($input_tokens, -$this->ctx_size);
            $num = $this->ctx_size;
        }

        $c_in = $this->ffi->new("int[$num]");
        foreach ($input_tokens as $i => $v) $c_in[$i] = $v;
        
        // VETO-FIX: Verwendet gecachten Array-Pointer gegen GC-Thrashing
        $c_logits = $this->cached_c_logits;
        
        $this->ffi->cortex_forward($this->state_ptr, $this->ffi->cast("int*", $c_in), $num, $this->ffi->cast("float*", $c_logits));
        
        $logits = [];
        $input_set = array_flip($input_tokens);
        
        for ($i = 0; $i < $this->vocab_size; $i++) {
            $val = $c_logits[$i];
            if (isset($input_set[$i])) $val -= $rep_pen;
            $logits[$i] = $val;
        }
        
        arsort($logits);
        $logits = array_slice($logits, 0, $top_k, true);
        
        if ($temp < 0.01) return array_key_first($logits);
        
        // AUDIT-FIX: Softmax Stabilisierung (Verhindert Float-Overflow zu INF/NAN)
        $max_val = max($logits); 
        
        $probs = []; $sum = 0.0;
        foreach ($logits as $id => $val) {
            $p = exp(($val - $max_val) / $temp); 
            $probs[$id] = $p;
            $sum += $p;
        }
        
        $cum = 0.0; $filtered = [];
        foreach ($probs as $id => $p) {
            $p_norm = $p / $sum; 
            $filtered[$id] = $p_norm;
            $cum += $p_norm;
            if ($cum >= $top_p) break;
        }
        
        // VETO-FIX: $r skaliert mit der echten $cum-Summe!
        $r = (mt_rand() / mt_getrandmax()) * $cum; 
        
        $cum_check = 0.0;
        foreach ($filtered as $id => $p) {
            $cum_check += $p;
            if ($r <= $cum_check) return $id;
        }
        return array_key_first($filtered);
    }
}

// Fallback Alias für alte Skripte
if (!class_exists('CortexBridge')) {
    class_alias('SnaiCortexBridge', 'CortexBridge');
}

// Eigenständige FFI Averaging Funktion für train_cluster.php
if (!function_exists('ffi_average_layer')) {
    function ffi_average_layer(array $binary_strings, int $dtype = 1): string {
        if (empty($binary_strings)) return "";
        $num_models = count($binary_strings);
        if ($num_models === 1) return $binary_strings[0];
        
        $num_floats = intval(strlen($binary_strings[0]) / 4);
        $sum = array_fill(0, $num_floats, 0.0);
        
        foreach ($binary_strings as $bin) {
            $floats = array_values(unpack("g*", $bin));
            for ($i = 0; $i < $num_floats; $i++) {
                $sum[$i] += $floats[$i] ?? 0.0;
            }
        }
        for ($i = 0; $i < $num_floats; $i++) {
            $sum[$i] /= $num_models;
        }

        // AUDIT-FIX: pack("g*", ...$sum) entfaltet den GESAMTEN Array auf den
        // PHP-Argument-Stack. Bei den Embeddings sind das >4 Mio. Floats -
        // die Funktionsaufruf-Konvention ist dafuer nicht gebaut (Crash/extreme
        // Verlangsamung). train_cluster.php macht es an anderer Stelle bereits
        // korrekt in Bloecken - hier nachgezogen statt neu erfunden.
        $bin_out = '';
        $chunk_size = 65536; // Floats pro pack()-Aufruf, bewusst klein gehalten
        for ($off = 0; $off < $num_floats; $off += $chunk_size) {
            $slice = array_slice($sum, $off, $chunk_size);
            $bin_out .= pack("g*", ...$slice);
        }
        return $bin_out;
    }
}