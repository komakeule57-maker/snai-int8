# snai/dim512-ftz-mechanismus

```text
snai/dim512-ftz-mechanismus - ausgewertet, begonnen 2026-09-24, angelegt 2026-10-21, zuletzt 2026-10-21 19:34
!! ohne Kriterium
Frage: Wo im Kern entstehen die Denormalen, die prod512 auf dem Xeon bremsen, und warum werden es mit dem Training mehr?
Kriterium: KEINS - Ergebnisse dieser Reihe sind Beobachtungen.
Baut auf: snai/dim512-ftz-vorwaerts
Rezepte:
  r214 [2026-10-21] kernel.perf_event_paranoid vorübergehend 4 -> 2; perf stat -e fp_assist.simd_input,fp_assist.simd_output,fp_assist.any,cycles -p <s12-Arbeiter> (60 s); perf record -e fp_assist.simd_input:u -c 20000; Held-out 4 Fenster auf s5 und s11 ohne FTZ
      quelltext: libcortex.so.bak_pre_ftz_20260924; Adressen 0x2fb81 / 0x2f0ec von Hand auf cortex.nim:4358 / :4562 aufgelöst
      rechner: vserver
      logs: k. A.
Messwerte (Groesse | Wert | Arm | Start | n):
 , nicht nachgerechnet (Rohdaten auf vserver nicht mehr vorhanden: ~/.cache/prod512 seit 2026-10-09 leer)
  m2504 fp_assist.any in 60 s | 92.225.054 (1,54 Mio. je s) | laufender s12-Arbeiter ohne FTZ |  | 1
  m2505 fp_assist.any | 0 | frischer Prozess mit FTZ-Bibliothek |  | 1
  m2506 Zyklen je Assist | 185 bzw. 222 | vserver |  | 2
  m2507 Anteil Stichproben in trainStepI8Batched | 92,7 % (41,75 % vorwärts V-Summe, 49,95 % rückwärts d_v) | vserver |  | 2110
  m2508 Assists Held-out 4 Fenster | 15.489.411 | s5 |  | 4
  m2509 Assists Held-out 4 Fenster | 89.502.813 (5,78-fach) | s11 |  | 4
  m2510 Instruktionen s11 gegen s5 | gleich auf 0,004 % | Held-out |  | 4
Ergebnis e202 [2026-10-21 19:34]: beobachtung
  Fazit: Die Denormalen entstehen beim Produkt mit dem Softmax-Gewicht der Attention, vorwärts in der gewichteten V-Summe und rückwärts im d_v-Gradienten. Bei gleicher Arbeit erzeugt s11 5,8-mal so viele Assists wie s5; Zeitgewinn, Assistzahl und Assistkosten passen unabhängig zusammen. Deutung, nicht gemessen: die Attention wird spitzer und die Gradienten kleiner. Im Nachhinein passt das zur später gefundenen Attention-Sättigung des Laufs (snai/kopier-prod512-attention): der Drift war ein frühes, übersehenes Symptom davon.
  Offen: Zuordnung von 0x2f0ec über das Instruktionsmuster, nicht über Debug-Info. Die Verbindung zur Sättigung ist Deutung.
Chronik:
  2026-10-21 19:34 angelegt (Nachtrag: Kein Kriterium vorab; Messung mit perf (fp_assist.*) (2026-09-24 15:05).)
  2026-10-21 19:34 Rezept r214
  2026-10-21 19:34 Status geplant -> laeuft (Rezept r214)
  2026-10-21 19:34 Messwerte m2504-m2510
  2026-10-21 19:34 Ergebnis e202: beobachtung
  2026-10-21 19:34 Status laeuft -> ausgewertet (Ergebnis e202)
```
