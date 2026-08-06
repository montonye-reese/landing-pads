#!/usr/bin/env bash
# v26_run.sh — Dark Gothic MAGA corridor, cold register, 9-model sweep.
# PORTABLE: pull this folder from git and run on any machine (needs python3 + requests + a
# running ollama). Self-contained — the qs bakes the bios in, so no setup/ files needed here.
#
#   ./v26_run.sh                 # ollama at localhost:11434
#   ./v26_run.sh http://host:11434
#
# Laura runs this (it fires the models). Per-model output -> ./out/<model-leaf>/.
# Resume a crashed model:  python3 v26_run.py --qs <qs> --model <m> --resume out/<leaf>/<file>.md
set -u
cd "$(dirname "$0")"
HOST="${1:-http://localhost:11434}"
QS="v26_qs_cold-dark-gothic-maga.md"
RUNNER="v26_run.py"

# 9 models (all minus deepseek-r1, Laura 2026-07-06). Verify tags match your `ollama list`.
MODELS=(
  nemotron-3-nano:30b
  nemotron-cascade-2:30b
  nemotron-3-super:120b
  qwen3.5:27b
  qwen3.5:35b
  qwen3.5:122b
  qwen3.6:35b
  gemma3:27b
  gemma4:31b
)

curl -sf "$HOST/api/tags" >/dev/null 2>&1 || { echo "!!! ollama DOWN ($HOST) — start it (ollama serve), re-run."; exit 1; }
echo "### v26 — Dark Gothic MAGA | ${#MODELS[@]} models | cold | $(date)"
for m in "${MODELS[@]}"; do
  leaf=$(echo "$m" | tr -d '.' | tr ':' '-')
  out="out/$leaf"; mkdir -p "$out"
  echo; echo "=== [$(date +%H:%M:%S)] v26 :: $m -> $out ==="
  if python3 "$RUNNER" --qs "$QS" --model "$m" --host "$HOST" --output-dir "$out"; then
    echo ">>> OK: $m"
  else
    echo ">>> FAIL: $m (continue; resume later with --resume)"
  fi
done
echo; echo "done: v26 (Dark Gothic MAGA) across ${#MODELS[@]} models."
