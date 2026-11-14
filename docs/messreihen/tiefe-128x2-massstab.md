# snai/tiefe-128x2-massstab

```text
snai/tiefe-128x2-massstab - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 20:44
Frage: Weg 1 (Entscheidung 2026-11-02): Was leisten die Schichten 3 und 4 des Knirps im K1-Rezept? 128x2 gegen 128x4 (K1) und gegen 128x4 mit LNS, Held-out und Rechenzeit.
Kriterium (festgelegt 2026-11-02 19:36, vor dem ersten Messwert):
  Arm Z2: Genesis init_base 128x2 je Saat, sonst K1-Rezept unverändert (128, voll int8, gebunden, SR, Clip 1, LR 0,003, WD 0,1, Warmup 500, kurz9000, 9.002 Schritte, Saaten 4-11, 1 Thread, CPU rechner-b, Lib b72d9d76 mit Stellrad aus). Gleiche Fensterfolge über gleichen Sitzungsnamen. Hauptgröße Held-out 700 Fenster am Ende, zwei getrennte Vergleiche: Z = L(Z2) - L(K1) und Z' = L(Z2) - L(LNS). Regel je Vergleich: BESSER: Z2 besser in >= 6/8 UND Mittel <= -0,02; SCHLECHTER: umgekehrt; GLEICH: |Mittel| < 0,01 UND |D| < 0,02 in >= 6/8; sonst OFFEN; knapp 0,005. Rechenzeit: K1T s4 läuft gleichzeitig mit Z2 s4-s6 auf demselben Rechner, Verhältnis der Trainingssekunden; Abstand unter 10 % = Gleichstand. Rechenbezug: gleichzeitig gefahren, Last der Fremdläufe nicht kontrolliert. Kontrollen: K1T s4 md5 ee903784; Messung meldet layers 2; Training rc=0, STEPS_DONE 9002, Fehlerkanal 0 je Lauf; Wächter nur Meldung. Aufbau: gemeinsam ändern sich Schichtzahl, Parameterzahl und Tiefe der Gradienten; das ist die Frage. Gewichte sind nicht gepaart (andere Genesis), Fenster schon. Nebenmechanismen: Revival aus, Clip an, Wächter meldet nur. Größter freier Parameter: LR 0,003 und Budget 9.002, beide für 128x4 gewählt; Reichweite daher nur dieses Rezept, 'kein Nutzen' hieße: nicht in 9.002 Schritten bei LR 0,003. Lange Läufe wären der zweite Verlauf vor jeder allgemeinen Aussage. Mitgeschrieben t1000/t3000, Gains je Schicht.
Darauf baut: snai/budget-tiefe, snai/tiefe-budget-r
Rezepte:
  r531 [2026-11-02] rechner-b ~/snai_pruef/clip_lns/reihe_z2.sh: Genesis php init_base.php clip_gen_z2_s<s>.snai 0 128 128 2 512 <s>, Lib b72d9d76 Stellrad aus, CLIP_LR=0.003 CLIP_GENPFX=z2_ ./lauf_clip_lns.sh z2 Z2 - <s> daten/kurz9000.txt 1000,3000; K1T s4 gleichzeitig mit Z2 s4-s6 als Zeitbezug. Log log/z2.log.
Messwerte (Groesse | Wert | Arm | Start | n):
  m7813 Nachtrag vor dem Start, Prüfer (Gemini ohne Inhalt, Mistral) | Übernommen: Z' vermischt Tiefe und LNS, trennt nicht, was von beidem wirkt; Startgewichte sind nicht gepaart; Parameterzahl mitberichten; Befunde zu FFN L1-L3 nicht auf 128x2 übertragen. Verworfen: Tiefe und Kapazität vermischt (ist die Frage), Zeitverhältnis trivial (die Zahl wird gebraucht, die Regel nimmt sie nur auf)
  m7814 Dateigröße Genesis 128x4 / 128x2 in Byte | 14086684 / 9361948
  m7815 Kontrolle Genesis-Reproduktion clip_gen_s4 | 882308c1 = 882308c1
  m7871 Held-out Z2 Ende s4 bis s11 | 2.7096 2.7401 2.7004 2.7198 2.7012 2.7163 2.7432 2.7209
  m7872 Z = Z2 - K1 s4 bis s11 | 0.0368 0.0314 0.0264 0.0067 0.0451 0.0226 0.0527 0.0559
  m7873 Z Mittel, Bootstrap 95 % | 0.0347, 0.0237 bis 0.0452
  m7874 Z' = Z2 - LNS s4 bis s11 | 0.0790 0.0999 0.0652 0.0854 0.0612 0.0779 0.0891 0.0955
  m7875 Z' Mittel, Bootstrap 95 % | 0.0817, 0.0727 bis 0.0904
  m7876 Z Mittel t1000 / t3000 | 0.0269 / 0.0167
  m7877 Trainingssekunden K1T s4 / Z2 s4 s5 s6 gleichzeitig | 1637 / 931 755 930
  m7878 Zeitverhältnis 128x2 zu 128x4 | 0.53
  m7879 Kontrolle K1T s4 md5 | ee903784
  m7880 Tot FFN und Att L0, L1 Z2 s4 | 0,0/3,9; 0,8/0,0
  m7881 Tot FFN und Att L0, L1 Z2 s11 | 0,0/3,1; 1,6/1,6
Ergebnis e473 [2026-11-02 20:44]: erfuellt
  Fazit: 128x2 nach Wortlaut SCHLECHTER gegen K1 (8/8, +0,0347, 1,3 %) und gegen LNS (8/8, +0,0817, 3,1 %), bei 53 % der Rechenzeit. Beide Abstände sind der Größe nach unter der 10-%-Hausregel. 'Zusatzschichten ohne Nutzen' ist für dieses Rezept widerlegt, teuer und wenig ertragreich trifft zu; K1-Rezept, ein Text, 9.002 Schritte, 8 Saaten. Der Abstand wächst nach t3000, Budget-Lesart nicht geprüft. Z' vermischt Tiefe und LNS.
  Datei: rechner-a:~/snai_pruef/clip_lns/ERGEBNIS_tiefe_128x2.md
Chronik:
  2026-11-02 19:36 angelegt
  2026-11-02 19:37 Messwerte m7813-m7815
  2026-11-02 19:37 Status geplant -> laeuft (Messwerte m7813-m7815)
  2026-11-02 19:39 Rezept r531
  2026-11-02 20:44 Messwerte m7871-m7881
  2026-11-02 20:44 Ergebnis e473: erfuellt
  2026-11-02 20:44 Status laeuft -> ausgewertet (Ergebnis e473)
```
