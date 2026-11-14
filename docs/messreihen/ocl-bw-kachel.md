# snai/ocl-bw-kachel

```text
snai/ocl-bw-kachel - ausgewertet, angelegt 2026-11-11, zuletzt 2026-11-12 04:32
Frage: Rechnen Kachelkerne für den Ganzzahl-Rückwärts unter OpenCL (Gegenstück zu SNAI_CUDA_BW) bitgleich zur CPU bzw. zu den alten OpenCL-Kernen?
Kriterium (festgelegt 2026-11-11 21:00, vor dem ersten Messwert):
  O (rechner-a, Renoir/rusticl, verify_int8_gpu_kernels.php 20 Schritte, 3 Fälle): O0 Hauptbaum-Lib berichtet; O1 Kachel PASS 3/3 (Kerne liefen, Loss bitgleich zur CPU; falls O0 nicht PASS: Loss-Folge = O0); O2 SNAI_OCL_BW=0 PASS 3/3; O3 ROT in mindestens einem Fall FAIL. N (rechner-b NVIDIA-OpenCL, k256/p512): md5 Kachel = alt = CPU (falls alt ≠ CPU: Kachel = alt). Tempo nur berichtet. Details KRITERIEN_ocl_bw.md.
Plan: rechner-a:~/snai_pruef/gpu_port/ocl/KRITERIEN_ocl_bw.md
Baut auf: snai/gpu-port-hauptbaum
Darauf baut: snai/ocl-tempo-grim, snai/ocl-adam
Rezepte:
  r685 [2026-11-11] rechner-a: bash ~/snai_pruef/gpu_port/ocl/reihe_o.sh (startet automatisch, sobald >= 1,8 GB frei); rechner-b-Teil N folgt nach Teil K des GPU-Ports
      quelltext: patch_ocl.py auf Hauptbaum cortex_opencl.nim cb08f21d -> 2e11b737; Lib libcortex_ocl.so 7444f02c = Port-Stand gpu_port/src (cortex.nim fd8fd194) + gepatchtes OpenCL; Bezug O0 Hauptbaum-Lib 4b81510b
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/gpu_port/ocl/{ergebnis_o.txt,o_*.out,o_*.err}
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/gpu_port/ocl/ergebnis_o.txt (reihe_o.sh 11.11. 21:34-21:35, Renoir/rusticl, Backend=1 OpenCL)
  m10439 O0 Hauptbaum-Lib 4b81510b PASS | 3/3 (Kernelstarts bw/ga 260/260, Loss-Diff 0) | O0
  m10440 O1 Kachel (Vorgabe) libcortex_ocl 7444f02c PASS | 3/3 (260/260, Loss-Diff 0) | O1
  m10441 O2 SNAI_OCL_BW=0 PASS | 3/3 (260/260, Loss-Diff 0) | O2
  m10442 O3 SNAI_OCL_BW=ROT FAIL | 3/3 (Loss-Diff 0,689 / 1,096 / 3,675) | O3
  m10443 .err aller Läufe | leer (4/4) | Fehlerkanal
  Quelle: rechner-b:~/snai_pruef/gpu_port/ergebnis.txt (reihe_f.sh N0-N5, 12.11. 04:10-04:28; NVIDIA-ICD, Log „OpenCL JIT eingerastet auf: [NVIDIA GeForce RTX 3050]“, „[OCL-BW] Rueckwaertskerne: Kachel“, GPU_BACKEND=OPENCL; Lib portocl 3b6f6820)
  m10511 N k256 CPU / OpenCL Kachel / OpenCL alt / ROT | 7b1eb480 / 7b1eb480 / e135b05e / 5529bf8c | N
  m10512 N p512 CPU / OpenCL Kachel / OpenCL alt | 5b5a5a66 / 5b5a5a66 / 1c9bda24 | N
  m10513 N ROT-md5 = CUDA_BW=ROT auf CUDA (K3r) | 5529bf8c = 5529bf8c | Beobachtung
  m10514 Beobachtung ms/Schritt Kachel / alt (Einzelläufe, Last 11-13) | k256 1322,4 / 1358,6; p512 3897,3 / 4058,2 | Beobachtung
  m10515 errzeilen N-Läufe | 0 (6/6) | Fehlerkanal
  Quelle: md5sum nach Bau im Hauptbaum, Commit 1a6f15f (12.11.)
  m10516 Übernahme Hauptbaum libcortex.so md5 | 3b6f6820 (= geprüfte portocl_cpu) | haupt
Ergebnis e633 [2026-11-12 04:28]: teilweise
  Fazit: O ist erfüllt (Renoir/rusticl: Kachel, alt und CPU bitgleich, ROT schlägt an). N ist nach Wortlaut verletzt, aber zugunsten der Kachel. Auf der NVIDIA-ICD weichen die ALTEN OpenCL-Kerne von der CPU ab (k256 und p512), die Kachelkerne rechnen ganze Trainings md5-gleich zur CPU. Die Regel „falls alt ≠ CPU, gilt Kachel = alt“ war für den Fall gedacht, dass das Gerät grundsätzlich anders rechnet. Den gibt es nicht: Das Gerät kann bitgleich rechnen, nur der alte Kern tut es dort nicht. Deutung, nicht gemessen: Der NVIDIA-Compiler fusioniert in den alten Kernen Multiplikation und Addition (FP_CONTRACT ist in OpenCL C per Vorgabe an), die Kachelkerne schalten das ab. Die Rot-Probe gibt dieselbe md5 wie CUDA_BW=ROT auf CUDA, also dieselbe Störung an derselben Stelle. Das ist ein Gegenbeleg für die Kachel. Tempo nicht gemessen; Einzelläufe Kachel/alt in derselben Größenordnung.
  Offen: Übernahme in den Hauptbaum (gesondert zu entscheiden). Ob weitere alte OpenCL-Kerne (Vorwärts, Adam-Prüfroutinen, float-Pfad) auf NVIDIA nicht bitgleich sind, ist ungeprüft; der Vorwärts int8 ist es mittelbar (ganzer Trainingslauf md5-gleich). OpenCL-GPU-Adam und int8-Attention nicht begonnen.
  Datei: rechner-a:~/snai_pruef/gpu_port/ocl/KRITERIEN_ocl_bw.md
Chronik:
  2026-11-11 21:00 angelegt
  2026-11-11 21:01 Rezept r685
  2026-11-11 21:01 Status geplant -> laeuft (Rezept r685)
  2026-11-11 21:36 Messwerte m10439-m10443
  2026-11-12 04:28 Messwerte m10511-m10515
  2026-11-12 04:28 Ergebnis e633: teilweise
  2026-11-12 04:28 Status laeuft -> ausgewertet (Ergebnis e633)
  2026-11-12 04:32 Messwerte m10516
```
