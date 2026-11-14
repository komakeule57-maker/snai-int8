# snai/silu-tab-hauptbaum

```text
snai/silu-tab-hauptbaum - ausgewertet, angelegt 2026-11-10, zuletzt 2026-11-11 04:13
Frage: Macht es das int8-Training des Hauptbaums auf rechner-a (Ryzen 5 5500U, 4 Fäden) schneller, wenn die SiLU-Ableitung im Rückwärts expf(−x) aus einer Tabelle des Vorwärts liest statt es je Element zu rufen, und bleibt das Ergebnis bytegleich?
Kriterium (festgelegt 2026-11-10 09:41, vor dem ersten Messwert):
  Arme: O = ausgelieferte Lib 57683872 (cortex 5dbb54fe); B = Lib aus cortex_silu.nim fc8cb41b (patch_silu.py 7bd7aeba), Stellrad SNAI_I8_SILU_EXP fehlt = an; B0 = dieselbe Lib mit =0. Zellen p512 (Breite 512, ctx 1024, Soll md5 6f49622c/Loss 78355d24), g256 (482098e1/61e0ea99), g128 (6e358822/f96d6e6f).
Teil 1 bytegleich (Pflicht): O, B0, B je Zelle bei 4 Fäden = Soll; seriell (SNAI_I8_PAR=0) g128 O = B; 1 Faden g128 und 12 Fäden g256 = Soll. Rot-Probe SNAI_I8_SILU_EXP=ROT muss in jeder Zelle und seriell ≠ Soll liefern, sonst ist die Sonde der Fehler. Fehlerkanal je Lauf: rc=0, keine Fehlerzeile, „SiLU-Tabelle: 1“, Meldung [SILU-EXP] passend zum Arm. Verletzt: Ende, nicht übernehmen.
Teil 2 Tempo: 24 Blöcke je Zelle, je Block O/B0/B direkt nacheinander, Reihenfolge über alle 6 Anordnungen, 4 Fäden, ms/Schritt. Lesart 1 (Urteil): Mittel log(X/Y), 95-%-t-Intervall ganz unter 1 = SCHNELLER, ganz über 1 = LANGSAMER, sonst NICHT AUFGELÖST; keine %-Schwelle. Lesart 2 (Gegenprobe): Median-Bootstrap (5000, Saat 1) + Vorzeichentest; SCHNELLER gegen LANGSAMER = widersprüchlich, wird gesondert entschieden. Grenze näher als 0,2 % an 1 = „knapp“, trägt allein weder Übernahme noch Veto. Erwartete Auflösung rund ±0,8 %; bleibt es unaufgelöst, ist das das Ergebnis, kein Nachlegen in dieser Reihe.
Übernahme (Vorschlag): Teil 1 erfüllt und B/O in mindestens einer Zelle SCHNELLER, in keiner LANGSAMER oder widersprüchlich. B/B0 SCHNELLER aber B/O nicht = „der Bau frisst den Gewinn“, nicht übernehmen. Überall unaufgelöst = kein Gewinn messbar bei dieser Auflösung, nicht übernehmen.
Nicht beantwortet: andere Rechner (vserver, rechner-b), andere Fadenzahlen im Tempo, LoRA-Pfad, fp32, ganze Trainingsläufe.
Plan: rechner-a:~/snai_pruef/threads/par12/KRITERIEN_silu_tab_hauptbaum.md
Baut auf: snai-evo/engine-silu-tab, snai/att-bw-blk-auto
Darauf baut: snai/gpu-port-hauptbaum
Rezepte:
  r667 [2026-11-10] cd ~/snai_pruef/threads/par12 && bash reihe_gleich.sh (11:57–12:13), dann setsid nohup bash reihe_tempo.sh (Start 12:13:48; 3 Zellen g128/g256/p512 × 24 Blöcke × 3 Arme O/B0/B, 4 Fäden, 6 Anordnungen); Auswertung python3 ausw_silu.py
      quelltext: patch_silu.py f52e9601 auf Hauptbaum cortex.nim 5dbb54fe → cortex_silu.nim c7471c3f; libs/silu.so 4b81510b (gebaut 10.11. 11:57 in proj_p512, Bauzeile wie Hauptbaum-Lib: nim c -d:danger --threads:on --passC:-fopenmp --passL:-fopenmp --app:lib, ohne -z nodelete, weil orig 57683872 es auch nicht trägt); libs/orig.so 57683872; arm.sh 6a62f79c, ab 12:15 9100e9d7 (nur Logname mit Zelle); reihe_gleich.sh bc398c01, reihe_tempo.sh d81efc0d, KRITERIEN 5fc033b0
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/par12/ergebnis.txt, log/
      notiz: Bytegleich-Teil: Logs trugen bis 12:15 keinen Zellennamen und überschrieben sich je Etikett (erhalten ist je Etikett die letzte Zelle); die Ergebniszeilen wurden je Lauf sofort geschrieben und sind vollständig. Fehlersonde errzeilen liest nur .err, die Worker-Meldungen stehen aber im .log: bei der Auswertung alle Tempo-Logs zusätzlich nach dem Muster durchsuchen.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/threads/par12/ergebnis.txt (acd2b7dc), ausw_silu.py 879855c2; ms/Schritt längster Worker, Lesart 1 Mittel log + 95-%-t, Lesart 2 Median/Bootstrap
  m10086 Teil 1 bytegleich G1 O/B0/B = Soll | 9/9 | alle |  | 9
  m10087 Teil 1 G2 seriell, n1, n12 = Soll | 4/4 | alle |  | 4
  m10088 Teil 1 G3 Rot ROT/ROTL ≠ Soll | 8/8 | ROT |  | 8
  m10089 Messgerät Tempo rc=0, Fehlerkanal leer (.err und .log), md5 = Soll | 216/216 | alle |  | 216
  m10090 g128 B/O | 0,9735 [0,9554-0,9920] SCHNELLER; L2 0,9810 SCHNELLER; Folgekorr. +0,10 | B |  | 24
  m10091 g128 B/B0 | 0,9628 [0,9484-0,9775] SCHNELLER; L2 SCHNELLER | B |  | 24
  m10092 g128 B0/O | 1,0111 [0,9902-1,0325] nicht aufgelöst; L2 1,0144 LANGSAMER | B0 |  | 24
  m10093 g256 B/O | 0,9446 [0,9055-0,9854] SCHNELLER; L2 0,9707 SCHNELLER; Folgekorr. -0,24 | B |  | 24
  m10094 g256 B/B0 | 0,9772 [0,9545-1,0003] nicht aufgelöst; L2 0,9715 SCHNELLER | B |  | 24
  m10095 g256 B0/O | 0,9666 [0,9359-0,9984] SCHNELLER (KNAPP), Folgekorr. +0,29; L2 nicht aufgelöst | B0 |  | 24
  m10096 p512 B/O | 1,0052 [0,9734-1,0380] nicht aufgelöst; L2 0,9971 nicht aufgelöst | B |  | 24
  m10097 p512 B/B0 | 0,9946 [0,9601-1,0303] nicht aufgelöst; L2 0,9904 nicht aufgelöst | B |  | 24
  m10098 p512 B0/O | 1,0107 [0,9703-1,0527] nicht aufgelöst | B0 |  | 24
Ergebnis e604 [2026-11-10 15:24]: erfuellt
  Fazit: Nach der Vorab-Regel ÜBERNEHMEN als Vorschlag: bytegleich, B/O an Breite 128 und 256 (ctx 512) SCHNELLER (0,974 und 0,945), nirgends LANGSAMER. An Breite 128 trägt der Patch selbst den Gewinn (B/B0 0,963), an 256 teils der Bau (B0/O knapp schneller). Für die Zielgröße prod512b (Breite 512, ctx 1024) sagt die Messung nichts: Rauschen viermal so groß wie geplant (±3,3 % statt ±0,8 %), ein Gewinn in Evo-Größe bliebe darunter. Hauptbaum unverändert bis zur Freigabe.
  Offen: Wirkung an p512/ctx 1024 (eigene ruhigere Reihe nötig, z. B. vserver nach s15); andere Rechner und Fadenzahlen; LoRA-Pfad bytegleich nicht geprüft; ob die 1-MB-Tabelle je Schicht bei ctx 1024 den Gewinn auffrisst.
  Datei: rechner-a:~/snai_pruef/threads/par12/ERGEBNIS_silu_tab_hauptbaum.md
Chronik (juengste 8 von 11, voll=True zeigt alle):
  2026-11-10 12:14 Status geplant -> laeuft (Rezept r667)
  2026-11-10 12:14 Teil 1 (bytegleich) 10.11. 12:13 erfüllt: G1 O/B0/B = Soll in g128, g256, p512 (9/9); G2 seriell g128 O = B (6e358822), ein Faden g128 O = B = Soll, 12 Fäden g256 B = Soll; G3 ROT und ROTL ≠ Soll in allen drei Zellen und seriell (8/8), Meldung ROT-PROBE vorhanden. Meldung [SILU-EXP] an/aus wie gesetzt, im O-Arm keine. Tempo läuft seit 12:13:48, Ende etwa 15:25.
  2026-11-10 15:24 Messwerte m10086-m10098
  2026-11-10 15:24 Ergebnis e604: erfuellt
  2026-11-10 15:24 Status laeuft -> ausgewertet (Ergebnis e604)
  2026-11-10 17:37 10.11. ~16:00: Entscheidung „wir übernehmen den SiLU-Patch mit Schalter“. Hauptbaum cortex.nim = c7471c3f (patch_silu.py auf 5dbb54fe, nach Commit 0ddb194 der Schwelle 256), libcortex.so neu gebaut = 4b81510b, byteidentisch zur gemessenen libs/silu.so. Stellrad SNAI_I8_SILU_EXP bleibt (fehlt = an, 0 = aus). Vorgänger-Lib 57683872 als libcortex.so.bak_20261110_vor_silu. SiLU noch nicht committet.
  2026-11-10 18:33 10.11.: Auf Auftrag („commite den SiLU patch bitte“) als f054f1b im Hauptbaum committet (cortex.nim c7471c3f, Projektregeln), lokal, nicht gepusht.
  2026-11-11 04:13 11.11.: snai_multi_stack übernimmt f054f1b vorerst nicht. Entscheidung, weitergereicht aus dem Zweig multi_stack mit Wortlaut: „Wir warten mit dem SiLU-Patch für multi_stack und machen erstmal ohne weiter.“ Grund: Training dort fast ganz auf CUDA, geschätzt unter 1 % Anteil. Wieder auf dem Tisch bei CPU-Training oder großem Kontext, zusammen mit den CPU-Tempo-Commits.
```
