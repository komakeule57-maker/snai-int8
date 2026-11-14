# snai/reichweite-v4

```text
snai/reichweite-v4 - ausgewertet, angelegt 2026-10-21, zuletzt 2026-10-22 04:09
Frage: Wie Versuch 3 (snai/reichweite-v3), aber der Hintergrund der Trainingsfenster sind Nano-Geschichten statt Zufallswörtern. Zusätzlich beschreibend: Setzt auf natürlichem Hintergrund überhaupt Kopieren ein?
Kriterium (nachgetragen, Beleg: Nachgetragen am 2026-10-21 um ~10:50; das Messbuch gibt es erst seit heute. Das Kriterium stammt aus v4/kriterien.txt und wurde am 2026-10-21 zwischen 08:00 und 08:50 vor dem Start geschrieben (Start 08:50:35).):
  Wörtlich wie snai/reichweite-v3 (R_LL, Gelernt-Bedingung r(96) >= 0,5, HEBEL WIRKT / KEIN HEBEL / PROBLEM FEHLT / saatabhängig, Rot-Probe). Sonde mit Held-out-Geschichten als Hintergrund (6.335 Geschichten). Zusatz vor dem Start: Die Rot-Probe liefert bei allen d den Boden r_rot(d). Liegt r_rot(96) > 0,05, wird R_LL zusätzlich bodenbereinigt berichtet. Das Urteil bleibt beim Wortlaut, bei Abweichung stehen beide Lesarten nebeneinander. Beschreibend: erstes Segment mit r(32) >= 0,05 bzw. r(96) >= 0,5; Gradientenanteile qk/vo je Segment. Abbruch nur bei technischen Fehlern.
Plan: rechner-b:~/snai_pruef/reichweite/v4/kriterien.txt
Baut auf: snai/reichweite-v3
Darauf baut: snai/kopier-torch-v4
Rezepte:
  r5 [2026-10-21] cd ~/snai_pruef/reichweite/v4 && for S in 1 2 3; do for A in profil gleich; do setsid nohup nice -n 10 ./lauf_v4.sh $A $S 12 2000 > log/nohup_${A}_s$S.out 2>&1 < /dev/null & done; done
      quelltext: lauf_v4.sh (diff zu lauf_v3.sh: Pfade, Vokabular, Material-Argument, Held-out-Argument, Zeile mit den Gradientenanteilen); korpus_abstand.php und mess_reich.php aus v3 per patch_v4.py (ein Stellrad, ohne Argument bytegleich bzw. kennzahlgleich zu v3); material.py; libcortex.so e281ce8d
      parameter: wie snai/reichweite-v3; Vokabular geschichten4096 (md5 eb9af782, Vorrat b37ef90c); Material v4/material/seg0..11 (je ~2,068 Mio. Wörter, kein Text doppelt), Held-out 6.335 Geschichten; nice 15 (Evo-Reihe hat Vorrang)
      seed: wie v3 (Genesis 4710+s mit dem neuen Vokabular, Korpus 1000*s+Segment, Sonde 20261020)
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/reichweite/v4/log; Rauchtest in v4/trash/rauch2
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/reichweite/v4/log/*_s?.log (Zeilen "Messung Segment 0" und "Gradientenanteile am Segmentende"), gemessen 2026-10-21 10:15-10:26; Start leer = alle drei Saaten
  m46 r(d) alle d, Segment 0 | 0,000 | alle 6 Läufe |  | 5280 Ziele je d
  m47 qk-Anteil Gradient, Ende Segment 0 | 1,46-1,99 % | alle 6 Läufe |  | 6
  m48 vo-Anteil Gradient, Ende Segment 0 | 50,0-56,9 % | alle 6 Läufe |  | 6
  m49 RECENT_LOSS Training, Ende Segment 0 | 4,76-4,84 | alle 6 Läufe |  | 6
  Quelle: rechner-b:~/snai_pruef/reichweite/v4/log/<arm>_s<saat>.log (Segmente 1 und 2)
  m467 r(d) alle d, Segment 1 | 0,000-0,001 | alle | 1-3 | 5280
  m468 Trainings-Loss Segment 1 | 4,486-4,552 | alle | 1-3
  m469 Gradientanteil qk / vo Segmentende 1 | 1,67-2,23 % / 46,1-49,5 % | alle | 1-3
  m470 r(d) alle d, Segment 2 | 0,000-0,001 | alle | 1-3 | 5280
  m471 Trainings-Loss Segment 2 | 4,390-4,433 | alle | 1-3
  m472 Gradientanteil qk / vo Segmentende 2 | 1,81-2,25 % / 44,7-47,3 % | alle | 1-3
  m473 Fehlerkanal Warnzeilen Segmente 0-2 | 0 | alle | 1-3
  Quelle: rechner-b:~/snai_pruef/reichweite/v4/log/<arm>_s<saat>.log (Segmente 3-8); ab Segment 5 ~38 min je Segment, weil die Evo-Reihe glr um 16:34 endete
  m1414 r(d) alle d, Segmente 3-8 | 0,000-0,001 | alle | 1-3 | 5280
  m1415 Trainings-Loss Segment 3 | 4,296-4,374 | alle | 1-3
  m1416 Trainings-Loss Segment 8 | 4,158-4,216 | alle | 1-3
  m1417 Gradientanteil qk / vo Segmentende 5-8 | 1,87-2,37 % / 43,1-45,4 % | alle | 1-3
  m1418 Fehlerkanal Warnzeilen Segmente 3-8 | 0 | alle | 1-3
  Quelle: rechner-b:~/snai_pruef/reichweite/v4/log/<arm>_s<saat>.mess.jsonl (Segment 11) und .log; Budget-Ende 2026-10-21 21:12-21:15
  m4246 r(d) alle d, Segment 11 | 0,0006 | profil | 1 | 5280
  m4247 r(d) alle d, Segment 11 | 0,0006 | profil | 2 | 5280
  m4248 r(d) alle d, Segment 11 | 0,0006 | profil | 3 | 5280
  m4249 r(d) alle d, Segment 11 | 0,0006 | gleich | 1 | 5280
  m4250 r(d) alle d, Segment 11 | 0,0006 | gleich | 2 | 5280
  m4251 r(d) alle d, Segment 11 | 0,0004 | gleich | 3 | 5280
  m4252 Loss Kopie-Token alle d, Segment 11 | 8,41-8,46 (kein Abstandseffekt) | alle | 1-3 | 5280
  m4253 Trainings-Loss Segment 11 | 4,168 / 4,153 / 4,180 | profil | 1/2/3
  m4254 Trainings-Loss Segment 11 | 4,175 / 4,154 / 4,176 | gleich | 1/2/3
  m4255 Gradientanteil qk / vo Segmentende 11 | 1,75-2,04 % / 42,5-43,7 % | alle | 1-3
  m4256 Fehlerkanal NaN/Fatal/NET2NET-GUARD, 72 Trainingslogs; Warnzeilen | 0; 0 | alle | 1-3
Ergebnis e310 [2026-10-22 04:09]: keine_aussage
  Fazit: Auch mit Geschichten-Hintergrund lernt kein Lauf kopieren (0/6, r auf Zufallsniveau, Kopie-Token-Loss bei allen d gleich). Die Hebelfrage GLEICH gegen PROFIL bleibt damit unbeantwortet; Wortlaut „nicht gelernt in 24.000 Fenstern bei 0,0001 mit Cosinus, auf Geschichten-Hintergrund“. Was daraus folgt: Der Hintergrund ist in diesem Aufbau NICHT das, was über Kopieren entscheidet. Versuch 4 widerlegt die Hoffnung aus Versuch 3, dass ein lebender Q/K-Gradient reicht – die Attention bekam die ganze Zeit ~2 % Gradient (Versuch 3: 0,00 %) und lernte trotzdem nur die Geschichten (Loss 4,8 → 4,16). Die Frühwarnregel ist damit notwendig, aber nicht hinreichend. Weiter am Hintergrund zu drehen lohnt nicht; der nächste Schritt muss Dichte/Länge des Kopiersignals isolieren (Kontextleiter ctx 64 → 1024).
  Offen: Warum nicht gelernt wird, ist nicht isoliert. Deutung, nicht gemessen: 10 Ereignisse je 1.024-Fenster mit d bis 1.012 sind ein zu dünnes/weites Signal für dieses Budget; snai/kopier-mini-lr-reihe lernte bei ctx 64 mit dichtem Signal. Isolierend: Kontextleiter mit gleicher Kopierdichte je Token, oder längeres Budget. Der Vergleich Versuch 3 gegen 4 ändert vier Größen gemeinsam (Hintergrund, Vokabular, Sonden-Hintergrund, Rechner). Sonde in v4 nie rot gesehen; „nicht gelernt“ trägt der Loss. Die Prämisse „Nano-Geschichten-Modell lernte schnell kopieren“ war nie mit einer Kopier-Sonde gemessen.
  Datei: rechner-a:~/snai_pruef/reichweite/v4/kriterien.txt
Abgeloest und ausgeblendet: 4 messwert - voll=True zeigt sie.
Chronik (juengste 8 von 10, voll=True zeigt alle):
  2026-10-21 10:45 Status geplant -> laeuft (Rezept r5)
  2026-10-21 10:45 Messwerte m38-m41
  2026-10-21 10:49 Messwerte m46-m49, loesen m38-m41 ab
  2026-10-21 14:15 Messwerte m467-m473
  2026-10-21 19:17 Messwerte m1414-m1418
  2026-10-22 04:09 Ergebnis e310: keine_aussage
  2026-10-22 04:09 Status laeuft -> ausgewertet (Ergebnis e310)
  2026-10-22 04:09 Messwerte m4246-m4256
```
