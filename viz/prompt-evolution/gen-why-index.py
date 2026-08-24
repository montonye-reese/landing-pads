#!/usr/bin/env python3
"""gen-why-index.py — build data/run-why.json for the run-manifest view.

Reads gauntlet SOURCE (not the mirror): each version's setup-snapshot
prompts.json `intent` block + the RQ registry, plus the earliest transcript
timestamp per version. Emits one row per version, v05 onward ([L] ruled
2026-08-16: the manifest starts at v05).

Rigor contract ([L] 2026-08-16): this script never authors a why. A version
with no intent block in any arm's snapshot renders as a visible gap
("no recorded why"), never as filler. Intent text travels verbatim.

Publish scrub: refuses to emit if any retired-codename string appears in the
intent text it is about to publish (a visible reject, not a silent fix).

Usage:
    python3 gen-why-index.py [--source ~/bench/research/gauntlet]
"""
import argparse
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE / "data" / "run-why.json"
VIZ_START = 5  # [L] ruled 2026-08-16: manifest starts at v05
RETIRED = ("8deg", "8steps")  # never in published copy; filenames only feed dates

TS_RE = re.compile(r"(20\d{6})_(\d{6})")
VER_RE = re.compile(r"^v(\d+)([a-z]?)$")


def version_key(name):
    m = VER_RE.match(name)
    if not m:
        return None
    return (int(m.group(1)), m.group(2))


def find_snapshots(vdir):
    """Yield (arm_label, prompts.json path). Arm '' = single-config version."""
    direct = vdir / "setup-snapshot" / "prompts.json"
    if direct.exists():
        yield "", direct
    for sub in sorted(p for p in vdir.iterdir() if p.is_dir()):
        pj = sub / "setup-snapshot" / "prompts.json"
        if pj.exists():
            yield sub.name, pj


def earliest_date(vdir):
    best = None
    for md in vdir.rglob("*.md"):
        m = TS_RE.search(md.name)
        if m:
            stamp = m.group(1)
            if best is None or stamp < best:
                best = stamp
    return f"{best[0:4]}-{best[4:6]}-{best[6:8]}" if best else None


def sanitize_source(intent):
    """Publish provenance as a summary, never raw artifact paths (paths carry
    the retired codename in old filenames; full pointers stay in source)."""
    srcfield = intent.get("source")
    if not isinstance(srcfield, dict):
        return intent
    out = dict(intent)
    pub = {k: v for k, v in srcfield.items() if k in ("backfilled", "authored", "method")}
    frm = srcfield.get("from")
    if isinstance(frm, list):
        refs = sorted({m for p in frm for m in re.findall(r"v\d+[a-z]?(?:_[a-z-]+)?", str(p))})
        pub["from_summary"] = f"{len(frm)} source artifact(s): {', '.join(refs) if refs else 'run files'}"
    out["source"] = pub
    return out


def load_snapshot(pj):
    """Return (intent, prompt_counts). Counts: cc = P/F/CK turns, gauntlet = G/BU."""
    try:
        data = json.loads(pj.read_text())
    except (json.JSONDecodeError, OSError):
        return None, None
    intent = data.get("intent")
    intent = sanitize_source(intent) if isinstance(intent, dict) else None
    prompts = data.get("prompts") or data.get("sequence")
    counts = None
    if isinstance(prompts, list):
        ids = [str(p.get("id", "")) for p in prompts if isinstance(p, dict)]
        cc = sum(1 for i in ids if i[:1] in ("P", "F") or i.startswith("CK"))
        ga = sum(1 for i in ids if i[:1] == "G" or i.startswith("BU"))
        if cc or ga:
            counts = {"cc": cc, "gauntlet": ga}
    return intent, counts


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--source", default=str(Path.home() / "bench/research/gauntlet"))
    args = ap.parse_args()
    src = Path(args.source).expanduser()
    runs = src / "runs"
    if not runs.is_dir():
        sys.exit(f"source runs/ not found: {runs}")

    registry = {}
    reg_path = src / "setup" / "research-questions.registry.json"
    for q in json.loads(reg_path.read_text()).get("questions", []):
        registry[q["id"]] = {
            "text": q.get("text"),
            "lay_ask": q.get("lay_ask") or q.get("lay_question"),
            "lay_why": q.get("lay_why"),
            "ties_to": q.get("ties_to"),  # the thread this RQ's finding closes (RQ-level link, [L] 2026-08-18)
            "finding": q.get("finding"),  # copied verbatim: {status, tldr, writeup, status_date, limitations, decision{text,rationale}, exhibits} when the RQ record carries one
        }

    versions = []
    used_rqs = set()
    for vdir in sorted((p for p in runs.iterdir() if p.is_dir() and version_key(p.name)),
                       key=lambda p: version_key(p.name)):
        num, _suffix = version_key(vdir.name)
        if num < VIZ_START:
            continue
        arms = []
        for arm, pj in find_snapshots(vdir):
            intent, counts = load_snapshot(pj)
            arms.append({"arm": arm, "intent": intent, "prompt_counts": counts})
            if intent:
                for rq in intent.get("research_questions") or []:
                    used_rqs.add(rq)
        attested = [a for a in arms if a["intent"]]
        status = ("attested" if attested and len(attested) == len(arms) and arms
                  else "partial" if attested
                  else "gap")
        entry = {
            "id": vdir.name,
            "date": earliest_date(vdir),
            "status": status,
            "arms": arms,
        }
        # per-run results record (instrumented/<ver>/results.json), copied verbatim
        # when present; rides the same scrub guard as everything else
        res_path = src / "instrumented" / vdir.name / "results.json"
        if res_path.is_file():
            entry["results"] = json.loads(res_path.read_text())
        versions.append(entry)

    out = {
        "generated_by": "gen-why-index.py (deterministic, no LLM; intent text verbatim from source snapshots)",
        "source_note": "gauntlet/runs/v{N}/**/setup-snapshot/prompts.json intent blocks + setup/research-questions.registry.json",
        "viz_start": f"v{VIZ_START:02d}",
        "versions": versions,
        "rq_index": {k: registry.get(k, {"text": None, "lay_ask": None}) for k in sorted(used_rqs)},
    }

    blob = json.dumps(out, indent=1, ensure_ascii=False)
    leaks = [w for w in RETIRED if w in blob]
    if leaks:
        sys.exit(f"REFUSED: retired codename in emitted copy: {leaks}. Fix at source.")

    OUT.parent.mkdir(exist_ok=True)
    OUT.write_text(blob + "\n")
    n_att = sum(1 for v in versions if v["status"] == "attested")
    n_gap = sum(1 for v in versions if v["status"] == "gap")
    print(f"wrote {OUT.relative_to(HERE)}: {len(versions)} versions "
          f"({n_att} attested, {sum(1 for v in versions if v['status']=='partial')} partial, {n_gap} gaps), "
          f"{len(used_rqs)} RQs")


if __name__ == "__main__":
    main()
