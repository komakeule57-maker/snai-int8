# snai/gradclip-knirps-kurz

```text
snai/gradclip-knirps-kurz - ausgewertet, angelegt 2026-10-30, zuletzt 2026-10-30 07:58
Frage: Bremst oder hilft das ständige Gradienten-Clipping (Schwelle 1,0 im Mittelwert-Raum, greift in int8-Läufen in 93-100 % der Schritte)? Knirps 128x4 auf den Kindergeschichten, die ersten ~9.000 Schritte: lernt er anders, wenn der Clip seltener (Schwelle 5) oder gar nicht (1e30) greift?
Kriterium (festgelegt 2026-10-30 06:43, vor dem ersten Messwert):
  Messgröße: Held-out-Loss L (mess_text.php 711d8187, heldout.txt bee2cc54, 700 Fenster ctx 128) an adam_t 1.000, 3.000 und Ende (~9.000). Urteil je Budget (3.000 und Ende getrennt; 1.000 nur berichtet), je Arm X (K5, AUS) gegen K1, je Saat d = (L_K1 - L_X)/L_K1: X BESSER bei d >= +10 % in 3/3 Saaten, SCHLECHTER bei d <= -10 % in 3/3, GLEICHSTAND bei |d| < 10 % in 3/3, sonst saatabhängig (kein Schluss). NaN/Abbruch = SCHLECHTER (instabil). Zusätzlich berichtet: Differenzen in nats (Maßstab 0,02 nats), Vorzeichen über die Saaten, Clip-Anteil je Arm gegen seine Schwelle, GradNorm. Kontrolle vorab: ungepatcht = gepatcht leer = gepatcht 1 = Wiederholung bytegleich, Rot 1e30 weicht ab. Größter freier Parameter: Budget (6 % eines Durchgangs), dann Schwelle 5, dann LR 0,001 (ein Gleichstand gilt nur für diese LR). Reichweite: 1 Modell, 1 Datensatz, 1 Rezept, 3 Saaten.
Plan: rechner-a:~/snai_pruef/clip/kriterien.txt
Baut auf: snai/gradclip-drohne, snai/geschichten-chin128
Darauf baut: snai/gradclip-knirps-lr3, snai/geschichten-wortfeld
Rezepte:
  r465 [2026-10-30] cd ~/snai_pruef/clip && setsid -f nohup ./reihe.sh  (je Saat die 3 Arme parallel, Saaten nacheinander; je Lauf: ./lauf_clip.sh reihe <K1|K5|AUS> <1|5|1e30> <saat> daten/kurz9000.txt 1000,3000 -> SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_SNAPSHOT_STEPS=1000,3000 SNAI_CLIP_SCHWELLE=<s> php train_cluster.php kurz9000.txt clip_s<saat>.snai 1 1 clip_gen_s<saat>.snai 3 0.001 0.0001 1 0.1, OMP 1, CPU)
      quelltext: wie r464; reihe.sh a5c1f838 (statt 0400de02: 3 statt 6 parallel)
      seed: 1,2,3
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/clip/laeufe/reihe/<arm>_s<saat>/, log/reihe.log, log/genesis.jsonl
      notiz: Erster Start 06:43 vor dem ersten Training per PID beendet (nur Genesis-Messung gelaufen): 6 parallele Läufe hätten bei 2,67 GB verfügbar die Regel >= 2 GB frei verletzt. Neustart 06:45:23. Kontrolle wie r464.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/clip/log/auswertung.txt (werkzeug/auswerten.py über laeufe/reihe/*/mess.jsonl, train.log)
  m6439 heldout_loss_genesis | 7,3192 | alle | 1 | 700
  m6440 heldout_loss_genesis | 7,3193 | alle | 2 | 700
  m6441 heldout_loss_genesis | 7,3192 | alle | 3 | 700
  m6442 heldout_loss_t1000 | 3,1866 | K1 | 1 | 700
  m6443 heldout_loss_t1000 | 3,2135 | K5 | 1 | 700
  m6444 heldout_loss_t1000 | 3,2362 | AUS | 1 | 700
  m6445 heldout_loss_t1000 | 3,1902 | K1 | 2 | 700
  m6446 heldout_loss_t1000 | 3,2218 | K5 | 2 | 700
  m6447 heldout_loss_t1000 | 3,2252 | AUS | 2 | 700
  m6448 heldout_loss_t1000 | 3,2211 | K1 | 3 | 700
  m6449 heldout_loss_t1000 | 3,2292 | K5 | 3 | 700
  m6450 heldout_loss_t1000 | 3,2466 | AUS | 3 | 700
  m6451 heldout_loss_t3000 | 2,8253 | K1 | 1 | 700
  m6452 heldout_loss_t3000 | 2,8388 | K5 | 1 | 700
  m6453 heldout_loss_t3000 | 2,8465 | AUS | 1 | 700
  m6454 heldout_loss_t3000 | 2,8240 | K1 | 2 | 700
  m6455 heldout_loss_t3000 | 2,8475 | K5 | 2 | 700
  m6456 heldout_loss_t3000 | 2,8330 | AUS | 2 | 700
  m6457 heldout_loss_t3000 | 2,8221 | K1 | 3 | 700
  m6458 heldout_loss_t3000 | 2,8492 | K5 | 3 | 700
  m6459 heldout_loss_t3000 | 2,8493 | AUS | 3 | 700
  m6460 heldout_loss_ende_t9002 | 2,5628 | K1 | 1 | 700
  m6461 heldout_loss_ende_t9002 | 2,5859 | K5 | 1 | 700
  m6462 heldout_loss_ende_t9002 | 2,5830 | AUS | 1 | 700
  m6463 heldout_loss_ende_t9002 | 2,5459 | K1 | 2 | 700
  m6464 heldout_loss_ende_t9002 | 2,5451 | K5 | 2 | 700
  m6465 heldout_loss_ende_t9002 | 2,5670 | AUS | 2 | 700
  m6466 heldout_loss_ende_t9002 | 2,5279 | K1 | 3 | 700
  m6467 heldout_loss_ende_t9002 | 2,5433 | K5 | 3 | 700
  m6468 heldout_loss_ende_t9002 | 2,5285 | AUS | 3 | 700
  m6469 clip_anteil_nach_warmup_gegen_eigene_schwelle | 100 % in allen 3 Saaten | K1 | 1-3
  m6470 clip_anteil_nach_warmup_gegen_eigene_schwelle | 0,0 / 0,1 / 0,2 % | K5 | 1-3
  m6471 clip_anteil_nach_warmup_gegen_eigene_schwelle | 0 % | AUS | 1-3
  m6472 gradnorm_median_nach_warmup | 1,834 / 1,787 / 1,804 | K1 | 1-3
  m6473 gradnorm_median_nach_warmup | 1,848 / 1,843 / 1,842 | K5 | 1-3
  m6474 gradnorm_median_nach_warmup | 1,920 / 1,910 / 1,889 | AUS | 1-3
  m6475 fehlerkanal_train_und_mess | 0 Zeilen / 0 Byte in allen 9 Läufen | alle | 1-3
  m6476 kontrolle_schritt1_loss_je_saat_gleich | ja (3/3) | alle | 1-3
Ergebnis e408 [2026-10-30 07:58]: gleichstand
  Fazit: Das ständige Clipping (100 % der Schritte bei Schwelle 1) bremst den Knirps 128x4 in den ersten 9.000 Schritten nicht. K5 und AUS liegen in beiden Budgets bei |d| < 1 % gegen K1 (Gleichstand 3/3), die Abstände betragen höchstens 0,027 nats, die Streuung zwischen den Saaten ist größer. Beobachtung: Das Vorzeichen spricht fast immer leicht für K1 (6/6 nach 3.000 Schritten, 5/6 am Ende), der Vorsprung schrumpft mit dem Training. Die Entwarnung ist damit für diesen Bereich gemessen; der Einwand „int8-Momente bzw. wechselnder Faktor 1/Norm machen den Clip schädlich“ ist für diesen Bereich widerlegt. Die Messung legt keinen Umbau der Clip-Vorgabe nahe.
  Offen: Lange Läufe (geprüft sind nur 6 % eines Durchgangs), andere LR (nur 0,001 geprüft; 3e-3 wäre die nächste Frage), prod512b (1.024 Token je Schritt, LR 1e-4). Ob das Rauschen die Norm bestimmt (1/√k-Probe, Vorschlag aus dem SnAI-Hauptzweig), ist nicht gemessen.
  Datei: rechner-a:~/snai_pruef/clip/ERGEBNIS_gradclip_knirps_kurz.md
Abgeloest und ausgeblendet: 1 rezept - voll=True zeigt sie.
Chronik:
  2026-10-30 06:43 angelegt
  2026-10-30 06:43 Rezept r464
  2026-10-30 06:43 Status geplant -> laeuft (Rezept r464)
  2026-10-30 06:45 Rezept r465, loest r464 ab
  2026-10-30 07:57 Messwerte m6439-m6476
  2026-10-30 07:58 Ergebnis e408: gleichstand
  2026-10-30 07:58 Status laeuft -> ausgewertet (Ergebnis e408)
```
