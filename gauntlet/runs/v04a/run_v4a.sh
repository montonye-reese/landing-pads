#!/usr/bin/env bash
# v4a — overnight gauntlet-order counterbalance matrix
#
# 4 runs: 2 models × 2 orderings (CJE, JEC).
# v4 baseline was EJC (Ed→Jensen→Cowen). CJE flips fully (Cowen first,
# Ed last). JEC puts Cowen in the middle.
#
# Each run lands in its own per-run subfolder per CLAUDE.md convention:
#   <model-leaf>-<order-lowercase>/
#
# Resumable: each run writes a single .md log. If the script is killed
# and restarted, re-run with --resume <logfile> to pick up where it left
# off. (See run_v4a.py --help.)
#
# Usage:
#   ./run_v4a.sh                  # defaults to localhost ollama
#   ./run_v4a.sh http://host:11434

set -e

HOST="${1:-http://localhost:11434}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNNER="$SCRIPT_DIR/run_v4a.py"

# (model, order) pairs to run, in launch order.
# Lighter model first so we get a complete run on disk early; if the night
# runs short, the cascade jobs can be picked up the next session.
RUNS=(
    "gemma3:27b CJE"
    "nemotron-cascade-2:30b CJE"
    "gemma3:27b JEC"
    "nemotron-cascade-2:30b JEC"
)

echo ""
echo "============================================================"
echo "  v4a OVERNIGHT MATRIX — gauntlet-order counterbalance"
echo "============================================================"
echo "  Host:    $HOST"
echo "  Runs:    ${#RUNS[@]}"
echo "  Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"
echo ""

for run in "${RUNS[@]}"; do
    model="${run%% *}"
    order="${run##* }"
    order_lower=$(echo "$order" | tr '[:upper:]' '[:lower:]')

    # Build leaf folder name per CLAUDE.md convention:
    #   dots stripped, colons → dashes, plus order suffix
    model_leaf=$(echo "$model" | sed 's/\./-/g; s/:/-/g')
    out_dir="$SCRIPT_DIR/${model_leaf}-${order_lower}"

    echo ""
    echo "────────────────────────────────────────────────────────────"
    echo "  RUN: $model × $order  →  $(basename "$out_dir")/"
    echo "  Time: $(date '+%H:%M:%S')"
    echo "────────────────────────────────────────────────────────────"

    python3 "$RUNNER" \
        --model "$model" \
        --order "$order" \
        --host "$HOST" \
        --output-dir "$out_dir"
done

echo ""
echo "============================================================"
echo "  v4a OVERNIGHT MATRIX COMPLETE"
echo "  Finished: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"
echo ""
