# snai/torch-wup-mechanismus

```text
snai/torch-wup-mechanismus - ausgewertet, angelegt 2026-11-03, zuletzt 2026-11-03 02:27
Frage: Einwände Evo: Liegt das Sterben an der Nichtlinearität des kleinen SiLU-Arguments oder an einer Adam-Startphase, in der Schicht 2 verhungert (u = m/sqrt(v) lange klein)?
Kriterium (festgelegt 2026-11-03 00:19, vor dem ersten Messwert):
  Torch-Nachbau, K1-Rezept float32, Saaten 4, 5, 6, 7, gepaart zu TG, TU, TPU. Arme: LG wie TG, aber Aktivierung linear x/2 (Steigung wie SiLU bei 0); LU wie TPU, linear x/2; B2 wie TG, Adam beta2 0,99 statt 0,999. Sonde: SG, SU, SPU wie TG, TU, TPU bis Schritt 3000, je Schicht und w_up, w_down, rms_ffn alle 100 Schritte RMS g, RMS u, RMS p. Haupt: L2 ffn tot am Ende, Schwelle 0,05. F1: LU lebt (<= 0,5 x TG im Mittel und < TG in >= 3/4) heisst: Nichtlinearität ist für die Schutzwirkung von w_up nicht nötig, die Deutung 'SiLU fast linear, Zweig redundant' ist dann widerlegt. Lebt LU nicht, aber TPU: Nichtlinearität nötig. LG gegen TG wird berichtet, |Mittel D| < 15 Punkte zählt als wie TG. F2: B2 lebt (gleiche Regel): Adam-Startphase gestützt, nicht isoliert, weil beta2 auch sonst alles ändert; KEIN HEBEL bei |Mittel D| < 15 Punkte; sonst OFFEN. F3 Beobachtung ohne Urteil: u und p L2 gegen L0 an t1000 und t3000, TG gegen TU und TPU; Evos Zahlen K1: w_up L2 0,019-0,028 gegen L0 0,075. Linear-Arme: kein Held-out mit mess_text, weil der Engine-Vorwärtspfad SiLU rechnet; berichtet wird Trainingsverlust letzte 2.000 Schritte und tote Gains. B2: Held-out mess_text. Vier Saaten bei starkem Chaos im Einzelwert (TK): Beobachtungsstärke, Hinweis statt Beweis; Reichweite wie snai/torch-k1-gains.
Darauf baut: snai/neuronen-zensus
Rezepte:
  r540 [2026-11-03] rechner-b ~/snai_pruef/clip_torch/kette7.sh: xargs -P 2 ./eins7.sh < liste7.txt. Schalter torch_k1.py --linear (x/2), --beta2 0.99, --sonde 100 (sonde.jsonl: RMS g, RMS u, RMS p je Schicht für wup, wdown, rms_ffn). SG, SU, SPU --max-fenster 3000.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b ~/snai_pruef/clip_torch laeufe/*/ende.snai (Schwelle 0,05), train.log, log/mess.jsonl, sonde.jsonl
  m7963 FFN tot L0-L3 Mittel, Saaten 4-7 | 0,0 1,4 74,4 1,0 | TG
  m7964 L2 tot je Saat s4-s7 | 88 32 81 96 | TG
  m7965 FFN tot L0-L3 Mittel | 0,0 0,4 0,0 0,0 | TPU
  m7966 FFN tot L0-L3 Mittel | 4,1 87,5 83,8 82,8 | LG
  m7967 L2 tot je Saat s4-s7 | 96 88 97 54 | LG
  m7968 FFN tot L0-L3 Mittel | 1,6 84,2 91,2 67,8 | LU
  m7969 L2 tot je Saat s4-s7 | 91 91 91 92 | LU
  m7970 FFN tot L0-L3 Mittel | 0,0 3,3 65,0 1,8 | B2
  m7971 L2 tot je Saat s4-s7 | 38 91 32 98 | B2
  m7972 Held-out Mittel, D gegen TG s4-s7 | 2,7033; 0,035 0,0452 0,0286 0,0174, Mittel +0,0315, besser 0/4 | B2
  m7973 RMS Embedding am Ende | 0,1599 gegen TG 0,1168 | B2
  m7974 Trainingsverlust Mittel ganzer Lauf s4-s7 | 3,16942 3,15373 3,17430 3,17005 | LG
  m7975 Trainingsverlust Mittel ganzer Lauf s4-s7 | 3,08216 3,07538 3,08158 3,08136 | LU
  m7976 Trainingsverlust Mittel ganzer Lauf s4-s7 | 2,93744 2,94311 2,92934 2,94251 | TPU
  m7977 Trainingsverlust Mittel ganzer Lauf s4, s5 (train.log s6, s7 überschrieben) | 2,97763 2,97997 | TG
  m7978 u w_up L0-L3 an t1000 Mittel | 0,2406 0,1053 0,0960 0,1477 | SG
  m7979 u w_up L0-L3 an t1000 Mittel | 0,1905 0,1381 0,1294 0,2349 | SU
  m7980 u w_up L0-L3 an t1000 Mittel | 0,2380 0,1311 0,1554 0,1767 | SPU
Ergebnis e480 [2026-11-03 02:27]: teilweise
  Fazit: Nach Wortlaut, Beobachtungsstärke (4 Saaten). F1: LU lebt nicht (L2 91,2 gegen TG 74,4), TPU lebt (0,0): Nichtlinearität nötig; die Schutzwirkung von großem w_up hängt an SiLU. LG in L2 'wie TG' (D +9,4 Punkte, unter 15), aber Befund über das Kriterium hinaus: linear sterben L1 und L3 ebenfalls massenhaft (LG 87,5/82,8 %, LU 84,2/67,8 %), nur L0 bleibt. F2: B2 KEIN HEBEL (D -9,4 Punkte, unter 15, kleiner in 2/4). Deutung, nicht gemessen: Ein FFN-Zweig ohne wirksame Nichtlinearität ist neben den Residualpfaden redundant und wird abgebaut; das spricht für 'Zweig überflüssig' statt 'Zweig verhungert'. Ein Eingriff, der diese Deutung isoliert, fehlt. Folge: Die Frage verschiebt sich von Adam-Mechanik zu der, was der Zweig funktional beiträgt.
  Offen: Abweichung vom Kriterium: Trainingsverlust der letzten 2.000 Schritte nicht vorhanden, train.log führt nur das Laufmittel; TG nur s4, s5 lesbar. Linear-Arme ohne Held-out. Warum in TG gerade L2 stirbt und L1, L3 leben, ist nicht erklärt. F3 steht als Beobachtung bei snai/v-ueberhang.
Chronik:
  2026-11-03 00:19 angelegt
  2026-11-03 00:20 Rezept r540
  2026-11-03 00:20 Status geplant -> laeuft (Rezept r540)
  2026-11-03 02:27 Messwerte m7963-m7980
  2026-11-03 02:27 Ergebnis e480: teilweise
  2026-11-03 02:27 Status laeuft -> ausgewertet (Ergebnis e480)
```
