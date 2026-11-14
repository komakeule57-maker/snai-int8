# snai/par-schleifen

```text
snai/par-schleifen - ausgewertet, angelegt 2026-11-08, zuletzt 2026-11-08 23:03
Frage: Bringt die Parallelisierung der übrigen seriellen Positionsschleifen im int8-Trainingsschritt (trainStepI8Batched) Tempo, je Gruppe einzeln und alle zusammen, ohne das Training um ein Bit zu ändern?
Kriterium (festgelegt 2026-11-08 15:53, vor dem ersten Messwert):
  Aufbau: rechner-a, Arbeitskopie ~/snai_pruef/threads/par2, cortex.nim = patch_par2.py auf patch_par.py-Ausgabe 6de1a7fe (Herkunft cortex_orig f8292f7b = Projekt-Lib 1eb78bc1). Lauf wie arm.sh (prod512b-Umgebung, Basis prod512b_s11, text.txt 65b04081, 32 Schritte, fester Ausgabename out.snai). Stellrad allein SNAI_I8_PAR (fehlt = alle 9 Gruppen, 0 = keine = Originalpfad, sonst Liste aus att,sm,norm,qkv,ffn,ropebw,normbw,emb,vec).
(1) BYTEGLEICH (Bedingung für jedes Tempourteil): md5 6f49622c und Loss-md5 78355d24 mit allen Gruppen bei n=1,2,4,8 und mit SNAI_I8_PAR=0 bei n=4. Abweichung irgendwo = Reihe ungültig für die betroffene Gruppe (Bisektion über die Liste).
(2) ROT je Gruppe: SNAI_I8_PAR_ROT=<g> bei n=4, alle Gruppen an, muss md5 ändern. Bleibt eine grün, ist ihre Bytegleichheit nicht belegt (Sonde zählt nicht, Gruppe ohne Urteil).
(3) TEMPO bei n=4 (Produktionswert): ms/Schritt aus [Bilanz]. Arme: keine (0), jede der 9 Gruppen allein, att+sm (bisheriger Stand), alle. Je Arm 3 Läufe, Runden verschränkt (Rundenschleife außen, Arme innen). Je Arm Median der 3. Urteil je Arm gegen keine: Median ≤ 0,90 × keine = schneller; ≥ 1,10 × = langsamer; dazwischen Gleichstand. Gesamt: alle gegen keine und alle gegen att+sm, gleiche Regel. Bekanntes Rauschen zwischen Wiederholungen bis ~11 %, daher kein Einzellauf-Urteil; Einzelgruppen mit Gleichstand werden so berichtet. Nur berichtet: Zeit je Schritt n=1/2/8 aus den Bytegleich-Läufen neben den alten seriellen Bezugswerten 16.232/10.674/7.619 ms (andere Tageszeit, keine Vergleichsmessung).
Fehlerkanal: rc und .err je Lauf vor dem Lesen der Urteile; [PAR]-Zeile muss die gewünschten Gruppen nennen.
Baut auf: snai/att-fwd-par, snai/threads-skalierung
Darauf baut: snai/par-schleifen-fein
Rezepte:
  r629 [2026-11-08] setsid ~/snai_pruef/threads/par2/reihe.sh (ruft arm.sh <n> <etikett> [SNAI_I8_PAR=…|SNAI_I8_PAR_ROT=…]; darin php train_cluster.php text.txt out.snai 1 1 basis.snai 3 0.00005 0 1 0.1 mit prod512b-Umgebung)
      quelltext: patch_par2.py (Basis par/proj/cortex.nim 6de1a7fe) -> cortex.nim 1c3373bf, libcortex.so c18b7ed7 (nim -d:danger --threads:on -fopenmp --app:lib); arm.sh 20790e9b, reihe.sh 6ae19a00
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/par2/ergebnis.txt und log/
  r634 [2026-11-08] rot2: ~/snai_pruef/threads/par2r/rot2b.sh (wartet auf FEIN_ENDE, sonst wie rot2.sh; Etiketten rot2b_*, Kontrolle alle_n4_rotlib2b)
      quelltext: patch_rot2.py e68ff2a5 (mit Korrektur) auf cortex_par2r 69737e58 -> cortex.nim e24d2aa2, libcortex.so 794cc31a; rot2b.sh 15838c7e
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/par2r/ergebnis.txt
      notiz: Löst r632 ab. rot2 (19:28:26–19:28:57) lief nicht: alle 11 Läufe Exit 139 nach 3 s, auch die Kontrolle ohne ROT. Ursache im Patch, nicht im Prüfling: die Ersetzung 'a.rot and' -> 'rotM(a) and' traf auch die Definition von rotM (Endlosrekursion). Keine Messwerte aus rot2. Neu gebaut 19:30:02–19:30:18 mit nice 19, ÜBERLAPPT Lauf f0_att,sm der Feinmessung (Start 19:29:13).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/threads/par2/ergebnis.txt ([Bilanz] ms/Schritt, md5, Loss-md5)
  m9601 bytegleich md5/lossmd5 n1 | 6f49622c/78355d24 | alle |  | 1
  m9602 bytegleich md5/lossmd5 n2 | 6f49622c/78355d24 | alle |  | 1
  m9603 bytegleich md5/lossmd5 n4 | 6f49622c/78355d24 | alle |  | 1
  m9604 bytegleich md5/lossmd5 n8 | 6f49622c/78355d24 | alle |  | 1
  m9605 bytegleich md5/lossmd5 n4 | 6f49622c/78355d24 | keine |  | 1
  m9606 ms/Schritt n1 (nur berichtet) | 16434,1 | alle |  | 1
  m9607 ms/Schritt n2 (nur berichtet) | 10009,3 | alle |  | 1
  m9608 ms/Schritt n8 (nur berichtet) | 5949,1 | alle |  | 1
  m9609 rot md5 | d2cb372c (rot) | att |  | 1
  m9610 rot md5 | 90e591b6 (rot) | sm |  | 1
  m9611 rot md5 | 6f49622c (GRUEN, Sonde zu schwach) | norm |  | 1
  m9612 rot md5 | 2e026fbf (rot, nur Q) | qkv |  | 1
  m9613 rot md5 | 6f49622c (GRUEN, Sonde zu schwach) | ffn |  | 1
  m9614 rot md5 | 6f49622c (GRUEN, d_q an Position 0 exakt 0) | ropebw |  | 1
  m9615 rot md5 | 5a03bc7f (rot, nur Zeile) | normbw |  | 1
  m9616 rot md5 | e3cd53b8 (rot, nur Lookup) | emb |  | 1
  m9617 rot md5 | 927d3ada (rot, nur Addition) | vec |  | 1
  m9618 Median ms/Schritt n4 (9119,9/8466,3/8523,4) | 8523,4 | keine |  | 3
  m9619 Median ms/Schritt n4 (7483,0/6673,8/6699,7) | 6699,7 (0,786 x keine, schneller) | att |  | 3
  m9620 Median ms/Schritt n4 (8699,9/8863,5/8507,8) | 8699,9 (1,021, gleichstand) | sm |  | 3
  m9621 Median ms/Schritt n4 (8781,0/8427,4/8495,9) | 8495,9 (0,997, gleichstand) | norm |  | 3
  m9622 Median ms/Schritt n4 (8770,3/8390,0/8423,2) | 8423,2 (0,988, gleichstand) | qkv |  | 3
  m9623 Median ms/Schritt n4 (8373,4/8296,2/8032,4) | 8296,2 (0,973, gleichstand) | ffn |  | 3
  m9624 Median ms/Schritt n4 (8467,8/8455,2/8331,0) | 8455,2 (0,992, gleichstand) | ropebw |  | 3
  m9625 Median ms/Schritt n4 (8752,9/8394,8/8377,6) | 8394,8 (0,985, gleichstand) | normbw |  | 3
  m9626 Median ms/Schritt n4 (8431,6/8560,0/8541,9) | 8541,9 (1,002, gleichstand) | emb |  | 3
  m9627 Median ms/Schritt n4 (8826,8/8990,5/8383,2) | 8826,8 (1,036, gleichstand) | vec |  | 3
  m9628 Median ms/Schritt n4 (6586,4/6760,8/6775,3) | 6760,8 (0,793, schneller) | att,sm |  | 3
  m9629 Median ms/Schritt n4 (6367,3/6379,4/6248,4) | 6367,3 (0,747 x keine schneller; 0,942 x att,sm gleichstand) | alle |  | 3
  Quelle: rechner-a:~/snai_pruef/threads/par2r/ergebnis.txt (rot2b, Lib 794cc31a), 22:20–22:58
  m9641 bytegleich Rot-Lib ohne ROT | 6f49622c/78355d24 | alle_n4_rotlib2b |  | 1
  m9642 rot2b md5 | 7746f7de (rot) | norm |  | 1
  m9643 rot2b md5 | 0e4b8c9d (rot) | ropebw |  | 1
  m9644 rot2b md5 | 83ae353e (rot) | qkv K |  | 1
  m9645 rot2b md5 | 73237208 (rot) | qkv V |  | 1
  m9646 rot2b md5 | d67de71f (rot) | ffn Quant |  | 1
  m9647 rot2b md5 | 5b7e5a8c (rot) | ffn SiLU-Tabelle |  | 1
  m9648 rot2b md5 | 05bce630 (rot) | ffn SiLU-Ableitung |  | 1
  m9649 rot2b md5 | 09cb55df (rot) | emb Gradient |  | 1
  m9650 rot2b md5 | f6ff72f1 (rot) | vec Kopie |  | 1
  m9651 rot2b md5 | 69aa3a04 (rot) | normbw Gain-Summe |  | 1
Ergebnis e575 [2026-11-08 23:03]: teilweise
  Fazit: (1) Bytegleich bei 1/2/4/8 Threads mit allen Gruppen und mit SNAI_I8_PAR=0: erfüllt. (2) Rot: alle 9 Gruppen und alle Teilstücke rot, für norm/ffn/ropebw erst mit der Nachtrags-Sonde (+1,0; r634). (3) Tempo n4 gegen keine: att 0,786 und att+sm 0,793 schneller, alle 0,747 schneller; jede der 7 neuen Gruppen allein Gleichstand (0,97–1,04), sm allein Gleichstand; alle gegen att+sm 0,942 Gleichstand nach der 10-%-Regel. Die Feinmessung snai/par-schleifen-fein hat diesen Gleichstand aufgelöst: −6,1 % [5,2–7,0]. Fast der ganze Gewinn steckt in der Attention vorwärts; der Rest der seriellen Schleifen bringt zusammen gut 6 %. Nebenbefund für künftige Sonden: eine multiplikative Störung 1e-4 vor einer int8-Quantisierung wird verschluckt, und d_q an Position 0 ist exakt 0.
  Offen: Einzelbeiträge der sieben Gruppen unter 10 % nicht aufgelöst. Übernahme in den Hauptbaum offen.
Abgeloest und ausgeblendet: 3 rezept - voll=True zeigt sie.
Chronik (juengste 8 von 11, voll=True zeigt alle):
  2026-11-08 16:34 Rezept r630 (rot2)
  2026-11-08 16:41 Rezept r631 (rot2), loest r630 ab
  2026-11-08 16:53 Rezept r632 (rot2), loest r631 ab
  2026-11-08 19:30 Rezept r634 (rot2), loest r632 ab
  2026-11-08 19:31 Messwerte m9601-m9629
  2026-11-08 23:03 Messwerte m9641-m9651
  2026-11-08 23:03 Ergebnis e575: teilweise
  2026-11-08 23:03 Status laeuft -> ausgewertet (Ergebnis e575)
```
