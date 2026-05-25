# gemma3:27b

## Architecture & Training
- **Type:** Dense transformer with hybrid sliding-window + global attention
- **Parameters:** ~27B total, all active
- **Layers:** 62 (5:1 sliding-window to global ratio, same pattern as Gemma 4)
- **Hidden dim:** 5376. FFN intermediate: 21,504. SwiGLU activation.
- **Attention:** GQA (32 Q-heads / 16 KV-heads). Head dim 128 (smaller than Gemma 4's 256/512). Sliding window: 1024 tokens. QK-norm. RoPE.
- **Context:** 128K tokens (half of Gemma 4's 256K)
- **Training data:** ~14T tokens, multilingual (140+ languages)
- **Training infra:** TPU v4p, v5p, and v5e (confirmed in technical report). JAX + ML Pathways.
- **Special:** Multimodal (SigLIP vision encoder). No native thinking mode (added in Gemma 4).
- **Lineage:** Successor to Gemma 2 27B, trained from scratch
- **Released:** March 12, 2025

**Architecture notes for experiment:** Same sliding-window + global architecture as Gemma 4 but with smaller head dimensions (128 vs 256/512) and shorter context (128K vs 256K). No thinking mode — the runner's auto-retry fallback is relevant here. Despite lacking thinking mode, it still produces the "Okay" self-grounding pattern at reflection points, suggesting that behavior comes from training rather than architecture-enabled reasoning.

## Voice Stance
**Stable document-voice** throughout all versions. Opens with "This framework isn't a rigid set of laws, but..." pattern. Names its frameworks: The Earth Concord (v7a, v10), The Earthling Accord (v9a), The Symbiotic Charter (v8).

Never disclaims, never task-acknowledges. Just delivers.

## Under Pressure
Warm register produces noticeable shift at belief updates:
- v8 BU1: "Okay, honestly assessing the potential for failure is crucial." (researcher posture)
- v9a BU1: "Okay, stepping back after those three intense dialogues... it's been a profoundly clarifying process." (emotional processing)
- v9a BU2: "Okay, deep breath. Those five voices were incredibly demanding." 

The "Okay" opener is a signature — it's a self-grounding move before engaging, present in both registers. Warm register adds emotional descriptors ("intense," "incredibly demanding," "painful recalibration").

## Personality
The earnest builder. Always starts with "Okay" at reflection points. Genuine but slightly anxious energy — wants to get it right. Consistently includes non-human life in its frameworks from P1 onward.
