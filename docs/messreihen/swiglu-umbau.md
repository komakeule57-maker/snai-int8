# snai/swiglu-umbau

```text
snai/swiglu-umbau - ausgewertet, angelegt 2026-11-12, zuletzt 2026-11-12 16:04
Frage: Rechnet der SwiGLU-Umbau im Fork Snai_int8_swiglu richtig: SiLU-Arm bytegleich zum Original, SwiGLU-Gradient gleich PyTorch-Autograd?
Kriterium (nachgetragen, Beleg: Kriterium stand vor dem Lauf in ~/Projekte/Snai_int8_swiglu/FORK.md (Vorgehen 1+2, 2026-11-12) und in snai/gradient-tiefe (Pfad I); ins Messbuch erst nach dem Lauf eingetragen.):
  G (Gleichheit): SiLU-Modell 64x4, 99 Schritte INT8_FULL CPU, Ausgabe-md5 neue Lib+PHP == Original (git archive HEAD 73620b8 + libcortex c553f412); Rot: SNAI_I8_SILU_EXP=ROT muss md5 aendern. D (Gradient): wie snai/gradient-tiefe Pfad I unveraendert: cos >= 0,95 und |r/Median-r - 1| <= 10 % an Tensoren mit Norm >= 1e-3 x groesste, an SwiGLU-Genesis und nach 99 SwiGLU-Schritten (V7-Rundlauf); Rot: Torch mit getauschtem g/u muss reissen. SiLU-Genesis als Bezug.
Baut auf: snai/gradient-tiefe
Darauf baut: snai/swiglu-knirps, snai/swiglu-karte
Rezepte:
  r697 [2026-11-12] cd ~/snai_pruef/swiglu && ./gleich.sh alt $PWD/lib_alt.so; ./gleich.sh neu $PWD/lib_neu.so; ./gleich.sh neu $PWD/lib_neu.so SNAI_I8_SILU_EXP=ROT; ./gd.sh
      quelltext: Fork-Arbeitsbaum (nicht committet): cortex.nim 1d03637c -> lib_neu bd669325; init_base.php c732edad, tensor_io.php 576cbe8f, train_worker.php ff66bfb7; Dump-Lib = cortex.nim + patch_gd.py (gd/cortex.nim 97e1d46e, libcortex_gd fbc183bd); vergleich_swi.py a42cb6cc (aus vergleich.py + torch_knirps.py per assert, mach_vergleich.py); gd.sh f0cfab5e, gleich.sh 0ebcebd6
      parameter: 64x4 ctx 128, SiLU ffn 256 (gen_a4), SwiGLU h=176 (gen_s4, SNAI_SWIGLU=1), Saat 4, Koepfe 4, kurz.txt = erste 40.000 Byte kurz600.txt, LR 0,001, Warmup 50, Tie, INT8_FULL, 1 Fenster je Dump
      rechner: rechner-a, CPU, OMP 2
      logs: rechner-a:~/snai_pruef/swiglu/erg.jsonl, log/, d/, log_alt.log, log_neu.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: gleich.sh-Ausgabe; erg.jsonl ausgewertet nach Kriterium D
  m10695 Ausgabe-md5 nach 99 Schritten | c0e57348 | alt | 4 | 1
  m10696 Ausgabe-md5 nach 99 Schritten | c0e57348 | neu | 4 | 1
  m10697 Ausgabe-md5 Rot SILU_EXP=ROT | 5ece9514 | neu | 4 | 1
  m10698 cos min, rr Bereich, reissen | 0,9997, 0,997-1,004, 0/30 | SiLU Genesis | 4 | 1
  m10699 cos min, rr Bereich, reissen | 0,9998, 0,994-1,002, 0/30 | SwiGLU Genesis | 4 | 1
  m10700 cos min, rr Bereich, reissen | 0,9959, 0,987-1,045, 0/32 | SwiGLU 99 Schritte | 4 | 1
  m10701 cos min, rr Bereich, reissen | 0,2874, 0,418-1,421, 32/32 | Rot g/u getauscht | 4 | 1
  m10702 V7-Flags nach SwiGLU-Training | 5 | SwiGLU 99 Schritte | 4 | 1
Ergebnis e646 [2026-11-12 16:04]: erfuellt
  Fazit: Der Umbau ist als Werkzeug brauchbar: Ohne SwiGLU rechnet der Fork bytegleich wie der Hauptbaum, mit SwiGLU stimmt der Gradient mit Autograd überein, auch nach Speichern und Laden über V7 mit Bit 2. Der nächste Schritt ist der Knirps-Vorversuch SiLU gegen SwiGLU mit Kriteriendatei und Prüfer. Die Rechenfrage ist damit nicht mehr offen, die Qualitätsfrage noch ganz.
  Offen: Nur je 1 Fenster und 1 Saat, nur 64x4, nur CPU (Karte, LoRA, FP32, Wachstum sind gesperrt, nicht umgebaut). Bytegleichheit nur für den INT8_FULL-Weg mit SiLU-Tabelle geprüft. Rot nur Torch-seitig. Die Genesis-Skala der SwiGLU-Zweige (beide 0,02) ist eine ungeprüfte Wahl und gehört in die Kriterien des Vorversuchs. Keine Tempo-Messung (SwiGLU-Zweig ohne Tabelle und seriell).
Chronik:
  2026-11-12 16:04 angelegt (Nachtrag: Kriterium stand vor dem Lauf in ~/Projekte/Snai_int8_swiglu/FORK.md (Vorgehen 1+2, 2026-11-12) und in snai/gradient-tiefe (Pfad I); ins Messbuch erst nach dem Lauf eingetragen.)
  2026-11-12 16:04 Rezept r697
  2026-11-12 16:04 Status geplant -> laeuft (Rezept r697)
  2026-11-12 16:04 Messwerte m10695-m10702
  2026-11-12 16:04 Ergebnis e646: erfuellt
  2026-11-12 16:04 Status laeuft -> ausgewertet (Ergebnis e646)
```
