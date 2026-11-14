# snai/gains-spalten

```text
snai/gains-spalten - ausgewertet, angelegt 2026-11-01, zuletzt 2026-11-01 22:07
Frage: Haben Kanaele mit toter Pre-FFN-Gain auch kleine Spalten in w_up, wie die Kopplung gamma^2 - ||w||^2 = konstant aus Wang et al. 2026 (arXiv:2605.26895) vorhersagt?
Kriterium (festgelegt 2026-11-01 22:07, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/clip/kriterien_spalten.txt, ohne Lauf. V = Median Spalten-RMS tote / lebende Kanaele, L2, Endstand, Arme K1, W0, AUS, Saaten 4-11, auswertbar >= 10 tote und >= 10 lebende. Je Arm, alle auswertbaren bis auf hoechstens eine: KOPPLUNG V <= 0,5; KEINE V >= 0,8; sonst OFFEN; < 3 auswertbare keine Aussage; +-0,05 knapp. W0 entscheidet, weil unter WD eine tote Spalte von selbst schrumpft. Vor der Auswertung gesehen: K1 s4 V 0,605.
Plan: rechner-b:~/snai_pruef/clip/kriterien_spalten.txt
Baut auf: snai/wd-gains, snai/dauerclip-saaten
Darauf baut: snai/gains-ueberlebende
Rezepte:
  r496 [2026-11-01] rechner-b: cd ~/snai_pruef/clip/proj_clip && php ../werkzeug/spalten.php ../laeufe/<reihe>/<Arm>_s<S>/factory/checkpoints/clip_s<S>.snai >> ../log/spalten.jsonl
      quelltext: spalten.php f89ac39f, kriterien_spalten.txt b68c74d5
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/clip/log/spalten.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/clip/log/spalten.jsonl. Rot: Spalten genullt V 0; blind markiert V 0,99 / 1,05.
  m7296 V L2 auswertbar s4,6,7,8,9,10,11 | 0,605 / 0,568 / 0,692 / 0,655 / 0,543 / 0,636 / 0,639 | K1
  m7297 V L2 auswertbar s7,8,9,11 | 0,555 / 0,540 / 0,650 / 0,624 | W0
  m7298 V L2 auswertbar s4,5,6,7,8,9,11 | 0,432 / 0,460 / 0,511 / 0,473 / 0,563 / 0,477 / 0,492 | AUS
  m7299 Spalten-RMS tot / lebend, Median der Mediane | K1 0,0316-0,047 / 0,041-0,083; W0 0,055-0,074 / 0,090-0,136 | K1,W0
Ergebnis e432 [2026-11-01 22:07]: keine_aussage
  Fazit: Nach Regel OFFEN in K1, W0 und AUS: V liegt bei 0,43-0,69, also weder V <= 0,5 noch >= 0,8 im verlangten Umfang. Die Richtung ist in allen Armen gleich, tote Kanaele haben rund 40 % kleinere Spalten, auch ohne WD. Aber die Gain faellt um mehr als das 20-Fache, die Spalte nur um rund das 1,6-Fache: Ein gemeinsames Verschwinden von Skala und Spalte, wie es die Kopplung bei vollem Kollaps verlangte, liegt nicht vor. Die Gain stirbt weitgehend allein (Deutung).
  Offen: Reihenfolge Gain gegen Spalte im Verlauf, Spaltenwert beim Tod; Wang-Theorie gilt nur fuer Gradientenfluss, die Vorhersage ist unsere Ableitung.
  Datei: rechner-b:~/snai_pruef/clip/kriterien_spalten.txt
Chronik:
  2026-11-01 22:07 angelegt
  2026-11-01 22:07 Rezept r496
  2026-11-01 22:07 Status geplant -> laeuft (Rezept r496)
  2026-11-01 22:07 Messwerte m7296-m7299
  2026-11-01 22:07 Ergebnis e432: keine_aussage
  2026-11-01 22:07 Status laeuft -> ausgewertet (Ergebnis e432)
```
