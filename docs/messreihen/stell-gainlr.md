# snai/stell-gainlr

```text
snai/stell-gainlr - ausgewertet, angelegt 2026-11-04, zuletzt 2026-11-04 13:04
Frage: Überträgt sich der float-Befund e512 (Gain-LR ×0,1: Gains sterben nicht, Held-out schlechter) auf die int8-Engine? Programm Stellräder, Auftrag 2026-11-04.
Kriterium (festgelegt 2026-11-04 11:39, vor dem ersten Messwert):
  Wortlaut: rechner-a ~/snai_pruef/stell/KRITERIEN_stell.md (md5 24531ffe, vor dem ersten Reihenlauf, mit Gerätetests und Prüfer), Abschnitte „Gemeinsamer Aufbau“, „Regeln“ und „Reihe 1“.
Arm GL (SNAI_GAIN_LR_MUL=0,1 auf rms_att und rms_ffn, nicht rms_final) gegen K. K1-Rezept 128x4, kurz9000, Saaten 4-11, Lib c5f9fbaf, rechner-a.
Urteil: ÜBERTRAG BESTÄTIGT, wenn die toten L2-Gains SENKT (≤ 0,5×K, < K in 6/8) UND der Held-out SCHLECHTER ist. WIDERLEGT, wenn KEIN EFFEKT auf die Gains oder der Held-out BESSER/GLEICH. Sonst OFFEN.
Kontrolle: Spanne der L2-ffn-Gains bei t1000 in GL kleiner als in K in 6/8.
Voraussetzung: K im Mittel ≥ 20 % tote L2-Gains.
Rezepte:
  r575 [2026-11-04] rechner-a ~/snai_pruef/stell: setsid -f nohup ./reihe_stell.sh (md5 43d2660b): je Arm/Saat lauf_stell.sh stell <ARM> - <s> daten/kurz9000.txt 1000,3000 mit CLIP_LR=0.003, CLIP_LIB=bau_stell/libcortex.so, Stellrad je Arm per Umgebung; danach gains_tot.php (Ende, t1000) nach log/stell_gains.jsonl. 9 Arme x 8 Saaten, 12 zugleich. Dieser Reihe gehören K und GL (SNAI_GAIN_LR_MUL=0.1).
      quelltext: Lib c5f9fbaf = Quelle b32ca8bc (wie 3475df5c) + patch_stell.py b83ce328; Trainer de34a553; lauf_stell.sh ecd0d42a
      parameter: K1: 128x4, voll int8, gebunden, SR, Clip 1, LR 0,003 konstant, WD 0,1, Warmup 500, 9.002 Schritte, ohne F, ohne LNS
      seed: s4-s11 über Sitzungsname clip_s<s>
      rechner: rechner-a
      logs: log/stell.log, log/stell_gains.jsonl, laeufe/stell/<ARM>_s<s>/
      notiz: Start 11:39. Gerätetests 1 und 2 grün (log/geraet_1.log, log/geraet.log), Rot-Probe gains_tot grün. Prüfer Gemini/Mistral in der Kriteriendatei.
Messwerte (Groesse | Wert | Arm | Start | n):
  m8745 Held-out GL-K Mittel | +0.1723 | 8/8 positiv, BS +0,158..+0,186, SCHLECHTER
  m8746 Tote L2-Gains GL | 0.0 | % Mittel, alle 8 Saaten 0; K 52,5 %, SENKT
  m8747 Kontrolle Spanne t1000 GL kleiner K | 8 | von 8 Saaten (6 noetig)
Ergebnis e523 [2026-11-04 13:04]: erfuellt
  Fazit: ÜBERTRAG BESTÄTIGT, nicht knapp. Gain-LR × 0,1 hält in int8 alle L2-FFN-Gains am Leben (0 % tot gegen 52,5 %), der Held-out wird um 0,17 schlechter (8/8). Das Gain-Sterben ist kein Defekt der 8-Bit-Engine, sondern dieselbe Lerndynamik wie in float (e512). Wiederbeleben ist keine Reparatur. Reichweite: 128x4, 9k, LR 0,003, ein Text, 8 Saaten, ein Stellwert.
  Datei: rechner-a ~/snai_pruef/stell/ERGEBNIS_stell_r1r2.md
Chronik:
  2026-11-04 11:39 angelegt
  2026-11-04 11:40 Rezept r575
  2026-11-04 11:40 Status geplant -> laeuft (Rezept r575)
  2026-11-04 13:04 Messwerte m8745-m8747
  2026-11-04 13:04 Ergebnis e523: erfuellt
  2026-11-04 13:04 Status laeuft -> ausgewertet (Ergebnis e523)
```
