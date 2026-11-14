# snai/att-bw-evo

```text
snai/att-bw-evo - ausgewertet, angelegt 2026-11-09, zuletzt 2026-11-09 10:31
Frage: Wird der prod512b-Trainingsschritt schneller, wenn die Attention-Patches aus SnAI_Evo (attw: Gewichte aus dem Vorwärts wiederverwenden, deq: K/V einmal je Schritt entquantisieren, dwt/vec: AVX2 im Kopf-Rückwärts) auf den Hauptbaum 4a62d92 kommen, bytegleich? (Auftrag 09.11.: „Dann Bau und muss das bitte erstmal in einer Arbeitskopie.“)
Kriterium (festgelegt 2026-11-09 08:29, vor dem ersten Messwert):
  Lib par5: patch_par5.py (a7526c4f) auf cortex.nim 96cb5b6d -> 2878ec43, libcortex.so f4d6b1ab, Arbeitskopie ~/snai_pruef/threads/par5/proj (= par4/proj bis auf cortex.nim und Lib). Evo-Patches attw ab0d5d46, deq efc13c2d, dwt 3fd7c5a8, vec f3e2366a (= Evo-Lib vec_native, OHNE patch_fwd). Anpassung: Prep vor die parallele Kopfschleife, w-Ablage und V-Tabelle zusätzlich in snaiAttFwdHead. Bau ohne -march=native (keine FMA). Stellrad SNAI_I8_ATT_WCACHE (fehlt = an, 0 = alter Pfad). prod512b wie arm.sh, Basis s11, 32 Schritte.
(1) BYTEGLEICH: md5 6f49622c / Loss-md5 78355d24 mit WCACHE an bei n=1,2,4,8 und mit WCACHE=0 bei n4. Sonst ungültig, Tempo nur berichtet.
(2) ROT je n4: ROT (w), ROTD (K-Tabelle), ROTV (vT), ROTX (Vektor-d_k) müssen md5 ändern. Bleibt eine grün, ist die Probe zu schwach (×1,0001): dann stärkere Probe als Abweichung, vor dem Lesen des Tempos.
(3) TEMPO n4: 12 Blöcke A = WCACHE=0, B = an, AB/BA, ms/Schritt [Bilanz], gepaartes t-Intervall 95 % auf log(B/A) (ausw_paar.py). Ganz unter 1 = schneller, ganz über 1 = langsamer, sonst nicht aufgelöst.
Nur berichtet: Zeitsonde attB/attF bei n4 (B), gegen par4-Stand gz_n4 (attB 2396 ms, attF 572 ms).
Was sich gemeinsam ändert: alle vier Patches zugleich (wie in der Evo-Lib); die Einzelwirkung trennt die Reihe nicht.
Rezepte:
  r643 [2026-11-09] setsid nohup ~/snai_pruef/threads/par5/reihe5.sh (g_* Bytegleich/Rot, gz_n4 Zeitsonde, q<b>_aus/_an 12 Blöcke AB/BA)
      quelltext: patch_par5.py a7526c4f -> cortex.nim 2878ec43, libcortex.so f4d6b1ab; arm.sh 4ec6d4af (aus par4/arm.sh dc016fc1), reihe5.sh c6d10890
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/par5/ergebnis.txt, log/
Messwerte (Groesse | Wert | Arm | Start | n):
  m9723 bytegleich WCACHE an n1/n2/n4/n8 + aus n4 | 6f49622c/78355d24 alle 5 | Einzelläufe an: n1 12790,8 n2 7259,2 n4 4734,1 n8 3547,6 ms; aus n4 5208,8 ms
  m9724 rot ROT | 5da45dbb/0df7cb9d | rot
  m9725 rot ROTD | 1f525d99/14650c14 | rot
  m9726 rot ROTV | 9a3e3b04/6dec591d | rot
  m9727 rot ROTX | 50e0f67d/c4fe2848 | rot
  m9728 tempo an/aus n4 12 Blöcke | 0,8640 | 95%-t-Intervall [0,8416-0,8869], B schneller 12/12, Streuung je Block 4,1 %; Mittel A 5326,6 B 4605,7 ms/Schritt; 24/24 bytegleich, 34/34 rc=0, .err 0 Byte
  m9729 tempo Blockwerte aus q0-q11 | 5327,5 5221,2 5444,0 5343,4 5247,8 5291,4 5222,8 5270,4 5324,4 5386,4 5313,6 5526,0 | ms/Schritt
  m9730 tempo Blockwerte an q0-q11 | 4555,1 4913,8 4514,1 4501,6 4518,4 4449,0 4540,2 4516,8 4566,6 4488,8 4527,0 5177,5 | ms/Schritt
  m9731 zeitsonde gz_n4 (nur berichtet) | attB 1705 ms, attF 398 ms, ges 4598 ms | gegen par4 gz_n4: attB 2396, attF 572, ges 5416
Ergebnis e580 [2026-11-09 10:31]: erfuellt
  Fazit: (1) bytegleich bei n1/2/4/8 und WCACHE=0, (2) alle vier Rot-Proben rot, (3) TEMPO n4: an/aus 0,864 [0,842-0,887], 12/12 -> SCHNELLER um ~14 %. Zeitsonde: Attention rückwärts 2,40 -> 1,71 s, vorwärts 0,57 -> 0,40 s. Fazit: Die Evo-Patches tragen auf prod512b, mit der Anpassung an den parallelen Vorwärts. Die Attention rückwärts bleibt mit 1,7 s (37 %) der größte Posten; was noch drin steckt, ist die serielle Schleife über t je Kopf (8 Köpfe auf 4 Fäden). Übernahme in den Hauptbaum zusammen mit dem Urteil zu fwd (snai/att-fwd-evo, läuft), nach Auftrag.
Chronik:
  2026-11-09 08:29 angelegt
  2026-11-09 08:29 Rezept r643
  2026-11-09 08:29 Status geplant -> laeuft (Rezept r643)
  2026-11-09 10:31 Messwerte m9723-m9731
  2026-11-09 10:31 Ergebnis e580: erfuellt
  2026-11-09 10:31 Status laeuft -> ausgewertet (Ergebnis e580)
```
