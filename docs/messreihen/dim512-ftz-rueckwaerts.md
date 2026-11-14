# snai/dim512-ftz-rueckwaerts

```text
snai/dim512-ftz-rueckwaerts - ausgewertet, begonnen 2026-09-24, angelegt 2026-10-21, zuletzt 2026-10-21 19:34
!! ohne Kriterium
Frage: Ändert FTZ/DAZ im Produktionspfad von prod512 (int8 voll, Rückwärtspfad, Adam, Requantisierung) das Trainingsergebnis, und wie viel Trainingszeit spart es auf vserver?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Baut auf: snai/dim512-ftz-vorwaerts
Darauf baut: snai/prod512-ftz-takt
Rezepte:
  r213 [2026-10-21] SNAI_INT8_FULL=1 SNAI_FORCE_CPU=1 OMP_NUM_THREADS=2 php train_worker.php <Brocken> <Ausgabe> … Basis prod512_s11, Parameter 3 0.001 1 0.001 0 0 0, 15 Schritte, PLAN_CTX=1024; FTZ per LD_PRELOAD (Arm E)
      quelltext: libcortex.so.bak_pre_ftz_20260924 (md5 d6955121…) in allen Armen; Unterschied nur MXCSR
      parameter: Arme D ohne FTZ, E mit FTZ, F ohne FTZ (Wiederholung von D)
      seed: gleiche Sitzung, deterministisch
      rechner: vserver
      logs: k. A.
Messwerte (Groesse | Wert | Arm | Start | n):
 , nicht nachgerechnet (Rohdaten auf vserver nicht mehr vorhanden: ~/.cache/prod512 seit 2026-10-09 leer)
  m2498 Ausgabemodell md5 | d0ce07a495a275f3c1b74801a2d0d970 in D, E und F | alle |  | 15
  m2499 Avg Loss und GradNorm je Schritt | zeichengleich in D, E, F | alle |  | 15
  m2500 Wanduhr | 454 s | D ohne FTZ |  | 15
  m2501 Wanduhr | 410 s | E mit FTZ |  | 15
  m2502 Wanduhr | 462 s | F ohne FTZ |  | 15
  m2503 Trainingsgewinn FTZ | 10,5 % | E gegen D/F |  | 15
Ergebnis e201 [2026-10-21 19:34]: beobachtung
  Fazit: FTZ ändert am Training nichts: drei Arme, bitgleiches Modell, und die Wiederholung F zeigt, dass der Worker selbst reproduziert. Der Zeitgewinn im Training liegt bei 10,5 %, gleiche Größenordnung wie im Vorwärtspfad. Das trug den Einbau ohne Dienstneustart. Ein Numerik-A/B gehört auf die Maschine, wo der Effekt auftritt: derselbe Test auf dem Laptop wäre trivial bitgleich gewesen (Ryzen ohne Denormalen-Strafe, dazu ohne SNAI_INT8_FULL).
  Offen: 15 Schritte, ein Brocken, ein Basismodell; Aussage ist 'ändert hier nichts', nicht 'kann nie'.
Chronik:
  2026-10-21 19:34 angelegt (Nachtrag: Kein Kriterium vorab (Stand 2026-09-24 10:45); Aufbau mit Wiederholungsarm F, damit Reproduzierbarkeit des Workers geprüft ist.)
  2026-10-21 19:34 Rezept r213
  2026-10-21 19:34 Status geplant -> laeuft (Rezept r213)
  2026-10-21 19:34 Messwerte m2498-m2503
  2026-10-21 19:34 Ergebnis e201: beobachtung
  2026-10-21 19:34 Status laeuft -> ausgewertet (Ergebnis e201)
```
