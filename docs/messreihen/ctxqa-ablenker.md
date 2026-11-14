# snai/ctxqa-ablenker

```text
snai/ctxqa-ablenker - ausgewertet, begonnen 2026-08-31, angelegt 2026-10-21, zuletzt 2026-10-21 19:40
!! ohne Kriterium
Frage: Wählt das Kontext-QA-Modell (ctxqa_e1 aus snai/ctxqa-ab) die richtige Stelle aus, wenn neben dem Zielsatz Ablenker im Prompt stehen (typfremd, typgleich, Ziel zuletzt, kein Ziel)?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Plan: rechner-a:~/Projekte/snai_edge/experiments/context_test/run_distractor_test.sh
Baut auf: snai/ctxqa-ab
Darauf baut: snai/ctxqa-mix
Rezepte:
  r246 [2026-10-21] cd experiments/context_test && bash run_distractor_all.sh (je Modell run_distractor_test.sh <modell>); Nachwertung bash rescore_form.sh
      quelltext: run_distractor_test.sh md5 ebf72065be98…, rescore_form.sh md5 9d6e24610e91…
      parameter: 6 Bedingungen x 5 Fälle x n=10, T=0,25; Metriken name/ziel/fehl, später form
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge/experiments/context_test/ablenker_lauf.log, results_abl_{base,plain_e1,ctxqa_e1,ctxqa_e2}/ergebnis.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/Projekte/snai_edge/experiments/context_test/results_abl_*/ergebnis.txt, am 2026-10-21 neu summiert; Rahmenmetrik und Typaufteilung aus ABLENKER_ERGEBNIS.md
  m2748 ziel_nur | 40/50 | ctxqa_e1 |  | 50
  m2749 ziel_misch | 35/50 | ctxqa_e1 |  | 50
  m2750 ziel_gleich | 17/50 | ctxqa_e1 |  | 50
  m2751 ziel_gl_end | 20/50 | ctxqa_e1 |  | 50
  m2752 ziel_leer | 0/50 | ctxqa_e1 |  | 50
  m2753 fehl_leer | 19/50 | ctxqa_e1 |  | 50
  m2754 ziel_ohne | 0/50 | ctxqa_e1 |  | 50
  m2755 ziel_gleich | 18/50 | ctxqa_e2 |  | 50
  m2756 ziel_gleich | 0/50 | plain_e1 (Kontrolle) |  | 50
  m2757 ziel_gleich | 3/50 | Basis |  | 50
  m2758 ziel_gl_end | 9/50 | Basis |  | 50
  m2759 form_gl_end | 6/50 | Basis (Rahmenmetrik) |  | 50
  m2760 form_leer | 0/50 | Basis (Rahmenmetrik) |  | 50
  m2761 ziel_gleich_je_typ | ort 9/10, jahr 8/10, zahl 0/10, farbe 0/10, kategorie 0/10 | ctxqa_e1 |  | 50
Ergebnis e219 [2026-10-21 19:40]: beobachtung
  Fazit: Belegt sind zwei verschiedene Fähigkeiten. Extraktion: 40/50, typfremde Ablenker kosten fast nichts. Auswahl unter typgleichen Ablenkern: nur 17/50, aber echt, denn ohne Zielsatz trifft das Modell 0/50. Die Erklärung über die Materialmenge je Fakttyp hielt nicht: noch am selben Tag widerlegt durch snai/ctxqa-mix (Reihenfolge allein dreht das Typmuster). Bleibt: Auswahl ist die fragile Fähigkeit, und daran hängt jeder Nutzen von RAG auf dieser Stufe.
  Offen: n=10 je Zelle, Typ und Materialmenge konfundiert. Kein Kriterium vorab.
  Datei: rechner-a:~/Projekte/snai_edge/experiments/context_test/ABLENKER_ERGEBNIS.md
Chronik:
  2026-10-21 19:40 angelegt (Nachtrag: Kein Kriterium vor dem Lauf; als Eichung war vorab festgelegt, dass die Bedingungen nur/ohne byte-identisch zum Original sind und 40/50 bzw. 0/50 reproduzieren müssen (ABLENKER_ERGEBNIS.md, Abschnitt Kalibrierung).)
  2026-10-21 19:40 Rezept r246
  2026-10-21 19:40 Status geplant -> laeuft (Rezept r246)
  2026-10-21 19:40 Messwerte m2748-m2761
  2026-10-21 19:40 Ergebnis e219: beobachtung
  2026-10-21 19:40 Status laeuft -> ausgewertet (Ergebnis e219)
```
