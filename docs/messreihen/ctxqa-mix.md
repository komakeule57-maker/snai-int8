# snai/ctxqa-mix

```text
snai/ctxqa-mix - ausgewertet, begonnen 2026-08-31, angelegt 2026-10-21, zuletzt 2026-10-21 19:41
!! ohne Kriterium
Frage: Liefert ein kleinerer Anteil Kontext-QA im SFT-Material (10 % bzw. 30 %, je eine Epoche, 10,06 MB) die Kontext-Extraktion billiger als 100 %? Basis chinchilla_e15 (md5 0f5aa7f0…, 256 Dim, Ctx 1024, 3 Schichten, 4 Köpfe, FP32, Hauptzweig snai_edge).
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Plan: rechner-a:~/Projekte/snai_edge/experiments/princess_ctxqa_mix/run_mix.sh
Baut auf: snai/ctxqa-ablenker
Darauf baut: snai/ctxqa-genback
Rezepte:
  r247 [2026-10-21] cd experiments/princess_ctxqa_mix && php mix_pool.php … && bash run_mix.sh
      quelltext: run_mix.sh md5 0e698e28a6e5…; Engine wie snai/ctxqa-ab
      parameter: Arme mix10, mix30, mix100 (100 % durchmischt), je 1 Epoche, Hyperparameter wie ctxqa-ab; erster Start 08:15 mit 1 Kopf verworfen
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge/experiments/princess_ctxqa_mix/results/; rechner-a:~/Projekte/snai_edge/experiments/context_test/results_{,abl_}mix_mix*
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/Projekte/snai_edge/experiments/princess_ctxqa_mix/results/summary.txt und rechner-a:~/Projekte/snai_edge/experiments/context_test/results_abl_mix_*/ergebnis.txt, neu abgelesen; form-Spalte aus ERGEBNIS.md
  m2762 heldout_gen | 3,525161 | mix10 |  | 1
  m2763 heldout_gen | 3,537633 | mix30 |  | 1
  m2764 heldout_gen | 4,014652 | mix100 |  | 1
  m2765 extraktion_nur | 2/50 | mix10 |  | 50
  m2766 extraktion_nur | 4/50 | mix30 |  | 50
  m2767 extraktion_nur | 40/50 | mix100 |  | 50
  m2768 extraktion_form | 0/50 | mix10 |  | 50
  m2769 extraktion_form | 3/50 | mix30 |  | 50
  m2770 extraktion_form | 39/50 | mix100 |  | 50
  m2771 auswahl_gleich | 0/50 | mix10 |  | 50
  m2772 auswahl_gleich | 0/50 | mix30 |  | 50
  m2773 auswahl_gleich | 10/50 | mix100 |  | 50
  m2774 auswahl_gleich | 17/50 | ctxqa_e1 (gleiches Material, Sammlerreihenfolge) |  | 50
  m2775 extraktion_nur | 1/50 | plain_e1 (0 %) |  | 50
Ergebnis e220 [2026-10-21 19:41]: beobachtung
  Fazit: Es gibt keinen billigen Anteil: 10 % und 30 % Kontext-QA liegen auf Nullniveau und zahlen trotzdem schon etwas Held-out, erst 100 % erzeugt die Fähigkeit. Kontext-QA geht also nur als eigene Phase, nicht als Beimischung; der Plan "20-30 % im SFT-Mix" ist tot. Nebenbei widerlegt der Lauf die Materialmengen-Erklärung der Ablenker-Gegenprobe: dasselbe Material in anderer Reihenfolge dreht das Typmuster der Auswahl um (ort 9 auf 0, jahr 8 auf 10).
  Offen: Eine Saat, n=10 je Zelle. Ob 3 MB Kontext-QA als eigene Phase wirken, nicht gemessen.
  Datei: rechner-a:~/Projekte/snai_edge/experiments/princess_ctxqa_mix/ERGEBNIS.md
Chronik:
  2026-10-21 19:41 angelegt (Nachtrag: Kein Kriterium vor dem Lauf (ERGEBNIS.md nennt nur die Frage).)
  2026-10-21 19:41 Rezept r247
  2026-10-21 19:41 Status geplant -> laeuft (Rezept r247)
  2026-10-21 19:41 Messwerte m2762-m2775
  2026-10-21 19:41 Ergebnis e220: beobachtung
  2026-10-21 19:41 Status laeuft -> ausgewertet (Ergebnis e220)
```
