# snai/v-klebt-lauf

```text
snai/v-klebt-lauf - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-03 12:12
Frage: Ändert es Norm, Lernerfolg oder tote Gains, wenn v unter der Zeilenschwelle auf die kleinste Stufe geklemmt statt auf 0 gesetzt wird? Darf die Klemme als Fix in den Projektbaum?
Kriterium (festgelegt 2026-11-02 07:28, vor dem ersten Messwert):
  rechner-a:~/snai_pruef/vklebt/kriterien_lauf.txt, vor dem ersten Lauf, Prüfer. Start c128sr s7, s8 LR 1e-4, s9 LR 5e-5, drei Reihenfolgen gepaart, ein Stellrad SNAI_V_KLEMME. GN Median letzte 5.000 Schritte s9, G Held-out-Gewinn s7->s9, T tote Gains L1+L2. Je Größe besser/schlechter nur über 10 % in 3 von 3, sonst Gleichstand. FIX RECHTFERTIGT = keine Größe schlechter; Einbau nur mit Zustimmung. Kontrollen K1/K1b Aus-Arm gleich Original, K2 A Aus 10 %, Klemme praktisch 0, K3 Paarung, K4 rc, Schritte, Fehlerkanal.
Plan: rechner-a:~/snai_pruef/vklebt/kriterien_lauf.txt
Baut auf: snai/v-klebt
Darauf baut: snai/v-klebt-deckel, snai/multistack-vk-uebernahme
Rezepte:
  r504 [2026-11-02] cd ~/snai_pruef/vklebt && setsid -f nohup ./schlange.sh > schlange.out 2>&1 < /dev/null (je Lauf lauf_vk.sh <arm> <name>)
      quelltext: proj_sr cortex.nim 2f3a96c9 + patch_vk.py ff9721f4 = 9b36aab4, Lib 279a25cd; lauf_vk.sh 2f9088f9, schlange.sh e0740127, k1.sh 9e7191fb, kriterien_lauf.txt 6e7eaf34
      parameter: Start c128sr s7 md5 9c16ff73; s8 LR 1e-4, s9 LR 5e-5; WD 0,1; 1 Thread; höchstens 3 zugleich, ab 1400 MB frei, nice 10
      seed: Reihenfolgen über Laufnamen: c128sr, vk2, vk3
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/vklebt/log/, fortschritt.log, k1.txt, k1.diff
      notiz: K1 grün: Aus-Arm unter Originalnamen bis Schritt 2980 zeichengleich (600 geloggte Zeilen, k1.diff leer), dann gezielt beendet. Die [VK]-Zeile erschien schon im ersten Schritt, A auf s7 ist also klein, aber nicht 0; K1b kann deshalb früh abweichen.
Messwerte (Groesse | Wert | Arm | Start | n):
  m7825 Zwischenprüfung 2026-11-02 20:08 K1b a1_c128sr_s8 gegen Original | erster abweichender geloggter Schritt 3 (Loss 2,187354 gegen 2,187317, GN 5,8000 gegen 5,7998), Schritt 1 und 2 gleich
  m7826 K3 Step 1 vk2 a0 gegen a1 | gleich (1,932285, GN 6,4761); erster abweichender Schritt 3
  m7827 K4 s8 STEPS_DONE | 153241 in a1_c128sr, a0_vk2, a1_vk2; SR je 1
  m7828 K4 Fehlerkanal s8 | je 2 NET2NET-Meldungen tote Kanäle beim Laden (L1, L2), Abweichung vom Wortlaut "leer"; nur Meldung, siehe Korrektur-Zähler; [VK] 1/0/1 wie gesetzt
  m7829 Basis s7 md5 | 9c16ff73 in proj_vk0 und proj_vk1
  m7830 Fortschritt s9 | Schritt rund 98.000 von 153.241, alle drei schreiben; vk3-Arme warten; Speicher frei 1.171 MB
  m7916 S = Median RMS/Element, w_up L1, 110 tote Kanäle, Original s8 | 0,1135, 8,90 x Gleichgewicht 0,57·sqrt(lr/0,2), 5,07 x sqrt(lr/0,2), v0m 0,999
  m7917 S a1_c128sr_s8 Klemme | 0,0128, 1,00 x Gleichgewicht, v0m 0,000
  m7918 S a0_vk2_s8 aus | 0,1097, 8,61 x Gleichgewicht, v0m 0,998
  m7919 S a1_vk2_s8 Klemme | 0,0129, 1,01 x Gleichgewicht, v0m 0,000
  m7920 Tote L1 je Stand | 116 in Original, a1_c128sr, a0_vk2, a1_vk2
  m7921 Vorhersage gegen Messung | erwartet Minderung rund 2,7-fach, gemessen 8,5- bis 8,9-fach: Rechnung aus snai/tote-spalten-wachsen widerlegt, Klemme hebt das Aufblähen an s8 voll auf (2 Reihenfolgen, s9 und vk3 ausstehend)
  Quelle: rechner-a ~/snai_pruef/vklebt/spalten_vk3.jsonl (spalten.php auf rechner-b, Kopien md5 36e2fd33 / be185244), s_aus.py
  m8062 Kontrolle spalten.php auf rechner-b | a1_vk2_s8 nachgemessen, RMS und Gain aller 128 Kanaele gleich m7919-Messung | a1 vk2 | s7 | 1
  m8063 S a0_vk3_s8 aus | 0,1128, 8,85 x Gleichgewicht, v0m 0,998 | aus | s7 | 1
  m8064 S a1_vk3_s8 Klemme | 0,0126, 0,99 x Gleichgewicht, v0m 0,000 | Klemme | s7 | 1
  m8065 Tote L1 vk3 s8 | 116 in beiden Armen | aus, Klemme | s7 | 2
  m8066 Zwischenstand s8 ueber 3 Reihenfolgen | Klemme haelt S auf 0,99-1,01 x Gleichgewicht, Aus-Arm 8,6-8,9 x, in 3/3; tote L1 unveraendert 116; Urteil erst an s9 | aus, Klemme | s7 | 6
  m8067 vk3 s8 Training | a0 und a1 rc=0, 05:22 fertig; vk3 s9 laeuft | aus, Klemme | s7 | 2
  m8289 GN Median letzte 5000 Schritte s9 | aus 11.1118 / Klemme 11.1055 | c128sr | s7 | 1000
  m8290 GN Median letzte 5000 Schritte s9 | aus 11.1799 / Klemme 11.1980 | vk2 | s7 | 1000
  m8291 GN Median letzte 5000 Schritte s9 | aus 11.1815 / Klemme 11.2121 | vk3 | s7 | 1000
  m8292 G = L(s7)-L(s9) heldout 700 | aus 0.1559 / Klemme 0.1550 | c128sr | s7 | 700
  m8293 G = L(s7)-L(s9) heldout 700 | aus 0.1564 / Klemme 0.1569 | vk2 | s7 | 700
  m8294 G = L(s7)-L(s9) heldout 700 | aus 0.1548 / Klemme 0.1548 | vk3 | s7 | 700
  m8295 T tote FFN-Gains L1+L2 s9 | 244 in allen 6 Endständen (s7 ebenfalls 244) | alle | s7 | 6
  m8296 K2 A(ffn) s9 | aus 11.23 % (vk2, vk3) / Klemme 0 % (3/3); [VK] v-Klemme 1 in allen Klemm-Logs | alle | s7 | 6
  m8297 K4 s9 | rc 0, STEPS_DONE 153241, SR 1, Fehlerkanal nur NET2NET-Meldungen tote Kanäle L1/L2 (bekannt, m7828), Basis s7 md5 9c16ff73 | alle | s7 | 6
  m8298 Kontrolle Messpfad | Original c128sr s9 nachgemessen 1.8851 = c128sr.mess.jsonl | aus | s7 | 1
Ergebnis e499 [2026-11-03 11:59]: erfuellt
  Fazit: Nach Wortlaut ist der FIX GERECHTFERTIGT. Alle drei Größen stehen im GLEICHSTAND, in 3/3 Reihenfolgen liegt jeder Unterschied unter 1 %, die Schwelle war 10 %.

- GN (Median der letzten 5.000 Schritte von s9): aus 11,11 / 11,18 / 11,18, Klemme 11,11 / 11,20 / 11,21.
- G (L(s7) − L(s9)): aus 0,1559 / 0,1564 / 0,1548, Klemme 0,1550 / 0,1569 / 0,1548.
- T (tote FFN-Gains L1+L2): 244 in allen Endständen, genau wie an s7.

Kontrollen K1-K4 grün:
- K2: Der Klemm-Arm hat A(ffn) 0 %, der Aus-Arm 11,2 %.
- Das Original s9 wurde reproduziert (1,8851).

Folge: Die Klemme beseitigt den nachgewiesenen Fehler (v gespeichert als 0 bei m ≠ 0) ohne messbaren Preis. Sie heilt aber nichts Sichtbares: Die Norm wächst gleich, und die toten Gains bleiben tot. An s8 hatte sie die Spaltenaufblähung voll aufgehoben (m8066), am Endergebnis zeigt sich das nicht.

Reichweite: ein Modell (128x4), ein Startstand s7, Abkühlende, 2 Segmente. prod512b ist nicht gemessen.

Der Einbau in den Projektbaum geht nur mit Zustimmung.
Chronik (juengste 8 von 10, voll=True zeigt alle):
  2026-11-02 07:36 Status geplant -> laeuft (Rezept r504)
  2026-11-02 20:09 Messwerte m7825-m7830
  2026-11-03 00:16 Messwerte m7916-m7921
  2026-11-03 05:45 Messwerte m8062-m8067
  2026-11-03 11:59 Messwerte m8289-m8298
  2026-11-03 11:59 Ergebnis e499: erfuellt
  2026-11-03 11:59 Status laeuft -> ausgewertet (Ergebnis e499)
  2026-11-03 12:12 Eingebaut 2026-11-03 auf Entscheidung als VOREINSTELLUNG im Projektbaum snai_edge_int8_lora (SNAI_V_KLEMME=0 schaltet ab). Patch scratchpad patch_vk_baum.py, cortex.nim f8292f7b, Lib 1eb78bc1 (alte als libcortex.so.bak_pre_vklemme_20261103).
Prüfung auf rechner-a, c128sr s7 → s8, 100 Schritte:
- Voreinstellung ist zeichengleich mit dem Klemm-Arm a1_c128sr_s8.
- SNAI_V_KLEMME=0 ist zeichengleich mit dem Original c128sr_s8.
- Rot: Beide weichen ab Schritt 3 voneinander ab, wie K1b.
verify_v7_format und verify_v7_tying jeweils 26/26. Nicht committet.
```
