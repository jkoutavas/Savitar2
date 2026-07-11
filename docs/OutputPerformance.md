# Output scrollback & scroll performance

Internal engineering notes for Savitar 2 session **output** (`OutputView` / `WKWebView`).

**Schedule:** Implement at **start of beta** (Savitar 2 is practically v1 feature-complete on the 2.0 track; this work gates comfortable long-session play during beta dogfooding). Track tasks in [Story 27](Stories.md#story-27--output-scrollback--performance).

---

## Policy summary

| v1 field / UI | Status | Notes |
|---------------|--------|-------|
| **Flush period** (`FLUSHTICKS`) | **Dead** | Timer-tick batching for a native text engine. Replaced internally by per-run-loop / per-frame append coalescing — never user-configurable, never read from XML at runtime. |
| **Buffer size** (`OUTPUTMAX` / `OUTPUTMIN`) | **Honor internally** | Scrollback cap and trim target. Keep XML import/export; **no World Settings UI**. At beta, wire silent DOM trim using per-world values (defaults ~100KB / ~25KB). |
| **Buffer / flush Settings UI** | **Won't do** | Poor fit for WebKit; see [Decision](#decision-v1-bufferflush-ui-wont-do). |

---

## Architecture (v2)

| Piece | Role |
|-------|------|
| `OutputView` (`WKWebView`) | Renders ANSI/HTML output in a styled page |
| `Ansi2HtmlParser` | Converts escape codes to `<span>` markup before append |
| `output(html:…)` | Appends via `evaluateJavaScript` — new `<div><pre>…</pre></div>` or `innerHTML +=` on an existing `<pre id=N>` |
| `scrollToBottomJavaScript()` | Runs after each append (`behavior: "smooth"` when scroll lock is off) |
| Input pane | `NSTextView` — separate; not covered here |

Today: `OUTPUTMAX`, `OUTPUTMIN`, and `FLUSHTICKS` round-trip in world XML on `World`, but **no runtime code reads them**.

---

## Decision: v1 buffer/flush UI won't do

Savitar 1 exposed:

- **Buffer size** (`OUTPUTMAX` / `OUTPUTMIN`) — scrollback cap and trim target (defaults ~100KB / ~25KB)
- **Flush period** (`FLUSHTICKS`) — timer ticks between painting batched network text (default 30)

Those knobs targeted slow CPUs and cooperative redraw on a native text engine. Savitar 2 uses **WebKit**, which handles large documents and scrolling natively. Exposing bytes and tick counts in World Settings is poor UX and does not map to the WKWebView append model.

**Policy:** No World Settings fields. Implement **internal** behavior at beta (below). `FLUSHTICKS` stays import-only dead weight; `OUTPUTMAX` / `OUTPUTMIN` drive silent trim once Story 27 lands.

---

## Recommended implementation order (beta)

Agreed sequencing for start-of-beta work. Phases 1–2 are code; phase 3 validates them.

### Phase 1 — Quick wins (ship first)

Low risk; no XML semantics required.

1. **Scroll policy** — instant `scrollTop = scrollHeight` during live output; reserve smooth scroll for user-initiated jumps only; optional throttle when appends exceed N/sec.
2. **Coalesce appends** — buffer telnet chunks in `OutputViewController` / `Session`; one JS commit per main run-loop turn (modern replacement for `FLUSHTICKS`).

**Touchpoints:** `OutputView.scrollToBottomJavaScript()`, `OutputViewController.output(string:)`, `Session` read loop.

### Phase 2 — Honor `OUTPUTMAX` / `OUTPUTMIN`

Silent scrollback insurance for long sessions.

3. **Internal scrollback trim** — when estimated DOM/HTML size or block count exceeds `world.outputMax`, remove oldest `<div>` blocks until near `world.outputMin`.
   - Prefer **block-based trim** (drop oldest output wrappers); use byte fields as rough thresholds, not a byte-perfect v1 port.
   - Fallback: v1 defaults when XML omits attributes.
4. **Cheaper DOM append** — avoid unbounded `innerHTML +=` on one `<pre>`; use `insertAdjacentHTML`, split growing lines after a size threshold.

**Touchpoints:** `OutputView.output(html:…)`, new `trimScrollbackIfNeeded()`, `World.outputMax` / `outputMin`.

### Phase 3 — Output diagnostics overlay

Dogfooding and support tooling; ships after or alongside phase 1–2 so metrics reflect real optimizations.

5. **Session diagnostics strip** (optional, off by default) — see [Diagnostics overlay](#diagnostics-overlay-advanced).

### Stretch (only if profiling demands)

- Virtualized output (ring buffer + render window)
- Off-main ANSI→HTML parsing

---

## Diagnostics overlay (advanced)

**Goal:** Local, per-session visibility into output health — **not** “FPS” (WKWebView output is not a game loop). Useful for beta dogfooding, combat-spam reports, and tuning trim thresholds.

### Metrics to show

| Metric | Why |
|--------|-----|
| **Output updates/sec** | Telnet → DOM commits (throughput) |
| **Scrollback blocks** | Count of output `<div>` / `<pre>` wrappers |
| **Est. HTML size** | Rough KB in `document.body` |
| **JS bridge latency** | p50 / p95 ms for `evaluateJavaScript` |
| **Growing line size** | Current append-mode `<pre>` length |
| **Last trim** | Timestamp + amount removed (once phase 2 ships) |

### UI placement (proposed)

- **Settings → Advanced** → “Show output diagnostics” (app-wide debug flag), **or** per-world toggle in World Settings if world-to-world comparison matters (start app-wide).
- **Display:** thin status strip on the session window (debug counterpart to deferred divider status bar).
- **Privacy:** local overlay only — no TelemetryDeck / no upload.

### Story reference

Story 27 task **27.6** in [Stories.md](Stories.md#story-27--output-scrollback--performance).

---

## What to watch for

Use when testing long sessions, combat spam, or user reports of “laggy output.”

### DOM growth

- Each non-append line adds a new `<div>` wrapper + `<pre>` block; append mode grows one `<pre>` via `innerHTML +=`.
- ANSI markup multiplies payload size (many `<span class="…">` per line).
- **Symptom:** Session feels fine for minutes, then scroll/select/find get sluggish after hours.
- **Measure:** DOM node count, `document.body.scrollHeight`, Web Inspector memory; diagnostics strip once shipped.

### JavaScript bridge overhead

- Every telnet chunk can trigger one or more `evaluateJavaScript` calls.
- **Symptom:** High CPU with modest visible text rate.
- **Measure:** Appends per second; bridge latency in diagnostics overlay.

### `innerHTML` concatenation cost

- Appending to an existing `<pre>` copies the entire existing HTML string each time.
- **Symptom:** Prompt-without-newline or heavy append mode lags disproportionately.

### Scroll-to-bottom

- `behavior: "smooth"` on every append fights fast output (addressed in phase 1).

### Regression scenarios

| Scenario | Why it matters |
|----------|----------------|
| AFK overnight in busy world | Unbounded DOM until phase 2 |
| Combat spam (many short lines) | High JS call rate until phase 1 coalesce |
| Prompt without newline (append mode) | Growing `innerHTML` |
| ANSI-heavy room description | Inflated HTML size |
| Word wrap toggle on large buffer | Full reflow (Story 20) |

---

## When to open a PR

- **Beta start:** Story 27 phase 1 + 2 as a single epic (or 1 then 2 in quick succession).
- **After phase 1–2:** phase 3 diagnostics to validate under real MUD load.
- **Stretch goals:** only when diagnostics or Instruments show DOM/bridge still dominant.

---

## Touchpoints

- `client/Savitar2/src/worldDocument/OutputView.swift`
- `client/Savitar2/src/worldDocument/OutputViewController.swift`
- `client/Savitar2/src/worldDocument/Session.swift`
- `client/Savitar2/src/models/worlds/World.swift` (`outputMax`, `outputMin`; `flushTicks` import-only, dead at runtime)
- `client/Savitar2/src/worldDocument/Ansi2HtmlParser.swift`
- `client/Savitar2/src/views/AppPreferences/AdvancedSettingsViewController.swift` (diagnostics toggle — TBD)

---

## Related docs

- [USER_GUIDE.md — Output tab](USER_GUIDE.md#output-tab) — user-facing; no buffer/flush controls
- [Stories.md — Story 27](Stories.md#story-27--output-scrollback--performance)
- [HIG.md — Session window](HIG.md) — word wrap, scroll lock
