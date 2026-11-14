# snai/kopier-knirps-schaltkreis

```text
snai/kopier-knirps-schaltkreis - ausgewertet, begonnen 2026-10-12, angelegt 2026-10-21, zuletzt 2026-10-21 11:25
Frage: Welcher Schaltkreis trägt das Kopieren im Knirps 32/2/4 (LR 0,001): Attention-Muster je Kopf und Kausalprobe (Köpfe gleichschalten), und sucht er nach Inhalt oder nach Abstand?
Kriterium (nachgetragen, Beleg: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt):
  Muster: mittleres Attention-Gewicht je Kopf an Abfragen im zweiten Durchgang auf Folge / Gleich / Vorgänger / Selbst (Zufall 0,037); Kopf dieser Art ab 0,5, Ansatz 0,1-0,5. Rot 1: Stand vor dem Kopieren hat keinen Folge-Kopf. Rot 2: mit fremder erster Kopie fällt das Folge-Gewicht unter 0,1. Kausal (Rang 0): nötig = unter die Hälfte, entbehrlich = über 80 % des Werts ohne Eingriff, genügt = über der Hälfte.
Baut auf: snai/kopier-knirps-leiter
Darauf baut: snai/knirps-kb4-muster
Rezepte:
  r37 [2026-10-21] ~/snai_pruef/knirps/muster/muster.sh <ckpt> <marke> <fenster> <sabotage>   und   kausal.sh <ckpt>   (wörtliche Aufrufformen; konkrete Argumente k. A.)
      parameter: Modell knirps/proj/factory/checkpoints/kopiertest_w256_d32_lr0.001_s0..s3.snai: 32/2/4, ctx 64, wort256, LR 0,001; Aufgabe `var`, je 100 frische Fenster. Mitschnitt aus dem echten Vorwärtspfad über roentgen/libcortex_rx.so + SNAI_ATT_DUMP (MESS_SEQ in mess_seq.php, Auswertung auswert_muster.py); Köpfe gleichschalten über libcortex_qk.so (SNAI_QK_KOPF / SNAI_QK_AUSSER)
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/knirps/muster/
Messwerte (Groesse | Wert | Arm | Start | n):
  m301 R0 zweite Kopie s0 / s1 / s2 / s3 | 5,8 / 9,3 / 25,3 / 92,1 % | 32/2/4 |  | 100
  m302 Vorgänger-Gewicht Kopf 0.1 | 0,954 (Entropie 0,16) | s3 |  | 100
  m303 Folge-Gewicht Köpfe 1.0 / 1.1 / 1.2 / 1.3 | 0,777 / 0,776 / 0,693 / 0,811 | s3 |  | 100
  m304 Rot 2: Folge-Gewicht mit fremder erster Kopie | 0,068 | s3 |  | 100
  m305 Kausal R0: alle aus / aus 0.1 / aus 0.0, 0.2, 0.3 | 0,3 % / 9,0 % / 91,5-91,8 % | s3 |  | 100
  m306 Kausal R0: aus je einem Kopf der Schicht 1 | 77,1-80,4 % | s3 |  | 100
  m307 Kausal R0: nur 0.1 + EIN Folge-Kopf / nur 0.1 + alle vier | 19,2 / 25,9 % / 89,9 % | s3 |  | 100
Ergebnis e33 [2026-10-21 11:25]: erfuellt
  Fazit: Im Ganzzahl-Stack entsteht der Lehrbuch-Induktionsschaltkreis: ein Vorgänger-Kopf in Schicht 0 (nötig), vier gleichartige Folge-Köpfe in Schicht 1, die sich addieren (nur alle vier zusammen genügen). Rot 2 zeigt: die Köpfe suchen nach INHALT, nicht nach Abstand. Entstehung: erst der Vorgänger-Kopf, dann schärfen die Folge-Köpfe. Damit ist der Knirps ein brauchbares Versuchstier für Kopierfragen.
  Offen: Vermutung, nicht gemessen: ein Kopf der Breite 8 transportiert nur einen Teil der Token-Identität, deshalb braucht es alle vier (würde das Scheitern bei Kopfbreite 4 erklären). Ein Modell, eine Saat. Vorbehalt Lade-Wächter für Knirps-Werte dieses Tages.
Chronik:
  2026-10-21 11:23 angelegt (Nachtrag: Nachgetragen 2026-10-21; Kriterium laut damaliger Aufzeichnung vorab festgelegt)
  2026-10-21 11:24 Rezept r37
  2026-10-21 11:24 Status geplant -> laeuft (Rezept r37)
  2026-10-21 11:24 Messwerte m301-m307
  2026-10-21 11:25 Ergebnis e33: erfuellt
  2026-10-21 11:25 Status laeuft -> ausgewertet (Ergebnis e33)
```
