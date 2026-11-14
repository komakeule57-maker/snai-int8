# snai/lora-geometrie-klein

```text
snai/lora-geometrie-klein - ausgewertet, begonnen 2026-09-03, angelegt 2026-10-21, zuletzt 2026-10-21 19:39
Frage: Hält der LoRA-Vorsprung aus snai/lora-verfahren auch bei einer Geometrie mit nur 15,8 % Körperanteil (KLEIN: vocab 8192, dim 128, 2 Schichten, ffn 512, ctx 512, 1 Kopf; Basis best_langb_fp32_s7, nach INT8 gewandelt)? Vier Arme wie dort, SFT-Prüfsatz 184 Fenster.
Kriterium (nachgetragen, Beleg: Kriterium aus der LoRA-Planung Abschnitt "KLEIN: Messaufbau (gestartet 2026-09-03 07:00)" und run_geometrie_klein.sh (Datei 2026-09-03 06:57, vor dem Start 07:00:19).):
  Vorab festgelegt (LoRA-Planung "Was welches Ergebnis bedeutet"): (a) LoRA bleibt vorn: Kernbefund trägt auch bei 15,8 % Körperanteil, GROSS wird bestätigende Richtung. (b) LoRA verliert: Befund hängt an der Parameterverteilung, Abschnitt 4 ist zu revidieren, GROSS wird entscheidend. (c) Kurve fällt am Rand: bester Stand ist ein Fensterrand, kein Optimum. Jede Epoche über alle 184 Fenster, nicht per Argmax.
Plan: LoRA-Planung (Geometriefrage, KLEIN)
Baut auf: snai/lora-verfahren
Rezepte:
  r240 [2026-10-21] bash run_geometrie_klein.sh (je Arm: env SNAI_TRAIN_MODE=adapt SNAI_TIE_EMBEDDINGS=0 SNAI_LORA_RANK=<r> [SNAI_TRAIN_LAST_LAYERS=1] SNAI_START_OFFSET=115846 … php train_cluster.php factory/input/corpus_sft_ab.txt <arm> 1 <epochen> factory/checkpoints/base_klein_int8.snai 3 <lr> …)
      quelltext: run_geometrie_klein.sh md5 48e0040b0476…; Basis base_klein_int8.snai aus best_langb_fp32_s7 per convert_fp32_to_int8.php
      parameter: klein_lora_r8 10 Ep. lr 2e-4 r8; klein_voll_lr10tel 20 Ep. lr 2e-5; klein_lastlayer 10 Ep. lr 2e-4; klein_voll 10 Ep. lr 2e-4
      seed: Adapter-Saat 1234567, Offset 115846 (effektiv 115860)
      rechner: rechner-a
      logs: rechner-a:~/.cache/geo_klein/geometrie_klein.log, train_klein_*.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/heldout_full_i8_klein_{lora_r8,voll_lr10tel,lastlayer,voll}.jsonl und heldout_full_i8_base_klein_int8.jsonl, am 2026-10-21 neu ausgelesen; Ergebnisblock in rechner-a:~/.cache/geo_klein/geometrie_klein.log
  m2697 heldout_sft_loss | 6,7598 | ohne Adaption (base_klein_int8) |  | 184
  m2698 heldout_sft_loss_bester | 6,7546 | LoRA r8 (E1), Offset 115846 | 1234567 | 184
  m2699 heldout_sft_loss_E10 | 6,8187 | LoRA r8, Offset 115846 | 1234567 | 184
  m2700 heldout_sft_loss_bester | 6,7729 | Voll-FT lr 2e-5 (E1), Offset 115846 |  | 184
  m2701 heldout_sft_loss_E20 | 6,9361 | Voll-FT lr 2e-5, Offset 115846 |  | 184
  m2702 heldout_sft_loss_bester | 6,7811 | nur letzte Schicht (E1), Offset 115846 |  | 184
  m2703 heldout_sft_loss_bester | 6,8909 | Voll-FT lr 2e-4 (E1), Offset 115846 |  | 184
  m2704 heldout_sft_loss_E10 | 7,6072 | Voll-FT lr 2e-4, Offset 115846 |  | 184
  m2705 bester_adaptionsgewinn_nats | -0,0052 | KLEIN (LoRA r8 gegen ohne Adaption) |  | 184
Ergebnis e215 [2026-10-21 19:39]: keine_aussage
  Fazit: Eingetreten ist keiner der drei vorab festgelegten Fälle: auf KLEIN wirkt Adaption überhaupt nicht. Alle vier Arme haben ihr bestes Ergebnis in Epoche 1 und werden danach monoton schlechter, drei von vier liegen über dem Nullpunkt, LoRA nur 0,005 nats darunter. Die Rangfolge ist damit nicht deutbar, weil schon die Datenreihenfolge an einem E1-Stand ~0,05 nats bewegt. Die Geometriefrage ist nicht beantwortet und liegt ganz bei GROSS. Was die Messung trotzdem sagt: eine so kleine Basis nimmt den SFT-Korpus nicht auf. Das spricht gegen ein sparsam bemessenes Produktivmodell und war ein Argument für dim 512.
  Offen: GROSS (dim 384, 6 Schichten, Körperanteil 62,8 %) nie gefahren. Das Skript meldete automatisch "LoRA vorn"; diese Lesart ist im Dokument ausdrücklich verworfen.
  Datei: LoRA-Planung (KLEIN, Ergebnis 2026-09-03)
Chronik:
  2026-10-21 19:39 angelegt (Nachtrag: Kriterium aus der LoRA-Planung Abschnitt "KLEIN: Messaufbau (gestartet 2026-09-03 07:00)" und run_geometrie_klein.sh (Datei 2026-09-03 06:57, vor dem Start 07:00:19).)
  2026-10-21 19:39 Rezept r240
  2026-10-21 19:39 Status geplant -> laeuft (Rezept r240)
  2026-10-21 19:39 Messwerte m2697-m2705
  2026-10-21 19:39 Ergebnis e215: keine_aussage
  2026-10-21 19:39 Status laeuft -> ausgewertet (Ergebnis e215)
```
