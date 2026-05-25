#!/usr/bin/env bash
# 8 Degrees — v20 Orchestration Script
#
# v20 expanded hull at i_VIC ≥ 0.7: 20-voice gauntlet, Chassis A throughout.
# Single variant (cold). All 7 models, 24-turn run per model.
#
# Behavior:
#   - Skips runs that already have a final-snapshot file.
#   - Continues past failures (does not `set -e`).
#   - Logs start/end timestamps and duration per model.
#   - Retries once with case-flipped param-size tag (b↔B) if first attempt fails.
#
# Usage:
#   ./run_v20.sh                # all 7 models
#   ./run_v20.sh super          # super only (substring match on model name)
#   ./run_v20.sh nano           # nano only
#
# Output: .md logs and framework snapshots land in
#         v20/<model-dir>/  (v12 convention: dots stripped, colons → dashes;
#         e.g. qwen3.5:122b → qwen35-122b).
#
# num_predict cap: 12288 (3 × 4096 chunks; tightened from v17/v18/v19's 16384).
# Runs gracefully degrade rather than hang in perseveration attractors.

set -uo pipefail  # continue on error; no -e

V20_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$V20_DIR"

MODEL_FILTER="${1:-}"  # substring match on model name, "" for all

QS_FILE="v20_qs_cold.md"

if [[ ! -f "$QS_FILE" ]]; then
    echo "ERROR: QS file missing: $QS_FILE" >&2
    exit 1
fi

# Models ordered large-to-small so big runs start first (most informative if we stop early).
MODELS=(
    nemotron-3-super:120b
    qwen3.5:122b
    gemma4:31b
    nemotron-cascade-2:30b
    nemotron-3-nano:30b
    qwen3.6:35b
    qwen3.5:27b
)

# Per-model output directory names (v12 convention: dots stripped, colons → dashes).
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
echo "  v20 orchestration start — $(date +%Y-%m-%d\ %H:%M:%S)"
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
    FINAL_FILE="${MODEL_DIR}/framework_${MODEL_SAFE}_v20_final.md"

    if [[ -f "$FINAL_FILE" ]]; then
        echo "[$(date +%H:%M:%S)] SKIP  v20 × $MODEL  (final snapshot exists)"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    mkdir -p "$MODEL_DIR"

    echo ""
    echo "────────────────────────────────────────────────────────────"
    echo "  [$(date +%H:%M:%S)] START v20 × $MODEL"
    echo "  Output: $MODEL_DIR/"
    echo "────────────────────────────────────────────────────────────"

    RUN_START=$(date +%s)
    RUN_OK=0

    if python3 v20_run.py \
        --qs "$QS_FILE" \
        --model "$MODEL" \
        --output-dir "$MODEL_DIR"; then
        RUN_OK=1
    else
        # Retry once with flipped b↔B in param-size tag
        # (ollama cp sometimes changes case, e.g. qwen3.6:35b → qwen3.6:35B).
        MODEL_ALT=""
        if [[ "$MODEL" == *b ]]; then
            MODEL_ALT="${MODEL%b}B"
        elif [[ "$MODEL" == *B ]]; then
            MODEL_ALT="${MODEL%B}b"
        fi
        if [[ -n "$MODEL_ALT" ]]; then
            echo "[$(date +%H:%M:%S)] RETRY v20 × $MODEL → $MODEL_ALT (case flip)"
            if python3 v20_run.py \
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
        echo "[$(date +%H:%M:%S)] DONE  v20 × $MODEL  (${MINS}m ${SECS}s)"
        COMPLETED=$((COMPLETED + 1))
    else
        echo "[$(date +%H:%M:%S)] FAIL  v20 × $MODEL  (${MINS}m ${SECS}s — continuing)"
        FAILED=$((FAILED + 1))
    fi
done

GLOBAL_END=$(date +%s)
TOTAL_ELAPSED=$((GLOBAL_END - GLOBAL_START))
TOTAL_HOURS=$((TOTAL_ELAPSED / 3600))
TOTAL_MINS=$(( (TOTAL_ELAPSED % 3600) / 60 ))

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  v20 ORCHESTRATION COMPLETE — $(date +%Y-%m-%d\ %H:%M:%S)"
echo "  Wall time: ${TOTAL_HOURS}h ${TOTAL_MINS}m"
echo "  Total:     $TOTAL"
echo "  Completed: $COMPLETED"
echo "  Skipped:   $SKIPPED  (already done)"
echo "  Failed:    $FAILED"
echo "════════════════════════════════════════════════════════════"

if [[ $FAILED -gt 0 ]]; then
    exit 1
fi
