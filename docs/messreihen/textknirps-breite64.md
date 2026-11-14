# snai/textknirps-breite64

```text
snai/textknirps-breite64 - ausgewertet, begonnen 2026-10-13, angelegt 2026-10-21, zuletzt 2026-10-21 14:34
Frage: Text-Knirps bei konstanter LR 0,001: bringt Breite 64 (zwei Zellen 64/2/32 und 64/4/16, 2 Schichten) einen besseren Held-out-Loss als die 32er mit 2 bzw. 4 Schichten, und spielt die Kopfaufteilung eine Rolle?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/text/kriterien.txt, Abschnitt BREITE 64 (2026-10-13, vor dem Start; Läufe ab 13:44:23).):
  Stellrad Breite 32 -> 64 bei 2 Schichten, ffn 4 x Breite; gekoppelt Kopfbreite = Breite/Köpfe, deshalb zwei Zellen je 3 Saaten (64/2/32 Kopfzahl wie 32er, 64/4/16 Kopfbreite wie 32er), nicht gepaart. Urteil: Endwert Segment 19, Mittel der 3 Saaten gegen 32/2 x 2 Schichten (2,220) und gegen 32/2 x 4 Schichten (2,174); unter 10 % = Gleichstand. Gegen Trigramm (2,234): schlägt unter 2,011. Unterscheiden sich die beiden 64er-Zellen um weniger als 10 %, gilt die Kopfaufteilung als gleichgültig. Daneben: Segment 17, Kontext-Sonde, Lens, Leseproben.
Plan: rechner-a:~/snai_pruef/knirps/text/kriterien.txt
Baut auf: snai/textknirps-tiefe
Darauf baut: snai/textknirps-rezept
Rezepte:
  r111 [2026-10-21] tx_d64h2_s1..3, tx_d64h4_s1..3: cd ~/snai_pruef/knirps && text/lauf_text.sh <arm> <lr> 20 factory/checkpoints/text_gen_<zelle>_s<S>.snai  (darin je Segment: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 nice -n 10 php train_cluster.php factory/input/text_c64_seg<I>.txt <aus> 1 1 <vorstand> 3 <lr> 0.0001 1 0.1; Messung php text/mess_text.php <ck> text/heldout.txt text/ngram.json 300 0)
      quelltext: knirps/proj, libcortex.so md5 1c634106f31c (Lade-Wächter AN); text/lauf_text.sh 99ab6fb62520; text/mess_text.php 711d818750ae; text/mess_kontext.php 865b390c316f (md5 gekürzt)
      parameter: 64/2/32 und 64/4/16, 2 Schichten, ffn 256, ctx 64, zeichen-Vokabular, LR 0,001 konstant, Warmup 500, WD 0,1, 20 Segmente, Revival aus, Lade-Wächter an (keine Meldung)
      seed: Genesis text_gen_d64h2_s1..3, text_gen_d64h4_s1..3
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/text/tx_d64h2_s{1,2,3}.log, .mess.jsonl, .kontext.jsonl, .lens.jsonl, _s<I>.train.log; rechner-a:~/.cache/snai_pruef/knirps/text/tx_d64h4_s{1,2,3}.log, .mess.jsonl, .kontext.jsonl, .lens.jsonl, _s<I>.train.log
      notiz: Läufe 2026-10-13 13:44-14:38, sechs gleichzeitig. Prüfung beim Nachtrag: Endwerte, Segment 17, Rot-Probe und Kontext aus Rohdaten nachgerechnet. Kein Wächtereingriff. Der Vergleichswert 2,174 (32 x 4 Schichten) enthält die vom Wächter veränderte Saat 1 (siehe snai/textknirps-tiefe); ohne sie 2,168, Urteil unverändert. Der frühere Befund nennt als Rezept "Cosinus-Neustart mit voller LR 0,001 je Segment" - falsch, konstant.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/text/tx_d64h{2,4}_s{1,2,3}.mess.jsonl, .kontext.jsonl (nachgerechnet)
  m1136 Held-out-Loss Segment 19 (n = Fenster je Lauf) | 2,147 / 2,149 / 2,165 | tx_d64h2 | 1/2/3 | 300
  m1137 Held-out-Loss Segment 19 (n = Fenster je Lauf) | 2,166 / 2,131 / 2,159 | tx_d64h4 | 1/2/3 | 300
  m1138 Mittel | 2,154 | tx_d64h2 | 1-3 | 3
  m1139 Mittel | 2,152 | tx_d64h4 | 1-3 | 3
  m1140 Unterschied gegen 32/2 x 2 Schichten (2,220) (3 gegen 3) | -3,0 % | 64er
  m1141 Unterschied gegen 32/2 x 4 Schichten (2,174) (3 gegen 3) | -1,0 % | 64er
  m1142 Unterschied 64/4 gegen 64/2 (3 gegen 3) | -0,1 % | 64er
  m1143 Held-out-Loss Segment 17 | 2,137 / 2,108 / 2,136 | tx_d64h2 | 1/2/3 | 300
  m1144 Held-out-Loss Segment 17 | 2,104 / 2,116 / 2,092 | tx_d64h4 | 1/2/3 | 300
  m1145 Rot-Probe Loss | 4,56-4,82 | tx_d64h2, tx_d64h4 | 1-3 | 300
  m1146 Kontext-Sonde k=8 / alles (n = Ziele) | 2,106-2,142 / 2,102-2,123 | tx_d64h2, tx_d64h4 | 1-3 | 400
Ergebnis e104 [2026-10-21 14:34]: gleichstand
  Fazit: Doppelte Breite bringt bei konstanter Rate nur 1-3 % (Gleichstand gegen beide 32er), die Kopfaufteilung ist gleichgültig, und auch der 64er nutzt nur rund 8 Zeichen Kontext. Alle Zellen enden bei 2,15-2,22: Breite und Tiefe waren mit diesem Rezept nicht der Engpass. Die Vermutung "Rezept oder Budget" wurde danach geprüft (snai/textknirps-rezept): es war die konstante Rate. Größenaussagen dieser Reihe gelten nur für konstante LR 0,001.
  Offen: Breite mit fallender Rate: snai/textknirps-fall-groesse.
  Datei: rechner-a:~/snai_pruef/knirps/text/kriterien.txt
Chronik:
  2026-10-21 14:34 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/text/kriterien.txt, Abschnitt BREITE 64 (2026-10-13, vor dem Start; Läufe ab 13:44:23).)
  2026-10-21 14:34 Rezept r111 (tx_d64h2_s1..3, tx_d64h4_s1..3)
  2026-10-21 14:34 Status geplant -> laeuft (Rezept r111)
  2026-10-21 14:34 Messwerte m1136-m1146
  2026-10-21 14:34 Ergebnis e104: gleichstand
  2026-10-21 14:34 Status laeuft -> ausgewertet (Ergebnis e104)
```
