# snai/ratsche-k64

```text
snai/ratsche-k64 - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 21:18
Frage: Aendert die alte Rundung der 8-Bit-Momente gegenueber dem heutigen Stand beim Knirps 64x4 das Kippen der FFN-Gains, die Held-out-Qualitaet und den Beitrag der Mittelschichten?
Kriterium (festgelegt 2026-11-02 14:58, vor dem ersten Messwert):
  rechner-d:~/snai_pruef/k64rat/kriterien.txt, mit Pruefer, vor dem ersten Lauf. Arme alt (SNAI_I8_MOM_SR=0) gegen neu (Vorgabe), gepaart, Saaten 4-11, 64x4, LR 0,003, 9.002 Schritte. A Gains L2 Ende, E = alt - neu: SCHUETZT alt<neu in >=6/8 und mittleres E<=-20; VERHINDERT zusaetzlich alt<5 % in >=6/8; KEINE WIRKUNG |E|<10; sonst OFFEN; knapp 2 Punkte; neu im Mittel <10 % = KIPPT IN 64x4 NICHT. B Held-out Q = alt/neu: HILFT <=0,93 in >=6/8, SCHADET >=1,07 in >=6/8, sonst Gleichstand; knapp 0,91-0,95 und 1,05-1,09 mit heldout2 und Bootstrap. C Beitrag D12 nach Nullsetzen w_down Schicht 1+2 am Ende, nur Saaten mit D0>=0,05, mindestens 6: TRAEGT D12>=0,05 in >=6; OHNE BEITRAG <=0,02 in >=6; sonst OFFEN; knapp 0,005; Armvergleich Differenz >=0,05 in >=6/8.
Plan: rechner-d:~/snai_pruef/k64rat/kriterien.txt
Baut auf: snai/gains-v, snai/gains-ursache-folge, snai/merkmal-gains
Darauf baut: snai/ratsche-k64-hybrid, snai/adam-schatten, snai/genesis-ffn
Rezepte:
  r515 [2026-11-02] cd ~/snai_pruef/k64rat && setsid -f nohup ./reihe_k.sh > log/reihe_k.out 2>&1 < /dev/null
      quelltext: fdfbf24 cortex.nim cae946bf + werkzeug/patch_skalar.py = 00743669, libcortex.so 869d70f3; reihe_k.sh, lauf_k.sh, mess_k.sh, mess_text.php, nullsetzen.php, gains_leb.php
      parameter: 64x4, 4 Koepfe, FFN 256, ctx 128, voll int8, gebunden, LR 0,003, Warmup 500, WD 0,1, kurz9000 8d232de6, CPU, OMP 1, nice 5; Revival und Waechter aus; Stellrad SNAI_I8_MOM_SR=0 gegen leer
      seed: Saaten 4-11, Genesis init_base.php out 0 64 128 4 256 s, gleicher Laufname je Paar
      rechner: rechner-d, N4020, 2 Kerne, je Saat beide Arme parallel
      logs: rechner-d:~/snai_pruef/k64rat/log/reihe.log, laeufe/reihe/
      notiz: Kontrollen vor dem Start: K1 Wiederholung neu s4 bytegleich 819ddc25; K3 Rot 3,2252 -> 7,7203; K4 gains_leb liest K1 s4 L2 tot 79,7 = Messbuch m7489.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-d:~/snai_pruef/k64rat/laeufe/reihe/*/mess.jsonl, null.jsonl
  m7882 FFN L2 tot % Mittel 8 Saaten | 1,8 | alt
  m7883 FFN L2 tot % Mittel 8 Saaten | 33,8 | neu
  m7884 mittleres E alt-neu | -32,0 | alt-neu | 4-11
  m7885 alt<neu | 8/8 | alt-neu | 4-11
  m7886 alt<5 % ohne Knapp-Bereich | 5/8 | alt | 4-11
  m7887 Held-out Mittel | 2,6758 | alt | 4-11 | 700
  m7888 Held-out Mittel | 2,6877 | neu | 4-11 | 700
  m7889 Q alt/neu min-max | 0,990-1,004 | alt-neu | 4-11
  m7890 D12 >=0,05 | 3/8 | alt
  m7891 D12 >=0,05 | 3/8 | neu
  m7892 D12 <=0,02 ohne Knapp | 4/8 | neu
  m7893 D12 alt-neu >=0,05 | 1/8 | alt-neu
  m7894 FFN L3 tot % s8/s9/s10 | 100/3,1/4,7 | alt
  m7895 FFN L3 tot % s8/s9/s10 | 75/20,3/14,1 | neu
  m7896 Rot Messung sabotage 1 | 8,249 | neu | 4
Ergebnis e474 [2026-11-02 21:18]: teilweise
  Fazit: A SCHUETZT, VERHINDERT nach Wortlaut nicht (5/8, dreimal 4,7 knapp); B Gleichstand; C alt OFFEN, neu OFFEN, kein Unterschied. Der Knirps 64x4 kippt wie 128x4 und taugt als Pruefstand. Die alte Ratsche schuetzt Schicht 2, aendert Guete und Beitrag in 9.002 Schritten nicht. Ausserhalb des Kriteriums: In s8-s10 trifft es L3, auch mit alter Ratsche in s8 ganz. Folgereihen muessen je Schicht urteilen, das L2-Mass unterschaetzt das Sterben.
  Offen: Warum. Guete nach laengerem Lauf. Rot K3, K4 erst nach den Laeufen. Wanderung der toten Schicht nur beobachtet, 8 Saaten, nachtraeglich.
  Datei: rechner-d:~/snai_pruef/k64rat/ERGEBNIS_ratsche_k64.md
Chronik:
  2026-11-02 14:58 angelegt
  2026-11-02 14:58 Rezept r515
  2026-11-02 14:58 Status geplant -> laeuft (Rezept r515)
  2026-11-02 21:18 Messwerte m7882-m7896
  2026-11-02 21:18 Ergebnis e474: teilweise
  2026-11-02 21:18 Status laeuft -> ausgewertet (Ergebnis e474)
```
