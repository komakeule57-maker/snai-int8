# snai/merkmal-zerl

```text
snai/merkmal-zerl - ausgewertet, begonnen 2026-10-17, angelegt 2026-10-21, zuletzt 2026-10-21 19:18
Frage: Welcher Teil des int8-Trainingspfads ist fuer den Embedding-Kollaps (Sprung s4 -> s5, d96 Schach) noetig? Je Arm genau ein Teil auf float: Momente (M), FFN-Aktivierungen (A), Rueckwaerts (B), Gradientenakkumulation (G), alle vier (R); Gegenrichtung ohne Fehler-Rueckfuehrung (E).
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/zerl/kriterien_zerl.txt, Kopf '2026-10-17, VOR dem Start', Nachtrag vor dem Start ~09:13):
  Je Arm, Endstand s5, Saat 1 und 3 (Original F 28,4 / 37,2 %): TEIL NOETIG = F < 5 % in BEIDEN Saaten; TEIL NICHT NOETIG = F >= 15 % in BEIDEN; sonst kein Urteil. Pflichtkontrolle: L > 10 % vom Original -> kein Urteil fuer den Arm. R >= 15 % in beiden -> 'int8-Gewichte allein reichen'; R < 5 % in beiden -> 'Gewichte allein reichen nicht'. Nachtrag vor dem Start (09:13): Arm E (SNAI_I8_FEHLER_RUECK=0) in Saat 1, 2, 3 als Spiegelprobe. n = 2 Saaten = Beobachtung mit zwei Wiederholungen.
Baut auf: snai/merkmal-runde4
Darauf baut: snai/merkmal-ratsche, snai/merkmal-reihe, snai/merkmal-zerl-g2, snai/merkmal-prodtest, snai/merkmal-sr, snai/merkmal-zerl-verl, snai/gradnorm-zerlegung
Rezepte:
  r132 [2026-10-21] bash ~/snai_pruef/merkmal/zerl/lauf_zerl.sh <M|A|B|G|R|E> <saat> (ueber warteschlange.sh, max. 8 gleichzeitig; Schalter z. B. SNAI_I8_MOMENTE_8BIT=0, SNAI_I8_AKT_8BIT=0, SNAI_I8_INT_BACKWARD=0, SNAI_I8_INT_GRADACC=0, SNAI_I8_FEHLER_RUECK=0; php train_cluster.php factory/input/gross_c64_seg5.txt factory/checkpoints/gross_gross_s<S>_s5.snai 1 1 <start gross_gross_s<S>_s4> 3 0.001 0.0001 1 0.1 mit SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=727208)
      quelltext: Kopien knirps/proj_zerl_<arm>_s<S> aus proj_zerl_basis (= proj_spaet_s1 ohne Laeufe + patch_zerl.py, train_worker.php 8fa886f8), libcortex.so 28eeffe0; lauf_zerl.sh 5f95053c, patch_zerl.py d6fe721b, bank_zerl.sh 9ee84aa0 (Bank: Vorgabe 10a1ee05 = Original, jeder Schalter verschieden)
      parameter: d96 Schach, ein Segment s4 -> s5 ab Original gross_gross_s<S>_s4 (adam_t 466470), LR 0,001 Cosinus bis 727208 (im Segment 3,57e-4 -> ~2e-4), Warmup 500, WD 0,1 ueberall, gebunden, int8 FULL, Revival und Lade-Waechter aus, CPU OMP 1
      seed: Saat 1 und 3 (E auch 2); Ausgabename wie Original (gepaart)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/zerl/log/, spaet/mess_zerl<arm>_s<S>.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/spaet/mess_zerl{M,A,B,G,R,E}_s<S>.jsonl (am 2026-10-21 nachgelesen)
  m1425 F | 2,0 % (L 1,383; 0 tot) | M Momente float | 1 | 500
  m1426 F | 1,0 % (L 1,418; 0 tot) | M Momente float | 3 | 500
  m1427 F | 30,8 % (23 tot) | A Aktivierungen float | 1 | 500
  m1428 F | 37,2 % (40 tot) | A Aktivierungen float | 3 | 500
  m1429 F | 2,4 % (L 1,339) | B Rueckwaerts float | 1 | 500
  m1430 F | 2,2 % (L 1,337) | B Rueckwaerts float | 3 | 500
  m1431 F | 4,2 % (L 1,348) | G Gradakk. float | 1 | 500
  m1432 F | 4,2 % (L 1,350) | G Gradakk. float | 3 | 500
  m1433 F | 3,0 % | R alle vier float | 1 | 500
  m1434 F | 3,2 % | R alle vier float | 3 | 500
  m1435 F / L | 28,4 % / 1,638 (+18 %) | E ohne Fehler-Rueckfuehrung | 1 | 500
  m1436 F / L | 17,8 % / 1,550 | E ohne Fehler-Rueckfuehrung | 2 | 500
  m1437 F / L | 11,8 % / 1,613 | E ohne Fehler-Rueckfuehrung | 3 | 499
  m1438 F (Bezug) | 28,4 % | Original | 1 | 500
  m1439 F (Bezug) | 37,2 % | Original | 3 | 500
Ergebnis e126 [2026-10-21 19:18]: erfuellt
  Fazit: Drei Teile sind je fuer sich noetig: 8-Bit-Momente, Ganzzahl-Rueckwaerts und Ganzzahl-Gradakkumulation (G knapp, 4,2 %); die Aktivierungen nicht, die int8-Gewichte allein auch nicht. Das grenzte die Ursache auf den Gradienten-/Momentenpfad ein. Offen blieb, ob nicht jede grosse Bahnaenderung rettet; das pruefen snai/merkmal-reihe (Reihenfolge: rettet nicht) und snai/merkmal-rauschen (gemischt). Die konkrete Rechenoperation (v-Ratsche) fand erst snai/merkmal-sr;: nach dem Eingrenzen gleich die Operation suchen. Folge fuer die Produktion: prod512b lief ab Segment 2 mit float-Momenten.
  Offen: E: Loss-Kontrolle verletzt (+14..18 %), kein Urteil, anderes Fehlerbild (kaum tote Zeilen). Saat 2 fuer M/A/B/G/R nicht gefahren.
  Datei: rechner-a:~/snai_pruef/merkmal/zerl/kriterien_zerl.txt
Chronik:
  2026-10-21 19:17 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/zerl/kriterien_zerl.txt, Kopf '2026-10-17, VOR dem Start', Nachtrag vor dem Start ~09:13)
  2026-10-21 19:18 Rezept r132
  2026-10-21 19:18 Status geplant -> laeuft (Rezept r132)
  2026-10-21 19:18 Messwerte m1425-m1439
  2026-10-21 19:18 Ergebnis e126: erfuellt
  2026-10-21 19:18 Status laeuft -> ausgewertet (Ergebnis e126)
```
