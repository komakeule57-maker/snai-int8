# snai/textknirps-lens

```text
snai/textknirps-lens - ausgewertet, begonnen 2026-10-13, angelegt 2026-10-21, zuletzt 2026-10-21 14:34
Frage: Logit-Lens am Text-Knirps: Wie gut ist der Zwischenzustand nach jeder Schicht durch den Schlusskopf lesbar (Loss und Rang 0 je Schicht), bei 2 und 4 Schichten und bei Breite 32/64?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/lens/kriterien.txt ("vor dem ersten Lauf", Datei 2026-10-13 13:14:51, vor der ersten Lens-Messung am Ende der 4-Schicht-Läufe 13:33). Ohne Urteilsschwelle -> nur Beobachtung.):
  Beschreibend, keine Schwelle; über 3 Saaten berichten, Uneinigkeit benennen. Gültigkeit der Sonde vorab: GRÜN Lens an der letzten Schicht = normaler Vorwärtslauf (Abweichung < 1e-4); ROT Lens an Schicht 0 weicht ab; Kontrolle Vorwärts-Loss mit Lens-Bibliothek = mess_text.php. Grenze: Lens-Loss misst Lesbarkeit, keinen ursächlichen Beitrag.
Plan: rechner-a:~/snai_pruef/knirps/lens/kriterien.txt
Baut auf: snai/textknirps-tiefe
Rezepte:
  r110 [2026-10-21] SNAI_CORTEX_LIB=~/snai_pruef/knirps/lens/libcortex_lens.so php lens/lens_text.php <ck> text/heldout.txt text/ngram.json 300
      quelltext: lens/patch_lens.py 5b41d79cc57f (eine Ersetzung in einer Kopie von cortex.nim, assert count==1), lens/libcortex_lens.so b0faf311d7c4, lens/lens_text.php c42cca2e6f5f
      parameter: Endstände Segment 19 aller Textzellen auf rechner-a (tx_d32h2, tx_d32h2L4, tx_d64h2, tx_d64h4, je konstant und _fall, tx_d32h2_lr4), 300 Held-out-Fenster
      seed: Saaten 1-3 der jeweiligen Zellen
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps/text/tx_*_s{1,2,3}.lens.jsonl
      notiz: Prüfung beim Nachtrag: Alle Lens-Werte aus den lens.jsonl nachgerechnet; Sondenprüfung (Abweichung letzte Schicht 0, Schicht 0 > 12) an allen 27 Endständen erfüllt. Die früher festgehaltenen Werte stimmen. tx_d32h2L4_s1 und tx_d32h2L4_fall_s1 sind vom Lade-Wächter verändert.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/.cache/snai_pruef/knirps/text/tx_*.lens.jsonl (nachgerechnet)
  m1125 Sonde: max. Abweichung letzte Schicht | 0 | alle 27 Endstände | 1-3 | 18900
  m1126 Sonde: max. Abweichung Schicht 0 (Rot) | 12,3-25,4 | alle 27 Endstände | 1-3 | 18900
  m1127 Lens-Loss nach Schicht 1/2/3/4 (n = Fenster) | 2,730 / 2,517 / 2,358 / 2,186 (Wächter-Saat) | tx_d32h2L4 | 1 | 300
  m1128 Lens-Loss nach Schicht 1/2/3/4 (n = Fenster) | 2,824 / 2,612 / 2,468 / 2,161 | tx_d32h2L4 | 2 | 300
  m1129 Lens-Loss nach Schicht 1/2/3/4 (n = Fenster) | 2,840 / 2,620 / 2,358 / 2,174 | tx_d32h2L4 | 3 | 300
  m1130 Lens-Loss nach Schicht 1 (n = Fenster) | 2,63-2,78 | tx_d32h2 | 1-3 | 300
  m1131 Lens-Loss nach Schicht 1 (n = Fenster) | 2,34-2,52 | tx_d64h2 / tx_d64h4 | 1-3 | 300
  m1132 Lens-Loss nach Schicht 1 (n = Fenster) | 2,68-2,89 | tx_d32h2_fall | 1-3 | 300
  m1133 Lens-Loss nach Schicht 1 (n = Fenster) | 3,48-3,94 | tx_d32h2_lr4 | 1-3 | 300
  m1134 Lens-Loss nach Schicht 1 (n = Fenster) | 2,43-2,63 | tx_d64h2_fall / tx_d64h4_fall | 1-3 | 300
  m1135 Lens-Loss nach Schicht 1/2/3/4 (n = Fenster) | 2,96-3,01 / 2,66-2,72 / 2,37-2,48 / 2,01-2,04 | tx_d32h2L4_fall | 1-3 | 300
Ergebnis e103 [2026-10-21 14:34]: beobachtung
  Fazit: Bei 4 Schichten senkt jede Schicht den Lens-Loss um 0,14-0,31 nats; keine Schicht ist leer, welche der oberen beiden mehr bringt, hängt an der Saat. Die erste Schicht des 64ers ist schon besser lesbar als das Bigramm, die des 32ers nicht. Mit fallender Rate sind die unteren Schichten schlechter lesbar als bei konstanter Rate, das Ergebnis am Ende aber besser. Lesbarkeit durch den Schlusskopf ist kein Beitrag: für eine Aussage über die Arbeit einer Schicht fehlt ein Eingriff (Schicht überspringen).
  Offen: Ursächlicher Beitrag je Schicht (Eingriff) nicht gemessen; eine Auslese vor Block 0 gibt die Funktion nicht her.
  Datei: rechner-a:~/snai_pruef/knirps/lens/kriterien.txt
Chronik:
  2026-10-21 14:34 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/lens/kriterien.txt ("vor dem ersten Lauf", Datei 2026-10-13 13:14:51, vor der ersten Lens-Messung am Ende der 4-Schicht-Läufe 13:33). Ohne Urteilsschwelle -> nur Beobachtung.)
  2026-10-21 14:34 Rezept r110
  2026-10-21 14:34 Status geplant -> laeuft (Rezept r110)
  2026-10-21 14:34 Messwerte m1125-m1135
  2026-10-21 14:34 Ergebnis e103: beobachtung
  2026-10-21 14:34 Status laeuft -> ausgewertet (Ergebnis e103)
```
