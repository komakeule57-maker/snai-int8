# snai/nan-quant

```text
snai/nan-quant - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 11:04
Frage: Verschwindet NaN/Inf in der int8-Quantisierung tatsaechlich, ist das die Ursache fuer den endlichen Loss bei kaputtem Gain, und kommt es in gesunden Laeufen vor?
Kriterium (festgelegt 2026-11-02 10:11, vor dem ersten Messwert):
  Original cortex.nim 399d4446 an genau den Stellen patchen (assert), eine Kopie mit Sonde und Stellraedern: Zaehler nichtendlicher Eingaben je Stelle (quantizeActivation, quantizeVectorToQ8Row, quantizeActivationBatch, backwardDInI8), Aufrufzaehler. Stellrad P: Skala wird bei nichtendlicher Eingabe NaN. Stellrad L: Lade-Abweisung aus Punkt 7 aus, nur fuer den Rot-Arm. F1 gesund: c128sr s8 bis 3000 Schritte LR 1e-4, prod512b_s1 200 Schritte, Zaehler je Stelle. RANDFEHLER, wenn alle 0 bei Aufrufzaehler >0; RELEVANT, wenn >0. F2 Rot: nan1 (Gain NaN, Stellrad L) muss Zaehler >0 zeigen, sonst ist die Sonde ungueltig. F3 Ursache: nan1 mit P aus hat endlichen Loss; mit P an wird der Loss NaN oder die vorhandene Loss-Pruefung im Worker schlaegt an. Nur dann gilt das Verschwinden in der Quantisierung als Ursache des endlichen Loss. Kontrolle K1: gesund mit Sonde bitgleich zum Stand ohne Sonde (Schrittzeilen und Ergebnis-md5 aus t0: 03b6d85cc631). Reichweite: zwei Modellgroessen, 1 Thread, CPU, Entwarnung gilt nur fuer diesen Bereich und nur fuer die vier Stellen.
Baut auf: snai/nan-gains
Darauf baut: snai/gesamt-fix
Rezepte:
  r507 [2026-11-02] patch_q.py <Kopie cortex.nim>; rechner-b fix8/lauf.sh, k1b.sh, p200.sh (train_worker.php chunk out 1 base 3 0.0001 1 0.0001 0.1 0 0; SNAI_QNAN_PROP, SNAI_TEST_NANLOAD)
      quelltext: cortex.nim 399d4446 plus rechner-a:~/snai_pruef/fix8/patch_q.py
      rechner: rechner-b
      logs: rechner-a:~/snai_pruef/fix8/ (erg.txt, k1b.log, f2_p0.log, f3_p1.log, f1_c128.log, f1_prod200.log)
      notiz: Abweichungen: c128sr endete mit dem Chunk bei Schritt 2495 statt 3000; prod512b bis Zeitgrenze 40 min, letzte Logzeile Schritt 115 statt 200. Erster K1 mit anderem Chunknamen wich ab (Fensterfolge haengt am Namen), Wiederholung mit gleichem Namen gleich.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: fix8/erg.txt, k1b.log, f1_prod200.log; Zaehler nur bei Zehnerpotenzen protokolliert
  m7436 K1 Ergebnis-md5 mit Sonde gegen ohne | 03b6d85cc631 gleich, Schrittzeilen 0 Unterschiede | gesund
  m7437 F1 nichtendliche Eingaben, alle 4 Stellen | 0 bei mindestens 1.000.000 Aufrufen je Stelle, Stelle 3 mindestens 10.000.000 | c128sr bis Schritt 2495
  m7438 F1 nichtendliche Eingaben, alle 4 Stellen | 0 bei mindestens 1.000.000 Aufrufen je Stelle, Stelle 3 mindestens 10.000.000 | prod512b_s1 bis Schritt 115
  m7439 F2 nichtendliche Eingaben, Stelle 2 | mindestens 10.000 | nan1 P aus
  m7440 F2 nichtendliche Eingaben, Stelle 3 | mindestens 1.000.000 | nan1 P aus
  m7441 F3 Worker | rc 0, Loss Schritt 145 12,429551, GradNorm nan | nan1 P aus
  m7442 F3 Worker | rc 1, Exploding Gradients bei Schritt 1 | nan1 P an
Ergebnis e440 [2026-11-02 11:04]: verfehlt
  Fazit: RANDFEHLER nach Kriterium, keine Relevanz in gesunden Laeufen: 0 nichtendliche Eingaben. Der Mechanismus ist aber isoliert: die Quantisierung versteckt NaN vor dem Loss, wird NaN durchgereicht, greift die vorhandene Worker-Pruefung in Schritt 1. Korrektur als billige Vorsorge moeglich, kein Beitrag zu toten Gains oder Norm.
  Offen: Budget unter Plan (2495 und 115 Schritte statt 3000 und 200). 1 Thread, CPU. Nur vier Stellen, nicht quantDequantActRows, quantDequantAdamBlock, quantizeMatrixToQ8, GPU-Pfad. Kosten und Bitgleichheit einer Korrektur nicht gemessen.
  Datei: rechner-a:~/snai_pruef/PRUEFUNG_cortex_2026-11-02.md
Chronik:
  2026-11-02 10:11 angelegt
  2026-11-02 11:04 Rezept r507
  2026-11-02 11:04 Status geplant -> laeuft (Rezept r507)
  2026-11-02 11:04 Messwerte m7436-m7442
  2026-11-02 11:04 Ergebnis e440: verfehlt
  2026-11-02 11:04 Status laeuft -> ausgewertet (Ergebnis e440)
```
