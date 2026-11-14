# snai/geschichten-chin128

```text
snai/geschichten-chin128 - ausgewertet, angelegt 2026-10-30, zuletzt 2026-11-01 13:57
Frage: Wie weit kommt ein 128x4-Knirps auf den Kindergeschichten mit Chinchilla-Menge (19,6 Mio Token), trainiert bis zum Plateau (Abbruchregel prod512b) und abgekuehlt, und schreibt er danach verwertbare Geschichten?
Kriterium (festgelegt 2026-10-30 05:23, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/schluss/knirps128/kriterien.txt. Ein Lauf, eine Saat -> Beobachtung. Segment = ein voller Durchgang (Vorgabe). Gewinn = Held-out-Loss (mess_text.php, heldout.txt, 700 Fenster) Vorgaenger minus neu. Ausloeser: zwei Segmente nacheinander je < 0,02 nats (zweiter Wert knapp |G-0,02|<0,005 -> heldout2 entscheidet). Danach 4 Segmente LR 7,5e-4/5e-4/2,5e-4/1e-4 (Spitze 1e-3 konstant), dann Ende; Deckel 12 Segmente ohne Ausloeser (dann 'Kriterium nicht erreicht'). Am Ende Rot-Probe, heldout2, V1 >= 50 % Grundfilter (50 Geschichten T 0,8), V2 <= 10 % woertliche Kopien, V3 Held-out unter Trigramm. Trockenlauf der Abbruchlogik gruen in 3 Faellen, Mutante rot. Pruefer vorab (zweitmeinung): Einwaende Batch 1/int8/LR durch snai/geschichten-tiefe widerlegt, Epochen-Wiederholung durch Abbruchregel abgedeckt.
Plan: rechner-a:~/snai_pruef/schluss/knirps128/kriterien.txt
Baut auf: snai/geschichten-tiefe, snai/natur-aufbereiten
Darauf baut: snai/gradclip-knirps-kurz, snai/geschichten-wortfeld, snai/gradnorm-zerlegung
Rezepte:
  r463 [2026-10-30] rechner-b: cd ~/snai_pruef/knirps_gpu && setsid -f nohup nice -n 5 ./lauf_chin.sh c128sr factory/checkpoints/chin_gen_d128h8L4_s1.snai 0.001 12 > log/chin_c128sr.out 2>&1 (Arbeitskopie proj_sr; je Segment wie r462: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 php train_cluster.php chin/train.txt <aus> 1 1 <vorgaenger> 3 <LR> 0.0001 1 0.1; SR = Vorgabe mv)
      quelltext: lauf_chin.sh 3b459e2a; proj_sr = Projektbaum 48b983f + snai_tokenizer.php aus proj_t (35d4dd21) + cortex.nim Waechter aus (2f3a96c9) -> libcortex.so e281ce8d (auf rechner-b gebaut, Nim 2.2.10), revival enabled false; kriterien.txt b39be95e
      parameter: wie r462; zusaetzlich SR m 1 v 1 (Skript bricht ohne ab), Weight-Decay Embeddings an (Vorgabe)
      seed: Genesis 1; Mischung Korpus 4711
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/knirps_gpu/log/chin/c128sr.log, c128sr.mess.jsonl, c128sr_s<I>.train.log; Plan chin/lr_plan_c128sr.txt; verworfener Erststart in log/chin/alt_ohne_sr/
      notiz: r462 (proj_t, ohne SR) nach 35 min verworfen: bekannter Defekt (Ratsche der 8-Bit-Momente). Gleichlauf proj_t = proj_sr mit SR 0 bytegleich (bcdf2508, gleicher Laufname), SR an abweichend (18d89970). Start 06:09; Genesis-Loss 7,3192; Tempo ~5,7 Schritte/s -> ~7,5 h je Segment.
  r468 [2026-10-30] Pause nach Segment 0 wegen Neustart rechner-b (2026-10-30): chin/lr_plan_c128sr.txt = "ENDE 1", Skript endete 13:07:46 regulaer (STICHPROBE_FERTIG). Fortsetzen: Plandatei loeschen, dann derselbe Befehl wie r463; s0 existiert, wird nicht neu trainiert, nur neu gemessen.
  r470 [2026-10-30] rechner-a (Umzug 2026-10-30 ~13:45 auf Wunsch, rechner-b muss neu starten): cd ~/snai_pruef/knirps_gpu && setsid -f nohup nice -n 5 ./lauf_chin.sh c128sr factory/checkpoints/chin_gen_d128h8L4_s1.snai 0.001 12 >> log/chin_c128sr.out 2>&1. Dateien von rechner-b kopiert (lauf_chin.sh 3b459e2a, libcortex.so e281ce8d, s0 cfe662d4, train.txt 8cb75948, kriterien b39be95e), ohne lr_plan_c128sr.txt. Rezept sonst wie r463, 1 Thread (mehr Threads bringen bei 128x4 nichts: m6590-m6594). Vorab bytegleich auf beiden Rechnern nur fuer 307 Schritte belegt (f1cb2b41). Start: Skript misst Genesis und s0 neu (doppelte Zeilen in c128sr.mess.jsonl, dazu der Schlussteil der Pause), s0 wird nicht neu trainiert.
      logs: rechner-a:~/snai_pruef/knirps_gpu/log/chin/c128sr.log, c128sr.mess.jsonl, c128sr_s<I>.train.log
  r483 [2026-11-01] rechner-a: cd ~/snai_pruef/knirps_gpu && setsid -f nohup nice -n 5 ./lauf_chin.sh c128sr factory/checkpoints/chin_gen_d128h8L4_s1.snai 0.001 12 >> log/chin_c128sr.out 2>&1 < /dev/null (Plan um "9 0.0000500", "ENDE 10" ergaenzt)
      quelltext: lauf_chin.sh fda2870e (Vorgaenger als lauf_chin.sh.3b459e2a behalten); Plan bis s8 als chin/lr_plan_c128sr.bis_s8.txt, Stichprobe s8 als log/chin/c128sr_s8.stichprobe.txt
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/knirps_gpu/log/chin/c128sr.log, c128sr_s9.train.log; c128sr.mess.jsonl enthaelt Genesis bis s8 doppelt (Neumessung beim Start)
      notiz: Nachsegment s9, Wunsch, ausserhalb des Kriteriums. Start 05:48:36. Neumessung s8 beim Start wieder 1,9445.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/knirps_gpu/log/chin/c128sr.log, c128sr.mess.jsonl (mess_text.php, 700 Fenster; proj_sr libcortex e281ce8d, Lade-Waechter aus: Meldung NET2NET-GUARD L2.rms_ffn [0..127] nur Anzeige, Gewichte unveraendert). Segment 0 = 153.241 Schritte, Modell chin_c128sr_s0.snai cfe662d4
  m6551 Held-out-Loss Genesis | 7,3192 | c128sr | 1 | 700
  m6552 Held-out-Loss s0 heldout.txt | 2,2774 | c128sr | 1 | 700
  m6553 Gewinn s0 | 5,0418 | c128sr | 1 | 700
  m6554 Trigramm-Vergleich heldout.txt | 2,6391 | c128sr | 1 | 700
  m6555 Rang0 s0 % | 44 | c128sr | 1 | 700
  m6556 Rot-Probe Fenster gemischt s0 | 8,5499 | c128sr | 1 | 700
  m6557 Held-out-Loss s0 heldout2.txt | 2,2688 | c128sr | 1 | 700
  m6558 Trigramm-Vergleich heldout2.txt | 2,634 | c128sr | 1 | 700
  m6559 Trainings-Avg-Loss s0 | 2,34679 | c128sr | 1
  m6560 Fehlerkanal train.log s0 Zeilen | 0 | c128sr | 1
  m6561 Tote Gain-Kanaele L2.rms_ffn s0 (Betrag unter 0,05) | 128/128 | c128sr | 1
  Quelle: rechner-a:~/snai_pruef/clip/laeufe/threads/T*_s1 (lauf_clip_omp.sh, kontrolle.txt, 307 Schritte, Saat 1, libcortex_orig e281ce8d, CPU; je Zelle 1 Lauf, also Beobachtung; Vorentscheidung fuer Umzug auf rechner-a, kein Kriterium fuer die Reihe). Bytegleich = f1cb2b41 wie rechner-b.
  m6590 Trainingszeit 307 Schritte 1 Thread s | 35 | rechner-a | 1
  m6591 Trainingszeit 307 Schritte 2 Threads s | 44 | rechner-a | 1
  m6592 Trainingszeit 307 Schritte 4 Threads s | 40 | rechner-a | 1
  m6593 Trainingszeit 307 Schritte 6 Threads s | 37 | rechner-a | 1
  m6594 md5 Modell alle Threadzahlen | f1cb2b41 | rechner-a | 1
  Quelle: rechner-a:~/snai_pruef/knirps_gpu/log/chin/c128sr.log
  m6698 Held-out s1 | 2,2493 | c128sr
  m6699 Gewinn s1 gegen s0 | 0,0281 | c128sr
  m6700 Rang0 s1 | 44,41 % | c128sr
  m6701 Laufzeit Segment 1 | 17841 s (116,4 ms je Schritt) | c128sr
  m6702 Trainingsloss Segment 1 global | 2,26448 | c128sr
  m6703 Fehlerkanal s1 | nur bekannte NET2NET-GUARD-Meldung L2.rms_ffn beim Laden, kein Eingriff | c128sr
  Quelle: rechner-a:~/snai_pruef/knirps_gpu/log/chin/c128sr_s2.train.log (Laden von s1), Wächter in proj_sr nur Meldung
  m6713 Tote Kanäle beim Laden | L2.rms_ffn 128/128 | c128sr_s0
  m6714 Tote Kanäle beim Laden | L1.rms_ffn 20/128 (108-127), L2.rms_ffn 128/128 | c128sr_s1
  Quelle: rechner-a:~/snai_pruef/knirps_gpu/log/chin/c128sr.log, c128sr_s3.train.log
  m6788 Held-out s2 | 2,2439 | c128sr
  m6789 Gewinn s2 gegen s1 | 0,0054 | c128sr
  m6790 Rang0 s2 | 44,45 % | c128sr
  m6791 Laufzeit Segment 2 | 17867 s (116,6 ms je Schritt) | c128sr
  m6792 Trainingsloss Segment 2 global | 2,25275 | c128sr
  m6793 Tote Kanäle beim Laden | L1.rms_ffn 20/128 (108-127), L2.rms_ffn 128/128, unverändert gegen s1 | c128sr_s2
  Quelle: rechner-a:~/snai_pruef/knirps_gpu/log/chin/c128sr.log, c128sr_s4.train.log
  m6794 Held-out s3 | 2,2481 | c128sr
  m6795 Gewinn s3 gegen s2 | -0,0042 | c128sr
  m6796 Rang0 s3 | 44,31 % | c128sr
  m6797 Laufzeit Segment 3 | 17791 s (116,1 ms je Schritt) | c128sr
  m6798 Trainingsloss Segment 3 global | 2,24882 | c128sr
  m6799 Tote Kanäle beim Laden | L1.rms_ffn 20/128 (108-127), L2.rms_ffn 128/128, unverändert | c128sr_s3
  Quelle: rechner-a:~/snai_pruef/knirps_gpu/lauf_chin.sh 3b459e2a, Funktion unter(); chin/lr_plan_c128sr.txt angelegt 2026-10-31 04:47 von Hand
  m6800 Auslöser Abkühlen nach Regel | erreicht nach s3 (s2 0,0054, s3 -0,0042), vom Skript verpasst | c128sr
  m6801 Skriptfehler | php -r liest negativen Gewinn als Option, unter() liefert keine 1, Zähler auf 0; Trockenlauf hatte keinen negativen Wert | c128sr
  m6802 Abweichung vom Kriterium | s4 läuft mit LR 0,001 statt 7,5e-4, Abkühlen eine Stelle später: s5 7,5e-4, s6 5e-4, s7 2,5e-4, s8 1e-4, ENDE vor s9 | c128sr
  Quelle: rechner-a:~/snai_pruef/knirps_gpu/log/chin/c128sr.log, c128sr_s5.train.log
  m6810 Held-out s4 | 2,2530 | c128sr
  m6811 Gewinn s4 gegen s3 | -0,0049 | c128sr
  m6812 Rang0 s4 | 44,16 % | c128sr
  m6813 Laufzeit Segment 4 | 17883 s (116,7 ms je Schritt) | c128sr
  m6814 Trainingsloss Segment 4 global | 2,24672 | c128sr
  m6815 Tote Kanäle beim Laden | L1.rms_ffn 20/128 (108-127), L2.rms_ffn 128/128, unverändert | c128sr_s4
  m6816 Start Segment 5 | LR 0,00075 laut Log und Worker-Argument, SR m 1 v 1 | c128sr
  Quelle: rechner-a: php ~/snai_pruef/knirps/gains.php in proj_sr, Anteil Kanäle mit Betrag Gain < 0,05 je Norm. Löst die Wächter-Zählung ab: Der Wächter meldet nur einen zusammenhängenden Block am Ende.
  m6837 FFN-Gains tot L0/L1/L2/L3 | 0 / 68 / 100 / 0 % | c128sr_s0
  m6838 FFN-Gains tot L0/L1/L2/L3 | 0 / 82,8 / 100 / 0 % | c128sr_s1
  m6839 FFN-Gains tot L0/L1/L2/L3 | 0 / 88,3 / 100 / 0 % | c128sr_s2
  m6840 FFN-Gains tot L0/L1/L2/L3 | 0 / 89,8 / 100 / 0 % | c128sr_s3
  m6841 FFN-Gains tot L0/L1/L2/L3 | 0 / 91,4 / 100 / 0 % | c128sr_s4
  m6842 Attention-Gains tot L0 | 15,6 / 24,2 / 37,5 / 39,8 / 42,2 % | s0 bis s4
  m6843 Mittel FFN-Gain L0/L3 | 2,42/1,70 auf s0, 3,64/2,67 auf s4 | c128sr
  Quelle: rechner-a:~/snai_pruef/knirps_gpu/log/chin/c128sr.log, c128sr_s6.train.log; gains.php
  m6854 Held-out s5 | 2,1974 (neuer Bestwert) | c128sr
  m6855 Gewinn s5 gegen s4 | 0,0556 | c128sr
  m6856 Rang0 s5 | 45,14 % | c128sr
  m6857 Laufzeit Segment 5 | 17788 s (116,1 ms je Schritt) | c128sr
  m6858 Trainingsloss Segment 5 global | 2,19545 | c128sr
  m6859 FFN-Gains tot L0/L1/L2/L3 | 0 / 89,8 / 100 / 0 % | c128sr_s5
  m6860 Attention-Gains tot L0 | 41,4 % | c128sr_s5
  m6861 Start Segment 6 | LR 0,0005 laut Log, SR m 1 v 1 | c128sr
  Quelle: rechner-a:~/snai_pruef/knirps_gpu/log/chin/c128sr.log, c128sr_s7.train.log; gains.php in proj_sr (Betrag Gain < 0,05)
  m6862 Held-out s6 | 2,1257 (neuer Bestwert) | c128sr
  m6863 Gewinn s6 gegen s5 | 0,0717 | c128sr
  m6864 Rang0 s6 | 45,66 % | c128sr
  m6865 Laufzeit Segment 6 | 17793 s (116,1 ms je Schritt) | c128sr
  m6866 Trainingsloss Segment 6 global | 2,12957 | c128sr
  m6867 Fehlerkanal s6 | nur bekannte NET2NET-GUARD-Meldungen L1.rms_ffn und L2.rms_ffn beim Laden, kein Eingriff | c128sr
  m6868 FFN-Gains tot L0/L1/L2/L3 | 0 / 90,6 / 100 / 0 % | c128sr_s6
  m6869 Attention-Gains tot L0 | 38,3 % | c128sr_s6
  m6870 Start Segment 7 | LR 0,00025 laut Warmup-Zeile und Worker-Argument, SR m 1 v 1, Start 19:28:54 | c128sr
  Quelle: rechner-a:~/snai_pruef/knirps_gpu/log/chin/c128sr.log, c128sr_s8.train.log; gains.php in proj_sr (Betrag Gain < 0,05)
  m6941 Held-out s7 | 2,0410 (neuer Bestwert) | c128sr
  m6942 Gewinn s7 gegen s6 | 0,0847 | c128sr
  m6943 Rang0 s7 | 47,54 % | c128sr
  m6944 Laufzeit Segment 7 | 17709 s (115,6 ms je Schritt) | c128sr
  m6945 Trainingsloss Segment 7 global | 2,03112 | c128sr
  m6946 Fehlerkanal s7 | nur bekannte NET2NET-GUARD-Meldungen L1.rms_ffn und L2.rms_ffn beim Laden, kein Eingriff | c128sr
  m6947 FFN-Gains tot L0/L1/L2/L3 | 0 / 90,6 / 100 / 0 % | c128sr_s7
  m6948 Attention-Gains tot L0 | 26,6 % | c128sr_s7
  m6949 Start Segment 8 | LR 0,0001 laut Warmup-Zeile und Worker-Argument, SR m 1 v 1, Start 00:24:26 | c128sr
  Quelle: rechner-a:~/snai_pruef/knirps_gpu/log/chin/c128sr.log, c128sr.mess.jsonl, c128sr.kontext.jsonl, c128sr.stichprobe.txt; gains.php in proj_sr; schluss/knirps128/v12.py d1498088 (Rot: Trainingszeilen V2 100 %, Zeichensalat V1 0 %)
  m7009 Held-out s8 | 1,9445 (Endstand, Bestwert) | c128sr
  m7010 Gewinn s8 gegen s7 | 0,0965 | c128sr
  m7011 Rang0 s8 | 48,93 % | c128sr
  m7012 Laufzeit Segment 8 | 17607 s (114,9 ms je Schritt) | c128sr
  m7013 Trainingsloss Segment 8 global | 1,93217 | c128sr
  m7014 Fehlerkanal s8 | nur bekannte NET2NET-GUARD-Meldungen beim Laden, kein Eingriff | c128sr
  m7015 FFN-Gains tot L0/L1/L2/L3 | 0 / 90,6 / 100 / 0 % | c128sr_s8
  m7016 Attention-Gains tot L0 | 18,8 % | c128sr_s8
  m7017 Rot-Probe Fenster gemischt s8 | 9,3251 | c128sr
  m7018 Held-out s8 heldout2.txt | 1,9378 (Trigramm 2,634) | c128sr
  m7019 Kontext-Sonde s8 k1/k4/k8/k16/k32/alles | 3,2912 / 2,5485 / 2,2706 / 2,0382 / 1,9228 / 1,9149 | c128sr
  m7020 V1 Grundfilter | 50/50 (100 %) | c128sr |  | 50
  m7021 V2 woertliche Kopien | 0/50 (0 %); alle Zeilen 0/81 | c128sr |  | 50
  m7022 V3 Held-out gegen Trigramm | 1,9445 < 2,6391 | c128sr
  m7023 Gewinn Abkuehlen s4 -> s8 | 0,3085 nats (13,7 %) | c128sr
  Quelle: rechner-a:~/snai_pruef/knirps_gpu/log/chin/c128sr_s*.train.log, Zeilen "GradNorm: x" (jede 5. Schritt-Zeile, n 30.629 je Segment; s9 Stand 06:2x, n 2.961). Geloggt ist Norm geteilt durch Clip-Schwelle. Nebenbeobachtung ohne Kriterium.
  m7024 GradNorm Median s0-s4 (LR 0,001) | 2,35 / 2,61 / 2,81 / 2,84 / 2,80 | c128sr
  m7025 GradNorm Median s5-s8 (Abkuehlen) | 3,39 / 4,19 / 5,77 / 7,93 | c128sr
  m7026 GradNorm Median s9 bisher (LR 5e-5) | 8,98 | c128sr
  m7027 GradNorm p05-p95 s4 / s8 | 2,48-3,69 / 6,35-9,92 | c128sr
  m7028 Final-RMSNorm-Gain Mittel s6 / s7 / s8 | 3,09 / 4,29 / 5,26 | c128sr
  Quelle: rechner-a:~/snai_pruef/knirps_gpu/log/chin/c128sr.log, c128sr_s9.train.log, gains.php, sonde_staende.php, quant_sonde.php, v12.py, probe_text.php. Nachsegment aus Neugier, ausserhalb des Kriteriums, e422 bleibt. Fehlerkanal 0.
  m7205 Held-out heldout.txt | 1,8851 (Gewinn 0,0594 gegen s8) | s9 | 1 | 700
  m7206 Held-out heldout2.txt | 1,8812 (s8 1,9378) | s9 | 1 | 700
  m7207 Rot gemischte Fenster | 9,5652 | s9 | 1
  m7208 Trainingsloss, Abstand zum Held-out | 1,87976, 0,005 | s9 | 1
  m7209 V1 / V2 | 50/50 / 0/50 | s9 | 1
  m7210 GradNorm Median | 10,30 | s9 | 1
  m7211 FFN tot L0/L1/L2/L3 | 0 / 90,6 / 100 / 0 % | s9 | 1
  m7212 Embeddings Stufen, tote Zeilen | 33, 0 | s9 | 1
  m7213 Blindvorhersage Embedding-RMS | 0,024007, Bereich [0,017; 0,024], knapp ausserhalb | s9 | 1
  m7214 Blindvorhersage s9/s8 | 0,888 <= 0,90, knapp | s9 | 1
  m7215 Eingabe endet auf Token ▁, gierig | nur [USER]; s4, s6, s7, s8 normal; ohne Leerzeichen normal (4 Eingaben) | s9 | 1
  m7216 Zeilen-RMS Steuerzeichen und ▁ gegen Median | 0,094-0,102 gegen 0,0225 | s9 | 1
Ergebnis e422 [2026-11-01 05:33]: erfuellt
  Fazit: V1-V3 erfuellt, aber nur ein Lauf mit einer Saat und mit Abweichung: Abkuehlen wegen Skriptfehler eine Stelle spaeter (m6800-m6802). Das Plateau bei 2,25 war unter konstanter LR 0,001 kein Modelllimit; ohne Abkuehlen haette man den Knirps um 0,3 nats zu frueh abgeschrieben. Die Tests pruefen Form und Kopien, nicht Sinn, die Leseproben enthalten weiter Unsinn. Der Endstand ist kein Plateau, der Gewinn war im letzten Segment am groessten.
  Offen: Wie weit es unter 1,94 noch geht. Ob die LR-Senkung allein wirkt (kein Vergleichslauf mit konstanter LR). Ob die Geschichten inhaltlich besser wurden (kein Sinn-Test, Wortfeld-Sonde nur auf s0/s1). Tote FFN-Kanaele L1, L2 bleiben.
  Datei: rechner-a:~/snai_pruef/schluss/knirps128/ERGEBNIS_chin128.md
Abgeloest und ausgeblendet: 1 rezept - voll=True zeigt sie.
Chronik (juengste 8 von 25, voll=True zeigt alle):
  2026-11-01 00:33 Messwerte m6941-m6949
  2026-11-01 05:33 Messwerte m7009-m7023
  2026-11-01 05:33 Ergebnis e422: erfuellt
  2026-11-01 05:33 Status laeuft -> ausgewertet (Ergebnis e422)
  2026-11-01 05:43 Nachsegment s9 auf Wunsch (2026-11-01, "nur aus Neugier"), ausserhalb des Kriteriums, aendert e422 nicht. LR 5e-5 (halbe letzte LR, 5 % der Spitze), voller Durchgang. Vorab: Gewinn gegen s8 (1,9445) ab 0,02 nats = Abkuehlen bringt noch etwas, darunter = ausgeschoepft; unter 10 % des Loss ist kein Vergleich gemeint, nur Beobachtung. Mitgelesen: heldout2, Abstand Training/Held-out, V1-V3. Erwartung vorher notiert: Gewinn deutlich unter 0,0965, weil die Schrittweite halbiert ist.
  2026-11-01 05:49 Rezept r483
  2026-11-01 06:18 Messwerte m7024-m7028
  2026-11-01 13:57 Messwerte m7205-m7216
```
