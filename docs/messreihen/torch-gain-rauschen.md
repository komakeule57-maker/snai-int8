# snai/torch-gain-rauschen

```text
snai/torch-gain-rauschen - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-04 07:38
Frage: Treibt Rauschen mal Gain-Lernrate das Sterben (Chen et al. 2023; Mehta et al. 2019), und kostet es den Held-out oder den Beitrag der FFN-Zweige, wenn die FFN- und Attention-Gains langsamer lernen oder fest auf 1 stehen?
Kriterium (festgelegt 2026-11-02 20:31, vor dem ersten Messwert):
  Torch-Nachbau, K1-Rezept in float32, gepaart zu TG (snai/torch-k1-gains), Saaten 4-11, Genesis unverändert. Arme: TGL Lernrate aller Gains ausser rms_final x0,1; TGF Gains aller Schichten und rms_final fest auf Startwert 1 (kein Update). Haupt: L2 ffn tot TGL; HEBEL: <= 0,5 x TG im Mittel UND < TG in >= 6/8; KEIN HEBEL |Mittel D| < 10 Punkte; sonst OFFEN. TGF ist per Bau ohne tote Gains und zählt dort nicht. Held-out: D = Arm - TG; BESSER in >= 6/8 UND Mittel <= -0,02; SCHLECHTER umgekehrt; GLEICH |Mittel| < 0,01 UND |D| < 0,02 in >= 6/8; sonst OFFEN; Größe nach 10-%-Hausregel einordnen. Beitrag: Nullen w_down L2 und L1+L2+L3. Deutung: TGF nicht schlechter = die lernbaren Gains sind entbehrlich, Sterben kostet nichts. Kontrollen: t1000 Gains TGF exakt 1, TGL Spanne kleiner als TG, rc, Fehlerkanal. Gemeinsam ändert sich nur die Gain-Lernrate. Vorhersage der Rauschlesart: TGL senkt. Reichweite: float32, ein Rezept, 9.002 Schritte, ein Text; Faktor 0,1 frei gewählt (aus Mehta et al. 2019).
Darauf baut: snai/vorhersage-ffn-arme
Rezepte:
  r536 [2026-11-02] rechner-b ~/snai_pruef/clip_torch/kette3.sh: nach TORCH2_ENDE xargs -P 3 ./eins.sh < liste3.txt; TGL: --gain-lr 0.1, TGF: --gains-fest (auch rms_f), sonst wie r532.
Messwerte (Groesse | Wert | Arm | Start | n):
  m7897 Nachtrag vor dem Lesen von TGF, Einwand Evo | TGF hält auch rms_final fest, misst also mit der fehlenden Final-Gain mit; die vorab genannte Deutung "TGF nicht schlechter = Gains entbehrlich" gilt daher nur eingeschränkt. Neuer Arm TGF2: Schicht-Gains fest, rms_final frei, Regel wie Held-out oben, Saaten 4-11, nach TORCH3_ENDE (kette5.sh, eins5.sh). Beide Lesarten werden berichtet. Wortlaut oben bleibt.
  m7898 Nachtrag: TGF2 gestrichen, nicht gelaufen | Evo zieht Einwand zurück: g_final gelernt rund 0,86 gegen fest 1, nur rund 15 % Mitänderung, E braucht dafür keine andere Skala. TGF wird wie geplant gelesen, Mitänderung g_final 1 statt rund 0,86 wird genannt.
  m8602 L2 ffn tot Mittel (Schwelle 0,05) | 0.0 | TGL | s4-s11
  m8603 L2 ffn tot Mittel (Schwelle 0,05) | 67.2 | TG | s4-s11
  m8604 Held-out D gegen TG Mittel (8/8 schlechter) | 0.1457 | TGL | s4-s11
  m8605 Held-out D gegen TG Mittel (8/8 schlechter) | 0.1642 | TGF | s4-s11
  m8606 Kosten Nullen FFN L1-L3 Mittel | 0.3232 | TGL | s4-s11
  m8607 Kosten Nullen FFN L1-L3 Mittel | 0.3998 | TGF | s4-s11
  m8608 Kosten Nullen FFN L1-L3 Mittel | 0.2320 | TG | s4-s11
  m8609 RMS E Mittel | 0.1098 | TGF | s4-s11
  m8610 Kontrolle t1000 Gains min/max | 1.0000/1.0000 | TGF | s4
  m8611 Kontrolle t1000 Gains min/max (TG 0,311/1,428) | 0.913/1.033 | TGL | s4
Ergebnis e512 [2026-11-04 07:38]: erfuellt
  Fazit: Das Haupturteil ist HEBEL. TGL senkt die toten Gains in L2 von 67,2 auf 0,0 %, kleiner in 8/8. Beim Held-out sind beide Arme SCHLECHTER: TGL +0,146, TGF +0,164, je 8/8.

Die Kontrollen bei t1000 halten:
- TGF hat alle Gains exakt 1.
- Die Spanne von TGL (0,91-1,03) ist kleiner als die von TG (0,31-1,43).

Werden die Gains gebremst oder festgehalten, leben die Zweige und tragen mehr. Das Nullen von L1-L3 kostet dann 0,32 bzw. 0,40 statt 0,23, aber das Modell wird deutlich schlechter.

Folgerung: Das Lernen der Gains ist nützlich. Ihr Sterben ist eine Nebenwirkung davon und nicht der Schaden. Die Gains wiederzubeleben ist keine Reparatur.

Deutung, nicht gemessen: Die Gains regeln Schichten herunter.

Reichweite: float32, K1, ein Text, 9.002 Schritte, 8 Saaten. Erst am 04.11. ausgewertet, die Läufe waren seit 02.11. fertig.
  Datei: rechner-b ~/snai_pruef/clip_torch/ERGEBNIS_torch_nachtrag.md (md5 be8fe577)
Chronik:
  2026-11-02 20:31 angelegt
  2026-11-02 20:31 Rezept r536
  2026-11-02 20:31 Status geplant -> laeuft (Rezept r536)
  2026-11-02 22:46 Messwerte m7897
  2026-11-02 22:47 Messwerte m7898
  2026-11-04 07:38 Ergebnis e512: erfuellt
  2026-11-04 07:38 Status laeuft -> ausgewertet (Ergebnis e512)
  2026-11-04 07:38 Messwerte m8602-m8611
```
