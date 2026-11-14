# snai/prod512-ftz-takt

```text
snai/prod512-ftz-takt - ausgewertet, begonnen 2026-09-24, angelegt 2026-10-21, zuletzt 2026-10-21 19:34
Frage: Trifft der Takt des ersten Segments mit FTZ-Bibliothek (s13) die aus der kontrollierten A/B-Messung abgeleitete Vorhersage von 27,54 s je Schritt (30,77 x 0,895)?
Kriterium (nachgetragen, Beleg: Kriterium (2026-09-25 03:01, 'vorab'); die Vorhersage stand fest, bevor s13 mit der neuen Bibliothek lief.):
  Vorhersage: 10,5 % Trainingsgewinn, also 30,77 x 0,895 = 27,54 s je Schritt für s13; Vergleich im gleichen Schrittfenster 100..240. Projektregel: unter 10 % = Gleichstand.
Baut auf: snai/dim512-ftz-rueckwaerts
Rezepte:
  r215 [2026-10-21] Worker-Zeilen aus ~/.cache/prod512/s*.log, Takt im Schrittfenster 100..240 (Gegenversuch: spätes Fenster 3000..5000)
      quelltext: Produktivlauf; libcortex.so mit FTZ-Konstruktor gebaut 2026-09-24 17:04
      rechner: vserver
      logs: vserver:~/.cache/prod512/s9..s13.log (gelöscht)
Messwerte (Groesse | Wert | Arm | Start | n):
 ; nicht nachgerechnet (Rohdaten auf vserver nicht mehr vorhanden: ~/.cache/prod512 seit 2026-10-09 leer)
  m2511 Takt Schritt 100..240 | 27,67 / 28,64 / 29,83 / 30,77 s | prod512 s9 / s10 / s11 / s12 |  | 141
  m2512 Vorhersage s13 | 27,54 s | prod512 s13 |  | 1
  m2513 Takt Schritt 100..240 | 27,41 s | prod512 s13 |  | 141
  m2514 Abweichung | -0,5 % | prod512 s13 |  | 141
  m2515 Takt spätes Fenster 3000..5000 | 28,25 / 28,97 / 30,02 / 30,87 s | prod512 s9 / s10 / s11 / s12 |  | 2001
  m2516 Takt laufend | 26,9 s | prod512 s17 |  | 1
Ergebnis e203 [2026-10-21 19:34]: erfuellt
  Fazit: Treffer auf 0,5 %: der FTZ-Gewinn trägt im Produktivlauf, und der Takt hielt bis s19 bei 26,9 bis 27,6 s. Die Segmentdauer fiel damit von 48,6 auf rund 43,5 h. Dass die Prognose so genau traf, heißt zugleich, dass der Drift mit FTZ gestoppt und nicht nur überdeckt war; trennen kann die Messung das nicht sicher.
  Offen: Der Drift s9..s12 (+11,2 %) ist der größte freie Parameter; ohne seinen Stopp wäre der FTZ-Anteil eher 14 %.
Chronik:
  2026-10-21 19:34 angelegt (Nachtrag: Kriterium (2026-09-25 03:01, 'vorab'); die Vorhersage stand fest, bevor s13 mit der neuen Bibliothek lief.)
  2026-10-21 19:34 Rezept r215
  2026-10-21 19:34 Status geplant -> laeuft (Rezept r215)
  2026-10-21 19:34 Messwerte m2511-m2516
  2026-10-21 19:34 Ergebnis e203: erfuellt
  2026-10-21 19:34 Status laeuft -> ausgewertet (Ergebnis e203)
```
