# snai/lego-stecken

```text
snai/lego-stecken - ausgewertet, angelegt 2026-10-31, zuletzt 2026-10-31 11:51
Frage: Lassen sich fertig trainierte Schichten getrennter Modelle ohne Nachtraining zusammenstecken?
Kriterium (festgelegt 2026-10-31 11:35, vor dem ersten Messwert):
  kriterien.txt auf rechner-b, vor dem ersten Lauf. 3 fertige Modelle 512x4 (gleicher Text, verschiedene Saat). Schnitte H1, H2, H3 (L0 / L0-1 / L0-2 aus i, Rest aus j), H0 alle L aus j (Embedding-Tausch, getrennt gedeutet), je 6 geordnete Paare. Held-out 300 Fenster. Urteil je Schnitt, alle 6 einig: TRAEGT Loss <= 1,10 x Original i; ZERFAELLT Loss >= Unigramm (rund 3,38); DAZWISCHEN alle 6 dazwischen; sonst PAARABHAENGIG. Gültig nur wenn K bytegleich und Loss wie Messbuch (2,1900 / 2,1490 / 2,1537), Blöcke bytegleich zum Spender, Hybrid verschieden vom Original, Fehlerkanal je Punkt ohne NaN, Inf oder unerwartete Meldung. V (eigene Schichten 3,2,1,0) als Maßstab. Reichweite: ein Text, eine Größe, gleiche Daten, keine Aussage über gemeinsamen Vorfahren oder Wissen vereinen.
Plan: rechner-b:~/snai_pruef/lego/kriterien.txt
Baut auf: snai/multistack-gstack-512
Darauf baut: snai/naht-themen, snai/multistack-naht-512
Rezepte:
  r479 [2026-10-31] cd ~/snai_pruef/lego && ./lauf.sh > log/lauf.log 2>&1
      quelltext: kriterien.txt 32062168; lego_stecken.php 2ea827a1; lauf.sh 6d23c303; mess_text.php aus knirps_gpu/text; libcortex e281ce8d; Modelle proj_gsA text_gs_s1-3_s5 (99d756c2, 4e1a3621, 3c84725e)
      parameter: 300 Fenster, 1 Thread, CPU, kein Training; Reihenfolge K, V, H2, dann H1/H3/H0
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/lego/log/mess.jsonl, mess.err, bau.log
      notiz: Rot Blockkontrolle gesehen: falsche Spender ergeben bloecke_falsch=2, rc 1. Grün: 0.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/lego/log/auswertung.txt, mess_d.jsonl
  m6844 Kontrolle K Loss | 2,1900 / 2,1490 / 2,1537, bytegleich | K | 1-3 | 300
  m6845 Massstab V Reihenfolge 3,2,1,0 | 5,6398 / 5,4391 / 5,4034 | V | 1-3 | 300
  m6846 H3 Median (Spanne) | 3,0856 (2,9581-3,2411) DAZWISCHEN | H3 | Paare | 6
  m6847 H2 Median (Spanne) | 3,39475 (3,2564-3,5082) PAARABHAENGIG | H2 | Paare | 6
  m6848 H1 Median (Spanne) | 3,7088 (3,4795-4,2888) ZERFAELLT | H1 | Paare | 6
  m6849 H0 Median (Spanne) | 5,24165 (4,8089-9,1102) ZERFAELLT, Embedding-Tausch | H0 | Paare | 6
  m6850 Weglassen D3 L0-2 eigen | 3,2244 / 3,0913 / 3,0719 (Beobachtung, nachträglich) | D3 | 1-3 | 300
  m6851 Weglassen D2 L0-1 eigen | 3,5794 / 3,1496 / 3,3359 (Beobachtung, nachträglich) | D2 | 1-3 | 300
  m6852 D schlechter als Hybrid | 5 von 6 gegen H3, 3 von 6 gegen H2, uneinig | D | Paare | 12
  m6853 Fehlerkanal | leer, keine NaN oder Inf | alle
Ergebnis e421 [2026-10-31 11:51]: verfehlt
  Fazit: Getrennt trainierte Schichten lassen sich ohne Nachtraining nicht zusammenstecken: kein Schnitt trägt, selbst eine einzige fremde Schicht landet bei Faktor 1,37-1,51. Der einfachste Lego-Weg ist in dieser Größe ausgeschlossen. Der Gegenversuch zeigt, warum: Das Weglassen der eigenen letzten Schicht kostet fast genauso viel, eine fremde Schicht ist also etwa so viel wert wie gar keine. Offen und nun die eigentliche Frage bleibt der gemeinsame Vorfahr.
  Offen: Gemeinsamer Vorfahr, Klebeschicht und Nachtraining nicht geprüft. Andere Größen und Texte nicht geprüft. Der Gegenversuch ist nachträglich festgelegt und nur Beobachtung. H2 liegt an der Unigramm-Schwelle, sein Urteil ist nicht robust.
  Datei: rechner-b:~/snai_pruef/lego/ERGEBNIS_lego_stecken.md
Chronik:
  2026-10-31 11:35 angelegt
  2026-10-31 11:35 Rezept r479
  2026-10-31 11:35 Status geplant -> laeuft (Rezept r479)
  2026-10-31 11:51 Messwerte m6844-m6853
  2026-10-31 11:51 Ergebnis e421: verfehlt
  2026-10-31 11:51 Status laeuft -> ausgewertet (Ergebnis e421)
```
