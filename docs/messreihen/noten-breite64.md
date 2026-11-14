# snai/noten-breite64

```text
snai/noten-breite64 - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:21
Frage: Noten-Knirps mit Taktart-Token und 64 Epochen auf nur echtem Material (2.187 Melodien): erzeugt Breite 64 (64/4/16) mehr formkorrekte Melodien zur angesagten Taktart als 32/2/16?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/noten/kriterien.txt, Abschnitt BREITE 64 ("2026-10-14 ~16:55", VOR dem Start laut Text; erster Logeintrag 16:48:16). VORAB NICHT BELEGT: Die Uhrzeit im Abschnittskopf liegt nach dem Start der Logs, die Datei wurde zuletzt 2026-10-14 20:09:23 geändert; das Kriterium ist eingetragen, das Urteil daher beobachtung.):
  Daten notentakt2 (2.187 Melodien ohne Knirps-Generator-Material), 64 Epochen, Held-out unverändert. Arm d64 (64/4/16, ffn 256, 112.448 Parameter) gegen Kontrollarm d32 (32/2/16), sonst alles gleich; Breite, Köpfe und ffn ändern sich gemeinsam (Kopfbreite 16 fest); nicht gepaart. Urteil: quote_angesagt T=1,0 (form_noten.php, 500 Ziehungen, Saat 4711, TRAIN=notentakt2 seg0); d64 besser, wenn jede Saat über 110 % des d32-Mittels; alle unter 90 % = schlechter; sonst Gleichstand/saatabhängig. Daneben: Held-out-Loss, Überanpassung (> 0,02 über Minimum), Kopien, Taktartenverteilung gegen Training. Kontrolle: Trainingssegment selbst 2187/2187 als Kopien erkannt.
Plan: rechner-a:~/snai_pruef/knirps/noten/kriterien.txt
Baut auf: snai/noten-takt-e64
Darauf baut: snai/noten-tonart, snai/noten-tonart-breite, snai/noten-r
Rezepte:
  r153 [2026-10-21] n64takt_e64_s1..3, n32takt2_e64_s1..3 (VOK=noten_takt): cd ~/snai_pruef/knirps/proj_ow && VOK=<noten|noten_takt> ../noten/lauf_noten.sh <arm> 0.001 <segmente> <genesis> <decay_steps>  (je Segment: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=$DECAY nice -n 10 php train_cluster.php <seg> <aus> 1 1 <vorstand> 3 0.001 0.0001 1 0.1)
      quelltext: knirps/proj_ow (Lade-Wächter aus), libcortex.so md5 563780e32333; noten/lauf_noten.sh 08263f699b5a; noten/bau.py 8067a6954f13, bau2.py d6ee2095b99e; text/mess_text.php 711d818750ae; noten/form_noten.php 76a103a94364 (md5 gekürzt)
      parameter: 64/4/16 bzw. 32/2/16, 2 Schichten, Rezept FALL, Abklingen 64 x 3088 = 197.632 Schritte, 64 Segmente (Saat 3000+i)
      seed: Genesis notentakt_gen_d64h4_s1..3 bzw. notentakt_gen_d32h2_s1..3; Ziehsaat 4711
      rechner: rechner-a (CPU)
      logs: rechner-a:~/.cache/snai_pruef/knirps/ow/noten/n64takt_e64_s*, n32takt2_e64_s*; form.jsonl
      notiz: Prüfung beim Nachtrag: quote_angesagt und Loss aus form.jsonl/mess.jsonl nachgerechnet (der frühere Befund nennt Minimum bei s57-63, Rohdaten s58-63). Die Uhrzeit im Abschnittskopf liegt einige Minuten NACH dem ersten Logeintrag der Läufe; der Text sagt "VOR dem Start". Ob der Abschnitt wirklich vorher stand, belegen die Dateizeiten nicht (Datei zuletzt 2026-10-14 20:09:23).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/ow/noten/form.jsonl, n64takt_e64_s*.mess.jsonl, n32takt2_e64_s*.mess.jsonl (nachgerechnet)
  m1641 quote_angesagt T=1,0 % (n = je Lauf) | 19,8 / 22,2 / 19,4 | d32 | 1/2/3 | 500
  m1642 Mittel / Schwelle besser | 20,5 / 22,5 | d32 | 1-3 | 1500
  m1643 quote_angesagt T=1,0 % (n = je Lauf) | 38,4 / 37,6 / 50,4 | d64 | 1/2/3 | 500
  m1644 Held-out-Loss Segment 63 (n = Fenster) | 1,156 / 1,179 / 1,154 | d32 | 1/2/3 | 300
  m1645 Held-out-Loss Segment 63 (n = Fenster) | 1,114 / 1,102 / 1,101 | d64 | 1/2/3 | 300
  m1646 Anstieg über Minimum (n = Segmente) | 0 bis 0,0098 (Minimum Segment 58-63) | beide | 1-3 | 64
  m1647 Wörtliche Kopien (n = je Lauf) | 0 | beide | 1-3 | 500
  m1648 Häufigster Verwerfungsgrund (n = je Lauf) | Taktsumme falsch | beide | 1-3 | 500
Ergebnis e142 [2026-10-21 19:21]: beobachtung
  Fazit: Lesart nach der eingetragenen Regel: erfuellt. Weil nicht belegt ist, dass das Kriterium vor dem Lauf stand, zählt das nur als Beobachtung. Breite 64 verdoppelt die formkorrekten Melodien zur angesagten Taktart (alle Saaten 1,8- bis 2,5-fach über d32), während der Held-out-Loss nur 5 % sinkt. Für den Notengenerator ist damit d64 die bessere Wahl, und die Formsonde bleibt das Entscheidungsmaß. Nicht beantwortet: ob d64 mit mehr Epochen weiter gewinnt und ob Generator-Material hilft.
  Offen: Ein Budget; die 2/4-Schieflage der formkorrekten Melodien bleibt. Fehlerkanal der Sonde ging nach /dev/null (nicht mitgeschrieben).
  Datei: rechner-a:~/snai_pruef/knirps/noten/kriterien.txt
Chronik:
  2026-10-21 19:21 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/noten/kriterien.txt, Abschnitt BREITE 64 ("2026-10-14 ~16:55", VOR dem Start laut Text; erster Logeintrag 16:48:16). VORAB NICHT BELEGT: Die Uhrzeit im Abschnittskopf liegt nach dem Start der Logs, die Datei wurde zuletzt 2026-10-14 20:09:23 geändert; das Kriterium ist eingetragen, das Urteil daher beobachtung.)
  2026-10-21 19:21 Rezept r153 (n64takt_e64_s1..3, n32takt2_e64_s1..3 (VOK=noten_takt))
  2026-10-21 19:21 Status geplant -> laeuft (Rezept r153)
  2026-10-21 19:21 Messwerte m1641-m1648
  2026-10-21 19:21 Ergebnis e142: beobachtung
  2026-10-21 19:21 Status laeuft -> ausgewertet (Ergebnis e142)
```
