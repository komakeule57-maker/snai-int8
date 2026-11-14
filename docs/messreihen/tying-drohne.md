# snai/tying-drohne

```text
snai/tying-drohne - ausgewertet, begonnen 2026-08-28, angelegt 2026-10-21, zuletzt 2026-10-21 19:39
!! ohne Kriterium
Frage: Hauptzweig snai_edge, Drohnenstufe (128 Dim, 512 FFN, Ctx 512, 2 Köpfe, FP32): Bringt Weight Tying (gebunden, 7 Schichten, 2.426.752 Parameter) gegenüber ungebunden (2 Schichten, 2.491.008 Parameter) etwas, gemessen am Held-out und am Inferenzverhalten (Wiederholungskollaps, <unk>-Läufe, Inhaltstiefe)?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Plan: rechner-a:~/Projekte/snai_edge/docs/STUDIE_WEIGHT_TYING.md
Darauf baut: snai/tying-prinzessin
Rezepte:
  r241 [2026-10-21] Lauf 1: cd experiments/drone_tying_ab && bash run_ab.sh (je Epoche beide Arme parallel: php train_cluster.php ../data/epoch<e>.txt <out> <workers> <e> <base> …; Held-out php eval_held_out_full.php …; Inferenz compare_inference_wide.sh)
      quelltext: run_ab.sh md5 f9f29c95327a…; arm/libcortex.so = Tying-Build (libcortex_tying_test.so), compare_inference_wide.sh md5 3358b6f25829…
      parameter: 4 Epochen à 8.388.660 B, frisch je Epoche, LR 0,0005, WD 0,01, Dropout 0,1, Label-Smoothing 0,1, 3 Threads je Arm; Inferenz T=0,25 n=10 je Prompt, 10 Prompts, Gegenprobe T=0,90
      seed: Init ungeseedet (mt_rand), nicht reproduzierbar
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge/experiments/drone_tying_ab/results/, results_wide/
  r242 [2026-10-21] Lauf 2 (zweiter Seed): cd experiments/drone_tying_ab_seed2 && bash run_ab.sh (seed_prelude.php per auto_prepend_file)
      quelltext: run_ab.sh md5 a35383db3e9e…; arm/libcortex.so Hardlink auf die Datei von Lauf 1
      parameter: Material bitgleich zu Lauf 1, sonst identisch, 6 Threads je Arm
      seed: Init-Saat 20260901 (INIT_SEED in run_ab.sh, über seed_prelude.php)
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge/experiments/drone_tying_ab_seed2/results/, results_wide/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/Projekte/snai_edge/experiments/drone_tying_ab{,_seed2}/results/summary.txt und results_wide/matrix.txt; Held-out und T=0,25-Matrix am 2026-10-21 neu ausgezählt, Korrelation aus ERGEBNIS.md (nicht nachgerechnet)
  m2706 heldout_E4 | 5,049289 | ungebunden, Lauf 1 (ungeseedet) |  | 1
  m2707 heldout_E4 | 4,836527 | gebunden, Lauf 1 (ungeseedet) |  | 1
  m2708 heldout_E4 | 5,022651 | ungebunden | 20260901 | 1
  m2709 heldout_E4 | 4,859151 | gebunden | 20260901 | 1
  m2710 heldout_vorsprung_gebunden_E1_bis_E4 | 0,144/0,162/0,196/0,213 | gebunden minus ungebunden, Lauf 1 (ungeseedet) |  | 4
  m2711 heldout_vorsprung_gebunden_E1_bis_E4 | 0,119/0,129/0,151/0,164 | gebunden minus ungebunden | 20260901 | 4
  m2712 kollaps_was_ist_x | 0/20 | ungebunden, Lauf 1 (ungeseedet) |  | 20
  m2713 kollaps_was_ist_x | 5/20 | gebunden, Lauf 1 (ungeseedet) |  | 20
  m2714 kollaps_was_ist_x | 3/20 | ungebunden | 20260901 | 20
  m2715 kollaps_was_ist_x | 8/20 | gebunden | 20260901 | 20
  m2716 kollaps_uebrige_prompts | 1/80 | ungebunden, Lauf 1 (ungeseedet) |  | 80
  m2717 kollaps_uebrige_prompts | 0/80 | gebunden, Lauf 1 (ungeseedet) |  | 80
  m2718 kollaps_uebrige_prompts | 2/80 | ungebunden | 20260901 | 80
  m2719 kollaps_uebrige_prompts | 1/80 | gebunden | 20260901 | 80
  m2720 unk_laeufe | 19/100 | ungebunden, Lauf 1 (ungeseedet) |  | 100
  m2721 unk_laeufe | 8/100 | gebunden, Lauf 1 (ungeseedet) |  | 100
  m2722 unk_laeufe | 64/100 | ungebunden | 20260901 | 100
  m2723 unk_laeufe | 31/100 | gebunden | 20260901 | 100
  m2724 kollaps_T0,90 | 0/48 | beide Arme, beide Läufe, je 12 Ziehungen |  | 48
  m2725 korrelation_new_typ_unk | -0,648 | 20 Arm-Prompt-Zellen | 20260901 | 20
Ergebnis e216 [2026-10-21 19:39]: beobachtung
  Fazit: Zwei Befunde halten über beide Saaten: gebunden ist im Held-out in allen Epochen vorn, und gebunden kollabiert bei niedriger Temperatur deutlich häufiger auf "Was ist X?" (13/40 gegen 3/40). Tying verstärkt damit eine Schwäche, die beide Arme haben, es erzeugt sie nicht. Der Inhaltstiefe-Befund aus Lauf 1 ist widerlegt, er war ein <unk>-Artefakt. Die Entscheidung "kein Tying in die Schwarm-Pipeline" blieb, steht aber nur noch auf dem Kollapsbefund und der Rechenzeit. Später relativiert: der Kollaps gehört zur Vortrainingsdynamik, bei eingefrorener Basis tritt er nicht auf (snai/lora-tying-basis). Zudem zählt das Wortmaß eine zeichenweise entartete Ausgabe als gesund.
  Offen: Kein Kriterium vorab, deshalb nur Beobachtung. n=10 je Zelle, zwei Saaten; das Verhältnis der Arme ist nicht stabil (5:0 gegen 8:3). Datenreihenfolge nicht variiert.
  Datei: rechner-a:~/Projekte/snai_edge/experiments/drone_tying_ab_seed2/ERGEBNIS.md; rechner-a:~/Projekte/snai_edge/docs/inferenz/INFERENZ_DROHNEN_WEIGHT_TYING_AB.md
Chronik:
  2026-10-21 19:39 angelegt (Nachtrag: Kein Entscheidungskriterium vor Lauf 1 (docs/STUDIE_WEIGHT_TYING.md, 2026-08-27, schlägt nur den Aufbau vor). Vor Lauf 2 stand im Log-Kopf (results/run.log 2026-08-31 20:28) eine Liste "ZU BESTÄTIGEN aus Lauf 1" ohne Urteilsregel. Kollapsmaß: > 40 % wiederholte 4-Wort-Folgen, längenkontrolliert.)
  2026-10-21 19:39 Rezept r241 (Lauf 1)
  2026-10-21 19:39 Status geplant -> laeuft (Rezept r241)
  2026-10-21 19:39 Rezept r242 (Lauf 2 (zweiter Seed))
  2026-10-21 19:39 Messwerte m2706-m2725
  2026-10-21 19:39 Ergebnis e216: beobachtung
  2026-10-21 19:39 Status laeuft -> ausgewertet (Ergebnis e216)
```
