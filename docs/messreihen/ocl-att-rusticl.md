# snai/ocl-att-rusticl

```text
snai/ocl-att-rusticl - ausgewertet, angelegt 2026-11-13, zuletzt 2026-11-13 13:11
Frage: Macht der float-Kurzweg in der Attention (OCL-ATT-SN) den Weg V unter rusticl auf rechner-a schneller als die Hauptbaum-Lib b4a04047, und ist V danach schneller als G (Attention auf der CPU)?
Kriterium (festgelegt 2026-11-13 12:23, vor dem ersten Messwert):
  ms/Schritt aus [Bilanz], p512, OMP 6, ~32 Schritte, Median aus 3 rotierten Läufen; Arme alt:rV, alt:rG (b4a04047), neu:rV, neu:rG (22f711e9). Gültig nur mit md5 6f49622c, rc=0, Meldung [OCL-ATT-SN] an. Frage 1: Median alt/neu ≥ 1,05 und alle 3 neu-Läufe schneller als der schnellste alt-Lauf = schneller (Gesamt erfüllt); spiegelbildlich langsamer; sonst Gleichstand. Frage 2 genauso V gegen neu:rG. Kontrolle Wrapper: alt:rG gegen neu:rG, Erwartung Gleichstand. Vorab: Rot SNAI_OCL_ATT_SN=ROT md5 ≠ 6f49622c; neu rV und aV bitgleich. Schwelle 5 % wie in snai/ocl-umbau-tempo (Vorgabe). Gerätetest vorab: 0 Abweichungen bei je 2^20 Grenzfällen, Rot gesehen. Datei KRITERIEN_ocl_att_sn.md 88a2ff97.
Plan: rechner-a:~/snai_pruef/ocl_att/mess/KRITERIEN_ocl_att_sn.md
Baut auf: snai/ocl-umbau-tempo
Darauf baut: snai/ocl-sn2-rusticl
Rezepte:
  r709 [2026-11-13] setsid bash ~/snai_pruef/ocl_att/mess/reihe_sn.sh  (Vorab rot/rV/aV mit Abbruchprüfung, dann Aufwärmen neu:rV und 3 rotierte Durchgänge über alt:rV alt:rG neu:rV neu:rG)
      quelltext: Hauptbaum cortex_opencl.nim 22410c13 → patch_ocl_prof.py → 679575e2 → patch_ocl_att_sn.py → bb91bf0d; Lib neu 22f711e9, alt = Hauptbaum-Lib b4a04047. Gerätetest geraetetest/sn_test.c + zieh_quelle.py.
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/ocl_att/mess/ergebnis.txt, log/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ocl_att/mess/ergebnis.txt ([Bilanz] ms/Schritt, Median von 3 rotierten Läufen)
  m10888 ms/Schritt Median | 9760,2 | alt:rV | - | 3
  m10889 ms/Schritt Median | 5927,6 | neu:rV | - | 3
  m10890 ms/Schritt Median | 3216,0 | alt:rG | - | 3
  m10891 ms/Schritt Median | 3210,2 | neu:rG | - | 3
  m10892 alt/neu V | 1,65 | rusticl V | - | 3
  m10893 md5 out.snai | 6f49622c in 12/12 | alle | - | 12
  m10894 Rot-Probe md5 | 26f91e30 (≠ 6f49622c) | neu rV ATT_SN=ROT | - | 1
  m10895 Gerätetest Abweichungen | 0/0/0 von je 1048576 (ohne Schwelle 85336/257/73508) | add/sub/mul rusticl | - | 1
Ergebnis e659 [2026-11-13 13:11]: erfuellt
  Fazit: Der double-Nachbau der float-Rechnung war die Bremse der Attention unter rusticl: Kurzweg macht V 1,65× schneller, bitgleich (Frage 1 erfüllt). Frage 2 verfehlt: V (5,93 s) bleibt unter rusticl langsamer als G (3,21 s) — Empfehlung unter rusticl weiter Weg G. Wrapper-Kontrolle Gleichstand. Übernahme lohnt (unter ROCm inaktiv). Nächster Hebel, falls rusticl/Mobil-GPUs ohne Denormale wichtig werden: Rest-double in der Attention (Division, expf, ds*x).
  Offen: Welcher Kern die restlichen ~2,7 s je Schritt trägt (SNAI_OCL_PROF auf der neuen Lib nicht gefahren); Adam unter rusticl (3,5× langsamer als unter ROCm).
  Datei: rechner-a:~/snai_pruef/ocl_att/mess/ERGEBNIS_ocl_att_sn.md
Chronik:
  2026-11-13 12:23 angelegt
  2026-11-13 12:23 Rezept r709
  2026-11-13 12:23 Status geplant -> laeuft (Rezept r709)
  2026-11-13 13:11 Messwerte m10888-m10895
  2026-11-13 13:11 Ergebnis e659: erfuellt
  2026-11-13 13:11 Status laeuft -> ausgewertet (Ergebnis e659)
```
