# snai/kopier-drohne-float

```text
snai/kopier-drohne-float - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 19:17
Frage: Ändert die Ganzzahl-Rechnung (Arm F: Rückwärts, Gradienten, Adam-Momente, FFN-Aktivierungen in Float), die 8-Bit-Speicherung der Gewichte (Arm G: alles Float) oder Batch 16 (Arm B) das Lernen der Drohne gegenüber Arm E bzw. K?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  Unter 10 % Unterschied ist Gleichstand; beim ICL-Gewinn unter 2 Standardfehlern kein Befund.
Baut auf: snai/kopier-drohne-k-e
Darauf baut: snai/drohne-vo-nebenfund
Rezepte:
  r32 [2026-10-21] k. A. (nur in Arbeitsnotizen beschrieben)
      parameter: Drohne 128/4/4, ctx 512, gebunden, echter Text, Rezept E (LR 0,0001, Warmup 500, WD 0,1). Stellrad SNAI_INT8_FULL: Arm E alles INT8; Arm F Gewichte INT8, Rückwärtspfad/Gradienten/Adam-Momente/FFN-Aktivierungen Float; Arm G alles Float (Segmente 0..1, ~11 h je Segment, gestartet 2026-10-12 04:21). Arm B: 16 Fenster je Update, LR 0,001, gegen Arm K (1 Fenster, LR 0,001). Je ein Lauf, G mit anderer Fensterreihenfolge als E (ungepaart)
      rechner: rechner-a
Messwerte (Groesse | Wert | Arm | Start | n):
  m256 Held-out s0 | 5,615 / 5,576 / 5,593 | E / F / G |  | 64
  m257 Held-out s1 | 5,057 / 5,050 | E / G |  | 64
  m258 ICL-Gewinn s0 | 0,079 ± 0,035 / 0,080 ± 0,034 | E / F |  | 300
  m259 Beleg-Anteil A s0 | 1,2 % / 1,3 % / 1,3 % | E / F / G
  m260 Kopierrate s0 / s1 | 0 / 0,0001 | G
  m261 Leseprobe s0 | 0/10 | E, F, G |  | 10
  m262 Held-out s0 | 5,231 / 5,074 | B / K |  | 64
  m263 ICL-Gewinn s0 | 0,057 ± 0,037 / 0,087 ± 0,042 | B / K |  | 300
  m264 Beleg-Anteil A s0 | 2,3 % / 2,0 % | B / K
  Quelle: rechner-a:~/snai_pruef/drohne/log_B/heldout_s1.txt (2026-10-12 10:28) und log_F/heldout_s1.txt (2026-10-12 12:20), Zeile HELDOUT_FULL_LOSS, 64 Fenster / 32.704 Token; selbst abgelesen 2026-10-21 (Hinweis aus dem Evo-Fork). Beleg-Anteile/ICL s1 nicht eingetragen: Formel aus den Rohdateien nicht nachvollzogen.
  m1412 Held-out s1 | 4,609404 | B |  | 64
  m1413 Held-out s1 | 5,046114 | F |  | 64
Ergebnis e29 [2026-10-21 11:23]: gleichstand
  Fazit: Weder die Ganzzahl-Rechnung von Gradienten, Momenten und FFN-Aktivierungen (F) noch die 8-Bit-Speicherung der Gewichte (G) ändert am Lernen der Drohne bis Segment 1 (rund 41.700 Schritte) etwas Messbares; INT8 ist als Hauptverdacht für fehlendes Kopieren damit vom Tisch. Batch 16 bei LR 0,001 bringt ebenfalls keinen Vorteil (spricht die Batchgröße aber nicht frei). Vorbehalt laut Eintrag: kein Arm kopiert hier, belegt ist „lernt gleich“, nicht „bildet Kopieren gleich gut aus“.
  Offen: Je ein Lauf, G ungepaart zu E (andere Fensterreihenfolge; Reihenfolge-Streuung bis s1 <= 0,016, ab s2/s3 0,15). G endet vor dem Einsetzen des Kopierens und sagt über den Bereich, in dem kopiert wird, nichts. Segmentprüfung B rot wegen qk_rms 0,063.
Chronik:
  2026-10-21 11:22 angelegt (Nachtrag: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:22 Rezept r32
  2026-10-21 11:22 Status geplant -> laeuft (Rezept r32)
  2026-10-21 11:22 Messwerte m256-m264
  2026-10-21 11:23 Ergebnis e29: gleichstand
  2026-10-21 11:23 Status laeuft -> ausgewertet (Ergebnis e29)
  2026-10-21 19:17 Messwerte m1412, m1413
```
