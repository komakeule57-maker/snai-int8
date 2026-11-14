# snai/merkmal-zeilenintern

```text
snai/merkmal-zeilenintern - ausgewertet, begonnen 2026-10-17, angelegt 2026-10-21, zuletzt 2026-10-21 19:16
Frage: Sterben die Embedding-Zeilen im Sprung s4 -> s5 (Saat 1, GRENZE-Zwischenstaende) daran, dass c* IN der Zeile den Rest ueberwaechst?
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/merkmal/zeilenintern/kriterien_zeilenintern.txt, Kopf '2026-10-17, VOR der Rechnung' (Rechnung ~10:44)):
  Menge N = Zeilen tot bei t80k und nicht bei t60k. GESTUETZT: >= 80 % von N haben bei t80k Argmax in c* UND Median(d_r 80k / d_r 60k) >= 1,5 (d_r = |E[r,c*]| / groesster anderer Eintrag). NICHT GESTUETZT: < 50 % Argmax in c*. Sonst kein Urteil; |N| < 5 traegt kein Urteil. Berichtet: rho-Verlauf (BIASALLE-Geraet) ueber alle 18 Staende, Schritt des ersten rho >= +0,3 gegen den Sprung bei 70k. Geraetepruefung: tot = quant_sonde; Rot-Probe c* = 0.
Baut auf: snai/merkmal-grenze, snai/merkmal-biasalle
Darauf baut: snai/merkmal-gradrest
Rezepte:
  r124 [2026-10-21] python3 ~/snai_pruef/merkmal/zeilenintern/zeilenintern.py (Geraet A); biasalle/mess_bias.sh (Geraet B, rho)
      quelltext: zeilenintern.py 81d1ca93, biaskanal.py 96b2cb9a
      parameter: 18 Staende: Original s4, 16 GRENZE-Zwischenstaende, Original s5; Nachtrag: Originale s3_s4/s5/s7, s2_s4/s7
      seed: -
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/merkmal/zeilenintern/stand_cs32.jsonl, zeilen_cs*.json, urteil.txt, beobachtung.txt, rho.txt, vergleich_saaten.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/merkmal/zeilenintern/urteil.txt, beobachtung.txt, vergleich_saaten.txt (abgelesen 2026-10-21)
  m1342 abs(N) | 13 | GRENZE Saat 1 | 1 | 1
  m1343 Argmax in c* bei t80k | 13/13 = 100 % | N | 1 | 13
  m1344 Median d_r 80k/60k | 1,12 | N | 1 | 13
  m1345 Median abs(E c*) 80k/60k | 1,16 (lebend 1,175) | N | 1 | 13
  m1346 Median Rest 80k/60k | 0,58 (lebend 0,90) | N | 1 | 13
  m1347 rho bis t60k / t70k / t80k / t90k / Ende | -0,39 / -0,08 / +0,29 / +0,43 / +0,44 | GRENZE | 1 | 5
  m1348 AUC t0-Rest-Median sagt tot am Ende voraus | 0,973 (fuer 'kleiner Rest') | Beobachtung | 1 | 78
  m1349 gemeinsame tote Zeilen s1_s5 / s3_s5 | 21 von 22 bzw. 37 (Zufall 10,4) | Beobachtung Saaten 1 und 3 |  | 2
  m1350 AUC Saat-1-Rest bei s4 sagt Saat-3-Tote | 0,91 | Beobachtung Saaten 1 und 3 |  | 1
Ergebnis e118 [2026-10-21 19:16]: keine_aussage
  Fazit: Kein Urteil nach Regel (Argmax-Bedingung erfuellt, Dominanz steigt nur x1,12). Inhaltlich: c* setzt in den sterbenden Zeilen die Skala, waechst dort aber nicht staerker als anderswo; die Form 'c* waechst' ist damit widerlegt. Zwei Beobachtungen tragen weiter: rho kippt erst mit oder nach dem Formfehler-Sprung (laeuft nicht voraus, also eher Folge als Ausloeser), und die spaeter toten Zeilen sind am gesunden Start erkennbar und ueber die Saaten weitgehend dieselben Token. Die Saat bestimmt nur den Abstand zur Schwelle.
  Offen: Die Groesse d_r (gegen den zweitgroessten Eintrag) war fuer die Tot-Definition schlecht gewaehlt; 'Rest schmilzt' gilt fuer den Median, nicht die Summe (siehe snai/merkmal-gegenhalt). Ein früherer Zwischenbefund ist in diese Reihe eingegangen.
  Datei: rechner-a:~/snai_pruef/merkmal/zeilenintern/kriterien_zeilenintern.txt
Chronik:
  2026-10-21 14:35 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/merkmal/zeilenintern/kriterien_zeilenintern.txt, Kopf '2026-10-17, VOR der Rechnung' (Rechnung ~10:44))
  2026-10-21 19:16 Rezept r124
  2026-10-21 19:16 Status geplant -> laeuft (Rezept r124)
  2026-10-21 19:16 Messwerte m1342-m1350
  2026-10-21 19:16 Ergebnis e118: keine_aussage
  2026-10-21 19:16 Status laeuft -> ausgewertet (Ergebnis e118)
```
