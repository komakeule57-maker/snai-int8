# snai/fullint8-schluss

```text
snai/fullint8-schluss - ausgewertet, angelegt 2026-11-15, zuletzt 2026-11-16 07:51
Frage: Trainiert die int8-Engine mit SNAI_I8_GANZ=10 (alle Stufen an) vollstaendig ganzzahlig, also unabhaengig vom Rundungsmodus der FPU, und haelt sie dabei die Qualitaet von float32 (PyTorch) innerhalb von 5 %? Schlussprobe des Full-int8-Ziels (ZIEL.md Punkte 1-3).
Kriterium (festgelegt 2026-11-15 21:14, vor dem ersten Messwert):
  Volltext docs/messreihen/fullint8/KRITERIEN_SCHLUSS.txt (md5 87e1d8bb, nach Zweitmeinung). Kopien sch_* bytegleich bis auf den Ordner, Lib 96f136e4 (cortex_gz fa4a951b), Arme nur per Umgebungsvariable. R (tragend): sch_rund GANZ=10, s1, Segment 0 ganz, Modi naechster/null/auf/ab (SNAI_FP_RUNDUNG + SNAI_GZ_IO_RUNDUNG): vier V8-Checkpoints bytegleich; Rot je SNAI_GZ_ROT_FLOAT=h/o/a: auf weicht von naechster ab (sonst null und ab nachfahren; alle gleich = Probe blind, Abhilfe, R wiederholen); Kontrolle Rot-naechster != gruen-naechster. Q (tragend): sch_alle GANZ=10, s1-s3, 5 Segmente, Held-out 300 Fenster nach Segment 4, je Saat (alle-PyTorch)/PyTorch <= +5 % gegen m625-m627 (2,2357/2,2385/2,2326), 3 von 3; sonst Haltepunkt. G (berichtet): sch_heute GANZ=0 gepaart, |Mittel d| < 10 % Gleichstand; Kontrolle Segment 4 = sr-knirps-nachweis Arm B (53c19588/e376eb28/8d399d88). E (Haltepunkt): sch_orest GANZ=10+REST=0, sch_oadam GANZ=10+ADAM=0, d=(alle-ohne X)/ohne X <= +2 % in 3/3; uebrige Stufen zitiert aus ihren Reihen. K Messgeraet vor dem Urteil (rc, STEPS 5001 je Segment, NET2NET, Saettigungen mit Folgezeile, LR-Wache, Telemetrie, Magic, mess.jsonl, Rot der Messung). T Telemetrie berichtet. L README-Liste je Posten mit belegender Reihe in ERGEBNIS_SCHLUSS.md; Posten ausserhalb der eindeutigen Definition (float32 als Speicherformat, Mitteln mehrerer Worker, Genesis-Quantisierung) entscheidet der Autor, bis dahin L offen. Ziel erreicht = R, Q, L erfuellt, kein Haltepunkt aus E, K ohne Befund.
Plan: rechner-a:~/snai_pruef/fullint8/ZIEL.md
Baut auf: snai/fullint8-st10-ckpt, snai/geschichten-pytorch, snai/sr-knirps-nachweis
Darauf baut: snai/fullint8-st11-merge, snai/fullint8-schluss12
Rezepte:
  r732 [2026-11-15] cd ~/snai_pruef/fullint8 && ./schluss.sh  (Kette 1: ./reihe_gz.sh 5 sch_alle:10, dann SNAI_I8_GZ_REST=0 ./reihe_gz.sh 5 sch_orest:10; Kette 2: R = 10 Laeufe PROBE_IN=seg0 ./probe_iso_basis.sh sch_rund <SR_*> <modus> 2 mit SNAI_I8_GANZ=10 [SNAI_GZ_IO_RUNDUNG] [SNAI_GZ_ROT_FLOAT], 3 parallel; dann ./reihe_gz.sh 5 sch_heute:0; dann SNAI_I8_GZ_ADAM=0 ./reihe_gz.sh 5 sch_oadam:10)
      quelltext: cortex_gz.nim fa4a951b (bau11), cortex.nim b9263995, Lib 96f136e4; PHP tensor_io e7dc2c28, tensor_ffi_adapter 088ed992, train_worker 4732351c, train_cluster d2357091, eval_held_out_i8 2ebcc04d (patch_lr.py + patch_v8php.py d780540f); schluss.sh f77c30f6, reihe_gz.sh b7d052f9, lauf_gz.sh a06fa6c6, probe_iso_basis.sh 2fc813aa; KRITERIEN_SCHLUSS.txt 87e1d8bb
      parameter: Knirps 96x2 gebunden, REST=sr, INT8_FULL, Warmup 500, Cosinus 0,001 -> 0,0001 bis 25.000, WD 0,1, 1 Worker, 5 Segmente (25.005 Schritte), CPU 2 Faeden je Lauf, nice 15, Telemetrie alle 1000 Schritte
      seed: s1-s3 (Genesis 34242aac/b7ba6266/3c4c6939, gleicher Armname = gleiche Fensterfolge, gepaart mit PyTorch m625-m627); R nur s1
      rechner: rechner-a (neben der Endstand-Probe, 12 Faeden)
      logs: rechner-a:~/snai_pruef/fullint8/log/schluss.log, log/schluss_rund.log, log/SR_*.log, log/sch_*/, ergebnis/SR_*.snai
      notiz: Rauchtest vor dem Start (nicht gezaehlt, Kurzlauf 232 Schritte, proj_s11 = Lib 96f136e4): GANZ=0 0f79d04c, GANZ=10 759ba426 (= Stufe-10-Lib), Telemetrie alle 50 Schritte 759ba426 (aendert nichts), Telemetrie-Rot q0 100 % Null / 0,00 % Codes geaendert; GANZ=10 in auf ohne IO-Rundung 759ba426; Rot h/o/a jeweils naechster != auf (1be3fca3/57bd71ac, 1cafdaae/ac4f34af, df9572f2/1a6ebf6e); REST=0 und ADAM=0 bei GANZ=10 laufen, schreiben V8, ADAM=0 warnt wie vorgesehen (LRPLAN ohne Wirkung). Start erst nach K4 von snai/fullint8-st10-ckpt.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/fullint8/log/schluss_rund.log, log/SR_*.log, ergebnis/SR_*.snai (Lauf 21:42-22:47)
  m11560 R Checkpoint Segment 0 GANZ=10, Modus naechster / null / auf / ab | 6a544467 viermal, SNAI_V8, STEPS_DONE 5001 -> bytegleich, bestanden | sch_rund | 1 | 4
  m11561 R FPPROBE je Faden (2 Faeden) | jeder Faden meldet den gesetzten Modus (FE 0 / 3072 / 2048 / 1024), Bits von 1/3 je Modus wie in S0 | sch_rund | 1 | 4
  m11562 R Rot h (Hauptfaden) naechster / auf | 5604c10f / b50d1ee2 -> weicht ab, rot gesehen | sch_rund | 1 | 2
  m11563 R Rot o (OpenMP-Schleife) naechster / auf | f02a11e5 / f9147dd0 -> weicht ab, rot gesehen | sch_rund | 1 | 2
  m11564 R Rot a (AVX) naechster / auf | 75184afd / c33bf9d6 -> weicht ab, rot gesehen | sch_rund | 1 | 2
  m11565 R Kontrolle Rot-naechster gegen gruen-naechster | 5604c10f / f02a11e5 / 75184afd gegen 6a544467: alle verschieden (die eingebaute Rechnung wirkt) | sch_rund | 1 | 3
  m11566 R Messgeraet der 10 Laeufe | rc 0, STEPS_DONE 5001, NET2NET-GUARD 0, Fatal 0, ROT-PROBE-Meldung genau in den 6 Rot-Laeufen, Telemetrie 5 Berichte je Lauf; SNAI_GZ_IO_RUNDUNG per Umgebung gesetzt, das Werkzeug schreibt keine Protokollzeile (Wirkung in snai/fullint8-st10-ckpt K3 gesehen) | sch_rund | 1 | 10
  Quelle: rechner-a:~/snai_pruef/fullint8/log/sch_alle/, log/sch_heute/ (*.mess.jsonl, *_s0..s4.train.log), sch_*/factory/checkpoints; auswertung_schluss.py (Lauf 21:42-23:13)
  m11567 Q Held-out Segment 4 alle (PyTorch), q | 2,2650 (2,2357), +1,31 % | sch_alle | 1 | 300
  m11568 Q Held-out Segment 4 alle (PyTorch), q | 2,2529 (2,2385), +0,64 % | sch_alle | 2 | 300
  m11569 Q Held-out Segment 4 alle (PyTorch), q | 2,2482 (2,2326), +0,70 % | sch_alle | 3 | 300
  m11570 Q Urteil | 3 von 3 <= +5 % -> bestanden | sch_alle | 1-3 | 3
  m11571 G Held-out Segment 4 heute, d = (alle - heute)/heute | 2,2536, +0,51 % | sch_heute | 1 | 300
  m11572 G Held-out Segment 4 heute, d | 2,2639, -0,49 % | sch_heute | 2 | 300
  m11573 G Held-out Segment 4 heute, d | 2,2536, -0,24 % | sch_heute | 3 | 300
  m11574 G Mittel d / Urteil | -0,07 %, Gleichstand (Richtung uneinig: 1 schlechter, 2 besser) | sch_heute | 1-3 | 3
  m11575 G Kontrolle heute gegen sr-knirps-nachweis Arm B | Segment 0 ec75ac57/4e7a6c53/b15d1d26, Segment 4 53c19588/e376eb28/8d399d88 = Arm B bytegleich (Held-out wie m11276) | sch_heute | 1-3 | 6
  m11576 K sch_alle Messgeraet 15 Segmentlaeufe | rc 0, STEPS_DONE 5001, NET2NET-GUARD 0, Fatal/NaN/VETO 0, Saettigungen 0 (leere Felder = verschluckte "0"), LR-Wache max 137 * 2^-30 (Wache 2^13), Telemetrie 5 je Segment, alle Segmentdateien SNAI_V8 | sch_alle | 1-3 | 15
  m11577 K sch_alle Segment 0/1 = st10-Reihe (Lib 969a56ee ohne Telemetrie) | 6e710462/19d46fbb, c290894a/81f8c14a, 100f0bc1/779eb281 bytegleich: Telemetrie aendert ueber 10.002 Schritte nichts | sch_alle | 1-3 | 6
  m11578 K sch_heute Messgeraet 15 Segmentlaeufe | rc 0, STEPS_DONE 5001, NET2NET-GUARD 0, Fatal 0, alle SNAI_V7, keine GZ-Zeile | sch_heute | 1-3 | 15
  m11579 K Rot der Messung (sabotage 1) Segment 4 alle / heute | 9,06/9,08/9,08 / 8,96/9,03/9,06 | sch_alle | 1-3 | 6
  Quelle: rechner-a:~/snai_pruef/fullint8/log/sch_alle/*_s0..s4.train.log, Zeilen [GZ-TELE] (25 Berichte je Saat, t = 1000..25000)
  m11580 T Nullgradienten, groesster Anteil ueber alle Matrizen und Berichte | 0,03 % / 0,02 % / 0,02 %, ohne Anstieg | sch_alle | 1-3 | 75
  m11581 T Geaenderte int8-Codes je Schritt, Bericht t=1000 -> t=25000 (emb, q0, v0, up0, down1) | s1 6,7/17,3/19,7/26,1/22,1 % -> 0,7/1,1/2,1/1,5/1,3 %; s2 und s3 ebenso (kleinster Wert ueber alle 0,64 %) | sch_alle | 1-3 | 75
  m11582 T Restpfad log2 max/Mittel (h1.1, hf), t=1000 / 9000 / 25000 | s1 2/1,7 und 3/2,1 -> 4/2,7 und 4/3,2 -> 3/1,9 und 3/2,3; s2, s3 gleich bis auf eine Einheit | sch_alle | 1-3 | 75
  m11583 T Deutung, nicht gemessen | Der Rueckgang der Codeaenderungen um etwa das Zehnfache folgt dem Cosinus der Lernrate (0,001 -> 0,0001), kein Erliegen; tote Gradienten und Restpfad bleiben ueber 25.000 Schritte stabil. Ein Ausfall wie bei Jatai (de Almeida 2026, github.com/kdilim/jatai, nach 3.000-4.000 Schritten) zeigt sich nicht | sch_alle | 1-3 | 0
  Quelle: rechner-a:~/snai_pruef/fullint8/log/sch_orest/, log/sch_oadam/ (*.mess.jsonl, *_s0..s4.train.log), auswertung_schluss.py (Lauf 23:10-00:39); Stufenliste aus der Engine-Zeile "[GZ] Ganzzahl-Pfad ... Stufen an"
  m11584 E Stufen laut Engine sch_orest / sch_oadam | 1-7, 9, 10 (ohne 8 REST) / 1, 2, 4-8, 10 (ohne 3 ADAM und damit ohne 9, WARNUNG im Protokoll) | sch_orest | 1-3 | 2
  m11585 E REST Held-out Segment 4 ohne REST, d = (alle - ohne)/ohne | 2,2603, +0,21 % | sch_orest | 1 | 300
  m11586 E REST Held-out Segment 4 ohne REST, d | 2,2602, -0,32 % | sch_orest | 2 | 300
  m11587 E REST Held-out Segment 4 ohne REST, d | 2,2556, -0,33 % | sch_orest | 3 | 300
  m11588 E REST Urteil | 3 von 3 <= +2 %, Mittel -0,15 %, Gleichstand, kein Haltepunkt | sch_orest | 1-3 | 3
  m11589 E ADAM Held-out Segment 4 ohne ADAM, d = (alle - ohne)/ohne | 2,2578, +0,32 % | sch_oadam | 1 | 300
  m11590 E ADAM Held-out Segment 4 ohne ADAM, d | 2,2563, -0,15 % | sch_oadam | 2 | 300
  m11591 E ADAM Held-out Segment 4 ohne ADAM, d | 2,2562, -0,35 % | sch_oadam | 3 | 300
  m11592 E ADAM Urteil | 3 von 3 <= +2 %, Mittel -0,06 %, Gleichstand, kein Haltepunkt | sch_oadam | 1-3 | 3
  m11593 K sch_orest / sch_oadam Messgeraet je 15 Segmentlaeufe | rc 0, STEPS_DONE 5001, NET2NET-GUARD 0, Fatal 0, alle SNAI_V8; sch_orest Telemetrie 5 je Segment, LR-Wache max 137; sch_oadam ohne GZ-Adam-Zeilen (alter float-Adam), keine Telemetrie wie vorab vermerkt | sch_orest | 1-3 | 30
  m11594 K Rot der Messung Segment 4 ohne REST / ohne ADAM | 9,08/9,11/9,09 / 9,06/9,09/9,05 | sch_orest | 1-3 | 6
  m11596 Aus-Probe Hauptbaum mit cortex_gz fa4a951b (Telemetrie + Rot-Schalter), Lib 96f136e4, Segment 0, Schalter ungesetzt | 7063ce99 (= Bezug) | U_neu11 | 1 | 1
  Quelle: rechner-a:~/snai_pruef/fullint8/log/sch_heute/gesch_d96h6L2_s1.log, log/sch_alle/gesch_d96h6L2_s1.log (Zeilen "Segment N: rc=0 nach X s")
  m11597 Laufzeit je Segment, Saat 1 (3 parallel a 2 Faeden, zwei Ketten parallel, neben der Endstand-Probe) | sch_alle 869-1113 s (Mittel ca. 1004 s), sch_heute 258-274 s: der Ganzzahl-Weg ist auf der CPU rund 3,7x langsamer als der alte float-Weg; sch_orest und sch_oadam je 5 Segmente in 82-86 min, R je Lauf ca. 17 min | - | 1 | 0
Ergebnis e697 [2026-11-16 07:51]: erfuellt
  Fazit: Loest e695 ab. R, Q und L sind erfuellt, fuer den fertigen Schalter SNAI_I8_GANZ=12 nachgemessen in snai/fullint8-schluss12 (e693). Neu gegenueber e695: In der Release-Fassung v0.2.0 von snai-int8 (Arbeitsbaum vor dem Commit, geprueft 2026-11-16 07:51, README da9ea3ed) ist die Liste "Noch in float" ersetzt. An ihrer Stelle steht ein Schalter-Abschnitt mit den erlaubten Ausnahmen, den Voraussetzungen (sonst Abbruch), der Rundungsprobe mit ihrer Reichweite und den Grenzen. Die Rahmung bleibt "int8-Training", wie der Autor gewaehlt hat. Damit ist das Full-int8-Ziel (CPU) in der Release-Fassung in allen drei Punkten erfuellt. Oeffentlich gilt es mit der Veroeffentlichung von v0.2.0; Commit, Push und Release gibt der Autor frei. Wird v0.2.0 nicht so veroeffentlicht, gilt e695.
  Offen: Veroeffentlichung v0.2.0 (Freigabe der Dateiliste durch den Autor, Commit, Push, Tag, Zenodo). Karte (CUDA/OpenCL) ist ein eigener Auftrag. Andere Modellgroessen, mehr als 2 Worker und laengere Laeufe sind nicht Teil der Aussage. Auf der CPU rund 3,7x langsamer.
  Datei: docs/messreihen/fullint8/ERGEBNIS_SCHLUSS.md
Abgeloest und ausgeblendet: 1 messwert, 3 ergebnis - voll=True zeigt sie.
Chronik (juengste 8 von 14, voll=True zeigt alle):
  2026-11-16 00:40 Messwerte m11584-m11596
  2026-11-16 00:40 Messwerte m11597, loesen m11595 ab
  2026-11-16 00:41 Ergebnis e689: teilweise
  2026-11-16 00:41 Status laeuft -> ausgewertet (Ergebnis e689)
  2026-11-16 03:25 Entscheidung des Autors 16.11. ~00:45 zu L (interne Notiz): (1) float32 als Speicherformat ganzzahlig gebildeter Werte (Gains, Momente der Gains, Skalen) = ganzzahlig, ein Satz in der README; (3) Quantisieren der float-Genesis beim Start = Initialisierung, erlaubt; (2) Mitteln mehrerer Worker: ganzzahligen Merge als Stufe 11 bauen; (4) float32-Gradientenpuffer nur anlegen, wenn eine Stufe aus ist (eigener Schritt). L bleibt offen bis (2) und (4) erfuellt sind; danach neues Ergebnis, das e689 abloest.
  2026-11-16 06:39 Ergebnis e694: erfuellt, loest e689 ab
  2026-11-16 06:42 Ergebnis e695: erfuellt, loest e694 ab
  2026-11-16 07:51 Ergebnis e697: erfuellt, loest e695 ab
```
