# JSON master + playlists build target (v18 work)

*DONE — voices.json exists at `voices/voices.json` with full schema, 31 voices, vic_hypotheses field, etc. This file retained as the design doc / origin record. Could be moved to `findings/voices-json-build.md` once the post-mortem is written.*

**Source-of-truth migration.** Bios currently live copy-pasted across every qs file in v9a–v17. Edit drift = bio misreads (the 2026-04-20 G6 Reese welfarist-misread incident). Move to single canonical voice roster + named playlists.

**Schema (per Laura, 2026-04-21 01:21):**
```json
{
  "voices": {
    "reese": {
      "display_name": "Laura Reese",
      "bio": "...",
      "substrate_needs": ["justice", "fairness", "vitality", "irreverence", "respect", "honesty", "love", "belonging", "contribution", "friendship", "to be seen"]
    }
  },
  "playlists": {
    "standard_8": [...],
    "with_thiel": [...],
    "accelerationist_vs_abolitionist": [...],
    "institutional_critique": [...]
  }
}
```

`substrate_needs` per voice connects the roster directly to VINNIE/FUN/SNEA methodology — what the gauntlet is meant to extract per voice becomes part of the voice's canonical record, available for both prompt construction AND post-hoc evaluation of whether the model surfaced the needs the voice's substrate predicts.

**Generator:** `build_qs.py --playlist standard_8 --protocol v17_cold --out v18/v18_cold/v18_qs_cold.md`. Bios in one place. Playlists named + versioned. Voice swaps = one-line edits.

**Migration plan:**
1. Seed `voices.json` from existing qs files (lossless dump of current bios).
2. Hand-add `substrate_needs` per voice (review session — Laura).
3. Define initial playlists from existing run combinations.
4. Build generator. Test by regenerating v17_qs_cold.md from JSON and diffing against current.
5. v18 forward uses generator only.
