# snai/merkmal-gradzerl

```text
snai/merkmal-gradzerl - ausgewertet, begonnen 2026-10-16, angelegt 2026-10-21, zuletzt 2026-11-01 07:21
Frage: Treibt nach Yu et al. 2022 (Gl. 4) der Anteil (b) 'haeufige fremde Ziele' des Ausgabe-Gradienten die Merkmalsspalte c* (Paper-Uebertragung H-b)? Dazu: ist c* die gemeinsame Richtung von h^ (Q1), und ist der c*-Gradient konsistenter als die anderen Spalten (Q3)?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/gradzerl/kriterien.txt, Kopf 'Auftrag 2026-10-16, VOR der Messung' (Messung ~15:44-15:47)):
  H-b GESTUETZT, wenn in BEIDEN Kollaps-Saaten (b) betragsgroesster Anteil an c* in >= 70 % der Zeilen UND sign(G_b) == sign(G_gesamt) an c* in >= 70 %; WIDERLEGT, wenn beides < 50 % in beiden; sonst offen. Q1: c* hat Rang 1 bei |mittleres h^_c|. Q3: Konsistenz |Summe g|/Summe|g| an c* >= 2x Median der uebrigen Spalten. ROT: h^ durch Zufallsvektoren gleicher Norm -> Q1-Rang zufaellig, Q3 ~1. Geraet: Messkopie proj_grad, SNAI_DUMP_GRAD in trainStepI8Batched; LR 0, 400 Held-out-Zeilen.
Baut auf: snai/merkmal-gleichgewicht
Darauf baut: snai/merkmal-biaskanal-wd0
Rezepte:
  r95 [2026-10-21] cwd knirps/proj_grad: SNAI_DUMP_GRAD=<dump> php train_cluster.php <held400> mess.snai 1 1 <ckpt> 3 0 ... (LR 0; Log-Kopf mess_*.log); Zerlegung python3 merkmal/gradzerl/zerlege.py
      quelltext: proj_grad cortex.nim 5cbfccbc / libcortex.so fdc140f5 (Patch in trainStepI8Batched); Bank: Original, Patch ohne und mit Mitschrift bytegleich 79df9a23 (bank_*.log); zerlege.py 3f7f2111
      parameter: Checkpoints gross_gross_s1_s7, s3_s7, s2_s7, s1_s4; 400 Zeilen gebiete/heldout_gross.txt (15.952 Positionen); selten = 20 % seltenste Ids im seg7
      seed: -
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/gradzerl/mess_<ckpt>.log, dump_*.bin, E_*.json, ergebnis.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/gradzerl/ergebnis.jsonl (abgelesen 2026-10-21)
  m935 Anteil Zeilen mit (b) dominant an c* | 9,0 % | Original Stand s7 | 1 | 78
  m936 Vorzeichen G_b = gesamt an c* | 48,7 % | Original Stand s7 | 1 | 78
  m937 Anteil Zeilen mit (b) dominant an c* | 11,5 % | Original Stand s7 | 3 | 78
  m938 Vorzeichen G_b = gesamt an c* | 44,9 % | Original Stand s7 | 3 | 78
  m939 Anteil Zeilen mit (a) dominant an c* | 91,0 / 88,5 / 89,7 / 87,2 % | Original (s1_s7/s3_s7/s2_s7/s1_s4) |  | 4
  m940 Q1 Rang c* bei mittlerem h^ | 1 | Original (alle 4 Staende) |  | 4
  m941 Q3 Konsistenz c*/Rest | 0,31 | Original Stand s7 | 1 | 1
  m942 Q3 Konsistenz c*/Rest | 0,33 | Original Stand s7 | 3 | 1
  m943 Q3 Konsistenz c*/Rest | 0,21 | Original Stand s7 | 2 | 1
  m944 Q3 Konsistenz c*/Rest | 0,54 | Original Stand s4 | 1 | 1
  m945 Rot Q1-Rang / Q3 | 81 / 0,89 | Rot (h^ zufaellig) Stand s7 | 1 | 1
  m946 Plausibilitaet max Summe d_logits | <= 2e-6 | alle |  | 4
  m947 Plausibilitaet Loss Mitschrift / Log | 1,518 / 1,519 | Original Stand s7 | 1 | 1
Ergebnis e93 [2026-10-21 14:33]: verfehlt
  Fazit: Die Paper-Uebertragung ist widerlegt: an c* dominiert nicht der Zug fremder haeufiger Ziele (b, 9-12 %), sondern die Positionen, an denen die Zeile selbst Ziel ist (a, 88-91 %). Q1 ist erfuellt (c* ist ueberall die Hauptrichtung von h^), Q3 umgekehrt (der c*-Gradient hebt sich ueber 16k Positionen staerker auf). Die Erklaerung 'seltene Token degenerieren alle' aus Yu et al. traegt hier nicht. Die Nachmessung danach (ohne Vorab-Kriterium) brachte die fruchtbare Spur: in Kollaps-Staenden wirkt c* als verdeckter Logit-Bias (weiter in snai/merkmal-biaskanal-wd0).
  Offen: Nachmessung h^_c*-Mittel/Streuung und Final-RMSNorm-Gain an c* ist Beobachtung ohne Vorab-Kriterium: s1_s7 +822/189, s3_s7 -1126/211, s2_s7 +63/442, s1_s4 +116/154; Gain c* s4 50 -> s5 74 -> s7 99, WD0-Arm 74,8.
  Datei: rechner-a:~/snai_pruef/merkmal/gradzerl/kriterien.txt
Chronik:
  2026-10-21 14:32 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/gradzerl/kriterien.txt, Kopf 'Auftrag 2026-10-16, VOR der Messung' (Messung ~15:44-15:47))
  2026-10-21 14:32 Rezept r95
  2026-10-21 14:32 Status geplant -> laeuft (Rezept r95)
  2026-10-21 14:33 Messwerte m935-m947
  2026-10-21 14:33 Ergebnis e93: verfehlt
  2026-10-21 14:33 Status laeuft -> ausgewertet (Ergebnis e93)
  2026-11-01 07:21 VORBEHALT 2026-11-01: 'LR 0 (Gewichte bleiben)' stimmt nicht. train_worker.php ersetzt LR <= 0 durch 0,0005 (proj_grad Zeile 138); die Protokolle mess_*.log zeigen LR=0.0005000. Die Dumps entstanden also bei 400 Schritten mit LR 5e-4, nicht an einem festen Stand. Urteil nicht neu bewertet, nicht nachgemessen. Fund: snai/gradnorm-zerlegung, Rot-Probe.
```
