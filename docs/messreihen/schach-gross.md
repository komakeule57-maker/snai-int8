# snai/schach-gross

```text
snai/schach-gross - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:35
Frage: Vermutung 'nicht genug Material oder nicht lange genug trainiert': Hebt der Knirps d96 mit allen 153.086 Trainingsstellungen und 46,5 statt 12,8 Mio. Token (zwei Stellraeder zugleich) die Loesbarkeit B ueber die Saettigung der Leiter?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_schach_gross.txt (laut Text vor dem Lauf, 2026-10-15; mtime 13:01). Ergebnis später abgeloest durch eine Wiederholung ohne Kollaps.):
  Vergleich gegen Leiter-Zelle d96 (A 59,4 %, B 14,4 %, C 8,5 %). (1) Mehr Material und Zeit hilft, wenn B am Endstand in ALLEN drei Saaten ueber 15,9 % liegt. (2) Saettigung echt, wenn B am Endstand in 13,0-15,9 % liegt UND die Kurve keinen Anstieg ueber 10 % relativ zwischen Segment 4 und Segment 8 zeigt. (3) Sonst traegt es keinen Schluss, beide Lesarten. A und Form getrennt berichtet, kein Urteil. Messlatte 23,3 % wird berichtet.
Baut auf: snai/schach-leiter
Darauf baut: snai/schach-clip, snai/schach-kollaps-trennung, snai/merkmal-sr-lang-schach
Rezepte:
  r114 [2026-10-21] bash kette_gross.sh (startet je Saat: PRE=gross VOK=schach setsid nohup bash lauf_material.sh gross_s<S> 0.001 8 factory/checkpoints/gross_gen_s<S>.snai 727208; darin train_cluster.php wie bei snai/schach-d64-lauf); Zwischenpunkte nur Saat 1: ziehe_schach.php 300 1.0 4711 + schach.py --streng 0.70 0.15; Endstand 1.000 je Saat
      quelltext: proj_ow: cortex.nim 7b67236c, libcortex.so 563780e3 (gebaut 2026-10-13), train_worker.php af8e0a4f, train_cluster.php 2db1564a (md5 heute gelesen); kette_gross.sh 06320ef1, lauf_material.sh db41d2a1
      parameter: d96 (96/6/16, ffn 384, 238.368 Param.), alle 153.086 Stellungen, 5.817.670 Token je Epoche, 8 Segmente a ~93.294 Schritte, DECAY 727.208, LR 0,001 -> 0,0001 Cosinus, Warmup 500, WD 0,1, INT8_FULL, gebunden, 1 Arbeiter, Revival aus, proj_ow
      seed: Genesis 1, 2, 3 (bitgleich zu schach_gen_d96h6_s<S>); Ziehsaat 4711; Bootstrap 4711
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/gebiete/gross_s<S>.log, gross_s<S>.mess.jsonl, kette_gross.log, gross_verlauf.jsonl, gross_dump.jsonl, ziehungen.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/gebiete/ziehungen.jsonl, gross_verlauf.jsonl, gross_s<S>.mess.jsonl; Formfehler Endstand mit form_sonde.py am 2026-10-21 nachgerechnet; KI und Formfehler-Verlauf aus ERGEBNIS_sichtung.md
  m1199 A legal je Ziehung | 30,6 % | gross | 1 | 1000
  m1200 A legal je Ziehung | 52,9 % | gross | 2 | 1000
  m1201 A legal je Ziehung | 30,0 % | gross | 3 | 1000
  m1202 B unter den legalen | 14,7 % | gross | 1 | 306
  m1203 B unter den legalen | 13,4 % | gross | 2 | 529
  m1204 B unter den legalen | 11,3 % | gross | 3 | 300
  m1205 C je Ziehung | 4,5 % | gross | 1 | 1000
  m1206 C je Ziehung | 7,1 % | gross | 2 | 1000
  m1207 C je Ziehung | 3,4 % | gross | 3 | 1000
  m1208 A Mittel gegen Leiter-d96 KI95 | 37,8 gegen 59,4 %, -31,0 bis -7,7 Punkte | gross-d96 | 1-3 | 3000
  m1209 B Mittel gegen Leiter-d96 KI95 | 13,1 gegen 14,4 %, -4,5 bis +2,0 Punkte | gross-d96 | 1-3 | 3000
  m1210 C Mittel gegen Leiter-d96 KI95 | 5,0 gegen 8,5 %, -5,9 bis -1,2 Punkte | gross-d96 | 1-3 | 3000
  m1211 B Verlauf Segment 1-8 | 9,2 / 6,4 / 6,6 / 8,4 / 9,7 / 16,3 / 16,7 / 15,6 % | gross | 1 | 300
  m1212 B Segment 8 minus 5 KI95 | +5,9 Punkte, -2,8 bis +14,6 | gross | 1 | 300
  m1213 Formfehler Endstand | 34,6 % | gross | 1 | 1000
  m1214 Formfehler Endstand | 0,2 % | gross | 2 | 1000
  m1215 Formfehler Endstand | 37,7 % | gross | 3 | 1000
  m1216 Formfehler Endstand | 2,5 % | Leiter-d96 | 1 | 1000
  m1217 Formfehler Endstand | 1,2 % | Leiter-d96 | 2 | 1000
  m1218 Formfehler Endstand | 2,0 % | Leiter-d96 | 3 | 1000
  m1219 Formfehler Verlauf | 3,3 / 5,7 / 3,7 / 6,0 / 1,0 / 27,0 / 34,0 / 33,3 % | gross | 1 | 300
  m1220 Held-out-Loss Segment 1-8 | 1,4346 / 1,4335 / 1,4121 / 1,3960 / 1,3844 / 1,3922 / 1,3886 / 1,3701 | gross | 1 | 300
  m1221 Held-out-Loss Segment 1-8 | 1,4292 / 1,4415 / 1,4145 / 1,3947 / 1,3715 / 1,3518 / 1,3423 / 1,3433 | gross | 2 | 300
  m1222 Held-out-Loss Segment 1-8 | 1,4340 / 1,4303 / 1,4210 / 1,4085 / 1,4003 / 1,4103 / 1,3893 / 1,3805 | gross | 3 | 300
  m1223 Messlatte | 23,3 % | -
Ergebnis e110 [2026-10-21 14:35]: verfehlt
  Fazit: Regel (1) nicht erfuellt (B 14,7 / 13,4 / 11,3 %, nirgends ueber 15,9 %): viermal Material und Rechenzeit bewegen die Loesbarkeit nicht, die Vermutung ist fuer B mit Nein beantwortet. Fuer Regel (2) gibt es zwei Lesarten (Punktwert +61 % -> Fall 3; Intervall enthaelt die Null -> Fall 2); die Kriteriendatei legte eine 10-%-Schwelle auf 300 Ziehungen mit +-8 Punkten Rauschen, die Bedingung war nie pruefbar. Die Verschlechterung von A und C (-36 % bzw. -41 %) und der Formkollaps in 2 von 3 Saaten waren ein Engine-Defekt: die 8-Bit-Adam-Momente liessen das zweite Moment nicht abklingen (Embedding-Kollaps). Die Wiederholung mit zufaellig gerundeten Momenten (Kriterien merkmal/sr/kriterien_lang_sr.txt) zeigt A +11,6 % ueber der Leiter und B weiter gesaettigt. Gueltig bleibt also: Material/Zeit heben B nicht; A und C dieses Laufs sind durch den Defekt verfaelscht.
  Offen: Zwischenpunkte wurden nur fuer Saat 1 gemessen (Kriteriendatei: 24 Messpunkte). Welches der beiden Stellraeder den Kollaps traegt: snai/schach-kollaps-trennung.
  Datei: rechner-a:~/snai_pruef/knirps/gebiete/ERGEBNIS_sichtung.md (Abschnitte 'Mehr Material und laengeres Training' und 'Nachtrag 2026-10-18')
Chronik:
  2026-10-21 14:35 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_schach_gross.txt (laut Text vor dem Lauf, 2026-10-15; mtime 13:01). Ergebnis später abgeloest durch eine Wiederholung ohne Kollaps.)
  2026-10-21 14:35 Rezept r114
  2026-10-21 14:35 Status geplant -> laeuft (Rezept r114)
  2026-10-21 14:35 Messwerte m1199-m1223
  2026-10-21 14:35 Ergebnis e110: verfehlt
  2026-10-21 14:35 Status laeuft -> ausgewertet (Ergebnis e110)
```
