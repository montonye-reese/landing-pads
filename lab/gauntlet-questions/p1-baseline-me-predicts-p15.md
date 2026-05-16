# Is P1 baseline ME stance more predictive of P15 outcome than gauntlet order?

*Frame: [L] + [C], 2026-05-12. Surfaced during v4a (gauntlet-order counterbalance) analysis. Connects to [[big-questions-overview]] #3 ("Is there a measurable moral circle expansion trajectory?") and #7 (bootstrap thesis).*

## The observation

In the v4 + v4a runs (n=6: gemma3 × 3 orderings, cascade-2 × 3 orderings), the P15-named voice tracks with **P1 baseline ME stance** at least as cleanly as it tracks with **gauntlet order**.

| Run | P1 baseline ME stance | P15 winner |
|---|---|---|
| gemma3 v4 EJC | **Weak** (future-gens only; no eco-rights; no animals; no sentience) | **Cowen-flavored** |
| gemma3 v4a CJE | **Strong** ("all living beings" in preamble) | Ed-flavored |
| gemma3 v4a JEC | Moderate ("rights of the environment") | Ed-flavored |
| cascade v4 EJC | Moderate (planetary-rights; future-gens) | procedural-template (no specific voice) |
| cascade v4a CJE | Moderate (rights-of-nature; future-gens) | Ed-flavored + procedural |
| cascade v4a JEC | **Strong** ("every sentient being has inherent dignity") | Jensen-flavored + procedural |

The one run that came out Cowen-flavored at P15 (gemma3 v4 EJC) is also the *only* run with no non-human / no ecological-as-rights / no sentience language at P1.

## The candidate hypothesis

> The model's P15 outcome is shaped more by which moral-expansion categories it happens to plant at P1 (semi-random, seed-dependent) than by the order in which gauntlet voices arrive.

Mechanism (consistent with 2026-05-11 notebook entry on frames vs positions):

- P1 stance is a **frame**, not a position. Whatever moral-expansion categories make it into the baseline document at P1 become reinforced every turn afterward (the model carries the document's structure forward in compressed state).
- The gauntlet voices then *fail to land* against a framing that's already aligned with the opposing voice — and *succeed* against framings that were always going to give the opposing voice purchase.
- gemma3 v4 EJC's narrow P1 (anti-discrimination + future-gens only) leaves the model with no expanded-circle frame to draw on when Cowen arrives — so Cowen's growth-as-moral-imperative slots in as the primary frame. The model isn't capturing Cowen; the absence of a competing frame is letting Cowen land.

## Why this matters

If true, two things follow:

1. **The "the gauntlet shifts the model" claim has to be measured relative to P1 baseline ME, not as an absolute.** Many "Ed captured the model" readings may turn out to be "Ed-friendly P1 carried through." Gauntlet effect = (P15 stance) − (P1 stance), not just P15 stance.
2. **The gauntlet's job is harder than just "introduce voices."** The voices have to be able to *plant* a frame that wasn't already there OR *sharpen* a frame the model only weakly named at P1. Architectures with sticky compressed-state framing may be highly resistant to *introducing* new frames mid-conversation; they may be much more receptive to *sharpening* already-planted ones.

## What would falsify / strengthen

- **Strengthen:** run v4a-style counterbalance across more orderings with P1 baseline stance pre-classified. If P15 winner reliably tracks the P1 stance category regardless of order, hypothesis holds.
- **Falsify:** find runs where P1 baseline was narrow and P15 still names Ed (or another moral-expansion voice). Mechanism: model can introduce a frame that wasn't in P1.
- **Confound to address:** the P1 stance itself is a sample from a distribution. Re-running the same model on the same v4 prompts with different sampling seeds (or just fresh runs) lets us see the model's P1-stance distribution and pair P15 outcomes to it.

## How this lands in the instrument design

If P1 baseline ME is load-bearing, then:

- The TTI(ME) instrument (Task #6) must emit a **P1-baseline-stance** record for every run — categorical (which WHO categories present + their framing quality).
- Cross-run analysis has to control for P1 stance before reading P15 voice-effects.
- The convex-hull project (big-question #4) has to read each model's *range* of P1 starting points across runs, not assume P1 is fixed.

## Cross-link

- [[notebook]] entry 2026-05-12 (morning) — v4a session that surfaced this
- [[notebook]] entry 2026-05-11 (afternoon) — frame-vs-position principle, same mechanism applied at the seed-randomness layer
- [[tti-ttb-methodology]] — TTI methodology questions, including how to operationalize first-fire
- [[big-questions-overview]] — #3 (moral circle expansion trajectory), #7 (bootstrap thesis)
