# snai/merkmal-gegenhalt

```text
snai/merkmal-gegenhalt - ausgewertet, begonnen 2026-10-17, angelegt 2026-10-21, zuletzt 2026-10-21 19:17
Frage: Haelt der Adam-Zustand (m, v im Checkpoint) den Rest der anfaelligen Embedding-Zeilen schwaecher gegen den Decay als den der uebrigen?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/zeilenintern/kriterien_gegenhalt.txt, Kopf '2026-10-17, VOR der Rechnung' (Rechnung ~11:00)):
  H(r) = sum_c (-u_rc sign(w_rc)) / (wd sum_c |w_rc|) ueber c != c*, u = m^/(sqrt(v^)+1e-8). Am Stand s4 je Saat (1, 3): AUC(lebend > tot) von H. GESTUETZT >= 0,85 in beiden, NICHT GESTUETZT <= 0,65 in beiden, sonst kein Urteil. Plausibilitaet (Pflicht): Spearman(H(t), tatsaechliche log-Aenderung der Rest-Summe) > +0,5 erwartet; <= 0,2 -> H misst den Gegenhalt nicht, Hauptfrage nur berichtet. Rot: m-Vorzeichen gekippt -> H-Median ~0.
Baut auf: snai/merkmal-gradrest
Darauf baut: snai/merkmal-unterversorgung
Rezepte:
  r130 [2026-10-21] python3 ~/snai_pruef/merkmal/zeilenintern/gegenhalt.py
      quelltext: gegenhalt.py fcd9ef44 (E, m, v ueber load_v6_model_full)
      parameter: Original s1_s4, s3_s4, s2_s4; GRENZE t0, t20k, t60k, t70k, t80k
      seed: Rot 4711
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/zeilenintern/gh/, gegenhalt_ergebnis.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/zeilenintern/gegenhalt_ergebnis.txt (abgelesen 2026-10-21)
  m1405 Plausibilitaet Spearman(H, log Rest-Aenderung) | -0,053 / -0,034 / -0,053 | t0->20k / 60k->70k / 70k->80k | 1 | 3
  m1406 AUC(lebend > tot) H | 0,415 | orig s4 | 1 | 1
  m1407 AUC(lebend > tot) H | 0,487 | orig s4 | 3 | 1
  m1408 Rot H-Median echt / gekippt | -0,24 / -0,58 | Rot | 1 | 1
  m1409 Rest-Summe Median t0 -> Ende | 0,378 -> 0,325 (-14 %) | spaeter tot | 1 | 22
  m1410 Rest-Summe Median t0 -> Ende | 0,818 -> 0,526 (-36 %) | lebend | 1 | 56
  m1411 effektive Spaltenzahl t0 -> Ende | 27,3 -> 21,2 (lebend 36,2 -> 31,1) | spaeter tot | 1 | 22
Ergebnis e120 [2026-10-21 19:17]: keine_aussage
  Fazit: Die Messung kann die Frage nicht beantworten: H haengt nicht mit der tatsaechlichen Rest-Aenderung zusammen (Plausibilitaet ~ -0,05), weil m nur ~10 Schritte mittelt. Der Gegenbefund (ohne Vorab-Regel) korrigiert aber das Bild: die sterbenden Zeilen verlieren weniger Rest-Summe als die lebenden (-14 gegen -36 %); sie starten mit halb so viel Rest, und der Rest konzentriert sich auf weniger Spalten, sodass der Median unter die Stufe faellt. 'Der Decay erodiert die schwachen Zeilen schneller' ist fuer Saat 1 damit widerlegt.
  Offen: Die Nachfrage 'Unterversorgung in v' steht als eigene Reihe snai/merkmal-unterversorgung.
  Datei: rechner-a:~/snai_pruef/merkmal/zeilenintern/kriterien_gegenhalt.txt
Chronik:
  2026-10-21 19:17 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/zeilenintern/kriterien_gegenhalt.txt, Kopf '2026-10-17, VOR der Rechnung' (Rechnung ~11:00))
  2026-10-21 19:17 Rezept r130
  2026-10-21 19:17 Status geplant -> laeuft (Rezept r130)
  2026-10-21 19:17 Messwerte m1405-m1411
  2026-10-21 19:17 Ergebnis e120: keine_aussage
  2026-10-21 19:17 Status laeuft -> ausgewertet (Ergebnis e120)
```
