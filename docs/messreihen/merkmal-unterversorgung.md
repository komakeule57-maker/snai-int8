# snai/merkmal-unterversorgung

```text
snai/merkmal-unterversorgung - ausgewertet, begonnen 2026-10-17, angelegt 2026-10-21, zuletzt 2026-10-21 19:17
Frage: Sterben die anfaelligen Embedding-Zeilen, weil sie historisch zu wenig Gradient bekommen ('Unterversorgung', These von Auditor B), gemessen an sqrt(v) im Checkpoint?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/zeilenintern/kriterien_gegenhalt.txt, Abschnitt 'NACHTRAG VOR DER RECHNUNG (11:03:17)'):
  sqrt(v) auf den Rest-Spalten, Median je Zeile, am Stand s4 (Saat 1 und 3): 'Unterversorgung GESTUETZT', wenn AUC(lebend > tot) >= 0,85 in Saat 1 UND 3; 'NICHT GESTUETZT' bei <= 0,65 in beiden; sonst kein Urteil. Vorbehalt vorab: Adam normiert die Schrittgroesse auf sqrt(v), kleiner Gradient heisst bei Adam keinen kleineren Schritt.
Baut auf: snai/merkmal-gegenhalt
Darauf baut: snai/merkmal-ratsche, snai/merkmal-sr
Rezepte:
  r131 [2026-10-21] python3 ~/snai_pruef/merkmal/zeilenintern/gegenhalt.py (v-Teil)
      quelltext: gegenhalt.py fcd9ef44
      parameter: Original s1_s4, s3_s4; GRENZE t20k, t60k
      seed: -
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/zeilenintern/v_ergebnis.txt, gegenhalt_ergebnis.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/zeilenintern/gegenhalt_ergebnis.txt (abgelesen 2026-10-21)
  m1419 AUC(lebend > tot) sqrt(v_rest) | 0,046 | orig s4 | 1 | 1
  m1420 AUC(lebend > tot) sqrt(v_rest) | 0,022 | orig s4 | 3 | 1
  m1421 AUC sqrt(v_rest) | 0,050 / 0,057 | GRENZE t20k / t60k | 1 | 2
  m1422 Median sqrt(v_rest) tot / lebend | 0,094 / 0,024 | orig s4 | 1 | 1
  m1423 Median sqrt(v_rest) tot / lebend | 0,075 / 0,0065 | orig s4 | 3 | 1
  m1424 abs(m)/sqrt(v) Rest tot / lebend | 0,005 / 0,032 | orig s4 | 1 | 1
Ergebnis e125 [2026-10-21 19:17]: verfehlt
  Fazit: Widerlegt, und zwar in Gegenrichtung: die spaeter toten Zeilen haben auf dem Rest 4- bis 12-mal MEHR Gradientenenergie (AUC 0,02-0,06, beide Saaten, schon bei s4), aber kaum gleichgerichtet. Sie werden nicht ausgehungert, sondern mit Rauschen ueberschuettet. Das passte zu ZERL (vergroeberte Gradienten/Momente noetig) und fuehrte zur Suche in der Momenten-Rundung (snai/merkmal-ratsche, snai/merkmal-sr).
  Datei: rechner-a:~/snai_pruef/merkmal/zeilenintern/kriterien_gegenhalt.txt
Chronik:
  2026-10-21 19:17 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/zeilenintern/kriterien_gegenhalt.txt, Abschnitt 'NACHTRAG VOR DER RECHNUNG (11:03:17)')
  2026-10-21 19:17 Rezept r131
  2026-10-21 19:17 Status geplant -> laeuft (Rezept r131)
  2026-10-21 19:17 Messwerte m1419-m1424
  2026-10-21 19:17 Ergebnis e125: verfehlt
  2026-10-21 19:17 Status laeuft -> ausgewertet (Ergebnis e125)
```
