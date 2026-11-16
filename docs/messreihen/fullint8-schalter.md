# snai/fullint8-schalter

```text
snai/fullint8-schalter - ausgewertet, angelegt 2026-11-15, zuletzt 2026-11-15 19:12
Frage: Lassen sich die Stufen des Ganzzahl-Pfads einzeln schalten (SNAI_I8_GZ_<STUFE>=0|1 neben der Kurzform SNAI_I8_GANZ=N), ohne dass sich die bisherigen Stände ändern, und laufen die neuen Mischungen (Kleber float<->GZ) sauber?
Kriterium (festgelegt 2026-11-15 19:07, vor dem ersten Messwert):
  Lib cafc9ad7 (cortex_gz a2f97ebb, cortex.nim 624d543d, patch_gz ed29d20f), Kurzlauf kurz_seg0.txt 232 Schritte, isoliert (probe_iso.sh, 2 Fäden). A, bytegleich (md5 des Checkpoints): GANZ=0 = 0f79d04c, auch mit GZ_NORM=1 (dazu Warnung im Log); GANZ=1/2/3/4 = 47176fa4/12e40925/6f382e75/ac0be686; GANZ=2+MATMUL=0 = 47176fa4; GANZ=3+ADAM=0 = 12e40925; GANZ=4+NORM=0 = 6f382e75; GANZ=4+MATMUL=0+ADAM=0+NORM=0 = 47176fa4; GANZ=1+MATMUL=1+ADAM=1+NORM=1 = ac0be686. Rot-Fähigkeit: die Sollwerte unterscheiden sich je Stand, ein wirkungsloser Schalter fiele als falscher md5 auf. B, neue Mischungen {1,3}, {1,4}, {1,2,4}, {1,3,4}: rc 0, STEPS_DONE=232, letzter Globaler Avg Loss innerhalb ±2 % von GANZ=4, {1,3} zweimal bytegleich. Urteil erfüllt = A und B; B ist eine grobe Prüfung (Lauffähigkeit), keine Qualitätsaussage.
Baut auf: snai/fullint8-st4-norm
Darauf baut: snai/fullint8-st5-rope
Rezepte:
  r725 [2026-11-15] ./schalter_proben.sh (16 Proben, je: env SNAI_I8_GANZ=N [SNAI_I8_GZ_<STUFE>=0|1 ...] ./probe_iso.sh proj_gz <name> - 2; 2 parallel)
      quelltext: cortex_gz.nim a2f97ebb, cortex.nim 624d543d (patch_gz.py ed29d20f auf proj_s0/cortex.nim cefc6f9c), Lib cafc9ad7
      seed: Genesis gesch_gen_d96h6L2_s1, Kurzlauf
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/fullint8/log/schalter_proben.log, log/W*.log, log/C*.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: log/schalter_proben.log (md5 der Checkpoints), log/*.log (Globaler Avg Loss, Warnung, Stufenliste)
  m11367 A md5 GANZ=0 / GANZ=0+NORM=1 | 0f79d04c / 0f79d04c (Warnung im Log) | A | s1
  m11368 A md5 GANZ=1/2/3/4 | 47176fa4 / 12e40925 / 6f382e75 / ac0be686 (= Bezug) | A | s1
  m11369 A md5 GANZ=2+MATMUL=0 | 47176fa4 (= Stand 1) | A | s1
  m11370 A md5 GANZ=3+ADAM=0 | 12e40925 (= Stand 2) | A | s1
  m11371 A md5 GANZ=4+NORM=0 | 6f382e75 (= Stand 3) | A | s1
  m11372 A md5 GANZ=4+MATMUL=0+ADAM=0+NORM=0 | 47176fa4 (= Stand 1) | A | s1
  m11373 A md5 GANZ=1+MATMUL=1+ADAM=1+NORM=1 | ac0be686 (= Stand 4) | A | s1
  m11374 B Mischung {1,3} zweimal | d0f2f6eb / d0f2f6eb, Loss 5,64369 | B | s1
  m11375 B Mischung {1,4} | 81832cda, Loss 5,64455 | B | s1
  m11376 B Mischung {1,2,4} | aa328b15, Loss 5,64347 | B | s1
  m11377 B Mischung {1,3,4} | 591a5ae5, Loss 5,64614 | B | s1
  m11378 B Bezug GANZ=4 Loss | 5,64489 (alle Mischungen innerhalb 0,05 %) | B | s1
Ergebnis e681 [2026-11-15 19:12]: erfuellt
  Fazit: Jede Stufe lässt sich jetzt einzeln zurückdrehen. Eine abgeschaltete Stufe gibt bytegenau den Stand ohne sie, und die Kurzform SNAI_I8_GANZ=N rechnet wie vorher. Damit bleiben alle bisherigen Messreihen (Stufen 1–4) gültig, und die Schlussprüfung kann je Stufe einzeln zurückschalten. Neue Mischungen mit Klebern zwischen float und Ganzzahl laufen deterministisch und im Loss unauffällig. Ob sie qualitativ gleichwertig sind, ist damit nicht geprüft; das klären die Einzelvergleiche der Schlussläufe.
  Offen: Mischungen nur Kurzlauf (232 Schritte), Saat s1. Die Stufen 5–8 bekommen ihre Schalter beim Bau; die Probe wird je Stufe um 'Stufe k aus = Stand k-1' erweitert.
Chronik:
  2026-11-15 19:07 angelegt
  2026-11-15 19:12 Rezept r725
  2026-11-15 19:12 Status geplant -> laeuft (Rezept r725)
  2026-11-15 19:12 Messwerte m11367-m11378
  2026-11-15 19:12 Ergebnis e681: erfuellt
  2026-11-15 19:12 Status laeuft -> ausgewertet (Ergebnis e681)
```
