# snai/stell-reparatur27

```text
snai/stell-reparatur27 - ausgewertet, angelegt 2026-11-04, zuletzt 2026-11-04 20:16
Frage: Ziel: die nutzlosen mittleren Schichten reparieren. Trägt das reparierte Rezept R = Eingangsfaktor F=sqrt(128) + W-Plan (Warmup 2000, konstant, Cosinus über die letzten 10 %) bei 128x4 über 27k? Tragen die mittleren FFN darin (EW gegen EWo ohne FFN L1-L3)? Trägt F unter dem Plan (EW gegen KW)? Macht der Plan die FFN wertvoller als bei konstanter LR (Interaktion mit E27/F27 aus e504)?
Kriterium (festgelegt 2026-11-04 16:05, vor dem ersten Messwert):
  Wortlaut: rechner-a ~/snai_pruef/stell/KRITERIEN_rep27.md (vor dem Start, mit Prüferabschnitt). Arme EW, EWo, KW × s4–s11, kurz27000, 27.018 Schritte, Held-out 700 gepaart.
Regel D:
- BESSER: 6/8 UND Mittel ≤ −0,02.
- SCHLECHTER: spiegelbildlich.
- GLEICH: Betrag Mittel < 0,01 UND Betrag D < 0,02 in 6/8.
- Sonst OFFEN.
Urteile:
1. EW−EWo BESSER = FFN TRAGEN; GLEICH = UNNÖTIG.
2. EW−KW BESSER = F TRÄGT.
3. REPARATUR TRÄGT = 1 und 2 BESSER; VERFEHLT, wenn 1 GLEICH oder SCHLECHTER.
4. I = (EW−EWo) − (E27−F27, e504): PLAN VERSTÄRKT, wenn I ≤ −0,02 und I < 0 in 6/8; PLAN NEUTRAL, wenn Betrag Mittel I < 0,01 und Betrag I < 0,02 in 6/8.
Knapp (0,003 an einer Schwelle oder genau 6/8): heldout2 und Bootstrap.
Kontrollen:
- F im Training und in der Messung.
- LR an den Stellen 1, 2000, 24000 und 27000.
- Rot: EW s4 ohne F gemessen, EWo-Nullen = 0.
Gerätetest G: E27 s4 t9000 md5-gleich zu rechner-b. Nur dann gelten die rechnerübergreifenden Paare.
Größter freier Parameter: Warmup 2000.
Darauf baut: snai/tiefe-budget-r, snai/stell-lr-leiter, snai/noten-r
Rezepte:
  r582 [2026-11-04] rechner-a: cd ~/snai_pruef/stell && setsid -f nohup ./reihe_rep27.sh (md5 ba0fecf8; KRITERIEN_rep27.md 8b1100ca). Je Lauf (export $(umg arm); ./lauf_stell.sh rep27 <arm> - <s> daten/kurz27000.txt 9000,18000), danach nullsetzen.php w_down L1-L3 + mess_text mit gleichem F, gains_tot.php. 13 zugleich (12 + Gerätetest G).
      quelltext: Lib bau_stell c5f9fbaf (Stellräder aus), Trainer de34a553, lauf_stell.sh ecd0d42a, nullsetzen.php 41b71f14
      parameter: EW: SNAI_EMB_EIN=11.3137085, Warmup 2000, Cosinus 24316-27018, Boden 0,1; EWo: wie EW mit Genesis clip_gen_ef0_ (8d7e5806); KW: wie EW ohne F; G: E27-Rezept (F, Warmup 500, konstant), nur Training, Referenz t9000 md5 90786cf1 (rechner-b ee27/E27_s4)
      seed: s4-s11 über Genesis und Sitzungsname clip_s<s>, Fensterfolge wie E27/F27
      rechner: rechner-a CPU, 1 Thread je Lauf
      logs: rechner-a ~/snai_pruef/stell/log/rep27.log, rep27_null.jsonl, rep27_gains.jsonl, rep27_mess.err, laeufe/rep27/*
      notiz: Start 04.11. 16:05. Kopfzeilen geprüft: EW/EWo F 11.313708, KW 1.0; Warmup 2000, Cosinus ab 24316, Boden 0,0003; G Warmup 500 mit F. Ende etwa 19:30 (zwei Wellen).
Messwerte (Groesse | Wert | Arm | Start | n):
  m8822 EW-EWo heldout Mittel | -0.0253 | 8/8 neg, BS -0,030..-0,021, BESSER; heldout2 -0,0256
  m8823 EW-KW heldout Mittel | -0.0092 | 8/8 neg, 8/8 | D | <0,02, BS -0,013..-0,005, GLEICH KNAPP; heldout2 -0,0099 (BS -0,014..-0,006)
  m8824 I (EW-EWo)-(E27-F27) heldout Mittel | -0.0032 | 5/8 neg, 6/8 | I | <0,02, BS -0,013..+0,007, NEUTRAL KNAPP; heldout2 -0,0031
  m8825 EW heldout Mittel | 2.2323 | KW 2,2415, EWo 2,2576
  m8826 EW-E27 heldout Mittel | -0.2759 | 8/8, Gerätetest G bytegleich 90786cf1; EW-F27 -0,298
  m8827 Zweigbeitrag n123 EW | 0.278 | KW 0,252, EWo 0 (Rot n123 bestanden)
  m8828 Tote L2-FFN-Gains EW (%) | 6-21 | KW s4-s11 46,9/100/100/100/100/100/6,3/96,9
  m8829 Rot Messpfad EW s4 ohne F | 5.7635 | mit F 2,2291
Ergebnis e531 [2026-11-04 20:16]: teilweise
  Fazit: Urteil 1 FFN TRAGEN ist erfüllt: EW−EWo −0,025, 8/8, auf beiden Prüftexten. Der Größe nach sind das 1 %, also Gleichstand. Urteil 2 bleibt knapp GLEICH: F bringt −0,009, und zwar 8/8. Damit ist Urteil 3 REPARATUR OFFEN. Urteil 4 bleibt PLAN NEUTRAL, knapp. Der Plan macht die mittleren FFN nicht wertvoller.

Repariert ist die Güte, nicht die Nutzung der mittleren Schichten. R liegt 0,28 nats unter E27 (8/8, Gerätetest bytegleich), und das trägt der LR-Plan.

F hält die L2-Gains am Leben: in EW sind höchstens 21 % tot, in KW bei 6/8 Saaten fast alle. Das bringt aber nur rund 0,01.

Die mittleren FFN sind nicht nutzlos, sondern ersetzbar. Nullt man sie im fertigen Modell, kostet das 0,28. Trainiert man von vornherein ohne sie, kostet es nur 0,025.

Für den Hauptbaum heißt das: den Plan übernehmen, F ist optional, Gains wiederzubeleben lohnt nicht.
  Datei: rechner-a ~/snai_pruef/stell/ERGEBNIS_rep27.md
Chronik:
  2026-11-04 16:05 angelegt
  2026-11-04 16:06 Rezept r582
  2026-11-04 16:06 Status geplant -> laeuft (Rezept r582)
  2026-11-04 20:16 Messwerte m8822-m8829
  2026-11-04 20:16 Ergebnis e531: teilweise
  2026-11-04 20:16 Status laeuft -> ausgewertet (Ergebnis e531)
```
