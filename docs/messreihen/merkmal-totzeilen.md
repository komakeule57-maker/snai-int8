# snai/merkmal-totzeilen

```text
snai/merkmal-totzeilen - ausgewertet, begonnen 2026-10-17, angelegt 2026-10-21, zuletzt 2026-10-21 14:34
Frage: Sagt voraus, WELCHE Embedding-Zeilen tot sind (Anteil der Zieltoken im Pruefsatz mit toter Zeile, 'Totmasse'), ob ein Stand Formfehler hat?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/totzeilen/kriterien_totzeilen.txt, Kopf '2026-10-17, VOR der Messung' (Messung ~09:25)):
  T1 Totmasse (primaer) = Anteil der Ziel-Token in heldout_gross (2000 Zeilen) mit toter Zeile; T2 dasselbe nur Feld-Token. Je Groesse: GESTUETZT bei vollstaendiger Trennung FEHLER > GESUND (AUC 1); NICHT GESTUETZT bei AUC < 0,75; dazwischen kein Urteil. Zusatz: liegen die ZWISCHEN-Staende dazwischen? Rot/Gruen: Zaehlung muss quant_sonde reproduzieren. 22 Staende ohne Training: Originale gross_gross_s{1,2,3}_s4..s7, SPAET-Arme s{1,2,3}_s5..s7, wd0_s1_s5; FEHLER (F >= 15 %) 6, GESUND (F < 5 %) 13, ZWISCHEN (SPAET s3, 8-14 %) 3
Baut auf: snai/merkmal-verhaeltnis
Darauf baut: snai/merkmal-biasalle
Rezepte:
  r109 [2026-10-21] python3 ~/snai_pruef/merkmal/totzeilen/totzeilen.py (je Stand)
      quelltext: totzeilen.py 6352842f
      parameter: 22 Staende, heldout_gross.txt 2000 Zeilen
      seed: -
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/totzeilen/mess.jsonl, auswertung.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/totzeilen/auswertung.txt (abgelesen 2026-10-21)
  m1031 AUC T1 Totmasse | 1,000 (FEHLER min 0,172, GESUND max 0,120) | alle Saaten 1-3 |  | 19
  m1032 AUC T2 Feld-Totmasse | 1,000 (FEHLER min 0,362, GESUND max 0,254) | alle Saaten 1-3 |  | 19
  m1033 AUC Anzahl toter Zeilen (Gegenprobe, nicht vorab) | 1,000 (FEHLER min 22, GESUND max 14) | alle Saaten 1-3 |  | 19
  m1034 T1 / tote Zeilen | 0,21-0,36 / 27-31 | ZWISCHEN SPAET s3 | 3 | 3
  m1035 Rot/Gruen tote Zeilen | 0/22/56/14 = quant_sonde | s1_s4, s1_s5, s1_s7, SPAET s1_s7 | 1 | 4
Ergebnis e100 [2026-10-21 14:34]: erfuellt
  Fazit: Nach Regel gestuetzt (T1 und T2 trennen vollstaendig), aber das Urteil ist wenig wert: die blosse Anzahl toter Zeilen trennt genauso, weil immer zuerst dieselben Felder sterben, und die ZWISCHEN-Staende (mehr Totmasse, weniger Fehler) widersprechen beiden als hinreichendem Praediktor. Tote Zeilen sind hier ein Begleitmerkmal; spaeter zeigte RAUSCHEN 30,6 % Formfehler bei 0 toten Zeilen (snai/merkmal-rauschen), also sind sie auch nicht notwendig. Fuer die Praxis bleibt: tote Zeilen sind ein brauchbarer Alarm, keine Erklaerung.
  Offen: Abhaengige Staende; Ursachentest per Eingriff (Zeilen gezielt toeten) nicht gemacht.
  Datei: rechner-a:~/snai_pruef/merkmal/totzeilen/kriterien_totzeilen.txt
Chronik:
  2026-10-21 14:33 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/totzeilen/kriterien_totzeilen.txt, Kopf '2026-10-17, VOR der Messung' (Messung ~09:25))
  2026-10-21 14:34 Rezept r109
  2026-10-21 14:34 Status geplant -> laeuft (Rezept r109)
  2026-10-21 14:34 Messwerte m1031-m1035
  2026-10-21 14:34 Ergebnis e100: erfuellt
  2026-10-21 14:34 Status laeuft -> ausgewertet (Ergebnis e100)
```
