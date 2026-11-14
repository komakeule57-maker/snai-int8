# snai/merkmal-r3-float

```text
snai/merkmal-r3-float - ausgewertet, begonnen 2026-10-16, angelegt 2026-10-21, zuletzt 2026-10-21 14:32
Frage: Loest der int8-Rechenweg der Aktivierungen (dynamische Quantisierung von norm_buf vor den Logits) den Formfehler aus, oder tragen ihn die Gewichte selbst? Dieselben Gewichte im Float-Pfad gezogen.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/diag/kriterien_runde3.txt, Abschnitt E 'NACHTRAG VOR DEM LAUF (2026-10-16 ~13:30)' (Lauf 13:39-13:40)):
  Teil E (Nachtrag vor dem Lauf, 2026-10-16 ~13:30): Gewichte dequantisiert als Float-Modell (convert_v6_to_v5_full), Float-Pfad der Engine. Kontrolle: Held-out-Loss Float gegen int8 desselben Checkpoints innerhalb 1 %, sonst Messpunkt verdaechtig. Urteil: s1_s5 Float-Formfehler < 5 % (int8 28,4 %) -> 'der int8-Rechenweg loest aus'; >= 20 % -> 'die Gewichte selbst tragen ihn'; dazwischen kein Schluss. Gleiche Richtung in s1_s7 und s3_s7 noetig, sonst saatabhaengig.
Baut auf: snai/merkmal-r3-grob
Darauf baut: snai/merkmal-runde4
Rezepte:
  r83 [2026-10-21] bash ~/snai_pruef/merkmal/diag/lauf_float.sh (cwd knirps/proj_neu; php -r convert_v6_to_v5_full; mess_text.php heldout_gross 300; ziehe_schach.php 500 1.0 4711; form_sonde.py)
      quelltext: lauf_float.sh 527e11c5; tensor_io.php aus proj_neu; Engine libcortex.so 51047037
      parameter: Checkpoints gross_gross_s1_s4, s1_s5, s1_s7, s3_s7, s2_s7
      seed: Ziehung 4711
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/diag/r3/float.log, diag/r3/f32/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/diag/r3/float.log (abgelesen 2026-10-21; int8-Werte aus diag/erg/mittel.log)
  m833 Formfehler Float-Pfad | 1,2 % | s1_s4 | 1 | 500
  m834 Formfehler Float-Pfad | 29,8 % (int8 28,4 %) | s1_s5 | 1 | 500
  m835 Formfehler Float-Pfad | 34,0 % (int8 32,8 %) | s1_s7 | 1 | 500
  m836 Formfehler Float-Pfad | 32,4 % (int8 36,4 %) | s3_s7 | 3 | 500
  m837 Formfehler Float-Pfad | 0,0 % | s2_s7 | 2 | 500
  m838 Held-out-Loss Float / int8 | 1,3921 / 1,3922 | s1_s5 | 1 | 1
  m839 Held-out-Loss Float / int8 | 1,3746 / 1,3805 (-0,4 %) | s3_s7 | 3 | 1
  m840 Held-out-Loss Float / int8 | 1,3664 / 1,3701 | s1_s7 | 1 | 1
Ergebnis e81 [2026-10-21 14:32]: erfuellt
  Fazit: Die Gewichte selbst tragen den Formfehler, nicht der int8-Rechenweg beim Ziehen: dieselben Gewichte haben in Float dieselben Fehler (29,8 % statt 28,4 % in s1_s5), gleiche Richtung in s1 und s3. Eine Reparatur der Inferenz (z. B. Ausreisser-Behandlung der Aktivierungen) ist damit vom Tisch; der Defekt entsteht im Training. 'Erfuellt' = die These 'Gewichte tragen ihn' ist nach Regel gestuetzt.
  Datei: rechner-a:~/snai_pruef/merkmal/diag/kriterien_runde3.txt
Chronik:
  2026-10-21 14:31 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/diag/kriterien_runde3.txt, Abschnitt E 'NACHTRAG VOR DEM LAUF (2026-10-16 ~13:30)' (Lauf 13:39-13:40))
  2026-10-21 14:31 Rezept r83
  2026-10-21 14:31 Status geplant -> laeuft (Rezept r83)
  2026-10-21 14:32 Messwerte m833-m840
  2026-10-21 14:32 Ergebnis e81: erfuellt
  2026-10-21 14:32 Status laeuft -> ausgewertet (Ergebnis e81)
```
