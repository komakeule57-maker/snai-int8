# snai/tiefe-budget-r

```text
snai/tiefe-budget-r - ausgewertet, angelegt 2026-11-04, zuletzt 2026-11-05 01:47
Frage: Wächst unter Rezept R der Nutzen von Tiefe (128x4 gegen 128x2) und von den mittleren FFN (L1–L3) mit dem Budget, also mit Schritten und Text zusammen, von 9k auf 27k? Das ist der letzte Kandidat für die Ursache der „nutzlosen Schichten“, nachdem 8 Bit, Gains und Breite ausgeschlossen sind.
Kriterium (festgelegt 2026-11-04 22:36, vor dem ersten Messwert):
  Wortlaut steht in rechner-a ~/snai_pruef/stell/KRITERIEN_tiefe27.md (c9c41e2d, mit Prüfer-Nachtrag).
- Je Saat s4–s11:
  - Tiefe: BT = (Z27 − EW) − (Z9 − W9).
  - Mittlere FFN: BF = (EWo − EW) − (W9o − W9).
  - Gemessen wird der Held-out mit 700 Fenstern.
- Urteil, getrennt für BT und BF:
  - WÄCHST MIT BUDGET: Mittel ≥ +0,02 UND > 0 in 6/8.
  - WÄCHST NICHT: Betrag Mittel < 0,01 UND Betrag < 0,02 in 6/8.
  - SCHRUMPFT: spiegelbildlich.
  - Sonst OFFEN.
  - Knapp heißt 0,003 an einer Schwelle oder genau 6/8. Dann kommen heldout2 und ein gepaarter Bootstrap dazu.
- Zweite Lesart: GT9 gegen Z aus e473 (0,0347). Liegt der Abstand nicht innerhalb von 0,01, ist BT mit dem Warmup-Anteil vermischt.
- Rot-Proben:
  - Messpfad: Z27 s4 ohne F muss mehr als 1 nat schlechter sein.
  - Auswertung: GT9 gegen sich selbst muss WÄCHST NICHT ergeben.
Plan: rechner-a:~/snai_pruef/stell/KRITERIEN_tiefe27.md
Baut auf: snai/stell-reparatur27, snai/tiefe-128x2-massstab, snai/budget-tiefe, snai/baum-wsd
Darauf baut: snai/tiefe-budget-r2, snai/stell-lr-gruppen
Rezepte:
  r591 [2026-11-04] cd ~/snai_pruef/stell && setsid -f nohup ./reihe_tiefe27.sh > log/tiefe27.out 2>&1
      quelltext: Prüfstand wie rep27: Lib bau_stell c5f9fbaf, train_worker de34a553, lauf_stell.sh ecd0d42a. Genesis clip_gen_s4 882308c1, clip_gen_ef0_s4 8d7e5806, clip_gen_z2_s4 52468009 (neu, init_base 0 128 128 2 512 s, 9.361.948 Byte). Reproduktionsprobe clip_gen_s4 = 882308c1 bestanden.
      parameter: W9, W9o, Z9: 9k auf kurz9000 (Plan START 8102, STEPS 9002). Z27: 27k auf kurz27000 (START 24316, STEPS 27018). Warmup 2000, Boden 0,1, F 11,3137085 per Umgebung, LR 0,003, 12 Läufe zugleich. Bezüge EW und EWo aus laeufe/rep27.
      seed: s4–s11, Fensterfolge über den Sitzungsnamen clip_s<s>
      rechner: rechner-a CPU, 12 zugleich
      logs: rechner-a:~/snai_pruef/stell/log/tiefe27.log, laeufe/tiefe27/*
      notiz: Start 2026-11-04 22:34. Ende erwartet gegen 01:00.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a ~/snai_pruef/stell/werkzeug/ausw_tiefe27.py (f72a286a; Probe gruen, rot gesehen), log/tiefe27.log, log/tiefe27_ho2.jsonl (ho2_tiefe27.sh 5cd2c93b)
  m8902 GT9=Z9-W9 heldout Mittel | +0,0043 (pos 6/8, BS -0,0039..+0,0127) GLEICH | GT9 | s4-s11 | 8
  m8903 GT27=Z27-EW heldout Mittel | +0,0299 (8/8, BS +0,0273..+0,0329) TRAEGT | GT27 | s4-s11 | 8
  m8904 BT=GT27-GT9 heldout Mittel | +0,0255 (8/8, BS +0,0190..+0,0329) WAECHST MIT BUDGET | BT | s4-s11 | 8
  m8905 BT heldout2 Mittel | +0,0272 (8/8, BS +0,0218..+0,0335) WAECHST MIT BUDGET | BT | s4-s11 | 8
  m8906 GF9=W9o-W9 heldout Mittel | +0,0022 (BS -0,0045..+0,0090) GLEICH | GF9 | s4-s11 | 8
  m8907 GF27=EWo-EW heldout Mittel | +0,0253 (8/8) TRAEGT | GF27 | s4-s11 | 8
  m8908 BF=GF27-GF9 heldout Mittel | +0,0231 (8/8, BS +0,0137..+0,0321) WAECHST MIT BUDGET | BF | s4-s11 | 8
  m8909 BF heldout2 Mittel | +0,0242 (8/8, BS +0,0161..+0,0323) WAECHST MIT BUDGET | BF | s4-s11 | 8
  m8910 Zweite Lesart GT9 gegen e473 Z 0,0347 | Abstand 0,0304, nicht innerhalb 0,01: mit Warmup-Anteil vermischt | GT9 | s4-s11 | 8
  m8911 heldout Mittel W9/W9o/Z9/Z27 | 2,4291 / 2,4313 / 2,4335 / 2,2622 | alle | s4-s11 | 8
  m8912 Rot Messpfad Z27 s4 ohne F | 4,8066 | Z27 | 4 | 1
  m8913 Kontrollen rc0/STEPS/emb11/messF11 3/tie/SR/layers/korrigiert 0 | 32/32 | alle | s4-s11 | 32
Ergebnis e541 [2026-11-05 01:47]: erfuellt
  Fazit: BT und BF wachsen nach Wortlaut mit dem Budget, auf beiden Held-out-Texten, je 8/8, nicht knapp. Die vorab festgelegte zweite Lesart meldete eine Vermischung mit dem Warmup-Anteil. Stufe 2 (snai/tiefe-budget-r2, e-Ergebnis dort) hat das aufgelöst: Bei gleichem Warmup-Anteil wächst der Nutzen sogar stärker. Das Budget ist damit als Ursache isoliert.
  Offen: Neue Daten gegen mehr Schritte. Nur Breite 128 geprüft.
  Datei: rechner-a:~/snai_pruef/stell/ERGEBNIS_tiefe27.md
Abgeloest und ausgeblendet: 1 ergebnis - voll=True zeigt sie.
Chronik:
  2026-11-04 22:36 angelegt
  2026-11-04 22:36 Rezept r591
  2026-11-04 22:36 Status geplant -> laeuft (Rezept r591)
  2026-11-05 00:38 Messwerte m8902-m8913
  2026-11-05 00:38 Ergebnis e539: erfuellt
  2026-11-05 00:38 Status laeuft -> ausgewertet (Ergebnis e539)
  2026-11-05 01:47 Ergebnis e541: erfuellt, loest e539 ab
```
