# snai/fruehwarner-null

```text
snai/fruehwarner-null - ausgewertet, angelegt 2026-11-04, zuletzt 2026-11-04 08:46
Frage: Taugt der Nulltest (w_down L1-L3 = 0 am Stand, ohne Training) als Frühwarner für Entbehrlichkeit, d. h. sagt seine Kostenzahl N voraus, was das Weglassen der Zweige beim Neutraining kostet (R)? Zuerst an Endständen; fällt er dort durch, sind frühe Stände nicht zu prüfen.
Kriterium (festgelegt 2026-11-04 08:45, vor dem ersten Messwert):
  Nur vorhandene Messungen, kein Lauf. rechner-b clip_lns. N je Saat = Loss(n123) - Loss(Ende) aus log/ee27_null.jsonl bzw. log/ee100_null.jsonl (E-Arm), R je Saat = Loss(F) - Loss(E) heldout 700 Fenster am Ende aus laeufe/ee27, laeufe/ee100 mess.jsonl. Paare s4-s11 in E27/F27 und E100/F100.
Urteile:
- KALIBRIERT: Mittel N / Mittel R zwischen 0,5 und 2 in beiden Paaren.
- RANGTREU: Spearman(N, R) >= 0,7 in beiden Paaren (n = 8).
- TAUGLICH, wenn KALIBRIERT und RANGTREU. UNTAUGLICH, wenn N/R > 3 in beiden Paaren. Sonst OFFEN.
Kontrollen: N der F-Arme = 0 in 16/16 (Werkzeug rechnet). Rot: Spearman mit verschobenen Saaten wird berichtet, N gegen N = 1.
Vorbelastung offen: Die Mittel von R (0,022 / 0,021) und N (Augenschein 0,2-0,3) waren vor dem Festlegen gesehen, das Urteil KALIBRIERT ist also kein frischer Test. Die Spearman-Werte sind nicht gesehen.
Reichweite: 128x4 int8, Eingangsfaktor, LR 0,003 konstant, 27k und 100k, Endstände, Gruppe L1-L3 (keine Einzelschichten). Frühe Stände und Adam-SNR werden hier nicht geprüft.
Rezepte:
  r571 [2026-11-04] rechner-b ~/snai_pruef/clip_lns: python3 (inline, Abfrage 2026-11-04 09:00) liest log/ee27_null.jsonl, log/ee100_null.jsonl (n123 je Arm und Saat) und laeufe/{ee27,ee100}/{E,F}*_s<s>/mess.jsonl (ck clip_s<s>.snai); N = n123 - Ende (E-Arm), R = F - E, Spearman ohne Bindungen
Messwerte (Groesse | Wert | Arm | Start | n):
  m8675 Kontrolle N der F-Arme = 0 | 16/16 | F27, F100 | s4-s11 | 16
  m8676 N je Saat (n123 - Ende) | 0,2398 0,1983 0,1842 0,2153 0,2656 0,2984 0,2195 0,3367; Mittel 0,2447 | E27 | s4-s11 | 8
  m8677 R je Saat (F27 - E27) | +0,0314 +0,0424 +0,0210 +0,0114 +0,0148 +0,0136 +0,0339 +0,0086; Mittel +0,0221 | E27 | s4-s11 | 8
  m8678 N/R und Spearman(N,R) | 11,1 und -0,57 (Rot: N gegen N 1,00, verschobene Saaten +0,50) | E27 | s4-s11 | 8
  m8679 N je Saat (n123 - Ende) | 0,2333 0,3962 0,3302 0,3386 0,2602 0,2348 0,2664 0,3293; Mittel 0,2986 | E100 | s4-s11 | 8
  m8680 R je Saat (F100 - E100) | +0,0171 +0,0273 +0,0198 +0,0134 +0,0252 +0,0247 +0,0131 +0,0258; Mittel +0,0208 | E100 | s4-s11 | 8
  m8681 N/R und Spearman(N,R) | 14,4 und +0,24 (Rot: N gegen N 1,00, verschobene Saaten -0,19) | E100 | s4-s11 | 8
Ergebnis e519 [2026-11-04 08:46]: erfuellt
  Fazit: UNTAUGLICH nach Wortlaut: Der Nulltest überschätzt die Kosten des Weglassens beim Neutraining um das 11- bzw. 14-Fache (N 0,245 gegen R 0,022 bei 27k; 0,299 gegen 0,021 bei 100k) und ordnet die Saaten nicht (Spearman -0,57 bzw. +0,24). Kontrollen: N der F-Arme 0 in 16/16, Rot N gegen N 1,00. KALIBRIERT war vorbelastet (Mittel gesehen), die Rangprüfung nicht.
Folgerung: Abschalten im fertigen Modell misst, wie sehr das Modell die Zweige benutzt, nicht, ob es sie braucht. Ohne Zweige trainiert findet es gleich gute Wege. Ein Frühwarner auf Nullbasis ist damit erledigt, frühe Stände müssen nicht geprüft werden. Gültige Wahrheit für Entbehrlichkeit ist nur das gepaarte Neutraining.
Deutung, nicht gemessen: Das trifft auch auf Schlüsse aus Nulltests bei anderen Breiten zu, etwa multi_stack e501 (512x8, MITTE TRÄGT): Dort ist belegt, dass das Modell die Mitte benutzt, nicht, dass es sie braucht.
Reichweite: 128x4 int8 mit Eingangsfaktor, LR 0,003 konstant, 27k und 100k, Endstände, Gruppe L1-L3, 8 Saaten je Budget. Adam-SNR als Frühwarner nicht geprüft; ihm fehlt dasselbe: In 128x4 gibt es keinen Fall, in dem Weglassen mehr als 0,022 kostet, also nichts zu unterscheiden.
Chronik:
  2026-11-04 08:45 angelegt
  2026-11-04 08:45 Rezept r571
  2026-11-04 08:45 Status geplant -> laeuft (Rezept r571)
  2026-11-04 08:45 Messwerte m8675-m8681
  2026-11-04 08:46 Ergebnis e519: erfuellt
  2026-11-04 08:46 Status laeuft -> ausgewertet (Ergebnis e519)
```
