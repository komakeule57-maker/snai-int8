# snai/zeitzerlegung-ctx1024

```text
snai/zeitzerlegung-ctx1024 - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:32
!! ohne Kriterium
Frage: Wo geht bei ctx 1024 (1024x2, Produktionsrezept) die Schrittzeit hin?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Plan: Zeitzerlegung D0/D1 mit Diagnose-Bau.
Baut auf: snai/cuda-fwd-kachel
Darauf baut: snai/att-bw-parallel
Rezepte:
  r201 [2026-10-21] D0, D1: Diagnose-Läufe D0, D1 (cuda_fwd/diag_fwd)
      quelltext: Diagnose-Bau cuda_fwd/diag
      parameter: 1024x2, ctx 1024, Vokabular 8192
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/cuda_fwd/prof
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/cuda_fwd/prof. Die Kriteriendatei von att_bw nennt '6,37 von 9,65 s'.
  m2411 Schrittzeit | 10.686 ms | D0 |  | 1
  m2412 Schrittzeit | 9.700 ms | D1 |  | 1
  m2413 Attention rückwärts | 6.371 ms (66 %) | D1 |  | 1
Ergebnis e189 [2026-10-21 19:32]: beobachtung
  Fazit: Bei langem Kontext steckt zwei Drittel der Zeit in der seriellen Attention-Rückwärtsschleife. Das war der Anlass für snai/att-bw-parallel.
  Datei: rechner-b:~/snai_pruef/cuda_fwd/prof
Chronik:
  2026-10-21 19:31 angelegt (Nachtrag: Nachtrag 2026-10-21 aus rechner-b ~/snai_pruef/cuda_fwd/prof (2026-10-14 15:37) und rechner-a ~/Projekte/snai_edge_int8_lora/docs/VERGLEICH_LITERATUR_KOPIEREN.md (Abschnitt 6ak). Profil ohne Kriterium.)
  2026-10-21 19:32 Rezept r201 (D0, D1)
  2026-10-21 19:32 Status geplant -> laeuft (Rezept r201)
  2026-10-21 19:32 Messwerte m2411-m2413
  2026-10-21 19:32 Ergebnis e189: beobachtung
  2026-10-21 19:32 Status laeuft -> ausgewertet (Ergebnis e189)
```
