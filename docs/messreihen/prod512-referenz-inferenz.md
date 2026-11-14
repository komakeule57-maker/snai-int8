# snai/prod512-referenz-inferenz

```text
snai/prod512-referenz-inferenz - ausgewertet, begonnen 2026-09-05, angelegt 2026-10-21, zuletzt 2026-10-21 19:31
!! ohne Kriterium
Frage: Wie verändern sich Register, Formfehler und Entartungszeichen (<unk>-Ketten, Markup, Assistenz-Floskeln, literales [SYMBIO]) in den vier festen Prompts der Referenz-Inferenz über die Stände s0 bis s19 von prod512, getrennt nach ROH- und KORSETT-Spur?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Baut auf: snai/prod512-lauf
Darauf baut: snai/prod512-registersonde, snai/prod512-sft-bereinigung, snai/vokabular-bytefallback
Rezepte:
  r198 [2026-10-21] bash tools/referenz_inferenz.sh factory/checkpoints/prod512_sN.snai (Beam 3, repetition_penalty 1,15, Tokenlimit 256; zwei Spuren: KORSETT mit [USER]…[SYMBIO], ROH mit SNAI_ROHPROMPT=1); ab s18 auf rechner-b mit LANG=de_DE.utf8 nohup setsid bash tools/referenz_inferenz.sh …; Auszählung python3 tools/auswert_referenz_register.py
      quelltext: tools/referenz_inferenz.sh md5 6aad95a3… (heutiger Stand; Vorstände .bak_pre_rohspur_20260906, .bak_pre_s2_20260907); libcortex.so vom 2026-09-02 bis s15, vom 2026-09-24 ab s16 (Gegenprobe s11 zeichengleich)
      parameter: 4 Prompts: 'Das Wohnhaus in der Friedensstrasse', 'Die Hauptstadt von Frankreich ist', 'Im Jahr 1928 wurde', 'Der Film handelt von'; md5 jedes Stands gegen vserver geprüft
      seed: deterministischer Beam
      rechner: rechner-a (s0-s17), rechner-b (s18, s19; s17 dort zeichengleich)
      logs: rechner-a:~/.cache/prod512/referenz_prod512_sN.txt und referenz_roh_prod512_sN.txt (+ .dump)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: am 2026-10-21 mit rechner-a:~/Projekte/snai_edge_int8_lora/tools/auswert_referenz_register.py über rechner-a:~/.cache/prod512/referenz_*prod512_s0..s19.txt neu ausgezählt (feste Markerliste)
  m2374 <unk> gesamt / maxRun KORSETT | 47 / 47 | prod512 s10 |  | 4
  m2375 <unk> gesamt / maxRun ROH | 4 / 2 | prod512 s13 |  | 4
  m2376 <unk> gesamt / maxRun KORSETT | 160 / 160 (bis Tokenlimit) | prod512 s18 |  | 4
  m2377 <unk> übrige Stände s0..s19 beide Spuren | 0 | prod512 |  | 4
  m2378 Assistenz-Floskeln KORSETT | 9 / 12 | prod512 s3 / s7 |  | 4
  m2379 Assistenz-Floskeln übrige Stände und ganze ROH-Spur | 0 | prod512 |  | 4
  m2380 literales [SYMBIO] KORSETT | 6 / 3 / 1 / 2 | prod512 s3 / s4 / s5 / s7 |  | 4
  m2381 Sport-Marker ROH | 30 / 6 / 21 / 29 / 3 / 12 / 1 | prod512 s1 bis s7 |  | 4
  m2382 Sport-Marker ROH s8 bis s19 | 0 bis 2 | prod512 |  | 4
 ; nicht nachgerechnet
  m2383 Markup-Zeilen (Zeitleiste/JSON/Wiki) | KORSETT s4 85, ROH s15 13 | prod512 |  | 128
  m2384 Markup-Zeilen s16 bis s19 | 0 | prod512 |  | 4
  m2385 nicht abgedeckte Zeichen im Trainingskorpus | 158.862 (0,011 %), 7.263 verschiedene | Korpus Server-Fassung |  | 40
  m2386 Anteil davon in Klammern | 55,9 % (Grundrate 5,15 %) | Korpus |  | 40
  m2387 Einzelzeichen im Vokabular symbio_vocab.json | 292 | Vokabular e5f04510 |  | 1
Ergebnis e186 [2026-10-21 19:31]: beobachtung
  Fazit: Die Referenz-Inferenz ist ein Lesegerät, kein Messgerät: vier Prompts mit deterministischem Beam schwanken von Stand zu Stand stärker als jede plausible Wirkung, und sie kann die Abwesenheit eines Ereignisses nicht belegen (die <unk>-Kette fehlte bei s11 in den vier Prompts, stand aber in der 30-Prompt-Sonde). Belastbar sind nur zwei Dinge: die ROH-Spur ist ab s7 registerrein und frei von Floskeln, und die <unk>-Ketten sind ein Abdeckungsdefekt des Vokabulars (Fremdschrift in Klammern, 292 Einzelzeichen), keine Entartung; behoben im neuen Vokabular (snai/vokabular-bytefallback). Faktenwissen fehlt auf jedem Stand. Für prod512b: Kollaps-Wächter ja, Fortschrittsmaß nein.
  Offen: Kein Rauschboden je Spur (zweite Saat oder mehr Prompts) gemessen. Zählungen vor s11 liefen mit wechselnden Markerlisten; die Neuzählung von heute weicht davon ab (z. B. s4 ROH Sport 29 statt 34).
  Datei: rechner-a:~/Projekte/snai_edge_int8_lora/docs/PRODUKTIVLAUF_DIM512.md (Abschnitte 12 bis 17)
Chronik:
  2026-10-21 19:31 angelegt (Nachtrag: Kein Urteilskriterium für die Reihe; Zählliste erst ab s11 eingefroren (tools/auswert_referenz_register.py, 2026-09-23). Einzelprüfungen mit Vorab-Regel: Markup 'neu nur, wenn kein früherer Stand welche hat' (2026-09-30) und 'erst ein zweiter Stand in Folge wäre ein Grund, das Korpus zu durchsuchen' (Test bei s16). Ursache der <unk>-Ketten mit eigener Vorab-Messvorschrift.)
  2026-10-21 19:31 Rezept r198
  2026-10-21 19:31 Status geplant -> laeuft (Rezept r198)
  2026-10-21 19:31 Messwerte m2374-m2382
  2026-10-21 19:31 Messwerte m2383-m2387
  2026-10-21 19:31 Ergebnis e186: beobachtung
  2026-10-21 19:31 Status laeuft -> ausgewertet (Ergebnis e186)
```
