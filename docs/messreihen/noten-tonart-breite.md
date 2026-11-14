# snai/noten-tonart-breite

```text
snai/noten-tonart-breite - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:22
Frage: Setzt der breitere Noten-Knirps d64 (64/4/16) weniger leiterfremde Töne als d32 (32/2/16), gemessen an seinen formkorrekten Melodien?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/noten/kriterien.txt, Abschnitt TONART-SONDE ("2026-10-14 ~20:15", "VOR dem Messen der Knirps-Melodien"; Datei zuletzt 20:09:23, U2-Ziehungen 20:09:07-10, tonart.jsonl bis 20:18:10). Wiederholung auf frischer Ziehsaat 4712 nach der Regel "knapp erfüllt ist nicht erfüllt" (Projektregel), nicht in der Kriteriendatei.):
  U2 aus der Tonart-Sonde: Melodien aus genau den 500 Ziehungen der Formsonde (T=1,0, Saat 4711, nur zur angesagten Taktart formkorrekte); Kontrolle: Zahl = ok_angesagt in form.jsonl. d64 gerader, wenn JEDE d64-Saat unter 90 % des d32-Mittels liegt; alle über 110 % = schiefer; sonst Gleichstand/saatabhängig; Lesart A Urteilsgröße, B daneben, uneinig = kein Urteil. Je Saat nur ~100-250 Melodien, KI mitberichten.
Plan: rechner-a:~/snai_pruef/knirps/noten/kriterien.txt
Baut auf: snai/noten-tonart, snai/noten-breite64
Rezepte:
  r156 [2026-10-21] python3 ~/snai_pruef/knirps/noten/tonart_sonde.py <dateien> (Ergebnisse in tonart.jsonl; U2-Melodien aus form_noten.php mit SCHREIBE)
      quelltext: noten/tonart_sonde.py e090b5edf2b2 (Selbsttest grün, Rot-Proben laut Kriterium)
      parameter: Lesart A = Anteil der Töne außerhalb der bestpassenden diatonischen Leiter (12 Transpositionen), Lesart B = zusätzlich harmonisches Moll; Mittel über Melodien mit 95-%-Bootstrap
      seed: U2: Ziehsaat 4711, Wiederholung 4712 (Ordner frisch/)
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/ow/noten/tonart/tonart.jsonl, *.txt, *.json, frisch/
      notiz: Prüfung beim Nachtrag: Alle Prozentwerte aus tonart.jsonl nachgerechnet. Zwei Lesarten nebeneinander: nach dem Wortlaut der Datei (eine Ziehsaat) "gerader"; mit der Projektregel zur Knappheit und der Wiederholung: kein Urteil. Das Messbuch-Urteil folgt der Wiederholung, wie damals berichtet.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/ow/noten/tonart/tonart.jsonl, *.json, frisch/ (abgelesen und Verhältnisse nachgerechnet)
  m1701 Fremdtonanteil A % (99 / 111 / 97 Melodien) | 3,06 / 3,82 / 3,36 | d32 | 1/2/3
  m1702 Fremdtonanteil A % (192 / 188 / 252 Melodien) | 2,26 / 2,97 / 2,85 | d64 | 1/2/3
  m1703 d64 in % des d32-Mittels, A | 66 / 87 / 83 | d64 Ziehsaat 4711 | 1/2/3
  m1704 d64 in % des d32-Mittels, B | 64 / 86 / 82 | d64 Ziehsaat 4711 | 1/2/3
  m1705 Fremdtonanteil A % (98 / 117 / 94) | 4,03 / 3,84 / 4,15 | d32 Ziehsaat 4712 | 1/2/3
  m1706 Fremdtonanteil A % (164 / 186 / 218) | 2,31 / 3,68 / 3,19 | d64 Ziehsaat 4712 | 1/2/3
  m1707 d64 in % des d32-Mittels, A | 58 / 92 / 80 | d64 Ziehsaat 4712 | 1/2/3
  m1708 d64 in % des d32-Mittels, B | 56 / 88 / 80 | d64 Ziehsaat 4712 | 1/2/3
  m1709 Kontrolle Melodienzahl = ok_angesagt form.jsonl | erfüllt (99/111/97, 192/188/252) | U2 4711 | 1-3
Ergebnis e146 [2026-10-21 19:22]: keine_aussage
  Fazit: Auf Ziehsaat 4711 wäre d64 nach Wortlaut gerader (A und B, alle Saaten unter 90 %), aber Saat 2 lag mit 87 % knapp an der Schwelle. Die Wiederholung auf frischer Ziehsaat trennt die Lesarten (A: 92 % in Saat 2 = saatabhängig, B: gerader), damit gilt kein Urteil. Tendenz: alle zwölf d64-Werte liegen unter dem d32-Mittel, d64_s1 ist stabil am geradesten. Für den Generator ist die Breite also höchstens ein schwacher Hebel gegen schiefe Töne; die Formquote war das stärkere Argument für d64.
  Offen: Mehr Ziehungen je Saat (je ~100-250 Melodien) würden das KI verengen.
  Datei: rechner-a:~/snai_pruef/knirps/noten/kriterien.txt
Chronik:
  2026-10-21 19:22 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/noten/kriterien.txt, Abschnitt TONART-SONDE ("2026-10-14 ~20:15", "VOR dem Messen der Knirps-Melodien"; Datei zuletzt 20:09:23, U2-Ziehungen 20:09:07-10, tonart.jsonl bis 20:18:10). Wiederholung auf frischer Ziehsaat 4712 nach der Regel "knapp erfüllt ist nicht erfüllt" (Projektregel), nicht in der Kriteriendatei.)
  2026-10-21 19:22 Rezept r156
  2026-10-21 19:22 Status geplant -> laeuft (Rezept r156)
  2026-10-21 19:22 Messwerte m1701-m1709
  2026-10-21 19:22 Ergebnis e146: keine_aussage
  2026-10-21 19:22 Status laeuft -> ausgewertet (Ergebnis e146)
```
