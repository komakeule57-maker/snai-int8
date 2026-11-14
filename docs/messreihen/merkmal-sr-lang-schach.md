# snai/merkmal-sr-lang-schach

```text
snai/merkmal-sr-lang-schach - ausgewertet, begonnen 2026-10-18, angelegt 2026-10-21, zuletzt 2026-10-21 19:24
Frage: Schach-Auswertung des grossen d96-Laufs ohne Kollaps (Langlauf MV): Hebt mehr Material und Zeit die Loesbarkeit B ueber die Leiter-d96, oder ist die Saettigung echt? Und wie steht die Form A ohne Kollaps?
Kriterium (nachgetragen, Beleg: Nachtrag in rechner-a:~/snai_pruef/merkmal/sr/kriterien_lang_sr.txt, 'NACHTRAG VOR DEN ERGEBNISSEN (2026-10-18 ~14:55, Langlauf laeuft, noch kein Segment fertig)'; ERGEBNIS SCHACH 2026-10-18 19:58):
  Regel aus gebiete/kriterien_schach_gross.txt unveraendert, Vergleichspunkt Leiter-d96 (B 14,4 %): (1) 'hilft' = B am Endstand in ALLEN DREI Saaten ueber 15,9 %; (2) 'Saettigung echt' = B am Endstand 13,0-15,9 % UND kein belegter Anstieg zwischen Segment 4 und 8 (Intervall-Lesart; Punktwert-Lesart daneben); (3) sonst kein Schluss. A und C gegen Leiter und gegen den alten grossen Lauf per Bootstrap getrennt; unter 10 % relativ = Gleichstand. Zaehlt als Abschluss nur, wenn snai/merkmal-sr-lang HAELT und SCHADET NICHT.
Baut auf: snai/merkmal-sr-lang, snai/schach-gross
Darauf baut: snai/merkmal-gains-fest
Rezepte:
  r163 [2026-10-21] bash ~/snai_pruef/merkmal/sr/kette_sr_schach.sh (Saat 1 je Segment 300 Ziehungen, Endstand s7 je Saat 1.000; T 1,0, Saat 4711; strenger Pruefer W 0,70 / A 0,15; Arbeitsordner proj_ow); python3 sr/boot_schach.py
      quelltext: kette_sr_schach.sh a793d219, boot_schach.py 67d04db7 (geschachtelter Bootstrap Saaten -> Ziehungen, 2.000 Zuege, Saat 4711; vor dem Lauf an der alten Tafel validiert, Abweichung <= 0,1 Punkte)
      parameter: Checkpoints Langlauf MV gross_gross_s<S>_s0..s7 von rechner-b; A = legal je Ziehung, B = geloeste 'einfache' Aufgaben unter den legalen, C = Aufgaben je Ziehung
      seed: Ziehungssaat 4711; Modellsaaten 1-3
      rechner: rechner-a (Ziehung und Auswertung)
      logs: rechner-a:~/snai_pruef/merkmal/sr/schach/kette.log, verlauf.jsonl, ziehungen.jsonl, mv_dump.jsonl, zwischen_dump.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/sr/schach/verlauf.jsonl und kette.log; Bootstrapwerte aus kriterien_lang_sr.txt (ERGEBNIS SCHACH)
  m1782 A Endstand s7 | 64,8 % | MV | 1 | 1000
  m1783 A Endstand s7 | 69,1 % | MV | 2 | 1000
  m1784 A Endstand s7 | 65,0 % | MV | 3 | 1000
  m1785 B Endstand s7 | 14,5 % | MV | 1 | 1000
  m1786 B Endstand s7 | 15,3 % | MV | 2 | 1000
  m1787 B Endstand s7 | 14,6 % | MV | 3 | 1000
  m1788 A gegen Leiter-d96 | 66,3 gegen 59,4 % (+11,6 % rel., KI [+3,4, +10,5] Punkte) | MV Saaten 1-3 |  | 3000
  m1789 B gegen Leiter-d96 | 14,8 gegen 14,3 % (+3,4 %, KI [-2,1, +3,0]) | MV Saaten 1-3 |  | 3000
  m1790 C gegen Leiter-d96 | 9,8 gegen 8,5 % (+15,2 %, KI [-0,5, +3,0]) | MV Saaten 1-3 |  | 3000
  m1791 A gegen alten grossen Lauf | 66,3 gegen 37,8 % (KI [+13,7, +38,4]) | MV Saaten 1-3 |  | 3000
  m1792 C gegen alten grossen Lauf | 9,8 gegen 5,0 % (KI [+2,3, +7,0]) | MV Saaten 1-3 |  | 3000
  m1793 B Segment 4 -> 8 | 9,9 -> 16,2 % (+6,3 Punkte, KI [-0,7, +13,0]) | MV | 1 | 300
  m1794 A je Segment 1..8 | 45,0 47,3 57,3 53,7 63,0 66,0 66,7 63,7 % | MV | 1 | 300
  m1795 Fehlerkanal engine_fehler | 0 (5 NET2NET-GUARD-Meldungen beim Laden, Waechter aus) | MV |  | 11
Ergebnis e152 [2026-10-21 19:24]: verfehlt
  Fazit: Nach Wortlaut der Kriteriendatei: Fall (2), Saettigung echt (Intervall-Lesart; die Punktwert-Lesart ergaebe Fall (3)). Ohne Kollaps bleibt die Loesbarkeit bei ~14,8 % stehen: mehr Material und Zeit heben sie nicht ueber die Leiter, die Saettigung ist echt. Die Form A dagegen steigt deutlich (+11,6 % gegen die Leiter, Intervall ohne Null). Das alte Urteil von snai/schach-gross, mehr Material verschlechtere die Form, war also der Embedding-Kollaps und kein Material- oder Zeiteffekt. Wer die Loesbarkeit heben will, muss am Modell oder an der Aufgabe drehen, nicht an der Datenmenge.
  Offen: Punktwert-Lesart des Anstiegs B 4 -> 8 (+63 % relativ) hielte die Saettigung fuer gerissen; nur die Intervall-Lesart traegt Fall (2). C gegen Leiter nicht belegt. Kontext-Messlatte C 23,3 % nicht erreicht.
  Datei: rechner-a:~/snai_pruef/merkmal/sr/kriterien_lang_sr.txt
Chronik:
  2026-10-21 19:23 angelegt (Nachtrag: Nachtrag in rechner-a:~/snai_pruef/merkmal/sr/kriterien_lang_sr.txt, 'NACHTRAG VOR DEN ERGEBNISSEN (2026-10-18 ~14:55, Langlauf laeuft, noch kein Segment fertig)'; ERGEBNIS SCHACH 2026-10-18 19:58)
  2026-10-21 19:23 Rezept r163
  2026-10-21 19:23 Status geplant -> laeuft (Rezept r163)
  2026-10-21 19:24 Messwerte m1782-m1795
  2026-10-21 19:24 Ergebnis e152: verfehlt
  2026-10-21 19:24 Status laeuft -> ausgewertet (Ergebnis e152)
```
