# snai/engine-emb-eingang

```text
snai/engine-emb-eingang - ausgewertet, angelegt 2026-11-03, zuletzt 2026-11-03 07:50
!! ohne Rezept
Frage: Repariert der Embedding-Eingangsfaktor F = sqrt(128) die toten FFN-Gains auch in der 8-Bit-Engine, bei gleich gutem oder besserem Held-out? Engine-Fassung von snai/torch-emb-eingang (Torch: BESSER -0,0367 8/8, L2 tot 4 % gegen 67 %).
Kriterium (festgelegt 2026-11-03 06:39, vor dem ersten Messwert):
  AUFBAU
Engine wie K1: clip_lns/lauf_clip_lns.sh, voll int8, gebunden, SR, Clip 1, LR 0,003 konstant, WD 0,1, Warmup 500, kurz9000, 9.002 Schritte, CPU. Saaten 4-11, gleicher Sitzungsname clip_s<s> wie K1, also gleiche Fensterfolge.
Bibliothek: bau_emb_voll/libcortex.so (737d5f7f) über CLIP_LIB. Gebaut aus proj_clip/cortex.nim (f393b841) mit werkzeug/patch_emb.py, assert-gesichert, an 11 Stellen. Vorwärts liest die Engine das Embedding x F in int8-Training (gebündelt und je Token), int8-Inferenz, float-Inferenz und float-Training. Rückwärts geht der Embedding-Gradient der Eingangsseite x F in alle vier Pfade. Die Ausgabeseite (gebunden) bleibt unverändert.
Einziges Stellrad: SNAI_EMB_EIN=11.3137085 im Arm EE, in Training und Messung. Gegenarm K1: vorhandene Läufe clip/laeufe/reihe_dc/K1_s*.

KONTROLLEN VOR DEM START (gesehen)
- F nicht gesetzt und F=1,0: Schritt 1-3 zeichengleich mit K1 s4 (7,522868 / 11,6736 usw.).
- F=11,31: Schritt 1 Loss 7,792130, GN 1,9256 gegen Torch TEE 7,792756 / 1,9240. Schritt 2-3 GN 1,9763 / 2,2497 gegen 1,9762 / 2,2493.
- Rot der Gradientenprüfung: Lib ohne Rückwärtsfaktor (bau_emb_rot, 81ad284c) gibt GN 1,5193 statt 1,9256, Vorwärts gleich. Die globale Norm sieht also einen fehlenden Faktor im Rückwärtspfad (Erwartung aus der Torch-Zerlegung: rund 1,52). Das ersetzt die endliche Differenz, weil die int8-Gewichte nicht stetig sind; Torch-Autograd ist hier das unabhängige Gegenstück.

KONTROLLEN IM LAUF
- K1C: K1 s4 mit der gepatchten Lib, F nicht gesetzt, voller Lauf, muss md5 ee903784 ergeben.
- rc=0, STEPS_DONE 9002, SR aktiv, Revival aus, [CLIP]-Zeile 1.0 (von Hand, weil CLIP_LIB die Skriptprüfung abschaltet), [EMBEIN]-Zeile 11.313708 im Training und in jeder Messung.
- Fehlerkanal: „korrigiert“ macht die Saat ungültig.
- Rot der Messung: Der Endstand EE s4 ohne SNAI_EMB_EIN gemessen muss abweichen.

SCHRITT 0, MANIPULATIONSPRÜFUNG (vor jedem Urteil)
(a) F·RMS E(EE) >= 3 x RMS E(K1) in >=6/8 am Ende, auch an t1000 und t3000 abgelesen. E ist das dequantisierte Embedding, gelesen mit clip/werkzeug/lesen_tie2.php.
(b) Zweig/R in L0, größerer Zweig, Messung multi_stack mit einer Messlib, die F ebenfalls anwendet: EE <= 1/3 K1 in >=6/8.
Fällt eine der beiden durch, lautet das Urteil „Eingriff ausgeglichen“. Das ist ein Befund für sich, keine Aussage zur Hypothese.

HAUPTGRÖSSE
D = L(EE) - L(K1) am Ende, Held-out mess_text mit 700 Fenstern.
- BESSER: Mittel <= -0,02 und D<0 in >=6/8.
- GLEICH: |Mittel| < 0,01 und |D| < 0,02 in >=6/8.
- SCHLECHTER: Mittel >= +0,02 und D>0 in >=6/8.
- Sonst OFFEN.
Liegt ein Wert innerhalb 0,003 um eine Schwelle, folgt eine Wiederholung auf heldout2 und ein Bootstrap.

REPARATUR GAINS
Erfüllt, wenn Schritt 0 hält, die Hauptgröße BESSER oder GLEICH ist und der Anteil toter L2-rms_ffn (|g|<0,05) bei EE höchstens halb so groß ist wie bei K1, in >=6/8.

NEBENGRÖSSE MITARBEIT (wie TEE)
Erfüllt, wenn die n123-Kosten bei EE mindestens doppelt so hoch sind wie bei K1, in >=6/8. Nullsetzen mit nullsetzen.php, Messung mit F.

BEOBACHTUNG
Tote Gains je Schicht, g_final, Clip-Anteil (GN > 1), D an t1000 und t3000, Zensus multi_stack.

GEMEINSAM VERÄNDERT
Eingangsskala, Verhältnis der Gradienten Eingang zu Ausgabe am Embedding, Gradientennorm (Schritt 1: 11,67 gegen 1,93), damit der Clip-Anteil. Dazu die int8-Rundung des Embeddings: Die Zeilenskala gilt für emb, F wirkt erst nach dem Dequantisieren. Größter freier Parameter ist F. Ein Nein gilt nur für F=11,31.
Reichweite: int8, K1-Rezept, ein Text, 9.002 Schritte, 128x4.
Baut auf: snai/torch-emb-eingang, snai/engine-ffn-weg
Darauf baut: snai/multistack-uebernahme-emb, snai/multistack-ee-512, snai/prod512b-gains-s9, snai/multistack-ee-64, snai/ee-lr-spaet
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b ~/snai_pruef/clip_lns/log/ee.log, laeufe/ee/*, log/ee_null.jsonl, log/ee_lesen.jsonl (lesen_tie2.php), werkzeug/ausw_ee.py -> log/ee_ausw.txt; K1 clip/laeufe/reihe_dc, n123 K1 null2/erg.jsonl (f123)
  m8164 Kontrolle K1C s4 (gepatchte Lib, F aus, voller Lauf) | md5 ee903784 = K1, Ende 2,6728 | K1C | s4 | 1
  m8165 Rot Messpfad EE s4 ohne F gemessen | 6,6762 statt 2,6187 | EE | s4 | 1
  m8166 Kontrollen je Saat | rc 0, STEPS_DONE 9002, [EMBEIN] 11.31 im Training 1x und in der Messung 3x, CLIP 1.0, SR 1, Fehlerzeilen 0 (keine NET2NET-Meldung toter Kanaele), korrigiert 0 in 8/8 | EE | s4-s11 | 8
  m8167 Schritt 0 (a) F*E(EE)/E(K1) t1000 / t3000 / Ende | 10,89-11,15 / 10,65-10,81 / 11,03-11,20; >= 3 in 8/8 an allen Staenden; E Ende EE 0,1121, K1 0,1142 | EE gegen K1 | s4-s11 | 8
  m8168 Schritt 0 (b) | ausstehend, multi_stack quelle3/m4.sh mit F | EE gegen K1 | s4-s11 | 8
  m8169 Held-out Ende EE | 2,6187 / 2,6537 / 2,6404 / 2,6723 / 2,6364 / 2,6414 / 2,6810 / 2,6346, Mittel 2,6473 | EE | s4-s11 | 8
  m8170 D = EE - K1 | -0,0541 / -0,0550 / -0,0336 / -0,0408 / -0,0197 / -0,0523 / -0,0095 / -0,0304; Mittel -0,0369; besser 8/8; Bootstrap 95 % -0,0473 bis -0,0257; 1,4 % | EE gegen K1 | s4-s11 | 8
  m8171 D an t1000 / t3000 Mittel | -0,0291 / -0,0377 | EE gegen K1 | s4-s11 | 8
  m8172 L2 rms_ffn tot Ende | EE 1,6 / 4,7 / 3,1 / 0,8 / 2,3 / 20,3 / 0,8 / 3,9 %; K1 79,7 / 0,8 / 22,7 / 49,2 / 61,7 / 59,4 / 60,2 / 85,9 %; EE <= K1/2 in 7/8 (s5 nicht: K1 dort 0,8) | EE, K1 | s4-s11 | 16
  m8173 tot Ende Mittel FFN L0-L3 / Attention L0-L3 | EE 0 / 0,5 / 4,7 / 1,7 und 7,5 / 3,4 / 2,1 / 0,5; K1 0 / 1,8 / 52,5 / 0,6 und 35,5 / 3,0 / 1,2 / 0,1 | EE, K1 | s4-s11 | 16
  m8174 n123-Kosten | EE 0,269 / 0,155 / 0,183 / 0,217 / 0,145 / 0,103 / 0,186 / 0,165 (Mittel 0,178); K1 0,256 / 0,233 / 0,174 / 0,230 / 0,120 / 0,221 / 0,205 / 0,188 (Mittel 0,203); EE >= 2 x K1 in 0/8 | EE, K1 | s4-s11 | 16
  m8175 Tote Embedding-Zeilen (zeilen_lang.php, Stufen <= 1) | 0 von 1509 in EE und K1, 8/8; Median-Stufen EE 32-33, K1 32-33 | EE, K1 | s4-s11 | 16
  m8176 g_final RMS Ende Mittel | EE 0,885, K1 0,859 | EE, K1 | s4-s11 | 16
  Quelle: multi_stack rechner-b ~/snai_pruef/nz/z6 (quelle3 31df8c5c, m4.sh, EE mit F, K1 ohne F)
  m8183 Schritt 0 (b) max(Att/R, FFN/R) L0 EE/K1 t1000 / t3000 / Ende | 0,117-0,142 / 0,098-0,116 / 0,078-0,096; <= 1/3 in 8/8 an allen Staenden, nahe 1/F | EE gegen K1 | s4-s11 | 8
  m8184 Kontrollen Messlib | K1C_s4 Ende 2,6728, alle Zeilen bytegleich zu K1_s4; Rot EE_s4 ohne F 6,6762; Fehlerkanal nur [EMBEIN]-Zeilen (24x 11.31, 18x 1.0) | EE, K1 | s4-s11 | 16
  m8185 FFN/R L0-L3 Median Ende | EE 7,4 / 0,131 / 0,102 / 0,326; K1 88,2 / 0,127 / 0,040 / 0,380 | EE, K1 | s4-s11 | 16
  m8186 Att/R L0-L3 Median Ende | EE 0,54 / 0,25 / 0,26 / 0,30; K1 0,41 / 0,26 / 0,29 / 0,34; R0 EE 17,6, K1 1,59 | EE, K1 | s4-s11 | 16
  m8187 Zensus Anteil arbeitend L2 (Beobachtung, Klassen nicht funktional, e486) | EE 0,46 / 0,29 / 0,15 / 0,56 / 0,14 / 0,19 / 0,65 / 0,31; K1 0,016-0,365; lineare Neuronen 0-4 | EE, K1 | s4-s11 | 16
Ergebnis e491 [2026-11-03 07:50]: erfuellt
  Fazit: REPARATUR GAINS erfuellt. Schritt 0 haelt: (a) 10,7-11,2 und (b) 0,08-0,14, je 8/8 an allen drei Staenden. Hauptgroesse BESSER: D -0,0369, 8/8, Bootstrap -0,047 bis -0,026, 1,4 %, in der Groesse wie Torch. L2 tot hoechstens halb so viel wie bei K1 in 7/8 (Mittel 4,7 % gegen 52,5 %), Attention L0 7,5 % gegen 35,5 %. Keine NET2NET-Meldung toter Kanaele und keine toten Embedding-Zeilen. Kontrollen vollstaendig: K1C md5 = K1, Rot im Rueckwaerts- und Messpfad, Schritt 1 gleich Torch. MITARBEIT nicht erfuellt (n123 0,178 gegen 0,203), die mittleren FFN bleiben entbehrlich. Folge: Die Ursache der toten Gains ist isoliert (kleines Embedding unter Bindung) und in 8 Bit repariert. Fuer den Projektbaum muss der Faktor ans Modell gebunden werden, weil alte Modelle mit F gemessen 0,05 nats verlieren. prod512b ist nicht gemessen.
  Offen: Groesseres Modell (prod512b) und laengeres Budget nicht gemessen. Nur F = sqrt(d). Mechanismus der Held-out-Verbesserung nicht isoliert. Einbau in den Projektbaum braucht die Zustimmung.
  Datei: rechner-a:~/snai_pruef/clip_lns/ERGEBNIS_engine_emb_eingang.md
Chronik:
  2026-11-03 06:39 angelegt
  2026-11-03 06:44 Vor dem Start (06:41), noch ohne Messwert: Die [EMBEIN]-Meldung ging zuerst auf stdout. Das hätte die JSON-Ausgabe von mess_text zerstört. Sie steht jetzt auf stderr.
Die Bibliothek ist deshalb neu gebaut: cortex.nim b32ca8bc, libcortex.so 3475df5c statt 737d5f7f. Die Probe danach erneut: F aus, Schritt 1-3 zeichengleich mit K1; F=11,31 mit Schritt 1 7,792130 / GN 1,9256, unverändert.
Messpfad mit der neuen Lib: K1 s4 ohne F ergibt 2,6728 (gleich K1). Rot: K1 s4 mit F gemessen ergibt 2,7204, die Messung wendet F also an.
Gestartet: reihe_ee.sh, 4 zugleich, K1C s4 plus EE s4-s11. Log clip_lns/log/ee.log.
  2026-11-03 07:46 Messwerte m8164-m8176
  2026-11-03 07:46 Status geplant -> laeuft (Messwerte m8164-m8176)
  2026-11-03 07:50 Messwerte m8183-m8187
  2026-11-03 07:50 Ergebnis e491: erfuellt
  2026-11-03 07:50 Status laeuft -> ausgewertet (Ergebnis e491)
```
