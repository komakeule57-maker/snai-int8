# snai/kopier-prod512-beleg

```text
snai/kopier-prod512-beleg - ausgewertet, begonnen 2026-10-10, angelegt 2026-10-21, zuletzt 2026-10-21 11:21
Frage: Wo liegt der alte Lauf prod512 (s6, s19) auf dem Maßstab der Prompt-Bindung: Beleg-Anteil auf seltenen Token und Leseprobe mit erfundenen Eigennamen?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21 (Maßstab); Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  Ebene 1: Beleg-Anteil A = (fremd - passend) / fremd in Schicht A (Rang >= 200); unter 10 % = nicht vorhanden, ab 50 % vorhanden. Ebene 2 (Leseprobe): zehn Prompts mit erfundenen Eigennamen, Treffer = Name in den ersten 120 Wörtern der Fortsetzung; ab 5 vorhanden, 0-1 nicht vorhanden.
Baut auf: snai/kopier-prod512-s19
Darauf baut: snai/kopier-drohne-p, snai/prod512b-beleg
Rezepte:
  r28 [2026-10-21] Beleg-Anteil: tools/auswert_beleg_sonde_token.py auf factory/checkpoints/beleg_sonde_prod512_s6.jsonl und _s19.jsonl (Aufrufargumente k. A.); Leseprobe: tools/prompt_bindung.sh (Spur ROH, Beam 3; Argumente k. A.)
      parameter: Alter Lauf prod512 s6 und s19 (512/6/8, ctx 1024, int8, LR 0,001 konstant), altes Vokabular e5f04510; Beleg-Sonde 120 Posten, Rang >= 200; Leseprobe 10 Prompts, Beam 3
      rechner: Laptop
      logs: Laptop:~/.cache/prompt_bindung/prompt_bindung_prod512_s19.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  m218 Beleg-Anteil A (BA) | 2,2 % (B 0,9 %), fremd - passend +0,1211 | s6 |  | 120
  m219 Beleg-Anteil A (BA) | 4,5 % (B 1,9 %), fremd - passend +0,2259 (t 10,0) | s19 |  | 120
  m220 Leseprobe Prompt-Bindung | 0 von 10 | s19 |  | 10
Ergebnis e25 [2026-10-21 11:21]: verfehlt
  Fazit: Der alte Lauf liegt auf beiden Ebenen des Maßstabs bei „nicht vorhanden“ (Beleg-Anteil unter der Hälfte der 10-%-Schwelle, Leseprobe 0/10), passend zur Kopier-Sonde. Das ist die Rot-Eichung des Maßstabs; Grün hatte das Gerät damit noch nicht gesehen. Den Beleg-Anteil über 10 % erreichte erst Drohne Arm P (snai/kopier-drohne-p).
  Offen: Altes Vokabular; mit dem neuen ist Schicht A anders zusammengesetzt.
Chronik:
  2026-10-21 11:20 angelegt (Nachtrag: Nachgetragen 2026-10-21 (Maßstab); Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:20 Rezept r28
  2026-10-21 11:20 Status geplant -> laeuft (Rezept r28)
  2026-10-21 11:20 Messwerte m218-m220
  2026-10-21 11:21 Ergebnis e25: verfehlt
  2026-10-21 11:21 Status laeuft -> ausgewertet (Ergebnis e25)
```
