# snai/drohne-arbeiter-raetsel

```text
snai/drohne-arbeiter-raetsel - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 19:28
Frage: Kommt der Rückstand der Mehr-Arbeiter-Arme (W2, W4, W6, W) allein davon, dass jeder Arbeiter nur 1/N der Schritte macht, oder kostet (oder nützt) die Mittelung zusätzlich?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus rechner-a ~/snai_pruef/drohne/arbeiter/kriterium.txt (mtime 2026-10-12 17:37) und der heutigen Ausgabe von auswert.py;.):
  Vorab (drohne/arbeiter/kriterium.txt, 2026-10-12 17:37, vor der Rechnung, keine neuen Läufe): Messgröße mittlerer Loss des ICL-Wächters (300 Fenster). Bezugskurve Ein-Arbeiter-Loss gegen Schritte aus E und P, linear in log(Schritte). DELTA = Loss(W) - Kurve(x), D = Loss(W) - Kurve(N*x). Je Arm: 'fehlende Schritte erklären es', wenn |DELTA| < 10 % von D UND |DELTA| < Rauschen; 'Mittelung kostet', wenn DELTA > +10 % von D und > Rauschen; 'Mittelung nützt' spiegelbildlich. Rauschen = größerer Wert aus Abstand E gegen P und Interpolationsfehler. Rot-Probe: Punkte weglassen und vorhersagen; x absichtlich N*x muss DELTA ~ D geben.
Plan: rechner-a:~/snai_pruef/drohne/arbeiter/kriterium.txt (Auswertung vorhandener Stände E, P, W2, W4, W6, W; keine neuen Läufe)
Baut auf: snai/drohne-arbeiter
Rezepte:
  r173 [2026-10-21] cd ~/snai_pruef/drohne/arbeiter && python3 auswert.py
      quelltext: auswert.py (rechner-a), Datengrundlage ~/.cache/snai_pruef/icl/uebersicht.txt
      parameter: Bezugskurve E/P t500 bis t10000 und Segmentenden; Rauschen 0,1182
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/drohne/arbeiter/
      notiz: Reine Auswertung, rechnet in Sekunden.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/drohne/arbeiter/auswert.py, Lauf vom 2026-10-21. Prüfung: Der frühere Befund nennt W2 Segment 0 'Feinstruktur unter dem Rauschkriterium'; nach Wortlaut ist es 'Mittelung kostet' (8 % über dem Rauschen).
  m2169 Rauschen (größerer Wert) | 0,1182 | Bezug |  | 1
  m2170 D Segmentende 0 | 0,684 | W2 |  | 1
  m2171 DELTA Segmentende 0 | +0,1275 | W2 |  | 1
  m2172 DELTA/D Segmentende 0 | 18,6 % | W2 |  | 1
  m2173 D Segmentenden | +1,128 und +0,999 | W4 |  | 2
  m2174 D Segmentenden | +1,384 und +1,306 | W6 |  | 2
  m2175 D Segmentenden | +1,703, +1,659 und +1,640 | W |  | 3
  m2176 DELTA/D (W4, W6, W) | 1,1 bis 8,0 % | W4, W6, W |  | 7
Ergebnis e164 [2026-10-21 19:28]: teilweise
  Fazit: Für 4, 6 und 10 Arbeiter erklären die fehlenden Schritte den Rückstand ganz; die Mittelung kostet dort nichts Messbares. Nur W2 am ersten Segmentende fällt nach dem Wortlaut unter 'Mittelung kostet' (DELTA +0,1275 über dem Rauschen 0,1182 und 18,6 % von D). Das ist ein einzelner Punkt knapp über der Schwelle, bei einem Lauf je Arbeiterzahl; als Befund für 'Mittelung schadet' reicht er nicht. Wer Arbeiter zuschaltet, muss mit 1/N der Schritte rechnen, nicht mit einem Zusatzverlust.
  Offen: Ob W2 Segment 0 bei einer zweiten Saat wieder über der Schwelle liegt; ob häufigeres Mitteln anders wirkt; Revival lief mit (laut Kriterium nicht entscheidbar).
  Datei: rechner-a:~/snai_pruef/drohne/arbeiter/kriterium.txt
Chronik:
  2026-10-21 19:27 angelegt (Nachtrag: Nachtrag 2026-10-21 aus rechner-a ~/snai_pruef/drohne/arbeiter/kriterium.txt (mtime 2026-10-12 17:37) und der heutigen Ausgabe von auswert.py;.)
  2026-10-21 19:27 Rezept r173
  2026-10-21 19:27 Status geplant -> laeuft (Rezept r173)
  2026-10-21 19:28 Messwerte m2169-m2176
  2026-10-21 19:28 Ergebnis e164: teilweise
  2026-10-21 19:28 Status laeuft -> ausgewertet (Ergebnis e164)
```
