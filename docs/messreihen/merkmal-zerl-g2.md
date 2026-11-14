# snai/merkmal-zerl-g2

```text
snai/merkmal-zerl-g2 - ausgewertet, begonnen 2026-10-17, angelegt 2026-10-21, zuletzt 2026-10-21 19:19
Frage: Bestaetigt sich der knappe ZERL-Arm G (Gradientenakkumulation float, F 4,2/4,2 %) mit zwei anderen Datenreihenfolgen, gepaart mit REIHE?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/zerl/kriterien_zerl_g2.txt, Kopf '2026-10-17, VOR dem Start' (Start ~14:30)):
  Zusammen mit den zwei alten G-Laeufen: G NOETIG BESTAETIGT = alle 4 neuen Laeufe (Saat 1 und 3, Reihenfolgen rA, rB) F < 5 %. NICHT BESTAETIGT = mindestens 2 der 4 F >= 15 %. Sonst kein Urteil, Rate berichten. Loss-Kontrolle 10 %. Gepaart berichtet gegen REIHE derselben Reihenfolge.
Baut auf: snai/merkmal-zerl, snai/merkmal-reihe
Rezepte:
  r139 [2026-10-21] bash ~/snai_pruef/merkmal/zerl/lauf_zerl_g2.sh <saat> <A|B> (SNAI_I8_INT_GRADACC=0, Ausgabename gross_gross_s<S>_s5_r<X>, sonst wie ZERL G)
      quelltext: Kopien knirps/proj_zerlG2_s<S><X> aus proj_zerl_basis, libcortex.so 28eeffe0; lauf_zerl_g2.sh a06e2b7d
      parameter: d96 Schach, ein Segment s4 -> s5 ab Original gross_gross_s<S>_s4 (adam_t 466470), LR 0,001 Cosinus bis 727208 (im Segment 3,57e-4 -> ~2e-4), Warmup 500, WD 0,1 ueberall, gebunden, int8 FULL, Revival und Lade-Waechter aus, CPU OMP 1
      seed: Saat 1 und 3, Reihenfolgen rA, rB
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/zerl/log_g2/, spaet/mess_zerlG2{A,B}_s<S>.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/spaet/mess_zerlG2*_s*.jsonl (am 2026-10-21 nachgelesen)
  m1537 F | 4,4 % (REIHE ohne G 26,4) | G, Reihenfolge A | 1 | 500
  m1538 F | 2,2 % (REIHE ohne G 35,4) | G, Reihenfolge B | 1 | 500
  m1539 F | 4,6 % (REIHE ohne G 39,4) | G, Reihenfolge A | 3 | 500
  m1540 F | 4,2 % (REIHE ohne G 44,6) | G, Reihenfolge B | 3 | 500
  m1541 tote Zeilen | 0 | G, alle 4 Saaten 1 und 3 |  | 4
  m1542 Loss gegen Original | -3,3 bis -4,2 % | G, alle 4 Saaten 1 und 3 |  | 4
Ergebnis e133 [2026-10-21 19:19]: erfuellt
  Fazit: G ist als noetiger Teil bestaetigt (6 von 6 unter 5 %, gepaart 22-40 Punkte unter dem Lauf ohne G). Das knappe Erfuellen ist kein Messzufall, sondern das Niveau von G: es verhindert Sprung und tote Zeilen, laesst aber einen Formfehler-Sockel von ~4 % (gesunde Originale 0-3,4 %). Als Abhilfe ist G deshalb und wegen +37 % Rechenzeit (snai/merkmal-prodtest) zweite Wahl.
  Datei: rechner-a:~/snai_pruef/merkmal/zerl/kriterien_zerl_g2.txt
Chronik:
  2026-10-21 19:19 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/zerl/kriterien_zerl_g2.txt, Kopf '2026-10-17, VOR dem Start' (Start ~14:30))
  2026-10-21 19:19 Rezept r139
  2026-10-21 19:19 Status geplant -> laeuft (Rezept r139)
  2026-10-21 19:19 Messwerte m1537-m1542
  2026-10-21 19:19 Ergebnis e133: erfuellt
  2026-10-21 19:19 Status laeuft -> ausgewertet (Ergebnis e133)
```
