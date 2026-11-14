# snai/ss-knirps

```text
snai/ss-knirps - ausgewertet, angelegt 2026-11-06, zuletzt 2026-11-06 16:59
Frage: Senkt Weitertraining mit Scheduled Sampling (parallele Form, eps 0,25/0,5) die Beam-Schleife des Knirps (Drohne P 128/4/4 int8) gegenüber M und gegenüber demselben Weitertraining ohne SS (K0), ohne Beleg, TP1 und Held-out zu kosten? Liegt eine Wirkung an der eigenen Vorhersage (Gegenarm ZF25 Zufallstoken)?
Kriterium (festgelegt 2026-11-06 14:01, vor dem ersten Messwert):
  Datei ~/snai_pruef/ss/KRITERIEN_ss.md (festgelegt 2026-11-06 vor dem ersten Armlauf, Prüfer-Nachtrag ohne Änderung). Je Arm X in {SS25, SS50}, je Saat 4/5/6 (3/3 ja, 0/3 nein, sonst saatabhängig): E* U_X <= 0,9 U_M (24 Prompts Beam 3, unscharf K=2; knapp -> 36); G (Pflicht) U_X <= 0,9 U_K0; S Beleg und TP1 >= 0,9 M; K' H_X - H_K0 <= 2 %. erfuellt = ein Arm alle vier 3/3 -> Kandidat, Bestätigung s7-9 als eigene Reihe. teilweise = E*, G, S 3/3, K' nicht. verfehlt = beide Arme E* 0/3 oder G 0/3. Sonst keine_aussage. Zuschreibung: eigene Vorhersage nur, wenn U_SS <= 0,9 U_ZF25 3/3, sonst "Eingaberauschen genügt".
Plan: lib SSZ (patch_ss.py auf lib D), Arme K0/SS25/SS50/ZF25 ab M_s4-6, 1 Epoche nat.txt, LR 2,5e-5; Messung mess6/textmess10/beam12/beam12n/beam12f wie e385; M/CT aus ditto2/mess, falls beam12 an M_s4 bytegleich; Auswertung boot_ss.py.
Baut auf: snai/ditto-eigen-kopie-bestaetigung, snai/prod512b-kopierkoepfe-blick
Darauf baut: snai/ukb-runde2-prod512b
Rezepte:
  r618 [2026-11-06] cd ~/snai_pruef/ss; setsid -f bash arme.sh   # arme.sh 8c022328, Arme K0 / SS25 (SNAI_SS_EPS=0.25) / SS50 (0.5) / ZF25 (0.25 + SNAI_SS_ZUFALL=1), Saaten 4-6
      quelltext: lib SSZ bau/libcortex_ssz.so 674518c7 = cortex_ditto.nim 0706e513 + patch_ss.py 88c87c01; KRITERIEN_ss.md 50d2bf48; boot_ss.py 687c1b94 (patch_boot_ss.py 807796fe aus ditto2/boot_best2.py 35a7b3ca); Messskripte aus ditto2 (nur Pfade geändert)
      parameter: ab M_s4/5/6 (ditto2/arme), 1 Epoche ditto/daten/nat.txt a68a6d3e, LR 2,5e-5, Warmup 0, WD 0,1, OMP 3, int8 voll, gebunden, SR mv, GAIN_GUARD 0, Gaenge 1, argmax, SS-Saat 20261106
      seed: SNAI_START_OFFSET 3000003/4000003/5000003 wie M_sK; Ausgabename ft.snai in allen Armen
      rechner: rechner-a
      logs: ~/snai_pruef/ss/log/arme.log, log/<ARM>_s<K>.log, mess/*; Gerätekontrollen log/probe.log, log/probe2.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ss/log/boot_ss.out (boot_ss.py 687c1b94), log/*_s[456].err
  m9387 U/U_M (Beam 3, unscharf K=2, 24 Prompts, gepaarter Bootstrap) | 0,89 [0,73-1,08] / 0,79 [0,65-0,96] / 0,91 [0,76-1,06] | K0 | s4/s5/s6 | 24
  m9388 U/U_M (24 Prompts) | 0,73 [0,61-0,87] / 0,79 [0,66-0,94] / 0,80 [0,66-0,96] | SS25 | s4/s5/s6 | 24
  m9389 U/U_M (24 Prompts) | 0,65 [0,53-0,79] / 0,67 [0,53-0,81] / 0,59 [0,43-0,77] | SS50 | s4/s5/s6 | 24
  m9390 U/U_M (24 Prompts) | 0,94 [0,81-1,10] / 1,02 [0,89-1,16] / 0,81 [0,69-0,96] | ZF25 | s4/s5/s6 | 24
  m9391 G U_X/U_K0 (24 Prompts, Pflicht; ZF25 nur berichtet) | SS25 0,81/1,00/0,88; SS50 0,72/0,84/0,64; ZF25 1,06/1,29/0,89 | SS25, SS50, ZF25 | s4/s5/s6 | 24
  m9392 TP1 nl /M (sonde_ein.php) | K0 1,03/1,01/1,20; SS25 0,74/0,70/0,87; SS50 0,58/0,57/0,69; ZF25 0,77/0,77/0,85 | alle | s4/s5/s6 | 198
  m9393 Beleg/M (Beleg-Sonde, Grenze 200) | K0 1,09/1,06/1,06; SS25 0,94/0,92/0,93; SS50 0,84/0,85/0,85; ZF25 1,02/1,01/1,02 | alle | s4/s5/s6 | 120
  m9394 H - H_K0 (Held-out 200 Fenster) | SS25 +3,6/+3,6/+3,6 %; SS50 +8,6/+8,2/+8,1 %; ZF25 +5,9/+5,9/+6,7 %; H_K0 4,135/4,142/4,143 (-M -2,3/-2,3/-2,8 %) | alle | s4/s5/s6 | 200
  m9395 Zuschreibung U_X/U_ZF25 (24 Prompts, entfaellt, nur berichtet) | SS25 0,77/0,77/0,99; SS50 0,69/0,65/0,72 | SS25, SS50 | s4/s5/s6 | 24
  m9396 U/U_M frische 12 Prompts beam12f (nur berichtet) | K0 0,80/0,77/0,77; SS25 0,67/0,89/0,87; SS50 0,62/0,78/0,65; ZF25 0,81/0,93/0,83 | alle | s4/s5/s6 | 12
  m9397 TPe2/M pipe (Kopie erstes Wort nach 2 Wiederholungen, nur berichtet) | K0 1,18/0,87/1,62; SS25 0,19/0,18/0,29; SS50 0,05/0,10/0,10; ZF25 0,05/0,06/0,08 | alle | s4/s5/s6 | 200
  m9398 [SS] Anteil ersetzt / Trefferquote eigene Vorhersage (Engine-Zeile) | SS25 0,249 / 0,296-0,297; SS50 0,497 / 0,277-0,278; ZF25 0,249 / 0,0001; K0 keine Zeilen | SS25, SS50, ZF25 | s4/s5/s6 | 1563
  Quelle: rechner-a:~/snai_pruef/ss/log/boot_ss_reserve.out (b1a0e9df)
  m9399 U/U_M auf 36 Prompts nach Reserve beam12r (Urteil unveraendert) | s5 0,76 [0,63-0,91] / s6 0,83 [0,70-0,96] | SS25 | s5/s6 | 36
Ergebnis e565 [2026-11-06 16:59]: keine_aussage
  Fazit: Nach Wortlaut keine_aussage: S und K' 0/3 fuer SS25 und SS50, deshalb weder erfuellt noch teilweise; nicht verfehlt, weil SS50 E* und G je 3/3 hat (verfehlt war nur ueber E*/G definiert). Inhaltlich eine eindeutige Tauschlinie: Scheduled Sampling (parallele Form, ein Gang, argmax, eps 0,25/0,5 konstant, 1 Epoche LR 2,5e-5 auf nat.txt) senkt die Beam-Schleife (SS50 0,59-0,67 x M, gegen K0 0,64-0,84, gegen Rauschen ZF25 0,65-0,72), kostet aber das erwuenschte Kopieren (TP1 0,57-0,87 x M) und Held-out (+3,6 % bzw. +8 % gegen K0). UKB1 (e385) senkt die Schleife gleich weit ohne diese Kosten. Kein Nachsteuern ueber eps lohnt, keine Bestaetigung auf s7-9. Widerlegt ist nur diese Form (einzelne Token ersetzt), nicht die Idee, dem Modell seine eigene Ausgabe zu zeigen; die Variante mit eigenen Fortsetzungen ist UKB1. Deutung, nicht gemessen: Bei gleichem Kopierverlust wie ZF25 senkt SS25 die Schleife etwas mehr (2/3), die Wirkung ist also nicht nur geschwaechtes Kopieren.
  Offen: Mehrere Gaenge oder Lehrplan ungeprueft (lohnt nach diesem Befund nicht); prod512b ungemessen.
  Datei: rechner-a:~/snai_pruef/ss/ERGEBNIS_ss.md
Chronik:
  2026-11-06 14:01 angelegt
  2026-11-06 14:05 Rezept r618
  2026-11-06 14:05 Status geplant -> laeuft (Rezept r618)
  2026-11-06 16:56 Messwerte m9387-m9398
  2026-11-06 16:59 Messwerte m9399
  2026-11-06 16:59 Ergebnis e565: keine_aussage
  2026-11-06 16:59 Status laeuft -> ausgewertet (Ergebnis e565)
```
