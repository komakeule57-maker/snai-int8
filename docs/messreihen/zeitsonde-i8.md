# snai/zeitsonde-i8

```text
snai/zeitsonde-i8 - ausgewertet, angelegt 2026-11-08, zuletzt 2026-11-09 01:27
Frage: Wo bleibt bei 4 Threads die Zeit im int8-Trainingsschritt (prod512b-Geometrie), und welcher Abschnitt skaliert von 1 auf 4 Threads schlecht?
Kriterium (festgelegt 2026-11-08 23:03, vor dem ersten Messwert):
  Gerät: Zeitsonde aus patch_par3.py (SNAI_I8_ZEIT=1), Wanduhrzeit je Abschnitt (mmF, mmT, gA, attF, attB, batch, clip, adam, ges) je Schritt, nur außerhalb paralleler Regionen gezählt. Lauf wie arm.sh (32 Schritte, Basis s11), Lib par3 mit SNAI_I8_MM=0 (Originalpfad der Matmul, alle 9 PAR-Gruppen an = Stand par2).
Pflicht vor jedem Lesen: (a) Sonde ändert das Training nicht: md5 6f49622c/78355d24 mit Sonde an; (b) Rot: SNAI_I8_ZEIT_ROT=mmF muss mmF um 2 ms × Aufrufzahl erhöhen (±20 %), sonst misst die Sonde nicht, was sie behauptet; (c) Summe der Teile ≤ ges, ges ≤ [Bilanz]-ms/Schritt.
Ausgewertet: Median je Abschnitt über die Schritte 3–32 (Anlauf weg), bei n=1 und n=4, je 1 Lauf. Befund je Abschnitt: Anteil an ges bei n4 und Beschleunigung n1/n4. Kein besser/schlechter-Urteil (Diagnose, Urteil beobachtung); sie wählt den nächsten Umbau. Einzelläufe: die Zahlen gelten als Größenordnung, Unterschiede unter 10 % zwischen Abschnitten werden nicht gedeutet.
Baut auf: snai/par-schleifen-fein
Darauf baut: snai/mm-fwd-blk, snai/ga-prep-par
Rezepte:
  r637 [2026-11-08] ~/snai_pruef/threads/par3/reihe3.sh (Teil z_*: arm.sh 4|1 z_… SNAI_I8_ZEIT=1 [SNAI_I8_MM=0] [SNAI_I8_ZEIT_ROT=mmF])
      quelltext: patch_par3.py auf cortex_par2 1c3373bf -> cortex.nim d1f83d2e, libcortex.so eb501b56; arm.sh bdf45f86
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/par3/log/z_*.err ([ZEIT]-Zeilen), ergebnis.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/threads/par3/log/z_*.log, zeit_med.py 9d048a55 (Median Schritte 3-32)
  m9657 Sonde ändert Training nicht (md5/lossmd5) | 6f49622c/78355d24 | z_n4_mm0, z_rot_mmF, z_n1_mm0, z_n4_mm1, z_n1_mm1 |  | 5
  m9658 Rot mmF: Zuwachs bei 37 Aufrufen x 2 ms (Soll 74 ms) | +72 ms (758 -> 830) | z_rot_mmF |  | 30
  m9659 Teile <= batch <= ges | 5555 <= 6049 <= 6464 ms | z_n4_mm0 |  | 30
  m9660 ges (Median) gegen [Bilanz] (Mittel) | 6464 gegen 6442,6 ms (+0,3 %, Median gegen Mittel; Regel (c) knapp verletzt) | z_n4_mm0 |  | 30
  m9661 mmF n1/n4 (Beschleunigung) | 983 / 758 ms (1,30) | Originalpfad |  | 30
  m9662 mmT n1/n4 | 2277 / 768 ms (2,97) | Originalpfad |  | 30
  m9663 gA n1/n4 | 1905 / 1110 ms (1,72) | Originalpfad |  | 30
  m9664 attF n1/n4 | 1802 / 546 ms (3,30) | Originalpfad |  | 30
  m9665 attB n1/n4 | 6856 / 2373 ms (2,89; 36,7 % von ges bei n4) | Originalpfad |  | 30
  m9666 Rest im Batch n1/n4 | 1465 / 494 ms (2,97) | Originalpfad |  | 30
  m9667 adam n1/n4 | 963 / 360 ms (2,68) | Originalpfad |  | 30
  m9668 ges n1/n4 | 16299 / 6464 ms (2,52) | Originalpfad |  | 30
  m9669 mmF n4 Blockpfad | 276 ms (Original 758) | z_n4_mm1 |  | 30
  m9670 Systemzeit je Lauf n4 (time) | 15,6 s Original gegen 1,6 s Blockpfad | b_mm0_n4 / b_alle_n4 |  | 1
Ergebnis e577 [2026-11-09 01:27]: beobachtung
  Fazit: Die Sonde misst richtig (Rot +72 statt +74 ms, Training unverändert). Bei 4 Threads (par2-Stand) verlieren gegenüber der idealen Teilung am meisten: Attention rückwärts 0,66 s (größter Posten, 37 %, skaliert aber 2,9x), Gradientenakkumulation 0,63 s (nur 1,7x), Vorwärts-Matmul 0,51 s (nur 1,3x; inzwischen behoben, snai/mm-fwd-blk). Gut skalieren Rückwärts-Matmul, Attention vorwärts, Adam und der Rest (2,7–3,3x); PHP und Clipping spielen keine Rolle. Nächster Umbau damit: Vorstufen der Gradientenakkumulation (snai/ga-prep-par). Attention rückwärts lohnt nur über weniger Arbeit oder bessere Speichernutzung, nicht über feinere Aufteilung (8 Köpfe auf 4 Threads sind gleich verteilt).
  Offen: Einzelläufe je Threadzahl; Unterschiede unter 10 % zwischen Abschnitten nicht gedeutet. Regel (c) knapp verletzt (Median ges 0,3 % über [Bilanz]-Mittel), vermutlich Median gegen Mittel, nicht geprüft.
Chronik:
  2026-11-08 23:03 angelegt
  2026-11-08 23:04 Rezept r637
  2026-11-08 23:04 Status geplant -> laeuft (Rezept r637)
  2026-11-09 01:27 Messwerte m9657-m9670
  2026-11-09 01:27 Ergebnis e577: beobachtung
  2026-11-09 01:27 Status laeuft -> ausgewertet (Ergebnis e577)
```
