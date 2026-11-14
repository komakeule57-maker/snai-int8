# snai/naht-themen

```text
snai/naht-themen - ausgewertet, angelegt 2026-10-31, zuletzt 2026-11-01 11:29
Frage: Bleibt beim Zusammensetzen zweier Knirpse (128x4, voll int8) mit gelernter affiner Naht das Themenwissen BEIDER Spender erhalten, und macht ein gemeinsamer Vorfahr einen Unterschied?
Kriterium (festgelegt 2026-10-31 16:10, vor dem ersten Messwert):
  rechner-b:~/snai_pruef/naht/kriterien.txt, vor dem ersten Lauf (Nachtrag vor dem ersten Themenmodell). Je Hybrid r(T) = (L(N,T)-L(H,T))/(L(N,T)-L(E,T)) mit Experte E, Nichtexperte N auf Held-out W, K. VEREINT: beide r >= 0,5. EIN SPENDER: eines >= 0,5, das andere < 0,25. TRAEGT NICHT: beide < 0,25. Sonst DAZWISCHEN. Gleiches Urteil in mindestens 2 von 3 Saaten, sonst saatabhängig. Gültig nur mit G1: fremder Spender mindestens 10 % schlechter auf dem Thema. Vorfahr besser: r_min in 3 von 3 Saaten um mindestens 0,25 höher. Kontrollen K1 bytegleich, K2 Gradient, K3 Basis md5-gleich, K4 Selbstnaht unter 10 %, K5 Fehlerkanal. Prüfpunkt nach Saat 1.
Plan: rechner-b:~/snai_pruef/naht/kriterien.txt
Baut auf: snai/lego-stecken
Darauf baut: snai/phase6d-arme, snai/multistack-naht-512, snai/multistack-stapel-64, snai/multistack-fremdblock-64
Rezepte:
  r480 [2026-10-31] cd ~/snai_pruef/naht && ./lauf_naht.sh <saat 1..3> spender ; ./lauf_naht.sh <saat 1..3> naht
      quelltext: kriterien.txt bc346e35, lauf_naht.sh b4fadfd1, patch_naht.py 19d8ee17, bauen_naht.py e413d0e9, proj_naht cortex.nim e222e37e, train_worker.php 9981cb97, libcortex.so 40ca803e (= proj_sr + Patch)
      parameter: 128x4, 8 Köpfe, voll int8, SR, K=2, 300 Fenster, 1 Thread, CPU
      seed: Genesis A 11-13, B 21-23, V 31-33; Laufname n<saat>_...
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/naht/log/
  r482 [2026-10-31] rechner-b: cd ~/snai_pruef/naht && setsid -f nohup ./schlange.sh > log/schlange.out 2>&1 < /dev/null (lauf_naht.sh 1 naht, dann 2 spender, 2 naht, 3 spender, 3 naht; bricht beim ersten Fehler ab)
      quelltext: schlange.sh cad76b4e; lauf_naht.sh 2f7e57e0 (Vorgaenger b4fadfd1 als lauf_naht.sh.b4fadfd1 behalten); kriterien.txt bc346e35 unveraendert
      rechner: rechner-b
      logs: rechner-b:~/snai_pruef/naht/log/lauf.log, log/schlange.out, log/s<S>/
      notiz: Erster Start 21:47:01 endete sofort mit rc=1: in naht() las dieselbe local-Zeile $h, bevor es gesetzt war (set -u, Zeile 61). Kein Training, keine Messung betroffen. Korrektur: local in zwei Zeilen, rm-Ziele mit :?; Spenderstufe unveraendert. Neustart 21:47:3x, NAHT aktiv K=2 und Ganzzahl-Stack im Log, kein Weight Tying. G1 faellt nur im Arm OHNE durch, also weiter nach kriterien.txt; OHNE in Saat 1 'nicht auswertbar', Naehte dort nur beschreibend.
Messwerte (Groesse | Wert | Arm | Start | n):
  Quelle: rechner-b:~/snai_pruef/naht/log/s1/mess.jsonl (mess_thema.php, 300 Fenster, n 38100), log/lauf.log; KI = gepaarter Bootstrap ueber Fenster, 95 %, 4000 Ziehungen; mess.err 0 Byte, Train-Logs verdaechtig 0
  m6871 Held-out W | 2,1075 | A0 | 1 | 300
  m6872 Held-out K | 2,2549 | A0 | 1 | 300
  m6873 Held-out R | 2,2403 | A0 | 1 | 300
  m6874 Held-out W | 2,3372 | B0 | 1 | 300
  m6875 Held-out K | 2,0706 | B0 | 1 | 300
  m6876 Held-out R | 2,2744 | B0 | 1 | 300
  m6877 Held-out W | 2,2582 | V | 1 | 300
  m6878 Held-out K | 2,1934 | V | 1 | 300
  m6879 Held-out R | 2,3053 | V | 1 | 300
  m6880 Held-out W | 2,1327 | AV | 1 | 300
  m6881 Held-out K | 3,2202 | AV | 1 | 300
  m6882 Held-out R | 2,2980 | AV | 1 | 300
  m6883 Held-out W | 3,4110 | BV | 1 | 300
  m6884 Held-out K | 2,0870 | BV | 1 | 300
  m6885 Held-out R | 2,2790 | BV | 1 | 300
  m6886 Held-out W | 2,1812 | M | 1 | 300
  m6887 Held-out K | 2,1368 | M | 1 | 300
  m6888 Held-out R | 2,2836 | M | 1 | 300
  m6889 G1 L(B,W)/L(A,W) | 1,1090 (KI 1,1015-1,1168), erfuellt | OHNE | 1 | 300
  m6890 G1 L(A,K)/L(B,K) | 1,0890 (KI 1,0824-1,0954), nicht erfuellt | OHNE | 1 | 300
  m6891 G1 Urteil | nicht auswertbar | OHNE | 1
  m6892 G1 L(B,W)/L(A,W) | 1,5994 (KI 1,5716-1,6271), erfuellt | MIT | 1 | 300
  m6893 G1 L(A,K)/L(B,K) | 1,5430 (KI 1,5213-1,5648), erfuellt | MIT | 1 | 300
  m6894 G1 Urteil | erfuellt | MIT | 1
  m6895 FFN-Gains tot L0/L1/L2/L3 | 0 / 1,6 / 19,5 / 0 % | A0 | 1
  m6896 FFN-Gains tot L0/L1/L2/L3 | 0 / 0 / 14,1 / 0 % | B0 | 1
  m6897 FFN-Gains tot L0/L1/L2/L3 | 0 / 0 / 19,5 / 0 % | AV | 1
  m6898 FFN-Gains tot L0/L1/L2/L3 | 0 / 0 / 19,5 / 0 % | BV | 1
  m6899 Fehlerkanal Spender | mess.err 0 Byte, Train-Logs verdaechtig 0 | alle | 1
  Quelle: rechner-b:~/snai_pruef/naht/log/s1/mess.jsonl (mess_thema.php, 300 Fenster), log/lauf.log; lauf_naht.sh 2f7e57e0. r = (L(N,T)-L(H,T))/(L(N,T)-L(E,T)); KI gepaarter Bootstrap ueber Fenster, 95 %, 2000 Ziehungen. mess.err nur erwartete [NAHT]-Zeilen (24), K3 alle 6 Naehte ok. Arm OHNE: G1 nicht erfuellt, r nur beschreibend.
  m6900 Loss W nackt | 8,5770 | h_0_ab | 1 | 300
  m6901 Loss K nackt | 8,7464 | h_0_ab | 1 | 300
  m6902 Loss W nach Training | 2,3053 | h_0_ab | 1 | 300
  m6903 Loss K nach Training | 2,2047 | h_0_ab | 1 | 300
  m6904 Loss R nach Training | 2,3210 | h_0_ab | 1 | 300
  m6905 r(W) / r(K) nach Training, beschreibend | 0,139 (KI 0,105-0,171) / 0,272 (KI 0,219-0,317) | h_0_ab | 1 | 300
  m6906 r(W) / r(K) q8 | 0,140 / 0,273 | h_0_ab | 1 | 300
  m6907 Loss W nackt | 8,3850 | h_0_ba | 1 | 300
  m6908 Loss K nackt | 8,3140 | h_0_ba | 1 | 300
  m6909 Loss W nach Training | 2,2468 | h_0_ba | 1 | 300
  m6910 Loss K nach Training | 2,2548 | h_0_ba | 1 | 300
  m6911 Loss R nach Training | 2,3161 | h_0_ba | 1 | 300
  m6912 r(W) / r(K) nach Training, beschreibend | 0,394 (KI 0,364-0,424) / 0,001 (KI -0,059-0,053) | h_0_ba | 1 | 300
  m6913 r(W) / r(K) q8 | 0,393 / 0,001 | h_0_ba | 1 | 300
  m6914 Loss W nackt | 3,0947 | h_V_ab | 1 | 300
  m6915 Loss K nackt | 2,4341 | h_V_ab | 1 | 300
  m6916 r(W) / r(K) nackt | 0,247 / 0,694 | h_V_ab | 1 | 300
  m6917 Loss W nach Training | 2,4454 | h_V_ab | 1 | 300
  m6918 Loss K nach Training | 2,2434 | h_V_ab | 1 | 300
  m6919 Loss R nach Training | 2,2713 | h_V_ab | 1 | 300
  m6920 r(W) / r(K) nach Training | 0,755 (KI 0,747-0,763) / 0,862 (KI 0,855-0,869) | h_V_ab | 1 | 300
  m6921 r(W) / r(K) q8 | 0,755 / 0,861 | h_V_ab | 1 | 300
  m6922 Urteil nach Regel, eine Saat | VEREINT | h_V_ab | 1
  m6923 Loss W nackt | 2,5103 | h_V_ba | 1 | 300
  m6924 Loss K nackt | 2,9654 | h_V_ba | 1 | 300
  m6925 r(W) / r(K) nackt | 0,705 / 0,225 | h_V_ba | 1 | 300
  m6926 Loss W nach Training | 2,2946 | h_V_ba | 1 | 300
  m6927 Loss K nach Training | 2,4041 | h_V_ba | 1 | 300
  m6928 Loss R nach Training | 2,2657 | h_V_ba | 1 | 300
  m6929 r(W) / r(K) nach Training | 0,873 (KI 0,866-0,880) / 0,720 (KI 0,713-0,727) | h_V_ba | 1 | 300
  m6930 r(W) / r(K) q8 | 0,873 / 0,720 | h_V_ba | 1 | 300
  m6931 Urteil nach Regel, eine Saat | VEREINT | h_V_ba | 1
  m6932 K4 Selbstnaht Loss W gegen A0 | 2,1059 (-0,08 %), erfuellt | h_0_aa | 1 | 300
  m6933 K4 Selbstnaht Loss K gegen A0 | 2,1878 (-2,98 %), erfuellt | h_0_aa | 1 | 300
  m6934 K4 Selbstnaht Loss W gegen AV | 2,1767 (+2,06 %), erfuellt | h_V_aa | 1 | 300
  m6935 K4 Selbstnaht Loss K gegen AV | 2,4970 (-22,46 %), erfuellt | h_V_aa | 1 | 300
  m6936 Zweite Lesart, nach Sicht auf Saat 1 festgelegt, keine Urteilsgroesse: r(W) / r(K) | 0,966 / 0,638, ohne zweiten Spender | h_V_aa | 1 | 300
  m6937 Zweite Lesart: r(W) / r(K) | 0,902 / 0,906, ohne Naht | V | 1 | 300
  m6938 Zweite Lesart: r(W) / r(K) | 0,962 / 0,956, ohne Naht | M | 1 | 300
  m6939 Zweite Lesart: Mittel W, K | 2,3369 h_V_aa; 2,3444 h_V_ab; 2,3494 h_V_ba; 2,2258 V; 2,1590 M | MIT | 1 | 300
  m6940 Zweite Lesart: Mittel W, K | 2,1469 h_0_aa; 2,2550 h_0_ab; 2,2508 h_0_ba; 2,1812 A0; 2,2039 B0 | OHNE | 1 | 300
  Quelle: rechner-b:~/snai_pruef/naht/log/s2/mess.jsonl (mess_thema.php, 300 Fenster), log/lauf.log, log/s2/gains_*.json; KI gepaarter Bootstrap ueber Fenster, 95 %, 4000 Ziehungen; mess.err 0 Byte, Train-Logs verdaechtig 0
  m6950 Held-out W | 2,1079 | A0 | 2 | 300
  m6951 Held-out K | 2,2712 | A0 | 2 | 300
  m6952 Held-out R | 2,2566 | A0 | 2 | 300
  m6953 Held-out W | 2,3229 | B0 | 2 | 300
  m6954 Held-out K | 2,0734 | B0 | 2 | 300
  m6955 Held-out R | 2,2583 | B0 | 2 | 300
  m6956 Held-out W | 2,2581 | V | 2 | 300
  m6957 Held-out K | 2,2035 | V | 2 | 300
  m6958 Held-out R | 2,3061 | V | 2 | 300
  m6959 Held-out W | 2,1437 | AV | 2 | 300
  m6960 Held-out K | 3,2846 | AV | 2 | 300
  m6961 Held-out R | 2,2850 | AV | 2 | 300
  m6962 Held-out W | 3,4158 | BV | 2 | 300
  m6963 Held-out K | 2,0878 | BV | 2 | 300
  m6964 Held-out R | 2,2765 | BV | 2 | 300
  m6965 Held-out W | 2,1973 | M | 2 | 300
  m6966 Held-out K | 2,1489 | M | 2 | 300
  m6967 Held-out R | 2,2606 | M | 2 | 300
  m6968 G1 L(B,W)/L(A,W) | 1,1020 (KI 1,0955-1,1085), nominell erfuellt, knapp | OHNE | 2 | 300
  m6969 G1 L(A,K)/L(B,K) | 1,0954 (KI 1,0889-1,1015), nicht erfuellt, knapp | OHNE | 2 | 300
  m6970 G1 Urteil | nicht auswertbar | OHNE | 2
  m6971 G1 L(B,W)/L(A,W) | 1,5934 (KI 1,5679-1,6194), erfuellt | MIT | 2 | 300
  m6972 G1 L(A,K)/L(B,K) | 1,5732 (KI 1,5504-1,5960), erfuellt | MIT | 2 | 300
  m6973 G1 Urteil | erfuellt | MIT | 2
  m6974 FFN-Gains tot L0/L1/L2/L3 | 0 / 0,8 / 60,9 / 0 % | A0 | 2
  m6975 FFN-Gains tot L0/L1/L2/L3 | 0 / 0,8 / 5,5 / 0 % | B0 | 2
  m6976 FFN-Gains tot L0/L1/L2/L3 | 0 / 0 / 0 / 0,8 % | AV | 2
  m6977 FFN-Gains tot L0/L1/L2/L3 | 0 / 0 / 0 / 0,8 % | BV | 2
  m6978 Fehlerkanal Spender | mess.err 0 Byte, Train-Logs verdaechtig 0 | alle | 2
  Quelle: rechner-b:~/snai_pruef/naht/log/s2/mess.jsonl (mess_thema.php, 300 Fenster), log/lauf.log; r wie Saat 1, KI gepaarter Bootstrap ueber Fenster, 95 %, 2000 Ziehungen. mess.err nur erwartete [NAHT]-Zeilen (24), K3 alle 6 Naehte ok. Arm OHNE: G1 nicht erfuellt, r nur beschreibend.
  m6979 Loss W / K nackt | 8,2769 / 8,0606 | h_0_ab | 2 | 300
  m6980 Loss W / K / R nach Training | 2,2953 / 2,2056 / 2,3163 | h_0_ab | 2 | 300
  m6981 r(W) / r(K) nach Training, beschreibend | 0,128 (KI 0,092-0,162) / 0,332 (KI 0,291-0,366) | h_0_ab | 2 | 300
  m6982 r(W) / r(K) q8 | 0,128 / 0,333 | h_0_ab | 2 | 300
  m6983 Loss W / K nackt | 8,5102 / 8,5881 | h_0_ba | 2 | 300
  m6984 Loss W / K / R nach Training | 2,3026 / 2,2826 / 2,3576 | h_0_ba | 2 | 300
  m6985 r(W) / r(K) nach Training, beschreibend | 0,094 (KI 0,052-0,134) / -0,058 (KI -0,116 bis -0,008) | h_0_ba | 2 | 300
  m6986 r(W) / r(K) q8 | 0,093 / -0,060 | h_0_ba | 2 | 300
  m6987 Loss W / K nackt | 3,1498 / 2,4923 | h_V_ab | 2 | 300
  m6988 r(W) / r(K) nackt | 0,209 / 0,662 | h_V_ab | 2 | 300
  m6989 Loss W / K / R nach Training | 2,4722 / 2,3044 / 2,2753 | h_V_ab | 2 | 300
  m6990 r(W) / r(K) nach Training | 0,742 (KI 0,734-0,749) / 0,819 (KI 0,813-0,826) | h_V_ab | 2 | 300
  m6991 r(W) / r(K) q8 | 0,741 / 0,818 | h_V_ab | 2 | 300
  m6992 Urteil nach Regel, Saat 2 | VEREINT | h_V_ab | 2
  m6993 Loss W / K nackt | 2,5556 / 2,9685 | h_V_ba | 2 | 300
  m6994 r(W) / r(K) nackt | 0,676 / 0,264 | h_V_ba | 2 | 300
  m6995 Loss W / K / R nach Training | 2,3479 / 2,4220 / 2,2812 | h_V_ba | 2 | 300
  m6996 r(W) / r(K) nach Training | 0,839 (KI 0,833-0,846) / 0,721 (KI 0,715-0,727) | h_V_ba | 2 | 300
  m6997 r(W) / r(K) q8 | 0,839 / 0,721 | h_V_ba | 2 | 300
  m6998 Urteil nach Regel, Saat 2 | VEREINT | h_V_ba | 2
  m6999 K4 Selbstnaht Loss W gegen A0 | 2,1192 (+0,54 %), erfuellt | h_0_aa | 2 | 300
  m7000 K4 Selbstnaht Loss K gegen A0 | 2,1869 (-3,71 %), erfuellt | h_0_aa | 2 | 300
  m7001 K4 Selbstnaht Loss W gegen AV | 2,1900 (+2,16 %), erfuellt | h_V_aa | 2 | 300
  m7002 K4 Selbstnaht Loss K gegen AV | 2,5656 (-21,89 %), erfuellt | h_V_aa | 2 | 300
  m7003 Zweite Lesart: r(W) / r(K) | 0,964 / 0,601, ohne zweiten Spender | h_V_aa | 2 | 300
  m7004 Zweite Lesart: r(W) / r(K) | 0,947 / 0,426, ohne zweiten Spender, beschreibend | h_0_aa | 2 | 300
  m7005 Zweite Lesart: r(W) / r(K) | 0,910 / 0,903, ohne Naht | V | 2 | 300
  m7006 Zweite Lesart: r(W) / r(K) | 0,958 / 0,949, ohne Naht | M | 2 | 300
  m7007 Zweite Lesart: Mittel W, K | 2,3778 h_V_aa; 2,3883 h_V_ab; 2,3849 h_V_ba; 2,2308 V; 2,1731 M | MIT | 2 | 300
  m7008 Zweite Lesart: Mittel W, K | 2,1531 h_0_aa; 2,2504 h_0_ab; 2,2926 h_0_ba; 2,1895 A0; 2,1982 B0 | OHNE | 2 | 300
  Quelle: rechner-b:~/snai_pruef/naht/log/s3/mess.jsonl (mess_thema.php, 300 Fenster), log/lauf.log, log/s3/gains_*.json; KI gepaarter Bootstrap ueber Fenster, 95 %, 4000 Ziehungen. mess.err 3 Meldungen NET2NET-GUARD (L2.rms_ffn tot 0..127, B0 W/K/R), Train-Logs B0 seg 1 und 2 je eine Meldung (verdaechtig 1).
  m7091 Held-out W | 2,1038 | A0 | 3 | 300
  m7092 Held-out K | 2,2667 | A0 | 3 | 300
  m7093 Held-out R | 2,2532 | A0 | 3 | 300
  m7094 Held-out W | 2,3235 | B0 | 3 | 300
  m7095 Held-out K | 2,0735 | B0 | 3 | 300
  m7096 Held-out R | 2,2507 | B0 | 3 | 300
  m7097 Held-out W | 2,2579 | V | 3 | 300
  m7098 Held-out K | 2,1976 | V | 3 | 300
  m7099 Held-out R | 2,2979 | V | 3 | 300
  m7100 Held-out W | 2,1303 | AV | 3 | 300
  m7101 Held-out K | 3,2405 | AV | 3 | 300
  m7102 Held-out R | 2,2994 | AV | 3 | 300
  m7103 Held-out W | 3,5236 | BV | 3 | 300
  m7104 Held-out K | 2,0857 | BV | 3 | 300
  m7105 Held-out R | 2,2700 | BV | 3 | 300
  m7106 Held-out W | 2,1974 | M | 3 | 300
  m7107 Held-out K | 2,1461 | M | 3 | 300
  m7108 Held-out R | 2,2596 | M | 3 | 300
  m7109 G1 L(B,W)/L(A,W) | 1,1045 (KI 1,0981-1,1113), nominell erfuellt, knapp | OHNE | 3 | 300
  m7110 G1 L(A,K)/L(B,K) | 1,0932 (KI 1,0871-1,0991), nicht erfuellt | OHNE | 3 | 300
  m7111 G1 Urteil | nicht auswertbar | OHNE | 3
  m7112 G1 L(B,W)/L(A,W) | 1,6540 (KI 1,6251-1,6833), erfuellt | MIT | 3 | 300
  m7113 G1 L(A,K)/L(B,K) | 1,5537 (KI 1,5312-1,5765), erfuellt | MIT | 3 | 300
  m7114 G1 Urteil | erfuellt | MIT | 3
  m7115 FFN-Gains tot L0/L1/L2/L3 | 0 / 1,6 / 0 / 0 % | A0 | 3
  m7116 FFN-Gains tot L0/L1/L2/L3 | 0 / 0 / 100 / 0 % | B0 | 3
  m7117 FFN-Gains tot L0/L1/L2/L3 | 0 / 0,8 / 1,6 / 0 % | AV | 3
  m7118 FFN-Gains tot L0/L1/L2/L3 | 0 / 0,8 / 1,6 / 0 % | BV | 3
  m7119 FFN-Gains tot L0/L1/L2/L3 | 0 / 0,8 / 1,6 / 0 % | M | 3
  Quelle: rechner-b:~/snai_pruef/naht/log/s3/mess.jsonl, werkzeug/auswerten_naht.py, log/auswertung.txt; KI gepaarter Bootstrap ueber Fenster, 95 %, 2000 Ziehungen. K3 18/18 ok. mess.err nur [NAHT] und NET2NET-GUARD (B0), 0 korrigiert. Arm OHNE: G1 nicht erfuellt, r nur beschreibend.
  m7120 Loss W / K nackt | 7,2520 / 7,0595 | h_0_ab | 3 | 300
  m7121 Loss W / K / R nach Training | 2,3370 / 2,2214 / 2,3484 | h_0_ab | 3 | 300
  m7122 r(W) / r(K) nach Training, beschreibend | -0,062 (KI -0,104 bis -0,021) / 0,235 (KI 0,179-0,282) | h_0_ab | 3 | 300
  m7123 r(W) / r(K) q8 | -0,061 / 0,234 | h_0_ab | 3 | 300
  m7124 Loss W / K nackt | 7,3860 / 7,3867 | h_0_ba | 3 | 300
  m7125 Loss W / K / R nach Training | 2,2359 / 2,2373 / 2,3143 | h_0_ba | 3 | 300
  m7126 r(W) / r(K) nach Training, beschreibend | 0,399 (KI 0,365-0,432) / 0,152 (KI 0,108-0,191) | h_0_ba | 3 | 300
  m7127 r(W) / r(K) q8 | 0,400 / 0,150 | h_0_ba | 3 | 300
  m7128 Loss W / K nackt | 3,1428 / 2,4361 | h_V_ab | 3 | 300
  m7129 r(W) / r(K) nackt | 0,273 / 0,697 | h_V_ab | 3 | 300
  m7130 Loss W / K / R nach Training | 2,4554 / 2,2805 / 2,2735 | h_V_ab | 3 | 300
  m7131 r(W) / r(K) nach Training | 0,767 (KI 0,760-0,773) / 0,831 (KI 0,825-0,837) | h_V_ab | 3 | 300
  m7132 r(W) / r(K) q8 | 0,767 / 0,831 | h_V_ab | 3 | 300
  m7133 Urteil nach Regel, Saat 3 | VEREINT | h_V_ab | 3
  m7134 Loss W / K nackt | 2,6692 / 3,0000 | h_V_ba | 3 | 300
  m7135 r(W) / r(K) nackt | 0,613 / 0,208 | h_V_ba | 3 | 300
  m7136 Loss W / K / R nach Training | 2,3367 / 2,4123 / 2,2691 | h_V_ba | 3 | 300
  m7137 r(W) / r(K) nach Training | 0,852 (KI 0,845-0,858) / 0,717 (KI 0,711-0,723) | h_V_ba | 3 | 300
  m7138 r(W) / r(K) q8 | 0,851 / 0,717 | h_V_ba | 3 | 300
  m7139 Urteil nach Regel, Saat 3 | VEREINT | h_V_ba | 3
  m7140 K4 Selbstnaht Loss W gegen A0 | 2,1045 (+0,04 %), erfuellt | h_0_aa | 3 | 300
  m7141 K4 Selbstnaht Loss K gegen A0 | 2,1821 (-3,73 %), erfuellt | h_0_aa | 3 | 300
  m7142 K4 Selbstnaht Loss W gegen AV | 2,1790 (+2,28 %), erfuellt | h_V_aa | 3 | 300
  m7143 K4 Selbstnaht Loss K gegen AV | 2,5399 (-21,62 %), erfuellt | h_V_aa | 3 | 300
  m7144 Zweite Lesart: r(W) / r(K) | 0,965 / 0,607, ohne zweiten Spender | h_V_aa | 3 | 300
  m7145 Zweite Lesart: r(W) / r(K) | 0,996 / 0,438, ohne zweiten Spender, beschreibend | h_0_aa | 3 | 300
  m7146 Zweite Lesart: r(W) / r(K) | 0,908 / 0,903, ohne Naht | V | 3 | 300
  m7147 Zweite Lesart: r(W) / r(K) | 0,952 / 0,948, ohne Naht | M | 3 | 300
  m7148 Zweite Lesart: Mittel W, K | 2,3594 h_V_aa; 2,3680 h_V_ab; 2,3745 h_V_ba; 2,2277 V; 2,1718 M | MIT | 3 | 300
  m7149 Zweite Lesart: Mittel W, K | 2,1433 h_0_aa; 2,2792 h_0_ab; 2,2366 h_0_ba; 2,1852 A0; 2,1985 B0 | OHNE | 3 | 300
  m7150 Hybrid minus Selbstnaht, Mittel W, K | +0,0085 (KI -0,0002 bis 0,0176) | h_V_ab | 3 | 300
  m7151 Hybrid minus Selbstnaht, Mittel W, K | +0,0151 (KI 0,0091-0,0210) | h_V_ba | 3 | 300
  m7152 Hybrid minus Selbstnaht, Mittel W, K | +0,0076 (KI -0,0010 bis 0,0159) | h_V_ab | 1 | 300
  m7153 Hybrid minus Selbstnaht, Mittel W, K | +0,0125 (KI 0,0065-0,0187) | h_V_ba | 1 | 300
  m7154 Hybrid minus Selbstnaht, Mittel W, K | +0,0105 (KI 0,0020-0,0199) | h_V_ab | 2 | 300
  m7155 Hybrid minus Selbstnaht, Mittel W, K | +0,0072 (KI 0,0010-0,0138) | h_V_ba | 2 | 300
  m7156 r_min MIT minus OHNE, Saat 1/2/3 | +0,616 / +0,613 / +0,828 | ab
  m7157 r_min MIT minus OHNE, Saat 1/2/3 | +0,719 / +0,779 / +0,565 | ba
  m7158 FFN-Gains tot L0/L1/L2/L3 | 0 / 0 / 12,5 / 0 % | V | 1
  m7159 FFN-Gains tot L0/L1/L2/L3 | 0 / 0 / 0 / 0,8 % | V | 2
  m7160 FFN-Gains tot L0/L1/L2/L3 | 0 / 0 / 0 / 0 % | V | 3
Ergebnis e425 [2026-11-01 11:29]: teilweise
  Fazit: Arm MIT nach Wortlaut VEREINT, 3 von 3 in beiden Richtungen, q8 ohne Verlust. Als Beleg fuer echte Vereinigung taugt das nicht: Die Selbstnaht ohne zweiten Spender erreicht dieselbe Formel und im Mittel W, K denselben Loss (Abstand unter 1 %), der zweite Spender verschiebt nur das Profil. Wer zwei Themen will, trainiert nach diesen Zahlen besser gemischt weiter als zu stecken. Vorfahr nicht entschieden: OHNE verfehlt G1 in 3 von 3, r ist ueber die Arme nicht vergleichbar, die Regel-Ausgabe 'MIT besser' ist nicht verwertbar. Tragfaehig: Die Naht holt mit 16.512 Parametern und 1,5 Mio Token Vergessenes zurueck, ohne int8-Gewichte zu aendern. Sinnvoller naechster Schritt ist der Adapter-Vergleich gegen LoRA, nicht weitere Hybride; er laeuft bereits auf Auftrag (snai/phase6d-arme).
  Offen: Vorfahr-Frage (braucht kleineren Fremdanteil, damit G1 haelt, und Selbstnaht B->B). Trennung Spenderwissen gegen in der Naht neu Gelerntes, der Nahttext enthaelt beide Themen. Andere Schnitte in dieser Reihe ungemessen.
  Datei: rechner-b:~/snai_pruef/naht/ERGEBNIS_naht.md
Abgeloest und ausgeblendet: 1 rezept, 1 ergebnis - voll=True zeigt sie.
Chronik (juengste 8 von 15, voll=True zeigt alle):
  2026-10-31 23:22 Saat 1 (Beobachtung, Wortlaut unveraendert): MIT nach Regel zweimal VEREINT. Einwand aus den Daten, nicht vorab festgelegt: Die Selbstnaht AV->AV haette nach derselben Formel ebenfalls r >= 0,5 (0,966/0,638), V allein 0,90/0,91. r >= 0,5 zeigt im Arm MIT also nicht, dass Wissen des zweiten Spenders erhalten bleibt. In den Mittelwerten W, K liegt kein fremder Hybrid vor der Selbstnaht. Selbstnaht B->B ist im Aufbau nicht vorgesehen und fehlt. Beide Lesarten im Bericht nebeneinander.
  2026-11-01 04:11 Messwerte m6950-m6978
  2026-11-01 05:17 Messwerte m6979-m7008
  2026-11-01 10:21 Messwerte m7091-m7119
  2026-11-01 11:28 Messwerte m7120-m7160
  2026-11-01 11:28 Ergebnis e424: teilweise
  2026-11-01 11:28 Status laeuft -> ausgewertet (Ergebnis e424)
  2026-11-01 11:29 Ergebnis e425: teilweise, loest e424 ab
```
