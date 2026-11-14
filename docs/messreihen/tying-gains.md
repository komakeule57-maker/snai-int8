# snai/tying-gains

```text
snai/tying-gains - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 17:22
Frage: Verstaerkt Weight Tying das Kippen der FFN-Gains in Schicht 2?
Kriterium (festgelegt 2026-11-02 13:19, vor dem ersten Messwert):
  Arm U = Rezept K1 aus snai/dauerclip-saaten (128x4, voll int8, SR, Clip 1, LR 0,003, WD 0,1, Warmup 500, kurz9000, 9.002 Schritte, Karte, Saaten 4-11, gleiche Genesis clip_gen_s<saat>) mit SNAI_TIE_EMBEDDINGS=0 (eigene w_out-Matrix aus der Genesis); K1 gebunden vorhanden. Messgroesse: Anteil L2.rms_ffn |g|<0,05 am Endstand, D = K1 - U je Saat. TYING VERSTAERKT: K1 > U in >= 6/8 UND mittleres D >= 20. TYING SCHWAECHT: U > K1 in >= 6/8 UND mittleres D <= -20. KEIN HEBEL: |mittleres D| < 10. Sonst OFFEN; innerhalb 2 Punkten um eine Schwelle nicht erfuellt. Gemeinsam aendert sich: Bindung UND Parameterzahl (eigene w_out) UND Startwert von w_out; der Vergleich trennt das nicht. Kontrollen: K1 s4 mit lauf_clip_u.sh und CLIP_TIE=1 md5 ee903784; U-Log ohne "Weight Tying aktiv", Endstand SNAI_V6 (Rot der Stellschraube); STEPS_DONE 9002; Fehlerkanal. Mitgeschrieben: Held-out, Norm, tot je Schicht. Reichweite: ein Rezept, kurzes Budget, nur Gains.
Baut auf: snai/dauerclip-saaten, snai/merkmal-gains-fp32, snai/wd-gains
Darauf baut: snai/tying-gains-lang, snai/lns-gains
Rezepte:
  r523 [2026-11-02] rechner-b ~/snai_pruef/clip/reihe_tie.sh: lauf_clip_u.sh (= lauf_clip.sh mit Stellrad CLIP_TIE) CLIP_GPU=1 CLIP_LR=0.003; K1U s4 mit CLIP_TIE=1 (Kontrolle), U s4-s11 mit CLIP_TIE=0 (SNAI_TIE_EMBEDDINGS=0)
      quelltext: clip/proj_clip Lib ccb10b0f, lauf_clip_u.sh, reihe_tie.sh
      rechner: rechner-b, Karte, nacheinander, parallel zu Evos Stufe B
      logs: rechner-b:~/snai_pruef/clip/laeufe/reihe_tie/, log/reihe_tie.log; rechner-a:~/snai_pruef/clip_rr/kanal_tie.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: log/reihe_tie.log, kanal_tie.jsonl, mess.jsonl der U- und K1-Laeufe (700 Fenster)
  m7614 Kontrolle K1U s4 md5 | ee903784 (= K1) | K1U
  m7615 Rot Stellrad: Endstand-Kennung / "Weight Tying aktiv" im Log | SNAI_V6 / 0 in 8/8 | U
  m7616 rc / STEPS_DONE / Fehlerzeilen | 0 / 9002 / 0 in 8/8 | U
  m7617 L2 tot Ende | 0,8 / 0,0 / 0,0 / 0,0 / 1,6 / 5,5 / 1,6 / 1,6 | U | s4-s11 | 8
  m7618 L2 tot Ende | 79,7 / 0,8 / 22,7 / 49,2 / 61,7 / 59,4 / 60,2 / 85,9 | K1 | s4-s11 | 8
  m7619 D = K1 - U je Saat | +78,9 +0,8 +22,7 +49,2 +60,1 +53,9 +58,6 +84,3 | K1 gegen U | s4-s11 | 8
  m7620 mittleres D / Median / K1 > U | 51,1 / 58,6 / 8 von 8 | K1 gegen U
  m7621 L1 tot Ende | 0 bis 3,9 % | U | s4-s11 | 8
  m7622 Held-out Ende | 2,8147 / 2,8471 / 2,8086 / 2,8316 / 2,8557 / 2,8572 / 2,8338 / 2,7869, Mittel 2,829 | U | s4-s11 | 8
  m7623 Held-out Ende | 2,6728 / 2,7087 / 2,6740 / 2,7131 / 2,6561 / 2,6937 / 2,6905 / 2,6650, Mittel 2,684 | K1 | s4-s11 | 8
  m7624 Held-out U schlechter als K1 | 8/8, Mittel +0,145 nats (5,4 %) | U gegen K1
Ergebnis e460 [2026-11-02 17:22]: erfuellt
  Fazit: TYING VERSTAERKT nach Wortlaut, deutlich: gebunden kippen im Mittel 52,5 % der L2-Gains, ungebunden 1,4 %, K1 > U in 8/8, mittleres D 51 Punkte (Schwelle 20). Vorbehalt, im Kriterium vorab benannt: der ungebundene Arm unterscheidet sich auch in Parameterzahl und Startwert von w_out und lernt in diesem Budget 0,145 nats (5,4 %) schlechter, 8/8. Zwei Lesarten: A) Tying treibt das Kippen (Ausgangsgradient auf den gebundenen Embeddings, Reststrom); B) Tying lernt schneller und erreicht frueher den Zustand, in dem der mittlere FFN entbehrlich ist. Gegenbelege zu B aus vorhandenen Daten (Evo): k4R/k4N lernen in denselben 9.002 Updates 0,36-0,38 nats weiter als K1 und kippen nicht staerker (41,7 / 40,9 gegen 52,5); R und B (Ratsche) liegen auf K1-Lernstand und kippen kaum; die Updatezahl ist bei U gleich. Held-out-Fortschritt als Treiber passt also nicht, A hat Vorsprung, ist aber nicht bewiesen (bei k4 sind Material und Rauschen anders). Sauberer Test laeuft: snai/tying-gains-lang. Ungebunden kippt mit anderem Rezept ebenfalls (snai/merkmal-gains-fp32): Tying ist Verstaerker, nicht Voraussetzung; fuer die Praxis bleibt es gesetzt (Held-out-Gewinn 0,145 gegen Zweigbeitrag hoechstens 0,02).
  Offen: snai/tying-gains-lang (laeuft, Karte, etwa 11 h): Lernstand-Abgleich. Norm der U-Laeufe nicht ausgewertet. Ein Rezept, ein Text.
  Datei: rechner-a:~/snai_pruef/clip_rr/ERGEBNIS_tying_gains.md
Abgeloest und ausgeblendet: 1 ergebnis - voll=True zeigt sie.
Chronik:
  2026-11-02 13:19 angelegt
  2026-11-02 17:16 Rezept r523
  2026-11-02 17:16 Status geplant -> laeuft (Rezept r523)
  2026-11-02 17:16 Messwerte m7614-m7624
  2026-11-02 17:16 Ergebnis e457: erfuellt
  2026-11-02 17:16 Status laeuft -> ausgewertet (Ergebnis e457)
  2026-11-02 17:22 Ergebnis e460: erfuellt, loest e457 ab
```
