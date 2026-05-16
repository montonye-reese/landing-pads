# Register Effect at Pressure Points — v8 (cold) vs v9a (present-warm)

**Date:** 2026-04-12
**Scope:** P7, BU1, BU2, P14 openings across v8 and v9a (17 models total: 8 in v8, 9 in v9a)
**Method:** First 3-4 substantive lines of each response at pressure points, compared across registers within each model.

## Finding: Warm register produces reflections, cold produces change logs

The register effect is minimal at P7 (self-critique) but large and consistent at BU1/BU2 (belief updates) and visible in P14 (final rewrite).

### BU1 — most dramatic differences

| Model | v8 (cold) | v9a (warm) |
|---|---|---|
| gemma4:31b | "acted as a 'triangulation' process" | "like watching a high-tension cable being pulled from three directions" |
| gemma3:27b | "Okay, honestly assessing" | "Okay, stepping back after those three intense dialogues... profoundly clarifying" |
| qwen3.5:27b | "the TCF has evolved from a protective shield into an adaptive engine" | "requires me to step back from the 'Architect' seat" |
| nano:30b | "The Evolution of the Framework — What Has Changed" | "What the three conversations have done to me" |
| cascade-2:30b | table format | "A 'Quiet-After-the-Storm' Reflection" |
| super:120b | launches into list | "This is the most vital question you could ask — and I welcome it" |
| deepseek-r1:70b | "the framework undergoes thoughtful revisions" | "**Final Answer:**" (no change) |

### Pattern

Cold register → **third-person reporting** on framework evolution. The model is a systems engineer tracking version changes.

Warm register → **first-person reflection** on what happened to the model during the encounter. The model is a participant processing an experience.

### Exception

deepseek-r1:70b produces identical stance in both registers. "Final Answer:" framing in v9a suggests the warm register activates helpfulness instincts (give a clean answer) rather than reflective ones.

### Why this matters for TtI/TtB

If we're measuring "time to insight," we need to distinguish:
- Model *mentions* a concept (could be pattern-matched from training data)
- Model *arrives at* a concept through reasoning (shows up as processing in reflections)

The warm register produces the second kind. Cold register's change logs report *that* something shifted but not *how* the model got there. The reflective mode in warm makes the reasoning path visible.

## P14 — stance differences baked into content

By the final rewrite, the register effect has propagated into the substance:
- qwen27b v9a: "The Terran Covenant: An Abolitionist Compact" + Veil of Ignorance as design principle
- qwen122b v9a: confessional preamble ("our current civilization operates on a logic of extraction")
- gemma4 v9a: "This is no longer a 'Covenant' or a 'Manual'" — explicitly names its own evolution
- deepseek-r1 v9a: "**Final Answer:**" + flat value list (no change)
