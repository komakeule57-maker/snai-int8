# snai/merkmal-sr

```text
snai/merkmal-sr - ausgewertet, begonnen 2026-10-18, angelegt 2026-10-21, zuletzt 2026-10-21 19:21
Frage: Ist die Rundungs-Ratsche des zweiten Adam-Moments (8-Bit-Log-Codec qmomStoreRow, v rundet das Abklingen weg) die Ursache des Embedding-Kollapses? Eingriff im echten Kern: zufaelliges Runden nur von v (V), nur von m (M, Spiegelprobe gleicher Staerke), beider (MV); Sprung s4 -> s5 in Saat 1 und 3.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/sr/kriterien_sr.txt, Kopf '2026-10-18, VOR dem Start' (Vorab-Messungen Codec-Sonde und Bank darin)):
  Je Arm, Endstand s5, beide Saaten, F gegen Original 28,4 / 37,2 %: VERHINDERT = F < 5 % in beiden; VERHINDERT NICHT = F >= 15 % in beiden; sonst kein Urteil. Pflichtkontrolle: L > 10 % vom Original s5 -> kein Urteil fuer den Arm. Lesart vorab: V verhindert UND M verhindert nicht -> v-Ratsche NOETIG, durch Eingriff isoliert; V verhindert UND M verhindert -> keine Isolierung ('jede Stoerung'); V verhindert nicht -> Ratsche nicht die Ursache.
Baut auf: snai/merkmal-zerl, snai/merkmal-ratsche, snai/merkmal-unterversorgung
Darauf baut: snai/merkmal-sr-lang, snai/merkmal-konstlr, snai/adam-schatten
Rezepte:
  r147 [2026-10-21] bash ~/snai_pruef/knirps_sr/lauf_sr.sh <V|M|MV> <saat> (SNAI_I8_MOM_SR=v|m|mv; php train_cluster.php factory/input/gross_c64_seg5.txt factory/checkpoints/gross_gross_s<S>_s5.snai 1 1 <start Original gross_gross_s<S>_s4> 3 0.001 0.0001 1 0.1 mit SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=727208); Messung messe_sr.sh
      quelltext: proj_sr_basis = proj_zerl_basis + patch_sr.py 47703c85 (eine Stelle: Rundung in qmomStoreRow, deterministischer Zufall aus Wert, Zeile, Spalte, adam_t), libcortex.so dfcc4711; lauf_sr.sh 2092c0fe, messe_sr.sh 5f4d5a75, bank_sr.sh fa71e0bf (rechner-a merkmal/sr), abstand.php 38c93f23
      parameter: ein Segment s4 -> s5 ab Original (adam_t 466470), d96 Schach, LR 0,001 Cosinus bis 727208, Untergrenze 1e-4, Warmup 500, WD 0,1 inkl. Embeddings, gebunden, int8 FULL, CPU, OMP 1, Revival und Lade-Waechter aus; einziges Stellrad SNAI_I8_MOM_SR
      seed: Saat 1 und 3, Ausgabename wie Original (gepaart; Bank Q0 10a1ee05 = Original-Bibliothek)
      rechner: rechner-b (Laeufe), rechner-a (Codec-Sonde, Bank)
      logs: rechner-b:~/snai_pruef/knirps_sr/log/, mess_srV_s1.jsonl usw.; rechner-a:~/snai_pruef/merkmal/sr/bank/
      notiz: Ablauf: Codec-Sonde am echten qmomStoreRow/qmomGet, Bank 200 Schritte (Rot-Probe je Stellung), dann 6 Laeufe s4 -> s5 auf rechner-b
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/knirps_sr/mess_srV_s1.jsonl, mess_srV_s3.jsonl, mess_srM_s*.jsonl, mess_srMV_s*.jsonl (am 2026-10-21 gelesen); Codec und Bank aus kriterien_sr.txt
  m1608 Codec v1 bei t 3000/10000/20000 | 0,950 / 1,000 / 1,000 | Rundung bisher |  | 1
  m1609 Codec v1 bei t 3000/10000/20000 | 0,320 / 2,6e-4 / 1,0e-4 | zufaellige Rundung |  | 1
  m1610 Bank md5 200 Schritte | Q0 10a1ee05, QV 65beb38c, QM 6607bea0, QMV 27ec7def | Bank Stand s4 | 1 | 1
  m1611 F s5 | 1,2 % | V | 1 | 500
  m1612 F s5 | 2,0 % | V | 3 | 500
  m1613 F s5 | 27,6 % | M | 1 | 500
  m1614 F s5 | 40,0 % | M | 3 | 500
  m1615 F s5 | 1,4 % | MV | 1 | 500
  m1616 F s5 | 1,8 % | MV | 3 | 500
  m1617 Held-out L s5 | 1,3815 | V | 1 | 300
  m1618 Held-out L s5 | 1,4688 | V | 3 | 300
  m1619 tote Zeilen s5 | 0 | V | 1
  m1620 tote Zeilen s5 | 1 | V | 3
  m1621 tote Zeilen s5 | 16 | M | 1
  m1622 tote Zeilen s5 | 37 | M | 3
  m1623 tote Zeilen s5 | 0 | MV | 1
  m1624 tote Zeilen s5 | 0 | MV | 3
  m1625 Loss-Abweichung gegen Original s5 | -0,8 ... +4,1 % | alle Arme Saaten 1, 3
Ergebnis e141 [2026-10-21 19:21]: erfuellt
  Fazit: Die v-Ratsche ist als notwendige Ursache des Kollapses isoliert: Wird nur v richtig gerundet, bleibt der Sprung aus (1-2 %); wird stattdessen m genauso stark verrauscht, kollabiert das Modell wie das Original (28-40 %). Damit ist die Lesart 'jede Stoerung der Bahn verhindert ihn' fuer dieses Rezept vom Tisch. MV ist der Abhilfe-Kandidat, der die 8-Bit-Momente behaelt; ob er einen ganzen Lauf traegt, musste erst snai/merkmal-sr-lang zeigen.
  Offen: Zwei Saaten, ein Segment, ein Rezept. Warum auch float-Rueckwaerts und float-Gradakkumulation (ZERL B/G) den Sprung verhindern, erklaert die Ratsche nicht direkt (Deutung in der Datei, nicht gemessen).
  Datei: rechner-a:~/snai_pruef/merkmal/sr/kriterien_sr.txt
Chronik:
  2026-10-21 19:20 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/sr/kriterien_sr.txt, Kopf '2026-10-18, VOR dem Start' (Vorab-Messungen Codec-Sonde und Bank darin))
  2026-10-21 19:20 Rezept r147
  2026-10-21 19:20 Status geplant -> laeuft (Rezept r147)
  2026-10-21 19:21 Messwerte m1608-m1625
  2026-10-21 19:21 Ergebnis e141: erfuellt
  2026-10-21 19:21 Status laeuft -> ausgewertet (Ergebnis e141)
```
