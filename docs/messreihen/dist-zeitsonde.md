# snai/dist-zeitsonde

```text
snai/dist-zeitsonde - ausgewertet, angelegt 2026-11-10, zuletzt 2026-11-10 05:28
Frage: Wo geht im float32-Kern der Distro (SNAI_distro core/cortex.nim 82463d2d, praktisch gleich snai_edge) beim reinen CPU-Training die Schrittzeit hin, und welche Abschnitte lohnen als Ziel für die Parallelisierungs-Patches aus dem int8-Hauptbaum?
Kriterium (festgelegt 2026-11-10 05:10, vor dem ersten Messwert):
  Vorab festgelegt 10.11. 05:15, vor dem ersten Lauf. Messgerät: Zeitsonde SNAI_ZEIT=1 in einer Projektkopie (~/snai_pruef/threads/dist1/proj, Original an benannten Stellen gepatcht, assert md5 und assert count), je Schritt eine [ZEIT]-Zeile mit den Abschnitten mmF (Vorwärts-Matmul ohne w_out), mmF_wout, attF, mmT, gA (rückwärts ohne w_out), mmT_wout, gA_wout, attB, sm (Softmax + d_logits), upd (Clip+Adam), fwd (Vorwärts gesamt), ges; Rest vorwärts/rückwärts = Differenz. Gültig erst, wenn (a) Rot-Probe: SNAI_ZEIT_ROT=<Abschnitt> verlängert genau diesen Abschnitt um Aufrufe x 2 ms (+-20 %) und die anderen nicht; (b) Modell-md5 und Loss-Zeilen mit Sonde = ohne Sonde (ungepatchte Lib) bytegleich; (c) Summe der Abschnitte + Rest = ges (per Bau), ges gegen die ms/Schritt des Workers höchstens 5 % Abstand; (d) GPU_BACKEND=NONE im Log. Aufbau: rechner-a, OMP_NUM_THREADS=4, kein anderer Rechenprozess; Geometrien G128 (Distro-Genesis: Breite 128, 2 Schichten, Kontext 512) und G512 (Breite 512, Kontext 1024, 8 Köpfe; Schichtzahl wird vor dem Lauf festgelegt und im Rezept genannt); je 3 Läufe, erster Schritt jedes Laufs verworfen, Kennzahl = Median des Zeitanteils je Abschnitt über die Schritte, dann Median der 3 Läufe. Urteilsregel: Ein Abschnitt ist ein lohnendes Ziel, wenn sein Anteil in allen 3 Läufen >= 10 % der Schrittzeit ist UND er laut Quelltext seriell läuft oder je Position eine eigene parallele Region öffnet. Liegt ein Anteil in den Läufen teils über, teils unter 10 %: 'knapp, trägt keinen Schluss'. Der Anteil ist eine Obergrenze des Gewinns, kein Gewinn: ob ein Patch hilft, entscheidet erst ein eigener Tempovergleich (Intervallregel). Frei gewählter Parameter: Fadenzahl 4 (auf anderem Rechner andere Anteile), Vokabulargröße (bestimmt den w_out-Anteil), Fensterlänge = voller Kontext. Reichweite: ein Rechner, CPU ohne Karte, zwei Geometrien.
Darauf baut: snai/dist-par-umbau, snai/dist-attf-par
Rezepte:
  r656 [2026-11-10] ~/snai_pruef/threads/dist1/reihe.sh (ruft arm.sh zeit <g128|g512> <etikett> SNAI_ZEIT=1 OCL_ICD_VENDORS=/nonexistent; darin: php src/train_cluster.php text30k.txt ck/out.snai 1 1 modelle/<geo>.snai 1 0.00005, OMP_NUM_THREADS=4, SNAI_WARMUP_STEPS=0, SNAI_LR_DECAY_STEPS=0). Projektkopie ~/snai_pruef/threads/dist1/proj aus ~/Projekte/SNAI_distro (main 2f6d643, ohne .git und Checkpoints). Engine: core/cortex.nim 82463d2d + patch_dist1.py -> 2ba050da, libcortex_zeit.so 339859cb; Vergleichsbau ohne Patch libcortex_orig.so 23e06f70. Modelle per src/init_base.php: g128 = Vokabular 8192, Breite 128, FFN 512, Kontext 512, 2 Schichten, 2 Köpfe; g512 = Breite 512, FFN 2048, Kontext 1024, 4 Schichten (prod512b-ähnlich, nicht am Modell nachgemessen), 8 Köpfe. Text: erste 30.000 Zeichen von ~/snai_pruef/threads/text.txt. OpenCL ausgeschlossen per OCL_ICD_VENDORS=/nonexistent (ohne das rastet bei Breite 512 die eingebaute Radeon über rusticl ein), Beleg GPU_BACKEND=NONE je Lauf. Auswertung ausw.py (nur volle Fenster, erster Schritt verworfen). Abweichung vom Kriterium: rechner-a war nicht frei (ICL-Wächter mit icl_score auf prod512b_s13 seit 05:05, dazu fremde LÖVE-Läufe); Fremdlast je Lauf in last.txt. Rot-Probe: 2 ms gingen im Rauschen unter, mit SNAI_ZEIT_ROT_MS=50 nachgerüstet (Lib danach neu gebaut, Bytegleichheit erneut geprüft).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/threads/dist1/ausw.py über log/g{128,512}_r{1,2,3}.log; Anteil am Median-Schritt
  m9896 attB Anteil % | 33,8 / 34,0 / 34,1 | g512 |  | 3
  m9897 mmF Anteil % | 16,3 / 16,6 / 16,8 | g512 |  | 3
  m9898 gA Anteil % | 12,6 / 12,8 / 13,4 | g512 |  | 3
  m9899 mmT Anteil % | 11,3 / 11,7 / 12,1 | g512 |  | 3
  m9900 attF Anteil % | 6,0 / 6,4 / 6,7 | g512 |  | 3
  m9901 gA_wout Anteil % | 5,0 / 5,2 / 5,3 | g512 |  | 3
  m9902 mmF_wout Anteil % | 4,9 / 5,0 / 5,0 | g512 |  | 3
  m9903 mmT_wout Anteil % | 3,8 / 3,9 / 3,9 | g512 |  | 3
  m9904 ges ms je Schritt (act 1024) | 16407 / 17318 / 17443 | g512 |  | 3
  m9905 gA_wout Anteil % | 24,0 / 24,8 / 26,2 | g128 |  | 3
  m9906 mmF Anteil % | 12,6 / 13,7 / 18,8 | g128 |  | 3
  m9907 mmF_wout Anteil % | 12,2 / 12,3 / 12,6 | g128 |  | 3
  m9908 mmT_wout Anteil % | 11,4 / 14,9 / 15,4 | g128 |  | 3
  m9909 attB Anteil % | 7,4 / 7,5 / 9,1 | g128 |  | 3
  m9910 ges ms je Schritt (act 512) | 655 / 835 / 905 | g128 |  | 3
  m9911 Summe ges gegen Wanduhr % | 99 / 99 / 99 | g512 |  | 3
  m9912 Modell-md5 | c1b8f88d in 3 von 3 | g512 |  | 3
  m9913 Modell-md5 | 3c9edd10 in 3 von 3 | g128 |  | 3
Ergebnis e595 [2026-11-10 05:28]: teilweise
  Fazit: Bei Breite 512 (4 Schichten, Kontext 1024, 8 Köpfe) erfüllen zwei Abschnitte das Kriterium in 3 von 3 Läufen: Attention rückwärts (34 %, seriell) und Vorwärts-Matmul (16 bis 17 %, Region je Position). Bei Breite 128 erfüllen es Vorwärts-Matmul (13 bis 19 %) und Vorwärts-Matmul w_out (12 %); Attention rückwärts liegt dort unter 10 %. Die übrigen großen Fächer (gA, mmT, gA_wout, mmT_wout) sind schon parallel und fallen an der Strukturbedingung durch. Daraus folgt: Zu übertragen lohnt zuerst die parallele Kopfschleife der Attention rückwärts, danach der Blockpfad des Vorwärts-Matmul; der Rest der int8-Patches hat in der Distro kein Ziel von Gewicht. Urteil „teilweise“, weil Gültigkeit (a) nur in 8 von 12 Fächern innerhalb ±20 % lag (die vier schwachen Fächer tragen keinen der beiden Schlüsse) und der Rechner nicht frei war.
  Offen: Der tatsächliche Gewinn: der Anteil ist Obergrenze, gemessen wird er erst im gepaarten Lauf mit Patch (Intervallregel). Rot-Probe nur an g128, nicht an g512. Wiederholung auf freiem Rechner. Ob an gA_wout/mmT_wout bei kleinem Modell trotz Parallelität etwas zu holen ist. Nebenbefund ungeklärt: mit rusticl (Radeon) gleiche Loss-Zeilen, aber anderes Modell-md5 als auf der CPU.
  Datei: rechner-a:~/snai_pruef/threads/dist1/ERGEBNIS_dist_zeitsonde.md
Chronik:
  2026-11-10 05:10 angelegt
  2026-11-10 05:18 Rezept r656
  2026-11-10 05:18 Status geplant -> laeuft (Rezept r656)
  2026-11-10 05:28 Messwerte m9896-m9913
  2026-11-10 05:28 Ergebnis e595: teilweise
  2026-11-10 05:28 Status laeuft -> ausgewertet (Ergebnis e595)
```
