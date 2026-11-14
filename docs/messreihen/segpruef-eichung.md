# snai/segpruef-eichung

```text
snai/segpruef-eichung - ausgewertet, begonnen 2026-10-10, angelegt 2026-10-21, zuletzt 2026-10-21 19:26
!! ohne Kriterium
Frage: Wie groß sind die Gradientenanteile der Gruppen (u. a. V/O) in den Armen C, D, E, K, S0 bei einer kurzen Fortsetzung, als Eichung für die Segmentprüfung?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Plan: 40 Schritte Fortsetzung je Arm auf gp_<arm>_g4.
Darauf baut: snai/segpruef-minilauf
Rezepte:
  r169 [2026-10-21] C, D, E, K, S0: bash segpruef/eich.sh <arm>
      quelltext: segpruef/proj
      parameter: 40 Schritte ab gp_<arm>_g4
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/segpruef/logs/eich_{C,D,E,K,S0}.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/segpruef/logs/eich_K.log, eich_E.log (aus den Logs nachgeprüft)
  m2022 V/O-Gradientenanteil | 0,85 bis 0,97 % | K |  | 40
  m2023 V/O-Gradientenanteil | 39,6 % | E |  | 40
Ergebnis e159 [2026-10-21 19:26]: beobachtung
  Fazit: K und E liegen beim V/O-Anteil um den Faktor 40 auseinander; für eine Prüfschwelle ist das ein bequemer Abstand. Da die Faktor-2-Regel erst nach den Läufen entstand, ist die Eichung Beobachtung; sie taugt als Ausgangspunkt, nicht als Beleg für die Schwelle.
  Offen: Werte für C, D, S0 nicht übernommen (nur K und E geprüft).
  Datei: rechner-b:~/snai_pruef/segpruef/eich.sh
Chronik:
  2026-10-21 19:26 angelegt (Nachtrag: Nachtrag 2026-10-21 aus rechner-b ~/snai_pruef/segpruef/logs/eich_*.log (2026-10-10 14:29 bis 14:40). Die Regel 'Faktor 2' steht erst im Eintrag nach den Läufen.)
  2026-10-21 19:26 Rezept r169 (C, D, E, K, S0)
  2026-10-21 19:26 Status geplant -> laeuft (Rezept r169)
  2026-10-21 19:26 Messwerte m2022, m2023
  2026-10-21 19:26 Ergebnis e159: beobachtung
  2026-10-21 19:26 Status laeuft -> ausgewertet (Ergebnis e159)
```
