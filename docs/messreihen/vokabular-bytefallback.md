# snai/vokabular-bytefallback

```text
snai/vokabular-bytefallback - ausgewertet, begonnen 2026-09-28, angelegt 2026-10-21, zuletzt 2026-10-21 19:33
Frage: Beseitigen Byte-Rückfall im Tokenizer und Fremdschrift-Streichung im Korpus-Bereiniger die <unk>-Ursache, ohne das heutige Vokabular zu verändern und ohne echten Korpustext zu beschädigen (drei Prüfkriterien R1 bis R3)?
Kriterium (nachgetragen, Beleg: Kriterien (2026-09-28 14:52), dort als 'vorab festgelegt'; Entscheidung zum Umbau im selben Eintrag.):
  R1 Rückwärtsverträglichkeit: neuer Tokenizer mit heutigem symbio_vocab.json bitgleich zum alten (encode und decode). R2 Byte-Rückfall: Testvokabular aus neuem Forge, 0 <unk> und 0 Rundlauf-Fehler. R3 Bereiniger über das Trainingskorpus (Server-Fassung, 40 Segmente): jede geänderte Zeile erklärt, 0 Fremdschrift-, Platzhalter- und Tab-Rest.
Baut auf: snai/prod512-referenz-inferenz
Rezepte:
  r209 [2026-10-21] k. A. (Prüfskripte zu R1-R3 nicht benannt); Schnittstellen
      quelltext: Tokenizer und Bereiniger auf rechner-a, Sicherungen *.bak_pre_bytefallback_20260928 und *.bak_pre_fremdschrift_20260928
      parameter: R1: 20.764 Zeilen / 1.068.738 Token; R2: 1.069.307 Token; R3: 11.843.241 Zeilen, Segmente in Server-Fassung (md5 geprüft)
      seed: deterministisch
      rechner: rechner-a
      logs: k. A.
Messwerte (Groesse | Wert | Arm | Start | n):
 , nicht nachgerechnet
  m2468 R1 encode und decode bitgleich | ja | heutiges Vokabular |  | 20764
  m2469 R2 <unk> / Rundlauf-Fehler | 0 / 0 | Testvokabular |  | 1069307
  m2470 R3 geänderte / unerklärte Zeilen | 17.134 / 0 | Bereiniger |  | 11843241
  m2471 R3 <unk> mit heutigem Vokabular | 158.862 auf 37.756 | Bereiniger |  | 40
  m2472 R3 Zeilen mit Satzzeichen-Artefakten | 18 | Bereiniger |  | 11843241
Ergebnis e193 [2026-10-21 19:33]: erfuellt
  Fazit: Alle drei Kriterien bestanden: der Umbau ändert am alten Vokabular nichts, das neue Vokabular kennt kein <unk> mehr, und der Bereiniger greift nur, wo er soll. Damit war der Weg zum neuen Vokabular f020d0ca für prod512b frei; der laufende Lauf blieb bewusst unberührt. Offen blieb die Vermutung, dass gelernte Merges wie '▁,' im Betrieb kaum erreichbar sind, weil bpe_forge vor jedes Satzzeichen '▁' setzt.
  Offen: Rund 38.000 Latein-, Griechisch- und Symbolvorkommen laufen über Bytes statt Transliteration. Merge-Vermutung ungeprüft.
Chronik:
  2026-10-21 19:33 angelegt (Nachtrag: Kriterien (2026-09-28 14:52), dort als 'vorab festgelegt'; Entscheidung zum Umbau im selben Eintrag.)
  2026-10-21 19:33 Rezept r209
  2026-10-21 19:33 Status geplant -> laeuft (Rezept r209)
  2026-10-21 19:33 Messwerte m2468-m2472
  2026-10-21 19:33 Ergebnis e193: erfuellt
  2026-10-21 19:33 Status laeuft -> ausgewertet (Ergebnis e193)
```
