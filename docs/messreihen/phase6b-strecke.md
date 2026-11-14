# snai/phase6b-strecke

```text
snai/phase6b-strecke - ausgewertet, angelegt 2026-10-29, zuletzt 2026-10-29 20:47
Frage: Läuft die Adapter-Strecke aus Phase 6 (eingefrorene Basis + LoRA Rang 8 je Aufgabe) an prod512b fehlerfrei und messtechnisch sauber durch, einmal am vorläufigen Stand s6 mit der Aufgabe instruktion und dem Kontrollarm enzyklopaedie? Matrix nur als Beobachtung (eine Saat).
Kriterium (festgelegt 2026-10-29 05:13, vor dem ersten Messwert):
  Strecke (trägt das Urteil): S1 alle Läufe rc 0, Fehlerkanal leer, GPU_BACKEND=NONE, Logzeilen LoRA Rang 8 / Basis eingefroren / Tying / Ganzzahl-Stack, 6 Epochen. S2 Verpflanzungsprobe beider Adapter bitgleich. S3 Basis md5 vorher = nachher (d9e3d9d1). S4 jede Matrixzelle gepaart mit diagnose/compare_full_paired.php (bricht bei abweichendem Fensterschnitt ab; Rot-Probe am alten s11-Paar rc 1 gesehen; NICHT tools/gepaart.py, das blind -0,5054 liefert). S5 Matrix vollständig (2 Adapter x 4 Prüfsätze + 4 Nullpunkte, je 64 Fenster). erfuellt = S1-S5, sonst verfehlt. Beobachtung (vorab notierte Erwartung): instruktion gewinnt auf SFT-Gemma (|t|>2), auf Prosa/Enzyklopädie nicht; Kontrollarm auf SFT-Gemma weniger; [SYMBIO]-Lecks (Vorkommen im erzeugten Text nach dem Prompt, Korsett-Spur, Beam 3, 4 Referenzprompts) mit instruktion weniger als ohne Adapter und als mit Kontrollarm. Endstand Epoche 6 vorab festgelegt (Epochenwahl liefe auf denselben Fenstern). Rang 8, LR 2e-4, LoRA-Saat 1234567. Prüfer vorab, Einwände in der Kriteriendatei.
Plan: rechner-a + rechner-b: ~/snai_pruef/phase6b/kriterien.txt (md5 7bf1c402; Vorfassung 23f15ab5, nur Wortlaut: Bytezahl Kontrollkorpus, Schritt 4 Werkzeug wie S4, Schritt 5 mit Kontrollarm)
Baut auf: snai/phase6-instruktion
Darauf baut: snai/phase6-pruefsaetze, snai/phase6d-arme
Rezepte:
  r454 [2026-10-29] cd ~/snai_pruef/phase6b && setsid nohup ./lauf_phase6b.sh > lauf.out 2>&1 < /dev/null &
      quelltext: lauf_phase6b.sh d27a14a3; Arbeitskopie proj/ aus Projektbaum snai_edge_int8_lora (git 48b983f + nicht committete DS-Voreinstellung in snai_inference.php) mit run_adapter.sh 6e65f9fc, run_basis_einfrieren.sh e75f8637, tools/adapter_waehlen.sh 1050a759 (Originale gesichert in rechner-a ~/snai_pruef/phase6b/vor_patch/); symbio_vocab.json f020d0ca, revival_config.json 65f7ffc8 (aus), libcortex.so 9d02d504
      parameter: Basis prod512b_s6 d9e3d9d1 (8 Koepfe); Rang 8, 6 Epochen, LR 0,0002, Endstand (SNAI_PHASE6_ENDSTAND=1); 64 Fenster je Pruefsatz; Lesen: Korsett, Beam 3, 4 Prompts aus tools/referenz_inferenz.sh; OMP_NUM_THREADS=6 SNAI_FORCE_CPU=1 SNAI_INT8_FULL=1
      seed: LoRA-Saat 1234567 (eine Saat)
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/phase6b/ (fortschritt.log, einfrieren.log, null64_*.txt, adapter_*.log, m_*_*.txt, vergleich_*_*.txt, lese_*.txt/.err); jsonl in proj/factory/checkpoints/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b ~/snai_pruef/phase6b: einfrieren.log, null64_*.txt, fortschritt.log, lese_ohne.txt; Fehlerkanal (Fatal|NaN|NET2NET|VETO|Warn) aller vier Dateien plus lese_ohne.err je 0 Treffer
  m6244 nullpunkt64 holdout_prod nats | 3,522281 | ohne Adapter | - | 64
  m6245 nullpunkt ganz holdout_prod nats | 3,621703 | ohne Adapter | - | 577
  m6246 nullpunkt64 holdout_sft_gemma nats | 4,019629 | ohne Adapter | - | 64
  m6247 nullpunkt64 holdout_sft nats | 3,961993 | ohne Adapter | - | 64
  m6248 nullpunkt64 holdout_prosa nats | 4,40735 | ohne Adapter | - | 64
  m6249 SYMBIO-Lecks Korsett Beam 3 (4 Prompts) | 0 | ohne Adapter | - | 4
  Quelle: rechner-b ~/snai_pruef/phase6b/proj/factory/checkpoints/train_adapter_instruktion.jsonl, abgelesen 2026-10-29 09:51; adapter_instruktion.log Fehlerkanal 0 Treffer. e3 ab ~07:25 unter TDC-Mitlast.
  m6274 Epochenkurve holdout_sft_gemma nats (nur berichtet, Endstand zählt) | 3,753698 / 3,706564 / 3,677782 | instruktion e1 / e2 / e3 | 1234567 | 64
  m6275 Epochendauer s inkl. Epochen-Eval | 3142 / 3323 / 3607 | instruktion e1 / e2 / e3 | 1234567 | 1
  Quelle: rechner-b ~/.cache/adapter_instruktion/train.log und lauf.log, ~/snai_pruef/phase6b/adapter_instruktion.log, proj/factory/checkpoints/train_adapter_instruktion.jsonl; abgelesen 2026-10-29 13:20
  m6292 Epochenkurve holdout_sft_gemma nats (nur berichtet, Endstand zählt) | 3,667093 / 3,66136 / 3,659933 | instruktion e4 / e5 / e6 | 1234567 | 64
  m6293 Held-out Endstand holdout_sft_gemma nats (Verpflanzung: eigenes Modell = eingefrorene Basis) | 3,659933 / 3,659933 | instruktion e6 | 1234567 | 64
  m6294 S1 Logzeilen (LoRA Rang 8 eingefroren, Tying, Ganzzahl-Stack, GPU_BACKEND=NONE, Fehlerkanal) | je 6/6, 6 Epochen, 0 Fehlerzeilen | instruktion | 1234567 | 6
  m6295 Trainingsdauer | 346 min | instruktion | 1234567 | 1
  Quelle: rechner-b ~/snai_pruef/phase6b: fortschritt.log, adapter_enzyklopaedie.log, ~/.cache/adapter_enzyklopaedie/train.log, proj/factory/checkpoints/train_adapter_enzyklopaedie.jsonl, vergleich_*_*.txt (diagnose/compare_full_paired.php, jede Zelle "Fensterschnitt geprueft und identisch"), m_*_*.txt, lese_*.txt/.err; abgelesen 2026-10-29 20:50. Fehlerkanal (Fatal|NaN|NET2NET|VETO|Warn|error) in train.log, allen 8 m_*.txt und allen 3 lese_*.err je 0 Treffer. Gewinn = B - A gegen den Nullpunkt DESSELBEN Prüfsatzes, negativ = Adapter besser; t = gepaarter Mittelwert in sigma.
  m6379 Epochenkurve holdout_prod nats (nur berichtet, Endstand zählt) | 3,478324 / 3,470683 / 3,469692 / 3,472013 / 3,471358 / 3,471441 | enzyklopaedie e1-e6 | 1234567 | 64
  m6380 Held-out Endstand holdout_prod nats (Verpflanzung: eigenes Modell = eingefrorene Basis) | 3,471441 / 3,471441 | enzyklopaedie e6 | 1234567 | 64
  m6381 S1 Logzeilen (LoRA Rang 8 eingefroren, Tying, Ganzzahl-Stack, GPU_BACKEND=NONE, Fehlerkanal) | je 6/6, 6 Epochen, 0 Fehlerzeilen | enzyklopaedie | 1234567 | 6
  m6382 Trainingsdauer | 377 min | enzyklopaedie | 1234567 | 1
  m6383 Matrix gepaarter Gewinn holdout_sft_gemma nats | -0,3597 (t 54,0; 64:0 Fenster) | instruktion | 1234567 | 64
  m6384 Matrix gepaarter Gewinn holdout_sft nats | +0,1441 (t 34,5; 0:64) | instruktion | 1234567 | 64
  m6385 Matrix gepaarter Gewinn holdout_prosa nats | +0,4660 (t 67,2; 0:64) | instruktion | 1234567 | 64
  m6386 Matrix gepaarter Gewinn holdout_prod nats | +0,1698 (t 30,9; 0:64) | instruktion | 1234567 | 64
  m6387 Matrix gepaarter Gewinn holdout_sft_gemma nats | -0,0638 (t 34,4; 64:0) | enzyklopaedie | 1234567 | 64
  m6388 Matrix gepaarter Gewinn holdout_sft nats | -0,0113 (t 4,7; 48:16) | enzyklopaedie | 1234567 | 64
  m6389 Matrix gepaarter Gewinn holdout_prosa nats | -0,0465 (t 18,7; 64:0) | enzyklopaedie | 1234567 | 64
  m6390 Matrix gepaarter Gewinn holdout_prod nats | -0,0508 (t 23,5; 63:1) | enzyklopaedie | 1234567 | 64
  m6391 Matrix rc (eval / Vergleich) | 8/8 rc 0 / 8/8 rc 0 | beide Adapter | 1234567 | 8
  m6392 SYMBIO-Lecks Korsett Beam 3 (4 Prompts), Adapter geladen 4/4 | 0 | instruktion | 1234567 | 4
  m6393 SYMBIO-Lecks Korsett Beam 3 (4 Prompts), Adapter geladen 4/4 | 0 | enzyklopaedie | 1234567 | 4
  m6394 S3 Basis md5 vorher / nachher | d9e3d9d1 / d9e3d9d1 | Basis prod512_basis.snai | - | 1
Ergebnis e404 [2026-10-29 20:47]: erfuellt
  Fazit: Strecke an prod512b einsatzbereit: S1-S5 erfüllt (alle rc 0, Fehlerkanal leer, Verpflanzung bitgleich 3,659933 bzw. 3,471441 = Epochenwert e6, Basis d9e3d9d1 vorher = nachher, 8/8 Zellen gepaart mit identischem Fensterschnitt). Vor der echten Reihe reparieren: Pfadvergleich holdout_dir in run_adapter.sh (Schrägstrich), sonst bricht der eingebaute Vergleich ab. Beobachtung (eine Saat): instruktion -0,36 auf SFT-Gemma, aber +0,14 auf HF-SFT, +0,47 Prosa, +0,17 prod; Kontrollarm überall leicht besser (-0,01 bis -0,06), wirkt an s6 wie fortgesetztes Vortraining und taugt dort nicht als Nullkontrolle. Folge für Phase 6: Die echte Reihe muss den Schaden außerhalb der Aufgabe messen, mit einem zweiten Instruktionssatz als Prüfsatz (Aufgabe gelernt oder Korpusform gelernt?), Kontrollarm an der fertigen Basis wieder mitfahren; Adapter nur für ihre Aufgabe einschalten. Lecks 0 in allen drei Armen.
  Datei: rechner-a + rechner-b ~/snai_pruef/phase6b/ERGEBNIS_phase6b.md (904359b1)
Chronik (juengste 8 von 14, voll=True zeigt alle):
  2026-10-29 07:00 Zwischenstand 2026-10-29 07:00: Schritte 1, 2 und Lesen ohne Adapter fertig, alle rc 0, Fehlerkanal leer. Ohne Adapter 0 [SYMBIO]-Lecks: Die Beobachtungs-Erwartung "mit Adapter weniger als ohne" kann an s6 nicht eintreten (Boden 0); berichtet wird nur, ob ein Adapter Lecks erzeugt. Ausgabe ohne Adapter beginnt schon im Assistentenstil ("Natürlich! Hier sind ..."), danach Listen-Schleifen. Adapter instruktion seit 06:50, ~6,3 s/Schritt (Telemetrie Schritt 95 um 07:00), Schätzung ganz grob: Strecke fertig gegen Abend.
  2026-10-29 08:08 Ab ~07:25 am 2026-10-29 läuft TDC (tdc_v3ru-Lesungen, GPU, höchstens 4 Host-Schleifen je 1 Kern) parallel auf rechner-b. Folge: Laufzeiten der Adapter ab hier nicht mit früheren vergleichbar; Loss und md5 betrifft das nicht (CPU-Pfad deterministisch, feste OMP-Zahl). Nach dem Ende von phase6b TDC benachrichtigen.
  2026-10-29 09:51 Messwerte m6274, m6275
  2026-10-29 13:19 Messwerte m6292-m6295
  2026-10-29 13:19 Adapter instruktion fertig 12:52, rc 0, S1 und S2 für diesen Arm erfüllt. Endstand-Prüfung: md5-Vergleich der .lora-Dateien taugt NICHT (das Merge setzt einen Fingerabdruck in den Kopf, alle Dateien md5-verschieden); stattdessen: factory/adapter/instruktion.lora misst bitgleich 3,659933 = Epochenwert e6 (e1-e5 alle verschieden, Kurve fällt monoton, beste Epoche = e6 = Endstand). ABWEICHUNG: Der in run_adapter.sh eingebaute gepaarte Vergleich brach mit rc 1 ab, weil holdout_dir 'factory/holdout_sft_gemma/' (Nullpunkt) gegen 'factory/holdout_sft_gemma' (Treiber übergibt den Pfad ohne Schrägstrich) als Zeichenkette verglichen wird. Das Werkzeug hat richtig (vorsichtig) abgebrochen, keine falsche Zahl. Die Matrix (Schritt 4) ist nicht betroffen: Nullpunkte und Matrixmessungen tragen beide den Pfad mit Schrägstrich. Für die Strecke als Befund: run_adapter.sh sollte den Pfad normalisieren (rtrim '/'), sonst bricht die Paarung je nach Schreibweise ab. Enzyklopaedie läuft seit 12:52.
  2026-10-29 20:46 Messwerte m6379-m6394
  2026-10-29 20:47 Ergebnis e404: erfuellt
  2026-10-29 20:47 Status laeuft -> ausgewertet (Ergebnis e404)
```
