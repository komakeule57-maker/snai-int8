# snai/ditto-eigen

```text
snai/ditto-eigen - ausgewertet, angelegt 2026-10-26, zuletzt 2026-10-26 13:28
Frage: Senkt Unlikelihood auf Wiederholungen INNERHALB der eigenen Beam-Fortsetzungen (Welleck et al. 2019, L_UL-seq), als Feinabstimmung ab M, die Beam-Schleife unter M, ohne Beleg und Kopieren aus dem Kontext zu treffen?
Kriterium (festgelegt 2026-10-26 11:43, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/ditto2/kriterien_eigen.txt (md5 7b7ef3c0, mit Rot-Probe und Pruefer). Arme ab M_sK (3 Saaten, gepaart), 1 Epoche auf eigen_sK.txt (450 eigene Beam-3-Fortsetzungen von M_sK + gleich grosse nat-Stuecke), lib UL, LR 1e-4, Warmup 0: K0 = Fortsetzungen ohne Verlust (Kontrolle), UL = Kandidaten (Token in einem 6-Token-n-Gramm, das in derselben Fortsetzung schon vorkam) -log(1-p), Rest 0; ULC = UL + CE auf dem Rest; UL4 = UL mit n=4. Regel je Arm und Saat, 3/3 ja, 0/3 nein, sonst saatabhaengig: E* (tragend) U_X <= 0,9 U_M ueber 24 Prompts (knapp: 95-%-Intervall schliesst 0,9 ein -> 36 Prompts); S Beleg >= 0,9 M UND TP1 nl >= 0,9 M; K' H_X - H_CT <= 2 %. erfuellt = UL, ULC oder UL4 mit E*, S, K' 3/3, danach Bestaetigung mit 3 neuen Saaten; erfuellt K0 selbst E* 3/3, zusaetzlich U_X <= 0,9 U_K0 in 3/3 noetig (sonst keine_aussage). teilweise = E* und S 3/3. verfehlt = UL, ULC und UL4 je E* 0/3 oder S 0/3. keine_aussage sonst.
Plan: rechner-a: Erzeugung der Fortsetzungen in 9 Stroemen (gen_eigen.sh, OMP 1, ~1,5 h), Datenbau bau_eigen.py, dann je Saat eine Kette K0 -> UL -> ULC -> UL4 (OMP 3, je ~10-15 min), Messung in 4 Stroemen (mess6, textmess10, beam12, beam12n), Auswertung boot_eig.py (aus boot_mas.py), Reserve an knappen Faellen. rechner-b nicht gebraucht.
Baut auf: snai/ditto-maske, snai/ditto-einstieg, snai/ditto-knirps
Darauf baut: snai/ditto-eigen-dosis
Rezepte:
  r429 [2026-10-26] cd ~/snai_pruef/ditto2
# 1) Erzeugung (12:05-12:16): for K in 1 2 3; do for T in 0 1 2; do bash gen_eigen.sh $K $T 3 & done; done; wait
# 2) Daten: for K in 1 2 3; do python3 bau_eigen.py $K; done
# 3) Training + Messung (Start 12:17): for K in 1 2 3; do setsid nohup bash eig.sh $K > log/eig_s$K.nohup 2>&1 < /dev/null & done
#    eig.sh je Arm: env $EX SNAI_UL_LOG=1 SNAI_CORTEX_LIB=$B/bau/libcortex_UL.so SNAI_START_OFFSET=$OFF SNAI_TRAIN_MODE=pretrain SNAI_TIE_EMBEDDINGS=1 SNAI_INT8_FULL=1 SNAI_FORCE_CPU=1 SNAI_I8_MOM_SR=mv SNAI_WARMUP_STEPS=0 SNAI_GAIN_GUARD=0 OMP_NUM_THREADS=3 nice -n 15 php train_cluster.php $B/daten/eigen_s$K.txt factory/checkpoints/ft.snai 1 1 factory/checkpoints/M_s$K.snai 3 0.0001 0 1 0.1
#    EX: K0 "SNAI_UL_N=6 SNAI_UL_KAND=maske", UL "SNAI_UL_N=6", ULC "SNAI_UL_N=6 SNAI_UL_REST=ce", UL4 "SNAI_UL_N=4"
#    danach mess6.sh, textmess10.sh, beam12.sh, beam12n.sh je Arm (4 Stroeme je Saat)
# 4) Auswertung: python3 boot_eig.py | tee log/boot_eig.out (knapp: bash beam12r.sh X_sK ~/snai_pruef/ditto2/arme/X_sK.snai)
      quelltext: kriterien_eigen.txt 7b7ef3c0; lib bau/libcortex_UL.so dc357ab1 (cortex_ul.nim 659b7034 = patch_ul.py 579d6000 auf cortex_mas.nim 43592cba); patch_ul_php.py bcf89e0a -> train_worker.php 1f795e41 (proj_ul, proj_ul_s2, proj_ul_s3), tensor_ffi_adapter.php ac2c9616; gen_eigen.sh e6fe4436 (Engine merkmal/prodtest/proj_sr, ohne SNAI_CORTEX_LIB); prompts_eigen.py d686e4b6 -> daten/prompts_eigen.txt f0bb71ed; bau_eigen.py 91744e3b; eig.sh e65d1c6b; boot_eig.py aa0bd029 (patch_boot_eig.py a450a169 auf boot_mas.py 84d6d29b); mess6.sh 2d5e4b51, textmess10.sh 3bbf1ab1, beam12.sh f738a3d3, beam12n.sh a678460d, beam12r.sh 44b9109d
      parameter: Basis M_sK (~/snai_pruef/ditto/arme/M_sK.snai a69e1f4b/73fdf529/48c5cef3), 128/4/4 int8 voll gebunden; 1 Epoche, LR 1e-4 konstant, Warmup 0, WD 0,1, ctx 512, OMP 3; Daten daten/eigen_sK.txt cce43387/353402d2/1881688c (449/449/450 eigene Fortsetzungen, je ein gleich langes nat.txt-Stueck davor, Saat 20261026; je eine leere Fortsetzung in s1 und s2 weggelassen: Modell gab sofort Textende aus, rc=0), 262797 Token / 514 Schritte (s1), davon 115295 Token Maske 2. Erzeugung: Beam 3, ROHPROMPT, 256 Token, OMP 1, 9 Stroeme.
      seed: Saat am Laufnamen ft.snai; SNAI_START_OFFSET 0/1000003/2000003 fuer s1/s2/s3 (Ordner proj_ul/proj_ul_s2/proj_ul_s3); Bootstrap 2000 Ziehungen Saat 20261024
      rechner: rechner-a
      logs: ~/snai_pruef/ditto2/log/{K0,UL,ULC,UL4}_sK.log, log/eig.log, log/eig_sK.nohup, log/gen.log, mess/gen_sK/ (teil*.txt, rc*.log, gen*.err, md5.txt), mess/*_sK*/, arme/{K0,UL,ULC,UL4}_sK.snai
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ditto2/log/boot_eig.out (fb448be9; boot_eig.py aa0bd029). Fehlerkanal: alle 12 Trainingslaeufe rc=0, 0 NaN/Fatal/VETO/NET2NET, Schritt-1-Verlust je Saat in K0/UL/ULC gleich (2,704194 / 3,441365 / 2,882508), Beam 24/24 rc=0 ohne Fehler, Text-Sonde nur die bekannten Saetze 121/122 uebersprungen; Erzeugung 3x450 rc=0, je eine leere Fortsetzung in s1/s2 weggelassen
  m5840 U Trainings-Fortsetzungen von M (unscharf K=2) | 0,488 / 0,402 / 0,436 | M | 1-3 | 450
  m5841 Kandidatenanteil UL (n=6) an eigenen Token | 0,375 / 0,303 / 0,329 | UL | 1-3 | ~115000
  m5842 U/U_M (24 Prompts) | 0,90 / 1,06 / 0,77 | K0 | 1-3 | 24
  m5843 U/U_M (24 Prompts) [95-%-Intervall] | 0,50 [0,36-0,66] / 0,48 [0,33-0,67] / 0,58 [0,43-0,78] | UL | 1-3 | 24
  m5844 U/U_M (24 Prompts) | 0,96 / 1,05 / 0,98 (alle knapp) | ULC | 1-3 | 24
  m5845 U/U_M (24 Prompts) [95-%-Intervall] | 0,63 [0,54-0,75] / 0,38 [0,25-0,55] / 0,50 [0,34-0,71] | UL4 | 1-3 | 24
  m5846 Beleg A/A_M | 0,93 / 0,92 / 0,86 | K0 | 1-3 | 120
  m5847 Beleg A/A_M | 0,90 / 0,83 / 0,78 | UL | 1-3 | 120
  m5848 Beleg A/A_M | 0,90 / 0,85 / 0,78 | ULC | 1-3 | 120
  m5849 Beleg A/A_M | 0,90 / 0,84 / 0,78 | UL4 | 1-3 | 120
  m5850 TP1 nl /M | 0,99 / 1,00 / 1,00 | K0 | 1-3 | 198
  m5851 TP1 nl /M | 0,93 / 0,86 / 0,85 | UL | 1-3 | 198
  m5852 TP1 nl /M | 0,97 / 0,93 / 0,90 | ULC | 1-3 | 198
  m5853 TP1 nl /M | 0,94 / 0,86 / 0,83 | UL4 | 1-3 | 198
  m5854 Held-out H-H_CT / H-H_M | -0,9/-2,4/-2,4 % / +2,5/+2,0/+2,4 % | K0 | 1-3 | 200
  m5855 Held-out H-H_CT / H-H_M | -0,3/-1,4/-0,7 % / +3,1/+3,0/+4,2 % | UL | 1-3 | 200
  m5856 Held-out H-H_CT / H-H_M | -0,2/-1,4/-1,5 % / +3,2/+2,9/+3,4 % | ULC | 1-3 | 200
  m5857 Held-out H-H_CT / H-H_M | -0,2/-1,4/-0,6 % / +3,2/+3,0/+4,4 % | UL4 | 1-3 | 200
  m5858 U_UL/U_K0 (Mechanismus) | 0,55 / 0,45 / 0,76 -> 3/3 unter 0,9 | UL | 1-3 | 24
  m5859 U_UL4/U_K0 | 0,71 / 0,36 / 0,65 -> 3/3 | UL4 | 1-3 | 24
  m5860 U_ULC/U_UL | 1,93 / 2,20 / 1,68 | ULC | 1-3 | 24
  m5861 Urteil je Arm | K0 E* 2/3 S 2/3 K' 3/3; UL E* 3/3 S 1/3 K' 3/3; ULC E* 0/3 S 1/3 K' 3/3; UL4 E* 3/3 S 1/3 K' 3/3 | alle | 1-3 | 3
Ergebnis e377 [2026-10-26 13:28]: keine_aussage
  Fazit: Unlikelihood auf den eigenen Beam-Wiederholungen bricht als erster Eingriff die DITTO-Tauschlinie: U/U_M 0,50 / 0,48 / 0,58 (UL, Intervalle weit unter 0,9, gepaart gegen K0 0,55 / 0,45 / 0,76), Held-out unter CT 3/3, Beleg/M aber 0,90 / 0,83 / 0,78 und TP1/M 0,93 / 0,86 / 0,85, also S nur 1/3. Nach der Vorab-Regel keine_aussage. Ein Teil der Kosten stammt schon vom Weitertraining selbst (K0 ohne Strafe: Beleg 0,93 / 0,92 / 0,86, Held-out +2 bis +2,5 % gegen M). UL4 (n=4) wie UL. ULC (CE auf eigenen Token) hebt die Wirkung auf (U_ULC/U_UL 1,7-2,2) und ist verworfen. Die Schleife hat viel Abstand zur Schwelle, darum ist die naechste Reihe eine kleinere Dosis bei gleicher Methode: snai/ditto-eigen-dosis (LR 5e-5 und 2,5e-5, K0 und UL je Rate).
  Offen: Nur eine Erzeugungsrunde (Welleck erzeugt laufend neu), eine LR, n=6/4, ein Basismodell 128/4/4. Ob die Grundkosten von K0 (Weitertraining mit LR 1e-4) bei kleinerer LR verschwinden und UL dann S 3/3 erreicht, ist ungemessen. Ob CE auf eigenen Saetzen die Schleife ursaechlich verstaerkt, ist nicht isoliert.
  Datei: rechner-a:~/snai_pruef/ditto2/ERGEBNIS_eigen.md
Chronik:
  2026-10-26 11:43 angelegt
  2026-10-26 12:17 Rezept r429
  2026-10-26 12:17 Status geplant -> laeuft (Rezept r429)
  2026-10-26 13:28 Messwerte m5840-m5861
  2026-10-26 13:28 Ergebnis e377: keine_aussage
  2026-10-26 13:28 Status laeuft -> ausgewertet (Ergebnis e377)
```
