# snai/swiglu-512-lang

```text
snai/swiglu-512-lang - ausgewertet, angelegt 2026-11-12, zuletzt 2026-11-13 04:00
Frage: Liegt SwiGLU bei Breite 512 nach einem langen Lauf über den vollen Zeichenkorpus (37 Segmente, ~46.000 Schritte) noch vor SiLU, und wächst oder schrumpft der Vorsprung mit der Textmenge?
Kriterium (festgelegt 2026-11-12 20:30, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/swiglu512/lang/KRITERIEN_lang.md (75a9c138, Prüfer eingearbeitet). Rezept r487/Stufe C, Fork-Lib 689ce92b, 3 Saaten. D = HO(SG)−HO(SI) nach seg39, heldout.txt 300 Fenster: VORN 3/3 neg und Mittel ≤ −0,02; HINTEN gespiegelt; GLEICH |Mittel| < 0,01 und alle |D| < 0,02; sonst OFFEN; knapp (0,003) → heldout_frisch. 10-%-Lesart daneben. Verlauf: D_früh (seg0–2) gegen D_spät (seg37–39): WÄCHST D_spät < D_früh − 0,01 in 3/3, SCHRUMPFT gespiegelt, sonst kein Trend (Pfad, mit LR vermischt). SI-Gegenprobe gegen r487 L2 1,697–1,725 ±0,03.
Plan: rechner-b:~/snai_pruef/swiglu512/lang/KRITERIEN_lang.md
Baut auf: snai/swiglu-512, snai/swiglu-knirps, snai/multistack-tiefe-512-ctx256
Rezepte:
  r702 [2026-11-12] rechner-b: cd ~/snai_pruef/swiglu512/lang && setsid nohup ./reihe_lang.sh (md5 71ca9417, PARALLEL-Datei 3, gestartet 2026-11-12 20:30:47; Lib 689ce92b+d78a86ed, SI-Genesis d9d0f9c3/4cc1b717/7804a784, SG-Genesis f04de169/4c0d2db8/66775741; Log lang/reihe_lang.log, Messungen lang/laeufe/<Arm>_s<k>/mess.jsonl)
Messwerte (Groesse | Wert | Arm | Start | n):
  m10826 ho seg39 SI s1/s2/s3 | 1.7005/1.7374/1.6894
  m10827 ho seg39 SG s1/s2/s3 | 1.7581/1.7730/1.7543
  m10828 D seg39 s1/s2/s3 | +0.0576/+0.0356/+0.0649
  m10829 D seg39 Mittel | +0.0527
  m10830 D frisch s1/s2/s3 | +0.0513/+0.0390/+0.0620
  m10831 D_frueh s1/s2/s3 (seg0-2) | -0.0753/-0.0828/-0.0222
  m10832 D_spaet s1/s2/s3 (seg37-39) | +0.0597/+0.0172/+0.0517
  m10833 Train-Loss seg39 SI s1/s2/s3 | 1.6148/1.6418/1.5897
  m10834 Train-Loss seg39 SG s1/s2/s3 | 1.6707/1.6603/1.6370
  m10835 Rot gemischt (alle 6) | 5.25-5.78
  m10836 Segmentzeit SI/SG s (3 zugleich) | 191/237
Ergebnis e655 [2026-11-13 04:00]: verfehlt
  Fazit: SWIGLU HINTEN: D seg39 +0,058/+0,036/+0,065, Mittel +0,053, 3/3, nicht knapp; frisch gleiche Richtung; 10-%-Lesart Gleichstand (1,02–1,04). Verlauf: VORSPRUNG SCHRUMPFT (kehrt sich um), Vorzeichenwechsel zwischen seg2 und seg15, auch im Trainingsverlust. Kontrollen 222/222, SI-Gegenprobe zu r487 innerhalb ±0,03. Die 1.000-Schritte-Tests (e650, e647) zeigten in die falsche Richtung; e650 bleibt für 1.000 Schritte richtig. SwiGLU mit diesem int8-Rezept nicht übernehmen; Ursache (LR-Abstimmung, int8-Spannweite, tote Gains, Breite 1360) nicht isoliert.
  Datei: rechner-b:~/snai_pruef/swiglu512/lang/ERGEBNIS_lang.md
Chronik:
  2026-11-12 20:30 angelegt
  2026-11-12 20:34 Rezept r702
  2026-11-12 20:34 Status geplant -> laeuft (Rezept r702)
  2026-11-13 04:00 Messwerte m10826-m10836
  2026-11-13 04:00 Ergebnis e655: verfehlt
  2026-11-13 04:00 Status laeuft -> ausgewertet (Ergebnis e655)
```
