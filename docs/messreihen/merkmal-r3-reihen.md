# snai/merkmal-r3-reihen

```text
snai/merkmal-r3-reihen - ausgewertet, begonnen 2026-10-16, angelegt 2026-10-21, zuletzt 2026-10-21 14:31
Frage: Ist das Muster, welche Feldzeilen ihre Aufloesung behalten (Reihen 6-8), schon im fruehen Stand s0 angelegt?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/diag/kriterien_runde3.txt, Kopf '2026-10-16 nachmittags, VOR den Laeufen; Pruefliste des Auditors' (Laeufe 13:29-13:41)):
  Teil D: je Saat Spearman des Zeilen-Stufenmedians bei s5 und s7 gegen (a) Zeilenmaximum, (b) Zeilennorm (L2), (c) Stufenmedian, jeweils bei s0, ueber die 64 Feldzeilen. |rho| >= 0,5 in allen 3 Saaten -> 'das Muster ist in s0 angelegt (Zusammenhang, keine Ursache)'; < 0,3 in allen -> 'haengt nicht daran'; sonst saatabhaengig.
Baut auf: snai/merkmal-r3-saat
Rezepte:
  r72 [2026-10-21] php ~/snai_pruef/merkmal/diag/reihen_s0.php (Befehlszeile nicht protokolliert), Auswertung in diag/r3/reihen/
      quelltext: reihen_s0.php 1765f53d
      parameter: Staende gross_gross_s{1,2,3}_s{0,5,7}, 64 Feldzeilen
      seed: -
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/diag/r3/reihen/auswertung.txt, s<S>_s<N>.json
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/diag/r3/reihen/auswertung.txt (abgelesen 2026-10-21)
  m726 rho Stufenmedian s5 gegen s0-Stufenmedian | +0,78 | Original | 1 | 64
  m727 rho Stufenmedian s7 gegen s0-Stufenmedian | +0,74 | Original | 1 | 64
  m728 rho Stufenmedian s5 gegen s0-Stufenmedian | +0,64 | Original | 2 | 64
  m729 rho Stufenmedian s7 gegen s0-Stufenmedian | +0,57 | Original | 2 | 64
  m730 rho Stufenmedian s5 gegen s0-Stufenmedian | +0,61 | Original | 3 | 64
  m731 rho Stufenmedian s7 gegen s0-Stufenmedian | +0,50 | Original | 3 | 64
  m732 rho s5/s7 gegen s0-Maximum | +0,46/+0,57 | Original | 1 | 64
  m733 rho s5/s7 gegen s0-Maximum | +0,03/+0,08 | Original | 2 | 64
  m734 rho s5/s7 gegen s0-Maximum | -0,53/-0,46 | Original | 3 | 64
  m735 rho s5/s7 gegen s0-Norm | +0,82/+0,78 | Original | 1 | 64
  m736 rho s5/s7 gegen s0-Norm | +0,80/+0,73 | Original | 2 | 64
  m737 rho s5/s7 gegen s0-Norm | +0,38/+0,32 | Original | 3 | 64
Ergebnis e69 [2026-10-21 14:31]: erfuellt
  Fazit: Gegen den s0-Stufenmedian liegt rho in allen drei Saaten bei >= 0,5 (einmal genau auf der Schwelle, 0,50): welche Feldzeilen spaeter Aufloesung behalten, ist frueh angelegt. Gegen Maximum und Norm ist es saatabhaengig. Das ist ein Zusammenhang, keine Ursache; spaeter zeigte snai/merkmal-zeilenintern dasselbe schaerfer (die spaeter toten Zeilen sind am gesunden Stand erkennbar und ueber die Saaten dieselben Token).
  Offen: Knapp erfuellt (Saat 3 s7 genau 0,50); nicht auf frischen Daten wiederholt.
  Datei: rechner-a:~/snai_pruef/merkmal/diag/kriterien_runde3.txt
Chronik:
  2026-10-21 14:30 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/diag/kriterien_runde3.txt, Kopf '2026-10-16 nachmittags, VOR den Laeufen; Pruefliste des Auditors' (Laeufe 13:29-13:41))
  2026-10-21 14:30 Rezept r72
  2026-10-21 14:30 Status geplant -> laeuft (Rezept r72)
  2026-10-21 14:30 Messwerte m726-m737
  2026-10-21 14:31 Ergebnis e69: erfuellt
  2026-10-21 14:31 Status laeuft -> ausgewertet (Ergebnis e69)
```
