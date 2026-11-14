# snai/textknirps-b256-tiefe

```text
snai/textknirps-b256-tiefe - ausgewertet, begonnen 2026-10-13, angelegt 2026-10-21, zuletzt 2026-10-21 14:36
Frage: Text-Knirps mit fallender Rate auf rechner-b: (a) setzt sich der Breitengewinn über 128 hinaus fort und wird er je Verdopplung kleiner (256/16 x 2)? (b) Bringt bei Breite 128 doppelte Tiefe (128/8 x 4) mehr oder weniger als doppelte Breite?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-b:~/snai_pruef/knirps_gpu/text/kriterien.txt, Abschnitt BREITE 256 UND TIEFE 4 (geschrieben 2026-10-13 19:30 laut Text, vor dem Start 19:29:13 laut reihe.log).):
  Zellen je 3 Saaten, Kopfbreite 16, ffn 4 x Breite: 256/16 x 2 und 128/8 x 4; Vergleichszelle 128/8 x 2 aus snai/textknirps-b128 (gleicher Rechner, gleiche Kopie proj_t). Rezept unverändert (LR 0,001 -> 0,0001 über 99.880 Schritte, Warmup 500, WD 0,1, 20 Segmente), Revival aus, Lade-Wächter aus. Urteil: Zellenmittel gegen Mittel 128/8 x 2; unter 10 % = Gleichstand (heißt nicht "kein Effekt"; daneben Überlappung; überlappungsfrei und gleichgerichtet = "kleiner, aber in allen Saaten vorhandener Unterschied"). Gewinn je Breitenverdopplung als Reihe berichtet. (b): 256 x 2 gegen 128 x 4 ebenfalls nach der 10-%-Regel. Kein Vergleich bei gleicher Parameterzahl (256x2 ~4x, 128x4 ~2x Blockparameter).
Plan: rechner-b:~/snai_pruef/knirps_gpu/text/kriterien.txt
Baut auf: snai/textknirps-b128
Darauf baut: snai/textknirps-b256-budget
Rezepte:
  r122 [2026-10-21] cd ~/snai_pruef/knirps_gpu && ./reihe_t256.sh (wartet auf T128_FERTIG; je Lauf SNAI_LR_DECAY_STEPS=99880 nice -n 5 ./lauf_bd_text.sh proj_t tx_<d256h16|d128h8L4>_fall_s<S> 0.001 20 factory/checkpoints/text_gen_<zelle>_s<S>.snai); Fortsetzung nach Pause mit reihe_t256b.sh (2026-10-14 04:33)
      quelltext: rechner-b:~/snai_pruef/knirps_gpu/proj_t (Kopie von rechner-a knirps/proj, gain_guard_enabled=0, libcortex.so md5 563780e32333); lauf_bd_text.sh 529acb0c0481; mess_text.php wie rechner-a; N-Gramme ngram_bd.json (NFKC-Tokenisierung)
      parameter: 256/16 x 2 und 128/8 x 4, Rezept FALL, 20 Segmente
      seed: Genesis text_gen_d256h16_s1..3, text_gen_d128h8L4_s1..3 (init_base, Saat 1-3)
      rechner: rechner-b (CPU, 1 Thread je Lauf)
      logs: rechner-b:~/snai_pruef/knirps_gpu/log/proj_t/tx_d256h16_fall_s*, tx_d128h8L4_fall_s*
      notiz: 2026-10-13 19:29 bis 2026-10-14 07:22 (T256B_FERTIG); zeitweise angehalten für eine Tempomessung. Prüfung beim Nachtrag: Alle Endwerte und Kontextdifferenzen aus Rohdaten nachgerechnet. 0 Wächtermeldungen.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/knirps_gpu/log/proj_t/tx_d256h16_fall_s*, tx_d128h8L4_fall_s*, tx_d128h8_fall_s* .mess.jsonl/.kontext.jsonl (nachgerechnet)
  m1287 Held-out-Loss Segment 19 (n = Fenster je Lauf) | 1,716 / 1,720 / 1,733 | 256/16 x 2 fall | 1/2/3 | 300
  m1288 Held-out-Loss Segment 19 (n = Fenster je Lauf) | 1,787 / 1,783 / 1,783 | 128/8 x 4 fall | 1/2/3 | 300
  m1289 Mittel | 1,723 | 256/16 x 2 | 1-3 | 3
  m1290 Mittel | 1,784 | 128/8 x 4 | 1-3 | 3
  m1291 Vergleich Mittel 128/8 x 2 | 1,806 | 128/8 x 2 | 1-3 | 3
  m1292 Unterschied 256x2 gegen 128x2 (3 gegen 3) | -4,6 % | (a)
  m1293 Unterschied 128x4 gegen 128x2 (3 gegen 3) | -1,2 % | (b)
  m1294 Unterschied 256x2 gegen 128x4 (3 gegen 3) | -3,4 % | (b)
  m1295 Gewinn je Breitenverdopplung (nats) (Zellmittel) | 0,109 (64->128) / 0,083 (128->256) | Reihe rechner-b
  m1296 Kontext k8 minus alles (n = Ziele) | 0,031-0,037 | 128/8 x 2 | 1-3 | 400
  m1297 Kontext k8 minus alles (n = Ziele) | 0,040-0,056 | 256x2 und 128x4 | 1-3 | 400
  m1298 Rot-Probe Loss | 4,66-4,86 | beide Zellen | 1-3 | 300
Ergebnis e114 [2026-10-21 14:36]: gleichstand
  Fazit: Alle drei Vergleiche sind nach der 10-%-Regel Gleichstand, aber jeweils überlappungsfrei, also kleine, in allen Saaten vorhandene Unterschiede: Breite 256 schlägt 128 (-4,6 %), der Gewinn je Breitenverdopplung schrumpft (0,109 -> 0,083 nats), und eine Verdopplung der Breite bringt mehr als eine der Tiefe. Ob die schrumpfenden Gewinne an der Kapazität oder am festen Budget (6,4 Mio Zeichen) liegen, beantwortet die Reihe nicht; das prüfte snai/textknirps-b256-budget.
  Offen: Kapazität gegen Budget; kein Vergleich bei gleicher Parameterzahl.
  Datei: rechner-b:~/snai_pruef/knirps_gpu/text/kriterien.txt
Chronik:
  2026-10-21 14:36 angelegt (Nachtrag: Kriterium aus rechner-b:~/snai_pruef/knirps_gpu/text/kriterien.txt, Abschnitt BREITE 256 UND TIEFE 4 (geschrieben 2026-10-13 19:30 laut Text, vor dem Start 19:29:13 laut reihe.log).)
  2026-10-21 14:36 Rezept r122
  2026-10-21 14:36 Status geplant -> laeuft (Rezept r122)
  2026-10-21 14:36 Messwerte m1287-m1298
  2026-10-21 14:36 Ergebnis e114: gleichstand
  2026-10-21 14:36 Status laeuft -> ausgewertet (Ergebnis e114)
```
