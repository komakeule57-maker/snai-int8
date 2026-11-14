# snai/noten-mehr

```text
snai/noten-mehr - ausgewertet, angelegt 2026-11-05, zuletzt 2026-11-09 11:14
Frage: Erzeugt der Noten-Knirps (d32/d64, 2 Schichten, Rezept W, 197.632 Schritte) mehr formkorrekte Melodien zur angesagten Taktart (a) mit kleinerer LR (0,0005 / 0,00025) auf den alten Daten, (b) mit dem gesamten vorhandenen Bestand (920.172 Melodien, 99,8 % Generator-Material) bei gleicher LR und gleichem Budget, (c) mit kleinerer LR auf diesem Bestand, jeweils gegen snai/noten-r W? Auftrag 05.11. abends, nur rechner-c.
Kriterium (festgelegt 2026-11-05 21:40, vor dem ersten Messwert):
  Datei rechner-c+rechner-a:~/snai_pruef/r_wdh/noten/KRITERIEN_noten_mehr.md (md5 65059435, Prüfer Gemini/Mistral vor dem Start). Arme je Breite, Saaten 1-3: A1 (= noten-r W, LR 0,001 alte Daten), A05, A025 (alte Daten, LR 0,0005/0,00025), M1, M05 (Bestand 'mehr', LR 0,001/0,0005). Budget fest 64 x 3088 Schritte, Warmup 2000, Abkühlstart 177.869. Hauptmaß quote_angesagt T=1,0 am s63 auf 2.000 Ziehungen (Saaten 4711-4714). X gegen Y je Breite: BESSER, wenn jede Saat über 110 % des Y-Mittels; SCHLECHTER, wenn jede unter 90 %; GLEICH, wenn alle 90-110 %; sonst saatabhängig. Vergleiche V1 A05/A1, V2 A025/A1, V3 M1/A1, V4 M05/M1, V5 M05/A1. Knapp (±2 Punkte an einer Schwelle) -> 4715-4718 für alle Läufe beider Seiten, Urteil auf 4.000. Rand: A025 BESSER und über A05 -> 0,000125 nachlegen; M05 BESSER in V4 -> M025. Nebenmaße: Held-out s63 auf 219 echten Melodien, Überanpassung, Kopien, Taktarten. Gerätechecks G2 (Gleichlauf Segment 0 zu rechner-a), G3 (Formsonde bytegleich), G4 (STEPS 3088 bei M) vor dem Start, automatisch. Deutung V3: misst 'vorhandener Bestand (fast nur Generator-Material)', nicht 'mehr echte Daten'.
Plan: rechner-a:~/snai_pruef/r_wdh/noten/KRITERIEN_noten_mehr.md
Baut auf: snai/noten-r
Rezepte:
  r606 [2026-11-05] rechner-c: cd ~/snai_pruef/r_wdh && setsid -f nohup bash noten/start_mehr.sh (05.11. 21:40; wartet auf Ende der Zellwelt-K2-Läufe, dann G2-G4, dann bash noten/auftraege_mehr.sh | xargs -P 4). Je Lauf: VOK=noten_takt [INDIR=noten/daten PRE=mehr | PRE=notentakt2] SUF=_takt2 WARM=2000 DSTART=177869 bash noten/lauf_noten_mehr.sh N_<A05|A025|M1|M05>_<d32h2|d64h4>_s<S> <lr> 64 <genesis> 197632; danach form_noten_mehr.php modell <s63> 500 1.0 <4711..4714> nach noten/form_mehr/
      quelltext: Prüfkopie r_wdh/proj (Hauptbaum b3b9677, libcortex 1eb78bc1), md5-gleich zu rechner-a. lauf_noten_mehr.sh und form_noten_mehr.php aus noten/bau_mehr_skripte.py (assert-Patch; Änderungen: INDIR, Logordner noten_mehr; Prüfer-Kopie des Noten-Sammlers md5 67cb3d3d). Daten noten/daten/bau_mehr.py (+ nottingham.py, pruefe_zeilen.php), Zählwerte bau_mehr.json, seg0 md5 2ed523fe. start_mehr.sh 3f00d4e9, auftraege_mehr.sh 3dbf1427.
      parameter: d32 32/2/16 und d64 64/4/16, 2 Schichten, int8 voll, gebunden, ctx 64, Rezept W (Warmup 2000, Cosinus ab 177.869 bis 197.632, Boden 0,1), WD 0,1, ohne EE. LR A05/M05 0,0005, A025 0,00025, M1 0,001.
      seed: Genesis notentakt_gen_d32h2_s1-3 / d64h4_s1-3 (wie noten-r); Fensterfolge am Laufnamen; Bestand gemischt mit Saat 20261106; Formsonde 4711-4714
      rechner: rechner-c CPU (4 Threads), OMP 1, nice 10, P 4
      logs: rechner-c:~/.cache/snai_pruef/r_wdh/noten_mehr/; Checkpoints ~/snai_pruef/r_wdh/proj/factory/checkpoints/noten_N_*; Formsonde ~/snai_pruef/r_wdh/noten/form_mehr/; Starter noten/start_mehr.log
  r623 [2026-11-07] rechner-c: cd ~/snai_pruef/r_wdh/noten && setsid -f nohup bash start_mehr_p3.sh (07.11. 18:42; Gerätechecks G2-G4, dann bash noten/auftraege_mehr2.sh | xargs -P 2). Je M-Zeile N 198155, DSTART 178340; je A-Zeile N 197632, DSTART 177869. Code r_wdh/proj, libcortex vec_native 21dd837a.
      notiz: Ersetzt den Start per start_mehr.sh/start_mehr_p2.sh (G4-Abbruch 17:27). auftraege_mehr2.sh und start_mehr_p3.sh aus den Vorlagen per assert (noten/bau_mehr_p3.py). Plätze 2/2 mit snai-evo/reserve.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-c:~/snai_pruef/r_wdh/noten/start_mehr.log, noten/schritte_{mehr,alt}.txt (zaehle_schritte.php: SnaiTokenizer + snai_window_offsets wie train_worker), KRITERIEN_noten_mehr.md Nachtrag G4 (md5 cc5df3ff)
  m9475 G2 Gleichlauf (B_W_d32h2_s1 s0, Lib vec_native 21dd837a) | a247b2ae = Soll rechner-a, OK (17:25) | Gerät | 1 | 1
  m9476 G4 Rauchprobe M, erster Versuch | STEPS_DONE 3097 statt Soll 3088 -> Abbruch vor dem Start (17:27), wie die Regel verlangt | Gerät | 1 | 1
  m9477 Schrittzahl gezählt (ctx 64) | alte Abschnitte 64 x 3088 = 197.632 (= bisheriges N, Gegenprobe); mehr 3095-3098, Summe 198.155; seg0 3097 = G4 | Daten | - | 128
  m9478 Gesetzt nach G4-Regel (Nachtrag im Kriterium) | M-Arme N 198.155, DSTART 178.340; A-Arme unverändert 197.632 / 177.869; M rechnet 0,26 % mehr Schritte | M-Arme | - | 12
  m9479 Gerätechecks p3 (nach Stromausfall 17:31-18:21) | G2 OK, G3 Formsonde B_W_d32h2_s1 OK, G3 alt_d64h4_s3 OK, G4 OK (3097) | Gerät | - | 4
  m9480 Start 24 Läufe + A1-Sonden | 07.11. 18:43:35, noten/start_mehr_p3.sh, P 2 (Plätze 2/2) | rechner-c | - | 24
  Quelle: rechner-c: ~/.cache/snai_pruef/r_wdh/noten_mehr/N_M*_s*_s<k>.train.log (PLAN_STEPS/PLAN_TOKENS, LR-Decay, Telemetrie; echter Codepfad) gegen noten/schritte_mehr.txt (zaehle_schritte.php); Sonde noten/fehlerkanal_mehr.py (md5 900999ed, aus fehlerkanal.py per assert, bau_fk_mehr.py, einziges Stellrad --schritte), Schrittdatei noten/schritte_mehr_engine.txt (md5 714723880)
  m9542 Token je Segment Engine gegen Zähler (alle 64 Segmente, M-Daten) | Engine sieht je Segment genau 1 Token mehr als zaehle_schritte.php (PLAN_TOKENS = Zähler + 1) | M-Arme | - | 64
  m9543 Schritte je Segment Engine gegen Zähler | 63/64 gleich; s47: Engine 3097, Zähler 3096 (198146 Token kreuzen die Fenstergrenze) | M-Arme | - | 64
  m9544 Gesamtschritte M-Arme (Summe PLAN_STEPS) | 198156 in allen 6 Läufen (N_M05 s1-3, N_M1 s1-3); Nachtrag G4 setzte N = 198155 nach Zähler | M-Arme | 1-3 | 6
  m9545 LR am überzähligen Schritt adam_t 198156 | 0,0000500 (Boden, Decay endet bei 198155) | N_M05_d64h4_s1 | 1 | 1
  m9546 Fehlerkanal M-Arme (fehlerkanal_mehr.py noten_mehr <lauf> <lr> 2000 178340 198155 0 64 --schritte schritte_mehr_engine.txt) | 6/6 OK (Warmup-Start je Segment = kumulierte Schritte, Decay 178340-198155, keine warn/nan) | M-Arme | 1-3 | 6
  m9547 Rot-Proben fehlerkanal_mehr.py | mit alten Schritten (3088): steps- und warmup-Fehler ab s1; mit altem Decay 177869/197632: decay-Fehler in allen Segmenten; mit Zählerdatei: s47 steps + warmup ab s48 (alle rot gesehen) | Sonde | 1 | 3
  m9548 Kontrolle Kopie ohne --schritte am A-Arm | N_A05_d64h4_s1 OK wie Original fehlerkanal.py | Sonde | 1 | 1
  Quelle: rechner-a ~/snai_pruef/r_wdh/noten/auswert_mehr.py 6efb1330 (--knapp), auswert_knapp.txt; Erstauswertung ohne --knapp
  m9740 d32 V1 A½/A1 je Saat (2.000) | 121,8 / 127,3 / 146,4 % BESSER | A½ | 1-3 | 2000
  m9741 d32 V2 A¼/A1 je Saat (2.000) | 112,6 / 96,2 / 130,2 % SAATABHÄNGIG | A¼ | 1-3 | 2000
  m9742 d32 V3 M1/A1 je Saat (2.000) | 243,1 / 223,8 / 207,4 % BESSER | M1 | 1-3 | 2000
  m9743 d32 V4 M½/M1 je Saat (4.000, Knapp-Regel) | 107,1 / 104,8 / 89,3 % SAATABHÄNGIG (Kante 89,3; auf 2.000 GLEICH 109,0/104,1/90,2) | M½ | 1-3 | 4000
  m9745 d64 V1 A½/A1 je Saat (4.000, Knapp-Regel) | 105,1 / 91,9 / 97,6 % GLEICH (Kante 91,9) | A½ | 1-3 | 4000
  m9746 d64 V2 A¼/A1 je Saat (4.000, Knapp-Regel) | 105,8 / 104,2 / 90,7 % GLEICH (Kante 90,7) | A¼ | 1-3 | 4000
  m9747 d64 V3 M1/A1 je Saat (2.000) | 138,8 / 134,0 / 126,7 % BESSER | M1 | 1-3 | 2000
  m9748 d64 V4 M½/M1 je Saat (4.000, Knapp-Regel) | 108,9 / 106,1 / 110,2 % SAATABHÄNGIG (Kante 110,2) | M½ | 1-3 | 4000
  m9749 d64 V5 M½/A1 je Saat (2.000) | 143,7 / 142,8 / 147,8 % BESSER | M½ | 1-3 | 2000
  m9750 Held-out s63 M1 gegen A1 | d32 1,2247/1,1645 (+5,2 %), d64 1,1843/1,0999 (+7,7 %), jede M-Saat über jeder A1-Saat | M1 | 1-3
  m9751 Formsonden-.err Zusatzziehungen 4715-4718 | 0 nicht leer von 84 | alle
  Quelle: rechner-a ~/snai_pruef/r_wdh/noten/auswert_knapp.txt (Korrektur einer verschriebenen Zeile)
  m9752 d32 V5 M½/A1 je Saat (M½ 4.000, A1 2.000; nicht knapp, Urteil aus 2.000 ebenfalls BESSER) | 241,3 / 236,1 / 201,3 % BESSER | M½ | 1-3 | 4000
Ergebnis e582 [2026-11-09 11:14]: teilweise
  Fazit: Der Hebel für mehr formkorrekte Melodien ist das Material, nicht die Lernrate: mehr Daten bei gleichem Budget (V3) und mehr Daten mit kleinerer LR (V5) sind in beiden Breiten BESSER (d32 gut das Doppelte, d64 gut ein Drittel). Kleinere LR allein: nur d32 A½ BESSER, A¼ saatabhängig, d64 GLEICH; kleinere LR auf dem großen Bestand (V4) saatabhängig. Eine LR-Senkung lohnt als nächster Schritt nicht. Preis: Auf echten Melodien liegt der Held-out-Loss der M-Arme in jeder Saat höher (+3 bis +8 %, unter der 10-%-Schwelle) – Deutung, nicht gemessen: Destillation des Generators statt 'mehr Daten'. Ob das taugt, entscheidet die Verwendung (Hörprobe), nicht diese Messung. Rand-Regeln nicht ausgelöst, nichts nachgelegt.
  Offen: Mehr ECHTE Daten (Bestand 99,8 % Generator); mehr Daten bei mehr Rechenmenge (~5,9-faches Budget); musikalische Güte der M-Melodien (Hörprobe). Schrittzahl M 198.156 statt 198.155: beide Lesarten im Ergebnis, ändert kein Urteil.
  Datei: rechner-a:~/snai_pruef/r_wdh/noten/ERGEBNIS_noten_mehr.md
Abgeloest und ausgeblendet: 1 messwert - voll=True zeigt sie.
Chronik (juengste 8 von 11, voll=True zeigt alle):
  2026-11-06 06:13 06.11. ~06:15, Entscheidung:
- noten-mehr startet erst NACH den 12 restlichen r-welt-Läufen auf rechner-c. Ab ~09:30 sind das rund 30 h.
- Die Läufe benutzen die neue Lib vec_native 21dd837a. Die Warteschlange (evo/warteschlange_vec.sh) tauscht dazu proj/libcortex.so per mv, bevor noten/start_mehr.sh läuft.
- Gerätechecks: G2 (Abschnitt 0 gegen rechner-a-Sollwert) und G3 (Formsonde) vergleichen gegen Werte der alten Lib. Das ist zugleich die Bytegleich-Probe der neuen Lib in diesem Rezept.
- Der alte Starter (PID 81558) ist beendet.
  2026-11-07 18:44 Messwerte m9475-m9480
  2026-11-07 18:44 Rezept r623
  2026-11-08 10:11 Messwerte m9542-m9548
  2026-11-09 11:14 Messwerte m9740-m9751
  2026-11-09 11:14 Messwerte m9752, loesen m9744 ab
  2026-11-09 11:14 Ergebnis e582: teilweise
  2026-11-09 11:14 Status laeuft -> ausgewertet (Ergebnis e582)
```
