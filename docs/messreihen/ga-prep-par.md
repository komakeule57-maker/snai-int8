# snai/ga-prep-par

```text
snai/ga-prep-par - ausgewertet, angelegt 2026-11-08, zuletzt 2026-11-09 03:29
Frage: Wird der Trainingsschritt schneller, wenn die seriellen Vorstufen der int8-Gradientenakkumulation (Spalten-/Zeilenskalen, Quantisierung, Paarpacken) parallel laufen, bytegleich?
Kriterium (festgelegt 2026-11-08 23:33, vor dem ersten Messwert):
  Lib par4 (patch_par4.py auf cortex_par3 d1f83d2e -> 96cb5b6d, libcortex.so 5a8676fc), Stellrad SNAI_I8_GA (fehlt = parallel, 0 = Original). In beiden Armen MM-Blockpfad und alle 9 PAR-Gruppen an.
(1) BYTEGLEICH: md5 6f49622c/78355d24 mit GA parallel bei n=1,2,4,8 und mit SNAI_I8_GA=0 bei n4. Sonst ungültig.
(2) ROT je n4: ROTI (isc), ROTQ (qi), ROTD (dsc, beide Procs zugleich), ROTP (pk, beide Procs zugleich) müssen md5 ändern. Einschränkung vorab: ROTD/ROTP prüfen gradAccumBatchedQI8 nicht getrennt; ob QI8 in diesem Lauf überhaupt gerufen wird, wird nicht gezeigt — dafür gilt nur die Bytegleichheit.
(3) TEMPO n4: 12 Blöcke A = SNAI_I8_GA=0, B = parallel, direkt nacheinander AB/BA, ms/Schritt [Bilanz], gepaartes t-Intervall 95 % auf log(B/A). Intervall ganz unter 1 = schneller, ganz über 1 = langsamer, sonst nicht aufgelöst (mit Breite).
Nur berichtet: Zeitsonde gA bei n4 und n1 in B.
Läuft nach REIHE3_ENDE von snai/mm-fwd-blk (keine Überlappung).
Baut auf: snai/mm-fwd-blk, snai/zeitsonde-i8
Rezepte:
  r639 [2026-11-08] ~/snai_pruef/threads/par4/reihe4.sh (wartet auf REIHE3_ENDE; g_* Bytegleich/Rot, gz_* Zeitsonde, q<b>_ga0/_gap 12 Blöcke AB/BA)
      quelltext: patch_par4.py -> cortex.nim 96cb5b6d, libcortex.so 5a8676fc; arm.sh dc016fc1; reihe4.sh 6017ce73
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/par4/ergebnis.txt, log/
      notiz: Bau 23:31–23:33 mit nice 19 während b_alle_n1 von snai/mm-fwd-blk (Bytegleich-Lauf, Zeit dort nicht gewertet). Bekannter Schönheitsfehler arm.sh: grep ZEIT holt bei Läufen mit Sonde auch die [ZEIT]-Schrittzeilen in ergebnis.txt; rc= steht dann am Ende des Blocks. Betrifft nur z*/gz*-Läufe, nicht die Tempo-Blöcke.
Messwerte (Groesse | Wert | Arm | Start | n):
  m9696 bytegleich n1/n2/n4/n8 parallel + GA=0 n4 | 6f49622c/78355d24 alle 5 | Einzelläufe n1 15331,3 n2 8209,6 n4 5158,5 n8 4242,9 ms; GA=0 n4 5703,3 ms
  m9697 rot ROTI | afa48b9c/738c9b17 | rot
  m9698 rot ROTQ | e05b84f6/c920f13e | rot
  m9699 rot ROTD | 6bfcee83/51881800 | rot
  m9700 rot ROTP | f9cb579b/9f060bfb | rot
  m9701 tempo gap/ga0 n4 12 Blöcke | 0,9377 | 95%-t-Intervall [0,9270-0,9484], B schneller 12/12, Streuung je Block 1,8 %; Mittel A 5672,7 B 5318,8 ms/Schritt; 24/24 bytegleich rc=0, Fehlerkanal 35/35 leer
  m9702 tempo Blockwerte ga0 q0-q11 | 5530,0 5634,1 5778,9 5524,6 5584,1 5773,4 5599,5 5725,6 5633,5 5625,0 5788,7 5874,4 | ms/Schritt
  m9703 tempo Blockwerte gap q0-q11 | 5205,9 5327,4 5292,0 5334,6 5267,0 5204,7 5250,2 5348,7 5336,1 5352,7 5454,1 5451,7 | ms/Schritt
  m9704 zeitsonde gz_n4 (nur berichtet) | gA 439 ms, ges 5416 ms | mmF 287 mmT 808 attF 572 attB 2396 adam 363; par3-Stand z_n4_mm1: gA 882, ges 5736
  m9705 zeitsonde gz_n1 (nur berichtet) | gA 1292 ms, ges 15590 ms | mmF 921 mmT 2334 attF 1801 attB 6803 adam 968
Ergebnis e578 [2026-11-09 03:29]: erfuellt
  Fazit: (1) bytegleich bei n1/2/4/8 und GA=0, (2) alle vier Rot-Proben rot, (3) Tempo n4: gap/ga0 0,9377 [0,927-0,948], 12/12 Blöcke, also SCHNELLER um ~6 %. Zeitsonde: gA bei n4 0,88 -> 0,44 s (Skalierung n1->n4 1,7 -> 2,9). Fazit: Die Vorstufen waren der serielle Bremsklotz der Gradientenakkumulation; mit ihnen ist gA kein Thema mehr. Größter Restposten ist jetzt die Attention rückwärts (2,4 s = 44 % des Schritts, skaliert schon 2,8x), danach mmT (0,81 s). Weitere Gewinne dort brauchen weniger Arbeit oder bessere Speichernutzung, nicht mehr Threads. Einschränkung: ob gradAccumBatchedQI8 in diesem Lauf gerufen wird, ist nicht gezeigt (nur Bytegleichheit). Nächster Schritt: direkte gepaarte Messung Hauptbaum 1eb78bc1 gegen den neuen Stand, dann Übernahme nach Auftrag.
Chronik:
  2026-11-08 23:33 angelegt
  2026-11-08 23:33 Rezept r639
  2026-11-08 23:33 Status geplant -> laeuft (Rezept r639)
  2026-11-09 03:29 Ergebnis e578: erfuellt
  2026-11-09 03:29 Status laeuft -> ausgewertet (Ergebnis e578)
  2026-11-09 03:29 Messwerte m9696-m9705
```
