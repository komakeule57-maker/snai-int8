# snai/fullint8-st3-adam

```text
snai/fullint8-st3-adam - ausgewertet, angelegt 2026-11-15, zuletzt 2026-11-15 19:04
!! Kriterium nach Messwerten geaendert
Frage: Rechnen Clip-Norm, Adam der Matrizen (8-Bit-Log-Momente) und Adam der Gains (SNAI_I8_GANZ=3) ohne Gleitkomma, mit demselben Ergebnis wie der alte float-Adam (bis auf Rundungsgrenzen) und ohne Qualitätsverlust gegen Stufe 2? Schritt S3 des Full-int8-Umbaus.
Kriterium (nachgetragen, Beleg: Kriteriendatei KRITERIEN_ST3.txt geschrieben 2026-11-15 ca. 18:05, vor dem ersten gezählten Lauf (nur der Rauchtest T3 lief davor), ergänzt um K2b und t=3000 nach der Zweitmeinung noch vor den gezählten Läufen. Messbuch-Eintrag erst 18:25.):
  Wie bisher (KRITERIEN_ST3.txt), K3 jedoch in Lesart B: Vergleich mit dem alten float-Adam bei GLEICHER Norm (GZ bekommt die Norm des alten Pfads eingespeist, SNAI_GZ_ADAMVGL_ALTNORM=1) mit den unveraenderten Schwellen, dazu die Ganzzahl-Norm gegen eine float64-Referenz rel. <= 1e-6.
Plan: rechner-a:~/snai_pruef/fullint8/PLAN.md
Baut auf: snai/fullint8-st2-matmul
Darauf baut: snai/fullint8-st4-norm
Rezepte:
  r723 [2026-11-15] K1: SNAI_I8_GANZ=k ./probe_s0.sh proj_gz R1_Gk - 1 (k=0..3); Determinismus/Kern isoliert: SNAI_I8_GANZ=3 [SNAI_GZ_KERN=1] ./probe_iso.sh proj_gz I_G3|I_G3b|I_R2 - 1|2 ; K2/K2b: SNAI_I8_GANZ=3 SNAI_GZ_KERN=1 [SNAI_GZ_KERN_ROT=1] ./probe_s0.sh proj_gz R2[rot] - 2 ; K3: SNAI_I8_GANZ=3 SNAI_GZ_ADAMVGL=1|150 [SNAI_GZ_ADAMVGL_ROT=1 | SNAI_GZ_ADAMVGL_ALTNORM=1] ./probe_s0.sh proj_gz R3a|R3b|R3rot|R3alt - 2 ; t=3000: PROBE_IN=seg0 SNAI_GZ_ADAMVGL=3000 ./probe_iso.sh proj_gz I_R3c - 2 ; K4: ./reihe_gz.sh 1 st3:3
      quelltext: proj_gz/st3 = Hauptbaum 1a8edde + patch_s0.py 80fee343 + patch_gz.py 9270b63a (3 Ersetzungen) + cortex_gz.nim 27704c03 (nach Reparatur der Momentgenauigkeit), libcortex.so 6118054a; erste Fassung 6d9b23b5/0dfb8e1f (Rauchtest), Zwischenfassungen f7feacde/2405ae7d (K2b verfehlt) und mit Einzelauskunft; probe_iso.sh neu
      parameter: REST=sr, INT8_FULL, LR 0,001, Cosinus 25.000, Warmup 500, CPU 2 Faeden (Kurzproben 1-2)
      seed: Genesis gesch_gen_d96h6L2_s1..s3, Armname gesch_d96h6L2_sN; Kurzproben Saat s1
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/fullint8/log/ (R1_*, R2*, R3*, I_*, ST3K*, D3b, st3/, reihe_gz.log)
      notiz: Fehler im Messaufbau gefunden (interne Notiz): probe_s0.sh-Laeufe parallel im selben Ordner teilen Chunk/Ergebnisdatei. Betroffen nur die parallelen Stufe-3-Proben ab 18:01; Gleichheitsaussagen isoliert wiederholt (probe_iso.sh), K3-Protokolle sind je Lauf getrennt und gueltig, der erste t=3000-Lauf (R3c) war ungueltig (falscher Text).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: probe_s0.sh/probe_iso.sh-Ausgaben; log/ST3K2*.log (erste Fassung), log/R2*.log, log/R3*.log, log/I_*.log; Auswertung k3.py (Scratchpad) gegen die Schwellen aus KRITERIEN_ST3
  m11339 K1 md5 Kurzlauf Stufe 0/1/2, Lib 6118054a | 0f79d04c / 47176fa4 / 12e40925 (= Bezug) | K1
  m11340 K1 Stufe 3 deterministisch (isoliert: 1 Faden, 2 Faeden, mit Bausteinprobe) | 6f382e75 dreimal | K1 | s1
  m11341 K2 Bausteinprobe Adam (Lib 6118054a) | 13 Matrizen + 5 Gains + Norm gleich | K2 | s1
  m11342 K2 Rot (float32-Mult. je Zeile) | 13 von 13 Matrizen, 5 von 5 Gains abweichend; Matmul-Rot weiter abweichend | K2rot | s1
  m11343 K2b Selbsttest erste Fassung (Q38-Tabellen) | Tabellen rel. 1,58e-4 > 1e-6 VERFEHLT; log2 1,7e-7, isqrt 0, 0,5 ulp, Rundreise 0 | K2b-alt | s1
  m11344 K2b Selbsttest nach Reparatur (Tabellen 24-Bit-Mantisse+Exponent, Momente 60 Bit je Zeile) | log2 1,7e-7; isqrt 0 falsch; float32-Bau 0,5 ulp; Rundreise 0; Tabellen rel. 0,0 | K2b | s1
  m11345 K2b Rot | log2 1,0e-5; isqrt 200000; 8,5 ulp; Rundreise 200000; Tabellen 1,0e-5 (alle fuenf schlagen an) | K2brot | s1
  m11346 K3 t=1 Norm rel alt/GZ | 8,9e-5 (float64-Bezug: alt 8,9e-5, GZ 1,9e-8) | K3 | s1
  m11347 K3 t=1 Matrizen | w, m, v Codes 100 % gleich, groesste Codedifferenz 0; Zeilenskala <= 1,9e-7; m-Skala 8,9e-5; v-Skala 1,8e-4 (> 1e-4, im Wortlaut VERFEHLT, alle 13) | K3 | s1
  m11348 K3 t=150 Norm rel alt/GZ | 1,03e-4 (float64-Bezug: alt 1,03e-4, GZ 1,2e-8) | K3 | s1
  m11349 K3 t=150 Matrizen | w gleich >= 99,997 %, groesste Gewichtsdifferenz 1 (alle erfuellt); m gleich 99,80-99,97 %, groesste m-Codedifferenz bis 109 (VERFEHLT in 9 von 13); m-Skala bis 2,1e-4, v-Skala bis 1,6e-4 (VERFEHLT in 6) | K3 | s1
  m11350 K3 t=150 Gains | Schritt relL2 <= 6,6e-4, m <= 4,6e-5, v <= 7,8e-6 (erfuellt) | K3 | s1
  m11351 K3 Gegenversuch t=150, GZ mit der Norm des alten Pfads (SNAI_GZ_ADAMVGL_ALTNORM=1) | alle Kriterien erfuellt: w/m/v gleich >= 99,997 %, groesste Codedifferenz 1, 0 Faelle mit m-Differenz > 1, alle Skalen <= 2,3e-7 | K3alt | s1
  m11352 K3 Rot t=150 (K +10 %) | w-Kriterium in 9 von 13 Matrizen verfehlt (w gleich bis 94,6 %), Gains-Schritt relL2 0,10 | K3rot | s1
  m11353 K3 Einzelauskunft m-Codedifferenz > 1 (t=150) | alle gezeigten Faelle Ausloeschung: altes m gross (Code ~110-127), Gradient entgegengesetzt, neues m ~1e-5 des Zeilenmaximums | K3 | s1
  Quelle: log/I_R3c.log, log/I_R3calt.log (isoliert, Segment 0, s1), log/st2/ und log/st3/gesch_d96h6L2_sN.mess.jsonl, log/st3/*.train.log (Saettigungszeilen), reihe_gz.log 18:21-18:38
  m11354 K3 t=3000 Norm rel alt/GZ | 4,0e-5 (float64-Bezug: alt 4,0e-5, GZ 2,8e-8) | K3 | s1
  m11355 K3 t=3000 Matrizen | w gleich >= 99,997 %, groesste Gewichtsdifferenz 1; m gleich 99,88-99,99 %, groesste m-Codedifferenz bis 14 (VERFEHLT in 6 von 13); Skalen <= 8,4e-5 | K3 | s1
  m11356 K3 t=3000 Gains | Schritt relL2 <= 1,4e-4, m <= 2,3e-5, v <= 2,8e-7 (erfuellt) | K3 | s1
  m11357 K3 Gegenversuch t=3000 (alte Norm eingespeist) | alle 13 Matrizen und 5 Gains im Kriterium, 0 Faelle m-Codedifferenz > 1 | K3alt | s1
  m11358 K4 Held-out Loss Stufe 3 | 2,6177 | st3 | s1 | 300
  m11359 K4 Held-out Loss Stufe 3 | 2,6254 | st3 | s2 | 300
  m11360 K4 Held-out Loss Stufe 3 | 2,6420 | st3 | s3 | 300
  m11361 K4 d = (st3-st2)/st2 | +0,11 % | st3 | s1
  m11362 K4 d = (st3-st2)/st2 | -0,02 % | st3 | s2
  m11363 K4 d = (st3-st2)/st2 | -0,14 % | st3 | s3
  m11364 Messgeraet Rot (Fenster gemischt) | 8,43 / 8,52 / 8,50 (st3) | Rot
  m11365 K5 Saettigungen im Adam | 0 in allen 15 Berichten (je Lauf adam_t 1000-5000) | K5
  m11366 Laufzeit Segment 0 (2 Faeden) | 887-894 s (st3) gegen 745-756 s (st2) | Zeit
Ergebnis e680 [2026-11-15 19:04]: erfuellt
  Fazit: Erfüllt in Lesart B, im Wortlaut verfehlt (e678). Grund der Abweichung: Der alte Pfad summiert die Clip-Norm in float32 und liegt damit selbst neben float64, und zwar um 8,9e-5 bei t=1, 1,03e-4 bei t=150 und 4,0e-5 bei t=3000. Die Ganzzahl-Norm liegt bei 1,9e-8, 1,2e-8 und 2,8e-8. Bei Auslöschungen (altes m groß, Gradient entgegengesetzt) wird dieser relative Normfehler von 1e-4 vielfach verstärkt, daher m-Codedifferenzen bis 109 im Wortlaut. Den Wortlaut kann nur ein Pfad erfüllen, der den float32-Summierfehler nachahmt. Wahl von Lesart B: Entscheidung des Autors am 15.11. auf Rückfrage am Haltepunkt (Antwort „Lesart B gilt“, interne Notiz). Lesart B heißt: K3 bei gleicher Norm, also mit der Norm des alten Pfads eingespeist (SNAI_GZ_ADAMVGL_ALTNORM=1), mit den unveränderten Schwellen, dazu die Ganzzahl-Norm gegen float64 ≤ 1e-6. So gemessen sind alle K3-Schwellen bei t=150 und t=3000 erfüllt, ebenso K1, K2, K2b, K4 (Gleichstand 3/3) und K5. Folge: Der Optimierer ist ganzzahlig und kostet über ein Segment nichts. Spätere Stufen vergleichen gegen eine float64-Referenz bei gleichem Eingang, nicht gegen eine float32-Summe als Wahrheit. Diese Fassung löst e679 nur wegen des ausführlicheren Fazits ab (Wunsch aus der Veröffentlichung); die Zahlen und das Urteil sind dieselben.
  Offen: Ein Segment, Knirps 96x2, ein Datensatz. Gains-Gradient und Lookup-Anteil des Embedding-Gradienten noch float-Kleber (Stufen 4 und 8). Laufzeit +19 % gegen Stufe 2. Schlussprüfung (gesamt und je Stufe einzeln) steht aus.
  Datei: rechner-a:~/snai_pruef/fullint8/ERGEBNIS_ST3.md
Abgeloest und ausgeblendet: 2 ergebnis - voll=True zeigt sie.
Chronik (juengste 8 von 10, voll=True zeigt alle):
  2026-11-15 18:22 Status geplant -> laeuft (Rezept r723)
  2026-11-15 18:22 Messwerte m11339-m11353
  2026-11-15 18:40 Messwerte m11354-m11366
  2026-11-15 18:40 Ergebnis e678: teilweise
  2026-11-15 18:40 Status laeuft -> ausgewertet (Ergebnis e678)
  2026-11-15 18:44 Kriterium geaendert, vorher: Volltext docs/messreihen/fullint8/KRITERIEN_ST3.txt. K1: Stufen 0/1/2 mit der neuen Lib bytegleich zu 0f79d04c/47176fa4/12e40925, Stufe 3 deterministisch. K2: ganzer Optimiererschritt unter FE_UPWARD (alle Fäden) und FE_TONEAREST bytegleich; Rot (float32-Mult. je Zeile) mind. eine Abweichung. K2b (nach Prüfer): Selbsttest log2 <= 1e-6, isqrt 0 falsch, float32-Bau <= 0,5 ulp, Rundreise 0, Tabellen rel. <= 1e-6; Rot: alle fünf schlagen an. K3: gegen den alten float-Adam (unverändert aufgerufen, beide zum Nächsten gerundet) bei t=1, 150, 3000: Norm rel <= 2e-3; je Matrix Gewichtscodes gleich >= 99,5 %, max|dw| <= 1; m-/v-Codes gleich >= 99 %, max|d| <= 1; Zeilenskalen rel <= 1e-4; Gains relL2 Schritt <= 1e-2, m/v <= 1e-3; Rot (K +10 %) reißt w in mind. einer Matrix. K4: Segment 0, s1-s3 gepaart, d = (st3-st2)/st2 <= +2 % in 3/3, sonst Haltepunkt. K5: Sättigungszähler vor dem Urteil ansehen. Urteil erfuellt = K1-K5. | Grund: Entscheidung des Autors 2026-11-15 (Rueckfrage am Haltepunkt, Antwort "Lesart B gilt"): Der alte Bezug summiert die Clip-Norm in float32 und liegt selbst 4e-5 bis 1e-4 neben float64; den Wortlaut kann nur ein Pfad erfuellen, der diesen Summierfehler nachahmt. Gemessen vor der Aenderung: Wortlaut verfehlt, Lesart B erfuellt (e678).
  2026-11-15 18:44 Ergebnis e679: erfuellt, loest e678 ab
  2026-11-15 19:04 Ergebnis e680: erfuellt, loest e679 ab
```
