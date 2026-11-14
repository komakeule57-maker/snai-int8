# snai/vokabular-vortok

```text
snai/vokabular-vortok - ausgewertet, begonnen 2026-10-10, angelegt 2026-10-21, zuletzt 2026-10-21 19:43
Frage: Spart ein Vokabular (8192), dessen Bauer Satzzeichen nicht abtrennt (Modus leer, wie der Tokenizer), mindestens 10 % Token je Zeichen gegenüber Modus wort (Satzzeichen abgetrennt), beide aus demselben bereinigten Korpus?
Kriterium (nachgetragen, Beleg: Kriterium "vorab" (2026-10-10); eine datierte Kriteriendatei habe ich nicht gefunden.):
  Zwei Vokabulare (8192) aus demselben bereinigten Korpus (pseg03 + pseg17, 76 MB, korpus_bereinigen), gemessen mit dem echten SnaiTokenizer an 4 MB bereinigtem pseg30 (20.525 Zeilen, 3,90 Mio. Zeichen); ab 10 % Unterschied in Token je Zeichen Gewinn, darunter Gleichstand; Pflicht 0 unk und 0 Rundlauf-Fehler.
Rezepte:
  r260 [2026-10-21] nicht rekonstruiert (bpe_init/bpe_forge.nim im Modus wort bzw. leer, Messung mit snai_tokenizer.php)
      quelltext: bpe_forge.nim Stand 2026-10-10, nicht einzeln gesichert
      parameter: Vokabulargröße 8192, Baukorpus pseg03 + pseg17 bereinigt, Messkorpus pseg30 bereinigt 4 MB
      rechner: rechner-a (Laptop)
      logs: nicht gefunden
Messwerte (Groesse | Wert | Arm | Start | n):
 , nicht nachgerechnet, Rohdaten nicht gefunden
  m2877 token_je_zeichen | 0,2781 | Modus wort |  | 3900000
  m2878 token_je_zeichen | 0,2662 | Modus leer |  | 3900000
  m2879 token_je_zeichen | 0,2886 | altes symbio_vocab.json |  | 3900000
  m2880 unk / rundlauf_fehler | 0 / 0 | Modus wort, 20.525 Zeilen |  | 20525
  m2881 unk / rundlauf_fehler | 0 / 0 | Modus leer, 20.525 Zeilen |  | 20525
  m2882 unk / rundlauf_fehler | 60 / 37 | altes symbio_vocab.json, 20.525 Zeilen |  | 20525
  m2883 unterschied_leer_gegen_wort | -4,3 % | Regelgröße
Ergebnis e231 [2026-10-21 19:43]: gleichstand
  Fazit: Der Satzzeichen-Unterschied kostet nur 4,3 % Token, unter der 10-%-Schwelle: Gleichstand. Gewählt wurde trotzdem Modus leer, weil der Bauer dann dieselben Wortgrenzen zählt wie der Tokenizer und es nichts kostet. Auch gegen das alte Vokabular sind es nur 7,8 % weniger Token; der eigentliche Gewinn des Neubaus ist 0 unk statt 60, nicht die Länge. Die Wirkung auf den Loss ist nicht gemessen (dazu snai/kopier-vokprobe).
  Offen: Nur Token-Zählung, kein Training. Rohdaten und genauer Befehl nicht gefunden. n bei token_je_zeichen = Zeichenzahl des Messkorpus (3,90 Mio., gerundet).
Chronik:
  2026-10-21 19:43 angelegt (Nachtrag: Kriterium "vorab" (2026-10-10); eine datierte Kriteriendatei habe ich nicht gefunden.)
  2026-10-21 19:43 Rezept r260
  2026-10-21 19:43 Status geplant -> laeuft (Rezept r260)
  2026-10-21 19:43 Messwerte m2877-m2883
  2026-10-21 19:43 Ergebnis e231: gleichstand
  2026-10-21 19:43 Status laeuft -> ausgewertet (Ergebnis e231)
```
