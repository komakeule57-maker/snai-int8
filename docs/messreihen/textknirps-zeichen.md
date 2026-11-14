# snai/textknirps-zeichen

```text
snai/textknirps-zeichen - ausgewertet, begonnen 2026-10-13, angelegt 2026-10-21, zuletzt 2026-10-21 14:33
Frage: Lernt ein Knirps 32/2/16 mit 2 Schichten (ctx 64, zeichenweises Vokabular 256, Ganzzahl-Stack gebunden, LR 0,001) auf echtem deutschem Text in 20 Segmenten (6,4 Mio Zeichen, jedes einmal) mehr als Uni-, Bi- und Trigramm? Kein Kopierversuch, sondern Sprachmodell-Probe.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/text/kriterien.txt, Abschnitt Kopf ("Kriterien VOR dem ersten Lauf", 2026-10-13; erster Lauf 12:30:40 laut Log; Prüfer-Notiz 12:33 ohne Regeländerung).):
  Endwert Segment 19 (nicht Bestwert), Held-out 300 Fenster (letzte 1 Mio Zeichen der Textprobe), Loss nats je Zeichen. Modell schlägt eine Vergleichsgröße, wenn sein Loss unter 90 % ihres Werts liegt; innerhalb ±10 % = Gleichstand; darüber = schlechter. Vergleichsgrößen auf denselben Positionen, gezählt auf den 20 Trainingssegmenten (Trigramm-Mischgewichte 0,9/0,09/0,01 frei gewählt). Über die Saaten: alle drei einig, sonst saatabhängig. Rot-Probe: Zeichen je Fenster gemischt, Modell-Loss muss > 10 % höher liegen, Unigramm gleich. Zusatz ohne Schwelle (vor dem Endstand festgelegt): Kontext-Sonde k = 1..32 Zeichen, "nutzt rund k Zeichen" ab weniger als 0,02 nats Gewinn je Verdopplung.
Plan: rechner-a:~/snai_pruef/knirps/text/kriterien.txt
Darauf baut: snai/textknirps-tiefe
Rezepte:
  r102 [2026-10-21] tx_d32h2_s1..3: cd ~/snai_pruef/knirps && text/lauf_text.sh <arm> <lr> 20 factory/checkpoints/text_gen_<zelle>_s<S>.snai  (darin je Segment: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 nice -n 10 php train_cluster.php factory/input/text_c64_seg<I>.txt <aus> 1 1 <vorstand> 3 <lr> 0.0001 1 0.1; Messung php text/mess_text.php <ck> text/heldout.txt text/ngram.json 300 0)
      quelltext: knirps/proj, libcortex.so md5 1c634106f31c (Lade-Wächter AN); text/lauf_text.sh 99ab6fb62520; text/mess_text.php 711d818750ae; text/mess_kontext.php 865b390c316f (md5 gekürzt)
      parameter: 32/2/16, 2 Schichten, ffn 128, ctx 64, Vokabular zeichen.json (256), LR 0,001 konstant nach Warmup 500 (KEIN Cosinus, siehe snai/textknirps-rezept), WD 0,1, 1 Arbeiter, Revival aus, 20 Segmente à 320.000 Zeichen aus textprobe_20mb.txt
      seed: Genesis text_gen_d32h2_s1..3 (Saat 1-3); Laufname hängt an der Saat
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/text/tx_d32h2_s{1,2,3}.log, .mess.jsonl, .kontext.jsonl, .lens.jsonl, _s<I>.train.log
      notiz: Läufe 2026-10-13 12:30-12:48. Prüfung beim Nachtrag: Endwerte, Rang 0, Rot-Probe, Segment 17 und Kontext-Sonde aus den mess.jsonl/kontext.jsonl nachgerechnet, alle. Keine NET2NET-GUARD-Zeile in Training oder Messung dieser drei Läufe (grep). Abweichung: Der frühere Befund schreibt "Cosinus-Neustart je Segment"; falsch, die LR war konstant (später berichtigt).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/text/tx_d32h2_s{1,2,3}.mess.jsonl und .kontext.jsonl (nachgerechnet)
  m975 Held-out-Loss Segment 19 (nats/Zeichen) (n = Fenster) | 2,231 | tx_d32h2 | 1 | 300
  m976 Held-out-Loss Segment 19 (nats/Zeichen) (n = Fenster) | 2,217 | tx_d32h2 | 2 | 300
  m977 Held-out-Loss Segment 19 (nats/Zeichen) (n = Fenster) | 2,211 | tx_d32h2 | 3 | 300
  m978 Rang 0 Segment 19 % (n = Positionen) | 39,0 | tx_d32h2 | 1 | 18900
  m979 Rang 0 Segment 19 % (n = Positionen) | 39,1 | tx_d32h2 | 2 | 18900
  m980 Rang 0 Segment 19 % (n = Positionen) | 39,8 | tx_d32h2 | 3 | 18900
  m981 Vergleich Unigramm (n = Fenster) | 3,372 | n-Gramm |  | 300
  m982 Vergleich Bigramm (n = Fenster) | 2,594 | n-Gramm |  | 300
  m983 Vergleich Trigramm (n = Fenster) | 2,234 | n-Gramm |  | 300
  m984 Faktor Modell/Bigramm | 0,85-0,86 | tx_d32h2 | 1-3 | 3
  m985 Faktor Modell/Trigramm | 0,99-1,00 | tx_d32h2 | 1-3 | 3
  m986 Rot-Probe Loss (Fenster gemischt) (n = Fenster) | 4,598 | tx_d32h2 | 1 | 300
  m987 Rot-Probe Loss (Fenster gemischt) (n = Fenster) | 4,770 | tx_d32h2 | 2 | 300
  m988 Rot-Probe Loss (Fenster gemischt) (n = Fenster) | 4,796 | tx_d32h2 | 3 | 300
  m989 Held-out-Loss Segment 17 (vor untypischem Segment 18) (n = Fenster) | 2,198 | tx_d32h2 | 1 | 300
  m990 Held-out-Loss Segment 17 (vor untypischem Segment 18) (n = Fenster) | 2,170 | tx_d32h2 | 2 | 300
  m991 Held-out-Loss Segment 17 (vor untypischem Segment 18) (n = Fenster) | 2,168 | tx_d32h2 | 3 | 300
  m992 Kontext-Sonde k=1 / k=8 / alles (n = Ziele) | 2,843 / 2,265 / 2,252 | tx_d32h2 | 1 | 400
  m993 Kontext-Sonde k=1 / k=8 / alles (n = Ziele) | 2,812 / 2,164 / 2,170 | tx_d32h2 | 2 | 400
  m994 Kontext-Sonde k=1 / k=8 / alles (n = Ziele) | 2,803 / 2,171 / 2,152 | tx_d32h2 | 3 | 400
Ergebnis e96 [2026-10-21 14:33]: teilweise
  Fazit: Der kleinste Text-Knirps lernt echte Sprachstatistik über das Bigramm hinaus (alle drei Saaten Faktor 0,85-0,86), erreicht aber nur das Trigramm (Gleichstand) und nutzt rund 8 der 64 Zeichen Kontext. Damit taugt der Knirps als billiges Versuchstier für Textfragen, aber mit diesem Rezept (konstante LR 0,001, 6,4 Mio Zeichen) liegt er an einer Decke. Die Folgereihen zeigten, dass diese Decke am Rezept (konstante Rate) lag, nicht an Breite oder Tiefe (snai/textknirps-rezept).
  Offen: Ob mehr Text, Breite oder ein anderes Rezept über das Trigramm hilft (hier eine Zelle, ein Budget). Segment 18 der Textprobe ist untypisch (viele Ziffern) und verschlechtert den Endwert in allen Läufen; der Endwert hängt an der Segmentreihenfolge.
  Datei: rechner-a:~/snai_pruef/knirps/text/kriterien.txt
Chronik:
  2026-10-21 14:33 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/text/kriterien.txt, Abschnitt Kopf ("Kriterien VOR dem ersten Lauf", 2026-10-13; erster Lauf 12:30:40 laut Log; Prüfer-Notiz 12:33 ohne Regeländerung).)
  2026-10-21 14:33 Rezept r102 (tx_d32h2_s1..3)
  2026-10-21 14:33 Status geplant -> laeuft (Rezept r102)
  2026-10-21 14:33 Messwerte m975-m994
  2026-10-21 14:33 Ergebnis e96: teilweise
  2026-10-21 14:33 Status laeuft -> ausgewertet (Ergebnis e96)
```
