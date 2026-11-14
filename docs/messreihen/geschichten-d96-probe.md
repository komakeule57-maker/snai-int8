# snai/geschichten-d96-probe

```text
snai/geschichten-d96-probe - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:30
Frage: Lernt ein Knirps 96x2 aus den Nano-Geschichten (kurze Kindergeschichten der Schlussfolgern-Textsammlung) etwas Verwertbares, also lesbare Geschichten?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/schluss/knirps96/kriterien.txt (= rechner-b:~/snai_pruef/knirps_gpu/geschichten/kriterien.txt; laut Text vor dem Start, 2026-10-15 ~13:50).):
  'Verwertbar' am Ende (T 0,8, 50 Geschichten): V1 >= 50 % bestehen den Grundfilter (>= 3 Saetze, bekannte Zeichen, keine Silbenpaare); V2 <= 10 % woertliche Kopien einer Trainingsgeschichte; V3 Held-out-Loss unter dem Trigramm. Alle drei = verwertbar in diesem Sinn. Rot-Probe: gemischte Fenster deutlich schlechter. Reichweite vorab: ein Lauf, eine Saat -> Beobachtung.
Baut auf: snai/natur-leanstral-probe
Darauf baut: snai/geschichten-tiefe
Rezepte:
  r62 [2026-10-21] SNAI_LR_DECAY_STEPS=25000 nice -n 5 ./lauf_geschichten.sh proj_t gesch_d96h6L<L>_s<S> 0.001 5 factory/checkpoints/gesch_gen_d96h6L<L>_s<S>.snai (darin je Segment: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 php train_cluster.php factory/input/geschichten_seg<I>.txt <aus> 1 1 <vorgaenger> 3 0.001 0.0001 1 0.1); Genesis: SNAI_VOCAB=... php init_base.php <ziel> 0 96 128 <L> 384 <S> + .heads 6
      quelltext: proj_t: cortex.nim 7e8a0516, libcortex.so 563780e3 (md5 heute); lauf_geschichten.sh 87ee67db, reihe_tiefe.sh b2439bcf; Korpus rechner-a:~/snai_pruef/schluss/knirps96/bauen.py
      parameter: Nano-Geschichten (alle Quellen der Schlussfolgern-Textsammlung, Filter natuertext.py, Wortschatz 1.500, gemischt Saat 4711), 3.000 Geschichten Held-out, 5 Segmente a ~640.000 Token (5.000 Fenster ctx 128), Vokabular wortweise 1.509; 96 breit, 6 Koepfe, ffn 384, ctx 128, gebunden, INT8_FULL, LR 0,001 -> 0,0001 Cosinus ueber 25.000, Warmup 500, WD 0,1, 1 Arbeiter, Revival aus, CPU OMP 2, Lade-Waechter aus; L = 2
      seed: Genesis 1
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/knirps_gpu/log/proj_t/gesch_d96h6L2_s1.log, .mess.jsonl, .stichprobe.txt, .kontext.jsonl, _s<I>.train.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/knirps_gpu/log/proj_t/gesch_d96h6L2_s1.mess.jsonl (Loss nachgelesen); V1/V2/Kontext aus kriterien.txt
  m603 Held-out-Loss Segment 0-4 | 2,5973 / 2,4480 / 2,3444 / 2,2691 / 2,2285 | d96L2 | 1 | 300
  m604 Trigramm-Loss | 2,647 | Trigramm |  | 300
  m605 Rot-Probe gemischt | 9,166 | d96L2 | 1 | 300
  m606 V1 Grundfilter bestanden | 49 von 50 (98 %) | d96L2 | 1 | 50
  m607 V2 woertliche Kopien | 0 von 50 | d96L2 | 1 | 50
  m608 Kontext-Sonde Loss nach k Token | k1 3,18 / k4 2,53 / k8 2,37 / k16 2,24 / k32 2,20 | d96L2 | 1
  m609 Fehlerkanal Trainingslogs | 0 Zeilen | d96L2 | 1 | 5
Ergebnis e57 [2026-10-21 14:30]: beobachtung
  Fazit: Beobachtung, weil Einzellauf (die Kriteriendatei nennt ihn selbst so): V1-V3 sind erfuellt, der 96x2-Knirps schreibt nach 25.000 Schritten (~25 min CPU) Geschichten mit Satzform und Grammatik, ohne zu kopieren, und liegt unter dem Trigramm. Die Tiefenreihe (snai/geschichten-tiefe) zeigt dasselbe mit drei Saaten: alle drei L2-Laeufe bestehen V1-V3 und enden bei 2,219-2,229. Inhaltlicher Zusammenhang nur stellenweise; der Kontextgewinn endet bei ~16-32 Token (Deutung: etwa eine Geschichte). Damit wurde der Nano-Geschichten-Korpus zum Standard-Pruefstand fuer Knirps-Fragen (Tiefe, PyTorch-Vergleich, Tempo, RAM).
  Offen: Lesbarkeit wurde an 5 Geschichten von Hand beurteilt (nicht protokolliert).
  Datei: rechner-a:~/snai_pruef/schluss/knirps96/kriterien.txt (Ergebnisabschnitt)
Chronik:
  2026-10-21 14:29 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/schluss/knirps96/kriterien.txt (= rechner-b:~/snai_pruef/knirps_gpu/geschichten/kriterien.txt; laut Text vor dem Start, 2026-10-15 ~13:50).)
  2026-10-21 14:29 Rezept r62
  2026-10-21 14:29 Status geplant -> laeuft (Rezept r62)
  2026-10-21 14:29 Messwerte m603-m609
  2026-10-21 14:30 Ergebnis e57: beobachtung
  2026-10-21 14:30 Status laeuft -> ausgewertet (Ergebnis e57)
```
