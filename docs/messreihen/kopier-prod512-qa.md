# snai/kopier-prod512-qa

```text
snai/kopier-prod512-qa - ausgewertet, begonnen 2026-10-09, angelegt 2026-10-21, zuletzt 2026-10-21 11:20
Frage: Entsteht bei prod512 s19 durch Feinabstimmung auf Beleg-QA (Adapter Rang 8 bzw. alle Gewichte frei) Kopieren oder ein QA-Treffer?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  QA-Sonde sftb, 240 Prüffragen aus 120 ungesehenen Dokumenten; Treffer = alle Antwort-Token Rang 0; Lesen = Loss fremder Beleg minus passender; Frage = Loss vertauschte Frage minus passend; Kopier-Sonde: Kopierrate Zufallsfolge, ab 50 % vorhanden; unter 10 % = Gleichstand.
Baut auf: snai/kopier-prod512-s19
Rezepte:
  r19 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben)
      parameter: Basis prod512 s19 (512/6/8, ctx 1024, int8). Arme: Adapter Rang 8 und Voll-Feinabstimmung (alle Gewichte frei); Korpus corpus_qa_beleg.txt (1084 Fenster, 1,11 M Token), LR 0,0002, 3 Epochen; Neuron-Revival 324 von 27.648 je Epochengrenze
Messwerte (Groesse | Wert | Arm | Start | n):
  m173 QA-Treffer | 0/240 | Basis s19, Adapter e1-e3, Voll e1-e3 |  | 240
  m174 Kopierrate Zufallsfolge | 0,0 % | Basis s19 und Voll e1-e3, mit und ohne Lücke
  m175 Lesen (fremd minus passend) e1/e2/e3 | +0,279 / +0,290 / +0,296 (Basis +0,279) | Adapter
  m176 Lesen (fremd minus passend) e1/e2/e3 | +0,310 / +0,369 / +0,375 | Voll
  m177 Frage (vertauscht minus passend) e1/e2/e3 | +0,131 / +0,174 / +0,179 (Basis +0,060) | Voll
  m178 Held-out gepaart 64 Fenster | 4,851 gegen 3,845 (-1,006 nats, t -24,6) | Voll e3 gegen Basis |  | 64
  m179 Held-out gepaart 64 Fenster | 4,944 gegen 3,845 (-1,10 nats, t -19,9) | Adapter gegen Basis |  | 64
Ergebnis e17 [2026-10-21 11:20]: verfehlt
  Fazit: Der Engpass ist nicht der Adapter: auch mit allen Gewichten frei entsteht weder Kopieren (Kopierrate 0,0 %) noch ein QA-Treffer (0/240); die Voll-Feinabstimmung lernt auswendig (Trainingsloss fällt, Prüfloss steigt). s19 ist als Basis für LoRA+RAG unbrauchbar; ein Neustart mit anderem Rezept ist nötig statt weiterer Feinabstimmung. Erklärung laut Eintrag: gesättigte Attention, Q/K bekommen kein gerichtetes Lernsignal (snai/kopier-prod512-attention).
  Offen: Ob ein ungesättigtes Basismodell mit demselben QA-Korpus kopieren würde, ist hier nicht gemessen.
Chronik:
  2026-10-21 11:19 angelegt (Nachtrag: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:19 Rezept r19
  2026-10-21 11:19 Status geplant -> laeuft (Rezept r19)
  2026-10-21 11:19 Messwerte m173-m179
  2026-10-21 11:20 Ergebnis e17: verfehlt
  2026-10-21 11:20 Status laeuft -> ausgewertet (Ergebnis e17)
```
