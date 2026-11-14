# snai/textknirps-g1024

```text
snai/textknirps-g1024 - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:31
Frage: 1024/64 x 2 im Textrezept auf der Karte (GPU-Adam und GPU-Rückwärts), 6 Segmente: (a) hält die Tempo-Hochrechnung aus dem Speedtest (~26 min je Segment)? (b) Was liefert das Modell nach 1,92 Mio Zeichen im Held-out und in den Leseproben?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-b:~/snai_pruef/knirps_gpu/text/kriterien.txt, Abschnitt 1024 x 2 AUF DER KARTE (2026-10-14, vor dem Start; Datei zuletzt 11:08:55, erster Segmentabschluss 11:36:17).):
  Eine Saat (Beobachtung). (a) Segmentzeit innerhalb 10 % von 26 min = Hochrechnung hält. (b) Held-out unter 10 % Abstand zu einem Bezug = Gleichstand; Bezug 256/16 x 2 fall bei Segment 5 (2,130-2,137) und Endstand Segment 19 (1,716-1,733). Breite und Abklinglänge ändern sich gemeinsam, kein Urteil "Breite hilft". "Brauchbares Inferenzergebnis" wird von Hand an den Leseproben beurteilt. Abbruch bei rc != 0, fehlender Schaltermeldung oder Wächtermeldung.
Plan: rechner-b:~/snai_pruef/knirps_gpu/text/kriterien.txt
Rezepte:
  r165 [2026-10-21] rechner-b: ~/snai_pruef/knirps_gpu/lauf_g1024.sh (Arm tx_d1024h64_g6_s1, SNAI_LR_DECAY_STEPS=29964, SNAI_I8_GPU_ADAM=1 SNAI_I8_GPU_BACKWARD=1, OMP 4)
      quelltext: proj_g1024 (Projektbaum 2026-10-14 mit GPU-Adam, gain_guard_enabled=0), libcortex.so md5 7db78a46d776, libcortex_cuda 78249867 (laut Kriterium), lauf_g1024.sh bcd3ec475830
      parameter: 1024/64 x 2, ffn 4096, ctx 64, zeichen-Vokabular, LR 0,001 -> 0,0001 über 6 Segmente, Warmup 500, WD 0,1, 1 Arbeiter
      seed: Genesis text_gen_d1024h64_s1 (init_base, Saat 1)
      rechner: rechner-b (RTX 3050)
      logs: rechner-b:~/snai_pruef/knirps_gpu/log/proj_g1024/tx_d1024h64_g6_s1.*
      notiz: Prüfung beim Nachtrag: Segmentzeiten, Held-out-Verlauf, Kontext und Rot-Probe aus Log und mess.jsonl nachgerechnet. Abstand Segment 5: 2,347/2,133 = +10,03 %, also knapp über der Schwelle (der frühere Befund sagt "schlechter", ohne die Knappheit zu nennen). 0 NET2NET-Meldungen.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/knirps_gpu/log/proj_g1024/tx_d1024h64_g6_s1.log, .mess.jsonl, .kontext.jsonl (nachgerechnet); Bezug aus log/proj_t/tx_d256h16_fall_s*.mess.jsonl
  m2003 Sekunden je Segment (n = Segmente) | 1642 / 1610 / 1609 / 1610 / 1665 / 1604 | 1024x2 | 1 | 6
  m2004 Held-out-Loss je Segment 0-5 (n = Fenster) | 2,760 / 2,701 / 2,606 / 2,501 / 2,458 / 2,347 | 1024x2 | 1 | 300
  m2005 Bezug 256x2 fall Segment 5 (n = Fenster) | 2,132 / 2,130 / 2,137 | 256x2 fall | 1/2/3 | 300
  m2006 Abstand Segment 5 gegen Bezug (1 gegen 3) | +10,0 % | 1024 gegen 256 fall | 1
  m2007 Kontext-Sonde k=8 / alles (n = Ziele) | 2,376 / 2,390 | 1024x2 | 1 | 1600
  m2008 Rot-Probe Loss | 5,135 | 1024x2 | 1 | 300
Ergebnis e155 [2026-10-21 19:24]: beobachtung
  Fazit: Das Tempo hält die Hochrechnung (1604-1665 s je Segment, innerhalb 10 % von 26 min). Im Held-out liegt der 1024er nach 6 Segmenten mit 2,347 schlechter als der 256er nach gleich viel Text (2,13; Abstand +10,03 %, knapp über der Schwelle), die Leseproben sind Silbenbrei. Mit einer Saat und gleichzeitig veränderter Abklinglänge sagt das nichts über Breite; nicht als "1024 lernt schlechter" zitieren. Für einen brauchbaren 1024er fehlen eine passende LR (0,001 vermutlich zu hoch) und viel mehr Text. Bezüge: Frage (a) baut auf dem Speedtest 1024 x 2 auf (Reihe snai/speedtest-1024x2 des Helfers technik, beim Eintrag noch nicht im Messbuch); der Vergleichsbezug (b) ist snai/textknirps-b256-tiefe.
  Offen: Zweite LR (z. B. 0,0003), weitere Saaten, mehr Budget.
  Datei: rechner-b:~/snai_pruef/knirps_gpu/text/kriterien.txt
Chronik:
  2026-10-21 19:24 angelegt (Nachtrag: Kriterium aus rechner-b:~/snai_pruef/knirps_gpu/text/kriterien.txt, Abschnitt 1024 x 2 AUF DER KARTE (2026-10-14, vor dem Start; Datei zuletzt 11:08:55, erster Segmentabschluss 11:36:17).)
  2026-10-21 19:24 Rezept r165
  2026-10-21 19:24 Status geplant -> laeuft (Rezept r165)
  2026-10-21 19:24 Messwerte m2003-m2008
  2026-10-21 19:24 Ergebnis e155: beobachtung
  2026-10-21 19:24 Status laeuft -> ausgewertet (Ergebnis e155)
  2026-10-21 19:31 Baut auf snai/speedtest-1024x2 (Tempo und Rezept 1024x2 auf der Karte) und snai/textknirps-b256-tiefe. Beim Anlegen stand speedtest-1024x2 noch nicht im Messbuch; ein Feld baut_auf lässt sich nachträglich nicht setzen, darum steht es hier.
```
