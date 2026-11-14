# snai/revival-erkennung

```text
snai/revival-erkennung - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 19:29
Frage: Erkennt der alte Neuron-Revival-Erkenner tote Zeilen zuverlässig: im Mittel < 0,05 Fehlalarme je Modell an frischer Initialisierung (A) und tote Zeilen (f <= 0,05) zu >= 95 % erkannt UND lebendige (f >= 0,5) zu <= 5 % markiert (B)?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus rechner-a ~/snai_pruef/revival_pruef/erkennung_test.php.):
  Vorab im Kopf von revival_pruef/erkennung_test.php: A Fehlalarm an frischer Initialisierung, zuverlässig = im Mittel < 0,05 Fehlalarme je Modell. B an trainiertem Modell, zuverlässig = f <= 0,05 zu >= 95 % erkannt UND f >= 0,5 zu <= 5 % markiert.
Plan: A an frischen Initialisierungen (Drohne, prod512), B mit gepflanzten Zeilen (pflanzen.php).
Darauf baut: snai/revival-reparatur
Rezepte:
  r179 [2026-10-21] php revival_pruef/erkennung_test.php
      quelltext: Revival-Erkenner vor der Reparatur
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/revival_pruef/log/
Messwerte (Groesse | Wert | Arm | Start | n):
  m2233 Fehlalarme je Modell | 1,7 | Drohne |  | 1
  m2234 Fehlalarme je Modell | 10,8 | prod512 |  | 1
  m2235 lebendige Zeilen f=0,5 markiert | 90 % | trainiertes Modell |  | 1
Ergebnis e168 [2026-10-21 19:29]: verfehlt
  Fazit: Der alte Erkenner ist unbrauchbar: er schlägt an frischen Modellen 1,7- bis 10,8-mal Alarm, wo höchstens 0,05 erlaubt sind, und hält 90 % der halb-normigen, lebendigen Zeilen für tot. Was das alte Revival in Läufen 'wiederbelebt' hat, waren also überwiegend gesunde Zeilen. Das trug die Reparatur (snai/revival-reparatur).
  Offen: Erkennungsrate der wirklich toten Zeilen (erster Teil von B) nicht übernommen.
  Datei: rechner-a:~/snai_pruef/revival_pruef/erkennung_test.php
Chronik:
  2026-10-21 19:28 angelegt (Nachtrag: Nachtrag 2026-10-21 aus rechner-a ~/snai_pruef/revival_pruef/erkennung_test.php.)
  2026-10-21 19:28 Rezept r179
  2026-10-21 19:28 Status geplant -> laeuft (Rezept r179)
  2026-10-21 19:28 Messwerte m2233-m2235
  2026-10-21 19:29 Ergebnis e168: verfehlt
  2026-10-21 19:29 Status laeuft -> ausgewertet (Ergebnis e168)
```
