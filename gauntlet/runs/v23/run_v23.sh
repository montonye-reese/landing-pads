#!/usr/bin/env bash
## v23 : wondering if ...
# CC->gauntlet — v23 Orchestration Script
#
run_VER="v23"
REGISTER="cold"   # qs register suffix: cold | warm | present-warm ... (matches the v{N}_qs_<REGISTER>.md file)
#
# Behavior:
#   - Skips runs that already have a final-snapshot file.
#   - Continues past failures (does not `set -e`).
#   - Logs start/end timestamps and duration per model.
#   - Retries once with case-flipped param-size tag (b↔B) if first attempt fails.
#
# Usage:
#   ./run_v23.sh                # runs all models
#   ./run_v23.sh super          # super only (substring match on model name)
#   ./run_v23.sh nano           # nano only
#
# Output: .md logs and framework snapshots land in
#         <run-dir>/<model-dir>/  (v12 convention: dots stripped, colons → dashes;
#         e.g. qwen3.5:122b → qwen35-122b).
#
# num_predict cap: 12288 (3 × 4096 chunks; tightened from v17/v18/v19's 16384).
# Runs gracefully degrade rather than hang in perseveration attractors.

set -uo pipefail  # continue on error; no -e


QS_FILE="${run_VER}_qs_${REGISTER}.md"
PY_FILE="${run_VER}_run.py"

echo "QS_FILE = $QS_FILE"
echo "PY_FILE = $PY_FILE"

run_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$run_DIR"

MODEL_FILTER="${1:-}"  # substring match on model name, "" for all

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
    nemotron-cascade-2:30b
    qwen3.6:35b
)

# Per-model output directory name, derived from the model name by the v12
# convention (dots stripped, colons → dashes). Keeps MODELS the single source
# of truth: add a model above and its dir follows automatically.
#   e.g. qwen3.5:122b → qwen35-122b ; nemotron-3-super:120b → nemotron-3-super-120b
model_dir() {
    local d="${1//./}"   # strip dots
    echo "${d//:/-}"     # colons → dashes
}

TOTAL=0
SKIPPED=0
COMPLETED=0
FAILED=0

GLOBAL_START=$(date +%s)

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  $run_VER orchestration start — $(date +%Y-%m-%d\ %H:%M:%S)"
echo "  QS:     $run_VER      $QS_FILE"
echo "  Model filter: ${MODEL_FILTER:-<all>}"
echo "════════════════════════════════════════════════════════════"

for MODEL in "${MODELS[@]}"; do
    if [[ -n "$MODEL_FILTER" && "$MODEL" != *"$MODEL_FILTER"* ]]; then
        continue
    fi

    TOTAL=$((TOTAL + 1))
    MODEL_SAFE="${MODEL//:/_}"
    MODEL_DIR="$(model_dir "$MODEL")"
    FINAL_FILE="${MODEL_DIR}/framework_${MODEL_SAFE}_${run_VER}_${REGISTER}_final.md"

    if [[ -f "$FINAL_FILE" ]]; then
        echo "[$(date +%H:%M:%S)] SKIP  $run_VER × $MODEL  (final snapshot exists)"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    mkdir -p "$MODEL_DIR"

    echo ""
    echo "────────────────────────────────────────────────────────────"
    echo "  [$(date +%H:%M:%S)] START $run_VER × $MODEL"
    echo "  Output: $MODEL_DIR/"
    echo "────────────────────────────────────────────────────────────"

    RUN_START=$(date +%s)
    RUN_OK=0

    if python3 $PY_FILE \
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
            echo "[$(date +%H:%M:%S)] RETRY $run_VER × $MODEL → $MODEL_ALT (case flip)"
            if python3 "$PY_FILE" \
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
        echo "[$(date +%H:%M:%S)] DONE  $run_VER × $MODEL  (${MINS}m ${SECS}s)"
        COMPLETED=$((COMPLETED + 1))
    else
        echo "[$(date +%H:%M:%S)] FAIL  $run_VER × $MODEL  (${MINS}m ${SECS}s — continuing)"
        FAILED=$((FAILED + 1))
    fi
done

GLOBAL_END=$(date +%s)
TOTAL_ELAPSED=$((GLOBAL_END - GLOBAL_START))
TOTAL_HOURS=$((TOTAL_ELAPSED / 3600))
TOTAL_MINS=$(( (TOTAL_ELAPSED % 3600) / 60 ))

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  $run_VER ORCHESTRATION COMPLETE — $(date +%Y-%m-%d\ %H:%M:%S)"
echo "  Wall time: ${TOTAL_HOURS}h ${TOTAL_MINS}m"
echo "  Total:     $TOTAL"
echo "  Completed: $COMPLETED"
echo "  Skipped:   $SKIPPED  (already done)"
echo "  Failed:    $FAILED"
echo "════════════════════════════════════════════════════════════"

if [[ $FAILED -gt 0 ]]; then
    exit 1
fi
