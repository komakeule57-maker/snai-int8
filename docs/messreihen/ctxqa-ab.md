# snai/ctxqa-ab

```text
snai/ctxqa-ab - ausgewertet, begonnen 2026-08-30, angelegt 2026-10-21, zuletzt 2026-10-21 19:40
!! ohne Kriterium
Frage: Lässt sich In-Context-Nutzung antrainieren? Bringt eine SFT-Epoche auf Kontext-QA-Material (Kontext-QA-Sammler, 22.969 Beispiele, 10,06 MB) im Kontext-Test mit erfundenen Entitäten mehr Treffer als dieselbe Menge gewöhnliches SFT (Kontrollarm)? Basis chinchilla_e15 (md5 0f5aa7f0…, 256 Dim, Ctx 1024, 3 Schichten, 4 Köpfe, FP32, Hauptzweig snai_edge).
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Plan: rechner-a:~/Projekte/snai_edge/experiments/princess_ctxqa_ab/run_ab.sh
Darauf baut: snai/ctxqa-ablenker
Rezepte:
  r245 [2026-10-21] cd experiments/princess_ctxqa_ab && ./run_ab.sh 0
      quelltext: run_ab.sh md5 b9943aa41c48…; arm/libcortex.so = Fassung vom 18.08. (e5c6631b…)
      parameter: 2 Epochen, LR 0,00005, WD 0,01, Dropout 0,1, LS 0,1, 5 Threads je Arm; Kontext-Test n=10 je Fall, 5 Fälle, T=0,25; Held-out GEN und SFT
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge/experiments/princess_ctxqa_ab/results/run.log, summary.txt; Kontext-Test rechner-a:~/Projekte/snai_edge/experiments/context_test/results_results_ctxqa_ab_*
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/Projekte/snai_edge/experiments/princess_ctxqa_ab/results/run.log und summary.txt, am 2026-10-21 abgelesen
  m2736 kontext_test_ziel_mit_kontext | 1/50 | Basis E0 |  | 50
  m2737 kontext_test_ziel_mit_kontext | 40/50 | ctxqa E1 |  | 50
  m2738 kontext_test_ziel_ohne_kontext | 0/50 | ctxqa E1 |  | 50
  m2739 kontext_test_ziel_mit_kontext | 40/50 | ctxqa E2 |  | 50
  m2740 kontext_test_ziel_mit_kontext | 0/50 | plain E1 (Kontrolle) |  | 50
  m2741 kontext_test_ziel_mit_kontext | 1/50 | plain E2 (Kontrolle) |  | 50
  m2742 heldout_gen | 3,457885 | Basis E0 |  | 1
  m2743 heldout_gen | 4,007878 | ctxqa E1 |  | 1
  m2744 heldout_gen | 3,514238 | plain E1 |  | 1
  m2745 heldout_sft | 3,636406 | Basis E0 |  | 1
  m2746 heldout_sft | 4,126589 | ctxqa E1 |  | 1
  m2747 heldout_sft | 3,585494 | plain E1 |  | 1
Ergebnis e218 [2026-10-21 19:40]: beobachtung
  Fazit: Kontext-Extraktion lässt sich antrainieren: nach einer Epoche Kontext-QA findet das Modell das Zielwort in 40 von 50 Fällen, ohne Kontext in keinem, und gewöhnliches SFT bleibt bei 0 bis 1. Der Preis sind +0,55 nats GEN-Held-out. Ob das Auswahl ist oder nur Umformulieren des einzigen gelieferten Satzes, beantwortet dieser Lauf nicht; das klärte erst die Ablenker-Gegenprobe (snai/ctxqa-ablenker). Eine zweite Epoche bringt nichts dazu.
  Offen: Ein Lauf, keine Saat, n=10 je Fall. Kein Kriterium vorab.
  Datei: rechner-a:~/Projekte/snai_edge/experiments/princess_ctxqa_ab/results/run.log; Einordnung in rechner-a:~/Projekte/snai_edge/experiments/context_test/ABLENKER_ERGEBNIS.md
Chronik:
  2026-10-21 19:40 angelegt (Nachtrag: Kein Entscheidungskriterium vor dem Lauf. Kopf von run_ab.sh (2026-08-30) und Log-Kopf nennen nur die Leitfrage ("Kontext-Test (erfundene Entitäten), NICHT der Held-out") und den Kontrollarm.)
  2026-10-21 19:40 Rezept r245
  2026-10-21 19:40 Status geplant -> laeuft (Rezept r245)
  2026-10-21 19:40 Messwerte m2736-m2747
  2026-10-21 19:40 Ergebnis e218: beobachtung
  2026-10-21 19:40 Status laeuft -> ausgewertet (Ergebnis e218)
```
