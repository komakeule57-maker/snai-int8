# snai/knirps-plateau-schaerfen

```text
snai/knirps-plateau-schaerfen - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 14:31
Frage: Ist am Kopier-Plateau des Knirpses 16/2/8 die unscharfe Suche der Folge-Köpfe ursächlich? Eingriff: Scores der beiden Folge-Köpfe (Schicht 1) vor dem Softmax mal Faktor.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt, Abschnitt EINGRIFFSPROBE "unscharfe Suche" und Nachtrag (g) (2026-10-12, vor dem Lauf bzw. nach der Nachmessung). (Punkt 4),.):
  Modell 16/2/8 am Endstand (85 %), frische Fenster. UNSCHARFE SUCHE URSÄCHLICH, wenn Schärfen (Faktor 1,5 oder 2) die Quote um mindestens die halbe Lücke zum fortgesetzten Stand hebt (>= +3 Punkte) UND Weichen (0,5) sie senkt; unter 1 Punkt = nicht ursächlich; dazwischen Teilursache. Kontrollen: Faktor 1,0 = ohne Eingriff; Schicht 0 schärfen ohne Kriterium. Nachtrag (g) nach Nachmessung: die Halbe-Lücke-Schwelle gilt nur noch als Beschreibung; getesteter Satz: "Schärfen der Folge-Köpfe hebt die Quote; das 95-%-Intervall des Gewinns liegt über null."
Plan: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt
Baut auf: snai/knirps-plateau-fortsetzung
Darauf baut: snai/knirps-plateau-saaten, snai/knirps-plateau-lr-schaerfe
Rezepte:
  r86 [2026-10-21] ~/snai_pruef/knirps/muster/muster_eingriff.sh <ckpt> <marke> <fenster> <modus> <schicht> <kopf> [faktor]; Auswertung python3 muster/bootstrap.py <basis> <scharf> <forts>
      quelltext: Sonden-Bibliothek ~/snai_pruef/qk_pruef/libcortex_qk.so (patch_qk.py, SNAI_QK_MODUS=8, SNAI_QK_SCHARF), muster/bootstrap.py (5.000 Ziehungen ganzer Fenster)
      parameter: Stand 16/2/8 nach 60.000 Fenstern LR 0,001 (Plateau) gegen fortgesetzten Stand (4 Segmente LR 0,0001); Faktoren 0,5 / 1,0 / 1,5 / 2,0 / 3,0; Schicht 0 mal 2
      seed: Fenstersätze 777000111 und 424242 (je 300, zusammen 600)
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/muster/ep_basis_*, ep_scharf_*, ep_forts_*, ep_fortsscharf_*
      notiz: Prüfung beim Nachtrag: Bootstrap auf ep_basis/scharf/forts_beide.jsonl neu gerechnet: Werte. Faktoren-Dosis und Schicht 0 nicht nachgerechnet. Lief am revival-geprägten Stand.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/muster/ep_*_beide.jsonl mit muster/bootstrap.py nachgerechnet (Zeilen 1-5); Faktoren 0,5/1,5/3,0 und Schicht 0: nicht nachgerechnet
  m787 Rang 0 Basis / mal 2 / Fortsetzung (n = Fenster; 1 Lauf) | 85,08 / 88,21 / 91,26 % | 16/2/8 Plateau |  | 600
  m788 Gewinn Schärfen mal 2 (95 % KI) (n = Fenster; 1 Lauf) | +3,13 [2,82; 3,44] | 16/2/8 |  | 600
  m789 Lücke zur Fortsetzung (95 % KI) (n = Fenster; 1 Lauf) | +6,18 [5,66; 6,71] | 16/2/8 |  | 600
  m790 Anteil der Lücke (95 % KI) (n = Fenster; 1 Lauf) | 51 % [46; 56] | 16/2/8 |  | 600
  m791 Gewinn minus halbe Lücke (95 % KI) (n = Fenster; 1 Lauf) | +0,04 [-0,27; 0,33] | 16/2/8 |  | 600
  m792 Rang 0 Faktor 0,5 / 1,5 / 3,0 (n = Fenster; 1 Lauf) | 67,4 / 87,6 / 88,6 % | 16/2/8 |  | 300
  m793 Rang 0 Schicht 0 mal 2 (n = Fenster; 1 Lauf) | 84,95 % | 16/2/8 |  | 300
Ergebnis e74 [2026-10-21 14:31]: teilweise
  Fazit: Nach dem ursprünglichen Wortlaut: Schärfen hebt um +3,13 (über 3 Punkte) und Weichen senkt, also "ursächlich" - aber die Nachmessung zeigt, dass die halbe Lücke nicht abgesichert ist (Intervall von Gewinn minus halbe Lücke schließt null ein). Nach Nachtrag (g) bleibt der getestete Satz erfüllt: Schärfen hebt die Quote, Intervall über null. Die unscharfe Suche ist also eine Teilursache des Plateaus; die frühere Aufteilung "zwei Drittel Suche" ist zurückgenommen. Ein Modell, eine Saat; über Saaten siehe snai/knirps-plateau-saaten.
  Offen: Woher die andere Hälfte kommt: snai/knirps-plateau-tausch.
  Datei: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt
Chronik:
  2026-10-21 14:31 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt, Abschnitt EINGRIFFSPROBE "unscharfe Suche" und Nachtrag (g) (2026-10-12, vor dem Lauf bzw. nach der Nachmessung). (Punkt 4),.)
  2026-10-21 14:31 Rezept r86
  2026-10-21 14:31 Status geplant -> laeuft (Rezept r86)
  2026-10-21 14:31 Messwerte m787-m793
  2026-10-21 14:31 Ergebnis e74: teilweise
  2026-10-21 14:31 Status laeuft -> ausgewertet (Ergebnis e74)
```
