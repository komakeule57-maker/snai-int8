# snai/arm-knirps

```text
snai/arm-knirps - ausgewertet, angelegt 2026-10-27, zuletzt 2026-10-27 10:21
Frage: Taugt der M5 LLM Stack (2x Cortex-A53, ~700 MB frei) als zusaetzlicher CPU-Rechner fuer Knirps-Laeufe: fehlerfrei, deterministisch, bitgleich zu x86, Tempo?
Kriterium (festgelegt 2026-10-27 09:06, vor dem ersten Messwert):
  Knirps 128/ctx64/L4/FFN512 Saat 1, 160 KB Nano-Geschichten, Training wie lauf_geschichten.sh (INT8_FULL, gebunden, OMP 2, Revival aus), eine Quelle (ARM-Port nur FTZ-Block). Laeufe X1, X2 rechner-a, A1, A2 Geraet. L: A1/A2 rc 0, Checkpoint, Loss endlich, kein Fatal/NaN/NET2NET/VETO. D: md5(A1)==md5(A2); Kontrolle md5(X1)==md5(X2), sonst ungueltig. P: md5(A1)==md5(X1); bei nein P': ARM mit -ffp-contract=off (A3) gegen X1. T nur berichtet (s/Schritt, RAM). Urteil erfuellt = L und D; P/P' entscheiden ueber gemischte Reihen. Rot-Probe md5-Vergleich mit verstelltem Byte. Pruefer vorab, Einwaende in der Kriteriendatei.
Plan: rechner-a:~/snai_pruef/arm/kriterien.txt (md5 8d6a942d)
Rezepte:
  r445 [2026-10-27] Je Lauf: ./lauf_arm.sh <Etikett> (Laufname immer K). Darin: SNAI_VOCAB=$PWD/vokabular.json OMP_NUM_THREADS=2 LD_LIBRARY_PATH=$PWD SNAI_FORCE_CPU=1 SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 php train_cluster.php factory/input/kurz.txt factory/checkpoints/K.snai 1 1 factory/checkpoints/gen.snai 3 0.001 0.0001 1 0.1
      quelltext: Projektbaum snai_edge_int8_lora Commit 48b983f (*.php, *.json, Revival enabled=false); cortex.nim ce66d294 = Projekt-cortex.nim 18d6a7df mit ARM-Port am FTZ-Block (FPCR Bit 24), rechner-a:~/snai_pruef/arm/quelle. Bibliotheken: x86 9a785ae4 (rechner-a, Nim-Flags -O3 -fopenmp -fno-math-errno, kein -march), ARM 21a5c031 (Geraet gcc 11.4, nim --cpu:arm64 --compileOnly --genScript), ARM ohne FMA 047a5864 (dieselben Zeilen + -ffp-contract=off). lauf_arm.sh 730b7878.
      parameter: Genesis php init_base.php gen.snai 0 128 64 4 512 1 (330ba964, auf x86 erzeugt, auf beide kopiert), Eingabe kurz.txt 70a54771 (erste 160000 Byte geschichten_seg0), vokabular.json a998fd85, 790 Schritte, OMP 2. PHP 8.5 (rechner-a) / 8.1 + mbstring (Geraet).
      seed: Genesis-Saat 1; Fensterreihenfolge ueber Laufname K
      rechner: rechner-a (X1, X2), M5 LLM Stack ssh-Alias m5stack (A1, A2, A3)
      logs: rechner-a:~/snai_pruef/arm/proj_x86/ergebnis/; m5stack:/root/snai_arm/proj/ergebnis/ (A1, A2), /root/snai_arm/proj_nofma/ergebnis/ (A3)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/arm/proj_x86/lauf_X1.out, lauf_X2.out, ergebnis/
  m6058 Kontrolle md5 X1 / X2 (rechner-a, Name K) | 47339eb1 / 47339eb1 gleich | X | 1 | 2
  m6059 Rot-Probe md5-Vergleich (X1 mit einem verstellten Byte) | 8fd449b1, ungleich | Kontrolle | 1 | 1
  m6060 Laufzeit 790 Schritte rechner-a | 108,3 s / 122,8 s | X | 1 | 2
  m6061 RAM-Spitze rechner-a | 102444 / 102296 KB | X | 1 | 2
  m6062 Loss Ende (Globaler Avg) | 4,59525 | X | 1 | 2
  Quelle: m5stack:/root/snai_arm/proj/lauf_A1.out, lauf_A2.out, ergebnis/
  m6063 L rc / Fehlerzeilen A1, A2 | rc 0 / 0, rc 0 / 0 | A | 1 | 2
  m6064 D md5 A1 / A2 (Geraet, Name K) | 3c071233 / 3c071233 gleich | A | 1 | 2
  m6065 P md5 A1 gegen X1 | 3c071233 gegen 47339eb1, ungleich | A | 1 | 1
  m6066 Loss Ende (Globaler Avg) | 4,59614 | A | 1 | 2
  m6067 Laufzeit 790 Schritte Geraet | 1254,6 s / 1259,4 s | A | 1 | 2
  m6068 Faktor Laufzeit Geraet / rechner-a | 10,9 (1257 / 115,5 s) | A | 1 | 2
  m6069 RAM-Spitze Geraet | 75580 / 77472 KB | A | 1 | 2
  Quelle: m5stack:/root/snai_arm/proj_nofma/lauf_A3.out, ergebnis/A3.{snai,log}; Bibliothek bau_nofma/libcortex.so 047a5864 (-ffp-contract=off an jeder gcc -c-Zeile)
  m6102 L rc / Fehlerzeilen A3 | rc 0 / 0 | A3 | 1 | 1
  m6103 P' md5 A3 gegen X1 | 47339eb1 gegen 47339eb1, gleich | A3 | 1 | 1
  m6104 Loss Ende (Globaler Avg) | 4,59525 | A3 | 1 | 1
  m6105 Laufzeit 790 Schritte Geraet ohne FMA | 1268,5 s | A3 | 1 | 1
  m6106 RAM-Spitze Geraet ohne FMA | 77592 KB | A3 | 1 | 1
Ergebnis e389 [2026-10-27 10:21]: erfuellt
  Fazit: Das Geraet ist ein vollwertiger, langsamer Knirps-Rechner: fehlerfrei (L), deterministisch (D, A1=A2), und mit -ffp-contract=off bytegleich zu rechner-a (P' erfuellt, A3=X1=47339eb1; P ohne den Schalter nein, Ursache FMA-Zusammenfassung). Damit muessen Arme einer Reihe nicht alle aufs Geraet: eine Saat oder ein Kontrollarm kann ausgelagert werden, wenn beide Seiten dieselbe Quelle ohne -march nutzen; vor jeder gemischten Reihe ein md5-Stichlauf auf beiden Seiten, weil nur ein Pfad (INT8_FULL, 1 Saat, OMP 2) gemessen ist. Faktor ~11 gegen rechner-a, ~76 MB je Lauf: kurze Knirps-Nebenreihen, nicht prod512b.
  Offen: Bitgleichheit fuer LoRA, Beam-Inferenz, andere Thread-Zahlen und zu den Projektbibliotheken auf rechner-a/rechner-b (andere Bauten) ungemessen.
  Datei: rechner-a:~/snai_pruef/arm/ERGEBNIS_arm.md
Chronik (juengste 8 von 9, voll=True zeigt alle):
  2026-10-27 09:13 Status geplant -> laeuft (von Hand)
  2026-10-27 09:13 Aufbaufehler vor jedem gueltigen Messwert: X1/X2/A1 liefen unter verschiedenen Ausgabenamen; SnAI leitet die Fensterreihenfolge aus dem Namen ab, daher X1 != X2 (md5 e17702fd / 46ab09f1, Loss 4,5955 / 4,6128) - kein Determinismus-Befund. A1 nach ~2 min per PID abgebrochen. Behoben: lauf_arm.sh 730b7878 faehrt jeden Lauf unter dem Namen K und verschiebt Ergebnis nach ergebnis/<Etikett>; Kriterien unveraendert. Fehllaeufe in proj_x86/alt_falsch/. Nebenbefund Fehlerkanal: Geraet brauchte php8.1-mbstring (erster A1-Start Fatal mb_convert_encoding), nachinstalliert; PHP-Staende 8.5 (rechner-a) gegen 8.1 (Geraet) gehoeren zum gemessenen Stack.
  2026-10-27 09:18 Messwerte m6058-m6062
  2026-10-27 09:59 Messwerte m6063-m6069
  2026-10-27 10:20 Messwerte m6102-m6106
  2026-10-27 10:20 Rezept r445
  2026-10-27 10:21 Ergebnis e389: erfuellt
  2026-10-27 10:21 Status laeuft -> ausgewertet (Ergebnis e389)
```
