# snai/norm-je-tensor

```text
snai/norm-je-tensor - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 19:11
Frage: Welcher Tensor welcher Schicht traegt den Normanstieg s4 zu K1 und s4 zu s9, und haengt die Embedding-Gruppe nur am Quadrat der Final-Gain?
Kriterium (festgelegt 2026-11-02 18:19, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/gradnorm/kriterien_tensor.txt. F1: Anteil am Anstieg der mittleren Norm^2; TRAEGT Tensortyp >= 0,7 oder Einzeltensor >= 0,5, sonst VERTEILT, Knapp 5 %. F2: Q_F = [emb(x)/emb(s4)]/[RMS(g_final x)/RMS(g_final s4)]^2; F ERKLAERT in [0,8;1,25] an s0,s5,s6,s7,s8,s9; F NICHT wenn einer ausserhalb [0,5;2] oder mehr als die Haelfte ausserhalb [0,8;1,25]; sonst OFFEN. Beide Lesarten: alle sechs und nur s0,s5,s7 (blind). Rot: Summe gegen total_sq, doppelt gezaehlter Tensor, skn_W analytisch. Teil 2 vorab: Decay nur auf rms_final gegen nur auf rms_att und rms_ffn.
Baut auf: snai/gradnorm-zerlegung, snai/skala-norm, snai/wdg-norm
Darauf baut: snai/wdg-final, snai/genesis-norm, snai/adamc-dc
Rezepte:
  r528 [2026-11-02] cd ~/snai_pruef/gradnorm; werkzeug/schlange_gt.sh; python3 werkzeug/gt_sum.py log/gt_*.log; python3 werkzeug/auswerten_gt.py
      quelltext: werkzeug/patch_gt.py, proj_gt = proj_gn + Patch, Lib fba9f15f, auswerten_gt.py
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/gradnorm/log/gt_*.log, log/auswertung_gt.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/gradnorm/log/auswertung_gt.txt; Fehlerkanal leer, Rot a 4,74e-07 gegen 7,40e-02, Rot b c² auf 4 Stellen, Rot c GF 4,3700 und 2,9327
  m7768 F1 Anteil emb | 0,490/0,489/0,506 | dc_K1 | r1,r2,r3
  m7769 F1 Anteil down | 0,181/0,180/0,178 | dc_K1 | r1,r2,r3
  m7770 F1 Anteil v | 0,117/0,124/0,117 | dc_K1 | r1,r2,r3
  m7771 F1 Anteil up | 0,099/0,096/0,093 | dc_K1 | r1,r2,r3
  m7772 F1 Anteil o | 0,082/0,082/0,078 | dc_K1 | r1,r2,r3
  m7773 F1 Anteil emb, down, v, o, up | 0,328/0,223/0,211/0,113/0,092 | s9
  m7774 F1 größter Schichttensor L0.w_down | 0,145/0,146/0,144 | dc_K1 | r1,r2,r3
  m7775 F1 größter Schichttensor L0.w_down | 0,167 | s9
  m7776 Q_F | 0,916 | s0
  m7777 Q_F | 0,994 | s5
  m7778 Q_F | 0,975 | s6
  m7779 Q_F | 1,194 | s7
  m7780 Q_F | 1,003 | s8
  m7781 Q_F | 0,985 | s9
  m7782 Q_F | 1,197/1,196/1,211 | dc_K1 | r1,r2,r3
  m7783 Q_F | 1,134/1,145/1,162 | dc_G | r1,r2,r3
  m7784 Q_E | 0,835/1,072/1,139/1,485/1,173/1,116 | s0,s5,s6,s7,s8,s9
  m7785 Q_E | 1,090/1,089/1,100 | dc_K1 | r1,r2,r3
  m7786 Q_E | 0,673/0,676/0,693 | dc_G | r1,r2,r3
Ergebnis e469 [2026-11-02 19:11]: erfuellt
  Fazit: F1 VERTEILT in 3/3 und an s9: kein einzelner Tensor trägt den Anstieg, ein Eingriff an einer Stelle kann ihn höchstens teilweise lösen. F2 F ERKLÄRT nach Wortlaut, auch an den blinden Ständen, s7 mit 1,194 knapp. g² beschreibt den Embedding-Teil besser als 1/E², ist aber nicht isoliert, und die Arme aus snai/gradnorm-skala widersprechen einer einfachen Proportion. Nur ein direkter Eingriff trennt das: snai/wdg-final. Für v, o, up, down gilt die Spur nicht.
  Offen: Warum v, o, up, down stärker wachsen, als schrumpfende Gewichte erklären (s9 28- bis 103-fach). s7 auf frischem Datensatz. Ein Modell, eine Saat.
  Datei: rechner-a:~/snai_pruef/gradnorm/ERGEBNIS_norm_tensor.md
Chronik:
  2026-11-02 18:19 angelegt
  2026-11-02 19:11 Rezept r528
  2026-11-02 19:11 Status geplant -> laeuft (Rezept r528)
  2026-11-02 19:11 Messwerte m7768-m7786
  2026-11-02 19:11 Ergebnis e469: erfuellt
  2026-11-02 19:11 Status laeuft -> ausgewertet (Ergebnis e469)
```
