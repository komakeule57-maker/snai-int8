# snai/ratsche-k64-hybrid

```text
snai/ratsche-k64-hybrid - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-03 00:07
Frage: Schuetzt die Ratsche nur auf dem v der FFN-Gewichte (SR sonst) beim Knirps 64x4 die Gains, ohne den Held-out zu verschlechtern, und aendert sie den Beitrag der Mittelschichten?
Kriterium (festgelegt 2026-11-02 15:43, vor dem ersten Messwert):
  rechner-d:~/snai_pruef/k64rat/kriterien.txt, Nachtrag Arm hyb, mit Pruefer, vor dem ersten Lauf. Gepaart gegen neu aus snai/ratsche-k64, Saaten 4-11, gleiches Rezept. A Gains L2 Ende, E = hyb - neu: SCHUETZT hyb<neu in >=6/8 und mittleres E<=-20; KEINE WIRKUNG |E|<10; sonst OFFEN; knapp 2 Punkte; neu im Mittel <10 % = keine Schutzaussage. B Q = hyb/neu: HILFT <=0,93, SCHADET >=1,07 in >=6/8, sonst Gleichstand. C D12(hyb)-D12(neu)>=0,05 in >=6/8 = traegt mehr. Embedding-Kollaps nicht beurteilt: bestes Ergebnis ist 'im Kurzlauf nicht ausgeschlossen'. hyb gegen alt nur beschrieben. Kontrolle: voller Lauf ohne Schalter s4 bytegleich neu s4.
Plan: rechner-d:~/snai_pruef/k64rat/kriterien.txt
Baut auf: snai/ratsche-k64, snai/gains-v-b
Darauf baut: snai/ratsche-k64-hybrid-lang
Rezepte:
  r518 [2026-11-02] cd ~/snai_pruef/k64rat && setsid -f nohup ./reihe_h.sh > log/reihe_h.nohup 2>&1 < /dev/null
      quelltext: quelle_h: cortex 0b477718 (quelle 00743669 + patch_gb.py d17c9b2e der Evo-Stufe B), libcortex af9ab20a; lauf_h.sh, reihe_h.sh, mess_k.sh
      parameter: wie snai/ratsche-k64, Stellrad SNAI_RATSCHE_FFN=1; startet nach K64_FERTIG, zwei Saaten zugleich
      seed: Saaten 4-11, Genesis und Laufname wie neu
      rechner: rechner-d
      logs: rechner-d:~/snai_pruef/k64rat/log/reihe_h.log, laeufe/reihe/hyb_s*, laeufe/kontrolle/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-d:~/snai_pruef/k64rat/laeufe/reihe/hyb_s*/mess.jsonl, null.jsonl
  m7899 FFN L2 tot % Mittel | 1,4 | hyb | 4-11
  m7900 FFN L2 tot % Mittel | 33,8 | neu | 4-11
  m7901 mittleres E hyb-neu | -32,4 | hyb-neu | 4-11
  m7902 hyb<neu | 8/8 | hyb-neu | 4-11
  m7903 hyb<5 % ohne Knapp-Bereich | 6/8 | hyb | 4-11
  m7904 Held-out Mittel | 2,6839 | hyb | 4-11 | 700
  m7905 Held-out Mittel | 2,6877 | neu | 4-11 | 700
  m7906 Q hyb/neu min-max | 0,989-1,003 | hyb-neu | 4-11
  m7907 D12 >=0,05 | 3/8 | hyb
  m7908 D12 hyb-neu >=0,05 | 2/8 | hyb-neu
  m7909 FFN L3 tot % Mittel | 1,4 | hyb | 4-11
  m7910 FFN L3 tot % Mittel | 14,5 | neu | 4-11
  m7911 FFN L3 tot % Mittel | 13,5 | alt | 4-11
  m7912 Attention L0 tot % Mittel | 32,0 | hyb | 4-11
  m7913 Attention L0 tot % Mittel | 30,7 | neu | 4-11
  m7914 Attention L0 tot % Mittel | 6,3 | alt | 4-11
  m7915 md5 ohne_s4 = neu_s4 | db35bc43 | Kontrolle | 4
Ergebnis e475 [2026-11-03 00:07]: teilweise
  Fazit: A SCHUETZT und VERHINDERT (6/8, genau an der Zahl), B Gleichstand, C OFFEN und kein Unterschied. Fuer die FFN-Gains reicht die Ratsche auf w_up und w_down, in allen Schichten, auch L3 (1,4 gegen alt 13,5, im Abstand vor allem s8). Attention L0 schuetzt der Hybrid nicht. Kein Guetegewinn in diesem Budget. Damit nicht als tauglich zu lesen: kein Kollapsurteil; das sagt erst der Langlauf.
  Offen: Embedding-Kollaps nicht gemessen. Warum. Guete auf langer Strecke. Mitwirkung anderer Gewichte in alt nicht ausgeschlossen.
  Datei: rechner-d:~/snai_pruef/k64rat/ERGEBNIS_ratsche_k64_hybrid.md
Chronik:
  2026-11-02 15:43 angelegt
  2026-11-02 15:43 Rezept r518
  2026-11-02 15:43 Status geplant -> laeuft (Rezept r518)
  2026-11-03 00:07 Messwerte m7899-m7915
  2026-11-03 00:07 Ergebnis e475: teilweise
  2026-11-03 00:07 Status laeuft -> ausgewertet (Ergebnis e475)
```
