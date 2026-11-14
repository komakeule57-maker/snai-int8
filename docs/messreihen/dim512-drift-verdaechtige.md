# snai/dim512-drift-verdaechtige

```text
snai/dim512-drift-verdaechtige - ausgewertet, begonnen 2026-09-22, angelegt 2026-10-21, zuletzt 2026-10-21 19:33
!! ohne Kriterium
Frage: Woher kommt der Schrittzeit-Drift des Produktivlaufs prod512 auf vserver (von s6 bis s12 rund +12 % je Schritt): Speicher (Ballon), CPU-Steal, Schrittzahl oder Trainingszustand?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Baut auf: snai/prod512-lauf
Darauf baut: snai/dim512-drift-2x2
Rezepte:
  r210 [2026-10-21] grep PLAN_EPOCH_STEPS ~/.cache/prod512/s<N>.log; total_duration_sec aus factory/checkpoints/train_prod512_sN.jsonl; /var/log/ramkurve.log; sar (%steal, %nice); Held-out-Dauer aus lauf.log zwischen 'rc=0' und 'Held-out (64 Fenster)'
      quelltext: Produktivlauf wie snai/prod512-lauf
      parameter: Segmente s5..s12 auf vserver
      rechner: vserver
      logs: vserver:~/.cache/prod512/ (gelöscht), /var/log/ramkurve.log
Messwerte (Groesse | Wert | Arm | Start | n):
 ; nicht nachgerechnet (Rohdaten auf vserver nicht mehr vorhanden: ~/.cache/prod512 seit 2026-10-09 leer)
  m2473 Schrittzeit | 27.130 / 27.314 / 27.160 / 28.034 / 29.604 / 30.299 / ~30.850 ms | prod512 s6 bis s12 |  | 1
  m2474 MemTotal beim Segmentstart | 17.648 / 4.922 / 5.171 / 5.242 / 5.145 / 4.445 / 3.845 MB | prod512 s6 bis s12 |  | 1
  m2475 Dauer je MiB | 4070 / 4091 / 4104 / 4212 / 4452 / 4568 s | prod512 s6 bis s11 |  | 1
  m2476 Pearson r (s je MiB gegen MemTotal) | -0,60 | prod512 |  | 6
  m2477 Pearson r (s je MiB gegen Segmentnummer) | +0,93 | prod512 |  | 6
  m2478 %steal Tagesmittel 09-16 bis 09-24 | 0,03 bis 0,06 % | vserver |  | 9
  m2479 Held-out-Dauer (fester Arbeitsauftrag) | 675 / 691 / 697 / 717 / 709 / 743 / 764 s | prod512 s5 bis s11 |  | 1
  m2480 Schrittzeit innerhalb s12 (Fenster à 500) | 30,84 bis 31,37 s, ±1,4 % | prod512 s12 |  | 7
Ergebnis e198 [2026-10-21 19:33]: beobachtung
  Fazit: Speicher, Steal und Schrittzahl sind es nicht; der Drift hängt an der Segmentnummer und sitzt an der Segmentgrenze, nicht im Lauf. Der entscheidende Hinweis lag schon im Lauf: der Held-out nach jedem Segment ist ein fester Arbeitsauftrag und wurde um 13 % langsamer, also liegt die Ursache im Vorwärtspfad und im Zahleninhalt der Gewichte. Das führte zu den Denormalen (snai/dim512-ftz-vorwaerts). Lehre: zuerst nach einer schon mitlaufenden Wiederholungsmessung suchen, bevor man Verdächtige einzeln abklopft.
  Offen: Ursache des Wachstums nicht durch Eingriff isoliert, nur eingegrenzt.
Chronik:
  2026-10-21 19:33 angelegt (Nachtrag: Kein Kriterium vorab. Messvorschrift: Dauer je MiB Segment bzw. ms je Schritt, nicht rohe Segmentdauer. Einzelne Verdächtige nacheinander ausgeschlossen.)
  2026-10-21 19:33 Rezept r210
  2026-10-21 19:33 Status geplant -> laeuft (Rezept r210)
  2026-10-21 19:33 Messwerte m2473-m2480
  2026-10-21 19:33 Ergebnis e198: beobachtung
  2026-10-21 19:33 Status laeuft -> ausgewertet (Ergebnis e198)
```
