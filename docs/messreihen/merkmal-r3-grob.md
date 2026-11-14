# snai/merkmal-r3-grob

```text
snai/merkmal-r3-grob - ausgewertet, begonnen 2026-10-16, angelegt 2026-10-21, zuletzt 2026-10-21 14:31
Frage: Reicht nachtraegliches Vergroebern der Embedding-Zeilen eines gesunden Stands (s1_s4) als Ausloeser des Formfehlers? Und traegt das Embedding allein den Defekt (Tausch s4 <-> s5)?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/diag/kriterien_runde3.txt, Kopf '2026-10-16 nachmittags, VOR den Laeufen; Pruefliste des Auditors' (Laeufe 13:29-13:41)):
  Teil C: Dosisreihe an s1_s4, je Zeile alle Werte ausser dem Zeilenmaximum auf Vielfache von k*Skala gerundet (k 1 / 1,33 / 1,67 / 2 / 2,33 / 3; Rot-Probe k 10). Erreicht eine Stufe mit >= 15 toten Zeilen >= 15 % Formfehler -> 'Aufloesungsverlust reicht als Ausloeser'; bleibt jede Stufe bis k 2,33 unter 3 % -> 'nachtraeglich vergroebert reicht er nicht' (kein Beleg fuer Dynamik); dazwischen kein Urteil. TAUSCH: s5-Modell + s4-Embedding < 5 % UND s4-Modell + s5-Embedding >= 15 % -> 'das Embedding traegt den Defekt'; umgekehrt -> 'die uebrigen Gewichte'; sonst kein Schluss.
Baut auf: snai/merkmal-r3-saat
Darauf baut: snai/merkmal-r3-float
Rezepte:
  r71 [2026-10-21] bash ~/snai_pruef/merkmal/diag/lauf_runde3.sh (cwd knirps/proj_neu; miss(): quant_sonde.php --json, mess_text.php heldout_gross 300, ziehe_schach.php 500 1.0 4711, form_sonde.py, diag/zeilen_schach.php)
      quelltext: lauf_runde3.sh 23daf590, ablation_mittel.php 418a36b6, zeilen_schach.php 8cb2ec29, Engine proj_neu libcortex.so 51047037 (Lade-Waechter aus)
      parameter: Checkpoints proj_ow gross_gross_s{1,2,3}_s{4..7}; ohne Training
      seed: Ziehung Saat 4711 (B1 zusaetzlich 4712, 4713)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/diag/r3.log, diag/r3/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/diag/r3.log (Abschnitt C, abgelesen 2026-10-21)
  m714 Formfehler k 1 (rein) | 1,4 % | s1_s4 grob | 1 | 500
  m715 Formfehler k 1,33 | 1,8 % | s1_s4 grob | 1 | 500
  m716 Formfehler k 1,67 | 1,4 % | s1_s4 grob | 1 | 500
  m717 Formfehler k 2 | 1,6 % | s1_s4 grob | 1 | 500
  m718 Formfehler k 2,33 | 0,6 % | s1_s4 grob | 1 | 500
  m719 Formfehler k 3 | 1,0 % | s1_s4 grob | 1 | 500
  m720 Formfehler k 10 (Rot-Probe) | 1,0 % | s1_s4 grob | 1 | 500
  m721 tote Zeilen k 10 | 35 | s1_s4 grob | 1 | 1
  m722 Held-out-Loss k 1 bis 3 | 1,3835-1,3861 | s1_s4 grob | 1 | 6
  m723 Held-out-Loss k 10 | 1,4026 | s1_s4 grob | 1 | 1
  m724 Held-out-Loss Tausch s5-Modell + s4-Embedding | 16,1498 | Tausch | 1 | 1
  m725 Held-out-Loss Tausch s4-Modell + s5-Embedding | 4,9964 | Tausch | 1 | 1
Ergebnis e68 [2026-10-21 14:31]: verfehlt
  Fazit: Nachtraegliches Vergroebern erzeugt keinen Formfehler, selbst bei 35 toten Zeilen (k 10). Reiner Praezisionsverlust der Embeddings ist damit als Ausloeser ausgeschlossen; der Kollaps braucht etwas, das waehrend des Trainings geschieht. Das lenkte die Suche auf die Trainingsdynamik (Runde 4, ZERL, schliesslich die v-Ratsche, snai/merkmal-sr). Der Tausch ist kein Ergebnis: beide Mischmodelle sind kaputt, Embedding und Rest sind aufeinander eingespielt.
  Offen: Die Rot-Probe k 10 blieb gruen und war falsch gewaehlt (sie setzte die gepruefte These voraus); eine echte Positivkontrolle fuer 'Vergroebern kann Formfehler erzeugen' fehlt.
  Datei: rechner-a:~/snai_pruef/merkmal/diag/kriterien_runde3.txt
Chronik:
  2026-10-21 14:30 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/diag/kriterien_runde3.txt, Kopf '2026-10-16 nachmittags, VOR den Laeufen; Pruefliste des Auditors' (Laeufe 13:29-13:41))
  2026-10-21 14:30 Rezept r71
  2026-10-21 14:30 Status geplant -> laeuft (Rezept r71)
  2026-10-21 14:30 Messwerte m714-m725
  2026-10-21 14:31 Ergebnis e68: verfehlt
  2026-10-21 14:31 Status laeuft -> ausgewertet (Ergebnis e68)
```
