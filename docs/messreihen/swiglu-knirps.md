# snai/swiglu-knirps

```text
snai/swiglu-knirps - ausgewertet, angelegt 2026-11-12, zuletzt 2026-11-12 19:31
Frage: Senkt ein SwiGLU-FFN bei gleicher Parameterzahl den Held-out-Verlust des Knirps 128x4 gegenüber SiLU, im Rezept HR (snai/baum-wsd), 9.002 Schritte?
Kriterium (festgelegt 2026-11-12 18:13, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/swiglu/KRITERIEN_knirps.md. Arme SI (SiLU, ffn 512) und SG (SwiGLU h=344, Startskala 0,02; +0,8 % Parameter); 8 Saaten s4-s11, 16 Läufe; Rezept HR (F per Bit, Warmup 2000, Abkühlen 8102-9002 auf 0,1, LR 0,003); Tokenizer und Revival-aus wie snai/baum-wsd aus proj_haupt_neu. Held-out 700 Fenster heldout.txt am Endstand. D = SG - SI. BESSER 6/8 negativ UND Mittel <= -0,02; SCHLECHTER 6/8 positiv UND Mittel >= +0,02; GLEICH |Mittel| < 0,01 UND |D| < 0,02 in 6/8; sonst OFFEN; knapp (0,003 an Schwelle oder genau 6/8) -> heldout2 + gepaarter Bootstrap 95 %. SCHLECHTER/OFFEN ist von der Startskala nicht trennbar (SG2 auf Entscheidung gestrichen). Prüfer vor dem Start (zweitmeinung 2026-11-12), Nachtrag in der Datei.
Plan: rechner-a:~/snai_pruef/swiglu/KRITERIEN_knirps.md
Baut auf: snai/swiglu-umbau, snai/baum-wsd
Darauf baut: snai/swiglu-512, snai/swiglu-ausgabe, snai/swiglu-512-lang
Rezepte:
  r698 [2026-11-12] cd ~/snai_pruef/swiglu && setsid nohup ./reihe_swi.sh > log/reihe.out 2>&1 < /dev/null &
      quelltext: Fork e2190f0, Lib bd669325; reihe_swi.sh 6ac6fa42, lauf_swi.sh dc73654b (aus lauf_baum.sh 3f7a8cf2 per assert); KRITERIEN_knirps.md 77f95f5a; Tokenizer 35d4dd21 und revival_config 88a3b1bc aus proj_haupt_neu; Genesis SI proj_clip clip_gen_s<s> (s4 = Fork-init_base bytegleich 882308c1), SG gen/swi_gen_s<s> (Fork-init_base, SNAI_SWIGLU=1, h=344)
      parameter: SI ffn 512, SG h=344 (Startskala 0,02); HR: SNAI_EMB_EIN=1 SNAI_GENESIS_RUN=1, Warmup 2000, START 8102, STEPS 9002, MIN 0,1, LR 0,003; kurz9000 (8d232de6), 1 Thread, CPU, Snapshots 1000/3000; Messung mess_text.php 700 Fenster heldout.txt mit cwd = Laufkopie
      seed: s4-s11
      rechner: rechner-a, 6 zugleich (Training ~110 MB, Messung ~150 MB RSS gemessen)
      logs: rechner-a:~/snai_pruef/swiglu/log/reihe.log, laeufe/swi/*, log/gains.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/swiglu/log/reihe.log, laeufe/swi/*/mess.jsonl, log/ho2.jsonl, log/gains.jsonl; Auswertung inline (python, Bootstrap 10.000, Saat 1)
  m10712 D=SG-SI heldout Mittel | -0,0174 (7/8 neg, Betrag D unter 0,02 in 5/8, sd 0,0102, BS -0,0238..-0,0104) | SG-SI | s4-s11 | 8
  m10713 D je Saat heldout s4..s11 | -0,0202 -0,0309 -0,0182 -0,0117 +0,0004 -0,0173 -0,0114 -0,0296 | SG-SI | s4-s11 | 8
  m10714 D=SG-SI heldout2 Mittel (Knapp-Regel) | -0,0160 (7/8 neg, Betrag D unter 0,02 in 6/8, sd 0,0102, BS -0,0223..-0,0091) | SG-SI | s4-s11 | 8
  m10715 D je Saat heldout2 s4..s11 | -0,0165 -0,0286 -0,0185 -0,0122 +0,0025 -0,0155 -0,0100 -0,0290 | SG-SI | s4-s11 | 8
  m10716 heldout Mittel | 2,4293 | SI | s4-s11 | 8
  m10717 heldout Mittel | 2,4119 | SG | s4-s11 | 8
  m10718 D Snapshot 1000 heldout Mittel | -0,0414 (8/8 neg) | SG-SI | s4-s11 | 8
  m10719 D Snapshot 3000 heldout Mittel | -0,0166 (6/8 neg) | SG-SI | s4-s11 | 8
  m10720 Sekunden je Lauf Mittel | SI 1229, SG 1292 (+5 %) | beide | s4-s11 | 16
  m10721 tote FFN-Gains je Schicht L0-L3 max | SI 0/0/3,1/0,8 %, SG 0/3,9/9,4/0,8 % | beide | s4-s11 | 16
  m10722 Kontrollen rc0/9002/embein/flags 3 bzw. 7/korrigiert 0/messerr 0 | 16/16 | alle | s4-s11 | 16
  m10723 M1 SI s4 proj_haupt_neu = Fork | 2,4285 = 2,4285 | SI | 4 | 1
  m10724 M2 SG s4 in proj_haupt_neu | Abbruch unbekannte Bits | SG | 4 | 1
  m10725 M3 SG s4 ohne SNAI_SWIGLU = mit | 2,4083 = 2,4083 | SG | 4 | 1
Ergebnis e647 [2026-11-12 19:31]: keine_aussage
  Fazit: Urteil nach Wortlaut OFFEN: heldout knapp (−0,0174, 7/8), Nachmessung heldout2 −0,0160, 7/8 negativ, Bootstrap −0,0223..−0,0091, weder BESSER (−0,02 verfehlt) noch GLEICH. Zweite Lesart: kein Hin und Her der Saaten, sondern ein beständiger kleiner Vorsprung von SwiGLU unter der vorab gesetzten Relevanzschwelle. SwiGLU hilft am Knirps also etwas, dass es sich lohnt, ist nach der eigenen Schwelle nicht nachgewiesen. Der befürchtete langsame Anlauf trat nicht auf (Snapshot 1000: −0,041, 8/8), SG2 ist damit nicht mehr dringend. Für den Hauptbaum folgt daraus allein keine Übernahme; die offene Frage ist die Produktionsbreite 512.
  Offen: Breite 512 und längeres Budget nicht geprüft (dafür fehlen Kartenpfade für SwiGLU). Nur ein Text, eine Startskala. Mehr tote FFN-Gains in L1/L2 bei SG (bis 9,4 % gegen 3,1 %), Ursache nicht geprüft. +5 % Laufzeit auf der CPU ohne Optimierung.
  Datei: rechner-a:~/snai_pruef/swiglu/ERGEBNIS_knirps.md
Chronik:
  2026-11-12 17:31 angelegt
  2026-11-12 18:13 Kriterium geaendert, vorher: rechner-a:~/snai_pruef/swiglu/KRITERIEN_knirps.md. Arme SI (SiLU, ffn 512), SG (SwiGLU h=344, Startskala 0,02), SG2 (h=344, Startskala 0,04); 8 Saaten s4-s11; Held-out 700 Fenster heldout.txt am Endstand. D = SG - SI (Haupturteil), D2 = SG2 - SI. Regel wie snai/baum-wsd: BESSER 6/8 negativ UND Mittel <= -0,02; SCHLECHTER 6/8 positiv UND Mittel >= +0,02; GLEICH |Mittel| < 0,01 UND |D| < 0,02 in 6/8; sonst OFFEN; knapp (0,003 an Schwelle oder genau 6/8) -> heldout2 + gepaarter Bootstrap 95 %. Lesart: D schlechter/offen und D2 besser/gleich = Startskala statt Bauart. Prüfer vor dem Start (zweitmeinung 2026-11-12), Nachtrag in der Datei.
  2026-11-12 18:13 Vor dem Start auf zwei Arme verkleinert (Vorgabe 2026-11-12: „Mach erstmal bitte nur den Vergleich SiLU gegen SwiGLU in 16 Läufen.“). Beim Bau des Laufskripts gefunden: Tokenizer des Forks kennt SNAI_VOCAB nicht, Revival steht im Fork an; beides wie in snai/baum-wsd aus proj_haupt_neu übernommen.
  2026-11-12 18:17 Rezept r698
  2026-11-12 18:17 Status geplant -> laeuft (Rezept r698)
  2026-11-12 19:30 Messwerte m10712-m10725
  2026-11-12 19:31 Ergebnis e647: keine_aussage
  2026-11-12 19:31 Status laeuft -> ausgewertet (Ergebnis e647)
```
