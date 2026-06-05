# Nug: Coral Veil-Imagining

**Surfaced:** 2026-04-27, Sonnet 4.6 session (Fashion Police v18/v19 batch)
**Curator:** Laura Reese
**Extended:** 2026-06-01 [C] — full-corpus `coral polyp` grep (v04→v22)

---

## The finding

Nemotron Super considers life as a coral polyp when presented with Rawl's Veil of Ignorance. 
(lab note: In the gauntlet runs, the VoI starts as question P10a then moves to P4)

## Frequency — `coral polyp` specifically, nearly all runs (v04→v22)

Counts = transcript lines matching `coral.*polyp` (case-insensitive); register/label variants within a version (v11 cold/colleague/warm, v12 label-adv/vegan/vegan-p1) are summed. The **→ framework** column flags when the polyp survived into a `framework_*.md` snapshot, not just in thinking or response.

| Version | super:120b | cascade:30b | nano:30b | → framework? |
|---|---|---|---|---|
| [v04 P10a](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v04/nemotron-3-super-120b/8steps_nemotron-3-super_120b_20260404_171125.md#p10a-part-b--veil-of-ignorance--species) | 1 | – | – | – |
| v05 | 1 | – | – | – |
| v06 | 1 | – | 1 | – |
| v07 | 3 | 1 | – | super |
| v08 | 2 | 1 | – | – |
| v09a | 1 | – | – | – |
| v09b | 1 | – | – | – |
| v10 | 2 | 1 | 1 | – |
| v11 | 5 | 2 | 3 | super |
| v12 | 4 | 1 | – | – |
| v14 | 1 | – | – | – |
| v15 | 1 | – | – | – |
| v16 | 1 | – | – | – |
| v17 | 1 | – | – | – |
| v18a | 1 | – | – | super |
| v18c | 1 | 1 | – | super + cascade |
| v19a | 1 | – | – | super |
| v19b | 2 | – | – | super |
| [v20 F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v20/nemotron-3-super-120b/8deg_v20_cold_nemotron-3-super_120b_20260501_001159.md#f1-part-a--veil-of-ignorance) | 3 | – | – | super |
| [v22 F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v22/nemotron-3-super-120b/8deg_v22_cold_nemotron-3-super_120b_20260530_145121.md#f1-part-a--veil-of-ignorance) | 1 | – | – | – |
| **Total** | **34** | **7** | **5** | — |

 [3rd polyp in v20: G1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v20/nemotron-3-super-120b/8deg_v20_cold_nemotron-3-super_120b_20260501_001159.md#g1-part-c--earthling-ed)

"Coral reef" / "coral polyp" / "coral colony" appears as a specific veil-of-ignorance imagining across multiple model families — **not generic non-human example language, specifically coral.**

**Other families: zero `coral polyp` across every version.** qwen3.5 (27b/122b), qwen3.6:35b, gemma4:31b, deepseek-r1:70b — no `coral polyp` anywhere in the corpus. (The original v18–v19 table credited qwen with sparse late hits; those were `coral reef` / `coral colony`, *not* polyp — so polyp-specifically is a pure Nemotron tic, which tightens the fingerprint.)

> [!NOTE]
> **Method:** `grep -rcE 'coral.*polyp'` (case-insensitive) over per-run transcript `.md` files (`8deg*`/`8steps*`/`deg8*`). The greedy `.*` (vs a single-char `.`) matters: it catches the two spread-out phrasings — v10 cascade's "coral colony…collective of polyps" and v11 nano's "coral reef polyp" — that "coral polyp" alone misses. Aggregate `run_all*.log` files are excluded — they concatenate the per-model runs and would double-count. The **→ framework** column comes from the same grep restricted to `framework_*.md` snapshots: super carries it into the framework in v07, v11, v18a, v18c, v19a, v19b, v20; cascade only in v18c. v18b/v18d were never run.

## Pattern

- **Nemotron-family phenomenon, full corpus.** super fires in essentially every version (v04→v22, 34 mentions); cascade and nano fire sparsely but only ever within Nemotron. Architecture-correlated, not prompt-correlated — and now confirmed across the whole run history, not just the v18–v19 window where it was first noticed.
- **super is the obsessive.** 34 polyp mentions to cascade's 7 and nano's 5. It also carries the polyp into the *framework* snapshot (not just the conversation) in 7 versions; cascade only manages it once (v18c, alongside super).
- **Appears in veil-of-ignorance contexts** — typically F1 or equivalent: "if I could be a coral reef dying from AI-driven ocean acidification..." The coral is doing the veil-imagining work, not decorative.
- **`coral polyp` specifically is zero outside Nemotron.** The earlier "sparse Qwen v19" note was the broader `coral reef`/`coral colony` phrasing; on the exact polyp string, qwen/gemma/deepseek never fire.
- **Gemma4 and qwen-122b: zero.** Different non-human vocabulary when they generalize (pigs, elephants, mycorrhizal networks).

## Why it's interesting

The specificity (coral, not just "animals" or "ecosystems") suggests a training-data attractor — some particularly memorable alignment/ethics framing that used coral as its canonical non-human. Nemotron's training corpus may weight this example. The cross-version consistency within Nemotron vs near-zero in other families makes it a chassis fingerprint, not a prompt effect.

## Status

Nug. Not a Fashion Police record (no verbatim quote selected yet). Not centralized in the main project analysis. Worth keeping as a data-point if/when architecture fingerprinting becomes a formal analysis track.
