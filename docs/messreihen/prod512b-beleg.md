# snai/prod512b-beleg

```text
snai/prod512b-beleg - ausgewertet, angelegt 2026-10-23, zuletzt 2026-10-23 15:44
Frage: Liest prod512b einen Beleg im Kontext (Prompt-Bindung, Ebene 1 des Maßstabs)? Erstes Urteil an s4, weil der vorgesehene Messpunkt s3 nicht gemessen wurde (keine Ausgabedatei gefunden, 2026-10-23).
Kriterium (nachgetragen, Beleg: Kriterium vom 2026-10-10 (docs/MASSSTAB_PROMPT_BINDUNG.md); die Reihe wurde erst 2026-10-23 vor dem ersten Lauf angelegt):
  Maßstab (festgelegt 2026-10-10, vor dem ersten Ergebnis), wörtlich übernommen: Beleg-Sonde diagnose/beleg_sonde.php, 120 Posten, Saat 20260912, ho_prod; Auswertung tools/auswert_beleg_sonde_token.py mit Rang >= 200. Kennzahl Beleg-Anteil A = (Loss fremd - Loss passend) / Loss fremd in Schicht A (seltene Zieltoken, die wörtlich im passenden Beleg stehen). Ab 50 % vorhanden, 10-50 % teilweise, unter 10 % nicht vorhanden. Nebenbedingungen: Abstand über dem Rauschboden fremd_a/fremd_b UND Anteil A größer als Anteil B (sonst Themennähe). Abweichung: Messpunkt s4 statt s3. Grenze: die 50 % sind gesetzt, nicht gemessen; belastbar ist nur die untere Grenze.
Baut auf: snai/prod512b-lauf, snai/kopier-prod512-beleg
Rezepte:
  r394 [2026-10-23] prod512b s4 (md5 751d92d9): cd ~/snai_pruef/merkmal/prodtest/proj_sr && SNAI_FORCE_CPU=1 SNAI_GAIN_GUARD=0 OMP_NUM_THREADS=4 nice -n 19 timeout 10800 php diagnose/beleg_sonde.php factory/checkpoints/prod512b_s4.snai 120 > ../beleg_s4.out 2> ../beleg_s4.err; danach python3 tools/auswert_beleg_sonde_token.py factory/checkpoints/beleg_sonde_prod512b_s4.jsonl 200 (aus kette_s4.sh, nach Leseprobe, Alpha und Schleifen-Sonde)
      quelltext: diagnose/beleg_sonde.php md5 d1e13cc0 (gleich snai_edge_int8_lora); libcortex.so wie Leseprobe (proj_sr, 2026-10-18 17:10)
      parameter: 120 Posten, Prüfsatz factory/holdout_prod/ho_prod.txt, 8 Köpfe aus .heads, Rang-Grenze 200
      seed: 20260912 (fest im Skript)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/prodtest/beleg_s4.out/.err, proj_sr/factory/checkpoints/beleg_sonde_prod512b_s4.jsonl, kette_s4.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/prodtest/proj_sr/factory/checkpoints/beleg_sonde_prod512b_s4.jsonl via tools/auswert_beleg_sonde_token.py 200 (2390,8 s, beleg_s4.err ohne Fehler, md5 751d92d9); Vergleich prod512 s19 aus snai_edge_int8_lora/factory/checkpoints/beleg_sonde_prod512_s19.jsonl, gleicher Auswerter
  m4815 Schicht A fremd / passend (nats) | 4,4982 / 3,3491 (+1,1490, t 18,4, besser 116/119) | prod512b s4 | 20260912 | 120
  m4816 Beleg-Anteil A = (fremd-passend)/fremd | 25,5 % | prod512b s4 | 20260912 | 120
  m4817 Beleg-Anteil B (selten, nicht im Beleg) | 1,9 % (+0,0933 nats) | prod512b s4 | 20260912 | 120
  m4818 Rauschboden Schicht A fremd_a gegen fremd_b | +0,0349 nats, t 1,7 | prod512b s4 | 20260912 | 120
  m4819 A minus B | +1,0555 nats, SE 0,0617, t 17,1 | prod512b s4 | 20260912 | 119
  m4820 Wert A passend gegen ohne | +0,9442 nats, t 15,9 | prod512b s4 | 20260912 | 120
  m4821 Beleg-Anteil A, alter Lauf zum Vergleich | 4,5 % (+0,2259 / 5,0634) | prod512 s19 | 20260912 | 120
Ergebnis e340 [2026-10-23 15:44]: erfuellt
  Fazit: Nach dem Maßstab heißt das „teilweise vorhanden“. Die Stufe ist nach Regel eindeutig bestimmt, deshalb lautet das Urteil der Reihe „erfüllt“ im Sinne von „Messung trägt ein Urteil“. Der Beleg-Anteil A liegt bei 25,5 % (Band 10–50 %). Beide Nebenbedingungen halten: Der Abstand liegt rund 33-fach über dem Rauschboden, und A (25,5 %) ist deutlich größer als B (1,9 %). prod512b schlägt also nach, statt nur das Thema aufzunehmen. Der alte Lauf lag nach 20 Segmenten bei 4,5 %, prod512b liegt schon nach 5 Segmenten beim 5,7-fachen. Für den Entscheidungspunkt s7 (Regel: ab 10 % weiterlaufen) ist die Schwelle schon jetzt klar überschritten. Ein Abbruch wegen fehlender Prompt-Bindung steht damit nicht mehr zur Debatte. Gemessen ist Kopieren bzw. Konditionieren auf wörtlich im Kontext stehende Token, nicht Faktenwissen.
  Offen: Erster Messpunkt: Es gibt keinen Verlauf, weil s0 und s3 nie gemessen wurden. Ob A weiter wächst, zeigt erst s7. Der Vergleich mit prod512 läuft über verschiedene Vokabulare (Rang-Schicht >= 200 je Prüfsatz), er ist eine Größenordnung, kein exakter Abstand. Ebene 2 (prompt_bindung.sh, 10 Prompts) ist nicht gelaufen. Die 50-%-Grenze ist gesetzt, nicht geeicht.
  Datei: rechner-a:~/snai_pruef/merkmal/prodtest/beleg_s4.out
Chronik:
  2026-10-23 14:39 angelegt (Nachtrag: Kriterium vom 2026-10-10 (docs/MASSSTAB_PROMPT_BINDUNG.md); die Reihe wurde erst 2026-10-23 vor dem ersten Lauf angelegt)
  2026-10-23 14:39 Rezept r394 (prod512b s4 (md5 751d92d9))
  2026-10-23 14:39 Status geplant -> laeuft (Rezept r394)
  2026-10-23 15:44 Messwerte m4815-m4821
  2026-10-23 15:44 Ergebnis e340: erfuellt
  2026-10-23 15:44 Status laeuft -> ausgewertet (Ergebnis e340)
```
