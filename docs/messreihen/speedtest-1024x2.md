# snai/speedtest-1024x2

```text
snai/speedtest-1024x2 - ausgewertet, begonnen 2026-10-14, angelegt 2026-10-21, zuletzt 2026-10-21 19:25
Frage: Wie schnell trainiert 1024x2 (ffn 4096, 16 Köpfe) auf der Karte gegen die CPU, und bringen GPU-Adam und GPU-Backward dort jeweils mindestens 10 %?
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21 aus der Kriteriendatei, rechner-b ~/snai_pruef/cuda_i8/out/S_* (speed1024.sh 2026-10-14 09:43).):
  Vorab rechner-b ~/snai_pruef/cuda_i8/kriterien.txt Abschnitt 'SPEEDTEST 1024x2' (2026-10-14): Arme C (FORCE_CPU), G (Karte, Adam CPU), GA (+GPU-Adam), GAB (+GPU-Backward), 3 Runden verschränkt; Median der Wandzeit; unter 10 % = Gleichstand; streuen die Runden eines Arms um mehr als den Abstand zum Nachbarn, trägt der Vergleich nicht. Kontrolle GA = G bitgleich.
Plan: rechner-b:~/snai_pruef/cuda_i8/kriterien.txt (3 Runden C G GA GAB verschränkt)
Baut auf: snai/gpu-adam-projekt
Darauf baut: snai/cuda-fwd-kachel
Rezepte:
  r166 [2026-10-21] C, G, GA, GAB: bash speed1024.sh
      quelltext: bau_proj/libcortex_proj.so 789e1092 + lib_proj/libcortex_cuda.so 78249867
      parameter: init_base.php gen1024.snai 256 1024 64 2 (ffn 4096), 16 Köpfe, gebunden, INT8_FULL, p300, 300 Schritte, OMP 4
      rechner: rechner-b (RTX 3050)
      logs: rechner-b:~/snai_pruef/cuda_i8/out/S_*
      notiz: Fremdlast: Textreihe b2 drei Kerne, Arm P ~1,3 Kerne. Rohdateien S_C1.* überschrieben, S_C2 bis S_GAB3 erhalten.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/cuda_i8/out/S_*; S_C1.* überschrieben, Median von C stützt sich darum teils auf den Bericht
  m2009 Wandzeit Median | 216,7 s | C |  | 3
  m2010 Wandzeit Median | 241,1 s | G |  | 3
  m2011 Wandzeit Median | 135,6 s | GA |  | 3
  m2012 Wandzeit Median | 95,1 s | GAB |  | 3
  m2013 G gegen C | +11,3 % | G gegen C |  | 3
Ergebnis e156 [2026-10-21 19:25]: teilweise
  Fazit: GPU-Adam (-44 % gegen G) und GPU-Backward (-30 % gegen GA) bringen beide klar mehr als 10 %; mit beiden ist die Karte bei 1024x2 gut doppelt so schnell wie die CPU. Ob die Karte allein (G) langsamer ist als die CPU, entscheidet die Messung nicht: +11,3 % liegt knapp über der Schwelle bei vermengter Fremdlast.
  Offen: G gegen C auf freiem Rechner; Abhängigkeit von OMP 4.
  Datei: rechner-b:~/snai_pruef/cuda_i8/kriterien.txt
Chronik:
  2026-10-21 19:25 angelegt (Nachtrag: Nachtrag 2026-10-21 aus der Kriteriendatei, rechner-b ~/snai_pruef/cuda_i8/out/S_* (speed1024.sh 2026-10-14 09:43).)
  2026-10-21 19:25 Rezept r166 (C, G, GA, GAB)
  2026-10-21 19:25 Status geplant -> laeuft (Rezept r166)
  2026-10-21 19:25 Messwerte m2009-m2013
  2026-10-21 19:25 Ergebnis e156: teilweise
  2026-10-21 19:25 Status laeuft -> ausgewertet (Ergebnis e156)
```
