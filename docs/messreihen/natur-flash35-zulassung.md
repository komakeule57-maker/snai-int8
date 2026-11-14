# snai/natur-flash35-zulassung

```text
snai/natur-flash35-zulassung - ausgewertet, begonnen 2026-10-15, angelegt 2026-10-21, zuletzt 2026-10-21 14:32
Frage: Taugt gemini-3.5-flash-lite als Nachschub-Quelle, wenn das 3.1-Kontingent erschoepft ist (Probe 1 Prompt wie 3.1, Probe 2 mit Wortliste und 'genau 5 Saetze', Probe 3 zusaetzlich mit Persona)?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/schluss/kriterien_natur.txt, Abschnitte 'FLASH 3.5 ALS NACHSCHUB', 'PROBE 2 MIT VORGABE', 'PROBE 3 MIT PERSONA' (2026-10-15 09:50-10:2x, je vor der Probe).):
  Je Probe: Q1 alle Anfragen liefern Text, keine am Ausgabelimit abgeschnitten; Q2 >= 50 % der Geschichten behalten nach dem gemeinsamen Filter (Wortschatz aller Quellen, strengere Lesart ab Probe 2); Q3 haeufigste 4-Folge <= 15 %. Rot in Q1-Q3: 3.5 laeuft nicht.
Darauf baut: snai/natur-flash35-persona
Rezepte:
  r80 [2026-10-21] SNAI_GEMMA_MODEL_ID=gemini-3.5-flash-lite [SNAI_NATUR_SAETZE=5 SNAI_NATUR_WORTLISTE=gemma/wortliste_1500.txt] [SNAI_NATUR_PERSONA=1] Geschichten-Sammler (Flash-3.5-Fassung)
      quelltext: Geschichten-Sammler (Flash-3.5-Fassung) = Kopie der Flash-Fassung mit zwei Ersetzungen (assert); ohne Schalter Prompt bytegleich (md5 5fa3a2b3 bei mt_srand(7))
      parameter: je 3 Anfragen, 30 Gruppen, Ausgabelimit 32.000, RPD 300
      seed: -
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/schluss/gemma/natur_flash35_p1, _p2, _p3
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/schluss/kriterien_natur.txt (Ergebnisabschnitt; aus der Kriteriendatei abgelesen, Filterlaeufe nicht nachgerechnet)
  m813 Q2 behalten gemeinsamer Wortschatz | 10,8 % (97/900) | Probe 1 |  | 900
  m814 Q2 behalten | 18,0 % (161/895) | Probe 2 Wortliste |  | 895
  m815 Q2 behalten | 38,9 % (245/630) | Probe 3 Persona |  | 630
  m816 Q1 Text, nicht abgeschnitten | 3 von 3 | Probe 1/2/3 |  | 3
  m817 Q3 haeufigste 4-Folge | 5,2 / 5,6 / 9,0 % | Probe 1/2/3
  m818 Anfragen nur mit Ein-Satz-Geschichten | 1 / 1 / 0 | Probe 1/2/3 |  | 3
  m819 behaltene Token je Anfrage | 2.238 / 3.811 | Probe 2/3 |  | 3
  m820 Vergleich Flash 3.1 im selben Filter | 68,2-70,2 % behalten | Flash 3.1
Ergebnis e78 [2026-10-21 14:32]: verfehlt
  Fazit: Q2 blieb in allen drei Proben rot (10,8 / 18,0 / 38,9 %): 3.5 schreibt laengere Geschichten mit reicherem Wortschatz und haelt sich weder an die Wortliste noch zuverlaessig an die Satzzahl. Nach Kriterium laeuft 3.5 nicht. Es wurde trotzdem zugeschaltet (Fassung Probe 3), weil die behaltenen Token je Anfrage auf Hoehe von 3.1 liegen und der Zweck die Wartezeit war - eine bewusste Abweichung vom Kriterium, keine Erfuellung.
  Offen: Je Probe nur 3 Anfragen; eine Ein-Satz-Anfrage kippt den Anteil um ein Drittel.
  Datei: rechner-a:~/snai_pruef/schluss/kriterien_natur.txt
Chronik:
  2026-10-21 14:31 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/schluss/kriterien_natur.txt, Abschnitte 'FLASH 3.5 ALS NACHSCHUB', 'PROBE 2 MIT VORGABE', 'PROBE 3 MIT PERSONA' (2026-10-15 09:50-10:2x, je vor der Probe).)
  2026-10-21 14:31 Rezept r80
  2026-10-21 14:31 Status geplant -> laeuft (Rezept r80)
  2026-10-21 14:31 Messwerte m813-m820
  2026-10-21 14:32 Ergebnis e78: verfehlt
  2026-10-21 14:32 Status laeuft -> ausgewertet (Ergebnis e78)
```
