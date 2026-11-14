# snai/stell-vreset

```text
snai/stell-vreset - ausgewertet, angelegt 2026-11-04, zuletzt 2026-11-04 13:04
Frage: Hilft ein periodischer voller Reset des Adam-Zustands (alle 300 Schritte m und v auf 0, Bias-Korrektur neu) dem 8-Bit-Training (nach Topollai, Choromanska 2026)?
Kriterium (festgelegt 2026-11-04 11:39, vor dem ersten Messwert):
  Wortlaut: rechner-a ~/snai_pruef/stell/KRITERIEN_stell.md (md5 24531ffe), Abschnitte „Gemeinsamer Aufbau“, „Regeln“, „Reihe 2“ und der Nachtrag Gerätetest 1. Dort explodierte der Reset nur von v (Loss 1557); vor jedem Reihenlauf wurde deshalb auf den vollen Reset umgestellt.
Arm VR (SNAI_V_RESET=300) gegen K, K1-Rezept 128x4, kurz9000, Saaten 4-11, Lib c5f9fbaf.
Held-out:
- HILFT bei BESSER (6/8 UND Mittel ≤ −0,02).
- SCHADET bei SCHLECHTER.
- KEIN NUTZEN bei GLEICH (|Mittel| < 0,01 UND |D| < 0,02 in 6/8).
- Sonst OFFEN.
Nebenurteil: tote L2-Gains nach der Gain-Regel.
Kontrolle: 30 Resets je Lauf.
Die Periode 300 ist frei gewählt.
Rezepte:
  r576 [2026-11-04] wie r(snai/stell-gainlr): rechner-a ~/snai_pruef/stell/reihe_stell.sh, Arme K und VR (SNAI_V_RESET=300, voller Reset von m und v).
      quelltext: Lib c5f9fbaf (patch_stell.py b83ce328, voller Reset nach Gerätetest 1)
      parameter: K1-Rezept, Periode 300
      seed: s4-s11
      rechner: rechner-a
      logs: log/stell.log, laeufe/stell/VR_s*
      notiz: Start 11:39 im selben Skript.
Messwerte (Groesse | Wert | Arm | Start | n):
  m8748 Held-out VR-K Mittel | +0.1387 | 8/8 positiv, BS +0,124..+0,154, SCHLECHTER
  m8749 Tote L2-Gains VR | 33.8 | % Mittel, je Saat 7,0 0,8 0,0 3,1 64,1 99,2 30,5 65,6; K 52,5 %, OFFEN
  m8750 Resets je Lauf | 30 | erster bei adam_t=300, K und VR bis Schritt 300 gleich
Ergebnis e524 [2026-11-04 13:04]: verfehlt
  Fazit: SCHADET, nicht knapp. Ein voller Adam-Reset (m und v) alle 300 Schritte kostet 0,14 nat Held-out (8/8). Die toten Gains sind saatabhängig, 0 bis 99 % (OFFEN). Der Moment-Reset aus Topollai, Choromanska 2026 ist als Reparatur für die 8-Bit-Engine verworfen. Damit ist nicht gezeigt, dass der Adam-Zustand unschuldig ist, nur dass dieses Gegenmittel schadet. Reichweite: 128x4, 9k, Periode 300, 8 Saaten.
  Datei: rechner-a ~/snai_pruef/stell/ERGEBNIS_stell_r1r2.md
Chronik:
  2026-11-04 11:39 angelegt
  2026-11-04 11:40 Rezept r576
  2026-11-04 11:40 Status geplant -> laeuft (Rezept r576)
  2026-11-04 13:04 Messwerte m8748-m8750
  2026-11-04 13:04 Ergebnis e524: verfehlt
  2026-11-04 13:04 Status laeuft -> ausgewertet (Ergebnis e524)
```
