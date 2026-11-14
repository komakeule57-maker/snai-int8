# snai/qk-quant-sonde

```text
snai/qk-quant-sonde - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 19:29
Frage: Hungert die int8-Quantisierung von Q/K die Attention aus: haben Köpfe weniger als 16 der 127 Stufen (A), ist der Logit-Fehler groß (B), und ändern Modus 1/2/4 Loss oder Kontextgewinn gegen Modus 0 messbar (C)?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus rechner-a ~/Projekte/snai_edge_int8_lora/diagnose/qk_pruef/ergebnis_20261012.out, lauf_qk.sh und rechner-a ~/Projekte/snai_edge_int8_lora/docs/VERGLEICH_LITERATUR_KOPIEREN.md (Abschnitt 6e).):
  Vorab im Kopf von diagnose/qk_pruef/lauf_qk.sh ('festgelegt 2026-10-12 vor dem ersten Lauf'): S Sonde gültig, Modus 0 liefert dieselben Positions-Losses wie das Original; A ausgehungert, wenn im Mittel < 16 von 127 Stufen; B Logit-Fehler (rms, zentriert) / Streuung der Float-Logits; C Wirkung von Modus 1/2/4 gegen 0 auf Loss und Kontextgewinn (Pos. 30..70 minus 471..511) in Standardfehlern.
Plan: Modelle K s0, prod512b u. a.; Modus 0/1/2/4 (SNAI_QK_MODUS) mit Rot-Probe.
Rezepte:
  r181 [2026-10-21] bash diagnose/qk_pruef/alle.sh
      quelltext: qk_pruef/patch_qk.py (Stand 2026-10-12 14:07)
      parameter: SNAI_QK_MODUS 0, 1, 2, 4
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge_int8_lora/diagnose/qk_pruef/ergebnis_20261012.out
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/Projekte/snai_edge_int8_lora/diagnose/qk_pruef/ergebnis_20261012.out. Prüfung: die Doku (6e) sagt 'unter 2,3 SE', das Ergebnis zeigt für prod512b -4,1 SE.
  m2242 Stufen je Kopf Minimum | 49 | alle |  | 1
  m2243 Logit-Fehler Maximum | 1,59 % | alle |  | 1
  m2244 Rot-Probe Ausschlag | 5,3 bis 27 SE | Rot |  | 1
  m2245 dLoss Modus 4 | +2,3 SE | K s0 |  | 1
  m2246 dKontextgewinn | -4,1 / -2,8 / -3,5 SE | prod512b |  | 3
  m2247 dKontextgewinn absolut | höchstens 0,0015 nats | prod512b |  | 3
Ergebnis e170 [2026-10-21 19:29]: teilweise
  Fazit: Q/K sind nicht ausgehungert: der schwächste Kopf nutzt 49 Stufen (Schwelle 16), der Logit-Fehler bleibt unter 1,6 %. Nach dem Wortlaut von Kriterium C ist die Wirkung bei prod512b aber sichtbar (-4,1 / -2,8 / -3,5 SE, gerichtet), deshalb teilweise. Absolut beträgt sie höchstens 0,0015 nats und ist praktisch bedeutungslos: die Q/K-Quantisierung erklärt das fehlende Kopieren nicht.
  Offen: Ob die kleinen, gerichteten Verschiebungen bei prod512b bei längerem Kontext wachsen.
  Datei: rechner-a:~/Projekte/snai_edge_int8_lora/diagnose/qk_pruef/ergebnis_20261012.out
Chronik:
  2026-10-21 19:28 angelegt (Nachtrag: Nachtrag 2026-10-21 aus rechner-a ~/Projekte/snai_edge_int8_lora/diagnose/qk_pruef/ergebnis_20261012.out, lauf_qk.sh und rechner-a ~/Projekte/snai_edge_int8_lora/docs/VERGLEICH_LITERATUR_KOPIEREN.md (Abschnitt 6e).)
  2026-10-21 19:28 Rezept r181
  2026-10-21 19:28 Status geplant -> laeuft (Rezept r181)
  2026-10-21 19:28 Messwerte m2242-m2247
  2026-10-21 19:29 Ergebnis e170: teilweise
  2026-10-21 19:29 Status laeuft -> ausgewertet (Ergebnis e170)
```
