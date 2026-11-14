# snai/residuum-gains

```text
snai/residuum-gains - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 15:21
Frage: Verstaerkt oder schwaecht der Reset des Fehler-Rueckfuehrungs-Restes, wie ihn jeder Segmentuebergang ausloest, das Kippen der FFN-Gains?
Kriterium (festgelegt 2026-11-02 12:56, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/clip_rr/kriterien.txt. Arm R = K1 aus snai/dauerclip-saaten (128x4, voll int8, gebunden, SR, LR 0,003, kurz9000, 9.002 Schritte, Karte, Saaten 4-11) plus Reset alle 1.000 Schritte; K1 unveraendert als Kontrollarm. Messgroesse: Anteil L2.rms_ffn |g|<0,05 am Endstand, D = R - K1 je Saat. VERSTAERKT: R>K1 in >=6/8 und mittleres D >= 20. SCHWAECHT: R<K1 in >=6/8 und mittleres D <= -20. KEIN HEBEL: |mittleres D| < 10. Sonst OFFEN; innerhalb 2 Punkten um eine Schwelle nicht erfuellt. Kontrollen: K1 s4 mit korrigierter Bibliothek ohne Reset md5 ee903784; ungefixte Bibliothek mit Reset ebenfalls ee903784 (Rot: belegt den Fehler bei Tying); R bis Schritt 1.000 zeichengleich K1, danach verschieden; je Lauf 9 Resets; Fehlerkanal. Notwendigkeit ist schon ohne diese Reihe beantwortet: K1 kippt ohne Reset. Reichweite: ein Modell, ein Text, 9.002 Schritte, 9 Resets als Ueberdosis gegen real rund einen je 138.000 Schritte, nur Gains, nicht die Norm.
Baut auf: snai/dauerclip-saaten, snai/wd-gains, snai/merkmal-gains-fp32
Rezepte:
  r517 [2026-11-02] rechner-b ~/snai_pruef/clip_rr/reihe.sh: lauf_clip.sh (Kopie) mit CLIP_GPU=1 CLIP_LR=0.003 SNAI_TEST_RESET_EVERY=1000; K0 (neue Lib, kein Reset), ROT (alte Lib, Reset-Haken), R s4-s11
      quelltext: proj_clip = clip/proj_clip plus eine Zeile in cortex_reset_i8_error_feedback (Fruehreturn auch bei gebundenem Modell nicht) und Haken in train_worker.php (SNAI_TEST_RESET_EVERY); Lib 4c9442cd, alte Lib ccb10b0f
      rechner: rechner-b, Karte, nacheinander, parallel zu Evos Stufe B ab 13:39
      logs: rechner-a:~/snai_pruef/clip_rr/ (log/reihe.log, kanal_rr.jsonl); rechner-b clip_rr/laeufe/reihe/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: clip_rr/log/reihe.log, kanal_rr.jsonl, K1-Werte aus snai/dauerclip-saaten (kanal_clip.jsonl)
  m7577 Kontrolle K0 s4 neue Lib ohne Reset md5 | ee903784 (= K1) | K0
  m7578 Rot ROT s4 alte Lib mit 9 Resets md5 | ee903784 (= K1, Reset wirkt dort nicht) | ROT
  m7579 Resets je Lauf / STEPS_DONE / Fehlerzeilen | 9 / 9002 / 0 in 8/8 | R
  m7580 L2 tot Ende | 85,9 / 2,3 / 15,6 / 50,8 / 67,2 / 71,1 / 68,0 / 90,6 | R | s4-s11 | 8
  m7581 L2 tot Ende | 79,7 / 0,8 / 22,7 / 49,2 / 61,7 / 59,4 / 60,2 / 85,9 | K1 | s4-s11 | 8
  m7582 D = R - K1 je Saat | +6,2 +1,5 -7,1 +1,6 +5,5 +11,7 +7,8 +4,7 | R gegen K1 | s4-s11 | 8
  m7583 mittleres D / Median / R > K1 | 4,0 / 5,5 / 7 von 8 | R gegen K1
  m7584 L1 tot Ende | 0 bis 3,9 % | R | s4-s11 | 8
  Quelle: Schrittzeilen train.log K1 gegen R, s4/s7/s11
  m7585 Paarung Schrittzeilen bis Schritt 1000 verschieden | 0 von 204 | R gegen K1 | s4, s7, s11
  m7586 Schrittzeilen 1001-1200 verschieden (Reset wirkt) | 40 von 40 | R gegen K1 | s4, s7, s11
Ergebnis e452 [2026-11-02 15:21]: verfehlt
  Fazit: KEIN HEBEL nach Kriterium: 9 Resets des Fehler-Rueckfuehrungs-Restes je Lauf (Ueberdosis gegen real rund einen je 138.000 Schritte) aendern den Totanteil der L2-Gains im Mittel um +4,0 Punkte (Schwelle 10), R > K1 in 7/8 bei kleinen Betraegen. Der Segmentuebergang ist als Ursache oder Verstaerker des Kippens aus dem Rennen; der letzte Kandidat aus der cortex.nim-Durchsicht ist damit abgehakt. Beobachtung: die schwache Richtung (7/8 leicht hoeher) ist mit dem Kriterium kein Befund.
  Offen: Held-out der R-Laeufe nicht gemessen (nicht im Kriterium). Ein Rezept, 9.002 Schritte, nur Gains; die Norm nicht betrachtet. Die Reparatur der Fruehreturn-Zeile bei Tying ist nur in der Messkopie, nicht im Projektbaum.
Chronik:
  2026-11-02 12:56 angelegt
  2026-11-02 15:21 Rezept r517
  2026-11-02 15:21 Status geplant -> laeuft (Rezept r517)
  2026-11-02 15:21 Messwerte m7577-m7584
  2026-11-02 15:21 Messwerte m7585, m7586
  2026-11-02 15:21 Ergebnis e452: verfehlt
  2026-11-02 15:21 Status laeuft -> ausgewertet (Ergebnis e452)
```
