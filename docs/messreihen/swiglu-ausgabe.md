# snai/swiglu-ausgabe

```text
snai/swiglu-ausgabe - ausgewertet, angelegt 2026-11-12, zuletzt 2026-11-12 20:22
!! ohne Rezept
Frage: Liest sich die freie Ausgabe des Knirps mit SwiGLU besser als mit SiLU (Blindurteil), über Verlust und Held-out hinaus?
Kriterium (festgelegt 2026-11-12 19:57, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/swiglu/KRITERIEN_ausgabe.md (4c5c8c79, Prüfer eingearbeitet). 16 Endstände aus snai/swiglu-knirps, 5 Anfänge aus heldout2, 40 Token T 0,8, mt_srand 4711; 40 Paare SI/SG + 4 Grobkontrollen (intakt gegen gebrochen, gültig bei >= 3/4) + 4 Feinkontrollen (Endstand gegen Schritt 3.000, ~0,5 nats, Eichung). Blind, Reihenfolge/Seite zufällig, Schlüssel lokal. Vorzeichentest zweiseitig ohne Gleichstände: p < 0,05 -> eine Bauart liest sich besser; < 10 Paare ohne Gleichstand -> kein Unterschied sichtbar; sonst OFFEN. Zweite Lesart Mehrheit je Saat. Nebengrößen Wdh (gierig), Vielfalt, Kongruenz d1.
Plan: rechner-a:~/snai_pruef/swiglu/KRITERIEN_ausgabe.md
Baut auf: snai/swiglu-knirps, snai/knirps-kongruenz27
Messwerte (Groesse | Wert | Arm | Start | n):
  m10779 Wdh gierig d SG-SI Mittel (5 neg/3 pos von 8) | -0.0154
  m10780 Vielfalt T0,8 d SG-SI Mittel (6 neg/2 pos von 8) | -0.0217
  m10781 Kongruenz d1 d SG-SI Mittel (6 pos/2 neg von 8) | 0.0003
  m10782 Rot Vielfalt intakt/gebrochen (K-Anfänge, T 0,8) | 0.629/0.430
  m10783 Rot Wdh@T0,8 intakt/gebrochen | 0.048/0.148
  m10784 Erzeugung 176 Texte rc0, Fehlerkanal nur erwartete Zeilen | 176
  m10785 Blindseite claude.ai/artifact/FdPDaPwMa8uYSyZq34Ksef, Schlüssel md5 | 13f3ec02
  m10786 Blind haupt SG besser | 12
  m10787 Blind haupt SI besser | 13
  m10788 Blind haupt gleich | 15
  m10789 Vorzeichentest p zweiseitig | 1.0
  m10790 Je Saat Mehrheit SG/SI/gleich | 4/4/0
  m10791 Grobkontrolle intakt/gebrochen/gleich | 3/0/1
  m10792 Feinkontrolle Endstand/t3000/gleich | 2/1/1
Ergebnis e651 [2026-11-12 20:22]: keine_aussage
  Fazit: Wortlaut OFFEN: SG 12, SI 13, gleich 15, p 1,0; Grobkontrolle 3/4 (gültig), Feinkontrolle 2/4 (auch 0,5 nats beim Lesen nicht sicher sichtbar). Kennzahlen Wdh, Vielfalt, Kongruenz d1 ohne gesicherten Unterschied. Beim Lesen kein Unterschied erkennbar, aber das Lesen bei 40 Token T 0,8 ist für Abstände dieser Größe am Knirps zu grob. Lesetest erst bei einem stärkeren Modell (512, langer Lauf) sinnvoll.
  Datei: rechner-a:~/snai_pruef/swiglu/ERGEBNIS_ausgabe.md
Chronik:
  2026-11-12 19:57 angelegt
  2026-11-12 20:02 Messwerte m10779-m10785
  2026-11-12 20:02 Status geplant -> laeuft (Messwerte m10779-m10785)
  2026-11-12 20:22 Messwerte m10786-m10792
  2026-11-12 20:22 Ergebnis e651: keine_aussage
  2026-11-12 20:22 Status laeuft -> ausgewertet (Ergebnis e651)
```
