# snai/ocl-umbau-tempo

```text
snai/ocl-umbau-tempo - ausgewertet, angelegt 2026-11-13, zuletzt 2026-11-13 12:08
Frage: Ist der OpenCL-Pfad mit den vier Umbauten zusammen (Kachel-Vorwärtskern, Map statt Kopie, int8-Punktprodukt, Division nur wo nötig) je Plattform (ROCm, rusticl) auf rechner-a schneller als der jetzige Stand c553f412? Nur Gesamtwirkung, keine Einzelwirkungen.
Kriterium (festgelegt 2026-11-13 07:20, vor dem ersten Messwert):
  ms/Schritt aus [Bilanz], p512, OMP 6, ~32 Schritte, Median aus 3 rotierten Läufen je Arm; Arme C (CPU alt), je Plattform Weg G und V jeweils alt/neu. Gültig nur mit md5 out.snai = 6f49622c, rc=0, Meldung [OCL-FWD] Kachel bei neu. Je Plattform×Weg: Median alt/neu ≥ 1,05 und alle 3 neu-Läufe schneller als der schnellste alt-Lauf = schneller; spiegelbildlich langsamer; sonst Gleichstand. Gesamt erfüllt, wenn auf mindestens einer Plattform der schnellste neue Weg den schnellsten alten um ≥5 % schlägt (Regel oben); verfehlt sonst; ungültig bei md5-Abweichung. Vorab Rot-Probe SNAI_OCL_FWD=ROT muss md5 ändern (rocm+rusticl). Datei KRITERIEN_ocl_umbau_tempo.md md5 f092e1c6.
Plan: rechner-a:~/snai_pruef/ocl_umbau/mess/KRITERIEN_ocl_umbau_tempo.md
Baut auf: snai/rocm-tempo-grim, snai/ocl-tempo-grim
Darauf baut: snai/ocl-att-rusticl
Rezepte:
  r708 [2026-11-13] setsid bash ~/snai_pruef/ocl_umbau/mess/reihe.sh  (Aufwärmen neu:aV, dann 3 rotierte Durchgänge über C, alt/neu × aG/rG/aV/rV; je Lauf arm.sh <alt|neu> <rocm|rusticl> <G|V|C> t)
      quelltext: patch_ocl_umbau.py auf cortex_opencl.nim 00a81585 (HEAD 73620b8) → 22410c13; Libs aus bau.sh: alt 154c4042 (ungepatcht, ersetzt nach Regel c553f412), neu b4a04047. Kriterien jetzt 41fc6578 (= f092e1c6 + Nachtrag Bau, Urteilsregel unverändert).
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/ocl_umbau/mess/ergebnis.txt, log/
      notiz: Vorab bestanden: Rot-Probe SNAI_OCL_FWD=ROT md5 ecd76aaf auf rocm und rusticl (≠ 6f49622c); neu V rocm und rusticl md5 6f49622c. Meldungen: rocm IDOT nein, DDIV nativ (0/65536), ZC an; rusticl IDOT ja, DDIV Nachbau (65536/65536 abweichend, vermutlich fp64 ohne RUSTICL_FEATURES nicht echt an), ZC an.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ocl_umbau/mess/ergebnis.txt ([Bilanz] ms/Schritt, Median von 3 rotierten Läufen)
  m10872 ms/Schritt Median | 3056,1 | C alt | - | 3
  m10873 ms/Schritt Median | 8109,3 | ROCm G alt | - | 3
  m10874 ms/Schritt Median | 2619,1 | ROCm G neu | - | 3
  m10875 ms/Schritt Median | 7349,4 | rusticl G alt | - | 3
  m10876 ms/Schritt Median | 3171,0 | rusticl G neu | - | 3
  m10877 ms/Schritt Median | 8048,6 | ROCm V alt | - | 3
  m10878 ms/Schritt Median | 2677,9 | ROCm V neu | - | 3
  m10879 ms/Schritt Median | 13744,8 | rusticl V alt | - | 3
  m10880 ms/Schritt Median | 9912,1 | rusticl V neu | - | 3
  m10881 alt/neu | 3,10 / 2,32 / 3,01 / 1,39 | ROCm G / rusticl G / ROCm V / rusticl V | - | 3
  m10882 md5 out.snai | 6f49622c in 27/27 | alle | - | 27
  m10883 Rot-Probe md5 | ecd76aaf (≠ 6f49622c) | neu G ROT rocm+rusticl | - | 2
Ergebnis e658 [2026-11-13 09:55]: erfuellt
  Fazit: Die Bremse von OpenCL auf rechner-a war unser naiver Vorwärtskern, nicht der Treiber: mit den vier Umbauten 2,3–3,1× schneller, bitgleich, in allen 4 Zellen ohne Überlappung. Unter ROCm ist die iGPU damit erstmals schneller als die CPU (G 2.619 gegen 3.056 ms, 14 %, Beobachtung ohne Vorab-Urteil), unter rusticl gleichauf. Übernahme in den Hauptbaum lohnt (so entschieden). Unter rusticl bleibt die Attention auf der Karte (V) der nächste Hebel, ~6,7 s/Schritt.
  Offen: Anteil der einzelnen Umbauten (Schalter vorhanden, nicht gemessen); warum der DDIV-Selbsttest unter rusticl 65536/65536 abweicht (fp64 ohne RUSTICL_FEATURES?); Wirkung auf Handy/SoC.
  Datei: rechner-a:~/snai_pruef/ocl_umbau/mess/ERGEBNIS_ocl_umbau_tempo.md
Chronik:
  2026-11-13 07:11 angelegt
  2026-11-13 07:20 Kriterium geaendert, vorher: ms/Schritt aus [Bilanz], p512, OMP 6, ~32 Schritte, Median aus 3 rotierten Läufen je Arm; Arme C (CPU alt), je Plattform Weg G und V jeweils alt/neu. Gültig nur mit md5 out.snai = 6f49622c, rc=0, Meldung [OCL-FWD] Kachel bei neu. Je Plattform×Weg: Median alt/neu ≥ 1,10 und alle 3 neu-Läufe schneller als der schnellste alt-Lauf = schneller; spiegelbildlich langsamer; sonst Gleichstand. Gesamt erfüllt, wenn auf mindestens einer Plattform der schnellste neue Weg den schnellsten alten um ≥10 % schlägt (Regel oben); verfehlt sonst; ungültig bei md5-Abweichung. Vorab Rot-Probe SNAI_OCL_FWD=ROT muss md5 ändern (rocm+rusticl). Datei KRITERIEN_ocl_umbau_tempo.md md5 90fde966 inkl. Prüfer-Nachtrag. | Grund: Vor dem ersten Lauf auf Wunsch Schwelle 10 % → 5 % („Setz mal bitte das Kriterium auf die Rauschgrenze von 5%“). Stütze: Wiederholungen in snai/rocm-tempo-grim streuten bis dahin 0,6–1,4 %.
  2026-11-13 08:17 Rezept r708
  2026-11-13 08:17 Status geplant -> laeuft (Rezept r708)
  2026-11-13 09:55 Messwerte m10872-m10883
  2026-11-13 09:55 Ergebnis e658: erfuellt
  2026-11-13 09:55 Status laeuft -> ausgewertet (Ergebnis e658)
  2026-11-13 12:08 Korrektur der Deutung im Ergebnis (e658 offen-Punkt): die Engine setzt RUSTICL_FEATURES=fp64 selbst; die 65536/65536 DDIV-Abweichungen unter rusticl sind die bekannte Ungenauigkeit von double-/ und sqrt dort (12.11.), nicht fehlendes fp64. Selbsttest hat richtig entschieden. ERGEBNIS-Datei entsprechend korrigiert.
```
