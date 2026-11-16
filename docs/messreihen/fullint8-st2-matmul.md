# snai/fullint8-st2-matmul

```text
snai/fullint8-st2-matmul - ausgewertet, angelegt 2026-11-15, zuletzt 2026-11-15 18:20
Frage: Rechnen die ganzzahligen Matmuls (vorwärts, d_in rückwärts, Gradientenakkumulation in einen int32-Puffer mit Exponent je Zeile; SNAI_I8_GANZ=2) ohne Gleitkomma, mit denselben Gradienten wie der alte Pfad und ohne Qualitätsverlust gegen Stufe 1? Schritte S1+S2 des Full-int8-Umbaus.
Kriterium (festgelegt 2026-11-15 17:38, vor dem ersten Messwert):
  Volltext docs/messreihen/fullint8/KRITERIEN_ST2.txt (17a5aee7), vor den gezählten Läufen. K1: Stufe 0 mit Lib 4d20c9f3 bytegleich zur Basis (md5 0f79d04c). K2: Bausteinprobe, jeder matfwd-, matbw-din- und matbw-grad-Aufruf unter FE_UPWARD und FE_TONEAREST bytegleich; die Rot-Probe (float-Rundung in matfwd) meldet mindestens eine Abweichung. K3: Gradienten je Tensor relL2 <= 0,05, Kosinus >= 0,995 gegen den alten Pfad. K4: Segment 0, Saaten s1-s3 gepaart, Held-out 300 Fenster, d = (st2-st1b)/st1b <= +2 % in 3/3 (st1b = Stufe 1 mit derselben Lib), sonst Haltepunkt. Urteil erfuellt = K1-K4.
Plan: rechner-a:~/snai_pruef/fullint8/PLAN.md
Baut auf: snai/fullint8-st1-geruest
Darauf baut: snai/fullint8-st3-adam
Rezepte:
  r722 [2026-11-15] K1: SNAI_I8_GANZ=0 ./probe_s0.sh proj_gz ST2K1 - 2 ; K2: SNAI_I8_GANZ=2 SNAI_GZ_KERN=1 [SNAI_GZ_KERN_ROT=1] ./probe_s0.sh proj_gz ST2K2[rot] - 2 ; K3: SNAI_I8_GANZ=2 SNAI_GZ_VERGL=1 ./probe_s0.sh ... ; K4: reihe_kette.sh 1 st1b:1 st2:2 (wartet auf reihe_gz st0/st1, dann reihe_gz.sh)
      quelltext: proj_gz/st1b/st2 = Hauptbaum 1a8edde + patch_s0.py 80fee343 + patch_gz.py 5acb7976 + cortex_gz.nim f93402e0, libcortex.so 4d20c9f3; lauf_gz.sh a06fa6c6, reihe_gz.sh b7d052f9
      parameter: REST=sr, INT8_FULL, LR 0,001, Cosinus 25.000, Warmup 500, CPU 2 Faeden
      seed: Genesis gesch_gen_d96h6L2_s1..s3, Armname gesch_d96h6L2_sN
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/fullint8/log/ (ST2K*.log, st1b/, st2/, reihe_gz.log)
      notiz: Nachgetragen 18:3x: Rezept war beim Start nicht eingetragen. K1-K3 liefen nacheinander (Zeiten 17:38-17:39 ueberlappen nicht), also unberuehrt vom spaeter gefundenen Fehler paralleler Proben im selben Ordner.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: probe_s0.sh, log/ST2K1.log, log/ST2K2.log, log/ST2K2rot.log
  m11310 K1 md5 Stufe 0 mit Lib 4d20c9f3 | 0f79d04c (= Basis) | K1
  m11311 K2 Bausteinprobe Aufrufe gleich | 39 von 39 (13 matfwd, 13 matbw-din, 13 matbw-grad) | K2 | s1
  m11312 K2 Rot (float-Rundung in matfwd) | 13 von 39 abweichend (alle 13 matfwd) | K2rot | s1
  m11313 K3 größter relL2 | 0,00433 (g_w_down[1]) | K3 | s1
  m11314 K3 kleinster Kosinus | 0,999991 | K3 | s1
  m11315 K3 Loss erster Schritt alt / GZ2 | 7,4693184 / 7,4693184 | K3 | s1
  Quelle: log/st1b/ und log/st2/gesch_d96h6L2_sN.mess.jsonl, log/reihe_gz.log (zweite Reihe 17:46-18:09)
  m11328 K4 Held-out Loss Stufe 1 (Lib 4d20c9f3) | 2,6058 | st1b | s1 | 300
  m11329 K4 Held-out Loss Stufe 1 (Lib 4d20c9f3) | 2,6231 | st1b | s2 | 300
  m11330 K4 Held-out Loss Stufe 1 (Lib 4d20c9f3) | 2,6388 | st1b | s3 | 300
  m11331 K4 Held-out Loss Stufe 2 | 2,6149 | st2 | s1 | 300
  m11332 K4 Held-out Loss Stufe 2 | 2,6258 | st2 | s2 | 300
  m11333 K4 Held-out Loss Stufe 2 | 2,6456 | st2 | s3 | 300
  m11334 K4 d = (st2-st1b)/st1b | +0,35 % | st2 | s1
  m11335 K4 d = (st2-st1b)/st1b | +0,10 % | st2 | s2
  m11336 K4 d = (st2-st1b)/st1b | +0,26 % | st2 | s3
  m11337 Messgeraet Rot (Fenster gemischt) | 8,48 / 8,55 / 8,52 (st1b) ; 8,43 / 8,49 / 8,49 (st2) | Rot
  m11338 Laufzeit Segment 0 (2 Faeden) | 314-316 s (st1b) ; 745-756 s (st2) | Zeit
Ergebnis e677 [2026-11-15 18:20]: erfuellt
  Fazit: Die ganzzahligen Matmuls samt int32-Gradientenpuffer ersetzen den alten Weg ohne messbaren Preis: rundungsmodusfest auf Bausteinebene, Gradienten bis 0,4 % am alten, und über ein Segment Gleichstand in 3/3 (+0,1 bis +0,35 %). Der weitaus größte Rechenanteil des Trainings ist damit nachweislich ganzzahlig. Die Kosten liegen in der Zeit (2,4x langsamer, Matmuls noch seriell), nicht in der Qualität: Parallelisieren lohnt später, ist aber kein Teil des Ziels.
  Offen: Ein Segment, Knirps 96x2, ein Datensatz. Laufzeit nicht optimiert (serielle Ganzzahl-Matmuls).
Chronik:
  2026-11-15 17:38 angelegt
  2026-11-15 17:39 Messwerte m11310-m11315
  2026-11-15 17:39 Status geplant -> laeuft (Messwerte m11310-m11315)
  2026-11-15 18:20 Rezept r722
  2026-11-15 18:20 Messwerte m11328-m11338
  2026-11-15 18:20 Ergebnis e677: erfuellt
  2026-11-15 18:20 Status laeuft -> ausgewertet (Ergebnis e677)
```
