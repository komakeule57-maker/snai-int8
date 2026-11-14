# snai/int8-fp32-dim512-gepaart

```text
snai/int8-fp32-dim512-gepaart - ausgewertet, begonnen 2026-09-25, angelegt 2026-10-21, zuletzt 2026-10-21 19:38
Frage: Bleibt ein mit dem Produktiv-INT8-Stack (int8prod) trainiertes Modell bei dim 512 auf dem Held-out hinter einem FP32-trainierten zurück, bei gleicher Genesis und gleicher Token-Folge (400 Schritte, gepaart über 32 Fenster)?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/Projekte/snai_edge_int8_lora/diagnose/VORABFESTLEGUNG_int8_vs_fp32_dim512.md (mtime 2026-09-25 05:28:36, 'aufgestellt VOR jeder Messung'); Laufskript mtime 05:33, Arm A gestartet 06:14 (docs/VERSUCH_INT8_VS_FP32_DIM512.md Abschnitt 9).):
  Auswertung mit compare_full_paired.php je Messpunkt; Effektmaß gepaarter Mittelwert und Median der Fensterdifferenz bei Schritt 400, dazu der Verlauf über 8 Punkte. (1) INT8 zurückliegend, wenn alle drei zutreffen: |B-A| >= 2 x |C-A| (Saateffekt), Vorzeichentest B gegen A >= 3 Sigma, der Abstand wächst über die acht Messpunkte. (2) Gleichstand, wenn |B-A| <= |C-A|. (3) Kein Urteil, wenn |B-A| zwischen 1- und 2-fach |C-A|. (4) Mittelwert und Median im Vorzeichen uneins: Median gilt. (5) Runs-Test ab |3 Sigma| entwertet zu Domäneneffekt.
Plan: rechner-a:~/Projekte/snai_edge_int8_lora/docs/VERSUCH_INT8_VS_FP32_DIM512.md
Rezepte:
  r222 [2026-10-21] bash diagnose/lauf_int8_vs_fp32_dim512.sh 400 8 32  (je Arm: SNAI_TRACE_CORPUS=./factory/input/corpus_long.txt SNAI_TRACE_HOLDOUT=./factory/holdout/ OMP_NUM_THREADS=6 SNAI_TRACE_GENESIS=<genesis> php -d memory_limit=3G diagnose/trace_heldout.php <modus> 400 8 32; Ausgaben auf arm{A,B,C}_… umbenannt). Auswertung 2026-10-21: php diagnose/compare_full_paired.php factory/checkpoints/armA_heldout_trace_fp32_sNNNN.jsonl factory/checkpoints/armB_heldout_trace_int8prod_sNNNN.jsonl (bzw. armC)
      quelltext: diagnose/lauf_int8_vs_fp32_dim512.sh (mtime 2026-09-25 05:33); diagnose/trace_heldout.php mit Modus int8prod (Vorstand trace_heldout.php.bak_pre_int8prod_20260925; heutige md5 75b6a096…, Stand am Lauftag nicht festgehalten); compare_full_paired.php heute ad32369b…
      parameter: Arm A fp32 Genesis trace512_genA (Saat 1); Arm B int8prod Genesis trace512_genA; Arm C fp32 Genesis trace512_genB (Saat 2); 400 Schritte, 8 Messpunkte, 32 Held-out-Fenster (ho_long.txt), lr 0,001, ctx 1024, dim 512, ffn 2048, 6 Schichten, 8 Köpfe, ungebunden
      seed: Genesis-Saat 1 (A, B) und 2 (C); kein Shuffle, Dropout 0
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/arm{A,B,C}_heldout_trace_*_s0050..s0400.jsonl und lauf_int8_vs_fp32.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: Auswertung nachträglich am 2026-10-21 durch Helfer prod: php diagnose/compare_full_paired.php auf rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/armA_heldout_trace_fp32_sNNNN.jsonl, armB_heldout_trace_int8prod_sNNNN.jsonl, armC_heldout_trace_fp32_sNNNN.jsonl (Rohdaten vom 2026-09-25, 09:38 bis 15:05); kein früherer Auswertungseintrag gefunden
  m2562 Held-out Schritt 400 | 8,7517 | A fp32 | 1 | 32
  m2563 Held-out Schritt 400 | 8,9998 | B int8prod | 1 | 32
  m2564 Held-out Schritt 400 | 8,7891 | C fp32 | 2 | 32
  m2565 B-A Mittelwert / Median Schritt 400 | +0,2480 / +0,2498 | B gegen A |  | 32
  m2566 B-A Vorzeichen Schritt 400 | 32:0 (5,66 Sigma) | B gegen A |  | 32
  m2567 C-A Mittelwert / Median Schritt 400 | +0,0374 / +0,0340 | C gegen A |  | 32
  m2568 C-A Vorzeichen Schritt 400 | 27:5 (3,89 Sigma) | C gegen A |  | 32
  m2569 Verhältnis Betrag B-A zu Betrag C-A Schritt 400 | 6,6 | B gegen A |  | 32
  m2570 B-A Mittelwert Schritt 50/100/150/200/250/300/350/400 | +0,377 / +0,177 / +0,156 / +0,441 / +0,379 / +0,102 / +0,265 / +0,248 | B gegen A |  | 32
  m2571 C-A Mittelwert Schritt 50/100/150/200/250/300/350/400 | +0,257 / -0,038 / +0,183 / +0,167 / +0,193 / +0,003 / +0,115 / +0,037 | C gegen A |  | 32
  m2572 Runs-Test B gegen A | durchmischt an allen Punkten | B gegen A |  | 32
Ergebnis e212 [2026-10-21 19:38]: keine_aussage
  Fazit: Nach der Vorab-Regel gibt es kein Urteil. „Zurückliegend“ verlangt alle drei Bedingungen; die dritte (der Abstand wächst) ist nicht erfüllt. Für diesen Fall hat die Regel keinen Ausgang. Gleichstand (2) und Kein-Urteil (3) greifen nicht. Die drei Bedingungen sind Teile EINES Urteils und keine getrennten Teilfragen, deshalb gilt keine_aussage statt teilweise; das ersetzt e209.

Was trotzdem feststeht: Der Produktivpfad liegt bei Schritt 400 um 0,25 nats hinter FP32, also 6,6-mal so weit wie der Saateffekt, und das in allen 32 Fenstern, ohne Trend über die 8 Messpunkte. Ein Pegelabstand ist da, ein wachsender nicht. Die frühere Entwarnung betraf den Hybridpfad und lässt sich auf den Produktivpfad nicht übertragen.

Wer den INT8-Preis für prod512b wissen will, braucht einen längeren gepaarten Lauf. Die SnAI_Evo-Gegenarme (snai-evo/gegenarme) fanden ihn bei Breite 32 saatabhängig.
  Offen: Je Rechenpfad nur eine Saat. 400 Schritte ab Genesis. Der Held-out kommt in keinem Arm unter 8,7. Ob sich der Abstand über Millionen Token schließt oder öffnet, ist nicht gemessen. Die Rohdaten lagen fast vier Wochen unausgewertet. Baut inhaltlich auf snai/int8-port auf (Feld nachträglich nicht setzbar).
  Datei: rechner-a:~/Projekte/snai_edge_int8_lora/docs/VERSUCH_INT8_VS_FP32_DIM512.md
Abgeloest und ausgeblendet: 1 ergebnis - voll=True zeigt sie.
Chronik:
  2026-10-21 19:36 angelegt (Nachtrag: Kriterium aus rechner-a:~/Projekte/snai_edge_int8_lora/diagnose/VORABFESTLEGUNG_int8_vs_fp32_dim512.md (mtime 2026-09-25 05:28:36, 'aufgestellt VOR jeder Messung'); Laufskript mtime 05:33, Arm A gestartet 06:14 (docs/VERSUCH_INT8_VS_FP32_DIM512.md Abschnitt 9).)
  2026-10-21 19:36 Rezept r222
  2026-10-21 19:36 Status geplant -> laeuft (Rezept r222)
  2026-10-21 19:36 Messwerte m2562-m2572
  2026-10-21 19:36 Ergebnis e209: teilweise
  2026-10-21 19:36 Status laeuft -> ausgewertet (Ergebnis e209)
  2026-10-21 19:38 Ergebnis e212: keine_aussage, loest e209 ab
```
