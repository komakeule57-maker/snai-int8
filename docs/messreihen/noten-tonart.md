# snai/noten-tonart

```text
snai/noten-tonart - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:21
Frage: Macht der Noten-Generator (Knirps ntakt_e32_s1) mehr leiterfremde ("schiefe") Töne als sein Trainingsmaterial?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/noten/kriterien.txt, Abschnitt TONART-SONDE ("2026-10-14 ~20:15", "VOR dem Messen der Knirps-Melodien"; Datei zuletzt 20:09:23, U2-Ziehungen 20:09:07-10, tonart.jsonl bis 20:18:10).):
  Maß Lesart A (Urteilsgröße): je Melodie Anteil der Töne außerhalb der bestpassenden diatonischen Siebentonleiter, Mittel über Melodien mit 95-%-KI; Lesart B (mit harmonischem Moll) daneben; urteilen A und B verschieden: kein Urteil. U1: Generator (knirps_noten_ntakt_e32_s1_s31.txt) gegen sein Training (notentakt_c64_seg0, 1.980 Melodien): schiefer, wenn Generator-Mittel > 110 % des Trainingsmittels; unter 90 % = gerader; sonst Gleichstand; liegt die Schwelle im KI des Generators: knapp, kein Urteil. Störgröße Melodielänge: weicht sie um mehr als 20 % ab, Urteil unter Vorbehalt. Essen und Sammler nur zur Einordnung.
Plan: rechner-a:~/snai_pruef/knirps/noten/kriterien.txt
Baut auf: snai/noten-breite64
Darauf baut: snai/noten-tonart-breite
Rezepte:
  r154 [2026-10-21] python3 ~/snai_pruef/knirps/noten/tonart_sonde.py <dateien> (Ergebnisse in tonart.jsonl; U2-Melodien aus form_noten.php mit SCHREIBE)
      quelltext: noten/tonart_sonde.py e090b5edf2b2 (Selbsttest grün, Rot-Proben laut Kriterium)
      parameter: Lesart A = Anteil der Töne außerhalb der bestpassenden diatonischen Leiter (12 Transpositionen), Lesart B = zusätzlich harmonisches Moll; Mittel über Melodien mit 95-%-Bootstrap
      seed: U2: Ziehsaat 4711, Wiederholung 4712 (Ordner frisch/)
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/ow/noten/tonart/tonart.jsonl, *.txt, *.json, frisch/
      notiz: Prüfung beim Nachtrag: A/B-Werte für Generator, Training, Essen aus tonart.jsonl abgelesen. Nicht nachgerechnet: Längenband 25-40 Töne, Anteil ohne fremden Ton (52 % gegen 83 %), Position der Fremdtöne. Vorab-Charakter: Kriteriendatei zuletzt 20:09:23, also Sekunden nach den U2-Ziehungen; der Essen-Bezug ist laut Text vorher gemessen (Rot-Probe).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/ow/noten/tonart/tonart.jsonl (abgelesen; Längenband-Gegenprobe und Anteil ohne fremden Ton: nicht nachgerechnet)
  m1649 Fremdtonanteil Lesart A % (n = Melodien) | 3,35 | Generator ntakt_e32_s1 | 1 | 46151
  m1650 Fremdtonanteil Lesart B % (n = Melodien) | 3,26 | Generator ntakt_e32_s1 | 1 | 46151
  m1651 Fremdtonanteil Lesart A % (n = Melodien) | 1,19 | Training notentakt seg0 |  | 1980
  m1652 Fremdtonanteil Lesart B % (n = Melodien) | 0,80 | Training notentakt seg0 |  | 1980
  m1653 Verhältnis Generator/Training A | 282 % | U1 | 1
  m1654 Verhältnis Generator/Training B | 408 % | U1 | 1
  m1655 Bezug Essen A / B % | 0,53 / 0,40 | Essen |  | 1570
  m1656 Bezug Training notentakt2 A % | 1,35 | Training notentakt2 |  | 2187
Ergebnis e143 [2026-10-21 19:21]: erfuellt
  Fazit: Der Höreindruck hat eine messbare Entsprechung: der Generator setzt fast dreimal so viele leiterfremde Töne wie sein Training (3,35 gegen 1,19 %), in beiden Lesarten und längenneutral, und ist damit etwa so schief wie die LLM-Sammlermelodien. Ob die gehörten schiefen Töne genau diese sind, ist nicht gemessen. Fremde Töne treten schon in den ersten 10 Noten auf, die Kontextgrenze ist also nicht die Hauptursache (Beobachtung).
  Offen: Ursache der Fremdtöne; lokale Ausweichungen gegen Modulation nicht getrennt.
  Datei: rechner-a:~/snai_pruef/knirps/noten/kriterien.txt
Chronik:
  2026-10-21 19:21 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/noten/kriterien.txt, Abschnitt TONART-SONDE ("2026-10-14 ~20:15", "VOR dem Messen der Knirps-Melodien"; Datei zuletzt 20:09:23, U2-Ziehungen 20:09:07-10, tonart.jsonl bis 20:18:10).)
  2026-10-21 19:21 Rezept r154
  2026-10-21 19:21 Status geplant -> laeuft (Rezept r154)
  2026-10-21 19:21 Messwerte m1649-m1656
  2026-10-21 19:21 Ergebnis e143: erfuellt
  2026-10-21 19:21 Status laeuft -> ausgewertet (Ergebnis e143)
```
