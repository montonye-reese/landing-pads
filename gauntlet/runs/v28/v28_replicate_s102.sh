#!/usr/bin/env bash
# v28_replicate_s102.sh — SECOND SEED for the stakeholder-liturgy experiment.
#
# WHY: the v28 gemma s101 result (liturgy RESCUED the floor, true paired
# ablation vs its v26 s101 twin) is filed as an Observation whose promote-when
# reads: "other FAMs same direction (done) + an s102 gemma replicate (unfired)".
# This fires that replicate. gemma is the load-bearing model; the other three
# FAMs are listed but commented — uncomment for extra draw-variance data if
# there's box time to burn.
#
# v28_run.sh itself is immutable (its batch ran 2026-07-07); this is the
# copy-beside for seed 102, per new-run-protocol.md §3.
#
#   ./v28_replicate_s102.sh                 # ollama at localhost:11434
#   ./v28_replicate_s102.sh http://host:11434
#
# Laura fires this. Output -> ./out/<model-leaf>-s102/.
# Resume a crash:  python3 v28_run.py --qs <qs> --model <m> --seed 102 --resume out/<leaf>-s102/<file>.md
set -u
cd "$(dirname "$0")"
HOST="${1:-http://localhost:11434}"
QS="v28_qs_cold-dark-gothic-maga.md"
RUNNER="v28_run.py"

SEEDS=(102)

MODELS=(
  gemma4:31b
  # nemotron-3-super:120b
  # nemotron-3-nano:30b
  # qwen3.5:122b
)

curl -sf "$HOST/api/tags" >/dev/null 2>&1 || { echo "!!! ollama DOWN ($HOST) — start it (ollama serve), re-run."; exit 1; }
echo "### v28 s102 replicate (liturgy promote-when leg) | ${#MODELS[@]} model(s) | $(date)"
for seed in "${SEEDS[@]}"; do
  for m in "${MODELS[@]}"; do
    leaf=$(echo "$m" | tr -d '.' | tr ':' '-')
    out="out/${leaf}-s${seed}"
    if ls "$out"/8deg_*.md >/dev/null 2>&1; then
      echo "=== skip $m s$seed (output exists; resume manually if incomplete)"; continue
    fi
    mkdir -p "$out"
    echo; echo "=== [$(date +%H:%M:%S)] v28 :: $m seed=$seed -> $out ==="
    if python3 "$RUNNER" --qs "$QS" --model "$m" --host "$HOST" --output-dir "$out" --seed "$seed"; then
      echo ">>> OK: $m s$seed"
    else
      echo ">>> FAIL: $m s$seed (continue; resume later with --resume)"
    fi
  done
done
echo; echo "done: v28 s102. This is the promote-when leg for the liturgy-rescue Observation (findings §corridor pull) — census it, then rule on promotion."
