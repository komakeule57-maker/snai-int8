# snai/noten-form

```text
snai/noten-form - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:21
Frage: Wie viele frei gezogene Melodien des Noten-Knirpses sind formkorrekt (parse_melody aus dem Notensammler), im Vergleich zum Trigramm und zwischen 8 und 32 Epochen?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/noten/kriterien.txt, Abschnitt FORMSONDE (2026-10-14, "festgelegt VOR der ersten Messung an einem trainierten Modell"; Messungen in form.jsonl).):
  Prüfer parse_melody() aus dem Noten-Sammler unverändert; formkorrekt = angenommen für mindestens eine der 4 Taktarten und eine der 4 Lagen. Ziehen ab "</s>\n" bis </s> oder 200 Token (sonst "kein Ende"); T = 1,0 ist Urteilsgröße, T = 0,8 beschreibend. Je Modell 500 Melodien (Saat 4711); Trigramm 3 Saaten (4711-4713) zu je 500. Kontrollen vorab: Held-out 219/219 formkorrekt, 0 Kopien; Rot: Genesis 0/100. Urteil: Knirps besser als Trigramm, wenn jede der 3 Saaten über 110 % des Trigramm-Mittels liegt; alle unter 90 % = schlechter; sonst Gleichstand/saatabhängig. Daneben: wörtliche Trainingskopien, Verwerfungsgründe. 8 gegen 32 Epochen: gleiche Regel, nicht gepaart.
Plan: rechner-a:~/snai_pruef/knirps/noten/kriterien.txt
Baut auf: snai/noten-epochen32
Darauf baut: snai/noten-takt-e64
Rezepte:
  r152 [2026-10-21] cd ~/snai_pruef/knirps/proj_ow && SNAI_VOCAB=../vokabular/noten.json php ../noten/form_noten.php modell <ckpt> 500 <T> | tri ../noten/ngram.json 500 1.0 <saat> | heldout <datei>
      quelltext: noten/form_noten.php 76a103a94364; parse_melody aus dem Noten-Sammler (unverändert)
      parameter: Modelle noten_nd32h2_s{1,2,3}_s7 und noten_nd32h2_e32_s{1,2,3}_s31; 500 Ziehungen, T 1,0 und 0,8, max. 200 Token
      seed: Ziehsaat 4711; Trigramm 4711/4712/4713
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/ow/noten/form.jsonl
      notiz: Ersetzt r148: dort stand eine beim Übertragen erschlossene Aufrufform; dies ist der Befehl aus dem Entwurf. Prüfung beim Nachtrag: Alle Formquoten aus form.jsonl abgelesen. Die Held-out- und Genesis-Kontrolle stehen nicht in form.jsonl, übernommen.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/ow/noten/form.jsonl (nachgerechnet); Kontrollen: nicht nachgerechnet
  m1588 Formquote T=1,0 % (n = je Saat) | 0 / 0 / 0 | Trigramm | 4711/4712/4713 | 500
  m1589 Formquote T=1,0 % (n = je Lauf) | 3,6 / 3,2 / 2,8 | 8 Epochen | 1/2/3 | 500
  m1590 Formquote T=1,0 % (n = je Lauf) | 7,2 / 16,0 / 19,6 | 32 Epochen | 1/2/3 | 500
  m1591 Mittel Formquote T=1,0 % | 14,3 | 32 Epochen | 1-3 | 1500
  m1592 Formquote T=0,8 % (n = je Lauf) | 11,6 / 6,4 / 6,2 | 8 Epochen | 1/2/3 | 500
  m1593 Formquote T=0,8 % (n = je Lauf) | 21,2 / 41,2 / 40,8 | 32 Epochen | 1/2/3 | 500
  m1594 Wörtliche Trainingskopien unter den formkorrekten (n = je Lauf) | 0 | alle 6 Modelle | 1-3 | 500
  m1595 Häufigster Verwerfungsgrund (n = je Lauf) | Taktsumme falsch (55-75 %) | alle | 1-3 | 500
  m1596 Kontrolle Held-out formkorrekt | 219/219 | Held-out |  | 219
  m1597 Rot-Probe Genesis formkorrekt | 0/100 | Genesis s1 | 1 | 100
Ergebnis e138 [2026-10-21 19:20]: erfuellt
  Fazit: Der Knirps schlägt das Trigramm in der Form (Trigramm 0 %), und 32 Epochen sind nach der Regel klar besser als 8 (Mittel 14,3 % gegen 3,2 %, alle Saaten über der Schwelle), obwohl der Loss nur 8 % sank. Daraus folgte die Arbeitsregel: für Noten zählt die Formsonde, nicht der Loss. Die Quote streut stark zwischen Saaten (7-20 %), und Hauptfehler bleibt die falsche Taktsumme; auswendig gelernt wird nichts.
  Offen: Eine Zelle, ein Korpus, ctx 64. 6/8 erscheint als 3/4 (gleiche Taktsumme).
  Datei: rechner-a:~/snai_pruef/knirps/noten/kriterien.txt
Abgeloest und ausgeblendet: 1 rezept - voll=True zeigt sie.
Chronik:
  2026-10-21 19:20 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/noten/kriterien.txt, Abschnitt FORMSONDE (2026-10-14, "festgelegt VOR der ersten Messung an einem trainierten Modell"; Messungen in form.jsonl).)
  2026-10-21 19:20 Rezept r148
  2026-10-21 19:20 Status geplant -> laeuft (Rezept r148)
  2026-10-21 19:20 Messwerte m1588-m1597
  2026-10-21 19:20 Ergebnis e138: erfuellt
  2026-10-21 19:20 Status laeuft -> ausgewertet (Ergebnis e138)
  2026-10-21 19:21 Rezept r152, loest r148 ab
```
