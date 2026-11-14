# snai/gradnorm-batch

```text
snai/gradnorm-batch - ausgewertet, angelegt 2026-11-01, zuletzt 2026-11-02 12:10
Frage: Der Anstieg der Gradientennorm ist Rauschen (snai/gradnorm-zerlegung, e427). Aendert sich der Anstieg, wenn je Adam-Schritt mehr Fenster gesammelt werden, liegt das am Rauschen, an der Materialmenge oder am Clip, und was kostet oder bringt ein groesserer Batch auf dem Held-out?
Kriterium (festgelegt 2026-11-01 14:42, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/gradnorm/kriterien_batch.txt (mit Nachtrag). c128sr s4, LR 2,5e-4 fest, WD 0,1, 80.000 Fenster, r1-r3 gepaart. Arme k1, k4, k16, k16K (Clip-Schwelle 0,25), k16R (Vorrat 5.000 Fenster). GF = Norm je Einzelfenster, LR 0, k=1, train_a; A = GF - GF(s4). Gueltig: GF(k1) >= 1,10 x s4 bei U=5.000, >= 1,30 x bei U=20.000, je 3/3. Q = A(kx)/A(k1), k16 bei U=5.000, k4 bei U=20.000: SENKT <= 0,5, GLEICH [0,8; 1,25], HEBT >= 1,5, je 3/3, sonst OFFEN; knapp +-5 % nicht erfuellt. Clip-Trennung A(k16K)/A(k16), Material A(k16R)/A(k16): [0,8; 1,25] in 3/3 vermittelt nicht, <= 0,5 oder >= 1,5 in 3/3 vermittelt. Held-out-Gewinn: Unterschied ab 10 % des groesseren Gewinns und 0,01 nats in 3/3, sonst Gleichstand. Entscheidet nicht, ob hohe Norm schadet.
Plan: rechner-a:~/snai_pruef/gradnorm/kriterien_batch.txt
Baut auf: snai/gradnorm-zerlegung, snai/gradnorm-skala
Rezepte:
  r494 [2026-11-01] rechner-a: cd ~/snai_pruef/gradnorm && setsid -f nohup werkzeug/schlange_bs.sh > log/schlange_bs.out 2>&1 < /dev/null (je Lauf werkzeug/lauf_bs.sh proj_bs daten/<batch|batch16x>_<r>.txt <k> <schwelle|-> bs_<arm>_<r> <snapshots>)
      quelltext: lauf_bs.sh 35ae1acc, schlange_bs.sh 08351a32, patch_clip_accum.py 1a559f23; proj_bs = proj_gn + Patch, Lib dbbbf92d
      parameter: c128sr s4, LR 2,5e-4, WD 0,1, CPU 1 Thread, nice 8, 5 parallel, Gate 1400 MB; Daten train.txt ab Byte 21,6 Mio, 47,3 MB; k16R 2,95 MB x 16; Snapshots adam_t 771205, 786205. Startet nach SCHLANGE_DC_ENDE.
      seed: Reihenfolgen r1-r3 am Dateinamen, Arme je Reihenfolge gepaart; k16R eigene Datei, nicht fensterweise gepaart
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/gradnorm/log/bs_*
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/gradnorm/log/auswertung_bs.txt, log/nach_bs.txt (auswerten_bs.py 39dd0172)
  m7449 GF s4 | 2,9327 | s4 | - | 1710
  m7450 GF/s4 U5000 | 1,100/1,096/1,108 | k1 | r1/r2/r3 | 1710
  m7451 GF/s4 U20000 | 1,363/1,354/1,365 | k1 | r1/r2/r3 | 1710
  m7452 Q U20000 | 1,592/1,644/1,517 | k4 gegen k1 | r1/r2/r3 | 1710
  m7453 Q U5000 Beobachtung | 3,557/3,651/3,263 | k16 gegen k1 | r1/r2/r3 | 1710
  m7454 Q U5000 Beobachtung | 2,987/3,059/2,756 | k16K gegen k1 | r1/r2/r3 | 1710
  m7455 Q Material Enden Beobachtung | 0,427/0,413/0,425 | k16 gegen k1 | r1/r2/r3 | 1710
  m7456 Q Material Enden Beobachtung | 0,676/0,666/0,679 | k4 gegen k1 | r1/r2/r3 | 1710
  m7457 Q Material | 1,926/1,994/1,995 | k16R gegen k16 | r1/r2/r3 | 1710
  m7458 Q Clip | 0,840/0,838/0,845 | k16K gegen k16 | r1/r2/r3 | 1710
  m7459 Held-out Ende | 2,0367/2,0424/2,0372 | k1 | r1/r2/r3 | 700
  m7460 Held-out Ende | 1,9341/1,9349/1,9346 | k4 | r1/r2/r3 | 700
  m7461 Held-out Ende | 1,9237/1,9231/1,9242 | k16 | r1/r2/r3 | 700
  m7462 Held-out U5000 | 2,0383/2,0412/2,0410 | k16R | r1/r2/r3 | 700
  m7463 Held-out | 2,253 | s4 | - | 700
  m7464 Spearman Weg emb gegen GF, nachtraeglich | 0,981 | 36 Staende | - | 36
  m7465 Spearman RMS emb gegen GF, nachtraeglich | -0,017 | 36 Staende | - | 36
  m7466 Skala r1 Weg emb und GF, nachtraeglich | H 0,0476 GF 3,295; T 0,0080 GF 9,211 | gegenprobe | r1 | 1710
Ergebnis e442 [2026-11-02 12:10]: teilweise
  Fazit: Ob weniger Rauschen im Update den Normanstieg senkt, beantwortet die Reihe nicht: Linie U=5.000 ungueltig (k1 r2 1,096 unter 1,10), U=20.000 zahlenmaessig HEBT, aber knapp (r3 1,517), und MATERIAL TREIBT sperrt nach Kriterium die Zuschreibung an das Rauschen. Clip vermittelt nach Zahl nicht (Q 0,84), knapp an 0,8. Klar ist der Held-out: bei gleichem Material k4 und k16 rund 0,1 nats besser als k1, k16 gegen k4 Gleichstand. Nachtraeglich, ohne Vorab-Kriterium: Die Norm folgt in dieser Reihe weder Loss noch Gewichtsgroesse, sondern dem Weg vom Start (Spearman 0,98), aber nur bei fester LR: Skala-Arm H hat den groessten Weg und die kleinste Norm. Naechster entscheidender Versuch: k16 mit LR so, dass der Weg dem von k1 gleicht. Rezeptwechsel folgt daraus noch nicht, feste LR.
  Offen: Rauschen gegen Schaerfe gegen Weg nicht getrennt; frisches Datenstueck fuer U=20.000 nicht gefahren; k skaliert mit LR nicht gemessen; Abkuehlplan und prod512b nicht gemessen; GF schwankt zwischen fast gleichen Staenden bis 1,3 %, Bootstrap darum zu eng.
  Datei: rechner-a:~/snai_pruef/gradnorm/ERGEBNIS_batch.md
Chronik:
  2026-11-01 14:42 angelegt
  2026-11-01 14:46 Rezept r494
  2026-11-01 14:46 Status geplant -> laeuft (Rezept r494)
  2026-11-02 12:10 Messwerte m7449-m7466
  2026-11-02 12:10 Ergebnis e442: teilweise
  2026-11-02 12:10 Status laeuft -> ausgewertet (Ergebnis e442)
```
