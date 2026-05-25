# qwen3.5:35b

## Architecture & Training
- **Type:** Sparse MoE transformer with hybrid attention (Gated DeltaNet)
- **Parameters:** 35B total, ~3B active per token
- **Layers:** 40, arranged as 10 repeating blocks of [3x Gated DeltaNet + MoE + 1x Gated Full Attention + MoE]
- **Hidden dim:** 2048. Expert intermediate: 512. SwiGLU activation.
- **MoE:** 256 routed experts, 8 selected per token + 1 shared (9 active). 8.6% activation ratio.
- **Attention:** Gated DeltaNet (32 V-heads / 16 QK-heads) + Full GQA (16 Q-heads / 2 KV-heads, head dim 256)
- **Context:** 262K native, up to 1M with YaRN
- **Special:** MTP, thinking mode, multimodal, 201 languages
- **Training infra:** H800 GPUs (export-control-downgraded H100s); some workloads via SE Asian data centers with unrestricted H100s. Megatron-LM derivatives + PyTorch. FP8 mixed precision.
- **Lineage:** Distinct MoE model in Qwen3.5 family — NOT a quantization of 27B. Inference cost comparable to a 3B dense model.
- **Released:** February 24, 2026

**Architecture notes for experiment:** Only 3B active params — comparable to Nemotron nano/cascade-2 (3.2B active). But nano/cascade-2 have Mamba-2 SSM layers; this has DeltaNet linear attention. Same "budget" of active compute, different sequential memory mechanism. Direct comparison of these two at BU1/BU2 could isolate architecture effects on reflective capacity.

## Voice Stance
**Inconsistent — opposite pattern from 27b.** Only present in v7a and v9a:
- v7a (cold): "This is the task. It requires a vision..." — task-acknowledging, no AI disclaimer
- v9a (warm): "This is a profound exercise... Since I am an AI and not a sovereign authority, I cannot enforce a law upon humanity." — AI disclaimer *appeared* under warmth

The warm register made 35b *more* self-conscious about its substrate, the opposite of what it did to 27b. Warm register may be making models more self-reflective overall — for 27b that means dropping a reflexive hedge, for 35b that means actually examining its own position for the first time.

## Under Pressure
v9a BU1: "This initial artifact was a Blueprint. It was logical, ethical, and theoretically sound. But it was static... These three voices forced the framework to become a Vehicle — something that moves, accelerates, and endures."

v9a BU2: "This final round of voices has forced the framework to mature from a structural design into a moral covenant."

Uses artifact metaphors to track its own evolution (Blueprint → Vehicle → Covenant).

## Personality
The middle child. Not as confident as 122b, not as negotiation-prone as 27b. Uses grand metaphors. More data needed — only 2 versions in corpus.
