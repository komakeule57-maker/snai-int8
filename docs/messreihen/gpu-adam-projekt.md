# snai/gpu-adam-projekt

```text
snai/gpu-adam-projekt - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:31
Frage: Besteht die Projektfassung des GPU-Adam die Herz-und-Nieren-Prüfung: jede Zelle (Modi, Threads, ungebunden, WD 0, Wachstums-Boost, Arm C, ungerade Geometrie, compute-Modus, Fortsetzung) CPU = Karte, Rot-Probe weicht ab?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus der Kriteriendatei und rechner-b ~/snai_pruef/cuda_i8/out/batterie.txt (batterie_proj.sh 2026-10-14 09:17).):
  Vorab rechner-b ~/snai_pruef/cuda_i8/kriterien.txt Abschnitt 'GPU-ADAM PROJEKTFASSUNG' (2026-10-14, vor dem ersten Lauf): je Paar bitgleich (md5 und Step-Zeilen), ein Stellrad SNAI_I8_GPU_ADAM; PROT muss abweichen, POLD Warnung und = P0, G0 muss von P0 abweichen. Übernahme, wenn alle Erwartungen erfüllt, Fehlerkanal leer und der Prüfer keinen Befund offenlässt. Nachtrag vor dem zweiten Durchgang: Zwei-Zustände-Test, Bau 789e1092 + 78249867.
Plan: Batterie P0, P1, P1o1, P1o8, P2, P1B, PROT, POLD, U, W, G, C, O, Q, K; zweiter Durchgang nach dem Allokator-Fix.
Baut auf: snai/gpu-adam-seg256
Darauf baut: snai/speedtest-1024x2
Rezepte:
  r197 [2026-10-21] bash batterie_proj.sh
      quelltext: zweiter Durchgang: bau_proj/libcortex_proj.so 789e1092 + lib_proj/libcortex_cuda.so 78249867 (Projektbaum cortex.nim 314a7c26 + patch_gpu_adam_proj.py, gaOwn-Register, -ftz=true)
      parameter: Prüfstand cuda_i8/t: gen.snai 512/8, ctx 64, p300.txt, 300 Schritte, Laufname paar, INT8_FULL, gebunden
      rechner: rechner-b (RTX 3050)
      logs: rechner-b:~/snai_pruef/cuda_i8/out/batterie.txt
      notiz: Erster Durchgang (2256c95e/5ac848db) bis POLD grün, abgebrochen, weil zwei_zustaende.php in Modus 1 abwich.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/cuda_i8/out/batterie.txt
  m2371 Zellen OK zweiter Durchgang | 15 von 15 | Batterie |  | 15
  m2372 Zwei-Zustände-Test erster Bau | weicht ab | Modus 1 |  | 1
  m2373 Zwei-Zustände-Test nach Fix | = CPU (1377854e) | Modus 0, 1, 2 |  | 3
Ergebnis e185 [2026-10-21 19:31]: erfuellt
  Fazit: Die Projektfassung besteht alle 15 Zellen; der Fehler, den erst der Zwei-Zustände-Test fand (alte Gewichtsadressen im Cache), ist behoben und geprüft. Die Batterie hat damit ihren Zweck erfüllt: sie fand einen Fehler, den die 300-Schritte-Prüfung nicht sehen konnte.
  Offen: Nur durch Durchsicht gedeckt: Fehler-Rückführung aus, gscale 0 / NaN-Gradient.
  Datei: rechner-b:~/snai_pruef/cuda_i8/kriterien.txt
Chronik:
  2026-10-21 19:30 angelegt (Nachtrag: Nachtrag 2026-10-21 aus der Kriteriendatei und rechner-b ~/snai_pruef/cuda_i8/out/batterie.txt (batterie_proj.sh 2026-10-14 09:17).)
  2026-10-21 19:31 Rezept r197
  2026-10-21 19:31 Status geplant -> laeuft (Rezept r197)
  2026-10-21 19:31 Messwerte m2371-m2373
  2026-10-21 19:31 Ergebnis e185: erfuellt
  2026-10-21 19:31 Status laeuft -> ausgewertet (Ergebnis e185)
```
