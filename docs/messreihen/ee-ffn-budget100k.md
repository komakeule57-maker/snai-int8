# snai/ee-ffn-budget100k

```text
snai/ee-ffn-budget100k - ausgewertet, angelegt 2026-11-03, zuletzt 2026-11-04 05:38
Frage: Wächst der Nutzen der mittleren FFN-Zweige L1-L3 mit Eingangsfaktor über 27k hinaus klar über die Schwelle (e504: +0,022, knapp), und kehrt das Sterben der L2-Gains bei langem Training trotz Faktor zurück (e504: s9 50 %, s11 65 % tot bei 27k)?
Kriterium (festgelegt 2026-11-03 18:09, vor dem ersten Messwert):
  **Aufbau wie snai/ee-ffn-budget (r554).** Es ändert sich nur der Text: kurz100k.txt ist ein Präfix von knirps_gpu/chin/train.txt mit rund 100.000 Fenstern, kurz27000 ist ein Präfix davon.
- E100: Genesis clip_gen_s<s>.
- F100: Genesis clip_gen_ef0_s<s>.
- Beide mit F = sqrt(128) über bau_emb_voll 3475df5c, SNAI_EMB_EIN = 11,3137085. Voll int8, K1-Rezept (LR 0,003 konstant, WD 0,1, Warmup 500, SR, Clip 1, gebunden), CPU, 1 Thread.
- Ein Stellrad: die Genesis. Lib, Daten und Sitzungsname clip_s<s> sind gleich, die Fensterfolge ist gepaart.
- Snapshots 27000, 50000, 75000 und Ende. Saaten 4-11. Messung: mess_text, heldout 700 Fenster, mit F.

**Größe:** D(b) = L(F100, b) − L(E100, b) je Saat. Positiv heißt, die Zweige nützen.

**Urteil 1 am Ende:**
- NUTZEN: Mittel D ≥ +0,02 UND D > 0 in mindestens 6/8. Wortgleich mit e504, damit es vergleichbar bleibt.
- ENTBEHRLICH: Mittel D < +0,01 UND D < +0,02 in mindestens 6/8.
- Sonst OFFEN.

**Urteil 2, weiteres Wachstum:** H2 = D(Ende) − D(27000).
- WÄCHST: Mittel H2 ≥ +0,01 UND H2 > 0 in mindestens 6/8.
- PLATEAU: |Mittel H2| < 0,005 UND |H2| < 0,01 in mindestens 6/8.
- Sonst saatabhängig.

**Urteil 3, Sterben am Ende in E100:** tote L2-FFN-Gains, |g| < 0,05, gemessen mit lesen_tie2.php.
- KEHRT ZURÜCK: mindestens 30 % tot in mindestens 4/8 Saaten.
- BLEIBT LEBENDIG: höchstens 20 % tot in mindestens 6/8.
- Sonst OFFEN.
- Zum Vergleich K1 ohne F bei 9k (e491): 0,8-86 %, Mittel 52 %.

**Knapp-Regel:** Liegt ein Wert innerhalb von 0,003 um eine Schwelle (bei Urteil 3 innerhalb von 3 Prozentpunkten), ist sie nicht erfüllt. Dann folgen ein gepaarter Bootstrap und eine Wiederholung auf heldout2 (Urteil 1 und 2).

**Kontrollen:**
- Je Lauf: rc 0, STEPS_DONE gleich PLAN_STEPS. Den Faktorwert 11.313708 im Training suchen, nicht die umbrochene Zeile. Telemetrie grad emb rund 85 %, messF in jeder Messung, SR an, CLIP 1, korrigiert 0.
- F100: Nullen von w_down L1-L3 am Endstand muss 0 kosten.
- Rot Messpfad: E100 s4 Ende ohne F gemessen.

**Größter freier Parameter:** das Budget von etwa 100k Schritten bei konstanter LR, ohne Abkühlen. „Wächst“ und „Plateau“ gelten nur bis dahin und nur für dieses Rezept, 128x4.

**Gemeinsam verändert zwischen den Ständen:** Schritte und frische Daten. Der Nutzen lässt sich deshalb nicht einer der beiden Größen allein zuordnen.
Baut auf: snai/ee-ffn-budget
Darauf baut: snai/ee-lr-spaet
Rezepte:
  r563 [2026-11-03] rechner-b ~/snai_pruef/clip_lns: setsid -f nohup ./reihe_ee100.sh (md5 51de1e9e, per assert-Ersetzung aus reihe_ee27.sh abgeleitet). Je Lauf: CLIP_GENPFX=<''|ef0_> SNAI_EMB_EIN=11.3137085 CLIP_LIB=bau_emb_voll/libcortex.so ./lauf_clip_lns.sh ee100 <E100|F100> - <s> daten/kurz100k.txt 27000,50000,75000, 8 zugleich, CPU, 1 Thread.
      quelltext: Lib bau_emb_voll 3475df5c, Genesis clip_gen_s4 882308c1, clip_gen_ef0_s4 8d7e5806
      parameter: kurz100k.txt md5 3dc97e81, 58.522.294 Bytes, Präfix von knirps_gpu/chin/train.txt (kurz27000 ist Präfix davon, assert geprüft). PLAN_STEPS 100025. LR 0,003 konstant, WD 0,1, Warmup 500, SR, Clip 1, gebunden.
      seed: Saaten 4-11 über Genesis und Sitzungsname clip_s<s>
      rechner: rechner-b
      logs: rechner-b ~/snai_pruef/clip_lns/log/ee100.log, laeufe/ee100/*, log/ee100_null.jsonl
      notiz: Gestartet 18:11, gestartet im Hauptbaum im Rahmen des Ziels (Ursache und Reparatur der nutzlosen Schichten). Gegengelesen von Gemini und Mistral. Mistrals Einwände 1 und 3 beruhen auf Missverständnissen: In F sind L1-L3 genullt, also auch die letzte Schicht; ein Durchgang ohne Wiederholung hat keine Overfitting-Phase. Übernommen wird Einwand 5: tote Gains zusätzlich an den Snapshots 27k, 50k und 75k auslesen, als Beobachtung. Tempo zu Beginn etwa 5,8 Schritte/s, erwartetes Ende 04.11. gegen 05:00.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b ~/snai_pruef/clip_lns/log/ee100_tot_snap.jsonl (lesen_tie2.php, tot = |g|<0,05), Schnappschuss t50000; Beobachtung, nicht Teil des Urteilskriteriums
  m8478 tot FFN L1 % t50000 | 16,4 | E100 | 4
  m8479 tot FFN L1 % t50000 | 25,8 | E100 | 5
  m8480 tot FFN L1 % t50000 | 23,4 | E100 | 6
  m8481 tot FFN L1 % t50000 | 16,4 | E100 | 7
  m8482 tot FFN L2 % t50000 | 8,6 | E100 | 4
  m8483 tot FFN L2 % t50000 | 10,9 | E100 | 5
  m8484 tot FFN L2 % t50000 | 34,4 | E100 | 6
  m8485 tot FFN L2 % t50000 | 9,4 | E100 | 7
  m8486 tot Att L0 % t50000 | 15,6 | E100 | 4
  m8487 tot Att L0 % t50000 | 9,4 | E100 | 5
  m8488 tot Att L0 % t50000 | 11,7 | E100 | 6
  m8489 tot Att L0 % t50000 | 13,3 | E100 | 7
  m8490 tot FFN L1 % t27000 | 7,8 | E100 | 4
  m8491 tot FFN L1 % t27000 | 9,4 | E100 | 5
  m8492 tot FFN L1 % t27000 | 11,7 | E100 | 6
  m8493 tot FFN L1 % t27000 | 7,8 | E100 | 7
  Quelle: rechner-b ~/snai_pruef/clip_lns/log/ee100_ausw.txt (werkzeug/ausw_ee100.py), log/ee100_ho2.jsonl (ee100_ho2.sh md5 6b4af011), log/ee100_tot.jsonl (lesen_tie2.php, tot = |g|<0,05)
  m8494 D Ende heldout | 0.0171 | F-E | 4
  m8495 D Ende heldout | 0.0273 | F-E | 5
  m8496 D Ende heldout | 0.0198 | F-E | 6
  m8497 D Ende heldout | 0.0134 | F-E | 7
  m8498 D Ende heldout | 0.0252 | F-E | 8
  m8499 D Ende heldout | 0.0247 | F-E | 9
  m8500 D Ende heldout | 0.0131 | F-E | 10
  m8501 D Ende heldout | 0.0258 | F-E | 11
  m8502 D Ende heldout2 | 0.0174 | F-E | 4
  m8503 D Ende heldout2 | 0.0231 | F-E | 5
  m8504 D Ende heldout2 | 0.0208 | F-E | 6
  m8505 D Ende heldout2 | 0.0111 | F-E | 7
  m8506 D Ende heldout2 | 0.0226 | F-E | 8
  m8507 D Ende heldout2 | 0.0181 | F-E | 9
  m8508 D Ende heldout2 | 0.0201 | F-E | 10
  m8509 D Ende heldout2 | 0.0286 | F-E | 11
  m8510 H2 D(Ende)-D(27000) | -0.0080 | F-E | 4
  m8511 H2 D(Ende)-D(27000) | 0.0178 | F-E | 5
  m8512 H2 D(Ende)-D(27000) | 0.0139 | F-E | 6
  m8513 H2 D(Ende)-D(27000) | -0.0216 | F-E | 7
  m8514 H2 D(Ende)-D(27000) | -0.0076 | F-E | 8
  m8515 H2 D(Ende)-D(27000) | 0.0134 | F-E | 9
  m8516 H2 D(Ende)-D(27000) | -0.0078 | F-E | 10
  m8517 H2 D(Ende)-D(27000) | 0.0108 | F-E | 11
  m8518 tot FFN L2 % Ende | 13.3 | E100 | 4
  m8519 tot FFN L2 % Ende | 21.1 | E100 | 5
  m8520 tot FFN L2 % Ende | 27.3 | E100 | 6
  m8521 tot FFN L2 % Ende | 14.8 | E100 | 7
  m8522 tot FFN L2 % Ende | 23.4 | E100 | 8
  m8523 tot FFN L2 % Ende | 95.3 | E100 | 9
  m8524 tot FFN L2 % Ende | 12.5 | E100 | 10
  m8525 tot FFN L2 % Ende | 19.5 | E100 | 11
  m8526 tot FFN L1 % Ende | 23.4 | E100 | 4
  m8527 tot FFN L1 % Ende | 36.7 | E100 | 5
  m8528 tot FFN L1 % Ende | 46.1 | E100 | 6
  m8529 tot FFN L1 % Ende | 21.9 | E100 | 7
  m8530 tot FFN L1 % Ende | 25.0 | E100 | 8
  m8531 tot FFN L1 % Ende | 28.1 | E100 | 9
  m8532 tot FFN L1 % Ende | 32.0 | E100 | 10
  m8533 tot FFN L1 % Ende | 34.4 | E100 | 11
  m8534 Nullen w_down L1-L3 kostet nats Ende | 0.2333 | E100 | 4
  m8535 Nullen w_down L1-L3 kostet nats Ende | 0.3962 | E100 | 5
  m8536 Nullen w_down L1-L3 kostet nats Ende | 0.3302 | E100 | 6
  m8537 Nullen w_down L1-L3 kostet nats Ende | 0.3386 | E100 | 7
  m8538 Nullen w_down L1-L3 kostet nats Ende | 0.2602 | E100 | 8
  m8539 Nullen w_down L1-L3 kostet nats Ende | 0.2348 | E100 | 9
  m8540 Nullen w_down L1-L3 kostet nats Ende | 0.2664 | E100 | 10
  m8541 Nullen w_down L1-L3 kostet nats Ende | 0.3293 | E100 | 11
Ergebnis e509 [2026-11-04 05:38]: teilweise
  Fazit: Urteil 1 OFFEN (knapp): Mittel D +0,0208 (heldout) und +0,0202 (heldout2), je 8/8 > 0, Bootstrap +0,017..+0,024, also innerhalb 0,003 um die Schwelle 0,02; der Größe nach 0,8 %, Gleichstand. Urteil 2 saatabhängig: H2 Mittel +0,0014, 4/8 > 0, |H2| < 0,01 nur 3/8; Mittel D je Stand 0,019/0,028/0,025/0,021, kein Wachstum nach 50k. Urteil 3 OFFEN: tote L2-Gains am Ende 12,5-27,3 %, s9 95,3 %; ≥30 % in 1/8, ≤20 % in 4/8. Beobachtung: L1 stirbt stetig nach (Mittel 9,2 → 31,0 %, 8/8). Kontrollen erfüllt (Nullkontrolle 0,0000 in 8/8, Rot Messpfad 5,6482); Abweichung: Embedding-Gradientenanteil 72-81 % statt rund 85 %, in beiden Armen gleich. Fazit: Mit konstanter LR werden die mittleren Zweige auch bei 100k nicht nützlich über 0,02 nats hinaus; der Eingangsfaktor bremst das Gain-Sterben, beendet es aber nicht. Weiter in snai/ee-lr-spaet (LR als Treiber) und snai/ee-ffn-abkuehlen (Nutzen beim Abkühlen).
  Datei: rechner-b ~/snai_pruef/clip_lns/ERGEBNIS_ee_ffn_budget100k.md
Chronik:
  2026-11-03 18:09 angelegt
  2026-11-03 18:13 Rezept r563
  2026-11-03 18:13 Status geplant -> laeuft (Rezept r563)
  2026-11-03 20:36 Messwerte m8478-m8493
  2026-11-04 05:37 Messwerte m8494-m8541
  2026-11-04 05:38 Ergebnis e509: teilweise
  2026-11-04 05:38 Status laeuft -> ausgewertet (Ergebnis e509)
```
