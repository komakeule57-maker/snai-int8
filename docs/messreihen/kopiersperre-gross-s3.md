# snai/kopiersperre-gross-s3

```text
snai/kopiersperre-gross-s3 - ausgewertet, angelegt 2026-10-27, zuletzt 2026-10-27 15:13
Frage: Kostet die seit 2026-10-26 voreingestellte stärkere Dosis DS an prod512b_s3 Namen gegenüber D4? Bisher geprüft nur an s4 (e367) und s5 (e371).
Kriterium (festgelegt 2026-10-27 04:59, vor dem ersten Messwert):
  Aufbau wie e371 (snai/kopiersperre-gross), einzige Änderung: Stand s3 (md5 deee2ea3). 120 Posten (posten.txt ed3fd98d), Arme V1-V3 (D4, Saat 1-3) gegen S1-S3 (DS), gepaart, 360 Paare. Delta = (T_V-T_S)/360, Bootstrap über Posten (10000 Ziehungen, Saat 20261027, 95 %).
- B: obere Grenze von Delta <= 0,05. K: untere Grenze > 0.
- L: U_S/U_V <= 0,9 und obere Grenze < 1. E: E_S/E_V <= 1,2 (ohne Schlüsselnamen).
- Saatregel: in jeder Saat T_Sk >= T_Vk - 6.
- Boden: T_V < 30/360 -> Namensteil höchstens keine_aussage.
Urteil:
- erfuellt = B, L, E und Saatregel -> DS bleibt, geprüft an s3-s5.
- teilweise = B und K oder sonst unvollständig.
- verfehlt = K allein -> zur Entscheidung vorlegen.
- gleichstand = weder L noch K.
Volltext kriterien_gross3.txt 93e07a49 (mit Prüfer).
Plan: rechner-a:~/snai_pruef/einstieg/dosis/gross3/kriterien_gross3.txt
Baut auf: snai/kopiersperre-gross, snai/kopiersperre-kombi
Rezepte:
  r441 [2026-10-27] rechner-b: cd ~/snai_pruef/einstieg/dosis/gross3 && setsid nohup bash lauf.sh > lauf.out 2>&1 < /dev/null &  ; Auswertung rechner-a: python3 dosis/gross3/auswert_gross3.py [-l] (nach Kopie von rechner-b dosis/gross3/s3)
      quelltext: snai_inference_kopie2.php 516e3a65, tools/prompt_bindung_kopie5.sh 5be9ee78, lauf.sh de8220db, posten.txt ed3fd98d, auswert_gross3.py 8434e444, kriterien_gross3.txt 93e07a49, modell prod512b_s3.snai deee2ea3 (.heads c9f0f895)
      parameter: Beam 3 ROH, prompt-frei, D4=0.4174,0.6245,0.8671,0.7404,0.7988 / DS=0.3613,0.5620,0.5627,0.7051,0.7978, 120 Posten x 6 Arme = 720 Läufe, xargs -P 2, Speicherwächter MemAvailable >= 3000 MB (flock, 30 s Anlauf), OMP_NUM_THREADS=1, SNAI_GAIN_GUARD=0, nice 19
      seed: SNAI_KOPIE_SAAT 1/2/3 (V_k und S_k gleiche Saat), Bootstrap 20261027
      rechner: rechner-b (daneben SnAI Evo 4 Prozesse bis ~06:00, abgesprochen; TDC-AI angekündigt)
      logs: rechner-b:~/snai_pruef/einstieg/dosis/gross3/s3/<arm>/, fortschritt.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/einstieg/dosis/gross3/auswert_gross3.txt (auswert_gross3.py 8434e444), Daten von rechner-b kopiert nach gross3/s3/, fortschritt.log (720 rc=0, GROSS3 FERTIG 14:13:43)
  m6158 Treffer | 76/360 | V (D4) | 1-3 | 360
  m6159 Treffer | 85/360 | S (DS) | 1-3 | 360
  m6160 Delta (T_V-T_S)/n, 95 % Bootstrap ueber Posten | -0,0250 [-0,0583; 0,0056] | S gegen V | 20261027 | 360
  m6161 U_S/U_V, 95 % | 0,606 [0,540; 0,675] | S gegen V | 20261027 | 360
  m6162 E_S/E_V (ohne Schluesselnamen), 95 % | 0,933 [0,864; 1,017] | S gegen V | 20261027 | 360
  m6163 Treffer V/S, verloren/gewonnen | 27/29, 2/4 | V1/S1 | 1 | 120
  m6164 Treffer V/S, verloren/gewonnen | 24/31, 1/8 | V2/S2 | 2 | 120
  m6165 Treffer V/S, verloren/gewonnen | 25/25, 7/7 | V3/S3 | 3 | 120
  m6166 U_S/U_V je Saat | 0,544 / 0,618 / 0,651 | S gegen V | 1-3 | 120
  m6167 Woerter im Mittel | 159,6 / 160,8 | V / S | 1-3 | 360
  m6168 Fehlerkanal rc!=0 / Fehlermuster / ohne KOPIE-Zaehler | 0 / 0 / 0 | alle | 1-3 | 720
  m6169 Sperrzeile je Arm | V1-V3 120x D4-Werte, S1-S3 120x DS-Werte | alle | 1-3 | 720
  m6170 Posten unter 20 Woertern | 3 (Posten 86 in V1, S1, S2: Bindestrich-Ketten "Marine-Marine-...", 256 Token, rc 0; Posten 86 hat in allen 6 Armen Treffer 0) | V1, S1, S2 | 1-2 | 3
Ergebnis e393 [2026-10-27 15:13]: erfuellt
  Fazit: Auch an s3 kostet DS keine Namen (Delta -0,025 [-0,058; 0,006], obere Grenze weit unter 0,05; Treffer 76 gegen 85 von 360) und senkt die Schleifen auf 0,61 x D4 [0,54; 0,68]; E 0,93, Saatregel in 3/3. Damit trägt die seit 2026-10-26 voreingestellte Dosis DS an s3, s4 (e367) und s5 (e371); die Voreinstellung bleibt, nichts zu ändern. Weitere Dosis-Reihen an alten Ständen lohnen nicht; spätere Stände prüft man erst, wenn einer ausgeliefert werden soll.
  Offen: Stände ab s6, andere Beam-Breiten, Sampling ungemessen. Posten 86 erzeugt an s3 Bindestrich-Ketten (unter 20 Wörter gezählt, Treffer 0 in allen Armen).
  Datei: rechner-a:~/snai_pruef/einstieg/dosis/gross3/ERGEBNIS_gross3.md
Chronik:
  2026-10-27 04:59 angelegt
  2026-10-27 05:02 Rezept r441
  2026-10-27 05:02 Status geplant -> laeuft (Rezept r441)
  2026-10-27 15:13 Messwerte m6158-m6170
  2026-10-27 15:13 Ergebnis e393: erfuellt
  2026-10-27 15:13 Status laeuft -> ausgewertet (Ergebnis e393)
```
