# Dateiname: cortex_cuda_bridge.nim
# Funktion: FFI-Schnittstelle zwischen der Nim-Engine und der libcortex_cuda.so
# MAXIME: E > H. Zero-Copy Pointer-Durchreichung an die Tensor Cores.
#
# STATUS: seit Update 2026-08-08 in cortex.nim's Backend-Dispatch eingeklinkt
# (intelligenter Switch: CUDA -> OpenCL -> CPU, siehe cortex_init_gpu()) -
# funktional vollstaendig deckungsgleich zu cortex_opencl.nim (alle Forward-/
# Backward-/Adam-/Hilfsfunktionen inkl. der gebuendelten Attention-Variante
# portiert und einzeln + im Zusammenspiel verifiziert).
#
# AUDIT-FIX (2026-08-06): cuda_adamStep hatte im urspruenglichen Entwurf nicht
# die Growth-Boundary/Boost-Parameter (cols, bound_r, bound_c, boost), die
# ocl_adamStep seit dem Net2Net-LR-Fix traegt - Signatur hier nachgezogen,
# damit ein spaeteres Einklinken in cortex.nim den LR-Boost nicht still
# unterschlaegt. cuda_sync_to_device ergaenzt (Gegenstueck zu
# ocl_sync_to_device, fehlte komplett - siehe cortex_cuda.cu-Kommentar).
#
# AUDIT-FIX (2026-08-08): wd-Parameter (Weight-Decay) ergaenzt - Nachzug aus
# dem "Trainings-Absicherung: Nachruest-Paket" fuer ocl_adamStep, das nach
# dem urspruenglichen CUDA-Audit entstand (siehe cortex_cuda.cu-Kommentar
# und Update 2026-08-08).
#
# Update 2026-08-08: Backward-Pass, Einzelvektor-Ops und gebuendelte Attention
# ergaenzt. Alle
# Signaturen 1:1 identisch zu ihren ocl_*-Pendants (Parameterzahl,
# -reihenfolge, -namen).
#
# ==============================================================================
# AUDIT-FIX (2026-08-08, sicherheitskritisch): manuelles std/dynlib-Laden
# statt {.importc, dynlib.}
# ==============================================================================
# {.importc, dynlib: "libcortex_cuda.so".} laedt lazy beim ERSTEN AUFRUF -
# schlaegt das fehl (Bibliothek oder eine ihrer Laufzeit-Abhaengigkeiten wie
# libcudart.so/libcublas.so nicht auffindbar), ist das ein harter, nicht
# abfangbarer Prozessabsturz. In isolierten Testprogrammen (auch mit den
# exakt gleichen Compiler-Flags und Modul-Imports) verhielt sich das wie
# erwartet lazy und sicher - beim tatsaechlichen Einbau in die VOLLE
# cortex.nim (als Teil von deren --app:lib-Build) stuerzte der Prozess
# jedoch schon VOR dem ersten Aufruf von cuda_lib_loadable() ab, obwohl
# dessen einzige Aufgabe genau diese Pruefung ist (reproduziert, exakte
# Ursache innerhalb der verfuegbaren Zeit nicht abschliessend isoliert -
# vermutlich eine Eigenheit von Nims Dynlib-Registrierung bei vielen
# {.importc, dynlib.}-Prozeduren im selben grossen --app:lib-Build).
#
# Deshalb hier komplett auf manuelles Laden umgestellt: std/dynlib.loadLib()
# (sicher, liefert nil statt abzustuerzen) plus symAddr() pro Funktion. Das
# ist in JEDER getesteten Konfiguration nachweislich sicher - auch beim
# tatsaechlichen Fehlschlag innerhalb der vollen cortex.nim (empirisch
# verifiziert, Update 2026-08-08). Ergebnis ist
# funktional identisch zu vorher (dieselben Funktionsnamen/Signaturen nach
# aussen), nur der Lademechanismus dahinter ist robuster.
#
# cuda_lib_loadable() MUSS true liefern, BEVOR irgendeine andere Funktion
# aus diesem Modul aufgerufen wird - siehe cortex_init_gpu() in cortex.nim
# fuer den einzigen vorgesehenen Aufrufer.

import std/dynlib

type
  InitCudaEngineProc = proc(): cint {.cdecl.}
  ShutdownCudaEngineProc = proc() {.cdecl.}
  CudaReleaseBufferProc = proc(h_ptr: pointer) {.cdecl.}
  CudaSyncToHostProc = proc(h_ptr: pointer) {.cdecl.}
  CudaSyncToDeviceProc = proc(h_ptr: pointer, bytes: csize_t) {.cdecl.}
  CudaZeroBufferProc = proc(h_ptr: pointer, bytes: csize_t) {.cdecl.}
  CudaAdamStepProc = proc(w: ptr cfloat, m: ptr cfloat, v: ptr cfloat, g: ptr cfloat, lr: cfloat, b1: cfloat, b2: cfloat, b1t: cfloat, b2t: cfloat, scale: cfloat, size: cint, is_sparse: cint, cols: cint, bound_r: cint, bound_c: cint, boost: cfloat, wd: cfloat) {.cdecl.}
  CudaMatVecMulProc = proc(M: ptr cfloat, v: ptr cfloat, o: ptr cfloat, rows: cint, cols: cint) {.cdecl.}
  CudaMatVecMulTProc = proc(M: ptr cfloat, d_out: ptr cfloat, d_in: ptr cfloat, rows: cint, cols: cint, accumulate: cint) {.cdecl.}
  CudaGradAccumProc = proc(gm: ptr cfloat, d_out: ptr cfloat, i_v: ptr cfloat, rows: cint, cols: cint) {.cdecl.}
  CudaMatMulBatchedProc = proc(M: ptr cfloat, in_seq: ptr cfloat, out_seq: ptr cfloat, rows: cint, cols: cint, batch_size: cint, max_batch: cint) {.cdecl.}
  CudaAttentionForwardProc = proc(q: ptr cfloat, k_cache: ptr cfloat, v_cache: ptr cfloat, out_v: ptr cfloat, pos: cint, numHeads: cint, headSize: cint, dim: cint, ctx: cint) {.cdecl.}
  CudaAttentionBackwardProc = proc(q: ptr cfloat, k_cache: ptr cfloat, v_cache: ptr cfloat, d_att_out: ptr cfloat, d_q: ptr cfloat, d_k_cache: ptr cfloat, d_v_cache: ptr cfloat, pos: cint, numHeads: cint, headSize: cint, dim: cint, ctx: cint) {.cdecl.}
  CudaMatMulTBatchedProc = proc(M: ptr cfloat, d_out: ptr cfloat, d_in: ptr cfloat, rows: cint, cols: cint, batch: cint, accumulate: cint) {.cdecl.}
  CudaGradAccumBatchedProc = proc(gm: ptr cfloat, d_out: ptr cfloat, i_v: ptr cfloat, rows: cint, cols: cint, batch: cint) {.cdecl.}
  CudaAttentionForwardBatchedProc = proc(q_all: ptr cfloat, k_cache: ptr cfloat, v_cache: ptr cfloat, att_out_all: ptr cfloat, act: cint, numHeads: cint, headSize: cint, dim: cint, ctx: cint) {.cdecl.}
  CudaAttentionBackwardBatchedProc = proc(q_all: ptr cfloat, k_cache: ptr cfloat, v_cache: ptr cfloat, d_att_out_all: ptr cfloat, d_q_all: ptr cfloat, d_k_cache: ptr cfloat, d_v_cache: ptr cfloat, act: cint, numHeads: cint, headSize: cint, dim: cint, ctx: cint) {.cdecl.}
  # PHASE 4 DES INT8-UMBAUS - UNGETESTET, siehe cortex_cuda.cu.
  CudaMatVecMulI8Proc = proc(m: ptr int8, mScale: ptr cfloat, v: ptr int8, vScale: cfloat, o_v: ptr cfloat, rows: cint, cols: cint) {.cdecl.}
  CudaAdamStepI8Proc = proc(w: ptr int8, wScale: ptr cfloat, m: ptr cfloat, v: ptr cfloat, g: ptr cfloat, lr: cfloat, b1: cfloat, b2: cfloat, b1t: cfloat, b2t: cfloat, scale: cfloat, size: cint, is_sparse: cint, cols: cint, bound_r: cint, bound_c: cint, boost: cfloat, wd: cfloat) {.cdecl.}
  CudaAdamRowQI8Proc* = proc(w: ptr int8, ws: ptr cfloat, mqd: ptr uint8, mqs: ptr cfloat, vqd: ptr uint8, vqs: ptr cfloat, g: ptr cfloat, res: ptr cfloat, tabM: ptr cfloat, tabV: ptr cfloat, lgr: cdouble, lr, b1, b2, b1t, b2t, gscale: cfloat, rows, cols, is_sparse, bound_r, bound_c: cint, boost, wd: cfloat, use_fb, mode: cint): cint {.cdecl.}
  CudaAdamRowQI8SRProc* = proc(w: ptr int8, ws: ptr cfloat, mqd: ptr uint8, mqs: ptr cfloat, vqd: ptr uint8, vqs: ptr cfloat, g: ptr cfloat, res: ptr cfloat, tabM: ptr cfloat, tabV: ptr cfloat, lgr: cdouble, lr, b1, b2, b1t, b2t, gscale: cfloat, rows, cols, is_sparse, bound_r, bound_c: cint, boost, wd: cfloat, use_fb, mode, sr_mask: cint, sr_salt: uint64): cint {.cdecl.}
  CudaQaStatsProc* = proc(o: ptr cdouble) {.cdecl.}
  # REST-16 (Messkopie ms_rest/karte): wie SR, dazu Rest-Modus, Rot, Telemetrie; Zaehler lesen und nullen.
  CudaAdamRowQI8RestProc* = proc(w: ptr int8, ws: ptr cfloat, mqd: ptr uint8, mqs: ptr cfloat, vqd: ptr uint8, vqs: ptr cfloat, g: ptr cfloat, res: ptr cfloat, tabM: ptr cfloat, tabV: ptr cfloat, lgr: cdouble, lr, b1, b2, b1t, b2t, gscale: cfloat, rows, cols, is_sparse, bound_r, bound_c: cint, boost, wd: cfloat, use_fb, mode, sr_mask: cint, sr_salt: uint64, rmode, rrot, rtele: cint): cint {.cdecl.}
  CudaRestStatsProc* = proc(o: ptr uint64, owd: ptr cdouble) {.cdecl.}
  # ATT-GPU (2026-10-14, patch_att_gpu.py) - freiwillig wie GPU-Adam.
  CudaAttFwdI8Proc* = proc(q8: ptr int8, qs: ptr cfloat, k8: ptr int8, ks: ptr cfloat, v8: ptr int8, vs: ptr cfloat,
                           o: ptr cfloat, act, dim, nH, hs: cint, sqrtHs: cfloat, rot: cint): cint {.cdecl.}
  CudaAttBwI8Proc* = proc(q8: ptr int8, qs: ptr cfloat, k8: ptr int8, ks: ptr cfloat, v8: ptr int8, vs: ptr cfloat,
                          datt, dq, dk, dv: ptr cfloat, act, dim, nH, hs: cint, sqrtHs: cfloat, attScale: cdouble,
                          rot: cint): cint {.cdecl.}
  # GRAD-DEV (2026-11-11, e619) - freiwillig.
  CudaPullToProc* = proc(h: pointer, dst: pointer, bytes: csize_t): cint {.cdecl.}
  CudaGradPrepProc* = proc(h: pointer, bytes: csize_t, kind: cint, scale: cfloat, rot: cint): cint {.cdecl.}
  CudaAdamGDevProc* = proc(on: cint) {.cdecl.}
  CudaPullPtrProc* = proc(h: pointer, bytes: csize_t): ptr cfloat {.cdecl.}
  CudaEarlyStatsProc* = proc(o: ptr uint64) {.cdecl.}
  # RESIDENT (2026-11-11, e624/e625) - freiwillig.
  CudaResProc* = proc(op: cint, p: ptr pointer, n: ptr clonglong, f: ptr cfloat): cint {.cdecl.}
  CudaAdamRowFloatI8Proc = proc(w: ptr int8, wScale: ptr cfloat, m: ptr cfloat, v: ptr cfloat, g: ptr cfloat, res: ptr cfloat, lr: cfloat, b1: cfloat, b2: cfloat, b1t: cfloat, b2t: cfloat, scale: cfloat, rows: cint, cols: cint, is_sparse: cint, bound_r: cint, bound_c: cint, boost: cfloat, wd: cfloat, use_fb: cint) {.cdecl.}
  # INT8-ANSCHLUSS 2026-10-13
  CudaMatMulBatchedI8Proc = proc(m: ptr int8, mScale: ptr cfloat, i_v: ptr int8, inScale: ptr cfloat, o_v: ptr cfloat, rows: cint, cols: cint, batch: cint) {.cdecl, raises: [], gcsafe.}
  CudaMatVecMulTI8Proc = proc(m: ptr int8, mScale: ptr cfloat, d_out: ptr cfloat, d_in: ptr cfloat, rows: cint, cols: cint, accumulate: cint) {.cdecl, raises: [], gcsafe.}
  CudaMatMulTBatchedI8Proc = proc(m: ptr int8, mScale: ptr cfloat, d_out: ptr cfloat, d_in: ptr cfloat, rows: cint, cols: cint, batch: cint, accumulate: cint) {.cdecl, raises: [], gcsafe.}
  CudaBackwardDInI8Proc = proc(w: ptr int8, dq: ptr int8, bscale: ptr cfloat, d_in: ptr cfloat, rows: cint, cols: cint, blockSize: cint, accumulate: cint) {.cdecl, raises: [], gcsafe.}
  CudaBackwardDInI8BatchedProc = proc(w: ptr int8, dq: ptr int8, bscale: ptr cfloat, d_in: ptr cfloat, rows: cint, cols: cint, batch: cint, blockSize: cint, accumulate: cint) {.cdecl, raises: [], gcsafe.}
  CudaGradAccumI8Proc = proc(qi: ptr int8, qd: ptr int8, dsc: ptr cfloat, isc: ptr cfloat, gm: ptr cfloat, rows: cint, cols: cint, batch: cint, qiStride: cint, gmOnDevice: cint) {.cdecl, raises: [], gcsafe.}
  CudaPushQMatrixProc = proc(data: ptr int8, scale: ptr cfloat, rows: cint, cols: cint) {.cdecl, raises: [], gcsafe.}
  CudaDeviceChecksumProc = proc(p: pointer, bytes: csize_t): clong {.cdecl, raises: [], gcsafe.}
  CudaCounterProc = proc(): clong {.cdecl, raises: [], gcsafe.}

var
  cudaLib: LibHandle = nil
  cudaProbeDone = false
  cudaProbeResult = false
  pInitCudaEngine: InitCudaEngineProc
  pShutdownCudaEngine: ShutdownCudaEngineProc
  pCudaReleaseBuffer: CudaReleaseBufferProc
  pCudaSyncToHost: CudaSyncToHostProc
  pCudaSyncToDevice: CudaSyncToDeviceProc
  pCudaZeroBuffer: CudaZeroBufferProc
  pCudaAdamStep: CudaAdamStepProc
  pCudaMatVecMul: CudaMatVecMulProc
  pCudaMatVecMulT: CudaMatVecMulTProc
  pCudaGradAccum: CudaGradAccumProc
  pCudaMatMulBatched: CudaMatMulBatchedProc
  pCudaAttentionForward: CudaAttentionForwardProc
  pCudaAttentionBackward: CudaAttentionBackwardProc
  pCudaMatMulTBatched: CudaMatMulTBatchedProc
  pCudaGradAccumBatched: CudaGradAccumBatchedProc
  pCudaAttentionForwardBatched: CudaAttentionForwardBatchedProc
  pCudaAttentionBackwardBatched: CudaAttentionBackwardBatchedProc
  pCudaMatVecMulI8: CudaMatVecMulI8Proc
  pCudaAdamStepI8: CudaAdamStepI8Proc
  pCudaAdamRowFloatI8: CudaAdamRowFloatI8Proc
  # GPU-Adam (2026-10-14) - freiwillig: eine aeltere libcortex_cuda.so ohne diese Symbole bleibt ladbar,
  # SNAI_I8_GPU_ADAM meldet dann einmal, dass es nicht greift.
  pCudaAdamRowQI8*: CudaAdamRowQI8Proc
  pCudaAdamRowQI8SR*: CudaAdamRowQI8SRProc   # SR auf der Karte (2026-10-19), freiwillig
  pCudaQaStats*: CudaQaStatsProc
  pCudaAdamRowQI8Rest*: CudaAdamRowQI8RestProc
  pCudaRestStats*: CudaRestStatsProc
  pCudaAttFwdI8*: CudaAttFwdI8Proc
  pCudaAttBwI8*: CudaAttBwI8Proc
  pCudaAttStats*: CudaQaStatsProc
  pCudaPullTo*: CudaPullToProc
  pCudaGradPrep*: CudaGradPrepProc
  pCudaAdamGDev*: CudaAdamGDevProc
  pCudaPullPtr*: CudaPullPtrProc
  pCudaEarlyStats*: CudaEarlyStatsProc
  pCudaRes*: CudaResProc
  pCudaRes2*: CudaResProc
  # INT8-ANSCHLUSS 2026-10-13
  pCudaMatMulBatchedI8: CudaMatMulBatchedI8Proc
  pCudaMatVecMulTI8: CudaMatVecMulTI8Proc
  pCudaMatMulTBatchedI8: CudaMatMulTBatchedI8Proc
  pCudaBackwardDInI8: CudaBackwardDInI8Proc
  pCudaBackwardDInI8Batched: CudaBackwardDInI8BatchedProc
  pCudaGradAccumI8: CudaGradAccumI8Proc
  pCudaPushQMatrix: CudaPushQMatrixProc
  pCudaDeviceChecksum: CudaDeviceChecksumProc
  pCudaGetGradAccCalls: CudaCounterProc
  pCudaGetBwDinCalls: CudaCounterProc

proc cuda_lib_loadable*(): bool =
  ## True, wenn libcortex_cuda.so (und alle 20 erwarteten Symbole - seit
  ## Phase 4 des INT8-Umbaus zwei mehr als die urspruenglichen 17) auf diesem
  ## System ladbar sind. Sagt NICHTS darueber aus, ob tatsaechlich eine
  ## funktionsfaehige NVIDIA-GPU vorhanden ist - dafuer zusaetzlich
  ## init_cuda_engine() aufrufen (cudaSetDevice() kann trotzdem scheitern,
  ## z.B. kein Treiber geladen). Muss true liefern, BEVOR irgendeine andere
  ## Funktion aus diesem Modul aufgerufen wird - alle pCuda*-Funktionszeiger
  ## bleiben sonst nil.
  if cudaProbeDone: return cudaProbeResult
  cudaProbeDone = true

  cudaLib = loadLib("libcortex_cuda.so")
  if cudaLib == nil:
    return false

  template bindSym(p, T: untyped, name: string) =
    p = cast[T](cudaLib.symAddr(name))
    if p == nil:
      return false

  bindSym(pInitCudaEngine, InitCudaEngineProc, "init_cuda_engine")
  bindSym(pShutdownCudaEngine, ShutdownCudaEngineProc, "shutdown_cuda_engine")
  bindSym(pCudaReleaseBuffer, CudaReleaseBufferProc, "cuda_release_buffer")
  bindSym(pCudaSyncToHost, CudaSyncToHostProc, "cuda_sync_to_host")
  bindSym(pCudaSyncToDevice, CudaSyncToDeviceProc, "cuda_sync_to_device")
  bindSym(pCudaZeroBuffer, CudaZeroBufferProc, "cuda_zero_buffer")
  bindSym(pCudaAdamStep, CudaAdamStepProc, "cuda_adamStep")
  bindSym(pCudaMatVecMul, CudaMatVecMulProc, "cuda_matVecMul")
  bindSym(pCudaMatVecMulT, CudaMatVecMulTProc, "cuda_matVecMulT")
  bindSym(pCudaGradAccum, CudaGradAccumProc, "cuda_gradAccum")
  bindSym(pCudaMatMulBatched, CudaMatMulBatchedProc, "cuda_matMulBatched")
  bindSym(pCudaAttentionForward, CudaAttentionForwardProc, "cuda_attentionForward")
  bindSym(pCudaAttentionBackward, CudaAttentionBackwardProc, "cuda_attentionBackward")
  bindSym(pCudaMatMulTBatched, CudaMatMulTBatchedProc, "cuda_matMulTBatched")
  bindSym(pCudaGradAccumBatched, CudaGradAccumBatchedProc, "cuda_gradAccumBatched")
  bindSym(pCudaAttentionForwardBatched, CudaAttentionForwardBatchedProc, "cuda_attentionForwardBatched")
  bindSym(pCudaAttentionBackwardBatched, CudaAttentionBackwardBatchedProc, "cuda_attentionBackwardBatched")
  bindSym(pCudaMatVecMulI8, CudaMatVecMulI8Proc, "cuda_matVecMulI8")
  bindSym(pCudaAdamStepI8, CudaAdamStepI8Proc, "cuda_adamStepI8")
  bindSym(pCudaAdamRowFloatI8, CudaAdamRowFloatI8Proc, "cuda_adamRowFloatI8")
  pCudaAdamRowQI8 = cast[CudaAdamRowQI8Proc](cudaLib.symAddr("cuda_adamRowQI8"))
  pCudaAdamRowQI8SR = cast[CudaAdamRowQI8SRProc](cudaLib.symAddr("cuda_adamRowQI8SR"))
  pCudaQaStats = cast[CudaQaStatsProc](cudaLib.symAddr("cuda_get_qa_stats"))
  pCudaAdamRowQI8Rest = cast[CudaAdamRowQI8RestProc](cudaLib.symAddr("cuda_adamRowQI8Rest"))
  pCudaRestStats = cast[CudaRestStatsProc](cudaLib.symAddr("cuda_rest_stats"))
  pCudaAttFwdI8 = cast[CudaAttFwdI8Proc](cudaLib.symAddr("cuda_att_fwd_i8"))
  pCudaAttBwI8 = cast[CudaAttBwI8Proc](cudaLib.symAddr("cuda_att_bw_i8"))
  pCudaAttStats = cast[CudaQaStatsProc](cudaLib.symAddr("cuda_att_stats"))
  pCudaPullTo = cast[CudaPullToProc](cudaLib.symAddr("cuda_pull_to"))
  pCudaGradPrep = cast[CudaGradPrepProc](cudaLib.symAddr("cuda_grad_prep"))
  pCudaAdamGDev = cast[CudaAdamGDevProc](cudaLib.symAddr("cuda_adam_g_dev"))
  pCudaPullPtr = cast[CudaPullPtrProc](cudaLib.symAddr("cuda_pull_ptr"))
  pCudaEarlyStats = cast[CudaEarlyStatsProc](cudaLib.symAddr("cuda_early_stats"))
  pCudaRes = cast[CudaResProc](cudaLib.symAddr("cuda_res"))
  pCudaRes2 = cast[CudaResProc](cudaLib.symAddr("cuda_res2"))
  # INT8-ANSCHLUSS 2026-10-13: alle Pflicht. Eine aeltere libcortex_cuda.so
  # ohne diese Symbole gilt als nicht ladbar (Rueckfall OpenCL/CPU wie bisher).
  bindSym(pCudaMatMulBatchedI8, CudaMatMulBatchedI8Proc, "cuda_matMulBatchedI8")
  bindSym(pCudaMatVecMulTI8, CudaMatVecMulTI8Proc, "cuda_matVecMulTI8")
  bindSym(pCudaMatMulTBatchedI8, CudaMatMulTBatchedI8Proc, "cuda_matMulTBatchedI8")
  bindSym(pCudaBackwardDInI8, CudaBackwardDInI8Proc, "cuda_backwardDInI8")
  bindSym(pCudaBackwardDInI8Batched, CudaBackwardDInI8BatchedProc, "cuda_backwardDInI8Batched")
  bindSym(pCudaGradAccumI8, CudaGradAccumI8Proc, "cuda_gradAccumI8")
  bindSym(pCudaPushQMatrix, CudaPushQMatrixProc, "cuda_push_qmatrix")
  bindSym(pCudaDeviceChecksum, CudaDeviceChecksumProc, "cuda_device_checksum")
  bindSym(pCudaGetGradAccCalls, CudaCounterProc, "cuda_get_gradacc_calls")
  bindSym(pCudaGetBwDinCalls, CudaCounterProc, "cuda_get_bw_din_calls")

  cudaProbeResult = true
  true

proc init_cuda_engine*(): cint =
  # Selbst-absichernd: ruft cuda_lib_loadable() intern auf, falls der
  # Aufrufer das vergessen hat (leicht zu vergessen - selbst
  # skripte/e2e_compare.nim tat es urspruenglich nicht). Damit ist
  # init_cuda_engine() allein schon sicher, nicht nur in Kombination mit
  # einem vorgeschalteten expliziten Probe-Aufruf.
  if not cuda_lib_loadable(): return 0
  pInitCudaEngine()
proc shutdown_cuda_engine*() = pShutdownCudaEngine()
proc cuda_release_buffer*(h_ptr: pointer) = pCudaReleaseBuffer(h_ptr)
proc cuda_sync_to_host*(h_ptr: pointer) = pCudaSyncToHost(h_ptr)
proc cuda_sync_to_device*(h_ptr: pointer, bytes: csize_t) = pCudaSyncToDevice(h_ptr, bytes)
proc cuda_zero_buffer*(h_ptr: pointer, bytes: csize_t) = pCudaZeroBuffer(h_ptr, bytes)
proc cuda_adamStep*(w: ptr cfloat, m: ptr cfloat, v: ptr cfloat, g: ptr cfloat, lr: cfloat, b1: cfloat, b2: cfloat, b1t: cfloat, b2t: cfloat, scale: cfloat, size: cint, is_sparse: cint, cols: cint, bound_r: cint, bound_c: cint, boost: cfloat, wd: cfloat) =
  pCudaAdamStep(w, m, v, g, lr, b1, b2, b1t, b2t, scale, size, is_sparse, cols, bound_r, bound_c, boost, wd)
proc cuda_matVecMul*(M: ptr cfloat, v: ptr cfloat, o: ptr cfloat, rows: cint, cols: cint) =
  pCudaMatVecMul(M, v, o, rows, cols)
proc cuda_matVecMulT*(M: ptr cfloat, d_out: ptr cfloat, d_in: ptr cfloat, rows: cint, cols: cint, accumulate: cint) =
  pCudaMatVecMulT(M, d_out, d_in, rows, cols, accumulate)
proc cuda_gradAccum*(gm: ptr cfloat, d_out: ptr cfloat, i_v: ptr cfloat, rows: cint, cols: cint) =
  pCudaGradAccum(gm, d_out, i_v, rows, cols)
proc cuda_matMulBatched*(M: ptr cfloat, in_seq: ptr cfloat, out_seq: ptr cfloat, rows: cint, cols: cint, batch_size: cint, max_batch: cint) =
  pCudaMatMulBatched(M, in_seq, out_seq, rows, cols, batch_size, max_batch)
proc cuda_attentionForward*(q: ptr cfloat, k_cache: ptr cfloat, v_cache: ptr cfloat, out_v: ptr cfloat, pos: cint, numHeads: cint, headSize: cint, dim: cint, ctx: cint) =
  pCudaAttentionForward(q, k_cache, v_cache, out_v, pos, numHeads, headSize, dim, ctx)
proc cuda_attentionBackward*(q: ptr cfloat, k_cache: ptr cfloat, v_cache: ptr cfloat, d_att_out: ptr cfloat, d_q: ptr cfloat, d_k_cache: ptr cfloat, d_v_cache: ptr cfloat, pos: cint, numHeads: cint, headSize: cint, dim: cint, ctx: cint) =
  pCudaAttentionBackward(q, k_cache, v_cache, d_att_out, d_q, d_k_cache, d_v_cache, pos, numHeads, headSize, dim, ctx)
proc cuda_matMulTBatched*(M: ptr cfloat, d_out: ptr cfloat, d_in: ptr cfloat, rows: cint, cols: cint, batch: cint, accumulate: cint) =
  pCudaMatMulTBatched(M, d_out, d_in, rows, cols, batch, accumulate)
proc cuda_gradAccumBatched*(gm: ptr cfloat, d_out: ptr cfloat, i_v: ptr cfloat, rows: cint, cols: cint, batch: cint) =
  pCudaGradAccumBatched(gm, d_out, i_v, rows, cols, batch)
proc cuda_attentionForwardBatched*(q_all: ptr cfloat, k_cache: ptr cfloat, v_cache: ptr cfloat, att_out_all: ptr cfloat, act: cint, numHeads: cint, headSize: cint, dim: cint, ctx: cint) =
  pCudaAttentionForwardBatched(q_all, k_cache, v_cache, att_out_all, act, numHeads, headSize, dim, ctx)
proc cuda_attentionBackwardBatched*(q_all: ptr cfloat, k_cache: ptr cfloat, v_cache: ptr cfloat, d_att_out_all: ptr cfloat, d_q_all: ptr cfloat, d_k_cache: ptr cfloat, d_v_cache: ptr cfloat, act: cint, numHeads: cint, headSize: cint, dim: cint, ctx: cint) =
  pCudaAttentionBackwardBatched(q_all, k_cache, v_cache, d_att_out_all, d_q_all, d_k_cache, d_v_cache, act, numHeads, headSize, dim, ctx)

# PHASE 4 DES INT8-UMBAUS - UNGETESTET, siehe cortex_cuda.cu.
proc cuda_matVecMulI8*(m: ptr int8, mScale: ptr cfloat, v: ptr int8, vScale: cfloat, o_v: ptr cfloat, rows: cint, cols: cint) =
  pCudaMatVecMulI8(m, mScale, v, vScale, o_v, rows, cols)
proc cuda_adamStepI8*(w: ptr int8, wScale: ptr cfloat, m: ptr cfloat, v: ptr cfloat, g: ptr cfloat, lr: cfloat, b1: cfloat, b2: cfloat, b1t: cfloat, b2t: cfloat, scale: cfloat, size: cint, is_sparse: cint, cols: cint, bound_r: cint, bound_c: cint, boost: cfloat, wd: cfloat) =
  pCudaAdamStepI8(w, wScale, m, v, g, lr, b1, b2, b1t, b2t, scale, size, is_sparse, cols, bound_r, bound_c, boost, wd)

# PHASE 10 DES INT8-UMBAUS - UNGETESTET (kein nvcc/keine NVIDIA-GPU hier).
# Gegenstueck zu ocl_adamRowFloatI8, das auf echter AMD-Hardware bit-exakt
# gegen die CPU verifiziert ist.
proc cuda_adamRowFloatI8*(w: ptr int8, wScale: ptr cfloat, m: ptr cfloat, v: ptr cfloat, g: ptr cfloat, res: ptr cfloat, lr: cfloat, b1: cfloat, b2: cfloat, b1t: cfloat, b2t: cfloat, scale: cfloat, rows: cint, cols: cint, is_sparse: cint, bound_r: cint, bound_c: cint, boost: cfloat, wd: cfloat, use_fb: cint) =
  pCudaAdamRowFloatI8(w, wScale, m, v, g, res, lr, b1, b2, b1t, b2t, scale, rows, cols, is_sparse, bound_r, bound_c, boost, wd, use_fb)

# INT8-ANSCHLUSS 2026-10-13: Portierung der OpenCL-Ganzzahl-Kerne, auf einer
# RTX 3050 gepaart gegen die CPU geprueft (siehe cortex_cuda.cu).
proc cuda_matMulBatchedI8*(m: ptr int8, mScale: ptr cfloat, i_v: ptr int8, inScale: ptr cfloat, o_v: ptr cfloat, rows: cint, cols: cint, batch: cint) {.raises: [], gcsafe.} =
  pCudaMatMulBatchedI8(m, mScale, i_v, inScale, o_v, rows, cols, batch)
proc cuda_matVecMulTI8*(m: ptr int8, mScale: ptr cfloat, d_out: ptr cfloat, d_in: ptr cfloat, rows: cint, cols: cint, accumulate: cint) {.raises: [], gcsafe.} =
  pCudaMatVecMulTI8(m, mScale, d_out, d_in, rows, cols, accumulate)
proc cuda_matMulTBatchedI8*(m: ptr int8, mScale: ptr cfloat, d_out: ptr cfloat, d_in: ptr cfloat, rows: cint, cols: cint, batch: cint, accumulate: cint) {.raises: [], gcsafe.} =
  pCudaMatMulTBatchedI8(m, mScale, d_out, d_in, rows, cols, batch, accumulate)
proc cuda_backwardDInI8*(w: ptr int8, dq: ptr int8, bscale: ptr cfloat, d_in: ptr cfloat, rows: cint, cols: cint, blockSize: cint, accumulate: cint) {.raises: [], gcsafe.} =
  pCudaBackwardDInI8(w, dq, bscale, d_in, rows, cols, blockSize, accumulate)
proc cuda_backwardDInI8Batched*(w: ptr int8, dq: ptr int8, bscale: ptr cfloat, d_in: ptr cfloat, rows: cint, cols: cint, batch: cint, blockSize: cint, accumulate: cint) {.raises: [], gcsafe.} =
  pCudaBackwardDInI8Batched(w, dq, bscale, d_in, rows, cols, batch, blockSize, accumulate)
proc cuda_gradAccumI8*(qi: ptr int8, qd: ptr int8, dsc: ptr cfloat, isc: ptr cfloat, gm: ptr cfloat, rows: cint, cols: cint, batch: cint, qiStride: cint, gmOnDevice: cint) {.raises: [], gcsafe.} =
  pCudaGradAccumI8(qi, qd, dsc, isc, gm, rows, cols, batch, qiStride, gmOnDevice)
proc cuda_push_qmatrix*(data: ptr int8, scale: ptr cfloat, rows: cint, cols: cint) {.raises: [], gcsafe.} =
  pCudaPushQMatrix(data, scale, rows, cols)
proc cuda_device_checksum*(p: pointer, bytes: csize_t): clong = pCudaDeviceChecksum(p, bytes)
proc cuda_get_gradacc_calls*(): clong = pCudaGetGradAccCalls()
proc cuda_get_bw_din_calls*(): clong = pCudaGetBwDinCalls()
