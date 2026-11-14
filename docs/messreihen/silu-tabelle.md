# snai/silu-tabelle

```text
snai/silu-tabelle - ausgewertet, begonnen 2026-10-16, angelegt 2026-10-21, zuletzt 2026-10-21 19:18
Frage: Rechnen Training und Auswertung denselben Forward? Wie gross ist der Unterschied durch die SiLU-Tabelle des gebuendelten Trainingspfads (siluRowFromQ8 aus der int8-Historie) gegenueber forward_i8 (Float-SiLU), gepaart je Fenster?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/silu/kriterien.txt (laut Text vor dem ersten Lauf, 2026-10-16; Ergebnis spaeter angefuegt, Wortlaut unveraendert).):
  S = mittel(T1 - T0) je Fenster (Trainings-Forward mit gegen ohne Tabelle). 'Vernachlaessigbar', wenn |S| < 0,2 % des E0 in allen Modellen; 'relevant', wenn |S| >= 1 % und Intervall ohne 0 in 3 von 3 d64-Saaten; dazwischen 'messbar, aber klein'; d64-Saaten uneinig -> saatabhaengig. K = mittel(T0 - E0) ebenso, |K| >= 1 % waere eigener Befund. Rot-Proben: R1 Label-Smoothing nur im Training -> K > 1 %; R2 verschobene Ziele -> K gross; R3 E1 - E0 exakt 0.
Rezepte:
  r135 [2026-10-21] cd ~/snai_pruef/silu && bash reihe.sh (je Modell: SNAI_FORCE_CPU=1 OMP_NUM_THREADS=1 php silu_sonde.php modelle/<m>.snai <vokabular> <heldout> 40 normal|rot_ls|rot_shift ergebnis/<m>.json); Auswertung python3 auswert.py
      quelltext: Baum = git archive 21b7fde + libcortex.so 031879a2 (cortex.nim 1f30c590); silu_sonde.php dd736acd
      parameter: 40 aufeinanderfolgende Held-out-Fenster ctx 64; Modelle schach_d64_s1-3_s7, schach_d96_s1-3_s7, mini_d64 (Text); Bootstrap 2.000
      seed: Bootstrap 20261016
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/silu/ergebnis/*.json, ergebnis/auswertung.txt, log/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/silu/ergebnis/auswertung.txt (nachgelesen)
  m1493 S relativ | -0,002 % [KI enthaelt 0] | d64 | 1 | 40
  m1494 S relativ | -0,011 % [KI enthaelt 0] | d64 | 2 | 40
  m1495 S relativ | +0,031 % [KI enthaelt 0] | d64 | 3 | 40
  m1496 S relativ | -0,045 % [KI enthaelt 0] | d96 | 1 | 40
  m1497 S relativ | 0,000 % [KI enthaelt 0] | d96 | 2 | 40
  m1498 S relativ | +0,014 % [KI enthaelt 0] | d96 | 3 | 40
  m1499 S relativ | 0,000 % [KI enthaelt 0] | mini_d64 |  | 40
  m1500 K relativ | -0,002 bis 0,000 % | Schach | 1-3 | 40
  m1501 K relativ | -0,072 % [-0,013;-0,001 absolut] | mini_d64 |  | 40
  m1502 R2 verschobene Ziele K | +714 % | Rot | 1 | 40
  m1503 R3 max E1-E0 | 0 | alle |  | 40
  m1504 R1 Label-Smoothing K | 0,000 % (schlug nicht an) | Rot | 1 | 40
Ergebnis e129 [2026-10-21 19:18]: gleichstand
  Fazit: Vernachlaessigbar nach Vorab-Regel: |S| <= 0,045 % in allen 7 Modellen, alle Intervalle mit 0. Die SiLU-Tabelle bewegt den Loss je Fenster, aber ohne Richtung. Ohne Tabelle rechnen Training und Auswertung auf Schach bis 0,002 % gleich; der kleine Rest beim Textmodell kommt aus der NLL-Kappung bei -ln(1e-7) im Trainingsweg. Kein Handlungsbedarf fuer die bekannte Abweichung (BUGFIXES §24) bei kleinen Modellen.
  Offen: 512er-Modelle nicht gemessen; ob Training MIT Tabelle anders lernt, misst diese Sonde nicht. R1 war als Rot-Probe falsch gewaehlt (Kern glaettet nur den Gradienten, nicht den zurueckgegebenen Loss).
  Datei: rechner-a:~/snai_pruef/silu/kriterien.txt (Ergebnisabschnitt)
Chronik:
  2026-10-21 19:18 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/silu/kriterien.txt (laut Text vor dem ersten Lauf, 2026-10-16; Ergebnis spaeter angefuegt, Wortlaut unveraendert).)
  2026-10-21 19:18 Rezept r135
  2026-10-21 19:18 Status geplant -> laeuft (Rezept r135)
  2026-10-21 19:18 Messwerte m1493-m1504
  2026-10-21 19:18 Ergebnis e129: gleichstand
  2026-10-21 19:18 Status laeuft -> ausgewertet (Ergebnis e129)
```
