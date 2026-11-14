# snai/merkmal-gradrest

```text
snai/merkmal-gradrest - ausgewertet, begonnen 2026-10-17, angelegt 2026-10-21, zuletzt 2026-10-21 19:17
Frage: Bekommt der Rest (Spalten ausser c*) der anfaelligen Embedding-Zeilen zu wenig gleichgerichteten Gradienten, um gegen den Decay zu halten? Auswertung der BIASALLE-Gradienten-Dumps.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/zeilenintern/kriterien_gradrest.txt, Kopf '2026-10-17, VOR der Auswertung' (Auswertung ~10:53)):
  A_rest(r) = Median ueber c != c* von |mittel g| / sqrt(mittel g^2) ueber Bloecke zu 64 Positionen (Gegenprobe 256). Am gesunden Stand s4 je Saat (1 und 3), Zeilen >= 9 mit Vorkommen, tot = tot bei s5: AUC(lebend > tot). GESTUETZT: >= 0,85 in beiden Saaten; NICHT GESTUETZT: <= 0,65 in beiden; sonst kein Urteil. Plausibilitaet vorab: Spearman(A_rest, Rest-Median |E|) > +0,5 erwartet; <= 0,2 -> Hauptfrage nur berichtet. Rot-Proben: Permutation tot/lebend -> AUC ~0,5; Blockvorzeichen gekippt -> A ~ 1/sqrt(Blockzahl).
Baut auf: snai/merkmal-zeilenintern
Darauf baut: snai/merkmal-gegenhalt
Rezepte:
  r125 [2026-10-21] python3 ~/snai_pruef/merkmal/zeilenintern/gradrest.py
      quelltext: gradrest.py d85cba79
      parameter: Dumps biasalle/dump: orig s1_s4, grenze t60000, orig s3_s4, orig s2_s4; B 64 und 256
      seed: Permutation 4711
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/zeilenintern/gr/, gradrest_ergebnis.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/zeilenintern/gradrest_ergebnis.txt (abgelesen 2026-10-21)
  m1351 AUC(lebend > tot) A_rest B64 / B256 | 0,377 / 0,413 | orig s4 | 1 | 1
  m1352 AUC(lebend > tot) A_rest B64 / B256 | 0,287 / 0,286 | orig s4 | 3 | 1
  m1353 AUC A_rest B64 / B256 | 0,344 / 0,336 | GRENZE t60k | 1 | 1
  m1354 Plausibilitaet Spearman(A_rest, Rest-Median abs(E)) | -0,34 bis -0,48 | alle Saaten 1 und 3 |  | 6
  m1355 Rot Vorzeichen: A_rest echt / gekippt / Zufallserwartung | 0,033 / 0,044 / 0,051 | Rot | 1 | 1
  m1356 Rot Permutation AUC | 0,497 [0,349; 0,653] | Rot | 1 | 1000
  m1357 Anteil Ausgabeseite am Rest-Gradienten tot / lebend | 0,31 / 0,57 | Beobachtung | 1 | 1
  m1358 Anteil Ausgabeseite tot / lebend | 0,28 / 0,63 | Beobachtung | 3 | 1
Ergebnis e119 [2026-10-21 19:17]: keine_aussage
  Fazit: Formal 'nicht gestuetzt' (AUC <= 0,65), aber die Messung kann die Frage nicht beantworten: die Vorzeichen-Rot-Probe zeigt, dass auf den Rest-Spalten kein Signal ueber dem Rauschen liegt, und die Plausibilitaet ist negativ. Pruef-Dumps bei LR 0 taugen fuer Gleichgerichtetheit nicht; stattdessen den Adam-Zustand im Checkpoint lesen (snai/merkmal-gegenhalt). Belastbar ist nur die Beobachtung, dass die anfaelligen Zeilen ihren Rest-Gradienten ueberwiegend von der Eingangsseite bekommen.
  Datei: rechner-a:~/snai_pruef/merkmal/zeilenintern/kriterien_gradrest.txt
Chronik:
  2026-10-21 19:16 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/zeilenintern/kriterien_gradrest.txt, Kopf '2026-10-17, VOR der Auswertung' (Auswertung ~10:53))
  2026-10-21 19:16 Rezept r125
  2026-10-21 19:16 Status geplant -> laeuft (Rezept r125)
  2026-10-21 19:17 Messwerte m1351-m1358
  2026-10-21 19:17 Ergebnis e119: keine_aussage
  2026-10-21 19:17 Status laeuft -> ausgewertet (Ergebnis e119)
```
