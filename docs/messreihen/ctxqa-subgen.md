# snai/ctxqa-subgen

```text
snai/ctxqa-subgen - ausgewertet, begonnen 2026-08-31, angelegt 2026-10-21, zuletzt 2026-10-21 19:41
!! ohne Kriterium
Frage: Gibt es unterhalb von 1 MB GEN-Nachphase (0,2 und 0,5 MB, unabhängige Arme von ctxqa_e1, Byte-Präfixe des d1-Materials) einen Stand, auf dem Kontext-Auswahl und Held-out-Erholung zugleich vorhanden sind?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Plan: rechner-a:~/Projekte/snai_edge/experiments/princess_ctxqa_subgen/run_subgen.sh
Baut auf: snai/ctxqa-genback
Rezepte:
  r249 [2026-10-21] cd experiments/princess_ctxqa_subgen && php build_sub_slices.php … && bash run_subgen.sh
      quelltext: run_subgen.sh md5 e5c3fe471dd2…
      parameter: Arme s02 (0,2 MB) und s05 (0,5 MB), Hyperparameter wie d1
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge/experiments/princess_ctxqa_subgen/results/; rechner-a:~/Projekte/snai_edge/experiments/context_test/results_{,abl_}sg_s*
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/Projekte/snai_edge/experiments/princess_ctxqa_subgen/results/summary.txt und rechner-a:~/Projekte/snai_edge/experiments/context_test/results_abl_sg_*/ergebnis.txt, neu abgelesen
  m2792 heldout_gen | 3,567717 | s02 0,2 MB |  | 1
  m2793 heldout_gen | 3,52285 | s05 0,5 MB |  | 1
  m2794 extraktion_form | 40/50 | s02 |  | 50
  m2795 extraktion_form | 40/50 | s05 |  | 50
  m2796 extraktion_ziel_roh | 44/50 | s02 |  | 50
  m2797 extraktion_ziel_roh | 48/50 | s05 |  | 50
  m2798 auswahl_gleich | 2/50 | s02 |  | 50
  m2799 auswahl_gleich | 0/50 | s05 |  | 50
  m2800 fehl_gleich | 8/50 | s02 |  | 50
  m2801 fehl_gleich | 17/50 | s05 |  | 50
Ergebnis e222 [2026-10-21 19:41]: beobachtung
  Fazit: Einen gemeinsamen Arbeitspunkt gibt es nicht: schon 0,2 MB GEN nehmen 88 % der Auswahl weg (17 auf 2 von 50), bevor der Held-out zu 80 % erholt ist. Die Extraktion bleibt bei 0,2 und 0,5 MB exakt auf 40/50. Rezept für Extraktion: Kontext-QA-Phase plus 0,2 MB GEN. RAG wurde für diese Modellstufe damit vertagt. Methodisch wichtig: die Rohmetrik hätte einen Scheintrend "GEN verbessert die Extraktion" (40, 44, 48) gezeigt; der Anstieg kam ganz aus einem Teilstring-Treffer (Fluss in Flusses).
  Offen: Eine Saat je Punkt, n=10 je Zelle; unter 0,2 MB nicht gemessen.
  Datei: rechner-a:~/Projekte/snai_edge/experiments/princess_ctxqa_subgen/ERGEBNIS.md
Chronik:
  2026-10-21 19:41 angelegt (Nachtrag: Kein Kriterium vor dem Lauf.)
  2026-10-21 19:41 Rezept r249
  2026-10-21 19:41 Status geplant -> laeuft (Rezept r249)
  2026-10-21 19:41 Messwerte m2792-m2801
  2026-10-21 19:41 Ergebnis e222: beobachtung
  2026-10-21 19:41 Status laeuft -> ausgewertet (Ergebnis e222)
```
