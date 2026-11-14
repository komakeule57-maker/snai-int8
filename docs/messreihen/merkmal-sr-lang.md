# snai/merkmal-sr-lang

```text
snai/merkmal-sr-lang - ausgewertet, begonnen 2026-10-18, angelegt 2026-10-21, zuletzt 2026-10-21 19:22
Frage: Haelt zufaelliges Runden beider Adam-Momente (MV) den Embedding-Kollaps ueber einen ganzen Lauf ab Genesis fern (s0..s7, Saat 1-3), ohne der gesunden Saat 2 zu schaden?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/sr/kriterien_lang_sr.txt, Kopf '2026-10-18, VOR dem Start', Ergebnis angefuegt):
  Saat 1 und 3, Endsegmente s5-s7: HAELT = F < 5 % in allen drei, beide Saaten; HAELT NICHT = F >= 15 % in mindestens einem Endsegment in mindestens einer Saat; sonst kein Urteil. Saat 2: SCHADET NICHT = F < 5 % in s5-s7; SCHADET = F >= 15 % in einem davon. Pflichtkontrolle: L s7 mehr als 10 % ueber Original-s7 -> kein HAELT fuer die Saat. s0-s4 nur berichten.
Baut auf: snai/merkmal-sr
Darauf baut: snai/merkmal-gains, snai/merkmal-sr-lang-schach, snai/ratsche-k64-hybrid-lang
Rezepte:
  r151 [2026-10-21] bash ~/snai_pruef/knirps_sr/lauf_lang_sr.sh <Q0|MV> <saat> (je Segment php train_cluster.php factory/input/gross_c64_seg<I>.txt factory/checkpoints/gross_gross_s<S>_s<I>.snai 1 1 <vorher> 3 0.001 0.0001 1 0.1 mit SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=727208, MV mit SNAI_I8_MOM_SR=mv); Messung messe_lang.sh
      quelltext: proj_sr_basis, libcortex.so dfcc4711; lauf_lang_sr.sh e4582069, messe_lang.sh fc4fc2ae, gains_sr.php 06dea5e6, produkt_sr.php a0fe2883
      parameter: d96 Schach, Korpus gross, LR 0,001 Cosinus bis 727208, Untergrenze 1e-4, Warmup 500, WD 0,1 inkl. Embeddings, gebunden, int8 FULL, CPU, OMP 1, Revival und Lade-Waechter aus; ab Genesis gross_gen_s<S>, s0..s7 (746.352 Schritte); Q0 = Vorgabe als Kontrolle (s0 bytegleich zum Original)
      seed: Saat 1, 2, 3, Laufnamen gross_s1..s3 (gepaart mit den Originalen)
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/knirps_sr/log_lang/, lang_langMV_s<S>.jsonl, lang_langQ0_s<S>.jsonl, lang_orig_s<S>.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/knirps_sr/lang_langMV_s{1,2,3}.jsonl (am 2026-10-21 gelesen); Originale aus lang_orig_s*.jsonl bzw. der Datei; Gains aus kriterien_lang_sr.txt
  m1657 md5 Q0 s0 | 386687ac = Original | Q0 | 1 | 1
  m1658 md5 Q0 s0 | 66b7fa70 = Original | Q0 | 2 | 1
  m1659 md5 Q0 s0 | 63f33165 = Original | Q0 | 3 | 1
  m1660 F s5 / s6 / s7 | 0,4 / 1,0 / 0,6 % | MV | 1 | 500
  m1661 F s5 / s6 / s7 | 0,0 / 0,2 / 1,0 % | MV | 2 | 500
  m1662 F s5 / s6 / s7 | 0,8 / 0,8 / 0,0 % | MV | 3 | 500
  m1663 F s5 / s6 / s7 | 28,4 / 34,4 / 32,8 % | Original | 1 | 500
  m1664 F s5 / s6 / s7 | 0,6 / 1,4 / 0,2 % | Original | 2 | 500
  m1665 F s5 / s6 / s7 | 37,2 / 36,8 / 36,4 % | Original | 3 | 500
  m1666 Held-out L s7 | 1,3190 | MV | 1 | 300
  m1667 Held-out L s7 | 1,3177 | MV | 2 | 300
  m1668 Held-out L s7 | 1,3161 | MV | 3 | 300
  m1669 Held-out L s7 | 1,3701 | Original | 1 | 300
  m1670 Held-out L s7 | 1,3433 | Original | 2 | 300
  m1671 Held-out L s7 | 1,3805 | Original | 3 | 300
  m1672 tote Zeilen s5-s7 | 0 | MV Saaten 1, 2, 3
  m1673 Stufen-Median s7 | 33 | MV | 1
  m1674 Stufen-Median s7 | 35 | MV | 2
  m1675 Stufen-Median s7 | 33 | MV | 3
  m1676 Median L1.rms_ffn s0 | 0,002 (Original 1,233) | MV | 1 | 96
  m1677 Median L1.rms_ffn s0 | 0,004 (Original 0,913) | MV | 2 | 96
  m1678 Median L1.rms_ffn s0 | 0,003 (Original 0,531) | MV | 3 | 96
Ergebnis e145 [2026-10-21 19:22]: erfuellt
  Fazit: MV ist die Abhilfe fuer dieses Rezept: ueber den ganzen Lauf kein Kollaps (alle F <= 1 %), kein toter Zeilenrest, und der Loss am Ende ist in allen drei Saaten besser als im Original, auch in der gesunden Saat 2. Damit war die Bedingung fuer den Schach-Abschluss (snai/merkmal-sr-lang-schach) und fuer das Scharfschalten auf vserver erfuellt. Der Preis ist ein Nebenbefund: die RMS-Gains vor dem FFN der Schicht 1 fallen schon in s0 auf ~0; ob das schadet, klaeren snai/merkmal-gains, snai/merkmal-gains-fp32 und snai/merkmal-gains-fest.
  Offen: Nur d96 Schach, ein Rezept; andere Breiten (prod512b), GPU-Adam, laengere Laeufe nicht geprueft.
  Datei: rechner-a:~/snai_pruef/merkmal/sr/kriterien_lang_sr.txt
Chronik:
  2026-10-21 19:21 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/sr/kriterien_lang_sr.txt, Kopf '2026-10-18, VOR dem Start', Ergebnis angefuegt)
  2026-10-21 19:21 Rezept r151
  2026-10-21 19:21 Status geplant -> laeuft (Rezept r151)
  2026-10-21 19:21 Messwerte m1657-m1678
  2026-10-21 19:22 Ergebnis e145: erfuellt
  2026-10-21 19:22 Status laeuft -> ausgewertet (Ergebnis e145)
```
