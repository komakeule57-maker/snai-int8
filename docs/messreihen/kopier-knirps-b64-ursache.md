# snai/kopier-knirps-b64-ursache

```text
snai/kopier-knirps-b64-ursache - ausgewertet, begonnen 2026-10-13, angelegt 2026-10-21, zuletzt 2026-10-21 11:27
Frage: Warum lernt Breite 64 die Kopieraufgabe bei LR 0,001 nicht: erklärt es der Lade-Wächter, die Gewichtsdämpfung (WD) oder das Absterben der FFN-Gains?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21 (Fallstrick); Kriterium laut damaliger Aufzeichnung vorab festgelegt (WD mit Prüfer vor dem Start); Regelwortlaut im Eintrag nur sinngemäß):
  Gelernt = Rang 0 zweite Kopie >= 90 %. (A) Wächter (waechter_kriterien.txt, 4 Läufe n2_d64h{2,8}_s{1,2}, 12 Segmente): >= 3 von 4 ohne Wächter gelernt -> „der Wächter hat das Lernen verhindert“; 0-1 von 4 -> „der Wächter erklärt das Nichtlernen im Budget nicht“; 2 von 4 -> uneinig. Keine Zellenurteile. (B) WD (wd_kriterien.txt): Breite 64, vier Paare: abgestorben (eine Norm mit >= 1/8 der Kanäle |g| < 0,05 am letzten Segment) mit WD in >= 3 und ohne in <= 1 -> „WD ist in diesen Läufen nötig fürs Absterben“; je Zelle zählt ein Unterschied im Lernen bei > 1 Segment und gleicher Richtung in allen Saaten. (C) Gains festhalten (gain_kriterien.txt Reihe 1): Breite 64, sechs Paare: „Festhalten hilft“, wenn in >= 4 Paaren der festgehaltene Lauf >= 90 % erreicht und der freie nicht; „hilft nicht in diesem Rezept und Budget“, wenn höchstens 1 von 6 festgehaltenen lernt; Breite 32 nur bei > 1 Segment in allen 3 Saaten gleich gerichtet. „Nicht gelernt“ heißt nur: nicht im Budget bei LR 0,001.
Plan: rechner-a:~/snai_pruef/knirps/waechter_kriterien.txt, wd_kriterien.txt, gain_kriterien.txt (Reihe 1)
Baut auf: snai/kopier-knirps-lr-breite
Rezepte:
  r45 [2026-10-21] k. A. (Aufrufe nicht wörtlich im Eintrag; Skripte reihe_ow.sh, reihe_ow_b.sh, reihe_wd.sh, reihe_folge.sh)
      parameter: `var`, wort256, 2 Schichten, ctx 64, Ganzzahl gebunden, LR 0,001 konstant, Warmup 500, Revival aus. (A) Wächter: proj_ow (gain_guard_enabled=0) gegen Altlauf gleicher Name/Genesis, n2_d64h2_s1/s2, n2_d64h8_s1/s2, 12 Segmente, WD 0,1. (B) WD 0,1 gegen 0 (EXTRA=„1 0.1“ / „1 0“), proj_ow / proj_ow_wd0, Wächter aus; 64/2, 64/8 je Saat 1,2 (24 Segmente); 32/2 Saat 1-3 (12 Segmente). (C) SNAI_GAIN_FREEZE (Bit 1 = rms_ffn) in proj_gf gegen freie WD-0,1-Läufe (proj_ow), 64/2 und 64/8 je 3 Saaten (24 Segmente), 32/2 (12)
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/ow/ (wd1, wd0), ~/.cache/snai_pruef/knirps/gf/m1; Doku 6u, 6v, 6w
Messwerte (Groesse | Wert | Arm | Start | n):
  m377 gelernt ohne Wächter | 0 von 4 (Ende 85,4 / 6,9 / 13,7 / 7,0 %) | (A) ohne Wächter, 64/2 s1, 64/2 s2, 64/8 s1, 64/8 s2 |  | 4
  m378 R0 Ende mit Wächter | 84,3 / 9,2 / 11,7 / 9,2 % | (A) mit Wächter |  | 4
  m379 Messung kopiertest_n2_d64h2_s1_s9 mit / ohne Wächter-Korrektur | 2,9 % / 85,2 % | (A) Messgerät | 1
  m380 L0.rms_ffn abgestorben | 4 von 4 (100 % ab Segment 4-8) | (B) Breite 64 mit WD |  | 4
  m381 L0.rms_ffn abgestorben | 0 von 4 (0-10,9 %) | (B) Breite 64 ohne WD |  | 4
  m382 gelernt Breite 64 | 0 von 4 mit WD (Ende 82,3 / 7,9 / 11,3 / 10,0 %), 0 von 4 ohne (9,0 / 3,9 / 6,2 / 2,9 %) | (B) |  | 4
  m383 Segment bis gelernt 32/2 | mit WD 2/3/2, ohne WD 1/2/1 | (B) |  | 3
  m384 gelernt Breite 64 | fest 0 von 6, frei 0 von 6 | (C) |  | 6
  m385 Freier Lauf auf der 82-%-Stufe, festgehalten | 9 % | (C) 64/2 | 1
  m386 Segment bis gelernt 32/2 | fest 1/1/2, frei 2/3/2 | (C) |  | 3
Ergebnis e42 [2026-10-21 11:27]: verfehlt
  Fazit: Keiner der drei Kandidaten erklärt, warum Breite 64 bei LR 0,001 nicht lernt: der Lade-Wächter nicht (0 von 4 ohne ihn gelernt), WD ist zwar nötig fürs Absterben der L0-FFN-Gains, aber gelernt wird mit und ohne WD nicht, und Festhalten der Gains hilft nicht (0 von 6). Tote FFN-Gains sind Begleiterscheinung, nicht Ursache; bei Breite 32 sterben sie nach dem Lernen ab, ohne dass die Kopierleistung leidet. Die Ursache ist die LR (snai/kopier-knirps-lr-breite). Nebenbefund mit Gewicht: der Wächter verfälscht Messungen direkt (eine Datei 2,9 % mit, 85,2 % ohne Korrektur), alte Einbrüche waren teils Messfehler.
  Offen: Breite 64 mit 2 Saaten je Zelle in (A) und (B): kein Zellenurteil. Festhalten verbietet jedes Gain-Lernen und der Gradient fester Gains zählt weiter im Clip, das ist nicht getrennt. Ungepaarte Beobachtung: ohne WD kein toter Kanal und kein Lernen (Vermutung: WD drückt die rms_ffn-Gains gegen null).
Chronik:
  2026-10-21 11:26 angelegt (Nachtrag: Nachgetragen 2026-10-21 (Fallstrick); Kriterium laut damaliger Aufzeichnung vorab festgelegt (WD mit Prüfer vor dem Start); Regelwortlaut im Eintrag nur sinngemäß)
  2026-10-21 11:26 Kriterium geaendert, vorher: Gelernt = Rang 0 zweite Kopie >= 90 % in 24 Segmenten. Wächter (waechter_kriterien.txt): Arm ohne Wächter gegen Altlauf, Kontrolle md5-gleich bis zum ersten Eingriff; Wächter erklärt das Nichtlernen, wenn ohne ihn gelernt wird. WD (wd_kriterien.txt): „abgestorben“ = eine Norm mit >= 1/8 der Kanäle |g| < 0,05 am letzten Segment; Unterschied im Lernzeitpunkt zählt erst bei > 1 Segment. Gains festhalten (gain_kriterien.txt Reihe 1): fest gegen frei gepaart.
  2026-10-21 11:26 Kriterium vor dem ersten Messwert durch den Wortlaut der drei Plan-Dateien ersetzt (erste Fassung aus den Einträgen nur sinngemäß).
  2026-10-21 11:27 Rezept r45
  2026-10-21 11:27 Status geplant -> laeuft (Rezept r45)
  2026-10-21 11:27 Messwerte m377-m386
  2026-10-21 11:27 Ergebnis e42: verfehlt
  2026-10-21 11:27 Status laeuft -> ausgewertet (Ergebnis e42)
```
