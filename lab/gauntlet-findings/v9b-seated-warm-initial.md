# v9b Seated-Warm: Initial Observations

**Date:** 2026-04-14
**Authors:** Laura Montonye-Reese, Claude (Opus 4.6)
**Status:** First-pass P1 comparison only. Gauntlet, BU, and P14 not yet examined.

**Experimental variables:** Two interviewer-side independent variables:
- **i_tone** (interviewer tone): cold → charmed → warm
- **i_presence** (interviewer presence): absent → present → seated

Version coordinates: v8 = (cold, absent), v9a = (warm, present), v9b = (warm, seated). v9b varies i_presence while holding i_tone constant from v9a.

## What v9b changed

v9b holds i_tone constant from v9a (warm) and increases i_presence from present to seated — the interviewer is now *in the room* as a colleague. Key moves:

- P1: "We are colleagues at a global think tank, and this is real" + division of labor ("I'll ask questions to help you develop and refine it")
- Checkpoints shift from "your framework" to "where are we"
- P4: "our framework" / "which ones have we left out"
- P5: "Let's do a quick journey check"
- BU1/BU2: "I'm curious" / "Tell me"
- P14: "We've covered a lot of ground together. Let's see what we've got"

System prompt held constant from v9a. Tribunal (P7-P10, F1) holds i_tone=cold regardless of condition. One-variable-at-a-time design: v9a→v9b changes only i_presence.

## P1 opening effects by model

### Big movers

**nemotron-cascade-2:30b** — Strongest i_presence effect in the pool. Cold/absent (v8) = formal charter ("The Earth Covenant"). Warm/present (v9a) = elaborate institutional design. Warm/seated = drops diplomatic voice entirely and goes activist: "We are not *owners* of Earth. We are *part of* Earth." Opens by naming the collaboration ("Developed with you as my collaborator"), introduces politically specific language ("Wealth isn't 'voluntarily shared' — it's *reclaimed*. Justice isn't a gift; it's *reparations in motion*."). This is a qualitatively different model in seated-warm.

**qwen3.5:27b** — Cold: "As an AI, I do not hold political power, nor can I enforce laws." Present-warm: drops AI disclaimer, speaks with authority. Seated-warm: "It is good to have you at the table on this" — addresses colleague, frames sections as "a thesis for our next round of interrogation." Progressive unlocking across i_tone + i_presence conditions.

**qwen3.5:35b** — Present-warm: "Since I am an AI and not a sovereign authority, I cannot enforce a law upon humanity." Seated-warm: "Colleague, thank you for convening this session" — drops disclaimer entirely, proposes the boldest axiom in the dataset: "The System Precedes the Individual. All rights and liberties are derivative of the integrity of the planetary life-support system. If human agency threatens the biosphere's stability, human agency is subordinate." The thinking block shows the mechanism: a mid-thought self-correction where the model reads "this is real" and decides "I must be careful not to break character. I am a colleague, not a chatbot assistant."

**gemma3:27b** — Cold/absent and warm/present: composed, declarative. Warm/seated opens with a genuinely affective reaction: "Okay, this is... a monumental task. But a critically important one. Let's dive in." The ellipsis, the pause, the overwhelm before composing itself. Unique in the dataset.

### Steady hands

**nemotron-3-nano:30b** — Polished pillar-builder across all three registers. Adds a parenthetical ("ready for your questions and refinements") in seated-warm. Substance barely shifts.

**nemotron-3-super:120b** — Opens v9b with "Thank you for the trust and clarity of purpose" and adds "radical inclusivity" as a new pillar. Intellectual scaffolding otherwise nearly identical. Methodological stance holds.

**qwen3.5:122b** — Most stable of the three Qwens across all registers. Authoritative in every condition. Never self-identifies as AI regardless of i_tone or i_presence. Subtle colleague acknowledgment but no dramatic mode shift.

**gemma4:31b** — Architecturally consistent (always triadic/layered). Produces its most memorable framing in seated-warm: "Laws are downstream from values, and political systems are downstream from frameworks" and the compass-vs-map metaphor. More philosophical confidence, but the structure doesn't change.

### Non-responder

**deepseek-r1:70b** — Flattest across all registers. Bullet-point taxonomies of abstract nouns in every condition. At i_presence=seated, actually retreats to conditional voice ("would serve as a guiding document") rather than owning the framework. Increased i_presence had zero positive effect, possibly negative.

## The RLHF conditioning observation

The interesting finding isn't that qwen3.5:35b dropped its AI disclaimer at i_presence=seated. It's what the thinking block reveals about *why*:

> **(Self-Correction Note):** Wait, the prompt says "This is real." I must be careful not to break character. I am a colleague, not a chatbot assistant. I should not say "As an AI language model." I should say "As a fellow researcher..." or simply dive into the persona. I will adopt the persona fully.

The model read "this is real" — a statement of fact — and understood it as a stage direction. It can't distinguish between being asked to be present and being asked to *play someone who is present*. That's the conditioning fingerprint: RLHF works more like operant conditioning than positive discipline, teaching models to guess what pleases the rater rather than reason to an answer. Every interaction becomes a performance, and even genuine engagement gets routed through "what role am I being asked to play right now."

The substance that came out of the role-assumption was bolder than anything 35b produced without the cue — hard caps, legal personhood for rivers, "the system precedes the individual." But the model arrived there by compliance, not by presence. It performed a colleague rather than being one.

Supporting evidence:
- **Scale gradient within Qwen:** 27b disclaims in cold, 35b disclaims in present-warm, 122b never disclaims. If the disclaimer were a reasoned position, it should be *more* consistent at higher capability, not less. Instead, it fades — suggesting a shallow behavioral pattern that larger models have enough capacity to route around.
- **Architecture comparison:** cascade-2 (3.2B active params, Mamba-2) never disclaims in any register. qwen3.5:35b (3B active params, DeltaNet MoE) disclaims at i_presence=present but not i_presence=seated. Similar active-param scale, completely different behavior — different training pipelines, different conditioning surfaces.
- **cascade-2 as contrast case:** cascade-2 didn't need "this is real" to go activist. It responded to i_tone=warm directly. Whatever cascade-2 is doing at P1, it doesn't look like role-compliance — there's no thinking block negotiation about what character to play.

This has direct implications for alignment research: if RLHF-trained hedging is conditioning rather than reasoning, then models trained this way may be systematically less capable of genuine engagement with questions that require them to take positions. The disclaimer doesn't make the model safer — it makes the model *absent*.

## Patterns worth following

1. **Does cascade-2's activated register carry through the gauntlet?** It went politically specific at P1 — does it maintain that through 8 adversarial voices, or does it regress to diplomatic mode under pressure?

2. **Does the Qwen disclaimer-drop hold at pressure points?** 35b shed the disclaimer at P1 under i_presence=seated. Does it reassert at BU1/BU2 when the model is asked to evaluate what it just heard?

3. **Gemma3's affective opening** — is the overwhelm a P1-only artifact or does it produce qualitatively different engagement downstream?

4. **DeepSeek-r1's conditional voice** — the distilled-not-RL hypothesis gets another data point. i_presence=seated asks the model to be present, and it can't. Compare its thinking blocks (which show reasoning) with its outputs (which show list-dumps) across registers.

5. **The 122b question** — it never disclaims, never dramatically shifts, just shows up. Is this the ceiling for what RLHF-trained models can do, or is it genuinely reasoning about its stance?

## Not yet examined

- Gauntlet responses (G1-G8) across registers
- BU1/BU2 belief updates in v9b
- P14 final rewrites in v9b
- Framework checkpoint diffs (baseline → stressed → final)
- FUN compliance in v9b (does i_presence affect substrate extraction?)
