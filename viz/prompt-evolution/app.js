// v1 scaffolded by Claude (Opus 4.7), 2026-05-24.
// Fetches manifest.json + per-run setup-snapshot JSONs. Renders nav + right pane.
// Schema reference:
//   prompts.json:   {sequence: [{id,label,part,kind,text|voice,chassis?,snapshot?}], voice_chassis, system_prompt, ...}
//   voices.biographies.json: {voices: {slug: {display_name, full_name, bio}}}
// Manifest reference: {versions: [{id, runs: [{name, path}]}]}. Path is relative to RUN_BASE.

const MANIFEST_URL = "manifest.json";
const RUN_BASE = "../../gauntlet/runs";

const $ = (id) => document.getElementById(id);
let manifest = null;

async function loadManifest() {
  const r = await fetch(MANIFEST_URL);
  if (!r.ok) throw new Error(`manifest ${r.status}`);
  manifest = await r.json();
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
      li.appendChild(a);
    }

    ul.appendChild(li);
  }
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
  $("pe-system-prompt-slot").innerHTML = "";
  ["cc", "gauntlet", "rethink"].forEach(s => $(`pe-${s}-content`).innerHTML = "");

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
  if (sysText) {
    const sp = document.createElement("details");
    sp.className = "pe-system-prompt";
    const noteHtml = backfillNote
      ? `<div class="pe-system-backfill-note">${escapeHtml(backfillNote)}</div>`
      : "";
    sp.innerHTML = `<summary>System prompt</summary><div class="pe-system-text">${escapeHtml(sysText)}</div>${noteHtml}`;
    $("pe-system-prompt-slot").appendChild(sp);
  }

  // Preserve original sequence position (1-indexed) when bucketing.
  const buckets = {cc: [], gauntlet: [], rethink: []};
  (prompts.sequence || []).forEach((item, i) => {
    buckets[sectionOf(item)].push({item, num: i + 1});
  });

  renderItems(buckets.cc, $("pe-cc-content"), voices, prompts, "cc");
  renderItems(buckets.gauntlet, $("pe-gauntlet-content"), voices, prompts, "gauntlet");
  renderItems(buckets.rethink, $("pe-rethink-content"), voices, prompts, "rethink");
}

const EMPTY_MESSAGES = {
  cc: "no centering prompts in this run",
  gauntlet: "no voices this run",
  rethink: "no rethink prompts in this run",
};

function setSectionEmptyIndicator(section, isEmpty) {
  const summary = document.querySelector(`.pe-${section} > .pe-section-summary`);
  if (!summary) return;
  let sub = summary.querySelector(".pe-section-sub");
  if (isEmpty) {
    if (!sub) {
      sub = document.createElement("span");
      sub.className = "pe-section-sub";
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
