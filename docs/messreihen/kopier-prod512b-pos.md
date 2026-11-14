# snai/kopier-prod512b-pos

```text
snai/kopier-prod512b-pos - ausgewertet, begonnen 2026-10-19, angelegt 2026-10-21, zuletzt 2026-10-23 15:26
Frage: Kopiert prod512b (s0-s2) nach Inhalt oder nach Position, und wie weit reicht es (POS-Kopiersonde mit Versatz, Blocktausch und Abständen 96/320/796)?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  Rang-0-Anteil ab Position 8 auf einer 96-Token-Zufallsfolge, Basis W = R++R (Abstand 96). INHALT, wenn Versatz +1/+2/-1 je >= 0,9 W, Blocktausch (4x24, 2-0-3-1) >= 0,8 W und Abstand 320/796 je >= 0,5 W; POSITION, wenn Versatz und Blocktausch <= 0,2 W; sonst GEMISCHT. Orakel-Veto (Positions-/Inhalts-Orakel je Arm).
Plan: rechner-a:~/snai_pruef/kopierpos/kriterien.txt
Baut auf: snai/kopier-prod512b-s0, snai-evo/kopier
Darauf baut: snai/kopier-material-abstand, snai/kopier-prod512b-koepfe
Rezepte:
  r46 [2026-10-21] k. A. (Aufruf nicht wörtlich im Eintrag; Patch SNAI_KS_POS=1 an diagnose/kopier_sonde_rumpf.php über ~/snai_pruef/kopierpos/patch_pos.py, Lauf lauf_pos.sh, Auswertung auswert_pos.py)
      parameter: prod512b s0, s1, s2 (tg1, 512/6/8, ctx 1024, int8 LoRA-Fork, SR seit s3; Rezept LR 0,0001, Warmup 500, Cosinus, WD 0,1); POS-Kopiersonde je 80 Posten, Prüfsatz ho_prod 1ad0893a; Arme: Basis R++R (Abstand 96), Versatz +1/+2/-1, Blocktausch 4x24 (2-0-3-1), Abstand 320/796, Kontrolle kurzer Abstand an später Fensterstelle (spaet_l/ll), Fremd-Kontrollen, Orakel
      seed: Sonde 20260912
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/kopierpos/
Messwerte (Groesse | Wert | Arm | Start | n):
  m387 W (Abstand 96) | 0,000 | s0 | 20260912 | 80
  m388 W (Abstand 96) | 0,139 | s1 | 20260912 | 80
  m389 W (Abstand 96) | 0,176 [0,166-0,185] | s2 | 20260912 | 80
  m390 Versatz / Blocktausch relativ zu W | 1,00 W / 0,88 W | s1 | 20260912 | 80
  m391 Versatz / Blocktausch relativ zu W | 0,98-1,02 W / 0,84 W | s2 | 20260912 | 80
  m392 Abstand 320 / 796 relativ zu W | 0,61 W / 0,10 W | s1 | 20260912 | 80
  m393 Abstand 320 / 796 relativ zu W | 0,44 W / 0,10 W | s2 | 20260912 | 80
  m394 Kurzer Abstand an später Fensterstelle (spaet_l/ll) | 1,01-1,07 W | s1, s2 | 20260912 | 80
  m395 Fremd-Kontrollen | 0,000 | s1, s2 | 20260912 | 80
  Quelle: rechner-b:~/snai_pruef/kopierpos/proj/factory/checkpoints/kopier_sonde_prod512b_s3_pos.jsonl via auswert_pos.py (prod512b_s3 md5 deee2ea3, 2026-10-21, rc 0, Orakel im Soll)
  m1359 W = zuf_wieder Rang 0 (d 96) | 0,217 [0,206-0,227] | s3 | 20260912 | 80
  m1360 vp1 / vp2 / vm1 je W | 1,01 / 1,01 / 1,00 | s3 | 20260912 | 80
  m1361 zuf_perm je W | 0,85 | s3 | 20260912 | 80
  m1362 wieder_l (d 320) | 0,114 [0,106-0,122] = 0,53 W | s3 | 20260912 | 80
  m1363 wieder_ll (d 796) | 0,036 [0,031-0,040] = 0,16 W | s3 | 20260912 | 80
  m1364 spaet_l / spaet_ll je W | 1,01 / 1,00 | s3 | 20260912 | 80
  m1365 zuf_fremd_a | 0,000 | s3 | 20260912 | 80
  m1366 Urteil nach Regel | GEMISCHT (wieder_ll < 0,5 W) | s3 | 20260912 | 80
  Quelle: rechner-b:~/snai_pruef/kopierpos/proj/factory/checkpoints/kopier_sonde_prod512b_s4_pos.jsonl via auswert_pos.py (prod512b_s4 md5 751d92d9, 2026-10-23, 2915 s, voll_s4.err ohne NaN/Fatal/Fehler, Orakel im Soll)
  m4796 W = zuf_wieder Rang 0 (d 96) | 0,237 [0,224-0,250] | s4 | 20260912 | 80
  m4797 vp1 / vp2 / vm1 je W | 1,00 / 1,01 / 0,99 | s4 | 20260912 | 80
  m4798 zuf_perm je W | 0,87 | s4 | 20260912 | 80
  m4799 wieder_l (d 320) | 0,136 [0,125-0,147] = 0,57 W | s4 | 20260912 | 80
  m4800 wieder_ll (d 796) | 0,047 [0,042-0,053] = 0,20 W | s4 | 20260912 | 80
  m4801 spaet_l / spaet_ll je W | 1,03 / 1,01 | s4 | 20260912 | 80
  m4802 zuf_fremd_a / perm_fremd / fremd_ll | 0,000 / 0,000 / 0,000 | s4 | 20260912 | 80
  m4803 Urteil nach Regel | GEMISCHT (nur wieder_ll < 0,5 W) | s4 | 20260912 | 80
Ergebnis e339 [2026-10-23 15:26]: teilweise
  Fazit: Löst e43 ab und bezieht s3 und s4 ein. Nach der Regel bleibt es bei GEMISCHT, und zwar weiterhin nur wegen der weiten Reichweite. Versatz und Blocktausch erfüllen INHALT in s1 bis s4 durchgehend: prod512b kopiert nach Inhalt, nicht nach Position. Neu seit e43: Kopieren und Reichweite wachsen wieder. W bei Abstand 96 steigt 0,14 → 0,18 → 0,22 → 0,24 (s1 bis s4). Abstand 796 steigt 0,10 → 0,10 → 0,16 → 0,20 W, absolut 0,014 → 0,047. Die Lesart „die Reichweite wächst nicht“ aus e43 galt nur bis s2. Seit dem SR-Wechsel (s3) wächst sie, bleibt aber weit unter 0,5 W. Der Abfall hängt weiter am Abstand, nicht an der Fensterposition (spaet_ll 1,01 W). Für RAG über lange Belege reicht das nicht. Weiter messen an s9 (mit der Embedding-Sonde) und vorher bei Bedarf.
  Offen: Ein Lauf, ein Prüfsatz, Zufallsfolgen. Ob der Anstieg ab s3 an SR liegt oder einfach am längeren Training, trennt die Messung nicht, weil es keinen Arm ohne SR gibt. Ob die Kurzreichweite am Material oder an der Architektur liegt, bleibt offen (snai/kopier-prod512b-koepfe: das Finden scheitert bei 796).
  Datei: rechner-b:~/snai_pruef/kopierpos/kriterien.txt
Abgeloest und ausgeblendet: 1 ergebnis - voll=True zeigt sie.
Chronik (juengste 8 von 9, voll=True zeigt alle):
  2026-10-21 11:27 Rezept r46
  2026-10-21 11:27 Status geplant -> laeuft (Rezept r46)
  2026-10-21 11:27 Messwerte m387-m395
  2026-10-21 11:28 Ergebnis e43: teilweise
  2026-10-21 11:28 Status laeuft -> ausgewertet (Ergebnis e43)
  2026-10-21 19:17 Messwerte m1359-m1366
  2026-10-23 15:26 Messwerte m4796-m4803
  2026-10-23 15:26 Ergebnis e339: teilweise, loest e43 ab
```
