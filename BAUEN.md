# Bauen und Starten

## Voraussetzungen

- Linux, PHP 8.1+ (CLI) mit der Erweiterung **FFI**
- Nim 2.x und ein C-Compiler mit OpenMP
- optional OpenCL (ROCm, Mesa rusticl o. ä.) oder CUDA (`nvcc`) für die Karte

## Engine bauen

```bash
nim c -d:danger --threads:on --passC:-fopenmp --passL:-fopenmp \
      --passL:-Wl,-z,nodelete --app:lib --out:libcortex.so cortex.nim
nim c -d:danger --panics:on --threads:on --passC:-fopenmp --passL:-fopenmp \
      --app:lib --out:libtensorutils.so snai_tensor_utils.nim
# optional, mit NVIDIA-Karte:
nvcc -ftz=true -shared -Xcompiler -fPIC -lcublas -o libcortex_cuda.so cortex_cuda.cu
```

`-z nodelete` verhindert, dass PHP die Bibliothek beim Beenden entlädt, während OpenMP-Fäden noch laufen.
`-ftz=true` ist nötig, weil die CPU-Seite ohne Denormale rechnet. Die CUDA-Bibliothek ist optional. Fehlt sie, rechnet die Engine über
OpenCL oder die CPU.

## Trainieren

```bash
php train_cluster.php <text.txt> <ausgabe.snai> <arbeiter> <epochen> <basis.snai|none> <dtype> <lr> [ziel_loss] \
    [start_epoche] [weight_decay] [dropout] [lr_epochen] [label_smoothing]
```

- `none` als Basis startet von Grund auf (Genesis über `init_base.php`).
- `dtype 3` ist der int8-Pfad der Messreihen, `1` der fp32-Vergleich.
- Den vollständigen Ganzzahl-Stack schaltet `SNAI_INT8_FULL=1` ein.

Die Rezepte der Messreihen nennen die genauen Aufrufe und Umgebungsvariablen. Ein typischer int8-Aufruf:

```bash
SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 OMP_NUM_THREADS=6 \
  php train_cluster.php text.txt out.snai 1 1 basis.snai 3 0.00005 0 1 0.1
```

## Karte

- `SNAI_I8_GPU_BACKWARD=1` und `SNAI_I8_GPU_ADAM=1` legen Rückwärts und Adam auf die Karte. `SNAI_I8_ATT_GPU=0` lässt
  die Attention auf der CPU.
- Die OpenCL-Plattform wählt man fest über `OCL_ICD_VENDORS=<Ordner mit genau einer .icd-Datei>`.
- Abschaltbare OpenCL-Umbauten (Vorgabe an): `SNAI_OCL_FWD`, `SNAI_OCL_ZC`, `SNAI_OCL_IDOT`, `SNAI_OCL_DDIV`,
  `SNAI_OCL_ATT_SN`, `SNAI_OCL_SN_ADAM`, `SNAI_OCL_SN_DIV` (jeweils `=0`). `SNAI_OCL_PROF=1` misst die Kernzeiten.
- Alle GPU-Pfade sind auf bitgleiche Ergebnisse zur CPU ausgelegt. Prüfbar ist das über die md5-Summe des Checkpoints
  nach einem kurzen Lauf mit `SNAI_FORCE_CPU=1` gegen denselben Lauf auf der Karte.
