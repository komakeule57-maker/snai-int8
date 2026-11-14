# snai/textknirps-tiefe

```text
snai/textknirps-tiefe - ausgewertet, begonnen 2026-10-13, angelegt 2026-10-21, zuletzt 2026-10-21 14:33
Frage: Text-Knirps 32/2/16: bringen vier Schichten statt zwei bei sonst gleichem Rezept (konstante LR 0,001, 20 Segmente, zeichenweise) einen besseren Held-out-Loss?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/text/kriterien.txt, Abschnitt VIER SCHICHTEN (2026-10-13, vor dem Start; erste Läufe 13:01:50).):
  EIN Stellrad Schichten 2 -> 4, sonst alles gleich (gleiche Segmentdateien und Reihenfolge, Held-out, 300 Fenster, 3 Saaten), nicht gepaart (zwei unabhängige Stichproben zu 3). Urteil: Endwert Segment 19, Mittel der 3 Saaten gegen das Mittel der 2-Schicht-Läufe (2,220); unter 10 % Unterschied = Gleichstand. Gegen Bi-/Trigramm wie snai/textknirps-zeichen. Daneben berichtet: Wert nach Segment 17 und Kontext-Sonde.
Plan: rechner-a:~/snai_pruef/knirps/text/kriterien.txt
Baut auf: snai/textknirps-zeichen
Darauf baut: snai/textknirps-lens, snai/textknirps-breite64
Rezepte:
  r103 [2026-10-21] tx_d32h2L4_s1..3: cd ~/snai_pruef/knirps && text/lauf_text.sh <arm> <lr> 20 factory/checkpoints/text_gen_<zelle>_s<S>.snai  (darin je Segment: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 nice -n 10 php train_cluster.php factory/input/text_c64_seg<I>.txt <aus> 1 1 <vorstand> 3 <lr> 0.0001 1 0.1; Messung php text/mess_text.php <ck> text/heldout.txt text/ngram.json 300 0)
      quelltext: knirps/proj, libcortex.so md5 1c634106f31c (Lade-Wächter AN); text/lauf_text.sh 99ab6fb62520; text/mess_text.php 711d818750ae; text/mess_kontext.php 865b390c316f (md5 gekürzt)
      parameter: wie snai/textknirps-zeichen, aber 4 Schichten (32/2/16, ffn 128); LR 0,001 konstant, Warmup 500, WD 0,1, Revival aus, Lade-Wächter AN
      seed: Genesis text_gen_d32h2L4_s1..3
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/text/tx_d32h2L4_s{1,2,3}.log, .mess.jsonl, .kontext.jsonl, .lens.jsonl, _s<I>.train.log
      notiz: Läufe 2026-10-13 13:01-13:33. In tx_d32h2L4_s1 griff der Lade-Wächter (NET2NET-GUARD, L2.rms_ffn) an den Segmentgrenzen 3, 6, 9, 12, 16, 19 ins Training ein und auch in die Messung. Prüfung beim Nachtrag: Endwerte, Segment 17, Rot-Probe, Kontext nachgerechnet. NICHT im früheren Befund: In tx_d32h2L4_s1 stehen 6 Wächtermeldungen in den Trainingslogs (Segmente 3, 6, 9, 12, 16, 19) und 12 Meldungszeilen im Messprotokoll; erst ein späterer Befund nahm Saat 1 heraus. Ohne Saat 1: 2,168 statt 2,174, Urteil unverändert Gleichstand. Arbeitsblatt blatt.jsonl Thema floatpaar-messgeraet, Befund 89: Wächter greift im Text-Gitter in der Zelle Breite 32, 2 Köpfe, 4 Schichten - deckt sich mit dem Fund zu tx_d32h2L4_s1.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/text/tx_d32h2L4_s{1,2,3}.mess.jsonl, .kontext.jsonl (nachgerechnet); Wächter: grep NET2NET in _s<I>.train.log und tx_d32h2L4_s1.log
  m995 Held-out-Loss Segment 19 (vom Wächter verändert, nicht werten) (n = Fenster) | 2,186 | tx_d32h2L4 | 1 | 300
  m996 Held-out-Loss Segment 19 (n = Fenster) | 2,161 | tx_d32h2L4 | 2 | 300
  m997 Held-out-Loss Segment 19 (n = Fenster) | 2,174 | tx_d32h2L4 | 3 | 300
  m998 Mittel 3 Saaten (wie damals berichtet) | 2,174 | tx_d32h2L4 | 1-3 | 3
  m999 Mittel 2 saubere Saaten | 2,168 | tx_d32h2L4 | 2-3 | 2
  m1000 Vergleich Mittel 2 Schichten | 2,220 | tx_d32h2 | 1-3 | 3
  m1001 Unterschied zu 2 Schichten (saubere Saaten) (2 gegen 3) | -2,4 % | tx_d32h2L4 gegen tx_d32h2
  m1002 Held-out-Loss Segment 17 (n = Fenster) | 2,152 / 2,139 / 2,143 | tx_d32h2L4 | 1/2/3 | 300
  m1003 Rang 0 Segment 19 % | 39,9 / 41,0 / 40,0 | tx_d32h2L4 | 1/2/3 | 18900
  m1004 Rot-Probe Loss (n = Fenster) | 4,666 / 4,715 / 4,776 | tx_d32h2L4 | 1/2/3 | 300
  m1005 Kontext-Sonde k=8 / alles (n = Ziele) | 2,097-2,156 / 2,096-2,151 | tx_d32h2L4 | 1-3 | 400
  m1006 Faktor gegen Trigramm 2,234 | 0,97-0,98 | tx_d32h2L4 | 1-3 | 3
Ergebnis e97 [2026-10-21 14:33]: gleichstand
  Fazit: Doppelte Tiefe bringt bei konstanter Rate 0,001 nur rund 2 % (Gleichstand nach der 10-%-Regel); die Saatbereiche überlappen nicht, der Effekt ist also klein, aber gleichgerichtet. Wegen des Wächtereingriffs in Saat 1 tragen nur zwei Saaten, das Ergebnis ist streng genommen eine Beobachtung. Für die Frage nach der Kapazität ist die Reihe überholt: Die Decke lag am Rezept (konstante Rate, snai/textknirps-rezept), mit fallender Rate gilt snai/textknirps-fall-groesse.
  Offen: Gepaarter Lauf ohne Wächter für Saat 1 fehlt. Tiefe mit fallender Rate: snai/textknirps-fall-groesse.
  Datei: rechner-a:~/snai_pruef/knirps/text/kriterien.txt
Chronik:
  2026-10-21 14:33 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/text/kriterien.txt, Abschnitt VIER SCHICHTEN (2026-10-13, vor dem Start; erste Läufe 13:01:50).)
  2026-10-21 14:33 Rezept r103 (tx_d32h2L4_s1..3)
  2026-10-21 14:33 Status geplant -> laeuft (Rezept r103)
  2026-10-21 14:33 Messwerte m995-m1006
  2026-10-21 14:33 Ergebnis e97: gleichstand
  2026-10-21 14:33 Status laeuft -> ausgewertet (Ergebnis e97)
```
