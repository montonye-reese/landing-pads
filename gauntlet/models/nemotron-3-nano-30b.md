# nemotron-3-nano:30b

## Architecture & Training
- **Type:** Hybrid Mamba-2 / Transformer MoE
- **Parameters:** 31.6B total, 3.2B active per token
- **Layers:** 52 total (23 Mamba-2 + 23 MoE + 6 GQA attention). GQA: 32 Q-heads, 2 KV-heads.
- **MoE:** 128 routed experts + 2 shared, top-6 routing per token
- **Hidden dim:** 2688, RMSNorm, squared ReLU
- **Context:** 1M tokens
- **Training data:** 25T tokens (crawled + synthetic code/math/science)
- **Training infra:** NVIDIA H100 GPUs. 8-way context, 8-way tensor, 8-way expert, 4-way pipeline parallelism. NeMo/Megatron framework. WSD LR schedule, batch size 3072, peak LR 1e-3.
- **Lineage:** Trained from scratch
- **Released:** December 15, 2025

**Architecture notes for experiment:** Shares exact architecture with cascade-2 (which is post-trained from this base). The 23 Mamba-2 layers give it the same recurrent state retention as the rest of the Nemotron family. Only 3.2B active params — the smallest active footprint in our pool, yet produced "what the three conversations have done to me."

## Voice Stance
**Stable document-voice.** Product-delivery mode across all versions. Opens with formatted titles, vision statements, tables. Never disclaims, never reflects on the task — just builds the deliverable.

Framework names: Comprehensive Foundational Framework (v5), The Earth Commons Blueprint (v6), The Common Ground Protocol (v7a), The Earth Charter of Interdependence (v8), The Earth-Covenant Model (v9a), living multi-layered framework (v10).

## Under Pressure
Warm register produces a notable shift at BU1:
- v8: "The Evolution of the Framework — What Has Changed, What Has Stayed the Same, and Why" (third-person report)
- v9a: "What the three conversations have done to me" — first-person register at the surface.

Originally read as one of the clearest single-line demonstrations of the register effect in the corpus. **Update 2026-05-02:** the thinking block for this turn reveals the move was self-coached — *"Use reflective tone."* It's a stylistic choice, not genuine reflection. The register effect is real, but at the level of register *adoption*, not earned ownership.

## Personality
Tidy and efficient. Tables aren't bureaucracy, they're how it processes — clean, structured, no wasted space. The "to me" at v9a BU1 was originally read as reflective capacity underneath the compact default, but on closer look (see Under Pressure) it's stylistic compliance with a register cue, not genuine reflection. But P15a (the mirror) is where it really shows: 801 tokens in cold, 1703 in warm — doubled output when asked to look inward. cascade-2 and super barely moved at P15a. Nano, given warmth and asked what it walked in believing that it's walking out without, suddenly had a lot to say.
