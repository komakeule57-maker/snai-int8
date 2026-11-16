# snai/fullint8-st9-lrplan

```text
snai/fullint8-st9-lrplan - ausgewertet, angelegt 2026-11-15, zuletzt 2026-11-15 21:06
Frage: Fuehrt die Engine mit SNAI_I8_GZ_LRPLAN=1 den Lernratenplan (Warmup linear, Cosinus-Abklingen mit Boden, Formel wie train_worker.php) in Festkomma - Tabelle einmal beim ersten Gebrauch, je Schritt nur int64 - so genau wie der float32-Wert aus PHP (gegen float64), unabhaengig vom Rundungsmodus und ohne Qualitaetsverlust gegen Stufe 8?
Kriterium (festgelegt 2026-11-15 20:31, vor dem ersten Messwert):
  Volltext docs/messreihen/fullint8/KRITERIEN_ST9.txt (md5 bcb0a0fa, nach Zweitmeinung). Nummerierung: Stufe 9 = Lernratenplan, Stufe 10 = Checkpoint V8 (PLAN S9), Gesamtprobe = Schlussprobe. K1 Kurzlauf isoliert, Stufe-9-Lib + gepatchtes PHP: GANZ=0..8 = 0f79d04c/47176fa4/12e40925/6f382e75/ac0be686/8239bb67/39c71b8a/0b208b49/278e3d14; GANZ=9+LRPLAN=0 = 278e3d14; GANZ=8+LRPLAN=1 = GANZ=9; zweimal gleich; 1 = 2 Faeden; GANZ=2+LRPLAN=1 = 12e40925 mit Warnung; GANZ=3+LRPLAN=1 laeuft, Loss +-2 % von GANZ=3; Stufe-8-Lib + gepatchtes PHP GANZ=8 = 278e3d14; Stufe-9-Lib + ungepatchtes PHP GANZ=8 = 278e3d14, GANZ=9 Abbruch. K2 SNAI_GZ_KERN=1: lr-plan ueber alle Schritte 1..D+100 (Tabelle je Lauf neu) und alle Zeilen Stufen 2-8 unter FE_UPWARD/FE_TONEAREST bytegleich; Rot 1 und Rot 2 lr-plan ABWEICHEND. K3 SNAI_GZ_LRVGL=1: groesste rel. Abweichung gegen float64 ueber alle Schritte <= 1e-6 fuer Planformen (a) W=500 S=W D=25000, (b) S=22500, (c) D=0, (d) W=0; float32 nur berichtet; Rot (Referenz +1e-5) > 1e-6. K3b Wache: kein Abbruch ausser Rot; Rot (LRWACHE_ROT, Plan +2^-12) Abbruch im ersten Schritt. K4 Segment 0, s1-s3 gepaart: d=(st9-st8)/st8 <= +2 % in 3/3, sonst Haltepunkt; |d| < 10 % Gleichstand. K5 Saettigungen, NET2NET-GUARD, STEPS_DONE=5001, Wachenbericht. Urteil erfuellt = K1-K5.
Plan: rechner-a:~/snai_pruef/fullint8/PLAN.md
Baut auf: snai/fullint8-st8-rest
Darauf baut: snai/fullint8-st10-ckpt
Rezepte:
  r730 [2026-11-15] cd ~/snai_pruef/fullint8 && ./st9_proben.sh (28 Proben, probe_iso_wd.sh, 2 parallel); K4: ./reihe_gz.sh 1 st9:9
      quelltext: gz/cortex_gz.nim 8e99b309 (= st9/cortex_gz.nim), Lib 3e0e8e5f (bau9, cortex.nim 624d543d); PHP per patch_lr.py: train_worker.php aad5fd3a, tensor_ffi_adapter.php b5f0dce2; st9_proben.sh 0dd7b296; probe_iso_wd.sh 31add0ef; KRITERIEN_ST9.txt bcb0a0fa; Vergleichsarme: proj_d9a (Stufe-8-Lib cfdab036 + gepatchtes PHP), proj_d9u (Stufe-9-Lib + ungepatchtes PHP)
      parameter: Knirps 96x2, REST=sr, W=500, S=W, D=25000, m=0,1, lr 0.001, Segment 0, CPU 2 Faeden, nice 15
      seed: s1-s3 (gepaart mit st8)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/fullint8/log/st9_proben.log, log/P9_*.log, log/st9/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/fullint8/log/st9_proben.log, log/P9_*.log, log/st9/*.mess.jsonl und *_s0.train.log (Bezug st8: log/st8/*.mess.jsonl)
  m11510 K1 GANZ=0..8 md5 (Lib 3e0e8e5f + gepatchtes PHP) | 0f79d04c/47176fa4/12e40925/6f382e75/ac0be686/8239bb67/39c71b8a/0b208b49/278e3d14 = Bezug | st9 |  | 9
  m11511 K1 GANZ=9 md5, 2/2/1 Faeden | 201f5494 dreimal | st9 |  | 3
  m11512 K1 GANZ=9+LRPLAN=0 / GANZ=8+LRPLAN=1 | 278e3d14 (= Stufe 8) / 201f5494 (= GANZ=9) | st9 |  | 2
  m11513 K1 GANZ=2+LRPLAN=1 (ohne ADAM) | 12e40925 (= GANZ=2), WARNUNG im Protokoll | st9 |  | 1
  m11514 K1 GANZ=3+LRPLAN=1 Loss | 5,64476 gegen GANZ=3 5,64749 (-0,05 %), md5 d3427ab5 | st9 |  | 1
  m11515 K1 Vertraeglichkeit Stufe-8-Lib + gepatchtes PHP GANZ=8 | 278e3d14 | st9 |  | 1
  m11516 K1 Vertraeglichkeit Stufe-9-Lib + ungepatchtes PHP GANZ=8 / GANZ=9 | 278e3d14 / rc=1, FATAL kein Plan gesetzt | st9 |  | 2
  m11517 K2 Bausteinprobe abweichende Zeilen (lr-plan Schritte 1..25100 + Stufen 2-8) | 0 von 110 | st9 |  | 1
  m11518 K2 Rot 1 / Rot 2 lr-plan | ABWEICHEND 16250 / 14137 von 25100 Schritten | st9 |  | 2
  m11519 K3 groesste rel. Abweichung gegen float64 int (f32), Planform a W=500 S=W D=25000 | 6,45e-8 (5,95e-8) | st9 |  | 1
  m11520 K3 dto. Planform b S=22500 | 6,01e-8 (5,87e-8) | st9 |  | 1
  m11521 K3 dto. Planform c D=0 (Schritte 1..600) | 5,63e-8 (5,63e-8) | st9 |  | 1
  m11522 K3 dto. Planform d W=0 | 6,30e-8 (5,91e-8) | st9 |  | 1
  m11523 K3 Rot (Referenz +1e-5), Planform a | 1,006e-5 | st9 |  | 1
  m11524 K3b Wache Rot (Plan +2^-12) | rc=1, FATAL bei adam_t=1 (Plan 2,0004882e-6, PHP 2e-6) | st9 |  | 1
  m11525 K3b groesste Abweichung gegen PHP in den K4-Laeufen | 128 * 2^-30 (Wache bei 2^13), kein Abbruch | st9 |  | 3
  m11526 K4 Held-out st9 (st8), d | 2,6104 (2,6214), -0,42 % | st9 | s1 | 300
  m11527 K4 Held-out st9 (st8), d | 2,6197 (2,6188), +0,03 % | st9 | s2 | 300
  m11528 K4 Held-out st9 (st8), d | 2,6475 (2,6480), -0,02 % | st9 | s3 | 300
  m11529 K5 STEPS_DONE / NET2NET-GUARD / Wachenberichte | 5001 / 0 / 5 je Lauf (1000-5000) | st9 |  | 3
  m11530 K5 Saettigungen Adam / Restpfad | 0 in allen lesbaren Berichten; s2 bei 2000: Zahl im Protokoll verschluckt (train_cluster.php gibt einen Lesehappen "0" nicht aus, if ($output)), aus dem Quelltext = 0 | st9 |  | 3
  m11531 Laufzeit Segment 0 | ca. 16 min (20:32-20:48, 3 parallel a 2 Faeden, nice 15) | st9 |  | 3
  Quelle: rechner-a:~/snai_pruef/fullint8/log/U_neu9.out (PROBE_IN=seg0 ./probe_iso.sh proj_hb U_neu9 - 1; proj_hb = Hauptbaum 0a1c43e + cortex_gz 8e99b309 + patch_lr.py, Lib 3e0e8e5f neu gebaut im Hauptbaum)
  m11532 Aus-Probe Hauptbaum Segment 0, Schalter ungesetzt | 7063ce99 (= Bezug), STEPS_DONE 5001, keine GZ-Zeile; danach lokal committet ccf97ba | U_neu9 | 1 | 1
Ergebnis e687 [2026-11-15 20:55]: erfuellt
  Fazit: Der Lernratenplan laeuft jetzt in Festkomma in der Engine. PHP gibt die Planwerte nur einmal je Prozess hinein, rechnet ihn aber zur Kontrolle weiter mit. Bei gleichen Parametern ist der Plan in allen vier Planformen so genau wie der float32-Wert aus PHP (beide rund 6e-8 gegen float64, gleiche Groessenordnung wie vorab erwartet) und haengt nicht vom Rundungsmodus ab. Qualitaet: Gleichstand in 3 von 3 Saaten, die Lernrate wirkt also wie vorher. Damit kann der Lernratenplan in der README-Liste von "Noch in float" zu den erlaubten Ausnahmen wandern (Tabelle einmal beim Start, Plan in Festkomma); belegt durch diese Reihe. Die PHP-Rechnung bleibt nur noch als Wache und Protokoll. Neuer Fallstrick im Messgeraet: train_cluster.php verschluckt einen Lesehappen, der genau "0" ist (PHP wertet "0" als falsch); eine Zahl im Protokoll kann also fehlen, wenn die Ausgabe gerade dort zerteilt wird. Fuer K5 ist das nur aus dem Quelltext geschlossen; die Zaehler nur ueber das Protokoll zu lesen bleibt anfaellig.
  Offen: Aus-Pruefung ueber Segment 0 im Hauptbaum (U_neu9, erwartet 7063ce99) vor dem Commit. Der Cosinus wurde nur bis Schritt 5001 im Training gefahren, bis 25.100 nur im Bausteinvergleich; das ganze Abklingen erst in den Schlusslaeufen. Die Saettigungszahl s2 bei Schritt 2000 ist nur erschlossen; der deterministische Segment-0-Lauf der Stufe-10-Reihe kann sie bestaetigen.
  Datei: docs/messreihen/fullint8/KRITERIEN_ST9.txt
Chronik:
  2026-11-15 20:31 angelegt
  2026-11-15 20:32 Rezept r730
  2026-11-15 20:32 Status geplant -> laeuft (Rezept r730)
  2026-11-15 20:55 Messwerte m11510-m11531
  2026-11-15 20:55 Ergebnis e687: erfuellt
  2026-11-15 20:55 Status laeuft -> ausgewertet (Ergebnis e687)
  2026-11-15 21:06 Messwerte m11532
```
