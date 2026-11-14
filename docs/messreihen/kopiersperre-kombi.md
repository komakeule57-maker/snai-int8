# snai/kopiersperre-kombi

```text
snai/kopiersperre-kombi - ausgewertet, angelegt 2026-10-26, zuletzt 2026-10-26 21:41
Frage: Bringt das Unlikelihood-Training von SnAI Evo (Rezept UQW) zusaetzlich zur kalibrierten, prompt-freien Kopiersperre weniger Beam-Schleifen, ohne Namen aus dem Prompt zu kosten? Und kann das Training die Sperre ersetzen? Gepaart an 6 Knirps-Saaten (M, UQW, K0Q).
Kriterium (festgelegt 2026-10-26 19:19, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/kombi/kriterien.txt (md5 63e95783, mit Pruefer und Vorprobe). Arme je Saat k=1..6: M0, MS (M + Sperre D_M), U0, US (UQW + Sperre D_UQW neu kalibriert), UA (UQW + D_M, nur berichtet), KS (K0Q + D_K0Q). Durchlass je Modell aus 12 Kalibrier-Prompts (beamlauf2 + rate12), Test 24 andere Prompts (+12 Reserve), 80 Namensposten.
Q2 (tragend) je Saat: U_US <= 0,9 U_MS UND U_US <= 0,9 U_KS UND T_US >= T_MS - 4 UND E_US <= 1,2 E_MS. Knapp (Bootstrap-Intervall schliesst 0,9 ein) -> 36 Prompts.
Q1 (berichtet): U_U0 <= 1,1 U_MS.
Regel: ja >= 5/6, nein <= 1/6.
Vorbedingungen: G U_MS <= 0,5 U_M0 in >= 5/6; R1 M0/U0 bytegleich zu SnAI Evos b12n; Bindung messbar wenn T_M0 >= 8/80.
GESAMT: erfuellt = Q2 >= 5/6; verfehlt = U_US <= 0,9 U_MS in <= 1/6; teilweise = U-Teil >= 5/6, aber KS/T/E-Bedingung verfehlt oder Bindung nicht messbar; sonst keine_aussage.
Plan: rechner-a:~/snai_pruef/kombi/kriterien.txt
Baut auf: snai/ditto-eigen-bestaetigung, snai/ditto-eigen-gewicht, snai/kopiersperre-dosis, snai/kopiersperre-promptfrei
Darauf baut: snai/kopiersperre-gross-s3
Rezepte:
  r436 [2026-10-26] rechner-b: cd ~/snai_pruef/kombi && setsid nohup bash lauf.sh > lauf.out 2>&1 < /dev/null &   (Start 19:19:56, PAR=7). Auswertung rechner-a nach rsync: cd ~/snai_pruef/kombi && python3 auswert_kombi.py
      quelltext: kriterien.txt 63e95783; lauf.sh cc6e0a8c; auswert_kombi.py 01b911de (--probe gruen, KOMBI_MUTANT=1 rot 7 Fehler); proj_sr/snai_inference_kopie2.php 516e3a65 (Original snai_inference.php 8ba48a06, libcortex.so 318b2655, symbio_vocab.json f020d0ca, auf beiden Rechnern gleich); tools/prompt_bindung_kopie3.sh 2ac20112, kopie4.sh 361b1151; einstieg/beamlauf2.sh c22a9dc2, rate12.py 1739441e, sonde_einstieg.php b969e502, f aus einstieg/t1/basis.jsonl; ditto2/unscharf.py ff3999bd; sampling/erfunden.py
      parameter: Modelle (kombi/modell): M_s1-6 a69e1f4b 73fdf529 48c5cef3 c80ab8ad 8bce8ca8 91feb217; UQW_s1-6 dd7054ec c249ef78 749f2c77 ff159c9d 03ce25a6 4471648e; K0Q_s1-6 12e85a89 f2b0fa6d 2d1f74ad cf26ce00 0fe544d7 593522c3. Beam 3 ROH, CPU, OMP 1, rep 1,15/64; Sperre prompt-frei, Saat 1; Arme M0 MS U0 US UA KS; Prompt-Saetze n/f/r je 12; 80 Posten (kopie3 0-39, kopie4 40-79), Fenster 120 Woerter
      seed: Modelle: Saaten 1-6 von SnAI Evo (Offsets 0/1000003/.../5000003). Sperre SNAI_KOPIE_SAAT=1; Beam deterministisch; Bootstrap Saat 20261026
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/kombi/{fortschritt.log,lauf.out,durchlass/,aus/s<k>/<arm>/}, Kalibrier-Beams rechner-b:~/snai_pruef/einstieg/b/kk_<X>_s<k>/, Vorproben rechner-b:~/snai_pruef/kombi/probe/
      notiz: Vorproben 2026-10-26: kopie2 ohne F und mit F=1 bytegleich zum Original und zu SnAI Evos b12n_M_s4 (Abschnitt 1, andere Maschine); F=0 sperrt 237/238. Erste Vorprobe ROT durch zsh auf rechner-b ($E nicht zerlegt -> GPU, ohne ROHPROMPT), danach nur noch bash. Bindung M_s4 Posten 0-19: 5/20. Absprache: TDC-AI ok (4 VZ + 7), SnAI Evo ok (nur lesen in ditto/ditto2).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/kombi/auswert_kombi.txt (4111a4bc, auswert_kombi.py 01b911de), zusatz_kombi.txt (b08e4829, nur berichtet)
  m5984 U absolut (Beam 3, unscharf K=2) | 0,471 / 0,408 / 0,477 / 0,581 / 0,517 / 0,510 | M0 | s1-s6 | 24
  m5985 U/U_M0 | 0,08 / 0,14 / 0,13 / 0,09 / 0,07 / 0,13 | MS | s1-s6 | 24
  m5986 U/U_M0 | 0,61 / 0,73 / 0,71 / 0,51 / 0,53 / 0,57 | U0 | s1-s6 | 24
  m5987 U/U_M0 | 0,09 / 0,11 / 0,10 / 0,05 / 0,05 / 0,12 | US | s1-s6 | 24
  m5988 U/U_M0 | 0,06 / 0,06 / 0,04 / 0,05 / 0,03 / 0,06 | UA | s1-s6 | 24
  m5989 U/U_M0 | 0,14 / 0,08 / 0,14 / 0,09 / 0,10 / 0,11 | KS | s1-s6 | 24
  m5990 U_US/U_MS (alle Saaten knapp, Urteil auf 36; Lesart 24: 1,25 / 0,77 / 0,74 / 0,57 / 0,66 / 0,91) | 1,02 / 0,99 / 0,81 / 0,55 / 0,50 / 0,85 | US | s1-s6 | 36
  m5991 U_US/U_KS | 0,79 / 1,63 / 0,89 / 0,46 / 0,55 / 1,13 | US | s1-s6 | 36
  m5992 U_U0/U_MS (Q1) | 8,08 / 5,17 / 5,48 / 5,77 / 7,50 / 4,41 | U0 | s1-s6 | 24
  m5993 U_UA/U_US (Q3) | 0,61 / 0,51 / 0,38 / 0,96 / 0,68 / 0,51 | UA | s1-s6 | 24
  m5994 T Treffer/80 (unter Boden, T_M0 Mittel 7,3) | 14 / 6 / 2 / 9 / 7 / 6 | M0 | s1-s6 | 80
  m5995 T Treffer/80 | 14 / 6 / 3 / 14 / 16 / 10 | MS | s1-s6 | 80
  m5996 T Treffer/80 | 8 / 4 / 12 / 11 / 16 / 8 | US | s1-s6 | 80
  m5997 T Treffer/80 | 9 / 4 / 13 / 10 / 17 / 7 | UA | s1-s6 | 80
  m5998 T Treffer/80 | 14 / 12 / 13 / 12 / 20 / 16 | KS | s1-s6 | 80
  m5999 E_US/E_MS | 0,79 / 1,20 / 0,98 / 0,89 / 0,74 / 0,77 | US | s1-s6 | 24
  m6000 U_US/U_MS gepoolt 6x36 [95 % Bootstrap] (nur berichtet) | 0,78 [0,62; 0,97] | gepoolt | s1-s6 | 216
  m6001 U_US/U_KS gepoolt (nur berichtet) | 0,83 [0,67; 1,02] | gepoolt | s1-s6 | 216
  m6002 U_UA/U_US gepoolt (nur berichtet) | 0,58 [0,45; 0,72] | gepoolt | s1-s6 | 216
  m6003 U_UA/U_MS gepoolt (nur berichtet) | 0,45 [0,34; 0,59] | gepoolt | s1-s6 | 216
  m6004 U_U0/U_MS gepoolt (nur berichtet) | 5,66 [4,79; 6,83] | gepoolt | s1-s6 | 216
  m6005 Durchlass k=1 (D_UQW > D_M in 27/30 Faechern) | D_M 0,30-0,43, D_UQW 0,39-0,48, D_K0Q 0,33-0,40 | Kalibrierung | s1-s6 | 12
  m6006 Fehlerkanal (15 leere Bindungsposten = Beam-Textende nach 0-2 Token, nur UQW/K0Q, Posten 14/16/62; R1 6/6 bytegleich) | 4176/4176 rc 0, 0 U-Texte verdaechtig, 15/2880 Posten leer | alle | s1-s6 | 4176
Ergebnis e384 [2026-10-26 21:41]: keine_aussage
  Fazit: Training ersetzt die Sperre nicht (Q1 0/6): UQW allein laesst 4,4-8,1 x so viel Schleife wie die Sperre allein (gepoolt 5,66 [4,79; 6,83]). Ob UQW ZUSAETZLICH zur Sperre hilft, entscheidet die Messung nicht: U-Teil 4/6 in beiden Lesarten (24/36 Prompts), alle Saaten knapp, Rest-Schleife nach Sperre so klein (U ~0,05 von 0,49), dass die Prompt-Streuung 10 % nicht aufloest; gepoolt US/MS 0,78 [0,62; 0,97], gegen Kontrolle KS 0,83 [0,67; 1,02] (nur berichtet). Staerkerer Hebel im selben Lauf: UQW mit der alten, schaerferen Kalibrierung (UA) halbiert den Rest gegen MS (0,45 [0,34; 0,59]), d.h. Dosis der Sperre schlaegt Training; Neukalibrieren nach Anti-Schleifen-Training ist fuer die Schleifenwirkung nicht noetig (Q3). Bindung unter Boden (T_M0 7,3/80): Namenskosten hier ungemessen. Folge: Sperre bleibt der tragende Weg; weniger Schleife eher ueber die Dosis (DS) als ueber Training.
  Offen: Namenskosten der schaerferen Dosis an einem Modell mit messbarer Bindung; UKB1 (snai/ditto-eigen-kopie, Beleg ohne Kosten) mit Sperre ungemessen; prod512b ungemessen.
  Datei: rechner-a:~/snai_pruef/kombi/ERGEBNIS_kombi.md
Chronik:
  2026-10-26 19:19 angelegt
  2026-10-26 19:20 Rezept r436
  2026-10-26 19:20 Status geplant -> laeuft (Rezept r436)
  2026-10-26 21:41 Ergebnis e384: keine_aussage
  2026-10-26 21:41 Status laeuft -> ausgewertet (Ergebnis e384)
  2026-10-26 21:41 Messwerte m5984-m6006
```
