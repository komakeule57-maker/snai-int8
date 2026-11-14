# snai/gpu-adam-messkopie

```text
snai/gpu-adam-messkopie - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:31
Frage: Rechnet der Adam auf der Karte (SNAI_I8_GPU_ADAM, Messkopie) bitgleich zur Referenz: GA0, GA1, GA2, GA1B gleich R, Rot-Probe GA1R weicht ab, Aufrufnachweis vorhanden?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus der Kriteriendatei und rechner-b ~/snai_pruef/cuda_i8/out/GA*.):
  Vorab rechner-b ~/snai_pruef/cuda_i8/kriterien.txt Abschnitt 'GPU-ADAM (Messkopie, 2026-10-14)': je Lauf md5 und alle 64 Step-Zeilen = Referenz; GA1R muss abweichen; Nachweis 'gpuAdam Aufrufe=N' und '[GPU-ADAM] Modus'. Tempo: Eimer Adam GA1 gegen N2, unter 10 % Gleichstand; solange rechner-b belegt ist, nur Beobachtung.
Plan: GA0, GA1, GA1R, GA2, GA1B auf dem Prüfstand.
Baut auf: snai/adam-parallel
Darauf baut: snai/gpu-adam-seg256
Rezepte:
  r195 [2026-10-21] GA0, GA1, GA1R, GA2, GA1B: bash gpuadam.sh
      quelltext: bau_gpuadam/libcortex_gpuadam.so ac572ca2 + lib_gpuadam/libcortex_cuda.so a1b7f2bb (Projektstand 314a7c26 + patch_prof_i8 + patch_gpu_adam)
      parameter: Prüfstand cuda_i8/t: gen.snai 512/8, ctx 64, p300.txt, 300 Schritte, Laufname paar, INT8_FULL, gebunden; OMP 2; SNAI_I8_GPU_ADAM 0/1/2
      rechner: rechner-b (RTX 3050)
      logs: rechner-b:~/snai_pruef/cuda_i8/out/GA*
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/cuda_i8/out/GA*
  m2350 md5 und Step-Zeilen | gleich R | GA0, GA1, GA2, GA1B |  | 4
  m2351 erste Abweichung | Step 2 | GA1R (Rot) |  | 1
  m2352 Adam-Eimer | 48,7 s gegen 8,9 s | N2 gegen GA1 |  | 1
  m2353 Schrittzeit | 86,8 s gegen 49,0 s | N2 gegen GA1 |  | 1
  m2354 Schrittzeit | 39,1 s | GA1B |  | 1
Ergebnis e183 [2026-10-21 19:31]: erfuellt
  Fazit: Der Adam auf der Karte ist bitgleich und die Rot-Probe greift; die Korrektheit ist damit belegt. Das Tempo (Adam 48,7 -> 8,9 s) ist laut Kriterium nur Beobachtung, weil rechner-b belegt war; die tragende Tempozahl kommt aus snai/gpu-adam-seg256.
  Offen: Tempo auf freiem Rechner (in snai/gpu-adam-seg256 nachgeholt).
  Datei: rechner-b:~/snai_pruef/cuda_i8/kriterien.txt
Chronik:
  2026-10-21 19:30 angelegt (Nachtrag: Nachtrag 2026-10-21 aus der Kriteriendatei und rechner-b ~/snai_pruef/cuda_i8/out/GA*.)
  2026-10-21 19:31 Rezept r195 (GA0, GA1, GA1R, GA2, GA1B)
  2026-10-21 19:31 Status geplant -> laeuft (Rezept r195)
  2026-10-21 19:31 Messwerte m2350-m2354
  2026-10-21 19:31 Ergebnis e183: erfuellt
  2026-10-21 19:31 Status laeuft -> ausgewertet (Ergebnis e183)
```
