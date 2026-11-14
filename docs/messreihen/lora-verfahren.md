# snai/lora-verfahren

```text
snai/lora-verfahren - ausgewertet, begonnen 2026-08-29, angelegt 2026-10-21, zuletzt 2026-10-21 19:37
Frage: Int8-LoRA-Fork, eingefrorene Basis best_prin_int8_s13 (vocab 8192, dim 256, 3 Schichten, ungebunden, 6,55 Mio. Parameter), Adaption auf den SFT-Korpus corpus_sft_ab.txt (724 KB): Erreicht LoRA bei mindestens einem Rang (4/8/16/32) die billige Baseline C (nur letzte Schicht trainieren) im SFT-Held-out bei geringerem Speicher? (Nebenbei gemessen: Abstand zur Voll-Feinabstimmung, Arm A.)
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21. Zeitlinie, belegt nur durch Dokumentkopf und datierte Abschnitte der LoRA-Planung (keine Versionsgeschichte vor 2026-10-15): Das Abbruchkriterium steht in Abschnitt 4 'Messaufbau' (ohne eigenes Datum), der im Dokument vor 4a 'Erste Messwerte: Arm 0 und Arm A (2026-08-29)' liegt; der Kopf sagt, das Dokument halte fest, was gemessen werden soll, bevor LoRA-Code entsteht (Fork 2026-08-29). Die entscheidenden Läufe begannen danach: Arm C am 2026-08-30 (dessen Abschnitt beruft sich auf 'das Abbruchkriterium', Z. 919), Arm B Rang 4 am 2026-08-30 (Z. 974 'Abbruchkriterium aus Abschnitt 4'), der gültige Rang-Sweep run_ab_arms_clipgains.sh gestartet 2026-08-30 21:26, C-Neulauf 2026-09-02. Lesart verschärft am 2026-08-30 (Z. 1122): LoRA muss C bei deutlich weniger Parametern einholen; beide Lesarten sind erfüllt. Messgrößen-Ergänzung (Held-out = SFT-Prüfsatz factory/holdout_sft, 92 Fenster, Epochenkurve statt best_*.snai) erst nach den ersten Läufen am 2026-08-30 festgelegt.):
  Wörtlich aus der LoRA-Planung, Abschnitt 4: "Abbruchkriterium für den Pfad: Erreicht LoRA bei keinem Rang mindestens die Baseline C (letzte Schicht) bei geringerem Speicher, ist der Pfad für diese Geometrie widerlegt." Arme 0 (Basis), A (Voll-FT), B (LoRA k = 4/8/16/32), C (nur letzte Schicht), D (gebunden + LoRA, eigene Reihe snai/lora-tying-basis). Gleicher Korpus, gleiche Schrittzahl, gleicher Seed, gleicher Held-out. Je Arm zu berichten: Held-out-Loss über den ganzen Korpus, trainierbare Parameter, Spitzen-RSS, Wanduhrzeit je Schritt und Inferenzzeit je Token.
Plan: LoRA-Planung (Abschnitte 4, 4a, Kernfrage 2026-09-02)
Darauf baut: snai/lora-rang, snai/lora-tying-basis, snai/lora-geometrie-klein, snai/phase6-instruktion
Rezepte:
  r224 [2026-10-21] A (Voll-FT, erster Lauf), C_voll_lr10tel, B r4-r32 erster Lauf (verworfen): bash run_lora_ab.sh  (darin je Arm: env SNAI_LORA_RANK=<r> SNAI_LORA_SEED=<seed> php train_cluster.php factory/input/corpus_sft_ab.txt <modell> 1 10 factory/checkpoints/best_prin_int8_s13.snai 3 <lr> <stop>, SNAI_START_OFFSET=0)
      quelltext: run_lora_ab.sh md5 5f97f42c3319…; libcortex.so damals nicht als eigene Datei erhalten (nächste Sicherung libcortex.so.bak_pre_armc_20260829 vom 2026-08-29 17:43, md5 2979541773bd…)
      parameter: 10 Epochen à 195 Schritte, lr 2e-4 (Abfall auf 2e-5), 1 Arbeiter, dtype 3 (INT8), kein Dropout, kein Label-Smoothing; Korpus md5 fdeb62961edc…, Basis md5 639a137c53d8…
      seed: Adapter-Saat 1234567 (Vorgabe), Offset 0
      rechner: rechner-a
      logs: rechner-a:~/.cache/lora_ab/train_A_voll.log, ergebnisse.tsv
  r225 [2026-10-21] C nur letzte Schicht (alter Lauf), B r4/r8/r16/r32 (gestörtes Clipping, verworfen): bash run_ab_arms_bc.sh  (env SNAI_TRAIN_LAST_LAYERS=1 bzw. SNAI_LORA_RANK=<r> php train_cluster.php factory/input/corpus_sft_ab.txt factory/checkpoints/ab_<arm>.snai 1 10 factory/checkpoints/best_prin_int8_s13.snai 3 0.0002 0.0001)
      quelltext: run_ab_arms_bc.sh md5 7d7394d0732e…; libcortex.so.bak_pre_clipgains_20260830 (md5 8b34d76d7c0b…) = Bau vor dem Gains-Fix
      parameter: wie oben, Ziel-Loss 1e-4
      seed: Adapter-Saat 1234567, Offset nicht gepinnt (am Ausgabenamen hängend)
      rechner: rechner-a
      logs: rechner-a:~/.cache/lora_ab/arms_bc.log, train_ab_B_r*.log, train_ab_C_lastlayer.log
  r226 [2026-10-21] B r4/r8/r32 mit gefixtem Clipping (gültige Rangreihe; r16 = ab_B_r16_clipgains vom 2026-08-30): bash run_ab_arms_clipgains.sh  (je Rang: SNAI_LORA_RANK=<r> OMP_NUM_THREADS=6 php train_cluster.php factory/input/corpus_sft_ab.txt factory/checkpoints/ab_B_r<r>_clipgains.snai 1 10 factory/checkpoints/best_prin_int8_s13.snai 3 0.0002 0.0001)
      quelltext: run_ab_arms_clipgains.sh md5 b52443e15e8c…; libcortex.so vom 2026-08-30 18:49:53, heute als libcortex.so.bak_pre_nodelete_20260902 (md5 20784c3f587b8a62915be0d1acd5c183), cortex.nim mit 'if not armC and not baseGone'
      parameter: 10 Epochen, lr 2e-4, 1 Arbeiter, Ziel-Loss 1e-4, OMP 6 (parallel lief das gebundene Vortraining); Auswertung jeder Epoche: php eval_held_out_full_i8.php mit Basis + cp_<arm>_e<N>.lora gegen factory/holdout_sft/ (92 Fenster)
      seed: Adapter-Saat 1234567, Offset 115846
      rechner: rechner-a
      logs: rechner-a:~/.cache/lora_ab/arms_clipgains.log, epochenkurve.log; Zahlen in rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/heldout_full_i8_ab_B_r*_clipgains.jsonl
  r227 [2026-10-21] A neu (Voll-FT lr 2e-4, Epochenkurve): bash run_arm_a_neu.sh  (SNAI_TRAIN_MODE=adapt SNAI_LORA_RANK=0 SNAI_START_OFFSET=115846 SNAI_KEEP_EPOCHS=1 SNAI_BEST_HOLDOUT=factory/holdout_sft/ SNAI_BEST_WINDOWS=32 php train_cluster.php …)
      quelltext: run_arm_a_neu.sh md5 4f87c171abf1…; libcortex.so vom 2026-08-30 18:49:53 (s. o.)
      parameter: 10 Epochen, lr 2e-4
      seed: Offset 115846 (nach Darwin-Patch effektiv 115860)
      rechner: rechner-a
      logs: rechner-a:~/.cache/lora_ab/arm_a_neu.log, train_armA_voll_neu.log; rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/heldout_full_i8_armA_voll_neu.jsonl
  r228 [2026-10-21] Voll-FT lr 2e-5, 20 Epochen: bash run_arm_c_lr10tel_neu.sh (wie A neu, lr 2e-5, 20 Epochen)
      quelltext: run_arm_c_lr10tel_neu.sh md5 46deab7d99b0…
      parameter: 20 Epochen, lr 2e-5, Anlauf 15 % der Epochen
      seed: Offset 115846
      rechner: rechner-a
      logs: rechner-a:~/.cache/lora_ab/arm_c_lr10tel_neu.log; rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/heldout_full_i8_armC_lr10tel_neu.jsonl
  r229 [2026-10-21] C neu (nur letzte Schicht, Epochenkurve): bash run_arm_c_lastlayer_neu.sh (wie A neu, zusätzlich SNAI_TRAIN_LAST_LAYERS=1)
      quelltext: run_arm_c_lastlayer_neu.sh md5 d477867a2029…
      parameter: 10 Epochen, lr 2e-4
      seed: Offset 115846
      rechner: rechner-a
      logs: rechner-a:~/.cache/lora_ab/arm_c_lastlayer_neu.log; rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/heldout_full_i8_armC_lastlayer_neu.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/heldout_full_i8_{best_prin_int8_s13,ab_B_r*_clipgains,best_ab_C_lastlayer,armC_lastlayer_neu,armA_voll_neu,armC_lr10tel_neu,ab_A_voll,best_ab_A_voll}.jsonl (eval_held_out_full_i8.php), am 2026-10-21 mit json-Leser neu ausgelesen
  m2603 heldout_sft_loss | 6,3879 | 0 Basis (keine Adaption) |  | 92
  m2604 heldout_gen_loss | 4,6879 | 0 Basis (keine Adaption) |  | 192
  m2605 heldout_sft_loss_bester | 5,3991 | B LoRA r8 (E4), Offset 115846 | 1234567 | 92
  m2606 heldout_sft_loss_bester | 5,4012 | B LoRA r4 (E5), Offset 115846 | 1234567 | 92
  m2607 heldout_sft_loss_bester | 5,4030 | B LoRA r16 (E3), Offset 115846 | 1234567 | 92
  m2608 heldout_sft_loss_bester | 5,4067 | B LoRA r32 (E3), Offset 115846 | 1234567 | 92
  m2609 heldout_sft_loss_bester | 5,4837 | C nur letzte Schicht, alter Lauf (E1, Argmax-Griff), Offset nicht gepinnt |  | 92
  m2610 heldout_gen_loss | 4,7383 | C nur letzte Schicht, alter Lauf (E1), Offset nicht gepinnt |  | 192
  m2611 heldout_sft_loss_bester | 5,5367 | C nur letzte Schicht, Neulauf (E1), Offset 115846 |  | 92
  m2612 heldout_sft_loss_bester | 5,7206 | A Voll-FT lr 2e-4, Neulauf (E1), Offset 115846 |  | 92
  m2613 heldout_sft_loss | 6,4860 | A Voll-FT lr 2e-4, Neulauf (E5, erstmals schlechter als Basis), Offset 115846 |  | 92
  m2614 heldout_sft_loss | 6,6007 | A Voll-FT lr 2e-4, Neulauf (E10), Offset 115846 |  | 92
  m2615 heldout_sft_loss_bester | 5,5130 | Voll-FT lr 2e-5, 20 Epochen (E9), Offset 115846 |  | 92
  m2616 heldout_sft_loss | 6,6582 | A Voll-FT lr 2e-4, erster Lauf (E10), Offset 0 |  | 92
  m2617 heldout_sft_loss | 5,7795 | A Voll-FT lr 2e-4, erster Lauf (best_ = E1), Offset 0 |  | 92
  m2618 heldout_gen_loss | 5,0336 | A Voll-FT lr 2e-4, erster Lauf (best_ = E1), Offset 0 |  | 192
  Quelle: LoRA-Planung Abschnitte 3d, 3e, 4a (Rohprotokolle der Speicher-/Zeitmessung nicht gefunden, nicht nachgerechnet)
  m2619 trainierbare_parameter | 6.555.392 | A Voll-FT |  | 1
  m2620 trainierbare_parameter | 786.432 | C nur letzte Schicht |  | 1
  m2621 trainierbare_parameter | 55.296 | B LoRA r4 |  | 1
  m2622 trainierbare_parameter | 110.592 | B LoRA r8 |  | 1
  m2623 trainierbare_parameter | 221.184 | B LoRA r16 |  | 1
  m2624 trainierbare_parameter | 442.368 | B LoRA r32 |  | 1
  m2625 ms_je_schritt | 332,3 | voll (Basis trainiert), Einzelprozess 128 Token |  | 1
  m2626 ms_je_schritt | 185,0 | LoRA r8, Einzelprozess 128 Token |  | 1
  m2627 spitzen_rss_mb | 249 | voll (Basis trainiert) |  | 1
  m2628 spitzen_rss_mb | 152 | LoRA r8 (lora_preload) |  | 1
  m2629 spitzen_rss_mb | 252,5 | A Voll-FT im Cluster-Lauf (VmHWM) |  | 1
  m2630 ms_je_token_inferenz | 0,892 | ohne Adapter (= A, C) |  | 3
  m2631 ms_je_token_inferenz | 1,047 | LoRA r8 |  | 3
  m2632 ms_je_token_inferenz | 1,273 | LoRA r32 |  | 3
Ergebnis e210 [2026-10-21 19:37]: erfuellt
  Fazit: Das Abbruchkriterium greift nicht: LoRA schlägt die Baseline C schon bei Rang 4 und mit einem Vierzehntel ihrer Parameter, bei r8 mit −39 % Trainingsspeicher. Mehr noch: LoRA r8 ist auf diesem Korpus das beste gemessene Verfahren überhaupt, 0,11 nats vor der Voll-Feinabstimmung mit passender Lernrate und 0,32 vor der mit 2e-4. Für SnAI heißt das: Adaption einer fertigen Basis geht über LoRA r8 mit eingefrorener Basis, das wurde am 2026-09-02 Vorgabe (SNAI_TRAIN_MODE=adapt). Der Preis ist +17 % Inferenzzeit je Token, weil die Adapter getrennt bleiben müssen. Beantwortet ist das für eine Basis, einen Korpus, eine Geometrie und eine Saat; die Übertragung auf andere Geometrien ist offen (KLEIN hatte keine Auflösung, siehe snai/lora-geometrie-klein).
  Offen: Zweite Geometrie (GROSS, Körperanteil 62,8 %) nie gefahren. Nur eine Saat je Arm; der A/A-Rauschboden (0,0011 nats) gilt nur für eingelaufene Stände, ein E1-Optimum streut um ~0,05 nats mit der Datenreihenfolge. Rohprotokolle der Speicher-/Zeitmessung (Abschnitt 3d/3e) nicht gefunden.
  Datei: LoRA-Planung
Chronik (juengste 8 von 12, voll=True zeigt alle):
  2026-10-21 19:37 Rezept r226 (B r4/r8/r32 mit gefixtem Clipping (gültige Rangreihe; r16 = ab_B_r16_clipgains vom 2026-08-30))
  2026-10-21 19:37 Rezept r227 (A neu (Voll-FT lr 2e-4, Epochenkurve))
  2026-10-21 19:37 Rezept r228 (Voll-FT lr 2e-5, 20 Epochen)
  2026-10-21 19:37 Rezept r229 (C neu (nur letzte Schicht, Epochenkurve))
  2026-10-21 19:37 Messwerte m2603-m2618
  2026-10-21 19:37 Messwerte m2619-m2632
  2026-10-21 19:37 Ergebnis e210: erfuellt
  2026-10-21 19:37 Status laeuft -> ausgewertet (Ergebnis e210)
```
