# snai/phase6-instruktion

```text
snai/phase6-instruktion - ausgewertet, begonnen 2026-09-23, angelegt 2026-10-21, zuletzt 2026-10-21 19:42
Frage: Phase 6, Arm instruktion: Gewinnt ein LoRA-Adapter (Rang 8, 6 Epochen, LR 0,0002) auf der Basis prod512_probe_s11, trainiert auf corpus_sft_gemma.txt, auf dem passenden Prüfsatz SFT-Gemma gegen den Nullpunkt der Basis auf demselben Prüfsatz (gepaarter Gewinn, Diagonale der Phase-6-Matrix)?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/Projekte/snai_edge_int8_lora/docs/PHASE6_AUFGABEN.md (angelegt 2026-09-08 "bevor die erste Zahl existiert", Diagonale am 2026-09-22 vor jeder Messung auf SFT-Gemma verlegt).):
  Phase-6-Matrix: jeder Adapter wird auf allen vier Prüfsätzen ausgewertet (SFT-Gemma, SFT-HF, Prosa, Enzyklopädie), eingetragen wird der gepaarte Gewinn gegen den jeweiligen Nullpunkt. Arm instruktion muss auf SFT-Gemma gewinnen; SFT-HF ist Lesart, kein Kriterium. "Wechselbare Aufgabenadapter" gelten als belegt genau dann, wenn die Diagonale dominiert.
Plan: rechner-a:~/Projekte/snai_edge_int8_lora/docs/PHASE6_AUFGABEN.md, docs/PHASE6_ADAPTER.md
Baut auf: snai/lora-verfahren
Darauf baut: snai/phase6b-strecke
Rezepte:
  r257 [2026-10-21] bash run_adapter.sh instruktion_probe_s11 factory/input/corpus_sft_gemma.txt factory/holdout_sft_gemma/ 8 6 0.0002
      quelltext: run_adapter.sh md5 0ea126f59a37…, tools/gepaart.py md5 d79fa3640f9c… (heutiger Stand); Basis prod512_probe_s11.snai md5 2c4583e064da…
      parameter: Korpus 1.842.890 B (md5 e5527b2d50c8…), Rang 8, 6 Epochen, LR 0,0002, Auswertung eval_held_out_full_i8.php gekappt auf 64 Fenster
      rechner: rechner-a
      logs: rechner-a:~/.cache/adapter_instruktion_probe_s11/lauf.log, train.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/heldout_full_i8_prod512_probe_s11_adapter_instruktion_probe_s11.jsonl (holdout_dir factory/holdout_sft_gemma/), heldout_full_i8_prod512_probe_s11_nullpunkt64.jsonl und heldout_full_i8_prod512_probe_s11.jsonl (holdout_dir factory/holdout_prod/), am 2026-10-21 ausgelesen; rechner-a:~/.cache/adapter_instruktion_probe_s11/lauf.log
  m2850 heldout_64_fenster | 4,50615 | Adapter instruktion_probe_s11 auf SFT-Gemma (holdout_sft_gemma) |  | 64
  m2851 heldout_64_fenster | 4,000745 | Basis ohne Adapter auf Enzyklopädie (holdout_prod), als Nullpunkt verwendet |  | 64
  m2852 heldout_alle_fenster | 4,116743 | Basis ohne Adapter auf Enzyklopädie (holdout_prod) |  | 632
  m2853 gemeldeter_gewinn | -0,5054 (t -9,8, 7/64 besser) | Adapter SFT-Gemma minus Basis Enzyklopädie (ungültige Paarung) |  | 64
  m2854 nullpunkt_auf_sft_gemma | nicht gemessen | Basis ohne Adapter
  m2855 verpflanzungsprobe | zeichengleich 4,50615 | Adapter am eigenen Modell und an der eingefrorenen Basis |  | 64
Ergebnis e228 [2026-10-21 19:42]: ungueltig
  Fazit: Die Messung beantwortet die Frage nicht: der Adapter wurde auf dem Instruktions-Prüfsatz SFT-Gemma gemessen, der "Nullpunkt" aber stammt von der Basis auf dem Enzyklopädie-Prüfsatz. Das Skript hat Fenster zweier verschiedener Texte gepaart. Die verbreitete Lesart "der Adapter verschlechtert den allgemeinen Held-out um 0,5 nats" (später korrigiert) ist damit hinfällig; gemessen ist weder ein Verlust auf dem allgemeinen Prüfsatz noch ein Gewinn auf dem Instruktions-Prüfsatz. Die darauf gestützte Folge "Stufe 2 fällt aus" hat keine Grundlage. Wer Phase 6 wieder aufnimmt, braucht zuerst den Nullpunkt der Basis auf holdout_sft_gemma und den Adapter auf holdout_prod; der Adapter liegt noch vor (factory/adapter/instruktion_probe_s11.lora).
  Offen: Alle vier Spalten der Matrix sind unbesetzt. run_adapter.sh prüft nicht, ob Nullpunkt und Adapter auf demselben Prüfsatz gemessen wurden.
  Datei: rechner-a:~/Projekte/snai_edge_int8_lora/docs/PHASE6_AUFGABEN.md
Chronik:
  2026-10-21 19:42 angelegt (Nachtrag: Kriterium aus rechner-a:~/Projekte/snai_edge_int8_lora/docs/PHASE6_AUFGABEN.md (angelegt 2026-09-08 "bevor die erste Zahl existiert", Diagonale am 2026-09-22 vor jeder Messung auf SFT-Gemma verlegt).)
  2026-10-21 19:42 Rezept r257
  2026-10-21 19:42 Status geplant -> laeuft (Rezept r257)
  2026-10-21 19:42 Messwerte m2850-m2855
  2026-10-21 19:42 Ergebnis e228: ungueltig
  2026-10-21 19:42 Status laeuft -> ausgewertet (Ergebnis e228)
```
