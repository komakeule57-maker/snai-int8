# snai/kopfablation-prod512b

```text
snai/kopfablation-prod512b - ausgewertet, angelegt 2026-10-26, zuletzt 2026-10-26 15:13
Frage: Welche Attention-Köpfe tragen in prod512b das Kopieren aus dem Kontext? Liegen sie in Schicht 3, wo in Segment 1 der Q/K-Gradient zugleich mit der Kopierrate sprang? Bleiben es von s1 bis s5 dieselben Köpfe?
Kriterium (festgelegt 2026-10-26 10:18, vor dem ersten Messwert):
  Eingriff: Modus 5 der Q/K-Sonde, ein Kopf gleichverteilt, je Stand 48 Köpfe und 6 Schichten. Daten: 50 feste Fenster zu 1024 Token. Für jeden Kopf gilt: Delta = Eingriff minus kein Eingriff in den Klassen "Folge & selten" (FS) und "neu" (N), gepaart je Fenster. Rangmaß ist der spezifische Schaden S = Delta_FS - Delta_N.

- H1 "Schicht 3 trägt": In mindestens 4 von 5 Ständen liegt der Kopf mit dem größten S in Schicht 3, und Schicht 3 hat auch das größte S der Schichtablation. Höchstens 1 Stand: verfehlt.
- H2 "stabil": Derselbe Kopf hat in mindestens 4 von 5 Ständen das größte S. Höchstens 2 Stände: wandert.

Gesamt:
- erfüllt = H1 und H2
- teilweise = genau eines von beiden
- verfehlt = H1 verfehlt und H2 wandert
- keine_aussage = Rot-Probe (kein Eingriff bytegleich zum Original, Token-Dateien gleich) in mehr als einem Stand verletzt

Träger (Delta_FS >= 0,25 x (FS(s0) - FS(x)) und spezifisch) und die Kontrolle s0 werden nur berichtet. Volltext: rechner-a:~/snai_pruef/kopfabl/kriterien.txt e96e8463.
Plan: rechner-a:~/snai_pruef/kopfabl/kriterien.txt
Baut auf: snai/kopiersperre-gross
Darauf baut: snai/prod512b-kopierkoepfe-blick
Rezepte:
  r428 [2026-10-26] rechner-b: cd ~/snai_pruef/kopfabl && KA_PAR=4 setsid nohup bash lauf.sh > lauf.out 2>&1 &  ; je Lauf: cd mess && env ICL_OUT=… SNAI_EVAL_VERTEILT=1 SNAI_FORCE_CPU=1 OMP_NUM_THREADS=1 SNAI_CORTEX_LIB=bau/libcortex_qk.so SNAI_QK_MODUS=5 SNAI_QK_SCHICHT=l SNAI_QK_KOPF=h php diagnose/icl_score.php modell/prod512b_sX.snai factory/holdout_prod/ auto 50 ; Auswertung rechner-a: python3 kopfabl/auswert_kopf.py (nach rsync von aus/)
      quelltext: lauf.sh af186725, auswert_kopf.py (vor Lauf), cortex_qk.nim = patch_qk.py auf snai_edge_int8_lora/cortex.nim 18d6a7df, Referenz cortex.nim ungepatcht gleiche Bauoptionen; Messbaum = Kopie ~/snai_pruef/drohne/E ohne Checkpoints (Vokabular f020d0ca); Modelle s0-s5 md5 de325fec a89f25cf ec8406b8 deee2ea3 751d92d9 10ab21ad; kriterien.txt e96e8463
      parameter: 50 Fenster x 1024 Token (SNAI_EVAL_VERTEILT), Modus 5 (Gleichverteilung) je Kopf / je Schicht, s1-s5 je orig+kein+48 Koepfe+6 Schichten, s0 orig+kein+6 Schichten = 288 Laeufe, xargs -P 4 (nach VG bis 6), OMP 1, nice 12
      seed: deterministisch (keine Saat; Fensterauswahl fest verteilt)
      rechner: rechner-b (daneben TDC-AI VG bis ~11:30, abgesprochen)
      logs: rechner-b:~/snai_pruef/kopfabl/aus/<stand>/, fortschritt.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b ~/snai_pruef/kopfabl/fortschritt.log; rechner-a auswert_kopf.py 1a5823b6, wiederholung_loss.py (Kopie nur mit 4-stelliger Ausgabe), Generator scratchpad rot_gen.py
  m5789 Rot-Probe a kein==orig bytegleich | 6/6 | kein | s0-s5 | 50
  m5790 Rot-Probe b Token aller Staende bytegleich | 6/6 | orig | s0-s5 | 50
  m5791 Abnahme d gepooltes FS/N = wiederholung_loss.py auf 4 Stellen | 6/6 | kein | s0-s5 | 50
  m5792 FS_kein gepoolt (Folge & selten) | 5.4709 / 1.5080 / 1.2171 / 1.1231 / 1.0286 / 1.0702 | kein | s0-s5 | 1931
  m5793 N_kein gepoolt (neu) | 5.6058 / 5.1624 / 4.9562 / 4.8089 / 4.6922 / 4.6015 | kein | s0-s5 | 27180
  m5794 Rot-Probe auswert_kopf.py (gepflanzte Koepfe) | a erfuellt / b verfehlt / c keine_aussage wie vorhergesagt | synthetisch | s1-s5 | 3
  Quelle: rechner-a:~/snai_pruef/kopfabl/auswert_kopf.txt (auswert_kopf.py 1a5823b6) und zusatz_kopf.txt; 288/288 Laeufe ok, Logs ohne Fehlermeldung, kein OOM
  m5881 Laeufe ok | 288/288 | alle |  | 288
  m5882 Rot-Probe c (Schicht >= bester Kopf - 2SE) | verletzt s1 L4+L5, s2 L4, s3 L4 (Groesse 0,01-0,02 nats); L2/L3 bestanden | alle |  | 5
  m5883 dFS L2K4 | +3,498 ±0,138 | s1 |  | 50
  m5884 dFS L2K4 | +3,512 ±0,141 | s2 |  | 50
  m5885 dFS L2K4 | +3,344 ±0,140 | s3 |  | 50
  m5886 dFS L2K4 | +3,298 ±0,152 | s4 |  | 50
  m5887 dFS L2K4 | +3,137 ±0,159 | s5 |  | 50
  m5888 dFS L3K6 | +3,228 ±0,132 | s1 |  | 50
  m5889 dFS L3K6 | +3,116 ±0,131 | s2 |  | 50
  m5890 dFS L3K6 | +2,912 ±0,130 | s3 |  | 50
  m5891 dFS L3K6 | +2,797 ±0,137 | s4 |  | 50
  m5892 dFS L3K6 | +2,559 ±0,141 | s5 |  | 50
  m5893 dFS/G L2K4 | 0,90 / 0,85 / 0,79 / 0,76 / 0,73 | s1-s5 |  | 50
  m5894 dFS/G L3K6 | 0,83 / 0,75 / 0,68 / 0,65 / 0,60 | s1-s5 |  | 50
  m5895 dN L2K4 | +0,030 / +0,045 / +0,054 / +0,068 / +0,083 | s1-s5 |  | 50
  m5896 dN L3K6 | -0,031 / -0,018 / -0,013 / -0,007 / +0,005 | s1-s5 |  | 50
  m5897 dFS dritter Kopf L3K0 | +0,099 / +0,142 / +0,170 / +0,174 / +0,200 | s1-s5 |  | 50
  m5898 dFS L2alle | +3,634 / +3,711 / +3,576 / +3,514 / +3,390 | s1-s5 |  | 50
  m5899 dFS L3alle | +3,653 / +3,661 / +3,576 / +3,501 / +3,331 | s1-s5 |  | 50
  m5900 S(L3alle)-S(L2alle) gepaart | +3,5 % / +1,9 % / +3,5 % / +3,2 % / +1,9 % (Gleichstand <10 %) | s1-s5 |  | 50
  m5901 Abstand S L2K4 vor L3K6 | 6 % / 11 % / 12 % / 15 % / 20 % | s1-s5 |  | 50
  m5902 Traeger je Stand | 2 / 2 / 2 / 2 / 2 | s1-s5 |  | 50
  m5903 Kontrolle s0 dFS L2alle / L3alle | +0,394 / +0,393 (s1: 3,634 / 3,653) | s0 |  | 50
  m5904 Teuerster Kopf (S) | L2K4 in 5/5 | s1-s5 |  | 5
  m5905 Teuerste Schicht (S) | L3alle in 5/5 (gegen L2alle Gleichstand) | s1-s5 |  | 5
  m5906 H1 Schicht 3 traegt | 0/5 verfehlt | s1-s5 |  | 5
  m5907 H2 stabil | L2K4 5/5 stabil | s1-s5 |  | 5
Ergebnis e379 [2026-10-26 15:13]: teilweise
  Fazit: Das Kopieren in prod512b haengt von s1 bis s5 an DENSELBEN zwei Koepfen: L2K4 und L3K6. Jeder kostet allein 60-90 % des FS-Gewinns, fast ohne Wirkung auf "neu" (H2 stabil 5/5). Die Vorab-These "Schaltkreis sitzt in Schicht 3" ist widerlegt (H1 0/5): Er braucht Schicht 2 und 3 gemeinsam, wie das Kopfpaar an den Drohnen, und entsteht in Segment 1 (s0 L2/L3alle 0,39 gegen 3,6). Der Q/K-Gradientensprung ist damit praezisiert, nicht bestaetigt: Er betrifft nur die obere Haelfte des Paars, ein Zusammenfallen ohne Eingriff. Mit dem Training sinkt der Anteil beider Koepfe (0,90->0,73 bzw. 0,83->0,60 von G), das Kopieren wird etwas weniger exklusiv. Folge fuer die Absatzschleifen: Der Mechanismus ist auf zwei benannte Koepfe eingegrenzt. Ein Kopfeingriff im Beam (Daempfen von L3K6 oder L2K4) ist als Alternative zur Kopiersperre testbar, mit der Gegenhypothese, dass er die Namensbindung mehr kostet als die prompt-freie Sperre.
  Offen: Welcher Kopf welche Stufe ist (vorige-Token-Kopf / Induktionskopf), Attention-Muster nicht gemessen. Ob das Paar allein genuegt (Paar-Gegenversuch wie an den Drohnen, nicht Teil dieser Reihe). Ob der sinkende Anteil ein Ersatzweg ist oder nur ein besseres Restmodell. Rot-Probe c in Schicht 4/5 (s1-s3) verletzt, Groesse 0,01-0,02 nats, ungeklaert (nicht-additive Wechselwirkung vermutet). Schicht 2 gegen 3 als Ganzes Gleichstand (<10 %). Ein Lauf, ein Fensterschnitt.
  Datei: rechner-a:~/snai_pruef/kopfabl/ERGEBNIS_kopfablation.md
Chronik:
  2026-10-26 10:18 angelegt
  2026-10-26 10:30 Rezept r428
  2026-10-26 10:30 Status geplant -> laeuft (Rezept r428)
  2026-10-26 10:53 Messwerte m5789-m5794
  2026-10-26 15:12 Messwerte m5881-m5907
  2026-10-26 15:13 Ergebnis e379: teilweise
  2026-10-26 15:13 Status laeuft -> ausgewertet (Ergebnis e379)
```
