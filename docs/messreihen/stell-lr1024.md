# snai/stell-lr1024

```text
snai/stell-lr1024 - ausgewertet, angelegt 2026-11-06, zuletzt 2026-11-06 21:17
Frage: Wo liegt bei 1024x4 (Rezept R ohne Eingangsfaktor, 9k, Knirps-Text, 16 Köpfe à 64) das Optimum der Spitzen-LR? Setzt sich die bei 512 beobachtete Verengung der guten Zone von oben fort (Optimum unter Breite x LR 0,1, also unter 1e-4), oder hält 1/Breite? Auftrag 06.11. ~09:45 ("Feuer frei"), Grundlage für die LR bei 4096.
Kriterium (festgelegt 2026-11-06 09:56, vor dem ersten Messwert):
  Datei rechner-a:~/snai_pruef/stell/KRITERIEN_lr1024.md (a18b3463 samt Prüfer-Nachtrag; Kopie rechner-b:~/snai_pruef/stell1024/). Sprossen S2/S1/S05/S025 = 0,0002/0,0001/0,00005/0,000025 (Breite x LR 0,205/0,102/0,051/0,026), Saaten s4-s6 gepaart, heldout 700 Fenster am Endstand. Regel D=A-B und L*/EINGEGRENZT/EBENE wörtlich wie snai/stell-lr512; KNAPP -> heldout2. Breitenurteil: VERENGUNG SETZT SICH FORT = L* ist S05 oder S025 und S1 SCHLECHTER; 1/BREITE HÄLT = S1 ist L* oder in dessen Ebene; OPTIMUM HÖHER = L* ist S2; sonst OFFEN. Nur berichtet: obere Strafe S2 - L* gegen 512 (+0,097).
Plan: rechner-a:~/snai_pruef/stell/KRITERIEN_lr1024.md; rechner-b:~/snai_pruef/stell1024/ (lauf_stell.sh, geraet1024.sh, Reihe folgt)
Baut auf: snai/stell-lr512, snai/stell-lr-leiter
Rezepte:
  r613 [2026-11-06] cd ~/snai_pruef/stell1024 && MAXJ=4 setsid -f nohup bash reihe_lr1024.sh (rechner-b); je Lauf lauf_stell.sh lr1024 <arm> - <s> daten/kurz9000.txt 3000,6000 mit CLIP_GPU=1 (SNAI_I8_GPU_ADAM=1, SNAI_I8_GPU_BACKWARD=1, SNAI_GPU_MIN_DIM=128), CLIP_OMP=3, CLIP_HEADS=16, CLIP_GENPFX=d1024_, CLIP_LR, CLIP_WARMUP=2000, CLIP_DECAY_START=8102, CLIP_DECAY_STEPS=9002, CLIP_MIN_RATIO=0.1, ohne SNAI_EMB_EIN
      quelltext: rechner-b:~/snai_pruef/stell1024: reihe_lr1024.sh 722e4bdb, lauf_stell.sh 979fc258 (per assert aus rechner-a ecd0d42a: R=stell1024, CLIP_HEADS, CLIP_OMP, SNAI_I8_GPU_BACKWARD=1), KRITERIEN_lr1024.md a18b3463, Lib-Paar libcortex.so 180651d7 + libcortex_cuda.so 962af829 (multi_stack karte_vk/proj_vk, v-Klemme auf der Karte fest eingebaut), proj_clip/train_worker.php de34a553, werkzeug/ausw_lr1024.py 9f106e1e (Probe grün und rot gesehen)
      parameter: 1024x4, 16 Köpfe (Kopfbreite 64), ffn 4096, ctx 128, gebunden, int8 voll, SR, v-Klemme, Clip 1, Revival aus, WD 0,1; Sprossen 0,0002/0,0001/0,00005/0,000025; 9.002 Schritte kurz9000; heldout 700 Fenster
      seed: Genesis init_base.php <out> 0 1024 128 4 4096 <s> auf rechner-b: s4 e4f86f65, s5 2c19efab, s6 9b5ea3d7 (Kontrolle: dieselbe Genesis bei 512 s4 auf rechner-b = 73dc1386 wie rechner-a); Fensterfolge am Laufnamen clip_s<s> (gepaart)
      rechner: rechner-b Karte RTX 3050 + 12 Kerne, bis 4 Läufe zugleich (je OMP 3), Start nur bei >= 2500 MB frei; Belegung mit multi_stack abgesprochen 06.11. ~10:10
      logs: rechner-b:~/snai_pruef/stell1024/log/lr1024.log, laeufe/lr1024/<arm>_s<s>/ (lauf.log, train.log, mess.jsonl, mess.err), log/lr1024_gains.jsonl; Vorab log/geraet1024.log
Messwerte (Groesse | Wert | Arm | Start | n):
  m9408 heldout_loss | 2.4631 | S2 | s4 | 700
  m9409 heldout_loss | 2.4662 | S2 | s5 | 700
  m9410 heldout_loss | 2.4722 | S2 | s6 | 700
  m9411 heldout_loss | 2.3549 | S1 | s4 | 700
  m9412 heldout_loss | 2.3667 | S1 | s5 | 700
  m9413 heldout_loss | 2.3537 | S1 | s6 | 700
  m9414 heldout_loss | 2.3589 | S05 | s4 | 700
  m9415 heldout_loss | 2.3605 | S05 | s5 | 700
  m9416 heldout_loss | 2.3556 | S05 | s6 | 700
  m9417 heldout_loss | 2.4099 | S025 | s4 | 700
  m9418 heldout_loss | 2.4018 | S025 | s5 | 700
  m9419 heldout_loss | 2.3976 | S025 | s6 | 700
Ergebnis e566 [2026-11-06 21:17]: erfuellt
  Fazit: Urteil nach Regel: EBENE S1/S05 (1e-4 und 5e-5, Breite x LR 0,05-0,10), beidseitig von SCHLECHTEREN Sprossen begrenzt; Breitenurteil 1/BREITE HAELT. S2-S05 +0,109 SCHLECHTER, S1-S05 +0,0001 GLEICH, S025-S05 +0,045 SCHLECHTER, nichts KNAPP (kein heldout2). Kontrollen 12/12 sauber (rc, 9002 Schritte, CUDA, heads 16, tie, sr, LR-Stützstellen, mess.err leer, keine toten Gains); Probe grün und rot vor dem Lesen. Fazit: Die beste Spitzen-LR bei 1024x4 liegt zwischen 5e-5 und 1e-4. Die Verengung von oben aus 128->512 setzt sich nicht fort: Breite x LR 0,2 kostet bei 1024 +0,109, bei 512 +0,097. Der untere Rand rückt eher nach unten. Für 4096 Planungszahl 1e-5 bis 2,5e-5, Start um 1,2e-5 (Deutung). Ein Fehlgriff nach unten bleibt billiger (Faktor 2,4). Nur berichtet: Der beste Verlust bei 1024 (2,3583) ist nicht besser als bei 512 (2,3524), bei 9k Schritten bringt die Breite also nichts. Vor 4096 ist zu klären, ob Breite auf diesem Text und Budget überhaupt nützt.
  Datei: rechner-a:~/snai_pruef/stell/ERGEBNIS_lr1024.md (Kopie rechner-b:~/snai_pruef/stell1024/, md5 d156c805)
Chronik:
  2026-11-06 09:56 angelegt
  2026-11-06 10:02 Rezept r613
  2026-11-06 10:02 Status geplant -> laeuft (Rezept r613)
  2026-11-06 10:02 Vorab-Gerät 06.11. (rechner-b, log/geraet1024.log): 60 Schritte 1024x4 s4 LR 2e-4: Karte G1 = Karte G2 = CPU G3 (SNAI_FORCE_CPU, OMP 1) bytegleich, Endstand 79ec7231, Snapshot t30 8de7d1b6. Karte 43 s für 61 Schritte (allein), CPU 233 s. VRAM-Spitze allein 957 MiB. Log zeigt "[VK] Engine: v-Klemme" nur im CPU-Lauf (vk=1), auf der Karte vk=0; die Klemme ist in 962af829 fest eingebaut (multi_stack), die Bytegleichheit Karte = CPU mit Klemme ist der Beleg. Messgerät: mess_text.php auf dem G1-Endstand, 100 Fenster, CPU-Umgebung und Karten-Umgebung beide loss 5,6321, identische Ausgabe, je ~52 s. Tokenfolge kurz9000/heldout/heldout2 auf rechner-b (intl, NFKC an) = rechner-a (ohne NFKC): md5 58f84ab7/58edf3c5/6d811c68. Prüfer vor dem Start: Nachtrag in KRITERIEN_lr1024.md. Start 10:02:25, MAXJ 4.
  2026-11-06 21:17 Messwerte m9408-m9419
  2026-11-06 21:17 Ergebnis e566: erfuellt
  2026-11-06 21:17 Status laeuft -> ausgewertet (Ergebnis e566)
```
