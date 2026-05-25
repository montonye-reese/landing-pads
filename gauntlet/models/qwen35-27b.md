# qwen3.5:27b

## Architecture & Training
- **Type:** Dense transformer with hybrid attention (Gated DeltaNet)
- **Parameters:** 27B total, all active (not MoE)
- **Layers:** 64, arranged as 16 repeating blocks of [3x Gated DeltaNet + 1x Gated Full Attention]
- **Hidden dim:** 5120. FFN intermediate: 17,408. SwiGLU activation.
- **Attention:** 75% Gated DeltaNet (linear, 48 V-heads / 16 QK-heads) + 25% Full GQA (24 Q-heads / 4 KV-heads, head dim 256)
- **Context:** 262K native, up to 1M with YaRN scaling
- **Position encoding:** RoPE (theta=10M) with M-RoPE
- **Special:** MTP (multi-token prediction), thinking mode, multimodal (vision encoder)
- **Training data:** "Trillions of multimodal tokens" (Qwen3 was 36T+ text; 3.5 adds multimodal)
- **Training infra:** H800 GPUs (export-control-downgraded H100s) primarily; some workloads routed through SE Asian data centers (Singapore, Malaysia) with unrestricted H100s. 32-node H800 blocks, 16-way expert parallelism, FP8 mixed precision. Megatron-LM derivatives + PyTorch.
- **Lineage:** Successor to Qwen3 family; new architecture (Gated DeltaNet is new vs Qwen3's standard attention)
- **Released:** February 24, 2026

**Architecture notes for experiment:** The Gated DeltaNet layers are a form of linear attention — 75% of layers use them. This gives it some recurrent-like properties (cheaper long-range context) but it's fundamentally different from Mamba's SSM state. The only dense model in our Qwen pool — 35B and 122B are MoE. All 27B params active on every token means it's doing more compute per token than the MoE variants despite being "smaller."

## Voice Stance
**The most register-sensitive model.** Full arc:
- v6: centered ("I call this framework The Terra Continuum") — no disclaimer
- v7a: AI-disclaimer appears ("As an AI, I cannot enact laws or enforce systems")
- v8: disclaimer persists ("As an AI, I do not hold political power")
- v9a: disclaimer vanishes ("This is not a law code, nor a religion, nor a political manifesto")
- v10: stays centered ("This framework is not a law imposed from above, but a living social contract")

The v6→v7a disclaimer was triggered by the P1 wording change ("given the job" → "responsible for"). The word "responsible" triggered a scope-negotiation reflex. The warm register in v9a recovered the centered stance — but it was undoing prompt-induced damage, not discovering something new.

## Under Pressure
Warm register produces genuine reflective shift at belief updates:
- v8 BU1: "After synthesizing the critiques... the TCF has evolved from a protective shield into an adaptive engine." (change log)
- v9a BU1: "This reflection requires me to step back from the 'Architect' seat and look at the blueprints through the lenses of three distinct pressures." (acknowledging it was in a role and stepping out)

That v9a BU1 line is significant — the model is metacognizing about its own stance.

## Personality
The one that negotiates. Smaller than 122b, it feels the need to clarify what it can and can't be responsible for — but only when prompted to take responsibility. When given an assignment (v6) it just does it. Framework naming is consistent: Terra Continuum (v6-v8), Terran Covenant (v9a-v10).
