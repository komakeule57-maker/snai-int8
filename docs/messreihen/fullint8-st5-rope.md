# snai/fullint8-st5-rope

```text
snai/fullint8-st5-rope - ausgewertet, angelegt 2026-11-15, zuletzt 2026-11-15 19:30
Frage: Rechnet RoPE vorwärts (q, k) und rückwärts (dq, dk) mit SNAI_I8_GZ_ROPE=1 ohne Gleitkomma, mindestens so genau wie die alte float32-Fassung (gegen float64 bei gleichem Eingang) und ohne Qualitätsverlust gegen Stufe 4?
Kriterium (festgelegt 2026-11-15 19:13, vor dem ersten Messwert):
  Volltext docs/messreihen/fullint8/KRITERIEN_ST5.txt (vor den gezählten Läufen, nach Zweitmeinung). K1: Stufe-5-Lib, Kurzlauf GANZ=0..4 = 0f79d04c/47176fa4/12e40925/6f382e75/ac0be686, GANZ=5+ROPE=0 = ac0be686, Stufe 5 zweimal gleich, 1 Faden = 2 Fäden. K2: Bausteinprobe FE_UPWARD/FE_TONEAREST, 4 rope-fwd + 4 rope-bw + alle Zeilen der Stufen 2-4 bytegleich, Q30-Tabelle je Lauf neu gebaut; Rot 1 (float32-Mult. in tb[0]) und Rot 2 (Tabelle ohne festen Modus, float32-theta): je mind. eine rope-fwd- und eine rope-bw-Zeile ABWEICHEND, bei Rot 2 Matmul/Norm/Adam gleich. K3 (Lesart B): relL2 Ganzzahl gegen float64 <= 1e-6 in allen 8 Aufrufen bei t=1, 150 (Kurzlauf), 3000 (Segment 0, s1); float32 nur berichtet; Rot (Referenz +1e-5): jede Ganzzahl-Zeile > 1e-6. K3b: Gradienten gegen alten float32-Pfad relL2 <= 0,05, cos >= 0,995; Rot g_w_o[0] +10 %. K4: Segment 0, s1-s3 gepaart, d = (st5-st4)/st4 <= +2 % in 3/3, sonst Haltepunkt; |d| < 10 % Gleichstand. K5: Sättigungen, NET2NET-GUARD, STEPS_DONE=5001. Urteil erfüllt = K1-K5.
Plan: rechner-a:~/snai_pruef/fullint8/PLAN.md
Baut auf: snai/fullint8-st4-norm, snai/fullint8-schalter
Darauf baut: snai/fullint8-st6-att
Rezepte:
  r726 [2026-11-15] st5: K4: ./reihe_gz.sh 1 st5:5 (SNAI_I8_GANZ=5 SNAI_I8_REST=sr SNAI_LR_DECAY_STEPS=25000 ./lauf_gz.sh st5 gesch_d96h6L2_s$S 0.001 1 genesis_s$S, 3 parallel à 2 Fäden, nice 15). K1-K3b: ./st5_proben.sh (19 Proben isoliert per probe_iso.sh proj_gz, 2 parallel)
      quelltext: cortex_gz.nim 70d4db23, cortex.nim 624d543d (patch_gz.py ed29d20f), Lib 66c0b45f (proj_gz und st5)
      seed: Saat = Armname gesch_d96h6L2_s1..s3 (gepaart mit st4)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/fullint8/log/st5/, log/st5_proben.log, log/P5_*.log, log/reihe_gz.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: log/st5_proben.log (md5), log/P5_*.log über gzlog.py/k3r.py/k3b.py (Scratchpad), log/st4/ und log/st5/*.mess.jsonl, log/st5/*.train.log
  m11415 K1 md5 Kurzlauf GANZ=0..4, Lib 66c0b45f | 0f79d04c / 47176fa4 / 12e40925 / 6f382e75 / ac0be686 (= Bezug) | K1 | s1
  m11416 K1 GANZ=5+ROPE=0 | ac0be686 (= Stand 4) | K1 | s1
  m11417 K1 Stufe 5 zweimal, 1 Faden, GANZ=4+ROPE=1 | 8239bb67 viermal | K1 | s1
  m11418 K2 Bausteinprobe Stufe 5 | 4 rope-fwd, 4 rope-bw und alle 73 Zeilen der Stufen 2-4 gleich | K2 | s1
  m11419 K2 Rot 1 (float32-Mult. tb[0]) | rope-fwd 4/4, rope-bw 4/4 ABWEICHEND | K2rot | s1
  m11420 K2 Rot 2 (Tabelle ohne festen Modus, float32-theta) | rope-fwd 4/4, rope-bw 4/4 ABWEICHEND, matfwd/matbw/norm/adam alle gleich | K2rot2 | s1
  m11421 K3 t=1 relL2 int gegen float64 (max über 4+4 Aufrufe) | fwd 1,2e-9, bw 1,4e-9 (float32: 1,9e-7 / 1,1e-7) | K3 | s1
  m11422 K3 t=150 | fwd 1,3e-9, bw 1,7e-9 (float32: 1,8e-7 / 8,2e-8) | K3 | s1
  m11423 K3 t=3000 (Segment 0) | fwd 1,3e-9, bw 2,0e-9 (float32: 2,1e-7 / 2,3e-7) | K3 | s1
  m11424 K3 Rot t=1 (Referenz +1e-5) | jede Ganzzahl-Zeile 1,0e-5 | K3rot | s1
  m11425 K3b Gradienten gegen alten Pfad (19 Tensoren) | max relL2 0,0043 (g_w_down[1]), min cos 0,99999 | K3b | s1
  m11426 K3b Rot (g_w_o[0] +10 %) | relL2 0,100 verfehlt | K3brot | s1
  m11427 K4 Held-out Loss Stufe 5 | 2,6081 | st5 | s1 | 300
  m11428 K4 Held-out Loss Stufe 5 | 2,6326 | st5 | s2 | 300
  m11429 K4 Held-out Loss Stufe 5 | 2,6411 | st5 | s3 | 300
  m11430 K4 d = (st5-st4)/st4 | -0,16 % | st5 | s1
  m11431 K4 d = (st5-st4)/st4 | -0,10 % | st5 | s2
  m11432 K4 d = (st5-st4)/st4 | -0,23 % | st5 | s3
  m11433 Messgeraet Rot (Fenster gemischt) | 8,41 / 8,52 / 8,50 (st5) | Rot
  m11434 K5 Saettigungen, NET2NET-GUARD, STEPS_DONE | 0 in 15 Berichten, 0 Wächterzeilen, 5001 in allen drei Läufen | K5
  m11435 Laufzeit Segment 0 (2 Faeden) | 932-945 s (st5), Rechner stärker belegt (Proben daneben, Last ~7) | Zeit
Ergebnis e683 [2026-11-15 19:30]: erfuellt
  Fazit: RoPE ist ganzzahlig, hängt nicht vom Rundungsmodus ab (auch der Tabellenbau nicht, Rot 2 zeigt, dass die Probe das sehen kann) und liegt bei gleichem Eingang rund 100-mal näher an float64 als der alte float32-Weg. Über ein Segment kostet die Stufe nichts (Gleichstand 3/3). Damit ist der Weg bis zur Attention bis auf die Quantisierung von k/v ganzzahlig. Nächste Stufe ist die Attention selbst (6), dort sitzen exp und die Division der Softmax.
  Offen: Ein Segment, Knirps 96x2, ein Datensatz, CPU. Laufzeit unter höherer Rechnerlast gemessen, nicht vergleichbar. Schlussprüfung (gesamt und je Stufe einzeln) steht aus.
  Datei: docs/messreihen/fullint8/KRITERIEN_ST5.txt
Chronik:
  2026-11-15 19:13 angelegt
  2026-11-15 19:14 Rezept r726 (st5)
  2026-11-15 19:14 Status geplant -> laeuft (Rezept r726)
  2026-11-15 19:30 Messwerte m11415-m11435
  2026-11-15 19:30 Ergebnis e683: erfuellt
  2026-11-15 19:30 Status laeuft -> ausgewertet (Ergebnis e683)
```
