# snai/ee512-kopierbias

```text
snai/ee512-kopierbias - ausgewertet, angelegt 2026-11-03, zuletzt 2026-11-03 10:29
Frage: Erklärt der Kopier-Bias über das gebundene Embedding (eigenes Token mit Logit g·d·RMS(E_t), sobald F·E das Residual dominiert) den Startverlust 12,43 mit EE bei d=512 (snai_multi_stack e495)?
Kriterium (nachgetragen, Beleg: Kriterium stand vorher in rechner-a:~/snai_pruef/gradnorm/kriterien_ee512_bias.txt (2026-11-03 10:45, vor dem Rechnen); Messbuch-Eintrag nach der Rechnung.):
  L_pred = ln((V-1)+exp(g·E_t·E_t/RMS(E_t))), gemittelt über die Tokens, aus Genesis gen_d512h8L2_s1 (V5, embeddings, rms_final), V aus zeichen.json. TRAEGT: innerhalb 10 % von 12,43. WIDERLEGT: mehr als 25 % daneben. Sonst OFFEN. Gegenrichtung: L_pred muss deutlich über dem Wert ohne EE (5,75) liegen, sonst trennt die Formel die Arme nicht. Reichweite: eine Genesis, eine Saat, Step 1; Größenordnung, kein Mechanismusbeweis.
Plan: rechner-a:~/snai_pruef/gradnorm/kriterien_ee512_bias.txt
Darauf baut: snai/multistack-ee-512
Ergebnis e496 [2026-11-03 10:29]: erfuellt
  Fazit: TRAEGT: L_pred 13,06 gegen gemessen 12,43 (+5,1 %). Genesis: RMS(E) 0,02551, g_final 1,0 überall, V 256, eigenes Logit 12,3 bis 13,9 (Mittel 13,06). Gegenrichtung erfüllt: ohne EE 5,75 (ln V 5,55), dort dominiert x0 nicht. Folge: Nicht der Faktor F selbst verursacht den Startschaden, sondern dass F·E das Residual beherrscht und der gebundene Ausgang dann das eigene Token mit g·d·RMS(E) bevorzugt. Das wächst linear mit d bei gleicher Init-Streuung; bei d=128 und gleicher Streuung wären es rund 3,3 statt 13. EE darf deshalb nicht unverändert auf d=512-Genesen übertragen werden; die Init-Streuung des Embeddings oder die Final-Gain müsste mit 1/d mitskaliert werden (Deutung, nicht gemessen).
  Offen: Ob sich der Bias über ein Segment erholt (bei Schritt 40 ist die LR wegen Warmup 500 erst bei 8 %), ob der Schaden bleibt, und ob eine mitskalierte Init den EE-Nutzen bei d=512 erhält. Mechanismus nicht direkt ausgelesen (Logit des eigenen Tokens im Vorwärtslauf).
  Datei: rechner-a:~/snai_pruef/gradnorm/kriterien_ee512_bias.txt
Chronik:
  2026-11-03 10:29 angelegt (Nachtrag: Kriterium stand vorher in rechner-a:~/snai_pruef/gradnorm/kriterien_ee512_bias.txt (2026-11-03 10:45, vor dem Rechnen); Messbuch-Eintrag nach der Rechnung.)
  2026-11-03 10:29 Ergebnis e496: erfuellt
  2026-11-03 10:29 Status geplant -> ausgewertet (Ergebnis e496)
```
