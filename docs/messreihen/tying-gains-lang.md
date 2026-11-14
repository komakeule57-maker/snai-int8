# snai/tying-gains-lang

```text
snai/tying-gains-lang - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-03 05:45
!! ohne Rezept
Frage: Treibt Weight Tying das Kippen der L2-Gains, oder lernt das gebundene Modell nur schneller und erreicht frueher den Zustand, in dem der mittlere FFN entbehrlich ist? Folge zu snai/tying-gains (Freigabe 2026-11-02).
Kriterium (festgelegt 2026-11-02 17:18, vor dem ersten Messwert):
  Rezept K1 (128x4, voll int8, SR, Clip 1, LR 0,003 konstant, WD 0,1, Warmup 500, Karte rechner-b), aber Text kurz27000.txt = dreifache Laenge aus derselben Quelle (erste Geschichten von knirps128 train.txt), eine Epoche, rund 27.000 Schritte, Snapshots 9000/13500/18000/22500 und Ende. Zwei Arme je Saat 4-11, gleiche Genesis und Fensterfolge: T2 gebunden, U2 ungebunden. Held-out (700 Fenster) und L2 tot an jedem Stand. Lernstand-Abgleich je Saat: t* = erster Stand, an dem Held-out(U2) <= Held-out(T2 bei 9000); D* = tot(T2, 9000) - tot(U2, t*). TYING TREIBT: D* >= 20 in >= 6/8 UND mittleres D* >= 20. NUR SCHNELLERE UHR: |mittleres D*| < 10 UND |D*| < 10 in >= 6/8. Sonst OFFEN; innerhalb 2 Punkten um eine Schwelle nicht erfuellt. Erreicht U2 den Lernstand in 8/8 nicht, ist der Vergleich nicht moeglich (OFFEN, mit Bericht des Abstands). Zweite Lesart, Beobachtung: tot an gleichem Schritt (Ende 27.000) T2 gegen U2, und ob tot in T2 ueber 9000 hinaus weiter waechst. Kontrollen: T2 und U2 Step 1 gleich (Paarung); T2 s4 bis Schritt 9000 NICHT bytegleich mit K1 erwartet (andere Fensterfolge, laengerer Text), das wird berichtet, nicht geprueft; Rot der Bindung wie tying-gains (SNAI_V6, keine Tying-Zeile); rc 0, Fehlerkanal, STEPS_DONE. Gemeinsam aendert sich wie in tying-gains (Bindung, Parameterzahl, w_out-Start). Reichweite: ein Rezept, ein Text, bis 27.000 Schritte.
Baut auf: snai/tying-gains, snai/gains-batchgen
Darauf baut: snai/budget-tiefe
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b ~/snai_pruef/clip/log/reihe_tie2.log, laeufe/reihe_tie2/*/mess.jsonl, log/tie2_lesen.jsonl, werkzeug/ausw_tie2.py
  m8048 Kontrolle rc / PLAN_STEPS / STEPS_DONE / Fehlerzeilen Training | 0 / 27018 / 27018 / 0 in 16/16 | T2,U2 | s4-s11 | 16
  m8049 Rot der Bindung: Endstand-Kennung / Weight Tying aktiv | T2 SNAI_V7 / 1 in 8/8; U2 SNAI_V6 / 0 in 8/8 | T2,U2 | s4-s11 | 16
  m8050 Kontrolle Step 1 T2 = U2 (Wortlaut) | NICHT erfuellt: T2 7,14-7,67 je Saat, U2 7,319 in 8/8 (= ln 1509, eigenes w_out der Genesis). Der Step-1-Loss haengt an der Ausgabematrix, also am Stellrad selbst; die Kontrolle war falsch formuliert und prueft die Fensterpaarung nicht. Fensterfolge haengt am gleichen Sitzungsnamen clip_s<s> | T2,U2 | s4-s11 | 16
  m8051 Fehlerkanal Messung | T2 nur NET2NET-Meldungen tote Kanaele L2 beim Laden, korrigiert 0 in 8/8; U2 leer | T2,U2 | s4-s11 | 16
  m8052 Held-out 700 Mittel je Stand 9000/13500/18000/22500/27018 | T2 2,6812 / 2,5930 / 2,5520 / 2,5366 / 2,5198; U2 2,8236 / 2,6822 / 2,6119 / 2,5771 / 2,5478 | T2,U2 | s4-s11 | 16
  m8053 L2 rms_ffn tot (Schwelle 0,05, %) Mittel je Stand | T2 75,6 / 87,6 / 95,1 / 96,9 / 98,9; U2 1,2 / 2,1 / 2,9 / 4,4 / 5,4 | T2,U2 | s4-s11 | 16
  m8054 Lernstand-Abgleich t* je Saat s4-s11 | 13500 / 18000 / 18000 / 13500 / 18000 / 18000 / 18000 / 18000; erreicht in 8/8 | U2 | s4-s11 | 8
  m8055 D* = tot(T2,9000) - tot(U2,t*) je Saat s4-s11 | +50,8 / +81,3 / +60,1 / +89,8 / +78,2 / +62,5 / +78,1 / +82,8; Mittel +72,95; >= 20 in 8/8 | T2 gegen U2 | s4-s11 | 8
  m8056 tot Ende FFN L0-L3 Mittel | T2 0,2 / 23,3 / 98,9 / 2,4; U2 2,8 / 6,7 / 5,4 / 2,4 | T2,U2 | s4-s11 | 16
  m8057 L1 rms_ffn tot Mittel je Stand | T2 1,6 / 7,7 / 13,8 / 18,6 / 23,3; U2 0,8 / 2,1 / 3,7 / 5,5 / 6,7 | T2,U2 | s4-s11 | 16
  m8058 tot Ende Attention L0 Mittel | T2 52,5 %; U2 0,2 % | T2,U2 | s4-s11 | 16
  m8059 RMS Embeddings (alle Elemente, Eingang) Mittel je Stand | T2 0,1143 / 0,1131 / 0,1116 / 0,1111 / 0,1104; U2 0,1216 / 0,1285 / 0,1326 / 0,1353 / 0,1371 | T2,U2 | s4-s11 | 16
  m8060 RMS g_final Mittel je Stand | T2 0,858 / 0,929 / 0,969 / 0,991 / 1,002; U2 0,765 / 0,835 / 0,891 / 0,929 / 0,954 | T2,U2 | s4-s11 | 16
  m8061 Werkzeug | clip/werkzeug/lesen_tie2.php, Definitionen wie kanal.php/ueberleb.php; an T2 s4 Ende gleich ueberleb.php (E 0,11133, g 0,99573, L2 100); Rot: EF0 s4 meldet FFN L1-L3 100 % tot | T2,U2 | s4-s11 | 80
Ergebnis e484 [2026-11-03 05:45]: erfuellt
  Fazit: TYING TREIBT nach Wortlaut: D* Mittel +72,95 Punkte, >= 20 in 8/8; U2 erreicht den T2-Lernstand von 9000 in 8/8 (bei 13.500 bzw. 18.000). Bei gleichem Lernstand ist das Absterben der L2-Gains eine Folge der Bindung, nicht einer schnelleren Uhr; Lesart B aus snai/tying-gains ist fuer dieses Rezept widerlegt. Am Ende 98,9 % gegen 5,4 % L2 tot, T2 waechst ueber 9000 weiter (L1 1,6 -> 23,3 %), Attention L0 52,5 % gegen 0,2 %. Embedding gebunden fast konstant 0,11, ungebunden 0,122 -> 0,137. Held-out-Abstand U2-T2 schrumpft 0,142 -> 0,028. Kontrolle "Step 1 gleich" war falsch formuliert (haengt am Stellrad) und ist nicht erfuellt; das Urteil haengt nicht an Schrittpaarung. Folge: FFN-Gain- und Embedding-Raetsel sitzen beide an der geteilten Matrix; TEE (snai/torch-emb-eingang) setzt dort an. Bindung bleibt in der Praxis gesetzt (noch 0,028 besser), der Vorsprung schrumpft mit dem Budget.
  Offen: Mechanismus nicht isoliert (Ausgangsgradient auf dem geteilten Embedding ist Deutung). Ob der Held-out-Vorsprung der Bindung jenseits 27.000 Schritten kippt. Ein Rezept, ein Text.
  Datei: rechner-a:~/snai_pruef/clip_rr/ERGEBNIS_tying_gains_lang.md
Chronik:
  2026-11-02 17:18 angelegt
  2026-11-03 05:44 Messwerte m8048-m8061
  2026-11-03 05:44 Status geplant -> laeuft (Messwerte m8048-m8061)
  2026-11-03 05:45 Ergebnis e484: erfuellt
  2026-11-03 05:45 Status laeuft -> ausgewertet (Ergebnis e484)
```
