# snai/merkmal-gains-fp32

```text
snai/merkmal-gains-fp32 - ausgewertet, begonnen 2026-10-18, angelegt 2026-10-21, zuletzt 2026-10-21 19:23
Frage: Ist das Kippen der RMS-Gains (Schicht 1, FFN) bei korrektem Adam eine Eigenschaft von Architektur und Rezept (dann auch bei reinem FP32-Training) oder der int8-Gewichte?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/sr/kriterien_float_gfl.txt (TEST A), Kopf '2026-10-18 ~22:20, VOR dem Start', ERGEBNIS TEST A 2026-10-18 23:40):
  Drei ungebundene Arme, s0 ab Genesis, Saaten 1-3: U0 int8 Vorgabe, UMV int8 SR mv, UF FP32. Messgroesse und Regel wie snai/merkmal-gains (Median L1.rms_ffn Ende s0; KIPPT < 0,05 in allen drei Saaten, GESUND >= 0,3 in allen drei, sonst saatabhaengig). Kontrolle: U0 GESUND und UMV KIPPT, sonst UF nicht deutbar. Lesart: UF KIPPT -> kein int8-Thema; UF GESUND -> haengt an den int8-Gewichten.
Baut auf: snai/merkmal-gains
Darauf baut: snai/merkmal-gains-fest, snai/gains-bestand, snai/gains-archaeologie, snai/wd-gains, snai/gains-v, snai/residuum-gains, snai/tying-gains
Rezepte:
  r159 [2026-10-21] bash ~/snai_pruef/knirps_sr/lauf_untied.sh <U0|UMV|UF> <saat> (Segment s0 ab gross_gen_s<S>; U0/UMV dtype 3 mit SNAI_INT8_FULL=1, UMV SNAI_I8_MOM_SR=mv; UF dtype 1 ohne SNAI_INT8_FULL; SNAI_TIE_EMBEDDINGS ungesetzt); messe_u.sh
      quelltext: proj_sr_basis, libcortex.so dfcc4711; lauf_untied.sh ba611188, messe_u.sh 805e52ab, gains_sr.php 06dea5e6
      parameter: ungebunden (Float kann nicht gebunden trainieren), sonst wie Langlauf: LR 0,001, Warmup 500, Abklingen 727208, WD 0,1 inkl. Embeddings (Gains ohne Decay), CPU, OMP 1
      seed: Saat 1, 2, 3
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/knirps_sr/log_u/, u_U0.jsonl, u_UMV.jsonl, u_UF.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/sr/kriterien_float_gfl.txt (ERGEBNIS TEST A); Rohdateien rechner-b:~/snai_pruef/knirps_sr/u_U0.jsonl, u_UMV.jsonl, u_UF.jsonl nicht einzeln nachgelesen
  m1733 Median L1.rms_ffn s0 | 0,909 | U0 | 1 | 96
  m1734 Median L1.rms_ffn s0 | 0,648 | U0 | 2 | 96
  m1735 Median L1.rms_ffn s0 | 1,149 | U0 | 3 | 96
  m1736 Median L1.rms_ffn s0 | 0,003 | UMV | 1 | 96
  m1737 Median L1.rms_ffn s0 | 0,003 | UMV | 2 | 96
  m1738 Median L1.rms_ffn s0 | 0,003 | UMV | 3 | 96
  m1739 Median L1.rms_ffn s0 | 0,003 | UF | 1 | 96
  m1740 Median L1.rms_ffn s0 | 0,003 | UF | 2 | 96
  m1741 Median L1.rms_ffn s0 | 0,006 | UF | 3 | 96
  m1742 Kanaele < 0,05 | 3 | U0 | 1 | 96
  m1743 Kanaele < 0,05 | 15 | U0 | 2 | 96
  m1744 Kanaele < 0,05 | 5 | U0 | 3 | 96
  m1745 Kanaele < 0,05 | 70 | UMV | 1 | 96
  m1746 Kanaele < 0,05 | 84 | UMV | 2 | 96
  m1747 Kanaele < 0,05 | 82 | UMV | 3 | 96
  m1748 Kanaele < 0,05 | 84 | UF | 1 | 96
  m1749 Kanaele < 0,05 | 85 | UF | 2 | 96
  m1750 Kanaele < 0,05 | 66 | UF | 3 | 96
  m1751 Held-out L s0 | 1,441 | U0 | 1 | 300
  m1752 Held-out L s0 | 1,435 | U0 | 2 | 300
  m1753 Held-out L s0 | 1,435 | U0 | 3 | 300
  m1754 Held-out L s0 | 1,438 | UMV | 1 | 300
  m1755 Held-out L s0 | 1,437 | UMV | 2 | 300
  m1756 Held-out L s0 | 1,438 | UMV | 3 | 300
  m1757 Held-out L s0 | 1,433 | UF | 1 | 300
  m1758 Held-out L s0 | 1,424 | UF | 2 | 300
  m1759 Held-out L s0 | 1,427 | UF | 3 | 300
  m1760 F s0 | 6,4 % | U0 | 1 | 500
  m1761 F s0 | 8,4 % | U0 | 2 | 500
  m1762 F s0 | 5,6 % | U0 | 3 | 500
  m1763 F s0 | 4,6 % | UMV | 1 | 500
  m1764 F s0 | 7,2 % | UMV | 2 | 500
  m1765 F s0 | 4,8 % | UMV | 3 | 500
  m1766 F s0 | 7,0 % | UF | 1 | 500
  m1767 F s0 | 7,4 % | UF | 2 | 500
  m1768 F s0 | 8,0 % | UF | 3 | 500
Ergebnis e150 [2026-10-21 19:23]: erfuellt
  Fazit: Kein int8-Thema: Auch reines FP32-Training legt die Gains in s0 still, waehrend die Kontrolle mit Ratsche gesund bleibt. Das Kippen gehoert zu Architektur und Rezept mit korrektem Adam; der int8-Pfad muss deshalb nicht weiter danach durchsucht werden. Ob es etwas kostet, ist damit nicht gesagt (snai/merkmal-gains-fest).
  Offen: Ungebunden statt gebunden (zweite Aenderung gegen die Langlaeufe, durch die Kontrolle U0/UMV abgedeckt). Nur s0.
  Datei: rechner-a:~/snai_pruef/merkmal/sr/kriterien_float_gfl.txt
Chronik:
  2026-10-21 19:22 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/sr/kriterien_float_gfl.txt (TEST A), Kopf '2026-10-18 ~22:20, VOR dem Start', ERGEBNIS TEST A 2026-10-18 23:40)
  2026-10-21 19:22 Rezept r159
  2026-10-21 19:22 Status geplant -> laeuft (Rezept r159)
  2026-10-21 19:23 Messwerte m1733-m1768
  2026-10-21 19:23 Ergebnis e150: erfuellt
  2026-10-21 19:23 Status laeuft -> ausgewertet (Ergebnis e150)
```
