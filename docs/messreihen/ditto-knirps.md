# snai/ditto-knirps

```text
snai/ditto-knirps - ausgewertet, angelegt 2026-10-23, zuletzt 2026-10-23 22:32
Frage: Senkt DITTO-Feinabstimmung (Xu et al. 2022) an einem kleinen int8-Modell mit gemessener Selbstverstärkung (drohneP_s19, 128/4/4) die Selbstverstärkung von Satzwiederholung, und was kostet sie bei Held-out und nützlichem Kopieren?
Kriterium (festgelegt 2026-10-23 19:54, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/ditto/kriterien.txt (md5 bb375daf, mit Prüfer). Arme ab drohneP_s19, 1 Epoche, LR 0,0001: M = natürlicher Text mit MLE, C = Mix mit Wiederholungsstücken und MLE, D = derselbe Mix mit DITTO λ 0,5 (C/D gepaart, ein Stellrad). 3 Saaten über SNAI_START_OFFSET. Regel: 3/3 ja, 0/3 nein, sonst saatabhängig. K1 (entscheidet): Z = TP4−TP1 der Schleifen-Sonde, Z_D ≤ 0,5·Z_M in 3/3 (Zusatz gepaart Z_D ≤ 0,5·Z_C). K2 (stützt): Beam-W, W_D ≤ 0,9·W_M. K3 (Kosten): Held-out D−M ≤ 2 % von M = tragbar. K4 (Kosten): Beleg-Anteil A_D ≥ 0,9·A_M = kein Schaden. Gesamt „DITTO hilft am Knirps“ = K1 ja UND K3 tragbar UND K4 kein Schaden. K1 nein = „wirkt nicht in diesem Budget/Rezept“.
Plan: rechner-a:~/snai_pruef/ditto/kriterien.txt
Baut auf: snai/prod512b-schleife, snai/kopier-drohne-p, snai/prod512b-sampling
Darauf baut: snai/ditto-budget, snai/ditto-reihe6, snai/ditto-schonend, snai/knirps-weitertrain, snai/ditto-trenner, snai/ditto-eigen
Rezepte:
  r398 [2026-10-23] cd ~/snai_pruef/ditto && for k in 1 2 3; do setsid nohup bash arme.sh $k <offset> & done (Offsets 0 / 1000003 / 2000003); darin je Arm: env [SNAI_DITTO_LAMBDA=0.5] SNAI_CORTEX_LIB=bau/libcortex_D.so SNAI_START_OFFSET=<off> SNAI_TRAIN_MODE=pretrain SNAI_TIE_EMBEDDINGS=1 SNAI_INT8_FULL=1 SNAI_FORCE_CPU=1 SNAI_I8_MOM_SR=mv SNAI_WARMUP_STEPS=500 SNAI_GAIN_GUARD=0 OMP_NUM_THREADS=3 php train_cluster.php ../daten/<nat|mix>.txt factory/checkpoints/ft.snai 1 1 factory/checkpoints/drohneP_s19.snai 3 0.0001 0 1 0.1; danach mess.sh je Endstand (Schleifen-Sonde, Beam 3 ROH, Held-out 200 Fenster, Beleg-Sonde 120)
      quelltext: arme.sh 0f44689e, mess.sh fee161e2, bau_ditto.py 6b1504b7, patch_ditto.py 1c04cb31; libcortex_D.so e4bb3a0f (ohne λ bytegleich zu libcortex_A.so 7a27e544); Messgeräte aus proj_sr (lib 318b2655, Vokabular f020d0ca)
      parameter: Basis drohneP_s19 (md5 170d4d3f, 128/4/4, ctx 512); Daten mix.txt 793f6cbd / nat.txt a68a6d3e (je 3,11 MB, ~1.800 Schritte); λ 0,5; LR 0,0001 konstant, Warmup 500, WD 0,1
      seed: SNAI_START_OFFSET 0 / 1000003 / 2000003; Datenbau Saat 20261023
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/ditto/log/arm_<ARM>_s<k>.log, log/arme.log, mess/<ARM>_s<k>/, arme/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ditto/ERGEBNIS_roh.txt (auswert.py über mess/<arm>_s<k>/, alle rc 0, Fehlerkanal 0/40; Paarkontrolle C/D Schritt 1 identisch)
  m4907 Z = TP4-TP1 | 0,143 | Basis drohneP_s19 |  | 50
  m4908 Z = TP4-TP1 | 0,119 / 0,101 / 0,114 | M | 1-3 | 50
  m4909 Z = TP4-TP1 | 0,162 / 0,179 / 0,141 | C | 1-3 | 50
  m4910 Z = TP4-TP1 | 0,100 / 0,052 / 0,045 | D | 1-3 | 50
  m4911 TP1 (2. Kopie) | 0,293 / M 0,265-0,280 / C 0,573-0,650 / D 0,140-0,203 | alle | 1-3 | 50
  m4912 TP4/TP1 | Basis 1,49 / M 1,45 1,36 1,41 / C 1,25 1,31 1,22 / D 1,71 1,32 1,22 | alle | 1-3 | 50
  m4913 Beam-W (4 Prompts) | Basis 0,371 / M 0,190 0,272 0,202 / C 0,660 0,590 0,596 / D 0,130 0,166 0,179 | alle | 1-3 | 4
  m4914 Held-out (200 Fenster) | Basis 4,128 / M 4,243 4,252 4,239 / C 4,397 4,386 4,391 / D 4,481 4,419 4,378 | alle | 1-3 | 200
  m4915 Beleg-Anteil A | Basis 20,3 % / M 18,1 18,7 19,8 % / C 21,0 17,9 19,9 % / D 13,3 16,2 16,8 % | alle | 1-3 | 120
  m4916 K1 Z_D/Z_M | 0,84 / 0,51 / 0,39 -> saatabhängig 1/3 (gepaart gegen C 2/3) | D | 1-3 | 3
  m4917 K2 W_D/W_M | 0,68 / 0,61 / 0,89 -> ja 3/3 | D | 1-3 | 3
  m4918 K3 Held-out D-M | +5,6 / +3,9 / +3,3 % -> nein 0/3 (gepaart D-C +1,9 / +0,8 / -0,3 %) | D | 1-3 | 3
  m4919 K4 A_D/A_M | 0,73 / 0,86 / 0,85 -> nein 0/3 (gepaart D/C 0,63 / 0,90 / 0,84) | D | 1-3 | 3
Ergebnis e347 [2026-10-23 22:32]: keine_aussage
  Fazit: Nach der Vorab-Regel entscheidet K1 nicht. Die Selbstverstärkung fällt nur in 1 von 3 Saaten auf die Hälfte (D/M 0,84 / 0,51 / 0,39), deshalb heißt es „saatabhängig“. Eindeutig sind dagegen die Kosten: Held-out +3 bis +6 % (0/3 tragbar), Beleg-Anteil auf 73-86 % von M (0/3 ohne Schaden). Die Beam-Wiederholung W sinkt 3/3. Die Gegenprobe ändert die Deutung: DITTO senkt vor allem das Kopieren der zweiten Fassung überhaupt (TP1 0,14-0,20 gegen 0,27). Die relative Verstärkung TP4/TP1 liegt dagegen nicht niedriger (1,22-1,71 gegen 1,36-1,45). Beim Lesen wiederholt D Absätze weiter, nur leicht abgewandelt, und das verfehlt das wortgleiche Maß W. In dieser Form ist DITTO ein stumpfes Werkzeug: Es dämpft das Kopieren aus dem Kontext, das prod512b gerade für Belege braucht (snai/prod512b-beleg), statt gezielt die Schleife zu brechen. Für prod512b nicht übernehmen. Die Held-out-Kosten stammen überwiegend aus dem Datenmix (gepaart D-C ≤ 1,9 %), der Schaden am Beleg-Anteil aus dem Verlust selbst.
  Offen: Nur λ 0,5, ein Budget (~1.560 statt 10.000 Schritte bei Xu), 50 % Mix, ein Basismodell 128/4/4. Ob kleineres λ oder geringerer Mixanteil das Kopieren schont und trotzdem die Verstärkung senkt, ist ungemessen. Absatzschleifen mit Abwandlung bräuchten ein unscharfes Wiederholungsmaß. Nebenfund ohne Isolation: schon M (konstante LR 0,0001 auf natürlichem Text) halbiert Beam-W gegenüber der Basis.
  Datei: rechner-a:~/snai_pruef/ditto/ERGEBNIS_ditto.md
Chronik:
  2026-10-23 19:54 angelegt
  2026-10-23 19:54 Rezept r398
  2026-10-23 19:54 Status geplant -> laeuft (Rezept r398)
  2026-10-23 22:31 Messwerte m4907-m4919
  2026-10-23 22:32 Ergebnis e347: keine_aussage
  2026-10-23 22:32 Status laeuft -> ausgewertet (Ergebnis e347)
```
