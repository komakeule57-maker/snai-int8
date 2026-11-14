# snai/merkmal-r3-saat

```text
snai/merkmal-r3-saat - ausgewertet, begonnen 2026-10-16, angelegt 2026-10-21, zuletzt 2026-10-21 14:30
Frage: Reicht der Aufloesungsverlust der Embeddings (Stufen-Median, Verhaeltnis max/median) allein, um den Formfehler zu erklaeren? Pruefung ueber die kollapsfreie Saat 2 als freie Kontrolle (d96 Schach, Staende s4-s7 aller 3 Saaten).
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/diag/kriterien_runde3.txt, Kopf '2026-10-16 nachmittags, VOR den Laeufen; Pruefliste des Auditors' (Laeufe 13:29-13:41)):
  Teil A: Gleicht ein s2-Stand s1_s5 in ALLEN DREI Massen (Stufen-Median +-1, tote Zeilen und Verhaeltnis max/median je innerhalb 10 %) bei Formfehler < 3 %, dann reicht Aufloesungsverlust (so gemessen) NICHT. Weicht s2 bei den toten Zeilen ab, trennt s2 nicht, und der Schwanz (tote Zeilen) bleibt Kandidat.
Baut auf: snai/merkmal-langlauf-neu
Darauf baut: snai/merkmal-r3-masse, snai/merkmal-r3-grob, snai/merkmal-r3-reihen
Rezepte:
  r67 [2026-10-21] bash ~/snai_pruef/merkmal/diag/lauf_runde3.sh (cwd knirps/proj_neu; miss(): quant_sonde.php --json, mess_text.php heldout_gross 300, ziehe_schach.php 500 1.0 4711, form_sonde.py, diag/zeilen_schach.php)
      quelltext: lauf_runde3.sh 23daf590, ablation_mittel.php 418a36b6, zeilen_schach.php 8cb2ec29, Engine proj_neu libcortex.so 51047037 (Lade-Waechter aus)
      parameter: Checkpoints proj_ow gross_gross_s{1,2,3}_s{4..7}; ohne Training
      seed: Ziehung Saat 4711 (B1 zusaetzlich 4712, 4713)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/diag/r3.log, diag/r3/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/diag/r3.log (Abschnitt A, Skriptausgabe, abgelesen 2026-10-21)
  m670 tote Zeilen s4/s5/s6/s7 | 0/22/45/56 | Original | 1 | 4
  m671 Formfehler s4/s5/s6/s7 | 1,4/28,4/34,4/32,8 % | Original | 1 | 4
  m672 Stufen-Median s4/s5/s6/s7 | 7/3/1/1 | Original | 1 | 4
  m673 Verhaeltnis max/median s5 | 42,3 | Original | 1 | 1
  m674 tote Zeilen s4/s5/s6/s7 | 0/0/0/0 | Original | 2 | 4
  m675 Formfehler s4/s5/s6/s7 | 0,0/0,6/1,4/0,2 % | Original | 2 | 4
  m676 Stufen-Median s4/s5/s6/s7 | 8/6/5/4 | Original | 2 | 4
  m677 Verhaeltnis max/median s4/s5/s6/s7 | 15,9/21,2/25,4/31,8 | Original | 2 | 4
  m678 tote Zeilen s4/s5/s6/s7 | 6/37/48/48 | Original | 3 | 4
  m679 Formfehler s4/s5/s6/s7 | 0,8/37,2/36,8/36,4 % | Original | 3 | 4
  m680 Stufen-Median s4/s5/s6/s7 | 6/2/1/1 | Original | 3 | 4
  m681 Fehlerkanal stderr | 0 | alle 12 Staende Saaten 1-3 |  | 12
Ergebnis e64 [2026-10-21 14:30]: keine_aussage
  Fazit: Saat 2 taugt nicht als Gegenbeispiel: sie erreicht nie tote Zeilen, gleicht s1_s5 also nicht in allen drei Massen, und die Regel laesst die Frage offen. Uebrig bleibt als Kandidat der Schwanz der toten Zeilen (Beobachtung ueber 14 Staende: <= 10 tote Zeilen bei <= 1,4 % Formfehler, >= 22 bei >= 28 %). Diese Kopplung hielt spaeter nicht: SPAET Saat 1 hat 14 tote Zeilen bei 1 %, SPAET Saat 3 27-31 tote bei 8-14 % (snai/merkmal-spaet), RAUSCHEN hat 30 % Formfehler bei 0 toten Zeilen (snai/merkmal-rauschen). Tote Zeilen sind also weder noetig noch hinreichend.
  Offen: Was den Formfehler ausloest, beantworten die Teile B-E (snai/merkmal-r3-masse, -r3-grob, -r3-float) und spaeter snai/merkmal-biasalle.
  Datei: rechner-a:~/snai_pruef/merkmal/diag/kriterien_runde3.txt
Chronik:
  2026-10-21 14:29 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/diag/kriterien_runde3.txt, Kopf '2026-10-16 nachmittags, VOR den Laeufen; Pruefliste des Auditors' (Laeufe 13:29-13:41))
  2026-10-21 14:29 Rezept r67
  2026-10-21 14:29 Status geplant -> laeuft (Rezept r67)
  2026-10-21 14:30 Messwerte m670-m681
  2026-10-21 14:30 Ergebnis e64: keine_aussage
  2026-10-21 14:30 Status laeuft -> ausgewertet (Ergebnis e64)
```
