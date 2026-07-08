# Savitar 2 — Settings & Preferences Stories

_User stories for bringing Savitar 1.x application settings into Savitar 2, plus macOS HIG alignment. See [Savitar2DevNotes](Savitar2DevNotes.md) for broader design history and [HIG.md](HIG.md) for UI requirements._

Savitar 1 spread settings across three surfaces:

| Surface | v1 location | v2 status |
|---------|-------------|-----------|
| **App Settings** | `DoPreferences()` in `CViewAppMac.cp` | Done — HIG toolbar panes (`AppSettingsWindowController`) |
| **Speech** | `DoSpeechPreferences()` | Done — Settings → Speech pane (Story 4) |
| **ANSI Color Settings** | `EditColors()` | Done — Settings → Colors pane (Story 5) |

The prefs **data model** already imports v1 flags and values. **Stories 1, 4, and 5** are complete; **Story 2** is partially complete (see below). **Stories 6–8** track HIG and UI backlog from [HIG.md](HIG.md). **Stories 9–19** cover the user guide, feature backlog, analytics, help delivery, and web cross-links.

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

**Status:** Partially complete — keypad, mono fonts, mute bell, and default word wrap are wired; clicker remains.

### Tasks

- [x] **2.1** **Use keypad** — honor `useKeypad` in macro hotkey / input handling (v1: keypad chord entry)
- [x] **2.2** **Mono fonts only** — filter font menus when `monoFontsOnly` is set (v1: `UFontMenu::Initialize`)
- [x] **2.3** **Default word wrap** — apply `defaultWordWrap` to new session input/output panes at connect time (`Session.wordWrapEnabled`, `WordWrapFormatting`)
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
| `defaultWordWrap` | `Session.wordWrapEnabled`, `InputViewController`, `OutputView` (CSS via `WordWrapFormatting`) |

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

## Story 4 — Speech pane polish ✅

**Goal:** Minor cleanup; speech settings now live in the Settings window **Speech** pane (HIG). `SpeechPrefsViewController` is built programmatically and embedded as a child view controller.

**Status:** Complete (July 2026).

### Tasks

- [x] **4.0** Fold Speech into app Settings window (Audio → Speech… opens Settings → Speech pane)
- [x] **4.1** Confirm rate/voice/enabled persist and apply during continuous speech
- [x] **4.2** Save speech prefs on change (match App Settings live-save pattern)
- [x] **4.3** Rebuild Speech pane with Auto Layout; removed `SpeechPrefs.storyboard`
- [x] **4.4** Document macOS 10.15+ requirement in Help or prefs footnote (UI footnote + [USER_GUIDE.md](USER_GUIDE.md#speech) Speech chapter)

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

- [x] **6.1** Document intended HIG role (utility / auxiliary window vs. document window) in `HIG.md`
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

**Status:** In progress (July 2026) — beta-critical chapters are in [USER_GUIDE.md](USER_GUIDE.md) and bundled in-app (Stories 16–17). Remaining work: session window depth, triggers in depth, local commands, glossary, full Getting started front matter, and settings consolidation (9.5).

**Source:** The [Savitar 1.4 User's Manual](http://heynow.com/savitar/manual140.html) (last updated 2009) is the content blueprint. Savitar 2's guide should cover the same *topics* with updated menu paths, HIG Settings layout, and honest notes where features are deferred (MCP, file upload, Macro Clicker, status bar, xch_cmd).

### v1 manual → v2 guide map

| v1 manual chapter | v2 guide chapter | Status | Story task |
|-------------------|------------------|--------|------------|
| **1. General Information** | *Front matter* — what Savitar is, who it's for, system requirements, v1→v2 migration blurb | Partial | **9.1** (quick start ✅ **9.1c**; intro/migration TBD) |
| **2. Installing** | *Install & update* — download, first launch, Sparkle updates, prefs import | Partial | **9.1b** (Updates/Sparkle ✅; download/install TBD) |
| **3. Quick Start** | *Quick start* — connect to a world in five steps | Done | **9.1c** |
| **4. Understanding Savitar** | Split across session, input, output, triggers, macros chapters | Partial | **9.2–9.4** (menus, macros, events, World Settings Input; session/triggers depth TBD) |
| **5. Settings** | Settings + world settings reference | Partial | **9.5** (per-pane chapters ✅; Startup pane + v1 mapping tables TBD) |
| **6. Local Commands** | Local commands reference | Not started | **9.2d** |
| **7. Useful Tips** | Tips, diagnostics, performance | Not started | **9.7** |
| **8. Glossary** | Glossary (MUD, trigger, macro, ANSI, …) | Not started | **9.8** |
| **9. In Closing** | Bug reporting, links | Partial | **9.9** (Help/Privacy ✅ Stories 16–18; Send Feedback — Story 15) |

### Writing principles (v1 manual → v2 guide)

- **Task-first, not dialog-first.** v1 walked screenshot-by-screenshot through PowerPlant dialogs; v2 leads with what the user is trying to do, then where to click (Settings toolbar panes, World Settings sheet, Events window).
- **Parity callouts.** When behavior matches v1, say so explicitly (already the pattern in the Speech chapter). When it differs (Edit → Speech vs Audio → Start Speaking, Settings vs scattered prefs dialogs), note the v1 path in a footnote or table.
- **Ship when the feature ships.** Defer MCP, upload, Macro Clicker, status bar, and xch_cmd sections until implemented—or document them as "not in Savitar 2 yet" with a one-line v1 summary so migrators aren't left guessing.
- **Cross-link, don't duplicate.** Menus chapter stays the command index; feature chapters (Triggers, Speech) link back rather than re-list every shortcut.
- **One tone.** Player-facing prose, tables for reference material, tips at chapter ends—match the existing Speech and Menus chapters.

### Tasks

#### Done

- [x] **9.0** Create `docs/USER_GUIDE.md` and document **Speech** (continuous, triggers, Audio menu, settings; v1 parity)
- [x] **9.0b** Document **Menus** (all menu-bar items; File, Edit, World, Audio, Window, Help — includes Find, Print, scroll lock)
- [x] **9.1c** **Quick start** — five-step connect flow in [Getting started](USER_GUIDE.md#getting-started); contextual **?** callout
- [x] **9.2a** Document **Macros** (what they are, example, Events window; aliases/clicker noted as future)
- [x] **9.3b** **ANSI colors** — Settings → Colors pane; grid, Restore Defaults, vs World Settings Appearance
- [x] **9.3c** App Settings panes — [Input & Display](USER_GUIDE.md#input-display), [Audio](USER_GUIDE.md#audio), [Updates](USER_GUIDE.md#updates) (Sparkle + automatic updates pref)
- [x] **9.4a** Document **Events** (general term; Events window; triggers vs macros overview)
- [x] **9.5a** **World Settings** chapter — Starting, Appearance, Input, Output tabs ([USER_GUIDE.md#world-settings](USER_GUIDE.md#world-settings))
- [x] **9.5b** Per-pane App Settings chapters — Speech, Colors, Input & Display, Audio, Updates (Startup pane chapter still TBD)
- [x] **9.9a** **Getting help** + **Privacy & usage statistics**; Help menu table (Send Feedback deferred to Story 15)
- [x] **9.10** **Publish path** — README link; in-app Help book (Story 16); contextual **?** (Story 17); interim **Savitar Guide on the Web…** → GitHub

#### Chapter stories (from v1 manual)

- [ ] **9.1** **Getting started** — v1 §1 + §3 *(partial: **9.1c** quick start shipped)*
  - What Savitar is (MUD/MUSH/MOO telnet client); link to [JOURNEY.md](JOURNEY.md) for the rewrite story, not the whole history
  - System requirements (macOS 10.12+, 64-bit; v1 Catalina cutoff)
  - Migrating from Savitar 1: prefs import, read-only v1 worlds, save-as-v2
  - *Acceptance:* A new user can connect without reading anything else

- [ ] **9.1b** **Install & updates** — v1 §2 + Story 12 *(partial: [Updates](USER_GUIDE.md#updates) chapter shipped)*
  - Download from GitHub Releases; drag to Applications
  - ~~Sparkle **Check for Updates…**, automatic updates pref, release notes source~~ ✅ in Updates chapter
  - Uninstall = quit and trash (no Classic installer)
  - *Acceptance:* Matches actual distribution; links to [fastlane README](../client/fastlane/README.md) only in a developer footnote if at all

- [ ] **9.2** **The session window** — v1 §4 "Session Window"
  - Output pane vs input pane; resizing (grow box, divider bar when shipped)
  - Scroll lock (⌃S, title-bar button) — cross-link Menus
  - Output navigation keys (Home, End, Page Up/Down, ⌘K clear)
  - Status bar — **deferred** until README item ships; stub one sentence + link to future **9.2d** `set status`
  - *Acceptance:* Matches `WindowController` / world window as shipped

- [ ] **9.2b** **Entering commands** — v1 §4 "Entering Commands" *(partial: echo, sticky, markers, CR/LF in World Settings Input; scroll lock in Menus)*
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

- [ ] **9.3** **Output & appearance** — v1 §4 output + §5 Appearance/Output tabs *(partial: Appearance tab + session logging in World Settings)*
  - ANSI interpretation, intense/bold/blink handling (World Settings → Appearance)
  - HTML tags, `<xch_cmd>` — document or mark **not yet** per README
  - Buffer size, flush period, pane dimensions (World Settings → Output)
  - Session logging vs text documents (cross-link Menus → Text documents)
  - Word wrap — default for new sessions via Settings → Input & Display (Story 2.3); per-session toggle deferred
  - *Acceptance:* User can fix "gibberish ANSI" and "invisible white-on-white text"

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

- [ ] **9.5** **Settings reference** — v1 §5 *(partial: per-pane chapters shipped; consolidation tables TBD)*
  - **App Settings** toolbar panes → v1 `DoPreferences()` mapping table (Startup, Input & Display, Colors, Audio, Updates, Speech)
  - **World Settings** sheet tabs → v1 Starting, Appearance, Input, Output, MCP, Closing
  - Grayed-out prefs explained (Macro Clicker startup, word wrap, mute clicker) — partially covered in Input & Display / Audio chapters
  - Dedicated **Startup** settings pane chapter (World Picker / Events / Macro Clicker at launch)
  - *Acceptance:* One table per settings surface; v1 menu path in a "was" column

- [ ] **9.6** **Worlds & connection** — v1 §4 "Switching Worlds" + §5 Starting tab *(partial: Starting tab + World Picker via Menus/quick start)*
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

- [ ] **9.9** **Help & feedback** — v1 §9 *(partial: **9.9a** shipped; **Send Feedback…** — Story 15)*
  - Update Getting help when Story 15 ships
  - *Acceptance:* Matches Help menu; honest about feedback path

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

1. ~~**9.1c** quick start~~ ✅ — expand **9.1** front matter (what Savitar is, requirements, v1 migration)
2. **9.2 + 9.4 + 9.4b** — session window and triggers depth (biggest remaining gap for power users)
3. **9.2b + 9.2c** — command entry, recall, variables (extends macros chapter)
4. **9.6** — World Picker wizard, multi-session, connection troubleshooting
5. **9.5** — settings consolidation tables + Startup pane chapter
6. **9.3** — output depth (buffer/flush/dimensions; HTML/xch_cmd stubs)
7. **9.2d** — local commands (grows as commands ship)
8. **9.1b** — download/install (Updates chapter done; add first-run install)
9. **9.7, 9.8** — tips, glossary
10. **9.9** — finish when Story 15 ships Send Feedback
11. **9.2e, 9.2f** — when Stories 10–11 land

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

**Status:** Shipped (July 2026, v2.0.17+). End-to-end update install test (**12.7**) remains.

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
- [x] **12.8** User guide (Story 9): document how updates work and where release
      notes come from — [Updates](USER_GUIDE.md#updates) chapter.

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

**Status:** Shipped (July 2026, v2.0.18). Website privacy page remains Story 19 / heynow_websites W9.

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

- [x] **14.1** **TelemetryDeck account & app** — create org at telemetrydeck.com; create app **Savitar** (macOS); copy App ID for CI.
- [x] **14.2** **Swift Package** — add `https://github.com/TelemetryDeck/SwiftSDK` to `Savitar2.xcodeproj` (Up to Next Major); link **TelemetryDeck** product to Savitar target only (not test target).
- [x] **14.3** **`SavitarTelemetry` wrapper** — `initializeIfConfigured()` reads App ID from `Info.plist` key `TelemetryDeckAppID` (empty in Debug/local → no-op); skip when `isRunningTests`; call from `AppDelegate.applicationDidFinishLaunching` after prefs load.
- [x] **14.4** **Signals** — send `Savitar.launched` with version params; set `Savitar.firstLaunch` once using `UserDefaults` key `SavitarHasLaunchedBefore`.
- [x] **14.5** **CI injection** — add `TELEMETRYDECK_APP_ID` to GitHub **`release`** environment secrets; release workflow passes it into the Xcode build as `TELEMETRYDECK_APP_ID` (via `Info.plist`). Local/dev builds without the secret send nothing.
- [x] **14.6** **Test mode** — `#if DEBUG` use TelemetryDeck test mode (or omit App ID) so developer sessions do not pollute production dashboards ([Swift setup guide](https://telemetrydeck.com/docs/guides/swift-setup/)).
- [x] **14.7** **Privacy** — in-app: `USER_GUIDE.md` **Privacy & usage statistics** + **Help → About Privacy…** (Story 18). **Website:** dedicated page — Savitar2 **Story 19** / heynow_websites **W9** (not yet published).
- [x] **14.8** **Docs** — add `TELEMETRYDECK_APP_ID` row to `client/fastlane/README.md` CI secrets table; note in README beta checklist when shipped.

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

## Story 15 — Send Feedback (email)

**Goal:** Give **non-developer** players a frictionless way to report problems and suggest improvements — without a GitHub account.

**Context:** Savitar’s audience is MUD players and v1 migrants, not repo contributors. Savitar 1 directed users to **email Jay** and the heynow.com conference; that model still fits. GitHub Issues remain the **maintainer’s** triage backlog (you file issues from email when appropriate). This story satisfies the README alpha item *Add bug reporting support*.

**Relationship to Story 16:** Help menu order should encourage **Savitar Help** (user guide) before **Send Feedback…** so users can self-serve common questions first.

### Sketch (Help menu)

```
Help
  Savitar Help              ⌘?
  ─────────────────
  Send Feedback…
  Release Notes…
```

### Tasks

- [ ] **15.1** **`SavitarFeedback` helper** — build `mailto:` URL with UTF-8–safe subject/body; read destination address from `Info.plist` key `SavitarFeedbackEmail` (default `jay@heynow.com` or project-chosen support address).
- [ ] **15.2** **Pre-filled diagnostics** — body includes Savitar version (`CFBundleShortVersionString`), build (`CFBundleVersion`), macOS version (`ProcessInfo`), and labeled sections the user fills in:
  - *What I was trying to do*
  - *What happened*
  - *Bug or feature request?*
- [ ] **15.3** **Help → Send Feedback…** — menu item + `AppDelegate` action; open default mail client via `NSWorkspace.shared.open(url)`. If no mail client is configured, show alert with support email and “copy diagnostics to clipboard” fallback.
- [ ] **15.4** **VoiceOver / accessibility** — menu title and alert strings are plain language (“Send Feedback”, not “File GitHub Issue”).
- [ ] **15.5** **User guide (Story 9.9)** — short “Getting help” section: try Savitar Help first; then Send Feedback; what to include; response expectations; GitHub not required.
- [ ] **15.6** **Maintainer workflow** — document in `CONTRIBUTING.md` (or internal note): email → reproduce → optional GitHub issue; no expectation that reporters use Issues.

### Touchpoints

- New: `client/Savitar2/src/SavitarFeedback.swift` (or extension on `AppDelegate`)
- `client/Savitar2/Base.lproj/Main.storyboard` (Help menu)
- `client/Savitar2/src/AppDelegate.swift`
- `client/Savitar2/Info.plist` (`SavitarFeedbackEmail`)
- `docs/USER_GUIDE.md` (Story 9.9)
- `README.md` (check off bug reporting when shipped)

### Acceptance

- Help → Send Feedback opens Mail with pre-filled version info and structured prompts.
- Works for **bug reports and feature requests** in one flow (user labels which in the body).
- No GitHub login required.
- If Mail is unavailable, user still gets support address + copyable diagnostics.
- Menu appears **below** Savitar Help, separated from Release Notes.

### Out of scope

- In-app bug tracker, screenshot attachment automation, or automatic log upload (consider later with explicit consent).
- GitHub Issues as the in-app destination.
- Sentry crash reporting (README beta item — separate story).

---

## Story 16 — In-app user guide (Help menu)

**Goal:** Wire **[USER_GUIDE.md](USER_GUIDE.md)** into **Help → Savitar Help** (⌘?) so players can learn the app **before** sending feedback (Story 15).

**Context:** Today `showHelp:` is wired in the storyboard but there is no Help Book in the bundle (`Info.plist` lacks `CFBundleHelpBookFolder`). Players only see the guide if they find it on GitHub. Story 9 content work continues in parallel; this story is the **delivery mechanism** — bundle, index, and menu integration.

**v1 parity:** Savitar 1 shipped an online manual at heynow.com; v2 should work **offline in-app** with optional web mirror (Story 9.10 / heynow_websites W4).

### Approach (recommended)

Ship an **Apple Help Book** (`.help` bundle) generated from `docs/USER_GUIDE.md`:

1. Convert Markdown → HTML (build phase script or checked-in HTML updated when guide changes).
2. Run `hiutil` / Help Indexer to produce `SavitarHelp.helpindex`.
3. Set `CFBundleHelpBookFolder` + `CFBundleHelpBookName` in `Info.plist`.
4. Keep **stable anchor IDs** per chapter (`getting-started`, `triggers`, `speech`, …) for Story 17.

**MVP fallback** (if Help Book indexing slips): open bundled HTML in Help Viewer or a simple `NSWindow` + `WKWebView` loading `Guide/index.html` — still satisfies “Savitar Help works”; upgrade to full Help Book in a follow-up task within this story.

### Tasks

- [x] **16.1** **Guide structure** — anchor map in `docs/USER_GUIDE.md` (H2/H3/H4 `id`s) + `ANCHOR_BY_TITLE` in `build_help_book.py`; mirrored in `SavitarHelp.Anchor`.
- [x] **16.2** **Help bundle** — `client/Savitar2/resources/Savitar.help/` with `index.html`, CSS, `Savitar.helpindex`.
- [x] **16.3** **Build integration** — `client/scripts/build_help_book.py` (+ `client/scripts/README.md`); run after guide edits.
- [x] **16.4** **Info.plist** — `CFBundleHelpBookFolder`, `CFBundleHelpBookName`; **Help → Savitar Help** (⌘?) via `HelpGuideWindowController` (not Help Viewer).
- [x] **16.5** **Minimum shippable content** — getting started, speech, menus, events, macros, world settings (all tabs), settings panes (colors, input & display, audio, updates), privacy, getting help.
- [x] **16.6** **Story 9.10** — **Savitar Guide on the Web…** → GitHub `USER_GUIDE.md` interim; heynow.com mirror tracked in W4.
- [x] **16.7** **README** — in-app help checked off in progress list.

### Touchpoints

- `docs/USER_GUIDE.md` (anchor IDs)
- `client/Savitar2/Info.plist`
- `client/Savitar2/Base.lproj/Main.storyboard` (Savitar Help — verify `showHelp:`)
- New: `client/Savitar2/Resources/Savitar.help/**`
- New: build script (e.g. `client/scripts/build-help-book.sh`)
- `docs/HIG.md` (Help menu requirements)
- [heynow_websites STORIES W4](https://github.com/jkoutavas/heynow_websites/blob/main/docs/STORIES.md) (web mirror — coordination only)

### Acceptance

- ⌘? / Help → Savitar Help opens the bundled guide at a sensible home page.
- Guide works **offline** without GitHub.
- At least the **beta-critical** chapters are readable (connect, session, triggers, speech, feedback).
- Anchor IDs are stable enough for Story 17 to link into sections.

### Dependency

- **Story 15** should ship after or with **16.5** minimum content so “read Help first” is honest.
- **Story 9** continues to expand content; Story 16 does not block on every 9.x task being done.

---

## Story 17 — Contextual help (? buttons)

**Goal:** Add **?** help affordances on major UI surfaces that jump to the relevant **user guide anchor** (Story 16).

**Context:** When the guide is tightly integrated (Help Book + stable anchors), users should get **just-in-time** help from the window they’re in — Events, World Settings, Speech prefs, World Picker — without hunting the full manual. Defer until Story 16 anchor map exists.

### Sketch

```
┌─ Events ──────────────────────────────────────── [?] ─┐
│  [Triggers] [Macros] …                               │
```

`?` opens the in-app guide (`HelpGuideWindowController`) at the matching `#anchor` (not macOS Help Viewer).

### Tasks

- [x] **17.1** **Anchor registry** — `SavitarHelp.ContextualSurface` in `SavitarHelpButton.swift`: Events → `events`; App Settings panes → `speech-speech-settings-reference`, `audio`, `getting-started`, `input-display`, `ansi-colors`, `updates`; World Settings tabs → `world-settings-*-tab`; World Picker → `getting-started`; world session → `menus-world-menu`.
- [x] **17.2** **`SavitarHelp` API** — `SavitarHelp.show(anchor:)` + `ContextualSurface.show()` via WKWebView fragment navigation.
- [x] **17.3** **Reusable control** — `SavitarHelpButton.installInTitleBar(of:for:)` and `installInTopTrailingCorner(of:for:)` (World Settings sheet); wired on **Events**, **App Settings** (per pane), **World Settings** (per tab), **World Picker**, **world session window**.
- [x] **17.4** **VoiceOver** — per-surface `accessibilityLabel` (e.g. “Help for Events window”, “Help for Speech settings”).
- [x] **17.5** **User guide** — contextual help noted in Getting started (chapter-top “open from …” copy optional follow-up).

### Touchpoints

- New: `client/Savitar2/src/SavitarHelp.swift`, `SavitarHelpButton.swift`
- `client/Savitar2/Base.lproj/EventsWindow.storyboard`, `AppPrefs.storyboard`, World Settings storyboards, World Picker
- `docs/HIG.md` (contextual help pattern)
- `docs/USER_GUIDE.md` (anchor IDs from Story 16.1)

### Acceptance

- `?` on Events opens the triggers (or events overview) guide section.
- At least **four** major surfaces wired in v1 of this story.
- No dead links — every `?` resolves to an existing anchor or guide home with a sensible fallback.

### Dependency

- **Story 16** (Help book + anchors) — shipped in this epic.

---

## Story 18 — Help → About Privacy

**Goal:** Add **Help → About Privacy…** so users can read analytics and privacy information in-app without hunting the full guide.

**Context:** Story 14 added TelemetryDeck usage statistics; Story 16 put the disclosure in **Privacy & usage statistics** (`#privacy`). A dedicated menu item makes that chapter discoverable for privacy-conscious users and App Store–style transparency expectations. Pairs with Story 14.7.

### Tasks

- [x] **18.1** **Menu item** — **Help → About Privacy…** in `Main.storyboard`; action opens Savitar Help at anchor `privacy`.
- [x] **18.2** **`SavitarHelp.show(anchor:)`** — reuse existing API; no new window type.
- [x] **18.3** **User guide** — document item in Help menu table and Getting help list; privacy chapter already exists (Story 14.7 / guide `#privacy`).

### Touchpoints

- `client/Savitar2/Base.lproj/Main.storyboard`
- `client/Savitar2/src/AppDelegate.swift`
- `docs/USER_GUIDE.md`

### Acceptance

- **Help → About Privacy…** opens Savitar Help scrolled to **Privacy & usage statistics**.
- Works offline (bundled help book).
- Menu order: Savitar Help, Guide on the Web, separator, About Privacy, Release Notes.

### Dependency

- **Story 16** (in-app help + `#privacy` anchor). **Story 14** (content accuracy).

---

## Story 19 — Savitar privacy page on heynow.com (cross-repo)

**Goal:** Publish a **dedicated privacy page** on the Savitar website (`heynow.com/savitar/…`) that mirrors in-app disclosure (Story 18 / guide `#privacy`) for users who prefer the web, App Store review, or search.

**Context:** Story **14.7** noted a web privacy blurb “when published”; Story **18** added **Help → About Privacy…** offline. A stable public URL completes the triangle: in-app help, user guide repo, and marketing site. **Implementation is in [heynow_websites](https://github.com/jkoutavas/heynow_websites)** — Story **W9**; this story tracks **content** and **cross-links** from Savitar2.

### Tasks

- [ ] **19.1** **Content source** — keep `docs/USER_GUIDE.md` **Privacy & usage statistics** as canonical prose, or split to `docs/PRIVACY.md` included in guide + web build (avoid two divergent policies).
- [ ] **19.2** **Coordinate W9** — agree target URL (e.g. `heynow.com/savitar/privacy.html`), page title, and footer/nav placement on the W1 landing page.
- [ ] **19.3** **In-app link (optional)** — when W9 ships, add “Privacy on the web” link in guide `#privacy` and/or **About Privacy…** sheet footer (secondary to offline text).
- [ ] **19.4** **Story 14.7 closure** — mark website portion of 14.7 done when W9 is live.

### Touchpoints

- `docs/USER_GUIDE.md` (`#privacy`)
- [heynow_websites `docs/STORIES.md` — Story W9](https://github.com/jkoutavas/heynow_websites/blob/main/docs/STORIES.md)
- `client/Savitar2/Info.plist` / marketing URLs (only if we add explicit privacy URL later)

### Acceptance

- Public privacy page live at agreed path; content matches in-app **Privacy & usage statistics** (TelemetryDeck, no session text, dev builds).
- Savitar landing page or footer links to it; no contradictory copy elsewhere on `/savitar/`.

### Dependency

- **Story 14** (TelemetryDeck shipped; policy text accurate). **Story 18** (in-app entry point). **heynow_websites W9** (publish). **W1** landing (link target).

---

## Deferred (blocked on other epics)

| Item | Blocked by | v1 reference | Prefs UI |
|------|------------|--------------|----------|
| Show Macro Clicker at startup | Story 11 | `TVPrefFlag_t_StartupClicker` | Grayed out |
| Default word wrap | Story 2.3 ✅ | `TVPrefFlag_t_DefaultWordWrap` | Enabled |
| Mute clicker sounds | Story 11 | `cmd_MuteClicker` | Grayed out |
| Check for updates | Story 12 (Sparkle) ✅ | `CUpdateChecker`, `updatingEnabled` | Enabled |
| Capture file editor popup | File upload / capture (README beta) | `GetLogEditorName()` in `DoPreferences()` | Not in UI |
| Internet Config button | Obsolete (Classic Mac OS) | `cmd_InternetConfig` | Not in UI |

---

## Implementation order (recommended)

1. ~~Story 1 — App Settings UI~~ ✅
2. ~~Story 4 — Speech pane polish~~ ✅
3. ~~Story 5 — ANSI Colors Settings pane~~ ✅
4. ~~Story 12 — Sparkle 2 auto-updates~~ ✅ (*12.7* E2E install test remains)
5. ~~Story 13 — Help → Release Notes~~ ✅
6. ~~Story 14 — TelemetryDeck analytics~~ ✅ (*website* privacy page: Story 19 / W9)
7. ~~Story 16 — In-app user guide (Help menu)~~ ✅
8. ~~Story 17 — Contextual ? help buttons~~ ✅
9. ~~Story 18 — Help → About Privacy~~ ✅
10. **Story 15 — Send Feedback (email)** — next; completes “read Help first, then Send Feedback”
11. **Story 2** — *in progress* (remaining: 2.5 clicker, 2.6 Events sections)
12. **Story 9 — User guide** — ongoing (session window, triggers depth, local commands, glossary, 9.1 front matter, 9.5 consolidation)
13. Story 6 — Events Window HIG
14. Story 7 — World Picker HIG
15. Story 10 — Command aliases
16. Story 11 — Macro Clicker (README beta; unblocks Story 2.5)
17. Story 19 — Savitar privacy page on heynow.com (cross-repo **W9**)
18. Story 8 — SwiftUI Settings spike (optional, post-beta)

Stories 10 and 11 are independent tracks; either can ship first.
**Stories 15 + 16** satisfy README *Add bug reporting support* (15 pending; 16 ✅).
Story 9 content writing continues in parallel with feature work.

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
| Default word wrap | `defaultWordWrap` | Done — Story 2.3 |
| Mute sound / Mute speaking | `muteSound`, `muteSpeaking` | Done (prefs + Audio menu) |
| Mute terminal bell | `muteBell` | Done |
| Mute clicker | `muteClicker` | UI only (grayed out) |
| Check for updates | `updatingEnabled` | Done — Story 12 |
| Capture file editor | `logEditorName` | Deferred |
