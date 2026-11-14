# snai/textknirps-b128

```text
snai/textknirps-b128 - ausgewertet, begonnen 2026-10-13, angelegt 2026-10-21, zuletzt 2026-10-21 14:36
Frage: Setzt sich beim Text-Knirps mit fallender Rate der Breitengewinn (32 -> 64: 5,8-7,3 %) bis Breite 128 fort? 128/8/16 gegen den Anker 64/4/16 auf rechner-b.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/text/kriterien.txt bzw. rechner-b:~/snai_pruef/knirps_gpu/text/kriterien.txt, Abschnitt BREITE 128 (geschrieben 2026-10-13 18:25 laut Text, vor dem Start 18:23:32 laut reihe.log - Minutenangabe im Text gerundet).):
  Zellen je 3 Saaten, 2 Schichten, ctx 64, zeichen-Vokabular, ffn 4 x Breite, Ganzzahl-Stack gebunden, Kopfbreite 16 (Breite und Kopfzahl ändern sich gemeinsam). Rezept LR 0,001 -> 0,0001 (SNAI_LR_DECAY_STEPS=99880), Warmup 500, WD 0,1, 1 Arbeiter, Revival aus, 20 Segmente, Lade-Wächter AUS (proj_t). Messung Held-out 300 Fenster, Endwert Segment 19; Vergleich ngram_bd.json (Trigramm geschlagen unter 2,0205). Urteil: Mittel 128/8 gegen Mittel Anker 64/4 auf rechner-b; unter 10 % = Gleichstand, daneben ob die Saatbereiche überlappen; nicht gepaart. Nur innerhalb rechner-b vergleichen (andere Tokenisierung als rechner-a).
Plan: rechner-b:~/snai_pruef/knirps_gpu/text/kriterien.txt
Baut auf: snai/textknirps-fall-groesse
Darauf baut: snai/textknirps-b256-tiefe
Rezepte:
  r121 [2026-10-21] cd ~/snai_pruef/knirps_gpu && ./reihe_t128.sh  (je Lauf: SNAI_LR_DECAY_STEPS=99880 nice -n 5 ./lauf_bd_text.sh proj_t tx_<d128h8|d64h4>_fall_s<S> 0.001 20 factory/checkpoints/text_gen_<zelle>_s<S>.snai)
      quelltext: rechner-b:~/snai_pruef/knirps_gpu/proj_t (Kopie von rechner-a knirps/proj, gain_guard_enabled=0, libcortex.so md5 563780e32333); lauf_bd_text.sh 529acb0c0481; mess_text.php wie rechner-a; N-Gramme ngram_bd.json (NFKC-Tokenisierung)
      parameter: 128/8/16 und 64/4/16, 2 Schichten, Rezept FALL, 20 Segmente
      seed: Genesis text_gen_d128h8_s1..3 (auf rechner-b erzeugt), text_gen_d64h4_s1..3 (von rechner-a kopiert)
      rechner: rechner-b (CPU, 1 Thread je Lauf)
      logs: rechner-b:~/snai_pruef/knirps_gpu/log/proj_t/tx_d128h8_fall_s*, tx_d64h4_fall_s* (.log, .mess.jsonl, .kontext.jsonl)
      notiz: 2026-10-13 18:23-19:28 (reihe.log: T128_FERTIG). Prüfung beim Nachtrag: Endwerte, Rot-Proben, Kontextwerte aus den Rohdaten auf rechner-b nachgerechnet. 0 NET2NET-GUARD in allen Trainingslogs (grep).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/knirps_gpu/log/proj_t/tx_d{64h4,128h8}_fall_s*.mess.jsonl/.kontext.jsonl (nachgerechnet)
  m1277 Held-out-Loss Segment 19 (n = Fenster je Lauf) | 1,909 / 1,923 / 1,912 | 64/4 fall (Anker) | 1/2/3 | 300
  m1278 Held-out-Loss Segment 19 (n = Fenster je Lauf) | 1,810 / 1,805 / 1,803 | 128/8 fall | 1/2/3 | 300
  m1279 Mittel | 1,915 | 64/4 fall (Anker) | 1-3 | 3
  m1280 Mittel | 1,806 | 128/8 fall | 1-3 | 3
  m1281 Unterschied 128 gegen 64 (3 gegen 3) | -5,7 % | 128/8 gegen 64/4
  m1282 Vergleich Uni / Bi / Tri (rechner-b) (n = Fenster) | 3,381 / 2,601 / 2,245 | n-Gramm |  | 300
  m1283 Rot-Probe Loss | 4,64-4,92 | beide Zellen | 1-3 | 300
  m1284 Kontext-Sonde k=8 / k=32 (n = Ziele) | 1,937-1,951 / 1,913-1,931 | 64/4 fall | 1-3 | 400
  m1285 Kontext-Sonde k=8 / k=32 (n = Ziele) | 1,863-1,885 / 1,827-1,854 | 128/8 fall | 1-3 | 400
  m1286 Wächter-Meldungen (Trainings- und Messprotokolle) | 0 | alle 6 Läufe | 1-3
Ergebnis e113 [2026-10-21 14:36]: gleichstand
  Fazit: Formal Gleichstand (128 ist 5,7 % besser), aber überlappungsfrei (Abstand 0,09 bei 0,007-0,014 Streuung) und beide schlagen das Trigramm: der Breitengewinn setzt sich bis 128 fort, je Verdopplung etwa gleich groß (32->64 5,8-7,3 %, 64->128 5,7 %). Der Anker auf rechner-b liegt rund 1 % neben dem 64/4 auf rechner-a, Tokenisierung und Wächter-aus machen also wenig aus. Für die nächste Entscheidung war das der Anlass, 256 und Tiefe 4 zu prüfen (snai/textknirps-b256-tiefe).
  Offen: Ob breitere Modelle mehr Text brauchen (ein Budget).
  Datei: rechner-b:~/snai_pruef/knirps_gpu/text/kriterien.txt
Chronik:
  2026-10-21 14:36 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/text/kriterien.txt bzw. rechner-b:~/snai_pruef/knirps_gpu/text/kriterien.txt, Abschnitt BREITE 128 (geschrieben 2026-10-13 18:25 laut Text, vor dem Start 18:23:32 laut reihe.log - Minutenangabe im Text gerundet).)
  2026-10-21 14:36 Rezept r121
  2026-10-21 14:36 Status geplant -> laeuft (Rezept r121)
  2026-10-21 14:36 Messwerte m1277-m1286
  2026-10-21 14:36 Ergebnis e113: gleichstand
  2026-10-21 14:36 Status laeuft -> ausgewertet (Ergebnis e113)
```
