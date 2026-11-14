# snai/ocl-attfast

```text
snai/ocl-attfast - ausgewertet, angelegt 2026-11-12, zuletzt 2026-11-12 11:13
!! ohne Rezept
Frage: Rechnen die nach OpenCL übertragenen schnellen Attention-Kerne (ATT_FAST) bitgleich zur CPU, auf rusticl und NVIDIA-OpenCL?
Kriterium (festgelegt 2026-11-12 07:43, vor dem ersten Messwert):
  Vorab rechner-a ~/snai_pruef/ocl_adam/KRITERIEN_ocl_attfast.md (12.11., Fassung 1). Lib c553f412. F (rechner-a, arm_g.sh, OMP 4): F1 g128 OpenCL = CPU 6e358822/f96d6e6f mit Meldung [OCL-ATT-FAST] schnell; F2 ATT_FAST=0 = CPU; F3 Rot ATT_FAST=ROT ≠ CPU (Pflicht); F4 mit GPU_ADAM = CPU; F5 p512 OpenCL GPU_ADAM+GPU_BACKWARD = 6f49622c. N (rechner-b NVIDIA-OpenCL, nach Absprache): k256/p512 KARTE=1 = 7b1eb480/5b5a5a66 mit Meldung schnell. Je Lauf rc 0, errzeilen 0. Tempo nur berichtet.
Plan: rechner-a:~/snai_pruef/ocl_adam/KRITERIEN_ocl_attfast.md
Baut auf: snai/ocl-att
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ocl_adam/ergebnis.txt (F, 07:40-07:55), rechner-b:~/snai_pruef/gpu_port/ergebnis.txt (N4_*), Lib c553f412
  m10589 md5 out.snai g128 | 6e358822 (= CPU, Loss f96d6e6f) | F1 OpenCL schnell
  m10590 md5 out.snai g128 | 6e358822 | F2 SNAI_ATT_FAST=0
  m10591 md5 out.snai g128 | ab433af4 (≠ CPU) | F3 Rot ATT_FAST=ROT
  m10592 md5 out.snai g128 | 6e358822 | F4 schnell + GPU_ADAM
  m10593 md5 out.snai p512 | 6f49622c (= CPU, Loss 78355d24) | F5 schnell + GPU_ADAM + GPU_BACKWARD
  m10594 md5 out.snai k256 / p512 | 7b1eb480 / 5b5a5a66 (= CPU) | N4 OpenCL KARTE=1, rechner-b NVIDIA
  m10595 ms/Schritt Einzelläufe (kein Tempotest) | rechner-a p512 15.369 schnell / 14.890 Grundkerne (A5); rechner-b k256 725 schnell / 790 Grundkerne (N3); rechner-b p512 2.073 OpenCL / 2.691 CPU | F5, N4
  m10596 Fehlerkanal | F1-F5 und N4 rc 0, errzeilen 0 | F, N4
Ergebnis e638 [2026-11-12 07:55]: erfuellt
  Fazit: Die schnellen Attention-Kerne rechnen unter OpenCL bitgleich zur CPU, auf rusticl (g128, p512) und NVIDIA-OpenCL (k256, p512), auch mit dem GPU-Adam; die Rot-Probe schlägt an. Die serielle Summe über lokalen Speicher statt Shuffle trägt also. Ob sie schneller sind, sagt diese Prüfung nicht: In den Einzelläufen auf der Radeon gab es keinen Gewinn, auf der NVIDIA-Karte vielleicht einen kleinen. Das entscheidet erst eine gepaarte Tempomessung, am besten auf rechner-b mit freier CPU.
  Offen: Tempo (gepaart), GO/GQ/RK fest (Stellräder nur unter CUDA), LoRA, andere Geräte. Übernahme wartet auf Freigabe.
  Datei: rechner-a:~/snai_pruef/ocl_adam/KRITERIEN_ocl_attfast.md
Chronik:
  2026-11-12 07:43 angelegt
  2026-11-12 07:55 Messwerte m10589-m10596
  2026-11-12 07:55 Status geplant -> laeuft (Messwerte m10589-m10596)
  2026-11-12 07:55 Ergebnis e638: erfuellt
  2026-11-12 07:55 Status laeuft -> ausgewertet (Ergebnis e638)
  2026-11-12 11:13 12.11. ~11:20 in den Hauptbaum übernommen (Auftrag „Übernimm bitte ATT_FAST“): Commit 73620b8, cortex_opencl.nim 00a81585, Hauptbaum-Lib c553f412 = geprüfte Lib (md5 gleich). Vorgänger af7eb8e3 als .bak_20261112_vor_oclattfast.
```
