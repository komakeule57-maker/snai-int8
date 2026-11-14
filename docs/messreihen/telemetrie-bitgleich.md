# snai/telemetrie-bitgleich

```text
snai/telemetrie-bitgleich - ausgewertet, begonnen 2026-10-10, angelegt 2026-10-21, zuletzt 2026-10-21 19:26
!! ohne Kriterium
Frage: Ändert die neue Segment-Telemetrie (Schnappschüsse, Scheduler aus) den Trainingslauf, gemessen an der md5 des Checkpoints?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Plan: 7 Läufe mit festem Sitzungsnamen: alter und neuer Stand, Telemetrie aus/an/Schnappschuss/Scheduler aus, Threads 6.
Rezepte:
  r168 [2026-10-21] bash segpruef/bitgleich.sh
      quelltext: segpruef/proj (alt) und neuer Stand (Commit nicht notiert)
      parameter: fester Sitzungsname, gleiche Genesis
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/segpruef/logs/bitgleich.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/segpruef/logs/bitgleich.log. Prüfung: Erklärung der Abweichler; nur 4 Zeichen der md5 im Log übernommen.
  m2018 md5 Checkpoint | c5f24a5b | alt2, neu_aus, neu_snap, neu_sched_aus |  | 4
  m2019 md5 Checkpoint | 478b | alt1 |  | 1
  m2020 md5 Checkpoint | d093 | neu_tel |  | 1
  m2021 md5 Checkpoint | 212b | alt_threads6 |  | 1
Ergebnis e158 [2026-10-21 19:26]: beobachtung
  Fazit: Vier Läufe treffen dieselbe Prüfsumme, darunter alter und neuer Stand mit ausgeschalteter Telemetrie; die drei Abweichler (darunter ein alter Lauf) lassen sich mit den Revival-Runden erklären, die den Lauf ohnehin nicht reproduzierbar machen. Die Telemetrie an sich ändert die Rechnung also nicht nachweisbar; ob der Lauf mit voller Telemetrie (neu_tel) nur am Revival abweicht, ist nicht isoliert.
  Offen: neu_tel ohne Revival wiederholen; Erklärung 'Revival-Runden' ist nicht durch Eingriff gesichert.
  Datei: rechner-b:~/snai_pruef/segpruef/bitgleich.sh
Chronik:
  2026-10-21 19:26 angelegt (Nachtrag: Nachtrag 2026-10-21 aus rechner-b ~/snai_pruef/segpruef/logs/bitgleich.log (mtime 2026-10-10 16:13). Kein schriftliches Kriterium vor dem Lauf gefunden.)
  2026-10-21 19:26 Rezept r168
  2026-10-21 19:26 Status geplant -> laeuft (Rezept r168)
  2026-10-21 19:26 Messwerte m2018-m2021
  2026-10-21 19:26 Ergebnis e158: beobachtung
  2026-10-21 19:26 Status laeuft -> ausgewertet (Ergebnis e158)
```
