# snai/dist-attf-par

```text
snai/dist-attf-par - ausgewertet, angelegt 2026-11-10, zuletzt 2026-11-10 13:40
Frage: Bleibt der float32-Trainingsschritt der Distro bytegleich, wenn die Attention vorwärts parallel über die Positionen läuft (dritter Kandidat nach snai/dist-par-umbau), und wird er auf rechner-a schneller?
Kriterium (festgelegt 2026-11-10 09:08, vor dem ersten Messwert):
  Wortlaut: rechner-a ~/snai_pruef/threads/dist4/KRITERIEN_dist_attf.md (0b3ee7be, 2026-11-10 vor dem ersten Lauf). Basis Distro core/cortex.nim 6a3fdfc6, patch_dist4.py; Libs orig 61a76e9f, stell 5e02df73 (Stellrad SNAI_ATTF 0/S/D/ROT), endS b27553e6, endD 77bc2c45. (a) Bytegleich: je Zelle sechs Arme (orig, stell 0/S/D, endS, endD) mit gleichem Modell-md5 und Loss-md5; g128 Köpfe 1/2/4/8 × Fäden 1/2/4/8, g128h2 Fäden 12, g512 Fäden 4/8/12: 20/20, sonst Ende. (b) Rot: SNAI_ATTF=ROT ändert md5 an g128h2 n4 und g512 n4. (c) Messgerät je Lauf: rc=0, Fehlerkanal leer, GPU_BACKEND=NONE, [PAR]-Modus wie gesetzt. (d) Tempo: Wanduhr, gepaarte Blöcke zyklisch (A=0, S static, D dynamic,8), g512 n12 und n4 je 9 Blöcke, g128h2 n12 und n4 je 24; Mittel log(Y/X), 95-%-t-Intervall; SCHNELLER Obergrenze < 1, LANGSAMER Untergrenze > 1, sonst NICHT AUFGELÖST; keine %-Schwelle (Regel). Zweite Lesart ohne Blöcke mit abgeschnittener [PAR]-Zeile. Plan: D nur, wenn D/S in einer Zelle SCHNELLER und in keiner LANGSAMER, sonst S. ÜBERNEHMEN (Distro-Quelltext und Lib, kein Commit ohne Auftrag): (a)–(c) erfüllt, gewählter Plan gegen A in mindestens einer Zelle SCHNELLER, in keiner LANGSAMER. Alle NICHT AUFGELÖST: kein Gewinn messbar, nicht übernehmen. Erwartung vorab: g128 bleibt wahrscheinlich NICHT AUFGELÖST (möglicher Gewinn 2–3 % gegen Streuung ±10 % in dist2). Reichweite: ein Rechner, CPU-Pfad, nicht snai_edge, nicht int8.
Plan: rechner-a:~/snai_pruef/threads/dist4/KRITERIEN_dist_attf.md
Baut auf: snai/dist-par-umbau, snai/dist-zeitsonde
Rezepte:
  r663 [2026-11-10] cd ~/snai_pruef/threads/dist4 && setsid nohup ./reihe_gleich.sh > reihe_gleich.out 2>&1 &   (danach bei freiem Rechner: ./reihe_tempo.sh)
      quelltext: Distro core/cortex.nim 6a3fdfc6 (main 01619ad) + patch_dist4.py: cortex_stell.nim 45d1c2d7 -> libcortex_stell.so 5e02df73 (Stellrad SNAI_ATTF 0/S/D/ROT); Endfassungen cortex_endS.nim e9f4d42f -> b27553e6, cortex_endD.nim 9818548b -> 77bc2c45; Bezug libcortex_orig.so 61a76e9f (Neubau bytegleich zur ausgelieferten Lib). Bau wie symbio.sh: nim 2.2.10, gcc 16.2.1, -d:danger --threads:on -fopenmp.
      parameter: Bytegleich: g128h1/2/4/8 (128 breit, ctx 512) x Fäden 1/2/4/8, g128h2 std, g512 (512 breit, ctx 1024, 4 Schichten, 8 Köpfe) n4/n8/std; je Zelle 6 Arme (orig, stell 0/S/D, endS, endD); Rot an g128h2 n4 und g512 n4. Tempo: Arme A(=0)/S/D aus stell, g512 std 9 Blöcke, g512 n4 9, g128h2 std 24, g128h2 n4 24, text30k.
      seed: deterministisch (keine Saat; gleiche Modelle und Texte in allen Armen)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/dist4/ (ergebnis.txt, reihe_gleich.out, Läufe je Etikett)
      notiz: Kriterien: rechner-a:~/snai_pruef/threads/dist4/KRITERIEN_dist_attf.md. Gestartet 2026-11-10 09:09:06.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a ~/snai_pruef/threads/dist4/ergebnis_gleich.txt (reihe_gleich.sh, 122 Läufe)
  m10019 Zellen mit md5-gleichen sechs Armen (orig, stell 0/S/D, endS, endD) | 20/20 | bytegleich |  | 120
  m10020 Rot-Proben mit geändertem md5 (g128h2 n4, g512 n4) | 2/2 | stell ROT |  | 2
  m10021 Läufe mit rc=0, errzeilen=0, GPU_BACKEND=NONE | 122/122 | alle |  | 122
  m10022 Stellrad-Meldung wie gesetzt (0/S/D/ROT) | 61/62, eine Meldezeile abgeschnitten (stell 0), kein Widerspruch | stell |  | 62
  Quelle: rechner-a:~/snai_pruef/threads/dist4/ergebnis.txt (746e5b72), ausw_tempo.py 000725e3; Wanduhr-Verhältnis, Mittel log, 95-%-t-Intervall, Lesart 1 (alle Blöcke); Lesart 2 = ohne Blöcke mit abgeschnittener [PAR]-Zeile
  m10023 Messgerät Tempo: rc=0 / errzeilen=0 / GPU NONE / ein md5 je Zelle | 264/264 | alle |  | 264
  m10024 g512 n=std A/O (Baukosten) | 1,0188 [0,9757-1,0637] nicht aufgelöst | A |  | 9
  m10025 g512 n=std S/A | 0,9053 [0,8765-0,9350] SCHNELLER | S |  | 9
  m10026 g512 n=std D/A | 0,9033 [0,8951-0,9115] SCHNELLER | D |  | 9
  m10027 g512 n=std D/S | 0,9978 [0,9691-1,0273] nicht aufgelöst; Lesart 2: 0,9859 [0,9751-0,9967] SCHNELLER | D |  | 9
  m10028 g512 n=std D/O | 0,9202 [0,8840-0,9580] SCHNELLER | D |  | 9
  m10029 g512 n=std S/O | 0,9223 [0,9080-0,9368] SCHNELLER | S |  | 9
  m10030 g512 n=4 A/O | 1,0110 [0,9506-1,0753] nicht aufgelöst | A |  | 9
  m10031 g512 n=4 S/A | 0,9401 [0,8922-0,9906] SCHNELLER; Lesart 2 (7 Blöcke): nicht aufgelöst | S |  | 9
  m10032 g512 n=4 D/A | 0,9370 [0,8792-0,9986] SCHNELLER; Lesart 2 (7 Blöcke): 0,9570 [0,9034-1,0139] nicht aufgelöst | D |  | 9
  m10033 g512 n=4 D/S | 0,9967 [0,9590-1,0359] nicht aufgelöst | D |  | 9
  m10034 g512 n=4 D/O | 0,9473 [0,9083-0,9880] SCHNELLER | D |  | 9
  m10035 g512 n=4 S/O | 0,9505 [0,8996-1,0043] nicht aufgelöst | S |  | 9
  m10036 g128h2 n=std A/O | 0,9773 [0,9468-1,0087] nicht aufgelöst; Lesart 2 (21 Blöcke): 0,9829 [0,9670-0,9991] SCHNELLER | A |  | 24
  m10037 g128h2 n=std S/A | 0,9631 [0,9200-1,0082] nicht aufgelöst; Lesart 2: 0,9505 SCHNELLER | S |  | 24
  m10038 g128h2 n=std D/A | 0,9614 [0,9134-1,0120] nicht aufgelöst | D |  | 24
  m10039 g128h2 n=std D/S | 0,9983 [0,9531-1,0455] nicht aufgelöst | D |  | 24
  m10040 g128h2 n=std D/O | 0,9396 [0,9031-0,9775] SCHNELLER | D |  | 24
  m10041 g128h2 n=std S/O | 0,9412 [0,9154-0,9677] SCHNELLER | S |  | 24
  m10042 g128h2 n=4 A/O | 1,0029 [0,9918-1,0142] nicht aufgelöst | A |  | 24
  m10043 g128h2 n=4 S/A | 0,9729 [0,9608-0,9852] SCHNELLER | S |  | 24
  m10044 g128h2 n=4 D/A | 0,9584 [0,9490-0,9680] SCHNELLER | D |  | 24
  m10045 g128h2 n=4 D/S | 0,9851 [0,9742-0,9961] SCHNELLER | D |  | 24
  m10046 g128h2 n=4 D/O | 0,9612 [0,9537-0,9688] SCHNELLER | D |  | 24
  m10047 g128h2 n=4 S/O | 0,9758 [0,9650-0,9867] SCHNELLER | S |  | 24
  Quelle: rechner-a:~/snai_pruef/threads/dist4/ergebnis.txt, Zeilen k_ (reihe_kontroll.sh); Wanduhr, Mittel log, 95-%-t-Intervall
  m10048 Kontrolle g512 n=std Endfassung endD 77bc2c45 gegen ausgelieferte Lib O 61a76e9f | 0,9139 [0,8683-0,9618] SCHNELLER, E schneller in 8/9; md5 18/18 gleich, rc=0, errzeilen=0; Blöcke 7-9 unter Fremdlast | endD |  | 9
Ergebnis e601 [2026-11-10 11:56]: erfuellt
  Fazit: Die Attention vorwärts läuft in der Distro parallel über die Positionen (Plan dynamic,8 nach Vorab-Regel), bytegleich in 20/20 Zellen, und verkürzt einen Trainingslauf an Breite 512 um etwa 8 bis 10 %, an Breite 128 um etwa 4 %; in keiner Zelle langsamer, auch nicht gegen die ausgelieferte Bibliothek (Baukosten nicht messbar, Endfassung gegen ausgeliefert 0,914). Eingespielt im Arbeitsbaum SNAI_distro (cortex.nim 9818548b, Lib 77bc2c45), ohne Commit und Push. Die Zelle g512 n=4 gegen A ist knapp (Obergrenze 0,9986, Lesart 2 nicht aufgelöst) und trägt das Urteil nicht allein.
  Offen: Commit und Push (gesondert zu entscheiden). Schwarmbetrieb, andere Rechner, Inferenz, GPU-Pfad, snai_edge, andere Chunkgröße nicht gemessen. Herkunft der Fremdlast in den Kontrollblöcken 7-9 nicht festgestellt.
  Datei: rechner-a:~/snai_pruef/threads/dist4/ERGEBNIS_dist_attf.md
Chronik (juengste 8 von 10, voll=True zeigt alle):
  2026-11-10 09:10 Status geplant -> laeuft (Rezept r663)
  2026-11-10 09:32 Messwerte m10019-m10022
  2026-11-10 11:36 Fassung 2 der Kriterien (10.11. 09:25, VOR dem ersten Tempo-Lauf; KRITERIEN_dist_attf.md 219b75c4): vierter Arm O = ausgelieferte Bibliothek orig 61a76e9f in jedem Block (Anlass, Baukosten). ÜBERNEHMEN verschärft: gewählter Plan zusätzlich gegen O in mindestens einer Zelle SCHNELLER und in keiner LANGSAMER; danach Kontrollvergleich Endfassung gegen O (g512, Fäden wie Distro, 9 Blöcke), bei LANGSAMER nicht einspielen. Tempo-Reihe beendet 10.11. 11:35 (264 Läufe, alle rc=0, errzeilen=0, GPU_BACKEND=NONE, je Zelle ein md5; 7 abgeschnittene [PAR]-Zeilen in 6 Blöcken). Kontrollvergleich endD gegen O läuft seit 11:37 (reihe_kontroll.sh).
  2026-11-10 11:36 Messwerte m10023-m10047
  2026-11-10 11:56 Messwerte m10048
  2026-11-10 11:56 Ergebnis e601: erfuellt
  2026-11-10 11:56 Status laeuft -> ausgewertet (Ergebnis e601)
  2026-11-10 13:40 10.11.: Auf Auftrag („Distro, Attention vorwärts parallel bitte commiten und pushen“) als a9818c3 auf main committet und nach GitHub gepusht (core/cortex.nim 9818548b; libcortex.so ist nicht im Repo).
```
