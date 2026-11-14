# snai/ditto-gegen

```text
snai/ditto-gegen - ausgewertet, angelegt 2026-10-25, zuletzt 2026-10-25 22:46
Frage: Faengt ein Gegengewicht in den Trainingsdaten den Beleg-Schaden von DITTO auf? Gegengewicht = die natuerlichen Stuecke als Dokumentkopf + Sprung + spaeterer Teil desselben Dokuments, normale CE. lambda 0,5, wechselnde Trenner, gleiche DITTO-Stuecke wie DT.
Kriterium (festgelegt 2026-10-25 20:08, vor dem ersten Messwert):
  Arm DG (DITTO auf mix_g.txt 89f735e6: dieselben 869 DITTO-Stuecke wie mix_t, natuerliche Stuecke ersetzt), gepaart mit CG (MLE, gleiche Daten). Gegen DT unterscheiden sich nur die natuerlichen Stuecke. 3 Saaten, je Saat 3/3 ja, 0/3 nein, sonst saatabhaengig. Messung auf saetze_frisch7.json b5f695e4.
- W: nl R_DG <= 1,0 UND R_DG/R_M <= 0,9.
- S: Beleg A_DG >= 0,9 A_M UND TP1 >= 0,9 TP1_M.
- E: U <= 1,1 U_M.
- K: Held-out <= +2 %.
- Knapp: Wiederholung auf Kandidaten 1650..1849.
Urteil: erfuellt = alle 3/3; teilweise = W und S 3/3; verfehlt = W oder S 0/3; sonst keine_aussage.
Zweite Lesart (Pruefer M2, berichtet): DG/CG gegen DT/CT, also ob der DITTO-eigene Schaden kleiner wird.
Volltext rechner-a:~/snai_pruef/ditto2/kriterien_anteil_gegen.txt (mit Pruefer).
Plan: rechner-a:~/snai_pruef/ditto2/kriterien_anteil_gegen.txt
Baut auf: snai/ditto-lambda
Darauf baut: snai/ditto-selten
Rezepte:
  r423 [2026-10-25] cd ~/snai_pruef/ditto2 && for k in 1 2 3; do setsid nohup timeout 18000 bash ag.sh $k & done; setsid nohup timeout 10800 bash vorab_ag.sh &  (Arme DG/CG in derselben Kette nach D10/C10; danach Auswertung)
      quelltext: ag.sh 9ea2fa34, textmess7.sh 5769d821, beam12.sh f738a3d3, vorab_ag.sh df5fa545, mess6.sh 2d5e4b51, bau_ditto_gegen.py 763267cd (patch_bau2.py b81305c7 auf bau_ditto_trenner.py 0a9ca497), lib ditto/bau/libcortex_D.so e4bb3a0f, sonde_text.php 4ecc76bc, unscharf.py ff3999bd
      parameter: DG: SNAI_DITTO_LAMBDA=0.5 SNAI_DITTO_LOG=1, CG: SNAI_DITTO_AUS=1; daten/mix_g.txt 89f735e6; sonst wie D10/C10
      seed: SNAI_START_OFFSET 0 / 1000003 / 2000003, Ordner proj / proj_s2 / proj_s3
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/ditto2/{log/DG_s*.log, log/CG_s*.log, log/ag.log, mess/{DG,CG}_s*, mess/t7_*, mess/b12_{DG,CG}_s*}
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ditto2/log/boot_ag.out (md5 20d64354), boot_ag.py; Text-Sonde saetze_frisch7 (1450..1649), nl n=198
  m5562 R nl (TP4/TP1) | 0.641 | DG | s1 | 198
  m5563 R nl (TP4/TP1) | 0.294 | DG | s2 | 198
  m5564 R nl (TP4/TP1) | 0.575 | DG | s3 | 198
  m5565 R nl (TP4/TP1) | 1.456 | CG | s1 | 198
  m5566 R nl (TP4/TP1) | 1.283 | CG | s2 | 198
  m5567 R nl (TP4/TP1) | 1.377 | CG | s3 | 198
  m5568 R_DG/R_M nl [95%] | 0.439 [0.415-0.463] | DG | s1 | 198
  m5569 R_DG/R_M nl [95%] | 0.209 [0.195-0.224] | DG | s2 | 198
  m5570 R_DG/R_M nl [95%] | 0.395 [0.371-0.420] | DG | s3 | 198
  m5571 TP1 nl /M | 0.49 | DG | s1 | 198
  m5572 TP1 nl /M | 0.42 | DG | s2 | 198
  m5573 TP1 nl /M | 0.59 | DG | s3 | 198
  m5574 TP1 nl /M | 2.14 | CG | s1 | 198
  m5575 TP1 nl /M | 2.44 | CG | s2 | 198
  m5576 TP1 nl /M | 2.23 | CG | s3 | 198
  m5577 Beleg A /M | 0.74 | DG | s1 | 120
  m5578 Beleg A /M | 0.57 | DG | s2 | 120
  m5579 Beleg A /M | 0.74 | DG | s3 | 120
  m5580 Beleg A /M | 1.10 | CG | s1 | 120
  m5581 Beleg A /M | 1.11 | CG | s2 | 120
  m5582 Beleg A /M | 1.03 | CG | s3 | 120
  m5583 Beleg A /DT | 1.02 | DG | s1 | 120
  m5584 Beleg A /DT | 0.97 | DG | s2 | 120
  m5585 Beleg A /DT | 1.35 | DG | s3 | 120
  m5586 Beleg DG/CG (DITTO-eigen; DT/CT 0.67/0.52/0.56) | 0.67 | DG | s1 | 120
  m5587 Beleg DG/CG (DITTO-eigen; DT/CT 0.67/0.52/0.56) | 0.52 | DG | s2 | 120
  m5588 Beleg DG/CG (DITTO-eigen; DT/CT 0.67/0.52/0.56) | 0.72 | DG | s3 | 120
  m5589 U Beam12 /M | 0.74 | DG | s1 | 12
  m5590 U Beam12 /M | 0.84 | DG | s2 | 12
  m5591 U Beam12 /M | 0.86 | DG | s3 | 12
  m5592 U Beam12 /M | 1.81 | CG | s1 | 12
  m5593 U Beam12 /M | 1.70 | CG | s2 | 12
  m5594 U Beam12 /M | 2.43 | CG | s3 | 12
  m5595 Held-out H - M | +4.7 % | DG | s1 | 200
  m5596 Held-out H - M | +8.3 % | DG | s2 | 200
  m5597 Held-out H - M | +4.7 % | DG | s3 | 200
  m5598 Held-out H - M | +3.7 % | CG | s1 | 200
  m5599 Held-out H - M | +3.8 % | CG | s2 | 200
  m5600 Held-out H - M | +3.9 % | CG | s3 | 200
  m5601 DITTO-Fenster im Training | 1210 | DG | s1 | 1
  m5602 DITTO-Fenster im Training | 1213 | DG | s2 | 1
  m5603 DITTO-Fenster im Training | 1214 | DG | s3 | 1
Ergebnis e370 [2026-10-25 22:46]: verfehlt
  Fazit: Ein Gegengewicht in den Daten (natuerliche Stuecke als Dokumentkopf + spaeterer Teil, normale CE) faengt den DITTO-Schaden nicht auf. DG bricht die Schleife (W 3/3, R 0,29-0,64), kostet aber Beleg 0,57-0,74 von M (S 0/3) und Held-out +4,7-8,3 % (K 0/3); E 3/3. Lesart (b) des Pruefers: DITTO-eigener Schaden DG/CG 0,67/0,52/0,72 gegen DT/CT 0,67/0,52/0,56, also unveraendert. CG hebt die Satzkopie stark (TP1 x2,1-2,4), den Beleg aber nur wie CT (1,03-1,11); der Einwand, die Form beguenstige die Sonde, hat sich nicht gezeigt. Der Schaden kommt aus dem Verlust selbst, nicht aus fehlender Gegenuebung; ein Eingriff muesste an dem ansetzen, was der Verlust bestraft.
  Offen: Andere Formen oder Anteile des Gegengewichts sind ungeprueft.
  Datei: rechner-a:~/snai_pruef/ditto2/ERGEBNIS_gegen.md
Chronik:
  2026-10-25 20:08 angelegt
  2026-10-25 20:08 Rezept r423
  2026-10-25 20:08 Status geplant -> laeuft (Rezept r423)
  2026-10-25 22:42 Messwerte m5562-m5603
  2026-10-25 22:46 Ergebnis e370: verfehlt
  2026-10-25 22:46 Status laeuft -> ausgewertet (Ergebnis e370)
```
