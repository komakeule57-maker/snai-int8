# snai/haupt-gegen-tempo

```text
snai/haupt-gegen-tempo - ausgewertet, angelegt 2026-11-09, zuletzt 2026-11-09 08:20
Frage: Wie viel schneller ist der neue Tempo-Stand (par4: 9 PAR-Gruppen, MM-Blockpfad, GA-Vorstufen parallel) als der Hauptbaum, direkt gepaart über ~150 Schritte, und bleibt er bytegleich? (Auftrag 09.11.: „Ja, mach eine kurze Messung über ein paar hundert Schritte.“)
Kriterium (festgelegt 2026-11-09 04:57, vor dem ersten Messwert):
  A = Hauptbaum-Lib 1eb78bc1 (Kopie haupt/proj = par4/proj, nur libcortex.so getauscht, diff -rq außerhalb factory zeigt nur die Lib), B = par4-Lib 5a8676fc (par4/proj). prod512b-Umgebung wie arm.sh, Basis s11, n=4, Messtext haupt/text_lang.txt (text.txt + Korpus hf_GEN in Sortierfolge, 563000 Byte, b054976e), ~150 Schritte je Lauf. Zwei Blöcke AB/BA, 4 Läufe, ~300 Schritte je Arm.
(1) BYTEGLEICH: out.snai-md5 und Loss-md5 in allen 4 Läufen gleich. Sonst ist B kein reiner Tempo-Umbau, Tempo wird nur berichtet.
(2) TEMPO: B/A je Block aus [Bilanz] ms/Schritt. SCHNELLER, wenn beide Blöcke < 0,90; GLEICHSTAND, wenn beide in 0,90-1,10; sonst nicht aufgelöst. Kein Intervall (2 Blöcke); die Streuung je Block lag in den Fein-Reihen bei 2-3 %, der erwartete Abstand (Summe der Einzelreihen ~0,62) liegt weit darüber.
Nur berichtet: Faktor gegen die verkettete Erwartung aus den Einzelreihen; Schritte je Lauf, rc, .err.
Einschränkung vorab: nur rechner-a, nur n=4, nur CPU-Pfad (SNAI_FORCE_CPU=1), ein Messtext.
Rezepte:
  r642 [2026-11-09] setsid nohup ~/snai_pruef/threads/haupt/reihe_h.sh (h0_haupt, h0_neu, h1_neu, h1_haupt)
      quelltext: haupt/arm.sh d3310672 (aus par4/arm.sh dc016fc1 per assert: Projektordner als Argument, Messtext text_lang.txt, lib-md5 in der Ergebniszeile), reihe_h.sh ed1ceffb; Libs 1eb78bc1 / 5a8676fc
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/threads/haupt/ergebnis.txt, log/
Messwerte (Groesse | Wert | Arm | Start | n):
  m9713 bytegleich 4 Läufe | md5 c34081b2 / lossmd5 d1e93990 in allen 4 | rc 0 ×4, .err 0 Byte ×4, 184/184 Schritte je Lauf
  m9714 h0_haupt ms/Schritt | 8434,3 | A, Lib 1eb78bc1, real 1553 s
  m9715 h0_neu ms/Schritt | 5397,7 | B, Lib 5a8676fc, real 995 s
  m9716 h1_neu ms/Schritt | 5368,4 | B, real 989 s
  m9717 h1_haupt ms/Schritt | 8434,5 | A, real 1553 s
  m9718 B/A Block h0 | 0,640
  m9719 B/A Block h1 | 0,636
  m9720 B/A gesamt (Summe) | 0,638 | nur berichtet; verkettete Erwartung aus den Einzelreihen ~0,62
  m9721 Übernahme: Lib aus Hauptbaum-cortex.nim 96cb5b6d gebaut | ba130515 (md5 weicht von par4 5a8676fc ab, eingebettete Pfade) | u_neubau 184 Schritte n4: md5 c34081b2 / lossmd5 d1e93990 = bytegleich, 5376,9 ms/Schritt, rc 0, .err leer
  m9722 Commit Hauptbaum | 4a62d92 | cortex.nim + Abschnitt in den Projektregeln; libcortex.so ba130515 installiert (nicht versioniert), alte Lib 1eb78bc1 gesichert unter haupt/uebernahme/
Ergebnis e579 [2026-11-09 06:33]: erfuellt
  Fazit: (1) bytegleich in allen 4 Läufen, (2) B/A 0,640 und 0,636, beide < 0,90 -> SCHNELLER: der neue Stand braucht 36 % weniger Zeit je Schritt (8,43 -> 5,38 s bei n4, rechner-a, 184 Schritte prod512b), das Training ist 1,57-mal so schnell. Die Verkettung der Einzelreihen (~0,62) trifft fast; die Einzelgewinne addieren sich also wie erwartet. Fazit: Der Umbau ist reif für den Hauptbaum. Offen und nicht gemessen: andere Threadzahlen als 4, andere Rechner (rechner-b, vserver), GPU-Pfad. Vor dem Ausrollen auf vserver (nach s15) dort eine kurze Bytegleich- und Tempoprobe.
Chronik:
  2026-11-09 04:57 angelegt
  2026-11-09 04:57 Rezept r642
  2026-11-09 04:57 Status geplant -> laeuft (Rezept r642)
  2026-11-09 06:33 Messwerte m9713-m9720
  2026-11-09 06:33 Ergebnis e579: erfuellt
  2026-11-09 06:33 Status laeuft -> ausgewertet (Ergebnis e579)
  2026-11-09 08:20 Messwerte m9721, m9722
```
