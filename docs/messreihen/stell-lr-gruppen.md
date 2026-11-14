# snai/stell-lr-gruppen

```text
snai/stell-lr-gruppen - ausgewertet, angelegt 2026-11-05, zuletzt 2026-11-05 07:09
Frage: Lohnt bei 128x4 (Rezept R, 9k, gebunden) eine getrennte Lernrate für die gebundene Embedding-/Kopf-Matrix (x0,3, x3; Everett u. a. 2024), und ist die globale LR 0,003 im Faktor-2-Gitter (0,0015, 0,006) richtig? Anlass: Anregung multi_stack für 768+, Vorgabe 2026-11-05: auch an kleinen Modellen messen.
Kriterium (festgelegt 2026-11-05 05:09, vor dem ersten Messwert):
  Wortlaut: rechner-a ~/snai_pruef/stell/KRITERIEN_lrgruppen.md (md5 de8b9fa5, mit Prüfer-Nachtrag, vor dem Start).
Arme je 8 Saaten s4-s11, gepaart gegen K = W9 aus snai/tiefe-budget-r (gleiches Rezept, Trainer, Laufskript, Genesis): T03 (SNAI_TIE_LR_MUL=0,3), T3 (=3), G05 (CLIP_LR 0,0015), G2 (0,006). KW = K-Wiederholung s4 auf der neuen Lib, muss md5-gleich W9_s4 (fb0d507b) sein, sonst K neu.
Regel je Arm, D = Arm − K, Held-out 700 Fenster am Endstand: BESSER D<0 in >=6/8 und Mittel <= −0,02; SCHLECHTER spiegelbildlich; GLEICH Betrag Mittel < 0,01 und Betrag D < 0,02 in >=6/8; sonst OFFEN. Knapp -> heldout2 und Bootstrap über die 8 Saaten, beide Lesarten.
(A) 0,003 IST IM GITTER RICHTIG, wenn kein G-Arm BESSER. (B) GETRENNTE LR LOHNT, wenn ein T-Arm BESSER; LOHNT NICHT IM GEPRÜFTEN BEREICH, wenn beide GLEICH oder SCHLECHTER; sonst OFFEN. (C) nur bei T BESSER: T gegen G gleicher Richtung, nur berichtet. Tote Gains nur berichtet.
Gemeinsam ändert sich bei T die LR der Matrix in beiden Rollen samt ihrem Decay (lr*wd), Eingang und Kopf trennt die Reihe nicht.
Plan: rechner-a:~/snai_pruef/stell/KRITERIEN_lrgruppen.md
Baut auf: snai/stell-emb-ungebunden, snai/tiefe-budget-r
Darauf baut: snai/stell-lr-leiter
Rezepte:
  r594 [2026-11-05] cd ~/snai_pruef/stell && setsid nohup ./reihe_lrgruppen.sh > log/lrgruppen.out 2>&1 < /dev/null &
      quelltext: Lib bau_tie a4359087 = bau_stell cortex.nim 2d80b3f0 (Lib c5f9fbaf) + werkzeug/patch_tie.py 11bbe18c; reihe_lrgruppen.sh 7d14188f; Trainer proj_clip/train_worker.php de34a553; lauf_stell.sh ecd0d42a
      parameter: Rezept R 128x4 9k: SNAI_EMB_EIN 11,3137085, Warmup 2000, Decay ab 8102 bis 9002, Boden 0,1, gebunden, SR, Clip 1; Arme T03/T3 (SNAI_TIE_LR_MUL 0,3/3), G05/G2 (CLIP_LR 0,0015/0,006), KW s4
      seed: s4-s11 (Genesis clip_gen_s<s>, Fensterfolge clip_s<s>)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/stell/log/lrgruppen.log, laeufe/lrgruppen/*, log/lrgruppen_gains.jsonl; Gerät log/geraet_tie.log
      notiz: Gerätetest geraet_tie.sh dfeef24d vor dem Start bestanden: ohne Stellrad und mit 1,0 md5-gleich bau_stell (517064e3), x3/x0,3 weichen ab mit TieLR-Zeile, ungebunden x3 md5-gleich ungebunden ohne (92628874), CLIP_LR 0,006 weicht ab. Bis zu 12 Läufe zugleich, Start nur bei MemAvailable >= 1800 MB.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a ~/snai_pruef/stell/werkzeug/ausw_lrgruppen.py (4c13af3f, Probe grün und rot gesehen), log/lrgruppen.log, log/geraet_tie.log
  m8983 Kontrollen 33 Läufe | rc 0, STEPS_DONE 9002, messF11 3, tie 1, sr 1, layers 4, korrigiert 0, messerr 0, Gains-Fehlerkanal leer | alle | s4-s11 | 33
  m8984 LR an adam_t 1/2000/8102/9002 | T03, T3, KW 1,5e-6/0,003/0,003/0,0003; G05 7,5e-7/0,0015/0,0015/0,00015; G2 3e-6/0,006/0,006/0,0006 | alle | s4-s11
  m8985 KW-Endstand md5 | fb0d507b = W9_s4, Bezug K gültig | KW | 4 | 1
  m8986 T03-K heldout | -0.0095 | 8/8 negativ, 8/8 Betrag < 0,02, BS -0,0119..-0,0072, GLEICH (KNAPP) | s4-s11 | 8
  m8987 T3-K heldout | +0.0278 | 0/8 negativ, BS +0,0225..+0,0333, SCHLECHTER | s4-s11 | 8
  m8988 G05-K heldout | -0.0479 | 8/8 negativ, BS -0,0538..-0,0422, BESSER | s4-s11 | 8
  m8989 G2-K heldout | +0.1153 | 0/8 negativ, BS +0,1013..+0,1334, SCHLECHTER | s4-s11 | 8
  m8990 Mittel heldout | W9 2,4291; T03 2,4196; T3 2,4569; G05 2,3812; G2 2,5444 | alle | s4-s11 | 8
  m8991 Tote L2-ffn-Gains Mittel ungefähr | W9 0,8 %; T03 0,2 %; T3 2,1 %; G05 0 %; G2 9,1 % | alle | s4-s11 | 8
  Quelle: rechner-a ~/snai_pruef/stell/log/lrgruppen_ho2.jsonl (ho2_lrgruppen.sh a0538947), ausw_lrgruppen.py --ho2; Bezug W9 aus log/tiefe27_ho2.jsonl
  m8992 T03-K heldout2 | -0.0094 | 8/8 negativ, 8/8 Betrag < 0,02, BS -0,0126..-0,0067, GLEICH (KNAPP) | s4-s11 | 8
  m8993 T3-K heldout2 | +0.0270 | 0/8 negativ, SCHLECHTER | s4-s11 | 8
  m8994 G05-K heldout2 | -0.0474 | 8/8 negativ, BS -0,0531..-0,0421, BESSER | s4-s11 | 8
  m8995 G2-K heldout2 | +0.1135 | 0/8 negativ, SCHLECHTER | s4-s11 | 8
Ergebnis e543 [2026-11-05 07:09]: teilweise
  Fazit: (A) ANDERE GLOBALE LR BESSER: LR 0,0015 schlägt 0,003 um 0,048 nats (8/8, heldout2 bestätigt), 0,006 kostet 0,115. 0,003 ist für 128x4 im Rezept R bei 9k zu hoch. (B) GETRENNTE LR DER GEBUNDENEN MATRIX LOHNT NICHT IM GEPRÜFTEN BEREICH: x3 SCHLECHTER (+0,028), x0,3 GLEICH, knapp, auf beiden Texten. Zweite Lesart: x0,3 bringt stetig rund 0,01 (8/8, Intervall ohne Null), unter der Schwelle und fünfmal kleiner als G05. Folge: Für kleine gebundene Modelle ist das Embedding-Stellrad erledigt. Der Hebel ist die globale LR, deren Optimum nach unten nicht eingegrenzt ist. Die Vorgabe 0,003 erst nach einer Leiter nach unten und einer 27k-Prüfung ändern.
  Offen: Optimum unter 0,0015; ob der Gewinn bei 27k hält; ob Plan R (-0,22) und die Budget-Ursache der mittleren Schichten bei kleinerer LR gleich ausfallen; welche Parametergruppe den G05-Gewinn trägt; Eingang gegen Kopf (bei Bindung nicht trennbar); Breiten außer 128.
  Datei: rechner-a:~/snai_pruef/stell/ERGEBNIS_lrgruppen.md
Chronik:
  2026-11-05 05:09 angelegt
  2026-11-05 05:09 Rezept r594
  2026-11-05 05:09 Status geplant -> laeuft (Rezept r594)
  2026-11-05 07:05 Messwerte m8983-m8991
  2026-11-05 07:09 Messwerte m8992-m8995
  2026-11-05 07:09 Ergebnis e543: teilweise
  2026-11-05 07:09 Status laeuft -> ausgewertet (Ergebnis e543)
```
