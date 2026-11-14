# snai/tote-spalten-wachsen

```text
snai/tote-spalten-wachsen - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 13:33
!! ohne Kriterium
Frage: Warum wachsen die w_up-Spalten toter Kanaele in c128sr von s7 nach s8 bei fallender LR, Gradient nahe 0 und Decay 0,1? (Nachfrage 2026-11-02 zu snai/gains-ueberlebende)
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Baut auf: snai/gains-ueberlebende, snai/v-klebt
Darauf baut: snai/v-klebt-deckel
Rezepte:
  r511 [2026-11-02] spalten.php <stand> an chin_c128sr s0-s9 (L1.w_up je Eingangskanal: Spaltennorm, RMS je Element, Anteil Elemente mit v==0 und m!=0, Median |m| und v, Zeilenskala), Python-Vergleich gegen sqrt(lr/(2*0,1)) als Gleichgewicht von Adam-Zufallsgang und Decay (Kosson u. a.); D = 110 Kanaele tot bei s3 und s9, U = 12 lebend bei s9
      quelltext: rechner-a:~/snai_pruef/kanal/spalten.php; cortex.nim adamStepI8 (delta = lr*m_hat/(sqrt(v_hat)+1e-8)), quantDequantAdamBlock (unter max/1e8 auf 0)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/kanal/spalten.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: spalten.jsonl, Mediane ueber die Kanaele der Menge; LR je Segment aus train_chin_c128sr_s*.jsonl
  m7503 RMS je Element, tote Spalten, s0..s9 | 0,041 0,041 0,041 0,040 0,039 0,035 0,029 0,021 0,114 0,068 | D |  | 110
  m7504 LR je Segment s0..s9 | 1e-3 x5, 7,5e-4, 5e-4, 2,5e-4, 1e-4, 5e-5 | c128sr
  m7505 Verhaeltnis RMS/Element zu sqrt(lr/0,2), s0..s9 | 0,58 0,58 0,58 0,57 0,56 0,57 0,58 0,59 5,09 4,31 | D |  | 110
  m7506 RMS je Element, lebende Spalten, s7 s8 s9 | 0,021 0,016 0,012 | U |  | 12
  m7507 Anteil Elemente v==0 und m!=0 in toten Spalten, s0..s7 / s8 / s9 | 0 / 1,000 / 1,000 | D |  | 110
  m7508 Anteil v==0 und m!=0 in lebenden Spalten, alle Segmente | 0 | U |  | 12
  m7509 Median v tote Elemente s6 s7 s8 | 2,1e-13, 5,1e-14, 0 | D
  m7510 Median | m | tote Elemente s8 | 1,35e-8 | D
  m7511 Median v lebende Elemente s8 | 2,8e-8 | U
  m7512 Median Zeilenskala L1.w_up s7 / s8 / s9 | 0,00045 / 0,0025 / 0,0015 | c128sr
  m7513 Spaltennorm tote s7 / s8 / s9 | 0,47 / 2,57 / 1,54 | D
  m7514 GradNorm Segmentmittel s7 / s8 / s9 (vorhandenes Log) | 5,63 / 9,99 / 11,54 | c128sr
Ergebnis e446 [2026-11-02 13:33]: beobachtung
  Fazit: Zwei Regime. s0-s7: die toten Spalten sitzen im Gleichgewicht aus Adam-Zufallsgang und Decay, RMS je Element = 0,57 x sqrt(lr/0,2) in allen acht Segmenten, sie SCHRUMPFEN mit der LR (0,041 auf 0,021); Decay wirkt. s8: Sprung auf das 5-fache des Gleichgewichts genau dort, wo in 100 % der toten Elemente v als 0 gespeichert ist bei m != 0 (v klebt, snai/v-klebt): der Schritt wird lr*m/(0+1e-8), bei |m| um 1e-8 bis 1e-7 also 1 bis 10 LR statt kleiner LR. Die Zeilenskala von w_up steigt dadurch um das 5,5-fache, das vergroebert die Quantisierung der LEBENDEN Gewichte in jeder Zeile. Deutung, nicht per Eingriff isoliert; der gepaarte Lauf snai/v-klebt-lauf (Klemme auf Code 1) ist der Eingriff, erwartete Minderung nur etwa 2,7-fach, weil sqrt(Code 1) in der Groessenordnung von eps liegt. Warum v zuerst klebt: v spannt als Quadrat die doppelte Dekadenzahl von m, bei gleicher Dynamik 1e8 je Block faellt es als erstes unter die Schwelle.
  Offen: Ein Modell, eine Saat, nur L1.w_up. Zusammenhang mit dem GradNorm-Anstieg s8/s9 ist zeitliches Zusammenfallen, nicht Ursache. Ob die groebere Zeilenskala Held-out kostet, misst v-klebt-lauf (G). Im Kriterium von v-klebt-lauf steht die Spaltennorm toter Kanaele nicht; sie laesst sich an den s8-Staenden der Arme nachtraeglich lesen.
Chronik:
  2026-11-02 13:32 angelegt
  2026-11-02 13:33 Rezept r511
  2026-11-02 13:33 Status geplant -> laeuft (Rezept r511)
  2026-11-02 13:33 Messwerte m7503-m7514
  2026-11-02 13:33 Ergebnis e446: beobachtung
  2026-11-02 13:33 Status laeuft -> ausgewertet (Ergebnis e446)
```
