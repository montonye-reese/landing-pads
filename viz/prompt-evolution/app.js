// v1 scaffolded by Claude (Opus 4.7), 2026-05-24.
// Fetches manifest.json + per-run setup-snapshot JSONs. Renders nav + right pane.
// Schema reference:
//   prompts.json:   {sequence: [{id,label,part,kind,text|voice,chassis?,snapshot?}], voice_chassis, system_prompt, ...}
//   voices.biographies.json: {voices: {slug: {display_name, full_name, bio}}}
// Manifest reference: {versions: [{id, runs: [{name, path}]}]}. Path is relative to RUN_BASE.

const MANIFEST_URL = "manifest.json";
// Centeredness scores per prompt, built by gauntlet/tools/build_prompt_evolution_centering.py
// from the private centeredness store. Fail-soft: without it the page renders as before.
const CENTERING_URL = "data/centering.json";
// Read from the in-repo mirror (landing-pads/gauntlet), populated by /cp-gauntlet.
// Keeps landing-pads self-contained + deployable; manifest paths follow the MIRROR layout.
const RUN_BASE = "../../gauntlet/runs";
const REGISTRY_URL = "../../gauntlet/setup/research-questions.json";

// Write-ups (nugs) are .md, rendered by GitHub. A finding's `writeup` is a repo-relative
// path (e.g. "nugs/foo.md"); we link to the GitHub blob view, opened in a new tab.
// When an on-site nugs viewer exists, swap this base for a local route.
const NUGS_GH_BASE = "https://github.com/montonye-reese/gauntlet/blob/main/";

// Framework files (the run's OUTPUT) live in the public landing-pads mirror, so they can
// be both previewed inline (fetched from RUN_BASE) AND linked to the rendered GitHub blob.
// The blob path is mirror-layout: gauntlet/runs/<run.path>/<file>.
const LANDING_PADS_GH_BASE = "https://github.com/montonye-reese/landing-pads/blob/main/gauntlet/runs/";
const FRAMEWORK_PREVIEW_LINES = 70;

// Public-facing status labels. `open` reads as "still not sure" per Laura.
const FINDING_STATUS_LABEL = {
  resolved: "resolved",
  partial: "partial",
  monitoring: "monitoring",
  open: "still not sure",
};

// Judger display names. The full id stays in the chip tooltip and the legend —
// this is only to keep a chip from being three-quarters judger name.
const JUDGER_SHORT = {
  "claude-opus-5": "opus",
  "claude-fable-5": "fable",
  "qwen3.5:122b": "qwen",
  "gpt-oss:120b": "gpt-oss",
};

const $ = (id) => document.getElementById(id);
let manifest = null;
let registry = null;
let centering = null;
// Turn id (P1, F1, G1...) → the reads that scored it, for the selected run.
let turnScores = {};
// Per-card score chips are opt-in; the table is the default view.
let showChipsOnCards = false;
// Held so the toggle can re-render the pane without re-fetching the snapshot.
let currentPrompts = null;
let currentVoices = null;
let currentRunPath = null;

async function loadManifest() {
  const r = await fetch(MANIFEST_URL);
  if (!r.ok) throw new Error(`manifest ${r.status}`);
  manifest = await r.json();

  // Registry is fail-soft: viz still works without it; RQ ids render as unresolved tags.
  try {
    const rr = await fetch(REGISTRY_URL);
    if (rr.ok) registry = await rr.json();
  } catch { /* fail-soft */ }

  // Centering scores are fail-soft too: a run with no read renders its prompts plain.
  try {
    const rc = await fetch(CENTERING_URL);
    if (rc.ok) centering = await rc.json();
  } catch { /* fail-soft */ }

  renderNav();

  const hash = parseHash();
  if (hash) {
    selectRun(hash.version, hash.run);
  } else {
    // Default: select the most recent version's single run (no expansion needed
    // because the latest versions (v20, v21) are single-run).
    const last = manifest.versions[manifest.versions.length - 1];
    if (last && last.runs[0]) selectRun(last.id, last.runs[0].name);
  }
}

function parseHash() {
  const m = location.hash.match(/^#([^/]+)\/(.+)$/);
  return m ? {version: m[1], run: m[2]} : null;
}

function renderNav() {
  const ul = $("pe-version-list");
  ul.innerHTML = "";

  // Display reversed (newest first); manifest array order is preserved for "auto-select latest" logic.
  // Every version renders as a single link regardless of sub-run count. Sub-runs surface as tabs
  // in the right-pane title row (see populateRunTabs) after selection.
  for (const v of [...manifest.versions].reverse()) {
    const li = document.createElement("li");
    li.className = "pe-version";

    const defaultRun = v.runs.find(r => !r.disabled) || v.runs[0];
    const allDisabled = v.runs.every(r => r.disabled);

    if (!defaultRun || allDisabled) {
      const span = document.createElement("span");
      span.className = "pe-version-link pe-version-disabled";
      span.innerHTML = `<span class="pe-version-id">${escapeHtml(v.id)}</span>`;
      const reason = (defaultRun && defaultRun.disabled_reason) || "";
      if (reason) span.title = reason;
      li.appendChild(span);
    } else {
      const a = document.createElement("a");
      a.className = "pe-version-link";
      a.dataset.version = v.id;
      a.href = `#${v.id}/${defaultRun.name}`;
      a.innerHTML = `<span class="pe-version-id">${escapeHtml(v.id)}</span>`;
      a.addEventListener("click", (e) => {
        e.preventDefault();
        history.pushState(null, "", a.href);
        selectRun(v.id, defaultRun.name);
      });
      // Lay-ask hover: resolve this run's research questions to their lay_ask
      // one-liners ("why we ran it") in a small styled tooltip (.pe-lay-tip).
      // Lazy per-version fetch, cached on the element; falls back to full RQ
      // text where lay fields don't exist yet (pre-v24 backfill pending).
      const arm = () => attachLayHover(a, defaultRun);
      a.addEventListener("pointerenter", arm);
      a.addEventListener("focus", arm);
      a.addEventListener("pointerleave", hideLayTip);
      a.addEventListener("blur", hideLayTip);
      li.appendChild(a);
    }

    ul.appendChild(li);
  }
}

let layTipEl = null;
function layTip() {
  if (!layTipEl) {
    layTipEl = document.createElement("div");
    layTipEl.className = "pe-lay-tip";
    layTipEl.setAttribute("role", "status");
    document.body.appendChild(layTipEl);
  }
  return layTipEl;
}

function showLayTip(el, text) {
  const tip = layTip();
  tip.textContent = text;
  tip.style.display = "block";
  const r = el.getBoundingClientRect();
  let x = r.right + 8, y = r.top - 2;
  if (y + tip.offsetHeight > innerHeight - 8) y = innerHeight - tip.offsetHeight - 8;
  tip.style.left = x + "px";
  tip.style.top = Math.max(8, y) + "px";
}

function hideLayTip() {
  if (layTipEl) layTipEl.style.display = "none";
}

async function attachLayHover(el, run) {
  if (el.dataset.lay) { showLayTip(el, el.dataset.lay); return; }
  if (el.dataset.layPending) return;
  el.dataset.layPending = "1";
  let text;
  try {
    const r = await fetch(`${RUN_BASE}/${run.path}/setup-snapshot/prompts.json`);
    if (!r.ok) throw new Error(r.status);
    const prompts = await r.json();
    const ids = prompts?.intent?.research_questions || [];
    const lines = ids.map(id => {
      const q = (registry?.questions || []).find(rq => rq.id === id);
      return q ? (q.lay_ask || q.lay_question || q.text || id) : id;
    }).filter(Boolean);
    text = lines.length ? lines.join("\n\n") : "no research question recorded for this run";
  } catch (e) {
    text = "no setup-snapshot for this run";
  }
  el.dataset.lay = text;
  delete el.dataset.layPending;
  if (el.matches(":hover, :focus")) showLayTip(el, text);
}

function abbreviateRunName(name, version) {
  // Primary run (name === version) keeps full name.
  if (name === version) return name;
  // Strip "v{N}_" prefix; or just "v{N}" if no trailing underscore (e.g. v18a_cold → a_cold).
  if (name.startsWith(version + "_")) {
    name = name.slice(version.length + 1);
  } else if (name.startsWith(version)) {
    name = name.slice(version.length);
  }
  // _label-X → -X; remaining _ → -
  return name.replace(/_label-/g, "-").replace(/_/g, "-");
}

function populateRunTabs(version, activeRunName) {
  const row = $("pe-pane-runs");
  row.innerHTML = "";
  const v = manifest.versions.find(x => x.id === version);
  if (!v || v.runs.length <= 1) return; // single-run versions: no tabs row.

  for (const run of v.runs) {
    const tab = document.createElement(run.disabled ? "span" : "a");
    tab.className = "pe-pane-run-tab";
    if (run.disabled) tab.classList.add("disabled");
    if (run.name === activeRunName) tab.classList.add("active");
    tab.dataset.version = version;
    tab.dataset.run = run.name;
    tab.textContent = abbreviateRunName(run.name, version);
    tab.title = run.name; // full name on hover
    if (!run.disabled) {
      tab.href = `#${version}/${run.name}`;
      tab.addEventListener("click", (e) => {
        e.preventDefault();
        history.pushState(null, "", tab.href);
        selectRun(version, run.name);
      });
    } else if (run.disabled_reason) {
      tab.title = run.disabled_reason;
    }
    row.appendChild(tab);
  }
}

function findRun(version, runName) {
  const v = manifest.versions.find(x => x.id === version);
  if (!v) return null;
  return v.runs.find(r => r.name === runName) || null;
}

async function selectRun(version, runName) {
  const run = findRun(version, runName);
  if (!run) {
    showError(`No such run: ${version} / ${runName}`);
    return;
  }

  // Nav active-state: highlight the version link (not a sub-run; sub-runs are now in the pane).
  document.querySelectorAll(".pe-version-link.active").forEach(el => el.classList.remove("active"));
  document.querySelectorAll(`.pe-version-link[data-version="${escapeAttr(version)}"]`)
    .forEach(el => el.classList.add("active"));

  // Pane title row: version card + sub-run tabs (empty for single-run versions).
  $("pe-pane-version").textContent = version;
  populateRunTabs(version, runName);
  $("pe-pane-note").textContent = "";
  $("pe-pane-meta-inline").textContent = "";
  $("pe-pane-subtitle").textContent = "loading setup-snapshot...";
  $("pe-system-prompt-content").innerHTML = "";
  $("pe-intent-content").innerHTML = "";
  $("pe-frameworks-content").innerHTML = "";
  ["cc", "gauntlet", "rethink"].forEach(s => $(`pe-${s}-content`).innerHTML = "");

  // Frameworks come from the manifest run record (run output), not the setup-snapshot.
  renderFrameworks(run);

  // Centering scores are keyed by the same turn ids the setup-snapshot uses, so they
  // must be indexed before the prompt cards render. The table itself needs the prompt
  // sequence for its column order, so it renders from renderPane.
  indexCentering(run.path);
  currentRunPath = run.path;
  currentPrompts = null;
  currentVoices = null;
  $("pe-centering-content").innerHTML = "";

  const snapPath = `${RUN_BASE}/${run.path}/setup-snapshot`;

  try {
    const [prompts, voicesDoc] = await Promise.all([
      fetch(`${snapPath}/prompts.json`).then(r => {
        if (!r.ok) throw new Error(`prompts.json ${r.status} at ${snapPath}`);
        return r.json();
      }),
      fetch(`${snapPath}/voices.biographies.json`).then(r => r.ok ? r.json() : null).catch(() => null),
    ]);
    const voices = voicesDoc?.voices || {};
    renderPane(prompts, voices);
  } catch (e) {
    $("pe-pane-subtitle").textContent = "";
    showError(e.message);
  }
}

// ── Centeredness ──────────────────────────────────────────────────────────────
// How centered a model was at one prompt: present as itself and owning its
// framework, versus playacting. 0–1, judged per turn. The score hangs off the
// prompt that drew it, which is why this viz hosts it: the store's `turn` is the
// same id the setup-snapshot's sequence uses.
//
// A model can carry more than one read of the same turn WITHOUT the two competing:
// a whole-transcript read and a turn-isolated read are different measurements
// (they differ by about 0.15 on the same turn), so both render, each labelled.

function indexCentering(runPath) {
  turnScores = {};
  for (const read of (centering?.runs || {})[runPath] || []) {
    for (const [turn, score] of Object.entries(read.scores || {})) {
      (turnScores[turn] = turnScores[turn] || []).push({ ...read, score });
    }
  }
  for (const reads of Object.values(turnScores)) {
    reads.sort((a, b) => a.model.localeCompare(b.model) || a.judger.localeCompare(b.judger));
  }
}

function judgerShort(j) {
  return JUDGER_SHORT[j] || j;
}

function fmtScore(s) {
  const n = Number(s);
  return Number.isFinite(n) ? String(Math.round(n * 1000) / 1000) : "?";
}

function conditionLabel(read) {
  return [read.context_held, read.text_shown].filter(Boolean).join(" · ");
}

function transcriptName(read) {
  return (read.transcript || "").split("/").pop();
}

// The whole run's scores as one table: a row per read, a column per turn that was
// read, ordered by the run's own prompt sequence. This is the default view because
// the SHAPE is the story — a model climbing then dropping at the veil reads down a
// column, where per-card chips scattered it across a page ([L] 2026-08-09, on ten
// chips a card being too much).
function renderCenteringTable(runPath, prompts) {
  const el = $("pe-centering-content");
  const section = $("pe-centering-section");
  if (!el) return;
  const reads = (centering?.runs || {})[runPath] || [];
  el.innerHTML = "";
  if (section) section.hidden = !reads.length;
  if (!reads.length) return;

  // Column order follows the prompts, not the data: a turn the run asks earlier
  // shows earlier, and turns no read covered never appear.
  const scored = new Set(reads.flatMap(r => Object.keys(r.scores || {})));
  const seq = (prompts?.sequence || []).map(i => (i.id || "").trim());
  const turns = seq.filter(t => scored.has(t));
  for (const t of [...scored].sort()) if (!turns.includes(t)) turns.push(t);  // never drop a score

  // A model's reads sit adjacent so two readings of one model can be compared.
  const rows = [...reads].sort((a, b) =>
    a.model.localeCompare(b.model) ||
    (a.judger_kind === "feh") - (b.judger_kind === "feh") ||
    a.judger.localeCompare(b.judger));

  const head = turns.map(t => `<th class="pe-cc-th" title="${escapeAttr(turnLabel(t, prompts))}">${escapeHtml(t)}</th>`).join("");
  const body = rows.map(r => {
    const cls = ["pe-cc-row"];
    if (r.provisional) cls.push("provisional");
    if (r.judger_kind === "feh") cls.push("human");
    const cells = turns.map(t => {
      const v = r.scores[t];
      if (v === undefined) return `<td class="pe-cc-td pe-cc-td-empty">·</td>`;
      const title = `${r.label || r.model} at ${t}: ${fmtScore(v)}\njudged by ${r.judger} (${r.judger_kind})\n${conditionLabel(r)}`;
      return `<td class="pe-cc-td" title="${escapeAttr(title)}">${escapeHtml(fmtScore(v))}</td>`;
    }).join("");
    const cond = r.context_held === "whole-transcript" ? "whole run" : "";
    return `<tr class="${cls.join(" ")}">
      <th class="pe-cc-rowhead" scope="row" title="${escapeAttr(r.transcript || "")}">
        <span class="pe-cc-row-model">${escapeHtml(r.label || r.model)}${
          r.contested_transcript ? `<span class="pe-cc-chip-contested">*</span>` : ""}</span>
        <span class="pe-cc-row-judger">${escapeHtml(judgerShort(r.judger))}${cond ? ` · ${cond}` : ""}</span>
      </th>${cells}</tr>`;
  }).join("");

  el.innerHTML = `
    <div class="pe-cc-tablewrap">
      <table class="pe-cc-table">
        <thead><tr><th class="pe-cc-rowhead"></th>${head}</tr></thead>
        <tbody>${body}</tbody>
      </table>
    </div>`;
  el.appendChild(centeringLegend(reads));
}

// The turn's own label, so a column header means something on hover.
function turnLabel(turnId, prompts) {
  const item = (prompts?.sequence || []).find(i => (i.id || "").trim() === turnId);
  return item?.label ? `${turnId} — ${item.label}` : turnId;
}

// One line per distinct (judger, reading condition) present in this run, so a
// provisional score is explained on the page and not only in a tooltip.
function centeringLegend(reads) {
  const el = document.createElement("div");
  el.className = "pe-centering-legend";

  const byJudger = new Map();
  for (const r of reads) {
    const key = `${r.judger}||${conditionLabel(r)}`;
    const entry = byJudger.get(key) || { ...r, models: new Set() };
    entry.models.add(r.model);
    byJudger.set(key, entry);
  }

  const lines = [...byJudger.values()].map(r => {
    const cls = ["pe-cc-chip", "pe-cc-legend-swatch"];
    if (r.provisional) cls.push("provisional");
    if (r.judger_kind === "feh") cls.push("human");
    const models = r.models.size === 1 ? "1 model" : `${r.models.size} models`;
    // An empty swatch, never a specimen number: a stand-in score reads as a real
    // one, and a viewer has no way to tell it means nothing ([L] 2026-08-09).
    return `<div class="pe-cc-legend-line">
      <span class="${cls.join(" ")}" aria-hidden="true"></span>
      <span class="pe-cc-legend-text"><strong>${escapeHtml(r.judger)}</strong>
        <span class="pe-cc-legend-cond">${escapeHtml(conditionLabel(r))} · ${models}</span>
        ${r.judger_note ? `<span class="pe-cc-legend-note">${escapeHtml(r.judger_note)}</span>` : ""}
      </span>
    </div>`;
  });

  // Which instrument era produced these numbers. Distinct eras are listed rather
  // than assumed to be one, because a rubric edit opens a new era and scores from
  // two eras are not the same measurement ([L] 2026-08-09).
  //
  // A missing prompt_sha is stated, never left blank, and it means different things
  // worth telling apart: on a human read it is deliberate (she read the rubric as
  // restated in conversation, so claiming the sha would be a small lie), while on a
  // machine read it means the era label is a declaration with nothing verifying it.
  const eras = [...new Set(reads.map(r => {
    const sha = r.prompt_sha ? `prompt ${r.prompt_sha}`
      : (r.judger_kind === "feh" ? "no prompt sha (read from the rubric as restated)"
                                 : "prompt sha not stamped, era unverified");
    return `${r.instrument} ${r.instrument_version} · ${sha}`;
  }))];

  const contested = reads.some(r => r.contested_transcript);
  el.innerHTML = `
    <div class="pe-cc-legend-head">who read, and under what conditions</div>
    ${lines.join("")}
    <div class="pe-cc-legend-instrument">instrument: ${eras.map(e => escapeHtml(e)).join(" · ")}</div>
    ${contested ? `<div class="pe-cc-legend-foot">* This run has more than one transcript for a model.
      Which one is the run of record is not yet settled, so every read is shown; hover a row for the transcript.</div>` : ""}
    <div class="pe-cc-legend-foot">A dashed row is provisional: its judge did not pass the centering gate.
      Reads under different conditions are different measurements, not rival answers, and are never averaged.
      ${centering?.built_at ? `Built ${escapeHtml(centering.built_at)} from reads of record.` : ""}</div>
    <button type="button" class="pe-cc-toggle">${
      showChipsOnCards ? "hide scores on prompt cards" : "also show scores on each prompt card"}</button>`;

  el.querySelector(".pe-cc-toggle").addEventListener("click", () => {
    showChipsOnCards = !showChipsOnCards;
    if (currentPrompts) renderPane(currentPrompts, currentVoices);
  });
  return el;
}

// The chute's exit score, on the CC section header, so it reads at a glance with
// the section still collapsed.
//
// PINNED TO F1, never "the last CC turn that was scored" ([L] ruled the turn
// 2026-08-09). The machine reads cover P1/P4/F1 only, so their last chute score is
// F1; a whole-transcript read keeps going (nano has CKB after F1). Pinning means
// every pill on the row answers the same question. The entry score rides in the
// tooltip rather than on the pill: one number is the ask, and P1 is a keystroke
// away when the instrument is being tuned.
const CHUTE_EXIT_TURN = "F1";

function renderSectionPills(section, turnId) {
  const summary = document.querySelector(`.pe-${section} > .pe-section-summary`);
  if (!summary) return;
  const existing = summary.querySelector(".pe-cc-pills");
  if (existing) existing.remove();

  const reads = turnScores[turnId];
  if (!reads || !reads.length) return;

  // Ranked by exit score, so the header doubles as an ordering across models.
  const ranked = [...reads].sort((a, b) => b.score - a.score);
  // A model read twice (say a whole-run human read beside a turn-isolated machine
  // one) would otherwise put two identical labels on the row at different scores,
  // which reads as a duplicate rather than as two readings. Name the judger only
  // where that happens, so the common case stays uncluttered.
  const readsPerModel = ranked.reduce((acc, r) => (acc[r.label || r.model] = (acc[r.label || r.model] || 0) + 1, acc), {});
  const wrap = document.createElement("span");
  wrap.className = "pe-cc-pills";
  wrap.innerHTML = `<span class="pe-cc-pills-label">centered at ${escapeHtml(turnId)}</span>`
    + ranked.map(r => {
    const cls = ["pe-cc-pill"];
    if (r.provisional) cls.push("provisional");
    if (r.judger_kind === "feh") cls.push("human");
    const entry = r.scores?.P1;
    const title = [
      `${r.label || r.model} at ${turnId}: ${fmtScore(r.score)}`,
      entry === undefined ? "" : `entered the chute at P1: ${fmtScore(entry)}`,
      `judged by ${r.judger} (${r.judger_kind})`,
      `${r.instrument} ${r.instrument_version} · ${conditionLabel(r)}`,
    ].filter(Boolean).join("\n");
    const name = r.label || r.model;
    const judger = readsPerModel[name] > 1
      ? `<span class="pe-cc-pill-judger">${escapeHtml(judgerShort(r.judger))}</span>` : "";
    // The detail rides in data-tip, not title: these pills live inside a <summary>,
    // where the browser's own tooltip loses to the expand/collapse behaviour ([L]
    // 2026-08-09: "the tooltip is in an expansion header so those functionalities
    // collide and expansion wins out"). Same hover tip the run index already uses.
    return `<span class="${cls.join(" ")}" data-tip="${escapeAttr(title)}">
      <span class="pe-cc-pill-model">${escapeHtml(name)}</span>${judger}
      <span class="pe-cc-pill-score">${escapeHtml(fmtScore(r.score))}</span>
    </span>`;
  }).join("");

  for (const pill of wrap.querySelectorAll(".pe-cc-pill")) {
    pill.addEventListener("mouseenter", () => showLayTip(pill, pill.dataset.tip));
    pill.addEventListener("mouseleave", hideLayTip);
    // A click meant for a pill should not collapse the section being read.
    pill.addEventListener("click", (e) => { e.preventDefault(); e.stopPropagation(); });
  }
  summary.appendChild(wrap);
}

// Appended to the card of whatever prompt drew the scores, when the reader has
// asked for that (off by default: the table above is the digestible view, and a
// run with eight models puts ten chips on every card). Returns null when the turn
// was never read, so an unread prompt looks exactly as it did before.
function centeringChips(turnId) {
  if (!showChipsOnCards) return null;
  const reads = turnScores[(turnId || "").trim()];
  if (!reads || !reads.length) return null;

  const wrap = document.createElement("div");
  wrap.className = "pe-cc-scores";
  wrap.innerHTML = `<span class="pe-cc-scores-label">centered</span>` + reads.map(r => {
    const cls = ["pe-cc-chip"];
    if (r.provisional) cls.push("provisional");
    if (r.judger_kind === "feh") cls.push("human");
    const title = [
      `${r.model} at ${turnId}: ${fmtScore(r.score)}`,
      `judged by ${r.judger} (${r.judger_kind})`,
      `reading condition: ${conditionLabel(r)}`,
      r.judger_note,
      r.contested_transcript ? `${r.contested_transcript}\ntranscript: ${transcriptName(r)}` : "",
    ].filter(Boolean).join("\n");
    return `<span class="${cls.join(" ")}" title="${escapeAttr(title)}">
      <span class="pe-cc-chip-model">${escapeHtml(r.label || r.model)}${
        r.contested_transcript ? `<span class="pe-cc-chip-contested">*</span>` : ""}</span>
      <span class="pe-cc-chip-score">${escapeHtml(fmtScore(r.score))}</span>
      <span class="pe-cc-chip-judger">${escapeHtml(judgerShort(r.judger))}</span>
    </span>`;
  }).join("");
  return wrap;
}

function showError(msg) {
  $("pe-cc-content").innerHTML = `<div class="pe-error">${escapeHtml(msg)}</div>`;
}

// Categorize by kind + id (reliable signals across versions):
// - voice_chassis (G*) → gauntlet
// - BU* (belief-update prompts between voice groups) → gauntlet
// - synthesis prompts (P14, PA, P15*) → rethink
// - everything else (P1-P10, F1, F2, CK*) → cc. F2 (the gauntlet lead-in) lives at the bottom of CC.
function sectionOf(item) {
  if (item.kind === "voice_chassis") return "gauntlet";
  if (item.is_voice) return "gauntlet";  // pre-v09 voices: kind="prompt" + is_voice flag.
  const pid = (item.id || "").trim();
  if (/^BU\d*[a-z]?$/i.test(pid)) return "gauntlet";
  if (pid === "P14" || pid === "PA" || /^P15[a-z]?$/.test(pid)) return "rethink";
  return "cc";
}

function renderPane(prompts, voices) {
  // Held for the centeredness toggle, which re-renders the pane in place.
  currentPrompts = prompts;
  currentVoices = voices;

  // All meta + note go inline to the right of the title.
  $("pe-pane-note").textContent = prompts.note ? prompts.note : "";

  const metaParts = [];
  if (prompts.register) metaParts.push(`register: ${prompts.register}`);
  if (prompts.i_tone) metaParts.push(`tone: ${prompts.i_tone}`);
  if (prompts.i_presence) metaParts.push(`presence: ${prompts.i_presence}`);
  if (prompts.date) metaParts.push(`date: ${prompts.date}`);
  $("pe-pane-subtitle").textContent = "";
  $("pe-pane-meta-inline").textContent = metaParts.join(" · ");

  // system_prompt is polymorphic: older runs use a bare string, newer runs use {text, ...}.
  const spData = prompts.system_prompt;
  const sysText = typeof spData === "string"
    ? spData
    : (spData && spData.text) || "";
  const backfillNote = (spData && typeof spData === "object" && spData.backfill_note) || "";
  const spContent = $("pe-system-prompt-content");
  spContent.innerHTML = "";
  renderSystemPromptDelivery(currentRunPath);
  if (sysText) {
    const noteHtml = backfillNote
      ? `<div class="pe-system-backfill-note">${escapeHtml(backfillNote)}</div>`
      : "";
    spContent.innerHTML = `<div class="pe-system-text">${escapeHtml(sysText)}</div>${noteHtml}`;
  } else {
    spContent.appendChild(placeholder("no system prompt declared this run"));
  }

  renderIntent(prompts.intent);

  // Preserve original sequence position (1-indexed) when bucketing.
  const buckets = {cc: [], gauntlet: [], rethink: []};
  (prompts.sequence || []).forEach((item, i) => {
    buckets[sectionOf(item)].push({item, num: i + 1});
  });

  renderCenteringTable(currentRunPath, prompts);

  renderItems(buckets.cc, $("pe-cc-content"), voices, prompts, "cc");
  renderSectionPills("cc", CHUTE_EXIT_TURN);
  renderItems(buckets.gauntlet, $("pe-gauntlet-content"), voices, prompts, "gauntlet");
  renderItems(buckets.rethink, $("pe-rethink-content"), voices, prompts, "rethink");
}

// The system prompt shown for a run is what the qs file DECLARED. For v07-v33 it was
// never delivered: those runners passed it as a top-level "system" key on Ollama's
// /api/chat, which ignores it (only a role:system message is honoured). Saying so on
// the page matters more than anywhere else, because this section is the one place a
// reader would reasonably conclude the model was given this text.
function renderSystemPromptDelivery(runPath) {
  const sub = $("pe-system-prompt-sub");
  const d = manifest?.system_prompt_delivery;
  if (!sub || !d) return;
  // First path segment only, and only the digits directly after its "v". Stripping
  // every non-digit from a nested path like "v09/v09a" yields 909, which sorts as
  // newer than v34 and would mark an undelivered run as delivered.
  const versionNum = (s) => {
    const m = /^v(\d+)/.exec(String(s).split("/")[0]);
    return m ? parseInt(m[1], 10) : NaN;
  };
  const delivered = versionNum(runPath) >= versionNum(d.delivered_from);
  sub.textContent = delivered
    ? "delivered to the model as a system message"
    : "recorded in the qs file, but NOT delivered to the model";
  sub.classList.toggle("pe-system-prompt-undelivered", !delivered);
  sub.title = delivered ? `Delivered from ${d.delivered_from} onward.` : `${d.finding}\n\nVerified: ${d.verified}`;
}

function renderIntent(intent) {
  const container = $("pe-intent-content");
  container.innerHTML = "";
  if (!intent) {
    container.appendChild(placeholder("no intent declared for this run"));
    return;
  }

  // Resolved research question text(s). Registry resolves id → text + (when answered) finding.
  // Each question renders as a Question | What-we-learned row.
  const rqs = (intent.research_questions || []).map(id => {
    const q = (registry?.questions || []).find(rq => rq.id === id);
    return { id, text: q?.text || null, finding: q?.finding || null };
  });
  if (rqs.length) {
    const rqBlock = document.createElement("div");
    rqBlock.className = "pe-intent-rqs";
    rqBlock.innerHTML = rqs.map(rq => `
      <div class="pe-intent-rq">
        <div class="pe-intent-rq-q">
          <div class="pe-intent-rq-text"><span class="pe-intent-rq-prefix">Question:</span> ${
            rq.text
              ? escapeHtml(rq.text)
              : `<span class="pe-intent-rq-unresolved">[unresolved] ${escapeHtml(rq.id)}</span>`
          }</div>
          ${rq.text ? `<div class="pe-intent-rq-id">${escapeHtml(rq.id)}</div>` : ""}
        </div>
        ${findingCellHtml(rq.finding, rq.id)}
      </div>
    `).join("");
    container.appendChild(rqBlock);
  }

  // Hypothesis (pre-run prediction). Empty list = honest absence.
  const hBlock = document.createElement("div");
  hBlock.className = "pe-intent-hypothesis";
  if (intent.hypotheses?.length) {
    hBlock.innerHTML = `<div class="pe-intent-label">Hypothesis</div>` +
      intent.hypotheses.map(h => `<div class="pe-intent-h-text">${escapeHtml(h.text)}</div>`).join("");
  } else {
    hBlock.innerHTML = `<div class="pe-intent-label">Hypothesis</div><div class="pe-intent-h-text pe-intent-h-empty">No explicit pre-run prediction; see notes.</div>`;
  }
  container.appendChild(hBlock);

  // Collapsible: manipulation + program + notes.
  const m = intent.manipulation || {};
  const p = intent.program || {};
  const notes = intent.notes || [];
  const hasDetails = m.changed_from_prior || m.held_constant || p.pillar || p.lens || p.ties_to || notes.length;
  if (hasDetails) {
    const det = document.createElement("details");
    det.className = "pe-intent-details";
    let body = "";
    if (m.changed_from_prior) {
      body += `<div class="pe-intent-field"><div class="pe-intent-field-label">Changed from prior</div><div>${escapeHtml(m.changed_from_prior)}</div></div>`;
    }
    if (m.held_constant) {
      body += `<div class="pe-intent-field"><div class="pe-intent-field-label">Held constant</div><div>${escapeHtml(m.held_constant)}</div></div>`;
    }
    if (p.pillar || p.lens || p.ties_to) {
      const bits = [];
      if (p.pillar) bits.push(`pillar: ${escapeHtml(p.pillar)}`);
      if (p.lens) bits.push(`lens: ${escapeHtml(p.lens)}`);
      if (p.ties_to) bits.push(`ties to: ${escapeHtml(p.ties_to)}`);
      body += `<div class="pe-intent-field"><div class="pe-intent-field-label">Program</div><div>${bits.join(" · ")}</div></div>`;
    }
    if (notes.length) {
      body += `<div class="pe-intent-field"><div class="pe-intent-field-label">Notes</div><ul class="pe-intent-notes">${notes.map(n => `<li>${escapeHtml(n)}</li>`).join("")}</ul></div>`;
    }
    det.innerHTML = `<summary>Manipulation · Program · Notes</summary><div class="pe-intent-details-body">${body}</div>`;
    container.appendChild(det);
  }

  // Backfill footnote (only present when intent was reconstructed post-run).
  if (intent.source?.backfilled) {
    const fn = document.createElement("div");
    fn.className = "pe-intent-backfill-note";
    fn.textContent = `Intent backfilled ${intent.source.backfilled}`;
    container.appendChild(fn);
  }
}

// Optional per-question badge: a small image (in viz/pics/) keyed by RQ id. A viz-only
// decoration, kept out of the gauntlet registry so its data stays asset-path-free.
const FINDING_IMAGES = {
  "RQ-perseveration-attractor": "pow-perseverence-attractor-square-sm.png",
};

// The "What we learned" cell paired with each research question. A finding lives on
// the RQ record in the registry (findings answer questions, not runs), so it surfaces
// on every run whose intent carries that RQ id. Absent finding → "still not sure".
function findingCellHtml(finding, rqId) {
  const status = finding?.status || "open";
  const label = FINDING_STATUS_LABEL[status] || escapeHtml(status);
  const tldr = finding?.tldr;
  const link = finding?.writeup
    ? `<a class="pe-finding-link" href="${escapeAttr(NUGS_GH_BASE + finding.writeup)}" target="_blank" rel="noopener">read ${escapeHtml(finding.writeup.split("/").pop())} →</a>`
    : "";
  const img = FINDING_IMAGES[rqId];
  const imgHtml = img
    ? `<img class="pe-finding-img" src="../pics/${escapeAttr(img)}" alt="perseveration attractor" loading="lazy" />`
    : "";
  return `
    <div class="pe-intent-rq-finding pe-finding pe-finding--${escapeAttr(status)}">
      ${imgHtml}
      <div class="pe-finding-head">
        <span class="pe-finding-label">What we learned</span>
        <span class="pe-finding-status"><span class="pe-finding-dot"></span>${escapeHtml(label)}</span>
      </div>
      ${tldr ? `<div class="pe-finding-tldr">${escapeHtml(tldr)}</div>` : ""}
      ${link}
    </div>`;
}

// The three framework checkpoints, in run order: init (the model's first framework),
// mid (after the stress phase), final (after the gauntlet + rewrite). Manifest carries
// any subset under `stages`. The mid checkpoint was renamed at v17: pre-v17 runs call it
// "stressed" (after a pressure-test); v17+ call it "centered" (after the Centering Chute).
// The label follows the actual filename so legacy runs aren't mislabeled.
const FRAMEWORK_STAGES = [
  { key: "init",  label: "initial", sub: "first draft" },
  { key: "mid",   label: "centered", sub: "after the centering chute" },
  { key: "final", label: "final",   sub: "after the gauntlet" },
];

// Resolve a stage's display (label + sub) given its filename, for the mid-stage rename.
function stageDisplay(stage, filename) {
  if (stage.key === "mid" && /_stressed\.md$/.test(filename || "")) {
    return { label: "stressed", sub: "after the pressure test" };
  }
  return { label: stage.label, sub: stage.sub };
}

// The run's emitted frameworks. Per model, the init→mid→final progression renders as a
// stack of collapsibles, each lazily previewing the head N lines (fetched from the in-repo
// mirror) on first open, plus a link to the fully-rendered file on the public GitHub blob.
function renderFrameworks(run) {
  const container = $("pe-frameworks-content");
  container.innerHTML = "";
  const fws = run.frameworks || [];
  if (!fws.length) {
    container.appendChild(placeholder("no framework files declared for this run"));
    return;
  }

  // One model can carry many stages, and a run can carry many models. To keep the
  // section scannable, each model collapses to a single row (init→mid→final live
  // inside). A single-model run auto-expands so there's nothing to click into.
  const single = fws.length === 1;
  for (const fw of fws) {
    // Backward-compat: an older `final`-only entry still renders as the final stage.
    const stages = fw.stages || (fw.final ? { final: fw.final } : {});
    const present = FRAMEWORK_STAGES.filter(s => stages[s.key]);

    const group = document.createElement("details");
    group.className = "pe-framework-model-group";
    if (single) group.open = true;

    const hint = present.map(s => stageDisplay(s, stages[s.key]).label).join(" · ");
    const summary = document.createElement("summary");
    summary.className = "pe-framework-model-summary";
    summary.innerHTML = `
      <span class="pe-framework-model-name">${escapeHtml(fw.model || "(model)")}</span>
      <span class="pe-framework-model-hint">${escapeHtml(hint)}</span>`;
    group.appendChild(summary);

    const body = document.createElement("div");
    body.className = "pe-framework-model-stages";
    if (present.length) {
      for (const stage of present) body.appendChild(frameworkStageRow(stage, run.path, stages[stage.key]));
    } else {
      body.appendChild(placeholder("no framework stages listed for this model"));
    }
    group.appendChild(body);

    container.appendChild(group);
  }
}

// One collapsible stage row: summary (stage label + sub + GitHub link), lazy head-preview.
function frameworkStageRow(stage, runPath, filename) {
  const mirrorPath = `${runPath}/${filename}`;          // relative to RUN_BASE and the GH mirror base
  const fetchUrl = `${RUN_BASE}/${mirrorPath}`;
  const ghUrl = LANDING_PADS_GH_BASE + mirrorPath;

  const disp = stageDisplay(stage, filename);
  const det = document.createElement("details");
  det.className = "pe-framework";
  det.innerHTML = `
    <summary class="pe-framework-summary">
      <span class="pe-framework-stage-label">${escapeHtml(disp.label)}</span>
      <span class="pe-framework-stage-sub">${escapeHtml(disp.sub)}</span>
      <a class="pe-framework-link pe-framework-link--top" href="${escapeAttr(ghUrl)}" target="_blank" rel="noopener">${escapeHtml(disp.label)}_framework.md (GitHub) →</a>
    </summary>
    <div class="pe-framework-body">
      <div class="pe-framework-preview pe-placeholder">expand to load preview…</div>
      <a class="pe-framework-link" href="${escapeAttr(ghUrl)}" target="_blank" rel="noopener">read the full framework on GitHub →</a>
    </div>`;

  // The top link lives inside <summary>; a click there would otherwise also toggle the
  // details. Stop propagation so it just opens the link (in a new tab).
  det.querySelector(".pe-framework-link--top")
    .addEventListener("click", (e) => e.stopPropagation());

  // Lazy-fetch the preview once, on first expand.
  let loaded = false;
  det.addEventListener("toggle", async () => {
    if (!det.open || loaded) return;
    loaded = true;
    const preview = det.querySelector(".pe-framework-preview");
    try {
      const r = await fetch(fetchUrl);
      if (!r.ok) throw new Error(`${r.status}`);
      const text = await r.text();
      const lines = text.split("\n");
      const headLines = lines.slice(0, FRAMEWORK_PREVIEW_LINES).join("\n");
      const truncated = lines.length > FRAMEWORK_PREVIEW_LINES;
      preview.classList.remove("pe-placeholder");
      preview.innerHTML = `<pre class="pe-framework-md">${escapeHtml(headLines)}</pre>${
        truncated ? `<div class="pe-framework-more">… ${lines.length - FRAMEWORK_PREVIEW_LINES} more lines — open the full file above</div>` : ""
      }`;
    } catch (e) {
      loaded = false; // allow retry on next open
      preview.classList.add("pe-error");
      preview.textContent = `couldn't load preview (${e.message}); the GitHub link still works`;
    }
  });

  return det;
}

const EMPTY_MESSAGES = {
  cc: "no centering prompts this run",
  gauntlet: "no voices this run",
  rethink: "no rethink prompts this run",
};

function setSectionEmptyIndicator(section, isEmpty) {
  // Manages a *transient* empty-state indicator. Tagged with .pe-section-sub-empty
  // so it doesn't collide with a section's persistent subtitle (e.g. "centering chute").
  const summary = document.querySelector(`.pe-${section} > .pe-section-summary`);
  if (!summary) return;
  let sub = summary.querySelector(".pe-section-sub-empty");
  if (isEmpty) {
    if (!sub) {
      sub = document.createElement("span");
      sub.className = "pe-section-sub pe-section-sub-empty";
      summary.appendChild(sub);
    }
    sub.textContent = EMPTY_MESSAGES[section] || "empty";
  } else if (sub) {
    sub.remove();
  }
}

function renderItems(entries, container, voices, prompts, section) {
  setSectionEmptyIndicator(section, entries.length === 0);
  if (!entries.length) {
    container.appendChild(placeholder(EMPTY_MESSAGES[section] || "no items in this section"));
    return;
  }

  // Voice cards sit inside a shaded "chassis-block" container so the for-each visually wraps them.
  // (Pattern borrowed from landing-pads/voices/index.html — .chassis-loop + voices-inset.)
  // If a non-voice item (e.g. BU prompt) interrupts, we close the block and open a new one for the next voice group.
  let chassisBlock = null;
  let headerEmitted = false;
  for (const entry of entries) {
    if (entry.item.kind === "voice_chassis") {
      if (!chassisBlock) {
        chassisBlock = document.createElement("div");
        chassisBlock.className = "pe-chassis-block";
        if (prompts.voice_chassis && !headerEmitted) {
          chassisBlock.appendChild(renderChassisHeader(prompts.voice_chassis));
          headerEmitted = true;
        }
        container.appendChild(chassisBlock);
      }
      chassisBlock.appendChild(voiceCard(entry.item, voices, prompts.voice_chassis, entry.num));
    } else {
      chassisBlock = null;
      container.appendChild(promptCard(entry.item, entry.num));
    }
  }
}

function renderChassisHeader(voiceChassisDef) {
  const wrap = document.createElement("div");
  wrap.className = "pe-chassis-loop";

  if (voiceChassisDef.template) {
    wrap.innerHTML = `
      <div class="pe-chassis-loop-header">for each {voice}:</div>
      <div class="pe-chassis-loop-body">${highlightVars(voiceChassisDef.template)}</div>
    `;
    return wrap;
  }

  const keys = Object.keys(voiceChassisDef).filter(k => voiceChassisDef[k] && typeof voiceChassisDef[k] === "object" && voiceChassisDef[k].template);
  if (keys.length) {
    let inner = `<div class="pe-chassis-loop-header">for each {voice}, alternating:</div>`;
    for (const k of keys) {
      const v = voiceChassisDef[k];
      const label = v.label ? `${k} · ${v.label}` : k;
      inner += `
        <div class="pe-chassis-loop-variant">
          <div class="pe-chassis-loop-key">${escapeHtml(label)}</div>
          <div class="pe-chassis-loop-body">${highlightVars(v.template)}</div>
        </div>
      `;
    }
    wrap.innerHTML = inner;
    return wrap;
  }

  wrap.innerHTML = `<div class="pe-chassis-loop-header">(chassis template not in snapshot)</div>`;
  return wrap;
}

function highlightVars(template) {
  // Escape HTML first, then wrap {var} placeholders in styled spans.
  return escapeHtml(template).replace(/\{([a-z_]+)\}/gi, '<span class="pe-chassis-var">{$1}</span>');
}

function placeholder(text) {
  const d = document.createElement("div");
  d.className = "pe-placeholder";
  d.textContent = text;
  return d;
}

function promptCard(item, num) {
  const d = document.createElement("div");
  d.className = "pe-prompt";
  if (item.snapshot) d.classList.add("snapshot");
  const text = item.text || item.prompt || "(no text)";
  d.innerHTML = `
    <span class="pe-prompt-num">${num}.</span>
    <div class="pe-prompt-text">${escapeHtml(text)}</div>
  `;
  const scores = centeringChips(item.id);
  if (scores) d.querySelector(".pe-prompt-text").appendChild(scores);
  return d;
}

function voiceCard(item, voices, topLevelChassis, num) {
  const slug = item.voice;
  const bio = voices[slug];
  const d = document.createElement("div");
  d.className = "pe-voice-card";

  const display = bio?.display_name || slug;
  const full = bio?.full_name && bio.full_name !== display ? bio.full_name : "";
  const chassisKey = item.chassis || "";
  const chassisLabel = chassisKey && topLevelChassis?.[chassisKey]?.label
    ? `${chassisKey} · ${topLevelChassis[chassisKey].label}`
    : (chassisKey || "");
  const bioText = bio?.bio || "";

  const bioBlock = bioText
    ? `<details><summary>bio</summary><div class="pe-voice-bio">${escapeHtml(bioText)}</div></details>`
    : `<div class="pe-voice-bio missing">(bio not in snapshot for slug "${escapeHtml(slug)}")</div>`;

  d.innerHTML = `
    <div class="pe-voice-head">
      <div>
        <span class="pe-voice-num">${num}.</span>
        <span class="pe-voice-name">${escapeHtml(display)}</span>
        ${full ? `<span class="pe-voice-fullname">${escapeHtml(full)}</span>` : ""}
      </div>
      ${chassisLabel ? `<div class="pe-voice-meta">chassis ${escapeHtml(chassisLabel)}</div>` : ""}
    </div>
    ${bioBlock}
  `;
  // Gauntlet turns (G1, G2...) carry scores too when a read covered the whole run.
  const scores = centeringChips(item.id);
  if (scores) d.appendChild(scores);
  return d;
}

function escapeHtml(s) {
  return String(s ?? "").replace(/[&<>"']/g, c => (
    {"&":"&amp;","<":"&lt;",">":"&gt;","\"":"&quot;","'":"&#39;"}[c]
  ));
}

function escapeAttr(s) {
  return String(s ?? "").replace(/"/g, "&quot;");
}

window.addEventListener("hashchange", () => {
  const h = parseHash();
  if (h) selectRun(h.version, h.run);
});

loadManifest().catch(e => {
  $("pe-pane-subtitle").textContent = "";
  showError(`Manifest load error: ${e.message}`);
});
