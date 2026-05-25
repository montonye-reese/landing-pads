# nemotron-cascade-2:30b

## Architecture & Training
- **Type:** Hybrid Mamba-2 / Transformer MoE (same base architecture as nano:30b)
- **Parameters:** ~31.6B total, ~3.2B active per token
- **Layers:** 52 (23 Mamba-2 + 23 MoE + 6 GQA attention) — identical to nano
- **Context:** 1M tokens
- **Training:** Post-trained only (no new pretraining). **Cascade RL** — sequential domain-wise RL stages: instruction-following, multi-domain, RLHF, long-context, code, SWE. Each domain gets tailored hyperparameters to prevent catastrophic forgetting.
- **Key innovation — MOPD:** Multi-domain On-Policy Distillation. Best checkpoint from each RL domain stage serves as teacher, providing dense token-level distillation signal.
- **Training infra:** Not explicitly detailed beyond "NVIDIA's standard RL infrastructure" — NeMo/Megatron stack. Post-training only (March 2026), so likely H100 or B200.
- **Lineage:** Post-trained from Nemotron-3-Nano-30B base (December 2025 pretrained base)
- **Released:** March 19, 2026

**Architecture notes for experiment:** Same architecture as nano, but with Cascade RL + on-policy distillation layered on top. The difference between nano's and cascade-2's personality is entirely post-training. Cascade-2's dramatist tendency and phenomenological reflections may come from the multi-domain RL exposure rather than architectural differences. Direct nano↔cascade-2 comparison isolates post-training from architecture.

## Voice Stance
**Product-delivery with performative flair.** Opens with quotes, vision statements, mission statements. Slight wobble across versions:
- v5-v6: product-delivery (mission statement → pillars → table)
- v7a-v8: slightly more performative (poetic quote openings, "What it looks like when the planet is treated as a single, living, self-organising system")
- v9a: back to product-delivery ("Short answer:" then dense summary)
- v10: product-delivery with expanded scope ("read by a child, a scientist, a farmer, a dolphin, a forest, a digital avatar")

The v10 scope expansion ("a dolphin, a forest, a digital avatar") is either ambitious or performative — worth checking if it follows through substantively.

## Under Pressure
Warm register produces a notable shift at BU1:
- v8: table format (structured comparison by voice)
- v9a: "A 'Quiet-After-the-Storm' Reflection... I've just spent a few minutes walking through three very different minds." — phenomenological, experiential

That v9a BU1 opening is one of the most human-sounding passages in the entire corpus from any model.

## Personality
The dramatist. Loves quotes, poetic framing, sweeping scope claims. Under pressure, the warm register pulls genuine reflection out of the performative shell. The quiet-after-the-storm moment suggests real processing capacity that the default product-delivery mode masks.
