# snai/torch-k1-gains

```text
snai/torch-k1-gains - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-03 00:17
Frage: Trennfrage Engine gegen Rezept: Sterben die FFN-Gains und bleiben die FFN-Zweige mittlerer Schichten beitragslos auch dann, wenn das K1-Rezept in reinem float32 unter PyTorch läuft, gebunden und ungebunden, und was leistet dort 128x2?
Kriterium (festgelegt 2026-11-02 19:51, vor dem ersten Messwert):
  Nachbau knirps_gpu/pytorch/torch_knirps.py (Bauart G1 geeicht, Gradient bis L8 geprüft), Kopie clip_torch/torch_k1.py mit Schaltern. Rezept K1: 128x4, gleiche Genesis clip_gen_s<s> und Fensterfolge (Chunk-md5 d7959d38), LR 0,003 konstant, Warmup 500, Clip 1, WD 0,1 ohne Gains, Decay auf w_alt, 9.002 Schritte, Saaten 4-11, 1 Thread. Kein SR, kein int8. Arme: TG gebunden, TU ungebunden, T2 128x2 gebunden. Messung: mess_text.php 700 Fenster (Float-Vorwärtspfad), tot = |Gain| < 0,05, Nullsetzen w_down L2 sowie L1+L2+L3. Urteil F: L2 ffn tot TG gegen K1 (Mittel 52,5 %). REZEPT: TG tot >= 26 % im Mittel UND >= 20 % in >= 6/8. ENGINE: TG tot <= 10 % in >= 6/8. Sonst OFFEN, Knapp 2 Punkte. Urteil Z (Zweig): BEITRAGSLOS wie K1: Nullen L2 kostet <= 0,02 in >= 6/8. Urteil T (Tying): TG - TU tot >= 20 Punkte in >= 6/8 VERSTÄRKT, sonst nicht. Held-out TG gegen K1: unter 10 % Gleichstand. Urteil Tiefe: T2 gegen TG mit derselben Regel wie snai/tiefe-128x2-massstab. Kontrollen: Schritt-1-Loss und GradNorm gegen Engine auf 0,5 %; Genesis G1 mit check gegen Engine-Logits, Rot --tausche-qk; Fehlerkanal. Gemeinsam ändert sich gegen K1: int8-Pfad und SR, Rechenweg float; genau die Frage. Reichweite: ein Rezept, ein Text, 9.002 Schritte. Freie Parameter: Budget, Schwelle 0,05, LR.
Darauf baut: snai/v-ueberhang, snai/neuronen-zensus, snai/torch-v-getrennt, snai/torch-emb-leiter, snai/torch-adamc
Rezepte:
  r532 [2026-11-02] rechner-b ~/snai_pruef/clip_torch: xargs -P 2 -L 1 ./eins.sh < liste.txt; eins.sh <TG|TU|T2> <s>: torch_venv python torch_k1.py train <genesis> fen/f_s<s>.bin --koepfe 8 --lr 0.003 --lr-konst --snapshots 1000,3000 [--ungebunden]; mess_text.php 700 Fenster; nullsetzen 2:w_down und 1,2,3:w_down. Ergebnisse log/mess.jsonl, log/lauf.log.
Messwerte (Groesse | Wert | Arm | Start | n):
  m7816 Eichung Genesis s4 (Engine-Vorwärtspfad nutzt w_out der V5-Datei, Vergleich daher --ungebunden) max Logit-Diff | 1,863e-09, Argmax 100 %
  m7817 Rot --tausche-qk | 4,872e-04, Argmax 81,2 %, ROT gesehen
  m7818 Eichung Torch-Stand TG s4 t1000 gebunden exportiert, Engine-Vorwärtspfad | 1,001e-05 bei Logit bis 9,825, Argmax 100 %
  m7819 Schritt 1 s4 Loss Torch / Engine | 7,5216 / 7,5229
  m7820 Schritt 1 s4 GradNorm Torch / Engine | 11,6745 / 11,6736
  m7821 Fenster-Chunk md5 | d7959d38 = K1T chunk_clip_s4_0.txt
  m7822 Fehlbedienung erste Eichung | check ohne --ungebunden verglich emb gegen w_out, rot war Bedienfehler, nicht Bauart
  m7870 Bedienfehler TG s6, s7 rc=127 | eins.sh während des Laufs geändert, Bash las danach mitten in Zeile 9 weiter: ch_k1.py nicht gefunden, train.log überschrieben. Training selbst lief vorher durch (828 und 846 s, ende.snai und Snapshots vorhanden, Messungen vollständig), nur das Trainingsprotokoll fehlt; Modelle gelten, Prüfung Schrittzahl dort nicht mehr möglich. eins.sh seither unberührt, in laufenden Reihen nicht mehr ändern.
  m7926 TG L2 ffn tot s4 bis s11 | 88 32 81 96 66 62 39 73, Mittel 67,2
  m7927 TG ffn tot L0 L1 L2 L3 | 0,0 1,3 67,2 0,6
  m7928 TG att tot L0 L1 L2 L3 | 30,2 1,3 0,3 0,1
  m7929 TG Held-out Mittel, K1 Mittel | 2,6739, 2,6842
  m7930 TG Nullen w_down L2 / L1+L2+L3 Kosten Mittel | 0,0012 / 0,2320
  m7931 TU ffn tot L0-L3, Held-out, Kosten L1-3 | 0,2 1,4 1,2 0,0; 2,8669; 0,5447
  m7932 TU minus TG Held-out s4 bis s11 | 0,2184 0,186 0,2386 0,1725 0,1899 0,1946 0,135 0,209
  m7933 T2 Held-out Mittel, D gegen TG s4 bis s11 | 2,7098; 0,0635 0,0475 0,0327 0,0231 0,0622 0,0351 -0,0131 0,0369
  m7934 E und g_final Mittel TG / TU / T2 | 0,1168 0,8694 / 0,0931 0,7458 / 0,1168 0,8440
Ergebnis e476 [2026-11-03 00:17]: erfuellt
  Fazit: REZEPT nach Wortlaut: In reinem float32 unter PyTorch sterben die FFN-Gains von L2 ebenso (Mittel 67,2 %, 8/8 >= 20 %), der Zweig ist ebenso beitragslos (0,0012), Tying verstärkt ebenso (TG minus TU >= 20 Punkte in 8/8), Held-out gegen K1 Gleichstand (2,6739 gegen 2,6842, 0,4 %). Das Gain-Sterben ist also kein 8-Bit-Defekt, im 8-Bit-Pfad gibt es dafür nichts zu reparieren. Tiefe: T2 SCHLECHTER (7/8, +0,036), wie in der Engine. Reichweite: 128x4, K1-Rezept, ein Text, 9.002 Schritte, 8 Saaten. Der Widerspruch zu archiv- und e150-Befund (ungebunden kippt dort) bleibt offen: andere Breite und LR. Die Reparatur setzt an Genesis oder Skalen an, siehe snai/torch-genesis-128 und snai/torch-lns-zerlegung.
Chronik:
  2026-11-02 19:51 angelegt
  2026-11-02 19:51 Rezept r532
  2026-11-02 19:51 Status geplant -> laeuft (Rezept r532)
  2026-11-02 19:53 Messwerte m7816-m7822
  2026-11-02 20:32 Messwerte m7870
  2026-11-03 00:17 Messwerte m7926-m7934
  2026-11-03 00:17 Ergebnis e476: erfuellt
  2026-11-03 00:17 Status laeuft -> ausgewertet (Ergebnis e476)
```
