# snai/adamc-dc

```text
snai/adamc-dc - ausgewertet, angelegt 2026-11-03, zuletzt 2026-11-03 13:05
Frage: Senkt ein Weight Decay, der mit der Lernrate fällt (AdamC, Defazio 2025), den Anstieg der Gradientennorm in der Fortsetzung ab c128sr s4?
Kriterium (festgelegt 2026-11-03 07:28, vor dem ersten Messwert):
  Datei rechner-a:~/snai_pruef/gradnorm/kriterien_adamc.txt, vor dem ersten Lauf, mit Prüfer. Arm C = dc_K1 (lauf_dc.sh, Lib ccb10b0f, c128sr s4, LR 2,5e-4, 30.000 Fenster = Updates, skala_r1-3, CPU), EIN Stellrad WD 0,1 -> 0,025 (= 0,1·2,5e-4/1e-3), auch auf dem gebundenen Embedding. Q = (GF C − 2,9327)/(GF dc_K1 − 2,9327) je Reihenfolge: SENKT Q <= 0,5 in 3/3, GLEICH Q in [0,8; 1,25] in 3/3, sonst OFFEN, knapp 5 %. Q_emb und Q_rest daneben ohne Urteil. Held-out gleichrangig, Unterschied ab 0,023 nats in 3/3. Wette, kein Urteil: Q in [0,1; 0,4] in 3/3, Held-out nicht schlechter. Kontrollen: [Regularisierung] meldet 0,025, Step 1 gleich dc_K1, Step 100 ungleich (Rot-Probe des Stellrads, sonst ungültig), Fehlerkanal, NET2NET korrigiert 0. Deutung "Gewichte schrumpfen weniger" nur, wenn RMS vo und ffn in C in 3/3 näher an s4 als dc_K1. Reichweite: transient, ein Modell, eine LR-Stufe, kein ganzer Abkühlplan; Bindung: Ausgabeschicht bekommt hier denselben Decay, AdamC nimmt sie aus (Arm C2 nur nach SENKT, braucht Patch).
Plan: rechner-a:~/snai_pruef/gradnorm/kriterien_adamc.txt
Baut auf: snai/norm-je-tensor, snai/wdg-final, snai/gradnorm-skala, snai/embedding-nachlaufen
Darauf baut: snai/torch-adamc
Rezepte:
  r550 [2026-11-03] cd ~/snai_pruef/gradnorm && setsid -f nohup werkzeug/schlange_ac.sh (wartet auf SCHLANGE_WF_ENDE; je r: werkzeug/lauf_ac.sh <r> = php train_worker.php chunk_skala_<r>.txt ac_C_<r>.snai 1 chin_c128sr_s4.snai 3 0.00025 1 0.00025 0.025 0 0, dann GF lauf1.sh SNAI_GN_LOG=1 SNAI_GN_LR0=1 train_a, dann mess_text.php 700)
      quelltext: lauf_ac.sh 7845443f (diff zu lauf_dc.sh: nur WD 0.025, Tag ac_C), schlange_ac.sh 94fddf8d, kriterien_adamc.txt eb6a3bbe, Lib clip/proj_clip ccb10b0f
      seed: r1, r2, r3 (Fensterreihenfolge über chunk_skala_<r>, gepaart mit dc_K1)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/gradnorm/log/ac_C_*.log, gf_ac_C_*.log, held_ac_C_*, schlange_ac.log
  r552 [2026-11-03] werkzeug/schlange_ac_bd.sh (rechner-b): ac_C_r1..r3 parallel per werkzeug/lauf_ac.sh <r> (php train_worker.php chunk_skala_<r> ac_C_<r>.snai 1 chin_c128sr_s4.snai 3 0.00025 1 0.00025 0.025 0 0, Lib clip/proj_clip ccb10b0f, CPU, 1 Thread), dazu Nachrechnung dc_K1_r1 (lauf_dc.sh K1 - r1) und GF des rechner-a-Stands gh_dc_K1_r1; danach je GF (lauf1.sh proj_gn, train_a, k=1, LR 0, SNAI_GN_LOG=1 SNAI_GN_LR0=1) und Held-out (mess_text.php 700)
      quelltext: schlange_ac_bd.sh 8f1a2289, lauf_ac.sh 7845443f, kriterien_adamc.txt 4a0e2855 (mit Nachtrag 10:30 Rechnerwechsel und Rechnerkontrollen R1/R2)
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/gradnorm/log/ (ac_C_r*.log, gf_*.log, held_*.txt, schlange_ac.log); Vergleichslog rechner-a dc_K1_r1 als log/gh_dc_K1_r1_train.log
      notiz: Rechnerwechsel auf Wunsch 2026-11-03 10:25 (CPU rechner-b frei); rechner-a-Schlange schlange_ac.sh (PID 2137619) vor jedem Lauf beendet. Daten NFKC-invariant geprüft. Frühkontrolle 10:26: Step 1 aller drei Arme gleich dc_K1, [Regularisierung] 0.025 und Embeddings AN, ac_C weicht ab Step 2 ab (Rot), Nachrechnung dc_K1_r1 in den ersten 94 Step-Zeilen gleich rechner-a.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/gradnorm/log (gf_ac_C_r*.log, held_ac_C_r*.txt, ac_C_r*.log), Vergleich rechner-a log/gf_dc_K1_r*.log und held_dc_K1_r*.txt; Auswertung scratchpad ac_teil.py; Sonde sonde_staende.php. Fehlerkanal leer (nur NET2NET-Meldung), rc 0, STEPS_DONE 30085, [Regularisierung] 0.025 und Embeddings AN in 3/3.
  m8321 R1 Nachrechnung dc_K1_r1 rechner-b gegen rechner-a | 6021/6021 Step-Zeilen gleich, md5 a6c7904f gleich | dc_K1 | r1
  m8322 R2 GF rechner-a-Stand auf rechner-b | 4,3700 | dc_K1 | r1 | 1710
  m8323 GF train_a | 3,6321 | C | r1 | 1710
  m8324 GF train_a | 3,6319 | C | r2 | 1710
  m8325 GF train_a | 3,6044 | C | r3 | 1710
  m8326 Q train_a | 0,487 | C | r1
  m8327 Q train_a | 0,486 | C | r2
  m8328 Q train_a | 0,473 | C | r3
  m8329 Q 95-Prozent-Bootstrap train_a | 0,482-0,491 / 0,482-0,491 / 0,468-0,478 | C | r1-r3 | 1710
  m8330 Q_emb | 0,572 / 0,590 / 0,547 | C | r1-r3
  m8331 Q_rest | 0,298 / 0,281 / 0,291 | C | r1-r3
  m8332 Held-out | 1,9843 / 1,9869 / 1,9894 | C | r1-r3 | 700
  m8333 Held-out C minus dc_K1 | -0,0367 / -0,0360 / -0,0387 | C | r1-r3 | 700
  m8334 RMS emb/qk/vo/ffn | 0,0672 / 0,0798 / 0,0677 / 0,0551 | C | r1-r3
  m8335 RMS emb/qk/vo/ffn | 0,0643 / 0,0784 / 0,0665 / 0,0555 | s4
  m8336 RMS emb/qk/vo/ffn | 0,0484 / 0,0589 / 0,0445 / 0,0365 | dc_K1 | r1-r3
  m8337 g_final mittel | 2,216 / 1,953 / 2,529 | C / s4 / dc_K1
  Quelle: Wiederholung auf frischem Datensatz train_b (7b52193a, 3.419 Fenster, k=1, LR 0), rechner-b log/gfb_*.log, Schlange schlange_acb.sh 3d828df7, Nachtrag kriterien_adamc.txt 12:37; Fehlerkanal 0 in 7/7, rc 0
  m8338 GF train_b | 2,9199 | s4 | - | 3419
  m8339 GF train_b | 4,3534 / 4,3566 / 4,3370 | dc_K1 | r1-r3 | 3419
  m8340 GF train_b | 3,6202 / 3,6209 / 3,5926 | C | r1-r3 | 3419
  m8341 Q train_b | 0,488 / 0,488 / 0,475 | C | r1-r3 | 3419
  m8342 Q train_b 95-Prozent-Bootstrap | 0,485-0,492 / 0,484-0,491 / 0,471-0,478 | C | r1-r3 | 3419
  m8343 Q_emb train_b | 0,575 / 0,591 / 0,549 | C | r1-r3 | 3419
Ergebnis e501 [2026-11-03 13:05]: teilweise
  Fazit: Norm nach Wortlaut OFFEN: Q 0,487/0,486/0,473 (train_a) und 0,488/0,488/0,475 (frisch, train_b), zwei Werte in der Knapp-Zone; ohne Knapp-Regel SENKT 3/3. Q ist reproduzierbar und liegt nur genau an der Schwelle. Held-out BESSER in 3/3 (−0,036 bis −0,039, Schwelle 0,023). Deutungsregel erfüllt: vo/ffn bleiben auf s4-Größe (dc_K1 schrumpft um ein Drittel). Q_rest 0,28-0,30, Q_emb 0,55-0,59. Wette [0,1; 0,4] verfehlt. Rechnerkontrollen R1/R2 bestanden (rechner-b rechnet bytegleich zu rechner-a). Folge: Der verteilte Teil des Normanstiegs kommt vom Schrumpfen der Gewichte unter gekoppeltem Decay (Defazio); mit snai/wdg-final sind beide Teile per Eingriff isoliert. Der Held-out-Gewinn ist der erste klare Qualitätsgewinn der Normreihen.
  Offen: Wirkung über den ganzen Abkühlplan s5-s9 und gegen einen Plan ohne AdamC; ob AdamC selbst oder nur die schwächere Decay-Stärke den Held-out hebt; C2 (Ausgabeschicht ausgenommen); Kombination mit Decay auf g_final; Float-Gegencheck; EE-Modelle. Eine Saat, ein Modell, nicht eingeschwungen.
  Datei: rechner-a:~/snai_pruef/gradnorm/ERGEBNIS_adamc.md
Chronik:
  2026-11-03 07:28 angelegt
  2026-11-03 07:28 Rezept r550
  2026-11-03 07:28 Status geplant -> laeuft (Rezept r550)
  2026-11-03 10:24 Rezept r552
  2026-11-03 12:38 Messwerte m8321-m8337
  2026-11-03 13:04 Messwerte m8338-m8343
  2026-11-03 13:05 Ergebnis e501: teilweise
  2026-11-03 13:05 Status laeuft -> ausgewertet (Ergebnis e501)
```
