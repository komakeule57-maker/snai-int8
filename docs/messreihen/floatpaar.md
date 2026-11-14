# snai/floatpaar

```text
snai/floatpaar - ausgewertet, begonnen 2026-10-13, angelegt 2026-10-21, zuletzt 2026-10-21 19:33
Frage: Knirps auf der Kopieraufgabe var (wort256, ctx 64, 2 Schichten, gebunden, 8-Bit-Gewichte in beiden Armen): (1) Verschiebt der Ganzzahl-Stack des Trainers (SNAI_INT8_FULL=1 gegen 0, ein Bündel aus Ganzzahl-Rückweg, Ganzzahl-Gradientensammeln, quantisierten Adam-Momenten, int8-FFN-Aktivierungen und SiLU-Tabelle) das Einsetzen des inhaltsbasierten Kopierens? (2) Ändert er vor dem Einsetzen den Anteil der V/O-Matrizen am Gradienten? Anlass: Nebenfund an der Drohne (V/O-Anteil mit Stack 35-38 %, ohne 25-26 %).
Kriterium (nachgetragen, Beleg: Kriterium aus rechner-a:~/snai_pruef/floatpaar/kriterien.txt (Haupttext und Nachtrag 1-4 vor dem ersten Reihenlauf, 2026-10-13; Freigabe des Prüfers für Stand Nachtrag 4: fahrt1/FREIGABE_nachtrag4.txt, 2026-10-13 08:33:20; Nachtrag 5 nach der ersten Fahrt, Datei zuletzt geändert 2026-10-13 10:27:23, sha256 0a55b2fc5b41... = abnahme/FREIGABE 10:38:59, danach unverändert).):
  Gepaart über denselben Laufnamen: Arm i (Stack an, proj_i) gegen Arm f (Stack aus, proj_f); Böden: Arm r (andere Reihenfolge) und Arm p (Warmup 501 statt 500, Störungs-Boden). Zellen A 32/1/32 und B 32/4/8 (LR 0,001, 60.000 Fenster, Raster 250), C 64/2/32 (LR 0,0001, 90.000 Fenster, Raster 500). Warmup 500, danach konstant, WD 0,1, Revival aus, 1 Arbeiter, 1 Thread, ein Traineraufruf je Lauf. Endpunkte: E1 = T50 (erster Messpunkt mit Rang 0 auf der zweiten Kopie >= 50 % und am nächsten Punkt auch); E2 = V/O-Anteil am Gradienten im festen Fenster 1000 < adam_t <= 4000 (A, B) bzw. <= 10000 (C); E2b = V/O-Anteil relativ zum eigenen Einsetzen (T50-3000..T50-1000 bzw. T50-10000..T50-2000); E3 Endstand nur Plausibilität (Nachtrag 4b). Urteil je Zelle und Endpunkt über 6 Paare, rel = (f-i)/i: 6 von 6 gleiche Richtung UND |Median rel| >= 10 % = VERSCHIEBT; |Median| < 10 % = GLEICHSTAND ("aufgelöst", wenn Störungs-Boden p/i < 10 %, sonst "nicht aufgelöst"); sonst UNEINHEITLICH (trägt keinen Schluss); weniger als 6 zählende Paare = NICHT ENTSCHEIDBAR. Zensur: einseitig nie im Budget zählt mit Mindestbetrag in Richtung "zensierter später", unter 10 % nicht. Mehrfaches Testen: VERSCHIEBT in nur einer Zelle = HINWEIS, Befund erst nach genau einer Wiederholung mit Saaten 7-12 (allein ausgewertet, gleiches Urteil, gleiche Richtung) oder wenn zwei Zellen gleichgerichtet VERSCHIEBT zeigen. Lesart: "Stack verteilt den Gradienten anders" nur, wenn E2 UND E2b gleichgerichtet VERSCHIEBT. Stufen: erst A und B (Saaten 1-6, Auffüllen 13-18), C läuft außer bei E1-Befund in A und B plus übereinstimmendem E2/E2b. Nachtrag 5 (nach Fahrt 1): nur das Messgerät gewechselt (mess_ow.php ohne Gain-Wächter), Stufe 1 mit denselben Saaten neu gefahren.
Plan: rechner-a:~/snai_pruef/floatpaar/AUFBAU.md
Baut auf: snai/kopier-knirps-gitter
Rezepte:
  r160 [2026-10-21] cd ~/snai_pruef/floatpaar && nohup setsid ./reihe.sh "1 2 3 4 5 6" "A B"  (dann "13" "B", "1 2 3 4 5 6" "C", "7 8 9 10 11 12" "C"); je Lauf: lauf.sh <arm> <zelle> <saat> -> kern.sh: env SNAI_TRAIN_MODE=pretrain SNAI_START_OFFSET=0 SNAI_INT8_FULL=$FULL SNAI_TIE_EMBEDDINGS=1 SNAI_WARMUP_STEPS=$WARM SNAI_TELEMETRY_STEPS=100 SNAI_SNAPSHOT_STEPS=$SNAPS nice -n 15 php train_cluster.php $IN $O 1 1 $GEN 3 $LR 0.0001 1 0.1
      quelltext: libcortex.so md5 1c634106f31c6f44735c16e21fdd81bc (proj_i = proj_f, Stand Drohne E/F); cortex.nim md5 2edca94faf6706cae208239d58f9f9e6; train_worker.php md5 af8e0a4ff398cb0a082f4e0329ba4f05; kern.sh 6d6500c6bd62d861d3e08ff700fe6e12; lauf.sh c749156d58e5bdebc87db44e0a0b4419; reihe.sh 30cdc9217b62c78af9ee5c89171614a0; auswert.py 7eb594220005c591b0ef428908ba17fc; Messgerät werkzeug/mess_ow.php 733561bb287741da8c28e09ee180580b; Manifeste abnahme/manifest_proj_*.txt
      parameter: A 32/1/32 und B 32/4/8: LR 0,001, 60.000 Fenster, Snapshot/Messung alle 250; C 64/2/32: LR 0,0001, 90.000, alle 500. Alle: 2 Schichten, ffn 4xBreite, ctx 64, wort256, Aufgabe var, gebunden, dtype 3, Warmup 500 (Arm p 501), konstant, WD 0,1, Revival aus, 1 Arbeiter, 1 Thread, CPU. Messung 200 Fenster, Mess-Saat 20261013, Rang 0 zweite Kopie (~5.200 Positionen).
      seed: Saat s = Genesis-Saat s (gitter_gen_d<B>h<K>_s<s>.snai) + Daten-Saat 2000+s + Laufname fp_d<B>h<K>_s<s> (Arm r: _r). Hauptreihe 1-6, Auffüllen B 13, Wiederholung C 7-12.
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/floatpaar/protokoll/{i,f,r,p}/fp_*.{train.log,mess.jsonl,mess.err,lauf.json}, reihe.log; Zwischenstände proj_*/factory/checkpoints
      notiz: Zweite (gewertete) Fahrt 2026-10-13 10:39-17:35: Stufe 1 10:39-12:05, Auffüllen B13 12:06-12:16, Stufe 2 (C) 12:17-14:56, Wiederholung C 14:57-17:35; 100 gewertete Läufe. Kontrollen K0-K16 vorher grün (abnahme/kontrollen_2026-10-13_1027.out, KONTROLLEN_BESTANDEN). Prüfung beim Nachtrag: T50 und Endstand aller 100 gewerteten Läufe aus protokoll/*/fp_*.mess.jsonl neu gerechnet (Regel: erster Punkt >= 50 % und nächster auch) - alle gleich dem Bericht. E2 für C Saat 1 und 7 (Arm i/f) aus den Telemetriezeilen der train.log nachgerechnet: 26,8/41,5 und 28,4/42,9 = Bericht. sha256 von kriterien.txt heute = FREIGABE (0a55b2fc...), also nach dem Start nicht geändert. In keinem train.log der Reihe eine NET2NET-GUARD- oder revivt-Zeile. Nicht nachgerechnet: E2b, die Medianwerte und Böden (aus auswert.py übernommen). Der frühere Befund spricht für Zelle 32/4/8 von "V/O fest VERSCHIEBT hoeher (6 von 6)" - das ist für sich nur ein HINWEIS und wird erst zusammen mit Zelle C zum Befund. Die Reihe steht auch in KOPIEREN_UEBERSICHT.md Abschnitt B. Anlass ist der Drohnen-Nebenfund (Reihe des Helfers technik, Bezug wird nachgetragen). Arbeitsblatt ~/snai_pruef/blatt.jsonl, Thema floatpaar: Kriterien-Einträge 21 und 45, Befunde 81, 84, 85, 86, 92, 94; Thema floatpaar-messgeraet Befunde 51 und 71 (Blattnummern).
  r161 [2026-10-21] Fahrt 1 (ungültig): wie Rezept der zweiten Fahrt, mit fahrt1/kern_vor_n5.sh und fahrt1/reihe_vor_n5.sh (Messgerät mess.php MIT Gain-Wächter)
      quelltext: fahrt1/kriterien_nachtrag4.txt (sha256 a9d6e45f...), Messgerät mess.php
      parameter: wie zweite Fahrt, Zellen A und B, Saaten 1-6 + Auffüllen B13
      seed: wie zweite Fahrt
      rechner: rechner-a
      logs: rechner-a:~/snai_pruef/floatpaar/fahrt1/protokoll/, fahrt1/waechter_beleg/guard_alle.tsv
      notiz: Erste Fahrt 2026-10-13 08:33-09:55, verworfen nach Nachtrag 5: der Gain-Wächter beim Laden verfälschte die Messung. Training selbst unberührt, Zwischenstände der zweiten Fahrt md5-gleich. Nur Beleg, keine zweite Lesart; keine Messwerte daraus eingetragen.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-a:~/snai_pruef/floatpaar/protokoll/bericht_2026-10-13_1735.txt (auswert.py); T50 aller Läufe aus protokoll/*/fp_*.mess.jsonl nachgerechnet (alle gleich), E2 für C Saat 1 (i/f) aus train.log nachgerechnet (gleich)
  m1796 E1 T50 Fenster | 7750 | A-i | 1 | 1
  m1797 E1 T50 Fenster | 7250 | A-f | 1 | 1
  m1798 E1 T50 Fenster | 6750 | A-i | 2 | 1
  m1799 E1 T50 Fenster | 5500 | A-f | 2 | 1
  m1800 E1 T50 Fenster | 5500 | A-i | 3 | 1
  m1801 E1 T50 Fenster | 5000 | A-f | 3 | 1
  m1802 E1 T50 Fenster | 6000 | A-i | 4 | 1
  m1803 E1 T50 Fenster | 4750 | A-f | 4 | 1
  m1804 E1 T50 Fenster | 6000 | A-i | 5 | 1
  m1805 E1 T50 Fenster | 7000 | A-f | 5 | 1
  m1806 E1 T50 Fenster | 7500 | A-i | 6 | 1
  m1807 E1 T50 Fenster | 6500 | A-f | 6 | 1
  m1808 E2 V/O-Anteil fest % | 25,4 | A-i | 1 | 1
  m1809 E2 V/O-Anteil fest % | 34,9 | A-f | 1 | 1
  m1810 E2b V/O-Anteil vor Einsetzen % | 39,8 | A-i | 1 | 1
  m1811 E2b V/O-Anteil vor Einsetzen % | 40,8 | A-f | 1 | 1
  m1812 E2 V/O-Anteil fest % | 22,9 | A-i | 2 | 1
  m1813 E2 V/O-Anteil fest % | 31,0 | A-f | 2 | 1
  m1814 E2b V/O-Anteil vor Einsetzen % | 34,5 | A-i | 2 | 1
  m1815 E2b V/O-Anteil vor Einsetzen % | 36,8 | A-f | 2 | 1
  m1816 E2 V/O-Anteil fest % | 21,9 | A-i | 3 | 1
  m1817 E2 V/O-Anteil fest % | 32,6 | A-f | 3 | 1
  m1818 E2b V/O-Anteil vor Einsetzen % | 30,7 | A-i | 3 | 1
  m1819 E2b V/O-Anteil vor Einsetzen % | 36,5 | A-f | 3 | 1
  m1820 E2 V/O-Anteil fest % | 25,6 | A-i | 4 | 1
  m1821 E2 V/O-Anteil fest % | 34,2 | A-f | 4 | 1
  m1822 E2b V/O-Anteil vor Einsetzen % | 34,9 | A-i | 4 | 1
  m1823 E2b V/O-Anteil vor Einsetzen % | 35,9 | A-f | 4 | 1
  m1824 E2 V/O-Anteil fest % | 23,5 | A-i | 5 | 1
  m1825 E2 V/O-Anteil fest % | 20,3 | A-f | 5 | 1
  m1826 E2b V/O-Anteil vor Einsetzen % | 34,3 | A-i | 5 | 1
  m1827 E2b V/O-Anteil vor Einsetzen % | 33,8 | A-f | 5 | 1
  m1828 E2 V/O-Anteil fest % | 24,2 | A-i | 6 | 1
  m1829 E2 V/O-Anteil fest % | 34,7 | A-f | 6 | 1
  m1830 E2b V/O-Anteil vor Einsetzen % | 38,2 | A-i | 6 | 1
  m1831 E2b V/O-Anteil vor Einsetzen % | 39,8 | A-f | 6 | 1
  m1832 E1 Median rel f/i % (UNEINHEITLICH; f groesser 1, kleiner 5) (n = Paare) | -11,2 | A f gegen i | 1-6 | 6
  m1833 E1 Stoerungs-Boden Median % (Hoechstwert 9,1) | 5,3 | A p gegen i | 1-6 | 6
  m1834 E1 Reihenfolge-Boden Median % (Hoechstwert 513,3) | 26,5 | A r gegen i | 1-6 | 6
  m1835 E2 Median rel f/i % (UNEINHEITLICH; f groesser 5, kleiner 1) (n = Paare) | +36,2 | A f gegen i | 1-6 | 6
  m1836 E2 Stoerungs-Boden Median % (Hoechstwert 6,3) | 2,7 | A p gegen i | 1-6 | 6
  m1837 E2 Reihenfolge-Boden Median % (Hoechstwert 47,2) | 12,2 | A r gegen i | 1-6 | 6
  m1838 E2b Median rel f/i % (GLEICHSTAND; aufgeloest; f groesser 5, kleiner 1) (n = Paare) | +3,5 | A f gegen i | 1-6 | 6
  m1839 E2b Stoerungs-Boden Median % (Hoechstwert 10,4) | 1,7 | A p gegen i | 1-6 | 6
  m1840 E2b Reihenfolge-Boden Median % (Hoechstwert 33,9) | 10,7 | A r gegen i | 1-6 | 6
  m1841 E3 Median rel f/i % (GLEICHSTAND; f groesser 6, kleiner 0) (n = Paare) | +0,8 | A f gegen i | 1-6 | 6
  m1842 E1 T50 Fenster | 12250 | B-i | 1 | 1
  m1843 E1 T50 Fenster | 20000 | B-f | 1 | 1
  m1844 E1 T50 Fenster | nie im Budget | B-i | 2 | 1
  m1845 E1 T50 Fenster | 19000 | B-f | 2 | 1
  m1846 E1 T50 Fenster | 16250 | B-i | 3 | 1
  m1847 E1 T50 Fenster | 19750 | B-f | 3 | 1
  m1848 E1 T50 Fenster | 15250 | B-i | 4 | 1
  m1849 E1 T50 Fenster | 17500 | B-f | 4 | 1
  m1850 E1 T50 Fenster | 16000 | B-i | 5 | 1
  m1851 E1 T50 Fenster | 20000 | B-f | 5 | 1
  m1852 E1 T50 Fenster | 16500 | B-i | 6 | 1
  m1853 E1 T50 Fenster | 20500 | B-f | 6 | 1
  m1854 E1 T50 Fenster | 53000 | B-i | 13 | 1
  m1855 E1 T50 Fenster | 14500 | B-f | 13 | 1
  m1856 E2 V/O-Anteil fest % | 14,3 | B-i | 1 | 1
  m1857 E2 V/O-Anteil fest % | 26,4 | B-f | 1 | 1
  m1858 E2b V/O-Anteil vor Einsetzen % | 32,0 | B-i | 1 | 1
  m1859 E2b V/O-Anteil vor Einsetzen % | 35,0 | B-f | 1 | 1
  m1860 E2 V/O-Anteil fest % | 8,1 | B-i | 2 | 1
  m1861 E2 V/O-Anteil fest % | 24,4 | B-f | 2 | 1
  m1862 E2b V/O-Anteil vor Einsetzen % | - | B-i | 2 | 1
  m1863 E2b V/O-Anteil vor Einsetzen % | 34,5 | B-f | 2 | 1
  m1864 E2 V/O-Anteil fest % | 17,1 | B-i | 3 | 1
  m1865 E2 V/O-Anteil fest % | 28,0 | B-f | 3 | 1
  m1866 E2b V/O-Anteil vor Einsetzen % | 26,2 | B-i | 3 | 1
  m1867 E2b V/O-Anteil vor Einsetzen % | 31,5 | B-f | 3 | 1
  m1868 E2 V/O-Anteil fest % | 20,6 | B-i | 4 | 1
  m1869 E2 V/O-Anteil fest % | 29,2 | B-f | 4 | 1
  m1870 E2b V/O-Anteil vor Einsetzen % | 35,8 | B-i | 4 | 1
  m1871 E2b V/O-Anteil vor Einsetzen % | 34,2 | B-f | 4 | 1
  m1872 E2 V/O-Anteil fest % | 21,6 | B-i | 5 | 1
  m1873 E2 V/O-Anteil fest % | 31,3 | B-f | 5 | 1
  m1874 E2b V/O-Anteil vor Einsetzen % | 23,6 | B-i | 5 | 1
  m1875 E2b V/O-Anteil vor Einsetzen % | 31,7 | B-f | 5 | 1
  m1876 E2 V/O-Anteil fest % | 24,2 | B-i | 6 | 1
  m1877 E2 V/O-Anteil fest % | 33,4 | B-f | 6 | 1
  m1878 E2b V/O-Anteil vor Einsetzen % | 27,6 | B-i | 6 | 1
  m1879 E2b V/O-Anteil vor Einsetzen % | 33,1 | B-f | 6 | 1
  m1880 E2 V/O-Anteil fest % | 6,8 | B-i | 13 | 1
  m1881 E2 V/O-Anteil fest % | 22,5 | B-f | 13 | 1
  m1882 E2b V/O-Anteil vor Einsetzen % | 7,9 | B-i | 13 | 1
  m1883 E2b V/O-Anteil vor Einsetzen % | 36,5 | B-f | 13 | 1
  m1884 E1 Median rel f/i % (UNEINHEITLICH; f groesser 5, kleiner 1) (n = Paare) | +22,9 | B f gegen i | 1-6/13 | 6
  m1885 E1 Stoerungs-Boden Median % (Hoechstwert 82,9) | 12,1 | B p gegen i | 1-6/13 | 7
  m1886 E1 Reihenfolge-Boden Median % (Hoechstwert 71,2) | 14,3 | B r gegen i | 1-6/13 | 7
  m1887 E2 Median rel f/i % (VERSCHIEBT; ueber dem Stoerungs-Boden; f groesser 6, kleiner 0) (n = Paare) | +54,2 | B f gegen i | 1-6/13 | 6
  m1888 E2 Stoerungs-Boden Median % (Hoechstwert 40,0) | 2,0 | B p gegen i | 1-6/13 | 7
  m1889 E2 Reihenfolge-Boden Median % (Hoechstwert 147,9) | 14,0 | B r gegen i | 1-6/13 | 7
  m1890 E2b Median rel f/i % (UNEINHEITLICH; f groesser 5, kleiner 1) (n = Paare) | +20,2 | B f gegen i | 1-6/13 | 6
  m1891 E2b Stoerungs-Boden Median % (Hoechstwert 9,3) | 3,2 | B p gegen i | 1-6/13 | 5
  m1892 E2b Reihenfolge-Boden Median % (Hoechstwert 260,4) | 19,8 | B r gegen i | 1-6/13 | 6
  m1893 E3 Median rel f/i % (GLEICHSTAND; f groesser 6, kleiner 0) (n = Paare) | +3,8 | B f gegen i | 1-6/13 | 6
  m1894 E1 T50 Fenster | 26000 | C-i | 1 | 1
  m1895 E1 T50 Fenster | 28000 | C-f | 1 | 1
  m1896 E1 T50 Fenster | 26500 | C-i | 2 | 1
  m1897 E1 T50 Fenster | 28000 | C-f | 2 | 1
  m1898 E1 T50 Fenster | 22500 | C-i | 3 | 1
  m1899 E1 T50 Fenster | 26500 | C-f | 3 | 1
  m1900 E1 T50 Fenster | 25500 | C-i | 4 | 1
  m1901 E1 T50 Fenster | 29500 | C-f | 4 | 1
  m1902 E1 T50 Fenster | 21000 | C-i | 5 | 1
  m1903 E1 T50 Fenster | 28500 | C-f | 5 | 1
  m1904 E1 T50 Fenster | 22500 | C-i | 6 | 1
  m1905 E1 T50 Fenster | 28000 | C-f | 6 | 1
  m1906 E2 V/O-Anteil fest % | 26,8 | C-i | 1 | 1
  m1907 E2 V/O-Anteil fest % | 41,5 | C-f | 1 | 1
  m1908 E2b V/O-Anteil vor Einsetzen % | 42,2 | C-i | 1 | 1
  m1909 E2b V/O-Anteil vor Einsetzen % | 42,3 | C-f | 1 | 1
  m1910 E2 V/O-Anteil fest % | 26,8 | C-i | 2 | 1
  m1911 E2 V/O-Anteil fest % | 41,5 | C-f | 2 | 1
  m1912 E2b V/O-Anteil vor Einsetzen % | 42,0 | C-i | 2 | 1
  m1913 E2b V/O-Anteil vor Einsetzen % | 42,2 | C-f | 2 | 1
  m1914 E2 V/O-Anteil fest % | 26,8 | C-i | 3 | 1
  m1915 E2 V/O-Anteil fest % | 42,2 | C-f | 3 | 1
  m1916 E2b V/O-Anteil vor Einsetzen % | 44,2 | C-i | 3 | 1
  m1917 E2b V/O-Anteil vor Einsetzen % | 42,4 | C-f | 3 | 1
  m1918 E2 V/O-Anteil fest % | 26,7 | C-i | 4 | 1
  m1919 E2 V/O-Anteil fest % | 42,1 | C-f | 4 | 1
  m1920 E2b V/O-Anteil vor Einsetzen % | 41,2 | C-i | 4 | 1
  m1921 E2b V/O-Anteil vor Einsetzen % | 41,6 | C-f | 4 | 1
  m1922 E2 V/O-Anteil fest % | 26,5 | C-i | 5 | 1
  m1923 E2 V/O-Anteil fest % | 41,9 | C-f | 5 | 1
  m1924 E2b V/O-Anteil vor Einsetzen % | 45,5 | C-i | 5 | 1
  m1925 E2b V/O-Anteil vor Einsetzen % | 41,9 | C-f | 5 | 1
  m1926 E2 V/O-Anteil fest % | 29,0 | C-i | 6 | 1
  m1927 E2 V/O-Anteil fest % | 43,1 | C-f | 6 | 1
  m1928 E2b V/O-Anteil vor Einsetzen % | 43,6 | C-i | 6 | 1
  m1929 E2b V/O-Anteil vor Einsetzen % | 41,8 | C-f | 6 | 1
  m1930 E1 Median rel f/i % (VERSCHIEBT; ueber dem Stoerungs-Boden; f groesser 6, kleiner 0) (n = Paare) | +16,7 | C f gegen i | 1-6 | 6
  m1931 E1 Stoerungs-Boden Median % (Hoechstwert 4,8) | 1,9 | C p gegen i | 1-6 | 6
  m1932 E1 Reihenfolge-Boden Median % (Hoechstwert 21,6) | 5,3 | C r gegen i | 1-6 | 6
  m1933 E2 Median rel f/i % (VERSCHIEBT; ueber dem Stoerungs-Boden; f groesser 6, kleiner 0) (n = Paare) | +56,2 | C f gegen i | 1-6 | 6
  m1934 E2 Stoerungs-Boden Median % (Hoechstwert 1,2) | 0,5 | C p gegen i | 1-6 | 6
  m1935 E2 Reihenfolge-Boden Median % (Hoechstwert 9,6) | 2,8 | C r gegen i | 1-6 | 6
  m1936 E2b Median rel f/i % (GLEICHSTAND; aufgeloest; f groesser 3, kleiner 3) (n = Paare) | -1,9 | C f gegen i | 1-6 | 6
  m1937 E2b Stoerungs-Boden Median % (Hoechstwert 2,7) | 0,3 | C p gegen i | 1-6 | 6
  m1938 E2b Reihenfolge-Boden Median % (Hoechstwert 3,5) | 2,6 | C r gegen i | 1-6 | 6
  m1939 E3 Median rel f/i % (GLEICHSTAND; f groesser 5, kleiner 1) (n = Paare) | +0,0 | C f gegen i | 1-6 | 6
  Quelle: rechner-a:~/snai_pruef/floatpaar/protokoll/bericht_wiederholung_2026-10-13_1735.txt; T50 aus mess.jsonl nachgerechnet (gleich), E2 C Saat 7 aus train.log nachgerechnet (gleich)
  m1940 E1 T50 Fenster | 26500 | C-i | 7 | 1
  m1941 E1 T50 Fenster | 27500 | C-f | 7 | 1
  m1942 E1 T50 Fenster | 20000 | C-i | 8 | 1
  m1943 E1 T50 Fenster | 26000 | C-f | 8 | 1
  m1944 E1 T50 Fenster | 27000 | C-i | 9 | 1
  m1945 E1 T50 Fenster | 27000 | C-f | 9 | 1
  m1946 E1 T50 Fenster | 21500 | C-i | 10 | 1
  m1947 E1 T50 Fenster | 27500 | C-f | 10 | 1
  m1948 E1 T50 Fenster | 21500 | C-i | 11 | 1
  m1949 E1 T50 Fenster | 28000 | C-f | 11 | 1
  m1950 E1 T50 Fenster | 22000 | C-i | 12 | 1
  m1951 E1 T50 Fenster | 27500 | C-f | 12 | 1
  m1952 E2 V/O-Anteil fest % | 28,4 | C-i | 7 | 1
  m1953 E2 V/O-Anteil fest % | 42,9 | C-f | 7 | 1
  m1954 E2b V/O-Anteil vor Einsetzen % | 41,2 | C-i | 7 | 1
  m1955 E2b V/O-Anteil vor Einsetzen % | 41,8 | C-f | 7 | 1
  m1956 E2 V/O-Anteil fest % | 26,9 | C-i | 8 | 1
  m1957 E2 V/O-Anteil fest % | 41,8 | C-f | 8 | 1
  m1958 E2b V/O-Anteil vor Einsetzen % | 46,7 | C-i | 8 | 1
  m1959 E2b V/O-Anteil vor Einsetzen % | 42,3 | C-f | 8 | 1
  m1960 E2 V/O-Anteil fest % | 29,6 | C-i | 9 | 1
  m1961 E2 V/O-Anteil fest % | 42,6 | C-f | 9 | 1
  m1962 E2b V/O-Anteil vor Einsetzen % | 40,3 | C-i | 9 | 1
  m1963 E2b V/O-Anteil vor Einsetzen % | 41,8 | C-f | 9 | 1
  m1964 E2 V/O-Anteil fest % | 27,1 | C-i | 10 | 1
  m1965 E2 V/O-Anteil fest % | 41,5 | C-f | 10 | 1
  m1966 E2b V/O-Anteil vor Einsetzen % | 43,6 | C-i | 10 | 1
  m1967 E2b V/O-Anteil vor Einsetzen % | 41,3 | C-f | 10 | 1
  m1968 E2 V/O-Anteil fest % | 28,8 | C-i | 11 | 1
  m1969 E2 V/O-Anteil fest % | 41,8 | C-f | 11 | 1
  m1970 E2b V/O-Anteil vor Einsetzen % | 42,6 | C-i | 11 | 1
  m1971 E2b V/O-Anteil vor Einsetzen % | 41,3 | C-f | 11 | 1
  m1972 E2 V/O-Anteil fest % | 29,7 | C-i | 12 | 1
  m1973 E2 V/O-Anteil fest % | 43,4 | C-f | 12 | 1
  m1974 E2b V/O-Anteil vor Einsetzen % | 45,8 | C-i | 12 | 1
  m1975 E2b V/O-Anteil vor Einsetzen % | 43,0 | C-f | 12 | 1
  m1976 E1 Median rel f/i % (UNEINHEITLICH; f groesser 5, kleiner 0) (n = Paare) | +26,5 | C f gegen i | 7-12 | 6
  m1977 E1 Stoerungs-Boden Median % (Hoechstwert 5,0) | 2,1 | C p gegen i | 7-12 | 6
  m1978 E1 Reihenfolge-Boden Median % (Hoechstwert 12,5) | 8,1 | C r gegen i | 7-12 | 6
  m1979 E2 Median rel f/i % (VERSCHIEBT; ueber dem Stoerungs-Boden; f groesser 6, kleiner 0) (n = Paare) | +48,5 | C f gegen i | 7-12 | 6
  m1980 E2 Stoerungs-Boden Median % (Hoechstwert 0,9) | 0,5 | C p gegen i | 7-12 | 6
  m1981 E2 Reihenfolge-Boden Median % (Hoechstwert 7,5) | 1,4 | C r gegen i | 7-12 | 6
  m1982 E2b Median rel f/i % (GLEICHSTAND; aufgeloest; f groesser 2, kleiner 4) (n = Paare) | -4,1 | C f gegen i | 7-12 | 6
  m1983 E2b Stoerungs-Boden Median % (Hoechstwert 2,5) | 0,8 | C p gegen i | 7-12 | 6
  m1984 E2b Reihenfolge-Boden Median % (Hoechstwert 7,0) | 4,1 | C r gegen i | 7-12 | 6
  m1985 E3 Median rel f/i % (GLEICHSTAND; f groesser 5, kleiner 1) (n = Paare) | +0,1 | C f gegen i | 7-12 | 6
  Quelle: rechner-a:~/snai_pruef/floatpaar/anhang/trainloss_c_saaten_1-6.txt und _7-12.txt (Gegenprobe, kein Urteil); Spannen aus den Berichten abgelesen
  m1986 Trainingsverlust-Einsetzen TL Median rel f/i % (positiv in 6 von 6) (n = Paare) | +13,8 | C f gegen i | 1-6 | 6
  m1987 Trainingsverlust-Einsetzen TL Median rel f/i % (positiv in 5 von 6) (n = Paare) | +22,0 | C f gegen i | 7-12 | 6
  m1988 T50 Spanne Arm f (Fenster) | 26.000-29.500 | C-f | 1-12 | 12
  m1989 T50 Spanne Arm i (Fenster) | 20.000-27.000 | C-i | 1-12 | 12
Ergebnis e153 [2026-10-21 19:24]: keine_aussage
  Fazit: Frage 1 (bremst der Ganzzahl-Stack das Einsetzen des Kopierens?) ist nach dem eigenen Kriterium nicht entschieden: E1 ist in A und B UNEINHEITLICH, in C ein HINWEIS (f später in 6 von 6, +16,7 %), den die eine erlaubte Wiederholung nicht bestätigt (5 von 6, ein Paar gleich). Es gibt also keinen Beleg, dass der Stack bremst, und ebenso keine Entwarnung, denn der Reihenfolge-Boden (Arm r) ist in A und B so groß wie der Abstand der Arme. Frage 2 ist beantwortet: Vor dem eigenen Einsetzen (E2b) ist der V/O-Anteil gleich (GLEICHSTAND, aufgelöst in A und C; B uneinheitlich). Der Befund E2 (ohne Stack +54 bis +56 % V/O-Anteil im festen Schrittfenster, B und C) ist nach der vorab festgelegten Lesart mit einem Tempo-Unterschied erklärbar, nicht mit einer Umverteilung. Damit ist der Drohnen-Nebenfund am Knirps nicht wiedergegeben. Für die Drohne folgt daraus kein Grund, den teuren gepaarten Lauf bis Segment 3 zu fahren. Methodisch wichtiger als das Ergebnis: Die Reihe fand den Gain-Wächter-Defekt, der alle früheren Knirps-Messungen über den Ladepfad betrifft.
  Offen: Welcher Teil des Bündels SNAI_INT8_FULL wirkt (Zerlegung SNAI_INT8_FULL=compute nicht gefahren). Nichts über echten Text, Breite 128/512, 4 Schichten, Kontext 512. In Zelle C (Drohnen-LR) setzt Arm f über alle 12 Paare nie früher ein (später in 11, gleich in 1); Zusammenlegen der beiden Proben ist nach Kriterium ausgeschlossen. Ob dahinter ein kleiner echter Bremseffekt OHNE Stack steckt (Richtung gegen die Ausgangsvermutung), wäre nur mit einer neuen, vorab festgelegten Reihe zu klären. Kriterium von Nachtrag 5 wurde nach den Daten der ersten Fahrt geschrieben (nur Messgerät) und vom Prüfer nicht gesehen.
  Datei: rechner-a:~/snai_pruef/floatpaar/protokoll/bericht_2026-10-13_1735.txt
Chronik (juengste 8 von 10, voll=True zeigt alle):
  2026-10-21 19:23 Status geplant -> laeuft (Rezept r160)
  2026-10-21 19:23 Rezept r161 (Fahrt 1 (ungültig))
  2026-10-21 19:24 Messwerte m1796-m1939
  2026-10-21 19:24 Messwerte m1940-m1985
  2026-10-21 19:24 Messwerte m1986-m1989
  2026-10-21 19:24 Ergebnis e153: keine_aussage
  2026-10-21 19:24 Status laeuft -> ausgewertet (Ergebnis e153)
  2026-10-21 19:33 Siehe auch snai/drohne-vo-nebenfund (Nebenfund am Drohnen-Material zu V/O bei float gegen int8, nachgetragen 2026-10-21 aus dem Gebiet Technik).
```
