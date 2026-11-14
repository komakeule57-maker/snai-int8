# snai/adam-schatten

```text
snai/adam-schatten - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 18:26
Frage: Macht der echte Schritt nach dem Gradienten (Clip, Adam, Decay, 8-Bit-Momente, Requantisierung, Fehlerrueckfuehrung) dasselbe wie korrektes Adam, je Tensor und Schicht, und wo weicht er ab?
Kriterium (festgelegt 2026-11-02 16:52, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/ad/kriterien.txt, vor dem ersten Lauf, mit Pruefer. Schatten-Adam auf demselben geclippten Gradienten. Arme f (Momente float, Kontrolle), neu, alt (Rot fuer v). 64x4, LR 0,003, 9.002 Schritte, Saaten 4-6. Je Tensor und 500 Schritte: cos und Laenge der Fenstersumme ist gegen soll, Median log(v_ist/v_soll), Anteil v_ist=0, cos m. Geraet: Schatten aendert md5 nicht; f cos>=0,99, Laenge 0,99-1,01, |log v|<=0,01, Gains 1 auf 1e-4; alt |log v|>ln 1,1 an mindestens einem 8-Bit-Tensor. ADAM KORREKT in neu ab Schritt 1000, alle Fenster, 3 Saaten: cos>=0,9, Laenge 0,9-1,1, |Median log v|<=ln 1,1, v_ist=0 <1 %, bei Tensoren >=1e-3 der groessten Soll-Aenderung; sonst ABWEICHUNG mit Tensor und Zeitpunkt. CLIP korrekt: Abweichung <=1e-3.
Plan: rechner-b:~/snai_pruef/ad/kriterien.txt
Baut auf: snai/gradient-tiefe, snai/ratsche-k64, snai/merkmal-sr
Darauf baut: snai/genesis-ffn, snai/v-ueberhang
Rezepte:
  r522 [2026-11-02] cd ~/snai_pruef/ad; ./lauf.sh <arm> <saat>, Arme neu, alt, f, Saaten 4-6, zwei zugleich
      quelltext: ms_tiefe/proj_L2 cortex cae946bf + patch_sch.py = e1a18ec9, libcortex b7d78cd4; train_worker.php mit Schalter fuer Arm f; k4.py
      parameter: 64x4, LR 0,003, Warmup 500, WD 0,1, gebunden, kurz9000, CPU, 1 Thread, nice 10; SNAI_ADAM_SCHATTEN
      seed: Saaten 4, 5, 6, Genesis wie snai/ratsche-k64
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/ad/l/<arm>_s<saat>/sch.jsonl, log.txt
      notiz: K4 Formel gegen torch.optim.Adam groesste Abweichung 1,1e-15.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/ad/aus.py, zeit.py, gains_leb.php auf Endstaenden
  m7665 Abweichungen Zellen ab t1000 | 0/1734 | neu
  m7666 Abweichungen Zellen ab t1000 | 0/1734 | f
  m7667 Abweichungen Zellen ab t1000 | 927/1734 | alt
  m7668 cos min | 0,9296 | neu
  m7669 Laenge min-max | 1,003-1,061 | neu
  m7670 Median log v Betrag max | 0,032 | neu
  m7671 cos min | 0,9987 | f
  m7672 Laenge min-max | 0,999-1,003 | f
  m7673 Median log v Betrag max | 5,9e-5 | f
  m7674 Median log v min-max | -1,49 bis +4,00 | alt
  m7675 Clip Abweichung max | 1,32e-4 | alle Arme
  m7676 FFN L2 tot % Ende | 35,9 | neu | 4
  m7677 FFN L2 tot % Ende | 68,8 | neu | 5
  m7678 FFN L2 tot % Ende | 53,1 | neu | 6
  m7679 FFN L2 tot % Ende | 20,3 | f | 4
  m7680 FFN L2 tot % Ende | 76,6 | f | 5
  m7681 FFN L2 tot % Ende | 50 | f | 6
  m7682 FFN L2 tot % Ende | 0 | alt | 4
  m7683 FFN L2 tot % Ende | 4,7 | alt | 5
  m7684 FFN L2 tot % Ende | 0 | alt | 6
  m7685 Laenge wdown2 t1000/3000/9000 Median | 0,72/0,44/0,59 | alt
  m7686 Laenge wdown3 t1000/3000/9000 Median | 0,94/0,54/0,42 | alt
  m7687 Laenge wo3 t1000/3000/9000 Median | 1,21/1,73/1,18 | alt
  m7688 Laenge wdown2 t1000/3000/9000 Median | 1,03/1,02/1,01 | neu
  Quelle: rechner-b:~/snai_pruef/ad/aus2.py, l2/*/sch.jsonl, gains_leb.php
  m7733 cos m min ab t1000 | 0,9835 | neu
  m7734 cos m unter 0,9 | 0/1734 | neu
  m7735 cos m min ab t1000 | 1,0000 | f
  m7736 cos m Rotprobe | -0,998 bis -0,985 | rot | 4
  m7737 v0 Rotprobe | 0,100 | rot | 4
  m7738 Abweichungen Zellen ab t1000 | 366/1734, nur wup und wdown | hyb
  m7739 FFN L2 tot % Ende | 0 | hyb | 4
  m7740 FFN L2 tot % Ende | 7,8 | hyb | 5
  m7741 FFN L2 tot % Ende | 3,1 | hyb | 6
  m7742 Attention L0 tot % Ende | 53,1 | hyb | 4
  m7743 Attention L0 tot % Ende | 6,3 | hyb | 5
  m7744 Attention L0 tot % Ende | 17,2 | hyb | 6
  m7745 Attention L0 tot % Ende | 56,3 | neu | 4
  m7746 Attention L0 tot % Ende | 3,1 | neu | 5
  m7747 Attention L0 tot % Ende | 35,9 | neu | 6
  m7748 Attention L0 tot % Ende | 7,8 | alt | 4
  m7749 Attention L0 tot % Ende | 6,3 | alt | 5
  m7750 Attention L0 tot % Ende | 1,6 | alt | 6
  m7751 Laenge wo2 t1000/3000/9000 Median | 1,03/1,04/1,02 | hyb
  m7752 Laenge wdown2 t1000/3000/9000 Median | 0,75/0,52/0,73 | hyb
Ergebnis e467 [2026-11-02 18:26]: erfuellt
  Fazit: ADAM KORREKT und M KORREKT nach Reparatur der Sonde; Rotproben fuer cos m und v=0 gesehen. Der Schritt nach dem Gradienten ist auf diesem Knirps nicht die Fehlerquelle: Gains sterben bei korrektem Adam (neu, f) und bleiben dort heil, wo die Ratsche gezielt falsch rechnet (alt, hyb). Hyb weicht nur an w_up und w_down ab, die Beschleunigung von w_o aus alt ist also fuer den Schutz der FFN-Gains nicht noetig. Hyb schuetzt die Attention-Gains in L0 nicht wie alt, das gehoert zum Vermerk des Workarounds. Deutung, nicht gemessen: Das Sterben gehoert zum Rezept unter korrektem Adam, die Ratsche schuetzt als Stoerung. Naechster klaerender Lauf: gebunden in PyTorch mit diesem Rezept.
  Offen: Gebundener Lauf ohne 8-Bit-Gewichte (PyTorch). Abweichungen unter 10 % nicht beurteilt. Breite und Spaetphase nicht geprueft. Fehlerkanal neu s4 im ersten Durchgang verloren, im Nachlauf sauber. Warum gerade L2 stirbt, offen.
  Datei: rechner-b:~/snai_pruef/ad/ERGEBNIS_adam_schatten.md
Abgeloest und ausgeblendet: 1 ergebnis - voll=True zeigt sie.
Chronik:
  2026-11-02 16:52 angelegt
  2026-11-02 16:54 Rezept r522
  2026-11-02 16:54 Status geplant -> laeuft (Rezept r522)
  2026-11-02 17:42 Messwerte m7665-m7688
  2026-11-02 17:42 Ergebnis e463: erfuellt
  2026-11-02 17:42 Status laeuft -> ausgewertet (Ergebnis e463)
  2026-11-02 18:26 Messwerte m7733-m7752
  2026-11-02 18:26 Ergebnis e467: erfuellt, loest e463 ab
```
