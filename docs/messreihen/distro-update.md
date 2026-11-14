# snai/distro-update

```text
snai/distro-update - ausgewertet, begonnen 2026-10-19, angelegt 2026-10-21, zuletzt 2026-10-21 19:33
Frage: Behebt die Distro-Aktualisierung (Zweig update-2026-10 von komakeule57-maker/SnAI) Vokabular und die vier Codefehler, ohne die Rechnung im Altfall zu ändern: K0 bis K9 grün, je mit gesehener Rot-Probe?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus der Kriteriendatei (enthält ERGEBNIS, mtime 2026-10-19 19:39).):
  Vorab rechner-a ~/snai_pruef/distro_update/kriterien.txt (2026-10-19, 'vorab, je Punkt grün + rot gesehen'): K0 Regression md5 neu = alt bei 1 und 3 Epochen; K1 Tokenizer 0 <unk>, Rundlauf exakt; K2 [USER]-Maske; K3 Killswitch; K4 Lernrate %F; K5 Exitcode; K6 Warmup/Abklingen; K7 Bereiniger; K8 bpe_forge; K9 Ende-zu-Ende neu/ mit neuem Vokabular.
Plan: rechner-a:~/snai_pruef/distro_update/kriterien.txt (alt/ main b5a3a66 gegen neu/ und neu0/, lauf.sh mit fester Genesis und Sitzungsname 'probe')
Rezepte:
  r207 [2026-10-21] alt, neu, neu0: bash distro_update/lauf.sh
      quelltext: alt = git archive main b5a3a66 (libcortex f69430fb), neu = Arbeitsstand Zweig update-2026-10
      parameter: Genesis genesis.snai 129f7049 (8192/128/512/2), Text text_k.txt (100 kB pseg01), 1 Arbeiter
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/distro_update/out/
      notiz: fp32-Hauptzweig, kein int8.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/distro_update/kriterien.txt (ERGEBNIS)
  m2453 K0 md5 1 Epoche | 6857edd7 = 6857edd7 | alt gegen neu0 |  | 2
  m2454 K0 md5 3 Epochen | e634d9d7 = e634d9d7 | alt gegen neu0 |  | 2
  m2455 K0 Rot LR 0,00050001 | 74057a10 | rot |  | 1
  m2456 K1 <unk> neues Vokabular | 0 | neu |  | 1
  m2457 K1 Token Rückwärtsverträglichkeit | 85.197 gleich | neu Tokenizer altes Vokabular |  | 1
  m2458 K2 Schritte | 55 gegen 1 | neu gegen alt |  | 2
  m2459 K3 Epochen | 5 gegen Abbruch nach 2 | neu gegen alt |  | 2
  m2460 K6 LR bei adam_t 1 / 4 / 12 | 0,000125 / 0,0005 / 0,00005 | neu |  | 1
  m2461 K4, K5, K7, K8, K9 | grün | neu |  | 5
Ergebnis e197 [2026-10-21 19:33]: erfuellt
  Fazit: Alle Punkte grün, jede Rot-Probe gesehen; der Altfall rechnet bytegleich. Eine Einschränkung gehört zu jedem Zitat: die 3-Epochen-Gleichheit hält nur, weil die Lernraten in %F exakt sind; bei mehr als sechs Nachkommastellen weicht neu bewusst ab.
  Datei: rechner-a:~/snai_pruef/distro_update/kriterien.txt
Chronik:
  2026-10-21 19:32 angelegt (Nachtrag: Nachtrag 2026-10-21 aus der Kriteriendatei (enthält ERGEBNIS, mtime 2026-10-19 19:39).)
  2026-10-21 19:33 Rezept r207 (alt, neu, neu0)
  2026-10-21 19:33 Status geplant -> laeuft (Rezept r207)
  2026-10-21 19:33 Messwerte m2453-m2461
  2026-10-21 19:33 Ergebnis e197: erfuellt
  2026-10-21 19:33 Status laeuft -> ausgewertet (Ergebnis e197)
```
