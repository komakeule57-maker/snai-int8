# snai/att-fwd-par

```text
snai/att-fwd-par - ausgewertet, angelegt 2026-11-08, zuletzt 2026-11-08 15:43
Frage: Bleibt der int8-Trainingsschritt bytegleich, wenn Attention vorwaerts (ueber die Koepfe) und Softmax/Loss/d_logits (ueber die Positionen) parallel laufen, und wie viel schneller wird er bei prod512b-Geometrie?
Kriterium (festgelegt 2026-11-08 14:47, vor dem ersten Messwert):
  Kopie ~/snai_pruef/threads/par/proj = c292c82, cortex.nim per patch_par.py (6ce9f71a, assert auf f8292f7b) -> 6de1a7fe, Lib e49e195e (Bauweise wie Projekt-Lib; das ungepatchte Original baut so 1eb78bc1). Aufbau wie snai/threads-skalierung r627 (text 65b04081, Basis prod512b_s11, fester Ausgabename, prod512b-Umgebung, rechner-a). BEZUG: md5 6f49622c und Loss-Zeilen der ungepatchten Lib (snai/threads-skalierung, 9/9). (G) GUELTIG/BYTEGLEICH nur wenn md5 = 6f49622c UND alle Loss-Zeilen gleich in: parallel n=1/2/4/8 (je 2 Laeufe) und seriell im gepatchten Code (SNAI_I8_ATT_FWD=0 SNAI_I8_SM_PAR=0, n=4). Eine Abweichung = Umbau verworfen. ROT-Proben (muessen md5 != 6f49622c geben): SNAI_I8_ATT_FWD=ROT n=4 und SNAI_I8_SM_PAR=ROT n=4. (T) Tempo: ms/Schritt aus [Bilanz], Mittel aus 2 Laeufen je n, gegen den Bezug derselben Reihe (16.232 / 10.674 / 8.616 / 7.619 ms). SCHNELLER, wenn bei n=4 beide Laeufe >= 10 % unter dem Bezugsmittel liegen; sonst Gleichstand. S(n) neu berichtet.
Baut auf: snai/threads-skalierung
Darauf baut: snai/par-schleifen
Rezepte:
  r628 [2026-11-08] ~/snai_pruef/threads/par/reihe.sh: rot_att (ATT_FWD=ROT n4), rot_sm (SM_PAR=ROT n4), seriell (beide 0, n4), dann 2 x n1/n2/n4/n8 parallel; je arm.sh = train_cluster wie threads-skalierung r627
      quelltext: patch_par.py 6ce9f71a auf cortex.nim f8292f7b -> 6de1a7fe, libcortex.so e49e195e (RUNPATH, ohne nodelete); arm.sh 7fcade30, reihe.sh 1f3e3a8b; Bezug Loss-md5 der Schrittzeilen 78355d24 (threads/log n4_PASSIVE_w1, n1_PASSIVE_w2)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/par/ergebnis.txt, log/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: Quelle | rechner-a:~/snai_pruef/threads/par/ergebnis.txt, log/ (Fehlerkanaele 11/11 leer, Modusmeldung je Lauf im Log)
  m9591 md5 parallel n=1/2/4/8 je 2 Laeufe | 6f49622c in 8/8 (= Bezug) | parallel |  | 8
  m9592 md5 seriell im gepatchten Code (beide Schalter 0, n4) | 6f49622c | seriell |  | 1
  m9593 Loss-md5 der Schrittzeilen | 78355d24 in 11/11 (= Bezug) | alle |  | 11
  m9594 Rot ATT_FWD=ROT n4 md5 | d2cb372c != 6f49622c ROT (Loss-Zeilen gleich: Stoerung 1e-4 an einem Element sieht nur die md5) | rot_att |  | 1
  m9595 Rot SM_PAR=ROT n4 md5 | 90e591b6 != 6f49622c ROT (Loss-Zeilen gleich) | rot_sm |  | 1
  m9596 ms je Schritt n=1 | 16.390,8 / 16.608,2 (Mittel 16.500; Bezug 16.232, +1,6 %) | parallel |  | 2
  m9597 ms je Schritt n=2 | 10.064,7 / 9.661,1 (Mittel 9.863; Bezug 10.674, -7,6 %) | parallel |  | 2
  m9598 ms je Schritt n=4 | 7.327,1 / 6.715,9 (Mittel 7.021; Bezug 8.616, -18,5 %; je Lauf -15,0 / -22,1 %) | parallel |  | 2
  m9599 ms je Schritt n=8 | 6.281,2 / 6.258,8 (Mittel 6.270; Bezug 7.619, -17,7 %) | parallel |  | 2
  m9600 S(2) / S(4) / S(8) gegen eigenes n=1 | 1,67 / 2,35 / 2,63 (vorher 1,52 / 1,88 / 2,13) | parallel |  | 2
Ergebnis e573 [2026-11-08 15:43]: erfuellt
  Fazit: BYTEGLEICH und SCHNELLER nach Wortlaut. Der Umbau rechnet bei 1, 2, 4 und 8 Threads und im seriellen Rueckweg exakt das Modell der ungepatchten Lib (md5 6f49622c, Loss-Zeilen 78355d24, 11/11); beide Rot-Proben schlagen an. Bei 4 Threads ist ein Schritt 18,5 % schneller (8,6 -> 7,0 s, beide Laeufe ueber 10 %), bei 8 Threads 17,7 %, bei 1 Thread Gleichstand. S(4) steigt von 1,88 auf 2,35. Der Gewinn bleibt unter der Amdahl-Schaetzung (Faktor ~1,5): weitere serielle Schleifen je Position (RMSNorm vorwaerts/rueckwaerts, Quantisierung, Embedding, Residualsummen) und vermutlich Speicherbandbreite bleiben. Methodisch: Die Rot-Stoerung (1e-4 an einem Element) aendert keine einzige Loss-Zeile auf 6 Stellen, nur die md5 - Loss-Vergleiche allein haetten einen solchen Fehler nicht gesehen. Uebernahme in den Hauptbaum: wird gesondert entschieden.
  Offen: Nur rechner-a (6 Kerne) gemessen; vserver (4 vCPU) und rechner-b nicht. Nur prod512b-Geometrie (ctx 1024, 8 Koepfe); bei wenigen Koepfen (Knirps 1-2 Koepfe) bringt die Kopf-Parallelisierung der Attention vorwaerts wenig. Kein Lauf ueber mehr als 32 Schritte.
  Datei: rechner-a:~/snai_pruef/threads/par/ergebnis.txt
Chronik:
  2026-11-08 14:47 angelegt
  2026-11-08 14:48 Rezept r628
  2026-11-08 14:48 Status geplant -> laeuft (Rezept r628)
  2026-11-08 15:43 Messwerte m9591-m9600
  2026-11-08 15:43 Ergebnis e573: erfuellt
  2026-11-08 15:43 Status laeuft -> ausgewertet (Ergebnis e573)
```
