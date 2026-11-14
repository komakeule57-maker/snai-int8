# snai/ratsche-k64-hybrid-lang

```text
snai/ratsche-k64-hybrid-lang - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-03 02:29
Frage: Loest die Ratsche nur auf den FFN-Gewichten (SR sonst) beim Knirps 64x4 in 500.000 Fenstern Embedding-Kollaps aus, und bleiben die Gains dabei am Leben?
Kriterium (festgelegt 2026-11-02 15:58, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/k64lang/kriterien.txt, vor dem Lauf, ohne Pruefer auf ausdrueckliche Anweisung zum sofortigen Start. Ein Lauf, eine Saat = Beobachtung, kein Vergleichsarm. Je Stand alle 50.000 Schritte: Held-out, tot FFN-Gains, Embedding-Zeilen (zeilen_lang.php, tot = Stufen<=1). KOLLAPS-VERDACHT: tote Zeilen steigen gegen den ersten Stand um >=5 % der Zeilen ODER Median Stufen <=0,5 x Hoechstwert bei Tot-Zuwachs ODER Textprobe am Ende Zeichensalat. GAINS L2 Ende: GESUND <5 %, GEKIPPT >=50 %. WORKAROUND NICHT AUSGESCHLOSSEN = KEIN VERDACHT und GESUND. Bei Verdacht folgt Vergleichslauf neu mit gleicher Genesis.
Plan: rechner-b:~/snai_pruef/k64lang/kriterien.txt
Baut auf: snai/ratsche-k64-hybrid, snai/merkmal-sr-lang, snai/gains-v-b
Rezepte:
  r519 [2026-11-02] cd ~/snai_pruef/k64lang && setsid -f nohup ./lang.sh > log/lang.nohup 2>&1 < /dev/null
      quelltext: quelle = ms_tiefe/proj_L2 (fdfbf24, cortex cae946bf) + patch_gb.py = 87831d31, libcortex d1a65364 mit AVX2; lang.sh, gains_leb.php, zeilen_lang.php, mess_text.php
      parameter: 64x4, 4 Koepfe, FFN 256, ctx 128, voll int8, gebunden, SNAI_RATSCHE_FFN=1, LR 0,001, SNAI_LR_DECAY_STEPS=500000, Warmup 500, WD 0,1, chin/train.txt 3 Durchgaenge + teil4; CPU, 1 Thread, nice 5
      seed: Saat 4, Genesis wie snai/ratsche-k64 (k64_gen_s4)
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/k64lang/log/lang.log, mess.jsonl, mess.err, s*.train.log
      notiz: Kontrollen: Lib ohne Schalter Kurzprobe 819ddc25, mit Schalter 5e5ce477, beides gleich der rechner-d-Skalarfassung. Rot zeilen_lang: Schach gross_gross_s1 s4 tot 0, Median 7; s7 tot 58/87, Median 1.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/k64lang/log/mess.jsonl; ROT und heldout2 von Hand nachgemessen, weil lang.log bei 140 Zeichen abschneidet
  m8000 Held-out Endstand | 2,0729 | hybrid | 4 | 1
  m8001 Held-out 50.000 | 2,4006 | hybrid | 4 | 1
  m8002 heldout2 Endstand | 2,0739 | hybrid | 4 | 1
  m8003 Rot Held-out Token gemischt | 9,4423 | hybrid | 4 | 1
  m8004 Embedding-Zeilen tot, alle 14 Staende | 0/1509 | hybrid | 4 | 1
  m8005 Median Stufen Endstand | 36 | hybrid | 4 | 1
  m8006 FFN tot L0 Ende | 0 % | hybrid | 4 | 1
  m8007 FFN tot L1 Ende | 0 % | hybrid | 4 | 1
  m8008 FFN tot L2 Ende | 9,8 % | hybrid | 4 | 1
  m8009 FFN tot L3 Ende | 0 % | hybrid | 4 | 1
  m8010 FFN tot L2 Spitze bei 300.000 | 14,7 % | hybrid | 4 | 1
  m8011 Attention tot L0 Ende | 4,8 % | hybrid | 4 | 1
  m8012 Median FFN-Gain L2 Tiefstwert bei 200.000 | 0,80 | hybrid | 4 | 1
  m8013 Median FFN-Gain L2 Ende | 1,03 | hybrid | 4 | 1
Ergebnis e481 [2026-11-03 02:29]: teilweise
  Fazit: KEIN VERDACHT auf Embedding-Kollaps, aber L2 tot 9,8 % liegt zwischen GESUND und GEKIPPT, also ist WORKAROUND NICHT AUSGESCHLOSSEN nach Wortlaut nicht erfuellt. Ein Lauf, eine Saat, Beobachtung, LR 0,001, 500.000 Fenster. Folge: Als Arbeitsgrundlage fuer den Multistack-Fork bei 64x4 traegt der Workaround; das Kriterium wird nicht nachgezogen, ein Stapel-Erfolg muss ohne ihn bestehen. Vergleichslauf neu war nur bei Verdacht vorgesehen und entfaellt.
  Offen: Ob der Hybrid einen Kollaps verhindert hat: ungemessen, kein Vergleichsarm. Andere Saaten, LR 0,003, groessere Breiten. Maengel im Protokoll (abgeschnittene ROT/HELDOUT2-Zeile, leere STEPS_DONE-Angabe) stehen in der Ergebnisdatei.
  Datei: rechner-b:~/snai_pruef/k64lang/ERGEBNIS_ratsche_k64_hybrid_lang.md
Chronik:
  2026-11-02 15:58 angelegt
  2026-11-02 15:58 Rezept r519
  2026-11-02 15:58 Status geplant -> laeuft (Rezept r519)
  2026-11-03 02:29 Messwerte m8000-m8013
  2026-11-03 02:29 Ergebnis e481: teilweise
  2026-11-03 02:29 Status laeuft -> ausgewertet (Ergebnis e481)
```
