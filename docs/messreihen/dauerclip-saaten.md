# snai/dauerclip-saaten

```text
snai/dauerclip-saaten - ausgewertet, angelegt 2026-11-01, zuletzt 2026-11-01 17:47
Frage: Schuetzt das Clipping die FFN-Gains vor dem Kippen?
Kriterium (festgelegt 2026-11-01 13:37, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/clip/kriterien_dc.txt, vor dem ersten Lauf, Pruefer. Arme K1 und AUS gepaart, 128x4 voll int8, LR 0,003, 9.002 Schritte, nur frische Saaten 4-11. D = L2 tot AUS minus K1. SCHUETZT: K1 < AUS in mindestens 6 von 8 und mittleres D >= 20. KEIN SCHUTZ: mittleres D < 10. Sonst OFFEN.
Plan: rechner-b:~/snai_pruef/clip/kriterien_dc.txt
Baut auf: snai/clipfix-gains
Darauf baut: snai/wd-gains, snai/gains-spalten, snai/gains-batchgen, snai/wdg-kippen, snai/residuum-gains, snai/gains-kanalindex, snai/gains-ursache-folge, snai/tying-gains, snai/ffn2-null-training, snai/genesis-ffn-128
Rezepte:
  r492 [2026-11-01] rechner-b: cd ~/snai_pruef/clip && setsid -f nohup ./reihe_dc.sh > log/reihe_dc.out 2>&1 < /dev/null
      quelltext: kriterien_dc.txt 9ff30470, reihe_dc.sh 78622ee9, lauf_clip.sh, proj_clip Lib ccb10b0f
      seed: Genesis 4-11, Laufname clip_s<S>
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/clip/log/reihe_dc.log, laeufe/reihe_dc/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/clip/log/auswertung_dc.txt (auswerten_dc.py c40d9cc2, bestand.py). Genesis 52ca74d0, rc=0, STEPS_DONE=9002 je Lauf, Fehlerkanal 0, Step 1 je Paar gleich.
  m7249 L2 tot K1 / AUS, D | 79,7 / 8,6, -71,1 | K1,AUS | 4
  m7250 L2 tot K1 / AUS, D | 0,8 / 46,1, +45,3 | K1,AUS | 5
  m7251 L2 tot K1 / AUS, D | 22,7 / 32,0, +9,3 | K1,AUS | 6
  m7252 L2 tot K1 / AUS, D | 49,2 / 69,5, +20,3 | K1,AUS | 7
  m7253 L2 tot K1 / AUS, D | 61,7 / 46,1, -15,6 | K1,AUS | 8
  m7254 L2 tot K1 / AUS, D | 59,4 / 32,8, -26,6 | K1,AUS | 9
  m7255 L2 tot K1 / AUS, D | 60,2 / 1,6, -58,6 | K1,AUS | 10
  m7256 L2 tot K1 / AUS, D | 85,9 / 69,5, -16,4 | K1,AUS | 11
  m7257 Mittel D, K1<AUS | -14,2, 3 von 8 | K1,AUS | 4-11
  m7258 Held-out Mittel | 2,6842 / 2,7337, K1 besser in 8 von 8, Spanne 0,014-0,095 | K1,AUS | 4-11
  m7259 D Saat 1-3, nur daneben | +25,8 / +67,2 / -28,9 | K1,AUS | 1-3
Ergebnis e429 [2026-11-01 17:47]: verfehlt
  Fazit: KEIN SCHUTZ nach Regel: Der Clip schuetzt die Gains in diesem Rezept nicht vor dem Kippen, und er ist auch nicht ihr Motor, ohne Clip kippen sie weiter. Das Muster aus Saat 1-3 war Zufall: D streut bei frischen Saaten von -71 bis +45. Drei Saaten taugen fuer Gains-Vergleiche hier nicht. Unverlangt: Held-out mit Clip in 8/8 Saaten besser um im Mittel 0,05 nats, nicht vorab bewertet.
  Offen: Andere LR und laengere Laeufe; ob der Clip die Norm treibt (snai/dauerclip-lang); warum L2 je Saat so verschieden kippt; Herkunft des Held-out-Vorteils.
  Datei: rechner-b:~/snai_pruef/clip/ERGEBNIS_dauerclip_saaten.md
Chronik:
  2026-11-01 13:37 angelegt
  2026-11-01 13:37 Rezept r492
  2026-11-01 13:37 Status geplant -> laeuft (Rezept r492)
  2026-11-01 17:47 Messwerte m7249-m7259
  2026-11-01 17:47 Ergebnis e429: verfehlt
  2026-11-01 17:47 Status laeuft -> ausgewertet (Ergebnis e429)
```
