# snai/gesamt-fix

```text
snai/gesamt-fix - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 11:43
Frage: Rechnen die Korrekturen 4, 5, 7, 8, 9 zusammen auf gesunden Staenden bitgleich zum Stand davor, abgesehen vom Waechter?
Kriterium (festgelegt 2026-11-02 11:34, vor dem ersten Messwert):
  Echter train_worker, alt = Lib 9d02d504 (cortex 080bceaf, vor Punkt 4), neu = aktueller Baum cortex 2cfaaa0f. K1 c128sr s8 mit toten Gains: alt gegen neu mit SNAI_GAIN_GUARD=1, Schrittzeilen und Ergebnis-md5 gleich. K2 prod512b_s1 ohne Waechtermeldung: alt gegen neu Vorgabe, gleich. K3 c128sr s8 mit OMP 4 von Anfang an: alt gegen neu mit SNAI_GAIN_GUARD=1, und neu a gegen neu b, gleich; ist schon alt a gegen alt b ungleich, traegt K3 keinen Schluss. Rot: neu Vorgabe auf c128sr s8 MUSS von K1 abweichen, weil der Waechter dort nichts mehr korrigiert; bleibt es gleich, kann der Vergleich den Unterschied nicht sehen. Bestanden nur bei allen. Reichweite: zwei Modellgroessen, kurzer Chunk, CPU, kein GPU-Pfad und kein Held-out-Pfad.
Baut auf: snai/nan-gains, snai/nan-quant
Rezepte:
  r508 [2026-11-02] rechner-b ~/snai_pruef/gesamt/lauf.sh: train_worker.php chunk o.snai 1 base 3 0.0001 1 0.0001 0.1 0 0, alt gegen neu
      quelltext: alt 9d02d504 (cortex 080bceaf), neu cf5f2c73 (cortex 2cfaaa0f)
      rechner: rechner-b
      logs: rechner-a:~/snai_pruef/gesamt/ (erg.txt, *.st, *.log)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: gesamt/erg.txt
  m7443 K1 Ergebnis-md5, Zeilen 33 | 1022400f4c33 gleich | c128sr alt / neu Waechter an
  m7444 K2 Ergebnis-md5, Zeilen 6 | 5ef68a587b04 gleich | prod512b_s1 alt / neu
  m7445 K3 Ergebnis-md5 OMP 4, alt a/b und neu a/b | 1022400f4c33 alle gleich und gleich K1 | c128sr
  m7446 Rot abweichende Zeilen | 33/33, md5 03b6d85cc631 | neu Vorgabe
  m7447 Loss Schritt 145 | 4,528332 | Waechter korrigiert
  m7448 Loss Schritt 145 | 4,674937 | Waechter meldet nur
Ergebnis e441 [2026-11-02 11:43]: erfuellt
  Fazit: Die Korrekturen zusammen aendern auf gesunden Staenden nichts ausser der gewollten Waechter-Vorgabe; Commit und Bibliothekstausch sind von dieser Seite frei.
  Offen: Kein GPU- und kein Held-out-Pfad, kurzer Chunk. K3 gleich K1 kann heissen, dass OMP 4 hier nicht wirkte. Loss-Unterschied Waechter ist ein Einzellauf, kein Befund.
Chronik:
  2026-11-02 11:34 angelegt
  2026-11-02 11:43 Rezept r508
  2026-11-02 11:43 Status geplant -> laeuft (Rezept r508)
  2026-11-02 11:43 Messwerte m7443-m7448
  2026-11-02 11:43 Ergebnis e441: erfuellt
  2026-11-02 11:43 Status laeuft -> ausgewertet (Ergebnis e441)
```
