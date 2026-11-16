# Ergebnis Schlussprobe Full-int8 (`snai/fullint8-schluss`)

Stand 2026-11-16 ~00:50, rechner-a. Kriterien vorab: `KRITERIEN_SCHLUSS.txt` (md5 87e1d8bb, nach Zweitmeinung,
im Messbuch vor dem ersten Lauf, Rezept r732). Messwerte im Messbuch m11560–m11597.

**Aufbau.** Kopien `sch_*` = Stufe 10 + Telemetrie + Rot-Schalter (cortex_gz.nim fa4a951b, cortex.nim b9263995,
Lib 96f136e4; PHP patch_lr.py + patch_v8php.py d780540f), alle bytegleich bis auf den Ordner. Die Arme unterscheiden
sich nur in Umgebungsvariablen. Knirps 96×2 gebunden, Nano-Geschichten, REST=sr, INT8_FULL, Warmup 500, Cosinus
0,001 → 0,0001 bis 25.000, WD 0,1, 1 Worker, CPU, 2 Fäden je Lauf. Genesis s1–s3 wie `snai/geschichten-pytorch`
(gepaart: gleiche Startgewichte, gleiche Fensterfolge).

## R Rundungsprobe (ZIEL Punkt 1) – bestanden

| Lauf (GANZ=10, s1, Segment 0 = 5.001 Schritte) | Checkpoint |
|---|---|
| naechster / null / auf / ab | **6a544467 viermal** (SNAI_V8) |
| Rot h (Hauptfaden) naechster / auf | 5604c10f / b50d1ee2 |
| Rot o (OpenMP-Schleife) naechster / auf | f02a11e5 / f9147dd0 |
| Rot a (AVX) naechster / auf | 75184afd / c33bf9d6 |

Jeder Faden meldet den gesetzten Modus. Jede der drei eingebauten float-Rechnungen macht die Probe rot. Die
Rot-Läufe in naechster weichen auch vom grünen Lauf ab, die Rechnung wirkt also überhaupt.
Grenzen (vorab vermerkt): Die Probe sieht nur float-Rechnung, deren Ergebnis von der Rundung abhängt. Exakte
Operationen sieht sie nicht; das bitgenaue Zerlegen der float32-Konstanten ist eine solche. Nicht abgedeckt ist auch
das einmalige Quantisieren der float-Genesis beim Start (siehe L). SNAI_GZ_IO_RUNDUNG schreibt keine Protokollzeile;
seine Wirkung ist in `snai/fullint8-st10-ckpt` K3 gesehen.

## Q Qualität (ZIEL Punkt 2) – bestanden

Held-out (mess_text.php, 300 Fenster) nach Segment 4 = 25.005 Schritte, gegen PyTorch float32 (m625–m627):

| Saat | voll ganzzahlig | PyTorch | q |
|---|---|---|---|
| 1 | 2,2650 | 2,2357 | +1,31 % |
| 2 | 2,2529 | 2,2385 | +0,64 % |
| 3 | 2,2482 | 2,2326 | +0,70 % |

Schwelle +5 % in 3 von 3: bestanden. Rot der Messung (gemischte Fenster) 9,06 / 9,08 / 9,08.

## G Gesamtvergleich gegen heute (berichtet) – Gleichstand

GANZ=0 (alter Weg) 2,2536 / 2,2639 / 2,2536. d = +0,51 / −0,49 / −0,24 %, Mittel −0,07 %. Richtung uneinig
(eine Saat schlechter, zwei besser). Kontrolle: Der Arm „heute“ ist nach 25.000 Schritten bytegleich zu Arm B von
`snai/sr-knirps-nachweis` (53c19588 / e376eb28 / 8d399d88). Ausgeschaltet bleibt die Engine also über den ganzen
Lauf, nicht nur über Segment 0, beim alten Ergebnis.
Folge: Der vorher gemessene Preis von SR (+0,96 % gegen PyTorch) und der Preis des Ganzzahl-Wegs (+0,88 % im Mittel
gegen PyTorch) sind dieselbe Größenordnung. Der Ganzzahl-Weg kostet gegen heute nichts Messbares.

## E Einzelvergleiche lang – kein Haltepunkt

| Arm | Held-out s1 / s2 / s3 | d = (alle − ohne)/ohne | Mittel |
|---|---|---|---|
| ohne REST (Stufe 8 aus) | 2,2603 / 2,2602 / 2,2556 | +0,21 / −0,32 / −0,33 % | −0,15 % |
| ohne ADAM (Stufe 3 aus, damit auch 9) | 2,2578 / 2,2563 / 2,2562 | +0,32 / −0,15 / −0,35 % | −0,06 % |

Grenze +2 % in 3 von 3 nicht erreicht, Gleichstand. Die Stufen 2, 4–7, 9 und 10 haben ihren Einzelvergleich in
ihrer eigenen Reihe (je ein bzw. zwei Segmente, float64-Bezug, Rot-Probe): e677, e682, e683, e684, e685, e687, e688.

## K Messgerät – ohne Befund

60 Segmentläufe (4 Arme × 3 Saaten × 5) und 10 R-Läufe: rc 0, STEPS_DONE 5001, NET2NET-GUARD 0, Fatal/NaN/VETO 0.
Sättigungen 0 in allen lesbaren Berichten; leere Felder sind verschluckte „0“ (interne Notiz), einmal am deterministischen
Zwillingslauf bestätigt. LR-Wache höchstens 137 · 2⁻³⁰ (Wache bei 2¹³). Telemetrie 5 Berichte je Segment.
Magic wie erwartet (GZ-Arme SNAI_V8, heute SNAI_V7). Die Stufenliste je Arm stammt aus der Engine selbst.
sch_alle Segment 0/1 ist bytegleich zur Stufe-10-Reihe ohne Telemetrie: Die Telemetrie ändert nichts.

## T Telemetrie (berichtet)

Über 25.000 Schritte, alle drei Saaten:
- Nullgradienten: höchstens 0,03 % je Matrix, ohne Anstieg.
- Geänderte int8-Codes je Schritt: von 7–26 % (t=1000) auf 0,6–2,7 % (t=25.000).
- Restpfad: log2-Maximum 2–4, stabil.

Deutung, nicht gemessen: Der Rückgang der Codeänderungen folgt dem Cosinus der Lernrate (Faktor 10), kein Erliegen.
Ein Ausfall wie bei Jataí nach 3.000–4.000 Schritten (de Almeida 2026, github.com/kdilim/jatai) zeigt sich nicht.

**Preis:** Auf der CPU braucht der Ganzzahl-Weg je Segment rund 1.000 s statt 270 s, ist also etwa 3,7× langsamer
(3 Läufe parallel, unter Last; kein Kriterium).

## L README-Liste „Noch in float“ (ZIEL Punkt 3) – offen, Entscheidung beim Autor

Liste aus der README von snai-int8 v0.0.2. Stand mit SNAI_I8_GANZ=10:

| Posten (README) | Stand | Beleg |
|---|---|---|
| Gradientenpuffer float32 je Gewicht | int32-Mantisse je Gewicht, Exponent je Zeile | Stufe 2, e677 |
| Adam-Schritt je Gewicht | ganzzahlig über die 8-Bit-Log-Momente, samt Bias-Korrektur, Wurzel, Division, WD, SR | Stufe 3, e679 (Lesart B) |
| Softmax der Attention | 2⁻ˣ-Tabelle, Q30 | Stufe 6, e684 |
| Logits / Cross-Entropy | ganzzahlig, Verlust nur Protokoll | Stufe 7, e685 |
| RMSNorm | int64-Quadratsumme, 1/√ ganzzahlig | Stufe 4, e682 |
| RoPE | int-Tabelle | Stufe 5, e683 |
| Aktivierungen im Restpfad | int32-Mantisse mit Exponent je Position; SiLU, Embedding | Stufe 1 e676, Stufe 8 e686 |
| Gains samt Momenten | **gerechnet ganzzahlig, abgelegt als float32-Bitmuster** | Stufe 3/4; Frage 1 |
| Checkpoint-Momente als float32 | 8-Bit-Code + Zeilenskala (SNAI_V8) | Stufe 10, e688 |
| Skalar Lernrate | Plan in Festkomma | Stufe 9, e687 (Ausnahme b) |
| Skalare β-Potenzen, Clip-Norm | je Schritt ganzzahlig (Q30-Potenz, int-Wurzel) | Stufe 3, e679 |

Alle Posten zusammen: R zeigt, dass im Trainingsschritt nichts Rundungsabhängiges übrig ist.

**Nicht in der Liste, aber zu nennen:**
- Erlaubt (Ausnahmen): Tabellen beim ersten Gebrauch, fest im Modus naechster gebaut; Verlust und Gradientennorm als
  Protokoll, bitweise gebaut; der float-Wert der Lernrate in PHP, nur Wache und Protokoll; die float32-Konstanten
  β1, β2, ε, WD und lr0, je Schritt exakt zerlegt, ohne Rundung.
- Die Skalen je Zeile (Gewichte und Momente) werden ganzzahlig gebildet und als float32-Bitmuster abgelegt. Laut
  Autor sind Skalen ausgenommen. Der Satz „int8-Gewichte (mit float-Skala je Zeile)“ in der Liste
  „Ganzzahlig“ trifft das nicht mehr ganz.

**Fragen an den Autor:**
1. **float32 als Speicherformat:** Gains (480 von 0,37 Mio. Parametern), ihre Momente und alle Skalen werden
   ganzzahlig berechnet und nur als float32-Bitmuster gespeichert, ohne float-Rechnung. Gilt das als ganzzahlig?
   Dann ein Satz in der README dazu. Oder bleibt es ein Posten der Liste?
2. **Mehrere Worker:** Mit V7 mittelt der Merge in float; mit V8 bricht er ab. Der Schalter trainiert also nur mit
   einem Worker voll ganzzahlig. Als Grenze in die README, oder ein ganzzahliger Merge als weitere Stufe?
3. **Start aus einer float-Genesis:** Seg 0 quantisiert die SNAI_V5-Startdatei einmal (cortex_quantize_from_fp32).
   Initialisierung (wie ein vorab berechneter Plan) oder Posten?
4. **Ungenutzter float32-Gradientenpuffer:** Die alten g_*-Puffer sind noch angelegt (4 B je Gewicht). Mit allen
   Stufen werden sie weder beschrieben noch gelesen, nur als Kleber, wenn eine Stufe aus ist. Keine Rechnung, aber
   Speicher: erwähnen, oder vor dem Release im Ganzzahl-Modus nicht mehr anlegen (eigener Schritt)?

## Fazit

Die Engine trainiert mit SNAI_I8_GANZ=10 auf der CPU voll ganzzahlig, und das kostet keine Qualität. Über ein ganzes
Segment ist das Ergebnis in allen vier Rundungsmodi bytegleich. Die Probe sieht eine eingebaute float-Rechnung an
jeder der drei geprüften Stellen. Nach 25.000 Schritten liegt der Held-out höchstens 1,3 % über PyTorch; gegen den
heutigen Weg ist es Gleichstand, ebenso für die einzeln abgeschalteten Stufen REST und ADAM. Damit sind die
Punkte 1 und 2 des Ziels erfüllt.

Punkt 3 ist inhaltlich so gut wie erfüllt: Jeder Posten der README-Liste ist ganzzahlig geworden und durch eine
Reihe belegt. Ob die Liste „leer“ ist, hängt aber an vier Einordnungsfragen, die die Definition nicht eindeutig
regelt. Die entscheidet der Autor; vorher darf „full int8“ nicht in die README.

Nicht beantwortet ist, ob das bei anderen Größen, längeren Läufen, mehreren Workern oder auf der Karte gilt.
Der Preis ist das Tempo: etwa 3,7× langsamer auf der CPU. Lohnt Weitermachen, dann zuerst der Kartenauftrag. Auf der
Karte läge auch die Antwort auf das Tempo.

## Nachtrag 16.11. ~00:45: Entscheidung des Autors zu L (interne Notiz)

1. float32 als Speicherformat für ganzzahlig gebildete Werte (Gains, ihre Momente, Skalen) zählt als ganzzahlig.
   Die README sagt das in einem Satz.
2. Mitteln mehrerer Worker: Ein ganzzahliger Merge wird als **Stufe 11** gebaut, bevor „full int8“ in die README kommt.
3. Das Quantisieren der float-Genesis beim Start ist Initialisierung und erlaubt; die README nennt es.
4. Die float32-Gradientenpuffer werden nur noch angelegt, wenn eine Stufe aus ist. Das ist ein eigener Schritt:
   bytegleich prüfen, Speicher messen.

L bleibt offen, bis 2. und 4. erfüllt sind.

## Nachtrag 16.11. ~06:55: L neu geurteilt, Ziel erreicht

Beide offenen Punkte sind erfüllt:

- Stufe 11, ganzzahliger Merge: `snai/fullint8-st11-merge`, e691 erfüllt, lokal committet 09643b4.
- Stufe 12, float-Gradientenpuffer nur bei Bedarf: `snai/fullint8-st12-gfrei`, e692 erfüllt, lokal committet 6539a6c.

Der fertige Schalter ist damit SNAI_I8_GANZ=12. Für ihn wurden R und Q in `snai/fullint8-schluss12` aus dem Stand des
Hauptbaums nachgemessen (`ERGEBNIS_SCHLUSS12.md`):

- Segment 0 ist in allen vier Modi 6a544467, mit 2 Workern 3f64d3c1, im Fortsetzungsweg 389a20ff.
- Rot h ist gesehen.
- Alle 15 Segment-Checkpoints der Qualitätsläufe sind bytegleich zu sch_alle, der Held-out also unverändert +1,31 /
  +0,64 / +0,70 % gegen PyTorch.

**README-Liste „Noch in float“ (v0.0.2) mit GANZ=12, je Posten:**

| Posten (README) | Stand | Beleg |
|---|---|---|
| Gradientenpuffer float32 je Gewicht, dauerhaft angelegt | int32-Mantisse mit Exponent je Zeile; der float32-Puffer wird nicht mehr angelegt | Stufe 2 e677, Stufe 12 e692 |
| Adam-Schritt je Gewicht | ganzzahlig (Bias-Korrektur, Wurzel, Division, WD, SR) | Stufe 3 e679 |
| Softmax der Attention, Logits/Cross-Entropy | 2⁻ˣ-Tabelle Q30; CE ganzzahlig, Verlust nur Protokoll | Stufe 6 e684, Stufe 7 e685 |
| RMSNorm, RoPE, Aktivierungen im Restpfad | ganzzahlig | Stufe 4 e682, 5 e683, 1 e676, 8 e686 |
| Gains samt Momenten | ganzzahlig gerechnet, als float32-Bitmuster abgelegt: zählt als ganzzahlig (Autor, Frage 1), ein Satz in der README | Stufe 3/4 |
| Checkpoint-Momente float32 | 8-Bit-Code + Zeilenskala (SNAI_V8) | Stufe 10 e688 |
| Skalare: Lernrate, β-Potenzen, Clip-Norm | Plan in Festkomma (Ausnahme), β-Potenzen Q30, Clip ganzzahlig | Stufe 9 e687, Stufe 3 e679 |
| (neu) Mitteln mehrerer Worker | ganzzahliger Merge | Stufe 11 e691 |

Ausnahmen, die die Liste nicht leeren muss:

- Tabellen beim ersten Gebrauch, fest im Modus „nächster“.
- Der Lernratenplan in Festkomma.
- Protokollausgaben (Verlust, Gradientennorm, float-LR in PHP nur als Wache und Protokoll).
- Das einmalige Quantisieren der float-Genesis beim Start als Initialisierung (Autor, Frage 3; die README nennt es).

Wie in e689 eingeordnet, nicht als eigene Frage entschieden: Die float32-Konstanten β1, β2, ε, WD und lr0 werden je
Schritt exakt zerlegt, ohne Rundung. Sie gelten als Eingabe, nicht als Rechnung. Die Rundungsprobe sieht sie nicht,
weil die Zerlegung exakt ist.

**L: erfüllt.** Jeder Posten ist gestrichen oder eine erlaubte Ausnahme, und jede Streichung ist durch eine Reihe
belegt. Die README selbst ist noch unverändert: Den Text bereitet die Veröffentlichung vor, Push und Release
nur mit dem Autor.

Hinweis für den README-Text (gelesen im Quelltext, kein Kriterium): Ab Stufe 3 gibt es keinen float32-Rundungsrest.
Der Schalter verlangt SNAI_I8_REST=sr oder 0 und bricht sonst ab.

**Gesamturteil der Reihe: R, Q und L erfüllt (L nach dem Kriterium dieser Reihe: Liste je Posten belegt), kein
Haltepunkt aus E, K ohne Befund.** Grenzen wie oben: CPU, Knirps 96×2, ein Korpus, rund 3,7× langsamer als der alte
Weg.

**Ziel (ZIEL.md) noch NICHT erreicht.** Punkt 3 verlangt, dass die Liste „Noch in float“ in der README tatsächlich leer
ist. Die README von snai-int8 (rechner-a:~/snai_pruef/veroeffentlichung/snai-int8-neu, HEAD 28824e0 = origin/main)
ist unverändert. Den Text schreibt nach Entscheidung des Autors die Veröffentlichung; ein Entwurf ist ihr am
16.11. ~07:05 zugegangen. Erreicht ist das Ziel erst mit der geänderten Liste; sichtbar wird sie erst mit einem Push,
und der geht nur über den Autor.

## Nachtrag 16.11. ~07:55: README-Liste mit v0.2.0 geändert

In der Release-Fassung v0.2.0 von snai-int8 gibt es die Liste „Noch in float“ nicht mehr. Geprüft habe ich den
Arbeitsbaum vor dem Commit, am 16.11. um 07:51: README.md da9ea3ed, BAUEN.md 5c68db6c, CITATION.cff 772d669b.

An ihre Stelle tritt der Abschnitt „Schalter: ganz ganzzahliges Training (SNAI_I8_GANZ=12)“ mit folgendem Inhalt:

- eine Tabelle je Teil des Trainings;
- die Ausnahmen, wie oben und mit den Entscheidungen des Autors vom 16.11.: Startgewichte als Initialisierung,
  float32-Bitmuster als Speicherformat, Hyperparameter als Eingabe mit Halbsatz, Tabellen beim ersten Gebrauch,
  Protokoll;
- die Voraussetzungen (INT8_FULL, gebundene Embeddings, REST=sr oder 0, ohne LoRA, Dropout, Wachstum und FFN-Skip,
  nur CPU, sonst Abbruch);
- die Rundungsprobe mit ihrer Reichweite (Fortsetzen nur im Kurzlauf);
- die Grenzen.

Die Rahmung bleibt „int8-Training“, wie der Autor gewählt hat. Die Befunde aus meiner Durchsicht sind eingearbeitet,
darunter die zuvor falsche Aussage zur Karte.

Damit ist Punkt 3 des Ziels in der Release-Fassung erfüllt. Öffentlich gilt das mit der Veröffentlichung von v0.2.0;
Commit, Push und Release gibt der Autor frei. Wird v0.2.0 nicht so veröffentlicht, gilt der Abschnitt davor.
