# snai/fp32-bindung-abnahme

```text
snai/fp32-bindung-abnahme - ausgewertet, begonnen 2026-10-11, angelegt 2026-10-21, zuletzt 2026-10-21 19:28
Frage: Ist die FP32-Bindung von w_out an die Embeddings (Patch 2026-10-11) korrekt: Gradientensumme, Spiegel, ein Adam-Zustand, Speichern/Laden, Abweisung, ungebundener Pfad unberührt?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus rechner-a ~/snai_pruef/fbind/abnahme_20261011.out (mtime 2026-10-11 22:37) und dem Prüfskript.):
  Vorab in diagnose/verify_fp32_tying_lauf.py: K1 Kosinus m_emb gegen Summe >= 0,9999; K2 Kern meldet 'aktiv' und Spiegel gleich; K3 m/v von w_out bleiben 0; K4 Speichern/Laden ohne Abweichung; K5 falsche Bindung abgewiesen; K6 ungebundener Pfad unverändert. Rot-Probe: --sabotage-merge muss K1, --sabotage-spiegel K2 rot machen.
Plan: Abnahme K1 bis K6 mit zwei Sabotagekopien.
Rezepte:
  r172 [2026-10-21] python3 diagnose/verify_fp32_tying_lauf.py [--sabotage-merge|--sabotage-spiegel]
      quelltext: fbind/proj mit fp32_bindung_20261011.patch; Sabotage in fbind/sab_merge, sab_spiegel
      parameter: 6 Schritte gebunden
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/fbind/abnahme_20261011.out
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/fbind/abnahme_20261011.out
  m2162 K1 Kosinus | 1,000000 | neu |  | 1
  m2163 K1 Kosinus | 0,669354 | sab_merge |  | 1
  m2164 K2 Spiegel | grün | neu |  | 1
  m2165 K4 Abweichung nach Laden | 0 | neu |  | 1
  m2166 K4 Abweichung nach Laden | 3,04e-3 | Sabotage |  | 1
  m2167 K6 Tensoren gleich | 33 | ungebunden |  | 1
  m2168 Treue der Messkopie Loss | 8,30595 gegen 8,30584 | Messkopie gegen Original |  | 1
Ergebnis e163 [2026-10-21 19:28]: erfuellt
  Fazit: Alle sechs Punkte grün, die Sabotage fällt in K1, K2 und K4 auf. Die FP32-Bindung lässt sich also wie die int8-Bindung nutzen. Rot gesehen sind nur K1, K2, K4; K3, K5 und K6 sind grün ohne Gegenprobe und belegen deshalb weniger.
  Offen: Rot-Proben für K3, K5, K6 fehlen.
  Datei: rechner-a:~/snai_pruef/fbind/abnahme_20261011.out
Chronik:
  2026-10-21 19:27 angelegt (Nachtrag: Nachtrag 2026-10-21 aus rechner-a ~/snai_pruef/fbind/abnahme_20261011.out (mtime 2026-10-11 22:37) und dem Prüfskript.)
  2026-10-21 19:27 Rezept r172
  2026-10-21 19:27 Status geplant -> laeuft (Rezept r172)
  2026-10-21 19:28 Messwerte m2162-m2168
  2026-10-21 19:28 Ergebnis e163: erfuellt
  2026-10-21 19:28 Status laeuft -> ausgewertet (Ergebnis e163)
```
