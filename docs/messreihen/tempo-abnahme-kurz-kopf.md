# snai/tempo-abnahme-kurz-kopf

```text
snai/tempo-abnahme-kurz-kopf - ausgewertet, angelegt 2026-11-09, zuletzt 2026-11-09 19:07
Frage: Rechnet der Hauptbaum-Stand 84dbf37 (Lib 515b80ee: Evo-Attention-Patches par5/par6 + Block-Attention par8) bytegleich zum Stand davor 4a62d92 (Lib ba130515), auch bei kurzen/ungeraden Fensterlängen und bei Kopfgrößen ≠ 64? Auftrag 09.11. „Ja, fahr bitte beides“ (Lücken aus e588).
Kriterium (festgelegt 2026-11-09 18:35, vor dem ersten Messwert):
  Arbeitskopie ~/snai_pruef/threads/par9. A = Projektkopie mit Lib ba130515 (Stand 4a62d92, ohne par5/6/8), B = Kopie mit Lib 515b80ee (84dbf37, alles an). Gleiche Daten, Basis prod512b s11, arm.sh aus par8 (TXT=, PLAN_TOKENS). Kopfgröße über die Sidecar-Datei .heads (Basis und out) in eigenen Kopien: 8 Köpfe = hs 64, 16 = hs 32, 4 = hs 128 (dieselben Gewichte, nur anders in Köpfe geteilt).
(K) hs 64, n4: kurz_3, 15, 17, 40, 129, 511, 1024 (tatsächliche Längen aus PLAN_TOKENS): je A/B md5+lossmd5 gleich.
(H) hs 32 und hs 128, n4: text.txt (32 Schritte) sowie kurz_17, kurz_129, kurz_1024: je A/B gleich. Dazu B n1 auf text.txt = A n4 derselben Kopfgröße.
(R) Rot je Kopfgröße 32/128: B mit SNAI_I8_ATT_BW_BLK=ROTB und B mit SNAI_I8_ATT_WCACHE=ROTF auf text.txt n4 müssen md5 ändern (zeigt, dass die neuen Pfade bei dieser Kopfgröße laufen). Startmeldungen [ATT-W] an und [ATT-BWB] an in B-Logs.
Urteil: alle Paare gleich und Rot rot = erfüllt; ein Paar ungleich = nicht bytegleich für diesen Fall, Ursache suchen, nichts weiter übernehmen. Fehlerkanal: rc, .err je Lauf. Grenze: ein Modell (prod512b-Gewichte), rechner-a, CPU-int8-Pfad.
Rezepte:
  r652 [2026-11-09] setsid nohup ~/snai_pruef/threads/par9/reihe9.sh (k<act>_A64/_B64 n4; je Kopfgröße 32/128: t_A/t_B n4, t_B n1, k17/129/1024 A/B, r_ROTB/r_ROTF B)
      quelltext: Lib A ba130515 (uebernahme2/libcortex_vorher_ba130515.so), Lib B 515b80ee (Hauptbaum 84dbf37); Projektkopien proj_A/B{64,32,128} aus par8/proj mit .heads 8/16/4; arm.sh f39ce9af, reihe9.sh 026318c5; Kurztexte par8/korpus (finde.php 324bf03d)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/par9/ergebnis.txt, log/
Messwerte (Groesse | Wert | Arm | Start | n):
  m9835 K hs 64 Kurzfenster A=B n4 | 7/7 Paare md5+lossmd5 gleich | act 3, 16, 17, 41, 129, 511, 1024 (+1) aus PLAN_TOKENS
  m9836 H hs 32 (16 Köpfe) A=B n4 | text 1c6dda8d/1ed7ca6c, kurz_17 b40a3bf7, kurz_129 34f9f99d, kurz_1024 854e38ae | 4/4 gleich; B n1 text = A n4
  m9837 H hs 128 (4 Köpfe) A=B n4 | text 1042b050/ea4e6cee, kurz_17 9ff9e0ba, kurz_129 2c5bca37, kurz_1024 44e485ea | 4/4 gleich; B n1 text = A n4
  m9838 R Rot hs 32 | ROTB 86f2c376, ROTF cc6ff893 | beide rot gegen 1c6dda8d
  m9839 R Rot hs 128 | ROTB 4e9a015b, ROTF 3fd86781 | beide rot gegen 1042b050
  m9840 Startmeldungen B | [ATT-W] an, [ATT-BWB] an in t_B32/t_B128; [Heads] 16 (hs 32) bzw. 4 (hs 128) gelesen
  m9841 Fehlerkanal | 36/36 rc=0, alle .err leer
Ergebnis e590 [2026-11-09 19:07]: erfuellt
  Fazit: Der Hauptbaum-Stand 84dbf37 (Lib 515b80ee) rechnet bytegleich zum Stand davor 4a62d92 (ba130515): bei kurzen und nicht durch 16 teilbaren Fensterlängen (1 bis 1024) und bei den Kopfgrößen 32, 64 und 128, mit 4 und 1 Faden. Die Rot-Proben ROTB und ROTF zeigen, dass die neuen Pfade bei hs 32 und 128 wirklich laufen. Damit sind die Lücken aus e588 geschlossen: par5, par6 und par8 sind gegen den echten Vorstand geprüft, nicht nur gegen ihre eigenen Stellräder. Grenze: dieselben Gewichte (prod512b s11, nur anders in Köpfe geteilt), rechner-a, CPU-int8; Kartenbau, LoRA-Pfad und andere Prozessoren weiter ungeprüft.
Chronik:
  2026-11-09 18:35 angelegt
  2026-11-09 18:35 Rezept r652
  2026-11-09 18:35 Status geplant -> laeuft (Rezept r652)
  2026-11-09 19:07 Messwerte m9835-m9841
  2026-11-09 19:07 Ergebnis e590: erfuellt
  2026-11-09 19:07 Status laeuft -> ausgewertet (Ergebnis e590)
```
