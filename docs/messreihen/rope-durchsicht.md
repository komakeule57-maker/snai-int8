# snai/rope-durchsicht

```text
snai/rope-durchsicht - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 14:04
Frage: Rechnet die RoPE-Implementierung (cortex.nim ropeBase, applyRoPE samt Quantisierung danach) richtig, und bleibt die Abstands-Eigenschaft nach der 8-Bit-Quantisierung erhalten? Auftrag 2026-11-02, unabhängig von den Gains-Befunden.
Kriterium (festgelegt 2026-11-02 14:02, vor dem ersten Messwert):
  Vor dem ersten Lauf. Originalprozeduren per awk aus cortex.nim 2cfaaa0f, synthetische Vektoren, kein Training. T1 Rundlauf vor+zurück: größter relativer Fehler <= 1e-5. T2 float-Skalarprodukt je Kopf hängt nur von p-t ab: Abweichung <= 1e-4 von |q||k|. T3 Transponierte <Ru,w>=<u,R^-1 w>: <= 1e-5 von |u||w|. T4 Basis gegen Handformel, ctx128 d16 rund 2051: rel <= 1e-5. Je T in 3 von 3 Saaten, jede Kombination d 16,64 und ctx 64,256,512, sonst FEHLER. T5 N = Streuung von s_q(p,p-delta) über Verschiebungen p bei festem Inhalt und Abstand, geteilt durch Streuung von s_float über verschiedene Inhalte beim selben Abstand. N < 0,1 in 3 von 3: VERNACHLAESSIGBAR. N >= 0,1 in 3 von 3: SICHTBAR. Sonst saatabhängig. Innerhalb 5 % um 0,1 gilt als knapp, nicht erfüllt. Arme: Köpfe gleich groß; ein Kopf 8-fach größer. Rot je Test: Vorzeichen zurück nicht gedreht (T1,T3), K ungedreht (T2), Basis fest 10000 (T4), 3-Bit-Vergröberung (T5, N muss steigen). Reichweite: synthetisch, sagt nichts über echte Modellvektoren, Wirkung auf Loss nicht gemessen. Freie Parameter: Schwelle 0,1, Faktor 8, Vektorverteilung normal.
Rezepte:
  r514 [2026-11-02] cd ~/snai_pruef/rope; python3 gen.py; cat ext.nim rumpf.nim > sonde.nim; nim c -d:release -o:sonde sonde.nim; for s in 1 2 3; do ./sonde $s; done; Rot: ROT=sign, ROT=k, ROT=bit3, gen.py base
      quelltext: cortex.nim 2cfaaa0f, ext.nim a36cf9cb, rumpf.nim 8b820271, sonde.nim e21a50c4
      parameter: d 16,64; 8 Koepfe; ctx 64,256,512; Abstand 1,8,ctx/2; 150 Inhalte, 16 Verschiebungen
      seed: 1,2,3
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/rope/g1.txt, g2.txt, g3.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/rope/g1.txt, g2.txt, g3.txt; Rot aus dem Sondenlauf
  m7526 T1 Rundlauf groesster Fehler | 4,56e-8 | Original | 1-3
  m7527 T2 Abstand float | 7,31e-8 | Original | 1-3
  m7528 T3 Transponierte | 1,67e-8 | Original | 1-3
  m7529 T4 Basis gegen Handformel | 3,87e-8 | Original | 1-3
  m7530 T1 Rot Vorzeichen | 0,64 | Rot | 1
  m7531 T2 Rot K ungedreht | 1,05 | Rot | 1
  m7532 T3 Rot Vorzeichen | 0,30 | Rot | 1
  m7533 T4 Rot Basis fest | 9,77 | Rot | 1
  m7534 T5 N | 0,0092 bis 0,0117 | gleich | 1-3 | 18
  m7535 T5 N | 0,056 bis 0,0766 | schief | 1-3 | 18
  m7536 T5 E | 0,0094 bis 0,0117 | gleich | 1-3 | 18
  m7537 T5 E | 0,0562 bis 0,0789 | schief | 1-3 | 18
  m7538 T5 N Rot 3 Bit | 0,28 bis 0,29 | gleich | 1
  m7539 T5 N Rot 3 Bit | 0,49 bis 0,52 | schief | 1
Ergebnis e449 [2026-11-02 14:04]: erfuellt
  Fazit: RoPE ist in Ordnung und scheidet im geprueften Bereich als Fehlerquelle aus, auch nach der Quantisierung; weitere Arbeit lohnt dort nicht. Praktische Folge: Die Basis haengt am ctx, darum gehoert sie bei jedem ctx-Vergleich als mitlaufende Groesse in die Kriteriendatei.
  Offen: Echte Modellvektoren und Kopf-Ungleichheit nicht gemessen; Wirkung auf den Loss nicht gemessen; Verhalten der Drehungen beim Net2Net-Wachstum nicht geprueft.
  Datei: rechner-a:~/snai_pruef/rope/ERGEBNIS_rope.md
Chronik:
  2026-11-02 14:02 angelegt
  2026-11-02 14:04 Rezept r514
  2026-11-02 14:04 Status geplant -> laeuft (Rezept r514)
  2026-11-02 14:04 Messwerte m7526-m7539
  2026-11-02 14:04 Ergebnis e449: erfuellt
  2026-11-02 14:04 Status laeuft -> ausgewertet (Ergebnis e449)
```
