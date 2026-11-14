# snai/adam-parallel

```text
snai/adam-parallel - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:31
Frage: Rechnet der parallele Adam (über OpenMP) bitgleich zur Referenz R, bei 1, 2 und 8 Threads und mit Karte?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus rechner-b ~/snai_pruef/cuda_i8/out/ (adampar.sh, 2026-10-14 06:29).):
  Maßstab aus rechner-b ~/snai_pruef/cuda_i8/kriterien.txt (2026-10-13): bitgleich = alle Step-Zeilen und md5 gleich dem CPU-Lauf mit unveränderter Bibliothek (R, d0d5e143c924). Tempo ohne eigene Schwelle.
Plan: Läufe N1, N2, N8 (Threads), NG (mit Karte) gegen R; Tempo S8 (serieller Adam, OMP 8) gegen N8.
Baut auf: snai/adam-profil
Darauf baut: snai/gpu-adam-messkopie
Rezepte:
  r193 [2026-10-21] N1, N2, N8, NG, S8: bash adampar.sh  (./lauf_test_t.sh mit OMP_T)
      quelltext: bau_adampar (patch_adam_par.py)
      parameter: Prüfstand cuda_i8/t: gen.snai 512/8, ctx 64, Zeichen-Vokabular, p300.txt, 300 Schritte, Laufname paar; LR 0,001, Warmup 500, INT8_FULL, gebunden; OMP 1, 2, 8
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/cuda_i8/out/N*, S*
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/cuda_i8/out/ (rc-Zeilen, Last 6,3 bzw. 7,9, je ein Lauf)
  m2347 md5 und Step-Zeilen | gleich R (d0d5e143c924) | N1, N2, N8, NG, S8 |  | 5
  m2348 Laufzeit 300 Schritte OMP 8 | 52,885 s | N8 paralleler Adam |  | 1
  m2349 Laufzeit 300 Schritte OMP 8 | 111,84 s | S8 serieller Adam |  | 1
Ergebnis e182 [2026-10-21 19:31]: erfuellt
  Fazit: Der parallele Adam ist bitgleich bei jeder Threadzahl und mit Karte und halbiert bei acht Threads die Laufzeit. Er konnte deshalb ohne Risiko für die Reproduzierbarkeit in den Projektbaum.
  Offen: Tempo nur ein Lauf je Arm (Beobachtung).
  Datei: rechner-b:~/snai_pruef/cuda_i8/adampar.sh
Chronik:
  2026-10-21 19:30 angelegt (Nachtrag: Nachtrag 2026-10-21 aus rechner-b ~/snai_pruef/cuda_i8/out/ (adampar.sh, 2026-10-14 06:29).)
  2026-10-21 19:31 Rezept r193 (N1, N2, N8, NG, S8)
  2026-10-21 19:31 Status geplant -> laeuft (Rezept r193)
  2026-10-21 19:31 Messwerte m2347-m2349
  2026-10-21 19:31 Ergebnis e182: erfuellt
  2026-10-21 19:31 Status laeuft -> ausgewertet (Ergebnis e182)
```
