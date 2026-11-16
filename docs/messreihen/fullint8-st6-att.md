# snai/fullint8-st6-att

```text
snai/fullint8-st6-att - ausgewertet, angelegt 2026-11-15, zuletzt 2026-11-15 19:49
Frage: Rechnen Quantisierung von q/k/v, Scores, Softmax, Attention-Ausgang und Rückwärts (dq, dk, dv) mit SNAI_I8_GZ_ATT=1 ohne Gleitkomma, mindestens so genau wie die alte float32-Fassung (gegen float64 bei gleichem Eingang) und ohne Qualitätsverlust gegen Stufe 5?
Kriterium (festgelegt 2026-11-15 19:31, vor dem ersten Messwert):
  Volltext docs/messreihen/fullint8/KRITERIEN_ST6.txt (md5 242e43f7, vor den gezählten Läufen, nach Zweitmeinung zu Code und Aufbau). K1: Stufe-6-Lib GANZ=0..5 = 0f79d04c/47176fa4/12e40925/6f382e75/ac0be686/8239bb67, GANZ=6+ATT=0 = 8239bb67, GANZ=5+ATT=1 = GANZ=6, Stufe 6 zweimal gleich, 1 = 2 Fäden; GANZ=1+ATT=1 lauffähig, Loss ±2 % von GANZ=6. K2: quant-k/v, att-fwd, att-prob, att-bw-dq/dk/dv je Schicht und alle älteren Zeilen unter FE_UPWARD/FE_TONEAREST bytegleich (Tabelle je Lauf neu); Rot 1 mind. je eine quant-, att-fwd-, att-bw-dq-Zeile ABWEICHEND; Rot 2 (Tabellen ohne festen Modus) mind. eine att-fwd/att-prob-Zeile ABWEICHEND, matfwd/matbw/norm/adam/quant gleich. K3 (Lesart B) bei t=1, 150, 3000: relL2 int gegen float64 <= 1e-6 für att-fwd, dq, dk, dv in beiden Schichten; k/v-Codes = float64-Codes in >= 99,999 %; k/v-Skalen rel. <= 1e-8 zu max/127; float32 nur berichtet; Rot (Referenz +1e-5, Codes aus ×(1+1e-3)) jede att-Zeile > 1e-6 und Codezählung < 99,999 %; Rot Skala (KERN_ROT=1) > 1e-8. K3b: relL2 <= 0,05, cos >= 0,995 gegen alten float32-Pfad; Rot g_w_o[0]. K4: Segment 0, s1-s3 gepaart, d = (st6-st5)/st5 <= +2 % in 3/3, sonst Haltepunkt. K5: Sättigungen, NET2NET-GUARD, STEPS_DONE=5001. Urteil erfüllt = K1-K5.
Plan: rechner-a:~/snai_pruef/fullint8/PLAN.md
Baut auf: snai/fullint8-st5-rope
Darauf baut: snai/fullint8-st7-logits
Rezepte:
  r727 [2026-11-15] st6: K4: ./reihe_gz.sh 1 st6:6 (SNAI_I8_GANZ=6 SNAI_I8_REST=sr SNAI_LR_DECAY_STEPS=25000 ./lauf_gz.sh st6 gesch_d96h6L2_s$S 0.001 1 genesis_s$S, 3 parallel à 2 Fäden, nice 15). K1-K3b: ./st6_proben.sh (22 Proben isoliert per probe_iso.sh proj_gz, 2 parallel)
      quelltext: cortex_gz.nim d1118439, cortex.nim 624d543d (patch_gz.py ed29d20f), Lib a3bdc1e0 (proj_gz und st6); Rauchtest T6/T6a0 mit Vorfassung 6d7ac890/1d246159 (ohne Skalenprüfung)
      seed: Saat = Armname gesch_d96h6L2_s1..s3 (gepaart mit st5)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/fullint8/log/st6/, log/st6_proben.log, log/P6_*.log, log/reihe_gz.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: log/st6_proben.log (md5), log/P6_*.log über gzlog.py/k3r.py/k3b.py (Scratchpad), log/st5/ und log/st6/*.mess.jsonl, log/st6/*.train.log
  m11436 K1 md5 Kurzlauf GANZ=0..5, Lib a3bdc1e0 | 0f79d04c / 47176fa4 / 12e40925 / 6f382e75 / ac0be686 / 8239bb67 (= Bezug) | K1 | s1
  m11437 K1 GANZ=6+ATT=0 | 8239bb67 (= Stand 5) | K1 | s1
  m11438 K1 Stufe 6 zweimal, 1 Faden, GANZ=5+ATT=1 | 39c71b8a viermal | K1 | s1
  m11439 K1 grob GANZ=1+ATT=1 | läuft, Loss 5,64272 gegen 5,64457 (GANZ=6) | K1 | s1
  m11440 K2 Bausteinprobe Stufe 6 | je 2 quant-k, quant-v, att-fwd, att-prob, att-bw-dq/dk/dv und alle Zeilen der Stufen 2-5 gleich | K2 | s1
  m11441 K2 Rot 1 (float32 in Skala, Wahrscheinlichkeit, dq) | quant-k/v 2/2, att-fwd 2/2, att-prob 2/2, att-bw-dq 2/2, att-bw-dk 2/2 ABWEICHEND | K2rot | s1
  m11442 K2 Rot 2 (Tabellen ohne festen Modus) | att-fwd 2/2, att-prob 2/2 (und rope) ABWEICHEND; matfwd/matbw/norm/adam/quant gleich | K2rot2 | s1
  m11443 K3 t=1 relL2 int gegen float64 (max) | att-fwd 7,7e-9, dq 1,3e-8, dk 1,4e-8, dv 7,1e-9 (float32: 1,6e-7 / 2,5e-7 / 1,7e-7 / 1,2e-7) | K3 | s1
  m11444 K3 t=150 | att-fwd 5,8e-9, dq 1,1e-8, dk 1,4e-8, dv 7,9e-9 (float32 bis 4,1e-7) | K3 | s1
  m11445 K3 t=3000 (Segment 0) | att-fwd 5,1e-9, dq 2,2e-8, dk 1,4e-8, dv 6,2e-9 (float32 bis 2,9e-7) | K3 | s1
  m11446 K3 Codes und Skalen k/v (t=1, 150, 3000) | 0 von 12288 Codes abweichend je Aufruf (float32 ebenso 0); Skala rel. <= 4,5e-10 | K3 | s1
  m11447 K3 Rot (Referenz +1e-5, Codes ×(1+1e-3)) | jede att-Zeile 1,0e-5; Codes 440-504 von 12288 abweichend (96 %) | K3rot | s1
  m11448 K3 Rot Skala (KERN_ROT=1) | Skala rel. 1,7e-7 bis 1,9e-7 > 1e-8 | K3rot | s1
  m11449 K3b Gradienten gegen alten Pfad (19 Tensoren) | max relL2 0,0043, min cos 0,99999 | K3b | s1
  m11450 K3b Rot (g_w_o[0] +10 %) | relL2 0,100 verfehlt | K3brot | s1
  m11451 K4 Held-out Loss Stufe 6 | 2,6184 | st6 | s1 | 300
  m11452 K4 Held-out Loss Stufe 6 | 2,6254 | st6 | s2 | 300
  m11453 K4 Held-out Loss Stufe 6 | 2,6531 | st6 | s3 | 300
  m11454 K4 d = (st6-st5)/st5 | +0,39 % | st6 | s1
  m11455 K4 d = (st6-st5)/st5 | -0,27 % | st6 | s2
  m11456 K4 d = (st6-st5)/st5 | +0,45 % | st6 | s3
  m11457 Messgeraet Rot (Fenster gemischt) | 8,39 / 8,53 / 8,59 (st6) | Rot
  m11458 K5 Saettigungen, NET2NET-GUARD, STEPS_DONE | 0 in 15 Berichten, 0 Wächterzeilen, 5001 in allen drei Läufen | K5
  m11459 Laufzeit Segment 0 (2 Faeden) | 982-988 s (st6), Rechnerlast ~7-8 | Zeit
Ergebnis e684 [2026-11-15 19:49]: erfuellt
  Fazit: Die Attention ist ganzzahlig: Quantisierung von q, k und v, Softmax über eine 2^-x-Tabelle und der Rückwärts mit festem Raster je Tensor. Sie hängt nicht vom Rundungsmodus ab und liegt bei gleichem Eingang 10- bis 30-mal näher an float64 als der alte float32-Weg. Über ein Segment ist sie gleichauf (3/3). Die Sorge aus dem Plan, eine quantisierte Softmax verzerre kleine Wahrscheinlichkeiten (Pandey 2023, arXiv:2309.01729), trifft hier nicht zu, weil die Wahrscheinlichkeiten in Q30 statt uint8/16 gehalten werden. Nächste Stufen: Logits/Kreuzentropie (7) und Restpfad/SiLU/Embedding (8).
  Offen: Ein Segment, Knirps 96x2, ein Datensatz, CPU. Bei act > 256 sinkt die Kopfreserve (Bm = 61-7-bits(act)); für ctx 512 und mehr nicht geprüft. Schlussprüfung steht aus.
  Datei: docs/messreihen/fullint8/KRITERIEN_ST6.txt
Chronik:
  2026-11-15 19:31 angelegt
  2026-11-15 19:31 Rezept r727 (st6)
  2026-11-15 19:31 Status geplant -> laeuft (Rezept r727)
  2026-11-15 19:49 Messwerte m11436-m11459
  2026-11-15 19:49 Ergebnis e684: erfuellt
  2026-11-15 19:49 Status laeuft -> ausgewertet (Ergebnis e684)
```
