# snai/clipfix-gains

```text
snai/clipfix-gains - ausgewertet, angelegt 2026-11-01, zuletzt 2026-11-01 13:24
Frage: Schaltet der Clip-Fix vom 18.08.2026 das Kippen der FFN-Gains ein, kippt der heutige Stand also auch mit der alten Schwelle?
Kriterium (festgelegt 2026-11-01 12:34, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/clip/kriterien_alt.txt, vor dem ersten Lauf, Pruefer zweitmeinung. Arm ALT = SNAI_CLIP_SCHWELLE 1/128 in proj_clip, sonst wie reihe_lr3 (128x4, voll int8, SR, LR 0,003, WD 0,1, 9.002 Schritte, 3 Saaten). Messgroesse Anteil L2.rms_ffn |g|<0,05 am Ende. FIX SCHALTET: unter 5 % in 3 von 3. KEIN SCHALTER: mindestens 30 % in 2 von 3. Sonst saatabhaengig. 5 Prozentpunkte um eine Schwelle gelten als nicht erfuellt. Kontrollen: wiederholbar, Rot, Fehlerkanal.
Plan: rechner-b:~/snai_pruef/clip/kriterien_alt.txt
Baut auf: snai/gradclip-knirps-lr3, snai/gains-bestand
Darauf baut: snai/dauerclip-saaten
Rezepte:
  r491 [2026-11-01] rechner-b: cd ~/snai_pruef/clip && setsid -f nohup ./reihe_alt.sh > log/reihe_alt.out 2>&1 < /dev/null
      quelltext: proj_clip libcortex ccb10b0f, patch_clip.py unveraendert, lauf_clip.sh, reihe_alt.sh, kriterien_alt.txt
      parameter: SNAI_CLIP_SCHWELLE=0.0078125, CLIP_GPU=1, CLIP_LR=0.003, kurz9000.txt, Laeufe nacheinander
      seed: clip_gen_s1..3, Laufname clip_s<S>
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/clip/log/reihe_alt.log, laeufe/kontrolle3, laeufe/reihe_alt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: Vorhandene Modelle rechner-b:~/snai_pruef/clip/laeufe/reihe_lr3 und rechner-a:.../laeufe/reihe, gelesen mit bestand.py (bestand/rechner-b.jsonl, grim.jsonl); GradNorm aus train.log, Median je Bereich. Vergleichswerte, im Lauf vom 30.10. nicht als Gains-Reihe geplant.
  m7169 L2 tot, LR 0,003, Saat 1/2/3 | 32,0 / 2,3 / 68,0 % | K1 |  | 3
  m7170 L2 tot, LR 0,003, Saat 1/2/3 | 66,4 / 47,7 / 54,7 % | K5 |  | 3
  m7171 L2 tot, LR 0,003, Saat 1/2/3 | 57,8 / 69,5 / 39,1 % | AUS |  | 3
  m7172 L2 tot, LR 0,001, Saat 1/2/3 | 0,8 / 6,2 / 0,8 % | K1 |  | 3
  m7173 L2 tot, LR 0,001, Saat 1/2/3 | 6,2 / 0 / 0,8 % | K5 |  | 3
  m7174 L2 tot, LR 0,001, Saat 1/2/3 | 4,7 / 0 / 0,8 % | AUS |  | 3
  m7175 GradNorm Median Schritt 1.000-3.000 / 7.000-9.000, LR 0,003, Saat 1 | 1,037 / 1,049 | K1 | 1
  m7176 GradNorm Median Schritt 1.000-3.000 / 7.000-9.000, LR 0,003, Saat 1 | 1,190 / 1,070 | K5 | 1
  m7177 GradNorm Median Schritt 1.000-3.000 / 7.000-9.000, LR 0,003, Saat 1 | 1,220 / 1,088 | AUS | 1
  Quelle: rechner-b:~/snai_pruef/clip/log/alt_gains.jsonl, laeufe/reihe_alt/*/lauf.log, train.log. K-A K1 86face63 zweimal; ALT 461e6e9f; Fehlerkanal 0; STEPS_DONE 9002; mess.err 0 Byte. K-B Teil Schritt 1 nicht ablesbar (erste Norm-Zeile Schritt 100).
  m7189 L2 tot Saat 1/2/3 | 50,8 / 0,8 / 71,1 % | ALT |  | 3
  m7190 L2 Median Saat 1/2/3 | 0,05 / 0,90 / 0,02 | ALT |  | 3
  m7191 Alle Schichten tot, Saat 1 | 0 / 10,2 / 50,8 / 1,6 % | ALT | 1
  m7192 Alle Schichten tot, Saat 2 | 0 / 7,8 / 0,8 / 5,5 % | ALT | 2
  m7193 Alle Schichten tot, Saat 3 | 0 / 0 / 71,1 / 2,3 % | ALT | 3
  m7194 Held-out Saat 1/2/3 | 2,7206 / 2,6892 / 2,6844 | ALT |  | 3
  m7195 Held-out Saat 1/2/3 | 2,7191 / 2,6969 / 2,6730 | K1 |  | 3
  m7196 Held-out Saat 1/2/3 | 2,7632 / 2,7253 / 2,7193 | K5 |  | 3
  m7197 Held-out Saat 1/2/3 | 2,7872 / 2,7520 / 2,7117 | AUS |  | 3
  m7198 GradNorm Median Schritt 7.000-9.000, Saat 1/2/3 | 1,060 / 1,043 / 1,039 | ALT |  | 3
Ergebnis e426 [2026-11-01 13:24]: verfehlt
  Fazit: KEIN SCHALTER: Der Clip-Fix schaltet das Kippen der Gains nicht. Mit der alten Schwelle kippt derselbe Stand genauso (50,8 / 0,8 / 71,1 % gegen 32,0 / 2,3 / 68,0 %), gleiches Saatmuster, Held-out-Abstand hoechstens 0,4 %. Der Clip kommt damit als Ursache in diesem Rezept nicht mehr in Frage, auch nicht ohne Clip (AUS kippt ebenso). Weiter fuehrt die Beobachtung, dass Saat 2 nur unter Dauer-Clip gesund bleibt; 3 Saaten tragen das nicht.
  Offen: Nur int8-Pfad, 9.002 Schritte, LR 0,003, heutiger Stand. Lange Laeufe und die steigende Norm nicht abgedeckt; FP32-Pfad nicht gepatcht. Ob dauerndes Clippen eine Saat schuetzt, ungeklaert.
  Datei: rechner-b:~/snai_pruef/clip/ERGEBNIS_clipfix_gains.md
Chronik:
  2026-11-01 12:34 angelegt
  2026-11-01 12:34 Rezept r491
  2026-11-01 12:34 Status geplant -> laeuft (Rezept r491)
  2026-11-01 12:34 Messwerte m7169-m7177
  2026-11-01 13:24 Messwerte m7189-m7198
  2026-11-01 13:24 Ergebnis e426: verfehlt
  2026-11-01 13:24 Status laeuft -> ausgewertet (Ergebnis e426)
```
