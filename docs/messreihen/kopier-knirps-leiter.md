# snai/kopier-knirps-leiter

```text
snai/kopier-knirps-leiter - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 11:25
Frage: Wie klein darf ein Zwei-Schicht-Knirps sein und noch inhaltsbasiertes Kopieren lernen (`var`, ctx 64, wort256, gebunden, Ganzzahl-Stack), Breite 2-64 bei LR 0,0001 und 0,001?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  Gelernt = Rang 0 auf der zweiten Kopie >= 90 % auf frischen Fenstern; nicht gelernt = < 10 % nach 60.000 Fenstern; Rot-Probe = erste Kopie fremd -> unter 10 %.
Baut auf: snai/kopier-mini-lr-reihe, snai/kopier-drohne-kopfpaar
Darauf baut: snai/kopier-knirps-schaltkreis, snai/kopier-revival, snai/kopier-knirps-gitter, snai/kopier-smiley, snai/knirps-kopfbreite-erst
Rezepte:
  r36 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben; Skript ~/snai_pruef/knirps/lauf.sh, Revival-aus-Gegenprobe mit PROJ=proj_r0, Keller-Leiter ~/snai_pruef/mini/keller)
      parameter: Aufgabe `var`, ctx 64, 2 Schichten, wort256, gebunden, Ganzzahl-Stack, 1 Arbeiter, Warmup 500, WD 0,1, Segmente zu 5.000 Fenstern, Budget 60.000, Bibliothek 1c634106 aus Arm E; Breiten 2/4/8/16/32/64 mit Köpfen 1/2/4 (ab Breite 8: 4), ffn = 4 x Breite; LR 0,0001 und 0,001; je Zelle EIN Lauf, gleiche Daten und Genesis-Saat; Revival an (Gegenprobe aus)
      rechner: rechner-a
Messwerte (Groesse | Wert | Arm | Start | n):
  m293 R0 Ende, LR 0,0001 / 0,001 | 0,5 % / 0,4 % | Breite 2
  m294 R0 Ende, LR 0,0001 / 0,001 | 0,4 % / 0,4 % | Breite 4
  m295 R0 Ende, LR 0,0001 / 0,001 | 0,6 % / 0,5 % | Breite 8 (4 Köpfe)
  m296 R0 Ende, LR 0,0001 / 0,001 | 2,9 % langsam steigend / ~5 % ab 20.000, dann Stillstand | Breite 16 (4 Köpfe)
  m297 R0, LR 0,0001 / 0,001 | 12,2 % steigend / 90,9 % nach 20.000 (Rot 0,3 %) | Breite 32 (4 Köpfe)
  m298 R0, LR 0,0001 / 0,001 | 94,8 % nach 45.000 (Rot 0,2 %) / Stillstand ~12 %, Ende 6,9 % | Breite 64 (4 Köpfe)
  m299 R0 Ende ohne Revival, LR 0,0001, Breite 4/8/16/32 | 0,4 / 0,7 / 3,2 / 11,4 % (mit Revival 0,4 / 0,6 / 2,9 / 12,2 %) | Revival aus
  m300 R0 Ende mit Vokabular 8192, LR 0,0001, Breite 8/16/32 | 0,5 / 2,1 / 11,3 %; Breite 64 gelernt nach 40.000 | Keller-Leiter
Ergebnis e37 [2026-10-21 11:25]: teilweise
  Fazit: Kleinster kopierender Knirps der Leiter: Breite 32 (4 Köpfe, 32.768 Parameter) mit LR 0,001; Breite 64 lernt nur mit 0,0001. Die tragfähige LR hängt an der Breite (32: 0,001 ja / 0,0001 nein; 64 und 128 umgekehrt), Richtung „breiter verträgt weniger“, hier nur mit zwei Raten. Breite <= 16 lernt in dieser Leiter nicht, aber nur mit 4 Köpfen (Kopfbreite <= 4) und 60.000 Fenstern: das Gitter (snai/kopier-knirps-gitter) zeigt, dass Breite 16 mit 1-2 Köpfen lernt. Die Lernkurve in Fenstern hängt kaum am Vokabular (ohne Vorab-Kriterium), die Rechenzeit schon.
  Offen: Je Zelle ein Lauf, eine Saat. Die Entwarnung „Revival ist nicht schuld“ galt nur für 60.000 Fenster bei LR 0,0001 (zurückgenommen). Vorbehalt Lade-Wächter: Knirps-Werte teils mit aktivem Wächter gemessen und nicht neu gemessen.
Chronik:
  2026-10-21 11:23 angelegt (Nachtrag: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:24 Rezept r36
  2026-10-21 11:24 Status geplant -> laeuft (Rezept r36)
  2026-10-21 11:24 Messwerte m293-m300
  2026-10-21 11:25 Ergebnis e37: teilweise
  2026-10-21 11:25 Status laeuft -> ausgewertet (Ergebnis e37)
```
