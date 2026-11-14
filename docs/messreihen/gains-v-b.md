# snai/gains-v-b

```text
snai/gains-v-b - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-03 00:19
Frage: Stufe B von snai/gains-v: Schuetzt die alte v-Ratsche auch dann vor dem Sterben der FFN-Gains, wenn sie nur auf den 8-Bit-Momenten von w_up und w_down sitzt?
Kriterium (festgelegt 2026-11-02 13:39, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/clip/kriterien_gv.txt, Nachtrag Stufe B, vor dem ersten Lauf, mit Pruefer. Anteil L2.rms_ffn |g|<0,05 am Endstand, E = B - K1 je Saat, 8 Saaten 4-11, 128x4, 9.002 Schritte, LR 0,003. SCHUETZT: B<K1 in >=6/8 UND mittleres E<=-20. VERHINDERT zusaetzlich: B<5 % in >=6/8. HEBT: B>K1 in >=6/8 und E>=20. KEINE WIRKUNG: |E|<10. Sonst OFFEN. Knapp 2 Punkte. Bitgleichheit ohne Schalter unter Parallelbetrieb am Anfang und Ende Pflicht (s4 ee903784, s11 582cb413).
Plan: rechner-b:~/snai_pruef/clip/kriterien_gv.txt
Baut auf: snai/gains-v
Darauf baut: snai/ratsche-k64-hybrid, snai/ratsche-k64-hybrid-lang, snai/gains-nf-ratsche-b, snai/bremse-wdown, snai/v-ueberhang
Rezepte:
  r512 [2026-11-02] rechner-b: cd ~/snai_pruef/clip && setsid -f nohup ./reihe_gb.sh (SNAI_RATSCHE_FFN=1, CLIP_GPU=1, CLIP_LR=0.003, lauf_gv.sh, kurz9000)
      quelltext: bau_gb libcortex.so 233aaa15, werkzeug/patch_gb.py d17c9b2e auf bau_gv b50b8edc
      seed: 4-11
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/clip/log/reihe_gb.log, laeufe/reihe_gb/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/clip/log/auswertung_gb.txt, log/schritt.jsonl
  m7639 K0 md5 s4, s11 | ee903784, 582cb413 gleich Soll | K0 | 4,11
  m7640 L2 tot Ende je Saat s4-s11 | 0 0 0 0 10,9 14,8 0,8 15,6 | B | 4-11 | 8
  m7641 L2 tot Ende Mittel | 5,3 | B | 4-11 | 8
  m7642 E = B-K1 Mittel, Bootstrap, B<K1 | -47,19; -62,5 bis -29,9; 8/8 | B | 4-11 | 8
  m7643 L2 unter 5 % | 5/8 | B | 4-11 | 8
  m7644 Held-out Mittel | 2,6813 (K1 2,6842, R 2,6640) | B | 4-11 | 8
  m7645 Held-out B-K1 Mittel, besser | -0,0029; 3/8 | B | 4-11 | 8
  m7646 Held-out B-R Mittel, R besser | 0,0173; 8/8 | B | 4-11 | 8
  m7647 GN Median letzte 1.000 | 1,021 (K1 1,016, R 1,100) | B | 4-11 | 8
  m7648 RMS ffn | 0,0973 (K1 0,1095, R 0,1001) | B | 4-11 | 8
  m7649 Schritt s = Betrag m durch Wurzel v, w_down L2 t1000, t3000 | 0,035; 0,050 (K1 0,046; 0,074, R 0,034; 0,050) | B | 4-11 | 8
  m7650 s w_down L2 kleiner als K1 t1000, t3000 | 8/8; 5/8 | B | 4-11 | 8
  m7651 Spearman s w_down L2 t3000 gegen L2 tot Ende, nachtraeglich | -0,83 K1; +0,18 B; +0,68 R | K1,B,R | 4-11 | 8
  Quelle: Nachträglich, Beobachtung ohne Kriterium, Anfrage snai_multi_stack: Anteil L0.rms_att mit Betrag der Gain unter 0,05 am Endstand 9.002, Saaten 4 bis 11, rechner-b laeufe/reihe_dc, reihe_gb, reihe_gv
  m7762 L0 att tot % je Saat | 46,1/38,3/28,1/34,4/30,5/33,6/35,9/37,5 | K1
  m7763 L0 att tot % je Saat | 35,2/24,2/36,7/28,9/34,4/28,9/35,2/51,6 | B
  m7764 L0 att tot % je Saat | 14,8/10,9/25,8/18,0/15,6/15,6/25,0/23,4 | R
  m7765 L0 att tot % Mittel | 35,6 | K1
  m7766 L0 att tot % Mittel | 34,4 | B
  m7767 L0 att tot % Mittel | 18,6 | R
  Quelle: Nachträglich, Beobachtung ohne Kriterium, Anfrage snai_int8_lora: K1, 128x4, Saaten 4 bis 11, reihe_dc, Snapshots und Endstand, RMS aus der Datei
  m7935 L2 w_up RMS t1000 | 0,0223/0,0269/0,0275/0,0229/0,0212/0,0201/0,0208/0,0191 | K1
  m7936 L2 w_up RMS t3000 | 0,0342/0,0651/0,0519/0,0401/0,0356/0,0324/0,0360/0,0264 | K1
  m7937 L2 FFN-Gain RMS t3000 | 0,551/0,778/0,684/0,600/0,602/0,541/0,622/0,543 | K1
  m7938 Spearman gegen L2 tot Ende, w_up t1000 | -0,74 | K1 |  | 8
  m7939 Spearman gegen L2 tot Ende, w_up t3000 | -0,86 | K1 |  | 8
  m7940 Spearman gegen L2 tot Ende, Gain t1000 | -0,48 | K1 |  | 8
  m7941 Spearman gegen L2 tot Ende, Gain t3000 | -0,64 | K1 |  | 8
Ergebnis e458 [2026-11-02 17:18]: erfuellt
  Fazit: SCHUETZT nach Wortlaut, VERHINDERT nicht (5/8). Die alte Rundung von v allein auf w_up und w_down reicht fast so weit wie die volle Ratsche: Der Schalter fuer das Kippen sitzt in den Adam-Momenten der FFN-Gewichte. Die Gains leben, der Held-out bleibt Gleichstand mit K1; der kleine Vorteil von R haengt also nicht an den lebenden L2-Gains. Als Mittel gegen Qualitaetsverlust taugt B in diesem Budget nicht. Die einfache Bremse-Deutung ist nicht bestaetigt: w_down im Mittel gebremst, w_up kaum, L3 am staerksten und kippt trotzdem nicht; innerhalb K1 kippen Saaten mit kleinem s an t3000 mehr. Naechster sinnvoller Eingriff: w_down allein, und kleinere LR nur auf w_down, nur mit Freigabe.
  Offen: Warum L2; Langzeitfolge von B, insbesondere ob der Embedding-Kollaps der vollen Ratsche ausbleibt (snai/merkmal-sr); Bremse nicht isoliert; prod512b nicht gemessen.
  Datei: rechner-b:~/snai_pruef/clip/ERGEBNIS_gains_v_b.md
Chronik:
  2026-11-02 13:39 angelegt
  2026-11-02 13:39 Rezept r512
  2026-11-02 13:39 Status geplant -> laeuft (Rezept r512)
  2026-11-02 17:18 Ergebnis e458: erfuellt
  2026-11-02 17:18 Status laeuft -> ausgewertet (Ergebnis e458)
  2026-11-02 17:19 Messwerte m7639-m7651
  2026-11-02 18:27 Messwerte m7762-m7767
  2026-11-03 00:19 Messwerte m7935-m7941
```
