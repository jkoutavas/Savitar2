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
- [ ] **2.5** **Mute clicker** — honor flag once Macro Clicker exists
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

## Story 5 — ANSI Colors Settings pane (HIG)

**Goal:** v1 `EditColors()` parity as a **Colors** toolbar pane in the app Settings window ([HIG.md](HIG.md)). Replaces the separate-window approach in Story 3.

**Sketch:**

```
┌─ Colors ──────────────────────────────────────────────────┐
│  [Startup] … [Colors] … [Speech]                          │
│───────────────────────────────────────────────────────────│
│  Standard (0–7)          Bright (8–15)                    │
│  [swatches...]            [swatches...]                   │
│  [ Restore Defaults ]                                     │
└───────────────────────────────────────────────────────────┘
```

### Tasks

- [ ] **5.1** Add **Colors** pane to `AppSettingsPane` + toolbar item (`paintpalette` symbol)
- [ ] **5.2** Build `ColorsSettingsViewController` — 24 swatches in two columns (standard / bright)
- [ ] **5.3** Bind swatches to `AppContext.shared.prefs.colorMan`; live-save on change
- [ ] **5.4** **Restore Defaults** → `ColorMan` factory defaults (v1: `CreateColorPreferences`)
- [ ] **5.5** Confirm `Ansi2HtmlParser` / output rendering uses `colorMan` (wire if not already)
- [ ] **5.6** Add menu path to open Settings → Colors (e.g. **Edit → ANSI Colors…** or Savitar2 menu); remove any separate-window entry from Story 3
- [ ] **5.7** Resize Settings window to fit Colors pane; allow zoom if swatch grid needs scroll on small displays

### Touchpoints

- `client/Savitar2/src/views/AppPreferences/AppSettingsWindowController.swift`
- `client/Savitar2/src/views/AppPreferences/AppPrefsViewController.swift`
- `client/Savitar2/src/models/colors/ColorMan.swift`
- `client/Savitar2/src/worldDocument/Ansi2HtmlParser.swift`

### Acceptance

- User edits all 24 ANSI colors in Settings → Colors and sees them affect session output immediately
- Colors round-trip through prefs XML like v1
- No standalone ANSI Colors window remains

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

**Status:** Started — speech and menus chapters in [USER_GUIDE.md](USER_GUIDE.md).

### Tasks

- [x] **9.0** Create `docs/USER_GUIDE.md` and document **Speech** (continuous, triggers, Audio menu, settings; v1 parity)
- [x] **9.0b** Document **Menus** (all menu-bar items; File, Edit, World, Audio, Window, Help)
- [ ] **9.1** Worlds & sessions — connecting, world picker, world settings, appearance
- [ ] **9.2** Input & commands — macros, hotkeys, command recall, sticky commands, local commands
- [ ] **9.3** Output — ANSI colors, scrolling, logging, word wrap (when shipped)
- [ ] **9.4** Events — triggers, variables, audio cues, gags/substitutions
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

## Deferred (blocked on other epics)

| Item | Blocked by | v1 reference | Prefs UI |
|------|------------|--------------|----------|
| Show Macro Clicker at startup | Macro Clicker window (README beta) | `TVPrefFlag_t_StartupClicker` | Grayed out |
| Default word wrap | `World` / session word-wrap flag (Story 2.3) | `TVPrefFlag_t_DefaultWordWrap` | Grayed out |
| Mute clicker sounds | Macro Clicker | `cmd_MuteClicker` | Grayed out |
| Check for updates | Sparkle / updater (README alpha) | `CUpdateChecker`, `updatingEnabled` | Grayed out |
| Capture file editor popup | File upload / capture (README beta) | `GetLogEditorName()` in `DoPreferences()` | Not in UI |
| Internet Config button | Obsolete (Classic Mac OS) | `cmd_InternetConfig` | Not in UI |

---

## Implementation order (recommended)

1. ~~Story 1 — App Settings UI~~ ✅
2. ~~Story 2 — Wire flags~~ — *in progress* (remaining: 2.3 word wrap, 2.5 clicker, 2.6 Events sections)
3. Story 4 — Speech pane polish (Auto Layout, live-save)
4. Story 5 — ANSI Colors Settings pane (README beta item)
5. Story 6 — Events Window HIG
6. Story 7 — World Picker HIG
7. Story 8 — SwiftUI Settings spike (optional, post-beta)
8. Story 9 — User guide (ongoing; speech chapter first)

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
| Check for updates | `updatingEnabled` | UI only (grayed out) |
| Capture file editor | `logEditorName` | Deferred |
