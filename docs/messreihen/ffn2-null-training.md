# snai/ffn2-null-training

```text
snai/ffn2-null-training - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 17:31
Frage: Hilft der FFN-Zweig der Schicht 2 beim Lernen? Derselbe Lauf wie K1, aber w_down der Schicht 2 von Anfang an auf 0 festgehalten (Zweig im Training abwesend), gepaart gegen K1. Isolierender Eingriff zu snai/gains-vertretung B.
Kriterium (festgelegt 2026-11-02 16:07, vor dem ersten Messwert):
  Rezept K1 aus snai/dauerclip-saaten (128x4, voll int8, gebunden, SR, Clip 1, LR 0,003, WD 0,1, Warmup 500, kurz9000, 9.002 Schritte), Saaten 4-11, CPU rechner-b, 1 Thread, Kopie clip_nf/proj_clip mit EINEM Stellrad SNAI_TEST_NULL_WDOWN_L=2: w_down_q8 der Schicht 2 (und ihr Rueckfuehrungsrest) nach dem Quantisieren und nach jedem Adam-Schritt auf 0. Messgroesse: Held-out mess_text 700 Fenster, D = L(NF) - L(K1) je Saat am Ende; Zwischenstaende t=1000, t=3000 mitgemessen. HILFT: NF schlechter in >= 6/8 UND mittleres D >= 0,02 nats. HILFT NICHT: |D| <= 0,01 in >= 6/8. Sonst OFFEN; innerhalb 0,005 um eine Schwelle nicht erfuellt. Vergleichswert: Herausnehmen des fertigen Zweigs kostete 0,02 bei lebenden Gains. Kontrollen: K1C = Rezept auf CPU ohne Stellrad, md5 ee903784; Rot des Stellrads: [NW]-Zeile im Log, Endstand mit w_down L2 exakt 0 (nullsetzen "2:w_down" aendert die Datei nicht) und L2-Gains bleiben 1,0 (kein Gradient); rc 0, STEPS_DONE 9002, Fehlerkanal leer. Mitgeschrieben: tot L1/L2, Norm. Gemeinsam aendert sich: nur der Zweig; die Schicht 2 behaelt ihre Attention. Reichweite: ein Rezept, ein Text, 9.002 Schritte, nur Schicht 2.
Baut auf: snai/gains-vertretung, snai/gains-ursache-folge, snai/dauerclip-saaten
Darauf baut: snai/lns-gains
Rezepte:
  r524 [2026-11-02] rechner-b ~/snai_pruef/clip_nf/reihe.sh: lauf_clip_nf.sh (= lauf_clip.sh) auf CPU, K1C ohne Stellrad, NF s4-s11 mit SNAI_TEST_NULL_WDOWN_L=2, 4 zugleich; Held-out je Snapshot und Ende aus mess.jsonl
      quelltext: clip_nf/proj_clip = clip/proj_clip plus nullWdownTest() in cortex.nim (nach Quantisieren und nach jedem Adam-Schritt w_down_q8[l] und Rueckfuehrungsrest auf 0), Lib 29a7d776
      rechner: rechner-b CPU, 1 Thread je Lauf, 1054 s je Lauf
      logs: rechner-b:~/snai_pruef/clip_nf/ (log/reihe.log, laeufe/reihe/); rechner-a:~/snai_pruef/clip_rr/kanal_nf.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: mess.jsonl der NF- und K1-Laeufe (700 Fenster), kanal_nf.jsonl, nullsetzen-Probe
  m7652 Kontrolle K1C s4 CPU md5 | ee903784 (= K1 Karte) | K1C
  m7653 Rot Stellrad: [NW]-Zeile / w_down L2 am Ende exakt 0 (nullsetzen aendert nichts) / L2-Gains | 8/8 / ja (s4, s11 geprueft) / alle exakt 1,000 | NF
  m7654 rc / STEPS_DONE / Fehlerzeilen | 0 / 9002 / 0 in 8/8 | NF
  m7655 Held-out Ende | 2,6775 / 2,6908 / 2,6953 / 2,7081 / 2,6602 / 2,6701 / 2,6798 / 2,6622 | NF | s4-s11 | 8
  m7656 Held-out Ende | 2,6728 / 2,7087 / 2,6740 / 2,7131 / 2,6561 / 2,6937 / 2,6905 / 2,6650 | K1 | s4-s11 | 8
  m7657 D = NF - K1 Ende | +0,0047 -0,0179 +0,0213 -0,0050 +0,0041 -0,0236 -0,0107 -0,0028 | NF gegen K1 | s4-s11 | 8
  m7658 mittleres D / NF schlechter / | D | <= 0,01 | -0,0037 / 3 von 8 / 4 von 8 (s10 0,0107 knapp) | NF gegen K1
  m7659 Held-out t3000 NF besser als K1 | 6/8 (Mittel NF 2,955, K1 2,968) | NF gegen K1 | s4-s11 | 8
  m7660 L1 tot Ende | 3,9 / 2,3 / 5,5 / 2,3 / 0,8 / 18,8 / 2,3 / 1,6 | NF | s4-s11 | 8
  Quelle: Nachtrag auf Einwand Evo: B-Staende (snai/gains-v-b, Gains leben, gleiche Fensterfolge), mess.jsonl
  m7661 Held-out Ende | 2,6590 / 2,6698 / 2,6869 / 2,6955 / 2,6691 / 2,6946 / 2,6941 / 2,6816 | B | s4-s11 | 8
  m7662 D = NF - B Ende | +0,0185 +0,0210 +0,0084 +0,0126 -0,0089 -0,0245 -0,0143 -0,0194 | NF gegen B | s4-s11 | 8
  m7663 mittleres NF - B / NF schlechter | -0,0008 / 4 von 8 | NF gegen B
  m7664 NF - K1 bei lebender K1-Saat s5 | -0,0179 | NF gegen K1 | s5
Ergebnis e462 [2026-11-02 17:31]: keine_aussage
  Fazit: OFFEN nach Wortlaut, aber HILFT ist ausgeschlossen, und zwar auch gegen Staende mit lebenden Gains (Einwand Evo: K1 ist selbst zu 52,5 % gekippt): NF gegen K1 im Mittel -0,004 nats (NF schlechter 3/8), NF gegen B (Ratsche, Gains leben, gleiche Fensterfolge) -0,001 (4/8), NF gegen die lebende K1-Saat s5 -0,018; an t=3000 NF besser 6/8. HILFT NICHT (|D| <= 0,01 in 6/8) scheitert nur an der Saatstreuung +-0,02, die groesser ist als das vorab gesetzte Band; unter der 10-%-Regel Gleichstand. Der FFN-Zweig der Schicht 2 hilft in 9.002 Schritten dieses Rezepts beim Lernen nicht, das Kippen seiner Gains kostet nichts, und der R-Vorteil (0,02) kommt nicht von diesem Zweig. Fuer laengere Budgets sagt das nichts. Beobachtung: ohne L2-FFN kippen die L1-Gains etwas mehr (bis 18,8 %).
  Offen: Band 0,01 enger als die Saatstreuung; laengeres Budget; ein Rezept, ein Text, nur Schicht 2.
  Datei: rechner-a:~/snai_pruef/clip_rr/ERGEBNIS_ffn2_null.md
Abgeloest und ausgeblendet: 1 ergebnis - voll=True zeigt sie.
Chronik:
  2026-11-02 16:07 angelegt
  2026-11-02 17:30 Rezept r524
  2026-11-02 17:30 Status geplant -> laeuft (Rezept r524)
  2026-11-02 17:30 Messwerte m7652-m7660
  2026-11-02 17:30 Ergebnis e461: keine_aussage
  2026-11-02 17:30 Status laeuft -> ausgewertet (Ergebnis e461)
  2026-11-02 17:31 Messwerte m7661-m7664
  2026-11-02 17:31 Ergebnis e462: keine_aussage, loest e461 ab
```
