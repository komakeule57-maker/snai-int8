# snai/kopier-mini-worker

```text
snai/kopier-mini-worker - ausgewertet, begonnen 2026-10-10, angelegt 2026-10-21, zuletzt 2026-10-21 11:21
Frage: Lernen zwei gemittelte Arbeiter die Kopieraufgabe `var` ohne Mehrbedarf an Fenstern gegenüber einem Arbeiter (Mini-Modell 128/2/4, ctx 64, echter INT8-Trainer)?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21 (Aufbau); Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  Gelernt = >= 90 % Rang 0 auf der zweiten Kopie (Aufgabe var) am zusammengeführten Modell; „2 Arbeiter schaden nicht“ = erreicht bei höchstens dem 1,5-Fachen der Fenster der Ein-Arbeiter-Kontrolle; „schaden“ = im Budget nicht erreicht, während die Kontrolle es schafft.
Baut auf: snai/kopier-mini-lr-reihe
Rezepte:
  r26 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben)
      parameter: Mini-Modell 128/2/4, ctx 64, gebunden, Aufgabe `var`, echter INT8-Trainer; alle Arme LR 0,0001, SNAI_WARMUP_STEPS=500, WD 0,1, ATTFIX-Lib, 1 Thread je Arbeiter, je 1 Saat. Arme: 1 Arbeiter 20.000er-Segmente; 2 Arbeiter 20.000er-Segmente (Merge nach 10.000 Schritten je Arbeiter); 2 Arbeiter 5.000er-Segmente (Merge nach 2.500), Budget 60.000 bzw. 80.000 Fenster
      rechner: rechner-b
Messwerte (Groesse | Wert | Arm | Start | n):
  (je Arm eine Saat, Saatnummer nicht im Eintrag)
  m221 R0 nach 20.000 / 40.000 Fenstern | 13,6 % / 96,3 % (Rot 0,4 %) | 1 Arbeiter, 20.000er-Segmente
  m222 R0 nach 20.000 / 40.000 / 60.000 / 80.000 Fenstern | 3,8 / 10,8 / 14,9 / 96,2 % (Rot 0,4 %) | 2 Arbeiter, 20.000er-Segmente
  m223 Faktor Fenster gegen Kontrolle | 2,0 (Auflösung 20.000: zwischen 1,5 und 4; gegen 5.000er-Referenz 2 bis 3,2) | 2 Arbeiter, 20.000er-Segmente
  m224 R0 nach 60.000 Fenstern (Budgetende) | 21,6 %, nicht gelernt (Referenz 95,8 % nach 30.000) | 2 Arbeiter, 5.000er-Segmente
  m225 Wanduhr bis Kriterium | ~4950 s gegen ~4920 s | 2 Arbeiter gegen 1 Arbeiter
Ergebnis e23 [2026-10-21 11:21]: verfehlt
  Fazit: Zwei Arbeiter brauchen 2- bis 3-mal so viele Fenster wie einer (Schwelle 1,5 gerissen, aber gelernt) und bringen keinen Zeitgewinn bei doppeltem Kernverbrauch; mit häufigem Zusammenführen (5.000er-Segmente) im Budget gar nicht gelernt = nach Kriterium „schaden“. Faustregel aus den Zahlen: Fortschritt richtet sich nach den Schritten JE Arbeiter, nicht nach der Summe. Folge für den Neustart: 1 Arbeiter.
  Offen: Ob häufiges Zusammenführen zusätzlich schadet (Budgets trennen das nicht); Übertragbarkeit auf prod512; Thread-Skalierung auf vserver nicht gemessen. Je eine Saat.
Abgeloest und ausgeblendet: 5 messwert - voll=True zeigt sie.
Chronik:
  2026-10-21 11:20 angelegt (Nachtrag: Nachgetragen 2026-10-21 (Aufbau); Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:20 Rezept r26
  2026-10-21 11:20 Status geplant -> laeuft (Rezept r26)
  2026-10-21 11:20 Messwerte m207-m211
  2026-10-21 11:21 Messwerte m221-m225, loesen m207-m211 ab
  2026-10-21 11:21 Ergebnis e23: verfehlt
  2026-10-21 11:21 Status laeuft -> ausgewertet (Ergebnis e23)
```
