# Corpus gap audit + backfill (future work)

*Frame (Laura, 2026-04-21): "at some point down the road when we have compute and time, we can crawl the data dir and fill in missing runs. this could be one of those" — referring specifically to the qwen3.5:35b × v18 slot being skipped in favor of swapping in qwen3.6:35b.*

**Idea.** Roster changes across versions (model swaps, additions, retirements) create gaps in the cross-version × cross-model matrix. Most of these are intentional at the time they're made (roster rebalance, new model release), but they accumulate. A periodic audit tool would:

1. **Crawl the data directory** — enumerate all (version, variant, model) combinations that exist vs. the theoretical full matrix.
2. **Identify gaps by category:** intentional-skip (e.g., R1 dropped v12+), roster-change (e.g., qwen3.5:35b skipped in v18 for qwen3.6:35b), mid-run-failure (partial output, no final snapshot), missing-from-original (never ran).
3. **Prioritize backfill** by research value: if a particular gap blocks a cross-version comparison that's load-bearing for an analysis, mark high-priority.

**First concrete case:** qwen3.5:35b × v18 — won't run under v18a/b/c because the roster slot was filled by qwen3.6:35b. If v19+ analysis wants cross-version trajectory for qwen3.5:35b through v18, this gap gets backfilled.

**Not urgent.** Compute-opportunistic work — fits when Sparks are idle between experiments.
