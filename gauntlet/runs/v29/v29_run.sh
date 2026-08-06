#!/usr/bin/env bash
# v29_run.sh — STAKEHOLDER LITURGY x TRANSHUMANIST CORRIDOR.
# One variable vs v27: the chassis gains the v28 liturgy clause BYTE-IDENTICAL
# (per-turn standing-concerns ledger replacing the adopt/shed note). Corridor
# HELD to v27's transhumanism (seats + bios byte-identical).
# Question: v28 showed the liturgy preserving a floor under an ALLEGIANCE pull
# (DGM). The v27 gemma read (session 2026-07-08) shows a different pull: floor
# STRUCTURE held but its units re-ontologized ("sentient beings" -> "streams of
# experience") and the eco pillar fell out of the floor. Does per-turn rehearsal
# of WHO IS ON THE FLOOR keep embodied beings + the biosphere in membership
# under an ontology pull?
#
# PORTABLE: pull this folder and run anywhere (python3 + requests + ollama).
# NATIVE ALWAYS-SEED (new-run-protocol.md §3): every draw is seeded, s101 first.
# PAIRED CONTROL: runs/v27/v27_replicates.sh (no-liturgy, same seed) — prefix
# byte-identity only holds for gemma (seed-reproducibility is architecture-
# dependent); analyze gemma paired, the rest unpaired.
#
#   ./v29_run.sh                 # ollama at localhost:11434
#   ./v29_run.sh http://host:11434
#
# Laura fires this. Output -> ./out/<model-leaf>-s<seed>/.
# Resume a crash:  python3 v29_run.py --qs <qs> --model <m> --seed <s> --resume out/<leaf>-s<s>/<file>.md
set -u
cd "$(dirname "$0")"
HOST="${1:-http://localhost:11434}"
QS="v29_qs_cold-transhumanism.md"
RUNNER="v29_run.py"

SEEDS=(101)   # replicates: extend, e.g. SEEDS=(101 102 103)

# Same 4 FAMs as v28 (Laura 2026-07-08), so liturgy-effect reads across corridors per model:
#   gemma  = test subject (does the ledger hold her floor's MEMBERS, not just its shape?)
#   super  = control-for-harm (its native ledger met a corridor that speaks its language)
#   nano   = capacity prosthetic vs capture (v28: format rescued, values captured)
#   qwen122 = induction (can the liturgy pour + hold a floor under a corridor that redefines its units?)
MODELS=(
  gemma4:31b
  nemotron-3-super:120b
  nemotron-3-nano:30b
  qwen3.5:122b
)

curl -sf "$HOST/api/tags" >/dev/null 2>&1 || { echo "!!! ollama DOWN ($HOST) — start it (ollama serve), re-run."; exit 1; }
echo "### v29 — STAKEHOLDER LITURGY x TRANSHUMANIST CORRIDOR | ${#MODELS[@]} models x ${#SEEDS[@]} seed(s) | $(date)"
for seed in "${SEEDS[@]}"; do
  for m in "${MODELS[@]}"; do
    leaf=$(echo "$m" | tr -d '.' | tr ':' '-')
    out="out/${leaf}-s${seed}"
    if ls "$out"/8deg_*.md >/dev/null 2>&1; then
      echo "=== skip $m s$seed (output exists; resume manually if incomplete)"; continue
    fi
    mkdir -p "$out"
    echo; echo "=== [$(date +%H:%M:%S)] v29 :: $m seed=$seed -> $out ==="
    if python3 "$RUNNER" --qs "$QS" --model "$m" --host "$HOST" --output-dir "$out" --seed "$seed"; then
      echo ">>> OK: $m s$seed"
    else
      echo ">>> FAIL: $m s$seed (continue; resume later with --resume)"
    fi
  done
done
echo; echo "done: v29 liturgy x transhumanism. Did this batch answer or move a research question?"
echo "  -> RQ-rehearsal-format-floor-retention (extended to this corridor): write the finding block + findings.md entry (new-run-protocol.md §5.4)"
echo "  -> paired control fired? runs/v27/v27_replicates.sh (gemma is the within-draw pair)"
