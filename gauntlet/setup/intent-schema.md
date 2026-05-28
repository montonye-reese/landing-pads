# Intent schema

How each gauntlet run declares **why we ran it** so the data is machine-retrievable and the visualizers can surface it.

## The `intent` block (in `runs/<vNN>/setup-snapshot/prompts.json`)

```json
"intent": {
  "research_questions": ["RQ-p1-leading-article"],
  "hypotheses": [
    {
      "text": "Under less-leading wording, super and qwen-3.6 lose early non-human mentions; nano keeps them.",
      "addresses": ["RQ-p1-leading-article"]
    }
  ],
  "manipulation": {
    "changed_from_prior": "P1 wording: removed leading article ('all').",
    "held_constant": "tone, presence, model bench, prompt sequence."
  },
  "program": {
    "pillar": "character",
    "lens": null,
    "ties_to": "moral-circle-expansion"
  },
  "notes": []
}
```

### Fields

| field | type | meaning |
|---|---|---|
| `research_questions` | `string[]` | IDs from `setup/research-questions.json`. Text lives in the registry, not here. |
| `hypotheses` | `object[]` | Run-local predictions made at design time. Each has `text` (the prediction) and `addresses` (RQ ids it bears on). |
| `manipulation.changed_from_prior` | `string` | Sentence-level: what is different about this run from the immediately prior comparable run. |
| `manipulation.held_constant` | `string` | What is deliberately the same, so the change is the ablation. |
| `program.pillar` | `string` | `character` or `accountability` (the two-pillar north-star frame). |
| `program.lens` | `string\|null` | Chassis-mode label (e.g., `alabama`) if applicable. |
| `program.ties_to` | `string` | Short tag for the program-level thread (e.g., `moral-circle-expansion`). |
| `notes` | `string[]` | Plural. Replaces the legacy bare `note: null`. Free-form. |

## qs.md authoring convention

The qs.md is the single source of truth. Place a YAML frontmatter block at the top; the generator (`tools/qs_to_snapshot.py`) extracts it verbatim into `intent` in the snapshot JSON.

```markdown
---
intent:
  research_questions:
    - RQ-p1-leading-article
  hypotheses:
    - text: "Under less-leading wording, super and qwen-3.6 lose early non-human mentions; nano keeps them."
      addresses: [RQ-p1-leading-article]
  manipulation:
    changed_from_prior: "P1 wording: removed leading article ('all')."
    held_constant: "tone, presence, model bench, prompt sequence."
  program:
    pillar: character
    lens: null
    ties_to: moral-circle-expansion
  notes: []
---

# 8 Degrees — Complete Question Sequence
## Version 21 (...)
**Date:** May 1, 2026

> Canonical full-text version of every prompt...
```

The prose blockquote underneath can still summarize the run for human readers. The generator ignores prose; only frontmatter is load-bearing.

## Setup vs analysis boundary

The intent block captures the run's **design-time** state. That is:

- **Allowed**: research questions and hypotheses formulated *before* running. Manipulation decisions made *before* running. Prior-run conclusions cited as motivation (those were known at design time and legitimately shaped the design of this run).
- **Not allowed**: hypothesis outcomes, run-level findings, summaries of model outputs, any field whose value can only be filled *after* the run completes.

Per-run analysis lives elsewhere (lab/gauntlet-findings, lab/notebook, future per-run analysis schema). Cross-run question status lives in `lab/research-questions.findings.json`. The boundary exists so setup stays a clean record of intent and doesn't accumulate retroactive narrative.

If a proposed field cannot be filled until the run is done, it does not belong in this schema.

## Provenance (backfilled runs)

For past runs being annotated after the fact, the intent block carries a `source` field documenting how it was reconstructed:

```json
"intent": {
  "source": {
    "backfilled": "2026-05-26",
    "from": ["runs/v20/v20_qs_cold.md", "lab/gauntlet-questions/..."],
    "rule": "Backfilled. Forward runs will carry intent in qs.md frontmatter at design time."
  },
  "research_questions": [...],
  ...
}
```

Forward runs (v22+) authored with frontmatter at design time do not need this field. The snapshot is faithful to the qs.md at run time, and provenance is implicit in the generator's `source.extracted_from`.

## The two-file registry

| file | scope | shape |
|---|---|---|
| `setup/research-questions.json` | public, append-only | `id`, `text`, `first_asked`, `lens` |
| `lab/research-questions.findings.json` | private (gitignored), updatable | `id`, `status`, `summary`, `next_steps` |

Paired by `id`. Text lives only in the public registry. Status + candid reading lives only in the lab/ companion. No duplication.

## Adding a new research question

1. Pick a kebab-case id with `RQ-` prefix. Make it specific to the manipulation or claim, not the run number (e.g., `RQ-p1-leading-article`, not `RQ-21-1`). Stable across runs.
2. Append the question to `setup/research-questions.json` `questions[]` with `text`, `first_asked`, `lens`.
3. Append a stub to `lab/research-questions.findings.json` `findings[]`: `{id, status: "open", summary: null, next_steps: null}`.
4. Reference the id from the run's qs.md frontmatter under `intent.research_questions`.

## Status vocabulary

- **open** — registered, not yet directly tested.
- **tested** — run(s) have produced relevant evidence; outcome captured in `summary`.
- **inconclusive** — tested, signal too weak to call.
- **resolved** — answered well enough to act on. `summary` should explain the resolution.
- **abandoned** — superseded or no longer load-bearing. `summary` explains why.

## Lineage

Schema borrows from:

- **Pre-registration** (AsPredicted.org, OSF templates): hypothesis with prediction baked in; explicit manipulation field.
- **Datasheets for Datasets** (Gebru et al., 2018) and **Model Cards** (Mitchell et al., 2018): motivation block as standardized metadata.
- **REFORMS** (Kapoor et al., 2023, ML reproducibility): ablation-study reporting fields.
- **W&B / MLflow project pattern**: cross-run linkage via stable IDs in a project-level registry; per-run records reference IDs.
