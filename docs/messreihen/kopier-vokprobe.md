# snai/kopier-vokprobe

```text
snai/kopier-vokprobe - ausgewertet, begonnen 2026-10-10, angelegt 2026-10-21, zuletzt 2026-10-21 11:21
Frage: prod512-Fork, Minilauf mit neuem Vokabular und gesundem Rezept: bleibt die Ampel (Attention, Kopierrate) an jedem Stand grün, und ist Held-out je Zeichen gleichauf mit dem alten Vokabular?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  Ampel an jedem Stand grün; Held-out in Nats je ZEICHEN = Loss je Token x Token/Zeichen (neu 0,2658, alt 0,2885), unter 10 % = Gleichstand. Loss je Token ist zwischen zwei Vokabularen nicht vergleichbar.
Baut auf: snai/kopier-mini-lr-reihe
Darauf baut: snai/kopier-prod512b-s0
Rezepte:
  r27 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben; Startskript run_prod512b_server.sh nur probeweise)
      parameter: prod512-Fork (512/6/8, ctx 1024), neues Vokabular f020d0ca, bereinigte Eingabestücke und Prüfsatz, dieselbe Genesis wie bisher; Rezept Arm „neu“: LR 0,0001, Warmup 100, Cosinus bis 400, WD 0,1; 112+111+219 = 442 Schritte; ein Seed
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/vokprobe
Messwerte (Groesse | Wert | Arm | Start | n):
  m212 Kopierrate (Ampel, mit richtigem Vokabular nachgemessen) | 0 | alle neun Stände
  m213 Größtes Attention-Gewicht | 0,007 -> 0,036 | neues Vokabular
  m214 Logit-Streuung | 0,28 -> 0,63 | neues Vokabular
  m215 Held-out je Zeichen, drei Stände | 2,071 / 2,054 / 2,032 | neues Vokabular
  m216 Held-out je Zeichen, drei Stände | 2,105 / 2,055 / 2,010 | altes Vokabular
  m217 Abstand neu gegen alt | -1,6 % / -0,1 % / +1,1 % | neu gegen alt
Ergebnis e24 [2026-10-21 11:21]: gleichstand
  Fazit: Das neue Vokabular ist je Zeichen gleichauf mit dem alten (unter 10 %), und die Ampel bleibt an allen neun Ständen grün; der Neustart kann es verwenden. Für das Kopieren sagt der Minilauf nichts: Kopierrate 0 nach 442 Schritten ist in dieser Länge erwartbar und nur eine Ampel-Kennzahl.
  Offen: Eichhinweis grad_vo: der gesunde Arm streift bei Schritt 200 die Gelb-Schwelle 0,20. Ein Seed.
Chronik:
  2026-10-21 11:20 angelegt (Nachtrag: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:20 Rezept r27
  2026-10-21 11:20 Status geplant -> laeuft (Rezept r27)
  2026-10-21 11:20 Messwerte m212-m217
  2026-10-21 11:21 Ergebnis e24: gleichstand
  2026-10-21 11:21 Status laeuft -> ausgewertet (Ergebnis e24)
```
