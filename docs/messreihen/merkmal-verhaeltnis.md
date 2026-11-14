# snai/merkmal-verhaeltnis

```text
snai/merkmal-verhaeltnis - ausgewertet, begonnen 2026-10-17, angelegt 2026-10-21, zuletzt 2026-10-21 14:34
Frage: Schrumpfen die tokeneigenen Embedding-Anteile gegenueber c* genau dort, wo die Formfehler entstehen (Groessenverhaeltnis als Erklaerung)?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/verhaeltnis/kriterien_verhaeltnis.txt, Kopf '2026-10-17, VOR der Messung' (Messung ~09:19)):
  R_E = Median_r ||E_r ohne c*|| / |E_r,c*|; R_g = dasselbe mit dem Gain der finalen RMSNorm; je auch nur Feldzeilen. Je Groesse: GESTUETZT bei vollstaendiger Trennung (jeder FEHLER-Stand kleineres R als jeder GESUND-Stand, AUC 1); NICHT GESTUETZT bei AUC < 0,75; dazwischen 'trennt teilweise', kein Urteil. Rot-Probe: c* x3 in s1_s4 -> R faellt auf 1/3. 22 Staende ohne Training: Originale gross_gross_s{1,2,3}_s4..s7, SPAET-Arme s{1,2,3}_s5..s7, wd0_s1_s5; FEHLER (F >= 15 %) 6, GESUND (F < 5 %) 13, ZWISCHEN (SPAET s3, 8-14 %) 3
Baut auf: snai/merkmal-spaet
Darauf baut: snai/merkmal-totzeilen
Rezepte:
  r105 [2026-10-21] python3 ~/snai_pruef/merkmal/verhaeltnis/verhaeltnis.py <ckpt> [--rot] (je Stand)
      quelltext: verhaeltnis.py c4dc8b9a
      parameter: 22 Staende, c* je Stand haeufigste Argmax-Spalte
      seed: -
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/verhaeltnis/mess.jsonl, auswertung.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/verhaeltnis/auswertung.txt (abgelesen 2026-10-21)
  m1023 AUC R_E | 0,923 | alle Staende Saaten 1-3 |  | 19
  m1024 AUC R_g | 0,833 | alle Staende Saaten 1-3 |  | 19
  m1025 AUC R_E Feldzeilen | 0,859 | alle Staende Saaten 1-3 |  | 19
  m1026 AUC R_g Feldzeilen | 0,769 | alle Staende Saaten 1-3 |  | 19
  m1027 R_E / R_g bei F 28,4 % | 1,047 / 0,270 | orig s1_s5 | 1 | 1
  m1028 R_E / R_g bei F 0,6 % | 1,029 / 0,235 | SPAET s1_s5 | 1 | 1
  m1029 R_g bei F 1,0 % | 0,164 | SPAET s1_s7 | 1 | 1
  m1030 Rot-Probe c* x3: R_E | 2,0621 -> 0,6874 | s1_s4 | 1 | 1
Ergebnis e99 [2026-10-21 14:34]: keine_aussage
  Fazit: Keine Groesse trennt vollstaendig, keine liegt unter 0,75: 'trennt teilweise', kein Urteil. Das nahezu gepaarte Paar orig s1_s5 gegen SPAET s1_s5 (gleiches Verhaeltnis, 28,4 gegen 0,6 % Formfehler) zeigt aber, dass die Groesse von c* gegenueber dem Rest den Fehler nicht erklaert; die Teiltrennung kommt aus der gemeinsamen Laufzeit. Die Deutung ('tokeneigene Anteile schrumpfen gegenueber c*') ist damit als Erklaerung erledigt; als naechstes wurde der Inhalt von c* geprueft (snai/merkmal-biasalle).
  Offen: Abhaengige Staende (dieselben Laeufe zu mehreren Zeitpunkten).
  Datei: rechner-a:~/snai_pruef/merkmal/verhaeltnis/kriterien_verhaeltnis.txt
Chronik:
  2026-10-21 14:33 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/verhaeltnis/kriterien_verhaeltnis.txt, Kopf '2026-10-17, VOR der Messung' (Messung ~09:19))
  2026-10-21 14:33 Rezept r105
  2026-10-21 14:33 Status geplant -> laeuft (Rezept r105)
  2026-10-21 14:34 Messwerte m1023-m1030
  2026-10-21 14:34 Ergebnis e99: keine_aussage
  2026-10-21 14:34 Status laeuft -> ausgewertet (Ergebnis e99)
```
