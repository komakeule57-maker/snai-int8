# snai/ee-ffn-budget

```text
snai/ee-ffn-budget - ausgewertet, angelegt 2026-11-03, zuletzt 2026-11-03 15:27
Frage: Bringen die FFN-Zweige L1-L3 mit dem Embedding-Eingangsfaktor etwas, und wächst ihr Nutzen mit dem Budget? Hintergrund: snai/engine-ffn-weg (ohne Faktor, 9k: entbehrlich) und snai/engine-emb-eingang (mit Faktor leben die Gains, MITARBEIT verfehlt). Ziel: Ursache der nutzlosen Schichten klären und reparieren.
Kriterium (festgelegt 2026-11-03 10:25, vor dem ersten Messwert):
  Arme, beide mit F = sqrt(128) über die Stellrad-Lib bau_emb_voll 3475df5c, SNAI_EMB_EIN=11.3137085, voll int8, K1-Rezept (LR 0,003 konstant, WD 0,1, Warmup 500, SR, Clip 1, gebunden), CPU, 1 Thread:
- E27: Genesis clip_gen_s<s>.
- F27: Genesis clip_gen_ef0_s<s>, also rms_ffn und w_down von L1-L3 exakt 0. Das ist dieselbe Datei wie bei EF0 in e485.

Ein Stellrad: die Genesis. Lib, Daten und Sitzungsname clip_s<s> sind gleich, die Fensterfolge ist gepaart. Daten: kurz27000.txt, eine Epoche, 27.018 Schritte. Snapshots 9000, 13500, 18000, 22500 und Ende. Saaten 4-11. Messung: mess_text, heldout 700, mit F.

D(b) = L(F27, b) − L(E27, b) je Saat. Positiv heißt, die Zweige nützen.

Urteil 1 am Ende (27018):
- NUTZEN: Mittel D ≥ +0,02 UND D > 0 in ≥ 6/8.
- ENTBEHRLICH: Mittel D < +0,01 UND D < +0,02 in ≥ 6/8. Einseitig, denn die Frage ist, ob Weglassen kostet.
- Sonst OFFEN.

Urteil 2, Budget: H = D(Ende) − D(9000).
- WÄCHST: Mittel H ≥ +0,02 UND H > 0 in ≥ 6/8.
- KEIN BUDGETEFFEKT: |Mittel H| < 0,01 UND |H| < 0,02 in ≥ 6/8.
- Sonst saatabhängig.

Liegt ein Wert innerhalb 0,003 um eine Schwelle, ist sie nicht erfüllt. Dann gepaarter Bootstrap und Wiederholung auf heldout2.

Daneben, ohne Urteil:
- D(9000) gegen D aus e485 (ohne F, kurz9000), nur Einordnung, denn die Daten sind andere.
- Tote Gains je Schicht am Ende (|g| < 0,05).
- n123-Kosten an E27 Ende (w_down L1-L3 nullen, mit F gemessen).
- Rechenzeit je Arm.

Kontrollen:
- Je Lauf rc 0, STEPS_DONE 27018, [EMBEIN]/Eingangsfaktor-Zeile im Training und in jeder Messung, SR an, CLIP 1, korrigiert 0.
- F27: Nullen von w_down L1-L3 am Endstand ändert den Loss um 0.
- Rot Messpfad: E27 s4 Ende ohne F gemessen muss stark abweichen.
- Genesis md5 von clip_gen_ef0_s4 gleich wie in e485.

Größter freier Parameter: das Budget von höchstens 27.018 Schritten, durch die Textlänge begrenzt. „Entbehrlich“ gilt nur bis dahin, für dieses Rezept und für 128x4.

Gemeinsam verändert zwischen den Ständen: Schritte und frische Daten.
Darauf baut: snai/prod512b-gains-s9, snai/ee-ffn-budget100k
Rezepte:
  r554 [2026-11-03] rechner-b ~/snai_pruef/clip_lns: setsid -f nohup ./reihe_ee27.sh. Je Lauf: CLIP_GENPFX=<''|ef0_> SNAI_EMB_EIN=11.3137085 CLIP_LIB=bau_emb_voll/libcortex.so ./lauf_clip_lns.sh ee27 <E27|F27> - <s> daten/kurz27000.txt 9000,13500,18000,22500, 6 zugleich, CPU, 1 Thread. Log log/ee27.log, Läufe laeufe/ee27/*, n123/Nullkontrolle log/ee27_null.jsonl.
      quelltext: Lib 3475df5c (Stellrad-Lib aus e491), reihe_ee27.sh
      parameter: Genesis clip_gen_s4 882308c1, clip_gen_ef0_s4 8d7e5806 (Datei unverändert seit 03:57, also vor EF0 aus e485). LR 0,003 konstant, WD 0,1, Warmup 500, SR, Clip 1, gebunden.
      seed: Saaten 4-11 über Genesis und Sitzungsname clip_s<s>
      rechner: rechner-b
      logs: rechner-b ~/snai_pruef/clip_lns/log/ee27.log
      notiz: Gestartet 10:30. Gegengelesen von Mistral: Einwände betreffen nur die Einordnung. 0,20 nats beim nachträglichen Nullen ist nicht dasselbe wie der Nutzen im Training, und der Vergleich mit e485 ohne Faktor ist nur Einordnung. Den Aufbau ändern sie nicht.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b ~/snai_pruef/clip_lns/log/ee27_ausw.txt (werkzeug/ausw_ee27.py), log/ee27_ho2.jsonl, log/ee27_tot.jsonl, log/ee27.log
  m8371 D Ende heldout (L F27 - L E27) | +0,0314 | D | 4
  m8372 D Ende heldout | +0,0424 | D | 5
  m8373 D Ende heldout | +0,0210 | D | 6
  m8374 D Ende heldout | +0,0114 | D | 7
  m8375 D Ende heldout | +0,0148 | D | 8
  m8376 D Ende heldout | +0,0136 | D | 9
  m8377 D Ende heldout | +0,0339 | D | 10
  m8378 D Ende heldout | +0,0086 | D | 11
  m8379 D Ende heldout Mittel (Bootstrap 95 % +0,0144..+0,0303), positiv 8/8 | +0,0221 | D |  | 8
  m8380 D Ende heldout2 Mittel (Bootstrap +0,0153..+0,0302), positiv 8/8, je Saat +0,0332/+0,0407/+0,0209/+0,0171/+0,0099/+0,0110/+0,0335/+0,0138 | +0,0225 | D |  | 8
  m8381 D t9000 Mittel, positiv 1/8 | -0,0089 | D |  | 8
  m8382 D t13500 Mittel, positiv 8/8 | +0,0115 | D |  | 8
  m8383 D t18000 Mittel, positiv 7/8 | +0,0079 | D |  | 8
  m8384 D t22500 Mittel, positiv 8/8 | +0,0177 | D |  | 8
  m8385 H = D(Ende) - D(9000) Mittel (Bootstrap +0,023..+0,039), positiv 8/8, je Saat +0,0279/+0,0515/+0,0246/+0,0414/+0,0252/+0,0297/+0,0381/+0,0097 | +0,0310 | H |  | 8
  m8386 L Ende heldout Mittel | 2,5081 | E27 |  | 8
  m8387 L Ende heldout Mittel | 2,5303 | F27 |  | 8
  m8388 n123-Kosten E27 Ende Mittel (0,184-0,337) | 0,245 | E27 |  | 8
  m8389 tote L2-FFN-Gains E27 Ende (6 Saaten 8,6-14,1 %, s9 50 %, s11 64,8 %) | 8,6-64,8 % | E27 |  | 8
  m8390 Rechenzeit F27 gegen E27 gleiche Runde | 9-16 % schneller | F27 |  | 8
  m8391 Rot Messpfad E27 s4 ohne F | 5,1789 | E27 | 4
  m8392 Nullkontrolle F27 w_down L1-L3 genullt, Loss-Aenderung | 0,0000 in 8/8 | F27 |  | 8
Ergebnis e504 [2026-11-03 15:27]: teilweise
  Fazit: Urteil 2 WÄCHST ist erfüllt, Urteil 1 nach Wortlaut OFFEN (knapp): D am Ende +0,0221 auf heldout und +0,0225 auf heldout2, je 8/8 positiv, aber beide innerhalb 0,003 über der NUTZEN-Schwelle 0,02. ENTBEHRLICH ist klar widerlegt. Zweite Lesart ohne Knapp-Regel: NUTZEN auf beiden Texten, untere Bootstrap-Grenze über 0,014.

Folge: Die „nutzlosen“ mittleren FFN-Zweige sind mit Eingangsfaktor nur bei kurzem Training nutzlos (9k: D -0,009). Ihr Beitrag wächst mit dem Budget in 8/8 Saaten. Klein ist er trotzdem, 0,9 % des Held-out, nach der Hausregel ein Gleichstand der Größe nach.

Praxis: Für längere Läufe bleiben die Zweige drin. Das Weglassen samt Überspringen lohnt nur bei Läufen von 9k Schritten oder weniger.
  Offen: Ob der Nutzen bei deutlich größerem Budget (100k) klar über die Schwelle wächst, ist offen. Ebenso, ob das Sterben der L2-Gains bei langen Läufen trotz Faktor zurückkehrt: s9 50 % und s11 65 % tot bei 27k, in den übrigen 6 Saaten 9-14 %. Schritte und frische Daten ändern sich gemeinsam, ob der Nutzen am einen oder anderen hängt, ist nicht getrennt. Gemessen ist nur 128x4, int8, K1-Rezept mit einem Text.
  Datei: rechner-b:~/snai_pruef/clip_lns/ERGEBNIS_ee_ffn_budget.md
Chronik:
  2026-11-03 10:25 angelegt
  2026-11-03 10:31 Rezept r554
  2026-11-03 10:31 Status geplant -> laeuft (Rezept r554)
  2026-11-03 15:27 Messwerte m8371-m8392
  2026-11-03 15:27 Ergebnis e504: teilweise
  2026-11-03 15:27 Status laeuft -> ausgewertet (Ergebnis e504)
```
