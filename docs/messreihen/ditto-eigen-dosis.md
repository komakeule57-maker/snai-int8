# snai/ditto-eigen-dosis

```text
snai/ditto-eigen-dosis - ausgewertet, angelegt 2026-10-26, zuletzt 2026-10-26 15:03
Frage: Erreicht Unlikelihood auf eigenen Beam-Fortsetzungen mit kleinerer Lernrate (5e-5, 2,5e-5 statt 1e-4) die Schleifensenkung E* UND den Erhalt von Beleg und TP1 (S), weil die Schleife bei LR 1e-4 viel Abstand zur Schwelle hatte?
Kriterium (festgelegt 2026-10-26 13:35, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/ditto2/kriterien_dosis.txt (md5 30aca539, mit Pruefer). Arme ab M_sK auf daten/eigen_sK.txt, lib UL, n=6: K0H/ULH LR 5e-5, K0Q/ULQ LR 2,5e-5 (Kontrolle = Strafe aus). 3 Saaten gepaart; 3/3 ja, 0/3 nein, sonst saatabhaengig. E*: U_X <= 0,9 U_M (24 Prompts, knapp -> 36). S: Beleg >= 0,9 M und TP1 >= 0,9 M. K': H_X - H_CT <= 2 %. Ein UL-Arm zaehlt nur, wenn seine Kontrolle E* nicht 3/3 erreicht oder U_X <= 0,9 U_Kontrolle 3/3. erfuellt = zaehlender Arm mit E*, S, K' 3/3 (dann Bestaetigung mit 3 neuen Saaten); teilweise = E*, S 3/3; verfehlt = ULH und ULQ je E* 0/3 oder S 0/3; sonst keine_aussage.
Plan: rechner-a:~/snai_pruef/ditto2/kriterien_dosis.txt; dos.sh je Saat (4 Arme nacheinander, dann Messung in 4 Stroemen), Auswertung boot_dos.py
Baut auf: snai/ditto-eigen
Darauf baut: snai/ditto-eigen-gewicht
Rezepte:
  r430 [2026-10-26] cd ~/snai_pruef/ditto2; for K in 1 2 3; do setsid nohup bash dos.sh $K > log/dos_s$K.nohup 2>&1 < /dev/null & done   (Start 13:35)
# dos.sh je Arm wie eig.sh, nur LR: K0H "SNAI_UL_N=6 SNAI_UL_KAND=maske" 0.00005, ULH "SNAI_UL_N=6" 0.00005, K0Q "SNAI_UL_N=6 SNAI_UL_KAND=maske" 0.000025, ULQ "SNAI_UL_N=6" 0.000025; danach mess6/textmess10/beam12/beam12n in 4 Stroemen
# Auswertung: python3 boot_dos.py | tee log/boot_dos.out (knapp: bash beam12r.sh X_sK ~/snai_pruef/ditto2/arme/X_sK.snai)
      quelltext: kriterien_dosis.txt 30aca539; dos.sh d7cc9d90 (aus eig.sh e65d1c6b); boot_dos.py 392e7238 (patch_boot_dos.py 9f130f33 auf boot_eig.py aa0bd029); lib bau/libcortex_UL.so dc357ab1; train_worker.php 1f795e41; Messgeraete wie snai/ditto-eigen (r429)
      parameter: Basis M_sK (a69e1f4b/73fdf529/48c5cef3); Daten daten/eigen_sK.txt cce43387/353402d2/1881688c (aus snai/ditto-eigen); 1 Epoche (514 Schritte s1), LR 5e-5 bzw. 2,5e-5 konstant (Log: "LR: 0.000050"), Warmup 0, WD 0,1, OMP 3, n=6. Schritt 1 K0H = K0 aus ditto-eigen (2,704194 / 3,441365 / 2,882508, GradNorm gleich).
      seed: Saat am Laufnamen ft.snai; SNAI_START_OFFSET 0/1000003/2000003; Bootstrap Saat 20261024
      rechner: rechner-a
      logs: ~/snai_pruef/ditto2/log/{K0H,ULH,K0Q,ULQ}_sK.log, log/dos.log, log/dos_sK.nohup, mess/*_{K0H,ULH,K0Q,ULQ}_sK/, arme/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ditto2/log/boot_dos.out (ce00f187; boot_dos.py 392e7238). Fehlerkanal: 12 Laeufe rc=0, 0 NaN/Fatal/VETO/NET2NET, Schritt 1 gleich K0 aus ditto-eigen, Beam 24/24 rc=0 ohne Fehler, Text-Sonde nur Saetze 121/122; je Saat eine [UL]-Logzeile durch gleichzeitiges Schreiben abgeschnitten (Kandidatensummen weichen darum um <0,4 % ab)
  m5862 U/U_M (24 Prompts) | 0,87 / 1,05 / 0,82 | K0H | 1-3 | 24
  m5863 U/U_M (24 Prompts) [95-%-Intervall] | 0,46 [0,37-0,57] / 0,58 [0,41-0,80] / 0,42 [0,27-0,63] | ULH | 1-3 | 24
  m5864 U/U_M (24 Prompts) | 0,95 / 1,17 / 1,04 | K0Q | 1-3 | 24
  m5865 U/U_M (24 Prompts) [95-%-Intervall] | 0,51 [0,36-0,70] / 0,73 [0,54-1,00] knapp / 0,52 [0,36-0,72] | ULQ | 1-3 | 24
  m5866 Beleg A/A_M | 1,01 / 1,00 / 0,93 | K0H | 1-3 | 120
  m5867 Beleg A/A_M | 0,95 / 0,94 / 0,85 | ULH | 1-3 | 120
  m5868 Beleg A/A_M | 1,03 / 1,03 / 0,97 | K0Q | 1-3 | 120
  m5869 Beleg A/A_M | 0,97 / 0,96 / 0,89 | ULQ | 1-3 | 120
  m5870 TP1 nl /M | 1,09 / 1,12 / 1,06 | K0H | 1-3 | 198
  m5871 TP1 nl /M | 1,02 / 1,01 / 0,91 | ULH | 1-3 | 198
  m5872 TP1 nl /M | 1,11 / 1,13 / 1,09 | K0Q | 1-3 | 198
  m5873 TP1 nl /M | 1,09 / 1,02 / 0,98 | ULQ | 1-3 | 198
  m5874 Held-out H-H_CT / H-H_M | -3,9/-5,2/-5,3 % / -0,6/-1,0/-0,6 % | K0H | 1-3 | 200
  m5875 Held-out H-H_CT / H-H_M | -3,1/-4,5/-4,0 % / +0,2/-0,2/+0,7 % | ULH | 1-3 | 200
  m5876 Held-out H-H_CT / H-H_M | -4,9/-6,1/-6,2 % / -1,6/-1,9/-1,6 % | K0Q | 1-3 | 200
  m5877 Held-out H-H_CT / H-H_M | -4,1/-5,4/-5,4 % / -0,8/-1,2/-0,6 % | ULQ | 1-3 | 200
  m5878 U_UL/U_Kontrolle | ULH/K0H 0,53 / 0,55 / 0,51; ULQ/K0Q 0,53 / 0,62 / 0,50 (beide 3/3 unter 0,9) | ULH, ULQ | 1-3 | 24
  m5879 Beleg UL/Kontrolle | ULH/K0H 0,94 / 0,94 / 0,91; ULQ/K0Q 0,94 / 0,93 / 0,92 | ULH, ULQ | 1-3 | 120
  m5880 Urteil je Arm | K0H E* 2/3 S 3/3; ULH E* 3/3 S 2/3 K' 3/3; K0Q E* 0/3 S 3/3; ULQ E* 3/3 (s2 knapp) S 2/3 K' 3/3 | alle | 1-3 | 3
Ergebnis e378 [2026-10-26 15:03]: keine_aussage
  Fazit: Kleinere LR beseitigt die Drift des Weitertrainings (Kontrollen K0H/K0Q bei Beleg und Held-out auf oder ueber M), aendert aber die Wirkung von UL gegen die eigene Kontrolle nicht (U ~0,5-0,6, Beleg ~0,91-0,94 bei allen drei LR). ULQ (LR 2,5e-5): U/M 0,51 / 0,73 (knapp) / 0,52, Held-out 0,6-1,2 % unter M, TP1 ok, Beleg 0,97 / 0,96 / 0,89 -> S 2/3, nur Saat 3 fehlt um 0,01. ULH ebenso S 2/3 (s3 0,85). Nach Vorab-Regel keine_aussage, nicht umgedeutet. Die LR ist als Hebel ausgereizt; naechster Hebel ist das Verhaeltnis Strafe zu MLE und die Laenge der bestraften Wiederholung: snai/ditto-eigen-gewicht (Gewicht 0,5 bzw. n=12, LR 2,5e-5).
  Offen: Reserve fuer ULQ s2 nicht gefahren (aendert das Urteil nicht). Ob die Beleg-Luecke in s3 an der Basis M_s3 liegt (hoechster Beleg der drei) oder an UL, ist nicht getrennt. Eine Erzeugungsrunde, ein Basismodell, dieselben 36 Messprompts.
  Datei: rechner-a:~/snai_pruef/ditto2/ERGEBNIS_dosis.md
Chronik:
  2026-10-26 13:35 angelegt
  2026-10-26 13:36 Rezept r430
  2026-10-26 13:36 Status geplant -> laeuft (Rezept r430)
  2026-10-26 14:55 Messwerte m5862-m5880
  2026-10-26 15:03 Ergebnis e378: keine_aussage
  2026-10-26 15:03 Status laeuft -> ausgewertet (Ergebnis e378)
```
