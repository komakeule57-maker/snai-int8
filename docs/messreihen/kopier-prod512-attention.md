# snai/kopier-prod512-attention

```text
snai/kopier-prod512-attention - ausgewertet, begonnen 2026-10-09, angelegt 2026-10-21, zuletzt 2026-10-21 14:35
!! ohne Kriterium
Frage: Warum kopiert prod512 nicht: Wie sieht die Attention der 48 Köpfe von s0 bis s19 aus, und gibt es Induktionsbausteine (Vorgänger-Kopf, Kopf auf früheres gleiches Token)?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Baut auf: snai/kopier-prod512-s19
Darauf baut: snai/kopier-drohne-k-e, snai/prod512-gegenprobe-saettigung, snai/prod512b-lauf
Rezepte:
  r24 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben)
      parameter: prod512 s0-s19 (512/6/8, ctx 1024, int8; Training LR 0,001 konstant, ohne Warmup, ohne WD laut run_prod512.sh:103). Messung am echten Kern: Kopie von cortex.nim mit Ausgabezeilen (SNAI_CORTEX_LIB) bzw. SNAI_ATT_DUMP aus cortex_forward_i8; s19: 1024 Token, 4 Dokumente aus factory/holdout_prod; Röntgen: je Stand 6 volle Fenster aus ho_prod und 40 Posten x 4 Arme der Kopier-Sonde
      rechner: Laptop und rechner-b
      logs: Laptop:~/.cache/snai_pruef/vorwaerts/ und ~/.cache/snai_pruef/roentgen/ (out/s*.kenn.json, verlauf.txt, normen.txt); rechner-b:~/snai_pruef/roentgen/
      notiz: Skripte: Statistik je Checkpoint ~/.cache/snai_pruef/vorwaerts/statistik.py; Dumps neu mit ~/.cache/snai_pruef/roentgen/alle.sh N
Messwerte (Groesse | Wert | Arm | Start | n):
  m165 Anteil (Position, Kopf) mit größtem Gewicht > 0,99 | 89,5 % | s19
  m166 Logit-Spanne vor Softmax je Schicht L0..L5 | 2650 / 93 / 1550 / 1470 / 4600 / 9800 | s19
  m167 Harte Ein-Token-Zeiger (größtes Gewicht 0,99-1,00) | 47 von 48 Köpfen | s19 |  | 48
  m168 Vorgänger-Köpfe (Gewicht > 0,5 auf t-1) | 3, alle in L4/L5 (L5K0 0,92, L4K1 0,80, L5K2 0,64) | s19 |  | 48
  m169 Gewicht auf früherem gleichen Token oder Nachfolger | max 0,03-0,04 (Zufall 0,007) | s19
  m170 Duplikat (t-96) wieder minus fremd | max +0,007 Zufall / +0,011 Text | s19
  m171 Modellmittel größtes Gewicht | 0,926 / 0,984 / 0,991 / 0,994 / 0,991 / 0,979 | s0 / s1 / s3 / s6 / s12 / s19
  m172 Positivkontrolle handgesetzte W_q/W_k, Gewicht auf Token 96 zurück | 0,377 (Kontrolle 0,006); 896 zurück 0,036 | s19
  (Prüfagent Attention rückwärts, ho_prod.txt, Fenster 1024) und Gegenprobe (rechner-b, stand_messung_qq.php, 4 Fenster / 6 Paare); Kriterium dort vorab: |cos| < 0,02 = kein konsistentes Signal
  m1147 Paar-Kosinus Q/K-Gradient verschiedener Fenster | +0,015..+0,31 | s0
  m1148 Paar-Kosinus Q/K-Gradient verschiedener Fenster | -0,055..+0,010 | s6
  m1149 Paar-Kosinus Q/K-Gradient verschiedener Fenster | -0,042..+0,029 (Mittel -0,001) | s19
  m1150 Paar-Kosinus V/O/FFN / Embedding | +0,004..+0,16 / +0,21 | s19
  m1151 Q/K-Paare (Query, Kopf) mit 1 - sum w^2 > 0,01 | 11,3 % | s19
  m1152 Paar-Kosinus Q/K nach 1952 Schritten, Rezept B (LR 0,0003, Warmup 500) | 0,24-0,44 (FFN 0,41-0,50) | Gegenprobe B |  | 6
  m1153 Paar-Kosinus Q/K nach 1952 Schritten, Produktionsrezept (LR 0,001, kein Warmup) | -0,06..+0,09 (FFN 0,09-0,35) | Gegenprobe K |  | 6
Ergebnis e16 [2026-10-21 11:20]: beobachtung
  Fazit: Beide Bausteine der Induktion fehlen in prod512: Vorgänger-Köpfe sitzen zu spät (L4/L5), kein Kopf findet ein früheres Vorkommen; die Attention ist schon nach Segment 0 gesättigt (harte Ein-Token-Zeiger) und wächst danach monoton, getragen von den Q/K-Projektionen, nicht den Gains. Ein Rechenfehler im Vorwärtsweg ist per Rot-Probe und numpy-Referenz ausgeschlossen, und handgesetzte W_q/W_k zeigen, dass der Mechanismus Kopieren ausdrücken KANN. Damit liegt die Ursache im Training, nicht in der Architektur. Verdacht laut Eintrag (nicht belegt): Adam LR 0,001 konstant ohne Warmup und WD; gestützt später durch snai/kopier-mini-lr-batch und snai/kopier-mini-lr-reihe.
  Offen: Nicht geprüft: GPU-Zweige, FP32-Pfade, Backward. L1-Gain fällt von 0,94 auf 0,24 (Gegensteuern über den Gain = Vermutung). diagnose/snai_xray.php ist unbrauchbar (lehnt SNAI_V7 ab).
Chronik:
  2026-10-21 11:19 angelegt (Nachtrag: Nachgetragen 2026-10-21; kein Kriterium vorab im Eintrag (genannt sind nur die Messgrößen Logit-Spanne, Entropie, größtes Gewicht je Schicht, keine Schwelle))
  2026-10-21 11:19 Messwerte m165-m172
  2026-10-21 11:19 Status geplant -> laeuft (Messwerte m165-m172)
  2026-10-21 11:19 Rezept r24
  2026-10-21 11:20 Ergebnis e16: beobachtung
  2026-10-21 11:20 Status laeuft -> ausgewertet (Ergebnis e16)
  2026-10-21 14:35 Messwerte m1147-m1153
```
