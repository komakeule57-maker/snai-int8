# snai/npu-matmul

```text
snai/npu-matmul - ausgewertet, angelegt 2026-10-27, zuletzt 2026-10-27 09:59
Frage: Rechnet die AX630C-NPU (M5 LLM Stack, Pulsar2 7.0-lite, AX620E) eine Matrixmultiplikation zweier Laufzeit-Eingaben mit ganzen Zahlen in [-127,127] exakt wie die int32-Referenz, und wie lange braucht ein Aufruf? Vorbedingung, um Matmuls des int8-Trainings auszulagern.
Kriterium (festgelegt 2026-10-27 08:35, vor dem ersten Messwert):
  E (tragend): je Form F1 [256,128]x[128,512], F2 [128,256]x[256,512], F3 [256,512]x[512,2048] 6 Testpaare (5 gleichverteilt, 1 Randpaar +-127), nicht aus der Kalibrierung; bitgleich zur numpy-int64-Referenz in 6/6 je Form. Arm Q8 (Voreinstellung, MinMax), Arm QF (Ausgabe ohne Requantisierung) nur falls Q8 nicht exakt und baubar. Urteil: erfuellt = ein Arm 18/18; teilweise = einzelne Formen; verfehlt = keine Form exakt. Reichweite: nur diese Toolchain und Einstellungen. T nur berichtet: ax_run_model avg/min/max (100 Wdh., 10 Aufwaermen), Netzdurchsatz Host->Geraet; Hochrechnung nur als Deutung. Rot-Probe des Vergleichers vor dem Lesen. Fehlerkanal: Build-Log, rc, Ausgabegroesse. Pruefer vorab, Einwaende in der Kriteriendatei.
Plan: rechner-a:~/snai_pruef/npu/kriterien.txt (md5 8192c056)
Rezepte:
  r443 [2026-10-27] rechner-a ~/snai_pruef/npu: docker run --rm -v $PWD:/data pulsar2:7.0-lite python3 /data/gen.py; je Form: pulsar2 build --target_hardware AX620E --input /data/<F>/mm.onnx --output_dir /data/<F>/q8 --config /data/<F>/q8.json (Arm QF: qf_S32.json/qf_FP32.json mit layer_configs op_types MatMul data_type S32/FP32). Geraet m5stack (<lan-ip>): LD_LIBRARY_PATH=/opt/lib /opt/bin/ax_run_model -m <F>/q8/compiled.axmodel -i <F>/ein -o <F>/aus -l <F>/liste.txt; Tempo: ax_run_model -m ... -w 10 -r 100. Vergleich: python3 vergleich.py <F> <F>/aus.
      quelltext: gen.py c1f71528, vergleich.py 201e24fa, kriterien.txt 8192c056
      parameter: Formen F1 [256,128]x[128,512], F2 [128,256]x[256,512], F3 [256,512]x[512,2048]; calibration_method MinMax, 5 Kalibrierpaare; Pulsar2 7.0-lite; Laufzeit Ax_Version V2.0.0_P7_20240513
      seed: 20261027
      rechner: rechner-a (Bau, Vergleich), m5stack AX630C (Lauf)
      logs: rechner-a:~/snai_pruef/npu/<F>/{build_*.log,lauf*.log,aus*}; m5stack:/root/npu_probe
      notiz: Auf dem Geraet lief axllm (Qwen, 1855 MB CMM) ruhend mit, CPU 97 % frei. ax_run_model meldet --inputs-is-folder/--outputs-is-folder/--use-tensor-name als abgeschafft, liest aber trotzdem ordnergerecht (Tausch-Mutant zeigt richtige Zuordnung).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/npu vergleich.py-Ausgaben, ax_run_model-Benchmark, quant_axmodel.json
  m6043 Vergleicher Rot-Probe (Referenz gegen sich / verstellt / Tausch) | 6/6, 0/6, 0/6 | Kontrolle | 20261027 | 6
  m6044 E exakte Paare F1 | 0/6 | Q8 | 20261027 | 6
  m6045 E exakte Paare F2 | 0/6 | Q8 | 20261027 | 6
  m6046 max abs Abweichung F1 Zufallspaare | 4684-4915 (rel 1,7 %) | Q8 | 20261027 | 5
  m6047 max abs Abweichung F2 Zufallspaare | 6027-6784 (rel 1,7 %) | Q8 | 20261027 | 5
  m6048 Ausgabe-Quantisierung laut quant_axmodel.json | Y 8 Bit asymmetrisch 0..255, A/B 8 Bit symmetrisch | Q8 | 20261027 | 1
  m6049 E exakte Paare F1 | 0/6 | QF-S32 | 20261027 | 6
  m6050 max abs Abweichung F1 | 6,1-7,7 Zufall, 16,2 Randpaar (rel 2e-5) | QF-S32 | 20261027 | 6
  m6051 Quantisierung S32 | A/B 16 Bit, Y 32 Bit | QF-S32 | 20261027 | 1
  m6052 Lauffaehigkeit | Bau rc 0, Laden auf dem Geraet scheitert (Create handle failed) | QF-FP32 | 20261027 | 1
  m6053 T Zeit je Aufruf F1 (avg, 100 Wdh.) | 0,383 ms | Q8 | 20261027 | 100
  m6054 T Zeit je Aufruf F2 (avg, 100 Wdh.) | 0,298 ms | Q8 | 20261027 | 100
  m6055 T Zeit je Aufruf F1 (avg, 100 Wdh.) | 1,064 ms | QF-S32 | 20261027 | 100
  m6056 Netzdurchsatz rechner-a -> Geraet ueber ssh | 1,68 / 2,05 / 2,00 MB/s | Netz | 20261027 | 3
  m6057 Netzdurchsatz rechner-a -> Geraet roh TCP | 2,19 MB/s | Netz | 20261027 | 1
  Quelle: rechner-a:~/snai_pruef/npu/F3 vergleich.py, ax_run_model-Benchmark
  m6070 E exakte Paare F3 | 0/6 | Q8 | 20261027 | 6
  m6071 max abs Abweichung F3 Zufallspaare | 10278-10708 (rel 1,7 %) | Q8 | 20261027 | 5
  m6072 T Zeit je Aufruf F3 (avg, 100 Wdh.) | 4,406 ms | Q8 | 20261027 | 100
  m6073 Fehlerkanal F3 | Bau-Wartehuelle nach 30 min beendet, Log ab Linker-Phase abgeschnitten, compiled.axmodel 719404 B vorhanden, Lauf rc 0 | Q8 | 20261027 | 1
Ergebnis e387 [2026-10-27 09:59]: verfehlt
  Fazit: Die AX630C-NPU liefert mit Pulsar2 7.0-lite keine exakten Matmul-Summen (Q8: 8-Bit-Ausgang, ~1,7 % Fehler; S32: Rest 2e-5, Ursache offen; FP32 laedt nicht). Fuer SnAIs int8-Training ist sie damit kein Rechenweg. Weitersuchen lohnt nicht: auch exakt waere die Obergrenze beim Knirps ~1,3-1,4x (Matmuls 20-30 % der Schrittzeit) und das Netz (2 MB/s ueber rechner-as WLAN) teurer als die Rechnung. Der Nutzen des Geraets liegt bei den ARM-Kernen (snai/arm-knirps).
  Offen: Ursache der Restabweichung im S32-Arm; andere Pulsar2-Fassungen oder Einstellungen nicht geprueft.
  Datei: rechner-a:~/snai_pruef/npu/ERGEBNIS_npu.md
Chronik:
  2026-10-27 08:35 angelegt
  2026-10-27 08:58 Rezept r443
  2026-10-27 08:58 Status geplant -> laeuft (Rezept r443)
  2026-10-27 08:58 Messwerte m6043-m6057
  2026-10-27 09:59 Messwerte m6070-m6073
  2026-10-27 09:59 Ergebnis e387: verfehlt
  2026-10-27 09:59 Status laeuft -> ausgewertet (Ergebnis e387)
```
