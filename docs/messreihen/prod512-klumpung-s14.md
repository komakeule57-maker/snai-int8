# snai/prod512-klumpung-s14

```text
snai/prod512-klumpung-s14 - ausgewertet, begonnen 2026-09-26, angelegt 2026-10-21, zuletzt 2026-10-21 19:29
Frage: Ist der flache Held-out-Schritt s12->s13 des Produktivlaufs prod512 nur eine Klumpungspause (s14 fällt deutlich unter s13) statt einer echten Abflachung der Kurve?
Kriterium (nachgetragen, Beleg: Gegenprobe qualitativ vorab (2026-09-28 06:01, vor Ende von s14 um 13:25): 'muss s14 deutlich unter s13 fallen (Fit 3,9281); bleibt s14 nahe 3,96, ist die Kurve real abgeflacht'. Die Zahlenschwellen stehen erst um 14:32 mit dem Vermerk 'vorab'.):
  Prognose für s14 aus dem Fit s1..s13: 3,9281, SE 0,0061. s14 <= 3,9403 = Klumpungspause; s14 >= 3,9478 (2 Sigma am s13-Niveau) = reale Abflachung; dazwischen kein Urteil.
Baut auf: snai/prod512-ausreisser-s7
Darauf baut: snai/prod512-segmentnaehe
Rezepte:
  r184 [2026-10-21] Fit wie snai/prod512-fitwahl-s6 (Kontrolle: s1..s12 reproduziert 2,6987/2,2300/0,2272); php diagnose/compare_full_paired.php prod512_s12 prod512_s13 bzw. s13 s14
      quelltext: rechner-a:~/Projekte/snai_edge_int8_lora/diagnose/compare_full_paired.php; Fitskript k. A.
      parameter: HELDOUT_FULL_LOSS erste 64 Fenster
      seed: deterministisch
      rechner: rechner-a (Auswertung), vserver (Training/Held-out)
      logs: rechner-a:~/Projekte/snai_edge_int8_lora/factory/checkpoints/server_heldout/heldout_full_i8_prod512_s13.jsonl, _s14.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
 ; s13/s14 aus server_heldout abgelesen; Prognosen 3,9439 (s13) und 3,9281 (s14) sowie alpha s1..s13 0,2418 am 2026-10-21 nachgerechnet; gepaarte Werte nicht nachgerechnet
  m2271 Prognose s13 aus Fit s1..s12 | 3,9437 | Fit s1..s12 |  | 12
  m2272 HELDOUT_FULL_LOSS s13 | 3,960001 | prod512 s13 |  | 64
  m2273 Abweichung s13 | +2,7 Sigma | prod512 s13 |  | 64
  m2274 Gepaart s12->s13 Mittelwert / Median | -0,0018 / +0,0017 | prod512 |  | 64
  m2275 Prognose s14 aus Fit s1..s13 | 3,9281 | Fit s1..s13 |  | 13
  m2276 HELDOUT_FULL_LOSS s14 | 3,905523 | prod512 s14 |  | 64
  m2277 Abweichung s14 | -3,7 Sigma | prod512 s14 |  | 64
  m2278 Gepaart s13->s14 | -0,0545 (11,1 Sigma), Vorzeichen 61:3 | prod512 |  | 64
  m2279 Runs-Test s12->s14 | -3,53 Sigma (geklumpt) | prod512 |  | 64
  m2280 alpha Fit s1..s14 | 0,2235 | prod512 |  | 14
Ergebnis e172 [2026-10-21 19:29]: erfuellt
  Fazit: Klumpungspause, keine Abflachung: s14 fiel mit 3,9055 weit unter die Schwelle 3,9403, sogar 3,7 Sigma unter die Prognose. s13/s14 sind das dritte Klumpungspaar nach s7/s8 und s11/s12. Ein flaches Segment hätte die Abbruchgrenze fälschlich vorgezogen; Abbruchfragen gehören an Segmentpaare oder an den Pegel gegen den Fit. Dass der Fit beide Male um rund 3 Sigma danebenlag, war der Anstoß für snai/prod512-fenstertest und snai/prod512-heldout-verteilt: die SE 0,0061 unterschätzt die Streuung der ersten 64 Fenster.
  Offen: Die Zahlenschwellen sind erst im Ergebniseintrag schriftlich; vorab belegt ist nur die qualitative Gegenprobe.
Chronik:
  2026-10-21 19:29 angelegt (Nachtrag: Gegenprobe qualitativ vorab (2026-09-28 06:01, vor Ende von s14 um 13:25): 'muss s14 deutlich unter s13 fallen (Fit 3,9281); bleibt s14 nahe 3,96, ist die Kurve real abgeflacht'. Die Zahlenschwellen stehen erst um 14:32 mit dem Vermerk 'vorab'.)
  2026-10-21 19:29 Rezept r184
  2026-10-21 19:29 Status geplant -> laeuft (Rezept r184)
  2026-10-21 19:29 Messwerte m2271-m2280
  2026-10-21 19:29 Ergebnis e172: erfuellt
  2026-10-21 19:29 Status laeuft -> ausgewertet (Ergebnis e172)
```
