# snai/gradnorm-zerlegung

```text
snai/gradnorm-zerlegung - ausgewertet, angelegt 2026-11-01, zuletzt 2026-11-01 14:29
Frage: Warum steigt die GradNorm im Lauf c128sr (s4 2,80 -> s8 7,93): gemeinsame Richtung oder Streuung zwischen Fenstern? Liegt es am Ganzzahl-Rückwärtspfad, an einer Tensorgruppe, an schrumpfenden Gewichten, geht ein Embedding-Kollaps damit einher?
Kriterium (festgelegt 2026-11-01 07:21, vor dem ersten Messwert):
  Fester Stand, LR hart 0, gleiche Fenster, k=1/4/16/64, Modell ||g_k||^2 = S^2 + N^2/k. U1: R = dN^2/d(S^2+N^2) s4->s8; RAUSCHEN R>=0,9, RICHTUNG R<=0,5, sonst GEMISCHT; Intervall über Schwelle = nicht entschieden. U2: int/float je Stand, GLEICHSTAND alle |V-1|<10 %. U3: Gruppenanteile am Anstieg, trägt ab 70 %. U4: KOLLAPS-VERDACHT tote Zeilen +>=5 % oder Median <=0,5x; Rot an bekannten Kollaps-Ständen. U5: SKALENEFFEKT, wenn Gruppen-Norm x Gewichts-RMS <10 % steigt bei Gruppen-Norm >50 %. Reichweite: ein Modell; Wiederholung über drei Saaten in eigener Reihe.
Plan: rechner-a:~/snai_pruef/gradnorm/kriterien_zerlegung.txt
Baut auf: snai/geschichten-chin128, snai/merkmal-zerl
Darauf baut: snai/gradnorm-skala, snai/dauerclip-lang, snai/gradnorm-batch, snai/v-klebt, snai/l2sum-float32, snai/norm-je-tensor
Rezepte:
  r485 [2026-11-01] cd ~/snai_pruef/gradnorm && setsid -f nohup werkzeug/schlange_z.sh (je Messlauf: werkzeug/lauf1.sh proj_gn <stand> daten/<d>.txt <k> 0 z_<stand>_<d>_k<k>_<arm> SNAI_GN_LOG=1 SNAI_GN_LR0=1 SNAI_TELEMETRY_STEPS=0 [SNAI_I8_INT_BACKWARD=0 SNAI_I8_INT_GRADACC=0]; intern php train_worker.php <chunk> <out> 1 <stand> 3 0 1 0 0.1 0 0)
      quelltext: proj_gn: train_worker.php 2eb56d35, cortex.nim 9d174973, libcortex.so 4f6f712b; schlange_z.sh a65c371d; lauf1.sh cfc0d676; kriterien_zerlegung.txt 3de6f2a1; Kontrolle proj_gn0 libcortex e281ce8d
      parameter: Stände c128sr s8 s4 s6 s5 s7 s0, s9 nachgezogen; train_a/b/c, held; k 1/4/16/64; Arme int und float; 5 parallel, Start ab 2400 MB verfügbar
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/gradnorm/log/z_*.log, log/schlange_z.log
      notiz: Saat: Stände fest, Fensterreihenfolge hängt nur am Dateinamen. Vorlauf am Stand s8: Kontrollen K1-K4 bestanden; erste LR-0-Probe war ungültig (LR 0,0005 durch train_worker.php:148), durch Rot-Probe gefunden.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/gradnorm/werkzeug/auswerten_z.py auf log/z_*.log (74 Laeufe, alle rc=0, Fehlerkanal 0 Treffer, 136 Waechterzeilen nur Meldung); s9 steht noch aus
  m7077 sqrt mittel g1^2 train | 2,676 / 2,978 / 3,559 / 4,544 / 7,136 / 8,992 | int s0,s4,s5,s6,s7,s8 |  | 1710
  m7078 S train | 0,514 / 0,611 / 0,664 / 0,797 / 0,746 / 1,117 | int s0,s4,s5,s6,s7,s8 |  | 1710
  m7079 N train | 2,618 / 2,910 / 3,492 / 4,469 / 6,911 / 8,910 | int s0,s4,s5,s6,s7,s8 |  | 1710
  m7080 S held | 0,518 / 0,596 / 0,658 / 0,815 / 0,762 / 1,090 | int s0,s4,s5,s6,s7,s8 |  | 1503
  m7081 N held | 2,636 / 2,914 / 3,514 / 4,506 / 6,502 / 9,004 | int s0,s4,s5,s6,s7,s8 |  | 1503
  m7082 U1 R train s4 nach s8 | 0,988 [0,987; 0,988] RAUSCHEN | int
  m7083 U1 R held s4 nach s8 | 0,989 [0,988; 0,990] RAUSCHEN | int
  m7084 U2 int/float Norm | 1,0012 / 1,0014 / 1,0014 / 1,0014 / 1,0006 / 1,0008 GLEICHSTAND | s0,s4,s5,s6,s7,s8
  m7085 U2 int/float S | 0,9994 / 1,0008 / 0,9975 / 1,0009 / 0,9947 / 0,9961 GLEICHSTAND | s0,s4,s5,s6,s7,s8
  m7086 U3 Anteil am Anstieg Norm^2 s4 nach s8 | emb 0,454 / qk 0,036 / vo 0,254 / ffn 0,255, keine Gruppe traegt ihn (Schwelle 70 %) | int
  m7087 U5 Produkt Gruppennorm x RMS s4 nach s8 | emb +8,3 % bei Norm +158 % SKALENEFFEKT; qk +31,7 %; vo +50,1 %; ffn +165,7 % kein Skaleneffekt | int
  m7088 Kontrolle Ausschnitt k=1 train_a gegen train_c | s4 +0,2 %, s8 -0,1 % | int
  m7089 Modellabweichung groesste | s7 train -5,1 / -5,0 / +3,0 / -0,3 %, sonst unter 1 %; unter der Grenze 10 % | int
  m7090 Ausreisser s7 train_a | ein Fenster Norm 121,9 (float 122,2), ohne die Top 5 sqrt mq 6,465; held 6,552, Median 6,25; erklaert die breiten s7-Intervalle, U1 nutzt s7 nicht | int
  Quelle: rechner-a:~/snai_pruef/gradnorm/log/auswertung_z_s9.txt (auswerten_z.py), z_s9_*.log, sonde.jsonl, quant_sonde. Fehlerkanal 0 Dateien, 2 Waechterzeilen je Lauf, keine Korrektur. U5 aus gerundeten Anteilen.
  m7217 S / N train int | 1,056 / 11,376 | s9 | 1
  m7218 S / N held int | 1,027 / 11,460 | s9 | 1
  m7219 Norm k=1 train int | 11,429 | s9 | 1
  m7220 U1 R s4->s9 train | 0,994 (KI 0,993-0,994), RAUSCHEN | s9 | 1
  m7221 U1 R s4->s9 held | 0,994 (KI 0,993-0,995), RAUSCHEN | s9 | 1
  m7222 U2 int/float Norm, S | 1,0004, 0,9797, GLEICHSTAND | s9 | 1
  m7223 Modellabweichung k=1,4,16,64 train | -0,1 / -0,1 / +0,3 / -0,1 % | s9 | 1
  m7224 U4 tote Zeilen, Stufen s4 -> s9 | 0 -> 0, 36 -> 33, kein Kollaps-Verdacht | s9 | 1
  m7225 U5 Produkt Gruppennorm x RMS gegen s4 | emb +6, qk +44, vo +95, ffn +147 % | s9 | 1
Ergebnis e427 [2026-11-01 14:29]: erfuellt
  Fazit: Endurteil: Der Anstieg ist RAUSCHEN (R 0,988 bis s8, 0,994 bis s9, Training und Held-out, Intervalle klar ueber 0,9). Die Signal-Norm S steigt nicht mit (s8 1,117, s9 1,056), die Fenster-Streuung N verdreifacht bis vervierfacht sich. Der Ganzzahlpfad ist unschuldig (Gleichstand), ein Formkollaps der Embeddings liegt nicht vor. Keine Gruppe traegt den Anstieg allein. Bei den Embeddings ist er fast nur Skala (+6 %), bei den Schichten nicht (qk +44, vo +95, ffn +147 %), dort ist die Ursache offen. Beantwortet ist, WAS steigt, nicht WARUM und nicht, ob es schadet: Held-out verbessert sich waehrend des ganzen Anstiegs.
  Offen: Warum das Rauschen in den Schichten waechst: snai/gradnorm-skala. Ob es schadet: snai/dauerclip-lang und die geplante Batch-Reihe. Nur eine Saat, ein Modell; Ausreisserfenster s7 ungeklaert; prod512b nicht gemessen.
  Datei: rechner-a:~/snai_pruef/gradnorm/kriterien_zerlegung.txt, log/auswertung_z_s9.txt
Chronik:
  2026-11-01 07:21 angelegt
  2026-11-01 07:21 Rezept r485
  2026-11-01 07:21 Status geplant -> laeuft (Rezept r485)
  2026-11-01 09:04 2026-11-01 ~09:05: Schlange neu gestartet, weil die RAM-Grenze auf 1 GB gesenkt wurde (Startschwelle 2400 -> 1400 MB, schlange_z.sh, sonst unveraendert, Alt: .alt2400). Dabei eigener Fehler: falsches SKIP-Feld, z_s5_train_c_k64_float lief rund 10 s doppelt und schrieb in dieselbe Protokolldatei. Beide Kopien per PID beendet, Protokoll und rc nach verworfen/ (z_s5_train_c_k64_float.doppelt.*), Lauf wird komplett neu gefahren. Andere Tags nicht betroffen (keine weiteren Doppelten laut ps). Wirkt nicht auf die Messwerte: Schwelle regelt nur den Startzeitpunkt, Worker deterministisch.
  2026-11-01 10:14 Messwerte m7077-m7090
  2026-11-01 14:29 Messwerte m7217-m7225
  2026-11-01 14:29 Ergebnis e427: erfuellt
  2026-11-01 14:29 Status laeuft -> ausgewertet (Ergebnis e427)
```
