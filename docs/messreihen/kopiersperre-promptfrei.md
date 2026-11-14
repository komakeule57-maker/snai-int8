# snai/kopiersperre-promptfrei

```text
snai/kopiersperre-promptfrei - ausgewertet, angelegt 2026-10-24, zuletzt 2026-10-24 20:07
Frage: Senkt eine Kopiersperre, die Fortsetzungen von Prompt-Inhalt frei lässt (Paar letztes Token + Kandidat steht im Prompt), die Schleifen so stark wie die Grundform K, ohne Namen aus dem Prompt zu kosten? (prod512b_s4)
Kriterium (festgelegt 2026-10-24 19:17, vor dem ersten Messwert):
  Volltext rechner-a:~/snai_pruef/einstieg/kriterien_promptfrei.txt f9453e8c. Arme 0 / K (Grundform, Saat 1) / F (prompt-frei, Saat 1) / F2 (prompt-frei, Saat 2), Durchlass D=0.4174,0.6245,0.8671,0.7404,0.7988. TEIL B Bindung (rechner-b, 40 Posten mit erfundenem Namen, Treffer = Name in den ersten 120 Wörtern, gepaart): je F-Saat "kein Schaden" T_F >= T_0-2, "Schaden" T_F <= T_0-5, sonst unentschieden; F und F2 müssen in dieselbe Klasse fallen, sonst saatabhängig; K mit derselben Regel als Kontrolle, ob das Gerät den Schaden der Grundform sieht. TEIL S Schleifen: S1 rechner-a 12 Prompts U_F <= 0,5 U_0 (0/K aus b/p512_0, b/p512_K); S2 die 40 Bindungstexte U_F und U_F2 <= 0,5 U_0. GESAMT erfüllt = B kein Schaden UND S1 UND S2; teilweise = genau eines von B/S; verfehlt = B Schaden oder S1 und S2 verfehlt.
Plan: rechner-a:~/snai_pruef/einstieg/kriterien_promptfrei.txt
Baut auf: snai/kopiersperre-bindung, snai/schleife-einstieg
Darauf baut: snai/kopiersperre-nachmessung, snai/kopiersperre-kombi
Rezepte:
  r409 [2026-10-24] rechner-b: cd ~/snai_pruef/einstieg/bindung2 && setsid bash lauf.sh (xargs -P 6, je Job: PB_TAG=_<arm>_<i> PB_VON=i PB_BIS=i OMP_NUM_THREADS=1 SNAI_GAIN_GUARD=0 [Stellräder] bash proj_sr/tools/prompt_bindung_kopie2.sh ~/snai_pruef/einstieg/modell/prod512b_s4.snai 3 bindung2/<arm>). rechner-a: setsid bash ~/snai_pruef/einstieg/teil_s1.sh (BL_OMP=4 BL_KOEPFE=8 beamlauf2.sh M p512_F SNAI_KOPIE_F=D SNAI_KOPIE_PROMPTFREI=1).
      quelltext: patch_kopie2.py b6503675 -> snai_inference_kopie2.php 516e3a65 (aus snai_inference.php 8ba48a06); tools/prompt_bindung_kopie2.sh b08133ea; bindung2/lauf.sh f38e3783; beamlauf2.sh c22a9dc2; teil_s1.sh 1d4330e5; pruef_prot.py. Modell prod512b_s4.snai 751d92d9 (8 Köpfe).
      parameter: D=0.4174,0.6245,0.8671,0.7404,0.7988; Arme 0 | K (F=D Saat 1) | F (F=D Saat 1 PROMPTFREI=1) | F2 (F=D Saat 2 PROMPTFREI=1); Beam 3 ROH, 256 Token, rep 1,15/64. 40 Posten (10 alte + 30 neue, Namen gegen pseg00-39 und holdout_prod geprüft, 5 verworfen).
      seed: Sperre SNAI_KOPIE_SAAT 1 (K, F) und 2 (F2); Beam deterministisch
      rechner: rechner-b (Teil B, S2), rechner-a (Teil S1)
      logs: rechner-b:~/snai_pruef/einstieg/bindung2/{0,K,F,F2}/ und fortschritt.log; rechner-a:~/snai_pruef/einstieg/b/p512_F/ und log/promptfrei.log; Proben rechner-a:~/snai_pruef/einstieg/t2/
      notiz: Proben vor dem Start: A Stellrad aus bytegleich zu b/p512_K/p00 (Zähler 326/142 gleich); B pruef_prot GRÜN (14 frei, 0 Verstöße), C Mutante mit umgedrehter Bedingung ROT (128 Verstöße). Selbsttest des Bindungsgeräts grün, rot bei verstellter Postenzahl.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/einstieg/log/auswert_promptfrei.txt (auswert_promptfrei.py), Rohdaten bindung2/{0,K,F,F2}/ (von rechner-b), b/p512_{0,K,F}/beam.txt
  m5201 Treffer Prompt-Bindung (120 Woerter) | 7/40 | 0 |  | 40
  m5202 Treffer Prompt-Bindung (120 Woerter) | 2/40 | K | 1 | 40
  m5203 Treffer Prompt-Bindung (120 Woerter) | 12/40 | F | 1 | 40
  m5204 Treffer Prompt-Bindung (120 Woerter) | 10/40 | F2 | 2 | 40
  m5205 Posten verloren / gewonnen gegen 0 (McNemar p) | 5 / 0 (0,062) | K | 1 | 40
  m5206 Posten verloren / gewonnen gegen 0 (McNemar p) | 0 / 5 (0,062) | F | 1 | 40
  m5207 Posten verloren / gewonnen gegen 0 (McNemar p) | 1 / 4 (0,375) | F2 | 2 | 40
  m5208 Nennungen des Namens im ganzen Text | 25 / 6 / 56 / 39 | 0 / K / F / F2 | 1/2 | 40
  m5209 Urteil Bindung | K Schaden, F kein Schaden, F2 kein Schaden -> kein Schaden | B |  | 40
  m5210 U der 40 Bindungstexte | 0,552 / 0,144 / 0,140 / 0,149 | 0 / K / F / F2 | 1/2 | 40
  m5211 U der 12 Beam-Prompts (rechner-a) | 0,553 / 0,114 / 0,112 | 0 / K / F | 1 | 12
  m5212 U_F / U_0 | 0,20 (12 Prompts), 0,25 / 0,27 (40 Texte, F / F2) | F | 1/2 | 12/40
  m5213 E erfundene Wortformen, 12 Prompts | 0,0709 / 0,0355 / 0,0432 | 0 / K / F | 1 | 12
  m5214 Kopierkandidaten / gesperrt / prompt-frei (Summe 40 Posten) | 14146 / 5618 / 415 | F | 1 | 40
  m5215 Proben vor dem Lauf | A bytegleich K-Pfad, B pruef_prot gruen, C Mutante rot (128 Verstoesse) | F | 1 | 1
Ergebnis e358 [2026-10-24 20:07]: erfuellt
  Fazit: Die prompt-freie Kopiersperre behebt den Schaden der Grundform vollständig, ohne Schleifenwirkung zu verlieren. Die Grundform kostet auf 40 Posten Namen aus dem Prompt (7 auf 2, Schaden), prompt-frei verliert keinen (12 und 10 von 40, beide Saaten kein Schaden). U sinkt gleich stark wie mit der Grundform (0,20 bzw. 0,25-0,27 x U_0). Damit ist das die erste Fassung, die für eine Übernahme in die ausgelieferte snai_inference.php taugt; die Entscheidung ist offen. Die Paar-Regel ist nötig, weil "Fundstelle im Prompt" schon die zweite Nennung eines Namens wieder sperren würde.
  Offen: Nur ein Modell und ein Durchlass (aus 4 Prompts geschätzt); Übertragung auf andere Stände ungemessen. Zerbrochene Namensformen nehmen mit F zu (mehr Namensversuche), nicht als Kriterium gezählt. Dass F mehr Namen trifft als ganz ohne Sperre, ist nur gedeutet (Arm 0 hängt in Schleifen), nicht isoliert. Lesbarkeit/Qualität jenseits U und E ungemessen.
  Datei: rechner-a:~/snai_pruef/einstieg/ERGEBNIS_promptfrei.md
Chronik:
  2026-10-24 19:17 angelegt
  2026-10-24 19:18 Rezept r409
  2026-10-24 19:18 Status geplant -> laeuft (Rezept r409)
  2026-10-24 20:06 Messwerte m5201-m5215
  2026-10-24 20:07 Ergebnis e358: erfuellt
  2026-10-24 20:07 Status laeuft -> ausgewertet (Ergebnis e358)
```
