# snai/kopier-revival

```text
snai/kopier-revival - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 11:25
Frage: Zerstört das alte Neuron-Revival (z < -3,5, feste Skala ±0,02, Stand vor der Reparatur vom 2026-10-12) gelerntes Kopieren beim Knirps 16/2/8?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  Ungepaart: Ursache, wenn ohne Revival keine Saat nach Erreichen von 50 % wieder darunter fällt. Gepaart (gleicher Laufname, gleiche Genesis, Revival aus): (1) Stände der Segmente 0..4 bytegleich zum Lauf mit Revival (dort erster Eingriff am Ende von Segment 5); (2) Ursache, wenn ohne Revival in den Segmenten 8..23 nie unter 50 %.
Baut auf: snai/kopier-knirps-leiter
Darauf baut: snai/kopier-knirps-gitter, snai/knirps-revival-paar-32
Rezepte:
  r38 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben; Arme ohne Revival in knirps/proj_r0, Nachlauf knirps/nachlauf_n.sh)
      parameter: Knirps 16/2/8 (Breite 16, 2 Köpfe, 2 Schichten), wort256, `var`, LR 0,001, 24 x 5.000 Fenster, drei Genesis-Saaten. Arm mit altem Revival (z < -3,5, Skala ±0,02) gegen Revival aus (PROJ=proj_r0, sonst gleich). Gepaart: Lauf g_d16h2_s3 unter demselben Namen mit derselben Genesis in proj_r0 wiederholt (Training bei gleichem Laufnamen deterministisch)
      rechner: rechner-a
Messwerte (Groesse | Wert | Arm | Start | n):
  m308 Einbruch R0 mit Revival | Segment 17: 77,6 -> 39,4 %, Ende 14,2 % | mit Revival | 1
  m309 Einbruch R0 mit Revival | Segment 14: 88,2 -> 41,3 %, Ende 23,3 % | mit Revival | 2
  m310 Einbruch R0 mit Revival | Segment 8: 84,5 -> 37,5 %, Ende 27,1 % | mit Revival | 3
  m311 R0 ohne Revival | 79-90 % über alle 24 Segmente, Ende 87,4 % | ohne Revival | 2
  m312 R0 ohne Revival | bis Segment 19: 86-91 % (lief noch) | ohne Revival | 1
  m313 R0 ohne Revival | bis Segment 21: 83-91 % (lief noch) | ohne Revival | 3
  m314 Gepaart: Stände Segmente 0..4 | bytegleich, ab Segment 5 abweichend | g_d16h2_s3 | 3
  m315 Gepaart: R0 Segmente 8..23 | 82,5-88,5 %, Ende 82,6 % (mit Revival 23,2-41,8 %, Ende 27,1 %) | ohne gegen mit Revival | 3
  m316 Revival-Eingriffe im Audit-Gitter | in 22 von 24 Läufen | altes Gitter |  | 24
Ergebnis e34 [2026-10-21 11:25]: erfuellt
  Fazit: Das alte Neuron-Revival ist als Ursache des Einbruchs belegt, für die Zelle 16/2/8: mit Revival brechen 3 von 3 Saaten ein, ohne 0 von 3; gepaart bis Segment 4 bytegleich, danach ohne Revival stabil über 82 %. Folgen: das alte Gitter mit Revival (Eingriff in 22 von 24 Läufen) entscheidet nichts über „nicht gelernt“ und wurde ohne Revival wiederholt (snai/kopier-knirps-gitter); die Entwarnung „Revival ist nicht schuld“ aus der Leiter galt nur für 60.000 Fenster bei LR 0,0001. Kopierversuche laufen seitdem mit Revival aus. Bei großen Modellen (Drohne E: 0,04 % der Zeilen je Segment) ist ein Schaden nicht belegt.
  Offen: Welche überschriebene Zeile oder Matrix den Einbruch auslöst; Gradientennorm wächst in denselben Läufen von 4 auf 60 (Verbindung nicht gemessen). Vorbehalt Lade-Wächter: Messungen über den alten Ladepfad können „Einbrüche“ vortäuschen; ob der Wächter in diesen Läufen mitwirkte, steht nicht im Eintrag (nicht neu gemessen).
Chronik:
  2026-10-21 11:23 angelegt (Nachtrag: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:24 Rezept r38
  2026-10-21 11:24 Status geplant -> laeuft (Rezept r38)
  2026-10-21 11:24 Messwerte m308-m316
  2026-10-21 11:25 Ergebnis e34: erfuellt
  2026-10-21 11:25 Status laeuft -> ausgewertet (Ergebnis e34)
```
