# snai/stell-lr-leiter

```text
snai/stell-lr-leiter - ausgewertet, angelegt 2026-11-05, zuletzt 2026-11-05 13:07
Frage: Wo liegt bei 128x4 (Rezept R) das Optimum der Spitzen-LR unter 0,0015 (Leiter 0,001 / 0,00075 / 0,0005 bei 9k), und hält der Gewinn gegen 0,003 bei 27k Schritten mit dreifachem Text? Auftrag 2026-11-05 nach e543.
Kriterium (festgelegt 2026-11-05 10:06, vor dem ersten Messwert):
  Wortlaut: rechner-a ~/snai_pruef/stell/KRITERIEN_lrleiter.md (md5 42223de8, mit Prüfer-Nachtrag, vor dem Start).
Regel je Vergleich wie e543: BESSER D<0 in >=6/8 und Mittel <= −0,02; SCHLECHTER spiegelbildlich; GLEICH Betrag Mittel < 0,01 und Betrag D < 0,02 in >=6/8; sonst OFFEN; knapp -> heldout2.
Stufe 1 (9k): L10, L075, L05 je 8 Saaten, Bezug G05 aus snai/stell-lr-gruppen. Kette D1 = L10−G05, D2 = L075−L10, D3 = L05−L075. L* = von 0,0015 abwärts, solange der nächste Schritt BESSER ist. Urteil: EINGEGRENZT (Schritt nach L* SCHLECHTER), FLACH UNTER L* (GLEICH), OFFEN, NICHT EINGEGRENZT (L* = 0,0005). Nur berichtet: jeder Arm gegen G05 und W9; Nichtmonotonie als Abweichung.
Stufe 2 (27k, kurz27000): E* = L* gegen EW (0,003, rep27), KW27 s4 muss md5-gleich EW_s4 (2b0398db) sein. Urteil: GEWINN HÄLT BEI 27k (BESSER), VERSCHWINDET (GLEICH), KEHRT UM (SCHLECHTER), sonst OFFEN.
Plan: rechner-a:~/snai_pruef/stell/KRITERIEN_lrleiter.md
Baut auf: snai/stell-lr-gruppen, snai/stell-reparatur27
Darauf baut: snai/noten-r, snai-evo/r-welt, snai/stell-lr1024
Rezepte:
  r597 [2026-11-05] Stufe 1: cd ~/snai_pruef/stell && setsid nohup ./reihe_lrleiter.sh > log/lrleiter.out 2>&1 < /dev/null &
      quelltext: reihe_lrleiter.sh e42be91e (aus reihe_lrgruppen.sh 7d14188f per assert); Lib bau_tie a4359087 ohne Stellrad; Trainer de34a553; lauf_stell.sh ecd0d42a
      parameter: Rezept R 128x4 9k (F, Warmup 2000, Decay 8102-9002, Boden 0,1), CLIP_LR 0,001 / 0,00075 / 0,0005 (Arme L10/L075/L05)
      seed: s4-s11
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/stell/log/lrleiter.log, laeufe/lrleiter/*, log/lrleiter_gains.jsonl
      notiz: Start 10:06. Stufe 2 (27k) startet erst nach Auswertung von Stufe 1 mit eigenem Rezept.
  r599 [2026-11-05] Stufe 2: cd ~/snai_pruef/stell && setsid nohup ./reihe_lrleiter27.sh E15 0.0015 > log/lrleiter27.out 2>&1 < /dev/null &
      quelltext: reihe_lrleiter27.sh 0c61357a (aus reihe_lrleiter.sh per assert, vor Stufe 1 geschrieben); Lib bau_tie a4359087; Trainer de34a553; lauf_stell.sh ecd0d42a
      parameter: L* = 0,0015 nach Regel (Stufe 1 FLACH UNTER L*). 128x4, kurz27000, 27018 Schritte, Warmup 2000, Decay 24316-27018, Boden 0,1, F, gebunden; E15 x 8 Saaten, KW27 s4 bei 0,003 (muss md5 2b0398db = EW_s4 sein)
      seed: s4-s11
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/stell/log/lrleiter27.log, laeufe/lrleiter27/*
      notiz: Start 11:29, 9 Läufe zugleich, Ende grob 13:45.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a ~/snai_pruef/stell/werkzeug/ausw_lrleiter.py (4b9d6d35, Probe grün und rot gesehen), log/lrleiter.log
  m9051 Kontrollen Stufe 1, 24 Läufe | rc 0, STEPS_DONE 9002, messF11 3, tie 1, sr 1, TieLR 1.0, layers 4, korrigiert 0, messerr 0, Gains-Fehlerkanal leer; LR an den Stützstellen = Spitze x (5e-4/1/1/0,1) | L10, L075, L05 | s4-s11 | 24
  m9052 D1 L10-G05 heldout | -0.0063 | 7/8 negativ, 8/8 Betrag < 0,02, BS -0,0104..-0,0026, GLEICH, nicht knapp | s4-s11 | 8
  m9053 D2 L075-L10 heldout | +0.0042 | 1/8 negativ, 8/8 Betrag < 0,02, BS -0,0025..+0,0099, GLEICH | s4-s11 | 8
  m9054 D3 L05-L075 heldout | +0.0255 | 0/8 negativ, BS +0,0222..+0,0292, SCHLECHTER | s4-s11 | 8
  m9055 Wahl Stufe 1 | L* = 0,0015 (G05), Urteil FLACH UNTER L* | - | s4-s11
  m9056 nur berichtet, Arm gegen G05 | L075 -0,0020 GLEICH (knapp); L05 +0,0234 SCHLECHTER | - | s4-s11 | 8
  m9057 nur berichtet, Arm gegen W9 (0,003) | G05 -0,0479; L10 -0,0542; L075 -0,0500; L05 -0,0245, alle BESSER 8/8 | - | s4-s11 | 8
  m9058 Mittel heldout | W9 2,4291; G05 2,3812; L10 2,3749; L075 2,3791; L05 2,4046 | alle | s4-s11 | 8
  m9059 Tote L2-ffn-Gains | 0 % in allen Saaten bei G05, L10, L075, L05 (W9 0,8 %) | alle | s4-s11 | 8
  Quelle: rechner-a ~/snai_pruef/stell/log/lrleiter27.log, ausw_lrleiter.py --27, log/lrleiter27_gains.jsonl, log/rep27_gains.jsonl
  m9071 Kontrollen Stufe 2, 9 Läufe | rc 0, STEPS_DONE 27018, messF11 3, tie 1, sr 1, TieLR 1.0, layers 4, korrigiert 0, messerr 0, Gains-Fehlerkanal leer | E15, KW27 | s4-s11 | 9
  m9072 KW27-Endstand md5 | 2b0398db = EW_s4, Bezug EW gültig | KW27 | 4 | 1
  m9073 E15-EW heldout 27k | -0.0476 | 8/8 negativ, kleinster Betrag 0,043, BS -0,0492..-0,0458, BESSER, GEWINN HÄLT BEI 27k | s4-s11 | 8
  m9074 Mittel heldout 27k | E15 2,1847; EW 2,2323 | E15, EW | s4-s11 | 8
  m9075 Tote FFN-Gains 27k L1/L2 Mittel | EW 10,1 % / 9,5 %; E15 0,6 % / 1,2 % | E15, EW | s4-s11 | 8
Ergebnis e548 [2026-11-05 13:07]: erfuellt
  Fazit: Stufe 1 FLACH UNTER L*: Bei 128x4/Rezept R/9k sind 0,0015, 0,001 und 0,00075 GLEICH (alle rund −0,05 gegen 0,003), 0,0005 SCHLECHTER (+0,026). L* = 0,0015. Stufe 2 GEWINN HÄLT BEI 27k: 0,0015 gegen 0,003 −0,048 (8/8, nicht knapp), gleich groß wie bei 9k. Bei 27k sterben unter 0,003 rund 10 % der L1/L2-FFN-Gains, unter 0,0015 rund 1 %. Folge: Für 128x4 ist 0,0015 die bessere Vorgabe für Rezept R. Über die Übernahme wird gesondert entschieden. Breite×LR der Ebene 0,096–0,19 (multi_stack e547: Richtung 1/Breite, Vorfaktor rezeptabhängig).
  Offen: Plan R (−0,22) und die Budget-Ursache der mittleren Schichten unter 0,0015 nicht nachgemessen; welche Parametergruppe den Gewinn trägt; andere Breiten (kurze Leiter je Rezept).
  Datei: rechner-a:~/snai_pruef/stell/ERGEBNIS_lrleiter.md
Chronik:
  2026-11-05 10:06 angelegt
  2026-11-05 10:07 Rezept r597 (Stufe 1)
  2026-11-05 10:07 Status geplant -> laeuft (Rezept r597)
  2026-11-05 11:29 Messwerte m9051-m9059
  2026-11-05 11:29 Rezept r599 (Stufe 2)
  2026-11-05 13:07 Messwerte m9071-m9075
  2026-11-05 13:07 Ergebnis e548: erfuellt
  2026-11-05 13:07 Status laeuft -> ausgewertet (Ergebnis e548)
```
