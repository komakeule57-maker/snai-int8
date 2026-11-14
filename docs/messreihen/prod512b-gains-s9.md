# snai/prod512b-gains-s9

```text
snai/prod512b-gains-s9 - ausgewertet, angelegt 2026-11-03, zuletzt 2026-11-03 15:47
!! ohne Kriterium
Frage: Leidet der Produktivlauf prod512b (vserver, 512x6, ffn 2048, gebunden, ohne Eingangsfaktor) am Stand s9 unter toten RMS-Gains wie die 128er-Knirpse?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Baut auf: snai/ee-ffn-budget, snai/engine-emb-eingang
Darauf baut: snai/prod512b-gains-abkuehlen
Rezepte:
  r562 [2026-11-03] cd ~/Projekte/snai_edge_int8_lora && php -d memory_limit=1200M <scratchpad>/p512/gains_tot.php <scratchpad>/p512/prod512b_s9.snai (Kopie von vserver:~/snai_prod512b/factory/checkpoints/prod512b_s9.snai, md5 67359320). Tot = |g| < 0,05 je rms_ffn/rms_att, Definition wie lesen_tie2.php.
      quelltext: gains_tot.php (Abwandlung von clip/werkzeug/lesen_tie2.php mit Quantilen, Embedding-RMS stückweise), tensor_io.php aus dem Hauptbaum f5e4d82
      rechner: rechner-a (Auslesen), Stand von vserver
      notiz: Nur Lesen, kein Lauf. Rot-Probe: ee27 F27 s4 ergibt FFN L1-L3 100 % tot, wie konstruiert. Gegenprobe: E27 s11 ergibt 9,4 / 64,8 / 3,1, identisch mit lesen_tie2.php.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: gains_tot.php auf prod512b_s9.snai (adam_t 101879, flags 1 = gebunden)
  m8393 tote FFN-Gains L0-L5 | 0 / 0 / 0 / 0 / 0 / 0 % | prod512b s9
  m8394 tote Attention-Gains L0-L5 | 0 / 0 / 0 / 0 / 0 / 0 % | prod512b s9
  m8395 FFN-Gain Median L0-L5 | 1,12 / 1,29 / 1,08 / 1,05 / 1,18 / 1,34 | prod512b s9
  m8396 FFN-Gain 10-%-Quantil, kleinstes über die Schichten | 1,00 | prod512b s9
  m8397 Attention-Gain Median L0-L5 | 0,67 / 0,91 / 1,02 / 1,19 / 1,06 / 1,11 | prod512b s9
  m8398 g_final Median | 2,06 | prod512b s9
  m8399 RMS Embedding | 0,0371 | prod512b s9
  m8400 Rot-Probe F27 s4 FFN L1-L3 tot | 100 / 100 / 100 % | F27 | 4
  m8401 Gegenprobe E27 s11 FFN L1-L3 tot | 9,4 / 64,8 / 3,1 % | E27 | 11
Ergebnis e505 [2026-11-03 15:47]: beobachtung
  Fazit: prod512b hat am Stand s9 keine toten Gains, in keiner der 6 Schichten, weder FFN noch Attention. Alle FFN-Gains liegen bei 1,0 oder darüber, obwohl das Modell gebunden ist und ohne Eingangsfaktor rechnet. Das Gain-Sterben der 128er-Knirpse hat den Produktivlauf bis s9 nicht erreicht. Ein Neustart mit Eingangsfaktor ist dafür nicht nötig.
  Offen: Warum prod512b trotz Bindung nicht stirbt, ist nicht untersucht. Kandidaten (Deutung, nicht gemessen): Spitzen-LR 1e-4 statt 3e-3, andere Breite und Tiefe, anderes Rezept. Ob das Sterben in späteren Segmenten einsetzt, ist offen. Bei den Knirpsen kam es zum Teil erst spät. Nachsehen lässt es sich billig an jedem Segmentstand.
Chronik:
  2026-11-03 15:47 angelegt
  2026-11-03 15:47 Rezept r562
  2026-11-03 15:47 Status geplant -> laeuft (Rezept r562)
  2026-11-03 15:47 Messwerte m8393-m8401
  2026-11-03 15:47 Ergebnis e505: beobachtung
  2026-11-03 15:47 Status laeuft -> ausgewertet (Ergebnis e505)
```
