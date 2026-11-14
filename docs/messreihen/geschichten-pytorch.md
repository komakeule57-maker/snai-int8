# snai/geschichten-pytorch

```text
snai/geschichten-pytorch - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:30
Frage: Erreicht ein in PyTorch (float32) trainiertes Modell gleicher Bauart, gleicher Startgewichte, gleicher Daten in gleicher Reihenfolge und gleichen Rezepts dieselbe Textqualitaet wie der SnAI-Ganzzahl-Stack (INT8_FULL) beim Knirps 96x2 auf den Nano-Geschichten?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/schluss/knirps96/kriterien_pytorch.txt (= rechner-b:~/snai_pruef/knirps_gpu/pytorch/kriterien_pytorch.txt; laut Text vor dem Bau, 2026-10-15 ~14:30).):
  Gegenproben vor dem Training: G1 Bauart (Genesis in PyTorch gegen cortex_forward) groesster Logit-Unterschied <= 1e-4 und gleiche Argmax; G2 Export ebenso; Rot: G1 mit falscher RoPE-Basis und G2 mit vertauschten w_q/w_k muessen reissen; G3 Fensterzahl = PLAN_STEPS. Hauptkriterium Held-out-Loss nach Segment 4 je Paar: Abstand des Mittels < 10 % -> Gleichstand; >= 10 % und alle 3 Paare gleichgerichtet -> Richtung; uneinig -> kein Schluss. V1-V3 je Lauf.
Baut auf: snai/geschichten-tiefe
Darauf baut: snai/knirps-zeitanteil, snai/knirps-ram, snai/bauart-tiefe, snai/gradient-tiefe
Rezepte:
  r64 [2026-10-21] rechner-b ~/snai_pruef/knirps_gpu/pytorch/reihe_torch.sh (cd proj_t; ~/snai_pruef/torch_venv/bin/python ../pytorch/torch_knirps.py train factory/checkpoints/gesch_gen_d96h6L2_s<S>.snai ../pytorch/f_s<S>_seg0..4.bin --aus ../pytorch/torch_s<S>); Fensterfolge aus PHP exportiert (fenster_export.php)
      quelltext: torch_knirps.py 6ba90257, reihe_torch.sh 2d8d7233 (md5 heute); SnAI-Arm = snai/geschichten-tiefe L2
      parameter: Bauart aus cortex.nim gelesen (Pre-RMSNorm, RoPE mit skalierter Basis ~2051, SiLU-FFN ohne Gate, gebunden), Adam 0,9/0,999/1e-8, Clipping Norm 1,0, WD 0,1 ohne Gains, Warmup 500, Cosinus 0,001 -> 0,0001 bis 25.000; PyTorch-Modell als SNAI_V5 exportiert und mit den unveraenderten Werkzeugen gemessen (float-Vorwaertspfad)
      seed: Paare 1, 2, 3 (gleiche Genesis und Fensterfolge)
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/knirps_gpu/log/proj_t/torch_s<S>.log, torch_s<S>.train.log, reihe_torch.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/knirps_gpu/log/proj_t/torch_s<S>.log (Loss und Rot nachgelesen); G1/G2 und Tempo
  m625 Held-out-Loss Segment 4 | 2,2357 | PyTorch | 1 | 300
  m626 Held-out-Loss Segment 4 | 2,2385 | PyTorch | 2 | 300
  m627 Held-out-Loss Segment 4 | 2,2326 | PyTorch | 3 | 300
  m628 Held-out-Loss Segment 4 | 2,2285 | SnAI int8 | 1 | 300
  m629 Held-out-Loss Segment 4 | 2,2229 | SnAI int8 | 2 | 300
  m630 Held-out-Loss Segment 4 | 2,2194 | SnAI int8 | 3 | 300
  m631 Abstand Mittel PyTorch gegen SnAI | +0,55 % (PyTorch schlechter) | PyTorch-SnAI | 1-3
  m632 SnAI vorn | 3 von 3 Paaren | - | 1-3
  m633 Rot-Probe gemischt | 8,63 | PyTorch | 1 | 300
  m634 Rot-Probe gemischt | 8,66 | PyTorch | 2 | 300
  m635 Rot-Probe gemischt | 8,66 | PyTorch | 3 | 300
  m636 G1 / G2 groesster Logit-Unterschied | 1e-9 / 7e-6 | Gegenprobe | 1 | 128
  m637 Tempo | SnAI ~15-16,5, PyTorch ~67-100 Schritte/s | -
Ergebnis e59 [2026-10-21 14:30]: gleichstand
  Fazit: Der SnAI-Ganzzahl-Stack kostet in dieser Gewichtsklasse keine messbare Textqualitaet: +0,55 % fuer PyTorch, Gleichstand, SnAI sogar in allen drei Paaren knapp vorn. Der Preis von SnAI ist das Tempo (4-6x langsamer, Ursache im Nim-Kern, snai/knirps-zeitanteil), nicht die Qualitaet. Int8 als Trainingsweg fuer Knirpse ist damit fuer kurze Laeufe gedeckt; fuer lange Laeufe gilt das nicht (Embedding-Kollaps ab ~400k Schritten, snai/schach-kollaps-trennung).
  Offen: Eine Breite, eine Tiefe, ein Rezept, ein Korpus, 25.000 Schritte.
  Datei: rechner-a:~/snai_pruef/schluss/knirps96/kriterien_pytorch.txt
Chronik:
  2026-10-21 14:29 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/schluss/knirps96/kriterien_pytorch.txt (= rechner-b:~/snai_pruef/knirps_gpu/pytorch/kriterien_pytorch.txt; laut Text vor dem Bau, 2026-10-15 ~14:30).)
  2026-10-21 14:29 Rezept r64
  2026-10-21 14:29 Status geplant -> laeuft (Rezept r64)
  2026-10-21 14:29 Messwerte m625-m637
  2026-10-21 14:30 Ergebnis e59: gleichstand
  2026-10-21 14:30 Status laeuft -> ausgewertet (Ergebnis e59)
```
