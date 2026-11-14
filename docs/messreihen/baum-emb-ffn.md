# snai/baum-emb-ffn

```text
snai/baum-emb-ffn - ausgewertet, angelegt 2026-11-03, zuletzt 2026-11-03 10:21
!! ohne Rezept
Frage: Lassen sich der Embedding-Eingangsfaktor (ans Modell gebunden, V7 Flags Bit 1) und das Überspringen genullter FFN-Zweige so in den Projektbaum snai_edge_int8_lora einbauen, dass Modelle ohne diese Merkmale bytegleich rechnen und die Merkmale Speichern, Laden, Export und Merge überleben? Entscheidung vom 2026-11-03: Faktor fest ans Modell, FFN per Schalter überspringen.
Kriterium (festgelegt 2026-11-03 10:21, vor dem ersten Messwert):
  Die Prüfungen standen vor dem Bau im Auftrag fest:
(1) Ohne Bit und ohne SNAI_FFN_AUS rechnet die neue Lib gegen die alte (aus demselben Baum) 300 Schritte K1 s4. Alle geloggten Zeilen sind zeichengleich, die md5 des Zwischenstands ist gleich.
(2) SNAI_EMB_EIN=1 an der Genesis ergibt Schritt 1 = 7,792130 / GN 1,9256, wie in der Stellrad-Lib von e491. Die Datei trägt flags=3. Neu geladen ohne Env misst sie gleich der Stellrad-Lib. Rot: Ist Bit 1 gelöscht, misst sie anders, und die [EMBEIN]-Zeile fehlt. Wird der Faktor an einer trainierten Basis ohne Bit eingeschaltet, bricht der Lauf ab.
(3) SNAI_FFN_AUS=1,2,3 mit Skip gegen SNAI_FFN_SKIP=0 ist zeichengleich und md5-gleich, dazu wird die Zeit gemessen. Rot: Ist nur rms_ffn von L1 genullt, darf nicht übersprungen werden. Eine absichtlich falsche Lib muss abweichen.
(4) Inferenz (mess_text, snai_inference) ist mit und ohne Skip gleich. Die PHP-Formatschicht erhält das Bit, Rot ist gesehen. verify_v7_format und verify_v7_tying ergeben jeweils 26/26.
Darauf baut: snai/multistack-uebernahme-emb
Messwerte (Groesse | Wert | Arm | Start | n):
  m8202 Schritt1 Loss | 7.792130 | EMB_EIN | s4 | 1
  m8203 Schritt1 GN | 1.9256 | EMB_EIN | s4 | 1
  m8204 Held-out 700 neu geladen | 3.6659 | EMB_EIN t300 | s4 | 1
  m8205 Held-out 700 Bit geloescht (rot) | 5.4979 | EMB_EIN t300 | s4 | 1
  m8206 Zeit Schritt 5-300 s | 24.18 | FFN_AUS Skip an | s4 | 3
  m8207 Zeit Schritt 5-300 s | 27.49 | FFN_AUS Skip aus | s4 | 3
Ergebnis e493 [2026-11-03 10:21]: erfuellt
  Fazit: Alle vier Prüfungen sind erfüllt, Rot wurde je Sonde gesehen. Testprotokoll: rechner-a ~/snai_pruef/baumpatch/testprotokoll.txt, die Läufe liefen auf rechner-b unter ~/snai_pruef/baumpatch.

(1) 64/64 Zeilen sind gleich, md5 bd736ae0, außerdem gleich K1_s4.
(2) Schritt 1 7,792130 / 1,9256, alle 64 Zeilen gleich EE_s4, flags 3. Neu geladen ergibt 3,6659 wie die Stellrad-Lib. Mit gelöschtem Bit kommt 5,4979 und keine [EMBEIN]-Zeile.
(3) md5 dc94852c in 6/6 Läufen, gleich EF0_s4. Zeit 24,2 s gegen 27,5 s (−12 %, 128x4, 1 Thread). Rot: Die falsche Lib weicht ab Schritt 2 ab.
(4) mess_text und Beam bleiben gleich. io_test 13/13, Rot 3× FEHLER. verify 26/26 und 26/26, auch nach dem Einbau im Baum auf rechner-a.

Eingebaut am 2026-11-03 mit patch_baum.py (md5 0f1d592f). Die Quellen sind identisch mit der geprüften Kopie. cortex.nim hat jetzt md5 21f1108a. libcortex.so auf rechner-a ist neu gebaut und md5-gleich zur geprüften (a51d433f). Die alte Lib liegt als libcortex.so.bak_pre_embein_20261103. Es gibt keinen Commit.

Folgen:
- Wer den Faktor will, setzt an der Genesis SNAI_EMB_EIN=1. Bei einer eigenen Genesis-Datei, wie im K1-Rezept, muss zusätzlich SNAI_GENESIS_RUN=1 gesetzt sein.
- Alte Libs außerhalb des Baums übergehen Bit 1 still. Sie messen 5,50 statt 3,67. Werkzeuge in snai_pruef und multi_stack brauchen deshalb die neue Lib.
- Der Skip spart nur etwa 12 %, weil Adam die toten Zweige weiterrechnet.
- Nicht ausgeführt wurden: GPU, prod512b, Revival mit Bit, das Wachstum in royal_distillery.
- Bestandsfehler, nicht angefasst: royal_distillery.php:723 übersieht V7 beim Merge.
  Datei: ~/snai_pruef/baumpatch/testprotokoll.txt
Chronik:
  2026-11-03 10:21 angelegt
  2026-11-03 10:21 Ergebnis e493: erfuellt
  2026-11-03 10:21 Status geplant -> ausgewertet (Ergebnis e493)
  2026-11-03 10:21 Messwerte m8202-m8207
```
