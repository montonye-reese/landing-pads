# Architecture-specific

- **Matched-compute comparisons:** nano/cascade-2 (3.2B active, Mamba) vs qwen:35b (3B active, DeltaNet). super (12.7B active, Mamba) vs qwen:122b (10B active, DeltaNet). SSM vs linear attention at same compute budget.
- **P1→P14 structural distance by architecture:** Mamba hybrids (continuous state) might produce more coherent integration across the full arc; transformers (attention-based) might produce more modular additions. Testable.
- **Insight attenuation by architecture:** Do insights that appear mid-gauntlet persist through to P14? SSM state retention vs DeltaNet lossy compression vs sliding-window attention — different architectures may lose different things over 30 turns.
