# snai/geschichten-tiefe

```text
snai/geschichten-tiefe - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:30
Frage: Ist ein 96er-Knirps mit 4 Schichten auf den Nano-Geschichten besser als mit 2 Schichten? (Tiefe und Parameterzahl 0,37 gegen 0,59 Mio. aendern sich gemeinsam; gefragt ist nur '96x4 gegen 96x2', nicht 'hilft Tiefe'.)
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/schluss/knirps96/kriterien_tiefe.txt samt Nachtrag nach der Zweitmeinung (laut Text vor dem Start, 2026-10-15 ~14:00).):
  Held-out-Loss nach Segment 4 (mess_text.php, 300 Fenster). Mittel L4 gegen Mittel L2: Abstand >= 10 % UND alle 3 L4-Saaten jenseits aller 3 L2-Saaten -> Ergebnis in dieser Richtung; Abstand < 10 % -> Gleichstand (bei getrennten Saatbereichen beide Lesarten); Saaten uneinig -> saatabhaengig. Nebenkriterien V1-V3 je Lauf. Rot-Probe: gemischt >= 1,5 x ungemischt. Ungepaart (verschiedene Genesis).
Baut auf: snai/geschichten-d96-probe
Darauf baut: snai/geschichten-pytorch, snai/geschichten-chin128
Rezepte:
  r63 [2026-10-21] rechner-b ~/snai_pruef/knirps_gpu/reihe_tiefe.sh (startet je Zelle/Saat: SNAI_LR_DECAY_STEPS=25000 nice -n 5 ./lauf_geschichten.sh proj_t gesch_d96h6L<L>_s<S> 0.001 5 factory/checkpoints/gesch_gen_d96h6L<L>_s<S>.snai (darin je Segment: SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=1 SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=500 php train_cluster.php factory/input/geschichten_seg<I>.txt <aus> 1 1 <vorgaenger> 3 0.001 0.0001 1 0.1); Genesis: SNAI_VOCAB=... php init_base.php <ziel> 0 96 128 <L> 384 <S> + .heads 6)
      quelltext: proj_t: cortex.nim 7e8a0516, libcortex.so 563780e3 (md5 heute); lauf_geschichten.sh 87ee67db, reihe_tiefe.sh b2439bcf; Korpus rechner-a:~/snai_pruef/schluss/knirps96/bauen.py
      parameter: Nano-Geschichten (alle Quellen der Schlussfolgern-Textsammlung, Filter natuertext.py, Wortschatz 1.500, gemischt Saat 4711), 3.000 Geschichten Held-out, 5 Segmente a ~640.000 Token (5.000 Fenster ctx 128), Vokabular wortweise 1.509; 96 breit, 6 Koepfe, ffn 384, ctx 128, gebunden, INT8_FULL, LR 0,001 -> 0,0001 Cosinus ueber 25.000, Warmup 500, WD 0,1, 1 Arbeiter, Revival aus, CPU OMP 2, Lade-Waechter aus; L = 2 und 4; bis 5 Laeufe gleichzeitig a 2 Faeden
      seed: Genesis 1, 2, 3 je Zelle
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/knirps_gpu/log/proj_t/gesch_d96h6L<L>_s<S>.*, reihe_tiefe.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/knirps_gpu/log/proj_t/gesch_d96h6L<L>_s<S>.mess.jsonl (Loss und Rot nachgelesen); V1-V3 und Kontext aus kriterien_tiefe.txt
  m610 Held-out-Loss Segment 4 | 2,2285 | L2 | 1 | 300
  m611 Held-out-Loss Segment 4 | 2,2229 | L2 | 2 | 300
  m612 Held-out-Loss Segment 4 | 2,2194 | L2 | 3 | 300
  m613 Held-out-Loss Segment 4 | 2,2010 | L4 | 1 | 300
  m614 Held-out-Loss Segment 4 | 2,1894 | L4 | 2 | 300
  m615 Held-out-Loss Segment 4 | 2,1944 | L4 | 3 | 300
  m616 Abstand Mittel L4 gegen L2 | -1,3 % | L4-L2 | 1-3
  m617 Rot-Probe gemischt | 9,15-9,36 | alle | 1-3 | 6
  m618 V1 / V2 / V3 | 98-100 % / 0 Kopien / alle unter 2,647 | alle | 1-3 | 50
  m619 Kontext-Sonde k32 | 2,204 | L2 | 1
  m620 Kontext-Sonde k32 | 2,190 | L2 | 2
  m621 Kontext-Sonde k32 | 2,193 | L2 | 3
  m622 Kontext-Sonde k32 | 2,190 | L4 | 1
  m623 Kontext-Sonde k32 | 2,151 | L4 | 2
  m624 Kontext-Sonde k32 | 2,163 | L4 | 3
Ergebnis e58 [2026-10-21 14:30]: gleichstand
  Fazit: Gleichstand nach Wortlaut (-1,3 %). Zweite Lesart: die Saatbereiche sind getrennt, alle drei L4 vorn - ein kleiner, saatfester Vorteil von ~1 %, weit unter der Schwelle. Bei dieser Datenmenge (3,2 Mio. Token) lohnt die doppelte Rechenzeit fuer 4 Schichten nicht; Breite 96 mit 2 Schichten bleibt die Knirps-Vorgabe fuer Geschichten. Ob Tiefe als solche hilft, ist nicht beantwortet (Kontrolle gleicher Parameterzahl nicht gewaehlt).
  Offen: Trennung Tiefe/Parameterzahl (2 Schichten bei Breite ~120).
  Datei: rechner-a:~/snai_pruef/schluss/knirps96/kriterien_tiefe.txt (Ergebnisabschnitt)
Chronik:
  2026-10-21 14:29 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/schluss/knirps96/kriterien_tiefe.txt samt Nachtrag nach der Zweitmeinung (laut Text vor dem Start, 2026-10-15 ~14:00).)
  2026-10-21 14:29 Rezept r63
  2026-10-21 14:29 Status geplant -> laeuft (Rezept r63)
  2026-10-21 14:29 Messwerte m610-m624
  2026-10-21 14:30 Ergebnis e58: gleichstand
  2026-10-21 14:30 Status laeuft -> ausgewertet (Ergebnis e58)
```
