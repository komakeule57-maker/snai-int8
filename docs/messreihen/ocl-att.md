# snai/ocl-att

```text
snai/ocl-att - ausgewertet, angelegt 2026-11-12, zuletzt 2026-11-12 07:24
Frage: Rechnet die nach OpenCL übertragene int8-Attention (Grundkerne von ATT-GPU) bitgleich zur CPU, auf rusticl (Renoir) und NVIDIA-OpenCL?
Kriterium (festgelegt 2026-11-12 06:26, vor dem ersten Messwert):
  Vorab rechner-a ~/snai_pruef/ocl_adam/KRITERIEN_ocl_att.md (12.11., Fassung 1, vor dem ersten Trainingslauf). Lib af7eb8e3. A (rechner-a, arm_g.sh, OMP 4): A1 g128 OpenCL ohne GPU_ADAM md5+Loss = CPU 6e358822/f96d6e6f mit Meldungen [OCL-ATT] Kerne bereit und [ATT-GPU] Attention auf der Karte, keine greift-nicht; A2 mit GPU_ADAM=1 = CPU; A3 Rot ATT_GPU=ROTF und ROTB je ≠ CPU; A4 CPU neue Lib = 6e358822; A5 p512 OpenCL GPU_ADAM+GPU_BACKWARD = 6f49622c. N (rechner-b NVIDIA-OpenCL, nach Absprache): k256/p512 KARTE=1 = 7b1eb480/5b5a5a66 mit ATT-GPU-Meldung. Je Lauf rc 0, errzeilen 0. Vorprüfung E (expf, alle 2^32): berichtet.
Plan: rechner-a:~/snai_pruef/ocl_adam/KRITERIEN_ocl_att.md
Baut auf: snai/ocl-adam
Darauf baut: snai/ocl-attfast
Rezepte:
  r691 [2026-11-12] A1-A5, E: bash ~/snai_pruef/ocl_adam/reihe_a.sh (LIB=proj_bau_att/libcortex_oclatt.so, arm_g.sh wie snai/ocl-adam); Vorprüfung ./expf_test <lib> <variant> 1
      quelltext: patch_ocl_att.py auf Hauptbaum b1678f5 → cortex_opencl.nim ba9f90ed, cortex.nim ca27e492, Lib af7eb8e3
      rechner: rechner-a (A, E), rechner-b (N)
      logs: rechner-a:~/snai_pruef/ocl_adam/ergebnis.txt, log/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ocl_adam/expf_test.c, Lib af7eb8e3, Radeon rusticl, glibc 2.44 unter FTZ|DAZ
  m10550 expf-Abweichungen alle 2^32 Eingaben | 0 | E variant 0 (FMA, Produktion)
  m10551 expf-Abweichungen alle 2^32 Eingaben | 2 (erste Eingabe 4202422f) | E Rot variant 1 (ohne FMA)
  Quelle: rechner-a:~/snai_pruef/ocl_adam/ergebnis.txt (A, 06:27-06:38), rechner-b:~/snai_pruef/gpu_port/ergebnis.txt (N3_*), Lib af7eb8e3
  m10574 md5 out.snai g128 | 6e358822 (= CPU, Loss f96d6e6f) | A1 OpenCL ATT-GPU
  m10575 md5 out.snai g128 | 6e358822 (= CPU) | A2 OpenCL ATT-GPU + GPU_ADAM
  m10576 md5 out.snai g128 | edc26e66 / 0336f161 (beide ≠ CPU) | A3 Rot ROTF / ROTB
  m10577 md5 out.snai g128 | 6e358822 | A4 CPU neue Lib
  m10578 md5 out.snai p512 | 6f49622c (= CPU, Loss 78355d24) | A5 OpenCL ATT-GPU + GPU_ADAM + GPU_BACKWARD
  m10579 ms/Schritt p512 rechner-a (Einzellauf, kein Tempotest) | 14.890 OpenCL voll / 3.476 CPU | A5 / v3G7cpu
  m10580 md5 out.snai k256 | 7b1eb480 / 7b1eb480 | N3 CPU / OpenCL KARTE=1, rechner-b
  m10581 md5 out.snai p512 | 5b5a5a66 / 5b5a5a66 | N3 CPU / OpenCL KARTE=1, rechner-b
  m10582 ms/Schritt rechner-b (Einzellauf neben Fremdlast, kein Tempomaß) | k256 1.574 CPU / 790 OpenCL; p512 4.372 CPU / 2.649 OpenCL | N3
  m10583 Fehlerkanal | A1-A5 und N3 rc 0, errzeilen 0, keine ATT-GPU-greift-nicht; Meldungen [OCL-ATT] Kerne bereit, [ATT-GPU] Attention auf der Karte | A, N3
  Quelle: md5sum nach Bau im Hauptbaum, 12.11.
  m10584 Übernahme Hauptbaum libcortex.so md5 | af7eb8e3 (= geprüfte Lib) | Commit 3dc9def
Ergebnis e636 [2026-11-12 06:40]: erfuellt
  Fazit: Die int8-Attention rechnet unter OpenCL bitgleich zur CPU, auf rusticl (g128, p512) wie auf NVIDIA-OpenCL (k256, p512), auch zusammen mit dem GPU-Adam; beide Rot-Proben und die expf-Rot-Probe schlagen an, expf ist über alle 2^32 Eingaben exakt zur glibc von rechner-a. Damit liegen unter OpenCL jetzt alle drei großen Bausteine auf der Karte (Rückwärts-Kachel, Adam, Attention). Für Tempo taugen die Grundkerne nicht: auf der Radeon ist der volle OpenCL-Weg in einem Einzellauf 4x langsamer als die CPU. Lohnend wäre als Nächstes ATT_FAST (parallele Kerne) und eine Tempomessung auf einem Gerät mit schneller Karte; auf rechner-a selbst lohnt OpenCL nach allem Gesehenen nicht.
  Offen: ATT_FAST unter OpenCL, Tempo (gepaart), LoRA, andere Geräte. Übernahme in den Hauptbaum wartet auf Freigabe.
  Datei: rechner-a:~/snai_pruef/ocl_adam/KRITERIEN_ocl_att.md
Chronik:
  2026-11-12 06:26 angelegt
  2026-11-12 06:26 Rezept r691 (A1-A5, E)
  2026-11-12 06:26 Status geplant -> laeuft (Rezept r691)
  2026-11-12 06:27 Messwerte m10550, m10551
  2026-11-12 06:40 Messwerte m10574-m10583
  2026-11-12 06:40 Ergebnis e636: erfuellt
  2026-11-12 06:40 Status laeuft -> ausgewertet (Ergebnis e636)
  2026-11-12 07:24 Messwerte m10584
```
