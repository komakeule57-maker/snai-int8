# snai/kopier-knirps-fenster-je-schritt

```text
snai/kopier-knirps-fenster-je-schritt - ausgewertet, begonnen 2026-10-13, angelegt 2026-10-21, zuletzt 2026-10-21 11:27
Frage: Wie hängen Material (Fenster) und Updates bis zum Einsetzen des Kopierens (`var`, 32/2/16) an der Zahl der Fenster je Adam-Schritt (N = 1, 4, 16, 64), bei konstanter und fallender Rate und bei verschiedenem Warmup?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  Stopp bei >= 90 % Rang 0 zweite Kopie (200 frische Fenster); gemessen Segmente à 5000 Fenster bis dahin. Urteil nach Regel: Unterschied zählt bei mehr als 1 Segment und gleicher Richtung in allen Saaten. Fallend = Cosinus 0,001 -> 0,0001 über 100.000 Fenster (frei gewählt, größter freier Parameter).
Plan: rechner-a:~/snai_pruef/knirps/akkum_kriterien.txt (mit Abschnitt ERWEITERUNG)
Baut auf: snai/kopier-knirps-gitter, snai/kopier-mini-lr-batch
Rezepte:
  r44 [2026-10-21] k. A. (Aufrufe nicht wörtlich im Eintrag; Skripte reihe_akkum.sh, reihe_akkum2.sh; Gradienten-Sammeln per SNAI_ACCUM_WINDOWS als Patch auf knirps/proj_akk)
      parameter: `var`, wort256, Zelle 32/2/16, 2 Schichten, ctx 64, Ganzzahl-Stack gebunden, LR 0,001 (nicht mit N skaliert), WD 0,1, Revival aus, Segmente à 5000 Fenster, Stopp bei >= 90 %. Runde 1: N=1 Warmup 500; N=16 Warmup 500 Updates; N=16 Warmup 32 Updates. Runde 2: N = 1/4/16/64, Warmup 512 Fenster, konstant bzw. fallend (Cosinus 0,001 -> 0,0001 über 100.000 Fenster). 3 Saaten je Arm, gepaart über Armnamen ak_d32h2_s<S>; kein Lade-Wächter-Eingriff
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/akk/{n1,n16w500,n16w32,k4,k64,f1,f4,f16,f64}/; Doku 6q
Messwerte (Groesse | Wert | Arm | Start | n):
  (Segmente à 5000 Fenster bis >= 90 %, Saat 1/2/3)
  m365 Segmente bis >= 90 % | 3 / 4 / 3 | konstant N=1 |  | 3
  m366 Segmente bis >= 90 % | 4 / 4 / 4 | konstant N=4 |  | 3
  m367 Segmente bis >= 90 % | 7 / 8 / 8 (Warmup 500 Updates); 7 / 7 / 6 (Warmup 32 Updates) | konstant N=16 |  | 3
  m368 Segmente bis >= 90 % | 11 / 12 / 11 | konstant N=64 |  | 3
  m369 Segmente bis >= 90 % | 2 / 17 / 3 | fallend N=1 |  | 3
  m370 Segmente bis >= 90 % | 4 / 4 / 4 | fallend N=4 |  | 3
  m371 Segmente bis >= 90 % | 7 / 7 / 7 | fallend N=16 |  | 3
  m372 Segmente bis >= 90 % | 16 / 28 / 15 | fallend N=64 |  | 3
  m373 Material N 1 -> 64 | x3,4 (Fenster ~ N^0,30, grob) | konstant
  m374 Updates bis Einsetzen N 1 -> 64 | 16.667 -> 885 | konstant
  m375 Clip greift | 0 % der Updates bei N=16, 100 % bei N=1 | Telemetrie-Stichprobe
  m376 Rot-Proben | 0,2-0,6 % | alle 24 + 9 Läufe
Ergebnis e41 [2026-10-21 11:27]: teilweise
  Fazit: Hauptfrage entschieden: mehr Fenster je Adam-Schritt macht das Einsetzen in FENSTERN langsamer (N 1 -> 64: Material x3,4), in UPDATES schneller (ein Neunzehntel); weder Material noch Updates bis zum Einsetzen sind über die Batchgröße konstant. Beim 32er-Knirps lernt Batch 1 bei LR 0,001 schneller (in Fenstern) als Batch 16, anders als im PyTorch-Nachbau (snai/kopier-mini-lr-batch). Nicht entschieden: Warmup-Länge (0/1/2 Segmente) und fallend gegen konstant (nur N=64 in allen Saaten langsamer, N=1 uneinig); die Steigung bei fallender Rate trägt keine Zahl.
  Offen: Reichweite: eine Zelle, eine Aufgabe, LR nicht mit N skaliert. Beobachtung: Platte bei 8-12 % ab N=4, länger mit N; spät einsetzende Läufe kriechen bei fallender Rate hoch statt zu springen.
Chronik:
  2026-10-21 11:26 angelegt (Nachtrag: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:26 Rezept r44
  2026-10-21 11:26 Status geplant -> laeuft (Rezept r44)
  2026-10-21 11:26 Messwerte m365-m376
  2026-10-21 11:27 Ergebnis e41: teilweise
  2026-10-21 11:27 Status laeuft -> ausgewertet (Ergebnis e41)
```
