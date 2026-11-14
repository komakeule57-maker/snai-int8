# snai/ditto-anteil

```text
snai/ditto-anteil - ausgewertet, angelegt 2026-10-25, zuletzt 2026-10-25 22:46
Frage: Schont ein kleiner Anteil DITTO-Stuecke im Training (10 % statt 50 %, lambda 0,5, wechselnde Trenner) das Kopieren seltener Woerter und bricht trotzdem die Selbstverstaerkung bei Zeilenumbruch?
Kriterium (festgelegt 2026-10-25 20:08, vor dem ersten Messwert):
  Arm D10 (DITTO auf mix10_t.txt b440f875: 179 DITTO- und 1611 natuerliche Stuecke, 3,11 MB), gepaart mit C10 (MLE, gleiche Daten). 3 Saaten, je Saat 3/3 ja, 0/3 nein, sonst saatabhaengig. Messung auf saetze_frisch7.json b5f695e4 (Kandidaten 1450..1649). R = TP4/TP1.
- W: nl R_D10 <= 1,0 UND R_D10/R_M <= 0,9.
- S: Beleg A_D10 >= 0,9 A_M UND TP1 >= 0,9 TP1_M.
- E: U <= 1,1 U_M.
- K: Held-out <= +2 %.
- Knapp: Wiederholung auf Kandidaten 1650..1849.
Urteil: erfuellt = alle 3/3; teilweise = W und S 3/3; verfehlt = W oder S 0/3; sonst keine_aussage.
Berichtet: D10 gegen C10 und gegen DT.
Volltext rechner-a:~/snai_pruef/ditto2/kriterien_anteil_gegen.txt (mit Pruefer).
Plan: rechner-a:~/snai_pruef/ditto2/kriterien_anteil_gegen.txt
Baut auf: snai/ditto-lambda
Darauf baut: snai/ditto-selten, snai/ditto-einstieg
Rezepte:
  r422 [2026-10-25] cd ~/snai_pruef/ditto2 && for k in 1 2 3; do setsid nohup timeout 18000 bash ag.sh $k & done; setsid nohup timeout 10800 bash vorab_ag.sh &  (Arme D10/C10; danach Auswertung)
      quelltext: ag.sh 9ea2fa34, textmess7.sh 5769d821, beam12.sh f738a3d3, vorab_ag.sh df5fa545, mess6.sh 2d5e4b51, bau_ditto_anteil.py bbe7b22b (patch_bau2.py b81305c7 auf bau_ditto_trenner.py 0a9ca497), lib ditto/bau/libcortex_D.so e4bb3a0f, sonde_text.php 4ecc76bc, unscharf.py ff3999bd
      parameter: D10: SNAI_DITTO_LAMBDA=0.5 SNAI_DITTO_LOG=1, C10: SNAI_DITTO_AUS=1; daten/mix10_t.txt b440f875; 1 Epoche ab drohneP_s19, LR 1e-4, Warmup 500, WD 0,1, int8 voll gebunden, SR mv, GAIN_GUARD 0, OMP 3, ft.snai; Messung saetze_frisch7.json b5f695e4
      seed: SNAI_START_OFFSET 0 / 1000003 / 2000003, Ordner proj / proj_s2 / proj_s3
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/ditto2/{log/D10_s*.log, log/C10_s*.log, log/ag.log, log/textmess7.log, mess/{D10,C10}_s*, mess/t7_*, mess/b12_{D10,C10}_s*}
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ditto2/log/boot_ag.out (md5 20d64354), boot_ag.py; Text-Sonde saetze_frisch7 (1450..1649), nl n=198
  m5520 R nl (TP4/TP1) | 1.321 | D10 | s1 | 198
  m5521 R nl (TP4/TP1) | 1.274 | D10 | s2 | 198
  m5522 R nl (TP4/TP1) | 1.345 | D10 | s3 | 198
  m5523 R nl (TP4/TP1) | 1.506 | C10 | s1 | 198
  m5524 R nl (TP4/TP1) | 1.468 | C10 | s2 | 198
  m5525 R nl (TP4/TP1) | 1.379 | C10 | s3 | 198
  m5526 R nl (TP4/TP1) | 1.460 | M | s1 | 198
  m5527 R nl (TP4/TP1) | 1.407 | M | s2 | 198
  m5528 R nl (TP4/TP1) | 1.453 | M | s3 | 198
  m5529 R nl (TP4/TP1) | 0.338 | DT | s1 | 198
  m5530 R nl (TP4/TP1) | 0.180 | DT | s2 | 198
  m5531 R nl (TP4/TP1) | 0.199 | DT | s3 | 198
  m5532 R_D10/R_M nl [95%] | 0.905 [0.894-0.916] | D10 | s1 | 198
  m5533 R_D10/R_M nl [95%] | 0.906 [0.894-0.916] | D10 | s2 | 198
  m5534 R_D10/R_M nl [95%] | 0.926 [0.915-0.937] | D10 | s3 | 198
  m5535 TP1 nl /M | 0.94 | D10 | s1 | 198
  m5536 TP1 nl /M | 0.99 | D10 | s2 | 198
  m5537 TP1 nl /M | 0.81 | D10 | s3 | 198
  m5538 Beleg A /M | 0.98 | D10 | s1 | 120
  m5539 Beleg A /M | 1.00 | D10 | s2 | 120
  m5540 Beleg A /M | 0.83 | D10 | s3 | 120
  m5541 Beleg A /M | 1.07 | C10 | s1 | 120
  m5542 Beleg A /M | 1.08 | C10 | s2 | 120
  m5543 Beleg A /M | 1.09 | C10 | s3 | 120
  m5544 Beleg D10/C10 (DITTO-eigen) | 0.92 | D10 | s1 | 120
  m5545 Beleg D10/C10 (DITTO-eigen) | 0.93 | D10 | s2 | 120
  m5546 Beleg D10/C10 (DITTO-eigen) | 0.76 | D10 | s3 | 120
  m5547 U Beam12 /M | 0.84 | D10 | s1 | 12
  m5548 U Beam12 /M | 1.05 | D10 | s2 | 12
  m5549 U Beam12 /M | 1.14 | D10 | s3 | 12
  m5550 U Beam12 /M | 1.74 | C10 | s1 | 12
  m5551 U Beam12 /M | 1.56 | C10 | s2 | 12
  m5552 U Beam12 /M | 2.27 | C10 | s3 | 12
  m5553 Held-out H - M | +1.0 % | D10 | s1 | 200
  m5554 Held-out H - M | +0.4 % | D10 | s2 | 200
  m5555 Held-out H - M | +1.5 % | D10 | s3 | 200
  m5556 Held-out H - M | +0.5 % | C10 | s1 | 200
  m5557 Held-out H - M | +0.3 % | C10 | s2 | 200
  m5558 Held-out H - M | +0.6 % | C10 | s3 | 200
  m5559 DITTO-Fenster im Training | 255 | D10 | s1 | 1
  m5560 DITTO-Fenster im Training | 251 | D10 | s2 | 1
  m5561 DITTO-Fenster im Training | 252 | D10 | s3 | 1
  Quelle: rechner-a:~/snai_pruef/ditto2/log/boot_wdh8.out (md5 741f5040), Wiederholung auf saetze_frisch8 (1650..1849), nl n=192
  m5604 R nl Wiederholung frisch8 [95%] | 1.338 [1.316-1.361] | D10 | s1 | 192
  m5605 R nl Wiederholung frisch8 [95%] | 1.265 [1.248-1.284] | D10 | s2 | 192
  m5606 R nl Wiederholung frisch8 [95%] | 1.348 [1.327-1.371] | D10 | s3 | 192
  m5607 R_D10/R_M Wiederholung frisch8 | 0.925 | D10 | s1 | 192
  m5608 R_D10/R_M Wiederholung frisch8 | 0.905 | D10 | s2 | 192
  m5609 R_D10/R_M Wiederholung frisch8 | 0.928 | D10 | s3 | 192
  m5610 R nl Wiederholung frisch8 | 1.446 | M | s1 | 192
  m5611 R nl Wiederholung frisch8 | 1.397 | M | s2 | 192
  m5612 R nl Wiederholung frisch8 | 1.453 | M | s3 | 192
  m5613 R nl Wiederholung frisch8 | 0.360 | DT | s1 | 192
  m5614 R nl Wiederholung frisch8 | 0.196 | DT | s2 | 192
  m5615 R nl Wiederholung frisch8 | 0.234 | DT | s3 | 192
Ergebnis e369 [2026-10-25 22:46]: verfehlt
  Fazit: Ein kleiner Anteil DITTO-Stuecke (10 % statt 50 %) schont das Kopieren seltener Woerter fast (Beleg 0,83-1,00 von M, S 2/3; Held-out +0,4-1,5 %, K 3/3), bricht die Selbstverstaerkung aber nicht mehr (R nl 1,27-1,35, R/M 0,91-0,93; W 0/3, bestaetigt auf frisch8). Der Anteil verdünnt Wirkung und Schaden gemeinsam und verschiebt den Arm nur entlang derselben Tauschlinie wie lambda, AB und Gegengewicht (Vergleichstabelle aller 6 Arme in ERGEBNIS_anteil.md). Deutung, nicht gemessen: Der Schaden liegt in der Zielgroesse selbst (jedes Token, das L Positionen vorher stand, wird abgewertet), nicht in Dosis, Staerke, Ansatzstelle oder Datenumfeld. Naechster sinnvoller Test: seltene Token im DITTO-Fenster von der Strafe ausnehmen (normale CE). Ein Zwischenanteil liefert nur einen weiteren Punkt auf der Linie.
  Offen: Ob eine Ausnahme fuer seltene Token den Schaden isoliert; ob ein anderes Basismodell oder laengeres Training die Tauschlinie verschiebt.
  Datei: rechner-a:~/snai_pruef/ditto2/ERGEBNIS_anteil.md
Chronik:
  2026-10-25 20:08 angelegt
  2026-10-25 20:08 Rezept r422
  2026-10-25 20:08 Status geplant -> laeuft (Rezept r422)
  2026-10-25 22:42 Messwerte m5520-m5561
  2026-10-25 22:46 Messwerte m5604-m5615
  2026-10-25 22:46 Ergebnis e369: verfehlt
  2026-10-25 22:46 Status laeuft -> ausgewertet (Ergebnis e369)
```
