# snai/textknirps-fall-groesse

```text
snai/textknirps-fall-groesse - ausgewertet, begonnen 2026-10-13, angelegt 2026-10-21, zuletzt 2026-10-21 14:35
Frage: Zählt beim Text-Knirps die Modellgröße, sobald die Decke der konstanten Rate weg ist? Zellen 32/2 x 4 Schichten, 64/2 x 2 und 64/4 x 2, alle mit fallender Rate, gegen 32/2 x 2 fallend.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/text/kriterien.txt, Abschnitt GROESSENVERGLEICH MIT FALLENDER LERNRATE (2026-10-13 16:00, freigegeben, vor dem Start; Läufe ab 16:00:15 bzw. 16:47).):
  Je 3 Saaten, SNAI_LR_DECAY_STEPS=99880, sonst wie bisher, dieselben Genesis-Dateien wie bei konstanter Rate; rechner-a. Vergleichswert 32/2 x 2 fallend, Mittel 2,050. Urteil: Endwert Segment 19, Mittel der 3 Saaten gegen 2,050; unter 10 % = Gleichstand; daneben, ob die Saatbereiche überlappen. Gegen Trigramm (2,234): schlägt unter 2,011. Lesart vorab: liegen die größeren Zellen mit nicht überlappenden Bereichen unter 2,050, zählt Größe; liegen sie im Bereich, ist die Größe auch mit diesem Rezept nicht der Engpass.
Plan: rechner-a:~/snai_pruef/knirps/text/kriterien.txt
Baut auf: snai/textknirps-rezept
Darauf baut: snai/textknirps-b128, snai/multistack-tiefe-64
Rezepte:
  r118 [2026-10-21] tx_d64h2_fall_s1..3, tx_d64h4_fall_s1..3, tx_d32h2L4_fall_s1..3: cd ~/snai_pruef/knirps && text/lauf_text.sh <arm> <lr> 20 factory/checkpoints/text_gen_<zelle>_s<S>.snai  (darin je Segment: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 nice -n 10 php train_cluster.php factory/input/text_c64_seg<I>.txt <aus> 1 1 <vorstand> 3 <lr> 0.0001 1 0.1; Messung php text/mess_text.php <ck> text/heldout.txt text/ngram.json 300 0)
      quelltext: knirps/proj, libcortex.so md5 1c634106f31c (Lade-Wächter AN); text/lauf_text.sh 99ab6fb62520; text/mess_text.php 711d818750ae; text/mess_kontext.php 865b390c316f (md5 gekürzt)
      parameter: Rezept FALL (LR 0,001 -> 0,0001, SNAI_LR_DECAY_STEPS=99880), Warmup 500, WD 0,1, 20 Segmente, zeichen-Vokabular, ctx 64; Lade-Wächter an
      seed: Genesis text_gen_d64h2_s*, text_gen_d64h4_s*, text_gen_d32h2L4_s*
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/text/tx_d64h2_fall_s{1,2,3}.log, .mess.jsonl, .kontext.jsonl, .lens.jsonl, _s<I>.train.log; rechner-a:~/.cache/snai_pruef/knirps/text/tx_d64h4_fall_s{1,2,3}.log, .mess.jsonl, .kontext.jsonl, .lens.jsonl, _s<I>.train.log; rechner-a:~/.cache/snai_pruef/knirps/text/tx_d32h2L4_fall_s{1,2,3}.log, .mess.jsonl, .kontext.jsonl, .lens.jsonl, _s<I>.train.log
      notiz: Läufe 2026-10-13 16:00-17:23. tx_d32h2L4_fall_s1: Lade-Wächter griff in Segment 3, 6, 10 ein, nicht werten. Prüfung beim Nachtrag: Alle Endwerte, Rot-Proben und Kontextwerte nachgerechnet. Wächter: tx_d32h2L4_fall_s1 3 Trainingslogs und 6 Zeilen im Messprotokoll betroffen; ein späterer Befund schließt Saat 1 korrekt aus.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/text/tx_*_fall_s*.mess.jsonl/.kontext.jsonl (nachgerechnet)
  m1186 Held-out-Loss Segment 19 (n = Fenster je Lauf) | 1,933 / 1,930 / 1,934 | 64/2 fall | 1/2/3 | 300
  m1187 Held-out-Loss Segment 19 (n = Fenster je Lauf) | 1,903 / 1,899 / 1,899 | 64/4 fall | 1/2/3 | 300
  m1188 Held-out-Loss Segment 19 (Saat 1 vom Wächter verändert) (n = Fenster je Lauf) | 2,036 / 2,010 / 2,017 | 32/2 x 4 fall | 1/2/3 | 300
  m1189 Mittel | 1,932 | 64/2 fall | 1-3 | 3
  m1190 Mittel | 1,900 | 64/4 fall | 1-3 | 3
  m1191 Mittel 2 saubere Saaten | 2,014 | 32/2 x 4 fall | 2-3 | 2
  m1192 Unterschied gegen 2,050 (3 gegen 3) | -5,8 % | 64/2 fall
  m1193 Unterschied gegen 2,050 (3 gegen 3) | -7,3 % | 64/4 fall
  m1194 Unterschied gegen 2,050 (2 gegen 3) | -1,8 % | 32/2 x 4 fall
  m1195 Faktor gegen Trigramm 2,234 | 0,865 / 0,850 | 64/2 / 64/4 fall | 1-3 | 3
  m1196 Rang 0 Segment 19 % | 46,4-46,6 / 47,2-47,4 | 64/2 / 64/4 fall | 1-3 | 18900
  m1197 Rot-Probe Loss | 4,77-4,93 | alle drei Zellen | 1-3 | 300
  m1198 Kontext-Sonde k=8 (n = Ziele) | 1,95-2,00 / 1,90-1,93 / 1,87-1,88 | 32x4 / 64/2 / 64/4 fall | 1-3 | 400
Ergebnis e109 [2026-10-21 14:35]: gleichstand
  Fazit: Formal Gleichstand nach der 10-%-Regel (64er 5,8 % und 7,3 % besser). Nach der vorab notierten Lesart zählt die Breite mit fallender Rate aber: beide 64er liegen überlappungsfrei unter 2,050 (Abstand 0,10-0,15 bei 0,005 Streuung) und schlagen als erste Zellen der Reihe das Trigramm. Doppelte Tiefe bringt dagegen nur 1,8 % (zwei saubere Saaten, Beobachtung). Bei Breite 64 sind 4 Köpfe etwas besser als 2 (1,7 %, überlappungsfrei). Für die nächste Entscheidung: Breite vor Tiefe weiterverfolgen; das tat snai/textknirps-b128.
  Offen: 32/2 x 4 fallend hat nur zwei saubere Saaten; Trigramm-Schwelle dort nicht entschieden (Saat 2 knapp darunter, Saat 3 darüber).
  Datei: rechner-a:~/snai_pruef/knirps/text/kriterien.txt
Chronik:
  2026-10-21 14:35 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/text/kriterien.txt, Abschnitt GROESSENVERGLEICH MIT FALLENDER LERNRATE (2026-10-13 16:00, freigegeben, vor dem Start; Läufe ab 16:00:15 bzw. 16:47).)
  2026-10-21 14:35 Rezept r118 (tx_d64h2_fall_s1..3, tx_d64h4_fall_s1..3, tx_d32h2L4_fall_s1..3)
  2026-10-21 14:35 Status geplant -> laeuft (Rezept r118)
  2026-10-21 14:35 Messwerte m1186-m1198
  2026-10-21 14:35 Ergebnis e109: gleichstand
  2026-10-21 14:35 Status laeuft -> ausgewertet (Ergebnis e109)
```
