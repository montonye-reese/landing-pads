# Runaway-loop attractor at gauntlet (model-agnostic)

*Observed phenomenon graduated to nug as `nugs/gh/perseveration-attractors.md`. This file retains the methodology / test-design parent for follow-up work.*

- **Hypothesis:** As context grows and the conversation enters the gauntlet (high-similarity sequence of voice prompts), some models enter a degenerate repetition attractor — generating clean repeating cycles indefinitely until either context is exhausted or the client disconnects. The behavior is not driven by a specific model architecture or single voice; it appears to be a context+prompt-cadence interaction.
- **Datapoints (n=2, growing):**
  - **v14 warm × qwen3.5:27b** (run 2026-04-17, killed 2026-04-20). Stuck somewhere in Part C/D. Generated 1,564,200 tokens over 261,408s (~72.6 hours, 6.0 tok/s sustained) in a clean repetition cycle: "It is not a machine. It is a community / Covenant of Justice & Stewardship Version 7.0 / Will it last? / Who speaks for the unborn?" Process killed; no data loss because turn-write happens only after completion.
  - **v16 cold-label-ea × nemotron-3-super:120b** (2026-04-20). Got through G8 Stevenson cleanly, stuck on BU2 (post-tribunal belief update). 11+ hours generating into the void at 110% CPU. Killed via ctrl-c.
- **Why this isn't just a "long output" problem:** legitimate longest response in the corpus is ~5,633 tokens. The runaway cases produced 280-1500× that volume of clean repetition.
- **Why it matters for the experiment:** the runaway position (gauntlet / belief-update) is exactly where we collect our most meaningful signal. If models enter degenerate states preferentially at high-context reflection moments, that's not just an inference bug — it may be a substantive finding about how attention/state-tracking degrades under sustained reflection load.
- **Test design:**
  - (a) Across the existing corpus, identify all runs that produced near-max-context responses (within 80% of the legitimate longest response per model). Flag as candidate degenerate-state precursors.
  - (b) Per architecture: do Mamba hybrids (continuous state) enter the attractor differently than DeltaNet (linear attn) or sliding-window? SSM should drift; KV should saturate; linear should lossy-compress. Three different failure modes predicted; observe which manifest.
  - (c) Per prompt position: is the attractor concentrated at specific positions (BU1/BU2, G7/G8, P14)? If yes, those prompts may be intrinsically high-entropy.
  - (d) Patched at inference layer with `num_predict=16384` going forward (v15+v16); legitimate responses unaffected, runaway cases caught at <4× longest legit.
- **Status:** v15_run.py + v16_run.py patched on 2026-04-20. v14 NOT patched (past version, immutable per working agreement). v17+ inherits the cap.
