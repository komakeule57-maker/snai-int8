# snai/l2sum-float32

```text
snai/l2sum-float32 - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 08:16
Frage: Wie groß ist der Fehler der in float32 summierten Gradientennorm gegen dieselbe Summe in float64? Nicht gefragt: ob das Training sich ändert.
Kriterium (festgelegt 2026-11-02 07:46, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/l2sum/kriterien.txt. F = Norm_f32/Norm_f64 - 1 je Schritt im echten clipGlobalGradientNorm, LR 0. c128sr s0, s4, s8, s9 je 300 Schritte, prod512_basis s6 40 Schritte. RANDFEHLER: |F| < 0,1 % überall, kein Lauf. RELEVANT: |F| >= 1 % auf mindestens einem Stand, gepaarter Lauf vor Umbau. Sonst KLEIN. Faktor 1,5 an einer Schwelle = knapp. Kontrollen: K1 Patch neutral gegen z_s8_train_a_k1_int.log, K2 Rot synthetisch f32 verliert kleine Quadrate, K3 rc und Fehlerkanal.
Plan: rechner-a:~/snai_pruef/l2sum/kriterien.txt
Baut auf: snai/gradnorm-zerlegung
Darauf baut: snai/nan-gains
Rezepte:
  r505 [2026-11-02] rechner-b: cd ~/snai_pruef/l2sum && setsid -f nohup ./lauf.sh > lauf.out 2>&1 < /dev/null (SNAI_L2_LOG=1, LR 0)
      quelltext: proj_gn cortex.nim + patch_l2.py 6b1730d4 = 3eb29797, Lib 099b3120, train_worker.php 2eb56d35, kriterien.txt 0a98870a
      rechner: rechner-b (verlegt, rechner-a unter dem Speicher-Gate; Lib dort gebaut)
      logs: rechner-a und rechner-b:~/snai_pruef/l2sum/log/l2_*.log, fortschritt.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: ~/snai_pruef/l2sum/log/l2_*.log; F = Norm_f32/Norm_f64 - 1, Median und größter Betrag je Stand; Gruppen als sqrt(q32/q64)-1, größter Betrag. Nicht-Clip-Norm im Summen-Raum.
  m7396 F Median, max Betrag % | -0,00572, 0,00748 | c128sr s0 |  | 305
  m7397 F Median, max Betrag % | -0,00568, 0,00735 | c128sr s4 |  | 301
  m7398 F Median, max Betrag % | -0,00378, 0,00541 | c128sr s8 |  | 308
  m7399 F Median, max Betrag % | -0,00303, 0,00427 | c128sr s9 |  | 308
  m7400 F Median, max Betrag % | -0,05445, 0,06403 | prod512b s6 |  | 40
  m7401 Gruppe max Betrag % emb / qk / vo / ffn | 0,01057 / 0,00050 / 0,00050 / 0,00410 | c128sr schlechtester Stand je Gruppe
  m7402 Gruppe max Betrag % emb / qk / vo / ffn | 0,17952 / 0,01293 / 0,01006 / 0,05190 | prod512b s6
  m7403 K1 Patch neutral, Norm-Zeilen gegen z_s8_train_a_k1_int.log | 300 von 300 gleich
  m7404 K2 Rot synthetisch f32 / f64 | 1,0 / 1,19999999
  m7405 K3 Fehlerkanal | nur Wächter-Meldungen je Stand (0-2 Zeilen, Meldung ohne Korrektur laut K1); rc nicht gewertet, Läufe gezielt beendet
Ergebnis e438 [2026-11-02 08:16]: erfuellt
  Fazit: RANDFEHLER nach Wortlaut, bei prod512b knapp (0,064 % liegt innerhalb Faktor 1,5 an 0,1 %). Keine Wiederholung: Auch die Lesart KLEIN verlangt keinen Lauf, die Schlussfolgerung ändert sich nicht. Die Norm hat keinen messbaren Fehler aus der float32-Summe und erklärt den Anstieg nicht: Der Fehler sinkt von s0 bis s9, während die Norm steigt. Reparatur auf float64 lohnt nur als Kleinigkeit zwischen zwei Reihen, weil sie Bitgleichheit bricht; der Fehler wächst mit der Tensorgröße, das ist bei größeren Modellen als prod512b der Grund, es zu tun.
  Offen: Trainingswirkung nicht gemessen, bei 0,06 % Clip-Abweichung auch kein Anlass. Fertige Basis von prod512b nicht gemessen, nur s6 mit 40 Schritten auf dem Instruktionskorpus.
  Datei: rechner-a:~/snai_pruef/l2sum/kriterien.txt
Chronik:
  2026-11-02 07:46 angelegt
  2026-11-02 08:16 Rezept r505
  2026-11-02 08:16 Status geplant -> laeuft (Rezept r505)
  2026-11-02 08:16 Messwerte m7396-m7405
  2026-11-02 08:16 Ergebnis e438: erfuellt
  2026-11-02 08:16 Status laeuft -> ausgewertet (Ergebnis e438)
```
