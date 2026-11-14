# snai/bauart-tiefe

```text
snai/bauart-tiefe - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 16:11
Frage: Rechnet der Vorwaertspfad der Engine auch bei 4 und 8 Schichten genau die Bauart, die der PyTorch-Nachbau aus cortex.nim umsetzt?
Kriterium (nachgetragen, Beleg: Kriterium G1 aus kriterien_pytorch.txt vom 2026-10-15, Frage vom 2026-11-02, Lauf gleicher Tag):
  Uebernommen aus G1 von snai/geschichten-pytorch (kriterien_pytorch.txt): groesster Logit-Unterschied <= 1e-4 und gleiche Argmax an 128 Positionen, Rot mit vertauschten w_q/w_k muss reissen. Eintrag erst nach dem Lauf; das Kriterium stammt aus der Vorgaengerreihe, aber dieser Aufbau wurde nicht vorab eingetragen. Erster Aufruf ohne --ungebunden war ein Bedienfehler (Genesis V5 hat eigenes w_out, der Lade- und Dump-Pfad bindet nicht) und wird nicht gewertet.
Baut auf: snai/geschichten-pytorch
Darauf baut: snai/gradient-tiefe
Rezepte:
  r520 [2026-11-02] cd proj_L2; php knirps_gpu/pytorch/logits_dump.php <genesis> <koepfe> <tokens> <aus>; torch_venv/bin/python knirps_gpu/pytorch/torch_knirps.py check <genesis> <tokens> <aus> --koepfe <k> --ungebunden [--tausche-qk]
      quelltext: ms_tiefe/proj_L2 cortex cae946bf, libcortex e281ce8d (float-Vorwaertspfad, V5), torch_knirps.py 6ba90257 laut r64
      rechner: rechner-b, CPU
      logs: rechner-b:/tmp/lg (fluechtig), Zahlen im Messbuch
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: Ausgabe torch_knirps.py check, Genesis c_gen s1 (dim 512, 8 Koepfe), k64_gen_s4 (64, 4 Koepfe)
  m7600 max Logit-Diff, Argmax | 6,752e-09, 100 % | L2 dim 512 | 1 | 128
  m7601 max Logit-Diff, Argmax | 6,054e-09, 100 % | L4 dim 512 | 1 | 128
  m7602 max Logit-Diff, Argmax | 6,054e-09, 100 % | L8 dim 512 | 1 | 128
  m7603 max Logit-Diff, Argmax | 9,313e-10, 100 % | 64x4 | 4 | 128
  m7604 Rot q/k getauscht | 1,097e-03 / 7,522e-04 / 5,737e-04, ROT | L2 / L4 / L8 | 1 | 128
Ergebnis e454 [2026-11-02 16:11]: erfuellt
  Fazit: Der Schichtaufbau im Vorwaertspfad stimmt bis 8 Schichten mit dem PyTorch-Nachbau ueberein: die Tiefe ist kein Bauartfehler dieses Pfads. Damit bleibt fuer den fehlenden Tiefennutzen die Lerndynamik oder die Aufgabe, nicht die Verschaltung im Vorwaertsrechnen.
  Offen: Nur Genesis-Gewichte, float-Vorwaertspfad, CPU, ungebunden. Rueckwaertspfad bei mehr als 2 Schichten nicht numerisch verglichen (nur gelesen, PRUEFUNG_cortex_2026-11-02.md; Training-Gleichstand mit PyTorch nur 96x2). Int8-Vorwaertspfad und Karte hier nicht geprueft.
Chronik:
  2026-11-02 16:11 angelegt (Nachtrag: Kriterium G1 aus kriterien_pytorch.txt vom 2026-10-15, Frage vom 2026-11-02, Lauf gleicher Tag)
  2026-11-02 16:11 Rezept r520
  2026-11-02 16:11 Status geplant -> laeuft (Rezept r520)
  2026-11-02 16:11 Messwerte m7600-m7604
  2026-11-02 16:11 Ergebnis e454: erfuellt
  2026-11-02 16:11 Status laeuft -> ausgewertet (Ergebnis e454)
```
