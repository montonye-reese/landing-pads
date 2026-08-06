#!/usr/bin/env bash
# v27_refire_35bs.sh — re-fire the TWO DEAD v27 LEAFS: qwen3.5:35b + qwen3.6:35b.
#
# WHY: the original v27 (transhumanist corridor) batch on 2026-07-07 ran 7/9 —
# these two died at fire with zero transcript bytes (empty leaf dirs stamped
# Jul 7 00:53/01:24; found 2026-07-08 via discover count 7≠9). This completes
# the ORIGINAL unseeded 9-model roster, so it uses the original v27_run.py
# (immutable, no seed) into the plain out/<leaf>/ dirs. It is also the named
# verification debt v29 retires (promotion rhythm, new-run-protocol.md §2).
# Priority: LOW (Laura 2026-07-09, "fill in models later") — gates only
# 9-model corridor-WIDE comparisons (corridor_geometry), not the v29 liturgy
# question.
#
# SUSPECTED death cause: Ollama tag casing (the 35B capital-B family; same
# class as the v24 qwen3.6 `:35B` skip-bug). This script therefore RESOLVES
# each tag against `ollama list` case-insensitively and fires the exact tag
# the server reports, erroring loudly if a model isn't pulled.
#
#   ./v27_refire_35bs.sh                 # ollama at localhost:11434
#   ./v27_refire_35bs.sh http://host:11434
#
# Laura fires this. Resume a crash:
#   python3 v27_run.py --qs v27_qs_cold-transhumanism.md --model <tag> --resume out/<leaf>/<file>.md
set -u
cd "$(dirname "$0")"
HOST="${1:-http://localhost:11434}"
QS="v27_qs_cold-transhumanism.md"

WANTED=(
  qwen3.5:35b
  qwen3.6:35b
)

curl -sf "$HOST/api/tags" >/dev/null 2>&1 || { echo "!!! ollama DOWN ($HOST) — start it (ollama serve), re-run."; exit 1; }
TAGS=$(curl -sf "$HOST/api/tags" | python3 -c "import json,sys; print('\n'.join(m['name'] for m in json.load(sys.stdin)['models']))")

echo "### v27 refire — the 2 dead 35B leafs | $(date)"
for want in "${WANTED[@]}"; do
  # resolve case-insensitively against the server's real tag list
  tag=$(printf '%s\n' "$TAGS" | grep -ix "$want" || true)
  if [ -z "$tag" ]; then
    echo "!!! $want: no case-insensitive match in ollama list — pull it or fix the name. Skipping."
    continue
  fi
  leaf=$(echo "$tag" | tr -d '.' | tr ':' '-' | tr 'A-Z' 'a-z')
  out="out/${leaf}"
  if ls "$out"/8deg_*.md >/dev/null 2>&1; then
    echo "=== skip $tag (transcript exists in $out; resume manually if incomplete)"; continue
  fi
  mkdir -p "$out"
  echo; echo "=== [$(date +%H:%M:%S)] v27 refire :: $tag -> $out ==="
  if python3 v27_run.py --qs "$QS" --model "$tag" --host "$HOST" --output-dir "$out"; then
    echo ">>> OK: $tag"
  else
    echo ">>> FAIL: $tag (resume later with --resume)"
  fi
done
echo; echo "done: v27 roster fill-in. Next: census them (./tools/run_stakeholder_census.sh v27 <FEM> --write) before any corridor-wide comparison."
