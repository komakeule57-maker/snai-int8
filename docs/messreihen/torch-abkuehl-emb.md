# snai/torch-abkuehl-emb

```text
snai/torch-abkuehl-emb - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-03 03:55
Frage: Entsteht der Embedding-Überschuss bei kleiner LR (E² s8 rund 1,6 über Rekursion, snai/embedding-nachlaufen) auch in float32, oder hängt er an der 8-Bit-Speicherung? Dazu: Wie steht die Gradientennorm dort?
Kriterium (festgelegt 2026-11-02 20:11, vor dem ersten Messwert):
  Start c128sr s7 (md5 9c16ff73) dequantisiert als V5, Torch-Nachbau gebunden, LR 1e-4, WD 0,1 auf w_alt, Clip 1, ein voller Durchgang chin/train.txt (153.241 Fenster), Fensterfolge der drei Namen c128sr, vk2, vk3 wie Abkühlreihe s8. Adam-Momente Null beim Start (V5 trägt keine), Warmup 1. Größe: Q = E²_Ende / E²_Rekursion, E = RMS emb, Rekursion E²(t+1) = (1-LR·WD)² E² + c² LR², c 0,9098, Start E² des s7-Stands. int8-Vergleich: s8 c128sr 0,02704, Q rund 1,63; a0_vk2_s8 aus dem Lauf. FLOAT FOLGT: Q <= 1,2 in 3/3 (Überschuss hängt am 8-Bit-Pfad). FLOAT WIE INT8: Q >= 1,45 in 3/3 (kein 8-Bit-Thema). Sonst OFFEN; Knapp 0,03. Zweite Lesart: Abstand Torch gegen int8-Arm gleicher Fensterfolge, E² in Prozent; c aus Float nicht geeicht, deshalb wird auch c aus TG-Einschwingen angegeben. Nebenbei: GN je 100 Schritte, Median letzte 5.000 geloggte Schritte gegen int8 (Norm in float32); Held-out mess_text 700 Fenster; tote Gains. Gemeinsam ändert sich: Rechenweg und Adam-Kaltstart (Zeitkonstante Decay 50.000 Schritte, Kaltstart nach rund 10.000 Schritten verblasst). Rot: Rekursion gegen TG bei konstanter LR, Eichung Schritt 1 gegen Engine. Kontrollen: Fehlerkanal, rc. Reichweite: ein Stand, drei Reihenfolgen, ein Abkühlschritt.
Rezepte:
  r535 [2026-11-02] rechner-b ~/snai_pruef/clip_torch/kuehl/kette.sh: nach REIHE_ENDE der 128x2-Reihe je Name kuehl/eins.sh <c128sr|vk2|vk3>: torch_k1.py train kuehl/s7_v5.snai kuehl/f_<n>.bin --koepfe 8 --lr 0.0001 --lr-konst --warmup 1 --gn-log 100 --snapshots 30000,76000. s7_v5 aus gt/export.php, Fenster fen_export_k.php.
Messwerte (Groesse | Wert | Arm | Start | n):
  m7839 Nachtrag vor dem Lauf, Einwände Evo | int8-Vergleich je Name: c128sr Original s8, vk2 a0_vk2_s8, vk3 a0_vk3_s8 (kommt aus v-klebt-lauf), alle warm, alle voller Durchgang; beide Arme gleich lesen, zusätzlich E² bei 30.000 und 76.000 Schritten wo int8-Stand da ist. Kaltstart bleibt, freier Parameter, Überschlag rund 1 % von E²(s7). Band: FOLGT <= 1,2, WIE INT8 >= 1,45, Mitte 1,31; Rauschen über drei Namen wird angegeben. Startwert E aus s7_v5 wird abgelesen. Decay-Form LR·WD·w_alt wie Engine (Patch), Clip Schwelle 1 geeicht an Schritt 1.
  Quelle: rechner-b ~/snai_pruef/clip_torch/kuehl/*/{snap_t30000,snap_t76000,ende}.snai, train.log; rechner-a ~/snai_pruef/vklebt/log/*.log; gradnorm/log/bilanz.jsonl
  m8014 E² Start s7_v5 (abgelesen) | 0,0011458, E 0,03385
  m8015 E² Rekursion c 0,9098 bei t 30000 / 76000 / 153241 | 0,0008155 / 0,0005739 / 0,0004480
  m8016 E² Ende | 0,000768 | c128sr
  m8017 E² Ende | 0,000767 | vk2
  m8018 E² Ende | 0,000764 | vk3
  m8019 Q t30000 / t76000 / Ende, c 0,9098 | 1,206 / 1,500 / 1,715 | c128sr
  m8020 Q t30000 / t76000 / Ende, c 0,9098 | 1,192 / 1,493 / 1,712 | vk2
  m8021 Q t30000 / t76000 / Ende, c 0,9098 | 1,186 / 1,483 / 1,704 | vk3
  m8022 c aus TG geeicht (Genesis E 0,0511 auf TG Ende E 0,1168, 8 Saaten, LR-Plan wie Lauf) | 0,9559
  m8023 Q Ende mit c 0,9559 | 1,570 / 1,568 / 1,562 | c128sr/vk2/vk3
  m8024 Rot Rekursion gegen TG mit c 0,9098 | vorhergesagt E 0,1112, gemessen 0,1168 (-4,8 %)
  m8025 int8 s8 c128sr E (bilanz.jsonl) | 0,027044, E² 0,000731; Float c128sr E² 0,000768 = +5,0 %
  m8026 GN Median Float, letzte 50 Logpunkte (alle 100 Schritte, t 148300-153200) | 8,521 / 8,640 / 8,727 | c128sr/vk2/vk3
  m8027 GN Median int8 s8, letzte 5000 Schritte | 8,558 a1_c128sr / 8,593 a0_vk2 / 8,583 a1_vk2
Ergebnis e482 [2026-11-03 03:55]: erfuellt
  Fazit: Nach Wortlaut FLOAT WIE INT8: Q 1,70-1,72 in 3/3, mit dem an TG geeichten c 1,56-1,57, beide über 1,45. Float liegt sogar 5 % über dem int8-Stand gleicher Reihenfolge, und die Gradientennorm ist gleich (8,5-8,7 gegen 8,56-8,59). Der Embedding-Überschuss bei kleiner LR ist also kein 8-Bit-Defekt, sondern eine Eigenschaft des Rezepts (gebunden, Adam, Decay 0,1). Damit ist nach den toten Gains (snai/torch-k1-gains) auch das zweite Rätsel aus dem 8-Bit-Pfad herausgenommen; eine Reparatur in der int8-Speicherung gibt es dafür nicht. Hinweis zum Kriterium: Dort steht 0,02704 als E², das ist E (RMS), E² ist 0,000731; am Urteil ändert das nichts, weil Q aus Float allein gerechnet ist.
  Offen: Ein Stand, eine Saat, drei Reihenfolgen. Adam-Kaltstart als freier Parameter (Überschlag 1 %). Held-out und tote Gains der drei Endstände nicht gemessen; int8-Vergleich nur c128sr direkt, vk2/vk3 nicht gelesen. Warum E bei kleiner LR über dem Gleichgewicht liegt, bleibt offen (Zug nach außen nicht isoliert). GN-Stichprobe Float alle 100 Schritte, int8 jeder Schritt.
Chronik:
  2026-11-02 20:11 angelegt
  2026-11-02 20:11 Rezept r535
  2026-11-02 20:11 Status geplant -> laeuft (Rezept r535)
  2026-11-02 20:12 Messwerte m7839
  2026-11-03 03:55 Messwerte m8014-m8027
  2026-11-03 03:55 Ergebnis e482: erfuellt
  2026-11-03 03:55 Status laeuft -> ausgewertet (Ergebnis e482)
```
