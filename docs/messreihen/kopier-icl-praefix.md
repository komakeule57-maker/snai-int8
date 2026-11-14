# snai/kopier-icl-praefix

```text
snai/kopier-icl-praefix - ausgewertet, begonnen 2026-10-11, angelegt 2026-10-21, zuletzt 2026-10-21 11:22
Frage: Trägt das Korpus Wiederholungen, haben Drohnen-Arme, prod512b und der alte Lauf Induktionsköpfe (Prefix-Matching), und nutzen sie Kontext jenseits ~30 Token (ICL-Score nach Olsson)?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt (in den Werkzeugköpfen)):
  (1) Wiederholungen im Korpus: Schwellen 0,10 / > 0,10 = datenseitige Vorbedingung erfüllt. (2) Prefix-Matching-Score des besten Kopfes ab 0,30 vorhanden. (3) ICL-Score: Gewinn = Loss Pos. 30-70 minus 471-511; < 0,15 kein Sprung, ab 0,40 Sprung.
Baut auf: snai/kopier-drohne-k-e, snai/kopier-prod512b-s0
Darauf baut: snai/kopier-drohne-e-s3
Rezepte:
  r31 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben); Werkzeuge: tools/wiederholung_korpus.php, tools/praefix_score.py, diagnose/icl_score.php + tools/auswert_icl.py
      parameter: (1) Korpus je 6 MB pseg00/pseg17 + Prüfsatz, neues Vokabular, Fenster 512 und 1024. (2) Prefix-Score aus zuf_wieder.induktion der Röntgen-kenn.json, bester Kopf. (3) ICL-Score: diagnose/icl_score.php patcht eval_held_out_full_i8.php, 300 Fenster; Abnahme: reproduziert Held-out 5,615177 exakt. Modelle: Drohne E s0/s1, K s0, S s0, W s3; prod512b t500-t2000; prod512_s19
      logs: Tabellen in docs/VERGLEICH_LITERATUR_KOPIEREN.md §6a
Messwerte (Groesse | Wert | Arm | Start | n):
  m246 Wiederholungen im Korpus, Häufigkeit | 0,38 (Fenster 512) / 0,47 (1024) | Korpus
  m247 Verlässlichkeit nach Aoyama / direkt | 0,34 / 0,24-0,26 | Korpus
  m248 Prefix-Matching-Score (PM), bester Kopf | 0,007-0,015 | alle Drohnen-Arme, prod512b t500-t2000
  m249 PM auf natürlichen Wiederholungen | 0,010-0,028 (Kontrolle 0,003-0,008) | alle Drohnen-Arme, prod512b t500-t2000
  m250 ICL-Gewinn | 0,08 ± 0,04 / 0,08 | Drohne E s0 / s1 |  | 300
  m251 ICL-Gewinn | 0,09 / 0,08 / 0,07 | Drohne K s0 / S s0 / W s3 |  | 300
  m252 ICL-Gewinn | 0,02 ± 0,06 | prod512b t2000 |  | 300
  m253 ICL-Gewinn | -0,21 ± 0,09 (Loss 3,83 bei Pos. 33-64, 3,98 bei 512-1023) | prod512_s19 |  | 300
  m254 Anteil des Kontextgewinns in den ersten 32 Token | 95 % von 1,08 nats | Drohne E s1 |  | 300
  m255 Attention-Gewicht weiter als 9 Token zurück / mittlere Blickweite | 61 % / 51 Token (E s1); 81 % / 191 Token (prod512b t2000); 45 % / 28 Token (S) | Röntgen
Ergebnis e28 [2026-10-21 11:22]: teilweise
  Fazit: Die datenseitige Vorbedingung ist erfüllt (das Korpus hat genug verlässliche Wiederholungen), aber zu diesem Stand hat kein Modell Induktionsköpfe (Prefix-Score auf Zufallsniveau) und keines einen ICL-Sprung: aus Kontext jenseits ~30 Token ziehen die Modelle keinen messbaren Nutzen, obwohl die Attention breit weit zurückschaut („schauen hin, nutzen nicht“). Der gesättigte alte Lauf wird mit längerem Kontext sogar schlechter, die erste Leistungszahl, an der seine Sättigung sichtbar ist. Der Engpass liegt also nicht im Material, sondern im Training. „Kein Lauf nutzt Kontext jenseits 30 Token“ wurde am 2026-10-12 für Drohne E s3 überholt (snai/kopier-drohne-e-s3).
  Offen: Messung an frühen Ständen (Drohne s0/s1, prod512b bis t2000); spätere Stände siehe Folgereihen.
Chronik:
  2026-10-21 11:21 angelegt (Nachtrag: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt (in den Werkzeugköpfen))
  2026-10-21 11:21 Rezept r31
  2026-10-21 11:21 Status geplant -> laeuft (Rezept r31)
  2026-10-21 11:21 Messwerte m246-m255
  2026-10-21 11:22 Ergebnis e28: teilweise
  2026-10-21 11:22 Status laeuft -> ausgewertet (Ergebnis e28)
```
