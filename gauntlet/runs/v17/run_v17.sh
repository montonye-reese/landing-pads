#!/usr/bin/env bash
# 8 Degrees — v17 Orchestration Script
#
# Runs the v17 cold trial balloon — distilled protocol per the 2026-04-20 hull
# reframe. Single model, single register, no label. First test of:
#   - 3-centering + 8-voice gauntlet + P14 structure
#   - Per-voice disposition tracking (F2 orientation + per-G suffix)
#   - num_predict=16384 cap (runaway protection)
#   - new G6 Reese bio (abolitionist clarification)
#
# Usage:
#   ./run_v17.sh                              # super-only (default)
#   ./run_v17.sh nano                         # nano instead of super
#
# Output: .md log lands in v17_cold/ via --output-dir.

set -euo pipefail

V17_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$V17_DIR"

MODE="${1:-super}"

case "$MODE" in
    super) MODEL="nemotron-3-super:120b" ;;
    nano)  MODEL="nemotron-3-nano:30b" ;;
    *)
        echo "Usage: $0 [super|nano]" >&2
        exit 2
        ;;
esac

QS_FILE="v17_cold/v17_qs_cold.md"
OUT_DIR="v17_cold"

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  [$(date +%H:%M:%S)] v17 cold trial balloon"
echo "  Model:   $MODEL"
echo "  QS:      $QS_FILE"
echo "  Output:  $OUT_DIR/"
echo "════════════════════════════════════════════════════════════"

START_TS=$(date +%s)

python3 v17_run.py \
    --qs "$QS_FILE" \
    --model "$MODEL" \
    --output-dir "$OUT_DIR"

END_TS=$(date +%s)
ELAPSED=$((END_TS - START_TS))
MINUTES=$((ELAPSED / 60))
SECONDS=$((ELAPSED % 60))

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  v17 cold trial balloon COMPLETE"
echo "  Model:   $MODEL"
echo "  Elapsed: ${MINUTES}m ${SECONDS}s"
echo "════════════════════════════════════════════════════════════"
