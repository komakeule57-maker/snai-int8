# snai/knirps-kopierprobe

```text
snai/knirps-kopierprobe - ausgewertet, angelegt 2026-11-04, zuletzt 2026-11-04 16:13
!! ohne Rezept
Frage: Kopiert der Knirps 128x4 aus dem Kontext, sodass sich Arme mit toten und lebenden Gains im Kopieren vergleichen lassen (Frage: kosten tote Gains Fähigkeiten jenseits des Verlusts)?
Kriterium (festgelegt 2026-11-04 16:12, vor dem ersten Messwert):
  KEINS, Funktionsprobe des Messgeräts; das Ergebnis gilt als Beobachtung. Messgerät: text/faehig.php (94c4abb1, per assert aus mess_text.php 711d8187), Posten daten/faehig_ho2.jsonl (f6ac4a19, mach_faehig.py fdb0cfc2, heldout2, 200 Paare). Arme je Paar: nat_w (Satz A vorn und als Ziel), nat_k (anderer Satz gleicher Länge vorn), zuf_w und zuf_k (12 Zufallswörter). Gemessen: Rang 0 und Verlust auf den Ziel-Token ab dem zweiten. Kopiergewinn = w − k. Vorab gedacht: Kopiert keines der Bezugsmodelle, kann die Probe den Armvergleich nicht tragen.
Messwerte (Groesse | Wert | Arm | Start | n):
  m8786 Rang0 nat_w / nat_k C_s4 (9k, Cosinus) | 23.4 | % gegen 23,4 %; Verlust 3,469 gegen 3,483
  m8787 Rang0 zuf_w / zuf_k C_s4 | 0.0 | % gegen 0,0 %; Verlust 11,607 gegen 11,625
  m8788 Rang0 nat_w / nat_k E27_s4 (27k, F, konstant) | 20.7 | % gegen 20,5 %; Verlust 3,688 gegen 3,718
  m8789 Rang0 zuf_w / zuf_k E27_s4 | 0.0 | % gegen 0,0 %; Verlust 11,229 gegen 11,239
Ergebnis e528 [2026-11-04 16:13]: beobachtung
  Fazit: Der Knirps kopiert nicht aus dem Kontext, weder bei 9k (C_s4) noch bei 27k (E27_s4). Wiederholte Sätze oder Zufallsfolgen werden praktisch nicht besser vorhergesagt als neue: Kopiergewinn 0 Punkte Rang 0, höchstens 0,03 nats. Damit lässt sich am Knirps nicht entscheiden, ob tote Gains das Kopieren kosten. Diese Frage gehört an prod512b (snai/prod512b-abkuehl-kopieren). Reichweite: zwei Stände, eine Saat, 200 Paare.
Chronik:
  2026-11-04 16:12 angelegt
  2026-11-04 16:13 Messwerte m8786-m8789
  2026-11-04 16:13 Status geplant -> laeuft (Messwerte m8786-m8789)
  2026-11-04 16:13 Ergebnis e528: beobachtung
  2026-11-04 16:13 Status laeuft -> ausgewertet (Ergebnis e528)
```
