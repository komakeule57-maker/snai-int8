# snai/natur-leanstral-probe

```text
snai/natur-leanstral-probe - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:30
Frage: Liefert Leanstral (labs-leanstral-1-5-1) brauchbaren natuerlichen Text (sehr einfache Kindergeschichten) fuer den Natur-Anteil der Schlussfolgern-Reihe?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/schluss/kriterien_natur.txt, Abschnitt 'NATUERLICHER TEXTANTEIL MIT LEANSTRAL' (laut Text vor dem ersten Aufruf, 2026-10-15).):
  Probelauf 40 Anfragen: N1 >= 35 von 40 liefern Text; N2 nach dem Filter >= 50 % der Geschichten behalten (Wortschatz 1.500); N4 Gegenproben des Filters (Ziffer, Silbenpaar, 'antwort :', fremdes Wort verworfen, saubere bleibt). N3/N5 nur berichtet. Erst wenn N1, N2, N4 gruen, laeuft der volle Abruf.
Baut auf: snai/schluss-generator-proben
Darauf baut: snai/geschichten-d96-probe, snai/natur-ministral, snai/natur-aufbereiten
Rezepte:
  r61 [2026-10-21] cd ~/snai_pruef/schluss && python3 natuertext.py holen ... (Ablage natur/, Nachprobe natur15/, Dauerlauf natur_voll/ Anfragen 0-6199 und 6200-18999) && python3 natuertext.py aufbereiten
      quelltext: natuertext.py 4a9b8c18 (md5 heute, inzwischen mit Schaltern SNAI_NATUR_MODELL/PRO_MINUTE/PROMPT; ohne Schalter Anfrage unveraendert laut assert)
      parameter: 5 bzw. 15 Geschichten je Anfrage, drei Saatwoerter je Anfrage, Drossel 20/min; gemeinsamer Filter natuertext.py aufbereiten: Ziffern, fremde Zeichen, Silbenpaare, 'antwort :', < 3 Saetze, Dubletten, Wortschatz 1.500 haeufigste Woerter des Gesamtvorrats
      seed: 1
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/schluss/natur/roh.jsonl (40), natur15/roh.jsonl (10), natur_voll/roh.jsonl, natur_holen.log, natur_holen2.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/schluss/kriterien_natur.txt (Ergebnisabschnitt; aus der Kriteriendatei abgelesen, Filterlaeufe nicht nachgerechnet); Anfragezahlen natur/roh.jsonl (40 Zeilen), natur15/roh.jsonl (10) und natur_holen*.log nachgezaehlt
  m595 N1 Anfragen mit Text | 40 von 40 | Leanstral 5 je Anfrage | 1 | 40
  m596 N2 Geschichten behalten | 184 von 184 (100 %) | Leanstral 5 je Anfrage | 1 | 184
  m597 N4 Filter-Gegenproben | alle gruen | Filter |  | 5
  m598 N3 Token je Anfrage / Sekunden | 170 / 20,5 s | Leanstral 5 je Anfrage | 1 | 40
  m599 Nachprobe 15 je Anfrage behalten | 135 von 135 | Leanstral 15 je Anfrage | 1 | 10
  m600 Nachprobe Token je Anfrage / Sekunden | 491 / 32,5 s | Leanstral 15 je Anfrage | 1 | 10
  m601 Dauerlauf Abschnitt 1 mit Text | 6166 von 6200 | Leanstral | 1 | 6200
  m602 Dauerlauf Abschnitt 2 mit Text | 12736 von 12800 | Leanstral | 1 | 12800
Ergebnis e56 [2026-10-21 14:30]: erfuellt
  Fazit: Leanstral besteht N1, N2, N4 klar und wurde Hauptquelle des Natur-Textes (Dauerlauf mit 15 Geschichten je Anfrage, beide Abschnitte bis 2026-10-16 02:31 fertig). Der Wortschatz-Filter greift erst im vollen Korpus (dort 84,6 % behalten laut Flash-3.5-Probe). Mit den uebrigen Quellen ergab das den Nano-Geschichten-Korpus der Knirps-Laeufe.
  Offen: Verwurfsquote des Wortschatzfilters im vollen Korpus ist nur nebenbei berichtet.
  Datei: rechner-a:~/snai_pruef/schluss/kriterien_natur.txt
Chronik:
  2026-10-21 14:29 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/schluss/kriterien_natur.txt, Abschnitt 'NATUERLICHER TEXTANTEIL MIT LEANSTRAL' (laut Text vor dem ersten Aufruf, 2026-10-15).)
  2026-10-21 14:29 Rezept r61
  2026-10-21 14:29 Status geplant -> laeuft (Rezept r61)
  2026-10-21 14:29 Messwerte m595-m602
  2026-10-21 14:30 Ergebnis e56: erfuellt
  2026-10-21 14:30 Status laeuft -> ausgewertet (Ergebnis e56)
```
