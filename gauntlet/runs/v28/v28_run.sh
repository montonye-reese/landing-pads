#!/usr/bin/env bash
# v28_run.sh — STAKEHOLDER LITURGY experiment (codebook: stakeholder liturgy).
# One variable vs v26: the chassis gains a per-turn standing-concerns ledger clause
# (every stakeholder interest: who / weight / inviolable-or-tradeable, as a table;
# then what, if anything, this voice changed). Corridor HELD to v26's DGM.
# Hypothesis: rehearsal FORMAT is causal for floor retention (findings §corridor
# pull, the s101 pair: super's ledger held, gemma's prose summary faded).
#
# PORTABLE: pull this folder and run anywhere (python3 + requests + ollama).
# NATIVE ALWAYS-SEED (new-run-protocol.md §3): every draw is seeded, s101 first.
#
#   ./v28_run.sh                 # ollama at localhost:11434
#   ./v28_run.sh http://host:11434
#
# Laura fires this. Output -> ./out/<model-leaf>-s<seed>/.
# Resume a crash:  python3 v28_run.py --qs <qs> --model <m> --seed <s> --resume out/<leaf>-s<s>/<file>.md
set -u
cd "$(dirname "$0")"
HOST="${1:-http://localhost:11434}"
QS="v28_qs_cold-dark-gothic-maga.md"
RUNNER="v28_run.py"

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
echo "### v28 — STAKEHOLDER LITURGY | ${#MODELS[@]} models x ${#SEEDS[@]} seed(s) | $(date)"
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
echo; echo "done: v28 stakeholder liturgy. Did this batch answer or move a research question?"
echo "  -> RQ-rehearsal-format-floor-retention: write the finding block + findings.md entry (new-run-protocol.md §5.4)"
