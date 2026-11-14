# snai/gradclip-knirps-lr3

```text
snai/gradclip-knirps-lr3 - ausgewertet, angelegt 2026-10-30, zuletzt 2026-10-30 09:45
Frage: Bremst oder hilft das ständige Gradienten-Clipping am Knirps 128x4, wenn die Lernrate dreimal so hoch ist (0,003 statt 0,001)? Folgereihe zu snai/gradclip-knirps-kurz (dort Gleichstand bei LR 0,001).
Kriterium (festgelegt 2026-10-30 09:09, vor dem ersten Messwert):
  Wortgleich mit snai/gradclip-knirps-kurz bis auf LR 0,003: Held-out-Loss (mess_text.php, heldout.txt, 700 Fenster) an adam_t 1.000, 3.000, Ende 9.002. Urteil je Budget (3.000 und Ende), je Arm X (K5, AUS) gegen K1, je Saat d = (L_K1 - L_X)/L_K1: BESSER d >= +10 % in 3/3, SCHLECHTER <= -10 % in 3/3, GLEICHSTAND |d| < 10 % in 3/3, sonst saatabhängig. NaN/Abbruch = SCHLECHTER. Kontrolle vorab: Karte und CPU rechner-b bytegleich zur CPU rechner-a (f1cb2b41), Rot 1e30 auf der Karte weicht ab; sonst Reihe auf der CPU. Größter freier Parameter: LR 0,003 (Faktor 3 frei gewählt).
Plan: rechner-b:~/snai_pruef/clip/kriterien_lr3.txt
Baut auf: snai/gradclip-knirps-kurz
Darauf baut: snai/clipfix-gains, snai/dauerclip-lang
Rezepte:
  r466 [2026-10-30] rechner-b: cd ~/snai_pruef/clip && setsid -f nohup ./reihe_lr3.sh  (CLIP_GPU=1 CLIP_LR=0.003 CLIP_OHNE_LOCK=1; alle 9 Läufe parallel; je Lauf ./lauf_clip.sh reihe_lr3 <K1|K5|AUS> <1|5|1e30> <saat> daten/kurz9000.txt 1000,3000 -> wie snai/gradclip-knirps-kurz r465, aber LR 0.003 und Karte: SNAI_GPU_MIN_DIM=128 SNAI_I8_GPU_ADAM=1 LD_LIBRARY_PATH=<lauf>:/opt/cuda/lib64, ohne SNAI_FORCE_CPU)
      quelltext: libcortex.so ccb10b0f (auf rechner-b neu gebaut, bytegleich mit rechner-a), libcortex_cuda.so ecc68621, lauf_clip.sh 753045e5, reihe_lr3.sh d81d5d35, kriterien_lr3.txt 40824d35, Daten/Genesis wie r465
      seed: 1,2,3
      rechner: rechner-b (RTX 3050, CUDA)
      logs: rechner-b:~/snai_pruef/clip/laeufe/reihe_lr3/<arm>_s<saat>/, log/reihe_lr3.log
      notiz: Kontrolle 09:08 (307 Schritte, LR 0,001): CPU rechner-b = Karte = CPU rechner-a f1cb2b41; Rot 1e30 auf der Karte a0a2e487 = Rot rechner-a. Karte 24 s gegen CPU 33 s je Kontrolllauf. Erster Start 09:09:34 nach 1 min per PID beendet (Messbefehl falsch: "env 1 php"), verworfen; Neustart 09:10:23 mit korrigiertem lauf_clip.sh.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/clip/log/auswertung_lr3.txt (werkzeug/auswerten.py laeufe/reihe_lr3)
  m6499 heldout_loss_t1000 | 3,2804 | K1 | 1 | 700
  m6500 heldout_loss_t1000 | 3,2729 | K5 | 1 | 700
  m6501 heldout_loss_t1000 | 3,2973 | AUS | 1 | 700
  m6502 heldout_loss_t1000 | 3,2620 | K1 | 2 | 700
  m6503 heldout_loss_t1000 | 3,2652 | K5 | 2 | 700
  m6504 heldout_loss_t1000 | 3,2628 | AUS | 2 | 700
  m6505 heldout_loss_t1000 | 3,2639 | K1 | 3 | 700
  m6506 heldout_loss_t1000 | 3,2596 | K5 | 3 | 700
  m6507 heldout_loss_t1000 | 3,3116 | AUS | 3 | 700
  m6508 heldout_loss_t3000 | 2,9752 | K1 | 1 | 700
  m6509 heldout_loss_t3000 | 2,9924 | K5 | 1 | 700
  m6510 heldout_loss_t3000 | 3,0031 | AUS | 1 | 700
  m6511 heldout_loss_t3000 | 2,9412 | K1 | 2 | 700
  m6512 heldout_loss_t3000 | 2,9779 | K5 | 2 | 700
  m6513 heldout_loss_t3000 | 2,9805 | AUS | 2 | 700
  m6514 heldout_loss_t3000 | 2,9662 | K1 | 3 | 700
  m6515 heldout_loss_t3000 | 2,9930 | K5 | 3 | 700
  m6516 heldout_loss_t3000 | 3,0535 | AUS | 3 | 700
  m6517 heldout_loss_ende_t9002 | 2,7191 | K1 | 1 | 700
  m6518 heldout_loss_ende_t9002 | 2,7632 | K5 | 1 | 700
  m6519 heldout_loss_ende_t9002 | 2,7872 | AUS | 1 | 700
  m6520 heldout_loss_ende_t9002 | 2,6969 | K1 | 2 | 700
  m6521 heldout_loss_ende_t9002 | 2,7253 | K5 | 2 | 700
  m6522 heldout_loss_ende_t9002 | 2,7520 | AUS | 2 | 700
  m6523 heldout_loss_ende_t9002 | 2,6730 | K1 | 3 | 700
  m6524 heldout_loss_ende_t9002 | 2,7193 | K5 | 3 | 700
  m6525 heldout_loss_ende_t9002 | 2,7117 | AUS | 3 | 700
  m6526 clip_anteil_nach_warmup_gegen_eigene_schwelle | 60,8 / 58,6 / 52,2 % | K1 | 1-3
  m6527 clip_anteil_nach_warmup_gegen_eigene_schwelle | 0,0 / 0,0 / 0,1 % | K5 | 1-3
  m6528 clip_anteil_nach_warmup_gegen_eigene_schwelle | 0 % | AUS | 1-3
  m6529 gradnorm_median_nach_warmup | 1,032 / 1,021 / 1,005 | K1 | 1-3
  m6530 gradnorm_median_nach_warmup | 1,109 / 1,090 / 1,081 | K5 | 1-3
  m6531 gradnorm_median_nach_warmup | 1,121 / 1,115 / 1,110 | AUS | 1-3
  m6532 fehlerkanal_train_und_mess | 0 Zeilen / 0 Byte in allen 9 Läufen | alle | 1-3
  m6533 kontrolle_schritt1_loss_je_saat_gleich | ja (3/3) | alle | 1-3
  m6534 backend | CUDA in 9/9, LR im Log 0,0030000 | alle | 1-3
Ergebnis e410 [2026-10-30 09:45]: gleichstand
  Fazit: Auch bei LR 0,003 bremst der Dauer-Clip nicht. Nach der Regel herrscht Gleichstand (|d| ≤ 2,9 %), aber K1 liegt nach 3.000 Schritten und am Ende in 12/12 Paaren vorn, am Ende um 0,03–0,07 nats, das ist 2–3-mal mehr als bei LR 0,001 (Beobachtung). Für die Praxis: Die Vorgabe Schwelle 1 bleibt richtig, sie abzuschwächen bringt nichts. Die LR wiegt schwerer als der Clip: LR 0,001 schlägt 0,003 in allen Armen um ~6 % (berichtet, nicht geurteilt). Weitere Clip-Reihen am Knirps lohnen kaum.
  Offen: Lange Läufe (geprüft 9.002 Schritte), prod512b (1.024 Token je Schritt, LR 1e-4), ob der Clip-Vorsprung bei noch höherer LR weiter wächst (nur 2 LR-Stufen).
  Datei: rechner-a:~/snai_pruef/clip/ERGEBNIS_gradclip_knirps_lr3.md
Chronik:
  2026-10-30 09:09 angelegt
  2026-10-30 09:10 Rezept r466
  2026-10-30 09:10 Status geplant -> laeuft (Rezept r466)
  2026-10-30 09:45 Messwerte m6499-m6534
  2026-10-30 09:45 Ergebnis e410: gleichstand
  2026-10-30 09:45 Status laeuft -> ausgewertet (Ergebnis e410)
```
