# snai/gains-archaeologie

```text
snai/gains-archaeologie - ruht, angelegt 2026-11-01, zuletzt 2026-11-01 14:43
!! Messwerte ohne Ergebnis
Frage: Kippen die FFN-Gains auch auf den alten Engine-Staenden (Juni, August, September, int8 August), also seit jeher, oder erst ab einem Stand? Auftrag 2026-11-01.
Kriterium (festgelegt 2026-11-01 10:59, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/archaeo/kriterien.txt, vor dem ersten Lauf, mit Pruefer. d64, L2, ctx 64, 2 Koepfe, LR 0,001 fest, rund 40.000 Schritte, 3 Saaten je Zelle, gleiche Genesis ausser E0. Zellen WD 0,1: E2 sep03, E3 aug23i8, E4 aug29v7, E5i nov01 int8 SR, E5f nov01 FP32; WD 0: E0 jun18, E1 aug07, E5i0. Messgroesse: L0.rms_ffn tot am Endstand. KIPPT >= 50 % in 3 von 3, GESUND < 5 % in 3 von 3, sonst saatabhaengig; 5 Prozentpunkte um die Schwelle gelten als nicht erfuellt. Kontrolle E5i WD 0,1 muss KIPPEN, sonst Stopp und Rückfrage. SEIT JEHER im Rezept: E2 und E5f KIPPEN. AB STAND: E2 und E4 GESUND, E5f und E5i KIPPEN. Nur int8 abweichend: bekannte Ratsche. Sonst kein Datum. Ein Datum ist ein Indiz; Ursache erst, wenn der benannte Umbau einzeln an- und ausschaltet.
Plan: rechner-a:~/snai_pruef/archaeo/kriterien.txt
Baut auf: snai/gains-bestand, snai/merkmal-gains, snai/merkmal-gains-fp32
Rezepte:
  r489 [2026-11-01] rechner-a: cd ~/snai_pruef/archaeo && setsid -f nohup ./schlange_a.sh > log/schlange.out 2>&1 < /dev/null (je Lauf ./lauf_a.sh <zelle> <saat>: php train_cluster.php factory/input/d8.txt factory/checkpoints/a_s<S>.snai 1 1 <genesis> <dtype> 0.001 0 1 [wd])
      quelltext: kriterien.txt b673f4f8, lauf_a.sh 9f681f69, schlange_a.sh b96c9f1c; Libs aug07 0c61594e, sep03 52be5faa, aug23i8 4c3d20f5, aug29v7 9cef85fb, nov01 e281ce8d, jun18 68ce6159 (aus SNAI_distro f652fc7 core/cortex.nim gebaut mit Nim 2.2.10)
      parameter: d64, L2, FFN 256, ctx 64, 2 Koepfe per Sidecar, LR 0,001, ein Segment, d8.txt = erste 8 MB skala_r1, Vokabular e5f04510 (8192), CPU, 1 Thread, nice 8, hoechstens 5 parallel, Start ab 1400 MB
      seed: Genesis gh_s1..3 aus aug07/init_base.php, E0 g4_s1..3; gleiche Laufnamen a_s<S>; sep03 laut K3 nicht bytegleich wiederholbar
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/archaeo/log/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/archaeo/log/gains_s1_zwischen.jsonl (bestand.py, BESTAND_FRISCH=1), log/<Zelle>_s1.log. Fehlerkanal je 0 Treffer nan/fatal/error/warn, 0 NET2NET, rc=0, t 39.902. Saat 1, also nur Beobachtung.
  m7181 L0 / L1 rms_ffn tot, Median | 0 / 0 %, 0,795 / 1,736 | E2 FP32 Clip alt | 1
  m7182 L0 / L1 rms_ffn tot, Median | 0 / 0 %, 0,823 / 1,690 | E5f FP32 Clip neu | 1
  m7183 L0 / L1 rms_ffn tot, Median | 0 / 0 %, 1,906 / 1,796 | E4 int8 Ratsche | 1
  m7184 L0 / L1 rms_ffn tot, Median | 0 / 0 %, 1,781 / 1,222 | E5i int8 SR WD 0,1 | 1
  m7185 L0 / L1 rms_ffn tot, Median | 0 / 0 %, 1,252 / 0,973 | E5i0 int8 SR WD 0 | 1
  m7186 RMS emb / qk / vo / ffn | 0,0747 / 0,0763 / 0,0691 / 0,0446 | E2 | 1
  m7187 RMS emb / qk / vo / ffn | 0,0747 / 0,0761 / 0,0693 / 0,0461 | E5f | 1
  m7188 K1 Positivkontrolle Saat 1 | nicht gekippt, 0 % | E5i | 1
  Quelle: rechner-a:~/snai_pruef/archaeo/log/gains_pruefpunkt.jsonl (bestand.py, BESTAND_FRISCH=1), log/<Zelle>_s<S>.log. Fehlerkanal je 0 Treffer, 0 NET2NET, rc=0. E5i/E5i0 t 39.902.
  m7226 L0 / L1 rms_ffn tot, Median | 0 / 0 %, 1,934 / 1,191 | E5i int8 SR WD 0,1 | 2
  m7227 L0 / L1 rms_ffn tot, Median | 0 / 0 %, 1,840 / 1,401 | E5i int8 SR WD 0,1 | 3
  m7228 L0 / L1 rms_ffn tot, Median | 0 / 0 %, 1,272 / 0,979 | E5i0 int8 SR WD 0 | 2
  m7229 L0 / L1 rms_ffn tot, Median | 0 / 0 %, 0,713 / 1,260 | E0 FP32 WD 0 | 1
  m7230 L0 / L1 rms_ffn tot, Median | 0 / 0 %, 0,689 / 1,274 | E1 FP32 WD 0 | 1
  m7231 L0 / L1 rms_ffn tot, Median | 0 / 0 %, 0,816 / 1,677 | E3 Ganzzahl WD 0,1 | 1
  m7232 K1 Positivkontrolle Zelle | GESUND 0/0/0 %, nicht bestanden | E5i WD 0,1
Chronik (juengste 8 von 9, voll=True zeigt alle):
  2026-11-01 10:59 Rezept r489
  2026-11-01 10:59 Status geplant -> laeuft (Rezept r489)
  2026-11-01 11:25 Vor dem Lesen der Gain-Endstaende, Nachtrag in kriterien.txt: E0-E3 clippen laut Binary die Summen-Norm fest auf 1,0, E4 und E5 mit max(1, trainable_count). E2 (Lib 15.8.) liegt also VOR dem Clip-Fix vom 18.8., obwohl die Quelle ihn enthaelt. Geloggte GradNorm E2 205,36 gegen E5f 3,18 (Summen- gegen Mittelwertraum, Faktor 64,6 bei ctx 64). Die Linien E2/E5f und E3/E4 enthalten den Clip-Fix als mitlaufende Groesse. Zusaetzliche Lesart vermerkt, Wortlaut unveraendert. Hinweis aus dem Fork snai_multi_stack, gegen Quelltext und Binaries geprueft.
  2026-11-01 12:47 Messwerte m7181-m7188
  2026-11-01 12:47 Pruefpunkt ausgeloest: E5i Saat 1 kippt nicht (0 %). Schlange angehalten, E5i s2 laeuft, s3 vorgezogen (pruefpunkt_s3.sh). Stoppt die Reihe erst, wenn die Zelle nicht KIPPT. Beobachtung: E2 (Clip alt) und E5f (Clip neu) fast gleich in Gains und RMS, Saat 1, ungepaart bei sep03.
  2026-11-01 14:43 Messwerte m7226-m7232
  2026-11-01 14:43 Status laeuft -> ruht (von Hand)
  2026-11-01 14:43 Pruefpunkt: Positivkontrolle E5i nicht gekippt (0/0/0 %). Reihe laut Regel angehalten, nichts neu gestartet, Entscheidung offen. Aufbau kann die Frage so nicht beantworten: 40.000 Schritte und 2 Schichten; bekannte Faelle: Knirps 64/2 var erst nach 80.000-115.000 Fenstern, c128sr 4 Schichten nur mittlere Schichten.
```
