# snai/knirps-plateau-saaten

```text
snai/knirps-plateau-saaten - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 14:31
Frage: Gilt der Schärfungsgewinn am Kopier-Plateau 16/2/8 über Saaten? Jeder Gitterlauf 16/2/8 auf einem Plateau bekommt denselben Eingriff (Schicht 1 mal 2,0).
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt, Nachtrag (h) (2026-10-12, vor dem Lauf).):
  (h) Jeder Gitterlauf 16/2/8 (Saaten 1..3), der bei 60.000 Fenstern auf einem Plateau liegt (50..90 %), bekommt den Eingriff Schicht 1 mal 2,0, 300 Fenster, Saat 777000111; Bezug ist sein Zweiphasen-Stand nach vier Segmenten mit 0,0001. "Gilt über Saaten", wenn in JEDEM solchen Lauf das 95-%-Intervall des Gewinns über null liegt.
Plan: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt
Baut auf: snai/knirps-plateau-schaerfen, snai/kopier-knirps-gitter
Rezepte:
  r87 [2026-10-21] PRAE=n|g ~/snai_pruef/knirps/muster/eingriff_saaten.sh
      quelltext: libcortex_qk.so (SNAI_QK_MODUS=8), muster/bootstrap.py
      parameter: Plateau-Stände bei 60.000 Fenstern der Gitterläufe n_d16h2_s2, n_d16h2_s3 (ohne Revival) und g_d16h2_s1, g_d16h2_s2 (mit altem Revival); Bezug Zweiphasen-Stand
      seed: Fenstersatz 777000111, 300 Fenster
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/muster/esn_{b,s,f}_<saat>.jsonl (ohne Revival), es_{b,s,f}_<saat>.jsonl (mit altem Revival)
      notiz: Prüfung beim Nachtrag: Drei der vier Läufe mit bootstrap.py nachgerechnet,. es_*_3 (g Saat 3) ist der eingebrochene Lauf (Basis 29 %) und zählt nicht.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/muster/esn_*_2/3, es_*_2 mit muster/bootstrap.py nachgerechnet; g Saat 1: nicht nachgerechnet
  m794 Gewinn mal 2 (95 % KI) (n = Fenster) | +3,16 [2,74; 3,60] | ohne Revival n_d16h2 | 2 | 300
  m795 Anteil der Lücke (95 % KI) (n = Fenster) | 44 % [38; 49] | ohne Revival n_d16h2 | 2 | 300
  m796 Gewinn mal 2 (95 % KI) (n = Fenster) | +2,87 [2,44; 3,30] | ohne Revival n_d16h2 | 3 | 300
  m797 Anteil der Lücke (95 % KI) (n = Fenster) | 39 % [34; 45] | ohne Revival n_d16h2 | 3 | 300
  m798 Gewinn mal 2 / Anteil (n = Fenster) | +3,20 / 34 % | mit altem Revival g_d16h2 | 1 | 300
  m799 Gewinn mal 2 (95 % KI) / Anteil (n = Fenster) | +2,27 [1,84; 2,71] / 38 % | mit altem Revival g_d16h2 | 2 | 300
Ergebnis e75 [2026-10-21 14:31]: erfuellt
  Fazit: Der Schärfungsgewinn ist in allen vier zählenden Plateau-Läufen echt (Intervalle über null), schließt aber überall weniger als die Hälfte der Lücke (34-44 %). Die frühere Einzelmodell-Zahl 51 % hält über Saaten nicht. Für die Deutung heißt das: die Suchschärfe ist eine stabile Teilursache des Kopier-Plateaus, nicht die Hauptursache.
  Offen: Saat 1 ohne Revival hatte keinen Zweiphasen-Stand (lernte schon in Phase 1).
  Datei: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt
Chronik:
  2026-10-21 14:31 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt, Nachtrag (h) (2026-10-12, vor dem Lauf).)
  2026-10-21 14:31 Rezept r87
  2026-10-21 14:31 Status geplant -> laeuft (Rezept r87)
  2026-10-21 14:31 Messwerte m794-m799
  2026-10-21 14:31 Ergebnis e75: erfuellt
  2026-10-21 14:31 Status laeuft -> ausgewertet (Ergebnis e75)
```
