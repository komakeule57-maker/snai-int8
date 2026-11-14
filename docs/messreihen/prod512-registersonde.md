# snai/prod512-registersonde

```text
snai/prod512-registersonde - ausgewertet, begonnen 2026-09-23, angelegt 2026-10-21, zuletzt 2026-10-21 19:31
Frage: Trifft prod512 s16 in der 30-Prompt-Registersonde (6 Register x 5 Prompts) nachweisbar öfter das erwartete Register als die früheren Stände s1, s5, s9 und s11, in beiden Spuren?
Kriterium (nachgetragen, Beleg: Kriterium (2026-10-02, 'vorab'); Markerliste eingefroren (2026-09-23). Die Messung s1/s5/s9/s11 vom 2026-09-23 lief ohne schriftliche p-Schwelle.):
  McNemar gepaart je Spur (gleicher Prompt, gleicher deterministischer Beam), exakter Test p < 0,05 = Unterschied, sonst 'nicht nachweisbar'. Markerliste vor der ersten Messung eingefroren (tools/registersonde_marker.py).
Baut auf: snai/prod512-referenz-inferenz
Rezepte:
  r199 [2026-10-21] bash tools/registersonde.sh factory/checkpoints/prod512_sN.snai (~95 min je Stand); bei Abbruch SKIP_K=<n> bash ~/.cache/prod512/registersonde_fortsetzen.sh; Auswertung python3 tools/auswert_registersonde.py sA sB
      quelltext: tools/registersonde.sh md5 9e78c4ea…, registersonde_marker.py md5 f6394e80…, auswert_registersonde.py md5 98b80059…, Promptsatz registersonde_prompts.tsv md5 d2e8ba79…
      parameter: 30 Prompts x 2 Spuren (KORSETT, ROH), Beam 3; Register bio, film, geo, musik, sport, tech
      seed: deterministischer Beam
      rechner: rechner-a
      logs: rechner-a:~/.cache/prod512/sonde30_prod512_sN.txt, sonde30_roh_prod512_sN.txt, sonde30_lauf_*.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: am 2026-10-21 mit rechner-a:~/Projekte/snai_edge_int8_lora/tools/auswert_registersonde.py aus den sonde30-Spuren neu ausgewertet
  m2388 Treffer KORSETT / ROH | 5 / 5 | prod512 s1 |  | 30
  m2389 Treffer KORSETT / ROH | 10 / 16 | prod512 s5 |  | 30
  m2390 Treffer KORSETT / ROH | 13 / 20 | prod512 s9 |  | 30
  m2391 Treffer KORSETT / ROH | 9 / 15 | prod512 s11 |  | 30
  m2392 Treffer KORSETT / ROH | 15 / 17 | prod512 s16 |  | 30
  m2393 McNemar s1->s16 KORSETT | 12:2, p 0,013 | prod512 |  | 30
  m2394 McNemar s1->s16 ROH | 12:0, p < 0,001 | prod512 |  | 30
  m2395 McNemar s5->s16 KORSETT / ROH | 8:3 p 0,227 / 3:2 p 1,0 | prod512 |  | 30
  m2396 McNemar s9->s16 KORSETT / ROH | 6:4 p 0,754 / 0:3 p 0,25 | prod512 |  | 30
  m2397 McNemar s11->s16 KORSETT / ROH | 9:3 p 0,146 / 4:2 p 0,688 | prod512 |  | 30
  m2398 tech-Register Treffer | 0 von 5 auf jedem Stand, beide Spuren | prod512 |  | 5
 ; nicht nachgerechnet
  m2399 Korsetteffekt gepoolt s5+s9+s11 (ROH richtig : KORSETT richtig) | 24:5, p 0,00055 | prod512 |  | 90
  m2400 Korpusdichte tech-Marker | 59 je MB (sport 570, geo 444) | Korpus |  | 1
  m2401 Markerwörter als ein Token tech | 11 % (bio 53 %) | Vokabular e5f04510 |  | 1
Ergebnis e187 [2026-10-21 19:31]: teilweise
  Fazit: Gegen s1 ist s16 in beiden Spuren nachweisbar besser, gegen s5, s9 und s11 in keiner. 30 Prompts trennen den großen Sprung s1->s5, nicht Abstände von fünf bis elf Segmenten. Die Sonde ist damit ein Kollaps-Wächter, kein Fortschrittsmaß; Segmentfortschritt misst ab s5 nur der Held-out. Zwei Nebenbefunde gelten weiter: das Korsett kostet rund 20 Prozentpunkte Registertreue und die Lücke öffnete sich erst nach s1 (gepoolt p 0,00055); ein technisches Register fehlt ganz, weil es im Korpus dünn und im alten Vokabular zerstückelt ist.
  Offen: Ein weiterer Lauf lohnt erst am Laufende oder mit deutlich mehr Prompts.
Chronik:
  2026-10-21 19:31 angelegt (Nachtrag: Kriterium (2026-10-02, 'vorab'); Markerliste eingefroren (2026-09-23). Die Messung s1/s5/s9/s11 vom 2026-09-23 lief ohne schriftliche p-Schwelle.)
  2026-10-21 19:31 Rezept r199
  2026-10-21 19:31 Status geplant -> laeuft (Rezept r199)
  2026-10-21 19:31 Messwerte m2388-m2398
  2026-10-21 19:31 Messwerte m2399-m2401
  2026-10-21 19:31 Ergebnis e187: teilweise
  2026-10-21 19:31 Status laeuft -> ausgewertet (Ergebnis e187)
```
