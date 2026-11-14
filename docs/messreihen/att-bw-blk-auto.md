# snai/att-bw-blk-auto

```text
snai/att-bw-blk-auto - ausgewertet, angelegt 2026-11-10, zuletzt 2026-11-10 04:34
Frage: Schaltet die Schwelle (Blockpfad nur ab Breite 256, Entscheidung 09.11. „Ab breite 256“) richtig, und bleibt alles bytegleich?
Kriterium (festgelegt 2026-11-10 04:23, vor dem ersten Messwert):
  Arbeitskopie ~/snai_pruef/threads/par11: patch_par11.py a24feee8 auf Hauptbaum 433383ad -> 5dbb54fe, Lib 57683872. SNAI_I8_ATT_BW_BLK: fehlt = AUTO (ab hiddenDim 256), 0 aus, AN immer an, ROTB = Rot-Probe, folgt der Schwelle. Meldung „[ATT-BWB] Breite d: Blockpfad an/aus“.
(1) prod512b (Breite 512) AUTO text.txt n4 und n1: md5 6f49622c/78355d24, Meldung „Breite 512: Blockpfad an“. ROTB n4: md5 = 5d281170 (ROTB-Wert aus e588).
(2) g256_c512 AUTO n4: md5 = 482098e1/61e0ea99 (par10), Meldung „an“; ROTB: md5 ≠ 482098e1 (Schwelle schaltet ein).
(3) g128_c512 AUTO n4: md5 = 6e358822/f96d6e6f (par10), Meldung „aus“; ROTB: md5 = 6e358822 (Pfad aus, Probe wirkt nicht, erwartet grün); AN: md5 = 6e358822, Meldung „an“.
Alle Teile erfüllt = Schwelle übernehmen. Fehlerkanal rc, .err.
Darauf baut: snai/silu-tab-hauptbaum
Rezepte:
  r654 [2026-11-10] setsid nohup ~/snai_pruef/threads/par11/reihe11.sh (p512_auto n4/n1, p512_rotb, g256_auto/rotb, g128_auto/rotb/an)
      quelltext: patch_par11.py a24feee8 -> cortex 5dbb54fe, Lib 57683872; arm.sh 6d2f09b6, reihe11.sh 9cbb2925; Modelle aus par10 (g128_c512 405b21bb, g256_c512 c49c77cd)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/par11/ergebnis.txt, log/
Messwerte (Groesse | Wert | Arm | Start | n):
  m9887 (1) prod512b AUTO n4 / n1 | 6f49622c/78355d24 beide | Meldung „Breite 512: Blockpfad an“
  m9888 (1) prod512b ROTB n4 | 5d281170/76a96850 | = ROTB-Wert aus e588
  m9889 (2) g256_c512 AUTO / ROTB | 482098e1 (= par10) / 98767682 (rot) | Meldung „Breite 256: Blockpfad an“
  m9890 (3) g128_c512 AUTO / ROTB / AN | 6e358822/f96d6e6f in allen drei (= par10) | Meldungen „aus“, „aus“, „an“ (AN)
  m9891 Fehlerkanal | 8/8 rc=0, .err leer
Ergebnis e594 [2026-11-10 04:34]: erfuellt
  Fazit: Die Schwelle schaltet wie entschieden: Breite 512 und 256 an, Breite 128 aus. Die Rot-Probe wirkt bei 256 und bleibt bei 128 wirkungslos, AN erzwingt den Pfad auch bei 128. Alles bytegleich zu den Vorwerten. Übernahme in den Hauptbaum (cortex 5dbb54fe).
Chronik:
  2026-11-10 04:23 angelegt
  2026-11-10 04:24 Rezept r654
  2026-11-10 04:24 Status geplant -> laeuft (Rezept r654)
  2026-11-10 04:34 Messwerte m9887-m9891
  2026-11-10 04:34 Ergebnis e594: erfuellt
  2026-11-10 04:34 Status laeuft -> ausgewertet (Ergebnis e594)
```
