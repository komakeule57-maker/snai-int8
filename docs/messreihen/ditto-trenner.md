# snai/ditto-trenner

```text
snai/ditto-trenner - ausgewertet, angelegt 2026-10-24, zuletzt 2026-10-25 08:18
Frage: Bringt ein DITTO-Training mit wechselnden Trennern zwischen den Kopien (ohne / Zeilenumbruch / Leerzeile) die Wirkung auf die Zeilenumbruch-Wiederholung (Ursache Trenner isoliert), und uebertraegt sie sich auf einen nie trainierten Trenner (" | ")? Was kostet es beim nuetzlichen Kopieren?
Kriterium (festgelegt 2026-10-24 21:20, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/ditto2/kriterien_trenner.txt (mit Pruefer). Neue Arme CT (MLE) / DT (DITTO lambda 0,5) auf mix_t.txt (81ea3be0, Trenner je Stueck aus " ", "\n", "\n\n"), 1 Epoche, Saaten 1-3 (Offsets 0/1000003/2000003), gepaart; M/C/D aus ditto-knirps vorhanden. Messung neue Text-Sonde sonde_text.php (4ecc76bc, ganze Folge als ein Text tokenisiert; Rot und Gruen gesehen), 200 frische Saetze saetze_frisch3.json (1825ca3b), Trenner nl/pipe/nl2/leer. Regel je Saat 3/3 ja, 0/3 nein, sonst saatabhaengig. T1 (entscheidet) nl: R_DT <= 1,0 UND R_DT/R_M <= 0,9. Gegenprobe G: alter D erfuellt T1 nicht. T1 3/3 UND G 0/3 = "Trenner (samt Fensterlage) ist die Ursache". T2 (pipe, nie trainiert) gleiche Bedingung = Uebertragung. T3 Kosten Beleg A_DT >= 0,9 A_M, Held-out H_DT-H_M <= 2 %. T1 0/3 = "nicht in 1 Epoche" -> 6 Epochen vor "wirkt nicht". Knapp (Bootstrap ueber Saetze schliesst Schwelle ein) -> Wiederholung Kandidaten 650..849.
Plan: rechner-a: 3 Saaten parallel (OMP 3, nice 15), je Saat CT dann DT (~27 min je Epoche), danach Messung aller 15 Endstaende + Basis mit 4 Sonden (je ~100 s) sowie Held-out/Beleg fuer CT/DT. ~1,5-2 h.
Baut auf: snai/ditto-format, snai/ditto-knirps
Darauf baut: snai/ditto-ab2, snai/ditto-selten
Rezepte:
  r412 [2026-10-24] cd ~/snai_pruef/ditto2 && for k in 1 2 3; do setsid nohup bash trenner.sh $k & done; danach je Endstand bash textmess.sh <name> <ckpt> (15 Endstaende + Basis). trenner.sh: env <SNAI_DITTO_AUS=1 | SNAI_DITTO_LAMBDA=0.5> SNAI_CORTEX_LIB=~/snai_pruef/ditto/bau/libcortex_D.so SNAI_START_OFFSET=<0|1000003|2000003> SNAI_TRAIN_MODE=pretrain SNAI_TIE_EMBEDDINGS=1 SNAI_INT8_FULL=1 SNAI_FORCE_CPU=1 SNAI_I8_MOM_SR=mv SNAI_WARMUP_STEPS=500 SNAI_GAIN_GUARD=0 OMP_NUM_THREADS=3 php train_cluster.php daten/mix_t.txt factory/checkpoints/ft.snai 1 1 factory/checkpoints/drohneP_s19.snai 3 0.0001 0 1 0.1; danach mess6.sh
      quelltext: trenner.sh, textmess.sh, mess6.sh 2d5e4b51, sonde_text.php 4ecc76bc (patch_sonde_text.py 6d6d55ec), bau_ditto_trenner.py 0a9ca497 (patch_bau.py 8cb1a12b), kriterien_trenner.txt 753f576a; libcortex_D.so e4bb3a0f
      parameter: mix_t.txt 81ea3be0 (869 Stuecke: 271 ohne, 296 "\n", 302 "\n\n"), lambda 0,5 (DT), LR 0,0001 konstant, WD 0,1, 1 Epoche; Saetze saetze_frisch3.json 1825ca3b; Basis drohneP_s19 170d4d3f
      seed: SNAI_START_OFFSET 0 / 1000003 / 2000003 = Saat 1/2/3; Trennerzufall Saat 20261024, Datenbau 20261023
      rechner: rechner-a (proj, proj_s2, proj_s3)
      logs: rechner-a:~/snai_pruef/ditto2/log/{CT,DT}_s<k>.log, log/trenner.log, log/textmess.log, mess/{CT,DT}_s<k>/, mess/tr_<name>/, arme/{CT,DT}_s<k>.snai, geraet/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ditto2/boot_trenner.py 64057b6c (Ausgabe log/boot_trenner.out ea16d03e), Text-Sonde sonde_text.php 4ecc76bc auf saetze_frisch3.json 1825ca3b; R = TP4/TP1; Wiederholung boot_trenner_zweit.py 3756b9ef auf saetze_frisch4.json 2cde2d99
  m5277 R nl | 1,498 | M | 1 | 194
  m5278 R nl | 1,423 | M | 2 | 194
  m5279 R nl | 1,497 | M | 3 | 194
  m5280 R nl | 1,382 | C | 1 | 194
  m5281 R nl | 1,411 | C | 2 | 194
  m5282 R nl | 1,274 | C | 3 | 194
  m5283 R nl | 1,937 | D | 1 | 194
  m5284 R nl | 1,588 | D | 2 | 194
  m5285 R nl | 1,375 | D | 3 | 194
  m5286 R nl | 1,335 | CT | 1 | 194
  m5287 R nl | 1,310 | CT | 2 | 194
  m5288 R nl | 1,295 | CT | 3 | 194
  m5289 R nl [95 %] | 0,365 [0,338-0,395] | DT | 1 | 194
  m5290 R nl [95 %] | 0,198 [0,179-0,216] | DT | 2 | 194
  m5291 R nl [95 %] | 0,224 [0,201-0,249] | DT | 3 | 194
  m5292 R_DT/R_M nl [95 %] | 0,244 [0,225-0,264] | DT | 1 | 194
  m5293 R_DT/R_M nl [95 %] | 0,139 [0,126-0,152] | DT | 2 | 194
  m5294 R_DT/R_M nl [95 %] | 0,150 [0,135-0,165] | DT | 3 | 194
  m5295 R pipe | 1,429 | M | 1 | 200
  m5296 R pipe | 1,339 | M | 2 | 200
  m5297 R pipe | 1,417 | M | 3 | 200
  m5298 R pipe | 1,299 | C | 1 | 200
  m5299 R pipe | 1,331 | C | 2 | 200
  m5300 R pipe | 1,267 | C | 3 | 200
  m5301 R pipe | 0,657 | D | 1 | 200
  m5302 R pipe | 0,741 | D | 2 | 200
  m5303 R pipe | 0,807 | D | 3 | 200
  m5304 R pipe | 1,439 | CT | 1 | 200
  m5305 R pipe | 1,414 | CT | 2 | 200
  m5306 R pipe | 1,442 | CT | 3 | 200
  m5307 R pipe [95 %] | 1,172 [1,150-1,195] | DT | 1 | 200
  m5308 R pipe [95 %] | 1,014 [0,992-1,038] | DT | 2 | 200
  m5309 R pipe [95 %] | 1,124 [1,095-1,151] | DT | 3 | 200
  m5310 R_DT/R_M pipe [95 %] | 0,820 [0,804-0,836] | DT | 1 | 200
  m5311 R_DT/R_M pipe [95 %] | 0,758 [0,742-0,773] | DT | 2 | 200
  m5312 R_DT/R_M pipe [95 %] | 0,793 [0,775-0,811] | DT | 3 | 200
  m5313 R pipe Wiederholung frisch4 | 1,331 | M | 2 | 200
  m5314 R pipe Wiederholung frisch4 [95 %] | 1,018 [0,993-1,043] | DT | 2 | 200
  m5315 R_DT/R_M pipe Wiederholung frisch4 [95 %] | 0,765 [0,749-0,781] | DT | 2 | 200
  m5316 R nl2 | 0,363 | DT | 1 | 194
  m5317 R nl2 | 0,241 | DT | 2 | 194
  m5318 R nl2 | 0,198 | DT | 3 | 194
  m5319 R nl2 | 1,799 | D | 1 | 194
  m5320 R nl2 | 1,579 | D | 2 | 194
  m5321 R nl2 | 1,406 | D | 3 | 194
  m5322 R leer | 1,136 | DT | 1 | 200
  m5323 R leer | 0,990 | DT | 2 | 200
  m5324 R leer | 1,100 | DT | 3 | 200
  m5325 R leer | 0,696 | D | 1 | 200
  m5326 R leer | 0,755 | D | 2 | 200
  m5327 R leer | 0,827 | D | 3 | 200
  m5328 TP1 nl | 0,148 | DT | 1 | 194
  m5329 TP1 nl | 0,133 | DT | 2 | 194
  m5330 TP1 nl | 0,139 | DT | 3 | 194
  m5331 TP1 nl | 0,270 | M | 1 | 194
  m5332 TP1 nl | 0,277 | M | 2 | 194
  m5333 TP1 nl | 0,276 | M | 3 | 194
  m5334 Held-out 200 Fenster | 4,242 | M | 1 | 200
  m5335 Held-out 200 Fenster | 4,252 | M | 2 | 200
  m5336 Held-out 200 Fenster | 4,239 | M | 3 | 200
  m5337 Held-out 200 Fenster | 4,388 | CT | 1 | 200
  m5338 Held-out 200 Fenster | 4,441 | CT | 2 | 200
  m5339 Held-out 200 Fenster | 4,451 | CT | 3 | 200
  m5340 Held-out 200 Fenster | 4,495 | DT | 1 | 200
  m5341 Held-out 200 Fenster | 4,594 | DT | 2 | 200
  m5342 Held-out 200 Fenster | 4,569 | DT | 3 | 200
  m5343 Beleg-Anteil A | 0,181 | M | 1 | 120
  m5344 Beleg-Anteil A | 0,187 | M | 2 | 120
  m5345 Beleg-Anteil A | 0,197 | M | 3 | 120
  m5346 Beleg-Anteil A | 0,197 | CT | 1 | 120
  m5347 Beleg-Anteil A | 0,214 | CT | 2 | 120
  m5348 Beleg-Anteil A | 0,192 | CT | 3 | 120
  m5349 Beleg-Anteil A | 0,131 | DT | 1 | 120
  m5350 Beleg-Anteil A | 0,111 | DT | 2 | 120
  m5351 Beleg-Anteil A | 0,108 | DT | 3 | 120
Ergebnis e364 [2026-10-25 08:18]: teilweise
  Fazit: DITTO wirkt in der eigenen Engine genau auf die Wiederholungsformen, die es im Training sieht.

Mit Zeilenumbruch und Leerzeile in den Daten verschwindet die Selbstverstaerkung in der nl-Sonde vollstaendig:
- T1 3/3, R_DT 0,20-0,37, R_DT/R_M 0,14-0,24, alle Intervalle weit von der Schwelle.
- Der alte Arm D erfuellt T1 nicht (G 0/3). Also ist der Trenner (samt Fensterlage) die Ursache, isoliert.
- Die Frage aus ditto-reihe6 ist damit beantwortet: Es fehlte die Form, nicht das Budget und nicht die Engine.

Auf den nie trainierten Trenner " | " uebertraegt es sich nur als Daempfung:
- T2 dem Wortlaut nach 0/3, R_DT 1,01-1,17. Saat 2 ist knapp und wiederholt auf frisch4 mit 1,018 [0,993-1,043].
- Die Verhaeltnisbedingung (<= 0,9) ist dagegen 3/3 erfuellt: Die Kurve wird flach, faellt aber nicht.

Die Kosten sind in dieser Form nicht tragbar:
- Beleg-Anteil 0,55-0,72 von M (0,52-0,67 von CT), Held-out +6-8 % ueber M (DT-CT +2,5-3,5 %), beides 0/3.
- Das ist deutlich teurer als beim alten D (Beleg 0,73-0,86, Held-out +3-6 %).
- TP1 sinkt auf die Haelfte von M. TP4 faellt in nl sogar unter TP0.

Die naechste Frage ist deshalb "wie schonend", nicht mehr "ob": die Wirkung auf nl halten und TP1 und Beleg erhalten.
Naheliegende Hebel: Verlust erst ab Kopie 2 (AB 2, steckt nicht in lib D) oder ein schwaecheres lambda.
  Offen: - Schonende Variante (AB 2 oder lambda > 0,5) auf mix_t: haelt sie T1 bei Beleg >= 0,9 A_M?
- Uebertragung auf ungesehene Trenner braucht vermutlich mehr Formen im Training. Ungemessen.
- leer verschlechtert sich gegen D (R_DT 0,99-1,14 gegen 0,70-0,83): Verduennung durch die Mischung, nicht isoliert.
- D wirkt in pipe (0,66-0,81), DT nicht: Deutung ueber das lose "▁" nicht isoliert.
- Erzeugung (Beam) und prod512b ungemessen.
  Datei: rechner-a:~/snai_pruef/ditto2/ERGEBNIS_trenner.md
Chronik (juengste 8 von 9, voll=True zeigt alle):
  2026-10-24 21:21 Rezept r412
  2026-10-24 21:21 Status geplant -> laeuft (Rezept r412)
  2026-10-24 23:01 2026-10-24 21:29:37 rechner-a per Desktop-Sitzung neu gestartet (journal: reboot requested from xfce4-session), Trainings bei Schritt ~460/1568 und Text-Sonde bei M_s1 abgebrochen. 23:03 unveraendert neu gestartet; abgebrochene Logs/Messung in log/abgebrochen_2129, mess/abgebrochen_2129 (dienen als Determinismus-Kontrolle: neue Laeufe muessen bis Schritt 460 gleiche Verluste zeigen).
  2026-10-24 23:45 2026-10-24 23:41 rechner-a erneut aus (journal: Lid closed -> poweroff requested from xfce4-power-man). Gesichert: arme/CT_s1-3 (fertig 23:30, rc 0), Text-Sonde M_s1-3, D_s1-3 je 4 Formen, C_s1 nl. Verloren: DT_s1-3 bei Schritt ~600/1568, Rest der Messungen. Determinismus-Kontrolle bestanden: CT_s1-3 Verlust-/GradNorm-Zeilen bis Schritt ~460 md5-gleich dem abgebrochenen Lauf 21:29, M_s1 nl/pipe/nl2 bytegleich. Fortsetzung wartet auf Ruecksprache.
  2026-10-25 07:15 2026-10-25 ~00:00 auf Wunsch auf rechner-a fortgesetzt: trenner_dt.sh (= trenner.sh, nur DT trainiert, danach mess6 fuer CT und DT), alt_textmess2.sh (C_s1-3, Basis), neu_textmess.sh. Abgebrochenes in log/abgebrochen_2341, mess/abgebrochen_2341_tr_C_s1.
  2026-10-25 08:18 Messwerte m5277-m5351
  2026-10-25 08:18 Ergebnis e364: teilweise
  2026-10-25 08:18 Status laeuft -> ausgewertet (Ergebnis e364)
```
