# snai/att-bw-blk-schwelle

```text
snai/att-bw-blk-schwelle - ausgewertet, angelegt 2026-11-09, zuletzt 2026-11-09 20:07
Frage: Ab welcher Modellgröße und Kontextlänge macht der Blockpfad (SNAI_I8_ATT_BW_BLK) den Trainingsschritt im Hauptbaum schneller, und wo ist er langsamer? Anlass: Evo e(engine-attbw-blk) 13 % langsamer bei hs 8/ctx 512/OMP 1. Vorgabe 09.11.: „mach vorsichtshalber die kurze Messung und dann entscheiden wir ab welcher Größe der Schalter greift“.
Kriterium (festgelegt 2026-11-09 19:07, vor dem ersten Messwert):
  Arbeitskopie ~/snai_pruef/threads/par10, Lib 515b80ee (Hauptbaum 84dbf37), eine Lib je Projekt, Stellrad SNAI_I8_ATT_BW_BLK (A = 0, B = an). Frische Genesis-Modelle (init_base.php, Vocab 8192, Kopfgröße 64 wie suggest_num_heads im Hauptbaum, .heads gesetzt): g128_c256 L4 (2 Köpfe), g128_c512 L4, g256_c512 L4 (4 Köpfe), g256_c1024 L4, g512_c512 L6 (8 Köpfe). Bezug prod512b ctx 1024: e588 0,748. Daten text.txt, 1 Epoche (Schritte = Token/ctx), n4 wie Produktion.
Je Größe 8 Blöcke A/B, AB/BA, ms/Schritt [Bilanz], gepaartes 95-%-t-Intervall auf log(B/A) (ausw_geo.py efa0c03e: alle Läufe einer Größe müssen dieselbe md5+lossmd5 haben, sonst Abbruch; Probe: auf par8-Daten 0,7475 wie e588, mit verfälschter md5 Abbruch).
Urteil je Größe: Intervall ganz unter 1 = SCHNELLER, ganz über 1 = LANGSAMER, sonst NICHT AUFGELÖST. Nur berichtet: Median der Blockverhältnisse.
Über die Schwelle wird anhand dieser Tabelle entschieden. Was sich ändert: Breite, Kontext, Köpfe und (bei g512) Schichten gemeinsam; die Zellen sind eine Leiter, kein Gitter. Grenze: rechner-a, n4, Kopfgröße 64; andere Fadenzahlen nicht gemessen.
Rezepte:
  r653 [2026-11-09] setsid nohup ~/snai_pruef/threads/par10/reihe10.sh (je Größe <g>q<b>_aus/_blk, 8 Blöcke AB/BA, n4); Auswertung python3 ausw_geo.py ergebnis.txt <g>q aus blk "BLK=0)" "16: an"
      quelltext: Lib 515b80ee (84dbf37); Modelle init_base.php: g128_c256 46d9ac3f, g128_c512 405b21bb, g256_c512 c49c77cd, g256_c1024 1d442261, g512_c512 b3ac513f (.heads = dim/64); arm.sh d962a1a5, reihe10.sh f9e5e218, ausw_geo.py efa0c03e
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/par10/ergebnis.txt, log/
Messwerte (Groesse | Wert | Arm | Start | n):
  m9842 g128_c256 (2 Köpfe) blk/aus n4 | 1,0063 [0,9686-1,0455] nicht aufgelöst | Median 1,0109, B schneller 3/8, Streuung je Block 0,046; 163,6 / 164,5 ms
  m9843 g128_c512 (2 Köpfe) blk/aus n4 | 1,0665 [0,9961-1,1417] nicht aufgelöst | Median 1,0548, B schneller 2/8, Streuung 0,082; 286,9 / 306,7 ms
  m9844 g256_c512 (4 Köpfe) blk/aus n4 | 0,9773 [0,9184-1,0399] nicht aufgelöst | Median 0,9543, B schneller 6/8, Streuung 0,075; 557,5 / 545,7 ms
  m9845 g256_c1024 (4 Köpfe) blk/aus n4 | 0,8770 [0,7619-1,0094] nicht aufgelöst | Median 0,8571, B schneller 6/8, Streuung 0,169 (Einzelläufe 950-1511 ms in beiden Armen); 1281,1 / 1128,3 ms
  m9846 g512_c512 (8 Köpfe, L6) blk/aus n4 | 0,9364 [0,9221-0,9509] SCHNELLER | Median 0,9333, B schneller 8/8, Streuung 0,019; 1671,1 / 1565,0 ms
  m9847 Gültigkeit | 80/80 rc=0, .err leer, je Größe alle 16 Läufe gleiche md5+lossmd5 (ausw_geo-Pflicht) | Streuung je Block bei den kleinen Größen 4,6-17 % statt ~2 % bei prod512b: Auflösung reicht dort nicht
Ergebnis e591 [2026-11-09 20:07]: teilweise
  Fazit: Nur eine Größe ist aufgelöst: Ab Breite 512 (8 Köpfe) ist der Blockpfad schon bei ctx 512 schneller (0,936), bei ctx 1024 0,748 (e588). Darunter streuen die Läufe auf rechner-a bei 4 Fäden zu stark (4,6-17 % je Block), 8 Blöcke lösen nichts auf. Die Tendenz, nicht belegt: Breite 128 eher gleich bis etwas langsamer (Median 1,01 bzw. 1,05, B nur 2-3 von 8 schneller), Breite 256 eher schneller (Median 0,95 bzw. 0,86, 6 von 8). Für Evos Befund „13 % langsamer“ (hs 8) gibt es bei Kopfgröße 64 keine Entsprechung, ein Verlust dieser Größe kommt nicht vor. Die Schwelle wird gesondert entschieden; belegt ist nur „an ab Breite 512“.
Chronik:
  2026-11-09 19:07 angelegt
  2026-11-09 19:08 Rezept r653
  2026-11-09 19:08 Status geplant -> laeuft (Rezept r653)
  2026-11-09 20:07 Messwerte m9842-m9847
  2026-11-09 20:07 Ergebnis e591: teilweise
  2026-11-09 20:07 Status laeuft -> ausgewertet (Ergebnis e591)
```
