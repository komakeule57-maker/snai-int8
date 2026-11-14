# snai/tempo-rechenwege

```text
snai/tempo-rechenwege - ausgewertet, begonnen 2026-10-13, angelegt 2026-10-21, zuletzt 2026-10-21 19:30
Frage: Unterscheiden sich die Rechenwege CPU (A), OpenCL (B), CUDA vorwärts (C) und CUDA vorwärts+rückwärts (D) im Ganzzahl-Standardrezept (512/8, ctx 64) in der Trainingszeit um mindestens 10 %?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus rechner-b ~/snai_pruef/cuda_i8/kriterien.txt und out/ (tempo.sh).):
  Vorab rechner-b ~/snai_pruef/cuda_i8/kriterien.txt Abschnitt TEMPO (2026-10-13 19:35, vor dem Start): Median von 3 rotierten Wiederholungen je Arm; unter 10 % = Gleichstand; Spanne eines Arms größer als Abstand zweier Mediane = 'gestört'; fremder Prozess auf der Karte = 'Karte geteilt'. Kontrolle md5 d0d5e143c924 in allen 12 Läufen.
Plan: 3 Durchgänge ABCD, BCDA, CDAB nacheinander.
Baut auf: snai/cuda-i8-anschluss
Darauf baut: snai/adam-profil, snai/ocl-tempo-grim
Rezepte:
  r189 [2026-10-21] A, B, C, D: bash tempo.sh  (je Lauf ./lauf_test.sh, darin php train_cluster.php wie im Prüfstand cuda_i8/t)
      quelltext: libcortex_fix.so (A, B), libcortex_voll.so (C, D)
      parameter: Prüfstand cuda_i8/t: gen.snai 512/8, ctx 64, Zeichen-Vokabular, p300.txt, 300 Schritte, Laufname paar; LR 0,001, Warmup 500, INT8_FULL, gebunden; 2 Threads
      rechner: rechner-b (RTX 3050)
      logs: rechner-b:~/snai_pruef/cuda_i8/out/
      notiz: Eigene Textreihe per STOP angehalten; Arm P und fremder tdc_v3rl liefen weiter.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/cuda_i8/out/ (tempo). B (OpenCL) liegt 14 % hinter A.
  m2307 Trainingszeit Median | 106 s | A CPU |  | 3
  m2308 Trainingszeit Median | 121 s | B OpenCL |  | 3
  m2309 Trainingszeit Median | 112 s | C CUDA vorwärts |  | 3
  m2310 Trainingszeit Median | 102 s | D CUDA vorwärts+rückwärts |  | 3
  m2311 Spanne freie Karte | 102 bis 110 s | C, D |  | 6
Ergebnis e178 [2026-10-21 19:30]: gleichstand
  Fazit: Bei 512/8 und ctx 64 ist kein Rechenweg nennenswert schneller als die CPU mit zwei Threads; der größte Abstand auf freier Karte sind 8 %. Unter 10 % ist das nach der Vorab-Regel Gleichstand, ein vollwertiges Ergebnis. Die Karte lohnt sich in dieser Größe nicht; erst größere Modelle (snai/speedtest-1024x2) oder der Adam auf der Karte ändern das.
  Offen: Großes Vokabular, andere Threadzahlen, Energie (laut Kriteriendatei nicht entschieden).
  Datei: rechner-b:~/snai_pruef/cuda_i8/kriterien.txt
Chronik:
  2026-10-21 19:29 angelegt (Nachtrag: Nachtrag 2026-10-21 aus rechner-b ~/snai_pruef/cuda_i8/kriterien.txt und out/ (tempo.sh).)
  2026-10-21 19:29 Rezept r189 (A, B, C, D)
  2026-10-21 19:29 Status geplant -> laeuft (Rezept r189)
  2026-10-21 19:29 Messwerte m2307-m2311
  2026-10-21 19:30 Ergebnis e178: gleichstand
  2026-10-21 19:30 Status laeuft -> ausgewertet (Ergebnis e178)
```
