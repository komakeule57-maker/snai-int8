# snai/ditto-eigen-bestaetigung

```text
snai/ditto-eigen-bestaetigung - ausgewertet, angelegt 2026-10-26, zuletzt 2026-10-26 18:27
Frage: Wiederholt das Rezept UQW (Unlikelihood auf eigenen Beam-Fortsetzungen, Gewicht 0,5, n=6, LR 2,5e-5) auf drei NEUEN Basismodellen (neue MLE-Saaten ab drohneP_s19, Offsets 3000003/4000003/5000003) mit deren eigenen Fortsetzungen E*, S und K' je 3/3?
Kriterium (festgelegt 2026-10-26 16:05, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/ditto2/kriterien_best.txt (md5 f2afd7b6, mit Pruefer). Je Saat neu: M (nat.txt, Rezept ditto/arme.sh), CT (mix_t.txt), Fortsetzungen, K0Q (Kontrolle) und UQW, Rezept unveraendert. Regel unveraendert: E* U_UQW <= 0,9 U_M (24 Prompts, knapp -> 36); S Beleg und TP1 >= 0,9 M; K' H_UQW - H_CT <= 2 %; UQW zaehlt nur, wenn K0Q E* nicht 3/3 oder U_UQW <= 0,9 U_K0Q 3/3. erfuellt = 3/3 in allen drei -> Schleife behoben fuer dieses Modell und Rezept. 12 frische Prompts nur berichtet. Wiederholbarkeit des M-Rezepts: Neulauf mit Offset 0 muss bytegleich zu ditto/arme/M_s1.snai (a69e1f4b) sein.
Plan: best.sh je Saat 4/5/6 (M, dann CT parallel zur Erzeugung, Daten, K0Q, UQW, Messung in 4 Stroemen), chk_m.sh; Auswertung boot_best.py
Baut auf: snai/ditto-eigen-gewicht
Darauf baut: snai/ditto-eigen-kopie, snai/kopiersperre-kombi, snai/ditto-eigen-kopie-bestaetigung
Rezepte:
  r433 [2026-10-26] cd ~/snai_pruef/ditto2; for K in 4 5 6; do setsid nohup bash best.sh $K > log/best_s$K.nohup 2>&1 < /dev/null & done; setsid nohup bash chk_m.sh > log/chk_m.nohup 2>&1 < /dev/null &   (Start 16:04)
# best.sh: M (libcortex_D, DITTO_AUS=1, nat.txt, Warmup 500, LR 1e-4) -> parallel CT (mix_t.txt, gleiches Rezept) und gen_eigen.sh x3 (GEN_CK=arme/M_sK.snai) -> bau_eigen.py K -> K0Q (UL_N=6, KAND=maske) und UQW (UL_N=6, UL_GEWICHT=0.5), lib ULW, LR 2,5e-5, Warmup 0 -> Messung mess6/textmess10/beam12/beam12n (alle), beam12r (M), beam12f (M, K0Q, UQW)
# Auswertung: python3 boot_best.py > log/boot_best.out
      quelltext: kriterien_best.txt f2afd7b6; best.sh 80da2bf6; chk_m.sh; gen_eigen.sh 2dc26a44 (GEN_CK-Ueberschreibung, sonst wie e6fe4436); beam12f.sh a8243325; boot_best.py b2549385 (patch_boot_best.py da74677b auf boot_gew.py 4e82f843); bau_eigen.py 91744e3b; libs ditto/bau/libcortex_D.so e4bb3a0f, bau/libcortex_ULW.so 209b8472; Ordner proj_b4-6 (Kopien von proj), proj_ub4-6 (Kopien von proj_ul), proj_bchk
      parameter: drohneP_s19 170d4d3f; nat.txt a68a6d3e (1.563 Schritte, 800.219 Token); mix_t.txt 81ea3be0; prompts_eigen f0bb71ed; LR 1e-4 (M, CT), 2,5e-5 (K0Q, UQW); 1 Epoche; WD 0,1; OMP 3. Mchk Schritt 1 = altes M_s1 (4,079528 / GradNorm 11,3667).
      seed: SNAI_START_OFFSET 3000003 / 4000003 / 5000003 fuer Saat 4/5/6 (Mchk: 0); Saat am Laufnamen ft.snai; Bootstrap 20261024
      rechner: rechner-a
      logs: ~/snai_pruef/ditto2/log/{M,CT,K0Q,UQW}_s{4,5,6}.log, log/Mchk_s1.log, log/best.log, log/best_sK.nohup, log/gen.log, mess/gen_s{4,5,6}/, mess/*_s{4,5,6}/, arme/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: ~/snai_pruef/ditto2/log/boot_best.out (12972193), beleg_boot.py (8e3b67e9), log/best.log
  m5920 U/U_M (24 Prompts, Beam 3, unscharf K=2) | 0,63 [0,48-0,78] | UQW | s4 | 24
  m5921 U/U_M (24 Prompts, Beam 3, unscharf K=2) | 0,49 [0,36-0,64] | UQW | s5 | 24
  m5922 U/U_M (24 Prompts, Beam 3, unscharf K=2) | 0,51 [0,40-0,63] | UQW | s6 | 24
  m5923 U/U_M (24 Prompts) | 0,80 [0,65-0,97] | K0Q | s4 | 24
  m5924 U/U_M (24 Prompts) | 0,76 [0,64-0,89] | K0Q | s5 | 24
  m5925 U/U_M (24 Prompts) | 0,88 [0,75-1,03] | K0Q | s6 | 24
  m5926 U_UQW/U_K0Q (24 Prompts) | 0,78 / 0,65 / 0,58 | UQW | s4/s5/s6 | 24
  m5927 Beleg/M (Schicht A, Rang>=200; Intervall beleg_boot.py, nur berichtet) | 0,894 [0,865-0,922] | UQW | s4 | 119
  m5928 Beleg/M | 0,979 [0,952-1,006] | UQW | s5 | 119
  m5929 Beleg/M | 0,922 [0,892-0,948] | UQW | s6 | 119
  m5930 Beleg/M | 0,949 / 1,059 / 1,014 | K0Q | s4/s5/s6 | 119
  m5931 TP1 nl /M (200 Saetze frisch10) | 0,90 / 0,99 / 1,08 | UQW | s4/s5/s6 | 198
  m5932 TP1 nl /M | 0,95 / 1,06 / 1,16 | K0Q | s4/s5/s6 | 198
  m5933 H_UQW - H_CT (Held-out 200) | -5,6 / -5,1 / -6,0 % | UQW | s4/s5/s6 | 200
  m5934 H_UQW - H_M | -0,8 / -1,2 / -1,6 % | UQW | s4/s5/s6 | 200
  m5935 U/U_M frische 12 Prompts (nur berichtet) | 0,45 [0,32-0,58] / 0,54 [0,37-0,74] / 0,53 [0,41-0,67] | UQW | s4/s5/s6 | 12
  m5936 U/U_M frische 12 Prompts (nur berichtet) | 0,85 / 0,85 / 1,00 | K0Q | s4/s5/s6 | 12
  m5937 Wiederholbarkeit M_s1 (Offset 0, proj_bchk) | bytegleich a69e1f4b | M | s1 | 1
Ergebnis e381 [2026-10-26 18:27]: keine_aussage
  Fazit: Rezept UQW NICHT bestaetigt: E* 3/3 (U 0,49-0,63 x M, auf 12 frischen Prompts 0,45-0,54), K' 3/3, aber S 2/3 (Saat 4 Beleg 0,89 [0,87-0,92] x M). Die Schleifenwirkung ist saatfest und nicht an die Suchprompts angepasst; das Problem ist allein der Beleg: UL kostet gegen die Kontrolle stabil 6-9 % Beleg, ueber 6 Saaten faellt die Schwelle 0,9 je nach Streuung der Kontrolle. Das Gewicht ist dafuer ein schwacher Hebel (halbes Gewicht nur +1-2 Punkte). Naechster Schritt: Strafe auf kurze Abstaende (Kopieren aus der eigenen juengsten Ausgabe) begrenzen, Kopieren ueber weite Abstaende wie beim Beleg frei lassen; Reihe auf s1-s6, danach neue Bestaetigung.
  Offen: Schleife nicht behoben. Wiederholbarkeit M_s1 bytegleich gezeigt. Uebertrag auf prod512b ungemessen.
  Datei: ~/snai_pruef/ditto2/ERGEBNIS_best.md
Chronik:
  2026-10-26 16:05 angelegt
  2026-10-26 16:05 Rezept r433
  2026-10-26 16:05 Status geplant -> laeuft (Rezept r433)
  2026-10-26 18:26 Messwerte m5920-m5937
  2026-10-26 18:27 Ergebnis e381: keine_aussage
  2026-10-26 18:27 Status laeuft -> ausgewertet (Ergebnis e381)
```
