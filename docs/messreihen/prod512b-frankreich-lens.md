# snai/prod512b-frankreich-lens

```text
snai/prod512b-frankreich-lens - ausgewertet, angelegt 2026-11-06, zuletzt 2026-11-12 13:09
Frage: In welchem Block von prod512b s11 wird (A) der Einstieg König nach ": Der" lesbar und (B) die Kopie eines wiederholten Füllers (k=6)?
Kriterium (festgelegt 2026-11-06 11:59, vor dem ersten Messwert):
  Logit-Lens (sonde_lens.php, Lens-Lib b69df3ee = cortex.nim f8292f7b + Patch, Neubau ungepatcht = 1eb78bc1), Lesung nach Block 0..5, Posten der Frankreich-Sonde. Beginn b = kleinster Block mit Rang <= 10 dort und danach; Rang-Sprung s_r = Block mit größtem Rückgang von log(Rang). LA: lesbar ab Block X, wenn b = X in >= 5/6 Ländern (König k=0), sonst UNEINIG. LB: Kopie entsteht in Block X, wenn s_r = X in >= 15/18 (3 Arme x 6 Länder, k=6), sonst UNEINIG. Kontrollen: Block 5 = Vorwärtslauf (maxabw 0), logp_end = Frankreich-Sonde, Fehlerkanal sauber, Rot gesehen an s5. Lens = Lesbarkeit, keine Ursache. Volltext KRITERIEN_lens.md.
Plan: rechner-a:~/snai_pruef/frankreich/KRITERIEN_lens.md
Baut auf: snai/prod512b-frankreich
Darauf baut: snai/prod512b-frankreich-eingriff
Rezepte:
  r615 [2026-11-06] cd ~/snai_pruef/ref512b && SNAI_CORTEX_LIB=~/snai_pruef/frankreich/lens/gepatcht/libcortex_lens.so SNAI_GAIN_GUARD=0 SNAI_FORCE_CPU=1 OMP_NUM_THREADS=2 php ~/snai_pruef/frankreich/sonde_lens.php ~/snai_pruef/frankreich/ckpt/prod512b_sN.snai 8 ~/snai_pruef/frankreich/posten.json ~/snai_pruef/frankreich/lens/lens_sN.jsonl "T3|"; python3 auswert_lens.py lens/lens_sN.jsonl sN.jsonl
      quelltext: Lens-Lib b69df3ee (cortex.nim f8292f7b + ~/snai_pruef/knirps/lens/patch_lens.py; ungepatcht = 1eb78bc1), sonde_lens.php, posten.json b698fd4f
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/frankreich/lens/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/frankreich/lens/bericht_s5/s10/s11.txt (auswert_lens.py)
  m9351 LA Beginn b König k0, Block | 4 in 6/6 | s11
  m9352 LA Beginn b König k0, Block | 5 in 6/6 | s10
  m9353 LA Beginn b König k0, Block | nie in 6/6 | s5
  m9354 LA Rang König k0 Frankreich Block 0 bis 5 | 167 197 201 36 5 1 | s11
  m9355 LB Rang-Sprung s_r k6, Block | 3 in 18/18 | s11
  m9356 LB Rang-Sprung s_r k6, Block | 3 in 18/18 | s10
  m9357 LB Rang-Sprung s_r k6, Block | 3 in 18/18 | s5
  m9358 LB Rang Füller k6 in Block 2, Spanne | 2300 bis 5300 | s11
  m9359 LB Rang Füller k6 in Block 3 | 1 in 16/18, 2 in 2/18 | s11
  m9360 Kontrolle maxabw Block 5 gegen Vorwärtslauf | 0 in 3/3 Ständen
  m9499 Quelle s12 | rechner-a:~/snai_pruef/frankreich/lens/bericht_s12.txt, r615 mit N=12, Kontrolle logp_end ok, maxabw letzte Schicht 0, 0 Grenzfehler | prod512b | s12 | 18
  m9500 LA Beginn b König k0, Block | nie in 4/6, Block 5 in 2/6 -> UNEINIG (s11 Block 4 in 6/6) | s12 | s12 | 6
  m9501 LA Rang König k0 Frankreich Block 0 bis 5 | 409 442 369 448 54 30 (s11 167 197 201 36 5 1) | s12 | s12 | 1
  m9502 LB Rang-Sprung s_r k6, Block | 3 in 18/18 (wie s5, s10, s11) | s12 | s12 | 18
  m9503 LB Rang Füller k6 in Block 3 | 1 in 12/18 (König, Botschafter), 4-10 in 6/18 (alle Bürgermeister); s11 1 in 16/18, 2 in 2/18 | s12 | s12 | 18
  Quelle: ~/snai_pruef/frankreich/lens/bericht_s13.txt (auswert_lens.py auf lens/lens_s13.jsonl und s13.jsonl; Stand md5 d9facd40; lib 1eb78bc1)
  m9987 s13 Kontrolle max | logp_end - Frankreich-Sonde |  | 0,00e+00 (ok) | s13
  m9988 s13 LA: Beginn König k0 je Land | Block 5 in 2/6 (Frankreich, England), nie lesbar in 4/6: UNEINIG (s12 ebenso 2/6, dort England und Schweden) | s13
  m9989 s13 LA: Rang König Frankreich k0, Block 0-5 | 140 207 220 135 15 10 (s12 409 442 369 448 54 30; s11 167 197 201 36 5 1) | s13
  m9990 s13 LB: Rang-Sprung der Kopie k6 | Block 3 in 18/18 | s13
  m9991 s13 LB: Rang in Block 3 | 1 in 14/18, 2-3 in 4/18 (alle Bürgermeister); s12: 1 in 12/18, 4-10 in 6/18 | s13
  m9992 s13 LB: P in Block 3, König Frankreich k6 | 0,3130 (s12 0,0827) | s13
  Quelle: rechner-a ~/snai_pruef/frankreich/lens/lens_s14.jsonl (Lens-Lib wie s11-s13), auswert_lens.py -> lens/bericht_lens_s14.txt; Kontrolle logp_end maxabw 0; Fehlerkanal leer. Vergleichswerte s5/s10-s13 aus denselben jsonl nachgerechnet. Ausführlich ERGEBNIS_lens.md Abschnitt s14.
  m10668 s14 LA Einstieg König k0 | lesbar in 6/6 (Block 4 in 3/6, Block 5 in 3/6), UNEINIG nach Wortlaut; Rang Frankreich Block 0-5 161 203 280 131 10 1 | prod512b | s14 | 6
  m10669 s14 LB Kopie k6 | Block 3 in 18/18, Rang 1 in Block 3 18/18 (s13 14/18), KOPIE ENTSTEHT IN BLOCK 3 | prod512b | s14 | 18
  m10670 s14 P König Frankreich k6 in Block 3 | 0,594 (s13 0,313, s12 0,083, s11 0,658, s10 0,068, s5 0,078) | prod512b | s14 | 1
Ergebnis e561 [2026-11-06 12:00]: erfuellt
  Fazit: Die Schleife hat zwei Anfänge in verschiedenen Blöcken: Der Einstieg König wird ab Block 4 lesbar und baut sich über Block 3-5 auf (mit dem Training früher: s5 nie, s10 Block 5, s11 Block 4). Die Kopie erscheint schlagartig in Block 3 (Rang ~2000-5000 -> 1, 18/18, unverändert seit s5), für jeden Füller gleich. Ein Eingriff gegen das Kopieren müsste an Block 3 ansetzen. Lens = Lesbarkeit; ob Block 3 die Kopie selbst schreibt, ist nicht isoliert.
  Offen: Ursächlicher Test: Block 3 bzw. einzelne Köpfe darin im Vorwärtslauf abschalten (Kopie weg, Einstieg bleibt?). Zusammenhang mit dem auffälligen Q/K-Gradienten von Block 3 nur Fingerzeig.
  Datei: rechner-a:~/snai_pruef/frankreich/ERGEBNIS_lens.md
Chronik (juengste 8 von 9, voll=True zeigt alle):
  2026-11-06 12:00 Rezept r615
  2026-11-06 12:00 Status geplant -> laeuft (Rezept r615)
  2026-11-06 12:00 Messwerte m9351-m9360
  2026-11-06 12:00 Ergebnis e561: erfuellt
  2026-11-06 12:00 Status laeuft -> ausgewertet (Ergebnis e561)
  2026-11-08 06:27 Messwerte m9499-m9503
  2026-11-10 08:16 Messwerte m9987-m9992
  2026-11-12 13:09 Messwerte m10668-m10670
```
