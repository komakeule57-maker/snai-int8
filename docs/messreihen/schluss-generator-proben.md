# snai/schluss-generator-proben

```text
snai/schluss-generator-proben - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:28
Frage: Schlussfolgern bei kleinen SnAI-Modellen, Vorstufe ohne Modell: Taugt der Aufgabengenerator (4 Familien F1 Reihenfolge, F2 Zustand/Behaelter, F3 Regeln mit Kunstwoertern, F4 Rechnen; Testmengen T-ID, T-Name, T-Lang) samt Loeser, Abkuerzungsspielern und Kriterium fuer einen Trainingslauf? Proben P1-P9 mit Gegenproben.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/schluss/kriterien_proben.txt (laut Text vor dem ersten Lauf, 2026-10-15; Nachtraege jeweils vor dem naechsten Lauf).):
  P1 Orakel 100 % je Familie x Menge (Rot: verfaelschte Antwort < 100 %). P2 Ausgewogenheit: jeder Abkuerzungsspieler und der Oberflaechen-Spieler hoechstens Zufall + 10 Punkte je Familie x Testmenge (Rot: --unausgewogen muss reissen). P3 Lecks 0 (Testprompts, T-Name-Namen, zurueckgehaltene Rechenschritte). P4 Loeser stimmt bei 100 % mit Gold. P5 Verteilung (k, Ja-Anteil 50 +- 3 %, F3 33 +- 3 %). P6 0 unbekannte Woerter. P7 Determinismus. P8 Verwuerfeln aendert Gold in > 0 %. P9 Kriterium: +25 Punkte besteht, +3 faellt durch. 'Alles muss gruen sein, bevor der Generator fuer einen Trainingslauf benutzt wird.' Proben im Wortlaut unveraendert ueber alle Laeufe (nur P5 nach Lauf 1 angepasst, P3/P4/P5 vor Lauf 8 erweitert).
Plan: rechner-a:~/snai_pruef/schluss/PLAN.md
Darauf baut: snai/natur-leanstral-probe, snai/schluss-kv-reset
Rezepte:
  r57 [2026-10-21] cd ~/snai_pruef/schluss && python3 proben.py arbeit/w<N>  (Daten: python3 erzeuge.py arbeit/w<N>/s1a --saat 1 [--natur <datei> --natur-anteil 0.3])
      quelltext: Generatorstand je Lauf in laeufe/erzeuge_lauf<N>.py; heute erzeuge.py 226cd64e, proben.py 0418aa15, spieler.py 91ac9f7b, bewerte.py 51107950, loeser.py 54662e9f (md5)
      parameter: 80.000 Trainingsaufgaben je Saat (20.000 je Familie), Testmengen je 500, Oberflaechen-Spieler lernt auf 6.000 je Familie; Vokabular 147 (mit Natur-Text 768)
      seed: 1
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/schluss/laeufe/lauf1.txt bis lauf8.txt, lauf7_natur.txt; Daten arbeit/w6, w7, w8
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/schluss/ERGEBNIS.md und kriterien_proben.txt (Nachtraege), nicht gegen laeufe/*.txt nachgerechnet
  m545 Pruefungen gruen Lauf 6 | 27 (davon 13 Gegenproben) | Lauf 6 | 1
  m546 P4 Abweichungen Loeser/Gold | 0 | Lauf 6 | 1 | 14000
  m547 P8 Gold geaendert | F1 50 / F2 87 / F3 18 / F4 92 % | Lauf 6 | 1
  m548 P9 Kriterium | +25 besteht 12/12, +3 faellt 12/12 | Lauf 6 | 1 | 24
  m549 P2 beste Abkuerzung F1 | <= 53,4 % (Zufall 50) | Lauf 6 | 1 | 500
  m550 P2 beste Abkuerzung F3 | <= 36,6 % (Zufall 33,3) | Lauf 6 | 1 | 500
  m551 P2 beste Abkuerzung F4 | <= 6,2 % (Zufall 2,4) | Lauf 6 | 1 | 500
  m552 P2 beste Abkuerzung F2 (rot) | 22,6-26,8 % gegen Grenze 14,5-17,8 % | Lauf 6 | 1 | 500
  m553 P2 F2 Oberflaechen-Spieler Lauf 1 | 84-90 % | Lauf 1 | 1 | 500
  m554 Lauf 8 Zusatzaufgaben B | 26296 | Lauf 8 | 1
  m555 Lauf 8 Token A / B | 6.997.832 / 6.997.857 | Lauf 8 | 1
  m556 Lauf 8 Pruefungen gruen | 32 (P2 F2 rot) | Lauf 8 | 1
Ergebnis e52 [2026-10-21 14:28]: teilweise
  Fazit: Generator, Loeser und Kriterium sind belastbar: alle Proben samt 13 Gegenproben gruen, ausser P2 bei F2. Dort sank die beste Abkuerzung in fuenf Generatorrunden von 84-90 % auf 23-27 %, jede Runde beseitigte eine benannte Spur; der Rest liegt nahe 1/(Zahl der Ketten). Nach Wortlaut ist der Generator damit nicht freigegeben; F2 blieb fuer die erste Reihe trotzdem so (Messlatte gegen die beste Abkuerzung statt gegen den Zufall). Wichtigste Lehre: synthetische Aufgaben verraten ihre Antwort ueber Zaehl- und Strukturspuren, die erst ein Oberflaechen-Spieler findet. Die eigentliche Modellreihe (Arme A/B/C, 128/4/4) ist nie gelaufen; die Textsammlung fuer Arm C wurde stattdessen zum Nano-Geschichten-Korpus (snai/geschichten-d96-probe).
  Offen: Modellseite M1/M2 gebaut (sonde_modell.php, sonde_auswertung.py), nur an einem Mini-Modell angetestet (arbeit/mini_out.jsonl), keine Messreihe. Rot-Proben 3 und 5 brauchen ein Modell.
  Datei: rechner-a:~/snai_pruef/schluss/ERGEBNIS.md
Chronik:
  2026-10-21 14:27 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/schluss/kriterien_proben.txt (laut Text vor dem ersten Lauf, 2026-10-15; Nachtraege jeweils vor dem naechsten Lauf).)
  2026-10-21 14:28 Rezept r57
  2026-10-21 14:28 Status geplant -> laeuft (Rezept r57)
  2026-10-21 14:28 Messwerte m545-m556
  2026-10-21 14:28 Ergebnis e52: teilweise
  2026-10-21 14:28 Status laeuft -> ausgewertet (Ergebnis e52)
```
