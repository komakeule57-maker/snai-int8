# snai/kopier-drohne-k-e

```text
snai/kopier-drohne-k-e - ausgewertet, begonnen 2026-10-11, angelegt 2026-10-21, zuletzt 2026-10-21 11:22
Frage: Drohnen-Versuch (128/4/4, ctx 512, int8, gebunden, echter Text), Segmente 0-1: Sättigt das alte Rezept (Arm K) die Drohne wie prod512, und entsteht Kopieren nur im gesunden Arm (E)?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21 (Kriterien); Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  Aussagefähig zur Sättigung nur, wenn Arm K att_max_gewicht >= 0,7 erreicht und Arm E < 0,5 bleibt; Kopieren ab Kopierrate 50 % oder Beleg-Anteil A 10 %. Kriterium 2: Kopieren nur im ungesättigten (gesunden) Arm.
Baut auf: snai/kopier-mini-lr-reihe, snai/kopier-prod512-attention
Darauf baut: snai/kopier-icl-praefix, snai/kopier-drohne-float, snai/kopier-drohne-e-s3, snai/drohne-arbeiter
Rezepte:
  r29 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben)
      parameter: Drohne 128/4/4, ctx 512, int8, gebunden, echter Text; 21.104 Schritte = 10,8 Mio. Token je Arm und Segment; ein Seed je Arm. Arm K: LR 0,001, kein Warmup, WD 0. Arm E: LR 0,0001, Warmup 500, WD 0,1 (Übersicht: dazu Cosinus). Arm S (krank): LR 0,003. Arm W: 10 Arbeiter (rechner-b)
      rechner: rechner-a (K, E, S), rechner-b (W)
Messwerte (Groesse | Wert | Arm | Start | n):
  m226 att_max_gewicht Schritte 500/1000/2000/5000/10000/21104 | 0,199/0,353/0,380/0,373/0,372/0,369 | K
  m227 att_max_gewicht Schritte 500/1000/2000/5000/10000/21104 | 0,015/0,018/0,057/0,110/0,149/0,183 | E
  m228 Kopierrate s0 | 0,04 % | K
  m229 Kopierrate s0 | 0 % | E
  m230 Beleg-Anteil A s0 | 2,0 % (B 0,6 %) | K
  m231 Beleg-Anteil A s0 / s1 | 1,2 % (B 0,3 %) / 2,2 % (B 0,6 %) | E
  m232 Held-out s0 | 5,074 | K |  | 64
  m233 Held-out s0 / s1 | 5,615 / 5,057 | E |  | 64
  m234 att_max_gewicht s0 | 0,817 (je Schicht 0,47 0,99 0,81 1,00) | S
  m235 Kopierrate / Beleg-Anteil A s0 | 0,04 % / 1,9 % (B 0,7 %) | S
  m236 Held-out s0 | 5,282 | S |  | 64
  m237 Beleg-Anteil A s0 | 0,1 % | W
  m238 Leseprobe Prompt-Bindung | 0/10 | K, E, S (s0), E (s1) |  | 10
Ergebnis e26 [2026-10-21 11:22]: keine_aussage
  Fazit: Kriterium 1 nicht erfüllt: das alte Rezept sättigt die Drohne nicht (K bleibt bei 0,37 statt >= 0,7), der Versuch kann die Sättigungsfrage also nicht wie geplant beantworten. Die Sättigung hängt an Lernrate UND Modellgröße; ein dim-128-Modell stellt den Schaden von prod512 mit dessen Rezept nicht nach (erst LR 0,003, Arm S, sättigt). Kriterium 2 (Kopieren nur gesund) unentschieden: nach Segment 0/1 kopiert kein Arm (alle unter 10 %). Der gesättigte Arm S ist in keiner Leistungszahl schlechter als der gesunde; die Krankheit zeigt sich nur in Attention- und Gradientenanteilen. 10 Arbeiter (W) liegen 1,7 nats zurück.
  Offen: Ein Seed je Arm. Held-out K gegen E 9,6 % = knapper Gleichstand. Die Entwicklung ab Segment 2-3 steht in snai/kopier-drohne-e-s3.
Chronik:
  2026-10-21 11:21 angelegt (Nachtrag: Nachgetragen 2026-10-21 (Kriterien); Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:21 Rezept r29
  2026-10-21 11:21 Status geplant -> laeuft (Rezept r29)
  2026-10-21 11:21 Messwerte m226-m238
  2026-10-21 11:22 Ergebnis e26: keine_aussage
  2026-10-21 11:22 Status laeuft -> ausgewertet (Ergebnis e26)
```
