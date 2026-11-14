# snai/kopier-att-kollaps

```text
snai/kopier-att-kollaps - ausgewertet, angelegt 2026-11-04, zuletzt 2026-11-04 09:15
Frage: Kollabiert in den Kopier-Läufen Breite 64, die bei LR 0,001 nicht lernen, die Attention (Attention-Gains, QK- oder OV-Kopplung je Kopf), während sie in den lernenden Läufen (LR 0,0005/0,0003) erhalten bleibt? Prüft die Vermutung, dass dieselbe Ursache wie beim Absterben der FFN-Gains (Rauschen mal LR gegen ein spätes Signal) auch das Kopieren verhindert.
Kriterium (festgelegt 2026-11-04 09:13, vor dem ersten Messwert):
  Volltext rechner-a:~/snai_pruef/kopier_att/KRITERIEN.md (vor jedem Messwert, Prüfer Gemini/Mistral eingearbeitet). Kurz:
- Material: vorhandene Stände, A = 0,001 WD 0,1 (6, 0 gelernt), B = 0,001 WD 0 (4, 0 gelernt), C = 0,0005 (6, alle gelernt), D = 0,0003 (6, alle gelernt). 64/2 und 64/8, 2 Schichten, var, 24 Segmente.
- Werkzeug att.php ohne Lader/Wächter. att_tot (|g| < 0,05), r = QK/QK_Genesis, ov = OV/OV_Genesis, je Kopf, Median je Schicht.
- KOLLAPS je Lauf am Ende: att_tot ≥ 12,5 % oder r_med < 0,25 oder ov_med < 0,25 in einer Schicht.
- Urteile:
  1. KOLLABIERT BEI NICHTLERNERN: ≥ 8/10 A∪B UND ≥ 3/4 B UND ≤ 2/12 C∪D.
  2. KEIN KOLLAPS: ≤ 2/10 A∪B. Das widerlegt „gleiche Ursache“ für diese Läufe.
  3. NUR DECAY: ≥ 5/6 A UND ≤ 1/4 B.
  4. Sonst OFFEN.
- Eichung: ffn_tot L0 Ende gibt e42 wieder.
- Rot: g × 0,01, falsche Kopfzahl.
- Beobachtung, nicht Ursache: LR ändert zugleich das Lernen.
Rezepte:
  r572 [2026-11-04] rechner-a ~/snai_pruef/kopier_att/lauf.sh (att.php je Stand s4/s23 gegen Genesis, cwd Projektkopie), python3 ausw.py --urteil
Messwerte (Groesse | Wert | Arm | Start | n):
  m8682 Kontrolle Genesis gegen Genesis r und ov | 1 in allen Köpfen | Gerät
  m8683 Rot g x 0,01 | att_tot 100 %, r 1e-4, ov 0,01 (Vorhersage 1e-8 falsch hergeleitet, richtig g²) | Gerät
  m8684 Rot falsche Kopfzahl r_med L0 | 1,20 statt 2,19 | A 64/2 s1
  m8685 Eichung ffn_tot L0 Ende | A s1/s2 100 % in 4/4, B 0 bis 10,9 % (wie e42) | A, B
  m8686 KOLLAPS-Zählung Ende nach Wortlaut | A 3/6, B 0/4, C 6/6, D 4/6 | alle | s23 | 22
  m8687 KOLLAPS-Zählung ohne OV-Bedingung | A 2/6 (att_tot L1 52 / 45 %), B 0/4, C 0/6, D 0/6 | alle | s23 | 22
  m8688 OV L0 Median Ende | 0,10 bis 0,26 | C, D | s23 | 12
  m8689 QK L1 Median Ende | 4,96 bis 8,66 | C, D | s23 | 12
  m8690 QK L1 Median Ende | 0,63 bis 2,56, Ausnahme 64/2 s1 6,93 (der 85-%-Lauf) | A | s23 | 6
  m8691 OV L1 Median Ende | 0,21 bis 0,68, Ausnahme 64/2 s1 1,30 | A | s23 | 6
  m8692 QK und OV Median Ende | QK 1,25 bis 18,5, OV 4,3 bis 45 | B | s23 | 4
  m8693 QK L1 Median s4 | Lerner 64/2 4,3 bis 4,6, A 64/2 s2/s3 1,1 bis 1,3, A 64/2 s1 7,3 | A, C, D | s4
Ergebnis e520 [2026-11-04 09:15]: keine_aussage
  Fazit: Nach Wortlaut OFFEN (KOLLAPS A 3/6, B 0/4, C 6/6, D 4/6). Lücke: Die nach dem Prüfer ergänzte OV-Bedingung schlägt bei den Lernern an, weil OV in L0 beim Lernen normal auf 0,10-0,26 schrumpft. Zweite Lesart ohne OV: A∪B 2/10, C∪D 0/12, also KEIN KOLLAPS. Beide Lesarten stehen nebeneinander.
Sauberer Teil, unabhängig vom Wortlaut: B (LR 0,001 ohne Decay) kollabiert in keiner Größe und lernt trotzdem nicht. Das Nichtlernen hat also nicht die Gestalt „Teil auf null gezogen“.
Den Nichtlernern fehlt die QK-Kopplung in L1 (Lerner 5-9 x Genesis, A 0,6-2,6 x). Der einzige A-Lauf mit Lerner-Muster ist der 85-%-Lauf.
Ohne Decay wachsen QK und OV ungeordnet (bis 18 x bzw. 45 x).
Deutung, nicht gemessen: Rauschen mal LR zeigt sich hier als Drift, nicht als Kollaps. Die gemeinsame Wurzel mit dem FFN-Gain-Sterben bleibt möglich, ist aber nicht isoliert.
Chronik:
  2026-11-04 09:13 angelegt
  2026-11-04 09:15 Rezept r572
  2026-11-04 09:15 Status geplant -> laeuft (Rezept r572)
  2026-11-04 09:15 Messwerte m8682-m8693
  2026-11-04 09:15 Ergebnis e520: keine_aussage
  2026-11-04 09:15 Status laeuft -> ausgewertet (Ergebnis e520)
```
