# snai/merkmal-wdemb

```text
snai/merkmal-wdemb - ausgewertet, begonnen 2026-10-16, angelegt 2026-10-21, zuletzt 2026-10-21 19:24
Frage: Ist der Weight-Decay auf den Embeddings die Ursache des Aufloesungsverlusts, d. h. reicht es beim Knirps d96 Schach, den Weight-Decay nur von den Embeddings zu nehmen (alle anderen Gewichte WD 0,1), damit die Aufloesung der Embedding-Zeilen im Segment s4->s5 haelt?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/kriterien_wdemb.txt, Kopf '2026-10-16, vor dem Lauf' (Lauf 08:05-09:03; ERGEBNIS 09:03 angefuegt)):
  Regel aus gebiete/kriterien_wd.txt uebernommen: (1) WD auf den Embeddings IST die Ursache, wenn Stufen-Median >= 6 (gegen 3 mit WD 0,1) UND keine Zeile <= 1 Stufe; (2) NICHT die Ursache, wenn Stufen-Median <= 4; (3) genau 5: kein Schluss. Pflichtkontrolle: Held-out-Loss > 10 % schlechter als der Vergleichsarm (1,392) -> Tausch, keine Loesung. Zusatz ohne Schwelle: Formfehler bei 500 Ziehungen berichten (Vergleich 27,0 % mit WD 0,1). Reichweite: ein Segment, eine Saat = Beobachtung.
Baut auf: snai/merkmal-stufe1, snai/schach-wd0
Darauf baut: snai/merkmal-lang64, snai/merkmal-biaskanal-wd0, snai/merkmal-spaet
Rezepte:
  r162 [2026-10-21] SNAI_WD_EMBEDDINGS=0 SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 SNAI_LR_DECAY_STEPS=727208 nice -n 12 php train_cluster.php factory/input/gross_c64_seg5.txt factory/checkpoints/wd0_s1_s5.snai 1 1 factory/checkpoints/gross_gross_s1_s4.snai 3 0.001 0.0001 1 0.1 (aus merkmal/lauf_wdemb.sh, cwd knirps/proj_wdemb)
      quelltext: proj_wdemb = cp -a proj_clip + patch_stufe1.py --alt; cortex.nim-Basis 7b67236c, libcortex.so 3de425ae; Kurz-Bank bank_knirps.sh (b6b446a6): Vorgabe == Original 10a1ee05, =0 -> 706a5354; lauf_wdemb.sh 135a8c11
      parameter: Start gross_gross_s1_s4 (adam_t 466470), Segment gross_c64_seg5, LR 0,001 -> 0,0001 Cosinus bis 727208, Warmup 500, WD 0,1 ausser Embeddings, gebunden, int8 FULL, Revival aus
      seed: Saat 1 (Lauf gross_s1); Fensterfolge am Ausgabenamen wd0_s1_s5 (gepaart zum WD-0-Arm snai/schach-wd0, NICHT zu gross_gross_s1_s5)
      rechner: rechner-a (CPU, OMP 1)
      logs: rechner-a:~/snai_pruef/merkmal/erg_wdemb/wdemb.log, wdemb.train.log, zieh_wdemb.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/erg_wdemb/wdemb.log (Arm ohne Decay auf E; Formfehler mit form_sonde.py am 2026-10-21 nachgerechnet: 0,4 %, n 500). Vergleichsarme aus kriterien_wdemb.txt uebernommen, nicht nachgerechnet.
  m1769 Stufen-Median Embeddings | 4 | ohne Decay auf E | 1 | 1
  m1770 Zeilen <= 1 Stufe | 4/87 | ohne Decay auf E | 1 | 1
  m1771 Anteil Zeilenmaxima Spalte 32 | 73,6 % | ohne Decay auf E | 1 | 1
  m1772 Held-out-Loss | 1,3738 | ohne Decay auf E | 1 | 1
  m1773 Formfehler (500 Ziehungen, T 1, Saat 4711) | 0,4 % | ohne Decay auf E | 1 | 1
  m1774 Stufen-Median Embeddings | 4 | WD 0 ueberall (gepaart, Gebiete-Reihe) | 1 | 1
  m1775 Zeilen <= 1 Stufe | 10/87 | WD 0 ueberall (gepaart) | 1 | 1
  m1776 Formfehler | 0,6 % | WD 0 ueberall (gepaart) | 1 | 1
  m1777 Held-out-Loss | 1,3505 | WD 0 ueberall (gepaart) | 1 | 1
  m1778 Stufen-Median Embeddings | 3 | WD 0,1 ueberall (ungepaart) | 1 | 1
  m1779 Zeilen <= 1 Stufe | 22/87 | WD 0,1 ueberall (ungepaart) | 1 | 1
  m1780 Formfehler (300 Ziehungen) | 27,0 % | WD 0,1 ueberall (ungepaart) | 1 | 1
  m1781 Held-out-Loss | 1,392 | WD 0,1 ueberall (ungepaart) | 1 | 1
Ergebnis e151 [2026-10-21 19:24]: verfehlt
  Fazit: Nach der Vorab-Regel ist der Decay auf den Embeddings nicht die alleinige Ursache: der Stufen-Median faellt auch ohne ihn auf 4. Am Symptom wirkt der Eingriff aber vollstaendig (Formfehler 0,4 statt 27 %, so gut wie Decay ganz aus). Die Regel mass also die falsche Groesse; der Median sagt den Formfehler nicht voraus (spaeter bestaetigt in snai/merkmal-r3-saat und snai/merkmal-spaet). Achtung: Die Abhilfe 'Decay auf E aus' wurde am 2026-10-16 Vorgabe und am 2026-10-17 widerrufen, weil sie ab Genesis das Training zerfallen laesst (snai/merkmal-lang64). Ein Segment ab s4 ist zu kurz, um das zu sehen. Gepaart mit dem WD-0-Arm der Gebiete-Reihe (snai/schach-wd0, gebiete/kriterien_wd.txt).
  Offen: Eine Saat, ein Segment, Vergleich gegen WD 0,1 ungepaart. Langzeitwirkung ab Genesis: siehe snai/merkmal-lang64.
  Datei: rechner-a:~/snai_pruef/merkmal/kriterien_wdemb.txt
Chronik:
  2026-10-21 19:23 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/kriterien_wdemb.txt, Kopf '2026-10-16, vor dem Lauf' (Lauf 08:05-09:03; ERGEBNIS 09:03 angefuegt))
  2026-10-21 19:23 Rezept r162
  2026-10-21 19:23 Status geplant -> laeuft (Rezept r162)
  2026-10-21 19:23 Messwerte m1769-m1781
  2026-10-21 19:24 Ergebnis e151: verfehlt
  2026-10-21 19:24 Status laeuft -> ausgewertet (Ergebnis e151)
```
