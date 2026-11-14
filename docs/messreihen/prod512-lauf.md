# snai/prod512-lauf

```text
snai/prod512-lauf - ausgewertet, begonnen 2026-09-03, angelegt 2026-10-21, zuletzt 2026-10-21 19:28
Frage: Wie weit sinkt der Held-out-Verlust des ersten Produktivlaufs dim 512 (prod512: 512/6/8, ctx 1024, int8 voll, gebunden, 2 Arbeiter, LR 0,001 konstant, ab Genesis über 40 Segmente), und ab wann ist der Gewinn je Segment so klein, dass der Rest Rechenzeit ohne Gegenwert ist?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/Projekte/snai_edge_int8_lora/docs/PRODUKTIVLAUF_DIM512.md Z. 276 (Abschnitt 8, Phase 5); per Datei erst ab 2026-09-06 belegt (Sicherung PRODUKTIVLAUF_DIM512.md.bak_pre_dauerfix_20260906, mtime 2026-09-06 13:32), Lauf seit 2026-09-03; das Kriterium betrifft die Abflachung, die erst später messbar war. Nachträglich präzisiert ohne Wortlautänderung: Pegel gegen den Fit oder über >= 3 Segmente geglättet prüfen (2026-09-23); ab 2026-09-28 an der verteilten Held-out-Reihe.):
  Abbruchkriterium: flacht die Held-out-Kurve auf < 0,01 nats je Segment ab, ist der Rest Rechenzeit ohne Gegenwert (docs/PRODUKTIVLAUF_DIM512.md, Abschnitt 8, Phase 5). Maßgeblich ist HELDOUT_FULL_LOSS aus eval_held_out_full_i8.php (64 Fenster, factory/holdout_prod), nicht die Ein-Fenster-Zahl im Segmentlog.
Plan: rechner-a:~/Projekte/snai_edge_int8_lora/docs/PRODUKTIVLAUF_DIM512.md
Darauf baut: snai/prod512-fitwahl-s6, snai/prod512-kappung, snai/prod512-referenz-inferenz, snai/dim512-drift-verdaechtige, snai/prod512b-lauf
Rezepte:
  r176 [2026-10-21] Laptop s0-s4: SNAI_TRAIN_MODE=pretrain SNAI_TIE_EMBEDDINGS=1 SNAI_INT8_FULL=1 SNAI_FORCE_CPU=1 OMP_NUM_THREADS=3 php train_cluster.php factory/segments_prod/psegNN.txt factory/checkpoints/prod512_sNN.snai 2 1 <Basis> 3 0.001 ; danach SNAI_FORCE_CPU=1 OMP_NUM_THREADS=6 php eval_held_out_full_i8.php <Ausgabe> factory/holdout_prod/ auto 64
      quelltext: run_prod512.sh md5 2c35e7f3f4ce1017c9a87359b9b0d491 (mtime 2026-09-03 14:28:33, unverändert seit Start); libcortex.so vom 2026-09-02 21:56:15 laut lauf.log; Stand von train_cluster.php/train_worker.php/cortex.nim zur Laufzeit nicht festgehalten (heutige md5 sind spätere Fassungen)
      parameter: Geometrie 512/6/8, ffn 2048, Vokabular 8192 (altes Vokabular e5f04510), ctx 1024, gebunden (SNAI_V7), int8 voll; 2 Arbeiter mit Merge je Segment, 1 Epoche je Segment, LR 0,001 konstant (kein Warmup, kein Abklingen), WD 0 (argv 9 = 0), Dropout/Label-Smoothing 0; 40 Segmente pseg00..pseg39 à ~38-40 MB
      seed: Genesis prod512_genesis.snai (327.235.612 Bytes); Start-Offset per Darwin-Patch aus Host-Entropie, also nicht wiederholbar festgelegt
      rechner: rechner-a (Laptop, Ryzen 5 5500U), Segmente s0-s4
      logs: rechner-a:~/.cache/prod512/lauf.log und s0.log..s5.log
  r177 [2026-10-21] Server s5-s20: SNAI_TRAIN_MODE=pretrain SNAI_TIE_EMBEDDINGS=1 SNAI_INT8_FULL=1 SNAI_FORCE_CPU=1 OMP_NUM_THREADS=2 php train_cluster.php "$IN" "$O" 2 1 "$B" 3 0.001 ; Held-out: SNAI_FORCE_CPU=1 OMP_NUM_THREADS=2 php eval_held_out_full_i8.php "$O" factory/holdout_prod/ auto 64
      quelltext: run_prod512_server.sh md5 5d872bba1c42a3fa1091b0107b3bcfcc (Laptop-Kopie, mtime 2026-09-08 17:34); libcortex.so vom 2026-09-02, ab Segment s13 die FTZ-Bibliothek vom 2026-09-24 (Konstruktor; Ergebnis bitgleich); Korpus pseg09..pseg39 am 2026-09-16 im Lauf gegen SFT-bereinigte Fassung getauscht
      parameter: wie Laptop-Arm; Dienst snai-train (System-Unit), 2 Arbeiter à 2 Threads
      seed: wie Laptop-Arm
      rechner: vserver (Xeon E5-2699 v4, 4 Kerne), Segmente s5-s20; abgebrochen 2026-10-09 in Segment 21
      logs: vserver:~/.cache/prod512/ ist seit 2026-10-09 leer, lauf.log und sN.log dort nicht mehr vorhanden; Held-out-jsonl s5-s19 als Kopie in rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/server_heldout/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/heldout_full_i8_prod512_s0..s4.jsonl und rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/server_heldout/heldout_full_i8_prod512_s5..s19.jsonl (je die Zeile mit 64 Fenstern; s5/s11 tragen dahinter Probeläufe mit 40/4/2 Fenstern); nachgelesen 2026-10-21, alle Werte gleich den früher festgehaltenen
  m2177 HELDOUT_FULL_LOSS (erste 64 Fenster) | 7,264797 | prod512 s0 |  | 64
  m2178 HELDOUT_FULL_LOSS (erste 64 Fenster) | 4,927107 | prod512 s1 |  | 64
  m2179 HELDOUT_FULL_LOSS (erste 64 Fenster) | 4,612463 | prod512 s2 |  | 64
  m2180 HELDOUT_FULL_LOSS (erste 64 Fenster) | 4,431453 | prod512 s3 |  | 64
  m2181 HELDOUT_FULL_LOSS (erste 64 Fenster) | 4,307818 | prod512 s4 |  | 64
  m2182 HELDOUT_FULL_LOSS (erste 64 Fenster) | 4,262638 | prod512 s5 |  | 64
  m2183 HELDOUT_FULL_LOSS (erste 64 Fenster) | 4,189261 | prod512 s6 |  | 64
  m2184 HELDOUT_FULL_LOSS (erste 64 Fenster) | 4,119265 | prod512 s7 |  | 64
  m2185 HELDOUT_FULL_LOSS (erste 64 Fenster) | 4,095831 | prod512 s8 |  | 64
  m2186 HELDOUT_FULL_LOSS (erste 64 Fenster) | 4,055196 | prod512 s9 |  | 64
  m2187 HELDOUT_FULL_LOSS (erste 64 Fenster) | 4,012438 | prod512 s10 |  | 64
  m2188 HELDOUT_FULL_LOSS (erste 64 Fenster) | 4,000745 | prod512 s11 |  | 64
  m2189 HELDOUT_FULL_LOSS (erste 64 Fenster) | 3,961843 | prod512 s12 |  | 64
  m2190 HELDOUT_FULL_LOSS (erste 64 Fenster) | 3,960001 | prod512 s13 |  | 64
  m2191 HELDOUT_FULL_LOSS (erste 64 Fenster) | 3,905523 | prod512 s14 |  | 64
  m2192 HELDOUT_FULL_LOSS (erste 64 Fenster) | 3,884105 | prod512 s15 |  | 64
  m2193 HELDOUT_FULL_LOSS (erste 64 Fenster) | 3,881820 | prod512 s16 |  | 64
  m2194 HELDOUT_FULL_LOSS (erste 64 Fenster) | 3,867582 | prod512 s17 |  | 64
  m2195 HELDOUT_FULL_LOSS (erste 64 Fenster) | 3,862776 | prod512 s18 |  | 64
  m2196 HELDOUT_FULL_LOSS (erste 64 Fenster) | 3,845170 | prod512 s19 |  | 64
 , nicht nachgerechnet (Server-Log gelöscht, keine lokale jsonl)
  m2197 HELDOUT_FULL_LOSS (erste 64 Fenster) | 3,858 | prod512 s20 |  | 64
  Quelle: rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/heldout_full_i8_prod512_sN_verteilt.jsonl, nachgelesen 2026-10-21
  m2198 Held-out verteilt (64 gleichmäßig verteilte Fenster) | 4,965501 | prod512 s1 |  | 64
  m2199 Held-out verteilt (64 gleichmäßig verteilte Fenster) | 4,659226 | prod512 s2 |  | 64
  m2200 Held-out verteilt (64 gleichmäßig verteilte Fenster) | 4,503300 | prod512 s3 |  | 64
  m2201 Held-out verteilt (64 gleichmäßig verteilte Fenster) | 4,392537 | prod512 s4 |  | 64
  m2202 Held-out verteilt (64 gleichmäßig verteilte Fenster) | 4,333884 | prod512 s5 |  | 64
  m2203 Held-out verteilt (64 gleichmäßig verteilte Fenster) | 4,272665 | prod512 s6 |  | 64
  m2204 Held-out verteilt (64 gleichmäßig verteilte Fenster) | 4,224028 | prod512 s7 |  | 64
  m2205 Held-out verteilt (64 gleichmäßig verteilte Fenster) | 4,184122 | prod512 s8 |  | 64
  m2206 Held-out verteilt (64 gleichmäßig verteilte Fenster) | 4,150849 | prod512 s9 |  | 64
  m2207 Held-out verteilt (64 gleichmäßig verteilte Fenster) | 4,115342 | prod512 s10 |  | 64
  m2208 Held-out verteilt (64 gleichmäßig verteilte Fenster) | 4,085834 | prod512 s11 |  | 64
  m2209 Held-out verteilt (64 gleichmäßig verteilte Fenster) | 4,066383 | prod512 s12 |  | 64
  m2210 Held-out verteilt (64 gleichmäßig verteilte Fenster) | 4,043557 | prod512 s13 |  | 64
  m2211 Held-out verteilt (64 gleichmäßig verteilte Fenster) | 4,013914 | prod512 s14 |  | 64
  m2212 Held-out verteilt (64 gleichmäßig verteilte Fenster) | 3,989556 | prod512 s15 |  | 64
  m2213 Held-out verteilt (64 gleichmäßig verteilte Fenster) | 3,980391 | prod512 s16 |  | 64
  m2214 Held-out verteilt (64 gleichmäßig verteilte Fenster) | 3,963135 | prod512 s17 |  | 64
  m2215 Held-out verteilt (64 gleichmäßig verteilte Fenster) | 3,950658 | prod512 s18 |  | 64
  m2216 Held-out verteilt (64 gleichmäßig verteilte Fenster) | 3,937708 | prod512 s19 |  | 64
  Quelle: rechner-a:~/Projekte/snai_edge_int8_lora/diagnose/heldout_verteilt_fit.py (md5 246a7663…), am 2026-10-21 neu gelaufen, Ausgabe
  m2217 Zuwachs verteilt s15->s16 | 0,0092 | prod512 |  | 64
  m2218 Zuwachs verteilt s16->s17 | 0,0173 | prod512 |  | 64
  m2219 Zuwachs verteilt s17->s18 | 0,0125 | prod512 |  | 64
  m2220 Zuwachs verteilt s18->s19 | 0,0129 | prod512 |  | 64
  m2221 Fit verteilt s1..s19 a / b / alpha | 2,6393 / 2,3215 / 0,1974 | prod512 |  | 19
  m2222 Prognose Zuwachs < 0,01 nats ab | s25 (verteilt), s26 (alte Reihe) | prod512 |  | 19
  m2223 Prognose verteilt s39 | 3,7657 | prod512 |  | 19
  Quelle: rechner-a:~/.cache/prod512/lauf.log (s0-s5); Takt s19, nicht nachgerechnet
  m2224 Segmentdauer s0 / s1 / s3 / s4 (Laptop) | 1648 / 1687 / 1578 / 1547 min | prod512 |  | 1
  m2225 Segmentdauer s5 (erstes auf dem Server) | 2504 min | prod512 |  | 1
  m2226 Takt s19 | 27,56 s je Schritt | prod512 |  | 1
Ergebnis e165 [2026-10-21 19:28]: keine_aussage
  Fazit: Das Abbruchkriterium wurde nie erreicht: der Lauf wurde am 2026-10-09 in Segment 21 angehalten, weil die Attention seit Segment 0 gesättigt war und der Attention-Rückwärtspfad einen Fehler hatte (ATTFIX; Befund in snai/kopier-prod512-attention), nicht weil die Kurve flach war. Bis s19 folgt der Held-out sauber einem Potenzgesetz (verteilt 3,938, Prognose für das Kriterium s25), der Lauf hätte also nach eigener Messlatte noch rund sechs Segmente Gewinn gebracht. Für den Neustart prod512b heißt das: die Kurve des alten Laufs taugt nur als Formvorbild, nicht als Vergleichsmaßstab (anderes Vokabular, anderer Prüfsatz). Ob ein Modell mit gesunder Attention bei gleichem Budget weiter kommt, beantwortet diese Reihe nicht.
  Offen: s20 nur als notierte Zahl (3,858); Server-Logs der Segmente s6-s20 gelöscht, Segmentdauern und Takte nur aus den Arbeitsnotizen. Quelltextstand je Segment nicht festgehalten. Lauf abgebrochen 2026-10-09, Nachfolger snai/prod512b-lauf.
  Datei: rechner-a:~/Projekte/snai_edge_int8_lora/docs/PRODUKTIVLAUF_DIM512.md
Chronik (juengste 8 von 11, voll=True zeigt alle):
  2026-10-21 19:28 Rezept r177 (Server s5-s20)
  2026-10-21 19:28 Messwerte m2177-m2196
  2026-10-21 19:28 Messwerte m2197
  2026-10-21 19:28 Messwerte m2198-m2216
  2026-10-21 19:28 Messwerte m2217-m2223
  2026-10-21 19:28 Messwerte m2224-m2226
  2026-10-21 19:28 Ergebnis e165: keine_aussage
  2026-10-21 19:28 Status laeuft -> ausgewertet (Ergebnis e165)
```
