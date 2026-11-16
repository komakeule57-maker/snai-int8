# snai/fullint8-st4-norm

```text
snai/fullint8-st4-norm - ausgewertet, angelegt 2026-11-15, zuletzt 2026-11-15 19:13
Frage: Rechnen RMSNorm vorwärts, rückwärts (dx) und der Gradient der Norm-Gains (SNAI_I8_GANZ=4) ohne Gleitkomma, mindestens so genau wie die alte float32-Fassung (gegen float64 bei gleichem Eingang) und ohne Qualitätsverlust gegen Stufe 3?
Kriterium (festgelegt 2026-11-15 18:57, vor dem ersten Messwert):
  Volltext docs/messreihen/fullint8/KRITERIEN_ST4.txt (md5 d3110301, vor den gezählten Läufen, nach Zweitmeinung). K1: Lib 60164549, Kurzlauf Stufe 0/1/2/3 = 0f79d04c/47176fa4/12e40925/6f382e75 (dann gilt st3 als Vergleichsarm), Stufe 4 zweimal gleich, 1 Faden = 2 Fäden. K2: Bausteinprobe unter FE_UPWARD und FE_TONEAREST, alle normfwd/normbw-dx/normbw-gain-Aufrufe und alle Zeilen der Stufen 2-3 bytegleich; Rot (float32-Multiplikation): mind. eine normfwd- und eine normbw-dx-Zeile ABWEICHEND. K3 (Lesart B, Autor 15.11.): relL2 Ganzzahl gegen float64 bei gleichem Eingang <= 1e-6 für fwd, bw-dx, bw-gain in allen 5 Norm-Aufrufen bei t = 1, 150 (Kurzlauf), 3000 (Segment 0, s1); float32 nur berichtet; Rot (Referenz um 1e-5 verschoben): jede Ganzzahl-Zeile > 1e-6. K3b: Gradienten gegen alten float32-Pfad, je Tensor relL2 <= 0,05 und cos >= 0,995 (Plausibilität); Rot g_w_o[0] +10 %. K4: Segment 0, s1-s3 gepaart, Held-out 300 Fenster, d = (st4-st3)/st3 <= +2 % in 3 von 3, sonst Haltepunkt; |d| < 10 % ist Gleichstand. K5: Sättigungen, NET2NET-GUARD, STEPS_DONE=5001 vor dem Urteil ansehen. Urteil erfüllt = K1-K5.
Plan: rechner-a:~/snai_pruef/fullint8/PLAN.md
Baut auf: snai/fullint8-st3-adam
Darauf baut: snai/fullint8-schalter, snai/fullint8-st5-rope
Rezepte:
  r724 [2026-11-15] st4: K4: ./reihe_gz.sh 1 st4:4 (je Saat: SNAI_I8_GANZ=4 SNAI_I8_REST=sr SNAI_LR_DECAY_STEPS=25000 ./lauf_gz.sh st4 gesch_d96h6L2_s$S 0.001 1 factory/checkpoints/gesch_gen_d96h6L2_s$S.snai, 3 parallel à 2 Fäden, nice 15). K1-K3b: ./st4_proben.sh (15 Proben isoliert per probe_iso.sh proj_gz <name> - <faeden>, 2 parallel)
      quelltext: cortex_gz.nim f170ab44, cortex.nim baf84b26 (= Hauptbaum c750d11), Lib 60164549 (proj_gz und st4), st4_proben.sh, probe_iso.sh
      seed: Saat = Armname gesch_d96h6L2_s1..s3 (gepaart mit st3)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/fullint8/log/st4/, log/st4_s*.out, log/st4_proben.log, log/J*.log, log/reihe_gz.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: log/st4_proben.log (md5), log/J4*.log über gzlog.py/k3n.py (Scratchpad), log/st3/ und log/st4/gesch_d96h6L2_sN.mess.jsonl, log/st4/*.train.log
  m11379 K1 md5 Kurzlauf Stufe 0/1/2/3, Lib 60164549 | 0f79d04c / 47176fa4 / 12e40925 / 6f382e75 (= Bezug) | K1 | s1
  m11380 K1 Stufe 4 zweimal und mit 1 Faden | ac0be686 dreimal | K1 | s1
  m11381 K2 Bausteinprobe Stufe 4 | 5 normfwd, 5 normbw-dx, 5 normbw-gain, 13 matfwd, 13 matbw-din, 13 matbw-grad, 19 adam: alle gleich | K2 | s1
  m11382 K2 Rot (float32-Mult.) | 5 von 5 normfwd, 5 von 5 normbw-dx ABWEICHEND (normbw-gain gleich, die Rot-Stelle liegt im dx-Teil) | K2rot | s1
  m11383 K3 t=1 relL2 int gegen float64 (max über 5 Aufrufe) | fwd 3,3e-8, bw-dx 3,3e-8, bw-gain 3,8e-8 (float32: 7,9e-8 / 9,0e-8 / 2,6e-7) | K3 | s1
  m11384 K3 t=150 | fwd 2,7e-8, bw-dx 3,7e-8, bw-gain 3,0e-8 (float32: 8,6e-8 / 1,4e-7 / 2,4e-7) | K3 | s1
  m11385 K3 t=3000 (Segment 0) | fwd 3,0e-8, bw-dx 3,8e-8, bw-gain 3,9e-8 (float32: 9,4e-8 / 1,2e-7 / 2,9e-7) | K3 | s1
  m11386 K3 Rot t=1 (Referenz +1e-5) | jede Ganzzahl-Zeile 1,0e-5 bis 1,03e-5 | K3rot | s1
  m11387 K3b Gradienten gegen alten Pfad (19 Tensoren) | max relL2 0,0043 (g_w_down[1]), min cos 0,99999; Gains relL2 <= 0,0027 | K3b | s1
  m11388 K3b Rot (g_w_o[0] +10 %) | g_w_o[0] relL2 0,100 verfehlt | K3brot | s1
  m11389 K4 Held-out Loss Stufe 4 | 2,6123 | st4 | s1 | 300
  m11390 K4 Held-out Loss Stufe 4 | 2,6352 | st4 | s2 | 300
  m11391 K4 Held-out Loss Stufe 4 | 2,6472 | st4 | s3 | 300
  m11392 K4 d = (st4-st3)/st3 | -0,21 % | st4 | s1
  m11393 K4 d = (st4-st3)/st3 | +0,37 % | st4 | s2
  m11394 K4 d = (st4-st3)/st3 | +0,20 % | st4 | s3
  m11395 Messgeraet Rot (Fenster gemischt) | 8,44 / 8,52 / 8,50 (st4) | Rot
  m11396 K5 Saettigungen, NET2NET-GUARD, STEPS_DONE | 0 in 15 Berichten, 0 Wächterzeilen, 5001 in allen drei Läufen | K5
  m11397 Laufzeit Segment 0 (2 Faeden) | 863-870 s (st4) gegen 887-894 s (st3), andere Rechnerlast | Zeit
Ergebnis e682 [2026-11-15 19:13]: erfuellt
  Fazit: RMSNorm vorwärts und rückwärts sowie der Gradient der Norm-Gains sind ganzzahlig. Sie hängen nicht vom Rundungsmodus ab und liegen bei gleichem Eingang 2- bis 7-mal näher an float64 als die alte float32-Fassung. Über ein Segment kosten sie nichts (Gleichstand 3/3). Damit fällt ein weiterer float-Kleber weg: Der Adam der Gains liest jetzt ganzzahlige Gradienten. Der Bezug gegen float64 bei gleichem Eingang (Lesart B) trägt hier ohne Sonderfall; der alte Pfad dient nur noch als Plausibilität (K3b). Nächste Stufe ist RoPE (5).
  Offen: Ein Segment, Knirps 96x2, ein Datensatz, CPU. Die Rot-Probe in K2 trifft normbw-gain nicht, weil die Rot-Stelle im dx-Teil liegt; der Gain-Teil ist über K3 (bw-gain gegen float64 und dessen Rot) abgedeckt. Schlussprüfung (gesamt und je Stufe einzeln) steht aus.
  Datei: docs/messreihen/fullint8/KRITERIEN_ST4.txt
Chronik:
  2026-11-15 18:57 angelegt
  2026-11-15 18:57 Rezept r724 (st4)
  2026-11-15 18:57 Status geplant -> laeuft (Rezept r724)
  2026-11-15 19:13 Messwerte m11379-m11397
  2026-11-15 19:13 Ergebnis e682: erfuellt
  2026-11-15 19:13 Status laeuft -> ausgewertet (Ergebnis e682)
```
