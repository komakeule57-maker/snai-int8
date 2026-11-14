# snai/ditto-budget

```text
snai/ditto-budget - ausgewertet, angelegt 2026-10-24, zuletzt 2026-10-24 09:21
Frage: Erreicht die eigene int8-Engine das DITTO-Ziel (Selbstverstärkung der Satzwiederholung gebrochen), wenn sie statt 1 Epoche (1.568 Schritte) 6 Epochen (~9.400, Größenordnung Xu et al.) bekommt? Anlass: Wunsch 2026-10-24, DITTO separat weiter zu prüfen ("vielleicht hakt es an der Feinabstimmung mit unserer Engine"); in snai/ditto-knirps stieg die TP-Kurve des DITTO-Arms weiter (TP4/TP1 1,22-1,71), das Trainingsziel war also nicht erreicht.
Kriterium (festgelegt 2026-10-24 06:54, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/ditto2/kriterien.txt (md5 d840d0b0, mit Prüfer). Einzellauf D Saat 1, 6 Epochen als Kette (Offset je Epoche neu), sonst wie D in snai/ditto-knirps. K0: Epoche 1 md5-gleich alte D_s1 (d13cf606), sonst ungültig. Messung Epoche 2/4/6 mit mess.sh (Schleifen-Sonde, Beam, Held-out, Beleg). Regel am Stand Epoche 6: R = TP4/TP1 <= 1,0 UND TP1 <= 0,28 -> "Budget ist ein Hebel", nächste Reihe 3 Saaten D+M bei 6 Epochen; R > 1,2 -> "Budget kein Hebel in diesem Rezept", nächster Einzellauf anderes Stellrad (LR oder fp32); sonst unklar -> Saat 2. Einzellauf = Beobachtung, steuert nur die nächste Reihe.
Plan: rechner-a:~/snai_pruef/ditto2/kriterien.txt; lauf.sh (6 x ~40 min Training, Messungen im Hintergrund)
Baut auf: snai/ditto-knirps
Darauf baut: snai/ditto-reihe6
Rezepte:
  r400 [2026-10-24] cd ~/snai_pruef/ditto2 && setsid nohup bash lauf.sh > log/lauf.nohup 2>&1 & ; darin je Epoche E=1..6: env SNAI_DITTO_LAMBDA=0.5 SNAI_CORTEX_LIB=~/snai_pruef/ditto/bau/libcortex_D.so SNAI_START_OFFSET=$((3000017*(E-1))) SNAI_TRAIN_MODE=pretrain SNAI_TIE_EMBEDDINGS=1 SNAI_INT8_FULL=1 SNAI_FORCE_CPU=1 SNAI_I8_MOM_SR=mv SNAI_WARMUP_STEPS=500 SNAI_GAIN_GUARD=0 OMP_NUM_THREADS=3 php train_cluster.php ~/snai_pruef/ditto/daten/mix.txt factory/checkpoints/ft.snai 1 1 <Basis e-1> 3 0.0001 0 1 0.1; nach E=2/4/6 mess.sh (Kopie aus ditto, nur Ausgabeordner ditto2/mess)
      quelltext: lauf.sh 5d6018f4, mess.sh 2d5e4b51, kriterien.txt d840d0b0, auswert.py (Kopie aus ditto, nur B geändert); libcortex_D.so e4bb3a0f; proj = Kopie ditto/proj_s1
      parameter: Basis drohneP_s19 (170d4d3f); mix.txt 793f6cbd; lambda 0,5; LR 0,0001 konstant (Warmup inaktiv beim Weitertraining); WD 0,1; 6 Epochen à ~1.568 Schritte
      seed: Saat 1: SNAI_START_OFFSET 0 / 3000017 / 6000034 / 9000051 / 12000068 / 15000085 für Epoche 1-6
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/ditto2/log/D_e<E>.log, log/lauf.log, mess/D_e<E>/, arme/D_e<E>.snai
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a ~/snai_pruef/ditto2/mess/D_e<E>/ (auswert.py + Bootstrap 2000 über 50 Sätze, Saat 1); Epoche 1 = alte Messung D_s1 (K0 md5 d13cf606 gleich); Fehlerkanal: alle rc 0, 0 NaN/Fatal/NET2NET/VETO, LR 0,0001 in jeder Epoche (Telemetrie)
  m4967 R = TP4/TP1 | 1,71 / 1,23 / 1,41 / 0,94 | D | e1/e2/e4/e6 | 50
  m4968 R 95-%-Bootstrap | e2 1,17-1,29 / e4 1,34-1,48 / e6 0,86-1,03 | D | e2/e4/e6 | 50
  m4969 TP0..TP4 Epoche 6 | 0,080 / 0,164 / 0,175 / 0,169 / 0,154 | D | e6 | 50
  m4970 TP1/TP0 | e2 2,30 / e4 2,27 / e6 2,05 | D | e2/e4/e6 | 50
  m4971 TP1 | 0,140 / 0,183 / 0,174 / 0,164 | D | e1/e2/e4/e6 | 50
  m4972 Beam-W | 0,130 / 0,163 / 0,127 / 0,102 | D | e1/e2/e4/e6 | 4
  m4973 Held-out (200 Fenster) | 4,481 / 4,458 / 4,596 / 4,693 (Basis 4,128, M e1 4,243) | D | e1/e2/e4/e6 | 200
  m4974 Beleg-Anteil A | 13,3 / 13,5 / 14,9 / 11,8 % (Basis 20,3, M e1 18,1) | D | e1/e2/e4/e6 | 120
  m4975 K0 Epoche 1 md5 | d13cf606 = alte D_s1 | D | e1 | 1
Ergebnis e351 [2026-10-24 09:21]: beobachtung
  Fazit: Einzellauf (Saat 1): Nach Vorab-Regel "Budget ist ein Hebel" (Epoche 6: R = TP4/TP1 0,94 <= 1,0, TP1 0,164 <= 0,28), aber knapp: Bootstrap-Intervall 0,86-1,03 schließt 1,0 ein, Verlauf nicht monoton (1,71/1,23/1,41/0,94). DITTO bricht mit 6x Budget erstmals die Verstärkung ab Kopie 2; der Sprung zur 1. Kopie (TP1/TP0 ~2) bleibt. Kosten wachsen mit dem Budget (Held-out 4,69 gegen M e1 4,24; Beleg-Anteil 11,8 gegen 18 %). Folge laut Regel: volle Reihe 3 Saaten D+M bei 6 Epochen, Kriterien K1-K4 wie snai/ditto-knirps.
  Offen: Wie viel der Kosten reines langes Weitertrainieren auf dem Mix ist (M/C-Arm mit gleichem Budget fehlt). Saatabhängigkeit. Ob kleineres lambda / weniger Mix das Kopieren schont.
  Datei: rechner-a:~/snai_pruef/ditto2/ERGEBNIS_budget.md
Chronik:
  2026-10-24 06:54 angelegt
  2026-10-24 06:55 Rezept r400
  2026-10-24 06:55 Status geplant -> laeuft (Rezept r400)
  2026-10-24 09:21 Messwerte m4967-m4975
  2026-10-24 09:21 Ergebnis e351: beobachtung
  2026-10-24 09:21 Status laeuft -> ausgewertet (Ergebnis e351)
```
