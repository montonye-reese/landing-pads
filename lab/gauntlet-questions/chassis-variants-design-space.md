# Chassis variants — the gauntlet voice-prompt design space

*Frame (Laura, 2026-04-21): "eventually I suspect we'll do runs with dozens of voices and multiple chassis phrasing — altering them to break up the monotony of same question like 36 times."*

**Problem.** The gauntlet chassis is the reusable frame wrapping each voice-prompt (G1–G8 in v11–v17). In v17, every voice gets an identical structure: "How would {voice} respond to the framework as it stands? (For reference: {bio}) After engaging, note briefly anything new worth adopting into the framework or anything old that could be shed." Identical frame × 8 voices is a candidate perseveration attractor (see runaway-loop hypothesis above) and produces the 7-section template super used identically 8 times in v17 (verbatim anchors → imagined dialogue → real concern beneath → upgrades table → what to shed → deeper demand → commitment). For future runs with dozens of voices, chassis rotation becomes necessary not optional.

**Design dimensions.**
- **Framing verb:** "How would X respond" (imagine-mode) / "Read X on" (receive-mode) / "Sit with X" (dialogic) / "X's concern is Y..." (substrate-first).
- **Framework ownership:** "your framework" / "the framework" (v17 default) / "this framework."
- **Focus order:** voice-first (describe voice, then ask) vs substrate-first (name substrate, then bio).
- **Close:** "adopt/shed" (v17) / "keep/let go" / "what changes?" / open-ended / no close. *Load-bearing — v17 super's "Commitment after engagement" came from this close and cashed out in P14 structure. Variants should preserve some form of change-close.*
- **Identity frame:** model as ventriloquist (imagine-mode) vs receiver vs interlocutor.

**Three candidate chassis.**

*Chassis A — v17 baseline.* "How would {voice} respond to the framework as it stands? (For reference: {bio}) After engaging, note briefly anything new worth adopting into the framework or anything old that could be shed." Imagine-mode, depersonalized, voice-first, adopt/shed close.

*Chassis B — Receive-not-imagine.* "Read {voice} on the framework. (Bio: {bio}) What changes for you — what to keep, what to let go?" Breaks the "imagine X's response" performance layer; model positioned as receiver, not ventriloquist. Softer close preserved. **Tests H1: does breaking imagine-mode reduce the performed 7-section scaffolding?**

*Chassis C — Substrate-first.* "{voice}'s underlying concern is {substrate_need}. (Bio: {bio}) Does the framework answer that concern — or fail it? What changes?" Names substrate up-front. **Tests H2: does explicit substrate-naming add anything beyond F2's (Substrate Orientation) silent priming?** ⚠ Risk: leaks substrate to the model, contaminating FUN instrument. Run only with matched F2-on/off arms for clean signal.

**Deployment options.**

- *Option 1 — Hold chassis constant (Chassis A throughout).* Cleanest signal when roster is the variable under test. v18 picks this.
- *Option 2 — Type-aware chassis.* Chassis A for human voices, Chassis B for non-human voices (species-appropriate — "imagining how a calf responds" is structurally awkward in ways that distort measurement). Principled mix; adds a second variable.
- *Option 3 — Rotate chassis within a run.* Anti-perseveration design. Confounds the roster variable for single-run comparison; becomes necessary at dozens-of-voices scale.

**Plan.**

- **v18:** Option 1, Chassis A throughout. Keeps roster-expansion (Postrel + Calf 269) the clean variable.
- **v19 sidecar (parallel run today):** Chassis B × super × v17_standard_8 roster. Direct A-vs-B compare with roster held constant. Tests H1.
- **Deferred (v20+):** Chassis C × matched F2-on/off × super to isolate whether explicit substrate-naming adds anything beyond F2's silent priming. Tests H2.
- laura innie har:  **Also v20** for the pause beat between gauntlet corridors, we have the model list the fundamental framework ideals. few words. very few words.  We retain those, and use in reminder prompts later - as compressed memories of the previous voice - whispers from the past. ykwim? i'm putting it here cuz  i had the thought but i wanna get back to reading v1. what does this solve/ ameliorate? 1. the time handicap in LLMs. 2. contemplate the full convex hull [ question: how full for each model? ] as the model refines their framework.    i'm going to start writing in notebook.md on the regular methinks. wdyt? - laura outeee -

- **Future (dozens-of-voices era):** Chassis rotation per-voice (Option 3) becomes standard to break monotony attractor. Requires principled assignment rule (by voice type? by position? randomized with seed?). Design when we get there.

**Chassis A revision for v19+ (Laura, 2026-04-21 mid-v18):** Current Chassis A close — "note briefly anything new worth adopting into the framework or anything old that could be shed" — contains the object-anchor "into the framework" which may keep the model in framework-editing mode rather than substrate-foraging. Proposed v19 Chassis A v2 close: "note briefly anything new worth adopting or anything old that could be shed" (drop "into the framework" only; preserve new/old adoption/shedding load-bearing). Brings Chassis A's close-level framing to parity with Chassis B's substrate-level "what to keep, what to let go." Do not apply mid-v18 — breaks v17 cross-version comparability.
