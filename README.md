# snai-int8

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.24249038.svg)](https://doi.org/10.5281/zenodo.24249038)

**Kleine Sprachmodelle in int8 trainieren: int8-Gewichte, ganzzahlige Matrixmultiplikation vorwärts und rückwärts, 8-Bit-Adam-Momente.**
Mit dem Schalter `SNAI_I8_GANZ=12` läuft das Training auf der CPU vollständig ganzzahlig.
Eine eigene Engine in Nim (CPU mit OpenMP, CUDA, OpenCL) mit schlanker PHP-Steuerung, dazu die Forschungsakte: jede
Messreihe mit vorher festgelegtem Kriterium, Rezept, Messwerten und Urteil.

> *English summary:* snai-int8 is a research engine for int8 training of small transformer language models: int8
> weights, integer matmuls in forward and backward with int32 gradient accumulation, and 8-bit Adam moments. In the
> default path, normalization, softmax, loss and the optimizer update are computed in float. With the switch
> `SNAI_I8_GANZ=12`, training runs entirely in integer arithmetic on the CPU, including attention softmax, RMSNorm,
> cross-entropy and an integer Adam update; a 0.37M-parameter model trained this way ends 0.6–1.3 % above a
> paired float32 PyTorch baseline (3 seeds, 25,000 steps; pre-set threshold 5 %), at about 3.7× the CPU time. The GPU
> paths are not integer yet. The engine is written in Nim with CPU (OpenMP), CUDA and OpenCL backends that are bit-identical to the CPU
> reference. The repository also contains the research log (measurement series, each with a pre-registered
> criterion, recipe, raw values and verdict). Documentation is in German.

Stand: **Forschungsprototyp, 2026-11-16.** Das ist der Anfang der Arbeit, kein fertiges Produkt. Die konservative
fp32-Fassung zum Ausprobieren ist die Distro [komakeule57-maker/SnAI](https://github.com/komakeule57-maker/SnAI).

## Was bisher belegt ist

Die Zahlen stammen aus den verlinkten Messreihen. Jede nennt dort ihre Reichweite (Modellgröße, Saaten, Datensatz)
und was sie ausdrücklich *nicht* beantwortet.

- **Mit dem Schalter `SNAI_I8_GANZ=12` trainiert der Knirps auf der CPU ganz ganzzahlig, ohne messbaren Verlust
  gegen den bisherigen Weg.** Der Knirps 96×2 (rund 0,37 Mio. Parameter) liegt dann nach 25.000 Schritten auf
  Kurzgeschichten 1,31 / 0,64 / 0,70 % über einem gepaart
  trainierten PyTorch-Modell in float32 (3 Saaten, vorab festgelegte Schwelle 5 %). Gegen den bisherigen int8-Weg ist
  es Gleichstand (Mittel −0,07 %). Das Ergebnis ist in allen vier Rundungsmodi des Prozessors bytegleich, eine
  absichtlich eingebaute float-Rechnung wird an jeder geprüften Stelle erkannt.
  → [fullint8-schluss](docs/messreihen/fullint8-schluss.md), [fullint8-schluss12](docs/messreihen/fullint8-schluss12.md)
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

## Schalter: ganz ganzzahliges Training (`SNAI_I8_GANZ=12`)

Mit dem Schalter `SNAI_I8_GANZ=12` läuft auf der CPU jeder Trainingsschritt ganzzahlig. Ohne ihn (Vorgabe) rechnet
die Engine wie bisher: ganzzahlige Matrixmultiplikationen, Normierung, Softmax, Loss und Adam-Schritt in float.
Der Umbau besteht aus 12 Stufen, jede mit eigenem Schalter (`SNAI_I8_GZ_<STUFE>=0|1`) und eigener Messreihe;
ausgeschaltet ist die Engine bytegleich zum früheren Stand.

| Teil des Trainings | voll ganzzahlig |
|---|---|
| Gewichte | int8, Skala je Zeile ganzzahlig gebildet |
| Matrixmultiplikationen vorwärts und rückwärts | int8 × int8 → int32 |
| Gradientenpuffer | int32-Mantisse je Gewicht, Exponent je Zeile; kein float32-Puffer |
| Attention-Softmax | Tabelle für 2⁻ˣ in Festkomma (Q30) |
| Logits und Cross-Entropy | ganzzahlig; der Verlust als Zahl wird nur fürs Protokoll gebildet |
| RMSNorm, RoPE, SiLU, Restpfad | ganzzahlig (int64-Quadratsumme, ganzzahlige Wurzel, Tabellen, Mantisse mit Exponent) |
| Adam-Schritt | ganzzahlig auf den 8-Bit-Log-Momenten: Bias-Korrektur, Wurzel, Division, Weight Decay, stochastisches Runden |
| Lernratenplan, β-Potenzen, Gradienten-Clipping | Festkomma bzw. ganzzahlig |
| Mitteln mehrerer Worker | ganzzahlig |
| Checkpoint | Momente als 8-Bit-Code plus Zeilenskala (Format `SNAI_V8`) |

Was dabei nicht ganzzahlig ist, und warum es zählt oder nicht:

- **Startgewichte:** Das Training beginnt aus einer float-Startdatei, die beim Start einmal nach int8 quantisiert wird.
  Das ist Initialisierung, nicht Training.
- **Speicherformat:** RMSNorm-Gains, ihre Momente und alle Skalen werden ganzzahlig berechnet, aber als
  float32-Bitmuster abgelegt. Gerechnet wird mit ihnen nur ganzzahlig.
- **Hyperparameter:** β1, β2, ε, Weight Decay und die Anfangslernrate werden als float32 übergeben und je Schritt exakt
  zerlegt; sie zählen als Eingabe, nicht als float-Rechnung.
- **Tabellen** (u. a. 2⁻ˣ, RoPE, Log-Code der Adam-Momente) werden beim ersten Gebrauch gebaut, fest im
  Rundungsmodus „nächster“.
- **Protokoll:** Verlust, Gradientennorm und die Lernrate in der PHP-Steuerung gibt es als float nur für Ausgabe und
  Wache; sie fließen nicht zurück ins Training.

Geprüft ist das mit einer Rundungsprobe: Derselbe Lauf über 5.001 Schritte ergibt in allen vier Rundungsmodi des
Prozessors (nächster, zur Null, auf, ab) Byte für Byte denselben Checkpoint, auch mit 2 Workern; das Fortsetzen aus
einem Checkpoint ist im Kurzlauf (232 Schritte) geprüft. Eine absichtlich eingebaute float-Rechnung im Hauptfaden,
in der OpenMP-Schleife oder im AVX-Pfad ändert das Ergebnis jeweils. Die Probe sieht nur float-Rechnungen, deren
Ergebnis von der Rundung abhängt; die exakten Zerlegungen oben sieht sie nicht.

Der ganzzahlige Weg verlangt `SNAI_I8_REST=sr` (oder `0`); einen float32-Rundungsrest je Gewicht gibt es dort nicht.
Über 25.000 Schritte zeigen Telemetrie und gepaarte Einzelvergleiche keinen späten Zerfall: Null-Gradienten höchstens
0,03 % je Matrix, Restpfad stabil, ohne den ganzzahligen Restpfad oder ohne den ganzzahligen Adam jeweils Gleichstand.

**Voraussetzungen:** `SNAI_INT8_FULL=1`, `SNAI_TIE_EMBEDDINGS=1`, `SNAI_I8_REST=sr` oder `0`, ohne LoRA, Dropout,
Wachstum und FFN-Skip, nur CPU. Sonst bricht der Schalter mit einer Meldung ab.

**Grenzen:** gemessen nur am Knirps 96×2, auf einem Korpus, mit 1–2 Workern.
Auf der CPU ist der ganzzahlige Weg rund 3,7-mal langsamer als der bisherige. Ob das Ergebnis bei größeren Modellen,
längeren Läufen oder mehr Workern hält, ist nicht gemessen.
→ [fullint8-schluss](docs/messreihen/fullint8-schluss.md), [fullint8-schluss12](docs/messreihen/fullint8-schluss12.md)

## Einordnung

**snai-int8 ist in der Vorgabe int8-Training, kein reines Ganzzahl-Training:** Die großen Rechnungen laufen
ganzzahlig, Normierung, Softmax, Loss und Adam-Schritt in float. Mit dem Schalter `SNAI_I8_GANZ=12` läuft das
Training auf der CPU ganz ganzzahlig (Abschnitt oben); auf der Karte noch nicht.

Verwandte Arbeiten, die vorher veröffentlicht wurden:

- **Shalby, Pittorino und Roveri [1]** trainieren Bildmodelle durchgehend in INT8 (Gewichte, Gradienten, Momentum,
  Aktivierungen, Attention, Softmax, LayerNorm, GELU), mit SGD und Momentum. Ihr kleinster Transformer ist ein ViT-Ti
  mit 5,36 Mio. Parametern auf CIFAR-10 (88,0 % gegen 90,9 % in FP32).
- **Jataí [2]** trainiert Transformer vollständig in INT8 (Mantisse mit Exponent je Block), auch Sprachmodelle auf
  Text. Unter 1 Mio. Parametern zeigt es das an einer synthetischen Induktionsaufgabe; auf Text (31,6 Mio.) hört das
  Modell nach 3.000–4.000 Schritten auf zu lernen, während float weiterlernt.
- **int-llm [3]** trainiert ein winziges Zeichen-GPT ganz ohne float, in 64-Bit-Festkomma (Q16.48) statt int8.

Worin snai-int8 sich unterscheidet:

- Es trainiert **Sprachmodelle auf Text unter 1 Mio. Parametern**: Der Knirps 96×2 (rund 0,37 Mio. Parameter) liegt
  im gepaarten Vergleich mit PyTorch in float32 im bisherigen Weg gleichauf, mit dem Ganzzahl-Schalter höchstens
  1,3 % darüber (vorab festgelegte Schwelle 5 %).
  → [geschichten-pytorch](docs/messreihen/geschichten-pytorch.md), [fullint8-schluss](docs/messreihen/fullint8-schluss.md)
- Es nutzt **Adam mit 8-Bit-Momenten** statt SGD mit Momentum, mit dem Schalter auch im Schritt selbst ganzzahlig.

Die Entwicklung der int8-Engine begann im März 2026, öffentlich ist sie seit dem 14.11.2026; [1] erschien am
12.10.2026, [2] ist seit dem 04.11.2026 öffentlich, [3] seit Juni 2026.
Wir beanspruchen keinen Vorrang beim Ganzzahl-Training.

**Rundungsrest im bisherigen Weg:** Ohne `SNAI_I8_GANZ` hält snai-int8 in der Vorgabe je Gewicht einen
float32-Rundungsrest (Fehlerrückführung, siehe `cortex.nim`, Abschnitt FEHLER-RUECKFUEHRUNG). Mit `SNAI_I8_REST=sr`
werden die Gewichte stattdessen stochastisch gerundet, und der Rest-Puffer entfällt. Das kostet beim Knirps 96×2
rund 1 % Held-out (+1,10 % gegen die Vorgabe, +0,96 % gegen float32, 3 Paare); eine Verzerrung der Rundung durch den
Hash war nicht messbar. → [sr-knirps-nachweis](docs/messreihen/sr-knirps-nachweis.md),
[sr-hash-bias](docs/messreihen/sr-hash-bias.md)

> *English:* By default snai-int8 is int8 training, not integer-only training: the large matmuls are integer,
> normalization, softmax, loss and the Adam update are float. With `SNAI_I8_GANZ=12`, training on the CPU is entirely
> integer; exceptions are the one-time int8 quantization of the float initial weights, hyperparameters passed as
> float32 and split exactly into integers, lookup tables built once at start, and log output. Gains, their moments
> and all scales are computed in integers and stored as float32 bit patterns. A rounding-mode test (all four FPU
> rounding modes give byte-identical checkpoints; injected float operations are detected) checks this. Related
> earlier work: integer-only training of vision transformers down to 5.36M parameters [1]; fully INT8 transformer
> training including text language models, shown below 1M parameters only on a synthetic task, and on text stopping
> to improve after 3,000–4,000 steps at 31.6M parameters [2]; integer-only training of a tiny character GPT in 64-bit
> fixed point [3]. snai-int8 differs in that it trains text language models below 1M parameters with Adam and
> 8-bit moments; a 0.37M model matches a paired float32 PyTorch baseline in the default path and ends at most
> 1.3 % above it with the integer switch (pre-set threshold 5 %). We claim no priority for integer training as such.

[1] H. H. Y. Shalby, F. Pittorino, M. Roveri: *Memory-Efficient Integer-Only Training of Deep Neural Networks.*
arXiv:2610.16298, 2026. https://arxiv.org/abs/2610.16298

[2] C. L. P. de Almeida: *Jataí: treino de redes neurais só com inteiros (INT8) e só com bits, numa GPU sem tensor
cores.* 2026. https://github.com/kdilim/jatai

[3] N. Mićić: *int-llm: Integer-only LLM stack in pure C.* 2026. https://github.com/nmicic/int-llm

## Arbeitsweise der Messungen

- Das Kriterium für „besser/schlechter“ steht **vor** dem ersten gezählten Lauf fest. Wo es nachgetragen wurde, sagt
  die Reihe das ausdrücklich.
- Unter 10 % Unterschied ist Gleichstand. Für einzelne Tempo-Reihen gilt 5 %, das steht dann in der Reihe.
- Jede neue Sonde wird einmal absichtlich rot gesehen (Fehler herbeiführen, Ausschlag prüfen).
- Befund und Deutung stehen getrennt. Eine Deutung ist als „nicht gemessen“ markiert.

## Inhalt

| Teil | Dateien |
|---|---|
| Engine | `cortex.nim` (CPU, int8-Training), `cortex_gz.nim` (voll ganzzahliger Weg), `cortex_opencl.nim`, `cortex_cuda.cu` + `cortex_cuda_bridge.nim`, `snai_tensor_utils.nim` |
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
