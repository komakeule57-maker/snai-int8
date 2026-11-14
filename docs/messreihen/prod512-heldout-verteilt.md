# snai/prod512-heldout-verteilt

```text
snai/prod512-heldout-verteilt - ausgewertet, begonnen 2026-09-28, angelegt 2026-10-21, zuletzt 2026-10-21 19:30
Frage: Streuen 64 gleichmäßig über den Prüfsatz verteilte Held-out-Fenster um ihren eigenen Potenzgesetz-Fit (s1..s14 von prod512) um mehr als 10 % weniger als die bisherigen ersten 64 Fenster?
Kriterium (nachgetragen, Beleg: Kriterium nur im Ergebniseintrag als ‚vorab‘ bezeichnet, nicht unabhängig belegt. Kriterium (2026-09-28 15:55), dort als 'vorab' bezeichnet.):
  SD der Residuen um den eigenen Fit L=a+b*s^-alpha (Gitter 0,0001, n-3) über s1..s14; verteilt > 10 % niedriger = ruhiger, sonst Gleichstand. Gegenversuch: je 32-Fenster-Hälften (gerade/ungerade/vordere/hintere), alle Verhältnisse < 0,90 = kein Auswahlglück. Abnahme vorab: s14 im alten Modus auf dem Laptop = Server 3,905523 bitgleich; s1..s4 mit Server-Lib = alte Werte bitgleich.
Baut auf: snai/prod512-fenstertest
Darauf baut: snai/prod512-eichpunkte-verteilt
Rezepte:
  r191 [2026-10-21] bash tools/heldout_verteilt.sh <segment> (Laptop) bzw. bash ~/.cache/prod512/heldout_verteilt_rechner-b.sh <segment> (ab s18); darin: SNAI_CORTEX_LIB=<Server-libcortex.so> SNAI_FORCE_CPU=1 OMP_NUM_THREADS=2 SNAI_EVAL_VERTEILT=1 php eval_held_out_full_i8.php factory/checkpoints/prod512_sN.snai factory/holdout_prod/ auto 64; Auswertung python3 diagnose/heldout_verteilt_fit.py
      quelltext: tools/heldout_verteilt.sh md5 64d1d128…, diagnose/heldout_verteilt_fit.py md5 246a7663… (heutiger Stand); Server-libcortex.so md5 169141c5…; md5 jedes Checkpoints gegen vserver geprüft
      parameter: 64 Fenster bei floor((2i+1)*631/128), i=0..63 (Fenster 4, 14, …, 626) aus factory/holdout_prod/ho_prod.txt (632 Fenster à 1024 Token); Fit L=a+b*s^-alpha per Gittersuche (alpha-Schritt 0,0001)
      seed: deterministisch
      rechner: rechner-a (s1-s17), rechner-b (s18, s19; Gegenprobe s17 bitgleich)
      logs: rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/heldout_full_i8_prod512_sN_verteilt.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: s1..s14 (nicht neu gerechnet); s1..s19 am 2026-10-21 mit rechner-a:~/Projekte/snai_edge_int8_lora/diagnose/heldout_verteilt_fit.py aus den jsonl neu gerechnet
  m2317 SD Residuen erste 64 Fenster s1..s14 | 0,01244 | anfang |  | 14
  m2318 SD Residuen verteilt s1..s14 | 0,00555 | verteilt |  | 14
  m2319 Verhältnis verteilt/anfang s1..s14 | 0,446 | verteilt |  | 14
  m2320 Hälften gerade/ungerade/vordere/hintere s1..s14 | 0,69 / 0,42 / 0,68 / 0,29 | Gegenversuch |  | 32
  m2321 Verhältnis verteilt/anfang s1..s19 | 0,499 | verteilt |  | 19
  m2322 Hälften gerade/ungerade/vordere/hintere s1..s19 | 0,766 / 0,459 / 0,870 / 0,286 | Gegenversuch |  | 32
  m2323 Fit verteilt s1..s14 a / b / alpha | 2,7962 / 2,1666 / 0,2155 | verteilt |  | 14
Ergebnis e175 [2026-10-21 19:30]: erfuellt
  Fazit: Ja, die verteilte Reihe streut nur halb so stark um ihren Fit (Verhältnis 0,45, bis s19 0,50), und keine Hälfte liegt über 0,90. Das Zickzack der Klumpungspaare war größtenteils Ausschnittsrauschen der ersten 64 Fenster, nicht Trainingsdynamik. Seit 2026-09-28 entscheidet die verteilte Reihe die Abbruchfrage, die alte läuft nur zum Vergleich mit. Die Abbruchprognose verschob sich dadurch nur um ein Segment (s25 statt s26). Für prod512b gilt die Lehre ebenso; dessen Segmentprüfung misst aber weiter die ersten 64 Fenster (heldout_s*.txt: '64 von 577').
  Offen: Die SE 0,0061 der alten Reihe ist damit als Streuungsmaß der alten Reihe zu klein; alte Sigma-Aussagen (s7 bis s14) stehen unter diesem Vorbehalt.
Chronik:
  2026-10-21 19:30 angelegt (Nachtrag: Kriterium nur im Ergebniseintrag als ‚vorab‘ bezeichnet, nicht unabhängig belegt. Kriterium (2026-09-28 15:55), dort als 'vorab' bezeichnet.)
  2026-10-21 19:30 Rezept r191
  2026-10-21 19:30 Status geplant -> laeuft (Rezept r191)
  2026-10-21 19:30 Messwerte m2317-m2323
  2026-10-21 19:30 Ergebnis e175: erfuellt
  2026-10-21 19:30 Status laeuft -> ausgewertet (Ergebnis e175)
```
