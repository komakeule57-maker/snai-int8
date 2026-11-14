# snai/ditto-eigen-kopie-bestaetigung

```text
snai/ditto-eigen-kopie-bestaetigung - ausgewertet, angelegt 2026-10-26, zuletzt 2026-10-26 22:10
Frage: Wiederholt Rezept UKB1 (UL auf eigenen Fortsetzungen + Kopier-Gegengewicht b=1) auf drei neuen Basismodellen (Saaten 7-9) E*, S und K' je 3/3?
Kriterium (festgelegt 2026-10-26 19:49, vor dem ersten Messwert):
  Je Saat 7/8/9: E* U_UKB1 <= 0,9 U_M (24 Prompts Beam 3, unscharf K=2; knapp -> 12 Reserve, Urteil auf 36); S Beleg >= 0,9 M und TP1 >= 0,9 M; K' H - H_CT <= 2 %; UKB1 zaehlt nur, wenn K0Q E* nicht 3/3 oder U_UKB1 <= 0,9 U_K0Q 3/3. 3/3 ja, 0/3 nein, sonst saatabhaengig. erfuellt = alle drei 3/3 -> Schleife behoben (128/4/4 int8, Rezept UKB1). Frische 12 Prompts nur berichtet. Datei ~/snai_pruef/ditto2/kriterien_best2.txt.
Plan: best2.sh 7/8/9 parallel auf rechner-a (neue M, CT, eigene Fortsetzungen, K0Q, UKB1 mit lib ULK), Messung wie bestaetigung, Auswertung boot_best2.py.
Baut auf: snai/ditto-eigen-kopie, snai/ditto-eigen-bestaetigung
Darauf baut: snai/ditto-eigen-prod512b, snai/ss-knirps
Rezepte:
  r437 [2026-10-26] cd ~/snai_pruef/ditto2; for k in 7 8 9; do nohup bash best2.sh $k & done   # best2.sh 009c6b9d (= best.sh 80da2bf6 mit Offsets 6000003/7000003/8000003, Arm UKB1: SNAI_UL_N=6 SNAI_UL_GEWICHT=0.5 SNAI_UL_KOPIE_BETA=1 SNAI_UL_KOPIE_LISTE=daten/selten200.txt, lib ULK fuer K0Q und UKB1)
      quelltext: lib ULK 55441278 (patch_ulk.py d5c05311), lib D e4bb3a0f fuer M/CT; kriterien_best2.txt 039c87f7; Auswertung boot_best2.py 35a7b3ca
      parameter: M/CT: 1 Epoche LR 1e-4 Warmup 500 ab drohneP_s19; K0Q/UKB1: 1 Epoche LR 2,5e-5 Warmup 0 WD 0,1 OMP 3 ab M_sK auf eigen_sK
      seed: Saat am Laufnamen; Offsets s7/s8/s9 = 6000003 / 7000003 / 8000003
      rechner: rechner-a
      logs: ~/snai_pruef/ditto2/log/best2.log, log/*_s[789].log, mess/*_s[789]
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: ~/snai_pruef/ditto2/log/boot_best2.out (6d33c2c5, 24 Prompts), log/boot_best2_36.out (3bb639ea, nach Reserve), beleg_boot.py 8e3b67e9
  m6007 U/U_M (Beam 3, unscharf K=2; s7/s8 auf 36 nach Reserve) | 0,68 [0,52-0,85] / 0,83 [0,68-1,02] / 0,56 [0,44-0,72] | UKB1 | s7/s8/s9 | 36/36/24
  m6008 U/U_M (24 Prompts) | 0,97 / 1,37 / 0,74 | K0Q | s7/s8/s9 | 24
  m6009 U_UKB1/U_K0Q (24 Prompts) | 0,72 / 0,61 / 0,76 | UKB1 | s7/s8/s9 | 24
  m6010 Beleg/M (beleg_boot.py, Intervall nur berichtet) | 0,948 [0,926-0,971] / 1,136 [1,100-1,172] / 0,967 [0,942-0,991] | UKB1 | s7/s8/s9 | 119
  m6011 Beleg/M | 0,927 / 1,087 / 0,926 | K0Q | s7/s8/s9 | 119
  m6012 TP1 nl /M | 1,10 / 1,25 / 0,96 | UKB1 | s7/s8/s9 | 198
  m6013 H - H_CT | -5,6 / -5,5 / -5,6 % | UKB1 | s7/s8/s9 | 200
  m6014 H - H_M | -1,4 / -1,7 / -1,0 % | UKB1 | s7/s8/s9 | 200
  m6015 U/U_M frische 12 Prompts (nur berichtet) | 0,65 [0,44-0,94] / 0,74 [0,53-1,02] / 0,55 [0,36-0,76] | UKB1 | s7/s8/s9 | 12
  m6016 U/U_M frische 12 Prompts (nur berichtet) | 0,96 / 0,93 / 0,75 | K0Q | s7/s8/s9 | 12
  m6017 U_UKB1/U_M gepoolt ueber 9 Saaten (24 Prompts je Saat, gepaarter Bootstrap, nur berichtet) | 0,652 [0,599-0,706] | UKB1 | s1-s9 | 216
  m6018 Ausgaben unter 20 Woertern (diag/kurz.py) | 0/324 | UKB1 | s1-s9 | 324
Ergebnis e385 [2026-10-26 22:10]: erfuellt
  Fazit: Rezept UKB1 (UL 0,5 auf wiederholten 6-Grammen der eigenen Beam-Fortsetzungen + CE x2 auf seltenen Kopien im nat-Teil, LR 2,5e-5, 1 Epoche) erfuellt E*, S, K' 3/3 auf drei neuen Basismodellen (s7-9): Schleife 0,68 / 0,83 / 0,56 x M (s7/s8 auf 36 nach Reserve), Beleg 0,95-1,14 x M, TP1/Held-out wie oder besser als M; Kontrolle K0Q E* nur 1/3. Damit ist die Schleife fuer Drohne P 128/4/4 int8 behoben. Grenze: s8 Intervall bis 1,02 (Punktwert nach Regel 0,83); gepoolt ueber 9 Saaten 0,65 [0,60-0,71]. Behoben heisst rund zwei Drittel von M, nicht null. Offen: Uebertragung auf prod512b (gesondert zu entscheiden) und Zusammenspiel mit der Kopiersperre.
  Offen: prod512b ungemessen; Kombination mit Kopiersperre ungemessen; Gegengewicht trainiert die Beleg-Faehigkeit direkt.
  Datei: ~/snai_pruef/ditto2/ERGEBNIS_best2.md
Chronik:
  2026-10-26 19:49 angelegt
  2026-10-26 19:49 Rezept r437
  2026-10-26 19:49 Status geplant -> laeuft (Rezept r437)
  2026-10-26 22:10 Messwerte m6007-m6018
  2026-10-26 22:10 Ergebnis e385: erfuellt
  2026-10-26 22:10 Status laeuft -> ausgewertet (Ergebnis e385)
```
