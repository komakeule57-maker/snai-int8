# snai/kopiersperre-gross

```text
snai/kopiersperre-gross - ausgewertet, angelegt 2026-10-25, zuletzt 2026-10-26 07:10
Frage: Kostet die stärkere Dosis DS an s5 Namen gegenüber der ausgelieferten D4? Folge von e367, wo 40 Posten Rauschen und echte Kosten nicht trennen konnten.
Kriterium (festgelegt 2026-10-25 18:16, vor dem ersten Messwert):
  Aufbau: s5, 120 frische Posten, Arme V1-V3 (D4, Saat 1-3) gegen S1-S3 (DS), gepaart, also 360 Paare. Delta = (T_V - T_S)/360. Bootstrap über Posten (10000 Ziehungen, Saat 20261025, 95 %).
Kriterien:
- B: obere Grenze von Delta <= 0,05.
- K: untere Grenze > 0.
- L: U_S/U_V <= 0,9 und obere Grenze < 1.
- E: E_S/E_V <= 1,2 (E ohne den Schlüsselnamen).
- Saatregel: in jeder Saat T_Sk >= T_Vk - 6.
Urteil:
- erfuellt = B, L, E und Saatregel; dann DS vorschlagen.
- B und K zugleich = teilweise.
- K allein = verfehlt.
- nicht L = gleichstand.
- sonst teilweise.
Volltext: dosis/gross/kriterien_gross.txt 219d7f52.
Plan: rechner-a:~/snai_pruef/einstieg/dosis/gross/kriterien_gross.txt
Baut auf: snai/kopiersperre-dosis
Darauf baut: snai/kopfablation-prod512b, snai/kopiersperre-gross-s3
Rezepte:
  r421 [2026-10-25] rechner-b: cd ~/snai_pruef/einstieg/dosis/gross && setsid nohup bash lauf.sh > lauf.out 2>&1 &  ; Auswertung rechner-a: python3 dosis/gross/auswert_gross.py [-l] (nach Kopie von rechner-b dosis/gross/s5)
      quelltext: snai_inference_kopie2.php 516e3a65, tools/prompt_bindung_kopie5.sh 5be9ee78, lauf.sh 11392005, posten.txt ed3fd98d, auswert_gross.py 67e0bb5e, kriterien_gross.txt 26c6499b, modell prod512b_s5.snai 10ab21ad
      parameter: Beam 3 ROH, prompt-frei, D4=0.4174,0.6245,0.8671,0.7404,0.7988 / DS=0.3613,0.5620,0.5627,0.7051,0.7978, 120 Posten x 6 Arme = 720 Läufe, xargs -P 4, OMP_NUM_THREADS=1, SNAI_GAIN_GUARD=0, nice 19
      seed: SNAI_KOPIE_SAAT 1/2/3 (V_k und S_k gleiche Saat), Bootstrap 20261025
      rechner: rechner-b (daneben TDC-AI VL mit 6 Prozessen, abgesprochen)
      logs: rechner-b:~/snai_pruef/einstieg/dosis/gross/s5/<arm>/, fortschritt.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/einstieg/log/auswert_gross.txt (auswert_gross.py 67e0bb5e)
  m5616 Treffer | 94/360 | V (D4) | 1-3 | 360
  m5617 Treffer | 97/360 | S (DS) | 1-3 | 360
  m5618 Delta (T_V-T_S)/n, 95 % Bootstrap ueber Posten | -0,0083 [-0,0389; 0,0222] | S gegen V | 20261025 | 360
  m5619 U_S/U_V, 95 % | 0,642 [0,564; 0,727] | S gegen V | 20261025 | 360
  m5620 E_S/E_V (ohne Schluesselnamen), 95 % | 1,029 [0,948; 1,117] | S gegen V | 20261025 | 360
  m5621 Treffer V/S, verloren/gewonnen | 32/31, 5/4 | V1/S1 | 1 | 120
  m5622 Treffer V/S, verloren/gewonnen | 34/34, 4/4 | V2/S2 | 2 | 120
  m5623 Treffer V/S, verloren/gewonnen | 28/32, 6/10 | V3/S3 | 3 | 120
  m5624 U_S/U_V je Saat | 0,585 / 0,659 / 0,676 | S gegen V | 1-3 | 120
  m5625 Fehlerkanal (rc!=0, <20 Woerter, Muster, OOM) | 0 | alle | 1-3 | 720
Ergebnis e371 [2026-10-25 23:07]: erfuellt
  Fazit: Die offene Frage aus e367 ist beantwortet: DS kostet an s5 keine Namen. Höchstens 2,2 von 100 Namen gehen verloren, relativ rund 8 %. Die drei verlorenen Namen in e367 waren Rauschen. Der Schleifengewinn ist dagegen sicher, U fällt auf 0,64 × D4.

Damit gilt die Dosis-Lesart: D4 war zu schwach dosiert, nicht nur für s4 passend kalibriert. DS ist an s4 (e367) und s5 (hier) ohne Namenskosten geprüft. Nach der Regel wird DS als neue Voreinstellung vorgeschlagen; über den Wechsel wird gesondert entschieden.

Die Sperre lenkt an Verzweigungen um, ohne Namen anzutasten. Verloren und gewonnen wird ungefähr gleich oft, 15 zu 18.
  Offen: - Spätere Stände nach s5, andere Beam-Breiten und Sampling sind nicht gemessen.
- Ob eine noch stärkere Dosis weiter hilft oder dann Namen kostet, ist offen; DS ist nur der stärkste gemessene Punkt.
- Lesbarkeit ist nur über E genähert; eine Leseprobe durch einen Menschen fehlt.
  Datei: rechner-a:~/snai_pruef/einstieg/dosis/gross/ERGEBNIS_gross.md
Chronik:
  2026-10-25 18:16 angelegt
  2026-10-25 18:17 Rezept r421
  2026-10-25 18:17 Status geplant -> laeuft (Rezept r421)
  2026-10-25 23:06 Messwerte m5616-m5625
  2026-10-25 23:07 Ergebnis e371: erfuellt
  2026-10-25 23:07 Status laeuft -> ausgewertet (Ergebnis e371)
  2026-10-26 06:55 Entscheidung 2026-10-26: Der Wechsel der Voreinstellung von D4 auf DS wird zurückgestellt, bis der Fork SnAI Evo seine DITTO-Reihen am Knirps abgeschlossen hat (snai/ditto-*, zuletzt snai/ditto-einstieg, läuft). Bis dahin bleibt D4 im Projektbaum snai_edge_int8_lora (Commit 9576d0e), es wird nichts geändert. Danach Vorschlag aus e371 erneut vorlegen. Ein Wechsel hieße: SNAI_KOPIE_F_DEFAULT in snai_inference.php, §19 in PRODUKTIVLAUF_DIM512.md, Probe t3 (voreingestellt == kopie2 F) neu, Commit.
  2026-10-26 07:10 Grund für das Zurückstellen (2026-10-26). SnAI Evo bearbeitet in Testreihen dieselbe fehlerhafte Schleife von der Trainingsseite her (DITTO, snai/ditto-*). Erst mit diesen Ergebnissen wird über DS entschieden.
```
