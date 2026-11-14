# snai/matriarchin-mix

```text
snai/matriarchin-mix - ausgewertet, begonnen 2026-08-26, angelegt 2026-10-21, zuletzt 2026-10-21 19:42
!! ohne Kriterium
Frage: Verbessert die Quotenerhöhung des SFT-Anteils im Kalibrierungs-Nektar (0,20 auf 0,50) auf Matriarchin-Ebene die Prompt-Bindung? Neuer Mix f7cfff E6 gegen alten Mix 1fdf68 E3 (Hauptreferenz) und 1557a2 E3 (Bug-Linie), je 60 Läufe bei T=0,25.
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Plan: rechner-a:~/Projekte/snai_edge/docs/inferenz/INFERENZ_MATRIARCHIN_MIX_AB.md
Baut auf: snai/prinzessin-sftmix
Rezepte:
  r256 [2026-10-21] cd experiments/matriarchin_mix_ab && bash run_ab.sh
      quelltext: run_ab.sh md5 0f7c5b1aac47…; Modelle f7cfff E6 (sha256 3b05a752…), 1fdf68 E3 (03e317f4…), 1557a2 E3
      parameter: Inferenz 6 Prompts x n=10 bei T=0,25, Gegenprobe T=0,90 n=10; Held-out gemeinsames factory/holdout (2046 Token)
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge/experiments/matriarchin_mix_ab/results/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/Projekte/snai_edge/experiments/matriarchin_mix_ab/results/kennzahlen.md, neu abgelesen (topic_own, topic_lift, Held-out); register_lock aus dem Bericht
  m2842 topic_own | 1/60 | f7cfff E6 neuer Mix |  | 60
  m2843 topic_own | 9/60 | 1fdf68 E3 alter Mix |  | 60
  m2844 topic_own | 1/60 | 1557a2 E3 Bug-Linie |  | 60
  m2845 topic_lift | 0,29 | f7cfff E6 |  | 60
  m2846 topic_lift | 1,03 | 1fdf68 E3 |  | 60
  m2847 topic_lift | 1,20 | 1557a2 E3 |  | 60
  m2848 heldout_2046_token | 4,842497 / 4,739318 / 4,41736 | f7cfff / 1fdf68 / 1557a2 |  | 1
  m2849 register_lock | 13/60 / 4/60 / 4/60 | f7cfff / 1fdf68 / 1557a2 |  | 60
Ergebnis e227 [2026-10-21 19:42]: beobachtung
  Fazit: Die Quotenerhöhung hat auf Matriarchin-Ebene die Prompt-Bindung nicht verbessert, sondern nach dieser Messung verschlechtert; keine der drei Matriarchinnen liegt über dem Zufallsniveau (topic_lift 1). Der Mix hat das Register verschoben (mehr Chat-Öffner), nicht die Bindung. Die Mix-These der Prinzessin-Stufe überträgt sich also nicht ohne Weiteres; als Erklärung blieb die Trainingsdauer je Stufe, ungeprüft.
  Offen: Kein kontrollierter Vergleich, n=10 je Prompt, Held-out nur 2046 Token.
  Datei: rechner-a:~/Projekte/snai_edge/docs/inferenz/INFERENZ_MATRIARCHIN_MIX_AB.md
Chronik:
  2026-10-21 19:42 angelegt (Nachtrag: Kein Kriterium vor dem Test; als Beleg für die Mix-These gedacht. Kein kontrollierter A/B (verschiedene Läufe, Epochenzahlen und Clipping-Stände).)
  2026-10-21 19:42 Rezept r256
  2026-10-21 19:42 Status geplant -> laeuft (Rezept r256)
  2026-10-21 19:42 Messwerte m2842-m2849
  2026-10-21 19:42 Ergebnis e227: beobachtung
  2026-10-21 19:42 Status laeuft -> ausgewertet (Ergebnis e227)
```
