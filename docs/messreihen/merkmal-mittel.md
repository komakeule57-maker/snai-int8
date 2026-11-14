# snai/merkmal-mittel

```text
snai/merkmal-mittel - ausgewertet, begonnen 2026-10-16, angelegt 2026-10-21, zuletzt 2026-10-21 14:30
Frage: Traegt die Variation der Merkmalsspalte c* der gebundenen int8-Embeddings (d96 Schach) ueber die Token Information, statt nur als Konstante zu wirken?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/diag/kriterien_mittel.txt, Kopf '2026-10-16, vor dem Lauf' (Laeufe 13:15-13:16)):
  Eingriff ohne Training: topmeanu = c* in den genutzten Zeilen (Ids 9-84) durch deren Mittelwert ersetzt; Bezug rein (Lade-Speicher-Zyklus), top0 (c* = 0, Rot-Probe), rand0 (Kontrolle), topmean (alle 87 Zeilen). Held-out-Loss (mess_text, heldout_gross, 300 Fenster) je Checkpoint gegen rein: topmeanu < 10 % -> c* wirkt als Konstante; >= 10 % -> die Variation traegt Tokeninformation. top0 muss den Loss um > 100 % treiben, sonst Messkette verdaechtig. Saaten uneinig -> saatabhaengig; s2 getrennt berichtet. Formfehler ohne Schwelle (Beobachtung).
Rezepte:
  r66 [2026-10-21] bash ~/snai_pruef/merkmal/diag/lauf_mittel.sh (cwd knirps/proj_neu; je Checkpoint und Modus: php diag/ablation_mittel.php <ckpt> <kopie> <modus>; php text/mess_text.php <kopie> gebiete/heldout_gross.txt gebiete/ngram_gross.json 300 0; ziehe_schach.php 500 1.0 4711; form_sonde.py)
      quelltext: diag/ablation_mittel.php 418a36b6 (Kopie von gebiete/ablation_spalte.php, assert-gepatcht), lauf_mittel.sh d29c8b7b, Engine proj_neu libcortex.so 51047037, Lade-Waechter aus
      parameter: Checkpoints proj_ow gross_gross_s1_s4, s1_s5, s1_s7, s3_s7, s2_s7; Modi rein, top0, rand0, topmean, topmeanu
      seed: Ziehung Saat 4711
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/diag/erg/mittel.log, diag/erg/*.abl/.err/.zieh, Kopien diag/ckpt/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/diag/erg/mittel.log (Skriptausgabe, abgelesen 2026-10-21)
  m653 Held-out-Loss rein | 1,3844 | s1_s4 | 1 | 1
  m654 Held-out-Loss topmeanu | 1,6015 (+16 %) | s1_s4 | 1 | 1
  m655 Held-out-Loss top0 (Rot) | 2,4278 (+75 %) | s1_s4 | 1 | 1
  m656 Held-out-Loss rein | 1,3922 | s1_s5 | 1 | 1
  m657 Held-out-Loss topmeanu | 1,6138 (+16 %) | s1_s5 | 1 | 1
  m658 Held-out-Loss top0 (Rot) | 5,6371 (+305 %) | s1_s5 | 1 | 1
  m659 Held-out-Loss rein | 1,3701 | s1_s7 | 1 | 1
  m660 Held-out-Loss topmeanu | 2,9798 (+117 %) | s1_s7 | 1 | 1
  m661 Held-out-Loss top0 (Rot) | 12,6444 (+823 %) | s1_s7 | 1 | 1
  m662 Held-out-Loss rein | 1,3805 | s3_s7 | 3 | 1
  m663 Held-out-Loss topmeanu | 3,6719 (+166 %) | s3_s7 | 3 | 1
  m664 Held-out-Loss top0 (Rot) | 13,616 (+886 %) | s3_s7 | 3 | 1
  m665 Held-out-Loss rein | 1,3433 | s2_s7 | 2 | 1
  m666 Held-out-Loss topmeanu | 8,2753 (+516 %) | s2_s7 | 2 | 1
  m667 Held-out-Loss top0 (Rot) | 3,5966 (+168 %) | s2_s7 | 2 | 1
  m668 Held-out-Loss rand0 (Kontrolle) | 1,3696-1,4178 (je Checkpoint unter +3 %) | alle 5 Saaten 1-3 |  | 5
  m669 Fehlerkanal stderr | 0 | alle 25 Laeufe |  | 25
Ergebnis e61 [2026-10-21 14:30]: erfuellt
  Fazit: c* ist keine Konstante: der Ersatz durch den Mittelwert kostet in allen fuenf Staenden und drei Saaten mindestens 16 % Loss. Ein gemeinsamer Float-Bias kann c* also nicht ersetzen, und eine Reparatur, die c* glaettet, ist ausgeschlossen. Welche Information c* traegt, sagt die Probe nicht; das klaeren snai/merkmal-gradzerl und snai/merkmal-biaskanal-wd0 (Haeufigkeits-Bias). 'Erfuellt' = die Frage ist nach der Regel klar entschieden ('traegt Tokeninformation').
  Offen: Rot-Probe bei s1_s4 verfehlt ihre Schwelle (+75 % statt > 100 %), der s1_s4-Punkt steht unter Vorbehalt. Die Formfehler der Eingriffe sind nicht deutbar: topmeanu s2_s7 (0 %, 1 Token je Zeile) und s1_s7 (10,6 %, 2,8 Token je Zeile) sind Messausfaelle, keine Verbesserungen.
  Datei: rechner-a:~/snai_pruef/merkmal/diag/kriterien_mittel.txt
Chronik:
  2026-10-21 14:29 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/diag/kriterien_mittel.txt, Kopf '2026-10-16, vor dem Lauf' (Laeufe 13:15-13:16))
  2026-10-21 14:29 Rezept r66
  2026-10-21 14:29 Status geplant -> laeuft (Rezept r66)
  2026-10-21 14:29 Messwerte m653-m669
  2026-10-21 14:30 Ergebnis e61: erfuellt
  2026-10-21 14:30 Status laeuft -> ausgewertet (Ergebnis e61)
```
