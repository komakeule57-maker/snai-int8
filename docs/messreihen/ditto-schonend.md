# snai/ditto-schonend

```text
snai/ditto-schonend - ausgewertet, angelegt 2026-10-24, zuletzt 2026-10-24 15:35
Frage: Gibt es eine DITTO-Einstellung (lambda 1; neues Stellrad AB = Verlust erst ab Kopie k; 50 % oder 10 % Wiederholungsdaten), die die Selbstverstaerkung senkt, ohne das nuetzliche Kopieren (TP1, Beleg-Anteil) zu beschaedigen?
Kriterium (festgelegt 2026-10-24 10:04, vor dem ersten Messwert):
  Je D-Arm X (D5a lambda1 AB1 Mix50, D5b lambda1 AB2 Mix50, D1b lambda1 AB2 Mix10) gegen M (natuerlicher Text), je Saat gepaart, 3 Saaten: 3/3 ja, 0/3 nein, sonst saatabhaengig. K1 Z_X <= 0,5 Z_M (Z = TP4-TP1, sonde_schleife.php 50 Saetze; ungueltig bei Z_M < 0,03); K1b TP1_X >= 0,9 TP1_M; K4 Beleg-Anteil A_X >= 0,9 A_M (beleg_sonde.php 120 Posten, Schicht A). Stuetzend K2 U_X <= 0,9 U_M (unscharf.py ff3999bd, K=2 von 8, Beam 3, 12 Prompts). Kosten K3 Held-out H_X - H_M <= 2 % (200 Fenster) = tragbar. Arm schonend wirksam = K1, K1b, K4 je 3/3. Reihe erfuellt = mind. ein Arm schonend wirksam UND K3 tragbar; teilweise = schonend wirksam ohne K3; verfehlt = kein Arm K1; sonst keine_aussage. Volltext rechner-b:~/snai_pruef/ditto2/kriterien.txt 777c6b94.
Plan: rechner-b:~/snai_pruef/ditto2/kriterien.txt
Baut auf: snai/ditto-knirps
Darauf baut: snai/schleife-einstieg
Rezepte:
  r405 [2026-10-24] wie r402, Ordner jetzt rechner-b:~/snai_pruef/ditto3 (cd ~/snai_pruef/ditto3 && setsid nohup bash kette.sh; python3 auswert2.py)
      quelltext: wie r402; nach Umbenennung nur der Pfad ditto2->ditto3 per sed ersetzt: arm.sh f64851eb, mess2.sh d51c0d7f, kette.sh 13374163, probe.sh 710ef9c9, auswert2.py d29d3bad (Auswertung danach unveraendert reproduziert)
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/ditto3/{log,mess,arme}; Quelltextkopie rechner-a:~/snai_pruef/ditto3
      notiz: 2026-10-24 umbenannt: ditto2 gehoert auf rechner-a dem Fork SnAI_Evo (Kollision). Pfade in e354 und den Dateiangaben (rechner-b:~/snai_pruef/ditto2/...) liegen jetzt unter ditto3.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/ditto2/auswert2.py 81bd96a2, mess/<arm>_s<saat>/ und mess/basis/
  m5023 Z = TP4-TP1 | 0,1323 | C1 | 1 | 50
  m5024 TP1 zweite Kopie | 0,3575 | C1 | 1 | 50
  m5025 TP4/TP1 | 1,370 | C1 | 1 | 50
  m5026 Beleg-Anteil A | 0,1983 | C1 | 1 | 120
  m5027 U Beam 12 Prompts | 0,6130 | C1 | 1 | 12
  m5028 Held-out 200 Fenster | 4,2677 | C1 | 1 | 200
  m5029 Z = TP4-TP1 | 0,1417 | C1 | 2 | 50
  m5030 TP1 zweite Kopie | 0,3215 | C1 | 2 | 50
  m5031 TP4/TP1 | 1,441 | C1 | 2 | 50
  m5032 Beleg-Anteil A | 0,1911 | C1 | 2 | 120
  m5033 U Beam 12 Prompts | 0,6653 | C1 | 2 | 12
  m5034 Held-out 200 Fenster | 4,2830 | C1 | 2 | 200
  m5035 Z = TP4-TP1 | 0,1601 | C1 | 3 | 50
  m5036 TP1 zweite Kopie | 0,3397 | C1 | 3 | 50
  m5037 TP4/TP1 | 1,471 | C1 | 3 | 50
  m5038 Beleg-Anteil A | 0,1938 | C1 | 3 | 120
  m5039 U Beam 12 Prompts | 0,6792 | C1 | 3 | 12
  m5040 Held-out 200 Fenster | 4,2755 | C1 | 3 | 200
  m5041 Z = TP4-TP1 | 0,1327 | C5 | 1 | 50
  m5042 TP1 zweite Kopie | 0,6622 | C5 | 1 | 50
  m5043 TP4/TP1 | 1,200 | C5 | 1 | 50
  m5044 Beleg-Anteil A | 0,2086 | C5 | 1 | 120
  m5045 U Beam 12 Prompts | 0,7080 | C5 | 1 | 12
  m5046 Held-out 200 Fenster | 4,3835 | C5 | 1 | 200
  m5047 Z = TP4-TP1 | 0,1683 | C5 | 2 | 50
  m5048 TP1 zweite Kopie | 0,5744 | C5 | 2 | 50
  m5049 TP4/TP1 | 1,293 | C5 | 2 | 50
  m5050 Beleg-Anteil A | 0,1823 | C5 | 2 | 120
  m5051 U Beam 12 Prompts | 0,7160 | C5 | 2 | 12
  m5052 Held-out 200 Fenster | 4,3823 | C5 | 2 | 200
  m5053 Z = TP4-TP1 | 0,1177 | C5 | 3 | 50
  m5054 TP1 zweite Kopie | 0,6630 | C5 | 3 | 50
  m5055 TP4/TP1 | 1,178 | C5 | 3 | 50
  m5056 Beleg-Anteil A | 0,1904 | C5 | 3 | 120
  m5057 U Beam 12 Prompts | 0,7010 | C5 | 3 | 12
  m5058 Held-out 200 Fenster | 4,3822 | C5 | 3 | 200
  m5059 Z = TP4-TP1 | 0,0821 | D1b | 1 | 50
  m5060 TP1 zweite Kopie | 0,3057 | D1b | 1 | 50
  m5061 TP4/TP1 | 1,268 | D1b | 1 | 50
  m5062 Beleg-Anteil A | 0,1907 | D1b | 1 | 120
  m5063 U Beam 12 Prompts | 0,5470 | D1b | 1 | 12
  m5064 Held-out 200 Fenster | 4,2594 | D1b | 1 | 200
  m5065 Z = TP4-TP1 | 0,0875 | D1b | 2 | 50
  m5066 TP1 zweite Kopie | 0,2924 | D1b | 2 | 50
  m5067 TP4/TP1 | 1,299 | D1b | 2 | 50
  m5068 Beleg-Anteil A | 0,1867 | D1b | 2 | 120
  m5069 U Beam 12 Prompts | 0,5345 | D1b | 2 | 12
  m5070 Held-out 200 Fenster | 4,2761 | D1b | 2 | 200
  m5071 Z = TP4-TP1 | 0,1000 | D1b | 3 | 50
  m5072 TP1 zweite Kopie | 0,2981 | D1b | 3 | 50
  m5073 TP4/TP1 | 1,336 | D1b | 3 | 50
  m5074 Beleg-Anteil A | 0,1913 | D1b | 3 | 120
  m5075 U Beam 12 Prompts | 0,5202 | D1b | 3 | 12
  m5076 Held-out 200 Fenster | 4,2663 | D1b | 3 | 200
  m5077 Z = TP4-TP1 | 0,0555 | D5a | 1 | 50
  m5078 TP1 zweite Kopie | 0,1506 | D5a | 1 | 50
  m5079 TP4/TP1 | 1,368 | D5a | 1 | 50
  m5080 Beleg-Anteil A | 0,1486 | D5a | 1 | 120
  m5081 U Beam 12 Prompts | 0,3217 | D5a | 1 | 12
  m5082 Held-out 200 Fenster | 4,3725 | D5a | 1 | 200
  m5083 Z = TP4-TP1 | 0,0507 | D5a | 2 | 50
  m5084 TP1 zweite Kopie | 0,1760 | D5a | 2 | 50
  m5085 TP4/TP1 | 1,288 | D5a | 2 | 50
  m5086 Beleg-Anteil A | 0,1694 | D5a | 2 | 120
  m5087 U Beam 12 Prompts | 0,3352 | D5a | 2 | 12
  m5088 Held-out 200 Fenster | 4,3357 | D5a | 2 | 200
  m5089 Z = TP4-TP1 | 0,0649 | D5a | 3 | 50
  m5090 TP1 zweite Kopie | 0,1872 | D5a | 3 | 50
  m5091 TP4/TP1 | 1,346 | D5a | 3 | 50
  m5092 Beleg-Anteil A | 0,1685 | D5a | 3 | 120
  m5093 U Beam 12 Prompts | 0,2756 | D5a | 3 | 12
  m5094 Held-out 200 Fenster | 4,3281 | D5a | 3 | 200
  m5095 Z = TP4-TP1 | 0,0532 | D5b | 1 | 50
  m5096 TP1 zweite Kopie | 0,4531 | D5b | 1 | 50
  m5097 TP4/TP1 | 1,117 | D5b | 1 | 50
  m5098 Beleg-Anteil A | 0,2037 | D5b | 1 | 120
  m5099 U Beam 12 Prompts | 0,7095 | D5b | 1 | 12
  m5100 Held-out 200 Fenster | 4,3118 | D5b | 1 | 200
  m5101 Z = TP4-TP1 | 0,0651 | D5b | 2 | 50
  m5102 TP1 zweite Kopie | 0,4056 | D5b | 2 | 50
  m5103 TP4/TP1 | 1,161 | D5b | 2 | 50
  m5104 Beleg-Anteil A | 0,1672 | D5b | 2 | 120
  m5105 U Beam 12 Prompts | 0,6053 | D5b | 2 | 12
  m5106 Held-out 200 Fenster | 4,3117 | D5b | 2 | 200
  m5107 Z = TP4-TP1 | 0,0574 | D5b | 3 | 50
  m5108 TP1 zweite Kopie | 0,4465 | D5b | 3 | 50
  m5109 TP4/TP1 | 1,129 | D5b | 3 | 50
  m5110 Beleg-Anteil A | 0,1890 | D5b | 3 | 120
  m5111 U Beam 12 Prompts | 0,6356 | D5b | 3 | 12
  m5112 Held-out 200 Fenster | 4,3085 | D5b | 3 | 200
  m5113 Z = TP4-TP1 | 0,1190 | M | 1 | 50
  m5114 TP1 zweite Kopie | 0,2665 | M | 1 | 50
  m5115 TP4/TP1 | 1,446 | M | 1 | 50
  m5116 Beleg-Anteil A | 0,1844 | M | 1 | 120
  m5117 U Beam 12 Prompts | 0,5033 | M | 1 | 12
  m5118 Held-out 200 Fenster | 4,2366 | M | 1 | 200
  m5119 Z = TP4-TP1 | 0,0981 | M | 2 | 50
  m5120 TP1 zweite Kopie | 0,2866 | M | 2 | 50
  m5121 TP4/TP1 | 1,342 | M | 2 | 50
  m5122 Beleg-Anteil A | 0,1909 | M | 2 | 120
  m5123 U Beam 12 Prompts | 0,4308 | M | 2 | 12
  m5124 Held-out 200 Fenster | 4,2435 | M | 2 | 200
  m5125 Z = TP4-TP1 | 0,1127 | M | 3 | 50
  m5126 TP1 zweite Kopie | 0,2867 | M | 3 | 50
  m5127 TP4/TP1 | 1,393 | M | 3 | 50
  m5128 Beleg-Anteil A | 0,1960 | M | 3 | 120
  m5129 U Beam 12 Prompts | 0,4780 | M | 3 | 12
  m5130 Held-out 200 Fenster | 4,2368 | M | 3 | 200
  m5131 Z = TP4-TP1 | 0,1433 | Basis |  | 50
  m5132 TP1 zweite Kopie | 0,2932 | Basis |  | 50
  m5133 TP4/TP1 | 1,489 | Basis |  | 50
  m5134 Beleg-Anteil A | 0,2023 | Basis |  | 120
  m5135 U Beam 12 Prompts | 0,4480 | Basis |  | 12
  m5136 Held-out 200 Fenster | 4,1229 | Basis |  | 200
Ergebnis e354 [2026-10-24 14:41]: verfehlt
  Fazit: DITTO ist fuer prod512b erledigt, auch in schonender Form. lambda 1 allein (D5a) schont das Kopieren nicht: TP1 0,57-0,65 von M, Beleg 0,81-0,89. Das neue Stellrad AB 2 (Verlust erst ab Kopie 2) erhaelt das Kopieren und senkt TP4/TP1 auf 1,12-1,16. Die Beam-Erzeugung wird damit aber 33-41 % (Mix50) bzw. 9-24 % (Mix10) wiederholungsreicher als M, weil die kuenstlichen Wiederholungsdaten die erste Wiederholung beibringen. DITTO holt davon gegen die eigene Kontrolle nur einen Teil zurueck. Kein Arm erreicht K1 mit 3/3. Auch bei grosszuegiger Lesart der knappen Werte 0,51/0,52 gaebe es keinen Arm, der schont UND die Erzeugung bessert. Deutung, nicht isoliert: Die Schleifen der Erzeugung gehen mit dem Niveau der ersten Wiederholung (TP1) mit, nicht mit der Verstaerkung. Z sagt die Erzeugung nicht vorher.
  Offen: Warum das Modell ueberhaupt in die erste Wiederholung einsteigt (TP1 als Hebel), ist ungemessen und nicht isoliert. Uebertragung auf prod512b ungemessen. Ein Sweep ueber lambda und Budget wurde nicht gemacht, nur lambda 1, 1 Epoche.
  Datei: rechner-b:~/snai_pruef/ditto2/ERGEBNIS_schonend.md
Abgeloest und ausgeblendet: 1 rezept - voll=True zeigt sie.
Chronik:
  2026-10-24 10:04 angelegt
  2026-10-24 10:07 Rezept r402
  2026-10-24 10:07 Status geplant -> laeuft (Rezept r402)
  2026-10-24 14:41 Messwerte m5023-m5136
  2026-10-24 14:41 Ergebnis e354: verfehlt
  2026-10-24 14:41 Status laeuft -> ausgewertet (Ergebnis e354)
  2026-10-24 15:35 Rezept r405, loest r402 ab
```
