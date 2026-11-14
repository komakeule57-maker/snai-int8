# snai/skalenwanderung-final

```text
snai/skalenwanderung-final - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-03 11:00
!! ohne Rezept
Frage: Wandert beim Abkühlen die Skala aus den Embeddings in die Final-Gain, bleibt also RMS(emb) mal RMS(g_final) ungefähr gleich, während g_final ab s5 wächst? Vorschlag aus dem Zweig snai_int8_lora. Kein Training.
Kriterium (festgelegt 2026-11-02 18:23, vor dem ersten Messwert):
  Messgröße: P(x) = RMS emb(x) mal RMS g_final(x), geteilt durch denselben Wert an s4. Sonde werkzeug/sonde_staende.php (aus der Datei, Rot sonde_rot.php Halbierung). Stände c128sr s0 bis s9. Urteil an s5 bis s9, ein Modell und eine Saat.
WANDERUNG: P in [0,8; 1,25] an allen fünf Ständen. KEINE WANDERUNG: P(s9) >= 1,5, also Embeddings gleichen höchstens rund die Hälfte des g_final-Anstiegs aus. Sonst OFFEN. Innerhalb 5 % um eine Schwelle gilt nicht als erfüllt.
Daneben, gleiche Schwellen, zweite Linie mit drei Datenreihenfolgen: dc_K1_r1-3 gegen s4 (Fortsetzung ab s4, LR 2,5e-4, 30.000 Fenster); Beobachtung dc_G_r1-3 (Decay auch auf Gains). s0 bis s4 zeigen den Abschnitt ohne Abkühlen.
Eine Saat trägt keinen allgemeinen Schluss; Replikation über 8 Saaten bei konstanter LR liefern T2/U2 aus snai/tying-gains-lang.
Reichweite und Grenze, vorab: Auch WANDERUNG belegt keine Ursache. Ein flaches Produkt kann auch heißen, dass die Daten die Logit-Skala festlegen, gleich wodurch E schrumpft. Dass Decay die Wanderung treibt, zeigt nur ein Eingriff (snai/wdg-final oder Decay aus auf Embeddings). Die Lesart Standardabweichung statt RMS wird nicht getrennt, E ist nahezu mittelwertfrei angenommen; wird mitberichtet, falls nicht.
Freie Parameter: Bezug s4, Schwellen, RMS über alle Embedding-Einträge statt je Spalte.
Baut auf: snai/wdg-norm, snai/skala-norm
Darauf baut: snai/wdg-final, snai/genesis-norm, snai/embedding-nachlaufen, snai/prod512b-gains-abkuehlen
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/gradnorm/log/sonde_wand.jsonl, g_final aus log/final_rms.txt, Fehlerkanal leer bis auf s1-s3 (Stände dort nicht vorhanden)
  m7714 RMS emb | 0,06447 | s0
  m7715 RMS emb | 0,06433 | s4
  m7716 RMS emb | 0,0556 | s5
  m7717 RMS emb | 0,0448 | s6
  m7718 RMS emb | 0,03385 | s7
  m7719 RMS emb | 0,02704 | s8
  m7720 RMS emb | 0,02401 | s9
  m7721 P | 0,955 | s0
  m7722 P | 1,038 | s5
  m7723 P | 1,080 | s6
  m7724 P | 1,115 | s7
  m7725 P | 1,081 | s8
  m7726 P | 1,065 | s9
  m7727 P | 0,954 | dc_K1 | r1
  m7728 P | 0,954 | dc_K1 | r2
  m7729 P | 0,953 | dc_K1 | r3
  m7730 P | 0,771 | dc_G | r1
  m7731 P | 0,768 | dc_G | r2
  m7732 P | 0,773 | dc_G | r3
  Quelle: Nachträglich, kein Kriterium: rechner-a:~/snai_pruef/gradnorm/log/sonde_sk.jsonl und gf_sk_*.log aus snai/gradnorm-skala, ab s8, 30.000 Fenster, gegen Arm T. g aus Mittel |g|. Reihenfolge r1/r2/r3.
  m7753 P gegen T (mittel g) | 1,795/1,805/1,798 | H LR 1e-3
  m7754 P gegen T (mittel g) | 0,554/0,557/0,557 | Z WD 1
  m7755 P gegen T (mittel g) | 1,205/1,203/1,200 | W WD 0
  m7756 Q_F = emb-Norm² gegen T durch g² | 0,278/0,307/0,280 | H LR 1e-3
  m7757 Q_F = emb-Norm² gegen T durch g² | 1,755/1,755/1,683 | Z WD 1
  m7758 Q_F = emb-Norm² gegen T durch g² | 1,199/0,966/0,942 | W WD 0
  m7759 Q_E = emb-Norm² gegen T mal E² | 0,898/1,001/0,906 | H LR 1e-3
  m7760 Q_E = emb-Norm² gegen T mal E² | 0,539/0,545/0,522 | Z WD 1
  m7761 Q_E = emb-Norm² gegen T mal E² | 1,741/1,398/1,356 | W WD 0
  Quelle: Prüfung der Vorhersage aus dem Nachtrag 2026-11-03 05:46 (F2 auf frischen Daten): |g_E|² (E2, Mittel über 64 Held-out-Fenster, Torch-float, Forward ≤0,0011 nats gegen Engine) aus rechner-b:~/snai_pruef/clip_torch/f2/grad.jsonl (snai/f2-emb-gradteil), g_final = Mittel Betrag rms_final aus f2/dump/T2_s*_{t9000,ende}.bin; Q_F = (E2 Ende/E2 t9000)/(g Ende/g t9000)². Regel: [0,8; 1,25] in >= 6/8 BESTÄTIGT. Ergebnis 7/8 drin, auch mit 5-%-Abstand zur Schwelle 7/8: BESTÄTIGT. Ausgerechnet von SnAI Evo 2026-11-03 11:05.
  m8249 Q_F T2 Ende gegen t9000 (mittel g) | 0,777 | T2 | 4 | 64
  m8250 Q_F T2 Ende gegen t9000 (mittel g) | 0,850 | T2 | 5 | 64
  m8251 Q_F T2 Ende gegen t9000 (mittel g) | 0,963 | T2 | 6 | 64
  m8252 Q_F T2 Ende gegen t9000 (mittel g) | 0,917 | T2 | 7 | 64
  m8253 Q_F T2 Ende gegen t9000 (mittel g) | 0,917 | T2 | 8 | 64
  m8254 Q_F T2 Ende gegen t9000 (mittel g) | 1,040 | T2 | 9 | 64
  m8255 Q_F T2 Ende gegen t9000 (mittel g) | 0,847 | T2 | 10 | 64
  m8256 Q_F T2 Ende gegen t9000 (mittel g) | 0,849 | T2 | 11 | 64
  m8257 Q_F in [0,8; 1,25] | 7/8 | T2 | 4-11 | 8
  m8258 g_final mittel t9000 bis Ende | 0,778-0,804 bis 0,912-0,929 | T2 | 4-11 | 8
Ergebnis e468 [2026-11-02 18:26]: erfuellt
  Fazit: WANDERUNG nach Wortlaut gilt entlang des Abkühlens: P an s5 bis s9 1,04 bis 1,12, dc_K1 0,95 in 3/3. Als Gesetz oder Mechanismus trägt sie nicht: Die Eingriffsarme aus snai/gradnorm-skala brechen das Produkt (LR hoch 1,8, WD 1 0,55, WD 0 1,2 gegen T, 3/3, 30.000 Fenster, Beobachtung). Weil P entlang des Laufs fast 1 ist, sind g² und 1/E² dort nicht zu trennen; deshalb sagt das Q_F von rund 1 an s6, s8, s9 nichts darüber, welche von beiden die Embedding-Norm bestimmt. In den Armen stimmt Q_F nicht (H 0,28 bis 0,31, Z 1,68 bis 1,76), 1/E² auch nicht allgemein (H 0,90 bis 1,00, Z 0,52 bis 0,55, W 1,36 bis 1,74). Die Final-Gain als Hebel für die Norm ist damit stark geschwächt. snai/wdg-final wird nicht allein wegen Q_F gestartet.
  Offen: Eine Saat, s1 bis s3 fehlen. Arme laufen nur 30.000 Fenster ab s8, g bewegt sich dort langsam, und der Held-out unterscheidet sich (H, Z schlechter), also kein eingeschwungener Vergleich. Lange Armvergleiche fehlen. vo und ffn weiter offen. T2/U2 als Replikation bei konstanter LR.
  Datei: rechner-a:~/snai_pruef/gradnorm/log/sonde_wand.jsonl
Abgeloest und ausgeblendet: 1 ergebnis - voll=True zeigt sie.
Chronik (juengste 8 von 10, voll=True zeigt alle):
  2026-11-02 18:25 Status geplant -> laeuft (Messwerte m7714-m7732)
  2026-11-02 18:25 Ergebnis e466: erfuellt
  2026-11-02 18:25 Status laeuft -> ausgewertet (Ergebnis e466)
  2026-11-02 18:26 Messwerte m7753-m7761
  2026-11-02 18:26 Ergebnis e468: erfuellt, loest e466 ab
  2026-11-03 05:46 Nachtrag 2026-11-03, Daten aus snai/tying-gains-lang (e484, snai_int8_lora, Torch float32, LR 0,003 konstant, 8 Saaten), Beobachtung: Die Wanderung braucht kein Abkühlen. Gebunden (T2) von Schritt 9000 bis 27018 E 0,1143 auf 0,1104, g_final 0,858 auf 1,002, P = E·g 0,0981 auf 0,1106 (1,13 x), bei konstanter LR. Ungebunden (U2) wachsen E und g_final beide. Deutung, nicht gemessen: Unter Bindung holt sich das Modell die Ausgabeskala über g_final, weil E zugleich Eingang ist. Vorhersage für eine frische Prüfung der Beziehung aus snai/norm-je-tensor (F2, s7 dort knapp), festgelegt vor jeder Messung: Norm² emb (LR 0, gleiche Fenster) T2 27018 gegen 9000 geteilt durch (g_final 27018 / g_final 9000)² liegt in [0,8; 1,25] in >= 6/8 Saaten. Dann F2 auf frischen Daten BESTÄTIGT, liegt der Wert in <= 2/8 drinnen, WIDERLEGT, sonst OFFEN. Nicht gestartet.
  2026-11-03 05:46 Korrektur zum Nachtrag von heute (Wortlaut dort bleibt): snai/tying-gains-lang lief in der Engine (K1-Rezept, voll int8, SR, Karte rechner-b), nicht im Torch-Nachbau float32. Zahlen und Vorhersage gelten unverändert. Messweg laut snai_int8_lora: T2-Stände nach V5 dequantisiert, gradteil.py im Torch-Nachbau, vorher Abgleich Torch-Loss gegen Engine-Loss an denselben Fenstern (bei Abweichung ungültig). Das ist ein anderes Messgerät als bei F2 (Engine-Sonde mit Ganzzahl-Rückwärtspfad). Fällt die Prüfung WIDERLEGT aus, wird das vor jedem Zitat mit der Engine-Sonde nachgemessen.
  2026-11-03 11:00 Messwerte m8249-m8258
```
