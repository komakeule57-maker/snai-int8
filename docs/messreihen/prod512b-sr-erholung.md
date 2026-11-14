# snai/prod512b-sr-erholung

```text
snai/prod512b-sr-erholung - ausgewertet, begonnen 2026-10-19, angelegt 2026-10-21, zuletzt 2026-10-23 14:38
Frage: Erholt sich prod512b nach dem Wechsel auf 8-Bit-Adam-Momente mit zufälligem Runden (SR) ab Segment 3, das heißt: liegt der Held-out nach s4 unter dem von s2 (letztes Segment mit float-Momenten)?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/prodtest/kriterien_prodtest.txt Abschnitt ERHOLUNGSREGEL (Zeitstempel im Text 2026-10-19 07:20, 'festgelegt VOR Ende von Segment 2'; Ende s2 2026-10-19 15:19) und eine Fassung vom 2026-10-19 05:17. Datei zuletzt geändert 2026-10-21 14:29 (Helfer merkmal arbeitet darin).):
  Nach s4 gilt ERHOLT, wenn Held-out s4 < Held-out s2; NICHT ERHOLT, wenn s4 >= s2, dann zurückspulen auf s2 und mit float-Momenten weiter. Nach s3 nur Zwischenstand (s3 schlechter als s2 allein kein Grund). Sofort melden: Segmentprüfung s3 ROT, NaN/Fatal im Log, Held-out s3 >= 10 % über s2. Messgröße heldout_full_loss der Segmentprüfung (64 Fenster, ho_prod.txt). Grenze: kein Parallelarm ohne SR, 'erholt' heißt nur netto Fortschritt.
Plan: rechner-a:~/snai_pruef/merkmal/prodtest/kriterien_prodtest.txt
Baut auf: snai/prod512b-lauf
Rezepte:
  r230 [2026-10-21] SR ab s3: PROD_DECAY=401012 bash run_prod512b_server.sh (Dienst snai-train); je Segment: SNAI_TRAIN_MODE=pretrain SNAI_TIE_EMBEDDINGS=1 SNAI_INT8_FULL=1 SNAI_FORCE_CPU=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=401012 SNAI_LR_MIN_RATIO=0.1 SNAI_TELEMETRY_STEPS=100 OMP_NUM_THREADS=4 php train_cluster.php factory/segments_prod/psegNN.txt factory/checkpoints/prod512b_sNN.snai 1 1 <Basis> 3 0.0001 0 1 0.1 (laut ps 2026-10-21); Held-out eval_held_out_full_i8.php … factory/holdout_prod/ auto 64; Segmentprüfung tools/segment_ampel.py
      quelltext: vserver:~/snai_prod512b, Stand 2026-10-21: run_prod512b_server.sh md5 0d30553e…, train_worker.php 0abdb805… (seit 2026-10-19), libcortex.so 318b2655… (SR-Bibliothek, seit 2026-10-18), cortex.nim 2363b610…; beim Start 2026-10-10: libcortex.so d278e63b… (lauf.log). Änderungen im Lauf: Revival aus ab Ende s0, WD auf Embeddings an (wirkte durchgehend), Adam-Momente float32 ab s2, SR der 8-Bit-Momente ab s3
      parameter: 512/6/8, ffn 2048, ctx 1024, neues Vokabular f020d0ca (Byte-Rückfall), gebunden, int8 voll, 1 Arbeiter, LR 0,0001, Warmup 500, Cosinus bis 401.012 Schritte (Boden 0,1), WD 0,1; 40 bereinigte Segmente, bereinigter Prüfsatz (577 Fenster)
      seed: Genesis prod512_genesis.snai (327.235.612 Bytes, 8 Köpfe); Start-Offset per Darwin-Patch aus Host-Entropie
      rechner: vserver (Xeon E5-2699 v4, 4 Kerne)
      logs: vserver:~/.cache/prod512b/lauf.log, sN.log, pruefung_sN.txt, heldout_sN.txt, pruefung/verlauf.jsonl
      notiz: Einsatz SR: libcortex.so 318b2655 seit 2026-10-18, Worker-Vorgabe 8-Bit-Momente + SNAI_I8_MOM_SR=mv seit 2026-10-19 (train_worker.php 0abdb805…); Rückweg train_worker.php.vor_scharf_20261019 (f3e76849, float-Momente)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: vserver:~/.cache/prod512b/heldout_s1.txt, heldout_s2.txt, abgelesen 2026-10-21
  m2589 Held-out (Vergleichswert, float-Momente) | 3,89482 | prod512b s2 |  | 64
  m2590 Held-out | 4,0726 | prod512b s1 |  | 64
  Quelle: rechner-a:~/snai_pruef/merkmal/prodtest/kriterien_prodtest.txt, Abschnitt ZWISCHENSTAND s3 (2026-10-21), nicht selbst nachgelesen auf vserver
  m2591 Held-out (erstes SR-Segment, Zwischenstand) | 3,7483 (-3,8 % gegen s2) | prod512b s3 |  | 64
  m2592 SOFORT-Schwelle Held-out s3 (s2 + 10 %) | 4,284, nicht erreicht | prod512b s3 |  | 64
  m2593 Fehlerkanal s3.log NaN/Fatal/NET2NET-GUARD | 0 | prod512b s3 |  | 1
  m2594 Segmentprüfung | GELB (nur luecke 0,1888) | prod512b s3 |  | 1
  Quelle: vserver:~/.cache/prod512b/heldout_s4.txt (HELDOUT_FULL_LOSS), pruefung/prod512b_s4.ampel.txt, s4.log, abgelesen 2026-10-23
  m4784 Held-out | 3,6457 (-6,4 % gegen s2) | prod512b s4 |  | 64
  m4785 Fehlerkanal s4.log NaN/Fatal/NET2NET-GUARD | 0 | prod512b s4 |  | 1
  m4786 Segmentprüfung | GRÜN (alle 19 Größen), Lücke -0,1634, Kopierrate 0,2607 | prod512b s4 |  | 1
Ergebnis e338 [2026-10-23 14:38]: erfuellt
  Fazit: ERHOLT nach der Vorab-Regel. Held-out s4 3,6457 liegt unter s2 3,89482 (-6,4 %), das Fehlerprotokoll ist sauber, die Segmentprüfung ist ganz grün. Das gelbe Signal von s3 (Lücke 0,19) ist verschwunden. Die 8-Bit-Momente mit zufälligem Runden bleiben, ein Zurückspulen auf s2 entfällt. Der Lauf geht mit s5 weiter (gestartet 2026-10-23 14:24).
  Offen: "Erholt" heißt nur, dass es netto vorangeht. Ohne Parallelarm mit float-Momenten bleibt offen, ob SR langsamer lernt als float. Die Lücke ist von +0,19 auf -0,16 umgeschlagen; ob das am Segmentinhalt liegt (pseg04 schwerer als der Prüfsatz), ist nicht geprüft.
Chronik (juengste 8 von 9, voll=True zeigt alle):
  2026-10-21 19:37 Rezept r230 (SR ab s3)
  2026-10-21 19:37 Status geplant -> laeuft (Rezept r230)
  2026-10-21 19:37 Messwerte m2589, m2590
  2026-10-21 19:37 Messwerte m2591-m2594
  2026-10-21 19:37 wird im Zweig 'Projekt Snai int8 LoRa' weitergeführt; nächster Messpunkt s4 (~2026-10-23)
  2026-10-23 14:38 Messwerte m4784-m4786
  2026-10-23 14:38 Ergebnis e338: erfuellt
  2026-10-23 14:38 Status laeuft -> ausgewertet (Ergebnis e338)
```
