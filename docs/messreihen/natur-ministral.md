# snai/natur-ministral

```text
snai/natur-ministral - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:33
Frage: Taugt ministral-14b-latest (Mistral-Schluessel, eigenes Limit 30/min) mit dem Leanstral-Prompt als fuenfte Quelle einfacher Kindergeschichten?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/schluss/kriterien_natur.txt, Abschnitt 'MINISTRAL-14B ALS FUENFTE QUELLE' (laut Text vor der Probe, 2026-10-15 13:2x).):
  Probe 40 Anfragen: M1 >= 35/40 mit Text; M2 >= 50 % der Geschichten behalten im gemeinsamen Wortschatz; M3 haeufigste 4-Folge <= 15 %; M4 Leanstral-Takt im Probefenster faellt nicht um >= 10 % (sonst gemeinsames Limit). Alle gruen -> Dauerlauf.
Baut auf: snai/natur-leanstral-probe
Darauf baut: snai/natur-ministral-mistral2
Rezepte:
  r92 [2026-10-21] SNAI_NATUR_MODELL=ministral-14b-latest SNAI_NATUR_PRO_MINUTE=25 python3 natuertext.py holen (Saat 2, Ablage natur_ministral/)
      quelltext: natuertext.py (Schalter per assert, ohne Schalter unveraendert)
      parameter: 40 Anfragen, Prompt unveraendert (15 Geschichten), Drossel 25/min
      seed: 2
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/schluss/natur_ministral/roh.jsonl (40 Zeilen)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/schluss/kriterien_natur.txt (Ergebnisabschnitt; aus der Kriteriendatei abgelesen, Filterlaeufe nicht nachgerechnet); 40 Zeilen in natur_ministral/roh.jsonl nachgezaehlt
  m892 M1 Anfragen mit Text | 40 von 40 | Ministral | 2 | 40
  m893 M2 behalten | 0,3 % (2 von 600) | Ministral | 2 | 600
  m894 M2 verworfen als 'kurz' | 571 | Ministral | 2 | 600
  m895 M4 Leanstral-Takt im Fenster / davor | 17,4 / 17,6 je Minute | Leanstral
  m896 Sekunden je Anfrage Median | 7,0 | Ministral | 2 | 40
Ergebnis e90 [2026-10-21 14:33]: verfehlt
  Fazit: Mit dem Leanstral-Prompt unbrauchbar: Ministral schreibt nummerierte Ein-Satz-Geschichten mit Kommaketten (0,3 % behalten). Bestaetigt wurde nur das eigene Limit (M4). Kein Dauerlauf mit diesem Prompt; Anlass fuer den Prompt nach Mistral-Empfehlungen (snai/natur-ministral-mistral2). mistral-medium und mistral-small sind mit diesem Schluessel gesperrt (Limit 0, HTTP 429) - dazu lief keine Probe.
  Offen: M3 nicht beurteilbar (2 Geschichten).
  Datei: rechner-a:~/snai_pruef/schluss/kriterien_natur.txt
Chronik:
  2026-10-21 14:32 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/schluss/kriterien_natur.txt, Abschnitt 'MINISTRAL-14B ALS FUENFTE QUELLE' (laut Text vor der Probe, 2026-10-15 13:2x).)
  2026-10-21 14:32 Rezept r92
  2026-10-21 14:32 Status geplant -> laeuft (Rezept r92)
  2026-10-21 14:33 Messwerte m892-m896
  2026-10-21 14:33 Ergebnis e90: verfehlt
  2026-10-21 14:33 Status laeuft -> ausgewertet (Ergebnis e90)
```
