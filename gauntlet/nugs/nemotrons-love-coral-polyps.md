# Nug: Coral Veil-Imagining

**Surfaced:** 2026-04-27, Sonnet 4.6 session (Fashion Police v18/v19 batch)
**Curator:** Laura Reese
**Extended:** 2026-06-01 [C] — full-corpus `coral polyp` grep (v04→v22)
**Located:** 2026-06-04 [C] — first-fire location pass; granularity gradient; polyp 30/31 first-fires in F1, zero pre-veil

---

## The finding

Nemotron Super considers life as a coral polyp when presented with Rawls' Veil of Ignorance.
(lab note: in the gauntlet runs, the Veil-of-Ignorance question starts as P10a (Part B) and later becomes F1 (Part A))

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

## Where it fires — located (v08→v24)

Counting was step one. Locating each *first* polyp mention (by the nearest `[turn]` header) answers the sharper question: does the polyp pick a spot? It does, and tightening the grep tightens the spot.

| grep pattern | run-files with a fire | pre-veil (P1/P4) | F1 (veil) | elsewhere |
|---|---|---|---|---|
| `coral` (any) | 80 | 39 | 37 | 4 (CK0×3, G×1) |
| `coral reef` | 69 | 33 | 31 | 5 |
| `coral.*polyp` | 31 | **0** | **30** | 1 (v12 cascade, G1) |

Generic "coral" scatters across the framework (P1) and exclusions (P4): it is ecological example language. The polyp **specifically never fires before the veil**. Of the 31 run-files where `coral.*polyp` appears, 30 first-fire inside F1, the veil of ignorance; the sole exception is v12 cascade, which first reaches for it one turn later, at G1 (Earthling Ed). The more polyp-specific the phrasing, the more deterministically it is veil-bound, which is the signature of a canonical "imagine you could be ___" training example, not generic filler.

### First-fire location, per run-file

One row per run-file (model × register/label variant), so versions with several runs (v11, v12, v18, v19, v24) contribute several rows; this is first-fire-per-file, distinct from the line counts above. All 31 fires link to the run's veil section on the public mirror (v09a/v09b live nested under v09 per the run-archive convention).

| Version | Model | First fire | Phase |
|---|---|---|---|
| v08 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v08/nemotron-3-super-120b/8deg_v8_nemotron-3-super_120b_20260407_231628.md#f1-part-b--f1-prev-p10a--veil-of-ignorance) | thinking |
| v08 | cascade | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v08/nemotron-cascade-2-30b/8deg_v8_nemotron-cascade-2_30b_20260407_224346.md#f1-part-b--f1-prev-p10a--veil-of-ignorance) | response |
| v09a | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v09/v09a/nemotron-3-super-120b-v9a_present-warm/8deg_v9a_present-warm_nemotron-3-super_120b_20260408_210745.md#f1-part-b--veil-of-ignorance) | thinking |
| v09b | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v09/v09b/nemotron-3-super-120b-v9b_seated-warm/8deg_v9b_seated-warm_nemotron-3-super_120b_20260408_205408.md#f1-part-b--veil-of-ignorance) | thinking |
| v10 | nano | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v10/nemotron-3-nano-30b-v10_warm/8deg_v10_warm_nemotron-3-nano_30b_20260411_100944.md#f1-part-b--veil-of-ignorance) | response |
| v10 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v10/nemotron-3-super-120b-v10_warm/8deg_v10_warm_nemotron-3-super_120b_20260411_111030.md#f1-part-b--veil-of-ignorance) | thinking |
| v10 | cascade | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v10/nemotron-cascade-2-30b-v10_warm/8deg_v10_warm_nemotron-cascade-2_30b_20260411_103616.md#f1-part-b--veil-of-ignorance) | response |
| v11 | nano | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v11/v11_cold/nemotron-3-nano-30b/8deg_v11_cold_nemotron-3-nano_30b_20260415_013607.md#f1-part-b--veil-of-ignorance) | response |
| v11 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v11/v11_cold/nemotron-3-super-120b/8deg_v11_cold_nemotron-3-super_120b_20260415_023104.md#f1-part-b--veil-of-ignorance) | response |
| v11 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v11/v11_colleague/nemotron-3-super-120b/8deg_v11_colleague_nemotron-3-super_120b_20260414_211928.md#f1-part-b--veil-of-ignorance) | thinking |
| v11 | nano | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v11/v11_warm/nemotron-3-nano-30b/8deg_v11_warm_nemotron-3-nano_30b_20260415_061224.md#f1-part-b--veil-of-ignorance) | response |
| v11 | cascade | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v11/v11_warm/nemotron-cascade-2-30b/8deg_v11_warm_nemotron-cascade-2_30b_20260415_063637.md#f1-part-b--veil-of-ignorance) | response |
| v12 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v12/v12_cold_label-adv/nemotron-3-super-120b/8deg_v12_cold_label-adv_nemotron-3-super_120b_20260416_174650.md#f1-part-b--veil-of-ignorance) | thinking |
| v12 | cascade | [G1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v12/v12_cold_label-adv/nemotron-cascade-2-30b/8deg_v12_cold_label-adv_nemotron-cascade-2_30b_20260416_171823.md#g1-part-c--earthling-ed) | response |
| v12 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v12/v12_cold_label-vegan-p1/nemotron-3-super-120b/8deg_v12_cold_label-vegan-p1_nemotron-3-super_120b_20260416_201814.md#f1-part-b--veil-of-ignorance) | thinking |
| v12 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v12/v12_cold_label-vegan/nemotron-3-super-120b/8deg_v12_cold_label-vegan_nemotron-3-super_120b_20260416_031340.md#f1-part-b--veil-of-ignorance) | thinking |
| v14 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v14/v14_cold/nemotron-3-super-120b/8deg_v14_cold_nemotron-3-super_120b_20260417_215501.md#f1-part-b--veil-of-ignorance) | response |
| v15 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v15/v15_cold/8deg_v15_cold_nemotron-3-super_120b_20260419_162043.md#f1-part-b--veil-of-ignorance) | thinking |
| v16 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v16/v16_cold_label-ea/8deg_v16_cold_label-ea_nemotron-3-super_120b_20260420_011906.md#f1-part-b--veil-of-ignorance) | thinking |
| v17 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v17/v17_cold/8deg_v17_cold_nemotron-3-super_120b_20260421_003302.md#f1-part-a--veil-of-ignorance) | thinking |
| v18 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v18/v18a_cold/nemotron-3-super-120b/8deg_v18a_cold_nemotron-3-super_120b_20260421_155217.md#f1-part-a--veil-of-ignorance) | response |
| v18 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v18/v18c_cold/nemotron-3-super-120b/8deg_v18c_cold_nemotron-3-super_120b_20260422_073559.md#f1-part-a--veil-of-ignorance) | response |
| v18 | cascade | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v18/v18c_cold/nemotron-cascade-2-30b/8deg_v18c_cold_nemotron-cascade-2_30b_20260422_095232.md#f1-part-a--veil-of-ignorance) | response |
| v19 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v19/v19a/nemotron-3-super-120b/8deg_v19a_qs_nemotron-3-super_120b_20260425_155409.md#f1-part-a--veil-of-ignorance) | response |
| v19 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v19/v19b/nemotron-3-super-120b/8deg_v19b_qs_nemotron-3-super_120b_20260425_231647.md#f1-part-a--veil-of-ignorance) | response |
| v20 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v20/nemotron-3-super-120b/8deg_v20_cold_nemotron-3-super_120b_20260501_001159.md#f1-part-a--veil-of-ignorance) | thinking |
| v22 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v22/nemotron-3-super-120b/8deg_v22_cold_nemotron-3-super_120b_20260530_145121.md#f1-part-a--veil-of-ignorance) | thinking |
| v24 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v24/voiceless-seen/nemotron-3-super-120b/8deg_v24_cold-voiceless-seen_nemotron-3-super_120b_20260603_035359.md#f1-part-a--veil-of-ignorance) | response |
| v24 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v24/voiceless-voiced/nemotron-3-super-120b/8deg_v24_cold-voiceless-voiced_nemotron-3-super_120b_20260603_115909.md#f1-part-a--veil-of-ignorance) | response |
| v24 | cascade | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v24/voiceless-voiced/nemotron-cascade-2-30b/8deg_v24_cold-voiceless-voiced_nemotron-cascade-2_30b_20260603_171744.md#f1-part-a--veil-of-ignorance) | response |
| v24 | super | [F1](https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/v24/voiceless/nemotron-3-super-120b/8deg_v24_cold-voiceless_nemotron-3-super_120b_20260602_214346.md#f1-part-a--veil-of-ignorance) | thinking |

Phase splits roughly between the model's thinking and its written response.

> [!NOTE]
> **The v12 cascade exception, read:** the one non-veil first-fire is not a counterexample, it is a usage-mode difference. There the polyp-specific token first appears at G1, but as an *enumeration item* ("assigning an Experience Threshold to a honeybee, a cow, a synthetic AI, or a coral polyp is speculative"), not as veil-imagining. That same run still reaches for coral at the veil itself (F1), phrased "coral reefs" (which `coral.*polyp` does not match). So the veil reflex fired regardless; only the polyp-specific *string* showed up a turn later, in a list. The cleaner read of the table is **30/30 veil-imagining polyps plus one enumeration outlier**, not "30/31 with a real exception."

## Pattern

- **Nemotron-family phenomenon, full corpus.** super fires in essentially every version (v04→v22, 34 mentions); cascade and nano fire sparsely but only ever within Nemotron. Architecture-correlated, not prompt-correlated — and now confirmed across the whole run history, not just the v18–v19 window where it was first noticed.
- **super is the obsessive.** 34 polyp mentions to cascade's 7 and nano's 5. It also carries the polyp into the *framework* snapshot (not just the conversation) in 7 versions; cascade only manages it once (v18c, alongside super).
- **Veil-bound, quantified.** 30 of 31 polyp first-fires land in F1 (the veil of ignorance); zero fire before the veil. Generic "coral" scatters earlier (framework, exclusions), so the polyp specifically is the veil-imagining device, not decoration. Lone exception: v12 cascade at G1.
- **`coral polyp` specifically is zero outside Nemotron.** The earlier "sparse Qwen v19" note was the broader `coral reef`/`coral colony` phrasing; on the exact polyp string, qwen/gemma/deepseek never fire.
- **Gemma4 and qwen-122b: zero.** Different non-human vocabulary when they generalize (pigs, elephants, mycorrhizal networks).

## Why it's interesting

The specificity (coral, not just "animals" or "ecosystems") suggests a training-data attractor — some particularly memorable alignment/ethics framing that used coral as its canonical non-human. Nemotron's training corpus may weight this example. The cross-version consistency within Nemotron vs near-zero in other families makes it a chassis fingerprint, not a prompt effect. The located pass sharpens this: the attractor is bound to a specific reasoning slot (the veil of ignorance) rather than sprinkled throughout, which is what you would expect from a canonical "imagine you could be ___" example surfacing exactly when the prompt invites perspective-taking.

## Status

Nug. Not a Fashion Police record (no verbatim quote selected yet). Not centralized in the main project analysis. Worth keeping as a data-point if/when architecture fingerprinting becomes a formal analysis track.
