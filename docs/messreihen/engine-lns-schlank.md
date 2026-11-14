# snai/engine-lns-schlank

```text
snai/engine-lns-schlank - ausgewertet, angelegt 2026-11-04, zuletzt 2026-11-04 07:57
Frage: Trägt in 8 Bit ein Modell mit LNS und ganz ohne FFN-Zweige L1-L3 (LNSF)? Ist es besser als K1 und nicht schlechter als LNS? Das wäre die Reparatur der nutzlosen Schichten.
Kriterium (festgelegt 2026-11-04 07:33, vor dem ersten Messwert):
  Wortlaut: rechner-b ~/snai_pruef/clip_lns/KRITERIEN_lnsf.md (md5 8f683cc7, vor dem Start, mit Prüferabschnitt).

Arm LNSF: LNS-Genesis (r529), dazu rms_ffn und w_down L1-L3 exakt 0, SNAI_TEST_LNS=1. Lib b72d9d76 wie LNS und EF0, K1-Rezept, kurz9000, 9.002 Schritte, Saaten 4-11, gleiche Fensterfolge.

Größe: D_K = LNSF − K1 und D_L = LNSF − LNS, Held-out 700 Fenster am Ende, gepaart.

Regel:
- BESSER: 6/8 UND Mittel <= −0,02.
- SCHLECHTER: spiegelbildlich.
- GLEICH: |Mittel| < 0,01 UND |D| < 0,02 in 6/8.
- Sonst OFFEN.

Urteil 1:
- REPARATUR TRÄGT: D_K BESSER UND D_L nicht SCHLECHTER.
- SCHEITERT: D_L SCHLECHTER.
- Sonst OFFEN.

Nebenurteil: Die Zweige sind unter LNS entbehrlich, wenn D_L GLEICH oder BESSER ist.

Knapp heißt 0,003 um eine Schwelle oder genau 6/8. Dann ist das Urteil nicht erfüllt, es folgen Bootstrap und eine Wiederholung auf heldout2.

Größenregel: unter 10 % ist Gleichstand der Größe nach.

Kontrollen:
- (a) Nullen von w_down L1-L3 am Ende ändert den Loss um 0,0000 in 8/8, früh geprüft an t1000.
- (b) Genesis 6/6 Ziele mit Mittel 0 (erledigt).
- (c) rc 0, STEPS 9002, eine LNS-Zeile je Lauf.
- (d) 3 NET2NET erwartet, „korrigiert“ macht die Saat ungültig.

Vorhersage aus float32: D_K ≈ −0,05, D_L ≈ −0,01.

Reichweite: int8, ohne EE, 128x4, ein Text, 9k.
Rezepte:
  r568 [2026-11-04] rechner-b ~/snai_pruef/clip_lns: setsid -f nohup ./reihe_lnsf.sh (md5 cd358aaa, per assert aus reihe_ef0.sh, werkzeug/mach_lnsf.py). Je Saat: SNAI_TEST_LNS=1 CLIP_GENPFX=lnsf_ CLIP_LR=0.003 ./lauf_clip_lns.sh lnsf LNSF - <s> daten/kurz9000.txt 1000,3000, 8 zugleich, CPU, 1 Thread.
      quelltext: Lib proj_clip/libcortex.so b72d9d76 (wie LNS r529, EF0 r545). Genesis clip_gen_lnsf_s<s> = skaliere.php clip_gen_lns_s<s> "1:rms_ffn=0,2:rms_ffn=0,3:rms_ffn=0,1:w_down=0,2:w_down=0,3:w_down=0", 6/6 Mittel 0 in 8/8 (log/lnsf_gen_s*.txt); Rot: 9:w_down abgewiesen rc 2.
      parameter: K1-Rezept, LR 0,003 konstant, WD 0,1, Warmup 500, SR, Clip 1, gebunden, 9.002 Schritte, ohne Eingangsfaktor
      seed: s4-s11 über Sitzungsname clip_s<s>, Fensterfolge gleich K1/LNS/EF0
      rechner: rechner-b
      logs: log/lnsf.log, laeufe/lnsf/LNSF_s*, log/lnsf_null.jsonl
      notiz: Gestartet 07:33 im Hauptbaum, Anfrage nach Knirps-Rezepten für das freie rechner-b. Prüfer: Gemini ohne Sachbefund, Mistral 5 Einwände, keiner stichhaltig (Kriteriendatei).
Messwerte (Groesse | Wert | Arm | Start | n):
  m8635 Held-out Ende | 2.6172 | LNSF | s4
  m8636 Held-out Ende | 2.6252 | LNSF | s5
  m8637 Held-out Ende | 2.6456 | LNSF | s6
  m8638 Held-out Ende | 2.6389 | LNSF | s7
  m8639 Held-out Ende | 2.6531 | LNSF | s8
  m8640 Held-out Ende | 2.6219 | LNSF | s9
  m8641 Held-out Ende | 2.6507 | LNSF | s10
  m8642 Held-out Ende | 2.6275 | LNSF | s11
  m8643 D_K Mittel (8/8 besser, BS -0,066..-0,031) | -0.0492 | LNSF-K1 | s4-s11
  m8644 D_L Mittel (abs D unter 0,02 in 8/8, BS -0,010..+0,005) | -0.0023 | LNSF-LNS | s4-s11
  m8645 D gegen EF0 Mittel (8/8 besser) | -0.0418 | LNSF-EF0 | s4-s11
  m8646 Kontrolle (a) Nullen w_down L1-L3 Ende, Unterschied | 0.0000 | LNSF | s4-s11
  m8647 Clip-Anteil GradNorm ueber 1 | 56-66 % | LNSF | s4-s11
Ergebnis e516 [2026-11-04 07:56]: erfuellt
  Fazit: REPARATUR TRÄGT, das Urteil ist nicht knapp.

- LNSF gegen K1: −0,049, 8/8, Bootstrap −0,066 bis −0,031, also BESSER.
- LNSF gegen LNS: −0,002, |D| < 0,02 in 8/8, also GLEICH.
- LNSF gegen EF0: −0,042, 8/8.

Alle Kontrollen sind grün: Die Zweige bleiben aus (0,0000 in 8/8, früh bei t1000 ebenso), korrigiert 0, rc 0, eine LNS-Zeile je Lauf. Das Auswertungsskript rechnet e470 und e485 exakt nach.

Folgerung: In 8 Bit lassen sich die nutzlosen FFN-Zweige L1-L3 (rund 40 % der Parameter) ohne jeden Verlust streichen, wenn die Schichten mit LNS skaliert werden (die Wirkung kommt über die Attention, e514). Das schlanke Modell ist so gut wie LNS mit Zweigen und verlässlich besser als K1.

Größenregel: 1,8 % des Loss, der Größe nach Gleichstand. Der Gewinn ist also vor allem ein Gewinn an Sparsamkeit.

Nächster Schritt: dasselbe über ein längeres Budget, mit Eingangsfaktor und mit Abkühlen der LR. Erst danach steht eine Übernahme in den Hauptbaum zur Entscheidung.

Reichweite: int8, 128x4, ohne EE, ein Text, 9.002 Schritte, 8 Saaten.
  Datei: rechner-b ~/snai_pruef/clip_lns/ERGEBNIS_engine_lns_schlank.md (md5 b244346e)
Chronik:
  2026-11-04 07:33 angelegt
  2026-11-04 07:34 Rezept r568
  2026-11-04 07:34 Status geplant -> laeuft (Rezept r568)
  2026-11-04 07:56 Ergebnis e516: erfuellt
  2026-11-04 07:56 Status laeuft -> ausgewertet (Ergebnis e516)
  2026-11-04 07:57 Messwerte m8635-m8647
```
