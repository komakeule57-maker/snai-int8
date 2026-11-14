# snai/ee-lns-schlank27

```text
snai/ee-lns-schlank27 - ausgewertet, angelegt 2026-11-04, zuletzt 2026-11-04 10:32
Frage: Hält das schlanke Modell (LNS, ohne FFN L1-L3) mit Eingangsfaktor über 27k Schritte? Ist es nicht schlechter als das volle Modell E27, und kosten die Zweige unter LNS etwas (L27)?
Kriterium (festgelegt 2026-11-04 08:08, vor dem ersten Messwert):
  Wortlaut: rechner-b ~/snai_pruef/clip_lns/KRITERIEN_lf27.md (md5 fce49087, vor dem Start, mit Prüferabschnitt).

Aufbau:
- Arm LF27: LNS, FFN L1-L3 genullt.
- Arm L27: LNS mit vollen Zweigen.
- Beide mit SNAI_TEST_LNS=1 und F = sqrt(128). Lib bau_emb_voll 3475df5c, kurz27000, 27.018 Schritte, Saaten 4-11, gleiche Fensterfolge.
- Gegenstücke E27 und F27 aus snai/ee-ffn-budget (e504).

Größen, Held-out 700 Fenster mit F am Ende:
- D_E = LF27 − E27
- D_F = LF27 − F27
- D_L = LF27 − L27
- D_LE = L27 − E27

Regel wie e516:
- BESSER: 6/8 UND Mittel <= −0,02.
- SCHLECHTER: spiegelbildlich.
- GLEICH: |Mittel| < 0,01 UND |D| < 0,02 in 6/8.
- Sonst OFFEN.

Urteile:
1. REPARATUR HÄLT, wenn D_E BESSER oder GLEICH ist. Sie SCHEITERT, wenn D_E SCHLECHTER ist.
2. LNS wirkt mit Faktor: D_F und D_LE BESSER.
3. Zweige unter LNS entbehrlich: D_L GLEICH oder BESSER. Bei SCHLECHTER wäre L27 der bessere Weg.

Knapp heißt 0,003 um eine Schwelle oder genau 6/8. Dann folgen Bootstrap und eine Wiederholung auf heldout2.

Größenregel: unter 10 % des Loss ist Gleichstand der Größe nach.

Kontrollen:
- n123 von LF27 gleich dem Endwert in 8/8.
- lns=1 je Lauf, sonst ungültig.
- messF > 0 und Rot-Probe ohne F.
- 3 NET2NET je LF27-Lauf. „korrigiert“ macht die Saat ungültig.

Vorwissen: F27 − E27 = +0,022 in 8/8. Bei 27k mit Faktor helfen die Zweige also ohne LNS.

Reichweite: int8, 128x4, mit EE, LR konstant, ein Text.
Rezepte:
  r569 [2026-11-04] rechner-b ~/snai_pruef/clip_lns: setsid -f nohup ./reihe_lf27.sh (md5 41369bf3, per assert aus reihe_ee27.sh, werkzeug/mach_lf27.py). Je Lauf CLIP_GENPFX=<lns_|lnsf_> SNAI_EMB_EIN=11.3137085 SNAI_TEST_LNS=1 CLIP_LR=0.003 CLIP_LIB=bau_emb_voll/libcortex.so ./lauf_clip_lns.sh lf27 <L27|LF27> - <s> daten/kurz27000.txt 9000,13500,18000,22500; 12 zugleich, CPU, 1 Thread.
      quelltext: Lib bau_emb_voll 3475df5c; Genesis clip_gen_lns_s4 183de20e, clip_gen_lnsf_s4 647650bb (aus e516)
      parameter: K1-Rezept, LR 0,003 konstant, WD 0,1, SR, Clip 1, gebunden, F 11,3137085, LNS c_l 1/sqrt(l+1), 27.018 Schritte
      seed: s4-s11 über Sitzungsname clip_s<s>, Fensterfolge gleich E27/F27
      rechner: rechner-b
      logs: log/lf27.log, laeufe/lf27/*, log/lf27_null.jsonl
      notiz: Gestartet 08:07 im Hauptbaum im Rahmen des Ziels (Reparatur absichern). Prüf-Agent vor dem Start, 6 Einwände, alle eingearbeitet (L27 dazu, lns als Gültigkeitsbedingung, F-Kontrolle über messF). Ende etwa 10:30.
Messwerte (Groesse | Wert | Arm | Start | n):
  m8703 Kontrollen a-d (n123 LF27 = Ende 8/8, lns=1 16/16, rc 0, STEPS 27018, messF 5 16/16, Rot ohne F 4,9101, NET2NET LF27 je 3, korrigiert 0) | alle grün | LF27+L27 | s4-s11 | 16
  m8704 Held-out Mittel heldout E27 / F27 / L27 / LF27 | 2,5081 / 2,5303 / 2,5245 / 2,5218 | alle | s4-s11 | 8
  m8705 D_E = LF27 − E27 heldout | +0,0136, besser 0/8, Betrag D < 0,02 in 6/8, BS +0,0069..+0,0207 → OFFEN (knapp: genau 6/8) | LF27 | s4-s11 | 8
  m8706 D_E heldout2 | +0,0137, besser 0/8, Betrag D < 0,02 in 6/8, BS +0,0072..+0,0202 → OFFEN | LF27 | s4-s11 | 8
  m8707 D_E Verlauf heldout t9000/13500/18000/22500/Ende | −0,029 / −0,006 / +0,004 / +0,012 / +0,014 (Beobachtung) | LF27 | s4-s11 | 8
  m8708 D_F = LF27 − F27 heldout / heldout2 | −0,0085 (7/8, BS −0,0137..−0,0029) / −0,0088 (6/8, BS −0,0145..−0,0020) → GLEICH, knapp (0,0015 an der Schwelle 0,01) | LF27 | s4-s11 | 8
  m8709 D_L = LF27 − L27 heldout / heldout2 | −0,0027 (BS −0,0082..+0,0022) / −0,0014 (BS −0,0063..+0,0034) → GLEICH | LF27 | s4-s11 | 8
  m8710 D_LE = L27 − E27 heldout / heldout2 | +0,0164 (0/8, BS +0,0127..+0,0208) / +0,0152 (0/8, BS +0,0111..+0,0201) → OFFEN | L27 | s4-s11 | 8
  m8711 F27 − E27 heldout / heldout2 (Probe gegen e504 +0,0222) | +0,0221 / +0,0225 → SCHLECHTER | F27 | s4-s11 | 8
  m8712 L27 tote rms_ffn im Messkanal (NET2NET, nur gemeldet) | L3 in 7/8, L2 in 7/8 (einmal teilweise Kanäle 68..127), L1 0/8 | L27 | s4-s11 | 8
  m8713 L27 n123 − Ende (Beitrag der Zweige) | 0,090 / 0,063 / 0,016 / 0,002 / 0,011 / 0,096 / 0,065 / 0,017 | L27 | s4-s11 | 8
Ergebnis e521 [2026-11-04 10:32]: keine_aussage
  Fazit: Hauptergebnis REPARATUR OFFEN nach Wortlaut, auf beiden Held-out-Texten. LF27 liegt um +0,014 hinter E27, besser in 0/8, Bootstrap ohne 0. Der Größe nach ist das Gleichstand (0,5 %).
Nebenurteil 2 (LNS wirkt mit Faktor) nicht erfüllt: D_F nur knapp GLEICH, D_LE +0,015 in der falschen Richtung.
Nebenurteil 3 (Zweige unter LNS entbehrlich) erfüllt: D_L GLEICH auf beiden Texten.

Deutung, nicht gemessen:
- Die Kosten trägt LNS, nicht das Weglassen. Mit Eingangsfaktor ist LNS mit c_l = 1/sqrt(l+1) über 27k überflüssig bis leicht schädlich: Der Vorsprung bei t9000 kehrt sich um.
- Unter LNS mit Faktor sterben die FFN-Gains in L2 und L3 wieder (L27 7/8), obwohl die Zweige ohne LNS helfen (F27−E27 +0,022).
- Bestes gemessenes Rezept bei 128x4/27k bleibt E27 (Faktor, volle Zweige, kein LNS).

Offen: schwächeres LNS, Abkühlen, andere Breiten, prod512b.
  Datei: rechner-b:~/snai_pruef/clip_lns/ERGEBNIS_ee_lns_schlank27.md
Chronik:
  2026-11-04 08:08 angelegt
  2026-11-04 08:08 Rezept r569
  2026-11-04 08:08 Status geplant -> laeuft (Rezept r569)
  2026-11-04 10:32 Messwerte m8703-m8713
  2026-11-04 10:32 Ergebnis e521: keine_aussage
  2026-11-04 10:32 Status laeuft -> ausgewertet (Ergebnis e521)
```
