# snai/knirps-mitteln-rate

```text
snai/knirps-mitteln-rate - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 14:30
Frage: Runde 3 des Mitteln-Versuchs (permutierter Text): macht häufiges Mitteln eine höhere Lernrate erst nutzbar (Wechselwirkung), wirken 4 Arbeiter mit 64 Mittelungen wie Batch 4, und holt die beste 4-Arbeiter-Zelle die beste 1-Arbeiter-Zelle ein?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/mitteln/kriterium.txt, NACHTRAG 2026-10-12 20:15 (nach Runde 2, vor Runde 3; Datei zuletzt 20:13:09 - Uhrzeit im Text auf die Viertelstunde gerundet).):
  Zusatzzellen je 3 Läufe: a1xg (1 Arbeiter, LR 0,002), a1yg (0,004), m1xg (4 Arbeiter, 1 Mittelung, 0,002), m1yg (0,004), m64yg (4 Arbeiter, 64 Mittelungen, 0,004). (1) WECHSELWIRKUNG belegt, wenn L[m1]-L[m64] bei LR 0,002 UND 0,004 jeweils >= 0,18 (ein Viertel des Nachteils 0,74) und größer als die Spannweiten; bleibt er unter 0,09, ist der Gewinn von m64x reine Ratenwirkung. (2) SKALIERUNG "wie Batch 4", wenn L[m64, 0,004] höchstens 0,074 über L[a1, 0,001] = 6,799 liegt. (3) FAIRER VERGLEICH: Nachteil wett nur bei Restabstand < 0,074 zwischen bester 4-Arbeiter- und bester 1-Arbeiter-Zelle über die drei Raten.
Plan: rechner-a:~/snai_pruef/knirps/mitteln/kriterium.txt
Baut auf: snai/knirps-mitteln-perm
Rezepte:
  r69 [2026-10-21] a1xg, a1yg, m1xg, m1yg, m64yg: cd ~/snai_pruef/knirps && mitteln/mitteln.sh <arm> <arbeiter> <teile> [lr]  (DAT=mt bzw. mg; je Teil: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_TIE_EMBEDDINGS=1 SNAI_INT8_FULL=1 SNAI_FORCE_CPU=1 SNAI_ACCUM_WINDOWS=1 SNAI_WARMUP_STEPS=100 SNAI_LR_DECAY_STEPS=0 OMP_NUM_THREADS=1 php train_cluster.php factory/input/<DAT>_k<K>_<i>.txt <aus> <W> 1 <vorstand> 3 <lr> 0 1 0; Messung eval_held_out_full_i8.php, 300 Fenster)
      quelltext: knirps/proj (Code md5-gleich mini/proj), libcortex.so 1c634106f31c; mitteln/mitteln.sh 884c45e06a1c; Revival aus
      parameter: Knirps 1 Schicht, Breite 32, 2 Köpfe, ffn 128, ctx 64, Vokabular 8192, Text mini.txt (2 MB aus pseg00, 8.387 Fenster, einmal), LR 0,001 (Zusatzarme 0,002/0,004), Warmup 100, WD 0, INT8 voll; DAT=mg
      seed: je Zelle r1..r3 = 3 Fensterreihenfolgen über den Laufnamen; gleiche Genesis gen_d32_lr3
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/mitteln/ergebnis.txt, <arm>_r<n>.train.log
      notiz: Prüfung beim Nachtrag: Alle Werte aus ergebnis.txt nachgerechnet (Rest 0,2476 -> 0,248).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/mitteln/ergebnis.txt (nachgerechnet)
  m696 Held-out Ende Mittel (Spannweite) (Wiederholungen r1-r3) | 6,676 (0,016) | a1xg (1 Arbeiter, 0,002) |  | 3
  m697 Held-out Ende Mittel (Spannweite) (Wiederholungen r1-r3) | 6,675 (0,039) | a1yg (1 Arbeiter, 0,004) |  | 3
  m698 Held-out Ende Mittel (Spannweite) (Wiederholungen r1-r3) | 7,607 (0,176) | m1xg (4 Arb., 1 Mittelung, 0,002) |  | 3
  m699 Held-out Ende Mittel (Spannweite) (Wiederholungen r1-r3) | 7,875 (0,198) | m1yg (4 Arb., 1 Mittelung, 0,004) |  | 3
  m700 Held-out Ende Mittel (Spannweite) (Wiederholungen r1-r3) | 6,922 (0,023) | m64yg (4 Arb., 64 Mittelungen, 0,004) |  | 3
  m701 Gewinn m1 minus m64 je LR 0,001 / 0,002 / 0,004 (Wiederholungen r1-r3; Zellmittel) | 0,055 / 0,495 / 0,953 | Wechselwirkung (1)
  m702 m64 bei 0,004 minus a1 bei 0,001 (Wiederholungen r1-r3; Zellmittel) | +0,123 (Grenze 0,074) | Skalierung (2)
  m703 Rest beste 4-Arbeiter (6,922) minus beste 1-Arbeiter (6,675) (Wiederholungen r1-r3; Zellmittel) | 0,248 (Grenze 0,074) | fairer Vergleich (3)
  m704 Anteil des Nachteils zurückgeholt (m64yg) (Wiederholungen r1-r3; Zellmittel) | 83 % | Skalierung (2)
Ergebnis e63 [2026-10-21 14:30]: teilweise
  Fazit: Die Wechselwirkung ist belegt: häufiges Mitteln macht die höhere Rate erst nutzbar (Gewinn 64 gegen 1 Mittelung wächst mit der Rate von 0,055 auf 0,953, weit über den Spannweiten). "Wie Batch 4" ist knapp verfehlt (+0,123 statt <= 0,074, aber 83 % des Nachteils geholt), und im fairen Vergleich bester gegen bester bleibt ein Rest von 0,248: auch der beste 1-Arbeiter-Lauf profitiert von höherer Rate. Für mehrere Arbeiter folgt: häufig mitteln UND die Rate anheben, den Materialnachteil macht das in diesem Bereich aber nicht wett.
  Offen: Noch höhere Rate, mehr Mittelungen, andere Arbeiterzahl, Mitteln der Adam-Momente; ein Knirps, ein Durchlauf.
  Datei: rechner-a:~/snai_pruef/knirps/mitteln/kriterium.txt
Chronik:
  2026-10-21 14:30 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/mitteln/kriterium.txt, NACHTRAG 2026-10-12 20:15 (nach Runde 2, vor Runde 3; Datei zuletzt 20:13:09 - Uhrzeit im Text auf die Viertelstunde gerundet).)
  2026-10-21 14:30 Rezept r69 (a1xg, a1yg, m1xg, m1yg, m64yg)
  2026-10-21 14:30 Status geplant -> laeuft (Rezept r69)
  2026-10-21 14:30 Messwerte m696-m704
  2026-10-21 14:30 Ergebnis e63: teilweise
  2026-10-21 14:30 Status laeuft -> ausgewertet (Ergebnis e63)
```
