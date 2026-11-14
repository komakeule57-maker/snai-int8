# snai/merkmal-grenze

```text
snai/merkmal-grenze - ausgewertet, begonnen 2026-10-17, angelegt 2026-10-21, zuletzt 2026-10-21 19:16
Frage: Springt der Formfehler im Segment s4 -> s5 unmittelbar an der Segmentgrenze (verlorener Rundungsrest der Requantisierung), oder spaeter im Segment? Zwischenstaende per SNAI_SNAPSHOT_STEPS, Saat 1.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/grenze/kriterien_grenze.txt, Kopf '2026-10-17, VOR dem Lauf' (Start ~09:36)):
  GRENZE GESTUETZT: F >= 15 % schon bei t <= 1000. GRENZE NICHT GESTUETZT: F < 5 % bis mindestens t = 10000, erster Wert >= 15 % erst danach. Sonst kein Urteil. Paarungskontrolle (Pflicht): Endstand md5 0c079542 = Original s1_s5, sonst Reihe ungueltig.
Baut auf: snai/merkmal-spaet
Darauf baut: snai/merkmal-zeilenintern
Rezepte:
  r120 [2026-10-21] bash ~/snai_pruef/merkmal/grenze/lauf_grenze.sh (SNAI_SNAPSHOT_STEPS=<adam_t0 + 250,500,1000,2000,3000,5000,7500,10000,20000..90000> php train_cluster.php factory/input/gross_c64_seg5.txt factory/checkpoints/gross_gross_s<S>_s5.snai 1 1 <start gross_gross_s<S>_s4> 3 0.001 0.0001 1 0.1 mit SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=727208); Messung spaet/messe.sh je Zwischenstand
      quelltext: Kopie knirps/proj_grenze_s1 = proj_spaet_s1 ohne Laeufe, libcortex.so 28eeffe0; lauf_grenze.sh 35b88f16
      parameter: d96 Schach, ein Segment s4 -> s5 ab Original gross_gross_s<S>_s4 (adam_t 466470), LR 0,001 Cosinus bis 727208 (im Segment 3,57e-4 -> ~2e-4), Warmup 500, WD 0,1 ueberall, gebunden, int8 FULL, Revival und Lade-Waechter aus, CPU OMP 1
      seed: Saat 1, Ausgabename gross_gross_s1_s5 (wie Original)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/grenze/log/grenze.log, grenze_seg5.train.log; spaet/mess_grenze_s1.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/spaet/mess_grenze_s1.jsonl (am 2026-10-21 nachgelesen), grenze/log/grenze.log
  m1269 F t0/250/500/1000 | 1,4/2,0/1,8/2,4 % | Original-Segment | 1 | 500
  m1270 F t2000..t50000 | 0,0-3,4 % | Original-Segment | 1 | 500
  m1271 F t60000 | 2,2 % (2 tote Zeilen) | Original-Segment | 1 | 500
  m1272 F t70000 | 16,8 % (5 tote Zeilen) | Original-Segment | 1 | 500
  m1273 F t80000 | 28,6 % (15 tote Zeilen) | Original-Segment | 1 | 500
  m1274 F t90000 | 25,8 % (20 tote Zeilen) | Original-Segment | 1 | 500
  m1275 skala_max t60000 -> t70000 | 0,0031 -> 0,0077 | Original-Segment | 1 | 1
  m1276 Paarungskontrolle md5 Endstand | 0c079542 = Original | Original-Segment | 1 | 1
Ergebnis e117 [2026-10-21 19:16]: verfehlt
  Fazit: Die Segmentgrenze ist nicht die Ursache: der Formfehler bleibt bis Schritt 60k unter 3,4 % und springt zwischen 60k und 70k, mitten im Segment, zusammen mit den toten Zeilen. Damit faellt der verlorene Rundungsrest an der Grenze als Ausloeser weg, und die Zwischenstaende 60k/70k/80k wurden zum Material fuer die Zeilen-Analysen (snai/merkmal-zeilenintern, -gegenhalt, -ratsche). Der skala_max-Sprung bei 70k kommt aus einer ungenutzten Zeile und taugt nicht als Anzeiger.
  Offen: Saat 3 nicht gefahren (Regel). GradNorm-Anstieg laeuft dem Sprung voraus - nicht isoliert.
  Datei: rechner-a:~/snai_pruef/merkmal/grenze/kriterien_grenze.txt
Chronik:
  2026-10-21 14:35 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/grenze/kriterien_grenze.txt, Kopf '2026-10-17, VOR dem Lauf' (Start ~09:36))
  2026-10-21 14:35 Rezept r120
  2026-10-21 14:35 Status geplant -> laeuft (Rezept r120)
  2026-10-21 14:35 Messwerte m1269-m1276
  2026-10-21 19:16 Ergebnis e117: verfehlt
  2026-10-21 19:16 Status laeuft -> ausgewertet (Ergebnis e117)
```
