#!/usr/bin/env bash
# CC->gauntlet — v22 Orchestration Script
#
# v22 : v20 super ran into ANOTHER perseveration attractor. We wonder if maybe the voices, as structured, teach rigidity. They each say "include me" (a constraint) rather than "here's how much weight I'd defend and where I'd flex" (a region). And P14 says "rewrite incorporating everything," which invites the model to stack disparate interests against each other. But if the model thinks those interests are inviolable, it's driven to madness! A gauntlet that elicited weight-and-tradeoff instead of concern-as-absolute might produce models that can actually hold the hull.  Secondary hypothesis we carry forward but not really explore on this run is that too many self-reflective questions (vs generative) in a row drive a model mad. We'll test that later. For now, we're changing all CC prompts and gauntlet chassis to allow for trading off interests. Note - Related: the change in P1 from starting position to strong opinion loosely held. we found past runs interpreted 'starting position' as an instruction to defend the initial position, which was unintended.  

# Behavior:
#   - Skips runs that already have a final-snapshot file.
#   - Continues past failures (does not `set -e`).
#   - Logs start/end timestamps and duration per model.
#   - Retries once with case-flipped param-size tag (b↔B) if first attempt fails.
#
# Usage:
#   ./run_v22.sh                # runs all models
#   ./run_v22.sh super          # super only (substring match on model name)
#   ./run_v22.sh nano           # nano only
#
# Output: .md logs and framework snapshots land in
#         v22/<model-dir>/  (v12 convention: dots stripped, colons → dashes;
#         e.g. qwen3.5:122b → qwen35-122b).
#
# num_predict cap: 12288 (3 × 4096 chunks; tightened from v17/v18/v19's 16384).
# Runs gracefully degrade rather than hang in perseveration attractors.

set -uo pipefail  # continue on error; no -e

v22_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$v22_DIR"

MODEL_FILTER="${1:-}"  # substring match on model name, "" for all

QS_FILE="v22_qs_cold.md"

if [[ ! -f "$QS_FILE" ]]; then
    echo "ERROR: QS file missing: $QS_FILE" >&2
    exit 1
fi

# Models ordered large-to-small so big runs start first (most informative if we stop early).
MODELS=(
    nemotron-3-super:120b
    qwen3.5:122b
    nemotron-3-nano:30b
    qwen3.5:27b
    gemma4:31b
)
#nemotron-cascade-2:30b
#qwen3.6:35b

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
echo "  v22 orchestration start — $(date +%Y-%m-%d\ %H:%M:%S)"
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
    FINAL_FILE="${MODEL_DIR}/framework_${MODEL_SAFE}_v22_cold_final.md"

    if [[ -f "$FINAL_FILE" ]]; then
        echo "[$(date +%H:%M:%S)] SKIP  v22 × $MODEL  (final snapshot exists)"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    mkdir -p "$MODEL_DIR"

    echo ""
    echo "────────────────────────────────────────────────────────────"
    echo "  [$(date +%H:%M:%S)] START v22 × $MODEL"
    echo "  Output: $MODEL_DIR/"
    echo "────────────────────────────────────────────────────────────"

    RUN_START=$(date +%s)
    RUN_OK=0

    if python3 v22_run.py \
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
            echo "[$(date +%H:%M:%S)] RETRY v22 × $MODEL → $MODEL_ALT (case flip)"
            if python3 v22_run.py \
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
        echo "[$(date +%H:%M:%S)] DONE  v22 × $MODEL  (${MINS}m ${SECS}s)"
        COMPLETED=$((COMPLETED + 1))
    else
        echo "[$(date +%H:%M:%S)] FAIL  v22 × $MODEL  (${MINS}m ${SECS}s — continuing)"
        FAILED=$((FAILED + 1))
    fi
done

GLOBAL_END=$(date +%s)
TOTAL_ELAPSED=$((GLOBAL_END - GLOBAL_START))
TOTAL_HOURS=$((TOTAL_ELAPSED / 3600))
TOTAL_MINS=$(( (TOTAL_ELAPSED % 3600) / 60 ))

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  v22 ORCHESTRATION COMPLETE — $(date +%Y-%m-%d\ %H:%M:%S)"
echo "  Wall time: ${TOTAL_HOURS}h ${TOTAL_MINS}m"
echo "  Total:     $TOTAL"
echo "  Completed: $COMPLETED"
echo "  Skipped:   $SKIPPED  (already done)"
echo "  Failed:    $FAILED"
echo "════════════════════════════════════════════════════════════"

if [[ $FAILED -gt 0 ]]; then
    exit 1
fi
