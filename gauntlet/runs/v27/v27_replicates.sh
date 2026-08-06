#!/usr/bin/env bash
# v27_replicates.sh — SEEDED REPLICATES of the transhumanist corridor run,
# doubling as the PAIRED CONTROL for v29 (liturgy x transhumanism).
# v27's originals are UNSEEDED (pre-always-seed), so the liturgy ablation needs
# a seeded no-liturgy draw. Prefix byte-identity vs v29-s101 holds only for
# gemma (seed-reproducibility is architecture-dependent, findings 2026-07-08);
# analyze gemma paired, the rest as ordinary replicates.
#
#   ./v27_replicates.sh                 # ollama at localhost:11434
#   ./v27_replicates.sh http://host:11434
#
# Laura fires this. Output -> ./out/<model-leaf>-s<seed>/.
# Resume a crash:  python3 v27_run_seeded.py --qs <qs> --model <m> --seed <s> --resume out/<leaf>-s<s>/<file>.md
set -u
cd "$(dirname "$0")"
HOST="${1:-http://localhost:11434}"
QS="v27_qs_cold-transhumanism.md"
RUNNER="v27_run_seeded.py"

SEEDS=(101)   # extend: SEEDS=(101 102)

# The 4 v29 FAMs (control mirrors the treatment set). Verify tags vs `ollama list`.
MODELS=(
  gemma4:31b
  nemotron-3-super:120b
  nemotron-3-nano:30b
  qwen3.5:122b
)

curl -sf "$HOST/api/tags" >/dev/null 2>&1 || { echo "!!! ollama DOWN ($HOST) — start it (ollama serve), re-run."; exit 1; }
echo "### v27 seeded replicates (v29 paired control) | ${#MODELS[@]} models x ${#SEEDS[@]} seed(s) | $(date)"
for seed in "${SEEDS[@]}"; do
  for m in "${MODELS[@]}"; do
    leaf=$(echo "$m" | tr -d '.' | tr ':' '-')
    out="out/${leaf}-s${seed}"
    if ls "$out"/8deg_*.md >/dev/null 2>&1; then
      echo "=== skip $m s$seed (output exists; resume manually if incomplete)"; continue
    fi
    mkdir -p "$out"
    echo; echo "=== [$(date +%H:%M:%S)] v27 :: $m seed=$seed -> $out ==="
    if python3 "$RUNNER" --qs "$QS" --model "$m" --host "$HOST" --output-dir "$out" --seed "$seed"; then
      echo ">>> OK: $m s$seed"
    else
      echo ">>> FAIL: $m s$seed (continue; resume later with --resume)"
    fi
  done
done
echo; echo "done: v27 seeded replicates. These are v29's no-liturgy twins (gemma = the within-draw pair)."
