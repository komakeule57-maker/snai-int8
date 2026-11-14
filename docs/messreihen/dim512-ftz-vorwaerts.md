# snai/dim512-ftz-vorwaerts

```text
snai/dim512-ftz-vorwaerts - ausgewertet, begonnen 2026-09-24, angelegt 2026-10-21, zuletzt 2026-10-21 19:33
Frage: Sind denormale Fließkommazahlen die Ursache des Schrittzeit-Drifts von prod512 auf dem Xeon von vserver: schrumpft der Zeitabstand zwischen den Ständen s11 und s5 unter erzwungenem FTZ/DAZ um mehr als die Hälfte, bei gleichem Verlust?
Kriterium (nachgetragen, Beleg: Kriterium (2026-09-24 09:59, 'vorher genannt'); ersetzt den früheren Befund (dessen Denormalen-Zählung ein Artefakt war).):
  Bestätigt, wenn der Abstand s11-s5 unter FTZ um mehr als die Hälfte schrumpft und der Verlust gleich bleibt.
Baut auf: snai/dim512-drift-2x2
Darauf baut: snai/dim512-ftz-rueckwaerts, snai/dim512-ftz-mechanismus
Rezepte:
  r212 [2026-10-21] eval_held_out_full_i8.php auf prod512_s5 bzw. prod512_s11, 40 Fenster, OMP_NUM_THREADS=2, nice 19, Zeit als Spanne Fenster 20 -> 40; FTZ per LD_PRELOAD einer Schicht mit Konstruktor (gleiche Binärdatei, nur MXCSR anders); danach Wiederholung über den echten Codepfad mit eingebautem Konstruktor. Mikrobenchmark 64 floats, 1,28 Mrd. Multiplikationen.
      quelltext: libcortex.so.bak_pre_ftz_20260924 (md5 d6955121…, Stand 2026-09-02) bzw. FTZ-Bau vom 2026-09-24
      parameter: je Zelle eine eigene Logdatei
      seed: deterministisch
      rechner: vserver (Xeon E5-2699 v4); Mikrobenchmark auch rechner-a
      logs: k. A. (auf vserver nicht mehr vorhanden)
Messwerte (Groesse | Wert | Arm | Start | n):
 , nicht nachgerechnet (Rohdaten auf vserver nicht mehr vorhanden: ~/.cache/prod512 seit 2026-10-09 leer)
  m2488 Mikrobenchmark subnormal / normal | 11,57-fach | Xeon ohne FTZ |  | 1
  m2489 Mikrobenchmark subnormal / normal | 1,00-fach | Xeon mit FTZ |  | 1
  m2490 Mikrobenchmark subnormal / normal | 0,97-fach | Ryzen ohne FTZ |  | 1
  m2491 Held-out-Spanne Fenster 20->40 | 251,2 s (Wiederholung 246,1 s) | s5 ohne FTZ |  | 20
  m2492 Held-out-Spanne | 245,2 s | s5 mit FTZ |  | 20
  m2493 Held-out-Spanne | 272,3 s | s11 ohne FTZ |  | 20
  m2494 Held-out-Spanne | 243,4 s | s11 mit FTZ |  | 20
  m2495 Modellabstand s11-s5 | +9,5 % ohne, -0,7 % mit FTZ | vserver |  | 20
  m2496 echter Codepfad s11 ohne / mit | 290,1 / 248,7 s (-14,3 %) | vserver |  | 20
  m2497 Verlust 40.920 Token | bitgleich in allen Zellen (s11 3,982729, s5 4,261943) | vserver |  | 40
Ergebnis e200 [2026-10-21 19:33]: erfuellt
  Fazit: Ja: unter FTZ schrumpft der Abstand s11-s5 von +9,5 % auf -0,7 %, der Verlust bleibt bitgleich. Beweiskräftig ist die Asymmetrie: FTZ half s11 stark und s5 kaum, zeitlich nebeneinander gemessen. Folge: FTZ/DAZ-Konstruktor in libcortex.so seit 2026-09-24 11:18 auf vserver. Die gespeicherten Gewichte enthalten keine Denormalen; sie entstehen zur Laufzeit (Mechanismus in snai/dim512-ftz-mechanismus).
  Offen: Streuung ohne FTZ hoch (dieselbe Zelle 272,3 und 290,1 s); die s5-Wiederholung (2 %) ist keine gültige Streuungsschätzung für die Denormalen-Bedingung. Nur Vorwärtspfad.
Chronik:
  2026-10-21 19:33 angelegt (Nachtrag: Kriterium (2026-09-24 09:59, 'vorher genannt'); ersetzt den früheren Befund (dessen Denormalen-Zählung ein Artefakt war).)
  2026-10-21 19:33 Rezept r212
  2026-10-21 19:33 Status geplant -> laeuft (Rezept r212)
  2026-10-21 19:33 Messwerte m2488-m2497
  2026-10-21 19:33 Ergebnis e200: erfuellt
  2026-10-21 19:33 Status laeuft -> ausgewertet (Ergebnis e200)
```
