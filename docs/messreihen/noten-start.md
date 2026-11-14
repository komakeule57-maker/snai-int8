# snai/noten-start

```text
snai/noten-start - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:20
Frage: Lernt ein Knirps 32/2/16 mit 2 Schichten auf Melodien (Vokabular noten, 104 Einträge; 1.980 Melodien aus Essen-Sammlung und LLM-Generator, 8 Epochen, Rezept FALL) mehr als Uni-, Bi- und Trigramm?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/noten/kriterien.txt, Kopf "KNIRPS AUF NOTEN (2026-10-14) - Kriterien VOR dem ersten Lauf" samt Prüfer-Notiz; erster Lauf 14:21:13 laut Log.):
  Endwert Segment 7 (nicht Bestwert), Held-out 300 Fenster (219 Melodien, 10 % je Quelle), Loss nats je Token. Modell schlägt eine Vergleichsgröße, wenn sein Loss unter 90 % ihres Werts liegt; ±10 % = Gleichstand; darüber = schlechter. Über die Saaten: alle drei einig, sonst saatabhängig. Rot-Probe: Token je Fenster gemischt, Modell-Loss > 10 % höher, Unigramm gleich. Kontrollen: [LR-Decay], Ende LR ~0,0001, 0 NET2NET-GUARD, rc 0, kein NaN. Zusätzlich ohne Urteil: bestes Segment, Überanpassung, Loss je Quelle.
Plan: rechner-a:~/snai_pruef/knirps/noten/kriterien.txt
Darauf baut: snai/noten-epochen32
Rezepte:
  r143 [2026-10-21] nd32h2_s1..3: cd ~/snai_pruef/knirps/proj_ow && VOK=<noten|noten_takt> ../noten/lauf_noten.sh <arm> 0.001 <segmente> <genesis> <decay_steps>  (je Segment: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=$DECAY nice -n 10 php train_cluster.php <seg> <aus> 1 1 <vorstand> 3 0.001 0.0001 1 0.1)
      quelltext: knirps/proj_ow (Lade-Wächter aus), libcortex.so md5 563780e32333; noten/lauf_noten.sh 08263f699b5a; noten/bau.py 8067a6954f13, bau2.py d6ee2095b99e; text/mess_text.php 711d818750ae; noten/form_noten.php 76a103a94364 (md5 gekürzt)
      parameter: 32/2/16, 2 Schichten, ffn 128, ctx 64, 31.392 Parameter, Vokabular noten.json; LR 0,001 -> 0,0001 Cosinus über 22.528 Schritte, Warmup 500, WD 0,1, 1 Arbeiter, Revival aus; 8 Segmente = 8 Epochen (Reihenfolge je Segment neu gemischt, Saat 1000+i)
      seed: Genesis noten_gen_d32h2_s1..3; Held-out-Saat 20261014
      rechner: rechner-a (CPU)
      logs: rechner-a:~/.cache/snai_pruef/knirps/ow/noten/nd32h2_s{1,2,3}.log, .mess.jsonl, _s<I>.train.log
      notiz: Prüfung beim Nachtrag: Endwerte, Rot-Probe, Quellenwerte aus mess.jsonl nachgerechnet. 0 NET2NET in Training (grep). Fallstrick beim Nachrechnen: mess.jsonl enthält am Ende zusätzlich die Quellenzeilen (70 bzw. 230 Fenster); nur die Zeile mit 300 Fenstern ist der Gesamtwert.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/ow/noten/nd32h2_s{1,2,3}.mess.jsonl (nachgerechnet, nur Zeilen mit 300 Fenstern für den Gesamtwert)
  m1555 Held-out-Loss Segment 7 (n = Fenster je Lauf) | 1,292 / 1,303 / 1,299 | nd32h2 | 1/2/3 | 300
  m1556 Rang 0 % | 54,3 / 54,6 / 54,9 | nd32h2 | 1/2/3 | 18900
  m1557 Vergleich Uni / Bi / Tri (n = Fenster) | 2,862 / 2,074 / 1,676 | n-Gramm |  | 300
  m1558 Faktor gegen Trigramm | 0,77-0,78 | nd32h2 | 1-3 | 3
  m1559 Rot-Probe Loss | 6,369 / 6,376 / 6,318 | nd32h2 | 1/2/3 | 300
  m1560 Loss Quelle generiert (Tri 1,892) (n = Fenster) | 1,442 / 1,462 / 1,432 | nd32h2 | 1/2/3 | 70
  m1561 Loss Quelle Essen (Tri 1,613) (n = Fenster) | 1,245 / 1,254 / 1,258 | nd32h2 | 1/2/3 | 230
  m1562 Minimum des Held-out im Segment (n = Segmente) | 7 | nd32h2 | 1-3 | 8
Ergebnis e135 [2026-10-21 19:20]: erfuellt
  Fazit: Schon ein Lauf von 4 Minuten schlägt auf Melodien das Trigramm deutlich (Faktor 0,78, alle Saaten), ohne Überanpassung in 8 Epochen. Der Knirps taugt also als Melodiemodell; ob seine Melodien formal richtig sind, sagt der Loss nicht. Das maß erst die Formsonde (snai/noten-form), und die zeigte, dass der Loss dafür ein stumpfes Maß ist.
  Offen: Mischung zweier Quellen; welche Quelle mehr bringt, beantwortet der Lauf nicht. Eine Zelle, ein Budget.
  Datei: rechner-a:~/snai_pruef/knirps/noten/kriterien.txt
Chronik:
  2026-10-21 19:20 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/noten/kriterien.txt, Kopf "KNIRPS AUF NOTEN (2026-10-14) - Kriterien VOR dem ersten Lauf" samt Prüfer-Notiz; erster Lauf 14:21:13 laut Log.)
  2026-10-21 19:20 Rezept r143 (nd32h2_s1..3)
  2026-10-21 19:20 Status geplant -> laeuft (Rezept r143)
  2026-10-21 19:20 Messwerte m1555-m1562
  2026-10-21 19:20 Ergebnis e135: erfuellt
  2026-10-21 19:20 Status laeuft -> ausgewertet (Ergebnis e135)
```
