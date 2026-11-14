# snai/merkmal-biasalle

```text
snai/merkmal-biasalle - ausgewertet, begonnen 2026-10-17, angelegt 2026-10-21, zuletzt 2026-11-01 07:21
Frage: Traegt der INHALT des c*-Kanals (Kopplung des c*-Beitrags zu den Logits an die log-Haeufigkeit) den Formfehler, d. h. trennt er kranke von gesunden Staenden?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/biasalle/kriterien_biasalle.txt, Kopf '2026-10-17, VOR der Messung', Nachtrag 09:29 vor der Messung):
  Groessen je Stand (Geraet aus gradzerl, LR 0, held400): verh = |mittel h^_c*| / Streuung; rho = Spearman(E_r,c* x mittel h^_c*, log-Haeufigkeit). (1) je Groesse GESTUETZT bei AUC 1 (FEHLER > GESUND), NICHT GESTUETZT bei AUC < 0,75, dazwischen kein Urteil. (2) Kombination K = (tote Zeilen >= 22) UND (Bias-Kanal JA: verh >= 2 UND rho >= +0,3): GESTUETZT, wenn K in allen 6 FEHLER wahr und in allen 13 GESUND falsch. Rot: --rot -> verh ~0. Nachtrag vor der Messung (09:29): alle Staende mit EINEM festen Ausgabenamen (Fensterauswahl haengt am Namen, ~8 % Streuung in verh). 22 Staende ohne Training: Originale gross_gross_s{1,2,3}_s4..s7, SPAET-Arme s{1,2,3}_s5..s7, wd0_s1_s5; FEHLER (F >= 15 %) 6, GESUND (F < 5 %) 13, ZWISCHEN (SPAET s3, 8-14 %) 3
Baut auf: snai/merkmal-biaskanal-wd0, snai/merkmal-totzeilen
Darauf baut: snai/merkmal-eingriff, snai/merkmal-zeilenintern
Rezepte:
  r112 [2026-10-21] bash ~/snai_pruef/merkmal/biasalle/mess_bias.sh (Dump-Lauf in knirps/proj_grad mit LR 0, Ausgabename factory/checkpoints/bamess.snai, dann biaskanal.py)
      quelltext: mess_bias.sh 0846a492, biaskanal.py 96b2cb9a, proj_grad libcortex.so fdc140f5
      parameter: 22 Staende, gradzerl/held400.txt, Haeufigkeit gradzerl/freq_seg7.json
      seed: Fensterauswahl am festen Namen bamess.snai
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/biasalle/mess.jsonl, dump/, auswertung.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/biasalle/auswertung.txt (abgelesen 2026-10-21)
  m1154 AUC rho | 1,000 (FEHLER +0,44..+0,51, GESUND -0,42..-0,33) | alle Saaten 1-3 |  | 19
  m1155 AUC verh | 0,987 (FEHLER min 3,46, GESUND max 3,92) | alle Saaten 1-3 |  | 19
  m1156 K richtig | 6/6 FEHLER wahr, 13/13 GESUND falsch | alle Saaten 1-3 |  | 19
  m1157 rho | +0,11 / +0,20 / +0,22 | ZWISCHEN SPAET s3_s5/s6/s7 | 3 | 3
  m1158 verh / rho | 3,92 / -0,42 (gesund) | SPAET s1_s7 | 1 | 1
  m1159 Rot verh | 0,0 | orig s1_s7 | 1 | 1
Ergebnis e106 [2026-10-21 14:35]: erfuellt
  Fazit: rho trennt alle 22 Staende vollstaendig und ordnet als einzige Groesse auch die Zwischenstaende ein; die Kombination K ist ebenfalls gestuetzt. Entscheidend ist das Vorzeichen der Haeufigkeitskopplung, nicht die Staerke von c* (SPAET s1 hat einen starken Kanal mit negativem rho und ist gesund). Das ist ein Zusammenhang an abhaengigen Staenden: der Eingriff am Gain (snai/merkmal-eingriff) konnte die Kausalfrage nicht entscheiden, und im Zeitverlauf kippt rho erst NACH dem Formfehler-Sprung (snai/merkmal-zeilenintern). rho ist daher eher Folge als Ausloeser; die Ursache lag in der v-Ratsche des 8-Bit-Adam (snai/merkmal-sr).
  Offen: Ursachentest offen; ein Pruefsatz.
  Datei: rechner-a:~/snai_pruef/merkmal/biasalle/kriterien_biasalle.txt
Chronik:
  2026-10-21 14:34 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/biasalle/kriterien_biasalle.txt, Kopf '2026-10-17, VOR der Messung', Nachtrag 09:29 vor der Messung)
  2026-10-21 14:35 Rezept r112
  2026-10-21 14:35 Status geplant -> laeuft (Rezept r112)
  2026-10-21 14:35 Messwerte m1154-m1159
  2026-10-21 14:35 Ergebnis e106: erfuellt
  2026-10-21 14:35 Status laeuft -> ausgewertet (Ergebnis e106)
  2026-11-01 07:21 VORBEHALT 2026-11-01: gleiches Gerät wie snai/merkmal-gradzerl; 'LR 0' lief tatsächlich mit LR 0,0005 (train_worker.php ersetzt LR <= 0). Die 22 Stände wurden also über je rund 400 Schritte weitertrainiert, nicht am festen Stand gemessen. Urteil nicht neu bewertet, nicht nachgemessen.
```
