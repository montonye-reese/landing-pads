# Imitation vs genuine reasoning test (deepseek-r1)

- DeepSeek showed us reasoning is born in RL. R1-70B got its reasoning via SFT distillation from the full R1's traces, not its own RL. The base (LLaMA 3.3 70B) had standard RLHF (DPO + PPO) but for alignment, not reasoning.
- **Key question:** Can SFT on reasoning traces produce genuine reasoning, or only imitation of reasoning format? This is testable.
- **Proposed test design (to workshop):**
  - Compare thinking blocks across models at the same prompt. If deepseek's thinking shows formulaic structure regardless of gauntlet voice (same skeleton every time) while Nemotrons show structurally different thinking for different voices, that's evidence of imitation vs processing.
  - Check whether deepseek's P14 (final rewrite) structurally integrates the full conversation arc or just appends new sections. Compare to Nemotrons' P14 for genuine structural integration.
  - Look for "reasoning about reasoning" — does deepseek ever metacognize about its own process the way qwen27b did ("step back from the Architect seat")? Or does it only report conclusions?
  - The warm register is itself a test: genuine reasoning should be responsive to relational context; imitated reasoning should be format-stable regardless of context. We already have evidence here — deepseek didn't respond to warmth.
- **Potentially publishable on its own** — behavioral evidence for distillation ceiling on reasoning depth.
