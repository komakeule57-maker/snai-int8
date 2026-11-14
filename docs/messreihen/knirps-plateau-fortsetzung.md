# snai/knirps-plateau-fortsetzung

```text
snai/knirps-plateau-fortsetzung - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 14:31
Frage: Warum bleibt der Kopier-Knirps 16/2/8 (LR 0,001) bei 85 % Rang 0 stehen: Lernraten-Effekt oder Kapazitätsgrenze? Fortsetzungsprobe vom Endstand.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt, NACHTRAG "Warum bleibt Breite 16 mit 2 Koepfen bei 85 %?" (2026-10-12, vor dem Lauf). (Punkt 1-3).):
  Vom Endstand (60.000 Fenster, LR 0,001) vier weitere Segmente (Saaten 1012..1015), einmal mit LR 0,0001, einmal unverändert mit 0,001. OPTIMIERUNG (Lernrate zu hoch für die letzte Strecke), wenn die Fortsetzung mit 0,0001 >= 90 % erreicht und die mit 0,001 nicht. Bleiben beide unter 90 %: kein Lernraten-Effekt.
Plan: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt
Baut auf: snai/kopier-knirps-gitter
Darauf baut: snai/knirps-plateau-schaerfen
Rezepte:
  r78 [2026-10-21] k. A. (Fortsetzung des Arms w256_d16h2_lr0.001 um vier Segmente; Skript nicht im Eintrag)
      quelltext: knirps/proj, libcortex.so 1c634106f31c, Revival an
      parameter: 16/2/8, wort256, var, ctx 64; vier Segmente à 5.000 Fenster mit LR 0,0001 bzw. 0,001
      seed: Segment-Saaten 1012..1015, eine Genesis
      rechner: rechner-a
      logs: k. A. (nicht gefunden)
      notiz: Prüfung beim Nachtrag: Nicht aus Rohdaten nachgerechnet (Fortsetzungsprotokolle nicht gefunden). Der Lauf lief mit altem Revival (Revival griff in w256_d16h2_lr0.001 ab Segment 8 ein).
Messwerte (Groesse | Wert | Arm | Start | n):
 , nicht nachgerechnet
  m783 Rang 0 nach Fortsetzungssegment 1-4 (1 Lauf) | 91,1 / 90,6 / 91,4 / 91,4 % | LR 0,0001 |  | 200
  m784 Rang 0 nach Fortsetzungssegment 1-4 (1 Lauf) | 86,6 / 86,5 / 83,1 / 83,7 % | LR 0,001 |  | 200
  m785 Schaltkreis am Plateau: Vorgänger Kopf 0.1 / Folge 1.0, 1.1 (Muster) | 0,964 / 0,807, 0,795 | Plateau-Stand |  | 1
  m786 Kausal: aus 0.1 / aus je einem Folge-Kopf / aus 0.0 (Muster) | 7,4 / 17-19 / 71,4 % | Plateau-Stand |  | 1
Ergebnis e66 [2026-10-21 14:31]: erfuellt
  Fazit: Das 85-%-Plateau ist ein Lernraten-Effekt: mit 0,0001 erreicht derselbe Stand in einem Segment über 90 %, mit 0,001 nicht. Das hielt auch später ("85-%-Plateau als Lernraten-Effekt" gehört zu dem, was trug) und mündete in den Zweiphasen-Durchgang des Gitters. Der Schaltkreis am Plateau ist vollständig (Vorgänger- und zwei Folge-Köpfe). Mit Revival an und einem Lauf ist das eine Aussage über diese Zelle.
  Offen: Wo im Netz der Rest der Lücke steckt: snai/knirps-plateau-schaerfen, snai/knirps-plateau-tausch.
  Datei: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt
Chronik:
  2026-10-21 14:31 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt, NACHTRAG "Warum bleibt Breite 16 mit 2 Koepfen bei 85 %?" (2026-10-12, vor dem Lauf). (Punkt 1-3).)
  2026-10-21 14:31 Rezept r78
  2026-10-21 14:31 Status geplant -> laeuft (Rezept r78)
  2026-10-21 14:31 Messwerte m783-m786
  2026-10-21 14:31 Ergebnis e66: erfuellt
  2026-10-21 14:31 Status laeuft -> ausgewertet (Ergebnis e66)
```
