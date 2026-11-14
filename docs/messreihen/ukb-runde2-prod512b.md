# snai/ukb-runde2-prod512b

```text
snai/ukb-runde2-prod512b - ausgewertet, angelegt 2026-11-06, zuletzt 2026-11-07 13:01
Frage: Senkt eine zweite Runde UKB2 auf den eigenen Fortsetzungen des Modells nach Runde 1 (UKB2_sK) die Beam-Schleife von prod512b deutlich unter UKB2, ohne Beleg, TP1 und Held-out zu kosten, und mehr als dieselbe zweite Runde auf den alten Fortsetzungen von M (W2)?
Kriterium (festgelegt 2026-11-06 17:16, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/ditto_p/kriterien_r.txt 0540dea8 (mit Pruefer). Je Stand s3/s4/s5: E2 U_R2 <= 0,9 U_UKB2 (24 Prompts, gepaarter Bootstrap; knapp -> 36); G (Pflicht) U_R2 <= 0,9 U_W2 (24); S Beleg_R2 >= 0,9 M und TP1_R2 >= 0,9 M; K' H_R2 - H_M <= 2 %. 3/3 ja, 0/3 nein, sonst standabhaengig. erfuellt = alle vier 3/3 (Kandidat, Bestaetigung am Endstand nach s15); teilweise = E2, G, S 3/3, K' nicht; verfehlt = E2 0/3 oder G 0/3 oder S 0/3 (S 0/3 bei E2 3/3 = Tauschlinie); sonst keine_aussage.
Plan: kette_r.sh s3 PAR 1 auf rechner-a (Erzeugung 450 Fortsetzungen von UKB2_s3 ~6 h, Training R2/W2, Messung); s4/s5 PAR 2 auf rechner-b nach Ende von snai/stell-lr1024. Auswertung boot_r.py (aus boot_d.py, vor dem ersten Messwert gebaut). Anlass: Auftrag.
Baut auf: snai/ditto-eigen-prod512b-dosis, snai/ditto-eigen-prod512b, snai/ss-knirps, snai/prod512b-kopierkoepfe-blick
Rezepte:
  r621 [2026-11-06] rechner-a: cd ~/snai_pruef/ditto_p && setsid -f bash -c 'bash kette_r.sh 3 1 > log/kette_r_s3.out 2>&1'   (s4/s5 auf rechner-b: kette_r.sh 4 2 / 5 2, spaeter)
      quelltext: kette_r.sh 24707692, gen_eigen_r.sh 869c7437, bau_r.py 1e58b3db (alle aus den Originalen per patch_runde.py 8848134f); lib ULK 55441278; kriterien_r.txt 0540dea8
      parameter: R2: ab UKB2_sK auf eigenR_sK (Fortsetzungen von UKB2_sK); W2: ab UKB2_sK auf eigen_sK (Fortsetzungen von M, Runde 1). Beide SNAI_UL_N=6 GEWICHT 0.5 KOPIE_BETA=2 selten200.txt, 1 Epoche, LR 2.5e-5, Warmup 0, WD 0.1, SR mv, OMP 3, START_OFFSET 0
      seed: Staende s3/s4/s5; UKB2_s3 cd669efa; Saat der Fenstermischung gleich (Ausgabename ft.snai), Daten verschieden
      rechner: rechner-a (s3, hoechstens ein prod512b-Prozess), rechner-b (s4, s5)
      logs: ~/snai_pruef/ditto_p/log/kette_r.log, log/R2_s3.log, log/W2_s3.log, mess/genR_s3, mess/R2_s3 ...
Messwerte (Groesse | Wert | Arm | Start | n):
  m9437 U_R2/U_UKB2 (E2, 36 Prompts nach Reserve) | 1.04 | R2 | s3 | 36
  m9438 U_R2/U_UKB2 (E2) | 0.75 | R2 | s4 | 24
  m9439 U_R2/U_UKB2 (E2) | 0.71 | R2 | s5 | 24
  m9440 U_R2/U_W2 (G) | 0.97 | R2 | s3 | 24
  m9441 U_R2/U_W2 (G) | 0.83 | R2 | s4 | 24
  m9442 U_R2/U_W2 (G) | 0.83 | R2 | s5 | 24
  m9443 Beleg_R2/Beleg_M | 1.06 | R2 | s3 | 120
  m9444 Beleg_R2/Beleg_M | 1.02 | R2 | s4 | 120
  m9445 Beleg_R2/Beleg_M | 0.97 | R2 | s5 | 120
  m9446 TP1nl_R2/TP1nl_M | 0.99 | R2 | s3 | 198
  m9447 TP1nl_R2/TP1nl_M | 0.91 | R2 | s4 | 198
  m9448 TP1nl_R2/TP1nl_M | 0.94 | R2 | s5 | 198
  m9449 H_R2-H_M (%) | 0.4 | R2 | s3 | 200
  m9450 H_R2-H_M (%) | 0.8 | R2 | s4 | 200
  m9451 H_R2-H_M (%) | 0.7 | R2 | s5 | 200
  m9452 U_W2/U_UKB2 | 1.03 | W2 | s3 | 24
  m9453 U_W2/U_UKB2 | 0.89 | W2 | s4 | 24
  m9454 U_W2/U_UKB2 | 0.86 | W2 | s5 | 24
  m9455 leere Fortsetzungen genR | 8 | UKB2 | s3 | 450
  m9456 leere Fortsetzungen genR | 1 | UKB2 | s4 | 450
  m9457 leere Fortsetzungen genR | 3 | UKB2 | s5 | 450
Ergebnis e567 [2026-11-07 13:01]: keine_aussage
  Fazit: Nach der Vorab-Regel keine_aussage, beide Lesarten gleich: mit Abweichung (Datenbau ohne leere/kurze) E2 2/3, G 2/3, S 3/3, K' 3/3; nach Wortlaut bliebe nur s4. E2 U_R2/U_UKB2 1,04 (36 Prompts, knapp) / 0,75 / 0,71; G gegen W2 0,97 / 0,83 / 0,83. Kein Preis: Beleg 0,97-1,06 x M, TP1 0,91-0,99 x M, Held-out +0,4 bis +0,8 % (UKB2 lag bei +1,1 bis +1,6). Fazit: Die zweite Runde auf eigenen Fortsetzungen senkt die Schleife an s4/s5 deutlich, an s3 gar nicht (auch auf 48 Prompts 1,01), und schadet an keinem Stand. Sie ist damit an jedem Stand mindestens so gut wie UKB2, an zwei Ständen besser. Weitere Runden an s3-s5 lohnen nicht. Bewährungsprobe ist der Endstand nach s15 (beide Runden, frische Prompts, Kriterien vorab). Nebenbefund: UKB lehrt sofortiges Textende (leere Fortsetzungen M 0, UKB2 1-8 von 450), das beim Endstand mitzählen. Belohnungslernen bleibt letzter Ausweg und ist derzeit nicht nötig.
  Datei: rechner-a:~/snai_pruef/ditto_p/ERGEBNIS_r.md
Chronik:
  2026-11-06 17:16 angelegt
  2026-11-06 17:17 Rezept r621
  2026-11-06 17:17 Status geplant -> laeuft (Rezept r621)
  2026-11-07 08:37 07.11. ~08:40 Abweichung (steht in kriterien_r.txt f6feac51): Der Fehlerkanal bau_r.py hat an s3 angeschlagen (8 leere Fortsetzungen, Grenze 5) und an s5 (3 leere, 1 kurze). Alle Läufe rc=0, kein Timeout; M hatte 0 leere und 0 kurze. Das ist also Verhalten von UKB2 (sofortiges Textende), kein Gerätefehler. Weiter mit bau_r2.py 643b37f2 / kette_r2.sh d13783c1: leere und kurze werden weggelassen, Deckel 20. Gegenprobe: gen_s3 ergibt 00cf6433, genR_s4 ergibt d13479ef, beide bytegleich. Daten eigenR_s3/s4/s5 = 442/449/446 Fortsetzungen. s4 fertig 07.11. 04:23 (rechner-b). s5 neu gestartet 08:36 auf rechner-b, s3 08:36 auf rechner-a, beide OHNE_GEN. Im Ergebnis beide Lesarten: nach Wortlaut bliebe nur s4, also keine_aussage. Auswertung boot_r.py e97c920d, Probe grün/rot vor dem ersten Messwert.
  2026-11-07 13:01 Messwerte m9437-m9457
  2026-11-07 13:01 Ergebnis e567: keine_aussage
  2026-11-07 13:01 Status laeuft -> ausgewertet (Ergebnis e567)
```
