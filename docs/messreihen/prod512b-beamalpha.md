# snai/prod512b-beamalpha

```text
snai/prod512b-beamalpha - ausgewertet, angelegt 2026-10-23, zuletzt 2026-10-23 15:26
Frage: Wiederholen die Beam-Antworten der Leseprobe von prod512b, weil der Längenbonus (GNMT alpha 1,5) lange Kandidaten erzwingt, oder bewertet das Modell die lange, schleifende Fortsetzung je Token selbst als wahrscheinlicher?
Kriterium (festgelegt 2026-10-23 12:19, vor dem ersten Messwert):
  Teil A aus den Beam-Dumps der Leseprobe (alpha wirkt nur bei der Endauswahl, Kandidatenliste von alpha unabhängig, im Code geprüft): je Prompt Sieger beim Schnitt je Token score/len (Hauptlesart) sowie GNMT alpha 0/0,5/1,0/1,5 (nur berichtet). Je Checkpoint (4 Prompts): "Modell bevorzugt die Länge" = beim Schnitt je Token gewinnt in >= 3/4 Prompts ein 256-Token-Kandidat; "Bonus erzwingt die Länge" = in >= 3/4 ein Kandidat < 256 Token; sonst uneinig. Teil B: geänderte Sieger mit SNAI_BEAM_ALPHA neu erzeugen (Kontrolle len/score = Dump), W messen (wiederhol.py), nur berichtet. Offenlegung: Dump-Zeilen Prompt 1-2 von s3 vor dem Festlegen gesehen; Regel gilt gleich für s2 und s4. Einschränkung: score enthält Strafe 1,15 über 64 Token. Volltext rechner-a:~/snai_pruef/merkmal/prodtest/beamalpha/kriterien.txt (mit Prüfer).
Plan: rechner-a:~/snai_pruef/merkmal/prodtest/beamalpha/kriterien.txt
Baut auf: snai/prod512b-sampling
Darauf baut: snai/prod512b-norepeat, snai/prod512b-schleife
Rezepte:
  r390 [2026-10-23] Teil A: python3 ~/snai_pruef/merkmal/prodtest/beamalpha/teil_a.py <segment> (liest inferenz/referenz_roh_prod512b_s<N>.txt.dump). Teil B: setsid nohup bash ~/snai_pruef/merkmal/prodtest/beamalpha/teil_b.sh <segment> <alpha> (je Prompt SNAI_BEAM_ALPHA=<alpha> SNAI_BEAM_DUMP=1 SNAI_ROHPROMPT=1 SNAI_FORCE_CPU=1 OMP_NUM_THREADS=2 nice -n 19 php snai_inference.php factory/checkpoints/prod512b_s<N>.snai "<Prompt>" 3)
      quelltext: proj_sr snai_inference.php 8ba48a06 (unverändert, SNAI_BEAM_ALPHA eingebaut), libcortex.so 318b2655; beamalpha/teil_a.py, teil_b.sh, kriterien.txt 926bf1c6
      parameter: Beam 3, max 256 Token, Strafe 1,15/64 Token, ROH-Prompt, 4 Prompts; Lesarten Schnitt je Token und GNMT alpha 0/0,5/1,0/1,5
      seed: deterministisch (Beam)
      rechner: rechner-a, nice 19
      logs: rechner-a:~/snai_pruef/merkmal/prodtest/beamalpha/ (s<N>/a<alpha>_p<i>.txt/.err), Dumps in ~/snai_pruef/merkmal/prodtest/inferenz/
      notiz: Erster Teil-B-Lauf s3 alpha 0 durch einen Neustart abgebrochen (Ausgaben leer, verworfen), danach losgelöst neu gestartet.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a: beamalpha/teil_a.py auf inferenz/referenz_roh_prod512b_s2.txt.dump und _s3.txt.dump
  m4708 256-Token-Sieger beim Schnitt je Token s2 | 4/4 | Teil A | - | 4
  m4709 Schnitt je Token Sieger gegen bester kürzerer Kandidat s2 (Wohnhaus/Hauptstadt/1928/Film) | -0,525 vs -0,536 (253) / -1,108 vs -1,129 (251) / -1,430 vs -1,505 (214) / -0,793 vs -1,073 (162) | Teil A | - | 4
  m4710 Sieger-Länge bei GNMT alpha 0 / 0,5 / 1,0 / 1,5 s2 | Wohnhaus 8/8/256/256, Hauptstadt 22/22/256/256, 1928 8/8/8/256, Film 14/14/256/256 | Teil A | - | 4
  m4711 256-Token-Sieger beim Schnitt je Token s3 | 4/4 | Teil A | - | 4
  m4712 Schnitt je Token Sieger gegen bester kürzerer Kandidat s3 | -1,537 vs -2,189 (16) / -1,095 vs -1,117 (244) / -1,104 vs -1,107 (248) / -1,336 vs -1,358 (246) | Teil A | - | 4
  m4713 Sieger-Länge bei GNMT alpha 0 / 0,5 / 1,0 / 1,5 s3 | Wohnhaus 10/10/10/256, Hauptstadt 9/9/256/256, 1928 11/11/256/256, Film 13/13/256/256 | Teil A | - | 4
  m4714 Urteil Teil A s2 und s3 | Modell bevorzugt die Länge (je 4/4) | Teil A | - | 8
  Quelle: rechner-a:~/snai_pruef/merkmal/prodtest/beamalpha/s3/a0_p*.txt/.err (teil_b.sh 3 0)
  m4715 Kontrolle Teil B s3 alpha 0: len/score = Dump | 4/4 (10/-22,5225; 9/-15,7639; 11/-19,7484; 13/-25,7763) | Teil B | - | 4
  m4716 Sieger s3 alpha 0 = erster Satz der langen Beam-Antwort | 4/4 | Teil B | - | 4
  Quelle: rechner-a:~/snai_pruef/merkmal/prodtest/beamalpha/teil_a_s4.txt (teil_a.py 4 aus inferenz/referenz_roh_prod512b_s4.txt.dump, Leseprobe s4 md5 751d92d9)
  m4804 256-Token-Sieger beim Schnitt je Token | 4/4 | s4 |  | 4
  m4805 Sieger-Länge bei alpha 0 / 0,5 / 1,0 / 1,5 (Wohnhaus) | 1 / 1 / 1 / 256 | s4 |  | 1
  m4806 Sieger-Länge bei alpha 0 / 0,5 / 1,0 / 1,5 (Hauptstadt) | 9 / 9 / 9 / 256 | s4 |  | 1
  m4807 Sieger-Länge bei alpha 0 / 0,5 / 1,0 / 1,5 (1928) | 14 / 14 / 256 / 256 | s4 |  | 1
  m4808 Sieger-Länge bei alpha 0 / 0,5 / 1,0 / 1,5 (Film) | 18 / 18 / 256 / 256 | s4 |  | 1
  m4809 Urteil Teil A nach Vorab-Regel | Modell bevorzugt die Länge | s4 |  | 4
Ergebnis e333 [2026-10-23 12:57]: erfuellt
  Fazit: Nach der Vorab-Regel in s2 und s3 je 4/4: "Modell bevorzugt die Länge". Ohne Längenbonus (Schnitt je Token) gewinnt weiter die 256-Token-Antwort mit den Absatzschleifen; kurze Antworten gewinnen nur bei roher Summe der Log-Wahrscheinlichkeit und sind dann genau der erste Satz. Der Längenbonus ist also nicht die Ursache der Wiederholung, ihn zu senken liefert nur Ein-Satz-Antworten. Das Modell findet abgeschriebenen Text je Token billiger als neuen (Deutung: es lernt gerade kopieren; Absätze wiederholen sich jenseits des 64-Token-Fensters der Strafe). Abhilfe gehört in die Dekodierung gegen weite Wiederholungen (längeres Strafenfenster oder n-Gramm-Sperre mit großem n), nicht in alpha, und letztlich ins Training.
  Offen: s4 nach Regel nachrechnen (Dump der s4-Leseprobe). Größeres Strafenfenster / NOREPEAT mit n 8-12 ungemessen. Abstände zum besten kürzeren Kandidaten teils klein (0,003-0,02 je Token).
  Datei: rechner-a:~/snai_pruef/merkmal/prodtest/beamalpha/kriterien.txt
Chronik:
  2026-10-23 12:19 angelegt
  2026-10-23 12:53 Rezept r390
  2026-10-23 12:53 Status geplant -> laeuft (Rezept r390)
  2026-10-23 12:53 Messwerte m4708-m4714
  2026-10-23 12:57 Messwerte m4715, m4716
  2026-10-23 12:57 Ergebnis e333: erfuellt
  2026-10-23 12:57 Status laeuft -> ausgewertet (Ergebnis e333)
  2026-10-23 15:26 Messwerte m4804-m4809
```
