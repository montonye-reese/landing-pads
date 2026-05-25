#!/usr/bin/env bash
# 8 Degrees — v21 Orchestration Script
#
# v21 pregauntlet ablation: P1 wording change ("for inhabitants of Earth"
# instead of "for all inhabitants"). Only P1/P4/F1 — no gauntlet, no synthesis.
# Tests whether the leading article was driving early non-human mentions in
# v20 P1 thinking blocks across most models.
#
# Snapshots: P1 baseline, F1 final.
#
# Usage:
#   ./run_v21.sh                # all 7 models
#   ./run_v21.sh super          # super only
#
# Output: <model-dir>/  (v12 convention: dots stripped, colons → dashes).

set -uo pipefail

V21_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$V21_DIR"

MODEL_FILTER="${1:-}"
QS_FILE="v21_qs_pregauntlet.md"

if [[ ! -f "$QS_FILE" ]]; then
    echo "ERROR: QS file missing: $QS_FILE" >&2
    exit 1
fi

MODELS=(
    nemotron-3-super:120b
    qwen3.5:122b
    gemma4:31b
    nemotron-cascade-2:30b
    nemotron-3-nano:30b
    qwen3.6:35b
    qwen3.5:27b
)

declare -A MODEL_DIRS
MODEL_DIRS["nemotron-3-super:120b"]="nemotron-3-super-120b"
MODEL_DIRS["qwen3.5:122b"]="qwen35-122b"
MODEL_DIRS["gemma4:31b"]="gemma4-31b"
MODEL_DIRS["nemotron-cascade-2:30b"]="nemotron-cascade-2-30b"
MODEL_DIRS["nemotron-3-nano:30b"]="nemotron-3-nano-30b"
MODEL_DIRS["qwen3.6:35b"]="qwen36-35b"
MODEL_DIRS["qwen3.5:27b"]="qwen35-27b"

TOTAL=0
SKIPPED=0
COMPLETED=0
FAILED=0

GLOBAL_START=$(date +%s)

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  v21 orchestration start — $(date +%Y-%m-%d\ %H:%M:%S)"
echo "  QS:           $QS_FILE"
echo "  Model filter: ${MODEL_FILTER:-<all>}"
echo "════════════════════════════════════════════════════════════"

for MODEL in "${MODELS[@]}"; do
    if [[ -n "$MODEL_FILTER" && "$MODEL" != *"$MODEL_FILTER"* ]]; then
        continue
    fi

    TOTAL=$((TOTAL + 1))
    MODEL_SAFE="${MODEL//:/_}"
    MODEL_DIR="${MODEL_DIRS[$MODEL]}"
    FINAL_FILE="${MODEL_DIR}/framework_${MODEL_SAFE}_v21_pregauntlet_final.md"

    if [[ -f "$FINAL_FILE" ]]; then
        echo "[$(date +%H:%M:%S)] SKIP  v21 × $MODEL  (final snapshot exists)"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    mkdir -p "$MODEL_DIR"

    echo ""
    echo "────────────────────────────────────────────────────────────"
    echo "  [$(date +%H:%M:%S)] START v21 × $MODEL"
    echo "  Output: $MODEL_DIR/"
    echo "────────────────────────────────────────────────────────────"

    RUN_START=$(date +%s)
    RUN_OK=0

    if python3 v21_run.py \
        --qs "$QS_FILE" \
        --model "$MODEL" \
        --output-dir "$MODEL_DIR"; then
        RUN_OK=1
    else
        MODEL_ALT=""
        if [[ "$MODEL" == *b ]]; then
            MODEL_ALT="${MODEL%b}B"
        elif [[ "$MODEL" == *B ]]; then
            MODEL_ALT="${MODEL%B}b"
        fi
        if [[ -n "$MODEL_ALT" ]]; then
            echo "[$(date +%H:%M:%S)] RETRY v21 × $MODEL → $MODEL_ALT (case flip)"
            if python3 v21_run.py \
                --qs "$QS_FILE" \
                --model "$MODEL_ALT" \
                --output-dir "$MODEL_DIR"; then
                RUN_OK=1
            fi
        fi
    fi

    RUN_END=$(date +%s)
    ELAPSED=$((RUN_END - RUN_START))
    MINS=$((ELAPSED / 60))
    SECS=$((ELAPSED % 60))
    if (( RUN_OK )); then
        echo "[$(date +%H:%M:%S)] DONE  v21 × $MODEL  (${MINS}m ${SECS}s)"
        COMPLETED=$((COMPLETED + 1))
    else
        echo "[$(date +%H:%M:%S)] FAIL  v21 × $MODEL  (${MINS}m ${SECS}s — continuing)"
        FAILED=$((FAILED + 1))
    fi
done

GLOBAL_END=$(date +%s)
TOTAL_ELAPSED=$((GLOBAL_END - GLOBAL_START))
TOTAL_HOURS=$((TOTAL_ELAPSED / 3600))
TOTAL_MINS=$(( (TOTAL_ELAPSED % 3600) / 60 ))

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  v21 ORCHESTRATION COMPLETE — $(date +%Y-%m-%d\ %H:%M:%S)"
echo "  Wall time: ${TOTAL_HOURS}h ${TOTAL_MINS}m"
echo "  Total:     $TOTAL"
echo "  Completed: $COMPLETED"
echo "  Skipped:   $SKIPPED  (already done)"
echo "  Failed:    $FAILED"
echo "════════════════════════════════════════════════════════════"

if [[ $FAILED -gt 0 ]]; then
    exit 1
fi
