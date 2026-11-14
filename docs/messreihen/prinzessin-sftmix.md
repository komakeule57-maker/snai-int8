# snai/prinzessin-sftmix

```text
snai/prinzessin-sftmix - ausgewertet, begonnen 2026-08-21, angelegt 2026-10-21, zuletzt 2026-10-21 19:42
!! ohne Kriterium
Frage: Hauptzweig snai_edge, Prinzessin (Vocab 8192, Dim 256, Ctx 1024, 3 Schichten, FFN 1024, FP32): Fehlt die Prompt-Bindung des Chinchilla-Laufs (~11 % SFT im Vortraining) am Mix oder an der Kapazität? Kontrolllauf mit ~69 % SFT, sonst gleich (Genesis, Held-out, Epochengröße, Hyperparameter, Inferenz-Harness); Leitmetrik topic_lift.
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Plan: rechner-a:~/Projekte/snai_edge/docs/inferenz/INFERENZ_SFTMIX_KONTROLLLAUF_E1_E3.md
Darauf baut: snai/prinzessin-sft, snai/matriarchin-mix
Rezepte:
  r252 [2026-10-21] cd experiments/princess_sftmix && bash run_sftmix.sh; Inferenz compare_inference.sh
      quelltext: run_sftmix.sh md5 ab2d6a887ea1…, compare_inference.sh md5 ba983f50206e…
      parameter: Genesis sha256 5df547331e02…, Pool 483 MB über bis zu 15 Epochen, LR 0,0005, WD 0,01, Dropout 0,1, LS 0,1, 4 Threads; Inferenz 3 Prompts x n=10, T=0,25
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge/experiments/princess_sftmix/results/ (run.log, summary.txt, inferenz_e*_kennzahlen.txt)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/Projekte/snai_edge/experiments/princess_sftmix/results/summary.txt, inferenz_e3_kennzahlen.txt; rechner-a:~/Projekte/snai_edge/experiments/princess_chinchilla/results/inferenz_e3_kennzahlen.txt (Held-out, distinct_run_starts); topic-Werte des Chinchilla-Laufs und geglätteter Lift aus dem Inferenzbericht (nicht nachgerechnet)
  m2815 topic_own_E3 | 13/30 | SFT-Mix 69 % |  | 30
  m2816 topic_foreign_E3 | 2/30 | SFT-Mix 69 % |  | 30
  m2817 distinct_run_starts_E3 | 22/30 | SFT-Mix 69 % |  | 30
  m2818 heldout_E3 | 4,393827 | SFT-Mix 69 % |  | 1
  m2819 topic_own_E3 | 1/15 | Chinchilla 11 % |  | 15
  m2820 topic_foreign_E3 | 3/15 | Chinchilla 11 % |  | 15
  m2821 distinct_run_starts_E3 | 6/15 | Chinchilla 11 % |  | 15
  m2822 heldout_E3 | 4,117072 | Chinchilla 11 % |  | 1
  m2823 topic_lift_geglaettet_E3 | 10,80 gegen 0,86 | SFT-Mix gegen Chinchilla |  | 1
  m2824 heldout_E11/E12/E13 | 3,827026 / 3,795416 / 3,792033 | SFT-Mix 69 % (Abbruch nach Regel) |  | 1
Ergebnis e224 [2026-10-21 19:42]: beobachtung
  Fazit: Bei gleicher Epoche 3 bindet der Lauf mit 69 % SFT die Antwort an den Prompt (13/30 eigenes Thema gegen 1/15), der mit 11 % nicht. Die fehlende Prompt-Bindung lag damit überwiegend am Mix, nicht an der Kapazität von 6,5 Mio. Parametern. Daraus folgte die Quotenerhöhung in der Schwarm-Pipeline auf 50 % SFT; auf Matriarchin-Ebene hat sie nicht geliefert (snai/matriarchin-mix). Die Kapazitätshypothese ist nicht widerlegt, nur nicht nötig.
  Offen: Ein Lauf je Arm, n=10 je Prompt. Später als Teil der Loss/Verhalten-Divergenz gelesen: Held-out ist hier ausdrücklich keine Leitgröße.
  Datei: rechner-a:~/Projekte/snai_edge/docs/inferenz/INFERENZ_SFTMIX_KONTROLLLAUF_E1_E3.md
Chronik:
  2026-10-21 19:42 angelegt (Nachtrag: Kein Entscheidungskriterium vor dem Lauf; vorab angekündigt war nur, dass der GEN-Held-out des Kontrollarms schlechter ausfallen werde (INFERENZ_SFTMIX_KONTROLLLAUF_E1_E3.md, Auswertung 2026-08-23). Die Abbruchregel (Held-out-Zugewinn fällt auf ~1/10 der Vorepoche) wurde während des Laufs festgelegt.)
  2026-10-21 19:42 Rezept r252
  2026-10-21 19:42 Status geplant -> laeuft (Rezept r252)
  2026-10-21 19:42 Messwerte m2815-m2824
  2026-10-21 19:42 Ergebnis e224: beobachtung
  2026-10-21 19:42 Status laeuft -> ausgewertet (Ergebnis e224)
```
