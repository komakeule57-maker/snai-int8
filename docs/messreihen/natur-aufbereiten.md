# snai/natur-aufbereiten

```text
snai/natur-aufbereiten - ausgewertet, angelegt 2026-10-30, zuletzt 2026-10-30 05:05
Frage: Wie viel natuerlicher Text (Kindergeschichten) bleibt nach dem gemeinsamen Filter aller Dauerlauf-Quellen (Leanstral, Ministral-mistral2, Gemma, Flash 3.1, Flash 3.5), und reicht er fuer Arm C (~10 Mio Token)?
Kriterium (festgelegt 2026-10-30 04:58, vor dem ersten Messwert):
  Werkzeug natuertext.py aufbereiten (Filter unveraendert laut kriterien_natur.txt: Ziffern, fremde Zeichen, Silbenpaar, 'antwort :', < 3 Saetze, Dubletten; Wortschatz = 1.500 haeufigste Woerter ueber ALLE Quellen gemeinsam). Token = Woerter + Satzzeichen nach normalisiere() (wie im Skript). Quellen nur Dauerlaeufe: zusatz gemma/natur, gemma/natur_flash, gemma/natur_flash35; roh natur_voll/roh.jsonl, natur_ministral2/roh.jsonl (in dieser Reihenfolge; bei Dubletten zaehlt die erste). Nicht dabei: Proben (natur/, natur15/, natur_ministral/ (rot), natur_flash35_p1-3, probe_flash1-4, arbeit/). ERFUELLT, wenn behaltene Token >= 10 Mio; sonst VERFEHLT mit Menge. Gueltigkeit: Gegenprobe (N4) gruen; Summe der Quellen = Gesamt; Umbau auf mehrere Quellen mit altem Aufruf bytegleich (natur.txt, wortschatz.json, Bericht) und Rot-Probe gesehen (2026-10-30, vor dem Lauf erledigt). Berichtet, nicht geurteilt: Behaltquote und Token je Quelle, Verwurfsgruende, 2 Zufallsgeschichten je Quelle zur Sichtpruefung.
Plan: rechner-a:~/snai_pruef/schluss/kriterien_natur.txt
Baut auf: snai/natur-leanstral-probe, snai/natur-flash35-persona, snai/natur-ministral-mistral2
Darauf baut: snai/geschichten-chin128
Rezepte:
  r461 [2026-10-30] cd ~/snai_pruef/schluss && nice -n 10 python3 natuertext.py aufbereiten natur_alle --zusatz gemma/natur --zusatz gemma/natur_flash --zusatz gemma/natur_flash35 --roh natur_voll/roh.jsonl --roh natur_ministral2/roh.jsonl > natur_alle/bericht.txt 2> natur_alle/bericht.err
      quelltext: rechner-a:~/snai_pruef/schluss/natuertext.py md5 d7045b0b (Umbau 2026-10-30 auf mehrere Quellen; Original natuertext.py.vor_20261030 md5 4a9b8c18)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/schluss/natur_alle/ (natur.txt, natur_quelle.txt, je_quelle.json, wortschatz.json, bericht.txt, bericht.err)
      notiz: Gleichlauf alt/neu bytegleich (natur15 + natur_flash35_p1: natur.txt 725bafdd, wortschatz.json 55f3eb93, Berichtszeilen gleich); Rot-Probe (Zusatzquelle gestrichen) -> natur.txt ac9a44f2 abweichend; Gegenprobe N4 gruen.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/schluss/natur_alle/bericht.txt (bericht.err leer), je_quelle.json
  m6415 Geschichten gelesen | 1601614 | gesamt
  m6416 Geschichten behalten | 918224 (57,3 %) | gesamt
  m6417 Token behalten | 28646577 | gesamt
  m6418 Verwurf kurz | 335516 | gesamt
  m6419 Verwurf wortschatz | 339323 | gesamt
  m6420 Verwurf doppelt | 6715 | gesamt
  m6421 Verwurf zeichen/ziffer/silbenpaar | 1801/32/3 | gesamt
  m6422 Behalten | 228556/250425 (91,3 %) | gemma (natur)
  m6423 Token behalten | 5791055 | gemma (natur)
  m6424 Behalten | 123742/195929 (63,2 %) | flash31 (natur_flash)
  m6425 Token behalten | 3015919 | flash31 (natur_flash)
  m6426 Behalten | 153096/584750 (26,2 %) | flash35 (natur_flash35)
  m6427 Token behalten | 7021964 | flash35 (natur_flash35)
  m6428 Behalten | 217296/271686 (80,0 %) | leanstral (natur_voll)
  m6429 Token behalten | 6612538 | leanstral (natur_voll)
  m6430 Behalten | 195534/298824 (65,4 %) | ministral (natur_ministral2)
  m6431 Token behalten | 6205101 | ministral (natur_ministral2)
  m6432 Summenprobe Quellen = Gesamt | 918224 / 28646577 stimmt | gesamt
  Quelle: rechner-a: scratchpad tok/zaehle.php (echter SnaiTokenizer aus ~/snai_pruef/schluss/rig, SNAI_VOCAB; Vokabular fuer Natur aus erzeuge.py --natur natur_alle/natur.txt, Saat 1, 1577 Eintraege), Arm A = arbeit/w8/s1a/train_A.txt mit eigenem vokabular.json
  m6433 Natur Woerter (Leerzeichen) | 28646577 | natur_alle
  m6434 Natur Token echter Tokenizer | 29564801 (+3,2 %; = Woerter + 918224 Zeilenumbrueche, unk 0) | natur_alle
  m6435 Arm A Woerter (Leerzeichen) | 6997832 | w8/s1a train_A
  m6436 Arm A Token echter Tokenizer | 7078151 (+1,15 %; = Woerter + 80319 Zeilenumbrueche, unk 0) | w8/s1a train_A
  m6437 Blockgrenzen ohne Einfluss | 794098 bei 1 Block und 30 Bloecken (30.000 Zeilen) | Probe
  m6438 Rot-Probe fremdes Wort | 1 unk, 6 Token fuer 5 Woerter + Umbruch | Probe
Ergebnis e407 [2026-10-30 05:05]: erfuellt
  Fazit: Der gemeinsam gefilterte Vorrat reicht fast dreimal fuer Arm C: 28,6 Mio Woerter = 29,6 Mio echte Token (SnaiTokenizer, 0 unk); weitere Sammellaeufe sind nicht noetig. Die Leerzeichen-Zaehlung ist dasselbe Mass wie die Aufgaben-Token von Arm A: der echte Tokenizer zaehlt zusaetzlich nur die Zeilenumbrueche (+3,2 % Natur, +1,15 % Arm A, Abstand unter 10 %). Wer C exakt an A angleichen will, zaehlt Woerter + Zeilen. Gleicher Quellenanteil je Arm ist ohne Engpass moeglich; Flash 3.5 ist je Anfrage die schlechteste Quelle (26 % behalten), Gemma die sauberste (91 %).
  Offen: Vielfalt (haeufigste 4-Folge, F3b) im Gesamtbestand nicht gemessen (als nebensaechlich eingestuft). Zusammenhang innerhalb der Geschichten prueft der Filter nicht. Ob Arm C andere Geschichten bekommen soll als die ~3 Mio, die A/B eingemischt bekommen, ist nicht entschieden (Vorrat reicht fuer beides).
  Datei: rechner-a:~/snai_pruef/schluss/ERGEBNIS_natur_aufbereiten.md
Abgeloest und ausgeblendet: 1 ergebnis - voll=True zeigt sie.
Chronik:
  2026-10-30 04:58 angelegt
  2026-10-30 04:59 Rezept r461
  2026-10-30 04:59 Status geplant -> laeuft (Rezept r461)
  2026-10-30 05:00 Messwerte m6415-m6432
  2026-10-30 05:00 Ergebnis e406: erfuellt
  2026-10-30 05:00 Status laeuft -> ausgewertet (Ergebnis e406)
  2026-10-30 05:05 Messwerte m6433-m6438
  2026-10-30 05:05 Ergebnis e407: erfuellt, loest e406 ab
```
