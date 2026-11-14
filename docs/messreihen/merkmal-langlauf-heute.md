# snai/merkmal-langlauf-heute

```text
snai/merkmal-langlauf-heute - ausgewertet, begonnen 2026-10-18, angelegt 2026-10-21, zuletzt 2026-10-21 19:21
Frage: Rechnet der Code-Stand vom 2026-10-18 (Weight-Decay-Commits 72d1cf3/6b46247 und nicht committete Fixes) den d96-Langlauf, in dem der Embedding-Kollaps auftritt, bytegleich zum Stand vom 13.10.? (Frage: 'Das ist aber nicht der Grund fuer den Embeddingfehler, oder?')
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/kriterien_langlauf_heute.txt, 'vor dem Start geschrieben' 2026-10-18, Nachtrag vor dem Start (rechner-b), ERGEBNIS 2026-10-18 12:46 angefuegt):
  Je Segment s0..s5: md5 gegen die Originale (s0 386687ac, s1 c56f8055, s2 f589ee29, s3 4df2e0d4, s4 fbb4717f, s5 0c079542), Fehlerkanal, nach s5 Formfehler und quant_sonde. Alle sechs md5 gleich -> die Aenderungen koennen den Kollaps weder verursachen noch beheben. Nachtrag vor dem Start (Lauf auf rechner-b statt rechner-a): Arm A proj_heute, Kontrolle B proj_neu (Stand 16.10.), Nebenarm C V6-Genesis nur s0. A != Original, aber A = B -> Maschineneffekt; A != B -> die Aenderungen veraendern den Lauf; C md5 s0 = A s0 -> V6-Weg bytegleich.
Baut auf: snai/merkmal-langlauf-neu
Rezepte:
  r146 [2026-10-21] bash ~/snai_pruef/knirps_heute/lauf_heute.sh (je Arm s0..s5: php train_cluster.php factory/input/gross_c64_seg<I>.txt factory/checkpoints/gross_gross_s<S>_s<I>.snai 1 1 <vorher> 3 0.001 0.0001 1 0.1 mit SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=727208, Sitzungsnamen wie Original)
      quelltext: A proj_heute (Projektbaum HEAD 6b46247 + Aenderungen vom 18.10., lib 9b70fdb2, gain_guard_enabled 0, Revival aus), B proj_neu (21b7fde, lib 51047037), C proj_heute_v6 (Genesis V6 5497ae25)
      parameter: d96 Schach, Korpus gross (gross_c64_seg0..7, 93.294 Schritte je Segment), LR 0,001 Cosinus bis 727208, Untergrenze 1e-4, Warmup 500, WD 0,1 inkl. Embeddings, gebunden, int8 FULL, CPU, OMP 1, Revival und Lade-Waechter aus; Genesis gross_gen_s1 (1d08f95e), Segmente s0..s5 = 559.764 Schritte; SNAI_WD_EMBEDDINGS ungesetzt
      seed: Saat 1 (ARM gross_s1)
      rechner: rechner-b (Ryzen 5 4500; Originale auf rechner-a Ryzen 5 5500U)
      logs: rechner-b:~/snai_pruef/knirps_heute/erg_proj_heute/langlauf.log, erg_proj_neu/langlauf.log, erg_proj_heute_v6/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/knirps_heute/erg_proj_heute/langlauf.log und erg_proj_neu/langlauf.log (md5 und rc am 2026-10-21 gelesen)
  m1576 md5 s0 | 386687ac | A, B, Original |  | 1
  m1577 md5 s1 | c56f8055 | A, B, Original |  | 1
  m1578 md5 s2 | f589ee29 | A, B, Original |  | 1
  m1579 md5 s3 | 4df2e0d4 | A, B, Original |  | 1
  m1580 md5 s4 | fbb4717f | A, B, Original |  | 1
  m1581 md5 s5 | 0c079542 | A, B, Original |  | 1
  m1582 md5 s0 | 386687ac | C V6-Genesis |  | 1
  m1583 Formfehler F s5 | 28,4 % (paar 22,4, token 6,0) | A = B | 1 | 500
  m1584 Held-out L s5 | 1,3922 | A = B | 1 | 300
  m1585 Stufen-Median s5 | 3 | A = B | 1
  m1586 Zeilen <= 1 Stufe s5 | 22/87 (Zeilen der Sonde, Angabe wie in der Datei) | A = B | 1
  m1587 Fehlerkanal, rc | 0 | A, B, C alle Segmente
Ergebnis e140 [2026-10-21 19:21]: erfuellt
  Fazit: Die Aenderungen vom 13. bis 18.10. sind am Kollaps unschuldig: derselbe Lauf kommt Segment fuer Segment bytegleich heraus, sogar auf einer anderen CPU, und kollabiert in s5 wie gehabt (28,4 %). Wer die Ursache sucht, muss nicht mehr in den Weight-Decay-Commits suchen, sondern in der Numerik, die schon am 13.10. drin war; das fuehrte zur v-Ratsche (snai/merkmal-sr). Nebenbei: der V6-Genesis-Weg trainiert s0 bytegleich zum V5-Weg.
  Offen: Gilt nur fuer dieses Rezept (WD 0,1, int8 FULL, gebunden, CPU, OMP 1) und Saat 1; FP32, GPU-Pfade, SNAI_WD_EMBEDDINGS=0 nicht geprueft. '22/87' = tote Zeilen von 87 Embedding-Zeilen, wie in den uebrigen Reihen.
  Datei: rechner-a:~/snai_pruef/merkmal/kriterien_langlauf_heute.txt
Chronik:
  2026-10-21 19:20 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/kriterien_langlauf_heute.txt, 'vor dem Start geschrieben' 2026-10-18, Nachtrag vor dem Start (rechner-b), ERGEBNIS 2026-10-18 12:46 angefuegt)
  2026-10-21 19:20 Rezept r146
  2026-10-21 19:20 Status geplant -> laeuft (Rezept r146)
  2026-10-21 19:20 Messwerte m1576-m1587
  2026-10-21 19:21 Ergebnis e140: erfuellt
  2026-10-21 19:21 Status laeuft -> ausgewertet (Ergebnis e140)
```
