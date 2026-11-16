# snai/fullint8-schluss12

```text
snai/fullint8-schluss12 - ausgewertet, angelegt 2026-11-16, zuletzt 2026-11-16 06:39
Frage: Gelten die tragenden Teile R (Rundungsprobe) und Q (Qualitaet) der Schlussprobe (snai/fullint8-schluss, gemessen mit SNAI_I8_GANZ=10) auch fuer den fertigen Schalter SNAI_I8_GANZ=12 (Stufen 1-12, ganzzahliger Merge, ohne float-Gradientenpuffer), gefahren aus dem Stand des Hauptbaums?
Kriterium (festgelegt 2026-11-16 05:13, vor dem ersten Messwert):
  Volltext docs/messreihen/fullint8/KRITERIEN_SCHLUSS12.txt (md5 426e9afb, nach Zweitmeinung). Kopien hb_rund/hb_alle = proj_hb = Hauptbaum nach Stufe 12 (Lib dca24a87), Code-Dateien vorher bytegleich geprueft (revival_config wie alle Probekopien aus). Einziges Stellrad gegen die Schlussprobe: GANZ=12 statt 10 plus Code der Stufen 11/12. R12 (tragend): s1, Segment 0 ganz, 2 Faeden, Modi naechster/null/auf/ab: vier V8-Checkpoints bytegleich (erwartet 6a544467); Rot SNAI_GZ_ROT_FLOAT=h: auf != naechster, Rot-naechster != gruen. R12w (tragend): dasselbe mit 2 Workern, bytegleich (erwartet 3f64d3c1 = R2 Stufe 11). R12f (tragend): Fortsetzung aus ergebnis/K1_g11.snai, Kurzlauf 1 Faden, vier Modi bytegleich (erwartet 389a20ff). Q12 (tragend): s1-s3, 5 Segmente, reihe_gz.sh 5 hb_alle:12; Held-out nach Segment 4 je Saat <= +5 % gegen PyTorch m625-m627 (2,2357/2,2385/2,2326) in 3/3, sonst Haltepunkt; gleich gewichtet alle 15 Segment-Checkpoints bytegleich zu sch_alle (s1 6e710462..00552e4d, s2 c290894a..1b0574bb, s3 100f0bc1..ea4ebe90), eine Abweichung = Haltepunkt unabhaengig vom Q-Wert. K Messgeraet je Lauf (rc, STEPS 5001, NET2NET 0, Fatal/NaN/VETO 0, SNAI_V8, Stufenliste 1-12 aus der Engine, Stufe-12-Meldung 2043648 Bytes freigegeben/nicht angelegt, keine Stufe-12-Warnung, LR-Wache, Telemetrie, mess.jsonl, Rot der Messung um 9). G und E nicht wiederholt (Stufen 1-10 unveraendert, GANZ=0 bytegleich; Stufen 11/12 in e691/e692). Erfuellt = R12, R12w, R12f, Q12, K ohne Befund. Danach L der Schlussprobe neu urteilen.
Plan: rechner-a:~/snai_pruef/fullint8/ZIEL.md
Baut auf: snai/fullint8-schluss, snai/fullint8-st11-merge, snai/fullint8-st12-gfrei
Rezepte:
  r733 [2026-11-16] cd ~/snai_pruef/fullint8 && ./schluss12.sh  (Kette Q: ./reihe_gz.sh 5 hb_alle:12; Kette R: PROBE_IN=seg0 ./probe_iso_basis.sh hb_rund HR_* <modus> 2 mit SNAI_I8_GANZ=12 [SNAI_GZ_IO_RUNDUNG] [SNAI_GZ_ROT_FLOAT=h], 3 parallel; dann HRW_* mit PROBE_WORKER=2 einzeln; daneben HRF_* mit PROBE_BASIS=ergebnis/K1_g11.snai, Kurzlauf, 1 Faden)
      quelltext: Hauptbaum ~/Projekte/snai_edge_int8_lora nach Commit 6539a6c (Stufe 12): cortex_gz.nim ae179d20, cortex.nim 4e192007, Lib dca24a87, tensor_io 6d044735, train_cluster 50fc8b30, train_worker 4732351c; Kopien hb_rund/hb_alle (cp -a proj_hb, Code bytegleich geprueft); schluss12.sh 89f0c0b3, reihe_gz.sh b7d052f9, lauf_gz.sh a06fa6c6, probe_iso_basis.sh 2fc813aa; KRITERIEN_SCHLUSS12.txt 426e9afb
      parameter: Knirps 96x2 gebunden, REST=sr, INT8_FULL, Warmup 500, Cosinus 0,001 -> 0,0001 bis 25.000, WD 0,1, 1 Worker (R12w 2), 5 Segmente (25.005 Schritte), CPU 2 Faeden je Lauf, nice 15, Telemetrie wie Schlussprobe
      seed: s1-s3 (Genesis 34242aac/b7ba6266/3c4c6939, gepaart mit sch_alle und PyTorch m625-m627); R nur s1
      rechner: rechner-a (12 Faeden)
      logs: rechner-a:~/snai_pruef/fullint8/log/schluss12.log, log/schluss12_r.log, log/HR*_*.log, log/hb_alle/, ergebnis/HR*_*.snai, hb_alle/factory/checkpoints
      notiz: Start 2026-11-16 05:13:55. Vorher: Aus-Probe Hauptbaum nach Stufe 12 bytegleich (m11709 in snai/fullint8-st12-gfrei).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/fullint8/log/schluss12_r.log, log/HR_*.log, ergebnis/HR_*.snai (Lauf 05:13-05:48)
  m11712 R12 Checkpoint Segment 0 GANZ=12, Modus naechster / null / auf / ab | 6a544467 viermal (= GANZ=10 m11560), SNAI_V8, STEPS_DONE 5001 -> bytegleich, bestanden | hb_rund | 1 | 4
  m11713 R12 FPPROBE je Faden (2 Faeden) | jeder Faden meldet den gesetzten Modus (FE 0 / 3072 / 2048 / 1024) | hb_rund | 1 | 4
  m11714 R12 Rot h naechster / auf | 5604c10f / b50d1ee2 -> weicht ab, rot gesehen (dieselben md5 wie GANZ=10 m11562) | hb_rund | 1 | 2
  m11715 R12 Kontrolle Rot-naechster gegen gruen-naechster | 5604c10f gegen 6a544467 verschieden | hb_rund | 1 | 1
  m11716 R12 Messgeraet der 6 Laeufe | rc 0, STEPS_DONE 5001, Bilanz 5.001 = Plan, Engine-Zeile GANZ=12 Stufen 1-12, Stufe-12-Meldung "freigegeben 2043648 Bytes" in allen 6, keine WARNUNG/FATAL/NET2NET-Zeile, ROT-PROBE-Meldung genau in den 2 Rot-Laeufen; ca. 17 min je Lauf | hb_rund | 1 | 6
  Quelle: rechner-a:~/snai_pruef/fullint8/log/schluss12_r.log, log/HRW_*.log, log/HRF_*.log, log/hb_alle/ (*.mess.jsonl, *_s0..s4.train.log), hb_alle/factory/checkpoints; auswertung_schluss.py hb_alle (Lauf 05:13-06:37)
  m11717 R12w Checkpoint Segment 0 GANZ=12, 2 Worker, Modus naechster / null / auf / ab | 3f64d3c1 viermal (= R2 der Stufe 11 mit GANZ=11), SNAI_V8, Bilanz 5.001 = Plan, Merge-Zeile "ganzzahlig gemittelt (Stufe 11)" je Lauf, Stufe-12-Meldung "freigegeben" in beiden Workern -> bytegleich, bestanden | hb_rund | 1 | 4
  m11718 R12f Fortsetzung aus K1_g11.snai (V8), Kurzlauf 232 Schritte, 1 Faden, Modus naechster / null / auf / ab | 389a20ff viermal (= st12 K2), Stufe-12-Meldung "nicht angelegt 2043648 Bytes", Bilanz 232 = Plan -> bytegleich, bestanden | hb_rund | 1 | 4
  m11719 Q12 Segment-Checkpoints s1 (Segment 0-4) gegen sch_alle | 6e710462 19d46fbb f94d53c1 3b7afe5f 00552e4d, alle 5 bytegleich | hb_alle | 1 | 5
  m11720 Q12 Segment-Checkpoints s2 gegen sch_alle | c290894a 81f8c14a 6a5253a0 197ded48 1b0574bb, alle 5 bytegleich | hb_alle | 2 | 5
  m11721 Q12 Segment-Checkpoints s3 gegen sch_alle | 100f0bc1 779eb281 4ee24230 e9ca5845 ea4ebe90, alle 5 bytegleich | hb_alle | 3 | 5
  m11722 Q12 Held-out Segment 4 GANZ=12 (PyTorch), q | 2,2650 (2,2357), +1,31 % | hb_alle | 1 | 300
  m11723 Q12 Held-out Segment 4 GANZ=12 (PyTorch), q | 2,2529 (2,2385), +0,64 % | hb_alle | 2 | 300
  m11724 Q12 Held-out Segment 4 GANZ=12 (PyTorch), q | 2,2482 (2,2326), +0,70 % | hb_alle | 3 | 300
  m11725 Q12 Urteil | 3 von 3 <= +5 % und 15 von 15 Checkpoints bytegleich zu sch_alle -> bestanden | hb_alle | 1-3 | 3
  m11726 K hb_alle Messgeraet 15 Segmentlaeufe | rc 0, STEPS_DONE 5001, NET2NET-GUARD 0, Fatal/NaN/VETO 0, Saettigungen 0, LR-Wache max 137 * 2^-30, Telemetrie 5 Berichte je Segment, alle SNAI_V8, Engine-Zeile Stufen 1-12 (in s3 Segment 2 auf zwei Logzeilen zerteilt, interne Notiz, Inhalt vollstaendig), Stufe-12-Meldung 2043648 Bytes "freigegeben" in Segment 0 und "nicht angelegt" in 1-4, keine Stufe-12-WARNUNG; mess.jsonl 6 Zeilen je Saat; Rot der Messung 9,06/9,08/9,08 | hb_alle | 1-3 | 15
  m11727 K Vermerk Merge-Meldung bei 1 Worker | train_cluster meldet "[Merge] INT8-Tensoren (Pro-Zeile-Skala, neu abgeleitet) ..." auch bei einem Worker; merge_v6_models macht dann nur copy() (tensor_io.php Zeile 1281), keine Rechnung - Meldung irrefuehrend, Weg unbedenklich | hb_alle | 1-3 | 0
Ergebnis e693 [2026-11-16 06:39]: erfuellt
  Fazit: Der fertige Schalter SNAI_I8_GANZ=12 im Stand des Hauptbaums (6539a6c, Lib dca24a87) ist ueber den ganzen Lauf Byte fuer Byte derselbe wie GANZ=10 in der Schlussprobe: Segment 0 in allen vier Rundungsmodi 6a544467, alle 15 Segment-Checkpoints der Qualitaetslaeufe bytegleich zu sch_alle. R und Q gelten damit gemessen, nicht angenommen, fuer den fertigen Schalter (Held-out +1,31/+0,64/+0,70 % gegen PyTorch). Dazu belegt, was die Schlussprobe nicht sah: Mitteln mit 2 Workern (3f64d3c1 in vier Modi) und Fortsetzen aus V8 (389a20ff in vier Modi) sind ebenfalls rundungsunabhaengig. Weitere CPU-Laeufe lohnen fuer das Ziel nicht; das naechste offene Stueck ist der Kartenauftrag.
  Offen: Mehr als 2 Worker ueber viele Segmente, andere Modellgroessen, Karte. Meldung "[Merge] INT8-Tensoren ..." bei einem Worker ist irrefuehrend (nur copy()), nicht geaendert.
  Datei: docs/messreihen/fullint8/ERGEBNIS_SCHLUSS12.md
Chronik:
  2026-11-16 05:13 angelegt
  2026-11-16 05:14 Rezept r733
  2026-11-16 05:14 Status geplant -> laeuft (Rezept r733)
  2026-11-16 05:48 Messwerte m11712-m11716
  2026-11-16 06:38 Messwerte m11717-m11727
  2026-11-16 06:39 Ergebnis e693: erfuellt
  2026-11-16 06:39 Status laeuft -> ausgewertet (Ergebnis e693)
```
