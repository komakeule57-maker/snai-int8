# snai/phase6-pruefsaetze

```text
snai/phase6-pruefsaetze - ausgewertet, angelegt 2026-10-31, zuletzt 2026-10-31 10:16
Frage: Lassen sich zwei zusätzliche Instruktions-Prüfsätze fremder Generatoren (oasst_de, dolly-15k_de) bauen, die sauber und messtauglich sind, damit sich an der fertigen Basis trennen lässt, ob der Adapter instruktion nur die Form des Gemma-Korpus gelernt hat?
Kriterium (festgelegt 2026-10-31 09:37, vor dem ersten Messwert):
  erfüllt = P1-P5 je Satz. P1 300.000-325.533 Byte, echte Tokenisierung f020d0ca mindestens 64 Fenster bei ctx 1024. P2 0 <unk>, Rundlauf fehlerfrei außer bekannter Normalisierung. P3 tools/schindeltest.py (8 Wörter) gegen jede Sperrdatei und jedes der 40 Segmente unter 0,01 % von B, Rot-Probe mit eingeschleustem Segmentausschnitt schlägt an. P4 Median Frage 40-160, Median Antwort 137-550 Zeichen, 0 doppelte Fragen, je Ordner genau eine .txt. P5 Nullpunkt prod512b_s6 je Satz 64 Fenster rc 0, Fehlerkanal leer, compare_full_paired Satz gegen sich rc 0, gegen ho_sft_gemma-Nullpunkt rc 1. Nullpunkt-Wert prüft nur das Gerät. Spätere Lesung: instruktion schlägt Kontrollarm auf beiden Sätzen = Form überträgt sich auf fremde Generatoren gleicher Länge, nicht mehr; verliert auf beiden = Gemma-Form gelernt; uneinig = kein Schluss.
Plan: rechner-a:~/snai_pruef/phase6c/kriterien.txt
Baut auf: snai/phase6b-strecke
Darauf baut: snai/phase6d-arme
Rezepte:
  r478 [2026-10-31] cd ~/snai_pruef/phase6c && python3 ~/Projekte/snai_edge_int8_lora/diagnose/build_pruefsatz_instr2.py quelle /var/tmp/vok/seg_neu ho_prod_1ad0893a.txt . ; danach rechner-b ~/snai_pruef/phase6c/null.sh
      quelltext: build_pruefsatz_instr2.py f5d5af6b (Erstbau 8e3a7a0b), tools/schindeltest.py, kriterien.txt 43b29748 (Erstfassung e8c17533), Tokenizer f020d0ca
      parameter: Frage 20-200, Antwort 160-800 Zeichen, 8-Wort-Schindeln, Ziel 325.533 Byte, Basis prod512b_s6 d9e3d9d1, OMP 6
      seed: Reihenfolge md5("phase6c:"+Quelle+":"+Zeile)
      rechner: rechner-a, rechner-b
      logs: rechner-a:~/snai_pruef/phase6c/ (bau.log, bau1/, schindel_*.txt); rechner-b:~/snai_pruef/phase6c/ (null.log, null64_*.txt, selbst_*.txt, rot_*.txt)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: bau.log, schindel_segmente.txt, schindel_sperren.txt, schindel_ohne28.txt (rechner-a); tok.php, null.log (rechner-b); Fehlerkanal 0 Treffer
  m6817 Bytes / Turns | 325.423 / 566 | oasst |  | 1
  m6818 Bytes / Turns | 325.461 / 674 | dolly |  | 1
  m6819 Token / Fenster | 86.822 / 85 | oasst |  | 1
  m6820 Token / Fenster | 84.957 / 83 | dolly |  | 1
  m6821 <unk> / Byte-Token-Anteil | 0 / 0,197 % | oasst |  | 1
  m6822 <unk> / Byte-Token-Anteil | 0 / 0,088 % | dolly |  | 1
  m6823 Median Frage / Antwort Zeichen | 73,5 / 456 | oasst |  | 566
  m6824 Median Frage / Antwort Zeichen | 51 / 357 | dolly |  | 674
  m6825 Schindeln in 40 Segmenten | 0 von 47.549 | oasst |  | 40
  m6826 Schindeln in 40 Segmenten | 0 von 47.549 | dolly |  | 40
  m6827 Rot-Probe eingeschleuster pseg05-Ausschnitt | 22,803 % | oasst |  | 1
  m6828 Höchste Überlappung Sperrdatei | 0,008 % | oasst |  | 1
  m6829 Höchste Überlappung Sperrdatei (corpus_sft_gemma; ho_sft_gemma 0,011 %) | 0,013 % | dolly |  | 1
  m6830 Ausschuss wegen Segmenten | 36 von 753 (4,8 %) | oasst |  | 753
  m6831 Ausschuss wegen Segmenten | 140 von 5.200 (2,7 %) | dolly |  | 5200
  m6832 Nullpunkt prod512b_s6 nats | 4,073963 | oasst |  | 64
  m6833 Nullpunkt prod512b_s6 nats | 4,134274 | dolly |  | 64
  m6834 compare_full_paired selbst / gegen sft_gemma rc | 0 / 1 | oasst |  | 1
  m6835 compare_full_paired selbst / gegen sft_gemma rc | 0 / 1 | dolly |  | 1
  m6836 pseg28-Überlappung nach Schnitt (Band aller Segmente 0,269-0,530 %) | 0,466 % | holdout_prod_ohne28 |  | 1
Ergebnis e420 [2026-10-31 10:16]: teilweise
  Fazit: oasst erfüllt P1-P5 (P1 erst nach dem Nachtrag zum ersten Gesprächspaar). dolly verfehlt P3 wörtlich (0,013 % und 0,011 % gegen Schwelle 0,01 %), die Reste sind ausschließlich Turn-Grenzen aus Rollenmarker plus Standardfrage, daher zweite Lesart: brauchbar, Wortlaut unverändert und so zu zitieren. Beide Sätze gehen in die Reihe an der fertigen Basis, neben den vier vorhandenen Spalten. Die Frage nach Gemma-Form oder Übertragung ist damit nicht beantwortet, das misst erst die Matrix. Für Stände ab s28 Gesamtmessungen auf holdout_prod_ohne28.
  Offen: Gemeinsamer Übersetzer und gemeinsames Längenband beider Sätze: "Aufgabe verstanden" können sie nicht belegen. Adapter noch nicht auf den neuen Sätzen gemessen. run_basis_einfrieren.sh nutzt weiter holdout_prod.
  Datei: rechner-a:~/snai_pruef/phase6c/ERGEBNIS_phase6c.md
Chronik:
  2026-10-31 09:37 angelegt
  2026-10-31 10:16 Rezept r478
  2026-10-31 10:16 Status geplant -> laeuft (Rezept r478)
  2026-10-31 10:16 Messwerte m6817-m6836
  2026-10-31 10:16 Ergebnis e420: teilweise
  2026-10-31 10:16 Status laeuft -> ausgewertet (Ergebnis e420)
```
