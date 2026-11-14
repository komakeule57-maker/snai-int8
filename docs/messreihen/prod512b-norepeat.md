# snai/prod512b-norepeat

```text
snai/prod512b-norepeat - ausgewertet, angelegt 2026-10-23, zuletzt 2026-10-23 13:24
Frage: Beseitigt die eingebaute harte n-Gramm-Sperre der Beam-Suche (SNAI_BEAM_NOREPEAT, in Token) die Absatzschleifen der Leseprobe von prod512b s3, ohne Wortsalat zu erzeugen?
Kriterium (festgelegt 2026-10-23 13:05, vor dem ersten Messwert):
  Arme an prod512b_s3 (ROH, 4 Prompts, Beam 3, 256 Token, Strafe 1,15/64, alpha 1,5): B ohne Sperre, N4/N8/N12/N16 = Sperre 4/8/12/16 Token. W (8-Wort-Wiederholung) nur als Bedingung. Lesbarkeit blind: 20 Antworten + 4 Kontrollen (B-Antworten wortweise gemischt, Saat 20261023) gemischt ohne Armbezeichnung an Gemini und Mistral; je Text SAETZE / BRUCHSTUECKE / SCHLEIFE. Rater gültig nur mit Kontrollen >= 3/4 BRUCHSTUECKE und B >= 3/4 SCHLEIFE. hilft = W <= 0,1 in >= 3/4 Prompts UND jeder gültige Rater SAETZE in >= 3/4; Wortsalat = ein gültiger Rater BRUCHSTUECKE in >= 2/4; sonst uneinig. Mehrere hilft: größtes n empfohlen. logP je Token und Länge nur berichtet. Volltext rechner-a:~/snai_pruef/merkmal/prodtest/norepeat/kriterien.txt (29d5ef1b, mit Prüfer).
Plan: rechner-a:~/snai_pruef/merkmal/prodtest/norepeat/kriterien.txt
Baut auf: snai/prod512b-beamalpha
Darauf baut: snai/prod512b-schleife
Rezepte:
  r391 [2026-10-23] cd ~/snai_pruef/merkmal/prodtest/norepeat && setsid nohup bash lauf.sh 3 > lauf_s3.out 2>&1 &  (je Antwort SNAI_BEAM_NOREPEAT=<n> SNAI_BEAM_DUMP=1 SNAI_ROHPROMPT=1 SNAI_FORCE_CPU=1 OMP_NUM_THREADS=2 nice -n 19 php snai_inference.php factory/checkpoints/prod512b_s3.snai "<Prompt>" 3; 4 parallel je n)
      quelltext: proj_sr snai_inference.php 8ba48a06 unverändert (Sperre eingebaut), libcortex.so 318b2655; norepeat/lauf.sh 8405650c, kriterien.txt 29d5ef1b; Rater über mcp gemini-research zweitmeinung
      parameter: n = 4/8/12/16 Token; Beam 3, 256 Token, rep 1,15/64, alpha 1,5, ROH, 4 Prompts; Kontrollen: B-Antworten wortweise gemischt (random.Random(20261023))
      seed: deterministisch (Beam); Mischsaat Kontrollen 20261023, Mischsaat Reihenfolge an die Rater 20261024
      rechner: rechner-a, nice 19
      logs: rechner-a:~/snai_pruef/merkmal/prodtest/norepeat/s3/ (n<N>_p<i>.txt/.err)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/prodtest/norepeat/ (paket.py -> s3_zuordnung.json, rater.py -> s3_rater_gemini.txt / s3_rater_mistral.txt)
  m4717 W je Prompt (Wohnhaus/Hauptstadt/1928/Film) | 0,741/0,399/0,670/0,344 | B | - | 4
  m4718 W je Prompt | 0/0/0/0 | N4 | - | 4
  m4719 W je Prompt | 0/0/0/0 | N8 | - | 4
  m4720 W je Prompt | 0,380/0,115/0,051/0 | N12 | - | 4
  m4721 W je Prompt | 0,349/0,267/0,350/0,136 | N16 | - | 4
  m4722 logP je Token Sieger | -1,54/-1,10/-1,10/-1,34 | B | - | 4
  m4723 logP je Token Sieger | -1,77/-1,59/-1,39/-1,68 | N4 | - | 4
  m4724 logP je Token Sieger | -1,45/-1,25/-1,30/-1,34 | N8 | - | 4
  m4725 logP je Token Sieger | -1,53/-1,20/-1,25/-1,37 | N12 | - | 4
  m4726 logP je Token Sieger | -1,54/-1,19/-1,21/-1,32 | N16 | - | 4
  m4727 Rater-Gültigkeit B als SCHLEIFE | 0/4 (Gemini), 0/4 (Mistral) | Rater | - | 4
  m4728 Rater-Gültigkeit Kontrollen als BRUCHSTUECKE | 1/4 (Gemini), 3/4 (Mistral) | Rater | 20261023 | 4
  m4729 Fehlerkanal | N12 Prompt 1928 im ersten Durchgang durch OOM beendet, einzeln wiederholt | N12 | - | 1
Ergebnis e334 [2026-10-23 13:24]: keine_aussage
  Fazit: Nach der Vorab-Regel kein Urteil: beide Rater-Modelle sind ungültig, sie stufen die bekannten Schleifen (B) zu 0/4 als SCHLEIFE ein. Eigene Lesung (Beobachtung, nicht blind): Die harte n-Gramm-Sperre beseitigt die wortgleiche Absatzkopie, das Modell weicht aber aus - bei n 12/16 in Beinahe-Kopien mit getauschten Wörtern (W 0,05-0,38), bei n 8 in sinngleiche Schleifen und Kurzsatz-Ketten, erst bei n 4 bricht die Wiederholung, dann mit Wortneubildungen und erfundenen Namen. Keine Stufe liefert an allen 4 Prompts sauberen Text. Die Dekodierung verschiebt das Problem nur; es sitzt im Modell (passt zu snai/prod512b-beamalpha). Für die Leseprobe nichts umstellen; als Fortschrittsmaß weiter die Beam-Spur ohne Sperre lesen.
  Offen: Blinder Rater, der Schleifen erkennt (Mensch oder Kontrollen bestanden). Wiederholung an s4 und späteren Ständen: ob die Ausweich-Schleifen mit dem Training abnehmen. Sperre gegen sinngleiche Wiederholung (z. B. auf Satzebene) ungeprüft.
  Datei: rechner-a:~/snai_pruef/merkmal/prodtest/norepeat/kriterien.txt
Chronik:
  2026-10-23 13:05 angelegt
  2026-10-23 13:05 Rezept r391
  2026-10-23 13:05 Status geplant -> laeuft (Rezept r391)
  2026-10-23 13:24 Messwerte m4717-m4729
  2026-10-23 13:24 Ergebnis e334: keine_aussage
  2026-10-23 13:24 Status laeuft -> ausgewertet (Ergebnis e334)
```
