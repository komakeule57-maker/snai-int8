# snai/gradnorm-skala

```text
snai/gradnorm-skala - ausgewertet, angelegt 2026-11-01, zuletzt 2026-11-01 15:06
Frage: Steigt die GradNorm, weil Weight Decay und Schrittrauschen die Gewichte auf ||w|| ~ sqrt(lr/wd) einstellen (Hypothese H), oder folgt sie dem Lernfortschritt, der Lernrate selbst oder dem Ganzzahl-Pfad?
Kriterium (festgelegt 2026-11-01 07:27, vor dem ersten Messwert):
  Ab c128sr s8, 30.000 Fenster, 3 Reihenfolgen, gepaart. Arme T(1e-4,0,1) H(1e-3,0,1) Z(1e-3,1,0) W(1e-4,0). Urteil auf GF (Norm am Endstand, LR 0, train_a, k=1) und Embedding-RMS gegen T: H RMS>=1,8x und GF<=0,6x; Z RMS<=1,1x und GF>=0,9x; W RMS>=1,05x und GF<=0,97x. BESTÄTIGT: alle drei in 3/3. WIDERLEGT: Z GF<=0,7x in 2/3 oder H RMS<1,3x in 2/3. Sonst kein Urteil. Knapp (innerhalb 5 %) gilt als nicht erfüllt. Blindvorhersage s9: Embedding-RMS in [0,017; 0,024] und s9/s8<=0,90. Hypothese entstand nach dem Hinsehen an s4-s8. Quer: gemessen/vorhergesagt in [0,75; 1,25] an tx_d128h8L4_fall_s1..3, alle Saaten gleich.
Plan: rechner-a:~/snai_pruef/gradnorm/kriterien_skala.txt
Baut auf: snai/gradnorm-zerlegung
Darauf baut: snai/dauerclip-lang, snai/gradnorm-batch, snai/wdg-norm, snai/embedding-nachlaufen, snai/adamc-dc
Rezepte:
  r486 [2026-11-01] cd ~/snai_pruef/gradnorm && setsid -f nohup werkzeug/schlange_s.sh (je Lauf werkzeug/lauf2.sh <arm> <lr> <wd> <r>; intern SNAI_WARMUP_STEPS=500 SNAI_GN_LOG=1 php train_worker.php chunk_skala_<r>.txt sk_<arm>_<r>.snai 1 chin_c128sr_s8.snai 3 <lr> 1 <lr> <wd> 0 0)
      quelltext: proj_gn wie snai/gradnorm-zerlegung r485; kriterien_skala.txt 547a475a; lauf2.sh 5ec04e80; schlange_s.sh bd8a80d9
      seed: r1,r2,r3 (Fensterreihenfolge über Dateinamen)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/gradnorm/log/sk_*.log, log/schlange_s.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/gradnorm/log/auswertung_sk.txt (auswerten_sk.py 50f96cef), log/sonde_sk.jsonl, log/held_sk_*. Fehlerkanal 0, je 2 NET2NET-Meldungen. Step 1 je Reihenfolge ueber alle Arme gleich.
  m7233 Emb-RMS | 0,02660 / 0,02659 / 0,02666 | T | r1,r2,r3
  m7234 GF | 9,211 / 9,185 / 9,168 | T | r1,r2,r3
  m7235 Held-out | 1,9330 / 1,9377 / 1,9402 | T | r1,r2,r3
  m7236 Emb-RMS | 0,06131 / 0,06151 / 0,06162 | H | r1,r2,r3
  m7237 GF | 3,295 / 3,374 / 3,281 | H | r1,r2,r3
  m7238 Held-out | 2,2670 / 2,2751 / 2,2761 | H | r1,r2,r3
  m7239 Emb-RMS | 0,01942 / 0,01946 / 0,01950 | Z | r1,r2,r3
  m7240 GF | 7,230 / 7,149 / 7,054 | Z | r1,r2,r3
  m7241 Held-out | 2,8174 / 2,8030 / 2,8050 | Z | r1,r2,r3
  m7242 Emb-RMS | 0,03264 / 0,03258 / 0,03257 | W | r1,r2,r3
  m7243 GF | 8,502 / 8,370 / 8,323 | W | r1,r2,r3
  m7244 Held-out | 1,9121 / 1,9143 / 1,9164 | W | r1,r2,r3
  m7245 RMS/T, GF/T | 2,31 / 0,358-0,367 | H | r1,r2,r3
  m7246 RMS/T, GF/T | 0,73 / 0,769-0,785 | Z | r1,r2,r3
  m7247 RMS/T, GF/T | 1,22 / 0,908-0,923 | W | r1,r2,r3
  m7248 Blindvorhersage s9 | RMS 0,024007, s9/s8 0,888, nicht erfuellt | s9
Ergebnis e428 [2026-11-01 15:06]: keine_aussage
  Fazit: Nach Wortlaut kein Urteil: Z-Vorhersage GF >= 0,9 x T in 0/3 (0,77-0,785), Widerlegung Z GF <= 0,7 ebenfalls nicht erreicht. H in dieser Form nicht bestaetigt. Der Teil "Gewichte folgen sqrt(lr/wd)" trifft an den eingeschwungenen Armen H und Z auf 4 % (Beobachtung), der Teil "Norm folgt 1/Gewichtsgroesse" reicht allein nicht; Rest haengt an LR oder Loss. Unverlangt: WD 0 in 3/3 auf dem Held-out um 0,02 nats besser als WD 0,1 (s8, LR 1e-4, 30.000 Fenster), rechtfertigt einen eigenen Armvergleich, keinen Rezeptwechsel.
  Offen: LR gegen Loss als Treiber des Rests (Erklaerungen A, B, C); Quer-Pruefung nicht auswertbar (Laeufe ohne SR, zu kurz); andere Modelle und Startstaende.
  Datei: rechner-a:~/snai_pruef/gradnorm/ERGEBNIS_skala.md
Chronik:
  2026-11-01 07:27 angelegt
  2026-11-01 07:27 Rezept r486
  2026-11-01 07:27 Status geplant -> laeuft (Rezept r486)
  2026-11-01 07:28 Vor dem Lesen der Armwerte: Rot der Sonde bestanden (Embedding-Skalen im Stand s8 halbiert: RMS 0,013522 wie erwartet, qk unverändert 0,036579; Final-Gain 5,2579 = Engine-Gegenprobe gains.php). Quer-Rohwerte tx_d128h8L4_fall_s1..3 gelesen (ohne SR, Lauf zu kurz fürs Einschwingen bei kleiner LR: T bis 50.000 Schritte, je Segment 5.000): Beobachtung, Urteil bei der Auswertung. Prüfer 2026-11-01: Zeitkonstante gilt nur bei stationärem Adam-Rauschen, Armunterschied H-Z kann Clip/Momentum nicht erklären, Zusatzarm verworfen.
  2026-11-01 09:04 2026-11-01 ~09:05: Startschwelle der Schlange 2400 -> 1400 MB (RAM-Grenze jetzt 1 GB). Die drei laufenden Arme T, H, Z r1 blieben unberuehrt, die Fortsetzung startet per s_weiter.sh nach ihrem Ende. Wirkt nicht auf die Messwerte.
  2026-11-01 15:06 Messwerte m7233-m7248
  2026-11-01 15:06 Ergebnis e428: keine_aussage
  2026-11-01 15:06 Status laeuft -> ausgewertet (Ergebnis e428)
```
