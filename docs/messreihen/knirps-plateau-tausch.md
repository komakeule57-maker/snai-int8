# snai/knirps-plateau-tausch

```text
snai/knirps-plateau-tausch - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 14:33
Frage: Wo im Netz sitzt der Unterschied zwischen Kopier-Plateau P (16/2/8, LR 0,001, ~85 %) und fortgesetztem Stand F (vier Segmente LR 0,0001, ~91,5 %)? Gruppenweiser Gewichtstausch zwischen P und F.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt, Abschnitte KOMPONENTEN-TAUSCH, Nachtrag (j), (k), (m) (2026-10-12, jeweils vor dem Lauf).):
  tausch.php ersetzt in P die Gewichte je einer Gruppe byteweise durch die aus F (Gegenrichtung mitgemessen). EIN ORT, wenn eine Gruppe allein mindestens 80 % der Lücke P->F schließt; VERTEILT, wenn keine mehr als 50 % schließt; dazwischen Schwerpunkt. Werkzeugprüfung: leere Gruppe bytegleich, alle Gruppen = F, eine Gruppe ändert die Datei. Nachtrag (j) Norm oder Richtung der Einbettung (80 %-Regel), (k) kumulativer Tausch in vorab festgelegter Reihenfolge, Ort = kleinste Menge ab 80 %; (m) Ort stabil, wenn Dreiergruppe {emb, L0att, L1qk} in beiden Richtungen >= 80 %, Komplement < 20 % in beiden, und jede Zweiergruppe mindestens so gut wie ihre Einzelglieder; sonst "Schwerpunkt, kein abgegrenzter Ort". Jeweils frische Fenstersätze.
Plan: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt
Baut auf: snai/kopier-knirps-gitter
Rezepte:
  r97 [2026-10-21] php ~/snai_pruef/knirps/muster/tausch.php <basis> <spender> <aus> <gruppen>; Auswertung muster/tausch_auswert.py
      quelltext: muster/tausch.php (Layout aus tensor_io.php), tausch_auswert.py, bins.py
      parameter: Gruppen Einbettung (gebunden), rms_final, L0 Attention, L0 FFN, L1 Q/K, L1 V/O, L1 FFN, L1 rms; Teilgruppen emb_richtung / emb_norm
      seed: Fenstersätze 777000111, 31337, 271828 (Paar mit Revival), 4242 (Paar ohne Revival r0_g_d16h2_s2); je 300 Fenster, gepaarter Bootstrap
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/muster/t_*.jsonl, r_*.jsonl
      notiz: Prüfung beim Nachtrag: Nicht aus Rohdaten nachgerechnet. Werte aus vier früheren Einträgen; der letzte (ohne Revival) schwächt die früheren ab.
Messwerte (Groesse | Wert | Arm | Start | n):
 , nicht nachgerechnet
  m911 Einbettung P<-F / F<-P, Anteil der Lücke (Fenstersatz 777000111) | 52 % [43; 59] / 83 % [74; 93] | Paar mit Revival |  | 300
  m912 L1 V/O P<-F (Fenstersatz 777000111) | -42 % [-51; -34] | Paar mit Revival |  | 300
  m913 Einbettung nur Richtung / nur Betrag (Fenstersatz 31337) | 33 % / -9 % des Einbettungsgewinns | Paar mit Revival |  | 300
  m914 Kumulativ emb / +L0att / +L1qk (Fenstersatz 31337) | 54 % / 69 % / 86 % [80; 91] | Paar mit Revival |  | 300
  m915 Dreiergruppe P<-F / Komplement P<-F (Fenstersatz 271828) | 92 % [87; 98] / -46 % | Paar mit Revival |  | 300
  m916 Zweiergruppe emb+L1qk gegen emb allein (Fenstersatz 271828) | 49 % < 54 % (Regel 3 verletzt) | Paar mit Revival |  | 300
  m917 Einbettung P'<-F' / F'<-P' (Fenstersatz 4242) | 43 % [36; 50] / 87 % [80; 95] | Paar ohne Revival |  | 300
  m918 Dreiergruppe P'<-F' (Fenstersatz 4242) | 68 % [61; 74] | Paar ohne Revival |  | 300
Ergebnis e84 [2026-10-21 14:33]: teilweise
  Fazit: Weder ein Ort noch verteilt: die Einbettung trägt in beiden Paaren den größten Teil (43-54 % vorwärts, 82-87 % rückwärts), V/O der Kopier-Köpfe ist es nicht (Vermutung widerlegt), und die Gruppen sind stark aufeinander eingespielt. Auf dem revival-geprägten Paar erfüllte die Dreiergruppe Einbettung + L0-Attention + L1-Q/K die 80 %, als "Ort" nach (m) aber nur "Schwerpunkt"; auf dem sauberen Paar ohne Revival schließt sie nur 68 %. Gültig ist damit nur "Schwerpunkt Einbettung, verteilt über gekoppelte Gruppen"; die 86-92 %-Zahlen gelten nicht mehr (snai/kopier-knirps-gitter).
  Offen: Lesen oder Ausgeben der gebundenen Einbettung lässt sich so nicht trennen; zwei Paare, je eine Saat.
  Datei: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt
Chronik:
  2026-10-21 14:33 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt, Abschnitte KOMPONENTEN-TAUSCH, Nachtrag (j), (k), (m) (2026-10-12, jeweils vor dem Lauf).)
  2026-10-21 14:33 Rezept r97
  2026-10-21 14:33 Status geplant -> laeuft (Rezept r97)
  2026-10-21 14:33 Messwerte m911-m918
  2026-10-21 14:33 Ergebnis e84: teilweise
  2026-10-21 14:33 Status laeuft -> ausgewertet (Ergebnis e84)
```
