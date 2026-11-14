# snai/textknirps-b256-budget

```text
snai/textknirps-b256-budget - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 14:36
Frage: Holt der Text-Knirps 256/16 x 2 mit doppeltem Budget (40 Segmente = 12,8 Mio Zeichen, Abklingen über 199.760 Schritte) deutlich mehr, liegt die Grenze also am Budget statt an der Kapazität?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-b:~/snai_pruef/knirps_gpu/text/kriterien.txt, Abschnitt BREITE 256 MIT DOPPELTEM BUDGET (geschrieben 2026-10-14 07:45, vor dem Start 08:36:57).):
  Zelle 256/16 x 2, dieselben Genesis-Dateien wie die Zelle fall, Arme tx_d256h16_b2_s1-3; Segmente 20-39 neu aus textprobe_20mb.txt geschnitten, jedes Zeichen einmal. Einzige Änderung: Budget samt Abklinglänge (SNAI_LR_DECAY_STEPS=199760). Bei Segment 19 nur beobachten. Urteil: Mittel b2 (Segment 39) gegen Mittel fall (Segment 19, 1,723); 10-%-Regel, daneben Überlappung. Lesart vorab: Gewinn >= 0,083 nats = doppeltes Budget bringt so viel wie doppelte Breite; Gewinn < 0,083 und überlappungsfrei = Budget hilft, aber weniger als Breite; überlappend = nicht unterscheidbar. Saaten 3, alle einig, sonst saatabhängig.
Plan: rechner-b:~/snai_pruef/knirps_gpu/text/kriterien.txt
Baut auf: snai/textknirps-b256-tiefe
Rezepte:
  r123 [2026-10-21] cd ~/snai_pruef/knirps_gpu && ./reihe_t256b2.sh (je Lauf SNAI_LR_DECAY_STEPS=199760 nice -n 5 ./lauf_bd_text.sh proj_t tx_d256h16_b2_s<S> 0.001 40 factory/checkpoints/text_gen_d256h16_s<S>.snai)
      quelltext: rechner-b:~/snai_pruef/knirps_gpu/proj_t (Kopie von rechner-a knirps/proj, gain_guard_enabled=0, libcortex.so md5 563780e32333); lauf_bd_text.sh 529acb0c0481; mess_text.php wie rechner-a; N-Gramme ngram_bd.json (NFKC-Tokenisierung)
      parameter: 256/16 x 2, LR 0,001 -> 0,0001 über 40 Segmente, Warmup 500, WD 0,1, nice 5
      seed: Genesis text_gen_d256h16_s1..3
      rechner: rechner-b (CPU, 1 Thread je Lauf)
      logs: rechner-b:~/snai_pruef/knirps_gpu/log/proj_t/tx_d256h16_b2_s*
      notiz: 2026-10-14 08:36-15:09 (T256B2_FERTIG). Prüfung beim Nachtrag: Endwerte, Segment 19, Kontext, Rot-Probe aus Rohdaten nachgerechnet. Fehlerkanal laut Eintrag leer; 0 NET2NET in den Trainingslogs (grep).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/knirps_gpu/log/proj_t/tx_d256h16_b2_s*.mess.jsonl/.kontext.jsonl (nachgerechnet)
  m1299 Held-out-Loss Segment 39 (n = Fenster je Lauf) | 1,676 / 1,696 / 1,697 | 256x2 b2 | 1/2/3 | 300
  m1300 Mittel Segment 39 | 1,690 | 256x2 b2 | 1-3 | 3
  m1301 Vergleich Mittel fall Segment 19 | 1,723 | 256x2 fall | 1-3 | 3
  m1302 Gewinn (3 gegen 3) | 0,033 nats (-1,9 %) | b2 gegen fall
  m1303 Beobachtung Segment 19 (LR dort noch hoch) | 1,977 / 2,017 / 1,967 | 256x2 b2 | 1/2/3 | 300
  m1304 Kontext-Sonde k=8 / alles (n = Ziele) | 1,701-1,733 / 1,642-1,676 | 256x2 b2 | 1-3 | 400
  m1305 Rot-Probe Loss | 4,73-4,80 | 256x2 b2 | 1-3 | 300
Ergebnis e115 [2026-10-21 14:36]: gleichstand
  Fazit: Doppeltes Budget bringt bei 256 x 2 nur 0,033 nats (1,9 %, Gleichstand), überlappungsfrei; nach der vorab notierten Lesart hilft Budget also, aber deutlich weniger als die letzte Breitenverdopplung (0,083). In diesem Bereich ist Breite der stärkere Hebel als Text. Nicht beantwortet: ob 128 x 2 mit doppeltem Budget ebenso viel gewönne; erst das trennte Budget von Kapazität.
  Offen: 128 x 2 mit doppeltem Budget (als Option notiert, nicht gefahren).
  Datei: rechner-b:~/snai_pruef/knirps_gpu/text/kriterien.txt
Chronik:
  2026-10-21 14:36 angelegt (Nachtrag: Kriterium aus rechner-b:~/snai_pruef/knirps_gpu/text/kriterien.txt, Abschnitt BREITE 256 MIT DOPPELTEM BUDGET (geschrieben 2026-10-14 07:45, vor dem Start 08:36:57).)
  2026-10-21 14:36 Rezept r123
  2026-10-21 14:36 Status geplant -> laeuft (Rezept r123)
  2026-10-21 14:36 Messwerte m1299-m1305
  2026-10-21 14:36 Ergebnis e115: gleichstand
  2026-10-21 14:36 Status laeuft -> ausgewertet (Ergebnis e115)
```
