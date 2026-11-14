# snai/natur-ministral-mistral2

```text
snai/natur-ministral-mistral2 - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:33
Frage: Macht ein Prompt nach den Mistral-Empfehlungen ('mistral2': Systemrolle, Markdown-Abschnitte, objektive Regeln 'fuenf Saetze, keine Kommas', zwei Beispielgeschichten) Ministral-14B zu einer brauchbaren Quelle?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/schluss/kriterien_natur.txt, Abschnitt 'MINISTRAL-PROBE 2' (laut Text vor der Probe, 2026-10-15 13:4x).):
  40 Anfragen, M1-M4 wie bei snai/natur-ministral (M1 >= 35/40, M2 >= 50 % behalten, M3 4-Folge <= 15 %, M4 Leanstral-Takt); zusaetzlich berichtet: Anteil Geschichten mit woertlichem Beispielsatz.
Baut auf: snai/natur-ministral
Darauf baut: snai/natur-leanstral-mistral2, snai/natur-aufbereiten
Rezepte:
  r93 [2026-10-21] SNAI_NATUR_PROMPT=mistral2 SNAI_NATUR_MODELL=ministral-14b-latest SNAI_NATUR_PRO_MINUTE=25 python3 natuertext.py holen (Saat 4, Ablage natur_ministral2/); Dauerlauf Anfragen 40-20.000
      quelltext: natuertext.py 4a9b8c18 (md5 heute)
      parameter: Temperatur Vorgabe des Dienstes; 40 Anfragen Probe
      seed: 4
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/schluss/natur_ministral2/roh.jsonl, natur_ministral2.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/schluss/kriterien_natur.txt (Ergebnisabschnitt; aus der Kriteriendatei abgelesen, Filterlaeufe nicht nachgerechnet); Dauerlauf aus natur_ministral2.log
  m897 M1 Anfragen mit Text | 40 von 40 | mistral2 | 4 | 40
  m898 M2 behalten | 57,2 % (339 von 593) | mistral2 | 4 | 593
  m899 M3 haeufigste 4-Folge | 5,0 % | mistral2 | 4
  m900 M4 Leanstral-Takt im Fenster | 18,6 je Minute | Leanstral
  m901 Geschichten mit Beispielsatz | 0 | mistral2 | 4 | 593
  m902 behaltene Token je Anfrage | 274 | mistral2 | 4 | 40
  m903 Dauerlauf Anfragen mit Text | 19.960 von 19.960 | mistral2 | 4 | 19960
Ergebnis e91 [2026-10-21 14:33]: erfuellt
  Fazit: Mit dem Prompt nach Mistral-Empfehlungen wird Ministral brauchbar (0,3 % -> 57,2 % behalten, keine kopierten Beispielsaetze); Dauerlauf mit 20.000 Anfragen fehlerfrei durchgelaufen. Welche der zwei gleichzeitigen Aenderungen (Systemrolle/Abschnitte oder Beispiele) wirkt, ist nicht isoliert. Derselbe Prompt hilft Leanstral nicht (snai/natur-leanstral-mistral2): jedes Modell bekommt seinen eigenen Prompt.
  Offen: Wirkende Aenderung nicht isoliert.
  Datei: rechner-a:~/snai_pruef/schluss/kriterien_natur.txt
Chronik:
  2026-10-21 14:32 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/schluss/kriterien_natur.txt, Abschnitt 'MINISTRAL-PROBE 2' (laut Text vor der Probe, 2026-10-15 13:4x).)
  2026-10-21 14:32 Rezept r93
  2026-10-21 14:32 Status geplant -> laeuft (Rezept r93)
  2026-10-21 14:33 Messwerte m897-m903
  2026-10-21 14:33 Ergebnis e91: erfuellt
  2026-10-21 14:33 Status laeuft -> ausgewertet (Ergebnis e91)
```
