# snai/lora-rang

```text
snai/lora-rang - ausgewertet, begonnen 2026-08-29, angelegt 2026-10-21, zuletzt 2026-10-21 19:39
!! ohne Kriterium
Frage: Welcher LoRA-Rang (4/8/16/32) adaptiert die eingefrorene Basis best_prin_int8_s13 am besten auf den SFT-Korpus corpus_sft_ab.txt (SFT-Prüfsatz, voller Korpus, beste Epoche je Rang)?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Plan: LoRA-Planung (Abschnitte "Arm B", "Rang-Sweep nach dem Fix")
Baut auf: snai/lora-verfahren
Rezepte:
  r234 [2026-10-21] r4/r8/r32 gefixt (r16 = ab_B_r16_clipgains vom 2026-08-30 20:52): bash run_ab_arms_clipgains.sh (SNAI_LORA_RANK=<r> OMP_NUM_THREADS=6 php train_cluster.php factory/input/corpus_sft_ab.txt factory/checkpoints/ab_B_r<r>_clipgains.snai 1 10 factory/checkpoints/best_prin_int8_s13.snai 3 0.0002 0.0001); danach je Epoche php eval_held_out_full_i8.php (Basis + cp_<arm>_e<N>.lora) gegen factory/holdout_sft/
      quelltext: run_ab_arms_clipgains.sh md5 b52443e15e8c…; libcortex.so vom 2026-08-30 18:49:53 = heute libcortex.so.bak_pre_nodelete_20260902 (md5 20784c3f587b8a62915be0d1acd5c183)
      parameter: 10 Epochen, lr 2e-4, 1 Arbeiter, Ziel-Loss 1e-4, Korpus md5 fdeb62961edc…, Basis md5 639a137c53d8…
      seed: Adapter-Saat 1234567, Offset 115846
      rechner: rechner-a
      logs: rechner-a:~/.cache/lora_ab/arms_clipgains.log, train_ab_B_r*_clipgains.log, epochenkurve.log
  r235 [2026-10-21] erster Sweep (gestörtes Clipping, ungültig): bash run_ab_arms_bc.sh
      quelltext: run_ab_arms_bc.sh md5 7d7394d0732e…; libcortex.so.bak_pre_clipgains_20260830 (md5 8b34d76d7c0b…)
      parameter: wie oben
      seed: 1234567, Offset nicht gepinnt
      rechner: rechner-a
      logs: rechner-a:~/.cache/lora_ab/train_ab_B_r{4,8,16,32}.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/heldout_full_i8_ab_B_r{4,8,16,32}_clipgains.jsonl, am 2026-10-21 neu ausgelesen; Clip-Zählung und alter r16-Wert aus der LoRA-Planung (nicht nachgezählt)
  m2655 heldout_sft_loss_bester | 5,4012 | r4 (E5), Offset 115846 | 1234567 | 92
  m2656 heldout_sft_loss_bester | 5,3991 | r8 (E4), Offset 115846 | 1234567 | 92
  m2657 heldout_sft_loss_bester | 5,4030 | r16 (E3), Offset 115846 | 1234567 | 92
  m2658 heldout_sft_loss_bester | 5,4067 | r32 (E3), Offset 115846 | 1234567 | 92
  m2659 heldout_sft_loss_E1 | 5,9079 | r4, Offset 115846 | 1234567 | 92
  m2660 heldout_sft_loss_E1 | 5,8541 | r8, Offset 115846 | 1234567 | 92
  m2661 heldout_sft_loss_E1 | 5,7292 | r16, Offset 115846 | 1234567 | 92
  m2662 heldout_sft_loss_E1 | 5,6156 | r32, Offset 115846 | 1234567 | 92
  m2663 heldout_sft_loss_E10 | 5,4099 | r4, Offset 115846 | 1234567 | 92
  m2664 heldout_sft_loss_E10 | 5,4069 | r8, Offset 115846 | 1234567 | 92
  m2665 heldout_sft_loss_E10 | 5,4254 | r16, Offset 115846 | 1234567 | 92
  m2666 heldout_sft_loss_E10 | 5,4646 | r32, Offset 115846 | 1234567 | 92
  m2667 spanne_beste_staende_nats | 0,0076 | r4-r32 |  | 4
  m2668 clip_gefeuert_alter_lauf | 14/430 | r4 (gestörtes Clipping) |  | 430
  m2669 clip_gefeuert_alter_lauf | 13/430 | r8 (gestörtes Clipping) |  | 430
  m2670 clip_gefeuert_alter_lauf | 29/430 | r16 (gestörtes Clipping) |  | 430
  m2671 clip_gefeuert_alter_lauf | 25/430 | r32 (gestörtes Clipping) |  | 430
  m2672 heldout_sft_loss_E3_alt | 5,3773 | r16 alter Lauf (gestörtes Clipping, abgelöst) |  | 92
Ergebnis e213 [2026-10-21 19:39]: beobachtung
  Fazit: Kein Rang gewinnt: die besten Stände der vier Ränge liegen 0,0076 nats auseinander, weit unter der Messschärfe von ±0,021. Die frühere Aussage "Optimum bei Rang 16" war ein Artefakt des rangabhängig gestörten Gradient-Clippings und ist abgelöst. Was der Rang tatsächlich steuert, ist der Zeitpunkt: höherer Rang ist früher am Ziel (r32 bei E3, r4 bei E5) und überangepasst danach stärker (r32 verliert bis E10 0,058, r4 0,009). Für die Praxis heißt das: Rang 8 als Vorgabe ist kein Messergebnis, sondern eine vertretbare Wahl; wichtiger als der Rang ist, den besten Epochenstand auf dem passenden Prüfsatz zu wählen. Ein zweiter Seed lohnt hier nicht.
  Offen: Rangfrage nur für diese Geometrie und diesen Korpus; bei anderer Basisgröße nie gemessen. Kein Kriterium vorab, deshalb nur Beobachtung.
  Datei: LoRA-Planung
Chronik:
  2026-10-21 19:39 angelegt (Nachtrag: Kein Kriterium vor den Läufen. Die LoRA-Planung (Abschnitt 3, Falle e) verlangt nur, mehrere Ränge zu messen. Die Messschärfe ±0,021 nats (eval_held_out_full_i8.php, Standardfehler 0,0206, gemessen 2026-08-29) wurde erst nach dem Sweep als Maßstab herangezogen.)
  2026-10-21 19:39 Rezept r234 (r4/r8/r32 gefixt (r16 = ab_B_r16_clipgains vom 2026-08-30 20:52))
  2026-10-21 19:39 Status geplant -> laeuft (Rezept r234)
  2026-10-21 19:39 Rezept r235 (erster Sweep (gestörtes Clipping, ungültig))
  2026-10-21 19:39 Messwerte m2655-m2672
  2026-10-21 19:39 Ergebnis e213: beobachtung
  2026-10-21 19:39 Status laeuft -> ausgewertet (Ergebnis e213)
```
