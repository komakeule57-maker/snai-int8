# snai/reichweite-v3

```text
snai/reichweite-v3 - ausgewertet, angelegt 2026-10-21, zuletzt 2026-10-21 14:15
Frage: Baut Kopiermaterial mit weiten Wiederholungen (GLEICH, Dichte konstant über d 16..1012) die Nähe-Vorliebe des Kopierens beim Knirps ab, gegenüber PROFIL (Dichte ~1/d wie das Material von prod512b)? Hintergrund der Trainingsfenster: Zufallswörter.
Kriterium (nachgetragen, Beleg: Nachgetragen am 2026-10-21; das Messbuch gibt es erst seit heute. Kriterium aus v3/kriterien.txt, geschrieben am 2026-10-20 vor dem ersten Start. Neustart mit dem prod512b-Rezept am 2026-10-20 um 22:12, die geänderte Abbruchregel steht als Nachtrag in derselben Datei, ebenfalls vor dem Neustart geschrieben.):
  Sonde mess_reich.php (echter Vorwärtspfad, 120 Fenster, Saat 20261020): r(d) = Rang-0-Anteil auf den Kopie-Token 1..11 bei d in {32, 96, 200, 320, 560, 796}. R_LL = r(796)/r(96), gelesen am letzten Segment. Ein Lauf zählt nur, wenn r(96) >= 0,5 am Budget-Ende; es braucht mindestens 2 Saaten, in denen beide Arme gelernt haben. HEBEL WIRKT: je Saat R_LL(GLEICH) >= 0,5 UND R_LL(PROFIL) <= 0,25 UND Differenz >= 0,25. KEIN HEBEL: je Saat R_LL(GLEICH) <= 0,25. PROBLEM FEHLT: je Saat R_LL(PROFIL) >= 0,5. Sonst saatabhängig / kein Urteil. Rot-Probe: fremde Quelle bei r(96) >= 0,5, muss r(96) < 0,1 x ungestört liefern. Abbruch nur bei technischen Fehlern (Nachtrag vom Neustart 2026-10-20 22:00).
Plan: rechner-a:~/snai_pruef/reichweite/v3/kriterien.txt
Darauf baut: snai/reichweite-v4, snai/kopier-torch-v4
Rezepte:
  r4 [2026-10-21] cd ~/snai_pruef/reichweite/v3 && for S in 1 2 3; do for A in profil gleich; do setsid nohup ./lauf_v3.sh $A $S 12 2000 & done; done
      quelltext: lauf_v3.sh (Rezept-Patch vom 2026-10-20 ~22:00, Rezeptzeilen-Prüfung je Segment), korpus_abstand.php, mess_reich.php; Projektkopie v3/proj = Baum 3e4904f + Wortweise-Patch, libcortex.so e281ce8d (Lade-Wächter aus)
      parameter: 128/2/2, ffn 512, ctx 1024, wort4096 (Kunstwörter); V7 gebunden, SNAI_INT8_FULL=1, SR mv, LR 0,0001, Warmup 500, Cosinus bis adam_t 24000, Boden 0,1, WD 0,1, Revival aus; 12 Segmente à 2000 Fenster, k 10, m 12, d 16..1012; OMP 2
      seed: Genesis init_base Saat 4710+s (gen_s1..3, für beide Arme geteilt); Korpus-Saat 1000*s+Segment; Sonde 20261020
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/reichweite/v3/log (Laufprotokolle *_s?.log, Sonde *.mess.jsonl, Training *_seg*.train.log); Checkpoints v3/proj/factory/checkpoints
      notiz: Neustart am 2026-10-20 um 22:12. Der erste Durchgang (LR 0,001 konstant, halbes int8, ungebunden) wurde verworfen, die Dateien liegen in v3/trash/lauf1.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/reichweite/v3/log/*_s?.log und *_seg*.train.log, Stand 2026-10-21 10:36 (Kopie-Loss 05:25); Start leer = alle drei Saaten
  m50 r(d) alle d, Segmente 0-10 | 0,000-0,001 | alle 6 Läufe |  | 5280 Ziele je d
  m51 qk-Anteil Gradient, ab t2000 bis t22010 | 0,00 % | alle 6 Läufe |  | 6
  m52 vo-Anteil Gradient, t2000 -> t22010 | 17 % -> 2,6-2,8 % | alle 6 Läufe |  | 6
  m53 Loss auf Kopie-Token (Sonde) | 8,32-8,33 (ln 4096 = 8,318) | alle 6 Läufe |  | 6
  Quelle: rechner-a:~/snai_pruef/reichweite/v3/log/<arm>_s<saat>.mess.jsonl (Segment 11) und <arm>_s<saat>.log; Budget-Ende adam_t 24.011
  m456 r(d) alle d, Segment 11 | 0,0004 (d32 0,0004 d96 0,0004 d200 0,0002) | profil | 1 | 5280
  m457 r(d) alle d, Segment 11 | 0,0002 | profil | 2 | 5280
  m458 r(d) alle d, Segment 11 | 0,0002 | profil | 3 | 5280
  m459 r(d) alle d, Segment 11 | 0,0004 | gleich | 1 | 5280
  m460 r(d) alle d, Segment 11 | 0,0002 | gleich | 2 | 5280
  m461 r(d) alle d, Segment 11 | 0,0002-0,0004 | gleich | 3 | 5280
  m462 Loss Kopie-Token d32/d96, Segment 11 | 8,317-8,318 (ln 4087 = 8,3155) | alle | 1-3 | 5280
  m463 Trainings-Loss RECENT_LOSS Segment 11 | 8,3175 / 8,3172 / 8,3164 | profil | 1/2/3
  m464 Trainings-Loss RECENT_LOSS Segment 11 | 8,3161 / 8,3165 / 8,3160 | gleich | 1/2/3
  m465 Gradientanteil qk / vo Segmentende 11 | 0,00 % / 2,6-3,3 % | alle | 1-3
  m466 Fehlerkanal NaN/Fatal/NET2NET-GUARD, 72 Trainingslogs | 0 | alle | 1-3
Ergebnis e46 [2026-10-21 14:15]: keine_aussage
  Fazit: Die Frage GLEICH gegen PROFIL bleibt unbeantwortet. Kein einziger der sechs Läufe hat überhaupt kopieren gelernt: Gelernt-Bedingung r(96) >= 0,5 nirgends, r auf Zufallsniveau 1/4087, Loss = ln 4087. Damit fällt nach der Vorab-Regel jede Saat weg. Wortlaut: „nicht gelernt in 24.000 Fenstern bei 0,0001 mit Cosinus, auf Zufallshintergrund (Knirps 128/2/2, ctx 1024, int8 voll)“. Über den Hebel sagt das nichts; es sagt, dass dieser Aufbau die Vorfrage – lernt der Knirps hier überhaupt Kopieren über lange Abstände – schon verneint. Der Q/K-Gradient war ab t2000 tot (Frühwarnregel hätte nach Segment 1 den Abbruch erlaubt). Weitermachen mit demselben Aufbau lohnt nicht; die Hebelfrage braucht erst einen Aufbau, in dem PROFIL lernt (Versuch 4 läuft dafür).
  Offen: Warum nichts gelernt wird, ist nicht isoliert. Deutung, nicht gemessen: Zufallshintergrund bietet außer Kopieren nichts Vorhersagbares, der Gradient geht ins Embedding (93 %), die Attention bekommt keinen Zug. Isolierende Eingriffe: derselbe Aufbau mit Geschichten-Hintergrund als einzigem Stellrad (Versuch 4 ändert vier Größen zugleich) oder Kontextleiter ctx 64 -> 1024 mit diesem Rezept. Die Sonde ist in v3 nie rot gesehen worden (Rot-Probe nur bei r(96) >= 0,5); für „nicht gelernt“ trägt der Loss unabhängig.
  Datei: rechner-a:~/snai_pruef/reichweite/v3/kriterien.txt
Abgeloest und ausgeblendet: 4 messwert - voll=True zeigt sie.
Chronik:
  2026-10-21 10:44 angelegt (Nachtrag: Nachgetragen am 2026-10-21; das Messbuch gibt es erst seit heute. Kriterium aus v3/kriterien.txt, geschrieben am 2026-10-20 vor dem ersten Start. Neustart mit dem prod512b-Rezept am 2026-10-20 um 22:12, die geänderte Abbruchregel steht als Nachtrag in derselben Datei, ebenfalls vor dem Neustart geschrieben.)
  2026-10-21 10:45 Rezept r4
  2026-10-21 10:45 Status geplant -> laeuft (Rezept r4)
  2026-10-21 10:45 Messwerte m42-m45
  2026-10-21 10:49 Messwerte m50-m53, loesen m42-m45 ab
  2026-10-21 14:14 Messwerte m456-m466
  2026-10-21 14:15 Ergebnis e46: keine_aussage
  2026-10-21 14:15 Status laeuft -> ausgewertet (Ergebnis e46)
```
