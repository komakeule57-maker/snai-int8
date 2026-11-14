# snai/genesis-norm

```text
snai/genesis-norm - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-03 00:21
Frage: Beeinflusst die Genesis plus (größere FFN-Startgewichte, lebende Gains) den Embedding-Teil der Gradientennorm? Vorhersage vor dem Lesen der Werte, an den Ständen von snai/genesis-ffn, 64x4, t9002, Saaten 4 bis 6.
Kriterium (festgelegt 2026-11-02 19:53, vor dem ersten Messwert):
  Vorhersage vor dem Lesen, gesehen ist nur L2 tot von plus. Grundlage: E liegt bei 0,91 mal Wurzel(LR/(2 WD)) auch in 64x4 neu (0,112 bei LR 0,003, nachgerechnet aus den Zahlen von snai_multi_stack); Zeitkonstante rund 1.700 Schritte, also am Ende eingeschwungen und von der Genesis unabhängig. Lebende Gains in Arm alt gingen mit g_final +11 bis +19 % und E -9 bis -11 % einher. Erwartung je Saat, plus gegen neu: RMS E in [0,85; 1,05]; RMS g_final in [1,0; 1,2]; Norm² emb, gemessen bei LR 0, k=1, feste Fenster, in [1,0; 1,45], sinkt also nicht. Urteil: GETROFFEN alle drei Größen in 3/3. VERFEHLT mindestens eine Größe in 3/3 außerhalb. Sonst OFFEN. Folge bei GETROFFEN: Eine Genesis-Reparatur des Kippens löst den Embedding-Teil der Norm nicht. Reichweite: 64x4, 3 Saaten, nicht Breite 128, nicht Abkühlen.
Baut auf: snai/genesis-ffn, snai/skalenwanderung-final, snai/norm-je-tensor
Rezepte:
  r541 [2026-11-03] cd ~/snai_pruef/gradnorm; werkzeug/lauf1.sh proj_gn gen_<arm>_s<S> daten/train_a.txt 1 0 gf_gen_<arm>_s<S> SNAI_GN_LOG=1 SNAI_GN_LR0=1 SNAI_TELEMETRY_STEPS=0
      quelltext: schlange_wf2.sh; Stände Kopie von rechner-b gs/l/plus_s*, ad/l/neu_s* (md5 1c5f0570 b3f9acd0 c334ab4a, db35bc43 aded8ac8 669d881c)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/gradnorm/log/gf_gen_*.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: Nachricht snai_multi_stack, gf.py auf dequantisierten Ständen t9002, 64x4; Quotient plus gegen neu selbst gerechnet
  m7823 RMS E plus gegen neu | 1,013 / 0,990 / 1,010 | plus | 4,5,6
  m7824 RMS g_final plus gegen neu | 0,985 / 0,993 / 0,984 | plus | 4,5,6
  Quelle: rechner-a:~/snai_pruef/gradnorm/log/gf_gen_*.log, GN a=, LR 0, k=1, train_a, 1710 Fenster, Fehlerkanal 0
  m7942 Norm² emb plus gegen neu | 0,977 / 0,929 / 0,950 | plus | 4,5,6
  m7943 GF plus gegen neu | 0,996 / 0,951 / 0,965 | plus | 4,5,6
  m7944 GF plus, neu | 1,410 und 1,416 / 1,374 und 1,446 / 1,402 und 1,453 | plus, neu | 4,5,6
Ergebnis e477 [2026-11-03 00:21]: verfehlt
  Fazit: Nach Wortlaut VERFEHLT: g_final 0,98 bis 0,99 und Norm² emb 0,93 bis 0,98 liegen in 3/3 knapp unter den Intervallen; E getroffen. Die Richtung "steigt eher" war falsch, die Kernaussage hält: Plus ändert den Embedding-Normteil um höchstens 7 %, die Gesamtnorm um höchstens 5 %, obwohl L2 von 36 bis 69 % auf 0 bis 2 % tot geht. Kippen und Norm sind damit in diesem Rezept weitgehend getrennte Fragen; eine Genesis-Reparatur löst die Norm nicht.
  Offen: Nur 64x4, 3 Saaten, LR 0,003 konstant, kein Abkühlen. Breite 128 und Abkühlen nicht gemessen.
Chronik:
  2026-11-02 19:53 angelegt
  2026-11-02 19:57 Messwerte m7823, m7824
  2026-11-02 19:57 Status geplant -> laeuft (Messwerte m7823, m7824)
  2026-11-03 00:21 Rezept r541
  2026-11-03 00:21 Messwerte m7942-m7944
  2026-11-03 00:21 Ergebnis e477: verfehlt
  2026-11-03 00:21 Status laeuft -> ausgewertet (Ergebnis e477)
```
