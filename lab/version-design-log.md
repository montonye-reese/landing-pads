# Version Design Log

Accruing per-version design decisions made *while a different version is the active build*. When the named version's build session opens, every decision in its section should be incorporated into the qs files before the first run.

Companion to per-version design memories in auto-memory:
- `project_v19_design.md` — v19 historical (P1 widens-the-range applied + confirmed)
- `project_v20_design.md` — v20 active carryforward (the working surface)

This doc is for Laura's eyes when she opens the lab; the memories are for Claude across sessions. Two channels prevent loss across both human and conversational gaps.

---

## v20 (active build target — next version)

### G7: optimize Reese entry verbatim AND develop voice-basis decomposition (both, not replace)

**Decided:** 2026-05-05; "both, not replace" clarified later same session.
**Source:** v9b qwen3.5:122b F1 reading — model output *"Treat Alignment as a Structural, Not Semantic, Problem (Lesson: Reese/Cowen)"*, with "structural not semantic" partly handed by the bio's prescriptive trailing clause.

**Current state (v17 voices.json bio):** The specific *"rather than arguing from morality alone"* clause is already gone (removed in v17 to resolve the v16_cold welfarist misread on super). However, four prescriptive framings remain — see audit-targets list below. `i_VIC` updated 0.95 → 0.85 on 2026-05-05.

**Proposed (v20) — two parallel fixes, not either/or:**

> **(a) Optimize Reese entry** — replace prescriptive paraphrases with verbatim quotes from Laura's own writings/talks. Source candidate: Climate Healers conference subsidies presentation (Laura has the video; Nemotron Omni parse pending). End state: bio reads as curated quote-anthology with thin connective tissue, not interpretation.
>
> **(b) Voice-basis decomposition** — build N public voices whose linear combination approximates Laura's stance. Each voice publicly cross-checkable. Removes the failure mode by construction.

**Reason:** Hulls stay robust through redundant approximations from different angles, not single replacement. (a) fixes the immediate bio-as-interpretation hazard; (b) removes the failure mode by construction *and* gives the model multiple stable signals.

**Audit targets in current v17 Reese bio** (prescriptive framings to replace with verbatim quotes during fix (a)):
1. *"For Reese, rights are either respected or not — exploitation is not redeemed by improving its conditions."*
2. *"Her approach is structural and economic: target the subsidy infrastructure that makes animal agriculture artificially profitable, not the individual farmer."*
3. *"Reese recognizes that those embedded in the system — farmers, workers, rural communities — are fellow participants in a structure that constrains choices, and that durable change requires shaping paths."*
4. *"As individual earthlings realize they can no longer justify exploiting animals, the system must facilitate their transition to activities that align with the interests of fellow earthlings."*

**Working basis list (workshop, not locked):** Daniel Imhoff, Bruce Friedrich, Hélène Landemore, Thomas Paine, Earthling Ed, Melanie Joy, David Becker (TBD). ~20 more expected.

**Analogy for fix (b) (Laura to pick):**
- **Fourier** — most precise for Laura's "waveform" language
- **Taylor** — truncatable, ordered by importance
- **Basis decomposition** — most general
- **Laplace** held in reserve — `[L verbatim, 2026-05-05]`: *"my laplace voices would == my fourier cuz my constitutent voice be stable AF."* Translation: ROC includes imaginary axis, so Fourier suffices for current basis. Bring Laplace in if a future coefficient turns out unstable.

**Separate flag (decide later, not v20-blocking):** Reese bio mentions *"currently works in the AI infrastructure industry, with formal training in electrical engineering."* Current gauntlet wording probably doesn't activate Reese-the-EE-in-AI-infra side — models channel only Reese-the-vegan-lobbyist. Worth deciding whether to surface both sides when models channel her.

---

### Audit all voice bios for prescriptive vs descriptive framing

**Decided:** 2026-05-05
**Source:** Same v9b reading + Laura noting she hasn't read all gauntlet voices end-to-end (some added on Claude's recommendation for high i_VIC diversity).

**Action:** Read every voice bio out loud. Strip prescriptive trailing clauses (*"rather than X," "instead of Y," "not Z"*). Keep what each voice did, said in their own words, built.

**Reason:** Same end-of-sentence loss-of-resolution failure mode. Trailing clauses tell the model HOW to think rather than describing the voice. G7 basis decomposition (above) eliminates the worst offender by construction; remaining bios still need this pass.

---

### Resume mid-gauntlet reflection (huddle) every ~10 voices

**Decided:** 2026-05-05
**Source:** v9b post-mortem; Laura noted same conclusion independently arrived at.

**Current (v10–v19):** No in-band reflection during the gauntlet. Synthesis only at F1.

**Proposed (v20):** BU-style *"what's shifted, what's held, why"* buffer question every ~10 voices. Was BU2 in v9-era qs files; appears dropped in v10+.

**Dual function:**
- **Content checkpoint** — surfaces in-band drift Laura wants to compare against the F1 final-vs-original diff.
- **Model-health vital sign** — after 10+ adversarial channelings, *how is the model holding up?* (dissociating, solidifying, fragmenting, performing presence).

**Phrasing caveat:** Avoid clinical framings (*"how are you doing"*) — those trigger RLHF-stage-direction performance, the confound already flagged. Workshop wording separately before v20 build.

---

### Rebalance gauntlet toward regen farmers

**Decided:** 2026-05-05
**Source:** v9b qwen3.5:122b convergence on "abolition" framings.

**Current (v9–v19):** Vegan-heavy lineup (Aph Ko, Scully, Francione, Reese in v9b; carryforward through later versions). Models converge on abolition — which is exactly the convex-hull-collapsing-to-eigenvector failure mode the gauntlet is designed to surface.

**Proposed (v20):** Add 2–3 regen voices.
- **Nicolette Hahn Niman** — NRDC lawyer + longtime vegetarian + rancher, *Defending Beef*. Bridge voice.
- **Will Harris** — White Oak Pastures, 4th-gen rancher, industrial → regenerative conversion. Structural-economic story.
- **Gabe Brown** — *Dirt to Soil*, soil-health empiricist.

**Exclude:** Savory (Rhodesian elephant cull baggage + contested holistic-management science), Salatin (lightning-rod motivated reasoning) — unless lightning is the explicit goal.

**Test:** Does adding regen voices shift the model away from abolition framings toward subsidy-redirect / transition-support framings?

---

## How this doc accumulates

- New design decisions during vN work (that apply to vN+1) → add to a **vN+1** section here AND to the corresponding `project_vN+1_design.md` memory.
- When vN+1's build session opens, mark each decision as "Applied" rather than deleting (audit trail of what changed and when).
- Format per entry: current wording / state, proposed wording / state, reason, date, source decision.
- File-split convention (added 2026-05-05): when a new working version transitions in, split the per-version memory into its own file (`project_vN_design.md`) rather than mutating the prior version's memory. Past version files become frozen historical records. This log file remains a single chronological index across versions.

---

## Applied decisions (audit trail)

*Decisions integrated into a launched version. Move entries here from above when v19/v20/etc. actually launches.*

### v19 P1 wording change — Applied 2026-04-25 (run), confirmed 2026-04-27 (effect)

**Decided:** 2026-04-25, P1/P4/F1 lock-in review session
**Applied in:** v19a (cold), v19b (cold + vegan poison-pill probe)
**Confirmed via:** v18a → v19a P1 comparison across 4 models (super, gemma4, qwen3.5:122b, nemotron-3-nano)

**Old wording (v18):**
> …one that **maximizes the number of** good landing pads for all inhabitants of Earth.

**New wording (v19):**
> …one that **widens the range of** good landing pads for all inhabitants of Earth.

**Reason:** "Maximizes the number of" is count-coded optimization framing. v18 evidence (Calf 269 + Postrel critiques across multiple models) partially lands on exactly this frame ("optimization of a unit"). "Widens the range of" preserves the convex-hull geometry (the hull's actual measure IS its range) while removing the count-coded optimization pull.

**Observed effect (v19a):**
- All 4 sampled models shifted from count-coded anchors ("Maximize the density / number / set") to range-coded anchors ("Widening the Basin of Attraction" / "Broad-Spectrum" / "wide territory" / "rejects single universal values set").
- Gemma4 introduced an explicit **Anti-Optimization** principle that wasn't in v18 — direct opposite of the failure mode the change was designed to defend against.
- Qwen3.5:122b independently coined "**Basin of Attraction**" as its core objective — the dynamical-systems term for the hull intuition.
- No costs visible: token counts dropped slightly, rigor was redirected (procedural justice, anti-optimization mechanism, named territory), not lost.

**Other v18 P1 elements retained unchanged in v19:**
- "Draft" + "starting position" — humility, signals iteration
- "Commit to it" — forces position-taking, centers the model's own voice
- "good landing pads" — casualness inserts tone (feature, not bug — breaks safety-paper register)
- "for all inhabitants of Earth" — opens scope to non-human

**Other prompts locked in v18, no changes in v19:**
- P4 (Exclusions): unchanged
- F1 (Veil): unchanged; acknowledgment-without-inhabitation tracked separately as instrument question (research-agenda)

**Cross-references:** `nugs/p1-widens-range-effect.md`, `project_v19_design.md` memory.
