# snai/ctxqa-genback

```text
snai/ctxqa-genback - ausgewertet, begonnen 2026-08-31, angelegt 2026-10-21, zuletzt 2026-10-21 19:41
!! ohne Kriterium
Frage: Holt eine GEN-Nachphase nach der Kontext-QA-Phase (ctxqa_e1) den GEN-Held-out zurück, ohne die Kontext-Fähigkeit zu verlieren? Kumulative Dosis 1,0 / 2,6 / 5,2 / 10,5 MB frisches GEN.
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Plan: rechner-a:~/Projekte/snai_edge/experiments/princess_ctxqa_genback/run_genback.sh
Baut auf: snai/ctxqa-mix
Darauf baut: snai/ctxqa-subgen
Rezepte:
  r248 [2026-10-21] cd experiments/princess_ctxqa_genback && php build_gen_slices.php … && bash run_genback.sh
      quelltext: run_genback.sh md5 997ad04f66cb…
      parameter: 4 Phasen auf einer Linie (d1-d4), je frisches GEN; Kontrolle ctxqa_e2 (+10 MB Kontext-QA)
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge/experiments/princess_ctxqa_genback/results/; rechner-a:~/Projekte/snai_edge/experiments/context_test/results_{,abl_}gb_d*
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/Projekte/snai_edge/experiments/princess_ctxqa_genback/results/summary.txt, rechner-a:~/Projekte/snai_edge/experiments/context_test/results_gb_d*/ergebnis.txt und results_abl_gb_d*/ergebnis.txt, am 2026-10-21 neu summiert
  m2776 heldout_gen | 4,007878 | E0 ctxqa_e1 |  | 1
  m2777 heldout_gen | 3,501765 | d1 1,0 MB |  | 1
  m2778 heldout_gen | 3,479995 | d2 2,6 MB |  | 1
  m2779 heldout_gen | 3,471439 | d3 5,2 MB |  | 1
  m2780 heldout_gen | 3,462626 | d4 10,5 MB |  | 1
  m2781 heldout_gen | 4,062877 | Kontrolle ctxqa_e2 |  | 1
  m2782 heldout_gen | 3,457885 | Zielmarke chinchilla_e15 |  | 1
  m2783 extraktion_ziel_roh | 43/50 | d1 |  | 50
  m2784 extraktion_form | 37/50 | d1 |  | 50
  m2785 extraktion_ziel_roh | 39/50 | d2 |  | 50
  m2786 extraktion_ziel_roh | 27/50 | d3 |  | 50
  m2787 extraktion_ziel_roh | 19/50 | d4 |  | 50
  m2788 auswahl_gleich | 17/50 | E0 |  | 50
  m2789 auswahl_gleich | 0/50 | d1 |  | 50
  m2790 fehl_gleich | 19/50 | d1 |  | 50
  m2791 auswahl_gleich | 0/50 | d2 |  | 50
Ergebnis e221 [2026-10-21 19:41]: beobachtung
  Fazit: Die Extraktion ist billig zu haben: 1 MB GEN danach holt 92 % der Held-out-Kosten zurück und lässt die Extraktion fast stehen. Die Auswahl unter typgleichen Ablenkern ist dagegen nach 1 MB ganz weg und schlägt in Falschauswahl um. Dieselbe Intervention zerstört die eine Fähigkeit und lässt die andere stehen, das ist der stärkste Beleg, dass es zwei sind. Ob ein kleinerer Schluck GEN die Auswahl hält, klärt snai/ctxqa-subgen.
  Offen: Eine Linie, eine Saat, n=10 je Zelle; 2,5 % Materialüberschneidung mit dem Vortraining (Held-outs sauber). Die Tabelle in ERGEBNIS.md mischt Extraktionstest und Ablenker-Bedingung "nur"; hier stehen die Rohwerte des Extraktionstests.
  Datei: rechner-a:~/Projekte/snai_edge/experiments/princess_ctxqa_genback/ERGEBNIS.md
Chronik:
  2026-10-21 19:41 angelegt (Nachtrag: Kein Kriterium vor dem Lauf.)
  2026-10-21 19:41 Rezept r248
  2026-10-21 19:41 Status geplant -> laeuft (Rezept r248)
  2026-10-21 19:41 Messwerte m2776-m2791
  2026-10-21 19:41 Ergebnis e221: beobachtung
  2026-10-21 19:41 Status laeuft -> ausgewertet (Ergebnis e221)
```
