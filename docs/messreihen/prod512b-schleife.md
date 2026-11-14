# snai/prod512b-schleife

```text
snai/prod512b-schleife - ausgewertet, angelegt 2026-10-23, zuletzt 2026-10-23 15:26
Frage: Warum verfällt prod512b in Absatzschleifen? F1: verstärkt sich Satzwiederholung selbst (je öfter ein Satz im Kontext, desto wahrscheinlicher kommt er wieder; Xu et al. 2022)? F2: wächst das mit dem Training (s1..s3, s4 folgt)? F3: kommen Wiederholungen aus den Daten?
Kriterium (festgelegt 2026-10-23 13:42, vor dem ersten Messwert):
  sonde_schleife.php auf dem echten int8-Vorwärtspfad (SnaiCortexBridge wie eval_held_out_full_i8.php), 50 Held-out-Sätze (Saat 20261023), Folge S\nS\nS\nS\nS in einem Kontext; TP_j = mittlere Token-Wahrscheinlichkeit der Kopie j. Rot-Probe (Versatz um ein Token) gesehen. F1 je Checkpoint: Selbstverstärkung = Mittel TP j1<j2<j3<j4 UND TP_4 >= 1,10 x TP_1 UND TP_4 - TP_1 >= 0,02 UND TP_4 > TP_1 in >= 35/50 Sätzen; keine = TP_4 < 1,10 x TP_1 UND < 25/50; sonst uneinig (30/40 mitberichtet). F2 Kennzahl TP_4 - TP_1: wächst = s1<s2<s3 UND s3 >= 1,10 x s1; sinkt spiegelbildlich; sonst Gleichstand/uneinig (s0 nur berichtet). F3 (daten.py, Held-out + pseg04): Daten wiederholen kaum = W Mittel < 0,05 UND >= 90 % Dokumente W < 0,1. Kontrolle FREMD (anderer Satz nach 4 x S) nur berichtet. Offenlegung: 2 Sätze vorab gesehen. Volltext rechner-a:~/snai_pruef/merkmal/prodtest/schleife/kriterien.txt (mit Prüfer).
Plan: rechner-a:~/snai_pruef/merkmal/prodtest/schleife/kriterien.txt
Baut auf: snai/prod512b-norepeat, snai/prod512b-beamalpha
Darauf baut: snai/ditto-knirps, snai/schleife-einstieg, snai/prod512b-frankreich
Rezepte:
  r392 [2026-10-23] cd ~/snai_pruef/merkmal/prodtest/schleife && setsid nohup bash lauf.sh [segmente] &  (je Checkpoint: SNAI_GAIN_GUARD=0 SNAI_FORCE_CPU=1 OMP_NUM_THREADS=4 nice -n 19 php sonde_schleife.php factory/checkpoints/prod512b_s<N>.snai 8 saetze.json s<N>.jsonl 50, cwd proj_sr; dann python3 daten.py ho_prod.txt pseg04.txt)
      quelltext: proj_sr (tensor_ffi_adapter.php, snai_tokenizer.php, libcortex.so 318b2655, Vokabular f020d0ca); schleife/sonde_schleife.php, saetze.py, daten.py, lauf.sh, kriterien.txt 21fa26a9; Trainingssegment pseg04.txt md5 54a95b2b (Kopie von vserver)
      parameter: 50 Sätze, 5 Kopien, Trenner \n, Kontrolle FREMD = nächster Satz der Liste; Checkpoints s0..s3 (s4 nach Segmentende)
      seed: Satzauswahl random.Random(20261023); Messung deterministisch
      rechner: rechner-a, 1 Prozess, nice 19, OMP 4
      logs: rechner-a:~/snai_pruef/merkmal/prodtest/schleife/ (s<N>.jsonl, s<N>.err, md5_s<N>.txt, daten.txt, probe_rot/gruen.jsonl)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/prodtest/schleife/ergebnis.txt (auswert.py auf s0..s3.jsonl), daten.txt (daten.py)
  m4730 Mittel TP Kopie j0..j4 | 0,050 / 0,093 / 0,099 / 0,101 / 0,102 | s0 | 20261023 | 50
  m4731 Mittel TP Kopie j0..j4 | 0,070 / 0,315 / 0,379 / 0,404 / 0,418 | s1 | 20261023 | 50
  m4732 Mittel TP Kopie j0..j4 | 0,087 / 0,361 / 0,440 / 0,472 / 0,492 | s2 | 20261023 | 50
  m4733 Mittel TP Kopie j0..j4 | 0,105 / 0,398 / 0,479 / 0,514 / 0,534 | s3 | 20261023 | 50
  m4734 TP4 > TP1 (Sätze) | 48/50 / 50/50 / 50/50 / 50/50 | s0/s1/s2/s3 | 20261023 | 50
  m4735 Treffer H Kopie j0/j1/j4 | 0,19 / 0,62 / 0,75 | s3 | 20261023 | 50
  m4736 Kontrolle FREMD TP_U4 vs TP_U0 | 0,108 vs 0,108 (U4>U0 in 24/50) | s3 | 20261023 | 50
  m4737 F1-Urteil | uneinig / Selbstverstärkung / Selbstverstärkung / Selbstverstärkung | s0/s1/s2/s3 | 20261023 | 50
  m4738 F2 Zuwachs TP4-TP1 | 0,103 / 0,130 / 0,136 -> wächst | s1/s2/s3 | 20261023 | 50
  m4739 F3 W je Dokument Mittel (Anteil < 0,1) | 0,0050 (0,986) | Held-out ho_prod | - | 510
  m4740 F3 W je Dokument Mittel (Anteil < 0,1) | 0,0055 (0,990) | pseg04 | - | 10416
  m4741 F3 Dokumente mit direkt wiederholtem Satz | 0,8 % / 0,3 % | Held-out / pseg04 | - | 10926
  m4742 Rot-Probe (Versatz um ein Token) TP | 0,0003-0,003, kein Anstieg | s3 | 20261023 | 2
  m4743 Fehlerkanal | rc 0 in 4/4, keine Guard/unk/Fatal-Meldung | s0-s3 | - | 4
  Quelle: rechner-a:~/snai_pruef/merkmal/prodtest/schleife/s4.jsonl via auswert.py 1 2 3 4 (lauf.sh 4, s4.err ohne Fehler, md5 751d92d9)
  m4810 TP j0..j4 | 0,103 / 0,399 / 0,498 / 0,537 / 0,558 | s4 |  | 50
  m4811 H j0..j4 | 0,20 / 0,64 / 0,73 / 0,77 / 0,78 | s4 |  | 50
  m4812 TP4 - TP1 (Selbstverstärkung) | 0,159, TP4 > TP1 in 50/50 | s4 |  | 50
  m4813 Kontrolle fremd U4 / U0 | 0,104 / 0,104, U4 > U0 in 27/50 | s4 |  | 50
  m4814 F2-Verlauf TP4 - TP1 s1..s4 | 0,103 / 0,130 / 0,136 / 0,159 | s1-s4 |  | 50
Ergebnis e335 [2026-10-23 13:48]: erfuellt
  Fazit: Die Schleifen haben einen gemessenen Grund: prod512b verstärkt Satzwiederholung selbst (s1-s3, 50/50 Sätze, nach der zweiten Wiederholung trifft Greedy 62 %, nach der fünften 75 % der Tokens), und der Effekt wächst mit dem Training (F2), während die Trainingsdaten fast keine Wiederholung enthalten (F3). Die Schleife ist also eine erlernte Eigenschaft des Modells, entstanden mit dem Kopieren (s0 -> s1), kein Daten- und kein Dekodierfehler - deshalb verschieben Sperren und Längenbonus sie nur (prod512b-norepeat, -beamalpha). Mehr Training allein wird sie nicht beseitigen. Ein wirksamer Hebel läge im Training selbst (z. B. DITTO nach Xu et al.: auf künstlich wiederholten Sätzen die Wiederholungswahrscheinlichkeit bestrafen) - Eingriff in die Verlustfunktion, gesondert zu entscheiden.
  Offen: Auslöser der ersten Wiederholung nicht gemessen; Träger (Induktionsköpfe) nicht isoliert; s4 nachtragen (F2); s2->s3 nur noch +0,006 - ob der Zuwachs sättigt, zeigt s4ff.
  Datei: rechner-a:~/snai_pruef/merkmal/prodtest/schleife/kriterien.txt
Chronik:
  2026-10-23 13:42 angelegt
  2026-10-23 13:42 Rezept r392
  2026-10-23 13:42 Status geplant -> laeuft (Rezept r392)
  2026-10-23 13:48 Messwerte m4730-m4743
  2026-10-23 13:48 Ergebnis e335: erfuellt
  2026-10-23 13:48 Status laeuft -> ausgewertet (Ergebnis e335)
  2026-10-23 15:26 Messwerte m4810-m4814
```
