# snai/torch-emb-leiter

```text
snai/torch-emb-leiter - ausgewertet, angelegt 2026-11-03, zuletzt 2026-11-03 13:30
Frage: Ab welchem Eingangsfaktor F endet das Sterben der FFN-L2-Gains unter Bindung? Leiter F = 2 (TE2), F = 4 (TE4) neben TEE (F = 11,31) und TG (F = 1), ohne Änderung der Momentführung. Reicht ein kleines F, wäre das der gangbare Weg für größere Breiten (bei d=512 schadet F = sqrt(512) am Start, Kopierbias, e496).
Kriterium (festgelegt 2026-11-03 12:11, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/clip_torch/KRITERIEN_leiter.md (md5 889aa4d2), vor dem Hauptlauf. Original torch_k1e.py --emb-ein F, K1-Rezept wie TG/TEE, Saaten 4-11 gepaart.
- Hauptgröße: Anteil toter FFN-L2-Gains am Ende je Arm gegen TG, gepaart je Saat.
- REPARIERT bei F: höchstens halb so viele tote L2-Gains wie TG in ≥ 6/8 Saaten.
- NICHT REPARIERT bei F: mindestens 80 % der toten L2-Gains von TG in ≥ 6/8 Saaten.
- Sonst TEILWEISE.
- Daneben: Held-out gegen TG und gegen TEE (Hausregel, gepaarter Bootstrap), Schritt-1-Loss je F (Kopierbias-Signatur), RMS(E) und g_final am Ende.
- Kleinstes F, das REPARIERT, ist die Antwort. Liegt die Schwelle zwischen zwei Sprossen, steht genau das da, nicht interpoliert.
- Kontrolle: F = 1 über denselben Weg ergibt TG bytegleich (eine Saat, 30 Schritte genügen).
Lesart: tot = |g|<0,05; halb = tot_F <= tot_TG/2; 80 % = tot_F >= 0,8 tot_TG. Kontrollen vor dem Lauf: F=1 bytegleich zu TG_s4 (snap 1, 30; dabei nimmt der Code den unveränderten Zweig), zusätzlich F=11,31 über denselben Startweg bytegleich zu TEE_s4 bei 1000 (roh und Messform), Rot F=2 verschieden.
Plan: rechner-b:~/snai_pruef/clip_torch/KRITERIEN_leiter.md
Baut auf: snai/torch-emb-eingang, snai/torch-v-getrennt, snai/torch-k1-gains
Rezepte:
  r557 [2026-11-03] TE2, TE4: rechner-b: cd ~/snai_pruef/clip_torch && setsid -f ./kette_leiter.sh  (je Arm/Saat eins_leiter.sh <TE2|TE4> <2|4> <s>: nice 10, OMP 1, torch_k1e.py train clip_gen_s<s>.snai fen/f_s<s>.bin --koepfe 8 --lr 0.003 --lr-konst --snapshots 1000,3000 --max-fenster 0 --emb-ein F --gn-log 100; Messung mess_text.php heldout 700 wie eins_tee.sh, hoechstens 4 zugleich)
      quelltext: torch_k1e.py md5 93855f6e (unveraendert); eins_leiter.sh 63707b0c; kette_leiter.sh 3e13b9cd
      seed: 4-11
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/clip_torch/laeufe/TE2_s<s>, TE4_s<s>, log/mess.jsonl (arm TE2/TE4), Kontrollen leiter_k/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/clip_torch/ausw_leiter.py + leiter_k/schritt1_loss.py -> log/ausw_leiter.txt (md5 3d048a44)
  m8344 L2 tot % Ende je Saat 4-11 | 60,9/68,0/78,1/1,6/42,2/78,1/67,2/64,8 | TE2 |  | 8
  m8345 L2 tot % Ende je Saat 4-11 | 6,2/37,5/19,5/1,6/32,0/55,5/32,0/71,1 | TE4 |  | 8
  m8346 L2 tot % Ende Mittel | 57,6 | TE2 |  | 8
  m8347 L2 tot % Ende Mittel | 31,9 | TE4 |  | 8
  m8348 L2 tot % Ende Mittel | 67,2 | TG |  | 8
  m8349 L2 tot % Ende Mittel | 3,8 | TEE |  | 8
  m8350 halbiert gegen TG | 1/8 | TE2
  m8351 halbiert gegen TG | 4/8 | TE4
  m8352 halbiert gegen TG | 8/8 | TEE
  m8353 >= 0,8 TG | 5/8 | TE2
  m8354 >= 0,8 TG | 4/8 | TE4
  m8355 F*RMS(E) Ende | 0,117 / 0,232 / 0,462 / 1,302 | TG/TE2/TE4/TEE |  | 8
  m8356 Schritt-1-Loss Mittel | 7,425 / 7,514 / 7,713 / 7,799 | TG/TE2/TE4/TEE |  | 8
  m8357 Held-out D gegen TG Mittel | -0,0106 [-0,0209, +0,0002] | TE2 |  | 8
  m8358 Held-out D gegen TG Mittel | -0,0246 [-0,0393, -0,0140] | TE4 |  | 8
  m8359 Held-out D gegen TEE Mittel | +0,0260 [+0,0184, +0,0345] | TE2 |  | 8
  m8360 Held-out D gegen TEE Mittel | +0,0120 [+0,0015, +0,0215] | TE4 |  | 8
  m8361 g_final Ende Mittel | 0,869 / 0,880 / 0,882 / 0,894 | TG/TE2/TE4/TEE |  | 8
Ergebnis e502 [2026-11-03 13:30]: teilweise
  Fazit: Nach Wortlaut: F=2 TEILWEISE (halbiert 1/8), F=4 TEILWEISE (halbiert 4/8), F=11,31 (TEE) REPARIERT 8/8. Kleinstes reparierendes F ist 11,31; die Schwelle liegt zwischen 4 und 11,31, nicht interpoliert. Ein kleines F reicht bei d=128 nicht. Der Startpreis (Schritt-1-Mehrverlust) ist bei F=4 schon zu 77 % der von TEE bezahlt, die Reparatur nur halb: fuer groessere Breiten ist ein kleineres F kein billiger Ausweg, lohnender waere, den Kopierbias vom Eingangsfaktor zu entkoppeln. Held-out folgt der Reparatur (TE4 8/8 besser als TG, TEE noch besser), nach Hausregel aber ueberall Gleichstand.
  Offen: Schwelle zwischen F=4 und 11,31 (Sprosse 8 fehlt). Startpreis bei d=512 nur aus e496, hier nur d=128 gemessen. Saatstreuung bei F=4 gross (1,6 bis 71 %).
  Datei: rechner-b:~/snai_pruef/clip_torch/ERGEBNIS_torch_emb_leiter.md
Chronik:
  2026-11-03 12:11 angelegt
  2026-11-03 12:12 Rezept r557 (TE2, TE4)
  2026-11-03 12:12 Status geplant -> laeuft (Rezept r557)
  2026-11-03 13:30 Messwerte m8344-m8361
  2026-11-03 13:30 Ergebnis e502: teilweise
  2026-11-03 13:30 Status laeuft -> ausgewertet (Ergebnis e502)
```
