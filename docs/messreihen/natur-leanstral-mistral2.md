# snai/natur-leanstral-mistral2

```text
snai/natur-leanstral-mistral2 - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:33
Frage: Hilft der 'mistral2'-Prompt auch Leanstral, gepaart gemessen (gleiche Saatwoerter je Paar, einziges Stellrad der Prompt)?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/schluss/kriterien_natur.txt, Abschnitt 'LEANSTRAL MIT MISTRAL2-PROMPT, ISOLIERT' (laut Text vor dem Lauf, 2026-10-15 13:5x).):
  Behaltene Token nach gemeinsamem Filter. NEU gewinnt, wenn die Summe >= 10 % hoeher ist UND NEU in >= 15 von 20 Paaren vorn liegt; ALT spiegelbildlich; sonst Gleichstand. Paar mit Fehler faellt heraus; der laufende Leanstral-Abruf darf im Fenster keine 429 bekommen.
Baut auf: snai/natur-ministral-mistral2
Rezepte:
  r94 [2026-10-21] python3 natuertext.py holen (Arm ALT) und SNAI_NATUR_PROMPT=mistral2 python3 natuertext.py holen (Arm NEU), Anfragen 0-19, je 6/min gleichzeitig
      quelltext: natuertext.py 4a9b8c18 (md5 heute)
      parameter: 20 Paare, Leanstral labs-leanstral-1-5-1
      seed: 5
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/schluss/arbeit/lean_alt/, lean_neu/, lean_alt.log, lean_neu.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/schluss/kriterien_natur.txt (Ergebnisabschnitt; aus der Kriteriendatei abgelesen, Filterlaeufe nicht nachgerechnet)
  m904 behaltene Token Summe | 7.553 | ALT | 5 | 20
  m905 behaltene Token Summe | 5.728 | NEU | 5 | 20
  m906 Differenz | -24,2 % | NEU-ALT | 5 | 20
  m907 vorn | ALT 14 von 20, NEU 6 von 20 | - | 5 | 20
  m908 behalten | 84,7 % gegen 70,3 % | ALT/NEU | 5
  m909 Sekunden je Anfrage Median | 40 gegen 51 | ALT/NEU | 5 | 20
  m910 Fehler | 0 | beide | 5 | 40
Ergebnis e92 [2026-10-21 14:33]: gleichstand
  Fazit: Nach Wortlaut Gleichstand, weil ALT die 15-von-20-Regel um ein Paar verfehlt - die Richtung ist aber klar gegen NEU (-24 %, Verwurf fast nur am Wortschatz, langsamer). Leanstral bleibt beim alten Prompt. Folge fuer alle Quellen: Prompts sind modellspezifisch, eine Verbesserung bei einem Modell wird nicht uebertragen, ohne sie gepaart zu messen.
  Datei: rechner-a:~/snai_pruef/schluss/kriterien_natur.txt
Chronik:
  2026-10-21 14:32 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/schluss/kriterien_natur.txt, Abschnitt 'LEANSTRAL MIT MISTRAL2-PROMPT, ISOLIERT' (laut Text vor dem Lauf, 2026-10-15 13:5x).)
  2026-10-21 14:32 Rezept r94
  2026-10-21 14:32 Status geplant -> laeuft (Rezept r94)
  2026-10-21 14:33 Messwerte m904-m910
  2026-10-21 14:33 Ergebnis e92: gleichstand
  2026-10-21 14:33 Status laeuft -> ausgewertet (Ergebnis e92)
```
