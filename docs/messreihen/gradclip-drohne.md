# snai/gradclip-drohne

```text
snai/gradclip-drohne - ausgewertet, begonnen 2026-08-20, angelegt 2026-10-21, zuletzt 2026-10-21 19:42
!! ohne Kriterium
Frage: Hauptzweig snai_edge, Drohne (8192 Vocab, 128 Dim, 512 FFN, Ctx 512, 2 Schichten, 2 Köpfe, FP32): Ändert allein die Clip-Schwelle (Fix vom 18.08.: Norm im Mittelwert-Raum, libcortex ed2972cd… gegen Bug 52be5faa…, Norm im Summen-Raum) bei sonst bitgleichen Bedingungen Trainingsverlauf, Held-out und Inferenzverhalten, und in welche Richtung?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Plan: rechner-a:~/Projekte/snai_edge/experiments/gradclip_ab/README.md
Darauf baut: snai/gradclip-knirps-kurz
Rezepte:
  r250 [2026-10-21] Lauf 1 (ein Chunk, 3 Epochen): cd experiments/gradclip_ab && ./run_ab.sh 3
      quelltext: run_ab.sh md5 f21b06c8e4da…; arm_fixed/libcortex.so ed2972cd3ba86f802aa981da26a688c2, arm_bug/libcortex.so 52be5faa28c544b7f0332cd3e13082de
      parameter: Basis base/base.snai (md5 91ae00eb…, enthält Adam-Zustand), Trainingsdaten data/train_chunk.txt (879 KB, md5 b768a75d…), Held-out 2,1 MB (md5 3725423f…), LR 0,0002, WD 0,01, LS 0,1, Dropout 0, OMP 4
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge/experiments/gradclip_ab/results/20260820_064625/, run_ab_stdout.log
  r251 [2026-10-21] Lauf 2 (4 frische Chunks, je einmal): cd experiments/gradclip_ab && ./run_ab2.sh
      quelltext: run_ab2.sh md5 a0e8cee3d688…; Bibliotheken wie Lauf 1
      parameter: Chunks 2,1/1,7/2,1/2,1 MB (md5 ea5b3daa…, 5672a695…, ba80afed…, 3c838dab…), Held-out 512 KB (md5 0fce2bf6…); Inferenz n=8 je Prompt, 3 Prompts
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge/experiments/gradclip_ab/results2/20260820_095231/, run_ab2_stdout.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/Projekte/snai_edge/experiments/gradclip_ab/run_ab_stdout.log und run_ab2_stdout.log, am 2026-10-21 abgelesen; Determinismus aus README.md
  m2802 determinismus_wiederholung | bitgleiche Checkpoints (6a20ef3c… / 4d988d67…) | Smoke 82 Schritte, beide Arme |  | 2
  m2803 heldout_E1/E2/E3 | 8,004817 / 7,888876 / 7,902257 | fixed, Lauf 1 |  | 1
  m2804 heldout_E1/E2/E3 | 7,803114 / 7,762373 / 7,752038 | bug, Lauf 1 |  | 1
  m2805 recent_loss_E3 | 4,693342 | fixed, Lauf 1 |  | 1
  m2806 recent_loss_E3 | 4,905927 | bug, Lauf 1 |  | 1
  m2807 heldout_C1/C2/C3/C4 | 6,326293 / 6,061678 / 5,789945 / 5,643124 | fixed, Lauf 2 |  | 1
  m2808 heldout_C1/C2/C3/C4 | 6,583817 / 6,197633 / 5,888511 / 5,674495 | bug, Lauf 2 |  | 1
  m2809 gradnorm_mittel_C4 | 1,5459 | fixed, Lauf 2 |  | 245
  m2810 gradnorm_mittel_C4 | 811,3626 | bug, Lauf 2 |  | 245
  m2811 wiederholungsquote_WS | 12,9 % | fixed, Lauf 2 |  | 24
  m2812 wiederholungsquote_WS | 10,7 % | bug, Lauf 2 |  | 24
  m2813 laeufe_mit_unk | 7/24 | fixed, Lauf 2 |  | 24
  m2814 laeufe_mit_unk | 8/24 | bug, Lauf 2 |  | 24
Ergebnis e223 [2026-10-21 19:42]: beobachtung
  Fazit: Auf frischen Daten (Lauf 2) liefert der Clipping-Fix an allen vier Messpunkten den besseren Held-out, der Vorsprung schrumpft aber von 0,26 auf 0,03 nats; im Verhalten (n=24) ist kein Unterschied zu sehen. Lauf 1 (ein 879-KB-Chunk dreimal) zeigt das Gegenteil im Held-out und taugt wegen der Wiederholung desselben Materials nicht als Optimierer-Vergleich. Der Fix blieb drin; dass er bei großen Modellen dieselbe Richtung hat, ist damit nicht gezeigt (die unkontrollierte Matriarchin-Reihe zeigte das Gegenteil). Der Aufbau ist das Wertvolle: zwei Arme, die sich in genau einer Bibliothek unterscheiden und deterministisch rechnen.
  Offen: Kein Kriterium vorab, ein Lauf je Arm (deterministisch, also kein Saatrauschen, aber eine Datenreihenfolge). Nulllinie für das 512-KB-Held-out von Lauf 2 laut Log nicht gemessen. Tier-Sprung-Hypothese (Net2Net) nicht getestet.
  Datei: rechner-a:~/Projekte/snai_edge/experiments/gradclip_ab/README.md
Chronik:
  2026-10-21 19:42 angelegt (Nachtrag: Kein Entscheidungskriterium vor dem Lauf; README.md (2026-08-20) legt nur fest, was der Test beantworten kann und was nicht.)
  2026-10-21 19:42 Rezept r250 (Lauf 1 (ein Chunk, 3 Epochen))
  2026-10-21 19:42 Status geplant -> laeuft (Rezept r250)
  2026-10-21 19:42 Rezept r251 (Lauf 2 (4 frische Chunks, je einmal))
  2026-10-21 19:42 Messwerte m2802-m2814
  2026-10-21 19:42 Ergebnis e223: beobachtung
  2026-10-21 19:42 Status laeuft -> ausgewertet (Ergebnis e223)
```
