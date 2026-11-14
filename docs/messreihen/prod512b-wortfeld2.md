# snai/prod512b-wortfeld2

```text
snai/prod512b-wortfeld2 - ausgewertet, angelegt 2026-10-30, zuletzt 2026-10-30 16:38
Frage: Wird in prod512b ein Zielwort wahrscheinlicher, wenn ein thematisch verwandtes Wort außerhalb der Trigramm-Reichweite im Kontext stand? Ab welchem Stand? Neue Sonde mit Wörtern nach Regel, 8 Neutralwörtern, Sätzen im Lexikonstil, Boden relativ zum Effekt und Nullrelationen.
Kriterium (festgelegt 2026-10-30 15:07, vor dem ersten Messwert):
  kriterien.txt md5 4e6f8b2b, vor Wortwahl und Modellmessung. F = exp(Mittel D) gegen 8 Neutralwörter, bereinigt um 3 Kontrollziele. VERBINDUNG: F>=1,5, KI-Untergrenze>=1,1 (Bootstrap gekreuzt über Sätze und Neutralwörter), F>B (B = größter Neutralwort-gegen-Rest-Faktor), F>=1,25 in beiden Trägerhälften. GEGENTEIL spiegelbildlich. KEINE: ganzes KI in 1/1,5 bis 1,5. Sonst UNKLAR. Zweite Lesart ohne Entscheidung: log F>=1,5 log B. GÜLTIG nur wenn: Genesis nirgends VERBINDUNG, Schiff->Hafen auf s7 VERBINDUNG, auf s7 höchstens 1 von 12 Nullrelationen VERBINDUNG oder GEGENTEIL, Tokens sauber, Fehlerkanal gesichtet, Rot der Auswertung mit synthetischen Daten bestanden. AUSSAGE: auf s7 gezeigt bei mindestens 6 von 10 neuen Positiven VERBINDUNG; frühester Stand = erster Stand, an dem das gilt. Eine Saat, also Beobachtung über dieses eine Modell.
Plan: rechner-b:~/snai_pruef/wortfeld_p2/kriterien.txt
Baut auf: snai/prod512b-wortfeld, snai/geschichten-wortfeld
Rezepte:
  r472 [2026-10-30] cd ~/snai_pruef/wortfeld_p2 && ./lauf_p2.sh; python3 werkzeug/auswerten.py log/auswahl.json log/s7.jsonl ...
      quelltext: kriterien.txt 35192662 (4e6f8b2b plus Nachtrag zur Kandidatenregel, vor jeder Modellmessung); auswahl.py 81f4d609; auswahl.json aedb373e; sonde_p2.php 25b04a75; auswerten.py 50578f67; lauf_p2.sh eace5160; libcortex_prod 318b2655; Tokenizer f020d0ca
      parameter: 1 Thread, 10752 Prompts je Stand; Stände s7, s4, s0, t5000, t1000; Genesis s1 nur A0,O0,O1
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/wortfeld_p2/log/
      notiz: Erste Wortauswahl hatte groß geschriebene Funktionswörter, Regel vor der ersten Modellmessung nachgeschärft, v1 liegt in log/auswahl_v1.*
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/wortfeld_p2/log/auswertung.txt, erster Satz
  m6625 P VERBINDUNG von 10 | 0 | t1000
  m6626 P VERBINDUNG von 10 | 0 | t5000
  m6627 P VERBINDUNG von 10 | 5 | s0
  m6628 P VERBINDUNG von 10 | 5 | s4
  m6629 P VERBINDUNG von 10 | 6 | s7
  m6630 O VERBINDUNG/GEGENTEIL von 12 | 0 | t1000
  m6631 O VERBINDUNG/GEGENTEIL von 12 | 0 | t5000
  m6632 O VERBINDUNG/GEGENTEIL von 12 | 0 | s0
  m6633 O VERBINDUNG/GEGENTEIL von 12 | 2 | s4
  m6634 O VERBINDUNG/GEGENTEIL von 12 | 1 | s7
  m6635 Schiff>Hafen F | 3,50 (B 2,09) VERBINDUNG | s7
  m6636 Wasser>Fluss F | 7,08 (B 1,62) VERBINDUNG | s7
  m6637 Regen>Wasser F | 1,08 (B 1,84) KEINE | s7
  m6638 Wasser>Regen F | 4,45 (B 10,59) UNKLAR | s7
  m6639 Hafen>Schiff F | 2,68 (B 2,84) UNKLAR | s7
  m6640 Arzt>Hafen F | 0,12 (B 67,60) UNKLAR | s7
  m6641 Genesis A0,O0,O1 | F 1,00 KEINE | gen_s1
  m6642 Fehlerkanal trainierte Staende | 0 Byte | alle
  Quelle: rechner-b:~/snai_pruef/wortfeld_p2/log/auswertung_w.txt und log/vergleich.txt, Wiederholung mit frischen Sätzen
  m6643 P VERBINDUNG von 10, Satz 2 | 5 | s0
  m6644 P VERBINDUNG von 10, Satz 2 | 5 | s4
  m6645 P VERBINDUNG von 10, Satz 2 | 6 | s7
  m6646 O VERBINDUNG/GEGENTEIL von 12, Satz 2 | 0 | s0
  m6647 O VERBINDUNG/GEGENTEIL von 12, Satz 2 | 1 | s4
  m6648 O VERBINDUNG/GEGENTEIL von 12, Satz 2 | 0 | s7
  m6649 Median F P Satz 1/2 | 3,00 / 2,73 | s7
  m6650 Median F O Satz 1/2 | 1,33 / 1,18 | s7
  m6651 P über allen O Satz 1/2 | 7 / 7 von 10 | s7
  m6652 Korrelation log F Satz 1 gegen 2 | 0,97 | s7
  m6653 Schiff>Hafen F Satz 2 | 3,55 (B 2,36) VERBINDUNG | s7
  m6654 Wasser>Fluss F Satz 2 | 6,18 (B 1,36) VERBINDUNG | s7
  m6655 Regen>Wasser F Satz 2 | 0,99 (B 1,78) KEINE | s7
  m6656 Wasser>Regen F Satz 2 | 3,81 (B 9,01) UNKLAR | s7
  m6657 Hafen>Schiff F Satz 2 | 3,04 (B 2,37) VERBINDUNG | s7
  m6658 Arzt>Hafen F Satz 2 | 0,09 (B 106,83) UNKLAR | s7
Ergebnis e413 [2026-10-30 16:38]: erfuellt
  Fazit: Die Vorgängerreihe scheiterte an der Sonde, nicht am Modell. Für dieses eine Modell (eine Saat, also Beobachtung) gilt: prod512b bindet Themen über Satzgrenzen hinweg, nach 5.000 Schritten gar nicht, ab Segment 0 bei rund der Hälfte der Paare, auf s7 bei 6 von 10, in beiden Satzmengen. Der früheste Stand s7 ist ein Schwellenartefakt: s0 und s4 verfehlen um genau eine Relation. Keine Entscheidung über Training oder Rezept daraus ableiten. Die Sonde taugt für Vergleiche über Stände desselben Aufbaus, nicht für absolute Faktoren: Schiff->Hafen auf s7 war im Vorgänger 9,21, hier 3,50.
  Offen: Wortstichprobe klein, frische Sätze prüfen keine frischen Wörter (r=0,97). Aufwärtsversatz der Nullrelationen auf s7 (Median 1,33/1,18) ungeklärt, Faktoren unter rund 2 dort nicht von Null trennbar. Warum Regen->Wasser in drei Satzmengen fehlt, Wasser->Regen aber nicht, ist offen. Andere Saaten nicht gemessen.
  Datei: rechner-b:~/snai_pruef/wortfeld_p2/ERGEBNIS_wortfeld2.md
Chronik:
  2026-10-30 15:07 angelegt
  2026-10-30 15:11 Rezept r472
  2026-10-30 15:11 Status geplant -> laeuft (Rezept r472)
  2026-10-30 16:07 Messwerte m6625-m6642
  2026-10-30 16:38 Messwerte m6643-m6658
  2026-10-30 16:38 Ergebnis e413: erfuellt
  2026-10-30 16:38 Status laeuft -> ausgewertet (Ergebnis e413)
```
