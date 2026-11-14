# snai/korpus39-dubletten

```text
snai/korpus39-dubletten - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 14:27
!! ohne Kriterium
Frage: Wie viel verschiedener Text steckt im deutschen Wikipedia-Korpus ~/Projekte/snai_edge/factory/input (20.476 Dateien hf_GEN_*.txt, 41,3 GB), wie viel davon fehlt im Produktionskorpus segments_prod, und wie viele Held-out-Artikel stecken darin?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Rezepte:
  r51 [2026-10-21] python3 ~/snai_pruef/korpus39/artikel_hash.py (Ausgaben input.tsv, prod.tsv, ho.tsv, hofull.tsv)
      quelltext: artikel_hash.py (668 Byte, mtime 2026-10-14 12:32)
      parameter: Artikelgrenze </s>, Hash der ersten 200 Zeichen
      seed: -
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/korpus39/{input,prod,ho,hofull}.tsv
Messwerte (Groesse | Wert | Arm | Start | n):
  (abgelesen); Tabellen in ~/snai_pruef/korpus39 nicht nachgerechnet
  m474 Artikel gesamt | 14,0 Mio. | input |  | 20476
  m475 verschiedene Artikel | 5,26 Mio. | input
  m476 Groesse nach Entdoppelung | 12,0 GB (von 41,3) | input
  m477 nicht in segments_prod | 11,0 GB | input-prod
  m478 holdout_prod-Artikel im Korpus | 382 von 600 | ho |  | 600
  m479 holdout_prod-Artikel in segments_prod | 21 von 600 (3,5 %) | ho-prod |  | 600
  m480 holdout_prod_full-Artikel in segments_prod | 181 von 2456 | hofull-prod |  | 2456
Ergebnis e47 [2026-10-21 14:27]: beobachtung
  Fazit: Der grosse Wikipedia-Korpus ist zu drei Vierteln Dublette (meist vierfach); entdoppelt bleiben 12 GB, davon 11 GB neu gegenueber segments_prod - genug Nachschub fuer weitere Segmente. Wer daraus trainiert, muss die 382 Held-out-Artikel ausschliessen. Nebenbefund mit Folgen fuer alle prod512b-Held-out-Zahlen: 3,5 % des Pruefsatzes holdout_prod stehen auch im Trainingskorpus.
  Offen: Hash der ersten 200 Zeichen erkennt nur Dubletten mit gleichem Anfang.
  Datei: rechner-a:~/snai_pruef/korpus39/
Chronik:
  2026-10-21 14:26 angelegt (Nachtrag: Kein Kriterium; das früher genannte 'Kriterium' ist die Messmethode (Artikel getrennt an </s>, Hash der ersten 200 Zeichen). Gemessen 2026-10-14 mit rechner-a:~/snai_pruef/korpus39/artikel_hash.py.)
  2026-10-21 14:26 Rezept r51
  2026-10-21 14:26 Status geplant -> laeuft (Rezept r51)
  2026-10-21 14:27 Messwerte m474-m480
  2026-10-21 14:27 Ergebnis e47: beobachtung
  2026-10-21 14:27 Status laeuft -> ausgewertet (Ergebnis e47)
```
