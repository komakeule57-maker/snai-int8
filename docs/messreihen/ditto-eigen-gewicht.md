# snai/ditto-eigen-gewicht

```text
snai/ditto-eigen-gewicht - ausgewertet, angelegt 2026-10-26, zuletzt 2026-10-26 16:00
Frage: Senkt ein halbes Gewicht der Unlikelihood-Strafe (UQW) oder eine Strafe nur auf langen Wiederholungen n=12 (UQ12) bei LR 2,5e-5 die Beleg-Kosten so weit, dass S 3/3 haelt, waehrend U unter 0,9 M bleibt?
Kriterium (festgelegt 2026-10-26 15:02, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/ditto2/kriterien_gewicht.txt (md5 7473086d, mit Pruefer). Arme ab M_sK, lib ULW, LR 2,5e-5, je ein Stellrad gegen ULQ: UQW Gewicht 0,5 (n=6), UQ12 n=12. Kontrolle K0Q und Bezug ULQ aus snai/ditto-eigen-dosis, Wiederholbarkeit per bytegleichem Neulauf ULQ in s1. 3/3 ja, 0/3 nein, sonst saatabhaengig. E*: U_X <= 0,9 U_M (24 Prompts, knapp -> 36); S: Beleg und TP1 >= 0,9 M; K': H_X - H_CT <= 2 %. erfuellt = UQW oder UQ12 mit E*, S, K' 3/3 (dann Bestaetigung mit 3 neuen Saaten und 12 frischen Messprompts); teilweise = E*, S 3/3; verfehlt = beide je E* 0/3 oder S 0/3; sonst keine_aussage.
Plan: gew.sh je Saat, Auswertung boot_gew.py; Kriterien und Rot-Probe in kriterien_gewicht.txt
Baut auf: snai/ditto-eigen-dosis
Darauf baut: snai/ditto-eigen-bestaetigung, snai/ditto-eigen-kopie, snai/kopiersperre-kombi
Rezepte:
  r431 [2026-10-26] cd ~/snai_pruef/ditto2; for K in 1 2 3; do setsid nohup bash gew.sh $K > log/gew_s$K.nohup 2>&1 < /dev/null & done   (Start 15:02)
# gew.sh je Arm wie dos.sh mit lib ULW und LR 0.000025: UQW "SNAI_UL_N=6 SNAI_UL_GEWICHT=0.5", UQ12 "SNAI_UL_N=12", in s1 zusaetzlich ULQW "SNAI_UL_N=6" (Wiederholbarkeit gegen arme/ULQ_s1.snai, nicht gemessen); Messung mess6/textmess10/beam12/beam12n in 2 Stroemen
# Auswertung: python3 boot_gew.py > log/boot_gew.out
      quelltext: kriterien_gewicht.txt 7473086d; gew.sh ab1713d1; lib bau/libcortex_ULW.so 209b8472 (cortex_ulw.nim 45fb6de4 = patch_ulw.py 8556f96c auf cortex_ul.nim 659b7034, Bau bau/bauULW.log); boot_gew.py 4e82f843 (patch_boot_gew.py ef2a84b0 auf boot_dos.py 392e7238); Rot-Probe log/pul_w*.log; Worker/Messung wie r429
      parameter: Basis M_sK; Daten daten/eigen_sK.txt cce43387/353402d2/1881688c; 1 Epoche, LR 2,5e-5 konstant, Warmup 0, WD 0,1, OMP 3; UQW Gewicht 0,5 n=6, UQ12 Gewicht 1 n=12. Schritt 1 = K0Q (2,704194 / 3,441365 / 2,882508); GradNorm UQW s1 7,81 (K0 7,43, UL 9,22).
      seed: Saat am Laufnamen ft.snai; SNAI_START_OFFSET 0/1000003/2000003; Bootstrap Saat 20261024
      rechner: rechner-a
      logs: ~/snai_pruef/ditto2/log/{UQW,UQ12,ULQW}_sK.log, log/gew.log, log/gew_sK.nohup, mess/*_{UQW,UQ12}_sK/, arme/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ditto2/log/boot_gew36.out (981d16da, mit Reserve b12r fuer UQW s2/s3 und UQ12 s2; ohne Reserve log/boot_gew.out ed4f02fa). Fehlerkanal: 7 Laeufe rc=0, 0 NaN/Fatal/VETO/NET2NET, Schritt 1 gleich K0Q, Beam alle Saetze 12/12 rc=0 ohne Fehler, Text-Sonde nur Saetze 121/122. Wiederholbarkeit: ULQW_s1 (lib ULW ohne Gewicht) bytegleich zu ULQ_s1 (e9acdd6f)
  m5908 U/U_M [95-%-Intervall] | 0,64 [0,47-0,81] (24) / 0,73 [0,57-0,90] (36, knapp) / 0,62 [0,49-0,75] (36) | UQW | 1-3 | 24/36/36
  m5909 U/U_M [95-%-Intervall] | 0,64 [0,49-0,80] (24) / 0,81 [0,61-1,02] (36, knapp) / 0,62 [0,47-0,79] (24) | UQ12 | 1-3 | 24/36/24
  m5910 U/U_M auf 24 Prompts vor Reserve | UQW 0,64 / 0,77 / 0,73; UQ12 0,64 / 0,74 / 0,62 | UQW, UQ12 | 1-3 | 24
  m5911 Beleg A/A_M | 0,98 / 0,97 / 0,91 | UQW | 1-3 | 120
  m5912 Beleg A/A_M | 0,96 / 0,96 / 0,89 | UQ12 | 1-3 | 120
  m5913 TP1 nl /M | 1,09 / 1,04 / 1,02 | UQW | 1-3 | 198
  m5914 TP1 nl /M | 1,09 / 1,04 / 1,00 | UQ12 | 1-3 | 198
  m5915 Held-out H-H_CT / H-H_M | -4,4/-5,7/-5,7 % / -1,1/-1,5/-1,0 % | UQW | 1-3 | 200
  m5916 Held-out H-H_CT / H-H_M | -4,2/-5,6/-5,5 % / -0,9/-1,4/-0,8 % | UQ12 | 1-3 | 200
  m5917 U_X/U_K0Q (24 Prompts) | UQW 0,67 / 0,66 / 0,70; UQ12 0,68 / 0,63 / 0,60 | UQW, UQ12 | 1-3 | 24
  m5918 Kandidaten (Summe ueber die Fenster) | n=6 43196 / 34839 / 37645; n=12 33997 / 25555 / 28027 | UQW, UQ12 | 1-3 | ~115000
  m5919 Urteil je Arm | UQW E* 3/3 S 3/3 K' 3/3; UQ12 E* 3/3 S 2/3 (s3 Beleg 0,89) K' 3/3 | UQW, UQ12 | 1-3 | 3
Ergebnis e380 [2026-10-26 16:00]: erfuellt
  Fazit: UQW (Unlikelihood auf eigenen Beam-Fortsetzungen, Gewicht 0,5, n=6, LR 2,5e-5, 1 Epoche) erreicht als erster Arm der ganzen DITTO-Linie E*, S und K' je 3/3: U/M 0,64 / 0,73 / 0,62 (s2 und s3 nach Regel auf 36 Prompts), Beleg/M 0,98 / 0,97 / 0,91, TP1/M 1,02-1,09, Held-out 1,0-1,5 % unter M. UQ12 (n=12) senkt U gleich stark, schont den Beleg aber nicht (s3 0,89, S 2/3). Knapp erfuellt (U s2 Obergrenze 0,90, Beleg s3 0,91) auf Prompts, die ueber viele Reihen der Suche dienten: die vorab festgelegte Bestaetigung mit 3 neuen Basismodellen und 12 frischen Prompts ist Pflicht, bevor "behoben" gilt. Sie folgt sofort mit unveraendertem Rezept (snai/ditto-eigen-bestaetigung).
  Offen: Bestaetigung auf neuen Saaten steht aus. Ein Basismodell-Typ (128/4/4 int8), eine Erzeugungsrunde. Ob die Wirkung auf prod512b uebertraegt, ist ungemessen.
  Datei: rechner-a:~/snai_pruef/ditto2/ERGEBNIS_gewicht.md
Chronik:
  2026-10-26 15:02 angelegt
  2026-10-26 15:03 Rezept r431
  2026-10-26 15:03 Status geplant -> laeuft (Rezept r431)
  2026-10-26 15:59 Messwerte m5908-m5919
  2026-10-26 16:00 Ergebnis e380: erfuellt
  2026-10-26 16:00 Status laeuft -> ausgewertet (Ergebnis e380)
```
