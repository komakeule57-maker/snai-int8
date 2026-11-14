# snai/kopiersperre-bindung

```text
snai/kopiersperre-bindung - ausgewertet, angelegt 2026-10-24, zuletzt 2026-10-24 18:48
Frage: Kostet die kalibrierte Kopiersperre (snai/schleife-einstieg) das nuetzliche Kopieren in der Erzeugung, also einen Namen aus dem Prompt wieder aufzugreifen? Modell prod512b_s4.
Kriterium (festgelegt 2026-10-24 17:51, vor dem ersten Messwert):
  Ebene 2 des Massstabs Prompt-Bindung (tools/prompt_bindung.sh: 10 feste Prompts mit erfundenem Namen, Treffer = Name in den ersten 120 Woertern, Beam 3 ROH), Variante prompt_bindung_kopie.sh eaabe376 ueber snai_inference_kopie.php 6586779c. Arme 0 (ohne), K (Durchlass 0.4174,0.6245,0.8671,0.7404,0.7988, Saat 1), K2 (Saat 2). Gepaart je Posten: 'kein Schaden' = Treffer_K >= Treffer_0 - 1 UND hoechstens 1 Posten, den 0 trifft und K nicht; 'Schaden' = Treffer_K <= Treffer_0 - 3; sonst unentschieden. Je Saat getrennt, Gesamturteil nur bei gleichem Ergebnis beider Saaten, sonst saatabhaengig. Berichtet: Nennungen, erste Position, zerbrochene Namensformen, U, 3 Paare gelesen. Volltext rechner-a:~/snai_pruef/einstieg/kriterien_bindung.txt d199b3b0.
Plan: rechner-a:~/snai_pruef/einstieg/kriterien_bindung.txt
Baut auf: snai/schleife-einstieg
Darauf baut: snai/kopiersperre-promptfrei
Rezepte:
  r408 [2026-10-24] rechner-a: cd ~/snai_pruef/einstieg && setsid nohup bash bindung.sh (je Arm: OMP_NUM_THREADS=4 SNAI_GAIN_GUARD=0 PB_TAG=_<arm> [SNAI_KOPIE_F=... SNAI_KOPIE_SAAT=1|2] bash tools/prompt_bindung_kopie.sh prod512b_s4.snai 3 ~/snai_pruef/einstieg/bindung, cwd proj_sr)
      quelltext: bindung.sh 513f5661, tools/prompt_bindung_kopie.sh eaabe376 (aus prompt_bindung.sh a94f6b3b), snai_inference_kopie.php 6586779c, Bibliothek proj_sr 318b2655
      parameter: Beam 3 ROH, 10 Posten, Fenster 120 Woerter, Durchlass 0.4174,0.6245,0.8671,0.7404,0.7988
      seed: SNAI_KOPIE_SAAT 1 (K) und 2 (K2); Beam sonst deterministisch
      rechner: rechner-a, ein prod512b-Prozess
      logs: rechner-a:~/snai_pruef/einstieg/bindung/ (prompt_bindung_prod512b_s4_{arm0,K,K2}.txt), log/bindung.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/einstieg/bindung/prompt_bindung_prod512b_s4_{arm0,K,K2}.txt, auswert_bindung.py 18d5544c
  m5173 Treffer Prompt-Bindung (120 Woerter) | 3/10 | 0 |  | 10
  m5174 Treffer Prompt-Bindung (120 Woerter) | 1/10 | K | 1 | 10
  m5175 Treffer Prompt-Bindung (120 Woerter) | 2/10 | K | 2 | 10
  m5176 Posten verloren / gewonnen gegen 0 | 2 / 0 | K | 1 | 10
  m5177 Posten verloren / gewonnen gegen 0 | 1 / 0 | K | 2 | 10
  m5178 U der 10 Fortsetzungen | 0,608 / 0,147 / 0,182 | 0 / K / K2 | 1/2 | 10
  m5179 Zerbrochene Namensformen | 0 / 0 / 1 (Quasterberg) | 0 / K / K2 |  | 10
  m5180 Urteil | unentschieden (Saat 1), kein Schaden (Saat 2) -> saatabhaengig | K | 1/2 | 10
Ergebnis e356 [2026-10-24 18:48]: keine_aussage
  Fazit: Die 10-Posten-Probe kann die Frage nicht entscheiden: Ohne Sperre trifft prod512b_s4 nur 3 von 10 Namen, mit Sperre 1 bzw. 2 (Saat 1: unentschieden, Saat 2: kein Schaden, also saatabhaengig). Gelesen zeigt sich aber ein echter Schadensmechanismus: "Provinz Jorik Tannhusen" wird mit Sperre zu "Provinz Jorik zustaendig". Nach einem Vornamen aus dem Prompt ist der Nachname Kopierkandidat bei k=1, und dort sperrt die Sperre in 58 % der Faelle. In dieser Form also nicht in die ausgelieferte snai_inference.php uebernehmen. Naheliegende Abhilfe (ungeprueft): Kandidaten mit Fundstelle im Prompt nie sperren, nur Selbstkopie des erzeugten Textes daempfen.
  Offen: Die Variante "Prompt ausgenommen" ist ungemessen (Schleifen und Bindung). Ebenso offen: eine groessere Bindungsprobe mit mehr als 10 Posten fuer genug Trennschaerfe. Die Sperrzaehler fehlen im Log (prompt_bindung verwirft stderr).
  Datei: rechner-a:~/snai_pruef/einstieg/ERGEBNIS_bindung.md
Chronik:
  2026-10-24 17:51 angelegt
  2026-10-24 17:51 Rezept r408
  2026-10-24 17:51 Status geplant -> laeuft (Rezept r408)
  2026-10-24 18:48 Messwerte m5173-m5180
  2026-10-24 18:48 Ergebnis e356: keine_aussage
  2026-10-24 18:48 Status laeuft -> ausgewertet (Ergebnis e356)
```
