# snai/merkmal-gains

```text
snai/merkmal-gains - ausgewertet, begonnen 2026-10-18, angelegt 2026-10-21, zuletzt 2026-10-21 19:23
Frage: Was legt die RMS-Gains vor dem FFN der Schicht 1 still, wenn mit zufaellig gerundeten Momenten ab Genesis trainiert wird: Rundungsrauschen (Kandidat 1) oder korrektes Adam ohne Ratsche (Kandidat 2)?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/sr/kriterien_gains.txt, Kopf '2026-10-18, VOR dem Start', Ergebnis angefuegt):
  Messgroesse Median |L1.rms_ffn| am Ende s0. Je Arm: KIPPT = Median < 0,05 in allen drei Saaten; GESUND = Median >= 0,3 in allen drei; sonst saatabhaengig. Pflichtkontrolle: G0 GESUND und GMV KIPPT. Lesart vorab: GF KIPPT -> Kandidat 2; GF GESUND, GM KIPPT, GV GESUND -> Kandidat 1 (Rauschen in m).
Baut auf: snai/merkmal-sr-lang
Darauf baut: snai/merkmal-gains-fp32, snai/gains-bestand, snai/gains-archaeologie, snai/gains-v, snai/ratsche-k64
Rezepte:
  r158 [2026-10-21] bash ~/snai_pruef/knirps_sr/lauf_gains.sh <GV|GM|GF> <saat> (php train_cluster.php factory/input/gross_c64_seg0.txt factory/checkpoints/gross_gross_s<S>_s0.snai 1 1 <Genesis gross_gen_s<S>> 3 0.001 0.0001 1 0.1 mit SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=727208; SNAI_I8_MOM_SR=v bzw. m, GF: SNAI_I8_MOMENTE_8BIT=0); php gains_sr.php, produkt_sr.php
      quelltext: proj_sr_basis, libcortex.so dfcc4711; lauf_gains.sh 74711555, gains_sr.php 06dea5e6, produkt_sr.php a0fe2883
      parameter: d96 Schach, Korpus gross, LR 0,001 Cosinus bis 727208, Warmup 500, WD 0,1 inkl. Embeddings, gebunden, int8 FULL, CPU, OMP 1, Revival und Lade-Waechter aus; nur Segment s0; G0 = langQ0 s0 und GMV = langMV s0 wiederverwendet (deterministisch)
      seed: Saat 1, 2, 3
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/knirps_sr/log_gains/, lang_gains<Arm>_s<S>.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/knirps_sr/lang_gains{GV,GM,GF}_s{1,2,3}.jsonl (F, L am 2026-10-21 gelesen); Gains-Mediane aus kriterien_gains.txt (gains_sr.php)
  m1716 Median L1.rms_ffn s0 | 1,233 | G0 | 1 | 96
  m1717 Median L1.rms_ffn s0 | 0,913 | G0 | 2 | 96
  m1718 Median L1.rms_ffn s0 | 0,531 | G0 | 3 | 96
  m1719 Median L1.rms_ffn s0 | 1,205 | GM | 1 | 96
  m1720 Median L1.rms_ffn s0 | 0,872 | GM | 2 | 96
  m1721 Median L1.rms_ffn s0 | 0,709 | GM | 3 | 96
  m1722 Median L1.rms_ffn s0 | 0,004 | GV | 1 | 96
  m1723 Median L1.rms_ffn s0 | 0,005 | GV | 2 | 96
  m1724 Median L1.rms_ffn s0 | 0,003 | GV | 3 | 96
  m1725 Median L1.rms_ffn s0 | 0,003 | GF | 1 | 96
  m1726 Median L1.rms_ffn s0 | 0,007 | GF | 2 | 96
  m1727 Median L1.rms_ffn s0 | 0,003 | GF | 3 | 96
  m1728 Median L1.rms_ffn s0 | 0,002 | GMV | 1 | 96
  m1729 Median L1.rms_ffn s0 | 0,004 | GMV | 2 | 96
  m1730 Median L1.rms_ffn s0 | 0,003 | GMV | 3 | 96
  m1731 Held-out L s0 | 1,4251 - 1,4428 | GV, GM, GF Saaten 1-3 |  | 300
  m1732 F s0 | 4,4 - 7,2 % | GV, GM, GF Saaten 1-3 |  | 500
Ergebnis e149 [2026-10-21 19:23]: erfuellt
  Fazit: Kandidat 2 trifft zu: Die Gains kippen genau dann, wenn v richtig abklingen kann (GF, GV, GMV), und bleiben gesund, solange v an der Ratsche haengt (G0, GM), unabhaengig vom Rauschen in m. Die 'gesunden' Gains aller alten int8-Laeufe waren also eine Nebenwirkung des Fehlers. 'Nur v zufaellig runden' rettet sie nicht, 'nur m' rettet sie, verhindert aber den Kollaps nicht. Gesunde Gains und kein Kollaps zugleich gibt es mit diesem Rezept nicht; die naechste Frage war, ob das ueberhaupt stoert (snai/merkmal-gains-fest).
  Offen: Nur Segment s0; ob die Gains spaeter wiederkommen, zeigt nur der Langlauf MV (dort bleiben 73-96 von 96 Kanaelen unter 0,05).
  Datei: rechner-a:~/snai_pruef/merkmal/sr/kriterien_gains.txt
Chronik:
  2026-10-21 19:22 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/sr/kriterien_gains.txt, Kopf '2026-10-18, VOR dem Start', Ergebnis angefuegt)
  2026-10-21 19:22 Rezept r158
  2026-10-21 19:22 Status geplant -> laeuft (Rezept r158)
  2026-10-21 19:22 Messwerte m1716-m1732
  2026-10-21 19:23 Ergebnis e149: erfuellt
  2026-10-21 19:23 Status laeuft -> ausgewertet (Ergebnis e149)
```
