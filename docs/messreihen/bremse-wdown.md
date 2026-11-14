# snai/bremse-wdown

```text
snai/bremse-wdown - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-03 09:32
Frage: Wirkt die Ratsche auf den FFN-Gewichten als Bremse von w_down? Arm D: Ratsche nur auf w_down. Arm E: keine Ratsche, LR von w_down x 0,75.
Kriterium (festgelegt 2026-11-02 17:28, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/clip/kriterien_bremse.txt. Anteil L2.rms_ffn |g|<0,05 am Ende, E = Arm-K1, 8 Saaten: SCHUETZT Arm<K1 in >=6/8 und mittleres E <= -20; VERHINDERT zusaetzlich <5 % in >=6/8; KEINE WIRKUNG |E|<10; sonst OFFEN; Knapp 2 Punkte. Held-out gleichrangig. K0 s4 ee903784 und s11 582cb413 auf CPU. Kein Schluss auf "woanders".
Baut auf: snai/gains-v-b
Rezepte:
  r551 [2026-11-03] rechner-b ~/snai_pruef/clip: Reihe K0 s4, D s4-s11 (SNAI_RATSCHE_FFN=2), E s4-s11 (SNAI_LR_DOWN=0.75), K0 s11 nacheinander auf CPU, Lib bau_gd 90bf27d1; Auswertung python3 werkzeug/auswerten_gd.py > log/auswertung_gd.txt; Schrittgrößen schritt.php -> log/schritt_gd.jsonl
      quelltext: patch_gd.py f0737d84, bau_gd/libcortex.so 90bf27d1, auswerten_gd.py 067f76bb
      seed: Saaten 4-11 über Laufnamen clip_s<s>, gepaart mit reihe_dc K1
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/clip/log/reihe_gd.log, laeufe/reihe_gd/*, log/auswertung_gd.txt, log/schritt_gd.jsonl, laeufe/gd_probe/*
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b ~/snai_pruef/clip/log/auswertung_gd.txt, log/schritt_gd.jsonl, log/schritt.jsonl, laeufe/gd_probe
  m8192 Kontrolle K0 s4 / s11 md5 | ee903784 / 582cb413 = K1 | K0 | 4,11 | 2
  m8193 Kontrolle Kurzprobe 1.026 Schritte md5 | K 4d739ea3, D d903f093, E 720b2bec | K,D,E | 4 | 3
  m8194 Kontrolle rc, STEPS_DONE, Fehlerkanal, Step 1 gleich K1, [GD]-Zeile | in 16/16 erfüllt | D,E | 4-11 | 16
  m8195 L2 tot E=Arm-K1 je Saat s4-s11 | -78,9 +47,6 -21,1 +31,3 -32,8 -44,6 -58,6 -23,4; Mittel -22,56; Arm<K1 6/8; Bootstrap -48,9 bis +7,2 | D | 4-11 | 8
  m8196 L2 tot am Ende je Saat s4-s11 | 0,8 48,4 1,6 80,5 28,9 14,8 1,6 62,5; <5 % in 3/8 | D | 4-11 | 8
  m8197 L2 tot E=Arm-K1 je Saat s4-s11 | -31,3 +83,6 +44,5 +31,3 +11,7 +1,5 +0,7 -48,4; Mittel +11,70; Arm<K1 2/8; Bootstrap -14,6 bis +39,4 | E | 4-11 | 8
  m8198 FFN tot L0/L1/L3 Mittel am Ende | D 0/1,6/0,6; E 0,1/1,0/1,0; K1 0/1,8/0,6 | D,E,K1 | 4-11 | 24
  m8199 Held-out Arm-K1 Mittel, besser | D +0,0008, 4/8; E -0,0218, 8/8 | D,E | 4-11 | 16
  m8200 s50 w_down L2 t1000 / t3000 (ohne LR) | K1 0,0464/0,0741; D 0,0345/0,0276; E 0,0413/0,0637 (mit Faktor 0,75 effektiv 0,67/0,64 x K1) | K1,D,E | 4-11 | 24
  m8201 1/Wurzel(v) Median L1-L3 t1000 w_down / w_up | D 4383/8328/5431 und 15286/20625/21363; K1 7138/9526/9214 und 14868/20297/21732 | D,K1 | 4-11 | 16
Ergebnis e492 [2026-11-03 09:32]: teilweise
  Fazit: D (Ratsche nur auf w_down) SCHUETZT nach Wortlaut: 6/8, Mittel -22,56, 2,56 Punkte jenseits der Schwelle. Das Ergebnis ist nicht robust (Bootstrap schließt 0 ein, in s5 und s7 mehr Tote), VERHINDERT nicht (3/8), Held-out unverändert. E (LR w_down x 0,75) ist OFFEN (+11,7, 2/8) und rettet nicht, verbessert aber den Held-out in 8/8 um 0,022 (Armregel BESSER, Hausregel Gleichstand, keine Regel vereinbart). E bremst an t1000 so stark wie D: Die mittlere Schrittgröße von w_down bis t1000 erklärt das Sterben nicht. L1 und L3 werden nicht gehoben. Folge: Die Bremse auf w_down ist als Reparatur erledigt; EE (snai/engine-emb-eingang) ist der bessere Eingriff. Der Held-out-Gewinn von E ist ein billiger Kandidat für eine eigene Prüfung mit Kriterium.
  Offen: Ob eine späte oder stärkere Bremse (nach t1000, Faktor 0,5) schützt, ist nicht geprüft und braucht eine neue Freigabe. Warum E den Held-out verbessert, ist offen; Kandidat wäre die gleichzeitig kleinere Decay-Rate von w_down (adamWd geht mit der LR). Ein Modell, ein Text, 9.002 Schritte. Eine eigene vsinkt-Ausgabe fehlt, ersatzweise schritt.php.
  Datei: rechner-b:~/snai_pruef/clip/ERGEBNIS_bremse.md
Chronik:
  2026-11-02 17:28 angelegt
  2026-11-03 09:32 Rezept r551
  2026-11-03 09:32 Status geplant -> laeuft (Rezept r551)
  2026-11-03 09:32 Messwerte m8192-m8201
  2026-11-03 09:32 Ergebnis e492: teilweise
  2026-11-03 09:32 Status laeuft -> ausgewertet (Ergebnis e492)
```
