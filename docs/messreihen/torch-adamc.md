# snai/torch-adamc

```text
snai/torch-adamc - ausgewertet, angelegt 2026-11-03, zuletzt 2026-11-03 18:06
Frage: Float-Gegencheck zu snai/adamc-dc: Gilt Evos AdamC-Befund (WD 0,025 statt 0,1 bei LR auf einem Viertel senkt den Normanstieg auf Q 0,47-0,49 und verbessert den Held-out um 0,036-0,039) auch in float32 (Torch-Nachbau 128x4 gebunden), oder hängt er am int8-Pfad?
Kriterium (festgelegt 2026-11-03 14:05, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/clip_torch/ac/KRITERIEN_adamc_torch.md (md5 927c978f), Fassung nach Evos Gegenlesen, vor dem ersten Lauf. Wortlaut der Vorgabe unverändert:
- Q in Evos Definition (GF des Startstands und des WD-0,1-Arms, gleicher Stand, gleiche Fenster).
- REPLIZIERT, wenn Q in [0,38; 0,58] in mindestens 6/8 Saaten; WIDERLEGT, wenn Q ≥ 0,8 in mindestens 6/8; sonst OFFEN.
- Hauptfrage Held-out: C ist besser ab 0,023 nats in mindestens 6/8 Saaten. Dazu gepaarter Bootstrap.
- Daneben RMS von vo und ffn gegen den Startstand.
- Gemessen wird in der Engine wie bisher.
Lesart nach Evo: [E1] Urteilsstand N = 10.028 Fortsetzungsschritte (snap_t19030, lr·N = 7,52 wie Evo), Endstand 30.085 zweite Lesart ohne Urteil. [E3] GF-Hauptgröße = gebundene Norm (Torch, gf_torch.py, train_a 1.710 Fenster wie die Engine); Engine-Float (summiert emb und w_out getrennt, im Code geprüft) zweite Lesart; verschiedene Klassen beider Lesarten in einer Saat = OFFEN für diese Saat; Q_geb − Q_getr je Saat. [E4] Q undefiniert, wenn GF_K1 − GF_Start < 10 % von GF_Start; mehr als 2 undefiniert = KEINE AUSSAGE; Decay-einmal-Test und Wächter-Kontrollen (Gewichte nach Laden gleich, korrigiert 0). [E5] Held-out zweite Lesart: 10 % des mittleren Gewinns Start→K1. [E2] Reichweite: int8-Momente bei Evo, Gleichgewichtslage verschieden.
Plan: rechner-b:~/snai_pruef/clip_torch/ac/KRITERIEN_adamc_torch.md
Baut auf: snai/adamc-dc, snai/torch-k1-gains
Rezepte:
  r559 [2026-11-03] K1 (WD 0,1), C (WD 0,025): rechner-b: cd ~/snai_pruef/clip_torch/ac && setsid -f ./kette.sh  (wartet auf REIHE_ENDE ee27, 16:30; TG-Neulauf eins_tgn.sh, Kontrollen, GF Start, Arme eins_ac.sh <K1 0.1|C 0.025> <s>: torch_k1a.py train TGN_s<s>/ende.snai ac/fen_skala_r1.bin --lr 0.00075 --lr-konst --wd W --snapshots 19030 --adam-ein TGN_s<s>/ende_adam.snai; Messung gf_torch.py, mess_text, gf.sh float). Auswertung: torch_venv/bin/python ac/ausw_ac.py
      quelltext: torch_k1a.py 4914d681 (patch_ac.py 74636114 aus torch_k1e.py 93855f6e); kette.sh 7f87ecda; eins_ac.sh decfa35b; eins_tgn.sh 3051be9e; gf.sh e41a5d14; gf_torch.py 8a0eb4f6; gewichte_gleich.py f84c7c34; decay_test.py 7a2c35eb; ausw_ac.py 6a6934c8; fen_export_ac.php 298c1f7d
      seed: 4-11
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/clip_torch/ac/log (lauf.log, mess.jsonl, gf_*.log, gft_*.jsonl), ac/laeufe/{TGN,K1,C}_s<s>, ac/kontrolle, ac/gfout
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/clip_torch/ac/ausw_ac.py -> ac/log/ausw_ac.txt (md5 6c0d034b)
  m8414 Q Torch gebunden N=10.028 | 0,310 | C | 4
  m8415 Q Torch gebunden N=10.028 | 0,318 | C | 5
  m8416 Q Torch gebunden N=10.028 | 0,317 | C | 6
  m8417 Q Torch gebunden N=10.028 | 0,277 | C | 7
  m8418 Q Torch gebunden N=10.028 | 0,338 | C | 8
  m8419 Q Torch gebunden N=10.028 | 0,307 | C | 9
  m8420 Q Torch gebunden N=10.028 | 0,199 | C | 10
  m8421 Q Torch gebunden N=10.028 | 0,338 | C | 11
  m8422 Q Engine-Float N=10.028 | 0,204-0,340, Q_geb-Q_getr -0,005..+0,003 | C |  | 8
  m8423 Q in [0,38; 0,58] | 0/8 | C
  m8424 Q >= 0,8 | 0/8 | C
  m8425 Q_emb N=10.028 | 0,132-0,257 | C |  | 8
  m8426 Q_rest N=10.028 | 0,235-0,398 | C |  | 8
  m8427 GF-Anstieg K1 gegen Start | 42,4-56,3 % | K1 |  | 8
  m8428 Q Endstand N=30.085 | 0,219-0,283 | C |  | 8
  m8429 Held-out D C-K1 N=10.028 | Mittel -0,0362, je Saat -0,032..-0,040, Bootstrap -0,0378..-0,0345 | C |  | 8
  m8430 Held-out C besser >= 0,023 | 8/8 | C
  m8431 Held-out D C-K1 Endstand | Mittel -0,0873, Bootstrap -0,0903..-0,0843 | C |  | 8
  m8432 RMS vo/ffn C naeher am Start | 8/8 / 8/8 | C
  m8433 RMS emb/qk/vo/ffn N=10.028 Start/K1/C | 0,117/0,110/0,106/0,105 ; 0,084/0,082/0,073/0,076 ; 0,123/0,114/0,111/0,109 |  |  | 8
Ergebnis e506 [2026-11-03 18:06]: teilweise
  Fazit: Nach Wortlaut: NORM OFFEN (Q 0,20-0,34, in 0/8 im Fenster [0,38; 0,58], 0/8 >= 0,8; beide Lesarten einig), HELD-OUT C BESSER 8/8 (Mittel -0,036, Bootstrap -0,038..-0,035), Deutungsregel 8/8 erfuellt. Evos AdamC-Gewinn ist kein int8-Effekt: in float32 derselbe Held-out-Gewinn wie bei Evo (-0,036 gegen -0,036..-0,039), der Normanstieg wird sogar staerker gesenkt. OFFEN steht nur, weil das Fenster um Evos Wert lag und float darunter liegt; die Richtung ist eindeutig. Der Unterschied sitzt im Embedding-Anteil (Q_emb 0,13-0,26 hier, 0,55-0,59 bei Evo). Naechster Schritt: AdamC ueber den ganzen Abkuehlplan.
  Offen: Warum der Embedding-Anteil im int8-Modell weniger nachgibt (int8-Momente/SR oder Evos Gleichgewichtsstart) trennt die Reihe nicht. Kein Abkuehlplan, eine LR-Stufe.
  Datei: rechner-b:~/snai_pruef/clip_torch/ac/ERGEBNIS_torch_adamc.md
Chronik (juengste 8 von 9, voll=True zeigt alle):
  2026-11-03 14:05 Kriterium geaendert, vorher: rechner-b:~/snai_pruef/clip_torch/ac/KRITERIEN_adamc_torch.md (md5 c61cb8e4), vor dem ersten Lauf. Fortsetzung ab TG-Endständen s4-s11 mit Adam-Zustand (TG-Neulauf bytegleich, ac/torch_k1a.py), LR 0,00075 konstant, skala_r1 30.085 Fenster, Clip 1, EIN Stellrad WD 0,1 (K1) gegen 0,025 (C). GF in der Engine (eigene Kopie von gradnorm/proj_gn, Float-Pfad dtype 1, INT8_FULL=0, LR 0, k=1, train_a 1.710 Fenster); die Float-Engine summiert emb und w_out getrennt (sqrt(|g_ein|²+|g_aus|²+Rest)), Torch-gebundene Norm als zweite Lesart ohne Urteil.
- Q in Evos Definition (GF des Startstands und des WD-0,1-Arms, gleicher Stand, gleiche Fenster).
- REPLIZIERT, wenn Q in [0,38; 0,58] in mindestens 6/8 Saaten; WIDERLEGT, wenn Q ≥ 0,8 in mindestens 6/8; sonst OFFEN.
- Hauptfrage Held-out: C ist besser ab 0,023 nats in mindestens 6/8 Saaten. Dazu gepaarter Bootstrap.
- Daneben RMS von vo und ffn gegen den Startstand.
- Gemessen wird in der Engine wie bisher.
Lesart: Q undefiniert, wenn GF_K1 <= GF_Start (zählt für keine Seite); "besser ab 0,023" = C − K1 <= −0,023 je Saat; Deutungsregel wie Evo (vo und ffn von C in >= 6/8 näher am Start). | Grund: Gegenlesen durch Evo vor dem ersten Lauf: Lernraten-Budget, Normdefinition, fehlende Kontrollen. Noch kein Messwert.
  2026-11-03 14:05 Rezept r559 (K1 (WD 0,1), C (WD 0,025))
  2026-11-03 14:05 Status geplant -> laeuft (Rezept r559)
  2026-11-03 14:46 Rezept r559: kette.sh ist jetzt md5 085d2596 statt 7f87ecda. Am 2026-11-03 um 14:36 wurde auf Wunsch nur die 16:30-Sperre entfernt (Zeile 7). Der Rest ist laut diff gegen kette.sh.bak_1630 unverändert, ich habe das geprüft. Die Kette startet jetzt nach REIHE_ENDE von ee27. Auf Aufbau, Kriterium und Messung hat das keinen Einfluss.
  2026-11-03 15:19 15:02 Kette gestartet. Der TG-Neulauf ist in 8/8 Saaten bytegleich zu TG (ende, snap_t1000, snap_t3000), adam_t 9002. Danach hielt die Kette bei der Kontrolle an (15:17). Ursache war die Teilprüfung „Loss Schritt 2 verschieden“: Sie las die Logzeile mit nur 5 Nachkommastellen. In voller Genauigkeit (ac/schritt2.py) unterscheiden sich K1 und C um 7,2e-7, K1b ist gleich K1. Der Fehler lag also in der Prüfung, nicht im Aufbau. ac/kette2.sh (md5 a81ae4ec) wiederholt nur diese Prüfung an denselben Ständen: Kontrollen GRÜN, Decay-einmal-Test GRÜN. Ab 15:18 laufen GF der Startstände und die Arme. Der Nachtrag steht in der Kriteriendatei, die damit md5 eadc18d0 hat. Wortlaut und Aufbau sind unverändert.
  2026-11-03 18:06 Messwerte m8414-m8433
  2026-11-03 18:06 Ergebnis e506: teilweise
  2026-11-03 18:06 Status laeuft -> ausgewertet (Ergebnis e506)
```
