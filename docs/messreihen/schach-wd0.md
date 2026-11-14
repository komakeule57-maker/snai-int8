# snai/schach-wd0

```text
snai/schach-wd0 - ausgewertet, begonnen 2026-10-16, angelegt 2026-10-21, zuletzt 2026-10-21 19:17
Frage: Ist Weight-Decay die Ursache dafuer, dass die kleinen Embedding-Gewichte im grossen d96-Schachlauf unter eine Quantisierungsstufe schrumpfen? Ein Segment s4 -> s5 ab gross_gross_s1_s4 mit WD 0 statt 0,1, gepaart zum vorhandenen gross_gross_s1_s5.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_wd.txt (laut Text vor dem Lauf, 2026-10-16; mtime 07:04, Lauf ab 07:05).):
  Hauptgroesse Stufen-Median der Embedding-Zeilen (quant_sonde.php): (1) WD ist die Ursache, wenn der Median mit WD 0 >= 6 bleibt (gegen 3) UND keine Zeile auf <= 1 Stufe faellt; (2) nicht die Ursache, wenn er auf <= 4 faellt; (3) bei genau 5 kein Schluss. Nebengroessen: Zeilen <= 1 Stufe, Formfehler (500 Ziehungen T 1,0), Held-out-Loss, Spaltenanteil. Pflichtkontrolle: Loss-Anstieg > 10 % gegen 1,392 = Tausch.
Baut auf: snai/schach-clip
Darauf baut: snai/merkmal-wdemb
Rezepte:
  r129 [2026-10-21] bash lauf_wd.sh 0 (in proj_clip: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=727208 nice -n 12 php train_cluster.php factory/input/gross_c64_seg5.txt factory/checkpoints/wd0_s1_s5.snai 1 1 factory/checkpoints/gross_gross_s1_s4.snai 3 0.001 0.0001 1 0)
      quelltext: proj_clip mit tensor_io.php bitgleich zu proj_ow (vom Skript per cmp geprueft); cortex.nim 7b67236c, libcortex.so 563780e3; lauf_wd.sh e088d653, quant_sonde.php 4e1a0da3, spalten_sonde.php f304be15, form_sonde.py 4f7d130f
      parameter: Start adam_t 466.470, ein Segment (93.294 Schritte), Rezept wie gross ausser WD 0; Vergleichsarm gross_gross_s1_s5 (WD 0,1) wird nicht neu gerechnet
      seed: Saat 1 (Sitzungsname gepaart), Ziehsaat 4711
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/gebiete/wd.log, wd0.train.log; Ziehungen rechner-a:~/snai_pruef/knirps/gebiete/zieh_wd0.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/gebiete/wd.log (WD 0, nachgelesen); Vergleichsarm aus kriterien_wd.txt/kriterien_clip.txt
  m1396 Stufen-Median Embeddings | 4 | WD 0 | 1 | 87
  m1397 Stufen-Median Embeddings | 3 | WD 0,1 (gross_s1_s5) | 1 | 87
  m1398 Zeilen mit <= 1 Stufe | 10 von 87 | WD 0 | 1 | 87
  m1399 Zeilen mit <= 1 Stufe | 22 von 87 | WD 0,1 | 1 | 87
  m1400 Formfehler | 0,6 % | WD 0 | 1 | 500
  m1401 Formfehler | 27,0 % | WD 0,1 | 1 | 300
  m1402 Held-out-Loss | 1,3505 | WD 0 | 1 | 300
  m1403 Held-out-Loss | 1,392 | WD 0,1 | 1 | 300
  m1404 Zeilenmaximum in derselben Spalte | 72,4 % (Sp32) | WD 0 | 1 | 87
Ergebnis e124 [2026-10-21 19:17]: verfehlt
  Fazit: Nach Vorab-Regel Fall (2): der Stufen-Median faellt auch ohne Weight-Decay auf 4, WD ist nicht die alleinige Ursache des Aufloesungsverlusts. Am Symptom wirkt WD 0 aber vollstaendig (Formfehler 0,6 % statt 27 %, Loss besser) - die gewaehlte Hauptgroesse hat am Mechanismus vorbeigemessen. Spaeter isoliert: der Kollaps braucht Decay UND den int8-Pfad, Ursache ist die Rundungs-Ratsche der 8-Bit-Adam-Momente. Der gepaarte Arm 'WD nur auf den Embeddings aus' steht als snai/merkmal-wdemb.
  Offen: Eine Saat, ein Segment.
  Datei: rechner-a:~/snai_pruef/knirps/gebiete/kriterien_wd.txt (Ergebnis nur in wd.log)
Chronik:
  2026-10-21 19:16 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_wd.txt (laut Text vor dem Lauf, 2026-10-16; mtime 07:04, Lauf ab 07:05).)
  2026-10-21 19:17 Rezept r129
  2026-10-21 19:17 Status geplant -> laeuft (Rezept r129)
  2026-10-21 19:17 Messwerte m1396-m1404
  2026-10-21 19:17 Ergebnis e124: verfehlt
  2026-10-21 19:17 Status laeuft -> ausgewertet (Ergebnis e124)
```
