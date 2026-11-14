# snai/merkmal-logitbias

```text
snai/merkmal-logitbias - ausgewertet, begonnen 2026-10-17, angelegt 2026-10-21, zuletzt 2026-10-21 19:19
Frage: Verhindert ein trainierbarer Logit-Bias je Token (ohne Decay, Start 0, eigener Adam-Zaehler), ab s4 durch Segment 5 mittrainiert, den Formfehler-Sprung?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/logitbias/kriterien_logitbias.txt, Kopf '2026-10-17, VOR jedem Lauf', Nachtrag nach Zweitmeinung vor den Langlaeufen (eigener Zaehler lb_t), Nachtrag 10:59:25 vor dem Ergebnis):
  VERHINDERT: F < 5 % in BEIDEN Saaten (1, 3) UND L nicht mehr als 10 % ueber dem Original. NICHT VERHINDERT: F >= 15 % in beiden. Saaten uneinig: saatabhaengig. Sonst kein Urteil. Bank vor den Laeufen (AUS bytegleich 10a1ee05, AN deterministisch, Laden wirkt, eingefroren bleibt .lbias gleich, FEST ohne Begleitdatei bricht ab). Nachtrag vor dem Ergebnis (10:59): tote Zeilen gegen zwei konkurrierende Vorhersagen (Praevention: weniger; Auditor B: mehr) berichtet, +-10 % = gleich.
Baut auf: snai/merkmal-eingriff
Rezepte:
  r137 [2026-10-21] bash ~/snai_pruef/merkmal/logitbias/lauf_lb.sh <saat> (SNAI_LOGIT_BIAS=1, php train_cluster.php factory/input/gross_c64_seg5.txt factory/checkpoints/gross_gross_s<S>_s5.snai 1 1 <start gross_gross_s<S>_s4> 3 0.001 0.0001 1 0.1 mit SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=727208); Messung messe_lb.sh (SNAI_CORTEX_LIB auf die Bias-Engine)
      quelltext: Kopien knirps/proj_lbias_s1/_s3 aus proj_lbias_basis (= proj_spaet_s1 + patch_logitbias.py 9342d0a7), libcortex.so 1e2468ad; lauf_lb.sh 808a5afe, messe_lb.sh 9d6fda9e, bank_lb.sh a8096199
      parameter: d96 Schach, ein Segment s4 -> s5 ab Original gross_gross_s<S>_s4 (adam_t 466470), LR 0,001 Cosinus bis 727208 (im Segment 3,57e-4 -> ~2e-4), Warmup 500, WD 0,1 ueberall, gebunden, int8 FULL, Revival und Lade-Waechter aus, CPU OMP 1; Bias float32 je Token, wd 0, Format SNAILB02
      seed: Saat 1 und 3, Ausgabename wie Original
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/logitbias/log/, mess_lb_s<S>.jsonl, bias_inhalt.txt, bank/bank.txt
      notiz: Engine nach dem Zweitmeinungs-Nachtrag (eigener Zaehler lb_t) von d6ef27e0 auf 1e2468ad neu gebaut; die Laeufe nutzen 1e2468ad.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/logitbias/mess_lb_s1/s3.jsonl, bias_inhalt.txt, bank/bank.txt (abgelesen 2026-10-21)
  m1517 F | 27,6 % (Original 28,4) | Logit-Bias | 1 | 500
  m1518 F | 38,8 % (Original 37,2) | Logit-Bias | 3 | 500
  m1519 L | 1,3920 (1,3922) | Logit-Bias | 1 | 1
  m1520 L | 1,4103 (1,4103) | Logit-Bias | 3 | 1
  m1521 tote Zeilen | 20 (22) | Logit-Bias | 1 | 1
  m1522 tote Zeilen | 37 (37) | Logit-Bias | 3 | 1
  m1523 rho | +0,44 (+0,44) | Logit-Bias | 1
  m1524 rho | +0,51 (+0,49) | Logit-Bias | 3
  m1525 Median abs(b) auf Token mit Vorkommen | 0,035 | Logit-Bias | 1 | 78
  m1526 Median abs(b) auf Token mit Vorkommen | 0,089 | Logit-Bias | 3 | 78
  m1527 Spearman(b, log-Haeufigkeit) | +0,003 | Logit-Bias | 1 | 78
  m1528 Spearman(b, log-Haeufigkeit) | -0,18 | Logit-Bias | 3 | 78
  m1529 Bank L0 md5 (Schalter aus) | 10a1ee05 = Original | Bank |  | 1
Ergebnis e131 [2026-10-21 19:19]: verfehlt
  Fazit: Ein ab s4 mittrainierter Logit-Bias verhindert den Sprung nicht und aendert die Bahn kaum (Loss bis auf die vierte Stelle gleich). Weder Praevention noch die Beschleunigungs-These von Auditor B treffen zu. Die Aufbaugrenze ist wichtig: der Bias-Gradient ist nur die Fehlkalibrierung der Randverteilung, ein kalibriertes Modell gibt ihm nichts zu lernen. Gezeigt ist also 'zusaetzlicher Bias ab s4 hilft nicht', nicht 'Bias ab Genesis haette nicht geholfen'. Zusammen mit snai/merkmal-zeilenintern spricht das gegen die Haeufigkeitsdarstellung als Ausloeser.
  Offen: Bias ab Genesis ungeprueft; Kontrollarm mit eingefrorenem Bias nie festgelegt.
  Datei: rechner-a:~/snai_pruef/merkmal/logitbias/kriterien_logitbias.txt
Chronik:
  2026-10-21 19:18 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/logitbias/kriterien_logitbias.txt, Kopf '2026-10-17, VOR jedem Lauf', Nachtrag nach Zweitmeinung vor den Langlaeufen (eigener Zaehler lb_t), Nachtrag 10:59:25 vor dem Ergebnis)
  2026-10-21 19:18 Rezept r137
  2026-10-21 19:18 Status geplant -> laeuft (Rezept r137)
  2026-10-21 19:19 Messwerte m1517-m1529
  2026-10-21 19:19 Ergebnis e131: verfehlt
  2026-10-21 19:19 Status laeuft -> ausgewertet (Ergebnis e131)
```
