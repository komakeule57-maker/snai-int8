# snai/schach-clip

```text
snai/schach-clip - ausgewertet, begonnen 2026-10-16, angelegt 2026-10-21, zuletzt 2026-10-21 19:17
Frage: Hilft eine ausreisser-robuste Quantisierungsskala der Embedding-Zeilen (scale = min(max, K x median)/127, K = 20) gegen den Formkollaps des grossen d96-Laufs? Ein Segment s4 -> s5 ab gross_gross_s1_s4, gepaart zum vorhandenen gross_gross_s1_s5.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_clip.txt (laut Text vor dem Lauf, 2026-10-16; mtime 06:24). Nachfolgedatei kriterien_wd.txt (07:04) beschreibt den Abbruch.):
  Formfehler (500 Ziehungen T 1,0, Saat 4711): (1) hilft, wenn < 10 % (gegen 27,0 %) UND 0 Zeilen mit <= 1 Stufe; (2) hilft nicht, wenn > 20 %; (3) 10-20 % kein Schluss, dann K = 8 nachlegen. Pflichtkontrolle: steigt der Held-out-Loss um > 10 % gegen 1,392, ist es ein Tausch.
Baut auf: snai/schach-gross
Darauf baut: snai/schach-wd0
Rezepte:
  r128 [2026-10-21] bash lauf_clip.sh 20 (in proj_clip: SNAI_CLIP_K=20 SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=727208 nice -n 12 php train_cluster.php factory/input/gross_c64_seg5.txt factory/checkpoints/gross_gross_s1_s5.snai 1 1 factory/checkpoints/gross_gross_s1_s4.snai 3 0.001 0.0001 1 0.1)
      quelltext: proj_clip = Kopie von proj_ow, Patch in quantize_tensor_i8() von tensor_io.php (SNAI_CLIP_K); Patch-Stand nicht mehr vorhanden, tensor_io.php danach auf Original zurueckgesetzt; lauf_clip.sh e1feb736
      parameter: Start adam_t 466.470, Segment gross_c64_seg5, Rezept wie gross, K = 20, eine Saat
      seed: Saat 1 (Lauf), Ziehsaat 4711
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/gebiete/clip.log, clip_k20.train.log (endet 06:59:49 bei Schritt 54.215 ohne Abschluss)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: clip_k20.train.log (Abbruchstelle); Loss-Werte aus kriterien_wd.txt, nicht nachgerechnet
  m1393 Schritte bis Abbruch | 54215 von ~93294 | K20 | 1
  m1394 Held-out-Loss mit Median-Clip an gross_gross_s1_s7 (Pruefung des Eingriffs) | 57,44 | Clip | 1
  m1395 Held-out-Loss ohne Eingriff | 1,370 | Original | 1
Ergebnis e123 [2026-10-21 19:17]: ungueltig
  Fazit: Abgebrochen, Aufbau falsch: der Patch sass in tensor_io.php, das nur beim Speichern quantisiert; im Training quantisiert cortex.nim. Ausserdem ist der Ausreisser eine funktionale Merkmalsspalte (sie auf null zu setzen treibt den Loss von 1,37 auf 12,64), und der Median-Clip zerstoert sie (Loss 57,44). Clipping der Ausreisser ist als Gegenmittel verworfen; jede Reparatur muss die Merkmalsspalte erhalten. Die Spur fuehrte weiter ueber Weight-Decay (snai/schach-wd0) zum Adam-Momenten-Defekt.
  Offen: Kein Formfehler gemessen.
  Datei: rechner-a:~/snai_pruef/knirps/gebiete/kriterien_wd.txt (Abschnitt ANLASS beschreibt den Abbruch)
Chronik:
  2026-10-21 19:16 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_clip.txt (laut Text vor dem Lauf, 2026-10-16; mtime 06:24). Nachfolgedatei kriterien_wd.txt (07:04) beschreibt den Abbruch.)
  2026-10-21 19:17 Rezept r128
  2026-10-21 19:17 Status geplant -> laeuft (Rezept r128)
  2026-10-21 19:17 Messwerte m1393-m1395
  2026-10-21 19:17 Ergebnis e123: ungueltig
  2026-10-21 19:17 Status laeuft -> ausgewertet (Ergebnis e123)
```
