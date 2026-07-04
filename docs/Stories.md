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

### Tasks

- [x] **9.0** Create `docs/USER_GUIDE.md` and document **Speech** (continuous, triggers, Audio menu, settings; v1 parity)
- [x] **9.0b** Document **Menus** (all menu-bar items; File, Edit, World, Audio, Window, Help)
- [x] **9.2a** Document **Macros** (what they are, example, Events window; aliases/clicker noted as future)
- [x] **9.4a** Document **Events** (general term; Events window; triggers vs macros overview)
- [ ] **9.1** Worlds & sessions — connecting, world picker, world settings, appearance
- [ ] **9.2** Input & commands — command recall, sticky commands, local commands (macros intro done; see 9.2a)
- [ ] **9.2b** Document **Aliases** — typed command aliases vs macros vs input triggers (Story 10)
- [ ] **9.2c** Document **Macro Clicker** — button palette vs typed aliases (Story 11)
- [ ] **9.3** Output — ANSI colors, scrolling, logging, word wrap (when shipped)
- [ ] **9.4** Events — triggers in depth (matching, gags, audio, replies, variables; events intro done; see 9.4a)
- [ ] **9.5** Preferences overview — map Settings panes and menu items to v1 behavior
- [ ] **9.6** Publish path — link from README and in-app Help (when Help ships)

### Touchpoints

- `docs/USER_GUIDE.md`
- `README.md` (link to guide)

### Acceptance

- A new Savitar 1 user can migrate using the guide alone for documented topics
- Speech section matches actual app behavior and Savitar 1 semantics
- Remaining sections follow the same tone and structure as the speech chapter

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

Stories 10 and 11 are independent tracks; either can ship first.
Story 13 is optional and can ship any time after Story 12.

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
