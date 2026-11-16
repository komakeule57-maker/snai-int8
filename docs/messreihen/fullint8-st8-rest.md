# snai/fullint8-st8-rest

```text
snai/fullint8-st8-rest - ausgewertet, angelegt 2026-11-15, zuletzt 2026-11-15 20:32
Frage: Rechnen Rest-Addition, Embedding vorwaerts/rueckwaerts (Lookup-Anteil) und SiLU vorwaerts (samt int8-Historie von u und s) und rueckwaerts mit SNAI_I8_GZ_REST=1 ohne Gleitkomma, mindestens so genau wie die alte float32-Fassung (gegen float64 bei gleichem Eingang) und ohne Qualitaetsverlust gegen Stufe 7?
Kriterium (festgelegt 2026-11-15 20:05, vor dem ersten Messwert):
  Volltext docs/messreihen/fullint8/KRITERIEN_ST8.txt (md5 c6839387). K1 Kurzlauf isoliert, 2 Faeden: GANZ=0..7 = 0f79d04c/47176fa4/12e40925/6f382e75/ac0be686/8239bb67/39c71b8a/0b208b49; GANZ=8+REST=0 = 0b208b49; GANZ=7+REST=1 = GANZ=8; zweimal gleich; 1 Faden = 2 Faeden; grob GANZ=1+REST=1 und GANZ=8+ADAM=0 laufen, Loss +-2 % von GANZ=8. K2 SNAI_GZ_KERN=1: rest-add, emb-fwd, emb-bw, silu-fwd-u, silu-fwd-s, silu-bw und alle Zeilen Stufen 2-7 unter FE_UPWARD/FE_TONEAREST bytegleich; Rot 1 (KERN_ROT=1): je mind. eine rest-add-, emb-fwd-, emb-bw-, silu-fwd-s-, silu-bw-Zeile ABWEICHEND; Rot 2 (KERN_ROT=2): mind. eine silu-Zeile ABWEICHEND, matfwd/matbw/norm/adam gleich. K3 SNAI_GZ_RESTVGL=t (Lesart B), t=1, 150 (Kurzlauf), 3000 (Segment 0, s1): relL2 int gegen float64 <= 1e-6 fuer rest-add, emb-fwd, emb-bw, silu-bw; u-Codes >= 99,999 % gleich, s-Codes >= 99,99 % gleich; float32 nur berichtet; Rot (RESTVGL_ROT=1), t=1: jede relL2-Zeile > 1e-6, beide Codezaehlungen unter Schwelle. K3b SNAI_GZ_VERGL=1: je Tensor relL2 <= 0,05, cos >= 0,995 (auch g_embeddings); Rot g_w_o[0] verfehlt. K4 Segment 0, s1-s3 gepaart, Held-out 300 Fenster: d=(st8-st7)/st7 <= +2 % in 3 von 3, sonst Haltepunkt; |d| < 10 % Gleichstand. K5 Saettigungen Adam und Restpfad, NET2NET-GUARD, STEPS_DONE=5001. Urteil erfuellt = K1-K5; bei Uneinigkeit saatabhaengig, kein Schluss.
Plan: rechner-a:~/snai_pruef/fullint8/PLAN.md
Baut auf: snai/fullint8-st7-logits
Darauf baut: snai/fullint8-st9-lrplan
Rezepte:
  r729 [2026-11-15] cd ~/snai_pruef/fullint8 && ./st8_proben.sh   (K1-K3b, 24 Proben isoliert per probe_iso.sh proj_gz, 2 parallel); K4: ./reihe_gz.sh 1 st8:8
      quelltext: gz/cortex_gz.nim 4aabb927 (= st8/cortex_gz.nim), cortex.nim 624d543d (Hauptbaum 1a8edde + patch_s0.py + patch_gz.py ed29d20f), Lib 8652dd66 (bau8); st8_proben.sh 7f5525c1; KRITERIEN_ST8.txt c6839387
      parameter: Knirps 96x2, REST=sr, Cosinus 25.000, Warmup 500, lr 0.001, Segment 0 (5.001 Schritte), CPU 2 Faeden, nice 15
      seed: s1-s3 (Armname gesch_d96h6L2_s1..3, gepaart mit st7)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/fullint8/log/st8_proben.log, log/P8_*.log, log/st8/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/fullint8/log/st8_proben.log, st8b_proben.log, P8_*.log, P8b_*.log (gzlog.py, k3r.py, k3b.py mit korrigiertem Muster), log/st8/*.mess.jsonl, *_s0.train.log
  m11488 K1 GANZ=0..7 md5 (Lib 8652dd66) | 0f79d04c/47176fa4/12e40925/6f382e75/ac0be686/8239bb67/39c71b8a/0b208b49 = Bezug | st8 |  | 8
  m11489 K1 GANZ=8 md5, 2/2/1 Faeden | 278e3d14 dreimal | st8 |  | 3
  m11490 K1 GANZ=8+REST=0 / GANZ=7+REST=1 | 0b208b49 (= Stufe 7) / 278e3d14 (= GANZ=8) | st8 |  | 2
  m11491 K1 grob GANZ=1+REST=1 / GANZ=8+ADAM=0 Loss | 5,64523 (+0,03 %) / 5,64405 (+0,01 %) gegen GANZ=8 5,64347 | st8 |  | 2
  m11492 K2 Bausteinprobe abweichende Zeilen | 0 von 109 (Lib 8652dd66 und cfdab036) | st8 |  | 2
  m11493 K2 Rot 1 | rest-add 4/4, emb-fwd, emb-bw, silu-fwd-s 2/2, silu-bw 2/2 ABWEICHEND | st8 |  | 1
  m11494 K2 Rot 2 erste Sonde (Tabelle nicht je Lauf neu) | silu-Zeilen gleich: Sonde blind fuer die Tabelle | st8 |  | 1
  m11495 K2 Rot 2 reparierte Sonde (Lib cfdab036) | silu-fwd-s 2/2, silu-bw 2/2 ABWEICHEND; matfwd/matbw/norm/adam/emb/rest gleich | st8 |  | 1
  m11496 K2 Lib cfdab036 Kontrolle GANZ=8 / GANZ=0 / Rot 1 | 278e3d14 / 0f79d04c / alle Stufe-8-Zeilen ABWEICHEND | st8 |  | 3
  m11497 K3 t=1 relL2 int (f32) | rest-add 3,3e-9 (3,7e-8), emb-fwd 5,2e-10 (2,5e-8), emb-bw 6,2e-9 (6,8e-8), silu-bw 1,9e-9 (4,7e-8), silu-fwd-s 1,8e-9 (5,8e-8) | st8 |  | 1
  m11498 K3 t=150 relL2 int (f32) | rest-add 2,5e-9 (3,7e-8), emb-fwd 5,3e-10 (2,5e-8), emb-bw 5,6e-9 (4,9e-8), silu-bw 2,1e-9 (4,7e-8), silu-fwd-s 1,8e-9 (6,4e-8) | st8 |  | 1
  m11499 K3 t=3000 relL2 int (f32) | rest-add 3,4e-9 (3,7e-8), emb-fwd 7,3e-10 (2,4e-8), emb-bw 3,2e-9 (4,4e-8), silu-bw 3,8e-9 (4,6e-8), silu-fwd-s 3,8e-9 (bis 2,7e-4) | st8 | s1 | 1
  m11500 K3 SiLU-Codes t=1/150/3000 | u 0, s 0 von 49152 abweichend je Aufruf (float32: u 0, s bis 2) | st8 |  | 3
  m11501 K3 Rot (Referenz +1e-5, Codes x(1+1e-3)) | jede relL2-Zeile 1,0e-5; u 1535/1580, s 3548/3076 von 49152 abweichend | st8 |  | 1
  m11502 K3b Gradienten gegen float32-Pfad | 19 Tensoren, max relL2 0,0050, min cos 0,99999, g_embeddings 0,0016 | st8 |  | 1
  m11503 K3b Rot g_w_o[0] relL2 | 0,1001 (verfehlt wie verlangt) | st8 |  | 1
  m11504 K4 Held-out st8 (st7), d | 2,6214 (2,6013), +0,77 % | st8 | s1 | 300
  m11505 K4 Held-out st8 (st7), d | 2,6188 (2,6177), +0,04 % | st8 | s2 | 300
  m11506 K4 Held-out st8 (st7), d | 2,6480 (2,6449), +0,12 % | st8 | s3 | 300
  m11507 K5 STEPS_DONE / NET2NET-GUARD / Saettigungen Adam / Restpfad | 5001 / 0 / 0 in 15 Berichten / 0 in 15 Berichten | st8 |  | 3
  m11508 K5 Trainings-Loss Schritt 5000 | 3,0389 / 3,0286 / 3,0427 | st8 |  | 3
  m11509 Laufzeit Segment 0 | 1028-1033 s (unter Last) | st8 |  | 3
Ergebnis e686 [2026-11-15 20:32]: erfuellt
  Fazit: Restpfad, Embedding (vorwaerts und Lookup-Gradient) und SiLU rechnen ganzzahlig. Bei gleichem Eingang liegen sie 10- bis 50-mal naeher an float64 als der alte float32-Weg. Die int8-Codes von u und s treffen die exakte Rechnung in jedem Fall, der alte Weg kippt vereinzelt s-Codes. Qualitaet: Gleichstand. Alle drei Saaten liegen diesmal leicht ueber Stufe 7 (s1 +0,77 %), weit unter der Haltegrenze. Ob sich ueber die Stufen ein kleiner Nachteil aufbaut, entscheidet erst der Schlusslauf gegen PyTorch; aus einem Segment folgt dazu nichts. Damit sind alle Rechenbausteine des Trainingsschritts ganzzahlig. Offen fuer die README-Liste sind noch Lernratenplan (Stufe 9) und Checkpoint-Format (Stufe 10). Zwei Sondenfehler gefunden und behoben, Urteil unberuehrt: Die SiLU-Bausteinprobe baute die 2^-x-Tabelle nicht je Lauf neu, deshalb war Rot 2 zunaechst gruen; repariert wie bei Stufe 6, Normalweg unveraendert (Lib cfdab036: Kurzlauf 278e3d14 wie 8652dd66). Das Auswerteskript k3b.py uebersah Tensoren, deren Logzeilen ohne Leerzeichen ankamen; mit korrigiertem Muster sind es in allen Stufen 19, kein Urteil aendert sich (Stufe 7: m11475 durch m11487 abgeloest).
  Offen: Aus-Pruefung der Lib cfdab036 ueber Segment 0 (U_neu8, erwartet 7063ce99) vor der Uebernahme. Saettigungszweig der SiLU-Ableitung (|x| um 2^31) ist nie durchlaufen, also ungeprueft ausser durch Durchsicht. Qualitaet ueber 25.000 Schritte erst in den Schlusslaeufen.
  Datei: docs/messreihen/fullint8/KRITERIEN_ST8.txt
Chronik:
  2026-11-15 20:05 angelegt
  2026-11-15 20:06 Rezept r729
  2026-11-15 20:06 Status geplant -> laeuft (Rezept r729)
  2026-11-15 20:32 Messwerte m11488-m11509
  2026-11-15 20:32 Ergebnis e686: erfuellt
  2026-11-15 20:32 Status laeuft -> ausgewertet (Ergebnis e686)
```
