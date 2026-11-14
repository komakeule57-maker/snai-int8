# snai/neuronen-zensus

```text
snai/neuronen-zensus - ausgewertet, angelegt 2026-11-03, zuletzt 2026-11-03 07:47
Frage: Wie viele FFN-Neuronen je Schicht sind in fertigen Modellen tot, praktisch linear oder arbeitend? Stützt das die Deutung aus snai/torch-wup-mechanismus ("FFN-Zweig ohne wirksame Nichtlinearität wird abgebaut")?
Kriterium (festgelegt 2026-11-03 04:25, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/nz/kriterien.txt (md5 ac234067), vor der Reihe, Prüfer Gemini (Mistral Zeitüberschreitung), Einwände von snai_int8_lora übernommen. Echter Vorwärtspfad (cortex.nim + patch_nz, ohne Schalter bytegleich). Je Neuron über held-out 700 Fenster: rel = RMS(s)·Spaltennorm w_down / RMS-Norm Residual; rho = Restfehler der besten Geraden / RMS(s). TOT rel < 1e-3, LINEAR rho < 0,05, sonst ARBEITEND (Schwellen an K1_s4 geeicht, offengelegt; Nebenlesarten). Wirkprobe: alle TOT auf 0, alle LINEAR durch Gerade, je ≤ 0,005 nats in ≥ 7/8 = FUNKTIONAL; Gegenprobe L0 ARBEITEND durch Gerade ≥ 0,05 nats. Haupturteil je Paar TG/TPU und K1/plus, A2 = Anteil ARBEITEND in L2: GESTÜTZT bei A2 ≤ 0,25 im Arm mit toten Gains und Gegenarm ≥ 2x in ≥ 7/8; WIDERLEGT bei A2 > 0,5 oder Gegenarm ≤ Partner in ≥ 7/8; sonst OFFEN; ohne FUNKTIONAL keine Aussage. L2 überwiegend TOT statt LINEAR heißt "leise", nicht "linear". Tote Gains getrennt berichtet. Kosten ganzer Zweige nicht (snai/schicht-beitrag).
Plan: rechner-b:~/snai_pruef/nz/kriterien.txt
Baut auf: snai/torch-wup-mechanismus, snai/genesis-ffn-128, snai/torch-k1-gains
Rezepte:
  r546 [2026-11-03] cd ~/snai_pruef/nz && setsid -f nohup ./reihe.sh > reihe.nohup 2>&1 < /dev/null
      quelltext: nz/quelle/cortex.nim = clip/proj_clip 814588b5 + patch_nz.py -> e579c8c0, libcortex a3e5dffe (Referenzbau ohne Patch = ccb10b0f, gleich proj_clip); m.sh, nz_dump.php (auto_append_file an clip/text/mess_text.php, unverändert), zensus.py, modus.py, rot.php (Lage aus gs/werkzeug/nullsetzen.php)
      parameter: held-out clip/daten/heldout.txt 700 Fenster, 89.600 Positionen; TOT 1e-3, LINEAR 0,05, Nebenlesarten 3e-4, 3e-3, 0,1; Wirkproben WT, WL, Gegenprobe G0/G3 an s4; 1 Prozess, nice 19, OMP 1
      seed: K1, plus, TG, TPU, TF0 je s4-s11; LANG k64_lang_s3 (Beobachtung)
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/nz/reihe.log, aus.jsonl, z/*.nz, z/*.kl, w/, fehler/*.err, rot/
      notiz: Kontrollen vor dem Start: K1_s4 ohne Schalter 2,6728 = mess128, mit Schalter 2,6728. Rot R1 (int8 tot) und R2 (float linear, tot) richtig. Erwartete Fehlerkanal-Zeilen: "[NZ] Modusdatei ...", bei Torch "[cortex] INFO: m/v sind leer -> Cold Start".
  r547 [2026-11-03] Nachtrag Zweige: cd ~/snai_pruef/nz && setsid -f nohup ./reihe2.sh > reihe2.nohup 2>&1 < /dev/null   (wartet auf NZ_FERTIG)
      quelltext: quelle2/cortex.nim = quelle (e579c8c0) + patch_nz2.py -> 9aa91e74, Lib 0224f301; m2.sh
      logs: rechner-b:~/snai_pruef/nz/reihe2.log, z2/*.nz (Y-Zeilen), fehler/z2_*.err
      notiz: Wunsch snai_int8_lora: je Schicht RMS ||Attention-Ausgabe|| / ||Residual vor Attention|| und ||FFN-Ausgabe|| / ||Residual vor FFN||, Beobachtung ohne Urteil. Kontrolle K1_s4: Loss 2,6728 gleich, N- und X-Zeilen bytegleich zur ersten Lib. Modelle K1, TG, TF0, plus, TPU je s4-s11, LANG.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/nz/aus.jsonl (ausw.py); Torch-Gains clip_torch/aus.py g()
  m8107 WT-Anstieg <= 0,005 | 3/8 | K1
  m8108 WT-Anstieg <= 0,005 | 2/7 | plus
  m8109 WT-Anstieg <= 0,005 | 3/8 | TG
  m8110 WT-Anstieg <= 0,005 | 2/8 | TPU
  m8111 WT-Anstieg Spanne nats | 0,0028-0,0105 | K1
  m8112 WT-Anstieg Spanne nats | 0,0032-0,0162 | plus
  m8113 WT-Anstieg Spanne nats | 0,0028-0,0121 | TG
  m8114 WT-Anstieg Spanne nats | 0,0033-0,0199 | TPU
  m8115 TF0 L1-L3 TOT | 100 % in 8/8 | TF0
  m8116 Gegenprobe G0 | 0,148 | K1 | 4
  m8117 Gegenprobe G0 | 0,134 | plus | 4
  m8118 Gegenprobe G0 | 0,104 | TG | 4
  m8119 Gegenprobe G0 | 0,106 | TPU | 4
  m8120 G3 L3 durch Gerade | 0,124 / 0,119 / 0,122 / 0,095 | K1/plus/TG/TPU | 4
  m8121 LINEAR je Modell | 0-14 von 2048 | alle |  | 40
  m8122 A2 je Saat s4-s11 | 0,016 0,365 0,229 0,064 0,041 0,021 0,062 0,014 | K1
  m8123 A2 je Saat s4-s10 | 0,346 0,332 0,756 0,744 0,219 0,240 0,643 | plus
  m8124 A2 je Saat s4-s11 | 0,000 0,117 0,002 0,000 0,049 0,045 0,137 0,014 | TG
  m8125 A2 je Saat s4-s11 | 0,373 0,221 0,719 0,672 0,203 0,221 0,475 0,734 | TPU
  m8126 tote FFN-Gains L2 je Saat | 79,7 0,8 22,7 49,2 61,7 59,4 60,2 85,9 % | K1
  m8127 tote FFN-Gains L2 je Saat | 88,3 32,0 81,2 96,1 65,6 62,5 39,1 72,7 % | TG
  m8128 tote FFN-Gains L2 | 0-1,6 % | plus, TPU
  m8129 LANG Klassen L0-L3 arbeitend | 233 43 5 163 von 256 | LANG | 4 | 1
  m8130 LANG tote Gains L2 | 6,3 % | LANG | 4 | 1
  Quelle: rechner-b:~/snai_pruef/nz z2/, z3/, z5/, z/plus_s11 (zweig.py, ausw.py)
  m8149 WT plus s11 | 0,0086 | plus | 11
  m8150 A2 plus s11 | 0,668 | plus | 11
  m8151 FFN/R Median ende L0-L3 | 88 0,13 0,04 0,38 | K1 |  | 8
  m8152 FFN/R Median ende L0-L3 | 73 0,32 0,20 0,42 | plus |  | 8
  m8153 FFN/R Median ende L0-L3 | 92 0,09 0,03 0,41 | TG |  | 8
  m8154 FFN/R Median ende L0-L3 | 84 0,18 0,18 0,40 | TPU |  | 8
  m8155 Att/R Spanne Mediane L0-L3 alle Arme | 0,24-0,45 | alle |  | 40
  m8156 TEE (b) L0 TEE/TG t1000 t3000 ende | 0,111-0,127; 0,096-0,119; 0,080-0,103; 8/8 je Stand | TEE |  | 8
  m8157 FFN/R Median ende L0-L3 | 8,3 0,125 0,097 0,325 | TEE |  | 8
  m8158 Wette 512 W1 L0 | L8 87,6 110,8; L4 53,3 47,3 37,3 | L8,L4 |  | 5
  m8159 Wette 512 W3 letzte/Mitte | L8 14,2 13,3; L4 10,1 11,7 9,5 | L8,L4 |  | 5
  m8160 Wette 512 Urteil | GEWONNEN 5/5 | L8,L4 |  | 5
  m8161 WT L8 512 | 0,030-0,068 | L8 |  | 3
  m8162 c128sr L0 Zweig/R s4 s9 | 24,2 / 5,28, Faktor 0,22 (1/E erwartet 2,68) | c128sr |  | 1
  m8163 c128sr Vorhersage Urteil | WIDERLEGT | c128sr |  | 1
  Quelle: rechner-b:~/snai_pruef/nz/z6 (reihe6b.sh, quelle3 31df8c5c, m4.sh); für snai/engine-emb-eingang Bedingung (b)
  m8177 EE (b) L0 EE/K1 t1000 t3000 ende | 0,117-0,142; 0,098-0,116; 0,078-0,096; 8/8 je Stand | EE |  | 8
  m8178 FFN/R Median ende L0-L3 | 7,4 0,131 0,102 0,326 | EE |  | 8
  m8179 Att/R Median ende L0-L3 | 0,54 0,25 0,26 0,30 | EE |  | 8
  m8180 A2 EE ende s4-s11 | 0,46 0,29 0,15 0,56 0,14 0,19 0,65 0,31 | EE
  m8181 Kontrolle K1C_s4 | 2,6728, N/X/Y bytegleich K1_s4 | K1C | 4
  m8182 Rot EE_s4 ohne F | 6,6762 statt 2,6187 | EE | 4
Ergebnis e490 [2026-11-03 07:22]: keine_aussage
  Fazit: Haupturteil nach Wortlaut KEINE AUSSAGE: Klassen nicht FUNKTIONAL (leise Neuronen kosten gemeinsam 0,003-0,02 nats, Grenze 0,005; plus jetzt 2/8). Beobachtung mit Rot: praktisch keine linearen Neuronen, die Mitte ist leise, nicht linear. Nachträge: (1) Wette GEWONNEN nach vorab geschriebener Regel bei 512 mit 4 und 8 Schichten (5/5): laut - leise - laut, Attention arbeitet durch; der laute L0-Zweig ist bei 512 die Attention. (2) TEE Bedingung (b) 8/8 an allen Ständen; L1-L3 werden unter TEE nicht allgemein leiser, also nicht LNS-artig. (3) Evos 1/E-Vorhersage an c128sr WIDERLEGT: Das L0-Verhältnis fällt s4→s9 (Faktor 0,22 statt 2,68), weil der L0-FFN-Zweig schneller schrumpft als E. Folge: Embedding-Spur gestützt, die reine 1/E-Mechanik ist nicht die ganze Erklärung.
  Offen: Kumulativ geeichte tot-Schwelle. Warum der L0-Zweig beim Abkühlen schneller schrumpft als E (c128sr, ein Lauf). Ob das Muster bei 16/32 Schichten hält (keine Modelle). Engine-EE (reihe6) läuft bis etwa 08:30.
  Datei: rechner-b:~/snai_pruef/nz/ERGEBNIS_neuronen_zensus.md
Abgeloest und ausgeblendet: 1 ergebnis - voll=True zeigt sie.
Chronik (juengste 8 von 10, voll=True zeigt alle):
  2026-11-03 04:25 Status geplant -> laeuft (Rezept r546)
  2026-11-03 04:30 Rezept r547 (Nachtrag Zweige)
  2026-11-03 06:42 Messwerte m8107-m8130
  2026-11-03 06:42 Ergebnis e486: keine_aussage
  2026-11-03 06:42 Status laeuft -> ausgewertet (Ergebnis e486)
  2026-11-03 07:22 Messwerte m8149-m8163
  2026-11-03 07:22 Ergebnis e490: keine_aussage, loest e486 ab
  2026-11-03 07:47 Messwerte m8177-m8182
```
