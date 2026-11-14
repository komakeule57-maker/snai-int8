# snai/gains-kanalindex

```text
snai/gains-kanalindex - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 13:19
Frage: Haeufen sich tote Gain-Kanaele an festen Vektorpositionen (Layoutfehler im Kernel) oder streuen sie (Dynamik)?
Kriterium (festgelegt 2026-11-02 13:16, vor dem ersten Messwert):
  Kein Training, nur Lesen: |Gain| je Kanal aus allen Clip-Laeufen auf rechner-b (128x4, Endstaende und Snapshots t=1000/3000, laeufe/*) und c128sr s0-s9. Ortsinformation tragen nur Vektoren mit 10 bis 90 % toten Kanaelen (|g| < 0,05); ganz tote oder ganz lebende Vektoren werden gezaehlt, aber nicht gewertet. Messgroessen gepoolt ueber die gewerteten Vektoren: Totrate je 16er-Block (8 Bloecke), V = Rate der letzten 32 Kanaele / Rate der ersten 96, Konsistenz = Anteil der Vektoren, in denen derselbe Block den hoechsten Totanteil hat. LAYOUT-VERDACHT: ein Block >= 2x Mittel gepoolt UND derselbe Block in >= 50 % der Vektoren der toedlichste. STREUT: alle Bloecke in [0,67; 1,5] des Mittels UND V in [0,8; 1,25]. Sonst OFFEN. Beobachtung daneben: Zahl der Laeufe toter Kanaele gegen die Erwartung bei zufaelliger Anordnung. Rot: eine Kopie eines gewerteten Vektors mit Kanaelen 96-127 auf 0 muss LAYOUT-VERDACHT ergeben. Reichweite: Breite 128, FFN- und Attention-Gains getrennt, nur teilweise gekippte Vektoren.
Baut auf: snai/gains-bestand, snai/dauerclip-saaten, snai/wd-gains
Darauf baut: snai/gains-ueberlebende
Rezepte:
  r509 [2026-11-02] kanal.php <stand>... (|Gain| je Kanal, tensor_io.php des jeweiligen Projektbaums) ueber rechner-b ~/snai_pruef/clip/laeufe/*/*/factory/checkpoints/*.snai (234 Dateien, ohne Genesis) und rechner-a chin_c128sr_s0-s9; python3 auswerten.py kanal_clip.jsonl c128sr.jsonl
      quelltext: rechner-a:~/snai_pruef/kanal/kanal.php, auswerten.py
      rechner: rechner-a, Dateien von rechner-b
      logs: rechner-a:~/snai_pruef/kanal/ (kanal_clip.jsonl, c128sr.jsonl)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: auswerten.py, gepoolt Clip-Laeufe plus c128sr, Breite 128
  m7467 Vektoren gesamt / ganz tot / ganz lebend / gewertet (10-90 %) | 1952 / 23 / 1769 / 160 | alle
  m7468 Totrate je 16er-Block | 0,39 0,40 0,40 0,40 0,38 0,41 0,38 0,38 | alle |  | 160
  m7469 V letzte 32 / erste 96 | 0,97 | alle |  | 160
  m7470 toedlichster Block gleich in | 15 % (Block 5) | alle |  | 160
  m7471 Runs toter Kanaele ist / zufaellig erwartet | 49,8 / 50,7 | alle |  | 160
  m7472 Totrate je Block | 0,54 0,57 0,55 0,56 0,50 0,55 0,53 0,52, V 0,97 | ffn |  | 67
  m7473 Totrate je Block | 0,28 0,28 0,29 0,29 0,29 0,31 0,27 0,29, V 0,97 | att |  | 93
  m7474 Totrate je Block L2.ffn | 0,58 0,60 0,56 0,57 0,51 0,56 0,52 0,51, toedlichster Block 1 in 42 % | L2.ffn |  | 48
  m7475 Rot, Kanaele 96-127 tot gesetzt | Bloecke 6 und 7 1,00, V 8,0, Block 6 in 100 %, LAYOUT-VERDACHT | rot |  | 160
  m7476 c128sr L1.ffn Ueberlebende s9 | 12 von 128, feste Kanaele ab s3 | c128sr |  | 10
Ergebnis e443 [2026-11-02 13:19]: erfuellt
  Fazit: STREUT nach Kriterium, in allen Teilmengen: tote Gain-Kanaele liegen gleichverteilt ueber den Vektor, die Zahl der zusammenhaengenden Laeufe entspricht der Zufallserwartung. Ein Layoutfehler im Kernel (SIMD-Rest, Blockgroesse, Threadaufteilung) ist damit als Ursache aus dem Rennen; das Kippen ist Dynamik je Kanal. Rot-Probe loest aus.
  Offen: Nur Breite 128. Rot auf der reinen c128sr-Teilmenge ergibt OFFEN, weil dort schon 84 % tot sind; die Probe traegt nur im grossen Pool. Welche Kanaele ueberleben (c128sr L1: feste 12 ab s3), ist nicht untersucht.
Chronik:
  2026-11-02 13:16 angelegt
  2026-11-02 13:19 Rezept r509
  2026-11-02 13:19 Status geplant -> laeuft (Rezept r509)
  2026-11-02 13:19 Messwerte m7467-m7476
  2026-11-02 13:19 Ergebnis e443: erfuellt
  2026-11-02 13:19 Status laeuft -> ausgewertet (Ergebnis e443)
```
