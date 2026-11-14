# snai/ditto-maske

```text
snai/ditto-maske - ausgewertet, angelegt 2026-10-26, zuletzt 2026-10-26 11:33
Frage: Bricht die DITTO-Strafe am Übergang zwischen zwei Kopien die Schleife in der Beam-Ausgabe, wenn die übrigen Positionen der Wiederholung gar keinen Verlust bekommen statt CE? Bleibt der Beleg dabei erhalten?
Kriterium (festgelegt 2026-10-26 08:54, vor dem ersten Messwert):
  Je Arm (X0 nur Maske, X2/X5 Übergang, XM5 Mitte) und je Saat; 3/3 ja, 0/3 nein, sonst saatabhängig:
- E* (tragend): U_X <= 0,9 U_M (unscharf.py K=2, Beam 3, 24 Prompts). Knappe Fälle (95-%-Bootstrap über die Prompts schließt 0,9 ein) bekommen 12 Reserve-Prompts.
- S: Beleg >= 0,9 M UND TP1 nl >= 0,9 M.
- K': Held-out − CT <= 2 %.
Urteil:
- erfuellt = irgendein Arm mit E*, S, K' je 3/3; danach Bestätigung mit 3 neuen Saaten.
- teilweise = E* und S 3/3 ohne K'.
- verfehlt = jeder Arm E* 0/3 oder S 0/3.
- sonst keine_aussage.
Mechanismus nur berichtet: U_X <= 0,9 U_X0 bzw. U_X5 <= 0,9 U_XM5 in 3/3.
Volltext: kriterien_maske.txt ba069f07.
Plan: rechner-a:~/snai_pruef/ditto2/kriterien_maske.txt
Baut auf: snai/ditto-einstieg, snai/ditto-selten
Darauf baut: snai/ditto-eigen
Rezepte:
  r427 [2026-10-26] cd ~/snai_pruef/ditto2; for k in 1 2 3; do setsid nohup bash mas.sh $k > log/mas_kette$k.out 2>&1 < /dev/null & done; danach python3 boot_mas.py | tee log/boot_mas.out
      quelltext: mas.sh 7040f1b8; bau/libcortex_MAS.so 807ddce7 (cortex_mas.nim 43592cba = patch_maske.py 6d9f4d31 auf cortex_ein.nim aa8de9fa); daten/grenze.txt 915c9b6e; mix_t.txt 81ea3be0; Messung mess6.sh, textmess10.sh 3bbf1ab1 (saetze_frisch10.json df7f3c44), beam12.sh, beam12n.sh a678460d, Reserve beam12r.sh d056c8f2
      parameter: Alle Arme: SNAI_DITTO_REST=maske, LAMBDA 0,5, LOG, Grenzliste daten/grenze.txt. X0: EIN=0; X2: EIN=2; X5: EIN=5; XM5: EIN=5 und EIN_LAGE=mitte. Training wie DT: 1 Epoche ab drohneP_s19, LR 1e-4, Warmup 500, WD 0,1, int8 voll gebunden, SR mv, GAIN_GUARD 0, OMP 3, Ausgabe ft.snai
      seed: Saat am Laufnamen ft.snai; Ordner proj/proj_s2/proj_s3 mit SNAI_START_OFFSET 0/1000003/2000003; Bootstrap 2000 Ziehungen, Saat 20261024
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/ditto2/log/{X0,X2,X5,XM5}_s?.log, log/mas.log, mess/{,b12_,b12n_,t10_}{X0,X2,X5,XM5}_s?, arme/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ditto2/boot_mas.py 84d6d29b (patch_boot_mas.py 05b9fc94, mit Pruefung rc/Fehler je Beam-Ausgabe), Ausgabe log/boot_mas36.out 19a3d3ea (24 Prompts, bei knappen X2/X5/XM5 36 mit Reserve beam12r.sh). U = unscharf.py K=2, Beleg 120 und Held-out 200 (mess6), TP1 nl Text-Sonde frisch10. Erster Reserve-Lauf 11:18 ungueltig (relative Pfade, Matrix nicht gefunden), wiederholt 11:19-11:30; alte Fehlerzeilen in mess/b12r_*/beam.err.ungueltig1. Erste Auswertung ohne Reserve log/boot_mas.out 8f8a8636.
  m5795 U/U_M [95 %] (24 Prompts) | 1,26 [1,08-1,50] / 1,10 [0,90-1,38] / 1,35 [1,10-1,66] | X0 | 1-3 | 24
  m5796 U/U_M [95 %] (36 Prompts) | 1,09 [0,93-1,27] / 1,06 [0,87-1,29] / 0,96 [0,80-1,14] | X2 | 1-3 | 36
  m5797 U/U_M [95 %] (36 Prompts) | 0,89 [0,73-1,09] / 0,89 [0,74-1,10] / 0,84 [0,71-0,99] | X5 | 1-3 | 36
  m5798 U/U_M [95 %] (36 Prompts) | 0,88 [0,71-1,07] / 0,88 [0,72-1,07] / 0,94 [0,82-1,07] | XM5 | 1-3 | 36
  m5799 Beleg/M | 1,05 / 0,95 / 0,87 | X0 | 1-3 | 120
  m5800 Beleg/M | 1,01 / 0,88 / 0,83 | X2 | 1-3 | 120
  m5801 Beleg/M | 0,85 / 0,67 / 0,62 | X5 | 1-3 | 120
  m5802 Beleg/M | 0,84 / 0,72 / 0,61 | XM5 | 1-3 | 120
  m5803 TP1 nl/M | 1,04 / 1,04 / 1,00 | X0 | 1-3 | 198
  m5804 TP1 nl/M | 0,98 / 0,91 / 0,90 | X2 | 1-3 | 198
  m5805 TP1 nl/M | 0,75 / 0,75 / 0,71 | X5 | 1-3 | 198
  m5806 TP1 nl/M | 0,71 / 0,72 / 0,67 | XM5 | 1-3 | 198
  m5807 H-H_CT | -2,0 / -3,0 / -3,0 % | X0 | 1-3 | 200
  m5808 H-H_CT | -1,3 / -1,7 / -1,9 % | X2 | 1-3 | 200
  m5809 H-H_CT | +0,6 / +1,1 / +1,9 % | X5 | 1-3 | 200
  m5810 H-H_CT | +0,9 / +0,7 / +1,6 % | XM5 | 1-3 | 200
  m5811 R nl/R_M (Text-Sonde) | 0,97 / 0,97 / 0,96 | X0 | 1-3 | 198
  m5812 R nl/R_M (Text-Sonde) | 0,51 / 0,41 / 0,26 | X5 | 1-3 | 198
  m5813 R nl/R_M (Text-Sonde) | 0,32 / 0,31 / 0,20 | XM5 | 1-3 | 198
  m5814 TPe Kopie 2/M (nl) | 0,84 / 1,02 / 0,81 | X0 | 1-3 | 198
  m5815 TPe Kopie 2/M (nl) | 0,18 / 0,17 / 0,11 | X5 | 1-3 | 198
  m5816 TPe Kopie 2/M (nl) | 0,51 / 0,47 / 0,35 | XM5 | 1-3 | 198
  m5817 Urteile E* / S / K' | X0 0/3, 2/3, 3/3; X2 0/3, 1/3, 3/3; X5 3/3 (alle knapp), 0/3, 3/3; XM5 2/3, 0/3, 3/3 | alle | 1-3 | 3
  m5818 Mechanismus U_X/U_X0 (nur berichtet) | X2 0,90/0,99/0,77; X5 0,73/0,84/0,68; XM5 0,73/0,82/0,75; U_X5/U_XM5 1,00/1,02/0,89 | alle | 1-3 | 3
  m5819 Bestraft pen/n, maskiert | X0 0/1,000; X2 0,216/0,784; X5 0,465/0,535; XM5 0,470/0,530 | alle | 1-3 | ~1200 Fenster
Ergebnis e375 [2026-10-26 11:33]: verfehlt
  Fazit: Die Maske tut, was sie soll, bricht die Schleife aber nicht bei geschontem Beleg.
- Ohne CE auf dem Rest des Laufs fällt U gegen U5 (gleiche Strafe, CE-Rest) von 1,53-1,77 auf 0,84-0,89 x M. Die CE auf dem Rest war also das Kopiersignal, jetzt durch einen Eingriff isoliert.
- Nur Maske (X0): Kopieren beim Lesen auf M-Niveau (R/R_M 0,96-0,97, TP1 1,00-1,04), Beam-U aber 1,10-1,35 x M (E* 0/3).
- Mit Strafe (X5/XM5): U 0,84-0,94 x M auf 36 Prompts, alle Intervalle schließen 0,9 ein. Beleg 0,61-0,85 x M, TP1 0,67-0,75 x M (S 0/3).
- Übergang und Mitte wirken auf U gleich (U_X5/U_XM5 1,00/1,02/0,89). Was zählt, ist die Menge der Strafe, nicht ihr Ort.

Damit liegt auch diese Reihe auf der Tauschlinie von λ, Anteil, Gegengewicht und seltenen Token. Die DITTO-Linie auf künstlichen Wiederholungsdaten ist ausgeschöpft: jede Variante, die die Ausgabe unter M drückt, kostet den Beleg im selben Maß.
Weiter geht es nur mit einem anderen Angriffspunkt: Unlikelihood auf den EIGENEN Beam-Fortsetzungen des Modells (Welleck et al. 2019), Feinabstimmung ab M, nur Wiederholungen innerhalb der Fortsetzung bestraft (snai/ditto-eigen).
  Offen: - Warum X0 in der Beam-Ausgabe über M liegt, obwohl es beim Lesen gleich kopiert (zusätzliche Epoche auf mix_t?), ist ungeklärt.
- Der erste Reserve-Lauf war ungültig (relative Pfade). Die Auswertung prüft jetzt rc und Fehler je Beam-Ausgabe (boot_mas.py 84d6d29b), beam12r.sh leert beam.err (44b9109d).
- Nur ein Basismodell, ein Datensatz, λ 0,5, 1 Epoche.
  Datei: rechner-a:~/snai_pruef/ditto2/ERGEBNIS_maske.md
Chronik:
  2026-10-26 08:54 angelegt
  2026-10-26 08:54 Rezept r427
  2026-10-26 08:54 Status geplant -> laeuft (Rezept r427)
  2026-10-26 11:32 Messwerte m5795-m5819
  2026-10-26 11:33 Ergebnis e375: verfehlt
  2026-10-26 11:33 Status laeuft -> ausgewertet (Ergebnis e375)
```
