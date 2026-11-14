# snai/prod512b-frankreich

```text
snai/prod512b-frankreich - ausgewertet, angelegt 2026-11-06, zuletzt 2026-11-12 13:09
Frage: Warum schreibt prod512b s11 auf "Die Hauptstadt von Frankreich ist" (Korsett) "Der König von Frankreich" in Schleife? A: Bevorzugt das Modell König über die Korpusanteile vor "von <Land>" hinaus? B: Hält sich die Schleife, weil König besonders ist, oder weil das Modell jeden Füller kopiert?
Kriterium (festgelegt 2026-11-06 11:43, vor dem ersten Messwert):
  Sonde sonde_fr.php (teacher forcing, echter int8-Vorwärtspfad, Lib 1eb78bc1), 6 Länder, Urteile an s11. A (T2): Rahmen Korsett+": Der", P(" N von Land") für die 8 häufigsten groß geschriebenen Korpus-Füller; OR = Odds(König-Anteil Modell)/Odds(König-Anteil Korpus); BEVORZUGT OR>=2 in >=5/6, KORPUSGEMAESS 0,5<=OR<2 in >=5/6, UNTER KORPUS OR<0,5 in >=5/6, sonst OFFEN. B (T3): Folge ": Der N von Land, der N von Land, ..." 7 Vorkommen, P(" N") an k=6; Arme König/Botschafter/Bürgermeister; KOPIE UNSPEZIFISCH alle drei >=0,5 in >=5/6; KOENIG-SPEZIFISCH König >=0,5 und beide Kontrollen <0,2 in >=5/6; sonst OFFEN. Kontrollen: Fehlerkanal ohne GRENZE/UNK/NAN/NET2NET, md5 s11 968d6d2d, Rot-Probe gesehen (s5: 0,436 -> 0,002). Volltext samt Prüfer-Nachtrag: KRITERIEN.md.
Plan: rechner-a:~/snai_pruef/frankreich/KRITERIEN.md
Baut auf: snai/prod512b-schleife
Darauf baut: snai/prod512b-frankreich-lens
Rezepte:
  r614 [2026-11-06] cd ~/snai_pruef/frankreich && python3 aufbau.py && ./lauf.sh 5 10 11 && python3 auswert.py s11.jsonl
      quelltext: sonde_fr.php 466fc902, posten.json b698fd4f (aus aufbau.py), Lib 1eb78bc1, cwd ~/snai_pruef/ref512b
      parameter: SNAI_GAIN_GUARD=0 SNAI_FORCE_CPU=1 OMP_NUM_THREADS=2, 6 Laender, 3 Arme, 7 Vorkommen, Korpus pseg00-11
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/frankreich/ (s5/s10/s11.jsonl, .err, rc.log, verworfen_lauf1/)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/frankreich/urteil_s11.txt, bericht_s5.txt, bericht_s10.txt (auswert.py)
  m9338 T2 OR König Rahmen K, Spanne 6 Laender | 10 bis 622 | s11
  m9339 T2 Laender mit OR >= 2, Rahmen K | 6/6 | s11
  m9340 T2 Laender mit OR >= 2, Rahmen N | 6/6 | s11
  m9341 T2 König Top-1 nach Der, Laender | 6/6 | s11
  m9342 T2 Laender mit OR >= 2, Rahmen K | 5/6 | s10
  m9343 T2 Laender mit OR >= 2, Rahmen K | 6/6 | s5
  m9344 T3 P_N(6) König, Spanne | 0,56 bis 0,82 | s11
  m9345 T3 P_N(6) Botschafter, Spanne | 0,80 bis 0,88 | s11
  m9346 T3 P_N(6) Bürgermeister, Spanne | 0,25 bis 0,46 | s11
  m9347 T3 Laender P_N(6) >= 0,5 König/Botschafter/Bürgermeister | 6/6 6/6 0/6 | s11
  m9348 T3 Laender P_N(6) >= 0,3 König/Botschafter/Bürgermeister | 6/6 6/6 5/6 | s11
  m9349 T4 P(Komma) nach N von Frankreich, k0 bis k6, König | 0,10 bis 0,94 | s11
  m9350 Beobachtung Top-1 nach Die Hauptstadt ist ohne Land | König 0,034 | s11
  m9504 Quelle s12 | rechner-a:~/snai_pruef/frankreich/bericht_s12.txt, sonde_fr.php 466fc902, posten b698fd4f, Lib 1eb78bc1, Stand md5 133b4cc1, s12.err 0 Grenzfehler | prod512b | s12 | 165
  m9505 T1 P(König) nach ': Der' (Korsett) | s11 0,025-0,045 und Rang 1 in 6/6; s12 nur Schweden in den Top 5 (0,012), sonst nicht in den Top 5 | König | s12 | 6
  m9506 T2 Rahmen K OR König | 73 / 43 / 914 / 25 / 3,8 / 41 (Fr/Sp/En/Sw/Po/It; s11 380 / 71 / 622 / 38 / 10 / 192), weiter 6/6 >= 2 BEVORZUGT; absolutes P(König) 15- bis 175-mal kleiner (Fr 8,95e-3 -> 5,63e-4) | König | s12 | 6
  m9507 T3 P_N(6) König | 0,21 / 0,18 / 0,36 / 0,59 / 0,38 / 0,10 (s11 0,77 / 0,65 / 0,82 / 0,82 / 0,80 / 0,56); Schwelle 0,5 1/6 (s11 6/6) | König | s12 | 6
  m9508 T3 P_N(6) Botschafter | 0,26 / 0,38 / 0,48 / 0,43 / 0,42 / 0,32 (s11 0,80-0,88) | Botschafter | s12 | 6
  m9509 T3 P_N(6) Bürgermeister | 0,12 / 0,17 / 0,16 / 0,27 / 0,27 / 0,09 (s11 0,25-0,46) | Bürgermeister | s12 | 6
  m9510 T4 P(',') nach 'von Frankreich' k0 / k6 | König 0,313 / 0,778 (s11 0,103 / 0,944); Botschafter 0,473 / 0,856 (s11 0,105 / 0,896) | Frankreich | s12 | 1
  m9511 Beobachtung beob_posten B Hauptstadt Top 1 | ' Sch' 0,029 (s11 ' König' 0,034); B Film unverändert ' Film' 0,53 | beob | s12 | 5
  Quelle: ~/snai_pruef/frankreich/bericht_s13.txt (auswert.py auf s13.jsonl; Stand prod512b_s13 md5 d9facd40; lib 1eb78bc1 sonde 466fc902 posten b698fd4f; s13.err 0 Grenzfehler), beob_s13.jsonl, ~/.cache/prod512/referenz_prod512b_s13.txt
  m9975 s13 T2 Rahmen K: Länder mit OR >= 2 | 6/6 (BEVORZUGT) | s13
  m9976 s13 T2 Rahmen K: OR Frankreich/Spanien/England/Schweden/Polen/Italien | 33,22 / 29,20 / 3809,00 / 10,02 / 2,48 / 20,82 | s13
  m9977 s13 T2 Rahmen K: P(König) je Land | 7,33e-04 / 1,36e-04 / 1,36e-04 / 5,95e-05 / 7,84e-05 / 3,54e-05 (s12: 5,63e-04 / 1,06e-04 / 8,45e-05 / 4,22e-05 / 4,06e-05 / 4,17e-05) | s13
  m9978 s13 T1: König unter Top 5 nach ': Der' | 0/6 Länder (s12 1/6, s11 6/6 auf Rang 1) | s13
  m9979 s13 T3: P_N(6) König, Spanne über 6 Länder | 0,267-0,729 (s12 0,10-0,59; s11 0,56-0,82) | s13
  m9980 s13 T3: P_N(6) Botschafter, Spanne | 0,572-0,767 (s12 0,26-0,48; s11 0,80-0,88) | s13
  m9981 s13 T3: P_N(6) Bürgermeister, Spanne | 0,189-0,571 (s12 0,09-0,27; s11 0,25-0,46) | s13
  m9982 s13 T3: Schwelle 0,5 erreicht (König/Botschafter/Bürgermeister) | 4/6, 6/6, 2/6 (s12: 1/6, 0/6, 0/6); URTEIL B OFFEN | s13
  m9983 s13 T3: P_N(6) > P_N(1) | 18/18 | s13
  m9984 s13 T4: P(',') nach 'von Frankreich', König k0 / k6 | 0,135 / 0,817 (s12 0,31 / 0,78) | s13
  m9985 s13 Beobachtung beob_posten: Top 1 B | Hauptstadt / B | Film | ' Die' 0,041 / ' Film' 0,783 (s12 ' Sch' 0,029 / ' Film' 0,528) | s13
  m9986 s13 Referenz-Inferenz Korsett: Vielfalt der vier Prompts | 0,752 / 0,828 / 0,719 / 0,611 (s12 0,629 / 0,738 / 0,833 / 0,743) | s13
  Quelle: rechner-a ~/snai_pruef/frankreich: kette_s12.sh 14 (12.11. 12:53-13:07), s14.jsonl/beob_s14.jsonl, auswert.py -> bericht_s14.txt; Sonde 466fc902, Posten b698fd4f, Lib 1eb78bc1; Stand md5 0c29a7ff; s14.err 0 Grenzfehler, Auswertung rc 0, Fehlerkanal leer. Ausführlich ERGEBNIS.md Abschnitt s14.
  m10662 s14 T1 König nach ": Der" | Rang 1 in 3/6, Rang 2 in 1/6, nicht Top 5 in 2/6 (s13 0/6 Top 5, s11 Rang 1 6/6) | prod512b | s14 | 6
  m10663 s14 T2 Rahmen K | OR >= 2 in 5/6 (Polen 1,55), BEVORZUGT (URTEIL A); OR Frankreich 325 (s13 33) | prod512b | s14 | 6
  m10664 s14 T3 P_N(6) König / Botschafter / Bürgermeister | 0,68-0,91 / 0,51-0,65 / 0,40-0,76 (s13 0,27-0,73 / 0,57-0,77 / 0,19-0,57; s11 0,56-0,82 / 0,80-0,88 / 0,25-0,46) | prod512b | s14 | 18
  m10665 s14 T3 Schwelle 0,5 König / Botschafter / Bürgermeister | 6/6, 6/6, 4/6 (s13 4/6, 6/6, 2/6); P_N(6) > P_N(1) 18/18; URTEIL B nach Wortlaut OFFEN | prod512b | s14 | 18
  m10666 s14 T4 P(",") nach "von Frankreich" k0 / k6 | 0,143 / 0,745 (s13 0,135 / 0,817) | prod512b | s14 | 1
  m10667 s14 Referenz-Inferenz Vielfalt Korsett / Roh (4 Prompts) | 0,68 0,75 0,76 0,68 / 0,62 0,68 0,50 0,58; kein "König", Korsett mit Wortverschmelzungen | prod512b | s14 | 4
Ergebnis e560 [2026-11-06 11:47]: teilweise
  Fazit: A BEVORZUGT (6/6): Am Einstieg nimmt s11 König weit über den Korpusanteil hinaus, auch wo der Korpus Marschall (Frankreich) oder Preis (Italien) vorn hat; nachträglich beobachtet hängt das am Wort Hauptstadt, nicht am Land. Die Gegenthese "häufigste Wendung" ist widerlegt. B OFFEN nach Wortlaut (Bürgermeister verfehlt 0,5), KÖNIG-SPEZIFISCH aber ausgeschlossen: Botschafter wird stärker kopiert als König. Folge: Für das Bleiben in der Schleife ist das Wort austauschbar, der Hebel bleibt die Kopie (snai/prod512b-schleife). Der Zug zu König am Einstieg wächst mit dem Training (s5 nicht unter Top 5, s11 Top 1).
  Offen: Ob König bei Hauptstadt eine echte Assoziation ist oder ein allgemeiner Vorzug nach ": Der" (Beobachtung an einem Prompt); ob der Sinn der Wendung die Kopierstärke mitbestimmt (Bürgermeister am schwächsten); Verlauf bis s15.
  Datei: rechner-a:~/snai_pruef/frankreich/ERGEBNIS.md
Chronik (juengste 8 von 9, voll=True zeigt alle):
  2026-11-06 11:47 Rezept r614
  2026-11-06 11:47 Status geplant -> laeuft (Rezept r614)
  2026-11-06 11:47 Messwerte m9338-m9350
  2026-11-06 11:47 Ergebnis e560: teilweise
  2026-11-06 11:47 Status laeuft -> ausgewertet (Ergebnis e560)
  2026-11-08 06:28 Messwerte m9504-m9511
  2026-11-10 08:16 Messwerte m9975-m9986
  2026-11-12 13:09 Messwerte m10662-m10667
```
