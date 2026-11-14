# snai/prod512b-sampling

```text
snai/prod512b-sampling - ausgewertet, angelegt 2026-10-23, zuletzt 2026-10-23 18:39
Frage: Liegen die wortgleichen Absatz-Wiederholungen der Leseprobe von prod512b (ROH, Beam 3) an der Beam-Suche oder am Modell? Vergleich Beam 3 gegen Sampling T 0,25 (Auslieferungsweg) und T 0,8 am selben Checkpoint, s3 und s4 getrennt.
Kriterium (festgelegt 2026-10-23 12:00, vor dem ersten Messwert):
  Maß W (wiederhol.py 63573cff) = Anteil der Wörter in einer 8-Wort-Folge, die im selben Text vorher schon vorkam (Rot-Probe: frei 0,000 / Absatz dreifach 0,667 / Wortschleife 0,951). Arme: B = Beam 3 (vorhandene ROH-Referenz, 1 Antwort je Prompt; s3: 0,741/0,399/0,670/0,344, Mittel 0,539), S25 = Sampling T 0,25, S80 = T 0,8; sonst gleich (min_p 0,05, Strafe 1,15/64 Token, max 256 Token); je Sampling-Arm Saat 1-5 x 4 Prompts. Antworten < 40 Wörter = früher Stopp, gezählt, nicht in W; Arm gültig nur mit >= 14/20 gültigen Antworten und je Prompt >= 3 gültigen Saaten, sonst keine Aussage. Je Prompt Median W über die Saaten. weniger Wiederholung = Mittel über 4 Prompts <= 0,9 x Mittel B UND in >= 3/4 Prompts kleiner als B; mehr spiegelbildlich; Gleichstand = Mittel innerhalb ±10 %; sonst uneinig. Bewertung vorab: S80 weniger + S25 Gleichstand -> Wiederholung hängt an der fast deterministischen Auswahl; alle Gleichstand/mehr -> das Modell wiederholt auch beim Ziehen. Reichweite: 4 Prompts, je ein Checkpoint. Volltext rechner-a:~/snai_pruef/merkmal/prodtest/sampling/kriterien.txt (fb574de2, mit Prüfer).
Plan: rechner-a:~/snai_pruef/merkmal/prodtest/sampling/kriterien.txt
Baut auf: snai/prod512b-lauf
Darauf baut: snai/prod512b-beamalpha, snai/ditto-knirps
Rezepte:
  r389 [2026-10-23] cd ~/snai_pruef/merkmal/prodtest/sampling && setsid nohup bash lauf.sh <segment> > lauf_s<segment>.out 2>&1 &   (je Antwort: SNAI_SAAT=<1-5> SNAI_TEMP=<0.25|0.8> SNAI_ROHPROMPT=1 SNAI_FORCE_CPU=1 OMP_NUM_THREADS=2 nice -n 19 php snai_inference_saat.php factory/checkpoints/prod512b_s<N>.snai "<Prompt>" 1, 3 parallel; Auswertung wiederhol.py je Antwort)
      quelltext: proj_sr: snai_inference.php 8ba48a06 -> Kopie snai_inference_saat.php a0f57628 (mt_srand(SNAI_SAAT), SNAI_TEMP, per assert), libcortex.so 318b2655 (tg1-Stand), Vokabular f020d0ca; sampling/lauf.sh fa970f3a, wiederhol.py 63573cff, kriterien.txt fb574de2
      parameter: ROH-Prompt, 4 Prompts (Wohnhaus/Hauptstadt/1928/Film), max 256 Token, min_p 0,05, repetition_penalty 1,15 über 64 Token, T 0,25 und 0,8; B = Beam 3 aus inferenz/referenz_roh_prod512b_sN.txt
      seed: Saat 1-5 (mt_srand); Reproduzierbarkeit: Saat 1 zweimal f894164c, Saat 2 c14e2c54
      rechner: rechner-a, nice 19, 3 parallel, OMP 2 (neben laufenden Evo-Reihen)
      logs: rechner-a:~/snai_pruef/merkmal/prodtest/sampling/s<N>/ (T<temp>_s<saat>_p<i>.txt/.err, rc.log, md5.txt)
  r395 [2026-10-23] s4: bash ~/snai_pruef/merkmal/prodtest/sampling/lauf_p1.sh 4; danach python3 sampling/auswert.py 4
      quelltext: lauf_p1.sh md5 6d0ae9e2 = lauf.sh (fa970f3a) mit nur einer Änderung: xargs -P 1 statt -P 3 (OOM bei vier parallelen prod512b-Inferenzen); snai_inference_saat.php a0f57628
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/prodtest/sampling/s4/
      notiz: Abweichung vom Rezept r389 nur in der Parallelität; jeder Einzellauf ist gesät (SNAI_SAAT) und mit OMP 2, deshalb wird kein Einfluss auf die Ausgabe erwartet. Gestartet aus kette_s4.sh.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/prodtest/sampling/ergebnis_s3.txt (auswert.py auf s3/, Checkpoint prod512b_s3 md5 deee2ea3), B aus inferenz/referenz_roh_prod512b_s3.txt
  m4697 W Beam 3 je Prompt (Wohnhaus/Hauptstadt/1928/Film) s3 | 0,741 / 0,399 / 0,670 / 0,344, Mittel 0,539 | B | - | 4
  m4698 gültige Antworten (>= 40 Wörter) s3 | 13/20 | S25 | 1-5 | 20
  m4699 frühe Stopps (< 40 Wörter) s3 | 7/20, Film 5/5 | S25 | 1-5 | 20
  m4700 Länge Wörter s3 | 5-196, Median 65 | S25 | 1-5 | 20
  m4701 W gültige Antworten s3 | Wohnhaus 0/0,074/0,662; Hauptstadt 0/0,574/0/0/0,285; 1928 0/0,094/0/0/0,145 | S25 | 1-5 | 13
  m4702 gültige Antworten (>= 40 Wörter) s3 | 7/20 | S80 | 1-5 | 20
  m4703 frühe Stopps (< 40 Wörter) s3 | 13/20 | S80 | 1-5 | 20
  m4704 Länge Wörter s3 | 1-170, Median 17 | S80 | 1-5 | 20
  m4705 W gültige Antworten s3 | 0,000 in 7/7 | S80 | 1-5 | 7
  m4706 Urteil nach Regel s3 | keine Aussage (frühe Stopps) | S25 und S80 | 1-5 | 20
  m4707 Fehlerkanal .err (VETO/NaN/Fatal) s3 | 0/40 | S25+S80 | 1-5 | 40
  Quelle: rechner-a:~/snai_pruef/merkmal/prodtest/sampling/ergebnis_s4.txt (auswert.py 4; lauf_p1.sh, 40/40 rc 0, Fehlerkanal 0/40, md5 751d92d9)
  m4834 B W je Prompt (ROH Beam 3) | 0,326 / 0,393 / 0,421 / 0,590, Mittel 0,432 | B s4 |  | 4
  m4835 S25 gültig / frühe Stopps | 15/20 / 5, Film nur 2 gültige Saaten (Schwelle 3) | S25 s4 | 1-5 | 20
  m4836 S25 W je Saat gültig | Wohnhaus 0,20/0,20/0,00; Hauptstadt 0,00/0,05/0,08/0,00/0,22; 1928 0,00/0,93/0,12/0,06/0,13; Film 0,00/0,40 | S25 s4 | 1-5 | 15
  m4837 S25 Urteil nach Regel | keine Aussage (frühe Stopps) | S25 s4 | 1-5 | 20
  m4838 S80 gültig / frühe Stopps | 15/20 / 5, je Prompt 3/4/5/3 | S80 s4 | 1-5 | 20
  m4839 S80 Median W je Prompt | 0,00 / 0,00 / 0,00 / 0,00 = 0,00 x B, kleiner in 4/4 (einziger Ausreißer 0,764 Film) | S80 s4 | 1-5 | 15
  m4840 S80 Urteil nach Regel | weniger Wiederholung | S80 s4 | 1-5 | 20
  Quelle: rechner-a:~/snai_pruef/merkmal/prodtest/sampling/ergebnis_s50_s4.txt (auswert_s50.py 4; lauf_t.sh 4 0.5, md5 3d2f8c03, 20/20 rc 0, Fehlerkanal 0/20; Kriterium Zusatz S50 in kriterien.txt f48a20b6, vor dem Lauf, mit Prüfer)
  m4841 S50 gültig | 11/20 (je Prompt 3/2/5/1) | S50 s4 | 1-5 | 20
  m4842 S50 Urteil nach Regel | keine Aussage (frühe Stopps) | S50 s4 | 1-5 | 20
  m4843 E-Mittel erfundene Wörter (erfunden.py 1f4d5af7) | B 0,079 / S25 0,074 / S50 0,066 / S80 0,151 | s4 alle Arme | 1-5 | 4 Prompts
  m4844 S50 W der gültigen Antworten | 0,00-0,07 (10 von 11 unter 0,07) | S50 s4 | 1-5 | 11
  Quelle: rechner-a:~/snai_pruef/merkmal/prodtest/sampling/ergebnis_m_s4.txt (Saaten 1-5) und ergebnis_m2_s4.txt (Saaten 6-10), auswert_m.py; snai_inference_mind.php cf63177b (SNAI_MIN_TOKENS=80, Gegenprobe bytegleich/rot gesehen); 100/100 rc 0, Fehlerkanal 0; Kriterium Zusatz MINDESTLAENGE in kriterien.txt vor dem Lauf, mit Prüfer
  m4845 M25 gültig / W Mittel / W längengleich B / E-Mittel | 20/20 / 0,099 / 0,282 / 0,08928 (Band 0,08939, knapp) | M25 s4 | 1-5 | 20
  m4846 M50 gültig / W Mittel / W längengleich B / E-Mittel | 20/20 / 0,015 / 0,244 / 0,0658 | M50 s4 | 1-5 | 20
  m4847 M80 gültig / W Mittel / W längengleich B / E-Mittel | 19/20 / 0,000 / 0,312 / 0,150 | M80 s4 | 1-5 | 20
  m4848 Urteil Saaten 1-5 | M25 und M50 weniger Wiederholung ohne mehr erfundene Wörter (M25 knapp), M80 nur weniger Wiederholung | M s4 | 1-5 | 60
  m4849 M25 gültig / W Mittel / W längengleich B / E-Mittel | 20/20 / 0,127 / 0,327 / 0,0790 | M25 s4 | 6-10 | 20
  m4850 M50 gültig / W Mittel / W längengleich B / E-Mittel | 20/20 / 0,013 / 0,211 / 0,1253 | M50 s4 | 6-10 | 20
  m4851 Urteil Saaten 6-10 | M25 weniger Wiederholung ohne mehr erfundene Wörter; M50 nur weniger Wiederholung | M s4 | 6-10 | 40
  m4852 E-Mittel gepoolt 10 Saaten | M25 0,071 / M50 0,098 (Band 0,089) | M s4 | 1-10 | 40
Ergebnis e344 [2026-10-23 18:39]: erfuellt
  Fazit: Löst e343 ab. Mit gesperrtem Dokumentende (80 Token) sind alle Arme auswertbar, und die Vorab-Regel liefert eine Empfehlung: Temperatur 0,25 mit Mindestlänge. Dieser Arm hält in beiden Saatsätzen und gepoolt dreierlei: viel weniger Wiederholung als Beam (W 0,10-0,13 gegen 0,43), auch bei längengleichem Vergleich, und nicht mehr erfundene Wörter als Beam. Die Mitte 0,5 wiederholt noch weniger, erfindet aber auf frischen Saaten zu viel (E 0,125). Ihr erstes Bestehen war Saatglück. 0,8 erfindet doppelt so viel wie Beam. Für Leseproben heißt das: Der Beam-Weg erzeugt die Absatzschleifen, der ausgelieferte Sampling-Weg (0,25) ist brauchbar, sobald er nicht mehr früh abbricht. Der eigentliche Fehler des Standardwegs war das frühe Ende, nicht die Temperatur. Das Modell bleibt dasselbe (Selbstverstärkung, snai/prod512b-schleife). Die Mindestlänge umgeht das Symptom nur für Leseproben.
  Offen: Nur s4, 4 Prompts, 10 Saaten. E ist schwach: zwischen zwei 5-Saaten-Sätzen streut es bei M50 um 0,06, das Sechsfache der Bandbreite. Zusammenhang über Themensprünge ist nur gelesen, nicht gemessen. Ob 80 Token die richtige Sperre ist, ist nicht variiert. Die Mindestlänge ist nur in der Kopie snai_inference_mind.php, nicht im ausgelieferten Skript.
  Datei: rechner-a:~/snai_pruef/merkmal/prodtest/sampling/kriterien.txt
Abgeloest und ausgeblendet: 2 ergebnis - voll=True zeigt sie.
Chronik (juengste 8 von 12, voll=True zeigt alle):
  2026-10-23 14:39 Rezept r395 (s4)
  2026-10-23 18:05 Messwerte m4834-m4840
  2026-10-23 18:05 Ergebnis e342: teilweise
  2026-10-23 18:05 Status laeuft -> ausgewertet (Ergebnis e342)
  2026-10-23 18:16 Messwerte m4841-m4844
  2026-10-23 18:16 Ergebnis e343: teilweise, loest e342 ab
  2026-10-23 18:39 Messwerte m4845-m4852
  2026-10-23 18:39 Ergebnis e344: erfuellt, loest e343 ab
```
