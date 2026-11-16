# snai/fullint8-s0-probe

```text
snai/fullint8-s0-probe - ausgewertet, angelegt 2026-11-15, zuletzt 2026-11-15 17:08
Frage: Taugt die Rundungsmodus-Probe (SNAI_FP_RUNDUNG, patch_s0.py: fesetround in allen OpenMP-Fäden nur während cortex_train_step_i8) als Prüfgerät dafür, ob der int8-Trainingsschritt noch in float rechnet? Schritt S0 des Full-int8-Umbaus (Entscheidung des Autors 2026-11-15).
Kriterium (festgelegt 2026-11-15 17:06, vor dem ersten Messwert):
  Volltext docs/messreihen/fullint8/KRITERIEN_S0.txt (4eb6f16b), vor dem ersten Lauf. Knirps 96x2, kurze Eingabe (1000 Zeilen seg0), Rezept INT8_FULL, REST=sr, CPU, 2 Fäden, gleicher Ausgabename. K1 jeder Faden meldet den gesetzten Modus, Bits von 1/3 unter auf/ab verschieden (2 und 4 Fäden); K2 Modus naechster bytegleich zu ungesetzt; K3 ungesetzt zweimal bytegleich; K4 Rot: null, auf, ab je abweichend vom ungesetzten Lauf (heutiger Stand rechnet in float); K5 gepatchte Lib ungesetzt bytegleich zur Basis-Lib b445fbe4. Urteil erfuellt = K1-K5; sonst verfehlt. Grün ist erst ab S1 an einem ganzzahligen Teil zu sehen.
Plan: rechner-a:~/snai_pruef/fullint8/PLAN.md
Baut auf: snai/sr-knirps-nachweis
Darauf baut: snai/fullint8-st1-geruest
Rezepte:
  r720 [2026-11-15] cd ~/snai_pruef/fullint8 && ./probe_s0.sh <proj_s0|proj_basis> <name> <-|naechster|null|auf|ab> <faeden>   (Läufe: U1, U2 ungesetzt; N naechster; Z null; A auf; D ab; B proj_basis ungesetzt; A4 auf mit 4 Fäden)
      quelltext: proj_s0 = Hauptbaum 1a8edde + patch_s0.py (80fee343), cortex.nim cefc6f9c, libcortex.so 3c429f94; proj_basis libcortex.so b445fbe4 (= Hauptbaum-Lib, Baurezept nim c -d:danger --threads:on --passC:-fopenmp --passL:-fopenmp --passL:'-Wl,-rpath,' --app:lib); probe_s0.sh 562f9d37; Eingabe kurz_seg0.txt 1721c64b (1000 Zeilen seg0); Genesis gesch_gen_d96h6L2_s1; SNAI_INT8_FULL=1 SNAI_I8_REST=sr SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=25000 LR 0,001, CPU
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/fullint8/log/, Checkpoints ~/snai_pruef/fullint8/ergebnis/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: probe_s0.sh-Ausgabe und log/<name>.log (232 Schritte je Lauf)
  m11294 md5 Checkpoint ungesetzt | 0f79d04c | U1
  m11295 md5 Checkpoint ungesetzt Wiederholung | 0f79d04c | U2
  m11296 md5 Checkpoint Modus naechster | 0f79d04c | N
  m11297 md5 Checkpoint Modus null | af699c8d | Z
  m11298 md5 Checkpoint Modus auf | 3ba6f840 | A
  m11299 md5 Checkpoint Modus ab | 7e5c9439 | D
  m11300 md5 Checkpoint Basis-Lib b445fbe4 ungesetzt | 0f79d04c | B
  m11301 md5 Checkpoint Modus auf, 4 Fäden | 3ba6f840 | A4
  m11302 K1 FPPROBE je Faden | alle Fäden melden den gesetzten FE-Wert (2 und 4 Fäden); Bits 1/3: auf und naechster 1051372203, ab und null 1051372202 | Z,A,D,A4
  m11303 Fehlerkanal | je Lauf 1 Meldung, überall dieselbe bekannte (RESIDENT greift nicht, ohne CUDA-Lib) | alle
  m11304 Avg Loss (nur Protokoll) | 5,64408 (U1, N, B) / 5,64374 (Z) / 5,64698 (A) / 5,6466 (D) | alle
Ergebnis e675 [2026-11-15 17:08]: erfuellt
  Fazit: Das Prüfgerät taugt: Die Rundungsmodus-Probe erreicht jeden OpenMP-Faden, verändert im Modus naechster nichts und ist mit dem Patch ohne Schalter bytegleich zur Hauptbaum-Lib. Der heutige Stand fällt in allen drei anderen Modi rot aus. Ab S1 kann damit jeder umgebaute Teil auf „rechnet nicht mehr in float“ geprüft werden. Nebenbefund: Die Fadenzahl ändert den Checkpoint nicht (A und A4 gleich). Die Probe lässt sich also mit beliebig vielen Fäden fahren.
  Offen: Grün ist noch nicht gesehen. Dass die Probe einen ganzzahligen Teil als bytegleich durchlässt, zeigt sich erst ab S1. Dazu gehört die Gegenprobe „eine eingebaute float-Multiplikation wird rot“ im Hauptfaden, in einer OpenMP-Schleife und in einem AVX-Weg. Die Probe deckt nur cortex_train_step_i8 ab; andere zustandsändernde Aufrufe (Revival, Rescale) sind im Rezept aus.
Chronik:
  2026-11-15 17:06 angelegt
  2026-11-15 17:08 Rezept r720
  2026-11-15 17:08 Status geplant -> laeuft (Rezept r720)
  2026-11-15 17:08 Messwerte m11294-m11304
  2026-11-15 17:08 Ergebnis e675: erfuellt
  2026-11-15 17:08 Status laeuft -> ausgewertet (Ergebnis e675)
```
