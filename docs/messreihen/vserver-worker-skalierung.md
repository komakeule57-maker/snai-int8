# snai/vserver-worker-skalierung

```text
snai/vserver-worker-skalierung - ausgewertet, begonnen 2026-08-26, angelegt 2026-10-21, zuletzt 2026-10-21 19:34
!! ohne Kriterium
Frage: Lohnen auf dem SnAI-VServer mehr Threads je Arbeiter oder mehr Arbeiter (4 statt 2) für den Durchsatz des Produktivlaufs prod512?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Darauf baut: snai/prod512b-schrittzeit, snai/threads-skalierung
Rezepte:
  r216 [2026-10-21] Threads: ein Arbeiter allein, 400-KB-Brocken, Basis prod512_s4, Schritt 5 -> 25, OMP_NUM_THREADS 1/2/3/6; Befehl wörtlich k. A.
      quelltext: k. A.
      parameter: dim 512 wie Produktivlauf
      rechner: rechner-a (Laptop)
      logs: k. A.
  r217 [2026-10-21] Arbeiter: Prinzessin-Lauf, zwei Arme à 2 Arbeiter à 3 Threads gleichzeitig (Laptop, 12 Threads)
      quelltext: k. A.
      parameter: dim 256, ctx 1024
      rechner: rechner-a
      logs: Planung des Full-INT8-Ports Z. ~2620-2690
Messwerte (Groesse | Wert | Arm | Start | n):
 ; nicht nachgerechnet
  m2517 s je Schritt | 15,90 / 14,95 / 14,55 / 14,25 | 1 / 2 / 3 / 6 Threads |  | 20
  m2518 CPU je Arbeiter auf dem Server | 112 % | 2 Arbeiter |  | 1
  m2519 Tok/s je Arbeiter | 286 | 1 Arbeiter allein |  | 1
  m2520 Tok/s je Arbeiter | 176 (int8) / 121 (fp32) | 4 Arbeiter gleichzeitig |  | 1
  m2521 Tok/s je Arbeiter | 241 | 2 Arbeiter |  | 1
  m2522 Durchsatz 4 gegen 2 Arbeiter | ~1,2-fach | Prinzessin |  | 1
  m2523 RSS 2 Arbeiter zusammen / Merge-Spitze | ~1117 / ~1100 MB | prod512 s0 bis s3 |  | 4
Ergebnis e204 [2026-10-21 19:34]: beobachtung
  Fazit: Weder noch: mehr Threads bringen von 1 auf 6 nur 12 %, und 4 statt 2 Arbeiter brachten im gemessenen Fall 1,2-fach statt 2-fach; dazu passen 4 Arbeiter nicht in den RAM, den der Ballon übrig ließ. Der Lauf blieb deshalb bei 2 Arbeitern (so entschieden). Die Lehre aus der Reihe ist methodisch: ein Einzelprozess-Wert sagt nichts über den Durchsatz unter Konkurrenz; die frühere '~2x'-Hochrechnung war eine Rechnung, keine Messung. Für prod512b (1 Arbeiter) zeigte sich dasselbe Bild erneut: die Threadzahl ist dort Gleichstand (snai/prod512b-schrittzeit).
  Offen: Die Vier-Arbeiter-Zahlen stammen vom Prinzessin-Lauf (dim 256, Laptop), nicht von prod512 auf dem Server.
  Datei: Planung des Full-INT8-Ports
Chronik:
  2026-10-21 19:34 angelegt (Nachtrag: Kein Kriterium vorab. Thread-Messung (2026-09-09); Vier-Arbeiter-Beleg aus dem Prinzessin-Lauf 2026-08-26, gefunden in der Planung des Full-INT8-Ports.)
  2026-10-21 19:34 Rezept r216 (Threads)
  2026-10-21 19:34 Status geplant -> laeuft (Rezept r216)
  2026-10-21 19:34 Rezept r217 (Arbeiter)
  2026-10-21 19:34 Messwerte m2517-m2523
  2026-10-21 19:34 Ergebnis e204: beobachtung
  2026-10-21 19:34 Status laeuft -> ausgewertet (Ergebnis e204)
```
