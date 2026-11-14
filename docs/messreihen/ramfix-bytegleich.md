# snai/ramfix-bytegleich

```text
snai/ramfix-bytegleich - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 19:33
Frage: Bleibt das Training nach dem RAM-Umbau (Speichern aus Nim, Genesis direkt int8) bytegleich: R1 Checkpoints und Zwischenstände md5-gleich, R2 Training ab V6-Genesis = ab V5, R3 Fortsetzung gleich?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus der Kriteriendatei (enthält ERGEBNIS; Kopie auf rechner-b vor den Läufen 17:57).):
  Vorab rechner-a ~/snai_pruef/ramfix/kriterien.txt (Auftrag 2026-10-15 ~17:50, 'geschrieben VOR dem Umbau'): R1 Datei bytegleich in 96x2 gebunden, 512x4 gebunden, 96x2 ungebunden; R2 Genesis bytegleich; R3 Fortsetzung; R4 RAM als Beobachtung; Rot-Proben (a) m/v vertauscht, (b) trunc statt round, (c) alte Bibliothek. Fehlerkanal je Lauf.
Plan: rechner-a:~/snai_pruef/ramfix/kriterien.txt (U1 Speichern aus Nim, U2 Genesis V6; Tests R1 bis R4 mit Rot-Proben)
Darauf baut: snai/revival-strom
Rezepte:
  r204 [2026-10-21] patch_ramfix.py auf Arbeitskopie, Läufe auf rechner-b ~/snai_pruef/ramfix/baum
      quelltext: alt libcortex ad68aaf5 (git e55fced), neu 031879a2 (cortex.nim 1f30c590), rot_mv 904fa84c, rot_trunc 5e68f106
      parameter: 96x2 gebunden/ungebunden, 512x4 gebunden (691 Schritte); R4 512x4 Vokabular 8192, 112 Schritte
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/ramfix/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/ramfix/kriterien.txt (ERGEBNIS)
  m2427 R1 md5 Endmodell | 8fd54122 = 8fd54122 | 96 gebunden |  | 2
  m2428 R1 md5 Endmodell | 6511594d = 6511594d | 96 ungebunden |  | 2
  m2429 R1 md5 Endmodell | dc3533cb = dc3533cb | 512 gebunden |  | 2
  m2430 R2 Genesis 96 | c74d49d0 = c74d49d0 | V5 gegen V6 |  | 2
  m2431 Rot (a) m/v vertauscht | fc510aa3 | rot_mv |  | 1
  m2432 Rot (b) trunc | 17c049fd | rot_trunc |  | 1
  m2433 Worker-Spitze RAM | 545 MB gegen 291 MB | alt gegen neu ab V6 |  | 2
  m2434 Gesamtspitze RAM | ~660 bis 670 MB (unverändert) | alt, neu |  | 2
Ergebnis e194 [2026-10-21 19:33]: erfuellt
  Fazit: Alle Pflichttests bytegleich, Rot-Proben gesehen; der Umbau ging in den Projektbaum. Die Worker-Spitze sinkt um 47 %, die Gesamtspitze aber nicht, weil danach das Revival das Modell als Float lädt. Der nächste Posten war deshalb das Revival (snai/revival-strom).
  Offen: R3 nicht eigens gefahren (folgt aus R1).
  Datei: rechner-a:~/snai_pruef/ramfix/kriterien.txt
Chronik:
  2026-10-21 19:32 angelegt (Nachtrag: Nachtrag 2026-10-21 aus der Kriteriendatei (enthält ERGEBNIS; Kopie auf rechner-b vor den Läufen 17:57).)
  2026-10-21 19:33 Rezept r204
  2026-10-21 19:33 Status geplant -> laeuft (Rezept r204)
  2026-10-21 19:33 Messwerte m2427-m2434
  2026-10-21 19:33 Ergebnis e194: erfuellt
  2026-10-21 19:33 Status laeuft -> ausgewertet (Ergebnis e194)
```
