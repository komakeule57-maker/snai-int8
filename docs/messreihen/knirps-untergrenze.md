# snai/knirps-untergrenze

```text
snai/knirps-untergrenze - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 14:28
Frage: Was ist das kleinste Modell, das der echte Trainer (train_cluster.php, Ganzzahl-Stack, gebundene Einbettung, 1 Arbeiter, Vokabular 8192, ctx 64) auf echtem Text trainiert, und ab welcher Breite nutzt es Kontext? Kein Kopierversuch.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/mini/leiter.sh (Kopfkommentar "KRITERIEN (vor dem ersten Lauf)", Datei 2026-10-12 10:43:12; erster Lauf train_d2.log 10:47).):
  K1 läuft = rc 0, Ausgabe SNAI_V7, Held-out endlich. K2 lernt = Held-out <= 7,88 (höchstens 10 % des Abstands ln(V) -> Unigramm über dem Unigramm 7,752). K3 nutzt Kontext = Held-out < 7,08 (mehr als die Hälfte des Abstands Unigramm -> Bigramm 6,413). Rot-Probe: die untrainierte Genesis jeder Geometrie muss K2 verfehlen. Bezug referenz.php: ln(V) 9,011, Unigramm 7,752, Bigramm (günstigster Fall) 6,413.
Plan: rechner-a:~/snai_pruef/mini/leiter.sh
Rezepte:
  r58 [2026-10-21] ~/snai_pruef/mini/leiter.sh <name> <dim> <koepfe> <schichten> <ffn> 64 <lr> <warmup> <wd>  (darin: php init_base.php gen 8192 <dim> 64 <L> <ffn> 20261012; SNAI_TRAIN_MODE=pretrain SNAI_TIE_EMBEDDINGS=1 SNAI_INT8_FULL=1 SNAI_FORCE_CPU=1 SNAI_ACCUM_WINDOWS=1 SNAI_WARMUP_STEPS=$WU SNAI_LR_DECAY_STEPS=0 OMP_NUM_THREADS=1 php train_cluster.php factory/input/mini.txt <aus> 1 1 <gen> 3 <lr> 0 1 <wd>; Messung eval_held_out_full_i8.php <ck> factory/hold/ <H> 300)
      quelltext: mini/proj, libcortex.so md5 1c634106f31c; leiter.sh e32d42fdf2f9 (md5 gekürzt)
      parameter: Breite 2/4/8/16/32 mit 1 Schicht (1-2 Köpfe), Breite 64 mit 2 Schichten (4 Köpfe), ffn 4 x Breite; Arm prod512b-Rezept: LR 0,0001, Warmup 500, WD 0,1; Arm lr3: LR 0,001, Warmup 100, WD 0. Daten 2 MB aus pseg00 (536.730 Token, ~8.400 Schritte, ein Durchgang), Held-out 300 Fenster aus ho_mini.txt (Ende pseg03).
      seed: Genesis-Saat 20261012 (alle Geometrien), je Zelle ein Lauf
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/mini/leiter.txt, train_<name>.log, init_<name>.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/mini/leiter.txt (abgelesen, Werte = Zeilen dort)
  m557 Held-out (nats/Token) | 9,018 | Breite 2, prod512b-Rezept | 20261012 | 1
  m558 Held-out (nats/Token) | 7,758 | Breite 2, lr3 | 20261012 | 1
  m559 Held-out (nats/Token) | 8,787 | Breite 4, prod512b-Rezept | 20261012 | 1
  m560 Held-out (nats/Token) | 7,709 | Breite 4, lr3 | 20261012 | 1
  m561 Held-out (nats/Token) | 8,258 | Breite 8, prod512b-Rezept | 20261012 | 1
  m562 Held-out (nats/Token) | 7,414 | Breite 8, lr3 | 20261012 | 1
  m563 Held-out (nats/Token) | 7,865 | Breite 16, prod512b-Rezept | 20261012 | 1
  m564 Held-out (nats/Token) | 7,058 | Breite 16, lr3 | 20261012 | 1
  m565 Held-out (nats/Token) | 7,746 | Breite 32, prod512b-Rezept | 20261012 | 1
  m566 Held-out (nats/Token) | 6,814 | Breite 32, lr3 | 20261012 | 1
  m567 Held-out (nats/Token) | 7,492 | Breite 64 x 2 Schichten, prod512b-Rezept | 20261012 | 1
  m568 Held-out (nats/Token) | 6,573 | Breite 64 x 2 Schichten, lr3 | 20261012 | 1
  m569 Rot-Probe Genesis Held-out | 9,011 (alle über 7,88) | alle Geometrien | 20261012 | 12
  m570 Parameter kleinstes Modell | 16.432 | Breite 2 |  | 1
  m571 K1 rc / Magic | 0 / SNAI_V7 | alle 12 Läufe | 20261012 | 12
Ergebnis e53 [2026-10-21 14:28]: erfuellt
  Fazit: Der echte Trainer trainiert schon ab Breite 2, 1 Kopf, 1 Schicht (16.432 Parameter; Bedingung im Kern nur gerade Kopfbreite >= 2). Nach dem Wortlaut der Kriterien lernt mit LR 0,001 jede Breite (K2), Kontext nutzen ab Breite 16 (K3, 7,058 knapp unter 7,08), klar ab 32. Mit dem Produktionsrezept prod512b (LR 0,0001) lernen in einem Durchgang erst Breite 16, 32 und 64 nach K2, keine nutzt Kontext. Für Knirps-Versuche folgt: die kleinen Modelle brauchen eine höhere LR als prod512b; welcher der drei Rezeptteile (LR, Warmup, WD) das macht, ist nicht isoliert.
  Offen: LR nicht isoliert (drei Stellräder zugleich); je Zelle ein Lauf; eine Schicht kann nach Literatur nicht nach Inhalt kopieren (dafür die Kopier-Leitern, snai/kopier-knirps-leiter).
  Datei: rechner-a:~/snai_pruef/mini/leiter.sh
Chronik:
  2026-10-21 14:28 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/mini/leiter.sh (Kopfkommentar "KRITERIEN (vor dem ersten Lauf)", Datei 2026-10-12 10:43:12; erster Lauf train_d2.log 10:47).)
  2026-10-21 14:28 Rezept r58
  2026-10-21 14:28 Status geplant -> laeuft (Rezept r58)
  2026-10-21 14:28 Messwerte m557-m571
  2026-10-21 14:28 Ergebnis e53: erfuellt
  2026-10-21 14:28 Status laeuft -> ausgewertet (Ergebnis e53)
```
