# snai/kopier-mini-fest

```text
snai/kopier-mini-fest - ausgewertet, begonnen 2026-10-09, angelegt 2026-10-21, zuletzt 2026-10-21 11:20
Frage: Kann der echte Trainer samt Kern Positions-Kopieren lernen (Aufgabe `fest` = [R32][R32], Abstand fest 32), und hängt das an INT8 gegen FP32 oder an der Embedding-Bindung?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21 (Arm `fest`; Arm `var` steht als snai/kopier-mini-var); Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  Gelernt = Rang 0 auf der zweiten Kopie >= 90 % auf 200 frischen Fenstern, nicht gelernt < 10 %. Rot-Probe: fremde erste Kopie.
Baut auf: snai/kopier-mini-induktion
Rezepte:
  r21 [2026-10-21] Training k. A. (nur in Arbeitsnotizen beschrieben). Messung aus proj/: php ../mess.php factory/checkpoints/kopiertest_int8_fest_s0.snai ../vorrat256.json 200 fest 0   # letztes Argument 1 = Rot-Probe
      parameter: 128/2/4, ffn 512, ctx 64, Vokabular 8192 (256 Ein-Token-Wörter benutzt); echter Trainer train_cluster.php, 1 Worker, 1 Fenster = 1 Schritt, LR 0,001 konstant, Revival an, unveränderte libcortex.so. Arme: INT8 voll gebunden (5.000 Schritte), INT8 voll ungebunden (10.000), FP32 ungebunden (15.000); PyTorch-Nachbau gleicher Bauart als Maßstab
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/lernversuch/proj/factory/checkpoints/kopiertest_int8_fest_s0.snai; Skripte Laptop:~/.cache/snai_pruef/lernversuch/
Messwerte (Groesse | Wert | Arm | Start | n):
  m185 R0 zweite Kopie nach 5.000 Schritten | 99,9 % (Loss 0,010), Sprung zwischen Schritt 1500 und 2000 | INT8 voll gebunden |  | 200
  m186 R0 zweite Kopie nach 10.000 Schritten | 0,6 % (Loss 5,546) | INT8 voll ungebunden |  | 200
  m187 R0 zweite Kopie nach 15.000 Schritten | 0,45 % (Loss 5,546) | FP32 ungebunden |  | 200
  m188 R0 zweite Kopie nach 4.500 Schritten | 99,4 % | PyTorch gebunden
  m189 PyTorch ungebunden | Saat 1 lernt in 8.000, Saat 2 in 20.000 nicht | PyTorch ungebunden
  m190 Rot-Probe (fremde erste Kopie) | 0,5 % (von 99,9 %) | INT8 voll gebunden |  | 200
Ergebnis e19 [2026-10-21 11:20]: erfuellt
  Fazit: Der Produktivpfad (INT8 vorwärts, Ganzzahl-Rückwärts, quantisierter Adam, Bindung) lernt Positions-Kopieren etwa so schnell wie der PyTorch-Nachbau, aber nur mit gebundenem Embedding. Ob gelernt wird, hing an der Bindung, nicht an FP32 gegen INT8 (ungebunden scheitern INT8 und FP32 gleichermaßen). Für Kopierversuche heißt das: gebunden fahren.
  Offen: Je Arm ein Lauf; PyTorch ungebunden saatabhängig. Der Checkpoint (ctx 64) taugt nicht für diagnose/kopier_sonde.php (braucht ctx >= 200). Ob die Mini-Modelle dieselbe Attention-Sättigung zeigen wie prod512, ist nicht gemessen.
Chronik:
  2026-10-21 11:19 angelegt (Nachtrag: Nachgetragen 2026-10-21 (Arm `fest`; Arm `var` steht als snai/kopier-mini-var); Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:19 Rezept r21
  2026-10-21 11:19 Status geplant -> laeuft (Rezept r21)
  2026-10-21 11:19 Messwerte m185-m190
  2026-10-21 11:20 Ergebnis e19: erfuellt
  2026-10-21 11:20 Status laeuft -> ausgewertet (Ergebnis e19)
```
