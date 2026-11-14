# snai/vorhersage-ffn-arme

```text
snai/vorhersage-ffn-arme - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-04 07:40
!! ohne Rezept
Frage: Warum schlagen mehr FFN (TP) und weniger FFN (TLS) beide TG im Float? Vorhersage vor TLF, TF0, TGF, ausgewertet mit den Regeln aus snai/torch-lns-zerlegung und snai/torch-gain-rauschen.
Kriterium (festgelegt 2026-11-02 22:46, vor dem ersten Messwert):
  Zwei Lesarten. H1 Halbtot ist die schlechteste Lage: ganz leben oder gar nicht sind besser als teils sterben. H4 Zwei getrennte Wirkungen: TP gewinnt, weil FFN mehr trägt (Nullen 0,32 gegen 0,23); LNS gewinnt über kleinere Tiefenskala, nicht über weniger FFN. Meine Wette: H4.
Vorhersagen, Regeln der Quellreihen: V1 TF0 gegen TG nicht BESSER (H1 sagt BESSER; L1 und L3 leben in TG und tragen). V2 TLF gegen TL GLEICH oder BESSER (Nullen kostet in TL nur 0,024). V3 TGF gegen TG SCHLECHTER und RMS E in TGF >= 1,2 mal TG, also >= 0,140, in mindestens 6/8. Grund: g_final ist dort fest auf 1, die Logit-Skala muss also über E kommen, gegen das Decay-Gleichgewicht. V3 ist zugleich ein Gegenversuch zum Zug nach außen aus snai/embedding-nachlaufen, ohne ihn zu beweisen.
Urteil: H4 GESTÜTZT, wenn V1 und V2 eintreffen. H1 GESTÜTZT, wenn TF0 BESSER und TLF nicht schlechter. Sonst keine Lesart. V3 zählt getrennt.
Einwand vorab: Alle Abstände unter 2 %, TLS erst 3 Saaten, TK zeigt Chaos im Einzelwert. Die Frage selbst könnte zum Teil Rauschen erklären. Gesehen vor dem Eintrag: Mittelwerte TG, TU, TP, TL, TLS, TK aus der Nachricht von snai_int8_lora, keine Werte von TLF, TF0, TGF. Deutung, nicht gemessen, bleibt auch GESTÜTZT, solange kein eigener Eingriff die Tiefenskala trennt.
Baut auf: snai/torch-lns-zerlegung, snai/torch-gain-rauschen, snai/embedding-nachlaufen
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b ~/snai_pruef/clip_torch/laeufe/{TG,TGF}_s*/ende.snai, Leser wie g() in aus.py (RMS ueber alle V*D Embedding-Werte), ausgelesen 2026-11-04; Mittel gleich m8609 und der Nachricht des Hauptbaums
  m8612 RMS E Ende | 0.1156 | TG | 4
  m8613 RMS E Ende | 0.1171 | TG | 5
  m8614 RMS E Ende | 0.1165 | TG | 6
  m8615 RMS E Ende | 0.1171 | TG | 7
  m8616 RMS E Ende | 0.1175 | TG | 8
  m8617 RMS E Ende | 0.1176 | TG | 9
  m8618 RMS E Ende | 0.1167 | TG | 10
  m8619 RMS E Ende | 0.1165 | TG | 11
  m8620 RMS E Ende | 0.1095 | TGF | 4
  m8621 RMS E Ende | 0.1090 | TGF | 5
  m8622 RMS E Ende | 0.1091 | TGF | 6
  m8623 RMS E Ende | 0.1101 | TGF | 7
  m8624 RMS E Ende | 0.1084 | TGF | 8
  m8625 RMS E Ende | 0.1114 | TGF | 9
  m8626 RMS E Ende | 0.1111 | TGF | 10
  m8627 RMS E Ende | 0.1098 | TGF | 11
  m8628 RMS E Mittel | 0.1168 | TG | s4-s11 | 8
  m8629 RMS E Mittel | 0.1098 | TGF | s4-s11 | 8
  m8630 RMS E TGF/TG je Saat Spanne | 0,922-0,952 (kleiner in 8/8) | TGF | s4-s11 | 8
  m8631 g_final Mittel Ende (gelernt) | 0,788-0,809 | TG | s4-s11 | 8
  m8632 V3 alt: RMS E TGF >= 0,140 | 0/8 | TGF | s4-s11 | 8
  m8633 V3 neu: RMS E TGF in [0,10; 0,125] | 8/8 | TGF | s4-s11 | 8
  m8634 Held-out D TGF gegen TG (aus e512, m8605) | +0,164, schlechter 8/8 | TGF | s4-s11 | 8
Ergebnis e515 [2026-11-04 07:40]: keine_aussage
  Fazit: Nach Wortlaut keine Lesart. V1 ist eingetroffen (TF0 GLEICH TG). V2 ist OFFEN (TLF −0,0124, besser in 7/8, Schwelle −0,02 verfehlt), deshalb ist weder H1 noch H4 gestützt. V3 zählt getrennt: V3 alt ist verfehlt (TGF SCHLECHTER +0,164 in 8/8, aber RMS E >= 0,140 in 0/8), V3 neu ist eingetroffen (RMS E 0,108-0,111 in [0,10; 0,125], 8/8). Auch TG liegt in diesem Intervall, deshalb unterscheidet V3 neu wenig.

Zweite Lesart: V2 verfehlt nur auf der guten Seite. Zusammen mit e513 (LNS wirkt über die Attention-Gains, TLSA −0,042 in 8/8) spricht das gegen H1 und für H4 in präzisierter Form: TLS gewinnt über die Attention-Skala, nicht über weniger FFN. Eine eigene Folgereihe lohnt nicht, denn snai/engine-lns-schlank prüft das in 8 Bit.

Deutung, nicht gemessen: Steht g_final fest auf 1 statt bei rund 0,80, sinkt E um rund 6 % (TGF/TG 0,92-0,95 in 8/8, nach Hausregel Gleichstand), statt zu steigen. E hängt also am Decay-Gleichgewicht, nicht an der Final-Gain. Die Begründung von V3 alt hatte die Richtung falsch.

Reichweite: float32, K1, ein Text, 9.002 Schritte, 128x4, 8 Saaten (TLS 3), ohne Eingangsfaktor. TGF Held-out stammt aus e512, nicht selbst nachgerechnet. RMS E habe ich selbst ausgelesen und gegen m8609 geeicht.
  Offen: Ob die Attention-Skala aus LNS die Wirkung von TLS ganz erklärt, hat die Reihe nicht getrennt. Ebenso offen bleibt, ob das in 8 Bit und über 9.002 Schritte hinaus gilt (snai/engine-lns-schlank).
  Datei: rechner-a:~/snai_pruef/gradnorm/ERGEBNIS_vorhersage_ffn.md
Chronik:
  2026-11-02 22:46 angelegt
  2026-11-02 22:46 Korrektur vor dem Lesen von TGF, Wortlaut oben bleibt: V3 beruhte auf einer ungeprüften Annahme. K1 int8 128x4 Ende: g_final 0,8568/0,8406/0,8775, E 0,1135/0,1142/0,1144 (s4 bis s6); g_final fest auf 1 verlangt kein größeres E. V3 zurückgezogen, Einwand TGF2 zurückgezogen. Neu: RMS E in TGF in [0,10; 0,125], kein Held-out-Urteil. Beide Fassungen werden berichtet.
  2026-11-03 02:28 Zwischenstand 2026-11-03 02:35. V2 (TLF gegen TL GLEICH oder BESSER): nach Wortlaut der Quellreihe OFFEN, Mittel -0,0124, besser 7/8; BESSER verlangt <= -0,02, GLEICH |Mittel| < 0,01. V2 also nicht eingetroffen, die Abweichung liegt aber auf der guten Seite. Zweite Lesart: Nicht schlechter, die Kosten aus der Nullen-Messung (0,024) sagten einen Schaden voraus, der beim Training von Anfang an ausbleibt. TF0 fehlt, damit V1 und das H1/H4-Urteil offen. V3 (neu) wartet auf TGF.
  2026-11-03 03:59 2026-11-03 04:20, TF0 8/8 von snai_int8_lora: D gegen TG Mittel +0,0002, |D| < 0,02 in 7/8, also GLEICH. V1 (TF0 nicht BESSER) eingetroffen, H1 nicht gestützt (verlangt TF0 BESSER). V2 nach Wortlaut OFFEN, deshalb ist auch H4 nach Wortlaut nicht gestützt, also "keine Lesart". Zweite Lesart: V2 verfehlt nur auf der guten Seite (TLF besser als TL, 7/8, -0,012), das spricht eher für H4 als für H1. V3 (neu) wartet weiter auf TGF. Ergebnis erst mit TGF.
  2026-11-04 07:40 Messwerte m8612-m8634
  2026-11-04 07:40 Status geplant -> laeuft (Messwerte m8612-m8634)
  2026-11-04 07:40 Ergebnis e515: keine_aussage
  2026-11-04 07:40 Status laeuft -> ausgewertet (Ergebnis e515)
```
