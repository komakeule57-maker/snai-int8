# snai/prod512-sft-bereinigung

```text
snai/prod512-sft-bereinigung - ausgewertet, begonnen 2026-09-16, angelegt 2026-10-21, zuletzt 2026-10-21 19:33
Frage: Verschwinden nach dem Tausch der Segmente pseg09..pseg39 gegen SFT-bereinigte Fassungen (2026-09-16, im laufenden Betrieb) die Assistenz-Floskeln und literalen [SYMBIO] aus der KORSETT-Spur der Referenz-Inferenz von prod512 bei s9 und s10?
Kriterium (nachgetragen, Beleg: Prüfpunkt (2026-09-16 05:51), ohne Zahlenschwelle; dass 'null Floskeln und null [SYMBIO]' die Lesart ist, steht erst im Ergebnis.):
  Woran man sieht, ob das reicht: an der KORSETT-Spur der Referenz-Inferenz bei s9/s10, nicht an der Held-out-Zahl (der Prüfsatz enthält 0 [USER]).
Baut auf: snai/prod512-referenz-inferenz
Rezepte:
  r208 [2026-10-21] php tools/korpus_sft_entfernen.php --ziel=factory/segments_prod_clean factory/segments_prod/pseg*.txt; Einsetzen auf dem Server mit tools/korpus_tausch_server.sh (Ursprünge nach factory/segments_prod_roh/); Prüfung mit tools/referenz_inferenz.sh wie snai/prod512-referenz-inferenz
      quelltext: rechner-a:~/Projekte/snai_edge_int8_lora/tools/korpus_sft_entfernen.php (Stand 2026-09-16 nicht festgehalten)
      parameter: Schnitt in Spannen, Grenze </s> oder alleinstehendes [SYMBIO]; pseg00..pseg08 bewusst unberührt
      seed: deterministisch
      rechner: rechner-a (Bau), vserver (Tausch und Training)
      logs: rechner-a:~/.cache/prod512/referenz_prod512_s8..s10.txt
Messwerte (Groesse | Wert | Arm | Start | n):
 , nicht nachgerechnet
  m2462 verseuchte Segmente | 24 von 40 | Korpus vorher |  | 40
  m2463 verworfene Spannen pseg09..39 | 46 von 384.482 (1,20 auf 1,18 GB) | Bereinigung |  | 31
  m2464 [USER] / [SYMBIO] / Systemaufforderungen danach | 0 / 0 / 0 | Bereinigung |  | 31
  Quelle: am 2026-10-21 mit tools/auswert_referenz_register.py aus rechner-a:~/.cache/prod512/referenz_prod512_sN.txt neu gezählt
  m2465 Assistenz-Floskeln KORSETT | 12 / 0 / 0 / 0 | prod512 s7 / s8 / s9 / s10 |  | 4
  m2466 literales [SYMBIO] KORSETT | 2 / 0 / 0 / 0 | prod512 s7 / s8 / s9 / s10 |  | 4
  m2467 Floskeln / [SYMBIO] KORSETT s11 bis s19 | 0 / 0 | prod512 |  | 4
Ergebnis e192 [2026-10-21 19:33]: erfuellt
  Fazit: Ja: ab s8 null Floskeln und null [SYMBIO] in der KORSETT-Spur, und das hielt bis s19. s9 war der eigentliche Wirksamkeitsnachweis, weil pseg09 vor dem Training getauscht wurde. Die Dosis aus pseg00..08 steckt im Modell, sichtbar wurde sie danach aber nicht mehr. Für prod512b gilt das nicht automatisch: dessen Korpus trägt wieder echte SFT-Dialoge in pseg00, pseg02, pseg03, pseg04; die KORSETT-Spur misst dort den Datenwechsel mit.
  Offen: Prüfpunkt ohne Zahlenschwelle vorab. s8 war schon sauber, obwohl pseg08 unbereinigt war; der Effekt folgt also dem Segmentinhalt, nicht nur der Bereinigung.
Chronik:
  2026-10-21 19:33 angelegt (Nachtrag: Prüfpunkt (2026-09-16 05:51), ohne Zahlenschwelle; dass 'null Floskeln und null [SYMBIO]' die Lesart ist, steht erst im Ergebnis.)
  2026-10-21 19:33 Rezept r208
  2026-10-21 19:33 Status geplant -> laeuft (Rezept r208)
  2026-10-21 19:33 Messwerte m2462-m2464
  2026-10-21 19:33 Messwerte m2465-m2467
  2026-10-21 19:33 Ergebnis e192: erfuellt
  2026-10-21 19:33 Status laeuft -> ausgewertet (Ergebnis e192)
```
