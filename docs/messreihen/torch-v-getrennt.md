# snai/torch-v-getrennt

```text
snai/torch-v-getrennt - ausgewertet, angelegt 2026-11-03, zuletzt 2026-11-03 12:03
Frage: Isoliert ein Eingriff den Mechanismus des Gain-Sterbens unter Bindung? Arm TVS: E bleibt eine gebundene Matrix, Adam führt aber getrennte Momentpaare für den Gradientenanteil der Eingangs- und der Ausgangsseite (Hypothese aus snai/f2-emb-gradteil: das gemeinsame v wird von der Ausgangsseite bestimmt, die Eingangsseite läuft mit kleiner Schrittweite, die L2-FFN-Gains sterben).
Kriterium (festgelegt 2026-11-03 11:09, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/clip_torch/KRITERIEN_tvs.md (md5 4ce19d76), vor dem Hauptlauf. Torch-Nachbau torch_k1v.py (patch_vs.py aus torch_k1e.py, ein Stellrad --v-getrennt), K1-Rezept wie TG, Saaten 4-11 gepaart zu TG.
- Hauptgröße: Anteil toter FFN-L2-Gains (|g| < 0,05) am Ende, TVS gegen TG, je Saat.
- MECHANISMUS GESTÜTZT: TVS hat höchstens halb so viele tote L2-Gains wie TG in ≥ 6/8 UND RMS(E) am Ende ist größer als bei TG in ≥ 6/8.
- WIDERLEGT: TVS hat mindestens 80 % der toten L2-Gains von TG in ≥ 6/8.
- Sonst TEILWEISE.
- Daneben: Held-out-Loss TVS − TG je Saat (Hausregel: unter 10 % ist Gleichstand; daneben |D|<0,02), RMS(E) je Snapshot, tote Gains aller Schichten, Vergleich mit TEE.
- Gemeinsam verändert: nur die Momentführung von E. Lernrate, Clipping und Weight Decay bleiben gleich. Zwangsläufig mit: der Gesamtschritt auf E in Eingangszeilen wächst (bis Schritt 1000 RMS 0,29 statt 0,21 lr-Einheiten); die Reihe trennt nicht "geteiltes v" von "größerer E-Schritt in Eingangszeilen".
Kontrollen vor dem Lauf (alle wie vorgesehen): Kopie ohne Schalter bytegleich zu TG_s4 bis 1000; Rot "alles in v_aus" bytegleich; Decay-Gegenprobe (g_ein abgeschnitten) bytegleich, Rot Doppel-Decay verschieden; Schritt 1 NICHT gleich (sign(g_ein)+sign(g_aus) statt sign(Summe)), Vorhersage exakt.
Plan: rechner-b:~/snai_pruef/clip_torch/KRITERIEN_tvs.md
Baut auf: snai/f2-emb-gradteil, snai/torch-k1-gains, snai/torch-emb-eingang
Darauf baut: snai/torch-emb-leiter
Rezepte:
  r556 [2026-11-03] TVS: rechner-b: cd ~/snai_pruef/clip_torch && setsid -f ./kette_tvs.sh  (je Saat eins_tvs.sh <s>: nice 10, OMP 1, torch_k1v.py train clip_gen_s<s>.snai fen/f_s<s>.bin --koepfe 8 --lr 0.003 --lr-konst --snapshots 1000,3000 --v-getrennt --vs-log 100 --vs-log-bis 1000 --gn-log 100; Messung mess_text.php heldout 700 wie eins_tee.sh)
      quelltext: torch_k1v.py md5 6ae4bd25 (patch_vs.py 1c280094 aus torch_k1e.py 93855f6e); eins_tvs.sh dacffb7c; kette_tvs.sh 000ef015; Rotfassungen patch_vs_rot.py 32ad546a
      seed: 4-11
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/clip_torch/laeufe/TVS_s<s>/train.log, log/mess.jsonl (arm TVS), log/lauf.log, Kontrollen vs/k_K0..K7
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/clip_torch/ausw_tvs.py -> log/ausw_tvs.txt (md5 03470ecd)
  m8299 L2 tot % Ende | 79,7 | TVS | 4
  m8300 L2 tot % Ende | 98,4 | TVS | 5
  m8301 L2 tot % Ende | 75,8 | TVS | 6
  m8302 L2 tot % Ende | 93,0 | TVS | 7
  m8303 L2 tot % Ende | 71,9 | TVS | 8
  m8304 L2 tot % Ende | 80,5 | TVS | 9
  m8305 L2 tot % Ende | 49,2 | TVS | 10
  m8306 L2 tot % Ende | 93,8 | TVS | 11
  m8307 L2 tot % Ende Mittel | 80,3 | TVS |  | 8
  m8308 L2 tot % Ende Mittel | 67,2 | TG |  | 8
  m8309 TVS <= TG/2 | 0/8 | TVS
  m8310 TVS >= 0,8 TG | 8/8 | TVS
  m8311 RMS(E) Ende | 0,1625-0,1675 | TVS |  | 8
  m8312 RMS(E) Ende | 0,1156-0,1176 | TG |  | 8
  m8313 RMS(E) Ende TVS/TG | 1,39-1,44, groesser 8/8 | TVS |  | 8
  m8314 Held-out D TVS-TG Mittel | +0,0048 (Bootstrap -0,0032..+0,0136) | TVS |  | 8
  m8315 Held-out abs(D)/TG < 10 % | 8/8 | TVS
  m8316 Held-out abs(D) < 0,02 | 7/8 | TVS
  m8317 g_final Ende Mittel | 0,649 (TG 0,869) | TVS |  | 8
  m8318 Eingangsschritt getrennt/gemeinsam t200-1000 | 1,00-1,67 | TVS |  | 8
  m8319 Eingangsschritt getrennt/gemeinsam t200-1000 im Original (Schatten) | 1,25-1,49 | TG | 4
  m8320 max abs Eingangsschritt bis t1000 | 2,96, kein NaN | TVS |  | 8
Ergebnis e500 [2026-11-03 12:03]: verfehlt
  Fazit: Nach Wortlaut WIDERLEGT (TVS >= 0,8 x TG tote L2-Gains in 8/8; halbiert 0/8; RMS(E) zwar groesser 8/8). Das geteilte Adam-v der gebundenen Matrix ist im K1-Rezept (9.002 Schritte) nicht der Mechanismus des Gain-Sterbens; Held-out Gleichstand. Die F2-Annahme "Eingangsseite laeuft mit einem Drittel" trifft schon im Original nicht zu (bis Schritt 1000 etwa 70 %), getrennte Momente heben E nur auf das 1,4-fache (TEE: Eingang 11-fach, repariert). Die Eingangsskala als Hebel ist damit nicht widerlegt, nur die Dosis 1,4 reicht nicht. Weiter an der Momentfuehrung von E zu drehen lohnt nicht; naechster Schritt waere eine Dosisleiter des Eingangsfaktors (F = 2, 4).
  Offen: Verhaeltnis der Eingangsschrittweite nach Schritt 1000 nicht geloggt (Sterben ab 3000). Dosis zwischen 1,4 und 11 ungemessen. Schritt 1 mit Schalter ist nicht gleich dem Original (sign-Summe), Auftragserwartung war falsch; Stellrad trotzdem sauber.
  Datei: rechner-b:~/snai_pruef/clip_torch/ERGEBNIS_torch_v_getrennt.md
Chronik:
  2026-11-03 11:09 angelegt
  2026-11-03 11:09 Rezept r556 (TVS)
  2026-11-03 11:09 Status geplant -> laeuft (Rezept r556)
  2026-11-03 12:03 Messwerte m8299-m8320
  2026-11-03 12:03 Ergebnis e500: verfehlt
  2026-11-03 12:03 Status laeuft -> ausgewertet (Ergebnis e500)
```
