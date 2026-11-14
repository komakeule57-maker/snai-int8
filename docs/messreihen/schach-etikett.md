# snai/schach-etikett

```text
snai/schach-etikett - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:34
Frage: Schach-Materialversuch v1: Lernt der Knirps d64 mehr ueber 'ist eine Aufgabe', wenn Aufgaben ('Ja') und dieselben Stellungen einen Halbzug frueher ('Nein') etikettiert im Korpus stehen? Wirkt das Etikett beim Ziehen?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_schach_material.txt (V1 samt Nachtrag nach dem Pruefer, laut Text vor den Laeufen, 2026-10-15). Die Wiederholung auf frischen Ziehungen folgte der Projektregel 'knapp erfuellt ist nicht erfuellt', nicht der Kriteriendatei.):
  Gemeinsam (alle drei Versuche): d64 fest, Token-Budget ~12,8 Mio. konstant, 3 Saaten, 1.000 Ziehungen je Saat T 1,0 Saat 4711, Urteilsgroesse Aufgaben je Ziehung (nicht woertlich im Training); je Zelle Positivkontrolle >= 90 %, Rot-Probe, 0 engine_fehler; Messlatte je Versuch neu = 1,1 x beste billige Stufe. V1: Messlatte 23,3 % (einfacher Pruefer unveraendert). Eigene Urteilsgroesse Kontrast Ja gegen Nein (Aufgaben je Ziehung): das Etikett wirkt nur, wenn Ja die Nein-Quote um mindestens 10 % relativ uebertrifft UND das geschachtelte Bootstrap-KI der Differenz die Null nicht enthaelt UND alle drei Saaten in dieselbe Richtung zeigen (Nachtrag nach dem Pruefer). Rot-Probe des Aufbaus: mit Nein gezogene Stellungen muessen die Kontext-Sonde aehnlich gut bestehen.
Baut auf: snai/schach-leiter
Rezepte:
  r108 [2026-10-21] bash lauf_material.sh <ARM> 0.001 <MAXSEG> <GEN> <DECAY> (PRE=<praefix> VOK=<vokabular>; darin je Segment in proj_ow: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=$DECAY nice -n 10 php train_cluster.php "$IN" "$O" 1 1 "$P" 3 $LR 0.0001 1 0.1); Korpus: .venv/bin/python bau_material.py v1|v2|v3; Auswertung nach_material.sh: material.py arme <v> und material.py ziehungen <v> <datei> --marke <m> --json material_erg.jsonl
      quelltext: proj_ow: cortex.nim 7b67236c, libcortex.so 563780e3 (gebaut 2026-10-13), train_worker.php af8e0a4f, train_cluster.php 2db1564a (md5 heute gelesen); lauf_material.sh db41d2a1, nach_material.sh 22f91a4d, material.py 3943c3e6, bau_material.py ece4e6ad (md5 heute; material.py mtime 2026-10-15 16:20, waehrend der Auswertung)
      parameter: Korpus v1: 79.673 Zeilen (je Aufgabe 'Ja' + dieselbe Stellung einen Halbzug frueher mit 'Nein'), 4 Epochen, DECAY 195.228, Vokabular schach_etikett.json (89); Ziehen mit Praefix Ja bzw. Nein; Gegenprobe gegenprobe_v1.sh mit Ziehsaat 20261016
      seed: Genesis 1, 2, 3; Ziehsaat 4711 (v1 Gegenprobe 20261016)
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/gebiete/v<N>_s<S>.log, v<N>_s<S>_s<I>.train.log, nach_material.out, material_erg.jsonl, arme_v2.json, arme_v3.json, gegen_erg.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/gebiete/material_erg.jsonl (Ziehsaat 4711) und gegen_erg.jsonl (20261016) nachgelesen; KI und Kontext-Sonde aus ERGEBNIS_sichtung.md, nicht nachgerechnet
  m1074 Aufgaben je Ziehung Ja | 7,5 % | v1 Ja | 1 | 1000
  m1075 Aufgaben je Ziehung Ja | 7,5 % | v1 Ja | 2 | 1000
  m1076 Aufgaben je Ziehung Ja | 7,1 % | v1 Ja | 3 | 1000
  m1077 Aufgaben je Ziehung Nein | 6,1 % | v1 Nein | 1 | 1000
  m1078 Aufgaben je Ziehung Nein | 6,3 % | v1 Nein | 2 | 1000
  m1079 Aufgaben je Ziehung Nein | 5,5 % | v1 Nein | 3 | 1000
  m1080 Ja Mittel (Ziehsaat 4711) | 7,37 % | v1 Ja | 1-3 | 3000
  m1081 Nein Mittel (Ziehsaat 4711) | 5,97 % | v1 Nein | 1-3 | 3000
  m1082 Differenz KI95 (4711) | +0,03 bis +2,73 Punkte | Ja-Nein | 1-3 | 3000
  m1083 Aufgaben je Ziehung Ja frisch | 6,9 % | v1 Ja | 1 | 1000
  m1084 Aufgaben je Ziehung Ja frisch | 6,5 % | v1 Ja | 2 | 1000
  m1085 Aufgaben je Ziehung Ja frisch | 7,3 % | v1 Ja | 3 | 1000
  m1086 Aufgaben je Ziehung Nein frisch | 6,3 % | v1 Nein | 1 | 1000
  m1087 Aufgaben je Ziehung Nein frisch | 5,5 % | v1 Nein | 2 | 1000
  m1088 Aufgaben je Ziehung Nein frisch | 5,5 % | v1 Nein | 3 | 1000
  m1089 Differenz relativ frisch | +19,7 % | Ja-Nein | 1-3 | 3000
  m1090 Differenz KI95 frisch (20261016) | -0,23 bis +2,47 Punkte | Ja-Nein | 1-3 | 3000
  m1091 Differenz KI95 beide Ziehsaaten | +0,28 bis +2,22 Punkte | Ja-Nein | 1-3 | 6000
  m1092 Ja gegen d64 ohne Etikett KI95 | -3,37 bis +1,67 Punkte | Ja-d64 | 1-3
  m1093 legal je Ziehung Ja | 56,4 % | v1 Ja | 1 | 1000
  m1094 legal je Ziehung Ja | 51,1 % | v1 Ja | 2 | 1000
  m1095 legal je Ziehung Ja | 57,5 % | v1 Ja | 3 | 1000
  m1096 Kontext-Sonde alle vier Ja | 67,9 % | v1 Ja | 1 | 1000
  m1097 Kontext-Sonde alle vier Ja | 59,6 % | v1 Ja | 2 | 1000
  m1098 Kontext-Sonde alle vier Ja | 67,5 % | v1 Ja | 3 | 1000
  m1099 Kontext-Sonde alle vier Nein | 66,6 % | v1 Nein | 1 | 1000
  m1100 Kontext-Sonde alle vier Nein | 57,8 % | v1 Nein | 2 | 1000
  m1101 Kontext-Sonde alle vier Nein | 67,9 % | v1 Nein | 3 | 1000
  m1102 Rot-Probe Loss gemischt | 8,90 | v1 | 1 | 300
  m1103 Messlatte | 23,3 % | -
Ergebnis e102 [2026-10-21 14:34]: teilweise
  Fazit: Der Kontrast Ja/Nein ist der einzige echte Effekt der ganzen Schachreihe (6 von 6 Messungen gleichgerichtet, +21,6 % relativ ueber beide Ziehsaaten), aber die vorab zur Entscheidung bestimmte frische Wiederholung enthaelt die Null - nach Wortlaut nicht belegt. Und er zeigt in die unbrauchbare Richtung: 'Ja' liegt auf dem Niveau des d64-Laufs ohne Etikett, nur 'Nein' wird schlechter. Messlatte 23,3 % weit verfehlt. Als Erklaerung wertvoll (das Vorzeichen 'Aufgabe' steckt lernbar in der Verteilung), als Werkzeug nutzlos. Lehre: drei Saaten tragen eine Richtungsaussage, aber kein geschachteltes Intervall; dafuer braeuchte es acht bis zehn.
  Offen: Mit 8-10 Saaten liesse sich der Kontrast nach der eigenen Regel entscheiden (~3 h Training), nicht gemacht.
  Datei: rechner-a:~/snai_pruef/knirps/gebiete/ERGEBNIS_sichtung.md (Abschnitt 'v1 Etikett')
Chronik:
  2026-10-21 14:33 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_schach_material.txt (V1 samt Nachtrag nach dem Pruefer, laut Text vor den Laeufen, 2026-10-15). Die Wiederholung auf frischen Ziehungen folgte der Projektregel 'knapp erfuellt ist nicht erfuellt', nicht der Kriteriendatei.)
  2026-10-21 14:34 Rezept r108
  2026-10-21 14:34 Status geplant -> laeuft (Rezept r108)
  2026-10-21 14:34 Messwerte m1074-m1103
  2026-10-21 14:34 Ergebnis e102: teilweise
  2026-10-21 14:34 Status laeuft -> ausgewertet (Ergebnis e102)
```
