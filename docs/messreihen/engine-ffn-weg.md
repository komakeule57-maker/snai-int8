# snai/engine-ffn-weg

```text
snai/engine-ffn-weg - ausgewertet, angelegt 2026-11-03, zuletzt 2026-11-03 05:50
Frage: Ist das 8-Bit-Modell 128x4 ohne FFN-Zweige in L1-L3 von Anfang an so gut wie K1? Das wäre die Reparatur der "nutzlosen Schichten": In float32 ist TF0 nach Kriterium GLEICH zu TG (snai/torch-lns-zerlegung).
Kriterium (festgelegt 2026-11-03 03:57, vor dem ersten Messwert):
  Engine wie K1 (rechner-b clip_lns/lauf_clip_lns.sh: voll int8, gebunden, SR, Clip 1, LR 0,003 konstant, WD 0,1, Warmup 500, kurz9000, 9.002 Schritte, CPU), Saaten 4-11, gleicher Sitzungsname clip_s<saat> wie K1, also gleiche Fensterfolge. Arm EF0: Genesis clip_gen_s<s> mit rms_ffn und w_down in L1, L2, L3 exakt 0 (skaliere.php Faktor 0). Bei Gain 0 und w_down 0 sind alle Gradienten dieses Zweigs exakt 0, er bleibt aus. Kein Codeeingriff.
Haupt: D = L(EF0) - L(K1) am Ende, Held-out mess_text 700 Fenster, K1 aus clip/laeufe/reihe_dc/K1_s*/mess.jsonl. GLEICH (Reparatur trägt): |Mittel D| < 0,01 UND |D| < 0,02 in >= 6/8. BESSER: besser in >= 6/8 UND Mittel <= -0,02. SCHLECHTER: schlechter in >= 6/8 UND Mittel >= +0,02, dann helfen die Zweige im 8-Bit-Pfad beim Lernen. Sonst OFFEN. Größe nach 10-%-Hausregel. Daneben berichtet: EF0 gegen 128x2 (Z2, snai/tiefe-128x2-massstab) und gegen LNS.
Kontrollen, ohne die das Urteil nicht gilt: (a) Zweig bleibt aus: am Endstand ändert Nullsetzen von w_down L1-L3 (nullsetzen.php) den Loss um exakt 0,0000 in 8/8; (b) Genesis: skaliere.php meldet Mittel 0 für alle sechs Ziele; (c) Training rc=0, STEPS_DONE 9002, SR aktiv, Revival aus (Skript prüft); (d) Fehlerkanal Training und Messung: eine NET2NET-Meldung mit 'korrigiert' macht die Saat ungültig. Wenn (a) fehlschlägt (Wächter belebt die Gains), ist die Reihe ungültig, nicht SCHLECHTER.
Gemeinsam ändert sich: nur der Zweig; Rechenzeit gleich, weil die Engine Nullen mitrechnet, also keine Zeitaussage. Rot-Probe vor dem Lesen: Kontrolle (a) an einem K1-Endstand muss Kosten deutlich über 0 zeigen (bekannt 0,2034). Reichweite: int8, K1-Rezept, ein Text, 9.002 Schritte, 128x4.
Darauf baut: snai/engine-emb-eingang
Rezepte:
  r545 [2026-11-03] rechner-b ~/snai_pruef/clip_lns/reihe_ef0.sh (gestartet 2026-11-03 03:57, 2 zugleich): CLIP_GENPFX=ef0_ ./lauf_clip_lns.sh ef0 EF0 - <s> daten/kurz9000.txt 1000,3000 mit CLIP_LR=0.003, CLIP_OHNE_LOCK=1. Genesis proj_clip/factory/checkpoints/clip_gen_ef0_s<s>.snai = skaliere.php clip_gen_s<s> "1:rms_ffn=0,2:rms_ffn=0,3:rms_ffn=0,1:w_down=0,2:w_down=0,3:w_down=0" (alle 48 Meldungen Mittel 0,0000; Rot: Ziel 9:w_down abgewiesen, rc 2). Kontrolle (a): nullsetzen.php "1:w_down,2:w_down,3:w_down" am Endstand, log/ef0_null.jsonl. Zeilen log/ef0.log, Läufe laeufe/ef0/EF0_s*.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: Nachtrag vor dem ersten Ergebnis, Einwände Evo nach Quelltextprüfung
  m8043 Nachtrag Kriterium 1 | Gemeinsam ändert sich auch die Gradientennorm: Ohne die Gradienten von FFN L1-L3 greift der Clip bei 1 seltener (K1 rund 60 % der Schritte), die übrigen Tensoren bekommen größere Schritte. Das gehört zur Maßnahme Weglassen; Clip-Anteil oder Gradientennorm aus dem Trainingslog wird neben dem Urteil berichtet, bei BESSER oder SCHLECHTER als Erklärungskandidat.
  m8044 Nachtrag Kriterium 2 | K1-Endstand s4 wird mit der EF0-Bibliothek b72d9d76 nachgemessen; muss 2,6728 ergeben (K1 gemessen mit ccb10b0f), sonst kein gepaarter Vergleich.
  m8045 Nachtrag Kriterium 3 | Kontrolle (a) zusätzlich früh an snap t1000 von s4, Abbruch bei Belebung.
  Quelle: rechner-b mess_text.php mit SNAI_CORTEX_LIB proj_clip/libcortex.so (b72d9d76), K1 reihe_dc/K1_s4 Endstand
  m8046 Kontrolle Bibliothek: K1 s4 Endstand mit b72d9d76 | 2,6728, gleich dem Wert mit ccb10b0f; Fehlerkanal 0 korrigiert | K1 | 4
  Quelle: rechner-b laeufe/ef0/EF0_s4 snap t1000, nullsetzen.php + mess_text.php 100 Fenster
  m8047 Kontrolle (a) früh an t1000: Loss Stand / w_down L1-L3 genullt | 3,272 / 3,272, Unterschied 0; korrigiert 0; Wächter meldet nur tote Kanäle | EF0 | 4
  Quelle: rechner-b ~/snai_pruef/clip_lns/log/ef0.log, ef0_null2.jsonl, ef0_ho2.jsonl, laeufe/ef0/EF0_s*/train.log; K1 clip/laeufe/reihe_dc
  m8068 Held-out Ende EF0 s4-s11 | 2,6529 / 2,6898 / 2,6776 / 2,6885 / 2,6752 / 2,6721 / 2,6886 / 2,6699, Mittel 2,6768 | EF0 | s4-s11 | 8
  m8069 D = EF0 - K1 je Saat | -0,0199 / -0,0189 / +0,0036 / -0,0246 / +0,0191 / -0,0216 / -0,0019 / +0,0049; Mittel -0,0074; abs < 0,02 in 6/8; besser 5/8; Bootstrap 95 % -0,0174 bis +0,0033 | EF0 gegen K1 | s4-s11 | 8
  m8070 Wiederholung heldout2 (knapp an Schwelle): EF0 | 2,6339 / 2,6828 / 2,6637 / 2,6765 / 2,6681 / 2,6623 / 2,6712 / 2,6557 | EF0 | s4-s11 | 8
  m8071 Wiederholung heldout2: K1 | 2,6630 / 2,6946 / 2,6652 / 2,7014 / 2,6487 / 2,6853 / 2,6794 / 2,6560 | K1 | s4-s11 | 8
  m8072 D heldout2 je Saat | -0,0291 / -0,0118 / -0,0015 / -0,0249 / +0,0194 / -0,0230 / -0,0082 / -0,0003; Mittel -0,0099; abs < 0,02 in 5/8; besser 7/8; Bootstrap -0,0196 bis +0,0009 | EF0 gegen K1 | s4-s11 | 8
  m8073 Kontrolle (a) Nullsetzen w_down L1-L3 am Endstand | Unterschied 0,0000 in 8/8 (nachkontrolle_ef0.sh; eingebaute Fassung scheiterte an relativem Pfad, Kopf unlesbar) | EF0 | s4-s11 | 8
  m8074 Rot-Probe laut Kriterium: (a) an K1 s4 | 2,9286 gegen 2,6728, Kosten 0,2558; zusaetzlich w_down L0 an EF0 s4 7,2567 | K1, EF0 | s4 | 2
  m8075 Kontrollen (c)/(d) | rc 0, STEPS_DONE 9002, SR, Revival aus 8/8; Fehlerkanal je 3 erwartete Waechtermeldungen tote L1-L3, korrigiert 0 in Training, Messung, Nachkontrolle, heldout2 | EF0 | s4-s11 | 8
  m8076 Clip-Anteil (GradNorm > 1 der geloggten Schritte) | EF0 64-77 % (Median GN 1,04-1,08); K1 51-68 % (1,00-1,06); EF0 clippt haeufiger | EF0, K1 | s4-s11 | 16
  m8077 Daneben EF0 gegen Z2 / LNS (Mittel) | -0,042 / +0,040 | EF0 | s4-s11 | 8
Ergebnis e485 [2026-11-03 05:49]: teilweise
  Fazit: Nach Wortlaut auf heldout GLEICH, aber knapp: Mittel -0,0074, |D| < 0,02 in genau 6/8, zwei Werte bei 0,0199 und 0,0191. Die Wiederholung auf heldout2 ist OFFEN: Mittel -0,0099, nur 5/8 innerhalb 0,02, dafuer besser in 7/8. GLEICH scheitert dort an Saaten, die mehr als 0,02 besser liegen. Beide Lesarten stehen nebeneinander. Was die Reparatur tragen sollte, naemlich "nicht schlechter", ist auf zwei Held-out-Texten erfuellt: Die obere Bootstrap-Grenze liegt bei +0,003 bzw. +0,001 nats. Die FFN-Zweige L1-L3 sind auch in 8 Bit entbehrlich, wie in float32 (TF0), und das bei rund 40 % der Parameter. EF0 ist 0,042 besser als 128x2 und 0,040 schlechter als LNS. Clip-Anteil: EF0 clippt haeufiger, nicht seltener. Eine Rechenzeit-Ersparnis gibt es erst mit einem Engine-Eingriff, der die Zweige ueberspringt. Der geht nur mit Zustimmung.
  Offen: Ob die Zweige statt Streichen gerettet werden koennen: snai/torch-emb-eingang (TEE) und snai/budget-tiefe. Ein Text als Trainingsmaterial, 9.002 Schritte. Ob EF0 wirklich besser ist, entscheidet die Reihe nicht.
  Datei: rechner-a:~/snai_pruef/clip_lns/ERGEBNIS_engine_ffn_weg.md
Chronik (juengste 8 von 10, voll=True zeigt alle):
  2026-11-03 03:58 Status geplant -> laeuft (Rezept r545)
  2026-11-03 04:00 Messwerte m8043-m8045
  2026-11-03 04:00 Messwerte m8046
  2026-11-03 04:01 Messwerte m8047
  2026-11-03 05:49 Messwerte m8068-m8077
  2026-11-03 05:49 Ergebnis e485: teilweise
  2026-11-03 05:49 Status laeuft -> ausgewertet (Ergebnis e485)
  2026-11-03 05:50 Anmerkung des Gegenlesers (gradnorm-Betreuung), 2026-11-03: Mein Einwand 1 vor dem Start sagte, der Clip greife ohne FFN L1-L3 seltener. Gemessen greift er häufiger (EF0 64-77 % gegen K1 51-68 %). Die Richtung meiner Vorhersage war falsch. Ohne die Zweige tragen also andere Tensoren eine größere Gradientennorm. Deutung, nicht gemessen: Die übrigen Teile müssen mehr leisten, ihr Gradient wächst. Am Urteil ändert das nichts, die Clip-Häufigkeit bleibt eine mitveränderte Größe.
```
