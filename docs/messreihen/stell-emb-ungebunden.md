# snai/stell-emb-ungebunden

```text
snai/stell-emb-ungebunden - ausgewertet, angelegt 2026-11-04, zuletzt 2026-11-04 15:09
Frage: Schließt eine höhere LR des Eingangs-Embeddings (×3, ×10, Kopf bei Basis-LR, nach nanochat) die Lücke des ungebundenen Modells gegenüber dem gebundenen (e460: U 0,145 schlechter)?
Kriterium (festgelegt 2026-11-04 11:39, vor dem ersten Messwert):
  Wortlaut: rechner-a ~/snai_pruef/stell/KRITERIEN_stell.md (md5 24531ffe), Abschnitte „Gemeinsamer Aufbau“, „Regeln“ und „Reihe 3“.
Arme U (CLIP_TIE=0), UE3 (×3) und UE10 (×10) gegen K, K1-Rezept 128x4, kurz9000, Saaten 4-11, Lib c5f9fbaf.
Urteile je Dosis:
- (a) EMB-LR HILFT UNGEBUNDEN: UEx − U BESSER.
- (b) UNGEBUNDEN HOLT AUF: UEx − K GLEICH oder BESSER.
- (c) U − K, nur Einordnung.
- (d) Gains nach der Gain-Regel.
Gemeinsam ändern sich Bindung, Parameterzahl und w_out-Start. Die Dosen gegen U isolieren nur die Embedding-LR.
Darauf baut: snai/stell-lr-gruppen
Rezepte:
  r577 [2026-11-04] wie r(snai/stell-gainlr): rechner-a ~/snai_pruef/stell/reihe_stell.sh, Arme K, U (CLIP_TIE=0), UE3 (+SNAI_EMB_LR_MUL=3), UE10 (+SNAI_EMB_LR_MUL=10).
      quelltext: Lib c5f9fbaf, upEmb-Stellrad wirkt nur ungebunden (Gegenprobe G3 md5-gleich T1)
      parameter: K1-Rezept, Dosen 3 und 10
      seed: s4-s11
      rechner: rechner-a
      logs: log/stell.log, laeufe/stell/U*_s*
      notiz: Start 11:39 im selben Skript, zweite Welle.
Messwerte (Groesse | Wert | Arm | Start | n):
  m8770 UE3-U heldout | +0.0294 | 7/8 positiv, BS +0,0001..+0,0610, SCHLECHTER; heldout2 +0,0276, BS -0,0014..+0,0587
  m8771 UE10-U heldout | -0.0653 | 8/8 negativ, BS -0,080..-0,054, BESSER; heldout2 -0,0635
  m8772 UE3-K heldout | +0.1746 | SCHLECHTER; heldout2 +0,1715
  m8773 UE10-K heldout | +0.0799 | 8/8, SCHLECHTER; heldout2 +0,0803
  m8774 U-K heldout | +0.1452 | 8/8, SCHLECHTER (e460 +0,145); heldout2 +0,1438
  m8775 Tote L2-Gains U / UE3 / UE10 | 1.4 | % U; UE3 2,5; UE10 2,5; K 52,5; alle SENKT
Ergebnis e526 [2026-11-04 15:09]: teilweise
  Fazit: (a) EMB-LR HILFT UNGEBUNDEN: bei ×10 ja (−0,065, 8/8, heldout2 bestätigt), bei ×3 nein (SCHLECHTER +0,029, Intervall an der Null). (b) UNGEBUNDEN HOLT AUF: bei keiner Dosis (UE10 noch +0,080 hinter K). (c) U−K +0,145 wiederholt e460. Tote L2-Gains ungebunden 1,4–2,5 % gegen 52,5 %. Folge: Lösen der Bindung ist keine Reparatur. Dritter Fall des Musters „lebende Gains, schlechteres Modell“. Reichweite: 128x4, 9k, LR 0,003, 8 Saaten, zwei Dosen.
  Datei: rechner-a ~/snai_pruef/stell/ERGEBNIS_stell_r3.md
Chronik:
  2026-11-04 11:39 angelegt
  2026-11-04 11:40 Rezept r577
  2026-11-04 11:40 Status geplant -> laeuft (Rezept r577)
  2026-11-04 15:09 Messwerte m8770-m8775
  2026-11-04 15:09 Ergebnis e526: teilweise
  2026-11-04 15:09 Status laeuft -> ausgewertet (Ergebnis e526)
```
