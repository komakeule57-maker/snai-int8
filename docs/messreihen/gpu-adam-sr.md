# snai/gpu-adam-sr

```text
snai/gpu-adam-sr - ausgewertet, begonnen 2026-10-19, angelegt 2026-10-21, zuletzt 2026-10-21 19:33
Frage: Rechnet der SR-Adam auf der Karte über ein ganzes Segment bitgleich zur CPU in 3/3 Saaten, und ist er in 3/3 Saaten mindestens 10 % schneller als der Adam auf der CPU?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus der Kriteriendatei (enthält ERGEBNIS 2026-10-19 06:41), out/seg256_sr.txt, out/gpu_sr*.):
  Vorab rechner-b ~/snai_pruef/cuda_i8/kriterien_seg256_sr.txt (2026-10-19, vor dem ersten Lauf): bitgleich = md5, alle Step- und Telemetrie-Zeilen gleich R für A und B in 3/3 Saaten; Aufrufnachweis; ROT weicht ab; Tempo B gegen A gepaart, Regel aus kriterien_seg256.txt; Lastregel unverändert.
Plan: rechner-b:~/snai_pruef/cuda_i8/kriterien_seg256_sr.txt (Vorprüfung gpu_sr, dann Segment 256 mit SR je Saat R, A, B, danach ROT)
Baut auf: snai/gpu-adam-seg256
Rezepte:
  r206 [2026-10-21] R, A, B, ROT: bash gpu_sr.sh; bash seg256_sr.sh
      quelltext: bau_sr: libcortex.so 9d02d504 (Projektbaum 0dc87db + patch_sr_gpu.py), libcortex_cuda.so ecc68621
      parameter: wie snai/gpu-adam-seg256 (Textrezept 256/16, Segment 10, Basis s9, OMP 1, Revival aus), SR mv in allen Armen
      seed: 1, 2, 3
      rechner: rechner-b (RTX 3050)
      logs: rechner-b:~/snai_pruef/cuda_i8/out/seg256_sr/
      notiz: sperre_sr.sh ist eine verworfene Vorstufe.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/cuda_i8/kriterien_seg256_sr.txt (ERGEBNIS), out/seg256_sr.txt; Held-out-Vergleich außerhalb der Kriterien (ohne SR vom 2026-10-14, andere Bibliothek)
  m2441 Vorprüfung gpu_sr | 9 von 9 OK | gpu_sr |  | 9
  m2442 md5, Step- und Telemetrie-Zeilen | gleich R (6cbb5ec3) | A, B | 1 | 2
  m2443 md5, Step- und Telemetrie-Zeilen | gleich R (9f4ca9b2) | A, B | 2 | 2
  m2444 md5, Step- und Telemetrie-Zeilen | gleich R (701d3ab0) | A, B | 3 | 2
  m2445 Aufrufe GPU-Adam | 64.948 | B |  | 3
  m2446 ROT erste Abweichung | Step 2 | ROT | 1 | 1
  m2447 Wandzeit B gegen A | 219 gegen 495 s | B, A | 1 | 1
  m2448 Wandzeit B gegen A | 221 gegen 499 s | B, A | 2 | 1
  m2449 Wandzeit B gegen A | 219 gegen 495 s | B, A | 3 | 1
  m2450 Held-out R mit SR gegen ohne SR | +4,7 % | R | 1 | 1
  m2451 Held-out R mit SR gegen ohne SR | +2,7 % | R | 2 | 1
  m2452 Held-out R mit SR gegen ohne SR | +3,0 % | R | 3 | 1
Ergebnis e196 [2026-10-21 19:33]: erfuellt
  Fazit: Der SR-Adam auf der Karte ist in allen drei Saaten bitgleich und um 56 % schneller; nach der vorab festgelegten Regel ging er in den Projektbaum (3e4904f). Außerhalb der Kriterien fällt auf, dass SR selbst den Held-out in allen drei Saaten um 3 bis 5 % verschlechtert. Das ist formal Gleichstand, aber gleichgerichtet, und gehört beobachtet, bevor SR als neutral gilt.
  Offen: Ob der Held-out-Nachteil von SR bleibend oder vorübergehend ist (Wechsel mitten in der Reihe).
  Datei: rechner-b:~/snai_pruef/cuda_i8/kriterien_seg256_sr.txt
Chronik:
  2026-10-21 19:32 angelegt (Nachtrag: Nachtrag 2026-10-21 aus der Kriteriendatei (enthält ERGEBNIS 2026-10-19 06:41), out/seg256_sr.txt, out/gpu_sr*.)
  2026-10-21 19:33 Rezept r206 (R, A, B, ROT)
  2026-10-21 19:33 Status geplant -> laeuft (Rezept r206)
  2026-10-21 19:33 Messwerte m2441-m2452
  2026-10-21 19:33 Ergebnis e196: erfuellt
  2026-10-21 19:33 Status laeuft -> ausgewertet (Ergebnis e196)
```
