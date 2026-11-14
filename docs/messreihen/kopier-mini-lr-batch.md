# snai/kopier-mini-lr-batch

```text
snai/kopier-mini-lr-batch - ausgewertet, begonnen 2026-10-09, angelegt 2026-10-21, zuletzt 2026-10-21 11:20
Frage: Lernt das Mini-Modell (128/2/4, ctx 64, gebunden) die Aufgabe `var` mit kleinerer Lernrate oder größerem Batch, im PyTorch-Nachbau und im echten INT8-Kern? Scheiterte es am Ein-Fenster-Betrieb oder an der LR?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  Gelernt = Rang 0 auf der zweiten Kopie >= 90 % auf frischen Fenstern, nicht gelernt < 10 %; Rot-Probe = erste Kopie fremd.
Baut auf: snai/kopier-mini-var
Darauf baut: snai/kopier-mini-lr-reihe, snai/kopier-knirps-fenster-je-schritt, snai-evo/pytorch-gegenprobe
Rezepte:
  r23 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben; PyTorch-Nachbau referenz_batch.py, echter Trainer lauf.sh/train_cluster)
      parameter: Aufgabe `var`, 128/2/4, ctx 64, gebunden. PyTorch-Nachbau, ein Stellrad Batch: B1 LR 0,0000625 (Saat 1, 2), B1 0,0003, B16 0,001, B1 0,001. Echter INT8-Trainer, 1 Arbeiter, alte Bibliothek 1cfb54f4 ohne ATTFIX: LR 0,0000625 (einzige Änderung gegen den Vorlauf: LR)
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/lernversuch/
Messwerte (Groesse | Wert | Arm | Start | n):
  m194 Fenster bis R0 >= 90 % | 24.000 (97,7 %) | PyTorch B1 LR 0,0000625 | 1
  m195 Fenster bis R0 >= 90 % | 32.000 (94,6 %) | PyTorch B1 LR 0,0000625 | 2
  m196 Fenster bis R0 >= 90 % | 32.000 (94,4 %) | PyTorch B1 LR 0,0003 | 1
  m197 Fenster bis R0 >= 90 % | 280.000 (= 17.500 Schritte) | PyTorch B16 LR 0,001 | 1
  m198 R0 bis 192.000 Fenster | 13,7-16,1 % flach, nicht gelernt (abgebrochen) | PyTorch B1 LR 0,001 | 1
  m199 R0 Verlauf 5.000 ... 40.000 Fenster | 1,4 / 5,9 / 8,7 / 10,3 / 12,8 / 17,8 / 56,5 / 95,8 % | INT8-Kern LR 0,0000625
  m200 Rot-Probe | 0,2-0,5 % | alle gelernten Arme
Ergebnis e21 [2026-10-21 11:20]: erfuellt
  Fazit: Die Induktion scheiterte nicht am Ein-Fenster-Betrieb, sondern an der LR 0,001: mit kleiner LR lernen PyTorch-Nachbau und echter INT8-Kern `var` in derselben Größenordnung (40.000 gegen 24.000-32.000 Fenster; ein Lauf, Unterschied nicht bewertbar). Ein großer Batch rettet 0,001 nur teuer (Batch 16 braucht das 9- bis 12-Fache an Material); gleiches LR/Batch-Verhältnis gibt nicht dasselbe Ergebnis. Der Lernsprung ist ein Phasenübergang. Folge laut Eintrag: Gradienten-Sammeln im Kern wird nicht gebaut; Attention-Sättigung bei prod512 und dieser Versuch zeigen auf dieselbe Ursache, LR 0,001.
  Offen: Echter Kern bei 0,0003, Wirkung von Warmup, WD und ATTFIX (folgt in snai/kopier-mini-lr-reihe); Übertragung auf prod512 mit echtem Text, wo Kopieren nur ein kleiner Teil des Lernsignals ist. Je Arm meist eine Saat.
Chronik:
  2026-10-21 11:19 angelegt (Nachtrag: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:19 Rezept r23
  2026-10-21 11:19 Status geplant -> laeuft (Rezept r23)
  2026-10-21 11:19 Messwerte m194-m200
  2026-10-21 11:20 Ergebnis e21: erfuellt
  2026-10-21 11:20 Status laeuft -> ausgewertet (Ergebnis e21)
```
