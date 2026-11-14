# snai/schach-kontextsonde

```text
snai/schach-kontextsonde - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:35
!! ohne Kriterium
Frage: Halten die Schach-Knirpse Bedingungen ein, die den ganzen Kontext betreffen (M1 kein Feld zweimal, M2 Felder aufsteigend, M3 Form Figur/Feld, M4 genau ein Koenig je Farbe)? Beim Schach ist Kopieren aus dem Kontext ein Fehler.
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Baut auf: snai/schach-d64-lauf
Rezepte:
  r115 [2026-10-21] cd ~/snai_pruef/knirps/gebiete && python3 kontext_sonde.py ziehungen_<zelle>_s1.txt ziehungen_<zelle>_s2.txt ziehungen_<zelle>_s3.txt [--korpus] [--rot] [--trigramm 300]
      quelltext: kontext_sonde.py 2fa5ac5d (md5 heute)
      parameter: 300 Ziehungen je Stand fuer die Eichung, 1.000 je Saat fuer d32/d64/d96 (T 1,0)
      seed: Ziehsaat 4711
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/gebiete/nach_leiter.out (Kontext-Sonde je Zelle), nach_lauf.out
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/gebiete/nach_leiter.out (d96 abgelesen); d64/d32/Trigramm/Korpus aus ERGEBNIS_sichtung.md, nicht nachgerechnet
  m1224 alle vier | 66,1 % | d64 | 1 | 1000
  m1225 alle vier | 61,8 % | d64 | 2 | 1000
  m1226 alle vier | 72,2 % | d64 | 3 | 1000
  m1227 alle vier | 67,9 % | d96 | 1 | 1000
  m1228 alle vier | 69,6 % | d96 | 2 | 1000
  m1229 alle vier | 69,0 % | d96 | 3 | 1000
  m1230 alle vier | 55,6-61,4 % | d32 | 1-3 | 1000
  m1231 M4 Koenige | 90,2 % | d64 | 1 | 1000
  m1232 M4 Koenige | 90,9 % | d64 | 2 | 1000
  m1233 M4 Koenige | 93,5 % | d64 | 3 | 1000
  m1234 M4 Koenige | 22,3 % | Trigramm | 4711 | 300
  m1235 alle vier | 12,3 % | Trigramm | 4711 | 300
  m1236 Korpus alle vier (Positivkontrolle) | 100 % | Korpus
  m1237 Felder je Zeile | 17,0-18,1 (Korpus 18,3) | d96 | 1-3 | 1000
Ergebnis e111 [2026-10-21 14:35]: beobachtung
  Fazit: Die Knirpse nutzen den Kontext, und zwar gegen das Kopieren: den Koenigstest, der ein Gedaechtnis ueber die ganze Zeile braucht, bestehen sie zu ~90 %, das Trigramm zu 22 %. Die Materialdichte treffen sie genau. Damit ist das Scheitern an der Loesbarkeit kein Kontextproblem; was fehlt, ist der Inhalt. Die Sonde wurde zum festen Bestandteil aller spaeteren Schachmessungen (Rot-Probe der Etiketten in snai/schach-etikett).
  Offen: Keine Entscheidungsgroesse; Vergleiche zwischen Zellen sind beschreibend.
  Datei: rechner-a:~/snai_pruef/knirps/gebiete/ERGEBNIS_sichtung.md (Abschnitt 'Was der Knirps gelernt hat')
Chronik:
  2026-10-21 14:35 angelegt (Nachtrag: Aufbau aus rechner-a:~/snai_pruef/knirps/gebiete/kriterien_schach_lauf.txt Teil 3 (2026-10-15, laut Text vor der Messung, auf die Frage 'Kopierverhalten'). Ausdruecklich 'kein Urteil ueber das Gebiet, Beschreibung des Modellverhaltens'; vorab festgelegt sind nur die Gueltigkeitsproben (Korpus 100 %, Rot-Probe: Mischen laesst M2 < 10 % fallen, M1/M4 unberuehrt). Daher ohne Kriterium, Urteil beobachtung.)
  2026-10-21 14:35 Rezept r115
  2026-10-21 14:35 Status geplant -> laeuft (Rezept r115)
  2026-10-21 14:35 Messwerte m1224-m1237
  2026-10-21 14:35 Ergebnis e111: beobachtung
  2026-10-21 14:35 Status laeuft -> ausgewertet (Ergebnis e111)
```
