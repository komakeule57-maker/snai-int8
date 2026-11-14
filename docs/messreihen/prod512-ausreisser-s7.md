# snai/prod512-ausreisser-s7

```text
snai/prod512-ausreisser-s7 - ausgewertet, begonnen 2026-09-15, angelegt 2026-10-21, zuletzt 2026-10-21 19:29
Frage: War der Eichpunkt s7 des Produktivlaufs prod512 ein Ausreißer (registerverzerrter Gewinn auf Olympia-Ergebnistabellen, Runs-Test geklumpt), der den Exponenten des Potenzgesetzes zu Unrecht von 0,2635 auf 0,214 drückte?
Kriterium (nachgetragen, Beleg: Kriterium wörtlich (2026-09-16 11:11, vor s8 bis s12). Zwischentest bei s8 (2026-09-17) verglich beide vorab feststehenden Fits gegen die Messung, ist aber nicht das vorab benannte Kriterium.):
  Nachprüfung bei s12: bleibt alpha nahe 0,21, war s7 kein Ausreißer; kehrt es Richtung 0,26 zurück, war es einer und die Abbruchgrenze liegt wieder bei s24.
Baut auf: snai/prod512-fitwahl-s6
Darauf baut: snai/prod512-klumpung-s14
Rezepte:
  r183 [2026-10-21] numpy-Gittersuche wie snai/prod512-fitwahl-s6; Bootstrap 300 Züge mit SE 0,0061; gepaarter Fenstervergleich php diagnose/compare_full_paired.php prod512_s6 prod512_s7
      quelltext: rechner-a:~/Projekte/snai_edge_int8_lora/diagnose/compare_full_paired.php (heute md5 ad32369b…, Stand 2026-09-16 nicht festgehalten); Fitskript k. A.
      parameter: Fits s1..s6, s1..s7, s1..s8, s1..s12 auf HELDOUT_FULL_LOSS (erste 64 Fenster)
      seed: deterministisch; Bootstrap-Saat k. A.
      rechner: rechner-a
      logs: k. A.
Messwerte (Groesse | Wert | Arm | Start | n):
 ; s7 aus rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/server_heldout/heldout_full_i8_prod512_s7.jsonl abgelesen; alpha s1..s7 am 2026-10-21 nachgerechnet (0,2139)
  m2255 HELDOUT_FULL_LOSS s7 | 4,119265 | prod512 s7 |  | 64
  m2256 Prognose s7 aus Fit s1..s6 | 4,1398 | Fit s1..s6 |  | 6
  m2257 Abweichung s7 | -3,4 Sigma | prod512 s7 |  | 64
  m2258 Runs-Test s6->s7 | -3,98 Sigma (geklumpt) | prod512 |  | 64
  m2259 Mittelwert / Median Gewinn s6->s7 | -0,0700 / -0,0467 | prod512 |  | 64
  m2260 alpha Fit s1..s7 | 0,2139 | prod512 |  | 7
 ; Prognosen 4,0990 / 4,0853 am 2026-10-21 nachgerechnet
  m2261 HELDOUT_FULL_LOSS s8 | 4,095831 | prod512 s8 |  | 64
  m2262 Zwischentest s8 Fit s1..s6 | -0,52 Sigma (auf der Linie) | prod512 s8 |  | 64
  m2263 Zwischentest s8 Fit s1..s7 | +1,72 Sigma | prod512 s8 |  | 64
 ; s12 aus server_heldout abgelesen; Prognosen und alpha s1..s12 am 2026-10-21 nachgerechnet (3,9691 / 3,9603 / 0,2272); Bootstrap nicht nachgerechnet
  m2264 HELDOUT_FULL_LOSS s12 | 3,961843 | prod512 s12 |  | 64
  m2265 Prognose s12 Fit s1..s6 (alpha 0,2635) | 3,9836, -3,57 Sigma | prod512 s12 |  | 64
  m2266 Prognose s12 Fit s1..s7 (alpha 0,2140) | 3,9603, +0,26 Sigma | prod512 s12 |  | 64
  m2267 Prognose s12 Fit s1..s8 (alpha 0,2342) | 3,9690, -1,18 Sigma | prod512 s12 |  | 64
  m2268 alpha Fit s1..s12 | 0,2272 | prod512 |  | 12
  m2269 alpha Bootstrap 90-%-Band | 0,1955 bis 0,2528 | prod512 |  | 300
  m2270 Mittlere Abweichung Fit s1..s6 auf s9..s12 | -2,42 Sigma | prod512 |  | 4
Ergebnis e167 [2026-10-21 19:29]: verfehlt
  Fazit: s7 war kein Ausreißer: alpha blieb bei s12 mit 0,227 nahe 0,21, das Band 0,196 bis 0,253 schließt 0,2635 aus, und der alte Fit lag an allen vier Punkten s9..s12 zu hoch. Die Ausreißer-These aus dem geklumpten Runs-Test war damit falsch, und der Zwischentest bei s8, der sie scheinbar bestätigte, war selbst ein Einzelpunkt. Folge für die Planung: Abbruchgrenze s26 statt s24 und ein niedrigerer Endwert. Die allgemeine Lehre gilt in beide Richtungen: ein geklumpter Punkt ist verdächtig, aber kein Beweis; erst weitere Punkte entscheiden.
  Offen: Bootstrap und Runs-Test nicht nachgerechnet. Der frühere Schluss ('s7 war also der Ausreisser') ist durch dieses Ergebnis widerlegt, in den Arbeitsnotizen aber nicht als veraltet markiert.
Chronik:
  2026-10-21 19:29 angelegt (Nachtrag: Kriterium wörtlich (2026-09-16 11:11, vor s8 bis s12). Zwischentest bei s8 (2026-09-17) verglich beide vorab feststehenden Fits gegen die Messung, ist aber nicht das vorab benannte Kriterium.)
  2026-10-21 19:29 Rezept r183
  2026-10-21 19:29 Status geplant -> laeuft (Rezept r183)
  2026-10-21 19:29 Messwerte m2255-m2260
  2026-10-21 19:29 Messwerte m2261-m2263
  2026-10-21 19:29 Messwerte m2264-m2270
  2026-10-21 19:29 Ergebnis e167: verfehlt
  2026-10-21 19:29 Status laeuft -> ausgewertet (Ergebnis e167)
```
