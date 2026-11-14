# snai/knirps-kongruenz

```text
snai/knirps-kongruenz - ausgewertet, angelegt 2026-11-04, zuletzt 2026-11-04 17:13
Frage: Kosten tote FFN-Gains Grammatik? Gemessen wird die Kongruenz Artikel–Substantiv im Genus an vorhandenen Knirps-Ständen. Hauptvergleich C gegen W: gleicher Held-out, aber 9 % gegen 47 % tote L2-Gains. Frage: Folgen jenseits des Verlusts.
Kriterium (festgelegt 2026-11-04 16:18, vor dem ersten Messwert):
  Wortlaut: rechner-a ~/snai_pruef/stell/KRITERIEN_kongruenz.md. Fehlermasse E = 1 − M (M = Masse auf Substantiven mit passendem Genus / Masse auf allen Lexikon-Substantiven), d2 (Artikel, ein Wort, Substantiv) entscheidet. r = E_W / E_C je Saat, s4–s11.
- KOSTEN: Mittel r ≥ 1,2 und r > 1 in 6/8.
- KEIN UNTERSCHIED: Mittel r 0,9–1,1 und r 0,8–1,25 in 6/8.
- HELFEN: Mittel r ≤ 0,83 und r < 1 in 6/8.
- Sonst OFFEN.
Rot: verschobenes Genus-Lexikon an C_s4 muss M d2 < 0,5 liefern. Regression: Verlust bytegleich zu mess_text (gezeigt an C_s4).
Rezepte:
  r583 [2026-11-04] rechner-a ~/snai_pruef/stell/kongruenz.sh (5b84d158; KRITERIEN b233256b): Rot-Probe C_s4 mit genus_lex_rot.json, dann C, W, K, GL × s4–s11 mit text/kongruenz.php (95169f63) auf heldout2, 700 Fenster. Nachmessung des vom Lade-Wächter veränderten Stands W_s6 (L2.rms_ffn [108..127] beim Laden auf 1 gesetzt) ohne Wächter: nach_ow.sh mit text/kongruenz_ow.php (b1c36490, patch_ow.py f53934f4 per assert). Auswertung werkzeug/ausw_kongruenz.py --ow (718f7a09).
      rechner: rechner-a
Messwerte (Groesse | Wert | Arm | Start | n):
  m8811 Rot C_s4 verschobenes Lexikon M d2 | 0.0235 | nötig < 0,5, ROT GESEHEN
  m8812 E d2 C Mittel | 0.0328 | 8 Saaten, n=173 Stellen
  m8813 E d2 W Mittel | 0.0365 | 8 Saaten
  m8814 E d2 K Mittel | 0.0586 | 8 Saaten
  m8815 E d2 GL Mittel | 0.0768 | 8 Saaten; Trigramm 0,0521
  m8816 r W/C d2 Mittel | 1.117 | je Saat 0,910 1,256 1,274 1,203 1,146 0,960 1,117 1,070; BS 1,029..1,200; >1 in 6/8
  m8817 r K/GL d2 Mittel | 0.820 | BS 0,670..0,982, 6/8 <1; GL Verlust +0,17
  m8818 E d1 C Mittel | 0.0139 | n=1620
  m8819 E d1 W Mittel | 0.0182 | r W/C 1,325, BS 1,197..1,434, 8/8 >1 (nur berichtet)
  m8820 Korrelation E d2 mit L2 tot% in W | 0.87 | Beobachtung; in K -0,67, in C -0,41
  m8821 Nachmessung W_s6 ohne Wächter M d2 | 0.9567 | gleich Erstmessung; Wächter in dieser Kopie ab Werk aus
Ergebnis e530 [2026-11-04 17:13]: keine_aussage
  Fazit: Hauptkriterium d2 OFFEN und knapp (r W/C Mittel 1,117, BS 1,029..1,200, 6/8): weder KOSTEN noch KEIN UNTERSCHIED. Die Probe beantwortet die Frage nach dem Einfluss toter Gains auf Grammatik nicht. Belegt ist nur, dass gleicher Held-out nicht gleiche Kongruenz heißt: W liegt bei d1 in 8/8 Saaten schlechter (r 1,325). Die Ursache bleibt offen, weil sich zwischen C und W LR-Plan und Gain-Sterben gemeinsam ändern. Innerhalb der Arme wechselt das Vorzeichen der Korrelation mit toten Gains (W +0,87, K −0,67). Für eine Antwort braucht es Arme, die sich nur im Gain-Sterben unterscheiden.
  Datei: rechner-a ~/snai_pruef/stell/ERGEBNIS_kongruenz.md
Chronik:
  2026-11-04 16:18 angelegt
  2026-11-04 17:06 Rezept r583
  2026-11-04 17:06 Status geplant -> laeuft (Rezept r583)
  2026-11-04 17:13 Messwerte m8811-m8821
  2026-11-04 17:13 Ergebnis e530: keine_aussage
  2026-11-04 17:13 Status laeuft -> ausgewertet (Ergebnis e530)
```
