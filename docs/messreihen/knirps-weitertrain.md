# snai/knirps-weitertrain

```text
snai/knirps-weitertrain - ausgewertet, angelegt 2026-10-24, zuletzt 2026-10-24 15:35
Frage: Senkt blosses Weitertrainieren (Arm M: natuerlicher Text, LR 1e-4 konstant, Adam neu) die Schleifen in der Beam-Erzeugung wirklich, und liegt das an der LR-Hoehe (Basis drohneP_s19 endete bei 5,42e-5)?
Kriterium (festgelegt 2026-10-24 10:04, vor dem ersten Messwert):
  Entscheidend nur 8 NEUE Prompts (Beam 3, 256 Token), Mass U (unscharf.py ff3999bd, K=2 von 8), laengengleich je Prompt auf die kleinere Wortzahl gekuerzt; 3 Saaten. B1 Befund echt: U8_M <= 0,9 U8_Basis in 3/3. B2 (nur wenn B1 ja): Arm L = M mit LR 5,42e-5 konstant. 'LR-Hoehe nicht Ursache (5,4e-5..1e-4)' = U8_L innerhalb +-10 % von U8_M in 3/3; 'LR-Sprung noetig' = U8_L >= 0,9 U8_Basis in 3/3; sonst saatabhaengig. Vorbefund auf den 4 alten Prompts (Laengen gleich, U M/Basis 0,80-0,82) ist gesehen und entscheidet nicht. Basis ein Modell. Volltext rechner-b:~/snai_pruef/ditto2/kriterien.txt 777c6b94.
Plan: rechner-b:~/snai_pruef/ditto2/kriterien.txt
Baut auf: snai/ditto-knirps
Darauf baut: snai/schleife-einstieg
Rezepte:
  r406 [2026-10-24] wie r403, Ordner jetzt rechner-b:~/snai_pruef/ditto3
      quelltext: wie r403; Pfad ditto2->ditto3 per sed: arm.sh f64851eb, mess2.sh d51c0d7f, auswert2.py d29d3bad
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/ditto3/mess/{basis,M_s*,L_s*}
      notiz: 2026-10-24 umbenannt (Kollision mit SnAI_Evo); Pfade in e353 liegen jetzt unter ditto3.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/ditto2/auswert2.py 81bd96a2 (REIHE B), mess/{basis,M_s*,L_s*}
  m4992 U8 laengengleich M | 0,502 | M | 1 | 8
  m4993 U8 laengengleich Basis (gegen M_s1 gekuerzt) | 0,430 | Basis | 1 | 8
  m4994 U8 laengengleich M | 0,470 | M | 2 | 8
  m4995 U8 laengengleich Basis (gegen M_s2 gekuerzt) | 0,440 | Basis | 2 | 8
  m4996 U8 laengengleich M | 0,470 | M | 3 | 8
  m4997 U8 laengengleich Basis (gegen M_s3 gekuerzt) | 0,432 | Basis | 3 | 8
  m4998 U8 laengengleich L | 0,408 | L | 1 | 8
  m4999 U8 laengengleich L | 0,441 | L | 2 | 8
  m5000 U8 laengengleich L | 0,485 | L | 3 | 8
  m5001 U alte 4 Prompts | 0,473 | Basis |  | 4
  m5002 U alte 4 Prompts | 0,457 | M | 1 | 4
  m5003 U alte 4 Prompts | 0,352 | M | 2 | 4
  m5004 U alte 4 Prompts | 0,397 | M | 3 | 4
  m5005 W alte 4 Prompts | 0,371 | Basis |  | 4
  m5006 W alte 4 Prompts | 0,218 | M | 1 | 4
  m5007 W alte 4 Prompts | 0,214 | M | 2 | 4
  m5008 W alte 4 Prompts | 0,216 | M | 3 | 4
  m5009 Held-out 200 Fenster | 4,1229 | Basis |  | 200
  m5010 Held-out 200 Fenster | 4,2366 | M | 1 | 200
  m5011 Held-out 200 Fenster | 4,2435 | M | 2 | 200
  m5012 Held-out 200 Fenster | 4,2368 | M | 3 | 200
  m5013 Held-out 200 Fenster | 4,1324 | L | 1 | 200
  m5014 Held-out 200 Fenster | 4,1289 | L | 2 | 200
  m5015 Held-out 200 Fenster | 4,1252 | L | 3 | 200
  m5016 Z = TP4-TP1 | 0,1433 | Basis |  | 50
  m5017 Z = TP4-TP1 | 0,119 | M | 1 | 50
  m5018 Z = TP4-TP1 | 0,098 | M | 2 | 50
  m5019 Z = TP4-TP1 | 0,113 | M | 3 | 50
  m5020 Z = TP4-TP1 | 0,126 | L | 1 | 50
  m5021 Z = TP4-TP1 | 0,112 | L | 2 | 50
  m5022 Z = TP4-TP1 | 0,119 | L | 3 | 50
Ergebnis e353 [2026-10-24 12:38]: verfehlt
  Fazit: Der Nebenfund aus snai/ditto-knirps haelt nicht: Auf 8 frischen Prompts schreibt M (Weitertraining) in 3/3 Saaten eher mehr Schleifen als die Basis (U 0,47-0,50 gegen 0,43-0,44), B1 0/3, B2 entfaellt. Die alte "Halbierung" war eine Eigenheit der 4 Prompts, verstaerkt durch W, das nur wortgleiche Wiederholung zaehlt. Je Prompt streut U von 0,06 bis 0,75, deshalb tragen 4 Prompts keinen Unterschied von 20 %. Faden geschlossen. Nebenbei: Weitertraining mit LR 1e-4 kostet +2,8 % Held-out, mit der End-LR 5,42e-5 nur +0,2 %.
  Offen: Warum Z in M und L um 12-32 % unter der Basis liegt, ist nicht entschieden (Basis ist nur ein Modell). Wie viele Prompts eine Beam-Messung braucht, ist nicht bestimmt.
  Datei: rechner-b:~/snai_pruef/ditto2/ERGEBNIS_weitertrain.md
Abgeloest und ausgeblendet: 1 rezept - voll=True zeigt sie.
Chronik:
  2026-10-24 10:04 angelegt
  2026-10-24 10:07 Rezept r403
  2026-10-24 10:07 Status geplant -> laeuft (Rezept r403)
  2026-10-24 12:38 Messwerte m4992-m5022
  2026-10-24 12:38 Ergebnis e353: verfehlt
  2026-10-24 12:38 Status laeuft -> ausgewertet (Ergebnis e353)
  2026-10-24 15:35 Rezept r406, loest r403 ab
```
