# snai/gebiet-akkorde-hmm

```text
snai/gebiet-akkorde-hmm - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:28
Frage: Akkorde zur Melodie: Wie hoch liegt die beste billige GELERNTE Stufe (HMM erster Ordnung, 30 Zustaende) gegenueber der Regel R, und bleibt fuer einen Knirps Platz unter der menschlichen Einigkeit D?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien.txt, Abschnitt 'HMM-GEGENVERSUCH AKKORDE' samt Nachtrag nach dem Pruefer (laut Text vor der Messung, 2026-10-15).):
  H gegen R: unter 10 % relativ = Gleichstand. Messlatte fuer einen Knirps M = 1,1 x max(R, H). M > D (82,1 %) -> 'kein Platz'; M <= D -> 'weiter' (Knirps-Lauf ctx 128); M innerhalb 1 Punkt um D -> 'knapp', dann entscheidet obere KI-Grenze von H x 1,1 gegen D. Liegt H >= D, ist D als Decke widerlegt -> 'weiter'. Rot-Probe: vertauschte Etiketten -> H <= 55 %. Determinismus: zwei Laeufe bytegleich. Gepaarter Bootstrap ueber Held-out-Lieder (2.000). Freie Parameter (Glaettung 0,5, Gewicht 1:1, Bezug Dur-Grundton) werden nicht verstellt.
Baut auf: snai/gebiet-musik-sichtung
Darauf baut: snai/gebiet-schach-sichtung
Rezepte:
  r55 [2026-10-21] cd ~/snai_pruef/knirps/gebiete && python3 akkorde.py --json ~/.cache/snai_pruef/knirps/gebiete/akkorde.jsonl
      quelltext: akkorde.py e200e21c (md5 heute, mtime 2026-10-15 06:32)
      parameter: HMM 30 Zustaende relativ zum Dur-Grundton, Emission Tonklassen dauergewichtet, add-0,5, Gewicht 1:1, keine Parametersuche, Viterbi je Lied, geschenkte Abschnittsgrenzen; 943 Trainings-, 91 Held-out-Lieder (7.233 Viertel)
      seed: Rot-Probe 4711; Bootstrap ueber Lieder
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/gebiete/akkorde.jsonl (letzte Zeile, Schluessel HMM)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/gebiete/akkorde.jsonl (letzte Zeile, gegen ERGEBNIS_sichtung.md geprueft)
  m521 H je Viertel Held-out | 75,7 % | HMM |  | 7233
  m522 H KI95 | 72,3-79,1 % | HMM |  | 7233
  m523 R je Viertel Held-out | 69,6 % | Regel R |  | 7233
  m524 H minus R KI95 | 3,1-9,0 Punkte | HMM-R |  | 7233
  m525 H relativ zu R | +8,8 % | HMM-R |  | 7233
  m526 B ohne Uebergang | 73,0 % | Bayes |  | 7233
  m527 Rot vertauschte Etiketten | 46,3 % | HMM rot | 4711 | 7233
  m528 H auf Training | 73,5 % | HMM
  m529 R auf Training | 68,8 % | Regel R
  m530 Messlatte M = 1,1 x H | 83,3 % | -
  m531 Decke D | 82,1 % | - |  | 9713
Ergebnis e50 [2026-10-21 14:28]: verfehlt
  Fazit: Nach Vorab-Regel 'kein Platz': M = 83,3 % liegt ueber D = 82,1 % (1,2 Punkte, ausserhalb des Knapp-Bandes). Akkorde taugen damit nicht als Gebiet, an dem sich ein Knirps messbar verbessern laesst; das Hindernis ist das Mass (Uebereinstimmung mit einem einzigen menschlichen Bearbeiter), nicht das Modell. Kein Knirps-Lauf fuer Akkorde. H gegen R ist mit +8,8 % relativ Gleichstand. Lehre: das Mass braucht Luft nach oben (wurde als K5 in Runde 2 uebernommen).
  Offen: D ist eine grobe Schaetzung der menschlichen Einigkeit, keine harte Obergrenze; das KI von H ergibt M zwischen 79,5 und 87,0 und ueberdeckt D zu beiden Seiten. Ob ein Knirps musikalisch bessere Begleitungen setzt, beantwortet diese Messung nicht.
  Datei: rechner-a:~/snai_pruef/knirps/gebiete/ERGEBNIS_sichtung.md (Abschnitt 'Nachtrag 2026-10-15: HMM-Gegenversuch Akkorde')
Chronik:
  2026-10-21 14:27 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien.txt, Abschnitt 'HMM-GEGENVERSUCH AKKORDE' samt Nachtrag nach dem Pruefer (laut Text vor der Messung, 2026-10-15).)
  2026-10-21 14:28 Rezept r55
  2026-10-21 14:28 Status geplant -> laeuft (Rezept r55)
  2026-10-21 14:28 Messwerte m521-m531
  2026-10-21 14:28 Ergebnis e50: verfehlt
  2026-10-21 14:28 Status laeuft -> ausgewertet (Ergebnis e50)
```
