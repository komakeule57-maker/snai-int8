# snai/segpruef-minilauf

```text
snai/segpruef-minilauf - ausgewertet, begonnen 2026-10-10, angelegt 2026-10-21, zuletzt 2026-10-21 19:26
Frage: Erkennt die Segmentprüfung den bekannten Fehler: wird der Arm 'alt' (vor dem Fix) rot und der Arm 'neu' grün, über 3 Stücke ab der prod512-Genesis?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus rechner-b ~/snai_pruef/segpruef/logs/mini_alt.log, mini_neu.log (mini_alt 2026-10-10 17:16).):
  Vorab im Kopf von segpruef/minilauf.sh: 'der Arm alt muss daran rot werden'; der Arm neu muss grün bleiben.
Plan: Je Arm 3 Stücke ab prod512-Genesis, Prüfung nach jedem Stück.
Baut auf: snai/segpruef-eichung
Rezepte:
  r170 [2026-10-21] alt, neu: bash segpruef/minilauf.sh alt|neu
      quelltext: segpruef/proj alt gegen neu
      parameter: 3 Stücke ab prod512-Genesis
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/segpruef/logs/mini_alt.log, mini_neu.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/segpruef/logs/mini_alt.log, mini_neu.log
  m2024 Prüfung rot ab Stück | 0 | alt |  | 1
  m2025 Held-out Stück 0, 1, 2 | 7,248 / 7,019 / 6,772 | alt |  | 3
  m2026 Prüfung | durchgehend grün | neu |  | 1
  m2027 Held-out Stück 0, 1, 2 | 7,296 / 7,124 / 6,967 | neu |  | 3
Ergebnis e160 [2026-10-21 19:26]: erfuellt
  Fazit: Die Prüfung schlägt beim alten Stand sofort an und schweigt beim neuen: das Messgerät sieht den Fehler, für den es gebaut wurde. Eine Lücke bleibt: Zwischenstände ohne Log (t25 bis t200) blieben auch im alten Arm grün, dort ist die Prüfung blind.
  Offen: Zwischenstände t25 bis t200 ohne Log werden nicht erkannt.
  Datei: rechner-b:~/snai_pruef/segpruef/minilauf.sh
Chronik:
  2026-10-21 19:26 angelegt (Nachtrag: Nachtrag 2026-10-21 aus rechner-b ~/snai_pruef/segpruef/logs/mini_alt.log, mini_neu.log (mini_alt 2026-10-10 17:16).)
  2026-10-21 19:26 Rezept r170 (alt, neu)
  2026-10-21 19:26 Status geplant -> laeuft (Rezept r170)
  2026-10-21 19:26 Messwerte m2024-m2027
  2026-10-21 19:26 Ergebnis e160: erfuellt
  2026-10-21 19:26 Status laeuft -> ausgewertet (Ergebnis e160)
```
