# snai/merkmal-runde4

```text
snai/merkmal-runde4 - ausgewertet, begonnen 2026-10-16, angelegt 2026-10-21, zuletzt 2026-10-21 14:33
Frage: Braucht der Formfehler-Kollaps (s4 -> s5, d96 Schach) das int8-Training, oder entsteht er auch beim Float-Training derselben Gewichte? Beide Arme ungebunden (Float kann nicht gebunden).
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/diag/kriterien_runde4.txt, Kopf '2026-10-16, vor den Laeufen; Plan freigegeben' (Bank 14:12, Laeufe bis 16:42)):
  Je Saat (1 und 3), Formfehler (500, T 1, Saat 4711): C (Float) >= 15 % in beiden -> 'Kollaps braucht kein int8'; C < 5 % und B (int8 ungebunden) >= 15 % in beiden -> 'int8-Training noetig'; B und C < 5 % -> 'ungebunden kein Kollaps', int8-Frage nicht entscheidbar; Saaten uneinig -> saatabhaengig; 5-15 % -> kein Urteil. Pflichtkontrolle: Loss eines Arms > 10 % ueber A (Original gebunden) -> Tausch. Gate: Bank 200 Fenster B zweimal bytegleich, B != C; Startstand-Loss = A s4 innerhalb 0,5 %.
Baut auf: snai/merkmal-r3-float
Darauf baut: snai/merkmal-zerl
Rezepte:
  r96 [2026-10-21] bash ~/snai_pruef/merkmal/diag/lauf_runde4.sh <r4b|r4c> (je Saat: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=727208 [SNAI_INT8_FULL=1] nice -n 10 php train_cluster.php factory/input/gross_c64_seg5.txt factory/checkpoints/gross_gross_s<S>_s5.snai 1 1 factory/checkpoints/start_s<S>_v5.snai <3|1> 0.001 0.0001 1 0.1); Messung diag/mess_runde4.sh <arm> <saat>
      quelltext: Kopien knirps/proj_r4b und proj_r4c = proj_neu ohne Checkpoints, libcortex.so 51047037; lauf_runde4.sh b0d9d7f5, mess_runde4.sh 15212cee, bank_runde4.sh c7c3f2df; Start = gross_gross_s{1,3}_s4 per convert_v6_to_v5_full
      parameter: ein Segment s4 -> s5, ungebunden, B dtype 3 + int8 FULL, C dtype 1 Float; LR 0,001 Cosinus bis 727208, Warmup 500, WD 0,1, Ausgabename wie Original (gleiche Fensterfolge)
      seed: Saaten 1 und 3
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/diag/r4/runde4.log, r4/r4{b,c}_s<S>.train.log, r4/mess/ergebnis.txt, r4/bank/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/diag/r4/mess/ergebnis.txt (Skriptausgabe), r4/runde4.log, Bank-md5 am 2026-10-21 nachgerechnet; C-Medianwerte aus der Ergebnisdatei (stufen_float.php), nicht nachgerechnet
  m948 Formfehler | 33,0 % | B int8 ungebunden | 1 | 500
  m949 Formfehler | 37,4 % | B int8 ungebunden | 3 | 500
  m950 Formfehler | 2,2 % | C Float ungebunden | 1 | 500
  m951 Formfehler | 3,0 % | C Float ungebunden | 3 | 500
  m952 Formfehler | 28,4 % | A Original int8 gebunden | 1 | 500
  m953 Formfehler | 37,2 % | A Original int8 gebunden | 3 | 500
  m954 Held-out-Loss | 1,3982 | B | 1
  m955 Held-out-Loss | 1,4136 | B | 3
  m956 Held-out-Loss | 1,3418 | C | 1
  m957 Held-out-Loss | 1,3367 | C | 3
  m958 Held-out-Loss | 1,3922 | A | 1
  m959 Held-out-Loss | 1,4103 | A | 3
  m960 w_out tote Zeilen / Median | 42 / 2 | B | 1 | 1
  m961 w_out tote Zeilen / Median | 53 / 1 | B | 3 | 1
  m962 E tote Zeilen / Median | 0 / 17 und 0 / 19 | B Saaten 1 und 3 |  | 2
  m963 E / w_out Median (Float) | 12 | C | 1
  m964 E / w_out Median (Float) | 28, 0 tot | C | 3
  m965 Bank md5 B1 / B2 / C1 | af3f423c / af3f423c / ec28802d | Gate |  | 3
Ergebnis e94 [2026-10-21 14:33]: erfuellt
  Fazit: Nach Regel braucht der Kollaps den int8-Trainingspfad: Float mit gleichem Decay bleibt bei 2-3 %, int8 kippt auf 33-37 %, in beiden Saaten. Ungebunden stirbt die Ausgabematrix, die Eingabe-Embeddings erholen sich - der Schaden sitzt auf der Ausgabeseite. Achtung bei der Lesart: 'int8 noetig' heisst nicht 'int8 ist die Ursache'. Welcher Teil des int8-Pfads es ist, klaert snai/merkmal-zerl, die Rechenoperation (v-Ratsche des 8-Bit-Adam) erst snai/merkmal-sr.
  Offen: Zwei Saaten, ein Segment, ungebunden. Zwischen B und C aendert sich ein ganzes Buendel (Requantisierung, Ganzzahl-Backward, 8-Bit-Momente, int8-Aktivierungen, SiLU-Tabelle, Decay-Formel, sparse Float-Update).
  Datei: rechner-a:~/snai_pruef/merkmal/diag/kriterien_runde4.txt
Chronik:
  2026-10-21 14:32 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/diag/kriterien_runde4.txt, Kopf '2026-10-16, vor den Laeufen; Plan freigegeben' (Bank 14:12, Laeufe bis 16:42))
  2026-10-21 14:32 Rezept r96
  2026-10-21 14:32 Status geplant -> laeuft (Rezept r96)
  2026-10-21 14:33 Messwerte m948-m965
  2026-10-21 14:33 Ergebnis e94: erfuellt
  2026-10-21 14:33 Status laeuft -> ausgewertet (Ergebnis e94)
```
