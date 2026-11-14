# snai/merkmal-stufe1

```text
snai/merkmal-stufe1 - ausgewertet, begonnen 2026-10-16, angelegt 2026-10-21, zuletzt 2026-10-21 14:28
Frage: Rechnet der Patch 'Weight-Decay von den Embeddings ausnehmen' (Schalter SNAI_WD_EMBEDDINGS, patch_stufe1.py auf Git 21b7fde) mit Vorgabe bytegleich zum unveraenderten Stand, und wirkt der Schalter (=0 veraendert das Ergebnis, auch ungebunden; ohne Decay wirkungslos)?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/kriterien_stufe1.txt, Kopf 'vor dem ersten Lauf' (2026-10-16; Datei-mtime 2026-10-16 07:59 nach angefuegtem ERGEBNIS, Laeufe 07:51-07:59)):
  md5 des Endmodells je Arm (Bank 96x2, Vokabular 8192, ctx 64, Korpus 60 kB, 1 Worker, 1 Epoche, int8 FULL, CPU, OMP 1, Revival aus, gleicher Ausgabename). Pflicht: B (Projektbaum-Bibliothek 031879a2) == A (alt lokal gebaut) == N (neu, Vorgabe); N0 (SNAI_WD_EMBEDDINGS=0) != A; R (rot = Patch mit Vorgabe 0) == N0 und != A; mit WD 0: A_wd0 == N_wd0 == N0_wd0; ungebunden: A_u == N_u, N0_u != A_u. Alle Gleichheiten und Ungleichheiten erfuellt -> Stufe 1 bytegleich und wirksam; eine Abweichung bei == -> Patch falsch. Fehlerkanal je Lauf: rc, error/fatal/nan/NET2NET-GUARD/Warnung.
Darauf baut: snai/merkmal-wdemb
Rezepte:
  r59 [2026-10-21] bash ~/snai_pruef/merkmal/bank.sh (je Arm: cd <kopie> && env [SNAI_WD_EMBEDDINGS=0] SNAI_TIE_EMBEDDINGS=<1|0> php train_cluster.php factory/input/bank.txt factory/checkpoints/bank.snai 1 1 factory/genesis/genesis96.snai 3 0.002 0 1 <0.1|0>)
      quelltext: Kopien merkmal/alt, neu, rot = git archive 21b7fde, lokal gebaut (nim 2.2.10); Bau alt 72f1885f, neu 01970ecf, rot ede87828; patch_stufe1.py md5 2ed1b975; bank.sh 6f1db0fd (heutiger Stand, mtime 2026-10-16 07:51)
      parameter: Genesis init_base.php 8192 96 64 2 384 (Saat 20261016), Korpus merkmal/korpus.txt (60 kB aus ho_mini.txt), LR 0,002, Warmup 20, kein LR-Abfall, SNAI_INT8_FULL=1, SNAI_START_OFFSET=0, WD 0,1 bzw. 0, gebunden bzw. ungebunden
      seed: Genesis-Saat 20261016; Fensterfolge am gleichen Ausgabenamen bank.snai
      rechner: rechner-a (CPU, OMP 1)
      logs: rechner-a:~/snai_pruef/merkmal/erg/<Arm>.log, <Arm>.snai
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/erg/*.snai (md5 am 2026-10-21 nachgerechnet) und erg/*.log
  m572 md5 Endmodell | 4ef28436 | B (Baum-Bibliothek, WD 0,1) |  | 1
  m573 md5 Endmodell | 4ef28436 | A (alt lokal, WD 0,1) |  | 1
  m574 md5 Endmodell | 4ef28436 | N (neu, Vorgabe, WD 0,1) |  | 1
  m575 md5 Endmodell | 8b101378 | N0 (neu, SNAI_WD_EMBEDDINGS=0) |  | 1
  m576 md5 Endmodell | 8b101378 | R (rot, Vorgabe 0) |  | 1
  m577 md5 Endmodell | 56c0f485 | A_wd0 |  | 1
  m578 md5 Endmodell | 56c0f485 | N_wd0 |  | 1
  m579 md5 Endmodell | 56c0f485 | N0_wd0 |  | 1
  m580 md5 Endmodell | 8b8bcf03 | A_u (ungebunden) |  | 1
  m581 md5 Endmodell | 8b8bcf03 | N_u (ungebunden) |  | 1
  m582 md5 Endmodell | 411f1486 | N0_u (ungebunden, =0) |  | 1
  m583 Fehlerkanal Treffer | 0 | alle 11 Arme |  | 11
  m584 STEPS_DONE | 276 | alle 11 Arme |  | 11
Ergebnis e54 [2026-10-21 14:28]: erfuellt
  Fazit: Der Schalter fuer 'kein Decay auf den Embeddings' ist sauber eingebaut: Vorgabe rechnet bytegleich zum alten Stand, =0 aendert gebunden und ungebunden das Ergebnis, ohne Decay ist er wirkungslos. Damit duerfen spaetere Wirkungstests (snai/merkmal-wdemb) und die Projektbaum-Umstellung auf diesen Patch bauen. Ueber die Wirkung auf den Embedding-Kollaps sagt die Bank nichts.
  Offen: Kartenpfad (gpuAdamRows) nicht gefahren; nur Geometrie 96x2, 276 Schritte. Die Projektbaum-Fassung (patch_wdemb_baum.py, patch_wdemb_wout.py, spaeter patch_umkehr.py) hat eigene Bank-Laeufe ohne Kriteriendatei (erg_baum, erg_baum_wout, erg_umkehr).
  Datei: rechner-a:~/snai_pruef/merkmal/kriterien_stufe1.txt
Chronik:
  2026-10-21 14:28 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/kriterien_stufe1.txt, Kopf 'vor dem ersten Lauf' (2026-10-16; Datei-mtime 2026-10-16 07:59 nach angefuegtem ERGEBNIS, Laeufe 07:51-07:59))
  2026-10-21 14:28 Rezept r59
  2026-10-21 14:28 Status geplant -> laeuft (Rezept r59)
  2026-10-21 14:28 Messwerte m572-m584
  2026-10-21 14:28 Ergebnis e54: erfuellt
  2026-10-21 14:28 Status laeuft -> ausgewertet (Ergebnis e54)
```
