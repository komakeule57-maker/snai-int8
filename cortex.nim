# Dateiname: cortex.nim
# Funktion: Symbio Nano-AI Framework - Cortex Core Backend (FFI, Inference, BPTT)
# ==============================================================================
# VERSION: V11.11  (Etappe 1, Schritt 1 - gebuendeltes w_out ist Standard)
# Gemessen gegen V11.8 auf expert_SFT (dim=128, vocab=16384, 256 Positionen):
#   CPU  456,5 ms -> 335,0 ms (1,36x)   GPU  2672,9 ms -> 1671,7 ms (1,60x)
#   Loss in allen Laeufen bitidentisch -> Default jetzt AN.
#   Abschaltbar bleibt er: cortex_set_batched_wout(0) stellt V11.8-Verhalten her.
# V11.9 hatte in den CPU-Fallbacks der beiden Backward-Wrapper eine
# cache-feindliche Schleifenordnung (Schrittweite 512 B bzw. 64 KB in der
# innersten Schleife) -> Bucket 3 stieg von 255 ms auf 4012 ms. Behoben:
# beide nutzen jetzt exakt die zeilenweise Ordnung des bewaehrten alten
# Pfades, nur um die Positionsachse erweitert. GPU-Pfad unveraendert.
# Vorgaenger: V11.8 (OpenMP-Rueckbau) | Backend: cortex_opencl_v86.nim (V8.6)
# cortex_set_batched_wout(0) schaltet zurueck auf den alten Pfad (A/B-Vergleich).
# ==============================================================================
import std/math
import std/random
# V11.7 BAUFLAGS (zwingend, sonst laufen die ||-Schleifen seriell):
#   nim c -d:danger --threads:on --passC:-fopenmp --passL:-fopenmp \
#         --passL:-Wl,-z,nodelete --app:lib --out:libcortex.so cortex.nim
#
# -z nodelete (2026-09-02): die Bibliothek darf vom Prozess nicht mehr per
# dlclose() entladen werden. PHP entlaedt sie beim Herunterfahren, waehrend der
# OpenMP-Thread-Pool aus dem ersten parallelen Abschnitt noch Code darin
# referenziert -> SIGSEGV nach getaner Arbeit (rc 139, Backtrace nur in
# entladenem Code). Traf jedes Diagnoseskript mit direktem FFI::cdef, nicht
# den Worker (andere Abraeum-Reihenfolge ueber die Bridge-Klasse). Ohne das
# Flag sind die Exit-Codes von zwoelf Pruefskripten wertlos. Maschinencode ist
# mit und ohne Flag bitgleich (nur .dynamic waechst um 16 Byte).
import std/times
import std/envvars   # SR (SNAI_I8_MOM_SR)
import std/locks     # REST-16 Messkopie (Zaehler)
import std/tables    # GRAD-DEV (Port aus multi_stack)
from std/strutils import parseInt
import cortex_opencl
import cortex_cuda_bridge

# ==============================================================================
# SYMBIO NANO-AI FRAMEWORK (Code-4372)
# Modul: Cortex Core (Nim FFI Backend) - PRODUCTION V11.1 (ADAM & FFN FIX)
# ------------------------------------------------------------------------------
# MAXIME: E > H. Perfekte Mathematik trifft auf ausbruchsicheres I/O.
# UPDATE V11: Unterstützung für das SNAI_V5 Format (Adam Persistence).
# AUDIT-FIX V11.1: Heap-Buffer-Overflow bei dynamischer ffnDim behoben.
# AUDIT-FIX V11.1: Sanity-Checks für Header-Werte (OOM-Prevention) integriert.
# FIX V11.4b: Fehlerausgaben ohne String-Konkatenation (varargs writeLine).
#             Beseitigt die -Wstringop-overflow Warnungen unter -d:danger + LTO.
# PERF V11.4: w_out-Logits und der komplette Matrix-Backward laufen auf der GPU.
# AUDIT-FIX V11.3: Net2Net-Gain-Guard an cortex_load_layer + cortex_validate.
# AUDIT-FIX V11.2: Loader ist jetzt selbstverifizierend (Byte-Bilanz + v>=0-Test),
#                  raeumt bei Fehlern auf und stellt adam_t wieder her.
# ==============================================================================

{.pragma: ffi, exportc, dynlib, cdecl.}

# ==============================================================================
# FTZ/DAZ (2026-09-24): denormale Zwischenwerte werden in Null geklappt.
#
# WARUM: Eine denormale Float-Operation kostet auf vserver (Xeon E5-2699 v4,
# Broadwell) das 11,57-fache einer normalen - 1,470 s gegen 17,004 s im selben
# Mikrobenchmark -, mit FTZ/DAZ exakt das 1,00-fache. Auf dem Laptop
# (Ryzen 5 5500U, Zen) betraegt die Strafe 0,97-fach, also keine; deshalb war
# der Schrittzeit-Drift des Produktivlaufs dort nie zu reproduzieren.
#
# GEMESSEN am echten Arbeitspensum (eval_held_out_full_i8, 40 Fenster, OMP=2,
# Spanne zwischen Fenster 20 und 40, gleiche Binaerdatei, nur MXCSR anders):
#   prod512_s11  ohne FTZ 272,3 s   mit FTZ 243,4 s   -10,6 %
#   prod512_s5   ohne FTZ 248,7 s   mit FTZ 245,2 s    -1,4 %  (unter der Streuung)
# Ueber den echten Codepfad nach dem Neubau: s11 290,1 -> 248,7 s = -14,3 %.
# Held-out-Verlust in allen Faellen bitgleich (s11 3.982729, s5 4.261943,
# je 40.920 Token). Das Argument ist die ASYMMETRIE: die beiden Zellen lagen
# zeitlich nebeneinander, FTZ half s11 stark und s5 gar nicht - eine ruhigere
# Maschine oder ein allgemein schnelleres Fliesskomma erklaeren das nicht.
#
# WAS HIER AUSDRUECKLICH NICHT BEHAUPTET WIRD (korrigiert am 2026-09-24,
# eine erste Fassung dieses Kommentars behauptete beides faelschlich):
#  - Die Pruefpunkte enthalten KEINE subnormalen float32. Layoutbewusster Scan
#    ueber alle 23.075.328 m- und v-Werte von s5 und s11: null. Eine frueher
#    genannte Zahl (s5 331.670 -> s11 525.596) entstand dadurch, die Datei als
#    flaches uint32-Feld zu lesen - das zaehlt int8-Gewichtsbytes mit. Die
#    Denormalen entstehen also zur LAUFZEIT als Zwischenwerte, nicht im Modell.
#  - Weight Decay ist im Produktivlauf gar nicht aktiv (train_worker.php:498
#    setzt es nur bei > 0.0, argv[9] ist 0.000000). Es kann die Gewichte also
#    nicht gegen Null schieben.
#  - WARUM s11 mehr Denormalen-Verkehr erzeugt als s5, ist damit UNGEKLAERT.
#    Die Wirkung ist gemessen, die Ursache dahinter nicht.
#
# Der Konstruktor setzt MXCSR auf dem Thread, der die Bibliothek laedt; die
# OpenMP-Threads entstehen erst beim ersten parallelen Abschnitt und erben
# den Zustand ueber clone(). cortex_ftz_aktiv() prueft das zur Laufzeit.
# cortex_set_ftz(0) stellt das alte Verhalten her - A/B ohne Neubau, wie
# cortex_set_batched_wout(0) es fuer den w_out-Pfad tut.
# ==============================================================================
{.emit: """/*INCLUDESECTION*/
#include <xmmintrin.h>
#include <pmmintrin.h>
""".}

{.emit: """
__attribute__((constructor)) static void snai_ftz_init(void) {
  _MM_SET_FLUSH_ZERO_MODE(_MM_FLUSH_ZERO_ON);
  _MM_SET_DENORMALS_ZERO_MODE(_MM_DENORMALS_ZERO_ON);
}
void snai_ftz_set(int on) {
  _MM_SET_FLUSH_ZERO_MODE(on ? _MM_FLUSH_ZERO_ON : _MM_FLUSH_ZERO_OFF);
  _MM_SET_DENORMALS_ZERO_MODE(on ? _MM_DENORMALS_ZERO_ON : _MM_DENORMALS_ZERO_OFF);
}
int snai_ftz_get(void) {
  return (_MM_GET_FLUSH_ZERO_MODE() == _MM_FLUSH_ZERO_ON) ? 1 : 0;
}
""".}

proc snai_ftz_set(on: cint) {.importc, nodecl.}
proc snai_ftz_get(): cint {.importc, nodecl.}

proc cortex_set_ftz*(on: cint): cint {.ffi.} =
  ## Schaltet FTZ/DAZ auf dem aufrufenden Thread. Gibt den Zustand danach
  ## zurueck. Wirkt nicht rueckwirkend auf schon laufende OpenMP-Threads.
  snai_ftz_set(on)
  result = snai_ftz_get()

proc cortex_ftz_aktiv*(): cint {.ffi.} =
  ## 1, wenn FTZ auf dem aufrufenden Thread an ist.
  result = snai_ftz_get()

type
  FloatArray = UncheckedArray[cfloat]
  IntArray   = UncheckedArray[cint]
  FloatPtrArray = UncheckedArray[ptr FloatArray]
  Uint8PtrArray = UncheckedArray[ptr Uint8Array]
  MatrixArray   = UncheckedArray[Matrix]

  Matrix* = object
    rows*: cint
    cols*: cint
    data*: ptr FloatArray

  # ============================================================================
  # INT8-Umbau,
  # Design-Entscheidung #1/#2: symmetrische Quantisierung (-128..127), ein
  # Float32-Skalenfaktor PRO ZEILE (= Ausgabe-Kanal, deckungsgleich mit der
  # Zeilen-Indizierung von matVecMul/matMulBatchedD unten). Additiv neben
  # Matrix - kein bestehendes FP32-Feld/keine bestehende Prozedur wird durch
  # diese Typen ersetzt oder umgebaut (Design-Entscheidung #8).
  # ============================================================================
  Int8Array = UncheckedArray[int8]
  Uint8Array = UncheckedArray[uint8]
  QMatrixArray = UncheckedArray[QMatrix]

  QMatrix* = object
    rows*: cint
    cols*: cint
    data*: ptr Int8Array         # rows*cols int8, row-major (Layout wie Matrix.data)
    scale*: ptr FloatArray       # Laenge == rows; real(r,c) = data[r*cols+c] * scale[r]

  # FULL-INT8 SCHRITT 3 (Speicherumbau): Adam-Moment in 8 Bit, LOGARITHMISCH
  # quantisiert. Warum log und nicht linear: v ist ein Mittel ueber quadrierte
  # Gradienten und damit log-normal ueber ~7 Dekaden verteilt - lineare
  # Quantisierung rundet dort 59% der Werte auf 0 (gemessen,
  # diagnose/analyze_adam_dynamics.php), die logarithmische 0,0%.
  #
  # EINE SKALA JE ZEILE (nicht je 256er-Block wie in der Simulation): der
  # Adam-Schritt verarbeitet Zeile fuer Zeile, eine zeilenweise Skala macht
  # jede Zeile atomar requantisierbar. Ein blockuebergreifender Wert muesste
  # beim Aktualisieren einer einzelnen Zeile die Skala des halb veralteten
  # Nachbarblocks mitziehen. Die Simulation zeigte zwischen Block 64 und 256
  # praktisch keinen Unterschied (0,89% vs 0,90% mittlerer Fehler), Zeilenlaenge
  # liegt in derselben Groessenordnung.
  #
  # Kodierung: `scale[row]` = max|x| der Zeile.
  #   v (unsigned): q in 1..255, q=0 heisst exakt 0
  #   m (signed):   Bit 7 = Vorzeichen, Bits 0..6 = Magnitude 1..127, 0 = null
  # Dequantisieren ist eine Multiplikation `scale[row] * TAB[q]` - die Tabelle
  # ist blockunabhaengig, weil die darstellbare Dynamik fest ist.
  QMoment* = object
    rows*: cint
    cols*: cint
    data*: ptr Uint8Array
    scale*: ptr FloatArray       # Laenge == rows

  QMomentArray  = UncheckedArray[QMoment]

  CortexState* = object
    vocabSize*, hiddenDim*, ffnDim*, ctxSize*, numLayers*: cint
    adam_t*: cint
    numHeads*, headSize*: cint
    cachedTokens*: cint

    # weightDtype: 0 = FP32 (Standard, SNAI_V5) - benutzt die Matrix-Felder
    # unten wie bisher. 1 = INT8 (SNAI_V6) - benutzt zusaetzlich die *_q8-Felder
    # unten, die FP32-Gewichtsfelder (embeddings/w_out/w_q/... - NICHT deren
    # m_/v_/g_-Gegenstuecke) bleiben dann ungenutzt/unallokiert. Siehe
    # cortex_quantize_from_fp32()/cortex_train_step_i8().
    weightDtype*: cint

    embeddings*, m_embeddings*, v_embeddings*, g_embeddings*: Matrix
    w_out*, m_w_out*, v_w_out*, g_w_out*: Matrix
    # SCHRITT 3 (Speicherumbau): quantisierte Adam-Momente. Belegt statt
    # m_*/v_*, wenn init_quant_adam beim cortex_init() gesetzt war. Die
    # rms_*-Momente bleiben bewusst float32: sie sind Vektoren der Laenge dim
    # (<0,1% des Adam-Speichers) und als Normierungsgewichte empfindlicher -
    # der Aufwand lohnt dort nicht, das Risiko schon gar nicht.
    mq_embeddings*, vq_embeddings*: QMoment
    mq_w_out*, vq_w_out*: QMoment
    quantAdam*: cint             # 1 = die mq_/vq_-Felder sind massgeblich

    # SNAI_V7 / WEIGHT TYING (2026-08-29).
    # 1 = w_out IST die Embedding-Matrix, nicht eine Kopie davon: w_out_q8
    # zeigt auf DENSELBEN Speicher wie embeddings_q8 (Daten und Zeilenskalen),
    # m_w_out/v_w_out/mq_w_out/vq_w_out/res_w_out sind freigegeben und nil.
    #
    # NICHT geteilt wird EIN Feld: g_w_out. Der Gradient entsteht aus ZWEI
    # Quellen - dem Logit-Pfad (Matmul, im GPU-Fall geraeteseitig akkumuliert)
    # und dem Embedding-Lookup (Scatter-Add, immer host-seitig). Beide in einen
    # Puffer zu schreiben waere genau die bekannte Falle ("Gradienten-
    # Speichermodell im INT8-GPU-Pfad"): pullGradI8() holt den Geraetestand ab
    # und wuerde die CPU-Beitraege kommentarlos ueberschreiben. Deshalb bleiben
    # es zwei Puffer, die NACH dem Pull einmal zusammengefuehrt werden - siehe
    # cortex_train_step_i8().
    tiedEmbeddings*: cint

    # ==========================================================================
    # LoRA (2026-08-29, Fork snai_edge_int8_lora).
    #
    # Ein adaptiertes Gewicht rechnet   out = W.x + (alpha/rank) * B.(A.x)
    # mit A (rank x cols) und B (rows x rank). W bleibt INT8 und EINGEFROREN,
    # A und B sind FP32.
    #
    # DREI ENTSCHEIDUNGEN, DIE HIER FESTGESCHRIEBEN SIND:
    #
    # 1. A/B sind `Matrix`, NIEMALS `QMatrix`. Damit liegen sie ausserhalb des
    #    QMatrix-Gradientenpfads. Das ist kein Stilfrage: pullGradI8() holt die
    #    geraeteseitig akkumulierten Gradienten ab und ueberschreibt den
    #    Zielpuffer. Ein Adaptergradient in einem QMatrix-Gradientenpuffer
    #    waere nach dem naechsten Pull kommentarlos weg - dieselbe Fehlerklasse
    #    wie die Zwei-Quellen-Falle bei SNAI_V7 (siehe tiedEmbeddings oben).
    #
    # 2. Die Basis-Adam-Puffer (m_/v_/g_w_*) bleiben allokiert und werden bei
    #    eingefrorener Basis nur nicht mehr BESCHRIEBEN. Sie freizugeben waere
    #    der eigentliche Speichergewinn von LoRA - das ist aber ein eigener
    #    Schritt mit eigener Wirkung auf Speichern/Laden und gehoert nicht in
    #    denselben Umbau wie die Mathematik. Was hier zaehlt: die Basis
    #    veraendert sich bitgenau NICHT.
    #
    # 3. lora_h haelt h = A.x je Position aus dem Forward, weil der Backward
    #    es fuer g_B braucht. Es aus x neu zu berechnen waere billiger an
    #    Speicher und teurer an Rechenzeit - vor allem waere es eine zweite
    #    Stelle, an der dieselbe Groesse entsteht, und die beiden koennten
    #    auseinanderlaufen.
    #
    # Slot-Nummern (loraIdx): 0=w_q 1=w_k 2=w_v 3=w_o 4=w_up 5=w_down.
    # ==========================================================================
    loraRank*: cint                 # 0 = LoRA aus
    loraAlpha*: cfloat              # Skalierung ist alpha/rank
    loraMask*: cint                 # Bitmaske ueber die 6 Slots
    loraFrozenBase*: cint           # 1 = Basisgewichte bekommen keinen Adam-Schritt
    # ARM C des LoRA-Armvergleichs, "nur letzte Schicht trainieren" -
    # die billige Baseline, die LoRA schlagen muss.
    #   0 = aus (alles trainierbar, bisheriges Verhalten - und das ist der
    #       Nullwert von allocShared0, deshalb diese Zaehlrichtung und kein
    #       "trainLayersFrom = -1": ein vergessenes Init-Feld darf hier nicht
    #       versehentlich das halbe Modell einfrieren).
    #   n>0 = NUR die letzten n Transformer-Schichten bekommen einen
    #       Adam-Schritt, und dort ausschliesslich die SECHS Gewichtsmatrizen
    #       (w_q w_k w_v w_o w_up w_down).
    #
    # Eingefroren sind damit: Embeddings, w_out, rms_final, alle RMSNorm-Gains
    # und alle frueheren Schichten. Das ist eine Entscheidung, keine
    # Auslassung - es ist exakt dieselbe Tensor-Menge, die LoRA ueber seine
    # Slots adressiert. Nur so vergleicht Arm C "eine Schicht, voller Rang"
    # gegen "alle Schichten, niedriger Rang" und nicht zusaetzlich noch
    # Normierung gegen keine Normierung.
    #
    # Die Menge MUSS deckungsgleich sein mit der, die clipGlobalGradientNorm()
    # zaehlt. Zaehlte das Clipping Gradienten mit, die nie ein Gewicht bewegen,
    # wuerde die globale Norm kuenstlich gross und der Schritt der wirklich
    # trainierten Schicht still heruntergestutzt.
    trainLastLayers*: cint
    # 1 = der OPTIMIERER-Zustand der Basis ist FREIGEGEBEN (m/v/g/res und die
    # quantisierten Momente). Die GEWICHTE selbst bleiben natuerlich stehen.
    # Das ist der eigentliche Speichergewinn von LoRA und zugleich die
    # Entscheidung, die aus Feld-Kommentar Punkt 2 nachgereicht wurde: bis
    # 2026-08-29 blieben die Puffer allokiert, LoRA sparte Rechenzeit, aber
    # keinen Speicher.
    #
    # Wer dieses Feld setzt, uebernimmt die Pflicht, JEDEN Leser der Basis-
    # Optimiererpuffer abzusichern. Ein ungesicherter Zugriff ist hier kein
    # falsches Ergebnis, sondern ein Nullzeiger - lieber so herum.
    baseOptFreed*: cint
    lora_a*, m_lora_a*, v_lora_a*, g_lora_a*: ptr MatrixArray   # je numLayers*6
    lora_b*, m_lora_b*, v_lora_b*, g_lora_b*: ptr MatrixArray
    lora_h*: ptr FloatArray         # numLayers*6*ctx*rank - h aus dem Forward
    lora_dh*: ptr FloatArray        # ctx*rank - Scratch je Backward-Aufruf

    # INT8-Gewichte (nur belegt wenn weightDtype==1). m_/v_/g_ (Adam-Zustand/
    # Gradient) werden bewusst NICHT verdoppelt - Design-Entscheidung #2 haelt
    # sie immer FP32, die bestehenden m_embeddings/v_embeddings/g_embeddings
    # usw. oben werden fuer BEIDE dtypes wiederverwendet (identische Form,
    # unabhaengig davon ob das zugehoerige Gewicht int8 oder float32 ist).
    embeddings_q8*, w_out_q8*: QMatrix
    w_q_q8*, w_k_q8*, w_v_q8*, w_o_q8*, w_up_q8*, w_down_q8*: ptr QMatrixArray
    # FEHLER-RUECKFUEHRUNG (2026-08-20, Ursachenanalyse "w_out-Zeilendrift"):
    # Rundungsrest je Element aus dem letzten Requantisieren. Ohne ihn wird der
    # Fehler jedes Adam-Schritts ersatzlos verworfen und die Fehler addieren
    # sich ueber tausende Schritte als Random Walk auf - gemessen daran, dass
    # die w_out-Zeilennorm zur Funktion der UPDATE-ANZAHL statt der gelernten
    # Struktur wurde (Spearman gegen Token-Haeufigkeit: FP32 -0,554, INT8
    # -0,004). Mit Rueckfuehrung laeuft der Fehler ueber die Schritte aus,
    # statt sich aufzusummieren.
    # Nur fuer TRAINING noetig (reine Inferenz quantisiert nie neu) - deshalb
    # an das Vorhandensein des Adam-Zustands gekoppelt, nicht an weightDtype.
    res_embeddings*, res_w_out*: Matrix
    res_w_q*, res_w_k*, res_w_v*, res_w_o*, res_w_up*, res_w_down*: ptr MatrixArray
    # Scratch-Puffer fuer die dynamische Per-Aufruf-Quantisierung der
    # Eingabe-Aktivierung in matVecMulI8 (Design-Entscheidung #4). Groesse
    # max(hiddenDim, ffnDim), allokiert in cortex_quantize_from_fp32().
    i8_qscratch*: ptr Int8Array
    # PHASE 8: gebuendelter int8-Eingabeblock (ctx x max(dim,ffn)) + eine
    # Abs-Max-Skala je Position. Ersetzt i8_qscratch im gebuendelten Pfad.
    i8_qbatch*: ptr Int8Array
    i8_qbatch_scale*: ptr FloatArray
    # FULL-INT8 SCHRITT 1 (2026-08-23): Scratch fuer den ganzzahligen
    # Backward-Pfad (d_in = W^T . d_out).
    #   i8_dscratch  - der auf int8 quantisierte, mit der Zeilenskala
    #                  vorskalierte Gradient d'[r] = scale[r]*d_out[r].
    #                  Groesse max(vocabSize, hiddenDim, ffnDim), weil "rows"
    #                  hier je nach Tensor auch das Vokabular sein kann (w_out).
    #   i32_dacc     - int32-Akkumulator ueber die Zeilen-Reduktion, Groesse
    #                  max(hiddenDim, ffnDim). Erst nach der vollstaendigen
    #                  Reduktion wird EINMAL dequantisiert.
    i8_dscratch*: ptr Int8Array
    i32_dacc*: ptr IntArray
    #   i8_dbscale - Abs-Max-Skala je 64er-Block des Gradientenvektors
    #                (SCHRITT 1a). Laenge: max_rows/64 aufgerundet.
    i8_dbscale*: ptr FloatArray
    # SCHRITT 1b: alle drei Puffer sind THREAD-lokal segmentiert. Thread t
    # benutzt [t*Stride ..< (t+1)*Stride]. nThreads==0 heisst "nicht
    # allokiert" (dann faellt der Backward auf den Float-Pfad zurueck).
    i8_bwThreads*: cint
    i8_dqStride*, i8_accStride*, i8_bsStride*: cint
    # SCHRITT 2: Ganzzahl-Gradientenakkumulation (Aussenprodukt).
    #   i8_gqi     - die quantisierte Eingabe-Aktivierung, ctx x maxCols.
    #                Bewusst NICHT i8_qbatch mitbenutzt: das wuerde im
    #                Backward einen Forward-Puffer ueberschreiben und nur so
    #                lange funktionieren, wie Forward und Backward strikt
    #                getrennt bleiben - eine stille Kopplung, die beim naechsten
    #                Umbau bricht.
    #   i8_gdscale - Skala je ZEILE des Gradienten (ueber Positionen konstant)
    #   i8_giscale - Skala je SPALTE der Aktivierung (ueber Positionen konstant)
    i8_gqi*: ptr Int8Array
    i8_gdscale*, i8_giscale*: ptr FloatArray
    i8_gqiStride*: cint
    # PHASE 7 (GPU-Dispatch): 1 = die INT8-Gewichte/Skalen wurden auf dem HOST
    # veraendert (Adam-Schritt, Re-Scaling) und muessen vor der naechsten
    # GPU-Rechnung zurueckgeschrieben werden. Lazy statt sofort, damit pro
    # Schritt nur EIN Rueckschrieb faellt und nicht je Aenderungsstelle einer.
    qDirty*: cint

    # KV-Cache-Quantisierung (Entwurf "KV-Cache-Design"):
    # INT8 mit PRO-POSITION-Skala (nicht pro Ausgabe-Kanal wie bei Gewichten -
    # die Wertespanne aendert sich pro Zeitschritt). QMatrix passt hier direkt:
    # "Zeile" = Position (rows=ctxSize, cols=hiddenDim, identisches Layout zu
    # k_cache/v_cache oben), scale[pos] ist die Skala fuer genau diese
    # Position. d_k_cache/d_v_cache (Gradienten) bleiben die BESTEHENDEN FP32-
    # Felder unten - Cache-Gradienten sind wie Adam-Momente immer FP32.
    k_cache_q8*, v_cache_q8*: ptr QMatrixArray
    # Scratch fuer die rohe (noch unquantisierte) K/V-Berechnung EINER
    # Position vor dem Schreiben in k_cache_q8/v_cache_q8 (K braucht RoPE VOR
    # der Quantisierung). Groesse hiddenDim.
    kv_raw_buf*: ptr FloatArray
    
    rms_final_weight*, m_rms_final_weight*, v_rms_final_weight*, g_rms_final_weight*: ptr FloatArray

    rms_att_weights*, m_rms_att_weights*, v_rms_att_weights*, g_rms_att_weights*: ptr FloatPtrArray
    rms_ffn_weights*, m_rms_ffn_weights*, v_rms_ffn_weights*, g_rms_ffn_weights*: ptr FloatPtrArray
    mq_w_q*, vq_w_q*, mq_w_k*, vq_w_k*, mq_w_v*, vq_w_v*: ptr QMomentArray
    mq_w_o*, vq_w_o*, mq_w_up*, vq_w_up*, mq_w_down*, vq_w_down*: ptr QMomentArray
    w_q*, m_w_q*, v_w_q*, g_w_q*: ptr MatrixArray
    w_k*, m_w_k*, v_w_k*, g_w_k*: ptr MatrixArray
    w_v*, m_w_v*, v_w_v*, g_w_v*: ptr MatrixArray
    w_o*, m_w_o*, v_w_o*, g_w_o*: ptr MatrixArray
    w_up*, m_w_up*, v_w_up*, g_w_up*: ptr MatrixArray
    w_down*, m_w_down*, v_w_down*, g_w_down*: ptr MatrixArray

    k_cache*, v_cache*, act_q*: ptr MatrixArray
    d_k_cache*, d_v_cache*: ptr MatrixArray
    logits_cache*: Matrix
    
    act_hidden*, act_norm_att*, act_att_out*: ptr FloatPtrArray
    act_hidden_ffn*, act_norm_ffn*, act_ffn_in*, act_ffn_out*: ptr FloatPtrArray
    # SCHRITT 4b (Speicherumbau): act_ffn_out als int8 mit Pro-Position-Skala.
    # Belegt statt act_ffn_out, wenn init_quant_acts beim cortex_init() gesetzt
    # war. Der Forward braucht die Werte kurzzeitig in float - dafuer EIN
    # gemeinsamer Scratch (ctx*ffn) statt eines Puffers je Layer; genau daher
    # kommt der Gewinn: die Historie faellt auf ein Viertel, der Scratch
    # existiert nur einmal.
    act_ffn_out_q8*: ptr QMatrixArray
    act_ffn_scratch*: ptr FloatArray
    quantActs*: cint
    # SCHRITT 4c: dasselbe fuer act_ffn_in. Eigenes Flag, damit 4b und 4c
    # getrennt messbar bleiben - 4b ist bereits auf Echtdaten validiert, eine
    # gemeinsame Schaltung wuerde diese Aussage mit einer ungeprueften
    # Aenderung vermischen.
    act_ffn_in_q8*: ptr QMatrixArray
    quantActsIn*: cint
    silu_lut*: ptr FloatArray      # 256 Eintraege, SCHRITT 5a
    silu_exp*: ptr FloatPtrArray   # SILU-EXP: je Schicht ctx*256 Werte expf(-v) aus dem Vorwaerts
    silu_exp_ok*: ptr UncheckedArray[cint]  # SILU-EXP: je Schicht 1, wenn die Tabelle zum letzten Vorwaerts gehoert
    # Update 2026-08-09 (Nachruest-Paket #6 "Dropout"):
    # gleiche Form/Groesse wie act_ffn_out (ctx*ffnDim je Layer) - haelt pro
    # Element entweder 0.0 (verworfen) oder 1.0/(1.0-rate) (behalten, bereits
    # skaliert - "Inverted Dropout", damit im Eval/Inferenz-Pfad KEINE
    # separate Kompensation noetig ist, siehe applyDropoutForward()). Muss von
    # Forward bis zum entsprechenden Backward-Aufruf desselben Layers
    # ueberleben (beide sind getrennte Durchlaeufe ueber alle Positionen,
    # nicht Position-fuer-Position verschraenkt) - deshalb ein persistenter
    # State-Puffer, keine lokale Variable.
    # SCHRITT 4a: Bitmaske (1 Bit je Element) statt float32 - 32x kleiner,
    # verlustfrei. Zeigerarray auf uint8-Bloecke von je ceil(ctx*ffn/8) Bytes.
    dropout_mask*: ptr Uint8PtrArray
    act_hidden_final*: ptr FloatArray
    # V11.9: fuer den gebuendelten w_out-Pfad. act_norm_final haelt die Ausgabe
    # der finalen RMSNorm je Position, d_norm_all das Ergebnis des gebuendelten
    # w_out-Backwards. Beide ctx*dim Floats -> bei ctx=1024, dim=256 je 1 MB.
    act_norm_final*, d_norm_all*: ptr FloatArray

    # AUDIT: fuer den gebuendelten (layer-major) Attention-Pfad. d_hidden_all
    # ersetzt d_hidden als Positions-persistenter Gradienten-Akkumulator ueber
    # die gesamte Layer-Countdown-Schleife (statt pro Position neu). d_att_out_all
    # und d_q_all sind die gebuendelten Ein-/Ausgaben fuer attentionBackwardBatchedD.
    # Alle drei ctx*dim Floats, wie act_norm_final/d_norm_all.
    d_hidden_all*, d_att_out_all*, d_q_all*: ptr FloatArray

    # AUDIT: fuer die gebuendelte Q/K/V/O/Up/Down-Mathematik (matMulBatchedD &
    # Co., dieselbe Infrastruktur wie beim gebuendelten w_out). mm_hd_scratch
    # (ctx*dim) und mm_ffn_scratch (ctx*ffn) sind reiner Ein-Layer-Zwischenspeicher,
    # sequenziell innerhalb eines Sub-Pass wiederverwendet - kein Positions- oder
    # Layer-persistenter Zustand noetig.
    mm_hd_scratch*, mm_ffn_scratch*: ptr FloatArray

    j_space_cache*: ptr FloatPtrArray

    hidden_state_buf*, norm_buf*, att_out_buf*, ffn_buf*, q_buf*: ptr FloatArray
    d_logits_buf*, scores_buf*, d_w_buf*: ptr FloatArray
    d_hidden*, d_norm*, d_att_out*, d_q*, d_ffn*: ptr FloatArray

    # EMB-EINGANG (2026-11-03, messbuch snai/engine-emb-eingang): das gebundene Embedding geht am EINGANG mal
    # embEinF = sqrt(hiddenDim) in den Restpfad, die Ausgabeseite (w_out = dieselbe Matrix) bleibt unveraendert.
    # Eigenschaft des MODELLS, nicht des Laufs: SNAI_V7 Flags Bit 1, beim Laden gelesen, beim Speichern geschrieben.
    # Null-Init (allocShared0) = aus; dann ist der Faktor exakt 1.0 und jedes Modell ohne Bit rechnet bytegleich.
    embEinAn*: cint
    embEinF*: cfloat
    # FFN-SKIP (2026-11-03, messbuch snai/engine-ffn-weg): je Schicht 1 = FFN-Zweig aus (rms_ffn UND w_down exakt
    # 0), Vorwaerts und Rueckwaerts dieses Zweigs werden uebersprungen. Erkannt an den Werten, nicht an einem
    # Schalter (ffnSkipAktualisieren). nil = noch nie erkannt. ffnAusSig: zuletzt gemeldeter Stand.
    ffnAus*: ptr Uint8Array
    ffnAusSig*: uint64

# EMB-EINGANG: Faktor des Embedding-Lookups am Eingang. Aus -> exakt 1.0 (x * 1.0 ist in IEEE exakt).
template embFak(s: ptr CortexState): cfloat =
  (if s.embEinAn != 0: s.embEinF else: 1.0'f32)

# FFN-SKIP: ist der FFN-Zweig der Schicht l als aus erkannt?
template ffnAusL(s: ptr CortexState, l: int): bool =
  ((not s.ffnAus.isNil) and s.ffnAus[l] != 0'u8)

var gpu_initialized: bool = false

# Update 2026-08-08: intelligenter Backend-Switch (siehe cortex_init_gpu()
# unten). gpu_initialized bleibt der reine "irgendein
# GPU-Backend aktiv?"-Schalter (von useGpuMat() und den meisten Gate-Checks
# unveraendert weiterverwendet) - gpu_backend haelt zusaetzlich WELCHES.
type GpuBackend = enum gbNone, gbOpenCL, gbCuda
var gpu_backend: GpuBackend = gbNone

proc cortex_get_gpu_backend*(): cint {.ffi.} =
  ## Fuer Diagnose/Logging von aussen (PHP-Seite): 0=keins, 1=OpenCL, 2=CUDA.
  case gpu_backend
  of gbNone: 0.cint
  of gbOpenCL: 1.cint
  of gbCuda: 2.cint

# V11.4: EINE Stelle entscheidet ueber CPU/GPU. Forward, Backward, Zeroing und
# Sync muessen zwingend dieselbe Antwort bekommen - sonst holt ein Sync
# Device-Nullen ueber ein auf der CPU berechnetes Gradientenfeld.
# V11.5: Die Schwelle ist jetzt eine ELEMENTZAHL, keine Kantenlaenge.
# Grund: ein GPU-Roundtrip kostet eine feste Latenz (gemessen ~1,8 ms). Eine
# 256x256-Matrix sind 65k MACs - die rechnet die CPU in 66 us. Die GPU zu
# fragen ist dort 27x langsamer. Erst ab ~1,8M Elementen lohnt der Weg.
var gpu_min_elems: int = 1_000_000

proc cortex_set_gpu_threshold*(elems: cint) {.ffi.} =
  gpu_min_elems = (if elems < 0: 0 else: elems.int)

proc cortex_get_gpu_threshold*(): cint {.ffi.} =
  gpu_min_elems.cint

# ==============================================================================
# WEIGHT-DECAY (AdamW-Style, dekorreliert vom Adam-Update selbst).
# Teil von "Trainings-Absicherung: Nachruest-Paket" Punkt 1.
# Default 0.0 = exaktes No-Op, identisch zum bisherigen reinen-Adam-Verhalten -
# bestehende Laeufe/Checkpoints sind unberuehrt, solange niemand explizit
# cortex_set_weight_decay() aufruft. Greift NUR an echten Gewichtsmatrizen
# (Embeddings, w_q/k/v/o, w_up/down, w_out) - RMSNorm-Gains werden bewusst
# ausgenommen (sollen um 1.0 pendeln, nicht gegen 0 gezogen werden), siehe
# upA()/oclUpA() unten, die global_weight_decay NICHT weiterreichen.
# ==============================================================================
var global_weight_decay: cfloat = 0.0

proc cortex_set_weight_decay*(wd: cfloat) {.ffi.} =
  global_weight_decay = (if wd < 0.0: 0.0 else: wd)

proc cortex_get_weight_decay*(): cfloat {.ffi.} =
  global_weight_decay

# 2026-10-16 (Merkmalsspalte): Weight-Decay auf den Embeddings abschaltbar.
# Lange Laeufe mit WD 0,1 liessen die kleinen Embedding-Gewichte unter die Rundungsstufe schrumpfen, waehrend
# die vom Gradienten nachgespeiste Merkmalsspalte das Zeilenmaximum hielt. 1 = Embeddings bekommen
# global_weight_decay (VORGABE), 0 = Embeddings ohne Decay. 2026-10-17 zurueck auf 1: ohne Decay wachsen die
# Embedding-Normen unbegrenzt und das Training zerfaellt in langen Laeufen ab Genesis (LANG64).
# Bei gebundenen Modellen ist w_out dieselbe Matrix; bei ungebundenen gilt der Schalter seit 2026-10-16 auch fuer w_out.
var wd_embeddings*: cint = 1

proc cortex_set_wd_embeddings*(enabled: cint) {.ffi.} =
  wd_embeddings = enabled

proc cortex_get_wd_embeddings*(): cint {.ffi.} =
  wd_embeddings

# Update 2026-08-09 (Nachruest-Paket #9 "Gradient-Norm-
# Logging"): clipGlobalGradientNorm() berechnete die globale L2-Norm schon
# immer fuer die Clip-Entscheidung, hat sie aber bisher nirgends nach aussen
# gereicht. Gleiches Muster wie global_weight_decay oben - ein Prozess haelt
# genau einen CortexState, ein globaler Wert reicht.
var last_grad_norm: cfloat = 0.0

proc cortex_get_last_grad_norm*(): cfloat {.ffi.} =
  last_grad_norm

# Update 2026-10-10 (Segmentpruefung): Quadratsummen des letzten Schritts je
# Tensorgruppe, VOR dem Clipping, aus denselben calcL2Sq-Werten wie die globale
# Norm. Anlass: bei gesaettigter Attention verschwindet der Q/K-Gradient,
# waehrend die globale Norm unauffaellig bleibt. Gruppen: 0 Embedding+w_out,
# 1 Q/K, 2 V/O, 3 FFN, 4 Rest (RMSNorm-Gains, LoRA); 100+l = Q/K der Schicht l.
# Rueckgabe ist der ANTEIL an der Gesamt-Quadratsumme (0..1), damit er von der
# Summen-/Mittelwert-Umrechnung der Norm unabhaengig ist. -1 = unbekannter
# Index oder noch kein Schritt.
const GRAD_GROUPS = 5
const GRAD_QK_LAYERS_MAX = 64
var last_grad_group_sq: array[GRAD_GROUPS, cfloat]
var last_grad_qk_layer_sq: array[GRAD_QK_LAYERS_MAX, cfloat]
var last_grad_total_sq: cfloat = 0.0
var last_grad_layers: cint = 0

proc cortex_get_last_grad_share*(idx: cint): cfloat {.ffi.} =
  if last_grad_total_sq <= 0.0 or last_grad_total_sq.isNaN: return -1.0
  if idx >= 0 and idx < GRAD_GROUPS:
    return last_grad_group_sq[idx] / last_grad_total_sq
  if idx >= 100 and idx < 100 + min(last_grad_layers, GRAD_QK_LAYERS_MAX):
    return last_grad_qk_layer_sq[idx - 100] / last_grad_total_sq
  return -1.0

# ==============================================================================
# DROPOUT ("Trainings-Absicherung: Nachruest-Paket"
# Punkt 6, umgesetzt im Rahmen "Engine-/Framework-Verbesserungen" 2026-08-09).
# Default 0.0 = exaktes No-Op, gleiches Prinzip wie global_weight_decay oben -
# bestehende Laeufe sind unberuehrt, solange niemand explizit
# cortex_set_dropout_rate() aufruft. Greift NUR in cortex_train_step() (auf
# der FFN-Aktivierung, nach SiLU, vor der Down-Projektion) - cortex_forward()
# (Inferenz/Held-out-Eval) kennt kein Dropout, das ist die komplette
# Train/Eval-Unterscheidung: zwei bereits strukturell getrennte Code-Pfade,
# keine zusaetzliche Modus-Variable noetig.
# ==============================================================================
var global_dropout_rate: cfloat = 0.0
var dropout_rng_seeded = false

proc cortex_set_dropout_rate*(rate: cfloat) {.ffi.} =
  # Obergrenze 0.9 statt 1.0 - bei rate=1.0 waere der Skalierungsfaktor
  # 1.0/(1.0-rate) eine Division durch Null.
  global_dropout_rate = (if rate < 0.0: 0.0 elif rate > 0.9: 0.9 else: rate)
  if global_dropout_rate > 0.0 and not dropout_rng_seeded:
    randomize()  # einmalig, aus der System-Uhr
    dropout_rng_seeded = true

proc cortex_get_dropout_rate*(): cfloat {.ffi.} =
  global_dropout_rate

# Inverted Dropout: skaliert die ueberlebenden Elemente bereits im Training um
# 1.0/(1.0-rate) hoch, damit cortex_forward() (Inferenz) UNVERAENDERT bleiben
# kann - keine separate "* (1-rate)"-Kompensation dort noetig, die leicht
# vergessen werden koennte. buf wird in-place skaliert, mask haelt denselben
# Wert (0.0 oder 1.0/(1.0-rate)) pro Element fest, fuer den spaeteren
# Backward-Aufruf auf GENAU diesem Layer.
# FULL-INT8 SCHRITT 4a (2026-08-24): Dropout-Maske als BITMASKE.
# Die Maske kennt nur zwei Werte - 0 oder keepScale = 1/(1-rate). Sie als
# float32 zu speichern verschwendet 32 Bit fuer 1 Bit Information. Bei den
# Ladder-Stufen ist das kein Detail: `dropout_mask` ist ctx*ffn*layers gross,
# bei Goddess also ~16 GB von den 68 GB Aktivierungshistorie.
#
# Anders als alles bisher in diesem Port ist das VERLUSTFREI - es wird nicht
# quantisiert, sondern nur eine Ja/Nein-Entscheidung kompakt abgelegt. Der
# Faktor ist 32x, nicht 4x.
proc dropBitGet(mask: ptr Uint8Array, i: int): bool {.inline.} =
  (mask[i shr 3] and (1'u8 shl (i and 7)).uint8) != 0'u8

proc dropBitSet(mask: ptr Uint8Array, i: int, keep: bool) {.inline.} =
  let byteIdx = i shr 3
  let bit = (1'u8 shl (i and 7)).uint8
  if keep: mask[byteIdx] = mask[byteIdx] or bit
  else:    mask[byteIdx] = mask[byteIdx] and (not bit)

proc applyDropoutForward(buf: ptr FloatArray, mask: ptr Uint8Array, n: int,
                         bitOff: int = 0) {.inline.} =
  ## `bitOff` statt eines vorverschobenen Zeigers: ein Bit ist nicht
  ## byte-adressierbar, `addr mask[off]` gibt es also nicht. Der Einzelpfad
  ## uebergibt hier pos*ffnDim.
  if global_dropout_rate <= 0.0: return
  let keepScale = 1.0'f32 / (1.0'f32 - global_dropout_rate)
  for i in 0 ..< n:
    if rand(1.0) < global_dropout_rate.float:
      dropBitSet(mask, bitOff + i, false)
      buf[i] = 0.0
    else:
      dropBitSet(mask, bitOff + i, true)
      buf[i] *= keepScale

# Kettenregel fuer y = mask * x: dL/dx = dL/dy * mask - exakt dieselbe Maske
# wie im zugehoerigen Forward-Aufruf, deshalb kein erneutes Wuerfeln hier.
proc applyDropoutBackward(grad: ptr FloatArray, mask: ptr Uint8Array, n: int,
                          bitOff: int = 0) {.inline.} =
  ## Kettenregel fuer y = mask * x. keepScale wird aus der Rate rekonstruiert
  ## statt gespeichert - sie aendert sich innerhalb eines Trainingsschritts
  ## nicht (global_dropout_rate wird nur zwischen Laeufen gesetzt).
  if global_dropout_rate <= 0.0: return
  let keepScale = 1.0'f32 / (1.0'f32 - global_dropout_rate)
  for i in 0 ..< n:
    grad[i] = (if dropBitGet(mask, bitOff + i): grad[i] * keepScale else: 0.0)

# ==============================================================================
# LABEL SMOOTHING ("Naechste Schritte", Punkt 7).
# Default 0.0 = exaktes No-Op, gleiches Prinzip wie global_weight_decay/
# global_dropout_rate oben - bestehende Laeufe sind unberuehrt, solange
# niemand explizit cortex_set_label_smoothing() aufruft. Wirkt NUR auf die
# drei One-Hot-Gradient-Stellen (logits[v] - target), die auch der
# Loss-Masking-Fix vom 2026-08-12 angefasst hat - ersetzt dort das harte Ziel
# 1.0/0.0 durch das geglaettete Ziel (1-eps)/eps/(vocabSize-1). Die
# geloggte/getrackte total_loss (reines -ln(p_korrekt)) bleibt bewusst
# unveraendert, damit Held-out-Loss-Werte mit bisherigen Laeufen vergleichbar
# bleiben - Standardpraxis (z.B. fairseq trennt "loss" und "nll_loss"
# genauso), nur das Gradientensignal wird geglaettet.
# ==============================================================================
var global_label_smoothing: cfloat = 0.0

proc cortex_set_label_smoothing*(eps: cfloat) {.ffi.} =
  # Obergrenze 0.9 analog Dropout - bei eps=1.0 waere das Zielsignal fuer die
  # korrekte Klasse identisch zur Gleichverteilung, kein sinnvolles Training mehr.
  global_label_smoothing = (if eps < 0.0: 0.0 elif eps > 0.9: 0.9 else: eps)

proc cortex_get_label_smoothing*(): cfloat {.ffi.} =
  global_label_smoothing

# Geglaettetes Ziel fuer Klasse v gegen das wahre Label tgid. Bei eps=0.0
# identisch zum bisherigen harten One-Hot-Ziel (exaktes No-Op).
proc smoothedTarget(v, tgid: int, vocabSize: cint): cfloat {.inline.} =
  if global_label_smoothing <= 0.0:
    return (if v == tgid: 1.0.cfloat else: 0.0.cfloat)
  let eps = global_label_smoothing
  if v == tgid:
    (1.0'f32 - eps)
  else:
    eps / (vocabSize - 1).cfloat

# ==============================================================================
# LR-BOOST fuer frisch Net2Net-expandierte Parameter (Stichwort
# "Differenzierte Learning-Rate fuer frisch Net2Net-expandierte
# Parameter"). upscale_matrix_stream() in der Destille uebernimmt aus
# der Quelle nur den [0:old_dim)x[0:old_dim)-Block unveraendert, jede Zeile/
# Spalte darueber hinaus ist frisches Rauschen um Null - bei einer
# Dim-Verdopplung sind das bis zu 75% der Zellen einer quadratischen Matrix.
# Ohne Differenzierung lernen diese mit derselben, fuer die Gesamtheit moderat
# gewaehlten Rate wie die bereits konvergierten Altgewichte.
# growth_old_dim < 0 = kein Boundary gesetzt = kein Boost, identisch zum
# bisherigen Verhalten (Default, z.B. fuer Genesis-Modelle ohne
# Expansionshistorie).
# ==============================================================================
var growth_old_dim: cint = -1
var growth_old_ffn: cint = -1
var growth_old_layers: cint = -1
var growth_boost: cfloat = 1.0

proc cortex_set_growth_boundary*(old_dim, old_ffn, old_layers: cint, boost: cfloat) {.ffi.} =
  growth_old_dim = old_dim
  growth_old_ffn = old_ffn
  growth_old_layers = old_layers
  growth_boost = boost

proc elemBoost(idx, cols, boundR, boundC: cint): cfloat {.inline.} =
  if cols <= 0: return 1.0
  let row = idx div cols
  let col = idx mod cols
  if row >= boundR or col >= boundC: return growth_boost
  return 1.0

# ==============================================================================
# V11.6 PROFILER - keine Theorie mehr, nur Messwerte.
# Buckets: 0 matVecMul GPU | 1 matVecMul CPU | 2 backwardAcc GPU
#          3 backwardAcc CPU | 4 Attention GPU | 5 Clip+Adam | 6 Step gesamt
# "Rest" = Bucket 6 minus 0..5 = Normen, Softmax, SwiGLU, Embedding-Scatter.
# ==============================================================================
var prof: array[8, float64]

proc cortex_profile_reset*() {.ffi.} =
  for i in 0 ..< 8: prof[i] = 0.0

proc cortex_profile_get*(idx: cint): cfloat {.ffi.} =
  if idx < 0 or idx > 7: return -1.0
  return (prof[idx] * 1000.0).cfloat

{.emit: """
#ifdef _OPENMP
#include <omp.h>
int cortex_omp_probe(void) { return omp_get_max_threads(); }
/* FULL-INT8 SCHRITT 1b: der gebuendelte Backward-Pfad parallelisiert ueber
   die Positionen. Der Ganzzahl-Kernel braucht pro Position Scratch (dq,
   int32-Akkumulator, Blockskalen) - die Puffer werden deshalb THREAD-lokal
   angelegt (nThreads statt nPositions: bei ctx=8192 waeren pro Position
   dimensionierte Puffer hunderte MB, pro Thread sind es Kilobyte). */
int snai_omp_thread(void) { return omp_get_thread_num(); }
#else
int cortex_omp_probe(void) { return 0; }
int snai_omp_thread(void) { return 0; }
#endif
""".}

proc cortex_omp_probe(): cint {.importc, nodecl.}
proc snaiOmpThread(): cint {.importc: "snai_omp_thread", nodecl.}
{.emit: """
#include <time.h>
#ifdef _OPENMP
static int snai_in_par(void) { return omp_in_parallel(); }
#else
static int snai_in_par(void) { return 0; }
#endif
static double snai_now(void) { struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t); return t.tv_sec + t.tv_nsec * 1e-9; }
""".}
proc snaiInPar(): cint {.importc: "snai_in_par", nodecl.}
proc snaiNow(): cdouble {.importc: "snai_now", nodecl.}
proc c_getenv_z(name: cstring): cstring {.importc: "getenv", header: "<stdlib.h>".}
const ZA_NAMEN = ["mmF", "mmT", "gA", "attF", "attB", "batch", "clip", "adam", "ges"]
const ZA_MMF = 0; const ZA_MMT = 1; const ZA_GA = 2; const ZA_ATTF = 3; const ZA_ATTB = 4
const ZA_BATCH = 5; const ZA_CLIP = 6; const ZA_ADAM = 7; const ZA_GES = 8
var zeitAn = -1
var zeitRot = -1
var zeitSumme: array[9, float]
var zeitZahl: array[9, int]
var zeitSchritt = 0
proc zeitInit() =
  if zeitAn >= 0: return
  let e = c_getenv_z("SNAI_I8_ZEIT")
  zeitAn = (if not e.isNil and $e == "1": 1 else: 0)
  let r = c_getenv_z("SNAI_I8_ZEIT_ROT")
  if not r.isNil:
    for i, n in ZA_NAMEN:
      if $r == n: zeitRot = i
  if zeitAn == 1: stderr.writeLine("[ZEIT] Sonde an", (if zeitRot >= 0: " ROT " & ZA_NAMEN[zeitRot] else: ""))
template zeitMiss(k: int, rumpf: untyped) =
  zeitInit()
  if zeitAn == 1 and snaiInPar() == 0:
    let t0z = snaiNow()
    rumpf
    if zeitRot == k:
      let tw = snaiNow()
      while snaiNow() - tw < 0.002: discard
    zeitSumme[k] += (snaiNow() - t0z).float
    zeitZahl[k] += 1
  else:
    rumpf
proc zeitZeile() =
  if zeitAn != 1: return
  inc zeitSchritt
  var z = "[ZEIT] schritt=" & $zeitSchritt
  for i, n in ZA_NAMEN:
    z.add(" " & n & "=" & $(int(zeitSumme[i] * 1e6)) & "us/" & $zeitZahl[i])
    zeitSumme[i] = 0.0
    zeitZahl[i] = 0
  stderr.writeLine(z)

# Gibt die Zahl der OpenMP-Threads zurueck, 0 = ohne -fopenmp gebaut.
# 0 heisst: alle ||-Schleifen laufen seriell, der Umbau ist wirkungslos.
proc cortex_get_threads*(): cint {.ffi.} =
  cortex_omp_probe()

# ==============================================================================
# Update 2026-08-08: BACKEND-DISPATCH-SCHICHT
# Duenne 1:1-Wrapper um ocl_*/cuda_* - jede bestehende Aufrufstelle im Rest
# dieser Datei ruft ab jetzt gpuX() statt ocl_X() direkt auf, verzweigt aber
# NICHT selbst auf den Backend-Typ (das bleibt hier zentral gebuendelt, damit
# nicht an 15 Stellen im File dieselbe case-Unterscheidung wiederholt wird).
# Die umgebende gpu_initialized/useGpuMat-Gate-Logik an den Aufrufstellen
# bleibt unveraendert - nur der innere Funktionsname aendert sich.
# ==============================================================================

proc gpuReleaseBuffer(p: pointer) {.inline.} =
  case gpu_backend
  of gbCuda: cuda_release_buffer(p)
  of gbOpenCL: ocl_release_buffer(p)
  of gbNone: discard

proc gpuSyncToHost(p: pointer) {.inline.} =
  case gpu_backend
  of gbCuda: cuda_sync_to_host(p)
  of gbOpenCL: ocl_sync_to_host(p)
  of gbNone: discard

# GPU-Adam (2026-10-14), Register der Puffer, die im residenten Modus
# (SNAI_I8_GPU_ADAM=1) NUR auf der Karte aktuell sind: Momente (QMoment) und
# Rundungsreste. Der Kartenpuffer-Cache ist ueber den HOST-Zeiger indiziert und
# laedt nur beim ersten Anlegen hoch. Deshalb:
#  - gpuAdamSyncHost(): vor jedem Lesen auf dem Host zurueckholen
#    (cortex_extract_adam_layer, also jeder Checkpoint).
#  - gpuAdamDrop(): vor jedem Schreiben oder Freigeben auf dem Host - erst
#    zurueckholen, dann die Kartenkopien verwerfen; der naechste GPU-Adam
#    laedt neu hoch. Ohne das rechnete die Karte nach cortex_load_adam_layer
#    mit den alten Momenten weiter, und nach cortex_free konnte ein neuer
#    Zustand mit wiederverwendeter Adresse einen fremden Kartenpuffer treffen.
#  - gaOwn: alle uebrigen Kartenpuffer, die der GPU-Adam ueber einen
#    Host-Zeiger angelegt hat (Gewichte, Skalen; in Modus 2 auch Momente und
#    Reste). Sie sind nie allein massgeblich, muessen aber beim Freigeben mit
#    weg: gemessen 2026-10-14 vergibt der Allokator die Adresse frueherer
#    Gewichte (n Byte) an Momente eines neuen Zustands (ebenfalls n Byte) -
#    der Cache lieferte dann die alten Gewichte als Momente.
var gaRegs: seq[pointer]
var gaOwn: seq[pointer]
var gaStale = false
var gaCalls = 0
proc gpuAdamSyncHost() =
  if not gaStale: return
  for p in gaRegs: gpuSyncToHost(p)
  gaStale = false
proc gpuAdamDrop() =
  gpuAdamSyncHost()
  for p in gaRegs: gpuReleaseBuffer(p)
  for p in gaOwn: gpuReleaseBuffer(p)
  gaRegs.setLen(0)
  gaOwn.setLen(0)

proc gpuZeroBuffer(p: ptr cfloat, bytes: csize_t) {.inline.} =
  case gpu_backend
  of gbCuda: cuda_zero_buffer(p, bytes)
  of gbOpenCL: ocl_zero_buffer(p, bytes)
  of gbNone: discard

proc gpuMatVecMul(m, v, o: ptr cfloat, rows, cols: cint) {.inline.} =
  case gpu_backend
  of gbCuda: cuda_matVecMul(m, v, o, rows, cols)
  of gbOpenCL: ocl_matVecMul(m, v, o, rows, cols)
  of gbNone: discard

proc gpuMatVecMulT(m, d_out, d_in: ptr cfloat, rows, cols, accumulate: cint) {.inline.} =
  case gpu_backend
  of gbCuda: cuda_matVecMulT(m, d_out, d_in, rows, cols, accumulate)
  of gbOpenCL: ocl_matVecMulT(m, d_out, d_in, rows, cols, accumulate)
  of gbNone: discard

proc gpuGradAccum(gm, d_out, i_v: ptr cfloat, rows, cols: cint) {.inline.} =
  case gpu_backend
  of gbCuda: cuda_gradAccum(gm, d_out, i_v, rows, cols)
  of gbOpenCL: ocl_gradAccum(gm, d_out, i_v, rows, cols)
  of gbNone: discard

proc gpuMatMulBatched(m, i_v, o_v: ptr cfloat, rows, cols, batch, maxBatch: cint) {.inline.} =
  # Update 2026-08-09: cuda_matMulBatched() cached d_in/d_out in cuda_get_buffer()
  # unter dem Host-Pointer MIT fester Groesse (siehe cortex_cuda.cu) - anders als
  # matMulTBatched/gradAccumBatched/attentionForwardBatched, die fuer variable
  # Batchgroessen den Ephemeral-Grow-Pattern nutzen. Vorher wurde hier `batch`
  # (die tatsaechliche, PRO AUFRUF variierende Fenstergroesse - siehe `act` in
  # cortex_train_step) fuer BEIDE Parameter (batch_size UND max_batch) durch-
  # gereicht. Sobald ein kuerzeres Restfenster (letztes, nicht volles ctx-
  # Fenster einer Chunk-Datei) denselben Host-Pointer mit einer ANDEREN Groesse
  # registrierte als zuvor, schlug cuda_get_buffer() mit "Buffer Size Mismatch"
  # fehl und lieferte NULL zurueck - die Gewichts-Aktualisierung fuer genau
  # diesen Schritt wurde daraufhin still uebersprungen (kein Crash, siehe Guard
  # in cuda_matMulBatched: "if (!d_M || !d_in || !d_out) return;"). Bis zu
  # diesem Fund NIE in einem echten Lauf sichtbar geworden, weil CUDA in der
  # Produktion mangels $ORIGIN-Rpath nie tatsaechlich griff (siehe Roadmap-
  # Update) - erst der heutige echte End-to-End-Test hat es aufgedeckt. Fix:
  # `maxBatch` ist die FESTE Allokationsgroesse der beteiligten Host-Puffer
  # (immer state.ctxSize, siehe Aufrufer unten) - `batch` bleibt die echte,
  # variierende Elementzahl fuer die eigentliche Berechnung.
  case gpu_backend
  of gbCuda: cuda_matMulBatched(m, i_v, o_v, rows, cols, batch, maxBatch)
  of gbOpenCL: ocl_matMulBatched(m, i_v, o_v, rows, cols, batch)
  of gbNone: discard

proc gpuMatMulTBatched(m, d_out, d_in: ptr cfloat, rows, cols, batch, accumulate: cint) {.inline.} =
  case gpu_backend
  of gbCuda: cuda_matMulTBatched(m, d_out, d_in, rows, cols, batch, accumulate)
  of gbOpenCL: ocl_matMulTBatched(m, d_out, d_in, rows, cols, batch, accumulate)
  of gbNone: discard

proc gpuGradAccumBatched(gm, d_out, i_v: ptr cfloat, rows, cols, batch: cint) {.inline.} =
  case gpu_backend
  of gbCuda: cuda_gradAccumBatched(gm, d_out, i_v, rows, cols, batch)
  of gbOpenCL: ocl_gradAccumBatched(gm, d_out, i_v, rows, cols, batch)
  of gbNone: discard

proc gpuAttentionForward(q, k, v, o: ptr cfloat, pos, numHeads, headSize, dim, ctx: cint) {.inline.} =
  case gpu_backend
  of gbCuda: cuda_attentionForward(q, k, v, o, pos, numHeads, headSize, dim, ctx)
  of gbOpenCL: ocl_attentionForward(q, k, v, o, pos, numHeads, headSize, dim, ctx)
  of gbNone: discard

proc gpuAttentionBackward(q, k, v, d_att_out, d_q, d_k, d_v: ptr cfloat, pos, numHeads, headSize, dim, ctx: cint) {.inline.} =
  case gpu_backend
  of gbCuda: cuda_attentionBackward(q, k, v, d_att_out, d_q, d_k, d_v, pos, numHeads, headSize, dim, ctx)
  of gbOpenCL: ocl_attentionBackward(q, k, v, d_att_out, d_q, d_k, d_v, pos, numHeads, headSize, dim, ctx)
  of gbNone: discard

proc gpuAttentionForwardBatched(q_all, k, v, out_all: ptr cfloat, act, numHeads, headSize, dim, ctx: cint) {.inline.} =
  case gpu_backend
  of gbCuda: cuda_attentionForwardBatched(q_all, k, v, out_all, act, numHeads, headSize, dim, ctx)
  of gbOpenCL: ocl_attentionForwardBatched(q_all, k, v, out_all, act, numHeads, headSize, dim, ctx)
  of gbNone: discard

proc gpuAttentionBackwardBatched(q_all, k, v, d_att_out_all, d_q_all, d_k, d_v: ptr cfloat, act, numHeads, headSize, dim, ctx: cint) {.inline.} =
  case gpu_backend
  of gbCuda: cuda_attentionBackwardBatched(q_all, k, v, d_att_out_all, d_q_all, d_k, d_v, act, numHeads, headSize, dim, ctx)
  of gbOpenCL: ocl_attentionBackwardBatched(q_all, k, v, d_att_out_all, d_q_all, d_k, d_v, act, numHeads, headSize, dim, ctx)
  of gbNone: discard

proc gpuAdamStep(w, m, v, g: ptr cfloat, lr, b1, b2, b1t, b2t, scale: cfloat, size, is_sparse, cols, bound_r, bound_c: cint, boost, wd: cfloat) {.inline.} =
  case gpu_backend
  of gbCuda: cuda_adamStep(w, m, v, g, lr, b1, b2, b1t, b2t, scale, size, is_sparse, cols, bound_r, bound_c, boost, wd)
  of gbOpenCL: ocl_adamStep(w, m, v, g, lr, b1, b2, b1t, b2t, scale, size, is_sparse, cols, bound_r, bound_c, boost, wd)
  of gbNone: discard

proc useGpuMat(m: Matrix): bool {.inline.} =
  gpu_initialized and (m.rows.int * m.cols.int) >= gpu_min_elems

# ==============================================================================
# PHASE 7: GPU-DISPATCH FUER DEN INT8-PFAD (OpenCL)
# ------------------------------------------------------------------------------
# Bis hierhin rechnete cortex_train_step_i8() komplett auf der CPU - die in
# Phase 3 gebauten und bit-exakt verifizierten OpenCL-INT8-Kernel waren nie
# angebunden. Diese Schicht schliesst die Luecke nach demselben Muster wie die
# FP32-Wrapper oben (eine zentrale case-Verzweigung pro Operation).
#
# CUDA war hier bis 2026-10-13 bewusst NICHT eingehaengt (Kerne blind
# geschrieben, nie auf Hardware gelaufen); gbCuda fiel auf die CPU zurueck.
# Seit 2026-10-13 angeschlossen: die sieben im Training benutzten Kerne sind
# 1:1 nach den OpenCL-Kernen portiert (cortex_cuda.cu, Abschnitt
# "INT8-ANSCHLUSS") und auf einer RTX 3050 gepaart gegen die CPU geprueft.
# Die Tore unten fragen deshalb nur noch, ob UEBERHAUPT ein Geraet aktiv ist.
# NICHT angeschlossen bleibt der Adam-Schritt (cuda_adamStepI8,
# cuda_adamRowFloatI8): er laeuft wie bei OpenCL auf der CPU.
# ==============================================================================
# ==============================================================================
# FULL-INT8-PORT: GPU-Dispatch gegen stille Umgehung absichern
# ------------------------------------------------------------------------------
# Die in den Schritten 1-2 ergaenzten Ganzzahl-Kernel (backwardDInI8,
# gradAccumBatchedI8Int, gradAccumBatchedQI8) existieren NUR auf der CPU. In
# matMulTBatchedI8() und gradAccumBatchedI8() steht der GPU-Zweig VOR der
# Ganzzahl-Verzweigung - war der GPU-Dispatch aktiv, rechnete die GPU also
# still den alten Float-Pfad, und die gesetzten Schalter blieben WIRKUNGSLOS.
# Kein Absturz, keine Meldung, nur ein falsches Ergebnis der Messung.
#
# Bis es GPU-Pendants gibt, erzwingen die Schalter deshalb den CPU-Pfad. Das
# ist ehrlicher als eine stille Umgehung: lieber messbar langsamer als
# unbemerkt etwas anderes rechnen.
#
# Betroffen sind nur die BACKWARD-Kernel. Der Forward ist unkritisch: dort
# rechnet auch der Ganzzahl-Pfad auf dem float-Scratch, der GPU-Kernel bekommt
# also dieselben Eingaben wie bisher.
var i8_cpu_only_path* = false
# Sobald ein Ganzzahl-Kernel ein GPU-Pendant HAT, darf er die Sperre umgehen -
# sie schuetzt nur vor der stillen Umgehung dort, wo noch keines existiert.
var i8_gpu_backward* : cint = 0

proc cortex_set_i8_gpu_backward*(enabled: cint) {.ffi.} =
  ## Ganzzahl-Backward auf der GPU (OpenCL). Default AUS, bis verifiziert.
  i8_gpu_backward = enabled

proc cortex_get_i8_gpu_backward*(): cint {.ffi.} =
  i8_gpu_backward

proc cortex_gpu_weight_drift*(state: ptr CortexState): cfloat {.ffi.} =
  ## DIAGNOSE (Punkt 2): vergleicht die int8-Daten von w_out auf HOST und
  ## GERAET. 0 = deckungsgleich, sonst der Betrag der Differenz der
  ## Bytesummen. -1 = auf dem Geraet existiert kein Puffer zu diesem Zeiger.
  ##
  ## Die Bytesumme ist als Fingerabdruck grob, aber ausreichend: nach einem
  ## Adam-Schritt aendern sich Tausende Gewichte, ein Gleichstand waere hier
  ## kein Zufall sondern Beleg fuer einen ausgebliebenen Rueckschrieb.
  if state.isNil or state.w_out_q8.data.isNil: return -2.0
  let n = state.w_out_q8.rows.int * state.w_out_q8.cols.int
  let dev = (if gpu_backend == gbCuda: cuda_device_checksum(state.w_out_q8.data, n.csize_t)
             else: ocl_device_checksum(state.w_out_q8.data, n.csize_t))
  if dev == -1: return -1.0
  var host: int64 = 0
  for i in 0 ..< n: host += state.w_out_q8.data[i].int64
  result = abs(host - dev).cfloat

proc cortex_get_gpu_gradacc_calls*(): cint {.ffi.} =
  if gpu_backend == gbCuda: return cuda_get_gradacc_calls().cint
  ocl_gradacc_calls.cint

proc cortex_get_gpu_bw_calls*(): cint {.ffi.} =
  ## Wie oft der GPU-Backward-Kernel tatsaechlich abgesetzt wurde. Dient dem
  ## Nachweis, dass er laeuft - Bit-Gleichheit zur CPU allein zeigt das nicht.
  if gpu_backend == gbCuda: return cuda_get_bw_din_calls().cint
  ocl_bw_din_calls.cint
# Frueh deklariert, weil updateI8CpuOnly() (gleich unten) sie liest - die
# eigentliche Nutzung steht erst bei gradAccumBatchedI8().
var i8_int_gradacc*: cint = 0

proc useGpuQMat(qm: QMatrix): bool {.inline.} =
  gpu_initialized and gpu_backend != gbNone and
  (qm.rows.int * qm.cols.int) >= gpu_min_elems and
  not i8_cpu_only_path

proc useGpuGradAccI8(rows, cols: int): bool {.inline.} =
  ## Wie useGpuBackwardI8, aber fuer die Gradienten-Akkumulation. Sie bekommt
  ## kein QMatrix (der Gradient ist float), deshalb eine eigene Signatur.
  i8_gpu_backward != 0 and gpu_initialized and gpu_backend != gbNone and
  (rows * cols) >= gpu_min_elems

proc useGpuBackwardI8(qm: QMatrix): bool {.inline.} =
  ## Wie useGpuQMat, aber fuer den Ganzzahl-Backward - der hat jetzt ein
  ## GPU-Pendant und faellt deshalb NICHT unter die i8_cpu_only_path-Sperre.
  i8_gpu_backward != 0 and gpu_initialized and gpu_backend != gbNone and
  (qm.rows.int * qm.cols.int) >= gpu_min_elems

proc gpuMatVecMulI8(qm: QMatrix, qbuf: ptr Int8Array, actScale: cfloat, o_v: ptr FloatArray) {.inline.} =
  case gpu_backend
  of gbOpenCL:
    ocl_matVecMulI8(cast[ptr int8](qm.data), cast[ptr cfloat](qm.scale),
                     cast[ptr int8](qbuf), actScale, cast[ptr cfloat](o_v),
                     qm.rows, qm.cols)
  of gbCuda:
    cuda_matVecMulI8(cast[ptr int8](qm.data), cast[ptr cfloat](qm.scale),
                     cast[ptr int8](qbuf), actScale, cast[ptr cfloat](o_v),
                     qm.rows, qm.cols)
  else: discard

proc gpuMatVecMulTI8(qm: QMatrix, d_out, d_in: ptr FloatArray, accumulate: cint) {.inline.} =
  case gpu_backend
  of gbOpenCL:
    ocl_matVecMulTI8(cast[ptr int8](qm.data), cast[ptr cfloat](qm.scale),
                      cast[ptr cfloat](d_out), cast[ptr cfloat](d_in),
                      qm.rows, qm.cols, accumulate)
  of gbCuda:
    cuda_matVecMulTI8(cast[ptr int8](qm.data), cast[ptr cfloat](qm.scale),
                      cast[ptr cfloat](d_out), cast[ptr cfloat](d_in),
                      qm.rows, qm.cols, accumulate)
  else: discard

proc gpuPushQMatrix(qm: QMatrix) {.inline.} =
  ## Schreibt INT8-Daten UND Zeilen-Skalen zurueck auf das Geraet. Zwingend
  ## nach jeder HOST-seitigen Aenderung (cortex_rescale_weights), sonst
  ## rechnet die GPU mit veralteten Werten weiter.
  case gpu_backend
  of gbOpenCL:
    ocl_push_qmatrix(cast[ptr int8](qm.data), cast[ptr cfloat](qm.scale), qm.rows, qm.cols)
  of gbCuda:
    cuda_push_qmatrix(cast[ptr int8](qm.data), cast[ptr cfloat](qm.scale), qm.rows, qm.cols)
  else: discard

# INT8-ANSCHLUSS 2026-10-13: Verteiler fuer die drei Kerne, die bisher direkt
# als ocl_* gerufen wurden (die Tore liessen nur OpenCL durch).
proc gpuBackwardDInI8(w, dq: ptr int8, bscale, d_in: ptr cfloat,
                      rows, cols, blockSize, accumulate: cint) {.inline, raises: [], gcsafe.} =
  case gpu_backend
  of gbOpenCL: ocl_backwardDInI8(w, dq, bscale, d_in, rows, cols, blockSize, accumulate)
  of gbCuda: cuda_backwardDInI8(w, dq, bscale, d_in, rows, cols, blockSize, accumulate)
  else: discard

proc gpuBackwardDInI8Batched(w, dq: ptr int8, bscale, d_in: ptr cfloat,
                             rows, cols, batch, blockSize, accumulate: cint) {.inline, raises: [], gcsafe.} =
  case gpu_backend
  of gbOpenCL: ocl_backwardDInI8Batched(w, dq, bscale, d_in, rows, cols, batch, blockSize, accumulate)
  of gbCuda: cuda_backwardDInI8Batched(w, dq, bscale, d_in, rows, cols, batch, blockSize, accumulate)
  else: discard

proc gpuGradAccumI8(qi, qd: ptr int8, dsc, isc: ptr cfloat, gm: ptr cfloat,
                    rows, cols, batch, qiStride, gmOnDevice: cint) {.inline, raises: [], gcsafe.} =
  case gpu_backend
  of gbOpenCL: ocl_gradAccumI8(qi, qd, dsc, isc, gm, rows, cols, batch, qiStride, gmOnDevice)
  of gbCuda: cuda_gradAccumI8(qi, qd, dsc, isc, gm, rows, cols, batch, qiStride, gmOnDevice)
  else: discard

proc gradBytes(m: Matrix): csize_t {.inline.} =
  cast[csize_t](m.rows.uint64 * m.cols.uint64 * sizeof(cfloat).uint64)

# GRAD-DEV (2026-11-11, messbuch snai/multistack-graddev e619): Die 12 Schichtgradienten bleiben fuer den GPU-Adam
# auf der Karte. pullGradMerge holt den Kartenstand in einen festen Zwischenpuffer und fuehrt parallel zusammen
# (g = karte + host wie bisher). War der Host-Anteil ueberall +0, richtet die Karte ihren Puffer genauso her
# (x + 0 unter DAZ, dann Clip-Skalierung/Nullen wie scaleMat/zeroMat), und der GPU-Adam liest ihn statt den
# Host-Gradienten hochzuladen. Sonst, und bei Arm C/LoRA/Speicherarm, alter Weg.
# SNAI_GRAD_DEV: fehlt/1 = an (Vorgabe), 0 = aus, ROT = Rot-Probe (Clip-Skalierung auf der Karte fehlt).
var gdV = -1
proc gradDev(): int =
  if gdV < 0:
    let e = getEnv("SNAI_GRAD_DEV")
    gdV = (if e == "0": 0 elif e == "ROT": 2 else: 1)   # Vorgabe an (seit 2026-11-11, e619)
    try: stderr.writeLine("[GRAD-DEV] ", (if gdV == 1: "an" elif gdV == 2: "ROT-PROBE" else: "aus"))
    except IOError: discard
  gdV
var gdScratch: ptr FloatArray = nil
var gdScratchN = 0
var gdHostZero = initTable[pointer, bool]()
var gdReady = initTable[pointer, bool]()
var gdClipKind = 0
var gdClipScale: cfloat = 1.0
var gdPulls = 0
var gdPreps = 0
var gdAdams = 0
type GdArgs = object
  g, s: ptr FloatArray
  n: int
  nz: ptr UncheckedArray[int32]
proc gdMergeBlk(a: ptr GdArgs, k: int) {.exportc: "snai_gd_merge", cdecl, raises: [], gcsafe.} =
  ## g[i] = karte[i] + host[i] wie in pullGradMerge (dort: g = karte; g += tmp), merkt Host-Anteil != +0.
  let lo = k * 65536
  let hi = min(a.n, lo + 65536)
  var nz: int32 = 0
  for i in lo ..< hi:
    let h = a.g[i]
    if cast[uint32](h) != 0'u32: nz = 1
    a.g[i] = a.s[i] + h
  a.nz[k] = nz
proc gdMergeBlkC(a: ptr GdArgs, k: int) {.importc: "snai_gd_merge", cdecl.}

proc pullGradMerge(g: Matrix) =
  ## FIX 2026-10-13: Gegenstueck zu zeroGradI8 fuer geraeteresidente Gradienten.
  ## Vorher holte pullGradI8 den Geraetestand UEBER den Host-Stand. Rechnet der
  ## Gradientenkern aber auf dem Host (Ganzzahl-Akkumulation, i8_int_gradacc -
  ## im SNAI_INT8_FULL-Rezept die Vorgabe - ohne i8_gpu_backward), dann liegt
  ## das Ergebnis im Host-Puffer und auf dem Geraet stehen die Nullen vom
  ## Schrittanfang: der Gradient jeder Matrix >= gpu_min_elems war weg, ohne
  ## Meldung (gemessen 2026-10-13: GradNorm in Schritt 1 17,99 statt 21,81).
  ## Jetzt: Host-Anteil sichern, Host nullen, Geraetestand holen, Host-Anteil
  ## addieren. Gilt fuer jede Mischung; ist eine Seite null, bleibt die andere
  ## bitgleich erhalten. Host vorher nullen, damit ein fehlender Geraetepuffer
  ## (Holen = nichts) den Host-Anteil nicht verdoppelt.
  let n = g.rows.int * g.cols.int
  if g.data.isNil or n <= 0: return
  if gradDev() > 0 and gpu_backend == gbCuda and not pCudaPullTo.isNil:
    # GRAD-EARLY (2026-11-11, e621): liegt der Kartenstand schon vorgezogen im gepinnten Puffer, daraus.
    var src: ptr FloatArray = nil
    if not pCudaPullPtr.isNil:
      src = cast[ptr FloatArray](pCudaPullPtr(cast[pointer](g.data), (n * sizeof(cfloat)).csize_t))
    if src.isNil:
      if gdScratchN < n:
        if not gdScratch.isNil: deallocShared(gdScratch)
        gdScratch = cast[ptr FloatArray](allocShared(n * sizeof(cfloat)))
        gdScratchN = n
      if pCudaPullTo(cast[pointer](g.data), cast[pointer](gdScratch), (n * sizeof(cfloat)).csize_t) == 0:
        src = gdScratch
    if not src.isNil:
      let nb = (n + 65535) div 65536
      var nzs = newSeq[int32](nb)
      var a = GdArgs(g: g.data, s: src, n: n, nz: cast[ptr UncheckedArray[int32]](addr nzs[0]))
      let ap = addr a
      {.push checks: off.}
      for k in 0 || (nb - 1):
        gdMergeBlkC(ap, k)
      {.pop.}
      var anyNz = false
      for v in nzs:
        if v != 0: anyNz = true
      gdHostZero[cast[pointer](g.data)] = not anyNz
      inc gdPulls
      return
  let tmp = cast[ptr FloatArray](allocShared(n * sizeof(cfloat)))
  copyMem(tmp, g.data, n * sizeof(cfloat))
  zeroMem(g.data, n * sizeof(cfloat))
  gpuSyncToHost(cast[pointer](g.data))
  for i in 0 ..< n: g.data[i] += tmp[i]
  deallocShared(tmp)

proc allocMatrix(r, c: cint): Matrix =
  result.rows = r
  result.cols = c
  result.data = cast[ptr FloatArray](allocShared0(cast[int](r.uint64 * c.uint64 * sizeof(cfloat).uint64)))

proc freeMatrix(m: var Matrix) =
  if not m.data.isNil:
    if gpu_initialized: gpuReleaseBuffer(cast[pointer](m.data))
    deallocShared(m.data)
  m.data = nil

# --- MATH CORE ---
# Update 2026-08-08 ("RoPE-Basis an wachsende Kontextlaenge
# anpassen"): NTK-aware Basis-Skalierung statt fest verdrahteter 10000.
# ROPE_REF_CTX = Ctx der kleinsten Stufe der Evolutionsleiter (Drohne, 512) -
# dort ist ratio=1 und die Basis bleibt exakt beim klassischen Default (keine
# Aenderung fuer bereits trainierte Drohnen-Checkpoints). Fuer groessere Ctx
# (bis 8192 bei DemiGoddess/Goddess, das 16-Fache) skaliert die Basis
# proportional mit, damit die Rotationsfrequenzen nicht auf einen viel
# laengeren Kontext extrapolieren muessen, als sie kalibriert wurden -
# dieselbe Technik wie NTK-aware-Scaling/YaRN bei Long-Context-Modellen:
#   base_neu = base_alt * (ctx / ROPE_REF_CTX) ^ (head_size / (head_size - 2))
const ROPE_BASE = 10000.0
const ROPE_REF_CTX = 512.0

proc ropeBase(head_size, ctx: cint): float32 {.inline.} =
  if head_size <= 2: return ROPE_BASE.float32
  let ratio = ctx.float64 / ROPE_REF_CTX
  let exponent = head_size.float64 / (head_size.float64 - 2.0)
  (ROPE_BASE * pow(ratio, exponent)).float32

proc applyRoPE(vec: ptr FloatArray, dim, head_size, ctx, pos: cint, backward: bool = false) =
  let num_heads = dim div head_size
  let sign: cfloat = if backward: -1.0 else: 1.0
  let base = ropeBase(head_size, ctx)
  for h in 0 ..< num_heads:
    let h_off = h * head_size
    for i in countup(0, head_size - 1, 2):
      let freq = 1.0 / pow(base, i.float32 / head_size.float32)
      let theta = pos.float32 * freq
      let cos_t = cos(theta).cfloat
      let sin_t = sign * sin(theta).cfloat
      let v0 = vec[h_off + i]
      let v1 = vec[h_off + i + 1]
      vec[h_off + i] = v0 * cos_t - v1 * sin_t
      vec[h_off + i + 1] = v0 * sin_t + v1 * cos_t

proc matVecMul*(m: Matrix, i_v, o_v: ptr FloatArray) =
  let t0 = epochTime()
  if useGpuMat(m):
    gpuMatVecMul(cast[ptr cfloat](m.data), cast[ptr cfloat](i_v), cast[ptr cfloat](o_v), m.rows, m.cols)
    prof[0] += epochTime() - t0
  else:
    let rows = m.rows.int
    let cols = m.cols.int
    # V11.7: jede Zeile schreibt ausschliesslich o_v[r] -> race-frei parallel.
    {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
    # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
    for r in 0 || (rows - 1):
      var s: cfloat = 0.0
      let off = r * cols
      for c in 0 ..< cols:
        s += m.data[off + c] * i_v[c]
      o_v[r] = s
    {.pop.}
    prof[1] += epochTime() - t0

proc matVecMulBackwardAcc*(m, gm: Matrix, i_v, d_out, d_in: ptr FloatArray, accumulate: bool = false) =
  # V11.4: Backward-Offload. gm bleibt persistent im VRAM und akkumuliert ueber
  # alle Token - pro Token wandern nur die beiden kleinen Vektoren.
  let t0 = epochTime()
  if useGpuMat(m):
    if not d_in.isNil:
      gpuMatVecMulT(cast[ptr cfloat](m.data), cast[ptr cfloat](d_out),
                     cast[ptr cfloat](d_in), m.rows, m.cols,
                     (if accumulate: 1.cint else: 0.cint))
    gpuGradAccum(cast[ptr cfloat](gm.data), cast[ptr cfloat](d_out),
                  cast[ptr cfloat](i_v), m.rows, m.cols)
    prof[2] += epochTime() - t0
    return

  let rowsB = m.rows.int
  let colsB = m.cols.int

  if not d_in.isNil:
    # V11.8: zurueck auf die originale zeilenweise Reihenfolge. Die getauschte
    # Variante aus V11.7 war parallelisierbar, las m aber spaltenweise - bei
    # 16384x256 (w_out) zerlegt das die Cache-Lines. Bleibt vorerst seriell.
    if not accumulate:
      for c in 0 ..< colsB:
        d_in[c] = 0.0
    for r in 0 ..< rowsB:
      let do_v = d_out[r]
      let off = r * colsB
      for c in 0 ..< colsB:
        d_in[c] += m.data[off + c] * do_v
        
  # V11.7: Zeile r schreibt ausschliesslich gm-Zeile r -> race-frei parallel.
  {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
  # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
  for r in 0 || (rowsB - 1):
    let do_v = d_out[r]
    let off = r * colsB
    for c in 0 ..< colsB:
      gm.data[off + c] += do_v * i_v[c]
  {.pop.}
  prof[3] += epochTime() - t0

# ==============================================================================
# V11.9: GEBUENDELTE MATRIX-OPERATIONEN UEBER DIE POSITIONSACHSE
# Layout durchgehend row-major: IN[p*cols + c], OUT[p*rows + r].
# Bewusst hinter einem Flag: der alte Pfad bleibt Zeile fuer Zeile erhalten,
# damit sich beide im selben Binary gegeneinander messen lassen.
# ==============================================================================
var batched_wout: cint = 1   # V11.11: Standard AN (verifiziert schneller auf CPU und GPU)

proc cortex_set_batched_wout*(enabled: cint) {.ffi.} =
  batched_wout = enabled

proc cortex_get_batched_wout*(): cint {.ffi.} =
  batched_wout

# OUT[p*rows + r] = sum_c M[r*cols + c] * IN[p*cols + c]
# maxBatch: feste Allokationsgroesse von i_all/o_all (state.ctxSize beim
# Aufrufer) - siehe Kommentar in gpuMatMulBatched oben. Unabhaengig von batch,
# das pro Aufruf mit der tatsaechlichen Fenstergroesse variieren darf.
proc matMulBatchedD(m: Matrix, i_all, o_all: ptr FloatArray, batch: int, maxBatch: int) =
  let t0 = epochTime()
  if useGpuMat(m):
    gpuMatMulBatched(cast[ptr cfloat](m.data), cast[ptr cfloat](i_all),
                      cast[ptr cfloat](o_all), m.rows, m.cols, batch.cint, maxBatch.cint)
    prof[0] += epochTime() - t0
    return
  let rows = m.rows.int
  let cols = m.cols.int
  for p in 0 ..< batch:
    let ib = p * cols
    let ob = p * rows
    {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
    # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
    for r in 0 || (rows - 1):
      var s: cfloat = 0.0
      let off = r * cols
      for c in 0 ..< cols:
        s += m.data[off + c] * i_all[ib + c]
      o_all[ob + r] = s
    {.pop.}
  prof[1] += epochTime() - t0

# D_IN[p*cols + c] = sum_r M[r*cols + c] * D_OUT[p*rows + r]
# AUDIT: accumulate-Parameter ergaenzt (Standard false, bestehende w_out-Aufrufe
# unveraendert) - noetig, weil w_q/w_k/w_v alle in denselben d_norm-Gradienten
# summieren (exakt wie matVecMulBackwardAcc es pro Position schon immer tat).
proc matMulTBatchedD(m: Matrix, d_out_all, d_in_all: ptr FloatArray, batch: int, accumulate: bool = false) =
  let t0 = epochTime()
  if useGpuMat(m):
    gpuMatMulTBatched(cast[ptr cfloat](m.data), cast[ptr cfloat](d_out_all),
                       cast[ptr cfloat](d_in_all), m.rows, m.cols, batch.cint, (if accumulate: 1.cint else: 0.cint))
    prof[2] += epochTime() - t0
    return
  let rows = m.rows.int
  let cols = m.cols.int
  # V11.10: Positionen sind unabhaengig -> parallel ueber p. Innen exakt die
  # zeilenweise Ordnung des alten Pfades (m wird sequenziell gestreamt).
  {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
  # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
  for p in 0 || (batch - 1):
    let ob = p * rows
    let ib = p * cols
    if not accumulate:
      for c in 0 ..< cols:
        d_in_all[ib + c] = 0.0
    for r in 0 ..< rows:
      let do_v = d_out_all[ob + r]
      let off = r * cols
      for c in 0 ..< cols:
        d_in_all[ib + c] += m.data[off + c] * do_v
  {.pop.}
  prof[3] += epochTime() - t0

# gm[r*cols + c] += sum_p D_OUT[p*rows + r] * I_V[p*cols + c]
# Ein Thread pro Zeile r -> jeder schreibt nur seine eigene gm-Zeile, race-frei.
proc gradAccumBatchedD(m, gm: Matrix, d_out_all, i_all: ptr FloatArray, batch: int) =
  let t0 = epochTime()
  if useGpuMat(m):
    gpuGradAccumBatched(cast[ptr cfloat](gm.data), cast[ptr cfloat](d_out_all),
                         cast[ptr cfloat](i_all), m.rows, m.cols, batch.cint)
    prof[2] += epochTime() - t0
    return
  let rows = m.rows.int
  let cols = m.cols.int
  # V11.10: r aussen -> jeder Thread besitzt genau eine gm-Zeile (race-frei,
  # bleibt im L1). p in der Mitte, c innen streamend ueber i_all. Der einzige
  # strided Zugriff (d_out_all) passiert nur rows*batch mal statt
  # rows*cols*batch mal - Faktor 128 weniger bei cols=128.
  {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
  # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
  for r in 0 || (rows - 1):
    let off = r * cols
    for p in 0 ..< batch:
      let do_v = d_out_all[p * rows + r]
      let ib = p * cols
      for c in 0 ..< cols:
        gm.data[off + c] += do_v * i_all[ib + c]
  {.pop.}
  prof[3] += epochTime() - t0

# ==============================================================================
# AUDIT: GEBUENDELTE ATTENTION - analog zu V11.9 (batched_wout), aber fuer den
# eigentlich teuersten GPU-Pfad. Ursache der urspruenglichen 20x-Verlangsamung
# auf schwachen/treiber-limitierten GPUs: 'act' einzelne Dispatches pro Layer,
# jeder mit vollem Kernel-Launch + Transfer-Overhead inkl. eines BLOCKIERENDEN
# Reads. Erfordert layer-major statt position-major Reihenfolge im aufrufenden
# Trainings-Loop (siehe cortex_train_step, batchedAttn-Zweig): Q/K/V muessen
# fuer ALLE Positionen eines Layers feststehen, bevor Attention fuer eine davon
# berechnet wird.
# Standard AN: verifiziert per diag_batched.php-Methodik (Loss-Vergleich CPU/GPU,
# alt/neu, 1 und 8 Heads, 20 Schritte) - bitidentisch bis auf Float32-Rauschen,
# 11x Speedup auf dim=512 (49,6s -> 4,6s Step-Zeit), Attention-Backward-Anteil
# allein 43x (32,8s -> 0,76s). Analog zu batched_wout's Standard AN.
# ==============================================================================
var batched_attention: cint = 1

proc cortex_set_batched_attention*(enabled: cint) {.ffi.} =
  batched_attention = enabled

proc cortex_get_batched_attention*(): cint {.ffi.} =
  batched_attention

# Liest state.act_q[l] (fuer alle 'act' Positionen bereits gefuellt von Sub-Pass 1
# im Aufrufer), schreibt state.act_att_out[l]. CPU-Zweig ist Zeile-fuer-Zeile
# identisch zur alten Inline-Mathematik im Positions-Loop.
proc attentionForwardBatchedD(state: ptr CortexState, l, act: cint) =
  let t0 = epochTime()
  let dim = state.hiddenDim
  let numHeads = state.numHeads
  let headSize = state.headSize
  let q_all = cast[ptr FloatArray](state.act_q[l].data)
  let out_all = state.act_att_out[l]

  if gpu_initialized and batched_attention != 0:
    gpuAttentionForwardBatched(cast[ptr cfloat](q_all), cast[ptr cfloat](state.k_cache[l].data),
                                 cast[ptr cfloat](state.v_cache[l].data), cast[ptr cfloat](out_all),
                                 act, numHeads, headSize, dim, state.ctxSize)
    prof[0] += epochTime() - t0
    return

  for p in 0 ..< act:
    let off_dim = p * dim
    let q_p = cast[ptr FloatArray](addr q_all[off_dim])
    let out_p = cast[ptr FloatArray](addr out_all[off_dim])
    for d in 0 ..< dim: out_p[d] = 0.0
    for h in 0 ..< numHeads:
      let h_off = h * headSize
      var max_s: cfloat = NegInf.cfloat
      for t in 0 .. p:
        let tk = cast[ptr FloatArray](addr state.k_cache[l].data[t * dim])
        var sc: cfloat = 0.0
        for d in 0 ..< headSize: sc += q_p[h_off + d] * tk[h_off + d]
        sc /= sqrt(headSize.float32)
        state.scores_buf[t] = sc
        if sc > max_s: max_s = sc
      var sum_e: cfloat = 0.0
      for t in 0 .. p:
        state.scores_buf[t] = exp(state.scores_buf[t] - max_s)
        sum_e += state.scores_buf[t]
      for t in 0 .. p:
        let w = state.scores_buf[t] / sum_e
        let tv = cast[ptr FloatArray](addr state.v_cache[l].data[t * dim])
        for d in 0 ..< headSize: out_p[h_off + d] += tv[h_off + d] * w
  prof[1] += epochTime() - t0

# Liest state.act_q[l], state.d_att_out_all (fuer alle Positionen von Sub-Pass 1
# im Aufrufer gefuellt). Schreibt state.d_q_all sowie state.d_k_cache[l]/
# state.d_v_cache[l] (bereits am Funktionsanfang von cortex_train_step genullt).
# CPU-Zweig laeuft bewusst weiterhin als Countdown ueber die Positionen - das
# ist keine GPU-Notloesung, sondern noetig, damit die += Akkumulation in
# d_k_cache/d_v_cache exakt wie im alten Pfad funktioniert (siehe Kernel-
# Kommentar zu attentionBackwardBatchedKey fuer die GPU-seitige Race-Analyse).
proc attentionBackwardBatchedD(state: ptr CortexState, l, act: cint) =
  let t0 = epochTime()
  let dim = state.hiddenDim
  let numHeads = state.numHeads
  let headSize = state.headSize
  let q_all = cast[ptr FloatArray](state.act_q[l].data)
  let datt_all = state.d_att_out_all
  let dq_all = state.d_q_all

  if gpu_initialized and batched_attention != 0:
    gpuAttentionBackwardBatched(cast[ptr cfloat](q_all), cast[ptr cfloat](state.k_cache[l].data),
                                  cast[ptr cfloat](state.v_cache[l].data), cast[ptr cfloat](datt_all),
                                  cast[ptr cfloat](dq_all), cast[ptr cfloat](state.d_k_cache[l].data),
                                  cast[ptr cfloat](state.d_v_cache[l].data), act, numHeads, headSize,
                                  dim, state.ctxSize)
    prof[2] += epochTime() - t0
    return

  let scale = 1.0 / sqrt(headSize.float32)
  for p in countdown(act - 1, 0):
    let off_dim = p * dim
    let q_p = cast[ptr FloatArray](addr q_all[off_dim])
    let d_att_out_p = cast[ptr FloatArray](addr datt_all[off_dim])
    let d_q_p = cast[ptr FloatArray](addr dq_all[off_dim])
    for d in 0 ..< dim: d_q_p[d] = 0.0
    for h in 0 ..< numHeads:
      let h_off = h * headSize
      var max_s: cfloat = NegInf.cfloat
      for t in 0 .. p:
        let k_t = cast[ptr FloatArray](addr state.k_cache[l].data[t * dim])
        var sc: cfloat = 0.0
        for d in 0 ..< headSize: sc += q_p[h_off + d] * k_t[h_off + d]
        sc *= scale
        state.scores_buf[t] = sc
        if sc > max_s: max_s = sc
      var sum_e: cfloat = 0.0
      for t in 0 .. p:
        state.scores_buf[t] = exp(state.scores_buf[t] - max_s)
        sum_e += state.scores_buf[t]
      var sum_w_dw: cfloat = 0.0
      for t in 0 .. p:
        let w = state.scores_buf[t] / sum_e
        state.scores_buf[t] = w
        let v_t = cast[ptr FloatArray](addr state.v_cache[l].data[t * dim])
        var dw: cfloat = 0.0
        for d in 0 ..< headSize: dw += d_att_out_p[h_off + d] * v_t[h_off + d]
        let d_v_t = cast[ptr FloatArray](addr state.d_v_cache[l].data[t * dim])
        for d in 0 ..< headSize: d_v_t[h_off + d] += d_att_out_p[h_off + d] * w
        state.d_w_buf[t] = dw
        sum_w_dw += w * dw
      for t in 0 .. p:
        let w = state.scores_buf[t]
        let ds = w * (state.d_w_buf[t] - sum_w_dw) * scale
        let k_t = cast[ptr FloatArray](addr state.k_cache[l].data[t * dim])
        let d_k_t = cast[ptr FloatArray](addr state.d_k_cache[l].data[t * dim])
        for d in 0 ..< headSize:
          d_q_p[h_off + d] += ds * k_t[h_off + d]
          d_k_t[h_off + d] += ds * q_p[h_off + d]
  prof[3] += epochTime() - t0

proc applyRMSNorm(i_v, o_v: ptr FloatArray, dim: cint, w: ptr FloatArray) =
  var ss: cfloat = 0.0
  for d in 0 ..< dim: 
    ss += i_v[d] * i_v[d]
  let inv = 1.0 / sqrt((ss / dim.float32) + 1e-5)
  for d in 0 ..< dim: 
    o_v[d] = i_v[d] * inv * (if w.isNil: 1.0.cfloat else: w[d])

proc applyRMSNormBackwardAcc*(d_out, a_i: ptr FloatArray, dim: cint, w, gw: ptr FloatArray) =
  var ss: cfloat = 0.0
  for d in 0 ..< dim: 
    ss += a_i[d] * a_i[d]
  let inv = 1.0 / sqrt((ss / dim.float32) + 1e-5)
  
  var sum_dy_nx: cfloat = 0.0
  for d in 0 ..< dim: 
    let w_val = if w.isNil: 1.0.cfloat else: w[d]
    sum_dy_nx += d_out[d] * w_val * (a_i[d] * inv)
  let mean_dy_nx = sum_dy_nx / dim.float32

  for d in 0 ..< dim:
    let w_val = if w.isNil: 1.0.cfloat else: w[d]
    let nx = a_i[d] * inv
    if not gw.isNil: 
      gw[d] += d_out[d] * nx
    d_out[d] = (d_out[d] * w_val - nx * mean_dy_nx) * inv

# --- SPARSE ADAM CORE ---
proc adamStep(w, m, v, g: ptr cfloat, lr, b1, b2, b1t, b2t, scale: cfloat, is_sparse: bool = false, boost: cfloat = 1.0, wd: cfloat = 0.0) {.inline.} =
  if scale == 0.0: return
  var grad = g[] / scale
  if is_sparse and abs(grad) < 1e-8: return
  if grad.isNaN or grad > 9999.0 or grad < -9999.0:
    g[] = 0.0
    return

  m[] = b1 * m[] + (1.0 - b1) * grad
  v[] = b2 * v[] + (1.0 - b2) * grad * grad
  let m_hat = m[] / b1t
  let v_hat = v[] / b2t
  w[] -= (lr * boost) * m_hat / (sqrt(v_hat) + 1e-8)
  if wd > 0.0: w[] -= lr * wd * w[]
  g[] = 0.0

proc applyGlobalAdamUpdate(state: ptr CortexState, lr: cfloat, scale: cfloat) =
  state.adam_t += 1
  let b1: cfloat = 0.9
  let b2: cfloat = 0.999
  let b1t = 1.0 - pow(b1, state.adam_t.float32)
  let b2t = 1.0 - pow(b2, state.adam_t.float32)

  # Boundary-Werte fuer den LR-Boost: bei inaktivem Growth-Tracking (kein
  # cortex_set_growth_boundary()-Aufruf, growth_old_dim < 0) werden die
  # Grenzen auf die AKTUELLEN Dimensionen gesetzt - row/col koennen die nie
  # erreichen, der Boost triggert also nie. Identisch zum alten Verhalten.
  let boostActive = growth_old_dim >= 0
  let boundDimGlobal = if boostActive: growth_old_dim else: state.hiddenDim

  if gpu_initialized:
    template oclUpM(w, m, v, g, boundR, boundC) = gpuAdamStep(cast[ptr cfloat](w.data), cast[ptr cfloat](m.data), cast[ptr cfloat](v.data), cast[ptr cfloat](g.data), lr, b1, b2, b1t, b2t, scale, w.rows * w.cols, 0.cint, w.cols, boundR, boundC, growth_boost, global_weight_decay)
    template oclUpEmb(w, m, v, g, boundC) = gpuAdamStep(cast[ptr cfloat](w.data), cast[ptr cfloat](m.data), cast[ptr cfloat](v.data), cast[ptr cfloat](g.data), lr, b1, b2, b1t, b2t, scale, w.rows * w.cols, 1.cint, w.cols, w.rows.cint, boundC, growth_boost, global_weight_decay)
    template oclUpA(w, m, v, g, size, boundC) = gpuAdamStep(cast[ptr cfloat](w), cast[ptr cfloat](m), cast[ptr cfloat](v), cast[ptr cfloat](g), lr, b1, b2, b1t, b2t, scale, size, 0.cint, size, 1.cint, boundC, growth_boost, 0.0.cfloat)

    oclUpEmb(state.embeddings, state.m_embeddings, state.v_embeddings, state.g_embeddings, boundDimGlobal)
    oclUpM(state.w_out, state.m_w_out, state.v_w_out, state.g_w_out, state.w_out.rows.cint, boundDimGlobal)
    oclUpA(state.rms_final_weight, state.m_rms_final_weight, state.v_rms_final_weight, state.g_rms_final_weight, state.hiddenDim, boundDimGlobal)

    for l in 0 ..< state.numLayers:
      let isNewLayer = boostActive and (l.cint >= growth_old_layers)
      let boundDim = if not boostActive: state.hiddenDim elif isNewLayer: 0.cint else: growth_old_dim
      let boundFfn = if not boostActive: state.ffnDim elif isNewLayer: 0.cint else: growth_old_ffn

      oclUpA(state.rms_att_weights[l], state.m_rms_att_weights[l], state.v_rms_att_weights[l], state.g_rms_att_weights[l], state.hiddenDim, boundDim)
      oclUpA(state.rms_ffn_weights[l], state.m_rms_ffn_weights[l], state.v_rms_ffn_weights[l], state.g_rms_ffn_weights[l], state.hiddenDim, boundDim)
      oclUpM(state.w_q[l], state.m_w_q[l], state.v_w_q[l], state.g_w_q[l], boundDim, boundDim)
      oclUpM(state.w_k[l], state.m_w_k[l], state.v_w_k[l], state.g_w_k[l], boundDim, boundDim)
      oclUpM(state.w_v[l], state.m_w_v[l], state.v_w_v[l], state.g_w_v[l], boundDim, boundDim)
      oclUpM(state.w_o[l], state.m_w_o[l], state.v_w_o[l], state.g_w_o[l], boundDim, boundDim)
      oclUpM(state.w_up[l], state.m_w_up[l], state.v_w_up[l], state.g_w_up[l], boundFfn, boundDim)
      oclUpM(state.w_down[l], state.m_w_down[l], state.v_w_down[l], state.g_w_down[l], boundDim, boundFfn)
  else:
    template upM(w, m, v, g, boundR, boundC) =
      for i in 0 ..< (w.rows * w.cols): adamStep(addr w.data[i], addr m.data[i], addr v.data[i], addr g.data[i], lr, b1, b2, b1t, b2t, scale, false, elemBoost(i.cint, w.cols, boundR, boundC), global_weight_decay)
    template upEmb(w, m, v, g, boundC) =
      for i in 0 ..< (w.rows * w.cols): adamStep(addr w.data[i], addr m.data[i], addr v.data[i], addr g.data[i], lr, b1, b2, b1t, b2t, scale, true, elemBoost(i.cint, w.cols, w.rows.cint, boundC), global_weight_decay)
    template upA(w, m, v, g, size, boundC) =
      for i in 0 ..< size: adamStep(addr w[i], addr m[i], addr v[i], addr g[i], lr, b1, b2, b1t, b2t, scale, false, elemBoost(i.cint, size, 1.cint, boundC))

    upEmb(state.embeddings, state.m_embeddings, state.v_embeddings, state.g_embeddings, boundDimGlobal)
    upM(state.w_out, state.m_w_out, state.v_w_out, state.g_w_out, state.w_out.rows.cint, boundDimGlobal)
    upA(state.rms_final_weight, state.m_rms_final_weight, state.v_rms_final_weight, state.g_rms_final_weight, state.hiddenDim, boundDimGlobal)

    for l in 0 ..< state.numLayers:
      let isNewLayer = boostActive and (l.cint >= growth_old_layers)
      let boundDim = if not boostActive: state.hiddenDim elif isNewLayer: 0.cint else: growth_old_dim
      let boundFfn = if not boostActive: state.ffnDim elif isNewLayer: 0.cint else: growth_old_ffn

      upA(state.rms_att_weights[l], state.m_rms_att_weights[l], state.v_rms_att_weights[l], state.g_rms_att_weights[l], state.hiddenDim, boundDim)
      upA(state.rms_ffn_weights[l], state.m_rms_ffn_weights[l], state.v_rms_ffn_weights[l], state.g_rms_ffn_weights[l], state.hiddenDim, boundDim)
      upM(state.w_q[l], state.m_w_q[l], state.v_w_q[l], state.g_w_q[l], boundDim, boundDim)
      upM(state.w_k[l], state.m_w_k[l], state.v_w_k[l], state.g_w_k[l], boundDim, boundDim)
      upM(state.w_v[l], state.m_w_v[l], state.v_w_v[l], state.g_w_v[l], boundDim, boundDim)
      upM(state.w_o[l], state.m_w_o[l], state.v_w_o[l], state.g_w_o[l], boundDim, boundDim)
      upM(state.w_up[l], state.m_w_up[l], state.v_w_up[l], state.g_w_up[l], boundFfn, boundDim)
      upM(state.w_down[l], state.m_w_down[l], state.v_w_down[l], state.g_w_down[l], boundDim, boundFfn)

proc calcL2Sq(m: Matrix): cfloat {.inline.} =
  var sum: cfloat = 0.0
  let total = m.rows * m.cols
  for i in 0 ..< total: sum += m.data[i] * m.data[i]
  return sum

proc calcL2Sq(arr: ptr FloatArray, size: cint): cfloat {.inline.} =
  var sum: cfloat = 0.0
  for i in 0 ..< size: sum += arr[i] * arr[i]
  return sum

proc scaleMat(m: Matrix, scale: cfloat) {.inline.} =
  let total = m.rows * m.cols
  for i in 0 ..< total: m.data[i] *= scale

proc scaleArr(arr: ptr FloatArray, size: cint, scale: cfloat) {.inline.} =
  for i in 0 ..< size: arr[i] *= scale

proc zeroMat(m: Matrix) {.inline.} =
  let total = m.rows * m.cols
  for i in 0 ..< total: m.data[i] = 0.0

proc zeroArr(arr: ptr FloatArray, size: cint) {.inline.} =
  for i in 0 ..< size: arr[i] = 0.0

# ==============================================================================
# LoRA - kleine Bausteine (die Rechenkerne stehen weiter unten bei
# applyGlobalAdamUpdateI8, sie brauchen die Matmul-Infrastruktur).
# ==============================================================================
const LORA_SLOTS = 6      # w_q w_k w_v w_o w_up w_down
const LORA_ALL: cint = 63 # alle sechs Slots

proc loraOn(s: ptr CortexState): bool {.inline.} =
  ## Prueft die WIRKUNG, nicht den Schalter: Rang gesetzt UND Speicher da.
  ## Ein gesetztes loraRank ohne Adapter waere still wirkungslos - genau die
  ## Sorte Fehlmeldung, gegen die cortex_i8_error_feedback_active() eingefuehrt
  ## wurde (2026-08-25).
  (not s.isNil) and s.loraRank > 0 and (not s.lora_a.isNil) and (not s.lora_b.isNil)

proc loraSlotOn(s: ptr CortexState, slot: int): bool {.inline.} =
  loraOn(s) and ((s.loraMask.int and (1 shl slot)) != 0)

proc loraIdx(s: ptr CortexState, l, slot: int): int {.inline.} =
  l * LORA_SLOTS + slot

proc loraScale(s: ptr CortexState): cfloat {.inline.} =
  s.loraAlpha / s.loraRank.cfloat

template loraForEach(s: ptr CortexState, body: untyped) =
  ## Laeuft ueber alle AKTIVEN Adapter. `ga`/`gb` sind die Gradienten-,
  ## `wa`/`wb` die Gewichtsmatrizen des jeweiligen Adapters.
  if loraOn(s):
    for l {.inject.} in 0 ..< s.numLayers.int:
      for slot {.inject.} in 0 ..< LORA_SLOTS:
        if (s.loraMask.int and (1 shl slot)) != 0:
          let i {.inject.} = loraIdx(s, l, slot)
          body

proc lastLayerOnly(s: ptr CortexState): bool {.inline.} =
  ## Arm C aktiv? Siehe Feldkommentar bei trainLastLayers.
  (not s.isNil) and s.trainLastLayers > 0

proc layerTrainable(s: ptr CortexState, l: int): bool {.inline.} =
  ## Bekommt Schicht l einen Adam-Schritt? Ohne Arm C immer ja.
  s.trainLastLayers <= 0 or l >= (s.numLayers.int - s.trainLastLayers.int)

proc clipGlobalGradientNorm(s: ptr CortexState, max_norm: cfloat) =
  # SPEICHERARM: bei freigegebenem Basis-Optimierer gibt es keine
  # Basis-Gradienten mehr - weder zu zaehlen noch zu skalieren. Die Adapter
  # sind dann die einzigen Gradienten, und genau sie sollen die Norm bestimmen.
  let baseGone = s.baseOptFreed != 0
  # ARM C: die gezaehlte Menge muss der spaeter aktualisierten entsprechen -
  # siehe Feldkommentar bei trainLastLayers.
  let armC = lastLayerOnly(s)
  var total_sq: cfloat = 0.0
  # Gruppen-Quadratsummen fuer cortex_get_last_grad_share(). total_sq wird in
  # unveraenderter Reihenfolge aus denselben Werten summiert - der Clip bleibt
  # bitgleich.
  var grp: array[GRAD_GROUPS, cfloat]
  for l in 0 ..< GRAD_QK_LAYERS_MAX: last_grad_qk_layer_sq[l] = 0.0
  template cnt(g: int, v: cfloat) =
    let x = v
    total_sq += x
    grp[g] += x
  if not baseGone and not armC:
    cnt(0, calcL2Sq(s.g_embeddings))
    cnt(0, calcL2Sq(s.g_w_out))
  # FIX 2026-08-30: zusaetzlich an baseGone gehaengt. Bei eingefrorener Basis
  # bekommen die RMSNorm-Gains keinen Adam-Schritt (applyGlobalAdamUpdateI8:
  # "upLora(); return" - Eingefroren heisst dort woertlich alles ausser den
  # Adaptern). Sie zaehlten aber weiter in die globale Norm, und das war kein
  # Schoenheitsfehler: gemessen (diagnose/probe_clipnorm_parts.php) machten sie
  # 44-75 % der Norm aus, je kleiner der Rang desto mehr. Der geloggte GradNorm
  # war dadurch ueber Rang 4/16/32 praktisch konstant (0,3334/0,3191/0,3239),
  # waehrend die echte Adapternorm um das 2,3-fache auseinanderlag
  # (0,0804/0,1396/0,1833) - die Zahl war rangblind. Die Regel von Zeile 192
  # gilt unveraendert: gezaehlte Menge == aktualisierte Menge.
  if not armC and not baseGone:
    cnt(4, calcL2Sq(s.g_rms_final_weight, s.hiddenDim))
  # LoRA-Adapter zaehlen mit. Sie NICHT mitzuzaehlen waere kein Detail: bei
  # eingefrorener Basis sind die Adapter die einzigen Gradienten, die noch
  # etwas bewegen - eine Norm ohne sie waere praktisch immer winzig und das
  # Clipping damit wirkungslos.
  loraForEach(s):
    cnt(4, calcL2Sq(s.g_lora_a[i]))
    cnt(4, calcL2Sq(s.g_lora_b[i]))
  for l in 0 ..< s.numLayers:
    if not baseGone and layerTrainable(s, l):
      let gq = calcL2Sq(s.g_w_q[l])
      let gk = calcL2Sq(s.g_w_k[l])
      cnt(1, gq)
      cnt(1, gk)
      if l < GRAD_QK_LAYERS_MAX: last_grad_qk_layer_sq[l] = gq + gk
      cnt(2, calcL2Sq(s.g_w_v[l]))
      cnt(2, calcL2Sq(s.g_w_o[l]))
      cnt(3, calcL2Sq(s.g_w_up[l]))
      cnt(3, calcL2Sq(s.g_w_down[l]))
    if not armC and not baseGone:   # FIX 2026-08-30, siehe oben
      cnt(4, calcL2Sq(s.g_rms_att_weights[l], s.hiddenDim))
      cnt(4, calcL2Sq(s.g_rms_ffn_weights[l], s.hiddenDim))

  gdClipKind = 0
  gdClipScale = 1.0
  let global_norm = sqrt(total_sq)
  last_grad_norm = global_norm
  last_grad_group_sq = grp
  last_grad_total_sq = total_sq
  last_grad_layers = s.numLayers

  if global_norm.isNaN or global_norm > max_norm:
    if global_norm.isNaN or global_norm == 0.0:
      gdClipKind = 2
      if not baseGone and not armC:
        zeroMat(s.g_embeddings)
        zeroMat(s.g_w_out)
      if not armC and not baseGone:   # FIX 2026-08-30, siehe oben
        zeroArr(s.g_rms_final_weight, s.hiddenDim)
      loraForEach(s):
        zeroMat(s.g_lora_a[i])
        zeroMat(s.g_lora_b[i])
      for l in 0 ..< s.numLayers:
        if not baseGone and layerTrainable(s, l):
          zeroMat(s.g_w_q[l])
          zeroMat(s.g_w_k[l])
          zeroMat(s.g_w_v[l])
          zeroMat(s.g_w_o[l])
          zeroMat(s.g_w_up[l])
          zeroMat(s.g_w_down[l])
        if not armC and not baseGone:   # FIX 2026-08-30, siehe oben
          zeroArr(s.g_rms_att_weights[l], s.hiddenDim)
          zeroArr(s.g_rms_ffn_weights[l], s.hiddenDim)
    else:
      let scale = max_norm / global_norm
      gdClipKind = 1
      gdClipScale = scale
      if not baseGone and not armC:
        scaleMat(s.g_embeddings, scale)
        scaleMat(s.g_w_out, scale)
      if not armC and not baseGone:   # FIX 2026-08-30, siehe oben
        scaleArr(s.g_rms_final_weight, s.hiddenDim, scale)
      loraForEach(s):
        scaleMat(s.g_lora_a[i], scale)
        scaleMat(s.g_lora_b[i], scale)
      for l in 0 ..< s.numLayers:
        if not baseGone and layerTrainable(s, l):
          scaleMat(s.g_w_q[l], scale)
          scaleMat(s.g_w_k[l], scale)
          scaleMat(s.g_w_v[l], scale)
          scaleMat(s.g_w_o[l], scale)
          scaleMat(s.g_w_up[l], scale)
          scaleMat(s.g_w_down[l], scale)
        if not armC and not baseGone:   # FIX 2026-08-30, siehe oben
          scaleArr(s.g_rms_att_weights[l], s.hiddenDim, scale)
          scaleArr(s.g_rms_ffn_weights[l], s.hiddenDim, scale)

# ==============================================================================
# PHASE 2 DES INT8-UMBAUS
# Natives INT8-Training, CPU-Pfad. Additiver, eigenstaendiger Code neben dem
# bestehenden FP32-Training (Design-Entscheidung #8 - kein Big-Bang-Ersatz):
# kein bestehender FP32-Pfad (cortex_forward/cortex_train_step/
# applyGlobalAdamUpdate/matVecMul*) wird durch das Folgende veraendert.
#
# Hybrid-Ansatz (Design-Entscheidung #4): NUR das GEMM selbst ist echtes
# int8xint8->int32, RMSNorm/RoPE/Softmax/SiLU sind unveraendert die
# bestehenden FP32-Prozeduren (applyRMSNorm/applyRoPE/... oben) - ihr Input
# ist die sofort dequantisierte GEMM-Ausgabe. Adam-Momente (m/v) bleiben immer
# FP32 (Design-Entscheidung #2) - dafuer werden bewusst dieselben
# m_/v_/g_-Felder wie im FP32-Pfad wiederverwendet (identische Form,
# unabhaengig vom Gewichts-dtype), keine eigenen INT8-Adam-Felder noetig.
#
# Bewusst nur der einfache Nicht-gebuendelte, Nicht-GPU-Pfad (aequivalent zu
# batched_wout=0/batched_attention=0/GPU aus im FP32-Pfad, siehe Plan Phase 2
# "Disziplin") - die gebuendelten Perf-Varianten sind eine spaetere
# Optimierung, kein Korrektheitsrisiko fuer das Go/No-Go-Gate.
# ==============================================================================

# AUDIT 2026-08-19 - BEWUSST NICHT OPTIMIERT: Naheliegend waere hier, das
# libm-`round()` durch ein manuelles `(x + 0.5).int` zu ersetzen und die
# Division durch eine Multiplikation mit dem vorab berechneten Reziprok.
# Beides wurde umgesetzt und GEMESSEN: 53,34 ms -> 53,45 ms, also reine
# Messstreuung. Der Grund ist eine simple Aufwandsrechnung - pro Layer und
# Position stehen ~1.152 quantisierte Elemente gegen ~196.608 GEMM-
# Multiplikationen, die Quantisierung ist also ~0,6% der Arbeit. Die
# Aenderung wurde deshalb zurueckgenommen: sie brachte nichts, machte den
# Code aber komplexer und wich um 1 ULP von der Referenzimplementierung in
# diagnose/verify_int8_reference.php ab (Multiplikation mit dem Reziprok ist
# nicht bitgleich zur Division - das kann in seltenen Grenzfaellen eine
# Rundungsentscheidung kippen). Der Flaschenhals ist das GEMM selbst.
# NaN/Inf wird beim Runden zu -128 und taucht im Loss nie auf, die Pruefung im
# Worker bliebe blind (messbuch snai/nan-quant). Deshalb wird die Skala NaN: das
# Ergebnis des GEMM wird nichtendlich und der Lauf bricht sichtbar ab. Die Summe
# der Betraege ist nichtendlich, wenn es ein Element ist, und kostet nur einen
# Sprung je Vektor statt einen je Element.
const quantNaN: cfloat = NaN.cfloat
template quantSummeKaputt(summe: cfloat): bool = (summe - summe) != 0.0'f32

proc quantizeActivation(src: ptr FloatArray, dst: ptr Int8Array, n: cint): cfloat =
  ## Dynamische Abs-Max-Quantisierung eines Aktivierungsvektors, frisch pro
  ## GEMM-Aufruf (kein persistenter Skalen-Zustand fuer Aktivierungen noetig).
  var maxAbs: cfloat = 0.0
  var summe: cfloat = 0.0
  for i in 0 ..< n:
    let a = abs(src[i])
    summe += a
    if a > maxAbs: maxAbs = a
  let scale = if maxAbs > 0.0: maxAbs / 127.0 else: 1.0
  for i in 0 ..< n:
    var q = round(src[i] / scale).int
    if q > 127: q = 127
    elif q < -128: q = -128
    dst[i] = q.int8
  if quantSummeKaputt(summe): return quantNaN
  return scale

proc quantizeVectorToQ8Row(src: ptr FloatArray, qm: QMatrix, row: cint, n: cint) =
  ## Wie quantizeActivation(), schreibt aber direkt in Zeile `row` einer
  ## bestehenden QMatrix (KV-Cache-Design: k_cache_q8/v_cache_q8, "Zeile" =
  ## Position) statt in einen dedizierten Scratch-Puffer.
  let off = row.int * n.int
  var maxAbs: cfloat = 0.0
  var summe: cfloat = 0.0
  for i in 0 ..< n.int:
    let a = abs(src[i])
    summe += a
    if a > maxAbs: maxAbs = a
  let scale = if maxAbs > 0.0: maxAbs / 127.0 else: 1.0
  qm.scale[row] = (if quantSummeKaputt(summe): quantNaN else: scale)
  for i in 0 ..< n.int:
    var q = round(src[i] / scale).int
    if q > 127: q = 127
    elif q < -128: q = -128
    qm.data[off + i] = q.int8

# AUDIT 2026-08-23 - SIMD-VEKTORISIERUNG DES INT8-GEMM (Festlegung zur
# Zielhardware: -march=native/AVX2 war frueher wegen der
# AMD-Jaguar-Zielhardware (kein AVX2) verworfen worden, dieser Zwang ist
# hinfaellig, die Vektorisierung war seither der naheliegendste verbleibende
# Performance-Hebel).
#
# Portabilitaet: der Code wird weiterhin zwischen mehreren Maschinen gesynct,
# darunter potenziell die alte Jaguar-Hardware. Statt eines globalen
# -mavx2-Compile-Flags (haette den GESAMTEN Build auf jeder Maschine ohne
# AVX2 mit SIGILL abstuerzen lassen) nutzt dieser Kernel GCCs
# __attribute__((target("avx2"))) NUR fuer diese eine Funktion (der Rest der
# Datei bleibt auf der Baseline-Zielarchitektur) plus eine Laufzeit-Erkennung
# via __builtin_cpu_supports() - dieselbe .so laeuft also auf Nicht-AVX2-
# Hardware unveraendert im Skalarpfad weiter.
#
# Numerik: int8 x int8 werden zuerst VORZEICHENERWEITERT auf int16
# (_mm256_cvtepi8_epi16), dann paarweise mit _mm256_madd_epi16 zu int32
# aufsummiert - KEIN VPMADDUBSW/"unsigned+Bias"-Trick, obwohl der doppelten
# Durchsatz haette: die Gewichts-Quantisierung clampt auf [-128, 127] (siehe
# quantizeActivation oben), und -128 laesst sich nicht verlustfrei in ein
# vorzeichenloses Byte falten (abs(-128) ueberlaeuft int8 wieder zu -128) -
# dieser Randfall haette entweder ein zusaetzliches Clamping der Gewichte auf
# [-127,127] erzwungen (Aenderung der Quantisierungssemantik) oder eine
# Sonderbehandlung im Kernel gebraucht. Die hier gewaehlte int16-Variante
# braucht beides nicht.
#
# WICHTIG, warum das trotzdem BIT-EXAKT zum Skalarkern ist: die Summanden
# sind allesamt int32 (ganzzahlig, keine Rundung), und Integer-Addition ist
# assoziativ/kommutativ - anders als bei Floats aendert eine andere
# Aufsummierungsreihenfolge (SIMD-Paare zuerst, dann horizontal, dann
# Skalar-Rest) das Ergebnis nicht, solange kein Zwischenueberlauf entsteht.
# Genau das stellt der bestehende checkI8AccumRange()-Guard bereits sicher
# (Phase-Audit 2026-08-19). Verifiziert in diagnose/verify_int8_simd.php.
{.emit: """
#include <stdint.h>
#ifdef __x86_64__
#include <immintrin.h>

// Bewusst NICHT static: diagnose/verify_int8_simd.php ruft diese Funktion
// per FFI direkt und isoliert auf (Bit-Exaktheits-Test ohne den Rest der
// Engine als Konfundierung), braucht dafuer ein aufloesbares dynamisches Symbol.
__attribute__((target("avx2")))
int32_t snai_dot_i8_avx2(const int8_t* a, const int8_t* b, int n) {
  __m256i acc = _mm256_setzero_si256();
  int i = 0;
  for (; i + 16 <= n; i += 16) {
    __m128i va8 = _mm_loadu_si128((const __m128i*)(a + i));
    __m128i vb8 = _mm_loadu_si128((const __m128i*)(b + i));
    __m256i va16 = _mm256_cvtepi8_epi16(va8);
    __m256i vb16 = _mm256_cvtepi8_epi16(vb8);
    acc = _mm256_add_epi32(acc, _mm256_madd_epi16(va16, vb16));
  }
  __m128i lo = _mm256_castsi256_si128(acc);
  __m128i hi = _mm256_extracti128_si256(acc, 1);
  __m128i sum128 = _mm_add_epi32(lo, hi);
  sum128 = _mm_hadd_epi32(sum128, sum128);
  sum128 = _mm_hadd_epi32(sum128, sum128);
  int32_t result = _mm_cvtsi128_si32(sum128);
  for (; i < n; i++) result += (int32_t)a[i] * (int32_t)b[i];
  return result;
}

static int snai_has_avx2_cached = -1;
int snai_has_avx2(void) {
  if (snai_has_avx2_cached < 0) {
    snai_has_avx2_cached = __builtin_cpu_supports("avx2") ? 1 : 0;
  }
  return snai_has_avx2_cached;
}

// AUDIT 2026-08-23 (Fortsetzung) - Backward-Pfad von matVecMulBackwardAccI8().
// Beide Funktionen sind ELEMENTWEISE Skalierung+Akkumulation (dst[i] +=
// x[i]*factor fuer jedes i UNABHAENGIG) - anders als snai_dot_i8_avx2() gibt
// es hier KEINE Reduktion/Summation ueber mehrere Elemente in einen Skalar,
// jedes Ausgabeelement wird nur einmal geschrieben. Deshalb bewusst KEIN FMA
// (_mm256_fmadd_ps rundet a*b+c in EINEM Schritt - anders als zwei einzelne
// IEEE-754-Rundungen bei getrenntem Multiplizieren+Addieren, das haette
// ULP-Abweichungen vom Skalarpfad eingefuehrt, siehe die bereits verworfene
// Reziprok-Optimierung oben bei quantizeActivation). Mit getrenntem
// _mm256_mul_ps + _mm256_add_ps ist jede Spur bit-exakt zum Skalarcode, weil
// jede Lane unabhaengig genau dieselben zwei IEEE-754-Operationen durchlaeuft.

__attribute__((target("avx2")))
void snai_axpy_i8_scale_f32(const int8_t* w, float rowFactor, float* dst, int n) {
  __m256 vfactor = _mm256_set1_ps(rowFactor);
  int i = 0;
  for (; i + 8 <= n; i += 8) {
    __m128i vi8 = _mm_loadl_epi64((const __m128i*)(w + i));
    __m256i vi32 = _mm256_cvtepi8_epi32(vi8);
    __m256 vf = _mm256_cvtepi32_ps(vi32);
    __m256 prod = _mm256_mul_ps(vf, vfactor);
    __m256 old = _mm256_loadu_ps(dst + i);
    _mm256_storeu_ps(dst + i, _mm256_add_ps(old, prod));
  }
  for (; i < n; i++) dst[i] += (float)w[i] * rowFactor;
}

__attribute__((target("avx2")))
void snai_axpy_f32(float doV, const float* x, float* dst, int n) {
  __m256 vdoV = _mm256_set1_ps(doV);
  int i = 0;
  for (; i + 8 <= n; i += 8) {
    __m256 vx = _mm256_loadu_ps(x + i);
    __m256 prod = _mm256_mul_ps(vx, vdoV);
    __m256 old = _mm256_loadu_ps(dst + i);
    _mm256_storeu_ps(dst + i, _mm256_add_ps(old, prod));
  }
  for (; i < n; i++) dst[i] += doV * x[i];
}

// FULL-INT8 SCHRITT 1 (2026-08-23): reiner Ganzzahl-AXPY fuer den
// Backward-Pfad - dst_i32[c] += int8(w[c]) * int8(scalar). Keine einzige
// Float-Operation, der Akkumulator bleibt int32 ueber die gesamte Reduktion
// (erst der Aufrufer dequantisiert EINMAL am Ende). Damit wird
// d_in = W^T . d_out zu echtem int8xint8->int32-GEMM statt der bisherigen
// Float-Akkumulation auf dequantisierten Gewichten.
//
// Ueberlaufgrenze: rows * 127 * 127 muss in int32 passen -> rows <= 132.104.
// Derselbe Guard wie beim Forward-GEMM (checkI8AccumRange) deckt das ab.
__attribute__((target("avx2")))
void snai_axpy_i8_i32(const int8_t* w, int8_t scalar, int32_t* dst, int n) {
  __m256i vs = _mm256_set1_epi16((short)scalar);
  int i = 0;
  for (; i + 16 <= n; i += 16) {
    __m128i vw8 = _mm_loadu_si128((const __m128i*)(w + i));
    __m256i vw16 = _mm256_cvtepi8_epi16(vw8);
    // Produkt int16 x int16 -> zwei int32-Haelften (lo/hi je 8 Werte)
    __m256i prod_lo = _mm256_mullo_epi16(vw16, vs);
    __m256i prod_hi = _mm256_mulhi_epi16(vw16, vs);
    __m256i p0 = _mm256_unpacklo_epi16(prod_lo, prod_hi);
    __m256i p1 = _mm256_unpackhi_epi16(prod_lo, prod_hi);
    // unpack arbeitet lane-weise: p0 haelt Elemente 0-3 und 8-11, p1 die
    // Elemente 4-7 und 12-15 - deshalb die beiden 128-Bit-Haelften einzeln
    // an ihre richtige Position schreiben statt p0/p1 direkt zu addieren.
    __m128i d0 = _mm_loadu_si128((const __m128i*)(dst + i));
    __m128i d1 = _mm_loadu_si128((const __m128i*)(dst + i + 4));
    __m128i d2 = _mm_loadu_si128((const __m128i*)(dst + i + 8));
    __m128i d3 = _mm_loadu_si128((const __m128i*)(dst + i + 12));
    _mm_storeu_si128((__m128i*)(dst + i),      _mm_add_epi32(d0, _mm256_castsi256_si128(p0)));
    _mm_storeu_si128((__m128i*)(dst + i + 4),  _mm_add_epi32(d1, _mm256_castsi256_si128(p1)));
    _mm_storeu_si128((__m128i*)(dst + i + 8),  _mm_add_epi32(d2, _mm256_extracti128_si256(p0, 1)));
    _mm_storeu_si128((__m128i*)(dst + i + 12), _mm_add_epi32(d3, _mm256_extracti128_si256(p1, 1)));
  }
  for (; i < n; i++) dst[i] += (int32_t)w[i] * (int32_t)scalar;
}

// DW-GEMM (2026-10-15, Knirps-Tempo, Kriterien knirps96/kriterien_dw.txt): Gewichtsgradient einer Zeile r
//   acc[c] = sum_p q[p] * qi[p][c]   (int8 x int8 -> int32, exakt)
// in Registerbloecken statt je Position ein axpy ueber den Speicher-Akkumulator. Die Positionen liegen paarweise
// verschraenkt als int16 vor (pk[(pp*cols + c)*2 + k] = qi[2pp+k][c]), qp[pp] haelt (q[2pp] | q[2pp+1] << 16);
// _mm256_madd_epi16 bildet q[2pp]*qi[2pp][c] + q[2pp+1]*qi[2pp+1][c] (|.| <= 2*128*128, passt in int32).
// Ganzzahlsummen sind reihenfolgeunabhaengig (modulo 2^32 wie der alte Pfad) -> bitgleiches acc.
__attribute__((target("avx2")))
void snai_dw_rows_i8(const int16_t* pk, const int32_t* qp, int np, int32_t* acc, int cols) {
  int c = 0;
  for (; c + 32 <= cols; c += 32) {
    __m256i a0 = _mm256_setzero_si256(), a1 = _mm256_setzero_si256();
    __m256i a2 = _mm256_setzero_si256(), a3 = _mm256_setzero_si256();
    for (int pp = 0; pp < np; pp++) {
      int32_t qv = qp[pp];
      if (qv == 0) continue;
      __m256i vq = _mm256_set1_epi32(qv);
      const int16_t* b = pk + ((size_t)pp * cols + c) * 2;
      a0 = _mm256_add_epi32(a0, _mm256_madd_epi16(_mm256_loadu_si256((const __m256i*)(b)), vq));
      a1 = _mm256_add_epi32(a1, _mm256_madd_epi16(_mm256_loadu_si256((const __m256i*)(b + 16)), vq));
      a2 = _mm256_add_epi32(a2, _mm256_madd_epi16(_mm256_loadu_si256((const __m256i*)(b + 32)), vq));
      a3 = _mm256_add_epi32(a3, _mm256_madd_epi16(_mm256_loadu_si256((const __m256i*)(b + 48)), vq));
    }
    _mm256_storeu_si256((__m256i*)(acc + c), a0);
    _mm256_storeu_si256((__m256i*)(acc + c + 8), a1);
    _mm256_storeu_si256((__m256i*)(acc + c + 16), a2);
    _mm256_storeu_si256((__m256i*)(acc + c + 24), a3);
  }
  for (; c + 8 <= cols; c += 8) {
    __m256i a0 = _mm256_setzero_si256();
    for (int pp = 0; pp < np; pp++) {
      int32_t qv = qp[pp];
      if (qv == 0) continue;
      a0 = _mm256_add_epi32(a0, _mm256_madd_epi16(_mm256_loadu_si256((const __m256i*)(pk + ((size_t)pp * cols + c) * 2)), _mm256_set1_epi32(qv)));
    }
    _mm256_storeu_si256((__m256i*)(acc + c), a0);
  }
  for (; c < cols; c++) {
    int32_t s = 0;
    for (int pp = 0; pp < np; pp++) {
      int16_t lo = (int16_t)(qp[pp] & 0xFFFF), hi = (int16_t)((uint32_t)qp[pp] >> 16);
      s += (int32_t)lo * pk[((size_t)pp * cols + c) * 2] + (int32_t)hi * pk[((size_t)pp * cols + c) * 2 + 1];
    }
    acc[c] = s;
  }
}
#else
int32_t snai_dot_i8_avx2(const int8_t* a, const int8_t* b, int n) {
  int32_t result = 0;
  for (int i = 0; i < n; i++) result += (int32_t)a[i] * (int32_t)b[i];
  return result;
}
int snai_has_avx2(void) { return 0; }
void snai_axpy_i8_scale_f32(const int8_t* w, float rowFactor, float* dst, int n) {
  for (int i = 0; i < n; i++) dst[i] += (float)w[i] * rowFactor;
}
void snai_axpy_f32(float doV, const float* x, float* dst, int n) {
  for (int i = 0; i < n; i++) dst[i] += doV * x[i];
}
void snai_axpy_i8_i32(const int8_t* w, int8_t scalar, int32_t* dst, int n) {
  for (int i = 0; i < n; i++) dst[i] += (int32_t)w[i] * (int32_t)scalar;
}

void snai_dw_rows_i8(const int16_t* pk, const int32_t* qp, int np, int32_t* acc, int cols) {
  for (int c = 0; c < cols; c++) {
    int32_t s = 0;
    for (int pp = 0; pp < np; pp++) {
      int16_t lo = (int16_t)(qp[pp] & 0xFFFF), hi = (int16_t)((uint32_t)qp[pp] >> 16);
      s += (int32_t)lo * pk[((size_t)pp * cols + c) * 2] + (int32_t)hi * pk[((size_t)pp * cols + c) * 2 + 1];
    }
    acc[c] = s;
  }
}
#endif
""".}

proc snaiDotI8Avx2(a, b: ptr int8, n: cint): int32 {.importc: "snai_dot_i8_avx2", nodecl.}
proc snaiHasAvx2(): cint {.importc: "snai_has_avx2", nodecl.}
proc snaiAxpyI8ScaleF32(w: ptr int8, rowFactor: cfloat, dst: ptr cfloat, n: cint) {.importc: "snai_axpy_i8_scale_f32", nodecl.}
proc snaiAxpyF32(doV: cfloat, x: ptr cfloat, dst: ptr cfloat, n: cint) {.importc: "snai_axpy_f32", nodecl.}
proc snaiAxpyI8I32(w: ptr int8, scalar: int8, dst: ptr int32, n: cint) {.importc: "snai_axpy_i8_i32", nodecl.}
proc snaiDwRowsI8(pk: ptr int16, qp: ptr int32, np: cint, acc: ptr int32, cols: cint) {.importc: "snai_dw_rows_i8", nodecl.}
proc dwCGetenv(name: cstring): cstring {.importc: "getenv", header: "<stdlib.h>".}
# DW-GEMM-Schalter (seit 2026-10-15 Vorgabe an, Doku 6an): Gewichtsgradient blockweise (snai_dw_rows_i8);
# SNAI_DW_GEMM=0 -> alter axpy-Pfad. Beide Pfade rechnen bitgleich (Ganzzahlsummen).
let dwGemmOn = (let v = dwCGetenv("SNAI_DW_GEMM"); v.isNil or $v != "0")
if not dwGemmOn: stderr.writeLine("[DW-GEMM] aus (SNAI_DW_GEMM=0): Gewichtsgradient ueber den alten axpy-Pfad")

let hasAvx2Simd = snaiHasAvx2() != 0

proc matVecMulI8(m: QMatrix, i_v, o_v: ptr FloatArray, qbuf: ptr Int8Array) =
  ## out[r] = (sum_c int8(W[r,c]) * int8(in[c])) * scale[r] * actScale -
  ## echte int8xint8->int32-Akkumulation, Ergebnis sofort dequantisiert.
  let actScale = quantizeActivation(i_v, qbuf, m.cols)
  # PHASE 7: GPU-Dispatch. Die Aktivierung wird IMMER auf der CPU quantisiert
  # (O(cols), ~0,6% der Arbeit - eine GPU-Reduktion dafuer lohnt nicht und
  # braeuchte einen eigenen Kernel), nur das GEMM selbst wandert.
  if useGpuQMat(m):
    gpuMatVecMulI8(m, qbuf, actScale, o_v)
    return
  let rows = m.rows.int
  let cols = m.cols.int
  # AUDIT 2026-08-19 - bewusst die EINFACHE Reduktionsschleife: eine Variante
  # mit 4-fachem Unrolling und vier unabhaengigen Teilakkumulatoren (um die
  # Latenzkette der Additionen aufzubrechen) wurde gebaut und je dreimal
  # gegeneinander gemessen: 53,06/54,99/53,64 ms (entrollt) gegen
  # 53,01/54,38/53,12 ms (diese Fassung) - kein Unterschied jenseits der
  # Messstreuung. GCC entrollt/vektorisiert die simple Reduktion unter
  # -d:danger offenbar bereits selbst. Deshalb die kuerzere Fassung behalten.
  #
  # AUDIT 2026-08-23 - auf Hardware mit AVX2 laeuft die Reduktion jetzt ueber
  # snaiDotI8Avx2() (bit-exakt, siehe Kommentar an der Funktion), sonst
  # unveraendert der Skalarpfad.
  if hasAvx2Simd:
    {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
    # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
    for r in 0 || (rows - 1):
      let off = r * cols
      let acc = snaiDotI8Avx2(addr m.data[off], addr qbuf[0], cols.cint)
      o_v[r] = acc.cfloat * m.scale[r] * actScale
    {.pop.}
  else:
    {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
    # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
    for r in 0 || (rows - 1):
      let off = r * cols
      var acc: int32 = 0
      for c in 0 ..< cols:
        acc += int32(m.data[off + c]) * int32(qbuf[c])
      o_v[r] = acc.cfloat * m.scale[r] * actScale
    {.pop.}

# ==============================================================================
# PHASE 8: GEBUENDELTE INT8-MATMULS (ueber die Positionsachse)
# ------------------------------------------------------------------------------
# Phase 7 hat den GPU-Dispatch verdrahtet, aber gemessen war die GPU 6x
# LANGSAMER: der Einzelpfad ruft die Matmuls pro Position auf, das ergab 2.496
# Kernel-Starts pro Trainingsschritt (~0,26 ms Overhead je Start, jeweils mit
# blockierendem Readback). Diese Fassung verarbeitet alle Positionen in EINEM
# Aufruf - bei 16 Layern/Fenster 1024 sind das 291 statt ~298.000 Starts.
#
# Layout wie im FP32-Pendant matMulBatchedD: IN[p*cols + c], OUT[p*rows + r].
# ==============================================================================

var mmModusV = -1
proc mmModus(): int =
  ## 0 Originalpfad, 1 Blockpfad, 2 Blockpfad + ROT (o_all), 3 Blockpfad + ROTQ (qscales). Einmal je Prozess.
  if mmModusV < 0:
    let e = c_getenv_z("SNAI_I8_MM")
    let t = (if e.isNil: "" else: $e)
    mmModusV = (if t == "0": 0 elif t == "ROT": 2 elif t == "ROTQ": 3 else: 1)
    stderr.writeLine("[MM] Vorwaerts-Matmul: ", ["Originalpfad", "Blockpfad", "Blockpfad ROT", "Blockpfad ROTQ"][mmModusV])
  mmModusV
type QabArgs = object
  src: ptr FloatArray
  dst: ptr Int8Array
  scales: ptr FloatArray
  cols: int
  rot: bool
proc quantSummeKaputtF(summe: cfloat): bool
proc qabRow(a: ptr QabArgs, p: int) {.exportc: "snai_qab_row", cdecl.} =
  let cols = a.cols
  let src = a.src
  let off = p * cols
  var maxAbs: cfloat = 0.0
  var summe: cfloat = 0.0
  for c in 0 ..< cols:
    let x = abs(src[off + c])
    summe += x
    if x > maxAbs: maxAbs = x
  let scale = if maxAbs > 0.0: maxAbs / 127.0 else: 1.0
  a.scales[p] = (if quantSummeKaputtF(summe): quantNaN else: scale)
  for c in 0 ..< cols:
    var q = round(src[off + c] / scale).int
    if q > 127: q = 127
    elif q < -128: q = -128
    a.dst[off + c] = q.int8
  if a.rot and p == 0: a.scales[0] = a.scales[0] + 1.0'f32
proc qabRowC(a: ptr QabArgs, p: int) {.importc: "snai_qab_row", cdecl.}
proc quantizeActivationBatch(src: ptr FloatArray, dst: ptr Int8Array,
                             scales: ptr FloatArray, batch, cols: cint) =
  if mmModus() != 0:
    var a = QabArgs(src: src, dst: dst, scales: scales, cols: cols.int, rot: mmModus() == 3)
    let ap = addr a
    {.push checks: off.}
    for p in 0 || (batch.int - 1):
      qabRowC(ap, p)
    {.pop.}
    return
  ## Quantisiert einen ganzen Positionsblock: jede Position bekommt ihre EIGENE
  ## Abs-Max-Skala (identisch zur Einzelfassung quantizeActivation, nur
  ## batchweise). Bleibt bewusst auf der CPU - O(batch*cols) gegen
  ## O(batch*rows*cols) im GEMM, und ein GPU-Reduktionskernel dafuer waere
  ## mehr Aufwand als Nutzen.
  for p in 0 ..< batch.int:
    let off = p * cols.int
    var maxAbs: cfloat = 0.0
    var summe: cfloat = 0.0
    for c in 0 ..< cols.int:
      let a = abs(src[off + c])
      summe += a
      if a > maxAbs: maxAbs = a
    let scale = if maxAbs > 0.0: maxAbs / 127.0 else: 1.0
    scales[p] = (if quantSummeKaputt(summe): quantNaN else: scale)
    for c in 0 ..< cols.int:
      var q = round(src[off + c] / scale).int
      if q > 127: q = 127
      elif q < -128: q = -128
      dst[off + c] = q.int8

proc quantSummeKaputtF(summe: cfloat): bool = quantSummeKaputt(summe)
type MmBlkArgs = object
  m: QMatrix
  qbuf: ptr Int8Array
  qscales, o_all: ptr FloatArray
  batch, rows, cols: int
  rot: bool
const MM_BLK = 64
proc mmBlk(a: ptr MmBlkArgs, b: int) {.exportc: "snai_mm_blk", cdecl.} =
  let rows = a.rows
  let cols = a.cols
  let r0 = b * MM_BLK
  let r1 = min(r0 + MM_BLK, rows)
  for p in 0 ..< a.batch:
    let ib = p * cols
    let ob = p * rows
    let inScale = a.qscales[p]
    for r in r0 ..< r1:
      let off = r * cols
      let acc = snaiDotI8Avx2(addr a.m.data[off], addr a.qbuf[ib], cols.cint)
      a.o_all[ob + r] = acc.cfloat * a.m.scale[r] * inScale
  if a.rot and b == 0: a.o_all[0] = a.o_all[0] + 1.0'f32
proc mmBlkC(a: ptr MmBlkArgs, b: int) {.importc: "snai_mm_blk", cdecl.}
proc matMulBatchedI8Roh(m: QMatrix, i_all, o_all: ptr FloatArray,
                     qbuf: ptr Int8Array, qscales: ptr FloatArray, batch: cint) =
  ## OUT[p*rows + r] = (sum_c int8(W[r,c]) * int8(IN[p,c])) * scale[r] * inScale[p]
  quantizeActivationBatch(i_all, qbuf, qscales, batch, m.cols)
  if useGpuQMat(m):
    case gpu_backend
    of gbOpenCL:
      ocl_matMulBatchedI8(cast[ptr int8](m.data), cast[ptr cfloat](m.scale),
                           cast[ptr int8](qbuf), cast[ptr cfloat](qscales),
                           cast[ptr cfloat](o_all), m.rows, m.cols, batch)
      return
    of gbCuda:
      cuda_matMulBatchedI8(cast[ptr int8](m.data), cast[ptr cfloat](m.scale),
                           cast[ptr int8](qbuf), cast[ptr cfloat](qscales),
                           cast[ptr cfloat](o_all), m.rows, m.cols, batch)
      return
    else: discard
  let rows = m.rows.int
  let cols = m.cols.int
  if hasAvx2Simd and mmModus() != 0:
    var a = MmBlkArgs(m: m, qbuf: qbuf, qscales: qscales, o_all: o_all, batch: batch.int, rows: rows, cols: cols,
                      rot: mmModus() == 2)
    let ap = addr a
    let nb = (rows + MM_BLK - 1) div MM_BLK
    {.push checks: off.}
    for b in 0 || (nb - 1):
      mmBlkC(ap, b)
    {.pop.}
    return
  for p in 0 ..< batch.int:
    let ib = p * cols
    let ob = p * rows
    let inScale = qscales[p]
    # AUDIT 2026-08-23 - siehe matVecMulI8: identische Reduktion, deshalb
    # derselbe AVX2-Kernel (snaiDotI8Avx2), bit-exakt zum Skalarpfad.
    if hasAvx2Simd:
      {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
      # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
      for r in 0 || (rows - 1):
        let off = r * cols
        let acc = snaiDotI8Avx2(addr m.data[off], addr qbuf[ib], cols.cint)
        o_all[ob + r] = acc.cfloat * m.scale[r] * inScale
      {.pop.}
    else:
      {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
      # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
      for r in 0 || (rows - 1):
        var acc: int32 = 0
        let off = r * cols
        for c in 0 ..< cols:
          acc += int32(m.data[off + c]) * int32(qbuf[ib + c])
        o_all[ob + r] = acc.cfloat * m.scale[r] * inScale
      {.pop.}

# ==============================================================================
# FULL-INT8 SCHRITT 1 (2026-08-23): ganzzahliger Backward-Pfad
# ------------------------------------------------------------------------------
# Bis hierher war NUR das Forward-GEMM echtes int8 (Design-Entscheidung #4,
# "Hybrid"); der Backward-Pass rechnete in float auf DEQUANTISIERTEN Gewichten
# und machte damit rund zwei Drittel der Arbeit pro Trainingsschritt aus. Der
# Ziel ist ein vollstaendiger INT8-Port, nicht nur ein quantisierter
# Teil - dies ist der erste Schritt dorthin.
#
# DAS STRUKTURELLE PROBLEM, das der Hybrid-Ansatz umging:
#   Forward  out[r] = sum_c W[r,c]*scale[r] * x[c]   -> Skala ist KONSTANT
#            innerhalb der Summe (haengt nur von r ab, dem Summen-Ausgang).
#   Backward d_in[c] = sum_r W[r,c]*scale[r] * d[r]  -> Skala variiert INNERHALB
#            der Summe (r ist jetzt der Summations-Index). Ein reines
#            int8xint8-GEMM ist so nicht moeglich, weil jeder Summand eine
#            andere Skala traegt.
#
# DIE LOESUNG: die Zeilenskala vorab in den Gradienten ziehen.
#   d'[r] := scale[r] * d[r]   (O(rows) Float-Multiplikationen, vernachlaessigbar)
#   d_in[c] = sum_r W[r,c] * d'[r]
# Jetzt ist W roh-int8 OHNE Skala und d' wird EINMAL als Ganzes quantisiert
# (eine gemeinsame Abs-Max-Skala, genau wie eine Aktivierung im Forward). Die
# Summe laeuft komplett in int32, dequantisiert wird EINMAL am Ende.
#
# WARUM DIE SCHLEIFE UEBER r AUSSEN LIEGT (r-major statt c-major): die
# mathematisch naheliegende Fassung (fuer jedes c ueber alle r summieren)
# liest W spaltenweise - bei row-major-Layout ein Cache-Miss pro Element. Diese
# Fassung laeuft stattdessen zeilenweise durch W und akkumuliert in einen
# int32-Vektor der Laenge cols. Gleiche Mathematik (Integer-Addition ist
# assoziativ, die Reihenfolge ist also irrelevant - anders als bei Floats),
# aber sequenzieller Speicherzugriff und mit snaiAxpyI8I32() vektorisierbar.
#
# GENAUIGKEITSKOSTEN, ehrlich benannt: d' wird auf 8 Bit gerundet. Gradienten
# haben typischerweise eine groessere Dynamik als Aktivierungen (wenige grosse,
# viele winzige Werte), eine einzige Abs-Max-Skala fuer den ganzen Vektor kann
# die kleinen Werte also auf 0 druecken. Genau das ist die offene Frage aus
# Design-Entscheidung #4 des Ursprungsplans ("Gradientenfluss durch die
# Quantisierungsstufe"), und genau deshalb ist dieser Pfad per Schalter
# abschaltbar (cortex_set_i8_int_backward) und Default AUS, bis er gegen den
# Float-Pfad gemessen ist.
proc matMulBatchedI8(m: QMatrix, i_all, o_all: ptr FloatArray,
                     qbuf: ptr Int8Array, qscales: ptr FloatArray, batch: cint) =
  zeitMiss(ZA_MMF):
    matMulBatchedI8Roh(m, i_all, o_all, qbuf, qscales, batch)

var i8_int_backward*: cint = 0

proc updateI8CpuOnly() =
  ## Die Sperre schuetzte davor, dass der GPU-Zweig die Ganzzahl-Kernel STILL
  ## umgeht (er stand im Dispatch vor ihnen) - ein Fehler, der die Schalter
  ## wirkungslos machte, ohne es zu melden.
  ##
  ## Seit 2026-08-24 haben BACKWARD und GRADACC ein bit-exakt verifiziertes
  ## GPU-Pendant (ocl_backwardDInI8Batched, ocl_gradAccumI8). Die laufen ueber
  ## eigene Tore (useGpuBackwardI8/useGpuGradAccI8), die diese Sperre bewusst
  ## NICHT abfragen.
  ##
  ## Die Sperre bleibt trotzdem, weil sie noch etwas anderes abdeckt: sie haelt
  ## auch das FORWARD-GEMM auf der CPU. Ein Versuch, sie ganz zu entfernen,
  ## liess das Forward auf die GPU wandern - und die Loss-Kurve wich sofort um
  ## bis zu 4,7 ab (die GPU lernte praktisch nicht). Ursache nicht zu Ende
  ## verfolgt; Verdacht ist die Wechselwirkung mit dem Dirty-Flag-Rueckschrieb
  ## aus Phase 7. Bis das gemessen ist, bleibt das Forward gesperrt - eine
  ## unverifizierte GPU-Rechnung stillschweigend mitlaufen zu lassen ist genau
  ## der Fehler, den dieser ganze Abschnitt behebt.
  discard

proc cortex_set_i8_cpu_only*(enabled: cint) {.ffi.} =
  ## Notschalter: erzwingt den reinen CPU-Pfad, unabhaengig von der GPU.
  i8_cpu_only_path = enabled != 0

proc cortex_set_i8_int_backward*(enabled: cint) {.ffi.} =
  i8_int_backward = enabled
  updateI8CpuOnly()

proc cortex_get_i8_int_backward*(): cint {.ffi.} =
  i8_int_backward

# ------------------------------------------------------------------------------
# SCHRITT 1a (2026-08-24): Reparatur der Gradienten-Quantisierung
# ------------------------------------------------------------------------------
# Die erste Fassung quantisierte d' mit EINER Abs-Max-Skala fuer den ganzen
# Vektor. Auf echten Daten kostete das +0,665 Held-out-Loss (wachsend, siehe
# Messung im Full-INT8-Port). Vermessen, warum: bei w_out ist d_out = (softmax -
# onehot) - EIN grosser Wert am Ziel-Token, vocab-1 winzige. Die globale Skala
# richtet sich nach dem grossen Wert; gemessen an einer realistischen
# Verteilung landen dann **8.189 von 8.192 Werten auf 0** und nur 55% der
# Gradientenmasse ueberlebt. Der Backward-Pass sah also praktisch nur noch den
# Ziel-Token.
#
# FIX: Skalen pro BLOCK statt pro Vektor (Standardverfahren, vgl. block-wise
# quantization in bitsandbytes). Gemessen an derselben Verteilung:
#
#   Verfahren                 auf 0 gerundet   Gradientenmasse erhalten
#   global (alt)              8189 / 8192      55,2 %
#   Block 512                 1021 / 8192      94,5 %
#   Block 128                  253 / 8192      98,7 %
#   Block 64                   189 / 8192      99,0 %
#   Block 64 + stochastisch    177 / 8192      99,7 %
#
# Blockgroesse 64: guter Kompromiss. Kleinere Bloecke bringen kaum noch etwas,
# kosten aber je Block einen Dequantisierungs-Durchgang ueber `cols`.
#
# PREIS AN DER INTEGER-REINHEIT, ehrlich benannt: die Reduktion INNERHALB
# eines Blocks bleibt reines int32. Nur die Kombination der Bloecke laeuft in
# float (jeder Block hat eine andere Skala, ein gemeinsamer int32-Akkumulator
# ueber Bloecke mit 1e4-facher Dynamikspanne wuerde ueberlaufen oder die
# kleinen Bloecke platt machen). Das ist derselbe Kompromiss wie im Forward,
# wo die Zeilenskala die GEMM-Ausgabe dequantisiert. Der teure Teil - das
# eigentliche GEMM - ist vollstaendig ganzzahlig.
const I8_GRAD_BLOCK = 64

# Stochastisches Runden: erhaelt den ERWARTUNGSWERT von Werten unter einem
# halben LSB (ein Wert von 0,3 LSB wird in 30% der Faelle zu 1 statt immer zu
# 0). Nimmt dem Rundungsfehler die Systematik, erkauft das aber mit Varianz -
# deshalb per Schalter, Default AUS, bis gegen den Block-Fix allein gemessen.
var i8_grad_stochastic*: cint = 0
# THREAD-LOKAL (SCHRITT 1b): der gebuendelte Backward-Pfad ruft die
# Quantisierung aus einer parallelen Positions-Schleife auf. Ein einzelner
# globaler RNG-Zustand waere ein echtes Data Race - harmlos fuer die
# Korrektheit (es kaemen nur andere Zufallszahlen heraus), aber nicht
# reproduzierbar und unter dem Thread-Sanitizer ein Fund. Ein Slot je Thread
# loest das ohne Synchronisation.
const I8_MAX_THREADS = 256
var i8_rng_state: array[I8_MAX_THREADS, uint32]

proc cortex_set_i8_grad_stochastic*(enabled: cint) {.ffi.} =
  i8_grad_stochastic = enabled

proc cortex_get_i8_grad_stochastic*(): cint {.ffi.} =
  i8_grad_stochastic

proc xorshift32(t: int): uint32 {.inline, raises: [], gcsafe.} =
  ## Kleiner, schneller PRNG - Qualitaet reicht fuer Rundungsentscheidungen
  ## voellig aus (kein kryptografischer oder statistischer Anspruch).
  ## `t` ist der OpenMP-Thread-Index (eigener Zustand je Thread, s.o.).
  var x = i8_rng_state[t]
  if x == 0'u32:
    # Lazy-Init mit thread-abhaengigem Startwert: alle Threads mit demselben
    # Seed zu starten wuerde identische Rundungsentscheidungen erzeugen und
    # damit genau die Dekorrelation zunichtemachen, wegen der man stochastisch
    # rundet.
    x = 0x9E3779B9'u32 + (t.uint32 * 0x85EBCA6B'u32) + 1'u32
  x = x xor (x shl 13)
  x = x xor (x shr 17)
  x = x xor (x shl 5)
  i8_rng_state[t] = x
  return x

proc quantRound(x: cfloat, t: int): int {.inline, raises: [], gcsafe.} =
  if i8_grad_stochastic != 0:
    let f = floor(x)
    let frac = x - f
    # xorshift32 / 2^32 als Gleichverteilung in [0,1)
    let u = xorshift32(t).float64 / 4294967296.0
    result = (if frac.float64 > u: f.int + 1 else: f.int)
  else:
    result = round(x).int

proc allocI8BackwardScratch(s: ptr CortexState, maxRows, maxCols: int) =
  ## Legt die drei Backward-Scratchpuffer THREAD-lokal segmentiert an.
  ## Bewusst nach Threads statt nach Positionen dimensioniert: der gebuendelte
  ## Pfad parallelisiert ueber Positionen, braucht also nur so viele Saetze wie
  ## es gleichzeitig laufende Threads gibt. Bei ctx=8192 waeren pro Position
  ## dimensionierte Puffer hunderte MB, pro Thread sind es Kilobyte.
  var nThreads = cortex_omp_probe().int
  if nThreads < 1: nThreads = 1
  let dqStride = maxRows
  let accStride = maxCols
  let bsStride = (maxRows div I8_GRAD_BLOCK) + 2
  s.i8_bwThreads = nThreads.cint
  s.i8_dqStride = dqStride.cint
  s.i8_accStride = accStride.cint
  s.i8_bsStride = bsStride.cint
  s.i8_dscratch = cast[ptr Int8Array](allocShared0(nThreads * dqStride * sizeof(int8)))
  s.i32_dacc = cast[ptr IntArray](allocShared0(nThreads * accStride * sizeof(cint)))
  s.i8_dbscale = cast[ptr FloatArray](allocShared0(nThreads * bsStride * sizeof(cfloat)))
  # SCHRITT 2: i8_gqi ist ctx x maxCols gross (nicht thread-segmentiert - alle
  # Threads LESEN es nur, geschrieben wird es einmal vor der parallelen
  # Schleife). Der Gradient selbst wird nicht gepuffert, sondern in der
  # Zeilenschleife on-the-fly quantisiert: das kostet rows*batch Divisionen
  # gegen rows*batch*cols Multiplikationen im Kern, also ~1/cols - dafuer
  # entfaellt ein ctx x maxRows grosser Puffer (bei w_out waere das
  # ctx x vocab).
  s.i8_gqiStride = accStride.cint
  s.i8_gqi = cast[ptr Int8Array](allocShared0(s.ctxSize.int * accStride * sizeof(int8)))
  s.i8_gdscale = cast[ptr FloatArray](allocShared0(dqStride * sizeof(cfloat)))
  s.i8_giscale = cast[ptr FloatArray](allocShared0(accStride * sizeof(cfloat)))


# BEFUND 2026-09-02 (Engine-Pruefung): der Thread-Scratch wird nach
# omp_get_max_threads() ZUM ALLOKATIONSZEITPUNKT dimensioniert, an der
# Nutzstelle aber nur GEKLEMMT (`min(tid, maxT-1)`). Steigt die Threadzahl
# danach - omp_set_num_threads(), ein anderer OMP_NUM_THREADS-Wert im
# Elternprozess, ein Aufrufer mit eigener Parallelitaet -, schreiben zwei
# Threads in denselben Slice. Das Klemmen verhindert nur den Zugriff
# AUSSERHALB des Puffers; der Datenwettlauf INNERHALB bleibt und ist still:
# falsche Gradienten, kein Absturz, keine Meldung.
#
# Ein stiller Wettlauf ist schlimmer als ein langsamerer Pfad. Deshalb wird die
# Bedingung hier geprueft statt geklemmt: passt es nicht, faellt der
# Ganzzahl-Pfad auf den Float-Pfad zurueck (rechnerisch aequivalent, nur
# langsamer) und meldet sich EINMAL.
var scratchThreadWarned = false

proc scratchThreadsOk(st: ptr CortexState): bool {.raises: [], gcsafe.} =
  ## true = der Thread-lokale Scratch reicht fuer die aktuell aktive Threadzahl.
  ## `raises: []` wie quantRound(): der Aufrufer backwardDInBatchedI8() ist
  ## selbst nicht-werfend deklariert, und stderr.writeLine kann IOError werfen.
  if st.isNil or st.i8_bwThreads <= 0: return false
  let now = cortex_omp_probe().int
  # now == 0: ohne -fopenmp gebaut, alles laeuft seriell -> Slice 0 genuegt.
  if now == 0: return true
  if now <= st.i8_bwThreads.int and now <= I8_MAX_THREADS:
    return true
  if not scratchThreadWarned:
    scratchThreadWarned = true
    # Eine fehlgeschlagene Warnung darf den Trainingsschritt nicht abbrechen -
    # der Rueckfall auf den Float-Pfad passiert ohnehin, mit oder ohne Meldung.
    try:
      stderr.writeLine("[cortex] WARN: OpenMP-Threads (", $now,
                       ") ueberschreiten den beim Allokieren dimensionierten ",
                       "Scratch (", $st.i8_bwThreads, ", Obergrenze ",
                       $I8_MAX_THREADS, ") - Ganzzahl-Pfad abgeschaltet, es ",
                       "rechnet der Float-Pfad. Zustand neu laden behebt das.")
    except CatchableError:
      discard
  return false

proc backwardDInI8(m: QMatrix, d_out, d_in: ptr FloatArray,
                   dq: ptr Int8Array, acc32: ptr IntArray,
                   bscale: ptr FloatArray, accumulate: bool, gpuOk: cint)
                  {.exportc: "snai_bw_din_i8", raises: [], gcsafe.} =
  ## `raises: []` ist hier PFLICHT, nicht Kosmetik: SCHRITT 1b ruft diese
  ## Prozedur aus einer OpenMP-parallelen Positions-Schleife (`||`) auf. Ohne
  ## die Zusicherung erzeugt Nim nach dem Aufruf einen Fehler-Check mit
  ## `goto` aus dem strukturierten OpenMP-Block heraus - das lehnt GCC mit
  ## "ungueltiger Zweig zu/von strukturiertem OpenMP-Block" ab.
  ## d_in = W^T . d_out als int8xint8->int32-GEMM mit Pro-Block-Skalen.
  let rows = m.rows.int
  let cols = m.cols.int
  let nblocks = (rows + I8_GRAD_BLOCK - 1) div I8_GRAD_BLOCK
  # Einmal je Aufruf ermitteln, nicht je Element - der Aufruf ist billig, aber
  # nicht kostenlos.
  let tid = min(snaiOmpThread().int, I8_MAX_THREADS - 1)

  # 1. Je Block: eigene Abs-Max-Skala von d'[r] = scale[r]*d_out[r], dann
  #    quantisieren. Zwei Durchgaenge je Block statt eines Float-Puffers.
  for b in 0 ..< nblocks:
    let r0 = b * I8_GRAD_BLOCK
    let r1 = min(r0 + I8_GRAD_BLOCK, rows)
    var maxAbs: cfloat = 0.0
    var summe: cfloat = 0.0
    for r in r0 ..< r1:
      let a = abs(m.scale[r] * d_out[r])
      summe += a
      if a > maxAbs: maxAbs = a
    if maxAbs <= 0.0:
      bscale[b] = (if quantSummeKaputt(summe): quantNaN else: 0.0)
      for r in r0 ..< r1: dq[r] = 0
      continue
    let s = maxAbs / 127.0
    bscale[b] = (if quantSummeKaputt(summe): quantNaN else: s)
    for r in r0 ..< r1:
      var q = quantRound((m.scale[r] * d_out[r]) / s, tid)
      if q > 127: q = 127
      elif q < -128: q = -128
      dq[r] = q.int8

  # 2. Reduktion. Der GPU-Kernel bekommt genau die hier erzeugten dq/bscale -
  #    die Quantisierung bleibt auf dem Host (O(rows), lohnt auf der GPU nicht).
  # `gpuOk` statt useGpuBackwardI8() direkt: der gebuendelte Pfad ruft diese
  # Prozedur aus einer OpenMP-`||`-Schleife auf, und weder die OpenCL-Queue
  # noch die ephemeren Puffer sind thread-sicher (kostete hier einen
  # zerschossenen glibc-Heap). Er setzt das Flag deshalb auf 0 und benutzt
  # stattdessen ocl_backwardDInI8Batched() VOR der Schleife.
  if gpuOk == 1 and useGpuBackwardI8(m):
    gpuBackwardDInI8(cast[ptr int8](m.data), cast[ptr int8](addr dq[0]),
                      cast[ptr cfloat](addr bscale[0]), cast[ptr cfloat](addr d_in[0]),
                      m.rows, m.cols, I8_GRAD_BLOCK.cint,
                      (if accumulate: 1.cint else: 0.cint))
    return

  if not accumulate:
    for c in 0 ..< cols: d_in[c] = 0.0
  for b in 0 ..< nblocks:
    let s = bscale[b]
    if s <= 0.0: continue
    let r0 = b * I8_GRAD_BLOCK
    let r1 = min(r0 + I8_GRAD_BLOCK, rows)
    for c in 0 ..< cols: acc32[c] = 0
    if hasAvx2Simd:
      for r in r0 ..< r1:
        if dq[r] == 0: continue
        snaiAxpyI8I32(addr m.data[r * cols], dq[r], addr acc32[0], cols.cint)
    else:
      for r in r0 ..< r1:
        let dqr = int32(dq[r])
        if dqr == 0: continue
        let off = r * cols
        for c in 0 ..< cols:
          acc32[c] += int32(m.data[off + c]) * dqr
    for c in 0 ..< cols: d_in[c] += acc32[c].cfloat * s

# SCHRITT 1b: zweite, C-seitige Sicht auf backwardDInI8(). Noetig, weil Nim
# nach dem Aufruf einer NIM-Prozedur einen Fehler-Check mit `goto` erzeugt -
# und ein Sprung aus einem strukturierten OpenMP-Block heraus ist in C
# verboten (GCC: "ungueltiger Zweig zu/von strukturiertem OpenMP-Block").
# `raises: []` allein genuegt dafuer nicht; erst ueber die importc-Sicht
# entfaellt der Check. Genau deshalb rufen alle bestehenden `||`-Schleifen in
# dieser Datei ausschliesslich importc-Prozeduren auf (snaiDotI8Avx2 usw.).
proc backwardDInI8C(m: QMatrix, d_out, d_in: ptr FloatArray,
                    dq: ptr Int8Array, acc32: ptr IntArray,
                    bscale: ptr FloatArray, accumulate: bool, gpuOk: cint)
                   {.importc: "snai_bw_din_i8", nodecl.}

proc matMulTBatchedI8Roh(m: QMatrix, d_out_all, d_in_all: ptr FloatArray,
                      batch: cint, accumulate: bool = false,
                      st: ptr CortexState = nil) {.raises: [], gcsafe.} =
  ## D_IN[p*cols + c] = sum_r dequant(M[r,c]) * D_OUT[p*rows + r]
  ##
  ## FULL-INT8 SCHRITT 1b: ist `st` gesetzt, dessen Backward-Scratch allokiert
  ## UND i8_int_backward aktiv, laeuft jede Position durch denselben
  ## Ganzzahl-Kernel wie der Einzelpfad (`backwardDInI8`). Bewusst KEIN
  ## duplizierter Kernel - die Projekthistorie (CPU/OpenCL/CUDA-
  ## Adam-Kernel) zeigt, wie zuverlaessig duplizierte Rechenpfade auseinander
  ## driften. Der Preis ist die Thread-Slice-Indizierung hier.
  let rows = m.rows.int
  let cols = m.cols.int

  # REIHENFOLGE: siehe gradAccumBatchedI8(). Der Float-GPU-Zweig darf den
  # Ganzzahl-Zweig nicht ueberholen, sonst rechnet die GPU still etwas
  # anderes als eingeschaltet wurde.
  let useInt = i8_int_backward != 0 and not st.isNil and st.i8_bwThreads > 0 and
               scratchThreadsOk(st) and
               not st.i8_dscratch.isNil and not st.i32_dacc.isNil and
               not st.i8_dbscale.isNil and
               rows <= st.i8_dqStride.int and cols <= st.i8_accStride.int
  if not useInt and useGpuQMat(m):
    case gpu_backend
    of gbOpenCL:
      ocl_matMulTBatchedI8(cast[ptr int8](m.data), cast[ptr cfloat](m.scale),
                            cast[ptr cfloat](d_out_all), cast[ptr cfloat](d_in_all),
                            m.rows, m.cols, batch, (if accumulate: 1.cint else: 0.cint))
      return
    of gbCuda:
      cuda_matMulTBatchedI8(cast[ptr int8](m.data), cast[ptr cfloat](m.scale),
                            cast[ptr cfloat](d_out_all), cast[ptr cfloat](d_in_all),
                            m.rows, m.cols, batch, (if accumulate: 1.cint else: 0.cint))
      return
    else: discard

  if useInt and useGpuGradAccI8(rows, cols):
    # Ein Kernel-Start fuer alle Positionen. Die Quantisierung bleibt auf dem
    # Host (O(batch*rows) gegen batch*rows*cols im Kern) und spiegelt exakt
    # Schritt 1 von backwardDInI8() - sonst waere das Ergebnis nicht
    # bit-identisch zur CPU.
    let nb = batch.int
    let nblocks = (rows + I8_GRAD_BLOCK - 1) div I8_GRAD_BLOCK
    let dqB = cast[ptr Int8Array](allocShared(nb * rows))
    let bsB = cast[ptr FloatArray](allocShared(nb * nblocks * sizeof(cfloat)))
    for p in 0 ..< nb:
      let ob = p * rows
      for b in 0 ..< nblocks:
        let r0 = b * I8_GRAD_BLOCK
        let r1 = min(r0 + I8_GRAD_BLOCK, rows)
        var maxAbs: cfloat = 0.0
        for r in r0 ..< r1:
          let a = abs(m.scale[r] * d_out_all[ob + r])
          if a > maxAbs: maxAbs = a
        if maxAbs <= 0.0:
          bsB[p * nblocks + b] = 0.0
          for r in r0 ..< r1: dqB[ob + r] = 0
        else:
          let sc = maxAbs / 127.0
          bsB[p * nblocks + b] = sc
          for r in r0 ..< r1:
            var q = quantRound((m.scale[r] * d_out_all[ob + r]) / sc, 0)
            if q > 127: q = 127
            elif q < -128: q = -128
            dqB[ob + r] = q.int8
    gpuBackwardDInI8Batched(cast[ptr int8](m.data), cast[ptr int8](addr dqB[0]),
                             cast[ptr cfloat](addr bsB[0]),
                             cast[ptr cfloat](addr d_in_all[0]),
                             rows.cint, cols.cint, batch, I8_GRAD_BLOCK.cint,
                             (if accumulate: 1.cint else: 0.cint))
    deallocShared(dqB); deallocShared(bsB)
    return

  if useInt:
    let dqStride = st.i8_dqStride.int
    let accStride = st.i8_accStride.int
    let bsStride = st.i8_bsStride.int
    let maxT = st.i8_bwThreads.int
    {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
    # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
    for p in 0 || (batch.int - 1):
      # Thread-lokaler Scratch-Slice. min() ist eine Schutzschranke, falls zur
      # Laufzeit mehr Threads aktiv sind als beim Allokieren gemeldet wurden -
      # dann teilen sich zwei Threads einen Slice (Ergebnis waere Muell), das
      # faellt lieber auf Slice 0 zurueck als out-of-bounds zu schreiben.
      let t = min(snaiOmpThread().int, maxT - 1)
      backwardDInI8C(m,
                    cast[ptr FloatArray](addr d_out_all[p * rows]),
                    cast[ptr FloatArray](addr d_in_all[p * cols]),
                    cast[ptr Int8Array](addr st.i8_dscratch[t * dqStride]),
                    cast[ptr IntArray](addr st.i32_dacc[t * accStride]),
                    cast[ptr FloatArray](addr st.i8_dbscale[t * bsStride]),
                    accumulate, 0)
    {.pop.}
    return

  # AUDIT 2026-08-23 - identisches Muster wie matVecMulBackwardAccI8(), siehe
  # snai_axpy_i8_scale_f32() dort fuer die Bit-Exaktheits-Begruendung.
  {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
  # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
  for p in 0 || (batch.int - 1):
    let ob = p * rows
    let ib = p * cols
    if not accumulate:
      for c in 0 ..< cols: d_in_all[ib + c] = 0.0
    if hasAvx2Simd:
      for r in 0 ..< rows:
        let rowFactor = m.scale[r] * d_out_all[ob + r]
        let off = r * cols
        snaiAxpyI8ScaleF32(addr m.data[off], rowFactor, addr d_in_all[ib], cols.cint)
    else:
      for r in 0 ..< rows:
        let rowFactor = m.scale[r] * d_out_all[ob + r]
        let off = r * cols
        for c in 0 ..< cols:
          d_in_all[ib + c] += m.data[off + c].cfloat * rowFactor
  {.pop.}

proc matMulTBatchedI8(m: QMatrix, d_out_all, d_in_all: ptr FloatArray,
                      batch: cint, accumulate: bool = false,
                      st: ptr CortexState = nil) =
  {.cast(gcsafe).}:
    zeitMiss(ZA_MMT):
      matMulTBatchedI8Roh(m, d_out_all, d_in_all, batch, accumulate, st)

proc matVecMulBackwardAccI8(m: QMatrix, gm: Matrix, i_v, d_out, d_in: ptr FloatArray,
                            accumulate: bool = false,
                            dq: ptr Int8Array = nil, acc32: ptr IntArray = nil,
                            bscale: ptr FloatArray = nil) =
  ## d_in = dequant(M)^T . d_out (float, da d_out ein Gradient ist, keine
  ## quantisierte Aktivierung). gm-Akkumulation ist bit-identisch zur
  ## FP32-Formel (haengt gar nicht von m.data ab) - i_v ist die ORIGINALE
  ## FP32-Aktivierung, die vor der dynamischen Quantisierung in die
  ## Forward-Matmul ging (vom Aufrufer wie im FP32-Pfad bereits persistiert).
  ##
  ## FULL-INT8 SCHRITT 1: sind `dq`/`acc32` gesetzt UND i8_int_backward aktiv,
  ## laeuft der d_in-Teil als echtes int8xint8->int32-GEMM (backwardDInI8).
  let rowsB = m.rows.int
  let colsB = m.cols.int

  # PHASE 7: GPU-Dispatch. Zwei getrennte Teile - d_in nutzt den neuen
  # INT8-Backward-Kernel, die gm-Akkumulation den BESTEHENDEN FP32-Kernel
  # (gm, d_out und i_v sind alle float, das Gewicht kommt dort gar nicht vor -
  # der Kernel ist also dtype-unabhaengig und braucht keine INT8-Variante).
  if useGpuQMat(m):
    if not d_in.isNil:
      gpuMatVecMulTI8(m, d_out, d_in, (if accumulate: 1.cint else: 0.cint))
    gpuGradAccum(cast[ptr cfloat](gm.data), cast[ptr cfloat](d_out),
                  cast[ptr cfloat](i_v), gm.rows, gm.cols)
    return

  if not d_in.isNil:
    if i8_int_backward != 0 and not dq.isNil and not acc32.isNil and not bscale.isNil:
      # FULL-INT8 SCHRITT 1: echter Ganzzahl-Backward.
      backwardDInI8(m, d_out, d_in, dq, acc32, bscale, accumulate, 1)
    else:
      if not accumulate:
        for c in 0 ..< colsB: d_in[c] = 0.0
      for r in 0 ..< rowsB:
        let off = r * colsB
        # OPTIMIERUNG (Audit 2026-08-19): rscale*do_v ist schleifeninvariant und
        # wurde vorher fuer JEDES Element neu multipliziert
        # ((data*rscale)*do_v). Einmal vorab zusammengefasst spart eine
        # Multiplikation pro Element im gesamten Backward-Pass. Reine
        # Umklammerung derselben drei Faktoren - Float-Multiplikation ist
        # kommutativ/assoziativ genug, dass sich hoechstens die letzte
        # Mantissenstelle aendern kann.
        let rowFactor = m.scale[r] * d_out[r]
        # AUDIT 2026-08-23 - siehe snai_axpy_i8_scale_f32(): elementweise
        # Skalierung+Akkumulation, kein FMA (bit-exakt zum Skalarpfad).
        if hasAvx2Simd:
          snaiAxpyI8ScaleF32(addr m.data[off], rowFactor, addr d_in[0], colsB.cint)
        else:
          for c in 0 ..< colsB:
            d_in[c] += m.data[off + c].cfloat * rowFactor

  # AUDIT 2026-08-23 - siehe snai_axpy_f32(): identische Ueberlegung, reiner
  # Float-Pfad (haengt nicht von m.data ab, siehe Docstring oben).
  if hasAvx2Simd:
    {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
    # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
    for r in 0 || (rowsB - 1):
      let off = r * colsB
      snaiAxpyF32(d_out[r], addr i_v[0], addr gm.data[off], colsB.cint)
    {.pop.}
  else:
    {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
    # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
    for r in 0 || (rowsB - 1):
      let do_v = d_out[r]
      let off = r * colsB
      for c in 0 ..< colsB:
        gm.data[off + c] += do_v * i_v[c]
    {.pop.}

# --- ROUNDED-INTEGER-STEP ADAM (Design-Entscheidung #3) ---
# Kein FP32-Schattengewicht vorhanden, aus dem klassisches STE ableiten
# koennte - stattdessen rechnet Adam exakt wie im FP32-Pfad in float (liest
# int8_w[i]*scale[r] statt fp32_w[i]), der resultierende float-delta wird erst
# am Schluss auf eine ganzzahlige LSB-Bewegung gerundet (round-to-nearest,
# deterministisch/debugbar - stochastisches Runden nur als Fallback, falls das
# Go/No-Go-Gate systematisches "Dead Weight" unter der 0,5-LSB-Schwelle zeigt).
#
# GATE-BEFUND (Phase 2, erster Testlauf): kein "Dead Weight", sondern das
# GEGENTEIL - Adams charakteristische Schrittweite ist naeherungsweise
# lr-groß und UNABHAENGIG von der Parameter-Skala (Kernverhalten von Adam,
# nicht FP32/INT8-spezifisch). Bei Tensoren mit sehr kleiner Quantisierungs-
# Skala (z.B. w_out, Genesis-Init-Range ±0.0001 -> qscale ~ 1e-6..1e-7,
# "Softmax-Schutz", init_base.php) ist round(delta/qscale) dadurch eine
# vierstellige LSB-Zahl -> die Zeile saettigt INSTANT auf -128/127 statt sich
# graduell einzupendeln (bei FP32 unproblematisch, da w_out dort frei aus
# seiner Init-Skala herauswachsen darf - beim INT8-Fixgitter zerstoert das
# aber sofort die Fein-Struktur der Zeile). MAX_LSB_STEP_PER_UPDATE begrenzt
# die LSB-Bewegung pro Adam-Aufruf (Trust-Region auf dem Integer-Gitter) -
# Richtung/Betrag aus Adam bleiben bestimmend, aber der erste Schritt kann die
# Zeile nicht mehr in einem Rutsch zerstoeren; ueber viele Schritte kann sich
# eine konsistente Richtung trotzdem beliebig weit aufsummieren. Reiner
# Zahlenwert nicht theoretisch hergeleitet, sondern am Gate empirisch grob
# kalibriert (Faktor "genug LSBs fuer Fortschritt, wenig genug fuer
# Stabilitaet") - siehe Risiko-Punkt 1 im Plan-Dokument, dort bereits als
# "echtes Forschungsrisiko" erwartet.
const MAX_LSB_STEP_PER_UPDATE = 4

# DIAGNOSE (Ursachensuche 2026-08-19): zaehlt, wie oft die Trust-Region
# tatsaechlich greift. Reine Instrumentierung, aendert das Verhalten NICHT.
var i8_steps_total*: int64 = 0
var i8_steps_clamped*: int64 = 0
var i8_steps_zero*: int64 = 0
var i8_sum_wanted*: float64 = 0.0   # Summe |gewuenschte LSB-Schritte| vor der Kappung

proc cortex_i8_stats_reset*() {.ffi.} =
  i8_steps_total = 0; i8_steps_clamped = 0; i8_steps_zero = 0; i8_sum_wanted = 0.0

proc cortex_i8_stat*(which: cint): cdouble {.ffi.} =
  case which
  of 0: i8_steps_total.cdouble
  of 1: i8_steps_clamped.cdouble
  of 2: i8_steps_zero.cdouble
  of 3: i8_sum_wanted
  else: -1.0

proc adamStepI8(w: ptr int8, qscale: cfloat, m, v, g: ptr cfloat, lr, b1, b2, b1t, b2t, gradScale: cfloat, is_sparse: bool = false, boost: cfloat = 1.0, wd: cfloat = 0.0) {.inline.} =
  if gradScale == 0.0: return
  var grad = g[] / gradScale
  if is_sparse and abs(grad) < 1e-8: return
  if grad.isNaN or grad > 9999.0 or grad < -9999.0:
    g[] = 0.0
    return

  m[] = b1 * m[] + (1.0 - b1) * grad
  v[] = b2 * v[] + (1.0 - b2) * grad * grad
  let m_hat = m[] / b1t
  let v_hat = v[] / b2t
  var delta = (lr * boost) * m_hat / (sqrt(v_hat) + 1e-8)
  if wd > 0.0: delta += lr * wd * (w[].cfloat * qscale)
  let wanted = delta / qscale
  var steps = round(wanted).int
  i8_steps_total += 1
  i8_sum_wanted += abs(wanted)
  if steps == 0: i8_steps_zero += 1
  if steps > MAX_LSB_STEP_PER_UPDATE or steps < -MAX_LSB_STEP_PER_UPDATE:
    i8_steps_clamped += 1
  if steps > MAX_LSB_STEP_PER_UPDATE: steps = MAX_LSB_STEP_PER_UPDATE
  elif steps < -MAX_LSB_STEP_PER_UPDATE: steps = -MAX_LSB_STEP_PER_UPDATE
  if steps != 0:
    var newW = w[].int - steps
    if newW > 127: newW = 127
    elif newW < -128: newW = -128
    w[] = newW.int8
  g[] = 0.0

proc markQWeightsDirty(state: ptr CortexState) {.inline.} =
  ## PHASE 7: Adam und Re-Scaling laufen bewusst auf der CPU.
  ##
  ## Warum Adam NICHT auf die GPU wandert, obwohl der Kernel (ocl_adamStepI8)
  ## existiert und verifiziert ist: Adam ist eine reine elementweise Operation,
  ## also speicherbandbreiten- statt rechengebunden. Der bestehende
  ## FP32-Wrapper laedt dafuer w, m, v und g hoch und liest w, m, v wieder
  ## zurueck - bei Demi Goddess waeren das ~18 GB PCIe-Verkehr PRO SCHRITT und
  ## damit deutlich teurer als die Rechnung selbst. Die Gewichte auf der CPU zu
  ## aktualisieren und danach EINMAL die ~0,8 GB INT8-Daten hochzuschieben ist
  ## um Groessenordnungen guenstiger.
  ##
  ## Der Rueckschrieb passiert bewusst lazy (Flag statt sofortigem Transfer):
  ## pro Trainingsschritt aendern sowohl applyGlobalAdamUpdateI8() als auch
  ## cortex_rescale_weights() die Gewichte - ein sofortiger Push je Aenderung
  ## wuerde den Transfer verdoppeln.
  ##
  ## Nachtrag 2026-10-14: der Ganzzahl-Adam mit QMoment kann per
  ## SNAI_I8_GPU_ADAM doch auf der Karte laufen (gpuAdamRows). Dort bleiben
  ## die Momente resident und nur g, Gewichte und Skalen wandern - das
  ## Bandbreiten-Argument oben gilt fuer die FP32-Momente, nicht fuer 8 Bit.
  if gpu_initialized: state.qDirty = 1

proc flushQWeightsToGpu(state: ptr CortexState) =
  ## Schreibt alle INT8-Gewichte + Zeilen-Skalen auf das Geraet zurueck, falls
  ## sie host-seitig veraendert wurden. Muss VOR der ersten GPU-Rechnung eines
  ## Schrittes laufen - sonst rechnet die GPU still mit dem Stand von vorhin.
  if state.qDirty == 0 or not gpu_initialized: return
  gpuPushQMatrix(state.embeddings_q8)
  # Bei Tying identischer Host-Zeiger - der Puffer-Cache (ocl_get_buffer ist
  # ueber die Host-Adresse indiziert) traefe denselben Geraetepuffer, der Push
  # waere also nur doppelte Transferkosten.
  if state.tiedEmbeddings == 0:
    gpuPushQMatrix(state.w_out_q8)
  for l in 0 ..< state.numLayers:
    gpuPushQMatrix(state.w_q_q8[l]);  gpuPushQMatrix(state.w_k_q8[l])
    gpuPushQMatrix(state.w_v_q8[l]);  gpuPushQMatrix(state.w_o_q8[l])
    gpuPushQMatrix(state.w_up_q8[l]); gpuPushQMatrix(state.w_down_q8[l])
  state.qDirty = 0

# ==============================================================================
# URSACHENFIX (2026-08-19): Adam-Schritt in Float, danach Zeile requantisieren
# ------------------------------------------------------------------------------
# Die Messung (diagnose-Instrumentierung) zeigte: 72-76% aller Adam-Updates
# wurden von MAX_LSB_STEP_PER_UPDATE gekappt, weitere 26% runden auf 0 - nur
# ~2% liefen ungehindert durch. Der gewuenschte Schritt lag im Mittel bei ~540
# LSB gegen 4 erlaubte, also Faktor ~135 Drosselung. Ursache ist strukturell:
# Adams Schrittweite ist ~lr und damit UNABHAENGIG von der Gewichtsskala,
# waehrend ein LSB = max|Zeile|/127 ist. Bei klein initialisierten Tensoren
# (w_out: +-0.0001 -> 1 LSB ~ 8e-7) will ein Schritt von 0.001 rund 1270 LSB
# weit. Die Kappung verzerrt dabei nicht nur den Betrag, sondern auch die
# RICHTUNG (Elemente mit Wunsch 540 und 5 landen beide bei 4).
#
# Statt die Konstante nachzujustieren wird hier das Grundproblem beseitigt:
# der Adam-Schritt wird in Float auf dem dequantisierten Gewicht ausgefuehrt
# (exakt wie im FP32-Pfad), erst DANACH wird die Zeile mit frisch berechneter
# Skala requantisiert. Damit entfallen Kappung und Null-Schritte vollstaendig.
# Der einzige verbleibende Fehler ist die Rundung auf das Gitter je Schritt -
# und genau die wurde als unschaedlich GEMESSEN: ein fertig trainiertes
# FP32-Modell nachtraeglich zu quantisieren aendert den Held-out-Loss um
# < 0.00005 (7.2721 vs 7.2721).
#
# Speichertrick: der Gradientenpuffer g dient als Zwischenspeicher fuer das
# aktualisierte Float-Gewicht (er wird ohnehin direkt danach genullt) - kein
# zusaetzlicher Puffer noetig, die INT8-Speicherersparnis bleibt erhalten.
# Diese Fassung macht cortex_rescale_weights() ueberfluessig (die Skala wird
# hier bereits pro Schritt korrekt neu gesetzt).
# ==============================================================================
var i8_float_adam*: cint = 1

proc cortex_set_i8_float_adam*(enabled: cint) {.ffi.} =
  i8_float_adam = enabled

proc cortex_get_i8_float_adam*(): cint {.ffi.} =
  i8_float_adam

# FEHLER-RUECKFUEHRUNG: 1 = Rundungsrest aufheben und im naechsten Schritt vor
# dem Requantisieren wieder addieren (Default). 0 = altes Verhalten, Rest wird
# verworfen. Wirkt nur im Float-Adam-Pfad und nur, wenn die res_*-Puffer
# allokiert sind (also im Training, nicht bei reiner Inferenz).
var i8_error_feedback*: cint = 1

proc cortex_set_i8_error_feedback*(enabled: cint) {.ffi.} =
  i8_error_feedback = enabled

proc cortex_reset_i8_error_feedback*(state: ptr CortexState) {.ffi.} =
  ## Nullt die Rest-Puffer der Fehler-Rueckfuehrung - bildet nach, was ein
  ## Checkpoint-Uebergang ohnehin tut (das Residuum wird bewusst NICHT
  ## mitgespeichert, siehe Phase 10). Damit laesst sich der Reset ISOLIERT
  ## messen, ohne Datei-Rundlauf und ohne Merge daneben.
  gpuAdamDrop()
  if state.isNil or state.res_w_out.data.isNil: return
  template z(m: Matrix) =
    if not m.data.isNil:
      for i in 0 ..< (m.rows.int * m.cols.int): m.data[i] = 0.0
  z(state.res_embeddings); z(state.res_w_out)
  for l in 0 ..< state.numLayers:
    if not state.res_w_q.isNil: z(state.res_w_q[l])
    if not state.res_w_k.isNil: z(state.res_w_k[l])
    if not state.res_w_v.isNil: z(state.res_w_v[l])
    if not state.res_w_o.isNil: z(state.res_w_o[l])
    if not state.res_w_up.isNil: z(state.res_w_up[l])
    if not state.res_w_down.isNil: z(state.res_w_down[l])

proc cortex_i8_error_feedback_active*(state: ptr CortexState): cint {.ffi.} =
  ## 1 = eingeschaltet UND Rest-Puffer vorhanden, wirkt also wirklich. Der
  ## Schalter allein sagt das NICHT - genau diese Luecke kostete einen
  ## kompletten Vergleichslauf.
  ##
  ## SNAI_V7 (2026-08-29): geprueft wird der Puffer des Tensors, der auch
  ## tatsaechlich requantisiert wird. Bei Tying ist das res_embeddings -
  ## res_w_out ist dort bewusst nil, weil es kein zweites Gewicht mehr gibt.
  ## Die alte Fassung tastete unbedingt res_w_out ab und haette bei jedem
  ## gebundenen Modell "wirkt nicht" gemeldet, obwohl die Rueckfuehrung laeuft -
  ## also genau die Sorte falsche Entwarnung/Fehlwarnung, gegen die diese
  ## Funktion ueberhaupt eingefuehrt wurde.
  if state.isNil or i8_error_feedback == 0: return 0
  if state.tiedEmbeddings != 0:
    return (if state.res_embeddings.data.isNil: 0 else: 1)
  (if state.res_w_out.data.isNil: 0 else: 1)

proc cortex_get_i8_error_feedback*(): cint {.ffi.} =
  i8_error_feedback

# ==============================================================================
# FULL-INT8 SCHRITT 3 (2026-08-24): Adam-Zustaende (m/v) auf 8 Bit
# ------------------------------------------------------------------------------
# GROESSTER SPEICHERPOSTEN des Projekts: m und v sind je ein float32 pro
# Parameter und laut Groessenleiter bei Goddess zusammen 48,5 GB - mehr als
# alle Gewichte. Design-Entscheidung #2 hielt sie bewusst in FP32, weil der
# Phase-2-Gate-Befund zeigte, wie empfindlich Adams Schrittweite gegen
# Auflösungsverlust ist.
#
# GEMESSEN VOR DER UMSETZUNG (diagnose/analyze_adam_dynamics.php, 200 echte
# Schritte, Werte aus w_out):
#   m: Dynamik max/p1 = 7,3e4   v: Dynamik max/p1 = 1,9e7
# v ist der kritische Teil - es ist ein Mittel ueber QUADRIERTE Gradienten, die
# Dynamik von g erscheint darin quadriert. Vergleich der Verfahren, Fehler
# jeweils bezogen auf sqrt(v) (die Groesse, durch die Adam teilt):
#
#   Verfahren            auf 0 gerundet   max rel Fehler   mittl. rel Fehler
#   linear (Block 64)        59,4 %           41 %              4,0 %
#   sqrt-Domaene             20,6 %          100 %              8,6 %
#   LOGARITHMISCH             0,0 %          1,8 %              0,9 %
#
# Lineare Quantisierung verschwendet bei log-normal verteilten Groessen alle
# Stufen am oberen Ende; die logarithmische hat KONSTANTEN RELATIVEN Fehler -
# genau das braucht Adam. Deshalb: beide Momente log-quantisiert, v unsigned
# (immer positiv), m als Vorzeichen + Log-Magnitude.
#
# WARUM DAS HIER ZUNAECHST NUR SIMULIERT WIRD: der echte Speichergewinn
# erfordert, die Felder m_*/v_* von `Matrix` (float32) auf int8+Blockskala
# umzustellen - das beruehrt Allokation, extract/load, Serialisierung
# (SNAI_V6) und den Merge. Bevor dieser Aufwand investiert wird, muss die
# QUALITAETSFRAGE geklaert sein. Dieser Schalter quantisiert m und v nach
# jedem Adam-Schritt und dequantisiert sofort zurueck: der Praezisionsverlust
# ist damit exakt der des spaeteren echten Formats, der Speicherverbrauch
# bleibt aber unveraendert. Faellt das Gate durch, ist der Umbau gespart;
# haelt es, ist er gerechtfertigt.
const ADAM_Q_BLOCK = 256          # Blockgroesse der SIMULATION (Zeilenskala im echten Format)
const MAX_ADAM_ROW = 32768        # Zeilenpuffer fuer den quantisierten Adam-Pfad
const ADAM_Q_DYN = 1.0e8          # darstellbare Dynamik je Block

var i8_quant_adam*: cint = 0
# SCHRITT 3 (Speicherumbau): true => die Adam-Momente der 8 GROSSEN Tensoren
# werden als QMoment (8 Bit + Zeilenskala) angelegt, die float32-Zwillinge gar
# nicht erst. Nur so sinkt der Spitzenverbrauch - nachtraegliches Freigeben
# reicht nicht, der Allokator behaelt die Arena (im Audit vom 2026-08-19
# gemessen: 21 MB vor wie nach dem Freigeben).
var init_quant_adam* = false
# SCHRITT 4b (Speicherumbau): true => act_ffn_out wird als int8-QMatrix
# angelegt, der float-Zwilling gar nicht erst. Wie init_quant_adam muss das
# VOR cortex_init() stehen.
var init_quant_acts* = false
var init_quant_acts_in* = false

# Dequantisierungstabellen. Der Trick: weil die darstellbare Dynamik FEST ist
# (ADAM_Q_DYN), ist die Tabelle blockunabhaengig - dequantisieren ist dann eine
# einzige Multiplikation `blockMax * TAB[q]` statt eines exp()-Aufrufs. Nur die
# Quantisierung braucht ein log() pro Element.
var adamTabV: array[256, cfloat]      # v: q=0 -> exakt 0, q=1..255
var adamTabM: array[128, cfloat]      # |m|: q=0 -> exakt 0, q=1..127
var adamTabReady = false

proc initAdamTables() =
  if adamTabReady: return
  let lg = ln(ADAM_Q_DYN)
  adamTabV[0] = 0.0
  for q in 1 .. 255:
    adamTabV[q] = exp(((q - 1).float / 254.0 - 1.0) * lg).cfloat
  adamTabM[0] = 0.0
  for q in 1 .. 127:
    adamTabM[q] = exp(((q - 1).float / 126.0 - 1.0) * lg).cfloat
  adamTabReady = true

# ==============================================================================
# FULL-INT8 SCHRITT 4b (2026-08-24): Aktivierungshistorien der FFN-Schicht
# ------------------------------------------------------------------------------
# act_ffn_in und act_ffn_out sind je ctx*ffn*layers gross - bei Goddess je
# 16 GB, zusammen also der groesste verbleibende Posten nach der Bitmaske aus
# 4a. Anders als dort geht es hier NICHT verlustfrei: beide Puffer liegen im
# aktiven Rechenweg (act_ffn_in ist Ausgabeziel des Forward-GEMM und Eingang
# der SiLU-Ableitung, act_ffn_out geht als Eingabe ins naechste GEMM und als
# i_v in die Gradienten-Akkumulation).
#
# Deshalb wie bei Schritt 3 zuerst eine SIMULATION: die Werte werden nach dem
# Schreiben quantisiert und sofort dequantisiert. Der Praezisionsverlust ist
# exakt der des spaeteren int8-Formats, der Speicher bleibt unveraendert. Erst
# wenn die Qualitaet das traegt, lohnt der Umbau - der hier deutlich teurer
# waere als bei den Momenten, weil er den verifizierten Forward-Pfad beruehrt.
#
# Skala PRO POSITION (nicht pro Spalte): eine Zeile des Puffers ist eine
# Position, und genau so quantisiert der Forward-Pfad Aktivierungen ohnehin
# schon (quantizeActivationBatch). Damit bliebe der spaetere echte Umbau
# strukturgleich zum bestehenden Code.
var i8_quant_acts*: cint = 0

proc cortex_set_i8_quant_acts*(enabled: cint) {.ffi.} =
  i8_quant_acts = enabled

proc cortex_get_i8_quant_acts*(): cint {.ffi.} =
  i8_quant_acts

proc quantDequantActRows(dat: ptr FloatArray, rows, cols: int) =
  ## Simuliert int8 mit Pro-Position-Skala (symmetrisch, wie im Forward-Pfad).
  for r in 0 ..< rows:
    let off = r * cols
    var mx: cfloat = 0.0
    for c in 0 ..< cols:
      let a = abs(dat[off + c])
      if a > mx: mx = a
    if mx <= 0.0: continue
    let sc = mx / 127.0
    let inv = 1.0.cfloat / sc
    for c in 0 ..< cols:
      var q = round(dat[off + c] * inv).int
      if q > 127: q = 127
      elif q < -128: q = -128
      dat[off + c] = q.cfloat * sc

# ==============================================================================
# FULL-INT8 SCHRITT 5a (2026-08-24): SiLU als Tabellenzugriff
# ------------------------------------------------------------------------------
# VORAB GEMESSEN, weil es die Bewertung des ganzen Schritts bestimmt: der
# Anteil ALLER transzendenten Operationen (SiLU + Softmax) an der Rechenzeit
# liegt bei 1,6-3,2 % und FAELLT mit der Modellgroesse - die GEMMs skalieren
# mit `dim`, SiLU nicht. Ein vollstaendiger Festkomma-Umbau von RMSNorm, RoPE,
# Softmax und SiLU braechte also hoechstens ~3 % Tempo, null Speicher, und
# traegt zugleich das hoechste Genauigkeitsrisiko des ganzen Ports (RMSNorm
# und Softmax sind numerisch die empfindlichsten Stellen). Umgesetzt wird
# deshalb nur der Teil mit nachweisbarem Nutzen.
#
# DER ANSATZ: nach Schritt 4c liegt act_ffn_in als int8 vor - je Position gibt
# es also nur 256 moegliche Eingabewerte. Eine Tabelle mit 256 Eintraegen ist
# damit EXAKT (relativ zur ohnehin quantisierten Eingabe), kein zusaetzlicher
# Fehler. Statt `ffn` Aufrufen von exp() genuegen 256 je Position; bei
# ffn = 16.384 sind das 64x weniger.
#
# Gemessen an einem isolierten C-Benchmark: 3,2 ns/Element mit expf gegen
# 1,08 ns/Element per Tabelle - Faktor 2,99, inklusive Tabellenaufbau.
# ATTFIX 2026-10-09: Der Attention-Backward rechnete die Scores mit dem
# FLOAT-q neu, der Forward bildet sie aus dem QUANTISIERTEN q. Vorwaerts und
# rueckwaerts galten damit verschiedene Softmax-Verteilungen. An einem frischen
# Modell harmlos (cos 0,986-0,998), bei grossen Logits nicht mehr (prod512_s19:
# cos 0,03-0,81 der Q/K-Gradienten, anderer Sieger in 2,4 % der lebendigen
# Paare). 1 (Default) = der Backward quantisiert q wie der Forward und rechnet
# Scores und d_k darauf; 0 = altes Verhalten, nur fuer Vergleichsmessungen.
var i8_att_bw_quantq*: cint = 1

proc cortex_set_i8_att_bw_quantq*(enabled: cint) {.ffi.} =
  i8_att_bw_quantq = enabled

proc cortex_get_i8_att_bw_quantq*(): cint {.ffi.} =
  i8_att_bw_quantq

var i8_silu_lut*: cint = 0

proc cortex_set_i8_silu_lut*(enabled: cint) {.ffi.} =
  i8_silu_lut = enabled

proc cortex_get_i8_silu_lut*(): cint {.ffi.} =
  i8_silu_lut

proc siluRowFromQ8(qin: QMatrix, row: int, dst: ptr FloatArray, off, n: int,
                   lut: ptr FloatArray, ex: ptr FloatArray = nil) =
  ## SiLU einer Zeile aus der int8-Historie ueber eine 256er-Tabelle.
  ## Die Zeilenskala ist konstant, also haengt SiLU(q*s) nur von q ab - die
  ## Tabelle gilt fuer die ganze Zeile.
  let sc = qin.scale[row]
  for q in 0 ..< 256:
    let v = (q - 128).cfloat * sc
    let e = exp(-v)
    if not ex.isNil: ex[q] = e
    lut[q] = v * (1.0.cfloat / (1.0.cfloat + e))
  let base = row * qin.cols.int
  for i in 0 ..< n:
    dst[off + i] = lut[qin.data[base + i].int + 128]

proc allocQMoment(rows, cols: cint): QMoment =
  result.rows = rows
  result.cols = cols
  result.data = cast[ptr Uint8Array](allocShared0(rows.int * cols.int * sizeof(uint8)))
  result.scale = cast[ptr FloatArray](allocShared0(rows.int * sizeof(cfloat)))

proc freeQMoment(q: QMoment) =
  gpuAdamDrop()
  if not q.data.isNil: deallocShared(q.data)
  if not q.scale.isNil: deallocShared(q.scale)

proc qmomGet(q: QMoment, row, c: int, signed: bool): cfloat {.inline.} =
  ## Dequantisieren: eine Multiplikation, kein exp() (Tabelle ist
  ## blockunabhaengig, weil die Dynamik fest ist).
  let b = q.data[row * q.cols.int + c]
  if b == 0'u8: return 0.0
  let sc = q.scale[row]
  if signed:
    let mag = (b and 0x7F'u8).int
    if mag == 0: return 0.0
    let v = sc * adamTabM[mag]
    return (if (b and 0x80'u8) != 0'u8: -v else: v)
  else:
    return sc * adamTabV[b.int]

# SR 2026-10-18, im Projektbaum seit 2026-10-19 (Vorgabe mv): zufaelliges Runden des 8-Bit-Log-Codes der Adam-Momente.
# Grund: Beim Runden zum naechsten Code klingt v nie ab (0,1 % Abklingen je Schritt < halbe Stufe 3,7 %) und bleibt
# auf seinem Hoechststand stehen ("v-Ratsche"); zusammen mit Decay und den zackigen int8-Gradienten liess das lange
# int8-Laeufe kollabieren. Zufaelliges Runden ist im Mittel erwartungstreu.
# Bitmaske 1 = m, 2 = v,
# -1 = noch nicht aus SNAI_I8_MOM_SR gelesen. srInAdam: nur waehrend applyGlobalAdamUpdateI8.
var i8_mom_sr*: cint = -1
var srInAdam = false
var srSalt: uint64 = 0
proc srUniform(x: cfloat, row, c: int, signed: bool): float {.inline.} =
  var h = uint64(cast[uint32](x)) xor (uint64(row) shl 32) xor (uint64(c) shl 12) xor srSalt
  if signed: h = h xor 0x5851F42D4C957F2D'u64
  h = h + 0x9E3779B97F4A7C15'u64
  h = (h xor (h shr 30)) * 0xBF58476D1CE4E5B9'u64
  h = (h xor (h shr 27)) * 0x94D049BB133111EB'u64
  h = h xor (h shr 31)
  float(h shr 11) * (1.0 / 9007199254740992.0)
proc srLeseUmgebung() =
  let w = getEnv("SNAI_I8_MOM_SR")
  case w
  of "0": i8_mom_sr = 0
  of "m": i8_mom_sr = 1
  of "v": i8_mom_sr = 2
  of "", "mv": i8_mom_sr = 3
  else:
    stderr.writeLine("SNAI_I8_MOM_SR='", w, "' ungueltig (nur leer = mv, 0, m, v, mv) - Abbruch")
    quit(1)
  echo "  > [SR] Engine: Momente zufaellig gerundet m ", (i8_mom_sr and 1), " v ", (i8_mom_sr shr 1) and 1
  flushFile(stdout)

# V-KLEMME (2026-11-03, messbuch snai/v-klebt-lauf e499, als Voreinstellung).
# Fehler vorher: v > 0, aber unter der darstellbaren Zeilenschwelle, wurde als Code 0 gespeichert, waehrend m != 0
# blieb (rund 11 % der FFN-Momente am Knirps ab s8). Adam teilte danach durch sqrt(0)+eps - riesige Schritte.
# Jetzt: solches v auf die kleinste Stufe (Code 1) klemmen. v == 0 bleibt 0. Gemessen: Norm, Held-out und tote
# Gains in 3/3 Reihenfolgen gleich (< 1 %), Fehler beseitigt. SNAI_V_KLEMME=0 = altes Verhalten.
var vKlemmeZustand = -1
proc vKlemmeAn(): bool =
  if vKlemmeZustand < 0:
    vKlemmeZustand = (if getEnv("SNAI_V_KLEMME") == "0": 0 else: 1)
    stderr.writeLine("  > [VK] Engine: v-Klemme ", vKlemmeZustand)
  vKlemmeZustand == 1

proc qmomStoreRow(q: QMoment, row: int, src: ptr FloatArray, off: int, signed: bool) =
  ## Quantisiert eine ganze Zeile aus `src[off ..< off+cols]` und schreibt
  ## Skala + Bytes. Zwei Durchgaenge: erst max|x| der Zeile, dann kodieren.
  let cols = q.cols.int
  let base = row * cols
  var mx: cfloat = 0.0
  for c in 0 ..< cols:
    let a = abs(src[off + c])
    if a > mx: mx = a
  q.scale[row] = mx
  if mx <= 0.0:
    for c in 0 ..< cols: q.data[base + c] = 0'u8
    return
  let lo = mx / ADAM_Q_DYN
  let lgr = ln(ADAM_Q_DYN)
  let steps = (if signed: 126.0 else: 254.0)
  let qmax = (if signed: 127 else: 255)
  for c in 0 ..< cols:
    let x = src[off + c]
    let ax = abs(x)
    if ax <= lo:
      q.data[base + c] = (if (not signed) and ax > 0.0 and vKlemmeAn(): 1'u8 else: 0'u8)
    else:
      var qi: int
      if srInAdam and (i8_mom_sr and (if signed: 1.cint else: 2.cint)) != 0:
        qi = 1 + int(floor(steps * ln(ax / lo) / lgr + srUniform(x, row, c, signed)))
      else:
        qi = 1 + int(round(steps * ln(ax / lo) / lgr))
      if qi < 1: qi = 1
      elif qi > qmax: qi = qmax
      if signed:
        var b = qi.uint8 and 0x7F'u8
        if x < 0.0: b = b or 0x80'u8
        q.data[base + c] = b
      else:
        q.data[base + c] = qi.uint8

proc cortex_set_i8_quant_adam*(enabled: cint) {.ffi.} =
  ## SIMULATION (quantisiert/dequantisiert im Adam-Schritt, Speicher unveraendert).
  if enabled != 0: initAdamTables()
  i8_quant_adam = enabled

proc cortex_set_quant_acts_memory*(enabled: cint) {.ffi.} =
  ## ECHTER SPEICHERUMBAU fuer act_ffn_out. Wie beim Adam-Pendant: muss VOR
  ## cortex_init()/cortex_load_stream*() gesetzt werden.
  init_quant_acts = (enabled != 0)

proc cortex_set_quant_acts_in_memory*(enabled: cint) {.ffi.} =
  ## SCHRITT 4c: dasselbe fuer act_ffn_in. Setzt implizit auch 4b, weil beide
  ## sich denselben float-Scratch teilen - getrennt allokieren waere doppelter
  ## Speicher fuer denselben Zweck.
  init_quant_acts_in = (enabled != 0)
  if enabled != 0: init_quant_acts = true

proc cortex_get_quant_acts_in_memory*(s: ptr CortexState): cint {.ffi.} =
  if s.isNil: -1 else: s.quantActsIn

proc cortex_get_quant_acts_memory*(s: ptr CortexState): cint {.ffi.} =
  if s.isNil: -1 else: s.quantActs

proc cortex_set_quant_adam_memory*(enabled: cint) {.ffi.} =
  ## ECHTER SPEICHERUMBAU: muss VOR cortex_init()/cortex_load_stream*() gesetzt
  ## werden, weil dort ueber die Allokation entschieden wird. Nachtraeglich
  ## umzuschalten wirkt nicht - genau deshalb ist das ein eigener Schalter und
  ## nicht derselbe wie fuer die Simulation.
  if enabled != 0: initAdamTables()
  init_quant_adam = (enabled != 0)

proc cortex_get_quant_adam_memory*(s: ptr CortexState): cint {.ffi.} =
  if s.isNil: -1 else: s.quantAdam

proc cortex_get_i8_quant_adam*(): cint {.ffi.} =
  i8_quant_adam

proc quantDequantAdamBlock(dat: ptr FloatArray, off, n: int, signed: bool) =
  ## Quantisiert [off, off+n) logarithmisch auf 8 Bit und schreibt den
  ## dequantisierten Wert zurueck - simuliert damit genau den
  ## Praezisionsverlust des spaeteren int8-Formats.
  ## Zweite Verteidigungslinie gegen den nil-Fall (siehe Aufrufstelle).
  if dat.isNil: return
  var b = 0
  while b < n:
    let bn = min(ADAM_Q_BLOCK, n - b)
    var mx: cfloat = 0.0
    for i in 0 ..< bn:
      let a = abs(dat[off + b + i])
      if a > mx: mx = a
    if mx > 0.0:
      let lo = mx / ADAM_Q_DYN
      let lgr = ln(ADAM_Q_DYN)
      let steps = (if signed: 126.0 else: 254.0)
      let qmax = (if signed: 127 else: 255)
      for i in 0 ..< bn:
        let x = dat[off + b + i]
        let ax = abs(x)
        if ax <= lo:
          # Unterhalb der darstellbaren Dynamik: auf 0. Bei log-Quantisierung
          # betrifft das laut Messung 0,0% der Werte - der Zweig ist die
          # Sicherheitsschranke, nicht der Normalfall.
          dat[off + b + i] = 0.0
        else:
          var q = 1 + int(round(steps * ln(ax / lo) / lgr))
          if q < 1: q = 1
          elif q > qmax: q = qmax
          let mag = mx * (if signed: adamTabM[q] else: adamTabV[q])
          dat[off + b + i] = (if x < 0.0: -mag else: mag)
    b += bn

var fbMissingSeen = false
var fbMissingWarned = false

# BEFUND 2026-09-02 (Engine-Pruefung): der Pfad "quantisierte Momente UND
# Zeile laenger als MAX_ADAM_ROW" hat die Momente gelesen, aktualisiert und
# NIE ZURUECKGESCHRIEBEN - das Rueckschreiben haengt an `useRowBuf`, der
# Float-Zweig an `not useQM`; bei useQM und ueberlanger Zeile traf keiner von
# beiden zu. Adam waere dort stillschweigend zu reinem SGD degeneriert. Die
# Warnung behauptete dazu "Momente bleiben fuer diesen Tensor float", was
# nicht stimmen KANN: im Speicherumbau sind m/v leer, es gibt kein float, auf
# das man zurueckfallen koennte.
#
# Die Ursache war eine reine STACK-Grenze, keine fachliche: array[32768] auf
# dem Stack ist bereits 128 KB, zweimal 256 KB. Deshalb hier ein Ausweichpuffer
# auf dem Heap statt einer stillen Falschrechnung. Er waechst nur, nie
# schrumpfend, und wird zwischen Aufrufen wiederverwendet - eine Allokation je
# Groessenwechsel, nicht je Zeile.
#
# SERIELL: derselbe Puffer fuer alle Zeilen ist zulaessig, weil
# applyGlobalAdamUpdateI8() zeilenweise seriell aufruft (kein `||`). Wuerde das
# je parallel, muesste dieser Puffer thread-lokal segmentiert werden - wie
# i8_dscratch in allocI8BackwardScratch().
var adamBigM: ptr FloatArray = nil
var adamBigV: ptr FloatArray = nil
var adamBigCap = 0

proc ensureAdamBigRow(cols: int) =
  ## Stellt sicher, dass die Ausweichpuffer mindestens `cols` Elemente fassen.
  if cols <= adamBigCap: return
  if not adamBigM.isNil: deallocShared(adamBigM)
  if not adamBigV.isNil: deallocShared(adamBigV)
  adamBigM = cast[ptr FloatArray](allocShared0(cols * sizeof(cfloat)))
  adamBigV = cast[ptr FloatArray](allocShared0(cols * sizeof(cfloat)))
  adamBigCap = cols
  stderr.writeLine("[cortex] INFO: Adam-Zeilenpuffer auf Heap ausgewichen (",
                   $cols, " Spalten > MAX_ADAM_ROW ", $MAX_ADAM_ROW, ").")

# ---- REST-16 Messkopie (patch_rest.py) ----
# SNAI_I8_REST: Rundungsrest der int8-Gewichte. HAUPTBAUM: Vorgabe 32 (float32-Rest, Rechnung wie vor dem Port).
# sr = kein float32-Rest, Gewichte stochastisch gerundet (Vorgabe nur in multi_stack)
# (spart auf der Karte 4 B/Param). Gemessen gegen 32 (float32-Rest wie vorher): Messbuch snai/multistack-rest-16,
# -rest-2048, -rest-2048vk, -sr-klein, -rest-4096 (e572), -rest-2048L4 (e592): Gleichstand, Nachteil waechst mit
# der Tiefe nicht. 16/8/8h sind Messmodi ohne eigene Aussage (e552), 0 ist die Rot-Probe (lernt nicht).
var restModus = -1          # -1 ungelesen, 32, 16, 8, 9 = 8h (Code ueber +-1/2 Stufe), 1 = sr, 0 = aus
var restRot = 0
var restTeleN = 1000
var restTeleAktiv = false
var restLock: Lock
var restSkTab: seq[(pointer, ptr FloatArray)]
var restSkalaFehl, restAuflFehl, restUnter128, restAdamN, restWdN: int
var restWdSum: float
var restHist: array[5, int]
proc restLies() =
  initLock(restLock)
  let w = getEnv("SNAI_I8_REST")
  case w
  of "", "32": restModus = 32   # Hauptbaum: Vorgabe 32 = float32-Rest wie bisher (sr nur auf Anforderung, festgelegt 11.11.)
  of "16": restModus = 16
  of "8": restModus = 8
  of "8h": restModus = 9
  of "sr": restModus = 1   # multi_stack-Vorgabe sr, im Hauptbaum nur mit SNAI_I8_REST=sr
  of "0": restModus = 0
  else:
    stderr.writeLine("SNAI_I8_REST='", w, "' ungueltig (32, 16, 8, sr, 0) - Abbruch")
    quit(1)
  let r = getEnv("SNAI_I8_REST_ROT")
  restRot = (if r.len > 0: parseInt(r) else: 0)
  let t = getEnv("SNAI_I8_REST_TELE")
  restTeleN = (if t.len > 0: parseInt(t) else: 1000)
  echo "  > [REST] Engine: Modus ", (if restModus == 1: "sr" elif restModus == 9: "8h" else: $restModus), " Rot ", restRot, " Tele ", restTeleN
  flushFile(stdout)
proc restSrU(x: cfloat, row, c: int): float {.inline.} =
  var h = uint64(cast[uint32](x)) xor (uint64(row) shl 32) xor (uint64(c) shl 12) xor srSalt
  h = h xor 0xA0761D6478BD642F'u64
  h = h + 0x9E3779B97F4A7C15'u64
  h = (h xor (h shr 30)) * 0xBF58476D1CE4E5B9'u64
  h = (h xor (h shr 27)) * 0x94D049BB133111EB'u64
  h = h xor (h shr 31)
  float(h shr 11) * (1.0 / 9007199254740992.0)
proc restSichere(res: Matrix) =
  ## Seitentabelle der Speicherskalen je Rest-Matrix (nur Modus 16/8). Seriell vor den Zeilen gerufen.
  if restModus != 16 and restModus != 8 and restModus != 9: return
  if res.data.isNil: return
  let pk = cast[pointer](res.data)
  for e in restSkTab:
    if e[0] == pk: return
  restSkTab.add((pk, cast[ptr FloatArray](allocShared0(max(1, res.rows.int) * sizeof(cfloat)))))
proc restSkalen(res: Matrix): ptr FloatArray =
  let pk = cast[pointer](res.data)
  for i in countdown(restSkTab.len - 1, 0):
    if restSkTab[i][0] == pk: return restSkTab[i][1]
  nil
proc restTeleDruck(t: int) =
  if not restTeleAktiv: return
  let n = max(1, restAdamN)
  var hs = 0
  for k in 0 ..< 5: hs += restHist[k]
  let hn = max(1, hs)
  echo "  > [REST] t=", t, " modus=", (if restModus == 1: "sr" elif restModus == 9: "8h" else: $restModus),
       " unter128=", restUnter128.float / n.float,
       " hist=", restHist[0].float / hn.float, "/", restHist[1].float / hn.float, "/", restHist[2].float / hn.float,
       "/", restHist[3].float / hn.float, "/", restHist[4].float / hn.float,
       " wdStufen=", restWdSum / max(1, restWdN).float,
       " n=", restAdamN, " skalaFehl=", restSkalaFehl, " auflFehl=", restAuflFehl
  flushFile(stdout)
  restUnter128 = 0; restAdamN = 0; restWdN = 0; restWdSum = 0.0
  for k in 0 ..< 5: restHist[k] = 0
# ---- Ende REST-16 Zustand ----

proc adamRowFloatI8(qw: QMatrix, m, v, g, res: Matrix, row: int,
                    lr, b1, b2, b1t, b2t, gradScale: cfloat,
                    isSparse: bool, boundR, boundC: cint, wd: cfloat,
                    mq, vq: ptr QMoment = nil) =
  ## `mq`/`vq` gesetzt => die Momente liegen als 8-Bit-QMoment vor (SCHRITT 3,
  ## Speicherumbau); m/v sind dann leer. Gelesen wird in einen Zeilenpuffer,
  ## gerechnet unveraendert in float, am Ende die Zeile requantisiert.
  let cols = qw.cols.int
  let off = row * cols
  let qscale = qw.scale[row]
  var maxAbs: cfloat = 0.0
  let useQM = not mq.isNil and not vq.isNil
  # Zeilenpuffer fuer den quantisierten Pfad. Lokale Variablen, also je
  # Thread eigen: applyGlobalAdamUpdateI8 ruft die Zeilen seit 2026-10-14
  # PARALLEL auf (`||`). Geteilt ist nur adamBigM fuer cols > MAX_ADAM_ROW -
  # solche Matrizen laufen dort weiterhin seriell.
  var adamRowM {.noinit.}: array[MAX_ADAM_ROW, cfloat]
  var adamRowV {.noinit.}: array[MAX_ADAM_ROW, cfloat]
  # useRowBuf haengt NICHT mehr an der Zeilenlaenge: liegen quantisierte
  # Momente vor, gibt es immer einen Puffer - kurze Zeilen auf dem Stack,
  # lange auf dem Heap (siehe ensureAdamBigRow). Vorher fiel der lange Fall
  # durch alle Zweige und verwarf die Momente.
  let useRowBuf = useQM
  var mBuf, vBuf: ptr FloatArray = nil
  if useRowBuf:
    if cols <= MAX_ADAM_ROW:
      mBuf = cast[ptr FloatArray](addr adamRowM[0])
      vBuf = cast[ptr FloatArray](addr adamRowV[0])
    else:
      ensureAdamBigRow(cols)
      mBuf = adamBigM
      vBuf = adamBigV
  # FEHLER 2026-08-25: der Zeilenpuffer wird unten KOMPLETT zurueckgeschrieben,
  # beschrieben wurde er aber nur fuer Elemente, deren Adam-Zweig lief. Alle
  # uebersprungenen Elemente (bei den Embeddings via `isSparse` fast alle, denn
  # nur die Token DES BATCHES haben Gradient) erbten damit die Momente der
  # ZULETZT bearbeiteten Zeile. Der float-Pfad kennt das Problem nicht - dort
  # bleiben m.data/v.data bei einem Auslasser einfach unberuehrt.
  # Deshalb: Puffer vorab mit dem IST-Zustand fuellen.
  # (Gegenprobe: diagnose/verify_adam_row_buffer.php - ein Schritt mit drei
  # Token verschmutzte 8184 von 8192 Embedding-Zeilen.)
  var rowTouched = false
  if useRowBuf:
    for c in 0 ..< cols:
      mBuf[c] = qmomGet(mq[], row, c, true)
      vBuf[c] = qmomGet(vq[], row, c, false)
  # Rueckfuehrung nur wenn eingeschaltet UND der Puffer existiert (bei reiner
  # Inferenz wird er nicht allokiert - dort gibt es auch keine Adam-Schritte).
  let useFb = i8_error_feedback != 0 and not res.data.isNil and restModus != 1 and restModus != 0
  # Ein fehlender Rest-Puffer hat den Mechanismus frueher lautlos abgeschaltet
  # und dabei einen Qualitaetsverlust verursacht, den erst ein Produktivlauf
  # sichtbar machte. Jetzt meldet er sich (siehe allocI8ErrorFeedback).
  if i8_error_feedback != 0 and res.data.isNil: fbMissingSeen = true
  # REST-16: Codemodus, Faktoren, Seitentabelle, lokale Zaehler
  let rCode = useFb and (restModus == 16 or restModus == 8 or restModus == 9)
  let rFak: cfloat = (if restModus == 16: 32767.0 elif restModus == 9: 254.0 else: 127.0)
  let rKInv: cfloat = (if restModus == 16: (1.0 / 32767.0).cfloat elif restModus == 9: (1.0 / 254.0).cfloat else: (1.0 / 127.0).cfloat)
  let rFakEnc: cfloat = (if restRot == 2: (if restModus == 16: 16383.0 elif restModus == 9: 127.0 else: 63.0) else: rFak)
  let rSk = (if rCode: restSkalen(res) else: nil)
  let decScale = (if restRot == 1 and rCode: qw.scale[(row + 1) mod qw.rows.int] else: qscale)
  var lSkF, lAuF, lU128, lN, lWdN: int
  var lWd: float
  var lH: array[5, int]

  # Durchgang 1: Adam in Float, Ergebnis in g zwischenspeichern
  for c in 0 ..< cols:
    let i = off + c
    let wf0 = qw.data[i].cfloat * qscale
    var grad = g.data[i] / gradScale
    var wf = wf0
    if gradScale != 0.0 and not (grad.isNaN or grad > 9999.0 or grad < -9999.0):
      if not (isSparse and abs(grad) < 1e-8):
        var mCur, vCur: cfloat
        if useRowBuf:
          mCur = mBuf[c]          # oben aus mq/vq vorgeladen
          vCur = vBuf[c]
        else:
          mCur = m.data[i]
          vCur = v.data[i]
        mCur = b1 * mCur + (1.0 - b1) * grad
        vCur = b2 * vCur + (1.0 - b2) * grad * grad
        rowTouched = true
        if useRowBuf:
          # Zwischenspeichern im Gradientenpuffer waere hier falsch (g wird
          # unten weiterverwendet) - deshalb direkt in die Zeilenpuffer.
          mBuf[c] = mCur
          vBuf[c] = vCur
        else:
          m.data[i] = mCur
          v.data[i] = vCur
        let m_hat = mCur / b1t
        let v_hat = vCur / b2t
        let boost = elemBoost(i.cint, qw.cols, boundR, boundC)
        wf = wf0 - (lr * boost) * m_hat / (sqrt(v_hat) + 1e-8)
        if wd > 0.0: wf -= lr * wd * wf0
        if restTeleAktiv:
          inc lN
          if abs(wf - wf0) < qscale * (1.0 / 128.0): inc lU128
          if wd > 0.0 and qscale > 0.0:
            lWd += float(lr * wd * abs(wf0) / qscale); inc lWdN
    # Der beim letzten Requantisieren abgeschnittene Rest kommt hier zurueck -
    # das ist der eigentliche Kern der Massnahme. wf0 traegt bereits den
    # GERUNDETEN Wert; ohne diese Zeile ginge die Differenz endgueltig
    # verloren, statt beim naechsten Mal beruecksichtigt zu werden.
    if useFb:
      if not rCode:
        wf += res.data[i]
      else:
        let cd = res.data[i]
        if cd != 0.0 and not rSk.isNil and cast[uint32](decScale) != cast[uint32](rSk[row]): inc lSkF
        wf += (cd * rKInv) * decScale
    g.data[i] = wf
    let a = abs(wf)
    if a > maxAbs: maxAbs = a

  # SCHRITT 3 (Speicherumbau): die aktualisierte Zeile zurueck in 8 Bit.
  # Nur wenn sich ueberhaupt ein Moment geaendert hat. Das ist nicht bloss
  # schneller (qmomStoreRow kostet ein ln() je Element, und bei den Embeddings
  # ist die grosse Mehrheit der Zeilen je Schritt unberuehrt), sondern auch
  # genauer: ein Speichern ohne Aenderung wuerde die bereits quantisierten
  # Werte ein zweites Mal runden und die Momente so Schritt fuer Schritt
  # verschieben.
  if useRowBuf and rowTouched:
    qmomStoreRow(mq[], row, mBuf, 0, true)
    qmomStoreRow(vq[], row, vBuf, 0, false)

  # SCHRITT 3: Momente auf 8-Bit-Log-Auflösung bringen (Simulation des
  # spaeteren int8-Formats, siehe Blockkommentar oben). Muss NACH dem
  # m/v-Update und VOR dem naechsten Schritt passieren - dann sieht der
  # naechste Adam-Schritt genau die Werte, die er im echten Format sehen wuerde.
  # WICHTIG: nur wenn die Momente NICHT bereits quantisiert gespeichert sind.
  # Sonst greift die Simulation auf m.data/v.data zu, die beim Speicherumbau
  # legitim nil sind -> SIGSEGV. Genau diese Kombination (Simulation UND
  # Umbau gleichzeitig) entsteht erst durch die Pipeline-Anbindung; isoliert
  # war immer nur eines von beidem aktiv, deshalb fiel es vorher nicht auf.
  # Der Umbau ist ohnehin die genauere Variante - die Simulation waere hier
  # doppelt gemoppelt.
  if i8_quant_adam != 0 and not useQM:
    quantDequantAdamBlock(m.data, off, cols, true)
    quantDequantAdamBlock(v.data, off, cols, false)

  # Durchgang 2: Zeile mit frischer Skala requantisieren, Rest sichern, g nullen
  let newScale = if maxAbs > 0.0: maxAbs / 127.0 else: qscale
  qw.scale[row] = newScale
  let inv = 1.0.cfloat / newScale
  if rCode and not rSk.isNil: rSk[row] = newScale
  for c in 0 ..< cols:
    let i = off + c
    let target = g.data[i]
    var q = (if restModus == 1: floor(target * inv + restSrU(target, row, c).cfloat).int else: round(target * inv).int)
    if q > 127: q = 127
    elif q < -128: q = -128
    qw.data[i] = q.int8
    if useFb:
      # Regulaer ist |Rest| <= newScale/2. Groesser wird er nur, wenn oben
      # geklemmt wurde (|q| am Gitterrand) - dann waechst er ohne Deckel bei
      # jedem Schritt weiter und wuerde die Zeile langfristig sprengen.
      # Deshalb hart auf eine LSB-Breite begrenzen.
      var e = target - q.cfloat * newScale
      if e > newScale: e = newScale
      elif e < -newScale: e = -newScale
      if restTeleAktiv and newScale > 0.0:
        let a = abs(e) / newScale
        if a < 0.125: inc lH[0]
        elif a < 0.25: inc lH[1]
        elif a < 0.5: inc lH[2]
        elif a < 1.0: inc lH[3]
        else: inc lH[4]
      if not rCode:
        res.data[i] = e
      else:
        let rel = e * inv
        var cd: int
        if restModus == 16: cd = round(rel * rFakEnc).int
        else: cd = floor(rel * rFakEnc + restSrU(e, row, c).cfloat).int
        let lim = (if restModus == 16: 32767 else: 127)
        if cd > lim: cd = lim
        elif cd < -lim: cd = -lim
        res.data[i] = cd.cfloat
        let dec = (cd.cfloat * rKInv) * newScale
        let tol = (if restModus == 16: newScale * (0.5 / 32767.0) elif restModus == 9: newScale * (1.0 / 254.0) else: newScale * (1.0 / 127.0)) * 1.001
        if abs(dec - e) > tol: inc lAuF
    g.data[i] = 0.0
  if lSkF + lAuF + lN + lWdN > 0 or (restTeleAktiv and (lH[0] + lH[1] + lH[2] + lH[3] + lH[4]) > 0):
    acquire(restLock)
    restSkalaFehl += lSkF; restAuflFehl += lAuF; restUnter128 += lU128; restAdamN += lN
    restWdN += lWdN; restWdSum += lWd
    for k in 0 ..< 5: restHist[k] += lH[k]
    release(restLock)

# ==============================================================================
# LoRA - Rechenkerne
# ------------------------------------------------------------------------------
#   Forward   out[p,r] += s * sum_k B[r,k] * h[p,k]      mit h[p,k] = sum_c A[k,c]*x[p,c]
#   Backward  dh[p,k]   = s * sum_r B[r,k] * d_out[p,r]
#             d_in[p,c] += sum_k A[k,c] * dh[p,k]
#             g_B[r,k]  += s * sum_p d_out[p,r] * h[p,k]
#             g_A[k,c]  += sum_p dh[p,k] * x[p,c]
# dh traegt s bereits - deshalb steht s bei g_A nicht noch einmal.
#
# Alles in FP32 und ausserhalb jedes QMatrix-Pfads (siehe Feldkommentar oben).
# Die Basis-Matmul laeuft unveraendert davor; diese Prozeduren ADDIEREN nur.
# ==============================================================================

proc loraHPtr(s: ptr CortexState, l, slot: int): ptr FloatArray {.inline.} =
  cast[ptr FloatArray](addr s.lora_h[loraIdx(s, l, slot) * s.ctxSize.int * s.loraRank.int])

proc loraForwardVec(s: ptr CortexState, l, slot: int, x, o: ptr FloatArray) =
  ## Einzelvektor-Fassung fuer cortex_forward_i8(). Benutzt lora_dh als
  ## Rang-Scratch - das ist kollisionsfrei, weil der reine Forward-Pfad keinen
  ## Backward hat, der denselben Puffer braeuchte.
  if not loraSlotOn(s, slot): return
  let i = loraIdx(s, l, slot)
  let A = s.lora_a[i]
  let B = s.lora_b[i]
  let rk = s.loraRank.int
  let cols = A.cols.int
  let rows = B.rows.int
  let sc = loraScale(s)
  let h = s.lora_dh
  for k in 0 ..< rk:
    var acc: cfloat = 0.0
    let ao = k * cols
    for c in 0 ..< cols: acc += A.data[ao + c] * x[c]
    h[k] = acc
  for r in 0 ..< rows:
    var acc: cfloat = 0.0
    let bo = r * rk
    for k in 0 ..< rk: acc += B.data[bo + k] * h[k]
    o[r] += sc * acc

proc loraForwardBatch(s: ptr CortexState, l, slot: int,
                      x_all, o_all: ptr FloatArray, act: int) =
  ## Gebuendelte Fassung. Schreibt h nach lora_h - der Backward liest es dort.
  if not loraSlotOn(s, slot): return
  let i = loraIdx(s, l, slot)
  let A = s.lora_a[i]
  let B = s.lora_b[i]
  let rk = s.loraRank.int
  let cols = A.cols.int
  let rows = B.rows.int
  let sc = loraScale(s)
  let h = loraHPtr(s, l, slot)
  {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
  # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
  for p in 0 || (act - 1):
    let xo = p * cols
    let ho = p * rk
    for k in 0 ..< rk:
      var acc: cfloat = 0.0
      let ao = k * cols
      for c in 0 ..< cols: acc += A.data[ao + c] * x_all[xo + c]
      h[ho + k] = acc
    let oo = p * rows
    for r in 0 ..< rows:
      var acc: cfloat = 0.0
      let bo = r * rk
      for k in 0 ..< rk: acc += B.data[bo + k] * h[ho + k]
      o_all[oo + r] += sc * acc
  {.pop.}

proc loraBackwardBatch(s: ptr CortexState, l, slot: int,
                       d_out_all, x_all, d_in_all: ptr FloatArray, act: int) =
  ## Addiert den Adapter-Anteil auf d_in und akkumuliert g_A/g_B.
  ## d_in_all darf nil sein - dann wird der Eingangsgradient nicht angefasst
  ## (fuer den Fall, dass der Aufrufer ihn gar nicht braucht).
  if not loraSlotOn(s, slot): return
  let i = loraIdx(s, l, slot)
  let A = s.lora_a[i]
  let B = s.lora_b[i]
  let gA = s.g_lora_a[i]
  let gB = s.g_lora_b[i]
  let rk = s.loraRank.int
  let cols = A.cols.int
  let rows = B.rows.int
  let sc = loraScale(s)
  let h = loraHPtr(s, l, slot)
  let dh = s.lora_dh

  # dh und d_in: Position fuer Position, parallelisierbar (kein Schreibkonflikt).
  {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
  # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
  for p in 0 || (act - 1):
    let dho = p * rk
    let doo = p * rows
    for k in 0 ..< rk:
      var acc: cfloat = 0.0
      for r in 0 ..< rows: acc += B.data[r * rk + k] * d_out_all[doo + r]
      dh[dho + k] = sc * acc
    if not d_in_all.isNil:
      let xo = p * cols
      for c in 0 ..< cols:
        var acc: cfloat = 0.0
        for k in 0 ..< rk: acc += A.data[k * cols + c] * dh[dho + k]
        d_in_all[xo + c] += acc
  {.pop.}

  # g_B und g_A summieren UEBER die Positionen - deshalb bewusst seriell ueber
  # p und parallel ueber die Ausgabedimension, nicht umgekehrt. Andersherum
  # waere es ein Schreibkonflikt auf denselben Gradienten.
  {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
  # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
  for r in 0 || (rows - 1):
    let bo = r * rk
    for k in 0 ..< rk:
      var acc: cfloat = 0.0
      for p in 0 ..< act: acc += d_out_all[p * rows + r] * h[p * rk + k]
      gB.data[bo + k] += sc * acc
  {.pop.}
  {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
  # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
  for k in 0 || (rk - 1):
    let ao = k * cols
    for c in 0 ..< cols:
      var acc: cfloat = 0.0
      for p in 0 ..< act: acc += dh[p * rk + k] * x_all[p * cols + c]
      gA.data[ao + c] += acc
  {.pop.}

proc resM(arr: ptr MatrixArray, l: int): Matrix {.inline.} =
  ## Rest-Matrix eines Layers - liefert eine leere Matrix (data == nil), wenn
  ## die Fehler-Rueckfuehrung nicht allokiert ist (reine Inferenz). adamRowFloatI8
  ## prueft darauf und schaltet die Rueckfuehrung dann ab.
  if arr.isNil: result else: arr[l]

# Parallele Adam-Zeilenschleife (2026-10-14): die Argumente einer Zeile als
# Verbund, damit der Aufruf im OpenMP-Block ueber ein reines C-Symbol laufen
# kann. Ein direkter Aufruf einer Nim-Prozedur setzt dort eine
# Fehlerpruefung mit `goto`, die GCC in einem omp-Block ablehnt.
# Feldnamen mit a-Praefix: die Vorlagen upM/upEmb haben Parameter namens
# qw/m/v/g/res, die sonst die Feldnamen im Konstruktor ersetzen wuerden.
type AdamRowArgs = object
  aQw: QMatrix
  aM, aV, aG, aRes: Matrix
  aLr, aB1, aB2, aB1t, aB2t, aGs: cfloat
  aSp: bool
  aBR, aBC: cint
  aWd: cfloat
  aMq, aVq: ptr QMoment
proc snaiAdamRowPar(a: ptr AdamRowArgs, row: int) {.exportc: "snai_adam_row_par", cdecl.} =
  adamRowFloatI8(a.aQw, a.aM, a.aV, a.aG, a.aRes, row, a.aLr, a.aB1, a.aB2, a.aB1t, a.aB2t, a.aGs,
                 a.aSp, a.aBR, a.aBC, a.aWd, a.aMq, a.aVq)
proc snaiAdamRowParC(a: ptr AdamRowArgs, row: int) {.importc: "snai_adam_row_par", cdecl.}

# GPU-Adam (2026-10-14): Stellrad SNAI_I8_GPU_ADAM, Vorgabe aus. Messungen in
# docs/VERGLEICH_LITERATUR_KOPIEREN.md 6ad/6af (bitgleich zur CPU; 256/16 im
# Textrezept bei 1 Thread: Segment 553 -> 274 s).
var gaMode = -1
var gaRot = 0
var gaWarned = false
proc c_getenv_ga(name: cstring): cstring {.importc: "getenv", header: "<stdlib.h>".}
proc gpuAdamMode(): int =
  if gaMode < 0:
    let e = c_getenv_ga("SNAI_I8_GPU_ADAM")
    gaMode = 0
    if not e.isNil:
      if e[0] == '1': gaMode = 1
      elif e[0] == '2': gaMode = 2
    let r = c_getenv_ga("SNAI_I8_GPU_ADAM_ROT")
    if not r.isNil and r[0] == '1': gaRot = 1
    if gaMode > 0: stderr.writeLine("[GPU-ADAM] Modus ", gaMode, (if gaRot == 1: " ROT-PROBE" else: ""))
  gaMode
proc gaWarn(why: string) =
  if not gaWarned:
    stderr.writeLine("⚠️  [GPU-ADAM] SNAI_I8_GPU_ADAM=", gaMode, " gesetzt, greift aber nicht (", why,
                     ") - der Adam laeuft auf der CPU.")
    gaWarned = true
proc gaReg(p: pointer) =
  if p notin gaRegs: gaRegs.add(p)
proc gaOwnReg(p: pointer) =
  if p notin gaOwn and p notin gaRegs: gaOwn.add(p)
# RESIDENT (seit 2026-11-11, e624/e625): Zaehler, Ausgabe in gaStats.
var resModeV = -1
var resSteps, resFallbacks, resCheckSteps, resCheckBad = 0
var resBwSteps, resBwCheckBad = 0
proc gaStats(): string =
  if resModeV > 0:
    try: stderr.writeLine("[RESIDENT] Vorwaerts auf der Karte ", resSteps, ", Rueckfaelle ", resFallbacks,
                          ", CHECK-Schritte ", resCheckSteps, ", davon abweichend ", resCheckBad,
                          " | rueckwaerts auf der Karte ", resBwSteps, ", CHECK abweichend ", resBwCheckBad)
    except IOError: discard
  if gdV > 0:
    try: stderr.writeLine("[GRAD-DEV] geholt ", gdPulls, ", hergerichtet ", gdPreps, ", Adam ohne Hochladen ", gdAdams)
    except IOError: discard
    if not pCudaEarlyStats.isNil:
      var es: array[2, uint64]
      pCudaEarlyStats(addr es[0])
      try: stderr.writeLine("[GRAD-EARLY] angestossen ", es[0], ", genutzt ", es[1])
      except IOError: discard
  if pCudaQaStats.isNil: return ""
  var qs: array[4, cdouble]
  pCudaQaStats(addr qs[0])
  " (ms hoch " & $int(qs[0]) & ", Kern " & $int(qs[1]) & ", runter " & $int(qs[2]) & ")"
proc gdPrep(s: ptr CortexState) =
  ## GRAD-DEV: Kartenpuffer der Schichtgradienten herrichten (zusammenfuehren + Clip wie auf dem Host).
  gdReady.clear()
  if gradDev() > 0 and gpu_backend == gbCuda and not pCudaGradPrep.isNil and not pCudaAdamGDev.isNil and
     s.baseOptFreed == 0 and not lastLayerOnly(s) and not loraOn(s):
    let rot: cint = (if gradDev() == 2: 1 else: 0)
    template eins(qw: QMatrix, g: Matrix) =
      if useGpuQMat(qw) and gdHostZero.getOrDefault(cast[pointer](g.data), false):
        if pCudaGradPrep(cast[pointer](g.data), gradBytes(g), gdClipKind.cint, gdClipScale, rot) == 0:
          gdReady[cast[pointer](g.data)] = true
          inc gdPreps
    for l in 0 ..< s.numLayers:
      eins(s.w_q_q8[l], s.g_w_q[l]); eins(s.w_k_q8[l], s.g_w_k[l]); eins(s.w_v_q8[l], s.g_w_v[l])
      eins(s.w_o_q8[l], s.g_w_o[l]); eins(s.w_up_q8[l], s.g_w_up[l]); eins(s.w_down_q8[l], s.g_w_down[l])
  gdHostZero.clear()

proc gpuAdamRows(qw: QMatrix, g, res: Matrix, lr, b1, b2, b1t, b2t, gscale: cfloat, isSparse: bool,
                 boundR, boundC: cint, wd: cfloat, mq, vq: ptr QMoment): bool =
  ## true = diese Matrix ist auf der Karte gerechnet (Gewichte, Skalen auf dem
  ## Host aktuell, g genullt); false = der Aufrufer rechnet auf der CPU.
  let mode = gpuAdamMode()
  if mode == 0: return false
  # OCL-ADAM (2026-11-12): unter OpenCL derselbe Kern, ohne GRAD-DEV/OVERLAP.
  let oclA = gpu_backend == gbOpenCL and gpu_initialized
  if not oclA and (gpu_backend != gbCuda or not gpu_initialized):
    gaWarn("kein CUDA- oder OpenCL-Backend aktiv"); return false
  if oclA and ocl_adam_q_ready() == 0:
    gaWarn("OpenCL-Geraet ohne double-Kern, siehe [OCL-ADAM]"); return false
  if not oclA and pCudaAdamRowQI8.isNil:
    gaWarn("libcortex_cuda.so ohne cuda_adamRowQI8"); return false
  if mq.isNil or vq.isNil or mq.data.isNil or vq.data.isNil:
    gaWarn("Momente nicht als QMoment (SNAI_INT8_FULL=1 noetig)"); return false
  if not oclA and i8_mom_sr > 0 and pCudaAdamRowQI8SR.isNil:
    gaWarn("libcortex_cuda.so ohne cuda_adamRowQI8SR - die Karte runde nicht zufaellig"); return false
  # REST-16 Kartenseite: Rest wie im CPU-Pfad (sr/0 ohne Rest), Codes nur auf der Karte.
  if restModus < 0: restLies()
  if not oclA and (pCudaAdamRowQI8Rest.isNil or pCudaRestStats.isNil):
    stderr.writeLine("[REST] libcortex_cuda.so ohne cuda_adamRowQI8Rest - Abbruch"); quit(1)
  let useFb = i8_error_feedback != 0 and not res.data.isNil and restModus != 1 and restModus != 0
  let rCodeG = useFb and (restModus == 16 or restModus == 8 or restModus == 9)
  if i8_error_feedback != 0 and res.data.isNil: fbMissingSeen = true
  let lrX = (if gaRot == 1: lr * 1.0001'f32 else: lr)
  # SR (2026-10-19): mit dem SR-Symbol rechnet die Karte dieselbe Rundung wie qmomStoreRow (Maske, Salz srSalt).
  let gdOn = gdReady.getOrDefault(cast[pointer](g.data), false)
  if gdOn:
    pCudaAdamGDev(1)
    inc gdAdams
  let rc = if oclA:
             ocl_adamRowQI8Rest(addr qw.data[0], addr qw.scale[0], addr mq.data[0], addr mq.scale[0],
                           addr vq.data[0], addr vq.scale[0], addr g.data[0],
                           (if useFb: addr res.data[0] else: nil), addr adamTabM[0], addr adamTabV[0],
                           ln(ADAM_Q_DYN).cdouble, lrX, b1, b2, b1t, b2t, gscale, qw.rows, qw.cols,
                           (if isSparse: 1.cint else: 0.cint), boundR, boundC, growth_boost, wd,
                           (if useFb: 1.cint else: 0.cint), mode.cint, max(i8_mom_sr, 0.cint), srSalt,
                           restModus.cint, restRot.cint, (if restTeleAktiv: 1.cint else: 0.cint))
           elif true:
             pCudaAdamRowQI8Rest(addr qw.data[0], addr qw.scale[0], addr mq.data[0], addr mq.scale[0],
                           addr vq.data[0], addr vq.scale[0], addr g.data[0],
                           (if useFb: addr res.data[0] else: nil), addr adamTabM[0], addr adamTabV[0],
                           ln(ADAM_Q_DYN).cdouble, lrX, b1, b2, b1t, b2t, gscale, qw.rows, qw.cols,
                           (if isSparse: 1.cint else: 0.cint), boundR, boundC, growth_boost, wd,
                           (if useFb: 1.cint else: 0.cint), mode.cint, max(i8_mom_sr, 0.cint), srSalt,
                           restModus.cint, restRot.cint, (if restTeleAktiv: 1.cint else: 0.cint))
           else:
             pCudaAdamRowQI8(addr qw.data[0], addr qw.scale[0], addr mq.data[0], addr mq.scale[0],
                           addr vq.data[0], addr vq.scale[0], addr g.data[0],
                           (if useFb: addr res.data[0] else: nil), addr adamTabM[0], addr adamTabV[0],
                           ln(ADAM_Q_DYN).cdouble, lrX, b1, b2, b1t, b2t, gscale, qw.rows, qw.cols,
                           (if isSparse: 1.cint else: 0.cint), boundR, boundC, growth_boost, wd,
                           (if useFb: 1.cint else: 0.cint), mode.cint)
  if gdOn: pCudaAdamGDev(0)
  if rc != 1 and rCodeG:
    stderr.writeLine("[REST] Karte lehnte ab, die Rest-Codes liegen nur dort - Abbruch"); quit(1)
  if rc == 1 and restTeleAktiv:
    var rz: array[10, uint64]
    var rw: cdouble
    if oclA: ocl_rest_stats(addr rz[0], addr rw) else: pCudaRestStats(addr rz[0], addr rw)
    restSkalaFehl += rz[0].int; restAuflFehl += rz[1].int; restUnter128 += rz[2].int; restAdamN += rz[3].int
    restWdN += rz[4].int; restWdSum += rw.float
    for kk in 0 ..< 5: restHist[kk] += rz[5 + kk].int
  if rc != 1:
    # Die Karte hat nichts angefasst. Liegen andere Momente nur dort, muss der
    # Host vor dem CPU-Rueckfall wieder massgeblich werden.
    gpuAdamDrop()
    gaWarn("Karte lehnte ab, Pufferfehler - Rueckfall nach Zurueckholen")
    return false
  inc gaCalls
  if gaCalls == 1: stderr.writeLine("[GPU-ADAM] erste Matrix auf der Karte gerechnet (", qw.rows, "x", qw.cols, ")")
  gaOwnReg(addr qw.data[0]); gaOwnReg(addr qw.scale[0])
  if mode == 1:
    gaStale = true
    gaReg(addr mq.data[0]); gaReg(addr mq.scale[0]); gaReg(addr vq.data[0]); gaReg(addr vq.scale[0])
    if useFb and not rCodeG: gaReg(addr res.data[0])
  else:
    gaOwnReg(addr mq.data[0]); gaOwnReg(addr mq.scale[0]); gaOwnReg(addr vq.data[0]); gaOwnReg(addr vq.scale[0])
    if useFb and not rCodeG: gaOwnReg(addr res.data[0])
  true

proc applyGlobalAdamUpdateI8(state: ptr CortexState, lr: cfloat, scale: cfloat) =
  ## INT8-Pendant zu applyGlobalAdamUpdate() - auf der CPU, wahlweise auf der
  ## CUDA-Karte (SNAI_I8_GPU_ADAM, siehe gpuAdamRows). Iteriert zeilenweise, damit jedes Element
  ## die Skala SEINER Zeile fuer die Rundung bekommt. Die Zeilen laufen
  ## parallel (OpenMP); gemessen 2026-10-14 an 512/8: bitgleich, Adam bei
  ## 2 Threads 93,7 -> 63,1 s auf 300 Schritte.
  state.adam_t += 1
  if i8_mom_sr < 0: srLeseUmgebung()
  srSalt = uint64(state.adam_t) * 0xD1B54A32D192ED03'u64
  srInAdam = true
  defer: srInAdam = false
  if restModus < 0: restLies()
  restTeleAktiv = restTeleN > 0 and (state.adam_t mod restTeleN) == 0
  let restT = state.adam_t
  defer: restTeleDruck(restT)
  let b1: cfloat = 0.9
  let b2: cfloat = 0.999
  let b1t = 1.0 - pow(b1, state.adam_t.float32)
  let b2t = 1.0 - pow(b2, state.adam_t.float32)

  let boostActive = growth_old_dim >= 0
  let boundDimGlobal = if boostActive: growth_old_dim else: state.hiddenDim
  # Decay fuer den jeweils naechsten upM/upEmb-Aufruf; nur bei den Embeddings abweichend (wd_embeddings).
  var adamWd = global_weight_decay

  template upM(qw, m, v, g, res, boundR, boundC, mqp, vqp) =
    restSichere(res)
    if i8_float_adam != 0 and gpuAdamRows(qw, g, res, lr, b1, b2, b1t, b2t, scale, false, boundR, boundC, adamWd, mqp, vqp):
      discard   # auf der Karte gerechnet (SNAI_I8_GPU_ADAM)
    elif i8_float_adam != 0 and qw.cols.int <= MAX_ADAM_ROW:
      # Zeilen sind unabhaengig (eigene Skala, eigene Momente, Zeilenpuffer auf
      # dem Stapel des Threads) -> parallel und bitgleich zur seriellen Schleife,
      # bei jeder Threadzahl. Lange Zeilen (> MAX_ADAM_ROW) teilen sich den
      # globalen adamBigM-Puffer und laufen deshalb unten seriell.
      var pA = AdamRowArgs(aQw: qw, aM: m, aV: v, aG: g, aRes: res, aLr: lr, aB1: b1, aB2: b2, aB1t: b1t, aB2t: b2t,
                           aGs: scale, aSp: false, aBR: boundR, aBC: boundC,
                           aWd: adamWd, aMq: mqp, aVq: vqp)
      let pAp = addr pA
      let pRows = qw.rows.int
      {.push checks: off.}
      for r in 0 || (pRows - 1):
        snaiAdamRowParC(pAp, r)
      {.pop.}
    elif i8_float_adam != 0:
      for r in 0 ..< qw.rows.int:
        adamRowFloatI8(qw, m, v, g, res, r, lr, b1, b2, b1t, b2t, scale, false, boundR, boundC, adamWd, mqp, vqp)
    else:
      for r in 0 ..< qw.rows.int:
        let qscale = qw.scale[r]
        let rowOff = r * qw.cols.int
        for c in 0 ..< qw.cols.int:
          let i = rowOff + c
          adamStepI8(addr qw.data[i], qscale, addr m.data[i], addr v.data[i], addr g.data[i], lr, b1, b2, b1t, b2t, scale, false, elemBoost(i.cint, qw.cols, boundR, boundC), adamWd)
  template upEmb(qw, m, v, g, res, boundC, mqp, vqp) =
    restSichere(res)
    if i8_float_adam != 0 and gpuAdamRows(qw, g, res, lr, b1, b2, b1t, b2t, scale, true, qw.rows.cint, boundC, adamWd, mqp, vqp):
      discard   # auf der Karte gerechnet (SNAI_I8_GPU_ADAM)
    elif i8_float_adam != 0 and qw.cols.int <= MAX_ADAM_ROW:
      # Zeilen sind unabhaengig (eigene Skala, eigene Momente, Zeilenpuffer auf
      # dem Stapel des Threads) -> parallel und bitgleich zur seriellen Schleife,
      # bei jeder Threadzahl. Lange Zeilen (> MAX_ADAM_ROW) teilen sich den
      # globalen adamBigM-Puffer und laufen deshalb unten seriell.
      var pA = AdamRowArgs(aQw: qw, aM: m, aV: v, aG: g, aRes: res, aLr: lr, aB1: b1, aB2: b2, aB1t: b1t, aB2t: b2t,
                           aGs: scale, aSp: true, aBR: qw.rows.cint, aBC: boundC,
                           aWd: adamWd, aMq: mqp, aVq: vqp)
      let pAp = addr pA
      let pRows = qw.rows.int
      {.push checks: off.}
      for r in 0 || (pRows - 1):
        snaiAdamRowParC(pAp, r)
      {.pop.}
    elif i8_float_adam != 0:
      for r in 0 ..< qw.rows.int:
        adamRowFloatI8(qw, m, v, g, res, r, lr, b1, b2, b1t, b2t, scale, true, qw.rows.cint, boundC, adamWd, mqp, vqp)
    else:
      for r in 0 ..< qw.rows.int:
        let qscale = qw.scale[r]
        let rowOff = r * qw.cols.int
        for c in 0 ..< qw.cols.int:
          let i = rowOff + c
          adamStepI8(addr qw.data[i], qscale, addr m.data[i], addr v.data[i], addr g.data[i], lr, b1, b2, b1t, b2t, scale, true, elemBoost(i.cint, qw.cols, qw.rows.cint, boundC), adamWd)
  template upA(w, m, v, g, size, boundC) =
    # RMSNorm-Gains bleiben FP32 (Design-Entscheidung #7) - exakt der
    # bestehende adamStep()-Pfad, unveraendert.
    for i in 0 ..< size: adamStep(addr w[i], addr m[i], addr v[i], addr g[i], lr, b1, b2, b1t, b2t, scale, false, elemBoost(i.cint, size, 1.cint, boundC))

  # Zeiger auf das quantisierte Moment - nil, wenn der Speicherumbau nicht
  # aktiv ist (dann rechnet adamRowFloatI8 wie bisher auf den float-Matrizen).
  template qmp(fld): ptr QMoment =
    (if state.quantAdam != 0: addr fld else: nil)
  template qmpL(arr, l): ptr QMoment =
    (if state.quantAdam != 0 and not arr.isNil: addr arr[l] else: nil)

  # SNAI_V7: bei Tying ist das EIN Gewicht und bekommt genau EINEN
  # Adam-Schritt. Der Gradient beider Rollen wurde dafuer bereits in
  # g_embeddings zusammengefuehrt (cortex_train_step_i8, nach pullGradI8).
  #
  # Und zwar ueber upM, nicht upEmb - der Unterschied ist das is_sparse-Flag.
  # upEmb ueberspringt Zeilen mit |grad| < 1e-8 vollstaendig (kein Moment-,
  # kein Weight-Decay); das ist im UNGEBUNDENEN Fall richtig, weil dort nur die
  # Token des Batches ueberhaupt einen Embedding-Gradienten haben. Gebunden
  # traegt jede Zeile zusaetzlich einen Logit-Gradienten, und der ist wegen des
  # Softmax fuer praktisch JEDES Token ungleich null. Die Sparse-Abkuerzung
  # waere damit nicht nur wirkungslos, sondern falsch: sie wuerde bei den
  # wenigen echten Null-Zeilen den Decay unterschlagen, den der ungebundene
  # w_out-Arm sehr wohl bekommt - und genau gegen den vergleichen wir.
  # ---------------------------------------------------------------------------
  # LoRA: bei eingefrorener Basis bekommt NUR A/B einen Adam-Schritt.
  # Eingefroren heisst hier woertlich alles ausser den Adaptern - auch die
  # RMSNorm-Gains. Das ist eine Entscheidung, keine Auslassung: nur so ist die
  # Zahl der trainierbaren Parameter exakt die LoRA-Zahl und der Vergleich
  # gegen die Baseline "nur letzte Schicht" ehrlich. Wer die Gains mittrainiert,
  # misst LoRA plus etwas anderes.
  # ---------------------------------------------------------------------------
  template upLora() =
    loraForEach(state):
      let na = state.lora_a[i].rows.int * state.lora_a[i].cols.int
      for e in 0 ..< na:
        adamStep(addr state.lora_a[i].data[e], addr state.m_lora_a[i].data[e],
                 addr state.v_lora_a[i].data[e], addr state.g_lora_a[i].data[e],
                 lr, b1, b2, b1t, b2t, scale, false, 1.0, global_weight_decay)
      let nb = state.lora_b[i].rows.int * state.lora_b[i].cols.int
      for e in 0 ..< nb:
        adamStep(addr state.lora_b[i].data[e], addr state.m_lora_b[i].data[e],
                 addr state.v_lora_b[i].data[e], addr state.g_lora_b[i].data[e],
                 lr, b1, b2, b1t, b2t, scale, false, 1.0, global_weight_decay)

  if loraOn(state) and state.loraFrozenBase != 0:
    upLora()
    # markQWeightsDirty() bleibt hier bewusst AUS: es hat sich keine einzige
    # INT8-Gewichtszeile geaendert, ein Rueckschrieb ins VRAM waere reine
    # Arbeit ohne Wirkung. Genau das ist ein Teil des LoRA-Gewinns.
    return

  upLora()   # LoRA MIT mittrainierter Basis - eigener Arm, kein Standardfall

  # ARM C: nur die letzten n Schichten. Alles Globale bleibt stehen; die
  # gezaehlte Menge in clipGlobalGradientNorm() ist dieselbe.
  let armC = lastLayerOnly(state)

  if armC:
    for l in 0 ..< state.numLayers:
      if not layerTrainable(state, l.int): continue
      let boundDimC = if boostActive: growth_old_dim else: state.hiddenDim
      let boundFfnC = if boostActive: growth_old_ffn else: state.ffnDim
      upM(state.w_q_q8[l], state.m_w_q[l], state.v_w_q[l], state.g_w_q[l], resM(state.res_w_q, l), boundDimC, boundDimC, qmpL(state.mq_w_q, l), qmpL(state.vq_w_q, l))
      upM(state.w_k_q8[l], state.m_w_k[l], state.v_w_k[l], state.g_w_k[l], resM(state.res_w_k, l), boundDimC, boundDimC, qmpL(state.mq_w_k, l), qmpL(state.vq_w_k, l))
      upM(state.w_v_q8[l], state.m_w_v[l], state.v_w_v[l], state.g_w_v[l], resM(state.res_w_v, l), boundDimC, boundDimC, qmpL(state.mq_w_v, l), qmpL(state.vq_w_v, l))
      upM(state.w_o_q8[l], state.m_w_o[l], state.v_w_o[l], state.g_w_o[l], resM(state.res_w_o, l), boundDimC, boundDimC, qmpL(state.mq_w_o, l), qmpL(state.vq_w_o, l))
      upM(state.w_up_q8[l], state.m_w_up[l], state.v_w_up[l], state.g_w_up[l], resM(state.res_w_up, l), boundFfnC, boundDimC, qmpL(state.mq_w_up, l), qmpL(state.vq_w_up, l))
      upM(state.w_down_q8[l], state.m_w_down[l], state.v_w_down[l], state.g_w_down[l], resM(state.res_w_down, l), boundDimC, boundFfnC, qmpL(state.mq_w_down, l), qmpL(state.vq_w_down, l))
    # Dieselbe Warnung wie im Vollpfad unten - ein frueher return darf eine
    # Diagnose nicht verschlucken (Lehre aus dem res_w_out-Fund vom 2026-08-29).
    if fbMissingSeen and not fbMissingWarned:
      fbMissingWarned = true
      stderr.writeLine("[cortex] WARNUNG: Fehler-Rueckfuehrung ist eingeschaltet, aber es ",
                       "gibt keine Rest-Puffer - sie wirkt NICHT (Arm C).")
    markQWeightsDirty(state)
    return

  if wd_embeddings == 0: adamWd = 0.0
  if state.tiedEmbeddings != 0:
    upM(state.embeddings_q8, state.m_embeddings, state.v_embeddings, state.g_embeddings, state.res_embeddings, state.embeddings_q8.rows.cint, boundDimGlobal, qmp(state.mq_embeddings), qmp(state.vq_embeddings))
    adamWd = global_weight_decay
  else:
    upEmb(state.embeddings_q8, state.m_embeddings, state.v_embeddings, state.g_embeddings, state.res_embeddings, boundDimGlobal, qmp(state.mq_embeddings), qmp(state.vq_embeddings))
    # 2026-10-16: ungebunden faellt auch w_out unter den Schalter (Runde 4: dort starben die Zeilen).
    upM(state.w_out_q8, state.m_w_out, state.v_w_out, state.g_w_out, state.res_w_out, state.w_out_q8.rows.cint, boundDimGlobal, qmp(state.mq_w_out), qmp(state.vq_w_out))
    adamWd = global_weight_decay
  upA(state.rms_final_weight, state.m_rms_final_weight, state.v_rms_final_weight, state.g_rms_final_weight, state.hiddenDim, boundDimGlobal)

  for l in 0 ..< state.numLayers:
    let isNewLayer = boostActive and (l.cint >= growth_old_layers)
    let boundDim = if not boostActive: state.hiddenDim elif isNewLayer: 0.cint else: growth_old_dim
    let boundFfn = if not boostActive: state.ffnDim elif isNewLayer: 0.cint else: growth_old_ffn

    upA(state.rms_att_weights[l], state.m_rms_att_weights[l], state.v_rms_att_weights[l], state.g_rms_att_weights[l], state.hiddenDim, boundDim)
    upA(state.rms_ffn_weights[l], state.m_rms_ffn_weights[l], state.v_rms_ffn_weights[l], state.g_rms_ffn_weights[l], state.hiddenDim, boundDim)
    upM(state.w_q_q8[l], state.m_w_q[l], state.v_w_q[l], state.g_w_q[l], resM(state.res_w_q, l), boundDim, boundDim, qmpL(state.mq_w_q, l), qmpL(state.vq_w_q, l))
    upM(state.w_k_q8[l], state.m_w_k[l], state.v_w_k[l], state.g_w_k[l], resM(state.res_w_k, l), boundDim, boundDim, qmpL(state.mq_w_k, l), qmpL(state.vq_w_k, l))
    upM(state.w_v_q8[l], state.m_w_v[l], state.v_w_v[l], state.g_w_v[l], resM(state.res_w_v, l), boundDim, boundDim, qmpL(state.mq_w_v, l), qmpL(state.vq_w_v, l))
    upM(state.w_o_q8[l], state.m_w_o[l], state.v_w_o[l], state.g_w_o[l], resM(state.res_w_o, l), boundDim, boundDim, qmpL(state.mq_w_o, l), qmpL(state.vq_w_o, l))
    upM(state.w_up_q8[l], state.m_w_up[l], state.v_w_up[l], state.g_w_up[l], resM(state.res_w_up, l), boundFfn, boundDim, qmpL(state.mq_w_up, l), qmpL(state.vq_w_up, l))
    upM(state.w_down_q8[l], state.m_w_down[l], state.v_w_down[l], state.g_w_down[l], resM(state.res_w_down, l), boundDim, boundFfn, qmpL(state.mq_w_down, l), qmpL(state.vq_w_down, l))

  if fbMissingSeen and not fbMissingWarned:
    fbMissingWarned = true
    stderr.writeLine("[cortex] WARNUNG: Fehler-Rueckfuehrung ist eingeschaltet, aber es ",
                     "gibt keine Rest-Puffer - sie wirkt NICHT. Ohne sie driftet w_out ",
                     "ueber lange Laeufe.")

  # PHASE 7: Adam laeuft bewusst auf der CPU (siehe Kommentar bei
  # markQWeightsDirty) - die Gewichte im VRAM sind damit veraltet.
  markQWeightsDirty(state)

# --- QUANTISIERUNG / SKALEN-LEBENSZYKLUS ---

proc allocQMatrix(rows, cols: cint): QMatrix =
  result.rows = rows
  result.cols = cols
  result.data = cast[ptr Int8Array](allocShared0(rows.int * cols.int * sizeof(int8)))
  result.scale = cast[ptr FloatArray](allocShared0(rows.int * sizeof(cfloat)))

proc freeQMatrix(qm: var QMatrix) =
  if not qm.data.isNil: deallocShared(qm.data)
  if not qm.scale.isNil: deallocShared(qm.scale)
  qm.data = nil
  qm.scale = nil

# AUDIT 2026-08-19: matVecMulI8() akkumuliert int8*int8 in einem int32.
# Betragsmaessig groesstes Einzelprodukt ist 127*128 = 16256, der Akkumulator
# laeuft also ab cols > 2^31-1 / 16256 = 132.104 ueber - unter -d:danger
# STILL (kein Overflow-Check, undefiniertes Verhalten), das Ergebnis waere
# einfach falsch. Die groesste Stufe der EVOLUTION_LADDER (Goddess, dim=4096
# -> ffnDim=16384) liegt mit Faktor ~8 Sicherheitsabstand darunter, der
# Header-Sanity-Check in den Loadern erlaubt aber ffnDim bis 262.144. Dieser
# einmalige Check pro Modell-Initialisierung schliesst die Luecke.
const I8_MAX_SAFE_COLS = 132_104

proc checkI8AccumRange(dim, ffn: cint): bool {.discardable.} =
  let widest = max(dim.int, ffn.int)
  if widest > I8_MAX_SAFE_COLS:
    stderr.writeLine("[cortex] FATAL: INT8-GEMM-Akkumulator wuerde ueberlaufen ",
                     "(breiteste Matrixzeile ", $widest, " > ", $I8_MAX_SAFE_COLS,
                     "). int32 reicht dafuer nicht - Modell zu breit fuer den ",
                     "INT8-Pfad.")
    return false
  return true

# ==============================================================================
# SPEICHER-AUDIT 2026-08-19
# ------------------------------------------------------------------------------
# Der Kommentar am CortexState-Feld weightDtype behauptete seit Phase 2, die
# FP32-Gewichtsfelder blieben im INT8-Modus "ungenutzt/unallokiert" - der
# zweite Teil stimmte nie: cortex_init() legt sie IMMER an, die INT8-Felder
# kamen additiv obendrauf. Gemessen an einem 918k-Parameter-Modell belegte ein
# 0,90-MB-Deployment-Artefakt dadurch 21 MB RAM (Faktor 23) - genau das
# Gegenteil der Projekt-Vision ("1,5 MB, passt in den L2/L3-Cache").
#
# Aufteilung der 21 MB: ~3,7 MB FP32-Gewichte (im INT8-Pfad NACHWEISLICH nie
# gelesen - saemtliche Rechenpfade gehen ueber die *_q8-Felder), ~11 MB
# Adam-Momente/Gradienten (fuer Training noetig, fuer reine Inferenz nutzlos),
# Rest Aktivierungs-/KV-Puffer.
#
# Die beiden Prozeduren unten geben genau diese beiden Gruppen gezielt frei.
# Alle Zugriffspfade sind nil-sicher: cortex_load_layer()/
# cortex_extract_layer() pruefen bereits auf nil, freeMatrix()/freeA() ebenso,
# und cortex_validate()/cortex_train_step_i8() bekommen unten eigene Guards.
# ==============================================================================

proc freeFp32WeightShadows(s: ptr CortexState) =
  ## Gibt die FP32-Kopien der 8 quantisierbaren Gewichtstensoren frei. NUR im
  ## INT8-Modus aufrufen und erst NACHDEM die *_q8-Felder daraus gebaut sind.
  ## m/v/g bleiben unberuehrt (Adam braucht sie, Design-Entscheidung #2).
  freeMatrix(s.embeddings)
  freeMatrix(s.w_out)
  if not s.w_q.isNil:
    for l in 0 ..< s.numLayers:
      freeMatrix(s.w_q[l]); freeMatrix(s.w_k[l]); freeMatrix(s.w_v[l])
      freeMatrix(s.w_o[l]); freeMatrix(s.w_up[l]); freeMatrix(s.w_down[l])

# (Ein Gegenstueck freeAdamState() gab es kurzzeitig, wurde aber wieder
# entfernt: nachtraegliches Freigeben senkt den Spitzenverbrauch nicht, weil
# der Allokator die Arena behaelt - gemessen 21,00 MB vor wie nach dem
# Freigeben. Der Adam-Zustand wird stattdessen ueber init_skip_adam_state in
# cortex_init() gar nicht erst alloziert.)

proc quantizeMatrixToQ8(src: Matrix): QMatrix =
  ## Initial-Skala (Plan, "Skalen-Lebenszyklus"): scale = max(|row|)/127.
  result = allocQMatrix(src.rows, src.cols)
  let rows = src.rows.int
  let cols = src.cols.int
  for r in 0 ..< rows:
    let off = r * cols
    var maxAbs: cfloat = 0.0
    for c in 0 ..< cols:
      let a = abs(src.data[off + c])
      if a > maxAbs: maxAbs = a
    let scale = if maxAbs > 0.0: maxAbs / 127.0 else: 1.0
    result.scale[r] = scale
    for c in 0 ..< cols:
      var q = round(src.data[off + c] / scale).int
      if q > 127: q = 127
      elif q < -128: q = -128
      result.data[off + c] = q.int8

proc allocI8ErrorFeedback(state: ptr CortexState) =
  ## Legt die Rest-Puffer der Fehler-Rueckfuehrung an - EIN float32 je Gewicht,
  ## also genauso gross wie der Gradientenpuffer. Nur wenn ein Adam-Zustand
  ## vorhanden ist: ohne den wird nie ein Adam-Schritt gerechnet und damit nie
  ## requantisiert, es gibt also auch keinen Rest aufzuheben. Ein reines
  ## Deployment-Artefakt zahlt diesen Speicher folglich nicht.
  ##
  ## FEHLER 2026-08-25: die Bedingung lautete nur `m_embeddings.data.isNil`.
  ## Seit dem Adam-Speicherumbau (Schritt 3) ist dieses Feld auch im TRAINING
  ## legitim nil - die Momente liegen dann in mq_/vq_. Der volle Ganzzahl-Stack
  ## bekam damit NIE Rest-Puffer, und `useFb` in adamRowFloatI8() schaltete die
  ## Fehler-Rueckfuehrung stillschweigend ab. Folge im Produktivlauf: die
  ## w_out-Drift aus Phase 10 kehrte zurueck, der Held-out-Abstand zu FP32
  ## wuchs monoton von +0,54 auf +2,50 ueber vier Segmente.
  ##
  ## Dieselbe Fehlerklasse wie schon dreimal zuvor (`m_*.data.isNil` als
  ## Stellvertreter fuer "kein Adam-Zustand"). Deshalb BEIDE Ablageorte pruefen.
  if state.isNil: return
  let hasAdam = (not state.m_embeddings.data.isNil) or
                (state.quantAdam != 0 and not state.mq_embeddings.data.isNil)
  if not hasAdam: return
  state.res_embeddings = allocMatrix(state.embeddings_q8.rows, state.embeddings_q8.cols)
  # Bei Tying gibt es nur EINEN Rest-Puffer, weil es nur EINEN Adam-Schritt
  # gibt (applyGlobalAdamUpdateI8 ueberspringt w_out). Ein zweiter waere nicht
  # bloss ungenutzt, sondern irrefuehrend: ein spaeterer Leser koennte daraus
  # schliessen, w_out werde separat requantisiert.
  if state.tiedEmbeddings == 0:
    state.res_w_out = allocMatrix(state.w_out_q8.rows, state.w_out_q8.cols)
  let nl = state.numLayers.int
  template mkArr(fld, src) =
    state.fld = cast[ptr MatrixArray](allocShared0(nl * sizeof(Matrix)))
    for l in 0 ..< nl:
      state.fld[l] = allocMatrix(state.src[l].rows, state.src[l].cols)
  mkArr(res_w_q, w_q_q8)
  mkArr(res_w_k, w_k_q8)
  mkArr(res_w_v, w_v_q8)
  mkArr(res_w_o, w_o_q8)
  mkArr(res_w_up, w_up_q8)
  mkArr(res_w_down, w_down_q8)

proc freeI8ErrorFeedback(state: ptr CortexState) =
  gpuAdamDrop()
  freeMatrix(state.res_embeddings)
  # Bei Tying wurde res_w_out nie angelegt (data ist nil) - freeMatrix ist
  # dafuer bereits sicher, der Aufruf steht hier nur der Symmetrie halber.
  freeMatrix(state.res_w_out)
  template rmArr(fld) =
    if not state.fld.isNil:
      for l in 0 ..< state.numLayers:
        freeMatrix(state.fld[l])
      deallocShared(state.fld)
      state.fld = nil
  rmArr(res_w_q)
  rmArr(res_w_k)
  rmArr(res_w_v)
  rmArr(res_w_o)
  rmArr(res_w_up)
  rmArr(res_w_down)

proc cortex_quantize_from_fp32*(state: ptr CortexState): cint {.ffi.} =
  ## Bruecke von der bestehenden, unveraenderten FP32-Lade-Infrastruktur
  ## (cortex_load_stream/cortex_load_layer) zu nativem INT8: quantisiert die
  ## bereits geladenen FP32-Gewichte in-memory in die *_q8-Felder und setzt
  ## state.weightDtype=1. Erwartet ein per cortex_init()+cortex_load_layer()
  ## (oder cortex_load_stream()) voll geladenes FP32-State.
  if state.isNil: return 0
  if not checkI8AccumRange(state.hiddenDim, state.ffnDim): return 0
  state.embeddings_q8 = quantizeMatrixToQ8(state.embeddings)
  state.w_out_q8 = quantizeMatrixToQ8(state.w_out)
  let nl = state.numLayers.int
  state.w_q_q8 = cast[ptr QMatrixArray](allocShared0(nl * sizeof(QMatrix)))
  state.w_k_q8 = cast[ptr QMatrixArray](allocShared0(nl * sizeof(QMatrix)))
  state.w_v_q8 = cast[ptr QMatrixArray](allocShared0(nl * sizeof(QMatrix)))
  state.w_o_q8 = cast[ptr QMatrixArray](allocShared0(nl * sizeof(QMatrix)))
  state.w_up_q8 = cast[ptr QMatrixArray](allocShared0(nl * sizeof(QMatrix)))
  state.w_down_q8 = cast[ptr QMatrixArray](allocShared0(nl * sizeof(QMatrix)))
  for l in 0 ..< state.numLayers:
    state.w_q_q8[l] = quantizeMatrixToQ8(state.w_q[l])
    state.w_k_q8[l] = quantizeMatrixToQ8(state.w_k[l])
    state.w_v_q8[l] = quantizeMatrixToQ8(state.w_v[l])
    state.w_o_q8[l] = quantizeMatrixToQ8(state.w_o[l])
    state.w_up_q8[l] = quantizeMatrixToQ8(state.w_up[l])
    state.w_down_q8[l] = quantizeMatrixToQ8(state.w_down[l])
  let scratchSize = max(state.hiddenDim.int, state.ffnDim.int)
  state.i8_qscratch = cast[ptr Int8Array](allocShared0(scratchSize * sizeof(int8)))
  state.i8_qbatch = cast[ptr Int8Array](allocShared0(state.ctxSize.int * scratchSize * sizeof(int8)))
  state.i8_qbatch_scale = cast[ptr FloatArray](allocShared0(state.ctxSize.int * sizeof(cfloat)))
  # FULL-INT8 SCHRITT 1: "rows" ist beim Backward auch mal das Vokabular
  # (w_out), deshalb vocabSize in die Groesse einbeziehen - der Akkumulator
  # dagegen hat immer Spalten-Laenge (hiddenDim/ffnDim).
  allocI8BackwardScratch(state, max(scratchSize, state.vocabSize.int), scratchSize)

  # KV-Cache: leer allokiert (rows=ctxSize, cols=hiddenDim, wie k_cache/
  # v_cache) - kein FP32-Ausgangswert zu konvertieren, der Cache wird bei
  # jedem cortex_train_step_i8()-Aufruf position-fuer-position frisch
  # beschrieben (siehe KV-Cache-Design-Kommentar am Feld oben).
  allocI8ErrorFeedback(state)
  state.k_cache_q8 = cast[ptr QMatrixArray](allocShared0(nl * sizeof(QMatrix)))
  state.v_cache_q8 = cast[ptr QMatrixArray](allocShared0(nl * sizeof(QMatrix)))
  for l in 0 ..< state.numLayers:
    state.k_cache_q8[l] = allocQMatrix(state.ctxSize, state.hiddenDim)
    state.v_cache_q8[l] = allocQMatrix(state.ctxSize, state.hiddenDim)
  state.kv_raw_buf = cast[ptr FloatArray](allocShared0(state.hiddenDim.int * sizeof(cfloat)))

  state.weightDtype = 1
  # SPEICHER-AUDIT 2026-08-19: die FP32-Gewichte sind ab hier vollstaendig in
  # den *_q8-Feldern abgebildet und werden im INT8-Pfad nie wieder gelesen.
  # m/v/g bleiben (Training laeuft weiter). Siehe Kommentarblock bei
  # freeFp32WeightShadows().
  freeFp32WeightShadows(state)
  return 1

# ==============================================================================
# SNAI_V7 / WEIGHT TYING (2026-08-29)
# ------------------------------------------------------------------------------
# Anlass: das A/B des Hauptzweigs hat Weight Tying in allen vier Epochen
# gewinnen sehen - gebundener Arm besser bei 2,6 % WENIGER Parametern, Abstand
# monoton wachsend, GradNorm durchgehend niedriger. Der erwartete Groessen-
# vorteil blieb dort aber aus, weil SNAI_V6 den w_out-Block trotz Bindung
# redundant mitschreibt (41,7 MB gebunden gegen 29,9 MB ungebunden). SNAI_V7
# raeumt das weg; dieser Abschnitt ist die Kernseite davon.
#
# Was "gebunden" hier heisst: w_out_q8 zeigt auf DENSELBEN Speicher wie
# embeddings_q8 - dieselben int8-Daten UND dieselben Zeilenskalen. Das passt
# im INT8-Pfad ohne Kunstgriff, weil "Zeile" bei beiden Tensoren dasselbe
# bedeutet (ein Token) und beide Rollen die Zeile identisch interpretieren:
# der Lookup liest sie als Vektor (data[t*dim+d] * scale[t]), das Logit-GEMM
# als Gewichtszeile (Sum_c data[t*dim+c]*act[c] * scale[t] * actScale).
# ==============================================================================

proc tieEmbeddingsInternal(s: ptr CortexState) =
  ## Bindet w_out an embeddings. Setzt einen bereits quantisierten INT8-Zustand
  ## voraus (weightDtype == 1).
  ##
  ## Der eigene w_out-Speicher wird dabei FREIGEGEBEN, nicht bloss verwaist
  ## liegen gelassen - genau das ist der Speichergewinn, den das Format auf der
  ## Platte abbildet. Was wegfaellt: die int8-Daten + Skalen (vocab*dim + vocab
  ## Floats), die Adam-Momente m/v bzw. mq/vq, und der Rest-Puffer der
  ## Fehler-Rueckfuehrung.
  ##
  ## g_w_out BLEIBT ein eigener Puffer - Begruendung am Feld `tiedEmbeddings`.
  if s.isNil or s.weightDtype != 1: return
  if s.tiedEmbeddings != 0: return    # schon gebunden, nichts zu tun

  # Reihenfolge zaehlt: erst den eigenen Speicher freigeben, DANN aliasen.
  # Umgekehrt wuerde freeQMatrix() den frisch geteilten Embedding-Speicher
  # zerstoeren.
  freeQMatrix(s.w_out_q8)
  s.w_out_q8 = s.embeddings_q8        # Struktur-Kopie -> geteilte Zeiger

  freeMatrix(s.m_w_out)
  freeMatrix(s.v_w_out)
  freeMatrix(s.res_w_out)
  if s.quantAdam != 0:
    # freeQMoment() nullt die Zeiger NICHT (nimmt den Wert unveraenderlich
    # entgegen) - hier von Hand nachziehen, sonst gibt cortex_free() sie ein
    # zweites Mal frei.
    freeQMoment(s.mq_w_out); s.mq_w_out.data = nil; s.mq_w_out.scale = nil
    freeQMoment(s.vq_w_out); s.vq_w_out.data = nil; s.vq_w_out.scale = nil

  s.tiedEmbeddings = 1

proc cortex_tie_embeddings*(state: ptr CortexState): cint {.ffi.} =
  ## Bindet w_out an die Embeddings (SNAI_V7). Aufzurufen NACH
  ## cortex_quantize_from_fp32() bzw. bei einem frisch geladenen V6-Modell, das
  ## als gebundenes weitertrainiert werden soll. Ein bereits aus einer
  ## V7-Datei geladener Zustand ist schon gebunden und bleibt unveraendert.
  ##
  ## Rueckgabe: 1 = gebunden, 0 = abgelehnt (kein INT8-Zustand).
  if state.isNil or state.weightDtype != 1: return 0
  tieEmbeddingsInternal(state)
  return state.tiedEmbeddings

proc cortex_get_tied_embeddings*(state: ptr CortexState): cint {.ffi.} =
  ## Fragt die WIRKUNG ab, nicht einen Wunsch-Schalter: prueft zusaetzlich,
  ## dass die Zeiger tatsaechlich geteilt sind. Lehre aus dem
  ## `cortex_i8_error_feedback_active`-Befund (2026-08-25) - ein
  ## Schalter, der eingeschaltet ist, muss nicht wirken.
  if state.isNil: return 0
  if state.tiedEmbeddings == 0: return 0
  if state.w_out_q8.data != state.embeddings_q8.data: return 0
  if state.w_out_q8.scale != state.embeddings_q8.scale: return 0
  return 1

# ==============================================================================
# EMB-EINGANG (2026-11-03, messbuch snai/engine-emb-eingang)
# ------------------------------------------------------------------------------
# Unter Tying ist das Embedding klein (es ist zugleich die Ausgabeprojektion),
# der Restpfad startet deshalb winzig und die FFN-Gains sterben. Gemessen am
# Knirps 128x4 (int8, K1-Rezept, 8 Saaten): Eingang mal sqrt(d) repariert die
# toten Gains und verbessert den Held-out um 0,037 nats (1,4 %).
# Der Faktor gehoert zum MODELL: ein mit F trainiertes Modell ohne F gemessen
# ist zerstoert (6,68 statt 2,62), ein altes Modell mit F gemessen verliert
# 0,05 nats. Deshalb SNAI_V7 Flags Bit 1, kein Umgebungs-Stellrad.
# Einschalten nur an der Genesis (train_worker.php), nur mit Tying. Ein Modell
# MIT Bit laedt immer mit Faktor. Ausschalten gibt es nicht.
# ==============================================================================

proc cortex_get_emb_eingang*(state: ptr CortexState): cint {.ffi.} =
  ## WIRKUNG, nicht Wunsch: 1 nur, wenn der Faktor an ist UND die Bindung wirkt.
  if state.isNil or state.embEinAn == 0: return 0
  if cortex_get_tied_embeddings(state) == 0: return 0
  if state.embEinF != sqrt(state.hiddenDim.cfloat): return 0
  return 1

proc cortex_get_emb_eingang_faktor*(state: ptr CortexState): cfloat {.ffi.} =
  ## Der Faktor, mit dem der Embedding-Lookup am Eingang tatsaechlich rechnet (1.0 = aus).
  if state.isNil: return 0.0
  return embFak(state)

proc cortex_set_emb_eingang*(state: ptr CortexState, an: cint): cint {.ffi.} =
  ## Schaltet den Embedding-Eingangsfaktor EIN. Nur INT8 mit wirksamer Bindung.
  ## an == 0 wird abgelehnt, solange er an ist: das Bit ist Eigenschaft des
  ## Modells, ein Ausschalten wuerde es beim naechsten Speichern still verwerfen.
  ## Rueckgabe: cortex_get_emb_eingang() danach.
  if state.isNil: return 0
  if an == 0:
    if state.embEinAn != 0:
      stderr.writeLine("[cortex] EMB-EINGANG: Ausschalten abgelehnt - das Bit gehoert zum Modell.")
    return cortex_get_emb_eingang(state)
  if state.weightDtype != 1 or cortex_get_tied_embeddings(state) == 0:
    stderr.writeLine("[cortex] EMB-EINGANG abgelehnt: nur fuer INT8 mit wirksamem Weight Tying (SNAI_V7).")
    return 0
  state.embEinF = sqrt(state.hiddenDim.cfloat)
  state.embEinAn = 1
  return cortex_get_emb_eingang(state)

# ==============================================================================
# FFN-SKIP (2026-11-03, messbuch snai/engine-ffn-weg)
# ------------------------------------------------------------------------------
# Ist rms_ffn einer Schicht exakt 0 UND w_down exakt 0, liefert der Zweig exakt
# 0 und alle seine Gradienten sind exakt 0 (g_w_down = d * silu(w_up*0) = 0,
# d_ffn = w_down^T d = 0 -> g_w_up = 0 und g_rms_ffn = 0). Er bleibt also fuer
# immer aus, die Engine rechnete ihn aber mit. Hier wird er erkannt und in
# Vorwaerts und Rueckwaerts uebersprungen. Adam laeuft unveraendert (die
# Gradientenpuffer sind ohnehin 0, Weight Decay auf w_up wirkt wie bisher).
#
# Erkannt wird an den WERTEN, nicht an einem Schalter: beim Laden, zu Beginn
# jedes int8-Trainingsschritts und zu Beginn jeder Sequenz der int8-Inferenz
# (cachedTokens == 0). Wer Gewichte aendert, bekommt die Erkennung also
# spaetestens beim naechsten Schritt neu.
#
# Kein Ueberspringen (Zweig wird gerechnet wie bisher), wenn
#  - SNAI_FFN_SKIP=0 (Pruefung: Erkennung aus),
#  - Dropout aktiv ist (der Zweig verbraucht dann Zufallszahlen; Ueberspringen
#    verschoebe die Folge der spaeteren Schichten),
#  - LoRA auf w_up oder w_down sitzt (ein Adapter auf w_down gaebe d_ffn != 0,
#    der Zweig koennte wieder anlaufen).
# Meldungen auf stderr: mess_text.php liest stdout als JSON.
# ==============================================================================

var ffnSkipModus = -1   # -1 = Umgebung noch nicht gelesen, 0 = SNAI_FFN_SKIP=0, 1 = Erkennung an

proc ffnSkipErlaubt(): bool =
  if ffnSkipModus < 0:
    ffnSkipModus = (if getEnv("SNAI_FFN_SKIP") == "0": 0 else: 1)
    if ffnSkipModus == 0:
      stderr.writeLine("  > [FFN-SKIP] Engine: Erkennung abgeschaltet (SNAI_FFN_SKIP=0), alle FFN-Zweige werden gerechnet")
  ffnSkipModus == 1

proc ffnZweigNull(s: ptr CortexState, l: int): bool =
  ## true, wenn rms_ffn UND w_down der Schicht l exakt 0 sind (int8: alle Daten 0, Skalen endlich).
  if s.isNil or s.weightDtype != 1 or s.rms_ffn_weights.isNil or s.w_down_q8.isNil: return false
  if l < 0 or l >= s.numLayers.int: return false
  let g = s.rms_ffn_weights[l]
  if g.isNil: return false
  for d in 0 ..< s.hiddenDim.int:
    if g[d] != 0.0'f32: return false     # NaN != 0 -> nicht null
  let q = s.w_down_q8[l]
  if q.data.isNil or q.scale.isNil: return false
  # Eine nichtendliche Zeilenskala machte 0 * Skala zu NaN - dann ist der Zweig nicht still.
  for r in 0 ..< q.rows.int:
    let sc = q.scale[r]
    if sc.isNaN or sc > 1e30'f32 or sc < -1e30'f32: return false
  for i in 0 ..< (q.rows.int * q.cols.int):
    if q.data[i] != 0'i8: return false
  return true

proc ffnSkipAktualisieren(s: ptr CortexState) =
  ## Erkennt je Schicht, ob der FFN-Zweig aus ist, und meldet jede Aenderung des Stands auf stderr.
  if s.isNil or s.weightDtype != 1 or s.numLayers <= 0: return
  let nl = s.numLayers.int
  if s.ffnAus.isNil:
    s.ffnAus = cast[ptr Uint8Array](allocShared0(nl))
  let erlaubt = ffnSkipErlaubt() and global_dropout_rate <= 0.0 and
                not loraSlotOn(s, 4) and not loraSlotOn(s, 5)
  var sig: uint64 = 0
  var liste = ""
  for l in 0 ..< nl:
    let aus = erlaubt and ffnZweigNull(s, l)
    s.ffnAus[l] = (if aus: 1'u8 else: 0'u8)
    if aus:
      sig = sig * 1000003'u64 + uint64(l + 1)
      liste.add((if liste.len > 0: "," else: "") & $l)
  if sig != s.ffnAusSig:
    if sig == 0:
      stderr.writeLine("  > [FFN-SKIP] Engine: kein FFN-Zweig mehr uebersprungen")
    else:
      stderr.writeLine("  > [FFN-SKIP] Engine: FFN-Zweig uebersprungen in Schicht ", liste,
                       " (rms_ffn und w_down exakt 0)")
    s.ffnAusSig = sig

proc cortex_ffn_zweig_null*(state: ptr CortexState, layer: cint): cint {.ffi.} =
  ## 1, wenn rms_ffn und w_down der Schicht exakt 0 sind (Wirkung des Nullsetzens).
  return (if ffnZweigNull(state, layer.int): 1 else: 0)

proc cortex_ffn_zweig_uebersprungen*(state: ptr CortexState, layer: cint): cint {.ffi.} =
  ## 1, wenn die Engine den Zweig dieser Schicht beim naechsten Schritt ueberspringt.
  if state.isNil or layer < 0 or layer >= state.numLayers: return 0
  ffnSkipAktualisieren(state)
  return (if ffnAusL(state, layer.int): 1 else: 0)

proc cortex_ffn_aus*(state: ptr CortexState, layer: cint): cint {.ffi.} =
  ## GENESIS: setzt den FFN-Zweig der Schicht exakt auf 0 - rms_ffn (samt m/v/g), w_down int8-Daten 0 mit
  ## Zeilenskala 1.0 (wie quantizeMatrixToQ8 eine Nullzeile ablegt), Momente, Rest und Gradient 0.
  ## Nur INT8 und nur vor dem ersten Adam-Schritt (adam_t == 0). Rueckgabe: cortex_ffn_zweig_null() danach.
  if state.isNil or layer < 0 or layer >= state.numLayers: return 0
  if state.weightDtype != 1:
    stderr.writeLine("[cortex] FFN-AUS abgelehnt: nur fuer einen INT8-Zustand.")
    return 0
  if state.adam_t != 0:
    stderr.writeLine("[cortex] FFN-AUS abgelehnt: adam_t=", state.adam_t, " - nur an der Genesis (adam_t 0).")
    return 0
  gpuAdamDrop()
  let l = layer.int
  let D = state.hiddenDim.int
  template null0(p: ptr FloatArray, n: int) =
    if not p.isNil:
      for i in 0 ..< n: p[i] = 0.0'f32
  null0(state.rms_ffn_weights[l], D)
  if not state.m_rms_ffn_weights.isNil: null0(state.m_rms_ffn_weights[l], D)
  if not state.v_rms_ffn_weights.isNil: null0(state.v_rms_ffn_weights[l], D)
  if not state.g_rms_ffn_weights.isNil: null0(state.g_rms_ffn_weights[l], D)
  let q = state.w_down_q8[l]
  for i in 0 ..< (q.rows.int * q.cols.int): q.data[i] = 0'i8
  for r in 0 ..< q.rows.int: q.scale[r] = 1.0'f32
  template nullM(arr: untyped) =
    if not arr.isNil and not arr[l].data.isNil:
      null0(arr[l].data, arr[l].rows.int * arr[l].cols.int)
  nullM(state.w_down)
  nullM(state.m_w_down)
  nullM(state.v_w_down)
  nullM(state.g_w_down)
  nullM(state.res_w_down)
  template nullQ(arr: untyped) =
    if not arr.isNil and not arr[l].data.isNil:
      for i in 0 ..< (arr[l].rows.int * arr[l].cols.int): arr[l].data[i] = 0'u8
      for r in 0 ..< arr[l].rows.int: arr[l].scale[r] = 0.0'f32
  nullQ(state.mq_w_down)
  nullQ(state.vq_w_down)
  if gpu_initialized: state.qDirty = 1
  ffnSkipAktualisieren(state)
  return cortex_ffn_zweig_null(state, layer)

# ==============================================================================
# LoRA - Lebenszyklus und FFI (2026-08-29)
# ==============================================================================

proc loraSlotShape(s: ptr CortexState, slot: int): (cint, cint) =
  ## (rows, cols) des Basisgewichts, an dem dieser Slot haengt.
  case slot
  of 0, 1, 2, 3: (s.hiddenDim, s.hiddenDim)      # w_q w_k w_v w_o
  of 4:          (s.ffnDim, s.hiddenDim)         # w_up
  of 5:          (s.hiddenDim, s.ffnDim)         # w_down
  else:          (0.cint, 0.cint)

proc loraFreeAll(s: ptr CortexState) =
  if s.isNil: return
  template freeArr(arr) =
    if not arr.isNil:
      for i in 0 ..< (s.numLayers.int * LORA_SLOTS): freeMatrix(arr[i])
      deallocShared(arr); arr = nil
  freeArr(s.lora_a);   freeArr(s.m_lora_a); freeArr(s.v_lora_a); freeArr(s.g_lora_a)
  freeArr(s.lora_b);   freeArr(s.m_lora_b); freeArr(s.v_lora_b); freeArr(s.g_lora_b)
  if not s.lora_h.isNil:  deallocShared(s.lora_h);  s.lora_h = nil
  if not s.lora_dh.isNil: deallocShared(s.lora_dh); s.lora_dh = nil
  s.loraRank = 0
  s.loraMask = 0
  s.loraFrozenBase = 0

# SPEICHERARM, zweiter Anlauf (2026-08-29). Der erste war das FREIGEBEN nach
# dem Laden - gemessen hat es nichts gebracht: der Spitzen-RSS entsteht beim
# Laden, und `deallocShared` gibt die Seiten an Nims Arena zurueck, nicht an das
# Betriebssystem. Gemessen 249 MB vorher, 252 MB nachher; die Adapter kamen
# obendrauf, gespart wurde nichts.
#
# Was wirklich wirkt, ist NICHT ZU ALLOZIEREN. Dieser Schalter wird VOR
# cortex_load_stream_i8() gesetzt und laesst den Adam-Zustand der Basis samt
# Rest-Puffern gar nicht erst entstehen; die Bytes in der Datei werden
# uebersprungen statt gelesen.
var lora_preload_skip_base_adam = false

proc cortex_set_lora_preload*(on: cint) {.ffi.} =
  lora_preload_skip_base_adam = (on != 0)

proc cortex_get_lora_preload*(): cint {.ffi.} =
  (if lora_preload_skip_base_adam: 1 else: 0)

proc loraFreeBaseOptState(s: ptr CortexState) =
  ## Gibt den kompletten Optimierer-Zustand der Basis frei: Adam-Momente
  ## (float wie quantisiert), Gradientenpuffer und die Rest-Puffer der
  ## Fehler-Rueckfuehrung. Die GEWICHTE bleiben unangetastet.
  ##
  ## Warum das ueberhaupt geht: bei eingefrorener Basis wird keiner dieser
  ## Puffer noch gelesen - der Adam-Schritt kehrt vorher zurueck, die
  ## Gradientenakkumulation ist uebersprungen, und requantisiert wird nichts,
  ## also braucht auch niemand einen Rundungsrest.
  ##
  ## Was NICHT freigegeben wird: die rms_*-Momente. Sie sind Vektoren der
  ## Laenge dim (<0,1% des Adam-Speichers) und haengen an mehr Codestellen,
  ## als der Gewinn rechtfertigt.
  if s.isNil: return
  template fm(m) = freeMatrix(m)
  template fq(q) =
    if not q.data.isNil:
      freeQMoment(q); q.data = nil; q.scale = nil
  template fmArr(arr) =
    if not arr.isNil:
      for l in 0 ..< s.numLayers.int: freeMatrix(arr[l])
  template fqArr(arr) =
    if not arr.isNil:
      for l in 0 ..< s.numLayers.int: fq(arr[l])

  # Bei Tying zeigen m_w_out/v_w_out bereits auf nil (tieEmbeddingsInternal) -
  # freeMatrix ist dort folgenlos.
  fm(s.m_embeddings); fm(s.v_embeddings); fm(s.g_embeddings)
  fm(s.m_w_out);      fm(s.v_w_out);      fm(s.g_w_out)
  fq(s.mq_embeddings); fq(s.vq_embeddings)
  fq(s.mq_w_out);      fq(s.vq_w_out)
  fmArr(s.m_w_q); fmArr(s.v_w_q); fmArr(s.g_w_q)
  fmArr(s.m_w_k); fmArr(s.v_w_k); fmArr(s.g_w_k)
  fmArr(s.m_w_v); fmArr(s.v_w_v); fmArr(s.g_w_v)
  fmArr(s.m_w_o); fmArr(s.v_w_o); fmArr(s.g_w_o)
  fmArr(s.m_w_up); fmArr(s.v_w_up); fmArr(s.g_w_up)
  fmArr(s.m_w_down); fmArr(s.v_w_down); fmArr(s.g_w_down)
  fqArr(s.mq_w_q); fqArr(s.vq_w_q); fqArr(s.mq_w_k); fqArr(s.vq_w_k)
  fqArr(s.mq_w_v); fqArr(s.vq_w_v); fqArr(s.mq_w_o); fqArr(s.vq_w_o)
  fqArr(s.mq_w_up); fqArr(s.vq_w_up); fqArr(s.mq_w_down); fqArr(s.vq_w_down)
  freeI8ErrorFeedback(s)
  s.baseOptFreed = 1

proc cortex_lora_base_opt_freed*(state: ptr CortexState): cint {.ffi.} =
  ## Fragt die WIRKUNG ab: Merker gesetzt UND die Puffer tatsaechlich weg.
  if state.isNil or state.baseOptFreed == 0: return 0
  if not state.m_embeddings.data.isNil: return 0
  if not state.g_embeddings.data.isNil: return 0
  if not state.mq_embeddings.data.isNil: return 0
  return 1

proc cortex_lora_enable*(state: ptr CortexState, rank: cint, alpha: cfloat,
                         slotMask: cint, freezeBase: cint, seed: cint): cint {.ffi.} =
  ## Legt die Adapter an. Rueckgabe 1 = eingerichtet, 0 = abgelehnt.
  ##
  ## A wird zufaellig, B wird NULL initialisiert. Damit ist das Modell direkt
  ## nach dem Einrichten mathematisch exakt das Basismodell - das ist keine
  ## Konvention, sondern die Voraussetzung fuer die wichtigste Pruefung:
  ## "Schritt 0 muss bit-identisch zur Basis sein". Waeren beide zufaellig,
  ## startete der Lauf von einem verrauschten Modell und man koennte einen
  ## Einbaufehler nicht mehr von einer schlechten Initialisierung trennen.
  ##
  ## Der Zufall kommt aus einem eigenen, deterministischen Generator und NICHT
  ## aus dem globalen RNG: der treibt das Dropout, und ein Eingriff dort wuerde
  ## zwei Arme, die sonst identisch waeren, auseinanderlaufen lassen.
  if state.isNil: return 0
  if state.weightDtype != 1: return 0          # LoRA haengt an den INT8-Gewichten
  if rank <= 0 or rank > 512: return 0
  if state.ctxSize <= 0 or state.numLayers <= 0: return 0
  let mask = (if slotMask == 0: LORA_ALL else: slotMask)
  if (mask and not LORA_ALL) != 0: return 0

  loraFreeAll(state)
  let n = state.numLayers.int * LORA_SLOTS
  template allocArrM(arr) =
    arr = cast[ptr MatrixArray](allocShared0(n * sizeof(Matrix)))
  allocArrM(state.lora_a); allocArrM(state.m_lora_a); allocArrM(state.v_lora_a); allocArrM(state.g_lora_a)
  allocArrM(state.lora_b); allocArrM(state.m_lora_b); allocArrM(state.v_lora_b); allocArrM(state.g_lora_b)

  # Eigener LCG (Numerical Recipes). Gleiche Saat -> gleiche Adapter, auf jeder
  # Maschine. Fuer einen A/B ist das keine Bequemlichkeit, sondern Bedingung.
  var rngState: uint32 = (if seed == 0: 1234567u32 else: cast[uint32](seed))
  proc nextF(): cfloat =
    rngState = rngState * 1664525u32 + 1013904223u32
    (rngState.float64 / 4294967296.0).cfloat        # [0,1)

  for l in 0 ..< state.numLayers.int:
    for slot in 0 ..< LORA_SLOTS:
      let idx = l * LORA_SLOTS + slot
      if (mask and (1 shl slot)) == 0: continue
      let (rows, cols) = loraSlotShape(state, slot)
      state.lora_a[idx]   = allocMatrix(rank, cols)
      state.m_lora_a[idx] = allocMatrix(rank, cols)
      state.v_lora_a[idx] = allocMatrix(rank, cols)
      state.g_lora_a[idx] = allocMatrix(rank, cols)
      state.lora_b[idx]   = allocMatrix(rows, rank)
      state.m_lora_b[idx] = allocMatrix(rows, rank)
      state.v_lora_b[idx] = allocMatrix(rows, rank)
      state.g_lora_b[idx] = allocMatrix(rows, rank)
      # A ~ U(-b, b) mit b = 1/sqrt(cols); B bleibt exakt 0 (allocShared0).
      let b = (1.0 / sqrt(cols.float32)).cfloat
      let na = rank.int * cols.int
      for e in 0 ..< na:
        state.lora_a[idx].data[e] = (nextF() * 2.0 - 1.0) * b

  state.lora_h = cast[ptr FloatArray](allocShared0(
    n * state.ctxSize.int * rank.int * sizeof(cfloat)))
  state.lora_dh = cast[ptr FloatArray](allocShared0(
    state.ctxSize.int * rank.int * sizeof(cfloat)))

  state.loraRank = rank
  state.loraAlpha = (if alpha > 0.0: alpha else: rank.cfloat)
  state.loraMask = mask
  state.loraFrozenBase = (if freezeBase != 0: 1 else: 0)

  # BEFUND 2026-08-29 (gefunden von diagnose/verify_lora_file.php):
  # adam_t kommt aus der Basisdatei und steht nach einem Vortraining bei
  # mehreren hundert. Die Adapter starten aber bei m=v=0 - mit einem hohen t
  # ist b1t/b2t praktisch 1, die Bias-Korrektur faellt also aus, und der ERSTE
  # Adapterschritt wird rund dreimal zu gross (m/sqrt(v) = 0,1g/0,0316|g|).
  # Bei eingefrorener Basis ist ihr Schrittzaehler ohnehin bedeutungslos - sie
  # bekommt keinen Adam-Schritt mehr, und ihr eigener Stand bleibt in der
  # unveraenderten Basisdatei erhalten. Also zuruecksetzen.
  # NICHT zuruecksetzen, wenn die Basis mittrainiert: dann ist es ihr Zaehler.
  if state.loraFrozenBase != 0: state.adam_t = 0

  # SPEICHERARM (2026-08-29): bei eingefrorener Basis wird ihr Optimierer-
  # Zustand nicht mehr gebraucht - also weg damit. Das ist der Punkt, an dem
  # LoRA in diesem Projekt ueberhaupt erst Speicher spart; ohne ihn war der
  # gemessene Verbrauch sogar leicht HOEHER als beim vollen Finetune.
  #
  # Folge, die der Aufrufer kennen muss: dieser Zustand kann danach die Basis
  # nicht mehr trainieren. Ein Versuch endet im bestehenden FATAL-Check von
  # cortex_train_step_i8() - laut, nicht still.
  if state.loraFrozenBase != 0: loraFreeBaseOptState(state)
  return 1

proc cortex_lora_active*(state: ptr CortexState): cint {.ffi.} =
  ## Fragt die WIRKUNG ab, nicht den Schalter - gleiche Linie wie
  ## cortex_get_tied_embeddings(). Ein gesetzter Rang ohne allokierte Adapter
  ## waere still wirkungslos.
  if not loraOn(state): return 0
  if state.lora_h.isNil or state.lora_dh.isNil: return 0
  var seen = 0
  for l in 0 ..< state.numLayers.int:
    for slot in 0 ..< LORA_SLOTS:
      if (state.loraMask.int and (1 shl slot)) == 0: continue
      let i = l * LORA_SLOTS + slot
      if state.lora_a[i].data.isNil or state.lora_b[i].data.isNil: return 0
      inc seen
  if seen == 0: return 0
  return 1

proc cortex_lora_rank*(state: ptr CortexState): cint {.ffi.} =
  if state.isNil: 0 else: state.loraRank

proc cortex_lora_mask*(state: ptr CortexState): cint {.ffi.} =
  if state.isNil: 0 else: state.loraMask

proc cortex_lora_base_frozen*(state: ptr CortexState): cint {.ffi.} =
  if state.isNil: 0 else: state.loraFrozenBase

proc cortex_lora_params*(state: ptr CortexState): cint {.ffi.} =
  ## Zahl der TRAINIERBAREN Adapter-Parameter. Wird im A/B gegen die
  ## Gesamtparameterzahl berichtet - der Loss allein sagt ueber LoRA nichts.
  if cortex_lora_active(state) == 0: return 0
  var total = 0
  for l in 0 ..< state.numLayers.int:
    for slot in 0 ..< LORA_SLOTS:
      if (state.loraMask.int and (1 shl slot)) == 0: continue
      let i = l * LORA_SLOTS + slot
      total += state.lora_a[i].rows.int * state.lora_a[i].cols.int
      total += state.lora_b[i].rows.int * state.lora_b[i].cols.int
  return total.cint

proc loraMatFor(state: ptr CortexState, layer, slot, isB: cint): ptr Matrix =
  if cortex_lora_active(state) == 0: return nil
  if layer < 0 or layer >= state.numLayers: return nil
  if slot < 0 or slot >= LORA_SLOTS.cint: return nil
  if (state.loraMask.int and (1 shl slot.int)) == 0: return nil
  let i = layer.int * LORA_SLOTS + slot.int
  if isB != 0: addr state.lora_b[i] else: addr state.lora_a[i]

proc cortex_lora_extract*(state: ptr CortexState, layer, slot, isB: cint,
                          raw: ptr cfloat, size: cint): cint {.ffi.} =
  ## Kopiert eine Adaptermatrix heraus (zum Speichern). 0 = nicht vorhanden
  ## oder Groesse passt nicht - bewusst kein Teilkopieren, das waere eine
  ## halbe Datei ohne Fehlermeldung.
  let m = loraMatFor(state, layer, slot, isB)
  if m.isNil or m[].data.isNil: return 0
  let need = m[].rows.int * m[].cols.int
  if size.int != need: return 0
  let dst = cast[ptr FloatArray](raw)
  for e in 0 ..< need: dst[e] = m[].data[e]
  return need.cint

proc cortex_lora_load*(state: ptr CortexState, layer, slot, isB: cint,
                       raw: ptr cfloat, size: cint): cint {.ffi.} =
  ## Gegenstueck zu cortex_lora_extract(). Setzt NUR das Gewicht, nicht die
  ## Adam-Momente - wer einen Lauf fortsetzt, muss die getrennt laden.
  let m = loraMatFor(state, layer, slot, isB)
  if m.isNil or m[].data.isNil: return 0
  let need = m[].rows.int * m[].cols.int
  if size.int != need: return 0
  let src = cast[ptr FloatArray](raw)
  for e in 0 ..< need: m[].data[e] = src[e]
  return need.cint

proc loraMomentFor(state: ptr CortexState, layer, slot, isB, isV: cint): ptr Matrix =
  if cortex_lora_active(state) == 0: return nil
  if layer < 0 or layer >= state.numLayers: return nil
  if slot < 0 or slot >= LORA_SLOTS.cint: return nil
  if (state.loraMask.int and (1 shl slot.int)) == 0: return nil
  let i = layer.int * LORA_SLOTS + slot.int
  if isB != 0:
    (if isV != 0: addr state.v_lora_b[i] else: addr state.m_lora_b[i])
  else:
    (if isV != 0: addr state.v_lora_a[i] else: addr state.m_lora_a[i])

proc cortex_lora_extract_adam*(state: ptr CortexState, layer, slot, isB, isV: cint,
                               raw: ptr cfloat, size: cint): cint {.ffi.} =
  ## Adam-Moment eines Adapters herauskopieren. Ohne die Momente waere ein
  ## fortgesetzter Lauf kein fortgesetzter Lauf: Adam startet dann jede Epoche
  ## neu mit m=v=0 und laeuft erst wieder warm. Bei einem A/B ueber mehrere
  ## Epochen ist das keine Kleinigkeit, sondern ein systematischer Unterschied
  ## zum Vollarm, der seine Momente im SNAI_V6-Block mitschreibt.
  let m = loraMomentFor(state, layer, slot, isB, isV)
  if m.isNil or m[].data.isNil: return 0
  let need = m[].rows.int * m[].cols.int
  if size.int != need: return 0
  let dst = cast[ptr FloatArray](raw)
  for e in 0 ..< need: dst[e] = m[].data[e]
  return need.cint

proc cortex_lora_load_adam*(state: ptr CortexState, layer, slot, isB, isV: cint,
                            raw: ptr cfloat, size: cint): cint {.ffi.} =
  let m = loraMomentFor(state, layer, slot, isB, isV)
  if m.isNil or m[].data.isNil: return 0
  let need = m[].rows.int * m[].cols.int
  if size.int != need: return 0
  let src = cast[ptr FloatArray](raw)
  for e in 0 ..< need: m[].data[e] = src[e]
  return need.cint

proc cortex_lora_set_adam_t*(state: ptr CortexState, t: cint): cint {.ffi.} =
  ## adam_t gehoert beim LoRA-Lauf zum Adapterzustand, nicht zur Basis: die
  ## Basisdatei bleibt bitgenau die alte und traegt ihr eigenes, eingefrorenes
  ## adam_t. Wer nur die Momente laedt und den Schrittzaehler auf 0 laesst,
  ## bekommt eine falsche Bias-Korrektur (b1t/b2t) und damit einen zu grossen
  ## ersten Schritt nach jedem Neustart.
  if state.isNil or t < 0: return 0
  state.adam_t = t
  return 1

proc cortex_lora_disable*(state: ptr CortexState) {.ffi.} =
  loraFreeAll(state)

proc rescaleQMatrix(qm: QMatrix) =
  ## Periodisches Re-Scaling (Plan, "Skalen-Lebenszyklus"): spreizt jede Zeile
  ## wieder auf das volle INT8-Gitter und zieht die Differenz in die
  ## Zeilen-Skala. Arbeitet direkt auf der INT8-Ground-Truth, kein FP32-
  ## Schatten noetig.
  ##
  ## OPTIMIERUNG (Audit 2026-08-19) - mathematisch IDENTISCH zur vorherigen
  ## Fassung, nur ohne den Umweg ueber Realwerte: mit qmax = max|q_int| gilt
  ##   maxAbs  = qmax * oldScale
  ##   newScale = maxAbs/127 = oldScale * qmax/127
  ##   new_q   = round(q*oldScale / newScale) = round(q * 127/qmax)
  ## - oldScale kuerzt sich exakt heraus. Daraus drei Gewinne:
  ##   1. Die Suchschleife ist ein reiner int8-Scan (keine Float-Multiplikation
  ##      pro Element mehr).
  ##   2. Zeilen, die bereits das volle Gitter ausnutzen (qmax == 127), sind
  ##      per Definition unveraendert und werden komplett uebersprungen. Genau
  ##      das ist nach dem ersten Re-Scaling der Normalfall fuer die meisten
  ##      Zeilen (cortex_rescale_weights() laeuft nach JEDEM Trainingsschritt).
  ##   3. Zeilen sind voneinander unabhaengig -> parallelisierbar (vorher
  ##      seriell).
  let cols = qm.cols.int
  {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
  # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
  for r in 0 || (qm.rows.int - 1):
    let off = r * cols
    var qmax: int32 = 0
    for c in 0 ..< cols:
      let a = abs(qm.data[off + c].int32)
      if a > qmax: qmax = a
    # qmax == 0: leere Zeile (Skala unveraendert lassen, kein Nullteiler).
    # qmax == 127: Gitter bereits voll ausgenutzt, new_q == q -> nichts zu tun.
    # Bewusst als if-Block statt `continue` formuliert: Nims OpenMP-`||`-
    # Schleife uebersetzt `continue` im Rumpf nicht (Compiler-Abbruch
    # "index out of bounds" bei der Codegenerierung, verifiziert).
    if qmax > 0 and qmax != 127:
      let factor = 127.0.cfloat / qmax.cfloat
      for c in 0 ..< cols:
        var q = round(qm.data[off + c].cfloat * factor).int
        if q > 127: q = 127
        elif q < -128: q = -128
        qm.data[off + c] = q.int8
      qm.scale[r] = qm.scale[r] * (qmax.cfloat / 127.0.cfloat)
  {.pop.}

proc cortex_rescale_weights*(state: ptr CortexState) {.ffi.} =
  ## GATE-BEFUND (Phase 2, siehe diagnose/gate_int8_vs_fp32.php): urspruenglich
  ## als seltene Wartung geplant (Plan-Dokument nannte "einmal pro Epoche" als
  ## konservativen Startwert). Am Gate zeigte sich: bei kleinskaligen Tensoren
  ## (v.a. w_out) fuehrt ein zu seltener Aufruf zu dauerhafter Saettigung aller
  ## Zeilenwerte auf +-128 (MAX_LSB_STEP_PER_UPDATE allein reicht nicht) -
  ## Loss blieb praktisch auf Zufalls-Niveau haengen. Aufruf nach JEDEM
  ## cortex_train_step_i8() (nicht nur an Epochengrenzen) war im Gate-Test
  ## noetig, damit selbst gesaettigte Zeilen weiter einen Vorzeichen-
  ## Gradientenabstieg vollziehen koennen - damit konvergierte der INT8-Pfad
  ## auf dem Mini-Korpus tatsaechlich (Loss ~3.87 -> ~0.00002, vergleichbar
  ## FP32). Kosten: ein voller O(Parameter)-Durchlauf zusaetzlich pro Schritt -
  ## bei echten Modellgroessen ein reales Performance-Thema fuer Phase 3+
  ## (denkbare Optimierung: nur Zeilen nahe der Saettigungsgrenze neu skalieren
  ## statt aller Zeilen - noch nicht umgesetzt/getestet).
  if state.isNil or state.weightDtype != 1: return
  # LoRA mit eingefrorener Basis: keine INT8-Zeile hat sich veraendert, also
  # gibt es auch nichts neu zu skalieren. Ein Durchlauf waere hier nicht nur
  # verschwendet - er wuerde die Basis-Zeilenskalen veraendern und damit die
  # Zusage brechen, dass die Basis bitgenau unberuehrt bleibt.
  if loraOn(state) and state.loraFrozenBase != 0: return
  rescaleQMatrix(state.embeddings_q8)
  # Bei Tying ist w_out_q8 derselbe Speicher - ein zweiter Durchlauf waere
  # zwar folgenlos (nach dem ersten gilt qmax == 127, die Schleife ueberspringt
  # dann jede Zeile), aber er kostet einen vollen O(vocab*dim)-Scan pro
  # Trainingsschritt fuer nichts.
  if state.tiedEmbeddings == 0:
    rescaleQMatrix(state.w_out_q8)
  for l in 0 ..< state.numLayers:
    rescaleQMatrix(state.w_q_q8[l])
    rescaleQMatrix(state.w_k_q8[l])
    rescaleQMatrix(state.w_v_q8[l])
    rescaleQMatrix(state.w_o_q8[l])
    rescaleQMatrix(state.w_up_q8[l])
    rescaleQMatrix(state.w_down_q8[l])
  # PHASE 7: Re-Scaling hat Daten UND Skalen host-seitig veraendert.
  markQWeightsDirty(state)

# --- INT8-TRAININGSSCHRITT (Spiegel von cortex_train_step(), Nicht-gebuendelter Pfad) ---

# ==============================================================================
# FULL-INT8 SCHRITT 2 (2026-08-24): ganzzahlige Gradienten-Akkumulation
# ------------------------------------------------------------------------------
# Letztes grosses Float-Stueck im Backward: gm[r,c] += sum_p d[p,r] * i[p,c].
#
# WARUM DAS EIN ANDERES PROBLEM IST als der d_in-Teil (Schritt 1): dort war
# eine REDUKTION zu quantisieren (viele Summanden, ein Ergebnis). Hier ist es
# ein AUSSENPRODUKT, das ueber die Positionsachse akkumuliert - und der
# Akkumulator lebt ueber alle Positionen hinweg. Eine Per-Position-Skala (wie
# im Forward fuer Aktivierungen) ist damit unbrauchbar: jeder Summand haette
# eine andere Skala, man koennte nicht in einem int32-Akkumulator summieren.
#
# DIE LOESUNG: die Skalen muessen nur ueber die POSITIONEN konstant sein, nicht
# ueber Zeilen/Spalten. Genau das erlaubt die Struktur des Aussenprodukts:
#
#   dScale[r] := max_p |d[p,r]| / 127     (eine Skala je ZEILE)
#   iScale[c] := max_p |i[p,c]| / 127     (eine Skala je SPALTE)
#   gm[r,c]   += (sum_p qd[p,r] * qi[p,c]) * dScale[r] * iScale[c]
#
# Die innere Summe ist reines int8xint8->int32 ueber alle Positionen; die
# beiden Skalen sind konstante Faktoren, die erst NACH der vollstaendigen
# Akkumulation einmal angewandt werden. Damit ist die Skalierung sogar
# FEINKOERNIGER als bei einer globalen Tensorskala - wichtig bei w_out, wo die
# Gradientenzeilen um Groessenordnungen auseinanderliegen (die meisten Token
# bekommen winzige Gradienten, das Ziel-Token einen grossen).
#
# UEBERLAUF: der Akkumulator sammelt batch * 127 * 127 = batch * 16.129. Selbst
# bei batch = 65.536 sind das 1,06e9 - innerhalb int32 (2,15e9). Der Guard
# unten prueft das trotzdem, weil der Header-Sanity-Check groessere ctx-Werte
# grundsaetzlich zulaesst.
proc cortex_set_i8_int_gradacc*(enabled: cint) {.ffi.} =
  i8_int_gradacc = enabled
  updateI8CpuOnly()

proc cortex_get_i8_int_gradacc*(): cint {.ffi.} =
  i8_int_gradacc


# GA-PREP-PAR (2026-11-08, patch_par4.py): parallele Vorstufen der int8-Gradientenakkumulation.
var gaModusV = -1
proc gaModus(): int =
  ## 0 Original, 1 parallel, 2 ROTI, 3 ROTQ, 4 ROTD, 5 ROTP. Einmal je Prozess.
  if gaModusV < 0:
    let e = c_getenv_z("SNAI_I8_GA")
    let t = (if e.isNil: "" else: $e)
    gaModusV = (if t == "0": 0 elif t == "ROTI": 2 elif t == "ROTQ": 3 elif t == "ROTD": 4 elif t == "ROTP": 5 else: 1)
    {.cast(gcsafe).}:
      try: stderr.writeLine("[GA] Vorstufen Gradientenakkumulation: ",
                            ["Originalpfad", "parallel", "parallel ROTI", "parallel ROTQ", "parallel ROTD", "parallel ROTP"][gaModusV])
      except: discard
  gaModusV
type GaArgs = object
  src, sc, fak: ptr FloatArray
  n, w, qiStride: int
  qi: ptr Int8Array
  pk: ptr UncheckedArray[int16]
const GA_BLK = 64
proc gaMaxBlk(a: ptr GaArgs, b: int) {.exportc: "snai_ga_maxblk", cdecl.} =
  ## sc[j] = max_p |src[p*w + j]| (* fak[p], falls gesetzt) / 127, je Spalte j des Blocks, p aufsteigend.
  let j0 = b * GA_BLK
  let j1 = min(j0 + GA_BLK, a.w)
  var mx: array[GA_BLK, cfloat]
  for j in 0 ..< GA_BLK: mx[j] = 0.0
  for p in 0 ..< a.n:
    let base = p * a.w
    if a.fak.isNil:
      for j in j0 ..< j1:
        let x = abs(a.src[base + j])
        if x > mx[j - j0]: mx[j - j0] = x
    else:
      let f = a.fak[p]
      for j in j0 ..< j1:
        let x = abs(a.src[base + j] * f)
        if x > mx[j - j0]: mx[j - j0] = x
  for j in j0 ..< j1:
    let m = mx[j - j0]
    a.sc[j] = (if m > 0.0: m / 127.0 else: 0.0)
proc gaMaxBlkC(a: ptr GaArgs, b: int) {.importc: "snai_ga_maxblk", cdecl.}
proc gaQiRow(a: ptr GaArgs, p: int) {.exportc: "snai_ga_qirow", cdecl.} =
  let ib = p * a.w
  let qb = p * a.qiStride
  for c in 0 ..< a.w:
    let s = a.sc[c]
    if s <= 0.0:
      a.qi[qb + c] = 0
    else:
      var q = round(a.src[ib + c] / s).int
      if q > 127: q = 127
      elif q < -128: q = -128
      a.qi[qb + c] = q.int8
proc gaQiRowC(a: ptr GaArgs, p: int) {.importc: "snai_ga_qirow", cdecl.}
proc gaPkRow(a: ptr GaArgs, pp: int) {.exportc: "snai_ga_pkrow", cdecl.} =
  let cols = a.w
  for k in 0 .. 1:
    let p = 2 * pp + k
    for c in 0 ..< cols:
      a.pk[(pp * cols + c) * 2 + k] = (if p < a.n: a.qi[p * a.qiStride + c].int16 else: 0'i16)
proc gaPkRowC(a: ptr GaArgs, pp: int) {.importc: "snai_ga_pkrow", cdecl.}
proc gaMax(src, sc, fak: ptr FloatArray, n, w: int) =
  var a = GaArgs(src: src, sc: sc, fak: fak, n: n, w: w)
  let ap = addr a
  let nbk = (w + GA_BLK - 1) div GA_BLK
  {.push checks: off.}
  for b in 0 || (nbk - 1):
    gaMaxBlkC(ap, b)
  {.pop.}
proc gaQi(src, sc: ptr FloatArray, qi: ptr Int8Array, qiStride, n, w: int) =
  var a = GaArgs(src: src, sc: sc, qi: qi, qiStride: qiStride, n: n, w: w)
  let ap = addr a
  {.push checks: off.}
  for p in 0 || (n - 1):
    gaQiRowC(ap, p)
  {.pop.}
proc gaPk(pk: ptr UncheckedArray[int16], qi: ptr Int8Array, qiStride, n, w, np: int) =
  var a = GaArgs(pk: pk, qi: qi, qiStride: qiStride, n: n, w: w)
  let ap = addr a
  {.push checks: off.}
  for pp in 0 || (np - 1):
    gaPkRowC(ap, pp)
  {.pop.}

proc gradAccumBatchedI8Int(gm: Matrix, d_out_all, i_all: ptr FloatArray,
                           batch: cint, qi: ptr Int8Array, qiStride: int,
                           dsc, isc: ptr FloatArray,
                           acc32: ptr IntArray, accStride, maxT: int, gmOnDevice: cint)
                          {.exportc: "snai_gradacc_i8", raises: [], gcsafe.} =
  ## Siehe Blockkommentar. `exportc` aus demselben Grund wie bei
  ## backwardDInI8(): der Aufruf steht in einer OpenMP-`||`-Schleife.
  let rows = gm.rows.int
  let cols = gm.cols.int
  let nb = batch.int

  let gaM = gaModus()
  if gaM != 0:
    gaMax(i_all, isc, nil, nb, cols)
    if gaM == 2: isc[0] = isc[0] + 1.0'f32
    gaQi(i_all, isc, qi, qiStride, nb, cols)
    if gaM == 3: qi[0] = qi[0] xor 1'i8
    gaMax(d_out_all, dsc, nil, nb, rows)
    if gaM == 4: dsc[0] = dsc[0] + 1.0'f32
  else:
    # 1. Spaltenskalen der Aktivierung + Quantisierung (einmal, sequenziell -
    #    alle Threads lesen das Ergebnis anschliessend nur).
    for c in 0 ..< cols:
      var mx: cfloat = 0.0
      for p in 0 ..< nb:
        let a = abs(i_all[p * cols + c])
        if a > mx: mx = a
      isc[c] = (if mx > 0.0: mx / 127.0 else: 0.0)
    for p in 0 ..< nb:
      let ib = p * cols
      let qb = p * qiStride
      for c in 0 ..< cols:
        let s = isc[c]
        if s <= 0.0:
          qi[qb + c] = 0
        else:
          var q = round(i_all[ib + c] / s).int
          if q > 127: q = 127
          elif q < -128: q = -128
          qi[qb + c] = q.int8

    # 2. Zeilenskalen des Gradienten.
    for r in 0 ..< rows:
      var mx: cfloat = 0.0
      for p in 0 ..< nb:
        let a = abs(d_out_all[p * rows + r])
        if a > mx: mx = a
      dsc[r] = (if mx > 0.0: mx / 127.0 else: 0.0)

  # 3a. GPU-Zweig: das Aussenprodukt ist der einzige rows*cols*batch grosse
  #     Posten hier; die Schritte 1/2 bleiben auf dem Host. Der Gradient muss
  #     dafuer EINMAL zusammenhaengend quantisiert werden - die CPU-Fassung
  #     macht das absichtlich zeilenweise on-the-fly, um genau diesen Puffer
  #     zu sparen, was auf der GPU nicht geht.
  if useGpuGradAccI8(rows, cols):
    let nq = nb * rows
    let qd = cast[ptr Int8Array](allocShared(nq))
    for p in 0 ..< nb:
      let db = p * rows
      for r in 0 ..< rows:
        let ds = dsc[r]
        if ds <= 0.0:
          qd[db + r] = 0
        else:
          var q = round(d_out_all[db + r] / ds).int
          if q > 127: q = 127
          elif q < -128: q = -128
          qd[db + r] = q.int8
    gpuGradAccumI8(addr qi[0], addr qd[0], addr dsc[0], addr isc[0],
                    addr gm.data[0], rows.cint, cols.cint, nb.cint, qiStride.cint,
                    gmOnDevice)
    deallocShared(qd)
    return

  # 3. Aussenprodukt: je Zeile ein int32-Akkumulator ueber ALLE Positionen,
  #    danach EINMAL dequantisieren. Parallel ueber die Zeilen - jede Zeile
  #    schreibt nur ihren eigenen Bereich von gm, also kein Race.
  #    Der Gradient wird hier on-the-fly quantisiert (siehe Alloc-Kommentar):
  #    das spart einen ctx x rows grossen Puffer.
  if dwGemmOn:
    # DW-GEMM (Schalter oben): Positionen paarweise als int16 verschraenkt, einmal je Aufruf; je Zeile die
    # quantisierten Gradientwerte als Paare, dann ein Registerblock-Kern. Rundung und Schlussrechnung wie unten.
    let np = (nb + 1) div 2
    let pk = cast[ptr UncheckedArray[int16]](allocShared(max(1, np * cols * 2) * sizeof(int16)))
    if gaModus() != 0:
      gaPk(pk, qi, qiStride, nb, cols, np)
      if gaModus() == 5: pk[0] = pk[0] xor 1'i16
    else:
     for pp in 0 ..< np:
      for k in 0 .. 1:
        let p = 2 * pp + k
        for c in 0 ..< cols:
          pk[(pp * cols + c) * 2 + k] = (if p < nb: qi[p * qiStride + c].int16 else: 0'i16)
    let qpAll = cast[ptr UncheckedArray[int32]](allocShared(max(1, maxT) * max(1, np) * sizeof(int32)))
    {.push checks: off.}
    for r in 0 || (rows - 1):
      let ds = dsc[r]
      if ds > 0.0:
        let off = r * cols
        let t = min(snaiOmpThread().int, maxT - 1)
        let acc = cast[ptr IntArray](addr acc32[t * accStride])
        let qp = cast[ptr UncheckedArray[int32]](addr qpAll[t * np])
        for pp in 0 ..< np:
          var w2: array[2, int]
          for k in 0 .. 1:
            let p = 2 * pp + k
            var q = 0
            if p < nb:
              q = round(d_out_all[p * rows + r] / ds).int
              if q > 127: q = 127
              elif q < -128: q = -128
            w2[k] = q
          qp[pp] = cast[int32]((cast[uint32](w2[0].int32) and 0xFFFF'u32) or (cast[uint32](w2[1].int32) shl 16))
        snaiDwRowsI8(addr pk[0], addr qp[0], np.cint, cast[ptr int32](addr acc[0]), cols.cint)
        for c in 0 ..< cols:
          gm.data[off + c] += acc[c].cfloat * ds * isc[c]
    {.pop.}
    deallocShared(pk); deallocShared(qpAll)
    return

  # KEIN `continue` in dieser Schleife: Nim's OpenMP-Codegen stuerzt damit ab
  # (IndexDefect im Compiler selbst). Deshalb durchgaengig if-Bloecke.
  {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
  # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
  for r in 0 || (rows - 1):
    let ds = dsc[r]
    if ds > 0.0:                    # sonst ist die ganze Zeile null
      let off = r * cols
      let t = min(snaiOmpThread().int, maxT - 1)
      let acc = cast[ptr IntArray](addr acc32[t * accStride])
      for c in 0 ..< cols: acc[c] = 0
      for p in 0 ..< nb:
        var q = round(d_out_all[p * rows + r] / ds).int
        if q > 127: q = 127
        elif q < -128: q = -128
        if q != 0:
          snaiAxpyI8I32(addr qi[p * qiStride], q.int8, addr acc[0], cols.cint)
      for c in 0 ..< cols:
        gm.data[off + c] += acc[c].cfloat * ds * isc[c]
  {.pop.}

# C-seitige Sicht (siehe backwardDInI8C zur Begruendung).
proc gradAccumBatchedI8IntC(gm: Matrix, d_out_all, i_all: ptr FloatArray,
                            batch: cint, qi: ptr Int8Array, qiStride: int,
                            dsc, isc: ptr FloatArray,
                            acc32: ptr IntArray, accStride, maxT: int, gmOnDevice: cint)
                           {.importc: "snai_gradacc_i8", nodecl.}

proc gradAccumBatchedQI8(gm: Matrix, d_out_all: ptr FloatArray, qi: QMatrix,
                         batch: cint, dsc: ptr FloatArray,
                         acc32: ptr IntArray, accStride, maxT: int, gmOnDevice: cint)
                        {.exportc: "snai_gradacc_qi8", raises: [], gcsafe.} =
  ## SCHRITT 4b: wie gradAccumBatchedI8Int, aber die Aktivierung liegt BEREITS
  ## quantisiert vor - mit einer Skala je POSITION statt je Spalte.
  ##
  ## Das aendert die Algebra an genau einer Stelle:
  ##   gm[r,c] += sum_p d[p,r] * (qi[p,c] * scale_i[p])
  ##            = sum_p (d[p,r] * scale_i[p]) * qi[p,c]
  ## Die Positionsskala wird also in den GRADIENTEN gezogen und dort mit
  ## quantisiert - dasselbe Muster wie in Schritt 1 beim Backward-GEMM. Die
  ## Spaltenskala iScale[c] entfaellt dadurch ersatzlos.
  let rows = gm.rows.int
  let cols = gm.cols.int
  let nb = batch.int

  # Zeilenskala des vorskalierten Gradienten.
  if gaModus() != 0:
    gaMax(d_out_all, dsc, qi.scale, nb, rows)
    if gaModus() == 4: dsc[0] = dsc[0] + 1.0'f32
  else:
   for r in 0 ..< rows:
    var mx: cfloat = 0.0
    for p in 0 ..< nb:
      let a = abs(d_out_all[p * rows + r] * qi.scale[p])
      if a > mx: mx = a
    dsc[r] = (if mx > 0.0: mx / 127.0 else: 0.0)

  # GPU: derselbe Kernel wie gradAccumBatchedI8Int - er rechnet
  # gm += acc * ds[r] * isc[c], und mit isc == 1 ist das genau die Algebra
  # dieser Variante (die Spaltenskala entfaellt hier ja ersatzlos). Kein
  # zweiter Kernel, also auch keine zweite Stelle, die auseinanderdriften
  # kann - dieselbe Ueberlegung wie beim gemeinsamen CPU-Kernel in 1b.
  if useGpuGradAccI8(rows, cols):
    let qd = cast[ptr Int8Array](allocShared(nb * rows))
    let one = cast[ptr FloatArray](allocShared(cols * sizeof(cfloat)))
    for c in 0 ..< cols: one[c] = 1.0
    for p in 0 ..< nb:
      let ob = p * rows
      for r in 0 ..< rows:
        let ds = dsc[r]
        if ds <= 0.0:
          qd[ob + r] = 0
        else:
          var q = round((d_out_all[ob + r] * qi.scale[p]) / ds).int
          if q > 127: q = 127
          elif q < -128: q = -128
          qd[ob + r] = q.int8
    gpuGradAccumI8(addr qi.data[0], addr qd[0], addr dsc[0], addr one[0],
                    addr gm.data[0], rows.cint, cols.cint, nb.cint, qi.cols,
                    gmOnDevice)
    deallocShared(qd); deallocShared(one)
    return

  if dwGemmOn:
    # DW-GEMM (Schalter oben): Positionen paarweise als int16 verschraenkt, einmal je Aufruf; je Zeile die
    # quantisierten Gradientwerte als Paare, dann ein Registerblock-Kern. Rundung und Schlussrechnung wie unten.
    let np = (nb + 1) div 2
    let pk = cast[ptr UncheckedArray[int16]](allocShared(max(1, np * cols * 2) * sizeof(int16)))
    if gaModus() != 0:
      gaPk(pk, qi.data, qi.cols.int, nb, cols, np)
      if gaModus() == 5: pk[0] = pk[0] xor 1'i16
    else:
     for pp in 0 ..< np:
      for k in 0 .. 1:
        let p = 2 * pp + k
        for c in 0 ..< cols:
          pk[(pp * cols + c) * 2 + k] = (if p < nb: qi.data[p * qi.cols.int + c].int16 else: 0'i16)
    let qpAll = cast[ptr UncheckedArray[int32]](allocShared(max(1, maxT) * max(1, np) * sizeof(int32)))
    {.push checks: off.}
    for r in 0 || (rows - 1):
      let ds = dsc[r]
      if ds > 0.0:
        let off = r * cols
        let t = min(snaiOmpThread().int, maxT - 1)
        let acc = cast[ptr IntArray](addr acc32[t * accStride])
        let qp = cast[ptr UncheckedArray[int32]](addr qpAll[t * np])
        for pp in 0 ..< np:
          var w2: array[2, int]
          for k in 0 .. 1:
            let p = 2 * pp + k
            var q = 0
            if p < nb:
              q = round((d_out_all[p * rows + r] * qi.scale[p]) / ds).int
              if q > 127: q = 127
              elif q < -128: q = -128
            w2[k] = q
          qp[pp] = cast[int32]((cast[uint32](w2[0].int32) and 0xFFFF'u32) or (cast[uint32](w2[1].int32) shl 16))
        snaiDwRowsI8(addr pk[0], addr qp[0], np.cint, cast[ptr int32](addr acc[0]), cols.cint)
        for c in 0 ..< cols:
          gm.data[off + c] += acc[c].cfloat * ds
    {.pop.}
    deallocShared(pk); deallocShared(qpAll)
    return

  {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
  # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
  for r in 0 || (rows - 1):
    let ds = dsc[r]
    if ds > 0.0:
      let off = r * cols
      let t = min(snaiOmpThread().int, maxT - 1)
      let acc = cast[ptr IntArray](addr acc32[t * accStride])
      for c in 0 ..< cols: acc[c] = 0
      for p in 0 ..< nb:
        var q = round((d_out_all[p * rows + r] * qi.scale[p]) / ds).int
        if q > 127: q = 127
        elif q < -128: q = -128
        if q != 0:
          snaiAxpyI8I32(addr qi.data[p * qi.cols.int], q.int8, addr acc[0], cols.cint)
      for c in 0 ..< cols:
        gm.data[off + c] += acc[c].cfloat * ds
  {.pop.}

# C-seitige Sicht (OpenMP-Block, siehe backwardDInI8C).
proc gradAccumBatchedQI8C(gm: Matrix, d_out_all: ptr FloatArray, qi: QMatrix,
                          batch: cint, dsc: ptr FloatArray,
                          acc32: ptr IntArray, accStride, maxT: int, gmOnDevice: cint)
                         {.importc: "snai_gradacc_qi8", nodecl.}

proc gradAccumBatchedI8Roh(qm: QMatrix, gm: Matrix, d_out_all, i_all: ptr FloatArray,
                        batch: cint, st: ptr CortexState = nil) =
  ## gm[r,c] += sum_p D_OUT[p,r] * I_V[p,c]. Das Gewicht kommt in dieser Formel
  ## gar nicht vor - der bestehende FP32-Kernel ist also unveraendert nutzbar,
  ## nur die GPU-Entscheidung haengt an der QMatrix.
  let rows = gm.rows.int
  let cols = gm.cols.int

  # REIHENFOLGE (2026-08-24): der Ganzzahl-Zweig steht VOR dem Float-GPU-Zweig.
  # Stand er dahinter, gewann bei aktiver GPU immer der Float-Kernel und die
  # Ganzzahl-Schalter waren wirkungslos - ohne jede Meldung. Genau dagegen gab
  # es vorher die i8_cpu_only_path-Sperre; die Reihenfolge loest es an der
  # Wurzel, statt die GPU pauschal stillzulegen.
  # SCHRITT 2: Ganzzahl-Variante, wenn eingeschaltet und Scratch vorhanden.
  # Die Ueberlaufschranke ist konservativ: batch*127*127 muss in int32 passen.
  if i8_int_gradacc != 0 and not st.isNil and st.i8_bwThreads > 0 and
     scratchThreadsOk(st) and
     not st.i8_gqi.isNil and not st.i8_gdscale.isNil and
     not st.i8_giscale.isNil and not st.i32_dacc.isNil and
     cols <= st.i8_gqiStride.int and rows <= st.i8_dqStride.int and
     cols <= st.i8_accStride.int and
     batch.int <= (high(int32).int div (127 * 127)):
    gradAccumBatchedI8IntC(gm, d_out_all, i_all, batch,
                           st.i8_gqi, st.i8_gqiStride.int,
                           st.i8_gdscale, st.i8_giscale,
                           st.i32_dacc, st.i8_accStride.int, st.i8_bwThreads.int,
                           (if useGpuQMat(qm): 1.cint else: 0.cint))
    return

  if useGpuQMat(qm):
    gpuGradAccumBatched(cast[ptr cfloat](gm.data), cast[ptr cfloat](d_out_all),
                         cast[ptr cfloat](i_all), gm.rows, gm.cols, batch)
    return

  {.push checks: off.}   # OpenMP: Laufzeitpruefungen erzeugen hier ein `goto` aus dem
  # strukturierten Block heraus, das GCC ablehnt. Siehe Kommentar an cortex_omp_probe.
  for r in 0 || (rows - 1):
    let off = r * cols
    for p in 0 ..< batch.int:
      let do_v = d_out_all[p * rows + r]
      let ib = p * cols
      for c in 0 ..< cols:
        gm.data[off + c] += do_v * i_all[ib + c]
  {.pop.}

# PHASE 8: Schalter zwischen gebuendeltem und Einzel-Pfad. Der Einzelpfad
# bleibt erhalten - er ist die gegen die unabhaengige PHP-Referenz verifizierte
# Fassung und damit der Vergleichsmassstab fuer den gebuendelten Pfad
# (diagnose/verify_int8_batched.php).
proc gradAccumBatchedI8(qm: QMatrix, gm: Matrix, d_out_all, i_all: ptr FloatArray,
                        batch: cint, st: ptr CortexState = nil) =
  zeitMiss(ZA_GA):
    gradAccumBatchedI8Roh(qm, gm, d_out_all, i_all, batch, st)

var batched_i8: cint = 1

proc cortex_set_batched_i8*(enabled: cint) {.ffi.} =
  batched_i8 = enabled

proc cortex_get_batched_i8*(): cint {.ffi.} =
  batched_i8

# --- ARM C: nur die letzten n Schichten trainieren (LoRA-Armvergleich) ---

proc cortex_set_train_last_layers*(state: ptr CortexState, n: cint): cint {.ffi.} =
  ## n = 0 schaltet ab (alles trainierbar, unveraendertes Verhalten).
  ## n > 0 friert alles ein ausser den sechs Gewichtsmatrizen der letzten n
  ## Transformer-Schichten. Rueckgabe: 1 = gesetzt, 0 = abgelehnt.
  ##
  ## Bewusst ein Zustandsfeld und keine globale Variable wie bei
  ## batched_i8/i8_float_adam: dies beschreibt EINEN Lauf, nicht die Engine.
  ## Zwei Arme im selben Prozess (wie in den verify-Skripten ueblich) duerfen
  ## sich hier nicht gegenseitig umschalten.
  if state.isNil: return 0
  if n < 0 or n > state.numLayers: return 0
  state.trainLastLayers = n
  1

proc cortex_get_train_last_layers*(state: ptr CortexState): cint {.ffi.} =
  if state.isNil: 0 else: state.trainLastLayers

proc cortex_count_trainable_i8*(state: ptr CortexState): cint {.ffi.} =
  ## Kennzahl des LoRA-Armvergleichs - trainierbare Parameter, aus dem
  ## TATSAECHLICHEN Zustand gerechnet statt aus der Geometrie nachgeschlagen.
  ## Ein Schalter, der gesetzt ist, muss nicht wirken (Lehre vom 2026-08-25);
  ## deshalb zaehlt diese Funktion genau die Tensoren, die
  ## applyGlobalAdamUpdateI8() auch wirklich anfasst.
  if state.isNil: return 0
  var n: int64 = 0
  if loraOn(state) and state.loraFrozenBase != 0:
    loraForEach(state):
      n += state.lora_a[i].rows.int64 * state.lora_a[i].cols.int64
      n += state.lora_b[i].rows.int64 * state.lora_b[i].cols.int64
    return n.cint
  if loraOn(state):
    loraForEach(state):
      n += state.lora_a[i].rows.int64 * state.lora_a[i].cols.int64
      n += state.lora_b[i].rows.int64 * state.lora_b[i].cols.int64
  if not lastLayerOnly(state):
    if state.tiedEmbeddings != 0:
      n += state.embeddings_q8.rows.int64 * state.embeddings_q8.cols.int64
    else:
      n += state.embeddings_q8.rows.int64 * state.embeddings_q8.cols.int64
      n += state.w_out_q8.rows.int64 * state.w_out_q8.cols.int64
    n += state.hiddenDim.int64
  for l in 0 ..< state.numLayers:
    if not lastLayerOnly(state):
      n += 2'i64 * state.hiddenDim.int64          # rms_att + rms_ffn
    if not layerTrainable(state, l.int): continue
    n += state.w_q_q8[l].rows.int64 * state.w_q_q8[l].cols.int64
    n += state.w_k_q8[l].rows.int64 * state.w_k_q8[l].cols.int64
    n += state.w_v_q8[l].rows.int64 * state.w_v_q8[l].cols.int64
    n += state.w_o_q8[l].rows.int64 * state.w_o_q8[l].cols.int64
    n += state.w_up_q8[l].rows.int64 * state.w_up_q8[l].cols.int64
    n += state.w_down_q8[l].rows.int64 * state.w_down_q8[l].cols.int64
  n.cint


{.emit: """
/* ATT-DWT (engine_opt/patch_dwt.py): dw[t] fuer t in [0,n), 8 t je AVX2-Register.
   vT zeigt auf Zeile i = h_off der transponierten V-Tabelle, Zeilenlaenge act. */
#ifdef __x86_64__
__attribute__((target("avx2")))
static void snai_dw_block_avx2(const float* datt, const float* vT, int act, int hs, int n, float* out) {
  int t = 0;
  for (; t + 8 <= n; t += 8) {
    __m256 acc = _mm256_setzero_ps();
    for (int d = 0; d < hs; d++) {
      __m256 v = _mm256_loadu_ps(vT + (long)d * act + t);
      acc = _mm256_add_ps(acc, _mm256_mul_ps(_mm256_set1_ps(datt[d]), v));
    }
    _mm256_storeu_ps(out + t, acc);
  }
  for (; t < n; t++) {
    float s = 0.0f;
    for (int d = 0; d < hs; d++) { float pr = datt[d] * vT[(long)d * act + t]; s = s + pr; }
    out[t] = s;
  }
}
#endif
static void snai_dw_block(const float* datt, const float* vT, int act, int hs, int n, float* out) {
#ifdef __x86_64__
  if (__builtin_cpu_supports("avx2")) { snai_dw_block_avx2(datt, vT, act, hs, n, out); return; }
#endif
  for (int t = 0; t < n; t++) {
    float s = 0.0f;
    for (int d = 0; d < hs; d++) { float pr = datt[d] * vT[(long)d * act + t]; s = s + pr; }
    out[t] = s;
  }
}
""".}
proc snaiDwBlock(datt, vT: ptr cfloat, act, hs, n: cint, outp: ptr cfloat) {.importc: "snai_dw_block", nodecl.}
{.emit: """
/* ATT-VEC (engine_opt/patch_vec.py): elementweise Aktualisierungen, bitgleich zum Skalarcode. */
#ifdef __x86_64__
__attribute__((target("avx2")))
static void snai_atv_axpy_f32_avx2(float* y, const float* x, float a, int n) {
  int i = 0; __m256 va = _mm256_set1_ps(a);
  for (; i + 8 <= n; i += 8)
    _mm256_storeu_ps(y + i, _mm256_add_ps(_mm256_loadu_ps(y + i), _mm256_mul_ps(_mm256_loadu_ps(x + i), va)));
  for (; i < n; i++) { float pr = x[i] * a; y[i] = y[i] + pr; }
}
__attribute__((target("avx2")))
static void snai_atv_axpy_dr_avx2(float* y, const float* x, double a, int n) {
  int i = 0; __m256d va = _mm256_set1_pd(a);
  for (; i + 4 <= n; i += 4) {
    __m256d p = _mm256_mul_pd(va, _mm256_cvtps_pd(_mm_loadu_ps(x + i)));
    _mm_storeu_ps(y + i, _mm_add_ps(_mm_loadu_ps(y + i), _mm256_cvtpd_ps(p)));
  }
  for (; i < n; i++) { float pr = (float)(a * (double)x[i]); y[i] = y[i] + pr; }
}
#endif
static void snai_atv_axpy_f32(float* y, const float* x, float a, int n) {
#ifdef __x86_64__
  if (__builtin_cpu_supports("avx2")) { snai_atv_axpy_f32_avx2(y, x, a, n); return; }
#endif
  for (int i = 0; i < n; i++) { float pr = x[i] * a; y[i] = y[i] + pr; }
}
static void snai_atv_axpy_dr(float* y, const float* x, double a, int n) {
#ifdef __x86_64__
  if (__builtin_cpu_supports("avx2")) { snai_atv_axpy_dr_avx2(y, x, a, n); return; }
#endif
  for (int i = 0; i < n; i++) { float pr = (float)(a * (double)x[i]); y[i] = y[i] + pr; }
}
""".}
proc snaiAxpyF32(y, x: ptr cfloat, a: cfloat, n: cint) {.importc: "snai_atv_axpy_f32", nodecl.}
proc snaiAxpyDR(y, x: ptr cfloat, a: cdouble, n: cint) {.importc: "snai_atv_axpy_dr", nodecl.}
{.emit: """
/* ATT-FWD (engine_opt/patch_fwd.py): Scores fuer t in [0,n), bitgleich zum Skalarcode. */
static void snai_atv_scores_skalar(const int8_t* q, const int8_t* kT, const float* ks, int act, int hs, int t0, int n,
                                   float qs, float dv, float* out) {
  for (int t = t0; t < n; t++) {
    int32_t acc = 0;
    for (int d = 0; d < hs; d++) acc += (int32_t)q[d] * (int32_t)kT[(long)d * act + t];
    float sc = ((float)acc * qs) * ks[t];
    sc = sc / dv;
    out[t] = sc;
  }
}
#ifdef __x86_64__
__attribute__((target("avx2")))
static void snai_atv_scores_avx2(const int8_t* q, const int8_t* kT, const float* ks, int act, int hs, int n,
                                 float qs, float dv, float* out) {
  int t = 0; __m256 vqs = _mm256_set1_ps(qs), vdv = _mm256_set1_ps(dv);
  for (; t + 8 <= n; t += 8) {
    __m256i acc = _mm256_setzero_si256();
    for (int d = 0; d < hs; d++) {
      __m256i kv = _mm256_cvtepi8_epi32(_mm_loadl_epi64((const __m128i*)(kT + (long)d * act + t)));
      acc = _mm256_add_epi32(acc, _mm256_mullo_epi32(_mm256_set1_epi32((int32_t)q[d]), kv));
    }
    __m256 f = _mm256_mul_ps(_mm256_mul_ps(_mm256_cvtepi32_ps(acc), vqs), _mm256_loadu_ps(ks + t));
    _mm256_storeu_ps(out + t, _mm256_div_ps(f, vdv));
  }
  snai_atv_scores_skalar(q, kT, ks, act, hs, t, n, qs, dv, out);
}
#endif
static void snai_atv_scores(const int8_t* q, const int8_t* kT, const float* ks, int act, int hs, int n,
                            float qs, float dv, float* out) {
#ifdef __x86_64__
  if (__builtin_cpu_supports("avx2")) { snai_atv_scores_avx2(q, kT, ks, act, hs, n, qs, dv, out); return; }
#endif
  snai_atv_scores_skalar(q, kT, ks, act, hs, 0, n, qs, dv, out);
}
""".}
proc snaiAtvScores(q, kT: pointer, ks: ptr cfloat, act, hs, n: cint, qs, dv: cfloat, outp: ptr cfloat) {.importc: "snai_atv_scores", nodecl.}

# ATT-BW-PAR (2026-10-14): Attention-Rueckwaerts eines Kopfes ueber alle Positionen (absteigend wie der
# serielle Pfad). Rechnung Zeile fuer Zeile wie dort; nur q kommt vorquantisiert, Scores/dW aus eigenem Puffer.
type AttBwArgs = object
  bSt: ptr CortexState
  bL, bAct, bDim: int
  bQ: ptr Int8Array
  bQs, bS, bW: ptr FloatArray
  bQuant, bRot: bool
  bWc: ptr FloatArray   # ATT-W-CACHE: Gewichte der Schicht aus dem Vorwaerts, nil = neu rechnen
  bKf, bVf: ptr FloatArray   # ATT-DEQ: entquantisierte K/V der Schicht (nur mit bWc)
  bVT: ptr FloatArray   # ATT-DWT: transponierte V-Tabelle der Schicht (nur mit bWc)
  bXRot: bool           # ATT-VEC: Rot-Probe
  bWRot: bool
  bBlk: ptr FloatArray  # ATT-BW-BLK (par7): Blockpuffer je Kopf, nil = alter Zweig (nur mit bWc)
  bBRot: bool           # ATT-BW-BLK: Rot-Probe
  bBlkDs: ptr UncheckedArray[cdouble]  # ATT-BW-BLK: ds je Kopf als double (wie im alten Zweig), P x act

const attBwBlkP = 16      # ATT-BW-BLK: Positionen je Block
const attBwBlkMinDim = 256   # ATT-BW-BLK AUTO: Blockpfad ab dieser Breite (festgelegt 09.11., e591)
const attBwBlkTc = 128    # ATT-BW-BLK: Spaltenstueck fuer dw (vT-Stueck 64 x 128 floats = 32 KB)
proc attBwBlkPerHead(act: int): int = 3 * attBwBlkP * act + attBwBlkP * 256

proc snaiAttBwHeadBlk(a: ptr AttBwArgs, h: int) =
  ## ATT-BW-BLK (par7): ATT-W-CACHE-Zweig von snaiAttBwHead in Bloecken zu attBwBlkP Positionen.
  ## Je Element dieselbe Folge von Rechenschritten wie im Original (siehe patch_par7.py).
  let state = a.bSt
  let l = a.bL
  let dim = a.bDim
  let act = a.bAct
  let hs = state.headSize.int
  let h_off = h * hs
  let attScale = 1.0 / sqrt(state.headSize.float32)
  doAssert state.headSize <= 256
  const P = attBwBlkP
  let bb = cast[ptr FloatArray](addr a.bBlk[h * attBwBlkPerHead(act)])
  let oW = P * act
  let oS = 2 * P * act
  let oQ = 3 * P * act
  let bd = cast[ptr UncheckedArray[cdouble]](addr a.bBlkDs[h * P * act])
  let kf = a.bKf
  let vT = a.bVT
  let triH = h * (act * (act + 1) div 2)
  var p0 = act - 1
  while p0 >= 0:
    let nb = min(P, p0 + 1)          # Zeilen r = 0 .. nb-1, Position p = p0 - r
    # Phase A1: d_q nullen, q der Zeile
    for r in 0 ..< nb:
      let p = p0 - r
      let off = p * dim
      let qs8 = cast[ptr Int8Array](addr a.bQ[off])
      let qScaleBw: cfloat = a.bQs[p]
      for d in 0 ..< state.headSize: state.d_q_all[off + h_off + d] = 0.0
      for d in 0 ..< state.headSize: bb[oQ + r * 256 + d] = qs8[h_off + d].cfloat * qScaleBw
    # Phase A2: dw je Zeile, Spaltenstuecke aussen (vT-Stueck bleibt im Cache)
    var tc = 0
    while tc <= p0:
      for r in 0 ..< nb:
        let p = p0 - r
        let n = min(attBwBlkTc, p + 1 - tc)
        if n > 0:
          let d_att = cast[ptr FloatArray](addr state.d_att_out_all[p * dim])
          snaiDwBlock(cast[ptr cfloat](addr d_att[h_off]), cast[ptr cfloat](addr vT[h_off * act + tc]),
                      act.cint, state.headSize.cint, n.cint, cast[ptr cfloat](addr bb[r * act + tc]))
      tc += attBwBlkTc
    # Phase A3: w, Summe, ds je Zeile (Ausdruecke wie im Original)
    for r in 0 ..< nb:
      let p = p0 - r
      let wb = triH + p * (p + 1) div 2
      var sum_w_dw: cfloat = 0.0
      for t in 0 .. p:
        var w = a.bWc[wb + t]
        if a.bWRot and h == 0: w = w * 1.0001'f32
        bb[oW + r * act + t] = w
        let dw = bb[r * act + t]
        sum_w_dw += w * dw
      for t in 0 .. p:
        let w = bb[oW + r * act + t]
        var ds = w * (bb[r * act + t] - sum_w_dw) * attScale
        if a.bRot and h == 0: ds = ds * 1.0001'f32
        if a.bBRot and h == 0 and p == act - 1 and t == 0: ds = ds + 1.0'f32
        bd[r * act + t] = ds
    # Phase B: t aufsteigend einmal je Block; je t die Zeilen p absteigend (r aufsteigend)
    for t in 0 .. p0:
      let d_v_t = cast[ptr FloatArray](addr state.d_v_cache[l].data[t * dim])
      let d_k_t = cast[ptr FloatArray](addr state.d_k_cache[l].data[t * dim])
      let rmax = min(nb - 1, p0 - t)
      for r in 0 .. rmax:
        let p = p0 - r
        let w = bb[oW + r * act + t]
        let ds = bd[r * act + t]
        let d_att = cast[ptr FloatArray](addr state.d_att_out_all[p * dim])
        snaiAxpyF32(cast[ptr cfloat](addr d_v_t[h_off]), cast[ptr cfloat](addr d_att[h_off]), w, state.headSize.cint)
        snaiAxpyDR(cast[ptr cfloat](addr state.d_q_all[p * dim + h_off]), cast[ptr cfloat](addr kf[t * dim + h_off]),
                   ds, state.headSize.cint)
        snaiAxpyDR(cast[ptr cfloat](addr d_k_t[h_off]), cast[ptr cfloat](addr bb[oQ + r * 256]),
                   (if a.bXRot: ds * 1.0001 else: ds), state.headSize.cint)
    p0 -= nb

proc snaiAttBwHead(a: ptr AttBwArgs, h: int) {.exportc: "snai_att_bw_head", cdecl.} =
  if not a.bBlk.isNil:
    snaiAttBwHeadBlk(a, h)
    return
  let state = a.bSt
  let l = a.bL
  let dim = a.bDim
  let act = a.bAct
  let h_off = h * state.headSize
  let scb = cast[ptr FloatArray](addr a.bS[h * act])
  let dwb = cast[ptr FloatArray](addr a.bW[h * act])
  let bwQ = a.bQuant
  let attScale = 1.0 / sqrt(state.headSize.float32)
  template kElem(t, idx: int): cfloat =
    state.k_cache_q8[l].data[t * dim + idx].cfloat * state.k_cache_q8[l].scale[t]
  template vElem(t, idx: int): cfloat =
    state.v_cache_q8[l].data[t * dim + idx].cfloat * state.v_cache_q8[l].scale[t]
  for p in countdown(act - 1, 0):
    let off = p * dim
    let q_p = cast[ptr FloatArray](addr state.act_q[l].data[off])
    let d_att = cast[ptr FloatArray](addr state.d_att_out_all[off])
    let qs8 = cast[ptr Int8Array](addr a.bQ[if bwQ: off else: 0])
    let qScaleBw: cfloat = (if bwQ: a.bQs[p] else: 1.0)
    template qElem(idx: int): cfloat =
      (if bwQ: qs8[idx].cfloat * qScaleBw else: q_p[idx])
    for d in 0 ..< state.headSize: state.d_q_all[off + h_off + d] = 0.0
    if not a.bWc.isNil:
      # ATT-W-CACHE: w kommt bitgleich aus dem Vorwaerts; Rest unveraendert.
      let wb = h * (act * (act + 1) div 2) + p * (p + 1) div 2
      let kf = a.bKf
      let vf = a.bVf
      var qh: array[256, cfloat]
      doAssert state.headSize <= 256
      for d in 0 ..< state.headSize: qh[d] = qElem(h_off + d)
      var sum_w_dw: cfloat = 0.0
      snaiDwBlock(cast[ptr cfloat](addr d_att[h_off]), cast[ptr cfloat](addr a.bVT[h_off * act]),
                  act.cint, state.headSize.cint, (p + 1).cint, cast[ptr cfloat](addr dwb[0]))
      for t in 0 .. p:
        var w = a.bWc[wb + t]
        if a.bWRot and h == 0: w = w * 1.0001'f32
        scb[t] = w
        let dw = dwb[t]
        let d_v_t = cast[ptr FloatArray](addr state.d_v_cache[l].data[t * dim])
        snaiAxpyF32(cast[ptr cfloat](addr d_v_t[h_off]), cast[ptr cfloat](addr d_att[h_off]), w, state.headSize.cint)
        dwb[t] = dw
        sum_w_dw += w * dw
      for t in 0 .. p:
        let w = scb[t]
        var ds = w * (dwb[t] - sum_w_dw) * attScale
        if a.bRot and h == 0: ds = ds * 1.0001'f32
        let d_k_t = cast[ptr FloatArray](addr state.d_k_cache[l].data[t * dim])
        snaiAxpyDR(cast[ptr cfloat](addr state.d_q_all[off + h_off]), cast[ptr cfloat](addr kf[t * dim + h_off]),
                   ds.cdouble, state.headSize.cint)
        snaiAxpyDR(cast[ptr cfloat](addr d_k_t[h_off]), cast[ptr cfloat](addr qh[0]),
                   (if a.bXRot: ds.cdouble * 1.0001 else: ds.cdouble), state.headSize.cint)
      continue
    var max_s: cfloat = NegInf.cfloat
    for t in 0 .. p:
      var sc: cfloat = 0.0
      if bwQ:
        let kRow = t * dim
        var acc: int32 = 0
        for d in 0 ..< state.headSize:
          acc += int32(qs8[h_off + d]) * int32(state.k_cache_q8[l].data[kRow + h_off + d])
        sc = acc.cfloat * qScaleBw * state.k_cache_q8[l].scale[t]
        sc /= sqrt(state.headSize.float32)
      else:
        for d in 0 ..< state.headSize:
          sc += q_p[h_off + d] * kElem(t, h_off + d)
        sc *= attScale
      scb[t] = sc
      if sc > max_s: max_s = sc
    var sum_e: cfloat = 0.0
    for t in 0 .. p:
      scb[t] = exp(scb[t] - max_s)
      sum_e += scb[t]
    var sum_w_dw: cfloat = 0.0
    for t in 0 .. p:
      let w = scb[t] / sum_e
      scb[t] = w
      var dw: cfloat = 0.0
      for d in 0 ..< state.headSize:
        dw += d_att[h_off + d] * vElem(t, h_off + d)
      let d_v_t = cast[ptr FloatArray](addr state.d_v_cache[l].data[t * dim])
      for d in 0 ..< state.headSize:
        d_v_t[h_off + d] += d_att[h_off + d] * w
      dwb[t] = dw
      sum_w_dw += w * dw
    for t in 0 .. p:
      let w = scb[t]
      var ds = w * (dwb[t] - sum_w_dw) * attScale
      if a.bRot and h == 0: ds = ds * 1.0001'f32
      let d_k_t = cast[ptr FloatArray](addr state.d_k_cache[l].data[t * dim])
      for d in 0 ..< state.headSize:
        state.d_q_all[off + h_off + d] += ds * kElem(t, h_off + d)
        d_k_t[h_off + d] += ds * qElem(h_off + d)
proc snaiAttBwHeadC(a: ptr AttBwArgs, h: int) {.importc: "snai_att_bw_head", cdecl.}

# ATT-FWD-PAR (2026-11-08, messbuch snai/att-fwd-par): Attention-Vorwaerts eines Kopfes ueber alle
# Positionen. Rechnung wie die serielle Positionsschleife in trainStepI8Batched; q kommt vorquantisiert
# (dieselbe quantizeActivation je Position), Scores aus eigenem Puffer je Kopf. outp ist vorher genullt.
type AttFwdArgs = object
  fSt: ptr CortexState
  fL, fAct, fDim: int
  fQ: ptr Int8Array
  fQs, fS: ptr FloatArray
  fRot: bool
  fW, fVf: ptr FloatArray   # par5: ATT-W-Ablage der Schicht und entquantisiertes V (nil = aus)
  fKT8: ptr Int8Array       # par6: kT8[i*act + t] (nur mit fW)
  fTri: int

proc snaiAttFwdHead(a: ptr AttFwdArgs, h: int) {.exportc: "snai_att_fwd_head", cdecl.} =
  let state = a.fSt
  let l = a.fL
  let dim = a.fDim
  let act = a.fAct
  let h_off = h * state.headSize
  let scb = cast[ptr FloatArray](addr a.fS[h * act])
  for p in 0 ..< act:
    let off = p * dim
    let outp = cast[ptr FloatArray](addr state.act_att_out[l][off])
    let qs8 = cast[ptr Int8Array](addr a.fQ[off])
    let qScale = a.fQs[p]
    var max_s: cfloat = NegInf.cfloat
    if not a.fW.isNil:
      snaiAtvScores(addr qs8[h_off], addr a.fKT8[h_off * act],
                    cast[ptr cfloat](addr state.k_cache_q8[l].scale[0]), act.cint, state.headSize, (p + 1).cint,
                    qScale, sqrt(state.headSize.float32), cast[ptr cfloat](addr scb[0]))
      for t in 0 .. p:
        let sc = scb[t]
        if sc > max_s: max_s = sc
    else:
      for t in 0 .. p:
        let kRow = t * dim
        var acc: int32 = 0
        for d in 0 ..< state.headSize:
          acc += int32(qs8[h_off + d]) * int32(state.k_cache_q8[l].data[kRow + h_off + d])
        var sc = acc.cfloat * qScale * state.k_cache_q8[l].scale[t]
        sc /= sqrt(state.headSize.float32)
        scb[t] = sc
        if sc > max_s: max_s = sc
    var sum_e: cfloat = 0.0
    for t in 0 .. p:
      scb[t] = exp(scb[t] - max_s)
      sum_e += scb[t]
    if not a.fW.isNil:
      let awBase = h * a.fTri + p * (p + 1) div 2
      for t in 0 .. p:
        let w = scb[t] / sum_e
        a.fW[awBase + t] = w
        let vRow = t * dim
        snaiAxpyF32(cast[ptr cfloat](addr outp[h_off]), cast[ptr cfloat](addr a.fVf[vRow + h_off]), w, state.headSize)
    else:
      for t in 0 .. p:
        let w = scb[t] / sum_e
        let vRow = t * dim
        let vScale = state.v_cache_q8[l].scale[t]
        for d in 0 ..< state.headSize:
          outp[h_off + d] += (state.v_cache_q8[l].data[vRow + h_off + d].cfloat * vScale) * w
    if a.fRot and h == 0 and p == act - 1: outp[0] = outp[0] * 1.0001'f32
proc snaiAttFwdHeadC(a: ptr AttFwdArgs, h: int) {.importc: "snai_att_fwd_head", cdecl.}

# SM-PAR (2026-11-08): Softmax, Loss-Beitrag und d_logits einer Position. Wie die beiden seriellen
# Positionsschleifen in trainStepI8Batched; der Loss-Beitrag geht in sLoss[p], summiert wird danach seriell.
type SmArgs = object
  sLog: ptr FloatArray
  sTg, sMask: ptr IntArray
  sLoss: ptr FloatArray
  sVocab: cint
  sRot: bool

proc snaiSmRow(a: ptr SmArgs, p: int) {.exportc: "snai_sm_row", cdecl.} =
  let logits_all = a.sLog
  let vocab = a.sVocab
  var tgid = a.sTg[p]
  if tgid < 0 or tgid >= vocab: tgid = 0
  let base = p * vocab
  var max_l: cfloat = -9999.0
  for v in 0 ..< vocab:
    if logits_all[base + v] > max_l: max_l = logits_all[base + v]
  var sum_p: cfloat = 0.0
  for v in 0 ..< vocab:
    logits_all[base + v] = exp(logits_all[base + v] - max_l)
    sum_p += logits_all[base + v]
  for v in 0 ..< vocab:
    logits_all[base + v] /= sum_p
  a.sLoss[p] = 0.0
  if a.sMask[p] != 0:
    a.sLoss[p] = -ln(logits_all[base + tgid] + 1e-7)
  if a.sMask[p] != 0:
    for v in 0 ..< vocab:
      logits_all[base + v] = logits_all[base + v] - smoothedTarget(v, tgid, vocab)
  else:
    for v in 0 ..< vocab: logits_all[base + v] = 0.0
  if a.sRot and p == 0: logits_all[base] = logits_all[base] * 1.0001'f32
proc snaiSmRowC(a: ptr SmArgs, p: int) {.importc: "snai_sm_row", cdecl.}

proc c_getenv_af(name: cstring): cstring {.importc: "getenv", header: "<stdlib.h>".}
var attFwdModeV = -1
var smParModeV = -1
proc parModus(name: string, v: var int, etikett: string): int =
  ## 0 seriell, 1 parallel, 2 parallel + ROT-Probe. Einmal je Prozess.
  if v < 0:
    let e = c_getenv_af(name.cstring)
    let s = (if e.isNil: "" else: $e)
    v = (if s == "0": 0 elif s == "ROT": 2 else: 1)
    stderr.writeLine("[", etikett, "] ", (if v == 0: "seriell (" & name & "=0)" elif v == 2: "parallel ROT-PROBE" else: "parallel"))
  v

# ==============================================================================
# PAR-SCHLEIFEN (2026-11-08, messbuch snai/par-schleifen, patch_par2.py)
# ==============================================================================
proc c_getenv_par(name: cstring): cstring {.importc: "getenv", header: "<stdlib.h>".}
const PG_ATT = 1; const PG_SM = 2; const PG_NORM = 4; const PG_QKV = 8; const PG_FFN = 16
const PG_ROPEBW = 32; const PG_NORMBW = 64; const PG_EMB = 128; const PG_VEC = 256
const PG_NAMEN = ["att", "sm", "norm", "qkv", "ffn", "ropebw", "normbw", "emb", "vec"]
var parMaskeV = -1
var parRotV = 0
proc parInit() =
  if parMaskeV >= 0: return
  let e = c_getenv_par("SNAI_I8_PAR")
  var m = 0
  if e.isNil: m = 511
  else:
    let s = $e
    if s == "0": m = 0
    else:
      var t = ""
      for ch in s & ",":
        if ch == ',':
          for i, n in PG_NAMEN:
            if t == n: m = m or (1 shl i)
          t = ""
        elif ch != ' ': t.add(ch)
  let r = c_getenv_par("SNAI_I8_PAR_ROT")
  var rb = 0
  if not r.isNil:
    for i, n in PG_NAMEN:
      if $r == n: rb = 1 shl i
  parMaskeV = m
  parRotV = rb
  var txt = ""
  for i, n in PG_NAMEN:
    if (m and (1 shl i)) != 0: txt.add(n & " ")
  stderr.writeLine("[PAR] Gruppen parallel: ", (if txt.len == 0: "keine" else: txt),
                   (if rb != 0: " ROT-PROBE " & $r else: ""))
proc parOn(g: int): bool =
  parInit()
  (parMaskeV and g) != 0
proc parRot(g: int): bool =
  parInit()
  (parRotV and g) != 0

type ParArgs = object
  st: ptr CortexState
  l, act, dim, ffn, modus, vocab: int
  a, b, w, c: ptr FloatArray
  qm: QMatrix
  tin: ptr IntArray
  rot: bool

# --- norm: RMSNorm vorwaerts einer Zeile ---
proc parNormRow(a: ptr ParArgs, p: int) {.exportc: "snai_par_norm", cdecl.} =
  applyRMSNorm(cast[ptr FloatArray](addr a.a[p * a.dim]), cast[ptr FloatArray](addr a.b[p * a.dim]),
               a.dim.cint, a.w)
  if a.rot and p == 0: a.b[0] = a.b[0] * 1.0001'f32
proc parNormRowC(a: ptr ParArgs, p: int) {.importc: "snai_par_norm", cdecl.}
proc parNorm(st: ptr CortexState, src, dst, w: ptr FloatArray, act, dim: cint) =
  if parOn(PG_NORM):
    var a = ParArgs(st: st, act: act.int, dim: dim.int, a: src, b: dst, w: w, rot: parRot(PG_NORM))
    let ap = addr a
    {.push checks: off.}
    for p in 0 || (act - 1):
      parNormRowC(ap, p)
    {.pop.}
  else:
    for p in 0 ..< act:
      applyRMSNorm(cast[ptr FloatArray](addr src[p * dim]),
                   cast[ptr FloatArray](addr dst[p * dim]),
                   dim, w)

# --- qkv: modus 0 = K (RoPE + Quant), 1 = V (Quant), 2 = Q (RoPE) ---
proc parQkvRow(a: ptr ParArgs, p: int) {.exportc: "snai_par_qkv", cdecl.} =
  let st = a.st
  let dim = a.dim.cint
  let pc = p.cint
  let v = cast[ptr FloatArray](addr a.a[p * a.dim])
  if a.modus == 0:
    applyRoPE(v, dim, st.headSize, st.ctxSize, pc)
    quantizeVectorToQ8Row(v, a.qm, pc, dim)
  elif a.modus == 1:
    quantizeVectorToQ8Row(v, a.qm, pc, dim)
  else:
    applyRoPE(v, dim, st.headSize, st.ctxSize, pc)
    if a.rot and p == a.act - 1: v[0] = v[0] * 1.0001'f32
proc parQkvRowC(a: ptr ParArgs, p: int) {.importc: "snai_par_qkv", cdecl.}
proc parQkv(st: ptr CortexState, buf: ptr FloatArray, qm: QMatrix, modus: int, act, dim: cint) =
  var a = ParArgs(st: st, act: act.int, dim: dim.int, a: buf, qm: qm, modus: modus, rot: parRot(PG_QKV))
  let ap = addr a
  {.push checks: off.}
  for p in 0 || (act - 1):
    parQkvRowC(ap, p)
  {.pop.}

var siluExpModeV = -1
proc siluExpMode(): int =
  ## SILU-EXP: 0 aus, 1 an, 2 an + ROT-Probe. Einmal je Prozess (erster Aufruf ausserhalb paralleler Schleifen).
  if siluExpModeV < 0:
    let e = c_getenv_par("SNAI_I8_SILU_EXP")
    let s = (if e.isNil: "" else: $e)
    siluExpModeV = (if s == "0": 0 elif s == "ROT": 2 elif s == "ROTL": 3 else: 1)
    stderr.writeLine("[SILU-EXP] expf der SiLU-Ableitung aus der Vorwaerts-Tabelle: ",
                     (if siluExpModeV == 0: "aus (SNAI_I8_SILU_EXP=0)" elif siluExpModeV == 2: "an, ROT-PROBE" elif siluExpModeV == 3: "an, ROT-PROBE letzte Schicht" else: "an"))
  siluExpModeV
proc siluExpRow(st: ptr CortexState, l, p: int): ptr FloatArray {.inline.} =
  ## Zeile p der expf-Tabelle von Schicht l, nil wenn SILU-EXP aus ist.
  if siluExpMode() > 0 and not st.silu_exp.isNil: cast[ptr FloatArray](addr st.silu_exp[l][p * 256]) else: nil
proc siluExpRot(st: ptr CortexState, ex: ptr FloatArray, l, p: int) {.inline.} =
  ## ROT: Schicht 0, Position 0. ROTL: letzte Schicht, Position 1 (zeigt, dass auch dort die Tabelle gelesen wird).
  if ex.isNil: return
  if (siluExpModeV == 2 and l == 0 and p == 0) or (siluExpModeV == 3 and l == st.numLayers.int - 1 and p == 1):
    for q in 0 ..< 256: ex[q] = ex[q] + 1.0'f32
proc siluExpUse(st: ptr CortexState, l: int): bool {.inline.} =
  siluExpMode() > 0 and st.quantActsIn != 0 and not st.silu_exp_ok.isNil and st.silu_exp_ok[l] != 0
# --- ffn: modus 0 = Quant einer Zeile (Laenge ffn), 1 = SiLU-Tabelle, 2 = SiLU-Ableitung ---
proc parFfnRow(a: ptr ParArgs, p: int) {.exportc: "snai_par_ffn", cdecl.} =
  let st = a.st
  let ffn = a.ffn
  if a.modus == 0:
    quantizeVectorToQ8Row(cast[ptr FloatArray](addr a.a[p * ffn]), a.qm, p.cint, ffn.cint)
  elif a.modus == 1:
    var lut: array[256, cfloat]
    let ex = siluExpRow(st, a.l, p)
    siluRowFromQ8(a.qm, p, a.b, p * ffn, ffn, cast[ptr FloatArray](addr lut[0]), ex)
    siluExpRot(st, ex, a.l, p)
    if a.rot and p == 0: a.b[0] = a.b[0] * 1.0001'f32
  elif siluExpUse(st, a.l):
    let l = a.l
    let tab = cast[ptr FloatArray](addr st.silu_exp[l][p * 256])
    let sc = st.act_ffn_in_q8[l].scale[p]
    for i in p * ffn ..< (p + 1) * ffn:
      let dq = st.act_ffn_in_q8[l].data[i]
      let x = dq.cfloat * sc
      let ex = tab[dq.int + 128]
      let sig = 1.0 / (1.0 + ex)
      st.mm_ffn_scratch[i] *= sig * (1.0 + x * (1.0 - sig))
  else:
    let l = a.l
    for i in p * ffn ..< (p + 1) * ffn:
      let x = (if st.quantActsIn != 0:
                 st.act_ffn_in_q8[l].data[i].cfloat * st.act_ffn_in_q8[l].scale[i div ffn]
               else: st.act_ffn_in[l][i])
      let sig = 1.0 / (1.0 + exp(-x))
      st.mm_ffn_scratch[i] *= sig * (1.0 + x * (1.0 - sig))
proc parFfnRowC(a: ptr ParArgs, p: int) {.importc: "snai_par_ffn", cdecl.}
proc parFfn(st: ptr CortexState, l, modus: int, buf, dst: ptr FloatArray, qm: QMatrix, act, ffn: cint) =
  var a = ParArgs(st: st, l: l, act: act.int, ffn: ffn.int, a: buf, b: dst, qm: qm, modus: modus,
                  rot: parRot(PG_FFN))
  discard siluExpMode()   # Stellrad vor der parallelen Schleife lesen
  let ap = addr a
  {.push checks: off.}
  for p in 0 || (act - 1):
    parFfnRowC(ap, p)
  {.pop.}

# --- ropebw ---
proc parRopeBwRow(a: ptr ParArgs, p: int) {.exportc: "snai_par_ropebw", cdecl.} =
  let st = a.st
  let dim = a.dim.cint
  applyRoPE(cast[ptr FloatArray](addr a.a[p * a.dim]), dim, st.headSize, st.ctxSize, p.cint, true)
  applyRoPE(cast[ptr FloatArray](addr a.b[p * a.dim]), dim, st.headSize, st.ctxSize, p.cint, true)
  if a.rot and p == 0: a.a[0] = a.a[0] * 1.0001'f32
proc parRopeBwRowC(a: ptr ParArgs, p: int) {.importc: "snai_par_ropebw", cdecl.}

# --- normbw: Zeile p -> d (in a.c, Zeile p) und Gain-Beitrag (in a.b, Zeile p) ---
proc rmsBwBeitrag(d_out, a_i: ptr FloatArray, dim: cint, w, beitrag: ptr FloatArray) =
  ## Wie applyRMSNormBackwardAcc, aber statt `gw[d] += d_out[d] * nx` landet d_out[d] * nx in beitrag[d].
  var ss: cfloat = 0.0
  for d in 0 ..< dim:
    ss += a_i[d] * a_i[d]
  let inv = 1.0 / sqrt((ss / dim.float32) + 1e-5)
  var sum_dy_nx: cfloat = 0.0
  for d in 0 ..< dim:
    let w_val = if w.isNil: 1.0.cfloat else: w[d]
    sum_dy_nx += d_out[d] * w_val * (a_i[d] * inv)
  let mean_dy_nx = sum_dy_nx / dim.float32
  for d in 0 ..< dim:
    let w_val = if w.isNil: 1.0.cfloat else: w[d]
    let nx = a_i[d] * inv
    beitrag[d] = d_out[d] * nx
    d_out[d] = (d_out[d] * w_val - nx * mean_dy_nx) * inv
proc parNormBwRow(a: ptr ParArgs, p: int) {.exportc: "snai_par_normbw", cdecl.} =
  let dim = a.dim
  let off = p * dim
  rmsBwBeitrag(cast[ptr FloatArray](addr a.c[off]), cast[ptr FloatArray](addr a.a[off]), dim.cint, a.w,
               cast[ptr FloatArray](addr a.b[off]))
  if a.rot and p == 0: a.c[off] = a.c[off] * 1.0001'f32
proc parNormBwRowC(a: ptr ParArgs, p: int) {.importc: "snai_par_normbw", cdecl.}
proc parNormBwSum(a: ptr ParArgs, d: int) {.exportc: "snai_par_normbw_sum", cdecl.} =
  ## Gain-Gradient eines Elements: Beitraege in Positionsreihenfolge, wie im seriellen Pfad.
  for p in 0 ..< a.act:
    a.w[d] += a.b[p * a.dim + d]
proc parNormBwSumC(a: ptr ParArgs, d: int) {.importc: "snai_par_normbw_sum", cdecl.}
proc parNormBw(st: ptr CortexState, quelle, ziel, aIn, w, gw: ptr FloatArray, addiere: bool, act, dim: cint) =
  ## quelle: eingehender Gradient je Zeile; ziel: d_hidden_all (= oder +=); aIn: Eingang der Norm.
  if parOn(PG_NORMBW):
    var tmp = newSeq[cfloat](act.int * dim.int)
    var bei = newSeq[cfloat](act.int * dim.int)
    for i in 0 ..< act.int * dim.int: tmp[i] = quelle[i]
    var a = ParArgs(st: st, act: act.int, dim: dim.int, a: aIn, b: cast[ptr FloatArray](addr bei[0]),
                    c: cast[ptr FloatArray](addr tmp[0]), w: w, rot: parRot(PG_NORMBW))
    let ap = addr a
    {.push checks: off.}
    for p in 0 || (act - 1):
      parNormBwRowC(ap, p)
    {.pop.}
    if not gw.isNil:
      var s = ParArgs(st: st, act: act.int, dim: dim.int, b: cast[ptr FloatArray](addr bei[0]), w: gw)
      let sp = addr s
      {.push checks: off.}
      for d in 0 || (dim - 1):
        parNormBwSumC(sp, d)
      {.pop.}
    if addiere:
      for i in 0 ..< act.int * dim.int: ziel[i] += tmp[i]
    else:
      for i in 0 ..< act.int * dim.int: ziel[i] = tmp[i]
  else:
    for p in 0 ..< act:
      let off = p * dim
      for d in 0 ..< dim: st.d_norm[d] = quelle[off + d]
      applyRMSNormBackwardAcc(st.d_norm,
                              cast[ptr FloatArray](addr aIn[off]),
                              dim, w, gw)
      if addiere:
        for d in 0 ..< dim: ziel[off + d] += st.d_norm[d]
      else:
        for d in 0 ..< dim: ziel[off + d] = st.d_norm[d]

# --- emb: modus 0 = Lookup Zeile p, modus 1 = Gradient Spalte d ---
proc parEmbRow(a: ptr ParArgs, i: int) {.exportc: "snai_par_emb", cdecl.} =
  let state = a.st
  let dim = a.dim
  let vocab = a.vocab
  if a.modus == 0:
    let p = i
    var tid = a.tin[p]
    if tid < 0 or tid >= vocab: tid = 0
    let off = p * dim
    for d in 0 ..< dim:
      state.act_hidden_final[off + d] =
        state.embeddings_q8.data[tid * dim + d].cfloat * state.embeddings_q8.scale[tid] * embFak(state)
    if a.rot and p == 0: state.act_hidden_final[0] = state.act_hidden_final[0] * 1.0001'f32
  else:
    let d = i
    for p in 0 ..< a.act:
      var tid = a.tin[p]
      if tid < 0 or tid >= vocab: tid = 0
      let off = p * dim
      state.g_embeddings.data[tid * dim + d] += state.d_hidden_all[off + d] * embFak(state)
proc parEmbRowC(a: ptr ParArgs, i: int) {.importc: "snai_par_emb", cdecl.}

# --- vec: modus 0 = Kopie b <- a, 1 = a += b (Zeile p) ---
proc parVecRow(a: ptr ParArgs, p: int) {.exportc: "snai_par_vec", cdecl.} =
  let dim = a.dim
  if a.modus == 0:
    for i in p * dim ..< (p + 1) * dim: a.b[i] = a.a[i]
  else:
    for i in p * dim ..< (p + 1) * dim: a.a[i] += a.b[i]
  if a.rot and p == 0 and a.modus == 1: a.a[0] = a.a[0] * 1.0001'f32
proc parVecRowC(a: ptr ParArgs, p: int) {.importc: "snai_par_vec", cdecl.}
proc parVec(st: ptr CortexState, x, y: ptr FloatArray, modus: int, act, dim: cint) =
  var a = ParArgs(st: st, act: act.int, dim: dim.int, a: x, b: y, modus: modus, rot: parRot(PG_VEC))
  let ap = addr a
  {.push checks: off.}
  for p in 0 || (act - 1):
    parVecRowC(ap, p)
  {.pop.}
proc attFwdMode(): int = (if parOn(PG_ATT): (if parRot(PG_ATT): 2 else: 1) else: 0)
proc smParMode(): int = (if parOn(PG_SM): (if parRot(PG_SM): 2 else: 1) else: 0)

var attBwModeV = -1
proc c_getenv_ab(name: cstring): cstring {.importc: "getenv", header: "<stdlib.h>".}
proc attBwMode(): int =
  ## 0 seriell (alter Pfad), 1 parallel ueber die Koepfe, 2 parallel + ROT-Probe. Einmal je Prozess.
  if attBwModeV < 0:
    let e = c_getenv_ab("SNAI_I8_ATT_BW")
    let s = (if e.isNil: "" else: $e)
    attBwModeV = (if s == "0": 0 elif s == "ROT": 2 else: 1)
    stderr.writeLine("[ATT-BW] Attention-Rueckwaerts: ",
                     (if attBwModeV == 0: "seriell (SNAI_I8_ATT_BW=0)" elif attBwModeV == 2: "parallel ROT-PROBE" else: "parallel ueber die Koepfe"))
  attBwModeV

# ATT-GPU (2026-10-14, patch_att_gpu.py): Attention vorwaerts und rueckwaerts auf der Karte, bitgleich zur
# CPU (Kerne in cortex_cuda.cu, Abschnitt ATT-GPU). Stellrad SNAI_I8_ATT_GPU: fehlt/1 = Karte, 0 = CPU,
# ROTF/ROTB = Rot-Probe vorwaerts/rueckwaerts. Rueckwaerts nur im parallelen Zweig (SNAI_I8_ATT_BW != 0)
# und mit q-Quantisierung; sonst und bei jedem Fehler der Karte rechnet die CPU wie bisher.
var attGpuModeV = -1
var attGpuWarned = false
var attGpuFwdCalls, attGpuBwCalls = 0
proc attGpuMode(): int =
  if attGpuModeV < 0:
    let e = c_getenv_ab("SNAI_I8_ATT_GPU")
    let s = (if e.isNil: "" else: $e)
    attGpuModeV = (if s == "0": 0 elif s == "ROTF": 2 elif s == "ROTB": 3 else: 1)
  attGpuModeV
proc attGpuWarn(why: string) =
  if not attGpuWarned:
    stderr.writeLine("⚠️  [ATT-GPU] greift nicht (", why, ") - die Attention rechnet auf der CPU.")
    attGpuWarned = true
var attGpuAnnounced = false
proc attGpuOk(): bool =
  if attGpuMode() == 0: return false
  # OCL-ATT (2026-11-12): unter OpenCL dieselben Grundkerne (ohne ATT_FAST).
  if not gpu_initialized or gpu_backend == gbNone: return false
  if gpu_backend == gbOpenCL:
    if ocl_att_ready() == 0:
      attGpuWarn("OpenCL-Geraet ohne double-Kern, siehe [OCL-ADAM]/[OCL-ATT]"); return false
  elif pCudaAttFwdI8.isNil or pCudaAttBwI8.isNil:
    attGpuWarn("libcortex_cuda.so ohne cuda_att_fwd_i8/cuda_att_bw_i8"); return false
  if not attGpuAnnounced:
    stderr.writeLine("[ATT-GPU] Attention auf der Karte",
                     (if attGpuModeV == 2: " ROT-PROBE vorwaerts" elif attGpuModeV == 3: " ROT-PROBE rueckwaerts" else: ""))
    attGpuAnnounced = true
  true
proc attGpuFwd(state: ptr CortexState, l, act: int): bool =
  if not attGpuOk(): return false
  let dim = state.hiddenDim.int
  var fq = newSeq[int8](act * dim)
  var fqs = newSeq[cfloat](act)
  for p in 0 ..< act:
    fqs[p] = quantizeActivation(cast[ptr FloatArray](addr state.act_q[l].data[p * dim]),
                                cast[ptr Int8Array](addr fq[p * dim]), dim.cint)
  let rc = if gpu_backend == gbOpenCL: ocl_att_fwd_i8(addr fq[0], addr fqs[0], addr state.k_cache_q8[l].data[0], addr state.k_cache_q8[l].scale[0],
                         addr state.v_cache_q8[l].data[0], addr state.v_cache_q8[l].scale[0],
                         addr state.act_att_out[l][0], act.cint, dim.cint, state.numHeads, state.headSize,
                         sqrt(state.headSize.float32), (if attGpuModeV == 2: 1.cint else: 0.cint))
           else: pCudaAttFwdI8(addr fq[0], addr fqs[0], addr state.k_cache_q8[l].data[0], addr state.k_cache_q8[l].scale[0],
                         addr state.v_cache_q8[l].data[0], addr state.v_cache_q8[l].scale[0],
                         addr state.act_att_out[l][0], act.cint, dim.cint, state.numHeads, state.headSize,
                         sqrt(state.headSize.float32), (if attGpuModeV == 2: 1.cint else: 0.cint))
  if rc != 0:
    attGpuWarn("vorwaerts rc " & $rc); return false
  inc attGpuFwdCalls
  true
proc attGpuBw(state: ptr CortexState, l, act: int, abQ: var seq[int8], abQs: var seq[cfloat]): bool =
  if not attGpuOk(): return false
  let dim = state.hiddenDim.int
  # Wie im Kopf-Rueckwaerts: float64 (Nim-Literal 1.0), ds entsteht auf der CPU als double.
  let attScale: float64 = 1.0 / sqrt(state.headSize.float32)
  let rc = if gpu_backend == gbOpenCL: ocl_att_bw_i8(addr abQ[0], addr abQs[0], addr state.k_cache_q8[l].data[0], addr state.k_cache_q8[l].scale[0],
                        addr state.v_cache_q8[l].data[0], addr state.v_cache_q8[l].scale[0],
                        addr state.d_att_out_all[0], addr state.d_q_all[0],
                        addr state.d_k_cache[l].data[0], addr state.d_v_cache[l].data[0],
                        act.cint, dim.cint, state.numHeads, state.headSize,
                        sqrt(state.headSize.float32), attScale, (if attGpuModeV == 3: 1.cint else: 0.cint))
           else: pCudaAttBwI8(addr abQ[0], addr abQs[0], addr state.k_cache_q8[l].data[0], addr state.k_cache_q8[l].scale[0],
                        addr state.v_cache_q8[l].data[0], addr state.v_cache_q8[l].scale[0],
                        addr state.d_att_out_all[0], addr state.d_q_all[0],
                        addr state.d_k_cache[l].data[0], addr state.d_v_cache[l].data[0],
                        act.cint, dim.cint, state.numHeads, state.headSize,
                        sqrt(state.headSize.float32), attScale, (if attGpuModeV == 3: 1.cint else: 0.cint))
  if rc != 0:
    attGpuWarn("rueckwaerts rc " & $rc); return false
  inc attGpuBwCalls
  true

# ATT-W-CACHE (2026-11-06, engine_opt/patch_attw.py): Attention-Gewichte des Vorwaerts je
# Schicht/Kopf/Position fuer den Rueckwaerts desselben Schritts. Gueltig nur, wenn der Vorwaerts
# auf der CPU mit quantisiertem q lief (dann ist w bitgleich zur Neuberechnung im Rueckwaerts).
var attWBuf: seq[seq[cfloat]]
var attWValid: seq[bool]
var attWActV: seq[int]
var attWOwner: pointer = nil
var attWModeV = -1
var attBwBlkModeV = -1
var attBwBlkBuf: seq[cfloat]
var attBwBlkDsBuf: seq[cdouble]
var attBwBlkMeld = false
proc attBwBlkMode(): int =
  ## ATT-BW-BLK: 0 aus, 1 AUTO (ab Breite attBwBlkMinDim), 2 AUTO + ROT-Probe, 3 immer an. Einmal je Prozess.
  if attBwBlkModeV < 0:
    let e = c_getenv_ab("SNAI_I8_ATT_BW_BLK")
    let s = (if e.isNil: "" else: $e)
    attBwBlkModeV = (if s == "0": 0 elif s == "ROTB": 2 elif s == "AN": 3 else: 1)
    stderr.writeLine("[ATT-BWB] Attention rueckwaerts in Bloecken zu ", attBwBlkP, ": ",
                     (if attBwBlkModeV == 0: "aus (SNAI_I8_ATT_BW_BLK=0)" elif attBwBlkModeV == 2: "auto ab Breite " & $attBwBlkMinDim & ", ROT-PROBE"
                      elif attBwBlkModeV == 3: "immer an (SNAI_I8_ATT_BW_BLK=AN)" else: "auto ab Breite " & $attBwBlkMinDim))
  attBwBlkModeV
proc attBwBlkOn(dim: int): bool =
  ## Entscheidung je Aufruf; meldet beim ersten Mal die Breite und das Ergebnis.
  let m = attBwBlkMode()
  result = m == 3 or (m > 0 and dim >= attBwBlkMinDim)
  if not attBwBlkMeld:
    attBwBlkMeld = true
    stderr.writeLine("[ATT-BWB] Breite ", dim, ": Blockpfad ", (if result: "an" else: "aus"))

proc attWMode(): int =
  ## 0 aus, 1 an, 2 an + ROT-Probe. Einmal je Prozess.
  if attWModeV < 0:
    let e = c_getenv_ab("SNAI_I8_ATT_WCACHE")
    let s = (if e.isNil: "" else: $e)
    attWModeV = (if s == "0": 0 elif s == "ROT": 2 elif s == "ROTD": 3 elif s == "ROTV": 4 elif s == "ROTX": 5 elif s == "ROTF": 6 else: 1)
    stderr.writeLine("[ATT-W] Attention-Gewichte aus dem Vorwaerts: ",
                     (if attWModeV == 0: "aus (SNAI_I8_ATT_WCACHE=0)" elif attWModeV == 2: "an, ROT-PROBE" elif attWModeV == 3: "an, ROT-PROBE Tabellen" elif attWModeV == 4: "an, ROT-PROBE vT" elif attWModeV == 5: "an, ROT-PROBE Vektor" elif attWModeV == 6: "an, ROT-PROBE Vorwaerts" else: "an"))
  attWModeV
var attKf, attVf, attVT: seq[seq[cfloat]]
var attKT8: seq[seq[int8]]
proc attDeqPrep(state: ptr CortexState, l, act: int) =
  ## ATT-DEQ: entquantisierte K/V der Schicht, Ausdruck wie kElem/vElem (float * float).
  let nl = state.numLayers.int
  let dim = state.hiddenDim.int
  if attKf.len < nl:
    attKf.setLen(nl); attVf.setLen(nl); attVT.setLen(nl)
  if attKf[l].len < act * dim:
    attKf[l].setLen(act * dim); attVf[l].setLen(act * dim)
  if attVT[l].len < act * dim: attVT[l].setLen(act * dim)
  if attKT8.len < nl: attKT8.setLen(nl)
  if attKT8[l].len < act * dim: attKT8[l].setLen(act * dim)
  for t in 0 ..< act:
    for i in 0 ..< dim:
      attKT8[l][i * act + t] = state.k_cache_q8[l].data[t * dim + i]
  if attWMode() == 6:
    attKT8[l][0] = (if attKT8[l][0] < 127'i8: attKT8[l][0] + 1'i8 else: attKT8[l][0] - 1'i8)
  for t in 0 ..< act:
    let ks = state.k_cache_q8[l].scale[t]
    let vs = state.v_cache_q8[l].scale[t]
    for i in 0 ..< dim:
      attKf[l][t * dim + i] = state.k_cache_q8[l].data[t * dim + i].cfloat * ks
      attVf[l][t * dim + i] = state.v_cache_q8[l].data[t * dim + i].cfloat * vs
  if attWMode() == 3:
    attKf[l][0] = attKf[l][0] * 1.0001'f32
  # ATT-DWT: vT[i][t] (Zeilenlaenge act) fuer den Rueckwaerts
  for t in 0 ..< act:
    for i in 0 ..< dim:
      attVT[l][i * act + t] = attVf[l][t * dim + i]
  if attWMode() == 4:
    attVT[l][0] = attVT[l][0] * 1.0001'f32
proc attWPrep(state: ptr CortexState, l, act: int) =
  let nl = state.numLayers.int
  if attWBuf.len < nl:
    attWBuf.setLen(nl); attWValid.setLen(nl); attWActV.setLen(nl)
  let need = state.numHeads.int * (act * (act + 1) div 2)
  if attWBuf[l].len < need: attWBuf[l].setLen(need)
  attWOwner = cast[pointer](state)
  attWActV[l] = act
  attWValid[l] = true

# =====================================================================================================
# RESIDENT (seit 2026-11-11, Vorgabe an;
# messbuch snai/multistack-resident-fwd e624, snai/multistack-resident-bw e625):
# Stufe A - der Vorwaertsweg rechnet ganz auf der Karte, die Zwischenergebnisse bleiben dort; am Ende kommen die
# Historien, die der (noch CPU-)Rueckwaertsweg liest, in einem Block herunter. Kerne: cortex_cuda.cu, Abschnitt
# RESIDENT (cuda_res). Stellrad SNAI_RESIDENT: 0 = alter Weg, fehlt/1 = Karte vorwaerts und rueckwaerts (Vorgabe),
# CHECK = beide Wege im selben
# Schritt, Zwischengroessen bitweise verglichen (der alte Weg zaehlt), ROT = Rot-Probe (RMSNorm: letzte Rundung zur Null),
# CHECKROT = CHECK mit Rot-Probe im Kartenweg (muss Abweichungen melden). Seit Stufe B: 1 = vorwaerts und rueckwaerts,
# FWD = nur vorwaerts (Stufe A), ROTB/CHECKROTB = Rot-Probe im RMSNorm-Rueckwaerts; CHECK prueft beide Stufen.
# Nur im Rezeptfall (resEligible), sonst und bei jedem Kartenfehler rechnet der alte Weg.
# =====================================================================================================
var resWarned = false
var resRope, resRope2: seq[cfloat]
var resTok: seq[cint]
var resRopeKey = -1
var resTg, resMask: seq[cint]
var resPtg: seq[cfloat]
proc resWarn(why: string) =
  if not resWarned:
    try: stderr.writeLine("⚠️  [RESIDENT] greift nicht (", why, ") - der Vorwaertsweg rechnet wie bisher.")
    except IOError: discard
    resWarned = true
proc resMode(): int =
  if resModeV < 0:
    let e = c_getenv_ab("SNAI_RESIDENT")
    let s = (if e.isNil: "" else: $e)
    resModeV = (if s == "FWD": 1 elif s == "CHECK": 2 elif s == "ROT": 3 elif s == "CHECKROT": 4
                 elif s == "ROTB": 6 elif s == "CHECKROTB": 7 elif s == "" or s == "1": 5 else: 0)
    if resModeV > 0:
      try: stderr.writeLine("[RESIDENT] Vorwaerts auf der Karte: ",
                            ["", "nur vorwaerts", "CHECK", "ROT-PROBE vorwaerts", "CHECK mit ROT-PROBE vorwaerts", "vorwaerts und rueckwaerts",
                             "ROT-PROBE rueckwaerts", "CHECK mit ROT-PROBE rueckwaerts"][resModeV])
      except IOError: discard
  resModeV
proc resEligible(state: ptr CortexState): bool =
  var why = ""
  if pCudaRes.isNil: why = "libcortex_cuda.so ohne cuda_res"
  elif not gpu_initialized or gpu_backend != gbCuda: why = "keine CUDA-Karte"
  elif state.quantActs == 0 or state.quantActsIn == 0: why = "FFN-Historie nicht quantisiert"
  elif i8_silu_lut == 0 or state.silu_lut.isNil: why = "SiLU-Tabelle aus"
  elif loraOn(state): why = "LoRA aktiv"
  elif global_dropout_rate > 0.0: why = "Dropout"
  elif global_label_smoothing > 0.0: why = "Label-Smoothing"
  elif attGpuMode() != 1 or not attGpuOk(): why = "ATT-GPU nicht im Normalbetrieb"
  elif state.headSize mod 2 != 0 or state.hiddenDim mod state.headSize != 0: why = "Kopfbreite"
  else:
    for l in 0 ..< state.numLayers:
      if ffnAusL(state, l): why = "FFN-Zweig aus"
      for m in [state.w_q_q8[l], state.w_k_q8[l], state.w_v_q8[l], state.w_o_q8[l], state.w_up_q8[l], state.w_down_q8[l]]:
        if not useGpuQMat(m): why = "Schichtmatrix unter der Kartenschwelle"
  if why.len > 0: resWarn(why)
  why.len == 0

proc resRopeTable(state: ptr CortexState): bool =
  ## cos_t/sin_t je Position und Paar, Ausdruecke woertlich wie applyRoPE (vorwaerts). true = neu, hochladen.
  let key = state.ctxSize.int * 4096 + state.headSize.int
  if key == resRopeKey: return false
  let hh = state.headSize.int div 2
  resRope = newSeq[cfloat](state.ctxSize.int * hh * 2)
  let head_size = state.headSize
  let base = ropeBase(head_size, state.ctxSize)
  resRope2 = newSeq[cfloat](state.ctxSize.int * hh * 2)
  for bw in [false, true]:
    let sign: cfloat = if bw: -1.0 else: 1.0
    for pos in 0 ..< state.ctxSize.int:
      for k in 0 ..< hh:
        let i = 2 * k
        let freq = 1.0 / pow(base, i.float32 / head_size.float32)
        let theta = pos.float32 * freq
        let cos_t = cos(theta).cfloat
        let sin_t = sign * sin(theta).cfloat
        if bw:
          resRope2[(pos * hh + k) * 2] = cos_t
          resRope2[(pos * hh + k) * 2 + 1] = sin_t
        else:
          resRope[(pos * hh + k) * 2] = cos_t
          resRope[(pos * hh + k) * 2 + 1] = sin_t
  resRopeKey = key
  true

template resP(x: untyped): pointer = cast[pointer](x)

proc resHist(state: ptr CortexState, a: int): seq[(string, pointer, int)] =
  ## Was der Rueckwaertsweg vom Vorwaerts liest (Name, Hostzeiger, Bytes bei a Positionen).
  let dim = state.hiddenDim.int
  let ffn = state.ffnDim.int
  result.add(("act_hidden_final", resP(state.act_hidden_final), a * dim * 4))
  result.add(("act_norm_final", resP(state.act_norm_final), a * dim * 4))
  result.add(("logits", resP(state.logits_cache.data), a * state.vocabSize.int * 4))
  for l in 0 ..< state.numLayers.int:
    let s = "[" & $l & "]"
    result.add(("act_hidden" & s, resP(state.act_hidden[l]), a * dim * 4))
    result.add(("act_norm_att" & s, resP(state.act_norm_att[l]), a * dim * 4))
    result.add(("act_q" & s, resP(state.act_q[l].data), a * dim * 4))
    result.add(("k8" & s, resP(state.k_cache_q8[l].data), a * dim))
    result.add(("ks" & s, resP(state.k_cache_q8[l].scale), a * 4))
    result.add(("v8" & s, resP(state.v_cache_q8[l].data), a * dim))
    result.add(("vs" & s, resP(state.v_cache_q8[l].scale), a * 4))
    result.add(("act_att_out" & s, resP(state.act_att_out[l]), a * dim * 4))
    result.add(("act_hidden_ffn" & s, resP(state.act_hidden_ffn[l]), a * dim * 4))
    result.add(("act_norm_ffn" & s, resP(state.act_norm_ffn[l]), a * dim * 4))
    result.add(("ffn_in8" & s, resP(state.act_ffn_in_q8[l].data), a * ffn))
    result.add(("ffn_ins" & s, resP(state.act_ffn_in_q8[l].scale), a * 4))
    result.add(("ffn_out8" & s, resP(state.act_ffn_out_q8[l].data), a * ffn))
    result.add(("ffn_outs" & s, resP(state.act_ffn_out_q8[l].scale), a * 4))

proc resFwd(state: ptr CortexState, t_in, t_tg, t_mask: ptr IntArray, act: cint,
            lossOut: var cfloat, cntOut: var cint, downAll: bool): bool =
  let dim = state.hiddenDim.int
  let ffn = state.ffnDim.int
  let V = state.vocabSize.int
  let cap = state.ctxSize.int
  let a = act.int
  let hs = state.headSize.int
  let rot = (if resModeV == 3 or resModeV == 4: 1 else: 0)
  var pp: array[8, pointer]
  var nn: array[8, clonglong]
  var ff: array[2, cfloat]
  template R(op: int, ps: openArray[pointer], ns: openArray[int]) =
    for i in 0 ..< ps.len: pp[i] = ps[i]
    for i in 0 ..< ns.len: nn[i] = ns[i].clonglong
    let rc = pCudaRes(op.cint, addr pp[0], addr nn[0], addr ff[0])
    if rc != 0:
      resWarn("Karte rc " & $rc & " bei op " & $op)
      return false
  template GEMM(m: QMatrix, src, dst: pointer, upl: int) =
    R(5, [resP(m.data), resP(m.scale), src, dst], [m.rows.int, m.cols.int, a, upl])
  if resTg.len != cap:
    resTg = newSeq[cint](cap); resMask = newSeq[cint](cap); resPtg = newSeq[cfloat](cap); resTok = newSeq[cint](cap)
  for p in 0 ..< a:
    resTg[p] = t_tg[p]; resMask[p] = t_mask[p]
  # Platz mit voller Kapazitaet anlegen (Schluessel = Hostzeiger)
  let fd = cap * dim * 4
  for k in [resP(state.act_hidden_final), resP(state.act_norm_final), resP(state.mm_hd_scratch)]:
    R(14, [k], [0, fd])
  R(14, [resP(state.logits_cache.data)], [0, cap * V * 4])
  R(14, [resP(state.act_ffn_scratch)], [0, cap * ffn * 4])
  for l in 0 ..< state.numLayers.int:
    for k in [resP(state.act_hidden[l]), resP(state.act_norm_att[l]), resP(state.act_q[l].data),
              resP(state.act_att_out[l]), resP(state.act_hidden_ffn[l]), resP(state.act_norm_ffn[l])]:
      R(14, [k], [0, fd])
    for k in [resP(state.k_cache_q8[l].data), resP(state.v_cache_q8[l].data)]: R(14, [k], [0, cap * dim])
    for k in [resP(state.act_ffn_in_q8[l].data), resP(state.act_ffn_out_q8[l].data)]: R(14, [k], [0, cap * ffn])
    for k in [resP(state.k_cache_q8[l].scale), resP(state.v_cache_q8[l].scale),
              resP(state.act_ffn_in_q8[l].scale), resP(state.act_ffn_out_q8[l].scale)]: R(14, [k], [0, cap * 4])
  let ropeNeu = resRopeTable(state)
  let ropeBytes = resRope.len * 4
  if ropeNeu: R(1, [resP(addr resRope2[0])], [ropeBytes, ropeBytes])
  # Embedding wie bisher auf der CPU, dann hoch
  for p in 0 ..< a:
    var tid = t_in[p]
    if tid < 0 or tid >= V: tid = 0
    let off = p * dim
    for d in 0 ..< dim:
      state.act_hidden_final[off + d] =
        state.embeddings_q8.data[tid * dim + d].cfloat * state.embeddings_q8.scale[tid] * embFak(state)
  R(1, [resP(state.act_hidden_final)], [a * dim * 4, fd])
  let hf = resP(state.act_hidden_final)
  let sc = resP(state.mm_hd_scratch)
  let fs = resP(state.act_ffn_scratch)
  var ropeUp = (if ropeNeu: 1 else: 0)
  for l in 0 ..< state.numLayers.int:
    R(3, [hf, resP(state.act_hidden[l])], [a * dim * 4, fd])
    R(4, [hf, resP(state.act_norm_att[l]), resP(state.rms_att_weights[l])], [a, dim, rot])
    GEMM(state.w_q_q8[l], resP(state.act_norm_att[l]), resP(state.act_q[l].data), 0)
    GEMM(state.w_k_q8[l], resP(state.act_norm_att[l]), sc, 0)
    R(7, [sc, resP(addr resRope[0])], [a, dim, hs, ropeBytes, ropeUp])
    ropeUp = 0
    R(6, [sc, resP(state.k_cache_q8[l].data), resP(state.k_cache_q8[l].scale)], [a, dim, cap])
    GEMM(state.w_v_q8[l], resP(state.act_norm_att[l]), sc, 0)
    R(6, [sc, resP(state.v_cache_q8[l].data), resP(state.v_cache_q8[l].scale)], [a, dim, cap])
    R(7, [resP(state.act_q[l].data), resP(addr resRope[0])], [a, dim, hs, ropeBytes, 0])
    ff[0] = sqrt(state.headSize.float32)
    R(9, [resP(state.act_q[l].data), resP(state.k_cache_q8[l].data), resP(state.k_cache_q8[l].scale),
          resP(state.v_cache_q8[l].data), resP(state.v_cache_q8[l].scale), resP(state.act_att_out[l])],
         [a, dim, state.numHeads.int, hs, cap])
    GEMM(state.w_o_q8[l], resP(state.act_att_out[l]), sc, 0)
    R(8, [hf, sc], [a * dim])
    R(3, [hf, resP(state.act_hidden_ffn[l])], [a * dim * 4, fd])
    R(4, [hf, resP(state.act_norm_ffn[l]), resP(state.rms_ffn_weights[l])], [a, dim, rot])
    GEMM(state.w_up_q8[l], resP(state.act_norm_ffn[l]), fs, 0)
    R(6, [fs, resP(state.act_ffn_in_q8[l].data), resP(state.act_ffn_in_q8[l].scale)], [a, ffn, cap])
    R(10, [resP(state.act_ffn_in_q8[l].data), resP(state.act_ffn_in_q8[l].scale), fs], [a, ffn])
    R(6, [fs, resP(state.act_ffn_out_q8[l].data), resP(state.act_ffn_out_q8[l].scale)], [a, ffn, cap])
    GEMM(state.w_down_q8[l], fs, sc, 0)
    R(8, [hf, sc], [a * dim])
  R(4, [hf, resP(state.act_norm_final), resP(state.rms_final_weight)], [a, dim, rot])
  # w_out liegt unter der Kartenschwelle (kein gepflegter Kartenstand): Gewichte jeden Schritt hochladen.
  GEMM(state.w_out_q8, resP(state.act_norm_final), resP(state.logits_cache.data), 1)
  R(11, [resP(state.logits_cache.data), resP(addr resTg[0]), resP(addr resMask[0]), resP(addr resPtg[0])], [a, V, cap])
  # Loss wie bisher (ln auf der CPU), aus der Wahrscheinlichkeit am Ziel
  var total_loss: cfloat = 0.0
  var trainable_count: cint = 0
  for p in 0 ..< a:
    if t_mask[p] != 0:
      total_loss += -ln(resPtg[p] + 1e-7)
      inc trainable_count
  for h in resHist(state, a):
    # Stufe B: der Rueckwaertsweg braucht auf dem Host nur, was w_out (CPU) liest.
    if downAll or h[0] == "logits" or h[0] == "act_norm_final":
      R(2, [h[1]], [h[2], h[2]])
  lossOut = total_loss
  cntOut = trainable_count
  true

proc resCheck(state: ptr CortexState, t_in, t_tg, t_mask: ptr IntArray, act: cint,
              loss: cfloat, cnt: cint): bool =
  ## CHECK: der alte Weg hat eben gerechnet. Seine Historien sichern, den Kartenweg rechnen, bitweise vergleichen,
  ## danach den alten Stand zurueckschreiben (er zaehlt).
  let hl = resHist(state, act.int)
  var snap: seq[seq[byte]]
  for h in hl:
    var b = newSeq[byte](h[2])
    if h[2] > 0: copyMem(addr b[0], h[1], h[2])
    snap.add(b)
  var l2: cfloat = 0.0
  var c2: cint = 0
  let ok = resFwd(state, t_in, t_tg, t_mask, act, l2, c2, true)
  inc resCheckSteps
  var bad = 0
  var meld: seq[string]
  if not ok:
    meld.add("Kartenweg abgebrochen")
    inc bad
  else:
    if cast[uint32](l2) != cast[uint32](loss) or c2 != cnt:
      meld.add("Loss " & $loss & " gegen " & $l2 & ", Anzahl " & $cnt & " gegen " & $c2)
      inc bad
    for i, h in hl:
      let n = h[2]
      if n == 0: continue
      let q = cast[ptr UncheckedArray[byte]](h[1])
      if equalMem(addr snap[i][0], h[1], n): continue
      inc bad
      var first = -1
      var cntB = 0
      for j in 0 ..< n:
        if snap[i][j] != q[j]:
          inc cntB
          if first < 0: first = j
      var z = h[0] & ": " & $cntB & " Bytes abweichend, erstes Byte " & $first
      if n mod 4 == 0 and '8' notin h[0]:
        let e = first div 4
        z.add(" (Element " & $e & ": CPU " & $cast[ptr cfloat](addr snap[i][e * 4])[] &
              " Karte " & $cast[ptr UncheckedArray[cfloat]](h[1])[e] & ")")
      meld.add(z)
  if bad > 0:
    inc resCheckBad
    if resCheckBad <= 5:
      try:
        stderr.writeLine("[RESIDENT] CHECK Schritt ", resCheckSteps, ": ", bad, " Abweichungen")
        for z in meld: stderr.writeLine("[RESIDENT]   ", z)
      except IOError: discard
  for i, h in hl:
    if h[2] > 0: copyMem(h[1], addr snap[i][0], h[2])
  ok and bad == 0

# RESIDENT Stufe B (seit 2026-11-11, e624/e625): Rueckwaertsweg auf der Karte. w_out (unter der Kartenschwelle) rechnet
# wie bisher die CPU, danach kommt d_norm_all hoch; alles Weitere liest die Historien des Vorwaertswegs auf der Karte.
# Gewichtsgradienten der 12 Schichtmatrizen landen wie bisher im Puffercache (GRAD-DEV/GRAD-EARLY unveraendert),
# g_rms_* und g_embeddings kommen am Ende herunter.
proc resBEligible(state: ptr CortexState, act: cint): bool =
  var why = ""
  if pCudaRes2.isNil: why = "libcortex_cuda.so ohne cuda_res2"
  elif i8_int_backward == 0 or i8_int_gradacc == 0 or i8_gpu_backward == 0: why = "Ganzzahl-Rueckwaerts auf der Karte aus"
  elif i8_grad_stochastic != 0: why = "stochastisches Runden"
  elif attBwMode() <= 0 or i8_att_bw_quantq == 0: why = "ATT-BW nicht parallel mit q-Quantisierung"
  elif state.i8_bwThreads <= 0 or not scratchThreadsOk(state) or state.i8_dscratch.isNil or state.i32_dacc.isNil or
       state.i8_dbscale.isNil or state.i8_gqi.isNil or state.i8_gdscale.isNil or state.i8_giscale.isNil:
    why = "Rueckwaerts-Scratch fehlt"
  elif act.int > (high(int32).int div (127 * 127)): why = "act zu gross"
  else:
    for l in 0 ..< state.numLayers:
      for m in [state.w_q_q8[l], state.w_k_q8[l], state.w_v_q8[l], state.w_o_q8[l], state.w_up_q8[l], state.w_down_q8[l]]:
        let r = m.rows.int
        let c = m.cols.int
        if not useGpuGradAccI8(r, c) or r > state.i8_dqStride.int or c > state.i8_accStride.int or
           c > state.i8_gqiStride.int or r > state.i8_gqiStride.int:
          why = "Schichtmatrix ausserhalb der Kartenzweige"
  if why.len > 0: resWarn("Stufe B: " & why)
  why.len == 0

proc resBwd(state: ptr CortexState, t_in: ptr IntArray, act: cint, rotB: int): bool =
  let dim = state.hiddenDim.int
  let ffn = state.ffnDim.int
  let V = state.vocabSize.int
  let cap = state.ctxSize.int
  let a = act.int
  let hs = state.headSize.int
  var pp: array[12, pointer]
  var nn: array[8, clonglong]
  var ff: array[2, cfloat]
  template R(op: int, ps: openArray[pointer], ns: openArray[int]) =
    for i in 0 ..< ps.len: pp[i] = ps[i]
    for i in 0 ..< ns.len: nn[i] = ns[i].clonglong
    let rc = (if op < 20: pCudaRes(op.cint, addr pp[0], addr nn[0], addr ff[0])
              else: pCudaRes2(op.cint, addr pp[0], addr nn[0], addr ff[0]))
    if rc != 0:
      resWarn("Stufe B: Karte rc " & $rc & " bei op " & $op)
      return false
  template DIN(m: QMatrix, src, dst: pointer, accu: int) =
    R(20, [resP(m.data), resP(m.scale), src, dst], [m.rows.int, m.cols.int, a, accu])
  template GACC(m: QMatrix, g: Matrix, dout, xin: pointer) =
    R(21, [resP(g.data), dout, xin], [g.rows.int, g.cols.int, a])
  let fd = cap * dim * 4
  let dha = resP(state.d_hidden_all)
  let dna = resP(state.d_norm_all)
  let daa = resP(state.d_att_out_all)
  let dqa = resP(state.d_q_all)
  let sc = resP(state.mm_hd_scratch)
  let fsc = resP(state.mm_ffn_scratch)
  for k in [dha, dna, daa, dqa]: R(14, [k], [0, fd])
  R(14, [fsc], [0, cap * ffn * 4])
  for k in [resP(state.g_rms_final_weight)]: R(25, [k], [dim * 4, dim * 4])
  for l in 0 ..< state.numLayers.int:
    R(14, [resP(state.d_k_cache[l].data)], [0, fd]); R(14, [resP(state.d_v_cache[l].data)], [0, fd])
    R(25, [resP(state.g_rms_att_weights[l])], [dim * 4, dim * 4])
    R(25, [resP(state.g_rms_ffn_weights[l])], [dim * 4, dim * 4])
  # d_norm_all kommt von der CPU (w_out), dann RMSNorm der Endnormierung rueckwaerts: d_hidden_all = neu
  R(1, [dna], [a * dim * 4, fd])
  R(23, [dna, resP(state.act_hidden_final), resP(state.rms_final_weight), dha, resP(state.g_rms_final_weight)],
        [a, dim, 0, rotB])
  let ropeBytes = resRope2.len * 4
  for l in countdown(state.numLayers.int - 1, 0):
    # FFN
    DIN(state.w_down_q8[l], dha, fsc, 0)
    R(22, [resP(state.g_w_down[l].data), dha, resP(state.act_ffn_out_q8[l].data), resP(state.act_ffn_out_q8[l].scale)],
          [state.g_w_down[l].rows.int, state.g_w_down[l].cols.int, a, cap])
    R(24, [fsc, resP(state.act_ffn_in_q8[l].data), resP(state.act_ffn_in_q8[l].scale)], [a, ffn, cap])
    DIN(state.w_up_q8[l], fsc, daa, 0)
    GACC(state.w_up_q8[l], state.g_w_up[l], fsc, resP(state.act_norm_ffn[l]))
    R(23, [daa, resP(state.act_hidden_ffn[l]), resP(state.rms_ffn_weights[l]), dha, resP(state.g_rms_ffn_weights[l])],
          [a, dim, 1, rotB])
    # Attention
    DIN(state.w_o_q8[l], dha, daa, 0)
    GACC(state.w_o_q8[l], state.g_w_o[l], dha, resP(state.act_att_out[l]))
    R(25, [resP(state.d_k_cache[l].data)], [a * dim * 4, fd]); R(25, [resP(state.d_v_cache[l].data)], [a * dim * 4, fd])
    let attScale: float64 = 1.0 / sqrt(state.headSize.float32)
    var asb: clonglong
    copyMem(addr asb, unsafeAddr attScale, 8)
    ff[0] = sqrt(state.headSize.float32)
    R(26, [resP(state.act_q[l].data), resP(state.k_cache_q8[l].data), resP(state.k_cache_q8[l].scale),
           resP(state.v_cache_q8[l].data), resP(state.v_cache_q8[l].scale), daa, dqa,
           resP(state.d_k_cache[l].data), resP(state.d_v_cache[l].data)],
          [a, dim, state.numHeads.int, hs, cap, asb.int])
    R(7, [dqa, resP(addr resRope2[0])], [a, dim, hs, ropeBytes, 0])
    R(7, [resP(state.d_k_cache[l].data), resP(addr resRope2[0])], [a, dim, hs, ropeBytes, 0])
    DIN(state.w_q_q8[l], dqa, sc, 0)
    GACC(state.w_q_q8[l], state.g_w_q[l], dqa, resP(state.act_norm_att[l]))
    DIN(state.w_k_q8[l], resP(state.d_k_cache[l].data), sc, 1)
    GACC(state.w_k_q8[l], state.g_w_k[l], resP(state.d_k_cache[l].data), resP(state.act_norm_att[l]))
    DIN(state.w_v_q8[l], resP(state.d_v_cache[l].data), sc, 1)
    GACC(state.w_v_q8[l], state.g_w_v[l], resP(state.d_v_cache[l].data), resP(state.act_norm_att[l]))
    R(23, [sc, resP(state.act_hidden[l]), resP(state.rms_att_weights[l]), dha, resP(state.g_rms_att_weights[l])],
          [a, dim, 1, rotB])
  # Embedding-Gradient (Hostpuffer hoch, Karte addiert, zurueck) und die rms-Gradienten herunter
  for p in 0 ..< a: resTok[p] = t_in[p]
  ff[0] = embFak(state)
  R(27, [resP(state.g_embeddings.data), dha, resP(addr resTok[0])], [a, dim, V, cap])
  R(2, [resP(state.g_rms_final_weight)], [dim * 4, dim * 4])
  for l in 0 ..< state.numLayers.int:
    R(2, [resP(state.g_rms_att_weights[l])], [dim * 4, dim * 4])
    R(2, [resP(state.g_rms_ffn_weights[l])], [dim * 4, dim * 4])
  true

proc resGradList(state: ptr CortexState): seq[(string, pointer, int, bool)] =
  ## Ergebnis des Rueckwaertswegs: (Name, Hostzeiger, Bytes, liegt auf der Karte)
  let dim = state.hiddenDim.int
  result.add(("g_w_out", resP(state.g_w_out.data), state.g_w_out.rows.int * state.g_w_out.cols.int * 4, useGpuQMat(state.w_out_q8)))
  result.add(("g_embeddings", resP(state.g_embeddings.data), state.g_embeddings.rows.int * state.g_embeddings.cols.int * 4, false))
  result.add(("g_rms_final", resP(state.g_rms_final_weight), dim * 4, false))
  for l in 0 ..< state.numLayers.int:
    let s = "[" & $l & "]"
    result.add(("g_rms_att" & s, resP(state.g_rms_att_weights[l]), dim * 4, false))
    result.add(("g_rms_ffn" & s, resP(state.g_rms_ffn_weights[l]), dim * 4, false))
    for (n, g) in [("g_w_q", state.g_w_q[l]), ("g_w_k", state.g_w_k[l]), ("g_w_v", state.g_w_v[l]),
                   ("g_w_o", state.g_w_o[l]), ("g_w_up", state.g_w_up[l]), ("g_w_down", state.g_w_down[l])]:
      result.add((n & s, resP(g.data), g.rows.int * g.cols.int * 4, true))

proc resGradSnap(gl: seq[(string, pointer, int, bool)]): seq[seq[byte]] =
  for g in gl:
    var b = newSeq[byte](g[2])
    if g[3]:
      if pCudaPullTo(g[1], addr b[0], g[2].csize_t) != 0: resWarn("CHECK: Gradient nicht lesbar " & g[0])
    else: copyMem(addr b[0], g[1], g[2])
    result.add(b)

proc fwdBatchedCpu(state: ptr CortexState, t_in, t_tg, t_mask: ptr IntArray, act: cint,
                   lossOut: var cfloat, cntOut: var cint) =
  ## RESIDENT (seit 2026-11-11, e624/e625): der Vorwaertsteil von trainStepI8Batched, woertlich hierher verschoben.
  let dim = state.hiddenDim
  let ffn = state.ffnDim
  let vocab = state.vocabSize
  let qb = state.i8_qbatch
  let qs = state.i8_qbatch_scale
  var total_loss: cfloat = 0.0
  var trainable_count: cint = 0
  # --- FORWARD ---
  if parOn(PG_EMB):
    var ea = ParArgs(st: state, act: act.int, dim: dim.int, vocab: vocab.int, tin: t_in, modus: 0, rot: parRot(PG_EMB))
    let eap = addr ea
    {.push checks: off.}
    for p in 0 || (act - 1):
      parEmbRowC(eap, p)
    {.pop.}
  for p in 0 ..< (if parOn(PG_EMB): 0.cint else: act):
    var tid = t_in[p]
    if tid < 0 or tid >= vocab: tid = 0
    let off = p * dim
    for d in 0 ..< dim:
      state.act_hidden_final[off + d] =
        state.embeddings_q8.data[tid * dim + d].cfloat * state.embeddings_q8.scale[tid] * embFak(state)

  for l in 0 ..< state.numLayers:
    if parOn(PG_VEC): parVec(state, state.act_hidden_final, state.act_hidden[l], 0, act, dim)
    else:
      for i in 0 ..< (act * dim): state.act_hidden[l][i] = state.act_hidden_final[i]
    parNorm(state, state.act_hidden_final, state.act_norm_att[l], state.rms_att_weights[l], act, dim)

    matMulBatchedI8(state.w_q_q8[l], state.act_norm_att[l],
                    cast[ptr FloatArray](state.act_q[l].data), qb, qs, act)
    # LoRA: der Adapter addiert VOR RoPE/Quantisierung - er gehoert zum
    # Gewicht, nicht hinter die nachgelagerte Verarbeitung.
    loraForwardBatch(state, l, 0, state.act_norm_att[l],
                     cast[ptr FloatArray](state.act_q[l].data), act)
    # K und V gehen ueber denselben Scratch (sequenziell, keine Ueberlappung):
    # rechnen -> (K: RoPE) -> pro Position quantisiert in den INT8-KV-Cache.
    matMulBatchedI8(state.w_k_q8[l], state.act_norm_att[l], state.mm_hd_scratch, qb, qs, act)
    loraForwardBatch(state, l, 1, state.act_norm_att[l], state.mm_hd_scratch, act)
    if parOn(PG_QKV): parQkv(state, state.mm_hd_scratch, state.k_cache_q8[l], 0, act, dim)
    for p in 0 ..< (if parOn(PG_QKV): 0.cint else: act):
      let kp = cast[ptr FloatArray](addr state.mm_hd_scratch[p * dim])
      applyRoPE(kp, dim, state.headSize, state.ctxSize, p)
      quantizeVectorToQ8Row(kp, state.k_cache_q8[l], p, dim)
    matMulBatchedI8(state.w_v_q8[l], state.act_norm_att[l], state.mm_hd_scratch, qb, qs, act)
    loraForwardBatch(state, l, 2, state.act_norm_att[l], state.mm_hd_scratch, act)
    if parOn(PG_QKV): parQkv(state, state.mm_hd_scratch, state.v_cache_q8[l], 1, act, dim)
    for p in 0 ..< (if parOn(PG_QKV): 0.cint else: act):
      quantizeVectorToQ8Row(cast[ptr FloatArray](addr state.mm_hd_scratch[p * dim]),
                            state.v_cache_q8[l], p, dim)

    if parOn(PG_QKV): parQkv(state, cast[ptr FloatArray](state.act_q[l].data), QMatrix(), 2, act, dim)
    for p in 0 ..< (if parOn(PG_QKV): 0.cint else: act):
      applyRoPE(cast[ptr FloatArray](addr state.act_q[l].data[p * dim]),
                dim, state.headSize, state.ctxSize, p)

    # Attention je Position (CPU) - identische Mathematik wie im Einzelpfad.
    # ATT-GPU: rechnet die Karte, laeuft die Schleife leer.
    let attOnGpu = attGpuFwd(state, l.int, act.int)
    let afPar = (not attOnGpu) and attFwdMode() != 0
    let awOn = (not attOnGpu) and i8_att_bw_quantq != 0 and attWMode() > 0
    if awOn:
      attWPrep(state, l.int, act.int)
      attDeqPrep(state, l.int, act.int)
    elif l.int < attWValid.len: attWValid[l.int] = false
    let awTri = act.int * (act.int + 1) div 2
    if afPar:
      # ATT-FWD-PAR: q je Position quantisieren und outp nullen (seriell, wie bisher je Position),
      # dann je Kopf parallel. Siehe snaiAttFwdHead.
      var afQ = newSeq[int8](act.int * dim.int)
      var afQs = newSeq[cfloat](act.int)
      for p in 0 ..< act:
        afQs[p] = quantizeActivation(cast[ptr FloatArray](addr state.act_q[l].data[p * dim]),
                                     cast[ptr Int8Array](addr afQ[p * dim]), dim)
        let outz = cast[ptr FloatArray](addr state.act_att_out[l][p * dim])
        for d in 0 ..< dim: outz[d] = 0.0
      var afS = newSeq[cfloat](state.numHeads.int * act.int)
      var pF = AttFwdArgs(fSt: state, fL: l.int, fAct: act.int, fDim: dim.int,
                          fQ: cast[ptr Int8Array](addr afQ[0]), fQs: cast[ptr FloatArray](addr afQs[0]),
                          fS: cast[ptr FloatArray](addr afS[0]), fRot: attFwdMode() == 2)
      if awOn:
        pF.fW = cast[ptr FloatArray](addr attWBuf[l.int][0])
        pF.fVf = cast[ptr FloatArray](addr attVf[l.int][0])
        pF.fTri = awTri
        pF.fKT8 = cast[ptr Int8Array](addr attKT8[l.int][0])
      let pFp = addr pF
      let nH = state.numHeads
      zeitMiss(ZA_ATTF):
        {.push checks: off.}
        for h in 0 || (nH - 1):
          snaiAttFwdHeadC(pFp, h)
        {.pop.}
    for p in 0 ..< (if attOnGpu or afPar: 0.cint else: act):
      let q_p = cast[ptr FloatArray](addr state.act_q[l].data[p * dim])
      let outp = cast[ptr FloatArray](addr state.act_att_out[l][p * dim])
      let qScale = quantizeActivation(q_p, state.i8_qscratch, dim)
      for d in 0 ..< dim: outp[d] = 0.0
      for h in 0 ..< state.numHeads:
        let h_off = h * state.headSize
        var max_s: cfloat = NegInf.cfloat
        if awOn:
          snaiAtvScores(addr state.i8_qscratch[h_off], addr attKT8[l.int][h_off.int * act.int],
                        cast[ptr cfloat](addr state.k_cache_q8[l].scale[0]), act, state.headSize, (p + 1).cint,
                        qScale, sqrt(state.headSize.float32), cast[ptr cfloat](addr state.scores_buf[0]))
          for t in 0 .. p:
            let sc = state.scores_buf[t]
            if sc > max_s: max_s = sc
        else:
          for t in 0 .. p:
            let kRow = t * dim
            var acc: int32 = 0
            for d in 0 ..< state.headSize:
              acc += int32(state.i8_qscratch[h_off + d]) * int32(state.k_cache_q8[l].data[kRow + h_off + d])
            var sc = acc.cfloat * qScale * state.k_cache_q8[l].scale[t]
            sc /= sqrt(state.headSize.float32)
            state.scores_buf[t] = sc
            if sc > max_s: max_s = sc
        var sum_e: cfloat = 0.0
        for t in 0 .. p:
          state.scores_buf[t] = exp(state.scores_buf[t] - max_s)
          sum_e += state.scores_buf[t]
        let awBase = h.int * awTri + p.int * (p.int + 1) div 2
        if awOn:
          let vfL = cast[ptr FloatArray](addr attVf[l.int][0])
          for t in 0 .. p:
            let w = state.scores_buf[t] / sum_e
            attWBuf[l.int][awBase + t.int] = w
            let vRow = t * dim
            snaiAxpyF32(cast[ptr cfloat](addr outp[h_off]), cast[ptr cfloat](addr vfL[vRow + h_off]), w, state.headSize)
        else:
          for t in 0 .. p:
            let w = state.scores_buf[t] / sum_e
            let vRow = t * dim
            let vScale = state.v_cache_q8[l].scale[t]
            for d in 0 ..< state.headSize:
              outp[h_off + d] += (state.v_cache_q8[l].data[vRow + h_off + d].cfloat * vScale) * w

    matMulBatchedI8(state.w_o_q8[l], state.act_att_out[l], state.mm_hd_scratch, qb, qs, act)
    loraForwardBatch(state, l, 3, state.act_att_out[l], state.mm_hd_scratch, act)
    if parOn(PG_VEC):
      parVec(state, state.act_hidden_final, state.mm_hd_scratch, 1, act, dim)
      parVec(state, state.act_hidden_final, state.act_hidden_ffn[l], 0, act, dim)
    else:
      for i in 0 ..< (act * dim): state.act_hidden_final[i] += state.mm_hd_scratch[i]
      for i in 0 ..< (act * dim): state.act_hidden_ffn[l][i] = state.act_hidden_final[i]
    if not ffnAusL(state, l):   # FFN-SKIP: Zweig aus -> Beitrag exakt 0
      parNorm(state, state.act_hidden_final, state.act_norm_ffn[l], state.rms_ffn_weights[l], act, dim)

      # SCHRITT 4c: liegt act_ffn_in quantisiert vor, schreibt das GEMM in den
      # gemeinsamen Scratch; die Historie wird daraus kodiert und die SiLU
      # rechnet anschliessend IN PLACE auf demselben Puffer weiter. Dadurch
      # genuegt EIN float-Puffer fuer beide FFN-Zwischenwerte.
      let ffnIn = (if state.quantActsIn != 0: state.act_ffn_scratch else: state.act_ffn_in[l])
      matMulBatchedI8(state.w_up_q8[l], state.act_norm_ffn[l], ffnIn, qb, qs, act)
      # Muss VOR der Quantisierung von act_ffn_in und vor der SiLU stehen -
      # sonst saehe der Backward eine Historie ohne den Adapter-Anteil, und
      # die SiLU-Ableitung waere an der falschen Stelle ausgewertet.
      loraForwardBatch(state, l, 4, state.act_norm_ffn[l], ffnIn, act)
      if state.quantActsIn != 0:
        if parOn(PG_FFN): parFfn(state, l, 0, ffnIn, nil, state.act_ffn_in_q8[l], act, ffn)
        for p in 0 ..< (if parOn(PG_FFN): 0.cint else: act):
          quantizeVectorToQ8Row(cast[ptr FloatArray](addr ffnIn[p * ffn]),
                                state.act_ffn_in_q8[l], p.cint, ffn.cint)
      # Zielpuffer der FFN-Aktivierung: bei aktivem Speicherumbau der gemeinsame
      # Scratch, sonst die float-Historie dieses Layers.
      let ffnOut = (if state.quantActs != 0: state.act_ffn_scratch else: state.act_ffn_out[l])
      # SCHRITT 5a: liegt act_ffn_in quantisiert vor, kommt SiLU aus einer
      # 256er-Tabelle je Position statt aus `ffn` exp()-Aufrufen.
      if not state.silu_exp_ok.isNil: state.silu_exp_ok[l] = 0
      if i8_silu_lut != 0 and state.quantActsIn != 0 and not state.silu_lut.isNil:
        if parOn(PG_FFN): parFfn(state, l, 1, nil, ffnOut, state.act_ffn_in_q8[l], act, ffn)
        for p in 0 ..< (if parOn(PG_FFN): 0.cint else: act):
          let ex = siluExpRow(state, l, p)
          siluRowFromQ8(state.act_ffn_in_q8[l], p, ffnOut, p * ffn, ffn, state.silu_lut, ex)
          siluExpRot(state, ex, l, p)
        if siluExpMode() > 0 and not state.silu_exp_ok.isNil: state.silu_exp_ok[l] = 1
      else:
        for i in 0 ..< (act * ffn):
          let v = ffnIn[i]
          ffnOut[i] = v * (1.0 / (1.0 + exp(-v)))
      applyDropoutForward(ffnOut, state.dropout_mask[l], act * ffn)
      # SCHRITT 4b: act_ffn_out als int8 mit Pro-Position-Skala in die Historie.
      # Der Forward rechnet weiter auf dem float-Scratch (ffnOut) - die
      # Quantisierung betrifft nur, was fuer den BACKWARD aufgehoben wird.
      if state.quantActs != 0:
        if parOn(PG_FFN): parFfn(state, l, 0, ffnOut, nil, state.act_ffn_out_q8[l], act, ffn)
        for p in 0 ..< (if parOn(PG_FFN): 0.cint else: act):
          quantizeVectorToQ8Row(cast[ptr FloatArray](addr ffnOut[p * ffn]),
                                state.act_ffn_out_q8[l], p.cint, ffn.cint)
      # SCHRITT 4b (Simulation, unabhaengig vom Speicherumbau): act_ffn_in auf
      # int8-Aufloesung bringen. Fuer act_ffn_out ist das ueberfluessig, sobald
      # der Umbau aktiv ist - dann steht die quantisierte Fassung ohnehin schon.
      if i8_quant_acts != 0 and state.quantActsIn == 0:
        quantDequantActRows(state.act_ffn_in[l], act, ffn)
        if state.quantActs == 0:
          quantDequantActRows(ffnOut, act, ffn)
      matMulBatchedI8(state.w_down_q8[l], ffnOut, state.mm_hd_scratch, qb, qs, act)
      loraForwardBatch(state, l, 5, ffnOut, state.mm_hd_scratch, act)
      if parOn(PG_VEC): parVec(state, state.act_hidden_final, state.mm_hd_scratch, 1, act, dim)
      else:
        for i in 0 ..< (act * dim): state.act_hidden_final[i] += state.mm_hd_scratch[i]

  parNorm(state, state.act_hidden_final, state.act_norm_final, state.rms_final_weight, act, dim)

  let logits_all = cast[ptr FloatArray](state.logits_cache.data)
  matMulBatchedI8(state.w_out_q8, state.act_norm_final, logits_all, qb, qs, act)

  let smPar = smParMode() != 0
  if smPar:
    var smL = newSeq[cfloat](act.int)
    var pS = SmArgs(sLog: logits_all, sTg: t_tg, sMask: t_mask, sLoss: cast[ptr FloatArray](addr smL[0]),
                    sVocab: vocab, sRot: smParMode() == 2)
    let pSp = addr pS
    {.push checks: off.}
    for p in 0 || (act - 1):
      snaiSmRowC(pSp, p)
    {.pop.}
    for p in 0 ..< act:
      if t_mask[p] != 0:
        total_loss += smL[p]
        inc trainable_count

  for p in 0 ..< (if smPar: 0.cint else: act):
    var tgid = t_tg[p]
    if tgid < 0 or tgid >= vocab: tgid = 0
    let base = p * vocab
    var max_l: cfloat = -9999.0
    for v in 0 ..< vocab:
      if logits_all[base + v] > max_l: max_l = logits_all[base + v]
    var sum_p: cfloat = 0.0
    for v in 0 ..< vocab:
      logits_all[base + v] = exp(logits_all[base + v] - max_l)
      sum_p += logits_all[base + v]
    for v in 0 ..< vocab:
      logits_all[base + v] /= sum_p
    if t_mask[p] != 0:
      total_loss += -ln(logits_all[base + tgid] + 1e-7)
      inc trainable_count

  # d_logits IN-PLACE in logits_cache (wie im FP32-Pfad)
  for p in 0 ..< (if smPar: 0.cint else: act):
    var tgid = t_tg[p]
    if tgid < 0 or tgid >= vocab: tgid = 0
    let base = p * vocab
    if t_mask[p] != 0:
      for v in 0 ..< vocab:
        logits_all[base + v] = logits_all[base + v] - smoothedTarget(v, tgid, vocab)
    else:
      for v in 0 ..< vocab: logits_all[base + v] = 0.0

  lossOut = total_loss
  cntOut = trainable_count

proc bwdBatchedCpu(state: ptr CortexState, t_in: ptr IntArray, act: cint) =
  ## RESIDENT (seit 2026-11-11, e624/e625): der Rueckwaertsteil von trainStepI8Batched, woertlich hierher verschoben.
  let dim = state.hiddenDim
  let ffn = state.ffnDim
  let vocab = state.vocabSize
  let loraFrozen = loraOn(state) and state.loraFrozenBase != 0
  let logits_all = cast[ptr FloatArray](state.logits_cache.data)
  # --- BACKWARD ---
  matMulTBatchedI8(state.w_out_q8, logits_all, state.d_norm_all, act, false, state)
  if not loraFrozen:
    gradAccumBatchedI8(state.w_out_q8, state.g_w_out, logits_all, state.act_norm_final, act, state)

  parNormBw(state, state.d_norm_all, state.d_hidden_all, state.act_hidden_final,
            state.rms_final_weight, state.g_rms_final_weight, false, act, dim)

  for l in countdown(state.numLayers - 1, 0):
    if not ffnAusL(state, l):   # FFN-SKIP: alle Gradienten des Zweigs exakt 0
      matMulTBatchedI8(state.w_down_q8[l], state.d_hidden_all, state.mm_ffn_scratch, act, false, state)
      # LoRA braucht die FFN-Ausgabe als float. Liegt sie quantisiert vor, einmal
      # in denselben Scratch dequantisieren, den der Fallback-Zweig unten ohnehin
      # benutzt - kein zweiter Puffer, keine zweite Rechenvorschrift.
      if loraSlotOn(state, 5) and state.quantActs != 0:
        for p in 0 ..< act:
          let s5 = state.act_ffn_out_q8[l].scale[p]
          let b5 = p * ffn
          for c in 0 ..< ffn:
            state.act_ffn_scratch[b5 + c] = state.act_ffn_out_q8[l].data[b5 + c].cfloat * s5
      loraBackwardBatch(state, l, 5, state.d_hidden_all,
                        (if state.quantActs != 0: state.act_ffn_scratch else: state.act_ffn_out[l]),
                        state.mm_ffn_scratch, act)
      # SCHRITT 4b: liegt act_ffn_out quantisiert vor, direkt darauf rechnen -
      # das spart nicht nur den float-Puffer, sondern auch die Requantisierung.
      if loraFrozen:
        # Eingefrorene Basis: der Gradient dieses Gewichts wird nie benutzt.
        # Ihn trotzdem zu berechnen waere die teuerste Stelle des Backwards -
        # und genau die Rechenzeit, die LoRA einsparen soll.
        discard
      elif state.quantActs != 0 and i8_int_gradacc != 0 and state.i8_bwThreads > 0 and
           scratchThreadsOk(state) and
           act.int <= (high(int32).int div (127 * 127)):
        # Dieselben Bedingungen wie gradAccumBatchedI8: Mehr Threads als beim
        # Allokieren teilen sich sonst still denselben Akkumulator (min(tid, maxT-1)).
        gradAccumBatchedQI8C(state.g_w_down[l], state.d_hidden_all, state.act_ffn_out_q8[l],
                             act.cint, state.i8_gdscale, state.i32_dacc,
                             state.i8_accStride.int, state.i8_bwThreads.int,
                             (if useGpuQMat(state.w_down_q8[l]): 1.cint else: 0.cint))
      elif state.quantActs != 0:
        # Fallback: Ganzzahl-Gradientenakkumulation abgeschaltet -> dequantisieren.
        for p in 0 ..< act:
          let sc = state.act_ffn_out_q8[l].scale[p]
          let base = p * ffn
          for c in 0 ..< ffn:
            state.act_ffn_scratch[base + c] = state.act_ffn_out_q8[l].data[base + c].cfloat * sc
        gradAccumBatchedI8(state.w_down_q8[l], state.g_w_down[l], state.d_hidden_all, state.act_ffn_scratch, act, state)
      else:
        gradAccumBatchedI8(state.w_down_q8[l], state.g_w_down[l], state.d_hidden_all, state.act_ffn_out[l], act, state)
      applyDropoutBackward(state.mm_ffn_scratch, state.dropout_mask[l], act * ffn)
      if parOn(PG_FFN): parFfn(state, l, 2, nil, nil, QMatrix(), act, ffn)
      let siluTab = siluExpUse(state, l)
      for i in 0 ..< (if parOn(PG_FFN) or not siluTab: 0.cint else: act * ffn):
        # SILU-EXP: expf(-x) aus der Tabelle des Vorwaerts (Zeile = Position, Index = Code + 128).
        let dq = state.act_ffn_in_q8[l].data[i]
        let x = dq.cfloat * state.act_ffn_in_q8[l].scale[i div ffn]
        let ex = state.silu_exp[l][(i div ffn) * 256 + dq.int + 128]
        let sig = 1.0 / (1.0 + ex)
        state.mm_ffn_scratch[i] *= sig * (1.0 + x * (1.0 - sig))
      for i in 0 ..< (if parOn(PG_FFN) or siluTab: 0.cint else: act * ffn):
        # SCHRITT 4c: x aus der quantisierten Historie dequantisieren
        # (Pro-Position-Skala, Zeile = Position).
        let x = (if state.quantActsIn != 0:
                   state.act_ffn_in_q8[l].data[i].cfloat * state.act_ffn_in_q8[l].scale[i div ffn]
                 else: state.act_ffn_in[l][i])
        let sig = 1.0 / (1.0 + exp(-x))
        state.mm_ffn_scratch[i] *= sig * (1.0 + x * (1.0 - sig))
      matMulTBatchedI8(state.w_up_q8[l], state.mm_ffn_scratch, state.d_att_out_all, act, false, state)
      loraBackwardBatch(state, l, 4, state.mm_ffn_scratch, state.act_norm_ffn[l],
                        state.d_att_out_all, act)
      if not loraFrozen:
        gradAccumBatchedI8(state.w_up_q8[l], state.g_w_up[l], state.mm_ffn_scratch, state.act_norm_ffn[l], act, state)

      parNormBw(state, state.d_att_out_all, state.d_hidden_all, state.act_hidden_ffn[l],
                state.rms_ffn_weights[l], state.g_rms_ffn_weights[l], true, act, dim)

    matMulTBatchedI8(state.w_o_q8[l], state.d_hidden_all, state.d_att_out_all, act, false, state)
    loraBackwardBatch(state, l, 3, state.d_hidden_all, state.act_att_out[l],
                      state.d_att_out_all, act)
    if not loraFrozen:
      gradAccumBatchedI8(state.w_o_q8[l], state.g_w_o[l], state.d_hidden_all, state.act_att_out[l], act, state)

    # ATT-BW-PAR (2026-10-14, patch_att_bw_par.py): Koepfe parallel, Positionen innen in derselben
    # Reihenfolge - bitgleich zum seriellen Pfad (else-Zweig). Stellrad SNAI_I8_ATT_BW.
    if attBwMode() > 0:
      let bwQp = i8_att_bw_quantq != 0
      var abQ = newSeq[int8](if bwQp: act * dim else: 1)
      var abQs = newSeq[cfloat](act)
      if bwQp:
        for p in 0 ..< act:
          abQs[p] = quantizeActivation(cast[ptr FloatArray](addr state.act_q[l].data[p * dim]),
                                       cast[ptr Int8Array](addr abQ[p * dim]), dim.cint)
      var abS = newSeq[cfloat](state.numHeads * act)
      var abW = newSeq[cfloat](state.numHeads * act)
      var pB = AttBwArgs(bSt: state, bL: l, bAct: act, bDim: dim, bQ: cast[ptr Int8Array](addr abQ[0]),
                         bQs: cast[ptr FloatArray](addr abQs[0]), bS: cast[ptr FloatArray](addr abS[0]),
                         bW: cast[ptr FloatArray](addr abW[0]), bQuant: bwQp, bRot: attBwMode() == 2)
      if bwQp and attWMode() > 0 and l.int < attWValid.len and attWValid[l.int] and
         attWOwner == cast[pointer](state) and attWActV[l.int] == act.int:
        pB.bWc = cast[ptr FloatArray](addr attWBuf[l.int][0])
        pB.bKf = cast[ptr FloatArray](addr attKf[l.int][0])
        pB.bVf = cast[ptr FloatArray](addr attVf[l.int][0])
        pB.bVT = cast[ptr FloatArray](addr attVT[l.int][0])
        pB.bXRot = attWMode() == 5
        pB.bWRot = attWMode() == 2
        if attBwBlkOn(state.hiddenDim.int):
          let need = state.numHeads.int * attBwBlkPerHead(act.int)
          if attBwBlkBuf.len < need: attBwBlkBuf.setLen(need)
          pB.bBlk = cast[ptr FloatArray](addr attBwBlkBuf[0])
          let needDs = state.numHeads.int * attBwBlkP * act.int
          if attBwBlkDsBuf.len < needDs: attBwBlkDsBuf.setLen(needDs)
          pB.bBlkDs = cast[ptr UncheckedArray[cdouble]](addr attBwBlkDsBuf[0])
          pB.bBRot = attBwBlkMode() == 2
      if l.int < attWValid.len: attWValid[l.int] = false
      let pBp = addr pB
      # ATT-GPU: rechnet die Karte, laeuft die Kopfschleife leer.
      let nHeads = (if bwQp and attGpuBw(state, l.int, act.int, abQ, abQs): 0.cint else: state.numHeads)
      zeitMiss(ZA_ATTB):
        {.push checks: off.}
        for h in 0 || (nHeads - 1):
          snaiAttBwHeadC(pBp, h)
        {.pop.}
    else:
      # Attention-Backward je Position (CPU), identisch zum Einzelpfad.
      for p in countdown(act - 1, 0):
        let off = p * dim
        let q_p = cast[ptr FloatArray](addr state.act_q[l].data[off])
        let d_att = cast[ptr FloatArray](addr state.d_att_out_all[off])
        for d in 0 ..< dim: state.d_q[d] = 0.0
        # ATTFIX: q wie im Forward quantisieren (act_q haelt das RoPE-gedrehte q,
        # dieselbe Eingabe wie dort). i8_qscratch ist in dieser Schleife frei.
        let bwQ = i8_att_bw_quantq != 0
        var qScaleBw: cfloat = 1.0
        if bwQ: qScaleBw = quantizeActivation(q_p, state.i8_qscratch, dim)
        template qElem(idx: int): cfloat =
          (if bwQ: state.i8_qscratch[idx].cfloat * qScaleBw else: q_p[idx])
        template kElem(t, idx: int): cfloat =
          state.k_cache_q8[l].data[t * dim + idx].cfloat * state.k_cache_q8[l].scale[t]
        template vElem(t, idx: int): cfloat =
          state.v_cache_q8[l].data[t * dim + idx].cfloat * state.v_cache_q8[l].scale[t]
        for h in 0 ..< state.numHeads:
          let h_off = h * state.headSize
          let attScale = 1.0 / sqrt(state.headSize.float32)
          var max_s: cfloat = NegInf.cfloat
          for t in 0 .. p:
            var sc: cfloat = 0.0
            if bwQ:
              # ATTFIX: exakt die Rechnung des Forwards (int8 x int8, gleiche
              # Reihenfolge der Float-Operationen) - bitgleiche Scores.
              let kRow = t * dim
              var acc: int32 = 0
              for d in 0 ..< state.headSize:
                acc += int32(state.i8_qscratch[h_off + d]) * int32(state.k_cache_q8[l].data[kRow + h_off + d])
              sc = acc.cfloat * qScaleBw * state.k_cache_q8[l].scale[t]
              sc /= sqrt(state.headSize.float32)
            else:
              for d in 0 ..< state.headSize:
                sc += q_p[h_off + d] * kElem(t, h_off + d)
              sc *= attScale
            state.scores_buf[t] = sc
            if sc > max_s: max_s = sc
          var sum_e: cfloat = 0.0
          for t in 0 .. p:
            state.scores_buf[t] = exp(state.scores_buf[t] - max_s)
            sum_e += state.scores_buf[t]
          var sum_w_dw: cfloat = 0.0
          for t in 0 .. p:
            let w = state.scores_buf[t] / sum_e
            state.scores_buf[t] = w
            var dw: cfloat = 0.0
            for d in 0 ..< state.headSize:
              dw += d_att[h_off + d] * vElem(t, h_off + d)
            let d_v_t = cast[ptr FloatArray](addr state.d_v_cache[l].data[t * dim])
            for d in 0 ..< state.headSize:
              d_v_t[h_off + d] += d_att[h_off + d] * w
            state.d_w_buf[t] = dw
            sum_w_dw += w * dw
          for t in 0 .. p:
            let w = state.scores_buf[t]
            let ds = w * (state.d_w_buf[t] - sum_w_dw) * attScale
            let d_k_t = cast[ptr FloatArray](addr state.d_k_cache[l].data[t * dim])
            for d in 0 ..< state.headSize:
              state.d_q[h_off + d] += ds * kElem(t, h_off + d)
              d_k_t[h_off + d] += ds * qElem(h_off + d)
        for d in 0 ..< dim: state.d_q_all[off + d] = state.d_q[d]

    # RoPE-Rueckdrehung fuer d_q und d_k, dann die drei QKV-Backwards gebuendelt.
    if parOn(PG_ROPEBW):
      var ra = ParArgs(st: state, act: act.int, dim: dim.int, a: state.d_q_all,
                       b: cast[ptr FloatArray](state.d_k_cache[l].data), rot: parRot(PG_ROPEBW))
      let rap = addr ra
      {.push checks: off.}
      for p in 0 || (act - 1):
        parRopeBwRowC(rap, p)
      {.pop.}
    for p in 0 ..< (if parOn(PG_ROPEBW): 0.cint else: act):
      applyRoPE(cast[ptr FloatArray](addr state.d_q_all[p * dim]), dim, state.headSize, state.ctxSize, p, true)
      applyRoPE(cast[ptr FloatArray](addr state.d_k_cache[l].data[p * dim]), dim, state.headSize, state.ctxSize, p, true)

    matMulTBatchedI8(state.w_q_q8[l], state.d_q_all, state.mm_hd_scratch, act, false, state)
    loraBackwardBatch(state, l, 0, state.d_q_all, state.act_norm_att[l], state.mm_hd_scratch, act)
    if not loraFrozen:
      gradAccumBatchedI8(state.w_q_q8[l], state.g_w_q[l], state.d_q_all, state.act_norm_att[l], act, state)
    matMulTBatchedI8(state.w_k_q8[l], cast[ptr FloatArray](state.d_k_cache[l].data), state.mm_hd_scratch, act, true, state)
    loraBackwardBatch(state, l, 1, cast[ptr FloatArray](state.d_k_cache[l].data),
                      state.act_norm_att[l], state.mm_hd_scratch, act)
    if not loraFrozen:
      gradAccumBatchedI8(state.w_k_q8[l], state.g_w_k[l], cast[ptr FloatArray](state.d_k_cache[l].data), state.act_norm_att[l], act, state)
    matMulTBatchedI8(state.w_v_q8[l], cast[ptr FloatArray](state.d_v_cache[l].data), state.mm_hd_scratch, act, true, state)
    loraBackwardBatch(state, l, 2, cast[ptr FloatArray](state.d_v_cache[l].data),
                      state.act_norm_att[l], state.mm_hd_scratch, act)
    if not loraFrozen:
      gradAccumBatchedI8(state.w_v_q8[l], state.g_w_v[l], cast[ptr FloatArray](state.d_v_cache[l].data), state.act_norm_att[l], act, state)

    parNormBw(state, state.mm_hd_scratch, state.d_hidden_all, state.act_hidden[l],
              state.rms_att_weights[l], state.g_rms_att_weights[l], true, act, dim)

  if not loraFrozen and parOn(PG_EMB):
    var ga = ParArgs(st: state, act: act.int, dim: dim.int, vocab: vocab.int, tin: t_in, modus: 1)
    let gap = addr ga
    {.push checks: off.}
    for d in 0 || (dim - 1):
      parEmbRowC(gap, d)
    {.pop.}
  if not loraFrozen and not parOn(PG_EMB):
    for p in 0 ..< act:
      var tid = t_in[p]
      if tid < 0 or tid >= vocab: tid = 0
      let off = p * dim
      for d in 0 ..< dim:
        state.g_embeddings.data[tid * dim + d] += state.d_hidden_all[off + d] * embFak(state)


proc trainStepI8Batched(state: ptr CortexState, t_in, t_tg, t_mask: ptr IntArray,
                        act: cint, lr: cfloat, trainableOut: var cint): cfloat =
  ## Layer-major Spiegel von cortex_train_step_i8(): mathematisch dieselbe
  ## Rechnung, nur werden alle Positionen eines Layers gemeinsam durch die
  ## Matmuls geschickt. Attention und die Normierungen bleiben Positions-
  ## Schleifen auf der CPU (sie sind nicht die Kernel-Start-Treiber).
  let dim = state.hiddenDim
  let ffn = state.ffnDim
  let vocab = state.vocabSize
  let qb = state.i8_qbatch
  let qs = state.i8_qbatch_scale
  # LoRA mit eingefrorener Basis: die Basis-Gradienten werden nicht mehr
  # akkumuliert. Der EINGANGS-Gradient (matMulTBatchedI8) bleibt selbstver-
  # staendlich - ohne ihn kaeme nichts mehr bei den unteren Schichten an.
  let loraFrozen = loraOn(state) and state.loraFrozenBase != 0
  var total_loss: cfloat = 0.0
  var trainable_count: cint = 0

  # --- FORWARD ---
  # RESIDENT (seit 2026-11-11, e624/e625): Vorwaerts wahlweise auf der Karte (resFwd), sonst fwdBatchedCpu.
  let rm = resMode()
  var resDone = false
  var resB = false
  if rm > 0 and resEligible(state):
    let wantB = rm != 1 and resBEligible(state, act)
    if rm == 2 or rm == 4 or rm == 7:
      fwdBatchedCpu(state, t_in, t_tg, t_mask, act, total_loss, trainable_count)
      resB = resCheck(state, t_in, t_tg, t_mask, act, total_loss, trainable_count) and wantB
      resDone = true
    else:
      resDone = resFwd(state, t_in, t_tg, t_mask, act, total_loss, trainable_count, not wantB)
      if resDone:
        inc resSteps
        resB = wantB
      else: inc resFallbacks
  if not resDone:
    fwdBatchedCpu(state, t_in, t_tg, t_mask, act, total_loss, trainable_count)
  elif not (rm == 2 or rm == 4 or rm == 7):
    # HAUPTBAUM-PORT: der Kartenvorwaerts schreibt weder ATT-W-Gewichte noch die SiLU-exp-Tabelle. Ein folgender
    # CPU-Rueckwaerts darf keine Reste eines frueheren CPU-Vorwaerts lesen.
    for l in 0 ..< state.numLayers.int:
      if l < attWValid.len: attWValid[l] = false
      if not state.silu_exp_ok.isNil: state.silu_exp_ok[l] = 0
  let logits_all = cast[ptr FloatArray](state.logits_cache.data)

  # --- BACKWARD ---
  # RESIDENT Stufe B (seit 2026-11-11, e624/e625): w_out wie bisher auf der CPU, der Rest auf der Karte (resBwd).
  # CHECK: erst der alte Weg, Gradienten sichern, zuruecksetzen, Kartenweg, bitweise vergleichen.
  let rotB = (if rm == 6 or rm == 7: 1 else: 0)
  if resB and (rm == 2 or rm == 4 or rm == 7):
    bwdBatchedCpu(state, t_in, act)
    let gl = resGradList(state)
    let vor = resGradSnap(gl)
    for g in gl:
      if g[3]: gpuZeroBuffer(cast[ptr cfloat](g[1]), g[2].csize_t)
      else: zeroMem(g[1], g[2])
    matMulTBatchedI8(state.w_out_q8, logits_all, state.d_norm_all, act, false, state)
    gradAccumBatchedI8(state.w_out_q8, state.g_w_out, logits_all, state.act_norm_final, act, state)
    if not resBwd(state, t_in, act, rotB.int):
      stderr.writeLine("[RESIDENT] FEHLER: Rueckwaertsweg auf der Karte abgebrochen (CHECK)")
      quit(3)
    let nach = resGradSnap(gl)
    var meld: seq[string]
    for i, g in gl:
      if vor[i] == nach[i]: continue
      var cntB = 0
      var first = -1
      for j in 0 ..< g[2]:
        if vor[i][j] != nach[i][j]:
          inc cntB
          if first < 0: first = j
      let e = first div 4
      meld.add(g[0] & ": " & $cntB & " Bytes abweichend, Element " & $e & ": CPU " &
               $cast[ptr cfloat](unsafeAddr vor[i][e * 4])[] & " Karte " & $cast[ptr cfloat](unsafeAddr nach[i][e * 4])[])
    if meld.len > 0:
      inc resBwCheckBad
      if resBwCheckBad <= 5:
        stderr.writeLine("[RESIDENT] CHECK rueckwaerts: ", meld.len, " Gradienten abweichend")
        for z in meld: stderr.writeLine("[RESIDENT]   ", z)
  elif resB:
    matMulTBatchedI8(state.w_out_q8, logits_all, state.d_norm_all, act, false, state)
    gradAccumBatchedI8(state.w_out_q8, state.g_w_out, logits_all, state.act_norm_final, act, state)
    if not resBwd(state, t_in, act, rotB.int):
      stderr.writeLine("[RESIDENT] FEHLER: Rueckwaertsweg auf der Karte abgebrochen - Gradienten unbestimmt, Abbruch")
      quit(3)
    inc resBwSteps
  else:
    bwdBatchedCpu(state, t_in, act)

  trainableOut = trainable_count
  return total_loss / max(1, trainable_count).cfloat

proc cortexTrainStepI8Roh(state: ptr CortexState, raw_in: ptr cint, raw_tg: ptr cint, raw_mask: ptr cint, num_tok: cint, lr: cfloat): cfloat =
  if state.isNil or state.weightDtype != 1: return -1.0
  # SPEICHER-AUDIT 2026-08-19: bei einem reinen Inferenz-Artefakt (SNAI_V6
  # ohne Adam-Block) hat cortex_load_stream_i8() m/v/g freigegeben. Training
  # darauf ist nicht moeglich - laut scheitern statt in einen Nullzeiger
  # laufen.
  # SCHRITT 4b: der Einzelpfad liest act_ffn_out als float-Historie, die bei
  # aktivem Speicherumbau nicht existiert. Lieber hier laut scheitern als
  # spaeter in einen Nullzeiger laufen - der Aufrufer hat dann eine klare
  # Meldung statt eines Segfaults.
  if (state.quantActs != 0 or state.quantActsIn != 0) and batched_i8 == 0:
    stderr.writeLine("[cortex] FATAL: quantisierte FFN-Aktivierungen (Schritt 4b) ",
                     "erfordern den gebuendelten Pfad - cortex_set_batched_i8(1) setzen.")
    return -1.0
  # LoRA ist NUR im gebuendelten Pfad verdrahtet. Der Positions-major-Spiegel
  # unten ist bewusst nicht mit angefasst worden: zwei Fassungen derselben
  # Mathematik driften in diesem Projekt zuverlaessig auseinander (siehe
  # Erfahrung mit den drei Adam-Kerneln). Lieber hier laut scheitern, als still
  # ohne Adapter zu trainieren - der Loss faellt dann trotzdem, und man haelte
  # das Ergebnis fuer eine LoRA-Messung.
  if loraOn(state) and batched_i8 == 0:
    stderr.writeLine("[cortex] FATAL: LoRA ist aktiv, aber der gebuendelte Pfad ist aus. ",
                     "cortex_set_batched_i8(1) setzen - sonst wuerde ohne Adapter ",
                     "trainiert, ohne dass es auffaellt.")
    return -1.0

  # SCHRITT 3 (Speicherumbau): bei quantisierten Momenten ist m_embeddings.data
  # LEGITIM nil - der Adam-Zustand liegt dann in mq_/vq_. Ohne diese
  # Unterscheidung verweigert der Trainingsschritt genau dann, wenn der Umbau
  # aktiv ist (beim ersten Testlauf aufgetreten: Loss kam als -1 zurueck).
  # SPEICHERARM: bei LoRA mit eingefrorener Basis ist der Basis-Adam-Zustand
  # ABSICHTLICH weg (loraFreeBaseOptState). Das ist kein Inferenz-Artefakt,
  # sondern der Normalfall dieses Arms - der Check darf hier nicht zuschlagen.
  # Andersherum bleibt er scharf: wer LoRA abschaltet und weiterzutrainieren
  # versucht, landet genau hier und bekommt eine klare Meldung statt eines
  # Nullzeigers.
  if state.baseOptFreed == 0 and
     state.m_embeddings.data.isNil and
     (state.quantAdam == 0 or state.mq_embeddings.data.isNil):
    stderr.writeLine("[cortex] FATAL: cortex_train_step_i8() auf einem reinen ",
                     "Inferenz-Artefakt (ohne Adam-Zustand) - Training nicht moeglich.")
    return -1.0
  if state.baseOptFreed != 0 and not loraOn(state):
    stderr.writeLine("[cortex] FATAL: der Optimierer-Zustand der Basis wurde fuer einen ",
                     "LoRA-Lauf freigegeben, aber es sind keine Adapter (mehr) aktiv. ",
                     "Dieser Zustand kann nichts mehr trainieren - neu laden.")
    return -1.0
  let act = min(num_tok, state.ctxSize)
  if act <= 0: return 0.0
  ffnSkipAktualisieren(state)   # FFN-SKIP: an den aktuellen Werten erkennen, vor Forward und Backward
  flushQWeightsToGpu(state)   # PHASE 7: veraltete VRAM-Gewichte auffrischen
  let t_in = cast[ptr IntArray](raw_in)
  let t_tg = cast[ptr IntArray](raw_tg)
  let t_mask = cast[ptr IntArray](raw_mask)
  var total_loss: cfloat = 0.0
  var trainable_count: cint = 0

  # PHASE 7: Gradienten der 7 ueber matVecMulBackwardAccI8() akkumulierten
  # Tensoren liegen im GPU-Fall im VRAM - dort MIT nullen, sonst summiert der
  # naechste Schritt auf den alten Stand auf. g_embeddings (Scatter-Add) und
  # die rms-Gradienten entstehen weiterhin nur auf der CPU.
  template zeroGradI8(qw: QMatrix, g: Matrix) =
    zeroMat(g)
    if useGpuQMat(qw): gpuZeroBuffer(cast[ptr cfloat](g.data), gradBytes(g))

  # SPEICHERARM: sind die Basis-Gradientenpuffer freigegeben, gibt es hier
  # nichts zu nullen - und ein Zugriff waere ein Nullzeiger.
  let baseGradsGone = state.baseOptFreed != 0
  if not baseGradsGone:
    zeroMat(state.g_embeddings)
    zeroGradI8(state.w_out_q8, state.g_w_out)
  zeroArr(state.g_rms_final_weight, state.hiddenDim)
  for l in 0 ..< state.numLayers:
    if not baseGradsGone:
      zeroGradI8(state.w_q_q8[l], state.g_w_q[l])
      zeroGradI8(state.w_k_q8[l], state.g_w_k[l])
      zeroGradI8(state.w_v_q8[l], state.g_w_v[l])
      zeroGradI8(state.w_o_q8[l], state.g_w_o[l])
      zeroGradI8(state.w_up_q8[l], state.g_w_up[l])
      zeroGradI8(state.w_down_q8[l], state.g_w_down[l])
    zeroArr(state.g_rms_att_weights[l], state.hiddenDim)
    zeroArr(state.g_rms_ffn_weights[l], state.hiddenDim)
    for i in 0 ..< (act * state.hiddenDim):
      state.d_k_cache[l].data[i] = 0.0
      state.d_v_cache[l].data[i] = 0.0
  # Adaptergradienten nullen - reine Hostpuffer, kein GPU-Zweig noetig, weil
  # sie nie geraeteseitig entstehen (das ist der ganze Sinn von Punkt 1 im
  # Feldkommentar).
  loraForEach(state):
    zeroMat(state.g_lora_a[i])
    zeroMat(state.g_lora_b[i])

  # PHASE 8: gebuendelter Pfad. Berechnet Forward+Backward layer-major und
  # faellt danach in die gemeinsame Nachbereitung unten (Gradienten
  # zurueckholen, Clipping, Adam) - die ist fuer beide Pfade identisch.
  var batchedLoss: cfloat = 0.0
  var usedBatched = false
  if batched_i8 != 0 and not state.i8_qbatch.isNil:
    zeitMiss(ZA_BATCH):
      batchedLoss = trainStepI8Batched(state, t_in, t_tg, t_mask, act, lr, trainable_count)
    usedBatched = true

  # --- FORWARD (Positions-major, Nicht-gebuendelt - Spiegel von Zeile ~1444ff) ---
  if not usedBatched:
    for pos in 0 ..< act:
      var tid = t_in[pos]
      var tgid = t_tg[pos]
      if tid < 0 or tid >= state.vocabSize: tid = 0
      if tgid < 0 or tgid >= state.vocabSize: tgid = 0
      let off_dim = pos * state.hiddenDim
      let off_ffn = pos * state.ffnDim
      for d in 0 ..< state.hiddenDim:
        state.hidden_state_buf[d] = state.embeddings_q8.data[tid * state.hiddenDim + d].cfloat * state.embeddings_q8.scale[tid] * embFak(state)

      for l in 0 ..< state.numLayers:
        for d in 0 ..< state.hiddenDim:
          state.act_hidden[l][off_dim + d] = state.hidden_state_buf[d]
        applyRMSNorm(state.hidden_state_buf, state.norm_buf, state.hiddenDim, state.rms_att_weights[l])
        for d in 0 ..< state.hiddenDim:
          state.act_norm_att[l][off_dim + d] = state.norm_buf[d]

        let q_p = cast[ptr FloatArray](addr state.act_q[l].data[off_dim])
        matVecMulI8(state.w_q_q8[l], state.norm_buf, q_p, state.i8_qscratch)
        applyRoPE(q_p, state.hiddenDim, state.headSize, state.ctxSize, pos)

        # KV-Cache-Quantisierung (Design-Entscheidung): K/V roh in kv_raw_buf
        # berechnen (RoPE braucht Realwerte), dann pro Position quantisiert in
        # k_cache_q8/v_cache_q8 Zeile `pos` schreiben - siehe Feld-Kommentar bei
        # k_cache_q8 oben.
        matVecMulI8(state.w_k_q8[l], state.norm_buf, state.kv_raw_buf, state.i8_qscratch)
        applyRoPE(state.kv_raw_buf, state.hiddenDim, state.headSize, state.ctxSize, pos)
        quantizeVectorToQ8Row(state.kv_raw_buf, state.k_cache_q8[l], pos.cint, state.hiddenDim)

        matVecMulI8(state.w_v_q8[l], state.norm_buf, state.kv_raw_buf, state.i8_qscratch)
        quantizeVectorToQ8Row(state.kv_raw_buf, state.v_cache_q8[l], pos.cint, state.hiddenDim)

        # Q selbst wird ebenfalls quantisiert (dynamische Skala wie eine
        # Aktivierung, siehe quantizeActivation) - i8_qscratch haelt ab hier bis
        # zum Ende des Attention-Blocks Q als INT8, wird danach vom naechsten
        # matVecMulI8-Aufruf (w_o) wieder ueberschrieben (sequenzielle
        # Wiederverwendung, keine Ueberlappung).
        let qScale = quantizeActivation(q_p, state.i8_qscratch, state.hiddenDim)

        for d in 0 ..< state.hiddenDim:
          state.att_out_buf[d] = 0.0
        for h in 0 ..< state.numHeads:
          let h_off = h * state.headSize
          var max_s: cfloat = NegInf.cfloat
          for t in 0 .. pos:
            # Echtes int8xint8->int32-Skalarprodukt zwischen Q und dem
            # gecachten K (Design-Entscheidung #4/KV-Cache-Design).
            let kRow = t * state.hiddenDim
            var acc: int32 = 0
            for d in 0 ..< state.headSize:
              acc += int32(state.i8_qscratch[h_off + d]) * int32(state.k_cache_q8[l].data[kRow + h_off + d])
            var sc = acc.cfloat * qScale * state.k_cache_q8[l].scale[t]
            sc /= sqrt(state.headSize.float32)
            state.scores_buf[t] = sc
            if sc > max_s: max_s = sc
          var sum_e: cfloat = 0.0
          for t in 0 .. pos:
            state.scores_buf[t] = exp(state.scores_buf[t] - max_s)
            sum_e += state.scores_buf[t]
          for t in 0 .. pos:
            let w = state.scores_buf[t] / sum_e
            # V wird beim Lesen dequantisiert (gewichtete Summe bleibt float,
            # ein Operand ist eine Wahrscheinlichkeitsverteilung - siehe
            # KV-Cache-Design).
            let vRow = t * state.hiddenDim
            let vScale = state.v_cache_q8[l].scale[t]
            for d in 0 ..< state.headSize:
              state.att_out_buf[h_off + d] += (state.v_cache_q8[l].data[vRow + h_off + d].cfloat * vScale) * w

        for d in 0 ..< state.hiddenDim:
          state.act_att_out[l][off_dim + d] = state.att_out_buf[d]
        matVecMulI8(state.w_o_q8[l], state.att_out_buf, state.d_norm, state.i8_qscratch)
        for d in 0 ..< state.hiddenDim:
          state.hidden_state_buf[d] += state.d_norm[d]

        if not ffnAusL(state, l):   # FFN-SKIP
          for d in 0 ..< state.hiddenDim:
            state.act_hidden_ffn[l][off_dim + d] = state.hidden_state_buf[d]
          applyRMSNorm(state.hidden_state_buf, state.norm_buf, state.hiddenDim, state.rms_ffn_weights[l])
          for d in 0 ..< state.hiddenDim:
            state.act_norm_ffn[l][off_dim + d] = state.norm_buf[d]

          matVecMulI8(state.w_up_q8[l], state.norm_buf, state.ffn_buf, state.i8_qscratch)
          for d in 0 ..< state.ffnDim:
            state.act_ffn_in[l][off_ffn + d] = state.ffn_buf[d]
          for d in 0 ..< state.ffnDim:
            let v = state.ffn_buf[d]
            state.ffn_buf[d] = v * (1.0 / (1.0 + exp(-v)))
          applyDropoutForward(state.ffn_buf, state.dropout_mask[l], state.ffnDim, off_ffn)
          for d in 0 ..< state.ffnDim:
            state.act_ffn_out[l][off_ffn + d] = state.ffn_buf[d]
          matVecMulI8(state.w_down_q8[l], state.ffn_buf, state.att_out_buf, state.i8_qscratch)
          for d in 0 ..< state.hiddenDim:
            state.hidden_state_buf[d] += state.att_out_buf[d]

      for d in 0 ..< state.hiddenDim:
        state.act_hidden_final[off_dim + d] = state.hidden_state_buf[d]
      applyRMSNorm(state.hidden_state_buf, state.norm_buf, state.hiddenDim, state.rms_final_weight)

      var max_l: cfloat = -9999.0
      let logits = cast[ptr FloatArray](addr state.logits_cache.data[pos * state.vocabSize])
      matVecMulI8(state.w_out_q8, state.norm_buf, logits, state.i8_qscratch)
      for v in 0 ..< state.vocabSize:
        if logits[v] > max_l: max_l = logits[v]
      var sum_p: cfloat = 0.0
      for v in 0 ..< state.vocabSize:
        logits[v] = exp(logits[v] - max_l)
        sum_p += logits[v]
      for v in 0 ..< state.vocabSize:
        logits[v] /= sum_p
      if t_mask[pos] != 0:
        total_loss += -ln(logits[tgid] + 1e-7)
        inc trainable_count

    # --- BACKWARD (countdown ueber Positionen, dann Layer - Spiegel von Zeile ~1690ff) ---
    for pos in countdown(act - 1, 0):
      var tid = t_in[pos]
      var tgid = t_tg[pos]
      if tid < 0 or tid >= state.vocabSize: tid = 0
      if tgid < 0 or tgid >= state.vocabSize: tgid = 0
      let off_dim = pos * state.hiddenDim
      let off_ffn = pos * state.ffnDim
      let logits = cast[ptr FloatArray](addr state.logits_cache.data[pos * state.vocabSize])

      if t_mask[pos] != 0:
        for v in 0 ..< state.vocabSize:
          state.d_logits_buf[v] = logits[v] - smoothedTarget(v, tgid, state.vocabSize)
      else:
        for v in 0 ..< state.vocabSize:
          state.d_logits_buf[v] = 0.0
      for d in 0 ..< state.hiddenDim:
        state.d_hidden[d] = 0.0

      let final_hidden = cast[ptr FloatArray](addr state.act_hidden_final[off_dim])
      applyRMSNorm(final_hidden, state.norm_buf, state.hiddenDim, state.rms_final_weight)
      matVecMulBackwardAccI8(state.w_out_q8, state.g_w_out, state.norm_buf, state.d_logits_buf, state.d_norm, false,
                             state.i8_dscratch, state.i32_dacc, state.i8_dbscale)
      applyRMSNormBackwardAcc(state.d_norm, final_hidden, state.hiddenDim, state.rms_final_weight, state.g_rms_final_weight)

      for d in 0 ..< state.hiddenDim:
        state.d_hidden[d] += state.d_norm[d]

      for l in countdown(state.numLayers - 1, 0):
        for d in 0 ..< state.hiddenDim:
          state.d_norm[d] = state.d_hidden[d]

        if not ffnAusL(state, l):   # FFN-SKIP
          let act_ffn_out_p = cast[ptr FloatArray](addr state.act_ffn_out[l][off_ffn])
          matVecMulBackwardAccI8(state.w_down_q8[l], state.g_w_down[l], act_ffn_out_p, state.d_norm, state.d_ffn, false,
                                 state.i8_dscratch, state.i32_dacc, state.i8_dbscale)

          applyDropoutBackward(state.d_ffn, state.dropout_mask[l], state.ffnDim, off_ffn)
          let act_ffn_in_p = cast[ptr FloatArray](addr state.act_ffn_in[l][off_ffn])
          for d in 0 ..< state.ffnDim:
            let x = act_ffn_in_p[d]
            let sig = 1.0 / (1.0 + exp(-x))
            state.d_ffn[d] *= sig * (1.0 + x * (1.0 - sig))

          let act_norm_ffn_p = cast[ptr FloatArray](addr state.act_norm_ffn[l][off_dim])
          matVecMulBackwardAccI8(state.w_up_q8[l], state.g_w_up[l], act_norm_ffn_p, state.d_ffn, state.d_norm, false,
                                 state.i8_dscratch, state.i32_dacc, state.i8_dbscale)

          let act_hidden_ffn_p = cast[ptr FloatArray](addr state.act_hidden_ffn[l][off_dim])
          applyRMSNormBackwardAcc(state.d_norm, act_hidden_ffn_p, state.hiddenDim, state.rms_ffn_weights[l], state.g_rms_ffn_weights[l])

          for d in 0 ..< state.hiddenDim:
            state.d_hidden[d] += state.d_norm[d]
        for d in 0 ..< state.hiddenDim:
          state.d_norm[d] = state.d_hidden[d]

        let act_att_out_p = cast[ptr FloatArray](addr state.act_att_out[l][off_dim])
        matVecMulBackwardAccI8(state.w_o_q8[l], state.g_w_o[l], act_att_out_p, state.d_norm, state.d_att_out, false,
                               state.i8_dscratch, state.i32_dacc, state.i8_dbscale)

        let q_p = cast[ptr FloatArray](addr state.act_q[l].data[off_dim])
        for d in 0 ..< state.hiddenDim:
          state.d_q[d] = 0.0
        # KV-Cache-Design: Backward liest K/V dequantisiert (float Q * float K,
        # wie bei matVecMulBackwardAccI8 - nur der FORWARD-GEMM ist echtes
        # int8xint8, Backward-Chain-Rule bleibt float, Design-Entscheidung #4).
        # ATTFIX: q wie im Forward quantisieren (siehe i8_att_bw_quantq).
        let bwQ = i8_att_bw_quantq != 0
        var qScaleBw: cfloat = 1.0
        if bwQ: qScaleBw = quantizeActivation(q_p, state.i8_qscratch, state.hiddenDim)
        template qElem(idx: int): cfloat =
          (if bwQ: state.i8_qscratch[idx].cfloat * qScaleBw else: q_p[idx])
        template kElem(t, idx: int): cfloat =
          state.k_cache_q8[l].data[t * state.hiddenDim + idx].cfloat * state.k_cache_q8[l].scale[t]
        template vElem(t, idx: int): cfloat =
          state.v_cache_q8[l].data[t * state.hiddenDim + idx].cfloat * state.v_cache_q8[l].scale[t]
        for h in 0 ..< state.numHeads:
          let h_off = h * state.headSize
          let attScale = 1.0 / sqrt(state.headSize.float32)
          var max_s: cfloat = NegInf.cfloat
          for t in 0 .. pos:
            var sc: cfloat = 0.0
            if bwQ:
              let kRow = t * state.hiddenDim
              var acc: int32 = 0
              for d in 0 ..< state.headSize:
                acc += int32(state.i8_qscratch[h_off + d]) * int32(state.k_cache_q8[l].data[kRow + h_off + d])
              sc = acc.cfloat * qScaleBw * state.k_cache_q8[l].scale[t]
              sc /= sqrt(state.headSize.float32)
            else:
              for d in 0 ..< state.headSize:
                sc += q_p[h_off + d] * kElem(t, h_off + d)
              sc *= attScale
            state.scores_buf[t] = sc
            if sc > max_s: max_s = sc
          var sum_e: cfloat = 0.0
          for t in 0 .. pos:
            state.scores_buf[t] = exp(state.scores_buf[t] - max_s)
            sum_e += state.scores_buf[t]
          var sum_w_dw: cfloat = 0.0
          for t in 0 .. pos:
            let w = state.scores_buf[t] / sum_e
            state.scores_buf[t] = w
            var dw: cfloat = 0.0
            for d in 0 ..< state.headSize:
              dw += state.d_att_out[h_off + d] * vElem(t, h_off + d)
            let d_v_t = cast[ptr FloatArray](addr state.d_v_cache[l].data[t * state.hiddenDim])
            for d in 0 ..< state.headSize:
              d_v_t[h_off + d] += state.d_att_out[h_off + d] * w
            state.d_w_buf[t] = dw
            sum_w_dw += w * dw
          for t in 0 .. pos:
            let w = state.scores_buf[t]
            let ds = w * (state.d_w_buf[t] - sum_w_dw) * attScale
            let d_k_t = cast[ptr FloatArray](addr state.d_k_cache[l].data[t * state.hiddenDim])
            for d in 0 ..< state.headSize:
              state.d_q[h_off + d] += ds * kElem(t, h_off + d)
              d_k_t[h_off + d] += ds * qElem(h_off + d)

        let current_d_k = cast[ptr FloatArray](addr state.d_k_cache[l].data[off_dim])
        let current_d_v = cast[ptr FloatArray](addr state.d_v_cache[l].data[off_dim])
        applyRoPE(state.d_q, state.hiddenDim, state.headSize, state.ctxSize, pos, true)
        applyRoPE(current_d_k, state.hiddenDim, state.headSize, state.ctxSize, pos, true)

        let act_norm_att_p = cast[ptr FloatArray](addr state.act_norm_att[l][off_dim])
        matVecMulBackwardAccI8(state.w_q_q8[l], state.g_w_q[l], act_norm_att_p, state.d_q, state.d_norm, false,
                               state.i8_dscratch, state.i32_dacc, state.i8_dbscale)
        matVecMulBackwardAccI8(state.w_k_q8[l], state.g_w_k[l], act_norm_att_p, current_d_k, state.d_norm, true,
                               state.i8_dscratch, state.i32_dacc, state.i8_dbscale)
        matVecMulBackwardAccI8(state.w_v_q8[l], state.g_w_v[l], act_norm_att_p, current_d_v, state.d_norm, true,
                               state.i8_dscratch, state.i32_dacc, state.i8_dbscale)

        let act_hidden_p = cast[ptr FloatArray](addr state.act_hidden[l][off_dim])
        applyRMSNormBackwardAcc(state.d_norm, act_hidden_p, state.hiddenDim, state.rms_att_weights[l], state.g_rms_att_weights[l])
        for d in 0 ..< state.hiddenDim:
          state.d_hidden[d] += state.d_norm[d]

      for d in 0 ..< state.hiddenDim:
        state.g_embeddings.data[tid * state.hiddenDim + d] += state.d_hidden[d] * embFak(state)

  # PHASE 7: Gegenstueck zum Nullen oben - die auf der GPU akkumulierten
  # Gradienten muessen zurueck auf den Host, BEVOR clipGlobalGradientNorm()
  # und der Adam-Schritt (beide CPU) sie lesen. Spiegelt exakt das
  # pullGrad-Muster des FP32-Pfades.
  template pullGradI8(qw: QMatrix, g: Matrix) =
    if useGpuQMat(qw): pullGradMerge(g)   # FIX 2026-10-13: zusammenfuehren statt ueberschreiben

  pullGradI8(state.w_out_q8, state.g_w_out)

  # SNAI_V7 / Tying: hier - und NUR hier - werden die beiden Gradientenanteile
  # desselben Gewichts zusammengefuehrt.
  #
  # Die Stelle ist bewusst gewaehlt und nicht beliebig: der Logit-Anteil landet
  # im GPU-Fall geraeteseitig in g_w_out und ist erst nach pullGradI8() auf dem
  # Host gueltig; der Lookup-Anteil ist ein reiner CPU-Scatter und steht schon
  # seit dem Backward in g_embeddings. Wuerde man beide von vornherein in EINEN
  # Puffer schreiben, holte pullGradI8() den Geraetestand und ueberschriebe die
  # CPU-Beitraege stillschweigend - die Fehlersignatur waere "Schritt 0
  # bitgleich, ab Schritt 1 klebt der Loss am Startwert" (Stichwort
  # "Gradienten-Speichermodell im INT8-GPU-Pfad"). Danach zusammenfuehren
  # umgeht das vollstaendig und gilt fuer CPU- und GPU-Pfad gleichermassen.
  #
  # g_w_out wird anschliessend genullt, damit clipGlobalGradientNorm() dasselbe
  # Gewicht nicht zweimal in die globale Norm einrechnet (es zaehlt g_embeddings
  # und g_w_out getrennt) und der Adam-Schritt es nicht doppelt anwendet.
  if state.tiedEmbeddings != 0 and not baseGradsGone:
    let nEmb = state.g_embeddings.rows.int * state.g_embeddings.cols.int
    for i in 0 ..< nEmb:
      state.g_embeddings.data[i] += state.g_w_out.data[i]
      state.g_w_out.data[i] = 0.0

  # SPEICHERARM: ohne Basis-Gradientenpuffer gibt es auch nichts abzuholen. Die
  # Adaptergradienten entstehen ausschliesslich host-seitig (Feld-Kommentar
  # Punkt 1) und laufen nie ueber pullGradI8().
  if not baseGradsGone:
    for l in 0 ..< state.numLayers:
      pullGradI8(state.w_q_q8[l], state.g_w_q[l])
      pullGradI8(state.w_k_q8[l], state.g_w_k[l])
      pullGradI8(state.w_v_q8[l], state.g_w_v[l])
      pullGradI8(state.w_o_q8[l], state.g_w_o[l])
      pullGradI8(state.w_up_q8[l], state.g_w_up[l])
      pullGradI8(state.w_down_q8[l], state.g_w_down[l])

  # Clip-Schwelle skaliert mit trainable_count (Summen-Raum ueber bis zu
  # trainable_count Positionen) - Fix vom 18.08. aus dem Hauptzweig, siehe
  # clipfix_20260818_fuer_forks.patch. Der Adam-Skalierer bleibt bewusst das
  # ROHE trainable_count (keine doppelte Normalisierung); max(1.0, ...) ist
  # nur Division-durch-Null-Schutz an der Schwelle.
  # Gemessen 2026-10-30 (Messbuch snai/gradclip-knirps-kurz und
  # snai/gradclip-knirps-lr3): die Schwelle (1.0 im
  # Mittelwert-Raum) greift am Knirps 128x4 (int8 voll, SR) fast immer, nach
  # dem Warmup bei LR 1e-3 in 100 %, bei LR 3e-3 in 52-61 % der Schritte. Das
  # bremst nicht: Schwelle 5 und ganz ohne Clip lagen nach 9.002 Schritten
  # (je 3 Saaten, gepaart) im Gleichstand (|d| <= 2,5 %), der Clip in 23 von
  # 24 Paaren knapp vorn. Schwelle also so lassen. NICHT gemessen: lange
  # Laeufe, prod512b (1.024 Token/Schritt, LR 1e-4), der Float-Pfad in
  # cortex_train_step. Das Stellrad SNAI_CLIP_SCHWELLE gab es nur in der
  # Messkopie (patch_clip.py), nicht hier.
  let clip_norm = max(1.0'f32, trainable_count.cfloat)
  zeitMiss(ZA_CLIP):
    clipGlobalGradientNorm(state, clip_norm)
  # last_grad_norm haelt nach clipGlobalGradientNorm() die Norm im
  # SUMMEN-Raum - hier auf den Mittelwert-Raum umgerechnet, damit der
  # geloggte Wert direkt gegen 1.0 lesbar ist. Werte vor 2026-08-28 in
  # Altlogs sind Summen-Normen, also grob um trainable_count groesser.
  last_grad_norm = last_grad_norm / clip_norm
  zeitMiss(ZA_ADAM):
    gdPrep(state)
    applyGlobalAdamUpdateI8(state, lr, trainable_count.cfloat)
  # PHASE 8: der gebuendelte Pfad hat Loss und trainable_count selbst ermittelt
  # (die aeusseren Zaehler bleiben dort unberuehrt bei 0).
  if usedBatched: return batchedLoss
  return total_loss / max(1, trainable_count).cfloat

proc cortex_train_step_i8*(state: ptr CortexState, raw_in: ptr cint, raw_tg: ptr cint, raw_mask: ptr cint, num_tok: cint, lr: cfloat): cfloat {.ffi.} =
  zeitMiss(ZA_GES):
    result = cortexTrainStepI8Roh(state, raw_in, raw_tg, raw_mask, num_tok, lr)
  zeitZeile()

proc satPct(qm: QMatrix): cfloat =
  var n = 0
  let total = qm.rows.int * qm.cols.int
  for i in 0 ..< total:
    if qm.data[i] >= 126 or qm.data[i] <= -127: inc n
  (n.cfloat / total.cfloat) * 100.0

proc cortex_debug_sat*(s: ptr CortexState, which: cint): cfloat {.ffi.} =
  ## Diagnose-Werkzeug (entstanden aus dem Go/No-Go-Gate-Befund in Phase 2,
  ## siehe diagnose/gate_int8_vs_fp32.php) - Anteil (%) der INT8-Werte einer
  ## Zeile/eines Tensors nahe der Saettigungsgrenze (>=126 oder <=-127).
  ## which: 0=embeddings 1=w_out 2=w_q[0] 3=w_up[0] 4=w_down[0].
  case which
  of 0: satPct(s.embeddings_q8)
  of 1: satPct(s.w_out_q8)
  of 2: satPct(s.w_q_q8[0])
  of 3: satPct(s.w_up_q8[0])
  of 4: satPct(s.w_down_q8[0])
  else: -1.0

proc gainNichtEndlich(p: ptr FloatArray, n: int): bool =
  ## Vollscan: ein einziger NaN/Inf-Gain legt das Training still, ohne dass der
  ## Loss nichtendlich wird (messbuch snai/nan-gains). deadTailStart sieht NaN nicht.
  if p.isNil: return false
  for i in 0 ..< n:
    let x = p[i]
    if x.isNaN or x > 1e30 or x < -1e30: return true
  return false

proc gainsNichtEndlich(s: ptr CortexState): bool =
  let n = s.hiddenDim.int
  if gainNichtEndlich(s.rms_final_weight, n): return true
  for l in 0 ..< s.numLayers:
    if gainNichtEndlich(s.rms_att_weights[l], n) or
       gainNichtEndlich(s.rms_ffn_weights[l], n): return true
  return false

proc validateQMatrix(qm: QMatrix): cint =
  ## Bit 1: nicht-endliche/nicht-positive Zeilen-Skala. Ergaenzt
  ## cortex_validate() (dort FP32-Felder) um die INT8-Q8-Felder - siehe
  ## cortex_validate_i8() unten.
  result = 0
  for r in 0 ..< qm.rows.int:
    let s = qm.scale[r]
    if s.isNaN or s <= 0.0 or s > 1e30:
      result = result or 1

proc cortex_validate_i8*(s: ptr CortexState): cint {.ffi.} =
  ## INT8-Pendant zu cortex_validate() (Plan Phase 2, Verifikation). Bit 1:
  ## nicht-endliche/nicht-positive Zeilen-Skala irgendwo. Bit 2: NaN/Inf in
  ## einem Gain. Bit 8: Aufruf auf einem Nicht-INT8-State (weightDtype != 1).
  if s.isNil: return -1
  if s.weightDtype != 1: return 8
  var flags: cint = 0
  flags = flags or validateQMatrix(s.embeddings_q8)
  flags = flags or validateQMatrix(s.w_out_q8)
  for l in 0 ..< s.numLayers:
    flags = flags or validateQMatrix(s.w_q_q8[l])
    flags = flags or validateQMatrix(s.w_k_q8[l])
    flags = flags or validateQMatrix(s.w_v_q8[l])
    flags = flags or validateQMatrix(s.w_o_q8[l])
    flags = flags or validateQMatrix(s.w_up_q8[l])
    flags = flags or validateQMatrix(s.w_down_q8[l])
  if gainsNichtEndlich(s): flags = flags or 2
  return flags

# ==============================================================================
# PHASE 3 DES INT8-UMBAUS
# OpenCL-Kernel-Verifikation: baut synthetische INT8-Daten, rechnet einmal CPU
# (matVecMulI8/adamStepI8 aus Phase 2, unveraendert) und einmal GPU
# (ocl_matVecMulI8/ocl_adamStepI8 aus cortex_opencl.nim) und vergleicht.
# Bewusst NICHT in cortex_train_step_i8/die zentrale gpuMatVecMul-artige
# Dispatch-Schicht verdrahtet - das ist volle Trainings-Loop-Integration
# (Phase 5), hier geht es nur um den Korrektheitsnachweis der Kernel selbst.
# ==============================================================================

proc cortex_verify_ocl_i8*(mode: cint): cfloat {.ffi.} =
  ## mode 0: INT8-GEMM (matVecMulI8 vs. ocl_matVecMulI8).
  ## mode 1: Rounded-Integer-Step Adam (adamStepI8 vs. ocl_adamStepI8).
  ## Rueckgabe: groesster absoluter Unterschied. -1.0 wenn kein
  ## OpenCL-Geraet initialisierbar ist (z.B. auf einer NVIDIA-only-Maschine).
  if not gpu_initialized:
    if init_opencl_engine() != 1: return -1.0
    gpu_initialized = true
    gpu_backend = gbOpenCL

  var rng = initRand(1234)
  let rows = 17.cint
  let cols = 23.cint

  if mode == 0:
    var m = allocQMatrix(rows, cols)
    for r in 0 ..< rows.int:
      var raw: array[64, cfloat]
      var maxAbs: cfloat = 0.0
      for c in 0 ..< cols.int:
        raw[c] = (rng.rand(2.0) - 1.0).cfloat
        if abs(raw[c]) > maxAbs: maxAbs = abs(raw[c])
      let scale = if maxAbs > 0.0: maxAbs / 127.0 else: 1.0
      m.scale[r] = scale
      let off = r * cols.int
      for c in 0 ..< cols.int:
        var q = round(raw[c] / scale).int
        if q > 127: q = 127
        elif q < -128: q = -128
        m.data[off + c] = q.int8

    var actF: array[64, cfloat]
    for c in 0 ..< cols.int: actF[c] = (rng.rand(2.0) - 1.0).cfloat
    var scratch: array[64, int8]
    var cpuOut: array[64, cfloat]
    matVecMulI8(m, cast[ptr FloatArray](addr actF[0]), cast[ptr FloatArray](addr cpuOut[0]), cast[ptr Int8Array](addr scratch[0]))

    var actI8: array[64, int8]
    let actScale = quantizeActivation(cast[ptr FloatArray](addr actF[0]), cast[ptr Int8Array](addr actI8[0]), cols)
    var gpuOut: array[64, cfloat]
    ocl_matVecMulI8(cast[ptr int8](m.data), cast[ptr cfloat](m.scale), cast[ptr int8](addr actI8[0]), actScale, cast[ptr cfloat](addr gpuOut[0]), rows, cols)

    var maxDiff: cfloat = 0.0
    for r in 0 ..< rows.int:
      let d = abs(cpuOut[r] - gpuOut[r])
      if d > maxDiff: maxDiff = d
    freeQMatrix(m)
    return maxDiff
  else:
    let n = (rows * cols).int
    var wCpu = newSeq[int8](n)
    var wGpu = newSeq[int8](n)
    var scaleArr = newSeq[cfloat](rows.int)
    var mCpu = newSeq[cfloat](n)
    var vCpu = newSeq[cfloat](n)
    var gCpu = newSeq[cfloat](n)
    for r in 0 ..< rows.int: scaleArr[r] = (0.001 + rng.rand(0.01)).cfloat
    for i in 0 ..< n:
      let w0 = (rng.rand(254) - 127).int8
      wCpu[i] = w0
      wGpu[i] = w0
      mCpu[i] = (rng.rand(0.02) - 0.01).cfloat
      vCpu[i] = rng.rand(0.0001).cfloat
      gCpu[i] = (rng.rand(0.02) - 0.01).cfloat
    var mGpu = mCpu
    var vGpu = vCpu
    var gGpu = gCpu

    let lr = 0.01.cfloat
    let b1 = 0.9.cfloat
    let b2 = 0.999.cfloat
    let b1t = 0.1.cfloat
    let b2t = 0.001.cfloat
    let gradScale = 1.0.cfloat

    for r in 0 ..< rows.int:
      let qscale = scaleArr[r]
      let off = r * cols.int
      for c in 0 ..< cols.int:
        let i = off + c
        adamStepI8(addr wCpu[i], qscale, addr mCpu[i], addr vCpu[i], addr gCpu[i], lr, b1, b2, b1t, b2t, gradScale, false, 1.0, 0.0)

    ocl_adamStepI8(addr wGpu[0], cast[ptr cfloat](addr scaleArr[0]), cast[ptr cfloat](addr mGpu[0]), cast[ptr cfloat](addr vGpu[0]), cast[ptr cfloat](addr gGpu[0]), lr, b1, b2, b1t, b2t, gradScale, n.cint, 0.cint, cols, rows, cols, 1.0, 0.0)

    var maxDiff: cfloat = 0.0
    for i in 0 ..< n:
      let d = abs(wCpu[i].cfloat - wGpu[i].cfloat)
      if d > maxDiff: maxDiff = d
    return maxDiff

proc cortex_verify_ocl_row_i8*(useFb: cint): cfloat {.ffi.} =
  ## PHASE 10: Float-Adam je Zeile MIT/OHNE Fehler-Rueckfuehrung -
  ## adamRowFloatI8() (CPU) gegen ocl_adamRowFloatI8() (GPU).
  ## Verglichen wird der REALWERT (q * Zeilenskala), nicht das rohe q: die
  ## Skala wird vom Kernel selbst neu gesetzt, ein Vergleich der Integer
  ## allein waere daher bedeutungslos.
  ## Rueckgabe: groesste absolute Realwert-Differenz, -1.0 ohne OpenCL-Geraet.
  if not gpu_initialized:
    if init_opencl_engine() != 1: return -1.0
    gpu_initialized = true
    gpu_backend = gbOpenCL

  var rng = initRand(4242)
  let rows = 17.cint
  let cols = 23.cint
  let n = (rows * cols).int

  var qCpu = allocQMatrix(rows, cols)
  var qGpuData = newSeq[int8](n)
  var qGpuScale = newSeq[cfloat](rows.int)
  var mCpu = newSeq[cfloat](n)
  var vCpu = newSeq[cfloat](n)
  var gCpu = newSeq[cfloat](n)
  var rCpu = newSeq[cfloat](n)
  for r in 0 ..< rows.int:
    let sc = (0.001 + rng.rand(0.01)).cfloat
    qCpu.scale[r] = sc
    qGpuScale[r] = sc
  for i in 0 ..< n:
    let w0 = (rng.rand(254) - 127).int8
    qCpu.data[i] = w0
    qGpuData[i] = w0
    mCpu[i] = (rng.rand(0.02) - 0.01).cfloat
    vCpu[i] = rng.rand(0.0001).cfloat
    gCpu[i] = (rng.rand(0.02) - 0.01).cfloat
    rCpu[i] = (rng.rand(0.0002) - 0.0001).cfloat
  var mGpu = mCpu
  var vGpu = vCpu
  var gGpu = gCpu
  var rGpu = rCpu

  let lr = 0.01.cfloat
  let b1 = 0.9.cfloat
  let b2 = 0.999.cfloat
  let b1t = 0.1.cfloat
  let b2t = 0.001.cfloat
  let gradScale = 1.0.cfloat

  # Der CPU-Pfad liest den Schalter aus der globalen Variablen - fuer die Dauer
  # des Vergleichs auf den gewuenschten Wert setzen und danach zuruecksetzen.
  let savedFb = i8_error_feedback
  i8_error_feedback = useFb
  var resM_cpu: Matrix
  resM_cpu.rows = rows
  resM_cpu.cols = cols
  resM_cpu.data = cast[ptr FloatArray](addr rCpu[0])
  for r in 0 ..< rows.int:
    adamRowFloatI8(qCpu, Matrix(rows: rows, cols: cols, data: cast[ptr FloatArray](addr mCpu[0])),
                   Matrix(rows: rows, cols: cols, data: cast[ptr FloatArray](addr vCpu[0])),
                   Matrix(rows: rows, cols: cols, data: cast[ptr FloatArray](addr gCpu[0])),
                   resM_cpu, r, lr, b1, b2, b1t, b2t, gradScale, false, rows, cols, 0.0)
  i8_error_feedback = savedFb

  # FALLE (2026-08-20 erlebt): der OpenCL-Puffer-Cache ist ueber den HOST-ZEIGER
  # indiziert. Nim kann eine gerade freigegebene Adresse wiederverwenden - dann
  # liefert ocl_get_buffer() einen VERALTETEN Geraetepuffer und der Vergleich
  # misst Muell statt des Kernels (hier zunaechst als "Differenz 2,3" erschienen,
  # obwohl der Kernel exakt rechnete). Deshalb die Zuordnung fuer alle hier
  # benutzten Adressen vorsorglich loesen.
  ocl_release_buffer(cast[pointer](addr qGpuData[0]))
  ocl_release_buffer(cast[pointer](addr qGpuScale[0]))
  ocl_release_buffer(cast[pointer](addr mGpu[0]))
  ocl_release_buffer(cast[pointer](addr vGpu[0]))
  ocl_release_buffer(cast[pointer](addr gGpu[0]))
  ocl_release_buffer(cast[pointer](addr rGpu[0]))

  ocl_adamRowFloatI8(addr qGpuData[0], cast[ptr cfloat](addr qGpuScale[0]),
                     cast[ptr cfloat](addr mGpu[0]), cast[ptr cfloat](addr vGpu[0]),
                     cast[ptr cfloat](addr gGpu[0]), cast[ptr cfloat](addr rGpu[0]),
                     lr, b1, b2, b1t, b2t, gradScale, rows, cols, 0.cint,
                     rows, cols, 1.0, 0.0, useFb)

  var maxDiff: cfloat = 0.0
  for r in 0 ..< rows.int:
    for c in 0 ..< cols.int:
      let i = r * cols.int + c
      let a = qCpu.data[i].cfloat * qCpu.scale[r]
      let b = qGpuData[i].cfloat * qGpuScale[r]
      let d = abs(a - b)
      if d > maxDiff: maxDiff = d
  freeQMatrix(qCpu)
  return maxDiff

# ================================================================
# FFI EXPORTS
# ===============================================================

# AUDIT-FIX: ffn Parameter explizit aufnehmen (verhindert Heap-Buffer-Overflow)
# SPEICHER-AUDIT 2026-08-19: Schalter fuer cortex_init(). Default false =
# bisheriges Verhalten (FP32-Pfad unveraendert). Werden ausschliesslich von
# cortex_load_stream_i8() gesetzt und dort sofort wieder zurueckgesetzt.
var init_skip_fp32_weights = false
var init_skip_adam_state = false
var init_skip_fp32_kv = false        # FP32-k_cache/v_cache (im INT8-Pfad tot)
var init_skip_backward_buffers = false  # Aktivierungshistorie/d_*/logits_cache (nur Training)


proc cortex_init*(vocab, dim, ffn, ctx, layers, heads: cint): ptr CortexState {.ffi.} =
  var s = cast[ptr CortexState](allocShared0(sizeof(CortexState)))
  s.vocabSize = vocab
  s.hiddenDim = dim
  s.ffnDim = ffn
  s.ctxSize = ctx
  s.numLayers = layers
  
  s.numHeads = max(1, min(heads, dim)) 
  s.headSize = dim div s.numHeads
  if (s.headSize mod 2) != 0: s.headSize -= 1 
  if s.headSize < 2: s.headSize = 2
  s.numHeads = dim div s.headSize
  
  s.cachedTokens = 0
  s.adam_t = 0
  # SCHRITT 3: festhalten, ob dieser State quantisierte Momente hat. Muss im
  # State stehen (nicht global), weil mehrere States mit unterschiedlicher
  # Konfiguration gleichzeitig leben koennen - die Testskripte tun genau das.
  s.quantAdam = (if init_quant_adam and not init_skip_adam_state: 1 else: 0)
  s.quantActs = (if init_quant_acts and not init_skip_backward_buffers: 1 else: 0)
  s.quantActsIn = (if init_quant_acts_in and not init_skip_backward_buffers: 1 else: 0)
  
  template initM(m, r, c) =
    m = allocMatrix(r, c)
  template initA(a, size) =
    a = cast[ptr FloatArray](allocShared0(cast[int](size.uint64 * sizeof(cfloat).uint64)))

  # SPEICHER-AUDIT 2026-08-19 (siehe Kommentarblock bei freeFp32WeightShadows):
  # initMW/initMA/initAA sind Varianten von initM/initA, die die Allokation
  # ueberspringen koennen. Nachtraegliches deallocShared() reicht NICHT - der
  # Allokator behaelt die Arena, der Spitzenverbrauch bleibt (gemessen: 21 MB
  # vor wie nach dem Freigeben). Nur gar nicht erst zu allozieren senkt ihn.
  # Beide Flags stehen per Default auf false -> der FP32-Pfad allokiert exakt
  # wie bisher, cortex_load_stream_i8() setzt sie gezielt fuer sich.
  # Uebersprungene Matrizen behalten rows/cols (gradBytes() u.a. lesen die),
  # nur data bleibt nil - alle Zugriffspfade sind nil-geprueft.
  template initMW(m, r, c) =
    if init_skip_fp32_weights:
      m.rows = r.cint; m.cols = c.cint; m.data = nil
    else: m = allocMatrix(r, c)
  template initMA(m, r, c) =
    if init_skip_adam_state:
      m.rows = r.cint; m.cols = c.cint; m.data = nil
    else: m = allocMatrix(r, c)
  # SCHRITT 3: quantisiertes Moment-Paar. Legt bei aktivem Flag NUR die
  # 8-Bit-Fassung an und laesst die float32-Matrix leer (rows/cols bleiben
  # gesetzt, weil diverse Stellen sie lesen - Zugriffe sind nil-geprueft).
  template initMQ(mf, mq, r, c) =
    if init_skip_adam_state:
      mf.rows = r.cint; mf.cols = c.cint; mf.data = nil
    elif init_quant_adam:
      mf.rows = r.cint; mf.cols = c.cint; mf.data = nil
      mq = allocQMoment(r.cint, c.cint)
    else: mf = allocMatrix(r, c)
  template initAA(a, size) =
    if init_skip_adam_state: a = nil
    else: a = cast[ptr FloatArray](allocShared0(cast[int](size.uint64 * sizeof(cfloat).uint64)))

  # SPEICHER-AUDIT 2026-08-19, zweite Runde (Goddess-Hochrechnung): bei
  # ctx=8192/32 Layern sind die Caches der GROESSTE Posten ueberhaupt (91 GB),
  # groesser als Gewichte und Adam-Zustand zusammen. Zwei Gruppen davon sind
  # im jeweiligen Modus nachweislich tot (per Skript gegen den Rumpf von
  # cortex_forward_i8() geprueft, nicht geschaetzt):
  #   initMKV  - FP32-k_cache/v_cache: der INT8-Pfad nutzt ausschliesslich
  #              k_cache_q8/v_cache_q8, die FP32-Zwillinge liest er nie.
  #   initMB/initAB/initHistB - reine Backward-/Trainings-Puffer
  #              (Aktivierungshistorie, d_*-Gradienten, logits_cache,
  #              mm_*-Scratch). Ein Inferenz-Artefakt braucht davon nichts.
  # Beide Gruppen bleiben fuer den FP32-Pfad und fuer INT8-TRAINING vollstaendig
  # erhalten - nur ein Artefakt ohne Adam-Zustand (= per Definition Inferenz,
  # siehe export_int8_deployment()) laesst die Backward-Gruppe weg.
  template initMKV(m, r, c) =
    if init_skip_fp32_kv:
      m.rows = r.cint; m.cols = c.cint; m.data = nil
    else: m = allocMatrix(r, c)
  template initMB(m, r, c) =
    if init_skip_backward_buffers:
      m.rows = r.cint; m.cols = c.cint; m.data = nil
    else: m = allocMatrix(r, c)
  template initAB(a, size) =
    if init_skip_backward_buffers: a = nil
    else: a = cast[ptr FloatArray](allocShared0(cast[int](size.uint64 * sizeof(cfloat).uint64)))
  # Wie initHist, laesst aber die (grossen) Pro-Layer-Puffer weg. Das
  # Zeigerarray selbst wird IMMER angelegt: freeHist() laeuft darueber und
  # deallocShared()t es, und ein versehentlicher Zugriff trifft dann nil statt
  # Speichermuell.
  template initHistB(p, l, size) =
    p = cast[ptr FloatPtrArray](allocShared0(cast[int](l.uint64 * sizeof(pointer).uint64)))
    if not init_skip_backward_buffers:
      for i in 0 ..< l:
        p[i] = cast[ptr FloatArray](allocShared0(cast[int](size.uint64 * sizeof(cfloat).uint64)))
  # SCHRITT 4a: Bitmasken-Variante von initHistB - ein Bit je Element statt
  # eines float32, also ceil(size/8) Bytes je Layer.
  template initBitB(p, l, size) =
    p = cast[ptr Uint8PtrArray](allocShared0(cast[int](l.uint64 * sizeof(pointer).uint64)))
    if not init_skip_backward_buffers:
      for i in 0 ..< l:
        p[i] = cast[ptr Uint8Array](allocShared0(cast[int](((size.uint64 + 7'u64) div 8'u64))))
  template initP(p, l, T) = 
    p = cast[T](allocShared0(cast[int](l.uint64 * sizeof(p[0]).uint64)))
  template initHist(p, l, size) = 
    p = cast[ptr FloatPtrArray](allocShared0(cast[int](l.uint64 * sizeof(pointer).uint64)))
    for i in 0 ..< l: 
      p[i] = cast[ptr FloatArray](allocShared0(cast[int](size.uint64 * sizeof(cfloat).uint64)))

  initMW(s.embeddings, vocab, dim)
  initMQ(s.m_embeddings, s.mq_embeddings, vocab, dim)
  initMQ(s.v_embeddings, s.vq_embeddings, vocab, dim)
  initMA(s.g_embeddings, vocab, dim)
  
  initMW(s.w_out, vocab, dim)
  initMQ(s.m_w_out, s.mq_w_out, vocab, dim)
  initMQ(s.v_w_out, s.vq_w_out, vocab, dim)
  initMA(s.g_w_out, vocab, dim)
  
  initA(s.rms_final_weight, dim)
  initAA(s.m_rms_final_weight, dim)
  initAA(s.v_rms_final_weight, dim)
  initAA(s.g_rms_final_weight, dim)

  initP(s.rms_att_weights, layers, ptr FloatPtrArray)
  initP(s.m_rms_att_weights, layers, ptr FloatPtrArray)
  initP(s.v_rms_att_weights, layers, ptr FloatPtrArray)
  initP(s.g_rms_att_weights, layers, ptr FloatPtrArray)
  
  initP(s.rms_ffn_weights, layers, ptr FloatPtrArray)
  initP(s.m_rms_ffn_weights, layers, ptr FloatPtrArray)
  initP(s.v_rms_ffn_weights, layers, ptr FloatPtrArray)
  initP(s.g_rms_ffn_weights, layers, ptr FloatPtrArray)
  
  initP(s.w_q, layers, ptr MatrixArray)
  initP(s.m_w_q, layers, ptr MatrixArray)
  initP(s.v_w_q, layers, ptr MatrixArray)
  if init_quant_adam and not init_skip_adam_state:
    initP(s.mq_w_q, layers, ptr QMomentArray)
    initP(s.vq_w_q, layers, ptr QMomentArray)
  initP(s.g_w_q, layers, ptr MatrixArray)
  
  initP(s.w_k, layers, ptr MatrixArray)
  initP(s.m_w_k, layers, ptr MatrixArray)
  initP(s.v_w_k, layers, ptr MatrixArray)
  if init_quant_adam and not init_skip_adam_state:
    initP(s.mq_w_k, layers, ptr QMomentArray)
    initP(s.vq_w_k, layers, ptr QMomentArray)
  initP(s.g_w_k, layers, ptr MatrixArray)
  
  initP(s.w_v, layers, ptr MatrixArray)
  initP(s.m_w_v, layers, ptr MatrixArray)
  initP(s.v_w_v, layers, ptr MatrixArray)
  if init_quant_adam and not init_skip_adam_state:
    initP(s.mq_w_v, layers, ptr QMomentArray)
    initP(s.vq_w_v, layers, ptr QMomentArray)
  initP(s.g_w_v, layers, ptr MatrixArray)
  
  initP(s.w_o, layers, ptr MatrixArray)
  initP(s.m_w_o, layers, ptr MatrixArray)
  initP(s.v_w_o, layers, ptr MatrixArray)
  if init_quant_adam and not init_skip_adam_state:
    initP(s.mq_w_o, layers, ptr QMomentArray)
    initP(s.vq_w_o, layers, ptr QMomentArray)
  initP(s.g_w_o, layers, ptr MatrixArray)
  
  initP(s.w_up, layers, ptr MatrixArray)
  initP(s.m_w_up, layers, ptr MatrixArray)
  initP(s.v_w_up, layers, ptr MatrixArray)
  if init_quant_adam and not init_skip_adam_state:
    initP(s.mq_w_up, layers, ptr QMomentArray)
    initP(s.vq_w_up, layers, ptr QMomentArray)
  initP(s.g_w_up, layers, ptr MatrixArray)
  
  initP(s.w_down, layers, ptr MatrixArray)
  initP(s.m_w_down, layers, ptr MatrixArray)
  initP(s.v_w_down, layers, ptr MatrixArray)
  if init_quant_adam and not init_skip_adam_state:
    initP(s.mq_w_down, layers, ptr QMomentArray)
    initP(s.vq_w_down, layers, ptr QMomentArray)
  initP(s.g_w_down, layers, ptr MatrixArray)
  
  initP(s.k_cache, layers, ptr MatrixArray)
  initP(s.v_cache, layers, ptr MatrixArray)
  initP(s.act_q, layers, ptr MatrixArray)
  
  initP(s.d_k_cache, layers, ptr MatrixArray)
  initP(s.d_v_cache, layers, ptr MatrixArray)

  for l in 0 ..< layers:
    initA(s.rms_att_weights[l], dim)
    initAA(s.m_rms_att_weights[l], dim)
    initAA(s.v_rms_att_weights[l], dim)
    initAA(s.g_rms_att_weights[l], dim)
    
    initA(s.rms_ffn_weights[l], dim)
    initAA(s.m_rms_ffn_weights[l], dim)
    initAA(s.v_rms_ffn_weights[l], dim)
    initAA(s.g_rms_ffn_weights[l], dim)
    
    initMW(s.w_q[l], dim, dim)
    initMQ(s.m_w_q[l], s.mq_w_q[l], dim, dim)
    initMQ(s.v_w_q[l], s.vq_w_q[l], dim, dim)
    initMA(s.g_w_q[l], dim, dim)
    
    initMW(s.w_k[l], dim, dim)
    initMQ(s.m_w_k[l], s.mq_w_k[l], dim, dim)
    initMQ(s.v_w_k[l], s.vq_w_k[l], dim, dim)
    initMA(s.g_w_k[l], dim, dim)
    
    initMW(s.w_v[l], dim, dim)
    initMQ(s.m_w_v[l], s.mq_w_v[l], dim, dim)
    initMQ(s.v_w_v[l], s.vq_w_v[l], dim, dim)
    initMA(s.g_w_v[l], dim, dim)
    
    initMW(s.w_o[l], dim, dim)
    initMQ(s.m_w_o[l], s.mq_w_o[l], dim, dim)
    initMQ(s.v_w_o[l], s.vq_w_o[l], dim, dim)
    initMA(s.g_w_o[l], dim, dim)
    
    initMW(s.w_up[l], s.ffnDim, dim)
    initMQ(s.m_w_up[l], s.mq_w_up[l], s.ffnDim, dim)
    initMQ(s.v_w_up[l], s.vq_w_up[l], s.ffnDim, dim)
    initMA(s.g_w_up[l], s.ffnDim, dim)
    
    initMW(s.w_down[l], dim, s.ffnDim)
    initMQ(s.m_w_down[l], s.mq_w_down[l], dim, s.ffnDim)
    initMQ(s.v_w_down[l], s.vq_w_down[l], dim, s.ffnDim)
    initMA(s.g_w_down[l], dim, s.ffnDim)
    
    initMKV(s.k_cache[l], ctx, dim)
    initMKV(s.v_cache[l], ctx, dim)
    initMB(s.act_q[l], ctx, dim)
    
    initMB(s.d_k_cache[l], ctx, dim)
    initMB(s.d_v_cache[l], ctx, dim)
    
    for i in 0 ..< dim: 
      s.rms_att_weights[l][i] = 1.0
      s.rms_ffn_weights[l][i] = 1.0

  for i in 0 ..< dim: 
    s.rms_final_weight[i] = 1.0
    
  initMB(s.logits_cache, ctx, vocab)

  let ctxDim = ctx.int * dim.int
  let ctxFfn = ctx.int * s.ffnDim.int

  initHistB(s.act_hidden, layers, ctxDim)
  initHistB(s.act_norm_att, layers, ctxDim)
  initHistB(s.act_att_out, layers, ctxDim)
  initHistB(s.act_hidden_ffn, layers, ctxDim)
  initHistB(s.act_norm_ffn, layers, ctxDim)
  # SCHRITT 4b/4c: entweder float-Historie ODER int8 + gemeinsamer Scratch.
  if s.quantActsIn != 0:
    # act_ffn_in: float-Historie durch int8 ersetzen. Der Scratch aus 4b wird
    # mitbenutzt - im Forward nacheinander (GEMM-Ausgabe, dann SiLU in-place),
    # deshalb genuegt EIN Puffer fuer beide Zwecke.
    s.act_ffn_in = cast[ptr FloatPtrArray](allocShared0(cast[int](layers.uint64 * sizeof(pointer).uint64)))
    s.act_ffn_in_q8 = cast[ptr QMatrixArray](allocShared0(layers.int * sizeof(QMatrix)))
    for l in 0 ..< layers.int:
      s.act_ffn_in_q8[l] = allocQMatrix(ctx, ffn)
    s.silu_lut = cast[ptr FloatArray](allocShared0(256 * sizeof(cfloat)))
    s.silu_exp = cast[ptr FloatPtrArray](allocShared0(cast[int](layers.uint64 * sizeof(pointer).uint64)))
    for l in 0 ..< layers.int:
      s.silu_exp[l] = cast[ptr FloatArray](allocShared0(ctx.int * 256 * sizeof(cfloat)))
    s.silu_exp_ok = cast[ptr UncheckedArray[cint]](allocShared0(layers.int * sizeof(cint)))
  else:
    initHistB(s.act_ffn_in, layers, ctxFfn)
  if s.quantActs != 0:
    s.act_ffn_out = cast[ptr FloatPtrArray](allocShared0(cast[int](layers.uint64 * sizeof(pointer).uint64)))
    s.act_ffn_out_q8 = cast[ptr QMatrixArray](allocShared0(layers.int * sizeof(QMatrix)))
    for l in 0 ..< layers.int:
      s.act_ffn_out_q8[l] = allocQMatrix(ctx, ffn)
    s.act_ffn_scratch = cast[ptr FloatArray](allocShared0(cast[int](ctxFfn.uint64 * sizeof(cfloat).uint64)))
  else:
    initHistB(s.act_ffn_out, layers, ctxFfn)
  initBitB(s.dropout_mask, layers, ctxFfn)

  initHist(s.j_space_cache, layers, dim)
  
  initAB(s.act_hidden_final, ctxDim)
  initAB(s.act_norm_final, ctxDim)
  initAB(s.d_norm_all, ctxDim)
  initAB(s.d_hidden_all, ctxDim)
  initAB(s.d_att_out_all, ctxDim)
  initAB(s.d_q_all, ctxDim)
  initAB(s.mm_hd_scratch, ctxDim)
  initAB(s.mm_ffn_scratch, ctxFfn)

  initA(s.hidden_state_buf, dim)
  initA(s.norm_buf, dim)
  initA(s.att_out_buf, dim)
  initA(s.ffn_buf, s.ffnDim)
  initA(s.q_buf, dim)
  
  initA(s.d_logits_buf, vocab)
  initA(s.scores_buf, ctx)
  initA(s.d_w_buf, ctx)
  
  initA(s.d_hidden, dim)
  initA(s.d_norm, dim)
  initA(s.d_att_out, dim)
  initA(s.d_q, dim)
  initA(s.d_ffn, s.ffnDim)
  
  return s

proc getExpectedSize(s: ptr CortexState, t: cint): cint {.inline.} =
  case t:
  of 0, 1: return s.vocabSize * s.hiddenDim
  of 2, 10, 11: return s.hiddenDim
  of 12, 13, 14, 15: return s.hiddenDim * s.hiddenDim
  of 16, 17: return s.ffnDim * s.hiddenDim
  else: return 0

proc getTensorPtr(s: ptr CortexState, l: cint, t: cint, m: bool = false, v: bool = false): ptr cfloat =
  if l >= s.numLayers or l < -1: return nil
  if l == -1:
    if t == 0: return if m: cast[ptr cfloat](s.m_embeddings.data) elif v: cast[ptr cfloat](s.v_embeddings.data) else: cast[ptr cfloat](s.embeddings.data)
    # SNAI_V7: bei Bindung IST w_out die Embedding-Matrix - also auch hier
    # darauf zeigen. Ohne diese Umleitung liefe jeder Aufrufer, der Typ 1
    # anfragt, in die freigegebenen (nil) w_out-Felder; die Aufrufer sind zwar
    # nil-sicher, wuerden dann aber still NULLEN zurueckgeben statt der
    # richtigen Werte - eine leise falsche Antwort ist hier schlimmer als eine
    # laute Fehlende.
    if t == 1 and s.tiedEmbeddings != 0:
      return if m: cast[ptr cfloat](s.m_embeddings.data) elif v: cast[ptr cfloat](s.v_embeddings.data) else: cast[ptr cfloat](s.embeddings.data)
    if t == 1: return if m: cast[ptr cfloat](s.m_w_out.data) elif v: cast[ptr cfloat](s.v_w_out.data) else: cast[ptr cfloat](s.w_out.data)
    if t == 2: return if m: cast[ptr cfloat](s.m_rms_final_weight) elif v: cast[ptr cfloat](s.v_rms_final_weight) else: cast[ptr cfloat](s.rms_final_weight)
  else:
    if t == 10: return if m: cast[ptr cfloat](s.m_rms_att_weights[l]) elif v: cast[ptr cfloat](s.v_rms_att_weights[l]) else: cast[ptr cfloat](s.rms_att_weights[l])
    if t == 11: return if m: cast[ptr cfloat](s.m_rms_ffn_weights[l]) elif v: cast[ptr cfloat](s.v_rms_ffn_weights[l]) else: cast[ptr cfloat](s.rms_ffn_weights[l])
    if t == 12: return if m: cast[ptr cfloat](s.m_w_q[l].data) elif v: cast[ptr cfloat](s.v_w_q[l].data) else: cast[ptr cfloat](s.w_q[l].data)
    if t == 13: return if m: cast[ptr cfloat](s.m_w_k[l].data) elif v: cast[ptr cfloat](s.v_w_k[l].data) else: cast[ptr cfloat](s.w_k[l].data)
    if t == 14: return if m: cast[ptr cfloat](s.m_w_v[l].data) elif v: cast[ptr cfloat](s.v_w_v[l].data) else: cast[ptr cfloat](s.w_v[l].data)
    if t == 15: return if m: cast[ptr cfloat](s.m_w_o[l].data) elif v: cast[ptr cfloat](s.v_w_o[l].data) else: cast[ptr cfloat](s.w_o[l].data)
    if t == 16: return if m: cast[ptr cfloat](s.m_w_up[l].data) elif v: cast[ptr cfloat](s.v_w_up[l].data) else: cast[ptr cfloat](s.w_up[l].data)
    if t == 17: return if m: cast[ptr cfloat](s.m_w_down[l].data) elif v: cast[ptr cfloat](s.v_w_down[l].data) else: cast[ptr cfloat](s.w_down[l].data)
  return nil

# ==============================================================================
# NET2NET GAIN GUARD (V11.3)
# ------------------------------------------------------------------------------
# Ein RMSNorm-Gain von 0 stummschaltet den Kanal: o_v[d] = i_v[d] * inv * 0 = 0,
# die nachgelagerten w_up-Spalten bekommen keinen Gradienten mehr. Die Gain selbst
# ist KEIN Sattelpunkt: gw[d] = d_out[d] * nx haengt nicht von der Gain ab
# (applyRMSNormBackwardAcc), und Training zieht Gains auch legitim gegen 0.
#
# Seit 2026-11-02 meldet der Waechter nur noch. Eine Korrektur beim Laden hat
# gemessene Modelle und Trainingsstaende an Segmentgrenzen still veraendert
# (Floatpaar-Reihe, 2.960 von 11.520 Messpunkten). Das Wachstum polstert Gains
# selbst mit 1.0 (Destille, upscale_tensor_triplet).
# Die alte Korrektur: SNAI_GAIN_GUARD=1, wirkt schon beim ersten Laden.
# ==============================================================================

var gain_guard_enabled: cint = -1   # -1 = Umgebung noch nicht gelesen

proc gainGuardAn(): bool =
  if gain_guard_enabled < 0:
    gain_guard_enabled = (if getEnv("SNAI_GAIN_GUARD") == "1": 1 else: 0)
  gain_guard_enabled != 0

proc cortex_set_gain_guard*(enabled: cint) {.ffi.} =
  gain_guard_enabled = enabled

# Sucht einen zusammenhaengenden toten Block AM ENDE eines Gain-Arrays.
# Nur dieses Muster ist die Expansions-Signatur - gestreute kleine Werte
# koennen legitim antrainiert sein und werden bewusst ignoriert.
proc deadTailStart(p: ptr FloatArray, n: cint): cint =
  if p.isNil or n < 8: return -1
  let eps: cfloat = 0.05
  if abs(p[n-1]) >= eps: return -1
  var i = n - 1
  while i >= 0 and abs(p[i]) < eps:
    dec i
  let start = i + 1
  if (n - start) * 8 < n: return -1   # kleiner als 1/8 der Breite -> kein Muster
  return start

proc checkGains(p: ptr cfloat, size: cint, what: string): bool {.discardable.} =
  let arr = cast[ptr FloatArray](p)
  let ds = deadTailStart(arr, size)
  if ds < 0: return false
  stderr.writeLine("[cortex] NET2NET-GUARD: ", what, " hat tote Kanaele [",
                   $ds, "..", $(size-1), "] von ", $size, ".")
  if gainGuardAn():
    for i in ds ..< size: arr[i] = 1.0
    stderr.writeLine("[cortex] NET2NET-GUARD: auf 1.0 korrigiert. ",
                     "Die Ursache gehoert trotzdem in den Morph-Code.")
  return true

proc cortex_load_layer*(s: ptr CortexState, layer_idx: cint, tensor_type: cint, raw_weights: ptr cfloat, size: cint) {.ffi.} =
  if size != getExpectedSize(s, tensor_type): return 
  let p = getTensorPtr(s, layer_idx, tensor_type)
  if p.isNil: return
  copyMem(p, raw_weights, size * sizeof(cfloat))

  # AEGIS: greift genau in dem Moment, in dem der Morph die Gewichte reinreicht.
  if tensor_type == 2 or tensor_type == 10 or tensor_type == 11:
    checkGains(p, size, "Gain-Tensor (type " & $tensor_type & ", layer " & $layer_idx & ")")

proc cortex_extract_layer*(s: ptr CortexState, layer_idx: cint, tensor_type: cint, raw_weights: ptr cfloat, size: cint) {.ffi.} =
  if size != getExpectedSize(s, tensor_type): return
  let p = getTensorPtr(s, layer_idx, tensor_type)
  if not p.isNil: copyMem(raw_weights, p, size * sizeof(cfloat))

# PHASE 5 DES INT8-UMBAUS
# cortex_extract_adam_layer() unten funktioniert UNVERAENDERT auch fuer
# weightDtype==1-States (m/v liegen immer in denselben FP32-Matrix-Feldern,
# Design-Entscheidung #2) - nur die GEWICHTE selbst brauchen einen neuen,
# int8-bewussten Extraktionspfad (Skala kommt als zweiter Puffer mit).
proc getQTensorPtr(s: ptr CortexState, l: cint, t: cint): ptr QMatrix =
  if s.weightDtype != 1: return nil
  if l >= s.numLayers or l < -1: return nil
  if l == -1:
    if t == 0: return addr s.embeddings_q8
    if t == 1: return addr s.w_out_q8
  else:
    if t == 12: return addr s.w_q_q8[l]
    if t == 13: return addr s.w_k_q8[l]
    if t == 14: return addr s.w_v_q8[l]
    if t == 15: return addr s.w_o_q8[l]
    if t == 16: return addr s.w_up_q8[l]
    if t == 17: return addr s.w_down_q8[l]
  return nil

proc cortex_extract_layer_i8*(s: ptr CortexState, layer_idx: cint, tensor_type: cint, raw_i8: ptr int8, raw_scale: ptr cfloat, size: cint) {.ffi.} =
  ## INT8-Pendant zu cortex_extract_layer(): extrahiert INT8-Daten + die
  ## Pro-Zeile-Skalen eines der 8 quantisierbaren Tensor-Typen. raw_scale muss
  ## vom Aufrufer mit `rows` Floats allokiert sein (nicht `size` - das ist
  ## rows*cols); rows ist PHP-seitig aus der Modell-Geometrie bekannt
  ## (snai_tensor_shape() in tensor_io.php).
  if s.isNil or s.weightDtype != 1: return
  if size != getExpectedSize(s, tensor_type): return
  let qp = getQTensorPtr(s, layer_idx, tensor_type)
  if qp.isNil: return
  copyMem(raw_i8, qp.data, size * sizeof(int8))
  copyMem(raw_scale, qp.scale, qp.rows.int * sizeof(cfloat))

proc getQMomentPtr(s: ptr CortexState, layer_idx, tensor_type: cint, is_v: bool): ptr QMoment =
  ## Liefert das quantisierte Moment, falls der Speicherumbau aktiv ist und
  ## dieser Tensortyp quantisiert wird (rms_* sind bewusst ausgenommen).
  if s.quantAdam == 0: return nil
  template pick(a, b): ptr QMoment = (if is_v: addr b else: addr a)
  template pickL(a, b): ptr QMoment =
    (if is_v:
       (if b.isNil: nil else: addr b[layer_idx])
     else:
       (if a.isNil: nil else: addr a[layer_idx]))
  case tensor_type
  of 0: pick(s.mq_embeddings, s.vq_embeddings)
  # SNAI_V7: bei Bindung existieren mq_w_out/vq_w_out nicht mehr - siehe
  # Begruendung in getTensorPtr().
  of 1: (if s.tiedEmbeddings != 0: pick(s.mq_embeddings, s.vq_embeddings)
         else: pick(s.mq_w_out, s.vq_w_out))
  of 12: pickL(s.mq_w_q, s.vq_w_q)
  of 13: pickL(s.mq_w_k, s.vq_w_k)
  of 14: pickL(s.mq_w_v, s.vq_w_v)
  of 15: pickL(s.mq_w_o, s.vq_w_o)
  of 16: pickL(s.mq_w_up, s.vq_w_up)
  of 17: pickL(s.mq_w_down, s.vq_w_down)
  else: nil

proc cortex_extract_adam_layer*(s: ptr CortexState, layer_idx: cint, tensor_type: cint, is_v: bool, raw: ptr cfloat, size: cint) {.ffi.} =
  if gaStale:
    gpuAdamSyncHost()
    stderr.writeLine("[GPU-ADAM] Momente zurueckgeholt, Aufrufe ", gaCalls, gaStats())
    if (attGpuFwdCalls > 0 or attGpuBwCalls > 0) and not pCudaAttStats.isNil:
      var st: array[4, cdouble]
      pCudaAttStats(addr st[0])
      stderr.writeLine("[ATT-GPU] Aufrufe vorwaerts ", attGpuFwdCalls, " (", int(st[0]), " ms), rueckwaerts ",
                       attGpuBwCalls, " (", int(st[1]), " ms)")
  if size != getExpectedSize(s, tensor_type): return
  # SCHRITT 3 (Speicherumbau): liegen die Momente quantisiert vor, wird hier
  # dequantisiert. Damit bleibt das DATEIFORMAT SNAI_V6 unveraendert - die
  # Serialisierung sieht weiterhin float32. Bewusste Entscheidung: der Gewinn
  # dieses Schritts ist der RAM waehrend des Trainings (bei Goddess ~36 GB),
  # nicht die Dateigroesse. Ein Formatwechsel haette Merge, Net2Net-Wachstum
  # und die Kompatibilitaet zum Vorgaenger-Fork mitgerissen.
  let qm = getQMomentPtr(s, layer_idx, tensor_type, is_v)
  if not qm.isNil and not qm.data.isNil:
    let out_a = cast[ptr FloatArray](raw)
    let cols = qm.cols.int
    for r in 0 ..< qm.rows.int:
      for c in 0 ..< cols:
        out_a[r * cols + c] = qmomGet(qm[], r, c, not is_v)
    return
  let p = getTensorPtr(s, layer_idx, tensor_type, not is_v, is_v)
  if not p.isNil: copyMem(raw, p, size * sizeof(cfloat))


# RAM-AUFRAEUMEN 2026-10-15.
# Speichern direkt aus Nim: dieselbe Bytefolge wie save_model_stream_i8(extract_state_i8()) in PHP, aber Tensor fuer
# Tensor. Der alte Weg hielt den ganzen Zustand (int8 + m/v als float) ein zweites Mal im PHP-Speicher, das war die
# RAM-Spitze am Ende jedes Segments (~12 Byte je Parameter). Die Geometrie kommt vom Aufrufer, weil PHP sie aus dem
# Datei-Header nimmt; die Puffer sind nullgefuellt wie die FFI-Puffer von PHP (eine Extraktion, die wegen
# Groessenpruefung nichts liefert, schreibt also dieselben Nullen). Rueckgabe 1 = alles geschrieben, 0 = Fehler.
proc cFflush(f: File): cint {.importc: "fflush", header: "<stdio.h>".}
proc cFclose(f: File): cint {.importc: "fclose", header: "<stdio.h>".}
proc cFileno(f: File): cint {.importc: "fileno", header: "<stdio.h>".}
proc cFsync(fd: cint): cint {.importc: "fsync", header: "<unistd.h>".}
proc cRename(a, b: cstring): cint {.importc: "rename", header: "<stdio.h>".}
proc cRemove(a: cstring): cint {.importc: "remove", header: "<stdio.h>".}
proc cGetpid(): cint {.importc: "getpid", header: "<unistd.h>".}

proc cortex_save_stream_i8*(s: ptr CortexState, filepath_c: cstring,
                            vocab, dim, ffn, ctx, layers: cint): cint {.ffi.} =
  ## Schreibt in eine temporaere Datei und benennt sie erst nach geprueftem
  ## Leeren, fsync und Schliessen um. Sonst blieb der letzte Pufferinhalt beim
  ## Fehler unbemerkt (Erfolg mit abgeschnittener Datei), und ein Fehlschlag
  ## hinterliess eine kaputte Datei unter dem Zielnamen.
  if s.isNil or s.weightDtype != 1: return 0
  var f: File
  let tmpPfad = $filepath_c & ".savetmp." & $cGetpid()
  if not open(f, tmpPfad, fmWrite): return 0
  var ok = true
  # defer, weil writeBuffer bei einem Schreibfehler IOError wirft: auch dann darf
  # keine temporaere Datei liegen bleiben.
  var offen = true
  var erfolg = false
  defer:
    if offen: discard cFclose(f)
    if not erfolg: discard cRemove(tmpPfad.cstring)
  template wr(p: pointer, n: int) =
    if n > 0 and f.writeBuffer(p, n) != n: ok = false
  let tied = s.tiedEmbeddings != 0
  # EMB-EINGANG: Bit 1 nur mit Bindung (V7). Ein V6 kann es nicht tragen - dann lieber nicht speichern als es
  # still verwerfen (cortex_set_emb_eingang laesst den Fall gar nicht erst zu).
  let embEin = s.embEinAn != 0
  if embEin and not tied:
    stderr.writeLine("[cortex] FATAL: Embedding-Eingangsfaktor ohne Bindung - SNAI_V6 kann Bit 1 nicht tragen.")
    return 0
  var magic: array[8, char]
  let ms = (if tied: "SNAI_V7" else: "SNAI_V6")
  for i in 0 ..< ms.len: magic[i] = ms[i]
  wr(addr magic[0], 8)
  var hdr: array[7, uint32] = [vocab.uint32, dim.uint32, ffn.uint32, ctx.uint32, layers.uint32, 1'u32,
                               (if embEin: 3'u32 else: 1'u32)]
  wr(addr hdr[0], (if tied: 28 else: 24))     # dtype INT8 = 1; V7 haengt flags an (Bit 0 = Tying, Bit 1 = EMB-EINGANG)
  let V = vocab.int
  let D = dim.int
  let F = ffn.int
  template tensor(l: int, t: int) =
    block:
      let n = (case t
               of 0, 1: V * D
               of 2, 10, 11: D
               of 12, 13, 14, 15: D * D
               else: F * D)
      if t in [0, 1, 12, 13, 14, 15, 16, 17]:
        let rows = (case t
                    of 0, 1: V
                    of 16: F
                    else: D)
        var sc = newSeq[cfloat](max(1, rows))
        var qd = newSeq[int8](max(1, n))
        cortex_extract_layer_i8(s, l.cint, t.cint, addr qd[0], addr sc[0], n.cint)
        var cnt = uint16(rows and 0xFFFF)
        wr(addr cnt, 2)
        wr(addr sc[0], rows * sizeof(cfloat))
        wr(addr qd[0], n)
      else:
        var w = newSeq[cfloat](max(1, n))
        cortex_extract_layer(s, l.cint, t.cint, addr w[0], n.cint)
        wr(addr w[0], n * sizeof(cfloat))
      var m1 = newSeq[cfloat](max(1, n))
      cortex_extract_adam_layer(s, l.cint, t.cint, false, addr m1[0], n.cint)
      wr(addr m1[0], n * sizeof(cfloat))
      var m2 = newSeq[cfloat](max(1, n))
      cortex_extract_adam_layer(s, l.cint, t.cint, true, addr m2[0], n.cint)
      wr(addr m2[0], n * sizeof(cfloat))
  tensor(-1, 0)
  if not tied: tensor(-1, 1)
  tensor(-1, 2)
  for l in 0 ..< layers.int:
    for t in [10, 11, 12, 13, 14, 15, 16, 17]:
      tensor(l, t)
  var at = cast[uint32](s.adam_t)
  wr(addr at, 4)
  if cFflush(f) != 0: ok = false
  if ok and cFsync(cFileno(f)) != 0: ok = false
  offen = false
  if cFclose(f) != 0: ok = false
  if ok and cRename(tmpPfad.cstring, filepath_c) != 0: ok = false
  erfolg = ok
  return (if ok: 1 else: 0)

# Genesis direkt int8 (init_base.php): quantisiert EINEN Tensor (rows x cols, float32) mit quantizeMatrixToQ8 - genau
# der Funktion, die der Worker nach dem Laden einer Float-Genesis aufruft. Dadurch gibt es die Rundungslogik nur
# einmal. Das ganze Float-Modell existiert nie, nur der jeweils aktuelle Tensor in PHP.
proc cortex_quantize_rows_q8*(src: ptr cfloat, rows, cols: cint, out_i8: ptr int8, out_scale: ptr cfloat): cint {.ffi.} =
  if src.isNil or out_i8.isNil or out_scale.isNil or rows <= 0 or cols <= 0: return 0
  var m = Matrix(rows: rows, cols: cols, data: cast[ptr FloatArray](src))
  var q = quantizeMatrixToQ8(m)
  copyMem(out_i8, q.data, rows.int * cols.int)
  copyMem(out_scale, q.scale, rows.int * sizeof(cfloat))
  freeQMatrix(q)
  return 1

proc cortex_load_adam_layer*(s: ptr CortexState, layer_idx: cint, tensor_type: cint, is_v: bool, raw: ptr cfloat, size: cint) {.ffi.} =
  gpuAdamDrop()
  if size != getExpectedSize(s, tensor_type): return
  # Gegenstueck zu cortex_extract_adam_layer(): die Datei liefert float32,
  # bei aktivem Speicherumbau wird beim Laden quantisiert.
  let qm = getQMomentPtr(s, layer_idx, tensor_type, is_v)
  if not qm.isNil and not qm.data.isNil:
    let src = cast[ptr FloatArray](raw)
    for r in 0 ..< qm.rows.int:
      qmomStoreRow(qm[], r, src, r * qm.cols.int, not is_v)
    return
  let p = getTensorPtr(s, layer_idx, tensor_type, not is_v, is_v)
  if not p.isNil: copyMem(p, raw, size * sizeof(cfloat))

proc cortex_reset_cache*(s: ptr CortexState) {.ffi.} =
  s.cachedTokens = 0

proc cortex_forward*(state: ptr CortexState, raw_in: ptr cint, num_tok: cint, raw_logits: ptr cfloat) {.ffi.} =
  let tokens = cast[ptr IntArray](raw_in)
  let logits = cast[ptr FloatArray](raw_logits)
  
  for i in 0 ..< num_tok:
    var tid = tokens[i]
    if tid < 0 or tid >= state.vocabSize: tid = 0 
    let pos = state.cachedTokens
    if pos >= state.ctxSize: break 
    
    for d in 0 ..< state.hiddenDim: 
      state.hidden_state_buf[d] = state.embeddings.data[tid * state.hiddenDim + d] * embFak(state)
    
    for l in 0 ..< state.numLayers:
      applyRMSNorm(state.hidden_state_buf, state.norm_buf, state.hiddenDim, state.rms_att_weights[l])
      
      matVecMul(state.w_q[l], state.norm_buf, state.q_buf)
      applyRoPE(state.q_buf, state.hiddenDim, state.headSize, state.ctxSize, pos)

      let kp = cast[ptr FloatArray](addr state.k_cache[l].data[pos * state.hiddenDim])
      let vp = cast[ptr FloatArray](addr state.v_cache[l].data[pos * state.hiddenDim])
      matVecMul(state.w_k[l], state.norm_buf, kp)
      applyRoPE(kp, state.hiddenDim, state.headSize, state.ctxSize, pos)
      matVecMul(state.w_v[l], state.norm_buf, vp)
      
      if gpu_initialized:
          gpuAttentionForward(cast[ptr cfloat](state.q_buf), cast[ptr cfloat](state.k_cache[l].data), cast[ptr cfloat](state.v_cache[l].data),
                               cast[ptr cfloat](state.att_out_buf), pos.cint, state.numHeads.cint, state.headSize.cint, state.hiddenDim.cint, state.ctxSize.cint)
      else:
          for d in 0 ..< state.hiddenDim:
            state.att_out_buf[d] = 0.0
            
          for h in 0 ..< state.numHeads:
            let h_off = h * state.headSize
            var max_s: cfloat = NegInf.cfloat
            for t in 0 .. pos:
              let tk = cast[ptr FloatArray](addr state.k_cache[l].data[t * state.hiddenDim])
              var sc: cfloat = 0.0
              for d in 0 ..< state.headSize: 
                sc += state.q_buf[h_off + d] * tk[h_off + d]
              sc /= sqrt(state.headSize.float32)
              state.scores_buf[t] = sc
              if sc > max_s: max_s = sc
              
            var sum_e: cfloat = 0.0
            for t in 0 .. pos: 
              state.scores_buf[t] = exp(state.scores_buf[t] - max_s)
              sum_e += state.scores_buf[t]
              
            for t in 0 .. pos:
              let w = state.scores_buf[t] / sum_e
              let tv = cast[ptr FloatArray](addr state.v_cache[l].data[t * state.hiddenDim])
              for d in 0 ..< state.headSize: 
                state.att_out_buf[h_off + d] += tv[h_off + d] * w
      
      matVecMul(state.w_o[l], state.att_out_buf, state.d_norm)
      for d in 0 ..< state.hiddenDim: 
        state.hidden_state_buf[d] += state.d_norm[d]
      
      applyRMSNorm(state.hidden_state_buf, state.norm_buf, state.hiddenDim, state.rms_ffn_weights[l])
      matVecMul(state.w_up[l], state.norm_buf, state.ffn_buf)
      for d in 0 ..< state.ffnDim: 
        let v = state.ffn_buf[d]
        state.ffn_buf[d] = v * (1.0 / (1.0 + exp(-v)))
      matVecMul(state.w_down[l], state.ffn_buf, state.att_out_buf)
      for d in 0 ..< state.hiddenDim: 
        state.hidden_state_buf[d] += state.att_out_buf[d]
        
      if i == num_tok - 1:
        for d in 0 ..< state.hiddenDim:
          state.j_space_cache[l][d] = state.hidden_state_buf[d]
    
    applyRMSNorm(state.hidden_state_buf, state.norm_buf, state.hiddenDim, state.rms_final_weight)
    
    if i == num_tok - 1:
      # V11.4: identische Mathematik, jetzt ueber den GPU-Pfad.
      matVecMul(state.w_out, state.norm_buf, logits)
    
    state.cachedTokens += 1

proc cortex_forward_i8*(state: ptr CortexState, raw_in: ptr cint, num_tok: cint, raw_logits: ptr cfloat) {.ffi.} =
  ## PHASE 6 DES INT8-UMBAUS
  ## INT8-Pendant zu cortex_forward() - reiner Forward-Pass (kein Training),
  ## fuer Inferenz/Held-out-Eval auf einem nativ per cortex_load_stream_i8()
  ## geladenen INT8-Checkpoint. Erwartet state.weightDtype==1. Spiegelt exakt
  ## den Forward-Teil von cortex_train_step_i8() (Phase 2), nur ohne die
  ## Backward-/Adam-Haelfte und mit state.cachedTokens als Streaming-Position
  ## (wie cortex_forward()) statt einer expliziten Positions-Schleife.
  if state.isNil or state.weightDtype != 1: return
  # FFN-SKIP: zu Beginn einer Sequenz neu erkennen (mitten in einer Sequenz aendern sich die Gewichte nicht,
  # sonst passte der KV-Cache nicht mehr).
  if state.cachedTokens == 0: ffnSkipAktualisieren(state)
  flushQWeightsToGpu(state)   # PHASE 7: veraltete VRAM-Gewichte auffrischen
  let tokens = cast[ptr IntArray](raw_in)
  let logits = cast[ptr FloatArray](raw_logits)

  for i in 0 ..< num_tok:
    var tid = tokens[i]
    if tid < 0 or tid >= state.vocabSize: tid = 0
    let pos = state.cachedTokens
    if pos >= state.ctxSize: break

    for d in 0 ..< state.hiddenDim:
      state.hidden_state_buf[d] = state.embeddings_q8.data[tid * state.hiddenDim + d].cfloat * state.embeddings_q8.scale[tid] * embFak(state)

    for l in 0 ..< state.numLayers:
      applyRMSNorm(state.hidden_state_buf, state.norm_buf, state.hiddenDim, state.rms_att_weights[l])

      # LoRA: identische Einbaustellen wie im gebuendelten Trainingspfad -
      # unmittelbar nach dem Basis-GEMM, vor RoPE/Quantisierung. Waere die
      # Reihenfolge hier eine andere als dort, wuerde ein Modell anders
      # ausgewertet als es trainiert wurde, und der A/B vergliche zwei
      # verschiedene Rechnungen.
      matVecMulI8(state.w_q_q8[l], state.norm_buf, state.q_buf, state.i8_qscratch)
      loraForwardVec(state, l, 0, state.norm_buf, state.q_buf)
      applyRoPE(state.q_buf, state.hiddenDim, state.headSize, state.ctxSize, pos)

      matVecMulI8(state.w_k_q8[l], state.norm_buf, state.kv_raw_buf, state.i8_qscratch)
      loraForwardVec(state, l, 1, state.norm_buf, state.kv_raw_buf)
      applyRoPE(state.kv_raw_buf, state.hiddenDim, state.headSize, state.ctxSize, pos)
      quantizeVectorToQ8Row(state.kv_raw_buf, state.k_cache_q8[l], pos.cint, state.hiddenDim)

      matVecMulI8(state.w_v_q8[l], state.norm_buf, state.kv_raw_buf, state.i8_qscratch)
      loraForwardVec(state, l, 2, state.norm_buf, state.kv_raw_buf)
      quantizeVectorToQ8Row(state.kv_raw_buf, state.v_cache_q8[l], pos.cint, state.hiddenDim)

      let qScale = quantizeActivation(state.q_buf, state.i8_qscratch, state.hiddenDim)

      for d in 0 ..< state.hiddenDim:
        state.att_out_buf[d] = 0.0
      for h in 0 ..< state.numHeads:
        let h_off = h * state.headSize
        var max_s: cfloat = NegInf.cfloat
        for t in 0 .. pos:
          let kRow = t * state.hiddenDim
          var acc: int32 = 0
          for d in 0 ..< state.headSize:
            acc += int32(state.i8_qscratch[h_off + d]) * int32(state.k_cache_q8[l].data[kRow + h_off + d])
          var sc = acc.cfloat * qScale * state.k_cache_q8[l].scale[t]
          sc /= sqrt(state.headSize.float32)
          state.scores_buf[t] = sc
          if sc > max_s: max_s = sc
        var sum_e: cfloat = 0.0
        for t in 0 .. pos:
          state.scores_buf[t] = exp(state.scores_buf[t] - max_s)
          sum_e += state.scores_buf[t]
        for t in 0 .. pos:
          let w = state.scores_buf[t] / sum_e
          let vRow = t * state.hiddenDim
          let vScale = state.v_cache_q8[l].scale[t]
          for d in 0 ..< state.headSize:
            state.att_out_buf[h_off + d] += (state.v_cache_q8[l].data[vRow + h_off + d].cfloat * vScale) * w

      matVecMulI8(state.w_o_q8[l], state.att_out_buf, state.d_norm, state.i8_qscratch)
      loraForwardVec(state, l, 3, state.att_out_buf, state.d_norm)
      for d in 0 ..< state.hiddenDim:
        state.hidden_state_buf[d] += state.d_norm[d]

      if not ffnAusL(state, l):   # FFN-SKIP
        applyRMSNorm(state.hidden_state_buf, state.norm_buf, state.hiddenDim, state.rms_ffn_weights[l])
        matVecMulI8(state.w_up_q8[l], state.norm_buf, state.ffn_buf, state.i8_qscratch)
        loraForwardVec(state, l, 4, state.norm_buf, state.ffn_buf)
        for d in 0 ..< state.ffnDim:
          let v = state.ffn_buf[d]
          state.ffn_buf[d] = v * (1.0 / (1.0 + exp(-v)))
        matVecMulI8(state.w_down_q8[l], state.ffn_buf, state.att_out_buf, state.i8_qscratch)
        loraForwardVec(state, l, 5, state.ffn_buf, state.att_out_buf)
        for d in 0 ..< state.hiddenDim:
          state.hidden_state_buf[d] += state.att_out_buf[d]

      if i == num_tok - 1:
        for d in 0 ..< state.hiddenDim:
          state.j_space_cache[l][d] = state.hidden_state_buf[d]

    applyRMSNorm(state.hidden_state_buf, state.norm_buf, state.hiddenDim, state.rms_final_weight)

    if i == num_tok - 1:
      matVecMulI8(state.w_out_q8, state.norm_buf, logits, state.i8_qscratch)

    state.cachedTokens += 1

proc cortex_train_step*(state: ptr CortexState, raw_in: ptr cint, raw_tg: ptr cint, raw_mask: ptr cint, num_tok: cint, lr: cfloat): cfloat {.ffi.} =
  # SCHRITT 4b: der FP32-Pfad kennt die quantisierte Historie nicht. Ein
  # State mit quantActs ist fuer ihn nicht benutzbar - klare Meldung statt
  # Nullzeiger-Zugriff.
  if not state.isNil and (state.quantActs != 0 or state.quantActsIn != 0):
    stderr.writeLine("[cortex] FATAL: cortex_train_step() (FP32) auf einem State mit ",
                     "quantisierten FFN-Aktivierungen - nur der INT8-Pfad unterstuetzt das.")
    return -1.0
  let act = min(num_tok, state.ctxSize)
  if act <= 0: return 0.0
  let t_step = epochTime()
  let useBatchedWout = (batched_wout != 0)
  let batchedAttn = (batched_attention != 0)
  let t_in = cast[ptr IntArray](raw_in)
  let t_tg = cast[ptr IntArray](raw_tg)
  let t_mask = cast[ptr IntArray](raw_mask)
  var total_loss: cfloat = 0.0
  # Loss-Masking (Stichwort "Loss-Masking auf [USER]-Tokens"): zaehlt
  # nur Positionen, deren Ziel-Token trainierbar ist (t_mask[pos] != 0), damit
  # die zurueckgegebene Durchschnitts-Loss nicht durch nicht-trainierte
  # [USER]-Positionen verwaessert wird.
  var trainable_count: cint = 0
  
  # V11.4: Gradienten, die auf der GPU akkumuliert werden, muessen AUCH dort
  # genullt werden. g_embeddings und die rms-Gradienten sind bewusst NICHT dabei -
  # die entstehen weiterhin auf der CPU (Scatter bzw. Norm-Backward).
  template zeroGrad(g: Matrix) =
    zeroMat(g)
    if useGpuMat(g): gpuZeroBuffer(cast[ptr cfloat](g.data), gradBytes(g))

  zeroMat(state.g_embeddings)
  zeroGrad(state.g_w_out)
  zeroArr(state.g_rms_final_weight, state.hiddenDim)
  
  for l in 0 ..< state.numLayers:
    zeroGrad(state.g_w_q[l])
    zeroGrad(state.g_w_k[l])
    zeroGrad(state.g_w_v[l])
    zeroGrad(state.g_w_o[l])
    zeroGrad(state.g_w_up[l])
    zeroGrad(state.g_w_down[l])
    zeroArr(state.g_rms_att_weights[l], state.hiddenDim)
    zeroArr(state.g_rms_ffn_weights[l], state.hiddenDim)
    
    if gpu_initialized:
      let full_cache_bytes = cast[csize_t](state.ctxSize * state.hiddenDim * sizeof(cfloat))
      gpuZeroBuffer(cast[ptr cfloat](state.d_k_cache[l].data), full_cache_bytes)
      gpuZeroBuffer(cast[ptr cfloat](state.d_v_cache[l].data), full_cache_bytes)
    else:
      for i in 0 ..< (act * state.hiddenDim): 
        state.d_k_cache[l].data[i] = 0.0
        state.d_v_cache[l].data[i] = 0.0

  if batchedAttn:
    # ==========================================================================
    # AUDIT: LAYER-MAJOR FORWARD (gebuendelte Attention)
    # Mathematisch identisch zum Positions-Major-Pfad unten, nur umsortiert:
    # fuer jeden Layer werden erst ALLE Positionen durch RMSNorm+QKV geschickt,
    # dann EIN gebuendelter Attention-Aufruf fuer den ganzen Layer, dann ALLE
    # Positionen durch O-Projektion+FFN. state.act_hidden_final dient dabei als
    # Positions-persistenter Roll-Puffer ueber die Layer hinweg (ersetzt
    # hidden_state_buf, das im alten Pfad pro Position frisch aus den Embeddings
    # startete) - nach dem letzten Layer haelt es exakt das, was sein Name schon
    # immer versprach: den finalen Hidden-State je Position.
    # ==========================================================================
    for p in 0 ..< act:
      var tid = t_in[p]
      if tid < 0 or tid >= state.vocabSize: tid = 0
      let off_dim = p * state.hiddenDim
      for d in 0 ..< state.hiddenDim:
        state.act_hidden_final[off_dim + d] = state.embeddings.data[tid * state.hiddenDim + d] * embFak(state)

    for l in 0 ..< state.numLayers:
      # Sub-Pass 1: RMSNorm (echt Positions-abhaengig, bleibt Schleife) direkt
      # in act_norm_att[l] geschrieben, dann Q/K/V in EINEM Rutsch fuer alle
      # Positionen - dieselbe Batched-Matmul-Infrastruktur wie beim w_out-Pfad.
      for i in 0 ..< (act * state.hiddenDim):
        state.act_hidden[l][i] = state.act_hidden_final[i]
      for p in 0 ..< act:
        let off_dim = p * state.hiddenDim
        applyRMSNorm(cast[ptr FloatArray](addr state.act_hidden_final[off_dim]),
                     cast[ptr FloatArray](addr state.act_norm_att[l][off_dim]),
                     state.hiddenDim, state.rms_att_weights[l])

      matMulBatchedD(state.w_q[l], state.act_norm_att[l], cast[ptr FloatArray](state.act_q[l].data), act, state.ctxSize.int)
      matMulBatchedD(state.w_k[l], state.act_norm_att[l], cast[ptr FloatArray](state.k_cache[l].data), act, state.ctxSize.int)
      matMulBatchedD(state.w_v[l], state.act_norm_att[l], cast[ptr FloatArray](state.v_cache[l].data), act, state.ctxSize.int)

      for p in 0 ..< act:
        let off_dim = p * state.hiddenDim
        applyRoPE(cast[ptr FloatArray](addr state.act_q[l].data[off_dim]), state.hiddenDim, state.headSize, state.ctxSize, p.cint)
        applyRoPE(cast[ptr FloatArray](addr state.k_cache[l].data[off_dim]), state.hiddenDim, state.headSize, state.ctxSize, p.cint)

      attentionForwardBatchedD(state, l.cint, act.cint)

      # Sub-Pass 3: O-Projektion gebuendelt -> mm_hd_scratch, dann Skip-Add +
      # FFN-RMSNorm (Positions-abhaengig), dann Up/Down gebuendelt.
      matMulBatchedD(state.w_o[l], state.act_att_out[l], state.mm_hd_scratch, act, state.ctxSize.int)
      for i in 0 ..< (act * state.hiddenDim):
        state.act_hidden_final[i] += state.mm_hd_scratch[i]
      for i in 0 ..< (act * state.hiddenDim):
        state.act_hidden_ffn[l][i] = state.act_hidden_final[i]
      for p in 0 ..< act:
        let off_dim = p * state.hiddenDim
        applyRMSNorm(cast[ptr FloatArray](addr state.act_hidden_final[off_dim]),
                     cast[ptr FloatArray](addr state.act_norm_ffn[l][off_dim]),
                     state.hiddenDim, state.rms_ffn_weights[l])

      matMulBatchedD(state.w_up[l], state.act_norm_ffn[l], state.act_ffn_in[l], act, state.ctxSize.int)
      for i in 0 ..< (act * state.ffnDim):
        let v = state.act_ffn_in[l][i]
        state.act_ffn_out[l][i] = v * (1.0 / (1.0 + exp(-v)))
      applyDropoutForward(state.act_ffn_out[l], state.dropout_mask[l], act * state.ffnDim)
      matMulBatchedD(state.w_down[l], state.act_ffn_out[l], state.mm_hd_scratch, act, state.ctxSize.int)
      for i in 0 ..< (act * state.hiddenDim):
        state.act_hidden_final[i] += state.mm_hd_scratch[i]

    for p in 0 ..< act:
      var tgid = t_tg[p]
      if tgid < 0 or tgid >= state.vocabSize: tgid = 0
      let off_dim = p * state.hiddenDim
      let final_hidden = cast[ptr FloatArray](addr state.act_hidden_final[off_dim])
      applyRMSNorm(final_hidden, state.norm_buf, state.hiddenDim, state.rms_final_weight)

      if useBatchedWout:
        for d in 0 ..< state.hiddenDim:
          state.act_norm_final[off_dim + d] = state.norm_buf[d]
      else:
        var max_l: cfloat = -9999.0
        let logits = cast[ptr FloatArray](addr state.logits_cache.data[p * state.vocabSize])
        matVecMul(state.w_out, state.norm_buf, logits)
        for v in 0 ..< state.vocabSize:
          if logits[v] > max_l: max_l = logits[v]
        var sum_p: cfloat = 0.0
        for v in 0 ..< state.vocabSize:
          logits[v] = exp(logits[v] - max_l)
          sum_p += logits[v]
        for v in 0 ..< state.vocabSize:
          logits[v] /= sum_p
        if t_mask[p] != 0:
          total_loss += -ln(logits[tgid] + 1e-7)
          inc trainable_count
  else:
   for pos in 0 ..< act:
    var tid = t_in[pos]
    var tgid = t_tg[pos]
    if tid < 0 or tid >= state.vocabSize: tid = 0
    if tgid < 0 or tgid >= state.vocabSize: tgid = 0
    let off_dim = pos * state.hiddenDim
    let off_ffn = pos * state.ffnDim
    for d in 0 ..< state.hiddenDim:
      state.hidden_state_buf[d] = state.embeddings.data[tid * state.hiddenDim + d] * embFak(state)

    for l in 0 ..< state.numLayers:
      for d in 0 ..< state.hiddenDim:
        state.act_hidden[l][off_dim + d] = state.hidden_state_buf[d]
      applyRMSNorm(state.hidden_state_buf, state.norm_buf, state.hiddenDim, state.rms_att_weights[l])
      for d in 0 ..< state.hiddenDim:
        state.act_norm_att[l][off_dim + d] = state.norm_buf[d]

      let q_p = cast[ptr FloatArray](addr state.act_q[l].data[off_dim])
      matVecMul(state.w_q[l], state.norm_buf, q_p)
      applyRoPE(q_p, state.hiddenDim, state.headSize, state.ctxSize, pos)

      let kp = cast[ptr FloatArray](addr state.k_cache[l].data[off_dim])
      let vp = cast[ptr FloatArray](addr state.v_cache[l].data[off_dim])
      matVecMul(state.w_k[l], state.norm_buf, kp)
      applyRoPE(kp, state.hiddenDim, state.headSize, state.ctxSize, pos)
      matVecMul(state.w_v[l], state.norm_buf, vp)

      if gpu_initialized:
          gpuAttentionForward(cast[ptr cfloat](q_p), cast[ptr cfloat](state.k_cache[l].data), cast[ptr cfloat](state.v_cache[l].data),
                               cast[ptr cfloat](state.att_out_buf), pos.cint, state.numHeads.cint, state.headSize.cint, state.hiddenDim.cint, state.ctxSize.cint)
      else:
          for d in 0 ..< state.hiddenDim:
            state.att_out_buf[d] = 0.0

          for h in 0 ..< state.numHeads:
            let h_off = h * state.headSize
            var max_s: cfloat = NegInf.cfloat
            for t in 0 .. pos:
              let tk = cast[ptr FloatArray](addr state.k_cache[l].data[t * state.hiddenDim])
              var sc: cfloat = 0.0
              for d in 0 ..< state.headSize:
                sc += q_p[h_off + d] * tk[h_off + d]
              sc /= sqrt(state.headSize.float32)
              state.scores_buf[t] = sc
              if sc > max_s: max_s = sc

            var sum_e: cfloat = 0.0
            for t in 0 .. pos:
              state.scores_buf[t] = exp(state.scores_buf[t] - max_s)
              sum_e += state.scores_buf[t]

            for t in 0 .. pos:
              let w = state.scores_buf[t] / sum_e
              let tv = cast[ptr FloatArray](addr state.v_cache[l].data[t * state.hiddenDim])
              for d in 0 ..< state.headSize:
                state.att_out_buf[h_off + d] += tv[h_off + d] * w

      for d in 0 ..< state.hiddenDim:
        state.act_att_out[l][off_dim + d] = state.att_out_buf[d]
      matVecMul(state.w_o[l], state.att_out_buf, state.d_norm)
      for d in 0 ..< state.hiddenDim:
        state.hidden_state_buf[d] += state.d_norm[d]

      for d in 0 ..< state.hiddenDim:
        state.act_hidden_ffn[l][off_dim + d] = state.hidden_state_buf[d]
      applyRMSNorm(state.hidden_state_buf, state.norm_buf, state.hiddenDim, state.rms_ffn_weights[l])
      for d in 0 ..< state.hiddenDim:
        state.act_norm_ffn[l][off_dim + d] = state.norm_buf[d]

      matVecMul(state.w_up[l], state.norm_buf, state.ffn_buf)
      for d in 0 ..< state.ffnDim:
        state.act_ffn_in[l][off_ffn + d] = state.ffn_buf[d]
      for d in 0 ..< state.ffnDim:
        let v = state.ffn_buf[d]
        state.ffn_buf[d] = v * (1.0 / (1.0 + exp(-v)))
      applyDropoutForward(state.ffn_buf, state.dropout_mask[l], state.ffnDim, off_ffn)
      for d in 0 ..< state.ffnDim:
        state.act_ffn_out[l][off_ffn + d] = state.ffn_buf[d]
      matVecMul(state.w_down[l], state.ffn_buf, state.att_out_buf)
      for d in 0 ..< state.hiddenDim:
        state.hidden_state_buf[d] += state.att_out_buf[d]

    for d in 0 ..< state.hiddenDim:
      state.act_hidden_final[off_dim + d] = state.hidden_state_buf[d]
    applyRMSNorm(state.hidden_state_buf, state.norm_buf, state.hiddenDim, state.rms_final_weight)

    if useBatchedWout:
      # V11.9: nur die Norm-Ausgabe sichern. w_out laeuft nach der Schleife
      # gebuendelt ueber ALLE Positionen - ein Kernel statt act Kernels.
      for d in 0 ..< state.hiddenDim:
        state.act_norm_final[off_dim + d] = state.norm_buf[d]
    else:
      var max_l: cfloat = -9999.0
      let logits = cast[ptr FloatArray](addr state.logits_cache.data[pos * state.vocabSize])
      matVecMul(state.w_out, state.norm_buf, logits)
      for v in 0 ..< state.vocabSize:
        if logits[v] > max_l: max_l = logits[v]
      var sum_p: cfloat = 0.0
      for v in 0 ..< state.vocabSize:
        logits[v] = exp(logits[v] - max_l)
        sum_p += logits[v]
      for v in 0 ..< state.vocabSize:
        logits[v] /= sum_p
      if t_mask[pos] != 0:
        total_loss += -ln(logits[tgid] + 1e-7)
        inc trainable_count

  # ============================================================================
  # V11.9: GEBUENDELTER w_out-BLOCK
  # Ein matMulBatched fuer alle Logits, dann Softmax je Position, dann
  # d_logits in-place in logits_cache - und ein einziges Paar Backward-Aufrufe
  # statt act Stueck. Reihenfolge-unabhaengig, deshalb aus der countdown-
  # Schleife herausziehbar (Attention-Gradienten bleiben dort unberuehrt).
  # ============================================================================
  if useBatchedWout:
    let logits_all = cast[ptr FloatArray](state.logits_cache.data)
    matMulBatchedD(state.w_out, state.act_norm_final, logits_all, act, state.ctxSize.int)

    for pos in 0 ..< act:
      var tgid = t_tg[pos]
      if tgid < 0 or tgid >= state.vocabSize: tgid = 0
      let base = pos * state.vocabSize
      var max_l: cfloat = -9999.0
      for v in 0 ..< state.vocabSize:
        if logits_all[base + v] > max_l: max_l = logits_all[base + v]
      var sum_p: cfloat = 0.0
      for v in 0 ..< state.vocabSize:
        logits_all[base + v] = exp(logits_all[base + v] - max_l)
        sum_p += logits_all[base + v]
      for v in 0 ..< state.vocabSize:
        logits_all[base + v] /= sum_p
      if t_mask[pos] != 0:
        total_loss += -ln(logits_all[base + tgid] + 1e-7)
        inc trainable_count

    # d_logits IN-PLACE: ab hier haelt logits_cache die Gradienten, nicht mehr
    # die Wahrscheinlichkeiten. Die Logits werden danach nicht mehr gebraucht.
    # Maskierte Positionen (t_mask[pos] == 0, [USER]-Ziel-Token) bekommen einen
    # Null-Gradienten - kein Backprop-Signal fuer vom Menschen vorgegebenen Text.
    for pos in 0 ..< act:
      var tgid = t_tg[pos]
      if tgid < 0 or tgid >= state.vocabSize: tgid = 0
      let base = pos * state.vocabSize
      if t_mask[pos] != 0:
        for v in 0 ..< state.vocabSize:
          logits_all[base + v] = logits_all[base + v] - smoothedTarget(v, tgid, state.vocabSize)
      else:
        for v in 0 ..< state.vocabSize:
          logits_all[base + v] = 0.0

    matMulTBatchedD(state.w_out, logits_all, state.d_norm_all, act)
    gradAccumBatchedD(state.w_out, state.g_w_out, logits_all, state.act_norm_final, act)

  if batchedAttn:
    # ==========================================================================
    # AUDIT: LAYER-MAJOR BACKWARD (gebuendelte Attention)
    # Spiegel des Forward-Umbaus. state.d_hidden_all uebernimmt die Rolle von
    # d_hidden, jetzt aber Positions-persistent statt pro Position frisch auf
    # 0 gesetzt - es sammelt den Gradienten fuer jede Position ueber die
    # gesamte Countdown-Schleife der Layer.
    # ==========================================================================
    for p in 0 ..< act:
      let off_dim = p * state.hiddenDim
      let final_hidden = cast[ptr FloatArray](addr state.act_hidden_final[off_dim])
      if useBatchedWout:
        for d in 0 ..< state.hiddenDim:
          state.d_norm[d] = state.d_norm_all[off_dim + d]
      else:
        var tgid = t_tg[p]
        if tgid < 0 or tgid >= state.vocabSize: tgid = 0
        let logits = cast[ptr FloatArray](addr state.logits_cache.data[p * state.vocabSize])
        if t_mask[p] != 0:
          for v in 0 ..< state.vocabSize:
            state.d_logits_buf[v] = logits[v] - smoothedTarget(v, tgid, state.vocabSize)
        else:
          for v in 0 ..< state.vocabSize:
            state.d_logits_buf[v] = 0.0
        applyRMSNorm(final_hidden, state.norm_buf, state.hiddenDim, state.rms_final_weight)
        matVecMulBackwardAcc(state.w_out, state.g_w_out, state.norm_buf, state.d_logits_buf, state.d_norm, false)
      applyRMSNormBackwardAcc(state.d_norm, final_hidden, state.hiddenDim, state.rms_final_weight, state.g_rms_final_weight)
      for d in 0 ..< state.hiddenDim:
        state.d_hidden_all[off_dim + d] = state.d_norm[d]

    for l in countdown(state.numLayers - 1, 0):
      # Sub-Pass A: FFN-Backward gebuendelt. d_hidden_all ist bereits exakt das,
      # was vorher pro Position in d_norm kopiert wurde - direkt als d_out_all
      # verwendbar, keine Kopie noetig.
      matMulTBatchedD(state.w_down[l], state.d_hidden_all, state.mm_ffn_scratch, act)
      gradAccumBatchedD(state.w_down[l], state.g_w_down[l], state.d_hidden_all, state.act_ffn_out[l], act)

      applyDropoutBackward(state.mm_ffn_scratch, state.dropout_mask[l], act * state.ffnDim)
      for i in 0 ..< (act * state.ffnDim):
        let x = state.act_ffn_in[l][i]
        let sig = 1.0 / (1.0 + exp(-x))
        state.mm_ffn_scratch[i] *= sig * (1.0 + x * (1.0 - sig))

      matMulTBatchedD(state.w_up[l], state.mm_ffn_scratch, state.mm_hd_scratch, act)
      gradAccumBatchedD(state.w_up[l], state.g_w_up[l], state.mm_ffn_scratch, state.act_norm_ffn[l], act)

      for p in 0 ..< act:
        let off_dim = p * state.hiddenDim
        applyRMSNormBackwardAcc(cast[ptr FloatArray](addr state.mm_hd_scratch[off_dim]),
                                 cast[ptr FloatArray](addr state.act_hidden_ffn[l][off_dim]),
                                 state.hiddenDim, state.rms_ffn_weights[l], state.g_rms_ffn_weights[l])
      for i in 0 ..< (act * state.hiddenDim):
        state.d_hidden_all[i] += state.mm_hd_scratch[i]

      # Sub-Pass B: O-Projektion-Backward gebuendelt -> d_att_out_all.
      matMulTBatchedD(state.w_o[l], state.d_hidden_all, state.d_att_out_all, act)
      gradAccumBatchedD(state.w_o[l], state.g_w_o[l], state.d_hidden_all, state.act_att_out[l], act)

      let t_att = epochTime()
      attentionBackwardBatchedD(state, l.cint, act.cint)
      prof[4] += epochTime() - t_att

      for p in 0 ..< act:
        let off_dim = p * state.hiddenDim
        applyRoPE(cast[ptr FloatArray](addr state.d_q_all[off_dim]), state.hiddenDim, state.headSize, state.ctxSize, p.cint, true)
        applyRoPE(cast[ptr FloatArray](addr state.d_k_cache[l].data[off_dim]), state.hiddenDim, state.headSize, state.ctxSize, p.cint, true)

      # Sub-Pass C: Q/K/V-Backward gebuendelt. Alle drei speisen denselben
      # act_norm_att[l] - ihre d_in-Beitraege muessen deshalb aufsummiert
      # werden (matMulTBatchedD's accumulate-Parameter, siehe dessen Kommentar).
      matMulTBatchedD(state.w_q[l], state.d_q_all, state.mm_hd_scratch, act, false)
      gradAccumBatchedD(state.w_q[l], state.g_w_q[l], state.d_q_all, state.act_norm_att[l], act)
      matMulTBatchedD(state.w_k[l], state.d_k_cache[l].data, state.mm_hd_scratch, act, true)
      gradAccumBatchedD(state.w_k[l], state.g_w_k[l], state.d_k_cache[l].data, state.act_norm_att[l], act)
      matMulTBatchedD(state.w_v[l], state.d_v_cache[l].data, state.mm_hd_scratch, act, true)
      gradAccumBatchedD(state.w_v[l], state.g_w_v[l], state.d_v_cache[l].data, state.act_norm_att[l], act)

      for p in 0 ..< act:
        let off_dim = p * state.hiddenDim
        applyRMSNormBackwardAcc(cast[ptr FloatArray](addr state.mm_hd_scratch[off_dim]),
                                 cast[ptr FloatArray](addr state.act_hidden[l][off_dim]),
                                 state.hiddenDim, state.rms_att_weights[l], state.g_rms_att_weights[l])
      for i in 0 ..< (act * state.hiddenDim):
        state.d_hidden_all[i] += state.mm_hd_scratch[i]

    for p in 0 ..< act:
      var tid = t_in[p]
      if tid < 0 or tid >= state.vocabSize: tid = 0
      let off_dim = p * state.hiddenDim
      for d in 0 ..< state.hiddenDim:
        state.g_embeddings.data[tid * state.hiddenDim + d] += state.d_hidden_all[off_dim + d] * embFak(state)
  else:
   for pos in countdown(act - 1, 0):
    var tid = t_in[pos]
    var tgid = t_tg[pos]
    if tid < 0 or tid >= state.vocabSize: tid = 0
    if tgid < 0 or tgid >= state.vocabSize: tgid = 0
    let off_dim = pos * state.hiddenDim
    let off_ffn = pos * state.ffnDim
    let logits = cast[ptr FloatArray](addr state.logits_cache.data[pos * state.vocabSize])

    if not useBatchedWout:
      if t_mask[pos] != 0:
        for v in 0 ..< state.vocabSize:
          state.d_logits_buf[v] = logits[v] - smoothedTarget(v, tgid, state.vocabSize)
      else:
        for v in 0 ..< state.vocabSize:
          state.d_logits_buf[v] = 0.0
    for d in 0 ..< state.hiddenDim:
      state.d_hidden[d] = 0.0

    let final_hidden = cast[ptr FloatArray](addr state.act_hidden_final[off_dim])
    if useBatchedWout:
      # d_norm wurde bereits gebuendelt berechnet - nur uebernehmen.
      for d in 0 ..< state.hiddenDim:
        state.d_norm[d] = state.d_norm_all[off_dim + d]
    else:
      applyRMSNorm(final_hidden, state.norm_buf, state.hiddenDim, state.rms_final_weight)
      matVecMulBackwardAcc(state.w_out, state.g_w_out, state.norm_buf, state.d_logits_buf, state.d_norm, false)
    applyRMSNormBackwardAcc(state.d_norm, final_hidden, state.hiddenDim, state.rms_final_weight, state.g_rms_final_weight)

    for d in 0 ..< state.hiddenDim:
      state.d_hidden[d] += state.d_norm[d]

    for l in countdown(state.numLayers - 1, 0):
      for d in 0 ..< state.hiddenDim:
        state.d_norm[d] = state.d_hidden[d]

      let act_ffn_out_p = cast[ptr FloatArray](addr state.act_ffn_out[l][off_ffn])
      matVecMulBackwardAcc(state.w_down[l], state.g_w_down[l], act_ffn_out_p, state.d_norm, state.d_ffn, false)

      applyDropoutBackward(state.d_ffn, state.dropout_mask[l], state.ffnDim, off_ffn)
      let act_ffn_in_p = cast[ptr FloatArray](addr state.act_ffn_in[l][off_ffn])
      for d in 0 ..< state.ffnDim:
        let x = act_ffn_in_p[d]
        let sig = 1.0 / (1.0 + exp(-x))
        state.d_ffn[d] *= sig * (1.0 + x * (1.0 - sig))

      let act_norm_ffn_p = cast[ptr FloatArray](addr state.act_norm_ffn[l][off_dim])
      matVecMulBackwardAcc(state.w_up[l], state.g_w_up[l], act_norm_ffn_p, state.d_ffn, state.d_norm, false)

      let act_hidden_ffn_p = cast[ptr FloatArray](addr state.act_hidden_ffn[l][off_dim])
      applyRMSNormBackwardAcc(state.d_norm, act_hidden_ffn_p, state.hiddenDim, state.rms_ffn_weights[l], state.g_rms_ffn_weights[l])

      for d in 0 ..< state.hiddenDim:
        state.d_hidden[d] += state.d_norm[d]
      for d in 0 ..< state.hiddenDim:
        state.d_norm[d] = state.d_hidden[d]

      let act_att_out_p = cast[ptr FloatArray](addr state.act_att_out[l][off_dim])
      matVecMulBackwardAcc(state.w_o[l], state.g_w_o[l], act_att_out_p, state.d_norm, state.d_att_out, false)

      let q_p = cast[ptr FloatArray](addr state.act_q[l].data[off_dim])

      let t_att = epochTime()
      if gpu_initialized:
          gpuAttentionBackward(cast[ptr cfloat](q_p), cast[ptr cfloat](state.k_cache[l].data), cast[ptr cfloat](state.v_cache[l].data), cast[ptr cfloat](state.d_att_out),
                                cast[ptr cfloat](state.d_q), cast[ptr cfloat](state.d_k_cache[l].data), cast[ptr cfloat](state.d_v_cache[l].data),
                                pos.cint, state.numHeads.cint, state.headSize.cint, state.hiddenDim.cint, state.ctxSize.cint)
          prof[4] += epochTime() - t_att
      else:
          for d in 0 ..< state.hiddenDim:
            state.d_q[d] = 0.0
          for h in 0 ..< state.numHeads:
            let h_off = h * state.headSize
            let scale = 1.0 / sqrt(state.headSize.float32)
            var max_s: cfloat = NegInf.cfloat
            for t in 0 .. pos:
              let k_t = cast[ptr FloatArray](addr state.k_cache[l].data[t * state.hiddenDim])
              var sc: cfloat = 0.0
              for d in 0 ..< state.headSize:
                sc += q_p[h_off + d] * k_t[h_off + d]
              sc *= scale
              state.scores_buf[t] = sc
              if sc > max_s: max_s = sc

            var sum_e: cfloat = 0.0
            for t in 0 .. pos:
              state.scores_buf[t] = exp(state.scores_buf[t] - max_s)
              sum_e += state.scores_buf[t]

            var sum_w_dw: cfloat = 0.0
            for t in 0 .. pos:
              let w = state.scores_buf[t] / sum_e
              state.scores_buf[t] = w
              let v_t = cast[ptr FloatArray](addr state.v_cache[l].data[t * state.hiddenDim])
              var dw: cfloat = 0.0
              for d in 0 ..< state.headSize:
                dw += state.d_att_out[h_off + d] * v_t[h_off + d]

              let d_v_t = cast[ptr FloatArray](addr state.d_v_cache[l].data[t * state.hiddenDim])
              for d in 0 ..< state.headSize:
                d_v_t[h_off + d] += state.d_att_out[h_off + d] * w

              state.d_w_buf[t] = dw
              sum_w_dw += w * dw

            for t in 0 .. pos:
              let w = state.scores_buf[t]
              let ds = w * (state.d_w_buf[t] - sum_w_dw) * scale
              let k_t = cast[ptr FloatArray](addr state.k_cache[l].data[t * state.hiddenDim])
              let d_k_t = cast[ptr FloatArray](addr state.d_k_cache[l].data[t * state.hiddenDim])
              for d in 0 ..< state.headSize:
                state.d_q[h_off + d] += ds * k_t[h_off + d]
                d_k_t[h_off + d] += ds * q_p[h_off + d]

      let current_d_k = cast[ptr FloatArray](addr state.d_k_cache[l].data[off_dim])
      let current_d_v = cast[ptr FloatArray](addr state.d_v_cache[l].data[off_dim])

      applyRoPE(state.d_q, state.hiddenDim, state.headSize, state.ctxSize, pos, true)
      applyRoPE(current_d_k, state.hiddenDim, state.headSize, state.ctxSize, pos, true)

      let act_norm_att_p = cast[ptr FloatArray](addr state.act_norm_att[l][off_dim])

      matVecMulBackwardAcc(state.w_q[l], state.g_w_q[l], act_norm_att_p, state.d_q, state.d_norm, false)
      matVecMulBackwardAcc(state.w_k[l], state.g_w_k[l], act_norm_att_p, current_d_k, state.d_norm, true)
      matVecMulBackwardAcc(state.w_v[l], state.g_w_v[l], act_norm_att_p, current_d_v, state.d_norm, true)

      let act_hidden_p = cast[ptr FloatArray](addr state.act_hidden[l][off_dim])
      applyRMSNormBackwardAcc(state.d_norm, act_hidden_p, state.hiddenDim, state.rms_att_weights[l], state.g_rms_att_weights[l])
      for d in 0 ..< state.hiddenDim:
        state.d_hidden[d] += state.d_norm[d]

    for d in 0 ..< state.hiddenDim:
      state.g_embeddings.data[tid * state.hiddenDim + d] += state.d_hidden[d] * embFak(state)

  # V11.4: gm hat ueber alle Token im VRAM akkumuliert - einmal pro Step abholen,
  # damit Clipping und Adam auf dem Host denselben Stand sehen.
  template pullGrad(g: Matrix) =
    if useGpuMat(g): gpuSyncToHost(cast[pointer](g.data))

  pullGrad(state.g_w_out)
  for l in 0 ..< state.numLayers:
    pullGrad(state.g_w_q[l])
    pullGrad(state.g_w_k[l])
    pullGrad(state.g_w_v[l])
    pullGrad(state.g_w_o[l])
    pullGrad(state.g_w_up[l])
    pullGrad(state.g_w_down[l])

  let t_upd = epochTime()
  # Clip-Schwelle skaliert mit trainable_count (Summen-Raum ueber bis zu
  # trainable_count Positionen) - Fix vom 18.08. aus dem Hauptzweig, siehe
  # clipfix_20260818_fuer_forks.patch. Der Adam-Skalierer bleibt bewusst das
  # ROHE trainable_count (keine doppelte Normalisierung); max(1.0, ...) ist
  # nur Division-durch-Null-Schutz an der Schwelle.
  let clip_norm = max(1.0'f32, trainable_count.cfloat)
  clipGlobalGradientNorm(state, clip_norm)
  # last_grad_norm haelt nach clipGlobalGradientNorm() die Norm im
  # SUMMEN-Raum - hier auf den Mittelwert-Raum umgerechnet, damit der
  # geloggte Wert direkt gegen 1.0 lesbar ist. Werte vor 2026-08-28 in
  # Altlogs sind Summen-Normen, also grob um trainable_count groesser.
  last_grad_norm = last_grad_norm / clip_norm
  # Loss-Masking: skaliert den akkumulierten Gradienten auf die trainierbaren
  # Positionen statt die volle Fenstergroesse - sonst wuerden Fenster mit viel
  # [USER]-Text (Gradient dort bereits oben auf 0 gesetzt) einen kuenstlich
  # abgeschwaechten Update-Schritt bekommen. scale==0.0 (Fenster komplett ohne
  # trainierbare Position) laesst adamStep() den Schritt bereits sauber
  # ueberspringen (siehe "if scale == 0.0: return" dort).
  applyGlobalAdamUpdate(state, lr, trainable_count.cfloat)
  prof[5] += epochTime() - t_upd
  prof[6] += epochTime() - t_step
  return total_loss / max(1, trainable_count).cfloat

proc cortex_free*(state: ptr CortexState) {.ffi.} =
  if state.isNil: return
  gpuAdamDrop()
  
  template freeM(m) = 
    freeMatrix(m)
    
  template freeA(a) = 
    if not a.isNil: 
      if gpu_initialized: gpuReleaseBuffer(cast[pointer](a))
      deallocShared(a)
      a = nil
      
  template freeHist(p, l) = 
    if not p.isNil:
      for i in 0 ..< l: 
        freeA(p[i])
      deallocShared(p)
      p = nil

  loraFreeAll(state)   # LoRA-Adapter zuerst - eigener Lebenszyklus, eigene Puffer

  freeM(state.logits_cache)
  freeA(state.act_hidden_final)
  freeA(state.act_norm_final)
  freeA(state.d_norm_all)
  freeA(state.d_hidden_all)
  freeA(state.d_att_out_all)
  freeA(state.d_q_all)
  freeA(state.mm_hd_scratch)
  freeA(state.mm_ffn_scratch)
  freeA(state.hidden_state_buf)
  freeA(state.norm_buf)
  freeA(state.att_out_buf)
  freeA(state.ffn_buf)
  freeA(state.d_logits_buf)
  freeA(state.scores_buf)
  freeA(state.d_w_buf)
  freeA(state.q_buf)
  freeA(state.d_hidden)
  freeA(state.d_norm)
  freeA(state.d_att_out)
  freeA(state.d_q)
  freeA(state.d_ffn)
  
  freeHist(state.act_hidden, state.numLayers)
  freeHist(state.act_norm_att, state.numLayers)
  freeHist(state.act_att_out, state.numLayers)
  freeHist(state.act_hidden_ffn, state.numLayers)
  freeHist(state.act_norm_ffn, state.numLayers)
  freeHist(state.act_ffn_in, state.numLayers)
  freeHist(state.act_ffn_out, state.numLayers)
  freeHist(state.dropout_mask, state.numLayers)

  freeHist(state.j_space_cache, state.numLayers)
  
  if not state.act_q.isNil:
    for l in 0 ..< state.numLayers: 
      freeM(state.act_q[l])
      freeM(state.d_k_cache[l])
      freeM(state.d_v_cache[l])
    deallocShared(state.act_q)
    deallocShared(state.d_k_cache)
    deallocShared(state.d_v_cache)
  
  freeM(state.embeddings)
  freeM(state.m_embeddings)
  freeM(state.v_embeddings)
  freeM(state.g_embeddings)
  freeM(state.w_out)
  freeM(state.m_w_out)
  freeM(state.v_w_out)
  freeM(state.g_w_out)
  
  freeA(state.rms_final_weight)
  freeA(state.m_rms_final_weight)
  freeA(state.v_rms_final_weight)
  freeA(state.g_rms_final_weight)
  
  if not state.w_q.isNil:
    for l in 0 ..< state.numLayers:
      freeA(state.rms_att_weights[l])
      freeA(state.m_rms_att_weights[l])
      freeA(state.v_rms_att_weights[l])
      freeA(state.g_rms_att_weights[l])
      freeA(state.rms_ffn_weights[l])
      freeA(state.m_rms_ffn_weights[l])
      freeA(state.v_rms_ffn_weights[l])
      freeA(state.g_rms_ffn_weights[l])
      freeM(state.w_q[l])
      freeM(state.m_w_q[l])
      freeM(state.v_w_q[l])
      freeM(state.g_w_q[l])
      freeM(state.w_k[l])
      freeM(state.m_w_k[l])
      freeM(state.v_w_k[l])
      freeM(state.g_w_k[l])
      freeM(state.w_v[l])
      freeM(state.m_w_v[l])
      freeM(state.v_w_v[l])
      freeM(state.g_w_v[l])
      freeM(state.w_o[l])
      freeM(state.m_w_o[l])
      freeM(state.v_w_o[l])
      freeM(state.g_w_o[l])
      freeM(state.w_up[l])
      freeM(state.m_w_up[l])
      freeM(state.v_w_up[l])
      freeM(state.g_w_up[l])
      freeM(state.w_down[l])
      freeM(state.m_w_down[l])
      freeM(state.v_w_down[l])
      freeM(state.g_w_down[l])
      freeM(state.k_cache[l])
      freeM(state.v_cache[l])
      
    deallocShared(state.rms_att_weights)
    deallocShared(state.m_rms_att_weights)
    deallocShared(state.v_rms_att_weights)
    deallocShared(state.g_rms_att_weights)
    deallocShared(state.rms_ffn_weights)
    deallocShared(state.m_rms_ffn_weights)
    deallocShared(state.v_rms_ffn_weights)
    deallocShared(state.g_rms_ffn_weights)
    deallocShared(state.w_q)
    deallocShared(state.m_w_q)
    deallocShared(state.v_w_q)
    deallocShared(state.g_w_q)
    deallocShared(state.w_k)
    deallocShared(state.m_w_k)
    deallocShared(state.v_w_k)
    deallocShared(state.g_w_k)
    deallocShared(state.w_v)
    deallocShared(state.m_w_v)
    deallocShared(state.v_w_v)
    deallocShared(state.g_w_v)
    deallocShared(state.w_o)
    deallocShared(state.m_w_o)
    deallocShared(state.v_w_o)
    deallocShared(state.g_w_o)
    deallocShared(state.w_up)
    deallocShared(state.m_w_up)
    deallocShared(state.v_w_up)
    deallocShared(state.g_w_up)
    deallocShared(state.w_down)
    deallocShared(state.m_w_down)
    deallocShared(state.v_w_down)
    deallocShared(state.g_w_down)
    deallocShared(state.k_cache)
    deallocShared(state.v_cache)

  # INT8-Q8-Felder (nur belegt wenn weightDtype==1, siehe cortex_quantize_from_fp32()).
  if state.weightDtype == 1:
    # SNAI_V7 / Tying: w_out_q8 teilt sich Daten UND Skalen mit embeddings_q8.
    # Erst embeddings freigeben (setzt dessen Zeiger auf nil) und danach den
    # Alias NICHT anfassen - freeQMatrix() waere dort eine Doppelfreigabe auf
    # denselben Block. Reihenfolge deshalb umgedreht gegenueber dem
    # ungebundenen Fall.
    if state.tiedEmbeddings != 0:
      freeQMatrix(state.embeddings_q8)
      state.w_out_q8.data = nil
      state.w_out_q8.scale = nil
    else:
      freeQMatrix(state.embeddings_q8)
      freeQMatrix(state.w_out_q8)
    if not state.w_q_q8.isNil:
      for l in 0 ..< state.numLayers:
        freeQMatrix(state.w_q_q8[l])
        freeQMatrix(state.w_k_q8[l])
        freeQMatrix(state.w_v_q8[l])
        freeQMatrix(state.w_o_q8[l])
        freeQMatrix(state.w_up_q8[l])
        freeQMatrix(state.w_down_q8[l])
      deallocShared(state.w_q_q8)
      deallocShared(state.w_k_q8)
      deallocShared(state.w_v_q8)
      deallocShared(state.w_o_q8)
      deallocShared(state.w_up_q8)
      deallocShared(state.w_down_q8)
    if not state.i8_qscratch.isNil:
      deallocShared(state.i8_qscratch)
    if not state.i8_qbatch.isNil: deallocShared(state.i8_qbatch)
    if not state.i8_qbatch_scale.isNil: deallocShared(state.i8_qbatch_scale)
    if not state.i8_dscratch.isNil: deallocShared(state.i8_dscratch)
    if not state.i32_dacc.isNil: deallocShared(state.i32_dacc)
    if not state.i8_dbscale.isNil: deallocShared(state.i8_dbscale)
    # SCHRITT 3: quantisierte Momente freigeben
    if state.quantAdam != 0:
      freeQMoment(state.mq_embeddings); freeQMoment(state.vq_embeddings)
      # Bei Tying hat tieEmbeddingsInternal() die w_out-Momente bereits
      # freigegeben UND ihre Zeiger genullt - freeQMoment() ist dann ein No-Op.
      freeQMoment(state.mq_w_out); freeQMoment(state.vq_w_out)
      template freeQL(arr) =
        if not arr.isNil:
          for l in 0 ..< state.numLayers: freeQMoment(arr[l])
          deallocShared(arr)
      freeQL(state.mq_w_q); freeQL(state.vq_w_q)
      freeQL(state.mq_w_k); freeQL(state.vq_w_k)
      freeQL(state.mq_w_v); freeQL(state.vq_w_v)
      freeQL(state.mq_w_o); freeQL(state.vq_w_o)
      freeQL(state.mq_w_up); freeQL(state.vq_w_up)
      freeQL(state.mq_w_down); freeQL(state.vq_w_down)
    if not state.silu_lut.isNil: deallocShared(state.silu_lut)
    if not state.silu_exp.isNil:
      for l in 0 ..< state.numLayers: deallocShared(state.silu_exp[l])
      deallocShared(state.silu_exp)
    if not state.silu_exp_ok.isNil: deallocShared(state.silu_exp_ok)
    if state.quantActsIn != 0 and not state.act_ffn_in_q8.isNil:
      for l in 0 ..< state.numLayers: freeQMatrix(state.act_ffn_in_q8[l])
      deallocShared(state.act_ffn_in_q8)
    if state.quantActs != 0:
      if not state.act_ffn_out_q8.isNil:
        for l in 0 ..< state.numLayers: freeQMatrix(state.act_ffn_out_q8[l])
        deallocShared(state.act_ffn_out_q8)
      if not state.act_ffn_scratch.isNil: deallocShared(state.act_ffn_scratch)
    if not state.i8_gqi.isNil: deallocShared(state.i8_gqi)
    if not state.i8_gdscale.isNil: deallocShared(state.i8_gdscale)
    if not state.i8_giscale.isNil: deallocShared(state.i8_giscale)
    if not state.k_cache_q8.isNil:
      for l in 0 ..< state.numLayers:
        freeQMatrix(state.k_cache_q8[l])
        freeQMatrix(state.v_cache_q8[l])
      deallocShared(state.k_cache_q8)
      deallocShared(state.v_cache_q8)
    if not state.kv_raw_buf.isNil:
      deallocShared(state.kv_raw_buf)
    freeI8ErrorFeedback(state)

  if not state.ffnAus.isNil:   # FFN-SKIP
    deallocShared(state.ffnAus)
    state.ffnAus = nil
  deallocShared(state)

# ==============================================================================
# FFI EXPORT: STREAM LOADER (V11.2 - SELF-VERIFYING)
# ------------------------------------------------------------------------------
# Layout-Annahme: [Header][ pro Tensor: W | m | v ][ optional int32 adam_t ]
# Diese Annahme wird VOR dem Laden ueber die Byte-Bilanz der Datei geprueft
# und NACH dem Laden ueber die harte Invariante v >= 0 bewiesen.
# Kein stilles Laden von Muell mehr: jeder Fehler gibt nil + Fehlercode zurueck.
# ==============================================================================

type
  ModelHeader {.packed.} = object
    magic: array[8, char]
    vocab_size: uint32
    hidden_dim: uint32
    ffn_dim: uint32
    ctx_size: uint32
    num_layers: uint32

const
  LOAD_OK          = 0.cint   # alles sauber
  LOAD_ERR_OPEN    = 1.cint   # Datei nicht oeffenbar
  LOAD_ERR_HEADER  = 2.cint   # Header unvollstaendig
  LOAD_ERR_MAGIC   = 3.cint   # kein SNAI_V5
  LOAD_ERR_SANITY  = 4.cint   # Header-Werte unplausibel
  LOAD_ERR_INIT    = 5.cint   # cortex_init fehlgeschlagen
  LOAD_ERR_SIZE    = 6.cint   # Dateigroesse passt zu keinem bekannten Layout
  LOAD_ERR_TRUNC   = 7.cint   # Datei bricht mittendrin ab
  LOAD_ERR_LAYOUT  = 8.cint   # v-Tensor negativ -> Reihenfolge im File anders
  LOAD_ERR_NAN     = 9.cint   # NaN/Inf in den Gewichten

var last_load_error: cint = LOAD_OK

proc cortex_get_load_error*(): cint {.ffi.} =
  return last_load_error

# Stichprobenscan: NaN/Inf immer, Negativwerte optional (fuer v-Tensoren)
proc scanBad(p: ptr FloatArray, n: int, mustBePositive: bool): bool =
  if p.isNil or n <= 0: return false
  let step = max(1, n div 8192)
  var i = 0
  while i < n:
    let x = p[i]
    if x.isNaN or x > 1e30 or x < -1e30: return true
    if mustBePositive and x < 0.0: return true
    i += step
  return false

proc isAllZero(p: ptr FloatArray, n: int): bool =
  if p.isNil or n <= 0: return true
  let step = max(1, n div 8192)
  var i = 0
  while i < n:
    if p[i] != 0.0: return false
    i += step
  return true

# Gesundheitscheck fuer einen State im Speicher. Bitmaske:
#   1 = tote Gain-Kanaele   2 = NaN/Inf in Gewichten   4 = adam_t 0 trotz warmem m/v
# 0 = sauber, -1 = kein State.
proc cortex_validate*(s: ptr CortexState): cint {.ffi.} =
  if s.isNil: return -1
  # SPEICHER-AUDIT 2026-08-19: auf einem INT8-State sind die hier geprueften
  # FP32-Gewichtsfelder freigegeben (nil) - scanBad() wuerde in einen
  # Nullzeiger laufen. cortex_validate_i8() ist die zustaendige Pruefung.
  if s.weightDtype == 1: return cortex_validate_i8(s)
  var flags: cint = 0

  if deadTailStart(s.rms_final_weight, s.hiddenDim) >= 0: flags = flags or 1
  for l in 0 ..< s.numLayers:
    if deadTailStart(s.rms_att_weights[l], s.hiddenDim) >= 0: flags = flags or 1
    if deadTailStart(s.rms_ffn_weights[l], s.hiddenDim) >= 0: flags = flags or 1

  let embSize = s.vocabSize.int * s.hiddenDim.int
  if scanBad(s.embeddings.data, embSize, false) or
     scanBad(s.w_out.data, embSize, false) or
     gainsNichtEndlich(s): flags = flags or 2

  if s.adam_t <= 0 and not isAllZero(s.v_embeddings.data, embSize): flags = flags or 4
  return flags

# Misst die reine Roundtrip-Latenz eines GPU-Calls in Millisekunden.
# Damit laesst sich die Schwelle oben empirisch statt geschaetzt setzen:
# lohnend ist die GPU ab etwa (Latenz_in_ms * 1e6) Elementen.
proc cortex_bench_gpu*(state: ptr CortexState, iters: cint): cfloat {.ffi.} =
  if state.isNil or not gpu_initialized or iters <= 0: return -1.0
  let d = state.hiddenDim
  let m = cast[ptr cfloat](state.w_q[0].data)
  let i_v = cast[ptr cfloat](state.norm_buf)
  let o_v = cast[ptr cfloat](state.d_norm)
  gpuMatVecMul(m, i_v, o_v, d, d)          # Aufwaermen: Buffer anlegen
  let t0 = epochTime()
  for _ in 0 ..< iters:
    gpuMatVecMul(m, i_v, o_v, d, d)
  return (((epochTime() - t0) * 1000.0) / iters.float).cfloat

proc cortex_load_stream*(filepath_c: cstring, num_heads: cint): ptr CortexState {.ffi.} =
  last_load_error = LOAD_OK
  let filepath = $filepath_c
  var f: File
  if not open(f, filepath, fmRead):
    last_load_error = LOAD_ERR_OPEN
    return nil

  var header: ModelHeader
  if f.readBuffer(addr header, sizeof(ModelHeader)) != sizeof(ModelHeader):
    last_load_error = LOAD_ERR_HEADER
    f.close()
    return nil

  var magicStr = ""
  for c in header.magic:
    if c != '\0': magicStr.add(c)

  if magicStr != "SNAI_V5":
    last_load_error = LOAD_ERR_MAGIC
    stderr.writeLine("[cortex] FATAL: Magic '", magicStr, "' != 'SNAI_V5'.")
    f.close()
    return nil

  let
    nVocab  = header.vocab_size.int
    nDim    = header.hidden_dim.int
    nFfn    = header.ffn_dim.int
    nCtx    = header.ctx_size.int
    nLayers = header.num_layers.int

  # AUDIT-FIX V11.2: ffn_dim und ctx_size wurden vorher NICHT geprueft.
  if nVocab  < 1 or nVocab  > 4_000_000 or
     nDim    < 2 or nDim    > 65_536 or
     nFfn    < 1 or nFfn    > 262_144 or
     nCtx    < 1 or nCtx    > 1_048_576 or
     nLayers < 1 or nLayers > 512:
    last_load_error = LOAD_ERR_SANITY
    stderr.writeLine("[cortex] FATAL: Header unplausibel (V=", $nVocab, " D=", $nDim,
                     " F=", $nFfn, " C=", $nCtx, " L=", $nLayers, ").")
    f.close()
    return nil

  # --- BYTE-BILANZ: erwartete Nutzlast exakt ausrechnen ---
  let embSize = nVocab * nDim
  let dim2    = nDim * nDim
  let ffnSize = nFfn * nDim

  let elemsPerLayer = 2*nDim + 4*dim2 + 2*ffnSize
  let elemsTotal    = 2*embSize + nDim + nLayers*elemsPerLayer
  let wBytes        = elemsTotal.int64 * sizeof(cfloat).int64
  let payload       = f.getFileSize() - sizeof(ModelHeader).int64

  var withAdam = false   # Datei enthaelt m und v
  var withT    = false   # Datei enthaelt adam_t als int32-Trailer

  if payload == wBytes * 3:
    withAdam = true
  elif payload == wBytes * 3 + 4:
    withAdam = true
    withT = true
  elif payload == wBytes:
    discard
  elif payload == wBytes + 4:
    withT = true
  else:
    last_load_error = LOAD_ERR_SIZE
    stderr.writeLine("[cortex] FATAL: Groessen-Mismatch. Payload=", $payload,
                     " B. Erwartet: ", $wBytes, " (nur W) oder ", $(wBytes*3),
                     " (W+m+v). Delta zu W+m+v: ", $(payload - wBytes*3), " B.")
    f.close()
    return nil

  let s = cortex_init(nVocab.cint, nDim.cint, nFfn.cint, nCtx.cint, nLayers.cint, num_heads)
  if s.isNil:
    last_load_error = LOAD_ERR_INIT
    f.close()
    return nil

  # AUDIT-FIX V11.2: jeder Abbruch gibt jetzt auch den State frei (vorher: Leak).
  template rd(dest: pointer, count: int) =
    let need = count * sizeof(cfloat)
    if f.readBuffer(dest, need) != need:
      last_load_error = LOAD_ERR_TRUNC
      stderr.writeLine("[cortex] FATAL: Datei bricht ab (", $count, " Floats erwartet).")
      f.close()
      cortex_free(s)
      return nil

  template blast(pw, pm, pv: pointer, count: int) =
    rd(pw, count)
    if withAdam:
      rd(pm, count)
      rd(pv, count)

  # SCHRITT 3 (Speicherumbau): sind die Momente quantisiert, sind die
  # float32-Felder nil - direkt hineinzulesen wuerde segfaulten (genau das ist
  # beim ersten Testlauf passiert). Stattdessen ueber einen Scratch lesen und
  # zeilenweise kodieren. Der Scratch wird nur allokiert, wenn er gebraucht
  # wird, und deckt den groessten Tensor ab.
  var qScratch: ptr FloatArray = nil
  if s.quantAdam != 0 and withAdam:
    let maxElems = max(embSize, max(dim2, ffnSize))
    qScratch = cast[ptr FloatArray](allocShared0(maxElems * sizeof(cfloat)))

  template blastQ(pw: pointer, mf, vf: Matrix, mqp, vqp: ptr QMoment, count: int) =
    rd(pw, count)
    if withAdam:
      if s.quantAdam != 0 and not mqp.isNil and not mqp.data.isNil:
        rd(qScratch, count)
        for r in 0 ..< mqp.rows.int: qmomStoreRow(mqp[], r, qScratch, r * mqp.cols.int, true)
        rd(qScratch, count)
        for r in 0 ..< vqp.rows.int: qmomStoreRow(vqp[], r, qScratch, r * vqp.cols.int, false)
      else:
        rd(mf.data, count)
        rd(vf.data, count)

  # --- GLOBALE TENSOREN ---
  blastQ(s.embeddings.data, s.m_embeddings, s.v_embeddings, addr s.mq_embeddings, addr s.vq_embeddings, embSize)
  blastQ(s.w_out.data, s.m_w_out, s.v_w_out, addr s.mq_w_out, addr s.vq_w_out, embSize)
  blast(s.rms_final_weight, s.m_rms_final_weight, s.v_rms_final_weight, nDim)

  # --- LAYER TENSOREN ---
  for l in 0 ..< nLayers:
    blast(s.rms_att_weights[l], s.m_rms_att_weights[l], s.v_rms_att_weights[l], nDim)
    blast(s.rms_ffn_weights[l], s.m_rms_ffn_weights[l], s.v_rms_ffn_weights[l], nDim)

    blastQ(s.w_q[l].data, s.m_w_q[l], s.v_w_q[l], (if s.mq_w_q.isNil: nil else: addr s.mq_w_q[l]), (if s.vq_w_q.isNil: nil else: addr s.vq_w_q[l]), dim2)
    blastQ(s.w_k[l].data, s.m_w_k[l], s.v_w_k[l], (if s.mq_w_k.isNil: nil else: addr s.mq_w_k[l]), (if s.vq_w_k.isNil: nil else: addr s.vq_w_k[l]), dim2)
    blastQ(s.w_v[l].data, s.m_w_v[l], s.v_w_v[l], (if s.mq_w_v.isNil: nil else: addr s.mq_w_v[l]), (if s.vq_w_v.isNil: nil else: addr s.vq_w_v[l]), dim2)
    blastQ(s.w_o[l].data, s.m_w_o[l], s.v_w_o[l], (if s.mq_w_o.isNil: nil else: addr s.mq_w_o[l]), (if s.vq_w_o.isNil: nil else: addr s.vq_w_o[l]), dim2)

    blastQ(s.w_up[l].data, s.m_w_up[l], s.v_w_up[l], (if s.mq_w_up.isNil: nil else: addr s.mq_w_up[l]), (if s.vq_w_up.isNil: nil else: addr s.vq_w_up[l]), ffnSize)
    blastQ(s.w_down[l].data, s.m_w_down[l], s.v_w_down[l], (if s.mq_w_down.isNil: nil else: addr s.mq_w_down[l]), (if s.vq_w_down.isNil: nil else: addr s.vq_w_down[l]), ffnSize)

  if not qScratch.isNil: deallocShared(qScratch)

  if withT:
    var tRaw: int32 = 0
    if f.readBuffer(addr tRaw, 4) != 4:
      last_load_error = LOAD_ERR_TRUNC
      f.close()
      cortex_free(s)
      return nil
    s.adam_t = tRaw.cint

  f.close()

  # --- POST-CHECK 1: LAYOUT-BEWEIS -------------------------------------------
  # v ist das zweite Moment (Summe von Quadraten) und kann mathematisch
  # NIEMALS negativ sein. Negative Werte = die Datei liegt anders im Speicher
  # als hier gelesen. Das faengt genau den Fehler, den du befuerchtet hast.
  if withAdam:
    var layoutBroken = scanBad(s.v_embeddings.data, embSize, true) or
                       scanBad(s.v_w_out.data, embSize, true) or
                       scanBad(s.v_rms_final_weight, nDim, true)
    if not layoutBroken:
      for l in 0 ..< nLayers:
        if scanBad(s.v_w_q[l].data, dim2, true) or
           scanBad(s.v_w_o[l].data, dim2, true) or
           scanBad(s.v_w_down[l].data, ffnSize, true):
          layoutBroken = true
          break
    if layoutBroken:
      last_load_error = LOAD_ERR_LAYOUT
      stderr.writeLine("[cortex] FATAL: v-Tensor enthaelt negative Werte. Das File-Layout ",
                       "ist NICHT [W|m|v] pro Tensor. Writer-Seite pruefen.")
      cortex_free(s)
      return nil

  # --- POST-CHECK 2: NaN/Inf in den Gewichten --------------------------------
  if scanBad(s.embeddings.data, embSize, false) or
     scanBad(s.w_out.data, embSize, false) or
     gainsNichtEndlich(s):
    last_load_error = LOAD_ERR_NAN
    stderr.writeLine("[cortex] FATAL: NaN/Inf in den geladenen Gewichten.")
    cortex_free(s)
    return nil

  # --- POST-CHECK 3: ADAM-ZEITSCHRITT ----------------------------------------
  # KORREKTUR V11.2b: adam_t = 0 auf warmem m/v sprengt NICHTS, es bremst.
  #   t=1: m_hat = m/0.1 = 10m, v_hat = v/0.001 = 1000v -> sqrt = 31.6*sqrt(v)
  #        Schrittweite = 0.32x der eingeschwungenen Groesse, nicht 10x.
  #   Der Schaden ist ein ungewollter Re-Warmup ueber ~1000 Steps nach JEDEM
  #   Resume - schleichend, nicht explosiv. Trotzdem falsch.
  # Wichtig: nur bei WARMEM Adam-Zustand neutralisieren. Bei m = v = 0
  # (echter Cold Start) ist die Bias-Correction korrekt; adam_t = 1000 wuerde
  # den ersten Schritt dort um Faktor ~3.2 zu gross machen.
  if withAdam and s.adam_t <= 0:
    if isAllZero(s.v_embeddings.data, embSize):
      stderr.writeLine("[cortex] INFO: m/v sind leer -> Cold Start, adam_t bleibt 0.")
    else:
      s.adam_t = 1000
      stderr.writeLine("[cortex] WARN: adam_t fehlt im Checkpoint, m/v sind aber warm ",
                       "-> adam_t = 1000 (Bias-Correction neutralisiert). ",
                       "Besser: adam_t writer-seitig persistieren.")

  # --- POST-CHECK 4: NET2NET GAIN GUARD --------------------------------------
  # Faengt Checkpoints ab, die schon mit toten Kanaelen auf die Platte kamen.
  checkGains(cast[ptr cfloat](s.rms_final_weight), s.hiddenDim, "rms_final")
  for l in 0 ..< s.numLayers:
    checkGains(cast[ptr cfloat](s.rms_att_weights[l]), s.hiddenDim,
               "L" & $l & ".rms_att")
    checkGains(cast[ptr cfloat](s.rms_ffn_weights[l]), s.hiddenDim,
               "L" & $l & ".rms_ffn")

  return s

# ==============================================================================
# PHASE 6 DES INT8-UMBAUS
# Natives Laden einer SNAI_V6-Datei DIREKT in INT8 (QMatrix-Felder), ohne den
# Umweg ueber einen FP32-Zwischenstand (anders als cortex_quantize_from_fp32(),
# das einen bereits per cortex_load_stream() geladenen FP32-State
# konvertiert). Der fehlende Baustein aus Phase 5 fuer echte INT8-Inferenz/
# Held-out-Eval auf einem bereits INT8 trainierten Checkpoint
# (save_model_stream_i8()). Layout-Spiegelbild von save_model_stream_i8()
# (tensor_io.php): pro quantisierbarem Tensor [Skalen-Block][INT8-Daten][m:
# Float32][v: Float32], bei rms_* [w: Float32][m: Float32][v: Float32].
# ==============================================================================

proc cortex_load_stream_i8*(filepath_c: cstring, num_heads: cint): ptr CortexState {.ffi.} =
  last_load_error = LOAD_OK
  let filepath = $filepath_c
  var f: File
  if not open(f, filepath, fmRead):
    last_load_error = LOAD_ERR_OPEN
    return nil

  var header: ModelHeader
  if f.readBuffer(addr header, sizeof(ModelHeader)) != sizeof(ModelHeader):
    last_load_error = LOAD_ERR_HEADER
    f.close()
    return nil
  var dtypeVersion: int32 = 0
  if f.readBuffer(addr dtypeVersion, 4) != 4:
    last_load_error = LOAD_ERR_HEADER
    f.close()
    return nil

  var magicStr = ""
  for c in header.magic:
    if c != '\0': magicStr.add(c)
  if magicStr != "SNAI_V6" and magicStr != "SNAI_V7":
    last_load_error = LOAD_ERR_MAGIC
    stderr.writeLine("[cortex] FATAL: Magic '", magicStr, "' != 'SNAI_V6'/'SNAI_V7'.")
    f.close()
    return nil

  # SNAI_V7 haengt hinter dtype_version ein 4-Byte-Flags-Feld an (Header also
  # 36 statt 32 Byte). Bit 0 = Weight Tying: der w_out-Block FEHLT dann
  # vollstaendig in der Datei.
  var fileFlags: int32 = 0
  let isV7 = (magicStr == "SNAI_V7")
  if isV7:
    if f.readBuffer(addr fileFlags, 4) != 4:
      last_load_error = LOAD_ERR_HEADER
      f.close()
      return nil
  let wantTied = (fileFlags and 1'i32) != 0
  # EMB-EINGANG: Bit 1 = Embedding-Eingangsfaktor. Unbekannte Bits und Bit 1 ohne Bindung abweisen - ein Lader,
  # der ein Bit nicht versteht, darf das Modell nicht still anders rechnen.
  let wantEmbEin = (fileFlags and 2'i32) != 0
  if (fileFlags and not 3'i32) != 0 or (wantEmbEin and not wantTied):
    last_load_error = LOAD_ERR_HEADER
    stderr.writeLine("[cortex] FATAL: SNAI_V7 Flags=", $fileFlags, " - unbekannte Bits oder Bit 1 ohne Bit 0.")
    f.close()
    return nil
  let headerBytes = (if isV7: sizeof(ModelHeader).int64 + 8 else: sizeof(ModelHeader).int64 + 4)

  let
    nVocab  = header.vocab_size.int
    nDim    = header.hidden_dim.int
    nFfn    = header.ffn_dim.int
    nCtx    = header.ctx_size.int
    nLayers = header.num_layers.int

  if nVocab  < 1 or nVocab  > 4_000_000 or
     nDim    < 2 or nDim    > 65_536 or
     nFfn    < 1 or nFfn    > 262_144 or
     nCtx    < 1 or nCtx    > 1_048_576 or
     nLayers < 1 or nLayers > 512:
    last_load_error = LOAD_ERR_SANITY
    f.close()
    return nil

  if not checkI8AccumRange(nDim.cint, nFfn.cint):
    last_load_error = LOAD_ERR_SANITY
    f.close()
    return nil

  # --- BYTE-BILANZ: unterscheidet save_model_stream_i8() (MIT Adam-Zustand +
  # 4-Byte-Trailer) von export_int8_deployment() (NUR Gewichte, kein Trailer)
  # - dasselbe Prinzip wie im V5-Loader oben, nur fuer das INT8-Layout
  # ([Skalen-Block][INT8-Daten] statt reinem Float32 je quantisierbarem
  # Tensor). Beide Faelle sind die einzigen, die die beiden tatsaechlichen
  # V6-Writer in tensor_io.php produzieren - kein 4-Wege-Fall wie bei V5
  # noetig (dessen Historie mehr Schreiber-Varianten kennt).
  let embSize = nVocab * nDim
  let dim2 = nDim * nDim
  let ffnSize = nFfn * nDim
  const fBytes = sizeof(cfloat).int64

  proc q8Bytes(rows, totalElems: int): int64 =
    2.int64 + rows.int64 * fBytes + totalElems.int64

  let embQBytes = q8Bytes(nVocab, embSize)
  let qkvQBytes = q8Bytes(nDim, dim2)
  let upQBytes = q8Bytes(nFfn, ffnSize)
  let downQBytes = q8Bytes(nDim, ffnSize)
  let rmsBytes = nDim.int64 * fBytes

  # SNAI_V7/Tying: embeddings und w_out sind dasselbe Gewicht, in der Datei
  # steht es genau EINMAL. Der Faktor am Embedding-Block ist deshalb die
  # einzige Stelle, an der sich die Bilanz zwischen gebunden und ungebunden
  # unterscheidet - hier und beim Adam-Anteil unten.
  let embBlocks = (if wantTied: 1'i64 else: 2'i64)

  let payloadNoAdam = (embQBytes * embBlocks) + rmsBytes +
    nLayers.int64 * (rmsBytes * 2 + qkvQBytes * 4 + upQBytes + downQBytes)

  let embMV = embSize.int64 * fBytes * 2
  let rmsMV = nDim.int64 * fBytes * 2
  let qkvMV = dim2.int64 * fBytes * 2
  let upMV = ffnSize.int64 * fBytes * 2
  let downMV = ffnSize.int64 * fBytes * 2

  let payloadWithAdam = payloadNoAdam + (embMV * embBlocks) + rmsMV +
    nLayers.int64 * (rmsMV * 2 + qkvMV * 4 + upMV + downMV)

  let actualPayload = f.getFileSize() - headerBytes
  var withAdam = false
  if actualPayload == payloadWithAdam + 4:
    withAdam = true
  elif actualPayload == payloadNoAdam:
    withAdam = false
  else:
    last_load_error = LOAD_ERR_SIZE
    stderr.writeLine("[cortex] FATAL: ", magicStr, " Groessen-Mismatch. Payload=", $actualPayload,
                     " B. Erwartet: ", $payloadNoAdam, " (nur Gewichte) oder ",
                     $(payloadWithAdam + 4), " (+Adam+Trailer).")
    f.close()
    return nil

  # SPEICHER-AUDIT 2026-08-19: die FP32-Gewichtsmatrizen werden auf diesem Pfad
  # nie befuellt (alles kommt quantisiert aus der Datei) und nie gelesen - gar
  # nicht erst allozieren. Bei einem reinen Inferenz-Artefakt (kein Adam-Block,
  # siehe export_int8_deployment()) gilt dasselbe fuer m/v/g.
  init_skip_fp32_weights = true
  # LoRA-SPEICHERARM: ist der Vorlade-Schalter gesetzt, wird der Adam-Zustand
  # der Basis gar nicht erst alloziert - auch dann nicht, wenn die Datei einen
  # mitbringt. Die Bytes werden weiter unten in rdAdamQ ueberSPRUNGEN, nicht
  # ignoriert; sonst verrutschte alles Folgende.
  # init_skip_backward_buffers bleibt hier bewusst UNBERUEHRT: gelernt wird ja
  # weiterhin, nur eben nur an den Adaptern.
  let skipBaseAdam = lora_preload_skip_base_adam and withAdam
  init_skip_adam_state = (not withAdam) or skipBaseAdam
  # Zweite Audit-Runde: der INT8-Pfad rechnet ausschliesslich auf
  # k_cache_q8/v_cache_q8 - die FP32-Zwillinge sind hier immer tot. Die
  # Backward-Puffer fallen zusaetzlich weg, sobald die Datei keinen
  # Adam-Zustand mitbringt (= reines Inferenz-Artefakt; cortex_train_step_i8()
  # verweigert auf so einem State ohnehin bereits den Dienst).
  init_skip_fp32_kv = true
  init_skip_backward_buffers = not withAdam
  let s = cortex_init(nVocab.cint, nDim.cint, nFfn.cint, nCtx.cint, nLayers.cint, num_heads)
  init_skip_fp32_weights = false
  init_skip_adam_state = false
  init_skip_fp32_kv = false
  init_skip_backward_buffers = false
  if s.isNil:
    last_load_error = LOAD_ERR_INIT
    f.close()
    return nil

  # Q8-Infrastruktur wie cortex_quantize_from_fp32() allokieren (kein FP32-
  # Ausgangswert - wird direkt aus der Datei befuellt).
  s.embeddings_q8 = allocQMatrix(nVocab.cint, nDim.cint)
  s.w_out_q8 = allocQMatrix(nVocab.cint, nDim.cint)
  s.w_q_q8 = cast[ptr QMatrixArray](allocShared0(nLayers * sizeof(QMatrix)))
  s.w_k_q8 = cast[ptr QMatrixArray](allocShared0(nLayers * sizeof(QMatrix)))
  s.w_v_q8 = cast[ptr QMatrixArray](allocShared0(nLayers * sizeof(QMatrix)))
  s.w_o_q8 = cast[ptr QMatrixArray](allocShared0(nLayers * sizeof(QMatrix)))
  s.w_up_q8 = cast[ptr QMatrixArray](allocShared0(nLayers * sizeof(QMatrix)))
  s.w_down_q8 = cast[ptr QMatrixArray](allocShared0(nLayers * sizeof(QMatrix)))
  for l in 0 ..< nLayers:
    s.w_q_q8[l] = allocQMatrix(nDim.cint, nDim.cint)
    s.w_k_q8[l] = allocQMatrix(nDim.cint, nDim.cint)
    s.w_v_q8[l] = allocQMatrix(nDim.cint, nDim.cint)
    s.w_o_q8[l] = allocQMatrix(nDim.cint, nDim.cint)
    s.w_up_q8[l] = allocQMatrix(nFfn.cint, nDim.cint)
    s.w_down_q8[l] = allocQMatrix(nDim.cint, nFfn.cint)
  let scratchSize = max(nDim, nFfn)
  s.i8_qscratch = cast[ptr Int8Array](allocShared0(scratchSize * sizeof(int8)))
  # Batch-Puffer nur fuer Training noetig (gebuendelter Pfad) - bei einem
  # reinen Inferenz-Artefakt gespart.
  if withAdam:
    s.i8_qbatch = cast[ptr Int8Array](allocShared0(nCtx * scratchSize * sizeof(int8)))
    s.i8_qbatch_scale = cast[ptr FloatArray](allocShared0(nCtx * sizeof(cfloat)))
    # SCHRITT 1b-FIX: fehlte hier komplett. Ohne diese Zeile blieben die
    # Backward-Scratchpuffer bei einem AUS DER DATEI geladenen V6-Modell
    # (fortgesetztes Mehrepochen-Training) nil - der Ganzzahl-Backward waere
    # dort still auf den Float-Pfad zurueckgefallen, ohne jede Meldung.
    allocI8BackwardScratch(s, max(scratchSize, nVocab), scratchSize)
  s.k_cache_q8 = cast[ptr QMatrixArray](allocShared0(nLayers * sizeof(QMatrix)))
  s.v_cache_q8 = cast[ptr QMatrixArray](allocShared0(nLayers * sizeof(QMatrix)))
  for l in 0 ..< nLayers:
    s.k_cache_q8[l] = allocQMatrix(nCtx.cint, nDim.cint)
    s.v_cache_q8[l] = allocQMatrix(nCtx.cint, nDim.cint)
  s.kv_raw_buf = cast[ptr FloatArray](allocShared0(nDim * sizeof(cfloat)))

  # BUGFIX (Audit 2026-08-19): weightDtype MUSS frueh stehen, nicht erst am
  # Ende der Funktion. cortex_free() gibt die Q8-Felder nur frei, wenn
  # weightDtype == 1 - stand es beim Aufruf von failLoad() (Datei bricht ab,
  # Skalen-Block-Mismatch, ...) noch auf 0, wurden ALLE oben allokierten
  # INT8-Puffer inkl. der beiden ctx*dim grossen KV-Caches je Layer geleakt.
  # Betraf jeden fehlgeschlagenen Ladeversuch einer beschaedigten V6-Datei.
  #
  # 2026-08-29 noch ein Stueck weiter nach vorn gezogen (war: direkt nach
  # allocI8ErrorFeedback): tieEmbeddingsInternal() verlangt weightDtype == 1,
  # und die Bindung muss VOR allocI8ErrorFeedback() stehen, damit dort der
  # ueberfluessige zweite Rest-Puffer gar nicht erst entsteht. Frueher setzen
  # ist gegenueber dem Leck-Fix strikt sicherer, nie schwaecher.
  s.weightDtype = 1

  # SNAI_V7: Bindung herstellen, BEVOR Rest-Puffer und Lesereihenfolge davon
  # abhaengen. Gibt den gerade allokierten eigenen w_out-Speicher (int8-Daten,
  # Skalen, m/v) wieder frei - der Umweg ueber "allozieren und sofort
  # freigeben" ist bewusst in Kauf genommen, damit die Allokationsliste oben
  # eine einzige, geradlinige Fassung bleibt und nicht an zwei Stellen nach
  # Flags verzweigt.
  if wantTied:
    tieEmbeddingsInternal(s)
    if cortex_get_tied_embeddings(s) == 0:
      last_load_error = LOAD_ERR_INIT
      stderr.writeLine("[cortex] FATAL: SNAI_V7 verlangt Weight Tying, die Bindung ",
                       "kam aber nicht zustande.")
      f.close()
      cortex_free(s)
      return nil
  # EMB-EINGANG: das Bit gehoert zum Modell - immer uebernehmen, unabhaengig von jeder Umgebungsvariable.
  if wantEmbEin:
    if cortex_set_emb_eingang(s, 1) != 1:
      last_load_error = LOAD_ERR_INIT
      stderr.writeLine("[cortex] FATAL: SNAI_V7 Bit 1 (Embedding-Eingangsfaktor) liess sich nicht setzen.")
      f.close()
      cortex_free(s)
      return nil
    # Fester Wortlaut, auf stderr (mess_text.php liest stdout als JSON): multi_stack prueft an dieser Zeile, ob das
    # Bit ein Neuschreiben ueberlebt hat. Ohne Bit erscheint sie nicht.
    let fT = int64(round(s.embEinF.float64 * 10000.0))
    stderr.writeLine("[EMBEIN] Faktor ", $(fT div 10000), ".", ($(10000 + fT mod 10000))[1 .. 4],
                     " aus Modell-Flag (bit1)")

  # Fehler-Rueckfuehrung auch beim FORTGESETZTEN INT8-Training (Basismodell ist
  # bereits SNAI_V6). Der Rest selbst wird bewusst NICHT mitgespeichert: er ist
  # betragsmaessig hoechstens ein halbes LSB, das Format bliebe sonst nicht
  # abwaertskompatibel, und ein Neustart bei 0 kostet genau einen Schritt
  # Kompensation - nicht den ueber tausende Schritte aufgebauten Effekt.
  # LoRA-Speicherarm: ohne Requantisierung der Basis gibt es keinen
  # Rundungsrest zurueckzufuehren - die Rest-Puffer waeren reiner Ballast
  # (dieselbe Groesse wie die Gewichte selbst).
  if skipBaseAdam:
    s.baseOptFreed = 1
    # Die RMSNorm-Momente kommen ZURUECK. init_skip_adam_state nilt sie mit,
    # aber sie werden im LoRA-Backward weiterhin gebraucht:
    # applyRMSNormBackwardAcc() schreibt in g_rms_*, und zeroArr() nullt sie zu
    # Beginn jedes Schritts. Ein nil dort ist ein sofortiger Absturz - genau der
    # SIGSEGV, mit dem der erste Versuch dieses Speicherarms endete.
    # Der Preis ist vernachlaessigbar: Vektoren der Laenge dim, unter 0,1% des
    # Adam-Speichers. Deshalb laesst auch loraFreeBaseOptState() sie stehen -
    # beide Wege kommen so zum selben Zustand.
    template reAlloc(a: untyped) =
      if a.isNil:
        a = cast[ptr FloatArray](allocShared0(nDim * sizeof(cfloat)))
    reAlloc(s.m_rms_final_weight); reAlloc(s.v_rms_final_weight); reAlloc(s.g_rms_final_weight)
    for l in 0 ..< nLayers:
      reAlloc(s.m_rms_att_weights[l]); reAlloc(s.v_rms_att_weights[l]); reAlloc(s.g_rms_att_weights[l])
      reAlloc(s.m_rms_ffn_weights[l]); reAlloc(s.v_rms_ffn_weights[l]); reAlloc(s.g_rms_ffn_weights[l])
  else:
    allocI8ErrorFeedback(s)

  # (FP32-Gewichte und ggf. Adam-Zustand wurden oben schon gar nicht erst
  # alloziert - siehe init_skip_*-Flags beim cortex_init()-Aufruf.
  # s.weightDtype = 1 und die Tying-Bindung stehen weiter oben, direkt nach den
  # Q8-Allokationen - Begruendung im Kommentar dort.)

  # Vor failLoad deklariert, damit der Fehlerpfad ihn mitfreigeben kann -
  # sonst leckt jeder Abbruch diesen Puffer (dieselbe Fehlerklasse wie das im
  # Audit vom 2026-08-19 behobene weightDtype-Leck).
  var qScratch: ptr FloatArray = nil

  template failLoad(err: cint) =
    last_load_error = err
    f.close()
    if not qScratch.isNil: deallocShared(qScratch)
    cortex_free(s)
    return nil

  # [Skalen-Block][INT8-Daten] in eine bestehende QMatrix lesen.
  template rdQ(qm: QMatrix) =
    var cnt: uint16 = 0
    if f.readBuffer(addr cnt, 2) != 2: failLoad(LOAD_ERR_TRUNC)
    if cnt.int != qm.rows.int: failLoad(LOAD_ERR_SIZE)
    let scaleBytes = cnt.int * sizeof(cfloat)
    if f.readBuffer(qm.scale, scaleBytes) != scaleBytes: failLoad(LOAD_ERR_TRUNC)
    let dataBytes = qm.rows.int * qm.cols.int * sizeof(int8)
    if f.readBuffer(qm.data, dataBytes) != dataBytes: failLoad(LOAD_ERR_TRUNC)

  # Reine Float32-Bloecke (rms_*, und m/v fuer JEDEN Tensor - Design-
  # Entscheidung #2, immer FP32 unabhaengig vom Gewichts-dtype).
  template rdF(dest: pointer, count: int) =
    let need = count * sizeof(cfloat)
    if f.readBuffer(dest, need) != need: failLoad(LOAD_ERR_TRUNC)

  # PUNKT 3 (2026-08-24): Scratch fuer den Speicherumbau der Adam-Momente.
  # Liegen sie quantisiert vor (Schritt 3), ist m_*.data/v_*.data legitim nil -
  # ein Direktlesen dorthin ist ein SIGSEGV. Die Datei bleibt float32 (bewusste
  # Formatentscheidung, siehe cortex_extract_adam_layer), also wird ueber einen
  # Zwischenpuffer gelesen und beim Ablegen quantisiert.
  #
  # Der FP32-Lader (cortex_load_stream) hatte genau dieselbe Stelle und wurde in
  # Punkt 1 mit `blastQ` repariert - hier war sie noch offen, weil kein Test den
  # FORTSETZUNGS-Ladepfad mit aktivem Umbau fuhr. train_worker.php hat den Umbau
  # fuer diesen Pfad deshalb vorsorglich abgeschaltet; das kann jetzt entfallen.
  if s.quantAdam != 0:
    var maxCount = nVocab * nDim
    if nDim * nDim > maxCount: maxCount = nDim * nDim
    if nFfn * nDim > maxCount: maxCount = nFfn * nDim
    qScratch = cast[ptr FloatArray](allocShared0(maxCount * sizeof(cfloat)))

  # withAdam kommt aus der Byte-Bilanz oben - bei export_int8_deployment()-
  # Artefakten (nur Gewichte) ist dieser Block ein No-Op, m/v bleiben auf dem
  # von cortex_init() gezeigten Nullwert (= korrekter Cold-Start).
  template rdAdamQ(pm, pv: pointer, mqp, vqp: ptr QMoment, count: int) =
    if withAdam:
      if pm.isNil and (mqp.isNil or mqp.data.isNil):
        # LoRA-Speicherarm: es gibt kein Ziel fuer diesen Block, weil er gar
        # nicht erst alloziert wurde. Die Bytes stehen aber in der Datei -
        # also ueberspringen. Sie wegzulassen wuerde jeden folgenden Tensor
        # um genau diese Laenge verschieben, und der Ladefehler traete erst
        # ganz am Ende als "Datei zu kurz" auf, weit weg von der Ursache.
        setFilePos(f, (2 * count * sizeof(cfloat)).int64, fspCur)
      elif s.quantAdam != 0 and not mqp.isNil and not mqp.data.isNil and not qScratch.isNil:
        let need = count * sizeof(cfloat)
        if f.readBuffer(qScratch, need) != need: failLoad(LOAD_ERR_TRUNC)
        for r in 0 ..< mqp.rows.int: qmomStoreRow(mqp[], r, qScratch, r * mqp.cols.int, true)
        if f.readBuffer(qScratch, need) != need: failLoad(LOAD_ERR_TRUNC)
        for r in 0 ..< vqp.rows.int: qmomStoreRow(vqp[], r, qScratch, r * vqp.cols.int, false)
      else:
        rdF(pm, count)
        rdF(pv, count)

  template rdAdam(pm, pv: pointer, count: int) =
    if withAdam:
      rdF(pm, count)
      rdF(pv, count)

  rdQ(s.embeddings_q8)
  rdAdamQ(s.m_embeddings.data, s.v_embeddings.data,
          addr s.mq_embeddings, addr s.vq_embeddings, nVocab*nDim)
  # SNAI_V7/Tying: in der Datei steht an dieser Stelle NICHTS. w_out_q8 zeigt
  # bereits auf die eben eingelesenen Embeddings (tieEmbeddingsInternal weiter
  # oben), die m/v-Felder existieren nicht mehr - ein rdQ/rdAdamQ hier wuerde
  # den Lesezeiger um einen ganzen Block verschieben und alles Folgende
  # zerlegen.
  if not wantTied:
    rdQ(s.w_out_q8)
    rdAdamQ(s.m_w_out.data, s.v_w_out.data,
            addr s.mq_w_out, addr s.vq_w_out, nVocab*nDim)
  rdF(s.rms_final_weight, nDim); rdAdam(s.m_rms_final_weight, s.v_rms_final_weight, nDim)

  for l in 0 ..< nLayers:
    rdF(s.rms_att_weights[l], nDim); rdAdam(s.m_rms_att_weights[l], s.v_rms_att_weights[l], nDim)
    rdF(s.rms_ffn_weights[l], nDim); rdAdam(s.m_rms_ffn_weights[l], s.v_rms_ffn_weights[l], nDim)
    rdQ(s.w_q_q8[l])
    rdAdamQ(s.m_w_q[l].data, s.v_w_q[l].data,
            (if s.mq_w_q.isNil: nil else: addr s.mq_w_q[l]),
            (if s.vq_w_q.isNil: nil else: addr s.vq_w_q[l]), nDim*nDim)
    rdQ(s.w_k_q8[l])
    rdAdamQ(s.m_w_k[l].data, s.v_w_k[l].data,
            (if s.mq_w_k.isNil: nil else: addr s.mq_w_k[l]),
            (if s.vq_w_k.isNil: nil else: addr s.vq_w_k[l]), nDim*nDim)
    rdQ(s.w_v_q8[l])
    rdAdamQ(s.m_w_v[l].data, s.v_w_v[l].data,
            (if s.mq_w_v.isNil: nil else: addr s.mq_w_v[l]),
            (if s.vq_w_v.isNil: nil else: addr s.vq_w_v[l]), nDim*nDim)
    rdQ(s.w_o_q8[l])
    rdAdamQ(s.m_w_o[l].data, s.v_w_o[l].data,
            (if s.mq_w_o.isNil: nil else: addr s.mq_w_o[l]),
            (if s.vq_w_o.isNil: nil else: addr s.vq_w_o[l]), nDim*nDim)
    rdQ(s.w_up_q8[l])
    rdAdamQ(s.m_w_up[l].data, s.v_w_up[l].data,
            (if s.mq_w_up.isNil: nil else: addr s.mq_w_up[l]),
            (if s.vq_w_up.isNil: nil else: addr s.vq_w_up[l]), nFfn*nDim)
    rdQ(s.w_down_q8[l])
    rdAdamQ(s.m_w_down[l].data, s.v_w_down[l].data,
            (if s.mq_w_down.isNil: nil else: addr s.mq_w_down[l]),
            (if s.vq_w_down.isNil: nil else: addr s.vq_w_down[l]), nDim*nFfn)

  if not qScratch.isNil: deallocShared(qScratch)
  qScratch = nil

  var tRaw: int32 = 0
  if f.readBuffer(addr tRaw, 4) == 4:
    s.adam_t = tRaw.cint
  f.close()
  # (weightDtype wurde bereits vor dem ersten Lesevorgang gesetzt - siehe
  # BUGFIX-Kommentar oben.)

  # Post-Check: Skalen endlich/positiv (Pendant zu den Post-Checks in
  # cortex_load_stream()/cortex_validate_i8()).
  var flags: cint = 0
  flags = flags or validateQMatrix(s.embeddings_q8)
  flags = flags or validateQMatrix(s.w_out_q8)
  for l in 0 ..< nLayers:
    flags = flags or validateQMatrix(s.w_q_q8[l])
    flags = flags or validateQMatrix(s.w_k_q8[l])
    flags = flags or validateQMatrix(s.w_v_q8[l])
    flags = flags or validateQMatrix(s.w_o_q8[l])
    flags = flags or validateQMatrix(s.w_up_q8[l])
    flags = flags or validateQMatrix(s.w_down_q8[l])
  if flags != 0:
    last_load_error = LOAD_ERR_NAN
    stderr.writeLine("[cortex] FATAL: ungueltige INT8-Skalen beim Laden (Flags=", $flags, ").")
    cortex_free(s)
    return nil
  if gainsNichtEndlich(s):
    last_load_error = LOAD_ERR_NAN
    stderr.writeLine("[cortex] FATAL: NaN/Inf in den Gains beim Laden.")
    cortex_free(s)
    return nil

  checkGains(cast[ptr cfloat](s.rms_final_weight), s.hiddenDim, "rms_final")
  for l in 0 ..< s.numLayers:
    checkGains(cast[ptr cfloat](s.rms_att_weights[l]), s.hiddenDim, "L" & $l & ".rms_att")
    checkGains(cast[ptr cfloat](s.rms_ffn_weights[l]), s.hiddenDim, "L" & $l & ".rms_ffn")
  ffnSkipAktualisieren(s)   # FFN-SKIP: Meldung schon beim Laden

  return s

proc cortex_init_gpu*() {.ffi, exportc, dynlib, cdecl.} =
  # Update 2026-08-08: intelligenter Backend-Switch. CUDA zuerst versuchen -
  # aber NUR nachdem cuda_lib_loadable() (std/dynlib-basierter sicherer
  # Vortest, siehe cortex_cuda_bridge.nim) bestaetigt hat, dass
  # libcortex_cuda.so ueberhaupt ladbar ist. Ohne diesen Vortest wuerde
  # init_cuda_engine() auf einem Knoten ohne CUDA-Runtime (die meisten
  # Knoten im Schwarm) den gesamten Prozess hart
  # abstuerzen lassen (empirisch verifiziert). Danach OpenCL, sonst CPU.
  # CUDA bleibt damit explizit opt-in pro Knoten, kein Ersatz fuer OpenCL.
  if cuda_lib_loadable() and init_cuda_engine() == 1:
    gpu_backend = gbCuda
    gpu_initialized = true
  elif init_opencl_engine() == 1:
    gpu_backend = gbOpenCL
    gpu_initialized = true
  else:
    gpu_backend = gbNone
    gpu_initialized = false

proc get_vocab_size*(state: ptr CortexState): cint {.ffi, exportc, dynlib, cdecl.} =
  if state.isNil: return 0
  return state.vocabSize

proc get_ctx_size*(state: ptr CortexState): cint {.ffi, exportc, dynlib, cdecl.} =
  if state.isNil: return 0
  return state.ctxSize

# Update 2026-08-09 ("Engine-/Framework-Verbesserungen",
# Punkt 1): Lese-Seite fuer den optionalen int32-Adam-Schritt-Trailer
# existiert seit Laengerem (siehe cortex_load_stream weiter unten, "withT"),
# adam_t war aber nie ueber FFI abrufbar - extract_state() in
# tensor_ffi_adapter.php konnte es folglich nie mitschreiben. Jeder
# gespeicherte Checkpoint verlor dadurch seinen Bias-Correction-Fortschritt
# (Fallback beim naechsten Laden: adam_t=1000, neutralisiert die Korrektur,
# sprengt nichts, bremst nur - siehe V11.2b-Kommentar unten).
proc cortex_get_adam_t*(state: ptr CortexState): cint {.ffi, exportc, dynlib, cdecl.} =
  if state.isNil: return 0
  return state.adam_t

proc cortex_read_j_space*(state: ptr CortexState, layer_idx: cint, raw_logits: ptr cfloat) {.ffi, exportc, dynlib, cdecl.} =
  if state.isNil or layer_idx < 0 or layer_idx >= state.numLayers: return
  let logits = cast[ptr FloatArray](raw_logits)
  
  applyRMSNorm(state.j_space_cache[layer_idx], state.norm_buf, state.hiddenDim, state.rms_final_weight)
  
  matVecMul(state.w_out, state.norm_buf, logits)