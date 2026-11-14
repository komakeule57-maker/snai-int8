# snai/prinzessin-sft

```text
snai/prinzessin-sft - ausgewertet, begonnen 2026-08-27, angelegt 2026-10-21, zuletzt 2026-10-21 19:42
!! ohne Kriterium
Frage: Trägt eine getrennte SFT-Phase nach dem Vortraining (chinchilla_e15, 36,3 MB reines SFT, Spitzen-LR 0,00005, Cosinus mit Boden) die Prompt-Bindung, und wie viele Epochen braucht sie?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Plan: rechner-a:~/Projekte/snai_edge/docs/inferenz/INFERENZ_PRINZESSIN_SFT_FINETUNE_E1_E3.md
Baut auf: snai/prinzessin-sftmix
Darauf baut: snai/matriarchin-sft
Rezepte:
  r253 [2026-10-21] dieselben Daten in 3 Epochen: cd experiments/princess_sft_finetune && bash run_finetune.sh; compare_inference.sh
      quelltext: run_finetune.sh md5 e40d24b1022c…
      parameter: 38.048.892 B, 91.981 Beispiele, effektive LR E1 5e-5, E2 2,5e-5, E3 5e-6
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge/experiments/princess_sft_finetune/results/
  r254 [2026-10-21] E2 mit frischem Material: cd experiments/princess_sft_fresh_e2 && bash run_e2.sh
      quelltext: run_e2.sh
      parameter: Basis sft_e1.snai, 38.048.892 B / 96.206 ungesehene Beispiele, LR effektiv 2,5e-5
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge/experiments/princess_sft_fresh_e2/results/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/Projekte/snai_edge/experiments/princess_sft_finetune/results/summary.txt und inferenz_e*_kennzahlen.txt, rechner-a:~/Projekte/snai_edge/experiments/princess_sft_fresh_e2/results/, neu abgelesen; Basiswerte aus dem Bericht
  m2825 topic_own | 5/30 | Basis e15 |  | 30
  m2826 topic_own | 20/30 | E1 |  | 30
  m2827 topic_own | 10/30 | E2 (gleiche Daten) |  | 30
  m2828 topic_own | 11/30 | E3 |  | 30
  m2829 topic_own | 11/30 | E2 frische Daten |  | 30
  m2830 eos_ok | 12/30 | Basis e15 |  | 30
  m2831 eos_ok | 29/30 | E1 |  | 30
  m2832 heldout_sft | 3,636406 / 3,499762 / 3,456507 / 3,447956 | Basis / E1 / E2 / E3 |  | 1
  m2833 heldout_gen | 3,457885 / 3,604453 / 3,630725 / 3,633617 | Basis / E1 / E2 / E3 |  | 1
  m2834 heldout_sft | 3,449318 | E2 frische Daten |  | 1
Ergebnis e225 [2026-10-21 19:42]: beobachtung
  Fazit: Der ganze Ertrag steckt in der ersten SFT-Epoche: Themenbindung vervierfacht, sauberer Stopp fast immer. Ab Epoche 2 gibt das Modell die Themenbindung zurück, auch mit frischem Material, während der SFT-Held-out weiter fällt. Loss und Verhalten zeigen hier in entgegengesetzte Richtungen. Regel für den Hauptzweig: eine SFT-Epoche. Eine Stufe höher trägt das Rezept nicht (snai/matriarchin-sft).
  Offen: Ein Lauf, n=10 je Prompt. LR nicht konstant (Cosinus), Epoche und LR sind konfundiert.
  Datei: rechner-a:~/Projekte/snai_edge/docs/inferenz/INFERENZ_PRINZESSIN_SFT_FINETUNE_E1_E3.md
Chronik:
  2026-10-21 19:42 angelegt (Nachtrag: Kein Kriterium vor dem Lauf.)
  2026-10-21 19:42 Rezept r253 (dieselben Daten in 3 Epochen)
  2026-10-21 19:42 Status geplant -> laeuft (Rezept r253)
  2026-10-21 19:42 Rezept r254 (E2 mit frischem Material)
  2026-10-21 19:42 Messwerte m2825-m2834
  2026-10-21 19:42 Ergebnis e225: beobachtung
  2026-10-21 19:42 Status laeuft -> ausgewertet (Ergebnis e225)
```
