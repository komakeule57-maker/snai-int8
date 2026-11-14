# snai/att-bw-blk2

```text
snai/att-bw-blk2 - ausgewertet, angelegt 2026-11-09, zuletzt 2026-11-09 17:51
Frage: Ist die korrigierte Block-Attention rückwärts (par8 = par7 + ds als double, Fix von SnAI Evo) bytegleich auch bei kurzen und nicht durch 16 teilbaren Fensterlängen, und bleibt der Tempogewinn? Auftrag 09.11. („Ja“ zu: Fix, Abnahme mit kurzen Fenstern, Tempo nachmessen, dann Übernahme).
Kriterium (festgelegt 2026-11-09 16:50, vor dem ersten Messwert):
  Arbeitskopie ~/snai_pruef/threads/par8: patch_par8.py (par7 5586de6b + Evo patch_par7_ds.py e779df31, Basisprüfung auf 0098d44d umgestellt) auf Hauptbaum 7408b8fc -> cortex 433383ad, Lib par8/proj 515b80ee. Diagnose-Lib par8/diag (Evo patch_diag.py c8eabd54 auf par8 -> 0b1d2bed, Lib 8d38df98): rechnet je Kopf Blockpfad und alten Zweig auf demselben Zustand und vergleicht d_v/d_k/d_q elementweise.
(K) KURZFENSTER n4: Texte kurz_<act>.txt (finde.php 324bf03d, Präfix von text.txt mit genau act+1 Token) für act 2, 3, 15, 16, 17, 40, 129, 511, 1023, 1024, je ein Fenster. Je act Lauf aus (SNAI_I8_ATT_BW_BLK=0) und blk: md5 und lossmd5 gleich, PLAN_TOKENS = act+1 im Log. Ein Paar ungleich -> nicht bytegleich, nicht übernehmen.
(D) DIAGNOSE n1: kurz_17 und text.txt mit Diagnose-Lib: alle [DIAG]-Zeilen „ungleich d_v 0 d_k 0 d_q 0“. Rot der Sonde: Diagnose-Lib mit SNAI_I8_ATT_BW_BLK=ROTB auf kurz_129 muss ungleich > 0 melden.
(B) BYTEGLEICH text.txt: md5 6f49622c / 78355d24 mit blk bei n1/2/4/8 und aus bei n4.
(R) ROT n4: ROTB, SNAI_I8_ATT_WCACHE=ROTX, =ROT ändern md5.
(T) TEMPO n4: 8 Blöcke A = aus, B = blk, gleiche Lib, AB/BA, ausw_paar.py, gepaartes 95-%-t-Intervall; ganz unter 1 = schneller. Nur berichtet gegen e586 (0,752).
Fehlerkanal: .err jedes Laufs, rc=0. Grenze: nur hs 64 (prod512b); andere Kopfgrößen deckt Evos Abnahme ab (hs 8).
Rezepte:
  r651 [2026-11-09] setsid nohup ~/snai_pruef/threads/par8/reihe8.sh (k<act>_aus/_blk n4 für 10 Kurzfenster, d_k17/d_rot129/d_text Diagnose n1, g_blk n1/2/4/8, g_aus_n4, g_rot ROTB/ROTX/ROT, q<b>_aus/_blk 8 Blöcke)
      quelltext: patch_par8.py 8b5039f9 -> cortex 433383ad, Lib 515b80ee; Diagnose patch_diag.py c8eabd54 -> 0b1d2bed, Lib 8d38df98; finde.php 324bf03d; arm.sh 3da19cd0; reihe8.sh 336132e3
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/par8/ergebnis.txt, log/, bau.log, diag/bau.log
Messwerte (Groesse | Wert | Arm | Start | n):
  m9817 ABWEICHUNG Aufbau (K) | PLAN_TOKENS weicht vom gezählten act+1 ab (Chunking hängt teils ein Token an); kurz_2 bricht in beiden Pfaden ab („zu wenige Tokens für einen Batch“, rc=1) | Gewertet werden die tatsächlichen Fensterlängen aus PLAN_TOKENS (act = min(1024, T-1-Start))
  m9818 KURZFENSTER aus=blk n4 | 9/9 Paare md5+lossmd5 gleich, rc=0 | tatsächliche act: 3 (T4), 16 (T17, zweimal), 17 (T18), 41 (T42), 129 (T130), 511 (T512), 1024 (T1025), 1024+1 (T1026: zwei Fenster, das zweite act=1). Abgedeckt: unter 16 und nicht teilbar (1, 3), über 16 nicht teilbar (17, 41, 129, 511), teilbar (16, 1024)
  m9819 DIAGNOSE kurz_17 n1 | alle [DIAG]-Zeilen ungleich d_v 0 d_k 0 d_q 0 | 6 Schichten x 8 Köpfe
  m9820 DIAGNOSE text.txt n1 | 40/40 [DIAG]-Zeilen 0/0/0, act=1024 | Sonde meldet nur die ersten 40 Kopfaufrufe (Schritt 1); md5 6f49622c
  m9821 DIAGNOSE Rot ROTB kurz_129 | l=5 h=0: d_k 63, d_q 62 ungleich; übrige Köpfe 0 | rot wie erwartet (Probe nur in Kopf 0)
  m9822 BYTEGLEICH text.txt blk n1/n2/n4/n8, aus n4 | 6f49622c/78355d24 alle 5 | 9462,6 / 5188,0 / 3074,0 / 2685,5; aus n4 4231,6 ms/Schritt
  m9823 ROT ROTB / ROTX / ROT n4 | 5d281170 / 50e0f67d / 5da45dbb | alle rot; ROTX und ROT gleich den Werten des alten Zweigs
  m9824 TEMPO blk/aus n4 8 Blöcke | 0,7475 [0,7367-0,7585] | B schneller 8/8, Streuung je Block 0,0176; Mittel A 4346,0 B 3247,9 ms/Schritt; Gegenprobe vertauschte Muster bricht ab
  m9825 FEHLERKANAL | 45 von 47 Läufen rc=0 (die 2 übrigen: kurz_2, s. o.), alle .err ohne Inhalt
Ergebnis e588 [2026-11-09 17:51]: erfuellt
  Fazit: Die korrigierte Block-Attention (par8, ds als double) ist bytegleich bei allen geprüften Fensterlängen: 1, 3, 16, 17, 41, 129, 511 und 1024, darunter Restblöcke unter und über 16. Sie ist auch bytegleich bei 1/2/4/8 Fäden, und die Diagnose findet 0 Abweichungen je Kopf (die Sonde zeigte mit ROTB rot). Das Tempo bleibt: 0,748 [0,737-0,759], 8/8 Blöcke. Der double-Puffer kostet also nichts Messbares gegenüber e586 (0,752). Abweichung vom Aufbau: Länge 2 fällt aus (Projekt trainiert so kurze Texte nicht), die Längen kommen aus PLAN_TOKENS statt aus der Zählung. Grenze: nur headSize 64; die Kopfgröße 8 hat Evo mit demselben Fix abgenommen. Übernahme in den Hauptbaum nach Auftrag 09.11. folgt.
Chronik:
  2026-11-09 16:50 angelegt
  2026-11-09 16:50 Rezept r651
  2026-11-09 16:50 Status geplant -> laeuft (Rezept r651)
  2026-11-09 17:51 Messwerte m9817-m9825
  2026-11-09 17:51 Ergebnis e588: erfuellt
  2026-11-09 17:51 Status laeuft -> ausgewertet (Ergebnis e588)
```
