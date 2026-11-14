# snai/gains-ueberlebende

```text
snai/gains-ueberlebende - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 13:26
!! ohne Kriterium
Frage: Welche Kanaele ueberleben das Kippen der FFN-Gains (c128sr L1: 12 von 128), und was unterscheidet sie von den toten? Wunsch 2026-11-02.
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Baut auf: snai/gains-kanalindex, snai/gains-spalten
Darauf baut: snai/tote-spalten-wachsen
Rezepte:
  r510 [2026-11-02] ueberleb.php <stand> (Gains, Spaltennormen w_up/q/k/v je Eingangskanal, Zeilennormen w_down/w_o je Ausgangskanal, Embedding-Spalten-RMS; dequantisiert, nur lesen) an chin_c128sr s0, s3, s9 und an Clip-Endstaenden K1 s4/s7/s8/s11, W0 s4, K1 s4 t3000; Auswertung in Python (Raenge, Spearman)
      quelltext: rechner-a:~/snai_pruef/kanal/ueberleb.php
      rechner: rechner-a, Clip-Staende auf rechner-b gelesen
      logs: rechner-a:~/snai_pruef/kanal/ (ueberleb_s*.json, ub_*.json)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: kanal/ueberleb_s*.json, ub_*.json; lebend = |g| >= 0,05; Rang 1 = groesster von 128
  m7477 L1.ffn lebend s0 / s3 / s9 | 41 / 13 / 12 | c128sr
  m7478 Ueberlebende s9 | 5 8 15 21 25 27 30 51 64 66 86 107 | c128sr L1
  m7479 zwischen s3 und s9 zurueckgekehrt / gestorben | 5 (21 25 27 30 51) / 6 (1 12 31 32 48 82) | c128sr L1
  m7480 Gain der Ueberlebenden s9 | 0,10 bis 3,76, Median 0,67 | c128sr L1
  m7481 Rang w_up-Spaltennorm der Ueberlebenden s9 | 115 bis 128 von 128 (alle unter den 14 kleinsten) | c128sr L1
  m7482 Rang w_up-Spaltennorm derselben Kanaele s0 / s3 | 25-128 gemischt / 4-124 gemischt | c128sr L1
  m7483 w_up-Spaltennorm Median Ueberlebende / tote s9 | 0,28 / 1,53 | c128sr L1
  m7484 w_up-Spaltennorm Median aller Kanaele L1 s0 / s3 / s9 | 0,92 / 0,91 / 1,49 (LR 1e-3 / 1e-3 / 5e-5) | c128sr
  m7485 Spearman(Gain, w_up-Spaltennorm) Clip-Endstaende L2 | 0,55 / 0,69 / 0,70 / 0,68 / 0,80 | K1 s11, s4, s7, s8, W0 s4
  m7486 Rang der Ueberlebenden s9 in L2.att-Gain / L3.ffn-Gain / L1.k-Spalte / L1.w_down-Zeile | 1-4 fuer 4 von 12 / 1-7 fuer 4 / 1-4 fuer 4 / 1-5 fuer 5 | c128sr
  m7487 Rang der Ueberlebenden in Embedding-Spalten-RMS | 4 bis 126, gemischt | c128sr
  m7488 Kopfzugehoerigkeit (16 je Kopf) | Koepfe 0 1 3 4 5 6 | c128sr
Ergebnis e444 [2026-11-02 13:26]: beobachtung
  Fazit: Tot ist nicht endgueltig: zwischen s3 und s9 kehren 5 Kanaele zurueck und 6 sterben, bei Revival aus. Die Ueberlebenden sind keine feste Startmenge, sondern die Kanaele, die der FFN zuletzt liest; nach langem Lauf tragen ihre Gains die Skala (bis 3,8) und ihre w_up-Spalten sind die kleinsten (Decay auf Gewichte, keiner auf Gains). Kurze Laeufe zeigen das Gegenteil (lebende Kanaele mit groesseren Spalten): die kleine Spalte ist Folge, nicht Vorbedingung. Die Ueberlebenden sind tendenziell Kanaele, die auch andere Schichten stark gewichten; der FFN liest und schreibt dieselben Kanaele.
  Offen: Warum die w_up-Spalten toter Kanaele bei fallender LR von 0,9 auf 1,5 wachsen (Gradient nahe 0, Decay 0,1), ist nicht erklaert. Ein Modell, eine Saat; Deutungen ohne Kriterium.
Chronik:
  2026-11-02 13:24 angelegt
  2026-11-02 13:26 Rezept r510
  2026-11-02 13:26 Status geplant -> laeuft (Rezept r510)
  2026-11-02 13:26 Messwerte m7477-m7488
  2026-11-02 13:26 Ergebnis e444: beobachtung
  2026-11-02 13:26 Status laeuft -> ausgewertet (Ergebnis e444)
```
