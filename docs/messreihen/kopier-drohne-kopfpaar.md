# snai/kopier-drohne-kopfpaar

```text
snai/kopier-drohne-kopfpaar - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 11:23
Frage: An welchen Köpfen hängt das Kopieren in Drohne E s3 und S s2: an einem Kopf, an einem Kopfpaar, und genügt das Paar allein?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt (Ausnahme: der Boden „Kopf 0.1 an“ für Arm S wurde als Arm vorab vorgesehen, als Maßstab erst nach dem Ergebnis gewählt)):
  Einzelkopf-Ablation, Messgröße Loss der Klasse „Folge & selten“: K1 Träger = Ausschalten kostet mehr als die Hälfte des Abstands zum Stand ein Segment davor und kein anderer Kopf mehr als ein Viertel; K2 spezifisch = „Ziel neu“ wird um weniger als ein Fünftel davon schlechter. Gegenversuch (alle Köpfe gleichverteilt außer einer Liste), Messgröße V = Loss(Token, selten) - Loss(Folge, selten): G1 Paar genügt, wenn (V_nurPaar - V_Boden) > 0,5 x (V_ohneEingriff - V_Boden), genügt nicht unter 0,1; G2 jeder Kopf allein unter der Hälfte des Paar-Anteils; Rot 1 falsches Paar unter 0,1; Rot 2 alle 16 Köpfe auf der Liste bytegleich zu „kein Eingriff“.
Baut auf: snai/kopier-drohne-e-s3
Darauf baut: snai/kopier-knirps-leiter
Rezepte:
  r34 [2026-10-21] k. A. (Aufruf nicht im Eintrag; Skripte diagnose/qk_pruef/kopf_ablation.sh und diagnose/qk_pruef/paar_gegenversuch.sh, Auswertung tools/wiederholung_loss.py)
      parameter: Drohne Arm E Segment 3 und Arm S Segment 2; je 100 Fenster zu 512 Token. Ablation: je Lauf EIN Kopf auf gleichverteilte Attention. Gegenversuch: alle Köpfe gleichverteilt außer Liste (SNAI_QK_AUSSER=„schicht.kopf,...“ in patch_qk.py, mit SNAI_QK_MODUS 5..7)
      rechner: rechner-a
      logs: Projektdokument Abschnitt 6i
Messwerte (Groesse | Wert | Arm | Start | n):
  m276 Loss „Folge & selten“ ohne Eingriff (Segment davor) | 3,38 (s2: 5,12) | E s3 |  | 100
  m277 Loss „Folge & selten“ bei Kopf aus 3.2 / 2.1 / 2.3 / 1.0 | 5,10 / 4,64 / 3,98 / 3,69; übrige 12 höchstens +0,08 | E s3 |  | 100
  m278 Gesamtloss mit 3.2 aus | 4,905 (ohne Eingriff 4,672, s2 4,954) | E s3 |  | 100
  m279 Loss „Folge & selten“ bei Kopf aus 1.2 / 2.3 | 6,47 / 6,13 (ohne Eingriff 4,24, s1 5,56) | S s2 |  | 100
  m280 Gegenversuch V-Anteil nur Paar 2.1+3.2 | 55 % (V 2,012; ohne Eingriff 2,718, alle aus 1,157) | E s3 |  | 100
  m281 Gegenversuch nur 3.2 / nur 2.1 / falsches Paar 2.0+3.0 | -4 % / 5 % / 3 % | E s3 |  | 100
  m282 Gegenversuch 2.1+2.3+3.2 / dazu 1.0 | 100 % / 119 % | E s3 |  | 100
  m283 Gegenversuch (Boden Kopf 0.1 an) 0.1+1.2+2.3 | 52 % | S s2 |  | 100
  m284 Gegenversuch 0.1+2.3 / 0.1+1.2 / falsches Paar / 0.1+0.2+1.2+2.3 | 0 % / 11 % / 1 % / 82 % | S s2 |  | 100
Ergebnis e31 [2026-10-21 11:23]: teilweise
  Fazit: K1 in der strengen Form in keinem Modell erfüllt (zwei Köpfe über der Hälfte), K2 für die Paare erfüllt; G1, G2 und Rot 1 erfüllt. Das Kopieren hängt an einem Kopfpaar in zwei benachbarten Schichten (E: 2.1+3.2, mit 2.3 voll; S: 1.2+2.3), nicht an einem Kopf; die Lage ist nicht fest. Direkter Beleg, dass der Kopier-Schaltkreis zwei benachbarte Schichten braucht und nicht mehr: das stützt Knirpse mit zwei Schichten als Versuchstier. Der obere Kopf ist jeweils der, den der Prefix-Score unabhängig fand.
  Offen: Was der untere Kopf tut (Attention-Muster). Arm S: Boden „alle aus“ entartet; der Boden „Kopf 0.1 an“ wurde erst nach dem Ergebnis als Maßstab gewählt.
Chronik:
  2026-10-21 11:22 angelegt (Nachtrag: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt (Ausnahme: der Boden „Kopf 0.1 an“ für Arm S wurde als Arm vorab vorgesehen, als Maßstab erst nach dem Ergebnis gewählt))
  2026-10-21 11:22 Rezept r34
  2026-10-21 11:22 Status geplant -> laeuft (Rezept r34)
  2026-10-21 11:22 Messwerte m276-m284
  2026-10-21 11:23 Ergebnis e31: teilweise
  2026-10-21 11:23 Status laeuft -> ausgewertet (Ergebnis e31)
```
