# snai/merkmal-zerl-verl

```text
snai/merkmal-zerl-verl - ausgewertet, begonnen 2026-10-18, angelegt 2026-10-21, zuletzt 2026-10-21 19:22
Frage: Haben 'Rueckwaerts float' (B) und 'Gradakkumulation float' (G) den Embedding-Kollaps nur aufgeschoben (These) oder bleiben sie bei Fortsetzung bis s7 gesund?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/zerl/kriterien_zerl_verl.txt, Kopf '2026-10-18, VOR dem Start', ERGEBNIS 2026-10-18 16:32 angefuegt):
  Je Arm B, G: AUFGESCHOBEN (stuetzt die These) = F >= 15 % in s6 oder s7, in BEIDEN Saaten; IM BUDGET GESUND = F < 5 % in s6 und s7, beide Saaten (heisst NICHT 'verhindert', die LR faellt bis 1e-4); sonst / Saaten uneinig: kein Urteil. Kontrolle Original s6/s7 ungepaart, nur Groessenordnung.
Baut auf: snai/merkmal-zerl
Darauf baut: snai/merkmal-konstlr
Rezepte:
  r150 [2026-10-21] bash ~/snai_pruef/merkmal/zerl/lauf_zerl_verl.sh <B|G> <saat> (Fortsetzung ab eigenem s5 mit demselben Schalter SNAI_I8_INT_BACKWARD=0 bzw. SNAI_I8_INT_GRADACC=0; php train_cluster.php factory/input/gross_c64_seg<I>.txt factory/checkpoints/gross_gross_s<S>_s<I>.snai 1 1 <vorher> 3 0.001 0.0001 1 0.1 mit SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=727208, I = 6, 7)
      quelltext: ZERL-Kopien knirps/proj_zerl_{B,G}_s{1,3} unveraendert (libcortex.so 28eeffe0, ZERL-Patch, Lade-Waechter aus); lauf_zerl_verl.sh fd033501
      parameter: d96 Schach, Korpus gross, LR 0,001 Cosinus bis 727208, Untergrenze 1e-4, Warmup 500, WD 0,1 inkl. Embeddings, gebunden, int8 FULL, CPU, OMP 1, Revival und Lade-Waechter aus; Segmente s6, s7; LR Ende s5 2,1e-4 -> Ende s7 1,0e-4 (adam_t 746.352)
      seed: Saat 1 und 3, Ausgabenamen gross_gross_s<S>_s6/s7 (Datenreihenfolge der Originale)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/zerl/log_verl/verl<Arm>_s<S>.log, spaet/mess_zerl{B,G}_s<S>.jsonl (seg 6, 7)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/spaet/mess_zerlB_s1.jsonl, mess_zerlB_s3.jsonl, mess_zerlG_s1.jsonl, mess_zerlG_s3.jsonl (seg 6, 7 am 2026-10-21 gelesen); Mediane aus der Ergebnisdatei
  m1626 F s6 / s7 | 2,0 / 1,0 % | B | 1 | 500
  m1627 F s6 / s7 | 1,4 / 1,4 % | B | 3 | 500
  m1628 F s6 / s7 | 3,8 / 1,4 % | G | 1 | 500
  m1629 F s6 / s7 | 3,4 / 1,8 % | G | 3 | 500
  m1630 Held-out L s7 | 1,3096 | B | 1 | 300
  m1631 Held-out L s7 | 1,3083 | B | 3 | 300
  m1632 Held-out L s7 | 1,3182 | G | 1 | 300
  m1633 Held-out L s7 | 1,3187 | G | 3 | 300
  m1634 tote Zeilen s6, s7 | 0 | B, G Saaten 1, 3
  m1635 Stufen-Median s5 / s6 / s7 | 11/10/10 | B | 1
  m1636 Stufen-Median s5 / s6 / s7 | 14/13/15 | B | 3
  m1637 Stufen-Median s5 / s6 / s7 | 12/14/13 | G | 1
  m1638 Stufen-Median s5 / s6 / s7 | 12/17/17 | G | 3
  m1639 F s6 / s7 (Kontrolle, ungepaart) | 34,4 / 32,8 % | Original | 1 | 500
  m1640 F s6 / s7 (Kontrolle, ungepaart) | 36,8 / 36,4 % | Original | 3 | 500
Ergebnis e144 [2026-10-21 19:22]: verfehlt
  Fazit: Nach Wortlaut der Kriteriendatei: B und G je 'IM BUDGET GESUND' (F < 5 % in s6 und s7, beide Saaten). Die These 'float schiebt den Kollaps nur auf' traegt in diesem Budget nicht: B und G bleiben bis s7 gesund (alle F unter 4 %, keine tote Zeile, Median faellt nicht weiter). Weil die Lernrate dabei auf 1e-4 auslaeuft, ist 'verhindert' damit aber nicht bewiesen; genau das war der Anlass fuer den Lauf mit konstanter Lernrate (snai/merkmal-konstlr).
  Offen: Ob B/G bei nicht abklingender LR halten (beantwortet in snai/merkmal-konstlr). Zwei Saaten.
  Datei: rechner-a:~/snai_pruef/merkmal/zerl/kriterien_zerl_verl.txt
Chronik:
  2026-10-21 19:21 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/zerl/kriterien_zerl_verl.txt, Kopf '2026-10-18, VOR dem Start', ERGEBNIS 2026-10-18 16:32 angefuegt)
  2026-10-21 19:21 Rezept r150
  2026-10-21 19:21 Status geplant -> laeuft (Rezept r150)
  2026-10-21 19:21 Messwerte m1626-m1640
  2026-10-21 19:22 Ergebnis e144: verfehlt
  2026-10-21 19:22 Status laeuft -> ausgewertet (Ergebnis e144)
```
