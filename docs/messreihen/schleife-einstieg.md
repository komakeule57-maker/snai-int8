# snai/schleife-einstieg

```text
snai/schleife-einstieg - ausgewertet, angelegt 2026-10-24, zuletzt 2026-10-24 17:36
Frage: Woher kommen die Absatzschleifen, und warum steigt das Modell in die erste Wiederholung ein? Ueberschaetzt es das Kopieren aus dem Kontext (Kalibrierung), oder setzt der modussuchende Beam jede Uebereinstimmung fort, weil die Kopierfortsetzung meist das argmax ist?
Kriterium (festgelegt 2026-10-24 15:45, vor dem ersten Messwert):
  sonde_einstieg.php (int8-Vorwaertspfad, ho_prod, Fenster 5-204 a 512 Token, Fenster 0-4 gesehen): je Endstueck-Uebereinstimmung der Laenge k ist c der fruehere Nachfolger. f_k = Anteil, mit dem echter Text c fortsetzt; p_k = mittleres P(c); g_k = Anteil mit argmax == c. H1 Uebervertrauen: p_k >= 1,1 f_k fuer k=1,2,3 bei Basis und M s1-3 (4/4). H2a Modusvorrang: g_1 >= 1,1 f_1 und g_2, g_3 >= 0,5 (4/4). ENTSCHEIDEND Teil 2, Eingriff im Beam (snai_inference_kopie.php, Produktionseinstellung, 8 neue Prompts, U unscharf.py): K sperrt c mit q_k = max(0, 1 - f_k/r_k), r_k = Fortsetzungsrate im Beam-Text ohne Eingriff (4 alte Prompts); Placebo P sperrt mit demselben q_k das Token an Stelle j+1. Regel ueber M s1-3: 'Ursache' = U_K <= 0,5 U_0 in 3/3 und U_P >= 0,9 U_0 in 3/3; 'Teilursache' = U_K <= 0,8 U_0 (sonst wie Ursache); 'nicht die Ursache' = U_K > 0,9 U_0 in 3/3; Placebo wirkt = unspezifisch, kein Schluss. Kvoll (immer sperren) nur berichtet. Korrelation ueber 22 Modelle und Entropie am Einstieg nur berichtet. prod512b_s4 als Uebertragungspunkt (ein Modell, nur Richtung). Volltext rechner-b/rechner-a:~/snai_pruef/einstieg/kriterien.txt 6c52df2c.
Plan: rechner-a:~/snai_pruef/einstieg/kriterien.txt
Baut auf: snai/prod512b-schleife, snai/ditto-schonend, snai/knirps-weitertrain
Darauf baut: snai/kopiersperre-bindung, snai/kopiersperre-promptfrei, snai/ditto-einstieg, snai/prod512b-kopierkoepfe-blick
Rezepte:
  r407 [2026-10-24] rechner-b: cd ~/snai_pruef/einstieg && setsid nohup bash teil1.sh (Sonde 22 Modelle) ; bash teil3.sh (Sonde auf vorhandenen Beam-Texten) ; Teil 2/5: bash beamlauf.sh <modell> <name> <ein Stellrad> ; Auswertung python3 auswert1.py, auswert3.py. rechner-a: setsid nohup bash teil4a.sh (prod512b_s4 Sonde + Arm 0)
      quelltext: sonde_einstieg.php b969e502 (Fenster-Logik wie 81accbae, Zweig laenge 0 dazu), gegen.py 0e9e31e1, patch_kopie.py d820f90f -> snai_inference_kopie.php 6586779c (aus proj_sr/snai_inference.php 8ba48a06; Stellraeder SNAI_KOPIE_F/_MODUS/_SAAT und SNAI_BEAM_REPWIN), beamlauf.sh 6b6e2105, teil1.sh 94e734c1, teil3.sh 6c2f9b80, teil4a.sh 1e9d64d1, auswert1.py 95850e8d, auswert3.py, kriterien.txt 0f4df4b3; Messbibliothek proj_sr 318b2655; Modelle ditto3/arme/*, drohneP_s19 170d4d3f, prod512b_s4
      parameter: ho_prod Fenster 5-204 a 512 Token, KMAX 16, Faecher k 1/2/3/4-7/8-16; Beam 3 ROH, temp 1, rep 1,15, Fenster 64 (Arm W: 32/128, R1: rep 1,0), top_k 6, 12 Prompts
      seed: Sperre mt_srand(SNAI_KOPIE_SAAT=1); sonst deterministisch; Modell-Saaten wie snai/ditto-schonend
      rechner: rechner-b (Knirpse), rechner-a (prod512b_s4, ein Prozess)
      logs: rechner-b:~/snai_pruef/einstieg/{t1,t3,b,log}, rechner-a:~/snai_pruef/einstieg/{t1,b,log}
      notiz: Patch-Proben 2026-10-24 (Basis, Prompt "Im Jahr 1928 wurde"): ohne Stellrad, f=1 und REPWIN=64 bytegleich zum Original (d8687db9); f=0 sperrt 258/258 (74df580b); REPWIN=128 anders (2e59a7ea). Teil 3 einmal mit einem ueberzaehligen Zeilenumbruch zwischen Prompt und Text gerechnet, verworfen und neu gerechnet (teil3.sh 6c2f9b80).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/einstieg auswert1.py 95850e8d (Teil 1), auswert3.py (Teil 3), auswert25.py 61715dab (Teil 2/5), Wiederholung bf/ (teil2f.sh b344e0be); rechner-a:~/snai_pruef/einstieg/t1/prod512b_s4.jsonl
  m5137 f_k natuerlicher Text k=1/2/3/4-7/8-16 | 0,157 / 0,439 / 0,513 / 0,582 / 0,770 | ho_prod |  | 200
  m5138 p/f k=1/2/3/4-7/8-16 | 0,83 / 0,79 / 0,75 / 0,70 / 0,60 | Basis |  | 200
  m5139 p/f k=1/2/3/4-7/8-16 | 0,73 / 0,73 / 0,68 / 0,64 / 0,56 | M | 1 | 200
  m5140 p/f k=1/2/3/4-7/8-16 | 0,77 / 0,76 / 0,69 / 0,64 / 0,56 | M | 2 | 200
  m5141 p/f k=1/2/3/4-7/8-16 | 0,79 / 0,76 / 0,67 / 0,65 / 0,54 | M | 3 | 200
  m5142 g/f k=1/2/3/4-7/8-16 | 1,54 / 1,24 / 1,12 / 1,03 / 0,87 | Basis |  | 200
  m5143 g/f k=1/2/3/4-7/8-16 | 1,43 / 1,16 / 1,09 / 1,01 / 0,82 | M | 1 | 200
  m5144 g/f k=1/2/3/4-7/8-16 | 1,44 / 1,17 / 1,05 / 0,99 / 0,83 | M | 2 | 200
  m5145 g/f k=1/2/3/4-7/8-16 | 1,48 / 1,18 / 1,04 / 0,99 / 0,83 | M | 3 | 200
  m5146 H1 Uebervertrauen | nein (0/4) | Basis+M |  | 200
  m5147 H2a Modusvorrang | ja (4/4) | Basis+M |  | 200
  m5148 Spearman U gegen g_1 / TP1 / p_1 / g_2 / Z | +0,88 / +0,87 / +0,78 / +0,72 / +0,36 | 22 Modelle |  | 22
  m5149 p/f k=1/2/3/4-7/8-16 | 0,95 / 0,93 / 0,89 / 0,85 / 0,72 | prod512b_s4 |  | 200
  m5150 g/f k=1/2/3/4-7/8-16 | 1,60 / 1,34 / 1,22 / 1,15 / 0,96 | prod512b_s4 |  | 200
  m5151 Schleifeneinstiege mit Periode < 65 Token | 0 von 196 (Median 68) | Basis+M Arm 0 |  | 196
  m5152 Entropie am Einstieg ueber Median aller Positionen | 0,51 / 0,55 / 0,56 / 0,57 | Basis/M1/M2/M3 |  | 196
  m5153 U8 neue Prompts K/0 | 0,01 / 0,18 / 0,05 | M K | 1/2/3 | 8
  m5154 U8 neue Prompts P/0 | 0,89 / 1,00 / 0,90 | M P | 1/2/3 | 8
  m5155 U8 neue Prompts K/0 und P/0 | 0,27 / 0,97 | Basis |  | 8
  m5156 Urteil Teil 2 erste Lesart (8 neue) | Ursache saatabhaengig (2/3) | M |  | 8
  m5157 U8 frische Prompts K/0 | 0,15 / 0,10 / 0,10 | M K | 1/2/3 | 8
  m5158 U8 frische Prompts P/0 | 1,04 / 1,07 / 0,99 | M P | 1/2/3 | 8
  m5159 U8 frische Prompts K/0 und P/0 | 0,11 / 0,98 | Basis |  | 8
  m5160 Urteil Teil 2 Wiederholung (8 frische) | Ursache ja (3/3) | M |  | 8
  m5161 U12 Kvoll (immer sperren) | 0,000 in 4/4 | Basis+M |  | 12
  m5162 E erfundene Wortformen 0 / K (12 Prompts) | 0,041/0,054, 0,030/0,046, 0,031/0,042 | M | 1/2/3 | 12
  m5163 Median-Periode Strafenfenster 32 / 64 / 128 | 36/68,5/133, 37/68/134, 35/68/133 | M | 1/2/3 | 12
  m5164 T5a Strafenfenster setzt die Schleifenlaenge | ja (3/3) | M |  | 12
  m5165 U12 Fenster 32 / 64 / 128 / ohne Strafe | 0,66-0,75 / 0,43-0,50 / 0,14-0,27 / 0,94-0,95 | Basis+M |  | 12
  m5166 Median-Periode ohne Strafe (rep 1,0) | 20 / 8 / 12 / 4 | Basis/M1/M2/M3 |  | 12
  Quelle: rechner-a:~/snai_pruef/einstieg/b/p512_{0,K,P} (teil4a.sh 1e9d64d1, teil4b.sh b7a3defb, rate.py b930ff72, Durchlass log/durchlass_p512.txt)
  m5167 U8 neue Prompts ohne / K / P | 0,567 / 0,106 / 0,569 | prod512b_s4 |  | 8
  m5168 K/0 und P/0 (U8) | 0,19 / 1,00 | prod512b_s4 |  | 8
  m5169 Uebertragung gleiche Richtung (K <= 0,8 U_0 und P >= 0,9 U_0) | ja | prod512b_s4 |  | 8
  m5170 E erfundene Wortformen ohne / K / P (12 Prompts) | 0,071 / 0,036 / 0,059 | prod512b_s4 |  | 12
  m5171 Schleifeneinstiege und Median-Periode ohne / K / P | 48, 69 (9 unter 65) / 9, 82 / 54, 70,5 | prod512b_s4 |  | 12
  m5172 Sperren K | 3432 von 9144 Kandidaten | prod512b_s4 |  | 12
Ergebnis e355 [2026-10-24 17:36]: erfuellt
  Fazit: Die Absatzschleifen kommen aus der Erzeugung, nicht aus einem Wissensfehler des Modells. Das Modell ueberschaetzt Kopieren nicht (p/f 0,54-0,95), aber nach einer zufaellig passenden Wortfolge ist die Kopierfortsetzung oft sein Favorit (g/f bis 1,6). Der Beam nimmt immer den Favoriten und setzt Uebereinstimmungen deshalb weit oefter fort als echter Text; jede Kopie macht die naechste wahrscheinlicher. Belegt durch Eingriff mit Placebo: Die Kopiersperre auf natuerliche Rate senkt U auf frischen Prompts auf 10-15 % (3/3, Basis 11 %), das Placebo bleibt bei 99-107 %; prod512b gleiche Richtung (19 % gegen 100 %). Die erste Lesart (8 neue Prompts) war 2/3 wegen eines knappen Placebos; die vorab festgelegte Wiederholung entscheidet. Die Absatzlaenge macht das 64-Token-Fenster der Wiederholungsstrafe: Mit Fenster 32 bzw. 128 wandert die Periode auf 35-37 bzw. 133-134 (3/3), ohne Strafe kreist der Beam in 4-20-Token-Schleifen. Hebel ist die Erzeugung, nicht das Training; das erklaert auch, warum DITTO nicht half.
  Offen: Ob die Kopiersperre nuetzliches Kopieren in der Erzeugung kostet (Namen aus dem Prompt wieder aufgreifen, Leseprobe/Prompt-Bindung an prod512b), ist ungemessen. Der Durchlass wurde aus 4 Prompts geschaetzt; ein fester Satz fuer alle Modelle ist ungeprueft. Sampling statt Beam nicht im Eingriff getestet. Einstieg bei hoher Entropie (Mahaut) hier nicht gesehen (Beobachtung). Ueber die Uebernahme in die ausgelieferte snai_inference.php wird gesondert entschieden.
  Datei: rechner-a:~/snai_pruef/einstieg/ERGEBNIS_einstieg.md
Chronik:
  2026-10-24 15:45 angelegt
  2026-10-24 15:51 Rezept r407
  2026-10-24 15:51 Status geplant -> laeuft (Rezept r407)
  2026-10-24 16:44 Messwerte m5137-m5166
  2026-10-24 17:36 Messwerte m5167-m5172
  2026-10-24 17:36 Ergebnis e355: erfuellt
  2026-10-24 17:36 Status laeuft -> ausgewertet (Ergebnis e355)
```
