# snai/kopier-knirps-gitter

```text
snai/kopier-knirps-gitter - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 11:25
Frage: Knirps-Gitter ohne Revival, Breite 16/32 x Köpfe 1-16 (Kopfbreite 2-32), 3 Saaten je Zelle: welche Zellen lernen `var`, und gibt es eine Kopfbreiten-Schwelle zwischen 4 und 8?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt; Zellen- und Schwellenregel aus der Plan-Datei (Kopf: „Kriterien VOR dem ersten Lauf“), die der Eintrag nicht nennt, am 2026-10-21 nachgelesen):
  Laut Eintrag: gelernt >= 90 % Rang 0 zweite Kopie, Plateau = Höchstwert 50..90 %, nicht = < 10 % am Ende. Protokoll 1 = LR 0,001 bis 120.000 Fenster; Protokoll 2 (Zweiphasen) = ab 60.000 mit LR 0,0001 weitere 60.000. Laut Plan-Datei (nicht im Eintrag): Zelle „kopiert“, wenn mindestens 2 von 3 Saaten GELERNT oder PLATEAU erreichen; die Aussage „Kopfbreiten-Schwelle zwischen 4 und 8, unabhängig von Breite und Kopfzahl“ HÄLT, wenn alle Zellen mit Kopfbreite >= 8 kopieren und keine mit <= 4; WIDERLEGT, sobald eine Zelle mit <= 4 kopiert oder eine mit >= 8 nicht; uneinige Saaten = „saatabhängig“.
Plan: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt (Abschnitt GITTER NACH AUDIT)
Baut auf: snai/kopier-knirps-leiter, snai/kopier-revival
Darauf baut: snai/kopier-knirps-lr-breite, snai/kopier-knirps-kb4-lang, snai/kopier-knirps-laufnamen, snai/kopier-knirps-fenster-je-schritt, snai/knirps-plateau-fortsetzung, snai/knirps-plateau-saaten, snai/knirps-plateau-tausch, snai/floatpaar
Rezepte:
  r39 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben; Arme n_d<B>h<K>_s<S>)
      parameter: wort256, `var`, 2 Schichten, ctx 64, gebunden, Ganzzahl-Stack, Warmup 500, WD 0,1, Revival aus; Zellen 16/1/16, 16/2/8, 16/4/4, 32/1/32, 32/2/16, 32/4/8, 32/8/4, 32/16/2; 3 Genesis-Saaten je Zelle. Protokoll 1: LR 0,001 bis 120.000 Fenster; Protokoll 2: ab 60.000 mit LR 0,0001 weitere 60.000
      seed: Genesis-Saat 1, 2, 3 je Zelle
      rechner: rechner-a
Messwerte (Groesse | Wert | Arm | Start | n):
  m317 gelernt | 3/3 (20-25 Tsd. Fenster) | 16/1/16 |  | 3
  m319 R0 P1 / P2 Ende | <= 6,5 % / 5-9 % | 16/4/4 |  | 3
  m320 gelernt | 3/3 (10-15 Tsd.) | 32/1/32 |  | 3
  m321 gelernt | 3/3 (10-15 Tsd.) | 32/2/16 |  | 3
  m322 gelernt | 3/3 (20-25 Tsd.) | 32/4/8 |  | 3
  m323 R0 P1 / P2 Ende | <= 8,7 % / 11 / 12 / 18,8 % (langsam steigend) | 32/8/4 |  | 3
  m324 R0 P1 / P2 | <= 1,8 % / ~2 % | 32/16/2 |  | 3
  m325 gelernt P1 / P2 | P1: 1/3 gelernt (70 Tsd.), 2 Plateau 85-89 %; P2: beide Plateau-Läufe gelernt nach 5.000 Fenstern (92,2 / 94,6 %) | 16/2/8 |  | 3
Ergebnis e38 [2026-10-21 11:25]: erfuellt
  Fazit: Nach dem Wortlaut der Plan-Datei hält die Schwelle: Kopfbreite >= 8 kopiert in jeder Zelle, <= 4 in keiner (Budget 120.000 Fenster, beide Protokolle). Die Deutung „es zählt die Kopfbreite, nicht die Kopfzahl“ ist aber zurückgenommen: Kopfbreite und Kopfzahl/Breite sind im Kern nicht entkoppelbar, der Vergleich entscheidet keine der beiden Größen allein. Praktisch folgt: für Kopierversuche Kopfbreite >= 8 wählen. Bei gleicher Kopfbreite 8 lernt 32/4 glatt, 16/2 braucht die kleine Rate (Plateau 85-89 % ist ein Lernraten-Effekt).
  Offen: Breite 64 (snai/kopier-knirps-lr-breite). Zurückgenommene Werte zur Lage des Kopierens am 16/2/8-Plateau (51 % Schärfungsanteil, „zwei Drittel Suche“, „Ort“ 86-92 %) gelten nicht mehr; auf dem sauberen Paar ohne Revival 68 % statt 86-92 %, Schärfungsanteil über Saaten unter 50 %. Altes Gitter g_* (defektes Revival) ist ungepaart und nicht zu zitieren. Vorbehalt Lade-Wächter: n_d32h8 u. a. betroffen.
Abgeloest und ausgeblendet: 1 messwert - voll=True zeigt sie.
Chronik:
  2026-10-21 11:23 angelegt (Nachtrag: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt; Zellen- und Schwellenregel aus der Plan-Datei (Kopf: „Kriterien VOR dem ersten Lauf“), die der Eintrag nicht nennt, am 2026-10-21 nachgelesen)
  2026-10-21 11:24 Rezept r39
  2026-10-21 11:24 Status geplant -> laeuft (Rezept r39)
  2026-10-21 11:24 Messwerte m317-m324
  2026-10-21 11:25 Messwerte m325, loesen m318 ab
  2026-10-21 11:25 Ergebnis e38: erfuellt
  2026-10-21 11:25 Status laeuft -> ausgewertet (Ergebnis e38)
```
