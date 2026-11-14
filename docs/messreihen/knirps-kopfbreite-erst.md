# snai/knirps-kopfbreite-erst

```text
snai/knirps-kopfbreite-erst - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 14:31
Frage: Erster Kopfbreiten-Versuch am Knirps (Kopieraufgabe var): scheitert Breite 16 am Kopieren, weil vier Köpfe je nur Kopfbreite 4 haben? Ein Stellrad Kopfzahl bei gleicher Genesis; dazu Breite 8 mit einem Kopf.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt, Kopf "KOPFBREITE-VERSUCH (2026-10-12), Kriterien VOR dem ersten Lauf" und NACHTRAG Breite 8 mit EINEM Kopf. (beide später abgelöst).):
  Knirps-Leiter unverändert (2 Schichten, wort256, ctx 64, Warmup 500, WD 0,1, 12 x 5.000 Fenster, Revival wie Produktion an). Arme: Breite 16 mit 2 Köpfen (Kopfbreite 8) und 1 Kopf (16), je LR 0,0001 und 0,001; Gegenrichtung Breite 32 mit 8 Köpfen (Kopfbreite 4), LR 0,001 und 0,0001. BESTÄTIGT, wenn Breite 16 mit 1 oder 2 Köpfen bei mindestens einer LR gelernt erreicht (Rang 0 zweite Kopie >= 90 %, Rot-Probe < 10 %) UND Breite 32 mit 8 Köpfen bei LR 0,001 das in 60.000 Fenstern NICHT erreicht. WIDERLEGT, wenn Breite 16 in allen vier Armen unter 10 % bleibt ODER 32/8 bei LR 0,001 in höchstens 30.000 Fenstern lernt. Sonst nicht entschieden. Nachtrag Breite 8 mit 1 Kopf (LR 0,001 und 0,003): gelernt >= 90 % in 60.000 Fenstern, nicht gelernt < 10 %, dazwischen angefangen.
Plan: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt
Baut auf: snai/kopier-knirps-leiter
Rezepte:
  r77 [2026-10-21] VOK=wort256 ~/snai_pruef/knirps/lauf.sh w256_d<B>h<K>_lr<LR> var 3 <LR> 12 5000 <genesis> SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 OMP_NUM_THREADS=1
      quelltext: knirps/proj, libcortex.so 1c634106f31c, Revival AN (alte Erkennung)
      parameter: Breite 16 mit 1 und 2 Köpfen, Breite 32 mit 8 Köpfen, Breite 8 mit 1 Kopf; ffn 4 x Breite; LR 0,0001 / 0,001 (Breite 8: 0,001 / 0,003); Stopp bei floor(Rang 0) >= 90
      seed: je Arm dieselbe Genesis wie der Leiter-Lauf mit 4 Köpfen (knirps_gen_wort256_d<B>...), je Zelle ein Lauf
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/w256_d16h1_*, w256_d16h2_*, w256_d32h8_*, w256_d8h1_* (.log, .mess.jsonl, _s<I>.train.log)
      notiz: Prüfung beim Nachtrag: Messwerte aus den Laufprotokollen abgelesen. Altes Revival griff in w256_d16h2_lr0.001 (revivt-Zeilen in Segment 8-10). Lade-Wächter: w256_d8h1_lr0.003 hat NET2NET-GUARD in 10 Trainingslogs (Training verändert); die übrigen sieben Arme keine. Notizzeiten sind UTC (Eintrag 11:26 = Log 13:16 ff. Ortszeit).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/w256_*.log (Messzeilen abgelesen; n = Prüffenster)
  m775 Rang 0 zweite Kopie, Erreichen (1 Lauf) | 93,6 % nach Segment 3 (20.000 Fenster), Rot 0,3 % | 16/1/16 LR 0,001 |  | 200
  m776 Rang 0 Ende (1 Lauf) | 4,9 % | 16/1/16 LR 0,0001 |  | 200
  m777 Rang 0 Segmente 8-11 (1 Lauf) | 85,4 / 85,4 / 85,3 / 84,9 % | 16/2/8 LR 0,001 |  | 200
  m778 Rang 0 Ende (1 Lauf) | 3,9 % | 16/2/8 LR 0,0001 |  | 200
  m779 Rang 0 Ende (Höchstwert) (1 Lauf) | 6,5 % (8,9 %) | 32/8/4 LR 0,001 |  | 200
  m780 Rang 0 Ende (1 Lauf) | 8,7 % | 32/8/4 LR 0,0001 |  | 200
  m781 Rang 0 Segmente 8-11 (1 Lauf) | 11,3 / 23,7 / 26,8 / 23,6 % | 8/1/8 LR 0,001 |  | 200
  m782 Rang 0 Segmente 8-11 (1 Lauf) | 1,1 / 1,6 / 1,6 / 1,4 % | 8/1/8 LR 0,003 |  | 200
Ergebnis e65 [2026-10-21 14:31]: erfuellt
  Fazit: Nach dem Wortlaut bestätigt: Breite 16 lernt mit einem Kopf (Kopfbreite 16), Breite 32 mit 8 Köpfen (Kopfbreite 4) nicht. Die damalige Deutung "es zählt die Kopfbreite, nicht die Kopfzahl" ist zurückgenommen: bei fester Breite sind beide gekoppelt, je Zelle lief nur eine Saat, und das alte Revival lief mit. Abgelöst durch das Gitter ohne Revival (snai/kopier-knirps-gitter). Breite 8 mit einem Kopf setzt nach 40.000 Fenstern ein (~25 %), lernt aber im Budget nicht.
  Offen: Warum 16/2/8 bei 85 % steht: snai/knirps-plateau-fortsetzung.
  Datei: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt
Chronik:
  2026-10-21 14:31 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt, Kopf "KOPFBREITE-VERSUCH (2026-10-12), Kriterien VOR dem ersten Lauf" und NACHTRAG Breite 8 mit EINEM Kopf. (beide später abgelöst).)
  2026-10-21 14:31 Rezept r77
  2026-10-21 14:31 Status geplant -> laeuft (Rezept r77)
  2026-10-21 14:31 Messwerte m775-m782
  2026-10-21 14:31 Ergebnis e65: erfuellt
  2026-10-21 14:31 Status laeuft -> ausgewertet (Ergebnis e65)
```
