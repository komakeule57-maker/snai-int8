# snai/attfix

```text
snai/attfix - ausgewertet, begonnen 2026-10-09, angelegt 2026-10-21, zuletzt 2026-10-21 19:26
!! ohne Kriterium
Frage: Behebt der Attention-Rückwärts-Fix (2026-10-09) die abweichenden Gradientenzeilen gegen die Referenz?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Plan: Vergleich der Rückwärtszeilen ohne und mit Fix an zwei Checkpoints (s0, s19).
Rezepte:
  r167 [2026-10-21] bash diagnose/verify_att_bw_softmax.sh
      quelltext: Projektbaum snai_edge_int8_lora, Stand 2026-10-09 (Commit nicht notiert)
      parameter: Checkpoints s0 und s19 von prod512
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/rueckwaerts/
Messwerte (Groesse | Wert | Arm | Start | n):
 ; diagnose/verify_att_bw_softmax.sh. Prüfung: Zahl 46.032 ohne Gesamtzahl der Zeilen für s0 überliefert; s0/s19 sind Segmente (Arm), keine Saat.
  m2014 abweichende Zeilen ohne Fix | 12.346 von 49.104 | s19 |  | 1
  m2015 abweichende Zeilen mit Fix | 0 von 49.104 | s19 |  | 1
  m2016 abweichende Zeilen ohne Fix | 46.032 | s0 |  | 1
  m2017 abweichende Zeilen mit Fix | 0 | s0 |  | 1
Ergebnis e157 [2026-10-21 19:26]: beobachtung
  Fazit: Mit dem Fix weicht keine Zeile mehr ab, ohne ihn ein Viertel (s19) bis fast alle (s0). Der Fix wirkt also auf genau die Rechnung, die er treffen soll. Weil die Sollwerte erst nach dem Messen notiert wurden, zählt das als Beobachtung; inhaltlich ist die Lage eindeutig.
  Offen: Ob der Fix die Trainingsqualität messbar ändert, war nicht Gegenstand.
  Datei: rechner-a:~/Projekte/snai_edge_int8_lora/diagnose/verify_att_bw_softmax.sh
Chronik:
  2026-10-21 19:26 angelegt (Nachtrag: Nachtrag 2026-10-21 (Vorbefund, rechner-b ~/snai_pruef/rueckwaerts/) und rechner-a ~/Projekte/snai_edge_int8_lora/diagnose/verify_att_bw_softmax.sh. Die Sollwerte stehen im Kopf des Prüfskripts, also nach den Messungen geschrieben: kein Kriterium vorab.)
  2026-10-21 19:26 Rezept r167
  2026-10-21 19:26 Status geplant -> laeuft (Rezept r167)
  2026-10-21 19:26 Messwerte m2014-m2017
  2026-10-21 19:26 Ergebnis e157: beobachtung
  2026-10-21 19:26 Status laeuft -> ausgewertet (Ergebnis e157)
```
