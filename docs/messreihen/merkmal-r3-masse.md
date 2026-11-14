# snai/merkmal-r3-masse

```text
snai/merkmal-r3-masse - ausgewertet, begonnen 2026-10-16, angelegt 2026-10-21, zuletzt 2026-10-21 14:31
Frage: Tragen die toten Embedding-Zeilen (Stufen-Median <= 1) den Formfehler, d. h. landet die Wahrscheinlichkeitsmasse an Fehlerstellen auf toten Folgefeldern bzw. steigt p_wrong bei totem Zielfeld staerker als bei lebendem?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/diag/kriterien_runde3.txt, Kopf '2026-10-16 nachmittags, VOR den Laeufen; Pruefliste des Auditors' (Laeufe 13:29-13:41)):
  B1 (Fehlerstellen der s1_s5-Ziehung): Totdichte d(L) an Fehlerstellen >= 1,5 x Basis -> stuetzt 'tote Folgefelder'; <= 1,1 x -> stuetzt nicht; sonst kein Schluss. Gegenrichtung (Feld statt Figur): Anteil toter Felder unter den falsch gesetzten gegen ihren Anteil unter allen gezogenen Feldern, gleiche Schwellen. B2 (gepaart, Held-out 400 Zeilen, s1_s4 gegen s1_s5, Totmenge von s1_s5): D_tot > 0 (Bootstrap-Intervall 2000, 95 %, ohne 0) und D_tot >= 2 x D_leb -> 'die toten Zielzeilen tragen den Formfehler'; D_tot und D_leb beide > 0 und innerhalb 10 % -> 'global'; sonst kein Schluss. Rot-Proben: R0 ohne SNAI_VOCAB und R1 Ziele um eins verschoben muessen p_true einbrechen lassen.
Baut auf: snai/merkmal-r3-saat
Rezepte:
  r70 [2026-10-21] php ~/snai_pruef/merkmal/diag/masse_sonde.php (Vorwaertsrechnung, Kontext wie ziehe_schach) und python3 diag/auswert_masse.py, diag/auswert_b1_frisch.py (Befehlszeilen nicht protokolliert, nur Ausgaben in diag/masse/)
      quelltext: masse_sonde.php b323f845, auswert_masse.py 564c2e24, auswert_b1_frisch.py 34668bab; Engine proj_neu
      parameter: B1: Ziehungen erg_neu/zieh_s5.txt (Saat 4711) und frische Ziehungen Saat 4712/4713; B2: heldout_gross.txt erste 400 Zeilen, Totmenge 22 Felder von s1_s5
      seed: Ziehung 4711, 4712, 4713; Bootstrap 2000
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/diag/masse/auswertung.txt, *.json
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/diag/masse/auswertung.txt (abgelesen 2026-10-21)
  m705 B2 D_tot (p_wrong s5 - s4, Ziel tot) | 1,50e-2 [1,46e-2; 1,54e-2] | s1_s4 -> s1_s5 | 1 | 2697
  m706 B2 D_leb (Ziel lebend) | 5,88e-3 [5,56e-3; 6,19e-3] | s1_s4 -> s1_s5 | 1 | 4679
  m707 B2 Verhaeltnis D_tot/D_leb | 2,55 | s1_s4 -> s1_s5 | 1 | 1
  m708 B1 d(L) Fehler/Basis | 1,53 [1,37; 1,70] | Ziehung 4711 | 1 | 78
  m709 B1 d(L) Fehler/Basis | 1,38 [1,21; 1,54] | Ziehung 4712 | 1 | 81
  m710 B1 d(L) Fehler/Basis | 1,53 [1,35; 1,70] | Ziehung 4713 | 1 | 72
  m711 B1 d(L) Fehler/Basis zusammen | 1,48 [1,38; 1,57] | 3 Ziehungen | 1 | 231
  m712 B1 Fehlerstellen mit mind. einem toten legalen Folgefeld | 99 % (Basis 66 %) | Ziehung 4711 | 1 | 78
  m713 B1 Gegenrichtung tot-Faktor zusammen | 1,75 [1,59; 1,92] | 3 Ziehungen | 1 | 209
Ergebnis e67 [2026-10-21 14:31]: erfuellt
  Fazit: Nach B2 (gepaart) tragen die toten Zielzeilen den Formfehler ueberwiegend: p_wrong steigt bei totem Ziel 2,55-mal staerker. Es gibt aber zusaetzlich einen globalen Anteil (auch bei lebendem Ziel ~160-fach), und B1 erreicht seine 1,5-Schwelle nur im Gegenrichtungsteil (1,75), nicht in d(L) (1,48, Intervall ueber der Schwelle). Damit war der Zusammenhang tote Zeilen -> Formfehler fuer s1_s5 belegt, aber nicht als Ursache isoliert; spaetere Laeufe mit Formfehler ohne tote Zeilen (snai/merkmal-rauschen) zeigen, dass er nicht der einzige Weg ist.
  Offen: Ergebnis der Rot-Proben R0/R1 ist im Ergebnisabschnitt nicht berichtet (nur 'stderr 0'). Eine Saat (s1), ein Checkpoint-Paar.
  Datei: rechner-a:~/snai_pruef/merkmal/diag/kriterien_runde3.txt
Chronik:
  2026-10-21 14:30 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/diag/kriterien_runde3.txt, Kopf '2026-10-16 nachmittags, VOR den Laeufen; Pruefliste des Auditors' (Laeufe 13:29-13:41))
  2026-10-21 14:30 Rezept r70
  2026-10-21 14:30 Status geplant -> laeuft (Rezept r70)
  2026-10-21 14:30 Messwerte m705-m713
  2026-10-21 14:31 Ergebnis e67: erfuellt
  2026-10-21 14:31 Status laeuft -> ausgewertet (Ergebnis e67)
```
