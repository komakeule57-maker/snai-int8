# snai/fullint8-st12-gfrei

```text
snai/fullint8-st12-gfrei - ausgewertet, angelegt 2026-11-16, zuletzt 2026-11-16 05:13
!! ohne Rezept
Frage: Legt die Engine mit SNAI_I8_GZ_GFREI=1 (bzw. SNAI_I8_GANZ=12) die float32-Gradientenpuffer der Matrizen nicht mehr an (bzw. gibt sie im Genesis-Weg frei), ohne dass sich am Training ein Byte aendert, sinkt dabei der Speicher, und lehnt ein Schritt, der die Puffer braeuchte, laut ab?
Kriterium (festgelegt 2026-11-16 04:23, vor dem ersten Messwert):
  Volltext docs/messreihen/fullint8/KRITERIEN_ST12.txt (md5 b327c51f). K1 aus bytegleich (st12 Lib 024c34f6): Kurzlauf GANZ=0/9/10/11 = 0f79d04c/201f5494/759ba426/759ba426, 2 Worker GANZ=11 = 36fba098, Fortsetzung aus K1_g11.snai GANZ=11 = 389a20ff. K2 an bytegleich: GANZ=12 Kurzlauf 759ba426, 2 Worker 36fba098, Fortsetzung 389a20ff; Segment 0 ganz GANZ=12 in naechster und auf = 6a544467; Meldungen freigegeben/nicht angelegt 2043648 Bytes. K3 Abhaengigkeit laut: GANZ=12+ADAM=0 Warnung, Ergebnis = GANZ=11+ADAM=0; GANZ=12+ADAMVGL=1 Warnung, Puffer bleiben, rc 0. K4 Sperre: SNAI_GZ_GFREI_ROT=1 mit GANZ=12 im Fortsetzungs- und Genesis-Weg FATAL, kein Checkpoint, rc != 0; Kontrolle GANZ=11 laeuft durch. K5 Speicher mess_rss.py (ru_maxrss), Fortsetzungs-Kurzlauf 1 Faden, 3 gegen 3 abwechselnd: jeder GANZ=12-Lauf unter jedem GANZ=11-Lauf; Differenz gegen erwartete 1.996 KB berichtet, Genesis-Weg berichtet; Rot des Messgeraets 50 MB gesehen. Erfuellt = K1-K5.
Plan: rechner-a:~/snai_pruef/fullint8/PLAN.md
Baut auf: snai/fullint8-st11-merge
Darauf baut: snai/fullint8-schluss12, snai/worker-minus1
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/fullint8/log/st12_lauf1/ (Lauf 1, Lib 024c34f6, VERWORFEN nach Befund K4; Kriterien b327c51f -> Nachtrag da66e9f3)
  m11677 Lauf 1 K1 aus GANZ=0/9/10/11, 2 Worker, Fortsetzung | 0f79d04c/201f5494/759ba426/759ba426, 36fba098, 389a20ff (wie erwartet) | Lauf1 | s1 | 6
  m11678 Lauf 1 K2 an GANZ=12 Kurzlauf / 2 Worker / Fortsetzung | 759ba426 / 36fba098 / 389a20ff | Lauf1 | s1 | 3
  m11679 Lauf 1 K4 Sperre Fortsetzungsweg (ROT=1) | FATAL je Schritt, rc 1, kein Checkpoint (Abbruch nur ueber Master-Pruefung "keinen einzigen Loss") | Lauf1 | s1 | 1
  m11680 Lauf 1 K4 Sperre Genesis-Weg (ROT=1) | VERFEHLT: FATAL ab Schritt 2, aber rc 0 und Checkpoint 563a6f3a (train_worker.php wertet -1 nicht aus, Schritt 1 lief noch mit Puffern) | Lauf1 | s1 | 1
  m11681 Lauf 1 K4 Kontrolle GANZ=11 + ROT=1 | rc 0, 389a20ff | Lauf1 | s1 | 1
  m11682 Lauf 1 K5 maxrss Fortsetzung GANZ=11 | 75288 / 74960 / 78184 KB | Lauf1 | s1 | 3
  m11683 Lauf 1 K5 maxrss Fortsetzung GANZ=12 | 71372 / 72100 / 74860 KB (alle unter jedem GANZ=11-Lauf, Abstand der Spannen 100 KB) | Lauf1 | s1 | 3
  m11684 Lauf 1 K5 maxrss Genesis GANZ=11 / GANZ=12 | 74168 73988 (dritter s. Log) / 74260 73860 74116 KB | Lauf1 | s1 | 5
  m11685 Lauf 1 Streuung maxrss ueber den probe_iso_basis-Baum | bis 3.224 KB zwischen gleichen Laeufen (groesser als der erwartete Effekt 1.996 KB) -> K5b nachgetragen | Lauf1 | s1 | 3
  Quelle: rechner-a:~/snai_pruef/fullint8/log/st12_t1.log, st12_t2.log, T12_*.log (Lauf 2, Lib dca24a87, cortex.nim 4e192007, cortex_gz.nim ae179d20, Kriterien da66e9f3, st12_proben.sh eadcb50f)
  m11693 K1 Kurzlauf GANZ=0/9/10/11 | 0f79d04c / 201f5494 / 759ba426 / 759ba426 | aus | s1 | 4
  m11694 K1 2 Worker GANZ=11 / Fortsetzung GANZ=11 | 36fba098 / 389a20ff | aus | s1 | 2
  m11695 K2 GANZ=12 Kurzlauf / 2 Worker / Fortsetzung | 759ba426 / 36fba098 / 389a20ff; Meldungen "freigegeben 2043648 Bytes" (Genesis, je Worker) bzw. "nicht angelegt 2043648 Bytes" (Fortsetzung) | an | s1 | 3
  m11696 K2 Segment 0 ganz GANZ=12 naechster / auf | 6a544467 / 6a544467 (= Rundungsprobe der Schlussprobe), rc 0, Bilanz 5.001 = Plan | an | s1 | 2
  m11697 K3 GANZ=12+ADAM=0 / GANZ=11+ADAM=0 | e702a83f / e702a83f, Warnung "braucht die Stufen 2 (MATMUL), 3 (ADAM) und 8 (REST) - aus", keine Stufe-12-Meldung | Abhaengigkeit | s1 | 2
  m11698 K3 GANZ=12+ADAMVGL=1 | rc 0, Warnung "aus (SNAI_GZ_ADAMVGL rechnet den float-Weg daneben) - Gradientenpuffer bleiben" | Abhaengigkeit | s1 | 1
  m11699 K4 Sperre ROT=1 Fortsetzungsweg | FATAL "... - Prozess beendet", rc 1, kein Checkpoint | Sperre | s1 | 1
  m11700 K4 Sperre ROT=1 Genesis-Weg | FATAL ab Schritt 2, Master "Worker 0 ist abgestuerzt (Exit-Code: 1). Breche Epoche sofort ab", rc 1, kein neuer Checkpoint (die im Log genannte md5 563a6f3a ist die Datei von Lauf 1, 04:37, probe_iso_basis raeumt ergebnis/ nicht) | Sperre | s1 | 1
  m11701 K4 Kontrolle GANZ=11+ROT=1 | rc 0, 389a20ff | Sperre | s1 | 1
  m11702 K5 maxrss Baum Fortsetzung GANZ=11 | 75028 / 75024 / 75120 KB | aus | s1 | 3
  m11703 K5 maxrss Baum Fortsetzung GANZ=12 | 72008 / 72112 / 71824 KB (alle unter jedem GANZ=11-Lauf; Mittel -3.076 KB, 154 % der Erwartung) | an | s1 | 3
  m11704 K5b maxrss ein Prozess (v8_rundweg) GANZ=11 | 60508 / 60632 / 60640 KB | aus | s1 | 3
  m11705 K5b maxrss ein Prozess (v8_rundweg) GANZ=12 | 58628 / 58536 / 58416 KB (alle darunter; Mittel -2.067 KB = 103,5 % der erwarteten 1.996 KB) | an | s1 | 3
  m11706 K5 Genesis-Weg maxrss GANZ=11 / GANZ=12 (berichtet) | 73976 73936 74144 / 73664 73804 75824 KB (keine Wirkung auf die Spitze) | aus/an | s1 | 6
  m11707 K5 Rot des Messgeraets | 63052 KB mit 50 MB, 11756 KB ohne | Werkzeug | - | 2
  m11708 Rundweg K5b Ausgabe | 759ba426 = Eingabe (alle 6) | Werkzeug | s1 | 6
  Quelle: rechner-a:~/snai_pruef/fullint8/log/hb12_aus.log, log/HB12_*.log (hb12_aus.sh, proj_hb = Hauptbaum nach Stufe 12, Lib dca24a87)
  m11709 Aus-Probe Hauptbaum nach Uebernahme Stufe 12 (cortex.nim 4e192007, cortex_gz.nim ae179d20, Lib dca24a87), Schalter ungesetzt: Kurzlauf / 2 Worker / Segment 0 | 0f79d04c / 3eb4a5f8 / 7063ce99 (= Bezug), rc 0, STEPS_DONE 232/116/5001, keine GZ-Zeile; lokal committet 6539a6c | HB12 | 1 | 3
Ergebnis e692 [2026-11-16 05:05]: erfuellt
  Fazit: Mit SNAI_I8_GZ_GFREI traegt der Ganzzahlpfad die float32-Gradientenpuffer der Matrizen nicht mehr mit: bytegleich zu ausgeschaltet (auch Segment 0 in naechster und auf = 6a544467), Speicherspitze im fortgesetzten Training -2.067 KB je Prozess (104 % der erwarteten 4 B je Gewicht), Sperre bricht in beiden Wegen laut ab. Erfuellt erst nach einem Reparaturversuch: in Lauf 1 gab die Sperre nur -1 zurueck, und train_worker.php trainierte im Genesis-Weg still weiter. Der README-Posten "ungenutzter float32-Gradientenpuffer" ist damit erledigt. Folge ueber die Stufe hinaus: train_worker.php wertet -1 von cortex_train_step_i8 generell nicht aus (alle FATAL-Wege) - Entscheidung beim Autor.
  Offen: Genesis-Weg: Spitze unveraendert (liegt beim Quantisieren). LoRA und Karte nur ueber den Code. prod512b-Ersparnis nur hochgerechnet (~100 MB). Rueckgabe -1 in train_worker.php unbehandelt.
  Datei: rechner-a:~/snai_pruef/fullint8/ERGEBNIS_ST12.md
Chronik:
  2026-11-16 04:23 angelegt
  2026-11-16 04:49 Messwerte m11677-m11685
  2026-11-16 04:49 Status geplant -> laeuft (Messwerte m11677-m11685)
  2026-11-16 05:05 Messwerte m11693-m11708
  2026-11-16 05:05 Ergebnis e692: erfuellt
  2026-11-16 05:05 Status laeuft -> ausgewertet (Ergebnis e692)
  2026-11-16 05:13 Messwerte m11709
```
