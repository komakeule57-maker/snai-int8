# snai/geschichten-wortfeld

```text
snai/geschichten-wortfeld - ausgewertet, angelegt 2026-10-30, zuletzt 2026-10-30 18:52
Frage: Bringt der Knirps 128x4 Regen/Wasser mit nass/Jacke in Verbindung, d. h. wird ein Zielwort wahrscheinlicher, wenn das Themenwort ausserhalb der Trigramm-Reichweite im Kontext stand? Wie frueh im Training?
Kriterium (festgelegt 2026-10-30 13:21, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/wortfeld/kriterien.txt. Faktor F = exp(D), D = Differenz der mittleren log P(Ziel | Thema) - log P(Ziel | Neutralwort) gegen Kontrollziele derselben Wortart, Abstand Thema-Ziel >= 6 Token. VERBINDUNG F >= 1,5 und KI-Untergrenze >= 1,1; GEGENTEIL spiegelbildlich; KEINE 1/1,1 < F < 1,1; sonst UNKLAR. A/A-Boden je Modell (Neutral gegen Neutral): ab 1,5 nicht auswertbar. Gueltig nur wenn Genesis s1-s3 nirgends VERBINDUNG (rot) und Positivkontrolle wasser->schwimmt auf c128sr_s0 VERBINDUNG. c128sr_s0 = 1 Saat, Beobachtung; K1 (1.000/3.000/9.002 Schritte) zaehlt nur bei 3/3 Saaten.
Plan: rechner-a:~/snai_pruef/wortfeld/kriterien.txt
Baut auf: snai/geschichten-chin128, snai/gradclip-knirps-kurz
Darauf baut: snai/prod512b-wortfeld, snai/prod512b-wortfeld2
Rezepte:
  r469 [2026-10-30] rechner-a: cd ~/snai_pruef/wortfeld && ./lauf.sh (text/sonde.php 20ddb5d1, lauf.sh dd32c7a4, Auswertung werkzeug/auswerten.py 2eef77a8, kriterien.txt 193dd1c1; libcortex_orig e281ce8d, 1 Thread, 57 s fuer 13 Modelle; Modelle chin_c128sr_s0 cfe662d4, clip_gen_s1-3, K1 s1-3 t1000/t3000/t9002)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/wortfeld/log/auswertung.txt, log/gegenprobe.txt (Korpus-Vorhersage nachtraeglich, nicht Teil des Urteils)
  m6562 F regen-nass | 5,67 | c128sr_s0 | 1
  m6563 A/A regen-nass | 1,09 | c128sr_s0 | 1
  m6564 F wasser-nass | 1,46 | c128sr_s0 | 1
  m6565 A/A wasser-nass | 1,10 | c128sr_s0 | 1
  m6566 F regen-jacke | 3,66 | c128sr_s0 | 1
  m6567 A/A regen-jacke | 2,04 | c128sr_s0 | 1
  m6568 F wasser-jacke | 0,76 | c128sr_s0 | 1
  m6569 A/A wasser-jacke | 3,54 | c128sr_s0 | 1
  m6570 F regen-wasser | 3,43 | c128sr_s0 | 1
  m6571 A/A regen-wasser | 1,36 | c128sr_s0 | 1
  m6572 F wasser-regen | 1,60 | c128sr_s0 | 1
  m6573 A/A wasser-regen | 1,29 | c128sr_s0 | 1
  m6574 F wasser-schwimmt Positivkontrolle | 6,57 | c128sr_s0 | 1
  m6575 Korpus-Vorhersage regen-nass | 8,02 | c128sr_s0 | 1
  m6576 Korpus-Vorhersage wasser-nass | 3,22 | c128sr_s0 | 1
  m6577 Korpus-Vorhersage regen-jacke | 3,82 | c128sr_s0 | 1
  m6578 Korpus-Vorhersage wasser-jacke | 1,54 | c128sr_s0 | 1
  m6579 Korpus-Vorhersage regen-wasser | 1,36 | c128sr_s0 | 1
  m6580 Korpus-Vorhersage wasser-regen | 1,22 | c128sr_s0 | 1
  m6581 F Genesis alle Relationen | 1,00 | genesis | 1
  m6582 F Genesis alle Relationen | 1,00 | genesis | 2
  m6583 F Genesis alle Relationen | 1,00 | genesis | 3
  m6584 F wasser-schwimmt 9002 Schritte | 1,36 | K1_t9002 | 1
  m6585 F wasser-schwimmt 9002 Schritte | 1,11 | K1_t9002 | 2
  m6586 F wasser-schwimmt 9002 Schritte | 1,12 | K1_t9002 | 3
  m6587 F regen-nass 9002 Schritte | 1,06 | K1_t9002 | 1
  m6588 F regen-nass 9002 Schritte | 1,04 | K1_t9002 | 2
  m6589 F regen-nass 9002 Schritte | 1,11 | K1_t9002 | 3
  Quelle: rechner-b:~/snai_pruef/wortfeld/log/c128sr_s1.jsonl (Kopie rechner-a log/big/), Sonde 20ddb5d1, auswerten.py 2eef77a8. Neumessung s0 auf rechner-b bytegleich zu rechner-a (md5 c935c312)
  m6704 Positivkontrolle F | 3,39 (A/A 1,35) VERBINDUNG | c128sr_s1
  m6705 regen>nass F | 5,00 (A/A 1,33) VERBINDUNG | c128sr_s1
  m6706 wasser>nass F | 1,35 (A/A 1,40) UNKLAR | c128sr_s1
  m6707 regen>jacke F | 2,51 (A/A 2,10) NICHT AUSWERTBAR | c128sr_s1
  m6708 wasser>jacke F | 0,94 (A/A 1,41) KEINE | c128sr_s1
  m6709 regen>wasser F | 0,83 (A/A 1,92) NICHT AUSWERTBAR | c128sr_s1
  m6710 wasser>regen F | 1,03 (A/A 1,10) KEINE | c128sr_s1
  m6711 Fehlerkanal Sonde | NET2NET-GUARD L1.rms_ffn tote Kanaele 108-127 und L2.rms_ffn 0-127 | c128sr_s1
  m6712 Geraetekontrolle s0 rechner-b gegen rechner-a | bytegleich | c128sr_s0
Ergebnis e411 [2026-10-30 13:25]: teilweise
  Fazit: Sonde gueltig. Nach einem vollen Durchgang verknuepft der Knirps Regen klar mit nass und Regen/Wasser in beiden Richtungen, ausserhalb der Trigramm-Reichweite; wasser-nass knapp unter der Schwelle (UNKLAR); beide Jacke-Relationen nach der Regel nicht auswertbar (A/A-Boden zu hoch), regen-jacke in den Rohwerten aber deutlich. 1 Saat, also Beobachtung. Bei 9.002 Schritten keine Relation 3/3, auch die Positivkontrolle nicht. Das meiste ist Textstatistik, die ueber den Abstand behalten wird (nachtraegliche Korpus-Vorhersage trifft regen-nass, regen-jacke, wasser-schwimmt); nur regen-wasser (3,43 gegen 1,36) geht deutlich darueber hinaus, Ursache nicht geprueft. Sonde nach weiteren Segmenten mitlaufen lassen; fuer Jacke vorher bessere Neutralwoerter waehlen.
  Offen: Ob das ueber weitere Saaten und Segmente haelt; Ursache regen-wasser; wann zwischen 9.000 und 153.000 Schritten es entsteht (kein gepaarter Vergleich, anderer Korpusausschnitt); ob es sich in erzeugten Geschichten zeigt.
  Datei: rechner-a:~/snai_pruef/wortfeld/ERGEBNIS_wortfeld.md
Chronik:
  2026-10-30 13:21 angelegt
  2026-10-30 13:25 Rezept r469
  2026-10-30 13:25 Status geplant -> laeuft (Rezept r469)
  2026-10-30 13:25 Messwerte m6562-m6589
  2026-10-30 13:25 Ergebnis e411: teilweise
  2026-10-30 13:25 Status laeuft -> ausgewertet (Ergebnis e411)
  2026-10-30 18:52 Messwerte m6704-m6712
```
