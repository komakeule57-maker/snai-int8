# snai/threads-skalierung

```text
snai/threads-skalierung - ausgewertet, angelegt 2026-11-08, zuletzt 2026-11-08 14:22
Frage: Warum bringen mehr als 1 Thread bei prod512b-Geometrie (512/6/8, ctx 1024, int8 voll, gebunden, 1 Arbeiter) kaum Geschwindigkeit? Teilfragen: (1) Wie skaliert die Schrittzeit 1/2/4/8 Threads auf rechner-a? (2) Ist die Wartepolitik OMP_WAIT_POLICY=PASSIVE (in 5 PHP-Dateien fest gesetzt) eine Ursache? (3) Wo steht der Hauptthread, waehrend die Helfer warten (gdb-Stichproben)?
Kriterium (festgelegt 2026-11-08 12:39, vor dem ersten Messwert):
  Messung: ms je Schritt aus der [Bilanz]-Zeile von train_cluster.php (wie snai/prod512b-schrittzeit), Kopie ~/snai_pruef/threads/proj = Hauptbaum c292c82 mit EINEM Stellrad (putenv OMP_WAIT_POLICY nur, wenn nicht gesetzt), Lib 1eb78bc1, Basis prod512b_s11, 120 KB pseg39, Umgebung wie prod512b auf vserver, rechner-a ohne andere Last. Je Zelle 2 Laeufe (Zeit ist Wanduhr, keine Saat; zweiter Lauf = Wiederholung), Wert = Mittel. GUELTIG nur, wenn md5 des Ergebnisses in allen Zellen gleich ist (Bytegleichheit ueber Threadzahl und Politik, bekannt aus snai/adam-parallel). (1) Skalierung S(n)=t(1)/t(n); 'skaliert' ab S(4) >= 2,0, 'skaliert schwach' 1,1 bis 2,0, 'Gleichstand' unter 1,1 (10 %-Regel). (2) PASSIVE ist Ursache, wenn ACTIVE bei 4 Threads um >= 10 % schneller ist (t_PASSIVE/t_ACTIVE >= 1,10) in beiden Laeufen; unter 10 % Gleichstand = keine Ursache. (3) gdb: >= 100 Stichproben bei 4 Threads PASSIVE; Anteil der Stichproben, in denen KEIN Helfer in einer Rechenfunktion steht (alle in futex/GOMP-Warten) = serieller Anteil; nur Beobachtung, kein Urteil.
Baut auf: snai/prod512b-schrittzeit, snai/vserver-worker-skalierung
Darauf baut: snai/att-fwd-par, snai/par-schleifen
Rezepte:
  r627 [2026-11-08] wie r626, aber arm.sh mit festem Ausgabenamen out.snai
      quelltext: arm.sh neu (fester Name), reihe.sh ed60dca6, stich.sh 0b5f2b64, sonst wie r626
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/ergebnis.txt, log/
      notiz: ABWEICHUNG vor jedem Urteil: In r626 trug jeder Lauf einen eigenen Ausgabenamen; die Saat (Fensterreihenfolge) haengt am Chunk-Pfad, daher md5 probe (n4) d4e4564a != n1 6d51069e - Skriptfehler, kein Engine-Befund. Probe und n1_w1 verworfen (ergebnis_verworfen_namenssaat.txt, log_verworfen/), Reihe 2026-11-08 ~13:00 mit festem Namen neu gestartet. Kriterium unveraendert.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: Quelle | rechner-a:~/snai_pruef/threads/ergebnis.txt ([Bilanz]) und log/*.log (Zeitstempel der Schrittzeilen 2->30 fuer den ACTIVE-Vergleich), Fehlerkanal .err 0 Zeilen in allen 13 Laeufen
  m9553 ms je Schritt n=1 PASSIVE | 15.817,8 / 16.646,3 (Mittel 16.232) | n1 |  | 2
  m9554 ms je Schritt n=2 PASSIVE | 10.675,8 / 10.672,7 (Mittel 10.674) | n2 |  | 2
  m9555 ms je Schritt n=4 PASSIVE | 9.104,0 / 8.127,8 (Mittel 8.616) | n4 |  | 2
  m9556 ms je Schritt n=8 PASSIVE | 7.800,9 / 7.436,3 (Mittel 7.619) | n8 |  | 2
  m9557 S(2) / S(4) / S(8) | 1,52 / 1,88 / 2,13 | PASSIVE |  | 2
  m9558 md5 Ergebnis alle PASSIVE-Laeufe | 6f49622c in 9/9 (n1,n2,n4,n8 je 2 + Stichprobenlauf) | PASSIVE |  | 9
  m9559 ACTIVE rc | 1 in 4/4: Worker Exitcode 139 NACH dem Sichern (bekannter libgomp-Abgang), kein md5 | ACTIVE |  | 4
  m9560 Loss Schritt 1/2/30 ACTIVE = PASSIVE | 3.768731 / 3.330162 / 3.525369 in allen 9 geprueften Logs | alle |  | 9
  m9561 s je Schritt aus Zeitstempeln 2->30, n=4 PASSIVE / ACTIVE | 9,04 / 8,07 gegen 9,18 / 7,43 (Mittel 8,56 gegen 8,31, Verhaeltnis 1,03) | n4 |  | 2
  m9562 s je Schritt aus Zeitstempeln 2->30, n=8 PASSIVE / ACTIVE | 7,75 / 7,36 gegen 7,64 / 7,04 (Mittel 7,56 gegen 7,34, Verhaeltnis 1,03) | n8 |  | 2
  m9563 CPU user/real n=1/2/4/8 PASSIVE (w1) | 0,99 / 1,58 / 2,32 / 3,35 | PASSIVE |  | 1
  m9564 CPU user/real n=4/8 ACTIVE (w1) | 3,92 / 7,79 (Helfer drehen, Stellrad wirkt) | ACTIVE |  | 1
  m9565 gdb-Stichproben | 0/120 verwertbar: ptrace_scope=1, gdb darf nicht anhaengen; Fehlerkanal verworfen - Sonde nie gruen gesehen | stich |  | 120
  Quelle: Quelle | rechner-a:~/snai_pruef/threads/cg.out (valgrind callgrind 3.25.1, OMP 1, 3 Schritte, 8 KB Text, cg.sh), callgrind_annotate; NACHTRAG statt der gescheiterten gdb-Stichproben, nur Beobachtung
  m9566 Befehle gesamt (Ir) | 382,4 Mrd. (3 Schritte samt Laden/Speichern) | cg |  | 1
  m9567 Anteil in OpenMP-Regionen (GOMP_parallel inklusive) | 77,3 % | cg |  | 1
  m9568 Anteil trainStepI8Batched inklusive | 90,3 % | cg |  | 1
  m9569 Anteil trainStepI8Batched selbst (serieller Rumpf) | 17,0 % | cg |  | 1
  m9570 Anteil Attention rueckwaerts (snai_att_bw_head, parallel nur ueber 8 Koepfe) | 42,5 % | cg |  | 1
  m9571 Anteil matMulTBatchedI8 / matMulBatchedI8 (parallel) | 15,9 % / 7,1 % | cg |  | 1
  m9572 Amdahl-Anpassung aus n1/n2 (t = s + p/n) | s 5,1 s, p 11,1 s (serieller Anteil 31 % der Zeit); Vorhersage n4 7,9 s gemessen 8,6, n8 6,5 gemessen 7,6 | Rechnung |  | 2
Ergebnis e571 [2026-11-08 14:22]: teilweise
  Fazit: Gueltig (md5 6f49622c in 9/9 PASSIVE-Laeufen, Fehlerkanal leer). (1) SKALIERT SCHWACH: S(2) 1,52, S(4) 1,88, S(8) 2,13 bei prod512b-Geometrie auf rechner-a. (2) PASSIVE IST KEINE URSACHE: ACTIVE ist bei 4 und 8 Threads 3 % schneller (Gleichstand), rechnet dieselben Loss-Werte, stuerzt aber beim Beenden mit 139 ab (bekannter libgomp-Abgang) - PASSIVE bleibt. Die frueheren Werte 'Threads bringen nichts' (8 % auf vserver) gelten fuer die 4-vCPU-VM; auf 6 echten Kernen bringen 4 Threads Faktor 1,9, mehr nicht. (3) gdb-Sonde ausgefallen (ptrace_scope=1), ersetzt durch callgrind (Beobachtung): 77 % der Befehle laufen in parallelen Regionen, der serielle Rumpf von trainStepI8Batched traegt 17 %; die Amdahl-Anpassung gibt rund 31 % serielle ZEIT (5,1 von 16,2 s). Deutung, nicht gemessen: Im seriellen Rumpf steckt vor allem die Attention VORWAERTS (Schleife ueber 1.024 Positionen ohne ||, ueberschlagen ~3,2 Mrd. MAC je Schritt, etwa die Haelfte des Rumpfs), dazu Softmax ueber 8.192 Woerter je Position, RMSNorm und Quantisierung je Position. Der groesste parallele Block (Attention rueckwaerts, 42 %) ist nur ueber 8 Koepfe verteilt - ab 8 Threads ist dort Schluss. Ueber Amdahl hinaus verliert n4/n8 weitere ~10-15 % (Speicherbandbreite oder Hyperthreading, nicht getrennt). Naechster Schritt mit Aussicht: Attention vorwaerts und die Schleifen je Position parallelisieren, bytegleich pruefen, dann messen; Schaetzung nach Amdahl bei 4 Threads etwa 1,5-fach schneller.
  Offen: Zeitanteile je Funktion nicht gemessen (callgrind zaehlt Befehle, keine Zeit, und hat keine Zeilenzuordnung ohne -g). Bandbreite gegen Hyperthreading nicht getrennt. vserver (VM, 4 vCPU) und rechner-b nicht gemessen.
Abgeloest und ausgeblendet: 1 rezept - voll=True zeigt sie.
Chronik:
  2026-11-08 12:39 angelegt
  2026-11-08 12:44 Rezept r626
  2026-11-08 12:44 Status geplant -> laeuft (Rezept r626)
  2026-11-08 12:53 Rezept r627, loest r626 ab
  2026-11-08 14:03 Messwerte m9553-m9565
  2026-11-08 14:22 Messwerte m9566-m9572
  2026-11-08 14:22 Ergebnis e571: teilweise
  2026-11-08 14:22 Status laeuft -> ausgewertet (Ergebnis e571)
```
