# snai/f2-emb-gradteil

```text
snai/f2-emb-gradteil - ausgewertet, angelegt 2026-11-03, zuletzt 2026-11-03 10:59
!! ohne Rezept
Frage: Wie teilt sich der Gradient der gebundenen Embedding-Matrix E an trainierten T2-Ständen (128x4 int8, gebunden, ohne Faktor) auf Eingangs- und Ausgangsseite auf, und zieht die Ausgangsseite E klein? Prüfung F2, gewünscht von SnAI Evo.
Kriterium (festgelegt 2026-11-03 10:58, vor dem ersten Messwert):
  rechner-b ~/snai_pruef/clip_torch/f2/KRITERIEN_f2.md, festgelegt 10:41 vor der ersten Messung.

Stände: T2 an Schritt 9000 und am Ende (27018). Pflicht sind s4 und s5, s6-s11 laufen als Reichweite mit. Kontrolle ist U2.

Fenster: 64 aus heldout.txt, gleiche Auswahl wie mess_text.php.

Vorwärts im float-Nachbau (torch_k1e.vorwaerts mit dequantisierten Gewichten). Er muss den Engine-Loss auf ≤ 0,01 nats treffen, sonst gilt der Stand nicht.

Gemessen werden |g_ein|², |g_aus|², der Ausgangsanteil A und der Kosinus zwischen beiden. Der radiale Zug wird einfach und adam-gewichtet berechnet.

Rotproben: Sonde ohne Trennung, vertauschte Seiten, U2 als gebunden behandelt.
Darauf baut: snai/torch-v-getrennt
Messwerte (Groesse | Wert | Arm | Start | n):
  m8241 A Ausgangsanteil t9000 | 0.887 | T2 | s4 | 64
  m8242 A Ausgangsanteil Ende | 0.904 | T2 | s4 | 64
  m8243 A Ausgangsanteil t9000 | 0.866 | T2 | s5 | 64
  m8244 A Ausgangsanteil Ende | 0.893 | T2 | s5 | 64
  m8245 A Spanne alle Saaten/Stände | 0.855-0.911 | T2 | s4-11 | 16
  m8246 Kosinus g_ein/g_aus | +0.00 bis +0.017 | T2 | s4-11 | 16
  m8247 radial adam-gewichtet Vorzeichen negativ | 15/16, Mittel -0.42 (WD-Zug 4.8-5.1) | T2 | s4-11 | 16
  m8248 Forward torch vs Engine max | 0.0011 nats | T2,U2 | s4-11 | 32
Ergebnis e497 [2026-11-03 10:59]: erfuellt
  Fazit: Nach Vorab-Regel überwiegt der Ausgang. An trainierten T2-Ständen kommen rund 90 % des E-Gradienten (Norm²) von der Ausgangsseite: A liegt bei 0,855-0,911 in 16/16 Ständen. Beide Seiten stehen praktisch senkrecht zueinander, der Kosinus liegt bei ≤ 0,017. Ihre Größen entsprechen dem ungebundenen U2, die Bindung legt sie nur auf eine Matrix und ein gemeinsames Adam-v.

„Ausgangsseite zieht E klein“ ist NICHT gestützt:
- Der radiale Zug wechselt in der einfachen Form das Vorzeichen.
- Adam-gewichtet zeigt er eher nach außen (15/16 negativ, einzeln aber meist innerhalb von 2 SE um 0).
- In U2 ist der Zug auch nur 1 % des Weight Decay, und RMS(E) wächst dort trotzdem. Der Momentanzug legt die Norm also nicht fest.

Kontrollen: Der Forward trifft die Engine auf ≤ 0,0011 in 32/32 Ständen. Die Summe der Seiten ist bitgleich zum Autograd. U2 hat einen Ausgangsanteil von exakt 0. Alle drei Rotproben waren rot.

Grenze: Gemessen ist der float-Gradient, nicht der int8-Backward.

Deutung, nicht gemessen: Unter Adam bestimmt die Ausgangsseite fast allein das v von E. Der Eingangsanteil bekommt dadurch nur etwa ein Drittel seiner ungebundenen Schrittweite. Das passt zur Reparatur durch den Faktor F, der Forward und Eingangsgradient zugleich hebt.

Ein Eingriff, der das isolieren würde: gebunden bleiben, aber dem Ausgangsanteil von E ein eigenes v geben.
  Datei: rechner-b ~/snai_pruef/clip_torch/ERGEBNIS_f2_t2.md
Chronik:
  2026-11-03 10:58 angelegt
  2026-11-03 10:59 Messwerte m8241-m8248
  2026-11-03 10:59 Status geplant -> laeuft (Messwerte m8241-m8248)
  2026-11-03 10:59 Ergebnis e497: erfuellt
  2026-11-03 10:59 Status laeuft -> ausgewertet (Ergebnis e497)
```
