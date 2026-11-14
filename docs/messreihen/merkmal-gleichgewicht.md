# snai/merkmal-gleichgewicht

```text
snai/merkmal-gleichgewicht - ausgewertet, begonnen 2026-10-16, angelegt 2026-10-21, zuletzt 2026-10-21 14:32
Frage: Ruhen die Embedding-Elemente im AdamW-Decay-Gleichgewicht w ~ -EMA(u)/wd (u = m^/(sqrt(v^)+eps)), mit c* als Spalte festen Gradientenvorzeichens (These aus Literatur + Kernel)?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/gleichgewicht/kriterien.txt, Kopf '2026-10-16, Auftrag, VOR der Messung' (Messung ~15:33)):
  Je Checkpoint (s1_s7, s3_s7; s1_s4 als Vergleich), Zeilen 9..86, m/v aus dem Checkpoint: G1 Spearman rho(w, -u) ueber alle Elemente >= 0,3 stuetzt; < 0,1 und G2 nicht erfuellt: These nicht gestuetzt. G2 Spalte c*: sign(-u) == sign(w) in >= 80 % der Zeilen UND median|u| in c* >= 2x median|u| der uebrigen Spalten. These getragen: G2 in beiden Saaten. Geraetegrenze: m mittelt nur ~10 Schritte; schwaches G1 widerlegt dann nicht sicher ('mit diesem Geraet nicht entscheidbar'). Rot-Probe: u je Zeile permutiert -> |rho| < 0,05 und Vorzeichenquote ~50 %.
Darauf baut: snai/merkmal-gradzerl
Rezepte:
  r85 [2026-10-21] php ~/snai_pruef/merkmal/gleichgewicht/gleichgewicht.php <ckpt> [perm] (genaue Befehlszeile nicht protokolliert)
      quelltext: gleichgewicht.php 5a6c6b58 (Fassung nach Korrektur unpack('g*'))
      parameter: Checkpoints proj_ow gross_gross_s1_s7, s3_s7, s2_s7, s1_s4
      seed: Permutation Saat 4711
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/gleichgewicht/ergebnis.jsonl (ungueltige erste Fassung: ergebnis_FALSCH_int8gelesen.jsonl)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/gleichgewicht/ergebnis.jsonl (abgelesen 2026-10-21)
  m841 rho(w,-u) | 0,067 | Original Stand s7 | 1 | 1
  m842 Vorzeichen c* gleich | 50,0 % | Original Stand s7 | 1 | 78
  m843 medabs(u) c* / Rest | 73x | Original Stand s7 | 1 | 1
  m844 rho(w,-u) | 0,016 | Original Stand s7 | 3 | 1
  m845 Vorzeichen c* gleich | 51,3 % | Original Stand s7 | 3 | 78
  m846 medabs(u) c* / Rest | 63x | Original Stand s7 | 3 | 1
  m847 rho(w,-u) | 0,021 | Original Stand s7 | 2 | 1
  m848 medabs(u) c* / Rest | 23x | Original Stand s7 | 2 | 1
  m849 rho(w,-u) | 0,003 | Original Stand s4 | 1 | 1
  m850 medabs(u) c* / Rest | 18x | Original Stand s4 | 1 | 1
  m851 Rot (permutiert) rho / Verhaeltnis | 0,004 / 1,35 | Rot Stand s7 | 1 | 1
  m852 Rot (permutiert) rho / Verhaeltnis | 0,013 / 0,83 | Rot Stand s7 | 3 | 1
Ergebnis e82 [2026-10-21 14:32]: verfehlt
  Fazit: Die Gleichgewichtsform der Decay-These traegt nicht: rho(w,-u) liegt nahe 0 und das Vorzeichen von u in c* ist gegen w zufaellig (~50 %), in beiden Kollaps-Saaten. Wegen der Geraetegrenze (m ueber ~10 Schritte, keine Positivkontrolle fuer den Vorzeichenteil) ist das eher 'nicht gestuetzt' als widerlegt. Der Nebenbefund zaehlt mehr: c* bekommt 18- bis 73-mal groessere normierte Adam-Schritte, auch in der gesunden Saat 2 - c* allein erklaert also nicht, wer stirbt.
  Offen: Ein Geraet, das ueber die Zeitkonstante des Decays mittelt (statt m ueber ~10 Schritte), fehlt.
  Datei: rechner-a:~/snai_pruef/merkmal/gleichgewicht/kriterien.txt
Chronik:
  2026-10-21 14:31 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/gleichgewicht/kriterien.txt, Kopf '2026-10-16, Auftrag, VOR der Messung' (Messung ~15:33))
  2026-10-21 14:31 Rezept r85
  2026-10-21 14:31 Status geplant -> laeuft (Rezept r85)
  2026-10-21 14:32 Messwerte m841-m852
  2026-10-21 14:32 Ergebnis e82: verfehlt
  2026-10-21 14:32 Status laeuft -> ausgewertet (Ergebnis e82)
```
