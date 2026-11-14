# snai/noten-takt-e64

```text
snai/noten-takt-e64 - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:20
Frage: Noten-Knirps 32/2/16, Formquote: hilft ein Taktart-Token am Zeilenanfang (Arm ta32), und helfen 64 statt 32 Epochen (Arm e64), jeweils gegen e32?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/noten/kriterien.txt, Abschnitt TAKTART-TOKEN UND 64 EPOCHEN ("2026-10-14 ~15:20", VOR dem Start laut Text; erster Logeintrag beider Arme 15:05:13). VORAB NICHT BELEGT: Die Uhrzeit im Abschnittskopf liegt nach dem Start der Logs, die Datei wurde zuletzt 2026-10-14 20:09:23 geändert; das Kriterium ist eingetragen, das Urteil daher beobachtung.):
  Zwei Arme je 3 Saaten, Vergleich jeweils nd32h2_e32, ungepaart. e64: altes Format, 64 Epochen, Abklingen 180.544 Schritte (Epochen und Abklingdauer gemeinsam). ta32: Vokabular noten_takt (108), jede Zeile beginnt mit ihrer Taktart, gleiche Melodien in gleicher Reihenfolge, 32 Epochen (Format, Genesis und Fensterschnitt ändern sich gemeinsam). Urteilsgröße: Formquote T=1,0, 500 Ziehungen (Saat 4711). ta32 gegen e32 über "quote": jede Saat über 110 % des e32-Mittels 14,3 % = besser, alle unter 90 % = schlechter, sonst Gleichstand/saatabhängig; quote_angesagt beschreibend. e64 gegen e32: dieselbe Regel. Held-out-Loss nur beschreibend (ta32 nicht vergleichbar). Kontrollen Formsonde: heldout_takt 219/219; Rot mit vertauschten Taktart-Token: quote 219/219, quote_angesagt 0/219.
Plan: rechner-a:~/snai_pruef/knirps/noten/kriterien.txt
Baut auf: snai/noten-form
Darauf baut: snai/noten-breite64
Rezepte:
  r149 [2026-10-21] nd32h2_e64_s1..3 (VOK=noten), ntakt_e32_s1..3 (VOK=noten_takt): cd ~/snai_pruef/knirps/proj_ow && VOK=<noten|noten_takt> ../noten/lauf_noten.sh <arm> 0.001 <segmente> <genesis> <decay_steps>  (je Segment: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=$DECAY nice -n 10 php train_cluster.php <seg> <aus> 1 1 <vorstand> 3 0.001 0.0001 1 0.1)
      quelltext: knirps/proj_ow (Lade-Wächter aus), libcortex.so md5 563780e32333; noten/lauf_noten.sh 08263f699b5a; noten/bau.py 8067a6954f13, bau2.py d6ee2095b99e; text/mess_text.php 711d818750ae; noten/form_noten.php 76a103a94364 (md5 gekürzt)
      parameter: 32/2/16 x 2, Rezept FALL; e64: 64 Segmente, Abklingen 64 x 2821; ta32: 32 Segmente, Abklingen 32 x 2852 = 91.264, 31.648 Parameter
      seed: Genesis noten_gen_d32h2_s1..3 bzw. notentakt_gen_d32h2_s1..3; Ziehsaat 4711
      rechner: rechner-a (CPU)
      logs: rechner-a:~/.cache/snai_pruef/knirps/ow/noten/nd32h2_e64_s*, ntakt_e32_s*; form.jsonl
      notiz: Prüfung beim Nachtrag: Formquoten und Loss aus form.jsonl/mess.jsonl nachgerechnet. Das e64-Urteil "besser" hängt an Saat 2 mit 16,4 gegen Schwelle 15,7 (knapp; die Projektregel verlangt dann eine Wiederholung auf frischen Daten, die fehlt). Die Uhrzeit im Abschnittskopf liegt einige Minuten NACH dem ersten Logeintrag der Läufe; der Text sagt "VOR dem Start". Ob der Abschnitt wirklich vorher stand, belegen die Dateizeiten nicht (Datei zuletzt 2026-10-14 20:09:23).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/ow/noten/form.jsonl, nd32h2_e64_s*.mess.jsonl, ntakt_e32_s*.mess.jsonl (nachgerechnet)
  m1598 Formquote T=1,0 % (Schwelle besser 15,7) (n = je Lauf) | 20,2 / 17,0 / 14,4 | ta32 | 1/2/3 | 500
  m1599 quote_angesagt T=1,0 % (n = je Lauf) | 20,2 / 16,6 / 14,4 | ta32 | 1/2/3 | 500
  m1600 Formquote T=1,0 % (Schwelle besser 15,7) (n = je Lauf) | 25,4 / 16,4 / 24,6 | e64 | 1/2/3 | 500
  m1601 Vergleich Mittel e32 | 14,3 | e32 | 1-3 | 1500
  m1602 Formquote T=0,8 % | 42,4 / 34,0 / 31,0 | ta32 | 1/2/3 | 500
  m1603 Formquote T=0,8 % | 49,8 / 39,0 / 53,2 | e64 | 1/2/3 | 500
  m1604 Held-out-Loss Endwert (n = Fenster) | 1,179 / 1,161 / 1,184 | e64 | 1/2/3 | 300
  m1605 Held-out-Loss Endwert (andere Token, nicht vergleichbar) (n = Fenster) | 1,210 / 1,218 / 1,180 | ta32 | 1/2/3 | 300
  m1606 Anstieg Held-out über Minimum (n = Segmente) | < 0,01 | e64 | 1-3 | 64
  m1607 Wörtliche Kopien (n = je Lauf) | 0 | beide Arme | 1-3 | 500
Ergebnis e139 [2026-10-21 19:20]: beobachtung
  Fazit: Lesart nach der eingetragenen Regel: teilweise (64 Epochen besser, Taktart-Token Gleichstand). Weil nicht belegt ist, dass das Kriterium vor dem Lauf stand, zählt das nur als Beobachtung. 64 Epochen sind nach der Regel besser als 32 (alle Saaten über 15,7 %, Saat 2 nur knapp mit 16,4 %), das Taktart-Token dagegen bringt nichts Messbares (Gleichstand, eine Saat unter der Schwelle). Widerlegt ist damit die Vermutung, die Fehler kämen vom Erraten der Taktart: Hauptfehler bleibt die falsche Taktsumme. Für den Generator folgt: mehr Epochen vor Formatänderungen; das Token blieb trotzdem drin, weil der Generator die Taktart ansagen muss.
  Offen: Ob Token und 64 Epochen sich addieren (keine Zelle ta64). Knappes e64-Urteil in Saat 2 nicht auf frischer Saat wiederholt.
  Datei: rechner-a:~/snai_pruef/knirps/noten/kriterien.txt
Chronik:
  2026-10-21 19:20 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/noten/kriterien.txt, Abschnitt TAKTART-TOKEN UND 64 EPOCHEN ("2026-10-14 ~15:20", VOR dem Start laut Text; erster Logeintrag beider Arme 15:05:13). VORAB NICHT BELEGT: Die Uhrzeit im Abschnittskopf liegt nach dem Start der Logs, die Datei wurde zuletzt 2026-10-14 20:09:23 geändert; das Kriterium ist eingetragen, das Urteil daher beobachtung.)
  2026-10-21 19:20 Rezept r149 (nd32h2_e64_s1..3 (VOK=noten), ntakt_e32_s1..3 (VOK=noten_takt))
  2026-10-21 19:20 Status geplant -> laeuft (Rezept r149)
  2026-10-21 19:20 Messwerte m1598-m1607
  2026-10-21 19:20 Ergebnis e139: beobachtung
  2026-10-21 19:20 Status laeuft -> ausgewertet (Ergebnis e139)
```
