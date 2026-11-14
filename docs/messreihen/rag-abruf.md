# snai/rag-abruf

```text
snai/rag-abruf - ausgewertet, begonnen 2026-09-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:43
!! ohne Kriterium
Frage: Liefert ein echter Abruf (SQLite-FTS5/BM25, Anfrage aus dem Betreff, Heuhaufen 452 Prüfsatzdokumente plus 50.000 Störer aus untrainierten Segmenten pseg30-39) bei prod512_s6 so viel vom erreichbaren Belegnutzen (Schicht A), dass RAG die Mindest-Trefferquote überschreitet?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Baut auf: snai/beleg-sonde
Rezepte:
  r259 [2026-10-21] bash run_beleg_sonde.sh mit Abruf-Armen sql/fehlgriff (Anfrage betreff bzw. praefix, Heuhaufen klein bzw. 50.000 Störer)
      quelltext: diagnose/beleg_sonde.php (Stand 2026-09-14 nicht gesichert)
      parameter: 120 Posten, prod512_s6, Saat 20260912
      seed: 20260912
      rechner: rechner-a
      logs: rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/beleg_sonde_prod512_s6_{betreff,betreff_50000st,praefix_50000st}.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
 , nicht nachgerechnet (Rohdaten rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/beleg_sonde_prod512_s6_*50000st.jsonl vorhanden)
  m2869 gewinn_schicht_A | +0,0451 (t 3,2) | passend (Obergrenze) | 20260912 | 120
  m2870 gewinn_schicht_A | +0,0426 (t 2,9) | sql, echter Abruf, 89 % Treffer, Betreff, 50k Störer | 20260912 | 120
  m2871 schaden_schicht_A | +0,0099 (t 0,6) | gezielter Fehlgriff, Betreff, 50k | 20260912 | 120
  m2872 schaden_schicht_A | +0,0683 (t 5,3) | Zufallsstörer aus dem Störerpool (Positivkontrolle) | 20260912 | 120
  m2873 schaden_schicht_A | +0,0730 (t 4,2) | Zufallsbeleg aus dem Prüfsatz | 20260912 | 120
  m2874 mindest_trefferquote | 18 % | gezielter Fehlgriff | 20260912 | 120
  m2875 schaden_fehlgriff | +0,0402 / +0,0002 / +0,0214 / +0,0099 | Präfix klein / Präfix 50k / Betreff klein / Betreff 50k | 20260912 | 120
  m2876 gewinn_ganze_spanne | +0,0069 | sql | 20260912 | 120
Ergebnis e230 [2026-10-21 19:43]: beobachtung
  Fazit: Der Abruf ist nicht der Engpass: FTS5 über 50.000 Dokumente holt 94 % des erreichbaren Belegnutzens, und ein gezielter Fehlgriff schadet kaum, weil er thematisch passt. Ob ein Fehlgriff schadet, hängt am Heuhaufen, nicht an der Anfrageart. Für SnAI reicht SQLite-FTS5 ohne Vektorspeicher (so entschieden). Der Absolutnutzen über die ganze Spanne bleibt aber winzig, und gemessen ist Kopieren aus dem Kontext, nicht Frage-Antwort.
  Offen: Ohne Vorab-Kriterium; Zahlen nicht nachgerechnet. Bei s19 mit nur 452 Dokumenten und Präfix-Anfrage 93 %.
Chronik:
  2026-10-21 19:43 angelegt (Nachtrag: Kein Kriterium vor dem Lauf gefunden; die Mindest-Trefferquote als Maßstab stammt vom 2026-09-13, die Abruf-Arme wurden am 2026-09-14 gebaut.)
  2026-10-21 19:43 Rezept r259
  2026-10-21 19:43 Status geplant -> laeuft (Rezept r259)
  2026-10-21 19:43 Messwerte m2869-m2876
  2026-10-21 19:43 Ergebnis e230: beobachtung
  2026-10-21 19:43 Status laeuft -> ausgewertet (Ergebnis e230)
```
