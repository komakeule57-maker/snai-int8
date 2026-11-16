# cortex_gz.nim - FULLINT8: eigener CPU-Trainingspfad, Baustein fuer Baustein ganzzahlig.
# Nachweise je Stufe: docs/messreihen/fullint8-*.md, Kriterien in docs/messreihen/fullint8/.
# Wird per `include` in cortex.nim eingefuegt, unmittelbar vor cortexTrainStepI8Roh, und nur dort benutzt.
#
# Stufe SNAI_I8_GANZ (0 = aus, alter Pfad unveraendert):
#   1 Geruest: GZ-Vorwaerts/Rueckwaerts, jeder Baustein in float-Referenz (= die Rechnung des alten Pfads);
#     Clip und Adam alter Weg.
#   2.. je Stufe ein weiterer Baustein ganzzahlig (Messreihen snai/fullint8-*).
#
# Zwischenwerte zwischen den Bausteinen: GzT = Zeilen aus int32-Mantissen mit EINEM Exponenten je Zeile
# (Wert = m * 2^e, |m| < 2^30). Referenzbausteine wandeln an ihren Grenzen in float32 und zurueck.

import std/bitops

type
  GzI32A = UncheckedArray[int32]
  GzT = object
    rows, cols: int
    m: ptr GzI32A      # rows*cols Mantissen
    e: ptr GzI32A      # rows Exponenten

const GZ_MB = 30       # |m| < 2^GZ_MB

var gzStufeW = -1
proc gzStufe(): int =
  if gzStufeW < 0:
    let w = getEnv("SNAI_I8_GANZ")
    gzStufeW = (if w == "": 0 else: parseInt(w))
    if gzStufeW < 0 or gzStufeW > 12:
      stderr.writeLine("SNAI_I8_GANZ='", w, "' ungueltig (0..12) - Abbruch"); quit(1)
  gzStufeW

# Schalter je Stufe (2026-11-15, damit jede Stufe einzeln zurueckdrehbar ist):
# - SNAI_I8_GANZ=N (0..12): Stufe 1 (Geruest = GZ-Datenpfad) ab N >= 1, dazu Kurzform fuer die Stufen 2..N.
#   Vorgabe 0 = alter Weg, unveraendert.
# - SNAI_I8_GZ_<NAME>=1|0 schaltet eine einzelne Stufe k >= 2 an bzw. aus und ueberschreibt die Kurzform.
#   Namen: 2 MATMUL, 3 ADAM, 4 NORM, 5 ROPE, 6 ATT, 7 LOGITS, 8 REST, 9 LRPLAN, 10 CKPT, 11 MERGE, 12 GFREI.
# - Abhaengigkeit: jede Stufe k >= 2 setzt das Geruest voraus (SNAI_I8_GANZ >= 1); ohne Geruest wirkt sie nicht
#   (Warnung). Einzige weitere Abhaengigkeit: Stufe 9 (LRPLAN) speist den ganzzahligen Adam und braucht Stufe 3
#   (ADAM); ohne sie Warnung und ohne Wirkung. Stufe 10 (CKPT) betrifft nur das Schreiben des Checkpoints (SNAI_V8);
#   Lesen von V8 geht immer, auch ohne Schalter. Stufe 11 (MERGE, 2026-11-16) mittelt SNAI_V8 mehrerer Worker
#   ganzzahlig (nur in der Hauptinstanz, train_cluster.php) und braucht Stufe 10 (CKPT); ohne sie Warnung und ohne
#   Wirkung. Stufe 12 (GFREI, 2026-11-16) legt die float-Gradientenpuffer der Matrizen nicht mehr an und braucht
#   dafuer die Stufen 2, 3 und 8 (sonst Warnung, aus). Untereinander sind die Stufen frei kombinierbar; die Kleber zwischen ganzzahligen und float-Teilen
#   stehen in gzFwdBwd (Stufe aus => ihr float-Baustein liefert in die alten Puffer, Kleber setzt um).
const GZ_NAMEN = ["", "GERUEST", "MATMUL", "ADAM", "NORM", "ROPE", "ATT", "LOGITS", "REST", "LRPLAN", "CKPT", "MERGE", "GFREI"]
var gzAnW: array[13, bool]
var gzAnFertig = false
proc gzAn(k: int): bool =
  if not gzAnFertig:
    gzAnFertig = true
    let st = gzStufe()
    var liste = ""
    for i in 1 .. 12:
      var an = st >= i
      if i >= 2:
        let w = getEnv("SNAI_I8_GZ_" & GZ_NAMEN[i])
        if w == "1": an = true
        elif w == "0": an = false
        elif w != "":
          stderr.writeLine("SNAI_I8_GZ_", GZ_NAMEN[i], "='", w, "' ungueltig (0|1) - Abbruch"); quit(1)
        if an and st == 0:
          stderr.writeLine("  > [GZ] WARNUNG: SNAI_I8_GZ_", GZ_NAMEN[i], "=1 wirkt nur mit SNAI_I8_GANZ >= 1 (Geruest) - aus")
          an = false
        if i == 9 and an and not gzAnW[3]:
          stderr.writeLine("  > [GZ] WARNUNG: Stufe 9 (LRPLAN) speist den ganzzahligen Adam und wirkt nur mit Stufe 3 (ADAM) - aus")
          an = false
        if i == 11 and an and not gzAnW[10]:
          stderr.writeLine("  > [GZ] WARNUNG: Stufe 11 (MERGE) mittelt SNAI_V8 und wirkt nur mit Stufe 10 (CKPT) - aus")
          an = false
        if i == 12 and an and not (gzAnW[2] and gzAnW[3] and gzAnW[8]):
          stderr.writeLine("  > [GZ] WARNUNG: Stufe 12 (GFREI) braucht die Stufen 2 (MATMUL), 3 (ADAM) und 8 (REST) - aus")
          an = false
      gzAnW[i] = an
      if an: liste.add(" " & $i & ":" & GZ_NAMEN[i])
    if st > 0: stderr.writeLine("  > [GZ] Ganzzahl-Pfad SNAI_I8_GANZ=", st, ", Stufen an:", liste)
  gzAnW[k]

proc gzAlloc(rows, cols: int): GzT =
  result.rows = rows
  result.cols = cols
  result.m = cast[ptr GzI32A](allocShared0(max(1, rows * cols) * sizeof(int32)))
  result.e = cast[ptr GzI32A](allocShared0(max(1, rows) * sizeof(int32)))

# --- Referenz-Kleber float32 <-> GzT (nur in Referenzbausteinen, d.h. Stufen < 8) -------------------------
proc gzP2(e: int): float64 {.inline.} =
  ## 2^e exakt (Bitmuster), fuer |e| <= 1022.
  cast[float64](uint64(e + 1023) shl 52)

proc gzSetRowF(t: GzT, r: int, src: ptr FloatArray) =
  let n = t.cols
  let off = r * n
  var mx = 0.0'f64
  for c in 0 ..< n:
    let a = abs(src[c].float64)
    if a > mx: mx = a
  if mx == 0.0 or mx != mx or mx > 1e30:
    for c in 0 ..< n: t.m[off + c] = 0
    t.e[r] = 0
    return
  var k: int
  discard frexp(mx, k)          # mx = f * 2^k, f in [0.5, 1)
  let e = k - GZ_MB
  let sk = gzP2(-e)
  let lim = (1'i64 shl GZ_MB) - 1
  for c in 0 ..< n:
    var q = round(src[c].float64 * sk).int64
    if q > lim: q = lim
    elif q < -lim: q = -lim
    t.m[off + c] = q.int32
  t.e[r] = e.int32

proc gzRowToF(t: GzT, r: int, dst: ptr FloatArray) =
  let n = t.cols
  let off = r * n
  let s = gzP2(t.e[r].int)
  for c in 0 ..< n: dst[c] = (t.m[off + c].float64 * s).cfloat

proc gzToF(t: GzT, rows: int, dst: ptr FloatArray) =
  for r in 0 ..< rows: gzRowToF(t, r, cast[ptr FloatArray](addr dst[r * t.cols]))

proc gzFromF(t: GzT, rows: int, src: ptr FloatArray) =
  for r in 0 ..< rows: gzSetRowF(t, r, cast[ptr FloatArray](addr src[r * t.cols]))

# --- Ganzzahl-Werkzeuge (keine Gleitkommarechnung; float32-Skalen werden nur bitweise zerlegt) ------------
proc gzBits(x: uint64): int {.inline.} = (if x == 0'u64: 0 else: 64 - countLeadingZeroBits(x))
proc gzAbsU(x: int64): uint64 {.inline.} = (if x < 0: uint64(-x) else: uint64(x))
proc gzShr(x: int64, s: int): int64 {.inline.} =
  ## x / 2^s, symmetrisch zum Naechsten gerundet (Halbe weg von null); s <= 0 schiebt nach links.
  if s <= 0: return x shl (-s)
  if s >= 62: return 0
  let h = 1'i64 shl (s - 1)
  if x >= 0: (x + h) shr s else: -((-x + h) shr s)
proc gzDivR(a, b: int64): int64 {.inline.} =
  ## a / b zum Naechsten gerundet (Halbe weg von null), b > 0.
  if a >= 0: (a + b div 2) div b else: -((-a + b div 2) div b)

type GzMul = object
  m: int64     # 0 oder |m| in [2^23, 2^24)
  e: int32
proc gzMulF(x: cfloat): GzMul =
  ## float32 -> Mantisse/Exponent, exakt, nur Bitoperationen.
  let b = cast[uint32](x)
  let ex = int((b shr 23) and 0xFF'u32)
  var fr = int64(b and 0x7FFFFF'u32)
  if ex == 255: return GzMul(m: 0, e: 0)          # NaN/Inf: als 0 (der alte Pfad markiert das gesondert)
  var e: int
  if ex == 0:
    if fr == 0: return GzMul(m: 0, e: 0)
    e = -149
    while fr < (1'i64 shl 23):
      fr = fr shl 1
      dec e
  else:
    fr = fr or (1'i64 shl 23)
    e = ex - 150
  result.m = (if (b and 0x80000000'u32) != 0: -fr else: fr)
  result.e = e.int32
proc gzMulAus(mb: int64, ebase: int, div127: bool): GzMul =
  ## Skala (mb [/127]) * 2^ebase als 24-Bit-Mantisse, mb > 0.
  let k = (if div127: 31 else: 24) - gzBits(uint64(mb))
  let v = (if k >= 0: mb shl k else: gzShr(mb, -k))
  var m = (if div127: gzDivR(v, 127) else: v)
  var e = ebase - k
  if m >= (1'i64 shl 24):
    m = gzShr(m, 1)
    inc e
  GzMul(m: m, e: e.int32)

var gzI64: seq[int64]     # Scratch, serielle Bausteine
var gzI64b: seq[int64]
proc gzI64P(s: var seq[int64], n: int): ptr UncheckedArray[int64] =
  if s.len < n: s.setLen(n)
  cast[ptr UncheckedArray[int64]](addr s[0])

proc gzPutRow(t: GzT, r: int, buf: ptr UncheckedArray[int64], n: int, ebase: int) =
  ## int64-Werte (Wert = v * 2^ebase) als Zeile mit |m| < 2^30 ablegen.
  var mx = 0'u64
  for c in 0 ..< n:
    let a = gzAbsU(buf[c])
    if a > mx: mx = a
  let off = r * t.cols
  if mx == 0'u64:
    for c in 0 ..< n: t.m[off + c] = 0
    t.e[r] = 0
    return
  let s = gzBits(mx) - GZ_MB
  let lim = (1'i64 shl GZ_MB) - 1
  for c in 0 ..< n:
    var v = gzShr(buf[c], s)
    if v > lim: v = lim
    elif v < -lim: v = -lim
    t.m[off + c] = v.int32
  t.e[r] = (ebase + s).int32

proc gzRowNull(t: GzT, r: int): bool =
  for c in 0 ..< t.cols:
    if t.m[r * t.cols + c] != 0: return false
  true

proc gzAddRow(t: GzT, r: int, buf: ptr UncheckedArray[int64], n: int, ebase: int) =
  ## Zeile r += buf * 2^ebase (Exponenten angleichen, Summe neu normieren).
  if gzRowNull(t, r):
    gzPutRow(t, r, buf, n, ebase)
    return
  var mx = 0'u64
  for c in 0 ..< n:
    let a = gzAbsU(buf[c])
    if a > mx: mx = a
  if mx == 0'u64: return
  # buf erst auf 30 Bit bringen, dann beide auf den groesseren Exponenten
  let sb = gzBits(mx) - GZ_MB
  let eb = ebase + sb
  let et = t.e[r].int
  let E = max(eb, et) + 1
  let off = r * t.cols
  let tmp = gzI64P(gzI64b, n)
  for c in 0 ..< n:
    tmp[c] = gzShr(gzShr(buf[c], sb), E - eb) + gzShr(t.m[off + c].int64, E - et)
  gzPutRow(t, r, tmp, n, E)

proc gzIsqrt(x: uint64): uint64 =
  ## floor(sqrt(x)), Newton von oben (monoton fallend bis zum Ergebnis).
  if x < 2'u64: return x
  var g = 1'u64 shl ((gzBits(x) + 1) div 2)
  while true:
    let n = (g + x div g) shr 1
    if n >= g: return g
    g = n

# --- Norm (Summe der Quadrate mit Exponent) ---
type GzAkk = object
  m: uint64      # <= 2^62
  e: int
proc gzAkk61(x: var uint64, e: var int) {.inline.} =
  let b = gzBits(x)
  if b == 0: return
  if b < 61:
    x = x shl (61 - b)
    e -= 61 - b
  elif b > 61:
    x = uint64(gzShr(int64(x), b - 61))
    e += b - 61
proc gzAkkAdd(a: var GzAkk, v: uint64, ve: int) =
  if v == 0'u64: return
  var x = v
  var xe = ve
  gzAkk61(x, xe)
  if a.m == 0'u64:
    a.m = x
    a.e = xe
    return
  gzAkk61(a.m, a.e)
  let E = max(a.e, xe)
  a.m = uint64(gzShr(int64(a.m), E - a.e)) + uint64(gzShr(int64(x), E - xe))
  a.e = E
  gzAkk61(a.m, a.e)
# --- Gradientenpuffer: int32 je Gewicht, Exponent je Zeile -------------------------------------------------
type GzG = GzT   # Zeile r mit Mantisse und Exponent; Nullzeile = Gradient 0

proc gzGNull(g: GzG) =
  zeroMem(g.m, g.rows * g.cols * sizeof(int32))
  zeroMem(g.e, g.rows * sizeof(int32))

proc gzGZuFloat(g: GzG, dst: ptr FloatArray) =
  ## Kleber zu Stufen mit altem float-Adam: dst = Wert (float32).
  for r in 0 ..< g.rows:
    let s = gzP2(g.e[r].int)
    for c in 0 ..< g.cols: dst[r * g.cols + c] = (g.m[r * g.cols + c].float64 * s).cfloat

proc gzFloatZuG(src: ptr FloatArray, g: GzG) =
  ## Kleber float -> GZ-Puffer (Stufe 3 an, Stufe 2 aus): je Zeile bitgenau zerlegt (gzSetRowF), Zeile = Wert.
  for r in 0 ..< g.rows: gzSetRowF(g, r, cast[ptr FloatArray](addr src[r * g.cols]))

# --- Zustand des Pfads ----------------------------------------------------------------------------------
type GzLayer = object
  h1, n1, q, ao, h2, n2: GzT      # act x dim: Rest vor Att-Norm, Att-Norm, q nach RoPE, Att-Ausgang, Rest vor FFN-Norm, FFN-Norm
  u, s: GzT                       # act x ffn: FFN vor SiLU (aus int8 je Position), nach SiLU
  p: GzT                          # (heads*act) x act: Attention-Gewichte, Zeile = h*act + Position
  k8, v8: QMatrix                 # int8 je Position mit Skala (wie k_cache_q8/v_cache_q8)
  ksM, vsM: seq[int64]            # Stufe 6: Skala max/127 je Position als Mantisse ...
  ksE, vsE: seq[int]              # ... und Exponent

type GzSt = object
  owner: pointer
  ctx, dim, ffn, vocab, layers, heads: int
  x, hf, nf, lg, dx, dt, tmp: GzT  # Rest, Rest vor Final-Norm, Final-Norm, Logits/Wahrsch./dLogits, Gradient im Rest, Scratch
  dffn: GzT
  ly: seq[GzLayer]
  f1, f2, f3, f4: seq[cfloat]     # float-Scratch der Referenzbausteine
  qs8: seq[int8]
  qsc: seq[cfloat]
  gEmb: GzG                      # Gradient der gebundenen Embedding-Matrix (Logits + Lookup)
  gGain: seq[GzT]                # Stufe >= 4: Gain-Gradienten (1 x dim) in der Reihenfolge gzGainListe
  gLook: GzG                     # Stufe 8: Lookup-Anteil des Embedding-Gradienten (vocab x dim)
  gq, gk, gv, go, gup, gdown: seq[GzG]

var gz: GzSt

proc gzQAlloc(rows, cols: int): QMatrix =
  result.rows = rows.cint
  result.cols = cols.cint
  result.data = cast[ptr Int8Array](allocShared0(max(1, rows * cols)))
  result.scale = cast[ptr FloatArray](allocShared0(max(1, rows) * sizeof(cfloat)))

proc gzPruefe(state: ptr CortexState) =
  ## Nur das unterstuetzte Rezept; alles andere bricht laut ab, statt still anders zu rechnen.
  var warum = ""
  if state.weightDtype != 1: warum = "kein INT8"
  elif state.tiedEmbeddings == 0: warum = "Embeddings nicht gebunden"
  elif state.loraRank != 0: warum = "LoRA"
  elif state.trainLastLayers != 0: warum = "trainLastLayers"
  elif state.baseOptFreed != 0: warum = "Basis-Optimierer freigegeben"
  elif gpu_initialized and gpu_backend != gbNone: warum = "GPU aktiv (GZ nur CPU)"
  elif global_dropout_rate > 0.0: warum = "Dropout"
  elif growth_old_dim >= 0: warum = "Wachstum"
  elif state.quantAdam == 0: warum = "Momente nicht 8 Bit (SNAI_INT8_FULL=1 noetig)"
  elif state.quantActs == 0 or state.quantActsIn == 0: warum = "FFN-Aktivierungen nicht int8 (SNAI_INT8_FULL=1 noetig)"
  else:
    for l in 0 ..< state.numLayers.int:
      if ffnAusL(state, l): warum = "FFN-Skip in Schicht " & $l
  if warum != "":
    stderr.writeLine("[GZ] FEHLER: Ganzzahl-Pfad unterstuetzt dieses Rezept nicht: ", warum, " - Abbruch")
    quit(4)

# Stufe 12 (GFREI, 2026-11-16, Entscheidung des Autors "Nur bei Bedarf anlegen"): die float32-
# Gradientenpuffer der Matrizen (g_embeddings, g_w_out, g_w_q ... g_w_down, 4 Byte je Gewicht) liest und schreibt der
# Trainingsschritt mit den Stufen 2 (MATMUL), 3 (ADAM) und 8 (REST) nicht mehr - die Gradienten liegen ganzzahlig in
# GzG. Mit Schalter werden sie dann beim Laden (cortex_load_stream_i8) nicht angelegt und nach dem Quantisieren der
# Genesis im ersten Schritt freigegeben (gzInit). Sie bleiben, wenn eine der drei Stufen aus ist, die Karte laeuft oder
# ein Pruefwerkzeug den float-Weg daneben rechnet (SNAI_GZ_VERGL, SNAI_GZ_ADAMVGL, SNAI_GZ_RESTVGL), jeweils mit Warnung.
# Die Gain-Gradienten (d floats je Gain) bleiben, Stufe 3 nutzt sie.
var gzGFreiW = -1
proc gzGFrei(): bool =
  if gzGFreiW < 0:
    gzGFreiW = 0
    if gzAn(12):
      var grund = ""
      if gpu_initialized: grund = "Karte aktiv"
      for v in ["SNAI_GZ_VERGL", "SNAI_GZ_ADAMVGL", "SNAI_GZ_RESTVGL"]:
        if grund == "" and getEnv(v) == "1": grund = v & " rechnet den float-Weg daneben"
      if grund == "": gzGFreiW = 1
      else: stderr.writeLine("  > [GZ] WARNUNG: Stufe 12 (GFREI) aus (", grund, ") - Gradientenpuffer bleiben")
  gzGFreiW == 1

proc gzGFreigeben(s: ptr CortexState) =
  ## Stufe 12: Matrix-Gradientenpuffer freigeben (Genesis-Weg) bzw. melden, dass der Lader sie nicht angelegt hat.
  var frei, fehlt = 0'i64
  template f(m: var Matrix) =
    if m.data.isNil: fehlt += m.rows.int64 * m.cols.int64
    else:
      frei += m.rows.int64 * m.cols.int64
      freeMatrix(m)
  f(s.g_embeddings)
  f(s.g_w_out)
  for l in 0 ..< s.numLayers.int:
    f(s.g_w_q[l]); f(s.g_w_k[l]); f(s.g_w_v[l]); f(s.g_w_o[l]); f(s.g_w_up[l]); f(s.g_w_down[l])
  stderr.writeLine("  > [GZ] Stufe 12: float-Gradientenpuffer der Matrizen ",
                   (if frei > 0: "freigegeben " & $(frei * 4) & " Bytes" else: "nicht angelegt " & $(fehlt * 4) & " Bytes"))

proc gzInit(state: ptr CortexState) =
  if gz.owner == cast[pointer](state): return
  gzPruefe(state)
  gz.owner = cast[pointer](state)
  gz.ctx = state.ctxSize.int
  gz.dim = state.hiddenDim.int
  gz.ffn = state.ffnDim.int
  gz.vocab = state.vocabSize.int
  gz.layers = state.numLayers.int
  gz.heads = state.numHeads.int
  let c = gz.ctx
  let d = gz.dim
  gz.x = gzAlloc(c, d); gz.hf = gzAlloc(c, d); gz.nf = gzAlloc(c, d)
  gz.lg = gzAlloc(c, gz.vocab); gz.dx = gzAlloc(c, d); gz.dt = gzAlloc(c, d); gz.tmp = gzAlloc(c, d)
  gz.dffn = gzAlloc(c, gz.ffn)
  gz.ly = newSeq[GzLayer](gz.layers)
  for l in 0 ..< gz.layers:
    gz.ly[l].h1 = gzAlloc(c, d); gz.ly[l].n1 = gzAlloc(c, d); gz.ly[l].q = gzAlloc(c, d)
    gz.ly[l].ao = gzAlloc(c, d); gz.ly[l].h2 = gzAlloc(c, d); gz.ly[l].n2 = gzAlloc(c, d)
    gz.ly[l].u = gzAlloc(c, gz.ffn); gz.ly[l].s = gzAlloc(c, gz.ffn)
    gz.ly[l].p = gzAlloc(gz.heads * c, c)
    gz.ly[l].k8 = gzQAlloc(c, d); gz.ly[l].v8 = gzQAlloc(c, d)
    gz.ly[l].ksM = newSeq[int64](c); gz.ly[l].vsM = newSeq[int64](c)
    gz.ly[l].ksE = newSeq[int](c); gz.ly[l].vsE = newSeq[int](c)
  let big = c * max(max(d, gz.ffn), gz.vocab)
  gz.f1 = newSeq[cfloat](big); gz.f2 = newSeq[cfloat](big); gz.f3 = newSeq[cfloat](big); gz.f4 = newSeq[cfloat](big)
  gz.qs8 = newSeq[int8](big); gz.qsc = newSeq[cfloat](c)
  gz.gEmb = gzAlloc(gz.vocab, d)
  gz.gLook = gzAlloc(gz.vocab, d)
  for k in 0 ..< 2 * gz.layers + 1: gz.gGain.add(gzAlloc(1, d))
  for l in 0 ..< gz.layers:
    gz.gq.add(gzAlloc(d, d)); gz.gk.add(gzAlloc(d, d)); gz.gv.add(gzAlloc(d, d)); gz.go.add(gzAlloc(d, d))
    gz.gup.add(gzAlloc(gz.ffn, d)); gz.gdown.add(gzAlloc(d, gz.ffn))
  if gzGFrei(): gzGFreigeben(state)

template gzF(s: seq[cfloat]): ptr FloatArray = cast[ptr FloatArray](unsafeAddr s[0])

# --- Bausteine (Referenz = Rechnung des alten Pfads in float32) --------------------------------------------

proc gzCopy(dst, src: GzT, rows: int) =
  copyMem(dst.m, src.m, rows * src.cols * sizeof(int32))
  copyMem(dst.e, src.e, rows * sizeof(int32))

proc gzEmbFwdRef(state: ptr CortexState, t_in: ptr IntArray, act: int, x: GzT) =
  let d = gz.dim
  let f = gzF(gz.f1)
  for p in 0 ..< act:
    var tid = t_in[p]
    if tid < 0 or tid >= gz.vocab: tid = 0
    for k in 0 ..< d:
      f[p * d + k] = state.embeddings_q8.data[tid * d + k].cfloat * state.embeddings_q8.scale[tid] * embFak(state)
  gzFromF(x, act, f)

proc gzNormFwdRef(x, n: GzT, w: ptr FloatArray, act: int) =
  let d = x.cols
  let fi = gzF(gz.f1)
  let fo = gzF(gz.f2)
  gzToF(x, act, fi)
  for p in 0 ..< act:
    applyRMSNorm(cast[ptr FloatArray](addr fi[p * d]), cast[ptr FloatArray](addr fo[p * d]), d.cint, w)
  gzFromF(n, act, fo)

proc gzNormBwRef(dn, xin: GzT, w, gw: ptr FloatArray, act: int, dx: GzT, addiere: bool) =
  ## dx (+)= RMSNorm-Rueckwaerts von dn an der Stelle xin; Gain-Gradient nach gw (float, alter Puffer).
  let d = xin.cols
  let fd = gzF(gz.f1)
  let fx = gzF(gz.f2)
  let fa = gzF(gz.f3)
  gzToF(dn, act, fd)
  gzToF(xin, act, fx)
  if addiere: gzToF(dx, act, fa)
  for p in 0 ..< act:
    let dp = cast[ptr FloatArray](addr fd[p * d])
    applyRMSNormBackwardAcc(dp, cast[ptr FloatArray](addr fx[p * d]), d.cint, w, gw)
    for k in 0 ..< d:
      fa[p * d + k] = (if addiere: fa[p * d + k] + dp[k] else: dp[k])
  gzFromF(dx, act, fa)

proc gzFeset(m: cint): cint {.importc: "fesetround", header: "<fenv.h>".}
proc gzFeget(): cint {.importc: "fegetround", header: "<fenv.h>".}
var gzFeAuf {.importc: "FE_UPWARD", header: "<fenv.h>".}: cint
var gzFeNaechster {.importc: "FE_TONEAREST", header: "<fenv.h>".}: cint
var gzFeAb {.importc: "FE_DOWNWARD", header: "<fenv.h>".}: cint
var gzFeNull {.importc: "FE_TOWARDZERO", header: "<fenv.h>".}: cint
var gzKernAktiv = false      # Bausteinprobe (SNAI_GZ_KERN=1): erster Schritt, jeder Ganzzahl-Baustein zweimal
var gzKernRot = false        # SNAI_GZ_KERN_ROT=1: eine float-Rundung in gzMatFwdInt (Rot-Probe der Bausteinprobe)
var gzKernMeld: seq[string]
var gzKernFertig = false

proc gzWScale(qm: QMatrix, wm: var seq[int64], we: var seq[int32]): int =
  ## Zeilenskalen der Gewichte zerlegt; Rueckgabe: groesster Exponent (low(int32), wenn alle 0).
  let R = qm.rows.int
  wm.setLen(R); we.setLen(R)
  result = low(int32).int
  for r in 0 ..< R:
    let s = gzMulF(qm.scale[r])
    wm[r] = s.m
    we[r] = s.e
    if s.m != 0 and s.e.int > result: result = s.e.int

proc gzMatFwdInt(qm: QMatrix, x, y: GzT, act: int) =
  ## y = W . x je Position, ganzzahlig: Eingang je Position auf int8 (Skala max/127 wie bisher), int32-Summen,
  ## Gewichtsskala als 24-Bit-Mantisse.
  let R = qm.rows.int
  let C = qm.cols.int
  var wm: seq[int64]
  var we: seq[int32]
  let E = gzWScale(qm, wm, we)
  var qx = newSeq[int8](C)
  let tb = gzI64P(gzI64, R)
  for p in 0 ..< act:
    var mx = 0'i64
    for c in 0 ..< C:
      let a = abs(x.m[p * C + c].int64)
      if a > mx: mx = a
    if mx == 0 or E == low(int32).int:
      for r in 0 ..< R: y.m[p * R + r] = 0
      y.e[p] = 0
      continue
    for c in 0 ..< C:
      var q = gzDivR(x.m[p * C + c].int64 * 127, mx)
      if q > 127: q = 127
      elif q < -128: q = -128
      qx[c] = q.int8
    var tmx = 0'u64
    for r in 0 ..< R:
      var acc = 0'i64
      let wo = r * C
      for c in 0 ..< C: acc += qx[c].int64 * qm.data[wo + c].int64
      let v = (if wm[r] == 0: 0'i64 else: gzShr(acc * wm[r], E - we[r].int))
      tb[r] = v
      let a = gzAbsU(v)
      if a > tmx: tmx = a
    let sh1 = max(0, gzBits(tmx) - 30)
    for r in 0 ..< R: tb[r] = gzDivR(gzShr(tb[r], sh1) * mx, 127)
    if gzKernRot: tb[0] = (tb[0].float32 * 1.0000001'f32).int64
    gzPutRow(y, p, tb, R, x.e[p].int + E + sh1)

proc gzMatBwInt(qm: QMatrix, g: GzG, dy, x, dx: GzT, act: int, addiere: bool) =
  ## dx (+)= W^T . dy (dy*Skala je 64er-Block auf int8, wie bisher) und g += dy (x) x (dy je Zeile ueber die
  ## Positionen, x je Spalte ueber die Positionen auf int8, int32-Summen) - ganzzahlig.
  let R = qm.rows.int
  let C = qm.cols.int
  var wm: seq[int64]
  var we: seq[int32]
  let E = gzWScale(qm, wm, we)
  # --- d_in ---
  let nb = (R + 63) div 64
  var t = newSeq[int64](R)
  var q = newSeq[int8](R)
  var bm = newSeq[GzMul](nb)
  let v = gzI64P(gzI64, C)
  for p in 0 ..< act:
    for r in 0 ..< R:
      t[r] = (if wm[r] == 0 or E == low(int32).int: 0'i64 else: gzShr(dy.m[p * R + r].int64 * wm[r], E - we[r].int))
    var emax = low(int32).int
    for b in 0 ..< nb:
      var mb = 0'i64
      for r in b * 64 ..< min(R, b * 64 + 64):
        let a = abs(t[r])
        if a > mb: mb = a
      if mb == 0:
        bm[b] = GzMul(m: 0, e: 0)
        for r in b * 64 ..< min(R, b * 64 + 64): q[r] = 0
        continue
      for r in b * 64 ..< min(R, b * 64 + 64):
        var qq = gzDivR(t[r] * 127, mb)
        if qq > 127: qq = 127
        elif qq < -128: qq = -128
        q[r] = qq.int8
      bm[b] = gzMulAus(mb, dy.e[p].int + E, true)
      if bm[b].e.int > emax: emax = bm[b].e.int
    for c in 0 ..< C: v[c] = 0
    if emax != low(int32).int:
      for b in 0 ..< nb:
        if bm[b].m == 0: continue
        let sh = emax - bm[b].e.int
        for c in 0 ..< C:
          var acc = 0'i64
          for r in b * 64 ..< min(R, b * 64 + 64): acc += q[r].int64 * qm.data[r * C + c].int64
          v[c] += gzShr(acc * bm[b].m, sh)
    if emax == low(int32).int: emax = 0
    if addiere: gzAddRow(dx, p, v, C, emax)
    else: gzPutRow(dx, p, v, C, emax)
  # --- Gradient ---
  var ex = low(int32).int
  var ed = low(int32).int
  for p in 0 ..< act:
    if not gzRowNull(x, p) and x.e[p].int > ex: ex = x.e[p].int
    if not gzRowNull(dy, p) and dy.e[p].int > ed: ed = dy.e[p].int
  if ex == low(int32).int or ed == low(int32).int: return
  var xa = newSeq[int64](act * C)
  var da = newSeq[int64](act * R)
  for p in 0 ..< act:
    for c in 0 ..< C: xa[p * C + c] = gzShr(x.m[p * C + c].int64, ex - 24 - x.e[p].int)
    for r in 0 ..< R: da[p * R + r] = gzShr(dy.m[p * R + r].int64, ed - 24 - dy.e[p].int)
  var qx = newSeq[int8](act * C)
  var isc = newSeq[GzMul](C)
  var ec = low(int32).int
  for c in 0 ..< C:
    var mc = 0'i64
    for p in 0 ..< act:
      let a = abs(xa[p * C + c])
      if a > mc: mc = a
    if mc == 0:
      isc[c] = GzMul(m: 0, e: 0)
      for p in 0 ..< act: qx[p * C + c] = 0
      continue
    for p in 0 ..< act:
      var qq = gzDivR(xa[p * C + c] * 127, mc)
      if qq > 127: qq = 127
      elif qq < -128: qq = -128
      qx[p * C + c] = qq.int8
    isc[c] = gzMulAus(mc, ex - 24, true)
    if isc[c].e.int > ec: ec = isc[c].e.int
  if ec == low(int32).int: return
  var qd = newSeq[int8](act)
  let u = gzI64P(gzI64, C)
  for r in 0 ..< R:
    var md = 0'i64
    for p in 0 ..< act:
      let a = abs(da[p * R + r])
      if a > md: md = a
    if md == 0: continue
    for p in 0 ..< act:
      var qq = gzDivR(da[p * R + r] * 127, md)
      if qq > 127: qq = 127
      elif qq < -128: qq = -128
      qd[p] = qq.int8
    let ds = gzMulAus(md, ed - 24, true)
    var tmx = 0'u64
    for c in 0 ..< C:
      if isc[c].m == 0:
        u[c] = 0
        continue
      var acc = 0'i64
      for p in 0 ..< act: acc += qd[p].int64 * qx[p * C + c].int64
      u[c] = gzShr(acc * isc[c].m, ec - isc[c].e.int)
      let a = gzAbsU(u[c])
      if a > tmx: tmx = a
    let sh = max(0, gzBits(tmx) - 38)
    for c in 0 ..< C: u[c] = gzShr(u[c], sh) * ds.m
    gzAddRow(g, r, u, C, ec + sh + ds.e.int)

proc gzKernVgl(name: string, a, b: GzT, rows: int) =
  var n = 0
  for i in 0 ..< rows * a.cols:
    if a.m[i] != b.m[i]: inc n
  for i in 0 ..< rows:
    if a.e[i] != b.e[i]: inc n
  gzKernMeld.add(name & (if n == 0: " gleich" else: " ABWEICHEND (" & $n & ")"))

proc gzSnap(t: GzT, rows: int): GzT =
  result = gzAlloc(rows, t.cols)
  copyMem(result.m, t.m, rows * t.cols * sizeof(int32))
  copyMem(result.e, t.e, rows * sizeof(int32))
proc gzFrei(t: GzT) =
  deallocShared(t.m); deallocShared(t.e)

proc gzMatFwdRef(qm: QMatrix, x, y: GzT, act: int)
proc gzMatFwd(qm: QMatrix, x, y: GzT, act: int) =
  if gzAn(2):
    if gzKernAktiv:
      discard gzFeset(gzFeAuf)
      gzMatFwdInt(qm, x, y, act)
      discard gzFeset(gzFeNaechster)
      let s = gzSnap(y, act)
      gzMatFwdInt(qm, x, y, act)
      gzKernVgl("matfwd " & $qm.rows & "x" & $qm.cols, s, y, act)
      gzFrei(s)
    else: gzMatFwdInt(qm, x, y, act)
    return
  gzMatFwdRef(qm, x, y, act)

proc gzMatFwdRef(qm: QMatrix, x, y: GzT, act: int) =
  ## y = W . x je Position (alter matMulBatchedI8: Eingang je Position int8 quantisiert).
  let fi = gzF(gz.f1)
  let fo = gzF(gz.f2)
  gzToF(x, act, fi)
  matMulBatchedI8(qm, fi, fo, cast[ptr Int8Array](unsafeAddr gz.qs8[0]), gzF(gz.qsc), act.cint)
  gzFromF(y, act, fo)

proc gzMatBwRef(state: ptr CortexState, qm: QMatrix, g: Matrix, dy, x, dx: GzT, act: int, addiere: bool) =
  ## dx (+)= W^T . dy; Gradient g += dy (x) x (alter matMulTBatchedI8 / gradAccumBatchedI8).
  let fdy = gzF(gz.f1)
  let fx = gzF(gz.f2)
  let fdx = gzF(gz.f3)
  gzToF(dy, act, fdy)
  gzToF(x, act, fx)
  if addiere: gzToF(dx, act, fdx)
  matMulTBatchedI8(qm, fdy, fdx, act.cint, addiere, state)
  gradAccumBatchedI8(qm, g, fdy, fx, act.cint, state)
  gzFromF(dx, act, fdx)

proc gzMatBw(state: ptr CortexState, qm: QMatrix, g: Matrix, gi: GzG, dy, x, dx: GzT, act: int, addiere: bool) =
  ## Verteiler: Stufe 2 an => ganzzahlig in den GZ-Gradientenpuffer gi, sonst Referenz in den float-Puffer g.
  if gzAn(2):
    if gzKernAktiv:
      let dx0 = gzSnap(dx, act)
      let g0 = gzSnap(gi, gi.rows)
      discard gzFeset(gzFeAuf)
      gzMatBwInt(qm, gi, dy, x, dx, act, addiere)
      discard gzFeset(gzFeNaechster)
      let dx1 = gzSnap(dx, act)
      let g1 = gzSnap(gi, gi.rows)
      gzCopy(dx, dx0, act)
      gzCopy(gi, g0, gi.rows)
      gzMatBwInt(qm, gi, dy, x, dx, act, addiere)
      gzKernVgl("matbw-din " & $qm.rows & "x" & $qm.cols, dx1, dx, act)
      gzKernVgl("matbw-grad " & $qm.rows & "x" & $qm.cols, g1, gi, gi.rows)
      for s in [dx0, g0, dx1, g1]: gzFrei(s)
    else: gzMatBwInt(qm, gi, dy, x, dx, act, addiere)
    return
  gzMatBwRef(state, qm, g, dy, x, dx, act, addiere)

# --- Stufe 4: RMSNorm ganzzahlig -----------------------------------------------------------------------------
# Wie applyRMSNorm / applyRMSNormBackwardAcc: inv = 1/sqrt(mean(x^2) + 1e-5), out = x*inv*w;
# rueckwaerts nx = x*inv, mean = sum(dy*w*nx)/d, gw += dy*nx, dx = (dy*w - nx*mean)*inv. Gains auf ihrem
# Tensor-Raster (Stufe 3), eps = float32 1e-5 bitweise zerlegt.
proc gzGainLies(w: ptr FloatArray, d: int, wi: var seq[int64]): int =
  ## Gains als Ganzzahlen mit Tensor-Exponent (exakt, sobald der Tensor auf seinem Raster liegt). Rueckgabe Exponent.
  wi.setLen(d)
  var et = low(int)
  for c in 0 ..< d:
    let x = gzMulF(w[c])
    if x.m != 0 and x.e.int > et: et = x.e.int
  if et == low(int):
    for c in 0 ..< d: wi[c] = 0
    return 0
  for c in 0 ..< d:
    let x = gzMulF(w[c])
    wi[c] = gzShr(x.m, et - x.e.int)
  et

proc gzInvRms(x: GzT, p: int, iM: var int64, iE: var int) =
  ## 1/sqrt(mean(x^2) + eps) der Zeile p als iM * 2^iE, iM in [2^30, 2^32].
  let d = x.cols
  let off = p * d
  var acc: GzAkk
  var mx = 0'u64
  for c in 0 ..< d:
    let v = gzAbsU(x.m[off + c].int64)
    if v > mx: mx = v
  if mx != 0'u64:
    var s = max(0, gzBits(mx) - 24)
    while 2 * (gzBits(mx) - s) + gzBits(uint64(d)) > 62: inc s
    var ss = 0'u64
    for c in 0 ..< d:
      let v = gzShr(x.m[off + c].int64, s)
      ss += uint64(v * v)
    var se = 2 * (x.e[p].int + s)
    if gzBits(ss) > 61:
      ss = uint64(gzShr(int64(ss), 1))
      inc se
    let k = 61 - gzBits(ss)
    gzAkkAdd(acc, (ss shl k) div uint64(d), se - k)
  let eps = gzMulF(1.0e-5'f32)
  gzAkkAdd(acc, uint64(eps.m), eps.e.int)
  var m = acc.m
  var e = acc.e
  if (e and 1) != 0:
    m = m shl 1
    dec e
  let r = gzIsqrt(m)
  iM = int64((1'u64 shl 62) div r)
  iE = -62 - e div 2

proc gzNormFwdInt(x, n: GzT, w: ptr FloatArray, act: int) =
  let d = x.cols
  var wi: seq[int64]
  let ew = gzGainLies(w, d, wi)
  let tb = gzI64P(gzI64, d)
  for p in 0 ..< act:
    var iM: int64
    var iE: int
    gzInvRms(x, p, iM, iE)
    for c in 0 ..< d: tb[c] = gzShr(x.m[p * d + c].int64 * iM, 32) * wi[c]
    if gzKernRot: tb[0] = (tb[0].float32 * 1.0000001'f32).int64
    gzPutRow(n, p, tb, d, x.e[p].int + iE + 32 + ew)

proc gzNormBwInt(dn, xin: GzT, w: ptr FloatArray, gG: GzT, act: int, dx: GzT, addiere: bool) =
  ## dx (+)= RMSNorm-Rueckwaerts; Gain-Gradient gG (1 x d) += dy*nx, alles ganzzahlig.
  let d = xin.cols
  var wi: seq[int64]
  let ew = gzGainLies(w, d, wi)
  var nx = newSeq[int64](d)
  var dw = newSeq[int64](d)
  let tb = gzI64P(gzI64, d)
  let B = (62 - gzBits(uint64(d))) div 2
  for p in 0 ..< act:
    let off = p * d
    if gzRowNull(dn, p):
      if not addiere:
        for c in 0 ..< d: dx.m[off + c] = 0
        dx.e[p] = 0
      continue
    var iM: int64
    var iE: int
    gzInvRms(xin, p, iM, iE)
    let enx = xin.e[p].int + iE + 30
    let edw = dn.e[p].int + ew
    var mxn, mxd = 0'u64
    for c in 0 ..< d:
      nx[c] = gzShr(xin.m[off + c].int64 * iM, 30)
      dw[c] = dn.m[off + c].int64 * wi[c]
      mxn = max(mxn, gzAbsU(nx[c]))
      mxd = max(mxd, gzAbsU(dw[c]))
    # mean = sum(dy*w*nx)/d
    let shd = max(0, gzBits(mxd) - B)
    let shn = max(0, gzBits(mxn) - B)
    var sum = 0'i64
    for c in 0 ..< d: sum += gzShr(dw[c], shd) * gzShr(nx[c], shn)
    let es = edw + shd + enx + shn
    let mean = gzDivR(sum, d.int64)
    let shm = max(0, gzBits(gzAbsU(mean)) - 29)
    let m29 = gzShr(mean, shm)
    let e2 = enx + es + shm
    # dx = (dy*w - nx*mean)*inv, gemeinsamer Exponent Ec
    var top2 = low(int)
    if m29 != 0 and mxn != 0'u64: top2 = e2 + gzBits(mxn) + gzBits(gzAbsU(m29))
    let top1 = (if mxd != 0'u64: edw + gzBits(mxd) else: low(int))
    if top1 == low(int) and top2 == low(int):
      if not addiere:
        for c in 0 ..< d: dx.m[off + c] = 0
        dx.e[p] = 0
      continue
    let Ec = max(top1, top2) - 61
    var mxf = 0'u64
    for c in 0 ..< d:
      var v = 0'i64
      if mxd != 0'u64: v = gzShr(dw[c], Ec - edw)
      if top2 != low(int): v -= gzShr(nx[c] * m29, Ec - e2)
      tb[c] = v
      mxf = max(mxf, gzAbsU(v))
    let shf = max(0, gzBits(mxf) - 30)
    for c in 0 ..< d: tb[c] = gzShr(tb[c], shf) * iM
    if gzKernRot: tb[0] = (tb[0].float32 * 1.0000001'f32).int64
    if addiere: gzAddRow(dx, p, tb, d, Ec + shf + iE)
    else: gzPutRow(dx, p, tb, d, Ec + shf + iE)
    # Gain-Gradient
    for c in 0 ..< d: tb[c] = dn.m[off + c].int64 * nx[c]
    gzAddRow(gG, 0, tb, d, dn.e[p].int + enx)

# Pruefwerkzeug SNAI_GZ_NORMVGL=<t> (Schritt t, 1 = erster Schritt): Ganzzahl und alte float32-Fassung gegen float64 bei GLEICHEM
# Eingang (Lesart B, Entscheidung des Autors 15.11.). SNAI_GZ_NORMVGL_ROT=1: float64-Referenz um genau 1e-5 relativ
# verschoben (inv * (1 + 1e-5)); jede Groesse muss dann relL2 ~1e-5 zeigen.
var gzNormVglAktiv = false
var gzNormVglMeld: seq[string]
proc gzF64(t: GzT, p, c: int): float64 {.inline.} = t.m[p * t.cols + c].float64 * pow(2.0, t.e[p].float64)
proc gzRelL2(a, b: seq[float64]): float64 =
  var nd, nb: float64
  for i in 0 ..< a.len:
    nd += (a[i] - b[i]) * (a[i] - b[i])
    nb += b[i] * b[i]
  (if nb > 0: sqrt(nd / nb) else: 0.0)
proc gzNormRef64(xin: GzT, p: int, w: ptr FloatArray, epsF: float64): float64 =
  var ss = 0.0
  for c in 0 ..< xin.cols: ss += gzF64(xin, p, c) * gzF64(xin, p, c)
  (1.0 / sqrt(ss / xin.cols.float64 + epsF)) * (if getEnv("SNAI_GZ_NORMVGL_ROT") == "1": 1.0 + 1.0e-5 else: 1.0)

proc gzNormFwd(x, n: GzT, w: ptr FloatArray, act: int) =
  if not gzAn(4):
    gzNormFwdRef(x, n, w, act)
    return
  if gzNormVglAktiv:
    let d = x.cols
    let epsF = 1.0e-5'f32.float64
    var r64, ri, rf: seq[float64]
    let tn = gzAlloc(act, d)
    gzNormFwdInt(x, tn, w, act)
    for p in 0 ..< act:
      let inv = gzNormRef64(x, p, w, epsF)
      for c in 0 ..< d:
        r64.add(gzF64(x, p, c) * inv * w[c].float64)
        ri.add(gzF64(tn, p, c))
    gzNormFwdRef(x, tn, w, act)
    for p in 0 ..< act:
      for c in 0 ..< d: rf.add(gzF64(tn, p, c))
    gzFrei(tn)
    gzNormVglMeld.add("fwd int " & $gzRelL2(ri, r64) & " f32 " & $gzRelL2(rf, r64))
  if gzKernAktiv:
    discard gzFeset(gzFeAuf)
    gzNormFwdInt(x, n, w, act)
    discard gzFeset(gzFeNaechster)
    let s = gzSnap(n, act)
    gzNormFwdInt(x, n, w, act)
    gzKernVgl("normfwd", s, n, act)
    gzFrei(s)
  else: gzNormFwdInt(x, n, w, act)

proc gzNormBw(dn, xin: GzT, w, gw: ptr FloatArray, k, act: int, dx: GzT, addiere: bool) =
  ## Verteiler: ab Stufe 4 ganzzahlig mit Gain-Gradient in gz.gGain[k], sonst Referenz in den float-Puffer gw.
  if not gzAn(4):
    gzNormBwRef(dn, xin, w, gw, act, dx, addiere)
    return
  let gG = gz.gGain[k]
  if gzNormVglAktiv:
    let d = xin.cols
    let epsF = 1.0e-5'f32.float64
    var dx64, g64, dxi, gi, dxf, gf: seq[float64]
    var gacc = newSeq[float64](d)
    for p in 0 ..< act:
      let inv = gzNormRef64(xin, p, w, epsF)
      var sm = 0.0
      for c in 0 ..< d: sm += gzF64(dn, p, c) * w[c].float64 * gzF64(xin, p, c) * inv
      let mean = sm / d.float64
      for c in 0 ..< d:
        let nxv = gzF64(xin, p, c) * inv
        gacc[c] += gzF64(dn, p, c) * nxv
        dx64.add((gzF64(dn, p, c) * w[c].float64 - nxv * mean) * inv)
    g64 = gacc
    let tdx = gzAlloc(act, d)
    let tg = gzAlloc(1, d)
    gzNormBwInt(dn, xin, w, tg, act, tdx, false)
    for p in 0 ..< act:
      for c in 0 ..< d: dxi.add(gzF64(tdx, p, c))
    for c in 0 ..< d: gi.add(gzF64(tg, 0, c))
    var fgw = newSeq[cfloat](d)
    gzNormBwRef(dn, xin, w, cast[ptr FloatArray](addr fgw[0]), act, tdx, false)
    for p in 0 ..< act:
      for c in 0 ..< d: dxf.add(gzF64(tdx, p, c))
    for c in 0 ..< d: gf.add(fgw[c].float64)
    gzFrei(tdx); gzFrei(tg)
    gzNormVglMeld.add("bw-dx int " & $gzRelL2(dxi, dx64) & " f32 " & $gzRelL2(dxf, dx64) &
                      " | bw-gain int " & $gzRelL2(gi, g64) & " f32 " & $gzRelL2(gf, g64))
  if gzKernAktiv:
    let dx0 = gzSnap(dx, act)
    let g0 = gzSnap(gG, 1)
    discard gzFeset(gzFeAuf)
    gzNormBwInt(dn, xin, w, gG, act, dx, addiere)
    discard gzFeset(gzFeNaechster)
    let dx1 = gzSnap(dx, act)
    let g1 = gzSnap(gG, 1)
    gzCopy(dx, dx0, act)
    gzCopy(gG, g0, 1)
    gzNormBwInt(dn, xin, w, gG, act, dx, addiere)
    gzKernVgl("normbw-dx", dx1, dx, act)
    gzKernVgl("normbw-gain", g1, gG, 1)
    for s in [dx0, g0, dx1, g1]: gzFrei(s)
  else: gzNormBwInt(dn, xin, w, gG, act, dx, addiere)

proc gzRopeRef(t: GzT, act: int, backward: bool, state: ptr CortexState) =
  ## Alter Weg: applyRoPE in float32 (cos/sin je Aufruf).
  let d = t.cols
  let f = gzF(gz.f4)
  gzToF(t, act, f)
  for p in 0 ..< act:
    applyRoPE(cast[ptr FloatArray](addr f[p * d]), d.cint, state.headSize, state.ctxSize, p.cint, backward)
  gzFromF(t, act, f)

# =============================================================================================================
# Stufe 5 (2026-11-15): RoPE ganzzahlig. cos/sin(pos * base^(-2j/hs)) als Q30-Tabelle (ctx x hs/2),
# einmal beim ersten Aufruf in float64 im Modus "naechster" berechnet (erlaubte Ausnahme a); base = ropeBase wie im
# alten Weg. Drehung je Paar: (v0 c - v1 s, v0 s + v1 c) in int64 (|v| < 2^30, |c|,|s| <= 2^30 => < 2^61),
# rueckwaerts mit -s; Zeile neu normiert mit Exponent e - 30.
# =============================================================================================================
var gzRopeC, gzRopeS: seq[int32]
var gzRopeHs, gzRopeCtx = 0
var gzKernRotTab = false     # SNAI_GZ_KERN_ROT=2: Tabelle ohne festen Modus und mit float32-theta (Rot der Tabellenprobe)
proc gzRopeTab(state: ptr CortexState) =
  let hs = state.headSize.int
  let ctx = state.ctxSize.int
  if gzRopeHs == hs and gzRopeCtx == ctx: return
  let alt = gzFeget()
  if not gzKernRotTab: discard gzFeset(gzFeNaechster)
  let h2 = hs div 2
  gzRopeC = newSeq[int32](ctx * h2)
  gzRopeS = newSeq[int32](ctx * h2)
  let base = ropeBase(state.headSize, state.ctxSize).float64
  for p in 0 ..< ctx:
    for j in 0 ..< h2:
      var th = p.float64 / pow(base, (2 * j).float64 / hs.float64)
      if gzKernRotTab: th = (p.float32 * (1.0'f32 / pow(base.float32, (2 * j).float32 / hs.float32))).float64
      gzRopeC[p * h2 + j] = round(cos(th) * 1073741824.0).int32
      gzRopeS[p * h2 + j] = round(sin(th) * 1073741824.0).int32
  discard gzFeset(alt)
  gzRopeHs = hs
  gzRopeCtx = ctx

proc gzRopeInt(t: GzT, act: int, backward: bool, state: ptr CortexState) =
  gzRopeTab(state)
  let d = t.cols
  let hs = gzRopeHs
  let h2 = hs div 2
  let nh = d div hs
  let tb = gzI64P(gzI64, d)
  for p in 0 ..< act:
    if gzRowNull(t, p): continue
    let off = p * d
    for h in 0 ..< nh:
      for j in 0 ..< h2:
        let i = h * hs + 2 * j
        let c = gzRopeC[p * h2 + j].int64
        let s = (if backward: -gzRopeS[p * h2 + j].int64 else: gzRopeS[p * h2 + j].int64)
        let v0 = t.m[off + i].int64
        let v1 = t.m[off + i + 1].int64
        tb[i] = v0 * c - v1 * s
        tb[i + 1] = v0 * s + v1 * c
    for c in nh * hs ..< d: tb[c] = t.m[off + c].int64 shl 30
    if gzKernRot: tb[0] = (tb[0].float32 * 1.0000001'f32).int64
    gzPutRow(t, p, tb, d, t.e[p].int - 30)

# Pruefwerkzeug SNAI_GZ_ROPEVGL=<t> (Schritt t): Ganzzahl und alte float32-Fassung gegen float64 (exakte Drehung, theta
# in float64) bei GLEICHEM Eingang. SNAI_GZ_ROPEVGL_ROT=1: float64-Referenz um genau 1e-5 relativ verschoben.
var gzRopeVglAktiv = false
var gzRopeVglMeld: seq[string]
proc gzRope(t: GzT, act: int, backward: bool, state: ptr CortexState) =
  if not gzAn(5):
    gzRopeRef(t, act, backward, state)
    return
  if gzRopeVglAktiv:
    let d = t.cols
    let hs = state.headSize.int
    let h2 = hs div 2
    let nh = d div hs
    let base = ropeBase(state.headSize, state.ctxSize).float64
    let fak = (if getEnv("SNAI_GZ_ROPEVGL_ROT") == "1": 1.0 + 1.0e-5 else: 1.0)
    let sg = (if backward: -1.0 else: 1.0)
    var r64, ri, rf: seq[float64]
    for p in 0 ..< act:
      for c in 0 ..< d:
        let h = c div hs
        if h >= nh:
          r64.add(gzF64(t, p, c) * fak)
          continue
        let j = (c - h * hs) div 2
        let th = p.float64 / pow(base, (2 * j).float64 / hs.float64)
        let i0 = h * hs + 2 * j
        let v0 = gzF64(t, p, i0)
        let v1 = gzF64(t, p, i0 + 1)
        if c == i0: r64.add((v0 * cos(th) - v1 * sg * sin(th)) * fak)
        else: r64.add((v0 * sg * sin(th) + v1 * cos(th)) * fak)
    let ti = gzSnap(t, act)
    gzRopeInt(ti, act, backward, state)
    let tf = gzSnap(t, act)
    gzRopeRef(tf, act, backward, state)
    for p in 0 ..< act:
      for c in 0 ..< d:
        ri.add(gzF64(ti, p, c))
        rf.add(gzF64(tf, p, c))
    gzFrei(ti); gzFrei(tf)
    gzRopeVglMeld.add((if backward: "bw" else: "fwd") & " int " & $gzRelL2(ri, r64) & " f32 " & $gzRelL2(rf, r64))
  if gzKernAktiv:
    # Tabelle in jedem der beiden Laeufe neu berechnet (gzRopeHs = 0), damit ein modusabhaengiger Tabellenbau auffiele.
    let s0 = gzSnap(t, act)
    discard gzFeset(gzFeAuf)
    gzRopeHs = 0
    gzRopeInt(t, act, backward, state)
    discard gzFeset(gzFeNaechster)
    let s1 = gzSnap(t, act)
    gzCopy(t, s0, act)
    gzRopeHs = 0
    gzRopeInt(t, act, backward, state)
    gzKernVgl((if backward: "rope-bw" else: "rope-fwd"), s1, t, act)
    gzFrei(s0); gzFrei(s1)
  else: gzRopeInt(t, act, backward, state)

proc gzQuantRows(t: GzT, act: int, q: QMatrix) =
  ## Zeilen je Position nach int8 (wie quantizeVectorToQ8Row: Skala max/127, Runden zum Naechsten).
  let d = t.cols
  let f = gzF(gz.f4)
  gzToF(t, act, f)
  for p in 0 ..< act:
    quantizeVectorToQ8Row(cast[ptr FloatArray](addr f[p * d]), q, p.cint, d.cint)

proc gzAttFwdRef(state: ptr CortexState, L: var GzLayer, act: int, ao: GzT) =
  ## Attention je Position und Kopf wie im alten seriellen Pfad: q je Position int8, K/V int8 je Position,
  ## Softmax float; die Gewichte bleiben in L.p fuer den Rueckwaerts.
  let d = gz.dim
  let hs = state.headSize.int
  let fq = gzF(gz.f1)
  let fo = gzF(gz.f2)
  let pr = gzF(gz.f3)
  gzToF(L.q, act, fq)
  let qs = cast[ptr Int8Array](unsafeAddr gz.qs8[0])
  for p in 0 ..< act:
    let qScale = quantizeActivation(cast[ptr FloatArray](addr fq[p * d]), cast[ptr Int8Array](addr qs[p * d]), d.cint)
    gz.qsc[p] = qScale
    for k in 0 ..< d: fo[p * d + k] = 0.0
    for h in 0 ..< gz.heads:
      let ho = h * hs
      var mx: cfloat = NegInf.cfloat
      let row = cast[ptr FloatArray](addr pr[0])
      for t in 0 .. p:
        var acc: int32 = 0
        for k in 0 ..< hs: acc += int32(qs[p * d + ho + k]) * int32(L.k8.data[t * d + ho + k])
        var sc = acc.cfloat * qScale * L.k8.scale[t]
        sc /= sqrt(hs.float32)
        row[t] = sc
        if sc > mx: mx = sc
      var se: cfloat = 0.0
      for t in 0 .. p:
        row[t] = exp(row[t] - mx)
        se += row[t]
      for t in 0 ..< L.p.cols: row[t] = (if t <= p: row[t] / se else: 0.0)
      gzSetRowF(L.p, h * act + p, row)
      for t in 0 .. p:
        let w = row[t]
        for k in 0 ..< hs:
          fo[p * d + ho + k] += (L.v8.data[t * d + ho + k].cfloat * L.v8.scale[t]) * w
  gzFromF(ao, act, fo)

proc gzAttBwRef(state: ptr CortexState, L: var GzLayer, act: int, dao: GzT, dq, dk, dv: GzT) =
  ## Rueckwaerts der Attention wie im alten seriellen Pfad (bwQ: q int8 wie vorwaerts), Gewichte aus L.p.
  let d = gz.dim
  let hs = state.headSize.int
  let fd = gzF(gz.f1)
  let fq = gzF(gz.f2)
  let pr = gzF(gz.f3)
  gzToF(dao, act, fd)
  gzToF(L.q, act, fq)
  var gQ = newSeq[cfloat](act * d)
  var gK = newSeq[cfloat](act * d)
  var gV = newSeq[cfloat](act * d)
  var dw = newSeq[cfloat](act)
  let qs = cast[ptr Int8Array](unsafeAddr gz.qs8[0])
  let attScale = 1.0'f32 / sqrt(hs.float32)
  for p in countdown(act - 1, 0):
    let qScale = quantizeActivation(cast[ptr FloatArray](addr fq[p * d]), cast[ptr Int8Array](addr qs[p * d]), d.cint)
    for h in 0 ..< gz.heads:
      let ho = h * hs
      gzRowToF(L.p, h * act + p, pr)
      var swd: cfloat = 0.0
      for t in 0 .. p:
        var s: cfloat = 0.0
        for k in 0 ..< hs: s += fd[p * d + ho + k] * (L.v8.data[t * d + ho + k].cfloat * L.v8.scale[t])
        dw[t] = s
        for k in 0 ..< hs: gV[t * d + ho + k] += fd[p * d + ho + k] * pr[t]
        swd += pr[t] * s
      for t in 0 .. p:
        let ds = pr[t] * (dw[t] - swd) * attScale
        for k in 0 ..< hs:
          gQ[p * d + ho + k] += ds * (L.k8.data[t * d + ho + k].cfloat * L.k8.scale[t])
          gK[t * d + ho + k] += ds * (qs[p * d + ho + k].cfloat * qScale)
  gzFromF(dq, act, cast[ptr FloatArray](addr gQ[0]))
  gzFromF(dk, act, cast[ptr FloatArray](addr gK[0]))
  gzFromF(dv, act, cast[ptr FloatArray](addr gV[0]))

# =============================================================================================================
# Stufe 6 (2026-11-15): Attention ganzzahlig (Schalter SNAI_I8_GZ_ATT, setzt nur das Geruest voraus).
# =============================================================================================================
# - q, k, v je Position nach int8 wie quantizeActivation/quantizeVectorToQ8Row: Code = round(m*127/max) (Halbe weg
#   von null), Skala max/127 als Mantisse < 2^31 mit Exponent (ksM/ksE, vsM/vsE, qsM/qsE).
# - Scores sc_t = acc_t * qS * kS_t / sqrt(hs); Softmax als 2^(-y), y = (sc_max - sc_t) * log2(e) in Q32;
#   2^(-f) per Tabelle (4096 Stuetzstellen, Q40, linear interpoliert; einmal in float64 im Modus "naechster",
#   Ausnahme a). Wahrscheinlichkeiten Q30. 1/sqrt(hs) = isqrt(2^60 div hs) in Q30, log2(e) als Q30-Konstante.
# - Ausgang/gQ je Zeile auf gemeinsamem Exponenten; gK, gV ueber Positionen in int64 auf einem festen Raster je
#   Tensor, vorab aus der Schranke sum_p |Beitrag| <= act * max|Beitrag| (Summen < 2^61).
const GZ_LOG2E_Q30 = 1549082005'i64        # round(log2(e) * 2^30)
var gzExp2T: array[4097, int64]            # 2^(-i/4096) in Q40
var gzExp2Fertig = false
var gzKernRotExp = false                   # SNAI_GZ_KERN_ROT=2: Tabelle ohne festen Modus aus float32 (Rot der Tabellenprobe)
proc gzZuF32(m: int64, e: int): cfloat
proc gzExp2Tab() =
  if gzExp2Fertig: return
  let alt = gzFeget()
  if not gzKernRotExp: discard gzFeset(gzFeNaechster)
  for i in 0 .. 4096:
    if gzKernRotExp: gzExp2T[i] = (pow(2.0'f32, -i.float32 / 4096.0'f32) * 1099511627776.0'f32).int64
    else: gzExp2T[i] = round(pow(2.0, -i.float64 / 4096.0) * 1099511627776.0).int64
  discard gzFeset(alt)
  gzExp2Fertig = true

proc gzExp2Neg(y: int64): int64 {.inline.} =
  ## 2^(-y / 2^32) in Q40 fuer y >= 0.
  let n = y shr 32
  if n >= 41: return 0
  let f = y and 0xFFFFFFFF'i64
  let i = int(f shr 20)
  let r = f and 0xFFFFF'i64
  let a = gzExp2T[i]
  let b = gzExp2T[i + 1]
  gzShr(a - gzShr((a - b) * r, 20), n.int)

proc gzQuantInt(t: GzT, p: int, dst: ptr UncheckedArray[int8], sM: var int64, sE: var int) =
  ## Zeile p nach int8: Code = round(m*127/max); Skala max/127 = sM * 2^sE (sM < 2^31+1). Nullzeile: Codes 0, sM 0.
  let d = t.cols
  let off = p * d
  var mx = 0'i64
  for c in 0 ..< d: mx = max(mx, abs(t.m[off + c].int64))
  if mx == 0:
    for c in 0 ..< d: dst[c] = 0
    sM = 0
    sE = 0
    return
  for c in 0 ..< d: dst[c] = int8(gzDivR(t.m[off + c].int64 * 127, mx))
  let v = gzDivR(mx shl 31, 127)
  let s = max(0, gzBits(uint64(v)) - 31)
  sM = gzShr(v, s)
  sE = t.e[p].int - 31 + s
  if gzKernRot: sM = (sM.float32 * 1.0000001'f32).int64     # Rot-Probe: eine float32-Rundung in der Skala

proc gzQuantKVInt(t: GzT, act: int, q: QMatrix, sM: var seq[int64], sE: var seq[int]) =
  let d = t.cols
  for p in 0 ..< act:
    gzQuantInt(t, p, cast[ptr UncheckedArray[int8]](addr q.data[p * d]), sM[p], sE[p])
    q.scale[p] = (if sM[p] == 0: 1.0'f32 else: gzZuF32(sM[p], sE[p]))   # nur fuer Vergleichswerkzeuge (alter Weg liest sie)

proc gzKopfZeile(buf: var seq[int64], eh: seq[int], nh, hs, d: int, tb: ptr UncheckedArray[int64]): int =
  ## Kopfwerte (je Kopf eigener Exponent eh[h], low(int) = Kopf null) auf einen Zeilenexponenten; Rueckgabe Exponent.
  var top = low(int)
  for h in 0 ..< nh:
    if eh[h] == low(int): continue
    var mx = 0'u64
    for k in 0 ..< hs: mx = max(mx, gzAbsU(buf[h * hs + k]))
    if mx != 0'u64: top = max(top, eh[h] + gzBits(mx))
  if top == low(int):
    for c in 0 ..< d: tb[c] = 0
    return 0
  let Ec = top - 62
  for h in 0 ..< nh:
    for k in 0 ..< hs:
      tb[h * hs + k] = (if eh[h] == low(int): 0'i64 else: gzShr(buf[h * hs + k], Ec - eh[h]))
  for c in nh * hs ..< d: tb[c] = 0
  Ec

proc gzAttFwdInt(state: ptr CortexState, L: var GzLayer, act: int, ao: GzT) =
  gzExp2Tab()
  let d = gz.dim
  let hs = state.headSize.int
  let nh = gz.heads
  let As = int64(gzIsqrt((1'u64 shl 60) div uint64(hs)))
  let Lq = gzShr(GZ_LOG2E_Q30 * As, 30)                 # log2(e)/sqrt(hs) in Q30
  let Bm = 61 - 7 - gzBits(uint64(act))                 # Kopfsummen: act Terme * |Code| <= 127 bleiben < 2^61
  let qs = cast[ptr UncheckedArray[int8]](addr gz.qs8[0])
  var qsM = newSeq[int64](act)
  var qsE = newSeq[int](act)
  for p in 0 ..< act: gzQuantInt(L.q, p, cast[ptr UncheckedArray[int8]](addr qs[p * d]), qsM[p], qsE[p])
  let tb = gzI64P(gzI64, max(L.p.cols, d))
  var A = newSeq[int64](act)
  var F = newSeq[int64](act)
  var w = newSeq[int64](act)
  var buf = newSeq[int64](d)
  var eh = newSeq[int](nh)
  for p in 0 ..< act:
    for h in 0 ..< nh:
      let ho = h * hs
      var top = low(int)
      for t in 0 .. p:
        var acc = 0'i64
        for k in 0 ..< hs: acc += int64(qs[p * d + ho + k]) * int64(L.k8.data[t * d + ho + k])
        A[t] = acc * L.ksM[t]
        if A[t] != 0: top = max(top, L.ksE[t] + gzBits(gzAbsU(A[t])))
      let Ea = (if top == low(int): 0 else: top - 31)
      var amax = low(int64)
      for t in 0 .. p:
        A[t] = gzShr(A[t], Ea - L.ksE[t])
        if A[t] > amax: amax = A[t]
      let Kq = qsM[p] * Lq
      let sk = max(0, gzBits(gzAbsU(Kq)) - 30)
      let Km = gzShr(Kq, sk)
      let sh = Ea + qsE[p] - 30 + sk + 32
      var se = 0'i64
      for t in 0 .. p:
        let P = (amax - A[t]) * Km
        var y: int64
        if P == 0: y = 0
        elif sh >= 0:
          if gzBits(uint64(P)) + sh > 38: y = high(int64)
          else: y = P shl sh
        else: y = gzShr(P, -sh)
        w[t] = (if y == high(int64): 0'i64 else: gzExp2Neg(y))
        se += w[t]
      let sed = gzShr(se, 8)
      for t in 0 ..< L.p.cols: tb[t] = (if t <= p: gzDivR(w[t] shl 22, sed) else: 0'i64)
      if gzKernRot: tb[0] = (tb[0].float32 * 1.0000001'f32).int64
      gzPutRow(L.p, h * act + p, tb, L.p.cols, -30)
      # Ausgang: sum_t prob_t * v_t
      var tv = low(int)
      for t in 0 .. p:
        F[t] = tb[t] * L.vsM[t]
        if F[t] != 0: tv = max(tv, L.vsE[t] - 30 + gzBits(gzAbsU(F[t])))
      if tv == low(int):
        eh[h] = low(int)
        for k in 0 ..< hs: buf[ho + k] = 0
        continue
      let Eg = tv - Bm
      for t in 0 .. p: F[t] = gzShr(F[t], Eg - (L.vsE[t] - 30))
      for k in 0 ..< hs:
        var s = 0'i64
        for t in 0 .. p: s += F[t] * int64(L.v8.data[t * d + ho + k])
        buf[ho + k] = s
      eh[h] = Eg
    let Ec = gzKopfZeile(buf, eh, nh, hs, d, tb)
    gzPutRow(ao, p, tb, d, Ec)

proc gzAttBwInt(state: ptr CortexState, L: var GzLayer, act: int, dao: GzT, dq, dk, dv: GzT) =
  let d = gz.dim
  let hs = state.headSize.int
  let nh = gz.heads
  let As = int64(gzIsqrt((1'u64 shl 60) div uint64(hs)))
  let ba = gzBits(uint64(act))
  let Bm = 61 - 7 - ba
  var qc = newSeq[int8](act * d)
  var qsM = newSeq[int64](act)
  var qsE = newSeq[int](act)
  for p in 0 ..< act: gzQuantInt(L.q, p, cast[ptr UncheckedArray[int8]](addr qc[p * d]), qsM[p], qsE[p])
  # Raster fuer gV aus der Schranke |gV| <= act * max|dao|
  var Bv = low(int)
  for p in 0 ..< act:
    var mx = 0'u64
    for c in 0 ..< d: mx = max(mx, gzAbsU(dao.m[p * d + c].int64))
    if mx != 0'u64: Bv = max(Bv, dao.e[p].int + gzBits(mx))
  let EV = (if Bv == low(int): 0 else: Bv + ba - 61)
  var accV = newSeq[int64](act * d)
  var accK = newSeq[int64](act * d)
  var dsB = newSeq[int64](act * nh * act)
  var dsE = newSeq[int](act * nh)
  var P = newSeq[int64](act)
  var DW = newSeq[int64](act)
  var G = newSeq[int64](act)
  var expo = newSeq[int](act)
  var buf = newSeq[int64](d)
  var eh = newSeq[int](nh)
  let tb = gzI64P(gzI64, max(act, d))
  var Bk = low(int)
  for p in 0 ..< act:
    let de = dao.e[p].int
    for h in 0 ..< nh:
      let ho = h * hs
      let r = h * act + p
      let ep = L.p.e[r].int
      for t in 0 .. p: P[t] = gzShr(L.p.m[r * L.p.cols + t].int64, -(ep + 30))
      # gV
      if Bv != low(int):
        for t in 0 .. p:
          if P[t] == 0: continue
          for k in 0 ..< hs:
            accV[t * d + ho + k] += gzShr(dao.m[p * d + ho + k].int64 * P[t], EV - (de - 30))
      # dw_t = sum_k dao * v_t
      var top = low(int)
      for t in 0 .. p:
        var s = 0'i64
        for k in 0 ..< hs: s += dao.m[p * d + ho + k].int64 * int64(L.v8.data[t * d + ho + k])
        let s1 = max(0, gzBits(gzAbsU(s)) - 31)
        DW[t] = gzShr(s, s1) * L.vsM[t]
        expo[t] = de + L.vsE[t] + s1
        if DW[t] != 0: top = max(top, expo[t] + gzBits(gzAbsU(DW[t])))
      let k0 = (p * nh + h) * act
      if top == low(int):
        dsE[p * nh + h] = low(int)
        for t in 0 .. p: dsB[k0 + t] = 0
        eh[h] = low(int)
        for k in 0 ..< hs: buf[ho + k] = 0
        continue
      let Edw = top - 31
      var sw = 0'i64
      for t in 0 .. p:
        DW[t] = gzShr(DW[t], Edw - expo[t])
        sw += P[t] * DW[t]
      let swq = gzShr(sw, 30)
      var mds = 0'u64
      for t in 0 .. p:
        G[t] = P[t] * (DW[t] - swq)
        mds = max(mds, gzAbsU(G[t]))
      let sds = max(0, gzBits(mds) - 31)
      let Eds = Edw - 30 + sds
      for t in 0 .. p:
        let v = gzShr(gzShr(G[t], sds) * As, 30)
        dsB[k0 + t] = v
        if v != 0 and qsM[p] != 0: Bk = max(Bk, Eds + qsE[p] + gzBits(gzAbsU(v * qsM[p])))
      dsE[p * nh + h] = Eds
      # gQ (nur Zeile p): sum_t ds_t * k_t
      var tq = low(int)
      for t in 0 .. p:
        G[t] = dsB[k0 + t] * L.ksM[t]
        if G[t] != 0: tq = max(tq, Eds + L.ksE[t] + gzBits(gzAbsU(G[t])))
      if tq == low(int):
        eh[h] = low(int)
        for k in 0 ..< hs: buf[ho + k] = 0
        continue
      let Eq = tq - Bm
      for t in 0 .. p: G[t] = gzShr(G[t], Eq - Eds - L.ksE[t])
      for k in 0 ..< hs:
        var s = 0'i64
        for t in 0 .. p: s += G[t] * int64(L.k8.data[t * d + ho + k])
        buf[ho + k] = s
      eh[h] = Eq
    let Ec = gzKopfZeile(buf, eh, nh, hs, d, tb)
    if gzKernRot: tb[0] = (tb[0].float32 * 1.0000001'f32).int64
    gzPutRow(dq, p, tb, d, Ec)
  # gK: zweiter Durchgang auf dem Raster aus Bk
  let EK = (if Bk == low(int): 0 else: Bk + 7 + ba - 61)
  if Bk != low(int):
    for p in 0 ..< act:
      if qsM[p] == 0: continue
      for h in 0 ..< nh:
        let Eds = dsE[p * nh + h]
        if Eds == low(int): continue
        let ho = h * hs
        let k0 = (p * nh + h) * act
        for t in 0 .. p:
          let v = dsB[k0 + t]
          if v == 0: continue
          let Hr = gzShr(v * qsM[p], EK - Eds - qsE[p])
          for k in 0 ..< hs: accK[t * d + ho + k] += Hr * int64(qc[p * d + ho + k])
  for t in 0 ..< act:
    gzPutRow(dv, t, cast[ptr UncheckedArray[int64]](addr accV[t * d]), d, EV)
    gzPutRow(dk, t, cast[ptr UncheckedArray[int64]](addr accK[t * d]), d, EK)

# Pruefwerkzeug SNAI_GZ_ATTVGL=<t>: Quantisierung, Attention vorwaerts und rueckwaerts gegen float64 bei GLEICHEM
# Eingang (q exakt round(x*127/max), k/v-Codes und -Skalen wie GZ), dazu der alte float32-Weg. SNAI_GZ_ATTVGL_ROT=1:
# float64-Referenz um genau 1e-5 relativ verschoben.
var gzAttVglAktiv = false
var gzAttVglMeld: seq[string]
proc gzAttRef64(state: ptr CortexState, L: var GzLayer, act: int, dao: GzT, fwd: bool,
                ro, rq, rk, rv: var seq[float64]) =
  let d = gz.dim
  let hs = state.headSize.int
  let nh = gz.heads
  let fak = (if getEnv("SNAI_GZ_ATTVGL_ROT") == "1": 1.0 + 1.0e-5 else: 1.0)
  var cq = newSeq[float64](act * d)
  var qsc = newSeq[float64](act)
  for p in 0 ..< act:
    var mx = 0.0
    for c in 0 ..< d: mx = max(mx, abs(gzF64(L.q, p, c)))
    qsc[p] = mx / 127.0
    for c in 0 ..< d: cq[p * d + c] = (if mx == 0.0: 0.0 else: round(gzF64(L.q, p, c) * 127.0 / mx))
  var ks, vs = newSeq[float64](act)
  for t in 0 ..< act:
    ks[t] = L.ksM[t].float64 * pow(2.0, L.ksE[t].float64)
    vs[t] = L.vsM[t].float64 * pow(2.0, L.vsE[t].float64)
  let isq = 1.0 / sqrt(hs.float64)
  if fwd: ro = newSeq[float64](act * d)
  else:
    rq = newSeq[float64](act * d); rk = newSeq[float64](act * d); rv = newSeq[float64](act * d)
  var pr = newSeq[float64](act)
  var dw = newSeq[float64](act)
  for p in 0 ..< act:
    for h in 0 ..< nh:
      let ho = h * hs
      var mx = -Inf
      for t in 0 .. p:
        var s = 0.0
        for k in 0 ..< hs: s += cq[p * d + ho + k] * L.k8.data[t * d + ho + k].float64
        pr[t] = s * qsc[p] * ks[t] * isq
        mx = max(mx, pr[t])
      var se = 0.0
      for t in 0 .. p:
        pr[t] = exp(pr[t] - mx)
        se += pr[t]
      for t in 0 .. p: pr[t] = pr[t] / se
      if fwd:
        for k in 0 ..< hs:
          var s = 0.0
          for t in 0 .. p: s += pr[t] * L.v8.data[t * d + ho + k].float64 * vs[t]
          ro[p * d + ho + k] = s * fak
      else:
        var swd = 0.0
        for t in 0 .. p:
          var s = 0.0
          for k in 0 ..< hs: s += gzF64(dao, p, ho + k) * L.v8.data[t * d + ho + k].float64 * vs[t]
          dw[t] = s
          swd += pr[t] * s
          for k in 0 ..< hs: rv[t * d + ho + k] += gzF64(dao, p, ho + k) * pr[t] * fak
        for t in 0 .. p:
          let ds = pr[t] * (dw[t] - swd) * isq
          for k in 0 ..< hs:
            rq[p * d + ho + k] += ds * L.k8.data[t * d + ho + k].float64 * ks[t] * fak
            rk[t * d + ho + k] += ds * cq[p * d + ho + k] * qsc[p] * fak

proc gzQuantKV(t: GzT, act: int, q: QMatrix, sM: var seq[int64], sE: var seq[int], name: string) =
  if not gzAn(6):
    gzQuantRows(t, act, q)
    return
  let d = t.cols
  if gzAttVglAktiv:
    let q2 = gzQAlloc(act, d)
    gzQuantRows(t, act, q2)
    gzQuantKVInt(t, act, q, sM, sE)
    var ni, nf = 0
    var sk = 0.0
    let rf = (if getEnv("SNAI_GZ_ATTVGL_ROT") == "1": 1.0 + 1.0e-3 else: 1.0)   # Rot der Codezaehlung
    for p in 0 ..< act:
      var mx = 0.0
      for c in 0 ..< d: mx = max(mx, abs(gzF64(t, p, c)))
      if mx > 0.0: sk = max(sk, abs(sM[p].float64 * pow(2.0, sE[p].float64) / (mx / 127.0) - 1.0))
      for c in 0 ..< d:
        let r = (if mx == 0.0: 0 else: round(gzF64(t, p, c) * 127.0 / mx * rf).int)
        if q.data[p * d + c].int != r: inc ni
        if q2.data[p * d + c].int != r: inc nf
    deallocShared(q2.data); deallocShared(q2.scale)
    gzAttVglMeld.add("quant-" & name & " Codes abweichend: int " & $ni & " f32 " & $nf & " von " & $(act * d) &
                     ", Skala int rel. max " & $sk)
  if gzKernAktiv:
    discard gzFeset(gzFeAuf)
    gzQuantKVInt(t, act, q, sM, sE)
    discard gzFeset(gzFeNaechster)
    var c1 = newSeq[int8](act * d)
    copyMem(addr c1[0], q.data, act * d)
    let m1 = sM
    let e1 = sE
    gzQuantKVInt(t, act, q, sM, sE)
    var n = 0
    for i in 0 ..< act * d:
      if c1[i] != q.data[i]: inc n
    for p in 0 ..< act:
      if m1[p] != sM[p] or e1[p] != sE[p]: inc n
    gzKernMeld.add("quant-" & name & (if n == 0: " gleich" else: " ABWEICHEND (" & $n & ")"))
  else: gzQuantKVInt(t, act, q, sM, sE)

proc gzAttFwd(state: ptr CortexState, L: var GzLayer, act: int, ao: GzT) =
  if not gzAn(6):
    gzAttFwdRef(state, L, act, ao)
    return
  let d = gz.dim
  var r64, rf, ri, dq0, dk0, dv0: seq[float64]
  if gzAttVglAktiv:
    gzAttRef64(state, L, act, ao, true, r64, dq0, dk0, dv0)
    let tao = gzAlloc(act, d)
    gzAttFwdRef(state, L, act, tao)        # schreibt L.p; der GZ-Lauf unten schreibt es neu
    for p in 0 ..< act:
      for c in 0 ..< d: rf.add(gzF64(tao, p, c))
    gzFrei(tao)
  if gzKernAktiv:
    discard gzFeset(gzFeAuf)
    gzExp2Fertig = false
    gzAttFwdInt(state, L, act, ao)
    discard gzFeset(gzFeNaechster)
    let s1 = gzSnap(ao, act)
    let p1 = gzSnap(L.p, gz.heads * act)
    gzExp2Fertig = false
    gzAttFwdInt(state, L, act, ao)
    gzKernVgl("att-fwd", s1, ao, act)
    gzKernVgl("att-prob", p1, L.p, gz.heads * act)
    gzFrei(s1); gzFrei(p1)
  else: gzAttFwdInt(state, L, act, ao)
  if gzAttVglAktiv:
    for p in 0 ..< act:
      for c in 0 ..< d: ri.add(gzF64(ao, p, c))
    gzAttVglMeld.add("att-fwd int " & $gzRelL2(ri, r64) & " f32 " & $gzRelL2(rf, r64))

proc gzAttBw(state: ptr CortexState, L: var GzLayer, act: int, dao: GzT, dq, dk, dv: GzT) =
  if not gzAn(6):
    gzAttBwRef(state, L, act, dao, dq, dk, dv)
    return
  let d = gz.dim
  var o0, rq, rk, rv, fq, fk, fv: seq[float64]
  if gzAttVglAktiv:
    gzAttRef64(state, L, act, dao, false, o0, rq, rk, rv)
    let tq = gzAlloc(act, d)
    let tk = gzAlloc(act, d)
    let tv = gzAlloc(act, d)
    gzAttBwRef(state, L, act, dao, tq, tk, tv)
    for p in 0 ..< act:
      for c in 0 ..< d:
        fq.add(gzF64(tq, p, c)); fk.add(gzF64(tk, p, c)); fv.add(gzF64(tv, p, c))
    gzFrei(tq); gzFrei(tk); gzFrei(tv)
  if gzKernAktiv:
    discard gzFeset(gzFeAuf)
    gzAttBwInt(state, L, act, dao, dq, dk, dv)
    discard gzFeset(gzFeNaechster)
    let s1 = gzSnap(dq, act)
    let s2 = gzSnap(dk, act)
    let s3 = gzSnap(dv, act)
    gzAttBwInt(state, L, act, dao, dq, dk, dv)
    gzKernVgl("att-bw-dq", s1, dq, act)
    gzKernVgl("att-bw-dk", s2, dk, act)
    gzKernVgl("att-bw-dv", s3, dv, act)
    gzFrei(s1); gzFrei(s2); gzFrei(s3)
  else: gzAttBwInt(state, L, act, dao, dq, dk, dv)
  if gzAttVglAktiv:
    var iq, ik, iv: seq[float64]
    for p in 0 ..< act:
      for c in 0 ..< d:
        iq.add(gzF64(dq, p, c)); ik.add(gzF64(dk, p, c)); iv.add(gzF64(dv, p, c))
    gzAttVglMeld.add("att-bw-dq int " & $gzRelL2(iq, rq) & " f32 " & $gzRelL2(fq, rq) &
                     " | att-bw-dk int " & $gzRelL2(ik, rk) & " f32 " & $gzRelL2(fk, rk) &
                     " | att-bw-dv int " & $gzRelL2(iv, rv) & " f32 " & $gzRelL2(fv, rv))

proc gzAddRef(x, y: GzT, act: int) =
  ## x += y (Referenz)
  let fx = gzF(gz.f1)
  let fy = gzF(gz.f2)
  gzToF(x, act, fx)
  gzToF(y, act, fy)
  for i in 0 ..< act * x.cols: fx[i] += fy[i]
  gzFromF(x, act, fx)

proc gzSiluFwdRef(state: ptr CortexState, u, s: GzT, act: int) =
  ## Wie der alte Pfad: u je Position int8 (act_ffn_in_q8), SiLU auf dem entquantisierten Wert; u wird
  ## durch die int8-Fassung ersetzt (der Rueckwaerts sieht dieselbe Historie wie im alten Pfad).
  let n = u.cols
  let fu = gzF(gz.f1)
  let fs = gzF(gz.f2)
  gzToF(u, act, fu)
  var q8 = gzQAlloc(1, n)
  for p in 0 ..< act:
    quantizeVectorToQ8Row(cast[ptr FloatArray](addr fu[p * n]), q8, 0, n.cint)
    for k in 0 ..< n:
      let v = q8.data[k].cfloat * q8.scale[0]
      fu[p * n + k] = v
      fs[p * n + k] = v * (1.0 / (1.0 + exp(-v)))
  deallocShared(q8.data); deallocShared(q8.scale)
  gzFromF(u, act, fu)
  # Historie der FFN-Ausgabe wie act_ffn_out_q8: je Position int8
  q8 = gzQAlloc(1, n)
  for p in 0 ..< act:
    quantizeVectorToQ8Row(cast[ptr FloatArray](addr fs[p * n]), q8, 0, n.cint)
    for k in 0 ..< n: fs[p * n + k] = q8.data[k].cfloat * q8.scale[0]
  deallocShared(q8.data); deallocShared(q8.scale)
  gzFromF(s, act, fs)

proc gzSiluBwRef(u, ds: GzT, act: int) =
  ## ds *= SiLU'(u)
  let n = u.cols
  let fu = gzF(gz.f3)
  let fd = gzF(gz.f4)
  gzToF(u, act, fu)
  gzToF(ds, act, fd)
  for i in 0 ..< act * n:
    let x = fu[i]
    let sig = 1.0 / (1.0 + exp(-x))
    fd[i] *= sig * (1.0 + x * (1.0 - sig))
  gzFromF(ds, act, fd)

proc gzCERef(lg: GzT, t_tg, t_mask: ptr IntArray, act: int, loss: var cfloat, cnt: var cint) =
  ## Alter Weg: Softmax, Loss (Protokoll), dLogits in float32 - wie fwdBatchedCpu.
  let v = gz.vocab
  let fl = gzF(gz.f3)
  gzToF(lg, act, fl)
  loss = 0.0
  cnt = 0
  for p in 0 ..< act:
    var tg = t_tg[p]
    if tg < 0 or tg >= v: tg = 0
    let b = p * v
    var mx: cfloat = -9999.0
    for k in 0 ..< v:
      if fl[b + k] > mx: mx = fl[b + k]
    var sp: cfloat = 0.0
    for k in 0 ..< v:
      fl[b + k] = exp(fl[b + k] - mx)
      sp += fl[b + k]
    for k in 0 ..< v: fl[b + k] /= sp
    if t_mask[p] != 0:
      loss += -ln(fl[b + tg] + 1e-7)
      inc cnt
      for k in 0 ..< v: fl[b + k] = fl[b + k] - smoothedTarget(k, tg, v.cint)
    else:
      for k in 0 ..< v: fl[b + k] = 0.0
  gzFromF(lg, act, fl)

# =============================================================================================================
# Stufe 7 (2026-11-15): Softmax und Kreuzentropie der Logits ganzzahlig (Schalter SNAI_I8_GZ_LOGITS).
# =============================================================================================================
# Je Position: y_k = (max - l_k) * log2(e) in Q32 aus den Zeilenmantissen, 2^(-y) per Q40-Tabelle (wie Stufe 6),
# Wahrscheinlichkeiten Q30, dLogits = p - Ziel; Ziele der Label-Glaettung (1-eps, eps/(V-1)) einmal als Q30-Konstanten
# (Ausnahme a). Verlust (Protokoll) ganzzahlig: -log2(p_tg + 1e-7) in Q32 (p in Q40, Tabelle gzLg), Mittel, mal ln 2,
# float32 per Bitbau - auch die Protokollzahl haengt damit nicht vom Rundungsmodus ab.
const GZ_LN2_Q30 = 744261118'i64          # round(ln(2) * 2^30)
proc gzTabellen()
proc gzLog2Q(x: uint64): int64 {.inline.}
var gzLsOn, gzLsOff: int64
var gzLsV = -1
var gzLsEps = 0'u32
var gzVerlustMittel: cfloat
proc gzLsTab(v: int) =
  if gzLsV == v and gzLsEps == cast[uint32](global_label_smoothing): return
  let alt = gzFeget()
  discard gzFeset(gzFeNaechster)
  gzLsOn = round(smoothedTarget(0, 0, v.cint).float64 * 1073741824.0).int64
  gzLsOff = (if v > 1: round(smoothedTarget(1, 0, v.cint).float64 * 1073741824.0).int64 else: 0'i64)
  discard gzFeset(alt)
  gzLsV = v
  gzLsEps = cast[uint32](global_label_smoothing)

proc gzCEInt(lg: GzT, t_tg, t_mask: ptr IntArray, act: int, cnt: var cint) =
  gzExp2Tab()
  gzTabellen()
  let v = gz.vocab
  gzLsTab(v)
  let tb = gzI64P(gzI64, v)
  var w = newSeq[int64](v)
  var lsum = 0'i64
  cnt = 0
  for p in 0 ..< act:
    let off = p * v
    if t_mask[p] == 0:
      for k in 0 ..< v: lg.m[off + k] = 0
      lg.e[p] = 0
      continue
    var tg = t_tg[p]
    if tg < 0 or tg >= v: tg = 0
    var mmax = low(int64)
    for k in 0 ..< v: mmax = max(mmax, lg.m[off + k].int64)
    let sh = lg.e[p].int + 2                   # Q32: (max - m) * 2^e * log2(e) = P * 2^(e - 30 + 32)
    var se = 0'i64
    for k in 0 ..< v:
      let P = (mmax - lg.m[off + k].int64) * GZ_LOG2E_Q30
      var y: int64
      if P == 0: y = 0
      elif sh >= 0:
        if gzBits(uint64(P)) + sh > 38: y = high(int64)
        else: y = P shl sh
      else: y = gzShr(P, -sh)
      w[k] = (if y == high(int64): 0'i64 else: gzExp2Neg(y))
      se += w[k]
    let sed = gzShr(se, 8)
    for k in 0 ..< v: tb[k] = gzDivR(w[k] shl 22, sed)
    let X = gzDivR(w[tg] shl 22, gzShr(se, 18)) + 109951'i64      # p_tg + 1e-7 in Q40
    lsum += (40'i64 shl 32) - gzLog2Q(uint64(X))
    inc cnt
    for k in 0 ..< v: tb[k] -= (if k == tg: gzLsOn else: gzLsOff)
    # Rot-Probe am Zieleintrag (|tb[tg]| ~ 0,9 * 2^30): tb[0] (Token 0, |tb| < 2^23) machte die float32-Rundung nach dem
    # Abschneiden unsichtbar, Rot 1 blieb gruen (15.11.)
    if gzKernRot: tb[tg] = (tb[tg].float32 * 1.0000001'f32).int64
    gzPutRow(lg, p, tb, v, -30)
  let mean = (if cnt > 0: gzDivR(lsum, cnt.int64) else: 0'i64)
  gzVerlustMittel = gzZuF32(gzShr(mean, 7) * GZ_LN2_Q30, -55)

# Pruefwerkzeug SNAI_GZ_LOGVGL=<t>: dLogits und Verlust gegen float64 bei GLEICHEN Logits, dazu der alte float32-Weg.
# SNAI_GZ_LOGVGL_ROT=1: float64-Referenz um genau 1e-5 relativ verschoben.
var gzLogVglAktiv = false
var gzLogVglMeld: seq[string]
proc gzLogits(state: ptr CortexState, t_tg, t_mask: ptr IntArray, act: int, loss: var cfloat, cnt: var cint) =
  gzMatFwd(state.w_out_q8, gz.nf, gz.lg, act)
  if not gzAn(7):
    gzCERef(gz.lg, t_tg, t_mask, act, loss, cnt)
    return
  let v = gz.vocab
  var r64, rf, ri: seq[float64]
  var l64, lf: float64
  if gzLogVglAktiv:
    let fak = (if getEnv("SNAI_GZ_LOGVGL_ROT") == "1": 1.0 + 1.0e-5 else: 1.0)
    let eps = global_label_smoothing.float64
    var n = 0
    for p in 0 ..< act:
      if t_mask[p] == 0:
        for k in 0 ..< v: r64.add(0.0)
        continue
      var tg = t_tg[p]
      if tg < 0 or tg >= v: tg = 0
      var mx = -Inf
      for k in 0 ..< v: mx = max(mx, gzF64(gz.lg, p, k))
      var se = 0.0
      var e = newSeq[float64](v)
      for k in 0 ..< v:
        e[k] = exp(gzF64(gz.lg, p, k) - mx)
        se += e[k]
      l64 += -ln(e[tg] / se + 1.0e-7)
      inc n
      for k in 0 ..< v:
        let ziel = (if eps <= 0.0: (if k == tg: 1.0 else: 0.0) elif k == tg: 1.0 - eps else: eps / (v - 1).float64)
        r64.add((e[k] / se - ziel) * fak)
    l64 = l64 / max(1, n).float64 * fak
    let tl = gzSnap(gz.lg, act)
    var lsf: cfloat
    var cf: cint
    gzCERef(tl, t_tg, t_mask, act, lsf, cf)
    lf = lsf.float64 / max(1, cf).float64
    for p in 0 ..< act:
      for k in 0 ..< v: rf.add(gzF64(tl, p, k))
    gzFrei(tl)
  if gzKernAktiv:
    let s0 = gzSnap(gz.lg, act)
    discard gzFeset(gzFeAuf)
    gzExp2Fertig = false
    gzCEInt(gz.lg, t_tg, t_mask, act, cnt)
    discard gzFeset(gzFeNaechster)
    let s1 = gzSnap(gz.lg, act)
    let v1 = gzVerlustMittel
    gzCopy(gz.lg, s0, act)
    gzExp2Fertig = false
    gzCEInt(gz.lg, t_tg, t_mask, act, cnt)
    gzKernVgl("ce-dlogits", s1, gz.lg, act)
    gzKernMeld.add("ce-verlust " & (if cast[uint32](v1) == cast[uint32](gzVerlustMittel): "gleich" else: "ABWEICHEND"))
    gzFrei(s0); gzFrei(s1)
  else: gzCEInt(gz.lg, t_tg, t_mask, act, cnt)
  loss = gzVerlustMittel * max(1, cnt).cfloat      # nur fuer Aufrufer, die die Summe erwarten; gzFwdBwd nimmt das Mittel
  if gzLogVglAktiv:
    for p in 0 ..< act:
      for k in 0 ..< v: ri.add(gzF64(gz.lg, p, k))
    gzLogVglMeld.add("ce-dlogits int " & $gzRelL2(ri, r64) & " f32 " & $gzRelL2(rf, r64) &
                     " | ce-verlust int " & $abs(gzVerlustMittel.float64 / l64 - 1.0) & " f32 " & $abs(lf / l64 - 1.0))

proc gzEmbBwRef(state: ptr CortexState, t_in: ptr IntArray, act: int, dx: GzT) =
  let d = gz.dim
  let f = gzF(gz.f1)
  gzToF(dx, act, f)
  for p in 0 ..< act:
    var tid = t_in[p]
    if tid < 0 or tid >= gz.vocab: tid = 0
    for k in 0 ..< d:
      state.g_embeddings.data[tid * d + k] += f[p * d + k] * embFak(state)

# =============================================================================================================
# Stufe 8 (2026-11-15): Restpfad, SiLU, Embedding ganzzahlig (Schalter SNAI_I8_GZ_REST).
# =============================================================================================================
# - Rest-Addition x += y: Zeilen per gzAddRow (Exponenten angleichen, neu normieren).
# - Embedding vorwaerts: Code * Skala * embFak, Skala und embFak bitgenau zerlegt (gzMulF) => exakt.
# - Embedding rueckwaerts: dx * embFak je Position in einen eigenen Ganzzahl-Puffer gz.gLook (vocab x d); der Adam
#   (Stufe 3) holt ihn in gzEmbZusammen, ohne Stufe 3 klebt ihn gzFwdBwd in den float-Puffer g_embeddings.
# - SiLU vorwaerts: u je Position int8 (wie bisher), sigma je Code ueber 2^(-|v| log2 e) (Tabelle aus Stufe 6) und
#   eine Division in Q30, s = v * sigma, dann s je Position int8 (Historie wie bisher).
# - SiLU rueckwaerts: ds *= sigma(x) (1 + x (1 - sigma(x))) in Q30.
# - Saettigungen (SiLU rueckwaerts bei |x| >= 2^32) werden gezaehlt und alle 1000 Schritte gemeldet.
var gzSatRest = 0'i64

proc gzSigmaQ30(a: int64, e: int, neg: bool): int64 =
  ## sigma(x) in Q30 fuer x = +-a * 2^e (a >= 0): t = e^(-|x|) in Q40, sigma(|x|) = 1/(1+t), sigma(-|x|) = t/(1+t).
  var t: int64
  if a == 0: t = 1'i64 shl 40
  else:
    let sa = max(0, gzBits(uint64(a)) - 31)
    let P = gzShr(a, sa) * GZ_LOG2E_Q30
    let sh = e + sa - 30 + 32
    var y: int64
    if P == 0: y = 0
    elif sh >= 0:
      if gzBits(uint64(P)) + sh > 38: y = high(int64)
      else: y = P shl sh
    else: y = gzShr(P, -sh)
    t = (if y == high(int64): 0'i64 else: gzExp2Neg(y))
  let nen = gzShr((1'i64 shl 40) + t, 8)
  if neg: gzDivR(t shl 22, nen) else: gzDivR(1'i64 shl 62, nen)

proc gzAddInt(x, y: GzT, act: int) =
  let d = x.cols
  let tb = gzI64P(gzI64, d)
  for p in 0 ..< act:
    if gzRowNull(y, p): continue
    for c in 0 ..< d: tb[c] = y.m[p * d + c].int64
    if gzKernRot: tb[0] = (tb[0].float32 * 1.0000001'f32).int64
    gzAddRow(x, p, tb, d, y.e[p].int)

proc gzEmbFwdInt(state: ptr CortexState, t_in: ptr IntArray, act: int, x: GzT) =
  let d = gz.dim
  let f = gzMulF(embFak(state))
  let tb = gzI64P(gzI64, d)
  for p in 0 ..< act:
    var tid = t_in[p]
    if tid < 0 or tid >= gz.vocab: tid = 0
    let s = gzMulF(state.embeddings_q8.scale[tid])
    let sf = s.m * f.m
    for k in 0 ..< d: tb[k] = int64(state.embeddings_q8.data[tid * d + k]) * sf
    if gzKernRot: tb[0] = (tb[0].float32 * 1.0000001'f32).int64
    gzPutRow(x, p, tb, d, s.e.int + f.e.int)

proc gzEmbBwInt(state: ptr CortexState, t_in: ptr IntArray, act: int, dx: GzT) =
  let d = gz.dim
  let f = gzMulF(embFak(state))
  let tb = gzI64P(gzI64, d)
  for p in 0 ..< act:
    if gzRowNull(dx, p): continue
    var tid = t_in[p]
    if tid < 0 or tid >= gz.vocab: tid = 0
    for k in 0 ..< d: tb[k] = dx.m[p * d + k].int64 * f.m
    if gzKernRot: tb[0] = (tb[0].float32 * 1.0000001'f32).int64
    gzAddRow(gz.gLook, tid, tb, d, dx.e[p].int + f.e.int)

proc gzSiluFwdInt(state: ptr CortexState, u, s: GzT, act: int) =
  gzExp2Tab()
  let n = u.cols
  var cu = newSeq[int8](n)
  var cs = newSeq[int8](n)
  var vs: array[255, int64]
  let tb = gzI64P(gzI64, n)
  for p in 0 ..< act:
    var sM, s2M: int64
    var sE, s2E: int
    gzQuantInt(u, p, cast[ptr UncheckedArray[int8]](addr cu[0]), sM, sE)
    if sM == 0:
      for k in 0 ..< n:
        u.m[p * n + k] = 0
        s.m[p * n + k] = 0
      u.e[p] = 0
      s.e[p] = 0
      continue
    # v * sigma(v) je Code c: c * gzShr(sM * sigma, 7), Exponent sE + 7 - 30
    for c in -127 .. 127:
      let sg = gzSigmaQ30(abs(c).int64 * sM, sE, c < 0)
      vs[c + 127] = c.int64 * gzShr(sM * sg, 7)
    for k in 0 ..< n: tb[k] = vs[cu[k].int + 127]
    if gzKernRot: tb[0] = (tb[0].float32 * 1.0000001'f32).int64
    gzPutRow(s, p, tb, n, sE + 7 - 30)
    gzQuantInt(s, p, cast[ptr UncheckedArray[int8]](addr cs[0]), s2M, s2E)
    for k in 0 ..< n: tb[k] = cs[k].int64 * s2M
    gzPutRow(s, p, tb, n, s2E)
    for k in 0 ..< n: tb[k] = cu[k].int64 * sM
    gzPutRow(u, p, tb, n, sE)

proc gzSiluBwInt(u, ds: GzT, act: int) =
  gzExp2Tab()
  let n = u.cols
  let tb = gzI64P(gzI64, n)
  for p in 0 ..< act:
    if gzRowNull(ds, p): continue
    let e = u.e[p].int
    for k in 0 ..< n:
      let m = u.m[p * n + k].int64
      let sg = gzSigmaQ30(abs(m), e, m < 0)
      let om = (1'i64 shl 30) - sg
      let mo = m * om                      # x (1 - sigma) in Q30 ist mo * 2^e
      var fac: int64
      if e <= 0 or gzBits(gzAbsU(mo)) + e <= 61:
        # |sg * xo| bleibt < 2^59: fuer x > 0 ist xo <= 0,28 * 2^30, fuer x < 0 ist sigma |x| <= 0,28 (sg = 0 ab x < -21,5)
        let xo = gzShr(mo, -e)
        fac = gzShr(sg * ((1'i64 shl 30) + xo), 30)
      else:
        # |x| um 2^31: Grenzwert der Ableitung (1 fuer x -> +inf, 0 fuer x -> -inf), gezaehlt
        inc gzSatRest
        fac = (if m >= 0: 1'i64 shl 30 else: 0'i64)
      tb[k] = ds.m[p * n + k].int64 * fac
    if gzKernRot: tb[0] = (tb[0].float32 * 1.0000001'f32).int64
    gzPutRow(ds, p, tb, n, ds.e[p].int - 30)

# Pruefwerkzeug SNAI_GZ_RESTVGL=<t>: Rest-Addition, Embedding vorwaerts/rueckwaerts, SiLU vorwaerts/rueckwaerts gegen
# float64 bei GLEICHEM Eingang, dazu der alte float32-Weg. SNAI_GZ_RESTVGL_ROT=1: Referenz um 1e-5 verschoben,
# Referenzcodes aus x*127/max*(1+1e-3).
var gzRestVglAktiv = false
var gzRestVglMeld: seq[string]
proc gzRestFak(): float64 = (if getEnv("SNAI_GZ_RESTVGL_ROT") == "1": 1.0 + 1.0e-5 else: 1.0)

proc gzAdd(x, y: GzT, act: int) =
  if not gzAn(8):
    gzAddRef(x, y, act)
    return
  let d = x.cols
  var r64, rf, ri: seq[float64]
  if gzRestVglAktiv:
    for p in 0 ..< act:
      for c in 0 ..< d: r64.add((gzF64(x, p, c) + gzF64(y, p, c)) * gzRestFak())
    let tx = gzSnap(x, act)
    gzAddRef(tx, y, act)
    for p in 0 ..< act:
      for c in 0 ..< d: rf.add(gzF64(tx, p, c))
    gzFrei(tx)
  if gzKernAktiv:
    let s0 = gzSnap(x, act)
    discard gzFeset(gzFeAuf)
    gzAddInt(x, y, act)
    discard gzFeset(gzFeNaechster)
    let s1 = gzSnap(x, act)
    gzCopy(x, s0, act)
    gzAddInt(x, y, act)
    gzKernVgl("rest-add", s1, x, act)
    gzFrei(s0); gzFrei(s1)
  else: gzAddInt(x, y, act)
  if gzRestVglAktiv:
    for p in 0 ..< act:
      for c in 0 ..< d: ri.add(gzF64(x, p, c))
    gzRestVglMeld.add("rest-add int " & $gzRelL2(ri, r64) & " f32 " & $gzRelL2(rf, r64))

proc gzEmbFwd(state: ptr CortexState, t_in: ptr IntArray, act: int, x: GzT) =
  if not gzAn(8):
    gzEmbFwdRef(state, t_in, act, x)
    return
  let d = gz.dim
  if gzKernAktiv:
    discard gzFeset(gzFeAuf)
    gzEmbFwdInt(state, t_in, act, x)
    discard gzFeset(gzFeNaechster)
    let s1 = gzSnap(x, act)
    gzEmbFwdInt(state, t_in, act, x)
    gzKernVgl("emb-fwd", s1, x, act)
    gzFrei(s1)
  else: gzEmbFwdInt(state, t_in, act, x)
  if gzRestVglAktiv:
    var r64, ri, rf: seq[float64]
    let ef = embFak(state).float64
    for p in 0 ..< act:
      var tid = t_in[p]
      if tid < 0 or tid >= gz.vocab: tid = 0
      for k in 0 ..< d:
        r64.add(state.embeddings_q8.data[tid * d + k].float64 * state.embeddings_q8.scale[tid].float64 * ef * gzRestFak())
        ri.add(gzF64(x, p, k))
    let tx = gzAlloc(act, d)
    gzEmbFwdRef(state, t_in, act, tx)
    for p in 0 ..< act:
      for k in 0 ..< d: rf.add(gzF64(tx, p, k))
    gzFrei(tx)
    gzRestVglMeld.add("emb-fwd int " & $gzRelL2(ri, r64) & " f32 " & $gzRelL2(rf, r64))

proc gzEmbBw(state: ptr CortexState, t_in: ptr IntArray, act: int, dx: GzT) =
  if not gzAn(8):
    gzEmbBwRef(state, t_in, act, dx)
    return
  let d = gz.dim
  if gzKernAktiv:
    let g0 = gzSnap(gz.gLook, gz.vocab)
    discard gzFeset(gzFeAuf)
    gzEmbBwInt(state, t_in, act, dx)
    discard gzFeset(gzFeNaechster)
    let g1 = gzSnap(gz.gLook, gz.vocab)
    gzCopy(gz.gLook, g0, gz.vocab)
    gzEmbBwInt(state, t_in, act, dx)
    gzKernVgl("emb-bw", g1, gz.gLook, gz.vocab)
    gzFrei(g0); gzFrei(g1)
  else: gzEmbBwInt(state, t_in, act, dx)
  if gzRestVglAktiv:
    # Puffer war vor dem Aufruf null: gLook ist genau der Lookup-Anteil dieses Schritts
    var a64 = newSeq[float64](gz.vocab * d)
    let ef = embFak(state).float64
    for p in 0 ..< act:
      var tid = t_in[p]
      if tid < 0 or tid >= gz.vocab: tid = 0
      for k in 0 ..< d: a64[tid * d + k] += gzF64(dx, p, k) * ef
    var r64, ri, rf: seq[float64]
    for r in 0 ..< gz.vocab:
      for k in 0 ..< d:
        r64.add(a64[r * d + k] * gzRestFak())
        ri.add(gzF64(gz.gLook, r, k))
    let alt = newSeq[cfloat](gz.vocab * d)
    copyMem(addr alt[0], state.g_embeddings.data, gz.vocab * d * 4)
    zeroMem(state.g_embeddings.data, gz.vocab * d * 4)
    gzEmbBwRef(state, t_in, act, dx)
    for i in 0 ..< gz.vocab * d: rf.add(state.g_embeddings.data[i].float64)
    copyMem(state.g_embeddings.data, unsafeAddr alt[0], gz.vocab * d * 4)
    gzRestVglMeld.add("emb-bw int " & $gzRelL2(ri, r64) & " f32 " & $gzRelL2(rf, r64))

proc gzSiluFwd(state: ptr CortexState, u, s: GzT, act: int) =
  if not gzAn(8):
    gzSiluFwdRef(state, u, s, act)
    return
  let n = u.cols
  var ru, rs, fu, fs: seq[float64]
  var cuR, csR: seq[int]
  var nuF, nsF = 0
  if gzRestVglAktiv:
    # float64: u exakt quantisiert, s = v * sigma(v) exakt, s exakt quantisiert
    let rf = (if getEnv("SNAI_GZ_RESTVGL_ROT") == "1": 1.0 + 1.0e-3 else: 1.0)
    for p in 0 ..< act:
      var mx = 0.0
      for k in 0 ..< n: mx = max(mx, abs(gzF64(u, p, k)))
      var sv = newSeq[float64](n)
      var ms = 0.0
      for k in 0 ..< n:
        let c = (if mx == 0.0: 0 else: round(gzF64(u, p, k) * 127.0 / mx * rf).int)
        cuR.add(c)
        let v = c.float64 * mx / 127.0
        ru.add(v)
        sv[k] = v / (1.0 + exp(-v))
        ms = max(ms, abs(sv[k]))
      for k in 0 ..< n:
        let c = (if ms == 0.0: 0 else: round(sv[k] * 127.0 / ms * rf).int)
        csR.add(c)
        rs.add(c.float64 * ms / 127.0)
    let tu = gzSnap(u, act)
    let ts = gzAlloc(act, n)
    gzSiluFwdRef(state, tu, ts, act)
    for p in 0 ..< act:
      for k in 0 ..< n:
        fu.add(gzF64(tu, p, k)); fs.add(gzF64(ts, p, k))
    gzFrei(tu); gzFrei(ts)
  if gzKernAktiv:
    let u0 = gzSnap(u, act)
    discard gzFeset(gzFeAuf)
    gzExp2Fertig = false           # Tabelle je Lauf neu (sonst saehe die Probe nur eine einmal gebaute Tabelle; Rot 2)
    gzSiluFwdInt(state, u, s, act)
    discard gzFeset(gzFeNaechster)
    let u1 = gzSnap(u, act)
    let s1 = gzSnap(s, act)
    gzCopy(u, u0, act)
    gzExp2Fertig = false
    gzSiluFwdInt(state, u, s, act)
    gzKernVgl("silu-fwd-u", u1, u, act)
    gzKernVgl("silu-fwd-s", s1, s, act)
    gzFrei(u0); gzFrei(u1); gzFrei(s1)
  else: gzSiluFwdInt(state, u, s, act)
  if gzRestVglAktiv:
    # Codes zaehlen: Wert / (Skala) zurueckgerechnet; u, s sind nach dem Lauf entquantisiert
    var iu, isv: seq[float64]
    var nu, ns = 0
    var i = 0
    for p in 0 ..< act:
      var mu, ms = 0.0
      for k in 0 ..< n:
        mu = max(mu, abs(gzF64(u, p, k)))
        ms = max(ms, abs(gzF64(s, p, k)))
      for k in 0 ..< n:
        let cu = (if mu == 0.0: 0 else: round(gzF64(u, p, k) * 127.0 / mu).int)
        let cs = (if ms == 0.0: 0 else: round(gzF64(s, p, k) * 127.0 / ms).int)
        if cu != cuR[i]: inc nu
        if cs != csR[i]: inc ns
        iu.add(gzF64(u, p, k)); isv.add(gzF64(s, p, k))
        inc i
    # alte Fassung: Codes aus ihren entquantisierten Werten
    i = 0
    for p in 0 ..< act:
      var mu, ms = 0.0
      for k in 0 ..< n:
        mu = max(mu, abs(fu[p * n + k]))
        ms = max(ms, abs(fs[p * n + k]))
      for k in 0 ..< n:
        let cu = (if mu == 0.0: 0 else: round(fu[i] * 127.0 / mu).int)
        let cs = (if ms == 0.0: 0 else: round(fs[i] * 127.0 / ms).int)
        if cu != cuR[i]: inc nuF
        if cs != csR[i]: inc nsF
        inc i
    gzRestVglMeld.add("silu-fwd Codes abweichend: u int " & $nu & " f32 " & $nuF & ", s int " & $ns & " f32 " & $nsF &
                      " von " & $(act * n) & " | silu-fwd-s int " & $gzRelL2(isv, rs) & " f32 " & $gzRelL2(fs, rs))

proc gzSiluBw(u, ds: GzT, act: int) =
  if not gzAn(8):
    gzSiluBwRef(u, ds, act)
    return
  let n = u.cols
  var r64, rf, ri: seq[float64]
  if gzRestVglAktiv:
    for p in 0 ..< act:
      for k in 0 ..< n:
        let x = gzF64(u, p, k)
        let sg = 1.0 / (1.0 + exp(-x))
        r64.add(gzF64(ds, p, k) * sg * (1.0 + x * (1.0 - sg)) * gzRestFak())
    let td = gzSnap(ds, act)
    gzSiluBwRef(u, td, act)
    for p in 0 ..< act:
      for k in 0 ..< n: rf.add(gzF64(td, p, k))
    gzFrei(td)
  if gzKernAktiv:
    let d0 = gzSnap(ds, act)
    discard gzFeset(gzFeAuf)
    gzExp2Fertig = false
    gzSiluBwInt(u, ds, act)
    discard gzFeset(gzFeNaechster)
    let d1 = gzSnap(ds, act)
    gzCopy(ds, d0, act)
    gzExp2Fertig = false
    gzSiluBwInt(u, ds, act)
    gzKernVgl("silu-bw", d1, ds, act)
    gzFrei(d0); gzFrei(d1)
  else: gzSiluBwInt(u, ds, act)
  if gzRestVglAktiv:
    for p in 0 ..< act:
      for k in 0 ..< n: ri.add(gzF64(ds, p, k))
    gzRestVglMeld.add("silu-bw int " & $gzRelL2(ri, r64) & " f32 " & $gzRelL2(rf, r64))

# =============================================================================================================
# Stufe 9 (2026-11-15): Lernratenplan in Festkomma (Ausnahme b der Zieldefinition). Schalter SNAI_I8_GZ_LRPLAN bzw.
# SNAI_I8_GANZ >= 9; braucht Stufe 3 (ganzzahliger Adam), ohne sie Warnung und ohne Wirkung.
# Formel wie train_worker.php: t < W: lr0 t / W; sonst bei D > W: lr0 (m + (1 - m) (1 + cos(pi p)) / 2) mit
# p = clamp((t - S) / (D - S), 0, 1); sonst lr0. (1 + cos)/2 steht als Q30-Tabelle ueber die D - S + 1 Schritte, EINMAL
# beim ersten Gebrauch in float64 im Modus "naechster" gebaut (Ausnahmen a/b); je Schritt nur Tabellenzugriff,
# Multiplikation und Normierung in int64, Ergebnis 24-Bit-Mantisse + Exponent (Genauigkeit wie float32).
# PHP uebergibt lr0, W, S, D, m einmal (cortex_gz_lr_plan); ausgeschaltet werden sie nur gespeichert. Der float-Wert,
# den PHP je Schritt weiter uebergibt, ist Protokoll und Wache: weicht der Plan um mehr als 2^-17 relativ davon ab,
# bricht der Schritt ab (Parameter oder Formel sind auseinandergelaufen).
var gzLrDa = false
var gzLr0: GzMul
var gzLrW, gzLrS, gzLrD: int
var gzLrMin: cfloat
var gzLrMq: int64                 # m in Q30
var gzLrCos: seq[int64]           # (1 + cos(pi i / (D - S))) / 2 in Q30, i = 0 .. D - S
var gzLrTabFertig = false
var gzLrMaxAbw = 0'i64            # Wache: groesste Abweichung Plan gegen PHP-Wert seit dem letzten Bericht, in 2^-30 relativ
var gzLrVglFertig = false
var gzLrWacheRot = -1            # SNAI_GZ_LRWACHE_ROT=1: Plan absichtlich um 2^-12 verschoben (Wache muss abbrechen)
var gzKernRotLr = false           # SNAI_GZ_KERN_ROT=2: Tabelle ohne festen Modus in float32 (Rot der Tabellenprobe)

proc cortex_gz_lr_plan*(lr0: cfloat, warmup, decayStart, decaySteps: cint, minRatio: cfloat): cint {.ffi.} =
  ## Parameter des Lernratenplans (aus train_worker.php, einmal je Prozess). 1 = uebernommen; ungueltige Werte:
  ## 0, wenn Stufe 9 an ist (PHP bricht ab), sonst 2 (nichts gespeichert, ausgeschaltet aendert sich nichts).
  let ok = lr0 > 0.0'f32 and warmup >= 0 and decaySteps >= 0 and decayStart >= warmup and
           minRatio >= 0.0'f32 and minRatio <= 1.0'f32 and not (decaySteps > warmup and decaySteps <= decayStart)
  if not ok: return (if gzAn(9): 0 else: 2)
  gzLr0 = gzMulF(lr0)
  gzLrW = warmup.int
  gzLrS = decayStart.int
  gzLrD = decaySteps.int
  gzLrMin = minRatio
  gzLrTabFertig = false
  gzLrDa = true
  1

proc gzLrTab() =
  if gzLrTabFertig: return
  let M = gzMulF(gzLrMin)
  gzLrMq = (if M.m == 0: 0'i64 else: gzShr(M.m, -(M.e.int + 30)))
  gzLrCos.setLen(0)
  if gzLrD > gzLrW:
    let n = gzLrD - gzLrS
    let alt = gzFeget()
    if not gzKernRotLr: discard gzFeset(gzFeNaechster)
    gzLrCos.setLen(n + 1)
    for i in 0 .. n:
      if gzKernRotLr:
        gzLrCos[i] = ((1.0'f32 + cos(PI.float32 * i.float32 / n.float32)) * 0.5'f32 * 1073741824.0'f32).int64
      else: gzLrCos[i] = round((1.0 + cos(PI * i.float64 / n.float64)) * 0.5 * 1073741824.0).int64
    discard gzFeset(alt)
  gzLrTabFertig = true

proc gzLrPlan(t: int): GzMul =
  ## Lernrate fuer adam_t = t (nach dem Hochzaehlen, wie warmup_t in train_worker.php).
  gzLrTab()
  if t < gzLrW:
    let num = gzLr0.m * max(1, t).int64                     # < 2^24 * 2^31
    let k = 61 - gzBits(uint64(num))
    var v = gzDivR(num shl k, gzLrW.int64)
    if gzKernRot: v = (v.float32 * 1.0000001'f32).int64
    return gzMulAus(v, gzLr0.e.int - k, false)
  if gzLrD > gzLrW:
    let p = min(max(t - gzLrS, 0), gzLrD - gzLrS)
    var f = gzLrMq + gzShr(((1'i64 shl 30) - gzLrMq) * gzLrCos[p], 30)    # Q30
    if gzKernRot: f = (f.float32 * 1.0000001'f32).int64
    if f <= 0: return GzMul(m: 0, e: 0)
    return gzMulAus(gzLr0.m * f, gzLr0.e.int - 30, false)
  gzLr0

proc gzLrSchritt(t: int, lr: cfloat): GzMul =
  ## Stufe 9: Lernrate aus dem Plan; Wache gegen den float-Wert aus PHP (ganzzahlig verglichen).
  if not gzLrDa:
    stderr.writeLine("[GZ] FATAL: Stufe 9 (LRPLAN) an, aber kein Plan gesetzt (cortex_gz_lr_plan nicht aufgerufen) - Abbruch")
    quit(5)
  if not gzLrVglFertig and getEnv("SNAI_GZ_LRVGL") == "1":
    # Pruefwerkzeug: Plan ueber alle Schritte gegen dieselbe Formel in float64 (lr0 und m als die uebergebenen float32);
    # f32 = die float64-Formel auf float32 gerundet (so kommt der Wert aus PHP). SNAI_GZ_LRVGL_ROT=1: Referenz +1e-5.
    gzLrVglFertig = true
    let rf = (if getEnv("SNAI_GZ_LRVGL_ROT") == "1": 1.0 + 1.0e-5 else: 1.0)
    let l0 = gzZuF32(gzLr0.m, gzLr0.e.int).float64
    let md = gzLrMin.float64
    let tE = max(gzLrD, gzLrW) + 100
    var mi, mf = 0.0
    for u in 1 .. tE:
      var r = l0
      if u < gzLrW: r = l0 * u.float64 / gzLrW.float64
      elif gzLrD > gzLrW:
        let pr = min(1.0, max(0.0, (u - gzLrS).float64 / (gzLrD - gzLrS).float64))
        r = l0 * (md + (1.0 - md) * 0.5 * (1.0 + cos(PI * pr)))
      r *= rf
      let q = gzLrPlan(u)
      let vi = q.m.float64 * pow(2.0, q.e.float64)
      mi = max(mi, abs(vi - r) / r)
      mf = max(mf, abs(r.float32.float64 - r) / r)
    stderr.writeLine("  > [GZ-LRVGL] lr-plan int " & $mi & " f32 " & $mf & " (Schritte 1.." & $tE & ")")
  result = gzLrPlan(t)
  if gzLrWacheRot < 0: gzLrWacheRot = (if getEnv("SNAI_GZ_LRWACHE_ROT") == "1": 1 else: 0)
  if gzLrWacheRot == 1 and result.m != 0: result.m = gzDivR(result.m * 4097, 4096)   # Rot-Probe der Wache: Plan +2^-12
  let P = gzMulF(lr)
  var abw: int64
  if result.m == 0 or P.m == 0:
    abw = (if result.m == P.m: 0'i64 else: high(int64))
  elif abs(result.e.int - P.e.int) > 1: abw = high(int64)
  else:
    let E = min(result.e.int, P.e.int)
    let a = result.m.int64 shl (result.e.int - E)
    let b = P.m.int64 shl (P.e.int - E)
    abw = gzDivR(abs(a - b) shl 30, b)
  if abw > (1'i64 shl 13):
    stderr.writeLine("[GZ] FATAL: Lernratenplan weicht vom PHP-Wert ab (adam_t=" & $t & ", Plan " &
                     $gzZuF32(result.m, result.e.int) & ", PHP " & $lr & ") - Parameter oder Formel auseinandergelaufen, Abbruch")
    quit(5)
  gzLrMaxAbw = max(gzLrMaxAbw, abw)

# =============================================================================================================
# Stufe 10 (2026-11-15): Checkpoint SNAI_V8. Schalter SNAI_I8_GZ_CKPT bzw. SNAI_I8_GANZ >= 10, nur fuers
# Schreiben. V8 = Kopf wie V7 (Flags-Feld immer da: Bit 0 Bindung, Bit 1 Embedding-Eingang), Rumpf wie V6/V7 bis auf die
# Momente der int8-Matrizen: je Moment [uint16 Zeilen][Zeilenskalen float32][Codes uint8], also genau die Darstellung
# im Speicher (QMoment) - Schreiben und Lesen kopieren nur, es wird nichts gerechnet. V6/V7 rechneten beim Schreiben
# Skala * Tabellenwert in float und kodierten beim Lesen neu (qmomStoreRow). Gain-Momente bleiben float32 (ihr Inhalt
# ist eine ganzzahlig gebildete 24-Bit-Mantisse, Stufe 3). Lesen von V8 geht immer (cortex_load_stream_i8).
# Pruefwerkzeug SNAI_GZ_IO_RUNDUNG=auf|ab|null: Speichern und Laden laufen in diesem Rundungsmodus (Rundweg-Probe).
proc getQMomentPtr(s: ptr CortexState, layer_idx, tensor_type: cint, is_v: bool): ptr QMoment
var gzV8Gemeldet = false
proc gzV8Schreibbar(s: ptr CortexState): bool =
  ## Stufe 10: V8 schreiben? Nur mit Schalter und wenn alle Matrix-Momente als 8-Bit-Code vorliegen; sonst V6/V7 wie
  ## bisher, mit Meldung (einmal je Prozess).
  if not gzAn(10): return false
  var grund = ""
  if s.quantAdam == 0: grund = "Momente nicht quantisiert (quantAdam=0)"
  else:
    var typen: seq[(int, int)] = @[(-1, 0)]
    if s.tiedEmbeddings == 0: typen.add((-1, 1))
    for l in 0 ..< s.numLayers.int:
      for t in 12 .. 17: typen.add((l, t))
    for (l, t) in typen:
      for isv in [false, true]:
        let q = getQMomentPtr(s, l.cint, t.cint, isv)
        if q.isNil or q.data.isNil or q.scale.isNil:
          grund = "Moment fehlt (Schicht " & $l & ", Typ " & $t & ")"
  if grund != "":
    if not gzV8Gemeldet:
      stderr.writeLine("  > [GZ] Stufe 10: SNAI_V8 nicht schreibbar (" & grund & ") - V6/V7 wie bisher")
      gzV8Gemeldet = true
    return false
  if gaStale: gpuAdamSyncHost()
  true

var gzIoAlt: cint = -1
proc gzIoRundung(an: bool) =
  ## Pruefwerkzeug SNAI_GZ_IO_RUNDUNG: Rundungsmodus fuer die Dauer von Speichern/Laden.
  let w = getEnv("SNAI_GZ_IO_RUNDUNG")
  if w == "": return
  if an:
    gzIoAlt = gzFeget()
    let m = (case w
             of "auf": gzFeAuf
             of "ab": gzFeAb
             of "null": gzFeNull
             else: gzFeNaechster)
    discard gzFeset(m)
  elif gzIoAlt >= 0:
    discard gzFeset(gzIoAlt)
    gzIoAlt = -1

# --- Schritt ------------------------------------------------------------------------------------------------

# --- Telemetrie (nur Protokoll, 2026-11-15, vor den Schlusslaeufen; angeregt durch den Befund von Jatai, github.com/kdilim/jatai) ---
# Alle SNAI_GZ_TELE_N Schritte (Vorgabe 1000, 0 = aus), nur mit Stufe 3 (ganzzahliger Adam): Anteil Nullgradienten je
# Matrix (vor dem Schritt), Anteil geaenderter int8-Codes je Matrix (durch den Schritt), Groesse des Restpfads je Schicht
# (Zeilen sind normiert, max|m| in [2^29, 2^30), also log2-Obergrenze e + 30; max/Mittel/min ueber die Positionen des
# letzten Fensters). Jede Zeile wird als EIN String geschrieben: train_cluster.php verschluckt Lesehappen, die genau "0"
# sind (bekannter Protokollfehler). Fliesst nicht in die Rechnung zurueck.
# SNAI_GZ_TELE_ROT=1 (Rot der Sonde, nur Probe): im Berichtsschritt Gradient q0 genullt und Schrittweite/Decay 0.
var gzTeleN = -1
var gzTeleRot = false
var gzTeleAct = 0
proc gzTeleLies() =
  if gzTeleN < 0:
    let s = getEnv("SNAI_GZ_TELE_N")
    gzTeleN = (if s == "": 1000 else: max(0, parseInt(s)))
    gzTeleRot = getEnv("SNAI_GZ_TELE_ROT") == "1"
proc gzProzent(z, n: int): string =
  ## z/n in Prozent, zwei Nachkommastellen, ganzzahlig gebildet (Protokoll)
  if n <= 0: return "-"
  let h = (z.int64 * 10000 + n.int64 div 2) div n.int64
  let r = h mod 100
  $(h div 100) & "." & (if r < 10: "0" else: "") & $r & "%"
proc gzNullAnteil(g: GzG): int =
  for i in 0 ..< g.rows * g.cols:
    if g.m[i] == 0: inc result
proc gzCodesKopie(q: QMatrix): seq[int8] =
  let n = q.rows.int * q.cols.int
  result = newSeq[int8](n)
  if n > 0: copyMem(addr result[0], q.data, n)
proc gzCodesAnders(q: QMatrix, alt: seq[int8]): int =
  for i in 0 ..< alt.len:
    if q.data[i] != alt[i]: inc result
proc gzRestGroesse(t: GzT, act: int): string =
  var mx = low(int)
  var mn = high(int)
  var su = 0
  var n = 0
  for p in 0 ..< act:
    if gzRowNull(t, p): continue
    let g = t.e[p].int + 30
    mx = max(mx, g)
    mn = min(mn, g)
    su += g
    inc n
  if n == 0: return "null"
  let mi = (if su >= 0: (su * 10 + n div 2) div n else: (su * 10 - n div 2) div n)   # Zehntel, gerundet
  $mx & "/" & (if mi < 0: "-" else: "") & $(abs(mi) div 10) & "." & $(abs(mi) mod 10) & "/" & $mn

# --- Rot-Proben der Schlussprobe (2026-11-15): SNAI_GZ_ROT_FLOAT = h | o | a baut im Trainingsschritt
# absichtlich EINE float-Rechnung ein, deren Ergebnis vom Rundungsmodus abhaengt: h im Hauptfaden (Schrittfaktor K des
# Adam ueber float32), o in der OpenMP-Schleife des Adam (Zeilenskala * (1 + 2^-23) in float32, je Faden), a in einem
# AVX-Weg (_mm256_mul_ps auf die Zeilenskalen des Embeddings, Hauptfaden). Ohne Variable ohne Wirkung.
{.emit: """
#include <immintrin.h>
__attribute__((target("avx2")))
void snai_gz_rot_avx(float* p, int n) {
  const __m256 f = _mm256_set1_ps(1.0000001f);
  int i = 0;
  for (; i + 8 <= n; i += 8) _mm256_storeu_ps(p + i, _mm256_mul_ps(_mm256_loadu_ps(p + i), f));
}
""".}
proc gzRotAvx(p: ptr cfloat, n: cint) {.importc: "snai_gz_rot_avx", nodecl.}
var gzRotFloat = '?'
proc gzRotLies(): char =
  if gzRotFloat == '?':
    let s = getEnv("SNAI_GZ_ROT_FLOAT")
    gzRotFloat = (if s.len == 1 and s[0] in {'h', 'o', 'a'}: s[0] else: '-')
    if gzRotFloat != '-':
      stderr.writeLine("  > [GZ] ROT-PROBE SNAI_GZ_ROT_FLOAT=" & $gzRotFloat & ": absichtlich eine float-Rechnung im Schritt")
  gzRotFloat

proc gzFwdBwd(state: ptr CortexState, t_in, t_tg, t_mask: ptr IntArray, act: cint, trainableOut: var cint): cfloat =
  ## Vorwaerts + Rueckwaerts; Gradienten in die alten float-Puffer (Stufe 1). Rueckgabe: mittlerer Loss.
  gzInit(state)
  let a = act.int
  gzTeleAct = a
  if gzAn(2) or gzAn(3):
    gzGNull(gz.gEmb)
    for l in 0 ..< gz.layers:
      for g in [gz.gq[l], gz.gk[l], gz.gv[l], gz.go[l], gz.gup[l], gz.gdown[l]]: gzGNull(g)
  if gzAn(4):
    for g in gz.gGain: gzGNull(g)
  if gzAn(8): gzGNull(gz.gLook)
  var normVglJetzt = false
  let nvt = getEnv("SNAI_GZ_NORMVGL")   # Schritt t (wie SNAI_GZ_ADAMVGL): Vergleich im Vorwaerts/Rueckwaerts von Schritt t
  if gzAn(4) and not gzNormVglAktiv and gzNormVglMeld.len == 0 and nvt != "" and
     parseInt(nvt) == state.adam_t.int + 1:
    gzNormVglAktiv = true
    normVglJetzt = true
  let svt = getEnv("SNAI_GZ_RESTVGL")   # Schritt t: Restpfad/SiLU/Embedding-Vergleich gegen float64
  var restVglJetzt = false
  if gzAn(8) and not gzRestVglAktiv and gzRestVglMeld.len == 0 and svt != "" and parseInt(svt) == state.adam_t.int + 1:
    gzRestVglAktiv = true
    restVglJetzt = true
  let lvt = getEnv("SNAI_GZ_LOGVGL")    # Schritt t: Logits/CE-Vergleich gegen float64
  var logVglJetzt = false
  if gzAn(7) and not gzLogVglAktiv and gzLogVglMeld.len == 0 and lvt != "" and parseInt(lvt) == state.adam_t.int + 1:
    gzLogVglAktiv = true
    logVglJetzt = true
  let avt = getEnv("SNAI_GZ_ATTVGL")    # Schritt t: Attention-Vergleich gegen float64
  var attVglJetzt = false
  if gzAn(6) and not gzAttVglAktiv and gzAttVglMeld.len == 0 and avt != "" and parseInt(avt) == state.adam_t.int + 1:
    gzAttVglAktiv = true
    attVglJetzt = true
  let rvt = getEnv("SNAI_GZ_ROPEVGL")   # Schritt t: RoPE-Vergleich gegen float64 im Vorwaerts/Rueckwaerts von Schritt t
  var ropeVglJetzt = false
  if gzAn(5) and not gzRopeVglAktiv and gzRopeVglMeld.len == 0 and rvt != "" and parseInt(rvt) == state.adam_t.int + 1:
    gzRopeVglAktiv = true
    ropeVglJetzt = true
  var kernJetzt = false
  if not gzKernFertig and getEnv("SNAI_GZ_KERN") == "1":
    gzKernFertig = true
    kernJetzt = true
    gzKernAktiv = true
    gzKernRot = getEnv("SNAI_GZ_KERN_ROT") == "1"
    gzKernRotTab = getEnv("SNAI_GZ_KERN_ROT") == "2"
    gzKernRotExp = gzKernRotTab
  # Vorwaerts
  gzEmbFwd(state, t_in, a, gz.x)
  for l in 0 ..< gz.layers:
    template L: untyped = gz.ly[l]
    gzCopy(L.h1, gz.x, a)
    gzNormFwd(gz.x, L.n1, state.rms_att_weights[l], a)
    gzMatFwd(state.w_q_q8[l], L.n1, L.q, a)
    gzMatFwd(state.w_k_q8[l], L.n1, gz.tmp, a)
    gzRope(gz.tmp, a, false, state)
    gzQuantKV(gz.tmp, a, L.k8, L.ksM, L.ksE, "k")
    gzMatFwd(state.w_v_q8[l], L.n1, gz.tmp, a)
    gzQuantKV(gz.tmp, a, L.v8, L.vsM, L.vsE, "v")
    gzRope(L.q, a, false, state)
    gzAttFwd(state, L, a, L.ao)
    gzMatFwd(state.w_o_q8[l], L.ao, gz.tmp, a)
    gzAdd(gz.x, gz.tmp, a)
    gzCopy(L.h2, gz.x, a)
    gzNormFwd(gz.x, L.n2, state.rms_ffn_weights[l], a)
    gzMatFwd(state.w_up_q8[l], L.n2, L.u, a)
    gzSiluFwd(state, L.u, L.s, a)
    gzMatFwd(state.w_down_q8[l], L.s, gz.tmp, a)
    gzAdd(gz.x, gz.tmp, a)
  gzCopy(gz.hf, gz.x, a)
  gzNormFwd(gz.x, gz.nf, state.rms_final_weight, a)
  var loss: cfloat
  var cnt: cint
  gzLogits(state, t_tg, t_mask, a, loss, cnt)
  # Rueckwaerts
  gzMatBw(state, state.w_out_q8, state.g_w_out, gz.gEmb, gz.lg, gz.nf, gz.dt, a, false)
  gzNormBw(gz.dt, gz.hf, state.rms_final_weight, state.g_rms_final_weight, 0, a, gz.dx, false)
  for l in countdown(gz.layers - 1, 0):
    template L: untyped = gz.ly[l]
    gzMatBw(state, state.w_down_q8[l], state.g_w_down[l], gz.gdown[l], gz.dx, L.s, gz.dffn, a, false)
    gzSiluBw(L.u, gz.dffn, a)
    gzMatBw(state, state.w_up_q8[l], state.g_w_up[l], gz.gup[l], gz.dffn, L.n2, gz.dt, a, false)
    gzNormBw(gz.dt, L.h2, state.rms_ffn_weights[l], state.g_rms_ffn_weights[l], 2 + 2 * l, a, gz.dx, true)
    gzMatBw(state, state.w_o_q8[l], state.g_w_o[l], gz.go[l], gz.dx, L.ao, gz.dt, a, false)
    var dq = gzAlloc(a, gz.dim)
    var dk = gzAlloc(a, gz.dim)
    var dv = gzAlloc(a, gz.dim)
    gzAttBw(state, L, a, gz.dt, dq, dk, dv)
    gzRope(dq, a, true, state)
    gzRope(dk, a, true, state)
    gzMatBw(state, state.w_q_q8[l], state.g_w_q[l], gz.gq[l], dq, L.n1, gz.tmp, a, false)
    gzMatBw(state, state.w_k_q8[l], state.g_w_k[l], gz.gk[l], dk, L.n1, gz.tmp, a, true)
    gzMatBw(state, state.w_v_q8[l], state.g_w_v[l], gz.gv[l], dv, L.n1, gz.tmp, a, true)
    for t in [dq, dk, dv]:
      deallocShared(t.m); deallocShared(t.e)
    gzNormBw(gz.tmp, L.h1, state.rms_att_weights[l], state.g_rms_att_weights[l], 1 + 2 * l, a, gz.dx, true)
  gzEmbBw(state, t_in, a, gz.dx)
  if gzAn(2) and not gzAn(3):
    # Kleber Matmul ganzzahlig -> alter float-Adam: GZ-Gradienten in die float-Puffer (w_out wie im alten Pfad
    # getrennt; die Nachbereitung fuehrt g_w_out und g_embeddings zusammen).
    gzGZuFloat(gz.gEmb, state.g_w_out.data)
    for l in 0 ..< gz.layers:
      gzGZuFloat(gz.gq[l], state.g_w_q[l].data); gzGZuFloat(gz.gk[l], state.g_w_k[l].data)
      gzGZuFloat(gz.gv[l], state.g_w_v[l].data); gzGZuFloat(gz.go[l], state.g_w_o[l].data)
      gzGZuFloat(gz.gup[l], state.g_w_up[l].data); gzGZuFloat(gz.gdown[l], state.g_w_down[l].data)
  if gzAn(3) and not gzAn(2):
    # Kleber float-Matmul -> ganzzahliger Adam: float-Gradienten (oben je Schritt genullt) zeilenweise bitgenau
    # zerlegt in die GZ-Puffer; w_out in gz.gEmb, den Lookup-Anteil fuegt gzOptSchritt (gzEmbZusammen) hinzu.
    gzFloatZuG(state.g_w_out.data, gz.gEmb)
    for l in 0 ..< gz.layers:
      gzFloatZuG(state.g_w_q[l].data, gz.gq[l]); gzFloatZuG(state.g_w_k[l].data, gz.gk[l])
      gzFloatZuG(state.g_w_v[l].data, gz.gv[l]); gzFloatZuG(state.g_w_o[l].data, gz.go[l])
      gzFloatZuG(state.g_w_up[l].data, gz.gup[l]); gzFloatZuG(state.g_w_down[l].data, gz.gdown[l])
  if gzAn(8) and not gzAn(3):
    # Kleber Embedding-Rueckwaerts ganzzahlig -> alter float-Adam: Lookup-Anteil in g_embeddings (oben genullt, von
    # Stufe 8 sonst nicht beschrieben); die Nachbereitung addiert g_w_out wie bisher.
    gzGZuFloat(gz.gLook, state.g_embeddings.data)
  if gzAn(4) and not gzAn(3):
    # Kleber Norm ganzzahlig -> alter float-Adam: Gain-Gradienten in die float-Puffer.
    gzGZuFloat(gz.gGain[0], state.g_rms_final_weight)
    for l in 0 ..< gz.layers:
      gzGZuFloat(gz.gGain[1 + 2 * l], state.g_rms_att_weights[l])
      gzGZuFloat(gz.gGain[2 + 2 * l], state.g_rms_ffn_weights[l])
  if restVglJetzt:
    gzRestVglAktiv = false
    for z in gzRestVglMeld: stderr.writeLine("  > [GZ-RESTVGL] t=" & svt & " " & z)
  if logVglJetzt:
    gzLogVglAktiv = false
    for z in gzLogVglMeld: stderr.writeLine("  > [GZ-LOGVGL] t=" & lvt & " " & z)
  if attVglJetzt:
    gzAttVglAktiv = false
    for z in gzAttVglMeld: stderr.writeLine("  > [GZ-ATTVGL] t=" & avt & " " & z)
  if ropeVglJetzt:
    gzRopeVglAktiv = false
    for z in gzRopeVglMeld: stderr.writeLine("  > [GZ-ROPEVGL] t=" & rvt & " " & z)
  if normVglJetzt:
    gzNormVglAktiv = false
    for z in gzNormVglMeld: stderr.writeLine("  > [GZ-NORMVGL] t=" & nvt & " " & z)
  if kernJetzt and gzAn(9) and gzLrDa:
    # Bausteinprobe Stufe 9: Tabelle neu und Plan ueber alle Schritte, einmal unter "aufwaerts", einmal "naechster"
    let tE = max(gzLrD, gzLrW) + 100
    var a1 = newSeq[GzMul](tE + 1)
    gzKernRotLr = gzKernRotTab
    gzLrTabFertig = false
    discard gzFeset(gzFeAuf)
    for t in 1 .. tE: a1[t] = gzLrPlan(t)
    discard gzFeset(gzFeNaechster)
    gzLrTabFertig = false
    var nd = 0
    for t in 1 .. tE:
      let b = gzLrPlan(t)
      if b.m != a1[t].m or b.e != a1[t].e: inc nd
    gzKernMeld.add("lr-plan " & (if nd == 0: "gleich" else: "ABWEICHEND (" & $nd & ")") & " (Schritte 1.." & $tE & ")")
    gzKernRotLr = false
    gzLrTabFertig = false
  if kernJetzt:
    gzKernAktiv = false
    gzKernRot = false
    if gzKernRotTab:
      gzKernRotTab = false
      gzRopeHs = 0       # Rot-Tabellen verwerfen
      gzKernRotExp = false
      gzExp2Fertig = false
    for z in gzKernMeld: stderr.writeLine("  > [GZ-KERN] ", z)
    gzKernMeld.setLen(0)
  trainableOut = cnt
  if gzAn(7): return gzVerlustMittel             # Stufe 7: Mittel ganzzahlig gebildet (kein float-Teilen)
  return loss / max(1, cnt).cfloat

# --- Gradientenvergleich (Pruefwerkzeug, SNAI_GZ_VERGL=1): erster Schritt alter Pfad gegen GZ, gleiche Charge ----
# SNAI_GZ_VERGL_ROT=1 verfaelscht im GZ-Ergebnis g_w_o[0] um +10 % (Rot-Probe des Werkzeugs).
var gzVerglFertig = false
proc gzGradListe(state: ptr CortexState): seq[(string, ptr FloatArray, int)] =
  let d = state.hiddenDim.int
  result.add(("g_embeddings", state.g_embeddings.data, state.g_embeddings.rows.int * state.g_embeddings.cols.int))
  result.add(("g_w_out", state.g_w_out.data, state.g_w_out.rows.int * state.g_w_out.cols.int))
  result.add(("g_rms_final", state.g_rms_final_weight, d))
  for l in 0 ..< state.numLayers.int:
    for (n, m) in [("g_w_q", state.g_w_q[l]), ("g_w_k", state.g_w_k[l]), ("g_w_v", state.g_w_v[l]),
                   ("g_w_o", state.g_w_o[l]), ("g_w_up", state.g_w_up[l]), ("g_w_down", state.g_w_down[l])]:
      result.add((n & "[" & $l & "]", m.data, m.rows.int * m.cols.int))
    result.add(("g_rms_att[" & $l & "]", state.g_rms_att_weights[l], d))
    result.add(("g_rms_ffn[" & $l & "]", state.g_rms_ffn_weights[l], d))

proc gzVergleich(state: ptr CortexState, t_in, t_tg, t_mask: ptr IntArray, act: cint, lr: cfloat,
                 trainableOut: var cint): cfloat =
  ## Alter gebuendelter Pfad und GZ auf derselben Charge; meldet je Tensor rel. L2-Abstand und Kosinus.
  ## Danach gelten die GZ-Gradienten (der Schritt laeuft weiter wie ohne Vergleich).
  let gl = gzGradListe(state)
  var tcA: cint = 0
  let lossA = trainStepI8Batched(state, t_in, t_tg, t_mask, act, lr, tcA)
  var alt = newSeq[seq[cfloat]](gl.len)
  for i, g in gl:
    alt[i] = newSeq[cfloat](g[2])
    for j in 0 ..< g[2]:
      alt[i][j] = g[1][j]
      g[1][j] = 0.0
  result = gzFwdBwd(state, t_in, t_tg, t_mask, act, trainableOut)
  if gzAn(2) and gzAn(3):
    # Nur fuer den Vergleich: Ganzzahl-Gradienten in die float-Puffer (der Schritt selbst liest gz.*)
    gzGZuFloat(gz.gEmb, state.g_w_out.data)
    for l in 0 ..< gz.layers:
      gzGZuFloat(gz.gq[l], state.g_w_q[l].data); gzGZuFloat(gz.gk[l], state.g_w_k[l].data)
      gzGZuFloat(gz.gv[l], state.g_w_v[l].data); gzGZuFloat(gz.go[l], state.g_w_o[l].data)
      gzGZuFloat(gz.gup[l], state.g_w_up[l].data); gzGZuFloat(gz.gdown[l], state.g_w_down[l].data)
  if gzAn(8) and gzAn(3): gzGZuFloat(gz.gLook, state.g_embeddings.data)
  if gzAn(4) and gzAn(3):
    gzGZuFloat(gz.gGain[0], state.g_rms_final_weight)
    for l in 0 ..< gz.layers:
      gzGZuFloat(gz.gGain[1 + 2 * l], state.g_rms_att_weights[l])
      gzGZuFloat(gz.gGain[2 + 2 * l], state.g_rms_ffn_weights[l])
  if getEnv("SNAI_GZ_VERGL_ROT") == "1":
    for i, g in gl:
      if g[0] == "g_w_o[0]":
        for j in 0 ..< g[2]: g[1][j] = g[1][j] * 1.1'f32
  stderr.writeLine("  > [GZ-VERGL] Loss alt ", lossA, " GZ ", result, " | Zaehler alt ", tcA, " GZ ", trainableOut)
  for i, g in gl:
    var na, nd, nb, ab: float64
    for j in 0 ..< g[2]:
      let a = alt[i][j].float64
      let b = g[1][j].float64
      na += a * a
      nb += b * b
      nd += (a - b) * (a - b)
      ab += a * b
    let rel = (if na > 0.0: sqrt(nd / na) else: (if nb > 0.0: 1.0 else: 0.0))
    let cs = (if na > 0.0 and nb > 0.0: ab / sqrt(na * nb) else: 1.0)
    stderr.writeLine("  > [GZ-VERGL] ", g[0], " relL2 ", $rel, " cos ",
                     $cs, " |alt| ", $sqrt(na))

# =============================================================================================================
# Stufe 3 (2026-11-15): Clip-Norm, Adam der Matrizen (8-Bit-Log-Momente) und der Gains ganzzahlig.
# =============================================================================================================
# Semantik wie clipGlobalGradientNorm + applyGlobalAdamUpdateI8/adamRowFloatI8 + adamStep (cortex.nim), ohne
# Gleitkommarechnung:
# - Gradient je Element = g * S mit S = 1/max(Norm, N), N = trainable_count (alt: Clip auf N/Norm, danach / N;
#   fuer N >= 1 derselbe Wert). N = 0: kein Adam-Schritt, Zeilen werden nur neu gerundet (wie alt).
# - Momente: Log-Code per Tabelle (Q38) in Festkomma je Zeile entpackt; m' = b1 m + (1-b1) g,
#   v' = b2 v + (1-b2) g^2 mit b1, b2 = die float32-Werte 0.9/0.999 als exakte Q24-Brueche.
#   Schritt = K * m'/(sqrt(v') + eps*sqrt(b2t)), K = lr*sqrt(b2t)/b1t (algebraisch gleich lr*m_hat/(sqrt(v_hat)+eps));
#   b1t, b2t als Q30-Potenzen, Wurzel und Division ganzzahlig.
# - Gewicht: Ziel = q*Skala - Schritt - lr*wd*q*Skala in Festkomma je Zeile; neue Skala = max/127 als 24-Bit-Mantisse
#   (float32-Ablage exakt); Runden stochastisch (Hash-Bits, P(auf) = Rest) bzw. zum Naechsten (SNAI_I8_REST=0).
# - Momente zurueck in den Log-Code: log2 per Tabelle (Q32) mit linearer Interpolation; stochastisch auf den Code
#   (SNAI_I8_MOM_SR wie bisher). v-Klemme wie qmomStoreRow.
# - Gains: Festkomma mit Exponent je Tensor (Mantisse < 2^24, float32-Ablage exakt). Ihre Momente m, v bleiben in der
#   float32-Ablage, gelesen als Mantisse (24 Bit) mit Exponent je Element (wie die 8-Bit-Log-Momente ein Format mit
#   Exponent je Element) und ganzzahlig gerechnet.
# - Konstanten-Tabellen einmal in float64 berechnet, ausdruecklich im Rundungsmodus "naechster" (erlaubte Ausnahme a).
# - Protokollwerte (last_grad_norm, Gruppenanteile) werden aus den Ganzzahlen bitweise als float32 gebaut.

proc gzOmpNum(): cint {.importc: "omp_get_thread_num", header: "<omp.h>".}
proc gzOmpMax(): cint {.importc: "omp_get_max_threads", header: "<omp.h>".}

proc gzFeAlle(m: cint) =
  ## Rundungsmodus im Hauptfaden und in jedem OpenMP-Faden setzen (Bausteinprobe des parallelen Adam).
  discard gzFeset(m)
  let n = max(1, gzOmpMax().int)
  {.push checks: off.}
  for t in 0 || (n - 1):
    discard gzFeset(m)
  {.pop.}

var gzTMm, gzTMs: array[128, int64]   # |m|-Code -> 24-Bit-Mantisse, Rechtsschub auf das Zeilenraster (Skala.e - 35)
var gzTVm, gzTVs: array[256, int64]   # v-Code ebenso
var gzLg: array[1025, int64]     # log2(1 + i/1024) in Q32
var gzFM, gzFV: int64            # 126 bzw. 254 / log2(1e8) in Q21
var gzTabFertig = false
proc gzTabellen() =
  if gzTabFertig: return
  let alt = gzFeget()
  discard gzFeset(gzFeNaechster)
  let lg = ln(1.0e8)
  template eintrag(x: float64, mm, ss: var int64) =
    var k: int
    let f = frexp(x, k)                       # x = f * 2^k, f in [0.5, 1)
    var m = round(f * 16777216.0).int64       # 24 Bit
    if m >= 16777216'i64:
      m = m shr 1
      inc k
    mm = m
    ss = -35 - (k - 24)                       # Wert = m * 2^(k-24); Zeilenraster 2^(Skala.e - 35)
  gzTMm[0] = 0
  gzTMs[0] = 0
  for q in 1 .. 127: eintrag(exp(((q - 1).float64 / 126.0 - 1.0) * lg), gzTMm[q], gzTMs[q])
  gzTVm[0] = 0
  gzTVs[0] = 0
  for q in 1 .. 255: eintrag(exp(((q - 1).float64 / 254.0 - 1.0) * lg), gzTVm[q], gzTVs[q])
  for i in 0 .. 1024: gzLg[i] = round(log2(1.0 + i.float64 / 1024.0) * 4294967296.0).int64
  gzFM = round(126.0 / log2(1.0e8) * 2097152.0).int64
  gzFV = round(254.0 / log2(1.0e8) * 2097152.0).int64
  discard gzFeset(alt)
  gzTabFertig = true

proc gzLog2Q(x: uint64): int64 {.inline.} =
  ## log2(x) in Q32 fuer x > 0 (Tabelle + lineare Interpolation; Fehler < 2e-7).
  let b = gzBits(x) - 1
  let f = (if b >= 30: x shr (b - 30) else: x shl (30 - b))   # [2^30, 2^31)
  let fr = f - (1'u64 shl 30)
  let i = int(fr shr 20)
  let rest = int64(fr and ((1'u64 shl 20) - 1'u64))
  let a = gzLg[i]
  result = (b.int64 shl 32) + a + (((gzLg[i + 1] - a) * rest) shr 20)

proc gzZuF32(m: int64, e: int): cfloat =
  ## m * 2^e als float32 nur ueber Bitoperationen (Mantisse auf 24 Bit gerundet, Halbe weg von null).
  if m == 0: return 0.0'f32
  var a = gzAbsU(m)
  var ee = e
  let k = gzBits(a) - 24
  if k > 0:
    a = uint64(gzShr(int64(a), k))
    ee += k
    if a >= (1'u64 shl 24):
      a = a shr 1
      inc ee
  elif k < 0:
    a = a shl (-k)
    ee += k
  let be = ee + 150
  var bits: uint32
  if be >= 255: bits = 0x7F7FFFFF'u32
  elif be >= 1: bits = (uint32(be) shl 23) or uint32(a and 0x7FFFFF'u64)
  else:
    let s = 1 - be
    bits = (if s >= 25: 0'u32 else: uint32(gzShr(int64(a), s)))
  if m < 0: bits = bits or 0x80000000'u32
  cast[cfloat](bits)

proc gzUeber(a: uint64, e: int, lim: uint64): bool {.inline.} =
  ## a * 2^e > lim ?
  if a == 0'u64: return false
  if e >= 0:
    if gzBits(a) + e > 63: return true
    return (a shl e) > lim
  let s = -e
  if s >= 64: return false
  if gzBits(lim) + s > 63: return false
  a > (lim shl s)

proc gzSat(x: int64, s: int, satz: var int): int64 {.inline.} =
  ## gzShr mit Saettigung bei +-2^61 (Linksschub), Zaehler fuers Protokoll.
  if s < 0 and x != 0 and gzBits(gzAbsU(x)) - s > 61:
    inc satz
    return (if x < 0: -(1'i64 shl 61) else: 1'i64 shl 61)
  gzShr(x, s)

proc gzMulQ24(x: int64, c: int64): int64 {.inline.} =
  ## round(x * c / 2^24) fuer |x| < 2^62, 0 <= c < 2^24, ohne 128-Bit-Zwischenwert.
  let a = gzAbsU(x)
  let r = (a shr 24) * uint64(c) + (((a and 0xFFFFFF'u64) * uint64(c) + (1'u64 shl 23)) shr 24)
  (if x < 0: -int64(r) else: int64(r))

proc gzFloorDiv(a, b: int64): int64 {.inline.} =
  ## floor(a / b), b > 0.
  result = a div b
  if (a mod b) < 0: dec result

var gzSalt: uint64
proc gzHash(x: uint64, row, c: int, art: uint64): uint64 {.inline.} =
  ## 32 Zufallsbits (wie restSrU/srUniform: splitmix64 ueber Wert, Zeile, Spalte, Schritt).
  var h = x xor (uint64(row) shl 32) xor (uint64(c) shl 12) xor gzSalt xor art
  h = h + 0x9E3779B97F4A7C15'u64
  h = (h xor (h shr 30)) * 0xBF58476D1CE4E5B9'u64
  h = (h xor (h shr 27)) * 0x94D049BB133111EB'u64
  h = h xor (h shr 31)
  h shr 32
const GZ_ART_W = 0xA0761D6478BD642F'u64
const GZ_ART_M = 0x5851F42D4C957F2D'u64
const GZ_ART_V = 0x2D358DCCAA6C78A5'u64

proc gzAdamQ(am: uint64, eM: int, vx: uint64, eV: int, eps, k: GzMul, om: var int64, oe: var int) {.inline.} =
  ## |Schritt| = K * am*2^eM / (sqrt(vx*2^eV) + eps); Ergebnis om * 2^oe (om < 2^57).
  om = 0
  oe = 0
  if am == 0'u64 or k.m == 0: return
  var r = 0'u64
  var es = eps.e.int
  if vx != 0'u64:
    let msb = gzBits(vx) - 1
    var s = 60 - msb
    if ((eV - s) and 1) != 0: inc s
    let x = (if s >= 0: vx shl s else: vx shr (-s))
    r = gzIsqrt(x)
    es = (eV - s) div 2
  var ep = 0'u64
  if eps.m != 0:
    let d = eps.e.int - es
    if d >= 0:
      ep = (if gzBits(uint64(eps.m)) + d > 62: 1'u64 shl 62 else: uint64(eps.m) shl d)
    else:
      ep = uint64(gzShr(eps.m, -d))
  var dd = r + ep
  if dd > (1'u64 shl 62): dd = 1'u64 shl 62
  if dd == 0'u64: dd = 1'u64
  let ka = 63 - gzBits(am)
  let an = am shl ka                      # [2^62, 2^63)
  let q = an div dd
  let sq = max(0, gzBits(q) - 32)
  let q32 = gzShr(int64(q), sq)
  om = q32 * k.m
  oe = eM - ka - es + sq + k.e.int

proc gzMomKodiere(q: QMoment, r: int, x: ptr UncheckedArray[int64], n: int, ex: int, signed, sr, vKl: bool) =
  ## Zeile x (Wert = x * 2^ex) als 8-Bit-Log-Code mit Skala = max|x| (24-Bit-Mantisse, float32 exakt).
  let off = r * n
  var mx = 0'u64
  for c in 0 ..< n:
    let a = gzAbsU(x[c])
    if a > mx: mx = a
  if mx == 0'u64:
    q.scale[r] = 0.0'f32
    for c in 0 ..< n: q.data[off + c] = 0'u8
    return
  let sk = gzMulAus(int64(mx), ex, false)
  q.scale[r] = gzZuF32(sk.m, sk.e.int)
  let ls = gzLog2Q(uint64(sk.m)) + (sk.e.int64 shl 32)
  let f = (if signed: gzFM else: gzFV)
  let st = (if signed: 126'i64 else: 254'i64)
  let qmax = (if signed: 127'i64 else: 255'i64)
  let art = (if signed: GZ_ART_M else: GZ_ART_V)
  for c in 0 ..< n:
    let ax = gzAbsU(x[c])
    var code = 0'i64
    if ax != 0'u64:
      var L = gzLog2Q(ax) + (ex.int64 shl 32) - ls
      if L < -(28'i64 shl 32): L = -(28'i64 shl 32)
      let r32 = (st shl 32) + ((L * f) shr 21)
      if r32 <= 0:
        code = (if (not signed) and vKl: 1'i64 else: 0'i64)
      else:
        let u = (if sr: int64(gzHash(uint64(cast[uint64](x[c]) and 0xFFFFFFFF'u64), r, c, art)) else: 1'i64 shl 31)
        code = 1 + ((r32 + u) shr 32)
        if code > qmax: code = qmax
    if signed:
      var b = uint8(code) and 0x7F'u8
      if x[c] < 0 and code != 0: b = b or 0x80'u8
      q.data[off + c] = b
    else:
      q.data[off + c] = uint8(code)

type GzAdamArgs = object
  qw: QMatrix
  mq, vq: ptr QMoment
  g: GzG
  sM: int64
  sE: int
  b1, b1c, b2, b2c: int64        # Q24
  k, eps, lw: GzMul              # Schrittfaktor, eps*sqrt(b2t), lr*wd (m = 0: kein Decay)
  upd, srW, srM, srV, vKl, rot: bool
  scr: ptr UncheckedArray[int64]
  scrN: int
  satz: ptr UncheckedArray[int64]   # Saettigungen je Faden (Protokoll)

proc gzAdamZeile(a: ptr GzAdamArgs, r: int) {.exportc: "snai_gz_adam_zeile", cdecl.} =
  ## Eine Zeile einer Matrix: Momente, Schritt, Decay, neue Skala, Runden, Momente zurueck in 8 Bit.
  let C = a.qw.cols.int
  let off = r * C
  let tid = max(0, gzOmpNum().int)
  let sb = cast[ptr UncheckedArray[int64]](addr a.scr[tid * a.scrN])
  let mm = cast[ptr UncheckedArray[int64]](addr sb[0])
  let vv = cast[ptr UncheckedArray[int64]](addr sb[C])
  let gg = cast[ptr UncheckedArray[int64]](addr sb[2 * C])
  let dm = cast[ptr UncheckedArray[int64]](addr sb[3 * C])
  let de = cast[ptr UncheckedArray[int64]](addr sb[4 * C])
  let tt = cast[ptr UncheckedArray[int64]](addr sb[5 * C])
  var satz = 0
  # --- Gradient der Zeile (g * S) exakt: |g.m| < 2^30, |S.m| < 2^24 ---
  var ggx = 0'u64
  var eg = 0
  if a.upd:
    for c in 0 ..< C:
      gg[c] = a.g.m[off + c].int64 * a.sM
      let v = gzAbsU(gg[c])
      if v > ggx: ggx = v
    eg = a.g.e[r].int + a.sE
  else:
    for c in 0 ..< C: gg[c] = 0
  let hasG = ggx != 0'u64
  # Uebersprungen (alt: |grad| > 9999 oder N = 0): tt[c] = 1
  var anyUpd = false
  if not a.upd:
    for c in 0 ..< C: tt[c] = 1
  elif hasG and gzUeber(ggx, eg, 9999'u64):
    for c in 0 ..< C:
      tt[c] = (if gzUeber(gzAbsU(gg[c]), eg, 9999'u64): 1'i64 else: 0'i64)
      if tt[c] == 0: anyUpd = true
  else:
    for c in 0 ..< C: tt[c] = 0
    anyUpd = true
  # --- Momente entpacken: mm bei em, vv bei ev (<= 2^60; Tabelle 24 Bit relativ genau) ---
  let smq = gzMulF(a.mq[].scale[r])
  let svq = gzMulF(a.vq[].scale[r])
  let em = smq.e.int - 35
  let ev = svq.e.int - 35
  var hasM = false
  var hasV = false
  for c in 0 ..< C:
    let b = a.mq[].data[off + c]
    let mag = int(b and 0x7F'u8)
    var x = (if mag == 0 or smq.m == 0: 0'i64 else: gzShr(gzTMm[mag] * smq.m, gzTMs[mag].int))
    if (b and 0x80'u8) != 0'u8: x = -x
    mm[c] = x
    if x != 0: hasM = true
    let bv = a.vq[].data[off + c].int
    vv[c] = (if bv == 0 or svq.m == 0: 0'i64 else: gzShr(gzTVm[bv] * svq.m, gzTVs[bv].int))
    if vv[c] != 0: hasV = true
  # --- m' = m + (1-b1)(g - m)  (= b1 m + (1-b1) g), Werte bei EM, <= 2^60 ---
  let topG = (if hasG: eg + gzBits(ggx) else: 0)
  let EM = (if hasG and hasM: max(em, topG - 60) elif hasG: topG - 60 else: em)
  for c in 0 ..< C:
    let mA = gzShr(mm[c], EM - em)
    if tt[c] != 0: mm[c] = mA
    else: mm[c] = mA + gzMulQ24(gzShr(gg[c], EM - eg) - mA, a.b1c)
  # --- v' = v + (1-b2)(g^2 - v); g^2 je Element mit 31-Bit-Mantisse (dm/de als Zwischenspeicher) ---
  var topS = low(int)
  if hasG:
    for c in 0 ..< C:
      let s = max(0, gzBits(gzAbsU(gg[c])) - 31)
      let g31 = gzShr(gg[c], s)
      dm[c] = g31 * g31
      de[c] = int64(2 * (eg + s))
      if dm[c] != 0: topS = max(topS, de[c].int + gzBits(uint64(dm[c])))
  let hasS = topS != low(int)
  let EV = (if hasS and hasV: max(ev, topS - 60) elif hasS: topS - 60 else: ev)
  for c in 0 ..< C:
    let vA = gzShr(vv[c], EV - ev)
    if tt[c] != 0 or not hasS: vv[c] = vA
    else: vv[c] = vA + gzMulQ24(gzShr(dm[c], EV - de[c].int) - vA, a.b2c)
  # --- Schritt je Element ---
  for c in 0 ..< C:
    if tt[c] != 0 or mm[c] == 0:
      dm[c] = 0
      de[c] = 0
    else:
      var om: int64
      var oe: int
      gzAdamQ(gzAbsU(mm[c]), EM, uint64(vv[c]), EV, a.eps, a.k, om, oe)
      dm[c] = (if mm[c] < 0: -om else: om)
      de[c] = oe.int64
  # --- Gewicht: Ziel in Festkomma (Exponent Er) ---
  let W = gzMulF(a.qw.scale[r])
  var Er: int
  if W.m != 0: Er = W.e.int - 24
  else:
    var top = low(int)
    for c in 0 ..< C:
      if dm[c] != 0: top = max(top, de[c].int + gzBits(gzAbsU(dm[c])))
    Er = (if top == low(int): 0 else: top - 55)
  var tmx = 0'u64
  for c in 0 ..< C:
    let q0 = a.qw.data[off + c].int64
    var t = (if W.m != 0: (q0 * W.m) shl 24 else: 0'i64)
    if tt[c] == 0:
      if dm[c] != 0: t -= gzSat(dm[c], Er - de[c].int, satz)
      if a.lw.m != 0 and W.m != 0 and q0 != 0: t -= gzShr(q0 * W.m * a.lw.m, -24 - a.lw.e.int)
    if a.rot and c == 0: t = (t.float32 * 1.0000001'f32).int64     # Rot-Probe der Bausteinprobe (float!)
    tt[c] = t
    let v = gzAbsU(t)
    if v > tmx: tmx = v
  # --- neue Skala, Runden ---
  if tmx == 0'u64:
    for c in 0 ..< C: a.qw.data[off + c] = 0
  else:
    let ns = gzMulAus(int64(tmx), Er, true)
    let kk = Er - ns.e.int
    let den = (if kk >= 0: ns.m else: ns.m shl (-kk))
    let shd = max(0, gzBits(uint64(den)) - 30)
    for c in 0 ..< C:
      let num = (if kk >= 0: tt[c] shl kk else: tt[c])
      var q: int64
      if a.srW:
        let q0 = gzFloorDiv(num, den)
        let rest = num - q0 * den
        let u = int64(gzHash(uint64(cast[uint64](tt[c]) and 0xFFFFFFFF'u64), r, c, GZ_ART_W))
        q = q0 + (if u * (den shr shd) < ((rest shr shd) shl 32): 1'i64 else: 0'i64)
      else:
        q = gzDivR(num, den)
      if q > 127: q = 127
      elif q < -128: q = -128
      a.qw.data[off + c] = q.int8
    a.qw.scale[r] = gzZuF32(ns.m, ns.e.int)
  # --- Momente zurueck (nur wenn sich eines geaendert hat, wie rowTouched) ---
  if anyUpd:
    gzMomKodiere(a.mq[], r, mm, C, EM, true, a.srM, false)
    gzMomKodiere(a.vq[], r, vv, C, EV, false, a.srV, a.vKl)
  if satz > 0: a.satz[tid] += satz.int64
proc gzAdamZeileC(a: ptr GzAdamArgs, r: int) {.importc: "snai_gz_adam_zeile", cdecl.}

proc gzGainSchritt(w, mA, vA, gA: ptr FloatArray, n: int, a: ptr GzAdamArgs, gT: ptr GzT = nil) =
  ## Adam eines Gain-Tensors (ohne Decay, wie adamStep mit wd = 0), seriell.
  var dm = newSeq[int64](n)
  var de = newSeq[int](n)
  var et = low(int)
  for c in 0 ..< n:
    let x = gzMulF(w[c])
    if x.m != 0 and x.e.int > et: et = x.e.int
  if et == low(int): et = -23
  var satz = 0
  for c in 0 ..< n:
    if not a.upd: continue
    var gv: int64
    var ge: int
    if gT.isNil:
      let gb = cast[uint32](gA[c])
      if ((gb shr 23) and 0xFF'u32) == 255'u32: continue      # NaN/Inf im float-Kleber: uebersprungen wie in adamStep
      let gm = gzMulF(gA[c])
      gv = gzShr(gm.m * a.sM, 24)
      ge = gm.e.int + a.sE + 24
    else:
      # Stufe 4: Gradient aus dem Ganzzahlpuffer (Mantisse <= 2^30, Exponent je Tensor), je Element auf 24 Bit
      let pr = gT[].m[c].int64 * a.sM
      let s = max(0, gzBits(gzAbsU(pr)) - 24)
      gv = gzShr(pr, s)
      ge = gT[].e[0].int + a.sE + s
    if gzUeber(gzAbsU(gv), ge, 9999'u64): continue
    let mo = gzMulF(mA[c])
    let vo = gzMulF(vA[c])
    let t1 = mo.m * a.b1
    let y1 = mo.e.int - 24
    let t2 = gv * a.b1c
    let y2 = ge - 24
    let E = (if t1 == 0: y2 elif t2 == 0: y1 else: max(y1, y2))
    mA[c] = gzZuF32(gzShr(t1, E - y1) + gzShr(t2, E - y2), E)
    let g2 = gzShr(gv * gv, 24)
    let u1 = vo.m * a.b2
    let z1 = vo.e.int - 24
    let u2 = g2 * a.b2c
    let z2 = 2 * ge
    let F = (if u1 == 0: z2 elif u2 == 0: z1 else: max(z1, z2))
    vA[c] = gzZuF32(gzShr(u1, F - z1) + gzShr(u2, F - z2), F)
    let m2 = gzMulF(mA[c])
    let v2 = gzMulF(vA[c])
    var om: int64
    var oe: int
    gzAdamQ(gzAbsU(m2.m), m2.e.int, uint64(max(0'i64, v2.m)), v2.e.int, a.eps, a.k, om, oe)
    dm[c] = (if m2.m < 0: -om else: om)
    de[c] = oe
  var x = newSeq[int64](n)
  var tmx = 0'u64
  for c in 0 ..< n:
    let wf = gzMulF(w[c])
    var t = gzShr(wf.m, et - wf.e.int) shl 24
    if dm[c] != 0: t -= gzSat(dm[c], (et - 24) - de[c], satz)
    if a.rot and c == 0: t = (t.float32 * 1.0000001'f32).int64
    x[c] = t
    let v = gzAbsU(t)
    if v > tmx: tmx = v
  if tmx == 0'u64:
    for c in 0 ..< n: w[c] = 0.0'f32
    return
  var s = gzBits(tmx) - 24
  while true:
    var ok = true
    for c in 0 ..< n:
      if gzAbsU(gzShr(x[c], s)) >= (1'u64 shl 24):
        ok = false
        break
    if ok: break
    inc s
  for c in 0 ..< n: w[c] = gzZuF32(gzShr(x[c], s), et - 24 + s)
  if satz > 0: a.satz[0] += satz.int64

proc gzAkkF(a: GzAkk): cfloat = gzZuF32(int64(a.m), a.e)

proc gzQuadG(g: GzG, a, b, c: var GzAkk) =
  ## Quadratsumme eines Gradientenpuffers zeilenweise in drei Akkumulatoren (gesamt, Gruppe, Schicht).
  let C = g.cols
  for r in 0 ..< g.rows:
    let off = r * C
    var mx = 0'u64
    for k in 0 ..< C:
      let v = gzAbsU(g.m[off + k].int64)
      if v > mx: mx = v
    if mx == 0'u64: continue
    var s = max(0, gzBits(mx) - 24)
    while 2 * (gzBits(mx) - s) + gzBits(uint64(C)) > 62: inc s
    var sum = 0'u64
    for k in 0 ..< C:
      let v = gzShr(g.m[off + k].int64, s)
      sum += uint64(v * v)
    let e = 2 * (g.e[r].int + s)
    gzAkkAdd(a, sum, e)
    gzAkkAdd(b, sum, e)
    gzAkkAdd(c, sum, e)

proc gzQuadF(p: ptr FloatArray, n: int, a, b: var GzAkk) =
  ## Quadratsumme eines float32-Gradienten (Kleber der Gains bis Stufe 4), Element fuer Element exakt zerlegt.
  for k in 0 ..< n:
    let x = gzMulF(p[k])
    if x.m != 0:
      let v = uint64(x.m * x.m)
      gzAkkAdd(a, v, 2 * x.e.int)
      gzAkkAdd(b, v, 2 * x.e.int)

proc gzPowQ30(b: int64, t: int): int64 =
  ## b^t in Q30 (b in Q30), Quadrieren und Multiplizieren.
  result = 1'i64 shl 30
  var base = b
  var k = t
  while k > 0:
    if (k and 1) == 1: result = gzShr(result * base, 30)
    base = gzShr(base * base, 30)
    k = k shr 1

# --- Matrizen- und Gain-Liste, Zustandsabbild (Bausteinprobe, Vergleich) ---
type GzMatRef = object
  name: string
  qw: ptr QMatrix
  mq, vq: ptr QMoment
  g: GzG
  emb: bool
type GzGainRef = object
  name: string
  w, m, v, g: ptr FloatArray

proc gzMatListe(state: ptr CortexState): seq[GzMatRef] =
  result.add(GzMatRef(name: "emb", qw: addr state.embeddings_q8, mq: addr state.mq_embeddings,
                      vq: addr state.vq_embeddings, g: gz.gEmb, emb: true))
  for l in 0 ..< gz.layers:
    result.add(GzMatRef(name: "q" & $l, qw: addr state.w_q_q8[l], mq: addr state.mq_w_q[l], vq: addr state.vq_w_q[l], g: gz.gq[l]))
    result.add(GzMatRef(name: "k" & $l, qw: addr state.w_k_q8[l], mq: addr state.mq_w_k[l], vq: addr state.vq_w_k[l], g: gz.gk[l]))
    result.add(GzMatRef(name: "v" & $l, qw: addr state.w_v_q8[l], mq: addr state.mq_w_v[l], vq: addr state.vq_w_v[l], g: gz.gv[l]))
    result.add(GzMatRef(name: "o" & $l, qw: addr state.w_o_q8[l], mq: addr state.mq_w_o[l], vq: addr state.vq_w_o[l], g: gz.go[l]))
    result.add(GzMatRef(name: "up" & $l, qw: addr state.w_up_q8[l], mq: addr state.mq_w_up[l], vq: addr state.vq_w_up[l], g: gz.gup[l]))
    result.add(GzMatRef(name: "down" & $l, qw: addr state.w_down_q8[l], mq: addr state.mq_w_down[l], vq: addr state.vq_w_down[l], g: gz.gdown[l]))

proc gzGainListe(state: ptr CortexState): seq[GzGainRef] =
  result.add(GzGainRef(name: "rms_final", w: state.rms_final_weight, m: state.m_rms_final_weight,
                       v: state.v_rms_final_weight, g: state.g_rms_final_weight))
  for l in 0 ..< gz.layers:
    result.add(GzGainRef(name: "rms_att" & $l, w: state.rms_att_weights[l], m: state.m_rms_att_weights[l],
                         v: state.v_rms_att_weights[l], g: state.g_rms_att_weights[l]))
    result.add(GzGainRef(name: "rms_ffn" & $l, w: state.rms_ffn_weights[l], m: state.m_rms_ffn_weights[l],
                         v: state.v_rms_ffn_weights[l], g: state.g_rms_ffn_weights[l]))

type GzAbbild = object
  q8, md, vd: seq[seq[uint8]]
  qs, ms, vs: seq[seq[cfloat]]
  gw: seq[seq[cfloat]]          # je Gain-Tensor w, m, v hintereinander
  t: cint
proc gzAbbildNimm(state: ptr CortexState): GzAbbild =
  for M in gzMatListe(state):
    let n = M.qw[].rows.int * M.qw[].cols.int
    let R = M.qw[].rows.int
    var a = newSeq[uint8](n); copyMem(addr a[0], M.qw[].data, n); result.q8.add(a)
    var b = newSeq[uint8](n); copyMem(addr b[0], M.mq[].data, n); result.md.add(b)
    var c = newSeq[uint8](n); copyMem(addr c[0], M.vq[].data, n); result.vd.add(c)
    var s1 = newSeq[cfloat](R); copyMem(addr s1[0], M.qw[].scale, R * 4); result.qs.add(s1)
    var s2 = newSeq[cfloat](R); copyMem(addr s2[0], M.mq[].scale, R * 4); result.ms.add(s2)
    var s3 = newSeq[cfloat](R); copyMem(addr s3[0], M.vq[].scale, R * 4); result.vs.add(s3)
  let d = gz.dim
  for G in gzGainListe(state):
    var x = newSeq[cfloat](3 * d)
    copyMem(addr x[0], G.w, d * 4); copyMem(addr x[d], G.m, d * 4); copyMem(addr x[2 * d], G.v, d * 4)
    result.gw.add(x)
  result.t = state.adam_t
proc gzAbbildSetze(state: ptr CortexState, a: GzAbbild) =
  var i = 0
  for M in gzMatListe(state):
    let n = M.qw[].rows.int * M.qw[].cols.int
    let R = M.qw[].rows.int
    copyMem(M.qw[].data, unsafeAddr a.q8[i][0], n); copyMem(M.mq[].data, unsafeAddr a.md[i][0], n)
    copyMem(M.vq[].data, unsafeAddr a.vd[i][0], n)
    copyMem(M.qw[].scale, unsafeAddr a.qs[i][0], R * 4); copyMem(M.mq[].scale, unsafeAddr a.ms[i][0], R * 4)
    copyMem(M.vq[].scale, unsafeAddr a.vs[i][0], R * 4)
    inc i
  let d = gz.dim
  i = 0
  for G in gzGainListe(state):
    copyMem(G.w, unsafeAddr a.gw[i][0], d * 4); copyMem(G.m, unsafeAddr a.gw[i][d], d * 4)
    copyMem(G.v, unsafeAddr a.gw[i][2 * d], d * 4)
    inc i
  state.adam_t = a.t

# --- Der Schritt ---
var gzScr: ptr UncheckedArray[int64]
var gzScrN, gzScrT: int
var gzSatz: ptr UncheckedArray[int64]
var gzSatzSumme = 0'i64
var gzLetzteNorm: cfloat = 0.0      # Summen-Raum, nur Protokoll/Vergleich
var gzRowF: GzT

proc gzEmbZusammen(state: ptr CortexState) =
  ## Gebunden: Lookup-Anteil (float-Scatter, Kleber bis Stufe 8) zum Logit-Anteil in gz.gEmb.
  let d = gz.dim
  if gzRowF.m.isNil: gzRowF = gzAlloc(1, d)
  let buf = gzI64P(gzI64, d)
  if gzAn(8):
    # Stufe 8: Lookup-Anteil ganzzahlig in gz.gLook; g_embeddings (float) wird dann nicht gelesen (ein Pruefwerkzeug
    # darf es fuer seinen Vergleich beschreiben, ohne dass doppelt gezaehlt wird).
    for r in 0 ..< gz.vocab:
      if gzRowNull(gz.gLook, r): continue
      for c in 0 ..< d: buf[c] = gz.gLook.m[r * d + c].int64
      gzAddRow(gz.gEmb, r, buf, d, gz.gLook.e[r].int)
    return
  for r in 0 ..< gz.vocab:
    let src = cast[ptr FloatArray](addr state.g_embeddings.data[r * d])
    var nz = false
    for c in 0 ..< d:
      if cast[uint32](src[c]) != 0'u32 and cast[uint32](src[c]) != 0x80000000'u32:
        nz = true
        break
    if not nz: continue
    gzSetRowF(gzRowF, 0, src)
    for c in 0 ..< d: buf[c] = gzRowF.m[c].int64
    gzAddRow(gz.gEmb, r, buf, d, gzRowF.e[0].int)

proc gzOptKern(state: ptr CortexState, lr: cfloat, N: cint, srW, srM, srV, rot: bool, kFak: bool = false,
               normVorgabe: cfloat = -1.0'f32) =
  ## Norm, Skalare, alle Matrizen, Gains; adam_t += 1. Erwartet den zusammengefuehrten Gradienten in gz.gEmb.
  # 1. Norm ueber alle Gradienten (Gruppen wie clipGlobalGradientNorm: 0 Emb, 1 QK, 2 VO, 3 FFN, 4 Gains)
  var tot: GzAkk
  var grp: array[GRAD_GROUPS, GzAkk]
  var qkl = newSeq[GzAkk](gz.layers)
  var leer: GzAkk
  gzQuadG(gz.gEmb, tot, grp[0], leer)
  let gainInt = gzAn(4)     # Stufe 4: Gain-Gradienten ganzzahlig in gz.gGain, sonst float-Kleber
  if gainInt: gzQuadG(gz.gGain[0], tot, grp[4], leer)
  else:
    for G in gzGainListe(state)[0 .. 0]: gzQuadF(G.g, gz.dim, tot, grp[4])
  for l in 0 ..< gz.layers:
    gzQuadG(gz.gq[l], tot, grp[1], qkl[l])
    gzQuadG(gz.gk[l], tot, grp[1], qkl[l])
    gzQuadG(gz.gv[l], tot, grp[2], leer)
    gzQuadG(gz.go[l], tot, grp[2], leer)
    gzQuadG(gz.gup[l], tot, grp[3], leer)
    gzQuadG(gz.gdown[l], tot, grp[3], leer)
    if gainInt:
      gzQuadG(gz.gGain[1 + 2 * l], tot, grp[4], leer)
      gzQuadG(gz.gGain[2 + 2 * l], tot, grp[4], leer)
    else:
      gzQuadF(state.g_rms_att_weights[l], gz.dim, tot, grp[4])
      gzQuadF(state.g_rms_ffn_weights[l], gz.dim, tot, grp[4])
  var nr = 0'u64
  var ne = 0
  if tot.m != 0'u64:
    var x = tot.m
    var xe = tot.e
    if (xe and 1) != 0:
      x = x shl 1
      dec xe
    nr = gzIsqrt(x)
    ne = xe div 2
  if normVorgabe >= 0.0'f32:
    # Pruefwerkzeug (SNAI_GZ_ADAMVGL_ALTNORM=1): Norm des alten Pfads, bitweise zerlegt, statt der eigenen
    let nv = gzMulF(normVorgabe)
    nr = uint64(nv.m)
    ne = nv.e.int
  let nC = max(1, N.int)
  let ueber = nr != 0'u64 and gzUeber(nr, ne, uint64(nC))
  let S = (if ueber: gzMulAus(int64((1'u64 shl 62) div nr), -62 - ne, false)
           else: gzMulAus(int64((1'u64 shl 62) div uint64(nC)), -62, false))
  # Protokoll (bitweise gebaut): Norm im Mittelwert-Raum wie bisher nach der Division durch clip_norm
  gzLetzteNorm = gzZuF32(int64(nr), ne)
  last_grad_norm = (if nr == 0'u64: 0.0'f32 else: gzZuF32(int64((nr shl 31) div uint64(nC)), ne - 31))
  last_grad_total_sq = gzAkkF(tot)
  for i in 0 ..< GRAD_GROUPS: last_grad_group_sq[i] = gzAkkF(grp[i])
  for l in 0 ..< GRAD_QK_LAYERS_MAX: last_grad_qk_layer_sq[l] = 0.0'f32
  for l in 0 ..< min(gz.layers, GRAD_QK_LAYERS_MAX): last_grad_qk_layer_sq[l] = gzAkkF(qkl[l])
  last_grad_layers = gz.layers.cint
  # 2. Skalare des Schritts
  state.adam_t += 1
  let t = state.adam_t.int
  gzSalt = uint64(state.adam_t) * 0xD1B54A32D192ED03'u64
  let B1 = gzMulF(0.9'f32)
  let B2 = gzMulF(0.999'f32)
  doAssert B1.e == -24 and B2.e == -24
  let p1 = gzPowQ30(B1.m shl 6, t)
  let p2 = gzPowQ30(B2.m shl 6, t)
  let b1t = (1'i64 shl 30) - p1
  let b2t = (1'i64 shl 30) - p2
  let sqb = int64(gzIsqrt(uint64(b2t) shl 30))             # sqrt(b2t) in Q30
  let ratio = gzDivR(sqb shl 30, max(1'i64, b1t))           # sqrt(b2t)/b1t in Q30
  let LR = (if gzAn(9): gzLrSchritt(t, lr) else: gzMulF(lr))
  var K = (if LR.m <= 0 or ratio == 0: GzMul(m: 0, e: 0) else: gzMulAus(ratio * LR.m, LR.e.int - 30, false))
  if kFak and K.m != 0: K.m = gzDivR(K.m * 11, 10)        # Rot-Probe des Vergleichs: Schritt +10 %
  let EP = gzMulF(1.0e-8'f32)
  let EPS = gzMulAus(EP.m * sqb, EP.e.int - 30, false)
  let WD = gzMulF(global_weight_decay)
  let LW = (if LR.m <= 0 or WD.m <= 0: GzMul(m: 0, e: 0) else: gzMulAus(LR.m * WD.m, LR.e.int + WD.e.int, false))
  let rotF = gzRotLies()
  if rotF == 'h' and K.m != 0: K.m = int64(K.m.float32 * 1.0000001'f32)
  # Telemetrie (nur Protokoll): Nullgradienten vor dem Schritt, Codes vorher merken
  gzTeleLies()
  let tele = gzTeleN > 0 and t mod gzTeleN == 0
  var teleAlt: seq[seq[int8]]
  if tele:
    if gzTeleRot:
      gzGNull(gz.gq[0])
      K = GzMul(m: 0, e: 0)
    var z = "  > [GZ-TELE] adam_t=" & $t & " Nullgradienten"
    for M in gzMatListe(state):
      z.add(" " & M.name & "=" & gzProzent(gzNullAnteil(M.g), M.g.rows * M.g.cols))
      teleAlt.add(gzCodesKopie(M.qw[]))
    stderr.writeLine(z)
  # 3. Matrizen, Zeilen parallel
  let mc = max(gz.dim, max(gz.ffn, gz.vocab))
  let nt = max(1, gzOmpMax().int)
  if gzScr.isNil or gzScrT < nt or gzScrN < 6 * mc:
    if not gzScr.isNil: deallocShared(gzScr)
    if not gzSatz.isNil: deallocShared(gzSatz)
    gzScrT = nt
    gzScrN = 6 * mc
    gzScr = cast[ptr UncheckedArray[int64]](allocShared0(gzScrT * gzScrN * sizeof(int64)))
    gzSatz = cast[ptr UncheckedArray[int64]](allocShared0(gzScrT * sizeof(int64)))
  var A = GzAdamArgs(sM: S.m, sE: S.e.int, b1: B1.m, b1c: (1'i64 shl 24) - B1.m, b2: B2.m, b2c: (1'i64 shl 24) - B2.m,
                     k: K, eps: EPS, upd: N > 0, srW: srW, srM: srM, srV: srV, vKl: vKlemmeAn(), rot: rot,
                     scr: gzScr, scrN: gzScrN, satz: gzSatz)
  for M in gzMatListe(state):
    A.qw = M.qw[]
    A.mq = M.mq
    A.vq = M.vq
    A.g = M.g
    A.lw = (if M.emb and wd_embeddings == 0: GzMul(m: 0, e: 0) else: LW)
    if tele and gzTeleRot: A.lw = GzMul(m: 0, e: 0)
    let pa = addr A
    let R = M.qw[].rows.int
    let rotO = rotF == 'o'
    {.push checks: off.}
    for r in 0 || (R - 1):
      gzAdamZeileC(pa, r)
      if rotO: pa.qw.scale[r] = pa.qw.scale[r] * 1.0000001'f32
    {.pop.}
    if rotF == 'a' and M.emb: gzRotAvx(addr M.qw[].scale[0], M.qw[].rows)
  if tele:
    var z = "  > [GZ-TELE] adam_t=" & $t & " Codes geaendert"
    var i = 0
    for M in gzMatListe(state):
      z.add(" " & M.name & "=" & gzProzent(gzCodesAnders(M.qw[], teleAlt[i]), teleAlt[i].len))
      inc i
    stderr.writeLine(z)
    var rz = "  > [GZ-TELE] adam_t=" & $t & " Restpfad log2 max/mittel/min, " & $gzTeleAct & " Positionen"
    for l in 0 ..< gz.layers:
      rz.add(" h1." & $l & "=" & gzRestGroesse(gz.ly[l].h1, gzTeleAct) & " h2." & $l & "=" &
             gzRestGroesse(gz.ly[l].h2, gzTeleAct))
    rz.add(" hf=" & gzRestGroesse(gz.hf, gzTeleAct))
    stderr.writeLine(rz)
  # 4. Gains (seriell)
  var gk = 0
  for G in gzGainListe(state):
    A.lw = GzMul(m: 0, e: 0)
    gzGainSchritt(G.w, G.m, G.v, G.g, gz.dim, addr A, (if gainInt: addr gz.gGain[gk] else: nil))
    inc gk
  for i in 0 ..< gzScrT:
    gzSatzSumme += gzSatz[i]
    gzSatz[i] = 0
  if t mod 1000 == 0:
    stderr.writeLine("  > [GZ] adam_t=", t, " Saettigungen im Adam (seit dem letzten Bericht) ", gzSatzSumme)
    if gzAn(8):
      stderr.writeLine("  > [GZ] adam_t=", t, " Saettigungen im Restpfad (seit dem letzten Bericht) ", gzSatRest)
      gzSatRest = 0
    if gzAn(9):
      stderr.writeLine("  > [GZ] adam_t=", t, " LR-Plan: groesste Abweichung gegen PHP (seit dem letzten Bericht) ",
                       gzLrMaxAbw, " * 2^-30, Wache bei 2^13")
      gzLrMaxAbw = 0
    gzSatzSumme = 0

# --- Pruefwerkzeuge ---
proc gzAbbildVgl(name: string, a, b: GzAbbild): seq[string] =
  ## Bausteinprobe: Abbilder bytegleich?
  for k in 0 ..< a.q8.len:
    var n = 0
    for j in 0 ..< a.q8[k].len:
      if a.q8[k][j] != b.q8[k][j]: inc n
      if a.md[k][j] != b.md[k][j]: inc n
      if a.vd[k][j] != b.vd[k][j]: inc n
    for j in 0 ..< a.qs[k].len:
      if cast[uint32](a.qs[k][j]) != cast[uint32](b.qs[k][j]): inc n
      if cast[uint32](a.ms[k][j]) != cast[uint32](b.ms[k][j]): inc n
      if cast[uint32](a.vs[k][j]) != cast[uint32](b.vs[k][j]): inc n
    result.add(name & " Matrix " & $k & (if n == 0: " gleich" else: " ABWEICHEND (" & $n & ")"))
  for k in 0 ..< a.gw.len:
    var n = 0
    for j in 0 ..< a.gw[k].len:
      if cast[uint32](a.gw[k][j]) != cast[uint32](b.gw[k][j]): inc n
    result.add(name & " Gain " & $k & (if n == 0: " gleich" else: " ABWEICHEND (" & $n & ")"))

proc gzCodeS(b: uint8): int {.inline.} =
  let mag = int(b and 0x7F'u8)
  (if (b and 0x80'u8) != 0'u8: -mag else: mag)

proc gzRelF(x, y: cfloat): float64 =
  (if x == 0.0'f32 and y == 0.0'f32: 0.0 else: abs(x.float64 - y.float64) / max(abs(x.float64), abs(y.float64)))

var gzVglNorm64 = 0.0
proc gzAdamVglBericht(state: ptr CortexState, s0, a, b: GzAbbild, normA, normB: cfloat) =
  ## Vergleich alter float-Adam (a) gegen GZ (b), beide zum Naechsten gerundet, gleicher Ausgangszustand s0.
  stderr.writeLine("  > [GZ-ADAMVGL] Norm alt " & $normA & " GZ " & $normB & " rel " &
                   $(abs(normA.float64 - normB.float64) / max(1e-30, abs(normA.float64))) & " | float64 " & $gzVglNorm64 &
                   " rel alt " & $(abs(normA.float64 - gzVglNorm64) / gzVglNorm64) & " rel GZ " &
                   $(abs(normB.float64 - gzVglNorm64) / gzVglNorm64))
  let ml = gzMatListe(state)
  for k in 0 ..< a.q8.len:
    var n, eqW, eqM, eqV: int
    var dW, dM, dV: int
    for j in 0 ..< a.q8[k].len:
      inc n
      let wa = cast[int8](a.q8[k][j]).int
      let wb = cast[int8](b.q8[k][j]).int
      if wa == wb: inc eqW
      dW = max(dW, abs(wa - wb))
      if a.md[k][j] == b.md[k][j]: inc eqM
      dM = max(dM, abs(gzCodeS(a.md[k][j]) - gzCodeS(b.md[k][j])))
      if a.vd[k][j] == b.vd[k][j]: inc eqV
      dV = max(dV, abs(a.vd[k][j].int - b.vd[k][j].int))
    var rS, rM, rV: float64
    for j in 0 ..< a.qs[k].len:
      rS = max(rS, gzRelF(a.qs[k][j], b.qs[k][j]))
      rM = max(rM, gzRelF(a.ms[k][j], b.ms[k][j]))
      rV = max(rV, gzRelF(a.vs[k][j], b.vs[k][j]))
    var nz = 0
    let C = ml[k].qw[].cols.int
    for j in 0 ..< a.q8[k].len:
      if abs(gzCodeS(a.md[k][j]) - gzCodeS(b.md[k][j])) > 1 and nz < 6:
        inc nz
        let r = j div C
        let g = ml[k].g
        stderr.writeLine("  > [GZ-ADAMVGL-EL] " & ml[k].name & " r " & $r & " c " & $(j mod C) & " m-Code s0 " &
          $gzCodeS(s0.md[k][j]) & " alt " & $gzCodeS(a.md[k][j]) & " GZ " & $gzCodeS(b.md[k][j]) &
          " | v-Code s0 " & $s0.vd[k][j] & " alt " & $a.vd[k][j] & " GZ " & $b.vd[k][j] &
          " | m-Skala s0 " & $s0.ms[k][r] & " alt " & $a.ms[k][r] & " GZ " & $b.ms[k][r] &
          " | g " & $(g.m[j].float64 * pow(2.0, g.e[r].float64)) & " g-Zeilenmax-Exp " & $g.e[r])
    stderr.writeLine("  > [GZ-ADAMVGL] ", ml[k].name, " n ", n, " w gleich ", eqW.float64 / n.float64, " max|dw| ", dW,
                     " | m gleich ", eqM.float64 / n.float64, " max|dm| ", dM, " | v gleich ", eqV.float64 / n.float64,
                     " max|dv| ", dV, " | Skala rel ", rS, " m-Skala rel ", rM, " v-Skala rel ", rV)
  let gl = gzGainListe(state)
  let d = gz.dim
  for k in 0 ..< a.gw.len:
    var nd, na, mdd, mna, vdd, vna: float64
    for j in 0 ..< d:
      let da = a.gw[k][j].float64 - s0.gw[k][j].float64
      let db = b.gw[k][j].float64 - s0.gw[k][j].float64
      nd += (da - db) * (da - db); na += da * da
      let ma = a.gw[k][d + j].float64
      let mb = b.gw[k][d + j].float64
      mdd += (ma - mb) * (ma - mb); mna += ma * ma
      let va = a.gw[k][2 * d + j].float64
      let vb = b.gw[k][2 * d + j].float64
      vdd += (va - vb) * (va - vb); vna += va * va
    stderr.writeLine("  > [GZ-ADAMVGL] ", gl[k].name, " Schritt relL2 ", (if na > 0: sqrt(nd / na) else: 0.0),
                     " m relL2 ", (if mna > 0: sqrt(mdd / mna) else: 0.0), " v relL2 ", (if vna > 0: sqrt(vdd / vna) else: 0.0))

proc gzSelbsttest(rot: bool) =
  ## Pruefwerkzeug (mit der Bausteinprobe, SNAI_GZ_KERN=1): Hilfsfunktionen gegen float64 (nur Diagnose).
  ## rot (SNAI_GZ_KERN_ROT=1): jede Referenz um eine bekannte Spur verschoben, jede Pruefung muss anschlagen.
  let rl = (if rot: 1e-5 else: 0.0)
  let rq = (if rot: 1'u64 else: 0'u64)
  let rf = (if rot: 1.0 + pow(2.0, -21.0) else: 1.0)
  var h = 0x1234567'u64
  template nx(): uint64 =
    h = h + 0x9E3779B97F4A7C15'u64
    var z = h
    z = (z xor (z shr 30)) * 0xBF58476D1CE4E5B9'u64
    z = (z xor (z shr 27)) * 0x94D049BB133111EB'u64
    z xor (z shr 31)
  var eLog = 0.0
  var fSqrt = 0
  var eF32 = 0.0
  var fRund = 0
  for i in 0 ..< 200000:
    let b = 1 + int(nx() mod 63'u64)
    var x = nx() shr (64 - b)
    if x == 0'u64: x = 1
    let l = gzLog2Q(x).float64 / 4294967296.0
    eLog = max(eLog, abs(l - log2(x.float64) - rl))
    let r = gzIsqrt(x) + rq
    if not (r * r <= x and (r + 1'u64) * (r + 1'u64) > x): inc fSqrt
    let m = int64(nx() shr 20) - (1'i64 shl 43)
    let e = int(nx() mod 260'u64) - 160
    let f = gzZuF32(m, e)
    let exakt = m.float64 * pow(2.0, e.float64) * rf
    let g = gzMulF(f)
    let ulp = (if g.m == 0: pow(2.0, -149.0) else: pow(2.0, g.e.float64))
    if f.float64 != 0.0 and abs(exakt) > 1e-38 and abs(exakt) < 3e38:
      eF32 = max(eF32, abs(f.float64 - exakt) / ulp)
    let rt = gzZuF32(g.m, g.e.int)
    if cast[uint32](rt) != cast[uint32](f) or rot: inc fRund
  var eTab = 0.0
  for k in 1 .. 127:
    let w = gzTMm[k].float64 * pow(2.0, (-35 - gzTMs[k]).float64) * (1.0 + rl)
    eTab = max(eTab, abs(w - adamTabM[k].float64) / adamTabM[k].float64)
  for k in 1 .. 255:
    let w = gzTVm[k].float64 * pow(2.0, (-35 - gzTVs[k]).float64)
    eTab = max(eTab, abs(w - adamTabV[k].float64) / adamTabV[k].float64)
  stderr.writeLine("  > [GZ-SELBST] log2 max Fehler ", eLog, " | isqrt falsch ", fSqrt, " von 200000 | float32-Bau max ",
                   eF32, " ulp | Rundreise falsch ", fRund, " | Tabellen rel. zu adamTab ", eTab)

var gzAdamKernFertig = false
var gzAdamVglFertig = false
proc gzOptSchritt(state: ptr CortexState, lr: cfloat, N: cint) =
  ## Stufe >= 3: ersetzt Kleber, Tie-Zusammenfuehrung, clipGlobalGradientNorm und applyGlobalAdamUpdateI8.
  gzTabellen()
  if i8_mom_sr < 0: srLeseUmgebung()
  if restModus < 0: restLies()
  if restModus != 1 and restModus != 0:
    stderr.writeLine("[GZ] FEHLER: Stufe >= 3 kennt nur SNAI_I8_REST=sr oder 0 (Modus ", restModus, ") - Abbruch")
    quit(4)
  discard vKlemmeAn()
  let srW = restModus == 1
  let srM = (i8_mom_sr and 1) != 0
  let srV = (i8_mom_sr and 2) != 0
  # Vergleich alter Adam gegen GZ (SNAI_GZ_ADAMVGL=<adam_t>), beide zum Naechsten gerundet
  let vt = getEnv("SNAI_GZ_ADAMVGL")
  if not gzAdamVglFertig and vt != "" and parseInt(vt) == state.adam_t.int + 1:
    gzAdamVglFertig = true
    let d = gz.dim
    let s0 = gzAbbildNimm(state)
    let ne = gz.vocab * d
    var fEmb = newSeq[cfloat](ne)
    copyMem(addr fEmb[0], state.g_embeddings.data, ne * 4)
    var fG: seq[seq[cfloat]]
    for G in gzGainListe(state):
      var x = newSeq[cfloat](d); copyMem(addr x[0], G.g, d * 4); fG.add(x)
    # alter Weg: Kleber wie Stufe 2, Tie-Zusammenfuehrung wie cortexTrainStepI8Roh, Clip, Adam
    gzGZuFloat(gz.gEmb, state.g_w_out.data)
    for l in 0 ..< gz.layers:
      gzGZuFloat(gz.gq[l], state.g_w_q[l].data); gzGZuFloat(gz.gk[l], state.g_w_k[l].data)
      gzGZuFloat(gz.gv[l], state.g_w_v[l].data); gzGZuFloat(gz.go[l], state.g_w_o[l].data)
      gzGZuFloat(gz.gup[l], state.g_w_up[l].data); gzGZuFloat(gz.gdown[l], state.g_w_down[l].data)
    for i in 0 ..< ne:
      state.g_embeddings.data[i] += state.g_w_out.data[i]
      state.g_w_out.data[i] = 0.0
    block:
      var s64 = 0.0
      template addM(mm: Matrix) =
        for i in 0 ..< mm.rows.int * mm.cols.int: s64 += mm.data[i].float64 * mm.data[i].float64
      addM(state.g_embeddings)
      for G in gzGainListe(state):
        for i in 0 ..< d: s64 += G.g[i].float64 * G.g[i].float64
      for l in 0 ..< gz.layers:
        addM(state.g_w_q[l]); addM(state.g_w_k[l]); addM(state.g_w_v[l]); addM(state.g_w_o[l])
        addM(state.g_w_up[l]); addM(state.g_w_down[l])
      gzVglNorm64 = sqrt(s64)
    let altSr = i8_mom_sr
    let altRest = restModus
    i8_mom_sr = 0
    restModus = 0
    clipGlobalGradientNorm(state, max(1.0'f32, N.cfloat))
    let normA = last_grad_norm
    applyGlobalAdamUpdateI8(state, lr, N.cfloat)
    i8_mom_sr = altSr
    restModus = altRest
    let sa = gzAbbildNimm(state)
    # zurueck auf den Ausgangszustand, dann GZ
    gzAbbildSetze(state, s0)
    copyMem(state.g_embeddings.data, addr fEmb[0], ne * 4)
    var i = 0
    for G in gzGainListe(state):
      copyMem(G.g, addr fG[i][0], d * 4)
      inc i
    gzEmbZusammen(state)
    gzOptKern(state, lr, N, false, false, false, false, getEnv("SNAI_GZ_ADAMVGL_ROT") == "1",
              (if getEnv("SNAI_GZ_ADAMVGL_ALTNORM") == "1": normA else: -1.0'f32))
    let sb = gzAbbildNimm(state)
    gzAdamVglBericht(state, s0, sa, sb, normA, gzLetzteNorm)
    markQWeightsDirty(state)
    return
  gzEmbZusammen(state)
  if not gzAdamKernFertig and getEnv("SNAI_GZ_KERN") == "1":
    # Bausteinprobe: derselbe Schritt unter "aufwaerts" (alle Faeden) und "naechster", Ergebnis bytegleich?
    gzAdamKernFertig = true
    let rot = getEnv("SNAI_GZ_KERN_ROT") == "1"
    let s0 = gzAbbildNimm(state)
    gzFeAlle(gzFeAuf)
    gzOptKern(state, lr, N, srW, srM, srV, rot)
    gzFeAlle(gzFeNaechster)
    let s1 = gzAbbildNimm(state)
    let n1 = gzLetzteNorm
    gzAbbildSetze(state, s0)
    gzOptKern(state, lr, N, srW, srM, srV, rot)
    let s2 = gzAbbildNimm(state)
    for z in gzAbbildVgl("adam", s1, s2): stderr.writeLine("  > [GZ-KERN] ", z)
    stderr.writeLine("  > [GZ-KERN] adam Norm ", (if cast[uint32](n1) == cast[uint32](gzLetzteNorm): "gleich" else: "ABWEICHEND"))
    gzSelbsttest(rot)
  else:
    gzOptKern(state, lr, N, srW, srM, srV, false)
  markQWeightsDirty(state)

# --- Stufe 11 (2026-11-16): ganzzahliger Merge mehrerer Worker (SNAI_V8) --------------------------------------------
# Schalter SNAI_I8_GZ_MERGE bzw. SNAI_I8_GANZ >= 11, braucht Stufe 10 (CKPT). Gerechnet wird in der Hauptinstanz
# (train_cluster.php -> tensor_io.php merge_v8_models), seriell, Zeile fuer Zeile, nur mit Ganzzahlen:
#  - int8-Gewichte: Summe q_i * Skala_i exakt auf einem gemeinsamen Raster, / N gerundet, neu quantisiert wie in
#    gzAdamZeile (Skala = max/127 als 24-Bit-Mantisse, Code = gzDivR, ohne SR). Nullzeile: Codes 0, Skala 1,0 (wie
#    requantRow im alten Merge).
#  - 8-Bit-Momente: Codes ueber die Tabellen gzTMm/gzTVm entpackt (wie gzAdamZeile), gemittelt, mit gzMomKodiere ohne SR
#    neu kodiert (v mit der v-Klemme wie im Training).
#  - float32-Tensoren (Gains und ihre Momente): exakte Summe der Mantissen, / N, zum Naechsten gerundet mit Halbe zur
#    geraden Mantisse (beim Mitteln zweier Werte gleichen Exponenten ist jede zweite Summe ein Halbfall; so trifft das
#    Ergebnis das float64-Mittel des alten Wegs, statt Betraege nach oben zu ziehen).
# Pruefwerkzeuge: SNAI_GZ_IO_RUNDUNG (Rundungsmodus fuer die Dauer jeder Merge-Funktion), SNAI_GZ_MERGE_ROT=i|m|f (eine
# float32-Rechnung im Zweig Gewichte / Momente / float32, Rot-Probe), SNAI_GZ_MERGEVGL=1 (float64-Bezug je Element,
# Bericht ueber cortex_gz_merge_bericht; aendert das Ergebnis nicht).
const GZ_MERGE_NMAX = 64

proc cortex_gz_merge_an*(): cint {.ffi.} =
  ## 1, wenn Stufe 11 (ganzzahliger Merge) an ist. Die Hauptinstanz fragt das, bevor sie SNAI_V8 mehrerer Worker mittelt.
  (if gzAn(11): 1 else: 0)

var gzMrgRot = '?'
proc gzMrgRotLies(): char =
  if gzMrgRot == '?':
    let w = getEnv("SNAI_GZ_MERGE_ROT")
    gzMrgRot = (if w == "i" or w == "m" or w == "f": w[0] else: '-')
    if w != "" and gzMrgRot == '-':
      stderr.writeLine("SNAI_GZ_MERGE_ROT='", w, "' ungueltig (i|m|f) - Abbruch"); quit(1)
    if gzMrgRot != '-': stderr.writeLine("  > [GZ-MERGE] ROT-PROBE ", gzMrgRot, ": eine float32-Rechnung im Merge")
  gzMrgRot
proc gzMrgRotI(x: int64): int64 {.inline.} =
  ## Rot-Probe: Wert ueber float32 * (1 + 2^-23); das Ergebnis haengt vom Rundungsmodus ab.
  int64(x.float32 * 1.0000001'f32)

proc gzZuF32GS(a: uint64, e: int, klebe, neg: bool): cfloat =
  ## (a + Rest) * 2^e als float32, zum Naechsten gerundet, Halbe zur geraden Mantisse; klebe = Rest > 0 (Rest < 2^e).
  ## Nur Bitoperationen. Der Aufrufer liefert a mit >= 32 Bit, dann liegt jede Rundungsstelle oberhalb des Rests.
  if a == 0'u64: return 0.0'f32
  let nb = gzBits(a)
  let k = max(nb - 24, -149 - e)
  var q: uint64
  var ee = e + k
  if k >= 64:
    q = 0'u64
  elif k > 0:
    q = a shr k
    let rest = a and ((1'u64 shl k) - 1'u64)
    let half = 1'u64 shl (k - 1)
    if rest > half or (rest == half and (klebe or (q and 1'u64) == 1'u64)): inc q
  else:
    q = a shl (-k)
  if q >= (1'u64 shl 24):
    q = q shr 1
    inc ee
  var bits: uint32
  if q == 0'u64: bits = 0'u32
  elif q >= (1'u64 shl 23):
    let be = ee + 150
    bits = (if be >= 255: 0x7F7FFFFF'u32 else: (uint32(be) shl 23) or uint32(q and 0x7FFFFF'u64))
  else:
    bits = uint32(q)                      # subnormal (ee = -149)
  if neg: bits = bits or 0x80000000'u32
  cast[cfloat](bits)

# float64-Bezug (SNAI_GZ_MERGEVGL=1): je Zweig Elemente, gleiche Codes/Bitmuster, groesste Abweichung (Codes bzw. ulp),
# dazu die Zeilenskalen. Zweige: 0 Gewichte, 1 m, 2 v, 3 float32.
var gzMvW = -1
var gzMvEl, gzMvGl, gzMvMax, gzMvSk, gzMvSkGl, gzMvSkMax: array[4, int64]
proc gzMvLies(): bool =
  if gzMvW < 0: gzMvW = (if getEnv("SNAI_GZ_MERGEVGL") == "1": 1 else: 0)
  gzMvW == 1
proc gzOrdF(x: cfloat): int64 {.inline.} =
  let b = cast[uint32](x)
  (if (b and 0x80000000'u32) != 0: -int64(b and 0x7FFFFFFF'u32) else: int64(b))
proc gzMvSkala(k: int, a, b: cfloat) =
  inc gzMvSk[k]
  let d = abs(gzOrdF(a) - gzOrdF(b))
  if d == 0: inc gzMvSkGl[k]
  if d > gzMvSkMax[k]: gzMvSkMax[k] = d
proc gzMvWert(k: int, d: int64) =
  inc gzMvEl[k]
  if d == 0: inc gzMvGl[k]
  if d > gzMvMax[k]: gzMvMax[k] = d
template gzMvNaechster(body: untyped) =
  let altM = gzFeget()
  discard gzFeset(gzFeNaechster)
  body
  discard gzFeset(altM)

proc cortex_gz_merge_bericht*() {.ffi.} =
  ## Bericht des float64-Bezugs seit dem letzten Aufruf (nur mit SNAI_GZ_MERGEVGL=1), danach zurueckgesetzt.
  const nm = ["Gewichte", "m", "v", "float32"]
  for k in 0 .. 3:
    if gzMvEl[k] == 0 and gzMvSk[k] == 0: continue
    var z = "  > [GZ-MERGEVGL] " & nm[k] & ": " & $gzMvGl[k] & "/" & $gzMvEl[k] & " gleich (" &
            gzProzent(gzMvGl[k].int, gzMvEl[k].int) & "), groesste Abweichung " & $gzMvMax[k] &
            (if k == 3: " ulp" else: " Code")
    if gzMvSk[k] > 0:
      z.add("; Zeilenskalen " & $gzMvSkGl[k] & "/" & $gzMvSk[k] & " bitgleich, groesste Abweichung " &
            $gzMvSkMax[k] & " ulp")
    stderr.writeLine(z)
    gzMvEl[k] = 0; gzMvGl[k] = 0; gzMvMax[k] = 0; gzMvSk[k] = 0; gzMvSkGl[k] = 0; gzMvSkMax[k] = 0

proc gzMrgSkala(sv: cfloat, m: var GzMul): bool {.inline.} =
  ## Zeilenskala zerlegen; false bei NaN/Inf oder negativem Vorzeichen (der Lader lehnt solche Dateien ebenso ab).
  let b = cast[uint32](sv)
  if (b and 0x7F800000'u32) == 0x7F800000'u32 or b > 0x7F7FFFFF'u32: return false
  m = gzMulF(sv)
  true

proc cortex_gz_merge_i8*(n, rows, cols: cint, qs, ss: ptr pointer, qOut, sOut: pointer): cint {.ffi.} =
  ## N int8-Tensoren (Codes + float32-Zeilenskalen roh aus der Datei) -> gemittelter Tensor, nur Ganzzahl.
  ## Rueckgabe 0 = gut, 1 = Argumente ungueltig, 2 = Skala NaN/Inf/negativ.
  if n <= 0 or n > GZ_MERGE_NMAX or rows <= 0 or cols <= 0 or qs.isNil or ss.isNil or qOut.isNil or sOut.isNil:
    return 1
  gzIoRundung(true)
  defer: gzIoRundung(false)
  let N = n.int
  let C = cols.int
  let pq = cast[ptr UncheckedArray[pointer]](qs)
  let ps = cast[ptr UncheckedArray[pointer]](ss)
  let qo = cast[ptr UncheckedArray[int8]](qOut)
  let so = cast[ptr UncheckedArray[cfloat]](sOut)
  let rot = gzMrgRotLies() == 'i'
  let vgl = gzMvLies()
  let bN = gzBits(uint64(N))
  var acc = newSeq[int64](C)
  var sm = newSeq[GzMul](N)
  var ref64 = newSeq[float64](if vgl: C else: 0)
  for r in 0 ..< rows.int:
    let off = r * C
    var emax = low(int)
    var emin = high(int)
    for i in 0 ..< N:
      if not gzMrgSkala(cast[ptr UncheckedArray[cfloat]](ps[i])[r], sm[i]): return 2
      if sm[i].m != 0:
        emax = max(emax, sm[i].e.int)
        emin = min(emin, sm[i].e.int)
    var tmx = 0'u64
    var E = 0
    for c in 0 ..< C: acc[c] = 0
    if emax != low(int):
      # |q * m| < 2^31; Linksschub hoechstens 31 - bits(N) -> Summe < 2^62
      E = max(emin, emax - 31 + bN)
      for i in 0 ..< N:
        if sm[i].m == 0: continue
        let q = cast[ptr UncheckedArray[int8]](pq[i])
        let sh = E - sm[i].e.int
        for c in 0 ..< C: acc[c] += gzShr(q[off + c].int64 * sm[i].m, sh)
      for c in 0 ..< C:
        var a = gzDivR(acc[c], N.int64)
        if rot: a = gzMrgRotI(a)
        acc[c] = a
        let v = gzAbsU(a)
        if v > tmx: tmx = v
    if tmx == 0'u64:
      for c in 0 ..< C: qo[off + c] = 0
      so[r] = 1.0'f32
    else:
      let ns = gzMulAus(int64(tmx), E, true)
      let kk = E - ns.e.int
      let den = (if kk >= 0: ns.m else: ns.m shl (-kk))
      for c in 0 ..< C:
        let num = (if kk >= 0: acc[c] shl kk else: acc[c])
        var q = gzDivR(num, den)
        if q > 127: q = 127
        elif q < -128: q = -128
        qo[off + c] = q.int8
      so[r] = gzZuF32(ns.m, ns.e.int)
    if vgl:
      gzMvNaechster:
        var mx = 0.0
        for c in 0 ..< C:
          var s = 0.0
          for i in 0 ..< N:
            s += cast[ptr UncheckedArray[int8]](pq[i])[off + c].float64 * cast[ptr UncheckedArray[cfloat]](ps[i])[r].float64
          ref64[c] = s / N.float64
          mx = max(mx, abs(ref64[c]))
        let sref = (if mx > 0.0: (mx / 127.0).float32 else: 1.0'f32)
        gzMvSkala(0, so[r], sref)
        for c in 0 ..< C:
          let qr = max(-128.0, min(127.0, round(ref64[c] / sref.float64)))
          gzMvWert(0, abs(qo[off + c].int64 - qr.int64))
  0

proc cortex_gz_merge_mom*(n, rows, cols, signed: cint, cs, ss: ptr pointer, cOut, sOut: pointer): cint {.ffi.} =
  ## N 8-Bit-Momente (Codes + float32-Zeilenskalen roh aus der Datei; signed = 1 fuer m, 0 fuer v) -> gemitteltes
  ## Moment, nur Ganzzahl. Rueckgabe wie cortex_gz_merge_i8.
  if n <= 0 or n > GZ_MERGE_NMAX or rows <= 0 or cols <= 0 or cs.isNil or ss.isNil or cOut.isNil or sOut.isNil:
    return 1
  gzIoRundung(true)
  defer: gzIoRundung(false)
  gzTabellen()
  let N = n.int
  let C = cols.int
  let sg = signed != 0
  let vKl = (not sg) and vKlemmeAn()
  let pc = cast[ptr UncheckedArray[pointer]](cs)
  let ps = cast[ptr UncheckedArray[pointer]](ss)
  let rot = gzMrgRotLies() == 'm'
  let vgl = gzMvLies()
  let bN = gzBits(uint64(N))
  let qo = QMoment(rows: rows, cols: cols, data: cast[ptr Uint8Array](cOut), scale: cast[ptr FloatArray](sOut))
  var acc = newSeq[int64](C)
  var sm = newSeq[GzMul](N)
  var ref64 = newSeq[float64](if vgl: C else: 0)
  for r in 0 ..< rows.int:
    let off = r * C
    var emax = low(int)
    var emin = high(int)
    for i in 0 ..< N:
      if not gzMrgSkala(cast[ptr UncheckedArray[cfloat]](ps[i])[r], sm[i]): return 2
      if sm[i].m != 0:
        emax = max(emax, sm[i].e.int - 35)
        emin = min(emin, sm[i].e.int - 35)
    for c in 0 ..< C: acc[c] = 0
    var E = 0
    if emax != low(int):
      # entpackt < 2^60 bei em = Skala.e - 35 (wie gzAdamZeile); Summe von N Werten bei E < 2^62
      E = max(emin, emax - 2 + bN)
      for i in 0 ..< N:
        if sm[i].m == 0: continue
        let d = cast[ptr UncheckedArray[uint8]](pc[i])
        let sh = E - (sm[i].e.int - 35)
        for c in 0 ..< C:
          let b = d[off + c]
          var x: int64
          if sg:
            let mag = int(b and 0x7F'u8)
            x = (if mag == 0: 0'i64 else: gzShr(gzTMm[mag] * sm[i].m, gzTMs[mag].int))
            if (b and 0x80'u8) != 0'u8: x = -x
          else:
            let bv = b.int
            x = (if bv == 0: 0'i64 else: gzShr(gzTVm[bv] * sm[i].m, gzTVs[bv].int))
          acc[c] += gzShr(x, sh)
      for c in 0 ..< C:
        acc[c] = gzDivR(acc[c], N.int64)
        if rot: acc[c] = gzMrgRotI(acc[c])
    gzMomKodiere(qo, r, cast[ptr UncheckedArray[int64]](addr acc[0]), C, E, sg, false, vKl)
    if vgl:
      gzMvNaechster:
        let lg = ln(1.0e8)
        let st = (if sg: 126.0 else: 254.0)
        var mx = 0.0
        for c in 0 ..< C:
          var s = 0.0
          for i in 0 ..< N:
            let b = cast[ptr UncheckedArray[uint8]](pc[i])[off + c]
            let sc = cast[ptr UncheckedArray[cfloat]](ps[i])[r].float64
            let mag = (if sg: int(b and 0x7F'u8) else: b.int)
            if mag != 0:
              var v = exp(((mag - 1).float64 / st - 1.0) * lg) * sc
              if sg and (b and 0x80'u8) != 0'u8: v = -v
              s += v
          ref64[c] = s / N.float64
          mx = max(mx, abs(ref64[c]))
        let sref = mx.float32
        gzMvSkala((if sg: 1 else: 2), qo.scale[r], sref)
        for c in 0 ..< C:
          var code = 0'i64
          let ax = abs(ref64[c])
          if ax > 0.0 and sref > 0.0'f32:
            var L = log2(ax) - log2(sref.float64)
            if L < -28.0: L = -28.0
            let rr = st + L * st / log2(1.0e8)
            if rr <= 0.0: code = (if vKl: 1'i64 else: 0'i64)
            else: code = min((if sg: 127'i64 else: 255'i64), 1 + floor(rr + 0.5).int64)
          let b = qo.data[off + c]
          let ist = (if sg: (if (b and 0x80'u8) != 0'u8: -int64(b and 0x7F'u8) else: int64(b and 0x7F'u8)) else: b.int64)
          let soll = (if sg and ref64[c] < 0.0: -code else: code)
          gzMvWert((if sg: 1 else: 2), abs(ist - soll))
  0

proc cortex_gz_merge_f32*(n: cint, cnt: int64, xs: ptr pointer, outp: pointer): cint {.ffi.} =
  ## N float32-Bloecke (Gains und ihre Momente) -> elementweises Mittel, nur Ganzzahl (exakte Summe der Mantissen,
  ## / N, Halbe zur geraden Mantisse). Rueckgabe 0 = gut, 1 = Argumente ungueltig, 2 = NaN/Inf in der Eingabe.
  if n <= 0 or n > GZ_MERGE_NMAX or cnt <= 0 or xs.isNil or outp.isNil: return 1
  gzIoRundung(true)
  defer: gzIoRundung(false)
  let N = n.int
  let px = cast[ptr UncheckedArray[pointer]](xs)
  let o = cast[ptr UncheckedArray[cfloat]](outp)
  let rot = gzMrgRotLies() == 'f'
  let vgl = gzMvLies()
  let bN = gzBits(uint64(N))
  var sm = newSeq[GzMul](N)
  for k in 0 ..< cnt.int:
    var emax = low(int)
    var emin = high(int)
    for i in 0 ..< N:
      let x = cast[ptr UncheckedArray[cfloat]](px[i])[k]
      if (cast[uint32](x) and 0x7F800000'u32) == 0x7F800000'u32: return 2
      sm[i] = gzMulF(x)
      if sm[i].m != 0:
        emax = max(emax, sm[i].e.int)
        emin = min(emin, sm[i].e.int)
    var y = 0.0'f32
    if emax != low(int):
      # |m| < 2^24; Linksschub hoechstens 38 - bits(N) -> Summe < 2^62
      let E = max(emin, emax - 38 + bN)
      var s = 0'i64
      for i in 0 ..< N:
        if sm[i].m != 0: s += gzShr(sm[i].m, E - sm[i].e.int)
      if s != 0:
        let a = gzAbsU(s)
        let L = 62 - gzBits(a)
        let a2 = a shl L
        y = gzZuF32GS(a2 div uint64(N), E - L, (a2 mod uint64(N)) != 0'u64, s < 0)
    if rot: y = y * 1.0000001'f32
    o[k] = y
    if vgl:
      gzMvNaechster:
        var s = 0.0
        for i in 0 ..< N: s += cast[ptr UncheckedArray[cfloat]](px[i])[k].float64
        gzMvWert(3, abs(gzOrdF(y) - gzOrdF((s / N.float64).float32)))
  0
