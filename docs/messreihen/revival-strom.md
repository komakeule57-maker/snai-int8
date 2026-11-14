# snai/revival-strom

```text
snai/revival-strom - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 19:33
Frage: Rechnet das Neuron-Revival Tensor für Tensor (Strom-Weg) bytegleich zum alten Weg: V1 Ausgabe, Log und Befundtabelle gleich in allen Fällen, V2 Endmodell im Training gleich, Rot-Probe weicht ab?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus der Kriteriendatei (enthält ERGEBNIS; Läufe rechner-b ~/snai_pruef/ramfix/rv 19:2x bis 19:4x).):
  Vorab rechner-a ~/snai_pruef/ramfix/kriterien_revival.txt (Auftrag 2026-10-15 ~19:00, 'geschrieben VOR dem ersten Test'): V1 alt gegen neu je Ausgabe-md5, Log-md5, Befundtabelle; V2 Endmodell md5-gleich; V3 RAM Beobachtung; Rot-Probe --rot muss in V1 abweichen.
Plan: rechner-a:~/snai_pruef/ramfix/kriterien_revival.txt (V1 bis V3 mit Rot-Probe)
Baut auf: snai/ramfix-bytegleich
Rezepte:
  r205 [2026-10-21] alt, neu, rot: patch_revival.py auf diagnose/snai_neuron_revival.php; SNAI_REVIVAL_ALT=1 = alter Weg
      quelltext: Arbeitskopie nach ramfix
      parameter: Eingaben 96 gebunden (V7), 96 ungebunden (V6), 512 gebunden; unverändert und mit toten Zeilen
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/ramfix/rv/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ramfix/kriterien_revival.txt (ERGEBNIS); Spitze ganzes Segment aus der Nachmessung (Doku 6ap), nicht aus dem ERGEBNIS-Block
  m2435 V1 alt = neu | 7 von 7 Fällen | V1 |  | 7
  m2436 V1 Ausgabe unverändert | 8fd54122 | 96 gebunden |  | 1
  m2437 V1 Rot weicht ab | 3680baa0, 41c51cec, 5aaadb06 | rot |  | 3
  m2438 V2 Endmodell | 8fd54122 | 96 gebunden |  | 2
  m2439 V3 Spitze Revival-Aufruf | 612,9 MB gegen 138,8 MB | alt gegen neu |  | 2
  m2440 Spitze ganzes Segment | 662,5 MB gegen 304 MB | alt gegen neu |  | 2
Ergebnis e195 [2026-10-21 19:33]: erfuellt
  Fazit: Der Strom-Weg ist bytegleich in allen Fällen, die Rot-Probe greift, und die Segmentspitze sinkt auf weniger als die Hälfte. Zusammen mit snai/ramfix-bytegleich ist das RAM-Ziel erreicht, ohne die Rechnung zu ändern.
  Datei: rechner-a:~/snai_pruef/ramfix/kriterien_revival.txt
Chronik:
  2026-10-21 19:32 angelegt (Nachtrag: Nachtrag 2026-10-21 aus der Kriteriendatei (enthält ERGEBNIS; Läufe rechner-b ~/snai_pruef/ramfix/rv 19:2x bis 19:4x).)
  2026-10-21 19:33 Rezept r205 (alt, neu, rot)
  2026-10-21 19:33 Status geplant -> laeuft (Rezept r205)
  2026-10-21 19:33 Messwerte m2435-m2440
  2026-10-21 19:33 Ergebnis e195: erfuellt
  2026-10-21 19:33 Status laeuft -> ausgewertet (Ergebnis e195)
```
