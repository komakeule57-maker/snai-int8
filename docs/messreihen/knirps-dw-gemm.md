# snai/knirps-dw-gemm

```text
snai/knirps-dw-gemm - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:31
Frage: Rechnet der blockweise Gewichtsgradient (snai_dw_rows_i8, Schalter SNAI_DW_GEMM) bitgleich zum alten axpy-Pfad, und wie viel Zeit spart er?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/schluss/knirps96/kriterien_dw.txt (laut Text nach dem Bau, VOR jedem Testergebnis, 2026-10-15 ~15:45). Sicherung vor der Uebernahme rechner-a:~/snai_pruef/dw/vor_dw_20261015.):
  Alle muessen gruen sein: T0 Neubau der unveraenderten Quelle -> Segment 0 md5 91dd45e5; T1 neue Bibliothek, Schalter aus -> 91dd45e5; T2 Schalter an -> 91dd45e5 und '[DW-GEMM]' im Log; T3 Kern-Einzeltest gegen naive int32-Referenz, 0 Abweichungen (AVX2 und Skalar); T4 weitere Formen gepaart md5-gleich (96x4, Breite 512, OMP 1 und 4); T5 Rot: falscher Kern -> T3 meldet Abweichungen und Modell nicht md5-gleich, ohne Variable keine '[DW-GEMM]'-Zeile. T6 Tempo (laut Datei 'Beobachtung mit Kriterium', in der Liste 'alle muessen gruen sein'): Schritte/s Segment 0 alt gegen neu; Gewinn ab 10 % gilt als Gewinn, darunter Gleichstand.
Baut auf: snai/knirps-zeitanteil
Rezepte:
  r74 [2026-10-21] python3 patch_dw.py <proj> (rechner-b proj_zeit), Lauf Segment 0 von gesch_d96h6L2_s1 mit SNAI_CORTEX_LIB=libcortex_dw.so [SNAI_DW_GEMM=1]; Baum-Gegenprobe rechner-b:~/snai_pruef/dw/baum; vserver ~/snai_engine_20261015
      quelltext: cortex.nim 7e8a0516 -> 185aff77, libcortex_dw.so 37c59045; Projektbaum danach cortex.nim 5a03730e -> libcortex.so 5ce8674e (vserver-Bau), alt d0a29c9e / 9897f516
      parameter: 96x2 ganzes Segment 0 (5.001 Schritte), 96x4 Segment 0, Breite 512/ffn 2048/ctx 512 Kurzlauf (123 Schritte), OMP 1 und 4 (263 Schritte)
      seed: Genesis 1
      rechner: rechner-b, vserver
      logs: rechner-b:~/snai_pruef/knirps_gpu/proj_zeit, rechner-b:~/snai_pruef/dw/baum
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/schluss/knirps96/kriterien_dw.txt (Ergebnisabschnitte), nicht nachgerechnet
  m747 T0 Neubau Segment 0 md5 | 91dd45e5 | alt | 1 | 5001
  m748 T1 Schalter aus md5 | 91dd45e5 | neu aus | 1 | 5001
  m749 T2 Schalter an md5 | 91dd45e5 | neu an | 1 | 5001
  m750 T3 Abweichungen Kern-Einzeltest | 0 | neu |  | 660
  m751 T4 OMP 1 / OMP 4 aus = an | 714f6df8 = 714f6df8 | neu | 1 | 263
  m752 T4 Breite 512 aus = an | 66f02a13 = 66f02a13 | neu | 1 | 123
  m753 T4 96x4 an = Original | f6efc996 | neu | 1 | 5001
  m754 T5 Rot-Kern Abweichungen | 32109, Modell 43163006 | Rot
  m755 T6 Kern 96x2 Segment 0 | 303,49 -> 293,52 s (-3,3 %) | alt/neu | 1 | 5001
  m756 T6 Breite 512 Kurzlauf | 198,83 -> 188,65 s (-5,1 %) | alt/neu | 1 | 123
  m757 T6 OMP 1 / OMP 4 Kurzlauf | -11,4 % / -2,8 % | alt/neu | 1 | 263
  m758 vserver alt / neu / neu aus md5 | 8fd54122 (= rechner-b) | alle | 1 | 372
  m759 vserver prod512b-Umstieg md5 | 54686838 = 54686838, 100,8 -> 84,0 s | alt/neu |  | 381
Ergebnis e71 [2026-10-21 14:31]: teilweise
  Fazit: Teilweise: T0-T5 erfuellt, T6 nicht. Der Block-GEMM fuer dW rechnet in allen geprueften Formen, Fadenzahlen und auf zwei Rechnern bitgleich, die Rot-Proben schlagen an. Das Tempo (T6, mit eigener 10-%-Schwelle) bleibt Gleichstand (-3 bis -5 %, nur OMP 1 -11 %). Der Umbau wurde trotzdem in den Projektbaum uebernommen ('3 % koennen bei grossen Modellen Tage ausmachen'), Vorgabe an, SNAI_DW_GEMM=0 = alter Pfad. Auf vserver lief der prod512b-Umstiegstest bitgleich; libcortex.so in ~/snai_prod512b wurde von Hand getauscht (wirksam ab Segment 2).
  Offen: Im prod512b-Aufbau (d512, 4 Faeden) nur der Umstiegstest mit 381 Schritten, nicht ein ganzes Segment.
  Datei: rechner-a:~/snai_pruef/schluss/knirps96/kriterien_dw.txt
Chronik:
  2026-10-21 14:30 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/schluss/knirps96/kriterien_dw.txt (laut Text nach dem Bau, VOR jedem Testergebnis, 2026-10-15 ~15:45). Sicherung vor der Uebernahme rechner-a:~/snai_pruef/dw/vor_dw_20261015.)
  2026-10-21 14:30 Rezept r74
  2026-10-21 14:30 Status geplant -> laeuft (Rezept r74)
  2026-10-21 14:30 Messwerte m747-m759
  2026-10-21 14:31 Ergebnis e71: teilweise
  2026-10-21 14:31 Status laeuft -> ausgewertet (Ergebnis e71)
```
