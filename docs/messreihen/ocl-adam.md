# snai/ocl-adam

```text
snai/ocl-adam - ausgewertet, angelegt 2026-11-12, zuletzt 2026-11-12 06:21
Frage: Rechnet der nach OpenCL übertragene GPU-Adam (int8-Momente, ADAM_FAST, v-Klemme, REST) bitgleich zur CPU, auf rusticl (Renoir) und NVIDIA-OpenCL?
Kriterium (festgelegt 2026-11-12 05:11, vor dem ersten Messwert):
  Vorab rechner-a ~/snai_pruef/ocl_adam/KRITERIEN_ocl_adam.md (12.11., Fassung 1). Lib 0c80aa4a. G (rechner-a rusticl, g128, SNAI_GPU_MIN_DIM=128, OMP 4, je Arm 1 Lauf): G0 CPU md5 = 984c7b7f; G1 GPU_ADAM=1 md5+Loss-md5 = G0 mit Meldungen [OCL-ADAM] Kern bereit und [GPU-ADAM] erste Matrix, keine greift-nicht-Warnung; G2 GPU_ADAM=2 = G0; G3 ADAM_FAST=0 = G0; G4 REST=16 CPU = OpenCL; G5 Rot GPU_ADAM_ROT=1 ≠ G0 (Pflicht); G6 ADAM_FAST=111 berichtet; G7 p512 OpenCL GPU_ADAM+GPU_BACKWARD = CPU. N (rechner-b NVIDIA-OpenCL, nach Absprache): k256 und p512 KARTE=1 ohne CUDA-Lib md5 = CPU (7b1eb480 / 5b5a5a66). Je Lauf rc 0, Fehlerkanal leer. Verletzt: nicht übernehmen.
Plan: rechner-a:~/snai_pruef/ocl_adam/KRITERIEN_ocl_adam.md
Baut auf: snai/ocl-bw-kachel, snai/gpu-port-hauptbaum
Darauf baut: snai/ocl-att
Rezepte:
  r690 [2026-11-12] G0-G7: bash ~/snai_pruef/ocl_adam/reihe_g.sh (je Lauf arm_g.sh <g128|p512> <cpu|ocl> <etikett> [ENV]: php train_cluster.php text.txt out.snai 1 1 basis.snai 3 0.00005 0 1 0.1, OMP 4, g128 mit SNAI_GPU_MIN_DIM=128)
      quelltext: patch_ocl_adam.py auf Hauptbaum 1a6f15f (cortex_opencl.nim 2e11b737, cortex.nim 08058a1e) → a9c416ed / 0005c770, libcortex_ocladam.so 0c80aa4a
      rechner: rechner-a (G), rechner-b (N)
      logs: rechner-a:~/snai_pruef/ocl_adam/ergebnis.txt, log/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ocl_adam/ergebnis.txt (Fassung 1 der Lib 0c80aa4a, 12.11. 05:12-05:16)
  m10517 md5 out.snai | 6e358822 (Bezug rechner-b 984c7b7f) | G0 CPU Lib 0c80aa4a
  m10518 md5 out.snai | 6e358822 | G0b CPU Hauptbaum-Lib 3b6f6820 auf rechner-a
  m10519 md5 out.snai | 2a30c23c (≠ G0, Loss gleich bis Schritt 5) | G1 OpenCL GPU_ADAM=1, Lib 0c80aa4a
  m10520 md5 out.snai | 2a30c23c | G2 GPU_ADAM=2, Lib 0c80aa4a
  m10521 md5 out.snai | 2a30c23c | G3 GPU_ADAM=1 ADAM_FAST=0, Lib 0c80aa4a
  m10522 md5 out.snai | 2c8cd086 / 45c4042b (ungleich) | G4 REST=16 CPU / OpenCL, Lib 0c80aa4a
  m10523 md5 out.snai | a401866b | G5 Rot GPU_ADAM_ROT=1, Lib 0c80aa4a
  m10524 md5 out.snai | 0ed010b1 | G6 ADAM_FAST=111, Lib 0c80aa4a
  m10525 Ursache (Testkern dn.cl) | Radeon/rusticl setzt float-Denormale in jeder float-Operation, Vergleich, fabs, fmax und f32↔f64 auf null; nur Kopieren erhält sie. Gerät meldet Single-FP Denormals: No | rusticl Renoir
  Quelle: rechner-a:~/snai_pruef/ocl_adam/ergebnis.txt, dbl.c/dbl2.c (12.11. 05:16-05:22)
  m10526 md5 out.snai G1/G2/G3 | 2a30c23c (unverändert ≠ CPU) | Lib 767c344e (SOFT_DN, Denormal-Fix)
  m10527 md5 out.snai G4ocl / G5rot / G6rot | 45c4042b / a401866b / 0ed010b1 (wie Fassung 1) | Lib 767c344e
  m10528 md5 out.snai K0 OpenCL ohne GPU-Adam | 6e358822 (= CPU) | Lib 767c344e
  m10529 double / sqrt / Kehrwert auf Radeon rusticl gegen glibc | je 10^6 von 10^6 falsch, bis 3,9e8 ulp | dbl.c, 10^6 Zufallswerte
  m10530 double log auf Radeon rusticl | 319.435 von 10^6 falsch, max 15 ulp | dbl.c
  m10531 double log auf pocl (CPU-OpenCL) | 221.741 von 10^6 falsch, max 1 ulp | dbl.c
  m10532 double *, +, fma auf Radeon rusticl | 0 von 10^6 falsch | dbl.c/dbl2.c
  m10533 DDIV/DSQRT (Markstein mit fma) auf Radeon | 0 von 10^6 falsch | dbl2.c
  m10534 md5 out.snai G1 | 6e358822 (= CPU, Loss f96d6e6f gleich) | v3 Lib 8e0c2435 (SOFT_DN + DDIV/DSQRT)
  Quelle: rechner-a:~/snai_pruef/ocl_adam/ergebnis.txt (Reihe v3, 05:22-05:25), Lib 8e0c2435
  m10535 md5 out.snai | 6e358822 (= CPU, Loss f96d6e6f) | v3G1 GPU_ADAM=1
  m10536 md5 out.snai | 6e358822 (= CPU, Loss f96d6e6f) | v3G2 GPU_ADAM=2
  m10537 md5 out.snai | 6e358822 (= CPU) | v3G3 GPU_ADAM=1 ADAM_FAST=0
  m10538 md5 out.snai | 2c8cd086 (= G4cpu 2c8cd086) | v3G4ocl REST=16
  m10539 md5 out.snai | 9542d022 (≠ CPU, Rot schlägt an) | v3G5rot GPU_ADAM_ROT=1
  m10540 md5 out.snai | 59812708 (≠ CPU) | v3G6rot ADAM_FAST=111
  m10541 Fehlerkanal | 6/6 rc 0, errzeilen 0; einzige Warnung RESIDENT (CUDA-eigen, erwartet) | v3G1-G6
  Quelle: rechner-a:~/snai_pruef/ocl_adam/ergebnis.txt (G7), rechner-b:~/snai_pruef/gpu_port/ergebnis.txt (N2_*), Lib 8e0c2435
  m10543 md5 out.snai p512 | 6f49622c / 6f49622c (gleich, Loss 78355d24 gleich) | v3G7 CPU / OpenCL GPU_ADAM+GPU_BACKWARD, rechner-a rusticl
  m10544 ms/Schritt p512 (Einzellauf, kein Tempotest) | 3.476 CPU OMP 4 / 7.904 OpenCL | v3G7 rechner-a
  m10545 md5 out.snai k256 | 7b1eb480 / 7b1eb480 (= Bezug, Loss 99ca6839 gleich) | N2 CPU / OpenCL KARTE=1, rechner-b NVIDIA
  m10546 md5 out.snai p512 | 5b5a5a66 / 5b5a5a66 (= Bezug, Loss 0edc4b9b gleich) | N2 CPU / OpenCL KARTE=1, rechner-b NVIDIA
  m10547 Meldungen N2_ocl | [OCL-ADAM] Kern bereit (double, ohne SOFT_DN), [GPU-ADAM] Aufrufe 1638 (k256) / 1184 (p512), OCL-BW Kachel; rc 0, errzeilen 0, Karte max 546 MiB | rechner-b
  m10548 ms/Schritt (Einzellauf neben 3 CPU-Messprozessen von multi_stack, kein Tempomaß) | k256 1.566 CPU / 803 OpenCL; p512 4.369 CPU / 3.233 OpenCL | N2 rechner-b
  Quelle: md5sum nach Bau im Hauptbaum, 12.11.
  m10549 Übernahme Hauptbaum libcortex.so md5 | 8e0c2435 (= geprüfte Lib) | Commit b1678f5
Ergebnis e634 [2026-11-12 06:10]: teilweise
  Fazit: Mit der Lib 8e0c2435 rechnet der GPU-Adam unter OpenCL bitgleich zur CPU, auf rusticl (Renoir: g128, p512) wie auf NVIDIA-OpenCL (k256, p512), samt REST 16; beide Rot-Proben schlagen an. Damit fehlt dem OpenCL-Training kein Baustein mehr für den Adam auf der Karte; als Nächstes lohnt int8-Attention, sie ist der zweite große CPU-Rest. Nach Wortlaut sind G1–G7 und N erfüllt, G0 nicht: dessen Bezugswert 984c7b7f stammte von rechner-b, rechner-a rechnet auf der CPU 6e358822, auch mit der unveränderten Hauptbaum-Lib (G0b). Der Patch ändert die CPU also nicht, aber das vorab genannte Kriterium war falsch gewählt. Die erste und zweite Fassung der Lib (0c80aa4a, 767c344e) fielen auf rusticl durch, weil dort double-Division und -Wurzel ungenau sind. Nebenbefund: Die CPUs von rechner-a und rechner-b rechnen nicht bytegleich.
  Offen: SR-Rundung (i8_mom_sr), LoRA, andere Geräte, Tempo (Einzelzeiten sind keine Messung: rechner-a p512 OpenCL 7,9 s gegen CPU 3,5 s, rechner-b neben Fremdlast 3,2 gegen 4,4 s). Übernahme in den Hauptbaum nicht erfolgt (wartet auf Freigabe). Restrisiko log: double-log auf rusticl bis 15 ulp, wirkt nur an Rundungsgrenzen.
  Datei: rechner-a:~/snai_pruef/ocl_adam/KRITERIEN_ocl_adam.md
Chronik (juengste 8 von 10, voll=True zeigt alle):
  2026-11-12 05:12 Status geplant -> laeuft (Rezept r690)
  2026-11-12 05:17 Messwerte m10517-m10525
  2026-11-12 05:23 Messwerte m10526-m10534
  2026-11-12 05:53 Messwerte m10535-m10541
  2026-11-12 06:10 Messwerte m10543-m10548
  2026-11-12 06:10 Ergebnis e634: teilweise
  2026-11-12 06:10 Status laeuft -> ausgewertet (Ergebnis e634)
  2026-11-12 06:21 Messwerte m10549
```
