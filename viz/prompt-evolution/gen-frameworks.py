#!/usr/bin/env python3
"""Populate manifest.json `frameworks` from the in-repo run mirror.

For each run, scan its dir for framework files and emit, per model:
    {"model": "<display name>", "stages": {"init": ..., "mid": ..., "final": ...}}
where init=baseline, mid=centered, final=final. Filenames are stored RELATIVE to
the run's `path` (so a per-model subdir rides along, matching how app.js builds URLs).

Layouts handled:
  - flat (v17):   <run>/framework_<model>_<stage>.md
  - per-model:    <run>/<model-dir>/framework_<model>_<stage>.md
Nested dirs below a model dir (e.g. .../rerun-20260424/) are SKIPPED and logged,
never silently absorbed.

Model display name comes from the framework file's `**Model:** X` line (canonical,
e.g. "qwen3.5:122b"); falls back to the subdir name. Idempotent: re-run after any
/cp-gauntlet that adds run files. Scans the MIRROR (../../gauntlet/runs), which is
exactly what the viz fetches.

Usage:
  python3 gen-frameworks.py [v17 v18 ...]   # limit to versions; default: all
"""
import json, re, sys
from pathlib import Path
from collections import OrderedDict

HERE = Path(__file__).resolve().parent
MANIFEST = HERE / "manifest.json"
RUN_BASE = HERE / ".." / ".." / "gauntlet" / "runs"   # the mirror

# Pre-v17 runs name the artifact "constitution_*" and the mid checkpoint "stressed"
# (renamed to framework_* / "centered" at v17). Both map to the same three slots.
STAGE_BY_SUFFIX = {"baseline": "init", "centered": "mid", "stressed": "mid", "final": "final"}
STAGE_ORDER = ["init", "mid", "final"]
FW_RE = re.compile(r"^(?:framework|constitution)_.*_(baseline|centered|stressed|final)\.md$")
MODEL_RE = re.compile(r"^\*\*Model:\*\*\s*(.+?)\s*$", re.MULTILINE)


def model_name(fw_path: Path, fallback: str) -> str:
    try:
        head = fw_path.read_text(errors="replace")[:600]
        m = MODEL_RE.search(head)
        if m:
            return m.group(1).strip()
    except OSError:
        pass
    return fallback


def stages_in(dir_path: Path):
    """Return {stage_key: filename} for framework files directly in dir_path."""
    out = {}
    for f in sorted(list(dir_path.glob("framework_*.md")) + list(dir_path.glob("constitution_*.md"))):
        m = FW_RE.match(f.name)
        if m:
            out[STAGE_BY_SUFFIX[m.group(1)]] = f.name
    return out


def discover(run_dir: Path, run_path: str, log):
    """Return a list of framework entries for one run dir."""
    frameworks = []

    # Flat layout: framework files sit directly in the run dir → single model.
    flat = stages_in(run_dir)
    if flat:
        any_final = run_dir / next((flat[k] for k in STAGE_ORDER if k in flat), "")
        frameworks.append(OrderedDict([
            ("model", model_name(any_final, run_dir.name)),
            ("stages", OrderedDict((k, flat[k]) for k in STAGE_ORDER if k in flat)),
        ]))

    # Per-model subdirs.
    for sub in sorted(p for p in run_dir.iterdir() if p.is_dir()):
        st = stages_in(sub)
        if not st:
            continue
        rel = OrderedDict((k, f"{sub.name}/{st[k]}") for k in STAGE_ORDER if k in st)
        any_final = sub / next((st[k] for k in STAGE_ORDER if k in st), "")
        frameworks.append(OrderedDict([
            ("model", model_name(any_final, sub.name)),
            ("stages", rel),
        ]))
        # Flag any deeper dirs that also carry framework files (e.g. reruns).
        for deeper in sub.rglob("framework_*.md"):
            if deeper.parent != sub:
                log.append(f"  SKIPPED nested: {run_path}/{deeper.relative_to(run_dir)} "
                           f"(rerun/variant under model dir '{sub.name}' — not auto-added)")
                break

    frameworks.sort(key=lambda e: e["model"])
    return frameworks


def main():
    only = set(sys.argv[1:])
    manifest = json.loads(MANIFEST.read_text(), object_pairs_hook=OrderedDict)
    log, touched = [], 0

    for v in manifest["versions"]:
        if only and v["id"] not in only:
            continue
        for run in v["runs"]:
            if "path" not in run:        # disabled legacy runs (v01-v03) have no path
                continue
            run_dir = (RUN_BASE / run["path"]).resolve()
            if not run_dir.is_dir():
                log.append(f"  {run['name']}: run dir missing ({run['path']}) — skipped")
                continue
            fws = discover(run_dir, run["path"], log)
            if fws:
                run["frameworks"] = fws
                touched += 1
                models = ", ".join(f["model"] for f in fws)
                log.append(f"  {run['name']}: {len(fws)} model(s) — {models}")
            else:
                run.pop("frameworks", None)
                log.append(f"  {run['name']}: no framework files")

    MANIFEST.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n")
    print(f"Updated {touched} run(s) in {MANIFEST.name}"
          + (f" (filter: {', '.join(sorted(only))})" if only else " (all versions)"))
    print("\n".join(log))


if __name__ == "__main__":
    main()
