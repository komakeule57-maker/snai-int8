# snai/kopier-prod512b-s0

```text
snai/kopier-prod512b-s0 - ausgewertet, begonnen 2026-10-11, angelegt 2026-10-21, zuletzt 2026-10-21 11:22
Frage: Bleibt der Neustart prod512b (512/6/8, ctx 1024, LR 0,0001, Warmup 500, Cosinus, WD 0,1) in Segment 0 ungesättigt (Ampel grün), und zeigt die Kopier-Sonde schon etwas?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt (Ampel als Gesundheitsprüfung; eine Schwelle speziell für Kopieren steht nicht in den Einträgen)):
  Ampel aus tools/segment_ampel.py bzw. Segmentprüfung der Checkliste, je Kennzahl: att_max_gewicht < 0,5, grad_vo > 0,20 (u. a. auch qk_rms, Kopierrate, clip, lr, warmup, wd).
Baut auf: snai/kopier-mini-lr-reihe, snai/kopier-vokprobe
Darauf baut: snai/kopier-icl-praefix, snai/kopier-prod512b-pos, snai/prod512b-s0-prognose, snai/prod512b-lauf
Rezepte:
  r30 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben; Startskript run_prod512b_server.sh, Dienst snai-train)
      parameter: prod512b: 512/6/8, ctx 1024, int8, neues Vokabular f020d0ca; LR 0,0001, Warmup 500, Cosinus (decay 401012), WD 0,1, 8 Köpfe, 1 Arbeiter; Segment 0 = 10.552 Schritte, ~26,4-26,6 s je Schritt
      rechner: vserver
      logs: vserver:~/.cache/prod512b/lauf.log, pruefung_s0.txt, heldout_s0.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  m239 att_max_gewicht / grad_vo / Kopierrate t500 | 0,098 / 0,43 / 0 | prod512b
  m240 att_max_gewicht / grad_vo / Kopierrate t1000 | 0,162 / 0,40 / 0 | prod512b
  m241 att_max_gewicht Segment 0 Ende | 0,199 | prod512b
  m242 grad_vo Segment 0 Ende | 0,436 | prod512b
  m243 Kopierrate Segment 0 Ende | 0,0014 (fremd 0,001) | prod512b
  m244 Held-out Segment 0 | 4,8775 (PPL 131), Lücke zum Training 0,244 | prod512b |  | 64
  m245 Segmentprüfung | grün in allen Punkten | prod512b
Ergebnis e27 [2026-10-21 11:22]: erfuellt
  Fazit: Das neue Rezept hält prod512b in Segment 0 ungesättigt (Segmentprüfung grün in allen Punkten, att_max 0,199 statt 0,87-0,98 beim alten Rezept). Gesund heißt aber noch nicht kopierend: die Kopierrate liegt nach Segment 0 auf Zufallsniveau (0,0014 gegen fremd 0,001). Ob prod512b später nach Inhalt kopiert, zeigt erst snai/kopier-prod512b-pos (s1/s2).
  Offen: Ein Lauf. Segment 0 dauerte 76 h.
Chronik:
  2026-10-21 11:21 angelegt (Nachtrag: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt (Ampel als Gesundheitsprüfung; eine Schwelle speziell für Kopieren steht nicht in den Einträgen))
  2026-10-21 11:21 Rezept r30
  2026-10-21 11:21 Status geplant -> laeuft (Rezept r30)
  2026-10-21 11:21 Messwerte m239-m245
  2026-10-21 11:22 Ergebnis e27: erfuellt
  2026-10-21 11:22 Status laeuft -> ausgewertet (Ergebnis e27)
```
