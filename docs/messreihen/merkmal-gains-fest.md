# snai/merkmal-gains-fest

```text
snai/merkmal-gains-fest - ausgewertet, begonnen 2026-10-18, angelegt 2026-10-21, zuletzt 2026-10-21 19:24
Frage: Kostet die Stilllegung der RMS-Gains (Schicht 1, FFN) unter MV etwas? Gepaart: MVF (MV mit festgehaltenen Gains = 1,0) gegen Langlauf MV, s0..s7, Saaten 1-3.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/sr/kriterien_float_gfl.txt (TEST B), Kopf '2026-10-18 ~22:20, VOR dem Start', ERGEBNIS TEST B 2026-10-19 03:05):
  Unter 10 % relativ = Gleichstand. STILLLEGUNG KOSTET = MVF besser als MV in B oder C um >= 10 % relativ UND Bootstrap-Intervall ohne Null, ODER L s7 in allen drei Saaten um >= 1 % besser. KOSTET NICHTS = A, B, C Gleichstand UND L s7 innerhalb 1 % in allen Saaten. Sonst kein Urteil. Nebenbedingung: MVF kollabiert nicht (F < 5 % in s5-s7).
Baut auf: snai/merkmal-gains-fp32, snai/merkmal-sr-lang-schach
Darauf baut: snai/gains-bestand
Rezepte:
  r164 [2026-10-21] bash ~/snai_pruef/knirps_sr/lauf_lang_gfl.sh <saat> (je Segment php train_cluster.php factory/input/gross_c64_seg<I>.txt factory/checkpoints/gross_gross_s<S>_s<I>.snai 1 1 <vorher> 3 0.001 0.0001 1 0.1 mit SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=727208 SNAI_I8_MOM_SR=mv SNAI_GAIN_FREEZE_FFN_LAYER=1); Schach: bash ~/snai_pruef/merkmal/sr/kette_mvf_schach.sh, python3 sr/boot_schach.py
      quelltext: proj_gfl_basis = proj_sr_basis + patch_gf.py 44ee1fe7, libcortex.so a20c3d9c (Bank: Vorgabe 10a1ee05 = alte Engine, MVF1 d9954863 != MV, Rot und Gruen gesehen); lauf_lang_gfl.sh a7bd7840, kette_mvf_schach.sh 6107956f, boot_schach.py 67d04db7
      parameter: d96 Schach, Korpus gross (gross_c64_seg0..7, 93.294 Schritte je Segment), LR 0,001 Cosinus bis 727208, Untergrenze 1e-4, Warmup 500, WD 0,1 inkl. Embeddings, gebunden, int8 FULL, CPU, OMP 1, Revival und Lade-Waechter aus; ab Genesis s0..s7; einziges Stellrad gegen MV: Gains der Schicht 1 fest auf 1,0
      seed: Saat 1, 2, 3, gepaart mit Langlauf MV (gleiche Genesis, Daten, Namen)
      rechner: rechner-b (Training), rechner-a (Schach)
      logs: rechner-b:~/snai_pruef/knirps_sr/lang_langMVF_s<S>.jsonl, log_lang/; rechner-a:~/snai_pruef/merkmal/sr/schach_mvf/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/knirps_sr/lang_langMVF_s{1,2,3}.jsonl (F, L am 2026-10-21 gelesen); Schachwerte aus kriterien_float_gfl.txt (ERGEBNIS TEST B); B relativ -9,9 % wie in der Datei uebernommen, Nachrechnung aus den gerundeten Anteilen 13,3/14,8 ergibt -10,1 % (Datei vermutlich aus ungerundeten Anteilen)
  m1990 F s5 / s6 / s7 | 0,8 / 0,4 / 0,0 % | MVF | 1 | 500
  m1991 F s5 / s6 / s7 | 0,4 / 1,0 / 0,2 % | MVF | 2 | 500
  m1992 F s5 / s6 / s7 | 0,2 / 0,4 / 0,2 % | MVF | 3 | 500
  m1993 Held-out L s7 | 1,3186 | MVF | 1 | 300
  m1994 Held-out L s7 | 1,3194 | MVF | 2 | 300
  m1995 Held-out L s7 | 1,3170 | MVF | 3 | 300
  m1996 Held-out L s7 | 1,3190 | MV | 1 | 300
  m1997 Held-out L s7 | 1,3177 | MV | 2 | 300
  m1998 Held-out L s7 | 1,3161 | MV | 3 | 300
  m1999 A Endstand s7 | 66,2 gegen 66,3 % (-0,1 % rel., KI [-3,9, +3,6]) | MVF gegen MV Saaten 1-3 |  | 3000
  m2000 B Endstand s7 | 13,3 gegen 14,8 % (-9,9 % rel., KI [-3,7, +0,9]) | MVF gegen MV Saaten 1-3 |  | 3000
  m2001 C Endstand s7 | 8,8 gegen 9,8 % (-10,2 % rel., KI [-2,6, +0,6]) | MVF gegen MV Saaten 1-3 |  | 3000
  m2002 L1.rms_ffn s7 min = median = max | 1 | MVF Saaten 1-3 |  | 96
Ergebnis e154 [2026-10-21 19:24]: keine_aussage
  Fazit: Nach der Regel kein Urteil: 'kostet nichts' scheitert knapp an C (-10,2 %, Intervall mit Null), 'Stilllegung kostet' trifft nicht zu. Was sich trotzdem sagen laesst: Die Vermutung 'das Kippen schadet' sagt voraus, dass Festhalten hilft, und das tritt in keiner der fuenf Groessen ein; wenn ueberhaupt, schneidet das Festhalten schlechter ab. Fuer den Einsatz von MV heisst das: die gekippten Gains sind kein Grund, MV zurueckzuhalten. Weiter lohnt es nur, wenn die B/C-Differenz (~10 %) interessiert, dann mit frischen Saaten 4-6.
  Offen: Ob der B/C-Abstand (beide ~-10 %, Intervalle mit Null) echt ist; braeuchte frische Saaten.
  Datei: rechner-a:~/snai_pruef/merkmal/sr/kriterien_float_gfl.txt
Chronik:
  2026-10-21 19:24 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/sr/kriterien_float_gfl.txt (TEST B), Kopf '2026-10-18 ~22:20, VOR dem Start', ERGEBNIS TEST B 2026-10-19 03:05)
  2026-10-21 19:24 Rezept r164
  2026-10-21 19:24 Status geplant -> laeuft (Rezept r164)
  2026-10-21 19:24 Messwerte m1990-m2002
  2026-10-21 19:24 Ergebnis e154: keine_aussage
  2026-10-21 19:24 Status laeuft -> ausgewertet (Ergebnis e154)
```
