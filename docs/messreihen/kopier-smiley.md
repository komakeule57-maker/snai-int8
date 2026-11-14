# snai/kopier-smiley

```text
snai/kopier-smiley - ausgewertet, begonnen 2026-10-13, angelegt 2026-10-21, zuletzt 2026-10-21 11:27
Frage: Ab welcher Breite lernt ein Knirps die Smiley-Fähigkeiten (Schlussauge = Auge wiederholen über Abstand 2-4, Klammer, Sprung), und ist die Grenze bei Breite 8 eine Fähigkeits- oder eine Budgetgrenze?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  Leiter: drei Fähigkeiten an 300 frischen Fenstern gegen Boden (exakte Grammatik-Wahrscheinlichkeit) und Bigramm-Modell; Schlussauge = richtiges Auge bestes unter den 8 (Bigramm 12 %), Klammer = Rang 0 von „)“ bzw. Leerzeichen beide >= 90 %, Sprung = geschlossener Anteil der Loss-Lücke Bigramm->Boden; gelernt >= 90 %. Probe „weniger Augen“: gestützt = 8/1 lernt bei N=2 in 3 von 3; widerlegt = 3 von 3 nicht in beiden Raten; sonst saatabhängig. Verlängerung 8/1 bis 360.000 Fenster: gesprungen = Schlussauge >= 90 %, geblieben = <= 22 %.
Plan: rechner-a:~/snai_pruef/knirps/smiley/kriterien.txt
Baut auf: snai/kopier-knirps-leiter
Rezepte:
  r43 [2026-10-21] k. A. (Aufrufe nicht wörtlich im Eintrag; Skripte lauf_smiley.sh, mess_smiley.php, reihe_smiley.sh, probe_augen.sh; Schalter SM_AUGEN_N bzw. AUG=<n>, Fortsetzung per START=24)
      parameter: Smiley-Strom (gram.php = einzige Quelle für Vokabular/Korpus/Messung; Vokabular vokabular/smiley.json, 34 Einträge zeichenweise); gepaart [(] A M{1..3} A [)] (8 Augen, 4 Münder). Zellen Breite/Köpfe 2/1, 4/1, 8/1, 16/1, 32/2, 64/4, 2 Schichten, ctx 64, je 3 Saaten (Genesis + Laufname), LR 0,001 und für nicht vollständige Zellen 0,0001, je 24 x 5000 Fenster, Revival aus. Probe: 2 bzw. 4 Augen, Zellen 8/1 und 4/1. Verlängerung: sm_d8h1_s{1,2,3} bis 360.000 Fenster
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/smiley; Werkzeuge ~/snai_pruef/knirps/smiley
Messwerte (Groesse | Wert | Arm | Start | n):
  m354 Schlussauge Endstand | 11..15 % (= Bigramm) in allen 18 Läufen | 2/1, 4/1, 8/1, beide Raten |  | 18
  m355 Schlussauge Endstand | >= 99,9 % in allen Läufen | 16/1, 32/2, 64/4
  m356 Klammer | ab Breite 4 in allen Läufen beider Raten >= 96 %; Breite 2 nicht | Leiter
  m357 Sprung, LR 0,001 / 0,0001 | 84/93/85 % / 91,5/90,9/91,0 % (knapp, nicht als gelernt gewertet) | 8/1 |  | 3
  m358 Schlussauge 2 Augen, LR 0,001 / 0,0001 | 1 von 3 (100 % nach 70.000) / 0 von 3 | 8/1 |  | 3
  m359 Schlussauge 4 Augen, LR 0,001 / 0,0001 | 2 von 3 (100 % nach 55.000 bzw. 70.000) / 0 von 3 | 8/1 |  | 3
  m360 Schlussauge 2 Augen | 0 von 6 | 4/1 |  | 6
  m361 Verlängerung Schlussauge 8 Augen bis 360.000 | springt nach 250.000 (13 -> 49 -> 100 %) | 8/1 LR 0,001 | 1
  m362 Verlängerung Schlussauge 8 Augen bis 360.000 | springt nach 270.000 (16 -> 63 -> 99,8 %) | 8/1 LR 0,001 | 2
  m363 Verlängerung Schlussauge 8 Augen bis 360.000 | bleibt 11-14 % | 8/1 LR 0,001 | 3
  m364 Rot-Proben | Schlussauge 0,0 %, Klammer <= 0,2 %, Sprung <= -237 % | alle Stopps
Ergebnis e40 [2026-10-21 11:27]: teilweise
  Fazit: Leiter: Klammer ab Breite 4, Schlussauge und Sprung ab Breite 16 gelernt; Breite 8 bleibt beim Schlussauge in 120.000 Fenstern auf dem Bigramm-Wert. Probe „weniger Augen“: saatabhängig, die Deutung „Zahl der Augenzeichen“ ist weder gestützt noch widerlegt. Verlängerung: 2 von 3 Saaten springen nach 250.000-270.000 Fenstern = saatabhängig. Daraus folgt: die frühere „scharfe Schwelle zwischen Breite 8 und 16“ war eine Budgetgrenze, keine Fähigkeitsgrenze; Breite 8 mit einem Kopf KANN das Schlussauge, aber alles-oder-nichts und sehr spät (vorher über 240.000 Fenster völlig flach). „Nicht“ heißt hier nur „nicht im Budget“. Abweichend vom Kopiertest lernt Breite 64 hier mit LR 0,001.
  Offen: Aufbauschwäche: die Sprung-Schwelle 90 % liegt dicht an der Decke (bester Wert 94,8 %), gestoppte Läufe nur als „>= 90“ zu lesen; Breite 8 bei LR 0,0001 Sprung 90,9-91,5 % knapp, ohne Wiederholung auf frischen Fenstern nicht als gelernt zu werten. LR 0,0001 lernte das Schlussauge bei Breite 8 in keinem der 9 Läufe. Breite 8 mit 2 Köpfen ungeprüft.
Chronik:
  2026-10-21 11:26 angelegt (Nachtrag: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:26 Rezept r43
  2026-10-21 11:26 Status geplant -> laeuft (Rezept r43)
  2026-10-21 11:26 Messwerte m354-m364
  2026-10-21 11:27 Ergebnis e40: teilweise
  2026-10-21 11:27 Status laeuft -> ausgewertet (Ergebnis e40)
```
