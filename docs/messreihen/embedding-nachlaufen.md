# snai/embedding-nachlaufen

```text
snai/embedding-nachlaufen - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-03 03:56
Frage: Liegt die Embedding-Norm beim Abkühlen über dem Gleichgewicht, weil sie der sinkenden LR nur nachläuft (Kosson et al., arXiv:2305.17212), oder wirkt zusätzlich ein Zug nach außen? Kein Training. Vorschlag snai_int8_lora.
Kriterium (festgelegt 2026-11-02 20:08, vor dem ersten Messwert):
  Teil 1, Rekursion ohne Lauf: E²(t+1) = (1 - LR·WD)² E² + c² LR², WD 0,1, Start RMS E s4, c = E(s4) / Wurzel(LR/(2 WD)) = 0,91, LR-Plan und adam_t aus Protokoll und Sonde (s5 7,5e-4, s6 5e-4, s7 2,5e-4, s8 1e-4, s9 5e-5, je 153.241 Schritte). NACHLAUFEN GENÜGT: E² gemessen/vorhergesagt in [0,9; 1,1] an s5 bis s9. NICHT GENÜGT: an s8 oder s9 außerhalb [0,8; 1,25]. Sonst OFFEN. Vorab bekannt: Überschlag aus je dem Vorstand ergab s8 und s9 deutlich zu klein, die Erwartung ist also NICHT GENÜGT.
Teil 2, Bilanz aus den Ständen: u = m/Wurzel(v), Momente aus der Datei, Embeddings. R = <w,u>/<w,w>, Wirkrate 2·LR·(WD + R). ZUG NACH AUSSEN: -R >= 0,2·WD an s8 und s9, also Decay um mindestens ein Fünftel aufgehoben, und an s0, s4 kleiner als an s8. KEIN ZUG: |R| < 0,1·WD an s8 und s9. Sonst OFFEN. Daneben K = 19·Mittel(u²) als grobes Maß für c², nur Beobachtung, setzt Rauschen mit Beta1 0,9 voraus. Klassen nach mittlerem v je Zeile, drei Drittel, Stellvertreter für Häufigkeit, nur Beobachtung.
Rot: Zeilen von u zufällig vertauscht: R etwa 0. u mit Vorzeichen getauscht: R kippt. Ein Modell, eine Saat. Auch ZUG ist keine Ursache, sondern ein Term der Bilanz; dass der Gradient die Logit-Skala treibt, ist Deutung.
Freie Parameter: c aus s4, Schwellen, Faktor 19.
Baut auf: snai/skalenwanderung-final, snai/gradnorm-skala, snai/v-klebt
Darauf baut: snai/vorhersage-ffn-arme, snai/adamc-dc
Rezepte:
  r534 [2026-11-02] cd ~/snai_pruef/gradnorm/proj_gn; php -d memory_limit=-1 ../werkzeug/bilanz_emb.php factory/checkpoints/chin_c128sr_<s>.snai [rot_tausch|rot_vz]; Rekursion inline in Python, E²(t+1) = (1 - LR·WD)² E² + c² LR²
      quelltext: werkzeug/bilanz_emb.php, tensor_io.php aus proj_gn
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/gradnorm/log/bilanz.jsonl
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/gradnorm/log/bilanz.jsonl; Fehlerkanal leer; Rekursion c 0,9098
  m7831 E² gemessen/vorhergesagt | 0,996 | s5
  m7832 E² gemessen/vorhergesagt | 0,970 | s6
  m7833 E² gemessen/vorhergesagt | 1,107 | s7
  m7834 E² gemessen/vorhergesagt | 1,651 | s8
  m7835 E² gemessen/vorhergesagt | 2,235 | s9
  m7836 R | -0,071/-0,083/-0,118/-0,131/-0,011/-0,050/-0,057 | s0,s4,s5,s6,s7,s8,s9
  m7837 K | 0,75/0,92/0,91/0,90/0,73/0,96/0,85 | s0,s4,s5,s6,s7,s8,s9
  m7838 R Rot Vorzeichen, Zeilen vertauscht | +0,0496, +0,018 | s8
Ergebnis e471 [2026-11-02 20:10]: teilweise
  Fazit: Teil 1 NICHT GENÜGT: Nachlaufen erklärt den Embedding-Überschuss nicht; bis s6 passt das Gleichgewicht, an s8 und s9 liegt E² 1,65- und 2,2-fach darüber. Der Überschuss entsteht nur bei kleiner LR. Teil 2 OFFEN und als Messgröße untauglich: R ist schon durch Rauschen negativ (w enthält die vergangenen gleitend gemittelten u), einzelne Stände können keinen Zug nach außen zeigen. Nur ein Abkühlarm im reinen Float trennt Zug nach außen von 8-Bit-Speicherung.
  Offen: Zug nach außen gegen 8-Bit-Speicherung bei sehr kleinen Schritten. Kein Lauf gestartet. Eine Saat. Häufigkeitsklassen nur über mittleres v, zu verrauscht für eine Aussage.
  Datei: rechner-a:~/snai_pruef/gradnorm/ERGEBNIS_embedding_nachlaufen.md
Chronik:
  2026-11-02 20:08 angelegt
  2026-11-02 20:10 Rezept r534
  2026-11-02 20:10 Status geplant -> laeuft (Rezept r534)
  2026-11-02 20:10 Messwerte m7831-m7838
  2026-11-02 20:10 Ergebnis e471: teilweise
  2026-11-02 20:10 Status laeuft -> ausgewertet (Ergebnis e471)
  2026-11-03 03:56 2026-11-03, offene Frage aus e471 entschieden durch snai/torch-abkuehl-emb (Zweig snai_int8_lora, erfüllt): FLOAT WIE INT8, Q 1,70 bis 1,72 bzw. 1,56 bis 1,57, c aus TG geeicht. Der Embedding-Überschuss bei kleiner LR ist also kein 8-Bit-Thema, die Lesart "8-Bit-Speicherung" fällt. Es bleibt ein Mechanismus, der im Float wirkt (Zug nach außen oder anderes). Er ist nicht isoliert. Daneben aus snai/v-ueberhang: Beta2 0,99 hebt E auf 1,37 x (B2, 4 Saaten), Adams Gedächtnis wirkt also auf die Skala.
```
