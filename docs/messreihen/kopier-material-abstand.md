# snai/kopier-material-abstand

```text
snai/kopier-material-abstand - ausgewertet, begonnen 2026-10-20, angelegt 2026-10-21, zuletzt 2026-10-21 11:28
Frage: Ist das Trainingsmaterial von prod512b an weiten Kopiergelegenheiten dünn (nützliche Wiederholungen je Abstandsband K 65-128, L 257-384, LL 641-960)?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  pseg00-03 mit dem echten Tokenizer (f020d0ca) und snai_window_offsets (ctx 1024); je Zielposition das jüngste frühere gleiche n-Gramm im Fenster, „nützlich“ = Folgetoken stimmt; Dichte je möglicher Stelle in den Bändern; Q = f(Band)/f(K). Q_LL <= 0,2 = MATERIAL DUENN, >= 0,5 = TRAEGT; n=8 Hauptlesart, n=4 muss übereinstimmen.
Plan: rechner-a:~/snai_pruef/reichweite/kriterien.txt
Baut auf: snai/kopier-prod512b-pos
Darauf baut: snai/kopier-prod512b-koepfe
Rezepte:
  r47 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben)
      parameter: Material pseg00-03 (tg1-md5), echter Tokenizer f020d0ca, snai_window_offsets (ctx 1024); n-Gramm n=8 (Hauptlesart) und n=4; Bänder K 65-128, L 257-384, LL 641-960
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/reichweite
Messwerte (Groesse | Wert | Arm | Start | n):
  m396 Q_L | 0,21-0,31 | n=8, pseg00-03 |  | 4
  m397 Q_LL | 0,07-0,16 | n=8, pseg00-03 |  | 4
  m398 Nützliche Treffer je Fenster | 0,2-0,5 im Band LL gegen 1,8-2,5 im Band K | n=8
  m399 Anteil nützlicher an allen Treffern K / L / LL | 0,78 / 0,76 / 0,84 | n=8
  m400 Urteil n=4 | einig mit n=8 (MATERIAL DUENN) | n=4 |  | 4
Ergebnis e44 [2026-10-21 11:28]: erfuellt
  Fazit: MATERIAL DÜNN, einig über n=4/n=8 und alle 4 Segmente: weite Kopiergelegenheiten sind im prod512b-Material rund zehnmal seltener als nahe, aber genauso verlässlich (Zusatz ohne Urteil). Deutung, nicht gemessen: das passt zum Abstandsabfall der Kopierreichweite und stützt den Material-Hebel, unterscheidet ihn aber nicht von einer Architekturgrenze. Daraus folgt der Eingriff mit gezielt dichtem Weit-Material (snai/reichweite-v3, v4).
  Offen: Ob mehr weite Wiederholungen die Reichweite tatsächlich verlängern, beantworten erst die Eingriffsreihen.
Chronik:
  2026-10-21 11:27 angelegt (Nachtrag: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:27 Rezept r47
  2026-10-21 11:27 Status geplant -> laeuft (Rezept r47)
  2026-10-21 11:27 Messwerte m396-m400
  2026-10-21 11:28 Ergebnis e44: erfuellt
  2026-10-21 11:28 Status laeuft -> ausgewertet (Ergebnis e44)
```
