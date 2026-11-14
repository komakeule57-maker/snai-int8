# snai/tf32-unlock-512

```text
snai/tf32-unlock-512 - ausgewertet, angelegt 2026-10-30, zuletzt 2026-10-30 18:45
Frage: Macht die per gpu-unlock aufgehobene TF32-Drossel einen float32-GPU-Lauf (dim 512, ctx 1024, L6, train_worker.php, CUDA/TF32-Pfad) auf rechner-b (RTX 3050, GA107) messbar schneller, bei UNVERAENDERTEM (md5-gleichem) Ergebnis?
Kriterium (nachgetragen, Beleg: Kriterium stammt aus kriterien_tf32_unlock.txt (2026-10-30, vor dem Unlock geschrieben); Reihe im Messbuch nachgetragen 2026-10-30 ~18:15 nach dem erfolgreichen Unlock, Arm N schon gemessen, Arm V steht aus.):
  Gemessen: Median Sekunden je Schritt (bench_worker.php = train_worker.php mit Pro-Schritt-microtime, verifiziert md5-gleich zum Original -> Zeitnahme nicht-perturbierend), 3 Durchgaenge je Arm auf derselben Karte allein. Arme gepaart: N "nachher" = Karte entsperrt (Bootparameter gpu_unlock.targets aktiv), V "vorher" = Karte gedrosselt (Reboot ohne Parameter). EIN Stellrad: die Drossel. Urteil: N <= 0,90 x V = "Drossel-Aus hilft"; innerhalb +-10 % = "Gleichstand" (kein Gewinn); N > 1,10 x V = "langsamer". HARTE Nebenbedingung: md5 des Ausgabemodells N == V (sonst Messung ungueltig, Modul verdaechtig). Determinismus-Rotprobe vorab bestanden: zwei identische Laeufe bytegleich (105aea27), lr-Aenderung aendert md5 -> md5-Guard gueltig. ABWEICHUNG vom vorab-Gate in kriterien_tf32_unlock.txt: der GEMM-Zeitanteil wird NICHT separat per nsys/nvprof gemessen (auf rechner-b nicht vorhanden); stattdessen direkt der gepaarte Wanduhr-Test, der die tatsaechliche Wirkung misst statt sie zu schaetzen (gruendlicher, Gate wird nicht weggelassen sondern uebersprungen zugunsten des Volltests). Reichweite: eine Karte, eine Geometrie (512/1024/L6), float32-GPU-Pfad.
Plan: rechner-b:~/Projekte/gpu-unlock/kriterien_tf32_unlock.txt
Darauf baut: snai/float32-schrittprofil-512
Rezepte:
  r473 [2026-10-30] cd ~/snai_pruef/tf32_unlock && LD_LIBRARY_PATH=$PWD php bench_worker.php bench_tf32/chunk.txt bench_tf32/<arm>_r<k>.snai 1 bench_tf32/gen512.snai 3 0.0005 1 0.0005 0.0 0.0  (3 Durchgaenge je Arm; Median der STEP_MS-Zeilen, Schritt mit halber Zeit = letztes Teilfenster)
      quelltext: rechner-b:~/snai_pruef/tf32_unlock, cortex_cuda.cu (TF32-Pfad: cublasSetMathMode CUBLAS_TF32_TENSOR_OP_MATH Z.522, cublasSgemm Z.619/789/843), libcortex_cuda.so; bench_worker.php = train_worker.php + microtime um train_step (md5-gleich verifiziert)
      parameter: Genesis bench_tf32/gen512.snai (init_base.php: vocab 8192 auto, dim 512, ctx 1024, L6, 312 MB); Chunk bench_tf32/chunk.txt (12371 B, fest aus bpe_init); 7 Schritte/Lauf; GPU-Pfad aktiv ab dim>=512, Backend CUDA/TF32 bestaetigt (GPU_BACKEND=CUDA)
      rechner: rechner-b (RTX 3050 6GB, GA107, PCI 0000:01:00.0)
      logs: rechner-b:~/snai_pruef/tf32_unlock/bench_tf32/logN_r*.txt (Arm N), logV_r*.txt (Arm V, folgt)
      notiz: Schrittzeit ~16 s, extrem gleichmaessig (<1% Streuung, Schritt 1 nur ~1% ueber Rest -> Anlauf vernachlaessigbar). Schritt 4 je Lauf ~8 s = halbes letztes Fenster. Vermutung (nicht isoliert): Engine-Overhead (viele kleine Host<->GPU-Kopien in Attention) statt GEMM -> dann wenig TF32-Hebel; der gepaarte Test entscheidet unabhaengig von der Ursache.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/tf32_unlock/bench_tf32/logN_r*.txt, 2026-10-30 ~18:10
  m6677 Median s/Schritt | 16,03 | N | r1 | 7
  m6678 Median s/Schritt | 16,08 | N | r2 | 7
  m6679 Median s/Schritt | 15,96 | N | r3 | 7
  m6680 md5 Ausgabemodell | 105aea27 | N | r1-3 | 3
  Quelle: rechner-b:~/snai_pruef/tf32_unlock/bench_tf32/logVwarm_r*.txt und gemm/sonde_warm.txt, 2026-10-30 nach Warmstart 18:21
  m6681 Median s/Schritt | 15,945 | Vwarm | r1 | 7
  m6682 Median s/Schritt | 16,054 | Vwarm | r2 | 7
  m6683 Median s/Schritt | 16,119 | Vwarm | r3 | 7
  m6684 md5 Ausgabemodell | 105aea27 | Vwarm | r1-3 | 3
  m6685 GEMM-Sonde n=4096 TF32 TFLOPS | 8,03 | Vwarm | - | 15
  m6686 GEMM-Sonde n=4096 FP32 TFLOPS | 4,16 | Vwarm | - | 15
  m6687 GEMM-Sonde n=2048 TF32 TFLOPS | 6,34 | Vwarm | - | 41
  m6688 GEMM-Sonde n=2048 FP32 TFLOPS | 4,33 | Vwarm | - | 41
  Quelle: rechner-b:~/snai_pruef/tf32_unlock/bench_tf32/logN2_r*.txt, gemm/sonde_N2_warm.txt, journalctl -k -b (18:37) stage=gfw
  m6689 Median s/Schritt | 16,035 | N2 | r1 | 7
  m6690 Median s/Schritt | 16,062 | N2 | r2 | 7
  m6691 Median s/Schritt | 15,974 | N2 | r3 | 7
  m6692 md5 Ausgabemodell | 105aea27 | N2 | r1-3 | 3
  m6693 GEMM-Sonde n=4096 TF32 TFLOPS | 12,83 | N2 | - | 15
  m6694 GEMM-Sonde n=4096 FP32 TFLOPS | 4,12 | N2 | - | 15
  m6695 GEMM-Sonde n=2048 TF32 TFLOPS | 11,26 | N2 | - | 41
  m6696 GEMM-Sonde n=2048 FP32 TFLOPS | 4,33 | N2 | - | 41
  m6697 Register ss0 beim Booten vor dem Unlock | 0x0 | nach Warmstart aus Vwarm-Boot | - | 1
Ergebnis e415 [2026-10-30 18:45]: gleichstand
  Fazit: Die Entsperrung bringt diesem float32-Lauf nichts: N/V = 0,999, alle drei Paare innerhalb +-1 %, md5 in allen Armen gleich. Der Unlock selbst wirkt nachweislich: die reine GEMM-Sonde misst TF32 unter gleichen Bedingungen (warm, Leistungsgrenze aktiv) 1,60-fach (n=4096) und 1,78-fach (n=2048) schneller, FP32 unveraendert als Kontrolle. Der Engpass liegt also nicht im GEMM. Ein Umbau der Karte beschleunigt die Engine nicht; Hebel waere der Schrittpfad selbst. Deutung, nicht gemessen: aus 1,6-fach GEMM und unter 1 % Schrittdifferenz folgt rechnerisch ein GEMM-Anteil von hoechstens rund 3 % im Schritt; die Ursache der 16 s ist nicht isoliert. Warmstart: stage=gfw zeigte ss0=0x0 statt 0x88888888, die Entsperrung ueberlebte ihn also nicht, Vwarm gilt als Arm V. Der erwartete Wert 0x46716126 kam nicht; die Selektoren sind nach Warmstart genullt, das Verhalten entspricht trotzdem der Drossel laut Sonde.
  Offen: Reichweite: eine Karte, eine Geometrie (512/1024/L6), float32-Pfad. Sonde gedrosselt nur ein Lauf. Breitere Geometrien (2048/4096) nicht gemessen. Vorab-Gate GEMM-Anteil nur rechnerisch, nicht direkt per Zeitmarke. Rotation der Durchgaenge nur blockweise N-V-N. Wo die 16 s stecken, ist offen.
Chronik (juengste 8 von 9, voll=True zeigt alle):
  2026-10-30 18:19 Rezept r473
  2026-10-30 18:19 Status geplant -> laeuft (Rezept r473)
  2026-10-30 18:19 Messwerte m6677-m6680
  2026-10-30 18:31 Messwerte m6681-m6688
  2026-10-30 18:31 Arm Vwarm ist NICHT Arm V: gemessen nach `sudo reboot` (Warmstart 18:20-18:21, Strom blieb an) ohne Bootparameter. Ob ein Warmstart die Entsperrung zuruecknimmt, ist ungeklaert: README und Modulcode sprechen von "bis Stromausschalten", unlock_610.c:958 "open PLM means already unlocked or not cold"; ohne targets= schreibt das Modul keine Zustandszeile. Vwarm == N (16,05 zu 16,03 s, md5 gleich) kann deshalb auch heissen: beide entsperrt. Fuer das Urteil fehlen: (1) Kaltstart mit echtem Stromaus, ohne Parameter: gemm_sonde + 3 Laeufe (Arm V). (2) Rot-Probe der Sonde: nach schritt_grub.sh + Reboot (dmesg "unlocked") gemm_sonde im entsperrten Zustand. Sonde: bench_tf32/gemm/gemm_sonde.cu, bislang nur einmal gelaufen, noch nie rot gesehen. Waehrend der Sonde clocks_event_reasons=0x4 (Leistungsgrenze).
  2026-10-30 18:45 Messwerte m6689-m6697
  2026-10-30 18:45 Ergebnis e415: gleichstand
  2026-10-30 18:45 Status laeuft -> ausgewertet (Ergebnis e415)
```
