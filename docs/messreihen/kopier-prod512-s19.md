# snai/kopier-prod512-s19

```text
snai/kopier-prod512-s19 - ausgewertet, begonnen 2026-10-08, angelegt 2026-10-21, zuletzt 2026-10-21 11:18
Frage: Kopiert der alte Produktionslauf prod512 nach Segment 19 aus dem Kontext (Kopier-Sonde: zweimal dieselbe 96-Token-Spanne)?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  Kopier-Sonde, 80 Posten aus ho_prod: 96-Token-Spanne steht zweimal hintereinander, gemessen nur die zweite Kopie; Kontrolle = gleich langer fremder Text davor (gleiche Position); zusätzlich mit 224 fremden Token Abstand; einmal echter Text, einmal Zufallsfolge aus 96 verschiedenen Token. Kopierrate = Anteil Rang 0 in der Wiederholung der Zufallsfolge ab Position 8; >= 50 % vorhanden, < 10 % nicht vorhanden.
Darauf baut: snai/kopier-prod512-attention, snai/kopier-prod512-qa, snai/kopier-mini-induktion, snai/kopier-prod512-beleg
Rezepte:
  r18 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben)
      parameter: Modell prod512_s19: 512/6/8, ctx 1024, ~27 M Parameter, int8 (Ganzzahl-Stack); Training LR 0,001 konstant, kein Warmup, kein WD (laut Übersicht), 20 Segmente. Sonde: 80 Posten aus ho_prod, Spanne 96 Token, Abstand 0 bzw. 224 fremde Token
      rechner: Laptop
Messwerte (Groesse | Wert | Arm | Start | n):
  m159 Kopierrate Zufallsfolge (KR) | 0,0 % | ohne und mit 224 Token Abstand |  | 80
  m160 Loss Zufallsfolge wieder gegen fremd | 14,50 gegen 14,54 (+0,043 nats, t 3,1) | Zufallsfolge |  | 80
  m161 Loss fremd minus wieder, echter Text | +0,160 nats = 3,9 % des fremden Loss 4,10 (t 12,5) | echter Text |  | 80
  m162 Rang 0 echter Text wieder gegen fremd | 28,6 % gegen 27,2 % | echter Text |  | 80
  m163 Loss fremd minus wieder, seltene Token (Rang >= 200) | +0,251 | echter Text |  | 80
  m164 Loss fremd minus wieder mit 224 Token Abstand | +0,016 (0,4 %) | echter Text |  | 80
Ergebnis e15 [2026-10-21 11:18]: verfehlt
  Fazit: Nach 20 Segmenten hat prod512 keinen Kopier- oder Induktionsmechanismus (Kopierrate 0,0 %, klar unter der 10-%-Schwelle). Deutung laut Eintrag: der kleine Gewinn im echten Text ist Themennähe, kein Abschreiben. Das erklärt, warum der Beleg-Adapter Rang 8 nichts bewegte; „späteres Segment abwarten“ ist keine begründete Hoffnung. Folgefragen: warum nicht (snai/kopier-prod512-attention) und ob Feinabstimmung es erzeugt (snai/kopier-prod512-qa).
  Offen: Die Sonde hatte zu diesem Zeitpunkt noch kein kopierendes Modell gesehen (keine Positivkontrolle am echten Modell; nur Rot-Proben der Verdrahtung und Selbsttest des Auswerters). Positivkontrolle folgte am Mini-Modell (snai/kopier-mini-induktion). Ob das Modell Kopieren lernen kann, beantwortet diese Messung nicht.
Chronik:
  2026-10-21 11:18 angelegt (Nachtrag: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:18 Rezept r18
  2026-10-21 11:18 Status geplant -> laeuft (Rezept r18)
  2026-10-21 11:18 Messwerte m159-m164
  2026-10-21 11:18 Ergebnis e15: verfehlt
  2026-10-21 11:18 Status laeuft -> ausgewertet (Ergebnis e15)
```
