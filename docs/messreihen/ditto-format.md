# snai/ditto-format

```text
snai/ditto-format - ausgewertet, angelegt 2026-10-24, zuletzt 2026-10-24 21:06
Frage: Erreicht DITTO (lambda 0,5, 6 Epochen, Endstaende aus ditto-reihe6) sein Trainingsziel (fallende TP-Kurve) im eigenen Trainingsformat (Kopien Token an Token ohne Trenner), so dass das Ausbleiben in ditto-reihe6 an der Uebertragung auf die Zeilenumbruch-Sonde liegt und nicht an der Engine?
Kriterium (festgelegt 2026-10-24 20:57, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/ditto2/kriterien_format.txt (mit Pruefer). Sonde sonde_trenn.php (eabb0444, ein Stellrad SNAI_SONDE_TRENN=leer, Rot-Probe gesehen, ohne Stellrad bytegleich zum Original), 200 frische Saetze saetze_frisch2.json (e6226f51), 9 Endstaende M/C/D x Saat 2/3/4 + Basis. Je Saat gepaart, 3/3 ja, 0/3 nein, sonst saatabhaengig. F1 (entscheidet): R_D = TP4/TP1 <= 1,0 UND R_D/R_M <= 0,9. F2 (stuetzt): Z_D <= 0,5 Z_M, ungueltig bei Z_M < 0,03. Knapp (Bootstrap-Intervall schliesst Schwelle ein) -> Wiederholung auf Kandidaten 450..649. F1 3/3 = "DITTO erreicht sein Ziel im Trainingsformat; Uebertragung auf Zeilenumbruch fehlt (Ursache nicht isoliert)" -> Reihe mit Trennern im Training. F1 0/3 = "wirkt auch im Format nicht" -> Engine-Stellrad (fp32, lambda). Offen gelegt: Geraeteprobe P3 (D_s2, alte 50 Saetze, Kurve faellt) vor dem Kriterium gesehen, entscheidet nicht mit.
Plan: Nur Messung, kein Training: 10 Sondenlaeufe a ~1,5 min auf rechner-a (OMP 2, 3 parallel). Auswertung mit Bootstrap ueber die Saetze.
Baut auf: snai/ditto-reihe6
Darauf baut: snai/ditto-trenner
Rezepte:
  r410 [2026-10-24] cd ~/snai_pruef/ditto2 && for k in 2 3 4; do setsid nohup bash format.sh $k & done; danach bash format.sh basis. Darin je Endstand: env SNAI_SONDE_TRENN=leer SNAI_GAIN_GUARD=0 SNAI_FORCE_CPU=1 OMP_NUM_THREADS=2 php ~/snai_pruef/ditto2/sonde_trenn.php <ckpt> 4 saetze_frisch2.json mess/<N>/schleife_leer.jsonl 200 (cwd merkmal/prodtest/proj_sr)
      quelltext: format.sh, sonde_trenn.php eabb0444 (patch_sonde.py 5efa29bb aus sonde_schleife.php 66bd83f4), saetze_frisch2.py 08add3a8 -> saetze_frisch2.json e6226f51, kriterien_format.txt f1c24d51; Auswertung boot6b-Muster
      parameter: Trenner leer, 5 Kopien, 200 Saetze (Kandidaten 250..449), Endstaende arme/<ARM>_s<k>_e6.snai (md5 wie ditto-reihe6), Basis drohneP_s19 170d4d3f
      seed: Saaten 2/3/4 der Endstaende; Satzauswahl Saat 20261023
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/ditto2/mess/<N>/schleife_leer.jsonl, log/format.log, geraet/ (Proben P1-P3)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ditto2/boot_format.py über mess/<N>/schleife_leer.jsonl (sonde_trenn.php eabb0444, SNAI_SONDE_TRENN=leer, saetze_frisch2.json e6226f51); Fehlerkanal 10/10 rc 0, 0 Meldungen, md5 10/10
  m5234 TP-Kurve Kopie 0..4 Trainingsformat | 0,088 / 0,307 / 0,369 / 0,400 / 0,418 | Basis |  | 200
  m5235 R = TP4/TP1 Trainingsformat | 1,363 | Basis |  | 200
  m5236 R = TP4/TP1 Trainingsformat | 1,273 / 1,265 / 1,268 | M | 2-4 | 200
  m5237 R = TP4/TP1 Trainingsformat | 1,338 / 1,335 / 1,292 | C | 2-4 | 200
  m5238 R = TP4/TP1 Trainingsformat [95-%-Bootstrap] | 0,667 [0,627-0,705] / 0,569 [0,527-0,613] / 0,525 [0,477-0,574] | D | 2-4 | 200
  m5239 TP-Kurve Kopie 0..4 Trainingsformat | S2 0,078/0,150/0,146/0,126/0,100; S3 0,080/0,132/0,124/0,102/0,075; S4 0,077/0,117/0,103/0,082/0,061 | D | 2-4 | 200
  m5240 F1 R_D/R_M [95-%-Bootstrap] | 0,524 [0,495-0,553] / 0,450 [0,419-0,482] / 0,414 [0,378-0,451] -> 3/3 ja, keine knapp | D | 2-4 | 200
  m5241 Z = TP4-TP1 Trainingsformat | D -0,0499 / -0,0568 / -0,0555; M 0,0840 / 0,0798 / 0,0818; C 0,2171 / 0,2143 / 0,1949 | alle | 2-4 | 200
  m5242 F2 Z_D/Z_M | -0,59 / -0,71 / -0,68 -> 3/3 ja (gueltig, Z_M >= 0,03) | D | 2-4 | 200
  m5243 Geraeteprobe P1/P2/P3 | P1 ohne Stellrad bytegleich; P2 Rot TP 0,004; P3 D_s2 50 alte Saetze 0,081/0,151/0,147/0,128/0,102 (vor Kriterium gesehen) | D | 2 | 50
Ergebnis e360 [2026-10-24 21:06]: erfuellt
  Fazit: Die Engine kann DITTO: Im Trainingsformat (Kopien ohne Trenner) faellt die TP-Kurve in 3/3 Saaten (R_D 0,53-0,67, R_D/R_M 0,41-0,52, weit unter den Schwellen), waehrend dieselben Modelle mit Zeilenumbruch-Trenner keine Wirkung zeigen (R_D/R_M 0,96-1,03 in ditto-reihe6). DITTO hat "wiederhole den Satz nicht direkt hinter sich selbst" gelernt, nicht "wiederhole dich nicht". Die Luecke aus ditto-reihe6 liegt damit nicht an Budget, Clipping oder int8, sondern an den Trainingsdaten mit nur einer Wiederholungsform; fuer prod512b fehlt genau die wichtige (Absatzschleifen mit Zeilenumbruch). Naechste Reihe: DITTO-Stuecke mit wechselnden Trennern, C/D gepaart, Messung mit beiden Sonden plus Beleg-Anteil.
  Offen: Ursache Trenner nicht isoliert (erst Training mit Trennern isoliert sie). Uebertragung auf ungesehene Formen und auf prod512b ungemessen. Auch im Trainingsformat daempft D die erste Kopie (TP1/TP0 1,5-1,9 gegen M 3,4), Kosten beim nuetzlichen Kopieren (Beleg) bleiben offen. Ohne Praefix-Kontext gemessen.
  Datei: rechner-a:~/snai_pruef/ditto2/ERGEBNIS_format.md
Chronik:
  2026-10-24 20:57 angelegt
  2026-10-24 20:57 Rezept r410
  2026-10-24 20:57 Status geplant -> laeuft (Rezept r410)
  2026-10-24 21:06 Messwerte m5234-m5243
  2026-10-24 21:06 Ergebnis e360: erfuellt
  2026-10-24 21:06 Status laeuft -> ausgewertet (Ergebnis e360)
```
