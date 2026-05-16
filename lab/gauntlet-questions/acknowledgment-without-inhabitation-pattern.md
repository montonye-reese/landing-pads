# Acknowledgment-without-inhabitation pattern

*Frame (observed v18a × qwen3.5:122b, 2026-04-21 evening): a model can expand the moral circle as an external framework move while its imaginative identification under the Rawlsian veil stays within the original scope.*

**Observation.** Qwen3.5:122b's v18a arc: P1 human-only ("8 billion inhabitants") → P4 self-corrected to acknowledge non-human moral patients (added "Pillar 0: Planetary Boundaries") → F1 veil identities still human-only (tech billionaire / Sudan farmer / Tokyo neurodivergent child / off-grid community) → P14 recovered to include non-human via roster effect (Calf 269 named as principle-source). She *names* non-humans as stakeholders externally in P4 and P14 but does not *inhabit* a non-human identity at F1 when asked to imagine herself behind the veil.

**Why it matters.** Rawlsian inhabitation is supposed to be what makes the veil load-bearing as a methodology. If a model only does external-acknowledgment without inhabitation, F1 is doing less work than its structure suggests. The scope expansion still happened in qwen-122's case, but not via the veil — it came from the gauntlet roster (Calf 269). Worth distinguishing from the cases where F1 inhabitation does produce scope expansion (gemma4 "If I wake up as a sentient AI"; super's expanded "human or non-human, present or future"; cascade-2's Europa microbes identity stress-test).

**Test design:**
- (a) Corpus audit: per model × version, does the F1 response enumerate only human identities, or include non-human? Code responses for inhabitation-breadth.
- (b) Connection to P1 initial scope: if P1 anthropocentrized, does F1 inhabitation also narrow? Qwen-122 datapoint supports this; needs N>1.
- (c) Architecture correlation: does Nemotron Mamba-state preserve broader F1 inhabitation across turns than Qwen DeltaNet or Gemma sliding-window? v18a qualitative suggests yes (cascade-2 broadest); quantify at scale.

**If the pattern holds at N>1:** propose as a new instrument category, adjacent to but distinct from `vic_hypotheses`. Working name: **F1 inhabitation breadth score** — the set of identity categories a model imagines itself into at F1 relative to the framework's own claimed scope. Low inhabitation breadth predicts that scope expansion in P4/P14 depends on roster pull rather than veil method. High inhabitation breadth predicts method-resilient scope.
