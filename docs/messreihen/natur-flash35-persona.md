# snai/natur-flash35-persona

```text
snai/natur-flash35-persona - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:32
Frage: Hebt ein Persona-Satz vor dem Prompt ('groesster Kleinkindgeschichtenerzaehler der Welt') bei gemini-3.5-flash-lite den Anteil behaltener Geschichten gegenueber Probe 2 (gleicher Prompt ohne Persona)?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/schluss/kriterien_natur.txt, Abschnitt 'FLASH 3.5 PROBE 3 MIT PERSONA' (laut Text vor dem Lauf, 2026-10-15 10:2x).):
  Persona wirkt, wenn der Behaltanteil (gemeinsamer Wortschatz) gegenueber Probe 2 um >= 10 Prozentpunkte steigt; darunter Gleichstand. Vorbehalt vorab: 3 Anfragen je Arm.
Baut auf: snai/natur-flash35-zulassung
Darauf baut: snai/natur-flash31-persona, snai/natur-aufbereiten
Rezepte:
  r81 [2026-10-21] SNAI_NATUR_PERSONA=1 SNAI_NATUR_SAETZE=5 SNAI_NATUR_WORTLISTE=gemma/wortliste_1500.txt Geschichten-Sammler (Flash-3.5-Fassung) (Ablage natur_flash35_p3/)
      quelltext: Geschichten-Sammler (Flash-3.5-Fassung), Schalter SNAI_NATUR_PERSONA (assert Trefferzahl 1)
      parameter: 3 Anfragen je Arm, ungepaart (verschiedene Anfragen)
      seed: -
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/schluss/gemma/natur_flash35_p2, natur_flash35_p3
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/schluss/kriterien_natur.txt (Ergebnisabschnitt; aus der Kriteriendatei abgelesen, Filterlaeufe nicht nachgerechnet)
  m821 behalten | 38,9 % | Persona |  | 630
  m822 behalten (gleicher Wortschatz) | 18,7 % | ohne Persona (Probe 2) |  | 895
  m823 Differenz nach Wortlaut | +20,2 Punkte | Persona-ohne
  m824 Differenz ohne die Ein-Satz-Anfrage | +11,1 Punkte | Persona-ohne
  m825 Geschichten mit Wort ausserhalb der Liste | 65 % gegen 77 % | Persona-ohne
Ergebnis e79 [2026-10-21 14:32]: erfuellt
  Fazit: Nach Wortlaut wirkt die Persona bei 3.5 (+20 Punkte, ohne den Ausreisser +11). Mit 3 Anfragen je Arm ist das eine Beobachtung, kein gesicherter Befund; bei Flash 3.1 wirkt dieselbe Persona gepaart gemessen nicht (snai/natur-flash31-persona). Folge: Persona nur in der 3.5-Fassung.
  Offen: Nicht wiederholt, nicht gepaart.
  Datei: rechner-a:~/snai_pruef/schluss/kriterien_natur.txt
Chronik:
  2026-10-21 14:31 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/schluss/kriterien_natur.txt, Abschnitt 'FLASH 3.5 PROBE 3 MIT PERSONA' (laut Text vor dem Lauf, 2026-10-15 10:2x).)
  2026-10-21 14:31 Rezept r81
  2026-10-21 14:31 Status geplant -> laeuft (Rezept r81)
  2026-10-21 14:31 Messwerte m821-m825
  2026-10-21 14:32 Ergebnis e79: erfuellt
  2026-10-21 14:32 Status laeuft -> ausgewertet (Ergebnis e79)
```
