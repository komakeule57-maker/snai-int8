# snai/att-fwd-evo

```text
snai/att-fwd-evo - ausgewertet, angelegt 2026-11-09, zuletzt 2026-11-09 11:48
Frage: Bringt der fünfte Evo-Patch (patch_fwd: Vorwärts-Scores per AVX2 aus transponierter int8-K-Tabelle, outp per axpy) auf dem par5-Stand prod512b zusätzlich Tempo, bytegleich? (Hinweis 09.11.: fwd wird bei Evo neu geprüft, ~8 % auf allen Testgrößen machen ihn zum Kandidaten.)
Kriterium (festgelegt 2026-11-09 09:14, vor dem ersten Messwert):
  B = par6: patch_par6.py (c925768a) auf cortex_par5.nim 2878ec43 -> 7408b8fc (Evo patch_fwd e52fa4fa, dazu dieselbe Rechnung in snaiAttFwdHead, weil die serielle Schleife bei ATT-FWD-PAR leer läuft), Bau in reihe6.sh nach REIHE5_ENDE. A = par5/proj (Lib f4d6b1ab). Kopien unterscheiden sich nur in cortex.nim und Lib (diff -rq steht in ergebnis.txt). prod512b wie arm.sh, Basis s11, 32 Schritte. Gilt nur, wenn snai/att-bw-evo bytegleich ist.
(1) BYTEGLEICH: md5 6f49622c / 78355d24 mit B bei n=1,2,4,8.
(2) ROT: SNAI_I8_ATT_WCACHE=ROTF (kT8[0] ±1) muss md5 ändern (n4).
(3) TEMPO n4: 12 Blöcke A/B, AB/BA, ms/Schritt [Bilanz], gepaartes t-Intervall 95 % auf log(B/A) (ausw_paar.py). Ganz unter 1 = schneller, ganz über 1 = langsamer, sonst nicht aufgelöst.
Nur berichtet: Zeitsonde attF/attB in B gegen par5 gz_n4. Kein Schwellenwert in %: die Intervallregel entscheidet (Reihe mit Intervallregel); ob ein Gewinn um 8 % die Übernahme trägt, wird gesondert entschieden.
Rezepte:
  r645 [2026-11-09] setsid nohup ~/snai_pruef/threads/par6/reihe6.sh (wartet auf REIHE5_ENDE; Bau, g_fwd_n*, g_rot_ROTF, gz_n4, q<b>_p5/_fwd 12 Blöcke)
      quelltext: patch_par6.py c925768a -> cortex 7408b8fc; arm.sh 265e91aa (aus par5/arm.sh 4ec6d4af), reihe6.sh d32b6293
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/par6/ergebnis.txt, log/, bau.log
Messwerte (Groesse | Wert | Arm | Start | n):
  m9753 BYTEGLEICH n1 | 11746,7 ms/Schritt | B md5 6f49622c lossmd5 78355d24, Lib 5696cdd2
  m9754 BYTEGLEICH n2 | 6872,4 ms/Schritt | md5 6f49622c / 78355d24
  m9755 BYTEGLEICH n4 | 4202,0 ms/Schritt | md5 6f49622c / 78355d24
  m9756 BYTEGLEICH n8 | 3360,7 ms/Schritt | md5 6f49622c / 78355d24
  m9757 ROT ROTF n4 | md5 41efc1e3 | rot (weicht von 6f49622c ab)
  m9758 TEMPO fwd/p5 n4 | 0,9330 [0,9147-0,9517] | 12 Bloecke AB/BA, B schneller 12/12, Streuung je Block 0,0313; Mittel A 4702,1 B 4387,8 ms/Schritt; alle 24 Laeufe md5/lossmd5 gleich, rc=0, .err leer
  m9759 AUSWERTUNG Hinweis | ausw_paar.py auf umgestellter Kopie | arm.sh 265e91aa schreibt lib= vor n=4; Kopie mit sed lib= ans Zeilenende verschoben (Kern unveraendert), Pruefzeilen-Muster lib=f4d6b1ab/lib=5696cdd2; vertauschte Muster brechen ab (Probe rot)
  m9760 ZEITSONDE gz_n4 B | attF ~168 ms, attB ~1695 ms, batch ~3,92 s, ges ~4,33 s | par5 gz_n4: attF 398, attB ~1705, ges 4598 ms; nur berichtet
  m9761 UEBERNAHME Hauptbaum n4 | 4169,7 ms/Schritt | cortex.nim 7408b8fc im Hauptbaum (patch_par5+patch_par6 auf 96cb5b6d, cmp gleich par6), Lib 5696cdd2, md5 6f49622c / 78355d24, rc=0, .err leer
  m9762 UEBERNAHME Hauptbaum n1 | 11827,9 ms/Schritt | md5 6f49622c / 78355d24
  m9763 UEBERNAHME Hauptbaum n2 | 6893,0 ms/Schritt | md5 6f49622c / 78355d24
  m9764 UEBERNAHME Hauptbaum n8 | 3328,2 ms/Schritt | md5 6f49622c / 78355d24
Ergebnis e583 [2026-11-09 11:26]: erfuellt
  Fazit: Alle drei Teile erfuellt: bytegleich n1/2/4/8, ROTF rot, Tempo fwd/par5 = 0,933 [0,915-0,952], 12/12 Bloecke (4702 -> 4388 ms/Schritt). Zusammen mit par5 (e580, 0,864) steht prod512b n4 damit bei rund 4,4 s gegen 5,3 s auf dem Hauptbaum 4a62d92, also etwa 0,81. Die Ersparnis sitzt laut Zeitsonde im Attention-Vorwaerts (0,40 -> 0,17 s); groesster Posten bleibt attB ~1,7 s. Ob die ~7 % die Uebernahme tragen, wird gesondert entschieden (vorab so festgelegt). Reichweite: ein Modell (prod512b s11), 32 Schritte, rechner-a, n4 fuer Tempo.
Chronik:
  2026-11-09 09:14 angelegt
  2026-11-09 09:14 Rezept r645
  2026-11-09 09:14 Status geplant -> laeuft (Rezept r645)
  2026-11-09 11:26 Messwerte m9753-m9760
  2026-11-09 11:26 Ergebnis e583: erfuellt
  2026-11-09 11:26 Status laeuft -> ausgewertet (Ergebnis e583)
  2026-11-09 11:48 Messwerte m9761-m9764
```
