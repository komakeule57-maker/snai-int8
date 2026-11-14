# snai/gebiet-schach-sichtung

```text
snai/gebiet-schach-sichtung - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:28
Frage: Gebiets-Sichtung Runde 2 (Gebiete mit objektivem Pruefer): Besteht das Gebiet Schachaufgaben (Lichess-Puzzles, Stellung nach dem Fehlzug, Stockfish als Pruefer) die Bedingungen K1-K5, und wo liegt die Messlatte fuer einen Knirps? (Molekuele als zweiter Kandidat abgebrochen.)
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_runde2.txt samt Nachtrag nach dem Pruefer, Kalibrierung (W 0,70 / A 0,15) und Pruefer-Korrektur 'erreichbar' (alle laut Text vor der Messung, 2026-10-15; Datei mtime 07:28).):
  K3 >= 1.000 Trainingsbeispiele (Teilung nach Partie). K4 p90 <= 64 Token erfuellt, <= 128 bedingt. K1 Positivkontrolle Held-out >= 90 %, Rot-Probe 'einen Halbzug frueher' <= 25 %. Pruefer: legal und erreichbar, Stockfish 19 200.000 Knoten MultiPV 2, Gewinnchance >= W und Abstand zum Zweitbesten >= A; W/A vorab auf 500 Trainingsaufgaben kalibriert (strengste Kombination mit >= 95 %) und eingefroren. K2 B = max ueber Regel- und Trigramm-Arme (Z, Z2 'echte Aufgabe, 4 Figuren versetzt', N): B < 10 % Platz, B >= 50 % der Positivkontrolle raus, dazwischen offen. K5 1,1 x B <= Decke. 'Weiter' verlangt K2 Platz UND K5; im offenen Bereich ohne K5 -> raus. Neuheit: nur Ausgaben, die nicht woertlich im Training stehen.
Baut auf: snai/gebiet-akkorde-hmm
Darauf baut: snai/schach-d64-lauf
Rezepte:
  r56 [2026-10-21] cd ~/snai_pruef/knirps/gebiete && .venv/bin/python schach.py --kalibrieren; .venv/bin/python schach.py --messen 0.70 0.15 --json ~/.cache/snai_pruef/knirps/gebiete/schach.jsonl
      quelltext: schach.py 9dd704c0 (md5 heute; Datei nach der Sichtung fuer den Lauf erweitert, mtime 2026-10-15 16:20 - der Stand der Sichtung ist nicht gesichert)
      parameter: Lichess-Puzzles CC0, erste 200.000 Zeilen; Stockfish 19, 1 Thread, Hash 16 MB, 200.000 Knoten, MultiPV 2; W 0,70, A 0,15; je Arm 1.000 Ausgaben
      seed: 4711
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/gebiete/schach.jsonl Zeile 1 (Sichtung), schach_lauf.out
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/gebiete/schach.jsonl Zeile 1 (= schach_lauf.out), gegen ERGEBNIS geprueft; Kalibrierwert aus kriterien_runde2.txt
  m532 K3 Trainingsaufgaben | 180123 | - | 4711
  m533 K3 Held-out | 19877 | - | 4711
  m534 K4 Token median/p90/max | 38/54/66 | -
  m535 Kalibrierung bestehen bei W 0,70 A 0,15 | 96,2 % | Training |  | 500
  m536 K1 Positivkontrolle | 96,4 % | echt Held-out | 4711 | 1000
  m537 Rot einen Halbzug frueher | 9,5 % | rot_vor | 4711 | 1000
  m538 Rot Zufallsfelder legal | 4,1 % | rot (a) | 4711
  m539 K2 Z2 Aufgaben unter geprueften | 21,2 % | Z2 | 4711 | 1000
  m540 K2 Z Aufgaben unter geprueften | 13,1 % | Z | 4711 | 1000
  m541 K2 N Aufgaben unter geprueften | 9,4 % | N Trigramm | 4711 | 1000
  m542 K2 N legal | 9,6 % | N Trigramm | 4711 | 1000
  m543 K5 Messlatte 1,1 x B | 23,3 % | -
  m544 Engine-Fehler | 0 | alle | 4711
Ergebnis e51 [2026-10-21 14:28]: teilweise
  Fazit: Schachaufgaben bestehen K1, K3, K4 und K5 klar, K2 bleibt offen: die triviale Abwandlung echter Aufgaben (Z2) trifft schon 21,2 %. Nach Vorab-Regel 'offen, braucht einen Lauf' mit Messlatte 23,3 % Aufgaben je Ausgabe. Das hat den Knirps-Lauf snai/schach-d64-lauf begruendet. Der wichtigere Befund: der Pruefer nimmt 13,1 % reiner Zufallsstellungen aus echtem Material an, misst also 'Gewinnzug eindeutig', nicht 'gute Aufgabe'; diese Schwaeche hat spaeter die ganze Schachreihe gepraegt.
  Offen: Molekuel-Kandidat M: abgebrochen und nicht ausgewertet (Gebiet ausserhalb des Projekts); in der Rohdatei molekuele.jsonl liegt eine Teilmessung (Positivkontrolle 88,2 %), die nicht als Ergebnis gilt. Ob ein strengerer Pruefer das Urteil verschiebt, wurde im Lauf geprueft (strenger Pruefer riss seine Positivkontrolle).
  Datei: rechner-a:~/snai_pruef/knirps/gebiete/ERGEBNIS_sichtung.md (Abschnitt 'Runde 2, 2026-10-15')
Chronik:
  2026-10-21 14:27 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_runde2.txt samt Nachtrag nach dem Pruefer, Kalibrierung (W 0,70 / A 0,15) und Pruefer-Korrektur 'erreichbar' (alle laut Text vor der Messung, 2026-10-15; Datei mtime 07:28).)
  2026-10-21 14:28 Rezept r56
  2026-10-21 14:28 Status geplant -> laeuft (Rezept r56)
  2026-10-21 14:28 Messwerte m532-m544
  2026-10-21 14:28 Ergebnis e51: teilweise
  2026-10-21 14:28 Status laeuft -> ausgewertet (Ergebnis e51)
```
