# snai/drohne-vo-nebenfund

```text
snai/drohne-vo-nebenfund - ausgewertet, begonnen 2026-10-13, angelegt 2026-10-21, zuletzt 2026-10-21 19:29
!! ohne Kriterium
Frage: Nebenfund im Drohnen-Versuch: Unterscheiden sich die Arme E (Ganzzahl), F (ohne Ganzzahl-Stack) und G in der Kontextnutzung (Kontext-Ablation) und im Anteil der V/O-Matrizen am Gradienten, und ab wann?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Plan: Gepaarte Kontext-Ablation (gleiche Fenster) F, G gegen E, P als Boden; V/O-Anteil aus der Telemetrie über Segment 0 und 1.
Baut auf: snai/kopier-drohne-float
Rezepte:
  r182 [2026-10-21] E, F, G, P: python3 blatt_belege/2026-10-13-kontext-gepaart.py
      quelltext: Kontext-Ablation der Mess-Bibliothek (Modus 0 bytegleich zum Original)
      parameter: nah=0 / nah=100000; 60 Fenster gepaart
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/blatt_belege/
      notiz: Reine Auswertung vorhandener Checkpoints.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/blatt_belege/2026-10-13-kontext-gepaart-F-G-gegen-E-P.txt, -drohne-vo-verlauf-s0.txt. Abnahme der Ablation: Modus 0 bytegleich, nah=100000 gleich Original, nah=0 gleich selbst.
  m2248 Kontextgewinn F-E Segment 1 | +0,2029 ±0,0107 | F gegen E |  | 60
  m2249 Fenster mit F-E > 0 Segment 1 | 60 von 60 | F gegen E |  | 60
  m2250 Kontextgewinn G-E Segment 1 | +0,2115 | G gegen E |  | 60
  m2251 Boden P-E Segment 1 | +0,0380 | P gegen E |  | 60
  m2252 V/O-Anteil am Gradienten Segment 1 | 37,7 % | E |  | 1
  m2253 V/O-Anteil am Gradienten Segment 1 | 24,8 % | F |  | 1
  m2254 V/O-Anteil am Gradienten Segment 1 | 26,0 % | G |  | 1
Ergebnis e171 [2026-10-21 19:29]: beobachtung
  Fazit: F und G nutzen den Kontext deutlich mehr als E (+0,20 gegen einen Boden von 0,04, in allen 60 Fenstern), und bei E trägt V/O einen um gut ein Drittel größeren Teil des Gradienten. Die Trennung entsteht zwischen 1.000 und 2.000 Schritten. Ohne Kriterium vorab und mit einer Saat je Arm ist das ein Hinweis, wo man bei der Float-Frage hinsehen sollte, keine Erklärung; ob der V/O-Anteil die Ursache der schwächeren Kontextnutzung ist, hat kein Eingriff geprüft.
  Offen: Ursache (kein isolierender Eingriff); weitere Saaten; Verlauf über Segment 1 hinaus.
  Datei: rechner-a:~/snai_pruef/blatt_belege/
Chronik:
  2026-10-21 19:28 angelegt (Nachtrag: Nachtrag 2026-10-21 aus Blatt-Einträgen 18 und 32; Belege rechner-a ~/snai_pruef/blatt_belege/2026-10-13-kontext-gepaart-F-G-gegen-E-P.txt und -drohne-vo-verlauf-s0.txt (mtime 2026-10-13 05:20 und 07:08). Kein Kriterium vorab.)
  2026-10-21 19:28 Rezept r182 (E, F, G, P)
  2026-10-21 19:28 Status geplant -> laeuft (Rezept r182)
  2026-10-21 19:28 Messwerte m2248-m2254
  2026-10-21 19:29 Ergebnis e171: beobachtung
  2026-10-21 19:29 Status laeuft -> ausgewertet (Ergebnis e171)
```
