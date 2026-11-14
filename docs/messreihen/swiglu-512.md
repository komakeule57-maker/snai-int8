# snai/swiglu-512

```text
snai/swiglu-512 - ausgewertet, angelegt 2026-11-12, zuletzt 2026-11-12 20:01
Frage: Liegt SwiGLU bei gleicher Parameterzahl bei Breite 512 (Zeichen, 512/L2/ctx256, Rezept r487) nach 1.000 Schritten auf der Karte vor SiLU, und in welchem Tempo?
Kriterium (festgelegt 2026-11-12 19:44, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/swiglu512/KRITERIEN_512.md (3a3ea010, Prüfer eingearbeitet). SI ffn 2048 gegen SG h=1360 (−0,4 % Parameter), Saaten 1–3, 1.000 Schritte (Warmup 100, Cosinus 1000), Held-out 300 Fenster heldout.txt am Endstand. D = SG − SI. VORN 3/3 negativ UND Mittel <= −0,02; HINTEN 3/3 positiv UND Mittel >= +0,02; GLEICH |Mittel| < 0,01 UND alle |D| < 0,02; sonst OFFEN; knapp (0,003 an Schwelle) -> heldout_frisch entscheidet. Tempo nur Nebengröße (SG-w_down unter der Kartenschwelle auf der CPU). Keine Aussage über lange Läufe.
Plan: rechner-b:~/snai_pruef/swiglu512/KRITERIEN_512.md
Baut auf: snai/swiglu-karte, snai/swiglu-knirps, snai/multistack-tiefe-512-ctx256
Darauf baut: snai/swiglu-512-lang
Rezepte:
  r700 [2026-11-12] rechner-b: cd ~/snai_pruef/swiglu512 && setsid nohup ./reihe512.sh > log/reihe512.out 2>&1 < /dev/null &   (PARALLEL Vorgabe 2)
      quelltext: reihe512.sh c07e26d6; Fork-Arbeitsbaum auf rechner-b (cortex.nim ac523520, Lib 689ce92b, libcortex_cuda.so d78a86ed); KRITERIEN_512.md 3a3ea010; Text t1000.txt 18ec19b6 (Anfang seg0); SI-Genesis ms_tiefe c_gen/gen_c_L2_s1-3, SG-Genesis f04de169/4c0d2db8/66775741
      parameter: r487: Zeichen 256, 512/8/ctx 256/L2, gebunden, int8 voll, GPU-Adam + GPU-Rückwärts, OMP 4, LR 0,001, WD 0,1; Warmup 100, SNAI_LR_DECAY_STEPS=1000; SG h=1360; Messung mess_text.php 300 Fenster heldout.txt ngram_bd.json, CPU
      seed: 1-3
      rechner: rechner-b, 2 zugleich (multi_stack-Prüfkette läuft parallel auf der CPU, Tempo dadurch verfälscht)
      logs: rechner-b:~/snai_pruef/swiglu512/log/reihe512.log, ergebnis512.jsonl, laeufe/*
Messwerte (Groesse | Wert | Arm | Start | n):
  m10770 ho SI s1 | 2.4978
  m10771 ho SG s1 | 2.4530
  m10772 ho SI s2 | 2.4841
  m10773 ho SG s2 | 2.4533
  m10774 ho SI s3 | 2.5022
  m10775 ho SG s3 | 2.4558
  m10776 D Mittel | -0.0407
  m10777 Laufzeit SI s (2 zugleich) | 151-158
  m10778 Laufzeit SG s (2 zugleich) | 192-202
Ergebnis e650 [2026-11-12 20:01]: erfuellt
  Fazit: SWIGLU VORN nach Wortlaut: D −0,045/−0,031/−0,046, Mittel −0,041, 3/3, nicht knapp; Kontrollen 6/6. Richtung wie am Knirps, Karte rechnet richtig. Nur 1.000 Schritte: am Knirps schrumpfte ein gleich großer Frühvorsprung (−0,041) auf −0,017. Tempo +28 % (w_down unter Kartenschwelle auf CPU, ungepaart), saubere Tempomessung steht aus. Vor einem längeren Lauf erst Kartenschwelle für w_down senken.
  Datei: rechner-b:~/snai_pruef/swiglu512/ERGEBNIS_512.md
Chronik:
  2026-11-12 19:44 angelegt
  2026-11-12 19:47 Rezept r700
  2026-11-12 19:47 Status geplant -> laeuft (Rezept r700)
  2026-11-12 20:01 Messwerte m10770-m10778
  2026-11-12 20:01 Ergebnis e650: erfuellt
  2026-11-12 20:01 Status laeuft -> ausgewertet (Ergebnis e650)
```
