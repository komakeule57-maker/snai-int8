# snai/stell-wsd

```text
snai/stell-wsd - ausgewertet, angelegt 2026-11-04, zuletzt 2026-11-04 15:54
Frage: Vorschlag (2026-11-04): Ist ein wesentlich längerer Warmup mit kurzer Abkühlung (W) besser als der Cosinus über den ganzen Lauf (C)? Zerlegt in Abkühllänge (S gegen C) und Warmuplänge (W gegen S).
Kriterium (festgelegt 2026-11-04 11:39, vor dem ersten Messwert):
  Wortlaut: rechner-a ~/snai_pruef/stell/KRITERIEN_stell.md (md5 24531ffe), Abschnitte „Gemeinsamer Aufbau“, „Regeln“ und „Reihe 4“, Prüfer Punkt (4).
Arme, Spitze 0,003, Boden 0,1:
- C: Warmup 500, Cosinus 500 bis 9002.
- S: Warmup 500, konstant, Cosinus 8102 bis 9002.
- W: Warmup 2000, konstant, Cosinus 8102 bis 9002.
Rezept K1 128x4, kurz9000, Saaten 4-11, Lib c5f9fbaf, Trainer de34a553 mit SNAI_LR_DECAY_START.
Haupturteil: W − C nach der Held-out-Regel.
Zerlegung:
- S − C (Abkühllänge samt LR-Summe, beide ändern sich gemeinsam).
- W − S (Warmuplänge).
Daneben C, S und W gegen K sowie die Gains.
Kontrolle: LR im Log an den Stützstellen.
Rezepte:
  r578 [2026-11-04] wie r(snai/stell-gainlr): rechner-a ~/snai_pruef/stell/reihe_stell.sh, Arme C (CLIP_DECAY_STEPS=9002), S (+CLIP_DECAY_START=8102), W (+CLIP_WARMUP=2000), alle CLIP_MIN_RATIO=0.1, gegen K.
      quelltext: Trainer de34a553 (SNAI_LR_DECAY_START, ohne Variable bytegleich: T2=T3 69f66a61)
      parameter: Spitze 0,003, Boden 0,0003, Warmup 500/2000, Abkühlung 10 % oder ganzer Lauf
      seed: s4-s11
      rechner: rechner-a
      logs: log/stell.log, laeufe/stell/{C,S,W}_s*
      notiz: Start 11:39 im selben Skript, dritte Welle.
Messwerte (Groesse | Wert | Arm | Start | n):
  m8776 W-C heldout | -0.0017 | 5/8 negativ, Betrag unter 0,02 in genau 6/8, BS -0,012..+0,009, GLEICH knapp
  m8777 W-C heldout2 | -0.0021 | 6/8, BS -0,013..+0,009, GLEICH knapp
  m8778 S-C heldout | +0.0270 | 8/8, SCHLECHTER; heldout2 +0,0281
  m8779 W-S heldout | -0.0287 | 8/8, BESSER; heldout2 -0,0302
  m8780 C-K heldout | -0.2197 | 8/8, BESSER; S-K -0,1927; W-K -0,2214
  m8781 Tote L2-Gains C | 8.6 | % SENKT; S 48,5 KEIN EFFEKT knapp; W 47,3 KEIN EFFEKT; K 52,5
Ergebnis e527 [2026-11-04 15:54]: gleichstand
  Fazit: Haupturteil W−C GLEICH nach Wortlaut, auf beiden Held-out-Texten knapp (genau 6/8), Bootstrap −0,013..+0,009. Nach der Knapp-Regel heißt das: nicht streng erfüllt, aber eng um null. Langer Warmup (2000) plus kurze Abkühlung (letzte 10 %) ist im Knirps so gut wie Cosinus über den ganzen Lauf (Vorschlag). Die kurze Abkühlung braucht den langen Warmup: S−C +0,027, W−S −0,029, je 8/8. Abkühlen überhaupt ist der größte Hebel: −0,22 gegen konstant. Beobachtung: Gleiche Güte bei 9 % (C) und 47 % (W) toten L2-Gains, die Gains bestimmen die Güte nicht. Reichweite: 128x4, 9k, ein Text, 8 Saaten.
  Datei: rechner-a ~/snai_pruef/stell/ERGEBNIS_stell_r4.md
Chronik:
  2026-11-04 11:39 angelegt
  2026-11-04 11:40 Rezept r578
  2026-11-04 11:40 Status geplant -> laeuft (Rezept r578)
  2026-11-04 15:54 Messwerte m8776-m8781
  2026-11-04 15:54 Ergebnis e527: gleichstand
  2026-11-04 15:54 Status laeuft -> ausgewertet (Ergebnis e527)
```
