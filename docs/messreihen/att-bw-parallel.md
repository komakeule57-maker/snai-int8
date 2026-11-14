# snai/att-bw-parallel

```text
snai/att-bw-parallel - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:32
Frage: Ist die über die Köpfe parallele Attention-Rückwärtsrechnung (SNAI_I8_ATT_BW=1) bitgleich zur seriellen bei OMP 1/2/8 und in den Geometrien 512/8, 1024x2 und ctx 1024, mit abweichender Rot-Probe?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus der Kriteriendatei (mtime 17:46, Text ~16:40) und rechner-b ~/snai_pruef/att_bw/out/.):
  Vorab rechner-b ~/snai_pruef/att_bw/kriterien.txt (laut Text 2026-10-14 ~16:40, vor dem Test): A1 S0 = d0d5e143c924 und Steps = R, S1 bei OMP 1, 2, 8 = S0, SR weicht ab; A2 1024x2 = 1b88448b6ee2; B ctx 1024 B0 = B1 bytegleich; Tempo unter 10 % Gleichstand, je Arm ein Lauf = Beobachtung.
Plan: Stufe A (300-Schritte-Prüfstand), Stufe B (ctx 1024, 31 Schritte, Revival aus).
Baut auf: snai/zeitzerlegung-ctx1024
Darauf baut: snai/att-gpu
Rezepte:
  r202 [2026-10-21] S0, S1, SR, G1, B0, B1, B1o8: bash pruef_att.sh
      quelltext: cortex.nim 6f003dc8 -> 796345f3 (patch_att_bw_par.py), libcortex_att a29a032f; libcortex_cuda 85dafab9
      parameter: A1 gen.snai 512/8 FORCE_CPU OMP 2; A2 gen1024 GAB OMP 4; B drohne_g1024, det_p1024.txt, Revival aus
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/att_bw/out/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/att_bw/out/
  m2414 md5 | d0d5e143 | S0 |  | 1
  m2415 md5 | gleich S0 | S1 OMP 1, 2, 8 |  | 3
  m2416 md5 | 74c7b6f2 (weicht ab) | SR |  | 1
  m2417 md5 | 1b88448b | G1 |  | 1
  m2418 md5 ctx 1024 | 21b516f4 | B0, B1, B1o8 |  | 3
  m2419 Schrittzeit ctx 1024 | 11.293 ms | B0 |  | 1
  m2420 Schrittzeit ctx 1024 | 5.237 ms | B1 |  | 1
  m2421 Schrittzeit ctx 1024 | 4.685 ms | B1o8 |  | 1
Ergebnis e190 [2026-10-21 19:32]: erfuellt
  Fazit: Die parallele Rückwärtsrechnung ist überall bitgleich, die Rot-Probe greift, und bei ctx 1024 halbiert sie die Schrittzeit (Tempo als Beobachtung, je Arm ein Lauf). Damit war der größte Zeitposten bei langem Kontext ohne Numerikrisiko beseitigt.
  Offen: Pfad i8_att_bw_quantq=0 nicht gemessen (laut Kriteriendatei so zu zitieren).
  Datei: rechner-b:~/snai_pruef/att_bw/kriterien.txt
Chronik:
  2026-10-21 19:31 angelegt (Nachtrag: Nachtrag 2026-10-21 aus der Kriteriendatei (mtime 17:46, Text ~16:40) und rechner-b ~/snai_pruef/att_bw/out/.)
  2026-10-21 19:32 Rezept r202 (S0, S1, SR, G1, B0, B1, B1o8)
  2026-10-21 19:32 Status geplant -> laeuft (Rezept r202)
  2026-10-21 19:32 Messwerte m2414-m2421
  2026-10-21 19:32 Ergebnis e190: erfuellt
  2026-10-21 19:32 Status laeuft -> ausgewertet (Ergebnis e190)
```
