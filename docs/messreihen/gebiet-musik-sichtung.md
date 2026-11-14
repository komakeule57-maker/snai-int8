# snai/gebiet-musik-sichtung

```text
snai/gebiet-musik-sichtung - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:27
Frage: Gebiets-Sichtung fuer den Knirps (ohne Training): Lohnt ein Knirps fuer Schlagzeugmuster (Groove MIDI), Akkorde zur Melodie (Nottingham) oder Geraeusch-Rezepte (*.klang.json)? Je Kandidat 'weiter', 'raus' oder 'offen, braucht einen Lauf' nach den Bedingungen K1-K4 (Leitlinie).
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien.txt, erster Teil samt 'Nachtrag nach dem Pruefer' (laut Text vor der ersten Messung geschrieben, 2026-10-15; Datei spaeter um den HMM-Abschnitt ergaenzt, mtime 2026-10-15 06:29).):
  K3 Daten: >= 1.000 Beispiele im Training, Teilung nach Stueck. K4 Laenge: p90 <= 64 Token erfuellt, <= 128 bedingt. K1 Pruefer: Positivkontrolle Held-out >= 90 % (Schwelle nicht nachtraeglich verstellen, sonst beide Lesarten); A: (a) hoechstens 2 Hand-Instrumente je Schritt, (b) Takt 2 gleicht Takt 1 in >= 8 von 16 Schritten; B: (a) Konsonanz in >= 75 % der Akkordabschnitte, (b) Schlussakkord auf dem Grundton. Rot-Proben: A Schritte mischen -> <= 10 %, drei Zusatzhaende -> (a) verwirft >= 90 %; B Akkorde um einen Takt verschieben -> Konsonanz faellt um >= 20 Punkte. K2 Gegenversuch: A Trigramm-Quote < 10 % -> weiter, >= 50 % der Held-out-Quote (also >= 45 %) -> raus, dazwischen offen. B Regel R (leitereigener Dreiklang, Grenzen geschenkt) je Viertel gegen den Menschen: R >= 75 % raus, R <= 55 % weiter, dazwischen offen; liegt R weniger als 10 Punkte unter der Decke D (Mehrheitsakkord gleicher Takte) -> raus. Messgeraet B: Taktsumme in >= 95 % der Innentakte richtig.
Plan: rechner-a:~/snai_pruef/knirps/gebiete/kriterien.txt
Darauf baut: snai/gebiet-akkorde-hmm
Rezepte:
  r53 [2026-10-21] A Schlagzeug: cd ~/snai_pruef/knirps/gebiete && python3 schlagzeug.py --json ~/.cache/snai_pruef/knirps/gebiete/schlagzeug.jsonl --saat 4711
      quelltext: schlagzeug.py d49fb1e3 (md5 heute; mtime 2026-10-15 05:12, vor der letzten Rohzeile)
      parameter: Groove MIDI Dataset (CC BY 4.0), nur 4/4-Beat-Dateien, Sechzehntelraster, 2-Takt-Fenster, 10 Klassen (HH-Pedal eigene Klasse), offizielle Teilung nach Sitzung; Unigramm/Trigramm je 2.000 Fenster, Glaettung 0,9/0,09/0,01
      seed: 4711
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/gebiete/schlagzeug.jsonl (letzte Zeile gilt)
  r54 [2026-10-21] B Akkorde: cd ~/snai_pruef/knirps/gebiete && python3 akkorde.py --json ~/.cache/snai_pruef/knirps/gebiete/akkorde.jsonl
      quelltext: akkorde.py e200e21c (md5 heute = Stand nach dem HMM-Nachtrag; der Vorstand akkorde.py.vor_hmm lag im Scratchpad und ist nicht mehr da)
      parameter: Nottingham Music Database (jukedeck-Fassung, GPL-3.0), 943 Lieder Training / 91 Held-out, Teilung nach md5 des Liednamens, 8-Takt-Phrasen nach Tonika transponiert, Bootstrap ueber Lieder
      seed: -
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/gebiete/akkorde.jsonl (letzte Zeile gilt, enthaelt auch HMM)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/gebiete/schlagzeug.jsonl und akkorde.jsonl (je letzte Zeile, gegen ERGEBNIS_sichtung.md geprueft); C aus kriterien.txt (vorab gezaehlt)
  m491 C Geraeusch-Rezepte Anzahl | 155 | C
  m492 A Trainingsfenster | 8126 | A | 4711
  m493 A verschiedene Trainingsfenster | 7898 | A | 4711
  m494 A Held-out-Fenster | 2028 | A | 4711
  m495 A Token je Fenster | 33 | A | 4711
  m496 A Anschlaege mit Rundungsfehler ueber 1/4 Sechzehntel | 26,4 % | A | 4711 | 433605
  m497 A K1 Held-out (a) | 99,3 % | A | 4711 | 2028
  m498 A K1 Held-out (b) | 66,3 % | A | 4711 | 2028
  m499 A K1 Held-out beide | 66,0 % | A | 4711 | 2028
  m500 A Rot gemischt beide | 5,2 % | A | 4711 | 2028
  m501 A Rot drei Haende (a) | 0,0 % | A | 4711 | 2028
  m502 A K2 Trigramm beide | 0,0 % | A Trigramm | 4711 | 2000
  m503 A K2 Unigramm beide | 0,0 % | A Unigramm | 4711 | 2000
  m504 A Unigramm (a) allein | 95,5 % | A Unigramm | 4711 | 2000
  m505 A Trigramm woertlich im Training | 0,0 % | A Trigramm | 4711 | 2000
  m506 B Messgeraet Taktsumme richtig | 99,5 % | B |  | 17209
  m507 B verschiedene Trainingsphrasen | 2364 | B
  m508 B Held-out-Phrasen | 344 | B
  m509 B Token p90 (2 je Note) | 122 | B
  m510 B K1 Held-out beide | 90,2 % | B |  | 325
  m511 B K1 Held-out beide KI95 unten | 86,5 % | B |  | 325
  m512 B K1 frische Trainingsphrasen beide | 89,0 % | B |  | 2360
  m513 B K1 frisch KI95 | 87,7-90,3 % | B |  | 2360
  m514 B Rot verschoben beide | 12,3 % | B |  | 325
  m515 B Rot Konsonanz Abschnitte | 47,4 % (statt 90,9 %) | B |  | 325
  m516 B K2 Regel R je Viertel | 69,6 % | B Regel R |  | 7233
  m517 B K2 immer Tonika | 47,6 % | B Tonika |  | 7233
  m518 B Decke D | 82,1 % | B Decke |  | 9713
  m519 B zweite Lesart gleiche Takte R | 74,6 % | B Regel R |  | 980
  m520 B zweite Lesart gleiche Takte Mehrheit | 81,3 % | B Decke |  | 980
Ergebnis e49 [2026-10-21 14:27]: teilweise
  Fazit: Kein Kandidat besteht die Sichtung: Geraeusch-Rezepte raus (155 Beispiele, K3), Schlagzeug nicht weiter (K1: echte Grooves bestehen den Wiederholungspruefer nur zu 66 %, und eine Kopierregel liefert die einzige trennscharfe Eigenschaft umsonst), Akkorde offen (Regel R trifft schon 69,6 %, K1 auf frischen Daten knapp verfehlt). Damit war nur die Akkordfrage weiter zu verfolgen, und zwar mit dem naechstbilligeren Gegenversuch statt mit einem Knirps (snai/gebiet-akkorde-hmm). Lehre fuer die Gebietswahl: der Gegenversuch muss neben dem N-Gramm die naheliegende Regel enthalten; bei den Melodien wurde nie ein Regelgenerator geprueft.
  Offen: Ob die Ausgabe eines Knirps gut klingt, misst keine dieser Groessen. Die vorab gewaehlte Schwelle '> 1/32 Takt' fuer den Rundungsfehler war falsch gewaehlt (beim Runden hoechstens 1/32), gemeldet wurde > 1/64.
  Datei: rechner-a:~/snai_pruef/knirps/gebiete/ERGEBNIS_sichtung.md (Abschnitt 'Gebiets-Sichtung 2026-10-15')
Chronik:
  2026-10-21 14:26 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien.txt, erster Teil samt 'Nachtrag nach dem Pruefer' (laut Text vor der ersten Messung geschrieben, 2026-10-15; Datei spaeter um den HMM-Abschnitt ergaenzt, mtime 2026-10-15 06:29).)
  2026-10-21 14:26 Rezept r53 (A Schlagzeug)
  2026-10-21 14:26 Status geplant -> laeuft (Rezept r53)
  2026-10-21 14:26 Rezept r54 (B Akkorde)
  2026-10-21 14:27 Messwerte m491-m520
  2026-10-21 14:27 Ergebnis e49: teilweise
  2026-10-21 14:27 Status laeuft -> ausgewertet (Ergebnis e49)
```
