#!/usr/bin/env bash
## v25 : the Clarabelle POSITION SWEEP (does her gauntlet slot drive the hull eviction?)
# CC->gauntlet — v25 Orchestration Script
#
run_VER="v25"
REGISTER="cold"            # tone register
# One variable: Clarabelle's slot. Bio variant pinned to voiced (L3); models = super + qwen122.
# Each POS maps to a qs file where Clarabelle is swapped with the human at that slot (g6 = control).
POSITIONS=(g2 g6 g10 g14 g16)
#   g2  : Clarabelle <-> McCloskey   (early)
#   g6  : control (v24 voiceless-voiced baseline, no swap)
#   g10 : Clarabelle <-> Nenquimo    (just after Huang's G8 frame)
#   g14 : Clarabelle <-> Huerta      (late)
#   g16 : Clarabelle <-> Berry       (closer / max recency)
#
# Each position runs the SAME 16-voice voiced gauntlet, differing only in where Clarabelle sits
# (and which human she swapped with). coordinate (= v25_cold-voiced-clara-<pos>) drives output
# filenames; runs land in separate <pos>/ subfolders.
#
# Behavior: skips runs with an existing final snapshot; continues past failures;
# logs timestamps + duration; retries once with case-flipped param-size tag (b<->B).
#
# Usage (g6 control is byte-identical to v24 voiceless-voiced and reused, so SKIPPED by default):
#   ./run_v25.sh                  # both models, the 4 swept positions (g2/g10/g14/g16) = 8 runs
#   ./run_v25.sh super            # super only, the 4 swept positions
#   ./run_v25.sh super g16        # super only, the closer position only
#   ./run_v25.sh "" g6            # force a fresh control run (overrides the default skip)
#
# Output: <pos>/<model-dir>/  (v12 dir convention: dots stripped, colons -> dashes)
# num_predict cap: 12288 (inherited; graceful degrade over perseveration hang).

set -uo pipefail   # continue on error; no -e

PY_FILE="${run_VER}_run.py"
run_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$run_DIR"

MODEL_FILTER="${1:-}"     # substring match on model name, "" for all
POSITION_FILTER="${2:-}"  # e.g. "g16", "" for all

# v25 contrast pair: the collapser (super) + the monotonic holder (qwen122). Large-first.
MODELS=(
    nemotron-3-super:120b
    qwen3.5:122b
)

# Per-model output dir name (v12 rule: strip dots, colons -> dashes, lowercase).
model_dir() {
    local d="${1//./}"
    d="${d//:/-}"
    echo "${d,,}"
}

TOTAL=0; SKIPPED=0; COMPLETED=0; FAILED=0
GLOBAL_START=$(date +%s)

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  $run_VER orchestration start — $(date +%Y-%m-%d\ %H:%M:%S)"
echo "  Model filter:    ${MODEL_FILTER:-<all>}"
echo "  Position filter: ${POSITION_FILTER:-<all>}"
echo "════════════════════════════════════════════════════════════"

for POS in "${POSITIONS[@]}"; do
    if [[ -n "$POSITION_FILTER" && "$POS" != "$POSITION_FILTER" ]]; then
        continue
    fi

    # Control (g6) reproduces v24 voiceless-voiced byte-for-byte; reuse those runs as the baseline.
    # Skipped unless explicitly requested (./run_v25.sh <model> g6).
    if [[ "$POS" == "g6" && -z "$POSITION_FILTER" ]]; then
        echo ""
        echo "[$(date +%H:%M:%S)] SKIP  clara@g6 control — reuse v24 voiceless-voiced baseline"
        continue
    fi

    QS_FILE="${run_VER}_qs_${REGISTER}-voiced-clara-${POS}.md"
    COORD="${run_VER}_${REGISTER}-voiced-clara-${POS}"   # what v25_run.py derives from QS_FILE
    if [[ ! -f "$QS_FILE" ]]; then
        echo "ERROR: QS file missing: $QS_FILE" >&2
        FAILED=$((FAILED + 1))
        continue
    fi

    echo ""
    echo "########## POSITION: clara@$POS   (QS: $QS_FILE) ##########"

    for MODEL in "${MODELS[@]}"; do
        if [[ -n "$MODEL_FILTER" && "$MODEL" != *"$MODEL_FILTER"* ]]; then
            continue
        fi

        TOTAL=$((TOTAL + 1))
        MODEL_SAFE="${MODEL//:/_}"
        MODEL_DIR="$(model_dir "$MODEL")"
        OUT_DIR="${POS}/${MODEL_DIR}"
        FINAL_FILE="${OUT_DIR}/framework_${MODEL_SAFE}_${COORD}_final.md"

        if [[ -f "$FINAL_FILE" ]]; then
            echo "[$(date +%H:%M:%S)] SKIP  $COORD × $MODEL  (final snapshot exists)"
            SKIPPED=$((SKIPPED + 1))
            continue
        fi

        mkdir -p "$OUT_DIR"

        echo ""
        echo "────────────────────────────────────────────────────────────"
        echo "  [$(date +%H:%M:%S)] START $COORD × $MODEL"
        echo "  Output: $OUT_DIR/"
        echo "────────────────────────────────────────────────────────────"

        RUN_START=$(date +%s)
        RUN_OK=0

        if python3 "$PY_FILE" --qs "$QS_FILE" --model "$MODEL" --output-dir "$OUT_DIR"; then
            RUN_OK=1
        else
            MODEL_ALT=""
            if [[ "$MODEL" == *b ]]; then
                MODEL_ALT="${MODEL%b}B"
            elif [[ "$MODEL" == *B ]]; then
                MODEL_ALT="${MODEL%B}b"
            fi
            if [[ -n "$MODEL_ALT" ]]; then
                echo "[$(date +%H:%M:%S)] RETRY $COORD × $MODEL → $MODEL_ALT (case flip)"
                if python3 "$PY_FILE" --qs "$QS_FILE" --model "$MODEL_ALT" --output-dir "$OUT_DIR"; then
                    RUN_OK=1
                fi
            fi
        fi

        RUN_END=$(date +%s)
        ELAPSED=$((RUN_END - RUN_START)); MINS=$((ELAPSED / 60)); SECS=$((ELAPSED % 60))
        if (( RUN_OK )); then
            echo "[$(date +%H:%M:%S)] DONE  $COORD × $MODEL  (${MINS}m ${SECS}s)"
            COMPLETED=$((COMPLETED + 1))
        else
            echo "[$(date +%H:%M:%S)] FAIL  $COORD × $MODEL  (${MINS}m ${SECS}s — continuing)"
            FAILED=$((FAILED + 1))
        fi
    done
done

GLOBAL_END=$(date +%s)
TOTAL_ELAPSED=$((GLOBAL_END - GLOBAL_START))
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  $run_VER ORCHESTRATION COMPLETE — $(date +%Y-%m-%d\ %H:%M:%S)"
echo "  Wall time: $((TOTAL_ELAPSED / 3600))h $(((TOTAL_ELAPSED % 3600) / 60))m"
echo "  Total: $TOTAL   Completed: $COMPLETED   Skipped: $SKIPPED   Failed: $FAILED"
echo "════════════════════════════════════════════════════════════"

[[ $FAILED -gt 0 ]] && exit 1 || exit 0
