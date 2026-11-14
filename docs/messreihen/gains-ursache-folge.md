# snai/gains-ursache-folge

```text
snai/gains-ursache-folge - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 13:56
Frage: Wird der FFN-Zweig der Schicht 2 nutzlos, bevor seine Gains kippen (Kippen = Folge), oder ist er noch nuetzlich, solange die Gains leben (Kippen = Ursache oder Verlust)?
Kriterium (festgelegt 2026-11-02 13:19, vor dem ersten Messwert):
  Kein Training. Modelle: K1 s4-s11 aus snai/dauerclip-saaten (rechner-b clip/laeufe/reihe_dc), Staende t=1000, t=3000, Ende 9002. Arme je Stand mit ms_null/werkzeug/nullsetzen.php (Gewichte exakt 0, Skalen und Adam unberuehrt): A0 unveraendert, NF2 w_down Schicht 2 = 0, NF0 w_down Schicht 0 = 0 (Kontrollschicht mit lebenden Gains). Held-out mit clip/text/mess_text.php, 700 Fenster, Lib proj_clip ccb10b0f, Waechter im Quelltext aus. D_i = Loss(NF_i) - Loss(A0) in nats je Saat und Stand. Geraet je Stand: A0 gleich dem Wert in mess.jsonl des Laufs; D_0 >= 0,05 in 8/8 Saaten, sonst ist der Stand ungueltig. Lebend heisst tot L2.rms_ffn <= 5 % am Stand (aus kanal_clip.jsonl). NUTZLOS VOR DEM KIPPEN: an t=3000 mit lebenden Gains D_2 <= 0,02 UND D_2 <= 0,2 x D_0 in >= 6/8 Saaten. NUETZLICH VOR DEM KIPPEN: an t=3000 D_2 >= 0,05 in >= 6/8. Sonst OFFEN; innerhalb 0,005 nats um eine Schwelle nicht erfuellt. Beobachtung ohne Urteil: D_2 am Ende getrennt nach Saaten mit tot >= 50 % und < 20 %; Spearman D_2(3000) gegen tot(Ende). Reichweite: ein Rezept (128x4, LR 0,003, kurz9000), Schicht 2 gegen Schicht 0, t=1000 nur Beobachtung.
Baut auf: snai/dauerclip-saaten, snai/ffn-null-512, snai-evo/lese
Darauf baut: snai/gains-vertretung, snai/ratsche-k64, snai/ffn2-null-training
Rezepte:
  r513 [2026-11-02] rechner-b ~/snai_pruef/uf/lauf.sh: je Saat 4-11 und Stand t1000/t3000/Ende: nullsetzen.php <stand> <arm.snai> "" | "2:w_down" | "0:w_down"; php clip/text/mess_text.php <arm.snai> daten/heldout.txt daten/ngram.json 700 0
      quelltext: ms_null/werkzeug/nullsetzen.php, clip/text/mess_text.php, Lib proj_clip ccb10b0f
      rechner: rechner-b, CPU
      logs: rechner-a:~/snai_pruef/uf/ (erg.jsonl, log/, ERGEBNIS_ursache_folge.md)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: uf/erg.jsonl, D = Loss(NF) - Loss(A0) in nats, 700 Fenster; tot L2 aus kanal_clip.jsonl
  m7515 Geraet A0 md5 = Original, Werte = mess.jsonl | ja, 24/24 | A0
  m7516 Geraet D0 >= 0,05 | 8/8 je Stand, 3,24 bis 5,96 | NF0
  m7517 D2 t1000 | -0,0044 bis +0,0030, Median -0,0011 | NF2 | s4-s11 | 8
  m7518 D2 t3000 | -0,0030 bis +0,0056, Median +0,0003 | NF2 | s4-s11 | 8
  m7519 D2 Ende | -0,0015 bis +0,0195, Median +0,0013 | NF2 | s4-s11 | 8
  m7520 tot L2 t3000 | 0 bis 1,6 % | A0 | s4-s11 | 8
  m7521 tot L2 Ende | 0,8 bis 85,9 %, Mittel 52,5 | A0 | s4-s11 | 8
  m7522 NUTZLOS-Bedingung t3000 (D2 <= 0,02 und <= 0,2 D0) | 8/8 | NF2
  m7523 NUETZLICH-Bedingung t3000 (D2 >= 0,05) | 0/8 | NF2
  m7524 D2 Ende bei tot >= 50 % / tot < 20 % | -0,0015..+0,0042 (5) / +0,0195 (nur s5) | NF2
  m7525 Spearman D2(3000) gegen tot(Ende) | -0,38 |  |  | 8
Ergebnis e448 [2026-11-02 13:56]: erfuellt
  Fazit: Befund: NUTZLOS VOR DEM KIPPEN nach Wortlaut, 8/8 an t=3000 und ebenso an t=1000 und Ende: Schicht 2 allein herausgenommen aendert den Held-out um weniger als 0,006 nats, Kontrollschicht 0 kostet 3 bis 6 nats. Deutung, nicht gemessen: Das Kippen ist Folge eines beitragslosen Zweigs. Zwei Einwaende (Evo, 2026-11-02) halten die Deutung offen: (1) Vertretung, einzeln still sagt nichts, wenn Schicht 1 und 2 einander vertreten (snai/ffn-null-512: einzeln 0,1-3,5 %, Mitte gemeinsam 44-52 %); (2) Herausnehmen misst das eingestellte Modell, nicht ob der Zweig beim Lernen half, und Reihenfolge ist kein Eingriff. Gegenproben vorgeschlagen, nicht gestartet: NF1+NF2 zugleich an denselben Staenden; NF2 an Evos R-Staenden (Ratsche, Gains leben) bei 9002.
  Offen: Vertretung durch Schicht 1 nicht geprueft; Lernhilfe des Zweigs nicht geprueft; ein Rezept, 9.002 Schritte; Saat 5 +0,0195 Einzelwert. "Kostet nichts" gilt nur fuer dieses Budget.
  Datei: rechner-a:~/snai_pruef/uf/ERGEBNIS_ursache_folge.md
Abgeloest und ausgeblendet: 1 ergebnis - voll=True zeigt sie.
Chronik:
  2026-11-02 13:19 angelegt
  2026-11-02 13:55 Rezept r513
  2026-11-02 13:55 Status geplant -> laeuft (Rezept r513)
  2026-11-02 13:55 Messwerte m7515-m7525
  2026-11-02 13:55 Ergebnis e447: erfuellt
  2026-11-02 13:55 Status laeuft -> ausgewertet (Ergebnis e447)
  2026-11-02 13:56 Ergebnis e448: erfuellt, loest e447 ab
```
