# snai/wdg-norm

```text
snai/wdg-norm - ausgewertet, angelegt 2026-11-01, zuletzt 2026-11-02 17:18
Frage: Aendert Decay auf den RMSNorm-Gains den Anstieg der Gradientennorm beim Abkuehlen?
Kriterium (festgelegt 2026-11-01 22:13, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/clip/kriterien_wdg.txt Teil B. Start c128sr s4, LR 2,5e-4, 30.000 Fenster, skala_r1-r3, Arm G (Decay 0,1 auf Gains) gegen dc_K1. GF bei LR 0, train_a, k=1; A = GF - GF(s4), Q = A(G)/A(K1). SENKT <= 0,5, GLEICH [0,8; 1,25], HEBT >= 1,5, je 3/3, sonst OFFEN. Held-out wie dclang.
Plan: rechner-a:~/snai_pruef/clip/kriterien_wdg.txt
Baut auf: snai/dauerclip-lang, snai/gradnorm-skala
Darauf baut: snai/skala-norm, snai/norm-je-tensor, snai/skalenwanderung-final, snai/wdg-final
Rezepte:
  r499 [2026-11-01] rechner-a: Teil von ~/snai_pruef/clip/schlange_bg.sh, Stufe B, je Lauf ./lauf_dg.sh <r> (train_worker.php mit SNAI_CORTEX_LIB=clip/bau_wdg/libcortex.so, SNAI_WD_GAINS=0.1, Rezept wie gradnorm lauf_dc K1)
      quelltext: bau_wdg Lib aa5f61e8, lauf_dg.sh 5d8d8aa0
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/gradnorm/log/dc_G_*
      notiz: Startet nach Stufe A von snai/gains-batchgen.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/gradnorm/werkzeug/auswerten_wdg.py, log/gf_dc_G_r*.log, log/held_dc_G_r*.txt
  m7625 GF | 3,448 | G | r1 | 1710
  m7626 GF | 3,490 | G | r2 | 1710
  m7627 GF | 3,477 | G | r3 | 1710
  m7628 GF | 4,370 | K1 | r1 | 1710
  m7629 GF | 4,370 | K1 | r2 | 1710
  m7630 GF | 4,352 | K1 | r3 | 1710
  m7631 Q = A(G)/A(K1) | 0,359 | G | r1
  m7632 Q = A(G)/A(K1) | 0,387 | G | r2
  m7633 Q = A(G)/A(K1) | 0,384 | G | r3
  m7634 Held-out G-K1 | +0,0145 | G | r1 | 700
  m7635 Held-out G-K1 | +0,0179 | G | r2 | 700
  m7636 Held-out G-K1 | +0,0168 | G | r3 | 700
  m7637 Final-Gain Mittel | 1,76 (K1 2,53, s4 1,95) | G | r1-r3 | 3
  m7638 RMS emb | 0,0571 (K1 0,0485, s4 0,0643) | G | r1-r3 | 3
Ergebnis e459 [2026-11-02 17:18]: erfuellt
  Fazit: SENKT in 3/3: Decay auf den Gains senkt den Anstieg der Norm um rund 62 %, der erste deutlich wirksame Eingriff auf die Norm. Kein Mittel: Held-out in 3/3 etwas schlechter (unter 10 %, Gleichstand nach Hausregel), und beim Kippen verstaerkt derselbe Decay (e434). Hinweis, nicht isoliert: Der Anstieg koennte zum grossen Teil Skala sein, die sich von den schrumpfenden Gewichten in die wachsenden Gains verschiebt. Das prueft ein Gegenversuch ohne Training: Gains durch c, nachfolgende Gewichte mal c, Funktion gleich, GF neu.
  Offen: Skalenthese ungeprueft; ein Modell, ein Start, 3 Reihenfolgen, Decay 0,1 frei; nicht ueber den Abkuehlplan, nicht prod512b.
  Datei: rechner-a:~/snai_pruef/gradnorm/ERGEBNIS_wdg_norm.md
Chronik:
  2026-11-01 22:13 angelegt
  2026-11-01 22:13 Rezept r499
  2026-11-01 22:13 Status geplant -> laeuft (Rezept r499)
  2026-11-02 17:18 Messwerte m7625-m7638
  2026-11-02 17:18 Ergebnis e459: erfuellt
  2026-11-02 17:18 Status laeuft -> ausgewertet (Ergebnis e459)
```
