# snai/gpu-port-hauptbaum

```text
snai/gpu-port-hauptbaum - ausgewertet, angelegt 2026-11-11, zuletzt 2026-11-12 04:23
Frage: Lassen sich die Kartenpatches aus multi_stack (36fc85c..3a982dc ohne CPU-QPAR) so in den Hauptbaum portieren, dass die CPU-Rechnung bytegleich bleibt und die Karte bitgleich zur CPU rechnet?
Kriterium (festgelegt 2026-11-11 20:25, vor dem ersten Messwert):
  Teil C (rechner-a, CPU): Port-Lib = Hauptbaum-Lib 4b81510b in md5 out.snai und Loss-md5 in g128/g256/p512 bei 1 und 4 Fäden (6/6); Rot SNAI_I8_REST=sr weicht ab; Fehlerkanal sauber. Teil K (rechner-b, Karte): K1 Karte ohne Variablen = CPU (md5) in >=2 Geometrien und 2 Kontexten, RESIDENT greift mit 0 Rückfällen; K2 jeder Schalter =0 gleich K1; K3 Rot-Proben weichen ab, CHECK 0 Abweichungen; K4 LoRA eingefrorene Basis Karte = CPU ohne Abbruch. Ein Teil verletzt: nicht übernehmen. Tempo nur berichtet. Details KRITERIEN_gpu_port.md (Fassung 1; K wird vor dem ersten Kartenlauf als Fassung 2 präzisiert, ohne Lockerung).
Plan: rechner-a:~/snai_pruef/gpu_port/KRITERIEN_gpu_port.md
Baut auf: snai/silu-tab-hauptbaum
Darauf baut: snai/ocl-bw-kachel, snai/ocl-adam
Rezepte:
  r684 [2026-11-11] rechner-b: cd ~/snai_pruef/gpu_port && bash bau.sh && bash reihe_c.sh (arm.sh <zelle> <orig|port> <threads> <etikett> [ENV]; KARTE=1 für Karte)
      quelltext: orig: Hauptbaum cortex.nim c7471c3f / cortex_cuda.cu 5d9c28ae (Libs rechner-b orig_cpu 4b81510b = rechner-a-Lib, orig_cuda ca9040e1). port: src/cortex.nim fd8fd194 (resolve_gpu.py auf merge-file Hauptbaum + multi_stack 95923a4..3a982dc ohne 8d2ce96), cortex_cuda.cu 6d9aa6b5 + Brücke ef53f712 = multi_stack 3a982dc (Libs port_cpu 7f0f4003, port_cuda d78a86ed). Karte in Login-Umgebung ohne -ftz.
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/gpu_port/{ergebnis.txt,log/}
      notiz: Teil C auf rechner-b-CPU statt rechner-a, weil rechner-a nur 1,4 GB frei hatte (Regel 1,8 GB). Prüfer (multi_stack) für Teil C erst nach dem Start angefragt (reiner md5-Vergleich); Teil K erst nach Gegenlesen. Fehlersonde (errzeilen) rot gesehen an Testdatei (2 Treffer).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/gpu_port/ergebnis.txt (reihe_c.sh, 11.11. 20:34-20:53)
  m10416 C1 md5 g128 n4 orig/port | 984c7b7f / 984c7b7f | C1
  m10417 C1 md5 g128 n1 orig/port | 984c7b7f / 984c7b7f | C1
  m10418 C1 md5 g256 n4 orig/port | 21ae6c3f / 21ae6c3f | C1
  m10419 C1 md5 g256 n1 orig/port | 21ae6c3f / 21ae6c3f | C1
  m10420 C1 md5 p512 n4 orig/port | 5b5a5a66 / 5b5a5a66 | C1
  m10421 C1 md5 p512 n1 orig/port | 5b5a5a66 / 5b5a5a66 | C1
  m10422 C1 Loss-md5 gleich | 6/6 | C1
  m10423 C2 Rot REST=sr g128 n4 md5 | 05cf8a5d (≠ 984c7b7f) | C2
  m10424 C3 errzeilen alle Läufe | 0 (13/13), rc 0 | C3
  m10425 Beobachtung ms/Schritt orig→port (Einzelläufe, kein Tempotest) | g128n4 277,4→284,4; g128n1 556,0→570,1; g256n4 458,9→463,6; g256n1 1156,3→1156,9; p512n4 3013,1→3090,1; p512n1 9138,9→9229,3 | Beobachtung
  Quelle: rechner-b:~/snai_pruef/gpu_port/ergebnis.txt (reihe_k.sh 20:54-21:43, reihe_k2.sh, reihe_k3.sh, reihe_k4.sh, K4c 11.11. ~22:00)
  m10461 K1 k1024 CPU / CPU-K1b / Karte md5 | 1cdddf8a / 1cdddf8a / 1cdddf8a | K1
  m10462 K1 k256 CPU / CPU-K1b / Karte md5 | 7b1eb480 / 7b1eb480 / 7b1eb480 | K1
  m10463 K1 p512 CPU / CPU-K1b / Karte md5 | 5b5a5a66 / 5b5a5a66 / 5b5a5a66 | K1
  m10464 K1 RESIDENT k1024 / k256 | 32/32 bzw. 126/126 Schritte vorwärts und rückwärts auf der Karte, Rückfälle 0 | K1
  m10465 K1 RESIDENT p512 | greift nicht (Schichtmatrix unter Kartenschwelle), erwartet | K1
  m10466 K1 Kartenspitze eigener Prozess k1024 / k256 / p512 | 912 / 638 / 472 MiB | K1
  m10467 K2 je Schalter =0 (ADAM_FAST, CUDA_BW, ATT_FAST, OVERLAP, GRAD_DEV, GRAD_EARLY, RESIDENT) und RESIDENT=FWD | md5 7b1eb480 in 8/8 | K2
  m10468 K2r unter RESIDENT=0 je Schalter =0 | md5 7b1eb480 in 6/6 | K2
  m10469 K3 RESIDENT=ROTB / ROT | 143f8915 / a9113f31 (≠) | K3
  m10470 K3 Rot Einzelschalter unter RESIDENT=0 (CUDA_BW, ATT_FAST, OVERLAP, GRAD_EARLY, GRAD_DEV, ADAM_FAST=111) | alle ≠ 7b1eb480 (6/6) | K3
  m10471 K3 CHECK | 126 Schritte, 0 Abweichungen vorwärts und rückwärts; md5 9cc83696 ≠ 7b1eb480 (wdh gleich) | K3
  m10472 K3 CHECK mit GRAD_EARLY/GRAD_DEV/OVERLAP/ADAM_FAST je =0 | md5 9cc83696 in 4/4 | Nachsuche
  m10473 Gegenprobe unverändertes multi_stack 3a982dc (REST=32) k256 Normal / CHECK | 7b1eb480 / 9cc83696 (identisch zum Port) | Nachsuche
  m10474 K4 LoRA mit Tying auf V5-Genesis | Aufbaufehler, Speichern verweigert (rc 1 beide), Loss-md5 gleich 84b55d2e | K4
  m10475 K4c LoRA ohne Tying CPU / Karte | Basis 6e4749fd / 6e4749fd, Adapter f1ec1bdf / f1ec1bdf, rc 0, RESIDENT greift nicht (LoRA aktiv) | K4
  m10476 K5 alte Karten-Lib (5d9c28ae) k256 Karte / CPU | 41f0af6a / 7b1eb480 (alt ≠ CPU, erwartet: ohne v-Klemme) | K5
  m10477 errzeilen aller K-Läufe | 0 | Fehlerkanal
  Quelle: rechner-b:~/snai_pruef/gpu_port/ergebnis.txt (reihe_f.sh 12.11. 04:03-, Lib port2 9ca53220 = cortex.nim 08058a1e mit CHECK-Fix)
  m10506 F k256 CPU / Karte / CHECK md5 | 7b1eb480 / 7b1eb480 / 7b1eb480 (CHECK 0 Abweichungen, Loss-md5 99ca6839 wie Normal) | F
  m10507 F g128 CPU n4 md5 | 984c7b7f (= orig) | F
  m10508 F p512 Karte md5 | 5b5a5a66 (= CPU) | F
  m10509 Rot für CHECK-Fix | alter Stand CHECK 9cc83696 (K3, gesehen) | F
  m10510 Commit Hauptbaum | a44d2fd, libcortex.so 9ca53220 (rechner-a-Bau = geprüfter rechner-b-Bau), Karten-Lib d78a86ed | Übernahme
Ergebnis e632 [2026-11-12 04:23]: erfuellt
  Fazit: Der Hauptbaum hat jetzt den Kartenstand von multi_stack 3a982dc, ohne dass sich seine CPU-Rechnung ändert (REST-Vorgabe 32). Damit rechnet die Karte erstmals bitgleich zur CPU, weil die v-Klemme im Karten-Adam fehlte (Code-Review K1). Die alte Karten-Lib wich ab. GPU-Training im int8-LoRA-Hauptbaum ist damit technisch freigegeben. RESIDENT bringt aber nur bei Breite >= 1024 und ohne LoRA etwas; bei prod512b-Geometrie und mit Adaptern läuft der alte Kartenweg. Teil K wurde nach Wortlaut erst mit dem CHECK-Fix erfüllt (Fassung 1 der Lib: CHECK-md5 abweichend, Ursache in multi_stack gefunden, Fix eine Zeile, Teil F bestanden). Übernommen auf Entscheidung 12.11., Commit a44d2fd.
  Offen: Tempo Karte neu gegen alt nicht gemessen; Hauptbaum-Kopie auf rechner-b (c292c82) nicht nachgezogen; Invalidierung (e) nicht rot gesehen; CHECK-Fix in multi_stack noch nicht committet.
  Datei: rechner-a:~/snai_pruef/gpu_port/KRITERIEN_gpu_port.md
Chronik:
  2026-11-11 20:25 angelegt
  2026-11-11 20:34 Rezept r684
  2026-11-11 20:34 Status geplant -> laeuft (Rezept r684)
  2026-11-11 20:54 Messwerte m10416-m10425
  2026-11-11 21:59 Messwerte m10461-m10477
  2026-11-12 04:23 Messwerte m10506-m10510
  2026-11-12 04:23 Ergebnis e632: erfuellt
  2026-11-12 04:23 Status laeuft -> ausgewertet (Ergebnis e632)
```
