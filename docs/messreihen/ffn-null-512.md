# snai/ffn-null-512

```text
snai/ffn-null-512 - ausgewertet, angelegt 2026-11-01, zuletzt 2026-11-04 08:46
Frage: Tragen die mittleren Schichten der fertigen 8-Schicht-Modelle (dim 512, Zeichen-Text) etwas zum Held-out-Loss bei, und tun das ihre FFN-Zweige trotz schwacher Gains? L4 als Vergleich.
Kriterium (festgelegt 2026-11-01 22:44, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/ms_null/kriterien.txt (md5 d1e3a844, mit Prüfer, vor der ersten Armmessung). D = L(Arm)/L(A0) - 1 in Prozent, gepaart auf 300 Fenstern heldout.txt, je Saat, Bootstrap. Je Arm über 3 Saaten: TRÄGT D >= 7 in 3/3; STILL D < 1 in 3/3; KLEIN 1 <= D < 7 in 3/3; sonst SAATABHÄNGIG. Knapp (0,35 um 7, 0,05 um 1): Wiederholung auf heldout_frisch.txt, beide Lesarten. Haupturteil L8: Mitte nach NS_M, Mittel-FFN nach NF_M. Gegenprobe: NF_7 oder NF_0 TRÄGT in L8, NF_ALLE D >= 20 in 3/3, sonst FFN-Arm ungültig. Kontrolle: A0 = Endwerte der Tiefenreihe, sabotage > 10 % schlechter. Reichweite: Die Reihe sagt, ob L8 faktisch flach ist, nicht ob Tiefe nutzt.
Plan: rechner-b:~/snai_pruef/ms_null/kriterien.txt
Baut auf: snai/multistack-tiefe-512, snai-evo/lese
Darauf baut: snai/gains-ursache-folge, snai/gains-vertretung
Rezepte:
  r501 [2026-11-01] cd ~/snai_pruef/ms_null && setsid -f nohup python3 reihe_null.py > log/reihe.log 2>&1 < /dev/null
      quelltext: reihe_null.py 05532abe, werkzeug/nullsetzen.php 41b71f14 (aus SnAI_Evo evo/lese), werkzeug/mess_je.php 1ed6aa98 (mess_text.php plus Loss je Fenster, patch_mess.py 4d439b5d), libcortex e281ce8d
      parameter: L8 und L4, Saaten 1-3, Stand s19; Arme A0, SAB, NF_i, NA_i, NS_i, NF_M, NA_M, NS_M, NF_ALLE; 144 Messungen, 300 Fenster, CPU, 1 Thread, nice 8
      rechner: rechner-b, ein Prozess, startet nach REIHE_ENDE von reihe_g1
      logs: rechner-b:~/snai_pruef/ms_null/log/{reihe.log,mess.jsonl,mess.err}
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/ms_null/log/auswertung.txt, auswertung_nach.txt
  m7352 D NS_M L8 % | 65,3 / 57,0 / 70,8 | NS_M | 1,2,3 | 300
  m7353 D NF_M L8 % | 43,8 / 44,7 / 52,5 | NF_M | 1,2,3 | 300
  m7354 D NA_M L8 % | 33,0 / 19,8 / 45,7 | NA_M | 1,2,3 | 300
  m7355 D NF_7 L8 % | 104,7 / 119,0 / 87,6 | NF_7 | 1,2,3 | 300
  m7356 D NF_6 L8 % | 8,2 / 7,6 / 10,8 | NF_6 | 1,2,3 | 300
  m7357 D NF_0 L8 % | 6,2 / 3,7 / 3,7 | NF_0 | 1,2,3 | 300
  m7358 D NF_ALLE L8 % | 138,7 / 165,3 / 104,3 | NF_ALLE | 1,2,3 | 300
  m7359 D NF_1 bis NF_5 L8 %, Bereich | 0,07 bis 3,50 | NF_i | 1,2,3 | 300
  m7360 D NS_M L4 % | 27,9 / 30,2 / 55,6 | NS_M | 1,2,3 | 300
  m7361 D NF_M L4 % | 19,1 / 14,2 / 20,3 | NF_M | 1,2,3 | 300
  m7362 D NF_3 L4 % | 108,5 / 115,8 / 140,5 | NF_3 | 1,2,3 | 300
  m7363 Nachtraeglich D NF_K L8 %, Schichten 1..5 | 31,1 / 13,1 / 26,3 | NF_K | 1,2,3 | 300
  m7364 Nachtraeglich D NS_K L8 %, Schichten 1..5 | 37,7 / 25,0 / 29,3 | NS_K | 1,2,3 | 300
  m7365 Summe Einzel-D NF 1..5 L8 | 4,9 / 3,9 / 5,2 | NF_i | 1,2,3 | 300
  m7366 Loss NS_M L8 | 3,05 / 2,88 / 3,17 | NS_M | 1,2,3 | 300
  m7367 Spearman tot % gegen D(NF_i), Mittelschichten | L8 -0,72 (n 18), L4 -0,89 (n 6) | NF_i | 1,2,3
  m7368 Kontrolle A0 = Endwert | 6/6 gleich | A0 | 1,2,3 | 300
  m7369 Sabotage | +188 bis +193 % | SAB | 1,2,3 | 300
Ergebnis e435 [2026-11-02 04:56]: erfuellt
  Fazit: MITTE TRAEGT und MITTEL-FFN TRAEGT in L8, Gegenprobe bestanden. Die Lesart "L8 ist faktisch ein 2-Schichter mit Ballast" ist widerlegt; tote Tiefe erklaert den Gleichstand nicht. Schichten 1..5 kosten einzeln je rund 1 %, gemeinsam 25-38 %: Einzelnes Nullsetzen allein gaebe das falsche Bild "Mitte still", kuenftige Ablationen brauchen den gemeinsamen Arm. Ob Tiefe etwas nuetzt, misst das nicht; dafuer braucht es Trainingsvergleiche, weiteres Nullsetzen lohnt nicht.
  Offen: Ob Tiefe nuetzt. Trennung von "Schichten vertreten einander" und "Null-Ablation stoert" (NA_0 ist schlechter als Raten, Stoerung ist also real). Arme NF_K/NA_K/NS_K nachtraeglich, nur Beobachtung. Reichweite: 3 Saaten, ein Text, Stand s19, ohne Nachtraining; kein ctx 256, kein 128x4, kein prod512b.
  Datei: rechner-b:~/snai_pruef/ms_null/ERGEBNIS_ffn_null.md
Chronik:
  2026-11-01 22:44 angelegt
  2026-11-01 22:44 Rezept r501
  2026-11-01 22:44 Status geplant -> laeuft (Rezept r501)
  2026-11-02 04:56 Messwerte m7352-m7369
  2026-11-02 04:56 Ergebnis e435: erfuellt
  2026-11-02 04:56 Status laeuft -> ausgewertet (Ergebnis e435)
  2026-11-04 08:46 LESART-NACHTRAG 2026-11-04 (Anlass: e519 snai/fruehwarner-null des Hauptbaums). Bei 128x4 int8 mit Eingangsfaktor überschätzt das Nullen im fertigen Modell die Kosten des Weglassens beim gepaarten Neutraining um das 11- bis 14-Fache. Die Saaten ordnet es auch nicht. Das Urteil hier („MITTE TRÄGT“, „MITTEL-FFN TRÄGT“ in L8) belegt deshalb nur, dass das fertige Modell die Mitte BENUTZT. Dass es sie BRAUCHT, ist damit nicht belegt. Den Bedarf zeigt nur ein gepaarter Neulauf ohne den Teil, und bei 512 steht der aus. Der Wortlaut des Urteils bleibt unverändert. Die Übertragung von 128 auf 512 ist Deutung und nicht gemessen.
```
