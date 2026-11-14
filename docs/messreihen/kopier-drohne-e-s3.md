# snai/kopier-drohne-e-s3

```text
snai/kopier-drohne-e-s3 - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 11:23
Frage: Setzt Kopieren in der Drohne über die Segmente ein (Arm E bis s3, Arm S bis s3, Arm P s2), und nur im ungesättigten Arm?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21 (Kriterien); Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  Kopieren ab Kopierrate 50 % oder Beleg-Anteil A 10 %; Kriterium 2: Kopieren nur im ungesättigten Arm (aus den Drohnen-Kriterien vorab).
Baut auf: snai/kopier-drohne-k-e, snai/kopier-icl-praefix
Darauf baut: snai/kopier-drohne-kopfpaar, snai/kopier-drohne-p
Rezepte:
  r33 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben)
      parameter: Drohne 128/4/4, ctx 512, int8, gebunden, echter Text. Arm E: Rezept prod512b (LR 0,0001, Warmup 500, Cosinus, WD 0,1), alles INT8, s3 = Update 61.500-82.000. Arm S: LR 0,003. Arm P: wie E, andere Fensterreihenfolge. Messung: ICL-Wächter 300 Fenster, Kontext-Ablation 60 Fenster
      rechner: rechner-a (E, S), rechner-b (P)
      logs: rechner-a: start_E.out; docs/VERGLEICH_LITERATUR_KOPIEREN.md Abschnitt 6g
Messwerte (Groesse | Wert | Arm | Start | n):
  m265 Beleg-Anteil A s0/s1/s2/s3 | 1,2 / 2,2 / 3,2 / 9,8 % (B 0,9 %) | E
  m266 Prefix-Matching Zufallsfolge s0/s1/s2/s3 | 0,007 / 0,007 / 0,007 / 0,083 (Kopf 3.2) | E
  m267 Natürliche Induktion s0/s1/s2/s3 | 0,008 / 0,014 / 0,028 / 0,154 | E
  m268 Kontextgewinn (ICL) s0/s1/s2/s3 | 0,079 / 0,078 / 0,092 / 0,196 (± 0,04) | E |  | 300
  m269 Loss s3 | 4,68 | E |  | 300
  m270 Leseprobe s3 | 0/10 | E |  | 10
  m271 Prefix-Matching / Kontextgewinn s2 | 0,199 / 0,233 | S
  m272 Beleg-Anteil A s0/s1/s2/s3 | 1,9 / 2,3 / 9,0 / 11,3 % | S
  m273 Held-out s0/s1/s2/s3 | 5,28 / 5,02 / 5,25 / 6,57 | S |  | 64
  m274 att_max_gewicht | 0,71-0,82 | S
  m275 Loss / ICL-Gewinn / Beleg-Anteil A s2 | 4,82 / 0,219 / 9,4 % | P
Ergebnis e30 [2026-10-21 11:23]: keine_aussage
  Fazit: Nach der Vorab-Schwelle nicht entschieden: E s3 liegt mit Beleg-Anteil 9,8 % knapp UNTER 10 %, der gesättigte Arm S mit 11,3 % knapp darüber. Eine frühere Notiz nannte das „Kopieren setzt ein“; das ist im Ton eines Befunds zu stark, später korrigiert auf „nicht entschieden“. Was trotzdem steht: Fernkontext-Nutzung springt bei Loss ~4,7-4,85 an (E s3, P s2), damit ist „kein Lauf nutzt Kontext jenseits 30 Token“ überholt. Das Kriterium „Kopieren nur im ungesättigten Arm“ ist NICHT bestätigt: auch S zeigt den Anstieg, obwohl sein Held-out kaputtgeht. INT8 ist nicht der Hauptverdacht.
  Offen: Vorbehalt: Beleg-Anteil ist ein Verhältnis zum Loss auf fremdem Text, der in S von 6,4 auf 8,3 stieg. Hypothese (ungeprüft): es zählen sequenzielle Updates, nicht Token (Arm W). Bestätigung durch P s3 (snai/kopier-drohne-p).
Chronik:
  2026-10-21 11:22 angelegt (Nachtrag: Nachgetragen 2026-10-21 (Kriterien); Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:22 Rezept r33
  2026-10-21 11:22 Status geplant -> laeuft (Rezept r33)
  2026-10-21 11:22 Messwerte m265-m275
  2026-10-21 11:23 Ergebnis e30: keine_aussage
  2026-10-21 11:23 Status laeuft -> ausgewertet (Ergebnis e30)
```
