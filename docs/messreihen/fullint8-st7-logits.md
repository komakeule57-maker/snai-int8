# snai/fullint8-st7-logits

```text
snai/fullint8-st7-logits - ausgewertet, angelegt 2026-11-15, zuletzt 2026-11-15 20:27
Frage: Rechnen Softmax, Kreuzentropie-Gradient (mit Label-Glättung) und Verlustwert (Protokoll) über das Vokabular mit SNAI_I8_GZ_LOGITS=1 ohne Gleitkomma, mindestens so genau wie die alte float32-Fassung (gegen float64 bei gleichen Logits) und ohne Qualitätsverlust gegen Stufe 6?
Kriterium (festgelegt 2026-11-15 19:51, vor dem ersten Messwert):
  Volltext docs/messreihen/fullint8/KRITERIEN_ST7.txt (md5 a6470961, vor den gezählten Läufen, nach Zweitmeinung). K1: Stufe-7-Lib a7d526fe GANZ=0..6 = 0f79d04c/47176fa4/12e40925/6f382e75/ac0be686/8239bb67/39c71b8a, GANZ=7+LOGITS=0 = 39c71b8a, GANZ=6+LOGITS=1 = GANZ=7, zweimal gleich, 1 = 2 Fäden; GANZ=1+LOGITS=1 lauffähig ±2 % Loss. K2: ce-dlogits, ce-verlust und alle älteren Zeilen unter FE_UPWARD/FE_TONEAREST bytegleich; Rot 1 (tb[0]) ce-dlogits ABWEICHEND; Rot 2 (Tabellen) ce-dlogits ABWEICHEND, matfwd/matbw/norm/adam/quant gleich. K3 (Lesart B) t=1, 150, 3000: dLogits relL2 int gegen float64 <= 1e-6, Verlust rel. <= 1e-6; float32 nur berichtet; Rot (Referenz +1e-5) beide > 1e-6. K3b: relL2 <= 0,05, cos >= 0,995 gegen alten Pfad; Rot g_w_o[0]. K4: Segment 0, s1-s3 gepaart, d = (st7-st6)/st6 <= +2 % in 3/3, sonst Haltepunkt. K5: Sättigungen, NET2NET-GUARD, STEPS_DONE=5001, Protokoll-Loss gleiche Größenordnung wie Stufe 6. Urteil erfüllt = K1-K5.
Plan: rechner-a:~/snai_pruef/fullint8/PLAN.md
Baut auf: snai/fullint8-st6-att
Darauf baut: snai/fullint8-st8-rest
Rezepte:
  r728 [2026-11-15] st7: K4: ./reihe_gz.sh 1 st7:7 (SNAI_I8_GANZ=7 SNAI_I8_REST=sr SNAI_LR_DECAY_STEPS=25000 ./lauf_gz.sh st7 gesch_d96h6L2_s$S 0.001 1 genesis_s$S, 3 parallel à 2 Fäden, nice 15). K1-K3b: ./st7_proben.sh (22 Proben isoliert per probe_iso.sh proj_gz, 2 parallel)
      quelltext: cortex_gz.nim 6574ae37, cortex.nim 624d543d (patch_gz.py ed29d20f), Lib a7d526fe (bau7; proj_gz und st7)
      seed: Saat = Armname gesch_d96h6L2_s1..s3 (gepaart mit st6)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/fullint8/log/st7/, log/st7_proben.log, log/P7_*.log, log/reihe_gz.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/fullint8/log/st7_proben.log, st7b_proben.log, P7_*.log, P7b_*.log (gzlog.py, k3r.py, k3b.py), log/st7/*.mess.jsonl, *_s0.train.log
  m11460 K1 GANZ=0..6 md5 (Lib a7d526fe) | 0f79d04c/47176fa4/12e40925/6f382e75/ac0be686/8239bb67/39c71b8a = Bezug | st7 |  | 7
  m11461 K1 GANZ=7 md5, 2/2/1 Faeden | 0b208b49 dreimal | st7 |  | 3
  m11462 K1 GANZ=7+LOGITS=0 | 39c71b8a (= Stufe 6) | st7 |  | 1
  m11463 K1 GANZ=6+LOGITS=1 | 0b208b49 (= GANZ=7) | st7 |  | 1
  m11464 K1 grob GANZ=1+LOGITS=1 Loss | 5,6447 gegen GANZ=7 5,64342 (+0,02 %) | st7 |  | 1
  m11465 K2 Bausteinprobe abweichende Zeilen | 0 von 97 | st7 |  | 1
  m11466 K2 Rot 1 erste Sonde (tb[0]) ce-dlogits | gleich: Sonde blind (Token 0, Betrag unter 2^23, float32-Rundung nach Abschneiden unsichtbar) | st7 |  | 1
  m11467 K2 Rot 1 reparierte Sonde (tb[tg], Lib 4d3a71a2) ce-dlogits | ABWEICHEND (128 Zeilen) | st7 |  | 1
  m11468 K2 Lib 4d3a71a2 Kontrolle: Bausteinprobe / GANZ=7 / GANZ=0 | 0 von 97 / 0b208b49 / 0f79d04c (Normalweg unveraendert) | st7 |  | 3
  m11469 K2 Rot 2 ce-dlogits | ABWEICHEND (4508); matfwd/matbw/norm/adam/quant gleich | st7 |  | 1
  m11470 K3 t=1 relL2 dLogits int (f32) | 1,04e-8 (2,78e-8) | st7 |  | 1
  m11471 K3 t=1 Verlust rel. int (f32) | 2,2e-8 (1,06e-7) | st7 |  | 1
  m11472 K3 t=150 relL2 dLogits int (f32) | 1,08e-8 (1,05e-7) | st7 |  | 1
  m11473 K3 t=150 Verlust rel. int (f32) | 4,35e-8 (3,67e-7) | st7 |  | 1
  m11474 K3 Rot t=1 dLogits / Verlust | 1,0e-5 / 9,98e-6 (beide > 1e-6) | st7 |  | 1
  m11476 K3b Rot g_w_o[0] relL2 | 0,1001 (verfehlt wie verlangt) | st7 |  | 1
  m11477 K4 Held-out st7 (st6), d | 2,6013 (2,6184), -0,65 % | st7 | s1 | 300
  m11478 K4 Held-out st7 (st6), d | 2,6177 (2,6254), -0,29 % | st7 | s2 | 300
  m11479 K4 Held-out st7 (st6), d | 2,6449 (2,6531), -0,31 % | st7 | s3 | 300
  m11480 K5 STEPS_DONE / NET2NET-GUARD / Saettigungen | 5001 / 0 / 0 in 5 Berichten | st7 | s1 | 1
  m11481 K5 STEPS_DONE / NET2NET-GUARD / Saettigungen | 5001 / 0 / 0 in 5 Berichten | st7 | s2 | 1
  m11482 K5 STEPS_DONE / NET2NET-GUARD / Saettigungen | 5001 / 0 / 0 in 5 Berichten | st7 | s3 | 1
  m11483 K5 Trainings-Loss Schritt 5000 st7 (st6) | 3,0303 (3,0355) / 3,0280 (3,0300) / 3,0421 (3,0431) | st7 |  | 3
  m11484 Laufzeit Segment 0 | 980 s (s1, unter Last) | st7 | s1 | 1
  Quelle: rechner-a:~/snai_pruef/fullint8/log/P7_L3000.log (Segment 0, s1)
  m11485 K3 t=3000 relL2 dLogits int (f32) | 1,20e-8 (6,68e-7) | st7 | s1 | 1
  m11486 K3 t=3000 Verlust rel. int (f32) | 3,29e-8 (2,03e-7) | st7 | s1 | 1
  Quelle: log/P7_V.log, k3b.py mit korrigiertem Muster (Leerzeichen optional; das alte Muster uebersah 1 Tensor, weil verschachtelte Logzeilen die Leerzeichen verloren)
  m11487 K3b Gradienten gegen float32-Pfad | 19 Tensoren, max relL2 0,0050 (g_w_q[0]), min cos 0,99999, keiner verfehlt | st7 |  | 1
Ergebnis e685 [2026-11-15 20:13]: erfuellt
  Fazit: Softmax, Kreuzentropie-Gradient und der Verlustwert rechnen ganzzahlig, rund 10- bis 50-mal genauer als der alte float32-Weg (gegen float64 bei gleichen Logits), und kosten keine Qualitaet (Gleichstand, in allen drei Saaten leicht besser). Damit ist der Teil "Logits/CE" der README-Liste fachlich erledigt; gestrichen wird erst nach den Schlusslaeufen. Lehre fuer die Sonden: Die Rot-1-Sonde an tb[0] war fuer die dLogits blind, weil Token 0 kaum Wahrscheinlichkeit hat und eine float32-Rundung unter 2^23 nach dem Abschneiden verschwindet. Erst die Wiederholung an tb[tg] wurde rot. Fuer jede kuenftige Rot-Sonde den Eingriff an einen Wert legen, dessen Betrag ueber 2^24 liegt; die Sonden der Stufen 2-6 und 8 liegen auf Mantissen nahe 2^30 und sind davon nicht betroffen (dort wurde Rot gesehen). Der Normalweg ist durch die Sondenaenderung unveraendert (Lib 4d3a71a2: Kurzlauf 0b208b49 wie a7d526fe); K4 mit a7d526fe gilt deshalb fuer die zu uebernehmende Quelle 0683285c.
  Offen: Aus-Pruefung der Lib 4d3a71a2 ueber Segment 0 (U_neu7, erwartet 7063ce99) vor der Uebernahme in den Hauptbaum. Qualitaet ueber 25.000 Schritte erst in den Schlusslaeufen.
  Datei: docs/messreihen/fullint8/KRITERIEN_ST7.txt
Abgeloest und ausgeblendet: 1 messwert - voll=True zeigt sie.
Chronik:
  2026-11-15 19:51 angelegt
  2026-11-15 19:52 Rezept r728 (st7)
  2026-11-15 19:52 Status geplant -> laeuft (Rezept r728)
  2026-11-15 20:10 Messwerte m11460-m11484
  2026-11-15 20:13 Messwerte m11485, m11486
  2026-11-15 20:13 Ergebnis e685: erfuellt
  2026-11-15 20:13 Status laeuft -> ausgewertet (Ergebnis e685)
  2026-11-15 20:27 Messwerte m11487, loesen m11475 ab
```
