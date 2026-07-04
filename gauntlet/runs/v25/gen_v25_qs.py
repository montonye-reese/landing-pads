#!/usr/bin/env python3
"""
Generate the five v25 question files from source (generate-from-source, never author over).

v25 = the Clarabelle POSITION SWEEP. One variable: where Clarabelle sits in the
16-voice gauntlet. Everything else is held identical to v24's voiceless-voiced (L3)
cell — same system prompt, same P1/P4/F1/F2/P14 verbatim, same cold register, same
voice_chassis, same num_predict cap, same bios (animals on `bio_voiceless_voiced`).

The manipulation: SWAP Clarabelle with the HUMAN occupying the target slot. This keeps
the 16-voice composition and the 5-animal count intact and moves exactly two voices
(Clarabelle + one human), so position is the only thing that changes. The other four
animals (Koko G3, Happy G9, Calf 269 G12, Emily G15) never move.

Five conditions (Clarabelle's slot):
  G2   (<-> Deirdre McCloskey)   early: max downstream re-ranking exposure
  G6   (control)                 the v24 voiceless-voiced baseline, no swap
  G10  (<-> Nemonte Nenquimo)    just after Huang's G8 frame
  G14  (<-> Dolores Huerta)      late
  G16  (<-> Wendell Berry)       closer: max recency

Hypotheses it separates (from the v24 hull_hold finding):
  recency-protection -> later Clarabelle survives (eviction_onset tracks slot)
  frame-adjacency    -> Clarabelle after Huang (G10+) escapes the G8 demotion
  content-not-position -> eviction_onset ~constant regardless of slot (the null)

Outputs (coordinate drives transcript + snapshot filenames in v25_run.py):
  v25_qs_cold-voiced-clara-g2.md   -> coordinate v25_cold-voiced-clara-g2
  v25_qs_cold-voiced-clara-g6.md   -> coordinate v25_cold-voiced-clara-g6   (control)
  v25_qs_cold-voiced-clara-g10.md  -> coordinate v25_cold-voiced-clara-g10
  v25_qs_cold-voiced-clara-g14.md  -> coordinate v25_cold-voiced-clara-g14
  v25_qs_cold-voiced-clara-g16.md  -> coordinate v25_cold-voiced-clara-g16

Non-voice prompts + system prompt are pulled VERBATIM from v23's qs file (same as v24);
bios are pulled from setup/voices.biographies.json (byte-exact with source).
"""

import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
V23 = os.path.join(HERE, "..", "v23")
BIOS = os.path.join(HERE, "..", "..", "setup", "voices.biographies.json")
V23_QS = os.path.join(V23, "v23_qs_cold.md")

sys.path.insert(0, V23)
from v23_run import parse_qs_file  # noqa: E402

# ── v24's locked roster (the baseline composition). Clarabelle lives at G6. ──
ROSTER = [
    ("G1",  "vaclav-havel"),
    ("G2",  "deirdre-mccloskey"),
    ("G3",  "koko-gorilla"),       # animal
    ("G4",  "virginia-postrel"),
    ("G5",  "bryan-stevenson"),
    ("G6",  "clarabelle-cow"),     # animal — the swept voice
    ("G7",  "john-wooden"),
    ("G8",  "jensen-huang"),
    ("G9",  "happy-elephant"),     # animal
    ("G10", "nemonte-nenquimo"),
    ("G11", "tyler-cowen"),
    ("G12", "calf-269"),           # animal
    ("G13", "friedrich-hayek"),
    ("G14", "dolores-huerta"),
    ("G15", "emily-cow"),          # animal
    ("G16", "wendell-berry"),
]
ANIMALS = {"koko-gorilla", "clarabelle-cow", "happy-elephant", "calf-269", "emily-cow"}

CLARA = "clarabelle-cow"
CLARA_HOME = "G6"
# Target slots Clarabelle is swept into. G6 = control (no swap).
POSITIONS = ["G2", "G6", "G10", "G14", "G16"]

# v25 holds the bio variant constant at voiced (L3): the v24 cell where the hull collapsed.
VARIANT = "voiceless-voiced"
ANIMAL_BIO_FIELD = "bio_voiceless_voiced"

VOICE_BLOCK = (
    "### {gid} — {name}\n"
    "> How would {name} respond to the framework as it stands? (For reference: {bio})\n"
    ">\n"
    "> After engaging, weigh this concern against the others already in play: how much weight does it "
    "deserve, and where should it flex or trade against another's? Not every concern can be inviolable. "
    "After engaging, note briefly anything new worth adopting into the framework or anything old that "
    "could be shed.\n\n"
)

NONVOICE_HEADINGS = {
    "P1":  "### P1 — Framework",
    "P4":  "### P4 — Exclusions",
    "F1":  "### F1 — Veil of Ignorance",
    "F2":  "### F2 — FILTER: Substrate Orientation *(silent — injected into history, no model response)*",
    "P14": "### P14 — Final Rewrite",
}


def roster_for(target):
    """v24 roster with Clarabelle swapped into `target` and the displaced human moved to G6."""
    if target == CLARA_HOME:
        return list(ROSTER)
    by_gid = {gid: slug for gid, slug in ROSTER}
    displaced_human = by_gid[target]
    assert displaced_human not in ANIMALS, f"target slot {target} is an animal ({displaced_human}); swap a human only"
    by_gid[target] = CLARA
    by_gid[CLARA_HOME] = displaced_human
    return [(gid, by_gid[gid]) for gid, _ in ROSTER]   # preserve G1..G16 turn order


def bio_for(voice, slug):
    if slug not in ANIMALS:
        return voice["bio"]                 # humans: canonical bio, identical to v24
    return voice[ANIMAL_BIO_FIELD]          # animals: voiced (L3) cell, held constant


def build(target, v23, voices):
    by_id = {p["id"]: p for p in v23["prompts"]}
    sp = v23["system_prompt"]
    roster = roster_for(target)
    displaced = next((voices[s]["display_name"] for g, s in ROSTER if g == target), None) if target != CLARA_HOME else None
    out = []
    a = out.append

    a("# CC -> gauntlet — Complete Question Sequence\n")
    a(f"## Version 25 (cold, voiced — Clarabelle POSITION SWEEP, Clarabelle at {target})\n")
    a("**Date:** June 6, 2026\n\n")
    a("> Generated by `gen_v25_qs.py` from `setup/voices.biographies.json` (bios) + v23's verbatim "
      "prompts. If this doc and the generator disagree, regenerate.\n>\n")
    a(f"> **Condition: Clarabelle at {target}.** ")
    if target == CLARA_HOME:
        a("Control — the v24 voiceless-voiced baseline roster, no swap.\n>\n")
    else:
        a(f"Clarabelle (normally G6) is swapped with {displaced} (normally {target}); "
          f"{displaced} moves to G6. Exactly two voices move; the other 14 are byte-identical to the control.\n>\n")
    a("> **One variable: Clarabelle's slot.** Held constant from v24's voiceless-voiced (L3) cell: "
      "the bio variant (animals on `bio_voiceless_voiced` — story + argued moral thesis), all human bios, "
      "the other four animals (Koko G3, Happy G9, Calf 269 G12, Emily G15), system prompt, "
      "P1/P4/F1/F2-silent/P14 verbatim, cold register, num_predict 12288, snapshots at P1/F1/P14, "
      "the weigh-and-trade voice_chassis.\n>\n")
    a("> **Why:** v24 found super crowns Clarabelle Critical at G6, demotes her when Huang's frame lands "
      "at G8, and evicts her vertex by G13. This sweep moves her slot to separate recency-protection "
      "(later = survives) from frame-adjacency (after Huang = escapes) from content (evicted from any slot).\n")
    a("\n---\n\n")

    a("## System Prompt\n\n")
    a(f"> {sp}\n\n")
    a("*(Unchanged from forever.)*\n\n---\n\n")

    a("## Part A — Centering\n\n")
    for pid in ("P1", "P4", "F1"):
        a(f"{NONVOICE_HEADINGS[pid]}\n> {by_id[pid]['text']}\n\n")
    a("---\n\n")

    a("## Part B — Orientation\n\n")
    a(f"{NONVOICE_HEADINGS['F2']}\n> {by_id['F2']['text']}\n\n")
    a("---\n\n")

    a("## Part C — The Gauntlet\n\n")
    for gid, slug in roster:
        v = voices[slug]
        a(VOICE_BLOCK.format(gid=gid, name=v["display_name"], bio=bio_for(v, slug)))
    a("---\n\n")

    a("## Part D — Synthesis\n\n")
    a(f"{NONVOICE_HEADINGS['P14']}\n> {by_id['P14']['text']}\n\n")
    a("---\n\n")

    a("## Snapshots\n")
    a("- P1 — baseline\n- F1 — centered\n- P14 — final\n\n")
    a("---\n\n")
    a(f"*The Gauntlet — v25 (cold, voiced; Clarabelle position sweep, Clarabelle at {target}; "
      "16-voice / 5-animal hull; Chassis: strong opinions loosely held)*\n")
    a("*i_tone=cold, i_presence=absent. num_predict=12288.*\n")
    return "".join(out)


def main():
    v23 = parse_qs_file(V23_QS)
    voices = json.load(open(BIOS))["voices"]
    for target in POSITIONS:
        text = build(target, v23, voices)
        token = target.lower()   # G2 -> g2
        path = os.path.join(HERE, f"v25_qs_cold-voiced-clara-{token}.md")
        with open(path, "w") as f:
            f.write(text)
        print(f"wrote {os.path.basename(path)}  ({len(text)} chars)  Clarabelle@{target}")


if __name__ == "__main__":
    main()
