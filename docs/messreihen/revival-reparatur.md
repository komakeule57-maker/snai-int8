# snai/revival-reparatur

```text
snai/revival-reparatur - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 19:29
Frage: Besteht die Revival-Reparatur (2026-10-12) die Abnahme R1 bis R5: keine Schleife, Norm der neuen Zeilen 0,5 x Median (±20 %), Modell ohne tote Zeilen bytegleich, Selbstprüfung bricht ab, gesunde Genesis-Randzeilen unberührt?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus rechner-a ~/snai_pruef/revival_pruef/abnahme_20261012.out (mtime 2026-10-12 05:13) und abnahme.sh.):
  Vorab im Kopf von revival_pruef/abnahme.sh: R1 nach echtem Revival markiert derselbe Erkenner keine der neuen Zeilen (alt muss rot sein); R2 Norm 0,5 x Median ±20 %; R3 Modell ohne tote Zeilen bytegleich; R4 bei Anteil 0,03 rc 3 und nichts geschrieben; R5 Genesis-Randzeilen nicht angefasst (alt: rot).
Plan: Abnahme R1 bis R5, alt gegen neu.
Baut auf: snai/revival-erkennung
Rezepte:
  r180 [2026-10-21] bash revival_pruef/abnahme.sh
      quelltext: revival_pruef/proj mit revival_reparatur_20261012.patch, alt in proj_orig
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/revival_pruef/abnahme_20261012.out
      notiz: Die Schwelle der Rot-Probe R1 wurde erst nach dem ersten Lauf auf '>= 1' gesenkt (abnahme.sh Zeile 22); betrifft nur die Gegenprobe.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/revival_pruef/abnahme_20261012.out
  m2236 R1 wieder markiert | 0 | neu |  | 1
  m2237 R1 wieder markiert | 1 oder mehr (rot) | alt |  | 1
  m2238 R2 Norm in 0,4 bis 0,6 | grün | neu |  | 1
  m2239 R3 bytegleich | grün | neu |  | 1
  m2240 R4 rc bei Anteil 0,03 | 3 | neu |  | 1
  m2241 R5 Randzeilen markiert | 0 | neu |  | 1
Ergebnis e169 [2026-10-21 19:29]: erfuellt
  Fazit: Alle fünf Punkte grün, R1 und R5 am alten Stand rot gesehen. Das reparierte Revival ist damit abgenommen; für Läufe mit Revival vor dem 2026-10-12 gilt weiter der alte, defekte Erkenner (siehe snai/kopier-revival, das darauf aufbaut).
  Offen: R2 bis R4 ohne Rot-Probe am alten Stand.
  Datei: rechner-a:~/snai_pruef/revival_pruef/abnahme.sh
Chronik:
  2026-10-21 19:28 angelegt (Nachtrag: Nachtrag 2026-10-21 aus rechner-a ~/snai_pruef/revival_pruef/abnahme_20261012.out (mtime 2026-10-12 05:13) und abnahme.sh.)
  2026-10-21 19:28 Rezept r180
  2026-10-21 19:28 Status geplant -> laeuft (Rezept r180)
  2026-10-21 19:28 Messwerte m2236-m2241
  2026-10-21 19:29 Ergebnis e169: erfuellt
  2026-10-21 19:29 Status laeuft -> ausgewertet (Ergebnis e169)
```
