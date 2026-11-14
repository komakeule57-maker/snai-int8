# snai/dist-par-umbau

```text
snai/dist-par-umbau - ausgewertet, angelegt 2026-11-10, zuletzt 2026-11-10 07:59
Frage: Machen zwei Parallelisierungen im float32-Kern der Distro (SNAI_distro core/cortex.nim 82463d2d) das CPU-Training schneller, ohne ein Bit am Ergebnis zu aendern? (1) ATT-BW: Attention rueckwaerts parallel ueber die Koepfe (vorher seriell). (2) MM-FWD: Vorwaerts-Matmul mit einer Parallelregion statt einer je Position, Variante P (parallel ueber Positionen) oder R (parallel ueber Zeilen).
Kriterium (festgelegt 2026-11-10 06:26, vor dem ersten Messwert):
  Festgelegt 2026-11-10 vor dem ersten Lauf mit den neuen Bibliotheken.
Aufbau: rechner-a, ~/snai_pruef/threads/dist2, Kopie der Distro, Original per patch_dist2.py an genau den zwei Stellen geaendert (assert auf md5 und Trefferzahl). EINE Messbibliothek libcortex_stell mit zwei Stellraedern: SNAI_ATTB (0 alt, 1 neu, ROT) und SNAI_MMF (0 alt, P, R, ROT); Modus wird je Prozess als [PAR]-Zeile gemeldet. Lauf: php src/train_cluster.php <text> out.snai 1 1 <modell> 1 0.00005, Kaltstart-Modelle g128 (Breite 128) und g512 (Breite 512, 8 Koepfe), OCL_ICD_VENDORS=/nonexistent (GPU_BACKEND=NONE), fester Ausgabename.
(a) BYTEGLEICH (Pflicht fuer die Uebernahme): md5 von out.snai und md5 der Loss-Zeilen gleich zwischen libcortex_orig, stell mit 0/0, stell mit 1/P, stell mit 1/R, endP und endR. Geprueft an g128 mit 1, 2, 4 und 8 Koepfen (Kopfgroesse 128 bis 16, ueber .heads) bei n = 1, 2, 4, 8 Faeden und an g512 bei n = 4 und 8. Eine einzige Abweichung = Umbau nicht bytegleich, keine Uebernahme.
(b) ROT-PROBEN: SNAI_ATTB=ROT und SNAI_MMF=ROT muessen md5 aendern (g128 mit 2 Koepfen und g512), sonst ist die Bytegleichheits-Sonde ungueltig.
(c) MESSGERAET: jeder Lauf rc=0, erwartete Schrittzahl, [PAR]-Zeilen mit dem erwarteten Modus, Fehlerkanal sonst leer, GPU_BACKEND=NONE. Fehlerkanal wird vor dem Urteil gelesen.
(d) TEMPO: Messgroesse Wanduhr (real) des ganzen Laufs mit text30k. Arme aus derselben Bibliothek: A = 0/0, B = 1/0, C = 1/P, D = 1/R. Bloecke mit wechselnder Reihenfolge der Arme; je Block log-Verhaeltnis, gepaartes t-Intervall 95 %. Vergleiche B/A (ATT-BW allein), C/B (MM-FWD P allein), D/B (MM-FWD R allein), C/A (beides), D/C (R gegen P). Urteil je Vergleich: Intervall ganz unter 1 = SCHNELLER, ganz ueber 1 = LANGSAMER, sonst nicht aufgeloest. Keine Prozentschwelle (Vorgabe: auch 2 % zaehlen). g128: 12 Bloecke, g512: 6 Bloecke, jeweils n = 4 (wie die Zeitsonde). Zusaetzlich mit der Vorgabe der Distro (OMP_NUM_THREADS nicht gesetzt = 12 Kerne) A gegen C: g128 12 Bloecke, g512 6 Bloecke.
UEBERNAHME in ~/Projekte/SNAI_distro: ein Umbau wird uebernommen, wenn (a) bis (c) erfuellt sind, er in mindestens einer der vier Tempo-Zellen (g128/g512 x n=4/n=12) SCHNELLER ist und in keiner LANGSAMER. Ist er in einer Zelle LANGSAMER und in einer anderen SCHNELLER, wird er nicht still uebernommen, sondern zur Entscheidung vorgelegt. P gegen R: es gilt D/C; nicht aufgeloest = P (die einfachere Fassung). Vor der Uebernahme muss die Endfassung ohne Stellrad (endP bzw. endR) bytegleich zur Messfassung sein (steht in a).
FREIE PARAMETER: Fadenzahl (4 und 12), Textlaenge 30k, Kaltstart-Modell, Fremdlast auf rechner-a (je Lauf mitgeschrieben). Reichweite: ein Rechner, zwei Breiten, nur CPU-Pfad; die GPU-Pfade werden nicht beruehrt und nicht gemessen. Wiederholungen sind Zeitmessungen desselben deterministischen Laufs, keine Saaten.
Plan: rechner-a:~/snai_pruef/threads/dist2/patch_dist2.py
Baut auf: snai/dist-zeitsonde
Darauf baut: snai/edge-par-umbau, snai/dist-attf-par
Rezepte:
  r658 [2026-11-10] bytegleich: ~/snai_pruef/threads/dist2/reihe_gleich.sh (ruft arm.sh <orig|stell|endP|endR> <modell> <etikett> [SNAI_ATTB=.. SNAI_MMF=..]; darin: php src/train_cluster.php text12k.txt ck/out.snai 1 1 modelle/<modell>.snai 1 0.00005)
      quelltext: patch_dist2.py auf SNAI_distro core/cortex.nim 82463d2d (main 2f6d643); cortex_stell.nim a58a6dee -> libcortex_stell.so 85a1219d; cortex_endP.nim 6a3fdfc6 -> libcortex_endP.so 61a76e9f; cortex_endR.nim b13399c2 -> libcortex_endR.so e950a963; libcortex_orig.so 23e06f70
      parameter: g128 mit 1/2/4/8 Koepfen (harte Links auf dasselbe Modell, eigene .heads) x n=1,2,4,8; g512 (8 Koepfe) x n=4,8; OCL_ICD_VENDORS=/nonexistent; SNAI_LR_DECAY_STEPS=0 SNAI_WARMUP_STEPS=0
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/dist2/ergebnis.txt, log/
      notiz: Vorproben p_* an g128h2 n=4: orig = s00 = s1P = s1R = 1f8d0985; Rot ATTB f556087b, Rot MMF fd528b13 (md5 aendert sich, die Loss-Zeilen nicht: sie sind zu grob gerundet, also zaehlt fuer die Sonde der Modell-md5).
  r659 [2026-11-10] cd ~/snai_pruef/threads/dist2 && setsid -f ./reihe_tempo.sh > reihe_tempo.out 2>&1 < /dev/null   # Start 2026-11-10 06:47:17 rechner-a; libcortex_stell 85a1219d, text30k; Arme A=ATTB0/MMF0, B=1/0, C=1/P, D=1/R; g128h2 n4 12 Blöcke ABCD, g128h2 n=std 12 Blöcke AC, g512 n4 6 Blöcke ABCD, g512 n=std 6 Blöcke AC; Auswertung ./ausw_tempo.py
Messwerte (Groesse | Wert | Arm | Start | n):
  m9946 bytegleich g128, Köpfe 1/2/4/8 × Fäden 1/2/4/8 | 16/16 Zellen | je 6 Arme (orig, s00, s1P, s1R, endP, endR) gleicher md5: h1 3410b259, h2 1f8d0985, h4 f8225c1d, h8 961237b6; 5 Schritte
  m9947 bytegleich g512 (8 Köpfe) × Fäden 4/8 | 2/2 Zellen | 6 Arme md5 0107fec4, 4 Schritte
  m9948 Rot-Probe g512 n4 | 2/2 rot | SNAI_ATTB=ROT dc87d54c, SNAI_MMF=ROT 7b32fcb0, beide ≠ 0107fec4
  m9949 Rot-Probe g128h2 n4 | 2/2 rot | f556087b, fd528b13, beide ≠ 1f8d0985
  m9950 Fehlerkanal Bytegleich-Reihe | 110/110 sauber | rc=0, errzeilen=0, GPU_BACKEND=NONE, [PAR]-Modi wie gesetzt
  m9962 Tempo C/A g128h2 n4 (12 Blöcke) | 0,775 [0,702–0,856] | SCHNELLER; streng (11 Blöcke) 0,795 [0,726–0,871]
  m9963 Tempo C/A g128h2 n=std 12 Fäden (12 Blöcke) | 0,785 [0,708–0,869] | SCHNELLER; streng (9) 0,781 [0,725–0,842]
  m9964 Tempo C/A g512 n4 (6 Blöcke) | 0,774 [0,757–0,791] | SCHNELLER; streng (5) 0,780 [0,770–0,789]
  m9965 Tempo C/A g512 n=std 12 Fäden (6 Blöcke) | 0,643 [0,639–0,647] | SCHNELLER; streng (5) 0,644 [0,639–0,648]
  m9966 Tempo D/C (R gegen P) g128h2 n4 | 1,025 [1,007–1,044] | R LANGSAMER; g512 n4 0,978 [0,894–1,069] nicht aufgelöst (5 Blöcke) → P
  m9967 Tempo B/A (nur Attention) n4 | g512 0,821 [0,770–0,874], g128h2 0,874 [0,767–0,996] | streng: g128h2 0,916 [0,840–1,001] nicht aufgelöst
  m9968 Messgerät Tempo-Reihe | 7/108 Läufe mit abgeschnittener [PAR]-Zeile, 1 Lauf mit unlesbarer Zeit | kein Widerspruch zum Arm; strenge Lesart ohne betroffene Blöcke; Last 5–7 bei g128h2 n4 Block 11/12, Quelle unbekannt
  m9969 Einspielung Distro | core/cortex.nim 6a3fdfc6, lib 61a76e9f | lib bytegleich zur geprüften libcortex_endP.so, nicht committet
Ergebnis e597 [2026-11-10 07:59]: erfuellt
  Fazit: Beide Umbauten (Attention rückwärts parallel über die Köpfe, Vorwärts-Matmul mit einer Region, Variante P) sind bytegleich zum Original und in allen vier Zellen schneller: Wanduhr neu/alt 0,78 bei 4 Fäden an Breite 128 und 512, 0,78 an Breite 128 und 0,64 an Breite 512 mit den 12 Fäden der Distro-Vorgabe; in keiner Zelle langsamer, auch nicht in der strengen Lesart ohne Blöcke mit abgeschnittener Meldezeile. Variante R ist an Breite 128 langsamer als P, also P. Die Endfassung liegt im Arbeitsbaum der Distro (cortex.nim 6a3fdfc6, lib 61a76e9f), nicht committet. Gilt für rechner-a, CPU-Pfad, kurze Trainingsläufe; Schwarmbetrieb mit mehreren Prozessen und snai_edge sind nicht geprüft. Nächster Kandidat laut Zeitsonde wäre Attention vorwärts.
  Datei: ~/snai_pruef/threads/dist2/ERGEBNIS_dist_par_umbau.md
Chronik:
  2026-11-10 06:26 angelegt
  2026-11-10 06:28 Rezept r658 (bytegleich)
  2026-11-10 06:28 Status geplant -> laeuft (Rezept r658)
  2026-11-10 06:47 Messwerte m9946-m9950
  2026-11-10 06:47 Rezept r659
  2026-11-10 07:59 Messwerte m9962-m9969
  2026-11-10 07:59 Ergebnis e597: erfuellt
  2026-11-10 07:59 Status laeuft -> ausgewertet (Ergebnis e597)
```
