# snai/nan-gains

```text
snai/nan-gains - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 09:10
Frage: Laedt ein Stand mit NaN/Inf in Gains ohne Meldung, was macht das Training daraus, und steckt so etwas im Bestand?
Kriterium (festgelegt 2026-11-02 09:03, vor dem ersten Messwert):
  Gemessen mit cortex-Lib fbc5f4d2 (Waechter nur Meldung), Stand chin_c128sr_s8, echter train_worker, per Byte-Patch in einer Dateikopie. Arme: kontrolle, nan1 (L1.rms_ffn Kanal 5 NaN), inf1 (dasselbe Inf), nanfinal (rms_final Kanal 5 NaN). F1 Bestand: Zahl nichtendlicher Werte in Gains und Zeilenskalen aller c128sr s0-s9 und prod512b-Staende. F2 Sichtbarkeit: Meldung beim Laden ja/nein, Flags von cortex_validate_i8. F3 Folge: erster Schritt mit NaN in Loss/GradNorm, Abbruch ja/nein, nichtendliche Werte im gespeicherten Ergebnisstand. Urteil RELEVANT: mindestens ein Arm laedt ohne Meldung UND laeuft ohne Abbruch weiter mit verfaelschtem Loss oder gespeicherten nichtendlichen Werten. Fehlt eines: RANDFEHLER. Kontrolle: Arm kontrolle ohne NaN, Patch per Assertion genau einmal im Dateitext; Rot: der Patch muss im Scan als nichtendlich erscheinen. Reichweite: ein Stand, kuenstliche Beschaedigung, sagt nichts ueber die Haeufigkeit ausser F1.
Baut auf: snai/l2sum-float32
Darauf baut: snai/nan-quant, snai/gesamt-fix
Rezepte:
  r506 [2026-11-02] rechner-b:~/snai_pruef/fix7/lauf.sh (patch.php <quelle> <ziel> <arm>; train_worker.php chunk out 1 base 3 0.0001 1 0.0001 0.1 0 0; scan.php)
      quelltext: libcortex.so fbc5f4d2 (cortex 19ba888e), PHP des Projektbaums
      parameter: Stand chin_c128sr_s8, 60.000 Byte Chunk, 33 Logzeilen bis Schritt 145, LR 1e-4, 1 Thread, CPU
      rechner: rechner-b
      logs: rechner-a:~/snai_pruef/fix7/ (erg.txt, kontrolle.log, nan1.log, inf1.log, nanfinal.log)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: fix7/erg.txt und Armlogs
  m7406 Loss Schritt 145 | 4,674937 | kontrolle
  m7407 Loss Schritt 145 | 12,428064 | nan1
  m7408 Loss Schritt 145 | 10,658457 | inf1
  m7409 Loss Schritt 145 | 12,999040 | nanfinal
  m7410 GradNorm nan, Zeilen | 0/33 | kontrolle
  m7411 GradNorm nan, Zeilen | 33/33 | nan1
  m7412 GradNorm nan, Zeilen | 33/33 | inf1
  m7413 GradNorm nan, Zeilen | 33/33 | nanfinal
  m7414 Validate-Meldungen beim Laden | 0 | nan1
  m7415 Validate-Meldungen beim Laden | 0 | inf1
  m7416 Validate-Meldungen beim Laden | 0 | nanfinal
  m7417 Worker rc | 0 | alle vier Arme
  m7418 nichtendliche Gains im Ergebnisstand | 1 | nan1
  m7419 nichtendliche Gains im Ergebnisstand | 1 | inf1
  m7420 nichtendliche Gains im Ergebnisstand | 1 | nanfinal
  m7421 nichtendliche Gains im Ergebnisstand | 0 | kontrolle
  m7422 nichtendlich in Gains, Skalen, Momenten: Bestand | 0 in 19 Staenden | c128sr s0-s9, prod512 6, rueckwaerts 1, prod512b s0 s1
Ergebnis e439 [2026-11-02 09:10]: erfuellt
  Fazit: RELEVANT nach Kriterium: ein einziger NaN/Inf-Gain laedt ohne Meldung, der Worker meldet Erfolg und speichert den Fehler weiter, gelernt wird praktisch nicht mehr. Im Bestand kommt es nicht vor, also vorbeugende Haertung, keine Erklaerung fuer tote Gains oder die Norm. Vorschlag: Vollscan der Gains beim Laden und in cortex_validate_i8.
  Offen: Kuenstliche Beschaedigung an einem Stand. prod512b nur s0 und s1 gescannt. Warum der Loss trotz NaN endlich bleibt, gehoert zu Punkt 8. Korrektur noch nicht gebaut.
  Datei: rechner-a:~/snai_pruef/PRUEFUNG_cortex_2026-11-02.md
Chronik:
  2026-11-02 09:03 angelegt
  2026-11-02 09:10 Rezept r506
  2026-11-02 09:10 Status geplant -> laeuft (Rezept r506)
  2026-11-02 09:10 Messwerte m7406-m7422
  2026-11-02 09:10 Ergebnis e439: erfuellt
  2026-11-02 09:10 Status laeuft -> ausgewertet (Ergebnis e439)
```
