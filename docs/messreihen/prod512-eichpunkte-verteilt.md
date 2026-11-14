# snai/prod512-eichpunkte-verteilt

```text
snai/prod512-eichpunkte-verteilt - ausgewertet, begonnen 2026-10-02, angelegt 2026-10-21, zuletzt 2026-10-21 19:30
Frage: Trifft die Potenzgesetz-Prognose der verteilten Held-out-Reihe von prod512 jedes neue Segment s15 bis s19 innerhalb von ±2 x 0,0056 nats (Fit jeweils auf allen vorher gemessenen Segmenten)?
Kriterium (nachgetragen, Beleg: Kriterium (2026-10-02, 'vor dem Ergebnis festgelegt'), Prognosen s15 4,0049 und s26 (2026-09-28); für s17/s18/s19 jeweils im Eintrag davor wiederholt.):
  Prognose aus dem Fit s1..s(N-1) der verteilten Reihe (bei s15/s16 gemeinsam aus s1..s14); Messwert innerhalb ±2 x 0,0056 (Residuen-SD der verteilten Reihe) = auf der Linie.
Baut auf: snai/prod512-heldout-verteilt
Rezepte:
  r192 [2026-10-21] bash tools/heldout_verteilt.sh <segment> (Laptop) bzw. bash ~/.cache/prod512/heldout_verteilt_rechner-b.sh <segment> (ab s18); darin: SNAI_CORTEX_LIB=<Server-libcortex.so> SNAI_FORCE_CPU=1 OMP_NUM_THREADS=2 SNAI_EVAL_VERTEILT=1 php eval_held_out_full_i8.php factory/checkpoints/prod512_sN.snai factory/holdout_prod/ auto 64; Auswertung python3 diagnose/heldout_verteilt_fit.py
      quelltext: tools/heldout_verteilt.sh md5 64d1d128…, diagnose/heldout_verteilt_fit.py md5 246a7663… (heutiger Stand); Server-libcortex.so md5 169141c5…; md5 jedes Checkpoints gegen vserver geprüft
      parameter: 64 Fenster bei floor((2i+1)*631/128), i=0..63 aus factory/holdout_prod/ho_prod.txt; Fit L=a+b*s^-alpha per Gittersuche (alpha-Schritt 0,0001)
      seed: deterministisch
      rechner: rechner-a (s15-s17), rechner-b (s18, s19)
      logs: rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/heldout_full_i8_prod512_s15..s19_verteilt.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: Messwerte aus rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/heldout_full_i8_prod512_s15..s19_verteilt.jsonl; Prognosen am 2026-10-21 mit eigener Gittersuche nachgerechnet (alle fünf auf 0,0001 gleich den früheren Werten)
  m2324 Prognose verteilt | 4,0049 | prod512 s15 |  | 14
  m2325 Held-out verteilt | 3,989556 | prod512 s15 |  | 64
  m2326 Abweichung | -0,0153 (-2,7 SD) | prod512 s15 |  | 64
  m2327 Prognose verteilt | 3,9882 | prod512 s16 |  | 14
  m2328 Held-out verteilt | 3,980391 | prod512 s16 |  | 64
  m2329 Abweichung | -0,0078 (-1,4 SD) | prod512 s16 |  | 64
  m2330 Prognose verteilt | 3,9674 | prod512 s17 |  | 16
  m2331 Held-out verteilt | 3,963135 | prod512 s17 |  | 64
  m2332 Abweichung | -0,0043 (-0,8 SD) | prod512 s17 |  | 64
  m2333 Prognose verteilt | 3,9516 | prod512 s18 |  | 17
  m2334 Held-out verteilt | 3,950658 | prod512 s18 |  | 64
  m2335 Abweichung | -0,0009 (-0,2 SD) | prod512 s18 |  | 64
  m2336 Prognose verteilt | 3,9375 | prod512 s19 |  | 18
  m2337 Held-out verteilt | 3,937708 | prod512 s19 |  | 64
  m2338 Abweichung | +0,0002 (0,0 SD) | prod512 s19 |  | 64
  m2339 alpha Fit s1..s19 | 0,1974 | prod512 |  | 19
  m2340 Zuwachs < 0,01 nats ab (Prognose) | s25 | prod512 |  | 19
Ergebnis e180 [2026-10-21 19:30]: teilweise
  Fazit: Vier von fünf Segmenten lagen auf der Linie, s15 lag 2,7 SD daneben, aber auf der guten Seite. Zuletzt trafen zwei Prognosen in Folge auf unter 0,001 nats, und die Abbruchgrenze blieb in vier Neufits bei s25, während alpha von 0,2155 auf 0,197 sank: die Grenze ist robuster als die Fitparameter. Ein einzelner Zuwachs unter 0,01 (s15->s16: 0,0092) war Rauschen, das folgende Segment brachte 0,0173. Für prod512b heißt das: Abbruchentscheidungen nur an der verteilten Reihe und an Segmentpaaren. Ob der Lauf tatsächlich bei s25 abgeflacht wäre, bleibt offen, weil er bei s21 abgebrochen wurde.
  Offen: Prognose ab s20 nie geprüft (s20 nur in der alten Reihe gemessen, 3,858). s16 ist eine Zweischritt-Prognose aus s1..s14 (s15 und s16 wurden zusammen gemessen); aus s1..s15 wäre es 3,9841 (-0,7 SD).
Chronik:
  2026-10-21 19:30 angelegt (Nachtrag: Kriterium (2026-10-02, 'vor dem Ergebnis festgelegt'), Prognosen s15 4,0049 und s26 (2026-09-28); für s17/s18/s19 jeweils im Eintrag davor wiederholt.)
  2026-10-21 19:30 Rezept r192
  2026-10-21 19:30 Status geplant -> laeuft (Rezept r192)
  2026-10-21 19:30 Messwerte m2324-m2340
  2026-10-21 19:30 Ergebnis e180: teilweise
  2026-10-21 19:30 Status laeuft -> ausgewertet (Ergebnis e180)
```
