# snai/natur-gemma-wortvorgabe

```text
snai/natur-gemma-wortvorgabe - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:33
Frage: Liefert Gemma mehr Text je Prozess-Minute, wenn der Prompt 30 Geschichten mit je ~50 Woertern vorgibt (V2) statt der bisherigen Fassung (V1)?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/schluss/kriterien_natur.txt, Abschnitt 'GEMMA MIT WORTVORGABE' (laut Text vor dem Lauf, 2026-10-15 09:1x).):
  Text-Token nach Filter je Prozess-Minute, V2 gegen V1 (V1 aus den 4 laufenden Prozessen im selben Zeitfenster). Ab 10 % mehr gewinnt V2, darunter Gleichstand.
Rezepte:
  r91 [2026-10-21] Geschichten-Sammler V2 (1 Prozess, gleichzeitig zu den 4 V1-Prozessen), per SIGTERM beendet
      quelltext: Geschichten-Sammler V2 (md5 nicht festgehalten)
      parameter: V2: 30 Geschichten, je genau 6 Saetze, ~50 Woerter; 26B
      seed: -
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/schluss/gemma/logs, Ablage gemma/natur_v2/ (leer)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/schluss/kriterien_natur.txt (Ergebnisabschnitt; aus der Kriteriendatei abgelesen, Filterlaeufe nicht nachgerechnet)
  m888 Antworten | 4 | V2 |  | 4
  m889 Geschichten je Antwort | 15 (statt 30) | V2 |  | 4
  m890 Woerter je Antwort | 248-392 (Mittel 330) | V2 |  | 4
  m891 Woerter je Antwort | 238-434 (Mittel ~300) | V1
Ergebnis e89 [2026-10-21 14:33]: gleichstand
  Fazit: Gleichstand: Gemma folgt der Mengenvorgabe nicht und liefert weiter 15 Geschichten in gleicher Dauer und mit gleichem Verbrauch. V1 bleibt. Fuer kuenftige Quellen: Mengenvorgaben im Prompt sind bei Gemma kein Hebel.
  Offen: Nur 4 Antworten; der Vergleich lief ueber Woerter je Antwort, nicht ausdruecklich ueber Text-Token je Prozess-Minute nach Filter.
  Datei: rechner-a:~/snai_pruef/schluss/kriterien_natur.txt
Chronik:
  2026-10-21 14:32 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/schluss/kriterien_natur.txt, Abschnitt 'GEMMA MIT WORTVORGABE' (laut Text vor dem Lauf, 2026-10-15 09:1x).)
  2026-10-21 14:32 Rezept r91
  2026-10-21 14:32 Status geplant -> laeuft (Rezept r91)
  2026-10-21 14:33 Messwerte m888-m891
  2026-10-21 14:33 Ergebnis e89: gleichstand
  2026-10-21 14:33 Status laeuft -> ausgewertet (Ergebnis e89)
```
