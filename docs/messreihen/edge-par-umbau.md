# snai/edge-par-umbau

```text
snai/edge-par-umbau - ausgewertet, angelegt 2026-11-10, zuletzt 2026-11-10 08:58
Frage: Rechnet der Parallel-Umbau der Distro (Attention rückwärts parallel über die Köpfe, Vorwärts-Matmul mit einer Region, Commit 01619ad) im Quelltext von ~/Projekte/snai_edge (cortex.nim b2e5b498) bytegleich zum bisherigen Stand?
Kriterium (festgelegt 2026-11-10 08:38, vor dem ersten Messwert):
  Auftrag 10.11.: „Commite bitte auch nach snai_edge“. Patch patch_dist3.py = patch_dist2.py mit Basis b2e5b498 und Softmax-Startwert -9999.0 wie in snai_edge (ein Stellrad: nur die Parallelisierung; der NegInf-Fix der Distro wird NICHT mitgezogen). Gemessen: md5 des gespeicherten Modells nach kurzem Training (5 bzw. 7 Schritte, CPU-Pfad, GPU aus) im Prüfstand der Distro-Reihe (dist2/proj, train_cluster.php der Distro; snai_edge-eigenes PHP läuft nicht mit), Bibliotheken alle mit der Zeile aus snai_edge/build_cortex.sh gebaut.
Arme je Zelle: dep (ausgelieferte snai_edge/libcortex.so 52be5faa), orig (neu gebaut aus b2e5b498), stell alt (SNAI_ATTB=0 SNAI_MMF=0), stell neu (Vorgabe), end (Endfassung 73b737c6).
(a) BYTEGLEICH: g128 mit 1, 2, 4, 8 Köpfen x 1, 2, 4, 8 Fäden (16 Zellen) und g512 x 4, 8 Fäden (2 Zellen): alle 5 Arme gleicher md5 in 18/18 Zellen. Weicht nur dep ab, ist das ein eigener Befund (Bibliothek passt nicht zum Quelltext) und hält die Übernahme an, bis geklärt.
(b) ROT: SNAI_ATTB=ROT und SNAI_MMF=ROT ändern den md5 an g128h2 und an g512 (4/4). Bleibt eine grün, ist die Sonde ungültig.
(c) Fehlerkanal: jeder Lauf rc=0, errzeilen=0, GPU_BACKEND=NONE, Schrittzahl wie orig; [PAR]-Modus der stell-Läufe wie gesetzt (abgeschnittene Meldezeile zählt nicht als Widerspruch, wird gezählt und berichtet).
Übernahme: (a) bis (c) erfüllt -> Endfassung nach snai_edge/cortex.nim, Bibliothek per build_cortex.sh --deploy. Sonst nichts einspielen.
Tempo wird hier NICHT gemessen; die Zahlen aus snai/dist-par-umbau e597 gelten für die Distro und werden für snai_edge nur als Erwartung genannt. Reichweite: ein Rechner, CPU-Pfad, Distro-PHP als Treiber.
Baut auf: snai/dist-par-umbau
Rezepte:
  r661 [2026-11-10] cd ~/snai_pruef/threads/dist3 && setsid ./reihe_gleich.sh > reihe_gleich.out 2>&1 (je Zelle arm.sh dep|orig|stell(0,0)|stell|end; danach 4 Rot-Läufe)
      quelltext: snai_edge/cortex.nim b2e5b498 -> patch_dist3.py -> cortex_stell.nim 3c2dabe9, cortex_end.nim 73b737c6; Libs: dep 52be5faa (snai_edge/libcortex.so vom 15.08.), orig f69430fb, stell 9284ec29, end 264dca8d; Bau: nim c -d:danger --threads:on -f --passC:-fopenmp --passL:-fopenmp --passL:'-Wl,-rpath,\$ORIGIN' --app:lib
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/dist3/ergebnis.txt, log/
      notiz: Vorprobe g128h2 n4 (p_*): orig = stell alt = stell neu = end (ec5a34f9), dep weicht ab (37619fde). Die ausgelieferte Bibliothek ist vom 15.08., der Quelltext vom 03.09.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a ~/snai_pruef/threads/dist3/ergebnis.txt (reihe_gleich.sh), nm -D, strings
  m9993 Zellen mit md5-gleichen Quelltext-Armen (orig, s00, s1P, end) | 18/18 | Quelltext |  | 72
  m9994 Zellen, in denen alle fünf Arme gleich sind | 0/18 | dep gegen Quelltext |  | 90
  m9995 Rot-Proben mit geändertem md5 (ATTB, MMF; g128h2, g512) | 4/4 | Stellrad-Lib |  | 4
  m9996 Läufe mit rc=0, errzeilen=0, GPU_BACKEND=NONE | 94/94 | alle |  | 94
  m9997 Stellrad-Meldung wie gesetzt (s00 ATTB=0,MMF=0; s1P ATTB=1,MMF=1) | 18/18 und 18/18 | Stellrad-Lib |  | 36
  m9998 In dep fehlende Exporte gegenüber Neubau aus b2e5b498 | 4 (cortex_extract_grad, cortex_get_weight_tying, cortex_set_weight_tying, cortex_set_skip_adam) | dep
  m9999 Compiler dep / Neubau | GCC 16.1.1 20260728 / 16.2.1 20260810 | dep
Ergebnis e598 [2026-11-10 08:58]: teilweise
  Fazit: (b) und (c) erfüllt, (a) nach Wortlaut nicht: Die vier Quelltext-Arme sind in 18/18 Zellen bytegleich, die ausgelieferte Bibliothek 52be5faa weicht in 18/18 ab. Geklärt, soweit möglich: Sie stammt aus einem älteren Quelltext (vier Exporte fehlen, älterer Compiler). Folge: Der Umbau selbst ändert die Rechnung von snai_edge nicht und liegt als Quelltext in snai_edge/cortex.nim (73b737c6, Sicherung .bak_pre_par_20261110). Die Bibliothek wurde NICHT getauscht, weil ein Neubau mehr als den Umbau wirksam macht.
  Offen: Bibliothek neu bauen und tauschen? Tempo in snai_edge nicht gemessen; GPU-Bibliothek libcortex_cuda.so nicht berührt; Anteil des Compilerwechsels an der dep-Abweichung nicht isoliert.
  Datei: rechner-a:~/snai_pruef/threads/dist3/ERGEBNIS_edge_par.md
Chronik:
  2026-11-10 08:38 angelegt
  2026-11-10 08:40 Rezept r661
  2026-11-10 08:40 Status geplant -> laeuft (Rezept r661)
  2026-11-10 08:58 Messwerte m9993-m9999
  2026-11-10 08:58 Ergebnis e598: teilweise
  2026-11-10 08:58 Status laeuft -> ausgewertet (Ergebnis e598)
```
