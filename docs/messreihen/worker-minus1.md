# snai/worker-minus1

```text
snai/worker-minus1 - ausgewertet, angelegt 2026-11-16, zuletzt 2026-11-16 07:11
Frage: Bricht train_worker.php nach dem Patch ab (Meldung, rc != 0, kein Checkpoint), wenn der Trainingsschritt -1 (FATAL der Engine) zurueckgibt, auch nach gelungenen Schritten - und bleibt jeder normale Lauf bytegleich?
Kriterium (festgelegt 2026-11-16 07:05, vor dem ersten Messwert):
  Volltext docs/messreihen/fullint8/KRITERIEN_TW.txt (md5 nach Nachtrag Zweitmeinung, siehe Rezept). tw = Hauptbaum 6539a6c + patch_tw.py (eine Stelle in train_worker.php: if ($loss < 0) Meldung + exit(1), vor der NaN-Pruefung). Rot-Werkzeug twrot/twrot_alt = Lib 024c34f6 (Stufe-12-Sperre aus Lauf 1, gibt -1 zurueck), nachgebaut. K1 Rot vorher: twrot_alt (alter Worker) GANZ=12 + SNAI_GZ_GFREI_ROT=1 Genesis-Kurzlauf -> rc 0 + Checkpoint (Fehler reproduziert), Zahl der FATAL-Meldungen berichtet; sonst Probe ungueltig. K2 Rot nachher: twrot (neuer Worker), gleicher Aufruf -> Zeile "Trainingsschritt verweigert", keine andere Worker-[Fatal]-Zeile, kein Absturz, rc != 0, Master bricht ab, kein Checkpoint. K3 Normalfall bytegleich (tw, Lib dca24a87): Kurzlauf GANZ=0 0f79d04c, 2 Worker GANZ=0 3eb4a5f8, Segment 0 GANZ=0 7063ce99, Kurzlauf GANZ=12 759ba426, 2 Worker GANZ=12 36fba098, Fortsetzung GANZ=12 389a20ff, keine neue Fatal-Zeile. Erfuellt = K1-K3. Float-Pfad nur ueber den Code.
Baut auf: snai/fullint8-st12-gfrei
Rezepte:
  r735 [2026-11-16] cd ~/snai_pruef/fullint8 && ./tw_proben.sh
      quelltext: tw = proj_hb (Hauptbaum 6539a6c) + patch_tw.py 33fdafc0 -> train_worker.php e92038a9, Lib dca24a87; twrot = tw mit Lib 024c34f6 (bau_twrot: st11/cortex.nim b9263995 + patch_gfrei_6c305248.py.bak -> e850a14d, cortex_gz ae179d20, Nachbau ergab exakt 024c34f6); twrot_alt = proj_hb mit Lib 024c34f6 und altem train_worker 4732351c; tw_proben.sh 6dc9fbd1, probe_iso_basis.sh 2fc813aa; KRITERIEN_TW.txt 5784221a
      parameter: Knirps 96x2 gebunden, Kurzlauf (232 Schritte) 1 Faden, Segment 0 2 Faeden, REST=sr, nice 15
      seed: s1
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/fullint8/log/tw.log, log/TW_*.log, ergebnis/TW_*.snai
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/fullint8/log/tw.log, log/TW_*.log, ergebnis/TW_*.snai (Lauf 07:06-07:11; KRITERIEN_TW.txt nach Uhrzeit-Korrektur im Kopf 7923e002, Inhalt der Kriterien unveraendert gegen 5784221a)
  m11728 K1 Rot vorher: alter Worker 4732351c, Lib 024c34f6, GANZ=12 + SNAI_GZ_GFREI_ROT=1, Genesis-Kurzlauf | rc 0, Checkpoint 563a6f3a (= Lauf 1 der Stufe 12), STEPS_DONE=232, dabei 231 FATAL-Meldungen der Sperre (231 von 232 Schritten still verweigert) -> Fehler reproduziert | twrot_alt | 1 | 1
  m11729 K2 Rot nachher: neuer Worker e92038a9, Lib 024c34f6, gleicher Aufruf | rc 1, kein Checkpoint, Zeile "Trainingsschritt verweigert (Rueckgabe -1 ...) bei Step 2", keine andere Worker-[Fatal]-Zeile, kein Absturz, Master "Worker 0 ist abgestuerzt (Exit-Code: 1). Breche Epoche sofort ab" -> bestanden | twrot | 1 | 1
  m11730 K3 Normalfall neuer Worker, Lib dca24a87: Kurzlauf GANZ=0 / 2 Worker GANZ=0 / Segment 0 GANZ=0 | 0f79d04c / 3eb4a5f8 / 7063ce99 (= Bezug), rc 0, keine neue Fatal-Zeile | tw | 1 | 3
  m11731 K3 Normalfall neuer Worker: Kurzlauf GANZ=12 / 2 Worker GANZ=12 / Fortsetzung GANZ=12 | 759ba426 / 36fba098 / 389a20ff (= Bezug), rc 0, keine neue Fatal-Zeile | tw | 1 | 3
  m11732 Uebernahme Hauptbaum | train_worker.php e92038a9 (= tw), alle Code-Dateien von tw bytegleich zum Hauptbaum; lokal committet 919bacc, nicht gepusht | Hauptbaum | 1 | 1
Ergebnis e696 [2026-11-16 07:11]: erfuellt
  Fazit: Der Worker bricht jetzt laut ab, wenn die Engine einen Schritt verweigert, statt still mit uebersprungenen Schritten einen Checkpoint zu schreiben. Die Rot-Probe zeigt, wie gross der Mangel war: Mit dem alten Worker entstand ein normal aussehender Checkpoint, obwohl 231 von 232 Schritten nicht gerechnet wurden. Normale Laeufe aendern sich um kein Byte. Damit sind alle FATAL-Wege der Engine, die -1 zurueckgeben, im Worker abgesichert; die quit(1)-Loesung der Stufe-12-Sperre bleibt richtig, ist aber nicht mehr die einzige Sicherung.
  Offen: Float-Pfad (cortex_train_step) nur ueber dieselbe Zeile abgedeckt, nicht eigens gefahren. Andere Aufrufer von train_step_i8 ausserhalb train_worker.php (Diagnose-Skripte) nicht geprueft.
  Datei: docs/messreihen/fullint8/KRITERIEN_TW.txt
Chronik:
  2026-11-16 07:05 angelegt
  2026-11-16 07:06 Rezept r735
  2026-11-16 07:06 Status geplant -> laeuft (Rezept r735)
  2026-11-16 07:11 Messwerte m11728-m11732
  2026-11-16 07:11 Ergebnis e696: erfuellt
  2026-11-16 07:11 Status laeuft -> ausgewertet (Ergebnis e696)
```
