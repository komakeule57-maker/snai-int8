# snai/ditto-selten

```text
snai/ditto-selten - ausgewertet, angelegt 2026-10-26, zuletzt 2026-10-26 06:36
Frage: Isoliert eine Ausnahme fuer seltene Token im DITTO-Fenster (normale CE statt DITTO-Verlust) den Beleg-Schaden, oder ist sie nur eine Verduennung wie der kleinere Anteil?
Kriterium (festgelegt 2026-10-26 04:46, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/ditto2/kriterien_selten.txt (md5 03a355c1, mit Rot-Probe und Pruefer). Arme S2 (Rang >= 200 im natuerlichen Trainingstext, 59 % des Textes), S10 (Rang >= 1000, 34 %), Z2 (zufaellige Ids, gleicher Textanteil wie S2, Kontrolle gegen Verduennung). DT-Rezept mit lib SEL 71aeadb7, je Saat gepaart gegen DT. Je Arm und Saat (3/3 ja, 0/3 nein, sonst saatabhaengig): W nl R_X <= 1,0 UND R_X/R_M <= 0,9; S Beleg >= 0,9 M UND TP1 >= 0,9 M; E U <= 1,1 U_M; K Held-out <= +2 %. Knapp -> Wiederholung auf Kandidaten 2050..2249. erfuellt = S2 oder S10 W,S,E,K 3/3 und Z2 nicht S 3/3; teilweise = S2 oder S10 W und S 3/3, Z2 wie oben; verfehlt = S2 und S10 je W 0/3 oder S 0/3; keine_aussage sonst, auch wenn Z2 ebenso S 3/3 erreicht. Nur berichtet: Seltenheit isoliert erst bei S2/Z2 Beleg >= 1,10 in 3/3; R_h/R_s; Beleg bei Grenze 1000.
Plan: Je Saat eine Kette auf rechner-a: S2, Z2, S10 nacheinander trainieren (OMP 3), dann mess6 + Text-Sonde frisch9 (sonde_selten.php) + Beam 12 in 3 Stroemen. Daneben Text-Sonde frisch9 an M, CT, DT. Auswertung mit Bootstrap wie boot_ag.py. ~2,5 h.
Baut auf: snai/ditto-anteil, snai/ditto-gegen, snai/ditto-lambda, snai/ditto-ab2, snai/ditto-trenner
Darauf baut: snai/ditto-einstieg, snai/ditto-maske
Rezepte:
  r424 [2026-10-26] cd ~/snai_pruef/ditto2 && for k in 1 2 3; do (timeout 18000 bash sel.sh $k &); done; (timeout 14400 bash vorab_sel.sh &)
      quelltext: sel.sh d0b52b4b, textmess9.sh a6fe08ad, vorab_sel.sh 52956133, mess6.sh, beam12.sh f738a3d3; lib bau/libcortex_SEL.so 71aeadb7 (cortex_sel.nim 670e24bd = patch_selten.py b70e8599 auf ~/snai_pruef/ditto/cortex_ditto.nim 0706e513); Sonde sonde_selten.php ade5f9e3 (patch_sonde_selten.py 50e80cca auf sonde_text.php 4ecc76bc); Listen daten/selten200.txt 056c5a8d, daten/selten1000.txt c6782a80 (seltene_liste.php 7a8ea3ab), daten/zufall59.txt 41aa4e22 (zufall_liste.php ad538b74, Saat 20261026); Saetze saetze_frisch9.json 0e1c4d2c (saetze_frisch9.py a5ce6923)
      parameter: SNAI_DITTO_LAMBDA=0.5 SNAI_DITTO_LOG=1 SNAI_DITTO_SELTEN=<Liste>, Daten daten/mix_t.txt 81ea3be0, 1 Epoche ab drohneP_s19, LR 1e-4, Warmup 500, WD 0,1, SNAI_INT8_FULL=1, SNAI_TIE_EMBEDDINGS=1, SNAI_I8_MOM_SR=mv, SNAI_GAIN_GUARD=0, OMP 3, Ausgabename ft.snai
      seed: Saat 1/2/3 = Ordner proj/proj_s2/proj_s3 mit SNAI_START_OFFSET 0/1000003/2000003, Laufname ft
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/ditto2/log/{S2,Z2,S10}_s{1,2,3}.log, log/sel.log, log/textmess9.log, log/pab_s*.log (Rot-Probe), log/rot_sonde_sel/; Arme arme/{S2,Z2,S10}_s*.snai; Messungen mess/{ARM}_s*, mess/t9_*, mess/b12_*
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ditto2/log/boot_sel.out (md5 3d10bcf8), boot_sel.py; Text-Sonde saetze_frisch9 (1850..2049) nl n=194
  m5645 R nl (TP4/TP1) | 1.245 | S2 | s1 | 194
  m5646 R nl (TP4/TP1) | 1.200 | S2 | s2 | 194
  m5647 R nl (TP4/TP1) | 1.227 | S2 | s3 | 194
  m5648 R nl (TP4/TP1) | 1.428 | Z2 | s1 | 194
  m5649 R nl (TP4/TP1) | 1.497 | Z2 | s2 | 194
  m5650 R nl (TP4/TP1) | 1.514 | Z2 | s3 | 194
  m5651 R nl (TP4/TP1) [95%] | 1.168 [1.129-1.209] | S10 | s1 | 194
  m5652 R nl (TP4/TP1) [95%] | 1.031 [1.001-1.061] | S10 | s2 | 194
  m5653 R nl (TP4/TP1) [95%] | 1.081 [1.048-1.115] | S10 | s3 | 194
  m5654 R nl (TP4/TP1) | 1.472 | M | s1 | 194
  m5655 R nl (TP4/TP1) | 1.427 | M | s2 | 194
  m5656 R nl (TP4/TP1) | 1.487 | M | s3 | 194
  m5657 R nl (TP4/TP1) | 0.371 | DT | s1 | 194
  m5658 R nl (TP4/TP1) | 0.204 | DT | s2 | 194
  m5659 R nl (TP4/TP1) | 0.222 | DT | s3 | 194
  m5660 R_h haeufige Token /M | 0.42 | S2 | s1 | 194
  m5661 R_h haeufige Token /M | 0.27 | S2 | s2 | 194
  m5662 R_h haeufige Token /M | 0.26 | S2 | s3 | 194
  m5663 R_h haeufige Token /M | 0.94 | Z2 | s1 | 194
  m5664 R_h haeufige Token /M | 1.03 | Z2 | s2 | 194
  m5665 R_h haeufige Token /M | 0.98 | Z2 | s3 | 194
  m5666 R_h haeufige Token /M | 0.28 | S10 | s1 | 194
  m5667 R_h haeufige Token /M | 0.16 | S10 | s2 | 194
  m5668 R_h haeufige Token /M | 0.17 | S10 | s3 | 194
  m5669 R_s seltene Token (Rang>=200) | 1.393 | S2 | s1 | 194
  m5670 R_s seltene Token (Rang>=200) | 1.349 | S2 | s2 | 194
  m5671 R_s seltene Token (Rang>=200) | 1.394 | S2 | s3 | 194
  m5672 R_s seltene Token (Rang>=200) | 1.442 | S10 | s1 | 194
  m5673 R_s seltene Token (Rang>=200) | 1.248 | S10 | s2 | 194
  m5674 R_s seltene Token (Rang>=200) | 1.302 | S10 | s3 | 194
  m5675 R_s seltene Token (Rang>=200) | 1.518 | M | s1 | 194
  m5676 R_s seltene Token (Rang>=200) | 1.481 | M | s2 | 194
  m5677 R_s seltene Token (Rang>=200) | 1.547 | M | s3 | 194
  m5678 Beleg A /M | 1.07 | S2 | s1 | 120
  m5679 Beleg A /M | 1.17 | S2 | s2 | 120
  m5680 Beleg A /M | 1.03 | S2 | s3 | 120
  m5681 Beleg A /M | 1.01 | Z2 | s1 | 120
  m5682 Beleg A /M | 1.07 | Z2 | s2 | 120
  m5683 Beleg A /M | 0.91 | Z2 | s3 | 120
  m5684 Beleg A /M | 1.01 | S10 | s1 | 120
  m5685 Beleg A /M | 1.00 | S10 | s2 | 120
  m5686 Beleg A /M | 0.92 | S10 | s3 | 120
  m5687 U Beam12 /M | 1.61 | S2 | s1 | 12
  m5688 U Beam12 /M | 1.51 | S2 | s2 | 12
  m5689 U Beam12 /M | 2.13 | S2 | s3 | 12
  m5690 U Beam12 /M | 1.81 | Z2 | s1 | 12
  m5691 U Beam12 /M | 1.49 | Z2 | s2 | 12
  m5692 U Beam12 /M | 2.33 | Z2 | s3 | 12
  m5693 U Beam12 /M | 1.41 | S10 | s1 | 12
  m5694 U Beam12 /M | 1.29 | S10 | s2 | 12
  m5695 U Beam12 /M | 2.06 | S10 | s3 | 12
  m5696 Held-out H - M | +4.1 % | S2 | s1 | 200
  m5697 Held-out H - M | +5.6 % | S2 | s2 | 200
  m5698 Held-out H - M | +6.1 % | S2 | s3 | 200
  m5699 Held-out H - M | +3.3 % | Z2 | s1 | 200
  m5700 Held-out H - M | +4.3 % | Z2 | s2 | 200
  m5701 Held-out H - M | +4.3 % | Z2 | s3 | 200
  m5702 Held-out H - M | +4.6 % | S10 | s1 | 200
  m5703 Held-out H - M | +7.9 % | S10 | s2 | 200
  m5704 Held-out H - M | +7.0 % | S10 | s3 | 200
  m5705 Anteil freier Positionen im DITTO-Fenster | 0.598 | S2 | s1-3 | 3
  m5706 Anteil freier Positionen im DITTO-Fenster | 0.595 | Z2 | s1-3 | 3
  m5707 Anteil freier Positionen im DITTO-Fenster | 0.347 | S10 | s1-3 | 3
Ergebnis e373 [2026-10-26 06:36]: verfehlt
  Fazit: Den Beleg-Schaden kann man aufheben, die Schleife kommt dann aber zurueck. Alle drei Ausnahmen (selten ab Rang 200, ab 1000, zufaellig mit gleicher Menge) schonen den Beleg voll (0,91-1,17 von M, S 3/3), aber keine bricht die Satzschleife (W 0/3; R 1,03-1,51), und die Ausgabe ist so wiederholungsreich wie ohne DITTO (U 1,3-2,3 x M, CT-Niveau). Nicht die Seltenheit schont (Z2 schont auch, S2/Z2 1,06-1,13); der Schaden entsteht nur, wenn der Verlust fast alle Positionen trifft, schon 35 % freie Positionen (S10) heben ihn auf. S2 und S10 druecken die Wiederholung der haeufigen Token weiter wie DT (R_h 0,16-0,42 von M; Z2 0,94-1,03), die seltenen Token wiederholen sich aber wie bei M, und das genuegt der Schleife. Deutung, nicht isoliert: Schleife und nuetzliches Kopieren haengen an denselben inhaltstragenden Token; die Deutung aus ditto-anteil (Zielgroesse schadet an sich) ist in dieser Form widerlegt. Ungeprueft: DITTO nur am Einstieg jeder Kopie, mit E als tragendem Kriterium.
  Offen: Einstiegs-DITTO (nur erste Token jeder Wiederholung); ob ein groesseres Modell Schleife und Beleg-Kopie trennen kann.
  Datei: rechner-a:~/snai_pruef/ditto2/ERGEBNIS_selten.md
Chronik:
  2026-10-26 04:46 angelegt
  2026-10-26 04:46 Rezept r424
  2026-10-26 04:46 Status geplant -> laeuft (Rezept r424)
  2026-10-26 06:36 Messwerte m5645-m5707
  2026-10-26 06:36 Ergebnis e373: verfehlt
  2026-10-26 06:36 Status laeuft -> ausgewertet (Ergebnis e373)
```
