# snai/schach-d64-lauf

```text
snai/schach-d64-lauf - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:34
Frage: Schlaegt ein Knirps d64 (64/4/16, 2 Schichten, ctx 64, 109.760 Parameter), trainiert auf 40.000 Lichess-Aufgabenstellungen, die billige Stufe beim Erzeugen neuer Schachaufgaben?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_schach_lauf.txt Teil 1 und 2 (laut Text vor dem Lauf, 2026-10-15; Ergebnis Teil 1 und Fairness-Nachtrag vor dem Training eingetragen).):
  Teil 1: strenger Pruefer (eindeutige Gewinnfolge ueber zwei Loeserzuege) muss Positivkontrolle >= 90 % schaffen, sonst gilt er als untauglich und das Urteil bleibt beim einfachen Pruefer mit Messlatte 23,3 %; W/A nicht nachjustieren. Teil 2: Urteilsgroesse = Anteil Aufgaben je Ziehung (T 1,0, 1.000 je Saat, nicht woertlich im Training). Der Knirps schlaegt die billige Stufe, wenn JEDE der drei Saaten ueber M liegt; liegen alle drunter, hat er verloren; uneinig = saatabhaengig. Kontrollen: [LR-Decay], Ende-LR ~0,0001, 0 NET2NET-GUARD, rc=0, kein NaN, 0 engine_fehler.
Plan: rechner-a:~/snai_pruef/knirps/gebiete/kriterien_schach_lauf.txt
Baut auf: snai/gebiet-schach-sichtung
Darauf baut: snai/schach-leiter, snai/schach-kontextsonde
Rezepte:
  r106 [2026-10-21] bash lauf_schach.sh d64_s<S> 0.001 8 factory/checkpoints/schach_gen_d64h4_s<S>.snai 194800  (darin je Segment I: cd ~/snai_pruef/knirps/proj_ow && SNAI_VOCAB=~/snai_pruef/knirps/vokabular/schach.json SNAI_FORCE_CPU=1 OMP_NUM_THREADS=1 SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=$DECAY nice -n 10 php train_cluster.php "$IN" "$O" 1 1 "$P" 3 $LR 0.0001 1 0.1, IN=factory/input/schach_c64_seg<I>.txt); danach nach_lauf_schach.sh: php ziehe_schach.php <ckpt> 1000 1.0 4711 und .venv/bin/python schach.py --ziehungen <datei> --streng 0.70 0.15
      quelltext: proj_ow: cortex.nim 7b67236c, libcortex.so 563780e3 (gebaut 2026-10-13), train_worker.php af8e0a4f, train_cluster.php 2db1564a (md5 heute gelesen, Dateien seit dem Lauf unveraendert laut mtime); lauf_schach.sh 5316f02c, nach_lauf_schach.sh 0441a672, ziehe_schach.php cab17aeb, schach.py 9dd704c0, bau_schach.py 567aeddd
      parameter: 64/4/16, 2 Schichten, ffn 256, ctx 64, gebunden, INT8_FULL, Vokabular schach.json (87); 39.991 Stellungen, 8 Segmente = 8 Epochen (24.352 Schritte je Segment), LR 0,001 -> 0,0001 Cosinus ueber 194.800, Warmup 500, WD 0,1, 1 Arbeiter, Revival aus, START_OFFSET 0, proj_ow (Lade-Waechter aus); Ziehen T 1,0, 1.000 je Saat
      seed: Genesis 1, 2, 3; Ziehsaat 4711
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/gebiete/d64_s<S>.log, d64_s<S>.mess.jsonl, d64_s<S>_s<I>.train.log, nach_lauf.out, ziehungen.jsonl; Ziehungen rechner-a:~/snai_pruef/knirps/gebiete/ziehungen_d64_s<S>.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/gebiete/schach_streng.out und schach_beides.out
  m1036 strenger Pruefer Positivkontrolle | 84,3 % | echt Held-out | 4711 | 1000
  m1037 strenger Pruefer einen Halbzug frueher | 3,8 % | rot_vor | 4711 | 1000
  m1038 einfacher Pruefer Positivkontrolle (Korpus >= 2 Zuege) | 94,7 % | echt Held-out | 4711 | 1000
  m1039 einfacher Pruefer Z2 (Korpus >= 2 Zuege) | 18,3 % | Z2 | 4711 | 1000
  m1040 einfacher Pruefer Z (Korpus >= 2 Zuege) | 12,8 % | Z | 4711 | 1000
  m1041 einfacher Pruefer Trigramm je Ausgabe | 0,5 % | N | 4711 | 1000
  m1042 streng Z2 | 4,7 % | Z2 | 4711 | 1000
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/gebiete/ziehungen.jsonl (marke d64_s1..3), nach_lauf.out, d64_s<S>.mess.jsonl
  m1104 Aufgaben je Ziehung (Urteil) | 7,5 % | d64 | 1 | 1000
  m1105 Aufgaben je Ziehung (Urteil) | 6,1 % | d64 | 2 | 1000
  m1106 Aufgaben je Ziehung (Urteil) | 10,7 % | d64 | 3 | 1000
  m1107 legal je Ziehung | 56,3 % | d64 | 1 | 1000
  m1108 legal je Ziehung | 50,5 % | d64 | 2 | 1000
  m1109 legal je Ziehung | 60,4 % | d64 | 3 | 1000
  m1110 Aufgaben unter den legalen | 13,3 % | d64 | 1 | 563
  m1111 Aufgaben unter den legalen | 12,1 % | d64 | 2 | 505
  m1112 Aufgaben unter den legalen | 17,7 % | d64 | 3 | 604
  m1113 streng je Ziehung | 0,7 % | d64 | 1 | 1000
  m1114 streng je Ziehung | 1,2 % | d64 | 2 | 1000
  m1115 streng je Ziehung | 1,7 % | d64 | 3 | 1000
  m1116 woertlich im Training | 0,0 % | d64 | 1-3 | 3000
  m1117 Engine-Fehler | 0 | d64 | 1-3 | 3000
  m1118 Held-out-Loss Ende | 1,3392 | d64 | 1 | 300
  m1119 Held-out-Loss Ende | 1,3603 | d64 | 2 | 300
  m1120 Held-out-Loss Ende | 1,3540 | d64 | 3 | 300
  m1121 Trigramm-Loss | 1,5221 | Trigramm |  | 300
  m1122 Rot-Probe Loss gemischt | 8,24 | d64 | 1 | 300
  m1123 Rot-Probe Loss gemischt | 9,99 | d64 | 2 | 300
  m1124 Rot-Probe Loss gemischt | 8,67 | d64 | 3 | 300
Ergebnis e105 [2026-10-21 14:34]: verfehlt
  Fazit: Der Knirps hat verloren: alle drei Saaten (6,1 / 7,5 / 10,7 %) liegen deutlich unter der Messlatte 23,3 %, einig, nicht saatabhaengig; auch in der strengen Lesart (0,7-1,7 % gegen Z2 4,7 %). Unter seinen legalen Stellungen trifft er 12-18 % Aufgaben, etwa so viel wie echtes Material auf Zufallsfeldern (12,8 %): er hat die Form gelernt, nicht das, was eine Stellung zur Aufgabe macht. Das stiess die Folgeversuche an (Groesse, Material, Dauer). Die damalige Erklaerung 'Loesbarkeit steht nicht in den Daten' wurde von der Leiter (snai/schach-leiter) widerlegt.
  Offen: Der strenge Pruefer riss seine Positivkontrolle (84,3 %) und gilt nach Vorab-Regel als untauglich. Der Vergleich ist unsymmetrisch (Z2 bekommt eine echte Aufgabe geschenkt). Fairness-Nachtrag: auf dem Lernkorpus (>= 2 Zuege) liegt Z2 bei 18,3 % statt 21,2 %; die Messlatte blieb vorab bei 23,3 %.
  Datei: rechner-a:~/snai_pruef/knirps/gebiete/ERGEBNIS_sichtung.md (Abschnitt 'Der Lauf: Knirps auf Schachaufgaben')
Chronik:
  2026-10-21 14:33 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_schach_lauf.txt Teil 1 und 2 (laut Text vor dem Lauf, 2026-10-15; Ergebnis Teil 1 und Fairness-Nachtrag vor dem Training eingetragen).)
  2026-10-21 14:34 Rezept r106
  2026-10-21 14:34 Status geplant -> laeuft (Rezept r106)
  2026-10-21 14:34 Messwerte m1036-m1042
  2026-10-21 14:34 Messwerte m1104-m1124
  2026-10-21 14:34 Ergebnis e105: verfehlt
  2026-10-21 14:34 Status laeuft -> ausgewertet (Ergebnis e105)
```
