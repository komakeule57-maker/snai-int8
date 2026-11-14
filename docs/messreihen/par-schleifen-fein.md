# snai/par-schleifen-fein

```text
snai/par-schleifen-fein - ausgewertet, angelegt 2026-11-08, zuletzt 2026-11-08 23:03
Frage: Ist der Trainingsschritt mit allen 9 parallelen Gruppen schneller als mit att+sm allein (bisheriger Stand), auch wenn der Gewinn nur wenige Prozent beträgt? Wie groß ist er, mit Intervall?
Kriterium (festgelegt 2026-11-08 18:30, vor dem ersten Messwert):
  Anlass: Vorgabe 2026-11-08 („Selbst 2% sind auf lange Sicht eine echte Einsparung“). snai/par-schleifen löst unter 10 % nicht auf (Wiederholungsrauschen bis 11 %).
Aufbau: rechner-a, Lib par2 c18b7ed7, arm.sh 20790e9b (32 Schritte, n=4, Prod512b-Umgebung). Arme A = SNAI_I8_PAR=att,sm, B = alle (ohne Variable). 24 Blöcke zu A und B direkt nacheinander, Reihenfolge abwechselnd AB/BA (fein.sh 69c3298f), Start nach rot2 der Hauptreihe.
Maß: ms/Schritt aus [Bilanz] je Lauf. Je Block log(B/A); gepaartes t-Intervall 95 % über die 24 Blöcke (t-Quantil per Cornish-Fisher, 2,0684 bei df 23); berichtet wird das geometrische Mittel mit Intervall. Auswertung ausw_fein.py 874e468f.
Urteil: Intervall ganz unter 1 = B schneller (Größe = Intervall); ganz über 1 = B langsamer; sonst nicht aufgelöst, mit Intervallbreite berichtet. KEINE 10-%-Schwelle: auch kleine Gewinne sollen bekannt sein; hier entscheidet das Intervall statt der Schwelle.
Pflicht vor dem Urteil (bricht die Auswertung sonst ab): jeder Lauf md5 6f49622c, Loss-md5 78355d24, rc=0, [PAR]-Zeile passend zum Arm.
Probe der Auswertung vor dem ersten Messwert (Simulation, 24 Blöcke, Rauschen 3 % je Lauf, je 200 Reihen): wahres Verhältnis 1,00 -> 9/200 Fehlurteile (Soll ~5 %); 0,98 -> 126/200 gefunden; 0,97 -> 182/200. Bei 5 % Rauschen 0,98 nur 43/200. Ein „nicht aufgelöst“ heißt also nicht „kein Gewinn“, sondern „unter der Auflösung“; die Auflösung (Intervallbreite) wird mitberichtet. Gegenprobe Waechter: md5 deadbeef bricht ab (gesehen). Erste Fassung mit Bootstrap verworfen (Fehlalarm ~20 % bei 10 Blöcken).
Gemeinsam ändert sich zwischen A und B: nur die Gruppenliste (7 Gruppen dazu). Freier Parameter: Laufänge 32 Schritte, Basis s11.
Baut auf: snai/par-schleifen
Darauf baut: snai/zeitsonde-i8, snai/mm-fwd-blk
Rezepte:
  r635 [2026-11-08] wie r633
      quelltext: fein.sh 69c3298f, ausw_fein.py 874e468f, Lib c18b7ed7
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/par2/ergebnis.txt (Zeilen f*)
      notiz: ABWEICHUNG vor jedem Messwert: Während f0_att,sm (Start 19:29:13) lief 19:30:02–19:30:18 ein Bibliotheksbau (nice 19) auf rechner-a. Block 0 ist damit gestört, die Störung kann nur Arm A verlangsamen (Verzerrung zugunsten B). Auswertung: nach Wortlaut alle 24 Blöcke UND ohne Block 0 (23 Blöcke) nebeneinander; weichen die Urteile ab, gilt die Lesart ohne Block 0 als die saubere, beide werden berichtet.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/threads/par2/ergebnis.txt Zeilen f*, ausw_fein.py 874e468f, 19:29–22:19
  m9652 bytegleich, rc=0, PAR passend | 48/48 | alle Läufe |  | 48
  m9653 Verhältnis alle/att,sm geom. Mittel [95-%-t-Intervall], 24 Blöcke | 0,9390 [0,9302-0,9480] | alle |  | 24
  m9654 Verhältnis alle/att,sm ohne gestörten Block 0, 23 Blöcke | 0,9397 [0,9304-0,9490] | alle |  | 23
  m9655 Streuung je Block (sd log-Verhältnis) | 0,0225 |  |  | 24
  m9656 Blöcke mit alle schneller | 24/24 | alle |  | 24
Ergebnis e574 [2026-11-08 23:03]: erfuellt
  Fazit: Alle 9 Gruppen zusammen sind 6,1 % schneller je Schritt als att+sm allein (Intervall 5,2–7,0 %, 24/24 Blöcke, beide Lesarten gleich), bei bytegleichem Training. Der Gewinn der sieben kleinen Gruppen ist damit echt und lohnt für Langläufe; einzeln waren sie in snai/par-schleifen nicht auflösbar. Die Streuung je Blockpaar (2,3 %) war kleiner als befürchtet: mit diesem Aufbau sind künftig auch ~2-%-Effekte messbar.
  Offen: Welche der sieben Gruppen wie viel beiträgt (einzeln nicht gemessen). Übernahme in den Hauptbaum: wird gesondert entschieden.
Abgeloest und ausgeblendet: 1 rezept - voll=True zeigt sie.
Chronik:
  2026-11-08 18:30 angelegt
  2026-11-08 18:30 Rezept r633
  2026-11-08 18:30 Status geplant -> laeuft (Rezept r633)
  2026-11-08 19:30 Rezept r635, loest r633 ab
  2026-11-08 23:03 Messwerte m9652-m9656
  2026-11-08 23:03 Ergebnis e574: erfuellt
  2026-11-08 23:03 Status laeuft -> ausgewertet (Ergebnis e574)
```
