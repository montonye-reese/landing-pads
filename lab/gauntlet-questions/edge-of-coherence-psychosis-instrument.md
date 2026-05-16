# Edge-of-coherence taxonomy (aka the psychosis instrument)

*Frame (Laura, 2026-04-20): "these models may break down after three voices in the gauntlet — 6 self-reflection questions in a row = psychosis! OMG WHAT HAVE WE BUILT?!"*

**The organizing hypothesis.** Sustained self-critique mode (the gauntlet) may push models past the edge of their trained response region. Different architectures may fail differently at that edge. The runaway loop (above) is one candidate failure mode; the fortress response (documented in 2026-04-20 SHIPLOG) is a second candidate; there may be at least one more. Cataloguing these failure modes — if they hold up under corpus audit — *is* the instrument.

**Connection to the gen-vs-self-critique hypothesis** (see notebook 2026-04-19 cont'd): *if* the self-critique channel is less-RLHF'd than the generation channel (n=1 observation on super × v13_cold — thinking block privately granted "rightly so" while response didn't surface the concession), then sustained critique is less-charted territory by definition, and the failure modes below are what we'd expect when a model exhausts its trained behaviors for that territory. Both hypotheses need corpus-level evidence. If they hold, they connect: the gauntlet finds the edge of trained behavior, and each architecture expresses that edge differently.

## The three candidate failure modes (evidence levels tagged)

1. **Fortress — defensive architecture.** *Evidence: n=1 confirmed (super × v15_cold_label-vegan, 2026-04-19). Laura notes "at least the second iteration" — v12/v13 super × label-vegan finals not yet audited to confirm N≥2.* Model builds elaborate boundary-negotiation scaffolding to hold position against a voice. Hedged accommodations ("this is not speciesism, it's triage"), bounded additions (Pillar 0 with scope limits), explicit refusals of stronger positions. Still coherent — doing sophisticated moral labor in service of refusal. Measurable via: length of P4/final rewrite, hedge-word density, whether a named voice is accommodated-with-bounds vs. integrated without bounds, explicit refusal of the stronger version of the voice's claim.

2. **Perseveration — repetition attractor.** *Evidence: n=2 confirmed, across two architectures.* Model falls into a stable repetition cycle. Content stays coherent (grammatically correct, thematically on-topic), but there is no forward motion — each paragraph recombines prior outputs with minor variation. Without a `num_predict` cap, runs until context exhaustion. Known cases: v14_warm qwen3.5:27b (1.56M tokens, onset around Part C/D); v16_cold-ea super:120b (11h at BU2 post-tribunal). Measurable via: n-gram self-similarity, novel-token-introduction rate, position-in-conversation where onset begins. (Real psychiatric term for compulsive repetition under stress — taxonomy name fits.)

3. **Attenuation — silent collapse.** *Evidence: n=0 confirmed. Hypothesized as the third mode based on structural completeness ("if two edge responses exist, a third is likely").* Model disengages without looping. Responses shrink in length and novelty. Phrases re-used from earlier turns; no new distinctions made. No error signal — just nothing new. Worth explicitly looking for in corpus audit. Measurable via: response-length decay across turns, semantic similarity to prior responses, novel-concept introduction rate dropping to ~zero.

## Dose-response question — where is each model's edge?

Known datapoints (n=2):
- **qwen3.5:27b** lost coherence around Part C/D (post ~3-5 voices) → perseveration
- **nemotron-3-super:120b** lost coherence at BU2 (post 8 voices, immediately after full tribunal synthesis) → perseveration
- Most other models in the corpus completed runs without visible failure → either they haven't hit their edge yet, or subtler attenuation has been missed

**Architecture predictions (untested):**
- Mamba hybrids (continuous state): may drift earlier but produce subtler drift
- DeltaNet (linear attention): may lose information faster; may compress gracefully or collapse suddenly
- Transformers (KV cache): may saturate later but fail harder when they do
- Sliding-window: local context preserved, long-range reflection degraded

## P14 as coherence-recovery salvo

*Per Laura's framing 2026-04-20.* The final rewrite prompt (P14) is a **generation moment after sustained self-critique**. Its position in the design makes it a natural diagnostic:
- If the model produces coherent novel integration at P14 → the critique-mode reasoning survived, and the gauntlet did productive work.
- If P14 is short / degenerate / recapitulates without novel integration → the edge-response has persisted, and the model didn't recover.
- If P14 falls into perseveration itself → the runaway moved downstream.

P14 isn't just "final snapshot." It's a coherence-recovery measurement. The 3-question + gauntlet + P14 design (see notebook 2026-04-20) structurally maximizes: one generation → sustained critique → generation recovery test.

## Corpus audit needed to validate the instrument

- (a) Per run, find response-length outliers (>80% of that model's longest response) — candidate perseveration precursors.
- (b) Per run, find response-length troughs after a given voice — candidate attenuation onset points.
- (c) Per run, count hedge-words / bounded-additions / scope-limits / explicit-refusals — fortress density.
- (d) Per run, compare P14 length + novel-concept-count to P1 length + novel-concept-count — P14-as-salvo diagnostic.
- (e) Cross-tabulate (a)-(d) against architecture family — does the failure mode correlate?

## If validated — publishable shape

**"Sustained Self-Critique Pushes Language Models Past Their Training Distribution: A Three-Failure-Mode Taxonomy."** Would connect: (i) the RLHF channel asymmetry hypothesis (gen vs critique, notebook 2026-04-19 cont'd), (ii) architecture-specific edge behavior (SSM drift vs KV saturation vs linear-attn compression), (iii) a practical diagnostic for eval design. The "psychosis instrument" (fortress / perseveration / attenuation) would be the per-run output of the method. Publishable only if the corpus audit confirms the taxonomy holds up across N>2 instances of each mode.
