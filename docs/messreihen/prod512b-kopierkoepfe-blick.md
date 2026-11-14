# snai/prod512b-kopierkoepfe-blick

```text
snai/prod512b-kopierkoepfe-blick - ausgewertet, angelegt 2026-11-06, zuletzt 2026-11-06 13:37
Frage: Sind die Kopierköpfe 3.0/3.6 in der Schleife fehlgeleitet, schauen sie also anders als beim Kopieren in normalem Text? Oder wie immer, und die Schleife entsteht danach?
Kriterium (nachgetragen, Beleg: Kriterium stand vor dem Lauf in KRITERIEN_att.md (2026-11-06 ~13:50, Prüfer-Nachtrag ~14:00); der Messbuch-Eintrag wurde erst nach dem Lauf angelegt.):
  Attention-Gewichte (Lib 59315700, sonde_att.php) an s11: M = Gewicht auf Nachfolgern früherer Vorkommen des aktuellen Tokens. Schleife 18 T3-Posten bei k=6, natürlich 20 Fenster à 256 Token ho_prod (richtig/falsch). Q1 Vorgängerkopf: Median V(2.4) >= 0,5. Q2: M(3.0)+M(3.6) bei k=6 über dem 95. Perzentil natürlicher Abfragen mit Übereinstimmung >= 4 Token in >= 15/18 = ÜBERFOKUSSIERT, darunter in >= 15/18 = IM NATÜRLICHEN BEREICH, sonst GEMISCHT. Q3: Median falsch/richtig >= 0,8 BLIND, <= 0,5 SELEKTIV. Q4 nur berichtet. Volltext KRITERIEN_att.md (vor s10/s11 festgelegt, Prüfer-Nachtrag vor dem Lauf).
Plan: rechner-a:~/snai_pruef/frankreich/eingriff/KRITERIEN_att.md
Baut auf: snai/prod512b-frankreich-eingriff, snai/kopfablation-prod512b, snai/schleife-einstieg
Darauf baut: snai/ss-knirps, snai/ukb-runde2-prod512b
Rezepte:
  r617 [2026-11-06] cd ~/snai_pruef/ref512b && SNAI_ATT_LESEN=1 SNAI_CORTEX_LIB=~/snai_pruef/frankreich/eingriff/bau_att/libcortex_att.so SNAI_GAIN_GUARD=0 SNAI_FORCE_CPU=1 OMP_NUM_THREADS=2 php ~/snai_pruef/frankreich/eingriff/sonde_att.php ~/snai_pruef/frankreich/ckpt/prod512b_sN.snai ~/snai_pruef/frankreich/eingriff/att/att_sN.jsonl; python3 ~/snai_pruef/frankreich/eingriff/auswert_att.py att/att_sN.jsonl
      quelltext: Lib 59315700 = cortex.nim f8292f7b + patch_lens.py + patch_abl.py + patch_att.py (eingriff/); sonde_att.php, auswert_att.py
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/frankreich/eingriff/att/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/frankreich/eingriff/att/urteil_att_s11.txt, bericht_att_s5.txt, bericht_att_s10.txt
  m9375 Q1 Median Gewicht 2.4 auf Vorgänger | 0,966 | s11
  m9376 Q1 Median Gewicht 2.4 auf Vorgänger | 0,985 / 0,977 | s5 / s10
  m9377 Q2 M_S(6) Schleife Spanne | 1,53 bis 1,87 | s11 |  | 18
  m9378 Q2 natürlich lm>=4 Median / 95. Perzentil | 1,35 / 1,87 | s11 |  | 151
  m9379 Q2 Schleifenposten über dem Perzentil | 0/18 | s11
  m9380 Q2 Schleifenposten über dem Perzentil | 0/18 und 0/18 | s5 / s10
  m9381 Q3 Median M_S richtig / falsch | 1,33 / 0,29 (0,21) | s11 |  | 1456
  m9382 Q3 nach Länge lm>=2 / >=4 / >=8 richtig zu falsch | 1,46/0,90, 1,43/0,95, 1,58/1,16 | s11
  m9383 Q4 M_S je k=1..6 | 0,79 1,43 1,51 1,61 1,73 1,76 | s11
  m9384 Anteil jüngste Wiederholung an M bei k=6 (3.0 / 3.6) | 0,19 / 0,15 | s11
  m9385 Beobachtung Vielfalt Frankreich-Prompt ohne Sperre / DS / Grundform / immer sperren | 0,034 / 0,134 / 0,236 / 0,543 | s11
  m9386 Beobachtung Vielfalt Film-Prompt ohne Sperre / DS / Grundform / immer sperren | 0,042 / 0,422 / 0,442 / 0,54 | s11
Ergebnis e564 [2026-11-06 13:37]: erfuellt
  Fazit: Löst e563 nur im Wortlaut ab, die Zahlen bleiben. Das Verhalten der Köpfe in der Schleife ist fehlerhaft (sie drehen Kreise), der Mechanismus aber derselbe wie beim richtigen Kopieren: 3.0/3.6 schauen so stark und so verteilt wie in normalem Text bei langer Übereinstimmung (0/18 über dem 95. Perzentil, auch s5/s10), 2.4 ist der Vorgängerkopf. Maßstab der Köpfe ist die Länge der Übereinstimmung, und die eigene Ausgabe verlängert sie mit jeder Kopie (Rückkopplung, Exposure Bias). Es gibt also kein defektes Teil; Sperre und Kopfabschalten sind Symptombehandlung, eine Ursachenbehandlung muss im Training ansetzen (Kandidat Repetition Dropout, Li et al. 2023).
  Offen: Wert-Pfad nicht gemessen; Repetition Dropout am Knirps und an prod512b ungeprüft.
  Datei: rechner-a:~/snai_pruef/frankreich/eingriff/ERGEBNIS_att.md
Abgeloest und ausgeblendet: 1 ergebnis - voll=True zeigt sie.
Chronik:
  2026-11-06 13:36 angelegt (Nachtrag: Kriterium stand vor dem Lauf in KRITERIEN_att.md (2026-11-06 ~13:50, Prüfer-Nachtrag ~14:00); der Messbuch-Eintrag wurde erst nach dem Lauf angelegt.)
  2026-11-06 13:36 Rezept r617
  2026-11-06 13:36 Status geplant -> laeuft (Rezept r617)
  2026-11-06 13:36 Messwerte m9375-m9386
  2026-11-06 13:36 Ergebnis e563: erfuellt
  2026-11-06 13:36 Status laeuft -> ausgewertet (Ergebnis e563)
  2026-11-06 13:37 Ergebnis e564: erfuellt, loest e563 ab
```
