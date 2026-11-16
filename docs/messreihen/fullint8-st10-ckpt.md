# snai/fullint8-st10-ckpt

```text
snai/fullint8-st10-ckpt - ausgewertet, angelegt 2026-11-15, zuletzt 2026-11-15 21:42
Frage: Schreibt die Engine mit SNAI_I8_GZ_CKPT=1 die Adam-Momente der int8-Matrizen als 8-Bit-Code plus Zeilenskala (SNAI_V8) statt als float32, so dass Speichern und Laden nichts mehr rechnen (unabhaengig vom Rundungsmodus), der Zustand den Weg ueber die Datei unveraendert uebersteht, V6/V7 unveraendert bleiben und kein Leser eine V8-Datei still falsch liest?
Kriterium (festgelegt 2026-11-15 20:59, vor dem ersten Messwert):
  Volltext docs/messreihen/fullint8/KRITERIEN_ST10.txt (md5 ee2921b4, nach Zweitmeinung). K1 Kurzlauf isoliert, Stufe-10-Lib + V8-PHP: GANZ=0..9 = 0f79d04c/47176fa4/12e40925/6f382e75/ac0be686/8239bb67/39c71b8a/0b208b49/278e3d14/201f5494; GANZ=10+CKPT=0 = 201f5494; GANZ=9+CKPT=1 = GANZ=10; GANZ=10 zweimal gleich, 1 = 2 Faeden; Stufe-9-Lib + V8-PHP GANZ=9 = 201f5494; Stufe-10-Lib + Stufe-9-PHP GANZ=9 = 201f5494; GANZ=1+CKPT=1 schreibt V8, dessen V7-Fassung = 47176fa4. K2 (a) V8->laden->V8 bytegleich; (b) V8->V7 = V7-Datei desselben Laufs; (c) Fortsetzung GANZ=10 aus V8 = aus V7 bytegleich; (d) mess_text.php V8 = V7 (loss, rang0, uni, bi, tri); (e) eval_held_out_i8.php laedt V8 (rc 0), gleicher Wert wie V7. K3 SNAI_GZ_IO_RUNDUNG auf/ab/null: V8->V8 bytegleich zu naechster in allen drei; Rot: V7->V7 weicht in mind. einem Modus ab. K3b V8 an Leser ohne V8-Weg: load_v6_model_full -> null mit Meldung; export_int8_deployment -> false mit Meldung; cortex_load_stream_i8 ohne 8-Bit-Momentspeicher -> NULL mit Meldung; train_cluster.php 2 Worker GANZ=10 -> Abbruch beim Merge, rc != 0; Rot: dieselben Aufrufe mit V7 gelingen. K4 zwei Segmente (10.002 Schritte), s1-s3 gepaart, st10 (V8 an der Grenze) gegen st9 (V7 an der Grenze): d=(st10-st9)/st9 <= +2 % in 3/3, sonst Haltepunkt; |d| < 10 % Gleichstand; berichtet: V7-Fassung des st10-Endstands = st9-Endstand? K5 STEPS_DONE 5001 je Segment, NET2NET-GUARD, Saettigungen, Wachenbericht LR-Plan, Magic der Segmentdateien (st10 V8, st9 V7), mess.jsonl ohne Fehler. Urteil erfuellt = K1-K5; 3 Saaten, 3 von 3; bei Uneinigkeit saatabhaengig, kein Schluss.
Plan: rechner-a:~/snai_pruef/fullint8/PLAN.md
Baut auf: snai/fullint8-st9-lrplan
Darauf baut: snai/fullint8-schluss, snai/fullint8-st11-merge
Rezepte:
  r731 [2026-11-15] cd ~/snai_pruef/fullint8 && ./st10_proben.sh (K1, K2c, K3b-Merge; probe_iso_basis.sh, 2 parallel) && ./v8_nach.sh (K1 V7-Fassung, K2 a/b/d/e, K3, K3b-Leser); K4: ./reihe_gz.sh 2 st9:9 (nur Segment 1 neu) und ./reihe_gz.sh 2 st10:10
      quelltext: gz/cortex_gz.nim 20bad39c, cortex.nim b9263995 (Hauptbaum 1a8edde + patch_s0.py + patch_gz.py ed29d20f + patch_v8.py), Lib 969a56ee (bau10); PHP = patch_lr.py + patch_v8php.py d780540f (13 Ersetzungen; die 13. vor den gezaehlten Laeufen ergaenzt: load_v6_model_full meldet V8 laut, vorher still null; tensor_io.php e7dc2c28, tensor_ffi_adapter.php 088ed992, train_worker.php 4732351c, train_cluster.php d2357091, eval_held_out_i8.php 2ebcc04d); st10_proben.sh 4eaffc24, v8_nach.sh 7e3a3dc8, v8_rundweg.php 6e3a3f2e, probe_iso_basis.sh 2fc813aa (PROBE_WORKER ergaenzt, Vorgabe 1); Vergleichsarme proj_d10a (Stufe-9-Lib 3e0e8e5f + V8-PHP), proj_d10u (Stufe-10-Lib + Stufe-9-PHP tensor_io fe86844d, train_worker aad5fd3a)
      parameter: Knirps 96x2 gebunden, REST=sr, W=500, D=25000, lr 0.001; Kurzlaeufe 232 Schritte; K4 Segmente 0+1; CPU 2 Faeden, nice 15
      seed: K1-K3 s1 (Genesis s1); K4 s1-s3 gepaart mit st9
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/fullint8/log/st10_proben.log, log/P10_*.log, log/v8_nach.log, log/st9/, log/st10/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/fullint8/log/st10_proben.log, log/P10_*.log, log/v8_nach.log (K3b-Nim-Zeile mit berichtigter NULL-Pruefung nachgefahren), log/st9/ und log/st10/ (*.mess.jsonl, *_s0/_s1.train.log), auswertung_schluss.py; V7-Fassungen per v8_rundweg.php GANZ=9; U_neu10.out
  m11533 K1 GANZ=0..9 md5 (Lib 969a56ee + V8-PHP) | 0f79d04c/47176fa4/12e40925/6f382e75/ac0be686/8239bb67/39c71b8a/0b208b49/278e3d14/201f5494 = Bezug | st10 |  | 10
  m11534 K1 GANZ=10 md5, 2/2/1 Faeden | 759ba426 dreimal (SNAI_V8) | st10 |  | 3
  m11535 K1 GANZ=10+CKPT=0 / GANZ=9+CKPT=1 | 201f5494 (V7, = GANZ=9) / 759ba426 (V8, = GANZ=10) | st10 |  | 2
  m11536 K1 Vertraeglichkeit Stufe-9-Lib + V8-PHP / Stufe-10-Lib + Stufe-9-PHP, GANZ=9 | 201f5494 / 201f5494 | st10 |  | 2
  m11537 K1 GANZ=1+CKPT=1 | schreibt SNAI_V8 (83a3d8e4), V7-Fassung 47176fa4 (= GANZ=1) | st10 |  | 1
  m11538 K2a V8 -> laden -> V8 | 759ba426 bytegleich | st10 |  | 1
  m11539 K2b V8 -> laden -> V7 | 201f5494 = V7-Datei desselben Laufs | st10 |  | 1
  m11540 K2c Fortsetzung GANZ=10 aus V7 / aus V8 | 389a20ff / 389a20ff | st10 |  | 2
  m11541 K2d mess_text.php V7 / V8 (loss rang0 uni bi tri) | 4,4809 24,97 4,9127 2,9823 2,6467 beide | st10 |  | 2
  m11542 K2e eval_held_out_i8.php V7 / V8 | rc 0, HELDOUT_LOSS 4,874897 beide | st10 |  | 2
  m11543 K3 V8 -> V8 in auf / ab / null | 759ba426 dreimal (= naechster) | st10 |  | 3
  m11544 K3 Rot V7 -> V7 in auf / ab / null | 927bd4ec / c4da540c / c4da540c (naechster 201f5494): weicht ab | st10 |  | 3
  m11545 K3b V8 an load_v6_model_full / export_int8_deployment / Nim ohne 8-Bit-Momentspeicher | null mit Meldung / false mit Meldung / NULL mit FATAL-Meldung, Fehler 8 | st10 |  | 3
  m11546 K3b Merge 2 Worker GANZ=10 | rc 1, "SNAI_V8-Checkpoints mehrerer Worker lassen sich (noch) nicht mitteln - Abbruch" | st10 |  | 1
  m11547 K3b Rot: dieselben Aufrufe mit V7 | geladen / exportiert / geladen; Merge 2 Worker GANZ=9 rc 0 (5751c048, V7) | st10 |  | 4
  m11548 K4 Held-out nach Segment 1 st10 (st9), d | 2,4793 (2,4793), +0,000 % | st10 | s1 | 300
  m11549 K4 Held-out nach Segment 1 st10 (st9), d | 2,4708 (2,4708), +0,000 % | st10 | s2 | 300
  m11550 K4 Held-out nach Segment 1 st10 (st9), d | 2,4622 (2,4622), +0,000 % | st10 | s3 | 300
  m11551 K4 V7-Fassung des st10-Stands = st9-Stand, Segment 0 und 1 | bytegleich in 6 von 6 (s1 58903a2b/6c126b68, s2 6ee89c1a/15f199a7, s3 60b86c5c/4e0882c9) | st10 | s1-s3 | 6
  m11552 K5 STEPS_DONE / NET2NET-GUARD / Fatal | 5001 je Segment / 0 / 0 in allen 12 Segmentlaeufen | st10 |  | 12
  m11553 K5 Saettigungen Adam / Restpfad | 0 in allen lesbaren Berichten (leere Felder = verschluckte "0", interne Notiz); st10 s2 Segment 0 bei 2000 lesbar 0, und derselbe Rechenweg wie st9 s2 (V7-Fassung bytegleich) -> bestaetigt m11530 | st10 |  | 12
  m11554 K5 LR-Wache groesste Abweichung | 128 (Segment 0), 89 (Segment 1) * 2^-30, kein Abbruch | st10 |  | 12
  m11555 K5 Magic der Segmentdateien | st10 SNAI_V8, st9 SNAI_V7 | st10 |  | 12
  m11556 K5 Rot der Messung (sabotage 1) nach Segment 1 | 8,81 / 8,83 / 8,69 gleich in st9 und st10 | st10 |  | 6
  m11557 Dateigroesse Checkpoint V8 / V7 | 1.142.866 / 3.313.206 Byte (-65,5 %) | st10 |  | 1
  m11558 Laufzeit Segment 1 | st9 ca. 18 min, st10 ca. 14 min (je 3 parallel a 2 Faeden, unter Last) | st10 |  | 6
  m11559 Aus-Probe Hauptbaum Segment 0, Schalter ungesetzt (Lib 969a56ee im Hauptbaum gebaut) | 7063ce99 (= Bezug), STEPS_DONE 5001 | U_neu10 | 1 | 1
Ergebnis e688 [2026-11-15 21:42]: erfuellt
  Fazit: Der Checkpoint rechnet beim Speichern und Laden nichts mehr. Die Momente der int8-Matrizen gehen als 8-Bit-Code mit Zeilenskala in die Datei, genau wie sie im Speicher liegen. Damit ist die Datei in jedem Rundungsmodus dieselbe, und sie ist um zwei Drittel kleiner. Der Zustand uebersteht die Segmentgrenze verlustfrei: Nach zwei Segmenten ist die V7-Fassung des V8-Laufs bytegleich zum V7-Lauf, in allen drei Saaten. Der Held-out ist deshalb nicht nur Gleichstand, sondern identisch. Nebenbefund: Auch der alte V7-Weg war an dieser Grenze verlustfrei im Modus naechster (Entquantisieren und Neukodieren treffen dieselben Codes). Sein Problem ist nur die Abhaengigkeit vom Rundungsmodus, nicht ein Genauigkeitsverlust. Damit faellt der Posten "im Checkpoint die Adam-Momente (Format float32)" aus der README-Liste. Die Gains und die Skalen bleiben als float32-Bitmuster in der Datei; sie werden ganzzahlig gebildet und nur kopiert. Wie das in der README heisst, entscheidet der Autor. Grenze: Mehrere Worker lassen sich mit V8 nicht mitteln. Sie brechen laut ab, statt still falsch zu mitteln.
  Offen: Merge mehrerer Worker fuer V8 (ganzzahliger Merge) fehlt; load_v6_model_full, Export, Destillerie, Inferenz- und Diagnose-Skripte lesen V8 nicht (melden es). Ungebundene Modelle nur ueber den Code, nicht gemessen.
  Datei: docs/messreihen/fullint8/KRITERIEN_ST10.txt
Chronik:
  2026-11-15 20:59 angelegt
  2026-11-15 20:59 Rezept r731
  2026-11-15 20:59 Status geplant -> laeuft (Rezept r731)
  2026-11-15 21:42 Messwerte m11533-m11559
  2026-11-15 21:42 Ergebnis e688: erfuellt
  2026-11-15 21:42 Status laeuft -> ausgewertet (Ergebnis e688)
```
