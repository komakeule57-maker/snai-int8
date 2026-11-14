# snai/rocm-tempo-grim

```text
snai/rocm-tempo-grim - ausgewertet, angelegt 2026-11-13, zuletzt 2026-11-13 08:06
Frage: Rechnet ROCm-OpenCL (7.2.4) auf der Renoir-iGPU von rechner-a bei gleichem Rechenweg schneller als rusticl, und ist der beste ROCm-Weg schneller als die CPU?
Kriterium (festgelegt 2026-11-13 06:31, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/rocm/KRITERIEN_rocm_tempo.md (vor dem Start, Prüfer eingearbeitet). Aufbau wie snai/ocl-tempo-grim Fassung 2, einziges Stellrad Plattform (OCL_ICD_VENDORS je Lauf). Arme C, rO/rG/rV (rusticl), aO/aG/aV (ROCm), Aufwärmen + 3 rotierte Durchgänge. Median von 3, unter 10 % Gleichstand, Spanne > Abstand = gestört, md5 6f49622c Pflicht, Swap > 10.000 = verdächtig. Frage 1 je Rechenweg ROCm gegen rusticl; Frage 2 bester ROCm-Arm gegen C.
Plan: rechner-a:~/snai_pruef/rocm/KRITERIEN_rocm_tempo.md
Baut auf: snai/ocl-tempo-grim
Darauf baut: snai/ocl-umbau-tempo
Rezepte:
  r707 [2026-11-13] bash ~/snai_pruef/rocm/reihe.sh (6dcea1a0; arm.sh f746840a, Plattform je Lauf über OCL_ICD_VENDORS=~/snai_pruef/rocm/icd_<rocm|rusticl>), gestartet 2026-11-13 06:31:20, Kriterien 86b46d54. Lib c553f412, rocm-opencl-runtime 7.2.4 (systemweit installiert 13.11.), Gerät gfx90c:xnack+.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/rocm/ergebnis.txt ([Bilanz] ms/Schritt, Median von 3 rotierten Läufen)
  m10855 ms/Schritt Median | 3021,2 | C | - | 3
  m10856 ms/Schritt Median | 8126,5 | aO ROCm | - | 3
  m10857 ms/Schritt Median | 7123,2 | rO rusticl | - | 3
  m10858 ms/Schritt gültige Läufe | 8061,3 / 8085,8 (8171,5 ungültig, Swap 15762) | aG ROCm | - | 2
  m10859 ms/Schritt Median | 7381,6 | rG rusticl | - | 3
  m10860 ms/Schritt Median | 8021,9 | aV ROCm | - | 3
  m10861 ms/Schritt Median | 13769,0 | rV rusticl | - | 3
  m10862 md5 out.snai | 6f49622c in 21/21 | alle | - | 21
Ergebnis e657 [2026-11-13 08:06]: verfehlt
  Fazit: ROCm macht die iGPU auf rechner-a nicht zum Gewinn: bester ROCm-Weg (V) 2,66 × langsamer als die CPU (Frage 2 verfehlt). Frage 1 je Weg gemischt: O ROCm langsamer (+14 %), V ROCm schneller (rusticl 1,72 ×, Attention-Kerne kosten unter rusticl ~6,4 s/Schritt), G keine Aussage (ein Lauf über Swap-Grenze; beide Lesarten unter 10 %). Folge: Treiberwahl löst das Tempoproblem nicht, Hebel ist der Engine-Code (snai/ocl-umbau-tempo). Unter ROCm Weg V, unter rusticl Attention auf der CPU.
  Offen: Warum die Attention-Kerne unter rusticl so langsam sind (Arbeitsgruppe 512 statt 256 nur sichtbarer Unterschied, nicht isoliert).
  Datei: rechner-a:~/snai_pruef/rocm/ERGEBNIS_rocm_tempo.md
Chronik:
  2026-11-13 06:31 angelegt
  2026-11-13 06:31 Rezept r707
  2026-11-13 06:31 Status geplant -> laeuft (Rezept r707)
  2026-11-13 08:06 Messwerte m10855-m10862
  2026-11-13 08:06 Ergebnis e657: verfehlt
  2026-11-13 08:06 Status laeuft -> ausgewertet (Ergebnis e657)
```
