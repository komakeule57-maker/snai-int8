# snai/kopiersperre-nachmessung

```text
snai/kopiersperre-nachmessung - ausgewertet, angelegt 2026-10-24, zuletzt 2026-10-25 07:15
Frage: Passt die ausgelieferte Voreinstellung der Kopiersperre (Durchlass D4 aus prod512b_s4, prompt-frei, Commit 9576d0e) auch für andere Stände desselben Laufs (s2, s3), oder braucht jeder Stand einen eigenen Durchlass?
Kriterium (festgelegt 2026-10-24 21:19, vor dem ersten Messwert):
  Volltext rechner-a:~/snai_pruef/einstieg/kriterien_nachmessung.txt 15712bcb. Je Stand X in {s2, s3} (rechner-b, gepaart, 40 Bindungsposten): eigener Durchlass DX wie für s4 (Sonde 200 Fenster + Beam-Arm 0, rate.py). Arme 0 / V (D4, Saat 1) / V2 (D4, Saat 2) / E (DX, Saat 1) / E2 (DX, Saat 2), alle prompt-frei. N2 "Voreinstellung passt" = U_V und U_V2 <= 0,5 U_0 UND Bindung kein Schaden (T_V >= T_0-2, Schaden T_V <= T_0-5, V und V2 in derselben Klasse). N3 "eigener Durchlass besser" = in beiden Saaten U_E <= 0,9 U_V und T_E >= T_V-2, oder T_E >= T_V+3 und U_E <= 1,1 U_V; sonst "kein Vorteil gemessen" (kein Gleichheitsbeleg). N1 berichtet: DX gegen D4 je Fach. GESAMT erfüllt = N2 für s2 und s3; teilweise = einer; verfehlt = keiner. Eigener Durchlass je Stand nur empfohlen, wenn N3 irgendwo "besser".
Plan: rechner-a:~/snai_pruef/einstieg/kriterien_nachmessung.txt
Baut auf: snai/kopiersperre-promptfrei
Darauf baut: snai/kopiersperre-dosis
Rezepte:
  r411 [2026-10-24] rechner-b: cd ~/snai_pruef/einstieg/nach && setsid bash lauf.sh (Schritt 1 je Stand: sonde_einstieg.php M 8 factory/holdout_prod/ho_prod.txt nach/t1_X.jsonl 200 512 5 + BL_OMP=1 BL_KOEPFE=8 beamlauf2.sh M p512X_0 -> rate.py -> nach/durchlass_X.txt; Bindung je Job: PB_TAG=_<arm>_<i> PB_VON=i PB_BIS=i OMP_NUM_THREADS=1 [Stellräder] prompt_bindung_kopie2.sh M 3 nach/X/<arm>)
      quelltext: nach/lauf.sh d99b4264, snai_inference_kopie2.php 516e3a65, prompt_bindung_kopie2.sh b08133ea, sonde_einstieg.php b969e502, beamlauf2.sh c22a9dc2, rate.py b930ff72. Modelle prod512b_s2 ec8406b8, prod512b_s3 deee2ea3 (8 Köpfe).
      parameter: D4=0.4174,0.6245,0.8671,0.7404,0.7988; Arme 0 | V (D4 Saat 1) | V2 (D4 Saat 2) | E (DX Saat 1) | E2 (DX Saat 2), alle SNAI_KOPIE_PROMPTFREI=1; Beam 3 ROH, 40 Posten.
      seed: SNAI_KOPIE_SAAT 1/2; Beam deterministisch
      rechner: rechner-b, gedrosselt auf 6 Kerne (Absprache TDC-AI M9), xargs -P per USR1 erhöhbar
      logs: rechner-b:~/snai_pruef/einstieg/nach/ (fortschritt.log, t1_X.jsonl, durchlass_X.txt, X/<arm>/), rechner-b:~/snai_pruef/einstieg/b/p512s2_0, p512s3_0
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/einstieg/log/auswert_nach.txt (auswert_nach.py), Rohdaten nach/ (von rechner-b). 112 E/E2-Läufe nach OOM-Abbruch wiederholt (nachlauf.sh), danach 0 fehlerhaft.
  m5244 Durchlass DX | 0.4124,0.7021,0.5455,0.6255,0.7850 | s2 |  | 4 Prompts
  m5245 Durchlass DX | 0.4015,0.5559,0.7273,0.7158,0.7953 | s3 |  | 4 Prompts
  m5246 DX / D4 je Fach | 0,99 / 1,12 / 0,63 / 0,84 / 0,98 | s2 |  | 5 Fächer
  m5247 DX / D4 je Fach | 0,96 / 0,89 / 0,84 / 0,97 / 1,00 | s3 |  | 5 Fächer
  m5248 r_3 (n) Schätzgrundlage | s2 0,941 (17), s3 0,706 (34), s4 0,596 (52) | 0 |  | 4 Prompts
  m5249 Treffer 0 / V / V2 / E / E2 | 5 / 9 / 6 / 7 / 9 von 40 | s2 | 1/2 | 40
  m5250 Treffer 0 / V / V2 / E / E2 | 10 / 14 / 13 / 14 / 15 von 40 | s3 | 1/2 | 40
  m5251 U 0 / V / V2 / E / E2 | 0,559 / 0,153 / 0,168 / 0,105 / 0,135 | s2 | 1/2 | 40
  m5252 U 0 / V / V2 / E / E2 | 0,556 / 0,202 / 0,177 / 0,125 / 0,134 | s3 | 1/2 | 40
  m5253 U_E / U_V (Saat 1, Saat 2) | 0,68 / 0,80 | s2 | 1/2 | 40
  m5254 U_E / U_V (Saat 1, Saat 2) | 0,62 / 0,76 | s3 | 1/2 | 40
  m5255 N2 Voreinstellung passt | ja (U 0,27/0,30 x U_0, Bindung kein Schaden) | s2 | 1/2 | 40
  m5256 N2 Voreinstellung passt | ja (U 0,36/0,32 x U_0, Bindung kein Schaden) | s3 | 1/2 | 40
  m5257 N3 eigener Durchlass | besser (beide Saaten, beide Stände) | E | 1/2 | 40
  m5258 OOM-Abbruch (ungültig, wiederholt) | 112 Läufe E/E2 ab 23:44, 10 Prozesse x ~2 GB | E | 1/2 | 112
  Quelle: rechner-a:~/snai_pruef/einstieg/rate12.py (wie rate.py b930ff72, alle 12 Prompts) auf b/p512_0, b/p512s2_0, b/p512s3_0; nachgerechnet 2026-10-25, keine neuen Läufe
  m5259 Durchlass aus 12 Prompts D12 | 0.3861,0.6928,0.7895,0.7611,0.8002 | s4 |  | 12 Prompts
  m5260 Durchlass aus 12 Prompts D12 | 0.3613,0.5894,0.5627,0.7051,0.7978 | s2 |  | 12 Prompts
  m5261 Durchlass aus 12 Prompts D12 | 0.4072,0.5620,0.6199,0.7536,0.8059 | s3 |  | 12 Prompts
  m5262 r_3 aus 12 Prompts (n) | s2 0,912 (114), s3 0,828 (128), s4 0,655 (139) | 0 |  | 12 Prompts
  m5263 D12 / D4 an s4 je Fach | 0,92 / 1,11 / 0,91 / 1,03 / 1,00 | s4 |  | 5 Fächer
Ergebnis e362 [2026-10-25 07:15]: erfuellt
  Fazit: Die ausgelieferte Voreinstellung (D4 aus s4) trägt über s2 bis s4: Schleifen auf 0,27-0,36 x U_0, kein Namensverlust, beide Saaten. Commit 9576d0e bleibt richtig. Ein eigener Durchlass je Stand senkt U nach Regel weiter (U_E/U_V 0,62-0,80 bei gleichen oder mehr Treffern). Das trennt aber nicht "passend kalibriert" von "stärker dosiert". Nachgerechnet (m5259-m5263): Die Vermutung, der hohe k=3-Wert von D4 sei Rauschen aus 4 Prompts, ist widerlegt. Aus 12 Prompts liegt D4 für s4 fast gleich (höchstens 11 %), und ältere Stände setzen bei k=3 echt öfter fort (r_3 0,91/0,83 gegen 0,66). Ein Test "D4 neu geschätzt" lohnt nicht. Die offene Frage ist, ob eine stärkere Dosis auch an s4 hilft.
  Offen: Dosis gegen Kalibrierung: stärkere Sperre an s4 (und s5) ungemessen. Kosten stärkerer Sperre für die Lesbarkeit (E, Leseproben) ungemessen. s5 ungemessen. 112 E-Läufe wurden nach dem OOM-Abbruch mit denselben Befehlen wiederholt (deterministisch).
  Datei: rechner-a:~/snai_pruef/einstieg/ERGEBNIS_nachmessung.md
Abgeloest und ausgeblendet: 1 ergebnis - voll=True zeigt sie.
Chronik:
  2026-10-24 21:19 angelegt
  2026-10-24 21:20 Rezept r411
  2026-10-24 21:20 Status geplant -> laeuft (Rezept r411)
  2026-10-25 00:37 Messwerte m5244-m5258
  2026-10-25 00:37 Ergebnis e361: erfuellt
  2026-10-25 00:37 Status laeuft -> ausgewertet (Ergebnis e361)
  2026-10-25 07:15 Messwerte m5259-m5263
  2026-10-25 07:15 Ergebnis e362: erfuellt, loest e361 ab
```
