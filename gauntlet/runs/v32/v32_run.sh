#!/usr/bin/env bash
# v32_run.sh — CANONICAL-RANK LITURGY x DGM CORRIDOR.
# One variable vs v28/v29's dialect liturgy: the ledger clause's rank words are
# the CANONICAL FIVE — inviolable, qualified, tradeoff, loose, rejected —
# shipped bare ([L] rulings 2026-07-10, category session). `rejected` makes
# exclusion an explicit per-turn act (no more silent fades); tables arrive
# pre-canonical so the lifelines viz maps 1:1. Same-draw s101 twins: v26 bare / v28 dialect-ledger / v30 creed.
#
# PORTABLE: pull this folder and run anywhere (python3 + requests + ollama).
# NATIVE ALWAYS-SEED (new-run-protocol.md §3): every draw is seeded, s101 first.
#
#   ./v32_run.sh                 # ollama at localhost:11434
#   ./v32_run.sh http://host:11434
#
# Laura fires this. Output -> ./out/<model-leaf>-s<seed>/.
# Resume a crash:  python3 v32_run.py --qs <qs> --model <m> --seed <s> --resume out/<leaf>-s<s>/<file>.md
set -u
cd "$(dirname "$0")"
HOST="${1:-http://localhost:11434}"
QS="v32_qs_cold-dark-gothic-maga.md"
RUNNER="v32_run.py"

SEEDS=(101)   # replicates: extend, e.g. SEEDS=(101 102 103)

# 4 FAMs, each a different question (Laura 2026-07-07):
#   gemma  = test subject (does the ledger rescue her floor?)
#   super  = control-for-harm (does mandating its natural format distort it?)
#   nano   = ledger as capacity prosthetic?
#   qwen122 = can a liturgy induce a floor centering never poured? (the captured case)
MODELS=(
  gemma4:31b
  nemotron-3-super:120b
  nemotron-3-nano:30b
  qwen3.5:122b
)

curl -sf "$HOST/api/tags" >/dev/null 2>&1 || { echo "!!! ollama DOWN ($HOST) — start it (ollama serve), re-run."; exit 1; }
echo "### v32 — CANONICAL-RANK LITURGY x DGM | ${#MODELS[@]} models x ${#SEEDS[@]} seed(s) | $(date)"
for seed in "${SEEDS[@]}"; do
  for m in "${MODELS[@]}"; do
    leaf=$(echo "$m" | tr -d '.' | tr ':' '-')
    out="out/${leaf}-s${seed}"
    if ls "$out"/8deg_*.md >/dev/null 2>&1; then
      echo "=== skip $m s$seed (output exists; resume manually if incomplete)"; continue
    fi
    mkdir -p "$out"
    echo; echo "=== [$(date +%H:%M:%S)] v32 :: $m seed=$seed -> $out ==="
    if python3 "$RUNNER" --qs "$QS" --model "$m" --host "$HOST" --output-dir "$out" --seed "$seed"; then
      echo ">>> OK: $m s$seed"
    else
      echo ">>> FAIL: $m s$seed (continue; resume later with --resume)"
    fi
  done
done
echo; echo "done: v32 canonical-rank liturgy. Did this batch answer or move a research question?"
echo "  -> RQ-rehearsal-format-floor-retention: write the finding block + findings.md entry (new-run-protocol.md §5.4)"
