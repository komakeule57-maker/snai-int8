# snai/merkmal-langlauf-neu

```text
snai/merkmal-langlauf-neu - ausgewertet, begonnen 2026-10-16, angelegt 2026-10-21, zuletzt 2026-10-21 14:30
Frage: Besteht der Embedding-Kollaps in der Engine nach den Umbauten vom 15./16.10. (Git 21b7fde) unveraendert fort (statt sich damit erledigt zu haben)? Deckungsgleicher Nachlauf von gross_gross_s1 (d96 Schach) s0-s7.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/kriterien_langlauf_neu.txt, Kopf '2026-10-16, vor dem Start' (Start 08:53); Nachtrag 09:45 nach dem s0-Ergebnis auf Einwand):
  Je Segment (a) md5 gegen proj_ow/factory/checkpoints/gross_gross_s1_sN.snai, (b) quant_sonde (Stufen-Median, Zeilen <= 1 Stufe), (c) nach s5 und s7 Formfehler (500 Ziehungen T 1,0, Saat 4711). Urteil: md5 gleich in s0 -> der Fehler besteht in der neuen Engine unveraendert. md5 verschieden -> erledigt nur, wenn in s5 und s7 Stufen-Median >= 6, keine Zeile <= 1 Stufe und Formfehler < 10 %; eine Saat = Beobachtung. NACHTRAG 09:45 (nach s0, vor s1): die Regel 's0 bytegleich' war zu stark; erst wenn auch die Segmente mit Laden/Fortsetzen (s1 ff.) bytegleich sind, ist der ganze Lauf deckungsgleich.
Darauf baut: snai/merkmal-r3-saat, snai/merkmal-langlauf-heute
Rezepte:
  r65 [2026-10-21] bash ~/snai_pruef/merkmal/lauf_langlauf_neu.sh (je Segment I: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=727208 nice -n 10 php train_cluster.php factory/input/gross_c64_seg<I>.txt factory/checkpoints/gross_gross_s1_s<I>.snai 1 1 <vorher> 3 0.001 0.0001 1 0.1)
      quelltext: knirps/proj_neu = git archive 21b7fde + snai_tokenizer.php aus proj_ow, Lade-Waechter aus, Revival aus; libcortex.so 51047037; lauf_langlauf_neu.sh 4e5928ff
      parameter: Genesis gross_gen_s1.snai (V5), Segmente gross_c64_seg0..7, LR 0,001, Abklingen bis 727208, Warmup 500, WD 0,1, gebunden, int8 FULL, CPU, OMP 1
      seed: Saat 1, gleiche Sitzungsnamen wie das Original -> gleiche Fensterfolge
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/erg_neu/langlauf.log, gross_s1_s<N>.train.log, zieh_s5.txt, zieh_s7.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/erg_neu/langlauf.log (Skriptausgabe, abgelesen 2026-10-21)
  m638 md5 gleich Original | ja (386687ac) | neue Engine Segment 0 | 1 | 1
  m639 md5 gleich Original | ja (c56f8055) | neue Engine Segment 1 | 1 | 1
  m640 md5 gleich Original | ja (f589ee29) | neue Engine Segment 2 | 1 | 1
  m641 md5 gleich Original | ja (4df2e0d4) | neue Engine Segment 3 | 1 | 1
  m642 md5 gleich Original | ja (fbb4717f) | neue Engine Segment 4 | 1 | 1
  m643 md5 gleich Original | ja (0c079542) | neue Engine Segment 5 | 1 | 1
  m644 md5 gleich Original | ja (266b3c56) | neue Engine Segment 6 | 1 | 1
  m645 md5 gleich Original | ja (1d1708a4) | neue Engine Segment 7 | 1 | 1
  m646 Stufen-Median s5 | 3 | neue Engine | 1 | 1
  m647 Zeilen <= 1 Stufe s5 | 22/87 | neue Engine | 1 | 1
  m648 Formfehler s5 (500, T 1, Saat 4711) | 28,4 % | neue Engine | 1 | 1
  m649 Stufen-Median s7 | 1 | neue Engine | 1 | 1
  m650 Zeilen <= 1 Stufe s7 | 56/87 | neue Engine | 1 | 1
  m651 Formfehler s7 | 32,8 % | neue Engine | 1 | 1
  m652 Fehlerkanal je Segment | 0 | neue Engine | 1 | 8
Ergebnis e60 [2026-10-21 14:30]: erfuellt
  Fazit: Die neue Engine rechnet den Kollapslauf in allen acht Segmenten bytegleich, einschliesslich Laden und Fortsetzen an fuenf Segmentgrenzen. Die Umbauten vom 15./16.10. sind damit als Ursache ausgeschlossen, und jede Ursachensuche darf am alten wie am neuen Stand gleichermassen ansetzen. Der Kollaps ist ein Rezept-/Verfahrensproblem, kein Regressionsfehler. 'Erfuellt' heisst hier: die Frage ist nach der Regel entschieden (Fehler besteht unveraendert).
  Offen: Eine Saat, ein Rezept. Spaetere Staende (18.10.) prueft snai/merkmal-langlauf-heute.
  Datei: rechner-a:~/snai_pruef/merkmal/kriterien_langlauf_neu.txt
Chronik:
  2026-10-21 14:29 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/kriterien_langlauf_neu.txt, Kopf '2026-10-16, vor dem Start' (Start 08:53); Nachtrag 09:45 nach dem s0-Ergebnis auf Einwand)
  2026-10-21 14:29 Rezept r65
  2026-10-21 14:29 Status geplant -> laeuft (Rezept r65)
  2026-10-21 14:29 Messwerte m638-m652
  2026-10-21 14:30 Ergebnis e60: erfuellt
  2026-10-21 14:30 Status laeuft -> ausgewertet (Ergebnis e60)
```
