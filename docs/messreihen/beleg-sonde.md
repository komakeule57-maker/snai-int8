# snai/beleg-sonde

```text
snai/beleg-sonde - ausgewertet, begonnen 2026-09-12, angelegt 2026-10-21, zuletzt 2026-10-21 19:43
Frage: RAG-Voraussetzung am Produktivlauf prod512: Wird zwischen s6 und s19 der Nutzen eines passenden Belegs (Schicht A: seltene Zieltoken, die im Beleg stehen) größer, sowohl als Mechanismus (passend gegen fremd) wie als Wert (passend gegen ohne), und sinkt die nötige Mindest-Trefferquote eines Abrufs? Frühere Stände s1/s5/s6 als Verlauf.
Kriterium (nachgetragen, Beleg: Kriterium "vorab" für den Vergleich s6 gegen s19 (2026-10-07); die Messungen s1/s5/s6 (2026-09-13/14) liefen ohne Kriterium und stehen hier als Verlauf. Messaufbau und Zwei-Fragen-Trennung wie früher festgelegt.):
  Schicht A (Zieltoken Häufigkeitsrang >= 200, die im passenden Beleg stehen); eine Veränderung s6 nach s19 zählt nur bei gepaarter Differenz > 2 SE UND > 10 % relativ. Mindest-Trefferquote = Schaden / (Gewinn + Schaden).
Plan: rechner-a:~/Projekte/snai_edge_int8_lora/diagnose/beleg_sonde.php
Darauf baut: snai/rag-abruf
Rezepte:
  r258 [2026-10-21] bash run_beleg_sonde.sh factory/checkpoints/prod512_s<N>.snai 120; Vergleich python3 tools/vergleich_beleg_sonde.py <alt.jsonl> <neu.jsonl>
      quelltext: diagnose/beleg_sonde.php md5 d1e13cc07843…, run_beleg_sonde.sh md5 e4104d9f5977…, tools/vergleich_beleg_sonde.py md5 a87fab7f8749… (heutiger Stand)
      parameter: 120 Posten aus factory/holdout_prod/ho_prod.txt, Beleg 320 Token, Präfix 24, Antwortspanne 128, Lücke >= 64; Arme passend, fremd_a, fremd_b, ohne; SNAI_FORCE_CPU=1
      seed: 20260912
      rechner: rechner-a (s1-s6, Laptop) und rechner-b (s19; Kontrolle s6 mit 10 Posten identisch)
      logs: rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/beleg_sonde_prod512_s{1,5,6,19}.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: tools/vergleich_beleg_sonde.py auf rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/beleg_sonde_prod512_s1/s6/s19.jsonl, am 2026-10-21 neu gerechnet (s1 gegen s6, s6 gegen s19); s5 und Trefferquoten, nicht nachgerechnet
  m2856 mechanismus_schicht_A (passend gegen fremd_a) | +0,0207 | prod512 s1 | 20260912 | 120
  m2857 mechanismus_schicht_A | +0,1181 | prod512 s6 | 20260912 | 120
  m2858 mechanismus_schicht_A | +0,2099 | prod512 s19 | 20260912 | 120
  m2859 delta_mechanismus s6 nach s19 | +0,0918 (SE 0,0192, t 4,8, +78 %) | s19 minus s6 | 20260912 | 120
  m2860 gewinn_schicht_A (passend gegen ohne) | +0,0163 | prod512 s1 | 20260912 | 120
  m2861 gewinn_schicht_A | +0,0435 | prod512 s5 | 20260912 | 120
  m2862 gewinn_schicht_A | +0,0451 | prod512 s6 | 20260912 | 120
  m2863 gewinn_schicht_A | +0,0787 | prod512 s19 | 20260912 | 120
  m2864 delta_gewinn s6 nach s19 | +0,0336 (SE 0,0126, t 2,7, +75 %) | s19 minus s6 | 20260912 | 120
  m2865 rauschboden fremd_a gegen fremd_b, Schicht A | +0,0060 / +0,0321 (t 1,3) | s6 / s19 | 20260912 | 120
  m2866 mindest_trefferquote | 62 % / 63 % | s6 / s19 (Zufallsbeleg als Schaden) | 20260912 | 120
  m2867 mindest_trefferquote | 47 % / 46 % | s6 / s19 (thematisch nächster Fehlgriff) | 20260912 | 120
  m2868 kontrolle_besser_ohne_beleg s6 nach s19 | +0,4371 (t 10,1) | Arm ohne, Schicht A | 20260912 | 120
Ergebnis e229 [2026-10-21 19:43]: teilweise
  Fazit: Das Lesen des Belegs ist mit dem Training gewachsen: Mechanismus und Wert in Schicht A legen von s6 nach s19 je rund 75 % zu, beides über der Vorab-Schwelle. Die nötige Trefferquote eines Abrufs bleibt aber gleich (62 auf 63 %), weil der Schaden eines falschen Belegs im selben Maß wächst. Für die Planung heißt das: auf spätere Segmente zu warten macht RAG nicht leichter. Gemessen ist Kopieren seltener Token aus dem Kontext, keine Frage-Antwort-Aufgabe; diese Lücke war der eigentliche Engpass (snai/kopier-prod512-qa).
  Offen: Nur zwei Punkte unter dem Kriterium. Das A/A-Rauschen bei s19 (+0,0321) ist fast so groß wie der Gewinn-Zuwachs; der Mechanismus-Zuwachs trägt, der Gewinn-Zuwachs knapp.
Chronik:
  2026-10-21 19:43 angelegt (Nachtrag: Kriterium "vorab" für den Vergleich s6 gegen s19 (2026-10-07); die Messungen s1/s5/s6 (2026-09-13/14) liefen ohne Kriterium und stehen hier als Verlauf. Messaufbau und Zwei-Fragen-Trennung wie früher festgelegt.)
  2026-10-21 19:43 Rezept r258
  2026-10-21 19:43 Status geplant -> laeuft (Rezept r258)
  2026-10-21 19:43 Messwerte m2856-m2868
  2026-10-21 19:43 Ergebnis e229: teilweise
  2026-10-21 19:43 Status laeuft -> ausgewertet (Ergebnis e229)
```
