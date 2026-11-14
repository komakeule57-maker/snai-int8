# snai/knirps-revival-paar-32

```text
snai/knirps-revival-paar-32 - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 14:33
Frage: Hat das alte Neuron-Revival beim Kopier-Knirps 32/2/16 Saat 3 (g_d32h2_s3, nach 120.000 Fenstern bei 3,4 %) das spätere Lernen verhindert? Gepaarter Lauf ohne Revival unter demselben Namen.
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt, Nachtrag (q) (2026-10-12, vor dem Lauf).):
  (q) Wiederholung unter DEMSELBEN Namen in proj_r0 (Revival aus). (1) Kontrolle: Stände der Segmente 0..13 bytegleich (Revival griff erst ab Segment 14 ein). (2) REVIVAL HAT DAS SPÄTERE LERNEN VERHINDERT, wenn der Lauf ohne Revival in den Segmenten 14..23 mindestens 50 % erreicht; NICHT, wenn er unter 10 % bleibt. Dass dieselbe Genesis unter dem Namen n_d32h2_s3 nach 10.000 Fenstern lernt, zeigt dann: der Unterschied liegt in der Fensterreihenfolge (Laufname).
Plan: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt
Baut auf: snai/kopier-revival
Rezepte:
  r98 [2026-10-21] PROJ=proj_r0 VOK=wort256 ~/snai_pruef/knirps/lauf.sh g_d32h2_s3 var 3 0.001 24 5000 factory/checkpoints/gitter_gen_d32h2_s3.snai (Aufruf aus lauf.sh erschlossen, nicht protokolliert)
      quelltext: knirps/proj_r0 (revival_config enabled=false), libcortex.so 1c634106f31c
      parameter: 32/2/16, wort256, var, ctx 64, LR 0,001, Warmup 500, WD 0,1, 24 x 5.000 Fenster
      seed: Genesis gitter_gen_d32h2_s3, Laufname g_d32h2_s3 (gleiche Fensterreihenfolge)
      rechner: rechner-a
      logs: rechner-a:~/.cache/snai_pruef/knirps_paar_g_d32h2_s3.out (nicht gelesen)
      notiz: Prüfung beim Nachtrag: Nicht aus Rohdaten nachgerechnet. Lade-Wächter: Der Fallstrick-Befund nennt g_d32h2_s3 als betroffenen Anlasslauf der Laufnamen-Reihe; ob der Wächter im Paarlauf ohne Revival mitwirkte, nicht geprüft.
Messwerte (Groesse | Wert | Arm | Start | n):
 , nicht nachgerechnet
  m919 Kontrolle Stände s0..s13 (n = Stände) | bytegleich, ab s14 verschieden | Paar g_d32h2_s3 | 3 | 14
  m920 Rang 0 s14..s23 | 1,6-4,6 % | ohne Revival | 3 | 200
  m921 Rang 0 s14..s23 | 1,5-3,4 % | mit altem Revival | 3 | 200
Ergebnis e85 [2026-10-21 14:33]: verfehlt
  Fazit: Das Revival war hier nicht schuld: ohne Revival bleibt der Lauf unter 10 % (1,6-4,6 %), gepaart bis Segment 13 bytegleich. Dieselbe Genesis lernt unter einem anderen Laufnamen nach 10.000 Fenstern; das Nichtlernen beim Kopieren hängt also an der Fensterreihenfolge. Daraus wurde die Laufnamen-Reihe (snai/kopier-knirps-laufnamen). Ein Paar, eine Genesis, zwei Reihenfolgen.
  Offen: Wie häufig eine Reihenfolge blockiert: snai/kopier-knirps-laufnamen.
  Datei: rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt
Chronik:
  2026-10-21 14:33 angelegt (Nachtrag: Kriterium aus rechner-a:~/snai_pruef/knirps/kopfbreite_kriterien.txt, Nachtrag (q) (2026-10-12, vor dem Lauf).)
  2026-10-21 14:33 Rezept r98
  2026-10-21 14:33 Status geplant -> laeuft (Rezept r98)
  2026-10-21 14:33 Messwerte m919-m921
  2026-10-21 14:33 Ergebnis e85: verfehlt
  2026-10-21 14:33 Status laeuft -> ausgewertet (Ergebnis e85)
```
