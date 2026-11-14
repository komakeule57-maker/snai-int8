# snai/merge-int8-zeit

```text
snai/merge-int8-zeit - ausgewertet, angelegt 2026-11-08, zuletzt 2026-11-08 07:42
Frage: Wie teuer ist merge_v6_models() (int8, reine PHP-Arrays: dequantize per pack/unpack, Mittel, Requantisierung) bei prod512b-Geometrie (512/6/8, vocab 8192), und lohnt der Nim-Umbau (libtensorutils int8-Weg) fuer spaeteren Schwarm-/Mehrarbeiter-Betrieb?
Kriterium (festgelegt 2026-11-08 07:39, vor dem ersten Messwert):
  Gemessen: Wanduhrzeit (hrtime) von merge_v6_models() mit N=2 (s10+s11) und N=3 (s5+s10+s11) echter prod512b-Staende, je 3 Wiederholungen, rechner-a, php 8.5 CLI, memory_limit 3072M; Speicherspitze memory_get_peak_usage(true) und VmHWM. Bezug Segmentzeit prod512b s12 = 2944 min. Nim-Umbau LOHNT, wenn bei N=2 der Median > 1 % der Segmentzeit (> 29,4 min) ODER die Speicherspitze > 1 GB. Sonst LOHNT NICHT (fuer diese Geometrie). Knapp (innerhalb 10 % einer Schwelle): nachmessen. Ausgabedatei wird auf Gueltigkeit geprueft (load_v6_model_full laedt sie, Geometrie gleich), sonst Messung ungueltig.
Darauf baut: snai/merge-int8-nim
Rezepte:
  r624 [2026-11-08] ~/snai_pruef/merge_zeit/lauf.sh: 3 Wiederholungen je von `php -d memory_limit=3072M mz.php out2.snai s10 s11` und `... out3.snai s5 s10 s11` (Staende aus ~/snai_pruef/frankreich/ckpt)
      quelltext: mz.php 45ee8559, lauf.sh 32772798, tensor_io.php 7b8552d3 (snai_edge_int8_lora, HEAD b3b9677 plus Arbeitsstand), PHP 8.5.10 NTS
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merge_zeit/mz.jsonl, mz.err
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: Quelle | rechner-a:~/snai_pruef/merge_zeit/mz.jsonl (6 Laeufe) und nach.jsonl (Nachmessung s5+s11), Fehlerkanal mz.err nur FERTIG
  m9512 Zeit N=2 s10+s11 Sekunden | 14,15 / 14,16 / 14,12 (Median 14,15) | N2 |  | 3
  m9513 Zeit N=3 s5+s10+s11 Sekunden | 17,61 / 17,71 / 17,69 (Median 17,69) | N3 |  | 3
  m9514 Anteil N=2 an Segmentzeit 2944 min | 0,008 % | N2 |  | 3
  m9515 PHP-Speicherspitze N=2 MB | 1080 (alle 3 gleich) | N2 |  | 3
  m9516 VmHWM N=2 MB | 1026 (alle 3 gleich) | N2 |  | 3
  m9517 PHP-Speicherspitze N=3 MB | 1416 | N3 |  | 3
  m9518 VmHWM N=3 MB | 1364 | N3 |  | 3
  m9519 Nachmessung N=2 s5+s11 | 13,89 s, PHP 1080 MB, VmHWM 1026 MB | N2 |  | 1
  m9520 Ausgabe gueltig und md5 je N gleich ueber Wiederholungen | 7/7 | alle |  | 7
  m9521 Rot-Probe Gueltigkeit (abgeschnittene Datei) | load_v6_model_full null |  |  | 1
Ergebnis e569 [2026-11-08 07:42]: erfuellt
  Fazit: Nach Wortlaut LOHNT (ODER-Kriterium), aber nur ueber den Speicher und KNAPP: N=2 braucht 1080 MB PHP-Spitze bzw. 1026 MB VmHWM gegen die Schwelle 1 GB (1024 MB: +5 % bzw. +0,2 %; Lesart 1000 MB: klar darueber). Die Nachmessung auf frischem Paar (s5+s11) gibt exakt dieselben Speicherwerte; der Speicher haengt an der Geometrie, nicht an den Daten, Nachmessen kann die Knappheit nicht aufloesen. Die Zeit ist kein Grund: 14 s fuer N=2 (0,008 % eines Segments), +3,5 s je weiteres Modell. Die erinnerte "erhebliche Performanceeinbusse" durch unpack gilt fuer int8 bei 512/6/8 NICHT. Speicher waechst um ~340 MB je Modell (N=3: 1,4 GB). Deutung, nicht gemessen: Der Speicher kommt vor allem daher, dass alle N Modelle vollstaendig dequantisiert gleichzeitig im Speicher liegen; tensorweises Streamen loeste das auch in PHP. Ein Nim-Umbau lohnt erst bei groesserer Geometrie (1024/4096) oder die Schwarm-Pipeline auf kleinen Geraeten.
  Offen: Groessere Geometrie (1024, 4096) nicht gemessen; Hochrechnung linear in den Parametern ist Annahme. Ob tensorweises Streamen in PHP den Speicher unter 1 GB bringt, ungeprueft.
Chronik:
  2026-11-08 07:39 angelegt
  2026-11-08 07:39 Rezept r624
  2026-11-08 07:39 Status geplant -> laeuft (Rezept r624)
  2026-11-08 07:42 Messwerte m9512-m9521
  2026-11-08 07:42 Ergebnis e569: erfuellt
  2026-11-08 07:42 Status laeuft -> ausgewertet (Ergebnis e569)
```
