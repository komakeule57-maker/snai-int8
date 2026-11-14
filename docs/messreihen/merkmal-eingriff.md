# snai/merkmal-eingriff

```text
snai/merkmal-eingriff - ausgewertet, begonnen 2026-10-17, angelegt 2026-10-21, zuletzt 2026-10-21 14:35
Frage: Verursacht der c*-Beitrag zu den Logits die Formfehler? Eingriff am Gain der finalen RMSNorm an c* (Ablation, Halbierung, Inversion) in Checkpoint-Kopien ohne Training.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/eingriff/kriterien_eingriff.txt, Kopf '2026-10-17, VOR der Messung', Nachtrag mit Auditor B vor der Messung (Messung 09:53-10:00)):
  Nur kranke Staende (orig s1_s5, s1_s7, s3_s5, s3_s7): KAUSAL GESTUETZT = 'null' (g_c* = 0) senkt F in ALLEN VIER unter 5 % UND jede Kontrolle (Nachtrag: k_zweit_null, k_zweit_inv, k_rausch_null, k_rausch_inv, k_zufA_null) laesst F dort >= 15 %. NICHT GESTUETZT = 'null' laesst F in allen vier >= 15 %. Sonst kein Urteil. L unter 'null' > +50 % -> 'F gesenkt, aber Modell beschaedigt'. Inversion und gesunde Staende berichtet, kein Urteil. Geraetepruefung: basis reproduziert F exakt.
Baut auf: snai/merkmal-biasalle
Darauf baut: snai/merkmal-logitbias
Rezepte:
  r113 [2026-10-21] python3 ~/snai_pruef/merkmal/eingriff/eingriff.py (Kopien je Stand und Arm in eingriff/kopien/), Messung eingriff/messe.sh
      quelltext: eingriff.py c416f186, eingriff/messe.sh 3d42db62
      parameter: Staende krank orig s1_s5, s1_s7, s3_s5, s3_s7; gesund orig s1_s4, s2_s7, SPAET s1_s7; 9 Arme
      seed: Ziehung 4711; Zufallsspalte Saat 4711
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/eingriff/mess_*.jsonl, auswertung.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/eingriff/auswertung.txt (abgelesen 2026-10-21)
  m1160 F null (basis) | 64,0 % (28,4) | null Original Stand s5 | 1 | 500
  m1161 F null (basis) | 42,2 % (32,8) | null Original Stand s7 | 1 | 500
  m1162 F null (basis) | 98,2 % (37,2) | null Original Stand s5 | 3 | 500
  m1163 F null (basis) | 92,6 % (36,4) | null Original Stand s7 | 3 | 500
  m1164 F null | 96,9 / 99,8 / 99,4 % | null (gesund orig s1_s4, s2_s7, SPAET s1_s7) |  | 3
  m1165 L null | 1,648 / 2,655 / 2,168 / 3,071 | null (krank s1_s5/s1_s7/s3_s5/s3_s7) |  | 4
  m1166 F halb | 28,0 / 45,2 / 51,4 / 54,8 % | halb (krank) |  | 4
  m1167 F halb | 1,0 / 0,6 / 0,0 % | halb (gesund) |  | 3
  m1168 F k_rausch_null / inv | 29,0-39,4 % | Kontrolle (krank) |  | 8
  m1169 F k_zweit_null | 84,3-97,2 % | Kontrolle (krank) |  | 4
  m1170 F inv | 99,6 % (n 500), sonst n = 0 | inv (krank) |  | 4
  m1171 Geraetepruefung basis = bekanntes F | ja (7/7) | basis (alle) |  | 7
Ergebnis e107 [2026-10-21 14:35]: verfehlt
  Fazit: Nach Regel nicht gestuetzt: c* am Ausgang abschalten repariert nichts (42-98 %). Genauer ist aber, dass der Eingriff die Frage nicht entscheiden kann: der Gain an c* ist fuer JEDES Modell tragend (gesunde Staende gehen auf 97-99,8 %), Abschalten entfernt mehr als den Haeufigkeitsanteil. Widerlegt ist nur 'c* abschalten heilt'. Ein spezifischer Test braucht einen Logit-Term je Token; der wurde mit snai/merkmal-logitbias als trainierbarer Bias versucht.
  Offen: Haeufigkeitsanteil allein entfernen (Engine hat keinen Logit-Term je Token). Unter 'halb' steigt F in krank s1_s5 nicht (28,4 -> 28,0).
  Datei: rechner-a:~/snai_pruef/merkmal/eingriff/kriterien_eingriff.txt
Chronik:
  2026-10-21 14:34 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/eingriff/kriterien_eingriff.txt, Kopf '2026-10-17, VOR der Messung', Nachtrag mit Auditor B vor der Messung (Messung 09:53-10:00))
  2026-10-21 14:35 Rezept r113
  2026-10-21 14:35 Status geplant -> laeuft (Rezept r113)
  2026-10-21 14:35 Messwerte m1160-m1171
  2026-10-21 14:35 Ergebnis e107: verfehlt
  2026-10-21 14:35 Status laeuft -> ausgewertet (Ergebnis e107)
```
