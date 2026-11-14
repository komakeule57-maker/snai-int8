# snai/gpu-adam-seg256

```text
snai/gpu-adam-seg256 - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:31
Frage: Rechnet der GPU-Adam über ein ganzes Segment (Textrezept 256/16, ~4996 Schritte) bitgleich zur CPU in 3/3 Saaten, und ist er in 3/3 Saaten mindestens 10 % schneller als Arm A?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus der Kriteriendatei (mtime 2026-10-14 07:08, erste Läufe 07:22) und out/seg256*.):
  Vorab rechner-b ~/snai_pruef/cuda_i8/kriterien_seg256.txt (2026-10-14, vor dem ersten Lauf): bitgleich = md5, alle Step-Zeilen und Telemetrie-Zeilen gleich R derselben Saat; Aufrufnachweis; ROT muss abweichen. Tempo B gegen A gepaart: 3/3 >= 10 % schneller = 'schneller', alle ±10 % = Gleichstand, sonst 'uneinig'; Lastregel (Unterschied > 1,0 -> Paar verdächtig). Übernahme-Empfehlung, wenn bitgleich 3/3, Nachweis, ROT, 'schneller'.
Plan: rechner-b:~/snai_pruef/cuda_i8/kriterien_seg256.txt (je Saat R, A, B verschränkt, danach ROT mit Saat 1)
Baut auf: snai/gpu-adam-messkopie
Darauf baut: snai/gpu-adam-projekt, snai/gpu-adam-sr
Rezepte:
  r196 [2026-10-21] R, A, B, ROT: bash seg256.sh
      quelltext: bau_gpuadam ac572ca2 + lib_gpuadam a1b7f2bb (Projektbaum 314a7c26 + patch_prof_i8 + patch_gpu_adam)
      parameter: Textrezept 256/16 (text_gen_d256h16), Segment 10 (text_c64_seg10.txt), Basis s9 der Reihe, LR 0,001, Boden 0,0001, SNAI_LR_DECAY_STEPS=99880, Warmup 500, OMP 1, Revival aus
      seed: 1, 2, 3
      rechner: rechner-b (RTX 3050)
      logs: rechner-b:~/snai_pruef/cuda_i8/out/seg256/
      notiz: Ausgabename = Name der Reihe (text_tx_d256h16_fall_sN_s10.snai) für gleiche Fensterfolge.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/cuda_i8/out/seg256*; Basis- und Reihen-md5 je Saat im Kopf von out/seg256.txt; Last 2,2 bis 2,7, kein Paar über 1,0 Unterschied
  m2355 md5, Step- und Telemetrie-Zeilen gleich R | ja | B | 1 | 1
  m2356 md5, Step- und Telemetrie-Zeilen gleich R | ja | B | 2 | 1
  m2357 md5, Step- und Telemetrie-Zeilen gleich R | ja | B | 3 | 1
  m2358 Wandzeit Segment | 274 s | B | 1 | 1
  m2359 Wandzeit Segment | 276 s | B | 2 | 1
  m2360 Wandzeit Segment | 274 s | B | 3 | 1
  m2361 Wandzeit Segment | 553 s | A | 1 | 1
  m2362 Wandzeit Segment | 556 s | A | 2 | 1
  m2363 Wandzeit Segment | 554 s | A | 3 | 1
  m2364 Wandzeit B gegen A | -50,5 % | B gegen A |  | 3
  m2365 md5 und Steps gleich R | ja | A | 1 | 1
  m2366 md5 und Steps gleich R | ja | A | 2 | 1
  m2367 md5 und Steps gleich R | ja | A | 3 | 1
  m2368 R gegen Segment 10 der Reihe | md5 und Steps gleich | R | 1 | 1
  m2369 R gegen Segment 10 der Reihe | md5 und Steps gleich | R | 2 | 1
  m2370 R gegen Segment 10 der Reihe | md5 und Steps gleich | R | 3 | 1
Ergebnis e184 [2026-10-21 19:31]: erfuellt
  Fazit: Bitgleich in allen drei Saaten über ein ganzes Segment und halbe Wandzeit in jeder Saat: der GPU-Adam erfüllt alle Bedingungen der vorab festgelegten Übernahme-Empfehlung. Dass R auch dem Segment 10 der alten Reihe gleicht, zeigt nebenbei, dass der Projektbaum das Produktionsrezept unverändert rechnet.
  Offen: Moduswechsel/Neuladen im laufenden Prozess (in snai/gpu-adam-projekt geprüft).
  Datei: rechner-b:~/snai_pruef/cuda_i8/kriterien_seg256.txt
Chronik:
  2026-10-21 19:30 angelegt (Nachtrag: Nachtrag 2026-10-21 aus der Kriteriendatei (mtime 2026-10-14 07:08, erste Läufe 07:22) und out/seg256*.)
  2026-10-21 19:31 Rezept r196 (R, A, B, ROT)
  2026-10-21 19:31 Status geplant -> laeuft (Rezept r196)
  2026-10-21 19:31 Messwerte m2355-m2370
  2026-10-21 19:31 Ergebnis e184: erfuellt
  2026-10-21 19:31 Status laeuft -> ausgewertet (Ergebnis e184)
```
