# snai/ee-lr-spaet

```text
snai/ee-lr-spaet - ausgewertet, angelegt 2026-11-03, zuletzt 2026-11-04 05:39
Frage: Treibt die konstante Lernrate 0,003 das späte Sterben der FFN-Gains unter dem Eingangsfaktor (E100: L1 tot 8-12 % bei 27k auf 16-26 % bei 50k), oder löst eine kleinere Lernrate es im Gegenteil aus (These zum Abkühlen)?
Kriterium (festgelegt 2026-11-03 20:57, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/clip_lns/KRITERIEN_lr50.md (md5 a60a74f6, Prüfer vor dem Start). T = tote FFN-Gains (|g|<0,05) über L1-L3 (384 Kanäle) in Prozentpunkten, S am Start (E100-Snapshot t50000), K_e/L_e am Ende, D = K_e - L_e je Saat s4-s7. 1) NICHT ENTSCHEIDBAR wenn Mittel(K_e - S) < 2. 2) LR TREIBT: D>0 in >=3/4 und Mittel D >= 2. 3) ABKÜHLEN SCHADET: D<0 in >=3/4 und Mittel D <= -2. 4) KEIN LR-EFFEKT: |Mittel D| < 1. 5) sonst OFFEN. Knapp (0,5 Punkte an einer Schwelle): Bootstrap, OFFEN (knapp). 2:2 = saatabhängig.
Baut auf: snai/ee-ffn-budget100k, snai/engine-emb-eingang, snai/gains-v
Darauf baut: snai/ee-ffn-abkuehlen
Rezepte:
  r566 [2026-11-03] cd ~/snai_pruef/clip_lns && setsid -f nohup ./reihe_lr50.sh > log/reihe_lr50.out 2>&1 < /dev/null  (wartet auf REIHE_ENDE in log/ee100.log)
      quelltext: reihe_lr50.sh cf8fad3c, lauf_clip_lns.sh, Lib bau_emb_voll 3475df5c, Text daten/frisch27k.txt 6437cc82
      parameter: 128x4, 8 Köpfe, int8 voll, gebunden, SR, Clip 1, WD 0,1, EMB_EIN 11,3137085, Start E100-Snapshot t50000 (adam_t 50000, kein Warmup), Arme K LR 0,003 / L LR 0,001, ~27.000 Schritte, Snapshots adam_t 59000/68000
      seed: s4-s7, gepaart (gleicher Snapshot, gleicher Laufname clip_s<s>)
      rechner: rechner-b CPU, 8 zugleich, Start nach ee100 (~05:00), Dauer ~2 h
      logs: rechner-b:~/snai_pruef/clip_lns/log/lr50.log, laeufe/lr50/, log/lr50_tot.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b ~/snai_pruef/clip_lns/log/lr50_tot.jsonl und log/ee100_tot.jsonl (lesen_tie2.php, tot = |g|<0,05), Auswertung werkzeug/ausw_lr50.py → log/lr50_ausw.txt; Held-out laeufe/lr50/*/mess.jsonl
  m8542 T Start t50000 % | 9.63 | E100 | 4
  m8543 T Start t50000 % | 13.80 | E100 | 5
  m8544 T Start t50000 % | 19.80 | E100 | 6
  m8545 T Start t50000 % | 10.17 | E100 | 7
  m8546 T Ende % | 11.70 | K | 4
  m8547 T Ende % | 20.33 | K | 5
  m8548 T Ende % | 23.70 | K | 6
  m8549 T Ende % | 15.10 | K | 7
  m8550 T Ende % | 6.50 | L | 4
  m8551 T Ende % | 9.63 | L | 5
  m8552 T Ende % | 13.00 | L | 6
  m8553 T Ende % | 5.97 | L | 7
  m8554 D = K_e - L_e Punkte | 5.20 | K-L | 4
  m8555 D = K_e - L_e Punkte | 10.70 | K-L | 5
  m8556 D = K_e - L_e Punkte | 10.70 | K-L | 6
  m8557 D = K_e - L_e Punkte | 9.13 | K-L | 7
  m8558 heldout Ende | 2.4778 | K | 4
  m8559 heldout Ende | 2.4780 | K | 5
  m8560 heldout Ende | 2.4820 | K | 6
  m8561 heldout Ende | 2.4792 | K | 7
  m8562 heldout Ende | 2.2599 | L | 4
  m8563 heldout Ende | 2.2575 | L | 5
  m8564 heldout Ende | 2.2639 | L | 6
  m8565 heldout Ende | 2.2606 | L | 7
  m8566 emb_rms Ende | 0.1106 | K | 4
  m8567 emb_rms Ende | 0.1104 | K | 5
  m8568 emb_rms Ende | 0.1105 | K | 6
  m8569 emb_rms Ende | 0.1092 | K | 7
  m8570 emb_rms Ende | 0.0669 | L | 4
  m8571 emb_rms Ende | 0.0663 | L | 5
  m8572 emb_rms Ende | 0.0669 | L | 6
  m8573 emb_rms Ende | 0.0658 | L | 7
  m8574 gfin_rms Ende | 1.062 | K | 4
  m8575 gfin_rms Ende | 1.945 | L | 4
Ergebnis e510 [2026-11-04 05:39]: erfuellt
  Fazit: LR TREIBT: Mittel (K_e − S) +4,36 Punkte (entscheidbar), D = K_e − L_e +5,2/+10,7/+10,7/+9,1, Mittel +8,93, 4/4, nicht knapp. Unter LR 0,001 sinkt T in 4/4 unter den Startwert (Gains leben auf); Gegenprobe mit relativer Schwelle gleiche Richtung (Beobachtung, ohne Rot). Abkühl-These für Modelle MIT Eingangsfaktor widerlegt (128x4, int8, 27k Schritte ab t50000, nach Neustart aus Snapshot). Nebengrößen: Held-out L 0,219 nats besser (4/4; 8,8 % Loss, der Größe nach Gleichstand nach Hausregel, 24 % Perplexität); Embedding-RMS unter L 0,110 → 0,066 (Verhältnis 0,60, AdamW-Gleichgewicht sqrt(lr/wd) sagt 0,58, Kosson et al.), g_final 1,05 → 1,95. Fazit: Die konstante LR ist der Treiber des späten Sterbens; Abkühlen repariert es und bringt viel Loss. Offen ist der Fall ohne Faktor (prod512b), wo das schrumpfende Embedding beim Abkühlen das frühe Sterben verstärken könnte: Vorhersage für snai/prod512b-gains-abkuehlen.
  Datei: rechner-b ~/snai_pruef/clip_lns/ERGEBNIS_ee_lr_spaet.md
Chronik:
  2026-11-03 20:57 angelegt
  2026-11-03 20:57 Rezept r566
  2026-11-03 20:57 Status geplant -> laeuft (Rezept r566)
  2026-11-04 05:39 Messwerte m8542-m8575
  2026-11-04 05:39 Ergebnis e510: erfuellt
  2026-11-04 05:39 Status laeuft -> ausgewertet (Ergebnis e510)
```
