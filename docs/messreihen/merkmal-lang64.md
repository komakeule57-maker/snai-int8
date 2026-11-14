# snai/merkmal-lang64

```text
snai/merkmal-lang64 - ausgewertet, begonnen 2026-10-16, angelegt 2026-10-21, zuletzt 2026-10-21 14:32
Frage: Kollabieren die Embeddings auch bei Breite 64 (Melodien, Nano-Geschichten) im Rezept des d96-Schachlaufs bis ~1 Mio Schritte? Dazu Kontrollarm ohne Decay auf den Embeddings (SNAI_WD_EMBEDDINGS=0), gepaart.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/lang64/kriterien_lang64.txt, Kopf '2026-10-16, VOR dem Start'; Kontrollarm WD0 'Auftrag 2026-10-16 ~15:10, VOR seinem Start'; Zweitmeinung vor dem Start eingearbeitet):
  Je Saat am Endstand tot_haeufig/haeufig (zeilen_lang.php, tot = Stufen <= 1). KOLLAPS: >= 10 % der haeufigen Zeilen tot. FREI: 0 tote haeufige Zeilen UND median_haeufig >= 5. ANGEZAEHLT: dazwischen. Je Korpus: alle 3 Saaten gleich -> Urteil; sonst saatabhaengig. Wirkung nur Melodien (form_noten 500, T 1, Saat 4711): in einer KOLLAPS-Saat zaehlt Abfall der Formquote >= 10 Punkte gegen s63. Kontrollarm WD0 (Auftrag ~15:10, vor seinem Start): Schalter hilft bei d64, wenn alle 3 WD0-Saaten FREI sind - nur wenn der Hauptarm KOLLAPS zeigt; Pflichtkontrolle Held-out WD0 gegen Hauptarm am Endstand, > 10 % = Tausch, kein Gewinn. FREI heisst 'bis 1 Mio Schritte bei diesem Rezept'.
Baut auf: snai/merkmal-wdemb
Darauf baut: snai/merkmal-spaet
Rezepte:
  r84 [2026-10-21] Melodien Haupt / WD0: bash ~/snai_pruef/merkmal/lang64/lauf_noten64.sh <1|2|3> bzw. lauf_noten64_wd0.sh <1|2|3> (je Segment: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=1000512 nice -n 10 php train_cluster.php factory/input/notentakt2_c64_seg<I mod 64>.txt <out> 1 1 <vorher> 3 0.001 0.0001 1 0.1; WD0-Arm zusaetzlich SNAI_WD_EMBEDDINGS=0)
      quelltext: Kopien knirps/proj_l64n_s1..3 (Engine 563780e3 = proj_ow), WD0 proj_l64nw_s1..3 = Hauptkopie + libcortex.so, train_worker.php, tensor_ffi_adapter.php aus proj_wdemb; lauf_noten64.sh c0a708c0, lauf_noten64_wd0.sh bc826746, zeilen_lang.php 225243c1
      parameter: 64/4 Koepfe/ffn 256/ctx 64/2 Schichten, Vokabular noten_takt (108), Daten notentakt2, 324 Segmente a 3088 Schritte = 1.000.512, LR 0,001 Cosinus -> 0,0001, Warmup 500, WD 0,1, gebunden, int8 FULL, Revival und Lade-Waechter aus, CPU OMP 1
      seed: Saaten 1-3 (Genesis notentakt_gen_d64h4_s1..3); WD0 gleiche Genesis und Ausgabenamen (gepaart)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/lang64/log/l64n_s<S>.log (+ .mess/.form/.zeilen.jsonl), lang64/log_wd0/
  r89 [2026-10-21] Geschichten Haupt / WD0: bash ~/snai_pruef/knirps_gpu/l64/lauf_gesch64.sh <S> bzw. lauf_gesch64_wd0.sh <S> (Wortlaut liegt auf rechner-b; nicht im Einzelnen gelesen)
      quelltext: rechner-b ~/snai_pruef/knirps_gpu/proj_l64g_s1..3, proj_l64gw_s1..3
      parameter: 64/4/ffn 256/ctx 128/2 Schichten, Vokabular 1.509 Woerter, 5 Segmentdateien zyklisch, 200 Segmente = 1.000.200 Schritte, sonst wie Melodien
      seed: Saaten 1-3, Genesis gesch_gen_d64h4_s1..3
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/knirps_gpu/l64/log/l64g_s<S>.log, log_wd0/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/lang64/log_start_n<S>.out, log_start_nw<S>.out, log/ und log_wd0/ (Melodien); rechner-b:~/snai_pruef/knirps_gpu/l64/log/ und log_wd0/l64g_s<S>.log (Geschichten); am 2026-10-21 abgelesen. Trainingsloss, skala_max und GradNorm des Zusatzbefunds nicht nachgerechnet.
  m853 tot_haeufig Endstand s323 | 0/61 | Melodien Haupt | 1 | 1
  m854 tot_haeufig Endstand s323 | 0/61 | Melodien Haupt | 2 | 1
  m855 tot_haeufig Endstand s323 | 0/61 | Melodien Haupt | 3 | 1
  m856 median_haeufig s323 | 31 | Melodien Haupt | 1 | 1
  m857 Held-out-Loss s323 | 1,117 | Melodien Haupt | 1 | 1
  m858 Held-out-Loss s323 | 1,135 | Melodien Haupt | 2 | 1
  m859 Held-out-Loss s323 | 1,120 | Melodien Haupt | 3 | 1
  m860 Formquote T 1 s323 | 43,2 % | Melodien Haupt | 1 | 500
  m861 Formquote T 1 s323 | 42,2 % | Melodien Haupt | 2 | 500
  m862 Formquote T 1 s323 | 39,4 % | Melodien Haupt | 3 | 500
  m863 tot_haeufig Endstand s199 | 0/955 | Geschichten Haupt | 1 | 1
  m864 tot_haeufig Endstand s199 | 0/955 | Geschichten Haupt | 2 | 1
  m865 tot_haeufig Endstand s199 | 0/955 | Geschichten Haupt | 3 | 1
  m866 Held-out-Loss s199 | 2,094 | Geschichten Haupt | 1 | 1
  m867 Held-out-Loss s199 | 2,103 | Geschichten Haupt | 2 | 1
  m868 Held-out-Loss s199 | 2,118 | Geschichten Haupt | 3 | 1
  m869 Held-out-Loss s323 | 3,634 | Melodien WD0 | 1 | 1
  m870 Held-out-Loss s323 | 3,917 | Melodien WD0 | 2 | 1
  m871 Held-out-Loss s323 | 4,428 | Melodien WD0 | 3 | 1
  m872 Held-out-Loss s31 / s63 | 1,249 / 1,448 | Melodien WD0 | 1 | 2
  m873 Formquote T 1 s323 | 44,8 / 37,6 / 17,0 % | Melodien WD0 Saaten 1-3 |  | 3
  m874 Held-out-Loss s199 | 4,928 | Geschichten WD0 | 1 | 1
  m875 Held-out-Loss s199 | 4,980 | Geschichten WD0 | 2 | 1
  m876 Held-out-Loss s199 | 8,093 | Geschichten WD0 | 3 | 1
  m877 tote Zeilen Endstand | 0 | alle WD0-Arme Saaten 1-3 |  | 6
  m878 Fehlerkanal / rc != 0 je Segment | 0 | alle 12 Laeufe Saaten 1-3 |  | 12
Ergebnis e83 [2026-10-21 14:32]: verfehlt
  Fazit: Bei Breite 64 kollabiert mit diesem Rezept bis ~1 Mio Schritte nichts, in beiden Korpora und allen drei Saaten (Urteil FREI). Der Kollaps ist also an breitere Modelle oder laengere Laeufe gebunden; ein d64-Test kann ihn nicht abbilden. Der Kontrollarm sagt nach Regel nichts ueber den Schalter, zeigte aber den wichtigeren Befund: ohne Decay auf den Embeddings zerfaellt das Training ab Genesis (Held-out +135 bis +295 %, kein Ueberanpassen). Daraufhin wurde die Vorgabe 'Decay auf E aus' am 2026-10-17 widerrufen. Fuer die Abhilfe folgt: Decay muss an bleiben; gesucht war ein anderer Hebel (spaeter die v-Ratsche, snai/merkmal-sr).
  Offen: d96 und > 1 Mio Schritte ungeprueft; Zwischenweg (Decay spaet aus) prueft snai/merkmal-spaet. Fuer die Geschichten wurde ein Zwischenstand festgehalten; die Endwerte stehen hier.
  Datei: rechner-a:~/snai_pruef/merkmal/lang64/kriterien_lang64.txt
Chronik:
  2026-10-21 14:31 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/lang64/kriterien_lang64.txt, Kopf '2026-10-16, VOR dem Start'; Kontrollarm WD0 'Auftrag 2026-10-16 ~15:10, VOR seinem Start'; Zweitmeinung vor dem Start eingearbeitet)
  2026-10-21 14:31 Rezept r84 (Melodien Haupt / WD0)
  2026-10-21 14:31 Status geplant -> laeuft (Rezept r84)
  2026-10-21 14:32 Rezept r89 (Geschichten Haupt / WD0)
  2026-10-21 14:32 Messwerte m853-m878
  2026-10-21 14:32 Ergebnis e83: verfehlt
  2026-10-21 14:32 Status laeuft -> ausgewertet (Ergebnis e83)
```
