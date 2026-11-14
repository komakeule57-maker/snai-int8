# snai/merkmal-reihe

```text
snai/merkmal-reihe - ausgewertet, begonnen 2026-10-17, angelegt 2026-10-21, zuletzt 2026-10-21 19:19
Frage: Verhindert schon eine reine Bahnstoerung (andere Datenreihenfolge, sonst identisch) den Sprung s4 -> s5? Kontrolle zu ZERL.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/reihe/kriterien_reihe.txt, Kopf '2026-10-17, VOR dem Start' (Start 11:12:55), Nachtrag 11:13:58):
  6 Laeufe (Saat 1 und 3, je Reihenfolge A, B, C ueber Ausgabename gross_gross_s<S>_s5_r<X>): BAHNSTOERUNG VERHINDERT NICHT (ZERL-Effekte spezifisch) = alle 6 F >= 15 %. VERHINDERT = mindestens 4 von 6 F < 5 %. Sonst Rate berichten. Loss-Kontrolle 10 %. Nachtrag nach Laufstart (11:13:58, kein Messwert gesehen): Abstand der Endgewichte zum Original-s5 (rel. L2, alle Tensoren / Embeddings) je Lauf und ZERL-Arm berichtet, kein Urteil.
Baut auf: snai/merkmal-zerl
Darauf baut: snai/merkmal-zerl-g2, snai/merkmal-rauschen
Rezepte:
  r138 [2026-10-21] bash ~/snai_pruef/merkmal/reihe/lauf_reihe.sh <saat> <X> (php train_cluster.php factory/input/gross_c64_seg5.txt factory/checkpoints/gross_gross_s<S>_s5_r<X>.snai 1 1 <start gross_gross_s<S>_s4> 3 0.001 0.0001 1 0.1 mit SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=727208); Abstand python3 reihe/abstand.py
      quelltext: Kopien knirps/proj_reihe_s<S><X> = proj_spaet_s1 ohne Laeufe, libcortex.so 28eeffe0; lauf_reihe.sh c87481bd, bank_reihe.sh 06fd1733, abstand.py 8feba9bd
      parameter: d96 Schach, ein Segment s4 -> s5 ab Original gross_gross_s<S>_s4 (adam_t 466470), LR 0,001 Cosinus bis 727208 (im Segment 3,57e-4 -> ~2e-4), Warmup 500, WD 0,1 ueberall, gebunden, int8 FULL, Revival und Lade-Waechter aus, CPU OMP 1
      seed: Saat 1 und 3; Reihenfolge ueber Ausgabename (mt_srand(crc32(epoch:e:chunkdatei)))
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/reihe/log/, spaet/mess_reihe<X>_s<S>.jsonl, reihe/abstand.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/spaet/mess_reihe*_s*.jsonl und reihe/abstand.jsonl (am 2026-10-21 nachgelesen)
  m1530 F | 26,4 / 35,4 / 28,0 % | Reihenfolge A / B / C | 1 | 500
  m1531 F | 39,4 / 44,6 / 36,8 % | Reihenfolge A / B / C | 3 | 500
  m1532 Loss-Abweichung zum Original | -0,4 bis +1,2 % | alle 6 Saaten 1 und 3 |  | 6
  m1533 Abstand alle Tensoren | 0,041-0,061 | REIHE Saaten 1 und 3 |  | 6
  m1534 Abstand alle Tensoren | 0,19-0,30 | verhindernde ZERL-Arme M, G, B, R Saaten 1 und 3 |  | 8
  m1535 Abstand nur Embeddings | 0,34-1,15 | REIHE Saaten 1 und 3 |  | 6
  m1536 Abstand nur Embeddings | 1,10-1,29 | ZERL M und G Saaten 1 und 3 |  | 4
Ergebnis e132 [2026-10-21 19:19]: erfuellt
  Fazit: Die Datenreihenfolge rettet nicht (6/6 kippen, 26-45 %); der Sprung ist gegen sie robust. Das stuetzt die Spezifitaet der ZERL-Arme nur halb: alle kippenden Laeufe liegen am Ende nah am Original (<= 0,061), alle rettenden ZERL-Arme weit weg (>= 0,19). 'Float-Gradientenpfad' und 'grosse Bahnaenderung' sind damit nicht getrennt; nur im Embedding-Abstand ueberlappen die Bereiche (stuetzt M und G). Die Trennung versuchte snai/merkmal-rauschen. 'Erfuellt' = These 'Bahnstoerung durch Reihenfolge verhindert nicht' nach Regel gestuetzt.
  Offen: Nur eine Art Bahnstoerung (Reihenfolge).
  Datei: rechner-a:~/snai_pruef/merkmal/reihe/kriterien_reihe.txt
Chronik:
  2026-10-21 19:18 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/reihe/kriterien_reihe.txt, Kopf '2026-10-17, VOR dem Start' (Start 11:12:55), Nachtrag 11:13:58)
  2026-10-21 19:18 Rezept r138
  2026-10-21 19:18 Status geplant -> laeuft (Rezept r138)
  2026-10-21 19:19 Messwerte m1530-m1536
  2026-10-21 19:19 Ergebnis e132: erfuellt
  2026-10-21 19:19 Status laeuft -> ausgewertet (Ergebnis e132)
```
