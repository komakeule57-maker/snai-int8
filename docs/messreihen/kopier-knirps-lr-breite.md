# snai/kopier-knirps-lr-breite

```text
snai/kopier-knirps-lr-breite - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 11:25
Frage: Welche Lernrate trägt das Kopieren (`var`) bei Breite 64 und 32, und verschiebt die Breite die Grenzrate (Knirps 64/2-64/16 und 32/2, ohne Revival)?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt (Reihe 3 mit Prüfer vor dem Start); Wortlaut der Regel für Reihe 3 im Eintrag nur sinngemäß):
  Gelernt = Rang 0 zweite Kopie >= 90 % (erstes Segment; 89,5 zählt als 90, streng daneben).: Plateau 50..90 %, nicht < 10 % am Ende; Breite 64: beide Saaten müssen übereinstimmen. Reihe 2 (gain_kriterien.txt, vor dem Start): je Zelle und Rate „kleinere Rate lernt“, wenn >= 2 von 3 Saaten >= 90 % erreichen und bei 0,001 keine; lernt 0,001 ebenfalls >= 2 von 3 -> kein Ratenbefund; sonst saatabhängig. Reihe 3 (vor dem Start): Grenze je Zelle zwischen der größten Rate mit 3/3 gelernt und der kleinsten mit 0/3, Raten mit 1-2/3 = Übergangszone; „Breite verschiebt die Grenze“ nur, wenn die Übergangszone (bzw. das Grenzintervall) von 32/2 vollständig oberhalb der von 64/2 liegt. „Nicht gelernt“ heißt nur: nicht in 120.000 Fenstern mit konstanter Rate.
Plan: rechner-a:~/snai_pruef/knirps/gain_kriterien.txt (Reihe 2 und 3)
Baut auf: snai/kopier-knirps-gitter
Darauf baut: snai/kopier-knirps-b64-ursache, snai/multistack-stapel-64
Rezepte:
  r40 [2026-10-21] k. A. (Aufruf nicht im Eintrag; Skripte reihe_folge.sh, auswert_lr.sh (Reihe 2), reihe_grenze.sh, auswert_grenze.sh (Reihe 3))
      parameter: `var`, wort256, 2 Schichten, ctx 64, gebunden, Ganzzahl-Stack, Revival aus. Die Vorreihe (2026-10-12, mit Lade-Wächter): Breite 64 mit 2/4/8/16 Köpfen, je 2 Saaten; Protokoll A: 60.000 Fenster LR 0,001, dann 60.000 mit 0,0001 (Arme n2_d64h*); Protokoll B: LR 0,0001 von Anfang an, 90.000 Fenster (Arme n_d64h*). Reihe 2/3 (2026-10-13/14, Wächter aus, Projektkopien proj_lr1/lr3/lr5/lr7/lr15/lr20/lr30 von proj_ow, gleiche Bibliothek 563780e3): WD 0,1, Warmup 500, konstante Rate, 24 Segmente = 120.000 Fenster, 3 Saaten, gepaart (Step-1-Zeile gleich); Zellen 64/2, 64/8 (LR 0,0001-0,001), 32/2 (LR 0,001-0,003)
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/lr/; Doku 6y, 6ac
Messwerte (Groesse | Wert | Arm | Start | n):
  (Protokolle A/B, mit Lade-Wächter)
  m326 R0 Ende Protokoll A (0,001 dann 0,0001) | 86,5 / 23,4 % (saatabhängig) | 64/2/32 |  | 2
  m327 R0 Ende Protokoll A | 24,6 / 26,5 % | 64/4/16 |  | 2
  m328 R0 Ende Protokoll A | 19,2 / 17,5 % | 64/8/8 |  | 2
  m329 R0 Ende Protokoll A | 13,2 / 15,0 % | 64/16/4 |  | 2
  m330 Protokoll B (LR 0,0001) | 2/2 gelernt nach 30.000 (98,1 / 96,6 %) | 64/2/32 |  | 2
  m331 Protokoll B | 2/2 gelernt nach 45.000-50.000 | 64/4/16 |  | 2
  m332 Protokoll B | uneinig: Saat 1 ab 70.000 auf 86,1 % steigend, Saat 2 18,7 % | 64/8/8 |  | 2
  m333 Protokoll B | beide 14,4 %, langsam steigend | 64/16/4 |  | 2
  (Wächter aus, Segment bis >= 90 % je Saat 1/2/3)
  m334 Segment bis >= 90 %, LR 0,0001 / 0,0003 / 0,0005 / 0,0007 / 0,001 | 5/5/5; 1/2/1; 1/1/1; 2/nie/2; nie (0/3) | 64/2 |  | 3
  m335 Segment bis >= 90 %, LR 0,0001 / 0,0003 / 0,0005 / 0,0007 / 0,001 | 19 (streng 20)/22/20; 9/8/7; 5/4/3; 2/2/2; 0/3 | 64/8 |  | 3
  m336 Segment bis >= 90 %, LR 0,001 / 0,0015 / 0,002 / 0,003 | 2/3/2; 1/nie/1; 1/nie/2; 0/3 | 32/2 |  | 3
  m337 R0 Ende | 99,5-99,8 % (64/2) bzw. 94,5-98,4 % (64/8) | Reihe 2, gelernte Läufe
  m338 R0 Ende nahe der Grenze | 98 -> 86-91 % | 32/2 bei 0,0015-0,002
  m339 L0.rms_ffn abgestorben bei 0,0003 | 3/3, zwischen Segment 16 und 23, Leistung 99,6-99,8 % | 64/2 |  | 3
Ergebnis e35 [2026-10-21 11:25]: erfuellt
  Fazit: Die tragfähige LR sinkt mit der Breite: Reihe 2 bestätigt ohne Wächter und mit 3 Saaten „kleinere Rate lernt“ bei Breite 64 (0,001 in 0/3, 0,0003 und 0,0001 je 3/3); Reihe 3: das Grenzintervall von 32/2 (0,001-0,003) liegt vollständig über dem von 64/2 (0,0005-0,001) = „Breite verschiebt die Grenze“. Unterhalb der Grenze gilt: höhere Rate = schneller, die schnellste Rate liegt direkt unter der Kante. LR 0,001 lässt sich bei Breite 64 durch späteres Senken in 60.000 Fenstern nicht heilen. Folge für Rezepte: Breite 64 mit 0,0005 fahren, nicht 0,001. Deutung, nicht gemessen: verträgliche Rate ~ 1/Breite (µP-artig), geprüft nur 32 gegen 64.
  Offen: Die Vorreihe lief mit Lade-Wächter und anderem Protokoll (Zeiten zwischen Breiten nicht vergleichbar); Reihe 2 wiederholt es sauber. Rundung 89,5 zählt als 90. Nahe der Grenze geht Gelerntes langsam verloren (32/2 bei 0,0015-0,002). Tote FFN-Gains sind Begleiterscheinung, nicht Ursache (snai/kopier-knirps-b64-ursache).
Chronik (juengste 8 von 9, voll=True zeigt alle):
  2026-10-21 11:24 Kriterium geaendert, vorher: Gelernt = Rang 0 zweite Kopie >= 90 % (erstes Segment mit >= 90 %; 89,5 zählt gerundet als 90); Plateau 50..90 %, nicht < 10 % am Ende. Breite 64: beide Saaten müssen übereinstimmen. Reihe 2: Vorab-Regel „kleinere Rate lernt“. Reihe 3: Grenzintervalle je Breite, Vorab-Regel „Breite verschiebt die Grenze“, wenn die Intervalle sich nicht überlappen.
  2026-10-21 11:24 Kriterium vor dem ersten Messwert durch den Wortlaut aus gain_kriterien.txt (Reihe 2, Reihe 3) präzisiert.
  2026-10-21 11:25 Rezept r40
  2026-10-21 11:25 Status geplant -> laeuft (Rezept r40)
  2026-10-21 11:25 Messwerte m326-m333
  2026-10-21 11:25 Messwerte m334-m339
  2026-10-21 11:25 Ergebnis e35: erfuellt
  2026-10-21 11:25 Status laeuft -> ausgewertet (Ergebnis e35)
```
