# snai/noten-lehrer

```text
snai/noten-lehrer - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:22
!! ohne Kriterium
Frage: Welches Sprachmodell taugt als Lehrer für das Knirps-Notenkorpus: wie viele Antworten von Leanstral, Gemma-4-26b und Gemini 3.1 Flash-Lite bestehen parse_melody() aus dem Noten-Sammler (Format, Taktsummen, Lage, Sprünge)?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Rezepte:
  r157 [2026-10-21] k. A. (Noten-Sammler; Flash-Lite über dessen Startskript)
      quelltext: Noten-Sammler, Stand 2026-10-14 (md5 nicht festgehalten)
      parameter: Leanstral labs-leanstral-1-5-1, max_tokens 20000, 6 Prompt-Saaten mt_srand 101..106; Gemma-4-26b maxOutputTokens 15000, Probe 3 + Betrieb ~20 min; Gemini 3.1 Flash-Lite 30 Anfragen
      seed: Prompt-Saaten 101-106 (Leanstral), sonst k. A.
      rechner: rechner-a (API-Aufrufe)
      logs: rechner-a:~/Projekte/snai_edge_int8_lora/factory/noten/ (Sammelstand; Einzelprotokolle nicht nachgesehen)
      notiz: Prüfung beim Nachtrag: Nicht gegen Rohdaten geprüft (Sammlerprotokolle nicht gelesen); Zahlen aus den Arbeitsnotizen. Die Tonart-Sonde (snai/noten-tonart) maß nebenbei die Sammlermelodien: Flash-Lite-Dateien A 0,5-4,7 %, Gemma 0-1,1 %, Leanstral 1,3-6,0 % Fremdtöne (tonart.jsonl).
Messwerte (Groesse | Wert | Arm | Start | n):
 , nicht nachgerechnet
  m1710 Angenommen / Anfragen | 0 / 6 (5 mit Text) | Leanstral | 101-106 | 6
  m1711 Angenommen Probe | 1 / 3 | Gemma-4-26b |  | 3
  m1712 Angenommen Betrieb erste 20 min | 8 / 10 beantwortete | Gemma-4-26b |  | 10
  m1713 Angenommen | 16 / 30 (53 %) | Gemini 3.1 Flash-Lite |  | 30
  m1714 Token je Anfrage | ~585 | Gemini 3.1 Flash-Lite |  | 30
  m1715 Sekunden je Anfrage | 60-130 / ~200 / ~2 | Leanstral / Gemma / Flash-Lite
Ergebnis e147 [2026-10-21 19:22]: beobachtung
  Fazit: Leanstral taugt mit diesem Prompt nicht als Notenlehrer (0 von 6, musikalische Fehler), Gemma-4 liefert die meisten gültigen Melodien, Flash-Lite rund die Hälfte bei einem Bruchteil der Kosten und Zeit. Die Entscheidung "Gemma bleibt Lehrer, Flash-Lite als schneller Zusatz" stützt sich auf 6 bis 30 Anfragen ohne Vorab-Kriterium; für eine Wahl mit Gewicht wäre eine gleich große Probe je Modell mit gleichem Prompt nötig.
  Offen: Leanstral mit anderem Prompt; gleich große Proben.
Chronik:
  2026-10-21 19:22 angelegt (Nachtrag: Kein vorab festgelegtes Urteilskriterium gefunden; Messgröße (parse_melody besteht) und Entscheidung (Gemma bleibt Lehrer) sind vom 2026-10-14. Deshalb nur Beobachtung.)
  2026-10-21 19:22 Rezept r157
  2026-10-21 19:22 Status geplant -> laeuft (Rezept r157)
  2026-10-21 19:22 Messwerte m1710-m1715
  2026-10-21 19:22 Ergebnis e147: beobachtung
  2026-10-21 19:22 Status laeuft -> ausgewertet (Ergebnis e147)
```
