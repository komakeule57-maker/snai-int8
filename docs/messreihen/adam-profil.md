# snai/adam-profil

```text
snai/adam-profil - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:30
!! ohne Kriterium
Frage: Wo geht die Zeit im Ganzzahl-Training (Prüfstand 512/8) hin, insbesondere wie groß ist der Adam-Anteil?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Plan: Profil-Bau (bau_prof, bau_profad) mit Eimern je Rechenschritt.
Baut auf: snai/tempo-rechenwege
Darauf baut: snai/adam-parallel
Rezepte:
  r190 [2026-10-21] bash prof.sh; bash prof2.sh; bash profad.sh
      quelltext: bau_prof, bau_par, bau_profad (patch_prof_i8.py, patch_prof_adam.py)
      parameter: Prüfstand cuda_i8/t: gen.snai 512/8, ctx 64, p300.txt, 300 Schritte, Laufname paar, INT8_FULL, gebunden
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/cuda_i8/out/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/cuda_i8/out/ (prof, profad)
  m2312 Schrittzeit 300 Schritte | 135,9 s | CPU seriell |  | 1
  m2313 Adam | 93,7 s (69 %) | CPU seriell |  | 1
  m2314 Adam | 63,1 s | bau_par |  | 1
  m2315 Schrittzeit 300 Schritte | 104,7 s | bau_par |  | 1
  m2316 Momente zurückschreiben | 44,2 / 45,1 s (55 %) | profad |  | 2
Ergebnis e179 [2026-10-21 19:30]: beobachtung
  Fazit: Der Adam frisst gut zwei Drittel der Schrittzeit, davon wieder gut die Hälfte das Zurückschreiben der 8-Bit-Momente. Das zeigte, wo Tempo zu holen war, und führte zu Adam parallel und Adam auf der Karte.
  Datei: rechner-b:~/snai_pruef/cuda_i8/profad.sh
Chronik:
  2026-10-21 19:29 angelegt (Nachtrag: Nachtrag 2026-10-21 aus rechner-b ~/snai_pruef/cuda_i8/out/ (prof.sh, prof2.sh, profad.sh; Skripte 2026-10-14 04:58 bis 06:30) und rechner-a ~/Projekte/snai_edge_int8_lora/docs/VERGLEICH_LITERATUR_KOPIEREN.md (Abschnitt 6ab). Profil ohne Kriterium.)
  2026-10-21 19:29 Rezept r190
  2026-10-21 19:29 Status geplant -> laeuft (Rezept r190)
  2026-10-21 19:29 Messwerte m2312-m2316
  2026-10-21 19:30 Ergebnis e179: beobachtung
  2026-10-21 19:30 Status laeuft -> ausgewertet (Ergebnis e179)
```
