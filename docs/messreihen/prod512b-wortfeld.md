# snai/prod512b-wortfeld

```text
snai/prod512b-wortfeld - ausgewertet, angelegt 2026-10-30, zuletzt 2026-10-30 14:26
Frage: Wird in prod512b ein Zielwort wahrscheinlicher, wenn ein Themenwort ausserhalb der Trigramm-Reichweite im Kontext stand, und ab welchem Stand?
Kriterium (festgelegt 2026-10-30 14:01, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/wortfeld_p/kriterien.txt (ee2ab955). Kennzahl und Urteil wortgleich snai/geschichten-wortfeld: F = exp(D) gegen Neutralwoerter und Kontrollziele, VERBINDUNG F >= 1,5 und KI-Untergrenze >= 1,1, GEGENTEIL spiegelbildlich, KEINE 1/1,1 < F < 1,1, sonst UNKLAR, A/A >= 1,5 nicht auswertbar. Relationen: Schiff-Hafen (Positivkontrolle), Hafen-Schiff, Regen-Wasser, Wasser-Regen, Wasser-Fluss, Arzt-Hafen (Lift 0,40, keine Verbindung erwartet). Gueltig nur wenn Genesis 3 Saaten nirgends VERBINDUNG und Positivkontrolle auf s7 VERBINDUNG. Eine Saat, also Beobachtung. nass und Jacke im prod512b-Korpus zu selten und keine Einzeltoken, nicht messbar.
Plan: rechner-b:~/snai_pruef/wortfeld_p/kriterien.txt
Baut auf: snai/geschichten-wortfeld, snai/prod512b-lauf
Darauf baut: snai/prod512b-wortfeld2
Rezepte:
  r471 [2026-10-30] rechner-b: cd ~/snai_pruef/wortfeld_p && ./lauf_p.sh (sonde_p.php 563576d1, lauf_p.sh 87d30a53, cwd ~/snai_prod512b, SNAI_CORTEX_LIB=libcortex_prod.so 318b2655, 1 Thread; Staende t1000 0a6be185, t5000 f306b0e2, s0 de325fec, s4 751d92d9, s7 d28ae3f8; Genesis gen_s1-3 aus init_base.php 0 512 1024 6 2048 <s>)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/wortfeld_p/log/auswertung.txt, log/vorhersage.txt
  m6595 F Schiff-Hafen | 9,21 | s7 | 1
  m6596 A/A Schiff-Hafen | 1,98 | s7 | 1
  m6597 F Hafen-Schiff | 4,34 | s7 | 1
  m6598 A/A Hafen-Schiff | 1,69 | s7 | 1
  m6599 F Regen-Wasser | 0,89 | s7 | 1
  m6600 A/A Regen-Wasser | 2,57 | s7 | 1
  m6601 F Wasser-Regen | 3,19 | s7 | 1
  m6602 A/A Wasser-Regen | 1,36 | s7 | 1
  m6603 F Wasser-Fluss | 5,19 | s7 | 1
  m6604 A/A Wasser-Fluss | 1,34 | s7 | 1
  m6605 F Arzt-Hafen | 0,25 | s7 | 1
  m6606 A/A Arzt-Hafen | 2,78 | s7 | 1
  m6607 F Schiff-Hafen | 19,22 | s4 | 1
  m6608 A/A Schiff-Hafen | 1,39 | s4 | 1
  m6609 F Wasser-Fluss | 5,12 | s4 | 1
  m6610 F Wasser-Regen | 2,22 | s4 | 1
  m6611 F Schiff-Hafen | 2,44 | s0 | 1
  m6612 F Wasser-Fluss | 4,03 | s0 | 1
  m6613 F Wasser-Regen | 1,56 | s0 | 1
  m6614 F Schiff-Hafen | 1,00 | t5000 | 1
  m6615 F Wasser-Fluss | 1,07 | t5000 | 1
  m6616 F Schiff-Hafen | 0,91 | t1000 | 1
  m6617 F Wasser-Fluss | 1,03 | t1000 | 1
  m6618 F Genesis alle Relationen | 1,00 | genesis | 1
  m6619 F Genesis alle Relationen | 1,00 | genesis | 2
  m6620 F Genesis alle Relationen | 1,00 | genesis | 3
  m6621 Korpus-Vorhersage Schiff-Hafen | 25,60 | korpus
  m6622 Korpus-Vorhersage Wasser-Fluss | 10,98 | korpus
  m6623 Korpus-Vorhersage Wasser-Regen | 7,34 | korpus
  m6624 Korpus-Vorhersage Regen-Wasser | 7,48 | korpus
Ergebnis e412 [2026-10-30 14:26]: ungueltig
  Fazit: Nach dem Wortlaut ungueltig: Die Positivkontrolle Schiff-Hafen auf s7 hat F 9,21, aber der A/A-Boden 1,98 liegt ueber der festen Grenze 1,5. Der Boden steigt mit dem Training (t1000 bis 1,07, s7 bis 2,78), eine feste Grenze passt fuer grosse Modelle also nicht. Zweite Lesart: Wasser-Fluss 5,19 und Wasser-Regen 3,19 sind auf s7 VERBINDUNG, sichtbar ab s0 (10,8 Mio Token), bei 5.000 Schritten nichts. Das passt zum Knirps, ist aber kein Beleg. Regen-Wasser zeigt nichts (0,89), anders als beim Knirps. Vor einer Entscheidung fuer prod512b neue Reihe: bessere Neutralwoerter, Saetze im Korpusstil, Boden relativ zum Effekt, frische Saetze. Wortfeld nass/Jacke im prod512b-Korpus nicht pruefbar.
  Offen: Neue Reihe mit nachgebesserter Sonde; warum Regen-Wasser fehlt; ob die Schiff-Hafen-Faktoren von s4 auf s7 wirklich fallen; weitere Saaten gibt es fuer prod512b nicht.
  Datei: rechner-b:~/snai_pruef/wortfeld_p/ERGEBNIS_wortfeld_prod512b.md
Chronik:
  2026-10-30 14:01 angelegt
  2026-10-30 14:26 Rezept r471
  2026-10-30 14:26 Status geplant -> laeuft (Rezept r471)
  2026-10-30 14:26 Messwerte m6595-m6624
  2026-10-30 14:26 Ergebnis e412: ungueltig
  2026-10-30 14:26 Status laeuft -> ausgewertet (Ergebnis e412)
```
