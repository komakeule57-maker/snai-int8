# snai/dauerclip-lang

```text
snai/dauerclip-lang - ausgewertet, angelegt 2026-11-01, zuletzt 2026-11-01 19:18
Frage: Treibt das Dauer-Clipping den Anstieg der Gradientennorm, und schadet es, wenn die Norm steigt?
Kriterium (festgelegt 2026-11-01 13:37, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/gradnorm/kriterien_dclang.txt, vor dem ersten Lauf, Pruefer. Start c128sr s4, LR 2,5e-4, 30.000 Fenster, K1 und AUS, 3 Reihenfolgen gepaart. Gueltig nur, wenn GF K1 >= 1,3 x s4 in 3 von 3. CLIP TREIBT: Anstieg AUS <= 0,5 x K1 in 3 von 3. TREIBT NICHT: >= 0,8 x in 3 von 3. Sonst OFFEN. Held-out unter 10 % Gleichstand.
Plan: rechner-a:~/snai_pruef/gradnorm/kriterien_dclang.txt
Baut auf: snai/gradnorm-zerlegung, snai/gradnorm-skala, snai/gradclip-knirps-lr3
Darauf baut: snai/wdg-norm
Rezepte:
  r493 [2026-11-01] rechner-a: cd ~/snai_pruef/gradnorm && setsid -f nohup werkzeug/schlange_dc.sh > /dev/null 2>&1 < /dev/null
      quelltext: kriterien_dclang.txt fa160297, lauf_dc.sh 3da9461c, schlange_dc.sh f843de05, Lib ccb10b0f, PHP proj_gn0
      seed: Reihenfolge skala_r1..r3
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/gradnorm/log/dc_*.log, schlange_dc.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/knirps_gpu/log/chin/c128sr_s<N>.train.log, GradNorm-Zeilen jede 5. Schritt, ohne die ersten 200 Zeilen. Faktor = 1/max(Norm,1). Vorhandene Daten, s9 noch nicht ganz fertig (n 29.495).
  m7199 Clip-Anteil s0-s9 | 100 % in jedem Segment | K1 | 1
  m7200 Norm-Median s0/s4/s5/s6/s7/s8/s9 | 2,35 / 2,80 / 3,39 / 4,19 / 5,78 / 7,93 / 10,28 | K1 | 1
  m7201 Norm p05 s0/s8/s9 | 1,84 / 6,38 / 8,67 | K1 | 1
  m7202 Faktor Mittel s0/s4/s8/s9 | 0,428 / 0,351 / 0,127 / 0,097 | K1 | 1
  m7203 Faktor Streuung CV s0-s9 | 0,12 bis 0,16 | K1 | 1
  m7204 Anteil groesstes 1 % der Fenster am Rohquadrat | 4 bis 5 % | K1 | 1
  Quelle: rechner-a:~/snai_pruef/gradnorm/log/auswertung_dclang.txt (auswerten_dclang.py 9553ab39). Fehlerkanal 0, [CLIP] 1,0/1e+30, Step 1 je Paar gleich.
  m7260 GF s4 | 2,9327 | Start
  m7261 GF | 4,370 / 4,370 / 4,352 | K1 | r1,r2,r3
  m7262 GF | 4,347 / 4,341 / 4,330 | AUS | r1,r2,r3
  m7263 GF K1/s4 | 1,490 / 1,490 / 1,484 | K1 | r1,r2,r3
  m7264 A_AUS / A_K1 | 0,984 / 0,980 / 0,984 | AUS,K1 | r1,r2,r3
  m7265 GN Median letzte 5.000 Fenster | 4,155 / 4,160 / 4,206 | K1 | r1,r2,r3
  m7266 GN Median letzte 5.000 Fenster | 4,141 / 4,150 / 4,189 | AUS | r1,r2,r3
  m7267 Held-out | 2,0210 / 2,0229 / 2,0281 | K1 | r1,r2,r3
  m7268 Held-out | 2,0192 / 2,0198 / 2,0276 | AUS | r1,r2,r3
  m7269 Emb-RMS | 0,04848 / 0,04844 / 0,04842 | K1 | r1,r2,r3
  m7270 Emb-RMS | 0,04843 / 0,04868 / 0,04864 | AUS | r1,r2,r3
Ergebnis e430 [2026-11-01 19:18]: erfuellt
  Fazit: Gueltig und TREIBT NICHT: Das Clipping treibt den Anstieg der Norm nicht, A_AUS/A_K1 0,98 in 3/3; Held-out Gleichstand. Die Norm steigt auch ohne Clip um Faktor 1,48. Zusammen mit snai/dauerclip-saaten ist der Clip als Ursache fuer Norm und Gains in den gemessenen Bereichen raus. Bestaetigt nebenbei: Bei LR 2,5e-4 steigt die Norm in 30.000 Fenstern deutlich, snai/gradnorm-batch hat damit etwas zu messen.
  Offen: Ganzer Abkuehlplan, andere Modelle, was den Anstieg treibt (snai/gradnorm-batch laeuft; Tying fuer die Norm vermerkt).
  Datei: rechner-a:~/snai_pruef/gradnorm/ERGEBNIS_dauerclip_lang.md
Chronik:
  2026-11-01 13:37 angelegt
  2026-11-01 13:37 Messwerte m7199-m7204
  2026-11-01 13:37 Status geplant -> laeuft (Messwerte m7199-m7204)
  2026-11-01 13:37 Rezept r493
  2026-11-01 19:18 Messwerte m7260-m7270
  2026-11-01 19:18 Ergebnis e430: erfuellt
  2026-11-01 19:18 Status laeuft -> ausgewertet (Ergebnis e430)
```
