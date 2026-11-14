# snai/float32-att-threads-koepfe

```text
snai/float32-att-threads-koepfe - ausgewertet, angelegt 2026-10-30, zuletzt 2026-10-30 19:22
Frage: Welche Blockgroesse taugt als feste Einstellung fuer die float32-Attention ueber Kopfzahlen hinweg?
Kriterium (festgelegt 2026-10-30 19:09, vor dem ersten Messwert):
  Gemessen: Median s/Schritt und md5 je Arm, sonst wie snai/float32-att-threads-512, je 3 Laeufe. Teil A, 1 Kopf: T4, T2, T1 gegen T8 (5,42 s). Teil B, 8 Koepfe, sonst gleiche Geometrie: T256 gegen T8 und T32. Harte Bedingung: md5 je Teil in allen Armen gleich. Urteil: Unter 10 % Abstand gilt Gleichstand, dann bleibt der groessere Block. Eine Einstellung wird uebernommen, wenn sie in Teil A und Teil B innerhalb von 10 % des jeweils besten Arms liegt und in Teil B nicht langsamer als T256 ist. Sonst keine feste Zahl, sondern Berechnung aus der Kopfzahl als neue Reihe.
Baut auf: snai/float32-att-threads-512
Darauf baut: snai/multistack-att-threads-karte
Rezepte:
  r475 [2026-10-30] cd ~/snai_pruef/att_threads/bench_tf32 && ./alle2.sh
      quelltext: wie r474; gen512h8.snai = Kopie von gen512.snai mit Beidatei .heads = 8
      rechner: rechner-b (RTX 3050, entsperrt)
      logs: rechner-b:~/snai_pruef/att_threads/bench_tf32/logA*_r*.txt, logB*_r*.txt, stand2.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/att_threads/bench_tf32/logA*, logB*, stand2.txt
  m6736 Median s/Schritt | 5,155 | A T4 | r1 | 7
  m6737 Median s/Schritt | 5,167 | A T4 | r2 | 7
  m6738 Median s/Schritt | 5,181 | A T4 | r3 | 7
  m6739 Median s/Schritt | 5,114 | A T2 | r1 | 7
  m6740 Median s/Schritt | 5,122 | A T2 | r2 | 7
  m6741 Median s/Schritt | 5,106 | A T2 | r3 | 7
  m6742 Median s/Schritt | 5,242 | A T1 | r1 | 7
  m6743 Median s/Schritt | 5,235 | A T1 | r2 | 7
  m6744 Median s/Schritt | 5,239 | A T1 | r3 | 7
  m6745 Median s/Schritt | 4,206 | B T256 | r1 | 7
  m6746 Median s/Schritt | 4,205 | B T256 | r2 | 7
  m6747 Median s/Schritt | 4,206 | B T256 | r3 | 7
  m6748 Median s/Schritt | 3,696 | B T32 | r1 | 7
  m6749 Median s/Schritt | 3,709 | B T32 | r2 | 7
  m6750 Median s/Schritt | 3,691 | B T32 | r3 | 7
  m6751 Median s/Schritt | 3,592 | B T8 | r1 | 7
  m6752 Median s/Schritt | 3,600 | B T8 | r2 | 7
  m6753 Median s/Schritt | 3,585 | B T8 | r3 | 7
  m6754 md5 Ausgabemodell Teil A | 105aea27 | A | r1-3 | 9
  m6755 md5 Ausgabemodell Teil B | 5a2cc1ce | B | r1-3 | 9
  Quelle: rechner-b:~/snai_pruef/att_uebernahme/w/bench_tf32/logU_r*.txt; cortex_cuda.cu 57a639ce, libcortex_cuda.so 8a50c498
  m6756 Median s/Schritt, snai_edge-Quelltext ohne Stellrad | 5,436 | U | r1 | 7
  m6757 Median s/Schritt, snai_edge-Quelltext ohne Stellrad | 5,430 | U | r2 | 7
  m6758 Median s/Schritt, snai_edge-Quelltext ohne Stellrad | 5,420 | U | r3 | 7
  m6759 md5 Ausgabemodell | 105aea27 | U | r1-3 | 3
Ergebnis e418 [2026-10-30 19:20]: erfuellt
  Fazit: T8 wird feste Einstellung: bei 1 Kopf 6 % hinter dem besten Arm T2 (innerhalb 10 %, der groessere Block bleibt), bei 8 Koepfen selbst der beste Arm und 15 % schneller als T256. Das Ergebnis bleibt je Kopfzahl bytegleich. Eine Berechnung aus der Kopfzahl ist nicht noetig. Nebenbefund: 8 Koepfe sind schon mit T256 viel schneller als 1 Kopf (4,2 gegen 16,0 s), beide Geometrien rechnen aber verschiedene Modelle, das ist kein Tempogewinn gleicher Rechnung.
  Offen: Andere Breiten und Kontextlaengen; Watchdog bei groesseren Modellen. Verbleibender Hebel: bei T8 und 1 Kopf rund 3,3 s Attention und Vorwaertsblock, rund 1,8 s auf der CPU.
Chronik:
  2026-10-30 19:09 angelegt
  2026-10-30 19:09 Rezept r475
  2026-10-30 19:09 Status geplant -> laeuft (Rezept r475)
  2026-10-30 19:20 Messwerte m6736-m6755
  2026-10-30 19:20 Ergebnis e418: erfuellt
  2026-10-30 19:20 Status laeuft -> ausgewertet (Ergebnis e418)
  2026-10-30 19:22 Messwerte m6756-m6759
```
