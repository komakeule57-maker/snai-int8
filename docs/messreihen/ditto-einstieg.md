# snai/ditto-einstieg

```text
snai/ditto-einstieg - ausgewertet, angelegt 2026-10-26, zuletzt 2026-10-26 08:46
Frage: Bricht ein DITTO-Verlust, der nur am Uebergang zwischen zwei Kopien greift (Satzende, Trenner, Satzanfang), die Schleife in der Ausgabe und schont dabei den Beleg? Liegt die Wirkung an der Stelle oder nur an der Menge?
Kriterium (festgelegt 2026-10-26 06:47, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/ditto2/kriterien_einstieg.txt (md5 ed648bec, mit Rot-Probe, Grenzpruefung und Pruefer). Arme U2 (+-2 um jede Grenze), U5 (+-5), M5 (+-5 um b + L/2, Kontrolle Stelle gegen Menge). DT-Rezept mit lib EIN 693b6f99, je Saat gepaart gegen DT. Je Arm und Saat (3/3 ja, 0/3 nein, sonst saatabhaengig): E (tragend) U_X <= 1,1 U_M ueber 24 Prompts, knapp -> 12 Reserve-Prompts; S Beleg >= 0,9 M UND TP1 >= 0,9 M; K' Held-out H_X - H_CT <= 2 %; W nur berichtet. erfuellt = U2 oder U5 mit E,S,K' 3/3 und M5 nicht E 3/3; teilweise = U2 oder U5 mit E und S 3/3, M5 wie oben; verfehlt = U2 und U5 je E 0/3 oder S 0/3; keine_aussage sonst, auch wenn M5 ebenso E und S 3/3 erreicht.
Plan: Je Saat eine Kette auf rechner-a: U2, U5, M5 trainieren (OMP 3), dann mess6 + Text-Sonde frisch10 (sonde_ein.php) + Beam 24 Prompts in 3 Stroemen. Daneben Text-Sonde frisch10 und zweite 12 Prompts an M, CT, DT. ~2,7 h.
Baut auf: snai/ditto-selten, snai/ditto-anteil, snai/schleife-einstieg
Darauf baut: snai/ditto-maske, snai/ditto-eigen
Rezepte:
  r426 [2026-10-26] cd ~/snai_pruef/ditto2 && for k in 1 2 3; do (timeout 21600 bash ein.sh $k &); done; (timeout 18000 bash vorab_ein.sh &)
      quelltext: ein.sh 2304057b, textmess10.sh 3bbf1ab1, vorab_ein.sh 298a1a9d, beam12.sh f738a3d3, beam12n.sh a678460d, beam12r.sh d056c8f2 (Reserve), mess6.sh; lib bau/libcortex_EIN.so 693b6f99 (cortex_ein.nim aa8de9fa = patch_ein.py bf054657 auf ~/snai_pruef/ditto/cortex_ditto.nim 0706e513); Grenzliste daten/grenze.txt 915c9b6e (grenze_liste.php c45fcaa6, geprueft mit grenze_pruef.php fb611fbf); Sonde sonde_ein.php b413abd8 (patch_sonde_ein.py 22f5b262 auf sonde_selten.php ade5f9e3); Saetze saetze_frisch10.json df7f3c44 (saetze_frisch10.py c8860bf1)
      parameter: SNAI_DITTO_EIN=2/5 (U2, U5) bzw. 5 mit SNAI_DITTO_EIN_LAGE=mitte (M5), SNAI_DITTO_EIN_GRENZE=daten/grenze.txt, SNAI_DITTO_LAMBDA=0.5, SNAI_DITTO_LOG=1, Daten daten/mix_t.txt 81ea3be0, 1 Epoche ab drohneP_s19, LR 1e-4, Warmup 500, WD 0,1, SNAI_INT8_FULL=1, SNAI_TIE_EMBEDDINGS=1, SNAI_I8_MOM_SR=mv, SNAI_GAIN_GUARD=0, OMP 3, Ausgabename ft.snai
      seed: Saat 1/2/3 = Ordner proj/proj_s2/proj_s3 mit SNAI_START_OFFSET 0/1000003/2000003, Laufname ft
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/ditto2/log/{U2,U5,M5}_s{1,2,3}.log, log/ein.log, log/textmess10.log, log/textmess_beam.log, log/pab_e*.log (Rot-Probe); Arme arme/{U2,U5,M5}_s*.snai; Messungen mess/{ARM}_s*, mess/t10_*, mess/b12_*, mess/b12n_*
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ditto2/log/boot_ein.out c9b6c7d4 (boot_ein.py), bestraft aus log/{U2,U5,M5}_s?.log Fensterzeilen pen/n
  m5708 U/U_M (24 Prompts) | 0.74 | DT | s1 | 24
  m5709 Beleg/M | 0.72 | DT | s1 | 120
  m5710 TP1 nl/M | 0.54 | DT | s1 | 198
  m5711 Held-out - CT % | +2.5 | DT | s1 | 200
  m5712 U/U_M (24 Prompts) | 0.65 | DT | s2 | 24
  m5713 Beleg/M | 0.59 | DT | s2 | 120
  m5714 TP1 nl/M | 0.49 | DT | s2 | 198
  m5715 Held-out - CT % | +3.5 | DT | s2 | 200
  m5716 U/U_M (24 Prompts) | 0.81 | DT | s3 | 24
  m5717 Beleg/M | 0.55 | DT | s3 | 120
  m5718 TP1 nl/M | 0.52 | DT | s3 | 198
  m5719 Held-out - CT % | +2.6 | DT | s3 | 200
  m5720 U/U_M (24 Prompts) | 1.61 | U2 | s1 | 24
  m5721 Beleg/M | 1.10 | U2 | s1 | 120
  m5722 TP1 nl/M | 2.27 | U2 | s1 | 198
  m5723 Held-out - CT % | -0.1 | U2 | s1 | 200
  m5724 U/U_M (24 Prompts) | 1.76 | U2 | s2 | 24
  m5725 Beleg/M | 1.13 | U2 | s2 | 120
  m5726 TP1 nl/M | 2.24 | U2 | s2 | 198
  m5727 Held-out - CT % | +0.5 | U2 | s2 | 200
  m5728 U/U_M (24 Prompts) | 1.76 | U2 | s3 | 24
  m5729 Beleg/M | 1.03 | U2 | s3 | 120
  m5730 TP1 nl/M | 2.17 | U2 | s3 | 198
  m5731 Held-out - CT % | -0.3 | U2 | s3 | 200
  m5732 U/U_M (24 Prompts) | 1.53 | U5 | s1 | 24
  m5733 Beleg/M | 1.02 | U5 | s1 | 120
  m5734 TP1 nl/M | 1.63 | U5 | s1 | 198
  m5735 Held-out - CT % | +0.5 | U5 | s1 | 200
  m5736 U/U_M (24 Prompts) | 1.57 | U5 | s2 | 24
  m5737 Beleg/M | 1.04 | U5 | s2 | 120
  m5738 TP1 nl/M | 1.86 | U5 | s2 | 198
  m5739 Held-out - CT % | +0.8 | U5 | s2 | 200
  m5740 U/U_M (24 Prompts) | 1.77 | U5 | s3 | 24
  m5741 Beleg/M | 0.88 | U5 | s3 | 120
  m5742 TP1 nl/M | 1.71 | U5 | s3 | 198
  m5743 Held-out - CT % | +0.4 | U5 | s3 | 200
  m5744 U/U_M (24 Prompts) | 1.62 | M5 | s1 | 24
  m5745 Beleg/M | 1.03 | M5 | s1 | 120
  m5746 TP1 nl/M | 1.19 | M5 | s1 | 198
  m5747 Held-out - CT % | -0.4 | M5 | s1 | 200
  m5748 U/U_M (24 Prompts) | 1.54 | M5 | s2 | 24
  m5749 Beleg/M | 1.05 | M5 | s2 | 120
  m5750 TP1 nl/M | 1.20 | M5 | s2 | 198
  m5751 Held-out - CT % | -1.5 | M5 | s2 | 200
  m5752 U/U_M (24 Prompts) | 1.79 | M5 | s3 | 24
  m5753 Beleg/M | 0.94 | M5 | s3 | 120
  m5754 TP1 nl/M | 1.40 | M5 | s3 | 198
  m5755 Held-out - CT % | -1.3 | M5 | s3 | 200
  m5756 R nl/R_M | 0.249 | DT | s1 | 198
  m5757 TPe Kopie2/M nl | 0.24 | DT | s1 | 198
  m5758 R nl/R_M | 0.843 | U2 | s1 | 198
  m5759 TPe Kopie2/M nl | 0.37 | U2 | s1 | 198
  m5760 R nl/R_M | 0.913 | U5 | s1 | 198
  m5761 TPe Kopie2/M nl | 0.29 | U5 | s1 | 198
  m5762 R nl/R_M | 1.129 | M5 | s1 | 198
  m5763 TPe Kopie2/M nl | 2.26 | M5 | s1 | 198
  m5764 R nl/R_M | 0.144 | DT | s2 | 198
  m5765 TPe Kopie2/M nl | 0.16 | DT | s2 | 198
  m5766 R nl/R_M | 0.888 | U2 | s2 | 198
  m5767 TPe Kopie2/M nl | 0.31 | U2 | s2 | 198
  m5768 R nl/R_M | 0.870 | U5 | s2 | 198
  m5769 TPe Kopie2/M nl | 0.17 | U5 | s2 | 198
  m5770 R nl/R_M | 1.219 | M5 | s2 | 198
  m5771 TPe Kopie2/M nl | 2.47 | M5 | s2 | 198
  m5772 R nl/R_M | 0.159 | DT | s3 | 198
  m5773 TPe Kopie2/M nl | 0.16 | DT | s3 | 198
  m5774 R nl/R_M | 0.884 | U2 | s3 | 198
  m5775 TPe Kopie2/M nl | 0.21 | U2 | s3 | 198
  m5776 R nl/R_M | 0.861 | U5 | s3 | 198
  m5777 TPe Kopie2/M nl | 0.15 | U5 | s3 | 198
  m5778 R nl/R_M | 1.051 | M5 | s3 | 198
  m5779 TPe Kopie2/M nl | 1.84 | M5 | s3 | 198
  m5780 bestraft/Laufpositionen | 0,216 | U2 | s1 | 1209
  m5781 bestraft/Laufpositionen | 0,217 | U2 | s2 | 1214
  m5782 bestraft/Laufpositionen | 0,217 | U2 | s3 | 1198
  m5783 bestraft/Laufpositionen | 0,465 | U5 | s1 | 1209
  m5784 bestraft/Laufpositionen | 0,466 | U5 | s2 | 1214
  m5785 bestraft/Laufpositionen | 0,466 | U5 | s3 | 1198
  m5786 bestraft/Laufpositionen | 0,469 | M5 | s1 | 1209
  m5787 bestraft/Laufpositionen | 0,470 | M5 | s2 | 1214
  m5788 bestraft/Laufpositionen | 0,470 | M5 | s3 | 1198
Ergebnis e374 [2026-10-26 08:46]: verfehlt
  Fazit: Verfehlt (U2 und U5 je E 0/3). Das Kriterium stand vorher fest.
Die Strafe am Übergang trifft den Einstieg gezielt: Das erste Wort der zweiten Kopie liegt bei U5 bei 0,15–0,29 von M, bei der Kontrolle M5 mit gleicher Strafmenge in der Mitte bei 1,8–2,5 von M. Die Stelle ist damit isoliert.
Die Textausgabe folgt dem nicht. U2, U5 und M5 liegen gleichauf bei U 1,5–1,8 x M, also auf CT-Niveau.
Den Beleg schonen U2 und M5 3/3, U5 2/3, Held-out −1,5 bis +0,8 % gegen CT.
Deutung, nicht isoliert: Der Beam wiegt den unwahrscheinlichen Einstieg mit dem fast sicheren Rest der Kopie auf. Diesen Rest lernen die Arme über die CE auf den freien Wiederholungspositionen sogar stärker als M (TP1 1,6–2,3 x M).
Mit ditto-selten zusammen gilt: Jede CE auf wiederholten Positionen lehrt Kopieren, eine Teilstrafe wiegt das nicht auf.
Nächste Reihe: snai/ditto-maske. Die freien Positionen der Wiederholung bekommen gar keinen Verlust, mit dem Arm „nur Maske“ als Kontrolle.
  Offen: - Ob die Einstiegsstrafe mit maskiertem Rest wirkt (snai/ditto-maske).
- Ob die Deutung mit dem Beam stimmt: Gemessen sind nur TPe und die Kurve, nicht die Beam-Bewertung selbst.
  Datei: rechner-a:~/snai_pruef/ditto2/ERGEBNIS_einstieg.md
Chronik:
  2026-10-26 06:47 angelegt
  2026-10-26 06:48 Rezept r426
  2026-10-26 06:48 Status geplant -> laeuft (Rezept r426)
  2026-10-26 08:45 Messwerte m5708-m5788
  2026-10-26 08:46 Ergebnis e374: verfehlt
  2026-10-26 08:46 Status laeuft -> ausgewertet (Ergebnis e374)
```
