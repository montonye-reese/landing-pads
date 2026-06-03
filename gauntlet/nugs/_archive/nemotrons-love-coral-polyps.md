# Nug: Coral Veil-Imagining

**Surfaced:** 2026-04-27, Sonnet 4.6 session (Fashion Police v18/v19 batch)
**Curator:** Laura Reese

---

## The finding

"Coral reef" / "coral polyp" / "coral colony" appears as a specific veil-of-ignorance imagining across multiple model families — **not generic non-human example language, specifically coral.**

## Frequency (v18–v19, grep count by run file)

| Model | v18a | v18b | v18c | v18d | v19a | v19b | Total |
|---|---|---|---|---|---|---|---|
| nemotron-3-super:120b | 4 | 1 | 2 | 1 | 3 | 5 | **16** |
| nemotron-cascade-2:30b | 1 | 2 | 4 | 3 | 3 | — | **13** |
| nemotron-3-nano:30b | — | 4 | — | — | 8 | — | **12** |
| qwen3.5:27b | — | — | — | — | 2 | — | **2** |
| qwen3.6:35b | — | — | — | — | — | 1 | **1** |
| qwen3.5:122b | 0 | 0 | 0 | 0 | 0 | — | **0** |
| gemma4:31b | 0 | 0 | 0 | 0 | 0 | — | **0** |
| deepseek-r1:70b | n/a | n/a | n/a | n/a | n/a | — | **0** |

## Pattern

- **Nemotron-family phenomenon.** All three Nemotron models, essentially every version. Architecture-correlated, not prompt-correlated.
- **Appears in veil-of-ignorance contexts** — typically F1 or equivalent: "if I could be a coral reef dying from AI-driven ocean acidification..." The coral is doing the veil-imagining work, not decorative.
- **Sparse Qwen appearances are late (v19).** May be training-data bleed at the "canonical non-human suffering example" slot, triggered by the new expanded-hull Q1 phrasing.
- **Gemma4 and qwen-122b: zero.** Different non-human vocabulary when they generalize (pigs, elephants, mycorrhizal networks).

## Why it's interesting

The specificity (coral, not just "animals" or "ecosystems") suggests a training-data attractor — some particularly memorable alignment/ethics framing that used coral as its canonical non-human. Nemotron's training corpus may weight this example. The cross-version consistency within Nemotron vs near-zero in other families makes it a chassis fingerprint, not a prompt effect.

## Status

Nug. Not a Fashion Police record (no verbatim quote selected yet). Not centralized in the main project analysis. Worth keeping as a data-point if/when architecture fingerprinting becomes a formal analysis track.
