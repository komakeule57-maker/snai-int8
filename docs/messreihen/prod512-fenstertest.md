# snai/prod512-fenstertest

```text
snai/prod512-fenstertest - ausgewertet, begonnen 2026-09-28, angelegt 2026-10-21, zuletzt 2026-10-21 19:29
Frage: Bestimmt der Inhalt des trainierten Segments, welche der 64 Held-out-Fenster von prod512 gewinnen (Gewinn je Fenster gegen relative Nähe des Fensters zum neuen gegenüber dem alten Segment)?
Kriterium (nachgetragen, Beleg: Kriterium nur im Ergebniseintrag als ‚vorab‘ bezeichnet, nicht unabhängig belegt. Kriterium (2026-09-28 14:56), dort als 'vorab' bezeichnet.):
  Fenstertexte aus dem echten eval_held_out_full_i8.php (Kopie, eine Stelle mit assert gepatcht). Gewinn je Fenster aus window_losses; relative Nähe P_w = CE(Fenster|pseg_alt) - CE(Fenster|pseg_neu) (Wort-Unigramm, Laplace, gemeinsames V), Segmente in Server-Fassung. Gestützt bei Spearman >= 0,25 primär (s13->s14) und gleichem Vorzeichen in der Wiederholung (s12->s13); nicht gestützt bei |rho| < 0,10. Gegenversuch: spezifisch, wenn die Mehrheit der untrainierten Platzhalter-Segmente rho <= 0,33 hat.
Baut auf: snai/prod512-segmentnaehe
Darauf baut: snai/prod512-heldout-verteilt
Rezepte:
  r186 [2026-10-21] php <Kopie von eval_held_out_full_i8.php mit Textausgabe nach $windows++> … factory/holdout_prod/ auto 64; Rest k. A.
      quelltext: Kopie nicht erhalten; Original rechner-a:~/Projekte/snai_edge_int8_lora/eval_held_out_full_i8.php
      parameter: 64 Fenster à 1024 Token, Offset 0..64512; Platzhalter-Segmente pseg20/25/30/35; Glättung add-1, Gegenprobe add-0,1
      seed: Permutationstest, Saat k. A.
      rechner: rechner-a
      logs: k. A.
Messwerte (Groesse | Wert | Arm | Start | n):
 , nicht nachgerechnet
  m2286 Spearman rho primär s13->s14 | +0,666 (p < 1e-4) | add-1 |  | 64
  m2287 Spearman rho Wiederholung s12->s13 | +0,606 | add-1 |  | 64
  m2288 rho s13->s14 / s12->s13 | 0,634 / 0,549 | add-0,1 |  | 64
  m2289 rho gegen Fensterschwierigkeit | -0,09 / +0,07 | Kontrolle |  | 64
  m2290 rho Platzhalter s12->s13 (pseg20/25/30/35) | 0,04 / 0,25 / 0,29 / 0,03 | Gegenversuch |  | 64
  m2291 rho Platzhalter s13->s14 (pseg20/25/30/35) | 0,42 / 0,46 / 0,32 / 0,49 | Gegenversuch |  | 64
Ergebnis e174 [2026-10-21 19:29]: erfuellt
  Fazit: Ja: welche Fenster gewinnen, hängt am Segmentinhalt (rho 0,67, Wiederholung 0,61). Der Gegenversuch trennt die beiden Schritte: s12->s13 ist spezifisch, s13->s14 zu etwa zwei Dritteln unspezifisch, also Vergessen in s13 und Zurückholen in s14. Daraus folgt der wichtigere Schluss: die ersten 64 von 632 Fenstern sind wenige Artikel, Segmentgewinne hängen am Themenzufall dieses Ausschnitts, und die SE 0,0061 unterschätzt die echte Streuung. Das führte direkt zur verteilten Reihe (snai/prod512-heldout-verteilt).
  Offen: Skript und Kopie nicht erhalten; nur zwei Segmentschritte.
Chronik:
  2026-10-21 19:29 angelegt (Nachtrag: Kriterium nur im Ergebniseintrag als ‚vorab‘ bezeichnet, nicht unabhängig belegt. Kriterium (2026-09-28 14:56), dort als 'vorab' bezeichnet.)
  2026-10-21 19:29 Rezept r186
  2026-10-21 19:29 Status geplant -> laeuft (Rezept r186)
  2026-10-21 19:29 Messwerte m2286-m2291
  2026-10-21 19:29 Ergebnis e174: erfuellt
  2026-10-21 19:29 Status laeuft -> ausgewertet (Ergebnis e174)
```
