<?php
/**
 * train_defaults.php - die Standardeinstellungen fuer Trainingslaeufe.
 * Angelegt 2026-09-02.
 *
 * WOZU DIESE DATEI EXISTIERT. train_cluster.php und train_worker.php lesen
 * dieselben Umgebungsvariablen unabhaengig voneinander: der Worker, um LoRA
 * aufzusetzen, der Cluster, um bei eingefrorener Basis das Neuron-Revival zu
 * sperren (train_cluster.php, Abschnitt "Neuron-Revival"). Solange beide nur
 * `getenv() > 0` pruefen, sind sie sich einig. Sobald einer von ihnen einen
 * DEFAULT ableitet, muss der andere denselben ableiten - sonst laesst der
 * Cluster das Revival ueber eine Basis laufen, die der Worker eingefroren hat,
 * und der Lauf ist still verfaelscht. Deshalb: eine Quelle, beide fragen sie.
 *
 * ---------------------------------------------------------------------------
 * WARUM TYING EIN ECHTER DEFAULT IST UND LoRA NICHT
 * ---------------------------------------------------------------------------
 * Beide Verfahren sind in diesem Zweig gemessen und beide gewinnen. Sie sind
 * aber nicht gleich sicher zu schalten:
 *
 * TYING ist eine Entscheidung ueber die REPRAESENTATION. Sie gilt fuer jeden
 * INT8-Lauf gleichermassen, und beide Regime sind vermessen:
 *   - Vortraining gebunden: prin_tied_s13 endet bei 4,7215 (192 F) gegen
 *     4,6879 der ungebundenen Basis - 0,034 nats, ueber 14 Segmente monoton
 *     gefallen, keine Entartung (0/80 auf der Verhaltenssonde).
 *   - Adaption auf gebundener Basis: Arm D 5,3983 gegen 5,3991 ungebunden.
 *   Dafuer 32 % weniger Bytes (40.190.030 gegen 59.097.164).
 *   => umsonst zu haben, also Standard.
 *
 * LoRA ist eine Entscheidung ueber die AUFGABE. Es ergibt nur bei Adaption
 * einen Sinn - ein Vortraining von Grund auf hat nichts zu adaptieren. Und
 * genau das kann dieses Skript NICHT sehen: es bekommt einen Korpus und eine
 * Basisdatei, keine Absicht. "Basis vorhanden" heisst hier NICHT "Adaption" -
 * run_princess_tied.sh, run_int8_lang.sh, run_vergleich.sh und
 * run_princess_chinchilla.sh fahren ihr VORTRAINING segmentweise weiter und
 * uebergeben in jedem Segment die Basis des vorigen. Ein Default
 * "Basis da -> LoRA" haette diese Laeufe still in Adaptionslaeufe verwandelt:
 * 1,7 % der Parameter beweglich, ohne dass es jemand bemerkt haette.
 *
 * Das ist exakt der Fehler, der diesem Zweig am 30.08. den Best-Checkpoint
 * ruiniert hat: dort hat train_cluster.php aus "es gibt ein Held-out-
 * Verzeichnis" auf "das ist der richtige Pruefsatz" geschlossen. Kosten
 * 0,455 nats, unbemerkt ueber vier Arme. Zweimal dieselbe Wette waere keine
 * Nachlaessigkeit mehr, sondern Vorsatz.
 *
 * Deshalb wird die Absicht ANGESAGT, nicht geraten: SNAI_TRAIN_MODE=adapt.
 * Dann ist LoRA r8 der Standard. Ohne die Angabe bleibt es beim bisherigen
 * Verhalten, aber nicht mehr stillschweigend - snai_train_mode_hinweis()
 * schreibt hin, was gewaehlt wurde und was es kostet.
 *
 * ---------------------------------------------------------------------------
 * ALLE SCHALTER
 * ---------------------------------------------------------------------------
 *   SNAI_TRAIN_MODE=adapt      LoRA r8 + eingefrorene Basis (Standard fuer
 *                              Adaption). Rang mit SNAI_LORA_RANK ueberschreibbar,
 *                              SNAI_LORA_RANK=0 macht daraus wieder eine
 *                              Voll-Feinabstimmung (fuer Kontrollarme).
 *   SNAI_TRAIN_MODE=pretrain   Vortraining. LoRA aus, kein Hinweis.
 *   SNAI_TIE_EMBEDDINGS        1 = an, 0 = aus. NICHT gesetzt = an, ABER nur
 *                              an der Genesis (siehe unten). Eine bereits
 *                              gebundene Basis bleibt in jedem Fall gebunden.
 *
 * ---------------------------------------------------------------------------
 * WO DER TYING-DEFAULT AUFHOERT
 * ---------------------------------------------------------------------------
 * Er greift NICHT, wenn ein bereits trainiertes, ungebundenes INT8-Modell als
 * Basis uebergeben wird. Nachtraegliches Binden ist der Weg, auf dem
 * base_prin_int8_s13_tied.snai entstanden ist - Held-out 10,23, zerstoert.
 * Auf dem LoRA-Pfad bricht train_worker.php dort hart ab (Zeile ~697), ohne
 * LoRA gaebe es nicht einmal den Abbruch. Ein Default, der je nach Codepfad
 * abbricht oder zerstoert, waere keiner.
 *
 * Der Default greift dort, wo die Messung herkommt: an der Genesis. Die
 * Durchsetzung steht in train_worker.php, weil nur der Worker den Magic der
 * Basisdatei kennt.
 */

// Rang, den ein Adaptionslauf ohne eigene Angabe bekommt. Gemessen als bester
// Stand des Zweigs: LoRA r8 E4 = 5,3991 auf dem 92-Fenster-SFT-Pruefsatz,
// gegen 5,7206 der Voll-Feinabstimmung (armA_voll_neu, 2026-09-02). Die
// Rangreihe r4/r8/r16/r32 lag innerhalb von 0,1 nats beieinander; r8 ist der
// gemessene Beste, nicht der geratene Mittelwert.
define('SNAI_DEFAULT_LORA_RANK', 8);

/**
 * 'adapt', 'pretrain' oder '' (nicht angesagt).
 * Ein unbekannter Wert ist ein Tippfehler und wird laut abgewiesen, nicht
 * stillschweigend als 'nicht angesagt' behandelt.
 */
function snai_train_mode(): string
{
    $m = strtolower(trim((string)getenv('SNAI_TRAIN_MODE')));
    if ($m === '') {
        return '';
    }
    if ($m !== 'adapt' && $m !== 'pretrain') {
        fwrite(STDERR, "🚨 SNAI_TRAIN_MODE='$m' ist unbekannt - erlaubt sind 'adapt' "
                     . "und 'pretrain'. Abbruch statt stiller Rueckfall auf einen Default.\n");
        exit(1);
    }
    return $m;
}

/** Der wirksame LoRA-Rang. 0 = kein LoRA (alle Parameter beweglich). */
function snai_lora_rank(): int
{
    $env = trim((string)getenv('SNAI_LORA_RANK'));
    if ($env !== '') {
        return max(0, (int)$env);   // explizite Angabe schlaegt den Default, auch die 0
    }
    return snai_train_mode() === 'adapt' ? SNAI_DEFAULT_LORA_RANK : 0;
}

/** Bleibt die Basis bei aktivem LoRA eingefroren? (Default ja.) */
function snai_lora_freeze(): bool
{
    return trim((string)getenv('SNAI_LORA_FREEZE')) !== '0';
}

/**
 * Ist die Basis bei aktivem LoRA eingefroren? Genau diese Kombination sperrt
 * im Cluster das Neuron-Revival. Cluster und Worker MUESSEN hier dasselbe
 * Ergebnis sehen - das ist der Grund fuer diese Datei.
 */
function snai_lora_basis_eingefroren(): bool
{
    return snai_lora_rank() > 0 && snai_lora_freeze();
}

/**
 * Weight Tying, wenn nichts angesagt ist: AN.
 * Gilt nur fuer INT8 - der Aufrufer prueft den dtype und schaltet sonst ab.
 * Rueckgabe: [aktiv, ausdruecklich_verlangt]. Das zweite Feld entscheidet, ob
 * eine dtype-Warnung noetig ist: wer =1 gesetzt hat, will hoeren, dass es
 * ignoriert wird; wer nur den Default bekommt, soll bei jedem FP32-Lauf nicht
 * angeblafft werden.
 */
function snai_tie_embeddings(): array
{
    $env = trim((string)getenv('SNAI_TIE_EMBEDDINGS'));
    if ($env === '') {
        return [true, false];       // Standard seit 2026-09-02
    }
    return [$env === '1', true];
}

/**
 * Der Hinweis, der aus dem stillen Default einen sichtbaren macht. Wird vom
 * Cluster einmal je Lauf ausgegeben, bevor die erste Epoche startet.
 *
 * $basis_vorhanden: es wurde eine Basisdatei uebergeben. Nur dann ist die
 * Frage "Adaption oder Vortraining?" ueberhaupt gestellt.
 */
function snai_train_mode_hinweis(bool $basis_vorhanden): void
{
    $mode = snai_train_mode();
    $rank = snai_lora_rank();

    if ($mode === 'adapt') {
        if ($rank > 0) {
            printf("  > [Standard] Adaptionslauf: LoRA r%d, Basis %s.\n",
                   $rank, snai_lora_freeze() ? 'eingefroren' : 'beweglich');
        } else {
            echo "  > [Standard] Adaptionslauf mit SNAI_LORA_RANK=0 - ausdrueckliche "
               . "Voll-Feinabstimmung (Kontrollarm).\n";
        }
        return;
    }
    if ($mode === 'pretrain' || !$basis_vorhanden || $rank > 0) {
        return;   // Vortraining angesagt, kein Basismodell, oder Rang gesetzt: nichts zu melden
    }

    // Basis da, Absicht nicht angesagt, kein LoRA. Das ist der Fall, in dem
    // frueher stillschweigend voll feinabgestimmt wurde.
    echo "  > ⚠️  [Standard] Dieser Lauf bewegt ALLE Parameter.\n"
       . "  >    Ist das eine Adaption auf ein Basismodell, ist LoRA seit 2026-09-02 der\n"
       . "  >    Standard: SNAI_TRAIN_MODE=adapt. Gemessen 0,32 nats besser (5,3991 gegen\n"
       . "  >    5,7206) bei 1,7 % beweglicher Parameter, -44 % Zeit, -39 % RAM.\n"
       . "  >    Ist es fortgesetztes Vortraining, sagt SNAI_TRAIN_MODE=pretrain diesen\n"
       . "  >    Hinweis ab. Geraten wird hier nichts - siehe train_defaults.php.\n";
}

/**
 * Ist dieser Lauf eine GENESIS, also ein Vortraining aus dem Nichts?
 *
 * Gesetzt von train_cluster.php, sobald es die Genesis-Matrix selbst giesst.
 * Nicht zum Setzen von Hand gedacht - es ist ein internes Signal zwischen Cluster und
 * Arbeiter.
 *
 * WOZU. Der Tying-Default darf nur an der Genesis greifen. Der Arbeiter kann
 * das an der Basisdatei NICHT ablesen: eine frisch gegossene Genesis ist
 * SNAI_V5, ein lange trainiertes FP32-Modell aber auch. Die erste Fassung des
 * Schutzes (2026-09-02) behalf sich mit "Basis ist bereits INT8" - und liess
 * damit genau die Luecke offen, durch die am 2026-09-03 ein trainiertes
 * FP32-Modell still gebunden wurde: 0,79 nats Schaden, ohne Warnung, rc 0.
 */
function snai_ist_genesis_lauf(): bool {
    $v = getenv('SNAI_GENESIS_RUN');
    return $v !== false && $v !== '' && $v !== '0';
}

/**
 * Fensterplan eines Chunks: die Startpositionen, an denen train_worker.php
 * seine Mini-Batches schneidet. Ein Offset = ein Trainingsschritt.
 *
 * WOZU EINE EIGENE FUNKTION. Die Schrittzahl eines Segments war bisher nur
 * nachtraeglich aus dem Log ablesbar ("Step 5315") - vorher blieb nur Schaetzen
 * oder Nachrechnen von Hand. Der naheliegende Weg, sie im Cluster nochmal
 * auszurechnen, waere eine ZWEITE Fassung derselben Schleife gewesen: dieselbe
 * Fehlerklasse wie die neun woertlichen Kopien der Tensor-Reihenfolge vor
 * SNAI_V7 (Grundsatz "Eine einzige Wahrheitsquelle"). Aendert jemand die
 * Schrittweite hier, aendert sich Plan UND Ausfuehrung gemeinsam - eine Drift
 * zwischen beiden ist nicht mehr moeglich, statt nur unwahrscheinlich.
 *
 * Die Kappung auf $total_tokens - 1 ist NICHT kosmetisch: das Zielfenster
 * ($batch_out) ist um genau ein Token nach rechts verschoben, ab Position
 * $total_tokens - 1 gaebe es also kein Ziel mehr. Sie ist damit auch der Grund,
 * warum jeder zurueckgegebene Offset garantiert mindestens ein Token traegt -
 * die Zahl der Offsets IST die Zahl der ausgefuehrten Schritte, keine
 * Obergrenze.
 */
function snai_window_offsets(int $total_tokens, int $ctx): array {
    if ($ctx < 1) return [];
    $offsets = [];
    for ($i = 0; $i < $total_tokens - 1; $i += $ctx) {
        $offsets[] = $i;
    }
    return $offsets;
}
