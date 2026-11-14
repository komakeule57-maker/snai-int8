# snai/lora-tying-basis

```text
snai/lora-tying-basis - ausgewertet, begonnen 2026-08-30, angelegt 2026-10-21, zuletzt 2026-10-21 19:39
Frage: Unterscheidet sich LoRA r8 auf einer von Genesis an gebunden vortrainierten Basis (prin_tied_s13, SNAI_V7, 32 % weniger Parameter) von LoRA r8 auf der ungebundenen Basis best_prin_int8_s13 stärker als zwei Läufe derselben Konfiguration (A/A), gemessen am SFT-Held-out und an Wiederholungsentartung im Verhalten? (Urteil gleichstand = nein, Abstand im Rauschboden.)
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/Projekte/snai_edge_int8_lora/run_arm_d.sh (Kopf, 2026-09-01 10:41, vor dem Lauf: A/A-Boden 2,12 sigma aus aa_arm.log 2026-09-01 08:06) und Projektregel Abschnitt Definitions-/Entartungssonde (2026-09-02, Gate vor der Entartungssonde validiert). Eine ausdrückliche Entscheidungsregel für Arm D selbst steht nicht im Skript; die Regel oben ist sinngetreu aus beiden Stellen.):
  Ein Unterschied gebunden gegen ungebunden zählt nur, wenn er den mitgemessenen A/A-Abstand übersteigt (zweiter Lauf derselben Konfiguration, nur andere Datenreihenfolge: aa2_r8_off0 gegen ab_B_r8_clipgains, gepaart 2,12 sigma). Für die Verhaltenssonde: ein Null-Befund gilt erst, wenn die Positivkontrolle (nachträglich gebundene, zerstörte Basis base_prin_int8_s13_tied) im selben Lauf anschlägt.
Plan: LoRA-Planung (Arm D), Projektregel (Definitionssonde, Entartungssonde)
Baut auf: snai/lora-verfahren, snai/tying-prinzessin
Rezepte:
  r236 [2026-10-21] gebundenes Vortraining (Basis für D): bash run_princess_tied.sh (je Segment: SNAI_TRAIN_MODE=pretrain SNAI_TIE_EMBEDDINGS=1 SNAI_INT8_FULL=1 OMP_NUM_THREADS=3 php train_cluster.php <segment> <out> 2 1 <vorige_basis> 3 0.001)
      quelltext: run_princess_tied.sh md5 a92c1c6aa829…
      parameter: 14 Segmente s0-s13 (segments_princess), 2 Arbeiter, 1 Epoche je Segment, lr 0,001
      seed: -
      rechner: rechner-a
      logs: rechner-a:~/.cache/lora_ab/train_prin_tied_s0.log; Nachmessung remeasure_prin_tied_clean.sh
  r237 [2026-10-21] A/A-Zwilling: bash run_aa_arm.sh (SNAI_LORA_RANK=8 SNAI_START_OFFSET=0 OMP_NUM_THREADS=6 php train_cluster.php factory/input/corpus_sft_ab.txt factory/checkpoints/aa2_r8_off0.snai 1 10 factory/checkpoints/best_prin_int8_s13.snai 3 0.0002 0.0001)
      quelltext: run_aa_arm.sh md5 d90ec05f1498…; libcortex.so vom 2026-08-30 18:49:53 (md5 20784c3f587b…)
      parameter: wie ab_B_r8_clipgains, nur Offset 0
      seed: 1234567, Offset 0
      rechner: rechner-a
      logs: rechner-a:~/.cache/lora_ab/aa_arm.log
  r238 [2026-10-21] Arm D (gebunden + LoRA r8): bash run_arm_d.sh (SNAI_LORA_RANK=8 SNAI_START_OFFSET=115846 OMP_NUM_THREADS=6 php train_cluster.php factory/input/corpus_sft_ab.txt factory/checkpoints/abD_r8_tied.snai 1 10 factory/checkpoints/prin_tied_s13.snai 3 0.0002 0.0001)
      quelltext: run_arm_d.sh md5 e037fc5c2ea2…; Basis prin_tied_s13.snai md5 4ad80f6170f2…
      parameter: 10 Epochen, lr 2e-4, 1 Arbeiter
      seed: 1234567, Offset 115846
      rechner: rechner-a
      logs: rechner-a:~/.cache/lora_ab/arm_d.log
  r239 [2026-10-21] Entartungssonde: python3 run_entartungssonde.py (3 Arme x 10 Epochen x 8 Prompts x 10 Ziehungen + 3 Rohbasen x 80)
      quelltext: run_entartungssonde.py (Stand 2026-09-02)
      parameter: Maß zlib-Rate und längster Zeichenlauf je Ziehung; Prompts def/ctl
      seed: -
      rechner: rechner-a
      logs: rechner-a:~/.cache/lora_ab/entartungssonde.jsonl (2640 Zeilen), entartungssonde.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/heldout_full_i8_{ab_B_r8_clipgains,aa2_r8_off0,abD_r8_tied,best_prin_int8_s13,prin_tied_s13,base_prin_int8_s13_tied}.jsonl; gepaarte Werte aus rechner-a:~/.cache/lora_ab/aa_arm.log und arm_d.log (compare_full_paired.php)
  m2673 heldout_sft_loss_E10 | 5,4069 | B ungebunden r8 (ab_B_r8_clipgains), Offset 115846 | 1234567 | 92
  m2674 heldout_sft_loss_E10 | 5,4058 | A/A-Zwilling (aa2_r8_off0), Offset 0 | 1234567 | 92
  m2675 heldout_sft_loss_E10 | 5,3983 | D gebunden r8 (abD_r8_tied), Offset 115846 | 1234567 | 92
  m2676 gepaarte_diff_nats | -0,0011 | A/A (aa2 minus B) |  | 92
  m2677 gepaarte_diff_sigma | 2,12 | A/A (aa2 minus B) |  | 92
  m2678 gepaarte_diff_nats | -0,0086 | D minus B |  | 92
  m2679 gepaarte_diff_sigma | 1,67 | D minus B |  | 92
  m2680 vorzeichen_D_gewinnt | 55/92 | D minus B |  | 92
  m2681 heldout_gen_loss | 4,6879 | Basis ungebunden best_prin_int8_s13 |  | 192
  m2682 heldout_gen_loss | 4,7215 | Basis gebunden prin_tied_s13 |  | 192
  m2683 heldout_sft_loss | 9,8908 | nachträglich gebundene Basis (Positivkontrolle) |  | 92
  m2684 heldout_gen_loss | 10,2271 | nachträglich gebundene Basis (Positivkontrolle) |  | 192
  Quelle: rechner-a:~/.cache/lora_ab/entartungssonde.jsonl, am 2026-10-21 nachgezählt (Schwelle zlib < 0,4 oder maxRun >= 20 von mir gesetzt, die Originalschwelle stand nicht im Skript; die Trennung ist so groß, dass jede Schwelle dazwischen dasselbe zählt)
  m2685 median_zlib_def | 0,8017 | B ungebunden (alle Epochen) |  | 400
  m2686 median_zlib_def | 0,8389 | A/A-Zwilling (alle Epochen) |  | 400
  m2687 median_zlib_def | 0,8744 | D gebunden (alle Epochen) |  | 400
  m2688 median_zlib_ctl | 0,7341 | B ungebunden |  | 400
  m2689 median_zlib_ctl | 0,7535 | A/A-Zwilling |  | 400
  m2690 median_zlib_ctl | 0,7378 | D gebunden |  | 400
  m2691 median_maxrun | 2 | alle drei Arme |  | 2400
  m2692 median_zlib | 0,1986 (def) / 0,2392 (ctl) | Positivkontrolle zerstörte Basis |  | 80
  m2693 median_maxrun | 64,5 (def) / 64 (ctl) | Positivkontrolle zerstörte Basis |  | 80
  m2694 ziehungen_zlib_unter_0,4_oder_maxrun_ab_20 | 80/80 | Positivkontrolle |  | 80
  m2695 ziehungen_zlib_unter_0,4_oder_maxrun_ab_20 | 0/2400 | B, A/A, D zusammen |  | 2400
  m2696 ziehungen_zlib_unter_0,4_oder_maxrun_ab_20 | 0/80 | Rohbasis gebunden prin_tied_s13 |  | 80
Ergebnis e214 [2026-10-21 19:39]: gleichstand
  Fazit: Gebunden und ungebunden trennen sich auf keinem Instrument: auf dem Held-out liegt der Abstand (1,67 sigma) unter dem A/A-Boden (2,12 sigma), in der Entartungssonde zeigen alle drei Arme 0 von 2400 Entartungen, während die Positivkontrolle 80 von 80 anschlägt. Weil die gebundene Basis 32 % weniger Parameter hat, ist der Gleichstand ein Kompressionsergebnis: Tying ist auf dieser Geometrie für LoRA-Adaption umsonst zu haben. Daraus wurde am 2026-09-02 Tying an der Genesis Vorgabe. Der Kollaps des Hauptzweigs (snai/tying-prinzessin) tritt bei eingefrorener Basis nicht auf; er gehört zur Vortrainingsdynamik, nicht zur gebundenen Matrix. Ein weiteres Loss-Paar lohnt nicht.
  Offen: Nur ein Paar je Arm; der Arm-D-Vergleich nutzt E10 von B (5,4069), nicht dessen bestes E4. Die zuerst verwendete Definitionssonde (chars==0) war blind und ist zurückgezogen. Rohtexte der Sonde vom 2026-09-02 nicht gespeichert, das Wortmaß des Hauptzweigs ist darauf nicht nachrechenbar.
  Datei: Projektregel (Abschnitt Definitions-/Entartungssonde), LoRA-Planung (Arm D)
Chronik (juengste 8 von 10, voll=True zeigt alle):
  2026-10-21 19:39 Status geplant -> laeuft (Rezept r236)
  2026-10-21 19:39 Rezept r237 (A/A-Zwilling)
  2026-10-21 19:39 Rezept r238 (Arm D (gebunden + LoRA r8))
  2026-10-21 19:39 Rezept r239 (Entartungssonde)
  2026-10-21 19:39 Messwerte m2673-m2684
  2026-10-21 19:39 Messwerte m2685-m2696
  2026-10-21 19:39 Ergebnis e214: gleichstand
  2026-10-21 19:39 Status laeuft -> ausgewertet (Ergebnis e214)
```
