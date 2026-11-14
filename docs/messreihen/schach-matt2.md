# snai/schach-matt2

```text
snai/schach-matt2 - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 19:17
Frage: Schach-Materialversuch v2: Hilft eine drastisch verengte Verteilung (nur Matt in 2, <= 16 Figuren) dem Knirps d64, mehr echte Aufgaben zu erzeugen als die billige Stufe?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_schach_material.txt (V2 samt Nachtrag 2 nach dem Pruefer, laut Text vor den Laeufen, 2026-10-15).):
  Gemeinsam (alle drei Versuche): d64 fest, Token-Budget ~12,8 Mio. konstant, 3 Saaten, 1.000 Ziehungen je Saat T 1,0 Saat 4711, Urteilsgroesse Aufgaben je Ziehung (nicht woertlich im Training); je Zelle Positivkontrolle >= 90 %, Rot-Probe, 0 engine_fehler; Messlatte je Versuch neu = 1,1 x beste billige Stufe. V2: Pruefer (a) legal und erreichbar, (b) Matt in hoechstens 2 (Zugfolge mit python-chess nachgeprueft), (c) nicht Matt in 1. Positivkontrolle >= 90 %, Rot-Probe einen Halbzug frueher <= 25 %. Beide Lesarten (mit/ohne c) gemessen; das Urteil gilt in der Lesart, deren Positivkontrolle besteht, bei beiden die strengere; Messlatte in derselben Lesart. Messlatte = 1,1 x max(Z2, Z, N).
Baut auf: snai/schach-leiter
Rezepte:
  r126 [2026-10-21] bash lauf_material.sh <ARM> 0.001 <MAXSEG> <GEN> <DECAY> (PRE=<praefix> VOK=<vokabular>; darin je Segment in proj_ow: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=$DECAY nice -n 10 php train_cluster.php "$IN" "$O" 1 1 "$P" 3 $LR 0.0001 1 0.1); Korpus: .venv/bin/python bau_material.py v1|v2|v3; Auswertung nach_material.sh: material.py arme <v> und material.py ziehungen <v> <datei> --marke <m> --json material_erg.jsonl
      quelltext: proj_ow: cortex.nim 7b67236c, libcortex.so 563780e3 (gebaut 2026-10-13), train_worker.php af8e0a4f, train_cluster.php 2db1564a (md5 heute gelesen); lauf_material.sh db41d2a1, nach_material.sh 22f91a4d, material.py 3943c3e6, bau_material.py ece4e6ad (md5 heute; material.py mtime 2026-10-15 16:20, waehrend der Auswertung)
      parameter: Korpus v2: 8.262 mateIn2-Aufgaben mit <= 16 Figuren (895 Held-out), 54 Epochen = 54 Segmente, DECAY 198.666, Vokabular schach.json; Pruefer Stockfish 'go mate 2' mit Nachpruefung durch python-chess, Bedingung (c) 'go mate 1' findet nichts
      seed: Genesis 1, 2, 3; Ziehsaat 4711 (v1 Gegenprobe 20261016)
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/gebiete/v<N>_s<S>.log, v<N>_s<S>_s<I>.train.log, nach_material.out, material_erg.jsonl, arme_v2.json, arme_v3.json, gegen_erg.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/gebiete/arme_v2.json, material_erg.jsonl, nach_material.out (nachgelesen)
  m1367 Positivkontrolle mit c | 100,0 % | echt | 4711 | 895
  m1368 Rot einen Halbzug frueher mit c | 0,8 % | rot_vor | 4711 | 895
  m1369 Z2 mit c | 7,4 % | Z2 | 4711 | 1000
  m1370 Z mit c | 2,0 % | Z | 4711 | 1000
  m1371 N je Ausgabe mit c | 1,1 % | N | 4711 | 1000
  m1372 Messlatte mit c | 8,1 % | -
  m1373 Aufgaben je Ziehung mit c | 3,3 % | v2 | 1 | 1000
  m1374 Aufgaben je Ziehung mit c | 2,5 % | v2 | 2 | 1000
  m1375 Aufgaben je Ziehung mit c | 1,9 % | v2 | 3 | 1000
  m1376 Z2 ohne c | 15,4 % | Z2 | 4711 | 1000
  m1377 Messlatte ohne c | 16,9 % | -
  m1378 Aufgaben je Ziehung ohne c | 6,8 % | v2 | 1 | 1000
  m1379 Aufgaben je Ziehung ohne c | 5,9 % | v2 | 2 | 1000
  m1380 Aufgaben je Ziehung ohne c | 5,7 % | v2 | 3 | 1000
  m1381 legal je Ziehung | 66,2 % | v2 | 1 | 1000
  m1382 legal je Ziehung | 60,3 % | v2 | 2 | 1000
  m1383 legal je Ziehung | 58,1 % | v2 | 3 | 1000
  m1384 Kontext-Sonde alle vier | 73,6 % | v2 | 1 | 1000
  m1385 Kontext-Sonde alle vier | 72,4 % | v2 | 2 | 1000
  m1386 Kontext-Sonde alle vier | 66,2 % | v2 | 3 | 1000
  m1387 Rot-Probe Loss gemischt | 8,05 | v2 | 1 | 300
Ergebnis e121 [2026-10-21 19:17]: verfehlt
  Fazit: Verloren in beiden Lesarten, alle drei Saaten einig (2,6 % gegen Messlatte 8,1 %, ohne (c) 6,1 gegen 16,9 %). Der Pruefer war der schaerfste der Reihe (100 % gegen 0,8 %), und die vorab erwartete Schwaechung der Abwandlungsregel trat ein - trotzdem liegt das Modell darunter. Das enge Gebiet hilft der Form deutlich (bester Kontextwert aller Laeufe), der Loesbarkeit gar nicht. Gebietsverengung ist damit als Hebel fuer Schachaufgaben erledigt.
  Offen: Kombination enges Gebiet + Loesungszug nicht geprueft (jeder Versuch ein Stellrad).
  Datei: rechner-a:~/snai_pruef/knirps/gebiete/ERGEBNIS_sichtung.md (Abschnitt 'v2 Enges Gebiet')
Chronik:
  2026-10-21 19:16 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_schach_material.txt (V2 samt Nachtrag 2 nach dem Pruefer, laut Text vor den Laeufen, 2026-10-15).)
  2026-10-21 19:17 Rezept r126
  2026-10-21 19:17 Status geplant -> laeuft (Rezept r126)
  2026-10-21 19:17 Messwerte m1367-m1387
  2026-10-21 19:17 Ergebnis e121: verfehlt
  2026-10-21 19:17 Status laeuft -> ausgewertet (Ergebnis e121)
```
