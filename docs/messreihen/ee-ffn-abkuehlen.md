# snai/ee-ffn-abkuehlen

```text
snai/ee-ffn-abkuehlen - ausgewertet, angelegt 2026-11-04, zuletzt 2026-11-04 06:42
Frage: Nützen die mittleren FFN-Zweige L1-L3 (mit Eingangsfaktor) mehr, wenn die Lernrate ab t50000 von 0,003 auf 0,001 sinkt?
Kriterium (festgelegt 2026-11-04 05:36, vor dem ersten Messwert):
  Wortlaut: rechner-b ~/snai_pruef/clip_lns/KRITERIEN_fl50.md (md5 f8b9d4c0, vor dem Start). Aufbau: aus F100-Snapshot t50000 (snai/ee-ffn-budget100k) zwei Arme FK (LR 0,003) und FL (LR 0,001), sonst wortgleich zu snai/ee-lr-spaet (frisch27k, gleiche Fensterfolge, s4-s7); Gegenstück sind deren Arme K und L. D_a = Loss(F-Arm) − Loss(E-Arm) am Ende (heldout, 700 Fenster, mit F), H = D_L − D_K. Urteil 1: NUTZEN UNTER ABKÜHLEN bei Mittel D_L >= 0,02 und D_L > 0 in >= 3/4; ENTBEHRLICH bei Mittel D_L < 0,01 und D_L < 0,02 in >= 3/4; sonst OFFEN. Urteil 2: WECKT bei Mittel H >= +0,01 und H > 0 in >= 3/4; DÄMPFT spiegelbildlich; KEIN EFFEKT bei |Mittel H| < 0,005; sonst OFFEN; 2:2 saatabhängig. Knapp (0,003 um eine Schwelle): nicht erfüllt, Bootstrap und heldout2. Größenregel: unter 10 % des Loss ist der Größe nach Gleichstand. Kontrollen: rc 0, STEPS=PLAN, Start adam_t 50000, LR im Log, embein, CLIP 1, SR, genau 3 NET2NET-Zeilen je F-Arm, L1-L3-Gains bleiben 100 % null. Reichweite 128x4, int8, ein Text, nach Neustart aus Snapshot.
Baut auf: snai/ee-lr-spaet
Rezepte:
  r567 [2026-11-04] rechner-b ~/snai_pruef/clip_lns: setsid -f nohup ./reihe_fl50.sh (md5 6fc735e1, per assert-Ersetzung aus reihe_lr50.sh). Je Lauf CLIP_LR=<0.003|0.001> CLIP_GENPFX=f50_ ./lauf_clip_lns.sh fl50 <FK|FL> - <s> daten/frisch27k.txt 59000,68000, 8 zugleich, CPU, 1 Thread.
      quelltext: Lib bau_emb_voll 3475df5c; Genesis = F100-Snapshots t50000 (s4 a9110e4c, s5 2f43f254, s6 c006e3bf, s7 f52ed1b9)
      parameter: frisch27k md5 6437cc82, LR 0,003 bzw. 0,001, WD 0,1, SR, Clip 1, gebunden, SNAI_EMB_EIN 11,3137085
      seed: s4-s7 über Sitzungsname clip_s<s>, Fensterfolge gleich K/L aus snai/ee-lr-spaet
      rechner: rechner-b
      logs: rechner-b ~/snai_pruef/clip_lns/log/fl50.log, laeufe/fl50/*, log/fl50_tot.jsonl
      notiz: Gestartet 05:35:48 im Hauptbaum im Rahmen des Ziels. Prüfer Gemini/Mistral ohne stichhaltigen Einwand (Antworten in der Kriteriendatei). Ende etwa 06:50.
Messwerte (Groesse | Wert | Arm | Start | n):
  m8576 D_heldout | 0.0170 | K | s4
  m8577 D_heldout | 0.0086 | K | s5
  m8578 D_heldout | 0.0188 | K | s6
  m8579 D_heldout | 0.0272 | K | s7
  m8580 D_heldout | 0.0337 | L | s4
  m8581 D_heldout | 0.0261 | L | s5
  m8582 D_heldout | 0.0327 | L | s6
  m8583 D_heldout | 0.0290 | L | s7
  m8584 D_heldout2 | 0.0174 | K | s4
  m8585 D_heldout2 | 0.0102 | K | s5
  m8586 D_heldout2 | 0.0177 | K | s6
  m8587 D_heldout2 | 0.0267 | K | s7
  m8588 D_heldout2 | 0.0268 | L | s4
  m8589 D_heldout2 | 0.0259 | L | s5
  m8590 D_heldout2 | 0.0288 | L | s6
  m8591 D_heldout2 | 0.0235 | L | s7
Ergebnis e511 [2026-11-04 06:42]: teilweise
  Fazit: Urteil 1 NUTZEN UNTER ABKÜHLEN: Mittel D_L +0,030 (heldout, 4/4 > 0, nicht knapp), auf heldout2 +0,026. Der Größe nach ist das Gleichstand: 1,3 % des Loss. Urteil 2 OFFEN: Mittel H +0,0125 auf heldout ist knapp, auf heldout2 nur +0,0083 (3/4, Bootstrap +0,000 bis +0,014). Kontrollen sauber: 8/8 rc 0, je 3 NET2NET, L1-L3 100 % null; die Rot-Probe der Auswertung schlägt an. Folgerung: Ohne die mittleren FFN-Zweige verliert das 128x4-Modell bei LR 0,003 rund 0,02 nats und bei LR 0,001 rund 0,03, während die LR-Senkung allein 0,21 bringt. Die hohe konstante LR erklärt also, dass die Gains sterben (e510), aber nicht, dass die Zweige wenig tragen. Deutung, nicht gemessen: Kapazität, die bei diesem Text und dieser Größe nicht gebraucht wird. Prüfen ließe sich das nur mit größerem oder schwererem Text. Weitere LR-Varianten an den Zweigen lohnen nicht. Reichweite: 128x4, int8, ein Text, s4-s7, Fortsetzung ab t50000.
  Datei: rechner-b ~/snai_pruef/clip_lns/ERGEBNIS_ee_ffn_abkuehlen.md (md5 5299ea7d)
Chronik:
  2026-11-04 05:36 angelegt
  2026-11-04 05:36 Rezept r567
  2026-11-04 05:36 Status geplant -> laeuft (Rezept r567)
  2026-11-04 06:42 Messwerte m8576-m8591
  2026-11-04 06:42 Ergebnis e511: teilweise
  2026-11-04 06:42 Status laeuft -> ausgewertet (Ergebnis e511)
```
