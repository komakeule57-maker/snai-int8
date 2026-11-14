# snai/knirps-mitteln

```text
snai/knirps-mitteln - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 14:29
Frage: Macht häufigeres Mitteln mehrerer Arbeiter den Materialnachteil wett (Knirps 1 x 32, echter Text, 4 Arbeiter mit 1/4/16/64 Mittelungen gegen 1 Arbeiter)? Runde 1, Text in Dateireihenfolge zerschnitten.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/mitteln/kriterium.txt, Haupttext ("Kriterium VOR dem Lauf; Zweitmeinung Gemini/Mistral vorab", 2026-10-12).):
  Kennzahl R(k) = (L[m1] - L[mk]) / (L[m1] - L[a1]) aus Zellmitteln (je 3 Läufe). HILFT, wenn R >= 0,5 UND L[m1]-L[mk] > größte Spannweite der beteiligten Zellen; HILFT NICHT, wenn R < 0,1; dazwischen TEILWEISE. Kontrolle: |L[a16]-L[a1]| muss unter 10 % von (L[m1]-L[a1]) liegen, sonst ist R nicht deutbar. Erwartung aus der Drohne: L[m1] ~ L[a16 nach 1/4 des Materials], Abweichung > 10 % des Abstands heißt, der Drohnen-Befund gilt am Knirps nicht.
Plan: rechner-a:~/snai_pruef/knirps/mitteln/kriterium.txt
Darauf baut: snai/knirps-mitteln-perm
Rezepte:
  r60 [2026-10-21] a1, a16, m1, m4, m16, m64, m64x (LR 0,002): cd ~/snai_pruef/knirps && mitteln/mitteln.sh <arm> <arbeiter> <teile> [lr]  (DAT=mt bzw. mg; je Teil: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_TIE_EMBEDDINGS=1 SNAI_INT8_FULL=1 SNAI_FORCE_CPU=1 SNAI_ACCUM_WINDOWS=1 SNAI_WARMUP_STEPS=100 SNAI_LR_DECAY_STEPS=0 OMP_NUM_THREADS=1 php train_cluster.php factory/input/<DAT>_k<K>_<i>.txt <aus> <W> 1 <vorstand> 3 <lr> 0 1 0; Messung eval_held_out_full_i8.php, 300 Fenster)
      quelltext: knirps/proj (Code md5-gleich mini/proj), libcortex.so 1c634106f31c; mitteln/mitteln.sh 884c45e06a1c; Revival aus
      parameter: Knirps 1 Schicht, Breite 32, 2 Köpfe, ffn 128, ctx 64, Vokabular 8192, Text mini.txt (2 MB aus pseg00, 8.387 Fenster, einmal), LR 0,001 (Zusatzarme 0,002/0,004), Warmup 100, WD 0, INT8 voll; Teile in Dateireihenfolge (DAT=mt)
      seed: je Zelle r1..r3 = 3 Fensterreihenfolgen über den Laufnamen; gleiche Genesis gen_d32_lr3
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/mitteln/ergebnis.txt, <arm>_r<n>.train.log
      notiz: Prüfung beim Nachtrag: Alle Endwerte und Zwischenstände aus ergebnis.txt nachgerechnet. Die Drohnen-Erwartung ist im früheren Befund nicht berichtet (hier aus Rohdaten). Der Wert 0,77 im Nachtrag = 7,559-6,790.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/mitteln/ergebnis.txt (alle Zeilen nachgerechnet)
  m585 Held-out Ende Mittel (Spannweite) (Wiederholungen r1-r3) | 6,790 (0,006) | a1 |  | 3
  m586 Held-out Ende Mittel (Spannweite) (Wiederholungen r1-r3) | 7,011 (0,053) | a16 |  | 3
  m587 Held-out Ende Mittel (Spannweite) (Wiederholungen r1-r3) | 7,559 (0,014) | m1 |  | 3
  m588 Held-out Ende Mittel (Spannweite) (Wiederholungen r1-r3) | 7,476 (0,008) | m4 |  | 3
  m589 Held-out Ende Mittel (Spannweite) (Wiederholungen r1-r3) | 7,527 (0,009) | m16 |  | 3
  m590 Held-out Ende Mittel (Spannweite) (Wiederholungen r1-r3) | 7,518 (0,008) | m64 |  | 3
  m591 Held-out Ende Mittel (Spannweite) (Wiederholungen r1-r3) | 7,196 (0,013) | m64x (LR 0,002) |  | 3
  m592 Kontrolle a16 minus a1 (Wiederholungen r1-r3; 3 gegen 3) | 0,221 = 29 % des Nachteils 0,769 (verfehlt, Grenze 10 %) | a16 gegen a1
  m593 Drohnen-Erwartung: m1 gegen a16 nach 4/16 (Wiederholungen r1-r3; 3 gegen 3) | 7,559 gegen 7,594 (Abstand 0,035 < 0,077) | m1 / a16
  m594 Zwischenstände a16 bei 4/16, 8/16, 12/16 (Wiederholungen r1-r3) | 7,59 / 7,21 / 7,22 (nicht monoton) | a16 |  | 3
Ergebnis e55 [2026-10-21 14:29]: keine_aussage
  Fazit: Die Kontrolle ist verfehlt: schon ein einzelner Arbeiter verliert 0,22 nats, wenn der Text in Dateireihenfolge in 16 Teile zerschnitten wird. Damit ist R(k) nach dem eigenen Kriterium nicht deutbar, die Runde beantwortet die Mitteln-Frage nicht. Sie zeigte aber den eigentlichen Störfaktor: die Reihenfolge des Texts (Runde 2 bestätigte das). Die Drohnen-Erwartung hält am Knirps (m1 etwa wie ein Arbeiter nach einem Viertel des Materials).
  Offen: Reihenfolge gegen Aufrufkosten: in snai/knirps-mitteln-perm getrennt.
  Datei: rechner-a:~/snai_pruef/knirps/mitteln/kriterium.txt
Chronik:
  2026-10-21 14:29 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/mitteln/kriterium.txt, Haupttext ("Kriterium VOR dem Lauf; Zweitmeinung Gemini/Mistral vorab", 2026-10-12).)
  2026-10-21 14:29 Rezept r60 (a1, a16, m1, m4, m16, m64, m64x (LR 0,002))
  2026-10-21 14:29 Status geplant -> laeuft (Rezept r60)
  2026-10-21 14:29 Messwerte m585-m594
  2026-10-21 14:29 Ergebnis e55: keine_aussage
  2026-10-21 14:29 Status laeuft -> ausgewertet (Ergebnis e55)
```
