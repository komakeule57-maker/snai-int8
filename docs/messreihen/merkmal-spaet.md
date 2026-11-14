# snai/merkmal-spaet

```text
snai/merkmal-spaet - ausgewertet, begonnen 2026-10-17, angelegt 2026-10-21, zuletzt 2026-10-21 14:34
Frage: Haelt es den Embedding-Kollaps (d96 Schach) auf, wenn der Weight-Decay auf den Embeddings SPAET (ab s4, 466k Schritte) abgeschaltet wird, ohne dass das Training zerfaellt (s5-s7, drei Saaten)?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/spaet/kriterien_spaet.txt, Kopf '2026-10-17, VOR dem Start' (Start 07:00:48), Vorab-Pruefungen ~07:10, Nachtrag 08:59 vor dem Lesen der Arm-Werte):
  Je Saat am Endstand s7 (Lo = Original s7, L4 = Original s4): HAELT = F < 5 % UND L <= 1,10 x Lo UND L <= 1,10 x L4. ZERFALL = L > 1,10 x Lo (in jeder Saat). WIRKUNGSLOS = F >= 15 %. Sonst UNENTSCHIEDEN. Kollaps-Saat = Original s7 F >= 15 % (vor Arm-Ergebnis gemessen); Saat ohne Kollaps zaehlt nur fuer ZERFALL. GESAMT: 'haelt bis s7' = alle Kollaps-Saaten HAELT und keine ZERFALL; 'taugt nicht' = eine Saat ZERFALL oder alle Kollaps-Saaten WIRKUNGSLOS; sonst kein Urteil. Zusatzregel NORMWARNUNG (aus Zweitmeinung, vorab): skala_max-Wachstum w7 >= w6 > 1,05 oder GradNorm-Median s7 >= 3x Original. Nachtrag vor dem Lesen der Arm-Werte (08:59): mit n = 2 Kollaps-Saaten ist jedes Ergebnis eine Beobachtung mit zwei Wiederholungen.
Baut auf: snai/merkmal-wdemb, snai/merkmal-lang64
Darauf baut: snai/merkmal-verhaeltnis, snai/merkmal-grenze
Rezepte:
  r104 [2026-10-21] bash ~/snai_pruef/merkmal/spaet/lauf_spaet.sh <1|2|3|k> (je Segment 5..7: SNAI_WD_EMBEDDINGS=0 bzw. =1 fuer k, nice -n 10 php train_cluster.php factory/input/gross_c64_seg<I>.txt <out> 1 1 <vorher> 3 0.001 0.0001 1 0.1); Messung messe.sh, Kontrolle mess_ref.sh
      quelltext: Kopien knirps/proj_spaet_s1..3 und proj_spaet_k = proj_neu + cortex.nim, train_worker.php, tensor_ffi_adapter.php aus Projektbaum 6b46247, Lade-Waechter aus; libcortex.so 28eeffe0; lauf_spaet.sh 3e6bd442, messe.sh 9c4b3d9a, mess_ref.sh ac23dd70, bank_spaet.sh 9c9a2ea7
      parameter: Start Original s4, Segmente gross_c64_seg5..7, sonst Originalrezept (LR-Auslauf 3,57e-4 -> 1e-4); einziges Stellrad SNAI_WD_EMBEDDINGS=0
      seed: Saaten 1-3, gleiche Ausgabenamen wie die Originale (gepaart); Paarungskontrolle k = Saat 1 s5 mit =1
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/spaet/log/, spaet/mess_spaet_s<S>.jsonl, mess_orig_s<S>.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/spaet/mess_spaet_s<S>.jsonl und mess_orig_s<S>.jsonl (Saat 1 und 3 am 2026-10-21 nachgelesen), Paarungs-md5 nachgerechnet; uebrige aus kriterien_spaet.txt
  m1007 F s5/s6/s7 | 0,6/0,0/1,0 % | Decay auf E aus ab s4 | 1 | 500
  m1008 F s5/s6/s7 | 28,4/34,4/32,8 % | Original | 1 | 500
  m1009 L s7 | 1,3711 (Original 1,3701) | Decay aus | 1 | 1
  m1010 tote Zeilen s7 | 14 (Original 56) | Decay aus | 1 | 1
  m1011 F s5/s6/s7 | 0,0/0,0/0,0 % | Decay aus | 2 | 500
  m1012 F s7 | 0,2 % | Original | 2 | 500
  m1013 L s7 | 1,3572 (Original 1,3433, +1,0 %) | Decay aus | 2 | 1
  m1014 F s5/s6/s7 | 14,4/8,4/12,6 % | Decay aus | 3 | 500
  m1015 F s5/s6/s7 | 37,2/36,8/36,4 % | Original | 3 | 500
  m1016 L s7 | 1,4161 (Original 1,3805, +2,6 %) | Decay aus | 3 | 1
  m1017 tote Zeilen s7 | 31 (Original 48) | Decay aus | 3 | 1
  m1018 skala_max-Wachstum w5/w6/w7 | 2,13/1,38/1,32 | Decay aus | 1 | 3
  m1019 skala_max-Wachstum w5/w6/w7 | 2,89/1,58/0,98 | Decay aus | 2 | 3
  m1020 skala_max-Wachstum w5/w6/w7 | 6,94/1,71/0,98 | Decay aus | 3 | 3
  m1021 GradNorm-Median s7 | 77,2 (Original 79,1) | Decay aus | 1 | 1
  m1022 Paarungskontrolle md5 s5 mit =1 | 0c079542 = Original | k | 1 | 1
Ergebnis e98 [2026-10-21 14:34]: keine_aussage
  Fazit: Kein Urteil nach Regel: Saat 1 HAELT (1 % statt 32,8 %), Saat 3 bleibt UNENTSCHIEDEN (12,6 %), keine Saat zerfaellt. Spaetes Abschalten vor Kollapsbeginn verhinderte ihn in Saat 1, nach Beginn (Saat 3 hatte bei s4 schon 6 tote Zeilen) milderte es ihn nur - so die Deutung, nicht gemessen. Wegen der Kopplung an den LR-Auslauf ist 'Decay spaet aus' kein Notgriff fuer Laeufe mit hoher LR. Die Reihe hat stattdessen gezeigt, dass Zahl der toten Zeilen und Formfehler sich entkoppeln (14 tote bei 1 %), was die Suche auf den Inhalt von c* lenkte (snai/merkmal-biasalle). Abgeloest als Abhilfe durch das zufaellige Runden der Adam-Momente (snai/merkmal-sr-lang).
  Offen: Hohe LR beim Abschalten ungeprueft; Arm-Loss steigt in Saat 2/3 von s5 nach s7 leicht, waehrend das Original faellt (Beobachtung).
  Datei: rechner-a:~/snai_pruef/merkmal/spaet/kriterien_spaet.txt
Chronik:
  2026-10-21 14:33 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/spaet/kriterien_spaet.txt, Kopf '2026-10-17, VOR dem Start' (Start 07:00:48), Vorab-Pruefungen ~07:10, Nachtrag 08:59 vor dem Lesen der Arm-Werte)
  2026-10-21 14:33 Rezept r104
  2026-10-21 14:33 Status geplant -> laeuft (Rezept r104)
  2026-10-21 14:34 Messwerte m1007-m1022
  2026-10-21 14:34 Ergebnis e98: keine_aussage
  2026-10-21 14:34 Status laeuft -> ausgewertet (Ergebnis e98)
```
