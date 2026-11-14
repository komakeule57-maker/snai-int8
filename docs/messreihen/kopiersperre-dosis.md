# snai/kopiersperre-dosis

```text
snai/kopiersperre-dosis - ausgewertet, angelegt 2026-10-25, zuletzt 2026-10-25 17:08
Frage: Hilft eine stärkere Kopiersperre (DS = Minimum der Kalibrierungen von s2-s4, vor allem k=3: 0,56 statt 0,87) auch an s4 und s5, für die die ausgelieferte Voreinstellung D4 gilt? Ja = Dosis-Lesart (D4 zu schwach), nein = Kalibrierungs-Lesart (D4 passt, ältere Stände kopieren nur stärker).
Kriterium (festgelegt 2026-10-25 07:20, vor dem ersten Messwert):
  Volltext rechner-a:~/snai_pruef/einstieg/dosis/kriterien_dosis.txt 97e3bb9d. Je Stand (s4, s5; rechner-b, gepaart, 40 FRISCHE Bindungsposten, prompt_bindung_kopie3.sh 2ac20112): Arme 0 / V (D4 Saat 1) / V2 (D4 Saat 2) / S (DS Saat 1) / S2 (DS Saat 2), alle prompt-frei. D1 "stärkere Dosis besser" = in beiden Saaten U_S <= 0,9 U_V UND T_S >= T_V-2 UND E_S <= 1,2 E_V (E = Anteil erfundener Wortformen). D2 "Voreinstellung passt" = U_V und U_V2 <= 0,5 U_0 UND Bindung kein Schaden (T >= T_0-2, beide Saaten gleiche Klasse). GESAMT erfüllt = D1 an s4 und s5 (Dosis-Lesart, DS vorschlagen), verfehlt = an keinem (D4 bleibt), teilweise = an einem. 3 Lesepaare V/S je Stand.
Plan: rechner-a:~/snai_pruef/einstieg/dosis/kriterien_dosis.txt
Baut auf: snai/kopiersperre-nachmessung
Darauf baut: snai/kopiersperre-gross, snai/kopiersperre-kombi
Rezepte:
  r414 [2026-10-25] s4 (Teil 1 von 2): rechner-a: cd ~/snai_pruef/einstieg/dosis && bash start.sh s4 (kopiert nach rechner-b, prüft md5 und freien Speicher, startet dort setsid bash lauf.sh s4; je Job: PB_TAG=_<arm>_<i> PB_VON=i PB_BIS=i OMP_NUM_THREADS=1 SNAI_GAIN_GUARD=0 [Stellräder] prompt_bindung_kopie3.sh modell/prod512b_s4.snai 3 dosis/s4/<arm>, xargs -P 6)
      quelltext: dosis/lauf.sh 4c831dd8, dosis/start.sh 3aa40dba, tools/prompt_bindung_kopie3.sh 2ac20112, snai_inference_kopie2.php 516e3a65, dosis/auswert_dosis.py 5f2f597b, posten.txt d79af433. Modell prod512b_s4 751d92d9.
      parameter: D4=0.4174,0.6245,0.8671,0.7404,0.7988; DS=0.3613,0.5620,0.5627,0.7051,0.7978; Arme 0 | V (D4 S1) | V2 (D4 S2) | S (DS S1) | S2 (DS S2), alle SNAI_KOPIE_PROMPTFREI=1; Beam 3 ROH; 40 frische Posten.
      seed: SNAI_KOPIE_SAAT 1/2; Beam deterministisch
      rechner: rechner-b, 6 Prozesse (~12 GB von 15,7)
      logs: rechner-b:~/snai_pruef/einstieg/dosis/s4/{0,V,V2,S,S2}/, dosis/fortschritt.log, dosis/lauf_s4.out
  r417 [2026-10-25] s5 (Teil 2 von 2): rechner-a: cd ~/snai_pruef/einstieg/dosis && bash start.sh s5 (holt prod512b_s5 von tg1 nach END-LOSS-Zeile, md5-Prüfung, kopiert nach rechner-b, startet dort setsid bash lauf.sh s5: Schritt 1 Sonde 200 Fenster + beamlauf2 p512s5_0 + rate12.py -> dosis/durchlass_s5.txt, parallel Bindung xargs -P 4)
      quelltext: wie r414; Modell prod512b_s5 10ab21ad (tg1, Segment fertig 2026-10-25 11:49, END-LOSS 3.63902)
      parameter: wie r414 (D4, DS, Arme 0/V/V2/S/S2, 40 frische Posten)
      seed: SNAI_KOPIE_SAAT 1/2; Beam deterministisch
      rechner: rechner-b, 5 Prozesse (~10 GB)
      logs: rechner-b:~/snai_pruef/einstieg/dosis/s5/, dosis/t1_s5.jsonl, dosis/durchlass_s5.txt, b/p512s5_0, dosis/fortschritt.log, dosis/lauf_s5.out
  r418 [2026-10-25] s5 Wiederholung (frische Posten): rechner-b: cd ~/snai_pruef/einstieg/dosis/wdh && setsid bash lauf.sh s5 (je Job wie r414, aber prompt_bindung_kopie4.sh, Ausgabe dosis/wdh/s5/<arm>/, xargs -P 6)
      quelltext: dosis/wdh/lauf.sh 868ffacc (aus dosis/lauf.sh 4c831dd8), tools/prompt_bindung_kopie4.sh 361b1151, dosis/wdh/posten.txt 49aa154f, snai_inference_kopie2.php 516e3a65; Modell prod512b_s5 10ab21ad. Kriterien-Nachtrag kriterien_dosis.txt 5d6a77a4 (vor dem Lauf).
      parameter: wie r414: D4, DS, Arme 0/V/V2/S/S2; 40 weitere frische Posten
      seed: SNAI_KOPIE_SAAT 1/2
      rechner: rechner-b, 6 Prozesse (~13,4 GB von 15,7)
      logs: rechner-b:~/snai_pruef/einstieg/dosis/wdh/s5/, dosis/wdh/fortschritt.log
      notiz: Anlass: s5 Saat 1 U_S/U_V 0,85 knapp an 0,9, Bootstrap [0,58; 1,27] -> Hausregel "knapp erfüllt ist nicht erfüllt".
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/einstieg/log/auswert_dosis_s4.txt (dosis/auswert_dosis.py 5f2f597b), Rohdaten dosis/s4/ (von rechner-b); 200/200 rc 0, 0 OOM, Fehlerkanal leer
  m5352 Treffer 0 / V / V2 / S / S2 | 4 / 9 / 7 / 10 / 7 von 40 | s4 | 1/2 | 40
  m5353 U 0 / V / V2 / S / S2 | 0,559 / 0,177 / 0,161 / 0,065 / 0,107 | s4 | 1/2 | 40
  m5354 E 0 / V / V2 / S / S2 | 0,0604 / 0,0784 / 0,0624 / 0,0722 / 0,0699 | s4 | 1/2 | 40
  m5355 D1 S gegen V: U-Verhältnis, Treffer, E-Verhältnis | 0,37; 10 gegen 9; 0,92 | s4 | 1 | 40
  m5356 D1 S2 gegen V2: U-Verhältnis, Treffer, E-Verhältnis | 0,66; 7 gegen 7; 1,12 | s4 | 2 | 40
  m5357 D1 stärkere Dosis besser | ja (beide Saaten) | s4 | 1/2 | 40
  m5358 D2 Voreinstellung passt | ja (U 0,32/0,29 x U_0, Bindung kein Schaden) | s4 | 1/2 | 40
  Quelle: rechner-a:~/snai_pruef/einstieg/log/auswert_dosis.txt und log/bootstrap_dosis.txt (gepaarter Bootstrap über die 40 Posten, 10000 Ziehungen, Saat 20261025); Rohdaten dosis/s5/ (von rechner-b); 200/200 rc 0, 0 OOM, Fehlerkanal leer
  m5443 Durchlass D5 aus 12 Prompts (nur berichtet) | 0.4217,0.6151,0.7586,0.7206,0.8108 | s5 |  | 12 Prompts
  m5444 Treffer 0 / V / V2 / S / S2 | 8 / 7 / 7 / 7 / 8 von 40 | s5 | 1/2 | 40
  m5445 U 0 / V / V2 / S / S2 | 0,457 / 0,089 / 0,111 / 0,076 / 0,069 | s5 | 1/2 | 40
  m5446 E 0 / V / V2 / S / S2 | 0,0458 / 0,0625 / 0,0601 / 0,0560 / 0,0600 | s5 | 1/2 | 40
  m5447 D1 S gegen V: U-Verhältnis, Treffer, E-Verhältnis | 0,85; 7 gegen 7; 0,90 | s5 | 1 | 40
  m5448 D1 S2 gegen V2: U-Verhältnis, Treffer, E-Verhältnis | 0,62; 8 gegen 7; 1,00 | s5 | 2 | 40
  m5449 D2 Voreinstellung passt | ja (U 0,20/0,24 x U_0, Bindung kein Schaden) | s5 | 1/2 | 40
  m5450 U-Verhältnis S/V, 95%-Bootstrap-Intervall | 0,37 [0,25; 0,51] | s4 | 1 | 40
  m5451 U-Verhältnis S2/V2, 95%-Bootstrap-Intervall | 0,66 [0,48; 0,91] | s4 | 2 | 40
  m5452 U-Verhältnis S/V, 95%-Bootstrap-Intervall | 0,85 [0,58; 1,27] KNAPP | s5 | 1 | 40
  m5453 U-Verhältnis S2/V2, 95%-Bootstrap-Intervall | 0,62 [0,46; 0,83] | s5 | 2 | 40
  m5454 Gesamtregel nach Wortlaut | erfüllt (D1 an s4 und s5), aber s5 Saat 1 knapp -> Wiederholung auf frischen Posten vor dem Urteil | s4/s5 | 1/2 | 40
  Quelle: rechner-a:~/snai_pruef/einstieg/log/auswert_dosis_wdh.txt, log/bootstrap_dosis_wdh.txt; Rohdaten dosis/wdh/s5/ (von rechner-b); 200/200 rc 0, 0 OOM, Fehlerkanal leer
  m5455 WDH Treffer 0 / V / V2 / S / S2 | 5 / 8 / 8 / 9 / 5 von 40 | s5 | 1/2 | 40
  m5456 WDH U 0 / V / V2 / S / S2 | 0,479 / 0,131 / 0,143 / 0,088 / 0,077 | s5 | 1/2 | 40
  m5457 WDH E 0 / V / V2 / S / S2 | 0,0574 / 0,0578 / 0,0506 / 0,0630 / 0,0532 | s5 | 1/2 | 40
  m5458 WDH D1 S gegen V: U-Verhältnis [95 %], Treffer, E-Verhältnis | 0,67 [0,47; 0,93]; 9 gegen 8; 1,09 | s5 | 1 | 40
  m5459 WDH D1 S2 gegen V2: U-Verhältnis [95 %], Treffer, E-Verhältnis | 0,54 [0,40; 0,70]; 5 gegen 8 (verloren 3, gewonnen 0, McNemar p 0,25); 1,05 | s5 | 2 | 40
  m5460 WDH D1 stärkere Dosis besser | nein (Saat 2 verfehlt T_S >= T_V - 2: 5 gegen 8) | s5 | 1/2 | 40
  m5461 WDH D2 Voreinstellung passt | ja (U 0,27/0,30 x U_0, Bindung kein Schaden) | s5 | 1/2 | 40
  m5462 Gesamturteil nach Nachtrag | teilweise (D1 an s4 ja; an s5 erster Satz ja, Wiederholung nein -> nicht belegt) | s4/s5 | 1/2 | 40
Ergebnis e367 [2026-10-25 17:08]: teilweise
  Fazit: Die stärkere Dosis DS senkt die Schleifen robust weiter: U_S/U_V 0,37-0,85 in sechs Vergleichen, fünf Intervalle ganz unter 1. Den Wechsel der Voreinstellung trägt das aber nicht. An s4 ist D1 erfüllt. An s5 ist es nicht belegt: Im ersten Postensatz ist es knapp (0,85, Intervall bis 1,27), in der vorab festgelegten Wiederholung verliert S2 drei Namen gegen V2 (5 gegen 8, p 0,25). Nach dem Wortlaut ohne Wiederholung wäre die Reihe erfüllt; beide Lesarten stehen in der Ergebnisdatei. Die ausgelieferte D4 passt an allen drei Postensätzen (D2) und bleibt. Ob eine stärkere Sperre Namen kostet, kann eine 40-Posten-Probe nicht entscheiden. Weiter lohnt nur eine größere Bindungsprobe (z. B. 120 Posten an s5, nur V gegen S, mehrere Saaten), wenn die zusätzliche Schleifensenkung den Aufwand wert ist.
  Offen: Bindungskosten stärkerer Dosis (Rauschen oder beginnende Abnahme) nicht entschieden. Lesbarkeit nur über E und 9 gelesene Paare: beide Fassungen ähnlich holprig. Kein Modell außer prod512b, keine Stände nach s5.
  Datei: rechner-a:~/snai_pruef/einstieg/dosis/ERGEBNIS_dosis.md
Chronik (juengste 8 von 10, voll=True zeigt alle):
  2026-10-25 07:24 Status geplant -> laeuft (Rezept r414)
  2026-10-25 08:21 Messwerte m5352-m5358
  2026-10-25 15:00 Rezept r417 (s5 (Teil 2 von 2))
  2026-10-25 16:09 Messwerte m5443-m5454
  2026-10-25 16:11 Rezept r418 (s5 Wiederholung (frische Posten))
  2026-10-25 17:08 Messwerte m5455-m5462
  2026-10-25 17:08 Ergebnis e367: teilweise
  2026-10-25 17:08 Status laeuft -> ausgewertet (Ergebnis e367)
```
