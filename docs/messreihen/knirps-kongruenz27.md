# snai/knirps-kongruenz27

```text
snai/knirps-kongruenz27 - ausgewertet, angelegt 2026-11-04, zuletzt 2026-11-04 20:20
Frage: Kosten tote L2-FFN-Gains Grammatik, wenn sich die Arme nur in einem Stellrad unterscheiden? Gemessen wird die Genuskongruenz an den rep27-Endständen. EW hat den Eingangsfaktor F, seine L2-Gains sind zu 6–21 % tot. KW hat kein F, seine L2-Gains sind in 6/8 Saaten zu ≥ 97 % tot. Der Verlust unterscheidet sich um −0,009. Das ist die Nachfolge von e530, die offen blieb, weil sich dort der LR-Plan mitänderte.
Kriterium (festgelegt 2026-11-04 20:15, vor dem ersten Messwert):
  Der Wortlaut steht in rechner-a ~/snai_pruef/stell/KRITERIEN_kongruenz27.md. Gemessen wird bei d2 (Artikel, ein Wort, dann das Substantiv), je Saat r = E_KW / E_EW, Saaten s4–s11.
- KOSTEN: Mittel r ≥ 1,2 und r > 1 in 6/8.
- KEIN UNTERSCHIED: Mittel 0,9–1,1 und r in 0,8–1,25 in 6/8.
- HELFEN: Mittel ≤ 0,83 und r < 1 in 6/8.
- Sonst OFFEN. Knapp gilt als nicht erfüllt.

Rot-Probe: EW s4 ohne F muss M d2 < 0,9 liefern. Daneben EWo/EW. Als Beobachtung wird KW/EW zusätzlich nur über die 6 Saaten mit ≥ 97 % toten Gains ausgewertet.

Grenze: F verändert auch die Skala der Embeddings. Ein Befund heißt deshalb „fällt mit dem Gain-Sterben zusammen“, nicht „ist dadurch verursacht“.
Darauf baut: snai/swiglu-ausgabe
Rezepte:
  r587 [2026-11-04] rechner-a: cd ~/snai_pruef/stell && ./kongruenz27.sh (3c50b773; KRITERIEN_kongruenz27.md 6e21b713 mit Prüferabschnitt). Gemessen wird zuerst die Rot-Probe EW s4 ohne F, danach EW, KW und EWo für s4–s11 mit kongruenz_ow.php (b1c36490) auf heldout2, 700 Fenster, genus_lex.json, jeder Arm mit seinem F, 4 Läufe zugleich. Ausgabe nach log/kongruenz27.jsonl und .err. Ausgewertet wird mit werkzeug/ausw_kongruenz27.py (b1d991b9), die Regeln stehen in ausw_kongruenz_regeln.py (428eb38d), wörtlich aus ausw_kongruenz.py übernommen.
      rechner: rechner-a
Messwerte (Groesse | Wert | Arm | Start | n):
  m8830 Rot EW s4 ohne F M d2 | 0.9722 | mit F 0,9700; gefordert <0,9 -> SONDE BLIND; Verlust ohne F 5,7536
  m8831 Rot EW s4 ohne F M d1 | 0.5892 | mit F 0,9865 -> d1 sieht den Bruch
  m8832 r KW/EW d2 Mittel | 1.154 | BS 1,018..1,293, 5/8 >1, OFFEN knapp (ungueltig, Sonde blind)
  m8833 r EWo/EW d2 Mittel | 1.100 | BS 1,002..1,207, OFFEN knapp
  m8834 r KW/EW d1 Mittel | 0.944 | BS 0,873..1,032, KEIN UNTERSCHIED knapp (6/8), nur berichtet
  m8835 r EWo/EW d1 Mittel | 0.965 | BS 0,899..1,041, KEIN UNTERSCHIED
  m8836 E d1 EW / KW / EWo | 0.0119 | KW 0,0112, EWo 0,0114, Trigramm 0,0024
Ergebnis e532 [2026-11-04 20:20]: keine_aussage
  Fazit: Die Rot-Probe ist durchgefallen, die Sonde ist blind. Die entscheidende Größe d2 bemerkt einen Bruch des Modells nicht: Ohne F steigt der Verlust auf 5,75, M d2 bleibt bei 0,972. Wahrscheinlich trägt das Adjektiv dazwischen das Genus schon lokal. Das Hauptkriterium trägt deshalb kein Urteil. Dasselbe gilt rückwirkend für d2 in e530.

Die Größe d1 hat den Bruch gesehen, sie fiel auf 0,589. Sie zeigt keinen Unterschied zwischen lebenden und toten L2-Gains (KW/EW 0,944, BS 0,87..1,03) und keinen zu einem Modell ohne mittlere FFN (0,965). Das ist eine Beobachtung: Bei 128x4 kosten tote Gains nichts, was der Verlust verbirgt. d1 ist aber sehr lokal, das Trigramm ist hier besser als jedes Modell.

Für einen echten Fähigkeitstest jenseits des Verlusts muss man auf prod512b ausweichen (Kopiersonde ab s12).
  Datei: rechner-a ~/snai_pruef/stell/ERGEBNIS_kongruenz27.md
Chronik:
  2026-11-04 20:15 angelegt
  2026-11-04 20:16 Rezept r587
  2026-11-04 20:16 Status geplant -> laeuft (Rezept r587)
  2026-11-04 20:20 Messwerte m8830-m8836
  2026-11-04 20:20 Ergebnis e532: keine_aussage
  2026-11-04 20:20 Status laeuft -> ausgewertet (Ergebnis e532)
```
