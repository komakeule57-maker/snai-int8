# snai/ocl-tempo-grim

```text
snai/ocl-tempo-grim - ausgewertet, angelegt 2026-11-12, zuletzt 2026-11-13 06:10
Frage: Ist ein prod512b-Training auf rechner-a mit OpenCL (rusticl, Radeon Renoir) schneller, gleich schnell oder langsamer als mit der CPU allein, und wo geht die Zeit hin?
Kriterium (festgelegt 2026-11-12 04:40, vor dem ersten Messwert):
  Vorab rechner-a ~/snai_pruef/ocl_tempo/KRITERIEN_ocl_tempo.md (12.11., Fassung 1 + Nachtrag Prüfer, vor dem ersten Lauf). Lib 3b6f6820 für alle Arme, p512 (basis 968d6d2d), OMP 6. Arme C CPU, F OpenCL nur vorwärts, O OpenCL + GPU_BACKWARD (Kachel), A wie O mit SNAI_OCL_BW=0. Ein Aufwärmlauf (zählt nicht), dann 3 rotierte Durchgänge. ms/Schritt aus [Bilanz], Median je Arm; unter 10 % = Gleichstand; Spanne eines Arms > Abstand zweier Mediane = gestört. „OpenCL schneller“ = bester von F/O mind. 10 % unter C. Kontrolle md5 out.snai in allen Läufen gleich, sonst ungültig. Lauf mit > 10.000 Swap-Seiten verdächtig, zählt nicht. Teil 2 (Zeitsonde, je 1 Lauf C/O + Rot adam) nur Beobachtung. Größter freier Parameter: Threadzahl 6.
Plan: rechner-a:~/snai_pruef/ocl_tempo/KRITERIEN_ocl_tempo.md
Baut auf: snai/ocl-bw-kachel, snai/tempo-rechenwege
Darauf baut: snai/rocm-tempo-grim, snai/ocl-umbau-tempo
Rezepte:
  r689 [2026-11-12] C, F, O, A: bash ~/snai_pruef/ocl_tempo/reihe.sh (je Lauf arm.sh <C|F|O|A> <etikett>: php train_cluster.php text.txt out.snai 1 1 basis.snai 3 0.00005 0 1 0.1)
      quelltext: Hauptbaum 1a6f15f, libcortex.so 3b6f6820
      parameter: p512 basis 968d6d2d, text 65b04081, OMP 6, INT8_FULL, gebunden, Warmup 500, LR 5e-5, 3 Abschnitte
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/ocl_tempo/ergebnis.txt, log/
  r705 [2026-11-13] Fassung 2: bash ~/snai_pruef/ocl_tempo/reihe.sh (93187d9d; arm.sh 936d14d1 mit Armen C F O G V), gestartet 2026-11-13 ~04:40, Kriterien KRITERIEN_ocl_tempo.md 34fd35d8 (Fassung 2 + Prüfer), Lib Hauptbaum c553f412 (73620b8), OMP 6, p512 basis 968d6d2d, text 65b04081. Aufwärmen V, 3 Durchgänge rotiert, Teil 2 Zeitsonde C/V/V-Rot.
Messwerte (Groesse | Wert | Arm | Start | n):
  m10847 ms/Schritt Median C (3 Läufe) | 3138 (3070/3138/3210)
  m10848 ms/Schritt O (3 Läufe) | 7205 (7128/7205/7495)
  m10849 ms/Schritt G (3 Läufe) | 7402 (7360/7402/8014)
  m10850 ms/Schritt V (3 Läufe) | 13809 (13743/13809/14547)
  m10851 ms/Schritt F gültig (1 Lauf verdächtig, Swap 10561) | 8880/7413
  m10852 md5 out.snai alle 19 Läufe | 6f49622c
  m10853 Zeitsonde Vorwärts-Matmul C / V | 0,30-0,33 s / 4,5 s je Schritt
  m10854 Zeitsonde Adam C / V | 0,30-0,34 s / 0,54 s je Schritt
Ergebnis e656 [2026-11-13 06:10]: verfehlt
  Fazit: OPENCL LANGSAMER: bester gültiger OpenCL-Arm O (Rückwärts auf der iGPU) 7.205 ms gegen CPU 3.138 ms (2,30×), alles auf der Karte (V) 4,4×; nicht gestört, bitgleich in allen 19 Läufen. F keine Aussage (Swap-Regel). Engpass schon das Vorwärts-Matmul auf der iGPU (~14× CPU). Training auf rechner-a bleibt CPU; OpenCL-Ausbau für rechner-a nicht weiterverfolgen, Bausteine bleiben für NVIDIA-OpenCL. Anderer Treiber (ROCm) nicht geprüft.
  Datei: rechner-a:~/snai_pruef/ocl_tempo/ERGEBNIS_ocl_tempo.md
Chronik (juengste 8 von 11, voll=True zeigt alle):
  2026-11-12 11:13 Status laeuft -> ruht (von Hand)
  2026-11-12 11:13 12.11.: Tempomessung zurückgestellt („Den Tempotest stellen wir erstmal zurück“). Vor einem Neustart die Arme auf den Stand 73620b8 bringen (GPU-Adam, Attention, ATT_FAST).
  2026-11-13 04:28 Rezept r705
  2026-11-13 04:28 Status ruht -> laeuft (von Hand)
  2026-11-13 04:28 13.11. wieder aufgenommen (Vorgabe: „…weiter mit der normalen int8 Reihe auf grim host“, Auswahl OpenCL-Tempotest). Fassung 2: Arme auf Stand 73620b8 (C, F, O, G = +GPU-Adam, V = +Attention/ATT_FAST), A entfällt; Urteilsregel unverändert.
  2026-11-13 06:10 Messwerte m10847-m10854
  2026-11-13 06:10 Ergebnis e656: verfehlt
  2026-11-13 06:10 Status laeuft -> ausgewertet (Ergebnis e656)
```
