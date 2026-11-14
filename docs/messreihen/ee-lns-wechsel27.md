# snai/ee-lns-wechsel27

```text
snai/ee-lns-wechsel27 - ausgewertet, angelegt 2026-11-04, zuletzt 2026-11-04 13:01
Frage: Reparieren Eingangsfaktor F und LNS dasselbe, sodass LNS mit F nichts mehr bringt (Deutung aus e521)? Oder verfällt der LNS-Vorteil bis 27k unabhängig vom Faktor? 2x2 Faktor × LNS über 27k. Ziel: die Ursache der nutzlosen Schichten klären.
Kriterium (festgelegt 2026-11-04 10:36, vor dem ersten Messwert):
  Wortlaut: rechner-b ~/snai_pruef/clip_lns/KRITERIEN_ko27.md (md5 067411b3, vor dem Start, mit Prüferabschnitt).

Arme:
- Neu K27 (F aus, LNS aus, Genesis clip_gen_s, s4 882308c1).
- Neu L27o (F aus, LNS an, Genesis clip_gen_lns_s, s4 183de20e).
- Vorhanden E27 (F an, LNS aus) und L27 (F an, LNS an).
- Alle mit Lib bau_emb_voll 3475df5c, kurz27000, 27.018 Schritte, Saaten 4-11, gleiche Fensterfolge.

Größen (Held-out 700, Endstand, gepaart):
- D_Lo = L27o − K27
- D_LF = L27 − E27
- I = D_LF − D_Lo
- Daneben D_Fo = E27 − K27

Regel für D:
- BESSER: 6/8 UND Mittel <= −0,02.
- SCHLECHTER: spiegelbildlich.
- GLEICH: |Mittel| < 0,01 UND |D| < 0,02 in 6/8.

Regel für I:
- I POSITIV: Mittel >= +0,02 UND I > 0 in 6/8.
- I NULL: |Mittel| < 0,01 UND |I| < 0,02 in 6/8.

Haupturteil:
- WECHSELWIRKUNG (stützt die Deutung): D_Lo BESSER UND I POSITIV.
- BUDGET (widerlegt sie): D_Lo nicht BESSER UND I NULL.
- Sonst OFFEN, mit Nennung der fehlenden Teilbedingung.

Knapp heißt 0,003 an einer Schwelle oder genau 6/8. Dann folgt heldout2 (ko27_ho2.sh). Bootstrap wird für D_Lo, D_LF und I immer berichtet.

Größenregel: unter 10 % ist Gleichstand.

Kontrollen:
- rc 0, STEPS 27018, Clip 1, SR an.
- LNS-Zeile 0 bei K27 und 1 bei L27o.
- „Eingangsfaktor 1.0“ in Training und Messung.
- Rot: K27 s4 MIT F gemessen muss abweichen.
- korrigiert 0.
- Probe: L27−E27 gibt +0,0164 (e521) wieder.

Reichweite: int8, 128x4, LR konstant 0,003, ein Text, 8 Saaten. Eine Wechselwirkung zeigt Überschneidung der Wirkung, nicht den Mechanismus.
Rezepte:
  r574 [2026-11-04] rechner-b ~/snai_pruef/clip_lns: setsid -f nohup ./reihe_ko27.sh (md5 a9861c05, per assert aus reihe_lf27.sh, werkzeug/mach_ko27.py). Je Lauf CLIP_GENPFX=<''|lns_> [SNAI_TEST_LNS=1] CLIP_LR=0.003 CLIP_LIB=bau_emb_voll/libcortex.so ./lauf_clip_lns.sh ko27 <K27|L27o> - <s> daten/kurz27000.txt 9000,13500,18000,22500, ohne SNAI_EMB_EIN, 12 zugleich, CPU, 1 Thread.
      quelltext: Lib bau_emb_voll 3475df5c (ohne SNAI_EMB_EIN setzt sie 1,0, cortex.nim:3537); Genesis clip_gen_s4 882308c1, clip_gen_lns_s4 183de20e
      parameter: K1-Rezept, LR 0,003 konstant, WD 0,1, Warmup 500, SR, Clip 1, gebunden, F 1,0, LNS c_l 1/sqrt(l+1) (Genesis rms_att + LR je Schicht), 27.018 Schritte
      seed: s4-s11 über Sitzungsname clip_s<s>, Fensterfolge gleich E27/L27
      rechner: rechner-b
      logs: log/ko27.log, laeufe/ko27/*, log/ko27_null.jsonl, log/ko27_mess.err
      notiz: Start 10:36 im Hauptbaum im Rahmen des Ziels (Ursache klären), Gegenversuch zur Deutung in e521. Kopfzeilen geprüft: K27 „Eingangsfaktor 1.0“ und „LNS 0“, L27o „1.0“ und „LNS 1“. Prüfer Gemini/Mistral: Bootstrap für I aufgenommen, übrige Einwände aus dem Code beantwortet. multi_stack braucht rechner-b erst nach etwa 12:35 plus Kriterien. Ende etwa 12:50.
Messwerte (Groesse | Wert | Arm | Start | n):
  m8735 D_Lo heldout (L27o-K27) | +0.0140 | 8/8 positiv, BS +0,0105..+0,0178, OFFEN
  m8736 D_Lo heldout2 | +0.0127 | 8/8 positiv, BS +0,0097..+0,0160, OFFEN
  m8737 I heldout (D_LF-D_Lo) | +0.0024 | Betrag I unter 0,02 in 7/8, BS -0,0038..+0,0097, I NULL
  m8738 I heldout2 | +0.0024 | BS -0,0044..+0,0096, I NULL
  m8739 D_Fo heldout (E27-K27) | -0.0117 | 7/8 negativ, OFFEN; heldout2 -0,0118 8/8
  m8740 D_FL heldout (L27-L27o) | -0.0093 | GLEICH, heldout2 ebenso
  m8741 Mittel heldout K27 | 2.5198 | E27 2,5081, L27 2,5245
  m8742 Mittel heldout L27o | 2.5338
  m8743 Zweigbeitrag L1-L3 K27 (n123 minus Ende) | 0.24 | E27 0,25; L27 0,045; L27o 0,036; Beobachtung ohne Urteil
  m8744 Verlauf D_Lo t9000 | -0.0369 | t13500 -0,0035, t18000 +0,0106, t22500 +0,0168
Ergebnis e522 [2026-11-04 13:01]: keine_aussage
  Fazit: Haupturteil nach Wortlaut OFFEN: Für BUDGET fehlt, dass D_Lo GLEICH oder SCHLECHTER ist. LNS kostet auch ohne Faktor in 8/8 Saaten (+0,014 / ho2 +0,013), liegt damit aber zwischen den Schwellen. WECHSELWIRKUNG ist klar verfehlt: I NULL auf beiden Datensätzen (+0,0024), D_Lo hat das falsche Vorzeichen. Damit hebt der Eingangsfaktor den LNS-Nutzen nicht auf. Faktor und LNS wirken über 27k additiv, die Redundanz-Deutung aus e521 fällt. LNS hilft bis etwa 9k und kostet danach, mit und ohne Faktor. Beobachtung: Unter LNS tragen die FFN-Zweige L1-L3 nur 0,04 statt 0,24 nat bei. Praxis: LNS nicht für lange Läufe, Faktor behalten. Reichweite: int8 128x4, LR 0,003 konstant, kurz27000, 8 Saaten.
  Datei: rechner-b ~/snai_pruef/clip_lns/ERGEBNIS_ko27.md (md5 5a639db7)
Chronik:
  2026-11-04 10:36 angelegt
  2026-11-04 10:37 Rezept r574
  2026-11-04 10:37 Status geplant -> laeuft (Rezept r574)
  2026-11-04 13:01 Messwerte m8735-m8744
  2026-11-04 13:01 Ergebnis e522: keine_aussage
  2026-11-04 13:01 Status laeuft -> ausgewertet (Ergebnis e522)
```
