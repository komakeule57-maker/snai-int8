# snai/merkmal-prodtest

```text
snai/merkmal-prodtest - ausgewertet, begonnen 2026-10-17, angelegt 2026-10-21, zuletzt 2026-10-21 19:19
Frage: Kosten die Abhilfe-Kandidaten (Gradientenakkumulation float PG, Momente float PM) bei prod512b mehr als 10 % Zeit oder Speicher gegenueber der Vorgabe?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/prodtest/kriterien_prodtest.txt, Kopf '2026-10-17, VOR der Messung' (Freigabe 'Freigabe erteilt'); dieselbe Datei enthaelt danach die Einsaetze auf vserver (M 2026-10-17, SR-Bibliothek 2026-10-18, SR scharf 2026-10-19)):
  Je Kandidat gegen P0 (Vorgabe), lokal, 33 Schritte ab prod512b-Stand: Zeit je Schritt und Spitzenspeicher; unter 10 % relativ = Gleichstand, sonst MEHRKOSTEN. Wiederholung P0b als Rauschmass. Nur Kosten, nicht Wirkung gegen den Kollaps.
Baut auf: snai/merkmal-zerl
Rezepte:
  r140 [2026-10-21] P0, P0b, PG, PM: bash ~/snai_pruef/merkmal/prodtest/bench.sh (Arme P0, P0b, PG mit SNAI_I8_INT_GRADACC=0, PM mit SNAI_I8_MOMENTE_8BIT=0; 33 Schritte ab prod512b-Stand, OMP 4)
      quelltext: prodtest/proj = tg1-Code + patch_zerl.py; bench.sh 6153f06d, miss.py a2c89acb
      parameter: prod512b-Rezept (dim 512, gebunden, int8 FULL, WD 0,1), 33 Schritte, OMP 4
      seed: wie prod512b (Laufname)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/prodtest/log/
  r141 [2026-10-21] Einsatz M: Tausch train_worker.php auf vserver (mv), Abnahme lokal (Rot-Probe SNAI_I8_MOMENTE_8BIT=1 -> md5 P0) und auf tg1 (s2.log Engine-Zeile)
      quelltext: einsatz/train_worker.php f3e76849 (tg1-Stand d518ac25 + patch_zerl.py + Vorgabe Momente float)
      parameter: Einsatz M ab Segment 2 von prod512b
      seed: -
      rechner: vserver
      logs: rechner-a:~/snai_pruef/merkmal/prodtest/einsatz/log/
      notiz: Abnahme, keine Messreihe; als zweites Rezept vermerkt, weil die Kostenmessung hier ihren Zweck hatte
  r142 [2026-10-21] SR scharf: bash ~/snai_pruef/merkmal/prodtest/bank_sr_tg1.sh bzw. scharf/bank_scharf.sh (33 Schritte ab prod512b_s0, OMP 4); danach Tausch train_worker.php auf vserver
      quelltext: SR-Bibliothek 318b2655 (tg1 cortex.nim 99fbe7d7 + patch_sr.py, auf tg1 gebaut; ungepatcht df71bc14 = laufende Bibliothek); scharf: train_worker.php 0abdb805 (scharf/patch_scharf.py); bank_sr_tg1.sh 123cff4f
      parameter: SR mv als Vorgabe auf tg1 ab Segment 3
      seed: -
      rechner: vserver, rechner-a (Abnahme)
      logs: rechner-a:~/snai_pruef/merkmal/prodtest/log_sr/, prodtest/scharf/log/
      notiz: Abnahme; die Erholungsregel ab s3 fuehrt der Helfer prod als snai/prod512b-sr-erholung
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/prodtest/kriterien_prodtest.txt und prodtest/log/ (Bench); tg1-Werte aus den dort zitierten Logs (nicht neu gelesen)
  m1543 Zeit je Schritt | 9,31 s | P0 |  | 33
  m1544 Zeit je Schritt | 9,41 s | P0b |  | 33
  m1545 Zeit je Schritt | 12,79 s (+37 %) | PG |  | 33
  m1546 Zeit je Schritt | 8,97 s (-4 %) | PM |  | 33
  m1547 Spitzenspeicher | 732,7 MB | P0 |  | 1
  m1548 Spitzenspeicher | 729,0 MB | PG |  | 1
  m1549 Spitzenspeicher | 849,4 MB (+16 %) | PM |  | 1
  m1550 md5 nach 33 Schritten | P0 = P0b fb24ec52, PG 45843812, PM 992f1cb7 | alle |  | 1
  m1551 Tempo tg1 s/Schritt | s1 16,0 gegen s2 15,9 (Gleichstand) | Einsatz M |  | 10
  m1552 Worker-RSS tg1 | 1.098 MB | Einsatz M (s2) |  | 1
  m1553 Tempo tg1 s/Schritt | 16,2 gegen 15,5 (+4 %, Gleichstand) | SR scharf s3 gegen s2 |  | 330
  m1554 Worker-RSS tg1 | 950 MB (-13 % gegen float-Momente) | SR scharf (s3) |  | 1
Ergebnis e134 [2026-10-21 19:19]: erfuellt
  Fazit: Beide Kandidaten kosten mehr als 10 %, aber an verschiedener Stelle: float-Gradakkumulation kostet Zeit (+37 %), float-Momente kosten Speicher (+16 %, absolut ~117 MB). Deshalb ging zuerst M auf vserver (Speicher ist dort kein Engpass, Tempo gleich). Mit SR mv gibt es seit 2026-10-19 einen Weg ohne beide Kosten: 8-Bit-Momente, Tempo im Rauschen, Speicher sogar 13 % unter M. Ein float-Kandidat muss fuer prod512b nicht mehr erwogen werden.
  Offen: Bench nur lokal, OMP 4, 33 Schritte, ein Startstand; Hochrechnung auf tg1 nicht gemessen. Ob SR auf tg1 netto Fortschritt bringt, entscheidet die Erholungsregel (snai/prod512b-sr-erholung).
  Datei: rechner-a:~/snai_pruef/merkmal/prodtest/kriterien_prodtest.txt
Chronik:
  2026-10-21 19:19 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/prodtest/kriterien_prodtest.txt, Kopf '2026-10-17, VOR der Messung' (Freigabe 'Freigabe erteilt'); dieselbe Datei enthaelt danach die Einsaetze auf vserver (M 2026-10-17, SR-Bibliothek 2026-10-18, SR scharf 2026-10-19))
  2026-10-21 19:19 Rezept r140 (P0, P0b, PG, PM)
  2026-10-21 19:19 Status geplant -> laeuft (Rezept r140)
  2026-10-21 19:19 Rezept r141 (Einsatz M)
  2026-10-21 19:19 Rezept r142 (SR scharf)
  2026-10-21 19:19 Messwerte m1543-m1554
  2026-10-21 19:19 Ergebnis e134: erfuellt
  2026-10-21 19:19 Status laeuft -> ausgewertet (Ergebnis e134)
```
