# snai/sr-hash-bias

```text
snai/sr-hash-bias - ausgewertet, angelegt 2026-11-15, zuletzt 2026-11-15 12:51
Frage: Rundet das stochastische Runden der int8-Gewichte (SNAI_I8_REST=sr, Hash restSrU) im Mittel ohne Verzerrung, oder bringt der Hash ein Muster und damit eine schleichende Verschiebung? Anlass: Prüfhinweis aus der Durchsicht des Repos (2026-11-15).
Kriterium (festgelegt 2026-11-15 12:41, vor dem ersten Messwert):
  Volltext rechner-a:~/snai_pruef/knirps_sr/srbias/KRITERIEN.txt (cc78ab61), vor dem ersten Lauf. Gerät: restSrU wörtlich aus cortex.nim (a1b1c43) geschnitten, Rundungszeile und Salz als Text geprüft (assert). T1: 1e8 Zufallsziele, Fehler e = q − target·inv, Zellen gesamt, Bruchanteil (10), Zeile mod 2, Spalte mod 8, adam_t mod 4. T2: 10.000 Ketten mit fester Änderung d je Schritt (±0,001/±0,003/±0,01 über 10.000 Schritte, ±0,25 über 200), Drift je Schritt b. Je Zelle unverzerrt = |b| < 4 SE und |b| < 1e-3 Stufen (T1) bzw. < 1 % von |d| (T2). Alle unverzerrt -> erfüllt; nur 4-SE-Grenze verletzt -> teilweise; praktische Grenze verletzt -> verfehlt. Rot vorab: u·0,999 muss durchfallen.
Plan: rechner-a:~/snai_pruef/knirps_sr/srbias/KRITERIEN.txt
Baut auf: snai/sr-knirps-nachweis
Rezepte:
  r718 [2026-11-15] cd ~/snai_pruef/knirps_sr/srbias && python3 -I bau_test.py ~/Projekte/snai_edge_int8_lora/cortex.nim test_<v>.nim [u999|salt0] && nim c -d:danger test_<v>.nim && ./test_<v> > aus_<v>.txt
      quelltext: bau_test.py 344c3b04, Rumpf test_srbias.nim.rumpf 5c9fd619, erzeugt test_gruen.nim b4c0614f; Hash aus cortex.nim des Hauptbaums a1b1c43
      parameter: T1 N = 1e8, Skala 10^U(-4,-1), inv = 127/Skala, Zeile/Spalte U(0..4095), adam_t U(1..1e6); T2 100×100 Ketten, Skala 0,01, w0 = 0
      seed: randomize(20261115) für die Testziele; der SR-Zufall selbst hat keine Saat (Hash aus Wert, Zeile, Spalte, adam_t)
      rechner: rechner-a, je Variante ~22 s, ein Faden
      logs: rechner-a:~/snai_pruef/knirps_sr/srbias/aus_gruen.txt (61820cd9), aus_u999.txt (44eab96a), aus_salt0.txt (658d5854)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/knirps_sr/srbias/aus_gruen.txt, aus_u999.txt, aus_salt0.txt (2026-11-15)
  m11246 T1 gesamt | b = +3,3e-5 Stufen, SE 4,1e-5, z 0,82 | sr | - | 100000000
  m11247 T1 Zellen (10 Bruchklassen, Zeile mod 2, Spalte mod 8, adam_t mod 4) | alle 24 unverzerrt; größter Betrag z 2,68 (Bruch 6/10, b = 4,0e-4 unter 1e-3), sonst höchstens 1,45 | sr | - | 24
  m11248 T2 Drift je Schritt, d = +0,001 / −0,001 | b = +1,3e-6 / +5,5e-6 (Grenze 1e-5; z 0,41 / 1,70) | sr | - | 10000
  m11249 T2 d = +0,003 / −0,003 | b = −3,4e-6 / −1,0e-5 (Grenze 3e-5; z −0,62 / −1,88) | sr | - | 10000
  m11250 T2 d = +0,01 / −0,01 | b = −4,0e-6 / +5,4e-6 (Grenze 1e-4; z −0,40 / 0,54) | sr | - | 10000
  m11251 T2 d = +0,25 / −0,25 (T 200) | b = +2,6e-5 / −9,5e-5 (Grenze 2,5e-3; z 0,08 / −0,31) | sr | - | 10000
  m11252 ROT u·0,999 | T1 b = −4,7e-4, z −11,5 fällt an der 4-SE-Grenze; T2 d = +0,001/+0,003/+0,01 praktisch verzerrt (b ≈ −1e-3); d < 0 nicht erkannt (Vorhersage traf nur für +d zu: die Kürzung von u wirkt nur bei Bruchanteil nahe 0) | u999 | - | 10000
  m11253 nur berichtet: srSalt = 0 | T1 unverzerrt, aber T2 in allen 8 Zellen völlig verzerrt (b ≈ −d): ohne Schrittzähler im Salz bekommt ein Gewicht mit gleichbleibendem Ziel jeden Schritt dasselbe u und bewegt sich nie; das Salz aus adam_t ist tragend | salt0 | - | 10000
  Quelle: rechner-a:~/snai_pruef/knirps_sr/srbias/aus_uplus.txt (4bd95e2e), bau_test.py 401c4e13 (Variante uplus ergänzt). NACHTRÄGLICH nach dem Urteil, auf den Hinweis zur Minus-Richtung; ändert das Kriterium nicht.
  m11254 ROT nachträglich: u + 0,001 (verschoben statt gekürzt) | T1 b = +1,03e-3, z 25,2, praktisch verzerrt; T2 d = ±0,001, ±0,003, ±0,01 in BEIDEN Richtungen praktisch verzerrt (b ≈ +1e-3, z 95 bis 228); nur d = ±0,25 über 200 Schritte zu kurz (z 3,3) | uplus | - | 10000
Ergebnis e672 [2026-11-15 12:50]: erfuellt
  Fazit: Nach Wortlaut erfüllt: Keine Zelle zeigt eine Verzerrung. Über 1e8 Zufallsziele liegt der mittlere Rundungsfehler bei 3e-5 Stufen (z 0,8). Nach Bruchanteil, Zeile, Spalte und Schrittzähler zeigt keine der 24 Zellen ein Muster. Bei einer winzigen, gleichbleibenden Änderung (±0,001 bis ±0,25 Stufen je Schritt) liegt die Drift höchstens bei 0,5 % der Änderung und ist statistisch null. Reichweite der Aussage, genau genommen: Die Rot-Probe (u um 0,1 % gekürzt) fällt nur für Änderungen in Plus-Richtung durch, dort deutlich (T1 z −11,5, T2 b ≈ −1e-3). Für die Minus-Richtung erkennt das Gerät eine Verzerrung dieser Art und Größe nicht. Dort ist eine Verzerrung von 0,1 % also nicht ausgeschlossen, sondern mit diesem Aufbau nicht prüfbar. Ausgeräumt ist der Verdacht damit für die Plus-Richtung und für Verzerrungen, die sich im Gesamtmittel von T1 zeigen (Grenze dort 4 SE = 1,6e-4 Stufen); für die Minus-Richtung bräuchte es eine Rot-Probe, die dort wirkt, etwa u um 0,001 verschoben statt gekürzt. Nebenbefund: Das Salz aus dem Adam-Schrittzähler ist tragend. Ohne es bewegt sich ein Gewicht mit gleichbleibendem Ziel nie. Nicht geprüft: CUDA-Kern, wechselnde Zeilenskala, Klemmung am Rand. (Löst e671 ab: Wortlaut zur Minus-Richtung präzisiert.)
Abgeloest und ausgeblendet: 1 ergebnis - voll=True zeigt sie.
Chronik:
  2026-11-15 12:41 angelegt
  2026-11-15 12:41 Rezept r718
  2026-11-15 12:41 Status geplant -> laeuft (Rezept r718)
  2026-11-15 12:42 Ergebnis e671: erfuellt
  2026-11-15 12:42 Status laeuft -> ausgewertet (Ergebnis e671)
  2026-11-15 12:42 Messwerte m11246-m11253
  2026-11-15 12:50 Ergebnis e672: erfuellt, loest e671 ab
  2026-11-15 12:51 Messwerte m11254
```
