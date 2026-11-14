# snai/tempo512-gpu

```text
snai/tempo512-gpu - ausgewertet, angelegt 2026-10-27, zuletzt 2026-10-27 14:28
Frage: Trainiert prod512b mit Adam auf der Karte (SNAI_I8_GPU_ADAM=1) auf rechner-b schneller als auf vserver (16,25 s/Schritt)? (als Entscheidungsgrundlage)
Kriterium (festgelegt 2026-10-27 13:30, vor dem ersten Messwert):
  Referenz R = 16,25 s/Schritt (tg1 Bilanz s5 16,17 / s6 16,33). Auf rechner-b aus prod512b_s6, erste 460 KB pseg07 (~120 Schritte), Umgebung des tg1-Workers, OMP 4, Offset 0, gleicher Laufname, Projektbaum 18d6a7df (SR im GPU-Adam). Arme nacheinander: G = Karte + GPU-Adam, C = FORCE_CPU. s/Schritt aus Step-Zeitstempeln Schritt 20 bis Ende. G schneller wenn <= 14,6 s, langsamer wenn >= 17,9 s, sonst Gleichstand; G innerhalb 15 % einer Schwelle -> G wiederholen. Stationaritaet: 20-70 gegen 70-Ende < 10 %, sonst gilt zweite Haelfte. G gegen C nur berichtet. Vorbedingungen: Rezeptzeilen (Tying, int8-Stack, LR-Decay 401012, SR m1 v1, V7), G mit [GPU-ADAM] Modus 1 ohne Rueckfall, C ohne; VRAM-Spitze < 4,5 GB; md5 G/C nur berichtet. Pruefer vorab, Einwaende in der Kriteriendatei.
Plan: rechner-b:~/snai_pruef/tempo512/kriterien.txt (Kopie rechner-a gleicher Pfad, md5 7f9320b2)
Baut auf: drei frühere Messungen (nicht im Messbuch)
Rezepte:
  r446 [2026-10-27] rechner-b ~/snai_pruef/tempo512: ./lauf_tempo.sh <G|C> <Etikett> (Laufname T). Darin: env <G: SNAI_I8_GPU_ADAM=1 | C: SNAI_FORCE_CPU=1> SNAI_TRAIN_MODE=pretrain SNAI_TIE_EMBEDDINGS=1 SNAI_INT8_FULL=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=401012 SNAI_LR_MIN_RATIO=0.1 SNAI_TELEMETRY_STEPS=100 SNAI_START_OFFSET=0 OMP_NUM_THREADS=4 OMP_WAIT_POLICY=PASSIVE LD_LIBRARY_PATH=$PWD:/opt/cuda/lib64 php train_cluster.php factory/input/kurz07.txt factory/checkpoints/T.snai 1 1 factory/checkpoints/prod512b_s6.snai 3 0.0001 0 1 0.1
      quelltext: Projektbaum rechner-a snai_edge_int8_lora git 48b983f (cortex.nim 18d6a7df, libcortex.so 9d02d504 unveraendert uebernommen, libcortex_cuda.so ecc68621); symbio_vocab.json f020d0ca, revival_config.json 65f7ffc8 (enabled false) und .heads (8) von tg1; lauf_tempo.sh ef0ff8e5
      parameter: Basis prod512b_s6.snai d9e3d9d1 (tg1), Eingabe kurz07.txt e6608011 = erste 460000 Byte pseg07 (720f795e), OMP 4, Offset 0. Arm G schaltet die Karte ganz ein (CUDA, Attention auf der Karte, dp4a-Vorwaertskern, GPU-Adam), Arm C nichts davon.
      seed: Laufname T (Fensterreihenfolge), Offset 0
      rechner: rechner-b (Ryzen 5 5500U, RTX 3050 6 GB); TDC per SIGSTOP angehalten (1,6 GB VRAM belegt), SnAI-Evo-Inferenz 2 Prozesse nebenher
      logs: rechner-b:~/snai_pruef/tempo512/ergebnis/<Etikett>.log, lauf_<Etikett>.out; Fehlstart fehlstart/G1_opencl.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/tempo512/ergebnis/{G1,C1}.log, lauf_{G1,C1}.out; tempo.py 543e03ae; tg1 ~/.cache/prod512b/s5.log, s6.log, s7.log
  m6107 Referenz tg1 s/Schritt (Bilanz s5 / s6) | 16,175 / 16,329, R = 16,25 | R | - | 2
  m6108 Gegenprobe Auswerter auf tg1-Logs (Schritt 20 bis Ende) | s6 16,326 (Bilanz 16,329), s7 16,522 (Haelften 0,8 %) | R | - | 2
  m6109 Rot-Probe Stationaritaet (synthetisches Log 4 -> 6 s) | Abweichung 11,8 %, angeschlagen | Kontrolle | - | 1
  m6110 s/Schritt Schritt 20-120 | 3,890 (Haelften 3,900 / 3,880, 0,5 %) | G | T | 1
  m6111 s/Schritt Schritt 20-120 | 8,330 (Haelften 8,320 / 8,340, 0,2 %) | C | T | 1
  m6112 Bilanz ms/Schritt ganzer Lauf | 3893,4 / 8318,3 | G / C | T | 2
  m6113 G / R | 0,239 (Schwelle schneller <= 0,9) | G | T | 1
  m6114 C / R | 0,513 | C | T | 1
  m6115 G / C | 0,467 | G | T | 1
  m6116 md5 Checkpoint G / C | 5be5c373 / 5be5c373 gleich, 28 Step-Zeilen gleich, Loss 3,52434 | G, C | T | 2
  m6117 VRAM-Spitze gesamt (davon TDC 1645 MiB) | 2114 MiB / 1645 MiB | G / C | T | 2
  m6118 RSS-Spitze | 844168 / 557104 KB | G / C | T | 2
  m6119 Last (loadavg 1 min vor / nach) | 3,46 -> 4,04 / 3,88 -> 4,21 | G / C | T | 2
  m6120 Vorbedingungen G | CUDA, ATT-GPU, CUDA-FWD dp4a, GPU-ADAM Modus 1 ohne Rueckfall, 4477 Aufrufe, SR m1 v1, V7, rc 0, 0 Fehlerzeilen | G | T | 1
  m6121 Vorbedingungen C | GPU_BACKEND=NONE, keine GPU-ADAM-Zeile, rc 0, 0 Fehlerzeilen, V7 | C | T | 1
Ergebnis e390 [2026-10-27 13:58]: erfuellt
  Fazit: Ja: prod512b mit Karte und GPU-Adam auf rechner-b 3,89 s/Schritt gegen 16,25 auf tg1 (0,24 R, Schwelle 0,9), CPU allein auf rechner-b 8,33 (0,51 R); Karte = CPU bytegleich. Je Segment ~11 h statt ~46 h. Die Zahl entscheidet den Umzug nicht allein: Karte waere fuer TDC auf rechner-b belegt, und der Umzug wechselt den Quelltextstand (Projektbaum statt tg1-Stand). Vor einem Umzug Bytegleichheit tg1-Stand gegen Projektbaum und einen laengeren Lauf gegen Drosselung pruefen.
  Offen: Bytegleichheit tg1-Stand (2363b610) gegen Projektbaum (18d6a7df); Drosselung ueber ganze Segmente; Tempo bei gleichzeitigem TDC.
  Datei: rechner-a:~/snai_pruef/tempo512/ERGEBNIS_tempo512.md (Kopie rechner-b gleicher Pfad)
Chronik:
  2026-10-27 13:30 angelegt
  2026-10-27 13:34 Rezept r446
  2026-10-27 13:34 Status geplant -> laeuft (Rezept r446)
  2026-10-27 13:34 Fehlstart G1 13:31 vor jedem gueltigen Messwert: ohne LD_LIBRARY_PATH=/opt/cuda/lib64 lud libcortex_cuda.so nicht, GPU_BACKEND=OPENCL, Warnzeile "[GPU-ADAM] ... greift aber nicht" -> per PID abgebrochen (nach 5 Schritten), Log in fehlstart/G1_opencl.log. Damit ist der Rueckfall-Nachweis der Vorbedingung einmal rot gesehen. Behoben in lauf_tempo.sh ef0ff8e5 (Pfad fuer beide Arme), Kriterien unveraendert. Abweichung vom Kriterientext: libcortex.so ist die Baum-Bibliothek 9d02d504 (aus 18d6a7df gebaut) statt eines Neubaus auf rechner-b.
  2026-10-27 13:58 Messwerte m6107-m6121
  2026-10-27 13:58 Ergebnis e390: erfuellt
  2026-10-27 13:58 Status laeuft -> ausgewertet (Ergebnis e390)
  2026-10-27 14:28 Entscheidung 2026-10-27 nach e390: kein Umzug (Stromkosten, Ausfallsicherheit). Die Karte haelt seit Tagen Dauerlast bei ~80 °C. Die offenen Punkte zu einem Umzug entfallen.
```
