# snai/schluss-kv-reset

```text
snai/schluss-kv-reset - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 19:17
Frage: Rechnet der neue Ruecksprung im KV-Cache (cortex_set_cache_pos, patch_kv.py) bitgleich zu einer frischen Rechnung, damit die Schlussfolgern-Sonde Kandidaten nach gemeinsamem Prompt bewerten kann, ohne neu zu rechnen?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/schluss/kv/kriterien.txt und Kopf von kv/test_kv.php (laut Text vor dem Test, 2026-10-15 08:43).):
  K0 gepatchte Bibliothek ohne Aufruf md5-gleiche Ausgabe wie die Projektbibliothek. K1 Zuruecksetzen nach Umweg bitgleich zur frischen Rechnung (alle 6 Folge-Logits). K2 Rot-Probe: falsche Stelle (n-1) muss abweichen. K3 Vorwaerts-Setzen wird ignoriert (bitgleich).
Baut auf: snai/schluss-generator-proben
Rezepte:
  r127 [2026-10-21] cd ~/snai_pruef/schluss && python3 patch_kv.py kv && php kv/test_kv.php (und kv/test_kv0.php fuer K0)
      quelltext: cortex.nim 85f2791e (Projektstand d0a29c9e + Patch) -> libcortex_kv.so 17501246, Adapter tensor_ffi_adapter.php a164da13; Projektbibliothek libcortex.so 75e8fd2a
      parameter: Pruefmodell Kopie von knirps/proj_akk_f1 kopiertest_ak_d32h2_s1_s0.snai (2 Koepfe), Zufallstoken
      seed: 42 (Gegenprobe andere Saat)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/schluss/kv/ (Ergebnis in kriterien.txt eingetragen)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/schluss/kv/kriterien.txt (Ergebniszeilen), nicht neu gemessen
  m1388 K1 bitgleich nach Ruecksprung | 6 von 6 | Patch | 42 | 6
  m1389 K2 falsche Stelle gleich | 0 von 6 | Rot | 42 | 6
  m1390 K3 Vorwaerts-Setzen ignoriert | 6 von 6 | Patch | 42 | 6
  m1391 K0 Ausgabe-md5 gepatcht = Projekt | 4c4b82f5 = 4c4b82f5 | K0 | 42
  m1392 K0 Gegenprobe andere Saat | 2d7c2a66 | K0 andere Saat
Ergebnis e122 [2026-10-21 19:17]: erfuellt
  Fazit: Der KV-Ruecksprung ist bitgenau und die Rot-Probe schlaegt an; die Modellseite der Sonde kann Kandidaten mit gemeinsamem Prompt billig bewerten. Wichtig fuer jeden spaeteren Einsatz: Adapter und Bibliothek nur paarweise (der gepatchte Adapter laedt keine ungepatchte libcortex.so). Der Patch lebt nur in den Arbeitskopien schluss/kv und schluss/rig, nicht im Projektbaum; da die Modellreihe nie lief, ist er bisher ungenutzt.
  Offen: Nur an einem 2-Kopf-Modell d32 geprueft.
  Datei: rechner-a:~/snai_pruef/schluss/kv/kriterien.txt
Chronik:
  2026-10-21 19:16 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/schluss/kv/kriterien.txt und Kopf von kv/test_kv.php (laut Text vor dem Test, 2026-10-15 08:43).)
  2026-10-21 19:17 Rezept r127
  2026-10-21 19:17 Status geplant -> laeuft (Rezept r127)
  2026-10-21 19:17 Messwerte m1388-m1392
  2026-10-21 19:17 Ergebnis e122: erfuellt
  2026-10-21 19:17 Status laeuft -> ausgewertet (Ergebnis e122)
```
