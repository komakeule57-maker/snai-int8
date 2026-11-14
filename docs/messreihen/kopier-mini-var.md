# snai/kopier-mini-var

```text
snai/kopier-mini-var - ausgewertet, begonnen 2026-10-09, angelegt 2026-10-21, zuletzt 2026-10-21 11:20
Frage: Kann der echte Trainer samt Kern inhaltsbasiertes Kopieren (Induktion) lernen (Aufgabe `var` = [R1][R1][R2][R2], Längen 6-16), bei LR 0,001?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21 (Arm `var`; Arm `fest` steht als snai/kopier-mini-fest); Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  Gelernt = Rang 0 auf der zweiten Kopie >= 90 % auf 200 frischen Fenstern, nicht gelernt < 10 %. Rot-Probe: fremde erste Kopie.
Baut auf: snai/kopier-mini-induktion
Darauf baut: snai/kopier-mini-lr-batch
Rezepte:
  r22 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben)
      parameter: 128/2/4, ffn 512, ctx 64, Vokabular 8192 (256 benutzt), INT8 voll gebunden; train_cluster.php, 1 Worker, 1 Fenster = 1 Schritt, LR 0,001 konstant, Revival an; 30.000 Schritte. PyTorch-Nachbau gebunden 40.000 Schritte
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/lernversuch/; Skripte Laptop:~/.cache/snai_pruef/lernversuch/
Messwerte (Groesse | Wert | Arm | Start | n):
  m191 R0 zweite Kopie nach 30.000 Schritten | 20,1 % (Loss 3,683) | INT8 gebunden |  | 200
  m192 R0 Verlauf 5k/10k/15k/20k/25k/30k | 13,9 / 15,6 / 16,4 / 18,1 / 19,6 / 20,1 % | INT8 gebunden |  | 200
  m193 R0 zweite Kopie nach 40.000 Schritten | 17,5 % | PyTorch gebunden
Ergebnis e20 [2026-10-21 11:20]: keine_aussage
  Fazit: Nach Vorab-Regel weder gelernt (>= 90 %) noch nicht gelernt (< 10 %): 20,1 % ist ein Teilplateau, Kopieren nach Inhalt entstand in 30.000-40.000 Ein-Fenster-Schritten weder im Kern noch im PyTorch-Nachbau. Der Versuch zeigt also nur, dass sich der Kern wie ein Standard-Transformer verhält, nicht ob er Induktion kann. Die Vermutung des Eintrags (Ein-Fenster-Betrieb macht Induktion zäh) wurde am selben Tag widerlegt: Ursache war die LR 0,001 (snai/kopier-mini-lr-batch).
  Offen: Ein Lauf je Arm; Revival war an.
Chronik:
  2026-10-21 11:19 angelegt (Nachtrag: Nachgetragen 2026-10-21 (Arm `var`; Arm `fest` steht als snai/kopier-mini-fest); Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:19 Rezept r22
  2026-10-21 11:19 Status geplant -> laeuft (Rezept r22)
  2026-10-21 11:19 Messwerte m191-m193
  2026-10-21 11:20 Ergebnis e20: keine_aussage
  2026-10-21 11:20 Status laeuft -> ausgewertet (Ergebnis e20)
```
