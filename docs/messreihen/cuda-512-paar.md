# snai/cuda-512-paar

```text
snai/cuda-512-paar - ausgewertet, begonnen 2026-10-13, angelegt 2026-10-21, zuletzt 2026-10-21 19:30
Frage: Rechnet der CUDA-Pfad bei Breite 512 (Textrezept, 2 Segmente) richtig: Held-out nach Segment 0 und 1 gegen den CPU-Zwilling unter 10 % Abstand, kein NaN, rc 0?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus der Kriteriendatei.):
  Vorab rechner-b ~/snai_pruef/knirps_gpu/text/kriterien.txt Abschnitt 'BREITE 512 AUF DER GPU' (2026-10-13): (1) Held-out nach Segment 0 und 1 gegen CPU-Zwilling unter 10 % = gleichwertig, kein NaN, rc 0; (2) Tempo je Segment ohne Schwelle; (3) Vergleich mit 32/64 nur Beobachtung. Gepaart über gleichen Laufnamen, 1 Saat.
Plan: Ganzzahl-Paar (proj_voll mit SNAI_I8_GPU_BACKWARD=1 gegen proj_cpu) und Gleitkomma-Paar (dtype 1), je 2 Segmente.
Baut auf: snai/cuda-i8-anschluss
Rezepte:
  r188 [2026-10-21] tx_d512h8_s1 (Ganzzahl), tx_d512h8_fp_s1 (Gleitkomma): lauf_gpu.sh / lauf_gpu_fp.sh (knirps_gpu)
      quelltext: knirps_gpu/proj_voll gegen proj_cpu (Vollpatch CUDA)
      parameter: 512/8, 2 Schichten, ffn 2048, ctx 64, Zeichen-Vokabular, LR 0,001 -> 0,0001 über 9988 Schritte, Warmup 500, WD 0,1, gebunden, Revival aus, 4 Threads
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/knirps_gpu/log/<projekt>/
      notiz: Karte mit fremdem tdc_v3rl geteilt: Tempo gestört. Laut Berichtigung 15:27 der Kriteriendatei lief CUDA im Ganzzahl-Pfad vor dem Vollpatch ganz auf der CPU; dieses Paar nutzt den Vollpatch.
Messwerte (Groesse | Wert | Arm | Start | n):
  m2300 md5 nach Segment 0 | f6855926 (beide) | Ganzzahl CUDA/CPU |  | 1
  m2301 md5 nach Segment 1 | 662ff905 (beide) | Ganzzahl CUDA/CPU |  | 1
  m2302 Held-out nach Segment 0 | 2,614 = 2,614 | Ganzzahl CUDA/CPU |  | 1
  m2303 Held-out nach Segment 1 | 2,389 = 2,389 | Ganzzahl CUDA/CPU |  | 1
  m2304 Held-out nach Segment 0 | 2,597 / 2,595 | Gleitkomma CUDA/CPU |  | 1
  m2305 Held-out nach Segment 1 | 2,432 / 2,406 | Gleitkomma CUDA/CPU |  | 1
  m2306 Zeit je Segment | 2123 / 2106 s gegen 1903 / 1772 s | Ganzzahl CUDA gegen CPU (gestört) |  | 2
Ergebnis e177 [2026-10-21 19:30]: erfuellt
  Fazit: Im Ganzzahl-Pfad sind CUDA und CPU über fast 10.000 Schritte bitgleich, im Gleitkomma-Pfad liegen sie 1,1 % auseinander; beides weit innerhalb der 10 %. Der Pfad rechnet richtig. Schneller war CUDA unter den gestörten Bedingungen nicht; das Tempo beantwortet diese Reihe nicht.
  Offen: Tempo auf freier Karte (siehe snai/tempo-rechenwege); 1 Saat.
  Datei: rechner-b:~/snai_pruef/knirps_gpu/text/kriterien.txt
Chronik:
  2026-10-21 19:29 angelegt (Nachtrag: Nachtrag 2026-10-21 aus der Kriteriendatei.)
  2026-10-21 19:29 Rezept r188 (tx_d512h8_s1 (Ganzzahl), tx_d512h8_fp_s1 (Gleitkomma))
  2026-10-21 19:29 Status geplant -> laeuft (Rezept r188)
  2026-10-21 19:29 Messwerte m2300-m2306
  2026-10-21 19:30 Ergebnis e177: erfuellt
  2026-10-21 19:30 Status laeuft -> ausgewertet (Ergebnis e177)
```
