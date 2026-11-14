# snai/knirps-mitteln-perm

```text
snai/knirps-mitteln-perm - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 14:30
Frage: Runde 2 des Mitteln-Versuchs auf blockweise permutiertem Text: liegt der Verlust beim Zerschneiden an der Reihenfolge (A) oder an Aufrufkosten (B), und hilft häufigeres Mitteln dann bei gleicher Rate?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/mitteln/kriterium.txt, NACHTRAG 2026-10-12 18:55 (nach Runde 1, vor Runde 2).):
  Dieselbe Datei in Blöcken zu 20 Zeilen zufällig permutiert (Saat 20261012), dann in k Teile geschnitten; Zellen wie Runde 1 mit Endung g, je 3. (A) gilt, wenn L[a16g]-L[a1g] < 10 % von (L[m1g]-L[a1g]) UND die Zwischenstände monoton fallen; (B) gilt, wenn der Abstand a16g-a1g >= 0,11 bleibt; dazwischen beides. Kontrolle der Permutation: |L[a1g]-L[a1]| < 0,03. Ist die Kontrolle a16g bestanden, gilt für R(k) das Urteil aus Runde 1 unverändert: HILFT bei R >= 0,5 und Abstand > Spannweiten, HILFT NICHT bei R < 0,1, sonst TEILWEISE.
Plan: rechner-a:~/snai_pruef/knirps/mitteln/kriterium.txt
Baut auf: snai/knirps-mitteln
Darauf baut: snai/knirps-mitteln-rate
Rezepte:
  r68 [2026-10-21] a1g, a16g, m1g, m4g, m16g, m64g, m64xg (LR 0,002): cd ~/snai_pruef/knirps && mitteln/mitteln.sh <arm> <arbeiter> <teile> [lr]  (DAT=mt bzw. mg; je Teil: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_TIE_EMBEDDINGS=1 SNAI_INT8_FULL=1 SNAI_FORCE_CPU=1 SNAI_ACCUM_WINDOWS=1 SNAI_WARMUP_STEPS=100 SNAI_LR_DECAY_STEPS=0 OMP_NUM_THREADS=1 php train_cluster.php factory/input/<DAT>_k<K>_<i>.txt <aus> <W> 1 <vorstand> 3 <lr> 0 1 0; Messung eval_held_out_full_i8.php, 300 Fenster)
      quelltext: knirps/proj (Code md5-gleich mini/proj), libcortex.so 1c634106f31c; mitteln/mitteln.sh 884c45e06a1c; Revival aus
      parameter: Knirps 1 Schicht, Breite 32, 2 Köpfe, ffn 128, ctx 64, Vokabular 8192, Text mini.txt (2 MB aus pseg00, 8.387 Fenster, einmal), LR 0,001 (Zusatzarme 0,002/0,004), Warmup 100, WD 0, INT8 voll; DAT=mg (blockweise permutiert, mischen.py)
      seed: je Zelle r1..r3 = 3 Fensterreihenfolgen über den Laufnamen; gleiche Genesis gen_d32_lr3
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/mitteln/ergebnis.txt, <arm>_r<n>.train.log
      notiz: Prüfung beim Nachtrag: Alle Werte aus ergebnis.txt nachgerechnet, R(k) = Nachtrag 20:15. Abweichung im Wortlaut: Der frühere Befund sagt pauschal "hilft nicht (0,07-0,11)"; nach der Regel ist R(4) = 0,107 >= 0,1 TEILWEISE, nur k = 16 und 64 sind HILFT NICHT.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/mitteln/ergebnis.txt (nachgerechnet)
  m682 Held-out Ende Mittel (Spannweite) (Wiederholungen r1-r3) | 6,799 (0,035) | a1g |  | 3
  m683 Held-out Ende Mittel (Spannweite) (Wiederholungen r1-r3) | 6,830 (0,004) | a16g |  | 3
  m684 Held-out Ende Mittel (Spannweite) (Wiederholungen r1-r3) | 7,536 (0,034) | m1g |  | 3
  m685 Held-out Ende Mittel (Spannweite) (Wiederholungen r1-r3) | 7,457 (0,007) | m4g |  | 3
  m686 Held-out Ende Mittel (Spannweite) (Wiederholungen r1-r3) | 7,485 (0,011) | m16g |  | 3
  m687 Held-out Ende Mittel (Spannweite) (Wiederholungen r1-r3) | 7,481 (0,002) | m64g |  | 3
  m688 Held-out Ende Mittel (Spannweite) (Wiederholungen r1-r3) | 7,112 (0,017) | m64xg (LR 0,002) |  | 3
  m689 Kontrolle a16g minus a1g (Wiederholungen r1-r3; 3 gegen 3) | +0,031 = 4 % (bestanden) | a16g gegen a1g
  m690 Kontrolle Permutation a1g minus a1 (Wiederholungen r1-r3; 3 gegen 3) | +0,009 (bestanden) | a1g gegen a1
  m691 Zwischenstände a16g (Wiederholungen r1-r3) | 7,57 / 7,21 / 6,97 / 6,83 (monoton) | a16g |  | 3
  m692 R(4) (Wiederholungen r1-r3; Zellmittel) | 0,107 | m4g
  m693 R(16) (Wiederholungen r1-r3; Zellmittel) | 0,069 | m16g
  m694 R(64) (Wiederholungen r1-r3; Zellmittel) | 0,075 | m64g
  m695 R(64, LR 0,002) (Wiederholungen r1-r3; Zellmittel) | 0,575 | m64xg
Ergebnis e62 [2026-10-21 14:30]: verfehlt
  Fazit: Die Reihenfolge war der Störfaktor (A), nicht die Aufrufkosten. Häufigeres Mitteln bei gleicher Rate macht den Materialnachteil nicht wett: R(16) und R(64) liegen unter 0,1 (HILFT NICHT), R(4) mit 0,107 knapp darüber (formal TEILWEISE), und es gibt keine Dosis-Wirkung. Nur mit doppelter Rate holt 64-faches Mitteln mehr als die Hälfte (R 0,575), aber dort ändern sich Rate und Mitteln gemeinsam; das trennte Runde 3.
  Offen: Rate allein gegen Rate mal Mitteln: snai/knirps-mitteln-rate.
  Datei: rechner-a:~/snai_pruef/knirps/mitteln/kriterium.txt
Chronik:
  2026-10-21 14:30 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/mitteln/kriterium.txt, NACHTRAG 2026-10-12 18:55 (nach Runde 1, vor Runde 2).)
  2026-10-21 14:30 Rezept r68 (a1g, a16g, m1g, m4g, m16g, m64g, m64xg (LR 0,002))
  2026-10-21 14:30 Status geplant -> laeuft (Rezept r68)
  2026-10-21 14:30 Messwerte m682-m695
  2026-10-21 14:30 Ergebnis e62: verfehlt
  2026-10-21 14:30 Status laeuft -> ausgewertet (Ergebnis e62)
```
