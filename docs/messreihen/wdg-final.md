# snai/wdg-final

```text
snai/wdg-final - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-03 11:47
Frage: Isoliert ein Eingriff die Final-Gain als Hebel für die Gradientennorm? Decay 0,1 nur auf rms_final gegen Decay 0,1 nur auf rms_att und rms_ffn, Fortsetzung ab c128sr s4.
Kriterium (festgelegt 2026-11-02 19:22, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/gradnorm/kriterien_wdf.txt. Arme F (nur rms_final) und L (nur rms_att, rms_ffn), r1 bis r3, gepaart zu dc_K1 und dc_G, Rezept wie snai/wdg-norm: c128sr s4, LR 2,5e-4, WD 0,1, 30.000 Fenster. GF: LR 0, k=1, train_a. Q = (GF Arm - GF s4) / (GF dc_K1 - GF s4), je Reihenfolge. Gesamtnorm: SENKT Q <= 0,5 in 3/3, GLEICH Q in [0,8; 1,25] in 3/3, sonst OFFEN, knapp 5 %. Wortlaut aus Teil 2 von kriterien_tensor.txt. Ergänzung vor dem Start: Q_emb = Anstieg der mittleren Norm² nur emb, Arm gegen dc_K1. HEBEL FINAL: Q_emb(F) <= 0,5 und Q_emb(L) >= 0,8 in 3/3. HEBEL SCHICHT: umgekehrt. Sonst kein Hebel-Urteil. Held-out gleichrangig, Unterschied zählt ab 10 % des Gewinns und 0,01 nats in 3/3. Beide Lesarten werden berichtet.
Baut auf: snai/wdg-norm, snai/norm-je-tensor, snai/skalenwanderung-final
Darauf baut: snai/adamc-dc
Rezepte:
  r530 [2026-11-02] cd ~/snai_pruef/gradnorm; setsid -f nohup werkzeug/schlange_wf.sh (je Lauf werkzeug/lauf_wf.sh F|L r1-3; danach GF lauf1.sh proj_gn, Held-out mess_text.php)
      quelltext: clip/werkzeug/patch_wdf.py 4ea72d7e auf bau_wdg, Lib clip/bau_wdf 5b07d33f
      seed: r1,r2,r3 Fensterreihenfolge über Dateinamen; gepaart zu dc_K1, dc_G
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/gradnorm/log/wf_*.log, gf_wf_*.log, held_wf_*, schlange_wf.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a ~/snai_pruef/gradnorm: log/gf_*.log (GN-Zeilen, emb-Norm² = a0·norm²), log/held_*.txt, Trainingslogs (Step 1, [WDG]), sonde_staende.php; scratchpad wdf_teil.py; Stand 06:10, r3 unvollständig
  m8078 Kontrolle Step 1 Loss/GradNorm gleich dc_K1 | r1 2,035681/2,9139, r2 2,229864/2,7644, r3 2,075652/2,8504 in allen vorhandenen Läufen | F,L
  m8079 Kontrolle [WDG]-Zeile, Fehlerkanal Training und GF | nur=final bzw. nur=schicht; 0 Fehlerzeilen außer NET2NET-Meldungen (korrigiert 0) | F,L
  m8080 GF s4 / emb-Norm² s4 | 2,9327 / 5,6982 | s4
  m8081 GF, emb-Norm², Held-out r1 | 4,3700; 10,9384; 2,0210 | dc_K1 | 1
  m8082 GF, emb-Norm², Held-out r2 | 4,3704; 10,9445; 2,0229 | dc_K1 | 2
  m8083 GF, emb-Norm², Held-out r3 | 4,3524; 11,0642; 2,0281 | dc_K1 | 3
  m8084 GF, Q, Q_emb, Held-out r1 | 3,5006; 0,395; -0,154; 2,0292 | F | 1
  m8085 GF, Q, Q_emb, Held-out r2 | 3,5071; 0,400; -0,159; 2,0318 | F | 2
  m8086 GF, Q, Q_emb, Held-out r1 | 4,3200; 0,965; 0,984; 2,0277 | L | 1
  m8087 GF, Q, Q_emb, Held-out r2 | 4,3606; 0,993; 1,023; 2,0332 | L | 2
  m8088 Held-out s4, Schwelle 10 % des Gewinns | 2,253; Gewinn 0,23, Schwelle 0,023 | s4
  m8089 RMS E, g_final, P je r1/r2/r3 | 0,0485/0,0484/0,0484; 2,529/2,530/2,528; 0,1226/0,1226/0,1224 | dc_K1
  m8090 RMS E, g_final, P je r1/r2/r3 | 0,0573/0,0574/0,0573; 1,755/1,756/1,754; 0,1006/0,1008/0,1006 | F
  m8091 RMS E, g_final, P je r1/r2 | 0,0480/0,0481; 2,541/2,542; 0,1219/0,1223 | L
  Quelle: rechner-a:~/snai_pruef/gradnorm/log (gf_wf_*_r3.log, held_wf_*_r3.txt, wf_*_r3.log), wdf_teil.py r1,r2,r3, sonde_staende.php; Fehlerkanal leer bis auf NET2NET-Meldung (korrigiert 0), rc 0, [WDG] je Arm richtig, Step 1 gleich dc_K1 in 9/9
  m8259 GF | 3,4664 | F | r3 | 1710
  m8260 GF | 4,3729 | L | r3 | 1710
  m8261 GF | 4,3524 | dc_K1 | r3 | 1710
  m8262 emb-Norm2 | 4,8716 | F | r3 | 1710
  m8263 emb-Norm2 | 11,3264 | L | r3 | 1710
  m8264 emb-Norm2 | 11,0642 | dc_K1 | r3 | 1710
  m8265 Q | 0,376 | F | r3
  m8266 Q | 1,014 | L | r3
  m8267 Q_emb | -0,154 | F | r3
  m8268 Q_emb | 1,049 | L | r3
  m8269 Held-out | 2,0354 | F | r3 | 700
  m8270 Held-out | 2,0403 | L | r3 | 700
  m8271 Held-out | 2,0281 | dc_K1 | r3 | 700
  m8272 RMS emb / g_final mittel | 0,05734 / 1,7543 | F | r3
  m8273 RMS emb / g_final mittel | 0,048211 / 2,5401 | L | r3
  m8274 RMS emb / g_final mittel | 0,048418 / 2,5283 | dc_K1 | r3
Ergebnis e498 [2026-11-03 11:47]: erfuellt
  Fazit: Nach Wortlaut: F SENKT (Q 0,395/0,400/0,376), L GLEICH (Q 0,965/0,993/1,014), HEBEL FINAL (Q_emb F −0,15 in 3/3, L 0,98-1,05). Held-out: kein Unterschied über der Schwelle 0,023 (F +0,007 bis +0,009, L +0,007 bis +0,012, alle über dc_K1 – Tendenz, kein Befund). Kontrollen: Step 1 gleich dc_K1 9/9, [WDG] richtig, Fehlerkanal leer. Folge: Der Embedding-Anteil des Normanstiegs hängt an der Final-Gain, jetzt per Eingriff isoliert. Mit snai/f2-emb-gradteil (Ausgangsseite ≈ 90 % des E-Gradienten) ist der Mechanismus für diesen Teil geschlossen. Die Schicht-Gains sind kein Hebel. Der verteilte Rest (Q ≈ 0,39 bleibt) ist damit nicht erklärt; das prüft snai/adamc-dc.
  Offen: Wirkung über den ganzen Abkühlplan (g_final wächst gerade dort). Ob die leichte Held-out-Tendenz bei längerem Lauf echt wird. Eine Saat, ein Modell, nicht eingeschwungen.
  Datei: rechner-a:~/snai_pruef/gradnorm/ERGEBNIS_wdg_final.md
Chronik:
  2026-11-02 19:22 angelegt
  2026-11-02 19:27 Rezept r530
  2026-11-02 19:27 Status geplant -> laeuft (Rezept r530)
  2026-11-03 06:06 Messwerte m8078-m8091
  2026-11-03 11:46 Messwerte m8259-m8274
  2026-11-03 11:47 Ergebnis e498: erfuellt
  2026-11-03 11:47 Status laeuft -> ausgewertet (Ergebnis e498)
```
