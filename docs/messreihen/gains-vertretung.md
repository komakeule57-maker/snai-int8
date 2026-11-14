# snai/gains-vertretung

```text
snai/gains-vertretung - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 15:00
Frage: Gegenproben zu snai/gains-ursache-folge (Einwaende Evo): A) Vertreten sich Schicht 1 und 2, so dass "Schicht 2 allein still" nichts ueber den Zweig sagt? B) Traegt der FFN-Zweig der Schicht 2 etwas bei, wenn die Ratsche seine Gains am Leben haelt (R-Staende aus snai/gains-v)?
Kriterium (festgelegt 2026-11-02 14:00, vor dem ersten Messwert):
  Kein Training, Werkzeug wie gains-ursache-folge (nullsetzen.php, mess_text 700 Fenster, Lib proj_clip, CPU rechner-b). A) K1 s4-s11, Staende t1000/t3000/Ende, neue Arme NF1 (w_down Schicht 1 = 0) und NF12 (w_down Schicht 1 und 2 = 0); vorhandene A0, NF2. Grenzkosten von Schicht 2 ohne Schicht 1: M2 = D12 - D1 = Loss(NF12) - Loss(NF1). VERTRETUNG: M2 >= 0,05 nats in >= 6/8 Saaten an t=3000 ODER am Ende. KEINE VERTRETUNG: M2 <= 0,02 in >= 6/8 an t=3000 UND am Ende. Sonst OFFEN; innerhalb 0,005 um eine Schwelle nicht erfuellt. Beobachtung: D1 selbst (traegt Schicht 1 bei?). B) R-Staende s4-s11 (clip/laeufe/reihe_gv/R_s*, Ratsche auf Gewichten, Gains leben), Staende t1000/t3000/Ende, Arme A0, NF2, NF0. D2R = Loss(NF2) - Loss(A0). OHNE BEITRAG: D2R <= 0,02 UND <= 0,2 x D0 in >= 6/8 am Ende. BEITRAG: D2R >= 0,05 in >= 6/8 am Ende. Sonst OFFEN; knapp 0,005. Geraet: A0 bytegleich Original und gleich mess.jsonl; D0 >= 0,05 in 8/8 je Stand; tot L2 der R-Staende aus den Gains gelesen (soll < 5 % am Ende, sonst ist B nicht der verlangte Fall). Reichweite: ein Rezept, 9.002 Schritte; B misst das eingestellte Modell mit lebenden Gains, nicht die Lernhilfe im Verlauf; "kostet nichts" bleibt auf dieses Budget beschraenkt.
Baut auf: snai/gains-ursache-folge, snai/gains-v, snai/ffn-null-512
Darauf baut: snai/ffn2-null-training, snai/gains-nf-ratsche-b, snai/lns-gains
Rezepte:
  r516 [2026-11-02] rechner-b ~/snai_pruef/uf2/lauf.sh: A) nullsetzen.php K1-Stand "1:w_down" bzw. "1:w_down,2:w_down", B) nullsetzen.php R-Stand "" | "2:w_down" | "0:w_down"; je mess_text.php 700 Fenster; kanal.php an den R-Staenden
      quelltext: ms_null/werkzeug/nullsetzen.php, clip/text/mess_text.php, Lib proj_clip ccb10b0f; R-Staende aus snai/gains-v (clip/laeufe/reihe_gv/R_s4-s11)
      rechner: rechner-b, CPU, 120 Messpunkte, Fehlerkanal 0 Byte
      logs: rechner-a:~/snai_pruef/uf2/ (erg.jsonl, kanal_r.jsonl, log/), K1-Werte aus uf/erg.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: uf2/erg.jsonl mit uf/erg.jsonl; nats, 700 Fenster; tot L2 aus kanal_r.jsonl
  m7562 A M2 = NF12 - NF1, t3000 | -0,0040 bis +0,0092, Median +0,0023 | K1 | s4-s11 | 8
  m7563 A M2 Ende | -0,0002 bis +0,0313 (s5), Median +0,0026 | K1 | s4-s11 | 8
  m7564 A KEINE VERTRETUNG (M2 <= 0,02) t3000 / Ende | 8/8 / 7/8 | K1
  m7565 A VERTRETUNG (M2 >= 0,05) | 0/8 an beiden Staenden | K1
  m7566 A D1 = NF1 - A0, Ende, Beobachtung | +0,0057 bis +0,0208, Median +0,0145 | K1 | s4-s11 | 8
  m7567 B Geraet A0 md5 = Original | 24/24 | R
  m7568 B Geraet D0 >= 0,05 Ende | 8/8, 3,7 bis 11,5 | R
  m7569 B tot L2 t3000 / Ende | 0 / 0 bis 5,5 % (Gains leben) | R | s4-s11 | 8
  m7570 B D2R t1000 | -0,0012 bis +0,0037 | R | s4-s11 | 8
  m7571 B D2R t3000 | -0,0016 bis +0,0286, Median +0,0016 | R | s4-s11 | 8
  m7572 B D2R Ende | +0,0047 bis +0,0431, Median +0,0216 | R | s4-s11 | 8
  m7573 B OHNE BEITRAG (D2R <= 0,02 und <= 0,2 D0) Ende | 4/8 | R
  m7574 B BEITRAG (D2R >= 0,05) Ende | 0/8 | R
  m7575 B knapp (innerhalb 0,005 um 0,02 oder 0,05) | 2 (s8 +0,0216, s7 ... s11 +0,0134 nicht) | R
  m7576 Held-out A0 Ende Mittel R / K1, Beobachtung | 2,664 / 2,684, Differenz 0,020 | R gegen K1 | s4-s11 | 8
Ergebnis e451 [2026-11-02 15:00]: teilweise
  Fazit: A entschieden, KEINE VERTRETUNG fuer das Paar Schicht 1/2 in 128x4 (8/8 an t=3000, 7/8 am Ende); Vertretung durch Schicht 0 oder 3 ist so nicht pruefbar, weil deren Herausnahme 3-6 nats kostet. B OFFEN nach Wortlaut (OHNE BEITRAG 4/8, BEITRAG 0/8): Bei lebenden Gains (R-Staende) kostet der Zweig der Schicht 2 am Ende 0,005-0,043 nats, Median 0,022, steigend ueber den Lauf. Befund bleibt: D2 ist klein, auch ohne Schicht 1, und bei lebenden Gains nicht null. Zwei Lesarten, beide nicht entschieden (Nachrechnung Evo aus derselben Tabelle): (i) Die Ratsche schafft den Beitrag; dagegen spricht K1 s5 (Gains leben ohne Ratsche, D2 +0,0195, M2 +0,0313, Einzelwert). (ii) Der Zweig traegt rund 0,02 bei, sobald die Gains leben, Ratsche oder nicht, das Kippen kostet dann diese 0,02 je Modell; dagegen spricht, dass K1 s5 den zweitschlechtesten Held-out der K1-Saaten hat. Die Gleichheit von R-Vorteil (0,020) und Zweigbeitrag (0,022) besteht nur im Mittel: je Saat Spearman -0,39, kein Zusammenhang, also Zufall bis auf Weiteres. Reihenfolge Kippen oder Nutzlosigkeit bleibt in beide Richtungen unentschieden.
  Offen: Isoliert wuerde der Zweigbeitrag erst durch einen Eingriff im Training: derselbe Lauf mit w_down Schicht 2 = 0 von Anfang an oder ab t=3000, gepaart, 8 Saaten, Held-out als Hauptgroesse. Nicht gestartet, braucht eine Freigabe. Laengeres Budget offen.
  Datei: rechner-a:~/snai_pruef/uf2/ERGEBNIS_vertretung.md
Abgeloest und ausgeblendet: 1 ergebnis - voll=True zeigt sie.
Chronik:
  2026-11-02 14:00 angelegt
  2026-11-02 14:59 Rezept r516
  2026-11-02 14:59 Status geplant -> laeuft (Rezept r516)
  2026-11-02 14:59 Messwerte m7562-m7576
  2026-11-02 14:59 Ergebnis e450: teilweise
  2026-11-02 14:59 Status laeuft -> ausgewertet (Ergebnis e450)
  2026-11-02 15:00 Ergebnis e451: teilweise, loest e450 ab
```
