# snai/cuda-fwd-kachel

```text
snai/cuda-fwd-kachel - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:32
Frage: Ist der Vorwärts-Kachelkern (SNAI_CUDA_FWD=1) bitgleich zum alten Kern im Kerntest, im Training (ctx 64) und in der Produktionsgeometrie (ctx 1024), und ist er bei ctx 64 mindestens 10 % schneller?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus der Kriteriendatei und rechner-b ~/snai_pruef/cuda_fwd/out/ (pruef_fwd.sh, determ.sh 2026-10-14 15:27).):
  Vorab rechner-b ~/snai_pruef/cuda_fwd/kriterien.txt (2026-10-14 13:25, vor dem Trainingstest): Stufe 1 Kerntest 10 Größen gleich, ROT weicht ab; Stufe 2 F0 = F1 = G1 = 1b88448b, FR weicht ab; Stufe 3 Tempo F0 gegen F1, Median aus 3, unter 10 % Gleichstand; Stufe 4 ctx 1024 P0 = P1 (md5 und Step-Zeilen).
Plan: rechner-b:~/snai_pruef/cuda_fwd/kriterien.txt (Stufen 1 bis 4, dazu nachträglich determ.sh zur Erklärung von Stufe 4)
Baut auf: snai/speedtest-1024x2
Darauf baut: snai/zeitzerlegung-ctx1024
Rezepte:
  r200 [2026-10-21] F0, F1, FR, G1, P0, P1: bash pruef_fwd.sh; bash determ.sh
      quelltext: cortex_cuda.cu 203210ab -> 073c15da (patch_fwd_tiled.py), lib 85dafab9; libcortex 789e1092
      parameter: Stufe 2/3: 1024x2 ctx 64, gen1024, p300, OMP 4, GAB; Stufe 4: Vokabular 8192, ctx 1024, Rezept prod512b, tempo_p1024.txt
      rechner: rechner-b (RTX 3050)
      logs: rechner-b:~/snai_pruef/cuda_fwd/out/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/cuda_fwd/out/. Prüfung: die Doku nennt 82.465 verschiedene Bytes bei Stufe 4, determ.txt 91.917.
  m2402 Kerntest Prüfsummen gleich | 10 von 10 | Kachel |  | 10
  m2403 Kerntest ROT weicht ab | 10 von 10 | ROT |  | 10
  m2404 md5 Training ctx 64 | 1b88448b | F0, F1, G1 |  | 3
  m2405 md5 Training ctx 64 | 77769be8 | FR |  | 1
  m2406 Wandzeit Median | 95,35 s | F0 |  | 3
  m2407 Wandzeit Median | 80,78 s | F1 |  | 3
  m2408 F1 gegen F0 | -15 % | F1 gegen F0 |  | 3
  m2409 Stufe 4 P0 = P1 | weicht ab | P0, P1 |  | 2
  m2410 determ.sh md5 | K0a = K1b = cfc8, K1a = K0b = 6b0d | K0, K1 |  | 4
Ergebnis e188 [2026-10-21 19:32]: teilweise
  Fazit: Bei ctx 64 ist der Kachelkern bitgleich und 15 % schneller. Stufe 4 ist nach Wortlaut rot: P0 und P1 weichen ab. Deutung, nicht isoliert: determ.sh zeigt, dass die Prüfsumme dort an der Laufreihenfolge hängt (vertauschte Reihenfolge vertauscht die md5), vermutlich weil das Revival-Protokoll den Lauf überdauert; abgeschaltet wurde es nicht. Ein sauberer Beleg bei ctx 1024 fehlt.
  Offen: Stufe 4 mit Revival aus oder frischem Protokoll wiederholen.
  Datei: rechner-b:~/snai_pruef/cuda_fwd/kriterien.txt
Chronik:
  2026-10-21 19:31 angelegt (Nachtrag: Nachtrag 2026-10-21 aus der Kriteriendatei und rechner-b ~/snai_pruef/cuda_fwd/out/ (pruef_fwd.sh, determ.sh 2026-10-14 15:27).)
  2026-10-21 19:32 Rezept r200 (F0, F1, FR, G1, P0, P1)
  2026-10-21 19:32 Status geplant -> laeuft (Rezept r200)
  2026-10-21 19:32 Messwerte m2402-m2410
  2026-10-21 19:32 Ergebnis e188: teilweise
  2026-10-21 19:32 Status laeuft -> ausgewertet (Ergebnis e188)
```
