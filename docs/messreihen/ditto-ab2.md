# snai/ditto-ab2

```text
snai/ditto-ab2 - ausgewertet, angelegt 2026-10-25, zuletzt 2026-10-25 10:03
Frage: Haelt DITTO (lambda 0,5, Training mit wechselnden Trennern) die Wirkung bei Zeilenumbruch, wenn die erste Wiederholung normale CE behaelt und der DITTO-Verlust erst ab Kopie 2 greift (SNAI_DITTO_AB=2)? Schont das TP1, das Kopieren seltener Woerter (Beleg) und die Erzeugung?
Kriterium (festgelegt 2026-10-25 08:33, vor dem ersten Messwert):
  Arm DA = DT-Rezept (snai/ditto-trenner) + SNAI_DITTO_AB=2. Gepaart gegen DT, Vergleich mit M. 3 Saaten, je Saat: 3/3 ja, 0/3 nein, sonst saatabhaengig.

Messung auf frischen Saetzen saetze_frisch5.json (ad0693b4, Kandidaten 850..1049). R = TP4/TP1, TP1 = erste Wiederholung.
- A1 (entscheidet), Sonde nl: R_DA <= 1,0 UND R_DA/R_M <= 0,9.
- A2 (entscheidet): Beleg A_DA >= 0,9 A_M UND TP1_DA(nl) >= 0,9 TP1_M.
- A3 (entscheidet mit): Beam 3 an 12 Prompts, unscharf.py K=2, U_DA <= 1,1 U_M.
- K: Held-out H_DA - H_M <= 2 % = tragbar.
- Knapp (Bootstrap-Intervall schliesst die Schwelle ein): Wiederholung auf Kandidaten 1050..1249. U wird nicht wiederholt.

Urteil:
- erfuellt = A1, A2, A3 je 3/3 und K 3/3.
- teilweise = A1 und A2 3/3, A3 oder K nicht.
- verfehlt = A1 0/3 oder A2 0/3.
- sonst keine_aussage.

Berichtet: TP4_DA/TP4_M, pipe/nl2/leer, DA gegen DT.
Volltext rechner-a:~/snai_pruef/ditto2/kriterien_ab2.txt 6e106830 (mit Rot-Probe und Pruefer).
Plan: rechner-a:~/snai_pruef/ditto2/kriterien_ab2.txt
Baut auf: snai/ditto-trenner
Darauf baut: snai/ditto-lambda, snai/ditto-selten
Rezepte:
  r416 [2026-10-25] cd ~/snai_pruef/ditto2 && for k in 1 2 3; do setsid nohup timeout 7200 bash ab2.sh $k & done; setsid nohup timeout 14400 bash vorab_ab2.sh &  (danach python3 boot_ab2.py)
      quelltext: ab2.sh 74aa8fda, textmess5.sh 80ad1e65, beam12.sh 54cf99dd, vorab_ab2.sh 3dedcb7d, mess6.sh 2d5e4b51, sonde_text.php 4ecc76bc, unscharf.py ff3999bd, lib bau/libcortex_AB.so f8d4eaf1 (cortex_ab.nim 8cbbbd82 = patch_ab.py 65e35f90 auf ditto/cortex_ditto.nim 0706e513), Rot-Probe probe_ab.sh e6b20a0e
      parameter: DA: SNAI_DITTO_LAMBDA=0.5 SNAI_DITTO_AB=2, daten/mix_t.txt 81ea3be0, 1 Epoche ab drohneP_s19 170d4d3f, LR 1e-4, Warmup 500, WD 0,1, int8 voll gebunden, SR mv, GAIN_GUARD 0, OMP 3, Ausgabename ft.snai; Messung saetze_frisch5.json ad0693b4 (200), Beam 3 an 12 Prompts
      seed: SNAI_START_OFFSET 0 / 1000003 / 2000003 (Saat 1/2/3), Ordner proj / proj_s2 / proj_s3, Laufname ft.snai
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/ditto2/{log/DA_s*.log, log/ab2.log, log/textmess5.log, mess/DA_s*, mess/t5_*, mess/b12_*, arme/DA_s*.snai}
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ditto2/boot_ab2.py 678acffb (Ausgabe log/boot_ab2.out ed2bc7b2); Text-Sonde sonde_text.php 4ecc76bc auf saetze_frisch5.json ad0693b4; Beam 12 Prompts unscharf.py ff3999bd K=2; R = TP4/TP1
  m5359 R nl | 1,429 | M | 1 | 188
  m5360 R nl | 1,373 | M | 2 | 188
  m5361 R nl | 1,421 | M | 3 | 188
  m5362 R nl | 1,292 | CT | 1 | 188
  m5363 R nl | 1,270 | CT | 2 | 188
  m5364 R nl | 1,253 | CT | 3 | 188
  m5365 R nl | 0,344 | DT | 1 | 188
  m5366 R nl | 0,184 | DT | 2 | 188
  m5367 R nl | 0,204 | DT | 3 | 188
  m5368 R nl [95 %] | 0,315 [0,293-0,337] | DA | 1 | 188
  m5369 R nl [95 %] | 0,287 [0,263-0,313] | DA | 2 | 188
  m5370 R nl [95 %] | 0,386 [0,360-0,413] | DA | 3 | 188
  m5371 R_DA/R_M nl [95 %] | 0,220 [0,204-0,236] | DA | 1 | 188
  m5372 R_DA/R_M nl [95 %] | 0,209 [0,192-0,227] | DA | 2 | 188
  m5373 R_DA/R_M nl [95 %] | 0,272 [0,254-0,291] | DA | 3 | 188
  m5374 TP1 nl | 0,289 | M | 1 | 188
  m5375 TP1 nl | 0,292 | M | 2 | 188
  m5376 TP1 nl | 0,293 | M | 3 | 188
  m5377 TP1 nl | 0,374 | DA | 1 | 188
  m5378 TP1 nl | 0,399 | DA | 2 | 188
  m5379 TP1 nl | 0,392 | DA | 3 | 188
  m5380 TP4_DA/TP4_M nl | 0,29 | DA | 1 | 188
  m5381 TP4_DA/TP4_M nl | 0,29 | DA | 2 | 188
  m5382 TP4_DA/TP4_M nl | 0,36 | DA | 3 | 188
  m5383 R pipe | 1,379 | M | 1 | 200
  m5384 R pipe | 1,310 | M | 2 | 200
  m5385 R pipe | 1,360 | M | 3 | 200
  m5386 R pipe | 1,177 | DT | 1 | 200
  m5387 R pipe | 1,013 | DT | 2 | 200
  m5388 R pipe | 1,121 | DT | 3 | 200
  m5389 R pipe [95 %] | 0,987 [0,964-1,012] | DA | 1 | 200
  m5390 R pipe [95 %] | 0,887 [0,862-0,912] | DA | 2 | 200
  m5391 R pipe [95 %] | 0,967 [0,941-0,994] | DA | 3 | 200
  m5392 R leer | 1,136 | DT | 1 | 200
  m5393 R leer | 0,985 | DT | 2 | 200
  m5394 R leer | 1,103 | DT | 3 | 200
  m5395 R leer | 0,968 | DA | 1 | 200
  m5396 R leer | 0,889 | DA | 2 | 200
  m5397 R leer | 0,955 | DA | 3 | 200
  m5398 R nl2 | 0,312 | DA | 1 | 188
  m5399 R nl2 | 0,267 | DA | 2 | 188
  m5400 R nl2 | 0,387 | DA | 3 | 188
  m5401 Beleg-Anteil A | 0,130 | DA | 1 | 120
  m5402 Beleg-Anteil A | 0,134 | DA | 2 | 120
  m5403 Beleg-Anteil A | 0,140 | DA | 3 | 120
  m5404 Beleg A_DA/A_M | 0,72 | DA | 1 | 120
  m5405 Beleg A_DA/A_M | 0,72 | DA | 2 | 120
  m5406 Beleg A_DA/A_M | 0,71 | DA | 3 | 120
  m5407 U Beam 12 Prompts | 0,394 | M | 1 | 12
  m5408 U Beam 12 Prompts | 0,433 | M | 2 | 12
  m5409 U Beam 12 Prompts | 0,302 | M | 3 | 12
  m5410 U Beam 12 Prompts | 0,724 | CT | 1 | 12
  m5411 U Beam 12 Prompts | 0,731 | CT | 2 | 12
  m5412 U Beam 12 Prompts | 0,732 | CT | 3 | 12
  m5413 U Beam 12 Prompts | 0,319 | DT | 1 | 12
  m5414 U Beam 12 Prompts | 0,242 | DT | 2 | 12
  m5415 U Beam 12 Prompts | 0,356 | DT | 3 | 12
  m5416 U Beam 12 Prompts | 0,485 | DA | 1 | 12
  m5417 U Beam 12 Prompts | 0,421 | DA | 2 | 12
  m5418 U Beam 12 Prompts | 0,535 | DA | 3 | 12
  m5419 Held-out 200 Fenster | 4,477 | DA | 1 | 200
  m5420 Held-out 200 Fenster | 4,519 | DA | 2 | 200
  m5421 Held-out 200 Fenster | 4,483 | DA | 3 | 200
  m5422 Held-out H_DA-H_M | +5,5 % | DA | 1 | 200
  m5423 Held-out H_DA-H_M | +6,3 % | DA | 2 | 200
  m5424 Held-out H_DA-H_M | +5,8 % | DA | 3 | 200
Ergebnis e365 [2026-10-25 10:03]: verfehlt
  Fazit: Den DITTO-Verlust erst ab Kopie 2 anzusetzen, schont nicht, was zaehlt (A2 0/3, also verfehlt).

Die Wirkung bleibt und wird breiter:
- nl R_DA 0,29-0,39 (A1 3/3), TP4 absolut 0,29-0,36 von M.
- Neu wirkt es auch auf den ungesehenen Trenner pipe (R 0,89-0,99, 3/3, Saat 1 knapp; DT 0/3).

Die Kosten bleiben:
- Beleg 0,71-0,72 von M, trotz TP1 1,29-1,37 von M.
- Held-out +5,5-6,3 %, gegen DT Gleichstand.
- Die Erzeugung wird in 2/3 Saaten wiederholungsreicher als M (U 1,23/0,97/1,77) und liegt 1,5-1,7x ueber DT.

Widerlegt ist die Deutung, der Beleg-Einbruch komme vom Druecken der ersten Wiederholung. Er entsteht im DITTO-Verlust auf den spaeteren Kopien.

Nebenbefund, gleichgerichtet in 3/3:
- MLE auf den Wiederholungsdaten (CT) verdoppelt U fast (0,72-0,73 gegen M 0,30-0,43).
- DT (ab Kopie 1) bringt U auf M-Niveau.

Uebrig bleibt als Hebel die Staerke der Strafe: eine lambda-Leiter (0,5/0,75/1) auf diesem Aufbau.
Findet sich dort kein Punkt mit fallender Kurve UND Beleg >= 0,9, ist DITTO hier ein Tausch "weniger Schleifen gegen weniger nuetzliches Kopieren".
  Offen: - lambda-Leiter mit Trennern: Wo liegt die Grenze zwischen Wirkung und Beleg-Kosten?
- Anteil der DITTO-Stuecke als zweite Dosis.
- U streut je Prompt 0,10-0,74; A3 ist mit 12 Prompts nur grob.
- prod512b ungemessen.
  Datei: rechner-a:~/snai_pruef/ditto2/ERGEBNIS_ab2.md
Chronik:
  2026-10-25 08:33 angelegt
  2026-10-25 08:34 Rezept r416
  2026-10-25 08:34 Status geplant -> laeuft (Rezept r416)
  2026-10-25 10:03 Messwerte m5359-m5424
  2026-10-25 10:03 Ergebnis e365: verfehlt
  2026-10-25 10:03 Status laeuft -> ausgewertet (Ergebnis e365)
```
