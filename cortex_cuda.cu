#include <string.h>
/*
 * Dateiname: cortex_cuda.cu
 * Funktion: Native CUDA Compute Engine
 * ==============================================================================
 * KOMPILIERUNG: nvcc -ftz=true -shared -Xcompiler -fPIC -lcublas -o libcortex_cuda.so cortex_cuda.cu
 *   -ftz=true seit 2026-10-14: die CPU-Seite rechnet mit FTZ/DAZ (snai_ftz_init in cortex.nim); ohne den
 *   Schalter behielte die Karte Denormale und der GPU-Adam wiche bei toten Zeilen ab. Nie -use_fast_math.
 *
 * HERKUNFT: erster Entwurf (2026-08-06), hier mit folgenden Fixes/Ergaenzungen
 * gegen das etablierte OpenCL-Pendant (cortex_opencl.nim) auditiert:
 *   1. #include <cstring> fehlte - memset() in cuda_adamStep() war ein
 *      unportabler impliziter Include (haette je nach nvcc/libstdc++-Version
 *      scheitern koennen).
 *   2. cuda_sync_to_device() fehlte komplett - ocl_get_buffer() UND
 *      cuda_get_buffer() cachen den Device-Buffer ab dem ersten Aufruf pro
 *      Host-Pointer und laden ihn bei Cache-Hit NICHT automatisch neu (siehe
 *      ocl_sync_to_device()-Kommentar in cortex_opencl.nim). Ohne Gegenstueck
 *      gab es keinen Weg, eine ausserhalb dieser Bibliothek veraenderte
 *      Host-Matrix (z.B. nach Net2Net-Upscale) vor dem naechsten CUDA-Aufruf
 *      gezielt neu hochzuladen - einzige Alternative waere der teure Umweg
 *      ueber cuda_release_buffer() (kompletter Realloc statt Overwrite).
 *   3. cuda_adamStep()/adamUpdateKernel fehlten die Growth-Boundary/Boost-
 *      Parameter (cols, bound_r, bound_c, boost), die der OpenCL-Adam-Kernel
 *      seit dem Net2Net-LR-Fix traegt (Stichwort "Differenzierte
 *      Learning-Rate"). Ohne das haette ein spaeteres Einklinken dieses
 *      Pfads in cortex.nim den LR-Boost fuer frisch expandierte Parameter
 *      stillschweigend abgeschaltet. Logik 1:1 aus dem OpenCL-Kernel
 *      uebernommen (elemBoost()-Aequivalent).
 *   4. matMulBatchedForwardKernel war ein von Hand geschriebener Kernel -
 *      trotz des cublasSetMathMode(TF32)-Aufrufs beim Init wurde cuBLAS an
 *      keiner Stelle tatsaechlich benutzt, die Tensor Cores blieben also
 *      komplett ungenutzt (die eine Sache, die CUDA gegenueber OpenCL auf
 *      NVIDIA ueberhaupt einen Vorteil verschaffen koennte - Befund
 *      vom 2026-08-03). Ersetzt durch echtes cublasSgemm() mit
 *      Row-Major-auf-Column-Major-Transpositionstrick (siehe Kommentar an
 *      der Aufrufstelle). Der alte Kernel wurde entfernt, nicht daneben
 *      liegen gelassen.
 *   5. matMulBatchedBackwardWeightsKernel war deklariert, aber nirgendwo
 *      aufrufbar (keine Host-Wrapper-Funktion, keine Nim-FFI-Deklaration) -
 *      toter Code. Entfernt: Backward-Pass ist fuer diese Integrationsstufe
 *      bewusst nicht im Scope (siehe Roadmap - erst nach/mit dem FP16-Umbau
 *      sinnvoll vollstaendig nachzuziehen, sonst doppelte Kernel-Pflege ohne
 *      aktuellen Nutzen).
 *   6. cuda_attentionForward() allozierte/befreite d_q/d_out/d_scores bei
 *      JEDEM Aufruf per cudaMalloc()/cudaFree() - bei der eigentlich
 *      vorgesehenen Nutzung (ein Aufruf pro Token waehrend der Generierung,
 *      hunderte/tausende Male) waere das genau das Alloc/Free-pro-Aufruf-
 *      Problem, das im OpenCL-Pendant schon einmal gefixt wurde (siehe "FIX
 *      4: Robust Buffer Resize" in cortex_opencl.nim). Ersetzt durch
 *      persistente, bei Bedarf wachsende Ephemeral-Buffer nach demselben
 *      Muster.
 *   7. cuda_matMulBatched()/cuda_adamStep() prueften die Rueckgabe von
 *      cuda_get_buffer() nicht auf NULL (Buffer-Groessen-Mismatch oder
 *      Registry-Overflow) - waere ein Nullpointer-Crash statt eines
 *      kontrollierten Abbruchs gewesen. Guards ergaenzt (Muster aus
 *      cuda_attentionForward()/ocl_attentionForward() uebernommen).
 *
 * AUDIT-FIX (2026-08-08): adamUpdateKernel/cuda_adamStep() fehlte der
 * `wd`-Parameter (Weight-Decay, AdamW-Style), den ocl_adamStep seit dem
 * "Trainings-Absicherung: Nachruest-Paket" traegt.
 * Der CUDA-Port stammt von vor diesem Nachruest-Paket und wurde beim
 * ersten Audit nicht nachgezogen, weil es damals noch nicht existierte -
 * durch den Funktionstest (skripte/test_cuda_functional.nim, Update
 * 2026-08-08) aufgefallen. Signatur und Kernel-Logik 1:1 aus ocl_adamStep
 * uebernommen: `if (wd > 0.0f) { w[i] -= lr * wd * w[i]; }`, nach dem
 * eigentlichen Adam-Update, vor dem Gradient-Reset. wd=0.0 ist weiterhin
 * ein exaktes No-Op (identisch zum bisherigen Verhalten).
 * ==============================================================================
 */

#include <cuda_runtime.h>
#include <cublas_v2.h>
#include <cstring>
#include <iostream>
#include <cmath>
#include <chrono>

cublasHandle_t cublas_handle;
bool cuda_initialized = false;

// Simples VRAM-Tracking (Analog zur OpenCL Registry)
#define MAX_CUDA_BUFFERS 2048
struct CudaBufMap {
    void* h_ptr;
    void* d_buf;
    size_t bytes;
};

CudaBufMap cuda_buf_map[MAX_CUDA_BUFFERS];
int cuda_buf_count = 0;

// AUDIT-FIX (Punkt 6): persistente Ephemeral-Scratch-Buffer fuer
// cuda_attentionForward(), analog ocl_eph_v/ocl_eph_out/ocl_eph_scores -
// werden nur bei Bedarf (neu) alloziert, sonst wiederverwendet.
static float* cuda_eph_q = nullptr;      size_t cuda_eph_q_size = 0;
static float* cuda_eph_out = nullptr;    size_t cuda_eph_out_size = 0;
static float* cuda_eph_scores = nullptr; size_t cuda_eph_scores_size = 0;

// Update 2026-08-08 (Backward-Pass): weitere Ephemeral-Scratch-Buffer, analog
// ocl_eph_dq/ocl_eph_dw (Attention-Backward) und ocl_eph_bm_r/ocl_eph_bm_c
// (Batched-Matmul Vorwaerts+Rueckwaerts, in cortex_opencl.nim ueber alle drei
// Operationen hinweg geteilt). cuda_matMulBatched() (Forward) bleibt bewusst
// unangetastet bei seinen eigenen, per Host-Pointer gecachten in/out-Buffern
// (siehe dort) - die beiden neuen bm_r/bm_c-Puffer sind ausschliesslich fuer
// die hier neu hinzukommenden Backward-Funktionen, um das bereits verifizierte
// Forward-Verhalten nicht anzufassen.
static float* cuda_eph_dq = nullptr;     size_t cuda_eph_dq_size = 0;
static float* cuda_eph_dw = nullptr;     size_t cuda_eph_dw_size = 0;
static float* cuda_eph_bm_r = nullptr;   size_t cuda_eph_bm_r_size = 0;  // batch x rows
static float* cuda_eph_bm_c = nullptr;   size_t cuda_eph_bm_c_size = 0;  // batch x cols

// Update 2026-08-08 (Einzelvektor-Ops): analog ocl_eph_bt_a/ocl_eph_bt_b
// ("V8.5 BACKWARD OFFLOAD" in cortex_opencl.nim) - bewusst NICHT mit
// cuda_eph_bm_r/cuda_eph_bm_c (V8.6, batched) geteilt, obwohl beide Paare
// aehnlich (row-/spaltengroesse) sind: OpenCL haelt diese beiden Familien
// ebenfalls getrennt, hier 1:1 uebernommen statt eigenmaechtig zusammenzulegen.
static float* cuda_eph_bt_a = nullptr;   size_t cuda_eph_bt_a_size = 0;  // rows (d_out)
static float* cuda_eph_bt_b = nullptr;   size_t cuda_eph_bt_b_size = 0;  // cols (d_in / i_v)

// PHASE 4 DES INT8-UMBAUS: quantisierter Aktivierungsvektor (int8, dynamisch
// pro GEMM-Aufruf neu befuellt) - siehe cuda_matVecMulI8 unten.
static signed char* cuda_eph_act_i8 = nullptr; size_t cuda_eph_act_i8_size = 0;

// Update 2026-08-08 (gebuendelte Attention): analog ocl_eph_att_q/-out/-datt/
// -dq/-scores/-ds. Eigene Scratch-Familie, nicht mit cuda_eph_q/cuda_eph_out/
// cuda_eph_scores (Einzelposition) geteilt, obwohl aehnlich benannt - andere
// Groessen (act*dim bzw. act*numHeads*ctx statt dim bzw. numHeads*ctx) und
// andere Lebensdauer-Anforderungen; OpenCL haelt sie ebenfalls getrennt.
static float* cuda_eph_att_q = nullptr;      size_t cuda_eph_att_q_size = 0;
static float* cuda_eph_att_out = nullptr;    size_t cuda_eph_att_out_size = 0;
static float* cuda_eph_att_datt = nullptr;   size_t cuda_eph_att_datt_size = 0;
static float* cuda_eph_att_dq = nullptr;     size_t cuda_eph_att_dq_size = 0;
static float* cuda_eph_att_scores = nullptr; size_t cuda_eph_att_scores_size = 0;
static float* cuda_eph_att_ds = nullptr;     size_t cuda_eph_att_ds_size = 0;

// AUDIT-FIX-Analogie: siehe ocl_attentionForwardBatched/-BackwardBatched in
// cortex_opencl.nim - ein einzelner Dispatch ueber grosse Positionsmengen
// riskiert einen GPU-Watchdog-Timeout (dort empirisch auf AMDGPU aufgetreten).
// Selbe Konstante wie im OpenCL-Original, aus Konsistenzgruenden auch fuer
// NVIDIA/CUDA uebernommen (TDR-Mechanismus existiert dort ebenfalls).
#define ATT_POS_CHUNK 256

extern "C" {

void cuda_release_buffer(void* h_ptr) {
    if (!h_ptr) return;
    for(int i = 0; i < cuda_buf_count; i++) {
        if(cuda_buf_map[i].h_ptr == h_ptr) {
            cudaFree(cuda_buf_map[i].d_buf);
            for(int j = i; j < cuda_buf_count - 1; j++) {
                cuda_buf_map[j] = cuda_buf_map[j+1];
            }
            cuda_buf_count--;
            return;
        }
    }
}

void* cuda_get_buffer(void* h_ptr, size_t bytes) {
    if (!h_ptr || bytes == 0) return nullptr;

    for(int i = 0; i < cuda_buf_count; i++) {
        if(cuda_buf_map[i].h_ptr == h_ptr) {
            if (cuda_buf_map[i].bytes != bytes) {
                std::cerr << "🚨 [SYMBIO CUDA] Buffer Size Mismatch!" << std::endl;
                return nullptr;
            }
            // AUDIT: Cache-Hit liefert den bisherigen Device-Buffer OHNE
            // erneuten Upload zurueck - identisch zu ocl_get_buffer(). Wer
            // die Host-Seite ausserhalb dieser Bibliothek veraendert (z.B.
            // Net2Net-Upscale, frisches Laden von Platte), MUSS danach
            // cuda_sync_to_device() aufrufen, sonst rechnet die GPU mit
            // veralteten Daten weiter.
            return cuda_buf_map[i].d_buf;
        }
    }

    if(cuda_buf_count >= MAX_CUDA_BUFFERS) {
        std::cerr << "🚨 [SYMBIO CUDA] VRAM Registry Overflow!" << std::endl;
        return nullptr;
    }

    void* d_buf;
    cudaError_t err = cudaMalloc(&d_buf, bytes);
    if(err == cudaSuccess) {
        cudaMemcpy(d_buf, h_ptr, bytes, cudaMemcpyHostToDevice);
        cuda_buf_map[cuda_buf_count].h_ptr = h_ptr;
        cuda_buf_map[cuda_buf_count].d_buf = d_buf;
        cuda_buf_map[cuda_buf_count].bytes = bytes;
        cuda_buf_count++;
        return d_buf;
    }
    return nullptr;
}

#include <cfloat>
// GRAD-EARLY (2026-11-11, messbuch snai/multistack-gradearly e621, -wdh e622): Gradienten vorgezogen in gepinnte
// Puffer holen. cuda_gradAccumI8 mit geraeteresidentem Gradienten stoesst nach dem Kern auf einem zweiten, nicht
// blockierenden Strom ein cudaMemcpyAsync in einen gepinnten Hostpuffer an (Ereignis auf dem Standardstrom nach
// dem Kern); eine weitere Summe auf denselben Puffer stoesst neu an, das letzte gewinnt. pullGradMerge wartet auf
// das Ereignis und fuehrt direkt daraus zusammen. Kostet je Prozess so viel gepinnten Speicher wie die Gradienten
// der 12 Schichtmatrizen (~400 MB bei d2048 L2). SNAI_GRAD_EARLY: fehlt/1 = an (Vorgabe), 0 = aus,
// ROT = Rot-Probe (Herunterladen vor der Summe).
struct EarlyPull { void* h; void* d; size_t bytes; float* pin; cudaEvent_t evk; cudaEvent_t evd; int pending; };
static EarlyPull ep_tab[64];
static int ep_n = 0;
static cudaStream_t ep_s = nullptr;
static int ep_mode = -1;   // 0 aus, 1 an, 2 ROT
static unsigned long long ep_issued = 0, ep_hits = 0;
static int ep_get_mode() {
    if (ep_mode < 0) {
        const char* e = getenv("SNAI_GRAD_EARLY");
        if (e && strcmp(e, "0") == 0) ep_mode = 0;
        else if (e && strcmp(e, "ROT") == 0) ep_mode = 2;
        else if (!e || !*e || strcmp(e, "1") == 0) ep_mode = 1;   // Vorgabe an (seit 2026-11-11, e621/e622)
        else ep_mode = 0;
        fprintf(stderr, "[GRAD-EARLY] %s\n", ep_mode == 0 ? "aus" : ep_mode == 2 ? "ROT-PROBE" : "an");
    }
    return ep_mode;
}
static EarlyPull* ep_get(void* h, void* d, size_t bytes) {
    for (int i = 0; i < ep_n; i++)
        if (ep_tab[i].h == h) return (ep_tab[i].bytes == bytes && ep_tab[i].d == d) ? &ep_tab[i] : nullptr;
    if (ep_n >= 64) return nullptr;
    if (!ep_s && cudaStreamCreateWithFlags(&ep_s, cudaStreamNonBlocking) != cudaSuccess) { ep_s = nullptr; return nullptr; }
    EarlyPull e; e.h = h; e.d = d; e.bytes = bytes; e.pending = 0; e.pin = nullptr;
    if (cudaHostAlloc((void**)&e.pin, bytes, cudaHostAllocDefault) != cudaSuccess) return nullptr;
    if (cudaEventCreateWithFlags(&e.evk, cudaEventDisableTiming) != cudaSuccess ||
        cudaEventCreateWithFlags(&e.evd, cudaEventDisableTiming) != cudaSuccess) { cudaFreeHost(e.pin); return nullptr; }
    ep_tab[ep_n] = e;
    return &ep_tab[ep_n++];
}
static void ep_issue(EarlyPull* e) {
    cudaEventRecord(e->evk, 0);                 // Standardstrom: alles bis hierher (Kern bzw. bei ROT davor)
    cudaStreamWaitEvent(ep_s, e->evk, 0);
    cudaMemcpyAsync(e->pin, e->d, e->bytes, cudaMemcpyDeviceToHost, ep_s);
    cudaEventRecord(e->evd, ep_s);
    e->pending = 1;
    ep_issued++;
}
// Zeiger auf den vorgezogen geholten Kartenstand (wartet auf ihn), sonst nullptr.
extern "C" const float* cuda_pull_ptr(void* h_key, size_t bytes) {
    for (int i = 0; i < ep_n; i++)
        if (ep_tab[i].h == h_key) {
            EarlyPull* e = &ep_tab[i];
            if (!e->pending || e->bytes != bytes) return nullptr;
            if (cudaEventSynchronize(e->evd) != cudaSuccess) return nullptr;
            e->pending = 0;
            ep_hits++;
            return e->pin;
        }
    return nullptr;
}
extern "C" void cuda_early_stats(unsigned long long* o) { o[0] = ep_issued; o[1] = ep_hits; }
static void ep_free_all() {
    for (int i = 0; i < ep_n; i++) {
        cudaEventSynchronize(ep_tab[i].evd);
        cudaFreeHost(ep_tab[i].pin); cudaEventDestroy(ep_tab[i].evk); cudaEventDestroy(ep_tab[i].evd);
    }
    ep_n = 0;
    if (ep_s) { cudaStreamDestroy(ep_s); ep_s = nullptr; }
}

// GRAD-DEV (2026-11-11, e619): Puffer nachschlagen, ohne ihn anzulegen.
static void* cuda_find_buffer(void* h_ptr, size_t bytes) {
    for (int i = 0; i < cuda_buf_count; i++)
        if (cuda_buf_map[i].h_ptr == h_ptr) return cuda_buf_map[i].bytes == bytes ? cuda_buf_map[i].d_buf : nullptr;
    return nullptr;
}
// Kartenstand des Puffers zu h_key in einen ANDEREN Hostspeicher holen. 0 = geholt, 1 = kein Puffer, 2 = Fehler.
int cuda_pull_to(void* h_key, void* dst, size_t bytes) {
    if (!cuda_initialized || !h_key || !dst) return 1;
    void* d = cuda_find_buffer(h_key, bytes);
    if (!d) return 1;
    return cudaMemcpy(dst, d, bytes, cudaMemcpyDeviceToHost) == cudaSuccess ? 0 : 2;
}
// Gradient auf der Karte so herrichten, wie ihn der Host nach Zusammenfuehren (+0-Hostanteil) und Clip hat.
// kind 0 = nur zusammenfuehren, 1 = zusaetzlich *scale (scaleMat), 2 = nullen (zeroMat). rot = Skalierung weglassen.
__global__ void grad_prep_kern(float* g, size_t n, int kind, float scale, int rot) {
    for (size_t i = (size_t)blockIdx.x * blockDim.x + threadIdx.x; i < n; i += (size_t)gridDim.x * blockDim.x) {
        float x = g[i];
        float c = (fabsf(x) < FLT_MIN) ? 0.0f : x;          // x + (+0) unter DAZ: -0 und Subnormale -> +0
        if (kind == 2) c = 0.0f;
        else if (kind == 1 && !rot) {
            float r = __fmul_rn(c, scale);
            c = (fabsf(r) < FLT_MIN) ? copysignf(0.0f, r) : r;   // FTZ
        }
        g[i] = c;
    }
}
int cuda_grad_prep(void* h_key, size_t bytes, int kind, float scale, int rot) {
    if (!cuda_initialized || !h_key) return 1;
    float* d = (float*)cuda_find_buffer(h_key, bytes);
    if (!d) return 1;
    size_t n = bytes / sizeof(float);
    grad_prep_kern<<<1024, 256>>>(d, n, kind, scale, rot);
    return cudaGetLastError() == cudaSuccess ? 0 : 2;
}
static int cuda_qa_g_dev = 0;   // GPU-Adam liest g aus dem Kartenpuffer zu h_g statt ihn hochzuladen
void cuda_adam_g_dev(int on) { cuda_qa_g_dev = on; }

void cuda_sync_to_host(void* h_ptr) {
    if (!cuda_initialized || !h_ptr) return;
    for(int i = 0; i < cuda_buf_count; i++) {
        if(cuda_buf_map[i].h_ptr == h_ptr) {
            cudaMemcpy(h_ptr, cuda_buf_map[i].d_buf, cuda_buf_map[i].bytes, cudaMemcpyDeviceToHost);
            return;
        }
    }
}

// AUDIT-FIX (Punkt 2): Gegenstueck zu ocl_sync_to_device() - erzwingt einen
// Re-Upload eines schon gecachten Device-Buffers, falls die Host-Seite
// zwischenzeitlich ausserhalb dieser Bibliothek veraendert wurde. Legt den
// Buffer an, falls er noch nicht existiert (dann ist es ohnehin ein
// frischer Upload via cuda_get_buffer()).
void cuda_sync_to_device(void* h_ptr, size_t bytes) {
    if (!cuda_initialized || !h_ptr || bytes == 0) return;
    void* d_buf = cuda_get_buffer(h_ptr, bytes);
    if (d_buf) {
        cudaMemcpy(d_buf, h_ptr, bytes, cudaMemcpyHostToDevice);
    }
}

// Update 2026-08-08: Port von ocl_zero_buffer(). cudaMemset() statt
// clEnqueueFillBuffer() - CUDA hat dafuer keine eigene Kernel-Dispatch noetig.
// cudaDeviceSynchronize() danach, um exakt das blockierende Verhalten von
// OpenCLs clFinish() nachzubilden (Aufrufer darf sich auf "fertig, wenn diese
// Funktion zurueckkehrt" verlassen).
void cuda_zero_buffer(void* h_ptr, size_t bytes) {
    if (!cuda_initialized) return;
    void* d_buf = cuda_get_buffer(h_ptr, bytes);
    if (d_buf) {
        cudaMemset(d_buf, 0, bytes);
        cudaDeviceSynchronize();
    }
}

__global__ void adamUpdateKernel(float* w, float* m, float* v, float* g,
                                 float lr, float b1, float b2, float b1t, float b2t, float scale, int size, int is_sparse,
                                 int cols, int bound_r, int bound_c, float boost, float wd) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < size) {
        float grad = g[i] / scale;
        if (is_sparse == 1 && fabsf(grad) < 1e-8f) return;
        if (isnan(grad) || grad > 9999.0f || grad < -9999.0f) {
            g[i] = 0.0f;
            return;
        }
        // AUDIT-FIX (Punkt 3): LR-Boost fuer frisch Net2Net-expandierte
        // Bereiche - identische Logik wie im OpenCL-Kernel/CPU-Pfad
        // (elemBoost() in cortex.nim). cols/bound_r/bound_c beschreiben, ab
        // welcher Zeile/Spalte eine Matrix "neu" ist.
        int row = i / cols;
        int col = i % cols;
        float eff_lr = (row >= bound_r || col >= bound_c) ? (lr * boost) : lr;
        m[i] = b1 * m[i] + (1.0f - b1) * grad;
        v[i] = b2 * v[i] + (1.0f - b2) * grad * grad;
        float m_hat = m[i] / b1t;
        float v_hat = v[i] / b2t;
        w[i] -= eff_lr * m_hat / (sqrtf(v_hat) + 1e-8f);
        // AUDIT-FIX (2026-08-08): Weight-Decay (AdamW-Style, dekorreliert) -
        // nachgezogen aus ocl_adamStep. wd=0.0 (Default) ist ein exaktes
        // No-Op. Bewusst mit lr (nicht eff_lr) skaliert, identisch zum
        // OpenCL-Kernel.
        if (wd > 0.0f) { w[i] -= lr * wd * w[i]; }
        g[i] = 0.0f; // Reset Gradient
    }
}

__global__ void attentionForwardKernel(const float* q, const float* k_cache, const float* v_cache,
                                       float* att_out, float* scores, int pos, int numHeads, int headSize, int dim, int ctx) {
    int h = blockIdx.x * blockDim.x + threadIdx.x;
    if (h >= numHeads) return;

    int h_off = h * headSize;
    float scale = 1.0f / sqrtf((float)headSize);
    float max_s = -9999.0f;

    for (int t = 0; t <= pos; t++) {
        float sc = 0.0f;
        int k_off = t * dim + h_off;
        for (int d = 0; d < headSize; d++) {
            sc += q[h_off + d] * k_cache[k_off + d];
        }
        sc *= scale;
        scores[h * ctx + t] = sc;
        if (sc > max_s) max_s = sc;
    }

    float sum_e = 0.0f;
    for (int t = 0; t <= pos; t++) {
        float e = expf(scores[h * ctx + t] - max_s);
        scores[h * ctx + t] = e;
        sum_e += e;
    }

    for (int d = 0; d < headSize; d++) att_out[h_off + d] = 0.0f;
    for (int t = 0; t <= pos; t++) {
        float w = scores[h * ctx + t] / sum_e;
        int v_off = t * dim + h_off;
        for (int d = 0; d < headSize; d++) {
            att_out[h_off + d] += v_cache[v_off + d] * w;
        }
    }
}

// Update 2026-08-08 (Backward-Pass): 1:1-Uebernahme aus attentionBackward
// (cortex_opencl.nim) - gleiche Softmax-Rueckrechnung (Jacobian einer
// Softmax-gewichteten Summe), gleiche Zwischenspeicherung von w in scores[]
// und dw in d_w[] fuer die zweite Ableitungs-Passe. d_q wird pro Aufruf
// komplett ueberschrieben (=0 am Anfang, dann akkumuliert), d_k_cache/
// d_v_cache werden NUR akkumuliert (+=), NIE genullt - identisch zum
// OpenCL-Kernel muss der Aufrufer (bzw. spaeter cortex.nim) sie vor einer
// frischen Rueckwaerts-Passe selbst auf 0 setzen (z.B. per memset vor dem
// ersten Aufruf einer Sequenz).
__global__ void attentionBackwardKernel(const float* q, const float* k_cache, const float* v_cache,
                                        const float* d_att_out, float* d_q, float* d_k_cache, float* d_v_cache,
                                        float* scores, float* d_w, int pos, int numHeads, int headSize, int dim, int ctx) {
    int h = blockIdx.x * blockDim.x + threadIdx.x;
    if (h >= numHeads) return;

    int h_off = h * headSize;
    float scale = 1.0f / sqrtf((float)headSize);
    float max_s = -9999.0f;

    for (int d = 0; d < headSize; d++) d_q[h_off + d] = 0.0f;

    for (int t = 0; t <= pos; t++) {
        float sc = 0.0f;
        int k_off = t * dim + h_off;
        for (int d = 0; d < headSize; d++) sc += q[h_off + d] * k_cache[k_off + d];
        sc *= scale;
        scores[h * ctx + t] = sc;
        if (sc > max_s) max_s = sc;
    }

    float sum_e = 0.0f;
    for (int t = 0; t <= pos; t++) {
        float e = expf(scores[h * ctx + t] - max_s);
        scores[h * ctx + t] = e;
        sum_e += e;
    }

    float sum_w_dw = 0.0f;
    for (int t = 0; t <= pos; t++) {
        float w = scores[h * ctx + t] / sum_e;
        scores[h * ctx + t] = w;
        int v_off = t * dim + h_off;
        float dw = 0.0f;
        for (int d = 0; d < headSize; d++) {
            dw += d_att_out[h_off + d] * v_cache[v_off + d];
            d_v_cache[v_off + d] += d_att_out[h_off + d] * w;
        }
        d_w[h * ctx + t] = dw;
        sum_w_dw += w * dw;
    }

    for (int t = 0; t <= pos; t++) {
        float w = scores[h * ctx + t];
        float ds = w * (d_w[h * ctx + t] - sum_w_dw) * scale;
        int k_off = t * dim + h_off;
        for (int d = 0; d < headSize; d++) {
            d_q[h_off + d] += ds * k_cache[k_off + d];
            d_k_cache[k_off + d] += ds * q[h_off + d];
        }
    }
}

// Update 2026-08-08 (Einzelvektor-Ops): 1:1 aus den gleichnamigen OpenCL-
// Kernel-Strings in cortex_opencl.nim uebernommen (matVecMul, matVecMulT,
// gradAccum). Der manuelle 4er-Unroll aus dem OpenCL-Kernel wird hier NICHT
// nachgebaut - reine OpenCL-Compiler-Mikrooptimierung ohne Bedeutung fuer die
// Korrektheit, nvcc entrollt einfache Schleifen wie diese ohnehin selbst.
__global__ void matVecMulKernel(const float* M, const float* v, float* out, int rows, int cols) {
    int r = blockIdx.x * blockDim.x + threadIdx.x;
    if (r < rows) {
        float sum = 0.0f;
        for (int c = 0; c < cols; c++) {
            sum += M[(size_t)r * cols + c] * v[c];
        }
        out[r] = sum;
    }
}

__global__ void matVecMulTKernel(const float* M, const float* d_out, float* d_in, int rows, int cols, int accumulate) {
    int c = blockIdx.x * blockDim.x + threadIdx.x;
    if (c < cols) {
        float sum = 0.0f;
        size_t idx = c;
        for (int r = 0; r < rows; r++) {
            sum += M[idx] * d_out[r];
            idx += (size_t)cols;
        }
        d_in[c] = (accumulate == 1) ? (d_in[c] + sum) : sum;
    }
}

__global__ void gradAccumKernel(float* gm, const float* d_out, const float* i_v, int rows, int cols) {
    int c = blockIdx.x * blockDim.x + threadIdx.x;
    int r = blockIdx.y * blockDim.y + threadIdx.y;
    if (c < cols && r < rows) {
        gm[(size_t)r * cols + c] += d_out[r] * i_v[c];
    }
}

// ==============================================================================
// PHASE 4 DES INT8-UMBAUS
// UNGETESTET - diese Entwicklungsmaschine hat keine NVIDIA-GPU und keinen
// nvcc-Compiler (Festlegung 2026-08-19: trotzdem blind mitschreiben,
// 1:1 aus dem bereits auf echter Hardware verifizierten OpenCL-Pendant
// portiert - matVecMulI8/adamUpdateI8 in cortex_opencl.nim). Verifikation
// steht aus, sobald echte NVIDIA-Hardware verfuegbar ist.
//
// Die Planung des int8-Umbaus sah eigentlich __dp4a-Intrinsics (int8x4-
// Dot-Product, sm_61+) als Ziel vor. Bewusst NICHT hier umgesetzt: DP4A
// braucht korrektes Byte-Packing/Alignment fuer char4-Vektoren - das blind
// (ohne jede Kompilier-/Laufzeit-Pruefungsmoeglichkeit auf dieser Maschine)
// zu schreiben waere unverantwortlich fehleranfaellig. Stattdessen ein
// einfacher, direkt vom bereits verifizierten OpenCL-Kernel portierter
// Skalar-Kernel (analog zu matVecMulKernel oben, nvcc entrollt einfache
// Schleifen selbst) - correctness-first, DP4A-Vektorisierung bleibt
// expliziter Nachzieh-Schritt fuer nach der Hardware-Verifikation.
// ==============================================================================

// int8xint8->int32-GEMM, sofort auf float dequantisiert (Design-Entscheidung
// #4). Mscale: ein Skalenfaktor pro Zeile r. vScale: EIN Skalenfaktor fuer
// den ganzen (dynamisch quantisierten, auf dem HOST vorbereiteten)
// Aktivierungsvektor v - siehe Kommentar bei matVecMulI8 in
// cortex_opencl.nim (identische Begruendung, warum keine GPU-Reduktion).
__global__ void matVecMulI8Kernel(const signed char* M, const float* Mscale, const signed char* v, float vScale,
                                   float* out, int rows, int cols) {
    int r = blockIdx.x * blockDim.x + threadIdx.x;
    if (r < rows) {
        int acc = 0;
        size_t off = (size_t)r * cols;
        for (int c = 0; c < cols; c++) {
            acc += (int)M[off + c] * (int)v[c];
        }
        out[r] = (float)acc * Mscale[r] * vScale;
    }
}

// Rounded-Integer-Step Adam auf INT8-Gewichten (Design-Entscheidung #3) -
// MUSS exakt dieselbe Mathematik/denselben MAX_LSB_STEP_PER_UPDATE=4
// Trust-Region-Cap wie adamStepI8() (cortex.nim) und adamUpdateI8
// (cortex_opencl.nim) verwenden, sonst driften die drei Backends numerisch
// auseinander. wscale[row]: Skala der Zeile, zu der Element i gehoert.
#define MAX_LSB_STEP_PER_UPDATE_I8 4
__global__ void adamUpdateI8Kernel(signed char* w, const float* wscale, float* m, float* v, float* g,
                                    float lr, float b1, float b2, float b1t, float b2t, float scale, int size, int is_sparse,
                                    int cols, int bound_r, int bound_c, float boost, float wd) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < size) {
        float grad = g[i] / scale;
        if (is_sparse == 1 && fabsf(grad) < 1e-8f) return;
        if (isnan(grad) || grad > 9999.0f || grad < -9999.0f) {
            g[i] = 0.0f;
            return;
        }
        int row = i / cols;
        int col = i % cols;
        float eff_lr = (row >= bound_r || col >= bound_c) ? (lr * boost) : lr;
        float qscale = wscale[row];
        m[i] = b1 * m[i] + (1.0f - b1) * grad;
        v[i] = b2 * v[i] + (1.0f - b2) * grad * grad;
        float m_hat = m[i] / b1t;
        float v_hat = v[i] / b2t;
        float delta = eff_lr * m_hat / (sqrtf(v_hat) + 1e-8f);
        if (wd > 0.0f) { delta += lr * wd * ((float)w[i] * qscale); }
        int steps = (int)roundf(delta / qscale);
        if (steps > MAX_LSB_STEP_PER_UPDATE_I8) steps = MAX_LSB_STEP_PER_UPDATE_I8;
        if (steps < -MAX_LSB_STEP_PER_UPDATE_I8) steps = -MAX_LSB_STEP_PER_UPDATE_I8;
        if (steps != 0) {
            int newW = (int)w[i] - steps;
            if (newW > 127) newW = 127;
            if (newW < -128) newW = -128;
            w[i] = (signed char)newW;
        }
        g[i] = 0.0f;
    }
}

// Update 2026-08-08 (gebuendelte Attention): 1:1 aus attentionForwardBatched/
// attentionBackwardBatchedQuery/attentionBackwardBatchedKey (cortex_opencl.nim)
// uebernommen. OpenCL parallelisiert ueber ein 2D-NDRange (h, p) mit einem
// Chunk-Offset auf der zweiten Achse (siehe ocl_attentionForwardBatched-
// Kommentar zum AMDGPU-Watchdog) - CUDA kennt kein natives Launch-Offset,
// daher hier stattdessen ein FLACHER Thread-Index ueber (h, lokaler Index
// innerhalb des Chunks), p0 als zusaetzlicher Kernel-Parameter fuer den
// tatsaechlichen Positions-Offset. Mathematisch identisch, nur andere
// Grid/Thread-Aufteilung.
__global__ void attentionForwardBatchedKernel(const float* q_all, const float* k_cache, const float* v_cache,
                                              float* att_out_all, float* scores,
                                              int p0, int chunkLen, int numHeads, int headSize, int dim, int ctx) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= numHeads * chunkLen) return;
    int h = idx / chunkLen;
    int p = p0 + (idx % chunkLen);

    int h_off = h * headSize;
    const float* q = q_all + (size_t)p * (size_t)dim;
    float* att_out = att_out_all + (size_t)p * (size_t)dim;
    float* my_scores = scores + ((size_t)p * (size_t)numHeads + h) * (size_t)ctx;
    float scale = 1.0f / sqrtf((float)headSize);
    float max_s = -9999.0f;

    for (int t = 0; t <= p; t++) {
        float sc = 0.0f; int k_off = t * dim + h_off;
        for (int d = 0; d < headSize; d++) sc += q[h_off + d] * k_cache[k_off + d];
        sc *= scale; my_scores[t] = sc;
        if (sc > max_s) max_s = sc;
    }
    float sum_e = 0.0f;
    for (int t = 0; t <= p; t++) { float e = expf(my_scores[t] - max_s); my_scores[t] = e; sum_e += e; }
    for (int d = 0; d < headSize; d++) att_out[h_off + d] = 0.0f;
    for (int t = 0; t <= p; t++) {
        float w = my_scores[t] / sum_e;
        int v_off = t * dim + h_off;
        for (int d = 0; d < headSize; d++) att_out[h_off + d] += v_cache[v_off + d] * w;
    }
}

// Stufe A (query-parallel): d_q, weights, ds - siehe attentionBackwardBatchedQuery
// (cortex_opencl.nim) fuer die Herleitung, 1:1 uebernommen.
__global__ void attentionBackwardBatchedQueryKernel(const float* q_all, const float* k_cache, const float* v_cache,
                                                     const float* d_att_out_all, float* d_q_all,
                                                     float* weights, float* ds,
                                                     int p0, int chunkLen, int numHeads, int headSize, int dim, int ctx) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= numHeads * chunkLen) return;
    int h = idx / chunkLen;
    int p = p0 + (idx % chunkLen);

    int h_off = h * headSize;
    const float* q = q_all + (size_t)p * (size_t)dim;
    const float* d_att_out = d_att_out_all + (size_t)p * (size_t)dim;
    float* d_q = d_q_all + (size_t)p * (size_t)dim;
    float* my_w  = weights + ((size_t)p * (size_t)numHeads + h) * (size_t)ctx;
    float* my_ds = ds      + ((size_t)p * (size_t)numHeads + h) * (size_t)ctx;
    float scale = 1.0f / sqrtf((float)headSize);
    float max_s = -9999.0f;

    for (int d = 0; d < headSize; d++) d_q[h_off + d] = 0.0f;
    for (int t = 0; t <= p; t++) {
        float sc = 0.0f; int k_off = t * dim + h_off;
        for (int d = 0; d < headSize; d++) sc += q[h_off + d] * k_cache[k_off + d];
        sc *= scale; my_w[t] = sc;
        if (sc > max_s) max_s = sc;
    }
    float sum_e = 0.0f;
    for (int t = 0; t <= p; t++) { float e = expf(my_w[t] - max_s); my_w[t] = e; sum_e += e; }
    float sum_w_dw = 0.0f;
    for (int t = 0; t <= p; t++) {
        float w = my_w[t] / sum_e; my_w[t] = w;
        int v_off = t * dim + h_off; float dw = 0.0f;
        for (int d = 0; d < headSize; d++) dw += d_att_out[h_off + d] * v_cache[v_off + d];
        my_ds[t] = dw; sum_w_dw += w * dw;
    }
    for (int t = 0; t <= p; t++) {
        float w = my_w[t];
        float dw = my_ds[t];
        float ds_val = w * (dw - sum_w_dw) * scale;
        my_ds[t] = ds_val;
        int k_off = t * dim + h_off;
        for (int d = 0; d < headSize; d++) d_q[h_off + d] += ds_val * k_cache[k_off + d];
    }
}

// Stufe B (key-parallel): d_k_cache, d_v_cache - siehe attentionBackwardBatchedKey
// (cortex_opencl.nim) fuer die Race-Analyse (warum Key- statt Query-Achse).
// Nullt sein eigenes (h,t)-Segment selbst - kein Pre-Zero durch den Aufrufer
// noetig (anders als bei der Einzelpositions-Variante).
__global__ void attentionBackwardBatchedKeyKernel(const float* q_all, const float* d_att_out_all,
                                                   const float* weights, const float* ds,
                                                   float* d_k_cache, float* d_v_cache,
                                                   int t0, int chunkLen, int act, int numHeads, int headSize, int dim, int ctx) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= numHeads * chunkLen) return;
    int h = idx / chunkLen;
    int t = t0 + (idx % chunkLen);

    int h_off = h * headSize;
    int kv_off = t * dim + h_off;
    for (int d = 0; d < headSize; d++) { d_k_cache[kv_off + d] = 0.0f; d_v_cache[kv_off + d] = 0.0f; }
    for (int p = t; p < act; p++) {
        size_t idx2 = ((size_t)p * (size_t)numHeads + h) * (size_t)ctx + t;
        float w  = weights[idx2];
        float dsv = ds[idx2];
        const float* d_att_out = d_att_out_all + (size_t)p * (size_t)dim;
        const float* q = q_all + (size_t)p * (size_t)dim;
        for (int d = 0; d < headSize; d++) {
            d_v_cache[kv_off + d] += d_att_out[h_off + d] * w;
            d_k_cache[kv_off + d] += dsv * q[h_off + d];
        }
    }
}

int init_cuda_engine() {
    if (cuda_initialized) return 1;

    cudaError_t err = cudaSetDevice(0);
    if (err != cudaSuccess) return 0;

    cublasStatus_t status = cublasCreate(&cublas_handle);
    if (status != CUBLAS_STATUS_SUCCESS) return 0;

    // Aktiviert TF32 auf Tensor Cores. Nim und PHP schicken normales FP32,
    // die GPU komprimiert es intern rasant auf Tensor-Geschwindigkeit.
    // AUDIT-FIX (Punkt 4): dieser Modus wurde vorher gesetzt, aber nie
    // tatsaechlich von einem cuBLAS-Aufruf genutzt - siehe cuda_matMulBatched().
    cublasSetMathMode(cublas_handle, CUBLAS_TF32_TENSOR_OP_MATH);

    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);
    std::cerr << "⚡ [SYMBIO VRAM] CUDA Engine eingerastet: [" << prop.name << "] (TF32 Tensor Cores aktiv)" << std::endl;

    // PHASE 4 DES INT8-UMBAUS: Compute-Capability-Probe (vgl. die
    // dp4a-Planung oben). Vorher gab es HIER GAR KEINEN Capability-Check - nur
    // zu Logging-Zwecken abgefragt (prop.name oben). __dp4a (die fuer
    // spaeter vorgesehene INT8-Vektorisierung, siehe Kommentar bei
    // matVecMulI8Kernel oben) braucht sm_61+; der aktuell tatsaechlich
    // verwendete INT8-Kernel ist reiner Skalar-Code und laeuft auf JEDER
    // CUDA-Compute-Capability - dieser Check ist also informativ/vorbereitend
    // fuer die spaetere DP4A-Optimierung, blockiert aktuell nichts.
    int cc = prop.major * 10 + prop.minor;
    if (cc < 61) {
        std::cerr << "⚡ [SYMBIO VRAM] Compute Capability " << prop.major << "." << prop.minor
                   << " < 6.1 - DP4A-Vektorisierung (spaetere INT8-Optimierung) waere auf dieser"
                   << " GPU nicht verfuegbar, der aktuelle Skalar-INT8-Kernel laeuft trotzdem." << std::endl;
    } else {
        std::cerr << "⚡ [SYMBIO VRAM] Compute Capability " << prop.major << "." << prop.minor
                   << " >= 6.1 - DP4A waere verfuegbar (noch nicht implementiert, siehe Kommentar oben)." << std::endl;
    }

    cuda_initialized = true;
    return 1;
}

void shutdown_cuda_engine() {
    ep_free_all();
    for(int i=0; i < cuda_buf_count; i++) {
        cudaFree(cuda_buf_map[i].d_buf);
    }
    cuda_buf_count = 0;

    if (cuda_eph_q) { cudaFree(cuda_eph_q); cuda_eph_q = nullptr; cuda_eph_q_size = 0; }
    if (cuda_eph_out) { cudaFree(cuda_eph_out); cuda_eph_out = nullptr; cuda_eph_out_size = 0; }
    if (cuda_eph_scores) { cudaFree(cuda_eph_scores); cuda_eph_scores = nullptr; cuda_eph_scores_size = 0; }
    // Update 2026-08-08 (Backward-Pass): Gegenstuecke zu den obigen drei -
    // ohne diese Ergaenzung waeren das VRAM-Lecks bei jedem shutdown/init-Zyklus.
    if (cuda_eph_dq) { cudaFree(cuda_eph_dq); cuda_eph_dq = nullptr; cuda_eph_dq_size = 0; }
    if (cuda_eph_dw) { cudaFree(cuda_eph_dw); cuda_eph_dw = nullptr; cuda_eph_dw_size = 0; }
    if (cuda_eph_bm_r) { cudaFree(cuda_eph_bm_r); cuda_eph_bm_r = nullptr; cuda_eph_bm_r_size = 0; }
    if (cuda_eph_bm_c) { cudaFree(cuda_eph_bm_c); cuda_eph_bm_c = nullptr; cuda_eph_bm_c_size = 0; }
    if (cuda_eph_bt_a) { cudaFree(cuda_eph_bt_a); cuda_eph_bt_a = nullptr; cuda_eph_bt_a_size = 0; }
    if (cuda_eph_bt_b) { cudaFree(cuda_eph_bt_b); cuda_eph_bt_b = nullptr; cuda_eph_bt_b_size = 0; }
    if (cuda_eph_act_i8) { cudaFree(cuda_eph_act_i8); cuda_eph_act_i8 = nullptr; cuda_eph_act_i8_size = 0; }
    if (cuda_eph_att_q) { cudaFree(cuda_eph_att_q); cuda_eph_att_q = nullptr; cuda_eph_att_q_size = 0; }
    if (cuda_eph_att_out) { cudaFree(cuda_eph_att_out); cuda_eph_att_out = nullptr; cuda_eph_att_out_size = 0; }
    if (cuda_eph_att_datt) { cudaFree(cuda_eph_att_datt); cuda_eph_att_datt = nullptr; cuda_eph_att_datt_size = 0; }
    if (cuda_eph_att_dq) { cudaFree(cuda_eph_att_dq); cuda_eph_att_dq = nullptr; cuda_eph_att_dq_size = 0; }
    if (cuda_eph_att_scores) { cudaFree(cuda_eph_att_scores); cuda_eph_att_scores = nullptr; cuda_eph_att_scores_size = 0; }
    if (cuda_eph_att_ds) { cudaFree(cuda_eph_att_ds); cuda_eph_att_ds = nullptr; cuda_eph_att_ds_size = 0; }

    if (cublas_handle) cublasDestroy(cublas_handle);
    cuda_initialized = false;
    std::cerr << "⚡ [SYMBIO VRAM] CUDA-Ressourcen freigegeben." << std::endl;
}

void cuda_adamStep(float* h_w, float* h_m, float* h_v, float* h_g, float lr, float b1, float b2, float b1t, float b2t, float scale, int size, int is_sparse,
                   int cols, int bound_r, int bound_c, float boost, float wd) {
    if (!cuda_initialized) return;

    size_t bytes = (size_t)size * sizeof(float);
    float* d_w = (float*)cuda_get_buffer(h_w, bytes);
    float* d_m = (float*)cuda_get_buffer(h_m, bytes);
    float* d_v = (float*)cuda_get_buffer(h_v, bytes);
    float* d_g = (float*)cuda_get_buffer(h_g, bytes);
    // AUDIT-FIX (Punkt 7): ohne diesen Guard waere ein Registry-Overflow
    // oder Size-Mismatch ein Nullpointer-Crash statt eines kontrollierten
    // Abbruchs gewesen.
    if (!d_w || !d_m || !d_v || !d_g) return;

    cudaMemcpy(d_g, h_g, bytes, cudaMemcpyHostToDevice);

    int threadsPerBlock = 256;
    int blocksPerGrid = (size + threadsPerBlock - 1) / threadsPerBlock;

    adamUpdateKernel<<<blocksPerGrid, threadsPerBlock>>>(d_w, d_m, d_v, d_g, lr, b1, b2, b1t, b2t, scale, size, is_sparse, cols, bound_r, bound_c, boost, wd);

    cudaMemcpy(h_w, d_w, bytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_m, d_m, bytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_v, d_v, bytes, cudaMemcpyDeviceToHost);

    memset(h_g, 0, bytes); // Reset Host-Gradient
}

// PHASE 4 DES INT8-UMBAUS (UNGETESTET, siehe Kommentar bei matVecMulI8Kernel
// oben): Host-Wrapper fuer matVecMulI8Kernel, spiegelt cuda_matVecMul-Muster
// oben bzw. ocl_matVecMulI8 (cortex_opencl.nim, dort auf echter Hardware
// verifiziert). h_M/h_Mscale sind PERSISTENTE Host-Zeiger (via
// cuda_get_buffer wie bei cuda_adamStep/cuda_matMulBatched einmalig
// hochgeladen), h_v (quantisierter Aktivierungsvektor) ist EPHEMER.
void cuda_matVecMulI8(const signed char* h_M, const float* h_Mscale, const signed char* h_v, float vScale,
                      float* h_out, int rows, int cols) {
    if (!cuda_initialized || !h_M || !h_Mscale || !h_v || !h_out || rows <= 0 || cols <= 0) return;

    size_t size_M = (size_t)rows * cols * sizeof(signed char);
    size_t size_Mscale = (size_t)rows * sizeof(float);
    size_t size_v = (size_t)cols * sizeof(signed char);
    size_t size_out = (size_t)rows * sizeof(float);

    signed char* d_M = (signed char*)cuda_get_buffer((void*)h_M, size_M);
    float* d_Mscale = (float*)cuda_get_buffer((void*)h_Mscale, size_Mscale);
    if (!d_M || !d_Mscale) return;

    if (cuda_eph_act_i8_size < size_v) {
        if (cuda_eph_act_i8) cudaFree(cuda_eph_act_i8);
        cuda_eph_act_i8_size = (cudaMalloc(&cuda_eph_act_i8, size_v) == cudaSuccess) ? size_v : 0;
    }
    if (cuda_eph_out_size < size_out) {
        if (cuda_eph_out) cudaFree(cuda_eph_out);
        cuda_eph_out_size = (cudaMalloc(&cuda_eph_out, size_out) == cudaSuccess) ? size_out : 0;
    }
    if (!cuda_eph_act_i8 || !cuda_eph_out) return;

    cudaMemcpy(cuda_eph_act_i8, h_v, size_v, cudaMemcpyHostToDevice);

    int threadsPerBlock = 256;
    int blocksPerGrid = (rows + threadsPerBlock - 1) / threadsPerBlock;
    matVecMulI8Kernel<<<blocksPerGrid, threadsPerBlock>>>(d_M, d_Mscale, cuda_eph_act_i8, vScale, cuda_eph_out, rows, cols);

    cudaMemcpy(h_out, cuda_eph_out, size_out, cudaMemcpyDeviceToHost);
}

// PHASE 10 DES INT8-UMBAUS (2026-08-20, UNGETESTET): Float-Adam je Zeile MIT
// Fehler-Rueckfuehrung - 1:1 portiert aus dem auf echter AMD-Hardware
// verifizierten OpenCL-Pendant adamRowFloatI8 (cortex_opencl.nim), das dort
// bit-exakt gegen die CPU stimmt.
//
// EIN BLOCK JE ZEILE mit shared-memory-Reduktion: die neue Zeilenskala ist
// max|Zeile|/127, zwischen den beiden Durchgaengen braucht es also eine
// Reduktion ueber die ganze Zeile. blockDim.x MUSS eine Zweierpotenz sein.
// Der alte adamUpdateI8Kernel daneben rechnet weiter die Trust-Region-
// Variante und bleibt nur fuer Vergleichsmessungen stehen.
__global__ void adamRowFloatI8Kernel(signed char* w, float* wscale, float* m, float* v, float* g,
                                     float* res, float lr, float b1, float b2, float b1t, float b2t,
                                     float scale, int cols, int is_sparse, int bound_r, int bound_c,
                                     float boost, float wd, int use_fb) {
    extern __shared__ float red[];
    int row = blockIdx.x;
    int lid = threadIdx.x;
    int lsz = blockDim.x;
    size_t off = (size_t)row * (size_t)cols;
    float qscale = wscale[row];
    float localMax = 0.0f;

    // Durchgang 1: Adam in Float, Ergebnis in g zwischenspeichern
    for (int c = lid; c < cols; c += lsz) {
        size_t i = off + (size_t)c;
        float wf0 = (float)w[i] * qscale;
        float grad = g[i] / scale;
        float wf = wf0;
        if (scale != 0.0f && !isnan(grad) && grad <= 9999.0f && grad >= -9999.0f) {
            if (!(is_sparse == 1 && fabsf(grad) < 1e-8f)) {
                m[i] = b1 * m[i] + (1.0f - b1) * grad;
                v[i] = b2 * v[i] + (1.0f - b2) * grad * grad;
                float m_hat = m[i] / b1t;
                float v_hat = v[i] / b2t;
                float eff_lr = (row >= bound_r || c >= bound_c) ? (lr * boost) : lr;
                wf = wf0 - eff_lr * m_hat / (sqrtf(v_hat) + 1e-8f);
                if (wd > 0.0f) { wf -= lr * wd * wf0; }
            }
        }
        if (use_fb == 1) { wf += res[i]; }
        g[i] = wf;
        localMax = fmaxf(localMax, fabsf(wf));
    }

    red[lid] = localMax;
    __syncthreads();
    for (int st = lsz / 2; st > 0; st >>= 1) {
        if (lid < st) { red[lid] = fmaxf(red[lid], red[lid + st]); }
        __syncthreads();
    }
    float maxAbs = red[0];
    float newScale = (maxAbs > 0.0f) ? (maxAbs / 127.0f) : qscale;
    if (lid == 0) { wscale[row] = newScale; }
    float inv = 1.0f / newScale;

    // Durchgang 2: requantisieren, Rest sichern, g nullen
    for (int c = lid; c < cols; c += lsz) {
        size_t i = off + (size_t)c;
        float target = g[i];
        int q = (int)roundf(target * inv);
        if (q > 127) q = 127; else if (q < -128) q = -128;
        w[i] = (signed char)q;
        if (use_fb == 1) {
            // Deckel auf eine LSB-Breite, identisch zu CPU und OpenCL.
            float e = target - (float)q * newScale;
            if (e > newScale) e = newScale; else if (e < -newScale) e = -newScale;
            res[i] = e;
        }
        g[i] = 0.0f;
    }
}

// PHASE 4 DES INT8-UMBAUS (UNGETESTET): Host-Wrapper fuer adamUpdateI8Kernel,
// spiegelt cuda_adamStep oben bzw. ocl_adamStepI8 (auf echter Hardware
// verifiziert). h_wscale: Pro-Zeile-Skala (Laenge size/cols), PERSISTENT wie
// h_w. VORBEHALT wie bei ocl_adamStepI8 (cortex_opencl.nim): eine bereits
// hochgeladene d_wscale-Kopie wird bei einem HOST-seitigen
// cortex_rescale_weights()-Aufruf nicht automatisch aktualisiert - relevant
// erst bei voller Trainings-Loop-Integration (Phase 5).
void cuda_adamStepI8(signed char* h_w, const float* h_wscale, float* h_m, float* h_v, float* h_g,
                     float lr, float b1, float b2, float b1t, float b2t, float scale, int size, int is_sparse,
                     int cols, int bound_r, int bound_c, float boost, float wd) {
    if (!cuda_initialized || !h_w || !h_wscale || !h_m || !h_v || !h_g || size <= 0 || cols <= 0 || scale == 0.0f) return;

    size_t bytes_w = (size_t)size * sizeof(signed char);
    size_t bytes_f = (size_t)size * sizeof(float);
    int rows = size / cols;
    size_t bytes_scale = (size_t)rows * sizeof(float);

    signed char* d_w = (signed char*)cuda_get_buffer((void*)h_w, bytes_w);
    float* d_wscale = (float*)cuda_get_buffer((void*)h_wscale, bytes_scale);
    float* d_m = (float*)cuda_get_buffer(h_m, bytes_f);
    float* d_v = (float*)cuda_get_buffer(h_v, bytes_f);
    float* d_g = (float*)cuda_get_buffer(h_g, bytes_f);
    if (!d_w || !d_wscale || !d_m || !d_v || !d_g) return;

    cudaMemcpy(d_g, h_g, bytes_f, cudaMemcpyHostToDevice);

    int threadsPerBlock = 256;
    int blocksPerGrid = (size + threadsPerBlock - 1) / threadsPerBlock;
    adamUpdateI8Kernel<<<blocksPerGrid, threadsPerBlock>>>(d_w, d_wscale, d_m, d_v, d_g, lr, b1, b2, b1t, b2t, scale, size, is_sparse, cols, bound_r, bound_c, boost, wd);

    cudaMemcpy(h_w, d_w, bytes_w, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_m, d_m, bytes_f, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_v, d_v, bytes_f, cudaMemcpyDeviceToHost);

    memset(h_g, 0, bytes_f);
}

// PHASE 10 (UNGETESTET): Host-Wrapper fuer adamRowFloatI8Kernel. Anders als
// cuda_adamStepI8 SCHREIBT der Kernel die Zeilenskala - sie muss deshalb
// zurueckgelesen werden. h_res darf NULL sein (dann ohne Rueckfuehrung).
void cuda_adamRowFloatI8(signed char* h_w, float* h_wscale, float* h_m, float* h_v, float* h_g,
                         float* h_res, float lr, float b1, float b2, float b1t, float b2t,
                         float scale, int rows, int cols, int is_sparse,
                         int bound_r, int bound_c, float boost, float wd, int use_fb) {
    if (!cuda_initialized || !h_w || !h_wscale || !h_m || !h_v || !h_g || rows <= 0 || cols <= 0 || scale == 0.0f) return;

    size_t size = (size_t)rows * (size_t)cols;
    size_t bytes_w = size * sizeof(signed char);
    size_t bytes_f = size * sizeof(float);
    size_t bytes_scale = (size_t)rows * sizeof(float);
    int fb = (use_fb == 1 && h_res != nullptr) ? 1 : 0;

    signed char* d_w = (signed char*)cuda_get_buffer((void*)h_w, bytes_w);
    float* d_wscale = (float*)cuda_get_buffer((void*)h_wscale, bytes_scale);
    float* d_m = (float*)cuda_get_buffer(h_m, bytes_f);
    float* d_v = (float*)cuda_get_buffer(h_v, bytes_f);
    float* d_g = (float*)cuda_get_buffer(h_g, bytes_f);
    // Ohne Rueckfuehrung braucht der Kernel trotzdem einen gueltigen Zeiger -
    // d_g dient dann als Platzhalter und wird wegen fb==0 nie angefasst.
    float* d_res = fb ? (float*)cuda_get_buffer(h_res, bytes_f) : d_g;
    if (!d_w || !d_wscale || !d_m || !d_v || !d_g || !d_res) return;

    cudaMemcpy(d_g, h_g, bytes_f, cudaMemcpyHostToDevice);
    if (fb) cudaMemcpy(d_res, h_res, bytes_f, cudaMemcpyHostToDevice);

    // blockDim MUSS Zweierpotenz sein (Reduktion halbiert), <= cols und <= 1024
    int threadsPerBlock = 1;
    while (threadsPerBlock * 2 <= 1024 && threadsPerBlock * 2 <= cols) threadsPerBlock *= 2;
    size_t shared_bytes = (size_t)threadsPerBlock * sizeof(float);

    adamRowFloatI8Kernel<<<rows, threadsPerBlock, shared_bytes>>>(d_w, d_wscale, d_m, d_v, d_g, d_res,
        lr, b1, b2, b1t, b2t, scale, cols, is_sparse, bound_r, bound_c, boost, wd, fb);

    cudaMemcpy(h_w, d_w, bytes_w, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_wscale, d_wscale, bytes_scale, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_m, d_m, bytes_f, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_v, d_v, bytes_f, cudaMemcpyDeviceToHost);
    if (fb) cudaMemcpy(h_res, d_res, bytes_f, cudaMemcpyDeviceToHost);

    memset(h_g, 0, bytes_f);
}

void cuda_matMulBatched(const float* h_M, const float* h_in, float* h_out, int rows, int cols, int batch_size, int max_batch) {
    if (!cuda_initialized) return;

    size_t size_M = (size_t)rows * cols * sizeof(float);
    size_t active_in = (size_t)batch_size * cols * sizeof(float);
    size_t active_out = (size_t)batch_size * rows * sizeof(float);

    float* d_M = (float*)cuda_get_buffer((void*)h_M, size_M);
    float* d_in = (float*)cuda_get_buffer((void*)h_in, (size_t)max_batch * cols * sizeof(float));
    float* d_out = (float*)cuda_get_buffer((void*)h_out, (size_t)max_batch * rows * sizeof(float));
    if (!d_M || !d_in || !d_out) return;

    cudaMemcpy(d_in, h_in, active_in, cudaMemcpyHostToDevice);

    // AUDIT-FIX (Punkt 4): echtes cuBLAS-GEMM statt Handkernel, damit der
    // beim Init gesetzte TF32-Tensor-Core-Modus ueberhaupt greift.
    //
    // Gesucht (Row-Major-Semantik, identisch zum alten Handkernel):
    //   out_seq[b][r] = sum_c M[r][c] * in_seq[b][c]        (b < batch_size)
    //   M:       rows x cols
    //   in_seq:  batch x cols
    //   out_seq: batch x rows
    //
    // cuBLAS ist Column-Major. Trick: dieselbe Speicherregion, die Row-Major
    // als (p x q) gelesen wird, ist Column-Major identisch zu (q x p)^T.
    // Damit gilt (Herleitung siehe Commit-Kommentar):
    //   out_seq_cm (rows x batch) = M_cm^T (rows x cols) @ in_seq_cm (cols x batch)
    // -> transA = T (M_cm liegt als cols x rows vor, wird transponiert),
    //    transB = N, m=rows, n=batch, k=cols, lda=cols, ldb=cols, ldc=rows.
    const float alpha = 1.0f, beta = 0.0f;
    cublasSgemm(cublas_handle, CUBLAS_OP_T, CUBLAS_OP_N,
                rows, batch_size, cols,
                &alpha,
                d_M, cols,
                d_in, cols,
                &beta,
                d_out, rows);

    cudaMemcpy(h_out, d_out, active_out, cudaMemcpyDeviceToHost);
}

void cuda_attentionForward(const float* h_q, const float* h_k_cache, const float* h_v_cache, float* h_out, int pos, int numHeads, int headSize, int dim, int ctx) {
    if (!cuda_initialized || pos >= ctx) return;

    size_t size_cache = (size_t)ctx * dim * sizeof(float);
    float* d_k = (float*)cuda_get_buffer((void*)h_k_cache, size_cache);
    float* d_v = (float*)cuda_get_buffer((void*)h_v_cache, size_cache);
    if (!d_k || !d_v) return;

    size_t vec_bytes = (size_t)dim * sizeof(float);
    cudaMemcpy(d_k + ((size_t)pos * dim), h_k_cache + ((size_t)pos * dim), vec_bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_v + ((size_t)pos * dim), h_v_cache + ((size_t)pos * dim), vec_bytes, cudaMemcpyHostToDevice);

    // AUDIT-FIX (Punkt 6): persistente, wachsende Scratch-Buffer statt
    // cudaMalloc()/cudaFree() bei jedem einzelnen Aufruf (analog
    // ocl_eph_v/ocl_eph_out/ocl_eph_scores in cortex_opencl.nim, "FIX 4:
    // Robust Buffer Resize"). Bei der vorgesehenen Nutzung - ein Aufruf pro
    // generiertem Token - waere die alte Variante ein Alloc/Free pro Token.
    size_t size_scores = (size_t)numHeads * ctx * sizeof(float);
    if (cuda_eph_q_size < vec_bytes) {
        if (cuda_eph_q) cudaFree(cuda_eph_q);
        cuda_eph_q_size = (cudaMalloc(&cuda_eph_q, vec_bytes) == cudaSuccess) ? vec_bytes : 0;
    }
    if (cuda_eph_out_size < vec_bytes) {
        if (cuda_eph_out) cudaFree(cuda_eph_out);
        cuda_eph_out_size = (cudaMalloc(&cuda_eph_out, vec_bytes) == cudaSuccess) ? vec_bytes : 0;
    }
    if (cuda_eph_scores_size < size_scores) {
        if (cuda_eph_scores) cudaFree(cuda_eph_scores);
        cuda_eph_scores_size = (cudaMalloc(&cuda_eph_scores, size_scores) == cudaSuccess) ? size_scores : 0;
    }
    if (!cuda_eph_q || !cuda_eph_out || !cuda_eph_scores) return;

    cudaMemcpy(cuda_eph_q, h_q, vec_bytes, cudaMemcpyHostToDevice);

    int threads = 64;
    int blocks = (numHeads + threads - 1) / threads;
    attentionForwardKernel<<<blocks, threads>>>(cuda_eph_q, d_k, d_v, cuda_eph_out, cuda_eph_scores, pos, numHeads, headSize, dim, ctx);

    cudaMemcpy(h_out, cuda_eph_out, vec_bytes, cudaMemcpyDeviceToHost);
}

// ==============================================================================
// Update 2026-08-08: BACKWARD-PASS (Matmul + Attention)
// Ports von ocl_attentionBackward, ocl_matMulTBatched, ocl_gradAccumBatched
// (cortex_opencl.nim), samt eigens hergeleiteter
// cuBLAS-Parametrisierung der beiden Matmul-Backward-Funktionen. Attention-
// Backward bleibt bewusst die EINZELPOSITIONS-Variante (analog zum bereits
// vorhandenen cuda_attentionForward) - die gebuendelte
// attentionBackwardBatched-Variante (ocl_attentionBackwardBatched, zweistufig
// query-/key-parallel) ist weiterhin nicht Teil dieses Ports, siehe
// "keine batched Attention" im bestehenden Scope-Abschnitt oben.
// ==============================================================================

void cuda_attentionBackward(const float* h_q, const float* h_k_cache, const float* h_v_cache, const float* h_d_att_out,
                            float* h_d_q, float* h_d_k_cache, float* h_d_v_cache,
                            int pos, int numHeads, int headSize, int dim, int ctx) {
    if (!cuda_initialized || pos >= ctx) return;

    size_t size_cache = (size_t)ctx * dim * sizeof(float);
    float* d_k = (float*)cuda_get_buffer((void*)h_k_cache, size_cache);
    float* d_v = (float*)cuda_get_buffer((void*)h_v_cache, size_cache);
    // AUDIT: d_dk/d_dv sind eigene, per Host-Pointer gecachte Buffer (nicht
    // dieselben wie d_k/d_v) - der Kernel akkumuliert NUR in sie hinein,
    // liest sie aber nie. Erster Touch pro Pointer via cuda_get_buffer laedt
    // den aktuellen Host-Inhalt hoch (i.d.R. vom Aufrufer vorher genullt).
    float* d_dk = (float*)cuda_get_buffer((void*)h_d_k_cache, size_cache);
    float* d_dv = (float*)cuda_get_buffer((void*)h_d_v_cache, size_cache);
    if (!d_k || !d_v || !d_dk || !d_dv) return;

    size_t vec_bytes = (size_t)dim * sizeof(float);
    size_t size_scores = (size_t)numHeads * ctx * sizeof(float);

    // Ephemere Scratch-Buffer analog cuda_attentionForward (AUDIT-FIX Punkt 6).
    // cuda_eph_q/cuda_eph_out/cuda_eph_scores werden mit der Forward-Funktion
    // geteilt (gleiche Groessen: dim bzw. numHeads*ctx) - hier fuer q bzw.
    // d_att_out bzw. scores/weights genutzt. cuda_eph_dq/cuda_eph_dw sind
    // backward-exklusiv (analog ocl_eph_dq/ocl_eph_dw).
    if (cuda_eph_q_size < vec_bytes) {
        if (cuda_eph_q) cudaFree(cuda_eph_q);
        cuda_eph_q_size = (cudaMalloc(&cuda_eph_q, vec_bytes) == cudaSuccess) ? vec_bytes : 0;
    }
    if (cuda_eph_out_size < vec_bytes) {
        if (cuda_eph_out) cudaFree(cuda_eph_out);
        cuda_eph_out_size = (cudaMalloc(&cuda_eph_out, vec_bytes) == cudaSuccess) ? vec_bytes : 0;
    }
    if (cuda_eph_dq_size < vec_bytes) {
        if (cuda_eph_dq) cudaFree(cuda_eph_dq);
        cuda_eph_dq_size = (cudaMalloc(&cuda_eph_dq, vec_bytes) == cudaSuccess) ? vec_bytes : 0;
    }
    if (cuda_eph_scores_size < size_scores) {
        if (cuda_eph_scores) cudaFree(cuda_eph_scores);
        cuda_eph_scores_size = (cudaMalloc(&cuda_eph_scores, size_scores) == cudaSuccess) ? size_scores : 0;
    }
    if (cuda_eph_dw_size < size_scores) {
        if (cuda_eph_dw) cudaFree(cuda_eph_dw);
        cuda_eph_dw_size = (cudaMalloc(&cuda_eph_dw, size_scores) == cudaSuccess) ? size_scores : 0;
    }
    if (!cuda_eph_q || !cuda_eph_out || !cuda_eph_dq || !cuda_eph_scores || !cuda_eph_dw) return;

    cudaMemcpy(cuda_eph_q, h_q, vec_bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(cuda_eph_out, h_d_att_out, vec_bytes, cudaMemcpyHostToDevice);

    int threads = 64;
    int blocks = (numHeads + threads - 1) / threads;
    attentionBackwardKernel<<<blocks, threads>>>(cuda_eph_q, d_k, d_v, cuda_eph_out, cuda_eph_dq, d_dk, d_dv,
                                                   cuda_eph_scores, cuda_eph_dw, pos, numHeads, headSize, dim, ctx);

    cudaMemcpy(h_d_q, cuda_eph_dq, vec_bytes, cudaMemcpyDeviceToHost);
    // AUDIT: wie im OpenCL-Original wird nur die Position `pos` zurueckkopiert
    // - d_dk/d_dv akkumulieren am Device weiter ueber t=0..pos JEDES Aufrufs,
    // die frueheren Positionen werden erst beim jeweils eigenen `pos`-Durchlauf
    // (oder gar nicht, falls der Aufrufer das anders orchestriert) abgeholt.
    cudaMemcpy(h_d_k_cache + ((size_t)pos * dim), d_dk + ((size_t)pos * dim), vec_bytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_d_v_cache + ((size_t)pos * dim), d_dv + ((size_t)pos * dim), vec_bytes, cudaMemcpyDeviceToHost);
}

void cuda_matMulTBatched(const float* h_M, const float* h_d_out, float* h_d_in, int rows, int cols, int batch, int accumulate) {
    if (!cuda_initialized || !h_M || !h_d_out || !h_d_in || rows <= 0 || cols <= 0 || batch <= 0) return;

    size_t size_M = (size_t)rows * cols * sizeof(float);
    size_t size_o = (size_t)batch * rows * sizeof(float);
    size_t size_i = (size_t)batch * cols * sizeof(float);

    // d_M wird mit cuda_matMulBatched() (Forward) geteilt - gleicher
    // Host-Pointer, gleiche Groesse, kein erneuter Upload noetig.
    float* d_M = (float*)cuda_get_buffer((void*)h_M, size_M);
    if (!d_M) return;

    if (cuda_eph_bm_r_size < size_o) {
        if (cuda_eph_bm_r) cudaFree(cuda_eph_bm_r);
        cuda_eph_bm_r_size = (cudaMalloc(&cuda_eph_bm_r, size_o) == cudaSuccess) ? size_o : 0;
    }
    if (cuda_eph_bm_c_size < size_i) {
        if (cuda_eph_bm_c) cudaFree(cuda_eph_bm_c);
        cuda_eph_bm_c_size = (cudaMalloc(&cuda_eph_bm_c, size_i) == cudaSuccess) ? size_i : 0;
    }
    if (!cuda_eph_bm_r || !cuda_eph_bm_c) return;

    cudaMemcpy(cuda_eph_bm_r, h_d_out, size_o, cudaMemcpyHostToDevice);
    if (accumulate == 1) {
        cudaMemcpy(cuda_eph_bm_c, h_d_in, size_i, cudaMemcpyHostToDevice);
    }

    // Gesucht (Row-Major-Semantik, identisch zu matMulTBatched-Kernel):
    //   d_in[p][c] = sum_r M[r][c] * d_out[p][r]             (p < batch)
    //   M:      rows x cols   |   d_out: batch x rows   |   d_in: batch x cols
    //
    // Herleitung analog zum Forward-Kommentar (Row-Major-als-Column-Major-
    // Transpositionstrick): M_cm (cols x rows) = M_rm^T liegt bereits so vor
    // (ld=cols), d_out_cm (rows x batch) = d_out_rm^T liegt bereits so vor
    // (ld=rows). Gesucht ist d_in_cm (cols x batch) = d_in_rm^T:
    //   d_in_rm = d_out_rm @ M_rm  =>  d_in_rm^T = M_rm^T @ d_out_rm^T
    //   => d_in_cm = M_cm @ d_out_cm      (beides schon in der richtigen Form!)
    // -> transA = N, transB = N, m=cols, n=batch, k=rows, lda=cols, ldb=rows,
    //    ldc=cols. beta=1 bei accumulate (addiert auf vorhandenes d_in),
    //    sonst 0 (Ueberschreiben) - identisch zum `accumulate`-Flag im
    //    OpenCL-Kernel.
    const float alpha = 1.0f;
    const float beta = (accumulate == 1) ? 1.0f : 0.0f;
    cublasSgemm(cublas_handle, CUBLAS_OP_N, CUBLAS_OP_N,
                cols, batch, rows,
                &alpha,
                d_M, cols,
                cuda_eph_bm_r, rows,
                &beta,
                cuda_eph_bm_c, cols);

    cudaMemcpy(h_d_in, cuda_eph_bm_c, size_i, cudaMemcpyDeviceToHost);
}

void cuda_gradAccumBatched(float* h_gm, const float* h_d_out, const float* h_i_v, int rows, int cols, int batch) {
    if (!cuda_initialized || !h_gm || !h_d_out || !h_i_v || rows <= 0 || cols <= 0 || batch <= 0) return;

    size_t size_gm = (size_t)rows * cols * sizeof(float);
    size_t size_o = (size_t)batch * rows * sizeof(float);
    size_t size_i = (size_t)batch * cols * sizeof(float);

    // AUDIT: gm bleibt persistent im VRAM und akkumuliert ueber viele Aufrufe
    // (z.B. ein Aufruf pro Token eines Trainingsschritts) - analog
    // ocl_gradAccumBatched. Abholung erfolgt spaeter separat per
    // cuda_sync_to_host(h_gm), kein Readback hier.
    float* d_gm = (float*)cuda_get_buffer((void*)h_gm, size_gm);
    if (!d_gm) return;

    if (cuda_eph_bm_r_size < size_o) {
        if (cuda_eph_bm_r) cudaFree(cuda_eph_bm_r);
        cuda_eph_bm_r_size = (cudaMalloc(&cuda_eph_bm_r, size_o) == cudaSuccess) ? size_o : 0;
    }
    if (cuda_eph_bm_c_size < size_i) {
        if (cuda_eph_bm_c) cudaFree(cuda_eph_bm_c);
        cuda_eph_bm_c_size = (cudaMalloc(&cuda_eph_bm_c, size_i) == cudaSuccess) ? size_i : 0;
    }
    if (!cuda_eph_bm_r || !cuda_eph_bm_c) return;

    cudaMemcpy(cuda_eph_bm_r, h_d_out, size_o, cudaMemcpyHostToDevice);
    cudaMemcpy(cuda_eph_bm_c, h_i_v, size_i, cudaMemcpyHostToDevice);

    // Gesucht (Row-Major-Semantik, identisch zu gradAccumBatched-Kernel):
    //   gm[r][c] += sum_p d_out[p][r] * i_v[p][c]
    //   d_out: batch x rows   |   i_v: batch x cols   |   gm: rows x cols
    //
    // i_v_cm (cols x batch) = i_v_rm^T liegt bereits so vor (ld=cols).
    // Gesucht: gm_cm (cols x rows) = gm_rm^T:
    //   gm_rm += d_out_rm^T @ i_v_rm  =>  gm_rm^T += i_v_rm^T @ d_out_rm
    //   => gm_cm += i_v_cm @ d_out_rm
    // d_out_rm (batch x rows) ist NICHT direkt die Column-Major-Ansicht von
    // d_out (die waere d_out_cm = d_out_rm^T, rows x batch, ld=rows) - wird
    // daher ueber transB=T zurueckgeholt: op(B) = d_out_cm^T = d_out_rm.
    // -> transA = N, transB = T, m=cols, n=rows, k=batch, lda=cols, ldb=rows,
    //    ldc=cols, beta=1 (gm akkumuliert immer, kein Overwrite-Modus -
    //    identisch zum OpenCL-Kernel, der ausschliesslich `+=` kennt).
    const float alpha = 1.0f;
    const float beta = 1.0f;
    cublasSgemm(cublas_handle, CUBLAS_OP_N, CUBLAS_OP_T,
                cols, rows, batch,
                &alpha,
                cuda_eph_bm_c, cols,
                cuda_eph_bm_r, rows,
                &beta,
                d_gm, cols);
}

// ==============================================================================
// Update 2026-08-08: EINZELVEKTOR-OPS (matVecMul/matVecMulT/gradAccum)
// Ports von ocl_matVecMul, ocl_matVecMulT, ocl_gradAccum (cortex_opencl.nim).
// Bewusst Handkernel statt cuBLAS (cublasSgemv/cublasSger waeren die
// GEMM-Bibliotheks-Entsprechung) - konsistent mit der bestehenden
// Attention-Forward/Backward-Portierung, die aus demselben Grund ebenfalls
// Handkernel statt cuBLAS nutzt: bei Einzelvektor-Aufrufen (ein Token, kein
// Batch) ueberwiegt der cuBLAS-Handle-Dispatch-Overhead den moeglichen
// Tensor-Core-Vorteil, der laut obiger Einordnung ohnehin nur bei den
// batched GEMM-Operationen realistisch zum Tragen kommt.
// ==============================================================================

void cuda_matVecMul(const float* h_M, const float* h_v, float* h_out, int rows, int cols) {
    if (!cuda_initialized || !h_M || !h_v || !h_out || rows == 0 || cols == 0) return;

    size_t size_M = (size_t)rows * cols * sizeof(float);
    size_t size_v = (size_t)cols * sizeof(float);
    size_t size_out = (size_t)rows * sizeof(float);

    float* d_M = (float*)cuda_get_buffer((void*)h_M, size_M);
    if (!d_M) return;

    // Ephemere Scratch-Buffer geteilt mit cuda_attentionForward/Backward
    // (analog ocl_eph_v/ocl_eph_out, die OpenCL ebenfalls ueber matVecMul UND
    // Attention hinweg wiederverwendet) - wachsen bei Bedarf auf die jeweils
    // groesste bisher angefragte Groesse.
    if (cuda_eph_q_size < size_v) {
        if (cuda_eph_q) cudaFree(cuda_eph_q);
        cuda_eph_q_size = (cudaMalloc(&cuda_eph_q, size_v) == cudaSuccess) ? size_v : 0;
    }
    if (cuda_eph_out_size < size_out) {
        if (cuda_eph_out) cudaFree(cuda_eph_out);
        cuda_eph_out_size = (cudaMalloc(&cuda_eph_out, size_out) == cudaSuccess) ? size_out : 0;
    }
    if (!cuda_eph_q || !cuda_eph_out) return;

    cudaMemcpy(cuda_eph_q, h_v, size_v, cudaMemcpyHostToDevice);

    int threads = 256;
    int blocks = (rows + threads - 1) / threads;
    matVecMulKernel<<<blocks, threads>>>(d_M, cuda_eph_q, cuda_eph_out, rows, cols);

    cudaMemcpy(h_out, cuda_eph_out, size_out, cudaMemcpyDeviceToHost);
}

void cuda_matVecMulT(const float* h_M, const float* h_d_out, float* h_d_in, int rows, int cols, int accumulate) {
    if (!cuda_initialized || !h_M || !h_d_out || !h_d_in || rows == 0 || cols == 0) return;

    size_t size_M = (size_t)rows * cols * sizeof(float);
    size_t size_out = (size_t)rows * sizeof(float);
    size_t size_in = (size_t)cols * sizeof(float);

    float* d_M = (float*)cuda_get_buffer((void*)h_M, size_M);
    if (!d_M) return;

    if (cuda_eph_bt_a_size < size_out) {
        if (cuda_eph_bt_a) cudaFree(cuda_eph_bt_a);
        cuda_eph_bt_a_size = (cudaMalloc(&cuda_eph_bt_a, size_out) == cudaSuccess) ? size_out : 0;
    }
    if (cuda_eph_bt_b_size < size_in) {
        if (cuda_eph_bt_b) cudaFree(cuda_eph_bt_b);
        cuda_eph_bt_b_size = (cudaMalloc(&cuda_eph_bt_b, size_in) == cudaSuccess) ? size_in : 0;
    }
    if (!cuda_eph_bt_a || !cuda_eph_bt_b) return;

    cudaMemcpy(cuda_eph_bt_a, h_d_out, size_out, cudaMemcpyHostToDevice);
    if (accumulate == 1) {
        cudaMemcpy(cuda_eph_bt_b, h_d_in, size_in, cudaMemcpyHostToDevice);
    }

    int threads = 256;
    int blocks = (cols + threads - 1) / threads;
    matVecMulTKernel<<<blocks, threads>>>(d_M, cuda_eph_bt_a, cuda_eph_bt_b, rows, cols, accumulate);

    cudaMemcpy(h_d_in, cuda_eph_bt_b, size_in, cudaMemcpyDeviceToHost);
}

void cuda_gradAccum(float* h_gm, const float* h_d_out, const float* h_i_v, int rows, int cols) {
    if (!cuda_initialized || !h_gm || !h_d_out || !h_i_v || rows == 0 || cols == 0) return;

    size_t size_gm = (size_t)rows * cols * sizeof(float);
    size_t size_out = (size_t)rows * sizeof(float);
    size_t size_in = (size_t)cols * sizeof(float);

    // AUDIT: gm bleibt persistent im VRAM (analog ocl_gradAccum) - kein
    // Readback hier, Abholung ueber das bestehende cuda_sync_to_host().
    float* d_gm = (float*)cuda_get_buffer((void*)h_gm, size_gm);
    if (!d_gm) return;

    if (cuda_eph_bt_a_size < size_out) {
        if (cuda_eph_bt_a) cudaFree(cuda_eph_bt_a);
        cuda_eph_bt_a_size = (cudaMalloc(&cuda_eph_bt_a, size_out) == cudaSuccess) ? size_out : 0;
    }
    if (cuda_eph_bt_b_size < size_in) {
        if (cuda_eph_bt_b) cudaFree(cuda_eph_bt_b);
        cuda_eph_bt_b_size = (cudaMalloc(&cuda_eph_bt_b, size_in) == cudaSuccess) ? size_in : 0;
    }
    if (!cuda_eph_bt_a || !cuda_eph_bt_b) return;

    cudaMemcpy(cuda_eph_bt_a, h_d_out, size_out, cudaMemcpyHostToDevice);
    cudaMemcpy(cuda_eph_bt_b, h_i_v, size_in, cudaMemcpyHostToDevice);

    dim3 threads(16, 16);
    dim3 blocks((cols + threads.x - 1) / threads.x, (rows + threads.y - 1) / threads.y);
    gradAccumKernel<<<blocks, threads>>>(d_gm, cuda_eph_bt_a, cuda_eph_bt_b, rows, cols);
    // Kein Readback: gm bleibt im VRAM und akkumuliert weiter (wie ocl_gradAccum).
}

// ==============================================================================
// Update 2026-08-08: GEBUENDELTE ATTENTION (Forward + Backward)
// Ports von ocl_attentionForwardBatched/ocl_attentionBackwardBatched
// (cortex_opencl.nim) - letzte verbliebene Luecke aus der urspruenglichen
// Lueckenliste vom 2026-08-06. Siehe Kernel-Kommentare oben fuer die
// Grid/Thread-Aufteilung (flacher Index statt 2D-NDRange-Offset).
// ==============================================================================

void cuda_attentionForwardBatched(const float* h_q_all, const float* h_k_cache, const float* h_v_cache,
                                   float* h_att_out_all, int act, int numHeads, int headSize, int dim, int ctx) {
    if (!cuda_initialized || !h_q_all || !h_k_cache || !h_v_cache || !h_att_out_all || act <= 0) return;

    size_t size_cache = (size_t)ctx * dim * sizeof(float);
    size_t size_qout = (size_t)act * dim * sizeof(float);
    size_t size_scores = (size_t)act * numHeads * ctx * sizeof(float);

    float* d_k = (float*)cuda_get_buffer((void*)h_k_cache, size_cache);
    float* d_v = (float*)cuda_get_buffer((void*)h_v_cache, size_cache);
    if (!d_k || !d_v) return;

    // AUDIT-FIX-Analogie (siehe ocl_attentionForwardBatched): cuda_get_buffer()
    // laedt nur beim allerersten Aufruf fuer einen Host-Pointer automatisch
    // hoch. Bei Cache-Hit muss der aktuelle Stand (die gerade frisch
    // berechneten ersten act*dim Floats von k_cache/v_cache) explizit
    // nachgeladen werden, sonst rechnet die GPU im naechsten Trainingsschritt
    // mit veralteten K/V-Werten - OpenCL-Kommentar dazu: empirisch bis zu
    // 0.013 Loss-Differenz ohne diesen Fix, 0.0 mit ihm.
    cudaMemcpy(d_k, h_k_cache, size_qout, cudaMemcpyHostToDevice);
    cudaMemcpy(d_v, h_v_cache, size_qout, cudaMemcpyHostToDevice);

    if (cuda_eph_att_q_size < size_qout) {
        if (cuda_eph_att_q) cudaFree(cuda_eph_att_q);
        cuda_eph_att_q_size = (cudaMalloc(&cuda_eph_att_q, size_qout) == cudaSuccess) ? size_qout : 0;
    }
    if (cuda_eph_att_out_size < size_qout) {
        if (cuda_eph_att_out) cudaFree(cuda_eph_att_out);
        cuda_eph_att_out_size = (cudaMalloc(&cuda_eph_att_out, size_qout) == cudaSuccess) ? size_qout : 0;
    }
    if (cuda_eph_att_scores_size < size_scores) {
        if (cuda_eph_att_scores) cudaFree(cuda_eph_att_scores);
        cuda_eph_att_scores_size = (cudaMalloc(&cuda_eph_att_scores, size_scores) == cudaSuccess) ? size_scores : 0;
    }
    if (!cuda_eph_att_q || !cuda_eph_att_out || !cuda_eph_att_scores) return;

    cudaMemcpy(cuda_eph_att_q, h_q_all, size_qout, cudaMemcpyHostToDevice);

    // ATT_POS_CHUNK-Bloecke statt eines Riesen-Dispatch (siehe Konstanten-
    // Kommentar oben).
    // threads 8 statt 256 (2026-10-30, messbuch snai/multistack-att-threads-karte): bytegleich,
    // dim 2048/ctx 1024 rund 11 % schneller, 1 Kopf/ctx 1024 Faktor 2,6; ctx 64 unter 10 %.
    int threads = 8;
    for (int p0 = 0; p0 < act; p0 += ATT_POS_CHUNK) {
        int chunkLen = (act - p0) < ATT_POS_CHUNK ? (act - p0) : ATT_POS_CHUNK;
        int total = numHeads * chunkLen;
        int blocks = (total + threads - 1) / threads;
        attentionForwardBatchedKernel<<<blocks, threads>>>(cuda_eph_att_q, d_k, d_v, cuda_eph_att_out,
                                                             cuda_eph_att_scores, p0, chunkLen, numHeads, headSize, dim, ctx);
    }

    cudaMemcpy(h_att_out_all, cuda_eph_att_out, size_qout, cudaMemcpyDeviceToHost);
}

void cuda_attentionBackwardBatched(const float* h_q_all, const float* h_k_cache, const float* h_v_cache,
                                    const float* h_d_att_out_all, float* h_d_q_all,
                                    float* h_d_k_cache, float* h_d_v_cache,
                                    int act, int numHeads, int headSize, int dim, int ctx) {
    if (!cuda_initialized || !h_q_all || !h_k_cache || !h_v_cache || !h_d_att_out_all ||
        !h_d_q_all || !h_d_k_cache || !h_d_v_cache || act <= 0) return;

    size_t size_cache = (size_t)ctx * dim * sizeof(float);
    size_t size_qout = (size_t)act * dim * sizeof(float);
    size_t size_scores = (size_t)act * numHeads * ctx * sizeof(float);

    float* d_k = (float*)cuda_get_buffer((void*)h_k_cache, size_cache);
    float* d_v = (float*)cuda_get_buffer((void*)h_v_cache, size_cache);
    float* d_dk = (float*)cuda_get_buffer((void*)h_d_k_cache, size_cache);
    float* d_dv = (float*)cuda_get_buffer((void*)h_d_v_cache, size_cache);
    if (!d_k || !d_v || !d_dk || !d_dv) return;

    // d_k/d_v sind Lese-Inputs, muessen bei jedem Aufruf frisch hochgeladen
    // werden (siehe cuda_attentionForwardBatched). d_dk/d_dv sind reine
    // Schreib-Ziele - Stufe B nullt und befuellt ihr (h,t)-Segment selbst,
    // kein Pre-Upload noetig.
    cudaMemcpy(d_k, h_k_cache, size_qout, cudaMemcpyHostToDevice);
    cudaMemcpy(d_v, h_v_cache, size_qout, cudaMemcpyHostToDevice);

    if (cuda_eph_att_q_size < size_qout) {
        if (cuda_eph_att_q) cudaFree(cuda_eph_att_q);
        cuda_eph_att_q_size = (cudaMalloc(&cuda_eph_att_q, size_qout) == cudaSuccess) ? size_qout : 0;
    }
    if (cuda_eph_att_datt_size < size_qout) {
        if (cuda_eph_att_datt) cudaFree(cuda_eph_att_datt);
        cuda_eph_att_datt_size = (cudaMalloc(&cuda_eph_att_datt, size_qout) == cudaSuccess) ? size_qout : 0;
    }
    if (cuda_eph_att_dq_size < size_qout) {
        if (cuda_eph_att_dq) cudaFree(cuda_eph_att_dq);
        cuda_eph_att_dq_size = (cudaMalloc(&cuda_eph_att_dq, size_qout) == cudaSuccess) ? size_qout : 0;
    }
    if (cuda_eph_att_scores_size < size_scores) {
        if (cuda_eph_att_scores) cudaFree(cuda_eph_att_scores);
        cuda_eph_att_scores_size = (cudaMalloc(&cuda_eph_att_scores, size_scores) == cudaSuccess) ? size_scores : 0;
    }
    if (cuda_eph_att_ds_size < size_scores) {
        if (cuda_eph_att_ds) cudaFree(cuda_eph_att_ds);
        cuda_eph_att_ds_size = (cudaMalloc(&cuda_eph_att_ds, size_scores) == cudaSuccess) ? size_scores : 0;
    }
    if (!cuda_eph_att_q || !cuda_eph_att_datt || !cuda_eph_att_dq || !cuda_eph_att_scores || !cuda_eph_att_ds) return;

    cudaMemcpy(cuda_eph_att_q, h_q_all, size_qout, cudaMemcpyHostToDevice);
    cudaMemcpy(cuda_eph_att_datt, h_d_att_out_all, size_qout, cudaMemcpyHostToDevice);

    int threads = 8;   // siehe cuda_attentionForwardBatched, messbuch snai/multistack-att-threads-karte

    // Stufe A: query-parallel (d_q, weights, ds).
    for (int p0 = 0; p0 < act; p0 += ATT_POS_CHUNK) {
        int chunkLen = (act - p0) < ATT_POS_CHUNK ? (act - p0) : ATT_POS_CHUNK;
        int total = numHeads * chunkLen;
        int blocks = (total + threads - 1) / threads;
        attentionBackwardBatchedQueryKernel<<<blocks, threads>>>(cuda_eph_att_q, d_k, d_v, cuda_eph_att_datt,
                                                                   cuda_eph_att_dq, cuda_eph_att_scores, cuda_eph_att_ds,
                                                                   p0, chunkLen, numHeads, headSize, dim, ctx);
    }

    // Stufe B: key-parallel (d_k_cache, d_v_cache).
    for (int t0 = 0; t0 < act; t0 += ATT_POS_CHUNK) {
        int chunkLen = (act - t0) < ATT_POS_CHUNK ? (act - t0) : ATT_POS_CHUNK;
        int total = numHeads * chunkLen;
        int blocks = (total + threads - 1) / threads;
        attentionBackwardBatchedKeyKernel<<<blocks, threads>>>(cuda_eph_att_q, cuda_eph_att_datt,
                                                                 cuda_eph_att_scores, cuda_eph_att_ds,
                                                                 d_dk, d_dv, t0, chunkLen, act, numHeads, headSize, dim, ctx);
    }

    // Nur die tatsaechlich beschriebenen 'act' Positionen zurueckholen (nicht
    // den gesamten ctx-grossen Cache).
    cudaMemcpy(h_d_q_all, cuda_eph_att_dq, size_qout, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_d_k_cache, d_dk, size_qout, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_d_v_cache, d_dv, size_qout, cudaMemcpyDeviceToHost);
}

// ==============================================================================
// INT8-ANSCHLUSS (2026-10-13): die im Ganzzahl-Training benutzten Kerne
// ------------------------------------------------------------------------------
// 1:1 nach den OpenCL-Kernen in cortex_opencl.nim (dort auf AMD-Hardware
// bit-exakt gegen die CPU geprueft); auf einer RTX 3050 gepaart gegen die CPU
// gelaufen (Pruefstand cuda_i8, mit vorab festgelegten Kriterien).
//
// GLEITKOMMA: nvcc fasst a*b+c standardmaessig zu einem FMA zusammen. Die CPU
// (gcc ohne -march) tut das nicht - das Ergebnis wiche im letzten Bit ab und
// die Laeufe waeren nicht mehr bitgleich vergleichbar. Deshalb durchgehend
// __fmul_rn/__fadd_rn (werden nie zusammengefasst) statt -fmad=false fuer die
// ganze Datei: die Gleitkomma-Kerne oben bleiben, wie sie waren.
//
// FEHLER SIND LAUT: scheitert ein Puffer, schreibt die Funktion eine Zeile auf
// stderr. Die OpenCL-Vorlage kehrt in dem Fall still zurueck; der Aufrufer
// rechnet dann mit einem unberuehrten Ausgabepuffer weiter.
// ==============================================================================
static long cuda_gradacc_calls = 0;
static long cuda_bw_din_calls = 0;
static void* cuda_i8_e_in = nullptr;   static size_t cuda_i8_e_in_size = 0;    // int8: Aktivierungen / dq / qd
static void* cuda_i8_e_in2 = nullptr;  static size_t cuda_i8_e_in2_size = 0;   // int8: qi
static void* cuda_i8_e_sc = nullptr;   static size_t cuda_i8_e_sc_size = 0;    // float: Skalen
static void* cuda_i8_e_sc2 = nullptr;  static size_t cuda_i8_e_sc2_size = 0;   // float: zweite Skala
static void* cuda_i8_e_a = nullptr;    static size_t cuda_i8_e_a_size = 0;     // float: Eingabeblock
static void* cuda_i8_e_b = nullptr;    static size_t cuda_i8_e_b_size = 0;     // float: Ausgabeblock
static void* cuda_i8_e_gm = nullptr;   static size_t cuda_i8_e_gm_size = 0;    // float: Gradient (Host-Fall)

static bool cuda_i8_ensure(void** buf, size_t* have, size_t need) {
    if (*buf && *have >= need) return true;
    if (*buf) { cudaFree(*buf); *buf = nullptr; *have = 0; }
    if (cudaMalloc(buf, need) != cudaSuccess) { *buf = nullptr; return false; }
    *have = need;
    return true;
}
static void cuda_i8_fail(const char* wo) {
    std::cerr << "🚨 [SYMBIO CUDA] " << wo << ": Puffer fehlt oder Kernel-Fehler - Ergebnis NICHT berechnet" << std::endl;
}
static bool cuda_i8_ok(const char* wo) {
    cudaError_t e = cudaGetLastError();
    if (e != cudaSuccess) { std::cerr << "🚨 [SYMBIO CUDA] " << wo << ": " << cudaGetErrorString(e) << std::endl; return false; }
    return true;
}

long cuda_get_gradacc_calls() { return cuda_gradacc_calls; }
long cuda_get_bw_din_calls() { return cuda_bw_din_calls; }

// Bytesumme eines geraeteresidenten Puffers (Diagnose, wie ocl_device_checksum). -1 = kein Puffer.
long cuda_device_checksum(void* h_ptr, size_t bytes) {
    if (!cuda_initialized || !h_ptr || bytes == 0) return -1;
    void* d_buf = nullptr;
    for (int i = 0; i < cuda_buf_count; i++) {
        if (cuda_buf_map[i].h_ptr == h_ptr) { d_buf = cuda_buf_map[i].d_buf; break; }
    }
    if (!d_buf) return -1;
    signed char* tmp = (signed char*)malloc(bytes);
    if (!tmp) return -1;
    cudaMemcpy(tmp, d_buf, bytes, cudaMemcpyDeviceToHost);
    long sum = 0;
    for (size_t i = 0; i < bytes; i++) sum += (long)tmp[i];
    free(tmp);
    return sum;
}

// Gewichte UND Zeilenskalen nach einer Host-Aenderung neu hochladen (wie ocl_push_qmatrix).
void cuda_push_qmatrix(const signed char* h_data, const float* h_scale, int rows, int cols) {
    if (!cuda_initialized || !h_data || !h_scale || rows <= 0 || cols <= 0) return;
    cuda_sync_to_device((void*)h_data, (size_t)rows * (size_t)cols * sizeof(signed char));
    cuda_sync_to_device((void*)h_scale, (size_t)rows * sizeof(float));
}

// OUT[p*rows + r] = (sum_c M[r,c] * IN[p,c]) * Mscale[r] * inScale[p]
__global__ void matMulBatchedI8Kernel(const signed char* M, const float* Mscale,
                                      const signed char* IN, const float* inScale,
                                      float* OUT, int rows, int cols, int batch) {
    size_t idx = (size_t)blockIdx.x * (size_t)blockDim.x + (size_t)threadIdx.x;
    if (idx >= (size_t)rows * (size_t)batch) return;
    int p = (int)(idx / (size_t)rows);
    int r = (int)(idx % (size_t)rows);
    int acc = 0;
    size_t mo = (size_t)r * (size_t)cols;
    size_t io = (size_t)p * (size_t)cols;
    for (int c = 0; c < cols; ++c) acc += (int)M[mo + c] * (int)IN[io + c];
    OUT[idx] = __fmul_rn(__fmul_rn((float)acc, Mscale[r]), inScale[p]);
}


// ---------------------------------------------------------------------------------------------------------
// Schneller Vorwaerts-Kern (Arbeitskopie 2026-10-14, patch_fwd_tiled.py). Kachel 64 Zeilen x 64 Positionen,
// 16x16 Faden, je Faden 4x4 Ausgaben; K in Schritten von 16 Worten (64 int8) ueber Shared Memory, __dp4a.
// Faden-x laeuft ueber die Zeilen r: benachbarte Faden schreiben benachbarte OUT[p*rows + r] (gebuendelt).
// Bitgleich zum alten Kern und zur CPU: int32-Summe (reihenfolgeunabhaengig), Ausgabe mit denselben zwei
// gerundeten Multiplikationen.
#define FWD_T 64
#define FWD_KW 16
__global__ void matMulBatchedI8TiledKernel(const signed char* M, const float* Mscale,
                                           const signed char* IN, const float* inScale,
                                           float* OUT, int rows, int cols, int batch, int rot) {
    __shared__ int sM[FWD_T][FWD_KW + 1];
    __shared__ int sI[FWD_T][FWD_KW + 1];
    const int tx = threadIdx.x & 15, ty = threadIdx.x >> 4;
    const int r0 = blockIdx.x * FWD_T, p0 = blockIdx.y * FWD_T;
    const int K4 = cols >> 2;
    int acc[4][4];
    #pragma unroll
    for (int i = 0; i < 4; ++i)
        #pragma unroll
        for (int j = 0; j < 4; ++j) acc[i][j] = 0;
    for (int k0 = 0; k0 < K4; k0 += FWD_KW) {
        for (int e = threadIdx.x; e < FWD_T * FWD_KW; e += 256) {
            const int rr = e / FWD_KW, kk = e % FWD_KW, gk = k0 + kk;
            const int gr = r0 + rr, gp = p0 + rr;
            sM[rr][kk] = (gr < rows && gk < K4) ? ((const int*)(M  + (size_t)gr * (size_t)cols))[gk] : 0;
            sI[rr][kk] = (gp < batch && gk < K4) ? ((const int*)(IN + (size_t)gp * (size_t)cols))[gk] : 0;
        }
        __syncthreads();
        #pragma unroll
        for (int kk = 0; kk < FWD_KW; ++kk) {
            int a[4], b[4];
            #pragma unroll
            for (int i = 0; i < 4; ++i) a[i] = sM[tx + 16 * i][kk];
            #pragma unroll
            for (int j = 0; j < 4; ++j) b[j] = sI[ty + 16 * j][kk];
            #pragma unroll
            for (int i = 0; i < 4; ++i)
                #pragma unroll
                for (int j = 0; j < 4; ++j) acc[i][j] = __dp4a(a[i], b[j], acc[i][j]);
        }
        __syncthreads();
    }
    #pragma unroll
    for (int i = 0; i < 4; ++i) {
        const int r = r0 + tx + 16 * i;
        if (r >= rows) continue;
        #pragma unroll
        for (int j = 0; j < 4; ++j) {
            const int pp = p0 + ty + 16 * j;
            if (pp >= batch) continue;
            int a = acc[i][j];
            if (rot && r == rows - 1 && pp == batch - 1) a += 1;   // letztes Element: Kachelrand, Zufallsdaten
            OUT[(size_t)pp * (size_t)rows + (size_t)r] = __fmul_rn(__fmul_rn((float)a, Mscale[r]), inScale[pp]);
        }
    }
}
static int cuda_fwd_mode = -1;   // 0 alt, 1 Kachel, 2 Kachel + ROT
static int cuda_fwd_get_mode() {
    if (cuda_fwd_mode < 0) {
        const char* e = getenv("SNAI_CUDA_FWD");
        cudaDeviceProp prop; cudaGetDeviceProperties(&prop, 0);
        const int cc = prop.major * 10 + prop.minor;
        if (cc < 61) cuda_fwd_mode = 0;              // __dp4a erst ab sm_61
        else if (!e || !*e || strcmp(e, "1") == 0) cuda_fwd_mode = 1;
        else if (strcmp(e, "ROT") == 0) cuda_fwd_mode = 2;
        else cuda_fwd_mode = 0;
        fprintf(stderr, "[CUDA-FWD] Vorwaertskern: %s\n",
                cuda_fwd_mode == 0 ? "alt (SNAI_CUDA_FWD=0)" : cuda_fwd_mode == 2 ? "Kachel ROT-PROBE" : "Kachel (dp4a)");
    }
    return cuda_fwd_mode;
}

void cuda_matMulBatchedI8(const signed char* h_M, const float* h_Mscale,
                          const signed char* h_in, const float* h_inScale,
                          float* h_out, int rows, int cols, int batch) {
    if (!cuda_initialized || !h_M || !h_Mscale || !h_in || !h_inScale || !h_out ||
        rows <= 0 || cols <= 0 || batch <= 0) return;
    size_t size_M  = (size_t)rows * (size_t)cols * sizeof(signed char);
    size_t size_Ms = (size_t)rows * sizeof(float);
    size_t size_i  = (size_t)batch * (size_t)cols * sizeof(signed char);
    size_t size_sc = (size_t)batch * sizeof(float);
    size_t size_o  = (size_t)batch * (size_t)rows * sizeof(float);
    signed char* d_M = (signed char*)cuda_get_buffer((void*)h_M, size_M);
    float* d_Ms = (float*)cuda_get_buffer((void*)h_Mscale, size_Ms);
    if (!d_M || !d_Ms || !cuda_i8_ensure(&cuda_i8_e_in, &cuda_i8_e_in_size, size_i) ||
        !cuda_i8_ensure(&cuda_i8_e_sc, &cuda_i8_e_sc_size, size_sc) ||
        !cuda_i8_ensure(&cuda_i8_e_b, &cuda_i8_e_b_size, size_o)) { cuda_i8_fail("matMulBatchedI8"); return; }
    cudaMemcpy(cuda_i8_e_in, h_in, size_i, cudaMemcpyHostToDevice);
    cudaMemcpy(cuda_i8_e_sc, h_inScale, size_sc, cudaMemcpyHostToDevice);
    const int fm = cuda_fwd_get_mode();
    if (fm > 0 && (cols % 4) == 0) {
        dim3 grid((unsigned)((rows + FWD_T - 1) / FWD_T), (unsigned)((batch + FWD_T - 1) / FWD_T));
        matMulBatchedI8TiledKernel<<<grid, 256>>>(d_M, d_Ms, (const signed char*)cuda_i8_e_in,
                                                 (const float*)cuda_i8_e_sc, (float*)cuda_i8_e_b,
                                                 rows, cols, batch, fm == 2 ? 1 : 0);
    } else {
        size_t total = (size_t)rows * (size_t)batch;
        int tpb = 256;
        int blocks = (int)((total + tpb - 1) / tpb);
        matMulBatchedI8Kernel<<<blocks, tpb>>>(d_M, d_Ms, (const signed char*)cuda_i8_e_in, (const float*)cuda_i8_e_sc,
                                               (float*)cuda_i8_e_b, rows, cols, batch);
    }
    cudaMemcpy(h_out, cuda_i8_e_b, size_o, cudaMemcpyDeviceToHost);
    cuda_i8_ok("matMulBatchedI8");
}

// d_in[c] = sum_r M[r,c] * (Mscale[r] * d_out[r])   (Gleitkomma-Backward, Einzelposition)
__global__ void matVecMulTI8Kernel(const signed char* M, const float* Mscale, const float* d_out,
                                   float* d_in, int rows, int cols, int accumulate) {
    int c = blockIdx.x * blockDim.x + threadIdx.x;
    if (c >= cols) return;
    float sum = 0.0f;
    size_t idx = (size_t)c;
    for (int r = 0; r < rows; ++r) {
        sum = __fadd_rn(sum, __fmul_rn((float)M[idx], __fmul_rn(Mscale[r], d_out[r])));
        idx += (size_t)cols;
    }
    d_in[c] = (accumulate == 1) ? __fadd_rn(d_in[c], sum) : sum;
}

void cuda_matVecMulTI8(const signed char* h_M, const float* h_Mscale, const float* h_d_out,
                       float* h_d_in, int rows, int cols, int accumulate) {
    if (!cuda_initialized || !h_M || !h_Mscale || !h_d_out || !h_d_in || rows <= 0 || cols <= 0) return;
    size_t size_M  = (size_t)rows * (size_t)cols * sizeof(signed char);
    size_t size_Ms = (size_t)rows * sizeof(float);
    size_t size_o  = (size_t)rows * sizeof(float);
    size_t size_i  = (size_t)cols * sizeof(float);
    signed char* d_M = (signed char*)cuda_get_buffer((void*)h_M, size_M);
    float* d_Ms = (float*)cuda_get_buffer((void*)h_Mscale, size_Ms);
    if (!d_M || !d_Ms || !cuda_i8_ensure(&cuda_i8_e_a, &cuda_i8_e_a_size, size_o) ||
        !cuda_i8_ensure(&cuda_i8_e_b, &cuda_i8_e_b_size, size_i)) { cuda_i8_fail("matVecMulTI8"); return; }
    cudaMemcpy(cuda_i8_e_a, h_d_out, size_o, cudaMemcpyHostToDevice);
    if (accumulate == 1) cudaMemcpy(cuda_i8_e_b, h_d_in, size_i, cudaMemcpyHostToDevice);
    int tpb = 256;
    int blocks = (cols + tpb - 1) / tpb;
    matVecMulTI8Kernel<<<blocks, tpb>>>(d_M, d_Ms, (const float*)cuda_i8_e_a, (float*)cuda_i8_e_b, rows, cols, accumulate);
    cudaMemcpy(h_d_in, cuda_i8_e_b, size_i, cudaMemcpyDeviceToHost);
    cuda_i8_ok("matVecMulTI8");
}

// D_IN[p*cols + c] = sum_r M[r,c] * (Mscale[r] * D_OUT[p*rows + r])   (Gleitkomma-Backward, gebuendelt)
__global__ void matMulTBatchedI8Kernel(const signed char* M, const float* Mscale, const float* D_OUT,
                                       float* D_IN, int rows, int cols, int batch, int accumulate) {
    size_t o = (size_t)blockIdx.x * (size_t)blockDim.x + (size_t)threadIdx.x;
    if (o >= (size_t)cols * (size_t)batch) return;
    int p = (int)(o / (size_t)cols);
    int c = (int)(o % (size_t)cols);
    const float* d = D_OUT + (size_t)p * (size_t)rows;
    float sum = 0.0f;
    size_t idx = (size_t)c;
    for (int r = 0; r < rows; ++r) {
        sum = __fadd_rn(sum, __fmul_rn((float)M[idx], __fmul_rn(Mscale[r], d[r])));
        idx += (size_t)cols;
    }
    D_IN[o] = (accumulate == 1) ? __fadd_rn(D_IN[o], sum) : sum;
}

void cuda_matMulTBatchedI8(const signed char* h_M, const float* h_Mscale, const float* h_d_out,
                           float* h_d_in, int rows, int cols, int batch, int accumulate) {
    if (!cuda_initialized || !h_M || !h_Mscale || !h_d_out || !h_d_in ||
        rows <= 0 || cols <= 0 || batch <= 0) return;
    size_t size_M  = (size_t)rows * (size_t)cols * sizeof(signed char);
    size_t size_Ms = (size_t)rows * sizeof(float);
    size_t size_o  = (size_t)batch * (size_t)rows * sizeof(float);
    size_t size_i  = (size_t)batch * (size_t)cols * sizeof(float);
    signed char* d_M = (signed char*)cuda_get_buffer((void*)h_M, size_M);
    float* d_Ms = (float*)cuda_get_buffer((void*)h_Mscale, size_Ms);
    if (!d_M || !d_Ms || !cuda_i8_ensure(&cuda_i8_e_a, &cuda_i8_e_a_size, size_o) ||
        !cuda_i8_ensure(&cuda_i8_e_b, &cuda_i8_e_b_size, size_i)) { cuda_i8_fail("matMulTBatchedI8"); return; }
    cudaMemcpy(cuda_i8_e_a, h_d_out, size_o, cudaMemcpyHostToDevice);
    if (accumulate == 1) cudaMemcpy(cuda_i8_e_b, h_d_in, size_i, cudaMemcpyHostToDevice);
    size_t total = (size_t)cols * (size_t)batch;
    int tpb = 256;
    int blocks = (int)((total + tpb - 1) / tpb);
    matMulTBatchedI8Kernel<<<blocks, tpb>>>(d_M, d_Ms, (const float*)cuda_i8_e_a, (float*)cuda_i8_e_b,
                                            rows, cols, batch, accumulate);
    cudaMemcpy(h_d_in, cuda_i8_e_b, size_i, cudaMemcpyDeviceToHost);
    cuda_i8_ok("matMulTBatchedI8");
}

// Ganzzahl-Backward, Einzelposition: je Block int-Akkumulation, danach Blockskala.
__global__ void backwardDInI8Kernel(const signed char* W, const signed char* dq, const float* bscale,
                                    float* d_in, int rows, int cols, int blockSize, int accumulate) {
    int c = blockIdx.x * blockDim.x + threadIdx.x;
    if (c >= cols) return;
    float acc = (accumulate == 1) ? d_in[c] : 0.0f;
    int nblocks = (rows + blockSize - 1) / blockSize;
    for (int b = 0; b < nblocks; ++b) {
        float s = bscale[b];
        if (s <= 0.0f) continue;
        int r0 = b * blockSize;
        int r1 = r0 + blockSize; if (r1 > rows) r1 = rows;
        int iacc = 0;
        size_t idx = (size_t)r0 * (size_t)cols + (size_t)c;
        for (int r = r0; r < r1; ++r) { iacc += (int)W[idx] * (int)dq[r]; idx += (size_t)cols; }
        acc = __fadd_rn(acc, __fmul_rn((float)iacc, s));
    }
    d_in[c] = acc;
}

void cuda_backwardDInI8(const signed char* h_W, const signed char* h_dq, const float* h_bscale,
                        float* h_d_in, int rows, int cols, int blockSize, int accumulate) {
    if (!cuda_initialized || !h_W || !h_dq || !h_bscale || !h_d_in ||
        rows <= 0 || cols <= 0 || blockSize <= 0) return;
    int nblocks = (rows + blockSize - 1) / blockSize;
    size_t size_W  = (size_t)rows * (size_t)cols * sizeof(signed char);
    size_t size_dq = (size_t)rows * sizeof(signed char);
    size_t size_bs = (size_t)nblocks * sizeof(float);
    size_t size_di = (size_t)cols * sizeof(float);
    signed char* d_W = (signed char*)cuda_get_buffer((void*)h_W, size_W);
    if (!d_W || !cuda_i8_ensure(&cuda_i8_e_in, &cuda_i8_e_in_size, size_dq) ||
        !cuda_i8_ensure(&cuda_i8_e_sc, &cuda_i8_e_sc_size, size_bs) ||
        !cuda_i8_ensure(&cuda_i8_e_b, &cuda_i8_e_b_size, size_di)) { cuda_i8_fail("backwardDInI8"); return; }
    cudaMemcpy(cuda_i8_e_in, h_dq, size_dq, cudaMemcpyHostToDevice);
    cudaMemcpy(cuda_i8_e_sc, h_bscale, size_bs, cudaMemcpyHostToDevice);
    if (accumulate == 1) cudaMemcpy(cuda_i8_e_b, h_d_in, size_di, cudaMemcpyHostToDevice);
    int tpb = 256;
    int blocks = (cols + tpb - 1) / tpb;
    backwardDInI8Kernel<<<blocks, tpb>>>(d_W, (const signed char*)cuda_i8_e_in, (const float*)cuda_i8_e_sc,
                                         (float*)cuda_i8_e_b, rows, cols, blockSize, accumulate);
    cuda_bw_din_calls++;
    cudaMemcpy(h_d_in, cuda_i8_e_b, size_di, cudaMemcpyDeviceToHost);
    cuda_i8_ok("backwardDInI8");
}

// ==== BW-KACHEL (2026-11-11, messbuch snai/multistack-bwkachel e612): Rueckwaerts-Kerne als Kachelkerne mit __dp4a ====
// Kachel 64x64, 256 Faeden je 4x4 Ausgaben, K in Schritten zu 64 (16 gepackte int). Bitgleich: Summen ganzzahlig,
// float-Schritte in alter Reihenfolge. Schalter SNAI_CUDA_BW: fehlt/1 = Kachel (Vorgabe), 0 = alte Kerne, ROT = Rot-Probe.
#define BW_T 64
#define BW_KW 16
static int cuda_bw_mode = -1;   // 0 alt, 1 Kachel, 2 Kachel + ROT
static int cuda_bw_get_mode() {
    if (cuda_bw_mode < 0) {
        const char* e = getenv("SNAI_CUDA_BW");
        cudaDeviceProp prop; cudaGetDeviceProperties(&prop, 0);
        const int cc = prop.major * 10 + prop.minor;
        if (cc < 61 || (e && strcmp(e, "0") == 0)) cuda_bw_mode = 0;
        else if (e && strcmp(e, "ROT") == 0) cuda_bw_mode = 2;
        else if (!e || !*e || strcmp(e, "1") == 0) cuda_bw_mode = 1;   // Vorgabe Kachel (seit 2026-11-11, e612)
        else cuda_bw_mode = 0;
        fprintf(stderr, "[CUDA-BW] Rueckwaertskerne: %s\n",
                cuda_bw_mode == 0 ? "alt" : cuda_bw_mode == 2 ? "Kachel ROT-PROBE" : "Kachel (dp4a)");
    }
    return cuda_bw_mode;
}
// d_in[p,c] (+)= Summe ueber 64er-Bloecke b (s = bscale[p,b] > 0): (float)(sum_{r in b} W[r,c]*dq[p,r]) * s
__global__ void backwardDInI8BatchedTiledKernel(const signed char* W, const signed char* dq, const float* bscale,
                                                float* d_in, int rows, int cols, int batch, int accumulate, int rot) {
    __shared__ int sW[BW_T][BW_KW + 1];   // Spalte c, 4 Zeilen r gepackt
    __shared__ int sQ[BW_T][BW_KW + 1];   // Position p, 4 Zeilen r gepackt
    const int tx = threadIdx.x & 15, ty = threadIdx.x >> 4;
    const int c0 = blockIdx.x * BW_T, p0 = blockIdx.y * BW_T;
    const int nblocks = (rows + 63) / 64;
    float accf[4][4];
    #pragma unroll
    for (int i = 0; i < 4; ++i)
        #pragma unroll
        for (int j = 0; j < 4; ++j) {
            const int p = p0 + ty + 16 * i, c = c0 + tx + 16 * j;
            accf[i][j] = (accumulate == 1 && p < batch && c < cols) ? d_in[(size_t)p * (size_t)cols + (size_t)c] : 0.0f;
        }
    for (int b = 0; b < nblocks; ++b) {
        const int k0 = b * 64;
        const int k1 = (k0 + 64 < rows) ? k0 + 64 : rows;
        for (int e = threadIdx.x; e < BW_T * BW_KW; e += 256) {
            {   // W: aufeinanderfolgende Faeden -> aufeinanderfolgende Spalten
                const int ii = e % BW_T, kk = e / BW_T, gc = c0 + ii;
                unsigned int v = 0;
                if (gc < cols) {
                    #pragma unroll
                    for (int j = 0; j < 4; ++j) {
                        const int r = k0 + 4 * kk + j;
                        if (r < k1) v |= (unsigned int)(unsigned char)W[(size_t)r * (size_t)cols + (size_t)gc] << (8 * j);
                    }
                }
                sW[ii][kk] = (int)v;
            }
            {   // dq: aufeinanderfolgende Faeden -> aufeinanderfolgende Zeilen derselben Position
                const int ii = e / BW_KW, kk = e % BW_KW, gp = p0 + ii;
                unsigned int v = 0;
                if (gp < batch) {
                    #pragma unroll
                    for (int j = 0; j < 4; ++j) {
                        const int r = k0 + 4 * kk + j;
                        if (r < k1) v |= (unsigned int)(unsigned char)dq[(size_t)gp * (size_t)rows + (size_t)r] << (8 * j);
                    }
                }
                sQ[ii][kk] = (int)v;
            }
        }
        __syncthreads();
        int iacc[4][4];
        #pragma unroll
        for (int i = 0; i < 4; ++i)
            #pragma unroll
            for (int j = 0; j < 4; ++j) iacc[i][j] = 0;
        #pragma unroll
        for (int kk = 0; kk < BW_KW; ++kk) {
            int a[4], bb[4];
            #pragma unroll
            for (int i = 0; i < 4; ++i) a[i] = sQ[ty + 16 * i][kk];
            #pragma unroll
            for (int j = 0; j < 4; ++j) bb[j] = sW[tx + 16 * j][kk];
            #pragma unroll
            for (int i = 0; i < 4; ++i)
                #pragma unroll
                for (int j = 0; j < 4; ++j) iacc[i][j] = __dp4a(a[i], bb[j], iacc[i][j]);
        }
        __syncthreads();
        #pragma unroll
        for (int i = 0; i < 4; ++i) {
            const int p = p0 + ty + 16 * i;
            if (p >= batch) continue;
            const float sc = bscale[(size_t)p * (size_t)nblocks + (size_t)b];
            if (sc > 0.0f) {
                #pragma unroll
                for (int j = 0; j < 4; ++j) {
                    const int c = c0 + tx + 16 * j;
                    int ia = iacc[i][j];
                    if (rot && b == nblocks - 1 && p == batch - 1 && c == cols - 1) ia += 1;
                    accf[i][j] = __fadd_rn(accf[i][j], __fmul_rn((float)ia, sc));
                }
            }
        }
    }
    #pragma unroll
    for (int i = 0; i < 4; ++i) {
        const int p = p0 + ty + 16 * i;
        if (p >= batch) continue;
        #pragma unroll
        for (int j = 0; j < 4; ++j) {
            const int c = c0 + tx + 16 * j;
            if (c < cols) d_in[(size_t)p * (size_t)cols + (size_t)c] = accf[i][j];
        }
    }
}
// gm[r,c] += (float)(sum_p qd[p,r]*qi[p,c]) * ds[r] * is[c]   (nur wo ds > 0 und is > 0)
__global__ void gradAccumI8TiledKernel(const signed char* qi, const signed char* qd, const float* dsc,
                                       const float* isc, float* gm, int rows, int cols, int batch, int qiStride, int rot) {
    __shared__ int sD[BW_T][BW_KW + 1];   // Zeile r, 4 Positionen gepackt
    __shared__ int sI[BW_T][BW_KW + 1];   // Spalte c, 4 Positionen gepackt
    const int tx = threadIdx.x & 15, ty = threadIdx.x >> 4;
    const int c0 = blockIdx.x * BW_T, r0 = blockIdx.y * BW_T;
    int acc[4][4];
    #pragma unroll
    for (int i = 0; i < 4; ++i)
        #pragma unroll
        for (int j = 0; j < 4; ++j) acc[i][j] = 0;
    for (int q0 = 0; q0 < batch; q0 += 4 * BW_KW) {
        for (int e = threadIdx.x; e < BW_T * BW_KW; e += 256) {
            const int ii = e % BW_T, kk = e / BW_T;
            const int gr = r0 + ii, gc = c0 + ii;
            unsigned int vd = 0, vi = 0;
            #pragma unroll
            for (int j = 0; j < 4; ++j) {
                const int p = q0 + 4 * kk + j;
                if (p < batch) {
                    if (gr < rows) vd |= (unsigned int)(unsigned char)qd[(size_t)p * (size_t)rows + (size_t)gr] << (8 * j);
                    if (gc < cols) vi |= (unsigned int)(unsigned char)qi[(size_t)p * (size_t)qiStride + (size_t)gc] << (8 * j);
                }
            }
            sD[ii][kk] = (int)vd; sI[ii][kk] = (int)vi;
        }
        __syncthreads();
        #pragma unroll
        for (int kk = 0; kk < BW_KW; ++kk) {
            int a[4], bb[4];
            #pragma unroll
            for (int i = 0; i < 4; ++i) a[i] = sD[ty + 16 * i][kk];
            #pragma unroll
            for (int j = 0; j < 4; ++j) bb[j] = sI[tx + 16 * j][kk];
            #pragma unroll
            for (int i = 0; i < 4; ++i)
                #pragma unroll
                for (int j = 0; j < 4; ++j) acc[i][j] = __dp4a(a[i], bb[j], acc[i][j]);
        }
        __syncthreads();
    }
    #pragma unroll
    for (int i = 0; i < 4; ++i) {
        const int r = r0 + ty + 16 * i;
        if (r >= rows) continue;
        const float ds = dsc[r];
        #pragma unroll
        for (int j = 0; j < 4; ++j) {
            const int c = c0 + tx + 16 * j;
            if (c >= cols) continue;
            const float is = isc[c];
            if (ds > 0.0f && is > 0.0f) {
                int a = acc[i][j];
                if (rot && r == rows - 1 && c == cols - 1) a += 1;
                const size_t idx = (size_t)r * (size_t)cols + (size_t)c;
                gm[idx] = __fadd_rn(gm[idx], __fmul_rn(__fmul_rn((float)a, ds), is));
            }
        }
    }
}

// Ganzzahl-Backward, gebuendelt: ein Start fuer alle Positionen.
__global__ void backwardDInI8BatchedKernel(const signed char* W, const signed char* dq, const float* bscale,
                                           float* d_in, int rows, int cols, int batch, int blockSize,
                                           int accumulate) {
    size_t idx = (size_t)blockIdx.x * (size_t)blockDim.x + (size_t)threadIdx.x;
    if (idx >= (size_t)batch * (size_t)cols) return;
    int p = (int)(idx / (size_t)cols);
    int c = (int)(idx % (size_t)cols);
    int nblocks = (rows + blockSize - 1) / blockSize;
    float acc = (accumulate == 1) ? d_in[idx] : 0.0f;
    for (int b = 0; b < nblocks; ++b) {
        float s = bscale[(size_t)p * (size_t)nblocks + (size_t)b];
        if (s > 0.0f) {
            int r0 = b * blockSize;
            int r1 = r0 + blockSize; if (r1 > rows) r1 = rows;
            int iacc = 0;
            for (int r = r0; r < r1; ++r) {
                iacc += (int)W[(size_t)r * (size_t)cols + (size_t)c] * (int)dq[(size_t)p * (size_t)rows + (size_t)r];
            }
            acc = __fadd_rn(acc, __fmul_rn((float)iacc, s));
        }
    }
    d_in[idx] = acc;
}

void cuda_backwardDInI8Batched(const signed char* h_W, const signed char* h_dq, const float* h_bscale,
                               float* h_d_in, int rows, int cols, int batch, int blockSize, int accumulate) {
    if (!cuda_initialized || !h_W || !h_dq || !h_bscale || !h_d_in ||
        rows <= 0 || cols <= 0 || batch <= 0 || blockSize <= 0) return;
    int nblocks = (rows + blockSize - 1) / blockSize;
    size_t n_W  = (size_t)rows * (size_t)cols * sizeof(signed char);
    size_t n_dq = (size_t)batch * (size_t)rows * sizeof(signed char);
    size_t n_bs = (size_t)batch * (size_t)nblocks * sizeof(float);
    size_t n_di = (size_t)batch * (size_t)cols * sizeof(float);
    signed char* d_W = (signed char*)cuda_get_buffer((void*)h_W, n_W);
    if (!d_W || !cuda_i8_ensure(&cuda_i8_e_in, &cuda_i8_e_in_size, n_dq) ||
        !cuda_i8_ensure(&cuda_i8_e_sc, &cuda_i8_e_sc_size, n_bs) ||
        !cuda_i8_ensure(&cuda_i8_e_b, &cuda_i8_e_b_size, n_di)) { cuda_i8_fail("backwardDInI8Batched"); return; }
    cudaMemcpy(cuda_i8_e_in, h_dq, n_dq, cudaMemcpyHostToDevice);
    cudaMemcpy(cuda_i8_e_sc, h_bscale, n_bs, cudaMemcpyHostToDevice);
    if (accumulate == 1) cudaMemcpy(cuda_i8_e_b, h_d_in, n_di, cudaMemcpyHostToDevice);
    size_t total = (size_t)batch * (size_t)cols;
    int tpb = 256;
    int blocks = (int)((total + tpb - 1) / tpb);
    const int bwm = cuda_bw_get_mode();
    if (bwm > 0 && blockSize == 64) {
        dim3 grid((unsigned)((cols + BW_T - 1) / BW_T), (unsigned)((batch + BW_T - 1) / BW_T));
        backwardDInI8BatchedTiledKernel<<<grid, 256>>>(d_W, (const signed char*)cuda_i8_e_in, (const float*)cuda_i8_e_sc,
                                                      (float*)cuda_i8_e_b, rows, cols, batch, accumulate, bwm == 2 ? 1 : 0);
    } else
    backwardDInI8BatchedKernel<<<blocks, tpb>>>(d_W, (const signed char*)cuda_i8_e_in, (const float*)cuda_i8_e_sc,
                                                (float*)cuda_i8_e_b, rows, cols, batch, blockSize, accumulate);
    cuda_bw_din_calls++;
    cudaMemcpy(h_d_in, cuda_i8_e_b, n_di, cudaMemcpyDeviceToHost);
    cuda_i8_ok("backwardDInI8Batched");
}

// Ganzzahlige Gradienten-Akkumulation: gm[r,c] += (sum_p qd[p,r] * qi[p,c]) * ds[r] * is[c]
__global__ void gradAccumI8Kernel(const signed char* qi, const signed char* qd, const float* dsc,
                                  const float* isc, float* gm, int rows, int cols, int batch, int qiStride) {
    size_t idx = (size_t)blockIdx.x * (size_t)blockDim.x + (size_t)threadIdx.x;
    if (idx >= (size_t)rows * (size_t)cols) return;
    int r = (int)(idx / (size_t)cols);
    int c = (int)(idx % (size_t)cols);
    float ds = dsc[r];
    float is = isc[c];
    if (ds > 0.0f && is > 0.0f) {
        int acc = 0;
        for (int p = 0; p < batch; ++p) {
            acc += (int)qd[(size_t)p * (size_t)rows + (size_t)r] * (int)qi[(size_t)p * (size_t)qiStride + (size_t)c];
        }
        gm[idx] = __fadd_rn(gm[idx], __fmul_rn(__fmul_rn((float)acc, ds), is));
    }
}

// gmOnDevice == 1: der Gradient ist geraeteresident (zeroGradI8 hat ihn dort genullt, pullGradI8 holt ihn);
// dann weder hoch- noch runterladen. Sonst: Host-Stand hoch, akkumulieren, zurueck.
// OVERLAP (2026-11-11, messbuch snai/multistack-overlap e618, ~4 %): kein Warten nach der Gradientensumme bei
// geraeteresidentem Gradienten, memset(h_g) im GPU-Adam waehrend des Kerns. SNAI_OVERLAP: fehlt/1 = an (Vorgabe),
// 0 = aus, ROT = Rot-Probe (Gradientenkern vor dem Hochladen seiner Eingaben).
static int cuda_ov_mode = -1;   // 0 aus, 1 ueberlappen, 2 ROT
static int cuda_ov_get() {
    if (cuda_ov_mode < 0) {
        const char* e = getenv("SNAI_OVERLAP");
        if (e && strcmp(e, "0") == 0) cuda_ov_mode = 0;
        else if (e && strcmp(e, "ROT") == 0) cuda_ov_mode = 2;
        else if (!e || !*e || strcmp(e, "1") == 0) cuda_ov_mode = 1;   // Vorgabe an (seit 2026-11-11, e618)
        else cuda_ov_mode = 0;
        fprintf(stderr, "[OVERLAP] %s\n", cuda_ov_mode == 0 ? "aus" : cuda_ov_mode == 2 ? "ROT-PROBE" : "an");
    }
    return cuda_ov_mode;
}
void cuda_gradAccumI8(const signed char* h_qi, const signed char* h_qd, const float* h_dsc, const float* h_isc,
                      float* h_gm, int rows, int cols, int batch, int qiStride, int gmOnDevice) {
    if (!cuda_initialized || !h_qi || !h_qd || !h_dsc || !h_isc || !h_gm ||
        rows <= 0 || cols <= 0 || batch <= 0) return;
    size_t n_qi = (size_t)batch * (size_t)qiStride * sizeof(signed char);
    size_t n_qd = (size_t)batch * (size_t)rows * sizeof(signed char);
    size_t n_ds = (size_t)rows * sizeof(float);
    size_t n_is = (size_t)cols * sizeof(float);
    size_t n_gm = (size_t)rows * (size_t)cols * sizeof(float);
    if (!cuda_i8_ensure(&cuda_i8_e_in2, &cuda_i8_e_in2_size, n_qi) ||
        !cuda_i8_ensure(&cuda_i8_e_in, &cuda_i8_e_in_size, n_qd) ||
        !cuda_i8_ensure(&cuda_i8_e_sc, &cuda_i8_e_sc_size, n_ds) ||
        !cuda_i8_ensure(&cuda_i8_e_sc2, &cuda_i8_e_sc2_size, n_is)) { cuda_i8_fail("gradAccumI8"); return; }
    float* d_gm;
    if (gmOnDevice == 1) {
        d_gm = (float*)cuda_get_buffer((void*)h_gm, n_gm);
        if (!d_gm) { cuda_i8_fail("gradAccumI8 (gm)"); return; }
    } else {
        if (!cuda_i8_ensure(&cuda_i8_e_gm, &cuda_i8_e_gm_size, n_gm)) { cuda_i8_fail("gradAccumI8 (gm)"); return; }
        d_gm = (float*)cuda_i8_e_gm;
        cudaMemcpy(d_gm, h_gm, n_gm, cudaMemcpyHostToDevice);
    }
    const int ovm = cuda_ov_get();
    const bool ovRot = ovm == 2 && gmOnDevice == 1;
    if (!ovRot) {
    cudaMemcpy(cuda_i8_e_in2, h_qi, n_qi, cudaMemcpyHostToDevice);
    cudaMemcpy(cuda_i8_e_in, h_qd, n_qd, cudaMemcpyHostToDevice);
    cudaMemcpy(cuda_i8_e_sc, h_dsc, n_ds, cudaMemcpyHostToDevice);
    cudaMemcpy(cuda_i8_e_sc2, h_isc, n_is, cudaMemcpyHostToDevice);
    }
    size_t total = (size_t)rows * (size_t)cols;
    int tpb = 256;
    int blocks = (int)((total + tpb - 1) / tpb);
    const int epm = (gmOnDevice == 1) ? ep_get_mode() : 0;
    EarlyPull* epe = epm ? ep_get((void*)h_gm, (void*)d_gm, n_gm) : nullptr;
    if (epe && epm == 2) ep_issue(epe);   // ROT: vor dem Kern -> Beitrag fehlt
    const int bwm = cuda_bw_get_mode();
    if (bwm > 0) {
        dim3 grid((unsigned)((cols + BW_T - 1) / BW_T), (unsigned)((rows + BW_T - 1) / BW_T));
        gradAccumI8TiledKernel<<<grid, 256>>>((const signed char*)cuda_i8_e_in2, (const signed char*)cuda_i8_e_in,
                                              (const float*)cuda_i8_e_sc, (const float*)cuda_i8_e_sc2, d_gm,
                                              rows, cols, batch, qiStride, bwm == 2 ? 1 : 0);
    } else
    gradAccumI8Kernel<<<blocks, tpb>>>((const signed char*)cuda_i8_e_in2, (const signed char*)cuda_i8_e_in,
                                       (const float*)cuda_i8_e_sc, (const float*)cuda_i8_e_sc2, d_gm,
                                       rows, cols, batch, qiStride);
    cuda_gradacc_calls++;
    if (epe && epm == 1) ep_issue(epe);   // nach dem Kern
    if (ovRot) {
        cudaMemcpy(cuda_i8_e_in2, h_qi, n_qi, cudaMemcpyHostToDevice);
        cudaMemcpy(cuda_i8_e_in, h_qd, n_qd, cudaMemcpyHostToDevice);
        cudaMemcpy(cuda_i8_e_sc, h_dsc, n_ds, cudaMemcpyHostToDevice);
        cudaMemcpy(cuda_i8_e_sc2, h_isc, n_is, cudaMemcpyHostToDevice);
    }
    if (gmOnDevice == 1) {
        if (ovm == 0) cudaDeviceSynchronize();   // OVERLAP: nicht warten, pullGrad liest hinter dem Kern
    } else {
        cudaMemcpy(h_gm, d_gm, n_gm, cudaMemcpyDeviceToHost);
    }
    cuda_i8_ok("gradAccumI8");
}

// ==== GPU-Adam (2026-10-14): Adam mit 8-Bit-Log-Momenten (QMoment) auf der Karte ====
// Port von adamRowFloatI8 + qmomGet + qmomStoreRow (cortex.nim), Ausdruck fuer Ausdruck nach dem von Nim
// erzeugten C (gemischt float/double wie dort). Mul/Add ueber __*_rn, damit nvcc nichts zu FMA zusammenfasst
// (wie bei den INT8-Kernen oben). NIE mit -use_fast_math bauen: Division, sqrtf und log muessen IEEE bleiben.
// MIT -ftz=true bauen: die CPU-Seite rechnet mit FTZ/DAZ (snai_ftz_init in cortex.nim); ohne den Schalter
// behielte die Karte Denormale (Momente toter Zeilen) und wiche dort ab.
// Bitgleich gemessen (Projekt-Doku 6ad/6af). Restrisiko: CUDA-log (double) ist auf 1 ulp genau, glibc-log
// praktisch korrekt gerundet; eine Abweichung wirkt nur, wenn steps*ln(x/lo)/lgr auf ~1e-14 an einer
// Rundungsgrenze liegt.
static float* cuda_qa_tabM = nullptr;
static float* cuda_qa_tabV = nullptr;
static void* cuda_qa_g = nullptr;  static size_t cuda_qa_g_size = 0;
static void* cuda_qa_mb = nullptr; static size_t cuda_qa_mb_size = 0;
static void* cuda_qa_vb = nullptr; static size_t cuda_qa_vb_size = 0;
static double cuda_qa_t[4] = {0.0, 0.0, 0.0, 0.0};   // ms hoch, ms Kern, ms runter, Aufrufe
#define QA_TPB 256
#define QA_QN 1024

__device__ __forceinline__ float qaGet(const unsigned char* d, const float* sc, const float* tab,
                                       size_t i, int row, int sgn) {
    unsigned char b = d[i];
    if (b == 0) return 0.0f;
    float s = sc[row];
    if (sgn) {
        int mag = b & 0x7F;
        if (mag == 0) return 0.0f;
        float v = __fmul_rn(s, tab[mag]);
        return (b & 0x80) ? -v : v;
    }
    return __fmul_rn(s, tab[b]);
}

__device__ float qaBlockMax(float x, float* red) {
    int lid = threadIdx.x;
    __syncthreads();
    red[lid] = x;
    __syncthreads();
    for (int st = blockDim.x / 2; st > 0; st >>= 1) {
        if (lid < st) red[lid] = fmaxf(red[lid], red[lid + st]);
        __syncthreads();
    }
    float r = red[0];
    __syncthreads();
    return r;
}

// SR (2026-10-19): Gegenstueck zu srUniform in cortex.nim, Bit fuer Bit (splitmix64, 53 Bit nach [0,1)).
__device__ __forceinline__ double qaSrUniform(float x, int row, int c, int sgn, unsigned long long salt) {
    unsigned long long h = (unsigned long long)__float_as_uint(x) ^ ((unsigned long long)(long long)row << 32)
                         ^ ((unsigned long long)(long long)c << 12) ^ salt;
    if (sgn) h ^= 6364136223846793005ULL;
    h += 11400714819323198485ULL;
    h = (h ^ (h >> 30)) * 13787848793156543929ULL;
    h = (h ^ (h >> 27)) * 10723151780598845931ULL;
    h = h ^ (h >> 31);
    return __dmul_rn((double)(h >> 11), 1.1102230246251565e-16);
}

#ifndef QA_V_KLEMME
#define QA_V_KLEMME 1
#endif
__device__ __forceinline__ float qaSrUniformF(float x, int row, int c, int sgn, unsigned long long salt) {
    unsigned long long h = (unsigned long long)__float_as_uint(x) ^ ((unsigned long long)(long long)row << 32)
                         ^ ((unsigned long long)(long long)c << 12) ^ salt;
    if (sgn) h ^= 6364136223846793005ULL;
    h += 11400714819323198485ULL;
    h = (h ^ (h >> 30)) * 13787848793156543929ULL;
    h = (h ^ (h >> 27)) * 10723151780598845931ULL;
    h = h ^ (h >> 31);
    return __fmul_rn(__ull2float_rn(h >> 11), 1.1102230246251565e-16f);
}
__device__ void qaStoreRow(unsigned char* d, float* sc, const float* buf, size_t off, int cols, int row,
                           int sgn, double lgr, float* red, int sr, unsigned long long salt, int fast) {
    __shared__ int qaQ[QA_QN];
    __shared__ int qaQn;
    if (threadIdx.x == 0) qaQn = 0;   // sichtbar nach den Barrieren in qaBlockMax
    float mx = 0.0f;
    for (int c = threadIdx.x; c < cols; c += blockDim.x) mx = fmaxf(mx, fabsf(buf[off + c]));
    mx = qaBlockMax(mx, red);
    if (threadIdx.x == 0) sc[row] = mx;
    if ((double)mx <= 0.0) {
        for (int c = threadIdx.x; c < cols; c += blockDim.x) d[off + c] = 0;
        return;
    }
    double lo = (double)mx / 100000000.0;
    double steps = sgn ? 126.0 : 254.0;
    long qmax = sgn ? 127 : 255;
    // ADAM-FAST (2026-11-11, messbuch snai/multistack-adamfast e611): float-Stufe, double nur nahe einer Rundungsgrenze
    // (Abstand <= fG Stufen). SNAI_ADAM_FAST Bitmaske, fehlt = 79: 1 Log-Stufe, 2 SR-Addition, 4 Gewichtsrequantisierung,
    // 8 Adam-Division, 64 Rueckfaelle gesammelt nach der Schleife; 0 = alter Rechenweg; 32 = Rot-Probe (ohne Rueckfall),
    // 16 = NUR Zeitdiagnose (Momente in float, nicht bitgleich).
    const int fLog = fast & 1, fSr = fast & 2;
    const float fG = (fast & 32) ? -1.0f : (float)(1.0 / 256.0);
    float fSteps = 0.0f, fLnd = 0.0f, fIlg = 0.0f;
    if (fLog) { fSteps = sgn ? 126.0f : 254.0f; fLnd = (float)log((double)mx / lo); fIlg = (float)(1.0 / lgr); }
    for (int c = threadIdx.x; c < cols; c += blockDim.x) {
        float x = buf[off + c];
        float ax = fabsf(x);
        // V-KLEMME (Messkopie karte_vk, 2026-11-06): wie qmomStoreRow - v > 0 unter der Zeilenschwelle -> Code 1.
        if ((double)ax <= lo) { d[off + c] = (QA_V_KLEMME && !sgn && ax > 0.0f) ? 1 : 0; continue; }
        double t34 = 0.0;
        bool ok = false;
        if (fLog) {
            // ln(ax/lo) = ln(ax/mx) + ln(mx/lo); ax/mx liegt in (1e-8, 1]
            float af = __fmul_rn(__fmul_rn(fSteps, __fadd_rn(logf(__fdiv_rn(ax, mx)), fLnd)), fIlg);
            if (sr) {
                if (fSr) {
                    float sf = __fadd_rn(af, qaSrUniformF(x, row, c, sgn, salt));
                    float fl = floorf(sf);
                    float fr = __fsub_rn(sf, fl);
                    ok = (fr > fG) && (fr < __fsub_rn(1.0f, fG));   // NaN -> false -> Rueckfall
                    t34 = (double)fl;
                } else {
                    double sd = __dadd_rn((double)af, qaSrUniform(x, row, c, sgn, salt));
                    double fl = floor(sd);
                    double fr = __dsub_rn(sd, fl);
                    ok = (fr > (double)fG) && (fr < __dsub_rn(1.0, (double)fG));
                    t34 = fl;
                }
            } else {
                float fl = floorf(af);
                float fr = __fsub_rn(af, fl);
                ok = fabsf(__fsub_rn(fr, 0.5f)) > fG;
                t34 = (double)((fr < 0.5f) ? fl : __fadd_rn(fl, 1.0f));
            }
        }
        if (!ok && (fast & 64)) {
            int k = atomicAdd(&qaQn, 1);
            if (k < QA_QN) { qaQ[k] = c; continue; }
        }
        if (!ok) {
            double t33 = log((double)ax / lo);
            t34 = sr ? floor(__dadd_rn(__ddiv_rn(__dmul_rn(steps, t33), lgr), qaSrUniform(x, row, c, sgn, salt)))
                     : round(__dmul_rn(steps, t33) / lgr);
        }
        long qi = 1 + (long)t34;
        if (qi < 1) qi = 1; else if (qmax < qi) qi = qmax;
        if (sgn) {
            unsigned char b = (unsigned char)((unsigned char)qi & 0x7F);
            if ((double)x < 0.0) b = b | 0x80;
            d[off + c] = b;
        } else {
            d[off + c] = (unsigned char)qi;
        }
    }
    if (fast & 64) {
        __syncthreads();
        int nq = qaQn < QA_QN ? qaQn : QA_QN;
        for (int k = threadIdx.x; k < nq; k += blockDim.x) {
            int c = qaQ[k];
            float x = buf[off + c];
            float ax = fabsf(x);
            double t33 = log((double)ax / lo);
            double t34 = sr ? floor(__dadd_rn(__ddiv_rn(__dmul_rn(steps, t33), lgr), qaSrUniform(x, row, c, sgn, salt)))
                            : round(__dmul_rn(steps, t33) / lgr);
            long qi = 1 + (long)t34;
            if (qi < 1) qi = 1; else if (qmax < qi) qi = qmax;
            if (sgn) {
                unsigned char b = (unsigned char)((unsigned char)qi & 0x7F);
                if ((double)x < 0.0) b = b | 0x80;
                d[off + c] = b;
            } else {
                d[off + c] = (unsigned char)qi;
            }
        }
        __syncthreads();
    }
}

// Ein Block je Zeile (QA_TPB Faeden, Zweierpotenz - die Max-Reduktion halbiert).
// REST-16 (Messkopie ms_rest/karte, 2026-11-05): Gegenstueck zu restSrU in cortex.nim (Marke 0xA0761D6478BD642F).
__device__ __forceinline__ double restSrU(float x, int row, int c, unsigned long long salt) {
    unsigned long long h = (unsigned long long)__float_as_uint(x) ^ ((unsigned long long)(long long)row << 32)
                         ^ ((unsigned long long)(long long)c << 12) ^ salt;
    h ^= 11562461410679940143ULL;
    h += 11400714819323198485ULL;
    h = (h ^ (h >> 30)) * 13787848793156543929ULL;
    h = (h ^ (h >> 27)) * 10723151780598845931ULL;
    h = h ^ (h >> 31);
    return __dmul_rn((double)(h >> 11), 1.1102230246251565e-16);
}
__device__ __forceinline__ float restSrUF(float x, int row, int c, unsigned long long salt) {
    unsigned long long h = (unsigned long long)__float_as_uint(x) ^ ((unsigned long long)(long long)row << 32)
                         ^ ((unsigned long long)(long long)c << 12) ^ salt;
    h ^= 11562461410679940143ULL;
    h += 11400714819323198485ULL;
    h = (h ^ (h >> 30)) * 13787848793156543929ULL;
    h = (h ^ (h >> 27)) * 10723151780598845931ULL;
    h = h ^ (h >> 31);
    return __fmul_rn(__ull2float_rn(h >> 11), 1.1102230246251565e-16f);
}
__device__ __forceinline__ void restAtomAddD(double* a, double v) {
    unsigned long long* p = (unsigned long long*)a;
    unsigned long long alt = *p, erw;
    do { erw = alt; alt = atomicCAS(p, erw, __double_as_longlong(__longlong_as_double((long long)erw) + v)); } while (alt != erw);
}
// rcnt: 0 skalaFehl, 1 auflFehl, 2 unter128, 3 n, 4 wdN, 5..9 hist; rwd: Summe wdStufen.
__global__ void adamRowQI8Kernel(signed char* w, float* wscale, unsigned char* mqd, float* mqs,
                                 unsigned char* vqd, float* vqs, float* g, float* res, float* mb, float* vb,
                                 const float* tabM, const float* tabV,
                                 float lr, float b1, float b2, float b1t, float b2t, float gscale,
                                 int cols, int is_sparse, int bound_r, int bound_c, float boost, float wd,
                                 int use_fb, double lgr, int sr_mask, unsigned long long sr_salt,
                                 int rmode, short* rc16, signed char* rc8, float* rsk,
                                 unsigned long long* rcnt, double* rwd, int rrot, int rtele, int fast) {
    __shared__ float red[QA_TPB];
    const float fG = (fast & 32) ? -1.0f : (float)(1.0 / 256.0);
    const int fRot = fast & 32;
    __shared__ int wqQ[QA_QN];
    __shared__ int wqQn;
    if (threadIdx.x == 0) wqQn = 0;
    __shared__ int touched;
    int row = blockIdx.x;
    int lid = threadIdx.x;
    int lsz = blockDim.x;
    size_t off = (size_t)row * (size_t)cols;
    float qscale = wscale[row];
    if (lid == 0) touched = 0;
    for (int c = lid; c < cols; c += lsz) {
        mb[off + c] = qaGet(mqd, mqs, tabM, off + c, row, 1);
        vb[off + c] = qaGet(vqd, vqs, tabV, off + c, row, 0);
    }
    __syncthreads();
    float localMax = 0.0f;
    int myTouched = 0;
    // REST-16: Codemodus, Faktoren wie cortex.nim (rFak, rKInv, rFakEnc), lokale Zaehler
    const int rcode = use_fb && (rmode == 16 || rmode == 8 || rmode == 9);
    const float rFak = (rmode == 16) ? 32767.0f : ((rmode == 9) ? 254.0f : 127.0f);
    const float rKInv = (rmode == 16) ? (float)(1.0 / 32767.0) : ((rmode == 9) ? (float)(1.0 / 254.0) : (float)(1.0 / 127.0));
    const float rFakEnc = (rrot == 2) ? ((rmode == 16) ? 16383.0f : ((rmode == 9) ? 127.0f : 63.0f)) : rFak;
    const float decScale = (rrot == 1 && rcode) ? wscale[(row + 1) % (int)gridDim.x] : qscale;
    const float rSkRow = (rcode && rsk) ? rsk[row] : 0.0f;
    unsigned long long lSkF = 0, lAuF = 0, lU128 = 0, lN = 0, lWdN = 0, lH0 = 0, lH1 = 0, lH2 = 0, lH3 = 0, lH4 = 0;
    double lWd = 0.0;
    for (int c = lid; c < cols; c += lsz) {
        size_t i = off + (size_t)c;
        float wf0 = __fmul_rn((float)w[i], qscale);
        float grad = g[i] / gscale;
        float wf = wf0;
        if (!((double)gscale == 0.0) && !(isnan(grad) || 9999.0 < (double)grad || (double)grad < -9999.0)) {
            if (!(is_sparse && (double)fabsf(grad) < 1e-8)) {
                float mCur = mb[i];
                float vCur = vb[i];
                if (fast & 16) {   // DIAG_MOMF: NUR Zeitdiagnose, nicht bitgleich
                    mCur = fmaf(1.0f - b1, grad, __fmul_rn(b1, mCur));
                    vCur = fmaf(__fmul_rn(1.0f - b2, grad), grad, __fmul_rn(b2, vCur));
                } else {
                mCur = (float)__dadd_rn((double)__fmul_rn(b1, mCur), __dmul_rn(__dsub_rn(1.0, (double)b1), (double)grad));
                vCur = (float)__dadd_rn((double)__fmul_rn(b2, vCur), __dmul_rn(__dmul_rn(__dsub_rn(1.0, (double)b2), (double)grad), (double)grad));
                }
                myTouched = 1;
                mb[i] = mCur;
                vb[i] = vCur;
                float m_hat = mCur / b1t;
                float v_hat = vCur / b2t;
                float bst = (row >= bound_r || c >= bound_c) ? boost : 1.0f;
                float t59 = sqrtf(v_hat);
                bool okd = false;
                if (fast & 8) {
                    // FAST_DIV: s = fl(wf0 - q) mit q ~ P/(t59+1e-8); TwoSum-Rest e; Rundung steht fest, wenn
                    // |e| + Schranke(q-Fehler, double-Rundungen) < halbe kleinere float-Spanne um s.
                    float P = __fmul_rn(__fmul_rn(lr, bst), m_hat);
                    float q = __fdiv_rn(P, __fadd_rn(t59, 1e-8f));
                    float sf = __fsub_rn(wf0, q);
                    float bb = __fsub_rn(sf, wf0);
                    float e = __fadd_rn(__fsub_rn(wf0, __fsub_rn(sf, bb)), __fsub_rn(-q, bb));
                    float as = fabsf(sf);
                    float hu = __fmul_rn(__fsub_rn(as, nextafterf(as, 0.0f)), 0.5f);
                    float sch = __fadd_rn(__fmul_rn(fabsf(q), 4.0e-7f), __fmul_rn(as, 1.0e-12f));
                    okd = fRot || (isfinite(sf) && isfinite(q) && as > 1.0e-30f && __fadd_rn(fabsf(e), sch) < hu);
                    if (okd) wf = sf;
                }
                if (!okd)
                wf = (float)__dsub_rn((double)wf0, (double)__fmul_rn(__fmul_rn(lr, bst), m_hat) / __dadd_rn((double)t59, 1e-8));
                if (0.0 < (double)wd) wf = __fsub_rn(wf, __fmul_rn(__fmul_rn(lr, wd), wf0));
                if (rtele) {
                    lN++;
                    if ((double)fabsf(__fsub_rn(wf, wf0)) < __dmul_rn((double)qscale, 0.0078125)) lU128++;
                    if (0.0 < (double)wd && 0.0 < (double)qscale) {
                        lWd += (double)__fdiv_rn(__fmul_rn(__fmul_rn(lr, wd), fabsf(wf0)), qscale); lWdN++;
                    }
                }
            }
        }
        if (use_fb) {
            if (!rcode) wf = __fadd_rn(wf, res[i]);
            else {
                float cd = (rmode == 16) ? (float)rc16[i] : (float)rc8[i];
                if (!((double)cd == 0.0) && rsk && __float_as_uint(decScale) != __float_as_uint(rSkRow)) lSkF++;
                wf = __fadd_rn(wf, __fmul_rn(__fmul_rn(cd, rKInv), decScale));
            }
        }
        g[i] = wf;
        localMax = fmaxf(localMax, fabsf(wf));
    }
    if (myTouched) touched = 1;
    float maxAbs = qaBlockMax(localMax, red);
    if (touched) {
        qaStoreRow(mqd, mqs, mb, off, cols, row, 1, lgr, red, sr_mask & 1, sr_salt, fast);
        qaStoreRow(vqd, vqs, vb, off, cols, row, 0, lgr, red, sr_mask & 2, sr_salt, fast);
    }
    double newScale = (0.0 < (double)maxAbs) ? ((double)maxAbs / 127.0) : (double)qscale;
    if (lid == 0) wscale[row] = (float)newScale;
    double inv = 1.0 / newScale;
    const float invF = (float)inv;
    if (rcode && rsk && lid == 0) rsk[row] = (float)newScale;
    for (int c = lid; c < cols; c += lsz) {
        size_t i = off + (size_t)c;
        float target = g[i];
        double t92 = 0.0;
        bool okq = false;
        if ((fast & 4) && rmode == 1) {
            float sq = __fadd_rn(__fmul_rn(target, invF), restSrUF(target, row, c, sr_salt));
            float fl = floorf(sq);
            float fr = __fsub_rn(sq, fl);
            okq = (fr > fG) && (fr < __fsub_rn(1.0f, fG));   // NaN/inf -> Rueckfall
            t92 = (double)fl;
        }
        if (!okq && (fast & 64) && !use_fb) {
            int k = atomicAdd(&wqQn, 1);
            if (k < QA_QN) { wqQ[k] = c; continue; }
        }
        if (!okq)
        t92 = (rmode == 1) ? floor(__dadd_rn(__dmul_rn((double)target, inv), (double)(float)restSrU(target, row, c, sr_salt)))
                           : round(__dmul_rn((double)target, inv));
        long q = (long)t92;
        if (127 < q) q = 127; else if (q < -128) q = -128;
        w[i] = (signed char)q;
        if (use_fb) {
            double e = __dsub_rn((double)target, __dmul_rn((double)((float)q), newScale));
            if (newScale < e) e = newScale; else if (e < -newScale) e = -newScale;
            if (rtele && 0.0 < newScale) {
                double a = __ddiv_rn(fabs(e), newScale);
                if (a < 0.125) lH0++; else if (a < 0.25) lH1++; else if (a < 0.5) lH2++; else if (a < 1.0) lH3++; else lH4++;
            }
            if (!rcode) res[i] = (float)e;
            else {
                double rel = __dmul_rn(e, inv);
                long cd;
                if (rmode == 16) cd = (long)round(__dmul_rn(rel, (double)rFakEnc));
                else cd = (long)floor(__dadd_rn(__dmul_rn(rel, (double)rFakEnc), (double)(float)restSrU((float)e, row, c, sr_salt)));
                long lim = (rmode == 16) ? 32767 : 127;
                if (lim < cd) cd = lim; else if (cd < -lim) cd = -lim;
                if (rmode == 16) rc16[i] = (short)cd; else rc8[i] = (signed char)cd;
                double dec = __dmul_rn((double)__fmul_rn((float)cd, rKInv), newScale);
                double tol = __dmul_rn(__dmul_rn(newScale, (rmode == 16) ? (0.5 / 32767.0) : ((rmode == 9) ? (1.0 / 254.0) : (1.0 / 127.0))), 1.001);
                if (tol < fabs(__dsub_rn(dec, e))) lAuF++;
            }
        }
    }
    if ((fast & 64) && !use_fb) {
        __syncthreads();
        int nq = wqQn < QA_QN ? wqQn : QA_QN;
        for (int k = lid; k < nq; k += lsz) {
            int c = wqQ[k];
            size_t i = off + (size_t)c;
            float target = g[i];
            double t92 = (rmode == 1) ? floor(__dadd_rn(__dmul_rn((double)target, inv), (double)(float)restSrU(target, row, c, sr_salt)))
                                      : round(__dmul_rn((double)target, inv));
            long q = (long)t92;
            if (127 < q) q = 127; else if (q < -128) q = -128;
            w[i] = (signed char)q;
        }
    }
    if (rcnt && (lSkF | lAuF | lU128 | lN | lWdN | lH0 | lH1 | lH2 | lH3 | lH4)) {
        if (lSkF) atomicAdd(&rcnt[0], lSkF); if (lAuF) atomicAdd(&rcnt[1], lAuF);
        if (lU128) atomicAdd(&rcnt[2], lU128); if (lN) atomicAdd(&rcnt[3], lN); if (lWdN) atomicAdd(&rcnt[4], lWdN);
        if (lH0) atomicAdd(&rcnt[5], lH0); if (lH1) atomicAdd(&rcnt[6], lH1); if (lH2) atomicAdd(&rcnt[7], lH2);
        if (lH3) atomicAdd(&rcnt[8], lH3); if (lH4) atomicAdd(&rcnt[9], lH4);
        if (lWdN) restAtomAddD(rwd, lWd);
    }
}

// 1 = gerechnet; 0 = nichts angefasst, der Aufrufer rechnet auf der CPU (er muss vorher zurueckholen).
// Fehler NACH dem Kern beenden den Prozess: die Gewichte waeren dann weder auf der Karte noch auf dem Host sicher.
// SR (2026-10-19): sr_mask Bit 1 = m, Bit 2 = v zufaellig runden; sr_salt = adam_t * 0xD1B54A32D192ED03 (wie srSalt).
// REST-16: Code-Puffer je Rest-Matrix nur auf der Karte (Schluessel = Host-Zeiger des float-Rests).
static int adam_fast_mask = -1;
static int adamFastMask() {
    if (adam_fast_mask < 0) {
        const char* e = getenv("SNAI_ADAM_FAST");
        adam_fast_mask = (e && *e) ? atoi(e) : 79;   // Vorgabe 79 = 1|2|4|8|64 (seit 2026-11-11, e611)
        std::cerr << "[ADAM-FAST] Maske " << adam_fast_mask << std::endl;
    }
    return adam_fast_mask;
}
struct RestKarte { void* key; void* d_code; float* d_sk; size_t n; int bpe; };
static RestKarte rest_karte[512]; static int rest_karte_n = 0;
static unsigned long long* rest_d_cnt = nullptr; static double* rest_d_wd = nullptr;
static void* restCodes(void* key, size_t n, int rows, int bpe, float** sk) {
    for (int i = 0; i < rest_karte_n; i++) if (rest_karte[i].key == key) {
        if (rest_karte[i].n != n || rest_karte[i].bpe != bpe) return nullptr;
        *sk = rest_karte[i].d_sk; return rest_karte[i].d_code; }
    if (rest_karte_n >= 512) return nullptr;
    void* d = nullptr; float* s = nullptr;
    if (cudaMalloc(&d, n * bpe) != cudaSuccess || cudaMemset(d, 0, n * bpe) != cudaSuccess ||
        cudaMalloc((void**)&s, (size_t)rows * sizeof(float)) != cudaSuccess ||
        cudaMemset(s, 0, (size_t)rows * sizeof(float)) != cudaSuccess) return nullptr;
    rest_karte[rest_karte_n].key = key; rest_karte[rest_karte_n].d_code = d; rest_karte[rest_karte_n].d_sk = s;
    rest_karte[rest_karte_n].n = n; rest_karte[rest_karte_n].bpe = bpe; rest_karte_n++;
    *sk = s; return d;
}
// out[0..9] wie rcnt, out_wd Summe; liest und nullt.
void cuda_rest_stats(unsigned long long* out, double* out_wd) {
    for (int i = 0; i < 10; i++) out[i] = 0; *out_wd = 0.0;
    if (!rest_d_cnt) return;
    cudaMemcpy(out, rest_d_cnt, 10 * sizeof(unsigned long long), cudaMemcpyDeviceToHost);
    cudaMemcpy(out_wd, rest_d_wd, sizeof(double), cudaMemcpyDeviceToHost);
    cudaMemset(rest_d_cnt, 0, 10 * sizeof(unsigned long long)); cudaMemset(rest_d_wd, 0, sizeof(double));
}
int cuda_adamRowQI8Rest(signed char* h_w, float* h_wscale, unsigned char* h_mqd, float* h_mqs,
                      unsigned char* h_vqd, float* h_vqs, float* h_g, float* h_res,
                      const float* h_tabM, const float* h_tabV, double lgr,
                      float lr, float b1, float b2, float b1t, float b2t, float gscale,
                      int rows, int cols, int is_sparse, int bound_r, int bound_c, float boost, float wd,
                      int use_fb, int mode, int sr_mask, unsigned long long sr_salt, int rmode, int rrot, int rtele) {
    if (!cuda_initialized || !h_w || !h_wscale || !h_mqd || !h_mqs || !h_vqd || !h_vqs || !h_g ||
        rows <= 0 || cols <= 0) return 0;
    auto t0 = std::chrono::steady_clock::now();
    size_t n = (size_t)rows * (size_t)cols;
    size_t nr = (size_t)rows * sizeof(float);
    if (!cuda_qa_tabM) {
        if (cudaMalloc((void**)&cuda_qa_tabM, 128 * sizeof(float)) != cudaSuccess ||
            cudaMalloc((void**)&cuda_qa_tabV, 256 * sizeof(float)) != cudaSuccess ||
            cudaMemcpy(cuda_qa_tabM, h_tabM, 128 * sizeof(float), cudaMemcpyHostToDevice) != cudaSuccess ||
            cudaMemcpy(cuda_qa_tabV, h_tabV, 256 * sizeof(float), cudaMemcpyHostToDevice) != cudaSuccess) {
            cuda_qa_tabM = nullptr; cuda_i8_fail("adamRowQI8 (Tabellen)"); return 0;
        }
    }
    int fb = (use_fb == 1 && h_res != nullptr) ? 1 : 0;
    int rcode = fb && (rmode == 16 || rmode == 8 || rmode == 9);
    short* d_rc16 = nullptr; signed char* d_rc8 = nullptr; float* d_rsk = nullptr;
    if (rcode) {
        void* d = restCodes((void*)h_res, n, rows, rmode == 16 ? 2 : 1, &d_rsk);
        if (!d) { cuda_i8_fail("adamRowQI8 (Rest-Codes)"); return 0; }
        if (rmode == 16) d_rc16 = (short*)d; else d_rc8 = (signed char*)d;
    }
    if (!rest_d_cnt) {
        if (cudaMalloc((void**)&rest_d_cnt, 10 * sizeof(unsigned long long)) != cudaSuccess ||
            cudaMalloc((void**)&rest_d_wd, sizeof(double)) != cudaSuccess) { rest_d_cnt = nullptr; cuda_i8_fail("adamRowQI8 (Rest-Zaehler)"); return 0; }
        cudaMemset(rest_d_cnt, 0, 10 * sizeof(unsigned long long)); cudaMemset(rest_d_wd, 0, sizeof(double));
    }
    signed char* d_w = (signed char*)cuda_get_buffer((void*)h_w, n);
    float* d_ws = (float*)cuda_get_buffer((void*)h_wscale, nr);
    unsigned char* d_mqd = (unsigned char*)cuda_get_buffer((void*)h_mqd, n);
    float* d_mqs = (float*)cuda_get_buffer((void*)h_mqs, nr);
    unsigned char* d_vqd = (unsigned char*)cuda_get_buffer((void*)h_vqd, n);
    float* d_vqs = (float*)cuda_get_buffer((void*)h_vqs, nr);
    float* d_res = (fb && !rcode) ? (float*)cuda_get_buffer((void*)h_res, n * sizeof(float)) : nullptr;
    if (!d_w || !d_ws || !d_mqd || !d_mqs || !d_vqd || !d_vqs || (fb && !rcode && !d_res) ||
        !cuda_i8_ensure(&cuda_qa_g, &cuda_qa_g_size, n * sizeof(float)) ||
        !cuda_i8_ensure(&cuda_qa_mb, &cuda_qa_mb_size, n * sizeof(float)) ||
        !cuda_i8_ensure(&cuda_qa_vb, &cuda_qa_vb_size, n * sizeof(float))) { cuda_i8_fail("adamRowQI8"); return 0; }
    // Vor dem Kern: ein Fehler hier laesst den Host massgeblich (die Karte wird nur ueberschrieben).
    float* gsrc = (float*)cuda_qa_g;
    if (cuda_qa_g_dev) {
        gsrc = (float*)cuda_find_buffer((void*)h_g, n * sizeof(float));
        if (!gsrc) { cuda_i8_fail("adamRowQI8 (g auf der Karte fehlt)"); return 0; }
    }
    bool up = cudaMemcpy(d_w, h_w, n, cudaMemcpyHostToDevice) == cudaSuccess &&
              cudaMemcpy(d_ws, h_wscale, nr, cudaMemcpyHostToDevice) == cudaSuccess &&
              (cuda_qa_g_dev || cudaMemcpy(cuda_qa_g, h_g, n * sizeof(float), cudaMemcpyHostToDevice) == cudaSuccess);
    if (up && mode == 2) {
        up = cudaMemcpy(d_mqd, h_mqd, n, cudaMemcpyHostToDevice) == cudaSuccess &&
             cudaMemcpy(d_mqs, h_mqs, nr, cudaMemcpyHostToDevice) == cudaSuccess &&
             cudaMemcpy(d_vqd, h_vqd, n, cudaMemcpyHostToDevice) == cudaSuccess &&
             cudaMemcpy(d_vqs, h_vqs, nr, cudaMemcpyHostToDevice) == cudaSuccess &&
             (!fb || rcode || cudaMemcpy(d_res, h_res, n * sizeof(float), cudaMemcpyHostToDevice) == cudaSuccess);
    }
    if (!up) { cuda_i8_fail("adamRowQI8 (hoch)"); return 0; }
    const int ova = cuda_ov_get();
    if (ova == 0) cudaDeviceSynchronize();   // nur fuer die Zeitmessung
    auto t1 = std::chrono::steady_clock::now();
    adamRowQI8Kernel<<<rows, QA_TPB>>>(d_w, d_ws, d_mqd, d_mqs, d_vqd, d_vqs, gsrc,
        (fb && !rcode) ? d_res : gsrc, (float*)cuda_qa_mb, (float*)cuda_qa_vb, cuda_qa_tabM, cuda_qa_tabV,
        lr, b1, b2, b1t, b2t, gscale, cols, is_sparse, bound_r, bound_c, boost, wd, fb, lgr, sr_mask, sr_salt,
        rmode, d_rc16, d_rc8, d_rsk, rest_d_cnt, rest_d_wd, rrot, rtele, adamFastMask());
    if (ova) memset(h_g, 0, n * sizeof(float));   // OVERLAP: waehrend der Kern rechnet (er liest nur cuda_qa_g)
    cudaDeviceSynchronize();
    if (!cuda_i8_ok("adamRowQI8")) {
        std::cerr << "🚨 [GPU-ADAM] Kernfehler - Gewichte unbestimmt, Abbruch" << std::endl;
        exit(3);
    }
    auto t2 = std::chrono::steady_clock::now();
    bool down = cudaMemcpy(h_w, d_w, n, cudaMemcpyDeviceToHost) == cudaSuccess &&
                cudaMemcpy(h_wscale, d_ws, nr, cudaMemcpyDeviceToHost) == cudaSuccess;
    if (down && mode == 2) {
        down = cudaMemcpy(h_mqd, d_mqd, n, cudaMemcpyDeviceToHost) == cudaSuccess &&
               cudaMemcpy(h_mqs, d_mqs, nr, cudaMemcpyDeviceToHost) == cudaSuccess &&
               cudaMemcpy(h_vqd, d_vqd, n, cudaMemcpyDeviceToHost) == cudaSuccess &&
               cudaMemcpy(h_vqs, d_vqs, nr, cudaMemcpyDeviceToHost) == cudaSuccess &&
               (!fb || rcode || cudaMemcpy(h_res, d_res, n * sizeof(float), cudaMemcpyDeviceToHost) == cudaSuccess);
    }
    if (!down) {
        std::cerr << "🚨 [GPU-ADAM] Rueckkopie fehlgeschlagen - Gewichte unbestimmt, Abbruch" << std::endl;
        exit(3);
    }
    if (!ova) memset(h_g, 0, n * sizeof(float));
    auto t3 = std::chrono::steady_clock::now();
    cuda_qa_t[0] += std::chrono::duration<double, std::milli>(t1 - t0).count();
    cuda_qa_t[1] += std::chrono::duration<double, std::milli>(t2 - t1).count();
    cuda_qa_t[2] += std::chrono::duration<double, std::milli>(t3 - t2).count();
    cuda_qa_t[3] += 1.0;
    return 1;
}
int cuda_adamRowQI8SR(signed char* h_w, float* h_wscale, unsigned char* h_mqd, float* h_mqs,
                      unsigned char* h_vqd, float* h_vqs, float* h_g, float* h_res,
                      const float* h_tabM, const float* h_tabV, double lgr,
                      float lr, float b1, float b2, float b1t, float b2t, float gscale,
                      int rows, int cols, int is_sparse, int bound_r, int bound_c, float boost, float wd,
                      int use_fb, int mode, int sr_mask, unsigned long long sr_salt) {
    return cuda_adamRowQI8Rest(h_w, h_wscale, h_mqd, h_mqs, h_vqd, h_vqs, h_g, h_res, h_tabM, h_tabV, lgr,
                               lr, b1, b2, b1t, b2t, gscale, rows, cols, is_sparse, bound_r, bound_c, boost, wd,
                               use_fb, mode, sr_mask, sr_salt, 32, 0, 0);
}
// Alte Schnittstelle (vor SR): rundet zum naechsten Code, bytegleich zum Stand vor 2026-10-19.
int cuda_adamRowQI8(signed char* h_w, float* h_wscale, unsigned char* h_mqd, float* h_mqs,
                    unsigned char* h_vqd, float* h_vqs, float* h_g, float* h_res,
                    const float* h_tabM, const float* h_tabV, double lgr,
                    float lr, float b1, float b2, float b1t, float b2t, float gscale,
                    int rows, int cols, int is_sparse, int bound_r, int bound_c, float boost, float wd,
                    int use_fb, int mode) {
    return cuda_adamRowQI8SR(h_w, h_wscale, h_mqd, h_mqs, h_vqd, h_vqs, h_g, h_res, h_tabM, h_tabV, lgr,
                             lr, b1, b2, b1t, b2t, gscale, rows, cols, is_sparse, bound_r, bound_c, boost, wd,
                             use_fb, mode, 0, 0ULL);
}
void cuda_get_qa_stats(double* out) { for (int i = 0; i < 4; i++) out[i] = cuda_qa_t[i]; }

} // extern "C"

// =====================================================================================================
// ATT-GPU (2026-10-14, patch_att_gpu.py): Attention des Ganzzahl-Batch-Pfads (trainStepI8Batched) auf der
// Karte, vorwaerts und rueckwaerts. Ziel: bitgleich zur CPU (cortex.nim, gleiche Schleifen).
//   - Jede Summe laeuft in derselben Reihenfolge wie auf der CPU, ein Faden je Summe (kein Baum).
//   - Float-Operationen nur ueber __f*_rn (nvcc fasst a*b+c sonst zu FMA zusammen).
//   - FTZ/DAZ wie die CPU (MXCSR 0x8040, cortex.nim snai_ftz_init): Ein- und Ausgaenge jeder Operation
//     werden ausdruecklich in Null geklappt, unabhaengig von nvcc -ftz.
//   - exp ist die glibc-expf, die auf rechner-b aufgeloest wird (FMA-Fassung, libm 2.44, Adresse 0x92ad0):
//     Tabelle und Konstanten aus der Bibliothek gelesen, die fuenf FMA-Stellen aus der Disassemblierung.
//     Geprueft gegen die echte expf ueber alle 2^32 Eingaben (att_gpu/expf_test).
// Puffer: eigene, wachsen bei Bedarf; nichts haengt am Puffer-Cache der GEMMs.
// =====================================================================================================
#include <cstdint>
#include <cfloat>

__constant__ unsigned long long att_exp_tab[32] = {
    0x3ff0000000000000ULL, 0x3fefd9b0d3158574ULL, 0x3fefb5586cf9890fULL, 0x3fef9301d0125b51ULL,
    0x3fef72b83c7d517bULL, 0x3fef54873168b9aaULL, 0x3fef387a6e756238ULL, 0x3fef1e9df51fdee1ULL,
    0x3fef06fe0a31b715ULL, 0x3feef1a7373aa9cbULL, 0x3feedea64c123422ULL, 0x3feece086061892dULL,
    0x3feebfdad5362a27ULL, 0x3feeb42b569d4f82ULL, 0x3feeab07dd485429ULL, 0x3feea47eb03a5585ULL,
    0x3feea09e667f3bcdULL, 0x3fee9f75e8ec5f74ULL, 0x3feea11473eb0187ULL, 0x3feea589994cce13ULL,
    0x3feeace5422aa0dbULL, 0x3feeb737b0cdc5e5ULL, 0x3feec49182a3f090ULL, 0x3feed503b23e255dULL,
    0x3feee89f995ad3adULL, 0x3feeff76f2fb5e47ULL, 0x3fef199bdd85529cULL, 0x3fef3720dcef9069ULL,
    0x3fef5818dcfba487ULL, 0x3fef7c97337b9b5fULL, 0x3fefa4afa2a490daULL, 0x3fefd0765b6e4540ULL};

static __device__ __forceinline__ float att_z(float x) { return (fabsf(x) < FLT_MIN) ? copysignf(0.0f, x) : x; }
static __device__ __forceinline__ float att_add(float a, float b) { return att_z(__fadd_rn(att_z(a), att_z(b))); }
static __device__ __forceinline__ float att_sub(float a, float b) { return att_z(__fsub_rn(att_z(a), att_z(b))); }
static __device__ __forceinline__ float att_mul(float a, float b) { return att_z(__fmul_rn(att_z(a), att_z(b))); }
static __device__ __forceinline__ float att_div(float a, float b) { return att_z(__fdiv_rn(att_z(a), att_z(b))); }

// variant 0 = wie die glibc-FMA-Fassung (Produktion); 1 = ohne FMA (nur fuer die Rot-Probe des Tests).
static __device__ float att_expf(float x, int variant) {
    const double InvLn2N = 0x1.71547652b82fep+5, SHIFT = 0x1.8p+52;
    const double C0 = 0x1.c6af84b912394p-20, C1 = 0x1.ebfce50fac4f3p-13, C2 = 0x1.62e42ff0c52d6p-6;
    unsigned int ux = __float_as_uint(x);
    unsigned int abstop = (ux >> 20) & 0x7ff;
    if (abstop > 0x42a) {
        if (ux == 0xff800000u) return 0.0f;
        if (abstop > 0x7f7) return x + x;
        if (x > 0x1.62e42ep+6f) return __int_as_float(0x7f800000);
        if (-0x1.9fe368p+6f > x) return 0.0f;     // __math_uflowf: 2^-190 -> 0
        if (-0x1.9d1d9ep+6f > x) return 0.0f;     // __math_may_uflowf: unter FTZ 0
    }
    double xd = (double)att_z(x);                 // DAZ wie vcvtss2sd unter MXCSR.DAZ
    double kd, r, z, y;
    if (variant == 0) kd = __fma_rn(InvLn2N, xd, SHIFT);
    else              kd = __dadd_rn(__dmul_rn(InvLn2N, xd), SHIFT);
    unsigned long long ki = (unsigned long long)__double_as_longlong(kd);
    kd = __dsub_rn(kd, SHIFT);
    if (variant == 0) r = __fma_rn(InvLn2N, xd, -kd);
    else              r = __dsub_rn(__dmul_rn(InvLn2N, xd), kd);
    unsigned long long t = att_exp_tab[ki & 31] + (ki << 47);
    double s = __longlong_as_double((long long)t);
    double r2 = __dmul_rn(r, r);
    if (variant == 0) {
        z = __fma_rn(r, C0, C1);
        y = __fma_rn(r, C2, 1.0);
        y = __fma_rn(z, r2, y);
    } else {
        z = __dadd_rn(__dmul_rn(r, C0), C1);
        y = __dadd_rn(__dmul_rn(r, C2), 1.0);
        y = __dadd_rn(__dmul_rn(z, r2), y);
    }
    y = __dmul_rn(y, s);
    return att_z(__double2float_rn(y));           // FTZ wie vcvtsd2ss unter MXCSR.FTZ
}

__global__ void att_expf_kern(const float* in, float* out, int n, int variant) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) out[i] = att_expf(in[i], variant);
}

// Scores je (Kopf, Position p, Schluessel t<=p): wie cortex.nim
//   acc = sum int8*int8; sc = acc * qScale * kScale[t]; sc /= sqrt(headSize)
__global__ void att_scores_kern(const int8_t* q8, const float* qs, const int8_t* k8, const float* ks,
                                float* S, int act, int dim, int hs, float sqrtHs) {
    int hp = blockIdx.y;                       // h * act + p
    int h = hp / act, p = hp % act;
    int t = blockIdx.x * blockDim.x + threadIdx.x;
    if (t > p) return;
    const int8_t* qrow = q8 + (size_t)p * dim + h * hs;
    const int8_t* krow = k8 + (size_t)t * dim + h * hs;
    int acc = 0;
    for (int d = 0; d < hs; d++) acc += (int)qrow[d] * (int)krow[d];
    float sc = att_mul(att_mul((float)acc, qs[p]), ks[t]);
    sc = att_div(sc, sqrtHs);
    S[(size_t)hp * act + t] = sc;
}

// Softmax je (Kopf, Position), seriell ueber t wie die CPU: max, exp/Summe, Gewicht = e / Summe.
__global__ void att_softmax_kern(float* S, int act, int nrows) {
    int hp = blockIdx.x * blockDim.x + threadIdx.x;
    if (hp >= nrows) return;
    int p = hp % act;
    float* row = S + (size_t)hp * act;
    float m = __int_as_float(0xff800000);      // NegInf
    for (int t = 0; t <= p; t++) { float sc = row[t]; if (sc > m) m = sc; }
    float sum = 0.0f;
    for (int t = 0; t <= p; t++) { float e = att_expf(att_sub(row[t], m), 0); row[t] = e; sum = att_add(sum, e); }
    for (int t = 0; t <= p; t++) row[t] = att_div(row[t], sum);
}

// Vorwaerts-Ausgabe je (Kopf, Position, d): outp += (v * vScale) * w ueber t aufsteigend.
__global__ void att_out_kern(const int8_t* v8, const float* vs, const float* W, float* out,
                             int act, int dim, int hs, int rot) {
    int hp = blockIdx.x; int d = threadIdx.x;
    if (d >= hs) return;
    int h = hp / act, p = hp % act;
    const float* wrow = W + (size_t)hp * act;
    float o = 0.0f;
    for (int t = 0; t <= p; t++)
        o = att_add(o, att_mul(att_mul((float)v8[(size_t)t * dim + h * hs + d], vs[t]), wrow[t]));
    if (rot && h == 0 && p == act - 1 && d == 0) o = att_mul(o, 1.0001f);
    out[(size_t)p * dim + h * hs + d] = o;
}

// Rueckwaerts dw je (Kopf, p, t<=p): dw += d_att * (v * vScale) ueber d aufsteigend.
__global__ void att_dw_kern(const float* datt, const int8_t* v8, const float* vs, float* DW,
                            int act, int dim, int hs) {
    int hp = blockIdx.y; int h = hp / act, p = hp % act;
    int t = blockIdx.x * blockDim.x + threadIdx.x;
    if (t > p) return;
    const float* da = datt + (size_t)p * dim + h * hs;
    const int8_t* vrow = v8 + (size_t)t * dim + h * hs;
    float vsc = vs[t];
    float dw = 0.0f;
    for (int d = 0; d < hs; d++) dw = att_add(dw, att_mul(da[d], att_mul((float)vrow[d], vsc)));
    DW[(size_t)hp * act + t] = dw;
}

// Je (Kopf, p): sum_w_dw seriell, dann der float-Teil von ds: w * (dw - sum_w_dw) (in DW abgelegt).
// Auf der CPU ist ds ein double (attScale = 1.0 / sqrt(...) ist in Nim float64, im erzeugten C NF):
//   ds = (double)(w * (dw - s)) * attScale; d_q += (float)(ds * (double)kElem); d_k += (float)(ds * (double)qElem).
// Diese double-Schritte rechnen att_ds_d und die Verbraucher (dq, dkv). Bei Kopfbreite 16/64 ist attScale eine
// Zweierpotenz und der Unterschied unsichtbar; bei 128 nicht (Vergleichstest V3, 2026-10-14).
__global__ void att_ds_kern(const float* W, float* DW, int act, int nrows) {
    int hp = blockIdx.x * blockDim.x + threadIdx.x;
    if (hp >= nrows) return;
    int p = hp % act;
    const float* wrow = W + (size_t)hp * act;
    float* drow = DW + (size_t)hp * act;
    float s = 0.0f;
    for (int t = 0; t <= p; t++) s = att_add(s, att_mul(wrow[t], drow[t]));
    for (int t = 0; t <= p; t++) drow[t] = att_mul(wrow[t], att_sub(drow[t], s));
}
static __device__ __forceinline__ double att_ds_d(float f, double attScale, int rot, int h) {
    double ds = __dmul_rn((double)f, attScale);
    if (rot && h == 0) ds = __dmul_rn(ds, (double)1.0001f);
    return ds;
}
// (float)(ds * (double)x) unter FTZ, wie cvtsd2ss
static __device__ __forceinline__ float att_dsx(double ds, float x) {
    return att_z(__double2float_rn(__dmul_rn(ds, (double)att_z(x))));
}

// d_q je (Kopf, p, d): von 0 an, += ds * (k * kScale) ueber t aufsteigend.
__global__ void att_dq_kern(const float* DS, const int8_t* k8, const float* ks, float* dq,
                            int act, int dim, int hs, double attScale, int rot) {
    int hp = blockIdx.x; int d = threadIdx.x;
    if (d >= hs) return;
    int h = hp / act, p = hp % act;
    const float* drow = DS + (size_t)hp * act;
    float a = 0.0f;
    for (int t = 0; t <= p; t++)
        a = att_add(a, att_dsx(att_ds_d(drow[t], attScale, rot, h), att_mul((float)k8[(size_t)t * dim + h * hs + d], ks[t])));
    dq[(size_t)p * dim + h * hs + d] = a;
}

// d_k und d_v je (Kopf, t, d): vom Eingangswert an, Beitraege der Positionen p = act-1 .. t absteigend
// (so faellt die Reihenfolge der CPU an: aussen p absteigend, innen t).
__global__ void att_dkv_kern(const float* DS, const float* W, const float* datt, const int8_t* q8,
                             const float* qs, float* dk, float* dv, int act, int dim, int hs, double attScale, int rot) {
    int ht = blockIdx.x; int d = threadIdx.x;
    if (d >= hs) return;
    int h = ht / act, t = ht % act;
    size_t o = (size_t)t * dim + h * hs + d;
    float k = dk[o], v = dv[o];
    for (int p = act - 1; p >= t; p--) {
        size_t hpt = ((size_t)h * act + p) * act + t;
        float qE = att_mul((float)q8[(size_t)p * dim + h * hs + d], qs[p]);
        k = att_add(k, att_dsx(att_ds_d(DS[hpt], attScale, rot, h), qE));
        v = att_add(v, att_mul(datt[(size_t)p * dim + h * hs + d], W[hpt]));
    }
    dk[o] = k; dv[o] = v;
}


// ==== ATT-FAST (2026-11-11, messbuch snai/multistack-attfast e617): schnellere Attention-Kerne, bitgleich zu den alten ====
// SNAI_ATT_FAST: fehlt/1 = schnell (Vorgabe), 0 = alte Kerne, ROT = Rot-Probe (Softmax-Summe je 32er-Stueck rueckwaerts).
// Gruppengroessen SNAI_ATT_GO (Ausgabe, 8), SNAI_ATT_GQ (dq, 4), SNAI_ATT_RK (dkv, 0 = dkv_g<1>), am RTX 3050 gemessen.
static int att_envi(const char* n, int def) { const char* e = getenv(n); return e && *e ? atoi(e) : def; }
static int att_fast_mode = -1;   // 0 alt, 1 schnell, 2 schnell + ROT
static int att_fast_get() {
    if (att_fast_mode < 0) {
        const char* e = getenv("SNAI_ATT_FAST");
        if (e && strcmp(e, "0") == 0) att_fast_mode = 0;
        else if (e && strcmp(e, "ROT") == 0) att_fast_mode = 2;
        else if (!e || !*e || strcmp(e, "1") == 0) att_fast_mode = 1;   // Vorgabe schnell (seit 2026-11-11, e617)
        else att_fast_mode = 0;
        fprintf(stderr, "[ATT-FAST] GO=%d GQ=%d RK=%d\n", att_envi("SNAI_ATT_GO", 8), att_envi("SNAI_ATT_GQ", 4), att_envi("SNAI_ATT_RK", 0));
        fprintf(stderr, "[ATT-FAST] Attention-Kerne: %s\n",
                att_fast_mode == 0 ? "alt" : att_fast_mode == 2 ? "schnell ROT-PROBE" : "schnell");
    }
    return att_fast_mode;
}
#define ATT_FULL 0xffffffffu

// scores: wie att_scores_kern, Ganzzahlsumme ueber 16-Byte-Ladungen und __dp4a (hs % 16 == 0, dim % 16 == 0).
__global__ void att_scores_fast(const int8_t* q8, const float* qs, const int8_t* k8, const float* ks,
                                float* S, int act, int dim, int hs, float sqrtHs) {
    int hp = blockIdx.y;
    int h = hp / act, p = hp % act;
    int t = blockIdx.x * blockDim.x + threadIdx.x;
    if (t > p) return;
    const int4* qrow = (const int4*)(q8 + (size_t)p * dim + h * hs);
    const int4* krow = (const int4*)(k8 + (size_t)t * dim + h * hs);
    int acc = 0;
    for (int i = 0; i < hs / 16; i++) {
        int4 a = qrow[i], b = krow[i];
        acc = __dp4a(a.x, b.x, acc); acc = __dp4a(a.y, b.y, acc);
        acc = __dp4a(a.z, b.z, acc); acc = __dp4a(a.w, b.w, acc);
    }
    float sc = att_mul(att_mul((float)acc, qs[p]), ks[t]);
    sc = att_div(sc, sqrtHs);
    S[(size_t)hp * act + t] = sc;
}

// softmax: ein Warp je (Kopf, Position). Summe seriell in t-Reihenfolge ueber shfl (jede Lane rechnet dieselbe Kette).
__global__ void att_softmax_fast(float* S, int act, int nrows, int rot) {
    int hp = blockIdx.x * (blockDim.x >> 5) + (threadIdx.x >> 5);
    int lane = threadIdx.x & 31;
    if (hp >= nrows) return;
    int p = hp % act;
    float* row = S + (size_t)hp * act;
    float m = __int_as_float(0xff800000);
    for (int t = lane; t <= p; t += 32) { float sc = row[t]; if (sc > m) m = sc; }
    for (int o = 16; o; o >>= 1) { float x = __shfl_xor_sync(ATT_FULL, m, o); if (x > m) m = x; }
    float sum = 0.0f;
    for (int base = 0; base <= p; base += 32) {
        int t = base + lane;
        float e = 0.0f;
        if (t <= p) { e = att_expf(att_sub(row[t], m), 0); row[t] = e; }
        int n = min(32, p - base + 1);
        if (rot && n > 1) { for (int j = n - 1; j >= 0; j--) sum = att_add(sum, __shfl_sync(ATT_FULL, e, j)); }
        else              { for (int j = 0; j < n; j++)      sum = att_add(sum, __shfl_sync(ATT_FULL, e, j)); }
    }
    for (int t = lane; t <= p; t += 32) row[t] = att_div(row[t], sum);
}

// dw: wie att_dw_kern, v mit 16-Byte-Ladungen; Summe ueber d seriell aufsteigend.
__global__ void att_dw_fast(const float* datt, const int8_t* v8, const float* vs, float* DW,
                            int act, int dim, int hs) {
    int hp = blockIdx.y; int h = hp / act, p = hp % act;
    int t = blockIdx.x * blockDim.x + threadIdx.x;
    if (t > p) return;
    const float* da = datt + (size_t)p * dim + h * hs;
    const int4* vrow = (const int4*)(v8 + (size_t)t * dim + h * hs);
    float vsc = vs[t];
    float dw = 0.0f;
    for (int i = 0; i < hs / 16; i++) {
        int4 w4 = vrow[i];
        int ws[4] = {w4.x, w4.y, w4.z, w4.w};
        #pragma unroll
        for (int k = 0; k < 4; k++) {
            #pragma unroll
            for (int b = 0; b < 4; b++) {
                int d = i * 16 + k * 4 + b;
                float vv = (float)(signed char)((ws[k] >> (8 * b)) & 0xff);
                dw = att_add(dw, att_mul(da[d], att_mul(vv, vsc)));
            }
        }
    }
    DW[(size_t)hp * act + t] = dw;
}

// ds: ein Warp je (Kopf, p). s seriell in t-Reihenfolge, Produkte parallel.
__global__ void att_ds_fast(const float* W, float* DW, int act, int nrows) {
    int hp = blockIdx.x * (blockDim.x >> 5) + (threadIdx.x >> 5);
    int lane = threadIdx.x & 31;
    if (hp >= nrows) return;
    int p = hp % act;
    const float* wrow = W + (size_t)hp * act;
    float* drow = DW + (size_t)hp * act;
    float s = 0.0f;
    for (int base = 0; base <= p; base += 32) {
        int t = base + lane;
        float pr = 0.0f;
        if (t <= p) pr = att_mul(wrow[t], drow[t]);
        int n = min(32, p - base + 1);
        for (int j = 0; j < n; j++) s = att_add(s, __shfl_sync(ATT_FULL, pr, j));
    }
    for (int t = lane; t <= p; t += 32) drow[t] = att_mul(wrow[t], att_sub(drow[t], s));
}

// ds*x wie att_dsx(att_ds_d(f, attScale, 0, h), x); float-Weg nur bei fast != 0 (Zweierpotenz, rot 0) und
// f*scf normal oder 0 -> dann exakt gleich, sonst double wie bisher.
static __device__ __forceinline__ float att_dsx_fast(float f, float x, int fast, float scf, double attScale) {
    if (fast) {
        float dsf = __fmul_rn(f, scf);
        if (f == 0.0f || fabsf(dsf) >= FLT_MIN) return att_z(__fmul_rn(dsf, x));
    }
    return att_dsx(__dmul_rn((double)f, attScale), x);
}

__global__ void att_dq_fast(const float* DS, const int8_t* k8, const float* ks, float* dq,
                            int act, int dim, int hs, double attScale, int fast, float scf) {
    int hp = blockIdx.x; int d = threadIdx.x;
    if (d >= hs) return;
    int h = hp / act, p = hp % act;
    const float* drow = DS + (size_t)hp * act;
    float a = 0.0f;
    for (int t = 0; t <= p; t++)
        a = att_add(a, att_dsx_fast(drow[t], att_mul((float)k8[(size_t)t * dim + h * hs + d], ks[t]), fast, scf, attScale));
    dq[(size_t)p * dim + h * hs + d] = a;
}

__global__ void att_dkv_fast(const float* DS, const float* W, const float* datt, const int8_t* q8,
                             const float* qs, float* dk, float* dv, int act, int dim, int hs, double attScale,
                             int fast, float scf) {
    int ht = blockIdx.x; int d = threadIdx.x;
    if (d >= hs) return;
    int h = ht / act, t = ht % act;
    size_t o = (size_t)t * dim + h * hs + d;
    float k = dk[o], v = dv[o];
    for (int p = act - 1; p >= t; p--) {
        size_t hpt = ((size_t)h * act + p) * act + t;
        float qE = att_mul((float)q8[(size_t)p * dim + h * hs + d], qs[p]);
        k = att_add(k, att_dsx_fast(DS[hpt], qE, fast, scf, attScale));
        v = att_add(v, att_mul(datt[(size_t)p * dim + h * hs + d], W[hpt]));
    }
    dk[o] = k; dv[o] = v;
}

// Gruppenkerne: ein Block rechnet G benachbarte Ausgabezeilen (p bzw. t) je Kopf. Jede Ausgabe behaelt ihre eigene
// serielle Kette in derselben Reihenfolge; geteilt werden nur die geladenen k/q/v-Werte. G per SNAI_ATT_G (2/4/8).
template<int G>
__global__ void att_out_g(const int8_t* v8, const float* vs, const float* W, float* out,
                          int act, int dim, int hs, int rot) {
    int ng = (act + G - 1) / G;
    int h = blockIdx.x / ng, p0 = (blockIdx.x % ng) * G;
    int d = threadIdx.x;
    if (d >= hs) return;
    int pmax = min(p0 + G - 1, act - 1);
    const float* wbase = W + ((size_t)h * act + p0) * act;
    float o[G];
    #pragma unroll
    for (int j = 0; j < G; j++) o[j] = 0.0f;
    for (int t = 0; t <= pmax; t++) {
        float vx = att_mul((float)v8[(size_t)t * dim + h * hs + d], vs[t]);
        #pragma unroll
        for (int j = 0; j < G; j++)
            if (t <= p0 + j && p0 + j < act) o[j] = att_add(o[j], att_mul(vx, wbase[(size_t)j * act + t]));
    }
    #pragma unroll
    for (int j = 0; j < G; j++) {
        int p = p0 + j;
        if (p < act) {
            float oo = o[j];
            if (rot && h == 0 && p == act - 1 && d == 0) oo = att_mul(oo, 1.0001f);
            out[(size_t)p * dim + h * hs + d] = oo;
        }
    }
}
template<int G>
__global__ void att_dq_g(const float* DS, const int8_t* k8, const float* ks, float* dq,
                         int act, int dim, int hs, double attScale, int fast, float scf) {
    int ng = (act + G - 1) / G;
    int h = blockIdx.x / ng, p0 = (blockIdx.x % ng) * G;
    int d = threadIdx.x;
    if (d >= hs) return;
    int pmax = min(p0 + G - 1, act - 1);
    const float* dbase = DS + ((size_t)h * act + p0) * act;
    float a[G];
    #pragma unroll
    for (int j = 0; j < G; j++) a[j] = 0.0f;
    for (int t = 0; t <= pmax; t++) {
        float kx = att_mul((float)k8[(size_t)t * dim + h * hs + d], ks[t]);
        #pragma unroll
        for (int j = 0; j < G; j++)
            if (t <= p0 + j && p0 + j < act) a[j] = att_add(a[j], att_dsx_fast(dbase[(size_t)j * act + t], kx, fast, scf, attScale));
    }
    #pragma unroll
    for (int j = 0; j < G; j++) if (p0 + j < act) dq[(size_t)(p0 + j) * dim + h * hs + d] = a[j];
}
template<int G>
__global__ void att_dkv_g(const float* DS, const float* W, const float* datt, const int8_t* q8,
                          const float* qs, float* dk, float* dv, int act, int dim, int hs, double attScale,
                          int fast, float scf) {
    int ng = (act + G - 1) / G;
    int h = blockIdx.x / ng, t0 = (blockIdx.x % ng) * G;
    int d = threadIdx.x;
    if (d >= hs) return;
    float k[G], v[G];
    #pragma unroll
    for (int j = 0; j < G; j++) {
        k[j] = 0.0f; v[j] = 0.0f;
        if (t0 + j < act) { size_t o = (size_t)(t0 + j) * dim + h * hs + d; k[j] = dk[o]; v[j] = dv[o]; }
    }
    for (int p = act - 1; p >= t0; p--) {
        float qE = att_mul((float)q8[(size_t)p * dim + h * hs + d], qs[p]);
        float da = datt[(size_t)p * dim + h * hs + d];
        size_t base = ((size_t)h * act + p) * act + t0;
        #pragma unroll
        for (int j = 0; j < G; j++)
            if (p >= t0 + j && t0 + j < act) {
                k[j] = att_add(k[j], att_dsx_fast(DS[base + j], qE, fast, scf, attScale));
                v[j] = att_add(v[j], att_mul(da, W[base + j]));
            }
    }
    #pragma unroll
    for (int j = 0; j < G; j++)
        if (t0 + j < act) { size_t o = (size_t)(t0 + j) * dim + h * hs + d; dk[o] = k[j]; dv[o] = v[j]; }
}

// dkv mit R Zeilen t je Block als getrennte Fadengruppen (keine geteilte Kette, nur mehr Faeden je Block).
template<int R>
__global__ void att_dkv_r(const float* DS, const float* W, const float* datt, const int8_t* q8,
                          const float* qs, float* dk, float* dv, int act, int dim, int hs, double attScale,
                          int fast, float scf) {
    int nb = (act + R - 1) / R;
    int h = blockIdx.x / nb;
    int t = (blockIdx.x % nb) * R + threadIdx.x / hs;
    int d = threadIdx.x % hs;
    if (t >= act) return;
    size_t o = (size_t)t * dim + h * hs + d;
    float k = dk[o], v = dv[o];
    for (int p = act - 1; p >= t; p--) {
        size_t hpt = ((size_t)h * act + p) * act + t;
        // alle Ladungen vor die Rechnung (sonst haelt der double-Rueckfall sie hinter der Kette fest)
        const float qv = (float)q8[(size_t)p * dim + h * hs + d], qsc = qs[p];
        const float da = datt[(size_t)p * dim + h * hs + d], w = W[hpt], f = DS[hpt];
        float qE = att_mul(qv, qsc);
        k = att_add(k, att_dsx_fast(f, qE, fast, scf, attScale));
        v = att_add(v, att_mul(da, w));
    }
    dk[o] = k; dv[o] = v;
}
static int att_g = -1;
static int att_g_get() {
    if (att_g < 0) {
        const char* e = getenv("SNAI_ATT_G");
        int g = e && *e ? atoi(e) : 4;
        att_g = (g == 1 || g == 2 || g == 8) ? g : 4;
        fprintf(stderr, "[ATT-FAST] Gruppe G=%d\n", att_g);
    }
    return att_g;
}
#define ATT_GLAUNCH(K, GV, ...) do { int g_ = GV; \
    if (g_ == 1) K<1><<<nH * ((act + 0) / 1), hs>>>(__VA_ARGS__); \
    else if (g_ == 2) K<2><<<nH * ((act + 1) / 2), hs>>>(__VA_ARGS__); \
    else if (g_ == 8) K<8><<<nH * ((act + 7) / 8), hs>>>(__VA_ARGS__); \
    else K<4><<<nH * ((act + 3) / 4), hs>>>(__VA_ARGS__); } while (0)
// attScale als float-Zweierpotenz in (0, 1] -> float-Weg erlaubt
static int att_scale_pow2(double a, float* scf) {
    if (!(a > 0.0 && a <= 1.0)) return 0;
    int e; double m = frexp(a, &e);
    if (m != 0.5 || e < -125) return 0;
    *scf = (float)a;
    return (double)*scf == a;
}

static void* att_buf[12] = {0};
static size_t att_cap[12] = {0};
static double att_t[4] = {0, 0, 0, 0};           // ms vorwaerts, ms rueckwaerts, Aufrufe vw, Aufrufe rw
static bool att_need(int i, size_t bytes) {
    if (att_cap[i] >= bytes) return true;
    if (att_buf[i]) cudaFree(att_buf[i]);
    att_buf[i] = nullptr; att_cap[i] = 0;
    if (cudaMalloc(&att_buf[i], bytes) != cudaSuccess) { att_buf[i] = nullptr; return false; }
    att_cap[i] = bytes;
    return true;
}
static bool att_up(int i, const void* h, size_t bytes) {
    return att_need(i, bytes) && cudaMemcpy(att_buf[i], h, bytes, cudaMemcpyHostToDevice) == cudaSuccess;
}

extern "C" {

int cuda_att_expf_test(const float* h_in, float* h_out, int n, int variant) {
    if (!att_up(0, h_in, (size_t)n * 4) || !att_need(1, (size_t)n * 4)) return 1;
    att_expf_kern<<<(n + 255) / 256, 256>>>((const float*)att_buf[0], (float*)att_buf[1], n, variant);
    if (cudaDeviceSynchronize() != cudaSuccess || cudaGetLastError() != cudaSuccess) return 2;
    return cudaMemcpy(h_out, att_buf[1], (size_t)n * 4, cudaMemcpyDeviceToHost) == cudaSuccess ? 0 : 3;
}

// Rueckgabe 0 = gerechnet; sonst nichts veraendert, der Aufrufer rechnet auf der CPU.
int cuda_att_fwd_i8(const int8_t* q8, const float* qs, const int8_t* k8, const float* ks,
                    const int8_t* v8, const float* vs, float* out,
                    int act, int dim, int nH, int hs, float sqrtHs, int rot) {
    if (act <= 0 || hs > 1024 || (long)nH * act > 65535 || nH * hs != dim) return 9;
    auto t0 = std::chrono::steady_clock::now();
    size_t ad = (size_t)act * dim, aa = (size_t)nH * act * act;
    if (!att_up(0, q8, ad) || !att_up(1, qs, act * 4) || !att_up(2, k8, ad) || !att_up(3, ks, act * 4) ||
        !att_up(4, v8, ad) || !att_up(5, vs, act * 4) || !att_need(6, aa * 4) || !att_need(7, ad * 4)) return 1;
    float* S = (float*)att_buf[6];
    const int fm = att_fast_get();
    if (fm && hs % 16 == 0 && dim % 16 == 0)
        att_scores_fast<<<dim3((act + 255) / 256, nH * act), 256>>>((const int8_t*)att_buf[0], (const float*)att_buf[1],
            (const int8_t*)att_buf[2], (const float*)att_buf[3], S, act, dim, hs, sqrtHs);
    else
        att_scores_kern<<<dim3((act + 255) / 256, nH * act), 256>>>((const int8_t*)att_buf[0], (const float*)att_buf[1],
            (const int8_t*)att_buf[2], (const float*)att_buf[3], S, act, dim, hs, sqrtHs);
    if (fm) att_softmax_fast<<<(nH * act + 3) / 4, 128>>>(S, act, nH * act, fm == 2);
    else    att_softmax_kern<<<(nH * act + 127) / 128, 128>>>(S, act, nH * act);
    if (fm) ATT_GLAUNCH(att_out_g, att_envi("SNAI_ATT_GO", 8), (const int8_t*)att_buf[4], (const float*)att_buf[5], S, (float*)att_buf[7],
        act, dim, hs, rot);
    else att_out_kern<<<nH * act, hs>>>((const int8_t*)att_buf[4], (const float*)att_buf[5], S, (float*)att_buf[7],
        act, dim, hs, rot);
    if (cudaDeviceSynchronize() != cudaSuccess || cudaGetLastError() != cudaSuccess) return 2;
    if (cudaMemcpy(out, att_buf[7], ad * 4, cudaMemcpyDeviceToHost) != cudaSuccess) return 3;
    att_t[0] += std::chrono::duration<double, std::milli>(std::chrono::steady_clock::now() - t0).count();
    att_t[2] += 1.0;
    return 0;
}

int cuda_att_bw_i8(const int8_t* q8, const float* qs, const int8_t* k8, const float* ks,
                   const int8_t* v8, const float* vs, const float* datt, float* dq, float* dk, float* dv,
                   int act, int dim, int nH, int hs, float sqrtHs, double attScale, int rot) {
    if (act <= 0 || hs > 1024 || (long)nH * act > 65535 || nH * hs != dim) return 9;
    auto t0 = std::chrono::steady_clock::now();
    size_t ad = (size_t)act * dim, aa = (size_t)nH * act * act;
    if (!att_up(0, q8, ad) || !att_up(1, qs, act * 4) || !att_up(2, k8, ad) || !att_up(3, ks, act * 4) ||
        !att_up(4, v8, ad) || !att_up(5, vs, act * 4) || !att_need(6, aa * 4) || !att_need(8, aa * 4) ||
        !att_up(9, datt, ad * 4) || !att_up(10, dk, ad * 4) || !att_up(11, dv, ad * 4) || !att_need(7, ad * 4)) return 1;
    float* W = (float*)att_buf[6]; float* DS = (float*)att_buf[8];
    const int fm = att_fast_get();
    const bool vec = fm && hs % 16 == 0 && dim % 16 == 0;
    if (vec)
        att_scores_fast<<<dim3((act + 255) / 256, nH * act), 256>>>((const int8_t*)att_buf[0], (const float*)att_buf[1],
            (const int8_t*)att_buf[2], (const float*)att_buf[3], W, act, dim, hs, sqrtHs);
    else
        att_scores_kern<<<dim3((act + 255) / 256, nH * act), 256>>>((const int8_t*)att_buf[0], (const float*)att_buf[1],
            (const int8_t*)att_buf[2], (const float*)att_buf[3], W, act, dim, hs, sqrtHs);
    if (fm) att_softmax_fast<<<(nH * act + 3) / 4, 128>>>(W, act, nH * act, fm == 2);
    else    att_softmax_kern<<<(nH * act + 127) / 128, 128>>>(W, act, nH * act);
    if (vec)
        att_dw_fast<<<dim3((act + 255) / 256, nH * act), 256>>>((const float*)att_buf[9], (const int8_t*)att_buf[4],
            (const float*)att_buf[5], DS, act, dim, hs);
    else
        att_dw_kern<<<dim3((act + 255) / 256, nH * act), 256>>>((const float*)att_buf[9], (const int8_t*)att_buf[4],
            (const float*)att_buf[5], DS, act, dim, hs);
    if (fm) att_ds_fast<<<(nH * act + 3) / 4, 128>>>(W, DS, act, nH * act);
    else    att_ds_kern<<<(nH * act + 127) / 128, 128>>>(W, DS, act, nH * act);
    float scf = 0.0f;
    const int fdq = (fm && rot == 0 && att_scale_pow2(attScale, &scf)) ? 1 : 0;
    if (fm && rot == 0) {
        ATT_GLAUNCH(att_dq_g, att_envi("SNAI_ATT_GQ", 4), DS, (const int8_t*)att_buf[2], (const float*)att_buf[3], (float*)att_buf[7],
            act, dim, hs, attScale, fdq, scf);
        { const int rk = att_envi("SNAI_ATT_RK", 0);
          const int rr = (rk == 1 || rk == 2 || rk == 4) && hs * rk <= 1024 ? rk : 0;
          if (rr == 0) att_dkv_g<1><<<nH * act, hs>>>(DS, W, (const float*)att_buf[9], (const int8_t*)att_buf[0],
            (const float*)att_buf[1], (float*)att_buf[10], (float*)att_buf[11], act, dim, hs, attScale, fdq, scf);
          else
          if (rr == 4) att_dkv_r<4><<<nH * ((act + 3) / 4), hs * 4>>>(DS, W, (const float*)att_buf[9], (const int8_t*)att_buf[0],
            (const float*)att_buf[1], (float*)att_buf[10], (float*)att_buf[11], act, dim, hs, attScale, fdq, scf);
          else if (rr == 2) att_dkv_r<2><<<nH * ((act + 1) / 2), hs * 2>>>(DS, W, (const float*)att_buf[9], (const int8_t*)att_buf[0],
            (const float*)att_buf[1], (float*)att_buf[10], (float*)att_buf[11], act, dim, hs, attScale, fdq, scf);
          else att_dkv_r<1><<<nH * act, hs>>>(DS, W, (const float*)att_buf[9], (const int8_t*)att_buf[0],
            (const float*)att_buf[1], (float*)att_buf[10], (float*)att_buf[11], act, dim, hs, attScale, fdq, scf); }
    }
    else {   // rot (alte Rot-Probe der Kartenattention) bleibt beim alten Weg
        att_dq_kern<<<nH * act, hs>>>(DS, (const int8_t*)att_buf[2], (const float*)att_buf[3], (float*)att_buf[7],
            act, dim, hs, attScale, rot);
        att_dkv_kern<<<nH * act, hs>>>(DS, W, (const float*)att_buf[9], (const int8_t*)att_buf[0],
            (const float*)att_buf[1], (float*)att_buf[10], (float*)att_buf[11], act, dim, hs, attScale, rot);
    }
    if (cudaDeviceSynchronize() != cudaSuccess || cudaGetLastError() != cudaSuccess) return 2;
    if (cudaMemcpy(dq, att_buf[7], ad * 4, cudaMemcpyDeviceToHost) != cudaSuccess ||
        cudaMemcpy(dk, att_buf[10], ad * 4, cudaMemcpyDeviceToHost) != cudaSuccess ||
        cudaMemcpy(dv, att_buf[11], ad * 4, cudaMemcpyDeviceToHost) != cudaSuccess) {
        std::cerr << "🚨 [ATT-GPU] Rueckkopie fehlgeschlagen - Gradienten unbestimmt, Abbruch" << std::endl;
        exit(3);
    }
    att_t[1] += std::chrono::duration<double, std::milli>(std::chrono::steady_clock::now() - t0).count();
    att_t[3] += 1.0;
    return 0;
}

void cuda_att_stats(double* o) { for (int i = 0; i < 4; i++) o[i] = att_t[i]; }

} // extern "C" (ATT-GPU)

// =====================================================================================================
// RESIDENT (seit 2026-11-11, Vorgabe an; messbuch snai/multistack-resident-fwd e624, snai/multistack-resident-bw e625):
// Zwischenergebnisse des Vorwaertswegs bleiben auf der Karte. Eigene Puffertabelle (Schluessel = Hostzeiger,
// beim Anlegen KEIN Hochladen), getrennt vom GEMM-Puffercache (cuda_get_buffer), damit kein anderer Pfad einen
// veralteten Kartenstand fuer aktuell haelt. Rechenregeln wie ATT-GPU: jede float-Operation ueber att_add/att_mul/
// att_div (FTZ/DAZ wie die CPU), jede Summe seriell in CPU-Reihenfolge (ein Warp je Zeile, Kette ueber
// __shfl_sync), exp = att_expf (glibc-Nachbau). Einstieg: cuda_res(op, p, n, f), Rueckgabe 0 = gerechnet.
// =====================================================================================================
struct ResBuf { const void* h; void* d; size_t bytes; };
static ResBuf res_tab[512];
static int res_n = 0;
static double res_t[4] = {0, 0, 0, 0};   // Aufrufe, Fehler, -, -
static void* res_dev(const void* h, size_t bytes) {
    if (!h || bytes == 0) return nullptr;
    for (int i = 0; i < res_n; i++)
        if (res_tab[i].h == h) {
            if (res_tab[i].bytes >= bytes) return res_tab[i].d;
            cudaFree(res_tab[i].d); res_tab[i].d = nullptr; res_tab[i].bytes = 0;
            if (cudaMalloc(&res_tab[i].d, bytes) != cudaSuccess) { res_tab[i].d = nullptr; return nullptr; }
            res_tab[i].bytes = bytes;
            return res_tab[i].d;
        }
    if (res_n >= 512) return nullptr;
    void* d = nullptr;
    if (cudaMalloc(&d, bytes) != cudaSuccess) return nullptr;
    res_tab[res_n].h = h; res_tab[res_n].d = d; res_tab[res_n].bytes = bytes; res_n++;
    return d;
}

// Serielle Summe s = (((0 + f(x0)) + f(x1)) + ...) in CPU-Reihenfolge; ein Warp, alle Lanes erhalten s.
template <int K>
static __device__ __forceinline__ float res_chain(const float* x, int n) {
    const int lane = threadIdx.x & 31;
    float s = 0.0f;
    for (int b = 0; b < n; b += 32) {
        float v = 0.0f;
        if (b + lane < n) { float a = x[b + lane]; v = (K == 0) ? att_mul(a, a) : fabsf(a); }
        const int m = min(32, n - b);
        for (int j = 0; j < m; ++j) s = att_add(s, __shfl_sync(0xffffffffu, v, j));
    }
    return s;
}

// applyRMSNorm je Position: ss seriell, inv = 1/sqrt(ss/dim + 1e-5), o = x*inv*w.
// rot = 1: Rot-Probe, letzte Rundung auf float zur Null hin statt zum Naechsten (nur das letzte Bit, etwa jeder
// zweite Wert). Die erste Fassung (FMA im double-Zwischenwert) blieb gruen: der Fehler verschwand beim Runden auf float.
__global__ void res_rmsnorm_k(const float* in, float* out, const float* w, int act, int dim, int rot) {
    const int row = blockIdx.x * 4 + (threadIdx.x >> 5), lane = threadIdx.x & 31;
    if (row >= act) return;
    const float* x = in + (size_t)row * dim;
    float* o = out + (size_t)row * dim;
    const float ss = res_chain<0>(x, dim);
    // Nim: inv ist float64 (Literal 1.0), ss/dim float32, + 1e-5 und sqrt in double, o = float(double(x)*inv*double(w)).
    const double t = __dadd_rn((double)att_div(ss, (float)dim), 0.00001);
    const double inv = __ddiv_rn(1.0, __dsqrt_rn(t));
    for (int d = lane; d < dim; d += 32) {
        const double y = __dmul_rn(__dmul_rn((double)att_z(x[d]), inv), (double)att_z(w[d]));
        o[d] = att_z(rot ? __double2float_rz(y) : __double2float_rn(y));
    }
}

// quantizeVectorToQ8Row / quantizeActivationBatch je Position (identische Rechnung): Abs-Max (Vergleich unter DAZ),
// Summe der Betraege seriell (nur fuer die Endlichkeitspruefung), scale = max/127 (double), q = clamp(trunc(round(x/scale))).
// sc[row] = NaN, wenn die Summe nicht endlich ist (quantSummeKaputt), die Werte selbst mit scale.
__global__ void res_qrows_k(const float* in, int8_t* q, float* sc, int act, int n) {
    const int row = blockIdx.x * 4 + (threadIdx.x >> 5), lane = threadIdx.x & 31;
    if (row >= act) return;
    const float* x = in + (size_t)row * n;
    float m = 0.0f;
    for (int d = lane; d < n; d += 32) { const float a = fabsf(x[d]); if (att_z(a) > att_z(m)) m = a; }
    for (int off = 16; off > 0; off >>= 1) { const float o = __shfl_down_sync(0xffffffffu, m, off); if (att_z(o) > att_z(m)) m = o; }
    m = __shfl_sync(0xffffffffu, m, 0);
    const float summe = res_chain<1>(x, n);
    // Nim: scale ist float64 (maxAbs/127.0 in double), gespeichert als float; q = round(double(x)/scale) in double.
    const double scale = (att_z(m) > 0.0f) ? __ddiv_rn((double)m, 127.0) : 1.0;
    if (lane == 0) sc[row] = (__fsub_rn(summe, summe) != 0.0f || summe != summe) ? __int_as_float(0x7fc00000)
                                                                                : att_z(__double2float_rn(scale));
    int8_t* qo = q + (size_t)row * n;
    for (int d = lane; d < n; d += 32) {
        const double r = round(__ddiv_rn((double)att_z(x[d]), scale));
        long long qi = (r != r || !(fabs(r) < 9.223372036854775808e18)) ? (long long)0x8000000000000000ULL : (long long)r;
        if (qi > 127) qi = 127; else if (qi < -128) qi = -128;
        qo[d] = (int8_t)qi;
    }
}

// applyRoPE mit Tabelle (cos_t, sin_t je Position und Paar, auf der CPU mit derselben Formel gerechnet).
__global__ void res_rope_k(float* v, const float* tab, int act, int dim, int hs) {
    const size_t idx = (size_t)blockIdx.x * blockDim.x + threadIdx.x;
    const int half = dim >> 1, hh = hs >> 1;
    if (idx >= (size_t)act * half) return;
    const int p = (int)(idx / half), j = (int)(idx % half);
    const int h = j / hh, k = j % hh;
    const float c = tab[((size_t)p * hh + k) * 2], s = tab[((size_t)p * hh + k) * 2 + 1];
    float* e = v + (size_t)p * dim + (size_t)h * hs + 2 * k;
    const float v0 = e[0], v1 = e[1];
    e[0] = att_sub(att_mul(v0, c), att_mul(v1, s));
    e[1] = att_add(att_mul(v0, s), att_mul(v1, c));
}

__global__ void res_add_k(float* dst, const float* src, size_t n) {
    const size_t i = (size_t)blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) dst[i] = att_add(dst[i], src[i]);
}

// siluRowFromQ8: Tabelle je Zeile (256 Eintraege) aus der Zeilenskala, dann Nachschlagen.
__global__ void res_silu_k(const int8_t* q8, const float* qs, float* out, int act, int n) {
    __shared__ float lut[256];
    const int row = blockIdx.x;
    if (row >= act) return;
    const float sc = qs[row];
    {
        const int t = threadIdx.x;
        const float v = att_mul((float)(t - 128), sc);
        lut[t] = att_mul(v, att_div(1.0f, att_add(1.0f, att_expf(-v, 0))));
    }
    __syncthreads();
    const int8_t* qi = q8 + (size_t)row * n;
    float* o = out + (size_t)row * n;
    for (int i = threadIdx.x; i < n; i += 256) o[i] = lut[(int)qi[i] + 128];
}

// Softmax je Position (max ab -9999, exp, serielle Summe, Teilen), Wahrscheinlichkeit am Ziel fuer den Loss
// (ln rechnet die CPU), dann d_logits = p - Ziel (Label-Smoothing 0) bzw. 0 ohne Maske. Alles in place.
__global__ void res_softmax_k(float* lg, const int* tg, const int* mask, float* ptg, int act, int V) {
    const int row = blockIdx.x * 4 + (threadIdx.x >> 5), lane = threadIdx.x & 31;
    if (row >= act) return;
    float* x = lg + (size_t)row * V;
    float m = -9999.0f;
    for (int v = lane; v < V; v += 32) if (att_z(x[v]) > att_z(m)) m = x[v];
    for (int off = 16; off > 0; off >>= 1) { const float o = __shfl_down_sync(0xffffffffu, m, off); if (att_z(o) > att_z(m)) m = o; }
    m = __shfl_sync(0xffffffffu, m, 0);
    for (int v = lane; v < V; v += 32) x[v] = att_expf(att_sub(x[v], m), 0);
    __syncwarp();
    float s = 0.0f;
    for (int b = 0; b < V; b += 32) {
        const float e = (b + lane < V) ? x[b + lane] : 0.0f;
        const int mm = min(32, V - b);
        for (int j = 0; j < mm; ++j) s = att_add(s, __shfl_sync(0xffffffffu, e, j));
    }
    for (int v = lane; v < V; v += 32) x[v] = att_div(x[v], s);
    __syncwarp();
    int t = tg[row]; if (t < 0 || t >= V) t = 0;
    if (lane == 0) ptg[row] = x[t];
    __syncwarp();
    const int mk = mask[row];
    for (int v = lane; v < V; v += 32) x[v] = mk != 0 ? att_sub(x[v], v == t ? 1.0f : 0.0f) : 0.0f;
}

static inline int res_ok() {
    cudaError_t e = cudaGetLastError();
    if (e != cudaSuccess) { fprintf(stderr, "[RESIDENT] Kartenfehler: %s\n", cudaGetErrorString(e)); return 0; }
    return 1;
}
static int8_t* res_gq = nullptr; static size_t res_gq_cap = 0;   // int8-Eingang der GEMMs
static float* res_gs = nullptr; static size_t res_gs_cap = 0;    // Skalen dazu
static bool res_grow(void** b, size_t* cap, size_t bytes) {
    if (*cap >= bytes) return true;
    if (*b) cudaFree(*b);
    *b = nullptr; *cap = 0;
    if (cudaMalloc(b, bytes) != cudaSuccess) { *b = nullptr; return false; }
    *cap = bytes; return true;
}

extern "C" {

// op: 1 hoch (p0 Host, n0 Bytes, n1 Kapazitaet) | 2 runter (p0, n0, n1) | 3 Karte->Karte (p0 Quelle, p1 Ziel, n0, n1)
//     4 RMSNorm (p0 ein, p1 aus, p2 Gewicht Host; n0 act, n1 dim, n2 rot) | 5 GEMM (p0 M, p1 Mscale, p2 ein, p3 aus;
//     n0 rows, n1 cols, n2 batch, n3 1 = Gewichte jeden Aufruf aus der eigenen Tabelle hochladen)
//     6 Quantisieren je Zeile (p0 ein, p1 int8, p2 Skalen; n0 act, n1 Breite, n2 Kapazitaet Zeilen)
//     7 RoPE (p0 Vektor, p1 Tabelle Host; n0 act, n1 dim, n2 hs, n3 Tabellenbytes, n4 1 = Tabelle hochladen)
//     8 Addieren (p0 Ziel, p1 Quelle, n0 Elemente) | 9 Attention vorwaerts (p0 act_q, p1 k8, p2 ks, p3 v8, p4 vs,
//     p5 aus; n0 act, n1 dim, n2 nH, n3 hs, n4 Kapazitaet Zeilen; f0 sqrt(hs)) | 10 SiLU (p0 q8, p1 qs, p2 aus;
//     n0 act, n1 ffn) | 11 Softmax (p0 logits, p1 Ziele Host, p2 Maske Host, p3 p_Ziel Host; n0 act, n1 V, n2 Kap.)
//     12 Synchronisieren | 13 Zaehler (p0 double[4]) | 14 Platz anlegen (p0, n1 Kapazitaet)
int cuda_res(int op, void* const* p, const long long* n, const float* f) {
    if (!cuda_initialized) return 1;
    res_t[0] += 1.0;
    switch (op) {
    case 1: { void* d = res_dev(p[0], (size_t)n[1]); if (!d) return 2;
              return cudaMemcpy(d, p[0], (size_t)n[0], cudaMemcpyHostToDevice) == cudaSuccess ? 0 : 3; }
    case 2: { void* d = res_dev(p[0], (size_t)n[1]); if (!d) return 2;
              return cudaMemcpy(p[0], d, (size_t)n[0], cudaMemcpyDeviceToHost) == cudaSuccess ? 0 : 3; }
    case 3: { void* s = res_dev(p[0], (size_t)n[1]); void* d = res_dev(p[1], (size_t)n[1]); if (!s || !d) return 2;
              return cudaMemcpy(d, s, (size_t)n[0], cudaMemcpyDeviceToDevice) == cudaSuccess ? 0 : 3; }
    case 4: { const size_t ad = (size_t)n[0] * n[1];
              float* di = (float*)res_dev(p[0], ad * 4); float* dout = (float*)res_dev(p[1], ad * 4);
              float* dw = (float*)res_dev(p[2], (size_t)n[1] * 4);
              if (!di || !dout || !dw) return 2;
              if (cudaMemcpy(dw, p[2], (size_t)n[1] * 4, cudaMemcpyHostToDevice) != cudaSuccess) return 3;
              res_rmsnorm_k<<<(unsigned)((n[0] + 3) / 4), 128>>>(di, dout, dw, (int)n[0], (int)n[1], (int)n[2]);
              return res_ok() ? 0 : 4; }
    case 5: { const int rows = (int)n[0], cols = (int)n[1], batch = (int)n[2];
              const size_t sM = (size_t)rows * cols, sMs = (size_t)rows * 4;
              const signed char* dM; const float* dMs;
              if (n[3]) {
                  void* a = res_dev(p[0], sM); void* b = res_dev(p[1], sMs); if (!a || !b) return 2;
                  if (cudaMemcpy(a, p[0], sM, cudaMemcpyHostToDevice) != cudaSuccess ||
                      cudaMemcpy(b, p[1], sMs, cudaMemcpyHostToDevice) != cudaSuccess) return 3;
                  dM = (const signed char*)a; dMs = (const float*)b;
              } else {
                  dM = (const signed char*)cuda_get_buffer(p[0], sM); dMs = (const float*)cuda_get_buffer(p[1], sMs);
                  if (!dM || !dMs) return 2;
              }
              const float* di = (const float*)res_dev(p[2], (size_t)batch * cols * 4);
              float* dout = (float*)res_dev(p[3], (size_t)batch * rows * 4);
              if (!di || !dout || !res_grow((void**)&res_gq, &res_gq_cap, (size_t)batch * cols) ||
                  !res_grow((void**)&res_gs, &res_gs_cap, (size_t)batch * 4)) return 2;
              res_qrows_k<<<(unsigned)((batch + 3) / 4), 128>>>(di, res_gq, res_gs, batch, cols);
              const int fm = cuda_fwd_get_mode();
              if (fm > 0 && (cols % 4) == 0) {
                  dim3 grid((unsigned)((rows + FWD_T - 1) / FWD_T), (unsigned)((batch + FWD_T - 1) / FWD_T));
                  matMulBatchedI8TiledKernel<<<grid, 256>>>(dM, dMs, (const signed char*)res_gq, res_gs, dout,
                                                           rows, cols, batch, fm == 2 ? 1 : 0);
              } else {
                  const size_t total = (size_t)rows * batch;
                  matMulBatchedI8Kernel<<<(int)((total + 255) / 256), 256>>>(dM, dMs, (const signed char*)res_gq, res_gs,
                                                                         dout, rows, cols, batch);
              }
              return res_ok() ? 0 : 4; }
    case 6: { const size_t cap = (size_t)n[2];
              const float* di = (const float*)res_dev(p[0], (size_t)n[0] * n[1] * 4);
              int8_t* dq = (int8_t*)res_dev(p[1], cap * n[1]); float* ds = (float*)res_dev(p[2], cap * 4);
              if (!di || !dq || !ds) return 2;
              res_qrows_k<<<(unsigned)((n[0] + 3) / 4), 128>>>(di, dq, ds, (int)n[0], (int)n[1]);
              return res_ok() ? 0 : 4; }
    case 7: { float* dv = (float*)res_dev(p[0], (size_t)n[0] * n[1] * 4); float* dt = (float*)res_dev(p[1], (size_t)n[3]);
              if (!dv || !dt) return 2;
              if (n[4] && cudaMemcpy(dt, p[1], (size_t)n[3], cudaMemcpyHostToDevice) != cudaSuccess) return 3;
              const size_t pairs = (size_t)n[0] * (n[1] / 2);
              res_rope_k<<<(unsigned)((pairs + 255) / 256), 256>>>(dv, dt, (int)n[0], (int)n[1], (int)n[2]);
              return res_ok() ? 0 : 4; }
    case 8: { float* dd = (float*)res_dev(p[0], (size_t)n[0] * 4); const float* ds = (const float*)res_dev(p[1], (size_t)n[0] * 4);
              if (!dd || !ds) return 2;
              res_add_k<<<(unsigned)((n[0] + 255) / 256), 256>>>(dd, ds, (size_t)n[0]);
              return res_ok() ? 0 : 4; }
    case 9: { const int act = (int)n[0], dim = (int)n[1], nH = (int)n[2], hs = (int)n[3];
              const size_t cap = (size_t)n[4], ad = (size_t)act * dim, aa = (size_t)nH * act * act;
              if (act <= 0 || hs > 1024 || (long)nH * act > 65535 || nH * hs != dim) return 9;
              const float* dqf = (const float*)res_dev(p[0], ad * 4);
              const int8_t* k8 = (const int8_t*)res_dev(p[1], cap * dim); const float* ks = (const float*)res_dev(p[2], cap * 4);
              const int8_t* v8 = (const int8_t*)res_dev(p[3], cap * dim); const float* vs = (const float*)res_dev(p[4], cap * 4);
              float* dout = (float*)res_dev(p[5], ad * 4);
              if (!dqf || !k8 || !ks || !v8 || !vs || !dout || !att_need(0, ad) || !att_need(1, (size_t)act * 4) ||
                  !att_need(6, aa * 4)) return 2;
              res_qrows_k<<<(unsigned)((act + 3) / 4), 128>>>(dqf, (int8_t*)att_buf[0], (float*)att_buf[1], act, dim);
              const float sqrtHs = f[0];
              float* S = (float*)att_buf[6];
              const int fm = att_fast_get();
              if (fm && hs % 16 == 0 && dim % 16 == 0)
                  att_scores_fast<<<dim3((act + 255) / 256, nH * act), 256>>>((const int8_t*)att_buf[0], (const float*)att_buf[1],
                      k8, ks, S, act, dim, hs, sqrtHs);
              else
                  att_scores_kern<<<dim3((act + 255) / 256, nH * act), 256>>>((const int8_t*)att_buf[0], (const float*)att_buf[1],
                      k8, ks, S, act, dim, hs, sqrtHs);
              if (fm) att_softmax_fast<<<(nH * act + 3) / 4, 128>>>(S, act, nH * act, fm == 2);
              else    att_softmax_kern<<<(nH * act + 127) / 128, 128>>>(S, act, nH * act);
              if (fm) ATT_GLAUNCH(att_out_g, att_envi("SNAI_ATT_GO", 8), v8, vs, S, dout, act, dim, hs, 0);
              else att_out_kern<<<nH * act, hs>>>(v8, vs, S, dout, act, dim, hs, 0);
              att_t[2] += 1.0;
              return res_ok() ? 0 : 4; }
    case 10: { const size_t cap = (size_t)n[0];
               const int8_t* q8 = (const int8_t*)res_dev(p[0], cap * n[1]); const float* qs = (const float*)res_dev(p[1], cap * 4);
               float* dout = (float*)res_dev(p[2], (size_t)n[0] * n[1] * 4);
               if (!q8 || !qs || !dout) return 2;
               res_silu_k<<<(unsigned)n[0], 256>>>(q8, qs, dout, (int)n[0], (int)n[1]);
               return res_ok() ? 0 : 4; }
    case 11: { const int act = (int)n[0], V = (int)n[1];
               float* dl = (float*)res_dev(p[0], (size_t)act * V * 4);
               int* dt = (int*)res_dev(p[1], (size_t)n[2] * 4); int* dm = (int*)res_dev(p[2], (size_t)n[2] * 4);
               float* dp = (float*)res_dev(p[3], (size_t)n[2] * 4);
               if (!dl || !dt || !dm || !dp) return 2;
               if (cudaMemcpy(dt, p[1], (size_t)act * 4, cudaMemcpyHostToDevice) != cudaSuccess ||
                   cudaMemcpy(dm, p[2], (size_t)act * 4, cudaMemcpyHostToDevice) != cudaSuccess) return 3;
               res_softmax_k<<<(unsigned)((act + 3) / 4), 128>>>(dl, dt, dm, dp, act, V);
               if (!res_ok()) return 4;
               return cudaMemcpy(p[3], dp, (size_t)act * 4, cudaMemcpyDeviceToHost) == cudaSuccess ? 0 : 3; }
    case 12: { if (cudaDeviceSynchronize() != cudaSuccess) return 3; return res_ok() ? 0 : 4; }
    case 13: { double* o = (double*)p[0]; for (int i = 0; i < 4; i++) o[i] = res_t[i]; return 0; }
    case 14: { return res_dev(p[0], (size_t)n[1]) ? 0 : 2; }   // Platz mit voller Kapazitaet vorab anlegen
    }
    return 8;
}

} // extern "C" (RESIDENT)

// =====================================================================================================
// RESIDENT Stufe B (seit 2026-11-11, e625): Rueckwaertsweg auf der Karte. Jede
// Quantisierung folgt dem von Nim erzeugten C (gemischt float/double, an jeder Stelle anders), die GEMM-Kerne sind
// dieselben wie bisher (Kachelkerne, gleiche Modi), nur mit Geraetezeigern. Einstieg cuda_res2(op, p, n, f).
// =====================================================================================================
static __device__ __forceinline__ int8_t res_q8(float r) {   // (NI)(float) wie cvttss2si, dann klemmen
    long long qi = (r != r || !(fabsf(r) < 9.2233720368547758e18f)) ? (long long)0x8000000000000000ULL : (long long)r;
    if (qi > 127) qi = 127; else if (qi < -128) qi = -128;
    return (int8_t)qi;
}
// qpDinQ: je Position und 64er-Zeilenblock: max |scale[r]*d[r]|, sc = max/127.0 (double), bs = float(sc),
// q = quantRound(float(double(prod)/sc)) = roundf. Ein Warp je (Position, Block).
__global__ void res_dinq_k(const float* d, const float* ms, int8_t* dq, float* bs, int act, int rows, int nb) {
    const int w = blockIdx.x * 4 + (threadIdx.x >> 5), lane = threadIdx.x & 31;
    if (w >= act * nb) return;
    const int p = w / nb, b = w % nb, r0 = b * 64, r1 = min(r0 + 64, rows);
    const float* dp = d + (size_t)p * rows;
    float m = 0.0f;
    for (int r = r0 + lane; r < r1; r += 32) { const float a = fabsf(att_mul(ms[r], dp[r])); if (att_z(a) > att_z(m)) m = a; }
    for (int off = 16; off > 0; off >>= 1) { const float o = __shfl_down_sync(0xffffffffu, m, off); if (att_z(o) > att_z(m)) m = o; }
    m = __shfl_sync(0xffffffffu, m, 0);
    int8_t* qo = dq + (size_t)p * rows;
    if (!(att_z(m) > 0.0f)) {
        if (lane == 0) bs[(size_t)p * nb + b] = 0.0f;
        for (int r = r0 + lane; r < r1; r += 32) qo[r] = 0;
        return;
    }
    const double sc = __ddiv_rn((double)m, 127.0);
    if (lane == 0) bs[(size_t)p * nb + b] = att_z(__double2float_rn(sc));
    for (int r = r0 + lane; r < r1; r += 32) {
        const float x = att_z(__double2float_rn(__ddiv_rn((double)att_mul(ms[r], dp[r]), sc)));
        qo[r] = res_q8(roundf(x));
    }
}
// Spalten-/Zeilenmaximum ueber alle Positionen: out[j] = float(max/127.0) bzw. 0. ps: Positionsskala (QI8) oder nullptr.
__global__ void res_colmax_k(const float* x, const float* ps, float* out, int act, int n) {
    const int j = blockIdx.x * blockDim.x + threadIdx.x;
    if (j >= n) return;
    float m = 0.0f;
    for (int p = 0; p < act; ++p) {
        const float v = x[(size_t)p * n + j];
        const float a = fabsf(ps ? att_mul(v, ps[p]) : v);
        if (att_z(a) > att_z(m)) m = a;
    }
    out[j] = (att_z(m) > 0.0f) ? att_z(__double2float_rn(__ddiv_rn((double)m, 127.0))) : 0.0f;
}
// qpQiRow / qpQdRow: q = s <= 0 ? 0 : roundf(float(x[*ps]) / s), alles float. sAlongRow: Skala je Spalte (qi) bzw.
// je Zeile r (qd) - beides ist der innere Index j.
__global__ void res_qelem_k(const float* x, const float* ps, const float* sc, int8_t* q, int act, int n) {
    const size_t i = (size_t)blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= (size_t)act * n) return;
    const int p = (int)(i / n), j = (int)(i % n);
    const float s = sc[j];
    if (!(att_z(s) > 0.0f)) { q[i] = 0; return; }
    const float v = ps ? att_mul(x[i], ps[p]) : x[i];
    q[i] = res_q8(roundf(att_div(v, s)));
}
// applyRMSNormBackwardAcc je Position (siehe C-Code): ss float, inv double, sum_dy_nx float-Kette ueber float(double*double),
// mean float, Beitrag zu gw float(double(dout)*nx), neues dout float((double(dout*w) - nx*mean)*inv).
// Y = neu (add 0) bzw. Y + neu (add 1); C[p,d] = Beitrag zu gw (Spaltensumme danach seriell ueber p).
__global__ void res_rmsbw_k(const float* X, const float* A, const float* w, float* Y, float* C, int act, int dim,
                            int add, int rot) {
    const int row = blockIdx.x * 4 + (threadIdx.x >> 5), lane = threadIdx.x & 31;
    if (row >= act) return;
    const float* x = X + (size_t)row * dim; const float* a = A + (size_t)row * dim;
    float* y = Y + (size_t)row * dim; float* c = C + (size_t)row * dim;
    const float ss = res_chain<0>(a, dim);
    const double inv = __ddiv_rn(1.0, __dsqrt_rn(__dadd_rn((double)att_div(ss, (float)dim), 0.00001)));
    float s = 0.0f;
    for (int b = 0; b < dim; b += 32) {
        const int d = b + lane;
        float t = 0.0f;
        if (d < dim) t = att_z(__double2float_rn(__dmul_rn((double)att_mul(x[d], w[d]), __dmul_rn((double)att_z(a[d]), inv))));
        const int m = min(32, dim - b);
        for (int j = 0; j < m; ++j) s = att_add(s, __shfl_sync(0xffffffffu, t, j));
    }
    const float mean = att_div(s, (float)dim);
    __syncwarp();
    for (int d = lane; d < dim; d += 32) {
        const double nx = __dmul_rn((double)att_z(a[d]), inv);
        const float xd = x[d];
        c[d] = att_z(__double2float_rn(__dmul_rn((double)att_z(xd), nx)));
        const double v = __dmul_rn(__dsub_rn((double)att_mul(xd, w[d]), __dmul_rn(nx, (double)att_z(mean))), inv);
        const float nv = att_z(rot ? __double2float_rz(v) : __double2float_rn(v));
        y[d] = add ? att_add(y[d], nv) : nv;
    }
}
__global__ void res_colsum_k(float* gw, const float* C, int act, int dim) {
    const int d = blockIdx.x * blockDim.x + threadIdx.x;
    if (d >= dim) return;
    float g = gw[d];
    for (int p = 0; p < act; ++p) g = att_add(g, C[(size_t)p * dim + d]);
    gw[d] = g;
}
// SiLU rueckwaerts aus der int8-Historie: x = float(q)*s, sig = 1/(1+double(expf(-x))), g *= float(sig*(1+x*(1-sig))).
__global__ void res_silubw_k(float* g, const int8_t* q8, const float* qs, int act, int n) {
    const size_t i = (size_t)blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= (size_t)act * n) return;
    const float x = att_mul((float)q8[i], qs[i / n]);
    const double sig = __ddiv_rn(1.0, __dadd_rn(1.0, (double)att_expf(-x, 0)));
    const float f = att_z(__double2float_rn(__dmul_rn(sig, __dadd_rn(1.0, __dmul_rn((double)att_z(x), __dsub_rn(1.0, sig))))));
    g[i] = att_mul(g[i], f);
}
// Embedding-Gradient: g[tid*dim+d] += dh[p*dim+d]*fak, Positionen in Reihenfolge.
__global__ void res_embgrad_k(float* g, const float* dh, const int* tok, int act, int dim, int V, float fak) {
    const int d = blockIdx.x * blockDim.x + threadIdx.x;
    if (d >= dim) return;
    for (int p = 0; p < act; ++p) {
        int t = tok[p]; if (t < 0 || t >= V) t = 0;
        float* gp = g + (size_t)t * dim + d;
        *gp = att_add(*gp, att_mul(dh[(size_t)p * dim + d], fak));
    }
}

static int8_t* res_dq = nullptr; static size_t res_dq_cap = 0;
static float* res_bs = nullptr; static size_t res_bs_cap = 0;
static int8_t* res_qi = nullptr; static size_t res_qi_cap = 0;
static float* res_isc = nullptr; static size_t res_isc_cap = 0;
static float* res_dsc = nullptr; static size_t res_dsc_cap = 0;
static float* res_one = nullptr; static size_t res_one_cap = 0;
static float* res_C = nullptr; static size_t res_C_cap = 0;

// Gewichtsgradient: gm (Karte, Puffercache wie gmOnDevice=1) += Kern; GRAD-EARLY wie cuda_gradAccumI8.
static int res_gacc_launch(void* h_gm, const int8_t* qi, const int8_t* qd, const float* dsc, const float* isc,
                           int rows, int cols, int batch, int qiStride) {
    const size_t n_gm = (size_t)rows * cols * 4;
    float* d_gm = (float*)cuda_get_buffer(h_gm, n_gm);
    if (!d_gm) return 2;
    const int epm = ep_get_mode();
    EarlyPull* epe = epm ? ep_get(h_gm, (void*)d_gm, n_gm) : nullptr;
    if (epe && epm == 2) ep_issue(epe);
    const int bwm = cuda_bw_get_mode();
    if (bwm > 0) {
        dim3 grid((unsigned)((cols + BW_T - 1) / BW_T), (unsigned)((rows + BW_T - 1) / BW_T));
        gradAccumI8TiledKernel<<<grid, 256>>>((const signed char*)qi, (const signed char*)qd, dsc, isc, d_gm,
                                              rows, cols, batch, qiStride, bwm == 2 ? 1 : 0);
    } else {
        const size_t total = (size_t)rows * cols;
        gradAccumI8Kernel<<<(int)((total + 255) / 256), 256>>>((const signed char*)qi, (const signed char*)qd, dsc, isc,
                                                               d_gm, rows, cols, batch, qiStride);
    }
    cuda_gradacc_calls++;
    if (epe && epm == 1) ep_issue(epe);
    return res_ok() ? 0 : 4;
}

extern "C" {

// op: 20 Eingangsgradient (p0 W, p1 Wscale, p2 d_out, p3 d_in; n0 rows, n1 cols, n2 batch, n3 accumulate)
//     21 Gewichtsgradient int (p0 gm, p1 d_out, p2 i_all; n0 rows, n1 cols, n2 batch)
//     22 Gewichtsgradient QI8 (p0 gm, p1 d_out, p2 qi8, p3 qi-Skalen; n0 rows, n1 cols, n2 batch, n3 Kap. Zeilen)
//     23 RMSNorm rueckwaerts (p0 X, p1 A, p2 w Host, p3 Y, p4 gw; n0 act, n1 dim, n2 add, n3 rot)
//     24 SiLU rueckwaerts (p0 g, p1 q8, p2 qs; n0 act, n1 ffn, n2 Kap.) | 25 Nullen (p0, n0 Bytes, n1 Kap.)
//     26 Attention rueckwaerts (p0 act_q, p1 k8, p2 ks, p3 v8, p4 vs, p5 datt, p6 dq, p7 dk, p8 dv;
//        n0 act, n1 dim, n2 nH, n3 hs, n4 Kap., n5 attScale als double-Bits; f0 sqrt(hs))
//     27 Embedding-Gradient (p0 g Host: hoch, Kern, runter; p1 d_hidden; p2 Token Host; n0 act, n1 dim, n2 V, n3 Kap.; f0 fak)
int cuda_res2(int op, void* const* p, const long long* n, const float* f) {
    if (!cuda_initialized) return 1;
    res_t[0] += 1.0;
    switch (op) {
    case 20: { const int rows = (int)n[0], cols = (int)n[1], batch = (int)n[2], acc = (int)n[3];
               const int nb = (rows + 63) / 64;
               const signed char* dW = (const signed char*)cuda_get_buffer(p[0], (size_t)rows * cols);
               const float* dMs = (const float*)cuda_get_buffer(p[1], (size_t)rows * 4);
               const float* dO = (const float*)res_dev(p[2], (size_t)batch * rows * 4);
               float* dI = (float*)res_dev(p[3], (size_t)batch * cols * 4);
               if (!dW || !dMs || !dO || !dI || !res_grow((void**)&res_dq, &res_dq_cap, (size_t)batch * rows) ||
                   !res_grow((void**)&res_bs, &res_bs_cap, (size_t)batch * nb * 4)) return 2;
               res_dinq_k<<<(unsigned)((batch * nb + 3) / 4), 128>>>(dO, dMs, res_dq, res_bs, batch, rows, nb);
               const int bwm = cuda_bw_get_mode();
               if (bwm > 0) {
                   dim3 grid((unsigned)((cols + BW_T - 1) / BW_T), (unsigned)((batch + BW_T - 1) / BW_T));
                   backwardDInI8BatchedTiledKernel<<<grid, 256>>>(dW, (const signed char*)res_dq, res_bs, dI, rows, cols, batch,
                                                                 acc, bwm == 2 ? 1 : 0);
               } else {
                   const size_t total = (size_t)batch * cols;
                   backwardDInI8BatchedKernel<<<(int)((total + 255) / 256), 256>>>(dW, (const signed char*)res_dq, res_bs, dI,
                                                                                rows, cols, batch, 64, acc);
               }
               cuda_bw_din_calls++;
               return res_ok() ? 0 : 4; }
    case 21: { const int rows = (int)n[0], cols = (int)n[1], batch = (int)n[2];
               const float* dO = (const float*)res_dev(p[1], (size_t)batch * rows * 4);
               const float* dX = (const float*)res_dev(p[2], (size_t)batch * cols * 4);
               if (!dO || !dX || !res_grow((void**)&res_qi, &res_qi_cap, (size_t)batch * cols) ||
                   !res_grow((void**)&res_dq, &res_dq_cap, (size_t)batch * rows) ||
                   !res_grow((void**)&res_isc, &res_isc_cap, (size_t)cols * 4) ||
                   !res_grow((void**)&res_dsc, &res_dsc_cap, (size_t)rows * 4)) return 2;
               res_colmax_k<<<(cols + 255) / 256, 256>>>(dX, nullptr, res_isc, batch, cols);
               res_qelem_k<<<(unsigned)(((size_t)batch * cols + 255) / 256), 256>>>(dX, nullptr, res_isc, res_qi, batch, cols);
               res_colmax_k<<<(rows + 255) / 256, 256>>>(dO, nullptr, res_dsc, batch, rows);
               res_qelem_k<<<(unsigned)(((size_t)batch * rows + 255) / 256), 256>>>(dO, nullptr, res_dsc, res_dq, batch, rows);
               return res_gacc_launch(p[0], res_qi, res_dq, res_dsc, res_isc, rows, cols, batch, cols); }
    case 22: { const int rows = (int)n[0], cols = (int)n[1], batch = (int)n[2]; const size_t cap = (size_t)n[3];
               const float* dO = (const float*)res_dev(p[1], (size_t)batch * rows * 4);
               const int8_t* q8 = (const int8_t*)res_dev(p[2], cap * cols); const float* qs = (const float*)res_dev(p[3], cap * 4);
               if (!dO || !q8 || !qs || !res_grow((void**)&res_dq, &res_dq_cap, (size_t)batch * rows) ||
                   !res_grow((void**)&res_dsc, &res_dsc_cap, (size_t)rows * 4)) return 2;
               if (res_one_cap < (size_t)cols * 4) {
                   if (!res_grow((void**)&res_one, &res_one_cap, (size_t)cols * 4)) return 2;
                   float* h = (float*)malloc((size_t)cols * 4); for (int c = 0; c < cols; c++) h[c] = 1.0f;
                   cudaMemcpy(res_one, h, (size_t)cols * 4, cudaMemcpyHostToDevice); free(h);
               }
               res_colmax_k<<<(rows + 255) / 256, 256>>>(dO, qs, res_dsc, batch, rows);
               res_qelem_k<<<(unsigned)(((size_t)batch * rows + 255) / 256), 256>>>(dO, qs, res_dsc, res_dq, batch, rows);
               return res_gacc_launch(p[0], q8, res_dq, res_dsc, res_one, rows, cols, batch, cols); }
    case 23: { const int act = (int)n[0], dim = (int)n[1]; const size_t ad = (size_t)act * dim;
               const float* dX = (const float*)res_dev(p[0], ad * 4); const float* dA = (const float*)res_dev(p[1], ad * 4);
               float* dw = (float*)res_dev(p[2], (size_t)dim * 4); float* dY = (float*)res_dev(p[3], ad * 4);
               float* dg = (float*)res_dev(p[4], (size_t)dim * 4);
               if (!dX || !dA || !dw || !dY || !dg || !res_grow((void**)&res_C, &res_C_cap, ad * 4)) return 2;
               if (cudaMemcpy(dw, p[2], (size_t)dim * 4, cudaMemcpyHostToDevice) != cudaSuccess) return 3;
               res_rmsbw_k<<<(unsigned)((act + 3) / 4), 128>>>(dX, dA, dw, dY, res_C, act, dim, (int)n[2], (int)n[3]);
               res_colsum_k<<<(dim + 255) / 256, 256>>>(dg, res_C, act, dim);
               return res_ok() ? 0 : 4; }
    case 24: { const size_t cap = (size_t)n[2], an = (size_t)n[0] * n[1];
               float* g = (float*)res_dev(p[0], an * 4);
               const int8_t* q8 = (const int8_t*)res_dev(p[1], cap * n[1]); const float* qs = (const float*)res_dev(p[2], cap * 4);
               if (!g || !q8 || !qs) return 2;
               res_silubw_k<<<(unsigned)((an + 255) / 256), 256>>>(g, q8, qs, (int)n[0], (int)n[1]);
               return res_ok() ? 0 : 4; }
    case 25: { void* d = res_dev(p[0], (size_t)n[1]); if (!d) return 2;
               return cudaMemset(d, 0, (size_t)n[0]) == cudaSuccess ? 0 : 3; }
    case 26: { const int act = (int)n[0], dim = (int)n[1], nH = (int)n[2], hs = (int)n[3];
               const size_t cap = (size_t)n[4], ad = (size_t)act * dim, aa = (size_t)nH * act * act;
               double attScale; memcpy(&attScale, &n[5], 8);
               if (act <= 0 || hs > 1024 || (long)nH * act > 65535 || nH * hs != dim) return 9;
               const float* dqf = (const float*)res_dev(p[0], ad * 4);
               const int8_t* k8 = (const int8_t*)res_dev(p[1], cap * dim); const float* ks = (const float*)res_dev(p[2], cap * 4);
               const int8_t* v8 = (const int8_t*)res_dev(p[3], cap * dim); const float* vs = (const float*)res_dev(p[4], cap * 4);
               const float* datt = (const float*)res_dev(p[5], ad * 4);
               float* dq = (float*)res_dev(p[6], ad * 4); float* dk = (float*)res_dev(p[7], ad * 4); float* dv = (float*)res_dev(p[8], ad * 4);
               if (!dqf || !k8 || !ks || !v8 || !vs || !datt || !dq || !dk || !dv || !att_need(0, ad) ||
                   !att_need(1, (size_t)act * 4) || !att_need(6, aa * 4) || !att_need(8, aa * 4)) return 2;
               res_qrows_k<<<(unsigned)((act + 3) / 4), 128>>>(dqf, (int8_t*)att_buf[0], (float*)att_buf[1], act, dim);
               const int8_t* q8 = (const int8_t*)att_buf[0]; const float* qs = (const float*)att_buf[1];
               const float sqrtHs = f[0];
               float* W = (float*)att_buf[6]; float* DS = (float*)att_buf[8];
               const int fm = att_fast_get();
               const bool vec = fm && hs % 16 == 0 && dim % 16 == 0;
               if (vec) att_scores_fast<<<dim3((act + 255) / 256, nH * act), 256>>>(q8, qs, k8, ks, W, act, dim, hs, sqrtHs);
               else     att_scores_kern<<<dim3((act + 255) / 256, nH * act), 256>>>(q8, qs, k8, ks, W, act, dim, hs, sqrtHs);
               if (fm) att_softmax_fast<<<(nH * act + 3) / 4, 128>>>(W, act, nH * act, fm == 2);
               else    att_softmax_kern<<<(nH * act + 127) / 128, 128>>>(W, act, nH * act);
               if (vec) att_dw_fast<<<dim3((act + 255) / 256, nH * act), 256>>>(datt, v8, vs, DS, act, dim, hs);
               else     att_dw_kern<<<dim3((act + 255) / 256, nH * act), 256>>>(datt, v8, vs, DS, act, dim, hs);
               if (fm) att_ds_fast<<<(nH * act + 3) / 4, 128>>>(W, DS, act, nH * act);
               else    att_ds_kern<<<(nH * act + 127) / 128, 128>>>(W, DS, act, nH * act);
               float scf = 0.0f;
               const int fdq = (fm && att_scale_pow2(attScale, &scf)) ? 1 : 0;
               if (fm) {
                   ATT_GLAUNCH(att_dq_g, att_envi("SNAI_ATT_GQ", 4), DS, k8, ks, dq, act, dim, hs, attScale, fdq, scf);
                   const int rk = att_envi("SNAI_ATT_RK", 0);
                   const int rr = (rk == 1 || rk == 2 || rk == 4) && hs * rk <= 1024 ? rk : 0;
                   if (rr == 0) att_dkv_g<1><<<nH * act, hs>>>(DS, W, datt, q8, qs, dk, dv, act, dim, hs, attScale, fdq, scf);
                   else if (rr == 4) att_dkv_r<4><<<nH * ((act + 3) / 4), hs * 4>>>(DS, W, datt, q8, qs, dk, dv, act, dim, hs, attScale, fdq, scf);
                   else if (rr == 2) att_dkv_r<2><<<nH * ((act + 1) / 2), hs * 2>>>(DS, W, datt, q8, qs, dk, dv, act, dim, hs, attScale, fdq, scf);
                   else att_dkv_r<1><<<nH * act, hs>>>(DS, W, datt, q8, qs, dk, dv, act, dim, hs, attScale, fdq, scf);
               } else {
                   att_dq_kern<<<nH * act, hs>>>(DS, k8, ks, dq, act, dim, hs, attScale, 0);
                   att_dkv_kern<<<nH * act, hs>>>(DS, W, datt, q8, qs, dk, dv, act, dim, hs, attScale, 0);
               }
               att_t[3] += 1.0;
               return res_ok() ? 0 : 4; }
    case 27: { const int act = (int)n[0], dim = (int)n[1], V = (int)n[2]; const size_t gb = (size_t)V * dim * 4;
               float* g = (float*)res_dev(p[0], gb); const float* dh = (const float*)res_dev(p[1], (size_t)act * dim * 4);
               int* tok = (int*)res_dev(p[2], (size_t)n[3] * 4);
               if (!g || !dh || !tok) return 2;
               if (cudaMemcpy(g, p[0], gb, cudaMemcpyHostToDevice) != cudaSuccess ||
                   cudaMemcpy(tok, p[2], (size_t)act * 4, cudaMemcpyHostToDevice) != cudaSuccess) return 3;
               res_embgrad_k<<<(dim + 255) / 256, 256>>>(g, dh, tok, act, dim, V, f[0]);
               if (!res_ok()) return 4;
               return cudaMemcpy(p[0], g, gb, cudaMemcpyDeviceToHost) == cudaSuccess ? 0 : 3; }
    }
    return 8;
}

} // extern "C" (RESIDENT Stufe B)
