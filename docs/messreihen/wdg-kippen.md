# snai/wdg-kippen

```text
snai/wdg-kippen - ausgewertet, angelegt 2026-11-01, zuletzt 2026-11-02 01:18
Frage: Aendert Decay auf den RMSNorm-Gains das Kippen der FFN-Gains?
Kriterium (festgelegt 2026-11-01 22:13, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/clip/kriterien_wdg.txt Teil A. G1 (Decay 0,1 auf Gains) gegen K1, Saaten 4-11, 128x4, LR 0,003, 9.002 Schritte. E = G1 - K1 in L2 tot. VERSTAERKT: G1 > K1 in >= 6/8 und mittleres E >= 20. SENKT spiegelbildlich. KEINE: |E| < 10. Sonst OFFEN. Sind alle Gains um > Faktor 3 geschrumpft: reine Skalierung, nicht deutbar. Kontrolle Lib ohne Schalter md5 ee903784.
Plan: rechner-b:~/snai_pruef/clip/kriterien_wdg.txt
Baut auf: snai/wd-gains, snai/dauerclip-saaten
Darauf baut: snai/gains-v
Rezepte:
  r498 [2026-11-01] rechner-b: cd ~/snai_pruef/clip && setsid -f nohup ./reihe_g1.sh > log/reihe_g1.out 2>&1 < /dev/null (CLIP_LIB=bau_wdg/libcortex.so, SNAI_WD_GAINS=0.1, lauf_clip.sh reihe_g1 G1 - <s> kurz9000 1000,3000)
      quelltext: bau_wdg = bau_clip + patch_wdg.py, Lib aa5f61e8
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/clip/log/reihe_g1.log, laeufe/reihe_g1/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/clip/log/auswertung_g1.txt (auswerten_g1.py 97471b70)
  m7333 L2 tot % | 86,7 | G1 | 4 | 9002
  m7334 L2 tot % | 100 | G1 | 5 | 9002
  m7335 L2 tot % | 75,0 | G1 | 6 | 9002
  m7336 L2 tot % | 100 | G1 | 7 | 9002
  m7337 L2 tot % | 100 | G1 | 8 | 9002
  m7338 L2 tot % | 81,2 | G1 | 9 | 9002
  m7339 L2 tot % | 92,2 | G1 | 10 | 9002
  m7340 L2 tot % | 98,4 | G1 | 11 | 9002
  m7341 E mittel G1-K1 | +39,2 (Bootstrap 22,2 bis 60,0), G1>K1 8/8 | G1 gegen K1 | 4-11 | 8
  m7342 L2 tot Mittel | 52,5 gegen 91,7 | K1 gegen G1 | 4-11 | 8
  m7343 L2 tot t3000 Mittel | 0,5 gegen 10,2 | K1 gegen G1 | 4-11 | 8
  m7344 L2 tot t1000 | 0 gegen 0 | K1 gegen G1 | 4-11 | 8
  m7345 L1 tot % Bereich | 0,8-3,1 gegen 52,3-96,1 | K1 gegen G1 | 4-11 | 8
  m7346 Faktor K1/G1 lebender FFN-Gains | L0 3,16-3,82, L1 5,3-11,1, L3 3,49-6,47 | G1 | 4-11 | 8
  m7347 Faktor K1/G1 lebender Attention-Gains | 1,22-2,80 | G1 | 4-11 | 8
  m7348 Held-out Mittel | 2,6842 gegen 2,6319, G1 besser 8/8 | K1 gegen G1 | 4-11 | 8
  m7349 GN Median letzte 1000 | 1,016 gegen 0,889 | K1 gegen G1 | 4-11 | 8
  m7350 RMS ffn | 0,1095 gegen 0,0780 | K1 gegen G1 | 4-11 | 8
  m7351 Kontrolle K1N md5 | ee903784 gleich K1 | K1N | 4 | 1
Ergebnis e434 [2026-11-02 01:18]: erfuellt
  Fazit: VERSTAERKT nach Wortlaut (8/8, E +39,2). Faktor-3-Klausel greift nach Wortlaut nicht, weil Attention-Gains nur 1,2-2,8-fach schrumpfen; auf FFN-Gains allein gelesen schrumpfen sie ueber Faktor 3, das Urteil ist dort teils Skalierung. Decay auf Gains schuetzt die Gains in diesem Rezept nicht, die Idee ist hier zu streichen. Den eigentlichen Ausloeser klaert die Reihe nicht. Held-out in 8/8 um rund 2 % besser trotz mehr toter Kanaele (nach 10-%-Regel Gleichstand): weiterer Hinweis, dass tote Gains in diesem Budget nicht schaden, kein Rezeptwechsel.
  Offen: Ausloeser des Kippens. Wirkung ueber laengere Strecke und auf die Norm (snai/wdg-norm). Ob der Held-out-Gewinn ueber den Abkuehlplan haelt. Reichweite: 128x4, LR 0,003, 9.002 Schritte, Decay 0,1 frei gewaehlt.
  Datei: rechner-b:~/snai_pruef/clip/ERGEBNIS_wdg_kippen.md
Chronik:
  2026-11-01 22:13 angelegt
  2026-11-01 22:13 Rezept r498
  2026-11-01 22:13 Status geplant -> laeuft (Rezept r498)
  2026-11-02 01:18 Messwerte m7333-m7351
  2026-11-02 01:18 Ergebnis e434: erfuellt
  2026-11-02 01:18 Status laeuft -> ausgewertet (Ergebnis e434)
```
