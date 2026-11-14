# snai/kopier-torch-v4

```text
snai/kopier-torch-v4 - ausgewertet, angelegt 2026-10-22, zuletzt 2026-10-23 05:17
Frage: Lernt ein geeichter PyTorch-Nachbau (gleiche Funktion, gleiche Fenster und Reihenfolge, gleiche Genesis, Rezept der Engine in fp32) das Kopieren über Abstand d, wo die Engine (int8 voll, Versuch 4) 0/6 lernte? Ja = SnAI-int8 unterlegen; nein = Aufgabe/Rezept zu schwer.
Kriterium (festgelegt 2026-10-22 23:27, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/torchprobe/kriterien_v4t.txt (md5 24d4bc10, mit Prüfer). Gelernt je Lauf: r(96) >= 0,5 am Budget-Ende (Segment 11), mess_reich.php 120 Fenster Saat 20261020 Held-out-Hintergrund. ENGINE UNTERLEGEN: T gelernt >= 4/6 (je Arm >= 2/3). KEIN ENGINE-UNTERSCHIED: T 0/6 und r(96) <= 0,01 in 6/6. Sonst teilweise/saatabhängig. Beschreibend: Trainings-Loss letztes Segment T gegen E (|d| < 0,05 nats gleich), Messpfad-Kreuzmessung (E dequantisiert fp32, T quantisiert int8).
Plan: rechner-b:~/snai_pruef/torchprobe/kriterien_v4t.txt
Baut auf: snai/reichweite-v4, snai/reichweite-v3
Rezepte:
  r380 [2026-10-22] cd ~/snai_pruef/torchprobe && nohup bash -c './los_v4t.sh gleich; ./los_v4t.sh profil'  (Neustart 23:47:21; je Saat nice -n 10 venv/bin/python train_torch.py <arm> <S> 12 lauf/<arm>_s<S>)
      quelltext: train_torch.py 10a4cc83 (abspath, Sonde Seg 0-10 mit 40 Fenstern, Seg 11 mit 120), snai_torch.py 27f48a6f, export_fenster.php b7d11977; Kriterien 86e407f8 (mit Nachtrag vor dem Neustart)
      parameter: wie r379
      rechner: rechner-b (3 Kerne, nice 10)
      logs: rechner-b:~/snai_pruef/torchprobe/lauf/<arm>_s<S>/; verworfener Erststart verworfen/lauf_relpfad_*
      notiz: Erststart 23:27 verworfen: Messung scheiterte (relativer Pfad), Training sauber.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b ~/snai_pruef/torchprobe/lauf/gleich_s*/train.log; Engine ~/snai_pruef/reichweite/v4/log/gleich_s*_seg11.train.log
  m4537 r(96) Rang-0 Kopie-Token Segment 11 (120 Fenster, fp32-Pfad) | 0.001 | T gleich | 1 | 120
  m4538 r(96) Rang-0 Kopie-Token Segment 11 (120 Fenster, fp32-Pfad) | 0.001 | T gleich | 2 | 120
  m4539 r(96) Rang-0 Kopie-Token Segment 11 (120 Fenster, fp32-Pfad) | 0.001 | T gleich | 3 | 120
  m4540 Avg Train-Loss Segment 11 | 4.1817 | T gleich | 1 | 2001
  m4541 Avg Train-Loss Segment 11 | 4.1678 | T gleich | 2 | 2001
  m4542 Avg Train-Loss Segment 11 | 4.1734 | T gleich | 3 | 2001
  m4543 Avg Train-Loss Segment 11 (Engine, Globaler Avg Loss) | 4.18132 | E gleich | 1 | 2001
  m4544 Avg Train-Loss Segment 11 (Engine, Globaler Avg Loss) | 4.15769 | E gleich | 2 | 2001
  m4545 Avg Train-Loss Segment 11 (Engine, Globaler Avg Loss) | 4.1666 | E gleich | 3 | 2001
  m4546 Clip-Anteil Segment 11 (Schritte mit geklippter Norm) | 100 | T gleich | 1-3 | 2001
  Quelle: rechner-b ~/snai_pruef/torchprobe/lauf/profil_s*/train.log; ~/snai_pruef/reichweite/v4/log/profil_s*_seg11.train.log
  m4562 r(96) Rang-0 Kopie-Token Segment 11 (120 Fenster, fp32-Pfad) | 0.001 | T profil | 1 | 120
  m4563 r(96) Rang-0 Kopie-Token Segment 11 (120 Fenster, fp32-Pfad) | 0.001 | T profil | 2 | 120
  m4564 r(96) Rang-0 Kopie-Token Segment 11 (120 Fenster, fp32-Pfad) | 0.001 | T profil | 3 | 120
  m4565 Avg Train-Loss Segment 11 | 4.1877 | T profil | 1 | 2001
  m4566 Avg Train-Loss Segment 11 | 4.1688 | T profil | 2 | 2001
  m4567 Avg Train-Loss Segment 11 | 4.1716 | T profil | 3 | 2001
  m4568 Avg Train-Loss Segment 11 (Engine, Globaler Avg Loss) | 4.16805 | E profil | 1 | 2001
  m4569 Avg Train-Loss Segment 11 (Engine, Globaler Avg Loss) | 4.16018 | E profil | 2 | 2001
  m4570 Avg Train-Loss Segment 11 (Engine, Globaler Avg Loss) | 4.16442 | E profil | 3 | 2001
  Quelle: rechner-b ~/snai_pruef/torchprobe/kreuz_los.log und kreuz/{E,T}_{gleich,profil}_s{1,2,3}.json (mess_reich.php 120 Fenster Saat 20261020 Held-out), 2026-10-23 05:14; err: E nur "m/v leer -> Cold Start" (Datei ohne Adam-Zustand), T leer; rc 0 12/12
  m4581 r(96) Kreuz: E seg11 dequantisiert V5, fp32-Pfad (120 Fenster) | 0.0006 | E gleich | 1 | 120
  m4582 r(96) Kreuz: E seg11 dequantisiert V5, fp32-Pfad (120 Fenster) | 0.0006 | E gleich | 2 | 120
  m4583 r(96) Kreuz: E seg11 dequantisiert V5, fp32-Pfad (120 Fenster) | 0.0004 | E gleich | 3 | 120
  m4584 r(96) Kreuz: E seg11 dequantisiert V5, fp32-Pfad (120 Fenster) | 0.0006 | E profil | 1 | 120
  m4585 r(96) Kreuz: E seg11 dequantisiert V5, fp32-Pfad (120 Fenster) | 0.0006 | E profil | 2 | 120
  m4586 r(96) Kreuz: E seg11 dequantisiert V5, fp32-Pfad (120 Fenster) | 0.0006 | E profil | 3 | 120
  m4587 r(96) Kreuz: T seg11 nach int8 (V6), int8-Pfad (120 Fenster) | 0.0006 | T gleich | 1 | 120
  m4588 r(96) Kreuz: T seg11 nach int8 (V6), int8-Pfad (120 Fenster) | 0.0006 | T gleich | 2 | 120
  m4589 r(96) Kreuz: T seg11 nach int8 (V6), int8-Pfad (120 Fenster) | 0.0006 | T gleich | 3 | 120
  m4590 r(96) Kreuz: T seg11 nach int8 (V6), int8-Pfad (120 Fenster) | 0.0006 | T profil | 1 | 120
  m4591 r(96) Kreuz: T seg11 nach int8 (V6), int8-Pfad (120 Fenster) | 0.0006 | T profil | 2 | 120
  m4592 r(96) Kreuz: T seg11 nach int8 (V6), int8-Pfad (120 Fenster) | 0.0006 | T profil | 3 | 120
  m4593 Kopie-Token-Loss d96 Kreuz, Spanne über 12 Messungen (nats) | 8.413..8.460 | E und T | 1-3 | 12
  m4594 r(d) Kreuz für d 32/96/200/320/560/796 je Messung gleich (keine Abstandsabhängigkeit) | 12/12 | E und T | 1-3 | 12
Ergebnis e329 [2026-10-23 05:17]: gleichstand
  Fazit: KEIN ENGINE-UNTERSCHIED IM KOPIEREN: PyTorch fp32 lernt mit demselben Rezept ebenfalls 0/6, r(96) ≤ 0,001 in 6/6. Kreuzmessung: E im fp32-Pfad und T im int8-Pfad liegen bei 0,0004–0,0006, der Messpfad ändert nichts. Train-Loss T gegen E |d| ≤ 0,02 nats in 6/6. SnAI ist hier gleichwertig mit PyTorch. Die niedrige Kopierrate ist eine Frage von Rezept, Budget oder Aufgabe, nicht von Engine oder int8. Nächster Schritt laut Vorab-Regel: Rezeptsuche in PyTorch (LR zuerst, weil 100 % der Schritte geklippt werden; dann Batch, Kontextleiter, Kopierdichte), danach das Rezept in der Engine mit 3 Saaten.
  Offen: Die Sonde hat in v4/T nie angeschlagen (Rot-Probe erst ab r(96) ≥ 0,5). Ob sie schwaches Kopieren trennt, zeigt erst ein kopierender Lauf. Reichweite nur Knirps 128/2/2, ctx 1024, LR 0,0001, 24.000 Fenster.
  Datei: rechner-b:~/snai_pruef/torchprobe/ERGEBNIS_v4t.md
Abgeloest und ausgeblendet: 1 rezept - voll=True zeigt sie.
Chronik (juengste 8 von 9, voll=True zeigt alle):
  2026-10-22 23:27 Rezept r379
  2026-10-22 23:27 Status geplant -> laeuft (Rezept r379)
  2026-10-22 23:47 Rezept r380, loest r379 ab
  2026-10-23 02:10 Messwerte m4537-m4546
  2026-10-23 04:28 Messwerte m4562-m4570
  2026-10-23 05:16 Messwerte m4581-m4594
  2026-10-23 05:17 Ergebnis e329: gleichstand
  2026-10-23 05:17 Status laeuft -> ausgewertet (Ergebnis e329)
```
