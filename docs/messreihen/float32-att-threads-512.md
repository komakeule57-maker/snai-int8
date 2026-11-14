# snai/float32-att-threads-512

```text
snai/float32-att-threads-512 - ausgewertet, angelegt 2026-10-30, zuletzt 2026-10-30 19:09
Frage: Wird die float32-Attention auf der Karte schneller, wenn die Kernel-Bloecke kleiner sind (threads je Block 256 -> 32 / 8), bei bitgleichem Ergebnis?
Kriterium (festgelegt 2026-10-30 18:59, vor dem ersten Messwert):
  Gemessen: Median s/Schritt (STEP_MS, volle Schritte) und Zaehler 4, Rezept r473, rechner-b, Karte allein, entsperrt. Arme: T256 (Kontrolle, wie bisher), T32, T8; je 3 Laeufe. EIN Stellrad: die Umgebungsvariable SNAI_ATT_THREADS in EINER Bibliothek, wirkt nur auf threads in den gebuendelten Attention-Aufrufen. Harte Bedingung: md5 Ausgabemodell in allen Armen 105aea27, sonst Arm ungueltig. Kontrolle: T256 muss innerhalb +-10 % von 16,0 s liegen und md5 105aea27 liefern, sonst hat der Umbau selbst etwas veraendert. Urteil: Arm <= 0,90 x T256 in allen drei Laeufen = hilft; innerhalb +-10 % = Gleichstand; > 1,10 = langsamer. Bei Uneinigkeit der Laeufe kein Schluss. Reichweite: eine Karte, eine Geometrie, 1 Kopf; mehr Koepfe und andere Breiten nicht abgedeckt. Vorab geprueft: Saat-Abhaengigkeit entfaellt, gleicher Chunk und bytegleiche Laeufe. Nebenmechanismen: unveraendert, Karte entsperrt in allen Armen.
Baut auf: snai/float32-schrittprofil-512
Darauf baut: snai/float32-att-threads-koepfe
Rezepte:
  r474 [2026-10-30] cd ~/snai_pruef/att_threads && bench_tf32/alle.sh (je Arm: SNAI_ATT_THREADS=<arm> LD_LIBRARY_PATH=$PWD php bench_prof.php bench_tf32/chunk.txt bench_tf32/T<arm>_r<k>.snai 1 bench_tf32/gen512.snai 3 0.0005 1 0.0005 0.0 0.0)
      quelltext: rechner-b:~/snai_pruef/att_threads/cortex_cuda.cu = tf32_unlock-Stand mit Stellrad in cuda_attentionForwardBatched und cuda_attentionBackwardBatched; libcortex_cuda.so neu gebaut nach Kopfzeile der Datei
      rechner: rechner-b (RTX 3050, entsperrt)
      logs: rechner-b:~/snai_pruef/att_threads/bench_tf32/logT*_r*.txt, stand.txt
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/att_threads/bench_tf32/logT*_r*.txt, stand.txt
  m6726 Median s/Schritt | 16,058 | T256 | r1 | 7
  m6727 Median s/Schritt | 16,000 | T256 | r2 | 7
  m6728 Median s/Schritt | 15,964 | T256 | r3 | 7
  m6729 Median s/Schritt | 6,945 | T32 | r1 | 7
  m6730 Median s/Schritt | 6,961 | T32 | r2 | 7
  m6731 Median s/Schritt | 6,962 | T32 | r3 | 7
  m6732 Median s/Schritt | 5,421 | T8 | r1 | 7
  m6733 Median s/Schritt | 5,413 | T8 | r2 | 7
  m6734 Median s/Schritt | 5,418 | T8 | r3 | 7
  m6735 md5 Ausgabemodell | 105aea27 | T256,T32,T8 | r1-3 | 9
Ergebnis e417 [2026-10-30 19:09]: erfuellt
  Fazit: Die Blockgroesse war ein echter Hebel: T8 braucht 0,34 x T256, T32 0,43 x, alle Laeufe einig, md5 unveraendert 105aea27, Kontrolle T256 bei 16,0 s. Der Eingriff isoliert die Ursache fuer diese Geometrie. Vor einer Uebernahme in snai_edge muss die Einstellung auf anderer Kopfzahl geprueft werden, weil dort die Zahl der Bloecke anders ausfaellt.
  Offen: Kleinere Bloecke als 8; mehrere Koepfe; andere Breiten; Watchdog-Verhalten groesserer Modelle. Deutung, nicht gemessen: ein Block belegt nur einen Rechencluster der Karte.
Chronik:
  2026-10-30 18:59 angelegt
  2026-10-30 19:00 Rezept r474
  2026-10-30 19:00 Status geplant -> laeuft (Rezept r474)
  2026-10-30 19:09 Messwerte m6726-m6735
  2026-10-30 19:09 Ergebnis e417: erfuellt
  2026-10-30 19:09 Status laeuft -> ausgewertet (Ergebnis e417)
```
