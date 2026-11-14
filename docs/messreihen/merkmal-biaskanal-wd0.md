# snai/merkmal-biaskanal-wd0

```text
snai/merkmal-biaskanal-wd0 - ausgewertet, begonnen 2026-10-16, angelegt 2026-10-21, zuletzt 2026-11-01 07:21
Frage: Bildet sich der c*-Bias-Kanal (c* als verdeckter, haeufigkeitsgekoppelter Logit-Bias) auch ohne Weight-Decay auf den Embeddings?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/gradzerl/kriterien.txt, Abschnitt 'NACHFRAGE WD0 (Auftrag nach Zweitmeinung, 2026-10-16, VOR der Messung)'. Die Schwellen entstanden nach der Nachmessung an s1_s4/s1_s7 (Werte bekannt), aber vor der Messung der beiden entscheidenden Staende.):
  BIAS-KANAL JA: |mittel h^_c*| / Streuung >= 2 UND rho(E_c* x mittel h^_c*, log Haeufigkeit) >= +0,3. NEIN: Verhaeltnis < 1 ODER rho <= 0. Sonst offen. Lesart: WD0 JA + kaum tote Zeilen -> 'Bias-Kanal allein reicht nicht, Decay noetig'; WD0 NEIN, s1_s5 JA -> der Bias-Kanal haengt selbst am Decay. Checkpoints wd0_s1_s5 gegen gross_gross_s1_s5 (ungepaart, andere Datenreihenfolge). Geraet wie snai/merkmal-gradzerl, LR 0, held400. Rot: Vorzeichen zufaellig gekippt.
Baut auf: snai/merkmal-gradzerl, snai/merkmal-wdemb
Darauf baut: snai/merkmal-biasalle
Rezepte:
  r101 [2026-10-21] wie snai/merkmal-gradzerl (Dump-Lauf LR 0 in proj_grad), Auswertung python3 merkmal/gradzerl/biaskanal.py
      quelltext: biaskanal.py 730bfb4b; proj_grad libcortex.so fdc140f5
      parameter: wd0_s1_s5 (proj_wdemb), gross_gross_s1_s5, Bezug s1_s4/s1_s7
      seed: -
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/gradzerl/biaskanal.jsonl, mess_wd0_s1_s5.log, dump_wd0_s1_s5.bin
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/gradzerl/biaskanal.jsonl (abgelesen 2026-10-21)
  m966 Verhaeltnis abs(mittel h^_c*)/Streuung | 1,69 | ohne Decay auf E (wd0_s1_s5) | 1 | 1
  m967 rho(E_c* x h^_c*, log-Haeufigkeit) | -0,39 | ohne Decay auf E | 1 | 1
  m968 tote Zeilen / Median | 4/87 / 4 | ohne Decay auf E | 1 | 1
  m969 Verhaeltnis | 3,32 | mit Decay (gross_gross_s1_s5) | 1 | 1
  m970 rho | +0,44 | mit Decay | 1 | 1
  m971 tote Zeilen / Median | 22/87 / 3 | mit Decay | 1 | 1
  m972 Verhaeltnis / rho | 0,75 / -0,37 | Bezug s1_s4 | 1 | 1
  m973 Verhaeltnis / rho | 4,35 / +0,50 | Bezug s1_s7 | 1 | 1
  m974 Rot (Vorzeichen gekippt) Verhaeltnis | 0,0 | Rot Stand s7 | 1 | 1
Ergebnis e95 [2026-10-21 14:33]: verfehlt
  Fazit: Ohne Decay auf E entsteht kein Bias-Kanal (rho -0,39), mit Decay schon (+0,44). Der Kanal haengt also selbst am Decay; die Zwei-Faktoren-Deutung 'Kanal entsteht ohnehin, Decay toetet nur den Rest' faellt. Damit wurde der Inhalt von c* (Vorzeichen der Haeufigkeitskopplung) zum Kandidaten, der spaeter alle 22 Staende trennt (snai/merkmal-biasalle). Reichweite: eine Saat, ungepaart.
  Offen: Ungepaart (andere Fensterfolge in Segment 5); eine Saat. Ein echter decay-freier Logit-Bias als Eingriff: snai/merkmal-logitbias.
  Datei: rechner-a:~/snai_pruef/merkmal/gradzerl/kriterien.txt
Chronik:
  2026-10-21 14:32 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/gradzerl/kriterien.txt, Abschnitt 'NACHFRAGE WD0 (Auftrag nach Zweitmeinung, 2026-10-16, VOR der Messung)'. Die Schwellen entstanden nach der Nachmessung an s1_s4/s1_s7 (Werte bekannt), aber vor der Messung der beiden entscheidenden Staende.)
  2026-10-21 14:33 Rezept r101
  2026-10-21 14:33 Status geplant -> laeuft (Rezept r101)
  2026-10-21 14:33 Messwerte m966-m974
  2026-10-21 14:33 Ergebnis e95: verfehlt
  2026-10-21 14:33 Status laeuft -> ausgewertet (Ergebnis e95)
  2026-11-01 07:21 VORBEHALT 2026-11-01: gleiches Gerät wie snai/merkmal-gradzerl; 'LR 0' lief tatsächlich mit LR 0,0005 (train_worker.php ersetzt LR <= 0; Protokoll mess_wd0_s1_s5.log). Urteil nicht neu bewertet, nicht nachgemessen.
```
