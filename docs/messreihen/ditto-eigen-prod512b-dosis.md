# snai/ditto-eigen-prod512b-dosis

```text
snai/ditto-eigen-prod512b-dosis - ausgewertet, angelegt 2026-10-27, zuletzt 2026-10-27 20:55
Frage: Holt ein staerkeres Kopier-Gegengewicht (b=2, b=3 statt 1) auf prod512b TP1 ueber 0,9 x M zurueck, ohne die Schleifensenkung (U <= 0,9 U_M) zu verlieren?
Kriterium (festgelegt 2026-10-27 06:04, vor dem ersten Messwert):
  ~/snai_pruef/ditto_p/kriterien_d.txt 419bce76 (mit Pruefer). Je Stand s3/s4/s5: E* U_X <= 0,9 U_M (24 Prompts, gepaarter Bootstrap 2000, Saat 20261024; Intervall schliesst 0,9 ein -> 36 mit Reserve); S Beleg_X >= 0,9 Beleg_M und TP1_X(nl) >= 0,9 TP1_M; K' H_X - H_M <= 2 %. 3/3 ja, 0/3 nein, sonst standabhaengig. Arm zaehlt nur, wenn K0Q E* nicht 3/3 oder U_X <= 0,9 U_K0Q in 3/3. erfuellt = ein Arm E*, S, K' je 3/3 (beide -> kleineres mittleres U); teilweise = E*, S 3/3, K' nicht; verfehlt = beide E* 0/3 oder S 0/3; sonst keine_aussage. Erfuellt ist nur Kandidat (Suche), behoben erst nach Bestaetigung auf frischen Staenden.
Plan: Arme UKB2, UKB3 (= UKB1 mit SNAI_UL_KOPIE_BETA 2/3, einziges Stellrad) ab M_sK auf denselben Daten eigen_sK.txt; Bezug M und K0Q aus snai/ditto-eigen-prod512b. kette_d.sh 31a54133. s4/s5 auf rechner-b nach Absprache mit TDC-AI, s3 auf rechner-a nach Ende der laufenden Kette.
Baut auf: snai/ditto-eigen-prod512b, (Vorschau (nicht im Messbuch), s4/s5: (nicht im Messbuch), UKB1 (nicht im Messbuch), TP1 (nicht im Messbuch), s4 (nicht im Messbuch), 0 (nicht im Messbuch), 88 (nicht im Messbuch), x (nicht im Messbuch), M (nicht im Messbuch), S (nicht im Messbuch), hoechstens (nicht im Messbuch), 2/3) (nicht im Messbuch), snai/ditto-eigen-kopie, e383 (nicht im Messbuch), (UKB3 (nicht im Messbuch), am (nicht im Messbuch), Knirps) (nicht im Messbuch)
Darauf baut: snai/ukb-runde2-prod512b
Rezepte:
  r444 [2026-10-27] rechner-a: ~/snai_pruef/ditto_p/log/folge_s3.sh wartet auf "s3 FERTIG" der Uebertragung und startet dann `bash kette_d.sh 3 1` (gestartet 10:07:03). rechner-b s4/s5: `setsid nohup bash kette_d.sh 4 1` und `... 5 1` ab 15 Uhr (mit TDC-AI abgesprochen).
      quelltext: kette_d.sh 31a54133, kriterien_d.txt 419bce76, lib ULK 55441278, bau-Daten eigen_s3 00cf6433 / s4 9b807620 / s5 78339393
      parameter: UKB2/UKB3 = SNAI_UL_N=6 SNAI_UL_GEWICHT=0.5 SNAI_UL_KOPIE_BETA=2/3 SNAI_UL_KOPIE_LISTE=selten200.txt; ab M_sK, 1 Epoche, LR 2,5e-5, Warmup 0, WD 0,1, SR mv, OMP 3, START_OFFSET 0. Schritt 1 UKB2 s3 = 2,485954 = K0Q/UKB1.
      rechner: rechner-a (s3, PAR 1), rechner-b (s4, s5 je PAR 1, ab 15 Uhr)
      logs: ~/snai_pruef/ditto_p/log/kette_d.log, log/UKB2_sK.log, log/UKB3_sK.log
  r451 [2026-10-27] cd ~/snai_pruef/ditto_p && setsid nohup bash kette_d.sh 4 1 > log/kette_d_s4.out 2>&1 < /dev/null &  (ebenso kette_d.sh 5 1 > log/kette_d_s5.out)
      quelltext: kette_d.sh 31a54133, kriterien_d.txt 419bce76, lib bau/libcortex_ULK.so 55441278, daten/selten200.txt 056c5a8d, mess_p.sh 22a4d14d, textmess10.sh 8a3552e7, beam12.sh 26b482ff, beam12n.sh 1668c58b, beam12r.sh 638e0678, beam12f.sh 25b3e877 (alle md5-gleich zu rechner-a)
      parameter: Arme UKB2 (SNAI_UL_KOPIE_BETA=2) und UKB3 (=3), sonst wie UKB1: SNAI_UL_N=6, GEWICHT 0.5, ab M_sK, 1 Epoche, LR 2.5e-5, Warmup 0, WD 0.1, SR mv, OMP 3, START_OFFSET 0; Daten eigen_s4 9b807620, eigen_s5 78339393; PAR 1
      seed: Staende s4, s5 (M_s4 751d92d9, M_s5 10ab21ad); Schritt 1 = K0Q geprueft: s4 2.508250, s5 2.702449
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/ditto_p/log (kette_d.log, UKB2_s4.log ...), mess/
      notiz: Start 2026-10-27 15:03:13, mit TDC-AI fuer 15 Uhr abgesprochen; projekte-d6-Inferenzen vorher beendet, MemAvailable 12,7 GB vor / 11,1 GB nach Start. s3 laeuft auf rechner-a (r444).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ditto_p/log/boot_d.out (f0975252, boot_d.py 61a4ff1d aus patch_boot_d.py 2dfd4cb1), beleg_boot.py, diag_kurz_p.py
  m6185 U/U_M | 0,70 [0,56-0,85] | UKB2 | s3 | 24
  m6186 U/U_M | 0,87 [0,76-0,98] | UKB2 | s4 | 36
  m6187 U/U_M | 0,79 [0,66-0,93] | UKB2 | s5 | 36
  m6188 U/U_M | 0,77 [0,65-0,89] | UKB3 | s3 | 36
  m6189 U/U_M | 0,94 [0,81-1,09] | UKB3 | s4 | 36
  m6190 U/U_M | 0,83 [0,69-0,99] | UKB3 | s5 | 36
  m6191 U/U_M | 0,95 [0,81-1,11] | K0Q | s3 | 24
  m6192 U/U_M | 0,93 [0,82-1,05] | K0Q | s4 | 36
  m6193 U/U_M | 0,95 [0,80-1,13] | K0Q | s5 | 36
  m6194 U/U_M auf 24 (vor Reserve) | 0,90 [0,76-1,07] | UKB2 | s4 | 24
  m6195 U/U_M auf 24 (vor Reserve) | 0,75 [0,62-0,92] | UKB2 | s5 | 24
  m6196 Beleg/M | 1,01 [0,99-1,03] | UKB2 | s3 | 119
  m6197 Beleg/M | 1,03 [1,01-1,06] | UKB2 | s4 | 119
  m6198 Beleg/M | 1,03 [1,01-1,05] | UKB2 | s5 | 119
  m6199 Beleg/M | 1,04 [1,02-1,06] | UKB3 | s3 | 119
  m6200 Beleg/M | 1,07 [1,04-1,09] | UKB3 | s4 | 119
  m6201 Beleg/M | 1,05 [1,03-1,08] | UKB3 | s5 | 119
  m6202 TP1 nl/M | 0,94 | UKB2 | s3 | 198
  m6203 TP1 nl/M | 0,93 | UKB2 | s4 | 198
  m6204 TP1 nl/M | 0,98 | UKB2 | s5 | 198
  m6205 TP1 nl/M | 0,97 | UKB3 | s3 | 198
  m6206 TP1 nl/M | 0,96 | UKB3 | s4 | 198
  m6207 TP1 nl/M | 1,01 | UKB3 | s5 | 198
  m6208 H-H_M | +1,1 % | UKB2 | s3
  m6209 H-H_M | +1,4 % | UKB2 | s4
  m6210 H-H_M | +1,6 % | UKB2 | s5
  m6211 H-H_M | +1,2 % | UKB3 | s3
  m6212 H-H_M | +1,4 % | UKB3 | s4
  m6213 H-H_M | +1,7 % | UKB3 | s5
  m6214 U_X/U_K0Q (24, nur berichtet) | 0,74 / 1,00 / 0,85 | UKB2 | s3/s4/s5 | 24
  m6215 U_X/U_K0Q (24, nur berichtet) | 0,80 / 1,10 / 0,90 | UKB3 | s3/s4/s5 | 24
  m6216 U_X/U_UKB1 (24, nur berichtet) | 0,99 / 1,17 / 1,31 | UKB2 | s3/s4/s5 | 24
  m6217 U_X/U_UKB1 (24, nur berichtet) | 1,07 / 1,29 / 1,37 | UKB3 | s3/s4/s5 | 24
  m6218 U/U_M frisch (nur berichtet) | 0,95 / 1,03 / 0,62 | UKB2 | s3/s4/s5 | 12
  m6219 U/U_M frisch (nur berichtet) | 0,86 / 0,92 / 1,02 | UKB3 | s3/s4/s5 | 12
  m6220 U/U_M frisch (nur berichtet) | 1,03 / 0,97 / 0,78 | K0Q | s3/s4/s5 | 12
  m6221 Ausgaben unter 20 Woertern | 1/108 | UKB2 | s3-s5 | 108
  m6222 Ausgaben unter 20 Woertern | 2/108 | UKB3 | s3-s5 | 108
Ergebnis e396 [2026-10-27 20:55]: erfuellt
  Fazit: Nach Wortlaut erfuellt durch UKB2 (b=2), aber nur KANDIDAT und knapp: behoben ist die Schleife fuer prod512b NICHT. b=2 holt TP1 (0,93-0,98 x M) und Beleg zurueck, gibt dafuer Schleifenwirkung ab (U 0,70/0,87/0,79 x M gegen b=1 0,71/0,78/0,58; b=3 noch schwaecher, E* 2/3). Gegen blosses Nachtraining K0Q nur an s3 klar besser (24 Prompts 0,74/1,00/0,85), frische 12 Prompts tragen an s3/s4 nicht (0,95/1,03). Dieselbe Tauschlinie wie am Knirps; kein b trennt Schleife und Kopieren. Fuer die Produktion bleibt die Kopiersperre DS das Werkzeug, Anti-Schleifen-Nachtraining lohnt fuer prod512b nicht. Schleifenreihen enden hier (so entschieden).
  Offen: Bestaetigung auf frischen Staenden (prod512b_s6 ff.) laut Kriterien Voraussetzung fuer "behoben", laeuft nicht. Wirkung zusammen mit der Kopiersperre DS ungemessen. Abweichung: K0Q s3 ohne Reserve (ohne Einfluss, K0Q E* schon an s4 verfehlt).
  Datei: rechner-a:~/snai_pruef/ditto_p/ERGEBNIS_d.md
Chronik:
  2026-10-27 06:04 angelegt
  2026-10-27 10:09 Rezept r444
  2026-10-27 10:09 Status geplant -> laeuft (Rezept r444)
  2026-10-27 15:05 Rezept r451
  2026-10-27 20:54 Messwerte m6185-m6222
  2026-10-27 20:55 Ergebnis e396: erfuellt
  2026-10-27 20:55 Status laeuft -> ausgewertet (Ergebnis e396)
```
