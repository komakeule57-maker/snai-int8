# snai/merge-int8-nim

```text
snai/merge-int8-nim - ausgewertet, angelegt 2026-11-08, zuletzt 2026-11-08 07:59
Frage: Ist der Nim-Weg fuer INT8 (libtensorutils: snai_i8_dequant/quant/merge, snai_f32_avg; merge_v6_models tensorweise gestreamt) bytegleich zur PHP-Fassung und spart er Speicher ohne Zeitverlust?
Kriterium (festgelegt 2026-11-08 07:56, vor dem ersten Messwert):
  Bezug: unveraenderter tensor_io.php 7b8552d3 (Sicherung ~/snai_pruef/merge_nim/orig). GUELTIG nur wenn alle gleich: T1 md5 der Mischdatei neu = alt fuer gebunden N=2 (prod512b s10+s11, alt ba4a239d), N=3 (s5+s10+s11, alt 2c9fde32), N=2 frisch (s5+s11, alt 053bf628), ungebunden V6 N=2 (stell U_s5 t1000+t3000, alt frisch gerechnet). T2 md5 ueber alle Tensoren/Skalen von load_v6_model_full neu = alt (s11, U_s5 t1000). T3 quantize Nim === PHP (Daten und Skalen) auf allen Float-Bloecken (w, m, v) von s11 und U_s5 t1000. T4 Rueckfall SNAI_TENSORUTILS_PHP=1 im neuen Baum = alt (N=2 gebunden). Rot-Probe vorab: Lib mit drei kleinen Rechenabweichungen (Merge ohne float32-Rundung, Quant mit float32-Skala, Dequant in float32) muss T1, T2, T3 rot machen. LEISTUNG (nur wenn gueltig): erfuellt, wenn Speicherspitze (PHP-Peak) N=2 <= 270 MB (25 % der alten 1080 MB) UND Zeit N=2 nicht mehr als 10 % ueber alt (<= 15,6 s), je 3 Wiederholungen Median, rechner-a.
Baut auf: snai/merge-int8-zeit
Rezepte:
  r625 [2026-11-08] ~/snai_pruef/merge_nim/pruef.sh (Rot-Lib, Bezug orig/tensor_io.php, neuer Baum, Rueckfall SNAI_TENSORUTILS_PHP=1); Ausgabe pruef.out/pruef.err
      quelltext: neu: tensor_io.php fe86844d, tensor_utils_ffi.php 7a17fba7, snai_tensor_utils.nim 8d9b7d87, libtensorutils.so 036f7832 (nicht committet); alt: orig/ tensor_io 7b8552d3, ffi d665c2e7, nim 76b298ae, lib 4f55f13f; Rot-Lib b5d53d27; Pruefskripte pruef.sh 3347a485, merge_lauf 0b6c1cf8, lade_lauf 93740944, quant_lauf 9fda9993
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merge_nim/pruef.out, pruef.err
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: Quelle | rechner-a:~/snai_pruef/merge_nim/pruef.out und rot2.out, Fehlerkanal pruef.err 0 Byte
  m9522 Rot T1 Merge N=2 gebunden md5 | 98617732 (Bezug ba4a239d) ROT | rot |  | 1
  m9523 Rot T2 Laden s11, Probe 1 (Dequant in float32) | fc6888c8 = Bezug, GRUEN, Probe untauglich (float32-Produkt mathematisch gleich) | rot |  | 1
  m9524 Rot T2 Laden s11, Probe 2 (Dequant x (1+1e-7)) | cd00cf92 (Bezug fc6888c8) ROT | rot2 |  | 1
  m9525 Rot T3 Quant s11 gleich | 1/153 ROT | rot |  | 1
  m9526 T2 Laden s11 neu = alt | fc6888c8 = fc6888c8 | neu |  | 1
  m9527 T2 Laden U_s5 t1000 neu = alt | 0e995be0 = 0e995be0 | neu |  | 1
  m9528 T3 Quant gleich s11 | 153/153 | neu |  | 1
  m9529 T3 Quant gleich U_s5 t1000 | 105/105 | neu |  | 1
  m9530 T1 Merge ungebunden U_s5 t1000+t3000 neu = alt | 0ec9684b = 0ec9684b | neu |  | 1
  m9531 T1 Merge N=2 s10+s11 md5 | ba4a239d in 3/3 | neu |  | 3
  m9532 T1 Merge N=3 s5+s10+s11 md5 | 2c9fde32 in 3/3 | neu |  | 3
  m9533 T1 Merge N=2 frisch s5+s11 md5 | 053bf628 | neu |  | 1
  m9534 T4 Rueckfall SNAI_TENSORUTILS_PHP=1 N=2 md5 | ba4a239d (17,23 s, 1080 MB) | rueckfall |  | 1
  m9535 Zeit N=2 Sekunden | 0,61 / 0,92 / 1,08 (Median 0,92; alt 14,15) | neu |  | 3
  m9536 Zeit N=3 Sekunden | 1,11 / 1,21 / 1,27 (Median 1,21; alt 17,69) | neu |  | 3
  m9537 PHP-Speicherspitze N=2 / N=3 MB | 98 / 130 (alt 1080 / 1416) | neu |  | 3
  m9538 VmHWM N=2 / N=3 MB | 135 / 167 (alt 1026 / 1364) | neu |  | 3
  m9539 Speicher load_v6_model_full s11 PHP-Peak MB | 354 neu, 376 alt | neu |  | 1
Ergebnis e570 [2026-11-08 07:59]: erfuellt
  Fazit: Gueltig: T1-T4 alle bytegleich zum unveraenderten Original (gebunden N=2/N=3/frisch, ungebunden V6, Laden, Quantisieren auf 258 Bloecken, Rueckfall). Rot-Proben fuer T1, T2 (zweite Probe) und T3 rot gesehen; die erste T2-Probe war untauglich (float32-Produkt aus int8 und float32-Skala ist mathematisch dasselbe), offengelegt. Leistung klar erfuellt: Merge N=2 0,9 s statt 14 s (15x), Speicher 98 MB statt 1080 MB (11x weniger), N=3 1,2 s / 130 MB; jedes weitere Modell kostet nur noch ~32 MB statt ~340 MB. Damit ist der Merge fuer grosse Modelle und die Schwarm-Pipeline kein Hindernis mehr. NICHT geaendert: load_v6_model_full haelt weiter das ganze Modell als float32 im Speicher (354 MB bei s11) - Verbraucher wie royal_distillery::upscale_cortex und convert_* bleiben bei grossen Modellen speicherhungrig; das waere der naechste Ansatzpunkt. Aenderung liegt nur im Hauptbaum auf rechner-a, nicht committet.
  Offen: Commit und Verteilung auf vserver/rechner-b (Lib neu bauen) stehen aus. Groessere Geometrie nicht gemessen (Streaming-Speicher waechst mit groesstem Tensor, nicht mit Modellzahl x Modellgroesse). Lade-/Upscale-Pfade weiter vollstaendig im Speicher.
Chronik:
  2026-11-08 07:56 angelegt
  2026-11-08 07:57 Rezept r625
  2026-11-08 07:57 Status geplant -> laeuft (Rezept r625)
  2026-11-08 07:59 Messwerte m9522-m9539
  2026-11-08 07:59 Ergebnis e570: erfuellt
  2026-11-08 07:59 Status laeuft -> ausgewertet (Ergebnis e570)
```
