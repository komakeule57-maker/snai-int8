# snai/drohne-arbeiter

```text
snai/drohne-arbeiter - ausgewertet, begonnen 2026-10-11, angelegt 2026-10-21, zuletzt 2026-10-21 19:28
Frage: Schaden zu viele Arbeiter mit Mittelung im Drohnen-Langlauf (128/4/4, ctx 512, int8, gebunden, Rezept prod512b): liegt Arm W (10 Arbeiter) und liegen W2/W4/W6 bei gleichem Material im Held-out mehr als den doppelten Rauschboden hinter dem Ein-Arbeiter-Arm, ohne dass der Abstand über die Segmente schrumpft, und unterscheiden sich tote Neuronen?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 (Kriterium), (Zählung toter Neuronen), (Ende), Arbeitsblatt ~/snai_pruef/blatt.jsonl (versuch drohne, Einträge 3 bis 10 und 90) und den lauf.log der Arme. Datum aus den Logköpfen (W 2026-10-11 12:02:47, W2/W4/W6 2026-10-12 10:48). Das Kriterium (10:15 UTC = 12:15 Ortszeit) wurde rund 12 Minuten nach dem Start von W festgelegt, aber vor jedem Messwert.):
  Vorab (2026-10-11 12:15 Ortszeit): Rauschboden Held-out = Abstand Arm P gegen Arm E (gleiche Rechnung, zwei Rechner); Schaden belegt ab doppeltem Rauschboden ohne Schrumpfen über die Segmente; tote Neuronen unter 10 % oder einstellig = Gleichstand. Dazu Inferenz (Leseprobe) und Attention/Gradientenanteile ohne eigene Schwelle.
Plan: Erst 1 gegen 10 Arbeiter (P gegen W auf rechner-b), danach 2, 4 und 6 Arbeiter gleichzeitig; Segmente 0 bis 19.
Baut auf: snai/kopier-drohne-k-e, snai/kopier-drohne-p
Darauf baut: snai/drohne-arbeiter-raetsel
Rezepte:
  r174 [2026-10-21] W, W2, W4, W6: DR_LAST=19 DR_THREADS=1 bash run_drohne.sh W  (ebenso W2, W4, W6)
      quelltext: Genesis bd2b7d9e9246 (4 Köpfe), libcortex 1c634106f31c, Vokabular f020d0ca3a5b9835f0ef3c5935edd772 (Logkopf)
      parameter: LR 0,0001, Warmup 500, Cosinus bis 802000 (Boden 0,1), WD 0,1, 1 Fenster je Update, Ganzzahl-Stack 1; Arbeiter 10 / 2 / 4 / 6 (Mittelung von Gewichten und Adam-Gedächtnis am Segmentende); Revival an
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/drohne/log_{W,W2,W4,W6}/lauf.log
      notiz: W2, W4 und W6 liefen gleichzeitig: 13 Arbeiter auf 12 Threads (Blatt-Eintrag 10). Am 2026-10-13 gegen 12:19 auf Anweisung beendet (Blatt-Eintrag 90). Fensterfolge hängt am Laufnamen; Revival an.
  r175 [2026-10-21] E, P: DR_LAST=19 bash run_drohne.sh E  (rechner-a); P auf rechner-b mit 3 Threads
      quelltext: wie W (Genesis bd2b7d9e9246, libcortex 1c634106f31c)
      parameter: Rezept wie W, 1 Arbeiter
      rechner: rechner-a (E), rechner-b (P)
      logs: rechner-a:~/snai_pruef/drohne/log_E/lauf.log; rechner-b:~/snai_pruef/drohne/log_P/lauf.log
      notiz: Bezug und Rauschboden. P ebenfalls am 2026-10-13 beendet.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/drohne/log_*/lauf.log, rechner-a:~/snai_pruef/drohne/log_E/lauf.log; D aus rechner-a:~/snai_pruef/drohne/arbeiter/auswert.py (2026-10-21 neu gerechnet). Segment steht in der Größe, je Arm eine Saat.
  m2133 Held-out Rauschboden P-E Segment 0 | 0,0046 | P gegen E |  | 1
  m2134 Held-out Segment 0 | 5,6152 | E |  | 1
  m2135 Held-out Segment 0 | 5,6106 | P |  | 1
  m2136 Held-out Segment 0 | 7,344 | W |  | 1
  m2137 Held-out Segment 1 | 6,783 | W |  | 1
  m2138 Held-out bei ~20.500 Schritten je Arbeiter | 5,615 | E |  | 1
  m2139 Held-out bei ~20.500 Schritten je Arbeiter | 5,611 | P |  | 1
  m2140 Held-out bei ~20.500 Schritten je Arbeiter Segment 1 | 5,534 | W2 |  | 1
  m2141 Held-out bei ~20.500 Schritten je Arbeiter Segment 3 | 5,523 | W4 |  | 1
  m2142 Held-out bei ~20.500 Schritten je Arbeiter Segment 5 | 5,511 | W6 |  | 1
  m2143 Held-out bei ~20.500 Schritten je Arbeiter Segment 9 | 5,516 | W |  | 1
  m2144 Held-out bei ~41.000 Schritten je Arbeiter | 5,057 | E |  | 1
  m2145 Held-out bei ~41.000 Schritten je Arbeiter | 5,035 | P |  | 1
  m2146 Held-out bei ~41.000 Schritten je Arbeiter Segment 3 | 5,028 | W2 |  | 1
  m2147 Held-out bei ~41.000 Schritten je Arbeiter Segment 7 | 4,982 | W4 |  | 1
  m2148 Held-out bei ~41.000 Schritten je Arbeiter Segment 11 | 4,972 | W6 |  | 1
  m2149 Held-out bei ~41.000 Schritten je Arbeiter Segment 19 | 4,969 | W |  | 1
  m2150 Rückstand D bei gleichem Material (ICL-Wächter) | 1,703 bis 1,640 | W |  | 3
  m2151 Rückstand D bei gleichem Material (ICL-Wächter) | 1,384 bis 1,306 | W6 |  | 2
  m2152 Rückstand D bei gleichem Material (ICL-Wächter) | 1,128 bis 0,999 | W4 |  | 2
  m2153 Leseprobe Treffer | 0 von 10 | alle Arme |  | 1
  m2154 Beleg-Anteil am Ende | 2,2 bis 2,4 % | W-Arme |  | 1
Ergebnis e161 [2026-10-21 19:28]: teilweise
  Fazit: Bei gleichem Material schaden viele Arbeiter deutlich: W liegt um 1,6 bis 1,7 im Held-out hinter E, das ist mehr als das Hundertfache des doppelten Rauschbodens (0,009). Der Abstand schrumpft über die Segmente leicht (1,703 -> 1,640, rund 4 %); 'ohne Schrumpfen' ist damit knapp verletzt. Bei gleicher Schrittzahl je Arbeiter liegen dagegen alle W-Arme gleichauf oder leicht vor dem Ein-Arbeiter-Arm, der Schaden ist also im Wesentlichen das fehlende Hintereinander der Schritte (siehe snai/drohne-arbeiter-raetsel). Die Frage nach toten Neuronen beantwortet die Reihe nicht: die Zählung im Log ist ein Artefakt. Für Mehr-Arbeiter-Training heißt das: mehr Arbeiter sparen keine Schritte, sie kaufen nur Material.
  Offen: Tote Neuronen ohne gültige Zählung; ob häufigeres Mitteln (kleinere Segmente) hilft; je Arbeiterzahl nur ein Lauf; Revival lief mit (Reproduzierbarkeit). Läufe am 2026-10-13 12:19 abgebrochen, W2/W4/W6 nicht bis Segment 19.
  Datei: rechner-a:~/Projekte/snai_edge_int8_lora/docs/VERGLEICH_LITERATUR_KOPIEREN.md (Abschnitt 6k); rechner-a:~/snai_pruef/drohne/arbeiter/
Chronik:
  2026-10-21 19:27 angelegt (Nachtrag: Nachtrag 2026-10-21 (Kriterium), (Zählung toter Neuronen), (Ende), Arbeitsblatt ~/snai_pruef/blatt.jsonl (versuch drohne, Einträge 3 bis 10 und 90) und den lauf.log der Arme. Datum aus den Logköpfen (W 2026-10-11 12:02:47, W2/W4/W6 2026-10-12 10:48). Das Kriterium (10:15 UTC = 12:15 Ortszeit) wurde rund 12 Minuten nach dem Start von W festgelegt, aber vor jedem Messwert.)
  2026-10-21 19:28 Rezept r174 (W, W2, W4, W6)
  2026-10-21 19:28 Status geplant -> laeuft (Rezept r174)
  2026-10-21 19:28 Rezept r175 (E, P)
  2026-10-21 19:28 Messwerte m2133-m2154
  2026-10-21 19:28 Ergebnis e161: teilweise
  2026-10-21 19:28 Status laeuft -> ausgewertet (Ergebnis e161)
```
