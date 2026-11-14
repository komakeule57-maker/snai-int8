# snai/v-klebt

```text
snai/v-klebt - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 07:13
Frage: Wie viele Elemente stecken an vorhandenen Ständen im Zustand "v gespeichert als 0, m ungleich 0", in dem der nächste Adam-Schritt bis 31,6-mal zu groß wird? Nicht gefragt: ob das schadet oder die Norm treibt.
Kriterium (festgelegt 2026-11-02 07:11, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/vklebt/kriterien.txt. A = Anteil v==0 und m!=0 je Gruppe emb, qk, vo, ffn, Stände chin_c128sr s0, s4-s9. RANDFEHLER: A < 0,1 % überall. RELEVANT: A >= 1 % in mindestens einer Gruppe auf mindestens zwei Ständen, dann gepaarter Lauf. Sonst DAZWISCHEN; gepaarter Lauf nur, wenn A mit der Norm steigt. Innerhalb Faktor 1,5 an einer Schwelle = knapp. Kontrollen: rms (ungequantelt) A = 0; Rot 1 % der v in L0.w_up genullt muss A(ffn) um 0,5 % heben; Fehlerkanal leer. Ein Modell, eine Saat, keine Ursachenaussage.
Plan: rechner-a:~/snai_pruef/vklebt/kriterien.txt
Baut auf: snai/gradnorm-zerlegung
Darauf baut: snai/v-klebt-lauf, snai/tote-spalten-wachsen, snai/embedding-nachlaufen
Rezepte:
  r503 [2026-11-02] cd ~/snai_pruef/gradnorm/proj_gn; php -d memory_limit=1500M ~/snai_pruef/vklebt/vklebt.php <stand> [rot]; aufschluss.php <stand>
      quelltext: vklebt.php 79b0a9ce, kriterien.txt 83f6a4c0, aufschluss.php nach Sichtung der Hauptwerte (Beobachtung), tensor_io.php aus proj_gn
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/vklebt/erg.jsonl, auf.jsonl, erg.err
      notiz: Nur Lesen. Stände knirps_gpu/proj_sr/factory/checkpoints/chin_c128sr_s*.snai. Ein Modell, eine Saat.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/vklebt/erg.jsonl, auf.jsonl; Fehlerkanal 0 Byte. A = Anteil v==0 und m!=0 in Prozent.
  m7385 A emb / qk / vo / ffn | 0 / 0 / 0 / 0 | s0, s4, s5, s6
  m7386 A emb / qk / vo / ffn | 0 / 0,0053 / 0 / 0 | s7
  m7387 A emb / qk / vo / ffn | 0 / 0,6241 / 0,248 / 10,2547 | s8
  m7388 A emb / qk / vo / ffn | 0 / 3,1296 / 1,7303 / 10,9346 | s9
  m7389 A rms Negativkontrolle | 0 auf allen Ständen | s0, s4-s9
  m7390 Rot 1 % der v in L0.w_up genullt, A ffn | 0,1245 (Kriterium nannte 0,5, falsch gerechnet; ffn umfasst 8 Tensoren gleicher Größe, richtig 0,995/8 = 0,1244) | s4 rot
  m7391 Beobachtung L1.w_up A gesamt, tote / lebende Gain | 82,037; 90,524 / 0 | s8
  m7392 Beobachtung L1.w_up A gesamt, tote / lebende Gain | 87,477; 96,526 / 0 | s9
  m7393 Beobachtung L1 tote Gains von 128 | 116 | s7, s8, s9
  m7394 Beobachtung L2 tote Gains 128 von 128, A w_up | 0 | s7, s8, s9
  m7395 Beobachtung L0 A q / k / v | 12,024 / 13,013 / 13,843 | s9
Ergebnis e437 [2026-11-02 07:13]: erfuellt
  Fazit: RELEVANT nach Wortlaut (ffn über 10 % auf s8 und s9), der gepaarte Lauf ist damit fällig. Der Fehler ist kein Randfehler, aber nicht der Motor des Norm-Anstiegs: Von s4 bis s7 steigt die Norm von 2,98 auf 7,14, während A überall praktisch 0 ist. Er trifft fast nur tote w_up-Spalten neben lebenden in derselben Zeile (L1); L2 mit lauter toten Kanälen bleibt frei. Deutung, nicht gemessen: Der Zustand setzt ein, wenn der Gradient toter Spalten unter 1e-4 der lebenden fällt; Hauptwirkung wäre Rauschen in Spalten, deren Eingang ohnehin fast 0 ist. Das Kippen selbst kann er nicht auslösen, die Gains sind in L1 schon auf s7 tot, wo A 0 ist.
  Offen: Ob der Fehler Norm ab s8, Held-out oder das Wiederaufleben toter Gains beeinflusst: gepaarter Lauf ab s7. Warum A zwischen s7 und s8 springt und L0 ab s8 betroffen ist. Andere Saaten, prod512b. Abweichung: Rot-Sollwert im Kriterium falsch gerechnet, Wert stimmt mit der richtigen Rechnung.
  Datei: rechner-a:~/snai_pruef/vklebt/kriterien.txt
Chronik:
  2026-11-02 07:11 angelegt
  2026-11-02 07:12 Rezept r503
  2026-11-02 07:12 Status geplant -> laeuft (Rezept r503)
  2026-11-02 07:13 Messwerte m7385-m7395
  2026-11-02 07:13 Ergebnis e437: erfuellt
  2026-11-02 07:13 Status laeuft -> ausgewertet (Ergebnis e437)
```
