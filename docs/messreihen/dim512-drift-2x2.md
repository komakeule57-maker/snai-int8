# snai/dim512-drift-2x2

```text
snai/dim512-drift-2x2 - ausgewertet, begonnen 2026-09-23, angelegt 2026-10-21, zuletzt 2026-10-21 19:33
Frage: Reproduziert auf dem Laptop der Modellzustand (Basis s8 gegen s11) oder das Korpusmaterial (alte gegen SFT-bereinigte Fassung von pseg09) den Schrittzeit-Drift von prod512?
Kriterium (nachgetragen, Beleg: Vorhersage (2026-09-24) 'vor der Messung'; die 10-%-Regel ist die allgemeine Projektregel.):
  Vorhersage vor der Messung: A ~ B (Material egal) und C > A (Modellzustand). Projektregel: unter 10 % Unterschied ist Gleichstand.
Baut auf: snai/dim512-drift-verdaechtige
Darauf baut: snai/dim512-ftz-vorwaerts
Rezepte:
  r211 [2026-10-21] vier Läufe gleichzeitig, je 2 MB aus pseg09.txt ab Byte 18.000.000, train_cluster/train_worker wie im Produktivlauf; Befehl wörtlich k. A.
      quelltext: k. A.
      parameter: Basis prod512_s8 bzw. prod512_s11; Material alt (Laptop, 2026-09-03) bzw. neu (Server, 2026-09-16); 571 bzw. 572 Schritte; OMP_NUM_THREADS=1; Start im Abstand von 2 s
      rechner: rechner-a (Ryzen 5 5500U)
      logs: k. A.
Messwerte (Groesse | Wert | Arm | Start | n):
 , nicht nachgerechnet
  m2481 s je Schritt | 29,860 | Basis s8, Material alt |  | 571
  m2482 s je Schritt | 30,053 | Basis s8, Material neu |  | 572
  m2483 s je Schritt | 30,433 | Basis s11, Material alt |  | 571
  m2484 s je Schritt | 30,492 | Basis s11, Material neu |  | 572
  m2485 Materialeffekt (Mittel) | +0,4 % | Laptop |  | 4
  m2486 Modelleffekt (Mittel) | +1,7 % | Laptop |  | 4
  m2487 Vergleich Server, gleiches Modellpaar | +10,0 % | vserver |  | 1
Ergebnis e199 [2026-10-21 19:33]: gleichstand
  Fazit: Auf dem Laptop liegen alle vier Arme unter 10 % auseinander; die Richtung (Modell statt Material) passt zur Vorhersage, die Größe (1,7 statt 10 %) nicht. Das 2x2 erklärt den Drift also nicht, zeigte aber, dass er serverspezifisch ist. Genau das sagte später der Denormalen-Befund voraus: der Ryzen zahlt für Denormale nichts (snai/dim512-ftz-vorwaerts).
  Offen: Die Zielreihenfolge war exakt die Startreihenfolge (Spanne 2,3 %); der Gegenversuch mit umgekehrter Startfolge fehlt, Scheduling ist nicht ausgeschlossen.
Chronik:
  2026-10-21 19:33 angelegt (Nachtrag: Vorhersage (2026-09-24) 'vor der Messung'; die 10-%-Regel ist die allgemeine Projektregel.)
  2026-10-21 19:33 Rezept r211
  2026-10-21 19:33 Status geplant -> laeuft (Rezept r211)
  2026-10-21 19:33 Messwerte m2481-m2487
  2026-10-21 19:33 Ergebnis e199: gleichstand
  2026-10-21 19:33 Status laeuft -> ausgewertet (Ergebnis e199)
```
