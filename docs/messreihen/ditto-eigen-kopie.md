# snai/ditto-eigen-kopie

```text
snai/ditto-eigen-kopie - ausgewertet, angelegt 2026-10-26, zuletzt 2026-10-26 19:52
Frage: Rettet ein Kopier-Gegengewicht im natuerlichen Text (CE x (1+b) auf seltenen Token, die frueher im Fenster schon Ziel waren) den Beleg unter UL auf eigenen Fortsetzungen (Rezept UQW), ohne die Schleifenwirkung aufzuheben?
Kriterium (festgelegt 2026-10-26 18:38, vor dem ersten Messwert):
  Je Arm (UKB1 b=1, UKB3 b=3) und Saat (1-6): E* U_X <= 0,9 U_M (24 Prompts Beam 3, unscharf K=2; knapp -> 12 Reserve, Urteil auf 36); S Beleg_X >= 0,9 Beleg_M und TP1_X >= 0,9 TP1_M; K' H_X - H_CT <= 2 %. 6/6 ja, 0/6 nein, sonst saatabhaengig. Arm zaehlt nur, wenn K0Q E* nicht 6/6 oder U_X <= 0,9 U_K0Q in 6/6. erfuellt = E*, S, K' je 6/6 -> nur Kandidat, Bestaetigung auf 3 neuen Saaten (7-9) mit 3/3 noetig. teilweise = E*, S 6/6, K' nicht; verfehlt = E* 0/6 oder S 0/6; sonst keine_aussage. Datei ~/snai_pruef/ditto2/kriterien_kopie.txt.
Plan: lib ULK (patch_ulk.py auf ULW, Rot-Probe bestanden); kop.sh 1..6 parallel auf rechner-a (UKB1, UKB3 ab M_sK auf eigen_sK, LR 2,5e-5), Messung mess6/textmess10/beam12/beam12n/beam12f; Auswertung boot_kop.py (Patch auf boot_best.py); Bezug M, CT, K0Q, UQW aus den Vorreihen.
Baut auf: snai/ditto-eigen-bestaetigung, snai/ditto-eigen-gewicht
Darauf baut: snai/ditto-eigen-kopie-bestaetigung, snai/ditto-eigen-prod512b, snai/ditto-eigen-prod512b-dosis
Rezepte:
  r435 [2026-10-26] cd ~/snai_pruef/ditto2; for k in 1 2 3 4 5 6; do nohup bash kop.sh $k & done   # kop.sh 2a6cfcc4; je Arm: env SNAI_UL_N=6 SNAI_UL_GEWICHT=0.5 SNAI_UL_KOPIE_BETA=<1|3> SNAI_UL_KOPIE_LISTE=daten/selten200.txt SNAI_UL_LOG=1 SNAI_CORTEX_LIB=bau/libcortex_ULK.so SNAI_START_OFFSET=<off> SNAI_TRAIN_MODE=pretrain SNAI_TIE_EMBEDDINGS=1 SNAI_INT8_FULL=1 SNAI_FORCE_CPU=1 SNAI_I8_MOM_SR=mv SNAI_WARMUP_STEPS=0 SNAI_GAIN_GUARD=0 OMP_NUM_THREADS=3 php train_cluster.php daten/eigen_sK.txt factory/checkpoints/ft.snai 1 1 factory/checkpoints/M_sK.snai 3 0.000025 0 1 0.1
      quelltext: patch_ulk.py d5c05311 auf cortex_ulw.nim 45fb6de4 -> cortex_ulk.nim 7a14fd33 -> bau/libcortex_ULK.so 55441278 (Quelle bausrc_ulk, Baulog bau/bauULK.log); kriterien_kopie.txt 51ab4c90
      parameter: Arme UKB1 (b=1), UKB3 (b=3); UL n=6 Gewicht 0,5; LR 2,5e-5, 1 Epoche, Warmup 0, WD 0,1; Liste selten200 (7992 Ids, Rang >= 200)
      seed: Saat am Laufnamen ft.snai; Offsets s1-6: 0 / 1000003 / 2000003 / 3000003 / 4000003 / 5000003; Basismodelle M_s1-3 (ditto/arme), M_s4-6 (ditto2/arme)
      rechner: rechner-a
      logs: ~/snai_pruef/ditto2/log/kop.log, log/UKB*_sK.log, mess/*UKB*_sK
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: ~/snai_pruef/ditto2/log/boot_kop.out (6e1f7493, 24 Prompts), log/boot_kop36.out (998c6c0a, nach Reserve), beleg_boot.py 8e3b67e9
  m5965 U/U_M (Beam 3, unscharf K=2; s2 auf 36 nach Reserve) | 0,60 / 0,77 [0,64-0,93] / 0,57 / 0,62 / 0,57 / 0,67 | UKB1 | s1-s6 | 24 (s2 36)
  m5966 U/U_M (s1-s3 auf 36 nach Reserve) | 0,80 [0,65-1,00] / 0,74 / 0,65 / 0,60 / 0,71 / 0,69 | UKB3 | s1-s6 | 24 (s1-3 36)
  m5967 Beleg/M (beleg_boot.py, Intervall nur berichtet) | 1,078 / 1,054 / 1,000 / 0,981 [0,953-1,011] / 1,059 / 1,022 | UKB1 | s1-s6 | 119
  m5968 Beleg/M | 1,166 / 1,120 / 1,073 / 1,061 / 1,137 / 1,115 | UKB3 | s1-s6 | 119
  m5969 Beleg/M (Bezug, gleiche Auswertung) | 0,985 / 0,975 / 0,912 / 0,894 / 0,979 / 0,922 | UQW | s1-s6 | 119
  m5970 Beleg_X/Beleg_UQW (gepaart) | 1,095 / 1,082 / 1,096 / 1,097 / 1,082 / 1,109 | UKB1 | s1-s6 | 119
  m5971 Beleg_X/Beleg_UQW (gepaart) | 1,185 / 1,149 / 1,177 / 1,187 / 1,161 / 1,210 | UKB3 | s1-s6 | 119
  m5972 U_X/U_UQW (24 Prompts) | 0,93 / 1,06 / 0,78 / 0,98 / 1,15 / 1,31 | UKB1 | s1-s6 | 24
  m5973 U_X/U_UQW (24 Prompts) | 1,30 / 1,01 / 0,92 / 0,96 / 1,45 / 1,37 | UKB3 | s1-s6 | 24
  m5974 U_X/U_K0Q (24 Prompts) | 0,63 / 0,70 / 0,55 / 0,77 / 0,74 / 0,76 | UKB1 | s1-s6 | 24
  m5975 U_X/U_K0Q (24 Prompts) | 0,87 / 0,67 / 0,65 / 0,75 / 0,94 / 0,79 | UKB3 | s1-s6 | 24
  m5976 TP1 nl /M | 1,17 / 1,13 / 1,08 / 0,97 / 1,06 / 1,16 | UKB1 | s1-s6 | 198
  m5977 TP1 nl /M | 1,22 / 1,20 / 1,13 / 1,04 / 1,12 / 1,24 | UKB3 | s1-s6 | 198
  m5978 H - H_CT | -4,5 / -5,7 / -5,8 / -5,7 / -5,1 / -6,1 % | UKB1 | s1-s6 | 200
  m5979 H - H_M | -1,3 / -1,6 / -1,1 / -0,9 / -1,1 / -1,7 % | UKB1 | s1-s6 | 200
  m5980 H - H_M | -0,9 / -1,2 / -0,8 / -0,6 / -0,7 / -1,2 % | UKB3 | s1-s6 | 200
  m5981 U/U_M frische 12 Prompts (nur berichtet) | 0,68 / 0,55 / 0,46 / 0,58 / 0,50 / 0,58 | UKB1 | s1-s6 | 12
  m5982 U/U_M frische 12 Prompts (nur berichtet) | 0,70 / 0,79 / 0,93 / 0,40 / 0,88 / 0,60 | UKB3 | s1-s6 | 12
  m5983 K0Q E* (Kontrolle) | 3/6 | K0Q | s1-s6 | 24
Ergebnis e383 [2026-10-26 19:52]: erfuellt
  Fazit: UKB1 (UQW + CE x2 auf seltenen Kopien im nat-Teil) und UKB3 (x4) erfuellen E*, S, K' je 6/6. UKB1: Schleife 0,57-0,77 x M (frische Prompts 0,46-0,68), Beleg 0,98-1,08 x M (kleinste Untergrenze 0,95), gepaart gegen UQW Beleg +8-11 % in 6/6 bei im Mittel gleicher Schleifenwirkung; TP1/Held-out besser als M. UKB3 kauft weiteren Beleg mit Schleife (frische Prompts bis 0,93). Der Hebel war ein Gegengewicht fuer den Kollateralschaden der Strafe, nicht die Strafe selbst. Nur Kandidat (Saaten 1-6 waren Suche); entschieden wird in snai/ditto-eigen-kopie-bestaetigung (UKB1, Saaten 7-9, laeuft).
  Offen: Bestaetigung auf 3 neuen Saaten laeuft. prod512b ungemessen. Gegengewicht trainiert die Beleg-Faehigkeit direkt (an nat-Text).
  Datei: ~/snai_pruef/ditto2/ERGEBNIS_kopie.md
Chronik:
  2026-10-26 18:38 angelegt
  2026-10-26 18:38 Rezept r435
  2026-10-26 18:38 Status geplant -> laeuft (Rezept r435)
  2026-10-26 19:52 Messwerte m5965-m5983
  2026-10-26 19:52 Ergebnis e383: erfuellt
  2026-10-26 19:52 Status laeuft -> ausgewertet (Ergebnis e383)
```
