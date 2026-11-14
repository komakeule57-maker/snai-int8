# snai/kopier-drohne-p

```text
snai/kopier-drohne-p - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 11:23
Frage: Entsteht im Drohnen-Langlauf Arm P (prod128, Rezept wie prod512b, 1 Arbeiter) über die Segmente 3-7 Kopieren bei ungesättigter Attention?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21 (Kriterium, Maßstab docs/MASSSTAB_PROMPT_BINDUNG.md); Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  Kopieren belegt ab Beleg-Anteil A 10 % ODER Kopierrate 50 %; att_max_gewicht < 0,5 = hält (ungesättigt). Prompt-Bindung (Beam 3, Schlüssel in den ersten 120 Wörtern): >= 5 vorhanden, 2-4 teilweise, <= 1 nicht.
Baut auf: snai/kopier-drohne-e-s3, snai/kopier-prod512-beleg
Darauf baut: snai/drohne-arbeiter, snai/ditto-knirps
Rezepte:
  r35 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben)
      parameter: Drohne Arm P (prod128-Langlauf): 128/4/4, ctx 512, 8 Bit, gebunden, echter Text; Rezept wie prod512b (LR 0,0001, Warmup 500, Cosinus, WD 0,1), 1 Arbeiter, geplant 20 Segmente; Segmentdauer 335-346 min (s6/s7)
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/drohne/log_P/lauf.log; Doku 6aa
Messwerte (Groesse | Wert | Arm | Start | n):
  m285 Beleg-Anteil A s1/s2/s3/s4/s5/s6/s7 | 2,2 / 9,4 / 13,6 / 16,6 / 16,6 / 18,4 / 19,7 % | P
  m286 Kopierrate s2/s3/s4/s5/s6/s7 | 0,0027 / 0,026 / 0,035 / 0,031 / 0,037 / 0,059 | P
  m287 att_max_gewicht s3/s4/s5 | 0,29 / 0,309 / 0,322 | P
  m288 Held-out s0..s7 | 5,61 / 5,04 / 4,74 / 4,497 / 4,381 / 4,340 / 4,268 / 4,253 | P |  | 64
  m289 ICL-Gewinn s3 / s4 | 0,294 ± 0,046 / 0,312 ± 0,047 | P |  | 300
  m290 Gewinn aus Kontext > 32 Token s2 / s3 / s4 | +0,184 / +0,276 ± 0,025 / +0,297 ± 0,027 | P
  m291 Prompt-Bindung s5 / s6 / s7 | 0 / 0 / 2 von 10 | P |  | 10
  m292 Beleg-Anteil A / Kopierrate s3 zum Vergleich | 9,8 % / 0,0041 | E
Ergebnis e32 [2026-10-21 11:23]: erfuellt
  Fazit: Nach dem Wortlaut des Kriteriums ist Kopieren in Arm P ab Segment 3 (rund 82.000 Schritte) belegt, bei ungesättigter Attention: Beleg-Anteil A 13,6 % und danach steigend bis 19,7 %. Zweite Lesart, gleichrangig zu berichten: die Kopierrate liegt mit 2,6-5,9 % weit unter 50 % und nach der Schwelle der Kopier-Sonde sogar unter „nicht vorhanden“ (10 %); die beiden ODER-Kriterien widersprechen sich. Deutung laut Eintrag: das Modell nutzt passenden Kontext zunehmend für die Wahrscheinlichkeit, schreibt aber nicht ab. Prompt-Bindung erst s7 „teilweise“ (2/10). Folge: Beleg-Anteil allein reicht nicht als Kopiernachweis; spätere Messungen gingen auf Rang-0-Sonden (snai/kopier-prod512b-pos).
  Offen: Ein Lauf;: „Ein Lauf, ein Messpunkt: Beobachtung, kein Befund über ein Einsetzen des Kopierens.“ Segmentprüfung s6/s7 GELB (Kopierrate). Weitere Segmente nach s7 nicht eingetragen.
Chronik:
  2026-10-21 11:22 angelegt (Nachtrag: Nachgetragen 2026-10-21 (Kriterium, Maßstab docs/MASSSTAB_PROMPT_BINDUNG.md); Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:22 Rezept r35
  2026-10-21 11:22 Status geplant -> laeuft (Rezept r35)
  2026-10-21 11:22 Messwerte m285-m292
  2026-10-21 11:23 Ergebnis e32: erfuellt
  2026-10-21 11:23 Status laeuft -> ausgewertet (Ergebnis e32)
```
