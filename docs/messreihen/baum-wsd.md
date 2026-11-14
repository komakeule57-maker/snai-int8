# snai/baum-wsd

```text
snai/baum-wsd - ausgewertet, angelegt 2026-11-04, zuletzt 2026-11-04 22:27
Frage: Bringt die Übernahme des Abkühlstarts SNAI_LR_DECAY_START in den Projektbaum snai_edge_int8_lora das Rezept R ohne Nebenwirkung in den Baum, und wirkt R dort? Entscheidung am 2026-11-04 nach e531: R übernehmen. Der Faktor F ist schon seit 35da856 als Modell-Bit im Baum.
Kriterium (festgelegt 2026-11-04 20:28, vor dem ersten Messwert):
  Wortlaut: rechner-a ~/snai_pruef/stell/KRITERIEN_baum_wsd.md.

P1 (ausgeschaltet bytegleich): neuer gegen alten Trainer, 400 Schritte, Cosinus an, ohne Start. Alle Schrittzeilen und der t400-md5 müssen gleich sein. Rot: Mit Start 300 muss es ab Schritt 101 abweichen. Ein Start ≥ Steps muss abbrechen.

P2 (eingeschaltet gleich dem Prüfstand, v-Klemme aus): Baum mit F-Bit gegen Prüfstand mit Env-F, Plan 100/300/400. Alle Schrittzeilen müssen gleich sein. Rot: ohne Start.

P3 (Voreinstellung des Baums, v-Klemme an), 8 Saaten, kurz9000, D = HR − HE:
- HR = F plus Plan W (2000 / 8102 / 9002).
- HE = F, Warmup 500, konstant.
- REPARATUR WIRKT IM BAUM: 6/8 negativ und Mittel ≤ −0,02.
- GLEICH: Betrag Mittel < 0,01 und Betrag D < 0,02 in 6/8.
- Sonst OFFEN. Bei knappem Ergebnis: heldout2 und Bootstrap.
- Rot Messpfad: Lib ohne Bit-Kenntnis muss abweichen.
Darauf baut: snai/tiefe-budget-r, snai/swiglu-knirps
Rezepte:
  r589 [2026-11-04] Der Patch: ~/Projekte/snai_edge_int8_lora/train_worker.php geht von 00fc3f1d (HEAD) auf 2c3d0813, eingespielt per Python-assert aus dem Prüfstand-Trainer de34a553. Der alte Stand liegt im Scratchpad, ein Commit ist nicht gemacht.

Die Prüfungen laufen auf rechner-a unter ~/snai_pruef/stell:
- P1/P2: probe_baum.sh (a639ca64) <tag> <proj> <lib> <gen> 400.
- P3: setsid nohup ./reihe_baum.sh (012f3989; lauf_baum.sh 3f7a8cf2 aus lauf_stell.sh per assert; KRITERIEN_baum_wsd.md 1633b2b6 mit Prüfer-Nachtrag). Es sind 32 Läufe, 12 zugleich.
- Auswertung: werkzeug/ausw_baum.py (2a1737d8). Bei knappem Ergebnis kommt ho2_baum.sh dazu.
      quelltext: Baum-Lib 1eb78bc1 (mit v-Klemme), Prüfstand-Lib c5f9fbaf, train_cluster.php 9084a7c4 (in beiden Bäumen gleich), Genesis proj_clip clip_gen_s<s>
      parameter: HR: SNAI_EMB_EIN=1 SNAI_GENESIS_RUN=1, Warmup 2000, START 8102, STEPS 9002, MIN 0,1. HE: F, Warmup 500, konstant. HR0/HE0: wie HR/HE mit SNAI_V_KLEMME=0. LR 0,003, kurz9000, 1 Thread.
      rechner: rechner-a
      logs: log/probe/*.txt,*.steps (P1/P2); log/baum.log, laeufe/baum/*, log/baum_gains.jsonl (P3)
Messwerte (Groesse | Wert | Arm | Start | n):
  m8837 P1 Schrittzeilen neu=alt (ohne Start) | 84 | 84/84 gleich bis Schritt 400; md5 t400 37f86652 beide -> BYTEGLEICH
  m8838 P1 Rot mit Start 300 | 24 | 24/84 gleich, erste Abweichung Schritt 105 (erste Zeile nach Warmup), md5 e05e7e39
  m8839 P1 Schranke Start=Steps=400 | 0 | Abbruch "liegt nicht hinter SNAI_LR_DECAY_START" -> erfuellt
  m8840 P2 Schrittzeilen Baum(Bit-F, VK 0) = Pruefstand(Env-F) | 84 | 84/84 gleich, Schritt 400 4,144499/1,3089 beide; LR-Zeilen 1/300/400 gleich
  m8841 P2 Rot Baum ohne Start | 24 | 24/84 gleich, erste Abweichung Schritt 105
  Quelle: rechner-a ~/snai_pruef/stell/werkzeug/ausw_baum.py (2a1737d8), log/baum.log
  m8861 P3 D=HR-HE heldout Mittel | -0,2159 (8/8 neg, BS -0,2249..-0,2071) | HR-HE | s4-s11 | 8
  m8862 D0=HR0-HE0 heldout Mittel | -0,2182 (8/8 neg, BS -0,2329..-0,2045) | HR0-HE0 | s4-s11 | 8
  m8863 P3b I=D-D0 Mittel | +0,0023 (4/8 neg, Betrag I unter 0,02 in 4/8, BS -0,0111..+0,0154) | I | s4-s11 | 8
  m8864 heldout Mittel | 2,4293 | HR | s4-s11 | 8
  m8865 heldout Mittel | 2,4291 | HR0 | s4-s11 | 8
  m8866 heldout Mittel | 2,6452 | HE | s4-s11 | 8
  m8867 heldout Mittel | 2,6473 | HE0 | s4-s11 | 8
  m8868 tote FFN-Gains max je Schicht | bis 3,1 % | HR | s4-s11 | 8
  m8869 tote FFN-Gains L2 | 0-28 % | HE | s4-s11 | 8
  m8870 Rot Messpfad HR s4 Pruefstand-Lib | 5,5163 | HR | 4 | 1
  m8871 Kontrollen rc0/STEPS 9002/embein/flags3/korrigiert0 | 32/32 | alle | s4-s11 | 32
Ergebnis e535 [2026-11-04 22:27]: teilweise
  Fazit: P1, P2 und P3 sind erfüllt: R ist im Projektbaum repariert. Der neue Trainer ist ausgeschaltet bytegleich, rechnet eingeschaltet wie der Prüfstand und bringt in der Baum-Voreinstellung mit v-Klemme −0,22 nats in 8/8 Saaten. Das ist nicht knapp. Der Gewinn kommt vom Plan. F hält die Gains am Leben und bringt selbst nur rund 0,01 (e531). P3b (Wechselwirkung von Plan und v-Klemme) ist nach Wortlaut OFFEN, weil nur 4/8 Saaten |I| < 0,02 haben. Der Bootstrap −0,011..+0,015 schließt aber eine Wechselwirkung in der Größe der Schwelle aus. Vorgabe für neue Läufe ab 128x4: SNAI_EMB_EIN=1 an der Genesis, Warmup 2000, Abkühlen über die letzten 10 % auf das 0,1-Fache. Die v-Klemme kann an bleiben. Die schwachen mittleren FFN sind kein Defekt: nicht 8 Bit, nicht die Gains, auch nicht die Breite (bei 512 bringt Tiefe ebenfalls nichts, multistack-tiefe-512).
  Offen: Der Commit der Baumänderung steht noch aus. Die Regel für P3b kann die Abwesenheit einer Wechselwirkung bei dieser Saat-Streuung (±0,025 je I) kaum je bestätigen. Warum Tiefe in den geprüften Rezepten (Breite 64/128/512) wenig bringt, ist nicht isoliert; Kandidaten sind Daten und Budget. Ein Fähigkeitstest jenseits des Verlusts steht noch aus: Die Kopiersonde an prod512b ab s12 läuft nur, wenn dort Gains sterben (s9: keine). Eine Anzeigelücke ist ungelöst: train_cluster.php:766.
  Datei: rechner-a:~/snai_pruef/stell/ERGEBNIS_baum_wsd.md
Abgeloest und ausgeblendet: 1 ergebnis - voll=True zeigt sie.
Chronik:
  2026-11-04 20:28 angelegt
  2026-11-04 20:30 Rezept r589
  2026-11-04 20:30 Status geplant -> laeuft (Rezept r589)
  2026-11-04 20:30 Messwerte m8837-m8841
  2026-11-04 22:26 Ergebnis e534: teilweise
  2026-11-04 22:26 Status laeuft -> ausgewertet (Ergebnis e534)
  2026-11-04 22:26 Messwerte m8861-m8871
  2026-11-04 22:27 Ergebnis e535: teilweise, loest e534 ab
```
