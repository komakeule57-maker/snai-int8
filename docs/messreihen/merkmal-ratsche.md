# snai/merkmal-ratsche

```text
snai/merkmal-ratsche - ausgewertet, begonnen 2026-10-17, angelegt 2026-10-21, zuletzt 2026-10-21 19:18
Frage: Kann das 8-Bit-v der Adam-Momente (logarithmischer Code, 254 Stufen, Rundung zum naechsten Code) ueberhaupt sinken, oder wirkt es als Ratsche (Rechnung am Quelltext: Abklingen 0,1 %/Schritt < halbe Stufe 3,7 %)?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/zeilenintern/kriterien_ratsche.txt, Kopf '2026-10-17, VOR der Rechnung' (abgelesen 11:06)):
  Anteil der v-Elemente mit v(spaet) < v(frueh) zwischen zwei Checkpoints. RATSCHE GESTUETZT: in ALLEN 8-Bit-Paaren < 1 % gesunken UND in der float-Kontrolle (ZERL M) > 20 % gesunken. NICHT GESTUETZT: in einem 8-Bit-Paar > 10 % gesunken. Sonst kein Urteil. Rot-Probe: Staende vertauscht -> 'gesunken' = 'gestiegen' des richtigen Paars.
Baut auf: snai/merkmal-unterversorgung, snai/merkmal-zerl
Darauf baut: snai/merkmal-sr
Rezepte:
  r133 [2026-10-21] Rechnung in Python (Skript nicht als Datei abgelegt; Ausgabe ratsche_ergebnis.txt), m/v ueber den PHP-Lader
      quelltext: nicht erhalten (kein eigenes Skript im Ordner zeilenintern/)
      parameter: Paare 8 Bit: GRENZE t60k->t70k, t0->t20k, Original s1 und s3 s4->s5; float: ZERL M s1/s3 s4->s5
      seed: -
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/zeilenintern/ratsche_ergebnis.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/zeilenintern/ratsche_ergebnis.txt (abgelesen 2026-10-21); n = 87 x 96 Elemente angenommen, in der Datei nicht genannt
  m1440 v gesunken | 75,9 % | 8 Bit GRENZE t60k->t70k | 1 | 8352
  m1441 v gesunken | 45,3 % | 8 Bit GRENZE t0->t20k | 1 | 8352
  m1442 v gesunken | 63,1 % | 8 Bit Original s4->s5 | 1 | 8352
  m1443 v gesunken | 75,6 % | 8 Bit Original s4->s5 | 3 | 8352
  m1444 v gesunken | 97,2 % | float ZERL M s4->s5 | 1 | 8352
  m1445 v gesunken | 98,7 % | float ZERL M s4->s5 | 3 | 8352
  m1446 v gestiegen | 24-55 % (float 1-3 %) | 8 Bit, alle Paare Saaten 1 und 3 |  | 4
  m1447 Rot vertauscht: gesunken | 24,0 % = gestiegen des Paars | Rot | 1 | 1
Ergebnis e127 [2026-10-21 19:18]: verfehlt
  Fazit: Nach Wortlaut widerlegt: 8-Bit-v sinkt ueber ein Segment in 45-76 % der Elemente, die Rechnung 'v kann nie sinken' war falsch. ABER: am 2026-10-18 hat snai/merkmal-sr durch Eingriff (zufaelliges Runden nur von v) gezeigt, dass die Rundung von v fuer den Kollaps noetig ist. Beides vertraegt sich, wenn die Ratsche nicht als 'nie sinken', sondern als systematisch zu hohes v wirkt (8 Bit: v steigt in 24-55 % der Elemente, float nur 1-3 %). Wer diese Reihe zitiert, muss die SR-Reihe dazunehmen; 'Ratsche widerlegt' als Satz allein ist falsch.
  Offen: Warum die Rechnung im Detail falsch war (Neurundung der Zeile beim Wechsel des Maximums?), nicht isoliert.
  Datei: rechner-a:~/snai_pruef/merkmal/zeilenintern/kriterien_ratsche.txt
Chronik:
  2026-10-21 19:18 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/zeilenintern/kriterien_ratsche.txt, Kopf '2026-10-17, VOR der Rechnung' (abgelesen 11:06))
  2026-10-21 19:18 Rezept r133
  2026-10-21 19:18 Status geplant -> laeuft (Rezept r133)
  2026-10-21 19:18 Messwerte m1440-m1447
  2026-10-21 19:18 Ergebnis e127: verfehlt
  2026-10-21 19:18 Status laeuft -> ausgewertet (Ergebnis e127)
```
