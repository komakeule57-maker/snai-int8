# snai/kopier-prod512b-koepfe

```text
snai/kopier-prod512b-koepfe - ausgewertet, begonnen 2026-10-20, angelegt 2026-10-21, zuletzt 2026-10-21 11:28
Frage: Scheitert bei prod512b (s1, s2) über weiten Abstand (796) das FINDEN der Quelle durch die Kopierköpfe?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  Kopierköpfe K haben Folge-Gewicht >= 0,1 auf Abstand 96. V_LL = F(Abstand 796)/F(spaet_ll); spaet_ll hat gleiche Länge, gleiche Fensterstelle und denselben Fülltext. V_LL <= 0,5 heißt FINDEN SCHEITERT.
Plan: rechner-a:~/snai_pruef/reichweite/kriterien_att.txt
Baut auf: snai/kopier-prod512b-pos, snai/kopier-material-abstand
Rezepte:
  r48 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben; POS-Sonde mit Stellrad SNAI_ATT_ARME)
      quelltext: tg1-Quelltext 2363b610 (Röntgen-Bibliothek)
      parameter: prod512b s0, s1, s2; Mitschnitt aus dem echten Vorwärtspfad: Röntgen-Bibliothek aus dem tg1-Quelltext 2363b610; 24 Posten je Modell; Abstände 96 / 320 / 796 und Kontrolle spaet_ll
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/reichweite
Messwerte (Groesse | Wert | Arm | Start | n):
  m401 V_LL (796 gegen spaet_ll) | 0,261 | s1 |  | 24
  m402 V_LL (796 gegen spaet_ll) | 0,260 | s2 |  | 24
  m403 V_L (320) | 0,82 / 0,69 | s1 / s2 |  | 24
  m404 Ratenverhältnis R_LL / R_L | 0,11 / 0,46-0,64 | s1, s2 |  | 24
  m405 Schaltkreis | Vorgänger-Kopf 2.4 (0,96), Hauptkopierkopf 3.6 (Folge 0,62, Spitze 0,95), Nebenkopf 3.0 | s1, s2
  m406 Marge Kopf 3.6 (Quelle minus größter sonst) bei 96 / 320 / 796 | +2,3 bis +2,7 / +1,6 / -0,3 | s1, s2
  m407 Gewicht auf näherem Fülltext bei 796 / bei spaet_ll | 0,56 / 0,19 | s1, s2
  m408 Rot 1 (s0 max Folge-Gewicht) / Rot 2 (fremd/W) | 0,088 / 0,015 | Messgerät
Ergebnis e45 [2026-10-21 11:28]: erfuellt
  Fazit: FINDEN SCHEITERT, s1 und s2 einig: bei Abstand 796 findet der Hauptkopierkopf 3.6 die Quelle nicht mehr (seine Marge fällt mit dem Abstand stetig und wird bei 796 negativ, das Gewicht geht auf näheren Fülltext), und kein anderer Kopf übernimmt. Der Engpass der Reichweite liegt also im Suchen, nicht im Übertragen. Deutung, nicht gemessen: gelernte Nähe-Vorliebe, passend zum dünnen Weit-Material; von einer Architekturgrenze erst per Eingriff zu trennen (snai/reichweite-v3).
  Offen: 24 Posten je Modell, ein Lauf. Regression bytegleich, Rot 1 und Rot 2 bestanden.
Chronik:
  2026-10-21 11:27 angelegt (Nachtrag: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:27 Rezept r48
  2026-10-21 11:27 Status geplant -> laeuft (Rezept r48)
  2026-10-21 11:27 Messwerte m401-m408
  2026-10-21 11:28 Ergebnis e45: erfuellt
  2026-10-21 11:28 Status laeuft -> ausgewertet (Ergebnis e45)
```
