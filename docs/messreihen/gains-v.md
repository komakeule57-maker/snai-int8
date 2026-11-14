# snai/gains-v

```text
snai/gains-v - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 13:30
Frage: F1: Kippen die FFN-Gains weniger, wenn ihr eigenes Adam-v nicht sinken kann? F2: Reproduziert der alte Schalter (Ratsche auf dem 8-Bit-v der Gewichte) auch im Rezept 128x4 Text? F3: Zieht der Gradient einer sterbenden Gain beständig zu null oder driftet sie im Rauschen?
Kriterium (festgelegt 2026-11-02 06:51, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/clip/kriterien_gv.txt (md5 2c88ad4b, mit Prüfer, vor dem ersten Lauf). L2 tot am Ende, E = Arm - K1 je Saat, Saaten 4-11. SCHÜTZT: Arm < K1 in >= 6/8 und mittleres E <= -20. VERHINDERT zusätzlich: Arm < 5 % in >= 6/8. HEBT: Arm > K1 in >= 6/8 und mittleres E >= 20. KEINE WIRKUNG: |mittleres E| < 10. Sonst OFFEN. Knapp 2 Punkte. F3 an K1T: ZUG Z >= 0,7 und S >= 1,5 x S(lebend), DRIFT Z in [0,4; 0,6] und S <= 1,25 x S(lebend), in allen zählenden Saaten, mindestens 4; sonst OFFEN. Kontrolle: K1T md5 gleich K1. Stufen B (Ratsche nur FFN-Gewichte) und C (kleinere Gain-LR) nur bedingt, mit eigenem Nachtrag.
Plan: rechner-b:~/snai_pruef/clip/kriterien_gv.txt
Baut auf: snai/merkmal-gains, snai/merkmal-gains-fp32, snai/wd-gains, snai/wdg-kippen
Darauf baut: snai/gains-v-b, snai/gains-vertretung, snai/ratsche-k64, snai/ee-lr-spaet
Rezepte:
  r502 [2026-11-02] cd ~/snai_pruef/clip && setsid -f nohup ./reihe_gv.sh > log/reihe_gv.out 2>&1 < /dev/null
      quelltext: bau_gv/libcortex.so b50b8edc (bau + werkzeug/patch_gv.py 42227295), lauf_gv.sh a92d7ee7, reihe_gv.sh 5f130b42
      parameter: 128x4, 8 Köpfe, voll int8, gebunden, LR 0,003, Warmup 500, WD 0,1, kurz9000, 9.002 Schritte; Arme K1T, V (SNAI_GAIN_V_MAX=1), R (SNAI_I8_MOM_SR=m)
      seed: Saaten 4-11, Saat hängt am Laufnamen
      rechner: rechner-b, Karte, nacheinander, rund 6 h
      logs: rechner-b:~/snai_pruef/clip/log/reihe_gv.log, laeufe/reihe_gv/, je Lauf gain.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/clip/log/auswertung_gv.txt, log/f3_gv.txt
  m7489 L2 tot Ende s4-s11 | 79,7/0,8/22,7/49,2/61,7/59,4/60,2/85,9 | K1 | 4-11 | 8
  m7490 L2 tot Ende s4-s11 | 1,6/20,3/42,2/62,5/69,5/62,5/57,8/99,2 | V | 4-11 | 8
  m7491 L2 tot Ende s4-s11 | 0/0/0/0/3,1/5,5/0/4,7 | R | 4-11 | 8
  m7492 E L2 Mittel | -0,50 (Bootstrap -24,1 bis 14,4) | V | 4-11 | 8
  m7493 E L2 Mittel | -50,79 (Bootstrap -67,0 bis -32,1) | R | 4-11 | 8
  m7494 Held-out Mittel | 2,6842 | K1 | 4-11 | 8
  m7495 Held-out Mittel | 2,6959 | V | 4-11 | 8
  m7496 Held-out Mittel | 2,6640 | R | 4-11 | 8
  m7497 GN Median letzte 1000, Mittel | 1,016 / 1,008 / 1,100 | K1/V/R | 4-11 | 8
  m7498 RMS emb Mittel | 0,1142 / 0,1147 / 0,1045 | K1/V/R | 4-11 | 8
  m7499 Z sterbend | 0,918/0,893/0,940/0,908/0,941 | K1T | 6,7,8,10,11 | 5
  m7500 S sterbend/lebend | 2,55/2,48/2,34/2,02/2,14 | K1T | 6,7,8,10,11 | 5
  m7501 v sinkt, Kanal-Fenster-Paare | 0 in 8/8 | V | 4-11 | 8
  m7502 Rauschen allein unter Adam bis unter 0,05, Simulation | 1 von 2000 | Gegenprobe | - | 2000
Ergebnis e445 [2026-11-02 13:30]: erfuellt
  Fazit: Das Sterben der FFN-Gains haengt am v der 8-Bit-Gewichte, nicht am v der Gains: V KEINE WIRKUNG, R SCHUETZT (L2 tot 1,7 gegen 52,5, 8/8; VERHINDERT nach Zahl 7/8, mit Knappheit nicht gesichert). F3 ZUG: der Loss-Gradient zieht sterbende Gains bestaendig zu null, WD auf Gains ist in K1 aus; sqrt(v) sterbender Kanaele steigt. Damit ist die Rueckkopplung ueber das eigene v fuer dieses Rezept raus, und der Schach-Befund gilt auch im Text-Rezept 128x4. Ratsche ist keine Reparatur wegen des bekannten Embedding-Kollapses. Naechster Schritt: Stufe B, Ratsche nur auf w_up und w_down.
  Offen: Welche Gewichte tragen den Effekt; warum der Loss die Gain dann nach unten zieht; Zusammenhang zur Normfrage nicht belegt; nur 128x4, 9.002 Schritte, LR 0,003; prod512b nicht gemessen.
  Datei: rechner-b:~/snai_pruef/clip/ERGEBNIS_gains_v.md
Chronik:
  2026-11-02 06:51 angelegt
  2026-11-02 06:51 Rezept r502
  2026-11-02 06:51 Status geplant -> laeuft (Rezept r502)
  2026-11-02 13:30 Messwerte m7489-m7502
  2026-11-02 13:30 Ergebnis e445: erfuellt
  2026-11-02 13:30 Status laeuft -> ausgewertet (Ergebnis e445)
```
