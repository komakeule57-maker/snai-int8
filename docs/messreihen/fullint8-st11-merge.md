# snai/fullint8-st11-merge

```text
snai/fullint8-st11-merge - ausgewertet, angelegt 2026-11-16, zuletzt 2026-11-16 04:47
!! ohne Rezept
Frage: Mittelt die Hauptinstanz mit SNAI_I8_GZ_MERGE=1 (bzw. SNAI_I8_GANZ=11) die SNAI_V8-Checkpoints mehrerer Worker ausschliesslich ganzzahlig (unabhaengig vom Rundungsmodus), so genau wie ein float64-Bezug, ohne dass das Training mit 2 Workern schlechter wird als mit dem alten float-Merge, und bleibt mit Schalter aus alles bytegleich?
Kriterium (festgelegt 2026-11-16 03:47, vor dem ersten Messwert):
  Volltext docs/messreihen/fullint8/KRITERIEN_ST11.txt (md5 7ef68b89). K1 Schalter aus: Kurzlauf 1 Worker GANZ=0..10 = bekannte md5 (0f79d04c ... 201f5494, GANZ=10 759ba426), GANZ=11 = 759ba426; 2 Worker st11 = st10 fuer GANZ=0 und 9; GANZ=11+CKPT=0 = GANZ=9; GANZ=10 Abbruch mit Meldung; GANZ=10+MERGE=1 = GANZ=11; zweimal gleich, 1 Faden = 2 Faeden, MERGEVGL aendert nichts; neue PHP + Stufe-10-Lib laut. K2 merge_probe: merge(A,A)=A, Reihenfolge egal (N=2,3), float64-Bezug Codes >= 99,99 % gleich und <= 1 Code, Skalen <= 1 ulp, float32 >= 99,99 % bitgleich und <= 1 ulp (auch auf jedem Merge von K4 Arm A); ladbar und Rundweg bytegleich, mess_text rc 0; gemischte/abgeschnittene Eingaben laut abgelehnt (Rot: gueltige gelingen); Abstand zum alten float-Merge berichtet. K3 Merge in auf/ab/null = naechster; Rot i/m/f: auf != naechster, Rot naechster != gruen. R2 (tragend) 2 Worker, Segment 0 ganz, s1, 4 Modi: gemittelte V8 bytegleich, rc 0, Bilanz, Merge-Zeile; Rot MERGE_ROT=i auf != naechster. K4: 2 Worker, 2 Segmente, s1-s3 gepaart, A = GANZ=11 (int-Merge), B = GANZ=11+CKPT=0 (V7, alter float-Merge); d=(A-B)/B <= +2 % in 3/3 sonst Haltepunkt, |d|<10 % Gleichstand; Kontrolle Segment 0 bis zum ersten Merge gleich. K5 Messgeraet (rc, Bilanz, NET2NET, Saettigungen, LR-Wache, Merge-Zeilen, Magic A V8/B V7, mess.jsonl, sabotage > 8). Erfuellt = K1-K5 und R2; bei Uneinigkeit saatabhaengig, kein Schluss.
Plan: rechner-a:~/snai_pruef/fullint8/PLAN.md
Baut auf: snai/fullint8-st10-ckpt, snai/fullint8-schluss
Darauf baut: snai/fullint8-st12-gfrei, snai/fullint8-schluss12
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/fullint8/log/st11_k1.log, st11_k23.log, st11_k2_nach.log (zweiter Lauf, merge_probe 86fca4e4; erster Lauf st11_k2_nach_lauf1.log mit Werkzeugfehler); Lib 584489fd
  m11598 K1a Kurzlauf 1 Worker GANZ=0..9 md5 | 0f79d04c/47176fa4/12e40925/6f382e75/ac0be686/8239bb67/39c71b8a/0b208b49/278e3d14/201f5494 (alle wie erwartet) | st11 | s1 | 10
  m11599 K1a Kurzlauf 1 Worker GANZ=10 md5 | 759ba426 | st11 | s1 | 1
  m11600 K1a Kurzlauf 1 Worker GANZ=11 md5 | 759ba426 (= GANZ=10) | st11 | s1 | 1
  m11601 K1b 2 Worker GANZ=0 st11 / st10 | 3eb4a5f8 / 3eb4a5f8 | st11/st10 | s1 | 2
  m11602 K1b 2 Worker GANZ=9 st11 / st10 | 5751c048 / 5751c048 | st11/st10 | s1 | 2
  m11603 K1b 2 Worker GANZ=11+CKPT=0 | 5751c048 (= GANZ=9) | st11 | s1 | 1
  m11604 K1b 2 Worker GANZ=10 | rc=1, Meldung "SNAI_V8-Checkpoints mehrerer Worker lassen sich (noch) nicht mitteln - Abbruch" | st11 | s1 | 1
  m11605 K1b 2 Worker GANZ=10+MERGE=1 | 36fba098 (= GANZ=11) | st11 | s1 | 1
  m11606 K1c 2 Worker GANZ=11 zweimal / 1 Faden / MERGEVGL=1 | 36fba098 / 36fba098 / 36fba098 / 36fba098 | st11 | s1 | 4
  m11607 K1c MERGEVGL im Kurzlauf (echtes Worker-Paar) | Gewichte/m/v 100 % gleich, 0 Code; Skalen <= 1 ulp; float32 1440/1440 | st11 | s1 | 1
  m11608 K1d neue PHP + Stufe-10-Lib 969a56ee, GANZ=10+MERGE=1, 2 Worker | rc=1, dieselbe Abbruchmeldung (laut) | st11L | s1 | 1
  m11609 K2a merge(A,A)=A s1_s0 / s2_s4 / s3_s2 | 6e710462=6e710462 / 1b0574bb=1b0574bb / 4ee24230=4ee24230 | st11 | - | 3
  m11610 K2b merge(A,B)=merge(B,A); N=3 sechs Reihenfolgen | 6011a5b7=6011a5b7; 6x 4d1f4d44 | st11 | - | 8
  m11611 K2c Bezug (s1_s0,s2_s0) | Gewichte/m/v 366048/366048 gleich, 0 Code; Skalen <= 1 ulp (3217/3005/3046 von 3237 bitgleich); float32 1440/1440 | st11 | - | 1
  m11612 K2c Bezug (s1_s3,s1_s4) | Gewichte/m/v 100 % gleich, 0 Code; Skalen <= 1 ulp; float32 100 % | st11 | - | 1
  m11613 K2c Bezug (s2_s4,s3_s4) | Gewichte 100 %, m 366045/366048 (max 1 Code), v 100 %; Skalen <= 1 ulp; float32 100 % | st11 | - | 1
  m11614 K2c Bezug (s1_s0,s2_s0,s3_s0) | Gewichte 100 %, m 366047/366048 (max 1 Code), v 100 %; Skalen <= 1 ulp; float32 100 % | st11 | - | 1
  m11615 K2d Rundweg AB / N3 (geladen, als V8 geschrieben) | 6011a5b7 -> 6011a5b7 / 4d1f4d44 -> 4d1f4d44 | st11 | - | 2
  m11616 K2d mess_text.php auf Merge-Ergebnis | Loss 4,1071 (AB) / 5,1521 (N3, Mittel dreier fremder Saaten), Ausgabe vollstaendig; rc 0 (AB, N3 zweiter Lauf), rc 139 beim Beenden im ersten N3-Lauf = bekannter Beendigungsabsturz ohne -z nodelete (interne Notiz), gegengeprueft: tritt auch mit Lib 96f136e4 und ungemischter Datei auf (je 1-2 von 3 Wiederholungen) | st11 | - | 3
  m11617 K2e gemischt V8+V7 / abgeschnitten / gueltig (Rot) | false "ist kein SNAI_V8-Checkpoint", keine Ausgabe / false "hat 1000000 Bytes, erwartet 1142866", keine Ausgabe / OK rc 0 | st11 | - | 3
  m11618 K2f gegen alten float-Merge (s1_s0,s2_s0) | Gewichte 366046/366048 (max 1), m 100 %, v 100 %, float32 100 %; Skalen <= 1 ulp (81/88/89 % bitgleich) | st11 | - | 1
  m11619 K2f gegen alten float-Merge (s1_s3,s1_s4) | Gewichte 366034/366048 (max 1), m 100 %, v 100 %, float32 100 %; Skalen <= 1 ulp | st11 | - | 1
  m11620 K2f gegen alten float-Merge (s2_s4,s3_s4) | Gewichte 366047/366048, m 100 %, v 366046/366048 (max 1), float32 100 %; Skalen <= 1 ulp | st11 | - | 1
  m11621 K3 Modi auf/ab/null N=2 / N=3 | 6011a5b7 x3 (= naechster) / 4d1f4d44 x3 (= naechster) | st11 | - | 6
  m11622 K3 Rot i naechster/auf/null/ab | ea63cf66 / bc31ca47 / 7372c73e / 88b5e82d (gruen 6011a5b7) | st11 | - | 4
  m11623 K3 Rot m naechster/auf/null/ab | 73ad0344 / a9b3b46b / dde95402 / 4ad2f809 | st11 | - | 4
  m11624 K3 Rot f naechster/auf/null/ab | 42ae6bc8 / 16efd021 / 79d36a28 / 2551e221 | st11 | - | 4
  Quelle: rechner-a:~/snai_pruef/fullint8/log/st11_r2.log, log/R2_*.log, ergebnis/R2_*.snai; st11 Lib 584489fd, probe_iso_basis.sh PROBE_IN=seg0 PROBE_WORKER=2, 2 Faeden je Worker
  m11649 R2 gemittelter Checkpoint naechster | 3f64d3c1 | R2_N | s1 | 1
  m11650 R2 gemittelter Checkpoint null | 3f64d3c1 | R2_Z | s1 | 1
  m11651 R2 gemittelter Checkpoint auf | 3f64d3c1 | R2_U | s1 | 1
  m11652 R2 gemittelter Checkpoint ab | 3f64d3c1 | R2_D | s1 | 1
  m11653 R2 rc / Bilanz / Merge-Zeile / Magic (alle vier) | rc 0 / 5.001 gelaufen (geplant 5.001) / "SNAI_V8 ganzzahlig gemittelt (Stufe 11)" / SNAI_V8 | R2_N,Z,U,D | s1 | 4
  m11654 R2 FPPROBE je Faden | f0/f1 melden den gesetzten Modus (0 / 3072 / 2048 / 1024) | R2_N,Z,U,D | s1 | 4
  m11655 R2 Rot MERGE_ROT=i naechster / auf | 2142369a / 2a984e41 (verschieden; Rot naechster != gruen 3f64d3c1) | R2_In, R2_Iu | s1 | 2
  m11656 R2 Laufzeit Segment (laengster Worker) | 226,7-251,0 ms/Schritt, 9:27-10:27 min, 3 Laeufe parallel | R2 | s1 | 6
  Quelle: rechner-a:~/snai_pruef/fullint8/log/m11a|m11b/gesch_d96h6L2_s{1,2,3}.mess.jsonl und *_s{0,1}.train.log (st11_k4.sh, reihe_gz_w.sh 74610e26, lauf_gz_w.sh 760ca8c6, LAUF_WORKER=2 LAUF_FAEDEN=1, Lib 584489fd)
  m11657 K4 Held-out nach Segment 1 (mess_text 300 Fenster) | 2,5638 | A m11a GANZ=11 | s1 | 1
  m11658 K4 Held-out nach Segment 1 | 2,5649 | A m11a GANZ=11 | s2 | 1
  m11659 K4 Held-out nach Segment 1 | 2,5603 | A m11a GANZ=11 | s3 | 1
  m11660 K4 Held-out nach Segment 1 | 2,5655 | B m11b GANZ=11+CKPT=0 | s1 | 1
  m11661 K4 Held-out nach Segment 1 | 2,5666 | B m11b GANZ=11+CKPT=0 | s2 | 1
  m11662 K4 Held-out nach Segment 1 | 2,5607 | B m11b GANZ=11+CKPT=0 | s3 | 1
  m11663 K4 d = (A-B)/B | -0,066 % | A gegen B | s1 | 1
  m11664 K4 d = (A-B)/B | -0,066 % | A gegen B | s2 | 1
  m11665 K4 d = (A-B)/B | -0,016 % | A gegen B | s3 | 1
  m11666 K4 Held-out nach Segment 0 (nach dem ersten Merge) A / B | 2,8168/2,8168, 2,8198/2,8198, 2,8205/2,8205 (4 Stellen gleich) | A, B | s1-s3 | 6
  m11667 K4 Kontrolle Segment 0 vor dem ersten Merge | Verlustzeilen der Worker in A und B identisch (alle 3 Saaten); Segment 1 verschieden | A, B | s1-s3 | 3
  m11668 K5 rc / Bilanz / Abweichungswarnung | rc 0 alle 12 Segmente; Plan = Ausfuehrung (5.001 bzw. 5.002); 0 | A, B | s1-s3 | 12
  m11669 K5 NET2NET-GUARD / Fatal | 0 / 0 in allen 12 Segmenten | A, B | s1-s3 | 12
  m11670 K5 LR-Wache groesste Abweichung | 126-128 (x 2^-30, Wache bei 2^13), kein Abbruch | A, B | s1-s3 | 12
  m11671 K5 Saettigungen Adam / Restpfad | 0 (teils als verschluckte "0", interne Notiz) | A, B | s1-s3 | 12
  m11672 K5 Merge-Zeilen | A: "SNAI_V8 ganzzahlig gemittelt (Stufe 11)" je Segment; B: "INT8-Tensoren ... verschmolzen" + Warnung "Stufe 11 ... wirkt nur mit Stufe 10 - aus" | A, B | s1-s3 | 12
  m11673 K5 Magic Segmentdateien | A SNAI_V8, B SNAI_V7 | A, B | s1-s3 | 12
  m11674 K5 mess.jsonl Fehlerzeilen / Rot (sabotage 1) | 0 / 8,60 8,60 8,63 (A), 8,64 8,59 8,61 (B) | A, B | s1-s3 | 6
  m11675 K2c float64-Bezug auf den 6 echten Worker-Merges von A | Gewichte 100 % gleich (0 Code); m >= 366047/366048, v >= 366036/366048 (max 1 Code); Skalen <= 1 ulp; float32 1440/1440 | A | s1-s3 | 6
  m11676 Laufzeit Segment (2 Worker a 1 Faden, 12 Prozesse parallel) | 878-894 s | A, B | s1-s3 | 12
Ergebnis e691 [2026-11-16 04:47]: erfuellt
  Fazit: Das Mitteln mehrerer Worker ist kein float-Loch mehr. Mit 2 Workern ist der gemittelte Checkpoint in allen vier Rundungsmodi bytegleich (3f64d3c1), eine eingebaute float-Rechnung faellt in jedem Zweig auf. Gegen den alten float-Merge kostet er nichts: K4 Gleichstand, d -0,066/-0,066/-0,016 %. Gegen den float64-Bezug ist er so genau wie verlangt und genauer als der alte Weg. Der README-Posten "Mitteln mehrerer Worker" ist damit belegt (L der Schlussprobe kann ihn streichen, sobald Stufe 12 durch ist). Wortlaut K2d: ein Messpunkt endete mit rc 139 beim Beenden (bekannter Absturz ohne -z nodelete, interne Notiz, mit alter Lib ebenso), Ausgabe vollstaendig; beide Lesungen in der Ergebnisdatei.
  Offen: Mehr als 2 Worker im Training (N=3 nur im Merge-Werkzeug), ungebundene V8 mit w_out, Karte. Nebenbefund: train_worker.php wertet die Rueckgabe -1 von cortex_train_step_i8 nicht aus (alle FATAL-Wege), siehe snai/fullint8-st12-gfrei.
  Datei: rechner-a:~/snai_pruef/fullint8/ERGEBNIS_ST11.md
Chronik:
  2026-11-16 03:47 angelegt
  2026-11-16 04:10 Messwerte m11598-m11624
  2026-11-16 04:10 Status geplant -> laeuft (Messwerte m11598-m11624)
  2026-11-16 04:13 Messwerte m11649-m11656
  2026-11-16 04:47 Messwerte m11657-m11676
  2026-11-16 04:47 Ergebnis e691: erfuellt
  2026-11-16 04:47 Status laeuft -> ausgewertet (Ergebnis e691)
```
