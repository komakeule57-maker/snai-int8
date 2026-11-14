# snai/kopier-knirps-kb4-lang

```text
snai/kopier-knirps-kb4-lang - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 11:25
Frage: Lernt der Knirps 32/8/4 (Kopfbreite 4) das Kopieren (`var`) mit zehnfachem Budget (bis 1.200.000 Fenster, LR 0,0001)?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt (Zweitmeinung Gemini/Mistral vorab); Wortlaut im Messbuch aus dem Eintrag erschlossen):
  Kriterium (r), wörtlich aus der Plan-Datei: Messung nach jedem Segment (200 Fenster), Abbruch bei floor(Rang 0 zweite Kopie) >= 90 mit Rot-Probe. „LERNBAR, nur langsam“ = mindestens 2 von 3 Saaten erreichen 90 %. „NICHT IM BUDGET“ = alle drei enden unter 50 % UND Mittel der letzten 20 Messungen liegt weniger als 10 % (relativ) über dem Mittel der Segmente 100..119 (keine harte Grenze). Alles andere = UNENTSCHIEDEN; berichtet werden Endwerte und Steigung je 100.000 Fenster. Uneinige Saaten = saatabhängig. Die Schwelle 10 % ist frei gewählt.
Plan: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt (Abschnitt (r))
Baut auf: snai/kopier-knirps-gitter
Darauf baut: snai/knirps-kb4-muster
Rezepte:
  r41 [2026-10-21] k. A. (Skript ~/snai_pruef/knirps/verlaengerung.sh, Aufruf nicht überliefert)
      parameter: Knirps 32/8/4, wort256, `var`, 2 Schichten, ctx 64; die drei Zweiphasen-Läufe n_d32h8_s{1,2,3}_zp (60.000 Fenster LR 0,001, dann 60.000 mit 0,0001) unverändert mit LR 0,0001 bis 1.200.000 Fenster fortgesetzt (Segmente 24..239, 5.000 frische Fenster je Segment), Warmup 500, Revival aus, Messung je 5.000 Fenster (200 Fenster)
      seed: Genesis 1, 2, 3; Korpus-Saat 1000+Segment
      rechner: rechner-a
      notiz: Fallstrick laut Eintrag: Warmup zählt über adam_t im Modellstand und beginnt NICHT je Segment neu.
Messwerte (Groesse | Wert | Arm | Start | n):
  m340 R0 bei 120.000 Fenstern (Start) | 12,0 % | 32/8/4 | 1
  m341 R0 bei 120.000 Fenstern (Start) | 11,0 % | 32/8/4 | 2
  m342 R0 bei 120.000 Fenstern (Start) | 18,8 % | 32/8/4 | 3
  m343 R0 Ende (1.200.000 Fenster) | 50,2 % | 32/8/4 | 1
  m344 R0 Ende (1.200.000 Fenster) | 45,3 % | 32/8/4 | 2
  m345 R0 Ende (1.200.000 Fenster) | 35,6 % | 32/8/4 | 3
  m346 Mittel letzte 20 Messungen über Mittel bei 500.000-600.000 | +36 bis +77 % | 32/8/4 |  | 3
  m347 Steigung | 1,6-3,5 Punkte je 100.000 Fenster, kein Sprung | 32/8/4 |  | 3
Ergebnis e36 [2026-10-21 11:25]: keine_aussage
  Fazit: UNENTSCHIEDEN nach Kriterium (r): keine Saat erreicht 90 %, keine ist flach. Kopfbreite 4 lernt das Kopieren allmählich (1,6-3,5 Punkte je 100.000 Fenster), nicht in einem Phasenübergang wie Kopfbreite >= 8, und braucht mehr als das Hundertfache der Fenster. Für die Praxis heißt das: Kopfbreite 4 ist im vertretbaren Budget kein Kopiermodell.
  Offen: Anderes Rezept (von Anfang an 0,0001, Cosinus, anderes WD); Kopfbreite 4 gegen 8 Köpfe (im Kern gekoppelt). Vorbehalt Lade-Wächter: n_d32h8 gehört zu den betroffenen Trainingslogs; nicht neu gemessen.
Chronik:
  2026-10-21 11:23 angelegt (Nachtrag: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt (Zweitmeinung Gemini/Mistral vorab); Wortlaut im Messbuch aus dem Eintrag erschlossen)
  2026-10-21 11:24 Kriterium geaendert, vorher: Kriterium (r) in kopfbreite_kriterien.txt: gelernt = Rang 0 zweite Kopie >= 90 %; flach = Mittel der letzten 20 Messungen nicht über dem Mittel bei 500.000-600.000; sonst UNENTSCHIEDEN (genauer Wortlaut nur in der Plan-Datei).
  2026-10-21 11:24 Kriterium vor dem ersten Messwert durch den Wortlaut aus kopfbreite_kriterien.txt (r) ersetzt; die erste Fassung war nur erschlossen.
  2026-10-21 11:25 Rezept r41
  2026-10-21 11:25 Status geplant -> laeuft (Rezept r41)
  2026-10-21 11:25 Messwerte m340-m347
  2026-10-21 11:25 Ergebnis e36: keine_aussage
  2026-10-21 11:25 Status laeuft -> ausgewertet (Ergebnis e36)
```
