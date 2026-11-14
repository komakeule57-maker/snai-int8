# snai/skala-norm

```text
snai/skala-norm - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 18:12
Frage: Ist der Anstieg der Gradientennorm und der Abstand K1 gegen G zum grossen Teil reine Skala zwischen Gain und nachfolgenden Gewichten, ohne Aenderung der gerechneten Funktion?
Kriterium (festgelegt 2026-11-02 17:28, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/gradnorm/kriterien_skalatest.txt. Eingriff Gain x c, Gewichte / c ueber Zeilenskalen, Gueltigkeit Held-out und Train-Loss je Arm innerhalb 0,002. Q_W = (GF(W)-GF(s4))/(GF(K1)-GF(s4)): SKALA TRAEGT <= 0,5 in 3/3; NICHT DIESE SKALA in [0,8;1,25] in 3/3; sonst OFFEN; Knapp 5 %. E_S, E_T: ERKLAERT >= 0,5 in 3/3, NICHT <= 0,2 in 3/3. final und Embeddings nicht reparametrisierbar. Prueferhinweis Mistral 4 uebernommen: Rest kann dort sitzen, wird so berichtet.
Baut auf: snai/wdg-norm
Darauf baut: snai/norm-je-tensor, snai/skalenwanderung-final
Rezepte:
  r526 [2026-11-02] werkzeug/schlange_skala.sh (C, ROT, S) und schlange_skala2.sh (skn_W, skn_T): skala.php am Stand, dann lauf1.sh proj_gn LR 0 train_a k=1 SNAI_GN_LOG=1 SNAI_GN_LR0=1, mess_text.php 700
      quelltext: werkzeug/skala.php, skala_faktoren.php, log/skala_faktoren.json
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/gradnorm/log/gf_sk_{C,ROT,S}_*, gf_skn_{W,T}_*, held_*
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/gradnorm/log/auswertung_skala.txt
  m7699 Q_W | 0,837 | W | r1 | 1710
  m7700 Q_W | 0,836 | W | r2 | 1710
  m7701 Q_W | 0,841 | W | r3 | 1710
  m7702 E_S | 0,333 | S | r1 | 1710
  m7703 E_S | 0,349 | S | r2 | 1710
  m7704 E_S | 0,336 | S | r3 | 1710
  m7705 E_T | 1,005 | T | r1 | 1710
  m7706 E_T | 1,075 | T | r2 | 1710
  m7707 E_T | 1,065 | T | r3 | 1710
  m7708 GF W r1-r3 | 4,136 4,135 4,127 | W | r1-r3
  m7709 GF S r1-r3 | 4,063 4,063 4,058 | S | r1-r3
  m7710 GF T r1-r3 | 4,374 4,436 4,409 | T | r1-r3
  m7711 Funktionsgleich, groesste Abweichung Held-out, Train | 0,0001; 0,0000 | W,S,T | r1-r3 | 9
  m7712 Rot C cmp-Bytes, GF | 0; 4,3700 | C | r1
  m7713 Rot Gains x 0,5 Held-out-Delta, GF | +1,86; 11,01 | ROT | r1
Ergebnis e465 [2026-11-02 18:12]: teilweise
  Fazit: Die Skala zwischen Gains und w_up, w_q, w_k, w_v erklaert nur rund ein Sechstel des Normanstiegs s4 zu K1 (Q_W rund 0,84, SKALA TRAEGT klar nicht; nach Wortlaut OFFEN, Knapp-Zone um 0,8). Die Vermutung ist fuer diese Tensoren nicht gestuetzt. Zugleich ist die Gesamtnorm nicht invariant: Dasselbe G-Modell hat funktionsgleich die K1-Norm (E_T rund 1,05, ERKLAERT), von K1 aus nur ein Drittel (E_S rund 0,34, OFFEN); der Spiegel haelt nicht. Die Senkung durch Decay auf Gains ist also mindestens teilweise Koordinatenwahl. Naechster billiger Schritt: Norm je Tensor an s4 und K1.
  Offen: rms_final, Embeddings, w_o, w_down nicht reparametrisierbar; warum S und T verschieden ausfallen; ein Modell; keine Aussage ueber Lernen unter anderer Skala.
  Datei: rechner-a:~/snai_pruef/gradnorm/ERGEBNIS_skala_norm.md
Chronik:
  2026-11-02 17:28 angelegt
  2026-11-02 18:12 Rezept r526
  2026-11-02 18:12 Status geplant -> laeuft (Rezept r526)
  2026-11-02 18:12 Messwerte m7699-m7713
  2026-11-02 18:12 Ergebnis e465: teilweise
  2026-11-02 18:12 Status laeuft -> ausgewertet (Ergebnis e465)
```
