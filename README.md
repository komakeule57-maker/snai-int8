# snai-int8

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.24249038.svg)](https://doi.org/10.5281/zenodo.24249038)

**Kleine Sprachmodelle in int8 trainieren: int8-Gewichte, ganzzahlige Matrixmultiplikation vorwärts und rückwärts, 8-Bit-Adam-Momente.**
Eine eigene Engine in Nim (CPU mit OpenMP, CUDA, OpenCL) mit schlanker PHP-Steuerung, dazu die Forschungsakte: jede
Messreihe mit vorher festgelegtem Kriterium, Rezept, Messwerten und Urteil.

> *English summary:* snai-int8 is a research engine for int8 training of small transformer language models: int8
> weights, integer matmuls in forward and backward with int32 gradient accumulation, and 8-bit Adam moments.
> Normalization, softmax, loss and the optimizer update are still computed in float.
> The engine is written in Nim with CPU (OpenMP), CUDA and OpenCL backends that are bit-identical to the CPU reference.
> The repository also contains the research log (413 measurement series, each with a pre-registered criterion, recipe,
> raw values and verdict). Documentation is in German.

Stand: **Forschungsprototyp, 2026-11-13.** Das ist der Anfang der Arbeit, kein fertiges Produkt. Die konservative
fp32-Fassung zum Ausprobieren ist die Distro [komakeule57-maker/SnAI](https://github.com/komakeule57-maker/SnAI).

## Was bisher belegt ist

Die Zahlen stammen aus den verlinkten Messreihen. Jede nennt dort ihre Reichweite (Modellgröße, Saaten, Datensatz)
und was sie ausdrücklich *nicht* beantwortet.

- **Der int8-Stack (`SNAI_INT8_FULL`) trainiert stabil.** Kleines Modell (dim 128, 2 Schichten): Der Abstand zu FP32
  wächst über 14.700 Schritte und eine zweite Epoche an zwei Startpunkten nicht. Er kostet 0,16–0,23 nats bei einem um
  24,5 % kleineren Modell. → [int8-port](docs/messreihen/int8-port.md)
- **Bei Breite 512 bleibt ein Pegelabstand, der nicht wächst.** 0,25 nats hinter FP32 nach 400 Schritten, ohne Trend.
  Nach der vorab festgelegten Regel ergibt das *keine Aussage*. → [int8-fp32-dim512-gepaart](docs/messreihen/int8-fp32-dim512-gepaart.md)
- **Adaption über int8-LoRA:** Rang 8 auf eingefrorener int8-Basis war auf diesem Korpus das beste gemessene
  Verfahren, 0,11 nats vor der Voll-Feinabstimmung, mit −39 % Trainingsspeicher. → [lora-verfahren](docs/messreihen/lora-verfahren.md)
- **GPU-Pfade sind bitgleich zur CPU** (gleiche Prüfsumme des trainierten Modells): unter CUDA, unter OpenCL seit
  November 2026 ebenso. → [cuda-i8-anschluss](docs/messreihen/cuda-i8-anschluss.md), [att-gpu](docs/messreihen/att-gpu.md)
- **OpenCL auf einer Ryzen-APU (Vega-iGPU):** Ein gekachelter Vorwärtskern machte den OpenCL-Pfad 2,3- bis 3,1-mal
  schneller. Mit ROCm ist die iGPU damit erstmals etwas schneller als die CPU. → [ocl-umbau-tempo](docs/messreihen/ocl-umbau-tempo.md)
- **GPUs ohne float-Denormale** (z. B. Mesa rusticl): Ein nativer float-Kurzweg mit exakter Rückfallprüfung ersetzt den
  double-Nachbau, ohne ein Bit zu ändern. Attention auf der Karte 2,14-mal schneller.
  → [ocl-att-rusticl](docs/messreihen/ocl-att-rusticl.md), [ocl-sn2-rusticl](docs/messreihen/ocl-sn2-rusticl.md)

Viele Reihen enden mit *verfehlt*, *gleichstand* oder *keine_aussage*. Sie stehen gleichberechtigt in der
Übersicht: **[docs/MESSREIHEN.md](docs/MESSREIHEN.md)**.

## Einordnung

**snai-int8 ist int8-Training, kein reines Ganzzahl-Training.** Die großen Rechnungen laufen ganzzahlig, ein Teil
des Trainings rechnet weiter in float (Liste unten). Die nächstverwandte Arbeit ist das reine Ganzzahl-Training von
Shalby, Pittorino und Roveri [1]: Gewichte, Gradienten, Momentum und Aktivierungen durchgehend INT8, dazu Attention,
Softmax, LayerNorm, GELU und der Optimierer-Schritt ganzzahlig, float nur bei der Eingabewandlung und im
Lernratenplan. Ihr kleinster Transformer ist ein ViT-Ti mit 5,36 Mio. Parametern, von Grund auf trainiert auf CIFAR-10
(88,0 % gegen 90,9 % in FP32), mit SGD und Momentum. [1] ist damit **in fast allem ganzzahliger als snai-int8.**

Worin snai-int8 sich unterscheidet:

- Es trainiert **Sprachmodelle** (kausale Transformer auf Text) statt Bildklassifikatoren.
- Es reicht **unter 1 Mio. Parameter**: Der Knirps 96×2 (rund 0,37 Mio. Parameter, Breite 96, 2 Schichten) erreicht
  auf Kurzgeschichten mit dem int8-Stack dieselbe Held-out-Qualität wie ein gepaart trainiertes PyTorch-Modell in
  float32 (Gleichstand, 3 Paare, 25.000 Schritte; mit dem Engine-Stand vom 15.11.2026 0,15 % zugunsten von snai-int8,
  im Oktober 0,55 %). → [geschichten-pytorch](docs/messreihen/geschichten-pytorch.md),
  [sr-knirps-nachweis](docs/messreihen/sr-knirps-nachweis.md)
- Es nutzt **Adam mit 8-Bit-Momenten** statt SGD mit Momentum.

**Ganzzahlig** sind: int8-Gewichte (mit float-Skala je Zeile), die Matrixmultiplikationen vorwärts (int8 × int8 →
int32) und rückwärts (int8-GEMM für den Eingangsgradienten), die Gradienten-Akkumulation (int32), K/V-Cache und
FFN-Ein- und -Ausgang (int8 mit Skala je Position) und die Adam-Momente im Speicher (8 Bit, log-kodiert, Skala je
Zeile).

**Noch in float** sind:

- der Gradientenpuffer (float32 je Gewicht, nur innerhalb eines Schritts gebraucht, aber dauerhaft angelegt),
- der Adam-Schritt je Gewicht (Entquantisieren, Bias-Korrektur, Wurzel, Division, Weight Decay),
- die Softmax der Attention (Q·K selbst läuft int32) und Logits/Cross-Entropy,
- RMSNorm, RoPE und die Aktivierungen im Restpfad,
- die RMSNorm-Gains samt ihren Momenten (beim Knirps 480 von 0,37 Mio. Parametern),
- im Checkpoint die Adam-Momente (Format float32, Inhalt 8 Bit),
- Skalare: Lernrate, β-Potenzen, Clip-Norm.

Diese Teile sollen bis zum nächsten großen Release ganzzahlig werden.

**Rundungsrest:** In der Vorgabe hält snai-int8 je Gewicht einen float32-Rundungsrest (Fehlerrückführung, siehe
`cortex.nim`, Abschnitt FEHLER-RUECKFUEHRUNG). Mit `SNAI_I8_REST=sr` werden die Gewichte stochastisch gerundet, und
der Rest-Puffer wird gar nicht erst angelegt (4 Byte je Gewicht gespart, auf der CPU geprüft). Über die Schritte
hinweg gibt es dann keinen float-Zustand je Gewicht mehr; der Gradientenpuffer oben bleibt. Das kostet beim Knirps
96×2 rund 1 % Held-out (+1,10 % gegen die Vorgabe, +0,96 % gegen float32, 3 Paare, in allen drei schlechter); eine
Verzerrung der Rundung durch den Hash war in der Prüfung nicht messbar.
→ [sr-knirps-nachweis](docs/messreihen/sr-knirps-nachweis.md), [sr-hash-bias](docs/messreihen/sr-hash-bias.md)

Die Entwicklung der int8-Engine begann im März 2026, öffentlich ist sie seit dem 14.11.2026, [1] am 12.10.2026.
Wir beanspruchen keinen Vorrang beim Ganzzahl-Training.

> *English:* Integer-only training has been shown for vision models [1] (INT8 weights, gradients, momentum and
> activations; integer attention, softmax, normalization and optimizer step; smallest transformer ViT-Ti, 5.36M
> parameters, CIFAR-10, SGD with momentum). snai-int8 is int8 training, not integer-only training, and [1] is more
> integer in almost every respect. snai-int8 differs in that it trains language models, goes below 1M parameters
> (a 0.37M model matches a paired float32 PyTorch baseline on short stories) and uses Adam with 8-bit moments.
> Integer in snai-int8: int8 weights with per-row float scales, forward and backward matmuls, int32 gradient
> accumulation, 8-bit Adam moments in memory. Still float: a per-weight float32 gradient buffer, the per-weight Adam
> update, attention softmax, logits and cross-entropy, RMSNorm, RoPE, residual activations, RMSNorm gains, and the
> Adam moments as stored in the checkpoint. With `SNAI_I8_REST=sr` the per-weight float32 rounding residual is
> dropped (no per-weight float state across steps; verified on CPU) at a cost of about 1 % held-out loss on the
> 0.37M model.

[1] H. H. Y. Shalby, F. Pittorino, M. Roveri: *Memory-Efficient Integer-Only Training of Deep Neural Networks.*
arXiv:2610.16298, 2026. https://arxiv.org/abs/2610.16298

## Arbeitsweise der Messungen

- Das Kriterium für „besser/schlechter“ steht **vor** dem ersten gezählten Lauf fest. Wo es nachgetragen wurde, sagt
  die Reihe das ausdrücklich.
- Unter 10 % Unterschied ist Gleichstand. Für einzelne Tempo-Reihen gilt 5 %, das steht dann in der Reihe.
- Jede neue Sonde wird einmal absichtlich rot gesehen (Fehler herbeiführen, Ausschlag prüfen).
- Befund und Deutung stehen getrennt. Eine Deutung ist als „nicht gemessen“ markiert.

## Inhalt

| Teil | Dateien |
|---|---|
| Engine | `cortex.nim` (CPU, int8-Training), `cortex_opencl.nim`, `cortex_cuda.cu` + `cortex_cuda_bridge.nim`, `snai_tensor_utils.nim` |
| Steuerung | `train_cluster.php`, `train_worker.php`, `train_defaults.php`, `init_base.php`, `tensor_ffi_adapter.php`, `tensor_io.php`, `tensor_utils_ffi.php`, `snai_tokenizer.php`, `snai_inference.php`, `eval_held_out*.php`, `*_config.php`, `revival_config.json`, `symbio_vocab.json` |
| Forschungsakte | `docs/MESSREIHEN.md`, `docs/messreihen/` |
| Bauen und Starten | [BAUEN.md](BAUEN.md) |

**Bewusst nicht enthalten:** Datensammler, Prüf- und Hilfsskripte, interne Dokumentation, Trainingsdaten und
Checkpoints. Messreihen nennen solche Skripte in ihren Rezepten; das ist Protokoll, die Skripte liegen nicht hier.
Das Neuron-Revival, ein optionaler Eingriff während des Trainings, ist nicht enthalten und in `revival_config.json`
abgeschaltet. Läufe aus Reihen, die mit Revival gerechnet wurden, sind daher nicht bytegleich nachstellbar.

Rechnernamen sind neutralisiert: `rechner-a` = Ryzen-APU (Vega-iGPU, ROCm und rusticl), `rechner-b` = Rechner
mit NVIDIA-Karte, `vserver` = gemieteter VServer (nur CPU), `rechner-c`/`rechner-d` = weitere Rechner.

## Lizenz

[Apache License 2.0](LICENSE)
