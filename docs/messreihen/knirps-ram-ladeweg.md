# snai/knirps-ram-ladeweg

```text
snai/knirps-ram-ladeweg - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:31
Frage: Warum braucht SnAI ~26 Byte je Parameter trotz int8? These: der Rest stammt aus dem Ladeweg (Float-Genesis wird geladen und quantisiert, Allokator gibt nicht zurueck). Gegenversuch: dieselben Laeufe vom int8-Checkpoint statt von der Genesis.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/schluss/knirps96/ram/kriterien_ram.txt, Abschnitt 'NACHTRAG ... VOR dem Gegenversuch' (2026-10-15 ~17:2x). Kein festgehaltenes Ergebnis gefunden.):
  Steigung (MB je Mio. Param.) vom Checkpoint mindestens 30 % unter der Steigung von der Genesis -> These gestuetzt; unter 10 % Unterschied -> widerlegt; dazwischen Teilursache.
Baut auf: snai/knirps-ram
Rezepte:
  r76 [2026-10-21] python3 ram_mess.py <tag> -- <SnAI-Lauf mit Eingabe ram_kurz.txt vom Checkpoint ram_K_w3 bzw. ram_G_w3> (RAM_VERLAUF je Prozess)
      quelltext: ram_mess.py (wie snai/knirps-ram)
      parameter: 201 Schritte, Eingabe ram_kurz.txt, 3 Wiederholungen je Groesse vom Checkpoint, K von der Genesis 1 Lauf
      seed: Genesis 1
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/knirps_gpu/ram/ck.out, ram/log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/schluss/knirps96/ram/kriterien_ram.txt (Ergebnis Gegenversuch), nicht nachgerechnet
  m768 Spitze Summe Pss | 43,8 MB | K Genesis | 1 | 1
  m769 Spitze Summe Pss | 45,0 / 40,9 / 41,0 MB | K Checkpoint | 1 | 3
  m770 Spitze Summe Pss | 409,5 MB (Reihe 407,0) | G Genesis | 1 | 1
  m771 Spitze Summe Pss | 352,7 / 352,7 / 352,5 MB | G Checkpoint | 1 | 3
  m772 Steigung Genesis | 28,0 MB je Mio. Param. | Genesis
  m773 Steigung Checkpoint | 24,0 MB je Mio. Param. (-14 %) | Checkpoint
  m774 Worker flach im Training / beim Speichern | 192 / 346 MB | G Checkpoint | 1 | 1
Ergebnis e73 [2026-10-21 14:31]: teilweise
  Fazit: Nach Wortlaut Teilursache (-14 %): die These 'der Ladeweg ist der grosse Posten' ist widerlegt. Der Zeitverlauf zeigt die eigentliche Spitze: beim Speichern kopiert extract_state_i8 den ganzen Zustand nach PHP (~12 B je Parameter), im Training selbst ~12,7 B (Gradient und Rundungsrest in float). Hebel fuer grosse Modelle waere also der Speicherweg, nicht der Ladeweg - eine Deutung aus einem Verlaufslauf, nicht isoliert.
  Offen: Die Zerlegung je Parameter stammt aus je einem Verlaufslauf.
  Datei: rechner-a:~/snai_pruef/schluss/knirps96/ram/kriterien_ram.txt
Chronik:
  2026-10-21 14:30 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/schluss/knirps96/ram/kriterien_ram.txt, Abschnitt 'NACHTRAG ... VOR dem Gegenversuch' (2026-10-15 ~17:2x). Kein festgehaltenes Ergebnis gefunden.)
  2026-10-21 14:30 Rezept r76
  2026-10-21 14:30 Status geplant -> laeuft (Rezept r76)
  2026-10-21 14:30 Messwerte m768-m774
  2026-10-21 14:31 Ergebnis e73: teilweise
  2026-10-21 14:31 Status laeuft -> ausgewertet (Ergebnis e73)
```
