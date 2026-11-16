# snai/fullint8-st1-geruest

```text
snai/fullint8-st1-geruest - ausgewertet, angelegt 2026-11-15, zuletzt 2026-11-15 18:20
Frage: Rechnet das GZ-Gerüst (SNAI_I8_GANZ=1: eigener Vorwärts/Rückwärts in cortex_gz.nim, jeder Baustein in float-Referenz = Rechnung des alten Pfads) dieselben Gradienten und dieselbe Qualität wie der alte gebündelte CPU-Pfad? Stufe 1 des Full-int8-Umbaus.
Kriterium (festgelegt 2026-11-15 17:30, vor dem ersten Messwert):
  Volltext docs/messreihen/fullint8/KRITERIEN_ST1.txt (28ab3119), vor dem ersten gezählten Lauf. K1: SNAI_I8_GANZ=0 mit der GZ-Lib bytegleich zur Basis (Kurzlauf, md5 0f79d04c). K2: erster Schritt (Genesis s1, kurz_seg0) je Tensor relL2 <= 0,05 und Kosinus >= 0,995 gegen den alten Pfad. Rot-Probe: g_w_o[0] +10 % muss mit relL2 >= 0,09 erscheinen. K3: Segment 0 (5.001 Schritte), Saaten s1-s3 gepaart, Held-out 300 Fenster, d = (GZ1-alt)/alt <= +2 % in 3/3, sonst Haltepunkt. Urteil erfuellt = K1-K3.
Plan: rechner-a:~/snai_pruef/fullint8/PLAN.md
Baut auf: snai/fullint8-s0-probe
Darauf baut: snai/fullint8-st2-matmul
Rezepte:
  r721 [2026-11-15] K1: cd ~/snai_pruef/fullint8 && ./probe_s0.sh proj_gz K1 - 2 ; K2: SNAI_I8_GANZ=1 SNAI_GZ_VERGL=1 [SNAI_GZ_VERGL_ROT=1] ./probe_s0.sh proj_gz K2[rot] - 2 ; K3: setsid nohup ./reihe_gz.sh 1 st0:0 st1:1
      quelltext: proj_gz/st0/st1 = Hauptbaum 1a8edde + patch_s0.py (80fee343) + patch_gz.py (5acb7976) + cortex_gz.nim (7abe83a9); cortex.nim efb1e7aa; libcortex.so b990e8fa; lauf_gz.sh a06fa6c6; reihe_gz.sh b7d052f9; Rezept REST=sr, INT8_FULL, LR 0,001, Cosinus 25.000, Warmup 500, CPU 2 Fäden, Saaten = Genesis gesch_gen_d96h6L2_s1..s3 mit Armname gesch_d96h6L2_sN
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/fullint8/log/ (K2.log, K2rot.log, st0/, st1/, reihe_gz.log)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: probe_s0.sh-Ausgabe, log/K2.log und log/K2rot.log (Zeilen [GZ-VERGL])
  m11305 K1 md5 SNAI_I8_GANZ=0 mit GZ-Lib b990e8fa | 0f79d04c (= Basis) | K1
  m11306 K2 Loss erster Schritt alt / GZ | 7,4693184 / 7,4693184 | K2 | s1
  m11307 K2 größter relL2 | 0,00433 (g_w_down[1]), zweitgrößter 0,00337 (g_w_down[0]), alle übrigen <= 0,00078 | K2 | s1
  m11308 K2 kleinster Kosinus | 0,999991 (g_w_down[1]) | K2 | s1
  m11309 K2 Rot g_w_o[0] +10 % | relL2 0,09999, übrige Tensoren unverändert gegen K2 | K2rot | s1
  Quelle: log/st0/ und log/st1/gesch_d96h6L2_sN.mess.jsonl (Zeile 1 = Held-out s0, Zeile 2 = Rot Fenster gemischt), reihe_gz_174613.log; Querprobe md5 st0 s1 = SR-Nachweis
  m11316 K3 Held-out Loss Stufe 0 | 2,6117 | st0 | s1 | 300
  m11317 K3 Held-out Loss Stufe 0 | 2,6216 | st0 | s2 | 300
  m11318 K3 Held-out Loss Stufe 0 | 2,6565 | st0 | s3 | 300
  m11319 K3 Held-out Loss Stufe 1 | 2,6168 | st1 | s1 | 300
  m11320 K3 Held-out Loss Stufe 1 | 2,6280 | st1 | s2 | 300
  m11321 K3 Held-out Loss Stufe 1 | 2,6327 | st1 | s3 | 300
  m11322 K3 d = (st1-st0)/st0 | +0,20 % | st1 | s1
  m11323 K3 d = (st1-st0)/st0 | +0,24 % | st1 | s2
  m11324 K3 d = (st1-st0)/st0 | -0,90 % | st1 | s3
  m11325 Messgeraet Rot (Fenster gemischt) | 8,40 / 8,46 / 8,51 (st0) ; 8,37 / 8,48 / 8,53 (st1) | Rot
  m11326 Querprobe md5 Checkpoint st0 s1 Segment 0 | ec75ac57 (= SR-Nachweis) | st0 | s1
  m11327 Laufzeit Segment 0 (2 Faeden) | 225-233 s (st0) ; 315-322 s (st1) | Zeit
Ergebnis e676 [2026-11-15 18:20]: erfuellt
  Fazit: Das Gerüst des Ganzzahl-Pfads ist eine treue Kopie des alten CPU-Pfads: gleiche Gradienten im ersten Schritt, und über ein ganzes Segment Gleichstand in 3/3 Saaten (|d| <= 0,9 %, weit unter der 2-%-Halteschwelle). Damit ist jede spätere Abweichung einer Stufe dem jeweils umgebauten Baustein zuzuschreiben, nicht dem Gerüst. Die Querprobe (st0 s1 = Checkpoint des SR-Nachweises) bestätigt, dass Aufbau und Saaten der Reihe dieselben sind wie dort.
  Offen: Nur Knirps 96x2, ein Datensatz, ein Segment. Gerüst kostet ~40 % Laufzeit (kein Kriterium). Die Stufe-1-Lib b990e8fa ist nicht bytegleich zur späteren Lib 4d20c9f3 (Logits durchs GzT-Format) - deshalb nutzt Stufe 2 st1b als Vergleichsarm.
Chronik:
  2026-11-15 17:30 angelegt
  2026-11-15 17:32 Rezept r721
  2026-11-15 17:32 Status geplant -> laeuft (Rezept r721)
  2026-11-15 17:32 Messwerte m11305-m11309
  2026-11-15 18:20 Messwerte m11316-m11327
  2026-11-15 18:20 Ergebnis e676: erfuellt
  2026-11-15 18:20 Status laeuft -> ausgewertet (Ergebnis e676)
```
