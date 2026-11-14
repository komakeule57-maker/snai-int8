# snai/cuda-i8-anschluss

```text
snai/cuda-i8-anschluss - ausgewertet, begonnen 2026-10-13, angelegt 2026-10-21, zuletzt 2026-10-21 19:30
Frage: Lässt sich CUDA an den Ganzzahl-Pfad anschließen, so dass er bitgleich zur CPU rechnet (K3, K4 bitgleich, Rot-Probe K5 weicht ab, zweite Geometrie K9 bitgleich)?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus rechner-b ~/snai_pruef/cuda_i8/kriterien.txt und Rohauszügen out/K*.):
  Vorab rechner-b ~/snai_pruef/cuda_i8/kriterien.txt (2026-10-13, vor dem ersten Prüflauf): Maßstab CPU-Lauf mit unveränderter Bibliothek (R); bitgleich = jede Step-Zeile (Loss 6 Stellen, GradNorm 4 Stellen) und md5 des Modells. K1 Fix allein CPU, K2 Fix allein OpenCL, K3 Vollpatch CPU, K4 Vollpatch CUDA, K5 Rot (Kern 1,001-fach) muss abweichen, K6 CUDA + GPU_BACKWARD, K7 Rot dazu, K8 OpenCL + GPU_BACKWARD berichtet, K9 Vokabular 8192 bitgleich. URTEIL: angeschlossen, wenn K3, K4, K5 (rot), K9 bestehen.
Plan: rechner-b:~/snai_pruef/cuda_i8/kriterien.txt (Ausgangsbefund OpenCL gegen CPU, dann K1 bis K9 auf dem Prüfstand cuda_i8/t)
Darauf baut: snai/cuda-512-paar, snai/tempo-rechenwege
Rezepte:
  r187 [2026-10-21] ./lauf_test.sh <name> <lib> <cudaordner> <cpu> <gpubw>  (darin: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 php train_cluster.php $IN factory/checkpoints/paar.snai 1 1 $GEN 3 0.001 0.0001 1 0.1)
      quelltext: Projektbaum snai_edge_int8_lora + patch_cuda_i8.py; Bibliotheken bau_fix, bau_voll, bau_rot5, bau_rot7, bau_rot7b
      parameter: Prüfstand cuda_i8/t: gen.snai 512/8, 2 Schichten, ffn 2048, ctx 64, Zeichen-Vokabular (SNAI_VOCAB=knirps_gpu/vokabular/zeichen.json), p300.txt, 300 Schritte, Laufname paar, 64 Step-Zeilen; LR 0,001, Boden 0,0001, Warmup 500, WD 0,1, INT8_FULL, gebunden; OMP 2
      rechner: rechner-b (RTX 3050)
      logs: rechner-b:~/snai_pruef/cuda_i8/out/K*
      notiz: Arbeitsort rechner-b ~/snai_pruef/cuda_i8/t.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/cuda_i8/out/K*. Prüfung: die Kriteriendatei nennt als Ausgangsbefund einen früheren Lauf (Schritt 1 GradNorm 17,9867 gegen 21,8053, 400 Schritte); hier K0 auf dem 300-Schritte-Prüfstand (md5 8fd168cc52dc gegen d0d5e143c924).
  m2292 GradNorm Schritt 1 Ausgangsbefund | 15,8805 gegen 20,1554 | OpenCL gegen CPU |  | 1
  m2293 Loss Schritt 300 Ausgangsbefund | 3,224217 gegen 3,173553 | OpenCL gegen CPU |  | 1
  m2294 K1 bis K4, K6 | bitgleich | Fix/Voll |  | 5
  m2295 K5, K7, K7b | weicht ab | Rot |  | 3
  m2296 K8 erste Abweichung | Schritt 2 (21,3963 gegen 21,3961) | OpenCL + GPU_BACKWARD |  | 1
  m2297 K9, K9b | bitgleich | Vokabular 8192 |  | 2
  m2298 K9o GradNorm | 9,99 gegen 14,66 | OpenCL Vokabular 8192 |  | 1
  m2299 K9o Loss | 8,68 gegen 8,27 | OpenCL Vokabular 8192 |  | 1
Ergebnis e176 [2026-10-21 19:30]: erfuellt
  Fazit: CUDA rechnet im Ganzzahl-Pfad bitgleich zur CPU, auch mit Rückwärts auf der Karte und mit großem Vokabular; die Rot-Proben zeigen, dass die Kerne wirklich liefen. OpenCL dagegen weicht ab (K8 ab Schritt 2, K9o deutlich). Für Ganzzahl-Läufe auf der Karte ist CUDA der Weg, OpenCL nicht.
  Offen: Einzelpositions-Pfad (batched_i8=0), LoRA auf der Karte, andere Karten (laut Kriteriendatei nicht geprüft).
  Datei: rechner-b:~/snai_pruef/cuda_i8/kriterien.txt
Chronik:
  2026-10-21 19:29 angelegt (Nachtrag: Nachtrag 2026-10-21 aus rechner-b ~/snai_pruef/cuda_i8/kriterien.txt und Rohauszügen out/K*.)
  2026-10-21 19:29 Rezept r187
  2026-10-21 19:29 Status geplant -> laeuft (Rezept r187)
  2026-10-21 19:29 Messwerte m2292-m2299
  2026-10-21 19:30 Ergebnis e176: erfuellt
  2026-10-21 19:30 Status laeuft -> ausgewertet (Ergebnis e176)
```
