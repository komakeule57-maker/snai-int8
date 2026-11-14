# snai-int8

**Kleine Sprachmodelle vollständig in Ganzzahlen trainieren: int8-Gewichte, int8-Rückwärtsrechnung, 8-Bit-Adam-Momente.**
Eine eigene Engine in Nim (CPU mit OpenMP, CUDA, OpenCL) mit schlanker PHP-Steuerung, dazu die Forschungsakte: jede
Messreihe mit vorher festgelegtem Kriterium, Rezept, Messwerten und Urteil.

> *English summary:* snai-int8 is a research engine for training small transformer language models almost entirely in
> integer arithmetic (int8 weights and activations, integer backward pass and gradient accumulation, 8-bit Adam moments).
> The engine is written in Nim with CPU (OpenMP), CUDA and OpenCL backends that are bit-identical to the CPU reference.
> The repository also contains the research log (413 measurement series, each with a pre-registered criterion, recipe,
> raw values and verdict). Documentation is in German.

Stand: **Forschungsprototyp, 2026-11-13.** Das ist der Anfang der Arbeit, kein fertiges Produkt. Die konservative
fp32-Fassung zum Ausprobieren ist die Distro [komakeule57-maker/SnAI](https://github.com/komakeule57-maker/SnAI).

## Was bisher belegt ist

Die Zahlen stammen aus den verlinkten Messreihen. Jede nennt dort ihre Reichweite (Modellgröße, Saaten, Datensatz)
und was sie ausdrücklich *nicht* beantwortet.

- **Der vollständige Ganzzahl-Stack trainiert stabil.** Kleines Modell (dim 128, 2 Schichten): Der Abstand zu FP32
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
