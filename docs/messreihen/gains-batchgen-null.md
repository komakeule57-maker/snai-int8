# snai/gains-batchgen-null

```text
snai/gains-batchgen-null - ausgewertet, angelegt 2026-11-04, zuletzt 2026-11-04 08:37
Frage: Tragen die FFN-Zweige in den k16R-Endständen (16 Fenster je Update, lebende Gains) etwas, gemessen durch Nullen von w_down, und mehr als in k1 (Gains in L2 tot)? Vorschlag snai_int8_lora nach e517, Freigabe für Tests.
Kriterium (festgelegt 2026-11-04 08:25, vor dem ersten Messwert):
  Kein Training. Stände: Endstände clip_s<saat>.snai aus rechner-a ~/snai_pruef/clip/laeufe/batchgen/{k16R,k1}_s4..s11 (Lib proj_bs dbbbf92d, wie beim Training gemessen).
Arme je Stand:
- A0: unverändert.
- NF2: w_down von L2 = 0.
- NF123: w_down von L1, L2 und L3 = 0.
- NF0: w_down von L0 = 0, Positivkontrolle.
Werkzeug: nullsetzen.php (rechner-b ms_null/werkzeug, md5 41b71f14) und mess_text.php (711d8187), heldout.txt, 700 Fenster, cwd = Laufordner.
D_x = Loss(NF_x) − Loss(A0) in nats, also D0 = Loss(NF0) − Loss(A0).

URTEIL je Größe (D2 Haupt, weil nur L2 in k1 tote Gains hat: k1 L0 0 %, L1 ≤ 3,1 %, L3 ≤ 1,6 %; D123 Neben), nur an k16R:
- BEITRAG: D ≥ 0,05 in ≥ 6/8.
- OHNE BEITRAG: D ≤ 0,02 UND D ≤ 0,2·D0 in ≥ 6/8.
- Sonst OFFEN.
- Ein Wert innerhalb 0,005 um eine Schwelle zählt nicht als erfüllt.

VERGLEICH gepaart je Saat, Δ = D(k16R) − D(k1), für D2 und D123:
- MEHR: Δ > 0 in ≥ 6/8 UND Mittel ≥ 0,02.
- GLEICH: |Mittel| < 0,01.
- Sonst OFFEN.
- Median und Bootstrap-95 werden mitberichtet, 6/8 ist kein Signifikanzurteil.

GERÄT, vor dem Lesen der Urteile:
- A0-Loss = Loss am Ende aus mess.jsonl des Laufs, in 16/16.
- md5 von A0 = Original.
- md5 der NF-Arme ≠ Original.
- D0 ≥ 0,05 in 16/16. Das ist die Rot-Probe: Die Sonde muss Schaden sehen können.
- Fehlerkanal je Messpunkt (null.err, mess.err) wird vor dem Lesen der Urteile angesehen. Eine NET2NET-GUARD-Meldung bei k1 ist erwartet: Der Wächter meldet nur (m7561), die A0-Gleichheit zeigt, dass er nichts verändert.

EINSCHRÄNKUNGEN, vorab:
- k16R hat 16-mal so viel Rechnung und einen um 0,53 besseren Held-out. Ein MEHR sagt deshalb nicht, dass die lebenden Gains die Ursache sind. Es sagt nur, dass die Zweige im besseren Modell mehr tragen.
- Nullen ohne Nachtraining misst, was das fertige Modell nutzt. Ob es ohne den Zweig gleich gut gelernt hätte, misst es nicht (dazu snai/ffn2-null-training).
- Absolute Schwellen in nats wie in snai/gains-nf-ratsche-b (e464), zur Vergleichbarkeit. Sie sind frei gewählt. 0,05 nats sind 2,3 % des Loss von k16R.
- Reichweite: 128x4 int8, ein Text, LR 0,003, 9.002 Updates, 8 Saaten, ohne Eingangsfaktor.

PRÜFER 2026-11-04 (Gemini, Mistral):
- „D0 widersprüchlich“: Missverständnis, D0 ist jetzt ausgeschrieben.
- „Rechenmenge konfundiert“: übernommen als Einschränkung.
- „w_down=0 falsches Maß“: verworfen. Das Nullen nimmt den Ausgang des Zweigs exakt heraus und misst die Nutzung im fertigen Modell, dieselbe Bauart wie e464 und e485.
- „6/8 schwach“: Bootstrap wird mitberichtet, die Regel bleibt.
- „Absolute Schwellen“: bleiben, zur Vergleichbarkeit.
Baut auf: snai/gains-batchgen, snai/gains-nf-ratsche-b
Rezepte:
  r570 [2026-11-04] cd ~/snai_pruef/clip/null_bg && ./lauf.sh k16R 4 (Probe), dann printf '%s\n' "k16R 5" ... "k16R 11" "k1 4" ... "k1 11" | xargs -P 3 -L 1 ./lauf.sh
      quelltext: null_bg/lauf.sh, nullsetzen.php 41b71f14 (Kopie von rechner-b ms_null/werkzeug), text/mess_text.php 711d8187, Lib gradnorm/proj_bs dbbbf92d
      rechner: rechner-a CPU, 3 parallel, 1 Thread
      logs: rechner-a:~/snai_pruef/clip/null_bg/ (erg.jsonl, log/)
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a ~/snai_pruef/clip/null_bg/ausgabe_20261104.txt (auswerten.py auf erg.jsonl, 64 Messpunkte)
  m8659 Geraet A0 = mess.jsonl Ende, md5 A0 = Original, md5 NF != Original | 16/16 | k16R,k1 | 4-11 | 16
  m8660 Geraet D0 (w_down L0 = 0) | 4,52 bis 5,68 | k16R | 4-11 | 8
  m8661 Geraet D0 (w_down L0 = 0) | 3,25 bis 5,96 | k1 | 4-11 | 8
  m8662 Fehlerkanal mess.err und null.err | 0 Byte Meldungen in 64/64 (null.err nur Erfolgszeilen) | k16R,k1 | 4-11 | 16
  m8663 D2 je Saat s4-s11 | 0,0199 0,0154 0,0259 0,0089 0,0149 0,0027 0,0151 0,0062 | k16R | 4-11 | 8
  m8664 D2 Mittel / Median | 0,0136 / 0,0150 | k16R | 4-11 | 8
  m8665 D2 je Saat s4-s11 | -0,0003 0,0195 0,0044 0,0013 -0,0015 0,0042 -0,0013 -0,0001 | k1 | 4-11 | 8
  m8666 D2 Mittel / Median | 0,0033 / 0,0006 | k1 | 4-11 | 8
  m8667 D123 je Saat s4-s11 | 0,2837 0,3302 0,3828 0,3564 0,3625 0,3356 0,2749 0,2896 | k16R | 4-11 | 8
  m8668 D123 Mittel / Median | 0,3270 / 0,3329 | k16R | 4-11 | 8
  m8669 D123 je Saat s4-s11 | 0,2558 0,2332 0,1742 0,2303 0,1199 0,2211 0,2053 0,1878 | k1 | 4-11 | 8
  m8670 D123 Mittel / Median | 0,2034 / 0,2132 | k1 | 4-11 | 8
  m8671 Urteil D2 k16R: BEITRAG >= 0,05 / OHNE <= 0,02 | 0/8 / 7/8 roh, 4/8 ohne Knapp-Zone | k16R | 4-11 | 8
  m8672 Urteil D123 k16R: BEITRAG >= 0,05 | 8/8 (kleinster 0,2749) | k16R | 4-11 | 8
  m8673 Delta D2 k16R-k1 Mittel, Median, Boot95, positiv | 0,0103; 0,0120; 0,0038 bis 0,0164; 6/8 | k16R | 4-11 | 8
  m8674 Delta D123 k16R-k1 Mittel, Median, Boot95, positiv | 0,1235; 0,1082; 0,0792 bis 0,1716; 8/8 | k16R | 4-11 | 8
Ergebnis e518 [2026-11-04 08:37]: teilweise
  Fazit: Geprüft vor den Urteilen: A0 = Trainingsmessung in 16/16, D0 >= 4,5 überall, Fehlerkanal leer.

Urteile nach Wortlaut:
- D2 (L2) an k16R OFFEN: 0,0136 im Mittel, OHNE BEITRAG nur 4/8 außerhalb der Knapp-Zone.
- D123 (L1 bis L3) BEITRAG, 8/8, 0,33 im Mittel.
- Vergleich mit k1: bei D2 OFFEN (Δ 0,010, 6/8), bei D123 MEHR (Δ 0,12, 8/8).

Folge: Der durch 16 Fenster belebte L2-Zweig trägt kaum mehr als der tote in k1. Lebende L2-Gains sind auch bei weniger Rauschen kein Zeichen für einen nützlichen Zweig, wie in e464 und e512. Das größere D123 entfällt auf L1 und L3, deren Gains in beiden Armen leben, und ist eine Eigenschaft des besser trainierten Modells (16-mal so viel Rechnung), nicht der Gains.

Deutung, nicht gemessen: Nullen kostet in k1 0,20 nats, Weglassen von Anfang an kostet in 8 Bit fast nichts (e485, e511). Das spricht für redundante Kapazität.

Auf dieser Linie lohnt keine Folgereihe. Offen bleibt einzig, ob Rechenmenge oder Rauschlast das größere D123 macht. Dafür bräuchte es ein Training mit k1 bei gleicher Zahl an Fenstern, das ist nicht gestartet.
  Offen: L1 und L3 einzeln sind nicht genullt worden. Rechenmenge gegen Rauschen ist nicht getrennt. Nur ein Text, 9.002 Updates, ohne Eingangsfaktor.
  Datei: rechner-a:~/snai_pruef/clip/null_bg/ERGEBNIS_null_bg.md
Chronik:
  2026-11-04 08:25 angelegt
  2026-11-04 08:28 Rezept r570
  2026-11-04 08:28 Status geplant -> laeuft (Rezept r570)
  2026-11-04 08:37 Messwerte m8659-m8674
  2026-11-04 08:37 Ergebnis e518: teilweise
  2026-11-04 08:37 Status laeuft -> ausgewertet (Ergebnis e518)
```
