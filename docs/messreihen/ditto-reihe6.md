# snai/ditto-reihe6

```text
snai/ditto-reihe6 - ausgewertet, angelegt 2026-10-24, zuletzt 2026-10-24 19:15
Frage: Senkt DITTO bei 6 Epochen (~9.400 Schritte) die Selbstverstärkung der Satzwiederholung verlässlich (3 Saaten), und was kostet es, getrennt nach Wiederholungsmix (C) und DITTO-Verlust (D)? Folge-Regel aus snai/ditto-budget (Einzellauf erfüllte "Budget ist ein Hebel" knapp).
Kriterium (festgelegt 2026-10-24 09:24, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/ditto2/kriterien_reihe.txt (md5 569032a4, mit Prüfer). Arme M (MLE nat), C (MLE Mix), D (DITTO lambda 0,5 Mix), je 6 Epochen als Kette ab drohneP_s19, LR 0,0001. Entscheidende Saaten 2, 3, 4 (Saat 1 = Suchlauf, nur berichtet). K0: Epoche 1 der Saaten 2/3 md5-gleich alte Reihe. Regel 3/3 ja, 0/3 nein, sonst saatabhängig. K1 entscheidet Z_D <= 0,5 Z_M; K2 W_D <= 0,9 W_M; K3 H_D-H_M <= 2 % tragbar; K4 A_D >= 0,9 A_M kein Schaden; gesamt hilft = K1 ja UND K3 UND K4; K1 ja sonst "wirkt, kostet"; K1 nein = "wirkt nicht bei 6 Epochen". Zusätze gepaart D gegen C.
Plan: 9 Ketten (M/C/D x Saat 2/3/4), je Saat nacheinander D, C, M; 3 Saaten parallel auf rechner-a (OMP 3, nice 15), Messung je Kette am Stand Epoche 6; ~7-8 h.
Baut auf: snai/ditto-budget, snai/ditto-knirps
Darauf baut: snai/ditto-format
Rezepte:
  r401 [2026-10-24] cd ~/snai_pruef/ditto2 && for k in 2 3 4; do setsid nohup bash -c "for a in D C M; do bash kette.sh \$a $k; done" & done; kette.sh <ARM> <k>: 6 x (env <SNAI_DITTO_LAMBDA=0.5 | SNAI_DITTO_AUS=1> SNAI_CORTEX_LIB=~/snai_pruef/ditto/bau/libcortex_D.so SNAI_START_OFFSET=$((B_k+3000017*(E-1))) SNAI_TRAIN_MODE=pretrain SNAI_TIE_EMBEDDINGS=1 SNAI_INT8_FULL=1 SNAI_FORCE_CPU=1 SNAI_I8_MOM_SR=mv SNAI_WARMUP_STEPS=500 SNAI_GAIN_GUARD=0 OMP_NUM_THREADS=3 php train_cluster.php ~/snai_pruef/ditto/daten/<mix|nat>.txt factory/checkpoints/ft.snai 1 1 <Basis e-1> 3 0.0001 0 1 0.1), danach mess.sh am Stand e6
      quelltext: kette.sh 5c50e481, mess.sh 2d5e4b51, kriterien_reihe.txt 569032a4, auswert.py (Kopie, B=ditto2); libcortex_D.so e4bb3a0f; proj_s2..4 = Kopien von ditto2/proj
      parameter: Basis drohneP_s19 (170d4d3f); mix.txt 793f6cbd, nat.txt a68a6d3e; lambda 0,5 (D); LR 0,0001 konstant; WD 0,1; 6 Epochen à ~1.568 Schritte
      seed: B_k = 1000003 / 2000003 / 500001 für Saat 2 / 3 / 4; Anlauf Saat 2/3 Schritt 4 identisch mit alter Reihe (Loss 2,442461 / 3,676108)
      rechner: rechner-a, 3 Ketten parallel, Start 09:24
      logs: rechner-a:~/snai_pruef/ditto2/log/<ARM>_s<k>_e<E>.log, log/reihe.log, mess/<ARM>_s<k>_e6/, arme/<ARM>_s<k>_e<E>.snai
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ditto2: auswert6.py (b480aa2e) über mess/<ARM>_s<k>_e6/, boot6.py (999f5676, 50 Sätze) und boot6b.py (9fb75c82, schleife_frisch.jsonl, 200 frische Sätze saetze_frisch.json 99b2fed5); Fehlerkanal 0, rc 54/54 + 9/9 + 9/9
  m5181 Z = TP4-TP1 Erstmessung | 0,0985 / 0,0978 / 0,1012 | M | 2-4 | 50
  m5182 Z = TP4-TP1 Erstmessung | 0,1604 / 0,1431 / 0,1370 | C | 2-4 | 50
  m5183 Z = TP4-TP1 Erstmessung | 0,0398 / 0,0441 / 0,0498 | D | 2-4 | 50
  m5184 K1 Erstmessung Z_D/Z_M [95-%-Bootstrap] | 0,404 [0,287-0,524] / 0,451 [0,328-0,576] / 0,492 [0,363-0,618] -> nach Wortlaut 3/3 | D | 2-4 | 50
  m5185 Z = TP4-TP1 Zweitmessung frisch | 0,0973 / 0,0968 / 0,1017 | M | 2-4 | 200
  m5186 Z = TP4-TP1 Zweitmessung frisch | 0,1520 / 0,1319 / 0,1275 | C | 2-4 | 200
  m5187 Z = TP4-TP1 Zweitmessung frisch | 0,0526 / 0,0563 / 0,0616 | D | 2-4 | 200
  m5188 K1 Zweitmessung Z_D/Z_M [95-%-Bootstrap] | 0,540 [0,487-0,591] / 0,581 [0,532-0,633] / 0,606 [0,554-0,663] -> 0/3, K1 nein | D | 2-4 | 200
  m5189 gepaart Z_D/Z_C frisch | 0,346 / 0,427 / 0,484 [0,428-0,547] | D | 2-4 | 200
  m5190 R = TP4/TP1 frisch | D 1,246 / 1,317 / 1,365; M 1,305 / 1,315 / 1,329; C 1,251 / 1,232 / 1,205 | alle | 2-4 | 200
  m5191 R_D/R_M frisch | 0,956 / 1,001 / 1,027 | D | 2-4 | 200
  m5192 TP1 (2. Fassung) frisch | D 0,213 / 0,178 / 0,169; M 0,320 / 0,307 / 0,309; C 0,605 / 0,569 / 0,622 | alle | 2-4 | 200
  m5193 Beam-W (4 Prompts) | D 0,202 / 0,251 / 0,162; M 0,166 / 0,111 / 0,406; C 0,660 / 0,590 / 0,702 | alle | 2-4 | 4
  m5194 K2 W_D/W_M | 1,22 / 2,26 / 0,40 -> saatabhaengig 1/3 | D | 2-4 | 4
  m5195 Held-out (200 Fenster) | D 4,682 / 4,680 / 4,694; M 4,440 / 4,431 / 4,431; C 4,605 / 4,577 / 4,594 | alle | 2-4 | 200
  m5196 K3 Held-out D-M | +5,5 / +5,6 / +5,9 % -> 0/3 tragbar (gepaart D-C +1,7 / +2,3 / +2,2 %) | D | 2-4 | 3
  m5197 Beleg-Anteil A | D 13,6 / 11,5 / 11,4 %; M 17,8 / 18,2 / 17,7 %; C 18,0 / 16,9 / 17,3 % | alle | 2-4 | 120
  m5198 K4 A_D/A_M | 0,76 / 0,63 / 0,64 -> 0/3 ohne Schaden (gepaart A_D/A_C 0,75 / 0,68 / 0,66) | D | 2-4 | 3
  m5199 R = TP4/TP1 Saat 1 (Suchlauf, nur berichtet) | 0,94 (50 Saetze) | D | 1 | 50
  m5200 Clipping-Anteil Telemetrie | 100,0 % in 288/288 Telemetriezeilen je Arm | alle | 2-4 | 288
Ergebnis e357 [2026-10-24 19:15]: verfehlt
  Fazit: Auch mit sechsfachem Budget (9.408 Schritte) bricht DITTO in der eigenen int8-Engine die Selbstverstaerkung nicht; der Einzellauf aus snai/ditto-budget (R 0,94) ist nicht reproduziert. K1 nach Wortlaut auf den 50 Saetzen 3/3 (0,40/0,45/0,49), aber alle Intervalle ueber 0,5; die vorab geregelte Zweitmessung auf 200 frischen Saetzen ergibt 0,54/0,58/0,61 -> 0/3, K1 nein, Gesamt "wirkt nicht bei 6 Epochen, lambda 0,5, LR 0,0001". Relativ (TP4/TP1) verstaerkt sich D wie M (R_D/R_M 0,96-1,03). DITTO drueckt nur das Kopieren aus dem Kontext insgesamt (TP1 ein Drittel unter M, Beleg-Anteil 0,63-0,76 von M) und kostet Held-out +5,5-5,9 %. "Mehr Schritte" ist als Erklaerung erledigt. Lehre: 50-Satz-Sonde reicht nicht fuers Urteil nahe der Schwelle, die frische Wiederholung drehte es um.
  Offen: Andere Stellraeder der Engine ungemessen: Clipping greift in 100 % der Schritte aller Arme (skaliert den DITTO-Gradienten immer mit), fp32-Pfad statt int8, lambda-Sweep. Billigster letzter Test der Linie "Feinabstimmung der Engine": Einzellauf 1 Epoche D mit Clipping aus bzw. fp32. Uebertragung auf prod512b ungemessen (Schwesterreihe snai/ditto-schonend dort verfehlt).
  Datei: rechner-a:~/snai_pruef/ditto2/ERGEBNIS_reihe6.md
Chronik:
  2026-10-24 09:24 angelegt
  2026-10-24 09:25 Rezept r401
  2026-10-24 09:25 Status geplant -> laeuft (Rezept r401)
  2026-10-24 19:08 2026-10-24 19:30: Alle 9 Ketten fertig (54/54 rc 0, LR 0,0001 je Epoche, DITTO nur in D, K0 6/6 gleich, Messungen 9/9 rc 0, Fehlerkanal 0). Erstmessung K1 nach Wortlaut 3/3 (Z_D/Z_M 0,40/0,45/0,49), aber alle Bootstrap-Intervalle schliessen 0,5 ein -> Zweitmessung K1 auf 200 frischen Saetzen, Regel vorab in rechner-a:~/snai_pruef/ditto2/kriterien_zweit.txt (festgelegt nach Erst-, vor Zweitmessung). Wortlaut kriterien_reihe.txt unveraendert, beide Lesarten werden berichtet.
  2026-10-24 19:15 Messwerte m5181-m5200
  2026-10-24 19:15 Ergebnis e357: verfehlt
  2026-10-24 19:15 Status laeuft -> ausgewertet (Ergebnis e357)
  2026-10-24 19:15 Korrektur zur Notiz 19:30: kriterien_zweit.txt wurde um 19:08 festgelegt (vor dem Start der Zweitmessung 19:08-19:13), nicht ~19:30. md5 nach Korrektur der Uhrzeit in Zeile 1: 1cc3044f.
```
