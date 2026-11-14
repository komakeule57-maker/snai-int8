# snai/gradient-tiefe

```text
snai/gradient-tiefe - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 16:37
Frage: Rechnet der Rueckwaertspfad der Engine je Schicht dasselbe wie PyTorch-Autograd, auch in Mittelschichten bei 4 und 8 Schichten?
Kriterium (festgelegt 2026-11-02 16:30, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/gt/kriterien.txt, vor dem ersten Lauf, kein Pruefer (kein Vergleich von Armen, Rot und Referenz sichern das Geraet). Je Tensor und Schicht cos(Engine, Torch) und r relativ zum Median-r. F (FP32): GLEICH cos >= 0,999 und Abweichung r <= 1 % an allen Tensoren. I (int8, Torch auf gerundeten Gewichten): VERTRAEGLICH cos >= 0,95 und r <= 10 % an Tensoren mit Norm >= 1e-3 x groesste. MITTE AUFFAELLIG: schlechtester cos Mittelschichten > 0,05 unter schlechtestem der Randschichten in >=2 Modellen. Rot: Torch mit getauschten w_q/w_k muss in F reissen; Schalter leer bytegleich Original.
Plan: rechner-b:~/snai_pruef/gt/kriterien.txt
Baut auf: snai/bauart-tiefe, snai/geschichten-pytorch
Darauf baut: snai/adam-schatten, snai/swiglu-umbau
Rezepte:
  r521 [2026-11-02] cd ~/snai_pruef/gt && ./lauf.sh; ./run.sh; python3 ausw.py; python3 a2.py; Rot: vergleich.py gen/<m>.snai d/<m>_F.bin <k> F --tausche; kan.py
      quelltext: ms_tiefe/proj_L2 cortex cae946bf + patch_gd.py, libcortex 4c2f0c93; vergleich.py nutzt Vorwaertspfad aus torch_knirps.py; export.php
      parameter: 64xL2/L4/L8 Genesis und nach 308 FP32-Schritten, 128x4 K1 s11 Ende (L2 tot 85,9 %), 512x8 Genesis; je 1 Fenster a 128; Pfade FP32 und SNAI_INT8_FULL=1
      rechner: rechner-b, CPU, OMP 2
      logs: rechner-b:~/snai_pruef/gt/erg.jsonl, log/, d/, kriterien.txt 2fc82189
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/gt/erg.jsonl, a2.py, kan.py
  m7605 Tensoren reissen / gesamt | 0 / 379 | F |  | 9
  m7606 cos min, r Bereich | 0,99999999, 0,99995-1,000005 | F |  | 9
  m7607 Tensoren reissen / gesamt | 0 / 336 | I |  | 8
  m7608 cos min, r Bereich | 0,9945 (wk3 g128), 0,943-1,087 | I |  | 8
  m7609 Rot q/k getauscht reissen | 46/67 a8t, 35/35 g128 | F
  m7610 Schalter leer gegen Original | 280bb3fc beide | I
  m7611 rms_ffn2 g128 tot: Kanaele, cos, Vorzeichen | 110, 0,9979, 99,1 % | I
  m7612 rms_ffn2 g128 lebend: Kanaele, cos, Vorzeichen | 18, 0,9986, 100 % | I
  m7613 Mitte gegen Rand cos schlechtester g128 | 0,9965 / 0,9945, nicht auffaellig | I
Ergebnis e456 [2026-11-02 16:37]: erfuellt
  Fazit: F GLEICH, I VERTRAEGLICH, Mitte nicht auffaellig: Der Rueckwaertspfad rechnet bis 8 Schichten denselben Gradienten wie Autograd, auch an gekippten Gains. Ein Bauartfehler in den Schichten faellt damit als Erklaerung fuer Kippen und fehlenden Tiefennutzen weg (CPU). Der Zug auf sterbende Gains ist echter Loss-Gradient. Die Suche bleibt bei Adam, Rundung, Rezept und Aufgabe.
  Offen: Int8-Bias: r 0,943-1,087 gilt je Fenster; ob die Abweichung ueber viele Fenster wegmittelt oder je Tensor systematisch ist, ist nicht gemessen (Einwand SnAI Evo; Stichprobe waere rund 100 Fenster, mittleres r je Tensor). Karte nicht direkt geprueft; nach Evo K1 s4 CPU und Karte bitgleich ueber 9.002 Schritte, 128x4, Saat 4 (snai/gains-batchgen, nicht selbst nachgelesen). Nur je 1 Fenster und Saat. Adam-Schritt und Clip danach nicht verglichen. prod512b nicht. Zwei Bedienfehler per Nachtrag behoben.
  Datei: rechner-b:~/snai_pruef/gt/ERGEBNIS_gradient_tiefe.md
Abgeloest und ausgeblendet: 1 ergebnis - voll=True zeigt sie.
Chronik:
  2026-11-02 16:30 angelegt
  2026-11-02 16:36 Rezept r521
  2026-11-02 16:36 Status geplant -> laeuft (Rezept r521)
  2026-11-02 16:36 Messwerte m7605-m7613
  2026-11-02 16:36 Ergebnis e455: erfuellt
  2026-11-02 16:36 Status laeuft -> ausgewertet (Ergebnis e455)
  2026-11-02 16:37 Ergebnis e456: erfuellt, loest e455 ab
```
