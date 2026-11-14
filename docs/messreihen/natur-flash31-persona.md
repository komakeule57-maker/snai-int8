# snai/natur-flash31-persona

```text
snai/natur-flash31-persona - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:32
Frage: Wirkt der Persona-Satz auch bei gemini-3.1-flash-lite, gepaart gemessen (gleicher Prompt je Paar, einziges Stellrad die Persona)?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/schluss/kriterien_natur.txt, Abschnitt 'PERSONA AUF 3.1, ISOLIERT' (laut Text vor dem Lauf, 2026-10-15 10:4x).):
  Behaltene Token je Anfrage nach gemeinsamem Filter. Persona gewinnt, wenn die Summe ueber 6 Paare >= 10 % hoeher ist UND sie in >= 5 von 6 Paaren vorn liegt; verliert spiegelbildlich; sonst Gleichstand. Paar mit Fehler faellt heraus.
Baut auf: snai/natur-flash35-persona
Rezepte:
  r82 [2026-10-21] php gemma/paar_persona.php (ruft build_prompt, call_gemini, parse_melody aus dem Geschichten-Sammler (Flash-3.5-Fassung) im SNAI_TEST_MODE)
      quelltext: gemma/paar_persona.php (Original-Funktionen, nicht nachgebaut)
      parameter: 6 Paare, Prompt wie 3.1-Dauerlauf (30 Gruppen, keine Wortliste), Reihenfolge im Paar wechselnd
      seed: mt_srand 101-106
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/schluss/arbeit/persona31/, arbeit/persona31.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/schluss/kriterien_natur.txt (Ergebnisabschnitt; aus der Kriteriendatei abgelesen, Filterlaeufe nicht nachgerechnet); Rohdaten arbeit/persona31/ vorhanden
  m826 behaltene Token Summe | 24.849 | Persona | 101-106 | 6
  m827 behaltene Token Summe | 24.420 | ohne | 101-106 | 6
  m828 Differenz | +1,8 % | Persona-ohne | 101-106 | 6
  m829 Persona vorn | 3 von 6 Paaren | Persona-ohne | 101-106 | 6
  m830 behalten | 49,7 % gegen 65,2 % | Persona/ohne | 101-106 | 1759/1413
  m831 Ein-Satz-Geschichten | 27,1 % gegen 18,2 % | Persona/ohne | 101-106
  m832 Fehler | 0 | beide |  | 12
Ergebnis e80 [2026-10-21 14:32]: gleichstand
  Fazit: Bei Flash 3.1 wirkt die Persona nicht: +1,8 %, vorn in 3 von 6 Paaren. Mehr und laengere Geschichten, aber mehr Ein-Satz-Geschichten und Wortschatz-Verwurf heben sich auf. Ein Paar lieferte in beiden Armen nur Ein-Satz-Geschichten: solche Ausreisser haengen am Prompt, nicht an der Persona - das relativiert auch den ungepaarten 3.5-Befund. 3.1-Dauerlauf bleibt ohne Persona.
  Offen: Dubletten wurden quer ueber die Arme in der Reihenfolge 'mit vor ohne' gestrichen (verschiebt eher gegen die Persona).
  Datei: rechner-a:~/snai_pruef/schluss/kriterien_natur.txt
Chronik:
  2026-10-21 14:31 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/schluss/kriterien_natur.txt, Abschnitt 'PERSONA AUF 3.1, ISOLIERT' (laut Text vor dem Lauf, 2026-10-15 10:4x).)
  2026-10-21 14:31 Rezept r82
  2026-10-21 14:31 Status geplant -> laeuft (Rezept r82)
  2026-10-21 14:31 Messwerte m826-m832
  2026-10-21 14:32 Ergebnis e80: gleichstand
  2026-10-21 14:32 Status laeuft -> ausgewertet (Ergebnis e80)
```
