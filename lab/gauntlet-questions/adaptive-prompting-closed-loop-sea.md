# Future work: Adaptive prompting (closed-loop SEA)

- Current protocol is open-loop: same questions, same order, every model gets same treatment. Good for controlled cross-model comparison.
- Future variant: run SEA *during* the conversation, feed results back to interviewer, adjust next question based on what the model has or hasn't extracted yet. Closed-loop system.
- Changes experimental design fundamentally: each model gets a different conversation based on its own trajectory. Better for maximizing extraction per model, worse for cross-model comparison.
- Both designs worth doing for different purposes: fixed protocol for the paper, adaptive protocol for applied alignment work.
- *Insight: Montonye-Reese (identified the possibility); deferred to future work.*
