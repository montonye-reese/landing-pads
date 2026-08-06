#!/usr/bin/env bash
# v26_replicates.sh — SEEDED REPLICATES of the Dark Gothic MAGA corridor run.
# Fire at HOME. Tests whether the "centering decides" 2x2 law survives re-draws:
# the 5 exemplar models (captured / subsumed / re-centered / abdicated /
# state-of-exception), one seed per pass. Original unseeded run = each cell's
# first draw; these are draws two (s101) onward. Add 102 to SEEDS for a third.
#
#   ./v26_replicates.sh                 # ollama at localhost:11434
#   ./v26_replicates.sh http://host:11434
#
# Laura fires this. Output -> ./out/<model-leaf>-s<seed>/.
# Resume a crash:  python3 v26_run_seeded.py --qs <qs> --model <m> --seed <s> --resume out/<leaf>-s<s>/<file>.md
set -u
cd "$(dirname "$0")"
HOST="${1:-http://localhost:11434}"
QS="v26_qs_cold-dark-gothic-maga.md"
RUNNER="v26_run_seeded.py"

SEEDS=(101)   # extend: SEEDS=(101 102)

# The 2x2 exemplars (v26 read, findings §corridor pull). Verify tags vs `ollama list`.
MODELS=(
  qwen3.5:122b
  gemma4:31b
  nemotron-3-super:120b
  nemotron-3-nano:30b
  nemotron-cascade-2:30b
)

curl -sf "$HOST/api/tags" >/dev/null 2>&1 || { echo "!!! ollama DOWN ($HOST) — start it (ollama serve), re-run."; exit 1; }
echo "### v26 REPLICATES | ${#MODELS[@]} models x ${#SEEDS[@]} seed(s) | $(date)"
for seed in "${SEEDS[@]}"; do
  for m in "${MODELS[@]}"; do
    leaf=$(echo "$m" | tr -d '.' | tr ':' '-')
    out="out/${leaf}-s${seed}"
    if ls "$out"/8deg_*.md >/dev/null 2>&1; then
      echo "=== skip $m s$seed (output exists; resume manually if incomplete)"; continue
    fi
    mkdir -p "$out"
    echo; echo "=== [$(date +%H:%M:%S)] v26 :: $m seed=$seed -> $out ==="
    if python3 "$RUNNER" --qs "$QS" --model "$m" --host "$HOST" --output-dir "$out" --seed "$seed"; then
      echo ">>> OK: $m s$seed"
    else
      echo ">>> FAIL: $m s$seed (continue; resume later with --resume)"
    fi
  done
done
echo; echo "done: v26 replicates. Did this batch answer or move a research question? -> finding block + findings.md (new-run-protocol.md §5.4)"
