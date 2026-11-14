# snai/prod512b-s0-prognose

```text
snai/prod512b-s0-prognose - ausgewertet, begonnen 2026-10-11, angelegt 2026-10-21, zuletzt 2026-10-21 19:35
Frage: Treffen die am 2026-10-11 bei Schritt 1905 aufgeschriebenen Bänder für das Ende von Segment 0 von prod512b (Held-out, Lücke, Attention-Kennzahlen, grad_vo, Kopierrate, Beleg-Anteil, Leseprobe) die Messwerte der Segmentprüfung?
Kriterium (nachgetragen, Beleg: Kriterium (2026-10-11 11:35, bei Schritt 1905, vor dem Ergebnis).):
  Treffer = Messwert im Band. Held-out (64 Fenster) 4,8 bis 5,3; Lücke Held-out minus Training 0,05 bis 0,15; att_max_gewicht 0,25 bis 0,40; att_logit_std 1,8 bis 2,6; grad_vo 0,33 bis 0,40; att_h_rel 0,60 bis 0,75; clip_anteil >= 0,95; qk_rms_faktor 0,95 bis 1,10; Ampel gesamt grün; Kopierrate unter 1 %; Beleg-Anteil A 1 bis 3 %; Leseprobe 0 oder 1 von 10. Überraschung wäre: att_max >= 0,5, Held-out > 5,4, Beleg-Anteil oder Kopierrate >= 10 %.
Baut auf: snai/kopier-prod512b-s0
Rezepte:
  r220 [2026-10-21] Segmentprüfung nach Segmentende durch run_prod512b_server.sh (tools/segment_ampel.py); Held-out eval_held_out_full_i8.php … auto 64
      quelltext: wie snai/prod512b-lauf (Stand Segment 0)
      parameter: Grundlage der Prognose: Zwischenstände t500/t1000, Loss-Kurve bis Schritt 1900, Drohne Arm E über dieselben Token
      rechner: vserver
      logs: vserver:~/.cache/prod512b/pruefung_s0.txt, heldout_s0.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: vserver:~/.cache/prod512b/pruefung_s0.txt und heldout_s0.txt, abgelesen 2026-10-21; Bänder
  m2535 Held-out | 4,8775 (im Band) | prod512b s0 |  | 64
  m2536 Lücke Held-out minus Training | 0,2437 (außerhalb, Band 0,05 bis 0,15) | prod512b s0 |  | 64
  m2537 att_max_gewicht | 0,1994 (außerhalb, Band 0,25 bis 0,40) | prod512b s0 |  | 1
  m2538 att_logit_std | 1,436 (außerhalb, Band 1,8 bis 2,6) | prod512b s0 |  | 1
  m2539 grad_vo | 0,436 (außerhalb, Band 0,33 bis 0,40) | prod512b s0 |  | 1
  m2540 att_h_rel | 0,7196 (im Band) | prod512b s0 |  | 1
  m2541 clip_anteil | 1 (im Band) | prod512b s0 |  | 1
  m2542 qk_rms_faktor | 1,006 (im Band) | prod512b s0 |  | 1
  m2543 Ampel gesamt | grün (Treffer) | prod512b s0 |  | 1
  m2544 Kopierrate | 0,0014 (im Band) | prod512b s0 |  | 1408
  m2545 Treffer gesamt (ohne Beleg-Anteil und Leseprobe) | 6 von 10 | prod512b s0 |  | 10
Ergebnis e207 [2026-10-21 19:35]: teilweise
  Fazit: Der Held-out traf das Band, die Ampel blieb grün, und keine der vorab benannten Überraschungen trat ein. Daneben lag die Prognose bei der Form der Attention: sie blieb flacher und weicher als erwartet (att_max 0,20 statt 0,25 bis 0,40, logit_std 1,44 statt ab 1,8), V/O bekam mehr Gradient, und die Lücke zum Training war mit 0,24 deutlich größer. Die Drohne als Vorlage überschätzte also, wie schnell sich die Attention in dim 512 schärft. Für spätere Prognosen: Loss-Bänder aus der Kurve tragen, Attention-Bänder aus einer kleineren Geometrie nicht.
  Offen: Beleg-Anteil und Leseprobe nach s0 nicht als Messwert gefunden (gehören ggf. zu snai/kopier-prod512b-s0 oder snai/kopier-prod512b-pos). Ein Lauf.
Chronik:
  2026-10-21 19:35 angelegt (Nachtrag: Kriterium (2026-10-11 11:35, bei Schritt 1905, vor dem Ergebnis).)
  2026-10-21 19:35 Rezept r220
  2026-10-21 19:35 Status geplant -> laeuft (Rezept r220)
  2026-10-21 19:35 Messwerte m2535-m2545
  2026-10-21 19:35 Ergebnis e207: teilweise
  2026-10-21 19:35 Status laeuft -> ausgewertet (Ergebnis e207)
```
