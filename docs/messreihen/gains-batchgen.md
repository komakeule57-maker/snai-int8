# snai/gains-batchgen

```text
snai/gains-batchgen - ausgewertet, angelegt 2026-11-01, zuletzt 2026-11-04 08:22
Frage: Sinkt das Kippen der FFN-Gains, wenn von Anfang an mehr Fenster je Update gesammelt werden, und liegt das am Rauschen oder am Material?
Kriterium (festgelegt 2026-11-01 22:13, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/clip/kriterien_batchgen.txt. Saaten 4-11, 128x4, LR 0,003, 9.002 Updates, Arme k1, k4R, k4N, k16R. D = k1 - kx in L2 tot. SENKT: kx < k1 in >= 6/8 und mittleres D >= 20. KEINE WIRKUNG: mittleres D < 10. Sonst OFFEN, knapp 2 Punkte. k16R: D < 14 nicht vom Clip-Anteil trennbar. k4N gegen k4R fuers Material.
Plan: rechner-a:~/snai_pruef/clip/kriterien_batchgen.txt
Baut auf: snai/dauerclip-saaten, snai/wd-gains
Darauf baut: snai/tying-gains-lang, snai/gains-batchgen-null
Rezepte:
  r497 [2026-11-01] rechner-a: cd ~/snai_pruef/clip && setsid -f nohup ./schlange_bg.sh > log/schlange_bg.out 2>&1 < /dev/null (je Lauf BG_K=<k> CLIP_LR=0.003 CLIP_OHNE_LOCK=1 ./lauf_bg.sh batchgen <arm> - <s> daten/<datei>.txt 1000,3000)
      quelltext: proj_bs Lib dbbbf92d, lauf_bg.sh aus lauf_clip.sh per mach_lauf_bg.py
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/clip/log/schlange_bg.log, laeufe/batchgen/
      notiz: Startet nach SCHLANGE_BS_ENDE.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/clip/auswertung_bg/auswerten_a.py, bestand.jsonl, laeufe/batchgen/*/mess.jsonl
  m7540 K1 k1 s4 md5 gegen ee903784 | gleich (ee903784) | k1 | 4
  m7541 L2 tot Ende Mittel | 52,5 | k1 | 4-11 | 8
  m7542 L2 tot Ende Mittel | 41,7 | k4R | 4-11 | 8
  m7543 L2 tot Ende Mittel | 40,9 | k4N | 4-11 | 8
  m7544 L2 tot Ende je Saat s4-s11 | 79,7 0,8 22,7 49,2 61,7 59,4 60,2 85,9 | k1 | 4-11 | 8
  m7545 L2 tot Ende je Saat s4-s11 | 14,1 33,6 23,4 46,1 64,8 68,8 8,6 74,2 | k4R | 4-11 | 8
  m7546 L2 tot Ende je Saat s4-s11 | 1,6 14,8 4,7 71,1 36,7 85,2 21,1 92,2 | k4N | 4-11 | 8
  m7547 D = k1-kx Mittel, Median, Boot95, kx kleiner | 10,75; 1,20; -9,1 bis 33,4; 4/8 | k4R | 4-11 | 8
  m7548 D = k1-kx Mittel, Median, Boot95, kx kleiner | 11,53; 5,85; -9,6 bis 36,4; 4/8 | k4N | 4-11 | 8
  m7549 Material k4R-k4N Mittel, Median, Boot95, k4N kleiner | 0,77; 0,00; -12,6 bis 14,4; 4/8 | k4N | 4-11 | 8
  m7550 L2 tot t3000 groesster Wert | 1,6 | k1 | 4-11 | 8
  m7551 L2 tot t3000 groesster Wert | 0,8 | k4R | 4-11 | 8
  m7552 L2 tot t3000 groesster Wert | 0,8 | k4N | 4-11 | 8
  m7553 Held-out 700 Ende Mittel | 2,6842 | k1 | 4-11 | 8
  m7554 Held-out 700 Ende Mittel | 2,3222 | k4R | 4-11 | 8
  m7555 Held-out 700 Ende Mittel | 2,3064 | k4N | 4-11 | 8
  m7556 Held-out k4R-k4N Mittel | 0,0158 (8/8 k4N besser) | k4N | 4-11 | 8
  m7557 Clipanteil Trainingslog Mittel | 59,8 % | k1 | 4-11 | 8
  m7558 Clipanteil Trainingslog Mittel | 7,7 % | k4R | 4-11 | 8
  m7559 Clipanteil Trainingslog Mittel | 7,5 % | k4N | 4-11 | 8
  m7560 Fehlerkanal train.log verdaechtige Zeilen | 0 in 24 Laeufen | k1,k4R,k4N | 4-11 | 24
  m7561 Fehlerkanal mess.err | 72 Byte nur k4N s11: NET2NET-GUARD meldet, Waechter im Quelltext aus, keine Korrektur | k4N | 11
  Quelle: rechner-a ~/snai_pruef/clip: bestand.py (gradnorm/werkzeug) auf laeufe/batchgen/k16R_s4..s7, 2026-11-03 09:05, Zwischenstand; noch nicht an auswertung_bg/bestand.jsonl angehängt
  m8188 L2 rms_ffn tot am Ende je Saat s4-s7 (Schwelle 0,05, %) | 0,0 / 0,8 / 0,0 / 3,9 | k16R |  | 4
  m8189 FFN tot L0-L3 am Ende s4-s7 | s4 0/0/0/0, s5 0/0,8/0,8/0, s6 0/0/0/0, s7 0/0,8/3,9/0 | k16R |  | 4
  m8190 L2 tot an t1000 und t3000 s4-s7 | 0 in allen | k16R |  | 4
  m8191 D = k1 - k16R s4-s7 (Zwischenstand, kein Urteil) | 79,7 / 0,0 / 22,7 / 45,3, Mittel 36,9 | k16R |  | 4
  Quelle: rechner-a ~/snai_pruef/clip/auswertung_bg/ausgabe_k16R_20261104.txt (auswerten_a.py k16R, bestand.jsonl 96 Zeilen, k16R NUL-getrennt angehaengt 2026-11-04); Logs laeufe/batchgen/k16R_s*/train.log, mess.err
  m8648 L2 tot Ende Mittel | 7,8 | k16R | 4-11 | 8
  m8649 L2 tot Ende je Saat s4-s11 | 0,0 0,8 0,0 3,9 3,9 45,3 0,0 8,6 | k16R | 4-11 | 8
  m8650 D = k1-kx Mittel, Median, Boot95, kx kleiner | 44,64; 51,55; 25,0 bis 63,7; 7/8 (s5 gleich 0,8) | k16R | 4-11 | 8
  m8651 FFN tot L0, L1, L3 am Ende hoechster Wert | 0,0 / 0,8 / 0,0 | k16R | 4-11 | 8
  m8652 L2 tot t1000 und t3000 | 0 in allen | k16R | 4-11 | 8
  m8653 Held-out 700 Ende Mittel | 2,1585 | k16R | 4-11 | 8
  m8654 Held-out k1-k16R Mittel | 0,5257 (8/8) | k16R | 4-11 | 8
  m8655 Clipanteil Trainingslog Mittel | 1,4 % | k16R | 4-11 | 8
  m8656 GradNorm letzte 10 % Median, Mittel ueber Saaten | 1,042 / 0,725 / 0,700 / 0,582 (k1/k4R/k4N/k16R) | alle | 4-11 | 8
  m8657 Final-Gain Mittel Ende | 0,791 / 1,166 / 1,116 / 1,674 (k1/k4R/k4N/k16R) | alle | 4-11 | 8
  m8658 Kontrolle K2 | rc=0 8/8, STEPS_DONE 144.026, adam_t 9.002, [Sammeln] 16 Fenster, train.log verdaechtig 0, mess.err leer | k16R | 4-11 | 8
Ergebnis e517 [2026-11-04 08:22]: teilweise
  Fazit: Urteile je Arm nach Wortlaut:
- k16R SENKT: D 44,6 im Mittel, Median 51,6, Bootstrap-95 25 bis 64, kleiner in 7/8. s5 ist Gleichstand bei 0,8. Die Schwelle ist nicht knapp, und die Clip-Klausel (D < 14) greift nicht.
- k4R und k4N OFFEN, knapp an 10.
- Material (k4N gegen k4R): KEINE WIRKUNG.

Das Sterben der FFN-Gains ist also kein fester Teil des Modells. Mit 16 Fenstern je Update bleibt es fast ganz aus: L2 tot 7,8 % gegen 52,5 % bei k1, L0, L1 und L3 bei höchstens 0,8 %. Am Material liegt es nicht.

Die Aussage gilt bei gleicher Zahl an Updates. k16R rechnet 16-mal so viele Fenster, und der Held-out ist um 0,53 nats besser (8/8). Rauschen, Clip-Anteil (60 → 1,4 %) und Rechenmenge ändern sich gemeinsam.

Deutung, nicht gemessen:
- Clip ist als Hauptursache unwahrscheinlich. Die Arme k4 clippen schon nur noch 7,5 % der Schritte und verlieren trotzdem 41 %. Der Großteil der Wirkung liegt zwischen k4 und k16.
- Hier leben die Gains UND das Modell ist besser. Das ist der Gegensatz zu e512, wo das Festhalten der Gains schadete. Das passt zu „weniger Rauschen macht das Sterben überflüssig“.
- Die Final-Gain steigt mit k von 0,79 auf 1,67, das ist eine Beobachtung für die Norm-Frage.

Nächster sinnvoller Schritt ohne Training: Die k16R-Endstände durch Nullen messen, um zu sehen, ob die lebenden Zweige tragen. Nur mit Training ließe sich Rauschen von Rechenmenge trennen, mit k16R bei einem Sechzehntel der Updates.

Reichweite: 128x4 int8, ein Text, LR 0,003 konstant, 9.002 Updates, 8 Saaten, proj_bs dbbbf92d ohne die Reparaturen vom 03.11.
  Offen: Wie sich die Wirkung auf Rauschen und Rechenmenge verteilt, ob die Zweige in k16R tragen (Nullen) und ob das mit Eingangsfaktor und über 9.002 Updates hinaus gilt, bleibt offen. Ebenso, warum k4 kaum wirkt und k16 stark.
  Datei: rechner-a:~/snai_pruef/clip/ERGEBNIS_batchgen.md
Chronik (juengste 8 von 9, voll=True zeigt alle):
  2026-11-01 22:13 Rezept r497
  2026-11-01 22:13 Status geplant -> laeuft (Rezept r497)
  2026-11-02 14:08 Messwerte m7540-m7561
  2026-11-03 09:03 Messwerte m8188-m8191
  2026-11-03 09:03 2026-11-03 09:10: k16R s4-s7 fertig, s8 bei Schritt 130.000 von 144.026. s9-s11 laufen erst nach SCHLANGE_AC_ENDE (snai/adamc-dc hat auf rechner-a Vorrang), per schlange_bg3.sh 6d44205a. schlange_bg2.sh ist beendet, s8 läuft weiter. Nachtrag in kriterien_batchgen.txt, nur Rechnerlast. Erwartetes Ende in der Nacht zum 04.11. Zwischenstand ohne Urteil: In k16R sterben die Gains fast nicht (L2 0 bis 3,9 %). s5 kann nicht unter k1 liegen, weil k1 dort schon 0,8 hat; "kleiner in >= 6/8" verlangt also 6 von den übrigen 7 Saaten.
  2026-11-04 08:22 Messwerte m8648-m8658
  2026-11-04 08:22 Ergebnis e517: teilweise
  2026-11-04 08:22 Status laeuft -> ausgewertet (Ergebnis e517)
```
