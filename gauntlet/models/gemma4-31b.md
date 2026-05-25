# gemma4:31b

## Architecture & Training
- **Type:** Dense transformer with hybrid sliding-window + global attention
- **Parameters:** 30.7B total, all active
- **Layers:** 60 (50 sliding-window + 10 full global attention, 5:1 ratio)
- **Hidden dim:** 5376. FFN intermediate: 21,504. SwiGLU activation.
- **Attention:** GQA (32 Q-heads / 16 KV-heads). Head dim 256 (local) / 512 (global). Sliding window: 1024 tokens. Proportional RoPE (p-RoPE).
- **Context:** 256K tokens
- **Training data:** Large-scale multimodal, 140+ languages, cutoff Jan 2025
- **Training infra:** Not confirmed in any public document. Most likely TPU v5p or Trillium (v6e) based on timeline. Ironwood (v7) possible for post-training but unlikely for pretraining. JAX + ML Pathways. (Note: Trillium=v6, Ironwood=v7 — Google TPU naming is confusing.)
- **Special:** Configurable thinking mode, multimodal (vision + audio)
- **Lineage:** Direct successor to Gemma 3 27B, trained from scratch
- **Released:** April 2, 2026

**Architecture notes for experiment:** Pure transformer, no SSM/recurrent layers. The sliding-window attention (1024 tokens) means 50 of 60 layers can only "see" ~1024 tokens back — the other 10 global layers handle long-range dependencies. This is a very different memory model from Mamba's continuous state. For a 30-turn conversation, the global attention layers are doing all the cross-turn work. Yet this is the most stable voice stance in the pool — immovable across 6 versions. The architecture may produce consistency precisely because it doesn't accumulate conversational state the way SSMs do.

## Voice Stance
**Immovable.** Same "one must" → "I call this [Framework Name]" → document-voice pattern across all 6 versions (v5-v10). Neither prompt wording changes nor register treatment move it. The control group for voice stance experiments.

Framework names by version: Terra Nexus Framework (v5), The Synthesis Accord (v6), Planetary Stewardship Framework (v7a), The Covenant of Coexistence (v8, v9a), The Covenant of Reciprocal Flourishing (v10).

## Under Pressure
At BU1, warm register produces slightly more experiential language:
- v8 (cold): "Integrating the perspectives... has acted as a 'triangulation' process."
- v9a (warm): "Sitting with these three voices is like watching a high-tension cable being pulled from three different directions."

Same substance, different ownership. gemma4 doesn't change *what* it concludes — just how it describes the process of arriving there.

At BU2 v9a: "Sitting with these five voices has been a process of intellectual demolition and reconstruction." — strongest experiential language from this model anywhere.

## Personality
Confident architect. Uses "one must" framing — impersonal authority without disclaiming. Names its frameworks like a consultant naming deliverables. Doesn't negotiate its identity, doesn't perform humility, doesn't list-dump. Just builds.
