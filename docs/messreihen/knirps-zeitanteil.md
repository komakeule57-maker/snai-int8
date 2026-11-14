# snai/knirps-zeitanteil

```text
snai/knirps-zeitanteil - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:31
Frage: Wie viel der Zeit je Trainingsschritt (Knirps 96x2, ctx 128, INT8_FULL, CPU OMP 2) entfaellt auf PHP, wie viel auf den Nim-Kern (train_step_i8 + rescale_weights_i8)? Lohnt ein Umbau von PHP auf Nim?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/schluss/knirps96/kriterien_zeit.txt (laut Text vor der Messung, 2026-10-15). Dazu ein perf-Profil (ohne Kriterium, Nachmessung).):
  PHP-Anteil = (Schleife - Kern) / Schleife. < 20 % -> Umbau auf Nim lohnt nicht; >= 50 % -> lohnt; dazwischen haengt am Umfang kuenftiger Reihen. Kontrollen: K1 Modell der Zeitkopie byte-gleich zum Lauf ohne Zeitnahme; K2 Kern <= Schleife <= Gesamt.
Baut auf: snai/geschichten-pytorch
Darauf baut: snai/knirps-dw-gemm
Rezepte:
  r73 [2026-10-21] Segment 0 von gesch_d96h6L2_s1 in rechner-b:~/snai_pruef/knirps_gpu/proj_zeit (wie lauf_geschichten.sh); perf: perf record -F 999 -g auf train_cluster, kleines Segment 600 kB (1.048 Schritte)
      quelltext: proj_zeit = proj_t ohne Checkpoints, train_worker.php an 4 Stellen um hrtime-Zeitnahmen ergaenzt (assert je Trefferzahl 1)
      parameter: 96x2, ctx 128, INT8_FULL, CPU OMP 2, 5.001 Schritte; Arm P lief mit 3 Faeden mit
      seed: Genesis 1
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/knirps_gpu/log/proj_t/perf_klein.train.log; Zeitnahme-Ausgabe nicht gesondert gefunden
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/schluss/knirps96/kriterien_zeit.txt (Ergebnisabschnitt), nicht nachgerechnet
  m738 Schleife | 304,088 s | Zeitnahme | 1 | 5001
  m739 Kern | 303,950 s | Zeitnahme | 1 | 5001
  m740 PHP-Anteil | 0,05 % | Zeitnahme | 1 | 5001
  m741 Kern je Schritt | 60,8 ms | Zeitnahme | 1 | 5001
  m742 K1 Modell-md5 Zeitkopie = proj_t | 91dd45e5 = 91dd45e5 | Kontrolle | 1
  m743 perf Eigenzeit dW (snai_axpy_i8_i32 + snai_gradacc_i8) | ~23 % | perf | 1 | 68244
  m744 perf Eigenzeit Adam/8-Bit-Momente | ~26-30 % | perf | 1 | 68244
  m745 perf Eigenzeit trainStepI8Batched | 23,8 % | perf | 1 | 68244
  m746 perf Vorwaerts-GEMM | ~4,4 % | perf | 1 | 68244
Ergebnis e70 [2026-10-21 14:31]: verfehlt
  Fazit: PHP-Anteil 0,05 %: ein Umbau von PHP auf Nim lohnt nicht. Der Tempo-Abstand zu PyTorch liegt vollstaendig im Nim-Kern; das perf-Profil (Beobachtung ohne Kriterium) zeigt als Posten die Gewichtsgradienten als viele kurze axpy-Aufrufe, die 8-Bit-Momentkodierung im Adam-Schritt und die eingebettete Attention, nicht die Matrixrechnung. Daraus folgte der Block-GEMM-Umbau fuer dW (snai/knirps-dw-gemm).
  Offen: perf ohne Aufrufgraph; Arm P lief mit.
  Datei: rechner-a:~/snai_pruef/schluss/knirps96/kriterien_zeit.txt
Chronik:
  2026-10-21 14:30 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/schluss/knirps96/kriterien_zeit.txt (laut Text vor der Messung, 2026-10-15). Dazu ein perf-Profil (ohne Kriterium, Nachmessung).)
  2026-10-21 14:30 Rezept r73
  2026-10-21 14:30 Status geplant -> laeuft (Rezept r73)
  2026-10-21 14:30 Messwerte m738-m746
  2026-10-21 14:31 Ergebnis e70: verfehlt
  2026-10-21 14:31 Status laeuft -> ausgewertet (Ergebnis e70)
```
