# snai/prod512-fitwahl-s6

```text
snai/prod512-fitwahl-s6 - ausgewertet, begonnen 2026-09-12, angelegt 2026-10-21, zuletzt 2026-10-21 19:28
Frage: Folgt der Held-out des Produktivlaufs prod512 einem Potenzgesetz L(s) = a + b·s^-alpha oder einem geometrischen Zerfall der Segmentgewinne? Entscheidet die Laufdauer (Abbruch um s8 gegen um s24).
Kriterium (nachgetragen, Beleg: Kriterium (2026-09-13 18:56), dort als 'aufgestellt VOR der Messung' bezeichnet; die Prognosen selbst stehen nur in diesem nachträglich geschriebenen Eintrag. Die Schwelle für 'trifft' ist nicht in Sigma vorab benannt.):
  Beide Fits auf s1..s5 standen vor der Messung von s6 fest: geometrisch L(s6) = 4,2343, Potenzgesetz L(s6) = 4,1878; SE je Punkt 0,0061. Es gilt das Modell, dessen Prognose die gemessene HELDOUT_FULL_LOSS von s6 trifft.
Baut auf: snai/prod512-lauf
Darauf baut: snai/prod512-ausreisser-s7
Rezepte:
  r178 [2026-10-21] numpy-Gittersuche über alpha, a und b je alpha per kleinste Quadrate (Skript nicht erhalten); Nachrechnung 2026-10-21 mit eigener Gittersuche, Schritt 0,0001
      quelltext: Originalskript k. A.; die Held-out-Werte aus rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/heldout_full_i8_prod512_sN.jsonl
      parameter: Fit auf s1..s5, Prognose s6; SE 0,0061 (aus der gepaarten Messung s4->s5)
      seed: deterministisch
      rechner: rechner-a
      logs: k. A.
Messwerte (Groesse | Wert | Arm | Start | n):
 ; Messwert s6 aus rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/server_heldout/heldout_full_i8_prod512_s6.jsonl abgelesen; Potenzgesetz-Prognose 2026-10-21 nachgerechnet (Gitter: 4,1878, alpha 0,2589 auf s1..s5; s1..s6 alpha 0,2633), geometrischer Fit nicht nachgerechnet (Form nicht dokumentiert)
  m2227 Prognose s6 Potenzgesetz | 4,1878 | Fit s1..s5 |  | 5
  m2228 Prognose s6 geometrisch | 4,2343 | Fit s1..s5 |  | 5
  m2229 HELDOUT_FULL_LOSS s6 gemessen | 4,189261 | prod512 s6 |  | 64
  m2230 Abstand zum Potenzgesetz | 0,2 Sigma | prod512 s6 |  | 64
  m2231 Abstand zum geometrischen Fit | 7,4 Sigma | prod512 s6 |  | 64
  m2232 Neufit s1..s6 alpha | 0,2635 | prod512 |  | 6
Ergebnis e166 [2026-10-21 19:28]: erfuellt
  Fazit: Das Potenzgesetz gilt, der geometrische Zerfall ist widerlegt: s6 lag 0,2 Sigma neben der Potenzgesetz-Prognose und 7,4 Sigma neben der geometrischen. Damit war die Entscheidung 'weiterlaufen bis etwa Segment 24, nicht bis 8' getragen. Die Lehre reicht über den Lauf hinaus: der geometrische Fit entstand aus einer einzigen Delle (s5), ein Modell nur auf den letzten Punkten hätte den Lauf 16 Segmente zu früh beendet.
  Offen: Die Sigma-Schwelle für 'trifft' stand nicht vorab fest; bei 0,2 gegen 7,4 Sigma ist das unerheblich.
Chronik:
  2026-10-21 19:28 angelegt (Nachtrag: Kriterium (2026-09-13 18:56), dort als 'aufgestellt VOR der Messung' bezeichnet; die Prognosen selbst stehen nur in diesem nachträglich geschriebenen Eintrag. Die Schwelle für 'trifft' ist nicht in Sigma vorab benannt.)
  2026-10-21 19:28 Rezept r178
  2026-10-21 19:28 Status geplant -> laeuft (Rezept r178)
  2026-10-21 19:28 Messwerte m2227-m2232
  2026-10-21 19:28 Ergebnis e166: erfuellt
  2026-10-21 19:28 Status laeuft -> ausgewertet (Ergebnis e166)
```
