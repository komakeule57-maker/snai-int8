# snai/lns-gains

```text
snai/lns-gains - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 19:36
Frage: Weg 2 (Entscheidung 2026-11-02): Macht LayerNorm-Scaling nach Curse of Depth (Sun et al. 2025), Normausgang der Schicht l mit 1/sqrt(l+1) skaliert, die mittleren FFN-Zweige des Knirps 128x4 nutzbar, und verbessert es den Held-out?
Kriterium (festgelegt 2026-11-02 17:52, vor dem ersten Messwert):
  Umsetzung ohne Umbau des Vorwaertspfads: unter Adam ist ein fester Faktor c_l am Normausgang gleichbedeutend mit Gain-Start c_l und Adam-Lernrate c_l x lr auf diesen Gains (Adam normiert die Gradientengroesse weg). Arm LNS: Genesis clip_gen_s<saat> mit rms_att und rms_ffn der Schicht l auf c_l = 1/sqrt(l+1) (1 / 0,707 / 0,577 / 0,5), rms_final unveraendert, plus EIN Stellrad SNAI_TEST_LNS=1 in der Messkopie clip_lns/proj_clip: lr der Gains der Schicht l x c_l in upA. Sonst K1-Rezept (128x4, voll int8, gebunden, SR, Clip 1, LR 0,003, WD 0,1, Warmup 500, kurz9000, 9.002 Schritte), Saaten 4-11, CPU rechner-b (bitgleich zur Karte, K1C ee903784). Hauptgroesse Held-out 700 Fenster, D = L(LNS) - L(K1) am Ende: BESSER: LNS besser in >= 6/8 UND mittleres D <= -0,02; SCHLECHTER: umgekehrt; GLEICH: |mittleres D| < 0,01 UND |D| < 0,02 in >= 6/8; sonst OFFEN; knapp 0,005. Nebengroesse NUTZBAR: am LNS-Endstand w_down L2 = 0 (nullsetzen, mess_text) kostet D2 >= 0,05 nats in >= 6/8 (gegen K1: unter 0,006). Mitgeschrieben: tot L1/L2, Gains je Schicht an t1000/t3000/Ende, Norm. Kontrollen: Lib mit Stellrad aus auf K1-Genesis md5 ee903784; Rot: [LNS]-Zeile im Log, Genesis-Gains je Schicht wie gesetzt (kanal.php), Gains an t1000 nicht wieder bei 1,0 (sonst ist der Start weggewaschen und die Umsetzung sagt nichts); rc 0, STEPS_DONE 9002, Fehlerkanal leer. Gemeinsam aendert sich: Skala der Schichten und effektive Gain-LR; beides ist die Massnahme. Reichweite: ein Rezept, ein Text, 9.002 Schritte, 128x4.
Baut auf: snai/ffn2-null-training, snai/gains-vertretung, snai/tying-gains
Rezepte:
  r529 [2026-11-02] rechner-b ~/snai_pruef/clip_lns/reihe.sh: Lib b72d9d76 (proj_clip), SNAI_TEST_LNS=1 CLIP_GENPFX=lns_ CLIP_LR=0.003 ./lauf_clip_lns.sh reihe LNS - <s> daten/kurz9000.txt 1000,3000, Saaten 4-11, je 1 Thread, 4 zugleich; Genesis clip_gen_lns_s* per werkzeug/skaliere.php aus clip_gen_s*. K1-Vergleich: clip/laeufe/reihe_dc/K1_s*. NF2: nullsetzen.php "2:w_down", mess_text.php heldout.txt ngram.json 700 0. Gains: werkzeug/kanal.php nach log/kanal.jsonl.
Messwerte (Groesse | Wert | Arm | Start | n):
  m7787 Zusatzprobe Festlegung (nach Hauptergebnis, nur Beobachtung; Eintrag erst kurz nach Start gespeichert, Formatfehler) | Endstaende K1 und LNS s4-s11: w_down L1; w_down L3; w_down L1+L2+L3; w_down+w_o L1+L2+L3; Held-out 700 Fenster; Kosten = Loss genullt - Loss Endstand; Schwelle 0,05 wie NUTZBAR
  m7788 Held-out LNS Ende s4 | 2.6306
  m7789 Held-out LNS Ende s5 | 2.6402
  m7790 Held-out LNS Ende s6 | 2.6352
  m7791 Held-out LNS Ende s7 | 2.6344
  m7792 Held-out LNS Ende s8 | 2.6400
  m7793 Held-out LNS Ende s9 | 2.6384
  m7794 Held-out LNS Ende s10 | 2.6541
  m7795 Held-out LNS Ende s11 | 2.6254
  m7796 D LNS-K1 Ende s4 bis s11 | -0.0422 -0.0685 -0.0388 -0.0787 -0.0161 -0.0553 -0.0364 -0.0396
  m7797 D Mittel | -0.0469
  m7798 D Bootstrap 95 % (gepaart, 20000) | -0.0600 bis -0.0342
  m7799 D2 NF2 am LNS-Endstand s4 bis s11 | 0.0011 0.0000 0.0205 0.0075 0.0000 0.0000 0.0155 0.0000
  m7800 FFN tot Prozent Ende K1 L0 L1 L2 L3 (Schwelle 0,05) | 0.0 1.8 52.4 0.6
  m7801 FFN tot Prozent Ende LNS L0 L1 L2 L3 (Schwelle 0,05) | 0.0 35.7 83.1 73.6
  m7802 FFN tot Prozent Ende LNS L1 L2 L3 (Schwelle 0,05 x Startfaktor) | 32.2 80.3 68.5
  m7803 Median Gain t1000 K1 ffn L1 L2 L3 | 0.947 0.813 0.838
  m7804 Median Gain t1000 LNS ffn L1 L2 L3 | 0.662 0.462 0.395
  m7805 Median Gain t1000 K1 att L1 L2 L3 | 0.915 0.922 0.955
  m7806 Median Gain t1000 LNS att L1 L2 L3 | 0.638 0.536 0.475
  m7807 Norm Schritt 9000 LNS s4 bis s11 (Beobachtung) | 1.1394 1.1478 1.0812 2.2686 1.0344 1.0262 1.1532 1.0404
  m7808 Norm Schritt 9000 K1 s4 bis s11 (Beobachtung) | 1.1262 1.2400 1.0030 2.0940 1.1690 0.9990 1.1051 1.0130
  m7809 Zusatzprobe Kosten K1 w_down L1 / L3 / L1+L2+L3 / dazu w_o L1-3 (Mittel, Beobachtung) | 0.0134 0.1393 0.2034 0.7004
  m7810 Zusatzprobe Kosten LNS w_down L1 / L3 / L1+L2+L3 / dazu w_o L1-3 (Mittel, Beobachtung) | 0.0115 0.0042 0.0250 0.6326
  m7811 Kontrolle K1C s4 md5 | ee903784
  m7812 Kontrolle Training rc=0, STEPS_DONE 9002, ENDE, Fehlerkanal Training 0 | 8/8
Ergebnis e470 [2026-11-02 19:36]: teilweise
  Fazit: Hauptgröße BESSER (LNS 8/8, D im Mittel -0,0469, 95 % -0,0600 bis -0,0342), Nebengröße NUTZBAR nicht erfüllt (D2 >= 0,05 in 0/8, max 0,0205). FFN tot am Ende L1/L2/L3: LNS 35,7/83,1/73,6 %, K1 1,8/52,4/0,6 %. LNS hilft dem Held-out verlässlich, macht die FFN-Zweige aber nicht nutzbar, sondern entbehrlicher: Das Ziel, die mittleren Zweige zu retten, ist für dieses Rezept verfehlt. Beobachtung nach dem Hauptergebnis: FFN L1-L3 nullen kostet am LNS-Endstand 0,025 (K1 0,203), Attention dazu 0,63. Welcher Teil des Stellrads wirkt (Startskala oder Gain-LR), ist offen. Reichweite: K1-Rezept, ein Text, 9.002 Schritte, 128x4, 8 Saaten. Weg 1 (128x2) wird dadurch wichtiger; ein Arm mit LNS ohne FFN L1-L3 von Anfang an wäre der isolierende Eingriff.
  Datei: rechner-a:~/snai_pruef/clip_lns/ERGEBNIS_lns_gains.md
Chronik:
  2026-11-02 17:52 angelegt
  2026-11-02 19:24 Rezept r529
  2026-11-02 19:24 Status geplant -> laeuft (Rezept r529)
  2026-11-02 19:34 Messwerte m7787
  2026-11-02 19:35 Messwerte m7788-m7812
  2026-11-02 19:36 Ergebnis e470: teilweise
  2026-11-02 19:36 Status laeuft -> ausgewertet (Ergebnis e470)
```
