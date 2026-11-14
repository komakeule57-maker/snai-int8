# snai/v-ueberhang

```text
snai/v-ueberhang - ausgewertet, angelegt 2026-11-03, zuletzt 2026-11-03 03:56
Frage: Verhungert w_up in L1 und L2 unter Tying, weil der frühe Gradientenstoß v lange groß hält und u = m/Wurzel(v) dadurch klein bleibt? Das würde Tying, Schichtreihenfolge und den Hebel w_up-Start mit einer Mechanik erklären.
Kriterium (festgelegt 2026-11-03 01:54, vor dem ersten Messwert):
  Befund vor der Vorhersage (Sonden SG, SU, SPU, snai/torch-wup-mechanismus, Saaten 4 bis 7, nachträglich): RMS g w_up L2 t100 zu t1000: SG 0,00025 zu 0,00004 (fällt rund sechsfach), SU 0,00000 zu 0,00004 (kein Stoß), SPU 0,00027 zu 0,00009. u t1000: SG L2 0,096, L1 0,105, L3 0,148, L0 0,241, Rausch 0,229; SU L2 0,129; SPU L2 0,155. Die Reihenfolge von u passt zum Sterben (L2, L1 vor L3, L0). c² aus p t1000 bis t3000 SG 0,016 bis 0,127 gegen K 0,13 bis 0,38, SU und SPU c² etwa gleich K: In SG summieren sich die Schritte zusätzlich schlechter als Rauschen.
Vorhersage, vor dem Lesen von B2, Arm von snai_int8_lora (Beta2 0,99, Saaten 4 bis 7, gegen TG gepaart): L2 tot <= 0,5 mal TG im Mittel und kleiner in mindestens 3/4, u w_up L2 t1000 >= 0,15. ÜBERHANG GESTÜTZT, wenn beides. WIDERLEGT, wenn L2 tot >= 0,8 mal TG, obwohl u >= 0,15. Sonst OFFEN. B2 ändert auch das Rauschen in v, also kein reiner Eingriff.
Reiner Eingriff, Vorschlag: TVR, in TG an t = 1000 v aller Tensoren einmalig auf g² des nächsten Fensters setzen, sonst nichts. Gleiche Schwellen. Ursache heißt es nur, wenn TVR senkt und TK-Chaos den Abstand nicht erklärt. Grenzen: 4 Saaten, Float, Mechanik aus demselben Datensatz gewonnen, also B2 und TVR als frische Prüfung. Offen: Ob der Sinkflug der Gains selbst (SG 1,0 auf 0,55 bis t3000) daraus folgt.
Baut auf: snai/torch-k1-gains, snai/adam-schatten, snai/gains-v-b
Rezepte:
  r543 [2026-11-03] rechner-b ~/snai_pruef/clip_torch: B2 aus snai/torch-wup-mechanismus (ohne Sonde), dazu SB2 (eins9.sh, beta2 0,99, sonde 100 bis t1000, Saaten 4-7) für u; TVR (kette8.sh nach TORCH7_ENDE): --v-reset 1001: an Schritt 1001 v_hat = g² aller Tensoren, Saaten 4-11, sonst wie TG. Ergebnis log/mess.jsonl, laeufe/TVR_s*, laeufe/SB2_s*/sonde.jsonl.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b ~/snai_pruef/clip_torch laeufe/B2_s*/ende.snai, laeufe/SB2_s*/sonde.jsonl
  m7981 u w_up L0-L3 an t1000 Mittel | 0,2260 0,2105 0,2125 0,2245 | SB2
  m7982 u w_up L2 an t1000 je Saat s4-s7 | 0,216 0,198 0,211 0,225 | SB2
  m7983 u w_up L2 an t1000 je Saat s4-s7 | 0,098 0,098 0,083 0,104 | SG
  m7984 L2 tot Mittel s4-s7, Verhältnis zu TG | 65,0 gegen 74,4 = 0,87 x, kleiner in 2/4 | B2
  Quelle: rechner-b ~/snai_pruef/clip_torch: aus.py, egf.py, sonde.jsonl, md5 von B2 snap_t1000 gegen SB2 ende; eigene Nachprüfung 02:30
  m7993 Kontrolle md5 B2 snap_t1000 gleich SB2 ende | bytegleich in 4/4 | SB2
  m7994 FFN tot L0-L3 Mittel | 0,0 3,3 65,0 1,8 | B2 |  | 4
  m7995 FFN tot L0-L3 Mittel | 0,0 1,3 67,2 0,6 | TG |  | 8
  m7996 Gain-RMS L2 an t1000 je Saat s4-s7 | 0,739 0,664 0,746 0,496 | SB2
  m7997 Gain-RMS L2 an t1000 je Saat s4-s7 | 0,817 0,824 0,779 0,748 | SG
  m7998 E, g_final, P Mittel s4-s7 | 0,1599; 0,9715; 0,1554 | B2 |  | 4
  m7999 E, g_final, P Mittel s4-s7 | 0,1166; 0,8683; 0,1012 | TG |  | 4
  Quelle: rechner-b ~/snai_pruef/clip_torch aus.py, egf.py, laeufe/TVR_s*
  m8028 FFN tot L0-L3 Mittel, 8 Saaten | 0,0 0,0 4,3 0,6 | TVR
  m8029 L2 tot je Saat s4-s11 | 0 1 1 2 27 1 0 3, gegen TG 88 32 81 96 66 62 39 73, kleiner 8/8, 0,06 x | TVR
  m8030 Held-out, D gegen TG | 2,7664; 0,0496 0,1035 0,1075 0,0965 0,085 0,1199 0,0871 0,0914, Mittel +0,0926, besser 0/8 | TVR
  m8031 RMS E und g_final Mittel | 0,1834 und 0,7841 gegen TG 0,1168 und 0,8694 | TVR
  m8032 Kosten Nullen FFN L1+L2+L3 (7 Saaten gelesen) | 0,2172 gegen TG 0,2320 | TVR
  Quelle: rechner-b ~/snai_pruef/clip_torch: Gains aus snap_t1000, snap_t3000, ende.snai (Leseweg wie aus.py), Held-out aus log/mess.jsonl; eigene Nachprüfung 04:05
  m8033 Gain-RMS L2 an t3000 je Saat s4-s11 | 0,54 0,68 0,56 0,45 0,56 0,54 0,68 0,54 | TG |  | 8
  m8034 Gain-RMS L2 an t3000 je Saat s4-s11 | 0,74 0,69 0,66 0,69 0,63 0,75 0,77 0,73 | TVR |  | 8
  m8035 Gain-RMS L2 am Ende je Saat s4-s11 | 0,03 0,39 0,09 0,02 0,20 0,17 0,41 0,15 | TG |  | 8
  m8036 Gain-RMS L2 am Ende je Saat s4-s11 | 1,00 0,97 0,80 0,82 0,34 1,02 1,00 0,89 | TVR |  | 8
  m8037 Held-out Mittel t1000 / t3000 / Ende | 3,2514 / 2,9612 / 2,6739 | TG |  | 8
  m8038 Held-out Mittel t1000 / t3000 / Ende | 3,2514 / 3,1474 / 2,7664 | TVR |  | 8
  m8039 Mittel-Trainingsloss über 9002 Schritte, s4 | 3,11864 gegen TG 2,97763 | TVR | 4
Ergebnis e483 [2026-11-03 03:55]: teilweise
  Fazit: Die beiden Eingriffe widersprechen sich, und das entscheidet die Frage. B2 nach Wortlaut WIDERLEGT: u L2 an t1000 0,2125 (über 0,15), trotzdem L2 tot 0,87 x TG. TVR senkt das Sterben kategorial (0,06 x, 8/8), weit über das TK-Chaos von 36 Punkten hinaus, kostet aber 3,5 % Held-out (8/8 schlechter) und hebt E auf 1,57 x. Wenn ein dauerhaft größeres u (B2) nicht rettet, ein einmaliger Neustart von v aber schon, ist der Überhang selbst nicht die Ursache: gewirkt hat der Stoß an t1001, nicht das Ende der kleinen Schritte. Deutung, nicht gemessen: Der Reset gibt allen Tensoren für einige Schritte u nahe 1 und wirft das Modell aus seinem Pfad; dass die Gains danach leben, sagt dann wenig über den Mechanismus. Für die Reparatur folgt: kein Adam-Fix. Und erneut gilt: lebende Gains und besserer Loss gehen nicht zusammen.
  Offen: Ob jeder Stoß zu dieser Zeit wirkt (Gegenprobe: zufälliger Stoß gleicher Größe, oder Reset an t3000 oder t5000) ist nicht gemessen. u bei TVR nicht gemessen (keine Sonde). Float, ein Rezept, 9.002 Schritte.
Chronik (juengste 8 von 12, voll=True zeigt alle):
  2026-11-03 02:27 Messwerte m7981-m7984
  2026-11-03 02:28 Messwerte m7993-m7999
  2026-11-03 02:28 Zwischenurteil 2026-11-03 02:35, TVR fehlt. Nach Wortlaut WIDERLEGT für B2: u L2 0,2125 >= 0,15 und L2 tot 0,87 x TG, kleiner in 2/4. Nachgeprüft: B2 an t1000 bytegleich mit SB2, u gehört also zu B2. Einschränkung: 4 Saaten, Einzelabstände -50 bis +59 Punkte, die Saaten laufen auseinander, B2 ändert auch das Rauschen in v. Beobachtung ohne Kriterium: In SB2 liegt u in allen Schichten gleich hoch (0,21 bis 0,23), trotzdem stirbt nur L2 (3/65/2). Die Schichtreihenfolge von u erklärt das Sterben damit hier nicht. SU lebt mit u L2 0,129 (1,2 % tot), B2 stirbt mit 0,2125: u an t1000 sagt über die Arme hinweg das Überleben nicht voraus. Gain L2 an t1000 in SB2 niedriger als in SG (Mittel 0,66 gegen 0,79). Daneben B2 E 1,37 x, g_final 1,12 x, P 1,54 x, Held-out +0,0315. Deutung, nicht gemessen: Kürzeres Gedächtnis beschleunigt auch die Gains, also kann B2 den Überhang nicht allein prüfen. Das Endurteil bleibt TVR überlassen.
  2026-11-03 03:55 Messwerte m8028-m8032
  2026-11-03 03:55 Ergebnis e483: teilweise
  2026-11-03 03:55 Status laeuft -> ausgewertet (Ergebnis e483)
  2026-11-03 03:56 Messwerte m8033-m8039
  2026-11-03 03:56 Einwände des Reihenautors zu e483 (2026-11-03 04:05), Urteil e483 bleibt bestehen. (1) Beide Lesarten fehlen: Nach Wortlaut erfüllt TVR die Ursachen-Klausel ("TVR senkt und TK-Chaos erklärt den Abstand nicht": 0,06 x, 8/8). Das muss dastehen. Die Klausel setzte aber voraus, dass TVR ein reiner Eingriff ist, und das ist er nicht, siehe (2). Zusammen mit B2 bleibt der Überhang deshalb nicht gestützt. (2) TVR war schlecht entworfen, mein Fehler: v_hat = g² eines einzelnen Fensters ist je Element stark gestreut. Elemente mit zufällig kleinem g bekommen ein sehr großes u, und v wächst danach nur mit 0,001 g² je Schritt nach, über einige hundert Schritte. Das ist kein Stoß mit "u nahe 1", sondern eine lange Phase großer, schwer verteilter Schritte. Held-out an t3000 ist 3,147 gegen 2,961, das Modell fällt fast auf den Stand von t1000 (3,251) zurück. (3) Kein Aufschub: Die Gains L2 sterben in TVR nicht später, sie wachsen nach t3000 wieder (Mittel 0,71 auf 0,86, TG 0,57 auf 0,18). Die Lesart "das Sterben wird nur über das Budget hinaus verschoben" ist damit ausgeschlossen. (4) Mehr Arbeit für FFN erklärt es nicht: Nullen-Kosten TVR 0,217 gegen TG 0,232. Saubere Gegenprobe, nicht gestartet: an t1001 v auf einen glatten Schätzer setzen (parallel mitlaufendes v mit Beta2 0,99 oder Mittel g² der letzten 100 Fenster), also Überhang weg ohne schwer verteilten Stoß. Rettet das nicht, ist der Überhang erledigt. Dazu der Vorschlag von snai_int8_lora: Zufallsstoß gleicher Verschiebung, Reset an t3000 bzw. t5000.
```
