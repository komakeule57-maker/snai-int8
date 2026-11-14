# snai/prod512-segmentnaehe

```text
snai/prod512-segmentnaehe - ausgewertet, begonnen 2026-09-28, angelegt 2026-10-21, zuletzt 2026-10-21 19:29
Frage: Erklärt die Nähe des trainierten Segments zum Prüfsatz (Wort-Unigramm) das Zickzack der Segmentgewinne von prod512 auf Ebene ganzer Segmente?
Kriterium (nachgetragen, Beleg: Kriterium nur im Ergebniseintrag als ‚vorab‘ bezeichnet, nicht unabhängig belegt. Kriterium (2026-09-28 14:37), dort als 'vorab' bezeichnet; die Vermutung stammt vom selben Tag.):
  Zielgröße trendbereinigter Gewinn d_s = (L(s-1)-L(s)) - (f(s-1)-f(s)) mit Fit s1..s14 (2,6706 + 2,2576*s^-0,2235), s2..s14, n=13. Kennzahl: Kreuzentropie der Wortverteilung von ho_prod.txt unter Laplace-geglättetem Unigramm des Segments (\w+, Groß/klein erhalten). Spearman: gestützt bei rho <= -0,56, nicht gestützt bei |rho| < 0,30.
Baut auf: snai/prod512-klumpung-s14
Darauf baut: snai/prod512-fenstertest
Rezepte:
  r185 [2026-10-21] k. A. (Skript nicht erhalten); Permutationstest 200.000 Züge
      quelltext: k. A.
      parameter: Segmente s2..s14, s9..s14 in der Server-Fassung (md5 gegen vserver geprüft); Glättung add-1, Gegenprobe add-0,1
      seed: Permutationssaat k. A.
      rechner: rechner-a
      logs: k. A.
Messwerte (Groesse | Wert | Arm | Start | n):
 , nicht nachgerechnet (Skript und Zwischendaten nicht gefunden)
  m2281 Spearman rho (d_s gegen Kreuzentropie) | -0,08 (p 0,79) | add-1 |  | 13
  m2282 Spearman rho | -0,18 | add-0,1 |  | 13
  m2283 Pearson r | -0,42 (getragen von s5) | add-1 |  | 13
  m2284 Spanne der Kreuzentropie | 9,061 bis 9,094 | Segmente |  | 13
  m2285 rho Kreuzentropie gegen Segmentnummer | -0,70 | Segmente |  | 13
Ergebnis e173 [2026-10-21 19:29]: verfehlt
  Fazit: Auf Segmentebene erklärt die Nähe zum Prüfsatz das Zickzack nicht (rho -0,08). Das Instrument hatte aber kaum Spielraum: die Kreuzentropie streut zwischen den Segmenten nur um 0,4 %. Die Frage war damit nicht erledigt, sondern auf die falsche Ebene gestellt; die Fensterebene (snai/prod512-fenstertest) fand den Zusammenhang.
  Offen: Rechenweg nicht erhalten.
Chronik:
  2026-10-21 19:29 angelegt (Nachtrag: Kriterium nur im Ergebniseintrag als ‚vorab‘ bezeichnet, nicht unabhängig belegt. Kriterium (2026-09-28 14:37), dort als 'vorab' bezeichnet; die Vermutung stammt vom selben Tag.)
  2026-10-21 19:29 Rezept r185
  2026-10-21 19:29 Status geplant -> laeuft (Rezept r185)
  2026-10-21 19:29 Messwerte m2281-m2285
  2026-10-21 19:29 Ergebnis e173: verfehlt
  2026-10-21 19:29 Status laeuft -> ausgewertet (Ergebnis e173)
```
