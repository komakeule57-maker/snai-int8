# snai/tiefe-budget-r2

```text
snai/tiefe-budget-r2 - ausgewertet, angelegt 2026-11-05, zuletzt 2026-11-05 01:50
Frage: Wächst der Nutzen von Tiefe und mittleren FFN von 9k auf 27k auch bei gleicher Planform, mit Warmup 7,4 % in beiden? Damit wird Budget gegen Warmup-Anteil getrennt.
Kriterium (festgelegt 2026-11-05 00:38, vor dem ersten Messwert):
  Wortlaut: rechner-a ~/snai_pruef/stell/KRITERIEN_tiefe27.md, Abschnitt Stufe 2, festgelegt 00:40 vor dem Lauf.
- Arme: W9w, W9ow, Z9w mit Warmup 667, sonst wie W9, W9o, Z9.
- Größen: BTw = (Z27 − EW) − (Z9w − W9w) und BFw = (EWo − EW) − (W9ow − W9w).
- Urteil wie Stufe 1:
  - WÄCHST: Mittel ≥ +0,02 UND > 0 in 6/8.
  - WÄCHST NICHT: Betrag Mittel < 0,01 UND Betrag < 0,02 in 6/8.
  - Sonst OFFEN.
  - Knapp: Dann kommen heldout2 und ein Bootstrap dazu.
- Lesart:
  - BTw WÄCHST: Das Budget ist als Ursache isoliert.
  - BTw WÄCHST NICHT: Die Ursache ist der Warmup-Anteil.
- Nebengröße WT = (Z9w − W9w) − (Z9 − W9), nur berichtet.
Plan: rechner-a:~/snai_pruef/stell/KRITERIEN_tiefe27.md
Baut auf: snai/tiefe-budget-r
Rezepte:
  r592 [2026-11-05] cd ~/snai_pruef/stell && setsid -f nohup ./reihe_tiefe27w.sh > log/tiefe27w.out 2>&1
      quelltext: reihe_tiefe27w.sh, per assert aus reihe_tiefe27.sh erzeugt. Lib c5f9fbaf, Worker de34a553, lauf_stell ecd0d42a, wie Stufe 1.
      parameter: Warmup 667, START 8102, STEPS 9002, Boden 0,1, kurz9000, F 11,3137085, LR 0,003
      seed: s4–s11
      rechner: rechner-a CPU, 12 zugleich
      logs: rechner-a:~/snai_pruef/stell/log/tiefe27w.log, laeufe/tiefe27w/*
      notiz: Start 2026-11-05 00:38. Ende erwartet gegen 01:50.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a ~/snai_pruef/stell/werkzeug/ausw_tiefe27w.py (01f52d70), log/tiefe27w.log
  m8914 GT9w=Z9w-W9w heldout Mittel | -0,0057 (pos 3/8, BS -0,0151..+0,0031) OFFEN | GT9w | s4-s11 | 8
  m8915 BTw=GT27-GT9w heldout Mittel | +0,0355 (8/8, BS +0,0282..+0,0433) WAECHST MIT BUDGET | BTw | s4-s11 | 8
  m8916 GF9w=W9ow-W9w heldout Mittel | -0,0143 (neg 7/8, BS -0,0258..-0,0062) OFFEN | GF9w | s4-s11 | 8
  m8917 BFw=GF27-GF9w heldout Mittel | +0,0396 (8/8, BS +0,0317..+0,0513) WAECHST MIT BUDGET | BFw | s4-s11 | 8
  m8918 WT=GT9w-GT9 (nur berichtet) | -0,0100 (BS -0,0193..+0,0001) | WT | s4-s11 | 8
  m8919 heldout Mittel W9w/W9ow/Z9w | 2,4482 / 2,4339 / 2,4425 | alle | s4-s11 | 8
  m8920 Kontrollen rc0/STEPS 9002/emb11/messF11 3/korrigiert 0, LR t1 4,5e-6 | 24/24 | alle | s4-s11 | 24
  Quelle: rechner-a ho2_tiefe27w.sh, log/tiefe27w_ho2.jsonl, ausw_tiefe27w.py --ho2
  m8938 BTw heldout2 Mittel | +0,0351 (8/8, BS +0,0290..+0,0412) WAECHST MIT BUDGET | BTw | s4-s11 | 8
  m8939 BFw heldout2 Mittel | +0,0375 (8/8, BS +0,0282..+0,0495) WAECHST MIT BUDGET | BFw | s4-s11 | 8
  m8940 GT9w heldout2 Mittel | -0,0041 GLEICH | GT9w | s4-s11 | 8
Ergebnis e540 [2026-11-05 01:47]: erfuellt
  Fazit: BTw und BFw wachsen nach Wortlaut mit dem Budget, je 8/8, nicht knapp. Nach der vorab festgelegten Lesart ist damit das Budget als Ursache isoliert. Bei gleicher Planform (Warmup 7,4 %) tragen Tiefe und mittlere FFN bei 9k nichts (128x4 ohne mittlere FFN ist dort sogar 0,014 besser), bei 27k mit dreifachem Text je 0,025–0,030. Der Warmup-Anteil erklärt den Zuwachs aus Stufe 1 nicht, mit gleichem Anteil wird er sogar größer. Die „nutzlosen“ mittleren Schichten sind also unterforderte Kapazität bei zu kleinem Budget, kein Defekt.
  Offen: Ob neue Daten oder nur mehr Schritte wirken, ist offen, denn beides ändert sich gemeinsam. Offen sind auch die Schwelle, ab der Tiefe sich bei 128 lohnt, und die Übertragbarkeit auf große Breiten. Die Reichweite ist 128, ein Text, 8 Saaten.
  Datei: rechner-a:~/snai_pruef/stell/ERGEBNIS_tiefe27.md
Chronik:
  2026-11-05 00:38 angelegt
  2026-11-05 00:38 Rezept r592
  2026-11-05 00:38 Status geplant -> laeuft (Rezept r592)
  2026-11-05 01:47 Messwerte m8914-m8920
  2026-11-05 01:47 Ergebnis e540: erfuellt
  2026-11-05 01:47 Status laeuft -> ausgewertet (Ergebnis e540)
  2026-11-05 01:50 Messwerte m8938-m8940
```
