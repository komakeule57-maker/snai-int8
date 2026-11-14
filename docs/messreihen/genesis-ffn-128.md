# snai/genesis-ffn-128

```text
snai/genesis-ffn-128 - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-03 06:45
!! ohne Rezept
Frage: Hilft eine groessere FFN-Startgroesse (w_up, w_down) beim K1-Rezept 128x4 der Modellguete, und arbeiten die FFN der Mittelschichten dann messbar mit?
Kriterium (festgelegt 2026-11-02 19:54, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/gs/kriterien_128.txt. Der Held-out entscheidet. Arme plus (w_up x4,42, w_down x2,21), minus (Kehrwerte), gepaart gegen reihe_dc K1, Saaten 4-11. Held-out-Verhaeltnis Arm/K1: <=0,93 HILFT, >=1,07 SCHADET, sonst GLEICHSTAND, einheitlich in mind. 7/8, sonst saatabhaengig. VERBESSERUNG nur bei HILFT. Zweitmass Nullsetz-Kosten w_down L1, L2, L3 einzeln und gemeinsam: FFN TRAEGT bei plus >= 2 x K1 und >= 0,05 nats in mind. 7/8 (gemeinsam). Drittmass tote Gains L2: HEBEL <= 0,5 x K1 in mind. 7/8. Lebende Gains ohne HILFT sind keine Verbesserung.
Plan: rechner-b:~/snai_pruef/gs/kriterien_128.txt
Baut auf: snai/genesis-ffn, snai/dauerclip-saaten
Darauf baut: snai/neuronen-zensus
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/gs/mess128.jsonl, log128.txt; Rot von Hand
  m8131 Held-out plus/K1 s4-s11 | 0,987 0,985 0,993 0,980 0,988 0,978 1,001 0,993 | plus
  m8132 D plus-K1 nats s4-s11 | -0,035 -0,041 -0,020 -0,055 -0,033 -0,060 +0,003 -0,020; Mittel -0,032 | plus
  m8133 Held-out minus/K1 Spanne | 0,992-1,019; Mittel D +0,019 | minus
  m8134 C(L1+L2+L3) plus/K1 Faktor | 1,29-2,41, >=2 in 1/8 | plus
  m8135 C(L1+L2+L3) K1 s4-s11 | 0,256 0,233 0,174 0,230 0,120 0,221 0,205 0,188 | K1
  m8136 C(L1+L2+L3) plus s4-s11 | 0,402 0,348 0,293 0,323 0,289 0,285 0,370 0,263 | plus
  m8137 tote FFN-Gains L2 s4-s11 | 0 1,6 0 0 0 0 0,8 0,8 % | plus
  m8138 tote FFN-Gains L2 s4-s11 | 79,7 0,8 22,7 49,2 61,7 59,4 60,2 85,9 % | K1
  m8139 tote FFN-Gains L2 Spanne | 21,9-95,3 % | minus
  m8140 tote Attention-Gains L0 Spanne | 35,9-69,5 % (K1 28,1-46,1) | plus
  m8141 Rot gemischt | 8,2571 | plus | 4
  m8142 Kontrolle kon s4 md5 | ee903784 = K1 | kon | 4
Ergebnis e488 [2026-11-03 06:45]: teilweise
  Fazit: Nach dem eigenen Kriterium (Verhältnisregel ≤0,93): Held-out GLEICHSTAND 8/8 (plus/K1 0,978-1,001). Zweite Lesart ohne Urteilskraft, nicht vereinbart: Nach der Armregel der Torch-Reihen (Mittel ≤ -0,02, ≥6/8) wäre plus BESSER (Mittel D -0,032, kleiner 7/8, rund 1,2 %); zitieren nur mit Regel. HEBEL erfüllt (tote L2-Gains 0-1,6 % gegen 0,8-85,9 %), FFN TRAEGT nicht (Faktor ≥2 nur 1/8). Folge: Ein größerer FFN-Start rettet die Gains und bringt gut 1 %, macht die Mitte aber nicht tragend; kein Rezept gegen die nutzlose Mitte. Engine-Arm "nur w_up" war an "plus trägt" gebunden und entfällt. Stärkerer Kandidat: Embedding-Faktor am Eingang (snai/torch-emb-eingang).
  Offen: Warum unter plus mehr Attention-Gains in L0 sterben (36-70 % gegen 28-46 %). Ob plus bei mehr Budget oder schwererem Text trägt.
  Datei: rechner-b:~/snai_pruef/gs/ERGEBNIS_genesis_ffn_128.md
Abgeloest und ausgeblendet: 1 ergebnis - voll=True zeigt sie.
Chronik:
  2026-11-02 19:54 angelegt
  2026-11-03 06:44 Messwerte m8131-m8142
  2026-11-03 06:44 Status geplant -> laeuft (Messwerte m8131-m8142)
  2026-11-03 06:44 Ergebnis e487: teilweise
  2026-11-03 06:44 Status laeuft -> ausgewertet (Ergebnis e487)
  2026-11-03 06:45 Ergebnis e488: teilweise, loest e487 ab
```
