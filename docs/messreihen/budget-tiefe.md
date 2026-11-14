# snai/budget-tiefe

```text
snai/budget-tiefe - ausgewertet, angelegt 2026-11-03, zuletzt 2026-11-03 10:23
Frage: Wächst der Nutzen der Schichten 3 und 4 mit dem Trainingsbudget? 128x4 gegen 128x2 bei 9.000 bis 27.000 Schritten in 8 Bit. Folge zu snai/tiefe-128x2-massstab, dort waren es +0,0347 bei 9.002 Schritten. Auftrag 2026-11-03: „Budget-Reihe nach den heutigen Ergebnissen“.
Kriterium (festgelegt 2026-11-03 05:22, vor dem ersten Messwert):
  Arme:
- T2 = 128x4 aus snai/tying-gains-lang. Diese Läufe sind schon gerechnet und werden nicht neu gestartet.
- Z2L = 128x2, neu. Genesis clip_gen_z2_s<s>, md5-gleiche Kopie aus clip_lns.
Rezept für beide gleich: voll int8, SR, Clip 1, LR 0,003 konstant (im Log geprüft: LR 0,003 an adam_t 9000, 18000 und 27018), WD 0,1, Warmup 500, gebunden. Karte rechner-b (CLIP_GPU=1), Bibliothek clip/proj_clip ccb10b0f. Text kurz27000.txt, eine Epoche, 27.018 Schritte. Snapshots 9000, 13500, 18000, 22500 und Ende. Saaten 4-11.
Fensterfolge: Sie hängt am Sitzungsnamen clip_s<s>, der in beiden Armen gleich ist. Die Folge ist also gleich, die Gewichte sind nicht gepaart.
Budget b heißt: Stand nach b Schritten dieses Laufs. Bei konstanter LR ist das bis auf die Datenauswahl gleich einem Lauf mit b Schritten.
Messung: mess_text.php, Held-out 700 Fenster, je Stand.
Hauptgröße: G = Z(Ende) - Z(9000), mit Z(b) = L(Z2L,b) - L(T2,b) je Saat. Positives Z heißt, die Tiefe nützt.
- TIEFE GEWINNT MIT BUDGET: Mittel G >= +0,02 UND G > 0 in >= 6/8.
- KEIN BUDGETEFFEKT: |Mittel G| < 0,01 UND |G| < 0,02 in >= 6/8.
- TIEFE VERLIERT MIT BUDGET: Mittel G <= -0,02 UND G < 0 in >= 6/8.
- Sonst saatabhängig, trägt keinen Schluss.
Liegt ein Wert innerhalb 0,003 um eine Schwelle, ist sie nicht erfüllt. Dann gepaarter Bootstrap und Wiederholung auf heldout2.
Größe nach Hausregel: Z wird auch relativ in % von L(T2) berichtet, unter 10 % ist es ein Gleichstand der Größe nach. Das Urteil oben bewertet die Richtung.
Beobachtung ohne Urteil: Z an allen fünf Ständen, tote Gains je Schicht (Schwelle 0,05) in T2 und Z2L je Stand, Rechenzeit je Lauf. Z(9000) gegen +0,0347 aus dem 9k-Lauf (andere Daten, CPU, andere Bibliothek, daher nur Einordnung).
Gemeinsam verändert zwischen den Ständen: Schrittzahl und gesehene Datenmenge, denn der Text wird nicht wiederholt. Ein Budgeteffekt heißt hier deshalb „mehr Schritte mit frischen Daten“ und trennt Schritte nicht von Daten.
Zwischen den Armen verändert: Tiefe und mit ihr Parameterzahl und Rechenzeit.
Größter freier Parameter: das höchste Budget von 27.018 Schritten, festgelegt durch die vorhandene Textlänge. Ein „kein Effekt“ gilt nur bis 3x.
Kontrollen: rc=0, STEPS_DONE 27018, Fehlerkanal je Lauf, Messung meldet layers 2 (Abbruch sonst), Tying-Zeile, LR am Ende 0,003.
Baut auf: snai/tiefe-128x2-massstab, snai/tying-gains-lang
Darauf baut: snai/tiefe-budget-r
Rezepte:
  r549 [2026-11-03] rechner-b ~/snai_pruef/clip/reihe_budget.sh (wartet auf TEE_ENDE in clip_torch/log/lauf.log, REIHE_ENDE von reihe_tie2 und freie Karte) -> je Saat 4-11 nacheinander: CLIP_GPU=1 CLIP_LR=0.003 CLIP_OHNE_LOCK=1 CLIP_TIE=1 CLIP_GENPFX=z2_ ./lauf_clip_ub.sh reihe_budget Z2L - <s> daten/kurz27000.txt 9000,13500,18000,22500 (lauf_clip_ub.sh = lauf_clip_u.sh mit einer Aenderung: Genesis-Praefix). Log log/reihe_budget.log, Laeufe laeufe/reihe_budget/Z2L_s<s>. Gegenarm T2: laeufe/reihe_tie2/T2_s<s> (vorhanden).
Messwerte (Groesse | Wert | Arm | Start | n):
  m8208 Z mittel 9000 | +0.0393 | Z2L-T2 | s4-11 | 8
  m8209 Z mittel 13500 | +0.0551 | Z2L-T2 | s4-11 | 8
  m8210 Z mittel 18000 | +0.0539 | Z2L-T2 | s4-11 | 8
  m8211 Z mittel 22500 | +0.0594 | Z2L-T2 | s4-11 | 8
  m8212 Z mittel 27018 | +0.0514 | Z2L-T2 | s4-11 | 8
  m8213 G mittel | +0.0121 | Z(Ende)-Z(9000) | s4-11 | 8
  m8214 G s4..s11 | +0.0452 +0.0153 +0.0058 -0.0036 +0.0140 -0.0200 +0.0203 +0.0199 | G | s4-11 | 8
  m8215 G Bootstrap 95 | -0.0003 bis +0.0244 | G | s4-11 | 8
  m8216 FFN L1 tot Ende Z2L % | 0-5.5 | Z2L | s4-11 | 8
Ergebnis e494 [2026-11-03 10:23]: keine_aussage
  Fazit: Nach Wortlaut ist das Ergebnis saatabhängig und trägt keinen Schluss.

Befund:
- G = Z(Ende) − Z(9000) liegt im Mittel bei +0,0121, in 6/8 Saaten positiv. Der Bootstrap reicht von −0,0003 bis +0,0244.
- GEWINNT verlangt Mittel ≥ 0,02 und ist verfehlt. KEIN BUDGETEFFEKT verlangt |Mittel| < 0,01 und ist ebenfalls verfehlt.

Beobachtung:
- 128x4 schlägt 128x2 an allen fünf Ständen in 8/8 Saaten.
- Z liegt bei +0,039 (9000), +0,055, +0,054, +0,059 und +0,051 (27018), relativ 1,5-2,3 %. Nach der Hausregel ist das der Größe nach ein Gleichstand, die Richtung ist eindeutig.
- Z wächst von 9.000 auf 13.500 Schritte und bleibt danach flach.
- Z(9000) mit +0,039 passt zu den +0,0347 aus dem 9k-Lauf.
- Tote FFN-Gains in Z2L (128x2, gebunden) am Ende: L0 0 %, L1 0-5,5 %. In T2 (128x4, gebunden) ist L2 zu 98,9 % tot. Das Absterben braucht also Bindung UND eine mittlere Schicht.
- Bei Z2L ist Attention L0 am Ende zu 5-22 % tot.

Deutung, nicht gemessen: Die zusätzliche Tiefe trägt rund 2 % und wächst über 13.500 Schritte hinaus kaum. Bei T2 kommt der Beitrag nicht aus den mittleren FFN, die sind tot und nach e485 entbehrlich. Er kommt aus Attention und den äußeren Schichten.

Reichweite: kurz27000, K1-Rezept ohne Embedding-Faktor, ein Text, eine Epoche, bis 3x Budget.
Chronik:
  2026-11-03 05:22 angelegt
  2026-11-03 05:22 Rezept r549
  2026-11-03 05:22 Status geplant -> laeuft (Rezept r549)
  2026-11-03 10:23 Messwerte m8208-m8216
  2026-11-03 10:23 Ergebnis e494: keine_aussage
  2026-11-03 10:23 Status laeuft -> ausgewertet (Ergebnis e494)
```
