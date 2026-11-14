# snai/swiglu-karte

```text
snai/swiglu-karte - ausgewertet, angelegt 2026-11-12, zuletzt 2026-11-12 19:45
Frage: Rechnet SwiGLU nach Aufheben der Kartensperre auf der CUDA-Karte (rechner-b, 512/L2/ctx256 Zeichen, r487) richtig, und bleibt SiLU auf der Karte bytegleich zum Original?
Kriterium (nachgetragen, Beleg: Kriterium stand vor dem Lauf im Kopf von rechner-b:~/snai_pruef/swiglu512/pruef.sh (2026-11-12 ~19:38); Messbuch-Eintrag nach dem Lauf. Rot-Proben in pruef2.sh nachgeholt, weil die erste Wahl (SNAI_RESIDENT=ROT) auf einem nicht benutzten Weg lag und die g/u-Rot an der Genesis nahezu symmetrisch ist.):
  P1: SiLU Karte 100 Schritte, Umbau = Original 73620b8 (md5 Endstand); Rot auf den benutzten Wegen muss md5 ändern. P2: SwiGLU Karte = SwiGLU CPU (md5), Bezug SiLU Karte = SiLU CPU. P3: SwiGLU-Gradient auf der Karte gegen PyTorch wie snai/swiglu-umbau D (cos >= 0,95, |rr-1| <= 10 % an Tensoren >= 1e-3 der größten); Rot g/u getauscht muss reißen.
Baut auf: snai/swiglu-umbau
Darauf baut: snai/swiglu-512
Rezepte:
  r699 [2026-11-12] rechner-b: cd ~/snai_pruef/swiglu512 && ./pruef.sh; ./pruef2.sh
      quelltext: alt = git archive 73620b8 (cortex.nim ca27e492, Lib c553f412), neu = Fork-Arbeitsbaum (cortex.nim ac523520, Lib 689ce92b, Kartensperre aufgehoben), beide auf rechner-b gebaut (= rechner-a-Bauten bytegleich); libcortex_cuda.so d78a86ed; Dump-Lib a76ea863/0a4d9a96; vergleich_swi.py (Pfad auf swiglu512/ref)
      parameter: Rezept r487 (Zeichen 256, 512/8 Köpfe/ctx 256/L2), 100 Schritte (Anfang seg0), Warmup 50, GPU-Adam + GPU-Rückwärts, SG h=1360, Saat 1
      rechner: rechner-b, RTX 3050, 1 Prozess
      logs: rechner-b:~/snai_pruef/swiglu512/log/pruef.txt, pruef2.txt, gd.jsonl, gd2.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/swiglu512/log/pruef.txt, pruef2.txt, gd.jsonl, gd2.jsonl
  m10734 P1 SiLU Karte md5 alt / neu | 1f211957 / 1f211957 | SI | 1 | 1
  m10735 P1 Rot RESIDENT=ROT (Weg nicht benutzt) | 1f211957 unverändert, ungültige Rot | SI | 1 | 1
  m10736 P1 Rot GPU_ADAM_ROT / SILU_EXP=ROT | 8fb8576c / b12ca0be | SI | 1 | 1
  m10737 P2 SwiGLU Karte / CPU / Karte Wiederholung | a1c8e40e / a1c8e40e / a1c8e40e | SG | 1 | 1
  m10738 P2 SiLU CPU (Bezug, = Karte) | 1f211957 | SI | 1 | 1
  m10739 P2 Rot SwiGLU GPU_ADAM_ROT | 4fc3dc1a | SG | 1 | 1
  m10740 P3 cos min, rr, reissen Genesis SiLU | 0,9979, 0,994-1,005, 0/18 | SI | 1 | 1
  m10741 P3 cos min, rr, reissen Genesis SwiGLU | 0,9980, 0,987-1,007, 0/17 | SG | 1 | 1
  m10742 P3 Rot g/u Genesis (nahezu symmetrisch) | 1/17 reissen | SG | 1 | 1
  m10743 P3 cos min, rr, reissen nach 100 Kartenschritten | 0,9940, 0,909-1,009, 0/18 | SG | 1 | 1
  m10744 P3 Rot g/u nach 100 Kartenschritten | 18/18 reissen | SG | 1 | 1
Ergebnis e648 [2026-11-12 19:45]: erfuellt
  Fazit: SwiGLU rechnet auf der Karte richtig und bytegleich zur CPU, SiLU bleibt auf der Karte bytegleich zum Original. Der Umbau besteht darin, die Kartensperre aufzuheben; die GEMMs gehen nach Matrixform auf die Karte, RESIDENT lehnt SwiGLU sichtbar ab. Damit ist der 512er-Test auf der Karte zulässig. Lehre zur Rot-Probe: Sie muss auf einem benutzten Weg liegen, und die g/u-Vertauschung ist an der Genesis nahezu symmetrisch (silu(x) ≈ x/2), taugt also erst an einem trainierten Stand.
  Offen: RESIDENT (ganze Schicht auf der Karte) kennt SwiGLU nicht; bei Matrizen über der Kartenschwelle (Breite >= 1024) wäre SwiGLU deshalb deutlich langsamer als SiLU. OpenCL nicht geprüft. Nur 100 Schritte, eine Saat; rr 0,909 nahe der 10-%-Grenze an einem Tensor.
Chronik:
  2026-11-12 19:44 angelegt (Nachtrag: Kriterium stand vor dem Lauf im Kopf von rechner-b:~/snai_pruef/swiglu512/pruef.sh (2026-11-12 ~19:38); Messbuch-Eintrag nach dem Lauf. Rot-Proben in pruef2.sh nachgeholt, weil die erste Wahl (SNAI_RESIDENT=ROT) auf einem nicht benutzten Weg lag und die g/u-Rot an der Genesis nahezu symmetrisch ist.)
  2026-11-12 19:45 Rezept r699
  2026-11-12 19:45 Status geplant -> laeuft (Rezept r699)
  2026-11-12 19:45 Messwerte m10734-m10744
  2026-11-12 19:45 Ergebnis e648: erfuellt
  2026-11-12 19:45 Status laeuft -> ausgewertet (Ergebnis e648)
```
