# snai/torch-emb-eingang

```text
snai/torch-emb-eingang - ausgewertet, angelegt 2026-11-03, zuletzt 2026-11-03 07:21
Frage: Arbeiten die mittleren FFN-Zweige mit (und bleibt der Held-out mindestens gleich), wenn das gebundene Embedding nur am Eingang mit sqrt(d)=11,3137 multipliziert wird (Gemma-Art, Ausgabe unverändert)? Vorschlag multi_stack/Evo; Bezug Takase u. a. (Scaled Embed).
Kriterium (festgelegt 2026-11-03 04:54, vor dem ersten Messwert):
  Arm TEE gegen TG (Torch-Nachbau float32, K1-Rezept, LR 0,003 konstant, Warmup 500, WD 0,1, Clip 1, kurz9000, 9.002 Schritte), Saaten 4-11, gleiche Genesis clip_gen_s<s> und gleiche Fenster wie TG, also gepaart. Einziges Stellrad: torch_k1e.py --emb-ein 11.3137085 (Kopie von torch_k1.py, assert-gesicherte Ersetzung; Faktor 1 bytegleich mit Original, md5 2fd34e90 nach 30 Schritten; Faktor 11,31 weicht ab). Zusaetzlich --gn-log 100 (nur Ausgabe, kein Eingriff) fuer den Clip-Anteil.
Messung: Engine mess_text.php, Held-out 700 Fenster, int8 beim Laden, am Endstand. Messform: Slot emb = emb·F, Slot w_out = emb (Engine liest w_out getrennt: Slot genullt ergibt 7,3192 = ln 1509, Rotprobe gesehen). Rohform roh_ende.snai fuer E und g_final.
SCHRITT 0, MANIPULATIONSPRUEFUNG (vor jedem Urteil): EINGRIFF WIRKT, wenn (a) F·RMS E(TEE, roh, Ende) >= 3 x RMS E(TG, Ende) in >=6/8 UND (b) Zweig/R in L0 (groesserer Zweig, Messung multi_stack quelle2/m2.sh) bei TEE <= 1/3 des TG-Werts in >=6/8. Ist (a) oder (b) nicht erfuellt, lautet das Urteil "Eingriff ausgeglichen, keine Aussage zur Hypothese"; Haupt- und Nebengroesse werden dann nur als Beobachtung berichtet.
Hauptgroesse D = L(TEE) - L(TG) je Saat. BESSER: Mittel <= -0,02 und D<0 in >=6/8. SCHLECHTER: Mittel >= +0,02 und D>0 in >=6/8. GLEICH: |Mittel| < 0,01 und |D| < 0,02 in >=6/8. Sonst saatabhaengig, traegt keinen Schluss.
Nebengroesse MITARBEIT (mittlere FFN): Kosten n123 = L(FFN L1-L3 genullt) - L(Ende), je Saat gepaart. MITARBEIT erfuellt, wenn Kosten TEE >= 2 x Kosten TG in >=6/8 UND Anteil toter rms_ffn-Gains L2 (Schwelle 0,05, aus.py) TEE <= halber TG-Wert in >=6/8. Sonst nicht erfuellt. Vorab zur Deutung: Da TF0 GLEICH ergab (mittlere FFN in diesem Budget entbehrlich), ist ein Nein bei MITARBEIT erwartbar und kein Gegenbeleg gegen die Embedding-Spur.
Reparaturkandidat nur bei EINGRIFF WIRKT, Haupt nicht SCHLECHTER und MITARBEIT erfuellt.
Gemeinsam veraendert (vorab aufgezaehlt): (1) Eingangsskala des Residuals und damit Zweig/Residual-Verhaeltnis; (2) unter Tying das Verhaeltnis Eingangs- zu Ausgabegradient am Embedding (Eingangsseite x F); (3) Gradientennorm (Schritt 3: 14,15 gegen 2,25), damit Clip-Anteil; unter Adam weitgehend normiert, ein stark verschiedener Clip-Anteil wird als Nebenbefund genannt, nicht als Stoergroesse. Groesster freier Parameter: F selbst (ein Wert, sqrt(d)); ein Nein gilt nur fuer F=11,31 in diesem Rezept.
Beobachtung ohne Urteil: tote Gains je Schicht, g_final, RMS E (roh), n2-Kosten, D an t1000/t3000, Zensus und Zweigverhaeltnisse von multi_stack an Ende, t1000, t3000.
Kontrollen: rc=0 und 9.002 Schritte je Saat, Fehlerkanal mess.err je Messpunkt, TG-Werte aus vorhandenem log/mess.jsonl (nicht neu gerechnet).
Darauf baut: snai/engine-emb-eingang, snai/torch-v-getrennt, snai/torch-emb-leiter
Rezepte:
  r548 [2026-11-03] rechner-b ~/snai_pruef/clip_torch/kette_tee.sh (wartet auf NACH_ENDE der EF0-Nachkontrolle) -> xargs -P 2 eins_tee.sh TEE <s> (s 4-11): torch_k1e.py train clip_gen_s<s>.snai fen/f_s<s>.bin --koepfe 8 --lr 0.003 --lr-konst --snapshots 1000,3000 --emb-ein 11.3137085; Messung mess_text.php 700 an snap_t1000, snap_t3000, ende, dazu n2/n123 via nullv5.py -> log/mess.jsonl; Laufzeitzeilen log/lauf.log
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b ~/snai_pruef/clip_torch/log/mess.jsonl, laeufe/TEE_s*/ (roh_*.snai fuer E), ausw_tee.py -> log/tee_ausw.txt
  m8092 Kontrollen rc / Fehlerkanal Messung | rc=0 in 8/8; mess.err nur "INFO: m/v sind leer -> Cold Start" (Laden eines Torch-Stands), kein NET2NET, kein korrigiert | TEE | s4-s11 | 8
  m8093 Schritt 0 (a) F*E(TEE roh)/E(TG) t1000 | 10,88 / 10,83 / 10,81 / 10,82 / 10,99 / 10,96 / 10,84 / 10,95; >= 3 in 8/8 | TEE gegen TG | s4-s11 | 8
  m8094 Schritt 0 (a) t3000 | 10,73 / 10,69 / 10,77 / 10,65 / 10,74 / 10,75 / 10,67 / 10,75; >= 3 in 8/8 | TEE gegen TG | s4-s11 | 8
  m8095 Schritt 0 (a) Ende | 11,22 / 11,11 / 11,17 / 11,14 / 11,16 / 11,13 / 11,19 / 11,04; >= 3 in 8/8 (E roh TEE 0,1151, TG 0,1168: E schrumpft nicht um F) | TEE gegen TG | s4-s11 | 8
  m8096 Schritt 0 (b) Zweig/R L0 | ausstehend, Messung multi_stack quelle2/m2.sh | TEE gegen TG | s4-s11 | 8
  m8097 Held-out Ende TEE | 2,6121 / 2,6323 / 2,6414 / 2,6575 / 2,6220 / 2,6269 / 2,6690 / 2,6365, Mittel 2,6372 | TEE | s4-s11 | 8
  m8098 Held-out Ende TG | 2,6506 / 2,6763 / 2,6640 / 2,6961 / 2,6516 / 2,6686 / 2,7216 / 2,6621, Mittel 2,6739 | TG | s4-s11 | 8
  m8099 D = TEE - TG je Saat | -0,0385 / -0,0440 / -0,0226 / -0,0386 / -0,0296 / -0,0417 / -0,0526 / -0,0256; Mittel -0,0367; besser 8/8; Bootstrap 95 % -0,0432 bis -0,0302; 1,4 % von TG | TEE gegen TG | s4-s11 | 8
  m8100 D an t1000 / t3000 Mittel | -0,0166 / -0,0385 | TEE gegen TG | s4-s11 | 8
  m8101 n123-Kosten (FFN L1-L3 genullt) je Saat | TEE 0,206 / 0,224 / 0,138 / 0,222 / 0,215 / 0,166 / 0,230 / 0,229 (Mittel 0,2037); TG 0,268 / 0,145 / 0,254 / 0,260 / 0,208 / 0,213 / 0,280 / 0,228 (Mittel 0,2320); TEE >= 2 x TG in 0/8 | TEE, TG | s4-s11 | 16
  m8102 n2-Kosten Mittel | TEE 0,0139, TG 0,0012 | TEE, TG | s4-s11 | 16
  m8103 L2 rms_ffn tot Ende je Saat | TEE 1 / 3 / 13 / 1 / 7 / 3 / 1 / 2 %; TG 88 / 32 / 81 / 96 / 66 / 62 / 39 / 73 %; TEE <= TG/2 in 8/8 | TEE, TG | s4-s11 | 16
  m8104 tot Ende Mittel FFN L0-L3 / Attention L0-L3 | TEE 0 / 0 / 3,8 / 1,5 und 3,2 / 2,3 / 1,3 / 0,2; TG 0 / 1,3 / 67,2 / 0,6 und 30,2 / 1,3 / 0,3 / 0,1 | TEE, TG | s4-s11 | 16
  m8105 g_final RMS Ende Mittel | TEE 0,894, TG 0,869 | TEE, TG | s4-s11 | 16
  m8106 GradNorm-Log TEE (je 100 Schritte, n=90) | Median 1,06-1,12, Anteil > 1: 69-82 %; fuer TG nicht geloggt | TEE | s4-s11 | 8
  Quelle: multi_stack rechner-b ~/snai_pruef/nz/z5 (m2.sh, quelle2), zweig.py; Fehlerkanal 48x nur Cold Start
  m8143 Schritt 0 (b) max(Att/R, FFN/R) L0 TEE/TG t1000 | r 0,111-0,127 (TEE 11,7-13,4, TG 96,6-111,1); <= 1/3 in 8/8; lauter Zweig in beiden Armen FFN | TEE gegen TG | s4-s11 | 8
  m8144 Schritt 0 (b) t3000 | r 0,096-0,119; <= 1/3 in 8/8 | TEE gegen TG | s4-s11 | 8
  m8145 Schritt 0 (b) Ende | r 0,080-0,103 (TEE 7,6-9,1, TG 87,5-100,8); <= 1/3 in 8/8; nahe 1/F = 0,088 | TEE gegen TG | s4-s11 | 8
  m8146 R0 Vektornorm Residual vor L0, Ende | TEE 15,3-15,6, TG 1,38-1,42 | TEE, TG | s4-s11 | 16
  m8147 Att/R L0-L3 Median Ende | TEE 0,52 / 0,28 / 0,24 / 0,31; TG 0,43 / 0,25 / 0,29 / 0,36 | TEE, TG | s4-s11 | 16
  m8148 FFN/R L0-L3 Median Ende | TEE 8,3 / 0,125 / 0,097 / 0,325; TG 91,6 / 0,094 / 0,025 / 0,408; L2 unter TEE je Saat 1,5- bis 33-fach lauter | TEE, TG | s4-s11 | 16
Ergebnis e489 [2026-11-03 07:21]: teilweise
  Fazit: Schritt 0 erfuellt: (a) F*E/E_TG 10,7-11,2 in 8/8 an allen drei Staenden, (b) Zweig/R L0 TEE/TG 0,08-0,13 in 8/8. Hauptgroesse BESSER: D -0,0367, 8/8, Bootstrap -0,043 bis -0,030, 1,4 %. Tote L2-Gains 1-13 % gegen 32-96 % (8/8 unter der Haelfte), Attention L0 3 % gegen 30 %. MITARBEIT nicht erfuellt: n123-Kosten 0,204 gegen 0,232, 0/8 doppelt; damit ist nach Wortlaut kein Reparaturkandidat erfuellt. Zweigverhaeltnisse sprechen gegen "alle Zweige zu laut" (Attention L1-L3 gleich, FFN L2 viermal lauter) und fuer "E zu klein". Folge: Das Gain-Raetsel ist im Float an der Ursache gepackt (kleiner Eingang unter Bindung). Der Faktor geht als Kandidat in die 8-Bit-Engine (snai/engine-emb-eingang). Die mittleren FFN rettet er nicht, das Weglassen bleibt eine eigene Reparatur.
  Offen: Mechanismus der Verbesserung nicht isoliert. Nur F = sqrt(d), ein Text, 9.002 Schritte, float32. 8-Bit-Fassung laeuft.
  Datei: rechner-a:~/snai_pruef/clip_lns/ERGEBNIS_torch_emb_eingang.md
Chronik (juengste 8 von 9, voll=True zeigt alle):
  2026-11-03 04:53 Rezept r548
  2026-11-03 04:53 Status geplant -> laeuft (Rezept r548)
  2026-11-03 04:54 Kriterium geaendert, vorher: Arm TEE gegen TG (Torch-Nachbau float32, K1-Rezept, LR 0,003 konstant, Warmup 500, WD 0,1, Clip 1, kurz9000, 9.002 Schritte), Saaten 4-11, gleiche Genesis clip_gen_s<s> und gleiche Fenster wie TG, also gepaart. Einziges Stellrad: torch_k1e.py --emb-ein 11.3137085 (Kopie von torch_k1.py, assert-gesicherte Ersetzung; Faktor 1 bytegleich mit Original, md5 2fd34e90 nach 30 Schritten; Faktor 11,31 weicht ab).
Messung: Engine mess_text.php, Held-out 700 Fenster, int8 beim Laden, am Endstand. Messform: Slot emb = emb·F, Slot w_out = emb (Engine liest w_out getrennt: Slot genullt ergibt 7,3192 = ln 1509, Rotprobe gesehen). Rohform roh_ende.snai für E und g_final.
Hauptgröße D = L(TEE) - L(TG) je Saat. BESSER: Mittel <= -0,02 und D<0 in >=6/8. SCHLECHTER: Mittel >= +0,02 und D>0 in >=6/8. GLEICH: |Mittel| < 0,01 und |D| < 0,02 in >=6/8. Sonst saatabhängig, trägt keinen Schluss.
Nebengröße MITARBEIT (mittlere FFN): Kosten n123 = L(FFN L1-L3 genullt) - L(Ende), je Saat gepaart. MITARBEIT erfüllt, wenn Kosten TEE >= 2 x Kosten TG in >=6/8 UND Anteil toter rms_ffn-Gains L2 (Schwelle 0,05, aus.py) TEE <= halber TG-Wert in >=6/8. Sonst nicht erfüllt.
Reparaturkandidat nur bei Haupt nicht SCHLECHTER und MITARBEIT erfüllt.
Gemeinsam verändert (vorab aufgezählt): (1) Eingangsskala des Residuals und damit Zweig/Residual-Verhältnis am Start; (2) unter Tying das Verhältnis Eingangs- zu Ausgabegradient am Embedding (Eingangsseite x F); (3) Gradientennorm (Schritt 3: 14,15 gegen 2,25), damit Clip-Anteil; unter Adam weitgehend normiert, Clip-Anteil wird mitgeschrieben. Größter freier Parameter: F selbst (nur ein Wert, sqrt(d)); ein Nein gilt nur für F=11,31 in diesem Rezept.
Beobachtung ohne Urteil: tote Gains je Schicht, g_final, RMS E (roh), n2-Kosten, D an t1000/t3000, Zensus und Zweigverhältnisse von multi_stack an den Endständen.
Kontrollen: rc=0 und 9.002 Schritte je Saat, Fehlerkanal mess.err je Messpunkt, TG-Werte aus vorhandenem log/mess.jsonl (nicht neu gerechnet). | Grund: Einwand multi_stack/Evo vor dem Start (kein Messwert vorhanden): Manipulationsprüfung fehlte; gn-log fuer Clip-Anteil ergaenzt.
  2026-11-03 04:56 Ergänzung vor dem Start (Evo über multi_stack), der Wortlaut der Hauptregel bleibt unverändert.
(1) Fällt die Manipulationsprüfung durch, ist das ein eigener Befund: Das Modell zieht den großen Eingang gezielt zurück. Er steht dann neben dem Urteil „keine Aussage zur Hypothese“.
(2) Die Prüfung (a) und (b) wird auch an t1000 und t3000 abgelesen. Weichen (a) und (b) voneinander ab, werden beide berichtet, denn dann haben sich die Zweigausgaben selbst verändert.
(5) Deutung vorab: Wird TEE BESSER, trennt der Lauf „Embedding zu klein“ nicht von „Zweige überall zu laut“, der Richtung von LNS/TLS. Daneben wird Zweig/R in L1-L3 für TEE und TLS berichtet.
(4) Gradientenaufteilung am Startzustand, gemessen mit gradteil.py (echte Funktionen aus torch_k1e.py, Genesis s4, Fenster 0-2 ohne Update), Beobachtung an einer Saat:
F=1: gesamt 11,7/11,5/14,2, davon emb 3,0/2,9/3,5 (6 %) und Rest 11,3/11,1/13,7. emb-Gradient am Fenster 0: Eingangsseite 2,15, Ausgabeseite 2,13.
F=11,31: gesamt 1,9/2,0/2,2, davon emb 1,8/1,8/2,1 (86-87 %) und Rest 0,69/0,71/0,86. Eingangsseite 1,17, Ausgabeseite 1,35.
Damit ist meine frühere Lesart „Eingangspfad dominiert den Embedding-Gradienten“ WIDERLEGT, denn beide Seiten sind bei F=1 gleich groß. Der Rückgang der Norm kommt aus den übrigen Tensoren (rund 16-fach), so wie Evo es als Alternative genannt hat.
Nebenfolge: Unter TEE trägt das Embedding den Großteil der Gradientennorm. Clip 1 schneidet also anders zu, die Wirkung unter Adam ist offen.
  2026-11-03 06:35 Messwerte m8092-m8106
  2026-11-03 07:21 Messwerte m8143-m8148
  2026-11-03 07:21 Ergebnis e489: teilweise
  2026-11-03 07:21 Status laeuft -> ausgewertet (Ergebnis e489)
```
