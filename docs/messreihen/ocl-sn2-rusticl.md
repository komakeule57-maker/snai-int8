# snai/ocl-sn2-rusticl

```text
snai/ocl-sn2-rusticl - ausgewertet, angelegt 2026-11-13, zuletzt 2026-11-13 14:17
Frage: Machen exakte Nullen im float-Kurzweg, Adam über die Kurzwege (SN_ADAM) und geprüfte native Division/Wurzel (SN_DIV) unter rusticl die Wege V und G schneller als die Hauptbaum-Lib b4a04047, und wie steht V gegen G danach?
Kriterium (festgelegt 2026-11-13 13:26, vor dem ersten Messwert):
  ms/Schritt [Bilanz], p512, OMP 6, ~32 Schritte, Median aus 3 rotierten Läufen; Arme haupt:rV, haupt:rG, neu2:rV, neu2:rG, C. Gültig: md5 6f49622c, rc=0, Meldungen [OCL-ATT-SN] an und [OCL-SN2] an/an bei neu2-rusticl. Je Frage Verhältnis ≥ 1,05 und keine Überlappung = schneller, spiegelbildlich langsamer, sonst Gleichstand. Gesamt erfüllt wenn V und G schneller, teilweise wenn eines. Vorab: Rot SN_ADAM und SN_DIV ändern md5; neu2 rV und aV bitgleich. Swap > 10.000 = verdächtig, beide Lesarten. Gerätetest 0/5 Operationen abweichend, Rot gesehen. Datei KRITERIEN_ocl_sn2.md 6c9a24aa (mit Prüfer-Nachtrag).
Plan: rechner-a:~/snai_pruef/ocl_att/mess/KRITERIEN_ocl_sn2.md
Baut auf: snai/ocl-att-rusticl
Rezepte:
  r710 [2026-11-13] setsid bash ~/snai_pruef/ocl_att/mess/reihe_sn2.sh  (Vorab Rot Adam/Division + rV/aV mit Abbruchprüfung, dann Aufwärmen neu2:rV und 3 rotierte Durchgänge über haupt:rV haupt:rG neu2:rV neu2:rG C)
      quelltext: bb91bf0d (Hauptbaum + PROF + ATT-SN) → patch_ocl_sn2.py → 11a78633; Lib neu2 ab5a3a12, haupt b4a04047. Gerätetest geraetetest/sn_test.c, zieh_quelle.py.
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/ocl_att/mess/ergebnis.txt, log/
      notiz: Korrektur zum Kriterientext: die Kriteriendatei hat md5 3639e2ca (nicht 6c9a24aa wie im Kriterium vermerkt; Inhalt unverändert gegenüber dem eingetragenen Wortlaut).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ocl_att/mess/ergebnis.txt ([Bilanz] ms/Schritt, Median von 3 rotierten Läufen)
  m10896 ms/Schritt Median | 9735,2 | haupt:rV | - | 3
  m10897 ms/Schritt Median | 4539,9 | neu2:rV | - | 3
  m10898 ms/Schritt Median | 3229,5 | haupt:rG | - | 3
  m10899 ms/Schritt Median | 3038,6 (ohne Swap-Lauf 3025,1) | neu2:rG | - | 3
  m10900 ms/Schritt Median | 2898,0 | C | - | 3
  m10901 haupt/neu2 | 2,14 / 1,063 | rusticl V / rusticl G | - | 3
  m10902 md5 out.snai | 6f49622c in 15/15 | alle | - | 15
  m10903 Rot-Probe md5 | d01fa899 / f5a6188d | SN_ADAM=ROT rG / SN_DIV=ROT rV | - | 2
Ergebnis e660 [2026-11-13 14:17]: erfuellt
  Fazit: Beide Hebel greifen bitgleich: rusticl V 2,14× schneller (9,74 → 4,54 s), G 6,3 % schneller (knapp über 5 %; vor einer Entscheidung, die allein daran hängt, auf frischem Text wiederholen). Unter rusticl bleibt Weg G die Empfehlung (V 1,49× langsamer), CPU allein knapp vorn (Beobachtung, 4,8 %). Unter ROCm inaktiv. Rusticl auf dieser iGPU damit bis auf ~1,5 s Attention-Rest ausgereizt; weiterer Aufwand nur, wenn Mobil-GPUs ohne Denormale zählen.
  Offen: Messgerät-Lücke: [OCL-SN2]-Meldung nur für letzten Durchgang je Arm im Log belegt (Ersatzbeleg ATT-SN 7/7), arm.sh danach ergänzt. Restkosten der Attention unter rusticl (~1,5 s/Schritt) nicht zerlegt.
  Datei: rechner-a:~/snai_pruef/ocl_att/mess/ERGEBNIS_ocl_sn2.md
Chronik:
  2026-11-13 13:26 angelegt
  2026-11-13 13:27 Rezept r710
  2026-11-13 13:27 Status geplant -> laeuft (Rezept r710)
  2026-11-13 14:17 Messwerte m10896-m10903
  2026-11-13 14:17 Ergebnis e660: erfuellt
  2026-11-13 14:17 Status laeuft -> ausgewertet (Ergebnis e660)
```
