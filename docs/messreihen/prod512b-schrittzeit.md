# snai/prod512b-schrittzeit

```text
snai/prod512b-schrittzeit - ausgewertet, begonnen 2026-10-10, angelegt 2026-10-21, zuletzt 2026-10-29 12:54
Frage: Hängt die Schrittzeit des Neustarts prod512b (1 Arbeiter) an der Threadzahl, und wie schnell rechnen vserver und rechner-b im echten Aufrufmuster?
Kriterium (nachgetragen, Beleg: Kriterium (2026-10-10 17:16), wiederholt um 20:04; beide Fassungen nennen es vor den Zahlen.):
  ms je Schritt aus der [Bilanz]-Zeile von train_cluster.php; unter 10 % Unterschied = Gleichstand.
Baut auf: snai/vserver-worker-skalierung
Darauf baut: snai/threads-skalierung
Rezepte:
  r231 [2026-10-21] train_cluster.php mit 1 Arbeiter, INT8 voll, gebunden, ctx 1024, ab prod512-Genesis, 8 bzw. 16-18 Schritte; OMP_NUM_THREADS 2/3/4 (vserver) bzw. 4/6/12 (rechner-b); Befehl wörtlich k. A.
      quelltext: Testkopie vserver:~/snai_pruef/stufe/proj und alter Projektordner; Bibliotheken libcortex.so.bak_pre_attfix_20261009 gegen aktuelle (ATTFIX)
      parameter: neuer Kern, neues Rezept
      seed: Darwin-Patch-Offset je Rechner verschieden
      rechner: vserver, rechner-b (Ryzen 5 4500)
      logs: k. A.
Messwerte (Groesse | Wert | Arm | Start | n):
  (nicht nachgerechnet); Produktionswerte aus vserver:~/.cache/prod512b/s0..s2.log abgelesen 2026-10-21
  m2595 s je Schritt | 27,5 / 27,9 / 29,8 | vserver 4 / 3 / 2 Threads |  | 16
  m2596 s je Schritt alte / ATTFIX-Bibliothek | 29,14 / 29,15 | vserver 2 Threads |  | 16
  m2597 s je Schritt | 12,05 (6 und 12 Threads) / 12,57 (4 Threads) | rechner-b |  | 8
  m2598 s je Schritt nach VM-Neustart | 27,1 bis 27,7 | vserver |  | 8
  m2599 md5 Endstand über 4/6/12 Threads und Wiederholung | gleich (adb92b4e…) | rechner-b |  | 8
  m2600 Produktion s0 / s1 / s2 ([Bilanz]) | 26,04 / 15,17 / 15,54 | vserver |  | 10552
  Quelle: rechner-a:~/snai_pruef/merkmal/prodtest/kriterien_prodtest.txt, Abschnitt ZWISCHENSTAND s3 (2026-10-21), nicht selbst nachgelesen auf vserver
  m2601 s je Schritt Produktion | 16,4 (2731 min / 10.017) | vserver prod512b s3 |  | 10017
  m2602 s je Schritt laufend | ~16,7 (Step 170->180 in 167 s) | vserver prod512b s4 |  | 10
  Quelle: vserver:~/.cache/prod512b/s4.log, [Bilanz]-Zeile
  m4790 ms je Schritt | 16.894,4 (10.401 Schritte in 48:48:39) | prod512b s4, 1 Arbeiter, OMP 4 |  | 10401
Ergebnis e401 [2026-10-29 12:54]: gleichstand
  Fazit: Die Threadzahl ist kein Hebel für die Schrittzeit von prod512b mit 1 Arbeiter. vserver: 2 gegen 4 Threads 29,8 gegen 27,5 s, 8 % Abstand. rechner-b: 4 gegen 6/12 Threads 12,57 gegen 12,05 s, 4 % Abstand. Beides liegt unter der Vorab-Schwelle von 10 %, also Gleichstand. Der Endstand ist über die Threadzahl bytegleich. Der Sprung im echten Lauf (s0 26,0 s, s1-s7 15,2-16,9 s je Schritt) kommt von der Engine: Beim Neustart am 2026-10-16 00:07 lud der Lauf libcortex.so 5ce8674e (2026-10-15) mit parallelem Attention-Rückwärtspfad, belegt durch die Zeile [ATT-BW] in s1.log, die in s0.log fehlt. Der Patch wurde gepaart auf rechner-b gemessen: -54 % bei ctx 1024. Geprüft 2026-10-29. Die Schrittzeiten je Segment stehen nur noch in snai/prod512b-lauf. Diese Reihe wird geschlossen.
  Offen: Nicht getrennt ist, ob weitere Änderungen in derselben Bibliothek (z. B. der parallele Adam) zum Gewinn beitragen. Der rechner-b-Wert stammt nur aus einem Test mit 8 Schritten (2026-10-10). Die Zahlen wurden nicht nachgerechnet.
Abgeloest und ausgeblendet: 1 ergebnis - voll=True zeigt sie.
Chronik (juengste 8 von 12, voll=True zeigt alle):
  2026-10-21 19:37 Messwerte m2601, m2602
  2026-10-21 19:37 Befund nach dem Neustart von vserver: VM-Neustart 2026-10-15 22:06, Dienst setzte 2026-10-16 00:07 neu auf und rechnete Segment 1 von vorn; seitdem 15,2-16,7 s je Schritt statt 26,0 s (s0). Gleiche CPU laut /proc/cpuinfo (Xeon E5-2699 v4, 4 Kerne). Ursache unbekannt, nicht isoliert. Die Gleichstand-Aussage zur Threadzahl bleibt davon unberührt.
  2026-10-21 19:37 wird im Zweig 'Projekt Snai int8 LoRa' weitergeführt; nächster Messpunkt s4 (~2026-10-23)
  2026-10-23 14:38 Messwerte m4790
  2026-10-29 12:32 Ergebnis e400: gleichstand
  2026-10-29 12:32 Status laeuft -> ausgewertet (Ergebnis e400)
  2026-10-29 12:54 Ergebnis e401: gleichstand, loest e400 ab
  2026-10-29 12:54 Korrektur zu e401 (Verweis berichtigt).
```
