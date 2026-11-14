# snai/schach-kollaps-trennung

```text
snai/schach-kollaps-trennung - ausgewertet, begonnen 2026-10-16, angelegt 2026-10-21, zuletzt 2026-10-21 19:18
Frage: Formkollaps im grossen d96-Schachlauf isolieren: Liegt er an der Dauer (3,8-mal so viele Schritte, und damit mehr Wiederholungen je Stellung) oder am Material (153k statt 40k Stellungen)? Gepaartes 2x2-Gitter mit den neuen Zellen C 'gross_kurz' und D 'klein_lang'. Dazu: bestaetigt sich die Fruehwarnregel aus der Loss-Kurve?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_schach_trennung.txt samt Nachtrag 1 nach dem Pruefer (laut Text vor dem ersten Lauf, 2026-10-16; mtime 05:58, Laeufe ab 06:04). Kein festgehaltenes Ergebnis gefunden.):
  Formfehler am Endstand (form_sonde.py, 1.000 Ziehungen T 1,0): KOLLABIERT > 15 %, FORMTREU < 5 %, dazwischen unklar. (1) Dauer ist Ursache, wenn in D >= 2 von 3 Saaten kollabieren UND in C keine. (2) Material, wenn C >= 2 von 3 UND D keine. (3) Beides noetig, wenn weder C noch D. (4) Jedes Rad genuegt allein, wenn beide >= 2 von 3. (5) Sonst kein Schluss -> je Zelle zwei Saaten nachlegen (Genesis 4, 5). Fruehwarnsonde: Vorhersage allein aus der Loss-Kurve (Anstieg > +0,005 zwischen zwei Segmenten = Kollaps), aufgeschrieben in gebiete/vorhersage_trennung.txt BEVOR die Form angesehen wird; bestaetigt bei >= 5 von 6 richtig, widerlegt bei >= 2 Fehlern.
Baut auf: snai/schach-gross
Rezepte:
  r134 [2026-10-21] bash kette_trennung.sh gk|kl (je Saat: PRE=grosskurz|kleinlang VOK=schach setsid nohup bash lauf_material.sh <Z>_s<S> 0.001 8 factory/checkpoints/gross_gen_s<S>.snai 194800|727208); Korpus bau_trennung.py c|d; je Segment 500 Ziehungen (ziehe_schach.php 500 1.0 4711) -> form_verdeckt.py; Endstand 1.000 Ziehungen + schach.py --streng 0.70 0.15 + kontext_sonde.py
      quelltext: proj_ow: cortex.nim 7b67236c, libcortex.so 563780e3 (gebaut 2026-10-13), train_worker.php af8e0a4f, train_cluster.php 2db1564a (md5 heute gelesen); kette_trennung.sh ef1e9640, lauf_material.sh db41d2a1, form_sonde.py 4f7d130f (md5 heute)
      parameter: d96, wie snai/schach-gross; C: 8 Segmente a 39.991 Zeilen aus dem grossen Pool, ~24.372 Schritte je Segment, DECAY 194.800; D: 8 Segmente a 153.086 Zeilen aus den 39.991 Leiter-Stellungen blockweise wiederholt, ~93.218 Schritte je Segment, DECAY 727.208; Genesis je Saat bitgleich zu Leiter und gross
      seed: Genesis 1, 2, 3; Permutation 20261016; Ziehsaat 4711
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/gebiete/gk_s<S>.*, kl_s<S>.*, kette_gk.log, kette_kl.log, form_verdeckt.jsonl, ziehungen.jsonl, kontext_verdeckt_gk.json, kontext_verdeckt_kl.json
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/gebiete/form_verdeckt.jsonl, ziehungen.jsonl, kontext_verdeckt_*.json, gk_s<S>.mess.jsonl und kl_s<S>.mess.jsonl - alles am 2026-10-21 aus den Rohdaten ausgewertet (es gibt keine Ergebnisdatei); bei B (unter den legalen) ist n die Zahl der legalen Stellungen = A x 1000
  m1448 Formfehler Endstand | 2,0 % | C gross_kurz | 1 | 1000
  m1449 Formfehler Endstand | 1,1 % | C gross_kurz | 2 | 1000
  m1450 Formfehler Endstand | 2,9 % | C gross_kurz | 3 | 1000
  m1451 Formfehler Endstand | 31,3 % | D klein_lang | 1 | 1000
  m1452 Formfehler Endstand | 35,2 % | D klein_lang | 2 | 1000
  m1453 Formfehler Endstand | 27,0 % | D klein_lang | 3 | 1000
  m1454 Formfehler Endstand (Bezug) | 2,5 % | A Leiter-d96 | 1 | 1000
  m1455 Formfehler Endstand (Bezug) | 1,2 % | A Leiter-d96 | 2 | 1000
  m1456 Formfehler Endstand (Bezug) | 2,0 % | A Leiter-d96 | 3 | 1000
  m1457 Formfehler Endstand (Bezug) | 34,6 % | B gross | 1 | 1000
  m1458 Formfehler Endstand (Bezug) | 0,2 % | B gross | 2 | 1000
  m1459 Formfehler Endstand (Bezug) | 37,7 % | B gross | 3 | 1000
  m1460 Formfehler nach Segment 5 | 16,8 % | D klein_lang | 1 | 500
  m1461 Formfehler nach Segment 5 | 6,6 % | D klein_lang | 2 | 500
  m1462 Formfehler nach Segment 5 | 25,2 % | D klein_lang | 3 | 500
  m1463 groesster Loss-Anstieg zwischen Segmenten | keiner (max -0,0043 / -0,0057 / -0,0112) | C gross_kurz | 1/2/3 | 300
  m1464 groesster Loss-Anstieg zwischen Segmenten | +0,0058 | D klein_lang | 1 | 300
  m1465 groesster Loss-Anstieg zwischen Segmenten | +0,0057 | D klein_lang | 2 | 300
  m1466 groesster Loss-Anstieg zwischen Segmenten | +0,0134 | D klein_lang | 3 | 300
  m1467 Fruehwarnregel rueckblickend richtig | 6 von 6 | C+D | 1-3
  m1468 A legal je Ziehung | 58,2 % | C gross_kurz | 1 | 1000
  m1469 A legal je Ziehung | 56,1 % | C gross_kurz | 2 | 1000
  m1470 A legal je Ziehung | 61,4 % | C gross_kurz | 3 | 1000
  m1471 A legal je Ziehung | 30,5 % | D klein_lang | 1 | 1000
  m1472 A legal je Ziehung | 31,3 % | D klein_lang | 2 | 1000
  m1473 A legal je Ziehung | 32,2 % | D klein_lang | 3 | 1000
  m1474 B unter den legalen | 12,5 % | C gross_kurz | 1
  m1475 B unter den legalen | 15,3 % | C gross_kurz | 2
  m1476 B unter den legalen | 13,4 % | C gross_kurz | 3
  m1477 B unter den legalen | 17,0 % | D klein_lang | 1
  m1478 B unter den legalen | 10,2 % | D klein_lang | 2
  m1479 B unter den legalen | 13,4 % | D klein_lang | 3
  m1480 Kontext-Sonde alle vier | 66,2 % | C gross_kurz | 1 | 1000
  m1481 Kontext-Sonde alle vier | 64,1 % | C gross_kurz | 2 | 1000
  m1482 Kontext-Sonde alle vier | 71,8 % | C gross_kurz | 3 | 1000
  m1483 Kontext-Sonde alle vier | 34,2 % | D klein_lang | 1 | 1000
  m1484 Kontext-Sonde alle vier | 36,4 % | D klein_lang | 2 | 1000
  m1485 Kontext-Sonde alle vier | 36,2 % | D klein_lang | 3 | 1000
  m1486 Rot-Probe Loss gemischt | 8,47 | C gross_kurz | 1 | 300
  m1487 Rot-Probe Loss gemischt | 11,37 | C gross_kurz | 2 | 300
  m1488 Rot-Probe Loss gemischt | 8,51 | C gross_kurz | 3 | 300
  m1489 Rot-Probe Loss gemischt | 8,60 | D klein_lang | 1 | 300
  m1490 Rot-Probe Loss gemischt | 9,19 | D klein_lang | 2 | 300
  m1491 Rot-Probe Loss gemischt | 10,31 | D klein_lang | 3 | 300
  m1492 Engine-Fehler | 0 | C+D | 1-3 | 6000
Ergebnis e128 [2026-10-21 19:18]: erfuellt
  Fazit: Fall (1) der Vorab-Regel: D 'klein_lang' kollabiert in 3 von 3 Saaten (27-35 % Formfehler), C 'gross_kurz' bleibt in 3 von 3 formtreu (1-3 %). Der Kollaps haengt an der Dauer (Schritte samt Wiederholungen je Stellung), nicht am Material - so vorhergesagt. Das passt zum spaeter isolierten Mechanismus: die Rundungs-Ratsche der 8-Bit-Adam-Momente sammelt sich ueber Schritte an; Schritt- und Wiederholungszahl bleiben in diesem Aufbau gekoppelt. Fuer kuenftige Laeufe: lange int8-Laeufe ueber ~400k Schritte nicht ohne quant_sonde/Formmessung zitieren. Die Fruehwarnregel trifft rueckblickend 6 von 6 neuen Laeufen, ihr Blindprotokoll ist aber nicht belegt (siehe offen).
  Offen: Die vorab verlangte Vorhersagedatei gebiete/vorhersage_trennung.txt existiert nicht; ob die Loss-Vorhersage vor dem Blick auf die Form aufgeschrieben wurde, ist nicht belegbar (die Formzahlen wurden verdeckt geschrieben). Fruehwarnregel daher nur rueckblickend geprueft, und an gross_s2 gibt es einen Fehlalarm im ersten Segment (snai/schach-gross). Kein Ergebnis wurde in ERGEBNIS_sichtung.md oder in die Arbeitsnotizen geschrieben.
  Datei: rechner-a:~/snai_pruef/knirps/gebiete/kriterien_schach_trennung.txt (keine Ergebnisdatei)
Chronik:
  2026-10-21 19:18 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_schach_trennung.txt samt Nachtrag 1 nach dem Pruefer (laut Text vor dem ersten Lauf, 2026-10-16; mtime 05:58, Laeufe ab 06:04). Kein festgehaltenes Ergebnis gefunden.)
  2026-10-21 19:18 Rezept r134
  2026-10-21 19:18 Status geplant -> laeuft (Rezept r134)
  2026-10-21 19:18 Messwerte m1448-m1492
  2026-10-21 19:18 Ergebnis e128: erfuellt
  2026-10-21 19:18 Status laeuft -> ausgewertet (Ergebnis e128)
```
