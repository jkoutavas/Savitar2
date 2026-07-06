# Savitar 2 — Settings & Preferences Stories

_User stories for bringing Savitar 1.x application settings into Savitar 2, plus macOS HIG alignment. See [Savitar2DevNotes](Savitar2DevNotes.md) for broader design history and [HIG.md](HIG.md) for UI requirements._

Savitar 1 spread settings across three surfaces:

| Surface | v1 location | v2 status |
|---------|-------------|-----------|
| **App Settings** | `DoPreferences()` in `CViewAppMac.cp` | Done — HIG toolbar panes (`AppSettingsWindowController`) |
| **Speech** | `DoSpeechPreferences()` | Embedded in Settings → Speech pane; polish remains (Story 4) |
| **ANSI Color Settings** | `EditColors()` | Data layer only (`ColorMan` in prefs XML); Story 5 |

The prefs **data model** already imports v1 flags and values. **Story 1** is complete; **Story 2** is partially complete (see below). **Stories 4–8** track HIG and UI backlog from [HIG.md](HIG.md).

---

## Story 1 — Expand App Preferences window ✅

**Goal:** Replace the single-checkbox Preferences window with v1-parity startup, input, audio, and update settings.

**Status:** Complete (July 2026). HIG-aligned toolbar panes in `AppSettingsWindowController`.

**Sketch** (toolbar panes; window title matches selected pane):

```
┌─ Startup ─────────────────────────────────────────────────┐
│  [Startup] [Input & Display] [Audio] [Updates] [Speech]     │
│───────────────────────────────────────────────────────────│
│  ☐ Show World Picker at startup                           │
│  ☐ Show Macro Clicker at startup         (grayed out)     │
│  ☐ Show Events Window at startup                          │
└───────────────────────────────────────────────────────────┘
```

### Tasks

- [x] **1.1** Grow `AppPrefs.storyboard` with grouped sections (Startup, Input & Display, Audio, Updates)
- [x] **1.2** Expose `showStartupPicker` (done) and add bindings for remaining `PrefsFlags` in `AppPrefsPresenter`
- [x] **1.3** Add `SetShowEventsWindowAtStartupAction` wired to `startupEventsWindow` (fix misnamed `SetWorldPickerAtStartup` while here)
- [x] **1.4** Add ReSwift actions for `useKeypad`, `monoFontsOnly`, `defaultWordWrap`, `muteClicker`, `muteBell`; save prefs on change
- [x] **1.5** Mirror mute sound / mute speaking checkboxes with existing Audio menu bindings in `AppDelegate`
- [x] **1.6** Disable (gray out) unsupported rows until those features ship; show tooltips (Macro Clicker, word wrap, Mute clicker, Check for updates)
- [x] **1.7** Add `updatingEnabled` checkbox; keep disabled until Sparkle/updater exists

### Touchpoints

- `client/Savitar2/src/views/AppPreferences/AppSettingsWindowController.swift`
- `client/Savitar2/src/views/AppPreferences/AppPrefsViewController.swift`
- `client/Savitar2/src/state/App/AppPreferencesActions.swift`
- `client/Savitar2/src/AppPreferences.swift` (`PrefsFlags`)
- `docs/HIG.md` — HIG requirements for Settings

### Acceptance

- All checkboxes reflect values loaded from v1/v2 prefs XML
- Toggling any checkbox persists immediately to `~/Library/Preferences/Savitar2 Prefs`
- Audio menu mute items stay in sync with App Preferences audio section

---

## Story 2 — Wire preference flags to behavior

**Goal:** Flags that exist in XML but do nothing today actually affect the app.

**Status:** Partially complete — keypad, mono fonts, and mute bell are wired; word wrap and clicker remain.

### Tasks

- [x] **2.1** **Use keypad** — honor `useKeypad` in macro hotkey / input handling (v1: keypad chord entry)
- [x] **2.2** **Mono fonts only** — filter font menus when `monoFontsOnly` is set (v1: `UFontMenu::Initialize`)
- [ ] **2.3** **Default word wrap** — apply `defaultWordWrap` to new session input/output panes
- [x] **2.4** **Mute terminal bell** — suppress or pass through BEL when `muteBell` is set
- [ ] **2.5** **Mute clicker** — honor flag once Macro Clicker exists (Story 11)
- [ ] **2.6** **Events window sections** — wire `trigsClosed` / `varsClosed` to Events window UI state (stretch; not in main prefs window)

### Touchpoints

| Flag | Wired in |
|------|----------|
| `useKeypad` | `Macro.swift`, `HotKey.swift` |
| `monoFontsOnly` | `AppearanceSettingsController.swift` |
| `muteBell` | `TerminalBell.swift`, `OutputView.swift` (see also input PR #47) |
| `muteSound` / `muteSpeaking` | `Session.swift`, `AppDelegate.swift` (Audio menu + prefs) |
| `defaultWordWrap` | *Not yet — needs `World` / session pane support* |

### Acceptance

- Each flag has at least one observable effect when toggled (except blocked items)

---

## Story 3 — ANSI Color Settings window

> **Superseded by Story 5** — ANSI colors should ship as a Settings toolbar pane per [HIG.md](HIG.md), not a separate window. Kept for v1 parity reference.

**Goal:** v1 `EditColors()` parity — edit the 24 ANSI colors stored in `ColorMan`.

**Sketch:**

```
┌─ ANSI Color Settings ─────────────────────────────────────┐
│  Standard (0–7)          Bright (8–15)                    │
│  [swatches...]            [swatches...]                   │
│  [ Restore Defaults ]                                     │
└───────────────────────────────────────────────────────────┘
```

### Tasks

- [ ] **3.1** New `ANSIColors.storyboard` + view controller
- [ ] **3.2** Menu item (e.g. under Edit or Savitar2 menu) to open window
- [ ] **3.3** Bind swatches to `AppContext.shared.prefs.colorMan`
- [ ] **3.4** Restore Defaults → `ColorMan` factory defaults (v1: `CreateColorPreferences`)
- [ ] **3.5** Persist on change via existing prefs `save()`
- [ ] **3.6** Use `colorMan` colors in `Ansi2HtmlParser` / output rendering if not already

### Touchpoints

- `client/Savitar2/src/models/colors/ColorMan.swift`
- `client/Savitar2/src/worldDocument/Ansi2HtmlParser.swift`
- New files under `client/Savitar2/src/views/`

### Acceptance

- User can edit all 24 ANSI colors and see them affect session output
- Colors round-trip through prefs XML like v1

---

## Story 4 — Speech pane polish

**Goal:** Minor cleanup; speech settings now live in the Settings window **Speech** pane (HIG). `SpeechPrefsViewController` is built programmatically and embedded as a child view controller.

### Tasks

- [x] **4.0** Fold Speech into app Settings window (Audio → Speech… opens Settings → Speech pane)
- [x] **4.1** Confirm rate/voice/enabled persist and apply during continuous speech
- [x] **4.2** Save speech prefs on change (match App Settings live-save pattern)
- [x] **4.3** Rebuild Speech pane with Auto Layout; removed `SpeechPrefs.storyboard`
- [ ] **4.4** Document macOS 10.15+ requirement in Help or prefs footnote (already in UI)

### Acceptance

- Speech pane resizes cleanly inside Settings; controls remain usable at minimum pane size
- Voice/rate/enabled changes persist and affect live speech without restarting the app

---

## Story 5 — ANSI Colors Settings pane (HIG) ✅

**Goal:** v1 `EditColors()` parity as a **Colors** toolbar pane in the app Settings window ([HIG.md](HIG.md)). Replaces the separate-window approach in Story 3.

**Status:** Complete (July 2026). **Colors** pane in the app Settings window edits all 24 ANSI colors; the output renderer sources its palette from `colorMan`.

**Sketch (as built):**

```
┌─ Colors ──────────────────────────────────────────────────┐
│  [Startup] [Input & Display] [Colors] [Audio] … [Speech]   │
│───────────────────────────────────────────────────────────│
│              Normal     Dim      Intense                   │
│  Black        [ ]       [ ]       [ ]                      │
│  Red          [ ]       [ ]       [ ]                      │
│  …            …         …         …                        │
│  White        [ ]       [ ]       [ ]                      │
│  [ Restore Defaults ]                                      │
└───────────────────────────────────────────────────────────┘
```

### Tasks

- [x] **5.1** Add **Colors** pane to `AppSettingsPane` + toolbar item (`paintpalette` symbol)
- [x] **5.2** Build `ColorsSettingsViewController` — 24 color wells in an 8×3 grid (hue × Normal/Dim/Intense), matching Savitar 1's three shades per hue
- [x] **5.3** Bind wells to `AppContext.shared.prefs.colorMan`; live-save on change
- [x] **5.4** **Restore Defaults** → `ColorMan` factory defaults (v1: `CreateColorPreferences`), via `AnsiPalette.defaultHex`
- [x] **5.5** Wire output rendering to `colorMan` — `OutputView.setStyle` generates the ANSI CSS from the palette (dim → `.lighter.<hue>`, intense → `.bold`/`.highlighted.<hue>`); no `Ansi2HtmlParser` change needed. Open sessions restyle live via `.savitarColorsChanged`.
- [x] **5.6** Add menu path — **Edit → ANSI Colors…** opens Settings → Colors
- [x] **5.7** Settings window auto-fits the Colors pane (`resizeToFitCurrentPane`)

### Touchpoints

- `client/Savitar2/src/models/colors/AnsiPalette.swift` (new — palette names, shades, defaults)
- `client/Savitar2/src/models/colors/ColorMan.swift` (lookup, `setColor`, `installDefaultsIfNeeded`, `restoreDefaults`)
- `client/Savitar2/src/views/AppPreferences/ColorsSettingsViewController.swift` (new)
- `client/Savitar2/src/views/AppPreferences/AppSettingsWindowController.swift` (`.colors` pane)
- `client/Savitar2/src/views/AppPreferences/AppPrefsViewController.swift` (embed pane)
- `client/Savitar2/src/worldDocument/OutputView.swift` (palette-driven CSS)
- `client/Savitar2/src/worldDocument/WindowController.swift` (live restyle on change)
- `client/Savitar2/src/AppDelegate.swift` + `Base.lproj/Main.storyboard` (menu item)

### Acceptance

- User edits all 24 ANSI colors in Settings → Colors and sees them affect session output immediately ✅
- Colors round-trip through prefs XML like v1 ✅
- No standalone ANSI Colors window remains ✅

---

## Story 6 — Events Window HIG audit

**Goal:** Align the universal and per-world **Events** windows with [HIG.md](HIG.md) utility-window patterns.

**Context:** Events is a modeless utility window (triggers/variables), not app Settings. It currently uses frame autosave, shows minimize+resize chrome with a fixed min=max size, and can open at startup.

### Tasks

- [ ] **6.1** Document intended HIG role (utility / auxiliary window vs. document window) in `HIG.md`
- [ ] **6.2** **Window chrome** — decide minimize/zoom: enable resize with sensible min size, or close-only like Settings; remove contradictory min=max if staying fixed-size
- [ ] **6.3** **First open** — center on screen; evaluate whether frame autosave (`EventsWindowFrame`) should stay or only restore position
- [ ] **6.4** **Window menu** — ensure Events appears in **Window** menu when open (bring to front when buried)
- [ ] **6.5** **Per-world Events** — audit `WindowController.swift` per-document Events windows for same chrome/behavior as universal window
- [ ] **6.6** **Story 2.6** — wire `trigsClosed` / `varsClosed` prefs to Events split-view section collapse state

### Touchpoints

- `client/Savitar2/Base.lproj/EventsWindow.storyboard`
- `client/Savitar2/src/AppContext.swift` (`showUniversalEventsWindow`)
- `client/Savitar2/src/worldDocument/WindowController.swift` (per-world Events)
- `client/Savitar2/src/extensions/NSWindow+Extensions.swift`

### Acceptance

- Events window behavior is documented and consistent (universal + per-world)
- No disabled resize affordances; chrome matches documented intent
- Section open/closed state persists via prefs (2.6)

---

## Story 7 — World Picker HIG audit

**Goal:** Align the **Savitar World Picker** with [HIG.md](HIG.md) for a small, modeless startup/utility window.

**Context:** World Picker opens at startup (optional pref), from **File → New World Document…**, and hosts world list + wizard entry. Currently uses frame autosave; close-only chrome is already correct.

### Tasks

- [ ] **7.1** **First open** — center on screen when no saved frame exists
- [ ] **7.2** **Frame autosave** — evaluate `WorldPickerFrame`: keep position-only vs. drop autosave for fixed-size picker
- [ ] **7.3** **Window title** — confirm title matches menu/command expectations (`Savitar World Picker` or shorten to `World Picker`)
- [ ] **7.4** **Window menu** — list in **Window** menu when open
- [ ] **7.5** **Keyboard** — Escape closes picker when it is key; **⌘W** closes if appropriate for utility window
- [ ] **7.6** **Layout** — Auto Layout audit; window fits content without excess empty space

### Touchpoints

- `client/Savitar2/Base.lproj/WorldPicker.storyboard`
- `client/Savitar2/src/AppContext.swift` (`showWorldPicker`)
- `client/Savitar2/src/views/WorldPicker/` (controllers)

### Acceptance

- Picker opens centered on first launch; size is tight to content
- Window menu and keyboard dismissal match documented HIG behavior

---

## Story 8 — SwiftUI Settings migration (exploratory)

**Goal:** Evaluate migrating from AppKit `AppSettingsWindowController` to SwiftUI `Settings` scene — only if the app adopts SwiftUI app lifecycle.

**Status:** Deferred — not required for alpha/beta. AppKit implementation is the current standard.

### Tasks

- [ ] **8.1** Spike: minimal `@main` SwiftUI app with `Settings { }` scene alongside existing document architecture
- [ ] **8.2** Compare: toolbar pane parity, **⌘,** integration, pane title behavior, macOS 10.14 deployment impact
- [ ] **8.3** Decision doc in `Savitar2DevNotes.md` — migrate, hybrid, or stay AppKit

### Acceptance

- Written recommendation with cost/benefit; no migration unless explicitly approved

---

## Story 9 — User guide (full app documentation)

**Goal:** Ship a complete end-user guide covering all Savitar 2 features at v1 parity, written for players and world builders—not developers.

**Status:** Started — speech, menus, events overview, and macros intro in [USER_GUIDE.md](USER_GUIDE.md).

**Source:** The [Savitar 1.4 User's Manual](http://heynow.com/savitar/manual140.html) (last updated 2009) is the content blueprint. Savitar 2's guide should cover the same *topics* with updated menu paths, HIG Settings layout, and honest notes where features are deferred (MCP, file upload, Macro Clicker, status bar, xch_cmd).

### v1 manual → v2 guide map

| v1 manual chapter | v2 guide chapter | Status | Story task |
|-------------------|------------------|--------|------------|
| **1. General Information** | *Front matter* — what Savitar is, who it's for, system requirements, v1→v2 migration blurb | Not started | **9.1** |
| **2. Installing** | *Install & update* — download, first launch, Sparkle updates, prefs import | Not started | **9.1b** |
| **3. Quick Start** | *Quick start* — connect to a world in five steps | Not started | **9.1c** |
| **4. Understanding Savitar** | Split across session, input, output, triggers, macros chapters | Partial | **9.2–9.4** |
| **5. Settings** | Settings + world settings reference | Partial (speech done) | **9.5** |
| **6. Local Commands** | Local commands reference | Not started | **9.2d** |
| **7. Useful Tips** | Tips, diagnostics, performance | Not started | **9.7** |
| **8. Glossary** | Glossary (MUD, trigger, macro, ANSI, …) | Not started | **9.8** |
| **9. In Closing** | Bug reporting, links | Not started | **9.9** |

### Writing principles (v1 manual → v2 guide)

- **Task-first, not dialog-first.** v1 walked screenshot-by-screenshot through PowerPlant dialogs; v2 leads with what the user is trying to do, then where to click (Settings toolbar panes, World Settings sheet, Events window).
- **Parity callouts.** When behavior matches v1, say so explicitly (already the pattern in the Speech chapter). When it differs (Edit → Speech vs Audio → Start Speaking, Settings vs scattered prefs dialogs), note the v1 path in a footnote or table.
- **Ship when the feature ships.** Defer MCP, upload, Macro Clicker, status bar, and xch_cmd sections until implemented—or document them as "not in Savitar 2 yet" with a one-line v1 summary so migrators aren't left guessing.
- **Cross-link, don't duplicate.** Menus chapter stays the command index; feature chapters (Triggers, Speech) link back rather than re-list every shortcut.
- **One tone.** Player-facing prose, tables for reference material, tips at chapter ends—match the existing Speech and Menus chapters.

### Tasks

#### Done

- [x] **9.0** Create `docs/USER_GUIDE.md` and document **Speech** (continuous, triggers, Audio menu, settings; v1 parity)
- [x] **9.0b** Document **Menus** (all menu-bar items; File, Edit, World, Audio, Window, Help)
- [x] **9.2a** Document **Macros** (what they are, example, Events window; aliases/clicker noted as future)
- [x] **9.4a** Document **Events** (general term; Events window; triggers vs macros overview)

#### Chapter stories (from v1 manual)

- [ ] **9.1** **Getting started** — v1 §1 + §3
  - What Savitar is (MUD/MUSH/MOO telnet client); link to [JOURNEY.md](JOURNEY.md) for the rewrite story, not the whole history
  - System requirements (macOS 10.12+, 64-bit; v1 Catalina cutoff)
  - Migrating from Savitar 1: prefs import, read-only v1 worlds, save-as-v2
  - **Quick start:** World Picker → double-click world → type a command → open Events
  - *Acceptance:* A new user can connect without reading anything else

- [ ] **9.1b** **Install & updates** — v1 §2 + Story 12
  - Download from GitHub Releases; drag to Applications
  - Sparkle **Check for Updates…**, automatic updates pref, release notes source
  - Uninstall = quit and trash (no Classic installer)
  - *Acceptance:* Matches actual distribution; links to [fastlane README](../client/fastlane/README.md) only in a developer footnote if at all

- [ ] **9.2** **The session window** — v1 §4 "Session Window"
  - Output pane vs input pane; resizing (grow box, divider bar when shipped)
  - Scroll lock (⌃S, title-bar button) — cross-link Menus
  - Output navigation keys (Home, End, Page Up/Down, ⌘K clear)
  - Status bar — **deferred** until README item ships; stub one sentence + link to future **9.2d** `set status`
  - *Acceptance:* Matches `WindowController` / world window as shipped

- [ ] **9.2b** **Entering commands** — v1 §4 "Entering Commands"
  - Return sends; Option-Return for multiple lines in macros/triggers/startup scripts
  - Command recall (↑/↓, 32-line buffer); sticky commands (World Settings → Input)
  - Input editing keys (⌃A/E, ⌃U clear, word navigation)
  - Echo input setting; CR vs CR/LF postfix (World Settings → Input)
  - `##wait` in startup/reply chains (v1 local command; document syntax)
  - *Acceptance:* Parity table for v1 editing keys that still work in v2

- [ ] **9.2c** **Variables & macro expansion** — v1 §4 "Macros" (expansion half)
  - `%%name` markers; nesting; trigger-set variables vs macro values
  - Wildcard markers (`$$`) — defer detail to **9.4** triggers chapter
  - Distinct from hotkey macros (already in **9.2a**); cross-link
  - *Acceptance:* User understands `say %%news` vs pressing F5

- [ ] **9.2d** **Local commands** — v1 §6
  - Command marker (`##` default); per-world override in World Settings
  - **Shipped:** `##history` reference with example output
  - **Remaining v1 commands:** table with Implemented / Planned / Not planned columns (`add macro`, `upload`, `tell application`, `regex`, …)
  - *Acceptance:* Every implemented local command documented; deferred ones listed honestly

- [ ] **9.2e** **Aliases** — typed abbreviations (Story 10; not in v1 manual as such)
  - Classical MUD aliases vs v1 "Macro Clicker aliases" vs macros vs input triggers
  - *Blocked on Story 10 implementation*

- [ ] **9.2f** **Macro Clicker** — v1 §4 "Macro Clicker" (Story 11)
  - Button palette, keypad mapping, startup pref
  - *Blocked on Story 11 implementation*

- [ ] **9.3** **Output & appearance** — v1 §4 output + §5 Appearance/Output tabs
  - ANSI interpretation, intense/bold/blink handling (World Settings → Appearance)
  - HTML tags, `<xch_cmd>` — document or mark **not yet** per README
  - Buffer size, flush period, pane dimensions (World Settings → Output)
  - Session logging vs text documents (cross-link Menus → Text documents)
  - Word wrap — when Story 2.3 ships
  - *Acceptance:* User can fix "gibberish ANSI" and "invisible white-on-white text"

- [ ] **9.3b** **ANSI colors** — v1 §5 "ANSI Color Settings"
  - Settings → Colors pane; live preview in session; Restore Defaults
  - Background shift when text matches background color (v1 behavior—verify in code)
  - Cross-link from **9.3**; don't repeat full 24-swatch table
  - *Acceptance:* Matches Story 5 shipped UI

- [ ] **9.4** **Triggers in depth** — v1 §4 "Triggers"
  - Processing order (universal → per-world; top to bottom)
  - Types: output / input / both; match modes: contains, starts with, regex
  - Tabs: Matching, Appearance (gag/color), Audio Cue, Reply
  - Wildcards (`$$`) and regex captures (`%%0`…); `##regex` test command
  - Drag text from panes to create triggers; reorder; import/export via XML/world file
  - Continuous speech dedupes trigger speech (cross-link Speech)
  - *Acceptance:* A v1 power user can recreate a gag + sound + reply trigger from the manual's examples

- [ ] **9.4b** **Editing events** — v1 §4 "Editing Items"
  - In-place rename, double-click editor, ⇧⌘N new item, undo
  - Per-world vs app-wide Events windows
  - *Acceptance:* Covers Events window UX without a screenshot tour

- [ ] **9.5** **Settings reference** — v1 §5
  - **App Settings** toolbar panes → v1 `DoPreferences()` mapping table (Startup, Input & Display, Colors, Audio, Updates, Speech)
  - **World Settings** sheet tabs → v1 Starting, Appearance, Input, Output, MCP, Closing
  - Grayed-out prefs explained (Macro Clicker startup, word wrap, mute clicker)
  - *Acceptance:* One table per settings surface; v1 menu path in a "was" column

- [ ] **9.6** **Worlds & connection** — v1 §4 "Switching Worlds" + §5 Starting tab
  - World Picker: add/edit/remove worlds, wizard
  - Connect/disconnect, autologin commands, keepalive, auto-reconnect
  - Multi-session: one document per world; Window menu switching
  - Quit command on Closing tab
  - *Acceptance:* Covers connection troubleshooting (wrong CR/LF, idle disconnect)

- [ ] **9.7** **Tips & troubleshooting** — v1 §7
  - Diagnostics mindset: lag + flush period, trigger order, marker conflicts on MUX/MUSH (`##` vs `` ` ``)
  - Performance: buffer size, WKWebView output (brief—no architecture essay)
  - *Acceptance:* Short chapter; links into detailed sections above

- [ ] **9.8** **Glossary** — v1 §8
  - MUD, MOO, MUSH, MUVE, ANSI, trigger, macro, event, gag, wildcard, local command, …
  - *Acceptance:* Every jargon term used in the guide is defined here

- [ ] **9.9** **Help & feedback** — v1 §9
  - Bug reports (GitHub issues); forums legacy note; Help → Release Notes
  - In-app Help book when it ships (**9.10**)
  - *Acceptance:* Clear path to report bugs and read changelog

- [ ] **9.10** **Publish path**
  - Link from README ✅; in-app Help book; web publish tracked in [heynow_websites `docs/STORIES.md`](https://github.com/jkoutavas/heynow_websites/blob/main/docs/STORIES.md) Story **W4** (`heynow.com/savitar/guide/`)
  - *Acceptance:* Help menu opens useful content, not an empty stub; guide has a stable public URL when phase 1+ ships

#### Deferred guide sections (blocked on features)

| Topic | v1 manual section | Blocked by | Guide approach |
|-------|-------------------|------------|----------------|
| MCP SimpleEdit | §4 MCP, §5 MCP tab | README `_ MCP` | One paragraph "not in v2 yet" until shipped |
| File upload / capture | §4 Upload/Download, §6 `upload` | README beta | Stub in local commands table |
| Text drag-and-drop to Events | §4 Text Drag and Drop | Verify v2 parity | **9.4b** if implemented |
| HTML / xch_cmd links | §4 HTML, xch_cmd | README `_ xch_cmd` | **9.3** stub |
| Status bar / divider | §4 Status Bar | README `_ Divider status bar` | **9.2** one-liner |
| Web interaction text | §4 Web Interaction | TBD | Defer |
| Switching worlds drag | §4 Switching Worlds | TBD | **9.6** if drag-import still works |

### Suggested writing order

1. **9.1 + 9.1c** — front matter + quick start (gives the guide a proper opening)
2. **9.6 + 9.2** — worlds and session window (the core daily workflow)
3. **9.2b + 9.2c** — input, recall, variables (extends macros chapter)
4. **9.4 + 9.4b** — triggers depth (biggest v1 manual chapter)
5. **9.3 + 9.3b** — output and colors
6. **9.5** — settings reference (consolidation chapter—write after feature chapters exist)
7. **9.2d** — local commands (grows as commands ship)
8. **9.1b, 9.7, 9.8, 9.9** — install, tips, glossary, closing (finish line)
9. **9.2e, 9.2f** — when Stories 10–11 land

### Touchpoints

- `docs/USER_GUIDE.md`
- `README.md` (link to guide)
- [Savitar 1.4 manual](http://heynow.com/savitar/manual140.html) (reference only—not copied verbatim; © Heynow Software)

### Acceptance

- A Savitar 1.6.3 user can migrate using the guide alone for all **shipped** v2 features
- Every v1 manual chapter has a mapped v2 section (written or explicitly deferred)
- Speech section pattern (parity callouts, tables, tips) is the template for all chapters
- No chapter documents unshipped UI as if it exists—deferred items use the table above

---

## Story 10 — Command aliases

**Goal:** Ship **command aliases** — typed abbreviations expanded to full commands before send (classical MUD client behavior).

**Context:** Savitar 2 has **macros** (hotkey → command) and **input triggers** (pattern match on outgoing text with gag/substitution/reply effects). Neither is a classical alias: macros are keyboard shortcuts, not expansion of what you type; input triggers are reactive pattern hooks, not a lookup table of abbreviations. **Macro Clicker** (v1 button palette) is a separate epic — [Story 11](#story-11--macro-clicker).

**Sketch** (Events window, new **Aliases** tab — mirrors Macros):

```
┌─ Events ──────────────────────────────────────────────────┐
│  [Triggers] [Macros] [Aliases] [Variables]                │
│───────────────────────────────────────────────────────────│
│  Name    Abbreviation    Expansion              Enabled   │
│  heal    h               cast heal              ✓         │
│  look    l               look                   ✓         │
└───────────────────────────────────────────────────────────┘
```

**Processing order** (on Return in input pane):

```
typed line → alias expansion → variable expansion (%%) → input triggers → send
```

### Tasks

- [ ] **10.1** **`CommandAlias` model** — `abbreviation`, `expansion`, `enabled`; optional `wholeWord`, `caseSensitive` (defaults: whole-word on, case-insensitive). XML element `CMDALIAS` under group `ALIASES` in world document and app prefs (universal aliases). Use `CMDALIAS` to avoid collision with v1 clicker `ALIAS` XML ([Story 11](#story-11--macro-clicker)).
- [ ] **10.2** **`AliasMan`** — `ModelManager<CommandAlias>`; parse/serialize like `MacroMan` / `TriggerMan`; wire into `World` and universal prefs import/export.
- [ ] **10.3** **Expansion in send path** — in `Session.submitServerCmd` (or `InputViewController` before `determineEffects`): longest-match or first-match expansion of abbreviation tokens in the typed line; honor `enabled`; support semicolon-separated command chains if v1/classical parity requires (stretch: **10.3b**).
- [ ] **10.4** **Do not conflate with input triggers** — aliases expand text and send the result; input triggers remain pattern hooks (gag, reply, audio). Document distinction in code comments and user guide.
- [ ] **10.5** **Events UI** — **Aliases** tab in universal and per-world Events windows; list + detail editor (abbreviation, expansion, enabled, matching options); **Edit → New Alias** (⇧⌘A or similar, when Aliases tab active).
- [ ] **10.6** **Reactions store** — undo/redo for alias add/edit/delete/reorder (follow `MacroReducer` / `TriggerReducer` patterns).
- [ ] **10.7** **Tests** — `AliasManTests`, expansion unit tests (whole-word, case, multiple aliases, no match passthrough).
- [ ] **10.8** **User guide** — Story 9 task **9.2b**: Aliases chapter (vs macros, vs input triggers); cross-link from [Macros](USER_GUIDE.md#macros).

### Touchpoints

- New: `client/Savitar2/src/models/aliases/CommandAlias.swift`, `AliasMan.swift`
- `client/Savitar2/src/models/worlds/World.swift`
- `client/Savitar2/src/worldDocument/Session.swift`, `InputViewController.swift`
- `client/Savitar2/Base.lproj/EventsWindow.storyboard`
- `client/Savitar2/src/state/Reactions/` (reducer, undo)
- `docs/USER_GUIDE.md`

### Acceptance

- User types `h` + Return with alias `h` → `cast heal`; server receives expanded line (after variable expansion and input triggers).
- Aliases persist in `.world` XML and universal prefs; round-trip import/export.
- Events window edits aliases with undo; behavior is documented and distinct from macros and input triggers.

---

## Story 11 — Macro Clicker

**Goal:** Restore v1 **Macro Clicker** window — floating button palette; each slot is a v1-style `ALIAS` (name → macro reference); click sends macro value to frontmost session.

**Context:** Savitar 1 called these entries **aliases** (`ALIAS` XML, `CAliasMan`, `CClickerW`), but they are not classical typed command aliases — see [Story 10](#story-10--command-aliases). README beta item.

**Sketch:**

```
┌─ Macro Clicker ───────────────────────────────────────────┐
│  [↑] [↗] [→] [↘] [↓] [↙] [←] [↖]   (direction icons)     │
│  [1] [2] [3] [4] [5] ...                                  │
│  ─────────────────────────────────────────────────────    │
│  cast heal                          (hover caption)       │
└───────────────────────────────────────────────────────────┘
```

### Tasks

- [ ] **11.1** **`ClickerSlot` model** — v1 `ALIAS` XML: `NAME` attribute maps to macro name; import from Savitar 1 prefs `ALIAS` list (`CAliasMan`, `CTVAlias`). Separate from `CommandAlias` / `CMDALIAS` in Story 10.
- [ ] **11.2** **`ClickerMan`** — fixed slot list (direction + number buttons per v1 `TVAlias_t_*`); parse/serialize v1 `ALIAS` elements from prefs.
- [ ] **11.3** **Macro Clicker window** — modeless utility window; button grid; click → `Session.sendString(macro.value)` on key session; ⌘-click to bind slot to macro (v1: `DoEditButton`).
- [ ] **11.4** **Menu & prefs** — **Window → Macro Clicker** (or Savitar2 menu); enable **Show Macro Clicker at startup** and **Mute clicker sounds** (Story **2.5**); frame autosave (`mClickerPos` / v1 `GetClickerPos`).
- [ ] **11.5** **Assets** — direction / number button icons (v1 cicn resources or SF Symbols).
- [ ] **11.6** **User guide** — Story 9 task **9.2c**: update Macros chapter; distinguish clicker button slots from typed command aliases.

### Touchpoints

- New: `client/Savitar2/src/views/ClickerWindow/` (or similar)
- `client/Savitar2/src/AppContext.swift`, `AppDelegate.swift`
- `client/Savitar2/src/views/AppPreferences/AppPrefsViewController.swift` (un-gray 2.5 / startup clicker)
- v1 reference: `CClickerW.cp`, `CAliasMan.h`, `CTVAlias.cp`

### Acceptance

- Macro Clicker opens from menu and optional startup pref; buttons send bound macro commands to active world session.
- Click sound respects **Mute clicker** pref.
- v1 `ALIAS` entries in imported prefs load into clicker slots.

---

## Story 12 — Sparkle 2 auto-updates

**Goal:** Ship automatic updates via [Sparkle 2](https://sparkle-project.org/), fed
from the existing signed-release pipeline and `CHANGELOG.md`.

**Context:** Savitar 1 used a custom `CUpdateChecker`. Sparkle 2 is the
industry-standard choice for Developer ID–signed, direct-distribution macOS apps.
It integrates via SPM (no CocoaPods), displays release notes in the update sheet
before install, and verifies EdDSA signatures plus code-signing identity on every
download. Release notes come from the same changelog section that already feeds
GitHub Releases — at release time, extract the stamped version into a `.md` file
beside the zip; `generate_appcast` wires it as `releaseNotesLink` automatically.

Sparkle owns **update-time** release notes. A separate in-app "What's new"
welcome pane is intentionally **not** planned (see Story 13 for optional on-demand
access).

**Prerequisite:** Verify at least one successful signed + notarized build through
the `release` workflow (PR #56 / #57) before integrating Sparkle. The updater
must download binaries signed with the same Developer ID identity as the running
app.

**Sketch (Sparkle standard update sheet):**

```
┌─ A new version of Savitar is available! ──────────────────┐
│  Savitar 2.0.16 is now available — you have 2.0.15.       │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ ### Added                                           │  │
│  │ • ANSI Colors settings pane                         │  │
│  │ • Find and Find Next in input and output panes      │  │
│  │ ...                                                 │  │
│  └─────────────────────────────────────────────────────┘  │
│                        [ Install Update ]  [ Skip ]       │
└───────────────────────────────────────────────────────────┘
```

### Tasks

- [x] **12.1** Add Sparkle 2 via SPM (`https://github.com/sparkle-project/Sparkle`).
- [x] **12.2** Initialize `SPUStandardUpdaterController` in `AppDelegate`; add
      **Check for Updates…** to the Savitar menu (wired to
      `updaterController.checkForUpdates()`).
- [x] **12.3** Un-gray and wire **Check for updates automatically** to Sparkle's
      `automaticallyChecksForUpdates` / `automaticallyDownloadsUpdates` (map to
      existing `updatingEnabled` pref).
- [x] **12.4** Generate EdDSA signing keys (`generate_keys`); add `SUPublicEDKey`
      to `Info.plist`; provide feed URL via `SPUUpdaterDelegate` (not only
      `Info.plist`, per Sparkle 2 best practice).
- [x] **12.5** Host `appcast.xml` (e.g. committed under `client/fastlane/release/`
      or GitHub Pages); set `SUFeedURL` / delegate feed URL to its HTTPS location.
- [x] **12.6** Extend the release workflow: after notarization, extract the
      changelog section for the tag into `Savitar-<version>.md` beside the zip,
      run `generate_appcast`, sign the appcast, and publish appcast + deltas.
- [ ] **12.7** End-to-end test: install build N, publish build N+1 via tag, confirm
      Sparkle offers the update, release notes render, install succeeds, and
      `CFBundleShortVersionString` / `CFBundleVersion` compare correctly.
- [ ] **12.8** User guide (Story 9): document how updates work and where release
      notes come from.

### Touchpoints

- `client/Savitar2.xcodeproj` (SPM package)
- `client/Savitar2/src/AppDelegate.swift`
- `client/Savitar2/Info.plist` (`SUPublicEDKey`, version keys)
- `client/Savitar2/Base.lproj/Main.storyboard` (Check for Updates menu item)
- `client/Savitar2/src/views/AppPreferences/AppPrefsViewController.swift` (enable
  `updatingEnabled` checkbox)
- `.github/workflows/release.yml`, `client/fastlane/Fastfile`
- `CHANGELOG.md` → per-release `.md` for `generate_appcast`

### Acceptance

- Check for Updates finds a newer signed build and shows changelog-derived release
  notes in Sparkle's update sheet.
- Automatic update checking respects the `updatingEnabled` pref.
- Downloaded updates pass Sparkle's signature and code-signing verification.
- Release workflow publishes an updated `appcast.xml` on every tagged release.

---

## Story 13 — Help → Release Notes (optional)

**Goal:** On-demand access to version history without running Check for Updates.

**Context:** Sparkle (Story 12) already displays release notes in the update
sheet before install, and offers a Version History path when the user is already
current. This story is **optional polish** — a lightweight escape hatch for
"what changed in past releases?" that does not duplicate Sparkle's update UI or
require a custom changelog parser.

### Tasks

- [x] **13.1** **Help → Release Notes…** menu item opens the GitHub Releases page
      (`https://github.com/jkoutavas/Savitar2/releases`) in the default browser.

### Touchpoints

- `client/Savitar2/Base.lproj/Main.storyboard` (Help menu)
- `client/Savitar2/src/AppDelegate.swift` (menu action)

### Acceptance

- Help → Release Notes opens the releases page; no custom window or parser required.

---

## Story 14 — TelemetryDeck install & usage analytics

**Goal:** Track **active installations** and version adoption with [TelemetryDeck](https://telemetrydeck.com/) — privacy-first, GDPR-friendly analytics on the free **Sparrow** tier (up to 100,000 signals/month).

**Context:** GitHub Release **download counts** measure ZIP pulls, not installs or daily use. TelemetryDeck closes that gap with hashed per-install identifiers and session signals, without collecting personal data. Crash reporting (Sentry) remains a separate future story.

**Not in scope:** Session replay, ad tracking, per-user profiling, or shipping the TelemetryDeck App ID in plaintext for official builds only — inject via CI (see **14.5**).

### Metrics (dashboard)

| Signal | When | Purpose |
|--------|------|---------|
| `TelemetryDeck.Session.started` | Automatic on SDK init | Active users / sessions |
| `Savitar.launched` | `applicationDidFinishLaunching` | App opens with version metadata |
| `Savitar.firstLaunch` | Once per install (UserDefaults flag) | New install proxy |

**Payload parameters (no PII):** `appVersion`, `buildNumber`, `macOSVersion`, `isReleaseBuild` (true when App ID present).

### Tasks

- [ ] **14.1** **TelemetryDeck account & app** — create org at telemetrydeck.com; create app **Savitar** (macOS); copy App ID for CI.
- [ ] **14.2** **Swift Package** — add `https://github.com/TelemetryDeck/SwiftSDK` to `Savitar2.xcodeproj` (Up to Next Major); link **TelemetryDeck** product to Savitar target only (not test target).
- [ ] **14.3** **`SavitarTelemetry` wrapper** — `initializeIfConfigured()` reads App ID from `Info.plist` key `TelemetryDeckAppID` (empty in Debug/local → no-op); skip when `isRunningTests`; call from `AppDelegate.applicationDidFinishLaunching` after prefs load.
- [ ] **14.4** **Signals** — send `Savitar.launched` with version params; set `Savitar.firstLaunch` once using `UserDefaults` key `SavitarHasLaunchedBefore`.
- [ ] **14.5** **CI injection** — add `TELEMETRYDECK_APP_ID` to GitHub **`release`** environment secrets; release workflow passes it into the Xcode build as `INFOPLIST_KEY_TelemetryDeckAppID` (or generated `Secrets.xcconfig` gitignored locally). Local/dev builds without the secret send nothing.
- [ ] **14.6** **Test mode** — `#if DEBUG` use TelemetryDeck test mode (or omit App ID) so developer sessions do not pollute production dashboards ([Swift setup guide](https://telemetrydeck.com/docs/guides/swift-setup/)).
- [ ] **14.7** **Privacy** — one paragraph in `USER_GUIDE.md` (Getting started or Install chapter) and on heynow.com/savitar when published: anonymous usage stats, no account data, link to TelemetryDeck privacy policy.
- [ ] **14.8** **Docs** — add `TELEMETRYDECK_APP_ID` row to `client/fastlane/README.md` CI secrets table; note in README beta checklist when shipped.

### Touchpoints

- New: `client/Savitar2/src/SavitarTelemetry.swift`
- `client/Savitar2/src/AppDelegate.swift`
- `client/Savitar2/Info.plist` (or build setting for `TelemetryDeckAppID`)
- `client/Savitar2.xcodeproj/project.pbxproj`
- `.github/workflows/release.yml`
- `client/fastlane/README.md`
- `docs/USER_GUIDE.md` (privacy blurb)

### Acceptance

- Official signed release builds send `Savitar.launched` and session signals; TelemetryDeck dashboard shows active users and version breakdown within minutes of a test install.
- Local Xcode runs and unit tests send **no** production signals.
- App functions normally when App ID is absent (open-source clones, contributor builds).
- No TelemetryDeck App ID or auth material committed to the public repository.

### Monitoring GitHub ZIP downloads (supplementary)

Download counts are a **ceiling** on installs (re-downloads and CI count too). Useful for trend checks alongside TelemetryDeck.

**Web:** [github.com/jkoutavas/Savitar2/releases](https://github.com/jkoutavas/Savitar2/releases) — each release shows per-asset download counts.

**CLI (latest release):**

```bash
gh api repos/jkoutavas/Savitar2/releases/latest \
  --jq '{tag: .tag_name, zip: [.assets[] | select(.name == "Savitar.zip") | .download_count][0]}'
```

**CLI (all releases with `Savitar.zip`):**

```bash
gh api repos/jkoutavas/Savitar2/releases --paginate \
  --jq '.[] | select(.assets | length > 0) | .tag_name as $t | .assets[] | select(.name=="Savitar.zip") | {tag: $t, downloads: .download_count}'
```

**REST (no `gh`):** `GET https://api.github.com/repos/jkoutavas/Savitar2/releases` — each asset has `download_count` (unauthenticated limit 60 req/hr; use a token for heavier polling).

---

## Deferred (blocked on other epics)

| Item | Blocked by | v1 reference | Prefs UI |
|------|------------|--------------|----------|
| Show Macro Clicker at startup | Story 11 | `TVPrefFlag_t_StartupClicker` | Grayed out |
| Default word wrap | `World` / session word-wrap flag (Story 2.3) | `TVPrefFlag_t_DefaultWordWrap` | Grayed out |
| Mute clicker sounds | Story 11 | `cmd_MuteClicker` | Grayed out |
| Check for updates | Story 12 (Sparkle) ✅ | `CUpdateChecker`, `updatingEnabled` | Enabled |
| Capture file editor popup | File upload / capture (README beta) | `GetLogEditorName()` in `DoPreferences()` | Not in UI |
| Internet Config button | Obsolete (Classic Mac OS) | `cmd_InternetConfig` | Not in UI |

---

## Implementation order (recommended)

1. ~~Story 1 — App Settings UI~~ ✅
2. ~~Story 2 — Wire flags~~ — *in progress* (remaining: 2.3 word wrap, 2.5 clicker, 2.6 Events sections)
3. Story 4 — Speech pane polish (Auto Layout, live-save)
4. ~~Story 5 — ANSI Colors Settings pane~~ ✅
5. Story 6 — Events Window HIG
6. Story 7 — World Picker HIG
7. Story 8 — SwiftUI Settings spike (optional, post-beta)
8. Story 9 — User guide (ongoing; speech chapter first)
9. Story 10 — Command aliases (typed abbreviation expansion)
10. Story 11 — Macro Clicker (README beta; unblocks Story 2.5)
11. Story 12 — Sparkle 2 auto-updates (after first successful signed release)
12. Story 13 — Help → Release Notes (optional polish; no parser)
13. Story 14 — TelemetryDeck install & usage analytics (beta; pairs with README crash-reporting item)

Stories 10 and 11 are independent tracks; either can ship first.
Story 13 is optional and can ship any time after Story 12.
Story 14 can ship during beta once a TelemetryDeck app is configured.

Story 3 is retained for reference only; implement Story 5 instead.

---

## Reference — v1 Preferences checkboxes (`DoPreferences`)

| v1 control | `PrefsFlags` / field | v2 status |
|------------|---------------------|-----------|
| Show World Picker at startup | `startupPicker` | Done |
| Show Macro Clicker at startup | `startupClicker` | UI only (grayed out) |
| Show Events Window at startup | `startupEventsWindow` | Done |
| Use keypad | `useKeypad` | Done |
| Mono fonts only | `monoFontsOnly` | Done |
| Default word wrap | `defaultWordWrap` | UI only (grayed out); Story 2.3 |
| Mute sound / Mute speaking | `muteSound`, `muteSpeaking` | Done (prefs + Audio menu) |
| Mute terminal bell | `muteBell` | Done |
| Mute clicker | `muteClicker` | UI only (grayed out) |
| Check for updates | `updatingEnabled` | Done — Story 12 |
| Capture file editor | `logEditorName` | Deferred |
