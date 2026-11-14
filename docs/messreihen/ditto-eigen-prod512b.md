# snai/ditto-eigen-prod512b

```text
snai/ditto-eigen-prod512b - ausgewertet, angelegt 2026-10-26, zuletzt 2026-10-27 10:08
Frage: Senkt das unveraenderte Rezept UKB1 (vom Knirps) die Beam-Schleife von prod512b (Staende s3, s4, s5), ohne Beleg, TP1 und Held-out zu kosten?
Kriterium (festgelegt 2026-10-26 22:42, vor dem ersten Messwert):
  Je Stand s3/s4/s5: E* U_UKB1 <= 0,9 U_M (24 Prompts Beam 3, unscharf K=2, gepaarter Bootstrap; knapp -> 12 Reserve, Urteil auf 36); S Beleg >= 0,9 M und TP1 >= 0,9 M; K' H_UKB1 - H_M <= 2 % (gegen M statt CT); UKB1 zaehlt nur, wenn K0Q E* nicht 3/3 oder U_UKB1 <= 0,9 U_K0Q 3/3. 3/3 ja, 0/3 nein, sonst standabhaengig. erfuellt = alle drei 3/3 -> Schleife fuer prod512b behoben; knapp -> Wiederholung auf s6. teilweise = E*, S 3/3 ohne K'; verfehlt = E* oder S 0/3; sonst keine_aussage. Datei rechner-a:~/snai_pruef/ditto_p/kriterien_p.txt.
Plan: kette_p.sh: rechner-b s4, s5 (PAR 2), rechner-a s3 (PAR 1, ein prod512b-Prozess). Erzeugung 450 Fortsetzungen, K0Q und UKB1 (lib ULK, LR 2,5e-5, 1 Epoche), Messung M/K0Q/UKB1 mit ditto_p-Kopie der Knirps-Messung.
Baut auf: snai/ditto-eigen-kopie-bestaetigung, snai/ditto-eigen-kopie
Darauf baut: snai/ditto-eigen-prod512b-dosis, snai/ukb-runde2-prod512b
Rezepte:
  r438 [2026-10-26] rechner-b: cd ~/snai_pruef/ditto_p && for k in 4 5; do setsid nohup bash kette_p.sh $k 2 & done; rechner-a: cd ~/snai_pruef/ditto_p && setsid nohup bash kette_p.sh 3 1 &   # kette_p.sh ab3d3764; Training je Arm: env SNAI_UL_N=6 [K0Q: SNAI_UL_KAND=maske | UKB1: SNAI_UL_GEWICHT=0.5 SNAI_UL_KOPIE_BETA=1 SNAI_UL_KOPIE_LISTE=daten/selten200.txt] SNAI_UL_LOG=1 SNAI_CORTEX_LIB=bau/libcortex_ULK.so SNAI_START_OFFSET=0 SNAI_TRAIN_MODE=pretrain SNAI_TIE_EMBEDDINGS=1 SNAI_INT8_FULL=1 SNAI_FORCE_CPU=1 SNAI_I8_MOM_SR=mv SNAI_WARMUP_STEPS=0 SNAI_GAIN_GUARD=0 OMP_NUM_THREADS=3 php train_cluster.php daten/eigen_sK.txt factory/checkpoints/ft.snai 1 1 factory/checkpoints/M_sK.snai 3 0.000025 0 1 0.1
      quelltext: lib ULK 55441278 (Kopie, auf rechner-b per Knirps-Probe kU = c8cbc559 geprueft); Messgeraet ditto_p/proj_sr (libcortex.so 318b2655, snai_inference.php 8ba48a06); gen_eigen.sh d16fdd5f, bau_p.py 25e3496f, mess_p.sh 22a4d14d, textmess10.sh 8a3552e7, beam12* wie ditto2 mit Pfaden ditto_p und OMP 1; kriterien_p.txt 978b7af7
      parameter: Basis prod512b_s3/s4/s5 (deee2ea3 / 751d92d9 / 10ab21ad); nat-Teil pseg00.txt cfaa88d5 (Dokumente > 2500 Zeichen); Rezept UKB1 unveraendert vom Knirps
      seed: SNAI_START_OFFSET=0 je Stand; die "Saat" ist der Stand
      rechner: rechner-b (s4, s5), rechner-a (s3)
      logs: ~/snai_pruef/ditto_p/log/kette.log, log/*_sK.log, mess/ (auf beiden Rechnern)
  r439 [2026-10-27] rechner-b: cd ~/snai_pruef/ditto_p; OHNE_GEN=1 setsid nohup bash kette_pb.sh 4 2 & ; OHNE_GEN=1 setsid nohup bash kette_pb.sh 5 2 &  (Neustart ab Training, 02:44)
      quelltext: bau_p.py v2 46107a4f (patch_bau_p2.py 16bd97a1, ersetzt 25e3496f), kette_pb.sh 494cefad (= kette_p.sh ab3d3764 + OHNE_GEN), kriterien_p.txt Nachtrag 53d9dabe
      parameter: unveraendert UKB1/K0Q wie Erststart; Daten eigen_s4 9b807620 (450, 925170 B), eigen_s5 78339393 (450, 919457 B)
      rechner: rechner-b (s4, s5); rechner-a s3 laeuft mit kette_p.sh weiter, baut mit v2
      logs: ~/snai_pruef/ditto_p/log/kette.log, log/kette_pb_s4.out, log/kette_pb_s5.out
  r440 [2026-10-27] rechner-a: cd ~/snai_pruef/ditto_p; OHNE_GEN=1 setsid nohup bash kette_pb.sh 3 1 &  (Neustart s3 ab Training, 04:56). Korrektur zu r439: Neustart s4/s5 war 02:31, nicht 02:44.
      quelltext: bau_p.py v3 a310d91f (patch_bau_p3.py 49c34ee4; kurz ohne strip), kette_pb.sh 494cefad, kriterien_p.txt Nachtrag 2; v3 auf s4/s5 bytegleich zu v2
      parameter: unveraendert UKB1/K0Q; Daten eigen_s3 00cf6433 (450, 847560 B)
      rechner: rechner-a (s3, PAR 1, ein prod512b-Prozess)
      logs: ~/snai_pruef/ditto_p/log/kette.log, log/kette_pb_s3.out
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: ~/snai_pruef/ditto_p/log/boot_p.out 91a6ef27 (boot_p.py 801396cb); Beleg-Intervalle beleg_boot.py
  m6074 U/U_M | 0.95 [0.81-1.11] | K0Q | s3 | 24
  m6075 U/U_M | 0.93 [0.82-1.05] | K0Q | s4 | 36
  m6076 U/U_M | 0.95 [0.80-1.14] | K0Q | s5 | 36
  m6077 U/U_M | 0.71 [0.58-0.84] | UKB1 | s3 | 24
  m6078 U/U_M | 0.78 [0.68-0.89] | UKB1 | s4 | 36
  m6079 U/U_M | 0.58 [0.44-0.73] | UKB1 | s5 | 24
  m6080 Beleg/M | 0.97 | K0Q | s3 | 119
  m6081 Beleg/M | 0.97 | K0Q | s4 | 119
  m6082 Beleg/M | 0.96 | K0Q | s5 | 119
  m6083 Beleg/M | 0.97 [0.95-0.99] | UKB1 | s3 | 119
  m6084 Beleg/M | 0.98 [0.96-1.01] | UKB1 | s4 | 119
  m6085 Beleg/M | 1.00 [0.98-1.02] | UKB1 | s5 | 119
  m6086 TP1 nl/M | 0.99 | K0Q | s3 | 198
  m6087 TP1 nl/M | 0.97 | K0Q | s4 | 198
  m6088 TP1 nl/M | 1.05 | K0Q | s5 | 198
  m6089 TP1 nl/M | 0.89 | UKB1 | s3 | 198
  m6090 TP1 nl/M | 0.88 | UKB1 | s4 | 198
  m6091 TP1 nl/M | 0.95 | UKB1 | s5 | 198
  m6092 H-H_M % | -0.5 | K0Q | s3 | 200
  m6093 H-H_M % | -0.6 | K0Q | s4 | 200
  m6094 H-H_M % | -0.5 | K0Q | s5 | 200
  m6095 H-H_M % | +1.1 | UKB1 | s3 | 200
  m6096 H-H_M % | +1.5 | UKB1 | s4 | 200
  m6097 H-H_M % | +1.5 | UKB1 | s5 | 200
  m6098 U_UKB1/U_K0Q | 0.75 | UKB1 | s3 | 24
  m6099 U_UKB1/U_K0Q | 0.85 | UKB1 | s4 | 24
  m6100 U_UKB1/U_K0Q | 0.65 | UKB1 | s5 | 24
  m6101 U/U_M frisch (nur berichtet) | 0.72 / 0.86 / 0.79 | UKB1 | s3/s4/s5 | 12
Ergebnis e388 [2026-10-27 10:08]: keine_aussage
  Fazit: UKB1 (unveraendert vom Knirps) senkt die Beam-Schleife von prod512b in 3/3 Staenden (0,58-0,78 x M, Kontrolle 0,93-0,95) bei gehaltenem Beleg (0,97-1,00) und Held-out (+1,1 bis +1,5 %), kostet aber an s3/s4 Kopierfaehigkeit TP1 0,89/0,88 x M (Schwelle 0,9) -> S 1/3, damit nach Regel keine Aussage. "Wirkt, mit knapp zu hohem Preis"; anders als am Knirps (TP1 stieg). Folgefrage (staerkeres Gegengewicht b=2/3) laeuft als snai/ditto-eigen-prod512b-dosis; danach enden die Schleifenreihen.
  Offen: Ob b=2/3 TP1 ueber 0,9 hebt ohne Schleifenwirkung zu verlieren (snai/ditto-eigen-prod512b-dosis). Wirkung zusammen mit der Kopiersperre (DS) ungemessen. K0Q-Reserve fuer s3 nicht gefahren (aendert das Urteil nicht).
  Datei: ~/snai_pruef/ditto_p/ERGEBNIS_p.md
Chronik:
  2026-10-26 22:42 angelegt
  2026-10-26 22:42 Rezept r438
  2026-10-26 22:42 Status geplant -> laeuft (Rezept r438)
  2026-10-27 02:32 Rezept r439
  2026-10-27 04:58 Rezept r440
  2026-10-27 10:08 Messwerte m6074-m6101
  2026-10-27 10:08 Ergebnis e388: keine_aussage
  2026-10-27 10:08 Status laeuft -> ausgewertet (Ergebnis e388)
```
