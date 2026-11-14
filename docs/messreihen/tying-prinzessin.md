# snai/tying-prinzessin

```text
snai/tying-prinzessin - ausgewertet, begonnen 2026-08-29, angelegt 2026-10-21, zuletzt 2026-10-21 19:40
!! ohne Kriterium
Frage: Hauptzweig snai_edge, Prinzessin-Stufe (256 Dim, 1024 FFN, Ctx 1024, 4 Köpfe, FP32): Repliziert der Kollapsbefund der Drohne (gebunden kollabiert auf Definitionsfragen, ungebunden nicht)? Gebunden 6 Schichten / 6.818.816 Parameter gegen ungebunden 3 Schichten / 6.555.136; Leitfrage ist der Kollaps, nicht der Held-out (Arme nicht größengleich).
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Plan: rechner-a:~/Projekte/snai_edge/experiments/princess_tying_ab_clean/run_ab.sh
Baut auf: snai/tying-drohne
Darauf baut: snai/lora-tying-basis
Rezepte:
  r243 [2026-10-21] Lauf 1 (defekt: E1 mit 1 Kopf, E2-E4 mit 4): cd experiments/princess_tying_ab && bash run_ab.sh
      quelltext: run_ab.sh md5 045c1ce553b5…
      parameter: 4 Epochen à 14 MB frisch, LR 0,0005, WD 0,01, Dropout 0,1, LS 0,1; Proben def1/def2/ctl1/ctl2 je n=10
      seed: ungeseedet
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge/experiments/princess_tying_ab/results/
  r244 [2026-10-21] sauberer Lauf: cd experiments/princess_tying_ab_clean && bash run_ab.sh (Sidecars .heads vor dem Start auf 4, lib_check_heads.sh)
      quelltext: run_ab.sh md5 10be0e1e9d19…
      parameter: wie Lauf 1, Material bitgleich
      seed: Init-Saat 20260901 (INIT_SEED in run_ab.sh, über seed_prelude.php)
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge/experiments/princess_tying_ab_clean/results/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/Projekte/snai_edge/experiments/princess_tying_ab{,_clean}/results/summary.txt, am 2026-10-21 neu ausgezählt
  m2726 kollaps_gesamt | 0/160 | ungebunden | 20260901 | 160
  m2727 kollaps_gesamt | 10/160 | gebunden | 20260901 | 160
  m2728 kollaps_def2_E1_bis_E4 | 0/0/5/1 (je /10) | gebunden | 20260901 | 40
  m2729 kollaps_kontrollprompts | 3/80 | gebunden | 20260901 | 80
  m2730 kollaps_gesamt | 0/160 | ungebunden, Lauf 1 defekt (ungeseedet) |  | 160
  m2731 kollaps_gesamt | 15/160 | gebunden, Lauf 1 defekt (ungeseedet) |  | 160
  m2732 kollaps_def2_E1_bis_E4 | 0/3/6/2 (je /10) | gebunden, Lauf 1 defekt (ungeseedet) |  | 40
  m2733 heldout_E1_bis_E4 | 5,6042/5,2797/5,0615/4,9742 | ungebunden | 20260901 | 4
  m2734 heldout_E1_bis_E4 | 5,1206/4,8177/4,5786/4,4572 | gebunden | 20260901 | 4
  m2735 heldout_vorsprung_E1 | 1,392 | gebunden, Lauf 1 defekt (1-Kopf-Artefakt, ungeseedet) |  | 1
Ergebnis e217 [2026-10-21 19:40]: beobachtung
  Fazit: Der Armkontrast repliziert auf der Prinzessin-Stufe: gebunden 10/160 Kollapse, ungebunden 0/160. Die Spitze von def2 bei E3 kommt im sauberen Lauf wieder, war also kein Artefakt des Kopfwechsels. Der Kollaps trifft auch die Kontrollprompts, "nur Definitionsfragen" ist zu eng. Der Held-out-Vorsprung von gebunden zählt hier nicht, weil die Arme nicht größengleich sind. Für den Hauptzweig blieb es bei "kein Tying in die Schwarm-Pipeline". Der LoRA-Fork zeigte später, dass der Kollaps an der beweglichen Basis im Vortraining hängt (snai/lora-tying-basis). Ein zweiter sauberer Seed wurde nie gefahren.
  Offen: n=10 je Zelle, ein sauberer Lauf. Wortmaß blind für Zeichenentartung (Projektregel snai_edge_int8_lora, 2026-09-02). Lücke in flush() (Ziehung ohne Ausgabe fällt aus dem Nenner) nicht behoben, hier laut Nennerkontrolle nicht eingetreten.
  Datei: rechner-a:~/Projekte/snai_edge/experiments/princess_tying_ab_clean/ERGEBNIS.md, princess_tying_ab/WARNUNG_ARCHITEKTURWECHSEL.md
Chronik:
  2026-10-21 19:40 angelegt (Nachtrag: Kein Entscheidungskriterium vor den Läufen. Im sauberen Lauf stand die Leitfrage im Log-Kopf (results/run.log 2026-09-01 04:30: "Kollaps auf 'Was ist X?' - NICHT der Held-out"), aber ohne Urteilsregel. Eine ſ-Vorhersage wurde vor E4 notiert (ERGEBNIS.md Abschnitt 5); sie war nach eigener Auswertung nicht trennscharf.)
  2026-10-21 19:40 Rezept r243 (Lauf 1 (defekt: E1 mit 1 Kopf, E2-E4 mit 4))
  2026-10-21 19:40 Status geplant -> laeuft (Rezept r243)
  2026-10-21 19:40 Rezept r244 (sauberer Lauf)
  2026-10-21 19:40 Messwerte m2726-m2735
  2026-10-21 19:40 Ergebnis e217: beobachtung
  2026-10-21 19:40 Status laeuft -> ausgewertet (Ergebnis e217)
```
