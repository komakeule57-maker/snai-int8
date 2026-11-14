# snai/ditto-lambda

```text
snai/ditto-lambda - ausgewertet, angelegt 2026-10-25, zuletzt 2026-10-25 19:49
Frage: Gibt es ein lambda in [0,5; 1], bei dem DITTO (ab Kopie 1, Training mit wechselnden Trennern) die Selbstverstaerkung bei Zeilenumbruch bricht UND das Kopieren seltener Woerter erhaelt, oder ist es im geprueften Bereich ein Tausch?
Kriterium (festgelegt 2026-10-25 18:12, vor dem ersten Messwert):
  Arme L75 (lambda 0,75) und L10 (lambda 1,0) = DT-Rezept (snai/ditto-trenner) mit anderem lambda, je Saat gepaart gegen DT (lambda 0,5).
3 Saaten, je Saat: 3/3 ja, 0/3 nein, sonst saatabhaengig. Messung auf saetze_frisch6.json (87f8c6b8, Kandidaten 1050..1249). R = TP4/TP1.

Je Arm X:
- W: nl R_X <= 1,0 UND R_X/R_M <= 0,9.
- S: Beleg A_X >= 0,9 A_M UND TP1_X >= 0,9 TP1_M.
- E: U_X <= 1,1 U_M (Beam 3, 12 Prompts).
- K: Held-out <= +2 %.
- Knapp bei R: Wiederholung auf Kandidaten 1250..1449.

Urteil:
- erfuellt = ein Arm W, S, E, K je 3/3.
- teilweise = ein Arm W und S 3/3.
- verfehlt = jeder Arm W 0/3 oder S 0/3 (mit DT: Tausch im Bereich 0,5-1).
- sonst keine_aussage.

Volltext rechner-a:~/snai_pruef/ditto2/kriterien_lambda.txt 961c222f (mit Pruefer).
Plan: rechner-a:~/snai_pruef/ditto2/kriterien_lambda.txt
Baut auf: snai/ditto-ab2
Darauf baut: snai/ditto-anteil, snai/ditto-gegen, snai/ditto-selten
Rezepte:
  r419 [2026-10-25] cd ~/snai_pruef/ditto2 && for k in 1 2 3; do setsid nohup timeout 10800 bash lam.sh $k & done; setsid nohup timeout 10800 bash vorab_lambda.sh &  (danach python3 boot_lambda.py)
      quelltext: lam.sh 2044a3f0, textmess6.sh 528ca512, beam12.sh f738a3d3 (gegen ditto-ab2 nur die Logdatei der FERTIG-Zeile geaendert), vorab_lambda.sh fc50155f, mess6.sh 2d5e4b51, sonde_text.php 4ecc76bc, unscharf.py ff3999bd, lib ditto/bau/libcortex_D.so e4bb3a0f
      parameter: L75: SNAI_DITTO_LAMBDA=0.75, L10: SNAI_DITTO_LAMBDA=1.0; sonst wie DT: daten/mix_t.txt 81ea3be0, 1 Epoche ab drohneP_s19, LR 1e-4, Warmup 500, WD 0,1, int8 voll gebunden, SR mv, GAIN_GUARD 0, OMP 3, Ausgabename ft.snai; Messung saetze_frisch6.json 87f8c6b8 (200), Beam 3 an 12 Prompts
      seed: SNAI_START_OFFSET 0 / 1000003 / 2000003, Ordner proj / proj_s2 / proj_s3, Laufname ft.snai
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/ditto2/{log/L75_s*.log, log/L10_s*.log, log/lambda.log, log/textmess6.log, mess/L75_s*, mess/L10_s*, mess/t6_*, mess/b12_L*, arme/L75_s*, arme/L10_s*}
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ditto2/boot_lambda.py 9ca613a5 (Ausgabe log/boot_lambda.out ad761276); Text-Sonde 4ecc76bc auf saetze_frisch6.json 87f8c6b8; Beam 12 Prompts unscharf.py K=2; R = TP4/TP1
  m5463 R nl | 1,466 | M | 1 | 192
  m5464 R nl | 1,404 | M | 2 | 192
  m5465 R nl | 1,446 | M | 3 | 192
  m5466 R nl | 0,359 | DT | 1 | 192
  m5467 R nl | 0,201 | DT | 2 | 192
  m5468 R nl | 0,231 | DT | 3 | 192
  m5469 R nl [95 %] | 0,505 [0,478-0,533] | L75 | 1 | 192
  m5470 R nl [95 %] | 0,425 [0,401-0,452] | L75 | 2 | 192
  m5471 R nl [95 %] | 0,575 [0,544-0,606] | L75 | 3 | 192
  m5472 R nl [95 %] | 1,194 [1,180-1,209] | L10 | 1 | 192
  m5473 R nl [95 %] | 1,158 [1,143-1,174] | L10 | 2 | 192
  m5474 R nl [95 %] | 1,180 [1,162-1,199] | L10 | 3 | 192
  m5475 R_X/R_M nl | 0,345 | L75 | 1 | 192
  m5476 R_X/R_M nl | 0,303 | L75 | 2 | 192
  m5477 R_X/R_M nl | 0,398 | L75 | 3 | 192
  m5478 R_X/R_M nl | 0,815 | L10 | 1 | 192
  m5479 R_X/R_M nl | 0,825 | L10 | 2 | 192
  m5480 R_X/R_M nl | 0,817 | L10 | 3 | 192
  m5481 TP1_X/TP1_M nl | 0,55 | DT | 1 | 192
  m5482 TP1_X/TP1_M nl | 0,50 | DT | 2 | 192
  m5483 TP1_X/TP1_M nl | 0,51 | DT | 3 | 192
  m5484 TP1_X/TP1_M nl | 0,54 | L75 | 1 | 192
  m5485 TP1_X/TP1_M nl | 0,52 | L75 | 2 | 192
  m5486 TP1_X/TP1_M nl | 0,50 | L75 | 3 | 192
  m5487 TP1_X/TP1_M nl | 0,71 | L10 | 1 | 192
  m5488 TP1_X/TP1_M nl | 0,56 | L10 | 2 | 192
  m5489 TP1_X/TP1_M nl | 0,51 | L10 | 3 | 192
  m5490 Beleg-Anteil A | 0,132 | L75 | 1 | 120
  m5491 Beleg-Anteil A | 0,120 | L75 | 2 | 120
  m5492 Beleg-Anteil A | 0,113 | L75 | 3 | 120
  m5493 Beleg-Anteil A | 0,173 | L10 | 1 | 120
  m5494 Beleg-Anteil A | 0,130 | L10 | 2 | 120
  m5495 Beleg-Anteil A | 0,124 | L10 | 3 | 120
  m5496 Beleg A_X/A_M | 0,73 | L75 | 1 | 120
  m5497 Beleg A_X/A_M | 0,64 | L75 | 2 | 120
  m5498 Beleg A_X/A_M | 0,57 | L75 | 3 | 120
  m5499 Beleg A_X/A_M | 0,95 | L10 | 1 | 120
  m5500 Beleg A_X/A_M | 0,70 | L10 | 2 | 120
  m5501 Beleg A_X/A_M | 0,63 | L10 | 3 | 120
  m5502 U Beam 12 Prompts | 0,293 | L75 | 1 | 12
  m5503 U Beam 12 Prompts | 0,376 | L75 | 2 | 12
  m5504 U Beam 12 Prompts | 0,286 | L75 | 3 | 12
  m5505 U Beam 12 Prompts | 0,425 | L10 | 1 | 12
  m5506 U Beam 12 Prompts | 0,338 | L10 | 2 | 12
  m5507 U Beam 12 Prompts | 0,395 | L10 | 3 | 12
  m5508 Held-out 200 Fenster | 4,503 | L75 | 1 | 200
  m5509 Held-out 200 Fenster | 4,548 | L75 | 2 | 200
  m5510 Held-out 200 Fenster | 4,497 | L75 | 3 | 200
  m5511 Held-out 200 Fenster | 4,357 | L10 | 1 | 200
  m5512 Held-out 200 Fenster | 4,452 | L10 | 2 | 200
  m5513 Held-out 200 Fenster | 4,433 | L10 | 3 | 200
  m5514 R pipe | 1,162 | L75 | 1 | 200
  m5515 R pipe | 1,045 | L75 | 2 | 200
  m5516 R pipe | 1,117 | L75 | 3 | 200
  m5517 R pipe | 1,251 | L10 | 1 | 200
  m5518 R pipe | 1,218 | L10 | 2 | 200
  m5519 R pipe | 1,289 | L10 | 3 | 200
Ergebnis e368 [2026-10-25 19:49]: verfehlt
  Fazit: Die Strafstaerke lambda ist kein Schonhebel. In keinem lambda zwischen 0,5 und 1 bleibt das Kopieren seltener Woerter erhalten: S 0/3 in jedem Arm.

- L75 (lambda 0,75) wirkt fast wie DT (R 0,43-0,58) und kostet ebenso viel: Beleg 0,57-0,73 von M, TP1 0,50-0,54, Held-out +6-7 %.
- L10 (lambda 1) wirkt nicht mehr (R 1,16-1,19, W 0/3) und kostet immer noch: Beleg 0,63-0,95, TP1 0,51-0,71, Held-out +2,7-4,7 %.
- Nach Vorab-Regel heisst das "Tausch". Genauer wird die Schonung im ganzen Bereich nirgends erreicht.

Damit sind die Stellraeder des DITTO-Verlusts selbst geprueft, Ansatzstelle (ditto-ab2), Staerke und Trennerform. Jede Einstellung, die die Selbstverstaerkung bricht, kostet 30-45 % Beleg und rund 6 % Held-out.

Was bleibt:
- DITTO bricht die Satzschleife in den trainierten Formen (DT auf frisch6 bestaetigt, W 3/3).
- Es haelt die Beam-Wiederholung auf M-Niveau, waehrend MLE auf denselben Daten sie fast verdoppelt.

Ungeprueft ist der Anteil der DITTO-Stuecke (hier 50 %). Ein Gegengewicht im Training waere eine Vermutung.
Im Einsatz bleibt die Kopiersperre beim Erzeugen der wirksame Weg.
  Offen: - Anteil der DITTO-Stuecke (10/25 %).
- Gegengewicht: CE-Stuecke mit legitimem Wiederaufgreifen seltener Woerter.
- Deutung "Kopie-1-Ziel lambda*P(Kopie 0) ist immer klein" nicht isoliert.
- prod512b ungemessen.
  Datei: rechner-a:~/snai_pruef/ditto2/ERGEBNIS_lambda.md
Chronik:
  2026-10-25 18:12 angelegt
  2026-10-25 18:13 Rezept r419
  2026-10-25 18:13 Status geplant -> laeuft (Rezept r419)
  2026-10-25 19:49 Messwerte m5463-m5519
  2026-10-25 19:49 Ergebnis e368: verfehlt
  2026-10-25 19:49 Status laeuft -> ausgewertet (Ergebnis e368)
```
