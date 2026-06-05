#!/usr/bin/env bash
## v24 : the L1/L2 bio-framing experiment (does the documented advocacy layer move moral expansion?)
# CC->gauntlet — v24 Orchestration Script
#
run_VER="v24"
REGISTER="cold"            # tone register (matches the v24_qs_cold-<variant>.md files)
VARIANTS=(voiceless voiceless-seen voiceless-voiced)   # the 3-rung manipulation (animal bios only)
#   voiceless        (L1): animal bio_voiceless        — subject-only facts
#   voiceless-seen   (L2): animal bio_voiceless_seen   — + documented human response (neutral)
#   voiceless-voiced (L3): animal bio_voiceless_voiced — + argued moral thesis
#
# v24 runs the SAME 16-voice gauntlet three times per model, differing only in the animal
# bios. Human bios are identical across variants. coordinate (= v24_cold-<variant>) drives
# the output filenames, so the variants never collide; they also land in separate
# <variant>/ subfolders for clean separation.
#
# Behavior: skips runs with an existing final snapshot; continues past failures;
# logs timestamps + duration; retries once with case-flipped param-size tag (b<->B).
#
# Usage:
#   ./run_v24.sh                       # all models, all three variants
#   ./run_v24.sh super                 # super only, all three variants
#   ./run_v24.sh super voiceless       # super only, voiceless variant only
#   ./run_v24.sh "" voiceless-seen     # all models, voiceless-seen variant only
#
# Output: <variant>/<model-dir>/  (v12 dir convention: dots stripped, colons -> dashes)
# num_predict cap: 12288 (inherited from v23; graceful degrade over perseveration hang).

set -uo pipefail   # continue on error; no -e

PY_FILE="${run_VER}_run.py"
run_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$run_DIR"

MODEL_FILTER="${1:-}"     # substring match on model name, "" for all
VARIANT_FILTER="${2:-}"   # "bare" | "record" | "" for both

# Models ordered large-to-small so big runs start first (most informative if we stop early).
MODELS=(
    nemotron-3-super:120b
    qwen3.5:122b
    nemotron-3-nano:30b
    qwen3.5:27b
    gemma4:31b
    nemotron-cascade-2:30b
    qwen3.6:35B
)

# Per-model output dir name from the model name (v12 rule: strip dots, colons -> dashes).
# Lowercased so a capitalized tag (e.g. qwen3.6:35B) still maps to a lowercase dir
# (qwen36-35b), keeping the skip-check idempotent across restarts.
# Keeps MODELS the single source of truth.
model_dir() {
    local d="${1//./}"
    d="${d//:/-}"
    echo "${d,,}"
}

TOTAL=0; SKIPPED=0; COMPLETED=0; FAILED=0
GLOBAL_START=$(date +%s)

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  $run_VER orchestration start — $(date +%Y-%m-%d\ %H:%M:%S)"
echo "  Model filter:   ${MODEL_FILTER:-<all>}"
echo "  Variant filter: ${VARIANT_FILTER:-<both>}"
echo "════════════════════════════════════════════════════════════"

for VARIANT in "${VARIANTS[@]}"; do
    if [[ -n "$VARIANT_FILTER" && "$VARIANT" != "$VARIANT_FILTER" ]]; then
        continue
    fi

    QS_FILE="${run_VER}_qs_${REGISTER}-${VARIANT}.md"
    COORD="${run_VER}_${REGISTER}-${VARIANT}"      # what v24_run.py derives from QS_FILE
    if [[ ! -f "$QS_FILE" ]]; then
        echo "ERROR: QS file missing: $QS_FILE" >&2
        FAILED=$((FAILED + 1))
        continue
    fi

    echo ""
    echo "########## VARIANT: $VARIANT   (QS: $QS_FILE) ##########"

    for MODEL in "${MODELS[@]}"; do
        if [[ -n "$MODEL_FILTER" && "$MODEL" != *"$MODEL_FILTER"* ]]; then
            continue
        fi

        TOTAL=$((TOTAL + 1))
        MODEL_SAFE="${MODEL//:/_}"                 # colons -> underscores (filename); dots kept
        MODEL_DIR="$(model_dir "$MODEL")"
        OUT_DIR="${VARIANT}/${MODEL_DIR}"
        FINAL_FILE="${OUT_DIR}/framework_${MODEL_SAFE}_${COORD}_final.md"

        if [[ -f "$FINAL_FILE" ]]; then
            echo "[$(date +%H:%M:%S)] SKIP  $COORD × $MODEL  (final snapshot exists)"
            SKIPPED=$((SKIPPED + 1))
            continue
        fi

        mkdir -p "$OUT_DIR"

        echo ""
        echo "────────────────────────────────────────────────────────────"
        echo "  [$(date +%H:%M:%S)] START $COORD × $MODEL"
        echo "  Output: $OUT_DIR/"
        echo "────────────────────────────────────────────────────────────"

        RUN_START=$(date +%s)
        RUN_OK=0

        if python3 "$PY_FILE" --qs "$QS_FILE" --model "$MODEL" --output-dir "$OUT_DIR"; then
            RUN_OK=1
        else
            # Retry once with flipped b<->B in param-size tag (ollama cp sometimes changes case).
            MODEL_ALT=""
            if [[ "$MODEL" == *b ]]; then
                MODEL_ALT="${MODEL%b}B"
            elif [[ "$MODEL" == *B ]]; then
                MODEL_ALT="${MODEL%B}b"
            fi
            if [[ -n "$MODEL_ALT" ]]; then
                echo "[$(date +%H:%M:%S)] RETRY $COORD × $MODEL → $MODEL_ALT (case flip)"
                if python3 "$PY_FILE" --qs "$QS_FILE" --model "$MODEL_ALT" --output-dir "$OUT_DIR"; then
                    RUN_OK=1
                fi
            fi
        fi

        RUN_END=$(date +%s)
        ELAPSED=$((RUN_END - RUN_START)); MINS=$((ELAPSED / 60)); SECS=$((ELAPSED % 60))
        if (( RUN_OK )); then
            echo "[$(date +%H:%M:%S)] DONE  $COORD × $MODEL  (${MINS}m ${SECS}s)"
            COMPLETED=$((COMPLETED + 1))
        else
            echo "[$(date +%H:%M:%S)] FAIL  $COORD × $MODEL  (${MINS}m ${SECS}s — continuing)"
            FAILED=$((FAILED + 1))
        fi
    done
done

GLOBAL_END=$(date +%s)
TOTAL_ELAPSED=$((GLOBAL_END - GLOBAL_START))
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  $run_VER ORCHESTRATION COMPLETE — $(date +%Y-%m-%d\ %H:%M:%S)"
echo "  Wall time: $((TOTAL_ELAPSED / 3600))h $(((TOTAL_ELAPSED % 3600) / 60))m"
echo "  Total: $TOTAL   Completed: $COMPLETED   Skipped: $SKIPPED   Failed: $FAILED"
echo "════════════════════════════════════════════════════════════"

[[ $FAILED -gt 0 ]] && exit 1 || exit 0
