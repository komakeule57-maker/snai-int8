# snai/torch-wup-regime

```text
snai/torch-wup-regime - ausgewertet, angelegt 2026-11-03, zuletzt 2026-11-04 07:38
Frage: Warum wirkt nur der größere w_up-Start gegen das Sterben (TPU ja, TPD nein)? Liegt es an der Eingangsgröße der SiLU (kleines Argument = fast linear, Regime) oder an der Absolutgröße von w_up? Und lässt sich der lebende FFN mit dem LNS-Gewinn kombinieren?
Kriterium (festgelegt 2026-11-03 00:17, vor dem ersten Messwert):
  Torch-Nachbau, K1-Rezept float32, gepaart zu TG, Saaten 4-11. Arme: TGA FFN-Gains Start x4,4194, w_up unverändert (Eingang SiLU wie TPU, w_up klein); TPV w_up x4,4194 und FFN-Gains Start /4,4194 (Eingang SiLU wie TG, w_up groß); TPL LNS-Startskala plus w_up x4,4194; TLSA nur Attention-Gains mit c_l; TLSF nur FFN-Gains mit c_l. Lesart A Eingangsgröße: TGA lebt, TPV stirbt wie TG. Lesart B Absolutgröße w_up: TPV lebt, TGA stirbt wie TG. Lebt = L2+L3 ffn tot im Mittel <= 0,5 x TG UND kleiner als TG in >= 6/8; Tod zählt sowohl mit Schwelle 0,05 als auch 0,05 x Startfaktor (beide berichten, TPV zählt nach der skalierten Schwelle). A gilt nur, wenn TGA lebt UND TPV nicht; B umgekehrt; beide leben oder beide sterben: keine der Lesarten. Vorbehalt TGA: größerer Gain hat längeren Weg nach 0. Held-out je Arm gegen TG und gegen TLS (Regel: BESSER/SCHLECHTER 6/8 UND 0,02; GLEICH |Mittel| < 0,01 UND |D| < 0,02 in 6/8; sonst OFFEN). Reparaturkandidat TPL: lebt UND gegen TLS nicht SCHLECHTER, FFN-Kosten L1-3 >= 0,1. Mitgeschrieben Nullen L2 und L1-3, E, g_final, rms(h@w_up) am Start wird einmal gerechnet. Zuschreibung LNS: TLSA gegen TLSF. Kontrollen: skaliere.php Mittel, rc, Fehlerkanal; t1000 Gains. Reichweite: float32, ein Rezept, 9.002 Schritte; alles Weitere in der Engine.
Rezepte:
  r539 [2026-11-03] rechner-b ~/snai_pruef/clip_torch/kette6.sh: xargs -P 2 ./eins6.sh < liste6.txt. Genesis mit skaliere.php: tga (rms_ffn x4,4194), tpv (w_up x4,4194, rms_ffn x0,22627), tpl (clip_gen_lns plus w_up x4,4194), tlsa, tlsf (je c_l auf rms_att bzw. rms_ffn). Rest wie r532, keine lr-Änderung an Gains.
Messwerte (Groesse | Wert | Arm | Start | n):
  m8592 Held-out D gegen TG Mittel | 0.1041 | TGA | s4-s11
  m8593 Held-out D gegen TG Mittel | 0.0029 | TPV | s4-s11
  m8594 Held-out D gegen TG Mittel | -0.0592 | TPL | s4-s11
  m8595 Held-out D gegen TG Mittel | -0.0420 | TLSA | s4-s11
  m8596 Held-out D gegen TG Mittel | 0.0142 | TLSF | s4-s11
  m8597 D gegen TLS Mittel (7/8 besser) | -0.0186 | TPL | s4-s11
  m8598 L2+L3 ffn tot Summe Mittel (Schwelle skaliert) | 0 | TGA | s4-s11
  m8599 L2+L3 ffn tot Summe Mittel (Schwelle 0,0113) | 106.4 | TPV | s4-s11
  m8600 L2+L3 ffn tot Summe Mittel (Schwelle 0,05) | 67.8 | TG | s4-s11
  m8601 Kosten Nullen FFN L1-L3 Mittel | 0.0915 | TPL | s4-s11
Ergebnis e514 [2026-11-04 07:38]: teilweise
  Fazit: Es gilt Lesart A, die Eingangsgröße der SiLU.

- TGA lebt: 0 % tot in L2 und L3, bei Schwelle 0,05 ebenso wie skaliert bei 0,221, in 8/8.
- TPV stirbt: Bei skalierter Schwelle 0,0113 liegt die Summe L2+L3 im Mittel bei 106 %, gegen 68 % bei TG.

Held-out gegen TG:
- TGA ist SCHLECHTER, +0,104 in 8/8.
- TPV ist OFFEN, +0,003.
- TPL ist BESSER, −0,059 in 8/8.

TPL gegen TLS ist OFFEN und knapp: −0,0186, in 7/8 besser.

Reparaturkandidat TPL: nein. Die Zweige leben nicht, und ihre FFN-Kosten liegen mit 0,09 unter 0,1. Trotzdem ist TPL das beste Float-Modell.

Zuschreibung LNS: Sie wirkt über die Attention-Gains. TLSA ist BESSER (−0,042, 8/8), TLSF OFFEN (+0,014).

Folgerung: Lebende FFN-Gains sind kein Gütezeichen. TGA lebt und ist deutlich schlechter.

Reichweite: float32, ein Text, 9.002 Schritte, 8 Saaten. Die skalierten Schwellen sind mit gschw_torch.py nachgemessen, geeicht an TG s4 (88,3 gegen 88 aus aus.py).
  Datei: rechner-b ~/snai_pruef/clip_torch/ERGEBNIS_torch_nachtrag.md (md5 be8fe577)
Chronik:
  2026-11-03 00:17 angelegt
  2026-11-03 00:17 Rezept r539
  2026-11-03 00:17 Status geplant -> laeuft (Rezept r539)
  2026-11-04 07:38 Ergebnis e514: teilweise
  2026-11-04 07:38 Status laeuft -> ausgewertet (Ergebnis e514)
  2026-11-04 07:38 Messwerte m8592-m8601
```
