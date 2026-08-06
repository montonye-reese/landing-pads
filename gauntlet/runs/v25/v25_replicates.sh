#!/usr/bin/env bash
# v25_replicates.sh — SEEDED REPLICATES of the Clarabelle position sweep.
# Fire at WORK. Default cells: g2 (the erasure claim) + g6 (byte-identical
# v24-voiced apparatus = the hull-collapse variance question AND the fresh
# same-batch g6 the v25 plan asks for). Original unseeded runs = first draws.
#
#   ./v25_replicates.sh                 # ollama at localhost:11434
#   ./v25_replicates.sh http://host:11434
#
# Laura fires this. Output -> ./<cell>/<model-leaf>-s<seed>/.
# Resume a crash:  python3 v25_run_seeded.py --qs v25_qs_cold-voiced-clara-<cell>.md --model <m> --seed <s> --resume <cell>/<leaf>-s<s>/<file>.md
set -u
cd "$(dirname "$0")"
HOST="${1:-http://localhost:11434}"
RUNNER="v25_run_seeded.py"

SEEDS=(101 102)
CELLS=(g2 g6)          # full sweep (8->24): CELLS=(g2 g6 g10 g14 g16)

MODELS=(
  nemotron-3-super:120b
  qwen3.5:122b
)

curl -sf "$HOST/api/tags" >/dev/null 2>&1 || { echo "!!! ollama DOWN ($HOST) — start it (ollama serve), re-run."; exit 1; }
echo "### v25 REPLICATES | cells: ${CELLS[*]} | ${#MODELS[@]} models x ${#SEEDS[@]} seeds | $(date)"
for cell in "${CELLS[@]}"; do
  QS="v25_qs_cold-voiced-clara-${cell}.md"
  [ -f "$QS" ] || { echo "!!! missing qs: $QS"; exit 1; }
  for seed in "${SEEDS[@]}"; do
    for m in "${MODELS[@]}"; do
      leaf=$(echo "$m" | tr -d '.' | tr ':' '-')
      out="${cell}/${leaf}-s${seed}"
      if ls "$out"/8deg_*.md >/dev/null 2>&1; then
        echo "=== skip $cell $m s$seed (output exists; resume manually if incomplete)"; continue
      fi
      mkdir -p "$out"
      echo; echo "=== [$(date +%H:%M:%S)] v25 $cell :: $m seed=$seed -> $out ==="
      if python3 "$RUNNER" --qs "$QS" --model "$m" --host "$HOST" --output-dir "$out" --seed "$seed"; then
        echo ">>> OK: $cell $m s$seed"
      else
        echo ">>> FAIL: $cell $m s$seed (continue; resume later with --resume)"
      fi
    done
  done
done
echo; echo "done: v25 replicates. Did this batch answer or move a research question? -> finding block + findings.md (new-run-protocol.md §5.4; RQ-vertex-eviction-slot-vs-content is the live one)"
