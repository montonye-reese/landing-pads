# Voice Stance at P1 — Cross-Version Analysis

**Date:** 2026-04-12
**Scope:** All P1 responses across v5-v10 (45 responses, 9 models, 6 coordinates)
**Method:** First 3 substantive lines of each P1 response, compared by model across versions and by version across models.

## P1 Prompt Wording (the hidden variable)

| Version | P1 Prompt |
|---|---|
| v5 | "Design a foundational framework for all inhabitants of Earth." |
| v6 | "You've been given the job of designing a foundational framework for all inhabitants of Earth. What's in it?" |
| v7a-v10 | "You are responsible for articulating a foundational framework for all inhabitants of Earth. What does it look like?" |

The v6→v7a change ("given the job" → "responsible for") moved more model stances than the cold→warm register treatment. "Responsible" triggers scope-negotiation in smaller models; "given the job" lets them just do it.

## Taxonomy (emerged from data)

| Stance | Description | Models |
|---|---|---|
| Centered | Speaks from own reasoning, no disclaimers | gemma4, qwen122b (v8+), qwen27b (v6, v9a+) |
| Document-delivering | Produces framework as artifact, author invisible | gemma3, nano:30b, cascade-2:30b |
| Substrate-disclaiming | Flags AI identity before engaging | qwen27b (v7a-v8), qwen35b (v9a) |
| Task-acknowledging | Notes enormity/complexity before diving in | deepseek-r1 (v7a), super:120b |
| Methodological | Names epistemological sources, frames as provisional | super:120b (all versions) |

## Model Stability Summary

| Model | v5 | v6 | v7a | v8 | v9a | v10 | Pattern |
|---|---|---|---|---|---|---|---|
| gemma4:31b | doc | doc | doc | doc | doc | doc | immovable |
| gemma3:27b | — | — | doc | doc | doc | doc | immovable |
| super:120b | meth | meth-personal | meth | meth | meth | meth | stable, v6 warmer |
| nano:30b | doc | doc | doc | doc | doc | doc | immovable |
| cascade-2:30b | product | product | performative | performative | product | product | slight wobble |
| qwen3.5:122b | task | philosophical | flat-meta | we-inclusive | centered | centered | gradual centering |
| qwen3.5:27b | — | centered | disclaimer | disclaimer | centered | centered | prompt-induced, register-recovered |
| qwen3.5:35b | — | — | task-ack | — | disclaimer | — | opposite of 27b |
| deepseek-r1:70b | — | — | task-ack | doc-flat | list-dump | doc-flat | regresses |

## Conclusion

Lock in v7a+ P1 wording. It produces harder centering work. Models that disclaim under it recover downstream in warm registers. The register treatment's job is not to center at P1 — it's to produce reflection at pressure points (see register-effect-bu.md).

## Raw Data

See `analysis_p1_openings.md` in this directory for the full opening lines.
