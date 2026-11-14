# snai/stell-lr512

```text
snai/stell-lr512 - ausgewertet, angelegt 2026-11-05, zuletzt 2026-11-06 09:31
Frage: Wo liegt bei 512x4 (Rezept R ohne Eingangsfaktor, 9k, Knirps-Text) das Optimum der Spitzen-LR? Liegt es, wie die Richtung 1/Breite aus 128 erwarten lässt, bei 0,00019-0,00038, und ist die prod512b-Spitze 1e-4 dort schlechter? Auftrag 05.11. (Vorschlag multi_stack) als Grundlage für die Neustart-Entscheidung prod512b.
Kriterium (festgelegt 2026-11-05 14:45, vor dem ersten Messwert):
  Datei rechner-a:~/snai_pruef/stell/KRITERIEN_lr512.md (cec3c288 samt Prüfer-Nachtrag). Sprossen L08/L04/L02/L01 = 0,0008/0,0004/0,0002/0,0001, Saaten s4-s6 gepaart, heldout 700 Fenster am Endstand. Regel D=A-B: BESSER = 3/3 negativ UND Mittel <= -0,02; SCHLECHTER spiegelbildlich; GLEICH = |Mittel| < 0,01 UND |D| < 0,02 in 3/3; sonst OFFEN; KNAPP -> heldout2. L* = kleinstes Mittel; EINGEGRENZT = beide Nachbarn SCHLECHTER; EBENE = GLEICHE Nachbarn fortlaufend, Sprossen direkt außerhalb SCHLECHTER; Ebene/L* am Rand = NICHT EINGEGRENZT; sonst OFFEN. 1/Breite: RICHTUNG BESTÄTIGT, wenn L04 oder L02 in der Ebene/L*. prod512b: L01 gegen L* nach der Regel.
Plan: rechner-a:~/snai_pruef/stell/KRITERIEN_lr512.md, reihe_lr512.sh
Darauf baut: snai/stell-lr1024
Rezepte:
  r603 [2026-11-05] cd ~/snai_pruef/stell && ./reihe_lr512.sh (verzögert gestartet, Beginn 16:20); je Lauf lauf_stell.sh lr512 <arm> - <s> daten/kurz9000.txt 3000,6000 mit CLIP_LIB=Hauptbaum libcortex.so, CLIP_GENPFX=d512_, CLIP_LR, CLIP_WARMUP=2000, CLIP_DECAY_START=8102, CLIP_DECAY_STEPS=9002, CLIP_MIN_RATIO=0.1, ohne SNAI_EMB_EIN
      quelltext: reihe_lr512.sh 289e1ca5, lauf_stell.sh ecd0d42a, KRITERIEN_lr512.md cec3c288, Lib 1eb78bc1 (Hauptbaum, mit v-Klemme), proj_clip/train_worker.php de34a553, werkzeug/ausw_lr512.py (Probe grün und rot gesehen)
      parameter: 512x4, 8 Köpfe, ffn 2048, ctx 128, gebunden, int8 voll, SR, Clip 1, Revival aus, WD 0,1; Sprossen 0,0008/0,0004/0,0002/0,0001; 9.002 Schritte kurz9000; heldout 700 Fenster
      seed: Genesis init_base.php <out> 0 512 128 4 2048 <s>: s4 73dc1386, s5 cd55da55, s6 2ed11fda; Fensterfolge am Laufnamen clip_s<s> (gepaart)
      rechner: rechner-a CPU, OMP 1, höchstens 4 zugleich neben Evo (danach bis 12), Start nur bei >= 1,8 GB frei
      logs: rechner-a:~/snai_pruef/stell/log/lr512.log, laeufe/lr512/<arm>_s<s>/ (lauf.log, train.log, mess.jsonl, mess.err), log/lr512_gains.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/stell/laeufe/lr512/<arm>_s<s>/mess.jsonl (heldout, 700 Fenster) und log/lr512_ho2.jsonl (heldout2, ho2_lr512.sh, Kontrolle L01_s4 auf heldout reproduziert 2,3767), ausgewertet mit werkzeug/ausw_lr512.py 02244011; Kontrollzeilen lr512.log 12/12 sauber, Fehlerkanal leer, tote Gains 0 %
  m9303 heldout Endstand | 2,7831 / 2,7381 / 2,7879 (Mittel 2,7697) | L08 0,0008 | s4/s5/s6 | 700
  m9304 heldout Endstand | 2,4540 / 2,4487 / 2,4468 (Mittel 2,4498) | L04 0,0004 | s4/s5/s6 | 700
  m9305 heldout Endstand | 2,3486 / 2,3561 / 2,3526 (Mittel 2,3524) | L02 0,0002 | s4/s5/s6 | 700
  m9306 heldout Endstand | 2,3767 / 2,3787 / 2,3700 (Mittel 2,3751) | L01 0,0001 | s4/s5/s6 | 700
  m9307 D gegen L02 heldout | L08 +0,4173 SCHLECHTER; L04 +0,0974 SCHLECHTER; L01 +0,0281/+0,0226/+0,0174 Mittel +0,0227 SCHLECHTER KNAPP | gepaart | s4-s6 | 700
  m9308 heldout2 Endstand | L08 2,7600; L04 2,4383; L02 2,3458; L01 2,3631 (Mittel über s4-s6) | alle | s4/s5/s6 | 700
  m9309 D gegen L02 heldout2 | L08 +0,4142 SCHLECHTER; L04 +0,0925 SCHLECHTER; L01 +0,0186/+0,0181/+0,0152 Mittel +0,0173 OFFEN KNAPP | gepaart | s4-s6 | 700
  m9310 tote Gains Endstand | 0 % in allen Schichten (FFN, Attention, final) | alle 12 | s4-s6 | 12
Ergebnis e558 [2026-11-06 09:31]: erfuellt
  Fazit: Nach Wortlaut (heldout, weil heldout2 knapp bleibt): EINGEGRENZT bei 0,0002, 1/Breite RICHTUNG BESTÄTIGT, prod512b-Spitze 1e-4 SCHLECHTER (+0,023, KNAPP). Lesart heldout2: L02 bleibt beste Sprosse, nach unten OFFEN (+0,017, 3/3 positiv, unter 0,02). Beide tragen: 0,0002 ist am besten, 0,0004 kostet rund 0,09 nats, 0,0008 rund 0,41, 0,0001 rund 0,02 (6/6 Messungen schlechter). Deutung, nicht gemessen: Am unteren Rand passt 1/Breite zu 128x4 (Breite x LR 0,05-0,06 kostet bei beiden ~0,02). Nach oben ist die gute Zone bei 512 enger (Breite x LR 0,2 war bei 128 auf der Ebene, bei 512 +0,09). Für 4096 eher am unteren Ende der Hochrechnung planen (1,2e-5 bis 2,4e-5) und vorher eine kurze Leiter bei größerer Breite fahren. prod512b mit 1e-4 ist leicht zu vorsichtig; ein Neustart lohnt dafür allein nicht. Offen: Übertragung auf 6 Schichten, ctx 1024, langes Budget.
  Datei: rechner-a:~/snai_pruef/stell/ERGEBNIS_lr512.md
Chronik:
  2026-11-05 14:45 angelegt
  2026-11-05 15:07 Rezept r603
  2026-11-05 15:07 Status geplant -> laeuft (Rezept r603)
  2026-11-05 15:07 Vorab-Gerät 05.11.: 60-Schritte-Probe 512x4 (kurz60) zweimal gefahren, Endstand bytegleich (c6d3d1f7, P1/P2), Lib 1eb78bc1 passt zum Trainer proj_clip, Fehlerkanal 0. Zeit 2,2 s je Schritt bei voll belegtem Rechner (1 Thread), also rund 5,5 h je Lauf plus ~7 min Messung. Spitzen-RSS je Lauf 391 MB (Training + Messung, P3). Auswerteskript-Probe grün und rot gesehen. Prüfer vor dem Start: Nachtrag in KRITERIEN_lr512.md. Start verzögert auf 16:20 (Absprache Evo: ab dann 4 Kerne).
  2026-11-05 16:40 Start 2026-11-05 16:36:35 (Kontrollzeile: Lib 1eb78bc1, Worker de34a553, Lauf ecd0d42a, Kriterien cec3c288, kurz9000 8d232de6, gen 73dc1386/cd55da55/2ed11fda). Der verzögerte Starter um 16:20 scheiterte (reihe_lr512.sh ohne Ausführungsrecht), von Hand per `bash reihe_lr512.sh` nachgestartet, Skript unverändert 289e1ca5. 16:39: vier Läufe s4 trainieren (L04 bei adam_t 100, LR 2e-5 wie geplant), v-Klemme und Tying an, EMBEIN 0, Fehlerkanal 0; RSS je 312 MB, frei 1,79 GB neben 8 Evo-Läufen.
  2026-11-06 09:30 Messwerte m9303-m9310
  2026-11-06 09:31 Ergebnis e558: erfuellt
  2026-11-06 09:31 Status laeuft -> ausgewertet (Ergebnis e558)
```
