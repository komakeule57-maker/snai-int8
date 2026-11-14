# snai/att-bw-blk

```text
snai/att-bw-blk - ausgewertet, angelegt 2026-11-09, zuletzt 2026-11-09 16:41
Frage: Wird der prod512b-Trainingsschritt schneller, bytegleich, wenn die Attention rückwärts (ATT-W-CACHE-Zweig von snaiAttBwHead) P=16 Positionen je Block bearbeitet, sodass d_v/d_k/kf-Zeilen je Block einmal statt je Position einmal durchlaufen werden? Anlass: Vorgabe 09.11. „widmen uns lieber der Attention rückwärts“; attB ~1,7 s von ~4,4 s je Schritt (n4).
Kriterium (festgelegt 2026-11-09 13:42, vor dem ersten Messwert):
  Arbeitskopie ~/snai_pruef/threads/par7 (proj = Kopie par6/proj), patch_par7.py auf Hauptbaum cortex.nim 7408b8fc, EINE Lib, Stellrad SNAI_I8_ATT_BW_BLK (fehlt = Block 16, 0 = alter Zweig, ROTB = Rot-Probe ds(h0,p=act-1,t=0)+1,0). Reihenfolge je Element unverändert: d_v/d_k über p absteigend, d_q über t aufsteigend, dw/Summe je Zeile wie bisher.
(1) BYTEGLEICH: md5 6f49622c / lossmd5 78355d24 mit Blockpfad bei n=1,2,4,8 und mit SNAI_I8_ATT_BW_BLK=0 bei n4. Sonst ungültig, nicht übernehmen.
(2) ROT n4: ROTB muss md5 ändern; dazu SNAI_I8_ATT_WCACHE=ROTX und =ROT mit Blockpfad müssen md5 ändern (zeigt, dass die alten Proben im neuen Zweig wirken).
(3) TEMPO n4: 12 Blöcke A = SNAI_I8_ATT_BW_BLK=0, B = Blockpfad, gleiche Lib, AB/BA, ms/Schritt [Bilanz], gepaartes t-Intervall 95 % auf log(B/A) (ausw_paar.py). Ganz unter 1 = schneller, ganz über 1 = langsamer, sonst nicht aufgelöst (Breite berichtet). Keine %-Schwelle (Regel „selbst 2 %“).
Nur berichtet: Zeitsonde attB n4 in A und B. Vermutung (nicht gemessen): attB ist speicherbandbreitenbegrenzt (je Kopf und Schicht ~0,5 GB L2/L3-Verkehr); bleibt attB gleich, ist die Vermutung widerlegt.
Was sich ändert: nur der Zweig (Stellrad). Freier Parameter: P=16 und dw-Spaltenstück 128, nicht variiert. Fehlerkanal .err je Lauf vor dem Urteil lesen.
Rezepte:
  r649 [2026-11-09] setsid nohup ~/snai_pruef/threads/par7/reihe7.sh (g_blk_n4 mit Abbruch bei md5-Abweichung, g_blk_n1/2/8, g_aus_n4, g_rot_ROTB/ROTX/ROT, gz_blk/gz_aus, q<b>_aus/_blk 12 Blöcke AB/BA)
      quelltext: patch_par7.py 5586de6b auf Hauptbaum cortex.nim 7408b8fc -> 0098d44d, libcortex.so 3d384970; arm.sh 5b64a9ed (aus par6/arm.sh 265e91aa, lib= am Zeilenende), reihe7.sh 031ffc98
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/par7/ergebnis.txt, log/, bau.log
Messwerte (Groesse | Wert | Arm | Start | n):
  m9782 BYTEGLEICH Blockpfad n1/n2/n4/n8 | 6f49622c/78355d24 (4/4) | Einzelläufe 9542,3 / 5224,1 / 3821,4 / 2670,5 ms/Schritt, Lib 3d384970
  m9783 BYTEGLEICH SNAI_I8_ATT_BW_BLK=0 n4 | 6f49622c/78355d24 | 4189,6 ms/Schritt
  m9784 ROT ROTB n4 | b663e818/10e3f4e3 | rot
  m9785 ROT WCACHE=ROTX im Blockpfad n4 | 50e0f67d/c4fe2848 | rot; identisch zum ROTX-Wert des alten Zweigs (par5 e580)
  m9786 ROT WCACHE=ROT im Blockpfad n4 | 5da45dbb/0df7cb9d | rot; identisch zum ROT-Wert des alten Zweigs (par5 e580)
  m9787 TEMPO blk/aus n4 12 Blöcke | 0,7523 [0,7340-0,7711] | B schneller 12/12, Streuung je Block 0,0389; Mittel A 4333,8 B 3260,5 ms/Schritt; 34/34 Läufe rc=0, .err alle leer; Gegenprobe vertauschte Muster bricht ab
  m9788 ZEITSONDE gz n4 (nur berichtet) | attB ~0,58 s (blk) gegen ~2,02 s (aus) | ges blk ~3,2 s, aus 4,95-5,73 s (Sondenlauf aus streute); attF 0,17 s in beiden
  m9808 EINSCHRAENKUNG Restblock (nachgetragen nach e586, Hinweis Evo) | nicht gesondert geprüft | 32.062 Token in 32 Schritten bei ctx 1024: bei voll geschnittenen Fenstern 31x1024 + 1x318 (318 mod 16 = 14), also lief der Restblock vermutlich einmal (erschlossen, act nicht geloggt). act < 16 kam sicher nicht vor. Vor der Übernahme in den Hauptbaum gesondert abnehmen.
  m9809 FEHLER im Patch (gefunden von Evo, am erzeugten C bestätigt) | par7 5586de6b nicht allgemein bytegleich | ds ist im Original double (attScale NF), par7 rundet es im float-Puffer bb auf float32. Bei hs 64 (attScale 1/8) ist das exakt, außer bei subnormalem ds; bei hs 8/32/128 weicht es ab (Evo: d32 hs 8 alle act-Werte). Bytegleich-Befund von e586 gilt nur für prod512b hs 64 in diesem Lauf. Fix: ds in eigenem double-Puffer. Vor der Übernahme neu abnehmen.
Ergebnis e586 [2026-11-09 14:59]: erfuellt
  Fazit: Alle drei Teile erfüllt: bytegleich n1/2/4/8 und mit Stellrad aus, drei Rot-Proben rot, Tempo blk/aus 0,752 [0,734-0,771], 12/12 Blöcke (4334 -> 3261 ms/Schritt, n4). Die Zeitsonde bestätigt die Vermutung: attB fällt von ~2,0 auf ~0,58 s, die Attention rückwärts war speichergebunden, nicht rechengebunden. Die alten Rot-Proben ROT/ROTX geben im Blockpfad dieselben md5 wie im alten Zweig, ein zusätzlicher Beleg, dass beide Zweige auch unter Störung gleich rechnen. Gegen den Stand von heute früh (Commit 4a62d92, 5,38 s) ist prod512b n4 jetzt bei ~3,3 s, gegen gestern (8,43 s) bei ~0,39. Offen: Blockgröße 16 und Spaltenstück 128 nicht variiert; Über die Übernahme in den Hauptbaum wird gesondert entschieden. Reichweite: prod512b s11, 32 Schritte, rechner-a.
Chronik:
  2026-11-09 13:42 angelegt
  2026-11-09 13:44 Rezept r649
  2026-11-09 13:44 Status geplant -> laeuft (Rezept r649)
  2026-11-09 14:59 Messwerte m9782-m9788
  2026-11-09 14:59 Ergebnis e586: erfuellt
  2026-11-09 14:59 Status laeuft -> ausgewertet (Ergebnis e586)
  2026-11-09 16:28 Messwerte m9808
  2026-11-09 16:41 Messwerte m9809
```
