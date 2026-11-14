# snai/att-gpu

```text
snai/att-gpu - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:32
Frage: Ist die Attention auf der Karte (SNAI_I8_ATT_GPU=1) bitgleich zur CPU: Baustein exp ohne Abweichung, Training T0/T1 = 1b88448b6ee2, ctx 1024 BG = 21b516f49867, Vergleichstests V1 bis V7 gleich, Rot-Proben weichen ab?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus der Kriteriendatei (samt NACHTRAG 21:40) und den Ausgaben out/ der Durchgänge v1 und v2.):
  Vorab rechner-a ~/snai_pruef/att_gpu/kriterien.txt (2026-10-14, vor dem ersten Lauf): Stufe E expf über alle 2^32 Eingaben 0 Abweichungen, Variante ohne FMA muss abweichen; Stufe T T1 und T0 = 1b88448b6ee2, TRF und TRB weichen ab; Stufe B BG = 21b516f49867, Tempo gegen B1 5.237 ms, unter 10 % Gleichstand; Vergleichstests V1 bis V7 (21:0x, vor dem Lauf) je Prüfsumme und Step-Zeilen bytegleich.
Plan: Durchgang v1 (V3 rot), Fix, Durchgang v2 aller Stufen.
Baut auf: snai/att-bw-parallel
Rezepte:
  r203 [2026-10-21] E, T, BG, V1 bis V7: bash alles.sh; bash vergleich.sh
      quelltext: v2: patch_att_gpu.py auf cortex.nim 796345f3, cortex_cuda.cu 073c15da -> a715e883 / 55aa4100, Brücke 38acf70f; libcortex_attgpu.so 708af46e, libcortex_cuda.so 0b8076dc (v1 in att_gpu.cu.inc.v1)
      parameter: gen.snai 512/8, gen_odd 96/6, gen_h128 512/4, gen1024, ctx 1024 rigB; OMP 1/2/4/8
      rechner: rechner-b (RTX 3050)
      logs: rechner-b:~/snai_pruef/att_gpu/out/
      notiz: Messlauf seg1024 lief auf derselben Karte: Tempo nur Größenordnung.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/att_gpu/out/. Prüfung: im NACHTRAG 21:40 der Kriteriendatei sind Karte und CPU bei V3 vertauscht; nach den Rohdaten ist Karte 381f7b1c, CPU cedd8120.
  m2422 V3 md5 | 381f7b1c gegen cedd8120 (rot) | v1 Karte gegen CPU |  | 1
  m2423 expf Abweichungen | 0 | v2 Variante 0 |  | 1
  m2424 expf Abweichungen | 2 | v1 |  | 1
  m2425 T, BG, V1 bis V7 | gleich | v2 |  | 9
  m2426 Schrittzeit ctx 1024 | 6.328 ms gegen 2.594 ms | V7 ATT_GPU 0 gegen 1 |  | 1
Ergebnis e191 [2026-10-21 19:32]: erfuellt
  Fazit: Im zweiten Durchgang ist die Attention auf der Karte in allen Stufen und Geometrien bitgleich, und bei ctx 1024 sinkt die Schrittzeit auf rund 40 %. Der erste Durchgang fand mit V3 (Kopfbreite 128) einen echten Fehler, den die Standardgeometrie nicht zeigte; die breite Testmatrix war also nötig.
  Offen: Tempo mit belasteter Karte (seg1024), nur Größenordnung.
  Datei: rechner-a:~/snai_pruef/att_gpu/kriterien.txt
Chronik:
  2026-10-21 19:31 angelegt (Nachtrag: Nachtrag 2026-10-21 aus der Kriteriendatei (samt NACHTRAG 21:40) und den Ausgaben out/ der Durchgänge v1 und v2.)
  2026-10-21 19:32 Rezept r203 (E, T, BG, V1 bis V7)
  2026-10-21 19:32 Status geplant -> laeuft (Rezept r203)
  2026-10-21 19:32 Messwerte m2422-m2426
  2026-10-21 19:32 Ergebnis e191: erfuellt
  2026-10-21 19:32 Status laeuft -> ausgewertet (Ergebnis e191)
```
