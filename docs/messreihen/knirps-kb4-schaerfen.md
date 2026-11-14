# snai/knirps-kb4-schaerfen

```text
snai/knirps-kb4-schaerfen - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 14:33
Frage: Ist beim Kopier-Knirps 32/8/4 (Kopfbreite 4, 50-%-Stand) die Schärfe der Suche in Schicht 1 der Engpass? Eingriff: Attention-Scores einer Schicht mal Faktor.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt, Abschnitt (t) (2026-10-12, vor dem Lauf).):
  (t) Stände n_d32h8_s{1,2,3}_zp_s239; SNAI_QK_MODUS=8, alle Köpfe der Schicht, 300 frische Fenster (Saat 424242), gepaarter Bootstrap 95 %. Arme: Basis; Schicht 1 mal 0,5 / 1,5 / 2 / 3 / 4; Schicht 0 mal 2. Bezug für die Lücke: gelernter n_d32h4_s1_s4 auf denselben Fenstern. GESTÜTZT, wenn in Saat 1 und 2 der beste Faktor mindestens die halbe Lücke schließt (untere Grenze von Gewinn - Lücke/2 > 0) UND mal 0,5 verliert. NICHT GESTÜTZT, wenn der beste Faktor weniger als ein Viertel der Lücke schließt. Dazwischen Teilursache. Bester Faktor auf zweitem frischem Satz (31337) bestätigen, dort gilt der Wert. Vorhersage: in Saat 3 hilft Schicht 0 schärfen mehr. Mechanik-Kontrolle: Folge-Gewichte steigen mit dem Faktor.
Plan: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt
Baut auf: snai/knirps-kb4-muster
Rezepte:
  r100 [2026-10-21] ~/snai_pruef/knirps/muster/schaerf_h8.sh; Auswertung python3 muster/bootstrap.py <basis> <eingriff> <bezug>
      quelltext: libcortex_qk.so (SNAI_QK_MODUS=8), muster/bootstrap.py
      parameter: siehe Kriterium
      seed: Fenstersätze 424242 (sh8a_*) und 31337 (sh8b_*), je 300
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/muster/sh8a_*.jsonl, sh8b_*.jsonl
      notiz: Prüfung beim Nachtrag: Bootstrap auf sh8a_s{1,2,3} (Faktor 2, 0,5, Schicht 0) und sh8b_s1 neu gerechnet,. Lade-Wächter-Vorbehalt wie snai/knirps-kb4-muster.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/muster/sh8a_*/sh8b_* mit muster/bootstrap.py nachgerechnet; Saat 2/3 der Bestätigung und Mechanik: nicht nachgerechnet
  m927 Gewinn Schicht 1 mal 2 (95 % KI) (Fenstersatz 424242) | +2,03 [1,41; 2,65] | 32/8/4 | 1 | 300
  m928 Gewinn Schicht 1 mal 2 (95 % KI) (Fenstersatz 424242) | +1,61 [0,99; 2,26] | 32/8/4 | 2 | 300
  m929 Gewinn Schicht 1 mal 2 (95 % KI) (Fenstersatz 424242) | -0,73 [-1,26; -0,20] | 32/8/4 | 3 | 300
  m930 Lücke zum Bezug, Punkte (Fenstersatz 424242) | 43,5 / 48,7 / 59,9 | 32/8/4 | 1/2/3 | 300
  m931 Gewinn Schicht 1 mal 0,5 (Fenstersatz 424242) | -14,87 / -13,02 / -4,72 | 32/8/4 | 1/2/3 | 300
  m932 Gewinn Schicht 0 mal 2 (Fenstersatz 424242) | -5,74 / -10,28 / -6,78 | 32/8/4 | 1/2/3 | 300
  m933 Bestätigung Schicht 1 mal 2 (Fenstersatz 31337) | +1,41 (Saat 1, Anteil 3 %) / +1,0 / -0,7 | 32/8/4 | 1/2/3 | 300
  m934 Folge-Gewicht mal 4 (Mechanik) (n = Fenster) | 0,32-0,39 -> 0,37-0,52, Entropie 1,3 -> 0,35 | 32/8/4 | 1 | 60
Ergebnis e87 [2026-10-21 14:33]: verfehlt
  Fazit: Nicht gestützt: der beste Faktor schließt höchstens 5 % der Lücke (Schwelle für "nicht gestützt" 25 %), in Saat 3 schadet er; Schicht 0 schärfen schadet überall (Vorhersage für Saat 3 widerlegt). Die Köpfe bei Kopfbreite 4 sind nicht unscharf, sondern zeigen in rund der Hälfte der Abfragen auf die falsche Stelle (Deutung, nicht gemessen). Für Kopierversuche bleibt die Folgerung aus dem Gitter: Kopfbreite >= 8.
  Offen: Anteil der Abfragen, deren Maximum auf der Folge-Stelle liegt (Trennschärfe), nicht gemessen.
  Datei: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt
Chronik:
  2026-10-21 14:33 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt, Abschnitt (t) (2026-10-12, vor dem Lauf).)
  2026-10-21 14:33 Rezept r100
  2026-10-21 14:33 Status geplant -> laeuft (Rezept r100)
  2026-10-21 14:33 Messwerte m927-m934
  2026-10-21 14:33 Ergebnis e87: verfehlt
  2026-10-21 14:33 Status laeuft -> ausgewertet (Ergebnis e87)
```
