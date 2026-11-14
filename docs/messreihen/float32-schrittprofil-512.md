# snai/float32-schrittprofil-512

```text
snai/float32-schrittprofil-512 - ausgewertet, angelegt 2026-10-30, zuletzt 2026-10-30 18:58
!! ohne Rezept
Frage: Wo gehen die 16 s je Schritt des float32-GPU-Laufs (dim 512, ctx 1024, L6, 1 Kopf, Hauptzweig snai_edge-Stand) hin?
Kriterium (festgelegt 2026-10-30 18:52, vor dem ersten Messwert):
  Gemessen: die eingebauten Zaehler cortex_profile_get(0..6) je train_step, Median ueber die vollen Schritte, im Rezept r473 auf rechner-b, Karte allein, entsperrt. Kontrolle: md5 Ausgabemodell == 105aea27, sonst stoert die Messung und sie ist ungueltig; Summe der Bloecke gegen STEP_MS abgleichen, Luecke ueber 10 % wird als unerklaert berichtet. Urteil: Ein Block ab 25 % der Schrittzeit ist Optimierungskandidat; keiner ab 25 % = kein einzelner Hebel. Drei Laeufe; alle drei muessen dieselbe Reihenfolge der Bloecke ergeben, sonst traegt es keinen Schluss. Die Ursache innerhalb eines Blocks ist damit nicht belegt, erst ein Eingriff isoliert sie. Reichweite: eine Karte, eine Geometrie.
Baut auf: snai/tf32-unlock-512
Darauf baut: snai/float32-att-threads-512
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/tf32_unlock/bench_tf32/logP_r*.txt, PROF-Zeilen, Median ueber volle Schritte
  m6715 Attention rueckwaerts ms (Zaehler 4) | 10496 | entsperrt | r1 | 7
  m6716 Attention rueckwaerts ms (Zaehler 4) | 10611 | entsperrt | r2 | 7
  m6717 Attention rueckwaerts ms (Zaehler 4) | 10494 | entsperrt | r3 | 7
  m6718 Vorwaerts GPU inkl. Attention ms (Zaehler 0) | 3078 | entsperrt | r1 | 7
  m6719 Vorwaerts GPU inkl. Attention ms (Zaehler 0) | 3109 | entsperrt | r2 | 7
  m6720 Vorwaerts GPU inkl. Attention ms (Zaehler 0) | 3078 | entsperrt | r3 | 7
  m6721 Clip+Adam ms | 116 | entsperrt | r1-3 | 3
  m6722 Schritt gesamt ms | 15996 | entsperrt | r1 | 7
  m6723 Schritt gesamt ms | 16120 | entsperrt | r2 | 7
  m6724 Schritt gesamt ms | 15988 | entsperrt | r3 | 7
  m6725 md5 Ausgabemodell | 105aea27 | entsperrt | r1-3 | 3
Ergebnis e416 [2026-10-30 18:58]: erfuellt
  Fazit: Optimierungsziel ist die Attention-Rueckwaertsrechnung auf der Karte: rund 66 % des Schritts in allen drei Laeufen. Der naechste Block ist der Vorwaertszaehler mit 19 %, Adam ist mit unter 1 % kein Thema. Die Zaehler ueberlappen: Zaehler 4 steckt in Zaehler 2, Zaehler 2 enthaelt ausserdem GEMM. Ohne Doppelzaehlung bleiben rund 3 % unerklaert. Wo innerhalb der Attention die Zeit liegt, ist nicht gemessen.
  Offen: Aufteilung von Zaehler 0 in Attention und GEMM; Ursache innerhalb der Attention; andere Geometrien.
Chronik:
  2026-10-30 18:52 angelegt
  2026-10-30 18:58 Messwerte m6715-m6725
  2026-10-30 18:58 Status geplant -> laeuft (Messwerte m6715-m6725)
  2026-10-30 18:58 Ergebnis e416: erfuellt
  2026-10-30 18:58 Status laeuft -> ausgewertet (Ergebnis e416)
```
