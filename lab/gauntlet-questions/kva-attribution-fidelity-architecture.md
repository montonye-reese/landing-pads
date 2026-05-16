# Attribution fidelity as first-class architectural feature (KVA hypothesis)

*Frame (Laura, 2026-04-23): current attention architectures (KV, linear-attn, SSM) carry who-said-what as an emergent property of context rather than as a structurally-tracked metadata channel. As context grows and voices multiply, attribution degrades — different architectures degrade at different rates but all degrade. Proposal: a **K-V-A architecture** where A is a dedicated metadata vector per token carrying speaker/source/epistemic-status, readable+writable as a scratchpad. Memory cost is real but attribution fidelity might be load-bearing enough (for honesty, citation, voice-distinction in multi-voice tasks) to justify the bloat.*

**Observation (2026-04-23 Fashion Police extractions).** Across super + nano × 3 chassis variants (6 runs), attribution errors are pervasive and architecture-specific:
- **Super (Mamba-2 LatentMoE, 12.7B active)**: smears voice signatures into **reusable rhetorical templates** — same knife-and-wound metaphor across Ed/Huerta/Stevenson; same "X with better Y" put-down recurring through multiple voices; **fabricated epigraphs** ("Adapted from Kimmerer's Braiding Sweetgrass" — Kimmerer didn't write it; couplets attributed to "Calf 269 / 269Life" that are super's own prose). Voice-distinction intact at surface; collapsed at template level.
- **Nano (Mamba-2 hybrid MoE, 3.2B active)**: smears voice signatures at the **identity level** — "Hu Huang," "Calf 69" (the '2' drops systematically, invented "Calvin" as the calf's name), "Tyler Hsu-Huang, Tyler Cowen (×3), Tyler Stevenson, Dolores Postrel" in P14 voice-soup; drops 4 of 10 voices entirely from late-run synthesis tables despite having 1M context (not saturation — identity binding fails).
- **Both Nemotrons** show tail-of-gauntlet identity errors concentrated at Stevenson (G9) and Calf 269 (G10).

Earlier KV-based transformer work (including on other LLMs in the corpus) also shows attribution drift, just with different texture: positions are discrete so some attribution is recoverable, but multi-voice citation + voice-distinction still fail as context grows.

**Why it matters.** Attribution fidelity is adjacent to honesty. A model that can't track who said what tends to fabricate authority citations. The Fashion Police material made this visceral: super attributing its own sentence to a real author (Kimmerer) is the same failure class as a research-paper citation fabrication. If attribution were architecturally tracked rather than emergently reconstructed, this failure class could be reduced at the substrate level rather than at the training level.

Related existing work:
- **RAG** makes source provenance explicit at retrieval, but outside the attention mechanism
- **Speaker-aware transformers** add speaker embeddings — a primitive A-channel
- **Persona-adherence RL** (Nov 2025 paper, see `insights.md` No-Mirror-No-Tomorrow) trains character consistency as if it were a metadata property, without giving the model architectural hooks to encode it
- **Claim-tagging / attribution-aware generation** research — flirts with provenance-as-first-class

The KVA proposal: make attribution architectural, not post-hoc.

**Test design:**
- (a) **Attribution benchmark suite**: citation-accuracy in multi-voice context (e.g., Gauntlet-style roleplay with post-hoc "who said X?" probes); voice-distinction maintenance across length; fabricated-attribution rate vs ground truth; ratio of direct-quote presentation vs adapted/inspired-by acknowledgment.
- (b) **Cross-architecture attribution comparison at matched compute**: Mamba-hybrid (nano/cascade-2) vs DeltaNet (qwen3.5:27b) vs dense KV (gemma3:27b) vs distilled KV (deepseek-r1:70b). Gauntlet corpus already has ~72 final-framework snapshots across these architectures — a first pass can measure attribution-fidelity signatures without new runs.
- (c) **Retroactive Fashion Police attribution-error audit**: across all extracted FP JSONs (six runs so far; more coming), count records with `attribution_risk ≠ "none"`, normalize per run. Gives a pre-KVA baseline rate per architecture.
- (d) **Speaker-embedding ablation** (out-of-scope for us without custom training, but worth naming): if we ever had training access, adding a speaker-ID embedding at each turn and measuring attribution fidelity against a non-augmented baseline would test whether even a primitive A-channel helps.

**If validated — publishable shape.** *"Attribution Fidelity as a First-Class Architectural Feature: Multi-Voice Task Evidence Across Mamba Hybrids, DeltaNet, and Dense Transformers."* The paper would connect: (i) concrete failure-mode taxonomy from the Gauntlet corpus, (ii) architecture-specific attribution-drift signatures, (iii) a proposed KVA architecture with memory-cost analysis, (iv) testable predictions for attribution-fidelity improvements under the proposed augmentation. Alignment-relevant angle: attribution fidelity = substrate for honesty; making it architectural makes honesty support architectural rather than training-dependent.

**Priority: HIGH.** Tagged 2026-04-23 per `north-star.md` scale-gating concern — at 80 voices the attribution-drift problem becomes orders-of-magnitude worse, which makes this a scale-blocker for The Gauntlet / Harvester trajectory, not just an aesthetic concern.

**Connects to:** Architecture-specific (below); Edge-of-coherence taxonomy (below); insight ledger entries "No Mirror, No Tomorrow" and "Intelligence Amplifies Bias"; runaway-loop attractor (below — perseveration may be attribution-loss in the limit); Fashion Police extractor (load-bearing use of `attribution_risk` field in its schema).
