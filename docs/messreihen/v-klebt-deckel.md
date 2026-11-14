# snai/v-klebt-deckel

```text
snai/v-klebt-deckel - ausgewertet, angelegt 2026-11-02, zuletzt 2026-11-03 01:51
Frage: Haelt ein Deckel auf den Adam-Schritt (|m_hat/(sqrt(v_hat)+eps)| <= 3,16, die Schranke des echten Adam) das Aufblaehen der w_up-Spalten toter Kanaele ab s8 ab, und aendert das Norm, Lernen oder tote Gains? Dritter Arm zu snai/v-klebt-lauf, weil die Klemme auf Code 1 rechnerisch nur etwa 2,7-fach mindert.
Kriterium (festgelegt 2026-11-02 16:07, vor dem ersten Messwert):
  Wie snai/v-klebt-lauf (kriterien_lauf.txt): Start chin_c128sr_s7, s8 LR 1e-4, s9 LR 5e-5, je ein voller Durchgang chin/train.txt, Namen c128sr/vk2/vk3 fuer die Paarung, Kopie proj_vk2 = proj_vk0 plus EIN Stellrad SNAI_V_DECKEL=1 im Pfad der quantisierten Momente (Schritt vor Decay auf [-3,16; 3,16] begrenzt; die Schranke (1-b1)/sqrt(1-b2) bindet im echten Adam nie). Klemme aus. Rechner rechner-b CPU, 3 zugleich. Groessen wie v-klebt-lauf: GN (Median letzte 5.000 geloggte Schritte s9), G (Held-out s7 minus s9, 700 Fenster), T (tote Gains L1+L2); dazu S = RMS je Element der w_up-Spalten der 110 toten L1-Kanaele an s8 und s9 (spalten.php), Vorhersage aus snai/tote-spalten-wachsen: Aus-Arm 5x das Gleichgewicht 0,57 x sqrt(lr/0,2), Deckel-Arm hoechstens 2x. Urteil je Groesse wie v-klebt-lauf (3/3 Reihenfolgen, 10 %, 1 Punkt knapp); S: HAELT AB = Deckel-Arm S <= 2 x Gleichgewicht in 3/3 an s8, sonst nicht. Kontrollen: K1 Deckel-Arm r1 zeichengleich mit dem Original bis zur ersten Wirkung (erster abweichender Schritt wird berichtet), Chunk-md5 je Name gleich den rechner-a-Armen; Rot: Aus-Arm zeigt den Sprung (S 5x) und [VD]-Zeile "v-Deckel 1" im Deckel-Log; rc 0, STEPS_DONE 153241, Fehlerkanal leer. Reichweite: ein Modell, ein Startstand, Abkuehlende; Deckel ist ein Kandidat, kein Fix im Projektbaum.
Baut auf: snai/v-klebt-lauf, snai/tote-spalten-wachsen
Rezepte:
  r538 [2026-11-03] rechner-b ~/snai_pruef/vkd: setsid ./schlange.sh, je Name lauf_vkd.sh <c128sr|vk2|vk3>, Kopie proj_vk2 mit SNAI_V_DECKEL=1, Lib 3713a250, Start chin_c128sr_s7, s8 LR 1e-4, s9 LR 5e-5. Logs log/a2_*, fortschritt.log. Gestartet 2026-11-02 16:10.
Messwerte (Groesse | Wert | Arm | Start | n):
  m7922 Stand 2026-11-03 00:15 | s8 noch nicht fertig: Schritt 145.600 / 142.615 / 139.650 von 153.241; S folgt am fertigen s8
  m7923 K1 Deckel c128sr gegen Original | zeichengleich bis Schritt 3, erster abweichender geloggter Schritt 4 (Loss 2,207168 gegen 2,206160, GN 6,1748 gegen 6,1569)
  m7924 Chunk-md5 je Name s8 | 2dd9a7b9 in allen drei, gleich den rechner-a-Armen (dort vk2 s9 gelesen, Vergleich s8 nach Fertigstellung)
  m7925 Fehlerkanal bisher | Fatal, NaN, VETO 0; 2 NET2NET-Meldungen beim Laden wie Original, korrigiert 0; [VD] v-Deckel 1 in allen drei
  m7956 S Deckel s8 c128sr / vk2 / vk3 | 0,0771 / 0,0773 / 0,0793
  m7957 S / Gleichgewicht 0,57·sqrt(lr/0,2) | 6,05 / 6,07 / 6,22; Original 8,90; Klemme 1,00-1,01
  m7958 v0m Deckel | 0,998 in 3/3
  m7959 GN s8 Median letzte 5.000 geloggte, Deckel c128sr / vk2 / vk3, Original | 8,664 / 8,674 / 8,649, 8,659
  m7960 Tote L1 | 116 in 3/3
  m7961 Kontrollen | STEPS_DONE 153241 in 3/3; Fatal, NaN, VETO 0; rc 0; [VD] 1; Chunk 2dd9a7b9 in 3/3; Vergleich rechner-a nur über s9, s8-Chunk dort nicht mehr vorhanden
  m7962 Abbruch | s9 nach dem S-Urteil gestoppt, s8-Stände bleiben; Grund: Deckel hält nicht ab und ändert die Norm nicht, Klemme ist besser, rechner-b überbucht
Ergebnis e479 [2026-11-03 01:51]: verfehlt
  Fazit: Nach Wortlaut HÄLT NICHT AB: Deckel S 6,05 bis 6,22 x Gleichgewicht in 3/3 an s8 (Schwelle 2 x; Original 8,90, Klemme 1,00). Norm unverändert (8,65-8,67 gegen 8,66). Meine Vorhersage war doppelt falsch: Der Deckel bleibt weit über dem erwarteten Wert, die Klemme liegt weit darunter (1 x statt rund 3 x). Der Deckel scheidet als Kandidat aus. G und T an s9 sind nicht gemessen, weil s9 nach diesem Urteil abgebrochen wurde; Reichweite ein Modell, ein Startstand, Abkühlende. Der Fix-Kandidat bleibt die Klemme aus snai/v-klebt-lauf.
Chronik:
  2026-11-02 16:07 angelegt
  2026-11-03 00:16 Rezept r538
  2026-11-03 00:16 Status geplant -> laeuft (Rezept r538)
  2026-11-03 00:16 Messwerte m7922-m7925
  2026-11-03 01:51 Messwerte m7956-m7962
  2026-11-03 01:51 Ergebnis e479: verfehlt
  2026-11-03 01:51 Status laeuft -> ausgewertet (Ergebnis e479)
```
