# snai/merkmal-rauschen

```text
snai/merkmal-rauschen - ausgewertet, begonnen 2026-10-17, angelegt 2026-10-21, zuletzt 2026-10-21 19:20
Frage: Verhindert eine GROSSE Bahnaenderung ohne Eingriff in den Gradientenpfad (Gauss-Rauschen auf alle Gewichte bei s4) den Sprung s4 -> s5?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/rauschen/kriterien_rauschen.txt, Kopf '2026-10-17, VOR dem Start' (Start 14:30:14), Nachtraege 14:30:57 und 15:44:30):
  Gueltig ist ein Lauf, wenn sein Endabstand zum Original-s5 (alle Tensoren) >= 0,19 UND L hoechstens 10 % ueber Original. Nur gueltige Laeufe: GROSSE BAHNAENDERUNG RETTET NICHT = mindestens 3 gueltige, alle F >= 15 %. RETTET = mindestens 3 gueltige, davon mindestens 3 mit F < 5 %. Sonst kein Urteil. Laeufe eps 0,2 und 0,4, Saat 1 und 3, Rauschsaat 4711. Nachtrag 15:44:30 vor dem Zusatzlauf: ein weiterer Lauf eps 0,4, Rauschsaat 4712, Saat 1, gleiche Regel.
Baut auf: snai/merkmal-reihe
Rezepte:
  r145 [2026-10-21] bash ~/snai_pruef/merkmal/rauschen/lauf_rausch.sh <saat> <eps> (python3 rauschen.py erzeugt den verrauschten Start aus Original s4, dann php train_cluster.php factory/input/gross_c64_seg5.txt factory/checkpoints/gross_gross_s<S>_s5.snai 1 1 <start gross_gross_s<S>_s4> 3 0.001 0.0001 1 0.1 mit SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=727208)
      quelltext: Kopien knirps/proj_rausch_s<S>_e<eps> (und _e0.4b), libcortex.so 28eeffe0; lauf_rausch.sh bd56e39d, rauschen.py a1a74682
      parameter: d96 Schach, ein Segment s4 -> s5 ab Original gross_gross_s<S>_s4 (adam_t 466470), LR 0,001 Cosinus bis 727208 (im Segment 3,57e-4 -> ~2e-4), Warmup 500, WD 0,1 ueberall, gebunden, int8 FULL, Revival und Lade-Waechter aus, CPU OMP 1; Rauschen w' = w + eps * rms(Tensor) * N(0,1), m/v/adam_t unveraendert
      seed: Saat 1 und 3; Rauschsaat 4711 (Zusatzlauf 4712)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/rauschen/log/, spaet/mess_rausch*_s*.jsonl, rauschen/abstand.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/spaet/mess_rausch*_s*.jsonl, rauschen/abstand.jsonl (am 2026-10-21 nachgelesen); Abstand des Zusatzlaufs 0,310 nur aus der Kriteriendatei
  m1569 F s5 / tote Zeilen | 29,2 % / 18 | eps 0,2 (ungueltig, Abstand 0,174) | 1 | 500
  m1570 F s5 / tote Zeilen | 35,2 % / 41 | eps 0,2 (ungueltig, Abstand 0,173) | 3 | 500
  m1571 F s5 / tote Zeilen | 30,6 % / 0 | eps 0,4 (gueltig, Abstand 0,352) | 1 | 500
  m1572 F s5 / tote Zeilen | 32,2 % / 30 | eps 0,4 (gueltig, Abstand 0,368) | 3 | 500
  m1573 F s5 / tote Zeilen | 6,8 % / 0 | eps 0,4 Rauschsaat 4712 (gueltig, Abstand 0,310) | 1 | 500
  m1574 L s5 gegen Original | -1,7 bis +0,3 % | alle 5 Saaten 1 und 3 |  | 5
  m1575 F direkt nach dem Rauschen (s4 verrauscht) | 60,2 / 14,4 / 99,5 / 97,2 % | eps 0,2 s1/s3, 0,4 s1/s3 Saaten 1 und 3 |  | 4
Ergebnis e137 [2026-10-21 19:20]: keine_aussage
  Fazit: Kein Urteil (gemischt: 30,6 / 32,2 / 6,8 %). Rauschen ohne Eingriff in den Gradientenpfad kann das Zeilensterben in Saat 1 verhindern (2 von 2 ohne tote Zeilen) und den Formfehler teilweise senken (1 von 2). Die ZERL-Effekte sind damit nicht eindeutig dem Gradientenpfad zuzuschreiben, aber deutlich zuverlaessiger (M, G 8 von 8 unter 5 %). Nebenbefund mit Folgen: eps 0,4 Saat 1 hat 30,6 % Formfehler bei 0 toten Zeilen - tote Zeilen sind also nicht notwendig fuer den Formfehler. Die Frage wurde erst durch den gezielten Eingriff an der v-Rundung (snai/merkmal-sr) entschieden.
  Offen: Formfehler ohne tote Zeilen (eps 0,4 s1) nicht untersucht; ein Lauf.
  Datei: rechner-a:~/snai_pruef/merkmal/rauschen/kriterien_rauschen.txt
Chronik:
  2026-10-21 19:20 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/rauschen/kriterien_rauschen.txt, Kopf '2026-10-17, VOR dem Start' (Start 14:30:14), Nachtraege 14:30:57 und 15:44:30)
  2026-10-21 19:20 Rezept r145
  2026-10-21 19:20 Status geplant -> laeuft (Rezept r145)
  2026-10-21 19:20 Messwerte m1569-m1575
  2026-10-21 19:20 Ergebnis e137: keine_aussage
  2026-10-21 19:20 Status laeuft -> ausgewertet (Ergebnis e137)
```
