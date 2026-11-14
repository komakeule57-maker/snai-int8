# snai/textknirps-rezept

```text
snai/textknirps-rezept - ausgewertet, begonnen 2026-10-13, angelegt 2026-10-21, zuletzt 2026-10-21 14:35
Frage: Text-Knirps 32/2/16: lag die Decke bei 2,15-2,22 am Rezept? Arm FALL (Cosinus 0,001 -> 0,0001 über den ganzen Lauf) und Arm LR4 (konstant 0,0001) gegen konstant 0,001.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/text/kriterien.txt, Abschnitt REZEPT-PROBE (2026-10-13, freigegeben, vor dem Start; Läufe ab 14:45:08).):
  Zelle 32/2/16, 2 Schichten, sonst wie der erste Durchgang (Vergleich Mittel 2,220). Arm FALL: SNAI_LR_DECAY_STEPS=99880; Arm LR4: LR konstant 0,0001. Je 3 Saaten, dieselben Genesis-Dateien, nicht gepaart. Kontrolle: FALL zeigt "[LR-Decay]" und am Ende LR nahe 0,0001; LR4 LR=0.0001000. Urteil: Endwert Segment 19, Mittel der 3 Saaten gegen 2,220; unter 10 % = Gleichstand; zusätzlich berichtet, ob die Saatbereiche überlappen. Daneben Rückschlag bei Segment 18, Kontext-Sonde, Lens. Lesart vorab: fällt FALL klar unter die 64er (2,152), hing die Decke am Rezept; LR4 schlechter hieße "nicht im Budget".
Plan: rechner-a:~/snai_pruef/knirps/text/kriterien.txt
Baut auf: snai/textknirps-breite64
Darauf baut: snai/textknirps-fall-groesse
Rezepte:
  r117 [2026-10-21] tx_d32h2_fall_s1..3 (SNAI_LR_DECAY_STEPS=99880 lr 0.001), tx_d32h2_lr4_s1..3 (lr 0.0001): cd ~/snai_pruef/knirps && text/lauf_text.sh <arm> <lr> 20 factory/checkpoints/text_gen_<zelle>_s<S>.snai  (darin je Segment: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 nice -n 10 php train_cluster.php factory/input/text_c64_seg<I>.txt <aus> 1 1 <vorstand> 3 <lr> 0.0001 1 0.1; Messung php text/mess_text.php <ck> text/heldout.txt text/ngram.json 300 0)
      quelltext: knirps/proj, libcortex.so md5 1c634106f31c (Lade-Wächter AN); text/lauf_text.sh 99ab6fb62520; text/mess_text.php 711d818750ae; text/mess_kontext.php 865b390c316f (md5 gekürzt)
      parameter: 32/2/16, 2 Schichten, ffn 128, ctx 64, zeichen-Vokabular, Warmup 500, WD 0,1, 20 Segmente; FALL Cosinus über adam_t auf 0,1 x LR; LR4 konstant 0,0001
      seed: Genesis text_gen_d32h2_s1..3 (dieselben wie snai/textknirps-zeichen)
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/text/tx_d32h2_fall_s{1,2,3}.log, .mess.jsonl, .kontext.jsonl, .lens.jsonl, _s<I>.train.log; rechner-a:~/.cache/snai_pruef/knirps/text/tx_d32h2_lr4_s{1,2,3}.log, .mess.jsonl, .kontext.jsonl, .lens.jsonl, _s<I>.train.log
      notiz: Läufe 2026-10-13 14:45-15:02. Prüfung beim Nachtrag: Alle Endwerte, Segment 17/18, Kontext aus Rohdaten nachgerechnet. Kein Wächtereingriff. Kontrolle [LR-Decay] nicht selbst nachgesehen (vorhanden).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/text/tx_d32h2_fall_s*, tx_d32h2_lr4_s*, tx_d32h2_s* .mess.jsonl/.kontext.jsonl (nachgerechnet)
  m1172 Held-out-Loss Segment 19 (n = Fenster je Lauf) | 2,058 / 2,038 / 2,053 | FALL | 1/2/3 | 300
  m1173 Held-out-Loss Segment 19 (n = Fenster je Lauf) | 2,234 / 2,225 / 2,235 | LR4 | 1/2/3 | 300
  m1174 Held-out-Loss Segment 19 (n = Fenster je Lauf) | 2,231 / 2,217 / 2,211 | konstant 0,001 | 1/2/3 | 300
  m1175 Mittel | 2,050 | FALL | 1-3 | 3
  m1176 Mittel | 2,231 | LR4 | 1-3 | 3
  m1177 Unterschied FALL gegen konstant 0,001 (3 gegen 3) | -7,7 % | FALL
  m1178 Unterschied LR4 gegen konstant 0,001 (3 gegen 3) | +0,5 % | LR4
  m1179 Abstand Saatbereiche FALL zu konstant (3 gegen 3) | 0,15 bei Streuung 0,02 (überlappungsfrei) | FALL
  m1180 Faktor FALL gegen Trigramm 2,234 | 0,92 (Schwelle 2,011 knapp nicht erreicht) | FALL | 1-3 | 3
  m1181 Rückschlag Segment 18 minus 17 | +0,12 bis +0,13 | FALL | 1-3 | 3
  m1182 Rückschlag Segment 18 minus 17 | +0,14 bis +0,17 | LR4 | 1-3 | 3
  m1183 Rückschlag Segment 18 minus 17 | +0,14 bis +0,19 | konstant 0,001 | 1-3 | 3
  m1184 Rang 0 Segment 19 % | 43,0-43,5 | FALL | 1-3 | 18900
  m1185 Kontext-Sonde k=8 / alles (n = Ziele) | 2,007-2,036 / 1,999-2,021 | FALL | 1-3 | 400
Ergebnis e108 [2026-10-21 14:35]: gleichstand
  Fazit: Nach der 10-%-Regel formal Gleichstand (FALL -7,7 %). Die vorab notierte Lesart greift aber: FALL liegt mit 2,050 klar unter beiden 64er-Zellen (2,152) und unter 32 x 4 Schichten, mit überlappungsfreien Saatbereichen. Die Decke der früheren Textläufe lag also am Rezept (konstante Rate), nicht an Breite oder Tiefe. Folge: alle weiteren Text- und Noten-Knirpse laufen mit fallender Rate; Größenvergleiche bei konstanter Rate (snai/textknirps-tiefe, snai/textknirps-breite64) sagen wenig über Kapazität. LR4 ist im Budget zu langsam, nicht schädlich.
  Offen: Ob noch mehr Budget oder eine andere Endrate hilft.
  Datei: rechner-a:~/snai_pruef/knirps/text/kriterien.txt
Chronik:
  2026-10-21 14:35 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/text/kriterien.txt, Abschnitt REZEPT-PROBE (2026-10-13, freigegeben, vor dem Start; Läufe ab 14:45:08).)
  2026-10-21 14:35 Rezept r117 (tx_d32h2_fall_s1..3 (SNAI_LR_DECAY_STEPS=99880 lr 0.001), tx_d32h2_lr4_s1..3 (lr 0.0001))
  2026-10-21 14:35 Status geplant -> laeuft (Rezept r117)
  2026-10-21 14:35 Messwerte m1172-m1185
  2026-10-21 14:35 Ergebnis e108: gleichstand
  2026-10-21 14:35 Status laeuft -> ausgewertet (Ergebnis e108)
```
