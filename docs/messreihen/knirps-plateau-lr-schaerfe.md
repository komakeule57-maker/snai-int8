# snai/knirps-plateau-lr-schaerfe

```text
snai/knirps-plateau-lr-schaerfe - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 14:31
Frage: Deutung des Auditors als Test am Kopier-Plateau 16/2/8: "Lernrate und Suchschärfe sind dieselbe Geschichte" - wird das Folge-Gewicht durch die Fortsetzung mit kleiner LR schärfer, und bringt Schärfen am fortgesetzten Stand kaum noch etwas?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt, Nachtrag (i) (2026-10-12, vor dem Lauf).):
  (i) GESTÜTZT, wenn (1) das mittlere Folge-Gewicht der Kopier-Köpfe am fortgesetzten Stand (LR 0,0001, vier Segmente) höher liegt als am Plateau-Stand und das Intervall der Differenz über null liegt, UND (2) Schärfen mal 2,0 am fortgesetzten Stand weniger als ein Drittel des Gewinns am Plateau-Stand bringt. NICHT GESTÜTZT, wenn das Folge-Gewicht nicht steigt oder Schärfen am fortgesetzten Stand etwa gleich viel bringt (mehr als zwei Drittel).
Plan: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt
Baut auf: snai/knirps-plateau-schaerfen
Rezepte:
  r88 [2026-10-21] ~/snai_pruef/knirps/muster/muster_eingriff.sh <ckpt> <marke> 300 8 1 <kopf> <faktor>
      quelltext: libcortex_qk.so mit Mitschnitt nach dem Eingriff (SNAI_ATT_DUMP), geprüft bytegleich zu roentgen/libcortex_rx.so ohne Eingriff
      parameter: Plateau-Stand und fortgesetzter Stand 16/2/8; Faktoren 0,5 bis 3,0
      seed: Fenstersatz 777000111, 300 Fenster
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/muster/ep_*_777000111.jsonl, ep_fortsscharf_777000111.jsonl
      notiz: Prüfung beim Nachtrag: Nicht nachgerechnet; Urteil aus den früher festgehaltenen Zahlen nach dem Wortlaut von (i) abgeleitet: Teil (2) 1,27 / 3,40 = 37 % > ein Drittel -> nicht GESTÜTZT, aber auch nicht "mehr als zwei Drittel" -> nach Wortlaut weder gestützt noch ausdrücklich nicht gestützt; der frühere Befund sagt "nur zum kleinen Teil". Das Kriterium hat für den Zwischenbereich kein Urteil, daher keine_aussage; das Intervall für Teil (1) fehlt ohnehin.
Messwerte (Groesse | Wert | Arm | Start | n):
 , nicht nachgerechnet
  m800 Folge-Gewicht -> Rang 0, ohne Eingriff (n = Fenster; 1 Lauf) | 0,801 -> 85,07 % | Plateau |  | 300
  m801 Folge-Gewicht -> Rang 0, mal 2,0 (n = Fenster; 1 Lauf) | 0,876 -> 88,47 % | Plateau |  | 300
  m802 Folge-Gewicht -> Rang 0, mal 3,0 (n = Fenster; 1 Lauf) | 0,893 -> 88,58 % | Plateau |  | 300
  m803 Folge-Gewicht -> Rang 0, ohne Eingriff (n = Fenster; 1 Lauf) | 0,826 -> 91,5 % | fortgesetzt |  | 300
  m804 Folge-Gewicht -> Rang 0, mal 2,0 (n = Fenster; 1 Lauf) | 0,903 -> 92,77 % | fortgesetzt |  | 300
Ergebnis e76 [2026-10-21 14:31]: keine_aussage
  Fazit: Nach dem Wortlaut nicht entschieden, Teil (2) liegt zwischen den Schwellen: Schärfen bringt am fortgesetzten Stand +1,3 Punkte gegen +3,4 am Plateau, mehr als ein Drittel und weniger als zwei Drittel. Das Folge-Gewicht steigt durch die Fortsetzung nur wenig (0,801 -> 0,826), und der Plateau-Stand erreicht selbst künstlich auf 0,893 geschärft nur 88,6 % statt 91,5 %. Lernrate und Suchschärfe sind also nur zum kleinen Teil dieselbe Geschichte. Die Schätzung "rund 1,2 Punkte durch Suche" aus dieser Probe (Interpolation) ist später ersetzt (Minderheit, 20-40 %).
  Offen: Intervall der Gewichtsdifferenz (Teil 1) nicht berichtet.
  Datei: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt
Chronik:
  2026-10-21 14:31 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt, Nachtrag (i) (2026-10-12, vor dem Lauf).)
  2026-10-21 14:31 Rezept r88
  2026-10-21 14:31 Status geplant -> laeuft (Rezept r88)
  2026-10-21 14:31 Messwerte m800-m804
  2026-10-21 14:31 Ergebnis e76: keine_aussage
  2026-10-21 14:31 Status laeuft -> ausgewertet (Ergebnis e76)
```
