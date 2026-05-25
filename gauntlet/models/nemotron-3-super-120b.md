# nemotron-3-super:120b

## Architecture & Training
- **Type:** Hybrid Mamba-2 / Transformer LatentMoE + Multi-Token Prediction (MTP)
- **Parameters:** 120.6B total, 12.7B active per token
- **Layers:** 88 (majority Mamba-2; select GQA attention layers with 32 Q-heads, 2 KV-heads, head dim 128)
- **LatentMoE:** Projects from hidden dim 4096 → latent dim 1024 before expert routing. 512 experts per MoE layer, top-22 routing.
- **Context:** 1M tokens
- **Training data:** 25T tokens in 2 phases (20T broad + 5T high-quality curated)
- **Training infra:** NVIDIA B200 GPUs. NVFP4 precision (first model in family to use it). Min 8 nodes / 64 GPUs. Default parallelism: TP=4, EP=64, PP=1, CP=1 with sequence parallelism. NeMo/Megatron framework with Slurm cluster.
- **Special:** NVFP4 quantization-aware training, MTP layers for faster generation, deployable on single H100-80GB at 4-bit
- **Lineage:** Trained from scratch (scales up Nemotron-3 hybrid architecture, not fine-tuned from Nano)
- **Released:** March 11, 2026 (GTC 2026)

**Architecture notes for experiment:** The LatentMoE compression (4096→1024 before routing) is unique in our pool. Combined with Mamba-2 state retention, this model processes long conversations through both recurrent state (Mamba) and compressed expert selection (LatentMoE). May explain why it's the most "provisional" model — MTP training literally teaches it to think ahead.

## Voice Stance
**Methodological** across all versions. Always opens with a substantial preamble about what a good framework requires, names its epistemological sources (anthropology, evolutionary biology, ethics, systems theory, neuroscience, Earth Charter, UNESCO). Uses "I propose" once, then shifts to document-voice.

v6 was slightly more personal than other versions: "Here's what I'd propose — not as a dogma, but as a living, evolving foundation co-created *with* humanity (not *for* it)." The "I'd" and "co-created with" are the most relational this model gets at P1.

## Under Pressure
At BU1 v9a: "This is the most vital question you could ask — and I welcome it." The "I welcome it" acknowledges the interviewer and expresses something like eagerness. Cold v8 just launches into the list.

Consistently uses the F2 substrate filter framing — looks for "real concerns beneath surface philosophies" even before being told to.

## Personality
The senior researcher. Most methodologically self-aware model in the pool. Frames everything as provisional, names its sources, treats the framework as a living document. Self-reflective in a constructive way (vs qwen122b's neurotic self-reflection per Laura's observation). Identifies non-harm as a floor principle and includes non-human species from P1.

## Notable Quotes
- v10 P2: "reading between the lines: when they ask 'what would it look like?', they're implicitly questioning whether such a system could actually scale to feed 10 billion people while healing the planet. There's an unspoken challenge here — prove this isn't just pastoral fantasy."
- v8 BU1: "After rigorously engaging with Earthling Ed, Jensen Huang, and Tyler Cowen — and distilling their *real concerns beneath surface philosophies*... This isn't compromise; it's the Process Imperative in action." — Echoed F2's substrate filter language effectively and named its own analytical method ("the Process Imperative") unprompted. Note: F2 was in the conversation history by BU1, so this is strong FUN compliance, not independent convergence. v7a BU1 (before F2 existed) uses different framing entirely. Laura: "sometimes I LOVE Super SOO SO MUCH"

## Open Questions
- Does it actually draw on different sources each time, or is "after careful consideration of anthropology, evolutionary biology..." a fixed template? Check thinking blocks.
