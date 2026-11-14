# snai/wd-gains

```text
snai/wd-gains - ausgewertet, angelegt 2026-11-01, zuletzt 2026-11-01 20:42
Frage: Treibt der Weight Decay auf den Gewichten (indirekt, die Gains selbst bekommen keinen) das Kippen der FFN-Gains in den mittleren Schichten?
Kriterium (festgelegt 2026-11-01 17:57, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/clip/kriterien_wd.txt. W0 (WD 0) gegen K1 (WD 0,1, vorhanden aus snai/dauerclip-saaten), 128x4, LR 0,003, 9.002 Schritte, Saaten 4-11 gepaart. D = K1 - W0 in L2.rms_ffn tot am Endstand. WD TREIBT: W0 < K1 in >= 6/8 und mittleres D >= 20. TREIBT NICHT: mittleres D < 10. Sonst OFFEN. D innerhalb 2 Punkten um eine Schwelle nicht erfuellt. Kontrolle: Wiederholung K1 s4 md5 ee903784, sonst Stopp.
Plan: rechner-b:~/snai_pruef/clip/kriterien_wd.txt
Baut auf: snai/dauerclip-saaten, snai/merkmal-gains-fp32
Darauf baut: snai/gains-spalten, snai/gains-batchgen, snai/wdg-kippen, snai/gains-v, snai/residuum-gains, snai/gains-kanalindex, snai/tying-gains
Rezepte:
  r495 [2026-11-01] rechner-b: cd ~/snai_pruef/clip && setsid -f nohup ./reihe_wd.sh > log/reihe_wd.out 2>&1 < /dev/null (je Lauf CLIP_WD=0 ./lauf_clip_wd.sh reihe_wd W0 - <s> daten/kurz9000.txt 1000,3000)
      quelltext: lauf_clip_wd.sh = lauf_clip.sh + Stellrad CLIP_WD; proj_clip Lib ccb10b0f
      seed: Saaten 4-11, Genesis wie snai/dauerclip-saaten
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/clip/log/reihe_wd.log, laeufe/reihe_wd/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/clip/log/auswertung_wd.txt (auswerten_wd.py 181cd5f5). K1R md5 ee903784, Fehlerkanal 0, STEPS_DONE 9002, Step 1 je Paar gleich.
  m7282 L2 tot K1 / W0, D | 79,7 / 5,5, +74,2 | K1,W0 | 4
  m7283 L2 tot K1 / W0, D | 0,8 / 2,3, -1,5 | K1,W0 | 5
  m7284 L2 tot K1 / W0, D | 22,7 / 4,7, +18,0 | K1,W0 | 6
  m7285 L2 tot K1 / W0, D | 49,2 / 49,2, 0,0 | K1,W0 | 7
  m7286 L2 tot K1 / W0, D | 61,7 / 31,2, +30,5 | K1,W0 | 8
  m7287 L2 tot K1 / W0, D | 59,4 / 39,8, +19,6 | K1,W0 | 9
  m7288 L2 tot K1 / W0, D | 60,2 / 7,0, +53,2 | K1,W0 | 10
  m7289 L2 tot K1 / W0, D | 85,9 / 68,8, +17,1 | K1,W0 | 11
  m7290 Mittel D, W0<K1 | 26,4, 6 von 8, Bootstrap 95 % 10,7-44,5 | K1,W0 | 4-11
  m7291 L2 tot Mittel | 52,5 / 26,1 | K1,W0 | 4-11
  m7292 L2 tot t=1.000 und t=3.000 Mittel | 0 / 0 und 0,5 / 0,2 | K1,W0 | 4-11
  m7293 Held-out Mittel | 2,6842 / 2,7003, W0 besser in 3 von 8 | K1,W0 | 4-11
  m7294 Norm Ende | 1,016 / 0,815 | K1,W0 | 4-11
  m7295 Emb-RMS | 0,114 / 0,262 | K1,W0 | 4-11
Ergebnis e431 [2026-11-01 20:42]: erfuellt
  Fazit: Nach Wortlaut WD TREIBT (6/8, mittleres D 26,4), die Zaehlung liegt genau auf der Mindestzahl. WD verstaerkt das Kippen etwa aufs Doppelte, ist aber keine notwendige Bedingung: Ohne WD kippt es weiter (Mittel 26 %, bis 69 %). Die Lesart "ohne WD kein Kippen" gilt fuer dieses Rezept nicht. WD abschalten ist kein Rezept: Held-out im Mittel nicht besser, Richtung uneinheitlich. Tying bleibt fuer die Norm vermerkt.
  Offen: Holt W0 mit laengerem Budget auf, beschleunigt WD also nur? Wirkung ueber die Gewichtsgroesse (Faktor 2,3) nicht isoliert. Andere LR und Abkuehlplan. Eigentlicher Ausloeser bleibt unbekannt.
  Datei: rechner-b:~/snai_pruef/clip/ERGEBNIS_wd_gains.md
Chronik:
  2026-11-01 17:57 angelegt
  2026-11-01 17:57 Rezept r495
  2026-11-01 17:57 Status geplant -> laeuft (Rezept r495)
  2026-11-01 20:42 Messwerte m7282-m7295
  2026-11-01 20:42 Ergebnis e431: erfuellt
  2026-11-01 20:42 Status laeuft -> ausgewertet (Ergebnis e431)
```
