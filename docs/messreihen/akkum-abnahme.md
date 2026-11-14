# snai/akkum-abnahme

```text
snai/akkum-abnahme - ausgewertet, begonnen 2026-10-11, angelegt 2026-10-21, zuletzt 2026-10-21 19:28
Frage: Ist das Gradienten-Sammeln (SNAI_ACCUM_WINDOWS, Patch 2026-10-11) korrekt: N=1 bitgleich, Doppelfenster gleich Einzelfenster, Reihenfolge gleichgültig, Sabotage sichtbar?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus rechner-a ~/Projekte/snai_edge_int8_lora/docs/VERGLEICH_LITERATUR_KOPIEREN.md (Abschnitt 6a) und dem Prüfskript; Patch ~/snai_pruef/akkum/grad_accum_20261011.patch (mtime 2026-10-11 19:04). Rohausgabe nicht erhalten.):
  Vorab im Prüfskript diagnose/verify_grad_accum_lauf.py, ursprünglich je Punkt Kosinus >= 0,999; zwei Schwellen nach dem Messen gelockert (0,999 -> 0,99 und 0,999 -> 0,995). Gewertet wird nach den ursprünglichen Schwellen.
Plan: Prüfpunkte: N=1 bitgleich, AABBCC gegen ABC, Reihenfolge in den Gruppen (zwei Updates / ein Update), Restgruppe, Sabotage.
Rezepte:
  r171 [2026-10-21] python3 diagnose/verify_grad_accum_lauf.py
      quelltext: Projektbaum + akkum/grad_accum_20261011.patch
      parameter: SNAI_ACCUM_WINDOWS = 1, 2, 4
      rechner: rechner-a
      logs: nicht erhalten
Messwerte (Groesse | Wert | Arm | Start | n):
  bzw. rechner-a:~/Projekte/snai_edge_int8_lora/docs/VERGLEICH_LITERATUR_KOPIEREN.md Abschnitt 6a, Rohausgabe nicht gefunden, nicht nachgerechnet. Lockerung der Schwellen sichtbar im Prüfskript (Zeilen 70 bis 80).
  m2155 N=1 gegen ohne Sammeln | bitgleich | N1 |  | 1
  m2156 Kosinus AABBCC gegen ABC | 99,95 % | N2 |  | 1
  m2157 Kosinus Gegenprobe ohne Sammeln | 39 % | Gegenprobe |  | 1
  m2158 Kosinus Reihenfolge, ein Update | 99,83 % | Reihenfolge |  | 1
  m2159 Kosinus Reihenfolge, zwei Updates | 0,9967 | Reihenfolge |  | 1
  m2160 Kosinus Sabotage | 23,5 % | Sabotage |  | 1
  m2161 Anteil Clip greift bei N=4 | 10 bis 40 % | N4 |  | 1
Ergebnis e162 [2026-10-21 19:28]: teilweise
  Fazit: Das Sammeln rechnet, was es soll: N=1 ist bitgleich, Doppelfenster stimmen auf 99,95 %, Sabotage fällt mit 23,5 % auf. Gewertet nach den ursprünglichen Schwellen verfehlen aber zwei Reihenfolge-Prüfpunkte (0,9967 und 0,9983) die 0,999; die Schwellen wurden am 2026-10-11 nach dem Messen auf 0,99 bzw. 0,995 gelockert (Kommentar im Prüfskript, begründet mit Rundungskippern der Float-Summierung). Für den Einsatz reicht das; als Abnahme ist sie nur teilweise bestanden. Der Clip greift bei N=4 oft (10 bis 40 %), das gehört zu jedem Lauf mit Sammeln dazugesagt.
  Offen: Ob die Reihenfolge-Abweichung reine Rundung ist (vermutlich, nicht isoliert); Rohausgabe fehlt.
  Datei: rechner-a:~/Projekte/snai_edge_int8_lora/diagnose/verify_grad_accum_lauf.py
Chronik:
  2026-10-21 19:27 angelegt (Nachtrag: Nachtrag 2026-10-21 aus rechner-a ~/Projekte/snai_edge_int8_lora/docs/VERGLEICH_LITERATUR_KOPIEREN.md (Abschnitt 6a) und dem Prüfskript; Patch ~/snai_pruef/akkum/grad_accum_20261011.patch (mtime 2026-10-11 19:04). Rohausgabe nicht erhalten.)
  2026-10-21 19:27 Rezept r171
  2026-10-21 19:27 Status geplant -> laeuft (Rezept r171)
  2026-10-21 19:28 Messwerte m2155-m2161
  2026-10-21 19:28 Ergebnis e162: teilweise
  2026-10-21 19:28 Status laeuft -> ausgewertet (Ergebnis e162)
```
