# snai/genesis-ffn

```text
snai/genesis-ffn - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-02 20:30
Frage: Beeinflusst die Startgroesse der FFN-Gewichte (w_up, w_down) das Sterben der FFN-Gains am Knirps 64x4?
Kriterium (festgelegt 2026-11-02 18:14, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/gs/kriterien.txt. Messgroesse tote Gains FFN L2 am Ende (gains_leb.php, |g|<0,05), gepaart gegen neu, Saaten 4-6. Arme plus (w_up x6,25, w_down x3,125), minus (Kehrwerte), klein (beide x1,05, Empfindlichkeit gegen winzige Aenderung). HEBEL: plus <= 0,5 x neu in 3/3. VERSTAERKT: >= 1,5 x neu oder >= 90 % in 3/3. KEIN HEBEL: alle innerhalb. Sonst saatabhaengig, traegt keinen Schluss. Ursache nur, wenn plus hilft, minus nicht hilft und klein innerhalb bleibt; schwankt klein ebenso stark wie plus, ist der Abstand kein Befund. Held-out unter 10 % Gleichstand.
Plan: rechner-b:~/snai_pruef/gs/kriterien.txt
Baut auf: snai/adam-schatten, snai/ratsche-k64
Darauf baut: snai/genesis-norm, snai/genesis-ffn-128, snai/multistack-plus-64
Rezepte:
  r527 [2026-11-02] cd ~/snai_pruef/gs; ./kette.sh (Arme plus, minus, klein, Saaten 4-6, je ./lauf_g.sh arm saat)
      quelltext: init_g.php = init_base.php + SNAI_GEN_FFN; Bibliothek ad/quelle2/libcortex.so 948fee2a
      seed: Saat 4, 5, 6
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/gs/l/, log.txt, gs.out
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/gs/mess64.jsonl, a64.py, gs2.py
  m7840 FFN L2 tot % Ende | 35,9 | neu | 4
  m7841 FFN L2 tot % Ende | 68,8 | neu | 5
  m7842 FFN L2 tot % Ende | 53,1 | neu | 6
  m7843 FFN L2 tot % Ende | 0 | plus | 4
  m7844 FFN L2 tot % Ende | 0 | plus | 5
  m7845 FFN L2 tot % Ende | 1,6 | plus | 6
  m7846 FFN L2 tot % Ende | 29,7 | minus | 4
  m7847 FFN L2 tot % Ende | 25,0 | minus | 5
  m7848 FFN L2 tot % Ende | 50,0 | minus | 6
  m7849 FFN L2 tot % Ende | 60,9 | klein | 4
  m7850 FFN L2 tot % Ende | 85,9 | klein | 5
  m7851 FFN L2 tot % Ende | 45,3 | klein | 6
  m7852 Held-out Loss | 2,6683 | neu | 4 | 700
  m7853 Held-out Loss | 2,6831 | neu | 5 | 700
  m7854 Held-out Loss | 2,6858 | neu | 6 | 700
  m7855 Held-out Loss | 2,6492 | plus | 4 | 700
  m7856 Held-out Loss | 2,6510 | plus | 5 | 700
  m7857 Held-out Loss | 2,6695 | plus | 6 | 700
  m7858 Held-out Loss | 2,6920 | minus | 4 | 700
  m7859 Held-out Loss | 2,6854 | minus | 5 | 700
  m7860 Held-out Loss | 2,6956 | minus | 6 | 700
  m7861 Held-out Loss | 2,6906 | klein | 4 | 700
  m7862 Held-out Loss | 2,7025 | klein | 5 | 700
  m7863 Held-out Loss | 2,6967 | klein | 6 | 700
  m7864 Nullsetz-Kosten L1+L2+L3 nats | 0,102 | neu | 4
  m7865 Nullsetz-Kosten L1+L2+L3 nats | 0,085 | neu | 5
  m7866 Nullsetz-Kosten L1+L2+L3 nats | 0,085 | neu | 6
  m7867 Nullsetz-Kosten L1+L2+L3 nats | 0,348 | plus | 4
  m7868 Nullsetz-Kosten L1+L2+L3 nats | 0,279 | plus | 5
  m7869 Nullsetz-Kosten L1+L2+L3 nats | 0,232 | plus | 6
Ergebnis e472 [2026-11-02 20:30]: teilweise
  Fazit: plus HEBEL 3/3, tote L2-Gains auf nahezu null, Nullsetz-Kosten dreifach, Held-out Gleichstand. Die Annahme, die Genesis spiele keine Rolle, ist fuer Breite 64 widerlegt. Die vorab verlangte URSACHE-Klausel ist nicht erfuellt: klein schwankt in s4 mit Faktor 1,70 ausserhalb des Bandes, minus verstaerkt nicht. Zweite Lesart daneben: das Absinken auf null ueberragt die klein-Schwankung. Nicht als Ursache zitieren. Entscheidend ist snai/genesis-ffn-128.
  Offen: Mechanismus. w_up und w_down nicht getrennt (snai_int8_lora prueft es in Torch). Guete in laengeren Laeufen. Attention-L0-Gains unberuehrt. Breite ueber 64, 3 Saaten. Spiegelprobe traegt nicht.
  Datei: rechner-b:~/snai_pruef/gs/ERGEBNIS_genesis_ffn.md
Chronik:
  2026-11-02 18:14 angelegt
  2026-11-02 18:14 Rezept r527
  2026-11-02 18:14 Status geplant -> laeuft (Rezept r527)
  2026-11-02 20:30 Messwerte m7840-m7869
  2026-11-02 20:30 Ergebnis e472: teilweise
  2026-11-02 20:30 Status laeuft -> ausgewertet (Ergebnis e472)
```
