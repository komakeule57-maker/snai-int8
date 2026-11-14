# snai/schach-loesungszug

```text
snai/schach-loesungszug - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:35
Frage: Schach-Materialversuch v3: Lernt der Knirps d64 Taktik, wenn der Loesungszug im Trainingssignal steht und er sich beim Ziehen auf einen Zug festlegen muss?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_schach_material.txt (V3, laut Text vor den Laeufen, 2026-10-15).):
  Gemeinsam (alle drei Versuche): d64 fest, Token-Budget ~12,8 Mio. konstant, 3 Saaten, 1.000 Ziehungen je Saat T 1,0 Saat 4711, Urteilsgroesse Aufgaben je Ziehung (nicht woertlich im Training); je Zelle Positivkontrolle >= 90 %, Rot-Probe, 0 engine_fehler; Messlatte je Versuch neu = 1,1 x beste billige Stufe. V3: Pruefer (a) legal und erreichbar, (b) genannter Zug legal, (c) genannter Zug ist der eindeutig beste (w >= 0,70, Abstand >= 0,15). Positivkontrolle echte Held-out-Stellungen mit echter Loesung >= 90 %; Rot-Probe zufaelliger legaler Zug statt Loesung <= 25 %. Messlatte 1,1 x max(Z2m, Zz, N). Zusatzkontrolle ohne Urteil: Modellstellungen mit zufaelligem legalem Zug.
Baut auf: snai/schach-leiter
Rezepte:
  r116 [2026-10-21] bash lauf_material.sh <ARM> 0.001 <MAXSEG> <GEN> <DECAY> (PRE=<praefix> VOK=<vokabular>; darin je Segment in proj_ow: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=$DECAY nice -n 10 php train_cluster.php "$IN" "$O" 1 1 "$P" 3 $LR 0.0001 1 0.1); Korpus: .venv/bin/python bau_material.py v1|v2|v3; Auswertung nach_material.sh: material.py arme <v> und material.py ziehungen <v> <datei> --marke <m> --json material_erg.jsonl
      quelltext: proj_ow: cortex.nim 7b67236c, libcortex.so 563780e3 (gebaut 2026-10-13), train_worker.php af8e0a4f, train_cluster.php 2db1564a (md5 heute gelesen); lauf_material.sh db41d2a1, nach_material.sh 22f91a4d, material.py 3943c3e6, bau_material.py ece4e6ad (md5 heute; material.py mtime 2026-10-15 16:20, waehrend der Auswertung)
      parameter: Korpus v3: 39.800 Zeilen (Stellung + erster Loeserzug als zwei Feldtoken), 8 Epochen, DECAY 198.656, 89 Umwandlungszuege und 199 zu lange fallen weg; Pruefer: Stellung legal, genannter Zug legal und eindeutig bester (w >= 0,70, Abstand >= 0,15)
      seed: Genesis 1, 2, 3; Ziehsaat 4711 (v1 Gegenprobe 20261016)
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/gebiete/v<N>_s<S>.log, v<N>_s<S>_s<I>.train.log, nach_material.out, material_erg.jsonl, arme_v2.json, arme_v3.json, gegen_erg.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/gebiete/arme_v3.json, material_erg.jsonl, nach_material.out (nachgelesen)
  m1238 Positivkontrolle | 95,1 % | echt | 4711 | 1000
  m1239 Rot Zufallszug | 4,6 % | rot | 4711 | 1000
  m1240 Z2m | 8,1 % | Z2m | 4711 | 1000
  m1241 Zz | 4,0 % | Zz | 4711 | 1000
  m1242 N | 0,0 % | N | 4711 | 1000
  m1243 Messlatte | 8,9 % | -
  m1244 Aufgaben je Ziehung | 0,1 % | v3 | 1 | 1000
  m1245 Aufgaben je Ziehung | 0,0 % | v3 | 2 | 1000
  m1246 Aufgaben je Ziehung | 0,1 % | v3 | 3 | 1000
  m1247 Stellung legal | 53,4 % | v3 | 1 | 1000
  m1248 Stellung legal | 52,1 % | v3 | 2 | 1000
  m1249 Stellung legal | 50,2 % | v3 | 3 | 1000
  m1250 legal, aber Zug fehlt oder nicht spielbar | 484 | v3 | 1 | 534
  m1251 legal, aber Zug fehlt oder nicht spielbar | 481 | v3 | 2 | 521
  m1252 legal, aber Zug fehlt oder nicht spielbar | 466 | v3 | 3 | 502
  m1253 genannter Zug ist der beste (wo spielbar) | 2,0 % | v3 | 1 | 50
  m1254 genannter Zug ist der beste (wo spielbar) | 5,0 % | v3 | 2 | 40
  m1255 genannter Zug ist der beste (wo spielbar) | 5,6 % | v3 | 3 | 36
  m1256 Zufallszug ist der beste | 9,2 % | v3 Zufallszug | 1 | 533
  m1257 Zufallszug ist der beste | 8,5 % | v3 Zufallszug | 2 | 516
  m1258 Zufallszug ist der beste | 10,8 % | v3 Zufallszug | 3 | 500
  m1259 Rot-Probe Loss gemischt | 8,17 | v3 | 1 | 300
Ergebnis e112 [2026-10-21 14:35]: verfehlt
  Fazit: Verloren um 99 % relativ (0,07 % gegen 8,9 %). Das Zugformat hat das Modell gelernt, die Sache nicht: in rund neun von zehn legalen Stellungen ist der genannte Zug gar nicht spielbar, und wo er spielbar ist, ist er nicht besser als ein Zufallszug. Form und Inhalt sind in dieser Groessenordnung entkoppelt; eine Sonde, die nur die Form prueft, misst das Falsche. Zusammen mit v1, v2, Leiter und gross: Schachaufgaben sind als Knirps-Gebiet erledigt.
  Offen: Der Vergleich 'genannter Zug gegen Zufallszug' ist ungepaart und keine Zufallsstichprobe (Beobachtung).
  Datei: rechner-a:~/snai_pruef/knirps/gebiete/ERGEBNIS_sichtung.md (Abschnitt 'v3 Loesungszug')
Chronik:
  2026-10-21 14:35 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_schach_material.txt (V3, laut Text vor den Laeufen, 2026-10-15).)
  2026-10-21 14:35 Rezept r116
  2026-10-21 14:35 Status geplant -> laeuft (Rezept r116)
  2026-10-21 14:35 Messwerte m1238-m1259
  2026-10-21 14:35 Ergebnis e112: verfehlt
  2026-10-21 14:35 Status laeuft -> ausgewertet (Ergebnis e112)
```
