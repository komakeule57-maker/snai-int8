# snai/torch-genesis-128

```text
snai/torch-genesis-128 - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-03 00:43
Frage: Hängt das Sterben der FFN-Gains in float32 128x4 an der Startgröße von w_up oder w_down, und nutzt das dem Held-out sowie dem Beitrag der FFN-Zweige?
Kriterium (festgelegt 2026-11-02 20:07, vor dem ersten Messwert):
  Nachbau wie snai/torch-k1-gains, gepaart zu TG (gleiche Fenster, gleiche Zufallszahlen, nur skaliert), Saaten 4-11. Arme: TP w_up x4,42 und w_down x2,21 (Einträge ±1/sqrt(d) und (1/sqrt(F))/sqrt(2L) statt 0,02); TPU nur w_up x4,42; TPD nur w_down x2,21; TK Empfindlichkeit w_up und w_down x1,05 in 4 Saaten (s4-s7). Haupt: L2 ffn tot am Ende, D = Arm - TG. HEBEL: Arm <= 0,5 x TG im Mittel UND Arm < TG in >= 6/8. KEIN HEBEL: |Mittel D| < 10 Punkte. Sonst OFFEN. Ursache nur, wenn TP HEBEL und der Abstand mehr als das Doppelte der mittleren Betragsänderung von TK ist. Held-out: gepaart; BESSER Arm besser in >= 6/8 UND Mittel <= -0,02, SCHLECHTER umgekehrt, GLEICH |Mittel| < 0,01 UND |D| < 0,02 in >= 6/8; Größe außerdem nach 10-%-Hausregel einordnen. Beitrag: Nullen w_down L2 und L1+L2+L3, Kosten gegen TG. NÜTZT nur, wenn Gains leben UND L1+L2+L3-Kosten >= 2 x TG in >= 6/8, sonst gilt 'lebend, aber ohne Nutzen'. Kontrollen: skaliere.php meldet Mittel, Fehlerkanal, rc. Gemeinsam ändert sich: Skala des Starts; Adam-Rezept gleich. Reichweite: float32, ein Rezept, ein Text, 9.002 Schritte. Übertrag auf int8 prüft eine eigene Engine-Reihe (snai/genesis-ffn-128). Freier Parameter: Faktoren aus der Standard-Linear-Regel.
Rezepte:
  r533 [2026-11-02] rechner-b ~/snai_pruef/clip_torch/kette2.sh: nach REIHE_ENDE der 128x2-Reihe xargs -P 3 ./eins.sh < liste2.txt. Genesis per clip_lns/werkzeug/skaliere.php clip_gen_{tp,tpu,tpd,tk}_s<s> (Faktoren w_up 4,4194, w_down 2,2097, tk 1,05). Rest wie r532, Log log/gen.log, log/lauf.log, log/mess.jsonl.
Messwerte (Groesse | Wert | Arm | Start | n):
  m7945 TP ffn tot L0-L3, Held-out, D gegen TG Mittel | 0,0 0,1 0,3 0,1; 2,6445; -0,0294, 8/8 besser
  m7946 TPU ffn tot L0-L3, Held-out, D Mittel | 0,0 0,2 0,2 0,2; 2,6444; -0,0295, 8/8 besser, | D | <0,02 in 1/8
  m7947 TPD ffn tot L0-L3, Held-out, D Mittel | 0,0 3,6 49,6 0,7; 2,6814; +0,0075, 2/8 besser
  m7948 TPD L2 je Saat s4 bis s11 | 35 98 21 91 77 66 1 8
  m7949 TK L2 je Saat s4 bis s7 gegen TG | 45 35 2 77 gegen 88 32 81 96; mittlere Betragsänderung 36 Punkte
  m7950 TK Held-out D s4 bis s7 | 0,0228 0,0077 0,0158 0,0018, Mittel +0,0120
  m7951 Kosten Nullen L1+L2+L3 TG / TP / TPU / TPD | 0,2320 / 0,3215 / 0,2961 / 0,2440
  m7952 Kosten Nullen L2 TG / TP / TPU / TPD | 0,0012 / 0,0317 / 0,0276 / 0,0075
  m7953 L0 att tot TG / TP / TPU | 30,2 / 43,2 / 49,8
  m7954 E Mittel TG / TP / TPU | 0,1168 / 0,1164 / 0,1164
  m7955 g_final Mittel TG / TP | 0,8694 / 0,8636
Ergebnis e478 [2026-11-03 00:43]: teilweise
  Fazit: Nach Wortlaut: TP HEBEL (0,3 gegen 67,2 %, 8/8), TPU HEBEL (0,2 %, 8/8), TPD OFFEN (49,6 %, D -17,6 Punkte). Held-out TP und TPU BESSER (8/8, je -0,029, 1,1 %, in der Größe Gleichstand), TPD OFFEN. NÜTZT nicht erfüllt: L1-3-Kosten 1,4 x statt 2 x TG, also lebend, aber nicht doppelt tragend; die Gains leben, Held-out steigt nur wenig. Ursachen-Klausel knapp nicht erfüllt: |D| 66,9 gegen 2 x TK 72 (TK mittel 36 Punkte, 4 Saaten). Trotz Chaos im Einzelwert ist der kategoriale Abstand 0,2 % in 8/8 eindeutig; die Klausel ist nach Wortlaut trotzdem nicht erfüllt, also Hebel, nicht Ursache. w_up allein trägt alles, w_down nicht. Reichweite: float32, 128x4, K1-Rezept, 9.002 Schritte. Attention L0 stirbt unter TP/TPU eher mehr (43-50 gegen 30 %), das ist ungeklärt. Engine: snai/genesis-ffn-128 läuft.
Chronik:
  2026-11-02 20:07 angelegt
  2026-11-02 20:07 Rezept r533
  2026-11-02 20:07 Status geplant -> laeuft (Rezept r533)
  2026-11-03 00:43 Messwerte m7945-m7955
  2026-11-03 00:43 Ergebnis e478: teilweise
  2026-11-03 00:43 Status laeuft -> ausgewertet (Ergebnis e478)
```
