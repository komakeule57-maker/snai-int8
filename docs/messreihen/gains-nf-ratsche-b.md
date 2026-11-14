# snai/gains-nf-ratsche-b

```text
snai/gains-nf-ratsche-b - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 17:58
Frage: Traegt der FFN-Zweig der Schicht 2 etwas bei, wenn nur die Ratsche auf w_up/w_down seine Gains am Leben haelt (B-Staende aus snai/gains-v-b, Held-out gleich K1)? Probe zu den zwei Lesarten aus snai/gains-vertretung (Vorschlag Evo, Freigabe fuer CPU-Reihen auf rechner-b).
Kriterium (festgelegt 2026-11-02 17:22, vor dem ersten Messwert):
  Kein Training, Werkzeug wie gains-vertretung B: B-Staende s4-s11 (clip/laeufe/reihe_gb/B_s*), Staende t1000/t3000/Ende soweit vorhanden, Arme A0, NF2 (w_down Schicht 2 = 0), NF0 (Kontrolle). D2B = Loss(NF2) - Loss(A0) am Ende. OHNE BEITRAG: D2B <= 0,02 UND <= 0,2 x D0 in >= 6/8. BEITRAG: D2B >= 0,05 in >= 6/8. Sonst OFFEN; knapp 0,005. Lesarten: Traegt der Zweig in B (lebende Gains, kein Held-out-Vorteil) wie in R rund 0,02, dann ist "0,02 sobald Gains leben" gestuetzt und der R-Vorteil kommt woanders her; traegt er in B nichts, dann gehoert der Beitrag in R zur Ratsche auf allen Tensoren, nicht zu den lebenden Gains. Geraet: A0 md5 = Original und = mess.jsonl; D0 >= 0,05 in 8/8; tot L2 der B-Staende aus den Gains (soll < 20 %).
Baut auf: snai/gains-vertretung, snai/gains-v-b
Darauf baut: snai/gains-batchgen-null
Rezepte:
  r525 [2026-11-02] rechner-b ~/snai_pruef/uf3/lauf.sh: nullsetzen.php B-Stand "" | "2:w_down" | "0:w_down", mess_text.php 700 Fenster, Staende t1000/t3000/Ende; kanal.php an den B-Endstaenden
      quelltext: ms_null/werkzeug/nullsetzen.php, clip/text/mess_text.php, Lib proj_clip ccb10b0f; B-Staende aus snai/gains-v-b (clip/laeufe/reihe_gb/B_s4-s11)
      rechner: rechner-b CPU, 72 Messpunkte, Fehlerkanal 0 Byte
      logs: rechner-a:~/snai_pruef/uf3/ (erg.jsonl, kanal_b.jsonl, log/)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: uf3/erg.jsonl, kanal_b.jsonl; D2B = Loss(NF2) - Loss(A0) in nats
  m7689 Geraet A0 md5 = Original und = Evos Held-out | 24/24, 8/8 | B
  m7690 Geraet D0 Ende | 3,6 bis 7,3 nats, 8/8 | B
  m7691 tot L2 Ende | 0 / 0 / 0 / 0 / 10,9 / 14,8 / 0,8 / 15,6 % | B | s4-s11 | 8
  m7692 D2B t1000 | -0,0005 bis +0,0048 | B | s4-s11 | 8
  m7693 D2B t3000 | -0,0001 bis +0,0124, Median +0,0028 | B | s4-s11 | 8
  m7694 D2B Ende | +0,0132 +0,0245 +0,0199 +0,0128 +0,0033 +0,0102 +0,0160 +0,0044 | B | s4-s11 | 8
  m7695 D2B Ende Median / Mittel | +0,0132 / +0,0130 | B
  m7696 OHNE BEITRAG (D2B <= 0,02 und <= 0,2 D0) Ende | 7/8, davon 2 in der Knapp-Zone (s6 0,0199, s10 0,0160), bereinigt 5/8 | B
  m7697 BEITRAG (D2B >= 0,05) Ende | 0/8 | B
  m7698 Vergleich: D2 Ende in R / K1 (gains-vertretung, ursache-folge) | Median +0,0216 / +0,0013 | R / K1
Ergebnis e464 [2026-11-02 17:58]: keine_aussage
  Fazit: OFFEN nach Wortlaut (OHNE BEITRAG bereinigt 5/8, BEITRAG 0/8), die Zahl ist aber klar: Mit Ratsche nur auf w_up/w_down traegt der FFN-Zweig der Schicht 2 am Ende 0,003 bis 0,025 nats, Median 0,013, wachsend ueber den Lauf (t1000 um 0, t3000 0,003), also zwischen K1 (0,001) und R (0,022). Das stuetzt Evos Lesart: Der Zweig traegt rund 0,01 bis 0,02, sobald seine Gains leben, egal welche Ratsche; und es widerlegt meine Lesart, dass die Ratsche auf allen Tensoren den Beitrag schafft. Zugleich hat B keinen Held-out-Vorteil gegen K1 (Gleichstand, Evo e458) und ohne den Zweig von Anfang an lernt das Modell genauso gut (ffn2-null-training): Der lebende Zweig leistet einen kleinen Beitrag, den das Modell ohne ihn anders erbringt. Redundante Kapazitaet, kein Verlust durch das Kippen. Der R-Vorteil (0,02) kommt woanders her.
  Offen: Laengeres Budget; die Groesse des Zweigbeitrags waechst ueber den Lauf. Ein Rezept, ein Text.
Chronik:
  2026-11-02 17:22 angelegt
  2026-11-02 17:58 Rezept r525
  2026-11-02 17:58 Status geplant -> laeuft (Rezept r525)
  2026-11-02 17:58 Messwerte m7689-m7698
  2026-11-02 17:58 Ergebnis e464: keine_aussage
  2026-11-02 17:58 Status laeuft -> ausgewertet (Ergebnis e464)
```
