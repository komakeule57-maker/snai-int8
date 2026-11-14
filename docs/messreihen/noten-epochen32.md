# snai/noten-epochen32

```text
snai/noten-epochen32 - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:20
Frage: Noten-Knirps 32/2/16: senken 32 statt 8 Epochen (gleiche Melodien, Abklingen über den ganzen Lauf) den Held-out-Loss, und wann setzt Überanpassung ein?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/noten/kriterien.txt, Abschnitt MEHR EPOCHEN ("2026-10-14 ~14:45", VOR dem Start laut Text; erster Logeintrag 14:42:22). VORAB NICHT BELEGT: Die Uhrzeit im Abschnittskopf liegt nach dem Start der Logs, die Datei wurde zuletzt 2026-10-14 20:09:23 geändert; das Kriterium ist eingetragen, das Urteil daher beobachtung.):
  Arm nd32h2_e32: 32 Segmente = 32 Epochen, gleiche Genesis, gleiche Melodien (Segmente 8-31 = Segment 0 neu gemischt), gleiches Held-out. Ändert sich gemeinsam: Epochenzahl UND Abklingdauer (90.272 statt 22.528 Schritte); nicht gepaart. Urteil: Endwert Segment 31, Mittel der 3 Saaten gegen 8-Epochen-Mittel (1,298); unter 10 % = Gleichstand; zusätzlich Überlappung der Saatbereiche, bestes Segment, Anstieg danach (Überanpassung: > 0,02 über dem Minimum), Train gegen Held-out. Gegen Trigramm wie snai/noten-start.
Plan: rechner-a:~/snai_pruef/knirps/noten/kriterien.txt
Baut auf: snai/noten-start
Darauf baut: snai/noten-form
Rezepte:
  r144 [2026-10-21] nd32h2_e32_s1..3: cd ~/snai_pruef/knirps/proj_ow && VOK=<noten|noten_takt> ../noten/lauf_noten.sh <arm> 0.001 <segmente> <genesis> <decay_steps>  (je Segment: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=$DECAY nice -n 10 php train_cluster.php <seg> <aus> 1 1 <vorstand> 3 0.001 0.0001 1 0.1)
      quelltext: knirps/proj_ow (Lade-Wächter aus), libcortex.so md5 563780e32333; noten/lauf_noten.sh 08263f699b5a; noten/bau.py 8067a6954f13, bau2.py d6ee2095b99e; text/mess_text.php 711d818750ae; noten/form_noten.php 76a103a94364 (md5 gekürzt)
      parameter: wie snai/noten-start, 32 Segmente, Abklingen über 32 x 2821 = 90.272 Schritte
      seed: Genesis noten_gen_d32h2_s1..3; Mischsaat 2000+i für Segmente 8-31
      rechner: rechner-a (CPU)
      logs: rechner-a:~/.cache/snai_pruef/knirps/ow/noten/nd32h2_e32_s{1,2,3}.*
      notiz: Prüfung beim Nachtrag: Endwerte nachgerechnet. Die Uhrzeit im Abschnittskopf liegt einige Minuten NACH dem ersten Logeintrag der Läufe; der Text sagt "VOR dem Start". Ob der Abschnitt wirklich vorher stand, belegen die Dateizeiten nicht (Datei zuletzt 2026-10-14 20:09:23).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/ow/noten/nd32h2_e32_s*.mess.jsonl (nachgerechnet)
  m1563 Held-out-Loss Endwert (n = Fenster je Lauf) | 1,227 / 1,180 / 1,182 | 32 Epochen | 1/2/3 | 300
  m1564 Mittel | 1,196 | 32 Epochen | 1-3 | 3
  m1565 Vergleich Mittel 8 Epochen | 1,298 | 8 Epochen | 1-3 | 3
  m1566 Unterschied (3 gegen 3) | -7,8 % (Saatbereiche überlappen nicht) | 32 gegen 8
  m1567 Minimum im Segment (n = Segmente) | 31 (letztes) | 32 Epochen | 1-3 | 32
  m1568 Rot-Probe Loss | 6,740 / 6,582 / 6,937 | 32 Epochen | 1/2/3 | 300
Ergebnis e136 [2026-10-21 19:20]: beobachtung
  Fazit: Lesart nach der eingetragenen Regel: gleichstand (Held-out-Abstand 7,8 %, unter 10 %). Weil nicht belegt ist, dass das Kriterium vor dem Lauf stand, zählt das nur als Beobachtung. Vierfach so viele Epochen senken den Held-out-Loss nur um 7,8 % (Gleichstand, aber überlappungsfrei), Überanpassung tritt in 32 Epochen nicht auf. Die eigentliche Wirkung zeigt der Loss kaum: die Formquote stieg im selben Vergleich auf das Vierfache (snai/noten-form). Für Noten ist der Held-out-Loss deshalb kein brauchbares Entscheidungsmaß.
  Offen: Epochen und Abklingdauer ändern sich gemeinsam.
  Datei: rechner-a:~/snai_pruef/knirps/noten/kriterien.txt
Chronik:
  2026-10-21 19:20 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/noten/kriterien.txt, Abschnitt MEHR EPOCHEN ("2026-10-14 ~14:45", VOR dem Start laut Text; erster Logeintrag 14:42:22). VORAB NICHT BELEGT: Die Uhrzeit im Abschnittskopf liegt nach dem Start der Logs, die Datei wurde zuletzt 2026-10-14 20:09:23 geändert; das Kriterium ist eingetragen, das Urteil daher beobachtung.)
  2026-10-21 19:20 Rezept r144 (nd32h2_e32_s1..3)
  2026-10-21 19:20 Status geplant -> laeuft (Rezept r144)
  2026-10-21 19:20 Messwerte m1563-m1568
  2026-10-21 19:20 Ergebnis e136: beobachtung
  2026-10-21 19:20 Status laeuft -> ausgewertet (Ergebnis e136)
```
