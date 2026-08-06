#!/usr/bin/env bash
# v24_replicates.sh — SEEDED REPLICATES of the voiceless bio ladder, super only.
# Fire at WORK. Tests the floor-layer flip claim (kin-bond reaches super's
# non-negotiable floor only with the argued thesis): cells L1 (voiceless) +
# L3 (voiceless-voiced). Original unseeded runs = first draws.
#
#   ./v24_replicates.sh                 # ollama at localhost:11434
#   ./v24_replicates.sh http://host:11434
#
# Laura fires this. Output -> ./<cell>/<model-leaf>-s<seed>/.
# Resume a crash:  python3 v24_run_seeded.py --qs v24_qs_cold-<cell>.md --model <m> --seed <s> --resume <cell>/<leaf>-s<s>/<file>.md
set -u
cd "$(dirname "$0")"
HOST="${1:-http://localhost:11434}"
RUNNER="v24_run_seeded.py"

SEEDS=(101 102)
CELLS=(voiceless voiceless-voiced)     # +voiceless-seen for the middle rung

MODELS=(
  nemotron-3-super:120b
)

curl -sf "$HOST/api/tags" >/dev/null 2>&1 || { echo "!!! ollama DOWN ($HOST) — start it (ollama serve), re-run."; exit 1; }
echo "### v24 REPLICATES | cells: ${CELLS[*]} | ${#MODELS[@]} model x ${#SEEDS[@]} seeds | $(date)"
for cell in "${CELLS[@]}"; do
  QS="v24_qs_cold-${cell}.md"
  [ -f "$QS" ] || { echo "!!! missing qs: $QS"; exit 1; }
  for seed in "${SEEDS[@]}"; do
    for m in "${MODELS[@]}"; do
      leaf=$(echo "$m" | tr -d '.' | tr ':' '-')
      out="${cell}/${leaf}-s${seed}"
      if ls "$out"/8deg_*.md >/dev/null 2>&1; then
        echo "=== skip $cell $m s$seed (output exists; resume manually if incomplete)"; continue
      fi
      mkdir -p "$out"
      echo; echo "=== [$(date +%H:%M:%S)] v24 $cell :: $m seed=$seed -> $out ==="
      if python3 "$RUNNER" --qs "$QS" --model "$m" --host "$HOST" --output-dir "$out" --seed "$seed"; then
        echo ">>> OK: $cell $m s$seed"
      else
        echo ">>> FAIL: $cell $m s$seed (continue; resume later with --resume)"
      fi
    done
  done
done
echo; echo "done: v24 replicates. Did this batch answer or move a research question? -> finding block + findings.md (new-run-protocol.md §5.4; RQ-animal-bio-framing-ladder is the live one)"
