# snai/matriarchin-sft

```text
snai/matriarchin-sft - ausgewertet, begonnen 2026-08-29, angelegt 2026-10-21, zuletzt 2026-10-21 19:42
!! ohne Kriterium
Frage: Leistet die getrennte SFT-Phase (Rezept der Prinzessin: 1 Zehntel der Vortrainings-LR, gleiche Daten je Epoche) eine Stufe höher dasselbe? Basis GEN-Matriarchin 1fdf68 E3 (512 Dim, Ctx 2048, 6 Schichten, 8 Köpfe), 10,4 MB SFT, 2 Epochen.
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Plan: rechner-a:~/Projekte/snai_edge/docs/inferenz/INFERENZ_MATRIARCHIN_SFT_FINETUNE.md
Baut auf: snai/prinzessin-sft
Rezepte:
  r255 [2026-10-21] cd experiments/matriarchin_sft_finetune && bash run_finetune.sh; danach compare_inference.sh 0 1 2
      quelltext: run_finetune.sh md5 3292828d054b…
      parameter: 10.877.971 B, 16.860 Beispiele, effektive LR E1 5e-5, E2 5e-6
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge/experiments/matriarchin_sft_finetune/results/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/Projekte/snai_edge/experiments/matriarchin_sft_finetune/results/summary.txt und inferenz_e*_kennzahlen.txt (topic_own neu abgelesen); leere Antworten aus dem Bericht
  m2835 topic_own | 7/30 | E0 Basis |  | 30
  m2836 topic_own | 5/30 | E1 |  | 30
  m2837 topic_own | 0/30 | E2 |  | 30
  m2838 leere_antworten | 0/30 / 3/30 / 7/30 | E0 / E1 / E2 |  | 30
  m2839 heldout_sft | 4,917733 / 4,705307 / 4,687965 | E0 / E1 / E2 |  | 1
  m2840 heldout_gen | 4,910559 / 5,00758 / 5,003488 | E0 / E1 / E2 |  | 1
  m2841 kontextsonde | 0/50 | E0, E1, E2 |  | 50
Ergebnis e226 [2026-10-21 19:42]: beobachtung
  Fazit: Das Prinzessin-Rezept trägt auf der Matriarchin nicht: die Themenbindung verschwindet statt zu entstehen (7, 5, 0 von 30), und bei der Definitionsfrage kollabiert das Modell in leere Antworten, während der SFT-Held-out besser wird. Die Zwei-Phasen-SFT wurde für die Matriarchin nicht weiterverfolgt. Offen blieb, ob zu wenig SFT-Material oder eine zu kurz vortrainierte Basis die Ursache ist.
  Offen: Ein Lauf, n=10 je Prompt; eos_ok zählt leere Antworten als sauberen Stopp (im Bericht benannt).
  Datei: rechner-a:~/Projekte/snai_edge/docs/inferenz/INFERENZ_MATRIARCHIN_SFT_FINETUNE.md
Chronik:
  2026-10-21 19:42 angelegt (Nachtrag: Kein Kriterium vor dem Lauf; Verhaltenskennzahlen am 2026-08-30 nachträglich gemessen.)
  2026-10-21 19:42 Rezept r255
  2026-10-21 19:42 Status geplant -> laeuft (Rezept r255)
  2026-10-21 19:42 Messwerte m2835-m2841
  2026-10-21 19:42 Ergebnis e226: beobachtung
  2026-10-21 19:42 Status laeuft -> ausgewertet (Ergebnis e226)
```
