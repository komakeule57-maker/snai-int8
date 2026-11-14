# snai/noten-r

```text
snai/noten-r - ausgewertet, angelegt 2026-11-05, zuletzt 2026-11-05 20:54
Frage: Erzeugt der Noten-Knirps (notentakt2, 64 Epochen, d32 32/2/16 und d64 64/4/16) mit neuem Enginestand (Hauptbaum b3b9677, Lib 1eb78bc1) und den einzeln zugeschalteten Teilen von Rezept R (Warmup 2000 + WSD, eigene LR, Embedding-Eingangsfaktor) mehr formkorrekte Melodien zur angesagten Taktart als mit dem alten Stand (e142)? Welcher Teil macht den Unterschied? Auftrag 05.11.
Kriterium (festgelegt 2026-11-05 13:49, vor dem ersten Messwert):
  Datei rechner-a:~/snai_pruef/r_wdh/noten/KRITERIEN_noten_r.md (md5 dc174e86, Prüfer Gemini/Mistral vor dem Start). Stufe A: LR-Leiter 8 Epochen, Form W (Warmup 2000, Abkühlstart 0,9N), LR 0,001/0,002/0,004/0,008, 3 Saaten je Breite; lambda = kleinstes Held-out-Mittel, eine kleinere LR innerhalb 0,01 nats gewinnt; Rand 0,008 -> 0,016 nachlegen. Stufe B, 64 Epochen, 3 Saaten, je eine Änderung: K (neue Engine, altes Rezept), W (+Warmup 2000 + WSD 0,9N), L (+lambda), R (+EE). Hauptmaß quote_angesagt T=1,0 (form_noten.php, 500 Ziehungen, Saat 4711) am Endstand s63. X gegen Y je Breite: BESSER, wenn jede Saat über 110 % des Y-Mittels; SCHLECHTER, wenn jede unter 90 %; GLEICH, wenn alle in 90-110 %; sonst saatabhängig. Vergleiche K/alt, W/K, L/W, R/L, R/alt. Knapp (±2 Punkte an einer Schwelle): zweite Ziehung Saat 4712 für alle Läufe beider Seiten, Urteil auf 1000. Nebenmaße ohne Urteil: Held-out s63, Überanpassung, Kopien. Fehlerkanal (rc, STEPS 3088, Warmup/LR-Decay-Zeilen gegen adam_t, EMBEIN genau bei R) vor den Urteilen, Sonde einmal rot.
Plan: rechner-a:~/snai_pruef/r_wdh/noten/KRITERIEN_noten_r.md
Baut auf: snai/noten-breite64, snai/stell-lr-leiter, snai/stell-reparatur27
Darauf baut: snai/noten-mehr
Rezepte:
  r601 [2026-11-05] rechner-a: cd ~/snai_pruef/r_wdh && bash los.sh noten A 4 (13:49) ; bash los.sh noten B 3 (14:18). Je Lauf eine Zeile aus noten/auftraege_A.sh bzw. noten/auftraege_B.sh: VOK=noten_takt PRE=notentakt2 SUF=_takt2 [WARM=.. DSTART=.. EE=1] bash noten/lauf_noten.sh <arm> <lr> <segmente> proj_ow/factory/checkpoints/notentakt_gen_<d32h2|d64h4>_s<S>.snai <N>; Stufe B danach form_noten.php modell <s63> 500 1.0 4711 (TRAIN=proj_ow notentakt2_c64_seg0.txt) nach noten/form/<arm>.4711.json (+ .err)
      quelltext: Prüfkopie ~/snai_pruef/r_wdh/proj = Hauptbaum b3b9677 (git archive), libcortex.so 1eb78bc1, cortex.nim f8292f7b, snai_tokenizer.php 35d4dd21 (patch_vokabular.py), Revival aus; noten/lauf_noten.sh aus bau_skripte.py (Kopie knirps/noten/lauf_noten.sh 08263f69 mit 4 Änderungen per assert)
      parameter: Stufe A: 8 Epochen (N 24.704, WARM 2000, DSTART 22.234), LR 0,001-0,008. Stufe B: 64 Epochen (N 197.632); K LR 0,001 WARM 500 Cosinus ab 500; W LR 0,001 WARM 2000 DSTART 177.869; L entfällt (lambda 0,001); R = W + EE=1. Boden 0,1, WD 0,1, int8 voll, gebunden, ctx 64
      seed: Genesis notentakt_gen_d32h2_s1-3 / d64h4_s1-3 (dieselben wie e142); Fensterfolge am Laufnamen; Formsonde Saat 4711
      rechner: rechner-a CPU, OMP 1, nice 10
      logs: rechner-a:~/.cache/snai_pruef/r_wdh/noten/ (A_*, B_*: .log, .mess.jsonl, _s<k>.train.log); Checkpoints ~/snai_pruef/r_wdh/proj/factory/checkpoints/noten_*; Formsonde ~/snai_pruef/r_wdh/noten/form/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/r_wdh/noten/leiter_A_ausgabe.txt (leiter_A.py auf ~/.cache/snai_pruef/r_wdh/noten/A_*.mess.jsonl, Zeile s7, 300 Fenster, Sabotage 0); Fehlerkanal 24/24 OK (fehlerkanal.py, Rot-Proben vorher an probe_R/probe_K gesehen)
  m9076 Stufe A Held-out nach 8 Epochen, Mittel (Saaten 1/2/3) | 1,2589 (1,2703/1,2597/1,2467) | d32 lr0,001 | 1-3 | 300
  m9077 Stufe A Held-out nach 8 Epochen, Mittel | 1,2810 | d32 lr0,002 | 1-3 | 300
  m9078 Stufe A Held-out nach 8 Epochen, Mittel | 1,3044 | d32 lr0,004 | 1-3 | 300
  m9079 Stufe A Held-out nach 8 Epochen, Mittel | 1,3321 | d32 lr0,008 | 1-3 | 300
  m9080 Stufe A Held-out nach 8 Epochen, Mittel (Saaten 1/2/3) | 1,1912 (1,1826/1,1759/1,2151) | d64 lr0,001 | 1-3 | 300
  m9081 Stufe A Held-out nach 8 Epochen, Mittel | 1,2077 | d64 lr0,002 | 1-3 | 300
  m9082 Stufe A Held-out nach 8 Epochen, Mittel | 1,2471 | d64 lr0,004 | 1-3 | 300
  m9083 Stufe A Held-out nach 8 Epochen, Mittel | 1,3136 | d64 lr0,008 | 1-3 | 300
  m9084 lambda nach Wahlregel | 0,001 (beide Breiten; unterer Rand der Leiter, Optimum nach unten nicht eingegrenzt) -> Arm L entfällt | d32/d64 | 1-3 | 24
  m9085 Fehlerkanal Stufe A | 24/24 OK | alle | 1-3 | 24
  Quelle: rechner-a:~/snai_pruef/r_wdh/noten/auswert_B_ausgabe.txt (auswert_B.py; Formsonde noten/form/*.4711/.4712.json, Held-out ~/.cache/snai_pruef/r_wdh/noten/B_*.mess.jsonl)
  m9163 Fehlerkanal Stufe B | 18/18 Läufe x 64 Segmente OK; Formsonden-err nur erwartete EMBEIN-Zeile bei R; Gegenprobe alt 4711 = Bezug exakt | alle | 1-3 | 18
  m9164 quote_angesagt s63, 500 Ziehungen (4711), Saaten 1/2/3 (Mittel) | K 27,4/24,0/18,2 (23,20); W 26,6/18,6/16,8 (20,67); R 19,8/22,0/21,6 (21,13); alt 20,47 | d32 | 1-3 | 500
  m9165 quote_angesagt s63, 500 Ziehungen (4711), Saaten 1/2/3 (Mittel) | K 41,4/40,4/40,2 (40,67); W 47,4/40,0/44,2 (43,87); R 46,2/45,4/35,6 (42,40); alt 42,13 | d64 | 1-3 | 500
  m9166 Knapp-Regel | gegriffen (d32 K/alt 88,9 %; d64 W/K 108,7 %; d64 R/alt 109,7 %) -> Saat 4712 für alle 18 neuen + 6 alten Stände | alle | 1-3 | 24
  m9167 quote_angesagt s63, 1000 Ziehungen (4711+4712), Saaten 1/2/3 (Mittel) | alt 19,7/22,8/19,1 (20,53); K 25,0/25,9/19,2 (23,37); W 27,7/17,6/16,6 (20,63); R 18,6/21,7/21,2 (20,50) | d32 | 1-3 | 1000
  m9168 quote_angesagt s63, 1000 Ziehungen (4711+4712), Saaten 1/2/3 (Mittel) | alt 35,6/37,4/47,0 (40,00); K 40,8/39,4/38,1 (39,43); W 46,7/38,6/42,8 (42,70); R 45,1/43,4/35,5 (41,33) | d64 | 1-3 | 1000
  m9169 Urteile auf 1000 Ziehungen | d32: K/alt SAATABHAENGIG, W/K SAATABHAENGIG, R/W GLEICH (Saat 1 bei 90,1 %), R/alt GLEICH (90,6 %); d64: K/alt GLEICH, W/K SAATABHAENGIG, R/W SAATABHAENGIG, R/alt SAATABHAENGIG; L entfällt | alle | 1-3 | 1000
  m9170 Held-out-Loss s63, Mittel (Nebenmaß) | d32 alt 1,163 K 1,168 W 1,165 R 1,150; d64 alt 1,106 K 1,108 W 1,100 R 1,093 (Abstände <= 1,2 % = Gleichstand) | alle | 1-3 | 300
  m9171 Überanpassung (Anstieg s63 über Segment-Minimum) | K max 0,010; W und R 0 in 12/12 Läufen; keiner > 0,02; Kopien 0 überall | alle | 1-3 | 64
Ergebnis e553 [2026-11-05 20:54]: gleichstand
  Fazit: In keinem Vergleich ein BESSER (Kriterium: jede Saat über 110 % des Bezugsmittels, auf 1000 Ziehungen nach Knapp-Regel). Die neue Engine allein = alter Stand bei d64 (GLEICH), Rezept R gesamt = alter Stand bei d32 (GLEICH, Saat 1 an der Kante 90,6 %), bei d64 saatabhängig (2 Saaten leicht vorn, 1 deutlich hinten). Einziger durchgehender Effekt nur im Nebenmaß: mit Warmup 2000 + spätem Abkühlen kein Anstieg des Held-out-Loss gegen Ende (0 in 12/12), ohne Wirkung auf die Formquote. Für die Noten lohnt Weiterdrehen an Rezeptteilen nicht: Saatstreuung (alt d64 35,6-47,0) und Ziehungsrauschen (95-%-Band einer Saat bei d32 ca. ±12 % des Mittels) sind größer als jeder Effekt, den die Regel auflösen kann. Hebel bleiben Kapazität und Daten (d64 verdoppelte die Quote in e142), nicht das Rezept.
  Offen: LR unter 0,001 (Stufe A endete am unteren Rand); Warmup und Planform getrennt; andere Datensätze; Kriterium-Lesart '2 Prozentpunkte' (Verhältnis vs. Quote) ohne Folgen, da alle 24 Stände nachgezogen.
  Datei: rechner-a:~/snai_pruef/r_wdh/noten/ERGEBNIS_noten_r.md
Chronik:
  2026-11-05 13:49 angelegt
  2026-11-05 14:17 Messwerte m9076-m9085
  2026-11-05 14:17 Status geplant -> laeuft (Messwerte m9076-m9085)
  2026-11-05 14:18 Rezept r601
  2026-11-05 20:54 Messwerte m9163-m9171
  2026-11-05 20:54 Ergebnis e553: gleichstand
  2026-11-05 20:54 Status laeuft -> ausgewertet (Ergebnis e553)
```
