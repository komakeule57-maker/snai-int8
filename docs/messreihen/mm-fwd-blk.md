# snai/mm-fwd-blk

```text
snai/mm-fwd-blk - ausgewertet, angelegt 2026-11-08, zuletzt 2026-11-09 01:27
Frage: Wird der Trainingsschritt schneller, wenn matMulBatchedI8 statt einer parallelen Region je Position eine Region über Zeilenblöcke (64) öffnet und die Eingangsquantisierung parallel läuft, bytegleich?
Kriterium (festgelegt 2026-11-08 23:03, vor dem ersten Messwert):
  Lib par3 (patch_par3.py auf cortex_par2 1c3373bf), Stellrad SNAI_I8_MM (fehlt = Blockpfad, 0 = Original). Alle 9 PAR-Gruppen an in beiden Armen.
(1) BYTEGLEICH: md5 6f49622c, Loss-md5 78355d24 mit Blockpfad bei n=1,2,4,8 und mit SNAI_I8_MM=0 bei n4. Sonst Reihe ungültig.
(2) ROT: SNAI_I8_MM=ROT (o_all[0]+1) und SNAI_I8_MM=ROTQ (qscales[0]+1) je n4 müssen md5 ändern.
(3) TEMPO n4 wie snai/par-schleifen-fein: Blöcke A = SNAI_I8_MM=0, B = Blockpfad, direkt nacheinander, Reihenfolge abwechselnd, 12 Blöcke (Streuung je Block war 2,3 %, 12 Blöcke lösen ~2,5 % auf), ms/Schritt aus [Bilanz], gepaartes t-Intervall 95 % auf log(B/A), ausw_fein.py-Logik mit Etiketten m*. Intervall ganz unter 1 = schneller, ganz über 1 = langsamer, sonst nicht aufgelöst (mit Breite berichtet). Dazu nur berichtet: Zeitsonde mmF bei n1/n4 in beiden Armen.
Baut auf: snai/par-schleifen-fein, snai/zeitsonde-i8
Darauf baut: snai/ga-prep-par
Rezepte:
  r638 [2026-11-08] ~/snai_pruef/threads/par3/reihe3.sh (Teil b_*: Bytegleich und Rot; Teil m*: 12 Blöcke AB/BA, A = SNAI_I8_MM=0, B = Blockpfad)
      quelltext: patch_par3.py, cortex.nim d1f83d2e, libcortex.so eb501b56; arm.sh bdf45f86
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/par3/ergebnis.txt, log/
  r640 [2026-11-08] wie r638
      rechner: rechner-a
      notiz: Während b_alle_n1 (Bytegleich, Zeit nicht gewertet) lief 23:31–23:33 ein Bibliotheksbau mit nice 19 für snai/ga-prep-par. Tempo-Blöcke m* liegen danach, keine Überlappung geplant.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/threads/par3/ergebnis.txt; Tempo per ~/snai_pruef/threads/fein/ausw_paar.py 57d5f359 (Kern aus ausw_fein.py, Gegenprobe auf Fein-Daten bytegleiches Ergebnis 0,9390)
  m9671 bytegleich md5/lossmd5 Blockpfad n1/n2/n4/n8 | 6f49622c/78355d24 (4/4) | blk |  | 4
  m9672 bytegleich SNAI_I8_MM=0 n4 | 6f49622c/78355d24 | mm0 |  | 1
  m9673 rot ROT (o_all[0]+1) | ee8a4df1 (rot) | blk |  | 1
  m9674 rot ROTQ (qscales[0]+1) | 4ef67dbd (rot) | blk |  | 1
  m9675 Tempo-Läufe bytegleich, rc=0, MM-Zeile passend | 24/24 |  |  | 24
  m9676 blk/mm0 geom. Mittel [95-%-t-Intervall] | 0,9255 [0,9089-0,9424] | blk |  | 12
  m9677 Streuung je Block (sd log) | 0,0285 |  |  | 12
  m9678 Blöcke B schneller | 12/12 | blk |  | 12
  m9679 Mittel ms/Schritt | A 6339,4 / B 5867,2 |  |  | 12
  m9680 ms/Schritt Einzellauf n1/n2/n8 Blockpfad (nur berichtet) | 15883,2 / 8612,9 / 4921,2 | blk |  | 1
Ergebnis e576 [2026-11-09 01:27]: erfuellt
  Fazit: Die Vorwärts-Matmul über Zeilenblöcke (eine parallele Region statt einer je Position) macht den ganzen Schritt bei 4 Threads 7,5 % schneller (Intervall 5,8–9,1 %, 12/12 Blöcke), bytegleich bei 1/2/4/8 Threads, beide Rot-Proben rot. Der Abschnitt selbst sinkt von ~0,76 auf ~0,28 s je Schritt; die Systemzeit je Lauf fällt von 15,6 auf 1,6 s. Das bestätigt die Ursache: die vielen kleinen parallelen Regionen mit schlafenden Threads (PASSIVE). Gilt als Muster für jede Stelle, die eine ||-Schleife in einer seriellen Schleife öffnet.
  Offen: Blockgröße 64 nicht variiert. Übernahme in den Hauptbaum: wird gesondert entschieden.
Chronik:
  2026-11-08 23:03 angelegt
  2026-11-08 23:04 Rezept r638
  2026-11-08 23:04 Status geplant -> laeuft (Rezept r638)
  2026-11-08 23:33 Rezept r640
  2026-11-09 01:27 Messwerte m9671-m9680
  2026-11-09 01:27 Ergebnis e576: erfuellt
  2026-11-09 01:27 Status laeuft -> ausgewertet (Ergebnis e576)
```
