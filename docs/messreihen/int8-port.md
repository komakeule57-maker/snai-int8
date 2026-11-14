# snai/int8-port

```text
snai/int8-port - ausgewertet, begonnen 2026-08-24, angelegt 2026-10-21, zuletzt 2026-10-21 19:38
Frage: Bleibt der Held-out-Abstand des vollständigen Ganzzahl-Stacks (int8-Backward d_in und Gradienten-Akkumulation, 8-Bit-Adam-Momente, Bitmaske, int8-FFN-Aktivierungen, SiLU-Tabelle) zu FP32 über die Trainingsdauer ohne Wachstum? Drohnen-Stufe (vocab 8192, dim 128, ffn 512, ctx 512, 2 Schichten, 1 Kopf), Korpus corpus_long, Held-out ho_long; die Höhe des Abstands wird mitberichtet.
Kriterium (nachgetragen, Beleg: Nachtrag 2026-10-21. Zeitlinie, belegt nur durch die datierten, chronologisch angeordneten Abschnitte der Planung des Full-INT8-Ports (keine Versionsgeschichte): (1) Schritt 1 scheitert am 2026-08-24 (+0,665, wachsend); das Kriterium 'kein Wachstum des Abstands' ist ab Schritt 1a (2026-08-24, Z. 286f) in Gebrauch, also NACH dem Fehlschlag von Schritt 1 entstanden. (2) Die 2000-Schritt-Läufe des fertigen Stacks (Schritt 5a und die Saaten-Absicherung, 2026-08-24) liefen danach; in 'Konsolidierung: dritter Seed' (2026-08-24, Z. 1240f) wird das Kriterium als das entscheidende festgeschrieben. (3) Die Läufe, deren Zahlen hier stehen, begannen später: Produktivlauf 2026-08-25 (Z. 1884: 'Kriterium verletzt, das die Konsolidierung als das entscheidende benannt hatte'), Langlauf lang 2026-08-25 16:19, langb 2026-08-25 22:03 (Abschnitt 'Was die Wiederholung beantworten kann' steht vor dem Ergebnis). Damit stand das Kriterium vor den Läufen des fertigen Stacks und erst recht vor den Langläufen. Für Schritt 1 selbst lag es nicht vor.):
  Der Abstand INT8 minus FP32 im Held-out darf über die Trainingsdauer nicht wachsen ("Genau das letzte Kriterium ist das entscheidende: daran ist die erste Fassung von Schritt 1 gescheitert (+0,665 und monoton steigend)"). Ein einzelner Endwert gilt ausdrücklich nicht als Kennzahl.
Plan: Planung des Full-INT8-Ports
Darauf baut: snai/multistack-rest-16
Rezepte:
  r232 [2026-10-21] isolierter Pfad, 2000 Schritte, Seeds A/B/C: /tmp/fullint8_step1_trace.sh und Folgeskripte (nicht mehr vorhanden)
      quelltext: nicht rekonstruierbar (libcortex-Stände vom 2026-08-24 nicht einzeln gesichert)
      parameter: 1 Arbeiter, kein Merge, 2000 Schritte, 8 Messpunkte, Adam-Momente in diesen Läufen simuliert
      seed: Genesis A /tmp/fullint8_genesis.snai, B /tmp/fullint8_genesis_B.snai, C /tmp/fullint8_genesis_C.snai
      rechner: rechner-a
      logs: rechner-a:/tmp/fullint8_step1_trace.log u. a. (gelöscht)
  r233 [2026-10-21] Langlauf Seed A (lang) und B (langb): bash run_int8_lang.sh  bzw.  bash run_int8_lang.sh factory/checkpoints/fullint8_genesis_b.snai langb  (je Segment parallel: SNAI_INT8_FULL=1 OMP_NUM_THREADS=3 php train_cluster.php <seg> <o_i8> 2 1 <b_i8> 3 0.001 …; OMP_NUM_THREADS=3 php train_cluster.php <seg> <o_fp> 2 1 <b_fp> 1 0.001 …)
      quelltext: run_int8_lang.sh md5 38141fa1a080…; produktive libcortex.so vom 2026-08-25 12:55:03 (mit Zeilenpuffer-Fix, vor dem Clipfix vom 2026-08-28)
      parameter: 8 Segmente (seg0-3 zweimal), ~1835 Schritte je Segment, 2 Arbeiter je Arm, lr 0,001, Held-out 60 Fenster nach jedem Segment
      seed: Genesis A factory/checkpoints/fullint8_genesis.snai; Genesis B fullint8_genesis_b.snai (Saat 20260825)
      rechner: rechner-a
      logs: rechner-a:~/.cache/lang_run.log, ~/.cache/langb_run.log, ~/.cache/lang/, ~/.cache/langb/
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: Planung des Full-INT8-Ports (Abschnitte Schritt 1, Konsolidierung, Erster Produktivlauf, Adam-Zeilenpuffer), Rohdaten in /tmp gelöscht, nicht nachgerechnet
  m2633 abstand_endwert_schritt1_erste_fassung | +0,804 (gegen Hybrid), wachsend | Schritt 1 globale Gradientenskala (Rot), Genesis A (ungeseedet) |  | 8
  m2634 abstand_mittel | +0,071 | 1+2+3, Genesis A (ungeseedet) |  | 8
  m2635 abstand_mittel | +0,019 | 1+2+3, Genesis B (/tmp, Saat unbekannt) |  | 8
  m2636 abstand_mittel | +0,054 | voller Stack, Genesis A (ungeseedet) |  | 8
  m2637 abstand_mittel | +0,086 | voller Stack, Genesis C (ungeseedet) |  | 8
  m2638 abstand_endwert | -0,015 | 1+2+3, Genesis A (ungeseedet) |  | 1
  m2639 abstand_endwert | +0,073 | 1+2+3, Genesis B (/tmp, Saat unbekannt) |  | 1
  m2640 abstand_endwert | -0,008 | voller Stack, Genesis A (ungeseedet) |  | 1
  m2641 abstand_endwert | +0,089 | voller Stack, Genesis C (ungeseedet) |  | 1
  m2642 abstand_mittel_gesamt | +0,057 | alle 4 Läufe, Genesis A, B, C |  | 32
  m2643 abstand_segment3_produktivpfad | +2,50 (monoton wachsend) | voller Stack über train_cluster, Fehler-Rückführung still aus (Rot), Genesis A (ungeseedet) |  | 60
  m2644 abstand_segment3_produktivpfad | +0,68 (flach) | nach isNil-Fix, Genesis A (ungeseedet) |  | 60
  m2645 abstand_segment3_produktivpfad | +0,08 (fallend) | nach Zeilenpuffer-Fix, Genesis A (ungeseedet) |  | 60
  Quelle: rechner-a:~/.cache/lang_run.log und ~/.cache/langb_run.log (compare_heldout.php je Segment); Segmentwerte am 2026-10-21 aus den Logs neu abgelesen, Mittel/Steigung/Zerlegung aus der Planung des Full-INT8-Ports (nicht nachgerechnet)
  m2646 abstand_mittel_8_segmente | +0,1633 | Langlauf, Genesis A (ungeseedet) |  | 60
  m2647 steigung_je_segment | -0,0109 (SE 0,0085) | Langlauf, Genesis A (ungeseedet) |  | 8
  m2648 abstand_mittel_8_segmente | +0,2266 | Langlauf, Genesis B | 20260825 | 60
  m2649 steigung_je_segment | +0,0049 (SE 0,0151) | Langlauf, Genesis B | 20260825 | 8
  m2650 heldout_s7 | 6,4070 / 6,4534 | FP32 / INT8, Genesis A (ungeseedet) |  | 60
  m2651 heldout_s7 | 6,3964 / 6,5403 | FP32 / INT8, Genesis B | 20260825 | 60
  m2652 anteil_streuung_kachel | 51,8 % | Zerlegung beider Läufe, Genesis A und B |  | 16
  m2653 anteil_streuung_durchgang | 0,0 % | Zerlegung beider Läufe, Genesis A und B |  | 16
  m2654 modellgroesse_mb | 28,5 / 21,5 | FP32 / INT8 |  | 1
Ergebnis e211 [2026-10-21 19:38]: erfuellt
  Fazit: Der fertige Ganzzahl-Stack hält das Kriterium: der Abstand zu FP32 wächst weder in den 2000-Schritt-Läufen noch über 14.700 Schritte und eine zweite Epoche, an zwei Startpunkten. Er kostet auf der Drohnenstufe 0,16 bis 0,23 nats (Langlauf) bzw. ~0,06 (isolierter Pfad) bei 24,5 % kleinerem Modell. Damit war der int8-Stack als Unterbau für den LoRA-Fork und später prod512 tragfähig. Die Sonde konnte rot werden: zweimal schlug sie an, bei der ersten Fassung von Schritt 1 und als die Fehler-Rückführung im Produktivpfad still aus war. Nicht beantwortet ist, ob das bei größeren Modellen gilt; den gepaarten Versuch bei dim 512 führt snai/int8-fp32-dim512-gepaart.
  Offen: Alle Läufe vor dem Clipfix vom 2026-08-28 (beide Arme betroffen). Nur Drohnenstufe, ein Korpus, 2-3 Saaten. Endwerte schwanken stärker als der Effekt und hängen an der zuletzt trainierten Kachel (~0,15).
  Datei: Planung des Full-INT8-Ports
Chronik:
  2026-10-21 19:38 angelegt (Nachtrag: Nachtrag 2026-10-21. Zeitlinie, belegt nur durch die datierten, chronologisch angeordneten Abschnitte der Planung des Full-INT8-Ports (keine Versionsgeschichte): (1) Schritt 1 scheitert am 2026-08-24 (+0,665, wachsend); das Kriterium 'kein Wachstum des Abstands' ist ab Schritt 1a (2026-08-24, Z. 286f) in Gebrauch, also NACH dem Fehlschlag von Schritt 1 entstanden. (2) Die 2000-Schritt-Läufe des fertigen Stacks (Schritt 5a und die Saaten-Absicherung, 2026-08-24) liefen danach; in 'Konsolidierung: dritter Seed' (2026-08-24, Z. 1240f) wird das Kriterium als das entscheidende festgeschrieben. (3) Die Läufe, deren Zahlen hier stehen, begannen später: Produktivlauf 2026-08-25 (Z. 1884: 'Kriterium verletzt, das die Konsolidierung als das entscheidende benannt hatte'), Langlauf lang 2026-08-25 16:19, langb 2026-08-25 22:03 (Abschnitt 'Was die Wiederholung beantworten kann' steht vor dem Ergebnis). Damit stand das Kriterium vor den Läufen des fertigen Stacks und erst recht vor den Langläufen. Für Schritt 1 selbst lag es nicht vor.)
  2026-10-21 19:38 Rezept r232 (isolierter Pfad, 2000 Schritte, Seeds A/B/C)
  2026-10-21 19:38 Status geplant -> laeuft (Rezept r232)
  2026-10-21 19:38 Rezept r233 (Langlauf Seed A (lang) und B (langb))
  2026-10-21 19:38 Messwerte m2633-m2645
  2026-10-21 19:38 Messwerte m2646-m2654
  2026-10-21 19:38 Ergebnis e211: erfuellt
  2026-10-21 19:38 Status laeuft -> ausgewertet (Ergebnis e211)
```
