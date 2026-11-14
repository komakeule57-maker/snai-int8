# snai/torch-lns-zerlegung

```text
snai/torch-lns-zerlegung - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-04 07:38
Frage: Welcher Teil von LNS verbessert den Held-out (Startskala oder Gain-Lernrate), und kommt LNS ohne FFN-Zweige in L1-L3 von Anfang an aus? Das wäre ein billigeres Modell ohne Verlust.
Kriterium (festgelegt 2026-11-02 20:44, vor dem ersten Messwert):
  Torch-Nachbau, K1-Rezept in float32, Fenster und Saaten 4-11 wie TG (snai/torch-k1-gains). Arme: TL LNS voll (Genesis clip_gen_lns, --lns-lr), TLS nur Startskala, TLR nur Gain-LR x c_l, TLA2 128x2 mit LNS (Faktoren 1 und 0,707), TLF LNS plus w_down L1-L3 von Anfang an exakt 0 und nie aktualisiert, TF0 K1 ohne LNS mit w_down L1-L3 Null. D je gegen TG; BESSER: in >= 6/8 UND Mittel <= -0,02; SCHLECHTER umgekehrt; GLEICH: |Mittel| < 0,01 UND |D| < 0,02 in >= 6/8; sonst OFFEN; Größe zusätzlich nach Hausregel. Zuschreibung: TL BESSER ist Voraussetzung (Übertrag der Engine-Reihe snai/lns-gains auf Float). Startskala wirkt, wenn TLS BESSER und TLR nicht; Gain-LR entsprechend; beide BESSER: unabhängig wirksam. FFN-Entbehrlichkeit: TLF gegen TL: GLEICH oder BESSER heisst ENTBEHRLICH in diesem Budget; SCHLECHTER heisst Zweige helfen beim Lernen, auch wenn sie am Ende fast nichts tragen. Tiefe unter LNS: TLA2 gegen TL. Rechenaufwand wird aus FLOPs berichtet, nicht aus diesem Lauf, weil Torch Nullzweige mitrechnet. Kontrollen: Gains an t1000 nicht wieder bei 1, Nullzweig L1-L3 bleibt exakt 0, rc, Fehlerkanal. Reichweite: float32, ein Rezept, ein Text, 9.002 Schritte; Übertrag auf int8 danach als Engine-Reihe.
Darauf baut: snai/vorhersage-ffn-arme
Rezepte:
  r537 [2026-11-02] rechner-b ~/snai_pruef/clip_torch/kette4.sh: xargs -P 2 ./eins4.sh < liste4.txt. TL: clip_gen_lns, --lns-lr; TLS: clip_gen_lns; TLR: clip_gen_s, --lns-lr; TLF: clip_gen_lns, --lns-lr --ffn-aus 1,2,3; TF0: clip_gen_s, --ffn-aus 1,2,3; TLA2: clip_gen_z2l, --lns-lr. Sonst wie r532.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b ~/snai_pruef/clip_torch/aus.py, Stand 02:25, TF0 und TLA2 fehlen noch
  m7985 Held-out, D gegen TG Mittel, besser, FFN tot L0-L3 | 2,6379; -0,0360; 8/8; 0,0 42,4 86,0 66,3 | TL
  m7986 Held-out, D gegen TG Mittel, besser, FFN tot L0-L3 | 2,6332; -0,0406; 8/8; 0,0 57,2 92,8 87,3 | TLS
  m7987 Held-out, D gegen TG Mittel, besser, FFN tot L0-L3 | 2,6933; +0,0194; 2/8; 0,0 0,0 26,4 0,0 | TLR
  m7988 Held-out, D gegen TG Mittel, besser | 2,6255; -0,0483; 8/8 | TLF
  m7989 TLF - TL je Saat s4-s11 | -0,0123 -0,0050 -0,0084 +0,0097 -0,0281 -0,0170 -0,0325 -0,0055, Mittel -0,0124, besser 7/8 | TLF
  m7990 Kosten Nullen FFN L1+L2+L3 | 0,0241 | TL
  m7991 Kosten Nullen FFN L1+L2+L3 | 0,0117 | TLS
  m7992 Kosten Nullen FFN L1+L2+L3 | 0,2647 | TLR
  Quelle: rechner-b ~/snai_pruef/clip_torch/aus.py, Stand 03:55
  m8040 Held-out Mittel, 8 Saaten | 2,6741 | TF0
  m8041 D gegen TG je Saat s4-s11 | 0,0058 -0,0050 0,0029 0,0042 0,0112 0,0101 -0,0361 0,0087, Mittel +0,0002, | D | < 0,02 in 7/8, besser 2/8 | TF0
  m8042 FFN tot L0-L3 und Kosten Nullen FFN L1-L3 | 0,0 0,0 0,0 0,0; 0,0000 (Zweig bleibt exakt aus) | TF0
Ergebnis e513 [2026-11-04 07:38]: teilweise
  Fazit: Die Voraussetzung ist erfüllt: TL ist BESSER, −0,036 in 8/8.

Zuschreibung: Die Startskala wirkt, die Gain-LR nicht.
- TLS ist BESSER, −0,041 in 8/8.
- TLR ist OFFEN, +0,019 und nur in 2/8 besser.

FFN-Entbehrlichkeit, TLF gegen TL: nach Wortlaut OFFEN. Der Wert liegt bei −0,012 und ist in 7/8 besser, verfehlt aber die Schwelle für BESSER (−0,02), und für GLEICH ist |Mittel| zu groß. Zweite Lesart: Ohne die Zweige ist das Modell nicht schlechter.

Tiefe unter LNS: TLA2 gegen TL ist SCHLECHTER, +0,049 in 8/8. Vier Schichten tragen also mehr als zwei, auch wenn die FFN-Zweige L1-L3 entbehrlich sind.

TF0 ist GLEICH zu TG.

Folgerung: Eine Engine-Reihe mit LNS ohne FFN L1-L3 läuft als snai/engine-lns-schlank.

Reichweite: float32, ein Text, 9.002 Schritte, 8 Saaten.
  Datei: rechner-b ~/snai_pruef/clip_torch/ERGEBNIS_torch_nachtrag.md (md5 be8fe577)
Chronik:
  2026-11-02 20:44 angelegt
  2026-11-02 20:44 Rezept r537
  2026-11-02 20:44 Status geplant -> laeuft (Rezept r537)
  2026-11-03 02:27 Messwerte m7985-m7992
  2026-11-03 03:58 Messwerte m8040-m8042
  2026-11-04 07:38 Ergebnis e513: teilweise
  2026-11-04 07:38 Status laeuft -> ausgewertet (Ergebnis e513)
```
