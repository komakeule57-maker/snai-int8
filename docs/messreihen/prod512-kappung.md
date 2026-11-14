# snai/prod512-kappung

```text
snai/prod512-kappung - ausgewertet, begonnen 2026-09-23, angelegt 2026-10-21, zuletzt 2026-10-21 19:31
!! ohne Kriterium
Frage: Wie groß ist der Versatz zwischen der gekappten Held-out-Zahl (erste 64 Fenster) und der vollen (alle 632 Fenster) bei prod512, und ist er über die Reifestände konstant?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Baut auf: snai/prod512-lauf
Rezepte:
  r194 [2026-10-21] SNAI_FORCE_CPU=1 php eval_held_out_full_i8.php factory/checkpoints/prod512_sN.snai factory/holdout_prod/ auto 0 (alle 632 Fenster), 3 Fäden, nice -n 19
      quelltext: rechner-a:~/Projekte/snai_edge_int8_lora/eval_held_out_full_i8.php (Stand 2026-09-23 nicht festgehalten)
      parameter: ho_prod: 2.200.001 Byte, 646.882 Token, 632 Fenster, ctx 1024
      seed: deterministisch
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/heldout_full_i8_prod512_sN_kappung_sN.jsonl; rechner-a:~/.cache/prod512/kappung_s*.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: 632-Fenster-Werte s1/s5/s9 aus rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/heldout_full_i8_prod512_sN_kappung_sN.jsonl abgelesen; s11 (4,116743) und Empfindlichkeitsprobe, nicht nachgerechnet
  m2341 Held-out 64 / 632 Fenster | 4,927107 / 5,010712 | prod512 s1 |  | 632
  m2342 Held-out 64 / 632 Fenster | 4,262638 / 4,368865 | prod512 s5 |  | 632
  m2343 Held-out 64 / 632 Fenster | 4,055196 / 4,186372 | prod512 s9 |  | 632
  m2344 Held-out 64 / 632 Fenster | 4,000745 / 4,116743 | prod512 s11 |  | 632
  m2345 Versatz | +0,0836 / +0,1062 / +0,1312 / +0,1160 | s1 / s5 / s9 / s11 |  | 632
  m2346 Abbruchprognose Empfindlichkeit (je ein Punkt weg) | s23 bis s32 voll, s18 bis s29 gekappt | prod512 |  | 4
Ergebnis e181 [2026-10-21 19:31]: beobachtung
  Fazit: Der Versatz wächst erst (0,08 auf 0,13) und fällt dann (0,12), er ist weder konstant noch monoton; die gekappte Zahl ist also kein fester Abschlag auf die volle. Eine Richtungsaussage aus zwei Ständen (die frühere Behauptung 'gekappt unterschätzt um 28 %') war falsch. Wichtiger für die Planung: ein Potenzgesetz auf vier Punkten trägt keine Terminfrage, die Abbruchprognose streut je nach weggelassenem Punkt von s18 bis s32. Vor einer echten Abbruchentscheidung gehört die volle 632-Fenster-Messung auf den aktuellen Stand.
  Offen: s11-Wert nicht als lokale Datei gefunden.
Chronik:
  2026-10-21 19:31 angelegt (Nachtrag: Kein Entscheidungskriterium vorab; die Fassung vom 2026-09-23 nennt nur die Messvorschrift (derselbe Prüfsatz, auto 0 gegen auto 64, Präfixgleichheit bei Fenster 20/40/60 geprüft).)
  2026-10-21 19:31 Rezept r194
  2026-10-21 19:31 Status geplant -> laeuft (Rezept r194)
  2026-10-21 19:31 Messwerte m2341-m2346
  2026-10-21 19:31 Ergebnis e181: beobachtung
  2026-10-21 19:31 Status laeuft -> ausgewertet (Ergebnis e181)
```
