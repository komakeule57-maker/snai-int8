# snai/kopier-mini-induktion

```text
snai/kopier-mini-induktion - ausgewertet, begonnen 2026-10-09, angelegt 2026-10-21, zuletzt 2026-10-21 11:20
!! ohne Kriterium
Frage: Positivkontrolle: Lernt ein Mini-Modell (Vokabular 64, Breite 64, 2 Schichten, voll-INT8, gebunden) mit dem echten Trainingspfad Induktion von null, und schlägt die Kopier-Sonde dann an?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Baut auf: snai/kopier-prod512-s19
Darauf baut: snai/kopier-mini-fest, snai/kopier-mini-var
Rezepte:
  r20 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben; Skript kopier_mini.php in ~/.cache/snai_pruef/verdrahtung/)
      parameter: Mini-Modell Vokabular 64, Breite 64, 2 Schichten, voll-INT8, gebunden; echter Trainingspfad; Aufgaben Induktion feste Periode 16 und variable Periode 12-40; LR/Zeitplan k. A.
      rechner: Laptop und rechner-b
      logs: Laptop:~/.cache/snai_pruef/verdrahtung/; rechner-b:~/snai_pruef/verdrahtung/
Messwerte (Groesse | Wert | Arm | Start | n):
  m180 acc Induktion feste Periode 16 nach 1.000 Schritten | 1,000 (fremd 0,000) | Periode 16
  m181 acc Induktion variable Periode 12-40 nach 30.000 Schritten | 1,000, Loss 0,09 (fremd 0,011 / 4,27) | Periode 12-40
  m182 Übergang variable Periode | zwischen Schritt 20.000 und 26.000 | Periode 12-40
  m183 acc variable Periode nach 40.000 Schritten | nicht gelernt | Periode 12-40 | 1
  m184 Bigramm (Vorgänger, Token) schon im Fenster, Korpus prod | 18,8-20,5 % der Positionen | Korpus
Ergebnis e18 [2026-10-21 11:20]: beobachtung
  Fazit: Der echte Trainings- und Inferenzpfad kann Induktion von null lernen, und die Kopier-Sonde schlägt dann an: die Verdrahtung (Block-Aufbau, Datenfluss, Sonde = Trainer) ist als Ursache des fehlenden Kopierens bei prod512 ausgeschlossen. Die variable Periode lernt nur eine von zwei Saaten im Budget, also nicht verlässlich. Verdacht laut Eintrag (nicht gemessen): zu wenig Training für den Phasenübergang, grobe FFN-Quantisierung, Merge zweier Arbeiter und Revival.
  Offen: Gradient der Verdrahtung nur am Genesis-Zustand geprüft, nicht an s19. LR und Zeitplan des Mini-Laufs stehen nicht im Eintrag.
Chronik:
  2026-10-21 11:19 angelegt (Nachtrag: Nachgetragen 2026-10-21; kein Kriterium vorab im Eintrag (Schwelle für „gelernt“ nicht genannt, nur Rot-Proben))
  2026-10-21 11:19 Rezept r20
  2026-10-21 11:19 Status geplant -> laeuft (Rezept r20)
  2026-10-21 11:19 Messwerte m180-m184
  2026-10-21 11:20 Ergebnis e18: beobachtung
  2026-10-21 11:20 Status laeuft -> ausgewertet (Ergebnis e18)
```
