# snai/speicher-2048x8

```text
snai/speicher-2048x8 - ausgewertet, begonnen 2026-10-16, angelegt 2026-10-21, zuletzt 2026-10-21 19:18
!! ohne Kriterium
Frage: Wie viel RAM und VRAM braucht ein Training 2048 x 8 (ffn 8192, Vokabular 8192, gebunden, 16 Koepfe, ctx 512) mit dem Projektbaum (git 21b7fde), und wie lange dauert ein Schritt? Grundlage fuer die Hochrechnung auf 16 Schichten und die Wahl rechner-b / vserver.
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Rezepte:
  r136 [2026-10-21] rechner-b ~/snai_pruef/gross/baum: Genesis init_base.php V6 Saat 1, Lauf ueber den Anfang von k512.txt (~6 Fenster) mit ram_mess.py, nvidia-smi je 1 s; Zellen C (SNAI_FORCE_CPU=1), G (Karte), GA (+SNAI_I8_GPU_ADAM=1), G4 (2048 x 4)
      quelltext: Kopie von ramfix/rv = Projektbaum git 21b7fde; zweiter Durchgang mit libcortex_cuda.so 7e2dfedd (im ersten fehlte sie -> OpenCL)
      parameter: OMP 6, Revival aus, 9 Schritte ctx 512; Arm P lief daneben mit 3 Faeden
      seed: Genesis 1
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/gross/ergebnis/ (alle.txt, ram.jsonl, <Zelle>.log/.verlauf/.vram)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/gross/ergebnis/alle.txt (VRAM und Tempo nachgelesen); RAM aus gross/kriterien.txt
  m1505 RAM Spitze Summe Pss | 5.250,6 MB | C CPU L8 | 1 | 9
  m1506 RAM Spitze Summe Pss | 5.246,2 / 3.067,2 MB | OpenCL L8 / L4 | 1 | 9
  m1507 RAM Spitze Summe Pss | 5.552,4 MB | CUDA L8 | 1 | 9
  m1508 RAM Spitze Summe Pss | 5.545,2 MB | CUDA + GPU-Adam L8 | 1 | 9
  m1509 VRAM ueber Grundlast | +2.108 / +1.148 MiB | OpenCL L8 / L4 | 1 | 9
  m1510 VRAM ueber Grundlast | +2.170 MiB | CUDA L8 | 1 | 9
  m1511 VRAM ueber Grundlast | +4.762 MiB (Spitze 5.021 von 6.144) | CUDA + GPU-Adam L8 | 1 | 9
  m1512 ms je Schritt | 34.561,9 | C CPU 6 Faeden | 1 | 9
  m1513 ms je Schritt | 36.018,2 / 19.376,7 | OpenCL L8 / L4 | 1 | 9
  m1514 ms je Schritt | 27.618,3 | CUDA L8 | 1 | 9
  m1515 ms je Schritt | 24.866,5 | CUDA + GPU-Adam L8 | 1 | 9
  m1516 Fehler | 0 | alle | 1
Ergebnis e130 [2026-10-21 19:18]: beobachtung
  Fazit: Ein 2048 x 8 passt auf rechner-b: ~5,5 GB RAM, ~2,2 GB VRAM, mit GPU-Adam 4,8 GB VRAM (passt knapp in 6 GB), ~25-28 s je Schritt auf der Karte. Hochgerechnet (Rechnung, nicht gemessen) ~11 B RAM je Parameter wie die Typen-Rechnung, L16 ~9,6 GB RAM und ~4,1 GB VRAM ohne GPU-Adam; mit GPU-Adam passt L16 nicht mehr auf die 6-GB-Karte. Damit ist fuer 16 Schichten GPU-Adam auf rechner-b ausgeschlossen.
  Offen: CUDA-Steigung je Schicht nicht gemessen (L4 nur OpenCL); je Zelle ein Lauf; Arm P lief daneben. GA im ersten Durchgang ohne Wirkung (OpenCL).
  Datei: rechner-a:~/snai_pruef/gross/kriterien.txt (Ergebnisabschnitt)
Chronik:
  2026-10-21 19:18 angelegt (Nachtrag: Aufbau aus rechner-a:~/snai_pruef/gross/kriterien.txt (vor dem Lauf geschrieben, 2026-10-16). Die Datei legt ausdruecklich fest: je 1 Lauf, 'Beobachtung mit Zahl, keine Urteilsreihe'; die Vorhersage (RAM 5,5-6,7 GB + Aktivierungen, VRAM ~0,4 GB bzw. +2,5 GB mit GPU-Adam) ist kein Kriterium.)
  2026-10-21 19:18 Rezept r136
  2026-10-21 19:18 Status geplant -> laeuft (Rezept r136)
  2026-10-21 19:18 Messwerte m1505-m1516
  2026-10-21 19:18 Ergebnis e130: beobachtung
  2026-10-21 19:18 Status laeuft -> ausgewertet (Ergebnis e130)
```
