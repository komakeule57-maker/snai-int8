# snai/schach-leiter

```text
snai/schach-leiter - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:34
Frage: Schach-Groessenleiter d32 / d64 / d96 (Kopfbreite 16, Breite/Koepfe/ffn gemeinsam): Lernt mehr Modell die Loesbarkeit (B = Aufgaben unter den legalen), oder nur die Form (A = legal)? Und erreicht eine Zelle die Messlatte 23,3 %?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_schach_leiter.txt (2026-10-15, vor den Laeufen; Statistik-Nachtrag nach d32/d64 und vor d96; Prognose vor den d96-Zahlen).):
  Je Zelle Mittel der 3 Saaten. (1) Deutung 'Loesbarkeit nicht in den Daten' widerlegt, wenn B monoton steigt UND B(d96) >= 1,1 x B(d32) UND B(d96) >= 14,1 %. (2) Deutung haelt, wenn B ueber alle drei Groessen innerhalb +-10 % liegt, waehrend A steigt. (3) Sonst 'traegt keinen Schluss', beide Lesarten. Eigenes Urteil: erreicht eine Zelle C >= 23,3 % in allen drei Saaten, war d64 nur zu klein. Nachtrag Statistik (vor d96): massgeblich zusaetzlich vollstaendige Trennung der Saaten und geschachtelter Bootstrap (Saaten, dann Ziehungen, 2.000, Saat 4711); die Urteilsregel selbst bleibt.
Baut auf: snai/schach-d64-lauf
Darauf baut: snai/schach-etikett, snai/schach-gross, snai/schach-loesungszug, snai/schach-matt2
Rezepte:
  r107 [2026-10-21] bash lauf_schach.sh d<B>_s<S> 0.001 8 factory/checkpoints/schach_gen_d<B>h<B/16>_s<S>.snai 194800 (Genesis: SNAI_VOCAB=.../schach.json php init_base.php <ziel> 0 <B> 64 2 <4B> <S>, .heads = B/16); Auswertung nach_leiter_schach.sh (ziehe_schach.php 1000 1.0 4711, schach.py --streng 0.70 0.15, kontext_sonde.py)
      quelltext: proj_ow: cortex.nim 7b67236c, libcortex.so 563780e3 (gebaut 2026-10-13), train_worker.php af8e0a4f, train_cluster.php 2db1564a (md5 heute gelesen, Dateien seit dem Lauf unveraendert laut mtime); lauf_schach.sh 5316f02c, nach_leiter_schach.sh a11359df
      parameter: d32 32/2/16 ffn 128 (30.304 Param.), d64 = snai/schach-d64-lauf (109.760), d96 96/6/16 ffn 384 (238.368); sonst wie d64-Lauf (39.991 Stellungen, 8 Epochen, DECAY 194.800)
      seed: Genesis 1, 2, 3 je Zelle; Ziehsaat 4711; Bootstrap 4711
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/gebiete/d32_s<S>.*, d96_s<S>.*, nach_leiter.out, ziehungen.jsonl, d96_dump.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/gebiete/ziehungen.jsonl (Saatwerte, nachgelesen) und d96_s<S>.mess.jsonl; Mittel und KI aus ERGEBNIS_sichtung.md (Bootstrap nicht nachgerechnet)
  m1043 A legal je Ziehung | 48,2 % | d32 | 1 | 1000
  m1044 A legal je Ziehung | 50,7 % | d32 | 2 | 1000
  m1045 A legal je Ziehung | 49,0 % | d32 | 3 | 1000
  m1046 A legal je Ziehung | 56,3 % | d64 | 1 | 1000
  m1047 A legal je Ziehung | 50,5 % | d64 | 2 | 1000
  m1048 A legal je Ziehung | 60,4 % | d64 | 3 | 1000
  m1049 A legal je Ziehung | 57,9 % | d96 | 1 | 1000
  m1050 A legal je Ziehung | 59,5 % | d96 | 2 | 1000
  m1051 A legal je Ziehung | 60,9 % | d96 | 3 | 1000
  m1052 B unter den legalen | 12,0 % | d32 | 1 | 482
  m1053 B unter den legalen | 11,8 % | d32 | 2 | 507
  m1054 B unter den legalen | 9,2 % | d32 | 3 | 490
  m1055 B unter den legalen | 13,3 % | d64 | 1 | 563
  m1056 B unter den legalen | 12,1 % | d64 | 2 | 505
  m1057 B unter den legalen | 17,7 % | d64 | 3 | 604
  m1058 B unter den legalen | 13,0 % | d96 | 1 | 579
  m1059 B unter den legalen | 15,0 % | d96 | 2 | 595
  m1060 B unter den legalen | 15,1 % | d96 | 3 | 609
  m1061 B Mittel (KI) | 11,0 % (9,4-12,6) | d32 | 1-3 | 3000
  m1062 B Mittel (KI) | 14,5 % (12,8-16,2) | d64 | 1-3 | 3000
  m1063 B Mittel (KI) | 14,4 % (12,7-16,0) | d96 | 1-3 | 3000
  m1064 C je Ziehung Mittel | 5,4 % | d32 | 1-3 | 3000
  m1065 C je Ziehung Mittel | 8,1 % | d64 | 1-3 | 3000
  m1066 C je Ziehung Mittel | 8,5 % | d96 | 1-3 | 3000
  m1067 C je Ziehung max Saat | 10,7 % | d64 | 3 | 1000
  m1068 Held-out-Loss Ende | 1,3412 | d96 | 1 | 300
  m1069 Held-out-Loss Ende | 1,3399 | d96 | 2 | 300
  m1070 Held-out-Loss Ende | 1,3305 | d96 | 3 | 300
  m1071 Rot-Probe Loss | 9,60 | d96 | 1 | 300
  m1072 Rot-Probe Loss | 10,78 | d96 | 2 | 300
  m1073 Rot-Probe Loss | 9,86 | d96 | 3 | 300
Ergebnis e101 [2026-10-21 14:34]: keine_aussage
  Fazit: Nach Vorab-Regel Fall (3) 'traegt keinen Schluss': B ist nicht monoton (14,5 -> 14,4), aber auch nicht ueber alle Zellen innerhalb 10 % (d32 gegen d96 +31 %). Sachlich zeigt sich eine Stufe (d32 -> d64, alle Saaten getrennt, knapp 12,1 gegen 12,0) und dann Saettigung knapp ueber dem Zufallsniveau 12,8 %, weit unter der Decke 94,7 %. A steigt durchgehend (49 -> 56 -> 59 %): Parameter kaufen Form, nicht Loesbarkeit. Keine Zelle erreicht 23,3 %; die Frage 'war d64 zu klein' ist mit Nein beantwortet. Beide eigenen Erklaerungen waren zu einfach; offen blieb nur das Material (Folgeversuche v1-v3 und gross).
  Offen: Welche der gemeinsam veraenderten Groessen (Breite, Koepfe, ffn) wirkt, entscheidet die Leiter nicht; mehr Schichten nicht geprueft. Prognose: A getroffen, B verfehlt (16,5 vorhergesagt), C knapp verfehlt.
  Datei: rechner-a:~/snai_pruef/knirps/gebiete/ERGEBNIS_sichtung.md (Abschnitt 'Die Groessenleiter d32 / d64 / d96')
Chronik:
  2026-10-21 14:33 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_schach_leiter.txt (2026-10-15, vor den Laeufen; Statistik-Nachtrag nach d32/d64 und vor d96; Prognose vor den d96-Zahlen).)
  2026-10-21 14:34 Rezept r107
  2026-10-21 14:34 Status geplant -> laeuft (Rezept r107)
  2026-10-21 14:34 Messwerte m1043-m1073
  2026-10-21 14:34 Ergebnis e101: keine_aussage
  2026-10-21 14:34 Status laeuft -> ausgewertet (Ergebnis e101)
```
