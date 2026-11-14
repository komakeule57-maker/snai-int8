# snai/prod512b-frankreich-eingriff

```text
snai/prod512b-frankreich-eingriff - ausgewertet, angelegt 2026-11-06, zuletzt 2026-11-06 12:58
Frage: Ist die Attention von Block 3 (bzw. ein Kopf darin) notwendig für die Kopie wiederholter Füller in prod512b s11, während der Einstieg König erhalten bleibt?
Kriterium (festgelegt 2026-11-06 12:13, vor dem ersten Messwert):
  Eingriffs-Lib 0a1f48b4 (cortex.nim f8292f7b + Lens- und Abl-Patch, nur cortex_forward_i8), sonde_fr.php an s11, 18 T3-Posten + 30 Held-out-Absätze. Arme A0, ATT0-5, FFN3, K30-K37, Stufe 2 alle 28 Kopfpaare von Block 3 nur ohne Einzelkopf-Treffer. q = Stellen mit P_N(6) < 0,1 (von 18), e = Länder mit P(König k0) >= 0,5 x A0 (von 6), dNLL = NLL-Anstieg je Token. KAEE: q >= 15, e >= 5, dNLL < 1,0. Frage 1 NOTWENDIG: ATT3 KAEE und kein anderer ATTl q >= 15. Frage 2: Einzelkopf KAEE, sonst Paar, sonst VERTEILT. Kontrollen: A0 = frühere Messung (Abweichung 0), ATT9 = A0. Volltext KRITERIEN_eingriff.md.
Plan: rechner-a:~/snai_pruef/frankreich/eingriff/KRITERIEN_eingriff.md
Baut auf: snai/prod512b-frankreich-lens
Darauf baut: snai/prod512b-kopierkoepfe-blick
Rezepte:
  r616 [2026-11-06] cd ~/snai_pruef/frankreich/eingriff && bash ./lauf_eingriff.sh "NAME:ATT:FFN:KOPF" ...  (Arme A0::: ATT0:0:: .. ATT5:5:: FFN3::3: K30:::30 .. K37:::37, Stufe 2 P3ab:::3a3b); python3 auswert_eingriff.py [--paare]; Nachmessung bash ./lauf_frisch.sh; Freitext bash ./frei.sh
      quelltext: Eingriffs-Lib eingriff/bau/libcortex_abl.so 0a1f48b4 = cortex.nim f8292f7b + patch_lens.py + eingriff/patch_abl.py; sonde_fr.php 466fc902; posten_eingriff.json (aufbau_eingriff.py), posten_frisch.json
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/frankreich/eingriff/ (arme/, frisch/, frei/, rc.log, verworfen/)
      notiz: Zwei Startfehler verworfen und neu gefahren (rc.log): A0 lief zuerst mit der ganzen Armliste als Kopfschalter (zsh zerlegt $A nicht); Stufe 2 zuerst als Einzelkoepfe ($a3 als Variable gelesen). Beides hat die Kontrolle gemeldet (NLL-Abweichung A0, Fehlerkanal-Sollzeile).
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/frankreich/eingriff/urteil_stufe1.txt, urteil_stufe2.txt, frisch/ (auswert_eingriff.py)
  m9361 A0 NLL je Token, 30 Held-out-Absätze | 3,7194 | A0
  m9362 ATT3 q / e / dNLL | 18/18, 0/6, +0,303 | ATT3
  m9363 ATT2 q / e / dNLL | 15/18, 2/6, +0,418 | ATT2
  m9364 ATT0, ATT1, ATT4, ATT5 q | 0, 0, 0, 1 von 18 | ATT0-5
  m9365 FFN3 q / dNLL | 0/18, +0,096 | FFN3
  m9366 K36 q / e / dNLL, mittl. ln(P6/A0) König | 8/18, 6/6, +0,141, -1,68 | K36
  m9367 K30 mittl. ln(P6/A0) König | -0,69 | K30
  m9368 übrige Einzelköpfe Block 3 mittl. ln(P6/A0) | -0,05 bis +0,03 | K31-K35,K37
  m9369 P306 q / e / dNLL | 18/18, 6/6, +0,212 | P306
  m9370 P306 König k0 x A0 | 0,56 bis 0,62 | P306
  m9371 P306 P_N(6) Spanne | 0,007 bis 0,048 | P306
  m9372 nächstbestes Paar q | 11/18 (P336) | Stufe 2
  m9373 Nachmessung frische Länder P306 q / e | 18/18, 6/6 (König k0 x 0,54 bis 0,66) | P306 | frisch
  m9374 Hinreichend H306 (nur 3.0 und 3.6 an) P_N(6) Hauptposten | 0,25 bis 0,87 (A0 0,25 bis 0,88), dNLL +0,094 | H306
Ergebnis e562 [2026-11-06 12:58]: teilweise
  Fazit: Frage 2 erfüllt: Das Kopfpaar 3.0 + 3.6 trägt die Kopie. Abgeschaltet verschwindet sie an 18/18 Stellen (auch an 6 frischen Ländern), der Einstieg König bleibt (0,54-0,66x), dNLL +0,21; mit nur diesen beiden Köpfen in Block 3 kopiert das Modell unverändert. In freier Erzeugung sind beide Schleifen weg (Vielfalt 0,134 -> 0,719 bzw. 0,422 -> 0,584). Frage 1 nach Wortlaut nicht NOTWENDIG: Die ganze Block-3-Attention nimmt den Einstieg mit (e 0/6), und auch Block 2 (ATT2 q 15/18) ist nötig, der Kreis reicht über zwei Schichten. Abschalten ist keine Reparatur (+0,21 nats), aber das Ziel für jede weitere Maßnahme gegen die Schleifen ist benannt.
  Offen: Welcher Kopf in Block 2; Dämpfen statt Abschalten (Faktor 0,25-0,5); ob 3.0/3.6 bei s12-s15 dieselben bleiben; wie viel von dNLL erwünschtes Kopieren ist.
  Datei: rechner-a:~/snai_pruef/frankreich/eingriff/ERGEBNIS_eingriff.md
Chronik:
  2026-11-06 12:13 angelegt
  2026-11-06 12:44 Rezept r616
  2026-11-06 12:44 Status geplant -> laeuft (Rezept r616)
  2026-11-06 12:44 Messwerte m9361-m9374
  2026-11-06 12:58 Ergebnis e562: teilweise
  2026-11-06 12:58 Status laeuft -> ausgewertet (Ergebnis e562)
```
