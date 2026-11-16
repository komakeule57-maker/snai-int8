# Übertragsprobe: R und Q für den fertigen Schalter GANZ=12 (snai/fullint8-schluss12)

Stand 2026-11-16 ~06:50, rechner-a. Kriterien `KRITERIEN_SCHLUSS12.txt` (426e9afb), festgelegt vor dem ersten Lauf,
Prüfer vorher gelesen (Einwände dort einzeln beantwortet; R12w und R12f kamen deshalb dazu). Messwerte im Messbuch
m11712–m11727, Rezept r733.

## Aufbau

- hb_rund und hb_alle sind Kopien von proj_hb, also vom Hauptbaum nach Commit 6539a6c (Stufe 12):
  - Lib dca24a87, cortex_gz.nim ae179d20, cortex.nim 4e192007;
  - tensor_io.php 6d044735, train_cluster.php 50fc8b30, train_worker.php 4732351c.
- Vor dem Start war jede Code-Datei bytegleich zum Hauptbaum. Einzige Ausnahme ist revival_config.json, das wie in
  allen Probekopien auf „aus“ steht (= sch_alle).
- Skripte, Rezept und Saaten sind die der Schlussprobe. Einziges Stellrad: SNAI_I8_GANZ=12 statt 10 und der Code der
  Stufen 11 und 12.

## Befund

| Teil | Kriterium | gemessen | Urteil |
|---|---|---|---|
| R12 Rundungsprobe | Segment 0, vier Modi bytegleich; Rot h: auf ≠ nächster, Rot ≠ grün | 6a544467 viermal (= GANZ=10); Rot 5604c10f / b50d1ee2 (dieselben md5 wie bei GANZ=10) | erfüllt |
| R12w 2 Worker | Segment 0, vier Modi bytegleich | 3f64d3c1 viermal (= R2 der Stufe 11), Merge-Zeile „ganzzahlig gemittelt“ je Lauf | erfüllt |
| R12f Fortsetzung | Kurzlauf aus V8, vier Modi bytegleich | 389a20ff viermal (= st12 K2), Meldung „nicht angelegt“ | erfüllt |
| Q12 Qualität | Held-out ≤ +5 % gegen PyTorch in 3/3; 15 Checkpoints bytegleich zu sch_alle | +1,31 / +0,64 / +0,70 %; 15 von 15 bytegleich | erfüllt |
| K Messgerät | rc, Schritte, Wächter, Magic, Stufenliste, Stufe-12-Meldung, Telemetrie, Rot | alles ohne Befund (Rot 9,06 / 9,08 / 9,08) | erfüllt |

Vermerke zum Messgerät:

- In s3 Segment 2 ist die Engine-Zeile „Stufen an“ auf zwei Logzeilen zerteilt (bekannter Stückelfehler von
  train_cluster, interne Notiz). Der Inhalt ist vollständig.
- Bei einem Worker meldet train_cluster „[Merge] INT8-Tensoren (Pro-Zeile-Skala, neu abgeleitet) …“. merge_v6_models
  macht in dem Fall nur `copy()` (tensor_io.php, Zeile 1281), es wird nichts gerechnet. Die Meldung ist irreführend,
  der Weg unbedenklich.

Nebenbei im Quelltext gelesen (kein Kriterium): Ab Stufe 3 gibt es keinen float32-Rundungsrest mehr. Die Engine nimmt
nur SNAI_I8_REST=sr oder 0 und bricht sonst laut ab (cortex_gz.nim, gzOptSchritt). Der README-Absatz zum
„Rundungsrest“ gilt für den Ganzzahl-Schalter also nicht.

Reichweite: Knirps 96×2 gebunden, CPU, rechner-a, ein Korpus. Rundungsprobe mit einer Saat (s1) über Segment 0, dazu
2 Worker über Segment 0 und der Fortsetzungsweg im Kurzlauf. Qualität mit 3 Saaten über 25.005 Schritte im Modus
„nächster“.

## Fazit

Der fertige Schalter GANZ=12 im Stand des Hauptbaums ist über den ganzen Lauf Byte für Byte derselbe wie GANZ=10 in
der Schlussprobe. Die Ergebnisse R und Q gelten damit unverändert für ihn, und zwar gemessen, nicht nur angenommen.
Zusätzlich gemessen und damit belegt sind zwei Wege, die die Schlussprobe nicht sah: Mitteln mit 2 Workern und
Fortsetzen aus einem V8-Checkpoint. Beide sind ebenfalls rundungsunabhängig.

Nicht beantwortet sind mehr als 2 Worker über viele Segmente, andere Modellgrößen und die Karte. Weitere Messungen
lohnen hier nicht mehr: Das nächste offene Stück ist der Kartenauftrag, kein weiterer CPU-Lauf.
