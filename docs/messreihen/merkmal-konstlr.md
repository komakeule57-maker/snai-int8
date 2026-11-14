# snai/merkmal-konstlr

```text
snai/merkmal-konstlr - ausgewertet, begonnen 2026-10-18, angelegt 2026-10-21, zuletzt 2026-10-21 19:22
Frage: Verhindern float-Gradienten (KB Rueckwaerts float, KG Gradakk. float) und zufaellig gerundete Momente (KMV) den Embedding-Kollaps auch dann, wenn die Lernrate nicht abklingt (konstant 3,569e-4 ueber s5-s7)?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/sr/kriterien_konstlr.txt, Kopf '2026-10-18, VOR dem Start', Ergebnis angefuegt):
  Kontrolle K0: F >= 15 % in mindestens einem von s5-s7, in beiden Saaten; sonst kein Urteil fuer irgendeinen Arm. Je Arm KB, KG, KMV: KOLLABIERT = F >= 15 % in mindestens einem von s5-s7, in beiden Saaten; HAELT = F < 5 % in allen drei Segmenten, in beiden Saaten; sonst / Saaten uneinig: kein Urteil. Pflichtkontrolle: L s7 mehr als 10 % ueber K0 s7 derselben Saat -> Defekt, kein Urteil.
Baut auf: snai/merkmal-zerl-verl, snai/merkmal-sr
Rezepte:
  r155 [2026-10-21] bash ~/snai_pruef/knirps_sr/lauf_konst.sh <K0|KB|KG|KMV> <saat> (php train_cluster.php factory/input/gross_c64_seg<I>.txt factory/checkpoints/gross_gross_s<S>_s<I>.snai 1 1 <vorher> 3 0.0003569 0.0001 1 0.1, SNAI_LR_DECAY_STEPS ungesetzt, Schalter SNAI_I8_INT_BACKWARD=0 / SNAI_I8_INT_GRADACC=0 / SNAI_I8_MOM_SR=mv); Messung messe_lang.sh
      quelltext: proj_sr_basis (libcortex.so dfcc4711, ZERL- und SR-Schalter, Vorgabe bytegleich zum Original); lauf_konst.sh 32b7d5a7, messe_lang.sh fc4fc2ae
      parameter: Start Original gross_gross_s<S>_s4 (fbb4717f / 6849da72), Segmente s5-s7 (279.882 Schritte), LR konstant 3,569e-4 (Wert des Originals zu Beginn s5, im Log je Segment geprueft), sonst wie Original: int8 FULL, gebunden, WD 0,1, CPU, OMP 1, Revival und Lade-Waechter aus; 8 Laeufe parallel
      seed: Saat 1 und 3, Ausgabenamen wie Original
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/knirps_sr/log_konst/, lang_konst<Arm>_s<S>.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/knirps_sr/lang_konst{K0,KB,KG,KMV}_s{1,3}.jsonl (am 2026-10-21 gelesen)
  m1679 F s5 / s6 / s7 | 33,4 / 41,4 / 34,8 % | K0 | 1 | 500
  m1680 F s5 / s6 / s7 | 36,2 / 31,6 / 27,8 % | K0 | 3 | 500
  m1681 F s5 / s6 / s7 | 4,0 / 5,6 / 3,8 % | KB | 1 | 500
  m1682 F s5 / s6 / s7 | 3,0 / 3,8 / 4,2 % | KB | 3 | 500
  m1683 F s5 / s6 / s7 | 3,8 / 4,8 / 4,2 % | KG | 1 | 500
  m1684 F s5 / s6 / s7 | 3,2 / 3,8 / 4,0 % | KG | 3 | 500
  m1685 F s5 / s6 / s7 | 1,0 / 2,0 / 1,8 % | KMV | 1 | 500
  m1686 F s5 / s6 / s7 | 2,6 / 2,4 / 1,6 % | KMV | 3 | 500
  m1687 Held-out L s7 | 1,4655 | K0 | 1 | 300
  m1688 Held-out L s7 | 1,5118 | K0 | 3 | 300
  m1689 Held-out L s7 | 1,3539 | KB | 1 | 300
  m1690 Held-out L s7 | 1,3585 | KB | 3 | 300
  m1691 Held-out L s7 | 1,3583 | KG | 1 | 300
  m1692 Held-out L s7 | 1,3656 | KG | 3 | 300
  m1693 Held-out L s7 | 1,4971 | KMV | 1 | 300
  m1694 Held-out L s7 | 1,4474 | KMV | 3 | 300
  m1695 tote Zeilen s7 | 58 | K0 | 1
  m1696 tote Zeilen s7 | 51 | K0 | 3
  m1697 tote Zeilen s7 | 0 | KB, KG | 1
  m1698 tote Zeilen s7 | 0 | KB, KG | 3
  m1699 tote Zeilen s7 | 1 | KMV | 1
  m1700 tote Zeilen s7 | 0 | KMV | 3
Ergebnis e148 [2026-10-21 19:22]: teilweise
  Fazit: Auch ohne abklingende Lernrate kollabiert die Kontrolle sofort, die Eingriffe halten aber: KMV klar (hoechstens 2,6 %), KG knapp (hoechstens 4,8 %), KB verfehlt 'HAELT' nur wegen eines Punkts mit 5,6 % und liegt sonst unter 5 %, ohne tote Zeile. Die These 'float verhindert nicht, schiebt nur auf' ist damit fuer 280k Schritte bei LR 3,57e-4 nicht gestuetzt. 'Teilweise' heisst hier: zwei von drei Armen nach Wortlaut, nicht dass einer gekippt waere. Fuer die Praxis bleibt MV der Weg, weil er die 8-Bit-Momente behaelt; KB/KG sind Erklaerungshilfen.
  Offen: KG mit 4,8 % knapp - vor einem Zitat wiederholen. KMV hat in Saat 1 ein hoeheres L s7 (1,4971) als K0 (1,4655, +2,2 %), unter der 10-%-Schwelle, aber gegen KB/KG ~10 % schlechter; nicht untersucht. Zwei Saaten.
  Datei: rechner-a:~/snai_pruef/merkmal/sr/kriterien_konstlr.txt
Chronik:
  2026-10-21 19:22 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/sr/kriterien_konstlr.txt, Kopf '2026-10-18, VOR dem Start', Ergebnis angefuegt)
  2026-10-21 19:22 Rezept r155
  2026-10-21 19:22 Status geplant -> laeuft (Rezept r155)
  2026-10-21 19:22 Messwerte m1679-m1700
  2026-10-21 19:22 Ergebnis e148: teilweise
  2026-10-21 19:22 Status laeuft -> ausgewertet (Ergebnis e148)
```
