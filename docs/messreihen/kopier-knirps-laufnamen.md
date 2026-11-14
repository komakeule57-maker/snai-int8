# snai/kopier-knirps-laufnamen

```text
snai/kopier-knirps-laufnamen - ausgewertet, begonnen 2026-10-13, angelegt 2026-10-21, zuletzt 2026-10-21 11:27
Frage: Kann allein die Fensterreihenfolge (Laufname) das Lernen der Kopieraufgabe `var` blockieren, und wie oft (Zelle 32/2/16, 30 Läufe)?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt (Prüfer Gemini/Mistral vor dem Start)):
  Gelernt = Rang 0 zweite Kopie >= 90 % (200 Fenster) im Budget; blockiert = Höchstwert < 10 % in 120.000 Fenstern. Vorab-Lesart für 1-2/30: Blockade kommt vor, Größenordnung einige Prozent, kein weiterer Schluss.
Plan: rechner-a:~/snai_pruef/knirps/laufnamen/kriterium.txt
Baut auf: snai/kopier-knirps-gitter
Rezepte:
  r42 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben; Läufe rn_d32h2_s<S>_r01..10)
      parameter: Zelle 32/2/16, 2 Schichten, ctx 64, wort256, `var`, LR 0,001, Warmup 500, WD 0,1, 24 x 5000 Fenster, Revival aus; drei Genesis-Dateien gitter_gen_d32h2_s{1,2,3} je unter 10 neuen Laufnamen = 30 Läufe. Einziges Stellrad = Laufname (wirkt nur auf Durchmischung train_worker.php:687; SNAI_START_OFFSET=0 fest; Revival-Saat aus)
      seed: Genesis 1, 2, 3 x Laufnamen r01..r10
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/knirps/laufnamen/
Messwerte (Groesse | Wert | Arm | Start | n):
  m348 gelernt | 29 von 30 | alle |  | 30
  m349 blockiert (Höchstwert < 10 %) | 1 von 30 (s2_r02, Höchstwert 2,2 %), exaktes 95-%-Intervall 0,08..17,2 % | alle |  | 30
  m350 blockiert je Genesis | 0/10, 1/10, 0/10 | Genesis 1 / 2 / 3 |  | 30
  m351 Fenster bis gelernt | 10.000-15.000 bei 28 Läufen; s2_r06 erst nach 50.000 | alle |  | 30
  m352 R0 nach Segment 0 der blockierten/verspäteten | 0,3 % und 0,6 % (alle 28 anderen >= 3,2 %) | s2_r02, s2_r06
  m353 Rot-Proben der gelernten | höchstens 0,4 % | alle gelernten |  | 29
Ergebnis e39 [2026-10-21 11:27]: erfuellt
  Fazit: Ja, allein die Fensterreihenfolge kann das Lernen blockieren, aber selten: 1 von 30 (Größenordnung einige Prozent, Intervall bis 17 %), dazu ein stark verspäteter Lauf. Für Versuchsreihen folgt: ein einzelner blockierter Lauf ist kein Zellenbefund, deshalb mindestens drei Saaten je Zelle. Beobachtung ohne Eingriff: genau die beiden Läufe mit Rang 0 <= 1 % nach Segment 0 blockieren bzw. verspäten sich; ein Frühwarnzeichen, keine belegte Ursache.
  Offen: Ob der Frühwert die Blockade verursacht oder nur anzeigt; Blockade-Rate in anderen Zellen und Rezepten. Reichweite: eine Zelle, ein Rezept.
Chronik:
  2026-10-21 11:26 angelegt (Nachtrag: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt (Prüfer Gemini/Mistral vor dem Start))
  2026-10-21 11:26 Rezept r42
  2026-10-21 11:26 Status geplant -> laeuft (Rezept r42)
  2026-10-21 11:26 Messwerte m348-m353
  2026-10-21 11:27 Ergebnis e39: erfuellt
  2026-10-21 11:27 Status laeuft -> ausgewertet (Ergebnis e39)
```
