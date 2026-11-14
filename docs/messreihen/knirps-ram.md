# snai/knirps-ram

```text
snai/knirps-ram - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:31
Frage: Wie viel Arbeitsspeicher braucht ein SnAI-Trainingslauf gegenueber dem PyTorch-Gegenstueck mit gleichem Rezept, bei d96 L2 (0,37 Mio. Param.) und d512 L4 (13,4 Mio.)?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/schluss/knirps96/ram/kriterien_ram.txt (laut Text vor dem ersten Lauf, 2026-10-15 ~16:xx).):
  Hauptmass Spitze der Summe Pss ueber den ganzen Prozessbaum (ram_mess.py). Median SnAI gegen Median PyTorch je Zelle: < 10 % Gleichstand; sonst Richtung, sofern alle 3 Wiederholungen getrennt; sonst 'streut, kein Schluss'. Rot-Probe des Messgeraets: Eltern+Kind je 500 MB -> Summe >= 1.000 MB.
Baut auf: snai/geschichten-pytorch
Darauf baut: snai/knirps-ram-ladeweg
Rezepte:
  r75 [2026-10-21] python3 ram_mess.py <tag> -- <befehl> (SnAI: train_cluster.php wie lauf_geschichten.sh; PyTorch: torch_knirps.py train [--max-fenster 200])
      quelltext: ram_mess.py, rot.py in rechner-a:~/snai_pruef/schluss/knirps96/ram
      parameter: ctx 128, OMP 2, CPU; K = d96 L2 Segment 0 (5.001 Fenster); G = d512 L4 h8 ffn 2048, 200 Fenster; 3 Wiederholungen je Seite und Zelle
      seed: Genesis 1
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/knirps_gpu/ram/ergebnis.jsonl, ram/log, fehlerkanal.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/knirps_gpu/ram/ergebnis.jsonl (Pss nachgelesen); Rot-Probe und Steigung aus kriterien_ram.txt
  m760 Spitze Summe Pss | 70,1 / 70,1 / 70,8 MB | SnAI K | 1 | 3
  m761 Spitze Summe Pss | 300,1 / 299,9 / 299,5 MB | PyTorch K | 1 | 3
  m762 Spitze Summe Pss | 407,0 / 405,8 / 411,0 MB | SnAI G | 1 | 3
  m763 Spitze Summe Pss | 644,9 / 634,7 / 635,2 MB | PyTorch G | 1 | 3
  m764 Median SnAI gegen PyTorch K | -76,6 % | SnAI-PyTorch | 1 | 3
  m765 Median SnAI gegen PyTorch G | -35,9 % | SnAI-PyTorch | 1 | 3
  m766 Rot-Probe Geraet Baum / kaputtes Geraet | 1.007,6 / 503,8 MB | Rot
  m767 Steigung je Mio. Param. (Rechnung) | 25,9 / 25,8 MB | SnAI/PyTorch
Ergebnis e72 [2026-10-21 14:31]: erfuellt
  Fazit: SnAI braucht in beiden Groessen weniger RAM (-77 % bzw. -36 %, alle Wiederholungen getrennt). Der Vorsprung ist aber nur der feste Sockel (PyTorch-Bibliothek ~290 MB gegen ~61 MB); je Parameter brauchen beide ~26 Byte, trotz int8-Gewichten. Fuer grosse Modelle schrumpft der Vorteil anteilig gegen null. Warum 26 Byte: snai/knirps-ram-ladeweg.
  Offen: K und G unterscheiden sich in Breite, Tiefe und Fensterzahl; die Steigung ist ein Richtwert.
  Datei: rechner-a:~/snai_pruef/schluss/knirps96/ram/kriterien_ram.txt
Chronik:
  2026-10-21 14:30 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/schluss/knirps96/ram/kriterien_ram.txt (laut Text vor dem ersten Lauf, 2026-10-15 ~16:xx).)
  2026-10-21 14:30 Rezept r75
  2026-10-21 14:30 Status geplant -> laeuft (Rezept r75)
  2026-10-21 14:30 Messwerte m760-m767
  2026-10-21 14:31 Ergebnis e72: erfuellt
  2026-10-21 14:31 Status laeuft -> ausgewertet (Ergebnis e72)
```
