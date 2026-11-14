# snai/kopier-mini-lr-reihe

```text
snai/kopier-mini-lr-reihe - ausgewertet, begonnen 2026-10-10, angelegt 2026-10-21, zuletzt 2026-10-21 11:21
Frage: Wo liegt im echten INT8-Kern die Grenze der tragfähigen Lernrate für inhaltsbasiertes Kopieren (`var`, 128/2/4, ctx 64, gebunden), und ändern Warmup, WD und ATTFIX etwas?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  Gelernt = Rang 0 auf der zweiten Kopie >= 90 % auf frischen Fenstern, nicht gelernt < 10 %; Rot-Probe = erste Kopie fremd.
Baut auf: snai/kopier-mini-lr-batch
Darauf baut: snai/kopier-mini-worker, snai/kopier-vokprobe, snai/kopier-drohne-k-e, snai/kopier-prod512b-s0, snai/kopier-knirps-leiter
Rezepte:
  r25 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben; Folgearm prod512: kette.sh E 0.0001 500 0.1)
      parameter: Aufgabe `var`, 128/2/4, ctx 64, gebunden, INT8-Kern, 1 Arbeiter, 1 Fenster je Schritt, gleiche Segmentdateien und Genesis in allen Armen. Arme: LR 0,001 ohne Zusätze (alte Lib); 0,0003 ohne Zusätze (alte Lib); 0,0003 Rezept C (ATTFIX-Lib 613ee, Warmup 500, WD 0,1); 0,0001 Rezept (ATTFIX, Warmup 500, WD 0,1); 0,0001 ohne Zusätze (alte Lib); 0,0000625 ohne Zusätze. Konstante Rate, Messung je 5.000 Fenster, bis 60.000
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/lernversuch
Messwerte (Groesse | Wert | Arm | Start | n):
  m201 R0 zweite Kopie | 20,1 % nach 30.000 | LR 0,001 ohne Zusätze
  m202 R0 je 5.000 Fenster bis 60.000 | 11/15/20/20/19/17/17/16/18/18/18/18 % | LR 0,0003 ohne Zusätze
  m203 R0 je 5.000 Fenster bis 60.000 | 9/12/12/13/15/16/57/64/66/67/68/67 % | LR 0,0003 Rezept C (ATTFIX, Warmup 500, WD 0,1)
  m204 R0 je 5.000 Fenster | 3/8/11/14/58/95,8 % (gelernt nach 30.000, Rot 0,4 %) | LR 0,0001 Rezept (ATTFIX, Warmup 500, WD 0,1)
  m205 R0 je 5.000 Fenster | 5/9/11/16/78/95,5 % (gelernt nach 30.000, Rot 0,3 %) | LR 0,0001 ohne Zusätze
  m206 R0 zweite Kopie | 95,8 % nach 40.000 (Rot 0,5 %) | LR 0,0000625 ohne Zusätze
Ergebnis e22 [2026-10-21 11:21]: erfuellt
  Fazit: Im Kern liegt die tragfähige LR für `var` bei 128/2/4 zwischen 0,0001 und 0,0003; 0,0001 lernt am schnellsten (30.000 Fenster) und ist gleichauf mit dem PyTorch-Nachbau, der Kern verträgt also weniger LR als der Nachbau. Warmup + WD + ATTFIX machen bei 0,0001 keinen Unterschied, bei 0,0003 heben sie von 18 % auf 67 %, retten es aber nicht. Folge laut Eintrag: Empfehlung für den prod512-Neustart von 0,0003 auf 0,0001 gesenkt (mit Warmup 500, WD 0,1); die Faustregel lr ~ 1/sqrt(dim) ist am Mini-Modell nicht bestätigt.
  Offen: Zweite Saat im Kern; welcher der drei Zusätze bei 0,0003 die Verbesserung bringt; Übertragung auf prod512 mit echtem Text. Je ein Lauf je Arm.
Chronik:
  2026-10-21 11:20 angelegt (Nachtrag: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:20 Rezept r25
  2026-10-21 11:20 Status geplant -> laeuft (Rezept r25)
  2026-10-21 11:20 Messwerte m201-m206
  2026-10-21 11:21 Ergebnis e22: erfuellt
  2026-10-21 11:21 Status laeuft -> ausgewertet (Ergebnis e22)
```
