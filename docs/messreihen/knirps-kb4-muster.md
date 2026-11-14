# snai/knirps-kb4-muster

```text
snai/knirps-kb4-muster - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 14:33
Frage: Kopier-Knirps 32/8/4 (Kopfbreite 4) am 50-%-Stand nach 1,2 Mio Fenstern: entsteht derselbe Induktionsschaltkreis wie bei Kopfbreite 8, nur schwächer, oder etwas anderes?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt, Abschnitt (s) (2026-10-12, vor dem Lauf).):
  (s) Werkzeug muster.sh (Kopf ist von einer Art ab Gewicht >= 0,5; Ansatz 0,1-0,5; Rot fremd: Folge < 0,1), 60 Fenster. GLEICHER SCHALTKREIS, SCHWÄCHER: mind. ein Kopf Schicht 0 mit Vorgänger >= 0,5 UND mind. ein Kopf Schicht 1 mit Folge >= 0,1, dessen Folge-Gewicht bei fremder erster Kopie unter ein Drittel fällt. ANDERER MECHANISMUS: Rang 0 >= 30 %, aber kein Kopf Schicht 1 mit Folge >= 0,1, oder die Folge-Gewichte bleiben bei fremder Kopie erhalten. Zusatz ohne Schwelle: Summe der Folge-Gewichte gegen den Bezug.
Plan: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt
Baut auf: snai/kopier-knirps-kb4-lang, snai/kopier-knirps-schaltkreis
Darauf baut: snai/knirps-kb4-schaerfen
Rezepte:
  r99 [2026-10-21] ~/snai_pruef/knirps/muster/muster.sh <ckpt> <marke> 60 <sabotage>; auswert_muster.py
      quelltext: roentgen/libcortex_rx.so + SNAI_ATT_DUMP, muster/mess_seq.php, auswert_muster.py
      parameter: Stände n_d32h8_s{1,2,3}_zp_s239 (50 / 45 / 36 %), Saat 1 auch bei s23 und s120; Bezug n_d32h4_s1 (Kopfbreite 8, gelernt)
      seed: Fenstersatz 777000111, 60 Fenster
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/muster/h8s*_*.att, h4s1_ende.*
      notiz: Prüfung beim Nachtrag: Nicht aus Rohdaten nachgerechnet. Lade-Wächter: n_d32h8 gehört zu den betroffenen Gitterläufen; Mitschnitt über den Ladepfad mit Wächter, ungeprüft.
Messwerte (Groesse | Wert | Arm | Start | n):
 , nicht nachgerechnet
  m922 Vorgänger Kopf 0.1 / Folge Schicht 1 (6 Köpfe) (n = Fenster) | 0,926 / 0,32-0,39 | 32/8/4 (50 %) | 1 | 60
  m923 Folge bei fremder erster Kopie / Rang 0 (n = Fenster) | 0,08 / 0,5 % | 32/8/4 (50 %) | 1 | 60
  m924 Vorgänger / Folge (6 Köpfe) (n = Fenster) | 0,870 / 0,30-0,33 | 32/8/4 (46 %) | 2 | 60
  m925 Vorgänger verteilt / Folge (n = Fenster) | 0,33-0,51 auf 5 Köpfe / 0,18-0,25 | 32/8/4 (36 %) | 3 | 60
  m926 Bezug Vorgänger / Folge (4 Köpfe) (n = Fenster) | 0,977 / 0,69-0,85 | 32/4/8 gelernt (92,6 %) | 1 | 60
Ergebnis e86 [2026-10-21 14:33]: erfuellt
  Fazit: In Saat 1 und 2 entsteht derselbe Induktionsschaltkreis, nur unscharf (Folge-Gewicht je Kopf um 0,35 statt 0,7-0,85); Saat 3 hat keinen sauberen Vorgänger-Kopf. Die Kopfbreite 4 macht also keinen anderen Kopier-Mechanismus, sondern einen schwächeren. Ob die Unschärfe die Ursache ist, prüfte snai/knirps-kb4-schaerfen (nein).
  Offen: Kausalprobe (Köpfe ausschalten) steht aus.
  Datei: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt
Chronik:
  2026-10-21 14:33 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt, Abschnitt (s) (2026-10-12, vor dem Lauf).)
  2026-10-21 14:33 Rezept r99
  2026-10-21 14:33 Status geplant -> laeuft (Rezept r99)
  2026-10-21 14:33 Messwerte m922-m926
  2026-10-21 14:33 Ergebnis e86: erfuellt
  2026-10-21 14:33 Status laeuft -> ausgewertet (Ergebnis e86)
```
