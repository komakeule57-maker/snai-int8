# Dateiname: cortex_opencl.nim
# Funktion: OpenCL Compute Engine (Bare-Metal JIT) - PHASE VIII.4 (Memory Audit Fixes)
# ==============================================================================
# SYMBIO NANO-AI FRAMEWORK (Code-4372)
# -> VRAM Leaks geschlossen (ocl_release_buffer).
# -> Sparse Adam GPU Angleichung (fabs).
# -> Tote PCIe-Transfers eliminiert (E > H).
# ==============================================================================

{.passL: "-lOpenCL".}

{.emit: """
#define CL_TARGET_OPENCL_VERSION 120 
#include <CL/cl.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdatomic.h>
#include <math.h>
#include <string.h>
static void ocl_adam_q_build(cl_device_id dev);   // OCL-ADAM, unten

cl_context ocl_ctx = NULL;
cl_command_queue ocl_queue = NULL;
cl_kernel ocl_kernel_matvec = NULL;
cl_kernel ocl_kernel_adam = NULL; 
cl_kernel ocl_kernel_att_fwd = NULL;
cl_kernel ocl_kernel_att_bwd = NULL;
cl_kernel ocl_kernel_matvec_t = NULL;   // V8.5: Backward d_in = M^T * d_out
cl_kernel ocl_kernel_grad_acc = NULL;   // V8.5: Backward gm += d_out (x) i_v
cl_kernel ocl_kernel_gemm_f = NULL;     // V8.6: Batched Forward
cl_kernel ocl_kernel_gemm_t = NULL;     // V8.6: Batched Backward d_in
cl_kernel ocl_kernel_gemm_g = NULL;     // V8.6: Batched Gradienten-Akkumulation
cl_kernel ocl_kernel_att_fwd_b = NULL;  // AUDIT: Attention Forward, ueber alle Positionen gebuendelt
cl_kernel ocl_kernel_att_bwd_q = NULL;  // AUDIT: Attention Backward Stufe A (query-parallel: d_q, weights, ds)
cl_kernel ocl_kernel_att_bwd_k = NULL;  // AUDIT: Attention Backward Stufe B (key-parallel: d_k_cache, d_v_cache)

// ==============================================================================
// PHASE 3 DES INT8-UMBAUS
// Additive INT8-Kernel neben den bestehenden FP32-Kerneln oben - kein
// bestehender Kernel/Host-Wrapper wird veraendert. Spiegeln die CPU-Referenz
// aus cortex.nim (matVecMulI8/adamStepI8, Design-Entscheidungen #1/#3/#4).
// ==============================================================================
cl_kernel ocl_kernel_matvec_i8 = NULL;  // PHASE 3: INT8-GEMM (int8xint8->int32, Per-Zeile-Skala)
cl_kernel ocl_kernel_adam_i8 = NULL;     // PHASE 3: Rounded-Integer-Step Adam auf INT8-Gewichten
cl_kernel ocl_kernel_adam_row_i8 = NULL; // PHASE 10: Float-Adam je Zeile + Fehler-Rueckfuehrung
cl_kernel ocl_kernel_matvec_t_i8 = NULL; // PHASE 7: INT8-Backward (d_in = dequant(M)^T . d_out)
cl_kernel ocl_kernel_gemm_f_i8 = NULL;   // PHASE 8: gebuendeltes INT8-Forward-GEMM
cl_kernel ocl_kernel_gemm_t_i8 = NULL;   // PHASE 8: gebuendeltes INT8-Backward-GEMM
cl_kernel ocl_kernel_bw_din_i8 = NULL;
cl_kernel ocl_kernel_gradacc_i8 = NULL;
cl_kernel ocl_kernel_bw_din_i8_b = NULL;   // FULL-INT8 Schritt 1: Ganzzahl-Backward
cl_kernel ocl_kernel_bw_tiled = NULL;      // OCL-BW-KACHEL (2026-11-11)
cl_kernel ocl_kernel_ga_tiled = NULL;      // OCL-BW-KACHEL (2026-11-11)
static int ocl_bw_mode = -1;               // 0 alt, 1 Kachel, 2 Kachel + ROT
static int ocl_bw_get_mode(void) {
    if (ocl_bw_mode < 0) {
        const char* e = getenv("SNAI_OCL_BW");
        if (e && strcmp(e, "0") == 0) ocl_bw_mode = 0;
        else if (e && strcmp(e, "ROT") == 0) ocl_bw_mode = 2;
        else if (!e || !*e || strcmp(e, "1") == 0) ocl_bw_mode = 1;   // Vorgabe Kachel
        else ocl_bw_mode = 0;
        if (ocl_bw_mode > 0 && (!ocl_kernel_bw_tiled || !ocl_kernel_ga_tiled)) {
            fprintf(stderr, "[OCL-BW] Kachelkerne nicht verfuegbar (Arbeitsgruppe < 256) - alte Kerne\n");
            ocl_bw_mode = 0;
        }
        fprintf(stderr, "[OCL-BW] Rueckwaertskerne: %s\n",
                ocl_bw_mode == 0 ? "alt" : ocl_bw_mode == 2 ? "Kachel ROT-PROBE" : "Kachel");
    }
    return ocl_bw_mode;
}


// ==== OCL-ZC (2026-11-13): Puffer ohne Treiberkopie auf Geraeten mit gemeinsamem Speicher ===========================
// Statt Schreiben/Lesen ueber eine Treiberkopie legt die Engine Puffer im fuer CPU und GPU gemeinsamen Speicher an
// (CL_MEM_ALLOC_HOST_PTR) und kopiert per Map + memcpy. Reine Kopie, aendert keinen Wert.
// SNAI_OCL_ZC: fehlt/1 = an, wenn das Geraet gemeinsamen Speicher meldet; 0 = aus; 2 = immer an (Pruefung).
static int ocl_zc = 0;
static cl_mem ocl_mk(cl_context c, cl_mem_flags f, size_t sz, void* hp, cl_int* e) {
    if (ocl_zc && !hp && !(f & (CL_MEM_USE_HOST_PTR | CL_MEM_ALLOC_HOST_PTR))) f |= CL_MEM_ALLOC_HOST_PTR;
    return clCreateBuffer(c, f, sz, hp, e);
}
static cl_int ocl_wr(cl_command_queue q, cl_mem b, cl_bool blk, size_t off, size_t sz, const void* p,
                     cl_uint n, const cl_event* wl, cl_event* ev) {
    if (ocl_zc && sz > 0) {
        cl_int e = CL_SUCCESS;
        void* m = clEnqueueMapBuffer(q, b, CL_TRUE, CL_MAP_WRITE_INVALIDATE_REGION, off, sz, n, wl, NULL, &e);
        if (e == CL_SUCCESS && m) { memcpy(m, p, sz); return clEnqueueUnmapMemObject(q, b, m, 0, NULL, ev); }
    }
    return clEnqueueWriteBuffer(q, b, blk, off, sz, p, n, wl, ev);
}
static cl_int ocl_rd(cl_command_queue q, cl_mem b, cl_bool blk, size_t off, size_t sz, void* p,
                     cl_uint n, const cl_event* wl, cl_event* ev) {
    if (ocl_zc && sz > 0) {
        cl_int e = CL_SUCCESS;
        void* m = clEnqueueMapBuffer(q, b, CL_TRUE, CL_MAP_READ, off, sz, n, wl, NULL, &e);
        if (e == CL_SUCCESS && m) { memcpy(p, m, sz); cl_int r = clEnqueueUnmapMemObject(q, b, m, 0, NULL, ev); clFinish(q); return r; }
    }
    return clEnqueueReadBuffer(q, b, blk, off, sz, p, n, wl, ev);
}

// ==== OCL-FWD + OCL-IDOT (2026-11-13): Vorwaerts-int8-GEMM als Kachelkern ========================================
// OUT[p*rows+r] = (float)(sum_c M[r,c]*IN[p,c]) * Mscale[r] * inScale[p] wie matMulBatchedI8, Summe ganzzahlig,
// also bitgleich unabhaengig von der Reihenfolge. Kachel 64 (r) x 64 (p), 256 Work-Items je 4x4, Spalten in
// Viererpaketen (int = 4 x int8) im lokalen Speicher. Mit USE_IDOT rechnet dot_4x8packed_ss_int das Viererpaket.
static const char* fwd_tiled_source =
"#pragma OPENCL FP_CONTRACT OFF\n"
"#ifndef USE_IDOT\n"
"#define USE_IDOT 0\n"
"#endif\n"
"#if USE_IDOT\n"
"#pragma OPENCL EXTENSION cl_khr_integer_dot_product : enable\n"
"#define DOT4(a, b) dot_4x8packed_ss_int((uint)(a), (uint)(b))\n"
"#else\n"
"inline int DOT4(int a, int b) {\n"
"    char4 x = as_char4(a), y = as_char4(b);\n"
"    return (int)x.s0 * (int)y.s0 + (int)x.s1 * (int)y.s1 + (int)x.s2 * (int)y.s2 + (int)x.s3 * (int)y.s3;\n"
"}\n"
"#endif\n"
"inline int ld4(__global const char* p, int k, int lim) {\n"
"    if (k + 3 < lim) return as_int(vload4(0, p + k));\n"
"    char4 v = (char4)(0);\n"
"    if (k < lim) v.s0 = p[k];\n"
"    if (k + 1 < lim) v.s1 = p[k + 1];\n"
"    if (k + 2 < lim) v.s2 = p[k + 2];\n"
"    return as_int(v);\n"
"}\n"
"__kernel void matMulBatchedI8Tiled(__global const char* M, __global const float* Mscale,\n"
"                                   __global const char* IN, __global const float* inScale,\n"
"                                   __global float* OUT, int rows, int cols, int batch, int rot) {\n"
"    __local int sM[64][17];\n"
"    __local int sI[64][17];\n"
"    const int lid = get_local_id(0);\n"
"    const int tx = lid & 15, ty = lid >> 4;\n"
"    const int r0 = get_group_id(0) * 64, p0 = get_group_id(1) * 64;\n"
"    int acc[4][4];\n"
"    for (int i = 0; i < 4; ++i) for (int j = 0; j < 4; ++j) acc[i][j] = 0;\n"
"    for (int k0 = 0; k0 < cols; k0 += 64) {\n"
"        for (int e = lid; e < 1024; e += 256) {\n"
"            const int rr = e >> 4, w = e & 15, k = k0 + 4 * w;\n"
"            const int gr = r0 + rr, gp = p0 + rr;\n"
"            sM[rr][w] = (gr < rows) ? ld4(M + (size_t)gr * (size_t)cols, k, cols) : 0;\n"
"            sI[rr][w] = (gp < batch) ? ld4(IN + (size_t)gp * (size_t)cols, k, cols) : 0;\n"
"        }\n"
"        barrier(CLK_LOCAL_MEM_FENCE);\n"
"        for (int w = 0; w < 16; ++w) {\n"
"            int a[4], b[4];\n"
"            for (int i = 0; i < 4; ++i) a[i] = sI[ty + 16 * i][w];\n"
"            for (int j = 0; j < 4; ++j) b[j] = sM[tx + 16 * j][w];\n"
"            for (int i = 0; i < 4; ++i) for (int j = 0; j < 4; ++j) acc[i][j] += DOT4(a[i], b[j]);\n"
"        }\n"
"        barrier(CLK_LOCAL_MEM_FENCE);\n"
"    }\n"
"    for (int i = 0; i < 4; ++i) {\n"
"        const int p = p0 + ty + 16 * i;\n"
"        if (p >= batch) continue;\n"
"        for (int j = 0; j < 4; ++j) {\n"
"            const int r = r0 + tx + 16 * j;\n"
"            if (r >= rows) continue;\n"
"            int ia = acc[i][j];\n"
"            if (rot && r == rows - 1 && p == batch - 1) ia += 1;\n"
"            OUT[(size_t)p * (size_t)rows + (size_t)r] = (float)ia * Mscale[r] * inScale[p];\n"
"        }\n"
"    }\n"
"}\n";
static cl_kernel ocl_kernel_fwd_tiled = NULL;
static int ocl_fwd_idot = 0;
static int ocl_fwd_mode = -1;               // 0 alt, 1 Kachel, 2 Kachel + ROT
static int ocl_fwd_get_mode(void) {
    if (ocl_fwd_mode < 0) {
        const char* e = getenv("SNAI_OCL_FWD");
        if (e && strcmp(e, "0") == 0) ocl_fwd_mode = 0;
        else if (e && strcmp(e, "ROT") == 0) ocl_fwd_mode = 2;
        else if (!e || !*e || strcmp(e, "1") == 0) ocl_fwd_mode = 1;   // Vorgabe Kachel
        else ocl_fwd_mode = 0;
        if (ocl_fwd_mode > 0 && !ocl_kernel_fwd_tiled) {
            fprintf(stderr, "[OCL-FWD] Kachelkern nicht verfuegbar - alter Kern\n");
            ocl_fwd_mode = 0;
        }
        fprintf(stderr, "[OCL-FWD] Vorwaertskern: %s%s\n",
                ocl_fwd_mode == 0 ? "alt" : ocl_fwd_mode == 2 ? "Kachel ROT-PROBE" : "Kachel",
                ocl_fwd_mode == 0 ? "" : ocl_fwd_idot ? " (int8-Punktprodukt: cl_khr_integer_dot_product)" : " (int8-Punktprodukt: Nachbau)");
    }
    return ocl_fwd_mode;
}
static cl_program ocl_fwd_try(cl_device_id dev, const char* opt) {
    cl_int err;
    cl_program p = clCreateProgramWithSource(ocl_ctx, 1, (const char**)&fwd_tiled_source, NULL, &err);
    if (err != CL_SUCCESS || !p) return NULL;
    if (clBuildProgram(p, 1, &dev, opt, NULL, NULL) != CL_SUCCESS) {
        size_t ls = 0; clGetProgramBuildInfo(p, dev, CL_PROGRAM_BUILD_LOG, 0, NULL, &ls);
        char* lg = (char*)malloc(ls + 1); clGetProgramBuildInfo(p, dev, CL_PROGRAM_BUILD_LOG, ls, lg, NULL); lg[ls] = 0;
        fprintf(stderr, "[OCL-FWD] Bau mit [%s] fehlgeschlagen:\n%s\n", opt ? opt : "", lg); free(lg); clReleaseProgram(p);
        return NULL;
    }
    return p;
}
static void ocl_fwd_build(cl_device_id dev) {
    char ext[8192]; ext[0] = 0;
    clGetDeviceInfo(dev, CL_DEVICE_EXTENSIONS, sizeof(ext) - 1, ext, NULL); ext[sizeof(ext) - 1] = 0;
    const char* ie = getenv("SNAI_OCL_IDOT");
    const int want = !(ie && strcmp(ie, "0") == 0) && strstr(ext, "cl_khr_integer_dot_product") != NULL;
    cl_program p = NULL;
    if (want) { p = ocl_fwd_try(dev, "-cl-std=CL3.0 -DUSE_IDOT=1"); ocl_fwd_idot = p != NULL; }
    if (!p) p = ocl_fwd_try(dev, NULL);
    if (!p) return;
    cl_int err; size_t kwg = 0;
    ocl_kernel_fwd_tiled = clCreateKernel(p, "matMulBatchedI8Tiled", &err);
    if (err != CL_SUCCESS || clGetKernelWorkGroupInfo(ocl_kernel_fwd_tiled, dev, CL_KERNEL_WORK_GROUP_SIZE, sizeof(size_t),
                                                      &kwg, NULL) != CL_SUCCESS || kwg < 256) {
        fprintf(stderr, "[OCL-FWD] Kachelkern nicht nutzbar (Fehler %d, Arbeitsgruppe %zu < 256)\n", err, kwg);
        ocl_kernel_fwd_tiled = NULL;
    }
    clReleaseProgram(p);
}


// ==== OCL-PROF (2026-11-13): Kernzeiten je Kern (Diagnose), SNAI_OCL_PROF=1 ======================================
// Jeder Kernaufruf wartet dann auf sein Ereignis (serialisiert die Warteschlange, Zeit selbst misst das Geraet).
// Ausgabe kumulativ alle 20 s: Kernname, Aufrufe, Summe ms. Aendert keinen Wert.
#include <time.h>
static int ocl_prof = -1;
static int ocl_prof_get(void) {
    if (ocl_prof < 0) { const char* e = getenv("SNAI_OCL_PROF"); ocl_prof = (e && strcmp(e, "1") == 0) ? 1 : 0;
                        if (ocl_prof) fprintf(stderr, "[OCL-PROF] Kernzeiten an (Warteschlange mit Profiling)\n"); }
    return ocl_prof;
}
#define OCL_PROF_N 96
static char   ocl_prof_nm[OCL_PROF_N][64];
static double ocl_prof_ms[OCL_PROF_N];
static long   ocl_prof_nc[OCL_PROF_N];
static int    ocl_prof_used = 0;
static double ocl_prof_last = 0.0;
static void ocl_prof_print(void) {
    double tot = 0.0; for (int i = 0; i < ocl_prof_used; i++) tot += ocl_prof_ms[i];
    fprintf(stderr, "[OCL-PROF] Tabelle (kumulativ): gesamt %.1f ms\n", tot);
    int done[OCL_PROF_N] = {0};
    for (int r = 0; r < ocl_prof_used; r++) {
        int b = -1; for (int i = 0; i < ocl_prof_used; i++) if (!done[i] && (b < 0 || ocl_prof_ms[i] > ocl_prof_ms[b])) b = i;
        done[b] = 1;
        fprintf(stderr, "[OCL-PROF]   %-28s %9ld Aufrufe %11.1f ms\n", ocl_prof_nm[b], ocl_prof_nc[b], ocl_prof_ms[b]);
    }
}
static cl_int ocl_nd(cl_command_queue q, cl_kernel k, cl_uint dim, const size_t* off, const size_t* g, const size_t* l,
                     cl_uint n, const cl_event* wl, cl_event* ev) {
    if (!ocl_prof_get()) return clEnqueueNDRangeKernel(q, k, dim, off, g, l, n, wl, ev);
    cl_event e = NULL;
    cl_int r = clEnqueueNDRangeKernel(q, k, dim, off, g, l, n, wl, &e);
    if (r != CL_SUCCESS || !e) return r;
    clWaitForEvents(1, &e);
    cl_ulong t0 = 0, t1 = 0;
    clGetEventProfilingInfo(e, CL_PROFILING_COMMAND_START, sizeof(t0), &t0, NULL);
    clGetEventProfilingInfo(e, CL_PROFILING_COMMAND_END, sizeof(t1), &t1, NULL);
    char nm[64]; nm[0] = 0; clGetKernelInfo(k, CL_KERNEL_FUNCTION_NAME, sizeof(nm), nm, NULL); nm[63] = 0;
    int i = 0; while (i < ocl_prof_used && strcmp(ocl_prof_nm[i], nm) != 0) i++;
    if (i == ocl_prof_used && ocl_prof_used < OCL_PROF_N) { strcpy(ocl_prof_nm[i], nm); ocl_prof_ms[i] = 0; ocl_prof_nc[i] = 0; ocl_prof_used++; }
    if (i < OCL_PROF_N) { ocl_prof_ms[i] += (double)(t1 - t0) * 1e-6; ocl_prof_nc[i]++; }
    struct timespec ts; clock_gettime(CLOCK_MONOTONIC, &ts);
    double now = ts.tv_sec + ts.tv_nsec * 1e-9;
    if (ocl_prof_last == 0.0) ocl_prof_last = now;
    if (now - ocl_prof_last >= 20.0) { ocl_prof_last = now; ocl_prof_print(); }
    if (ev) *ev = e; else clReleaseEvent(e);
    return r;
}

size_t ocl_max_work_group_size = 64; 
_Atomic int ocl_initialized = 0;     

#define MAX_OCL_BUFFERS 2048

// AUDIT-FIX: max. Positionen pro Attention-Kernel-Dispatch (siehe Einsatzstellen
// in ocl_attentionForwardBatched/ocl_attentionBackwardBatched weiter unten).
#define ATT_POS_CHUNK 256

typedef struct { 
    void* h_ptr; 
    cl_mem d_buf; 
    size_t bytes; 
} OclBufMap;

OclBufMap ocl_buf_map[MAX_OCL_BUFFERS];
int ocl_buf_count = 0;

cl_mem ocl_eph_v = NULL; size_t ocl_eph_v_size = 0;
cl_mem ocl_eph_out = NULL; size_t ocl_eph_out_size = 0;
cl_mem ocl_eph_dq = NULL; size_t ocl_eph_dq_size = 0;
cl_mem ocl_eph_scores = NULL; size_t ocl_eph_scores_size = 0;
cl_mem ocl_eph_dw = NULL; size_t ocl_eph_dw_size = 0;
cl_mem ocl_eph_bt_a = NULL; size_t ocl_eph_bt_a_size = 0;   // V8.5: d_out
cl_mem ocl_eph_bt_b = NULL; size_t ocl_eph_bt_b_size = 0;   // V8.5: d_in / i_v
cl_mem ocl_eph_bm_r = NULL; size_t ocl_eph_bm_r_size = 0;   // V8.6: batch x rows
// FULL-INT8 Schritt 1: eigener kleiner Puffer fuer die Block-Gradientenskalen
// (ceil(rows/64) floats). Bewusst getrennt statt in einen bestehenden Puffer
// hineingerechnet - ein gemeinsamer Puffer haette einen Offset-Parameter im
// Kernel gebraucht und die Wiederverwendung an eine Groessenannahme gekoppelt.
cl_mem ocl_eph_bs = NULL; size_t ocl_eph_bs_size = 0;
cl_mem ocl_eph_ga_qi = NULL; size_t ocl_eph_ga_qi_size = 0;
cl_mem ocl_eph_ga_qd = NULL; size_t ocl_eph_ga_qd_size = 0;
cl_mem ocl_eph_ga_ds = NULL; size_t ocl_eph_ga_ds_size = 0;
cl_mem ocl_eph_ga_is = NULL; size_t ocl_eph_ga_is_size = 0;
cl_mem ocl_eph_ga_gm = NULL; size_t ocl_eph_ga_gm_size = 0;
cl_mem ocl_eph_bb_dq = NULL; size_t ocl_eph_bb_dq_size = 0;
cl_mem ocl_eph_bb_bs = NULL; size_t ocl_eph_bb_bs_size = 0;
cl_mem ocl_eph_bb_di = NULL; size_t ocl_eph_bb_di_size = 0;
long ocl_gradacc_calls = 0;
// Aufrufzaehler: Bit-Gleichheit zur CPU allein beweist NICHT, dass der Kernel
// gelaufen ist - ein stiller Fallback saehe identisch aus. Genau diese
// Verwechslung war der Umgehungsfehler, der vorher behoben wurde.
long ocl_bw_din_calls = 0;
// dq (int8, rows) fuer den Ganzzahl-Backward - eigener Name, weil ocl_eph_dq
// bereits fuer einen anderen Zweck belegt ist.
cl_mem ocl_eph_bwdq = NULL; size_t ocl_eph_bwdq_size = 0;
cl_mem ocl_eph_bm_c = NULL; size_t ocl_eph_bm_c_size = 0;   // V8.6: batch x cols

// AUDIT: gebuendelte Attention (Query-Batch statt Pro-Position-Dispatch)
cl_mem ocl_eph_att_q = NULL;      size_t ocl_eph_att_q_size = 0;       // act x dim
cl_mem ocl_eph_att_out = NULL;    size_t ocl_eph_att_out_size = 0;     // act x dim
cl_mem ocl_eph_att_datt = NULL;   size_t ocl_eph_att_datt_size = 0;    // act x dim
cl_mem ocl_eph_att_dq = NULL;     size_t ocl_eph_att_dq_size = 0;      // act x dim
cl_mem ocl_eph_att_scores = NULL; size_t ocl_eph_att_scores_size = 0;  // act x numHeads x ctx
cl_mem ocl_eph_att_ds = NULL;     size_t ocl_eph_att_ds_size = 0;      // act x numHeads x ctx

// PHASE 3 DES INT8-UMBAUS: quantisierter Aktivierungsvektor (int8, dynamisch
// pro GEMM-Aufruf neu befuellt - siehe ocl_matVecMulI8 unten).
cl_mem ocl_eph_act_i8 = NULL;     size_t ocl_eph_act_i8_size = 0;
// PHASE 8: gebuendelter int8-Eingabeblock (batch x cols) + Skala je Position
cl_mem ocl_eph_bm_i8 = NULL;      size_t ocl_eph_bm_i8_size = 0;
cl_mem ocl_eph_bm_sc = NULL;      size_t ocl_eph_bm_sc_size = 0;

// FIX 1: Stale Pointer-Registry (Memory Leak)
void ocl_release_buffer(void* h_ptr) {
    if (!h_ptr) return;
    for(int i = 0; i < ocl_buf_count; i++) {
        if(ocl_buf_map[i].h_ptr == h_ptr) {
            clReleaseMemObject(ocl_buf_map[i].d_buf);
            for(int j = i; j < ocl_buf_count - 1; j++) {
                ocl_buf_map[j] = ocl_buf_map[j+1];
            }
            ocl_buf_count--;
            return;
        }
    }
}

cl_mem ocl_get_buffer(void* h_ptr, size_t bytes) {
    if (!h_ptr || bytes == 0) return NULL;

    for(int i = 0; i < ocl_buf_count; i++) {
        if(ocl_buf_map[i].h_ptr == h_ptr) {
            if (ocl_buf_map[i].bytes != bytes) {
                fprintf(stderr, "🚨 [SYMBIO GPU] Buffer Size Mismatch für Pointer %p!\n", h_ptr);
                return NULL;
            }
            return ocl_buf_map[i].d_buf;
        }
    }
    
    if(ocl_buf_count >= MAX_OCL_BUFFERS) {
        fprintf(stderr, "🚨 [SYMBIO GPU] VRAM Registry Overflow!\n");
        return NULL; 
    }
    
    cl_int err;
    cl_mem d_buf = ocl_mk(ocl_ctx, CL_MEM_READ_WRITE, bytes, NULL, &err);
    if(err == CL_SUCCESS) {
        ocl_wr(ocl_queue, d_buf, CL_TRUE, 0, bytes, h_ptr, 0, NULL, NULL);
        ocl_buf_map[ocl_buf_count].h_ptr = h_ptr;
        ocl_buf_map[ocl_buf_count].d_buf = d_buf;
        ocl_buf_map[ocl_buf_count].bytes = bytes;
        ocl_buf_count++;
        return d_buf;
    }
    return NULL;
}

void ocl_sync_to_host(void* h_ptr) {
    if (!ocl_ctx || !h_ptr) return;
    for(int i = 0; i < ocl_buf_count; i++) {
        if(ocl_buf_map[i].h_ptr == h_ptr) {
            ocl_rd(ocl_queue, ocl_buf_map[i].d_buf, CL_TRUE, 0, ocl_buf_map[i].bytes, h_ptr, 0, NULL, NULL);
            return;
        }
    }
}

// DIAGNOSE (Punkt 2): Pruefsumme des GERAETE-Puffers zu einem Host-Zeiger.
// Sucht NUR im Cache und legt bewusst nichts an - ein ocl_get_buffer() wuerde
// den Puffer sonst frisch vom Host befuellen und damit genau die Frage
// wegerklaeren, die hier gestellt wird ("ist das Geraet veraltet?").
// Rueckgabe -1, wenn zu diesem Zeiger gar kein Geraetepuffer existiert.
long ocl_device_checksum(void* h_ptr, size_t bytes) {
    if (!ocl_ctx || !h_ptr || bytes == 0) return -1;
    cl_mem d_buf = NULL;
    for (int i = 0; i < ocl_buf_count; i++) {
        if (ocl_buf_map[i].h_ptr == h_ptr) { d_buf = ocl_buf_map[i].d_buf; break; }
    }
    if (!d_buf) return -1;
    signed char* tmp = (signed char*)malloc(bytes);
    if (!tmp) return -1;
    ocl_rd(ocl_queue, d_buf, CL_TRUE, 0, bytes, tmp, 0, NULL, NULL);
    long sum = 0;
    for (size_t i = 0; i < bytes; i++) sum += (long)tmp[i];
    free(tmp);
    return sum;
}

void ocl_sync_to_device(void* h_ptr, size_t bytes) {
    if (!ocl_ctx || !h_ptr || bytes == 0) return;
    cl_mem d_buf = ocl_get_buffer(h_ptr, bytes);
    if (d_buf) {
        ocl_wr(ocl_queue, d_buf, CL_TRUE, 0, bytes, h_ptr, 0, NULL, NULL);
    }
}

void ocl_zero_buffer(void* h_ptr, size_t bytes) {
    if (!ocl_ctx) return;
    cl_mem d_buf = ocl_get_buffer(h_ptr, bytes);
    if (d_buf) {
        float zero = 0.0f;
        clEnqueueFillBuffer(ocl_queue, d_buf, &zero, sizeof(float), 0, bytes, 0, NULL, NULL);
        clFinish(ocl_queue);
    }
}

const char *kernel_source = 
"__kernel void matVecMul(__global const float* M, __global const float* v, __global float* out, int rows, int cols) {\n"
"    size_t r = get_global_id(0);\n"
"    if (r < (size_t)rows) {\n"
"        float sum = 0.0f;\n"
"        int c = 0;\n"
"        #pragma unroll 4\n"
"        for (; c <= cols - 4; c += 4) {\n"
"            sum += M[r * cols + c] * v[c];\n"
"            sum += M[r * cols + c + 1] * v[c + 1];\n"
"            sum += M[r * cols + c + 2] * v[c + 2];\n"
"            sum += M[r * cols + c + 3] * v[c + 3];\n"
"        }\n"
"        for (; c < cols; ++c) {\n"
"            sum += M[r * cols + c] * v[c];\n"
"        }\n"
"        out[r] = sum;\n"
"    }\n"
"}\n"
"\n"
"__kernel void matVecMulT(__global const float* M, __global const float* d_out, __global float* d_in,\n"
"                         int rows, int cols, int accumulate) {\n"
"    size_t c = get_global_id(0);\n"
"    if (c < (size_t)cols) {\n"
"        float sum = 0.0f;\n"
"        size_t idx = c;\n"
"        for (int r = 0; r < rows; ++r) {\n"
"            sum += M[idx] * d_out[r];\n"
"            idx += (size_t)cols;\n"
"        }\n"
"        d_in[c] = (accumulate == 1) ? (d_in[c] + sum) : sum;\n"
"    }\n"
"}\n"
"\n"
"__kernel void gradAccum(__global float* gm, __global const float* d_out, __global const float* i_v,\n"
"                        int rows, int cols) {\n"
"    size_t c = get_global_id(0);\n"
"    size_t r = get_global_id(1);\n"
"    if (c < (size_t)cols && r < (size_t)rows) {\n"
"        gm[r * (size_t)cols + c] += d_out[r] * i_v[c];\n"
"    }\n"
"}\n"
"\n"
"__kernel void matMulBatched(__global const float* M, __global const float* IN, __global float* OUT,\n"
"                            int rows, int cols, int batch) {\n"
"    size_t r = get_global_id(0);\n"
"    size_t p = get_global_id(1);\n"
"    if (r < (size_t)rows && p < (size_t)batch) {\n"
"        __global const float* v  = IN + p * (size_t)cols;\n"
"        __global const float* mr = M  + r * (size_t)cols;\n"
"        float sum = 0.0f;\n"
"        int c = 0;\n"
"        for (; c <= cols - 4; c += 4) {\n"
"            sum += mr[c] * v[c];         sum += mr[c+1] * v[c+1];\n"
"            sum += mr[c+2] * v[c+2];     sum += mr[c+3] * v[c+3];\n"
"        }\n"
"        for (; c < cols; ++c) sum += mr[c] * v[c];\n"
"        OUT[p * (size_t)rows + r] = sum;\n"
"    }\n"
"}\n"
"\n"
"__kernel void matMulTBatched(__global const float* M, __global const float* D_OUT, __global float* D_IN,\n"
"                             int rows, int cols, int batch, int accumulate) {\n"
"    size_t c = get_global_id(0);\n"
"    size_t p = get_global_id(1);\n"
"    if (c < (size_t)cols && p < (size_t)batch) {\n"
"        __global const float* d = D_OUT + p * (size_t)rows;\n"
"        float sum = 0.0f;\n"
"        size_t idx = c;\n"
"        for (int r = 0; r < rows; ++r) { sum += M[idx] * d[r]; idx += (size_t)cols; }\n"
"        size_t o = p * (size_t)cols + c;\n"
"        D_IN[o] = (accumulate == 1) ? (D_IN[o] + sum) : sum;\n"
"    }\n"
"}\n"
"\n"
"// Ein Thread pro (r,c), Schleife ueber die Batch-Achse INNERHALB des Threads.\n"
"// Dadurch schreibt jeder Thread genau ein Element - keine Atomics noetig.\n"
"__kernel void gradAccumBatched(__global float* gm, __global const float* D_OUT, __global const float* I_V,\n"
"                               int rows, int cols, int batch) {\n"
"    size_t c = get_global_id(0);\n"
"    size_t r = get_global_id(1);\n"
"    if (c < (size_t)cols && r < (size_t)rows) {\n"
"        float sum = 0.0f;\n"
"        for (int p = 0; p < batch; ++p) {\n"
"            sum += D_OUT[(size_t)p * (size_t)rows + r] * I_V[(size_t)p * (size_t)cols + c];\n"
"        }\n"
"        gm[r * (size_t)cols + c] += sum;\n"
"    }\n"
"}\n"
"\n"
"__kernel void adamUpdate(__global float* w, __global float* m, __global float* v, __global float* g, \n"
"                         float lr, float b1, float b2, float b1t, float b2t, float scale, int size, int is_sparse,\n"
"                         int cols, int bound_r, int bound_c, float boost, float wd) {\n"
"    size_t i = get_global_id(0);\n"
"    if (i < (size_t)size) {\n"
"        float grad = g[i] / scale;\n"
"        if (is_sparse == 1 && fabs(grad) < 1e-8f) return;\n" // FIX 2: GPU/CPU Inkonsistenz (fabs)
"        if (isnan(grad) || grad > 9999.0f || grad < -9999.0f) {\n"
"            g[i] = 0.0f;\n"
"            return;\n"
"        }\n"
// AUDIT: LR-Boost fuer frisch Net2Net-expandierte Bereiche ("Differenzierte
// Learning-Rate"). cols/bound_r/bound_c
// beschreiben, ab welcher Zeile/Spalte eine Matrix "neu" ist - identische
// Logik wie im CPU-Pfad (elemBoost() in cortex.nim).
"        int row = (int)(i / (size_t)cols);\n"
"        int col = (int)(i % (size_t)cols);\n"
"        float eff_lr = (row >= bound_r || col >= bound_c) ? (lr * boost) : lr;\n"
"        m[i] = b1 * m[i] + (1.0f - b1) * grad;\n"
"        v[i] = b2 * v[i] + (1.0f - b2) * grad * grad;\n"
"        float m_hat = m[i] / b1t;\n"
"        float v_hat = v[i] / b2t;\n"
"        w[i] -= eff_lr * m_hat / (sqrt(v_hat) + 1e-8f);\n"
// Weight-Decay (AdamW-Style, dekorreliert) - "Trainings-Absicherung:
// Nachruest-Paket" Punkt 1. wd=0.0 (Default) macht
// das bitidentisch zum bisherigen reinen-Adam-Verhalten. Muss exakt zum
// CPU-Pfad (adamStep() in cortex.nim) passen.
"        if (wd > 0.0f) { w[i] -= lr * wd * w[i]; }\n"
"        g[i] = 0.0f;\n"
"    }\n"
"}\n"
"\n"
"__kernel void attentionForward(__global const float* q, __global const float* k_cache, __global const float* v_cache, \n"
"                               __global float* att_out, __global float* scores, int pos, int numHeads, int headSize, int dim, int ctx) {\n"
"    int h = get_global_id(0);\n"
"    if (h >= numHeads) return;\n"
"    int h_off = h * headSize;\n"
"    float scale = 1.0f / sqrt((float)headSize);\n"
"    float max_s = -9999.0f;\n"
"    for (int t = 0; t <= pos; t++) {\n"
"        float sc = 0.0f;\n"
"        int k_off = t * dim + h_off;\n"
"        int d = 0;\n"
"        for (; d <= headSize - 4; d += 4) {\n"
"            sc += q[h_off + d] * k_cache[k_off + d]; sc += q[h_off + d + 1] * k_cache[k_off + d + 1];\n"
"            sc += q[h_off + d + 2] * k_cache[k_off + d + 2]; sc += q[h_off + d + 3] * k_cache[k_off + d + 3];\n"
"        }\n"
"        for (; d < headSize; d++) sc += q[h_off + d] * k_cache[k_off + d];\n"
"        sc *= scale; scores[h * ctx + t] = sc;\n"
"        if (sc > max_s) max_s = sc;\n"
"    }\n"
"    float sum_e = 0.0f;\n"
"    for (int t = 0; t <= pos; t++) { float e = exp(scores[h * ctx + t] - max_s); scores[h * ctx + t] = e; sum_e += e; }\n"
"    for (int d = 0; d < headSize; d++) att_out[h_off + d] = 0.0f;\n"
"    for (int t = 0; t <= pos; t++) {\n"
"        float w = scores[h * ctx + t] / sum_e;\n"
"        int v_off = t * dim + h_off;\n"
"        int d = 0;\n"
"        for (; d <= headSize - 4; d += 4) {\n"
"            att_out[h_off + d] += v_cache[v_off + d] * w; att_out[h_off + d + 1] += v_cache[v_off + d + 1] * w;\n"
"            att_out[h_off + d + 2] += v_cache[v_off + d + 2] * w; att_out[h_off + d + 3] += v_cache[v_off + d + 3] * w;\n"
"        }\n"
"        for (; d < headSize; d++) att_out[h_off + d] += v_cache[v_off + d] * w;\n"
"    }\n"
"}\n"
"\n"
"__kernel void attentionBackward(__global const float* q, __global const float* k_cache, __global const float* v_cache, \n"
"                                __global const float* d_att_out, __global float* d_q, __global float* d_k_cache, __global float* d_v_cache, \n"
"                                __global float* scores, __global float* d_w, int pos, int numHeads, int headSize, int dim, int ctx) {\n"
"    int h = get_global_id(0);\n"
"    if (h >= numHeads) return;\n"
"    int h_off = h * headSize;\n"
"    float scale = 1.0f / sqrt((float)headSize);\n"
"    float max_s = -9999.0f;\n"
"    for (int d = 0; d < headSize; d++) d_q[h_off + d] = 0.0f;\n"
"    for (int t = 0; t <= pos; t++) {\n"
"        float sc = 0.0f; int k_off = t * dim + h_off;\n"
"        for (int d = 0; d < headSize; d++) sc += q[h_off + d] * k_cache[k_off + d];\n"
"        sc *= scale; scores[h * ctx + t] = sc;\n"
"        if (sc > max_s) max_s = sc;\n"
"    }\n"
"    float sum_e = 0.0f;\n"
"    for (int t = 0; t <= pos; t++) { float e = exp(scores[h * ctx + t] - max_s); scores[h * ctx + t] = e; sum_e += e; }\n"
"    float sum_w_dw = 0.0f;\n"
"    for (int t = 0; t <= pos; t++) {\n"
"        float w = scores[h * ctx + t] / sum_e; scores[h * ctx + t] = w;\n"
"        int v_off = t * dim + h_off; float dw = 0.0f;\n"
"        for (int d = 0; d < headSize; d++) {\n"
"            dw += d_att_out[h_off + d] * v_cache[v_off + d];\n"
"            d_v_cache[v_off + d] += d_att_out[h_off + d] * w;\n"
"        }\n"
"        d_w[h * ctx + t] = dw; sum_w_dw += w * dw;\n"
"    }\n"
"    for (int t = 0; t <= pos; t++) {\n"
"        float w = scores[h * ctx + t];\n"
"        float ds = w * (d_w[h * ctx + t] - sum_w_dw) * scale;\n"
"        int k_off = t * dim + h_off;\n"
"        for (int d = 0; d < headSize; d++) {\n"
"            d_q[h_off + d] += ds * k_cache[k_off + d];\n"
"            d_k_cache[k_off + d] += ds * q[h_off + d];\n"
"        }\n"
"    }\n"
"}\n"
"\n"
"// AUDIT: gebuendelte Attention ueber die Positionsachse - ein Dispatch statt\n"
"// 'act' einzelner Aufrufe. Arbeitsgruppe (h, p): jede Position p bekommt ihr\n"
"// eigenes Work-Item, das exakt dieselbe Kausal-Maske (t <= p) und dieselbe\n"
"// Softmax-Mathematik wie der alte Pro-Position-Kernel rechnet.\n"
"__kernel void attentionForwardBatched(__global const float* q_all, __global const float* k_cache, __global const float* v_cache,\n"
"                                       __global float* att_out_all, __global float* scores,\n"
"                                       int act, int numHeads, int headSize, int dim, int ctx) {\n"
"    int h = get_global_id(0);\n"
"    int p = get_global_id(1);\n"
"    if (h >= numHeads || p >= act) return;\n"
"    int h_off = h * headSize;\n"
"    __global const float* q = q_all + (size_t)p * (size_t)dim;\n"
"    __global float* att_out = att_out_all + (size_t)p * (size_t)dim;\n"
"    __global float* my_scores = scores + ((size_t)p * (size_t)numHeads + h) * (size_t)ctx;\n"
"    float scale = 1.0f / sqrt((float)headSize);\n"
"    float max_s = -9999.0f;\n"
"    for (int t = 0; t <= p; t++) {\n"
"        float sc = 0.0f; int k_off = t * dim + h_off;\n"
"        for (int d = 0; d < headSize; d++) sc += q[h_off + d] * k_cache[k_off + d];\n"
"        sc *= scale; my_scores[t] = sc;\n"
"        if (sc > max_s) max_s = sc;\n"
"    }\n"
"    float sum_e = 0.0f;\n"
"    for (int t = 0; t <= p; t++) { float e = exp(my_scores[t] - max_s); my_scores[t] = e; sum_e += e; }\n"
"    for (int d = 0; d < headSize; d++) att_out[h_off + d] = 0.0f;\n"
"    for (int t = 0; t <= p; t++) {\n"
"        float w = my_scores[t] / sum_e;\n"
"        int v_off = t * dim + h_off;\n"
"        for (int d = 0; d < headSize; d++) att_out[h_off + d] += v_cache[v_off + d] * w;\n"
"    }\n"
"}\n"
"\n"
"// AUDIT: Attention-Backward Stufe A (query-parallel, ein Work-Item pro (h,p)).\n"
"// d_q ist ausschliesslich von Position p abhaengig -> race-frei direkt geschrieben.\n"
"// weights/ds werden fuer Stufe B zwischengespeichert (bleiben GPU-resident).\n"
"__kernel void attentionBackwardBatchedQuery(__global const float* q_all, __global const float* k_cache, __global const float* v_cache,\n"
"                                             __global const float* d_att_out_all, __global float* d_q_all,\n"
"                                             __global float* weights, __global float* ds,\n"
"                                             int act, int numHeads, int headSize, int dim, int ctx) {\n"
"    int h = get_global_id(0);\n"
"    int p = get_global_id(1);\n"
"    if (h >= numHeads || p >= act) return;\n"
"    int h_off = h * headSize;\n"
"    __global const float* q = q_all + (size_t)p * (size_t)dim;\n"
"    __global const float* d_att_out = d_att_out_all + (size_t)p * (size_t)dim;\n"
"    __global float* d_q = d_q_all + (size_t)p * (size_t)dim;\n"
"    __global float* my_w  = weights + ((size_t)p * (size_t)numHeads + h) * (size_t)ctx;\n"
"    __global float* my_ds = ds      + ((size_t)p * (size_t)numHeads + h) * (size_t)ctx;\n"
"    float scale = 1.0f / sqrt((float)headSize);\n"
"    float max_s = -9999.0f;\n"
"    for (int d = 0; d < headSize; d++) d_q[h_off + d] = 0.0f;\n"
"    for (int t = 0; t <= p; t++) {\n"
"        float sc = 0.0f; int k_off = t * dim + h_off;\n"
"        for (int d = 0; d < headSize; d++) sc += q[h_off + d] * k_cache[k_off + d];\n"
"        sc *= scale; my_w[t] = sc;\n"
"        if (sc > max_s) max_s = sc;\n"
"    }\n"
"    float sum_e = 0.0f;\n"
"    for (int t = 0; t <= p; t++) { float e = exp(my_w[t] - max_s); my_w[t] = e; sum_e += e; }\n"
"    float sum_w_dw = 0.0f;\n"
"    for (int t = 0; t <= p; t++) {\n"
"        float w = my_w[t] / sum_e; my_w[t] = w;\n"
"        int v_off = t * dim + h_off; float dw = 0.0f;\n"
"        for (int d = 0; d < headSize; d++) dw += d_att_out[h_off + d] * v_cache[v_off + d];\n"
"        my_ds[t] = dw; sum_w_dw += w * dw;\n"
"    }\n"
"    for (int t = 0; t <= p; t++) {\n"
"        float w = my_w[t];\n"
"        float dw = my_ds[t];\n"
"        float ds_val = w * (dw - sum_w_dw) * scale;\n"
"        my_ds[t] = ds_val;\n"
"        int k_off = t * dim + h_off;\n"
"        for (int d = 0; d < headSize; d++) d_q[h_off + d] += ds_val * k_cache[k_off + d];\n"
"    }\n"
"}\n"
"\n"
"// AUDIT: Attention-Backward Stufe B (key-parallel, ein Work-Item pro (h,t)).\n"
"// d_k_cache/d_v_cache an Position t erhalten Beitraege von JEDER Query p >= t -\n"
"// ueber die Query-Achse zu parallelisieren waere ein Data-Race (mehrere p\n"
"// schreiben in dasselbe t). Deshalb hier die Key-Achse als Parallel-Dimension:\n"
"// jedes Work-Item besitzt exklusiv genau ein (h,t)-Ausgabe-Segment und summiert\n"
"// darin seriell ueber alle p >= t - race-frei, ohne Atomics.\n"
"__kernel void attentionBackwardBatchedKey(__global const float* q_all, __global const float* d_att_out_all,\n"
"                                           __global const float* weights, __global const float* ds,\n"
"                                           __global float* d_k_cache, __global float* d_v_cache,\n"
"                                           int act, int numHeads, int headSize, int dim, int ctx) {\n"
"    int h = get_global_id(0);\n"
"    int t = get_global_id(1);\n"
"    if (h >= numHeads || t >= act) return;\n"
"    int h_off = h * headSize;\n"
"    int kv_off = t * dim + h_off;\n"
"    for (int d = 0; d < headSize; d++) { d_k_cache[kv_off + d] = 0.0f; d_v_cache[kv_off + d] = 0.0f; }\n"
"    for (int p = t; p < act; p++) {\n"
"        size_t idx = ((size_t)p * (size_t)numHeads + h) * (size_t)ctx + t;\n"
"        float w  = weights[idx];\n"
"        float dsv = ds[idx];\n"
"        __global const float* d_att_out = d_att_out_all + (size_t)p * (size_t)dim;\n"
"        __global const float* q = q_all + (size_t)p * (size_t)dim;\n"
"        for (int d = 0; d < headSize; d++) {\n"
"            d_v_cache[kv_off + d] += d_att_out[h_off + d] * w;\n"
"            d_k_cache[kv_off + d] += dsv * q[h_off + d];\n"
"        }\n"
"    }\n"
"}\n"
"\n"
// PHASE 3 DES INT8-UMBAUS: INT8-GEMM (echtes int8xint8->int32, sofort auf
// float dequantisiert - Design-Entscheidung #4, spiegelt matVecMulI8() in
// cortex.nim). Mscale: ein Skalenfaktor pro Zeile r. vScale: EIN
// Skalenfaktor fuer den ganzen (dynamisch quantisierten) Aktivierungsvektor
// v - wird vom Host VOR dem Kernel-Aufruf berechnet (quantizeActivation()-
// Aequivalent, siehe ocl_matVecMulI8 unten), da der Vektor klein ist
// (hiddenDim/ffnDim) und eine GPU-seitige Max-Reduktion dafuer nicht lohnt.\n"
"__kernel void matVecMulI8(__global const char* M, __global const float* Mscale,\n"
"                          __global const char* v, float vScale,\n"
"                          __global float* out, int rows, int cols) {\n"
"    size_t r = get_global_id(0);\n"
"    if (r < (size_t)rows) {\n"
"        int acc = 0;\n"
"        size_t off = r * (size_t)cols;\n"
"        for (int c = 0; c < cols; c++) {\n"
"            acc += (int)M[off + c] * (int)v[c];\n"
"        }\n"
"        out[r] = (float)acc * Mscale[r] * vScale;\n"
"    }\n"
"}\n"
"\n"
// PHASE 3 DES INT8-UMBAUS: Rounded-Integer-Step Adam auf INT8-Gewichten
// (Design-Entscheidung #3, spiegelt adamStepI8() in cortex.nim - MUSS exakt
// dieselbe Mathematik/denselben MAX_LSB_STEP_PER_UPDATE=4 Trust-Region-Cap
// verwenden wie dort, sonst driften CPU- und GPU-INT8-Pfad numerisch
// auseinander. wscale[row]: Skala der Zeile, zu der Element i gehoert -\n"
// dieselbe Row/Col-Boost-Logik wie im bestehenden FP32 adamUpdate-Kernel\n"
// oben (aequivalent zu elemBoost() im CPU-Pfad).\n"
"#define MAX_LSB_STEP_PER_UPDATE_I8 4\n"
// PHASE 7 (GPU-Dispatch): transponiertes Matvec mit INT8-Gewichten fuer den
// Backward-Pass. d_in[c] = sum_r dequant(M[r,c]) * d_out[r], wobei
// dequant(M[r,c]) = M[r,c] * Mscale[r]. Anders als beim Forward-GEMM ist hier
// KEINE int8xint8-Akkumulation moeglich: d_out ist ein Gradient (float,
// beliebige Groessenordnung), kein quantisierter Aktivierungsvektor. Das
// Gewicht wird also beim Lesen dequantisiert und in float gerechnet - exakt
// wie im CPU-Pendant matVecMulBackwardAccI8(). Die Zeilen-Skala wird dabei
// mit d_out[r] zusammengefasst (rowFactor), spart eine Multiplikation je
// Element - dieselbe Optimierung wie im CPU-Pfad.
// PHASE 8: GEBUENDELTE INT8-KERNEL (ueber die Positionsachse)
// Der eigentliche Hebel gegenueber Phase 7: statt eines Kernel-Starts pro
// Position und Matrix nur noch EINER pro Matrix. Bei 16 Layern und Fenster
// 1024 sind das ~291 statt ~298.000 Starts pro Trainingsschritt.
// inScale ist PRO POSITION - jede Aktivierungszeile wird eigenstaendig
// quantisiert (dynamische Abs-Max-Skala), genau wie im Einzelpfad.
"__kernel void matMulBatchedI8(__global const char* M, __global const float* Mscale,\n"
"                              __global const char* IN, __global const float* inScale,\n"
"                              __global float* OUT, int rows, int cols, int batch) {\n"
"    size_t r = get_global_id(0);\n"
"    size_t p = get_global_id(1);\n"
"    if (r < (size_t)rows && p < (size_t)batch) {\n"
"        int acc = 0;\n"
"        size_t mo = r * (size_t)cols;\n"
"        size_t io = p * (size_t)cols;\n"
"        for (int c = 0; c < cols; ++c) acc += (int)M[mo + c] * (int)IN[io + c];\n"
"        OUT[p * (size_t)rows + r] = (float)acc * Mscale[r] * inScale[p];\n"
"    }\n"
"}\n"
"\n"
// ============================================================================
// FULL-INT8 SCHRITT 1 auf der GPU (2026-08-24): d_in = W^T . d_out als echtes
// int8xint8->int32-GEMM mit PRO-BLOCK-Gradientenskalen.
//
// Aufgabenteilung wie beim Forward-Pendant matVecMulI8: die Quantisierung des
// Gradienten bleibt auf dem HOST (O(rows), ~1/cols der Arbeit - eine
// GPU-Reduktion dafuer lohnt nicht), nur die eigentliche Reduktion wandert.
// Der Host liefert also bereits `dq` (int8) und `bscale` (eine Skala je
// 64er-Block).
//
// Ein Work-Item je AUSGABESPALTE. Innerhalb eines Blocks wird rein in int
// akkumuliert und erst danach mit der Blockskala dequantisiert - exakt die
// Reihenfolge von backwardDInI8() in cortex.nim, damit beide bit-gleich
// rechnen (Integer-Addition ist assoziativ, die Reihenfolge innerhalb des
// Blocks ist also unerheblich).
"__kernel void backwardDInI8Batched(__global const char* W, __global const char* dq,\n"
"                                   __global const float* bscale, __global float* d_in,\n"
"                                   int rows, int cols, int batch, int blockSize,\n"
"                                   int accumulate) {\n"
"    size_t idx = get_global_id(0);\n"
"    if (idx >= (size_t)batch * (size_t)cols) return;\n"
"    int p = (int)(idx / (size_t)cols);\n"
"    int c = (int)(idx % (size_t)cols);\n"
"    int nblocks = (rows + blockSize - 1) / blockSize;\n"
"    float acc = (accumulate == 1) ? d_in[idx] : 0.0f;\n"
"    for (int b = 0; b < nblocks; ++b) {\n"
"        float s = bscale[p * nblocks + b];\n"
"        if (s > 0.0f) {\n"
"            int r0 = b * blockSize;\n"
"            int r1 = r0 + blockSize; if (r1 > rows) r1 = rows;\n"
"            int iacc = 0;\n"
"            for (int r = r0; r < r1; ++r) {\n"
"                iacc += (int)W[r * cols + c] * (int)dq[p * rows + r];\n"
"            }\n"
"            acc += (float)iacc * s;\n"
"        }\n"
"    }\n"
"    d_in[idx] = acc;\n"
"}\n"
"__kernel void gradAccumI8(__global const char* qi, __global const char* qd,\n"
"                          __global const float* dsc, __global const float* isc,\n"
"                          __global float* gm,\n"
"                          int rows, int cols, int batch, int qiStride) {\n"
"    size_t idx = get_global_id(0);\n"
"    if (idx >= (size_t)rows * (size_t)cols) return;\n"
"    int r = (int)(idx / (size_t)cols);\n"
"    int c = (int)(idx % (size_t)cols);\n"
"    float ds = dsc[r];\n"
"    float is = isc[c];\n"
"    if (ds > 0.0f && is > 0.0f) {\n"
"        int acc = 0;\n"
"        for (int p = 0; p < batch; ++p) {\n"
"            acc += (int)qd[p * rows + r] * (int)qi[p * qiStride + c];\n"
"        }\n"
"        gm[idx] += (float)acc * ds * is;\n"
"    }\n"
"}\n"
"// ==== OCL-BW-KACHEL (2026-11-11, Gegenstueck zu SNAI_CUDA_BW e612): Kachel 64x64, 256 Work-Items je 4x4 ====\n"
"#pragma OPENCL FP_CONTRACT OFF\n"
"__kernel void backwardDInI8BatchedTiled(__global const char* W, __global const char* dq,\n"
"                                        __global const float* bscale, __global float* d_in,\n"
"                                        int rows, int cols, int batch, int accumulate, int rot) {\n"
"    __local char sW[64][65];\n"
"    __local char sQ[64][65];\n"
"    const int lid = get_local_id(0);\n"
"    const int tx = lid & 15, ty = lid >> 4;\n"
"    const int c0 = get_group_id(0) * 64, p0 = get_group_id(1) * 64;\n"
"    const int nblocks = (rows + 63) / 64;\n"
"    float accf[4][4];\n"
"    for (int i = 0; i < 4; ++i)\n"
"        for (int j = 0; j < 4; ++j) {\n"
"            const int p = p0 + ty + 16 * i, c = c0 + tx + 16 * j;\n"
"            accf[i][j] = (accumulate == 1 && p < batch && c < cols) ? d_in[(size_t)p * (size_t)cols + (size_t)c] : 0.0f;\n"
"        }\n"
"    for (int b = 0; b < nblocks; ++b) {\n"
"        const int k0 = b * 64;\n"
"        const int k1 = (k0 + 64 < rows) ? k0 + 64 : rows;\n"
"        for (int e = lid; e < 4096; e += 256) {\n"
"            const int kk = e / 64, ii = e % 64;\n"
"            const int r = k0 + kk, gc = c0 + ii;\n"
"            sW[kk][ii] = (r < k1 && gc < cols) ? W[(size_t)r * (size_t)cols + (size_t)gc] : (char)0;\n"
"            const int gp = p0 + kk, rq = k0 + ii;\n"
"            sQ[kk][ii] = (gp < batch && rq < k1) ? dq[(size_t)gp * (size_t)rows + (size_t)rq] : (char)0;\n"
"        }\n"
"        barrier(CLK_LOCAL_MEM_FENCE);\n"
"        int iacc[4][4];\n"
"        for (int i = 0; i < 4; ++i) for (int j = 0; j < 4; ++j) iacc[i][j] = 0;\n"
"        for (int k = 0; k < 64; ++k) {\n"
"            int a[4], bb[4];\n"
"            for (int i = 0; i < 4; ++i) a[i] = (int)sQ[ty + 16 * i][k];\n"
"            for (int j = 0; j < 4; ++j) bb[j] = (int)sW[k][tx + 16 * j];\n"
"            for (int i = 0; i < 4; ++i) for (int j = 0; j < 4; ++j) iacc[i][j] += a[i] * bb[j];\n"
"        }\n"
"        barrier(CLK_LOCAL_MEM_FENCE);\n"
"        for (int i = 0; i < 4; ++i) {\n"
"            const int p = p0 + ty + 16 * i;\n"
"            if (p >= batch) continue;\n"
"            const float sc = bscale[(size_t)p * (size_t)nblocks + (size_t)b];\n"
"            if (sc > 0.0f) {\n"
"                for (int j = 0; j < 4; ++j) {\n"
"                    const int c = c0 + tx + 16 * j;\n"
"                    int ia = iacc[i][j];\n"
"                    if (rot && b == nblocks - 1 && p == batch - 1 && c == cols - 1) ia += 1;\n"
"                    const float prod = (float)ia * sc;\n"
"                    accf[i][j] = accf[i][j] + prod;\n"
"                }\n"
"            }\n"
"        }\n"
"    }\n"
"    for (int i = 0; i < 4; ++i) {\n"
"        const int p = p0 + ty + 16 * i;\n"
"        if (p >= batch) continue;\n"
"        for (int j = 0; j < 4; ++j) {\n"
"            const int c = c0 + tx + 16 * j;\n"
"            if (c < cols) d_in[(size_t)p * (size_t)cols + (size_t)c] = accf[i][j];\n"
"        }\n"
"    }\n"
"}\n"
"__kernel void gradAccumI8Tiled(__global const char* qi, __global const char* qd,\n"
"                               __global const float* dsc, __global const float* isc,\n"
"                               __global float* gm, int rows, int cols, int batch, int qiStride, int rot) {\n"
"    __local char sD[64][65];\n"
"    __local char sI[64][65];\n"
"    const int lid = get_local_id(0);\n"
"    const int tx = lid & 15, ty = lid >> 4;\n"
"    const int c0 = get_group_id(0) * 64, r0 = get_group_id(1) * 64;\n"
"    int acc[4][4];\n"
"    for (int i = 0; i < 4; ++i) for (int j = 0; j < 4; ++j) acc[i][j] = 0;\n"
"    for (int q0 = 0; q0 < batch; q0 += 64) {\n"
"        for (int e = lid; e < 4096; e += 256) {\n"
"            const int kk = e / 64, ii = e % 64;\n"
"            const int p = q0 + kk;\n"
"            sD[kk][ii] = (p < batch && r0 + ii < rows) ? qd[(size_t)p * (size_t)rows + (size_t)(r0 + ii)] : (char)0;\n"
"            sI[kk][ii] = (p < batch && c0 + ii < cols) ? qi[(size_t)p * (size_t)qiStride + (size_t)(c0 + ii)] : (char)0;\n"
"        }\n"
"        barrier(CLK_LOCAL_MEM_FENCE);\n"
"        for (int k = 0; k < 64; ++k) {\n"
"            int a[4], bb[4];\n"
"            for (int i = 0; i < 4; ++i) a[i] = (int)sD[k][ty + 16 * i];\n"
"            for (int j = 0; j < 4; ++j) bb[j] = (int)sI[k][tx + 16 * j];\n"
"            for (int i = 0; i < 4; ++i) for (int j = 0; j < 4; ++j) acc[i][j] += a[i] * bb[j];\n"
"        }\n"
"        barrier(CLK_LOCAL_MEM_FENCE);\n"
"    }\n"
"    for (int i = 0; i < 4; ++i) {\n"
"        const int r = r0 + ty + 16 * i;\n"
"        if (r >= rows) continue;\n"
"        const float ds = dsc[r];\n"
"        for (int j = 0; j < 4; ++j) {\n"
"            const int c = c0 + tx + 16 * j;\n"
"            if (c >= cols) continue;\n"
"            const float is = isc[c];\n"
"            if (ds > 0.0f && is > 0.0f) {\n"
"                int a = acc[i][j];\n"
"                if (rot && r == rows - 1 && c == cols - 1) a += 1;\n"
"                const size_t idx = (size_t)r * (size_t)cols + (size_t)c;\n"
"                const float t1 = (float)a * ds;\n"
"                const float t2 = t1 * is;\n"
"                gm[idx] = gm[idx] + t2;\n"
"            }\n"
"        }\n"
"    }\n"
"}\n"
"#pragma OPENCL FP_CONTRACT ON\n"
"__kernel void backwardDInI8(__global const char* W, __global const char* dq,\n"
"                            __global const float* bscale, __global float* d_in,\n"
"                            int rows, int cols, int blockSize, int accumulate) {\n"
"    size_t c = get_global_id(0);\n"
"    if (c >= (size_t)cols) return;\n"
"    float acc = (accumulate == 1) ? d_in[c] : 0.0f;\n"
"    int nblocks = (rows + blockSize - 1) / blockSize;\n"
"    for (int b = 0; b < nblocks; ++b) {\n"
"        float s = bscale[b];\n"
"        if (s <= 0.0f) continue;\n"
"        int r0 = b * blockSize;\n"
"        int r1 = r0 + blockSize; if (r1 > rows) r1 = rows;\n"
"        int iacc = 0;\n"
"        size_t idx = (size_t)r0 * (size_t)cols + c;\n"
"        for (int r = r0; r < r1; ++r) { iacc += (int)W[idx] * (int)dq[r]; idx += (size_t)cols; }\n"
"        acc += (float)iacc * s;\n"
"    }\n"
"    d_in[c] = acc;\n"
"}\n"
"\n"
"__kernel void matMulTBatchedI8(__global const char* M, __global const float* Mscale,\n"
"                               __global const float* D_OUT, __global float* D_IN,\n"
"                               int rows, int cols, int batch, int accumulate) {\n"
"    size_t c = get_global_id(0);\n"
"    size_t p = get_global_id(1);\n"
"    if (c < (size_t)cols && p < (size_t)batch) {\n"
"        __global const float* d = D_OUT + p * (size_t)rows;\n"
"        float sum = 0.0f;\n"
"        size_t idx = c;\n"
"        for (int r = 0; r < rows; ++r) { sum += (float)M[idx] * (Mscale[r] * d[r]); idx += (size_t)cols; }\n"
"        size_t o = p * (size_t)cols + c;\n"
"        D_IN[o] = (accumulate == 1) ? (D_IN[o] + sum) : sum;\n"
"    }\n"
"}\n"
"\n"
"\n"
"// PHASE 10 DES INT8-UMBAUS (2026-08-20): Float-Adam MIT Fehler-Rueckfuehrung -\n"
"// exaktes Gegenstueck zu adamRowFloatI8() in cortex.nim. Der alte\n"
"// adamUpdateI8 daneben rechnet weiter die Trust-Region-Variante und bleibt\n"
"// nur fuer Vergleichsmessungen stehen (i8_float_adam=0).\n"
"//\n"
"// Anders als adamUpdateI8 ist das KEIN flaches Elementgitter: die neue Skala\n"
"// einer Zeile ist max|Zeile|/127, also braucht es eine Reduktion ueber die\n"
"// ganze Zeile zwischen den beiden Durchgaengen. Deshalb EINE WORKGROUP JE\n"
"// ZEILE mit lokaler Max-Reduktion. local_size MUSS eine Zweierpotenz sein.\n"
"__kernel void adamRowFloatI8(__global char* w, __global float* wscale,\n"
"                             __global float* m, __global float* v, __global float* g,\n"
"                             __global float* res,\n"
"                             float lr, float b1, float b2, float b1t, float b2t, float scale,\n"
"                             int cols, int is_sparse, int bound_r, int bound_c,\n"
"                             float boost, float wd, int use_fb,\n"
"                             __local float* red) {\n"
"    int row = get_group_id(0);\n"
"    int lid = get_local_id(0);\n"
"    int lsz = get_local_size(0);\n"
"    size_t off = (size_t)row * (size_t)cols;\n"
"    float qscale = wscale[row];\n"
"    float localMax = 0.0f;\n"
"\n"
"    // Durchgang 1: Adam in Float, Ergebnis in g zwischenspeichern\n"
"    for (int c = lid; c < cols; c += lsz) {\n"
"        size_t i = off + (size_t)c;\n"
"        float wf0 = (float)w[i] * qscale;\n"
"        float grad = g[i] / scale;\n"
"        float wf = wf0;\n"
"        if (scale != 0.0f && !isnan(grad) && grad <= 9999.0f && grad >= -9999.0f) {\n"
"            if (!(is_sparse == 1 && fabs(grad) < 1e-8f)) {\n"
"                m[i] = b1 * m[i] + (1.0f - b1) * grad;\n"
"                v[i] = b2 * v[i] + (1.0f - b2) * grad * grad;\n"
"                float m_hat = m[i] / b1t;\n"
"                float v_hat = v[i] / b2t;\n"
"                float eff_lr = (row >= bound_r || c >= bound_c) ? (lr * boost) : lr;\n"
"                wf = wf0 - eff_lr * m_hat / (sqrt(v_hat) + 1e-8f);\n"
"                if (wd > 0.0f) { wf -= lr * wd * wf0; }\n"
"            }\n"
"        }\n"
"        if (use_fb == 1) { wf += res[i]; }\n"
"        g[i] = wf;\n"
"        localMax = fmax(localMax, fabs(wf));\n"
"    }\n"
"\n"
"    red[lid] = localMax;\n"
"    barrier(CLK_LOCAL_MEM_FENCE);\n"
"    for (int st = lsz / 2; st > 0; st >>= 1) {\n"
"        if (lid < st) { red[lid] = fmax(red[lid], red[lid + st]); }\n"
"        barrier(CLK_LOCAL_MEM_FENCE);\n"
"    }\n"
"    float maxAbs = red[0];\n"
"    float newScale = (maxAbs > 0.0f) ? (maxAbs / 127.0f) : qscale;\n"
"    if (lid == 0) { wscale[row] = newScale; }\n"
"    float inv = 1.0f / newScale;\n"
"\n"
"    // Durchgang 2: requantisieren, Rest sichern, g nullen\n"
"    for (int c = lid; c < cols; c += lsz) {\n"
"        size_t i = off + (size_t)c;\n"
"        float target = g[i];\n"
"        int q = (int)round(target * inv);\n"
"        if (q > 127) q = 127; else if (q < -128) q = -128;\n"
"        w[i] = (char)q;\n"
"        if (use_fb == 1) {\n"
"            // Deckel auf eine LSB-Breite, identisch zur CPU: groesser wird der\n"
"            // Rest nur bei geklemmtem q und wuechse sonst unbegrenzt weiter.\n"
"            float e = target - (float)q * newScale;\n"
"            if (e > newScale) e = newScale; else if (e < -newScale) e = -newScale;\n"
"            res[i] = e;\n"
"        }\n"
"        g[i] = 0.0f;\n"
"    }\n"
"}\n"
"__kernel void matVecMulTI8(__global const char* M, __global const float* Mscale,\n"
"                           __global const float* d_out, __global float* d_in,\n"
"                           int rows, int cols, int accumulate) {\n"
"    size_t c = get_global_id(0);\n"
"    if (c < (size_t)cols) {\n"
"        float sum = 0.0f;\n"
"        size_t idx = c;\n"
"        for (int r = 0; r < rows; ++r) {\n"
"            sum += (float)M[idx] * (Mscale[r] * d_out[r]);\n"
"            idx += (size_t)cols;\n"
"        }\n"
"        d_in[c] = (accumulate == 1) ? (d_in[c] + sum) : sum;\n"
"    }\n"
"}\n"
"\n"
"__kernel void adamUpdateI8(__global char* w, __global const float* wscale, __global float* m, __global float* v, __global float* g,\n"
"                           float lr, float b1, float b2, float b1t, float b2t, float scale, int size, int is_sparse,\n"
"                           int cols, int bound_r, int bound_c, float boost, float wd) {\n"
"    size_t i = get_global_id(0);\n"
"    if (i < (size_t)size) {\n"
"        float grad = g[i] / scale;\n"
"        if (is_sparse == 1 && fabs(grad) < 1e-8f) return;\n"
"        if (isnan(grad) || grad > 9999.0f || grad < -9999.0f) {\n"
"            g[i] = 0.0f;\n"
"            return;\n"
"        }\n"
"        int row = (int)(i / (size_t)cols);\n"
"        int col = (int)(i % (size_t)cols);\n"
"        float eff_lr = (row >= bound_r || col >= bound_c) ? (lr * boost) : lr;\n"
"        float qscale = wscale[row];\n"
"        m[i] = b1 * m[i] + (1.0f - b1) * grad;\n"
"        v[i] = b2 * v[i] + (1.0f - b2) * grad * grad;\n"
"        float m_hat = m[i] / b1t;\n"
"        float v_hat = v[i] / b2t;\n"
"        float delta = eff_lr * m_hat / (sqrt(v_hat) + 1e-8f);\n"
"        if (wd > 0.0f) { delta += lr * wd * ((float)w[i] * qscale); }\n"
"        int steps = (int)round(delta / qscale);\n"
"        if (steps > MAX_LSB_STEP_PER_UPDATE_I8) steps = MAX_LSB_STEP_PER_UPDATE_I8;\n"
"        if (steps < -MAX_LSB_STEP_PER_UPDATE_I8) steps = -MAX_LSB_STEP_PER_UPDATE_I8;\n"
"        if (steps != 0) {\n"
"            int newW = (int)w[i] - steps;\n"
"            if (newW > 127) newW = 127;\n"
"            if (newW < -128) newW = -128;\n"
"            w[i] = (char)newW;\n"
"        }\n"
"        g[i] = 0.0f;\n"
"    }\n"
"}\n";

void shutdown_opencl_engine() {
    for(int i=0; i<ocl_buf_count; i++) {
        if(ocl_buf_map[i].d_buf) clReleaseMemObject(ocl_buf_map[i].d_buf);
    }
    ocl_buf_count = 0;
    
    if (ocl_eph_v) { clReleaseMemObject(ocl_eph_v); ocl_eph_v = NULL; ocl_eph_v_size = 0; }
    if (ocl_eph_out) { clReleaseMemObject(ocl_eph_out); ocl_eph_out = NULL; ocl_eph_out_size = 0; }
    if (ocl_eph_dq) { clReleaseMemObject(ocl_eph_dq); ocl_eph_dq = NULL; ocl_eph_dq_size = 0; }
    if (ocl_eph_scores) { clReleaseMemObject(ocl_eph_scores); ocl_eph_scores = NULL; ocl_eph_scores_size = 0; }
    if (ocl_eph_dw) { clReleaseMemObject(ocl_eph_dw); ocl_eph_dw = NULL; ocl_eph_dw_size = 0; }
    if (ocl_eph_bt_a) { clReleaseMemObject(ocl_eph_bt_a); ocl_eph_bt_a = NULL; ocl_eph_bt_a_size = 0; }
    if (ocl_eph_bt_b) { clReleaseMemObject(ocl_eph_bt_b); ocl_eph_bt_b = NULL; ocl_eph_bt_b_size = 0; }
    if (ocl_eph_bm_r) { clReleaseMemObject(ocl_eph_bm_r); ocl_eph_bm_r = NULL; ocl_eph_bm_r_size = 0; }
    if (ocl_eph_bs) { clReleaseMemObject(ocl_eph_bs); ocl_eph_bs = NULL; ocl_eph_bs_size = 0; }
    if (ocl_eph_ga_qi) { clReleaseMemObject(ocl_eph_ga_qi); ocl_eph_ga_qi = NULL; ocl_eph_ga_qi_size = 0; }
    if (ocl_eph_ga_qd) { clReleaseMemObject(ocl_eph_ga_qd); ocl_eph_ga_qd = NULL; ocl_eph_ga_qd_size = 0; }
    if (ocl_eph_ga_ds) { clReleaseMemObject(ocl_eph_ga_ds); ocl_eph_ga_ds = NULL; ocl_eph_ga_ds_size = 0; }
    if (ocl_eph_ga_is) { clReleaseMemObject(ocl_eph_ga_is); ocl_eph_ga_is = NULL; ocl_eph_ga_is_size = 0; }
    if (ocl_eph_ga_gm) { clReleaseMemObject(ocl_eph_ga_gm); ocl_eph_ga_gm = NULL; ocl_eph_ga_gm_size = 0; }
    if (ocl_eph_bb_dq) { clReleaseMemObject(ocl_eph_bb_dq); ocl_eph_bb_dq = NULL; ocl_eph_bb_dq_size = 0; }
    if (ocl_eph_bb_bs) { clReleaseMemObject(ocl_eph_bb_bs); ocl_eph_bb_bs = NULL; ocl_eph_bb_bs_size = 0; }
    if (ocl_eph_bb_di) { clReleaseMemObject(ocl_eph_bb_di); ocl_eph_bb_di = NULL; ocl_eph_bb_di_size = 0; }
    if (ocl_eph_bwdq) { clReleaseMemObject(ocl_eph_bwdq); ocl_eph_bwdq = NULL; ocl_eph_bwdq_size = 0; }
    if (ocl_eph_bm_c) { clReleaseMemObject(ocl_eph_bm_c); ocl_eph_bm_c = NULL; ocl_eph_bm_c_size = 0; }
    if (ocl_eph_att_q) { clReleaseMemObject(ocl_eph_att_q); ocl_eph_att_q = NULL; ocl_eph_att_q_size = 0; }
    if (ocl_eph_att_out) { clReleaseMemObject(ocl_eph_att_out); ocl_eph_att_out = NULL; ocl_eph_att_out_size = 0; }
    if (ocl_eph_att_datt) { clReleaseMemObject(ocl_eph_att_datt); ocl_eph_att_datt = NULL; ocl_eph_att_datt_size = 0; }
    if (ocl_eph_att_dq) { clReleaseMemObject(ocl_eph_att_dq); ocl_eph_att_dq = NULL; ocl_eph_att_dq_size = 0; }
    if (ocl_eph_att_scores) { clReleaseMemObject(ocl_eph_att_scores); ocl_eph_att_scores = NULL; ocl_eph_att_scores_size = 0; }
    if (ocl_eph_att_ds) { clReleaseMemObject(ocl_eph_att_ds); ocl_eph_att_ds = NULL; ocl_eph_att_ds_size = 0; }
    if (ocl_eph_act_i8) { clReleaseMemObject(ocl_eph_act_i8); ocl_eph_act_i8 = NULL; ocl_eph_act_i8_size = 0; }
    if (ocl_eph_bm_i8) { clReleaseMemObject(ocl_eph_bm_i8); ocl_eph_bm_i8 = NULL; ocl_eph_bm_i8_size = 0; }
    if (ocl_eph_bm_sc) { clReleaseMemObject(ocl_eph_bm_sc); ocl_eph_bm_sc = NULL; ocl_eph_bm_sc_size = 0; }

    if (ocl_kernel_gemm_f) clReleaseKernel(ocl_kernel_gemm_f);
    if (ocl_kernel_gemm_t) clReleaseKernel(ocl_kernel_gemm_t);
    if (ocl_kernel_gemm_g) clReleaseKernel(ocl_kernel_gemm_g);
    if (ocl_kernel_matvec_t) clReleaseKernel(ocl_kernel_matvec_t);
    if (ocl_kernel_grad_acc) clReleaseKernel(ocl_kernel_grad_acc);
    if (ocl_kernel_matvec) clReleaseKernel(ocl_kernel_matvec);
    if (ocl_kernel_adam) clReleaseKernel(ocl_kernel_adam);
    if (ocl_kernel_att_fwd) clReleaseKernel(ocl_kernel_att_fwd);
    if (ocl_kernel_att_bwd) clReleaseKernel(ocl_kernel_att_bwd);
    if (ocl_kernel_att_fwd_b) clReleaseKernel(ocl_kernel_att_fwd_b);
    if (ocl_kernel_att_bwd_q) clReleaseKernel(ocl_kernel_att_bwd_q);
    if (ocl_kernel_att_bwd_k) clReleaseKernel(ocl_kernel_att_bwd_k);
    if (ocl_kernel_matvec_i8) clReleaseKernel(ocl_kernel_matvec_i8);
    if (ocl_kernel_adam_i8) clReleaseKernel(ocl_kernel_adam_i8);
    if (ocl_kernel_matvec_t_i8) clReleaseKernel(ocl_kernel_matvec_t_i8);
    if (ocl_kernel_gemm_f_i8) clReleaseKernel(ocl_kernel_gemm_f_i8);
    if (ocl_kernel_gemm_t_i8) clReleaseKernel(ocl_kernel_gemm_t_i8);
    if (ocl_kernel_bw_din_i8) clReleaseKernel(ocl_kernel_bw_din_i8);
    if (ocl_queue) clReleaseCommandQueue(ocl_queue);
    if (ocl_ctx) clReleaseContext(ocl_ctx);

    ocl_kernel_matvec = NULL; ocl_kernel_adam = NULL; ocl_kernel_att_fwd = NULL; ocl_kernel_att_bwd = NULL;
    ocl_kernel_att_fwd_b = NULL; ocl_kernel_att_bwd_q = NULL; ocl_kernel_att_bwd_k = NULL;
    ocl_kernel_matvec_i8 = NULL; ocl_kernel_adam_i8 = NULL; ocl_kernel_matvec_t_i8 = NULL;
    ocl_kernel_gemm_f_i8 = NULL; ocl_kernel_gemm_t_i8 = NULL; ocl_kernel_bw_din_i8 = NULL;
    ocl_queue = NULL; ocl_ctx = NULL;
    atomic_store(&ocl_initialized, 0); 
    fprintf(stderr, "⚡ [SYMBIO VRAM] OpenCL-Ressourcen & Registry freigegeben.\n");
}

int init_opencl_engine() {
    if (atomic_load(&ocl_initialized)) return 1; 
    int expected = 0;
    if (!atomic_compare_exchange_strong(&ocl_initialized, &expected, 1)) return 0; 
    {   // OCL-ADAM: rusticl meldet double nur mit RUSTICL_FEATURES=fp64
        const char* ga = getenv("SNAI_I8_GPU_ADAM");
        const char* at = getenv("SNAI_I8_ATT_GPU");   // OCL-ATT: Vorgabe an
        if (((ga && (ga[0] == '1' || ga[0] == '2')) || !(at && strcmp(at, "0") == 0)) && !getenv("RUSTICL_FEATURES"))
            setenv("RUSTICL_FEATURES", "fp64", 0);
    }

    cl_uint num_platforms = 0;
    cl_int err = clGetPlatformIDs(0, NULL, &num_platforms);
    if (err != CL_SUCCESS || num_platforms == 0) return 0;

    cl_platform_id* platforms = (cl_platform_id*)malloc(sizeof(cl_platform_id) * num_platforms);
    clGetPlatformIDs(num_platforms, platforms, NULL);

    cl_device_id target_device = NULL;
    for (cl_uint i = 0; i < num_platforms; i++) {
        cl_uint num_devices = 0;
        err = clGetDeviceIDs(platforms[i], CL_DEVICE_TYPE_GPU, 1, &target_device, &num_devices);
        if (err == CL_SUCCESS && num_devices > 0 && target_device != NULL) break;
    }

    // AUDIT-FIX: manche Treiber (z.B. Mesa RustiCL fuer AMD-APUs) melden ihr
    // GPU-Geraet als CL_DEVICE_TYPE_CUSTOM statt CL_DEVICE_TYPE_GPU - der obige
    // Filter liefert dann still err=-1/count=0 und init_opencl_engine() gibt
    // ohne jede Meldung 0 zurueck ("GPU wird nicht erkannt", verifiziert per
    // eigenem clGetDeviceInfo-Test: raw_type=CL_DEVICE_TYPE_CUSTOM auf diesem
    // System). Fallback: erstes Nicht-CPU-Geraet nehmen, wenn kein offiziell
    // deklariertes CL_DEVICE_TYPE_GPU gefunden wurde.
    if (target_device == NULL) {
        cl_platform_id* fb_platforms = (cl_platform_id*)malloc(sizeof(cl_platform_id) * num_platforms);
        clGetPlatformIDs(num_platforms, fb_platforms, NULL);
        for (cl_uint i = 0; i < num_platforms && target_device == NULL; i++) {
            cl_uint num_devices = 0;
            clGetDeviceIDs(fb_platforms[i], CL_DEVICE_TYPE_ALL, 0, NULL, &num_devices);
            if (num_devices == 0) continue;
            cl_device_id* devices = (cl_device_id*)malloc(sizeof(cl_device_id) * num_devices);
            clGetDeviceIDs(fb_platforms[i], CL_DEVICE_TYPE_ALL, num_devices, devices, NULL);
            for (cl_uint j = 0; j < num_devices; j++) {
                cl_device_type t;
                clGetDeviceInfo(devices[j], CL_DEVICE_TYPE, sizeof(t), &t, NULL);
                if (!(t & CL_DEVICE_TYPE_CPU)) {
                    target_device = devices[j];
                    fprintf(stderr, "⚡ [SYMBIO VRAM] Kein CL_DEVICE_TYPE_GPU gemeldet, nutze Nicht-CPU-Geraet als Fallback (Treiber-Quirk, z.B. Mesa RustiCL).\n");
                    break;
                }
            }
            free(devices);
        }
        free(fb_platforms);
    }

    free(platforms);

    if (target_device == NULL) return 0;
    
    {   // OCL-ZC: gemeinsamen Speicher abfragen, bevor der erste Puffer entsteht
        cl_bool um = CL_FALSE;
        clGetDeviceInfo(target_device, CL_DEVICE_HOST_UNIFIED_MEMORY, sizeof(um), &um, NULL);
        const char* z = getenv("SNAI_OCL_ZC");
        if (z && strcmp(z, "0") == 0) ocl_zc = 0;
        else if (z && strcmp(z, "2") == 0) ocl_zc = 1;
        else ocl_zc = um ? 1 : 0;
        fprintf(stderr, "[OCL-ZC] Puffer %s (Geraet meldet gemeinsamen Speicher: %s)\n",
                ocl_zc ? "im gemeinsamen Speicher, Map statt Kopie" : "mit Treiberkopie", um ? "ja" : "nein");
    }
    ocl_ctx = clCreateContext(NULL, 1, &target_device, NULL, NULL, &err);
    if (err != CL_SUCCESS) return 0;

    ocl_queue = clCreateCommandQueue(ocl_ctx, target_device, ocl_prof_get() ? CL_QUEUE_PROFILING_ENABLE : 0, &err);   // OCL-PROF 
    if (err != CL_SUCCESS) { shutdown_opencl_engine(); return 0; }
    
    cl_program program = clCreateProgramWithSource(ocl_ctx, 1, (const char **)&kernel_source, NULL, &err);
    // FIX 6: Program Null Check
    if (err != CL_SUCCESS || !program) { shutdown_opencl_engine(); return 0; }

    cl_int build_status = clBuildProgram(program, 1, &target_device, NULL, NULL, NULL);
    
    if (build_status != CL_SUCCESS) {
        size_t log_size;
        clGetProgramBuildInfo(program, target_device, CL_PROGRAM_BUILD_LOG, 0, NULL, &log_size);
        char* log = (char*)malloc(log_size + 1);
        clGetProgramBuildInfo(program, target_device, CL_PROGRAM_BUILD_LOG, log_size, log, NULL);
        log[log_size] = '\0';
        fprintf(stderr, "🚨 [SYMBIO GPU] JIT Kernel Kompilierung fehlgeschlagen!\n%s\n", log);
        free(log);
        clReleaseProgram(program);
        shutdown_opencl_engine();
        return 0;
    }

    ocl_kernel_matvec = clCreateKernel(program, "matVecMul", &err);
    ocl_kernel_adam = clCreateKernel(program, "adamUpdate", &err);
    ocl_kernel_att_fwd = clCreateKernel(program, "attentionForward", &err);
    ocl_kernel_att_bwd = clCreateKernel(program, "attentionBackward", &err);
    ocl_kernel_matvec_t = clCreateKernel(program, "matVecMulT", &err);
    ocl_kernel_grad_acc = clCreateKernel(program, "gradAccum", &err);
    ocl_kernel_gemm_f = clCreateKernel(program, "matMulBatched", &err);
    ocl_kernel_gemm_t = clCreateKernel(program, "matMulTBatched", &err);
    ocl_kernel_gemm_g = clCreateKernel(program, "gradAccumBatched", &err);
    ocl_kernel_att_fwd_b = clCreateKernel(program, "attentionForwardBatched", &err);
    ocl_kernel_att_bwd_q = clCreateKernel(program, "attentionBackwardBatchedQuery", &err);
    ocl_kernel_att_bwd_k = clCreateKernel(program, "attentionBackwardBatchedKey", &err);
    ocl_kernel_matvec_i8 = clCreateKernel(program, "matVecMulI8", &err);
    ocl_kernel_adam_i8 = clCreateKernel(program, "adamUpdateI8", &err);
    ocl_kernel_adam_row_i8 = clCreateKernel(program, "adamRowFloatI8", &err);
    ocl_kernel_matvec_t_i8 = clCreateKernel(program, "matVecMulTI8", &err);
    ocl_kernel_gemm_f_i8 = clCreateKernel(program, "matMulBatchedI8", &err);
    ocl_kernel_gemm_t_i8 = clCreateKernel(program, "matMulTBatchedI8", &err);
    ocl_kernel_bw_din_i8 = clCreateKernel(program, "backwardDInI8", &err);
    ocl_kernel_gradacc_i8 = clCreateKernel(program, "gradAccumI8", &err);
    ocl_kernel_bw_din_i8_b = clCreateKernel(program, "backwardDInI8Batched", &err);
    {   // OCL-BW-KACHEL: eigene Fehlervariable, ein Fehlschlag hier schaltet nur die Kachel ab
        cl_int e2 = CL_SUCCESS; size_t kwg = 0;
        ocl_kernel_bw_tiled = clCreateKernel(program, "backwardDInI8BatchedTiled", &e2);
        if (e2 != CL_SUCCESS || clGetKernelWorkGroupInfo(ocl_kernel_bw_tiled, target_device, CL_KERNEL_WORK_GROUP_SIZE,
                sizeof(size_t), &kwg, NULL) != CL_SUCCESS || kwg < 256) ocl_kernel_bw_tiled = NULL;
        e2 = CL_SUCCESS; kwg = 0;
        ocl_kernel_ga_tiled = clCreateKernel(program, "gradAccumI8Tiled", &e2);
        if (e2 != CL_SUCCESS || clGetKernelWorkGroupInfo(ocl_kernel_ga_tiled, target_device, CL_KERNEL_WORK_GROUP_SIZE,
                sizeof(size_t), &kwg, NULL) != CL_SUCCESS || kwg < 256) ocl_kernel_ga_tiled = NULL;
    }
    clReleaseProgram(program);
    
    if (err != CL_SUCCESS) { shutdown_opencl_engine(); return 0; }

    size_t hw_max_wg;
    if (clGetDeviceInfo(target_device, CL_DEVICE_MAX_WORK_GROUP_SIZE, sizeof(size_t), &hw_max_wg, NULL) == CL_SUCCESS) {
        ocl_max_work_group_size = (hw_max_wg < 64) ? hw_max_wg : 64;
    }
    
    char deviceName[256];
    clGetDeviceInfo(target_device, CL_DEVICE_NAME, sizeof(deviceName), deviceName, NULL);
    fprintf(stderr, "⚡ [SYMBIO VRAM] Stateful OpenCL JIT eingerastet auf: [%s]\n", deviceName);
    ocl_fwd_build(target_device);   // OCL-FWD
    ocl_adam_q_build(target_device);
    return 1;
}

void ocl_matVecMul(const float* h_M, const float* h_v, float* h_out, int rows, int cols) {
    if (!ocl_ctx || !h_M || !h_v || !h_out || rows == 0 || cols == 0) return;

    size_t size_M = (size_t)rows * (size_t)cols * sizeof(float);
    size_t size_v = (size_t)cols * sizeof(float);
    size_t size_out = (size_t)rows * sizeof(float);

    cl_mem d_M = ocl_get_buffer((void*)h_M, size_M);
    if (!d_M) return;

    cl_int err = CL_SUCCESS;
    // FIX 4: Robust Buffer Resize
    if (ocl_eph_v_size < size_v) {
        if (ocl_eph_v) clReleaseMemObject(ocl_eph_v);
        ocl_eph_v = ocl_mk(ocl_ctx, CL_MEM_READ_WRITE, size_v, NULL, &err);
        ocl_eph_v_size = (err == CL_SUCCESS) ? size_v : 0;
    }
    if (ocl_eph_out_size < size_out) {
        if (ocl_eph_out) clReleaseMemObject(ocl_eph_out);
        ocl_eph_out = ocl_mk(ocl_ctx, CL_MEM_READ_WRITE, size_out, NULL, &err);
        ocl_eph_out_size = (err == CL_SUCCESS) ? size_out : 0;
    }
    if (!ocl_eph_v || !ocl_eph_out) return;

    ocl_wr(ocl_queue, ocl_eph_v, CL_FALSE, 0, size_v, h_v, 0, NULL, NULL);

    err  = clSetKernelArg(ocl_kernel_matvec, 0, sizeof(cl_mem), (void *)&d_M);
    err |= clSetKernelArg(ocl_kernel_matvec, 1, sizeof(cl_mem), (void *)&ocl_eph_v);
    err |= clSetKernelArg(ocl_kernel_matvec, 2, sizeof(cl_mem), (void *)&ocl_eph_out);
    err |= clSetKernelArg(ocl_kernel_matvec, 3, sizeof(int), (void *)&rows);
    err |= clSetKernelArg(ocl_kernel_matvec, 4, sizeof(int), (void *)&cols);
    if (err != CL_SUCCESS) return;

    size_t local_item_size = ocl_max_work_group_size; 
    size_t global_item_size = (((size_t)rows + local_item_size - 1) / local_item_size) * local_item_size;

    ocl_nd(ocl_queue, ocl_kernel_matvec, 1, NULL, &global_item_size, &local_item_size, 0, NULL, NULL);
    ocl_rd(ocl_queue, ocl_eph_out, CL_TRUE, 0, size_out, h_out, 0, NULL, NULL);
}

void ocl_attentionForward(const float* h_q, const float* h_k_cache, const float* h_v_cache, float* h_out, int pos, int numHeads, int headSize, int dim, int ctx) {
    if (!ocl_ctx || pos >= ctx) return; 
    
    size_t size_cache = (size_t)ctx * dim * sizeof(float);
    size_t size_vec = (size_t)dim * sizeof(float);
    size_t size_scores = (size_t)numHeads * ctx * sizeof(float);
    
    cl_mem d_k = ocl_get_buffer((void*)h_k_cache, size_cache);
    cl_mem d_v = ocl_get_buffer((void*)h_v_cache, size_cache);
    if (!d_k || !d_v) return; 
    
    size_t offset = (size_t)pos * dim * sizeof(float);
    ocl_wr(ocl_queue, d_k, CL_FALSE, offset, size_vec, h_k_cache + (pos * dim), 0, NULL, NULL);
    ocl_wr(ocl_queue, d_v, CL_FALSE, offset, size_vec, h_v_cache + (pos * dim), 0, NULL, NULL);
    
    cl_int err = CL_SUCCESS;
    // FIX 4: Robust Buffer Resize
    if (ocl_eph_v_size < size_vec) {
        if (ocl_eph_v) clReleaseMemObject(ocl_eph_v);
        ocl_eph_v = ocl_mk(ocl_ctx, CL_MEM_READ_WRITE, size_vec, NULL, &err); 
        ocl_eph_v_size = (err == CL_SUCCESS) ? size_vec : 0;
    }
    if (ocl_eph_out_size < size_vec) {
        if (ocl_eph_out) clReleaseMemObject(ocl_eph_out);
        ocl_eph_out = ocl_mk(ocl_ctx, CL_MEM_READ_WRITE, size_vec, NULL, &err); 
        ocl_eph_out_size = (err == CL_SUCCESS) ? size_vec : 0;
    }
    if (ocl_eph_scores_size < size_scores) {
        if (ocl_eph_scores) clReleaseMemObject(ocl_eph_scores);
        ocl_eph_scores = ocl_mk(ocl_ctx, CL_MEM_READ_WRITE, size_scores, NULL, &err); 
        ocl_eph_scores_size = (err == CL_SUCCESS) ? size_scores : 0;
    }
    if (!ocl_eph_v || !ocl_eph_out || !ocl_eph_scores) return;
    
    ocl_wr(ocl_queue, ocl_eph_v, CL_FALSE, 0, size_vec, h_q, 0, NULL, NULL);
    
    err  = clSetKernelArg(ocl_kernel_att_fwd, 0, sizeof(cl_mem), &ocl_eph_v);
    err |= clSetKernelArg(ocl_kernel_att_fwd, 1, sizeof(cl_mem), &d_k);
    err |= clSetKernelArg(ocl_kernel_att_fwd, 2, sizeof(cl_mem), &d_v);
    err |= clSetKernelArg(ocl_kernel_att_fwd, 3, sizeof(cl_mem), &ocl_eph_out);
    err |= clSetKernelArg(ocl_kernel_att_fwd, 4, sizeof(cl_mem), &ocl_eph_scores);
    err |= clSetKernelArg(ocl_kernel_att_fwd, 5, sizeof(int), &pos);
    err |= clSetKernelArg(ocl_kernel_att_fwd, 6, sizeof(int), &numHeads);
    err |= clSetKernelArg(ocl_kernel_att_fwd, 7, sizeof(int), &headSize);
    err |= clSetKernelArg(ocl_kernel_att_fwd, 8, sizeof(int), &dim);
    err |= clSetKernelArg(ocl_kernel_att_fwd, 9, sizeof(int), &ctx);
    if (err != CL_SUCCESS) return;
    
    size_t global_item_size = numHeads;
    ocl_nd(ocl_queue, ocl_kernel_att_fwd, 1, NULL, &global_item_size, NULL, 0, NULL, NULL);
    ocl_rd(ocl_queue, ocl_eph_out, CL_TRUE, 0, size_vec, h_out, 0, NULL, NULL);
}

void ocl_attentionBackward(const float* h_q, const float* h_k_cache, const float* h_v_cache, const float* h_d_att_out,
                           float* h_d_q, float* h_d_k_cache, float* h_d_v_cache, 
                           int pos, int numHeads, int headSize, int dim, int ctx) {
    if (!ocl_ctx || pos >= ctx) return; 
    
    size_t size_cache = (size_t)ctx * dim * sizeof(float);
    size_t size_vec = (size_t)dim * sizeof(float);
    size_t size_scores = (size_t)numHeads * ctx * sizeof(float);
    
    cl_mem d_k = ocl_get_buffer((void*)h_k_cache, size_cache);
    cl_mem d_v = ocl_get_buffer((void*)h_v_cache, size_cache);
    cl_mem d_dk = ocl_get_buffer((void*)h_d_k_cache, size_cache);
    cl_mem d_dv = ocl_get_buffer((void*)h_d_v_cache, size_cache);
    if (!d_k || !d_v || !d_dk || !d_dv) return;
    
    cl_int err = CL_SUCCESS;
    // FIX 4: Robust Buffer Resize
    if (ocl_eph_v_size < size_vec) {
        if (ocl_eph_v) clReleaseMemObject(ocl_eph_v);
        ocl_eph_v = ocl_mk(ocl_ctx, CL_MEM_READ_WRITE, size_vec, NULL, &err); 
        ocl_eph_v_size = (err == CL_SUCCESS) ? size_vec : 0;
    }
    if (ocl_eph_out_size < size_vec) {
        if (ocl_eph_out) clReleaseMemObject(ocl_eph_out);
        ocl_eph_out = ocl_mk(ocl_ctx, CL_MEM_READ_WRITE, size_vec, NULL, &err); 
        ocl_eph_out_size = (err == CL_SUCCESS) ? size_vec : 0;
    }
    if (ocl_eph_dq_size < size_vec) {
        if (ocl_eph_dq) clReleaseMemObject(ocl_eph_dq);
        ocl_eph_dq = ocl_mk(ocl_ctx, CL_MEM_READ_WRITE, size_vec, NULL, &err); 
        ocl_eph_dq_size = (err == CL_SUCCESS) ? size_vec : 0;
    }
    if (ocl_eph_scores_size < size_scores) {
        if (ocl_eph_scores) clReleaseMemObject(ocl_eph_scores);
        ocl_eph_scores = ocl_mk(ocl_ctx, CL_MEM_READ_WRITE, size_scores, NULL, &err); 
        ocl_eph_scores_size = (err == CL_SUCCESS) ? size_scores : 0;
    }
    if (ocl_eph_dw_size < size_scores) {
        if (ocl_eph_dw) clReleaseMemObject(ocl_eph_dw);
        ocl_eph_dw = ocl_mk(ocl_ctx, CL_MEM_READ_WRITE, size_scores, NULL, &err); 
        ocl_eph_dw_size = (err == CL_SUCCESS) ? size_scores : 0;
    }
    if (!ocl_eph_v || !ocl_eph_out || !ocl_eph_dq || !ocl_eph_scores || !ocl_eph_dw) return;
    
    ocl_wr(ocl_queue, ocl_eph_v, CL_FALSE, 0, size_vec, h_q, 0, NULL, NULL);
    ocl_wr(ocl_queue, ocl_eph_out, CL_FALSE, 0, size_vec, h_d_att_out, 0, NULL, NULL);
    
    // FIX 5: Toter Host-to-Device Copy für h_d_q entfernt (wird ohnehin im Kernel überschrieben)
    
    err  = clSetKernelArg(ocl_kernel_att_bwd, 0, sizeof(cl_mem), &ocl_eph_v);
    err |= clSetKernelArg(ocl_kernel_att_bwd, 1, sizeof(cl_mem), &d_k);
    err |= clSetKernelArg(ocl_kernel_att_bwd, 2, sizeof(cl_mem), &d_v);
    err |= clSetKernelArg(ocl_kernel_att_bwd, 3, sizeof(cl_mem), &ocl_eph_out);
    err |= clSetKernelArg(ocl_kernel_att_bwd, 4, sizeof(cl_mem), &ocl_eph_dq);
    err |= clSetKernelArg(ocl_kernel_att_bwd, 5, sizeof(cl_mem), &d_dk);
    err |= clSetKernelArg(ocl_kernel_att_bwd, 6, sizeof(cl_mem), &d_dv);
    err |= clSetKernelArg(ocl_kernel_att_bwd, 7, sizeof(cl_mem), &ocl_eph_scores);
    err |= clSetKernelArg(ocl_kernel_att_bwd, 8, sizeof(cl_mem), &ocl_eph_dw);
    err |= clSetKernelArg(ocl_kernel_att_bwd, 9, sizeof(int), &pos);
    err |= clSetKernelArg(ocl_kernel_att_bwd, 10, sizeof(int), &numHeads);
    err |= clSetKernelArg(ocl_kernel_att_bwd, 11, sizeof(int), &headSize);
    err |= clSetKernelArg(ocl_kernel_att_bwd, 12, sizeof(int), &dim);
    err |= clSetKernelArg(ocl_kernel_att_bwd, 13, sizeof(int), &ctx);
    if (err != CL_SUCCESS) return;
    
    size_t global_item_size = numHeads;
    ocl_nd(ocl_queue, ocl_kernel_att_bwd, 1, NULL, &global_item_size, NULL, 0, NULL, NULL);
    
    ocl_rd(ocl_queue, ocl_eph_dq, CL_FALSE, 0, size_vec, h_d_q, 0, NULL, NULL);
    size_t offset = (size_t)pos * dim * sizeof(float);
    ocl_rd(ocl_queue, d_dk, CL_FALSE, offset, size_vec, h_d_k_cache + (pos * dim), 0, NULL, NULL);
    ocl_rd(ocl_queue, d_dv, CL_FALSE, offset, size_vec, h_d_v_cache + (pos * dim), 0, NULL, NULL);

    clFinish(ocl_queue);
}

// ==============================================================================
// V8.5 BACKWARD OFFLOAD
// d_in = M^T * d_out   und   gm += d_out (x) i_v
// gm bleibt persistent im VRAM und akkumuliert ueber alle Token eines Steps.
// Der Host holt sie einmal pro Step per ocl_sync_to_host ab - kein Transfer
// pro Token. Nur die kleinen Vektoren wandern hin und her.
// ==============================================================================
static int ocl_eph_bt_ensure(cl_mem* buf, size_t* cur, size_t need) {
    if (*cur >= need) return 1;
    cl_int err;
    if (*buf) clReleaseMemObject(*buf);
    *buf = ocl_mk(ocl_ctx, CL_MEM_READ_WRITE, need, NULL, &err);
    *cur = (err == CL_SUCCESS) ? need : 0;
    return (err == CL_SUCCESS);
}

void ocl_matVecMulT(const float* h_M, const float* h_d_out, float* h_d_in, int rows, int cols, int accumulate) {
    if (!ocl_ctx || !h_M || !h_d_out || !h_d_in || rows == 0 || cols == 0) return;

    size_t size_M   = (size_t)rows * (size_t)cols * sizeof(float);
    size_t size_out = (size_t)rows * sizeof(float);
    size_t size_in  = (size_t)cols * sizeof(float);

    cl_mem d_M = ocl_get_buffer((void*)h_M, size_M);
    if (!d_M) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bt_a, &ocl_eph_bt_a_size, size_out)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bt_b, &ocl_eph_bt_b_size, size_in)) return;

    ocl_wr(ocl_queue, ocl_eph_bt_a, CL_FALSE, 0, size_out, h_d_out, 0, NULL, NULL);
    if (accumulate == 1) {
        ocl_wr(ocl_queue, ocl_eph_bt_b, CL_FALSE, 0, size_in, h_d_in, 0, NULL, NULL);
    }

    cl_int err;
    err  = clSetKernelArg(ocl_kernel_matvec_t, 0, sizeof(cl_mem), (void *)&d_M);
    err |= clSetKernelArg(ocl_kernel_matvec_t, 1, sizeof(cl_mem), (void *)&ocl_eph_bt_a);
    err |= clSetKernelArg(ocl_kernel_matvec_t, 2, sizeof(cl_mem), (void *)&ocl_eph_bt_b);
    err |= clSetKernelArg(ocl_kernel_matvec_t, 3, sizeof(int), (void *)&rows);
    err |= clSetKernelArg(ocl_kernel_matvec_t, 4, sizeof(int), (void *)&cols);
    err |= clSetKernelArg(ocl_kernel_matvec_t, 5, sizeof(int), (void *)&accumulate);
    if (err != CL_SUCCESS) return;

    size_t local_item_size = ocl_max_work_group_size;
    size_t global_item_size = (((size_t)cols + local_item_size - 1) / local_item_size) * local_item_size;
    ocl_nd(ocl_queue, ocl_kernel_matvec_t, 1, NULL, &global_item_size, &local_item_size, 0, NULL, NULL);
    ocl_rd(ocl_queue, ocl_eph_bt_b, CL_TRUE, 0, size_in, h_d_in, 0, NULL, NULL);
}

void ocl_gradAccum(float* h_gm, const float* h_d_out, const float* h_i_v, int rows, int cols) {
    if (!ocl_ctx || !h_gm || !h_d_out || !h_i_v || rows == 0 || cols == 0) return;

    size_t size_gm  = (size_t)rows * (size_t)cols * sizeof(float);
    size_t size_out = (size_t)rows * sizeof(float);
    size_t size_in  = (size_t)cols * sizeof(float);

    cl_mem d_gm = ocl_get_buffer((void*)h_gm, size_gm);
    if (!d_gm) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bt_a, &ocl_eph_bt_a_size, size_out)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bt_b, &ocl_eph_bt_b_size, size_in)) return;

    // CL_TRUE ist hier Pflicht: gradAccum hat am Ende KEINEN blockierenden Read.
    // Mit CL_FALSE koennte der Host d_out/i_v ueberschreiben, bevor die Kopie lief.
    ocl_wr(ocl_queue, ocl_eph_bt_a, CL_TRUE, 0, size_out, h_d_out, 0, NULL, NULL);
    ocl_wr(ocl_queue, ocl_eph_bt_b, CL_TRUE, 0, size_in, h_i_v, 0, NULL, NULL);

    cl_int err;
    err  = clSetKernelArg(ocl_kernel_grad_acc, 0, sizeof(cl_mem), (void *)&d_gm);
    err |= clSetKernelArg(ocl_kernel_grad_acc, 1, sizeof(cl_mem), (void *)&ocl_eph_bt_a);
    err |= clSetKernelArg(ocl_kernel_grad_acc, 2, sizeof(cl_mem), (void *)&ocl_eph_bt_b);
    err |= clSetKernelArg(ocl_kernel_grad_acc, 3, sizeof(int), (void *)&rows);
    err |= clSetKernelArg(ocl_kernel_grad_acc, 4, sizeof(int), (void *)&cols);
    if (err != CL_SUCCESS) return;

    size_t local2[2]  = { ocl_max_work_group_size, 1 };
    size_t global2[2] = { (((size_t)cols + local2[0] - 1) / local2[0]) * local2[0], (size_t)rows };
    ocl_nd(ocl_queue, ocl_kernel_grad_acc, 2, NULL, global2, local2, 0, NULL, NULL);
    // Kein Readback: gm bleibt im VRAM und akkumuliert weiter.
}

// ==============================================================================
// V8.6 ETAPPE 1 - BATCHING UEBER DIE POSITIONSACHSE
// Layout durchgehend row-major: IN[p*cols + c], OUT[p*rows + r].
// Das ist exakt die Geometrie der bestehenden act_*-Caches (pos * dim).
// Bewusst ephemer: Upload rein, Kernel, Download raus. Kein Buffer bleibt
// zwischen den Aufrufen gueltig -> keine Host/Device-Staleness moeglich.
// ==============================================================================
void ocl_matMulBatched(const float* h_M, const float* h_in, float* h_out, int rows, int cols, int batch) {
    if (!ocl_ctx || !h_M || !h_in || !h_out || rows <= 0 || cols <= 0 || batch <= 0) return;
    size_t size_M = (size_t)rows * (size_t)cols * sizeof(float);
    size_t size_i = (size_t)batch * (size_t)cols * sizeof(float);
    size_t size_o = (size_t)batch * (size_t)rows * sizeof(float);

    cl_mem d_M = ocl_get_buffer((void*)h_M, size_M);
    if (!d_M) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bm_c, &ocl_eph_bm_c_size, size_i)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bm_r, &ocl_eph_bm_r_size, size_o)) return;

    ocl_wr(ocl_queue, ocl_eph_bm_c, CL_FALSE, 0, size_i, h_in, 0, NULL, NULL);

    cl_int err;
    err  = clSetKernelArg(ocl_kernel_gemm_f, 0, sizeof(cl_mem), (void*)&d_M);
    err |= clSetKernelArg(ocl_kernel_gemm_f, 1, sizeof(cl_mem), (void*)&ocl_eph_bm_c);
    err |= clSetKernelArg(ocl_kernel_gemm_f, 2, sizeof(cl_mem), (void*)&ocl_eph_bm_r);
    err |= clSetKernelArg(ocl_kernel_gemm_f, 3, sizeof(int), (void*)&rows);
    err |= clSetKernelArg(ocl_kernel_gemm_f, 4, sizeof(int), (void*)&cols);
    err |= clSetKernelArg(ocl_kernel_gemm_f, 5, sizeof(int), (void*)&batch);
    if (err != CL_SUCCESS) return;

    size_t local2[2]  = { ocl_max_work_group_size, 1 };
    size_t global2[2] = { (((size_t)rows + local2[0] - 1) / local2[0]) * local2[0], (size_t)batch };
    ocl_nd(ocl_queue, ocl_kernel_gemm_f, 2, NULL, global2, local2, 0, NULL, NULL);
    ocl_rd(ocl_queue, ocl_eph_bm_r, CL_TRUE, 0, size_o, h_out, 0, NULL, NULL);
}

void ocl_matMulTBatched(const float* h_M, const float* h_d_out, float* h_d_in, int rows, int cols, int batch, int accumulate) {
    if (!ocl_ctx || !h_M || !h_d_out || !h_d_in || rows <= 0 || cols <= 0 || batch <= 0) return;
    size_t size_M = (size_t)rows * (size_t)cols * sizeof(float);
    size_t size_o = (size_t)batch * (size_t)rows * sizeof(float);
    size_t size_i = (size_t)batch * (size_t)cols * sizeof(float);

    cl_mem d_M = ocl_get_buffer((void*)h_M, size_M);
    if (!d_M) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bm_r, &ocl_eph_bm_r_size, size_o)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bm_c, &ocl_eph_bm_c_size, size_i)) return;

    ocl_wr(ocl_queue, ocl_eph_bm_r, CL_FALSE, 0, size_o, h_d_out, 0, NULL, NULL);
    if (accumulate == 1) {
        ocl_wr(ocl_queue, ocl_eph_bm_c, CL_FALSE, 0, size_i, h_d_in, 0, NULL, NULL);
    }

    cl_int err;
    err  = clSetKernelArg(ocl_kernel_gemm_t, 0, sizeof(cl_mem), (void*)&d_M);
    err |= clSetKernelArg(ocl_kernel_gemm_t, 1, sizeof(cl_mem), (void*)&ocl_eph_bm_r);
    err |= clSetKernelArg(ocl_kernel_gemm_t, 2, sizeof(cl_mem), (void*)&ocl_eph_bm_c);
    err |= clSetKernelArg(ocl_kernel_gemm_t, 3, sizeof(int), (void*)&rows);
    err |= clSetKernelArg(ocl_kernel_gemm_t, 4, sizeof(int), (void*)&cols);
    err |= clSetKernelArg(ocl_kernel_gemm_t, 5, sizeof(int), (void*)&batch);
    err |= clSetKernelArg(ocl_kernel_gemm_t, 6, sizeof(int), (void*)&accumulate);
    if (err != CL_SUCCESS) return;

    size_t local2[2]  = { ocl_max_work_group_size, 1 };
    size_t global2[2] = { (((size_t)cols + local2[0] - 1) / local2[0]) * local2[0], (size_t)batch };
    ocl_nd(ocl_queue, ocl_kernel_gemm_t, 2, NULL, global2, local2, 0, NULL, NULL);
    ocl_rd(ocl_queue, ocl_eph_bm_c, CL_TRUE, 0, size_i, h_d_in, 0, NULL, NULL);
}

void ocl_gradAccumBatched(float* h_gm, const float* h_d_out, const float* h_i_v, int rows, int cols, int batch) {
    if (!ocl_ctx || !h_gm || !h_d_out || !h_i_v || rows <= 0 || cols <= 0 || batch <= 0) return;
    size_t size_gm = (size_t)rows * (size_t)cols * sizeof(float);
    size_t size_o  = (size_t)batch * (size_t)rows * sizeof(float);
    size_t size_i  = (size_t)batch * (size_t)cols * sizeof(float);

    cl_mem d_gm = ocl_get_buffer((void*)h_gm, size_gm);
    if (!d_gm) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bm_r, &ocl_eph_bm_r_size, size_o)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bm_c, &ocl_eph_bm_c_size, size_i)) return;

    // CL_TRUE: dieser Aufruf endet ohne blockierenden Read, der Host darf die
    // Quellpuffer erst nach der Kopie wieder anfassen.
    ocl_wr(ocl_queue, ocl_eph_bm_r, CL_TRUE, 0, size_o, h_d_out, 0, NULL, NULL);
    ocl_wr(ocl_queue, ocl_eph_bm_c, CL_TRUE, 0, size_i, h_i_v, 0, NULL, NULL);

    cl_int err;
    err  = clSetKernelArg(ocl_kernel_gemm_g, 0, sizeof(cl_mem), (void*)&d_gm);
    err |= clSetKernelArg(ocl_kernel_gemm_g, 1, sizeof(cl_mem), (void*)&ocl_eph_bm_r);
    err |= clSetKernelArg(ocl_kernel_gemm_g, 2, sizeof(cl_mem), (void*)&ocl_eph_bm_c);
    err |= clSetKernelArg(ocl_kernel_gemm_g, 3, sizeof(int), (void*)&rows);
    err |= clSetKernelArg(ocl_kernel_gemm_g, 4, sizeof(int), (void*)&cols);
    err |= clSetKernelArg(ocl_kernel_gemm_g, 5, sizeof(int), (void*)&batch);
    if (err != CL_SUCCESS) return;

    size_t local2[2]  = { ocl_max_work_group_size, 1 };
    size_t global2[2] = { (((size_t)cols + local2[0] - 1) / local2[0]) * local2[0], (size_t)rows };
    ocl_nd(ocl_queue, ocl_kernel_gemm_g, 2, NULL, global2, local2, 0, NULL, NULL);
    // gm bleibt persistent im VRAM, Abholung wie bisher per ocl_sync_to_host.
}

// ==============================================================================
// AUDIT: GEBUENDELTE ATTENTION - ein Dispatch pro Layer statt 'act' einzelner.
// Ursache der urspruenglichen 20x-Verlangsamung auf schwachen/Treiber-limitierten
// GPUs: jede Position zahlte vollen Kernel-Launch + Transfer-Overhead inklusive
// eines BLOCKIERENDEN clEnqueueReadBuffer. Hier genau ein Upload, ein/zwei
// Kernel-Dispatches, ein Download fuer die GESAMTE Positionsachse.
// Erfordert layer-major statt position-major Aufrufreihenfolge im Trainings-Loop
// (siehe cortex.nim::cortex_train_step, batched_attention-Zweig): Q/K/V muessen
// fuer ALLE Positionen eines Layers feststehen, bevor Attention fuer eine davon
// berechnet wird.
// ==============================================================================
void ocl_attentionForwardBatched(const float* h_q_all, const float* h_k_cache, const float* h_v_cache,
                                  float* h_att_out_all, int act, int numHeads, int headSize, int dim, int ctx) {
    if (!ocl_ctx || !h_q_all || !h_k_cache || !h_v_cache || !h_att_out_all || act <= 0) return;

    size_t size_cache  = (size_t)ctx * (size_t)dim * sizeof(float);
    size_t size_qout   = (size_t)act * (size_t)dim * sizeof(float);
    size_t size_scores = (size_t)act * (size_t)numHeads * (size_t)ctx * sizeof(float);

    cl_mem d_k = ocl_get_buffer((void*)h_k_cache, size_cache);
    cl_mem d_v = ocl_get_buffer((void*)h_v_cache, size_cache);
    if (!d_k || !d_v) return;

    // AUDIT-FIX: ocl_get_buffer() laedt nur beim ERSTEN Aufruf fuer einen Host-
    // Pointer hoch, danach kommt stur der gecachte Device-Buffer zurueck - auch
    // wenn der Host-Inhalt sich (durch neue QKV-Berechnung im naechsten Trainings-
    // Schritt) laengst geaendert hat. Der alte Pro-Position-Pfad glich das mit
    // einem Write pro Aufruf aus (dort nur 1 Position gross); hier explizit fuer
    // alle 'act' Positionen. Ohne das driftet der Loss ab Schritt 2 (empirisch
    // verifiziert: 0.000000 Differenz mit diesem Fix, bis zu 0.013 ohne).
    ocl_wr(ocl_queue, d_k, CL_FALSE, 0, size_qout, h_k_cache, 0, NULL, NULL);
    ocl_wr(ocl_queue, d_v, CL_FALSE, 0, size_qout, h_v_cache, 0, NULL, NULL);

    if (!ocl_eph_bt_ensure(&ocl_eph_att_q, &ocl_eph_att_q_size, size_qout)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_att_out, &ocl_eph_att_out_size, size_qout)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_att_scores, &ocl_eph_att_scores_size, size_scores)) return;

    ocl_wr(ocl_queue, ocl_eph_att_q, CL_FALSE, 0, size_qout, h_q_all, 0, NULL, NULL);

    cl_int err;
    err  = clSetKernelArg(ocl_kernel_att_fwd_b, 0, sizeof(cl_mem), &ocl_eph_att_q);
    err |= clSetKernelArg(ocl_kernel_att_fwd_b, 1, sizeof(cl_mem), &d_k);
    err |= clSetKernelArg(ocl_kernel_att_fwd_b, 2, sizeof(cl_mem), &d_v);
    err |= clSetKernelArg(ocl_kernel_att_fwd_b, 3, sizeof(cl_mem), &ocl_eph_att_out);
    err |= clSetKernelArg(ocl_kernel_att_fwd_b, 4, sizeof(cl_mem), &ocl_eph_att_scores);
    err |= clSetKernelArg(ocl_kernel_att_fwd_b, 5, sizeof(int), &act);
    err |= clSetKernelArg(ocl_kernel_att_fwd_b, 6, sizeof(int), &numHeads);
    err |= clSetKernelArg(ocl_kernel_att_fwd_b, 7, sizeof(int), &headSize);
    err |= clSetKernelArg(ocl_kernel_att_fwd_b, 8, sizeof(int), &dim);
    err |= clSetKernelArg(ocl_kernel_att_fwd_b, 9, sizeof(int), &ctx);
    if (err != CL_SUCCESS) return;

    // AUDIT-FIX: ein einzelner Dispatch ueber alle 'act' Positionen liess bei
    // grossen Kontextlaengen (ctx=2048+) den GPU-Job so lange laufen, dass der
    // AMDGPU-Watchdog die Compute-Ring als haengengeblieben eingestuft und den
    // Context gekillt hat ("ring timeout", Absturz beim Matriarchin-Fine-Tuning,
    // 2026-08-03). Work-Items sind pro Position unabhaengig (schreiben nur in
    // ihr eigenes p-Segment von att_out/scores) - der Dispatch laesst sich daher
    // gefahrlos in kurze Positions-Bloecke aufteilen.
    for (size_t p0 = 0; p0 < (size_t)act; p0 += ATT_POS_CHUNK) {
        size_t chunkLen = ((size_t)act - p0) < ATT_POS_CHUNK ? ((size_t)act - p0) : ATT_POS_CHUNK;
        size_t offset2b[2] = { 0, p0 };
        size_t global2b[2] = { (size_t)numHeads, chunkLen };
        ocl_nd(ocl_queue, ocl_kernel_att_fwd_b, 2, offset2b, global2b, NULL, 0, NULL, NULL);
    }
    ocl_rd(ocl_queue, ocl_eph_att_out, CL_TRUE, 0, size_qout, h_att_out_all, 0, NULL, NULL);
}

void ocl_attentionBackwardBatched(const float* h_q_all, const float* h_k_cache, const float* h_v_cache,
                                   const float* h_d_att_out_all, float* h_d_q_all,
                                   float* h_d_k_cache, float* h_d_v_cache,
                                   int act, int numHeads, int headSize, int dim, int ctx) {
    if (!ocl_ctx || !h_q_all || !h_k_cache || !h_v_cache || !h_d_att_out_all ||
        !h_d_q_all || !h_d_k_cache || !h_d_v_cache || act <= 0) return;

    size_t size_cache  = (size_t)ctx * (size_t)dim * sizeof(float);
    size_t size_qout   = (size_t)act * (size_t)dim * sizeof(float);
    size_t size_scores = (size_t)act * (size_t)numHeads * (size_t)ctx * sizeof(float);

    cl_mem d_k  = ocl_get_buffer((void*)h_k_cache, size_cache);
    cl_mem d_v  = ocl_get_buffer((void*)h_v_cache, size_cache);
    cl_mem d_dk = ocl_get_buffer((void*)h_d_k_cache, size_cache);
    cl_mem d_dv = ocl_get_buffer((void*)h_d_v_cache, size_cache);
    if (!d_k || !d_v || !d_dk || !d_dv) return;

    // AUDIT-FIX: siehe ocl_attentionForwardBatched - d_k/d_v sind Lese-Inputs und
    // muessen bei jedem Aufruf frisch vom Host geholt werden (ocl_get_buffer()
    // laedt nur beim allerersten Mal automatisch hoch). d_dk/d_dv sind reine
    // Schreib-Ziele des Kernels (der sie selbst nullt und neu befuellt) und
    // brauchen deshalb KEIN Pre-Upload.
    ocl_wr(ocl_queue, d_k, CL_FALSE, 0, size_qout, h_k_cache, 0, NULL, NULL);
    ocl_wr(ocl_queue, d_v, CL_FALSE, 0, size_qout, h_v_cache, 0, NULL, NULL);

    if (!ocl_eph_bt_ensure(&ocl_eph_att_q, &ocl_eph_att_q_size, size_qout)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_att_datt, &ocl_eph_att_datt_size, size_qout)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_att_dq, &ocl_eph_att_dq_size, size_qout)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_att_scores, &ocl_eph_att_scores_size, size_scores)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_att_ds, &ocl_eph_att_ds_size, size_scores)) return;

    ocl_wr(ocl_queue, ocl_eph_att_q, CL_FALSE, 0, size_qout, h_q_all, 0, NULL, NULL);
    ocl_wr(ocl_queue, ocl_eph_att_datt, CL_FALSE, 0, size_qout, h_d_att_out_all, 0, NULL, NULL);

    cl_int err;
    // --- Stufe A: query-parallel (d_q, weights, ds) ---
    err  = clSetKernelArg(ocl_kernel_att_bwd_q, 0, sizeof(cl_mem), &ocl_eph_att_q);
    err |= clSetKernelArg(ocl_kernel_att_bwd_q, 1, sizeof(cl_mem), &d_k);
    err |= clSetKernelArg(ocl_kernel_att_bwd_q, 2, sizeof(cl_mem), &d_v);
    err |= clSetKernelArg(ocl_kernel_att_bwd_q, 3, sizeof(cl_mem), &ocl_eph_att_datt);
    err |= clSetKernelArg(ocl_kernel_att_bwd_q, 4, sizeof(cl_mem), &ocl_eph_att_dq);
    err |= clSetKernelArg(ocl_kernel_att_bwd_q, 5, sizeof(cl_mem), &ocl_eph_att_scores);
    err |= clSetKernelArg(ocl_kernel_att_bwd_q, 6, sizeof(cl_mem), &ocl_eph_att_ds);
    err |= clSetKernelArg(ocl_kernel_att_bwd_q, 7, sizeof(int), &act);
    err |= clSetKernelArg(ocl_kernel_att_bwd_q, 8, sizeof(int), &numHeads);
    err |= clSetKernelArg(ocl_kernel_att_bwd_q, 9, sizeof(int), &headSize);
    err |= clSetKernelArg(ocl_kernel_att_bwd_q, 10, sizeof(int), &dim);
    err |= clSetKernelArg(ocl_kernel_att_bwd_q, 11, sizeof(int), &ctx);
    if (err != CL_SUCCESS) return;

    // AUDIT-FIX: siehe Kommentar in ocl_attentionForwardBatched - Stufe A ist
    // pro Position (p) unabhaengig (d_q/weights/ds werden exklusiv fuer das
    // eigene p geschrieben), deshalb ebenfalls in Positions-Bloecke aufgeteilt,
    // um den AMDGPU-Watchdog nicht ueber einen einzelnen Riesen-Dispatch
    // auszuloesen.
    for (size_t p0 = 0; p0 < (size_t)act; p0 += ATT_POS_CHUNK) {
        size_t chunkLen = ((size_t)act - p0) < ATT_POS_CHUNK ? ((size_t)act - p0) : ATT_POS_CHUNK;
        size_t offset_q[2] = { 0, p0 };
        size_t global_q[2] = { (size_t)numHeads, chunkLen };
        ocl_nd(ocl_queue, ocl_kernel_att_bwd_q, 2, offset_q, global_q, NULL, 0, NULL, NULL);
    }

    // --- Stufe B: key-parallel (d_k_cache, d_v_cache) - siehe Kernel-Kommentar
    // fuer die Begruendung, warum das NICHT ueber die Query-Achse laufen darf. ---
    err  = clSetKernelArg(ocl_kernel_att_bwd_k, 0, sizeof(cl_mem), &ocl_eph_att_q);
    err |= clSetKernelArg(ocl_kernel_att_bwd_k, 1, sizeof(cl_mem), &ocl_eph_att_datt);
    err |= clSetKernelArg(ocl_kernel_att_bwd_k, 2, sizeof(cl_mem), &ocl_eph_att_scores);
    err |= clSetKernelArg(ocl_kernel_att_bwd_k, 3, sizeof(cl_mem), &ocl_eph_att_ds);
    err |= clSetKernelArg(ocl_kernel_att_bwd_k, 4, sizeof(cl_mem), &d_dk);
    err |= clSetKernelArg(ocl_kernel_att_bwd_k, 5, sizeof(cl_mem), &d_dv);
    err |= clSetKernelArg(ocl_kernel_att_bwd_k, 6, sizeof(int), &act);
    err |= clSetKernelArg(ocl_kernel_att_bwd_k, 7, sizeof(int), &numHeads);
    err |= clSetKernelArg(ocl_kernel_att_bwd_k, 8, sizeof(int), &headSize);
    err |= clSetKernelArg(ocl_kernel_att_bwd_k, 9, sizeof(int), &dim);
    err |= clSetKernelArg(ocl_kernel_att_bwd_k, 10, sizeof(int), &ctx);
    if (err != CL_SUCCESS) return;

    // AUDIT-FIX: siehe oben - Stufe B ist pro Key-Position (t) unabhaengig
    // (d_k_cache/d_v_cache werden exklusiv fuer das eigene t geschrieben),
    // deshalb ebenfalls in Bloecke aufgeteilt.
    for (size_t t0 = 0; t0 < (size_t)act; t0 += ATT_POS_CHUNK) {
        size_t chunkLen = ((size_t)act - t0) < ATT_POS_CHUNK ? ((size_t)act - t0) : ATT_POS_CHUNK;
        size_t offset_k[2] = { 0, t0 };
        size_t global_k[2] = { (size_t)numHeads, chunkLen };
        ocl_nd(ocl_queue, ocl_kernel_att_bwd_k, 2, offset_k, global_k, NULL, 0, NULL, NULL);
    }

    // Nur die tatsaechlich beschriebenen 'act' Positionen zurueckholen (nicht den
    // gesamten ctx-grossen Cache) - Positionen >= act liest ohnehin niemand.
    ocl_rd(ocl_queue, ocl_eph_att_dq, CL_FALSE, 0, size_qout, h_d_q_all, 0, NULL, NULL);
    ocl_rd(ocl_queue, d_dk, CL_FALSE, 0, size_qout, h_d_k_cache, 0, NULL, NULL);
    ocl_rd(ocl_queue, d_dv, CL_TRUE, 0, size_qout, h_d_v_cache, 0, NULL, NULL);
}

void ocl_adamStep(float* h_w, float* h_m, float* h_v, float* h_g, float lr, float b1, float b2, float b1t, float b2t, float scale, int size, int is_sparse,
                   int cols, int bound_r, int bound_c, float boost, float wd) {
    if (!ocl_ctx || !h_w || !h_m || !h_v || !h_g || size == 0 || scale == 0.0f) return;
    size_t bytes = (size_t)size * sizeof(float);
    cl_mem d_w = ocl_get_buffer((void*)h_w, bytes); cl_mem d_m = ocl_get_buffer((void*)h_m, bytes);
    cl_mem d_v = ocl_get_buffer((void*)h_v, bytes); cl_mem d_g = ocl_get_buffer((void*)h_g, bytes);
    if (!d_w || !d_m || !d_v || !d_g) return;

    ocl_wr(ocl_queue, d_g, CL_TRUE, 0, bytes, h_g, 0, NULL, NULL);
    cl_int err;
    err  = clSetKernelArg(ocl_kernel_adam, 0, sizeof(cl_mem), (void *)&d_w); err |= clSetKernelArg(ocl_kernel_adam, 1, sizeof(cl_mem), (void *)&d_m);
    err |= clSetKernelArg(ocl_kernel_adam, 2, sizeof(cl_mem), (void *)&d_v); err |= clSetKernelArg(ocl_kernel_adam, 3, sizeof(cl_mem), (void *)&d_g);
    err |= clSetKernelArg(ocl_kernel_adam, 4, sizeof(float), (void *)&lr);  err |= clSetKernelArg(ocl_kernel_adam, 5, sizeof(float), (void *)&b1);
    err |= clSetKernelArg(ocl_kernel_adam, 6, sizeof(float), (void *)&b2);  err |= clSetKernelArg(ocl_kernel_adam, 7, sizeof(float), (void *)&b1t);
    err |= clSetKernelArg(ocl_kernel_adam, 8, sizeof(float), (void *)&b2t); err |= clSetKernelArg(ocl_kernel_adam, 9, sizeof(float), (void *)&scale);
    err |= clSetKernelArg(ocl_kernel_adam, 10, sizeof(int), (void *)&size); err |= clSetKernelArg(ocl_kernel_adam, 11, sizeof(int), (void *)&is_sparse);
    err |= clSetKernelArg(ocl_kernel_adam, 12, sizeof(int), (void *)&cols); err |= clSetKernelArg(ocl_kernel_adam, 13, sizeof(int), (void *)&bound_r);
    err |= clSetKernelArg(ocl_kernel_adam, 14, sizeof(int), (void *)&bound_c); err |= clSetKernelArg(ocl_kernel_adam, 15, sizeof(float), (void *)&boost);
    err |= clSetKernelArg(ocl_kernel_adam, 16, sizeof(float), (void *)&wd);

    if (err != CL_SUCCESS) return;

    size_t local_item_size = ocl_max_work_group_size; 
    size_t global_item_size = (((size_t)size + local_item_size - 1) / local_item_size) * local_item_size;
    ocl_nd(ocl_queue, ocl_kernel_adam, 1, NULL, &global_item_size, &local_item_size, 0, NULL, NULL);
    
    ocl_rd(ocl_queue, d_w, CL_TRUE, 0, bytes, h_w, 0, NULL, NULL);
    ocl_rd(ocl_queue, d_m, CL_TRUE, 0, bytes, h_m, 0, NULL, NULL);
    ocl_rd(ocl_queue, d_v, CL_TRUE, 0, bytes, h_v, 0, NULL, NULL); 
    
    memset(h_g, 0, bytes);
}

// PHASE 3 DES INT8-UMBAUS: Host-Wrapper fuer matVecMulI8 - spiegelt
// ocl_matVecMul oben, mit int8-Gewichts-/Aktivierungs-Puffern statt float.
// Gewicht (h_M) + Skala (h_Mscale) sind PERSISTENTE Host-Zeiger (ueber
// ocl_get_buffer wie bei ocl_matVecMul einmalig hochgeladen, bei
// Wiederverwendung desselben Zeigers automatisch der bereits GPU-residente
// Puffer - identisches Verhalten zum bestehenden FP32-Pfad). Der quantisierte
// Aktivierungsvektor (h_v) ist dagegen EPHEMER (aendert sich jeden Aufruf).
void ocl_matVecMulI8(const signed char* h_M, const float* h_Mscale, const signed char* h_v, float vScale,
                      float* h_out, int rows, int cols) {
    if (!ocl_ctx || !h_M || !h_Mscale || !h_v || !h_out || rows == 0 || cols == 0) return;

    size_t size_M = (size_t)rows * (size_t)cols * sizeof(signed char);
    size_t size_Mscale = (size_t)rows * sizeof(float);
    size_t size_v = (size_t)cols * sizeof(signed char);
    size_t size_out = (size_t)rows * sizeof(float);

    cl_mem d_M = ocl_get_buffer((void*)h_M, size_M);
    cl_mem d_Mscale = ocl_get_buffer((void*)h_Mscale, size_Mscale);
    if (!d_M || !d_Mscale) return;

    cl_int err = CL_SUCCESS;
    if (ocl_eph_act_i8_size < size_v) {
        if (ocl_eph_act_i8) clReleaseMemObject(ocl_eph_act_i8);
        ocl_eph_act_i8 = ocl_mk(ocl_ctx, CL_MEM_READ_WRITE, size_v, NULL, &err);
        ocl_eph_act_i8_size = (err == CL_SUCCESS) ? size_v : 0;
    }
    if (ocl_eph_out_size < size_out) {
        if (ocl_eph_out) clReleaseMemObject(ocl_eph_out);
        ocl_eph_out = ocl_mk(ocl_ctx, CL_MEM_READ_WRITE, size_out, NULL, &err);
        ocl_eph_out_size = (err == CL_SUCCESS) ? size_out : 0;
    }
    if (!ocl_eph_act_i8 || !ocl_eph_out) return;

    ocl_wr(ocl_queue, ocl_eph_act_i8, CL_FALSE, 0, size_v, h_v, 0, NULL, NULL);

    err  = clSetKernelArg(ocl_kernel_matvec_i8, 0, sizeof(cl_mem), (void *)&d_M);
    err |= clSetKernelArg(ocl_kernel_matvec_i8, 1, sizeof(cl_mem), (void *)&d_Mscale);
    err |= clSetKernelArg(ocl_kernel_matvec_i8, 2, sizeof(cl_mem), (void *)&ocl_eph_act_i8);
    err |= clSetKernelArg(ocl_kernel_matvec_i8, 3, sizeof(float), (void *)&vScale);
    err |= clSetKernelArg(ocl_kernel_matvec_i8, 4, sizeof(cl_mem), (void *)&ocl_eph_out);
    err |= clSetKernelArg(ocl_kernel_matvec_i8, 5, sizeof(int), (void *)&rows);
    err |= clSetKernelArg(ocl_kernel_matvec_i8, 6, sizeof(int), (void *)&cols);
    if (err != CL_SUCCESS) return;

    size_t local_item_size = ocl_max_work_group_size;
    size_t global_item_size = (((size_t)rows + local_item_size - 1) / local_item_size) * local_item_size;

    ocl_nd(ocl_queue, ocl_kernel_matvec_i8, 1, NULL, &global_item_size, &local_item_size, 0, NULL, NULL);
    ocl_rd(ocl_queue, ocl_eph_out, CL_TRUE, 0, size_out, h_out, 0, NULL, NULL);
}

// PHASE 7 (GPU-Dispatch): Host-Wrapper fuer matVecMulTI8 (Backward). Spiegelt
// ocl_matVecMulT oben, nur mit int8-Gewicht + Pro-Zeile-Skala statt float.
void ocl_matVecMulTI8(const signed char* h_M, const float* h_Mscale, const float* h_d_out,
                       float* h_d_in, int rows, int cols, int accumulate) {
    if (!ocl_ctx || !h_M || !h_Mscale || !h_d_out || !h_d_in || rows == 0 || cols == 0) return;

    size_t size_M = (size_t)rows * (size_t)cols * sizeof(signed char);
    size_t size_Mscale = (size_t)rows * sizeof(float);
    size_t size_o = (size_t)rows * sizeof(float);
    size_t size_i = (size_t)cols * sizeof(float);

    cl_mem d_M = ocl_get_buffer((void*)h_M, size_M);
    cl_mem d_Mscale = ocl_get_buffer((void*)h_Mscale, size_Mscale);
    if (!d_M || !d_Mscale) return;

    cl_int err = CL_SUCCESS;
    if (!ocl_eph_bt_ensure(&ocl_eph_bt_a, &ocl_eph_bt_a_size, size_o)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bt_b, &ocl_eph_bt_b_size, size_i)) return;

    ocl_wr(ocl_queue, ocl_eph_bt_a, CL_FALSE, 0, size_o, h_d_out, 0, NULL, NULL);
    if (accumulate == 1) {
        ocl_wr(ocl_queue, ocl_eph_bt_b, CL_FALSE, 0, size_i, h_d_in, 0, NULL, NULL);
    }

    err  = clSetKernelArg(ocl_kernel_matvec_t_i8, 0, sizeof(cl_mem), (void *)&d_M);
    err |= clSetKernelArg(ocl_kernel_matvec_t_i8, 1, sizeof(cl_mem), (void *)&d_Mscale);
    err |= clSetKernelArg(ocl_kernel_matvec_t_i8, 2, sizeof(cl_mem), (void *)&ocl_eph_bt_a);
    err |= clSetKernelArg(ocl_kernel_matvec_t_i8, 3, sizeof(cl_mem), (void *)&ocl_eph_bt_b);
    err |= clSetKernelArg(ocl_kernel_matvec_t_i8, 4, sizeof(int), (void *)&rows);
    err |= clSetKernelArg(ocl_kernel_matvec_t_i8, 5, sizeof(int), (void *)&cols);
    err |= clSetKernelArg(ocl_kernel_matvec_t_i8, 6, sizeof(int), (void *)&accumulate);
    if (err != CL_SUCCESS) return;

    size_t local_item_size = ocl_max_work_group_size;
    size_t global_item_size = (((size_t)cols + local_item_size - 1) / local_item_size) * local_item_size;
    ocl_nd(ocl_queue, ocl_kernel_matvec_t_i8, 1, NULL, &global_item_size, &local_item_size, 0, NULL, NULL);
    ocl_rd(ocl_queue, ocl_eph_bt_b, CL_TRUE, 0, size_i, h_d_in, 0, NULL, NULL);
}

// PHASE 8: Host-Wrapper der gebuendelten INT8-GEMMs. Spiegeln
// ocl_matMulBatched/ocl_matMulTBatched, nur mit int8-Gewicht + Zeilen-Skala
// und (beim Forward) int8-Eingabeblock + Pro-Position-Skala.
void ocl_matMulBatchedI8(const signed char* h_M, const float* h_Mscale,
                          const signed char* h_in, const float* h_inScale,
                          float* h_out, int rows, int cols, int batch) {
    if (!ocl_ctx || !h_M || !h_Mscale || !h_in || !h_inScale || !h_out ||
        rows <= 0 || cols <= 0 || batch <= 0) return;
    size_t size_M = (size_t)rows * (size_t)cols * sizeof(signed char);
    size_t size_Ms = (size_t)rows * sizeof(float);
    size_t size_i = (size_t)batch * (size_t)cols * sizeof(signed char);
    size_t size_sc = (size_t)batch * sizeof(float);
    size_t size_o = (size_t)batch * (size_t)rows * sizeof(float);

    cl_mem d_M = ocl_get_buffer((void*)h_M, size_M);
    cl_mem d_Ms = ocl_get_buffer((void*)h_Mscale, size_Ms);
    if (!d_M || !d_Ms) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bm_i8, &ocl_eph_bm_i8_size, size_i)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bm_sc, &ocl_eph_bm_sc_size, size_sc)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bm_r, &ocl_eph_bm_r_size, size_o)) return;

    ocl_wr(ocl_queue, ocl_eph_bm_i8, CL_FALSE, 0, size_i, h_in, 0, NULL, NULL);
    ocl_wr(ocl_queue, ocl_eph_bm_sc, CL_FALSE, 0, size_sc, h_inScale, 0, NULL, NULL);

    if (ocl_fwd_get_mode() > 0) {   // OCL-FWD: Kachelkern
        const int rot = ocl_fwd_mode == 2;
        cl_int e3;
        e3  = clSetKernelArg(ocl_kernel_fwd_tiled, 0, sizeof(cl_mem), (void*)&d_M);
        e3 |= clSetKernelArg(ocl_kernel_fwd_tiled, 1, sizeof(cl_mem), (void*)&d_Ms);
        e3 |= clSetKernelArg(ocl_kernel_fwd_tiled, 2, sizeof(cl_mem), (void*)&ocl_eph_bm_i8);
        e3 |= clSetKernelArg(ocl_kernel_fwd_tiled, 3, sizeof(cl_mem), (void*)&ocl_eph_bm_sc);
        e3 |= clSetKernelArg(ocl_kernel_fwd_tiled, 4, sizeof(cl_mem), (void*)&ocl_eph_bm_r);
        e3 |= clSetKernelArg(ocl_kernel_fwd_tiled, 5, sizeof(int), (void*)&rows);
        e3 |= clSetKernelArg(ocl_kernel_fwd_tiled, 6, sizeof(int), (void*)&cols);
        e3 |= clSetKernelArg(ocl_kernel_fwd_tiled, 7, sizeof(int), (void*)&batch);
        e3 |= clSetKernelArg(ocl_kernel_fwd_tiled, 8, sizeof(int), (void*)&rot);
        if (e3 == CL_SUCCESS) {
            size_t lt[2] = { 256, 1 };
            size_t gt[2] = { (((size_t)rows + 63) / 64) * 256, ((size_t)batch + 63) / 64 };
            ocl_nd(ocl_queue, ocl_kernel_fwd_tiled, 2, NULL, gt, lt, 0, NULL, NULL);
            ocl_rd(ocl_queue, ocl_eph_bm_r, CL_TRUE, 0, size_o, h_out, 0, NULL, NULL);
            return;
        }
    }
    cl_int err;
    err  = clSetKernelArg(ocl_kernel_gemm_f_i8, 0, sizeof(cl_mem), (void*)&d_M);
    err |= clSetKernelArg(ocl_kernel_gemm_f_i8, 1, sizeof(cl_mem), (void*)&d_Ms);
    err |= clSetKernelArg(ocl_kernel_gemm_f_i8, 2, sizeof(cl_mem), (void*)&ocl_eph_bm_i8);
    err |= clSetKernelArg(ocl_kernel_gemm_f_i8, 3, sizeof(cl_mem), (void*)&ocl_eph_bm_sc);
    err |= clSetKernelArg(ocl_kernel_gemm_f_i8, 4, sizeof(cl_mem), (void*)&ocl_eph_bm_r);
    err |= clSetKernelArg(ocl_kernel_gemm_f_i8, 5, sizeof(int), (void*)&rows);
    err |= clSetKernelArg(ocl_kernel_gemm_f_i8, 6, sizeof(int), (void*)&cols);
    err |= clSetKernelArg(ocl_kernel_gemm_f_i8, 7, sizeof(int), (void*)&batch);
    if (err != CL_SUCCESS) return;

    size_t local2[2]  = { ocl_max_work_group_size, 1 };
    size_t global2[2] = { (((size_t)rows + local2[0] - 1) / local2[0]) * local2[0], (size_t)batch };
    ocl_nd(ocl_queue, ocl_kernel_gemm_f_i8, 2, NULL, global2, local2, 0, NULL, NULL);
    ocl_rd(ocl_queue, ocl_eph_bm_r, CL_TRUE, 0, size_o, h_out, 0, NULL, NULL);
}

// FULL-INT8 Schritt 1 auf der GPU. Der Host uebergibt den bereits
// quantisierten Gradienten (dq) und die Blockskalen - siehe Kommentar am
// Kernel. `d_in` wird nur bei accumulate==1 vorher hochgeladen.
void ocl_backwardDInI8(const signed char* h_W, const signed char* h_dq,
                       const float* h_bscale, float* h_d_in,
                       int rows, int cols, int blockSize, int accumulate) {
    if (!ocl_ctx || !ocl_kernel_bw_din_i8 || !h_W || !h_dq || !h_bscale || !h_d_in ||
        rows <= 0 || cols <= 0 || blockSize <= 0) return;
    int nblocks = (rows + blockSize - 1) / blockSize;
    size_t size_W  = (size_t)rows * (size_t)cols * sizeof(signed char);
    size_t size_dq = (size_t)rows * sizeof(signed char);
    size_t size_bs = (size_t)nblocks * sizeof(float);
    size_t size_di = (size_t)cols * sizeof(float);

    // Das Gewicht ist geraeteresident (Zeiger-indizierter Cache, siehe
    // ocl_get_buffer); dq/bscale/d_in wechseln je Aufruf und laufen deshalb
    // ueber ephemere Puffer.
    cl_mem d_W = ocl_get_buffer((void*)h_W, size_W);
    if (!d_W) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bwdq, &ocl_eph_bwdq_size, size_dq)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bs, &ocl_eph_bs_size, size_bs)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bm_c, &ocl_eph_bm_c_size, size_di)) return;

    cl_mem d_dq = ocl_eph_bwdq;
    cl_mem d_bs = ocl_eph_bs;
    ocl_wr(ocl_queue, d_dq, CL_FALSE, 0, size_dq, h_dq, 0, NULL, NULL);
    ocl_wr(ocl_queue, d_bs, CL_FALSE, 0, size_bs, h_bscale, 0, NULL, NULL);
    if (accumulate == 1) {
        ocl_wr(ocl_queue, ocl_eph_bm_c, CL_FALSE, 0, size_di, h_d_in, 0, NULL, NULL);
    }

    cl_int err;
    err  = clSetKernelArg(ocl_kernel_bw_din_i8, 0, sizeof(cl_mem), (void*)&d_W);
    err |= clSetKernelArg(ocl_kernel_bw_din_i8, 1, sizeof(cl_mem), (void*)&d_dq);
    err |= clSetKernelArg(ocl_kernel_bw_din_i8, 2, sizeof(cl_mem), (void*)&d_bs);
    err |= clSetKernelArg(ocl_kernel_bw_din_i8, 3, sizeof(cl_mem), (void*)&ocl_eph_bm_c);
    err |= clSetKernelArg(ocl_kernel_bw_din_i8, 4, sizeof(int), (void*)&rows);
    err |= clSetKernelArg(ocl_kernel_bw_din_i8, 5, sizeof(int), (void*)&cols);
    err |= clSetKernelArg(ocl_kernel_bw_din_i8, 6, sizeof(int), (void*)&blockSize);
    err |= clSetKernelArg(ocl_kernel_bw_din_i8, 7, sizeof(int), (void*)&accumulate);
    if (err != CL_SUCCESS) return;

    size_t local1  = ocl_max_work_group_size;
    size_t global1 = (((size_t)cols + local1 - 1) / local1) * local1;
    ocl_nd(ocl_queue, ocl_kernel_bw_din_i8, 1, NULL, &global1, &local1, 0, NULL, NULL);
    ocl_bw_din_calls++;
    ocl_rd(ocl_queue, ocl_eph_bm_c, CL_TRUE, 0, size_di, h_d_in, 0, NULL, NULL);
}

// Ganzzahlige Gradienten-Akkumulation (Aussenprodukt) auf der GPU.
// Arbeitsteilung wie bei ocl_backwardDInI8: die Quantisierung samt Skalen
// bleibt auf dem Host (O(batch*(rows+cols))), die GPU rechnet nur das
// rows*cols*batch grosse Aussenprodukt.
// Gebuendelter Ganzzahl-Backward: EIN Kernel-Start fuer alle Positionen.
// Der Einzelpositions-Wrapper darf hier nicht wiederverwendet werden - der
// gebuendelte CPU-Pfad ruft ihn aus einer OpenMP-Schleife auf, und weder die
// Kommando-Queue noch die ephemeren Puffer sind thread-sicher.
void ocl_backwardDInI8Batched(const signed char* h_W, const signed char* h_dq,
                              const float* h_bscale, float* h_d_in,
                              int rows, int cols, int batch, int blockSize,
                              int accumulate) {
    if (!ocl_ctx || !ocl_kernel_bw_din_i8_b || !h_W || !h_dq || !h_bscale || !h_d_in ||
        rows <= 0 || cols <= 0 || batch <= 0 || blockSize <= 0) return;
    int nblocks = (rows + blockSize - 1) / blockSize;
    size_t n_W  = (size_t)rows * (size_t)cols * sizeof(signed char);
    size_t n_dq = (size_t)batch * (size_t)rows * sizeof(signed char);
    size_t n_bs = (size_t)batch * (size_t)nblocks * sizeof(float);
    size_t n_di = (size_t)batch * (size_t)cols * sizeof(float);

    cl_mem d_W = ocl_get_buffer((void*)h_W, n_W);
    if (!d_W) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bb_dq, &ocl_eph_bb_dq_size, n_dq)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bb_bs, &ocl_eph_bb_bs_size, n_bs)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bb_di, &ocl_eph_bb_di_size, n_di)) return;

    ocl_wr(ocl_queue, ocl_eph_bb_dq, CL_FALSE, 0, n_dq, h_dq, 0, NULL, NULL);
    ocl_wr(ocl_queue, ocl_eph_bb_bs, CL_FALSE, 0, n_bs, h_bscale, 0, NULL, NULL);
    if (accumulate == 1) {
        ocl_wr(ocl_queue, ocl_eph_bb_di, CL_FALSE, 0, n_di, h_d_in, 0, NULL, NULL);
    }

    cl_int err;
    const int bwm = ocl_bw_get_mode();
    if (bwm > 0 && blockSize == 64) {
        const int rotv = (bwm == 2) ? 1 : 0;
        err  = clSetKernelArg(ocl_kernel_bw_tiled, 0, sizeof(cl_mem), (void*)&d_W);
        err |= clSetKernelArg(ocl_kernel_bw_tiled, 1, sizeof(cl_mem), (void*)&ocl_eph_bb_dq);
        err |= clSetKernelArg(ocl_kernel_bw_tiled, 2, sizeof(cl_mem), (void*)&ocl_eph_bb_bs);
        err |= clSetKernelArg(ocl_kernel_bw_tiled, 3, sizeof(cl_mem), (void*)&ocl_eph_bb_di);
        err |= clSetKernelArg(ocl_kernel_bw_tiled, 4, sizeof(int), (void*)&rows);
        err |= clSetKernelArg(ocl_kernel_bw_tiled, 5, sizeof(int), (void*)&cols);
        err |= clSetKernelArg(ocl_kernel_bw_tiled, 6, sizeof(int), (void*)&batch);
        err |= clSetKernelArg(ocl_kernel_bw_tiled, 7, sizeof(int), (void*)&accumulate);
        err |= clSetKernelArg(ocl_kernel_bw_tiled, 8, sizeof(int), (void*)&rotv);
        if (err != CL_SUCCESS) return;
        size_t g2[2] = { (size_t)((cols + 63) / 64) * 256, (size_t)((batch + 63) / 64) };
        size_t l2[2] = { 256, 1 };
        ocl_nd(ocl_queue, ocl_kernel_bw_tiled, 2, NULL, g2, l2, 0, NULL, NULL);
        ocl_bw_din_calls++;
        ocl_rd(ocl_queue, ocl_eph_bb_di, CL_TRUE, 0, n_di, h_d_in, 0, NULL, NULL);
        return;
    }
    err  = clSetKernelArg(ocl_kernel_bw_din_i8_b, 0, sizeof(cl_mem), (void*)&d_W);
    err |= clSetKernelArg(ocl_kernel_bw_din_i8_b, 1, sizeof(cl_mem), (void*)&ocl_eph_bb_dq);
    err |= clSetKernelArg(ocl_kernel_bw_din_i8_b, 2, sizeof(cl_mem), (void*)&ocl_eph_bb_bs);
    err |= clSetKernelArg(ocl_kernel_bw_din_i8_b, 3, sizeof(cl_mem), (void*)&ocl_eph_bb_di);
    err |= clSetKernelArg(ocl_kernel_bw_din_i8_b, 4, sizeof(int), (void*)&rows);
    err |= clSetKernelArg(ocl_kernel_bw_din_i8_b, 5, sizeof(int), (void*)&cols);
    err |= clSetKernelArg(ocl_kernel_bw_din_i8_b, 6, sizeof(int), (void*)&batch);
    err |= clSetKernelArg(ocl_kernel_bw_din_i8_b, 7, sizeof(int), (void*)&blockSize);
    err |= clSetKernelArg(ocl_kernel_bw_din_i8_b, 8, sizeof(int), (void*)&accumulate);
    if (err != CL_SUCCESS) return;

    size_t local1  = ocl_max_work_group_size;
    size_t total   = (size_t)batch * (size_t)cols;
    size_t global1 = ((total + local1 - 1) / local1) * local1;
    ocl_nd(ocl_queue, ocl_kernel_bw_din_i8_b, 1, NULL, &global1, &local1, 0, NULL, NULL);
    ocl_bw_din_calls++;
    ocl_rd(ocl_queue, ocl_eph_bb_di, CL_TRUE, 0, n_di, h_d_in, 0, NULL, NULL);
}

// gmOnDevice: der Gradient ist bereits GERAETERESIDENT - der Aufrufer hat ihn
// dort genullt (zeroGradI8) und holt ihn spaeter selbst zurueck (pullGradI8).
// Dann darf hier weder hoch- noch runtergeladen werden: ein Upload wuerde die
// auf dem Geraet akkumulierten Werte mit dem Host-Stand ueberschreiben, ein
// Download waere doppelte Arbeit - und ein EPHEMERER Puffer waere schlicht der
// falsche Speicher (der Rueckschrieb des Aufrufers holte dann die unberuehrten
// Nullen des persistenten Puffers). Genau daran lernte der Ganzzahl-Pfad
// nichts mehr, als die CPU-Sperre fiel.
void ocl_gradAccumI8(const signed char* h_qi, const signed char* h_qd,
                     const float* h_dsc, const float* h_isc, float* h_gm,
                     int rows, int cols, int batch, int qiStride, int gmOnDevice) {
    if (!ocl_ctx || !ocl_kernel_gradacc_i8 || !h_qi || !h_qd || !h_dsc || !h_isc ||
        !h_gm || rows <= 0 || cols <= 0 || batch <= 0) return;
    size_t n_qi = (size_t)batch * (size_t)qiStride * sizeof(signed char);
    size_t n_qd = (size_t)batch * (size_t)rows * sizeof(signed char);
    size_t n_ds = (size_t)rows * sizeof(float);
    size_t n_is = (size_t)cols * sizeof(float);
    size_t n_gm = (size_t)rows * (size_t)cols * sizeof(float);

    if (!ocl_eph_bt_ensure(&ocl_eph_ga_qi, &ocl_eph_ga_qi_size, n_qi)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_ga_qd, &ocl_eph_ga_qd_size, n_qd)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_ga_ds, &ocl_eph_ga_ds_size, n_ds)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_ga_is, &ocl_eph_ga_is_size, n_is)) return;
    cl_mem d_gm;
    if (gmOnDevice == 1) {
        d_gm = ocl_get_buffer((void*)h_gm, n_gm);
        if (!d_gm) return;
    } else {
        if (!ocl_eph_bt_ensure(&ocl_eph_ga_gm, &ocl_eph_ga_gm_size, n_gm)) return;
        d_gm = ocl_eph_ga_gm;
    }

    ocl_wr(ocl_queue, ocl_eph_ga_qi, CL_FALSE, 0, n_qi, h_qi, 0, NULL, NULL);
    ocl_wr(ocl_queue, ocl_eph_ga_qd, CL_FALSE, 0, n_qd, h_qd, 0, NULL, NULL);
    ocl_wr(ocl_queue, ocl_eph_ga_ds, CL_FALSE, 0, n_ds, h_dsc, 0, NULL, NULL);
    ocl_wr(ocl_queue, ocl_eph_ga_is, CL_FALSE, 0, n_is, h_isc, 0, NULL, NULL);
    // Nur im Host-Fall: gm wird AKKUMULIERT, muss also vorher hoch.
    if (gmOnDevice != 1) {
        ocl_wr(ocl_queue, d_gm, CL_FALSE, 0, n_gm, h_gm, 0, NULL, NULL);
    }

    cl_int err;
    const int bwm = ocl_bw_get_mode();
    if (bwm > 0) {
        const int rotv = (bwm == 2) ? 1 : 0;
        err  = clSetKernelArg(ocl_kernel_ga_tiled, 0, sizeof(cl_mem), (void*)&ocl_eph_ga_qi);
        err |= clSetKernelArg(ocl_kernel_ga_tiled, 1, sizeof(cl_mem), (void*)&ocl_eph_ga_qd);
        err |= clSetKernelArg(ocl_kernel_ga_tiled, 2, sizeof(cl_mem), (void*)&ocl_eph_ga_ds);
        err |= clSetKernelArg(ocl_kernel_ga_tiled, 3, sizeof(cl_mem), (void*)&ocl_eph_ga_is);
        err |= clSetKernelArg(ocl_kernel_ga_tiled, 4, sizeof(cl_mem), (void*)&d_gm);
        err |= clSetKernelArg(ocl_kernel_ga_tiled, 5, sizeof(int), (void*)&rows);
        err |= clSetKernelArg(ocl_kernel_ga_tiled, 6, sizeof(int), (void*)&cols);
        err |= clSetKernelArg(ocl_kernel_ga_tiled, 7, sizeof(int), (void*)&batch);
        err |= clSetKernelArg(ocl_kernel_ga_tiled, 8, sizeof(int), (void*)&qiStride);
        err |= clSetKernelArg(ocl_kernel_ga_tiled, 9, sizeof(int), (void*)&rotv);
        if (err != CL_SUCCESS) return;
        size_t g2[2] = { (size_t)((cols + 63) / 64) * 256, (size_t)((rows + 63) / 64) };
        size_t l2[2] = { 256, 1 };
        ocl_nd(ocl_queue, ocl_kernel_ga_tiled, 2, NULL, g2, l2, 0, NULL, NULL);
        ocl_gradacc_calls++;
        if (gmOnDevice == 1) clFinish(ocl_queue);
        else ocl_rd(ocl_queue, d_gm, CL_TRUE, 0, n_gm, h_gm, 0, NULL, NULL);
        return;
    }
    err  = clSetKernelArg(ocl_kernel_gradacc_i8, 0, sizeof(cl_mem), (void*)&ocl_eph_ga_qi);
    err |= clSetKernelArg(ocl_kernel_gradacc_i8, 1, sizeof(cl_mem), (void*)&ocl_eph_ga_qd);
    err |= clSetKernelArg(ocl_kernel_gradacc_i8, 2, sizeof(cl_mem), (void*)&ocl_eph_ga_ds);
    err |= clSetKernelArg(ocl_kernel_gradacc_i8, 3, sizeof(cl_mem), (void*)&ocl_eph_ga_is);
    err |= clSetKernelArg(ocl_kernel_gradacc_i8, 4, sizeof(cl_mem), (void*)&d_gm);
    err |= clSetKernelArg(ocl_kernel_gradacc_i8, 5, sizeof(int), (void*)&rows);
    err |= clSetKernelArg(ocl_kernel_gradacc_i8, 6, sizeof(int), (void*)&cols);
    err |= clSetKernelArg(ocl_kernel_gradacc_i8, 7, sizeof(int), (void*)&batch);
    err |= clSetKernelArg(ocl_kernel_gradacc_i8, 8, sizeof(int), (void*)&qiStride);
    if (err != CL_SUCCESS) return;

    size_t local1  = ocl_max_work_group_size;
    size_t total   = (size_t)rows * (size_t)cols;
    size_t global1 = ((total + local1 - 1) / local1) * local1;
    ocl_nd(ocl_queue, ocl_kernel_gradacc_i8, 1, NULL, &global1, &local1, 0, NULL, NULL);
    ocl_gradacc_calls++;
    if (gmOnDevice == 1) {
        clFinish(ocl_queue);   // der Aufrufer holt spaeter selbst zurueck
    } else {
        ocl_rd(ocl_queue, d_gm, CL_TRUE, 0, n_gm, h_gm, 0, NULL, NULL);
    }
}

void ocl_matMulTBatchedI8(const signed char* h_M, const float* h_Mscale,
                           const float* h_d_out, float* h_d_in,
                           int rows, int cols, int batch, int accumulate) {
    if (!ocl_ctx || !h_M || !h_Mscale || !h_d_out || !h_d_in ||
        rows <= 0 || cols <= 0 || batch <= 0) return;
    size_t size_M = (size_t)rows * (size_t)cols * sizeof(signed char);
    size_t size_Ms = (size_t)rows * sizeof(float);
    size_t size_o = (size_t)batch * (size_t)rows * sizeof(float);
    size_t size_i = (size_t)batch * (size_t)cols * sizeof(float);

    cl_mem d_M = ocl_get_buffer((void*)h_M, size_M);
    cl_mem d_Ms = ocl_get_buffer((void*)h_Mscale, size_Ms);
    if (!d_M || !d_Ms) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bm_r, &ocl_eph_bm_r_size, size_o)) return;
    if (!ocl_eph_bt_ensure(&ocl_eph_bm_c, &ocl_eph_bm_c_size, size_i)) return;

    ocl_wr(ocl_queue, ocl_eph_bm_r, CL_FALSE, 0, size_o, h_d_out, 0, NULL, NULL);
    if (accumulate == 1) {
        ocl_wr(ocl_queue, ocl_eph_bm_c, CL_FALSE, 0, size_i, h_d_in, 0, NULL, NULL);
    }

    cl_int err;
    err  = clSetKernelArg(ocl_kernel_gemm_t_i8, 0, sizeof(cl_mem), (void*)&d_M);
    err |= clSetKernelArg(ocl_kernel_gemm_t_i8, 1, sizeof(cl_mem), (void*)&d_Ms);
    err |= clSetKernelArg(ocl_kernel_gemm_t_i8, 2, sizeof(cl_mem), (void*)&ocl_eph_bm_r);
    err |= clSetKernelArg(ocl_kernel_gemm_t_i8, 3, sizeof(cl_mem), (void*)&ocl_eph_bm_c);
    err |= clSetKernelArg(ocl_kernel_gemm_t_i8, 4, sizeof(int), (void*)&rows);
    err |= clSetKernelArg(ocl_kernel_gemm_t_i8, 5, sizeof(int), (void*)&cols);
    err |= clSetKernelArg(ocl_kernel_gemm_t_i8, 6, sizeof(int), (void*)&batch);
    err |= clSetKernelArg(ocl_kernel_gemm_t_i8, 7, sizeof(int), (void*)&accumulate);
    if (err != CL_SUCCESS) return;

    size_t local2[2]  = { ocl_max_work_group_size, 1 };
    size_t global2[2] = { (((size_t)cols + local2[0] - 1) / local2[0]) * local2[0], (size_t)batch };
    ocl_nd(ocl_queue, ocl_kernel_gemm_t_i8, 2, NULL, global2, local2, 0, NULL, NULL);
    ocl_rd(ocl_queue, ocl_eph_bm_c, CL_TRUE, 0, size_i, h_d_in, 0, NULL, NULL);
}

// PHASE 7 (GPU-Dispatch), KRITISCH fuer die Korrektheit: cortex_rescale_weights()
// aendert nach JEDEM Trainingsschritt auf dem HOST sowohl die INT8-Daten als
// auch die Zeilen-Skalen. ocl_get_buffer() laedt einen Puffer aber nur beim
// ERSTEN Zugriff hoch und liefert danach die zwischengespeicherte
// GPU-Kopie - ohne diesen expliziten Rueckschrieb wuerde die GPU ab dem
// zweiten Schritt mit veralteten Gewichten UND veralteten Skalen weiterrechnen
// (still, ohne Fehlermeldung). Genau der Vorbehalt, der beim Bau der
// INT8-Kernel dokumentiert und bis hierhin offen war.
void ocl_push_qmatrix(const signed char* h_data, const float* h_scale, int rows, int cols) {
    if (!ocl_ctx || !h_data || !h_scale || rows <= 0 || cols <= 0) return;
    ocl_sync_to_device((void*)h_data, (size_t)rows * (size_t)cols * sizeof(signed char));
    ocl_sync_to_device((void*)h_scale, (size_t)rows * sizeof(float));
}

// PHASE 3 DES INT8-UMBAUS: Host-Wrapper fuer adamUpdateI8 - spiegelt
// ocl_adamStep oben. h_wscale ist die Pro-Zeile-Skala (Laenge size/cols),
// PERSISTENT wie h_w (via ocl_get_buffer). WICHTIGER VORBEHALT (dokumentiert,
// nicht in dieser Phase geloest): wenn cortex_rescale_weights() auf dem HOST
// die Skala aendert, bleibt eine bereits GPU-hochgeladene d_wscale-Kopie
// veraltet, bis ocl_sync_to_device() explizit aufgerufen wird - relevant erst
// bei voller Trainings-Loop-Integration (Phase 5), nicht fuer die isolierte
// Kernel-Verifikation hier.
void ocl_adamStepI8(signed char* h_w, const float* h_wscale, float* h_m, float* h_v, float* h_g,
                     float lr, float b1, float b2, float b1t, float b2t, float scale, int size, int is_sparse,
                     int cols, int bound_r, int bound_c, float boost, float wd) {
    if (!ocl_ctx || !h_w || !h_wscale || !h_m || !h_v || !h_g || size == 0 || scale == 0.0f || cols == 0) return;
    size_t bytes_w = (size_t)size * sizeof(signed char);
    size_t bytes_f = (size_t)size * sizeof(float);
    int rows = size / cols;
    size_t bytes_scale = (size_t)rows * sizeof(float);

    cl_mem d_w = ocl_get_buffer((void*)h_w, bytes_w);
    cl_mem d_wscale = ocl_get_buffer((void*)h_wscale, bytes_scale);
    cl_mem d_m = ocl_get_buffer((void*)h_m, bytes_f);
    cl_mem d_v = ocl_get_buffer((void*)h_v, bytes_f);
    cl_mem d_g = ocl_get_buffer((void*)h_g, bytes_f);
    if (!d_w || !d_wscale || !d_m || !d_v || !d_g) return;

    ocl_wr(ocl_queue, d_g, CL_TRUE, 0, bytes_f, h_g, 0, NULL, NULL);
    cl_int err;
    err  = clSetKernelArg(ocl_kernel_adam_i8, 0, sizeof(cl_mem), (void *)&d_w);
    err |= clSetKernelArg(ocl_kernel_adam_i8, 1, sizeof(cl_mem), (void *)&d_wscale);
    err |= clSetKernelArg(ocl_kernel_adam_i8, 2, sizeof(cl_mem), (void *)&d_m);
    err |= clSetKernelArg(ocl_kernel_adam_i8, 3, sizeof(cl_mem), (void *)&d_v);
    err |= clSetKernelArg(ocl_kernel_adam_i8, 4, sizeof(cl_mem), (void *)&d_g);
    err |= clSetKernelArg(ocl_kernel_adam_i8, 5, sizeof(float), (void *)&lr);
    err |= clSetKernelArg(ocl_kernel_adam_i8, 6, sizeof(float), (void *)&b1);
    err |= clSetKernelArg(ocl_kernel_adam_i8, 7, sizeof(float), (void *)&b2);
    err |= clSetKernelArg(ocl_kernel_adam_i8, 8, sizeof(float), (void *)&b1t);
    err |= clSetKernelArg(ocl_kernel_adam_i8, 9, sizeof(float), (void *)&b2t);
    err |= clSetKernelArg(ocl_kernel_adam_i8, 10, sizeof(float), (void *)&scale);
    err |= clSetKernelArg(ocl_kernel_adam_i8, 11, sizeof(int), (void *)&size);
    err |= clSetKernelArg(ocl_kernel_adam_i8, 12, sizeof(int), (void *)&is_sparse);
    err |= clSetKernelArg(ocl_kernel_adam_i8, 13, sizeof(int), (void *)&cols);
    err |= clSetKernelArg(ocl_kernel_adam_i8, 14, sizeof(int), (void *)&bound_r);
    err |= clSetKernelArg(ocl_kernel_adam_i8, 15, sizeof(int), (void *)&bound_c);
    err |= clSetKernelArg(ocl_kernel_adam_i8, 16, sizeof(float), (void *)&boost);
    err |= clSetKernelArg(ocl_kernel_adam_i8, 17, sizeof(float), (void *)&wd);
    if (err != CL_SUCCESS) return;

    size_t local_item_size = ocl_max_work_group_size;
    size_t global_item_size = (((size_t)size + local_item_size - 1) / local_item_size) * local_item_size;
    ocl_nd(ocl_queue, ocl_kernel_adam_i8, 1, NULL, &global_item_size, &local_item_size, 0, NULL, NULL);

    ocl_rd(ocl_queue, d_w, CL_TRUE, 0, bytes_w, h_w, 0, NULL, NULL);
    ocl_rd(ocl_queue, d_m, CL_TRUE, 0, bytes_f, h_m, 0, NULL, NULL);
    ocl_rd(ocl_queue, d_v, CL_TRUE, 0, bytes_f, h_v, 0, NULL, NULL);

    memset(h_g, 0, bytes_f);
}

// PHASE 10 DES INT8-UMBAUS: Host-Wrapper fuer adamRowFloatI8. Anders als
// ocl_adamStepI8 wird hier EINE WORKGROUP JE ZEILE gestartet und die
// Zeilenskala vom Kernel GESCHRIEBEN (nicht nur gelesen) - sie muss deshalb
// zurueckgelesen werden. h_res darf NULL sein (dann ohne Rueckfuehrung).
void ocl_adamRowFloatI8(signed char* h_w, float* h_wscale, float* h_m, float* h_v, float* h_g,
                        float* h_res, float lr, float b1, float b2, float b1t, float b2t,
                        float scale, int rows, int cols, int is_sparse,
                        int bound_r, int bound_c, float boost, float wd, int use_fb) {
    if (!ocl_ctx || !h_w || !h_wscale || !h_m || !h_v || !h_g || rows <= 0 || cols <= 0 || scale == 0.0f) return;
    size_t size = (size_t)rows * (size_t)cols;
    size_t bytes_w = size * sizeof(signed char);
    size_t bytes_f = size * sizeof(float);
    size_t bytes_scale = (size_t)rows * sizeof(float);
    int fb = (use_fb == 1 && h_res != NULL) ? 1 : 0;

    cl_mem d_w = ocl_get_buffer((void*)h_w, bytes_w);
    cl_mem d_wscale = ocl_get_buffer((void*)h_wscale, bytes_scale);
    cl_mem d_m = ocl_get_buffer((void*)h_m, bytes_f);
    cl_mem d_v = ocl_get_buffer((void*)h_v, bytes_f);
    cl_mem d_g = ocl_get_buffer((void*)h_g, bytes_f);
    // Ohne Rueckfuehrung braucht der Kernel trotzdem ein gueltiges Argument -
    // d_g dient dann als Platzhalter und wird wegen fb==0 nie angefasst.
    cl_mem d_res = fb ? ocl_get_buffer((void*)h_res, bytes_f) : d_g;
    if (!d_w || !d_wscale || !d_m || !d_v || !d_g || !d_res) return;

    ocl_wr(ocl_queue, d_g, CL_TRUE, 0, bytes_f, h_g, 0, NULL, NULL);
    if (fb) ocl_wr(ocl_queue, d_res, CL_TRUE, 0, bytes_f, h_res, 0, NULL, NULL);

    // local_size MUSS Zweierpotenz sein (Reduktion halbiert), <= cols und <= HW-Limit
    size_t local_item_size = 1;
    while (local_item_size * 2 <= ocl_max_work_group_size && (int)(local_item_size * 2) <= cols) local_item_size *= 2;
    size_t global_item_size = (size_t)rows * local_item_size;

    cl_int err;
    err  = clSetKernelArg(ocl_kernel_adam_row_i8, 0, sizeof(cl_mem), (void *)&d_w);
    err |= clSetKernelArg(ocl_kernel_adam_row_i8, 1, sizeof(cl_mem), (void *)&d_wscale);
    err |= clSetKernelArg(ocl_kernel_adam_row_i8, 2, sizeof(cl_mem), (void *)&d_m);
    err |= clSetKernelArg(ocl_kernel_adam_row_i8, 3, sizeof(cl_mem), (void *)&d_v);
    err |= clSetKernelArg(ocl_kernel_adam_row_i8, 4, sizeof(cl_mem), (void *)&d_g);
    err |= clSetKernelArg(ocl_kernel_adam_row_i8, 5, sizeof(cl_mem), (void *)&d_res);
    err |= clSetKernelArg(ocl_kernel_adam_row_i8, 6, sizeof(float), (void *)&lr);
    err |= clSetKernelArg(ocl_kernel_adam_row_i8, 7, sizeof(float), (void *)&b1);
    err |= clSetKernelArg(ocl_kernel_adam_row_i8, 8, sizeof(float), (void *)&b2);
    err |= clSetKernelArg(ocl_kernel_adam_row_i8, 9, sizeof(float), (void *)&b1t);
    err |= clSetKernelArg(ocl_kernel_adam_row_i8, 10, sizeof(float), (void *)&b2t);
    err |= clSetKernelArg(ocl_kernel_adam_row_i8, 11, sizeof(float), (void *)&scale);
    err |= clSetKernelArg(ocl_kernel_adam_row_i8, 12, sizeof(int), (void *)&cols);
    err |= clSetKernelArg(ocl_kernel_adam_row_i8, 13, sizeof(int), (void *)&is_sparse);
    err |= clSetKernelArg(ocl_kernel_adam_row_i8, 14, sizeof(int), (void *)&bound_r);
    err |= clSetKernelArg(ocl_kernel_adam_row_i8, 15, sizeof(int), (void *)&bound_c);
    err |= clSetKernelArg(ocl_kernel_adam_row_i8, 16, sizeof(float), (void *)&boost);
    err |= clSetKernelArg(ocl_kernel_adam_row_i8, 17, sizeof(float), (void *)&wd);
    err |= clSetKernelArg(ocl_kernel_adam_row_i8, 18, sizeof(int), (void *)&fb);
    err |= clSetKernelArg(ocl_kernel_adam_row_i8, 19, local_item_size * sizeof(float), NULL);
    if (err != CL_SUCCESS) return;

    ocl_nd(ocl_queue, ocl_kernel_adam_row_i8, 1, NULL, &global_item_size, &local_item_size, 0, NULL, NULL);

    ocl_rd(ocl_queue, d_w, CL_TRUE, 0, bytes_w, h_w, 0, NULL, NULL);
    ocl_rd(ocl_queue, d_wscale, CL_TRUE, 0, bytes_scale, h_wscale, 0, NULL, NULL);
    ocl_rd(ocl_queue, d_m, CL_TRUE, 0, bytes_f, h_m, 0, NULL, NULL);
    ocl_rd(ocl_queue, d_v, CL_TRUE, 0, bytes_f, h_v, 0, NULL, NULL);
    if (fb) ocl_rd(ocl_queue, d_res, CL_TRUE, 0, bytes_f, h_res, 0, NULL, NULL);

    memset(h_g, 0, bytes_f);
}
static const char* adam_q_source =
"// OCL-ADAM (2026-11-12): Gegenstueck zu adamRowQI8Kernel in cortex_cuda.cu (multi_stack 3a982dc / Hauptbaum a44d2fd),\n"
"// Zeile fuer Zeile. Eigenes Programm, nur gebaut, wenn das Geraet double kann (cl_khr_fp64).\n"
"// Rundung wie CUDA: kein Zusammenziehen (FP_CONTRACT OFF, entspricht __fmul_rn/__dadd_rn); float-Division und\n"
"// float-Wurzel ueber double (korrekt gerundet: 53 >= 2*24+2), weil OpenCL sie in float nur auf 2,5 ulp garantiert.\n"
"#pragma OPENCL EXTENSION cl_khr_fp64 : enable\n"
"#pragma OPENCL FP_CONTRACT OFF\n"
"#define QA_TPB 256\n"
"#define QA_QN 1024\n"
"#define QA_V_KLEMME 1\n"
"\n"
"// SOFT_DN (Bauoption -DSOFT_DN=1, wenn das Geraet keine float-Denormale hat, z. B. rusticl/radeonsi): jede float-Rechnung\n"
"// ueber double, float<->double ueber die Bits (die Hardware setzte Denormale sonst auf null, gemessen 12.11. mit dn.cl).\n"
"// Eine einzelne +,-,*,/,sqrt in double und Rueckrundung auf float ist korrekt gerundet (53 >= 2*24+2).\n"
"#ifndef SOFT_DN\n"
"#define SOFT_DN 0\n"
"#endif\n"
"#if SOFT_DN\n"
"inline double F2D(float x) {\n"
"    uint u = as_uint(x);\n"
"    if ((u & 0x7f800000u) == 0 && (u & 0x7fffffu) != 0) {\n"
"        double m = (double)(u & 0x7fffffu) * 0x1p-149;\n"
"        return (u >> 31) ? -m : m;\n"
"    }\n"
"    return (double)x;\n"
"}\n"
"inline float D2F(double d) {\n"
"    double a = fabs(d);\n"
"    if (a < 0x1p-126 && a != 0.0) {\n"
"        uint u = (uint)rint(a * 0x1p149);\n"
"        if (d < 0.0) u |= 0x80000000u;\n"
"        return as_float(u);\n"
"    }\n"
"    return (float)d;\n"
"}\n"
"#define FM_S(a, b) D2F(F2D(a) * F2D(b))\n"
"#define FA_S(a, b) D2F(F2D(a) + F2D(b))\n"
"#define FS_S(a, b) D2F(F2D(a) - F2D(b))\n"
"#else\n"
"#define F2D(x) ((double)(x))\n"
"#define D2F(d) ((float)(d))\n"
"#define FM_S(a, b) ((a) * (b))\n"
"#define FA_S(a, b) ((a) + (b))\n"
"#define FS_S(a, b) ((a) - (b))\n"
"#endif\n"
"inline float FNEG(float x) { return as_float(as_uint(x) ^ 0x80000000u); }\n"
"inline float FABS(float x) { return as_float(as_uint(x) & 0x7fffffffu); }\n"
"// OCL-ATT-SN / OCL-SN2: nativer float-Kurzweg, exakt gleich FA_S/FS_S/FM_S: keine Eingabe denormal und entweder\n"
"// |r| >= 2^-125 (Normalbereich, Rundung mit und ohne Unterlauf gleich) oder ein exaktes Nullergebnis (keine Rundung).\n"
"#ifndef ATT_SN\n"
"#define ATT_SN 0\n"
"#endif\n"
"#ifndef SN_ADAM\n"
"#define SN_ADAM 0\n"
"#endif\n"
"#ifndef SN_ROT\n"
"#define SN_ROT 0\n"
"#endif\n"
"inline int nodn(float x) { uint u = as_uint(x); return (u & 0x7f800000u) != 0 || (u & 0x7fffffu) == 0; }\n"
"#if SOFT_DN && (ATT_SN || SN_ADAM)\n"
"inline float FAq(float a, float b) { if (nodn(a) && nodn(b)) { float r = a + b;\n"
"    if (FABS(r) >= 0x1p-125f || (a == -b && isfinite(a))) return r; } return FA_S(a, b); }\n"
"inline float FSq(float a, float b) { if (nodn(a) && nodn(b)) { float r = a - b;\n"
"    if (FABS(r) >= 0x1p-125f || (a == b && isfinite(a))) return r; } return FS_S(a, b); }\n"
"inline float FMq(float a, float b) { if (nodn(a) && nodn(b)) { float r = a * b;\n"
"    if (FABS(r) >= 0x1p-125f) return SN_ROT ? as_float(as_uint(r) ^ 1u) : r;\n"
"    if ((a == 0.0f && isfinite(b)) || (b == 0.0f && isfinite(a))) return r; } return FM_S(a, b); }\n"
"#else\n"
"#define FAq(a, b) FA_S(a, b)\n"
"#define FSq(a, b) FS_S(a, b)\n"
"#define FMq(a, b) FM_S(a, b)\n"
"#endif\n"
"#if SOFT_DN && SN_ADAM\n"
"#define FM(a, b) FMq(a, b)\n"
"#define FA(a, b) FAq(a, b)\n"
"#define FS(a, b) FSq(a, b)\n"
"#else\n"
"#define FM(a, b) FM_S(a, b)\n"
"#define FA(a, b) FA_S(a, b)\n"
"#define FS(a, b) FS_S(a, b)\n"
"#endif\n"
"inline float FMAX(float a, float b) { if (isnan(a)) return b; if (isnan(b)) return a; return F2D(a) >= F2D(b) ? a : b; }\n"
"inline float FFLOOR(float x) { return D2F(floor(F2D(x))); }\n"
"inline float FNEXTDOWN(float a) { uint u = as_uint(a); return (u & 0x7fffffffu) == 0 ? a : as_float(u - 1); }   // a >= 0\n"
"// Korrekt gerundete double-Division und -Wurzel aus fma (Markstein). rusticl/radeonsi rechnet / und sqrt in double nur auf\n"
"// ~2^-24 genau (gemessen 12.11., dbl.c: 10^6 von 10^6 falsch, bis 4e8 ulp); fma, * und + sind dort exakt (dbl2.c: 0 von 10^6).\n"
"#ifndef NATIVE_DDIV\n"
"#define NATIVE_DDIV 0\n"
"#endif\n"
"#if NATIVE_DDIV\n"
"inline double DDIV(double x, double y) { return x / y; }\n"
"inline double DSQRT(double x) { return sqrt(x); }\n"
"#else\n"
"inline double DDIV(double x, double y) {\n"
"    double r = 1.0 / y;\n"
"    double e = fma(-y, r, 1.0); r = fma(r, e, r);\n"
"    e = fma(-y, r, 1.0); r = fma(r, e, r);\n"
"    e = fma(-y, r, 1.0); r = fma(r, e, r);\n"
"    double q = x * r;\n"
"    double rem = fma(-q, y, x);\n"
"    return fma(rem, r, q);\n"
"}\n"
"inline double DSQRT(double x) {\n"
"    if (!(x > 0.0) || isinf(x)) return sqrt(x);\n"
"    double y = rsqrt(x);\n"
"    double h = 0.5 * y;\n"
"    double g = x * y;\n"
"    for (int k = 0; k < 3; k++) { double r = fma(-g, h, 0.5); g = fma(g, r, g); h = fma(h, r, h); }\n"
"    double d = fma(-g, g, x);\n"
"    return fma(d, h, g);\n"
"}\n"
"#endif\n"
"inline float fdivr_s(float a, float b) { return D2F(DDIV(F2D(a), F2D(b))); }\n"
"inline float fsqrtr_s(float a) { return D2F(DSQRT(F2D(a))); }\n"
"// OCL-SN2 SN_DIV: float-Division/-Wurzel aus der nativen Naeherung (<= 3 ulp), geprueft mit exaktem Rest per double-fma\n"
"// (fma, * und + sind auch unter rusticl exakt). Angenommen nur weit innerhalb des Rundungsintervalls (Faktor 1-2^-20);\n"
"// Zweierpotenzen, |q| < 2^-125, denormale/unendliche Eingaben und Unklares gehen ueber den bisherigen Weg.\n"
"#ifndef SN_DIV\n"
"#define SN_DIV 0\n"
"#endif\n"
"inline double sn_ulp(float q) { int e = (int)((as_uint(q) >> 23) & 0xffu); return as_double((ulong)(e - 150 + 1023) << 52); }\n"
"inline int sn_ok(float q) { return FABS(q) >= 0x1p-125f && isfinite(q) && (as_uint(q) & 0x7fffffu) != 0; }\n"
"inline float sn_step(float q, int up) { uint u = as_uint(q); return as_float(((q > 0.0f) == (up != 0)) ? u + 1u : u - 1u); }\n"
"inline float fdivq(float a, float b) {\n"
"    if (nodn(a) && nodn(b) && isfinite(a) && isfinite(b) && a != 0.0f && b != 0.0f) {\n"
"        float q = a / b;\n"
"        if (SN_DIV == 2) return q;\n"
"        const double ad = (double)a, bd = (double)b;\n"
"        for (int it = 0; it < 4; it++) {\n"
"            if (!sn_ok(q)) break;\n"
"            double e = fma(-(double)q, bd, ad);\n"
"            double h = fabs(bd) * sn_ulp(q) * 0.5;\n"
"            double ea = fabs(e);\n"
"            if (ea < h * (1.0 - 0x1p-20)) return q;\n"
"            if (!(ea > h * (1.0 + 0x1p-20))) break;\n"
"            q = sn_step(q, (e > 0.0) == (bd > 0.0));\n"
"        }\n"
"    }\n"
"    return fdivr_s(a, b);\n"
"}\n"
"inline float fsqrtq(float a) {\n"
"    if (nodn(a) && isfinite(a) && a > 0.0f) {\n"
"        float s = sqrt(a);\n"
"        if (SN_DIV == 2) return s;\n"
"        const double ad = (double)a;\n"
"        for (int it = 0; it < 4; it++) {\n"
"            if (!sn_ok(s)) break;\n"
"            double e = fma(-(double)s, (double)s, ad);\n"
"            double h = (double)s * sn_ulp(s);\n"
"            double ea = fabs(e);\n"
"            if (ea < h * (1.0 - 0x1p-20)) return s;\n"
"            if (!(ea > h * (1.0 + 0x1p-20))) break;\n"
"            s = sn_step(s, e > 0.0);\n"
"        }\n"
"    }\n"
"    return fsqrtr_s(a);\n"
"}\n"
"#if SN_DIV && !NATIVE_DDIV\n"
"inline float fdivr(float a, float b) { return fdivq(a, b); }\n"
"inline float fsqrtr(float a) { return fsqrtq(a); }\n"
"#else\n"
"inline float fdivr(float a, float b) { return fdivr_s(a, b); }\n"
"inline float fsqrtr(float a) { return fsqrtr_s(a); }\n"
"#endif\n"
"\n"
"inline float qaGet(__global const uchar* d, __global const float* sc, __global const float* tab,\n"
"                   size_t i, int row, int sgn) {\n"
"    uchar b = d[i];\n"
"    if (b == 0) return 0.0f;\n"
"    float s = sc[row];\n"
"    if (sgn) {\n"
"        int mag = b & 0x7F;\n"
"        if (mag == 0) return 0.0f;\n"
"        float v = FM(s, tab[mag]);\n"
"        return (b & 0x80) ? FNEG(v) : v;\n"
"    }\n"
"    return FM(s, tab[b]);\n"
"}\n"
"\n"
"float qaBlockMax(float x, __local float* red) {\n"
"    int lid = get_local_id(0);\n"
"    barrier(CLK_LOCAL_MEM_FENCE);\n"
"    red[lid] = x;\n"
"    barrier(CLK_LOCAL_MEM_FENCE);\n"
"    for (int st = get_local_size(0) / 2; st > 0; st >>= 1) {\n"
"        if (lid < st) red[lid] = FMAX(red[lid], red[lid + st]);\n"
"        barrier(CLK_LOCAL_MEM_FENCE);\n"
"    }\n"
"    float r = red[0];\n"
"    barrier(CLK_LOCAL_MEM_FENCE);\n"
"    return r;\n"
"}\n"
"\n"
"inline ulong qaMix(ulong h) {\n"
"    h += 11400714819323198485UL;\n"
"    h = (h ^ (h >> 30)) * 13787848793156543929UL;\n"
"    h = (h ^ (h >> 27)) * 10723151780598845931UL;\n"
"    return h ^ (h >> 31);\n"
"}\n"
"inline ulong qaKey(float x, int row, int c, ulong salt) {\n"
"    return (ulong)as_uint(x) ^ ((ulong)(long)row << 32) ^ ((ulong)(long)c << 12) ^ salt;\n"
"}\n"
"inline double qaSrUniform(float x, int row, int c, int sgn, ulong salt) {\n"
"    ulong h = qaKey(x, row, c, salt);\n"
"    if (sgn) h ^= 6364136223846793005UL;\n"
"    return (double)(qaMix(h) >> 11) * 1.1102230246251565e-16;\n"
"}\n"
"inline float qaSrUniformF(float x, int row, int c, int sgn, ulong salt) {\n"
"    ulong h = qaKey(x, row, c, salt);\n"
"    if (sgn) h ^= 6364136223846793005UL;\n"
"    return FM(convert_float_rte(qaMix(h) >> 11), 1.1102230246251565e-16f);\n"
"}\n"
"inline double restSrU(float x, int row, int c, ulong salt) {\n"
"    ulong h = qaKey(x, row, c, salt) ^ 11562461410679940143UL;\n"
"    return (double)(qaMix(h) >> 11) * 1.1102230246251565e-16;\n"
"}\n"
"inline float restSrUF(float x, int row, int c, ulong salt) {\n"
"    ulong h = qaKey(x, row, c, salt) ^ 11562461410679940143UL;\n"
"    return FM(convert_float_rte(qaMix(h) >> 11), 1.1102230246251565e-16f);\n"
"}\n"
"\n"
"inline uchar qaCode(long qi, long qmax, int sgn, float x) {\n"
"    if (qi < 1) qi = 1; else if (qmax < qi) qi = qmax;\n"
"    if (sgn) {\n"
"        uchar b = (uchar)((uchar)qi & 0x7F);\n"
"        if (F2D(x) < 0.0) b = b | 0x80;\n"
"        return b;\n"
"    }\n"
"    return (uchar)qi;\n"
"}\n"
"\n"
"void qaStoreRow(__global uchar* d, __global float* sc, __global const float* buf, size_t off, int cols, int row,\n"
"                int sgn, double lgr, __local float* red, int sr, ulong salt, int fast,\n"
"                __local int* qaQ, __local int* qaQn) {\n"
"    int lid = get_local_id(0), lsz = get_local_size(0);\n"
"    if (lid == 0) *qaQn = 0;   // sichtbar nach den Barrieren in qaBlockMax\n"
"    float mx = 0.0f;\n"
"    for (int c = lid; c < cols; c += lsz) mx = FMAX(mx, FABS(buf[off + c]));\n"
"    mx = qaBlockMax(mx, red);\n"
"    if (lid == 0) sc[row] = mx;\n"
"    if (F2D(mx) <= 0.0) {\n"
"        for (int c = lid; c < cols; c += lsz) d[off + c] = 0;\n"
"        return;\n"
"    }\n"
"    double lo = DDIV(F2D(mx), 100000000.0);\n"
"    double steps = sgn ? 126.0 : 254.0;\n"
"    long qmax = sgn ? 127 : 255;\n"
"    const int fLog = fast & 1, fSr = fast & 2;\n"
"    const float fG = (fast & 32) ? -1.0f : (float)(1.0 / 256.0);\n"
"    float fSteps = 0.0f, fLnd = 0.0f, fIlg = 0.0f;\n"
"    if (fLog) { fSteps = sgn ? 126.0f : 254.0f; fLnd = D2F(log(DDIV(F2D(mx), lo))); fIlg = D2F(DDIV(1.0, lgr)); }\n"
"    for (int c = lid; c < cols; c += lsz) {\n"
"        float x = buf[off + c];\n"
"        float ax = FABS(x);\n"
"        if (F2D(ax) <= lo) { d[off + c] = (QA_V_KLEMME && !sgn && F2D(ax) > 0.0) ? 1 : 0; continue; }\n"
"        double t34 = 0.0;\n"
"        bool ok = false;\n"
"        if (fLog) {\n"
"            float af = FM(FM(fSteps, FA(log(fdivr(ax, mx)), fLnd)), fIlg);\n"
"            if (sr) {\n"
"                if (fSr) {\n"
"                    float sf = FA(af, qaSrUniformF(x, row, c, sgn, salt));\n"
"                    float fl = FFLOOR(sf);\n"
"                    float fr = FS(sf, fl);\n"
"                    ok = (F2D(fr) > F2D(fG)) && (F2D(fr) < F2D(FS(1.0f, fG)));\n"
"                    t34 = F2D(fl);\n"
"                } else {\n"
"                    double sd = F2D(af) + qaSrUniform(x, row, c, sgn, salt);\n"
"                    double fl = floor(sd);\n"
"                    double fr = sd - fl;\n"
"                    ok = (fr > (double)fG) && (fr < 1.0 - (double)fG);\n"
"                    t34 = fl;\n"
"                }\n"
"            } else {\n"
"                float fl = FFLOOR(af);\n"
"                float fr = FS(af, fl);\n"
"                ok = F2D(FABS(FS(fr, 0.5f))) > F2D(fG);\n"
"                t34 = F2D((F2D(fr) < 0.5) ? fl : FA(fl, 1.0f));\n"
"            }\n"
"        }\n"
"        if (!ok && (fast & 64)) {\n"
"            int k = atomic_inc(qaQn);\n"
"            if (k < QA_QN) { qaQ[k] = c; continue; }\n"
"        }\n"
"        if (!ok) {\n"
"            double t33 = log(DDIV(F2D(ax), lo));\n"
"            t34 = sr ? floor(DDIV(steps * t33, lgr) + qaSrUniform(x, row, c, sgn, salt))\n"
"                     : round(DDIV(steps * t33, lgr));\n"
"        }\n"
"        d[off + c] = qaCode(1 + (long)t34, qmax, sgn, x);\n"
"    }\n"
"    if (fast & 64) {\n"
"        barrier(CLK_LOCAL_MEM_FENCE);\n"
"        int nq = *qaQn < QA_QN ? *qaQn : QA_QN;\n"
"        for (int k = lid; k < nq; k += lsz) {\n"
"            int c = qaQ[k];\n"
"            float x = buf[off + c];\n"
"            float ax = FABS(x);\n"
"            double t33 = log(DDIV(F2D(ax), lo));\n"
"            double t34 = sr ? floor(DDIV(steps * t33, lgr) + qaSrUniform(x, row, c, sgn, salt))\n"
"                            : round(DDIV(steps * t33, lgr));\n"
"            d[off + c] = qaCode(1 + (long)t34, qmax, sgn, x);\n"
"        }\n"
"        barrier(CLK_LOCAL_MEM_FENCE);\n"
"    }\n"
"}\n"
"\n"
"// Ein Arbeitsgruppe je Zeile, QA_TPB Faeden. Zaehler (Telemetrie): je Zeile in rstat[row*10 + k] und rwd[row]\n"
"// statt globaler 64-Bit-Atomics (rusticl hat keine); der Host summiert. Nur Telemetrie, geht nicht ins Modell.\n"
"__kernel void adamRowQI8(__global char* w, __global float* wscale, __global uchar* mqd, __global float* mqs,\n"
"                         __global uchar* vqd, __global float* vqs, __global float* g, __global float* res,\n"
"                         __global float* mb, __global float* vb,\n"
"                         __global const float* tabM, __global const float* tabV,\n"
"                         float lr, float b1, float b2, float b1t, float b2t, float gscale,\n"
"                         int cols, int is_sparse, int bound_r, int bound_c, float boost, float wd,\n"
"                         int use_fb, double lgr, int sr_mask, ulong sr_salt,\n"
"                         int rmode, __global short* rc16, __global char* rc8, __global float* rsk,\n"
"                         __global ulong* rstat, __global double* rwd, int rrot, int rtele, int fast) {\n"
"    __local float red[QA_TPB];\n"
"    __local double redd[QA_TPB];\n"
"    __local int wqQ[QA_QN];\n"
"    __local int wqQn;\n"
"    __local int qaQ[QA_QN];\n"
"    __local int qaQn;\n"
"    __local int touched;\n"
"    __local uint lcnt[10];\n"
"    const float fG = (fast & 32) ? -1.0f : (float)(1.0 / 256.0);\n"
"    const int fRot = fast & 32;\n"
"    int row = get_group_id(0);\n"
"    int lid = get_local_id(0);\n"
"    int lsz = get_local_size(0);\n"
"    if (lid == 0) { wqQn = 0; touched = 0; }\n"
"    if (lid < 10) lcnt[lid] = 0;\n"
"    size_t off = (size_t)row * (size_t)cols;\n"
"    float qscale = wscale[row];\n"
"    for (int c = lid; c < cols; c += lsz) {\n"
"        mb[off + c] = qaGet(mqd, mqs, tabM, off + c, row, 1);\n"
"        vb[off + c] = qaGet(vqd, vqs, tabV, off + c, row, 0);\n"
"    }\n"
"    barrier(CLK_LOCAL_MEM_FENCE | CLK_GLOBAL_MEM_FENCE);\n"
"    float localMax = 0.0f;\n"
"    int myTouched = 0;\n"
"    const int rcode = use_fb && (rmode == 16 || rmode == 8 || rmode == 9);\n"
"    const float rFak = (rmode == 16) ? 32767.0f : ((rmode == 9) ? 254.0f : 127.0f);\n"
"    const float rKInv = (float)DDIV(1.0, (rmode == 16) ? 32767.0 : ((rmode == 9) ? 254.0 : 127.0));\n"
"    const float rFakEnc = (rrot == 2) ? ((rmode == 16) ? 16383.0f : ((rmode == 9) ? 127.0f : 63.0f)) : rFak;\n"
"    const float decScale = (rrot == 1 && rcode) ? wscale[(row + 1) % (int)get_num_groups(0)] : qscale;\n"
"    const float rSkRow = rcode ? rsk[row] : 0.0f;\n"
"    uint lSkF = 0, lAuF = 0, lU128 = 0, lN = 0, lWdN = 0, lH0 = 0, lH1 = 0, lH2 = 0, lH3 = 0, lH4 = 0;\n"
"    double lWd = 0.0;\n"
"    for (int c = lid; c < cols; c += lsz) {\n"
"        size_t i = off + (size_t)c;\n"
"        float wf0 = FM((float)w[i], qscale);\n"
"        float grad = fdivr(g[i], gscale);\n"
"        float wf = wf0;\n"
"        if (!(F2D(gscale) == 0.0) && !(isnan(grad) || 9999.0 < F2D(grad) || F2D(grad) < -9999.0)) {\n"
"            if (!(is_sparse && F2D(FABS(grad)) < 1e-8)) {\n"
"                float mCur = mb[i];\n"
"                float vCur = vb[i];\n"
"                if (fast & 16) {   // DIAG_MOMF: NUR Zeitdiagnose, nicht bitgleich\n"
"                    mCur = fma(1.0f - b1, grad, b1 * mCur);\n"
"                    vCur = fma((1.0f - b2) * grad, grad, b2 * vCur);\n"
"                } else {\n"
"                    mCur = D2F(F2D(FM(b1, mCur)) + (1.0 - F2D(b1)) * F2D(grad));\n"
"                    vCur = D2F(F2D(FM(b2, vCur)) + ((1.0 - F2D(b2)) * F2D(grad)) * F2D(grad));\n"
"                }\n"
"                myTouched = 1;\n"
"                mb[i] = mCur;\n"
"                vb[i] = vCur;\n"
"                float m_hat = fdivr(mCur, b1t);\n"
"                float v_hat = fdivr(vCur, b2t);\n"
"                float bst = (row >= bound_r || c >= bound_c) ? boost : 1.0f;\n"
"                float t59 = fsqrtr(v_hat);\n"
"                bool okd = false;\n"
"                if (fast & 8) {\n"
"                    float P = FM(FM(lr, bst), m_hat);\n"
"                    float q = fdivr(P, FA(t59, 1e-8f));\n"
"                    float sf = FS(wf0, q);\n"
"                    float bb = FS(sf, wf0);\n"
"                    float e = FA(FS(wf0, FS(sf, bb)), FS(FNEG(q), bb));\n"
"                    float as = FABS(sf);\n"
"                    float hu = FM(FS(as, FNEXTDOWN(as)), 0.5f);\n"
"                    float sch = FA(FM(FABS(q), 4.0e-7f), FM(as, 1.0e-12f));\n"
"                    okd = fRot || (isfinite(sf) && isfinite(q) && F2D(as) > F2D(1.0e-30f) && F2D(FA(FABS(e), sch)) < F2D(hu));\n"
"                    if (okd) wf = sf;\n"
"                }\n"
"                if (!okd)\n"
"                    wf = D2F(F2D(wf0) - DDIV(F2D(FM(FM(lr, bst), m_hat)), F2D(t59) + 1e-8));\n"
"                if (0.0 < F2D(wd)) wf = FS(wf, FM(FM(lr, wd), wf0));\n"
"                if (rtele) {\n"
"                    lN++;\n"
"                    if (F2D(FABS(FS(wf, wf0))) < F2D(qscale) * 0.0078125) lU128++;\n"
"                    if (0.0 < F2D(wd) && 0.0 < F2D(qscale)) {\n"
"                        lWd += F2D(fdivr(FM(FM(lr, wd), FABS(wf0)), qscale)); lWdN++;\n"
"                    }\n"
"                }\n"
"            }\n"
"        }\n"
"        if (use_fb) {\n"
"            if (!rcode) wf = FA(wf, res[i]);\n"
"            else {\n"
"                float cd = (rmode == 16) ? (float)rc16[i] : (float)rc8[i];\n"
"                if (!(F2D(cd) == 0.0) && as_uint(decScale) != as_uint(rSkRow)) lSkF++;\n"
"                wf = FA(wf, FM(FM(cd, rKInv), decScale));\n"
"            }\n"
"        }\n"
"        g[i] = wf;\n"
"        localMax = FMAX(localMax, FABS(wf));\n"
"    }\n"
"    if (myTouched) touched = 1;\n"
"    barrier(CLK_GLOBAL_MEM_FENCE);\n"
"    float maxAbs = qaBlockMax(localMax, red);\n"
"    if (touched) {\n"
"        qaStoreRow(mqd, mqs, mb, off, cols, row, 1, lgr, red, sr_mask & 1, sr_salt, fast, qaQ, &qaQn);\n"
"        qaStoreRow(vqd, vqs, vb, off, cols, row, 0, lgr, red, sr_mask & 2, sr_salt, fast, qaQ, &qaQn);\n"
"    }\n"
"    double newScale = (0.0 < F2D(maxAbs)) ? DDIV(F2D(maxAbs), 127.0) : F2D(qscale);\n"
"    barrier(CLK_GLOBAL_MEM_FENCE);\n"
"    if (lid == 0) wscale[row] = D2F(newScale);\n"
"    double inv = DDIV(1.0, newScale);\n"
"    const float invF = D2F(inv);\n"
"    if (rcode && lid == 0) rsk[row] = D2F(newScale);\n"
"    for (int c = lid; c < cols; c += lsz) {\n"
"        size_t i = off + (size_t)c;\n"
"        float target = g[i];\n"
"        double t92 = 0.0;\n"
"        bool okq = false;\n"
"        if ((fast & 4) && rmode == 1) {\n"
"            float sq = FA(FM(target, invF), restSrUF(target, row, c, sr_salt));\n"
"            float fl = FFLOOR(sq);\n"
"            float fr = FS(sq, fl);\n"
"            okq = (F2D(fr) > F2D(fG)) && (F2D(fr) < F2D(FS(1.0f, fG)));\n"
"            t92 = F2D(fl);\n"
"        }\n"
"        if (!okq && (fast & 64) && !use_fb) {\n"
"            int k = atomic_inc(&wqQn);\n"
"            if (k < QA_QN) { wqQ[k] = c; continue; }\n"
"        }\n"
"        if (!okq)\n"
"            t92 = (rmode == 1) ? floor(F2D(target) * inv + F2D(D2F(restSrU(target, row, c, sr_salt))))\n"
"                               : round(F2D(target) * inv);\n"
"        long q = (long)t92;\n"
"        if (127 < q) q = 127; else if (q < -128) q = -128;\n"
"        w[i] = (char)q;\n"
"        if (use_fb) {\n"
"            double e = F2D(target) - (double)q * newScale;\n"
"            if (newScale < e) e = newScale; else if (e < -newScale) e = -newScale;\n"
"            if (rtele && 0.0 < newScale) {\n"
"                double a = DDIV(fabs(e), newScale);\n"
"                if (a < 0.125) lH0++; else if (a < 0.25) lH1++; else if (a < 0.5) lH2++; else if (a < 1.0) lH3++; else lH4++;\n"
"            }\n"
"            if (!rcode) res[i] = D2F(e);\n"
"            else {\n"
"                double rel = e * inv;\n"
"                long cd;\n"
"                if (rmode == 16) cd = (long)round(rel * F2D(rFakEnc));\n"
"                else cd = (long)floor(rel * F2D(rFakEnc) + F2D(D2F(restSrU(D2F(e), row, c, sr_salt))));\n"
"                long lim = (rmode == 16) ? 32767 : 127;\n"
"                if (lim < cd) cd = lim; else if (cd < -lim) cd = -lim;\n"
"                if (rmode == 16) rc16[i] = (short)cd; else rc8[i] = (char)cd;\n"
"                double dec = F2D(FM((float)cd, rKInv)) * newScale;\n"
"                double tol = (newScale * ((rmode == 16) ? DDIV(0.5, 32767.0) : DDIV(1.0, (rmode == 9) ? 254.0 : 127.0))) * 1.001;\n"
"                if (tol < fabs(dec - e)) lAuF++;\n"
"            }\n"
"        }\n"
"    }\n"
"    if ((fast & 64) && !use_fb) {\n"
"        barrier(CLK_LOCAL_MEM_FENCE);\n"
"        int nq = wqQn < QA_QN ? wqQn : QA_QN;\n"
"        for (int k = lid; k < nq; k += lsz) {\n"
"            int c = wqQ[k];\n"
"            size_t i = off + (size_t)c;\n"
"            float target = g[i];\n"
"            double t92 = (rmode == 1) ? floor(F2D(target) * inv + F2D(D2F(restSrU(target, row, c, sr_salt))))\n"
"                                      : round(F2D(target) * inv);\n"
"            long q = (long)t92;\n"
"            if (127 < q) q = 127; else if (q < -128) q = -128;\n"
"            w[i] = (char)q;\n"
"        }\n"
"    }\n"
"    // Zaehler je Zeile (lokal summiert, Reihenfolge egal: ganze Zahlen; lWd in fester Baumreihenfolge)\n"
"    if (lSkF) atomic_add(&lcnt[0], lSkF); if (lAuF) atomic_add(&lcnt[1], lAuF);\n"
"    if (lU128) atomic_add(&lcnt[2], lU128); if (lN) atomic_add(&lcnt[3], lN); if (lWdN) atomic_add(&lcnt[4], lWdN);\n"
"    if (lH0) atomic_add(&lcnt[5], lH0); if (lH1) atomic_add(&lcnt[6], lH1); if (lH2) atomic_add(&lcnt[7], lH2);\n"
"    if (lH3) atomic_add(&lcnt[8], lH3); if (lH4) atomic_add(&lcnt[9], lH4);\n"
"    redd[lid] = lWd;\n"
"    barrier(CLK_LOCAL_MEM_FENCE);\n"
"    for (int st = lsz / 2; st > 0; st >>= 1) {\n"
"        if (lid < st) redd[lid] = redd[lid] + redd[lid + st];\n"
"        barrier(CLK_LOCAL_MEM_FENCE);\n"
"    }\n"
"    if (lid < 10) rstat[(size_t)row * 10 + lid] = (ulong)lcnt[lid];\n"
"    if (lid == 0) rwd[row] = redd[0];\n"
"}\n"
"\n"
"// OCL-ATT (2026-11-12): int8-Attention des Ganzzahl-Batch-Pfads, Gegenstueck zu den Grundkernen von ATT-GPU in\n"
"// cortex_cuda.cu (att_scores_kern .. att_dkv_kern, att_expf). Gleiche Regeln: jede Summe seriell in CPU-Reihenfolge, ein\n"
"// Faden je Summe; FTZ/DAZ wie die CPU (MXCSR 0x8040) ausdruecklich ueber AZ; float-Rechnung ueber FA/FM (SOFT_DN-faehig),\n"
"// Division ueber DDIV. Haengt an den Hilfen aus adam_q.cl (gleiches Programm).\n"
"\n"
"__constant ulong att_exp_tab[32] = {\n"
"    0x3ff0000000000000UL, 0x3fefd9b0d3158574UL, 0x3fefb5586cf9890fUL, 0x3fef9301d0125b51UL,\n"
"    0x3fef72b83c7d517bUL, 0x3fef54873168b9aaUL, 0x3fef387a6e756238UL, 0x3fef1e9df51fdee1UL,\n"
"    0x3fef06fe0a31b715UL, 0x3feef1a7373aa9cbUL, 0x3feedea64c123422UL, 0x3feece086061892dUL,\n"
"    0x3feebfdad5362a27UL, 0x3feeb42b569d4f82UL, 0x3feeab07dd485429UL, 0x3feea47eb03a5585UL,\n"
"    0x3feea09e667f3bcdUL, 0x3fee9f75e8ec5f74UL, 0x3feea11473eb0187UL, 0x3feea589994cce13UL,\n"
"    0x3feeace5422aa0dbUL, 0x3feeb737b0cdc5e5UL, 0x3feec49182a3f090UL, 0x3feed503b23e255dUL,\n"
"    0x3feee89f995ad3adUL, 0x3feeff76f2fb5e47UL, 0x3fef199bdd85529cUL, 0x3fef3720dcef9069UL,\n"
"    0x3fef5818dcfba487UL, 0x3fef7c97337b9b5fUL, 0x3fefa4afa2a490daUL, 0x3fefd0765b6e4540UL};\n"
"\n"
"// Betrag < FLT_MIN -> Null mit Vorzeichen (nur Bits, unabhaengig vom Denormal-Verhalten des Geraets)\n"
"inline float AZ(float x) { uint u = as_uint(x); return ((u & 0x7f800000u) == 0) ? as_float(u & 0x80000000u) : x; }\n"
"inline float att_add(float a, float b) { return AZ(FAq(AZ(a), AZ(b))); }\n"
"inline float att_sub(float a, float b) { return AZ(FSq(AZ(a), AZ(b))); }\n"
"inline float att_mul(float a, float b) { return AZ(FMq(AZ(a), AZ(b))); }\n"
"inline float att_div(float a, float b) { return AZ(fdivr(AZ(a), AZ(b))); }\n"
"\n"
"// variant 0 = glibc-FMA-Fassung (Produktion); 1 = ohne FMA (Rot-Probe des Tests). Wortgleich zu att_expf (CUDA).\n"
"float att_expf(float x, int variant) {\n"
"    const double InvLn2N = 0x1.71547652b82fep+5, SHIFT = 0x1.8p+52;\n"
"    const double C0 = 0x1.c6af84b912394p-20, C1 = 0x1.ebfce50fac4f3p-13, C2 = 0x1.62e42ff0c52d6p-6;\n"
"    uint ux = as_uint(x);\n"
"    uint abstop = (ux >> 20) & 0x7ff;\n"
"    if (abstop > 0x42a) {\n"
"        if (ux == 0xff800000u) return 0.0f;\n"
"        if (abstop > 0x7f7) return x + x;\n"
"        if (F2D(x) > F2D(0x1.62e42ep+6f)) return as_float(0x7f800000u);\n"
"        if (F2D(-0x1.9fe368p+6f) > F2D(x)) return 0.0f;\n"
"        if (F2D(-0x1.9d1d9ep+6f) > F2D(x)) return 0.0f;\n"
"    }\n"
"    double xd = F2D(AZ(x));\n"
"    double kd, r, z, y;\n"
"    if (variant == 0) kd = fma(InvLn2N, xd, SHIFT);\n"
"    else              kd = InvLn2N * xd + SHIFT;\n"
"    ulong ki = as_ulong(kd);\n"
"    kd = kd - SHIFT;\n"
"    if (variant == 0) r = fma(InvLn2N, xd, -kd);\n"
"    else              r = InvLn2N * xd - kd;\n"
"    ulong t = att_exp_tab[ki & 31] + (ki << 47);\n"
"    double s = as_double(t);\n"
"    double r2 = r * r;\n"
"    if (variant == 0) {\n"
"        z = fma(r, C0, C1);\n"
"        y = fma(r, C2, 1.0);\n"
"        y = fma(z, r2, y);\n"
"    } else {\n"
"        z = r * C0 + C1;\n"
"        y = r * C2 + 1.0;\n"
"        y = z * r2 + y;\n"
"    }\n"
"    y = y * s;\n"
"    return AZ(D2F(y));\n"
"}\n"
"\n"
"__kernel void att_expf_kern(__global const float* in, __global float* out, int n, int variant) {\n"
"    int i = get_global_id(0);\n"
"    if (i < n) out[i] = att_expf(in[i], variant);\n"
"}\n"
"\n"
"// Scores je (Kopf, Position p, Schluessel t<=p): acc = sum int8*int8; sc = acc * qScale * kScale[t]; sc /= sqrt(hs)\n"
"__kernel void att_scores_kern(__global const char* q8, __global const float* qs, __global const char* k8, __global const float* ks,\n"
"                              __global float* S, int act, int dim, int hs, float sqrtHs) {\n"
"    int hp = get_global_id(1);\n"
"    int h = hp / act, p = hp % act;\n"
"    int t = get_global_id(0);\n"
"    if (t > p) return;\n"
"    __global const char* qrow = q8 + (size_t)p * dim + h * hs;\n"
"    __global const char* krow = k8 + (size_t)t * dim + h * hs;\n"
"    int acc = 0;\n"
"    for (int d = 0; d < hs; d++) acc += (int)qrow[d] * (int)krow[d];\n"
"    float sc = att_mul(att_mul((float)acc, qs[p]), ks[t]);\n"
"    sc = att_div(sc, sqrtHs);\n"
"    S[(size_t)hp * act + t] = sc;\n"
"}\n"
"\n"
"// Softmax je (Kopf, Position), seriell ueber t: max, exp/Summe, Gewicht = e / Summe.\n"
"__kernel void att_softmax_kern(__global float* S, int act, int nrows) {\n"
"    int hp = get_global_id(0);\n"
"    if (hp >= nrows) return;\n"
"    int p = hp % act;\n"
"    __global float* row = S + (size_t)hp * act;\n"
"    float m = as_float(0xff800000u);\n"
"    for (int t = 0; t <= p; t++) { float sc = row[t]; if (F2D(sc) > F2D(m)) m = sc; }\n"
"    float sum = 0.0f;\n"
"    for (int t = 0; t <= p; t++) { float e = att_expf(att_sub(row[t], m), 0); row[t] = e; sum = att_add(sum, e); }\n"
"    for (int t = 0; t <= p; t++) row[t] = att_div(row[t], sum);\n"
"}\n"
"\n"
"// Vorwaerts-Ausgabe je (Kopf, Position, d): outp += (v * vScale) * w ueber t aufsteigend.\n"
"__kernel void att_out_kern(__global const char* v8, __global const float* vs, __global const float* W, __global float* out,\n"
"                           int act, int dim, int hs, int rot) {\n"
"    int hp = get_group_id(0); int d = get_local_id(0);\n"
"    if (d >= hs) return;\n"
"    int h = hp / act, p = hp % act;\n"
"    __global const float* wrow = W + (size_t)hp * act;\n"
"    float o = 0.0f;\n"
"    for (int t = 0; t <= p; t++)\n"
"        o = att_add(o, att_mul(att_mul((float)v8[(size_t)t * dim + h * hs + d], vs[t]), wrow[t]));\n"
"    if (rot && h == 0 && p == act - 1 && d == 0) o = att_mul(o, 1.0001f);\n"
"    out[(size_t)p * dim + h * hs + d] = o;\n"
"}\n"
"\n"
"// Rueckwaerts dw je (Kopf, p, t<=p): dw += d_att * (v * vScale) ueber d aufsteigend.\n"
"__kernel void att_dw_kern(__global const float* datt, __global const char* v8, __global const float* vs, __global float* DW,\n"
"                          int act, int dim, int hs) {\n"
"    int hp = get_global_id(1); int h = hp / act, p = hp % act;\n"
"    int t = get_global_id(0);\n"
"    if (t > p) return;\n"
"    __global const float* da = datt + (size_t)p * dim + h * hs;\n"
"    __global const char* vrow = v8 + (size_t)t * dim + h * hs;\n"
"    float vsc = vs[t];\n"
"    float dw = 0.0f;\n"
"    for (int d = 0; d < hs; d++) dw = att_add(dw, att_mul(da[d], att_mul((float)vrow[d], vsc)));\n"
"    DW[(size_t)hp * act + t] = dw;\n"
"}\n"
"\n"
"// Je (Kopf, p): sum_w_dw seriell, dann float-Teil von ds: w * (dw - sum_w_dw) (in DW abgelegt).\n"
"__kernel void att_ds_kern(__global const float* W, __global float* DW, int act, int nrows) {\n"
"    int hp = get_global_id(0);\n"
"    if (hp >= nrows) return;\n"
"    int p = hp % act;\n"
"    __global const float* wrow = W + (size_t)hp * act;\n"
"    __global float* drow = DW + (size_t)hp * act;\n"
"    float s = 0.0f;\n"
"    for (int t = 0; t <= p; t++) s = att_add(s, att_mul(wrow[t], drow[t]));\n"
"    for (int t = 0; t <= p; t++) drow[t] = att_mul(wrow[t], att_sub(drow[t], s));\n"
"}\n"
"inline double att_ds_d(float f, double attScale, int rot, int h) {\n"
"    double ds = F2D(f) * attScale;\n"
"    if (rot && h == 0) ds = ds * F2D(1.0001f);\n"
"    return ds;\n"
"}\n"
"// (float)(ds * (double)x) unter FTZ, wie cvtsd2ss\n"
"inline float att_dsx(double ds, float x) { return AZ(D2F(ds * F2D(AZ(x)))); }\n"
"\n"
"// d_q je (Kopf, p, d): von 0 an, += ds * (k * kScale) ueber t aufsteigend.\n"
"__kernel void att_dq_kern(__global const float* DS, __global const char* k8, __global const float* ks, __global float* dq,\n"
"                          int act, int dim, int hs, double attScale, int rot) {\n"
"    int hp = get_group_id(0); int d = get_local_id(0);\n"
"    if (d >= hs) return;\n"
"    int h = hp / act, p = hp % act;\n"
"    __global const float* drow = DS + (size_t)hp * act;\n"
"    float a = 0.0f;\n"
"    for (int t = 0; t <= p; t++)\n"
"        a = att_add(a, att_dsx(att_ds_d(drow[t], attScale, rot, h), att_mul((float)k8[(size_t)t * dim + h * hs + d], ks[t])));\n"
"    dq[(size_t)p * dim + h * hs + d] = a;\n"
"}\n"
"\n"
"// d_k und d_v je (Kopf, t, d): vom Eingangswert an, Beitraege der Positionen p = act-1 .. t absteigend.\n"
"__kernel void att_dkv_kern(__global const float* DS, __global const float* W, __global const float* datt, __global const char* q8,\n"
"                           __global const float* qs, __global float* dk, __global float* dv, int act, int dim, int hs,\n"
"                           double attScale, int rot) {\n"
"    int ht = get_group_id(0); int d = get_local_id(0);\n"
"    if (d >= hs) return;\n"
"    int h = ht / act, t = ht % act;\n"
"    size_t o = (size_t)t * dim + h * hs + d;\n"
"    float k = dk[o], v = dv[o];\n"
"    for (int p = act - 1; p >= t; p--) {\n"
"        size_t hpt = ((size_t)h * act + p) * act + t;\n"
"        float qE = att_mul((float)q8[(size_t)p * dim + h * hs + d], qs[p]);\n"
"        k = att_add(k, att_dsx(att_ds_d(DS[hpt], attScale, rot, h), qE));\n"
"        v = att_add(v, att_mul(datt[(size_t)p * dim + h * hs + d], W[hpt]));\n"
"    }\n"
"    dk[o] = k; dv[o] = v;\n"
"}\n"
"\n"
"// OCL-ATT-FAST (2026-11-12): Gegenstueck zu ATT-FAST in cortex_cuda.cu (multi_stack e617). Gleiche Rechnung wie die\n"
"// Grundkerne, schneller: Ganzzahlsummen ueber 16-Byte-Ladungen, Softmax/ds mit einer Arbeitsgruppe je Zeile (Summe weiter\n"
"// seriell in t-Reihenfolge, statt Warp-Shuffle ueber lokalen Speicher, NVIDIA-OpenCL hat keine Subgroups), ds*x in float bei\n"
"// Zweierpotenz-attScale, Gruppenkerne mit fester Gruppengroesse (Vorgaben von CUDA: Ausgabe 8, dq 4, dkv 1).\n"
"\n"
"#define ATT_WG 64\n"
"\n"
"__kernel void att_scores_fast(__global const char* q8, __global const float* qs, __global const char* k8, __global const float* ks,\n"
"                              __global float* S, int act, int dim, int hs, float sqrtHs) {\n"
"    int hp = get_global_id(1);\n"
"    int h = hp / act, p = hp % act;\n"
"    int t = get_global_id(0);\n"
"    if (t > p) return;\n"
"    __global const char* qrow = q8 + (size_t)p * dim + h * hs;\n"
"    __global const char* krow = k8 + (size_t)t * dim + h * hs;\n"
"    int acc = 0;\n"
"    for (int i = 0; i < hs / 16; i++) {\n"
"        int16 a = convert_int16(vload16(i, qrow)), b = convert_int16(vload16(i, krow));\n"
"        int16 c = a * b;\n"
"        acc += c.s0 + c.s1 + c.s2 + c.s3 + c.s4 + c.s5 + c.s6 + c.s7 + c.s8 + c.s9 + c.sa + c.sb + c.sc + c.sd + c.se + c.sf;\n"
"    }\n"
"    float sc = att_mul(att_mul((float)acc, qs[p]), ks[t]);\n"
"    sc = att_div(sc, sqrtHs);\n"
"    S[(size_t)hp * act + t] = sc;\n"
"}\n"
"\n"
"// softmax: eine Arbeitsgruppe (ATT_WG) je (Kopf, Position). max parallel (Reihenfolge egal), exp parallel, Summe seriell in\n"
"// t-Reihenfolge (Faden 0 ueber den lokalen Puffer), Division parallel. rot: Summe je Stueck rueckwaerts (Rot-Probe).\n"
"__kernel void att_softmax_fast(__global float* S, int act, int nrows, int rot) {\n"
"    __local float buf[ATT_WG];\n"
"    __local float lsum;\n"
"    int hp = get_group_id(0);\n"
"    int lid = get_local_id(0);\n"
"    if (hp >= nrows) return;\n"
"    int p = hp % act;\n"
"    __global float* row = S + (size_t)hp * act;\n"
"    float m = as_float(0xff800000u);\n"
"    for (int t = lid; t <= p; t += ATT_WG) { float sc = row[t]; if (F2D(sc) > F2D(m)) m = sc; }\n"
"    buf[lid] = m;\n"
"    barrier(CLK_LOCAL_MEM_FENCE);\n"
"    for (int st = ATT_WG / 2; st > 0; st >>= 1) {\n"
"        if (lid < st) { float x = buf[lid + st]; if (F2D(x) > F2D(buf[lid])) buf[lid] = x; }\n"
"        barrier(CLK_LOCAL_MEM_FENCE);\n"
"    }\n"
"    m = buf[0];\n"
"    barrier(CLK_LOCAL_MEM_FENCE);\n"
"    float sum = 0.0f;\n"
"    for (int base = 0; base <= p; base += ATT_WG) {\n"
"        int t = base + lid;\n"
"        float e = 0.0f;\n"
"        if (t <= p) { e = att_expf(att_sub(row[t], m), 0); row[t] = e; }\n"
"        buf[lid] = e;\n"
"        barrier(CLK_LOCAL_MEM_FENCE);\n"
"        if (lid == 0) {\n"
"            int n = min(ATT_WG, p - base + 1);\n"
"            if (rot && n > 1) { for (int j = n - 1; j >= 0; j--) sum = att_add(sum, buf[j]); }\n"
"            else              { for (int j = 0; j < n; j++)      sum = att_add(sum, buf[j]); }\n"
"        }\n"
"        barrier(CLK_LOCAL_MEM_FENCE);\n"
"    }\n"
"    if (lid == 0) lsum = sum;\n"
"    barrier(CLK_LOCAL_MEM_FENCE | CLK_GLOBAL_MEM_FENCE);\n"
"    sum = lsum;\n"
"    for (int t = lid; t <= p; t += ATT_WG) row[t] = att_div(row[t], sum);\n"
"}\n"
"\n"
"// dw: wie att_dw_kern, v mit 16-Byte-Ladungen; Summe ueber d seriell aufsteigend.\n"
"__kernel void att_dw_fast(__global const float* datt, __global const char* v8, __global const float* vs, __global float* DW,\n"
"                          int act, int dim, int hs) {\n"
"    int hp = get_global_id(1); int h = hp / act, p = hp % act;\n"
"    int t = get_global_id(0);\n"
"    if (t > p) return;\n"
"    __global const float* da = datt + (size_t)p * dim + h * hs;\n"
"    __global const char* vrow = v8 + (size_t)t * dim + h * hs;\n"
"    float vsc = vs[t];\n"
"    float dw = 0.0f;\n"
"    for (int i = 0; i < hs / 16; i++) {\n"
"        char16 w = vload16(i, vrow);\n"
"        char wv[16];\n"
"        vstore16(w, 0, wv);\n"
"        for (int b = 0; b < 16; b++) dw = att_add(dw, att_mul(da[i * 16 + b], att_mul((float)wv[b], vsc)));\n"
"    }\n"
"    DW[(size_t)hp * act + t] = dw;\n"
"}\n"
"\n"
"// ds: eine Arbeitsgruppe je (Kopf, p). s seriell in t-Reihenfolge, Produkte parallel.\n"
"__kernel void att_ds_fast(__global const float* W, __global float* DW, int act, int nrows) {\n"
"    __local float buf[ATT_WG];\n"
"    __local float ls;\n"
"    int hp = get_group_id(0);\n"
"    int lid = get_local_id(0);\n"
"    if (hp >= nrows) return;\n"
"    int p = hp % act;\n"
"    __global const float* wrow = W + (size_t)hp * act;\n"
"    __global float* drow = DW + (size_t)hp * act;\n"
"    float s = 0.0f;\n"
"    for (int base = 0; base <= p; base += ATT_WG) {\n"
"        int t = base + lid;\n"
"        float pr = 0.0f;\n"
"        if (t <= p) pr = att_mul(wrow[t], drow[t]);\n"
"        buf[lid] = pr;\n"
"        barrier(CLK_LOCAL_MEM_FENCE);\n"
"        if (lid == 0) { int n = min(ATT_WG, p - base + 1); for (int j = 0; j < n; j++) s = att_add(s, buf[j]); }\n"
"        barrier(CLK_LOCAL_MEM_FENCE);\n"
"    }\n"
"    if (lid == 0) ls = s;\n"
"    barrier(CLK_LOCAL_MEM_FENCE);\n"
"    s = ls;\n"
"    for (int t = lid; t <= p; t += ATT_WG) drow[t] = att_mul(wrow[t], att_sub(drow[t], s));\n"
"}\n"
"\n"
"// ds*x wie att_dsx(att_ds_d(f, attScale, 0, h), x); float-Weg nur bei fast != 0 (Zweierpotenz, rot 0) und\n"
"// f*scf normal oder 0 -> dann exakt gleich, sonst double wie bisher.\n"
"inline float att_dsx_fast(float f, float x, int fast, float scf, double attScale) {\n"
"    if (fast) {\n"
"        float dsf = FMq(f, scf);\n"
"        if (F2D(f) == 0.0 || F2D(FABS(dsf)) >= F2D(0x1p-126f)) return AZ(FMq(dsf, x));\n"
"    }\n"
"    return att_dsx(F2D(f) * attScale, x);\n"
"}\n"
"\n"
"// Ausgabe, G = 8 Positionen je Gruppe (Vorgabe SNAI_ATT_GO unter CUDA). Jede Ausgabe behaelt ihre serielle Kette.\n"
"#define GO 8\n"
"__kernel void att_out_g(__global const char* v8, __global const float* vs, __global const float* W, __global float* out,\n"
"                        int act, int dim, int hs, int rot) {\n"
"    int ng = (act + GO - 1) / GO;\n"
"    int grp = get_group_id(0);\n"
"    int h = grp / ng, p0 = (grp % ng) * GO;\n"
"    int d = get_local_id(0);\n"
"    if (d >= hs) return;\n"
"    int pmax = min(p0 + GO - 1, act - 1);\n"
"    __global const float* wbase = W + ((size_t)h * act + p0) * act;\n"
"    float o[GO];\n"
"    for (int j = 0; j < GO; j++) o[j] = 0.0f;\n"
"    for (int t = 0; t <= pmax; t++) {\n"
"        float vx = att_mul((float)v8[(size_t)t * dim + h * hs + d], vs[t]);\n"
"        for (int j = 0; j < GO; j++)\n"
"            if (t <= p0 + j && p0 + j < act) o[j] = att_add(o[j], att_mul(vx, wbase[(size_t)j * act + t]));\n"
"    }\n"
"    for (int j = 0; j < GO; j++) {\n"
"        int p = p0 + j;\n"
"        if (p < act) {\n"
"            float oo = o[j];\n"
"            if (rot && h == 0 && p == act - 1 && d == 0) oo = att_mul(oo, 1.0001f);\n"
"            out[(size_t)p * dim + h * hs + d] = oo;\n"
"        }\n"
"    }\n"
"}\n"
"// dq, G = 4 Positionen je Gruppe (Vorgabe SNAI_ATT_GQ).\n"
"#define GQ 4\n"
"__kernel void att_dq_g(__global const float* DS, __global const char* k8, __global const float* ks, __global float* dq,\n"
"                       int act, int dim, int hs, double attScale, int fast, float scf) {\n"
"    int ng = (act + GQ - 1) / GQ;\n"
"    int grp = get_group_id(0);\n"
"    int h = grp / ng, p0 = (grp % ng) * GQ;\n"
"    int d = get_local_id(0);\n"
"    if (d >= hs) return;\n"
"    int pmax = min(p0 + GQ - 1, act - 1);\n"
"    __global const float* dbase = DS + ((size_t)h * act + p0) * act;\n"
"    float a[GQ];\n"
"    for (int j = 0; j < GQ; j++) a[j] = 0.0f;\n"
"    for (int t = 0; t <= pmax; t++) {\n"
"        float kx = att_mul((float)k8[(size_t)t * dim + h * hs + d], ks[t]);\n"
"        for (int j = 0; j < GQ; j++)\n"
"            if (t <= p0 + j && p0 + j < act) a[j] = att_add(a[j], att_dsx_fast(dbase[(size_t)j * act + t], kx, fast, scf, attScale));\n"
"    }\n"
"    for (int j = 0; j < GQ; j++) if (p0 + j < act) dq[(size_t)(p0 + j) * dim + h * hs + d] = a[j];\n"
"}\n"
"// dkv wie att_dkv_g<1> (Vorgabe SNAI_ATT_RK = 0): je (Kopf, t, d) eine Kette, ds*x ueber att_dsx_fast.\n"
"__kernel void att_dkv_g1(__global const float* DS, __global const float* W, __global const float* datt, __global const char* q8,\n"
"                         __global const float* qs, __global float* dk, __global float* dv, int act, int dim, int hs,\n"
"                         double attScale, int fast, float scf) {\n"
"    int ht = get_group_id(0); int d = get_local_id(0);\n"
"    if (d >= hs) return;\n"
"    int h = ht / act, t = ht % act;\n"
"    size_t o = (size_t)t * dim + h * hs + d;\n"
"    float k = dk[o], v = dv[o];\n"
"    for (int p = act - 1; p >= t; p--) {\n"
"        size_t hpt = ((size_t)h * act + p) * act + t;\n"
"        float qE = att_mul((float)q8[(size_t)p * dim + h * hs + d], qs[p]);\n"
"        k = att_add(k, att_dsx_fast(DS[hpt], qE, fast, scf, attScale));\n"
"        v = att_add(v, att_mul(datt[(size_t)p * dim + h * hs + d], W[hpt]));\n"
"    }\n"
"    dk[o] = k; dv[o] = v;\n"
"}\n"
"\n"
;
// ==============================================================================
// OCL-ADAM (2026-11-12): Adam mit int8-Momenten auf dem OpenCL-Geraet, Gegenstueck zu cuda_adamRowQI8Rest.
// Gleiche Schnittstelle und Regeln: 1 = gerechnet; 0 = nichts angefasst (der Aufrufer rechnet auf der CPU).
// Fehler NACH dem Kern beenden den Prozess. Ohne GRAD_DEV/OVERLAP (gibt es unter OpenCL nicht): g kommt immer vom Host.
// ==============================================================================
static void ocl_att_kernels(cl_program p, cl_device_id dev);   // OCL-ATT, unten
static cl_kernel ocl_kernel_adam_q = NULL;
static cl_mem ocl_qa_tabM = NULL, ocl_qa_tabV = NULL;
static cl_mem ocl_qa_g = NULL;  static size_t ocl_qa_g_size = 0;
static cl_mem ocl_qa_mb = NULL; static size_t ocl_qa_mb_size = 0;
static cl_mem ocl_qa_vb = NULL; static size_t ocl_qa_vb_size = 0;
static cl_mem ocl_qa_st = NULL; static size_t ocl_qa_st_size = 0;   // rows*10 ulong
static cl_mem ocl_qa_wd = NULL; static size_t ocl_qa_wd_size = 0;   // rows double
static cl_mem ocl_qa_dummy = NULL;
static unsigned long long ocl_rest_cnt[10];
static double ocl_rest_wd = 0.0;
static int ocl_adam_fast_mask = -1;
static int oclAdamFastMask(void) {
    if (ocl_adam_fast_mask < 0) {
        const char* e = getenv("SNAI_ADAM_FAST");
        ocl_adam_fast_mask = (e && *e) ? atoi(e) : 79;   // wie CUDA (e611)
        fprintf(stderr, "[OCL-ADAM] Maske %d\n", ocl_adam_fast_mask);
    }
    return ocl_adam_fast_mask;
}
static int ocl_ensure(cl_mem* b, size_t* have, size_t need) {
    if (*have >= need && *b) return 1;
    if (*b) clReleaseMemObject(*b);
    cl_int e;
    *b = ocl_mk(ocl_ctx, CL_MEM_READ_WRITE, need, NULL, &e);
    *have = (e == CL_SUCCESS) ? need : 0;
    if (e != CL_SUCCESS) *b = NULL;
    return e == CL_SUCCESS;
}
typedef struct { void* key; cl_mem d_code; cl_mem d_sk; size_t n; int bpe; } OclRestKarte;
static OclRestKarte ocl_rest_karte[512]; static int ocl_rest_karte_n = 0;
static cl_mem oclRestCodes(void* key, size_t n, int rows, int bpe, cl_mem* sk) {
    for (int i = 0; i < ocl_rest_karte_n; i++) if (ocl_rest_karte[i].key == key) {
        if (ocl_rest_karte[i].n != n || ocl_rest_karte[i].bpe != bpe) return NULL;
        *sk = ocl_rest_karte[i].d_sk; return ocl_rest_karte[i].d_code; }
    if (ocl_rest_karte_n >= 512) return NULL;
    cl_int e1, e2; unsigned char z = 0;
    cl_mem d = ocl_mk(ocl_ctx, CL_MEM_READ_WRITE, n * bpe, NULL, &e1);
    cl_mem s = ocl_mk(ocl_ctx, CL_MEM_READ_WRITE, (size_t)rows * sizeof(float), NULL, &e2);
    if (e1 != CL_SUCCESS || e2 != CL_SUCCESS) return NULL;
    if (clEnqueueFillBuffer(ocl_queue, d, &z, 1, 0, n * bpe, 0, NULL, NULL) != CL_SUCCESS ||
        clEnqueueFillBuffer(ocl_queue, s, &z, 1, 0, (size_t)rows * sizeof(float), 0, NULL, NULL) != CL_SUCCESS) return NULL;
    ocl_rest_karte[ocl_rest_karte_n].key = key; ocl_rest_karte[ocl_rest_karte_n].d_code = d;
    ocl_rest_karte[ocl_rest_karte_n].d_sk = s; ocl_rest_karte[ocl_rest_karte_n].n = n;
    ocl_rest_karte[ocl_rest_karte_n].bpe = bpe; ocl_rest_karte_n++;
    *sk = s; return d;
}
// Baut das double-Programm. Ohne cl_khr_fp64 bleibt der Kern NULL (der Kern im Nim-Teil faellt dann auf die CPU zurueck).
// ==== OCL-DDIV (2026-11-13): Divisions-/Wurzel-Nachbau nur, wo das Geraet double ungenau rechnet =================
// Selbsttest: 65536 Divisionen und Wurzeln auf dem Geraet, bitweise gegen den Host. Alle gleich -> native Division.
// SNAI_OCL_DDIV: fehlt = Selbsttest, 1 = Nachbau immer, 0 = native Division immer (ohne Test).
static int ocl_ddiv_native(cl_device_id dev) {
    const char* e = getenv("SNAI_OCL_DDIV");
    if (e && strcmp(e, "1") == 0) { fprintf(stderr, "[OCL-DDIV] Nachbau erzwungen\n"); return 0; }
    if (e && strcmp(e, "0") == 0) { fprintf(stderr, "[OCL-DDIV] native Division erzwungen (ohne Selbsttest)\n"); return 1; }
    static const char* src =
        "#pragma OPENCL EXTENSION cl_khr_fp64 : enable\n"
        "#pragma OPENCL FP_CONTRACT OFF\n"
        "__kernel void ddt(__global const double* a, __global const double* b, __global double* q, __global double* s) {\n"
        "    size_t i = get_global_id(0); q[i] = a[i] / b[i]; s[i] = sqrt(a[i]); }\n";
    const size_t N = 65536;
    double* a = (double*)malloc(N * sizeof(double)); double* b = (double*)malloc(N * sizeof(double));
    double* q = (double*)malloc(N * sizeof(double)); double* s = (double*)malloc(N * sizeof(double));
    if (!a || !b || !q || !s) { free(a); free(b); free(q); free(s); return 0; }
    unsigned long long x = 0x9E3779B97F4A7C15ULL;
    for (size_t i = 0; i < N; i++) {
        x ^= x << 13; x ^= x >> 7; x ^= x << 17; double ma = 1.0 + (double)(x >> 11) * 0x1p-53; int ea = (int)(x % 241) - 120;
        x ^= x << 13; x ^= x >> 7; x ^= x << 17; double mb = 1.0 + (double)(x >> 11) * 0x1p-53; int eb = (int)(x % 241) - 120;
        a[i] = ldexp(ma, ea); b[i] = ((x >> 3) & 1) ? -ldexp(mb, eb) : ldexp(mb, eb);
    }
    int ok = 0; cl_int err;
    cl_program p = clCreateProgramWithSource(ocl_ctx, 1, &src, NULL, &err);
    if (err == CL_SUCCESS && p && clBuildProgram(p, 1, &dev, NULL, NULL, NULL) == CL_SUCCESS) {
        cl_kernel k = clCreateKernel(p, "ddt", &err);
        cl_mem da = clCreateBuffer(ocl_ctx, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR, N * sizeof(double), a, &err);
        cl_mem db = clCreateBuffer(ocl_ctx, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR, N * sizeof(double), b, &err);
        cl_mem dq = clCreateBuffer(ocl_ctx, CL_MEM_WRITE_ONLY, N * sizeof(double), NULL, &err);
        cl_mem ds = clCreateBuffer(ocl_ctx, CL_MEM_WRITE_ONLY, N * sizeof(double), NULL, &err);
        if (k && da && db && dq && ds) {
            clSetKernelArg(k, 0, sizeof(cl_mem), &da); clSetKernelArg(k, 1, sizeof(cl_mem), &db);
            clSetKernelArg(k, 2, sizeof(cl_mem), &dq); clSetKernelArg(k, 3, sizeof(cl_mem), &ds);
            size_t g = N;
            if (ocl_nd(ocl_queue, k, 1, NULL, &g, NULL, 0, NULL, NULL) == CL_SUCCESS &&
                clEnqueueReadBuffer(ocl_queue, dq, CL_TRUE, 0, N * sizeof(double), q, 0, NULL, NULL) == CL_SUCCESS &&
                clEnqueueReadBuffer(ocl_queue, ds, CL_TRUE, 0, N * sizeof(double), s, 0, NULL, NULL) == CL_SUCCESS) {
                size_t bad = 0;
                for (size_t i = 0; i < N; i++) {
                    volatile double hq = a[i] / b[i]; volatile double hs = sqrt(a[i]);
                    double tq = hq, ts = hs;
                    if (memcmp(&tq, &q[i], sizeof(double)) != 0 || memcmp(&ts, &s[i], sizeof(double)) != 0) bad++;
                }
                ok = bad == 0;
                fprintf(stderr, "[OCL-DDIV] Selbsttest: %zu von %zu Divisionen/Wurzeln abweichend -> %s\n",
                        bad, N, ok ? "native Division" : "Nachbau (Markstein)");
            }
        }
        if (da) clReleaseMemObject(da); if (db) clReleaseMemObject(db); if (dq) clReleaseMemObject(dq); if (ds) clReleaseMemObject(ds);
        if (k) clReleaseKernel(k);
    } else fprintf(stderr, "[OCL-DDIV] Selbsttest nicht baubar - Nachbau\n");
    if (p) clReleaseProgram(p);
    free(a); free(b); free(q); free(s);
    return ok;
}
static void ocl_adam_q_build(cl_device_id dev) {
    char ext[8192]; ext[0] = 0;
    clGetDeviceInfo(dev, CL_DEVICE_EXTENSIONS, sizeof(ext) - 1, ext, NULL); ext[sizeof(ext) - 1] = 0;
    if (!strstr(ext, "cl_khr_fp64")) {
        fprintf(stderr, "[OCL-ADAM] Geraet ohne cl_khr_fp64 - Adam bleibt auf der CPU%s\n",
                getenv("RUSTICL_FEATURES") ? "" : " (rusticl: RUSTICL_FEATURES=fp64)");
        return;
    }
    cl_int err;
    cl_program p = clCreateProgramWithSource(ocl_ctx, 1, (const char**)&adam_q_source, NULL, &err);
    if (err != CL_SUCCESS || !p) { fprintf(stderr, "[OCL-ADAM] Programm nicht angelegt (%d)\n", err); return; }
    // Ohne float-Denormale (rusticl/radeonsi: sie wuerden auf null gesetzt) rechnet der Kern jede float-Operation ueber double.
    cl_device_fp_config fpc = 0;
    clGetDeviceInfo(dev, CL_DEVICE_SINGLE_FP_CONFIG, sizeof(fpc), &fpc, NULL);
    const int softdn = (fpc & CL_FP_DENORM) ? 0 : 1;
    const int nddiv = ocl_ddiv_native(dev);   // OCL-DDIV
    int attsn = 0;   // OCL-ATT-SN: nur wirksam bei SOFT_DN
    {   const char* s = getenv("SNAI_OCL_ATT_SN");
        attsn = (s && strcmp(s, "0") == 0) ? 0 : (s && strcmp(s, "ROT") == 0) ? 2 : 1;
        if (!softdn) attsn = 0;
        fprintf(stderr, "[OCL-ATT-SN] float-Kurzweg in der Attention: %s\n", !softdn ? "nicht noetig (Geraet hat float-Denormale)" :
                attsn == 0 ? "aus" : attsn == 2 ? "an, ROT-PROBE" : "an");
    }
    int snadam = 0, sndiv = 0;   // OCL-SN2
    {   const char* s = getenv("SNAI_OCL_SN_ADAM");
        snadam = (s && strcmp(s, "0") == 0) ? 0 : (s && strcmp(s, "ROT") == 0) ? 2 : 1;
        if (!softdn) snadam = 0;
        const char* d = getenv("SNAI_OCL_SN_DIV");
        sndiv = (d && strcmp(d, "0") == 0) ? 0 : (d && strcmp(d, "ROT") == 0) ? 2 : 1;
        if (nddiv) sndiv = 0;
        fprintf(stderr, "[OCL-SN2] float-Kurzweg ganzes Programm (Adam): %s; Division/Wurzel nativ+gepruefte Korrektur: %s\n",
                !softdn ? "nicht noetig" : snadam == 0 ? "aus" : snadam == 2 ? "an, ROT-PROBE" : "an",
                nddiv ? "nicht noetig (native Division)" : sndiv == 0 ? "aus" : sndiv == 2 ? "an, ROT-PROBE" : "an");
    }
    char aopt[160]; snprintf(aopt, sizeof aopt, "%s%s%s%s%s%s", softdn ? "-DSOFT_DN=1 " : "", nddiv ? "-DNATIVE_DDIV=1 " : "",
                            attsn ? "-DATT_SN=1 " : "", snadam ? "-DSN_ADAM=1 " : "",
                            (attsn == 2 || snadam == 2) ? "-DSN_ROT=1 " : "", sndiv == 2 ? "-DSN_DIV=2" : sndiv ? "-DSN_DIV=1" : "");
    if (clBuildProgram(p, 1, &dev, aopt[0] ? aopt : NULL, NULL, NULL) != CL_SUCCESS) {
        size_t ls = 0; clGetProgramBuildInfo(p, dev, CL_PROGRAM_BUILD_LOG, 0, NULL, &ls);
        char* lg = (char*)malloc(ls + 1); clGetProgramBuildInfo(p, dev, CL_PROGRAM_BUILD_LOG, ls, lg, NULL); lg[ls] = 0;
        fprintf(stderr, "[OCL-ADAM] Bau fehlgeschlagen:\n%s\n", lg); free(lg); clReleaseProgram(p); return;
    }
    size_t kwg = 0;
    ocl_kernel_adam_q = clCreateKernel(p, "adamRowQI8", &err);
    if (err != CL_SUCCESS || clGetKernelWorkGroupInfo(ocl_kernel_adam_q, dev, CL_KERNEL_WORK_GROUP_SIZE, sizeof(size_t),
                                                      &kwg, NULL) != CL_SUCCESS || kwg < 256) {
        fprintf(stderr, "[OCL-ADAM] Kern nicht nutzbar (Fehler %d, Arbeitsgruppe %zu < 256)\n", err, kwg);
        ocl_kernel_adam_q = NULL;
    }
    ocl_att_kernels(p, dev);   // OCL-ATT
    clReleaseProgram(p);
    if (ocl_kernel_adam_q) fprintf(stderr, "[OCL-ADAM] Kern bereit (double%s%s)\n", softdn ? ", float ueber double: Geraet ohne float-Denormale" : "", nddiv ? ", native Division" : ", Divisions-Nachbau");
}
int ocl_adam_q_ready(void) { return ocl_kernel_adam_q != NULL; }
void ocl_rest_stats(unsigned long long* out, double* out_wd) {
    for (int i = 0; i < 10; i++) { out[i] = ocl_rest_cnt[i]; ocl_rest_cnt[i] = 0; }
    *out_wd = ocl_rest_wd; ocl_rest_wd = 0.0;
}
int ocl_adamRowQI8Rest(signed char* h_w, float* h_wscale, unsigned char* h_mqd, float* h_mqs,
                       unsigned char* h_vqd, float* h_vqs, float* h_g, float* h_res,
                       const float* h_tabM, const float* h_tabV, double lgr,
                       float lr, float b1, float b2, float b1t, float b2t, float gscale,
                       int rows, int cols, int is_sparse, int bound_r, int bound_c, float boost, float wd,
                       int use_fb, int mode, int sr_mask, unsigned long long sr_salt, int rmode, int rrot, int rtele) {
    if (!ocl_ctx || !ocl_kernel_adam_q || !h_w || !h_wscale || !h_mqd || !h_mqs || !h_vqd || !h_vqs || !h_g ||
        rows <= 0 || cols <= 0) return 0;
    size_t n = (size_t)rows * (size_t)cols;
    size_t nr = (size_t)rows * sizeof(float);
    cl_int e = CL_SUCCESS;
    if (!ocl_qa_tabM) {
        ocl_qa_tabM = ocl_mk(ocl_ctx, CL_MEM_READ_ONLY, 128 * sizeof(float), NULL, &e);
        if (e == CL_SUCCESS) ocl_qa_tabV = ocl_mk(ocl_ctx, CL_MEM_READ_ONLY, 256 * sizeof(float), NULL, &e);
        if (e != CL_SUCCESS ||
            ocl_wr(ocl_queue, ocl_qa_tabM, CL_TRUE, 0, 128 * sizeof(float), h_tabM, 0, NULL, NULL) != CL_SUCCESS ||
            ocl_wr(ocl_queue, ocl_qa_tabV, CL_TRUE, 0, 256 * sizeof(float), h_tabV, 0, NULL, NULL) != CL_SUCCESS) {
            ocl_qa_tabM = NULL; fprintf(stderr, "[OCL-ADAM] Tabellen nicht hochgeladen\n"); return 0;
        }
        ocl_qa_dummy = ocl_mk(ocl_ctx, CL_MEM_READ_WRITE, 64, NULL, &e);
        if (e != CL_SUCCESS) { ocl_qa_tabM = NULL; return 0; }
    }
    int fb = (use_fb == 1 && h_res != NULL) ? 1 : 0;
    int rcode = fb && (rmode == 16 || rmode == 8 || rmode == 9);
    cl_mem d_rc16 = ocl_qa_dummy, d_rc8 = ocl_qa_dummy, d_rsk = ocl_qa_dummy;
    if (rcode) {
        cl_mem sk = NULL;
        cl_mem d = oclRestCodes((void*)h_res, n, rows, rmode == 16 ? 2 : 1, &sk);
        if (!d) { fprintf(stderr, "[OCL-ADAM] Rest-Codes nicht angelegt\n"); return 0; }
        if (rmode == 16) d_rc16 = d; else d_rc8 = d;
        d_rsk = sk;
    }
    cl_mem d_w = ocl_get_buffer((void*)h_w, n);
    cl_mem d_ws = ocl_get_buffer((void*)h_wscale, nr);
    cl_mem d_mqd = ocl_get_buffer((void*)h_mqd, n);
    cl_mem d_mqs = ocl_get_buffer((void*)h_mqs, nr);
    cl_mem d_vqd = ocl_get_buffer((void*)h_vqd, n);
    cl_mem d_vqs = ocl_get_buffer((void*)h_vqs, nr);
    cl_mem d_res = (fb && !rcode) ? ocl_get_buffer((void*)h_res, n * sizeof(float)) : NULL;
    if (!d_w || !d_ws || !d_mqd || !d_mqs || !d_vqd || !d_vqs || (fb && !rcode && !d_res) ||
        !ocl_ensure(&ocl_qa_g, &ocl_qa_g_size, n * sizeof(float)) ||
        !ocl_ensure(&ocl_qa_mb, &ocl_qa_mb_size, n * sizeof(float)) ||
        !ocl_ensure(&ocl_qa_vb, &ocl_qa_vb_size, n * sizeof(float)) ||
        !ocl_ensure(&ocl_qa_st, &ocl_qa_st_size, (size_t)rows * 10 * sizeof(cl_ulong)) ||
        !ocl_ensure(&ocl_qa_wd, &ocl_qa_wd_size, (size_t)rows * sizeof(double))) {
        fprintf(stderr, "[OCL-ADAM] Puffer fehlen\n"); return 0;
    }
    int up = ocl_wr(ocl_queue, d_w, CL_TRUE, 0, n, h_w, 0, NULL, NULL) == CL_SUCCESS &&
             ocl_wr(ocl_queue, d_ws, CL_TRUE, 0, nr, h_wscale, 0, NULL, NULL) == CL_SUCCESS &&
             ocl_wr(ocl_queue, ocl_qa_g, CL_TRUE, 0, n * sizeof(float), h_g, 0, NULL, NULL) == CL_SUCCESS;
    if (up && mode == 2) {
        up = ocl_wr(ocl_queue, d_mqd, CL_TRUE, 0, n, h_mqd, 0, NULL, NULL) == CL_SUCCESS &&
             ocl_wr(ocl_queue, d_mqs, CL_TRUE, 0, nr, h_mqs, 0, NULL, NULL) == CL_SUCCESS &&
             ocl_wr(ocl_queue, d_vqd, CL_TRUE, 0, n, h_vqd, 0, NULL, NULL) == CL_SUCCESS &&
             ocl_wr(ocl_queue, d_vqs, CL_TRUE, 0, nr, h_vqs, 0, NULL, NULL) == CL_SUCCESS &&
             (!fb || rcode || ocl_wr(ocl_queue, d_res, CL_TRUE, 0, n * sizeof(float), h_res, 0, NULL, NULL) == CL_SUCCESS);
    }
    if (!up) { fprintf(stderr, "[OCL-ADAM] Hochladen fehlgeschlagen\n"); return 0; }
    cl_mem d_resx = (fb && !rcode) ? d_res : ocl_qa_g;
    int fast = oclAdamFastMask();
    cl_ulong salt = (cl_ulong)sr_salt;
    cl_kernel k = ocl_kernel_adam_q;
    int a = 0; cl_int err = CL_SUCCESS;
#define OA(t, v) err |= clSetKernelArg(k, a++, sizeof(t), (void*)&(v))
    OA(cl_mem, d_w); OA(cl_mem, d_ws); OA(cl_mem, d_mqd); OA(cl_mem, d_mqs); OA(cl_mem, d_vqd); OA(cl_mem, d_vqs);
    OA(cl_mem, ocl_qa_g); OA(cl_mem, d_resx); OA(cl_mem, ocl_qa_mb); OA(cl_mem, ocl_qa_vb);
    OA(cl_mem, ocl_qa_tabM); OA(cl_mem, ocl_qa_tabV);
    OA(float, lr); OA(float, b1); OA(float, b2); OA(float, b1t); OA(float, b2t); OA(float, gscale);
    OA(int, cols); OA(int, is_sparse); OA(int, bound_r); OA(int, bound_c); OA(float, boost); OA(float, wd);
    OA(int, fb); OA(double, lgr); OA(int, sr_mask); OA(cl_ulong, salt);
    OA(int, rmode); OA(cl_mem, d_rc16); OA(cl_mem, d_rc8); OA(cl_mem, d_rsk);
    OA(cl_mem, ocl_qa_st); OA(cl_mem, ocl_qa_wd); OA(int, rrot); OA(int, rtele); OA(int, fast);
#undef OA
    if (err != CL_SUCCESS) { fprintf(stderr, "[OCL-ADAM] Kernargumente (%d)\n", err); return 0; }
    size_t lsz = 256, gsz = (size_t)rows * 256;
    err = ocl_nd(ocl_queue, k, 1, NULL, &gsz, &lsz, 0, NULL, NULL);
    if (err != CL_SUCCESS) { fprintf(stderr, "[OCL-ADAM] Kernstart abgelehnt (%d)\n", err); return 0; }
    if (clFinish(ocl_queue) != CL_SUCCESS) {
        fprintf(stderr, "🚨 [OCL-ADAM] Kernfehler - Gewichte unbestimmt, Abbruch\n"); exit(3);
    }
    int down = ocl_rd(ocl_queue, d_w, CL_TRUE, 0, n, h_w, 0, NULL, NULL) == CL_SUCCESS &&
               ocl_rd(ocl_queue, d_ws, CL_TRUE, 0, nr, h_wscale, 0, NULL, NULL) == CL_SUCCESS;
    if (down && mode == 2) {
        down = ocl_rd(ocl_queue, d_mqd, CL_TRUE, 0, n, h_mqd, 0, NULL, NULL) == CL_SUCCESS &&
               ocl_rd(ocl_queue, d_mqs, CL_TRUE, 0, nr, h_mqs, 0, NULL, NULL) == CL_SUCCESS &&
               ocl_rd(ocl_queue, d_vqd, CL_TRUE, 0, n, h_vqd, 0, NULL, NULL) == CL_SUCCESS &&
               ocl_rd(ocl_queue, d_vqs, CL_TRUE, 0, nr, h_vqs, 0, NULL, NULL) == CL_SUCCESS &&
               (!fb || rcode || ocl_rd(ocl_queue, d_res, CL_TRUE, 0, n * sizeof(float), h_res, 0, NULL, NULL) == CL_SUCCESS);
    }
    if (!down) { fprintf(stderr, "🚨 [OCL-ADAM] Rueckkopie fehlgeschlagen - Gewichte unbestimmt, Abbruch\n"); exit(3); }
    if (rtele) {
        cl_ulong* st = (cl_ulong*)malloc((size_t)rows * 10 * sizeof(cl_ulong));
        double* wdv = (double*)malloc((size_t)rows * sizeof(double));
        if (!st || !wdv ||
            ocl_rd(ocl_queue, ocl_qa_st, CL_TRUE, 0, (size_t)rows * 10 * sizeof(cl_ulong), st, 0, NULL, NULL) != CL_SUCCESS ||
            ocl_rd(ocl_queue, ocl_qa_wd, CL_TRUE, 0, (size_t)rows * sizeof(double), wdv, 0, NULL, NULL) != CL_SUCCESS) {
            fprintf(stderr, "[OCL-ADAM] Zaehler nicht gelesen\n");
        } else {
            for (int r = 0; r < rows; r++) { for (int j = 0; j < 10; j++) ocl_rest_cnt[j] += st[(size_t)r * 10 + j]; ocl_rest_wd += wdv[r]; }
        }
        free(st); free(wdv);
    }
    memset(h_g, 0, n * sizeof(float));
    return 1;
}

// ==============================================================================
// OCL-ATT (2026-11-12): int8-Attention auf dem OpenCL-Geraet, Gegenstueck zu cuda_att_fwd_i8/cuda_att_bw_i8 (Grundkerne,
// ohne ATT_FAST). Rueckgabe 0 = gerechnet; sonst nichts veraendert, der Aufrufer rechnet auf der CPU.
// Kerne im selben double-Programm wie OCL-ADAM (Hilfen FA/FM/DDIV/AZ).
// ==============================================================================
static cl_kernel ocl_att_k_scores = NULL, ocl_att_k_softmax = NULL, ocl_att_k_out = NULL, ocl_att_k_dw = NULL,
                 ocl_att_k_ds = NULL, ocl_att_k_dq = NULL, ocl_att_k_dkv = NULL, ocl_att_k_expf = NULL;
// OCL-ATT-FAST (2026-11-12): schnelle Kerne wie ATT-FAST (CUDA, e617); SNAI_ATT_FAST fehlt/1 = schnell, 0 = Grundkerne, ROT.
static cl_kernel ocl_att_k_scores_f = NULL, ocl_att_k_softmax_f = NULL, ocl_att_k_dw_f = NULL, ocl_att_k_ds_f = NULL,
                 ocl_att_k_out_g = NULL, ocl_att_k_dq_g = NULL, ocl_att_k_dkv_g1 = NULL;
static int ocl_att_fast_mode = -1;
static int ocl_att_fast_get(void) {
    if (ocl_att_fast_mode < 0) {
        const char* e = getenv("SNAI_ATT_FAST");
        if (e && strcmp(e, "0") == 0) ocl_att_fast_mode = 0;
        else if (e && strcmp(e, "ROT") == 0) ocl_att_fast_mode = 2;
        else if (!e || !*e || strcmp(e, "1") == 0) ocl_att_fast_mode = 1;
        else ocl_att_fast_mode = 0;
        if (ocl_att_fast_mode > 0 && !ocl_att_k_dkv_g1) {
            fprintf(stderr, "[OCL-ATT-FAST] schnelle Kerne nicht verfuegbar - Grundkerne\n"); ocl_att_fast_mode = 0;
        }
        if (getenv("SNAI_ATT_GO") || getenv("SNAI_ATT_GQ") || getenv("SNAI_ATT_RK"))
            fprintf(stderr, "[OCL-ATT-FAST] SNAI_ATT_GO/GQ/RK gelten nur unter CUDA; OpenCL rechnet fest mit GO=8 GQ=4 RK=0\n");
        fprintf(stderr, "[OCL-ATT-FAST] Attention-Kerne: %s\n",
                ocl_att_fast_mode == 0 ? "alt" : ocl_att_fast_mode == 2 ? "schnell ROT-PROBE" : "schnell");
    }
    return ocl_att_fast_mode;
}
static int ocl_att_scale_pow2(double a, float* scf) {
    if (!(a > 0.0 && a <= 1.0)) return 0;
    int e; double m = frexp(a, &e);
    if (m != 0.5 || e < -125) return 0;
    *scf = (float)a;
    return (double)*scf == a;
}
static size_t ocl_att_wg = 0;       // kleinste erlaubte Arbeitsgruppe der Kerne
static cl_mem ocl_att_buf[12];
static size_t ocl_att_cap[12];
static void ocl_att_kernels(cl_program p, cl_device_id dev) {
    cl_int e = CL_SUCCESS;
    cl_kernel* ks[8] = {&ocl_att_k_scores, &ocl_att_k_softmax, &ocl_att_k_out, &ocl_att_k_dw, &ocl_att_k_ds,
                        &ocl_att_k_dq, &ocl_att_k_dkv, &ocl_att_k_expf};
    const char* nm[8] = {"att_scores_kern", "att_softmax_kern", "att_out_kern", "att_dw_kern", "att_ds_kern",
                         "att_dq_kern", "att_dkv_kern", "att_expf_kern"};
    size_t mn = 1 << 20;
    for (int i = 0; i < 8; i++) {
        size_t kwg = 0;
        *ks[i] = clCreateKernel(p, nm[i], &e);
        if (e != CL_SUCCESS || clGetKernelWorkGroupInfo(*ks[i], dev, CL_KERNEL_WORK_GROUP_SIZE, sizeof(size_t), &kwg, NULL) != CL_SUCCESS) {
            fprintf(stderr, "[OCL-ATT] Kern %s nicht angelegt (%d) - Attention bleibt auf der CPU\n", nm[i], e);
            for (int j = 0; j < 8; j++) *ks[j] = NULL;
            return;
        }
        if (kwg < mn) mn = kwg;
    }
    ocl_att_wg = mn;
    if (ocl_att_wg < 256) {
        fprintf(stderr, "[OCL-ATT] Arbeitsgruppe %zu < 256 - Attention bleibt auf der CPU\n", ocl_att_wg);
        ocl_att_k_scores = NULL;
        return;
    }
    {   // OCL-ATT-FAST: ein Fehlschlag hier schaltet nur die schnellen Kerne ab
        cl_kernel* fk[7] = {&ocl_att_k_scores_f, &ocl_att_k_softmax_f, &ocl_att_k_dw_f, &ocl_att_k_ds_f,
                            &ocl_att_k_out_g, &ocl_att_k_dq_g, &ocl_att_k_dkv_g1};
        const char* fn[7] = {"att_scores_fast", "att_softmax_fast", "att_dw_fast", "att_ds_fast",
                             "att_out_g", "att_dq_g", "att_dkv_g1"};
        for (int i = 0; i < 7; i++) {
            size_t kwg = 0; cl_int e2 = CL_SUCCESS;
            *fk[i] = clCreateKernel(p, fn[i], &e2);
            if (e2 != CL_SUCCESS || clGetKernelWorkGroupInfo(*fk[i], dev, CL_KERNEL_WORK_GROUP_SIZE, sizeof(size_t), &kwg, NULL)
                    != CL_SUCCESS || kwg < 256) {
                fprintf(stderr, "[OCL-ATT-FAST] Kern %s nicht nutzbar (%d) - Grundkerne\n", fn[i], e2);
                for (int j = 0; j < 7; j++) *fk[j] = NULL;
                break;
            }
        }
    }
    fprintf(stderr, "[OCL-ATT] Kerne bereit (Arbeitsgruppe bis %zu)\n", ocl_att_wg);
}
int ocl_att_ready(void) { return ocl_att_k_scores != NULL; }
static int ocl_att_need(int i, size_t bytes) { return ocl_ensure(&ocl_att_buf[i], &ocl_att_cap[i], bytes); }
static int ocl_att_up(int i, const void* h, size_t bytes) {
    return ocl_att_need(i, bytes) && ocl_wr(ocl_queue, ocl_att_buf[i], CL_TRUE, 0, bytes, h, 0, NULL, NULL) == CL_SUCCESS;
}
static size_t ocl_att_rund(size_t n, size_t m) { return (n + m - 1) / m * m; }
#define OAK(k, t, v) e |= clSetKernelArg(k, a++, sizeof(t), (void*)&(v))

// Pruefstand fuer att_expf (wie cuda_att_expf_test): 0 = gerechnet.
int ocl_att_expf_test(const float* h_in, float* h_out, int n, int variant) {
    if (!ocl_att_k_expf || n <= 0) return 8;
    if (!ocl_att_up(0, h_in, (size_t)n * 4) || !ocl_att_need(1, (size_t)n * 4)) return 1;
    cl_int e = CL_SUCCESS; int a = 0; cl_kernel k = ocl_att_k_expf;
    OAK(k, cl_mem, ocl_att_buf[0]); OAK(k, cl_mem, ocl_att_buf[1]); OAK(k, int, n); OAK(k, int, variant);
    size_t g = ocl_att_rund((size_t)n, 256), l = 256;
    if (e != CL_SUCCESS || ocl_nd(ocl_queue, k, 1, NULL, &g, &l, 0, NULL, NULL) != CL_SUCCESS ||
        clFinish(ocl_queue) != CL_SUCCESS) return 2;
    return ocl_rd(ocl_queue, ocl_att_buf[1], CL_TRUE, 0, (size_t)n * 4, h_out, 0, NULL, NULL) == CL_SUCCESS ? 0 : 3;
}

static int ocl_att_scores_softmax(int act, int dim, int nH, int hs, float sqrtHs, cl_mem S) {
    const int fm = ocl_att_fast_get();
    const int vec = fm && hs % 16 == 0 && dim % 16 == 0;
    cl_int e = CL_SUCCESS; int a = 0; cl_kernel k = vec ? ocl_att_k_scores_f : ocl_att_k_scores;
    OAK(k, cl_mem, ocl_att_buf[0]); OAK(k, cl_mem, ocl_att_buf[1]); OAK(k, cl_mem, ocl_att_buf[2]); OAK(k, cl_mem, ocl_att_buf[3]);
    OAK(k, cl_mem, S); OAK(k, int, act); OAK(k, int, dim); OAK(k, int, hs); OAK(k, float, sqrtHs);
    size_t g2[2] = {ocl_att_rund((size_t)act, 256), (size_t)nH * act}, l2[2] = {256, 1};
    if (e != CL_SUCCESS || ocl_nd(ocl_queue, k, 2, NULL, g2, l2, 0, NULL, NULL) != CL_SUCCESS) return 4;
    int nrows = nH * act; a = 0;
    if (fm) {
        int rotf = (fm == 2); k = ocl_att_k_softmax_f;
        OAK(k, cl_mem, S); OAK(k, int, act); OAK(k, int, nrows); OAK(k, int, rotf);
        size_t gf = (size_t)nrows * 64, lf = 64;
        if (e != CL_SUCCESS || ocl_nd(ocl_queue, k, 1, NULL, &gf, &lf, 0, NULL, NULL) != CL_SUCCESS) return 4;
        return 0;
    }
    k = ocl_att_k_softmax;
    OAK(k, cl_mem, S); OAK(k, int, act); OAK(k, int, nrows);
    size_t g = ocl_att_rund((size_t)nrows, 128), l = 128;
    if (e != CL_SUCCESS || ocl_nd(ocl_queue, k, 1, NULL, &g, &l, 0, NULL, NULL) != CL_SUCCESS) return 4;
    return 0;
}

int ocl_att_fwd_i8(const signed char* q8, const float* qs, const signed char* k8, const float* ks,
                   const signed char* v8, const float* vs, float* out,
                   int act, int dim, int nH, int hs, float sqrtHs, int rot) {
    if (!ocl_att_ready()) return 8;
    if (act <= 0 || (size_t)hs > ocl_att_wg || nH * hs != dim) return 9;
    size_t ad = (size_t)act * dim, aa = (size_t)nH * act * act;
    if (!ocl_att_up(0, q8, ad) || !ocl_att_up(1, qs, act * 4) || !ocl_att_up(2, k8, ad) || !ocl_att_up(3, ks, act * 4) ||
        !ocl_att_up(4, v8, ad) || !ocl_att_up(5, vs, act * 4) || !ocl_att_need(6, aa * 4) || !ocl_att_need(7, ad * 4)) return 1;
    int r = ocl_att_scores_softmax(act, dim, nH, hs, sqrtHs, ocl_att_buf[6]);
    if (r) return r;
    const int fm = ocl_att_fast_get();
    cl_int e = CL_SUCCESS; int a = 0; cl_kernel k = fm ? ocl_att_k_out_g : ocl_att_k_out;
    OAK(k, cl_mem, ocl_att_buf[4]); OAK(k, cl_mem, ocl_att_buf[5]); OAK(k, cl_mem, ocl_att_buf[6]); OAK(k, cl_mem, ocl_att_buf[7]);
    OAK(k, int, act); OAK(k, int, dim); OAK(k, int, hs); OAK(k, int, rot);
    size_t g = (size_t)nH * (fm ? (size_t)((act + 7) / 8) : (size_t)act) * hs, l = (size_t)hs;
    if (e != CL_SUCCESS || ocl_nd(ocl_queue, k, 1, NULL, &g, &l, 0, NULL, NULL) != CL_SUCCESS) return 4;
    if (clFinish(ocl_queue) != CL_SUCCESS) return 2;
    if (ocl_rd(ocl_queue, ocl_att_buf[7], CL_TRUE, 0, ad * 4, out, 0, NULL, NULL) != CL_SUCCESS) return 3;
    return 0;
}

int ocl_att_bw_i8(const signed char* q8, const float* qs, const signed char* k8, const float* ks,
                  const signed char* v8, const float* vs, const float* datt, float* dq, float* dk, float* dv,
                  int act, int dim, int nH, int hs, float sqrtHs, double attScale, int rot) {
    if (!ocl_att_ready()) return 8;
    if (act <= 0 || (size_t)hs > ocl_att_wg || nH * hs != dim) return 9;
    size_t ad = (size_t)act * dim, aa = (size_t)nH * act * act;
    if (!ocl_att_up(0, q8, ad) || !ocl_att_up(1, qs, act * 4) || !ocl_att_up(2, k8, ad) || !ocl_att_up(3, ks, act * 4) ||
        !ocl_att_up(4, v8, ad) || !ocl_att_up(5, vs, act * 4) || !ocl_att_need(6, aa * 4) || !ocl_att_need(8, aa * 4) ||
        !ocl_att_up(9, datt, ad * 4) || !ocl_att_up(10, dk, ad * 4) || !ocl_att_up(11, dv, ad * 4) || !ocl_att_need(7, ad * 4)) return 1;
    int r = ocl_att_scores_softmax(act, dim, nH, hs, sqrtHs, ocl_att_buf[6]);
    if (r) return r;
    const int fm = ocl_att_fast_get();
    const int vec = fm && hs % 16 == 0 && dim % 16 == 0;
    cl_int e = CL_SUCCESS; int a = 0; cl_kernel k = vec ? ocl_att_k_dw_f : ocl_att_k_dw;
    OAK(k, cl_mem, ocl_att_buf[9]); OAK(k, cl_mem, ocl_att_buf[4]); OAK(k, cl_mem, ocl_att_buf[5]); OAK(k, cl_mem, ocl_att_buf[8]);
    OAK(k, int, act); OAK(k, int, dim); OAK(k, int, hs);
    size_t g2[2] = {ocl_att_rund((size_t)act, 256), (size_t)nH * act}, l2[2] = {256, 1};
    if (e != CL_SUCCESS || ocl_nd(ocl_queue, k, 2, NULL, g2, l2, 0, NULL, NULL) != CL_SUCCESS) return 4;
    int nrows = nH * act; a = 0; k = fm ? ocl_att_k_ds_f : ocl_att_k_ds;
    OAK(k, cl_mem, ocl_att_buf[6]); OAK(k, cl_mem, ocl_att_buf[8]); OAK(k, int, act); OAK(k, int, nrows);
    size_t g = fm ? (size_t)nrows * 64 : ocl_att_rund((size_t)nrows, 128), l = fm ? 64 : 128;
    if (e != CL_SUCCESS || ocl_nd(ocl_queue, k, 1, NULL, &g, &l, 0, NULL, NULL) != CL_SUCCESS) return 4;
    if (fm && rot == 0) {
        float scf = 0.0f;
        int fdq = ocl_att_scale_pow2(attScale, &scf);
        a = 0; k = ocl_att_k_dq_g;
        OAK(k, cl_mem, ocl_att_buf[8]); OAK(k, cl_mem, ocl_att_buf[2]); OAK(k, cl_mem, ocl_att_buf[3]); OAK(k, cl_mem, ocl_att_buf[7]);
        OAK(k, int, act); OAK(k, int, dim); OAK(k, int, hs); OAK(k, double, attScale); OAK(k, int, fdq); OAK(k, float, scf);
        g = (size_t)nH * ((act + 3) / 4) * hs; l = (size_t)hs;
        if (e != CL_SUCCESS || ocl_nd(ocl_queue, k, 1, NULL, &g, &l, 0, NULL, NULL) != CL_SUCCESS) return 4;
        a = 0; k = ocl_att_k_dkv_g1;
        OAK(k, cl_mem, ocl_att_buf[8]); OAK(k, cl_mem, ocl_att_buf[6]); OAK(k, cl_mem, ocl_att_buf[9]); OAK(k, cl_mem, ocl_att_buf[0]);
        OAK(k, cl_mem, ocl_att_buf[1]); OAK(k, cl_mem, ocl_att_buf[10]); OAK(k, cl_mem, ocl_att_buf[11]);
        OAK(k, int, act); OAK(k, int, dim); OAK(k, int, hs); OAK(k, double, attScale); OAK(k, int, fdq); OAK(k, float, scf);
        g = (size_t)nH * act * hs;
        if (e != CL_SUCCESS || ocl_nd(ocl_queue, k, 1, NULL, &g, &l, 0, NULL, NULL) != CL_SUCCESS) return 4;
        goto fertig;
    }
    a = 0; k = ocl_att_k_dq;
    OAK(k, cl_mem, ocl_att_buf[8]); OAK(k, cl_mem, ocl_att_buf[2]); OAK(k, cl_mem, ocl_att_buf[3]); OAK(k, cl_mem, ocl_att_buf[7]);
    OAK(k, int, act); OAK(k, int, dim); OAK(k, int, hs); OAK(k, double, attScale); OAK(k, int, rot);
    g = (size_t)nH * act * hs; l = (size_t)hs;
    if (e != CL_SUCCESS || ocl_nd(ocl_queue, k, 1, NULL, &g, &l, 0, NULL, NULL) != CL_SUCCESS) return 4;
    a = 0; k = ocl_att_k_dkv;
    OAK(k, cl_mem, ocl_att_buf[8]); OAK(k, cl_mem, ocl_att_buf[6]); OAK(k, cl_mem, ocl_att_buf[9]); OAK(k, cl_mem, ocl_att_buf[0]);
    OAK(k, cl_mem, ocl_att_buf[1]); OAK(k, cl_mem, ocl_att_buf[10]); OAK(k, cl_mem, ocl_att_buf[11]);
    OAK(k, int, act); OAK(k, int, dim); OAK(k, int, hs); OAK(k, double, attScale); OAK(k, int, rot);
    if (e != CL_SUCCESS || ocl_nd(ocl_queue, k, 1, NULL, &g, &l, 0, NULL, NULL) != CL_SUCCESS) return 4;
fertig:
    if (clFinish(ocl_queue) != CL_SUCCESS) return 2;
    if (ocl_rd(ocl_queue, ocl_att_buf[7], CL_TRUE, 0, ad * 4, dq, 0, NULL, NULL) != CL_SUCCESS ||
        ocl_rd(ocl_queue, ocl_att_buf[10], CL_TRUE, 0, ad * 4, dk, 0, NULL, NULL) != CL_SUCCESS ||
        ocl_rd(ocl_queue, ocl_att_buf[11], CL_TRUE, 0, ad * 4, dv, 0, NULL, NULL) != CL_SUCCESS) {
        fprintf(stderr, "🚨 [OCL-ATT] Rueckkopie fehlgeschlagen - Gradienten unbestimmt, Abbruch\n");
        exit(3);
    }
    return 0;
}
#undef OAK

""" .}

proc init_opencl_engine*(): cint {.importc: "init_opencl_engine", cdecl.}
proc shutdown_opencl_engine*() {.importc: "shutdown_opencl_engine", cdecl.}
proc ocl_sync_to_host*(h_ptr: pointer) {.importc: "ocl_sync_to_host", cdecl.}
proc ocl_device_checksum*(p: pointer, bytes: csize_t): clong {.importc: "ocl_device_checksum", cdecl.}

proc ocl_sync_to_device*(h_ptr: pointer, bytes: csize_t) {.importc: "ocl_sync_to_device", cdecl.}
proc ocl_release_buffer*(h_ptr: pointer) {.importc: "ocl_release_buffer", cdecl.}
proc ocl_matVecMul*(m: ptr cfloat, v: ptr cfloat, out_v: ptr cfloat, rows: cint, cols: cint) {.importc: "ocl_matVecMul", cdecl.}
proc ocl_attentionForward*(q: ptr cfloat, k_cache: ptr cfloat, v_cache: ptr cfloat, out_v: ptr cfloat, pos: cint, numHeads: cint, headSize: cint, dim: cint, ctx: cint) {.importc: "ocl_attentionForward", cdecl.}
proc ocl_attentionBackward*(q: ptr cfloat, k_cache: ptr cfloat, v_cache: ptr cfloat, d_att_out: ptr cfloat, d_q: ptr cfloat, d_k_cache: ptr cfloat, d_v_cache: ptr cfloat, pos: cint, numHeads: cint, headSize: cint, dim: cint, ctx: cint) {.importc: "ocl_attentionBackward", cdecl.}
proc ocl_adamStep*(w: ptr cfloat, m: ptr cfloat, v: ptr cfloat, g: ptr cfloat, lr: cfloat, b1: cfloat, b2: cfloat, b1t: cfloat, b2t: cfloat, scale: cfloat, size: cint, is_sparse: cint, cols: cint, bound_r: cint, bound_c: cint, boost: cfloat, wd: cfloat) {.importc: "ocl_adamStep", cdecl.}
proc ocl_zero_buffer*(h_ptr: ptr cfloat, bytes: csize_t) {.importc: "ocl_zero_buffer", cdecl.}
proc ocl_matVecMulT*(m: ptr cfloat, d_out: ptr cfloat, d_in: ptr cfloat, rows: cint, cols: cint, accumulate: cint) {.importc: "ocl_matVecMulT", cdecl.}
proc ocl_gradAccum*(gm: ptr cfloat, d_out: ptr cfloat, i_v: ptr cfloat, rows: cint, cols: cint) {.importc: "ocl_gradAccum", cdecl.}
proc ocl_matMulBatched*(m: ptr cfloat, i_v: ptr cfloat, o_v: ptr cfloat, rows: cint, cols: cint, batch: cint) {.importc: "ocl_matMulBatched", cdecl.}
proc ocl_matMulTBatched*(m: ptr cfloat, d_out: ptr cfloat, d_in: ptr cfloat, rows: cint, cols: cint, batch: cint, accumulate: cint) {.importc: "ocl_matMulTBatched", cdecl.}
proc ocl_gradAccumBatched*(gm: ptr cfloat, d_out: ptr cfloat, i_v: ptr cfloat, rows: cint, cols: cint, batch: cint) {.importc: "ocl_gradAccumBatched", cdecl.}
proc ocl_attentionForwardBatched*(q_all: ptr cfloat, k_cache: ptr cfloat, v_cache: ptr cfloat, att_out_all: ptr cfloat, act: cint, numHeads: cint, headSize: cint, dim: cint, ctx: cint) {.importc: "ocl_attentionForwardBatched", cdecl.}
proc ocl_attentionBackwardBatched*(q_all: ptr cfloat, k_cache: ptr cfloat, v_cache: ptr cfloat, d_att_out_all: ptr cfloat, d_q_all: ptr cfloat, d_k_cache: ptr cfloat, d_v_cache: ptr cfloat, act: cint, numHeads: cint, headSize: cint, dim: cint, ctx: cint) {.importc: "ocl_attentionBackwardBatched", cdecl.}

# PHASE 3 DES INT8-UMBAUS
proc ocl_matVecMulI8*(m: ptr int8, mScale: ptr cfloat, v: ptr int8, vScale: cfloat, o_v: ptr cfloat, rows: cint, cols: cint) {.importc: "ocl_matVecMulI8", cdecl.}
proc ocl_matVecMulTI8*(m: ptr int8, mScale: ptr cfloat, d_out: ptr cfloat, d_in: ptr cfloat, rows: cint, cols: cint, accumulate: cint) {.importc: "ocl_matVecMulTI8", cdecl.}
proc ocl_push_qmatrix*(data: ptr int8, scale: ptr cfloat, rows: cint, cols: cint) {.importc: "ocl_push_qmatrix", cdecl.}
proc ocl_adamStepI8*(w: ptr int8, wScale: ptr cfloat, m: ptr cfloat, v: ptr cfloat, g: ptr cfloat, lr: cfloat, b1: cfloat, b2: cfloat, b1t: cfloat, b2t: cfloat, scale: cfloat, size: cint, is_sparse: cint, cols: cint, bound_r: cint, bound_c: cint, boost: cfloat, wd: cfloat) {.importc: "ocl_adamStepI8", cdecl.}
proc ocl_matMulBatchedI8*(m: ptr int8, mScale: ptr cfloat, i_v: ptr int8, inScale: ptr cfloat, o_v: ptr cfloat, rows: cint, cols: cint, batch: cint) {.importc: "ocl_matMulBatchedI8", cdecl.}
proc ocl_matMulTBatchedI8*(m: ptr int8, mScale: ptr cfloat, d_out: ptr cfloat, d_in: ptr cfloat, rows: cint, cols: cint, batch: cint, accumulate: cint) {.importc: "ocl_matMulTBatchedI8", cdecl.}
# FULL-INT8 Schritt 1 auf der GPU: der Host uebergibt den bereits quantisierten
# Gradienten und die Blockskalen (siehe Kommentar am Kernel).
var ocl_bw_din_calls* {.importc: "ocl_bw_din_calls".}: clong

var ocl_gradacc_calls* {.importc: "ocl_gradacc_calls".}: clong

proc ocl_backwardDInI8Batched*(w, dq: ptr int8, bscale, d_in: ptr cfloat,
                               rows, cols, batch, blockSize, accumulate: cint)
                              {.importc: "ocl_backwardDInI8Batched", cdecl.}

proc ocl_gradAccumI8*(qi, qd: ptr int8, dsc, isc: ptr cfloat, gm: ptr cfloat,
                      rows, cols, batch, qiStride, gmOnDevice: cint)
                     {.importc: "ocl_gradAccumI8", cdecl.}

proc ocl_backwardDInI8*(w: ptr int8, dq: ptr int8, bscale: ptr cfloat, d_in: ptr cfloat,
                        rows: cint, cols: cint, blockSize: cint, accumulate: cint)
                       {.importc: "ocl_backwardDInI8", cdecl.}

# PHASE 10 DES INT8-UMBAUS: Float-Adam je Zeile + Fehler-Rueckfuehrung
proc ocl_adamRowFloatI8*(w: ptr int8, wScale: ptr cfloat, m: ptr cfloat, v: ptr cfloat, g: ptr cfloat, res: ptr cfloat, lr: cfloat, b1: cfloat, b2: cfloat, b1t: cfloat, b2t: cfloat, scale: cfloat, rows: cint, cols: cint, is_sparse: cint, bound_r: cint, bound_c: cint, boost: cfloat, wd: cfloat, use_fb: cint) {.importc: "ocl_adamRowFloatI8", cdecl.}

# OCL-ADAM (2026-11-12): Adam mit int8-Momenten auf dem OpenCL-Geraet (Gegenstueck zu cuda_adamRowQI8Rest).
proc ocl_adam_q_ready*(): cint {.importc: "ocl_adam_q_ready", cdecl.}
proc ocl_rest_stats*(o: ptr uint64, owd: ptr cdouble) {.importc: "ocl_rest_stats", cdecl.}
proc ocl_adamRowQI8Rest*(w: ptr int8, ws: ptr cfloat, mqd: ptr uint8, mqs: ptr cfloat, vqd: ptr uint8, vqs: ptr cfloat,
                         g: ptr cfloat, res: ptr cfloat, tabM: ptr cfloat, tabV: ptr cfloat, lgr: cdouble,
                         lr, b1, b2, b1t, b2t, gscale: cfloat, rows, cols, is_sparse, bound_r, bound_c: cint,
                         boost, wd: cfloat, use_fb, mode, sr_mask: cint, sr_salt: uint64,
                         rmode, rrot, rtele: cint): cint {.importc: "ocl_adamRowQI8Rest", cdecl.}

# OCL-ATT (2026-11-12): int8-Attention auf dem OpenCL-Geraet (Gegenstueck zu cuda_att_fwd_i8/cuda_att_bw_i8).
proc ocl_att_ready*(): cint {.importc: "ocl_att_ready", cdecl.}
proc ocl_att_expf_test*(i: ptr cfloat, o: ptr cfloat, n, variant: cint): cint {.importc: "ocl_att_expf_test", cdecl.}
proc ocl_att_fwd_i8*(q8: ptr int8, qs: ptr cfloat, k8: ptr int8, ks: ptr cfloat, v8: ptr int8, vs: ptr cfloat,
                     o: ptr cfloat, act, dim, nH, hs: cint, sqrtHs: cfloat, rot: cint): cint {.importc: "ocl_att_fwd_i8", cdecl.}
proc ocl_att_bw_i8*(q8: ptr int8, qs: ptr cfloat, k8: ptr int8, ks: ptr cfloat, v8: ptr int8, vs: ptr cfloat,
                    datt, dq, dk, dv: ptr cfloat, act, dim, nH, hs: cint, sqrtHs: cfloat, attScale: cdouble,
                    rot: cint): cint {.importc: "ocl_att_bw_i8", cdecl.}
