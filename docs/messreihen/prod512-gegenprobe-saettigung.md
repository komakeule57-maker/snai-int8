# snai/prod512-gegenprobe-saettigung

```text
snai/prod512-gegenprobe-saettigung - ausgewertet, begonnen 2026-10-09, angelegt 2026-10-21, zuletzt 2026-10-21 19:36
Frage: Verursacht das Trainingsrezept des alten Laufs prod512 (LR 0,001 konstant, kein Warmup, WD 0) die Attention-Sättigung, und halten die Rezepte mit kleinerer Lernrate und Warmup (B, C, E) die Attention in prod512-Geometrie ungesättigt?
Kriterium (nachgetragen, Beleg: Kriterium (Eintrag 2026-10-09 08:55 UTC = 10:55 Ortszeit; Start der Arme 10:50, erster Messpunkt nach 122 Schritten etwa 40 min später, also vor jedem Ergebnis). Arm E (gestartet 2026-10-10 03:20) mit demselben Kriterium.):
  Logit-Streuung und größtes Attention-Gewicht je Schicht (Röntgen, 8 Fenster, Mittel über 6 Schichten x 8 Köpfe) gegen Arm K bei gleicher Schrittzahl. Ein Arm gilt als nicht gesättigt, wenn die Logit-Std mindestens um den Faktor 3 unter Arm K bleibt und das mittlere größte Gewicht unter 0,5 liegt; Gleichstand unter 10 %.
Plan: rechner-b:~/snai_pruef/gegenprobe/kette.sh
Baut auf: snai/kopier-prod512-attention
Rezepte:
  r221 [2026-10-21] bash ./kette.sh <arm> <lr> <warmup> <wd>  (K 0.001 0 0; B 0.0003 500 0; C 0.0003 500 0.1; D 0.001 0 0.1; E 0.0001 500 0.1); darin je Stück: SNAI_TRAIN_MODE=pretrain SNAI_TIE_EMBEDDINGS=1 SNAI_INT8_FULL=1 SNAI_FORCE_CPU=1 SNAI_START_OFFSET=0 SNAI_WARMUP_STEPS=$WU php train_cluster.php factory/input/gp_g$I.txt $O 1 1 $B 3 $LR 0 1 $WD; danach Röntgen ./lauf.sh $O gp_<arm>_g$I 8 2 libcortex_rx.so 1 und rx_auswert.py; Tafel: cd ~/snai_pruef/roentgen && ./venv/bin/python ~/snai_pruef/gegenprobe/tafel.py
      quelltext: rechner-b:~/snai_pruef/gegenprobe: kette.sh md5 0a61e6b1…, patch_warmup.py d0aee926…, tafel.py 77f7cb4c…, proj/train_worker.php 94bc6d44… (mit SNAI_WARMUP_STEPS), proj/libcortex.so 613ee158… (korrigierte cortex.nim mit ATTFIX); roentgen/lauf.sh e21a8772…, rx_auswert.py c0d594a2…
      parameter: prod512-Geometrie ab prod512_genesis.snai, 1 Arbeiter, gebunden, int8 voll, OMP_NUM_THREADS=3; Stücke gp_g0..g5 aus dem Anfang von pseg00 (122/122/244/488/976/1952 Schritte, kumuliert 122/244/488/976/1952/3904); Arm D bei 1952 beendet
      seed: eine Saat (Genesis, SNAI_START_OFFSET=0)
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/gegenprobe/logs/<arm>.log und <arm>_g<i>.train.log; Kennzahlen rechner-b:~/snai_pruef/roentgen/out/gp_<arm>_g<i>.kenn.json
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/gegenprobe/tafel.py am 2026-10-21 neu ausgegeben (liest roentgen/out/gp_*.kenn.json);
  m2546 Logit-Std / max_w nach 1952 Schritten | 57,38 / 0,962 | K |  | 1952
  m2547 Logit-Std / max_w nach 3904 Schritten | 92,75 / 0,981 | K |  | 3904
  m2548 Logit-Std / max_w nach 1952 Schritten | 40,46 / 0,947 | D |  | 1952
  m2549 Logit-Std / max_w nach 1952 Schritten | 3,13 / 0,473 | B |  | 1952
  m2550 Logit-Std / max_w nach 3904 Schritten | 2,73 / 0,445 | B |  | 3904
  m2551 Logit-Std / max_w nach 1952 Schritten | 2,98 / 0,462 | C |  | 1952
  m2552 Logit-Std / max_w nach 3904 Schritten | 2,39 / 0,392 | C |  | 3904
  m2553 Logit-Std / max_w nach 1952 Schritten | 1,16 / 0,175 | E |  | 1952
  m2554 Logit-Std / max_w nach 3904 Schritten | 1,25 / 0,182 | E |  | 3904
  m2555 Faktor Logit-Std K / Arm nach 3904 Schritten | 34 / 39 / 74 | B / C / E |  | 3904
  m2556 Faktor Logit-Std K / D nach 1952 Schritten | 1,4 | D |  | 1952
  m2557 max_w Produktion nach Segment s0 (Bezug) | 0,926 (Logit-Std 25,40) | prod512 s0 |  | 1
  Quelle: rechner-b:~/snai_pruef/gegenprobe/logs/<arm>_g5.train.log, Zeile '[Metrik] Globaler Avg Loss', abgelesen 2026-10-21 (Mittel über das letzte Stück, nicht der Momentanwert)
  m2558 Globaler Avg Loss Stück g5 | 5,92467 | K |  | 1952
  m2559 Globaler Avg Loss Stück g5 | 5,27741 | B |  | 1952
  m2560 Globaler Avg Loss Stück g5 | 5,24398 | C |  | 1952
  m2561 Globaler Avg Loss Stück g5 | 5,36425 | E |  | 1952
Ergebnis e208 [2026-10-21 19:36]: erfuellt
  Fazit: Ja: das Produktionsrezept sättigt auch mit ATTFIX und wächst ungebremst weiter (Logit-Std 93 nach 3904 Schritten), Weight Decay allein (D) verhindert das nicht. Kleinere Lernrate mit Warmup hält die Attention weich, B, C und E liegen um den Faktor 34 bis 74 unter K und unter 0,5; B und C erreichen ihr Maximum um 1952 Schritte und werden danach wieder weicher. Das war die Rezeptwahl für prod512b (LR 0,0001, Warmup 500, WD 0,1). Offen blieb damals, ob die sehr flache Attention von E überhaupt genutzt wird; die Antwort darauf gibt erst der Lauf selbst (snai/kopier-prod512b-pos). Dass kleinere LR auf echtem Text gleich schnell oder schneller lernt (Loss B/C 11 % unter K), entkräftet die Sorge, das Rezept koste Fortschritt.
  Offen: Eine Saat, 1 Arbeiter statt 2 mit Merge, höchstens 3904 Schritte (ein Produktivsegment hat rund 10.500). Die Q/K-Richtungstreue wurde mit einer Messbibliothek vor dem ATTFIX gemessen.
Chronik:
  2026-10-21 19:36 angelegt (Nachtrag: Kriterium (Eintrag 2026-10-09 08:55 UTC = 10:55 Ortszeit; Start der Arme 10:50, erster Messpunkt nach 122 Schritten etwa 40 min später, also vor jedem Ergebnis). Arm E (gestartet 2026-10-10 03:20) mit demselben Kriterium.)
  2026-10-21 19:36 Rezept r221
  2026-10-21 19:36 Status geplant -> laeuft (Rezept r221)
  2026-10-21 19:36 Messwerte m2546-m2557
  2026-10-21 19:36 Messwerte m2558-m2561
  2026-10-21 19:36 Ergebnis e208: erfuellt
  2026-10-21 19:36 Status laeuft -> ausgewertet (Ergebnis e208)
```
