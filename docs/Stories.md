# Savitar 2 — Settings & Preferences Stories

_User stories for bringing Savitar 1.x application settings into Savitar 2, plus macOS HIG alignment. See [Savitar2DevNotes](Savitar2DevNotes.md) for broader design history and [HIG.md](HIG.md) for UI requirements._

Savitar 1 spread settings across three surfaces:

| Surface | v1 location | v2 status |
|---------|-------------|-----------|
| **App Settings** | `DoPreferences()` in `CViewAppMac.cp` | Done — HIG toolbar panes (`AppSettingsWindowController`) |
| **Speech** | `DoSpeechPreferences()` | Done — Settings → Speech pane (Story 4) |
| **ANSI Color Settings** | `EditColors()` | Done — Settings → Colors pane (Story 5) |

The prefs **data model** already imports v1 flags and values. **Stories 1, 4, 5, and 23** (app Settings HIG) are complete; **Story 7** (World Picker HIG) and **Story 6** (Events Window HIG) are complete. **Story 2** is partially complete (see below). **Story 8** tracks SwiftUI Settings exploration; **Story 25** (Window menu HIG) is complete. **Story 24** tracks Settings → Advanced maintenance backlog. **Story 26** adds app-wide light/dark appearance (complete). **Stories 9–19** cover the user guide, feature backlog, analytics, help delivery, and web cross-links. **Story 20** (v2.1) improves word-wrap UX beyond v1 pref parity. **Story 21** restores the scrolling-credits About box.

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

**Status:** Partially complete — keypad, mono fonts, mute bell, and default word wrap are wired; clicker remains. `trigsClosed` / `varsClosed` are import-only ([2.6](#story-2--wire-preference-flags-to-behavior) won't do).

### Tasks

- [x] **2.1** **Use keypad** — honor `useKeypad` in macro hotkey / input handling (v1: keypad chord entry)
- [x] **2.2** **Mono fonts only** — filter font menus when `monoFontsOnly` is set (v1: `UFontMenu::Initialize`)
- [x] **2.3** **Default word wrap** — apply `defaultWordWrap` to new session input/output panes at connect time (`Session.wordWrapEnabled`, `WordWrapFormatting`). *v2.0 scope: v1 pref parity only; per-session toggle and live updates → [Story 20](#story-20--session-word-wrap-v21)*
- [x] **2.4** **Mute terminal bell** — suppress or pass through BEL when `muteBell` is set
- [ ] **2.5** **Mute clicker** — honor flag once Macro Clicker exists (Story 11)
- [x] **2.6** **`trigsClosed` / `varsClosed`** — **won't do.** In v1 these flags remembered whether **Universal** and **per-world** outline groups were collapsed in a single Events table (Triggers tab and Macros tab each had disclosure triangles for every connected world). v2 splits that into a **universal** Events window and **per-document** Events windows, each a flat trigger/macro list with no outline groups — window choice replaces group collapse. Flags stay in `PrefsFlags` so v1 prefs XML still loads; no behavior to wire.

### Touchpoints

| Flag | Wired in |
|------|----------|
| `useKeypad` | `Macro.swift`, `HotKey.swift` |
| `monoFontsOnly` | `AppearanceSettingsController.swift` |
| `muteBell` | `TerminalBell.swift`, `OutputView.swift` (see also input PR #47) |
| `muteSound` / `muteSpeaking` | `Session.swift`, `AppDelegate.swift` (Audio menu + prefs) |
| `defaultWordWrap` | `Session.wordWrapEnabled`, `InputViewController`, `OutputView` (CSS via `WordWrapFormatting`) |

### Acceptance

- Each flag has at least one observable effect when toggled (except blocked items and import-only flags: `trigsClosed`, `varsClosed` — [2.6](#story-2--wire-preference-flags-to-behavior) won't do)

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

## Story 6 — Events Window HIG audit ✅

**Goal:** Align the universal and per-world **Events** windows with [HIG.md](HIG.md) utility-window patterns.

**Context:** Events is a modeless utility window (triggers/macros), not app Settings. Fixed 900×400 layout: 440pt list column (all table columns visible) + detail editor filling the remainder; frame autosave restores position on subsequent opens.

**Status:** Complete (July 2026).

### Tasks

- [x] **6.1** Document intended HIG role (utility / auxiliary window vs. document window) in `HIG.md`
- [x] **6.2** **Window chrome** — close-only (no minimize/zoom); removed storyboard min=max fake resize; `EventsWindowController` applies fixed designed content size
- [x] **6.3** **First open** — center when no autosaved frame; keep full frame autosave (`EventsWindowFrame` / per-world `EventsWindowFrame - {title}`)
- [x] **6.4** **Window menu** — Events appears in **Window** menu when open and is reachable via **Show App-wide Events Window** (⇧⌘E); completed with [Story 25](#story-25--window-menu-hig-audit)
- [x] **6.5** **Per-world Events** — `WindowController.showWorldEvents` uses the same `EventsWindowController` chrome and presentation as the universal window
- [x] **6.6** **`trigsClosed` / `varsClosed`** — **won't do** (same rationale as [2.6](#story-2--wire-preference-flags-to-behavior)); Events layout persistence is **frame autosave** (`EventsWindowFrame`), not section-collapse prefs
- [x] **6.7** **Layout** — replaced `NSSplitViewController` with fixed two-column layout (`EventsContentViewController`); Macros detail form built in code with bordered fields

### Touchpoints

- `client/Savitar2/Base.lproj/EventsWindow.storyboard`
- `client/Savitar2/src/views/eventsWindow/EventsContentViewController.swift`
- `client/Savitar2/src/views/eventsWindow/EventsWindowController.swift`
- `client/Savitar2/src/views/eventsWindow/MacroViewController.swift`
- `client/Savitar2/src/AppContext.swift` (`showUniversalEventsWindow`)
- `client/Savitar2/src/worldDocument/WindowController.swift` (per-world Events)
- `client/Savitar2/src/extensions/NSWindow+Extensions.swift`

### Acceptance

- Events window behavior is documented and consistent (universal + per-world) ✅
- No disabled resize affordances; close-only chrome matches documented intent ✅
- Frame position/size persists via `EventsWindowFrame` autosave; first open centers when no saved frame ✅

---

## Story 7 — World Picker HIG audit ✅

**Goal:** Align the **Savitar World Picker** with [HIG.md](HIG.md) for a small, modeless startup/utility window.

**Context:** World Picker opens at startup (optional pref), from **File → New World Document…**, and hosts world list + wizard entry.

**Status:** Complete (July 2026). Programmatic welcome layout (`WorldPickerContentView`), position-only restore, keyboard dismissal.

### Tasks

- [x] **7.1** **First open** — center on screen when no saved frame exists
- [x] **7.2** **Frame autosave** — position-only origin (`WorldPickerFrameOrigin`); dropped full frame autosave
- [x] **7.3** **Window title** — **World Picker** (matches utility window role)
- [x] **7.4** **Window menu** — list in **Window** menu when open
- [x] **7.5** **Keyboard** — **Escape** and **⌘W** close when key
- [x] **7.6** **Layout** — Auto Layout welcome header, two-line world rows, connection detail card, primary **Connect**; window fits content

### Touchpoints

- `client/Savitar2/Base.lproj/WorldPicker.storyboard`
- `client/Savitar2/src/views/worldPicker/WorldPickerWindowController.swift`
- `client/Savitar2/src/views/worldPicker/WorldPickerContentView.swift`
- `client/Savitar2/src/AppContext.swift` (`showWorldPicker`)

### Acceptance

- Picker opens centered on first launch; size is tight to content ✅
- Window menu and keyboard dismissal match documented HIG behavior ✅
- First-run layout reads as a deliberate entry point, not a legacy table dialog ✅

---

## Story 23 — App Settings HIG audit ✅

**Goal:** Consolidate and polish the **app Settings** window per [HIG.md](HIG.md) — toolbar panes, live save, close-only chrome, contextual help, and an **Advanced** maintenance pane.

**Context:** Stories 1, 4, and 5 shipped individual panes; this story tracks cross-cutting HIG compliance and the **Advanced** tab added for factory reset.

**Status:** Complete (July 2026).

### Tasks

- [x] **23.1** **Toolbar** — `NSToolbar` + `.preference` style; icon + label for every pane (Startup through Advanced)
- [x] **23.2** **Chrome** — close-only, non-resizable; window title = active pane name
- [x] **23.3** **Dismissal** — **Escape** and **⌘.** close Settings when key
- [x] **23.4** **First open** — center after `fitContentSize` on first display
- [x] **23.5** **Live save** — no Save/Cancel/Apply; checkbox and color changes persist immediately
- [x] **23.6** **Deferred features** — grayed controls with tooltips (Macro Clicker, Mute clicker)
- [x] **23.7** **Deep links** — **Audio → Speech Settings…** → Speech pane; **Edit → ANSI Colors…** → Colors pane
- [x] **23.8** **Contextual ?** — per-pane help anchor updates on toolbar selection (Story 17)
- [x] **23.9** **Advanced pane** — `gearshape.2` toolbar item; scope copy + **Restore Factory Defaults…** with confirmation ([Story 24.1](#story-24--settings-advanced-maintenance))
- [x] **23.10** **Pane sizing** — `resizeToFitCurrentPane` accounts for widest toolbar label (including **Input & Display** and **Advanced**)

### Touchpoints

- `client/Savitar2/src/views/AppPreferences/AppSettingsWindowController.swift`
- `client/Savitar2/src/views/AppPreferences/AppPrefsViewController.swift`
- `client/Savitar2/src/views/AppPreferences/AdvancedSettingsViewController.swift`
- `client/Savitar2/src/views/AppPreferences/ColorsSettingsViewController.swift`
- `client/Savitar2/src/views/AppPreferences/SpeechPrefsViewController.swift`
- `client/Savitar2/src/AppPreferences.swift` (`loadFactoryDefaults`)
- `client/Savitar2/src/AppContext.swift` (`restoreFactoryDefaults`)
- `docs/HIG.md` — App Settings section

### Acceptance

- Settings behaves as a modeless macOS Settings window across all seven panes ✅
- Factory reset restores bundled defaults without deleting `.world` documents ✅
- HIG requirements are documented; further Advanced actions tracked in Story 24 ✅

---

## Story 24 — Settings → Advanced maintenance

**Goal:** Rare, app-wide maintenance actions live on **Settings → Advanced** — not scattered across other panes or the World Picker.

**Context:** **Restore Factory Defaults** shipped with Story 23. Remaining items depend on their underlying features or are natural companions to import/export.

**Not in scope for Advanced:** `SavitarHasSeenAlphaFeedbackAnnouncement` (first-run UX only), `debug` pref (no player-facing debug mode).

### Tasks

- [x] **24.1** **Restore Factory Defaults…** — reload `StartupPreferences.xml`; reset app prefs, World Picker world list, universal triggers/macros, ANSI colors; clear utility-window positions; confirmation alert
- [ ] **24.2** **Import Savitar 1 Preferences…** — re-read `~/Library/Preferences/Savitar 2.0 Prefs` on demand (triggers, macros, colors, worlds); merge or replace with user choice — *no v1 install required if file still exists*
- [ ] **24.3** **Export preferences…** — write current `Savitar2 Prefs` XML to a user-chosen file (backup / support)
- [ ] **24.4** **Import preferences…** — load a previously exported Savitar 2 prefs file
- [ ] **24.5** **Capture file editor** — `logEditorName` app pref UI when session logging / external editor ships (v1: `DoPreferences` capture editor field)
- [x] **24.6** **`trigsClosed` / `varsClosed`** — **won't do**; no Advanced-pane UI or wiring — see [2.6](#story-2--wire-preference-flags-to-behavior)

### Touchpoints

- `client/Savitar2/src/views/AppPreferences/AdvancedSettingsViewController.swift`
- `client/Savitar2/src/AppPreferences.swift` (v1 + v2 load paths)
- `docs/USER_GUIDE.md` — [Advanced](#advanced) chapter

### Acceptance

- Destructive maintenance is confirmable and documented; pane-local actions (e.g. Colors **Restore Defaults**) stay on their panes
- Import/export round-trips prefs XML without corrupting open sessions (define behavior in 24.3/24.4 tasks when implemented)

---

## Story 25 — Window menu HIG audit

**Goal:** Make the **Window** menu accurate for Savitar 2 — no spurious tab-bar commands, clear paths to reopen utility windows, and consistent listing of open documents and auxiliaries.

**Context:** Savitar 1 opened the World Picker via **File → New** and optional startup pref only — no dedicated Window menu item. Savitar 2 matches that for **File → New World Document…** (⌘N) and **Show World Picker at startup**, but the redesigned World Picker is a **modeless utility window** (like Events). The system **Window** menu (`systemMenu="window"`) also injects **Show/Hide Tab Bar** and related tabbing items even though Savitar does not use tabbed world documents.

**v1 parity note:** A **Window → Show World Picker** command is a **v2 UX improvement**, not v1 parity — documented in USER_GUIDE.

**Status:** Complete (July 2026).

### Tasks

- [x] **25.1** **Disable window tabbing** — `NSWindow.allowsAutomaticWindowTabbing = false` in `applicationDidFinishLaunching` so **Show/Hide Tab Bar** and **Merge All Windows** do not appear
- [x] **25.2** **Show World Picker** — **Window → Show World Picker** added (no shortcut; TBD); reuses `showWorldPickerAction:` → `AppContext.showWorldPicker()`, which brings an open picker forward; mirrors **Show App-wide Events Window** (⇧⌘E)
- [x] **25.3** **⌘N behavior** — decision: **File → New World Document…** (⌘N) opens the **World Picker** (choosing a world is the new-document step); documented in HIG + USER_GUIDE
- [x] **25.4** **Window list hygiene** — World documents (world name), **World Picker**, app-wide/​per-world Events are standard titled windows and list in the Window menu; selecting brings forward
- [x] **25.5** **Minimize / Zoom** — close-only utility windows (World Picker, Settings) use `styleMask = [.titled, .closable]` via `configureAsSettingsWindow`, so **Minimize**/**Zoom** auto-disable; world documents keep both
- [x] **25.6** **Fold Story 6.4** — Events already lists in the Window menu and is reachable via **Show App-wide Events Window**; [Story 6.4](#story-6--events-window-hig-audit) satisfied for the menu-listing portion (Events chrome completed in [Story 6](#story-6--events-window-hig-audit))
- [x] **25.7** **Docs** — [USER_GUIDE.md](USER_GUIDE.md) Window menu table (no tab bar; **Show World Picker**) and [HIG.md](HIG.md) Window menu section updated

### Touchpoints

- `client/Savitar2/Base.lproj/Main.storyboard` (Window menu)
- `client/Savitar2/src/AppDelegate.swift`
- `client/Savitar2/src/AppContext.swift` (`showWorldPicker`, `showUniversalEventsWindow`)
- `client/Savitar2/src/views/worldPicker/WorldPickerWindowController.swift`
- `docs/HIG.md`, `docs/USER_GUIDE.md`

### Acceptance

- Window menu contains no tab-bar or merge-windows items
- User can reopen a closed World Picker from **Window** menu without using **File → New World Document…**
- Open window list matches frontmost windows; utility windows use stable titles
- Behavior documented in HIG and user guide ✅

---

## Story 26 — App-wide appearance (System / Light / Dark)

**Goal:** Let the player choose whether Savitar’s **app chrome** follows the system, stays light, or stays dark — independent of per-world session colors.

**Context:** Savitar 1 had no app-wide appearance preference (`Savitar2DevNotes` lists dark mode as future work). Today Savitar 2 always follows macOS (`NSApp.appearance` unset). That is correct for **System**, but players who want a fixed light or dark shell — or who hit stale layer colors when **Auto** switches overnight — need an explicit control. This story is **app UI chrome only**; it does not change MUD output colors, ANSI palette, or **World Settings → Appearance**.

**Pane decision — Settings → Input & Display (no 8th tab):**

| Pane | Why not |
|------|---------|
| **Startup** | Launch behavior only (World Picker, Events at startup). |
| **Colors** | Terminal **ANSI palette** (24 wells), not window chrome. |
| **Advanced** | Rare maintenance (factory reset, import/export). |
| **World Settings → Appearance** | **Per-world** fonts, fore/back, ANSI interpretation — document windows, not the app shell. |

**Input & Display** already holds app-wide display prefs (`monoFontsOnly`, `defaultWordWrap`). Add an **Appearance** group at the top of that pane (popup: **System**, **Light**, **Dark**). Keep the toolbar tab name **Input & Display** — no rename required; contextual **?** can keep the existing `input-display` anchor.

**v1 parity:** New v2-only pref (default **System**). No v1 XML to import.

**Status:** Complete (July 2026).

### Tasks

- [x] **26.1** **Model** — `AppAppearanceMode` enum (`system`, `light`, `dark`); persist as v2 prefs XML attribute (e.g. `APPAPPEARANCE` on `PREFERENCES`); default `system`; include in `save()` / load paths and factory reset ([Story 24.1](#story-24--settings-advanced-maintenance))
- [x] **26.2** **UI** — `NSPopUpButton` (or segmented control) on **Settings → Input & Display**; live save like other checkboxes; `resizeToFitCurrentPane` if pane grows
- [x] **26.3** **Apply** — set `NSApp.appearance` at launch (`AppDelegate`) and immediately on change (`nil` = System, `.aqua` = Light, `.darkAqua` = Dark); post notification or reuse existing color-change path if other subsystems need refresh
- [x] **26.4** **Layer-backed views** — audit custom `wantsLayer` / `layer?.backgroundColor` fills (World Picker ✅ partial fix; About box; any others) so **System** + Auto light/dark transitions and explicit pref changes re-resolve dynamic colors (`updateLayer`, `viewDidChangeEffectiveAppearance`)
- [x] **26.5** **Out of scope check** — confirm world session `WKWebView` output, ANSI Colors pane, and Sparkle/update UI are unaffected or behave acceptably under forced light/dark
- [x] **26.6** **Docs** — [USER_GUIDE.md](USER_GUIDE.md) **Input & Display** table + short “App appearance vs world appearance” note; [HIG.md](HIG.md) panes table; optional CHANGELOG on ship
- [x] **26.7** **Tests** — `AppPreferencesTests` round-trip save/load; default `system` after factory reset

### Sketch (Input & Display pane)

```
┌─ Input & Display ─────────────────────────────────────────┐
│  Appearance                                                │
│    App appearance:  [ System ▾ ]                         │
│    System follows macOS Auto light/dark.                   │
│                                                            │
│  Input                                                     │
│    ☐ Use keypad for macro entry                            │
│    ☐ Mono fonts only (in font menus)                       │
│    ☐ Default word wrap for new sessions                     │
└────────────────────────────────────────────────────────────┘
```

### Touchpoints

- `client/Savitar2/src/AppPreferences.swift`
- `client/Savitar2/src/state/App/AppPreferencesActions.swift`
- `client/Savitar2/src/views/AppPreferences/AppPrefsViewController.swift` (Input & Display section)
- `client/Savitar2/src/AppDelegate.swift`
- `client/Savitar2/src/HelpGuideWindowController.swift` (help book inherits app appearance)
- `client/Savitar2/src/views/worldPicker/WorldPickerContentView.swift` (layer refresh pattern)
- `client/scripts/build_help_book.py` — `savitar-help.css` dark mode (`prefers-color-scheme`)
- `docs/USER_GUIDE.md`, `docs/HIG.md`

### Acceptance

- **System** matches today’s behavior (follow macOS, including Auto sunrise/sunset)
- **Light** / **Dark** force app chrome regardless of system setting; pref survives relaunch
- Control lives on **Input & Display** — seventh toolbar tab unchanged, no eighth pane
- **Colors**, **World Settings → Appearance**, and session output colors remain conceptually separate in docs
- Forced appearance change updates open utility windows without restart; layer-backed custom views stay readable

### Related

- [Story 7](#story-7--world-picker-hig-audit) — World Picker layer appearance refresh (shipped fix for Auto transition bug)
- [Story 24.1](#story-24--settings-advanced-maintenance) — factory reset restores **System**
- [Story 2](#story-2--wire-preference-flags-to-behavior) — wiring pattern for app-wide prefs (this story adds a new pref, not a `PrefsFlags` bit)

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

**Status:** In progress (July 2026) — beta-critical chapters are in [USER_GUIDE.md](USER_GUIDE.md) and bundled in-app (Stories 16–17). **Getting started**, install, session depth, triggers, local commands, glossary, and settings reference shipped July 2026; aliases/clicker chapters blocked on Stories 10–11.

**Source:** The [Savitar 1.4 User's Manual](http://heynow.com/savitar/manual140.html) (last updated 2009) is the content blueprint. Savitar 2's guide should cover the same *topics* with updated menu paths, HIG Settings layout, and honest notes where features are deferred (MCP, file upload, Macro Clicker, status bar, xch_cmd).

### v1 manual → v2 guide map

| v1 manual chapter | v2 guide chapter | Status | Story task |
|-------------------|------------------|--------|------------|
| **1. General Information** | *Front matter* — what Savitar is, who it's for, system requirements, v1→v2 migration blurb | Done | **9.1** |
| **2. Installing** | *Install & update* — download, first launch, Sparkle updates, prefs import | Done | **9.1b** |
| **3. Quick Start** | *Quick start* — connect to a world in five steps | Done | **9.1c** |
| **4. Understanding Savitar** | Split across session, input, output, triggers, macros chapters | Partial | **9.2–9.4** (session, commands, triggers ✅; MCP/upload stubs) |
| **5. Settings** | Settings + world settings reference | Partial | **9.5** (panes + Startup + reference table ✅; MCP deferred; Closing ✅) |
| **6. Local Commands** | Local commands reference | Partial | **9.2d** (`##history`, `##dump`; v1 table for rest) |
| **7. Useful Tips** | Tips, diagnostics, performance | Done | **9.7** |
| **8. Glossary** | Glossary (MUD, trigger, macro, ANSI, …) | Done | **9.8** |
| **9. In Closing** | Bug reporting, links | Partial | **9.9** (Help/Privacy ✅ Stories 16–18; Send Feedback ✅ Story 15) |

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
- [x] **9.5a** **World Settings** chapter — Starting, Appearance, Input, Output, Closing tabs ([USER_GUIDE.md#world-settings](USER_GUIDE.md#world-settings))
- [x] **9.5b** Per-pane App Settings chapters — Speech, Colors, Input & Display, Audio, Updates, **Startup**
- [x] **9.9a** **Getting help** + **Privacy & usage statistics**; Help menu table (Send Feedback ✅ Story 15)
- [x] **9.10** **Publish path** — README link; in-app Help book (Story 16); contextual **?** (Story 17); interim **Savitar Guide on the Web…** → GitHub

#### Chapter stories (from v1 manual)

- [x] **9.1** **Getting started** — v1 §1 + §3 — what Savitar is, requirements, migration, quick start
- [x] **9.1b** **Install & updates** — v1 §2 + Story 12 — download, first launch, uninstall; Updates chapter for Sparkle
- [x] **9.2** **The session window** — v1 §4 "Session Window" — panes, resize, scroll lock, navigation, connection note; status bar deferred
- [x] **9.2b** **Entering commands** — recall (100 lines), sticky, ⌥Return, editing keys (honest v1 parity gaps)
- [x] **9.2c** **Variables & macro expansion** — `%%` markers, wildcard cross-link
- [x] **9.2d** **Local commands** — `##history`, `##dump`; v1 command status table

- [ ] **9.2e** **Aliases** — typed abbreviations (Story 10; not in v1 manual as such)
  - Classical MUD aliases vs v1 "Macro Clicker aliases" vs macros vs input triggers
  - *Blocked on Story 10 implementation*

- [ ] **9.2f** **Macro Clicker** — v1 §4 "Macro Clicker" (Story 11)
  - Button palette, keypad mapping, startup pref
  - *Blocked on Story 11 implementation*

- [x] **9.3** **Output & appearance** — ANSI, HTML stub, word wrap, logging; v1 buffer/flush UI won't do ([OutputPerformance.md](OutputPerformance.md))
- [x] **9.4** **Triggers in depth** — order, types, matching, wildcards, appearance, audio, reply
- [x] **9.4b** **Editing events** — new/rename/reorder/undo; per-world vs app-wide
- [x] **9.5** **Settings reference** — v1 → v2 mapping tables; Startup pane; MCP deferred; Closing tab shipped
- [x] **9.6** **Worlds & connection** — World Picker, wizard, multi-session, troubleshooting
- [x] **9.7** **Tips & troubleshooting** — short chapter with cross-links
- [x] **9.8** **Glossary** — jargon used in the guide

- [x] **9.9** **Help & feedback** — v1 §9 *(**9.9a** + **Send Feedback…** ✅ Story 15)*

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

1. ~~**9.1c** quick start~~ ✅ — ~~expand **9.1** front matter~~ ✅
2. ~~**9.2 + 9.4 + 9.4b**~~ ✅
3. ~~**9.2b + 9.2c**~~ ✅
4. ~~**9.6**~~ ✅
5. ~~**9.5**~~ ✅ (Startup + reference tables)
6. ~~**9.3**~~ ✅ (v1 buffer/flush won't do — [OutputPerformance.md](OutputPerformance.md))
7. ~~**9.2d**~~ ✅ (grows as commands ship)
8. ~~**9.1b**~~ ✅
9. ~~**9.7, 9.8**~~ ✅
10. ~~**9.9** — Send Feedback~~ ✅
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

**Status:** Shipped (July 2026, v2.0.18). Website privacy page shipped with Story 19 / heynow_websites W9 (`heynow.com/savitar/privacy.html`).

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
- [x] **14.7** **Privacy** — in-app: `USER_GUIDE.md` **Privacy & usage statistics** + **Help → About Privacy…** (Story 18). **Website:** [heynow.com/savitar/privacy.html](https://www.heynow.com/savitar/privacy.html) (Story 19 / heynow_websites W9).
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

## Story 15 — Send Feedback (email) ✅

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

- [x] **15.1** **`SavitarFeedback` helper** — `mailto:` URL with UTF-8–safe subject/body; destination from `Info.plist` key `SavitarFeedbackEmail` (default `jay@heynow.com`).
- [x] **15.2** **Pre-filled diagnostics** — body includes Savitar version, build, macOS version, and labeled sections: *What I was trying to do*, *What happened*, *Bug or feature request?*
- [x] **15.3** **Help → Send Feedback…** — menu item + `AppDelegate` action; `NSWorkspace.shared.open(url)`; alert with support email + “Copy Diagnostics to Clipboard” fallback when Mail is unavailable.
- [x] **15.4** **VoiceOver / accessibility** — plain-language menu title “Send Feedback…” and alert strings.
- [x] **15.5** **User guide (Story 9.9)** — **Getting help** and Help menu table updated; try Savitar Help first, then Send Feedback.
- [x] **15.6** **Maintainer workflow** — `CONTRIBUTING.md` notes email → reproduce → optional GitHub issue.
- [x] **15.7** **Alpha announcement** — one-time modal on first launch after upgrade explains alpha testing, Savitar 1 feature-complete milestone, aliases after 2.0, and **Send Feedback…** / **Savitar Help** entry points.

### Touchpoints

- `client/Savitar2/src/SavitarFeedback.swift`
- `client/Savitar2/Base.lproj/Main.storyboard` (Help menu)
- `client/Savitar2/src/AppDelegate.swift`
- `client/Savitar2/Info.plist` (`SavitarFeedbackEmail`)
- `docs/USER_GUIDE.md` (Story 9.9)
- `README.md` (check off bug reporting when shipped)
- **Local testing:** reset alpha dialog — [client/fastlane/README.md § Local testing tips](../client/fastlane/README.md#local-testing-tips) (`defaults delete com.heynow.savitar2 SavitarHasSeenAlphaFeedbackAnnouncement`)

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

- [x] **17.1** **Anchor registry** — `SavitarHelp.ContextualSurface` in `SavitarHelpButton.swift`: Events → `events`; App Settings panes → `speech-speech-settings-reference`, `audio`, `getting-started`, `input-display`, `ansi-colors`, `updates`, `settings-advanced`; World Settings tabs → `world-settings-*-tab`; World Picker → `worlds-connection-world-picker`; world session → `menus-world-menu`.
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

## Story 19 — Savitar privacy page on heynow.com (cross-repo) ✅

**Goal:** Publish a **dedicated privacy page** on the Savitar website (`heynow.com/savitar/…`) that mirrors in-app disclosure (Story 18 / guide `#privacy`) for users who prefer the web, App Store review, or search.

**Context:** Story **14.7** noted a web privacy blurb “when published”; Story **18** added **Help → About Privacy…** offline. A stable public URL completes the triangle: in-app help, user guide repo, and marketing site. **Implementation is in [heynow_websites](https://github.com/jkoutavas/heynow_websites)** — Story **W9**; this story tracks **content** and **cross-links** from Savitar2.

### Tasks

- [x] **19.1** **Content source** — `docs/USER_GUIDE.md` **Privacy & usage statistics** is canonical prose; heynow_websites W9 renders matching web copy (no separate `PRIVACY.md`).
- [x] **19.2** **Coordinate W9** — live at `https://www.heynow.com/savitar/privacy.html`; footer link on Savitar 2 landing page.
- [x] **19.3** **In-app link** — “Privacy on the web” in guide `#privacy` and **Getting help**; links to `heynow.com/savitar/privacy.html`.
- [x] **19.4** **Story 14.7 closure** — website portion of 14.7 marked done (July 2026).

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

## Story 20 — Session word wrap (v2.1)

**Goal:** Make word wrap practical for daily use — toggle it live per session, optionally remember a per-world default, without requiring close/reopen. Keeps Story **2.3** as v1 **`TVPrefFlag_t_DefaultWordWrap`** parity for 2.0.

**Target release:** Savitar **2.1** (post–feature-matching beta). Not a 2.0 blocker.

**Context — what 2.0 ships today**

Story 2.3 wires the app-wide **Default word wrap for new sessions** checkbox to `Session.wordWrapEnabled` at connect time. That value is fixed for the life of the session; changing the pref or wanting different wrap per world means closing and reopening the window. Users notice both problems in practice.

**v1 behavior (reference)**

| Surface | v1 behavior |
|---------|-------------|
| App pref | “Automatically enable word wrapping for new **text windows**” — initial state only |
| Text document windows | Per-window toggle via bottom-right **blue arrow**; immediate; does not change the app pref |
| Session panes | `CTextPane::SetWordWrapping` / `WordWrap` flag (same text-pane class as text windows); runtime toggle existed in code |

Savitar 2.0 applied the app pref to **session** panes at open (reasonable v2 interpretation) but omitted the runtime toggle and per-world memory.

**Design (recommended)**

Three layers, outer → inner:

```
App Settings (default for new sessions)
        ↓ overridden by
World Settings → Output (optional per-world default)
        ↓ overridden by
Per-session toggle (live; input + output panes together)
```

| Layer | Behavior |
|-------|----------|
| **App pref** (`defaultWordWrap`) | Unchanged checkbox meaning: default for **new** sessions when the world has no override. Toggling it does **not** force-wrap open sessions (matches v1 text-window model). Optional stretch: brief note in Settings that open sessions are unaffected. |
| **Per-world default** | World Settings → **Output** tab: **Word wrap** control — `Use app default` / `On` / `Off`. Persisted in world XML. Used when the session connects (and on reconnect). |
| **Per-session toggle** | Immediate effect on **both** input (`NSTextView`) and output (`WKWebView` CSS via `WordWrapFormatting`). Does **not** write back to app pref or world file unless the user edits World Settings. Lost on reconnect unless world default covers it (acceptable). |

**UI (pick one primary + one secondary)**

| Control | Notes |
|---------|--------|
| **View → Word Wrap** (checkmark) | Standard macOS pattern; works when a world or text document window is key. |
| **Session title-bar control** | SF Symbol toggle (e.g. `text.append` wrapped vs `arrow.left.and.right`) or modernized v1 blue-arrow affordance in the input pane corner; tooltip “Word Wrap”. |
| **World Settings → Output** | Pop-up or segmented control for per-world default (see above). |

Input and output wrap stay **linked** in a session (one toggle) — v1 session UX and simpler mental model.

**Sketch (session window, wrap on)**

```
┌─ Alter Aeon ─────────────────────────────────── [?][🔒][⚡][⚙] ─┐
│  …output…                                                          │
├────────────────────────────────────────────────────────────────────┤
│  typed command wraps here                              [↩ wrap]   │
└────────────────────────────────────────────────────────────────────┘
  View → Word Wrap ✓
```

**Sketch (World Settings → Output tab)**

```
┌─ World Settings — Output ─────────────────────────────────────────┐
│  Word wrap:  (•) Use app default   ( ) On   ( ) Off               │
│  (logging, columns/rows — see Output tab)                         │
└───────────────────────────────────────────────────────────────────┘
```

### Tasks

- [ ] **20.1** **`Session.wordWrapEnabled` mutable** — replace `let` with `var`; add `setWordWrap(_:)` that updates input + output via `WindowController` / `WordWrapFormatting` without reconnect.
- [ ] **20.2** **Resolve initial wrap** — on session connect: `world.wordWrapDefault ?? app.defaultWordWrap` (exact API TBD in **20.4**).
- [ ] **20.3** **View menu** — **View → Word Wrap** checkmark bound to frontmost world session; enable only for world document windows. Optional shortcut (e.g. ⌃⌘W if unused).
- [ ] **20.4** **Per-world default** — new field on `World` / Output settings model; World Settings → Output UI; parse/serialize in `.world` XML; “Use app default” omits or sentinel value for v1 import compatibility.
- [ ] **20.5** **Session chrome toggle** — title-bar button or input-pane control; VoiceOver label; sync with View menu state.
- [ ] **20.6** **Output live update** — when toggling off→on or on→off, re-inject `WordWrapFormatting.outputPreCSS` (or equivalent) so existing buffer reflows without clearing.
- [ ] **20.7** **Text document parity (stretch)** — `PlainTextDocument` gets the same toggle + app-pref default as v1 text windows (blue-arrow behavior); can ship as **20.7** follow-up if session work lands first.
- [ ] **20.8** **Docs** — update `USER_GUIDE.md` (Input & Display + World Settings Output + session window); `HIG.md` session-window section; Story **9.3** output chapter.
- [ ] **20.9** **Tests** — toggle updates `Session` and both panes; world default overrides app pref at connect; app pref change does not alter open session.

### Touchpoints

- `client/Savitar2/src/worldDocument/Session.swift`
- `client/Savitar2/src/worldDocument/WindowController.swift`
- `client/Savitar2/src/worldDocument/InputViewController.swift`
- `client/Savitar2/src/worldDocument/OutputView.swift`, `OutputViewController.swift`
- `client/Savitar2/src/worldDocument/WordWrapFormatting.swift`
- `client/Savitar2/src/models/worlds/World.swift` (+ Output settings / XML)
- `client/Savitar2/Base.lproj/Main.storyboard` (View menu)
- World Settings storyboard (Output tab)
- `docs/USER_GUIDE.md`, `docs/HIG.md`

### Acceptance

- User toggles **View → Word Wrap** on an open session; long lines in input and output reflow (or un-wrap) **immediately** without closing the window.
- World A can stay wrap-off while World B is wrap-on across simultaneous sessions.
- World with **Word wrap: Off** opens wrapped-off even when app pref is on; **Use app default** follows app pref.
- Changing app **Default word wrap** does not change wrap on sessions already open.
- Behavior is documented; Story 2.3 remains the 2.0 v1-pref checkbox.

### Dependency

- **Story 2.3** ✅ (formatting helpers and app pref wiring).

### Non-goals (2.1)

- Separate wrap toggles for input vs output panes.
- Persisting per-session wrap across quit/relaunch (world default + app pref are enough).

---

## Story 21 — About box with scrolling credits ✅

**Goal:** Restore Savitar 1’s mirthful About experience — medallion artwork and scrolling “Special Heynows” credits — as a custom AppKit window instead of the system About panel.

**v1 reference:** `CTVAboutDialog` / PPob 1902, `LScrollingText` (TEXT/styl 1000), PICT 129 “Medallion”.

### Tasks

- [x] **21.1** **Menu** — **Savitar → About Savitar** → `showAboutAction:` (`AboutWindowController`)
- [x] **21.2** **Medallion** — ship classic art in `Assets.xcassets/AboutMedallion`
- [x] **21.3** **Credits roll** — “Special Heynows” names + Savitar 2 open-source acknowledgments; delay, fade-in, soft edge fade, loop
- [x] **21.4** **Chrome** — version/build, byline, copyright, heynow.com link; click or Escape dismisses
- [x] **21.5** **Docs** — USER_GUIDE, help book, HIG

### Acceptance

- About is modeless, close-only, shows marketing version + build.
- Credits scroll in a band below the medallion; content includes the classic Heynows and a short modern acknowledgments section.

---

## Story 22 — Alpha news banner on heynow.com/savitar (cross-repo) ✅

**Goal:** Add a visible **News** banner on the Savitar 2 landing page (`heynow.com/savitar/`) that tells visitors we are in **alpha testing** — matching the in-app welcome (Story 15) for people who discover Savitar on the web before they download.

**Context:** Story **15** introduces alpha testing and **Send Feedback…** inside the app. Many players will land on `/savitar/` first (search, bookmarks, v1 archive banners). A site banner closes the loop: same message, same era of the release, without requiring an install. **Implementation is in [heynow_websites](https://github.com/jkoutavas/heynow_websites)** — propose **Story W10**; this story tracks **content**, **coordination**, and **Savitar2 cross-links** if needed.

**Relationship to W1 / W2:** W1 is the Savitar 2 landing (`savitar-www/` Eleventy build). W2 adds a small v1 archive strip on legacy pages. This banner is **on the v2 landing only** — a forward-looking status line, not a migration nudge.

### Sketch (landing page)

```
┌─────────────────────────────────────────────────────────────┐
│ News · Savitar 2 is in alpha testing — we're close to       │
│ Savitar 1 feature complete. Try the build and send feedback │
│ (no GitHub account needed). [Download] [Community forum]    │
└─────────────────────────────────────────────────────────────┘
│ (existing W1 hero, features, migration, …)                  │
```

Copy should align with the in-app alpha announcement: define alpha briefly, mention aliases after 2.0 feature parity, point to download + feedback path (email via app; forum for discussion).

### Tasks

- [x] **22.1** **Content** — banner prose aligned with `SavitarFeedback` alpha announcement; defines alpha, feature-complete milestone, aliases after parity.
- [x] **22.2** **Coordinate W10** — above hero on W1 landing; always-on via `site.json` until beta (`newsBanner.enabled`).
- [x] **22.3** **heynow_websites build** — `savitar-www/src/_includes/news-banner.njk`, `site.json`, styles in `site.css`.
- [x] **22.4** **Links** — Download (GitHub Releases), Community forum, `mailto:` feedback; learn card updated from GitHub Issues.
- [ ] **22.5** **Deploy** — ship via `deploy-savitar.sh` / W5 when ready; local preview: `cd savitar-www && npm run dev`.
- [x] **22.6** **Savitar2 docs** — USER_GUIDE **Getting help** mentions site alpha news.

### Touchpoints

- [heynow_websites `savitar-www/`](https://github.com/jkoutavas/heynow_websites/tree/main/savitar-www) — Eleventy landing source
- [heynow_websites `docs/STORIES.md` — Story W10](https://github.com/jkoutavas/heynow_websites/blob/main/docs/STORIES.md)
- `client/Savitar2/src/SavitarFeedback.swift` — in-app announcement copy (reference)
- `docs/USER_GUIDE.md` — **Getting help** (optional web mention)

### Acceptance

- `heynow.com/savitar/` shows a clear **alpha testing** news banner without breaking W1 layout.
- Message is honest: pre–feature-complete software, feedback welcome, aliases called out as post-parity.
- Banner can be removed or swapped to “beta” copy without redeploying Savitar2 (site-only change).
- No contradiction with privacy page (W9) or v1 archive banners (W2).

### Dependency

- **Story 15** (in-app feedback + announcement shipped). **W1** landing (banner host). **W5** deploy path. **W8** forum link (optional CTA).

### Out of scope

- In-app “check website for news” polling or Sparkle release notes duplication.
- Per-visitor dismiss cookie (consider only if banner feels intrusive; default is always-on until beta).

---

## Story 27 — Output scrollback & performance

**Goal:** Keep session output smooth on long plays and combat spam **without** restoring v1 World Settings buffer/flush controls. Honor `OUTPUTMAX` / `OUTPUTMIN` internally; treat `FLUSHTICKS` as dead.

**Context:** Output renders in `WKWebView` (`OutputView`). Engineering watchpoints, phased plan, and diagnostics sketch: **[OutputPerformance.md](OutputPerformance.md)**.

**Schedule:** **Start of beta** — Savitar 2 is practically v1 feature-complete on the 2.0 track; this epic gates comfortable long-session dogfooding during beta (before wider release).

**Status:** Documented; implementation queued for beta kickoff.

### Policy

| Item | Status |
|------|--------|
| World Settings UI for buffer size / flush period | **Won't do** ([OutputPerformance.md](OutputPerformance.md#decision-v1-bufferflush-ui-wont-do)) |
| `FLUSHTICKS` at runtime | **Dead** — import-only; replaced by internal append coalescing |
| `OUTPUTMAX` / `OUTPUTMIN` at runtime | **Honor internally** — silent DOM trim using per-world XML values |

### Won't do

- [x] **27.0** **World Settings UI** for buffer size / flush period

### Phase 1 — Quick wins (beta, first)

- [ ] **27.1** **Scroll policy** — instant scroll-to-bottom during live output; throttle or disable smooth scroll on spam
- [ ] **27.2** **Coalesce appends** — batch telnet chunks to one JS commit per run-loop turn (replaces `FLUSHTICKS`)

### Phase 2 — Honor `OUTPUTMAX` / `OUTPUTMIN` (beta)

- [ ] **27.3** **Internal scrollback trim** — trim oldest DOM when over `world.outputMax`, toward `world.outputMin`; block-based trim + v1 defaults as fallback
- [ ] **27.4** **Cheaper DOM append** — avoid unbounded `innerHTML +=` on huge `<pre>` blocks (`insertAdjacentHTML`, split growing lines)

### Phase 3 — Diagnostics (beta, after 27.1–27.4)

- [ ] **27.5** **Output diagnostics overlay** — optional session status strip: updates/sec, scrollback blocks, est. HTML size, JS bridge latency, last trim; **Settings → Advanced** toggle; local only, no telemetry
- [ ] **27.6** **Profile checklist** — record baseline metrics in OutputPerformance.md after optimizations land

### Touchpoints

- [OutputPerformance.md](OutputPerformance.md)
- `client/Savitar2/src/worldDocument/OutputView.swift`
- `client/Savitar2/src/worldDocument/OutputViewController.swift`
- `client/Savitar2/src/worldDocument/Session.swift`
- `client/Savitar2/src/models/worlds/World.swift`
- `client/Savitar2/src/views/AppPreferences/AdvancedSettingsViewController.swift` (diagnostics toggle — TBD)

### Acceptance

- No World Settings fields for buffer/flush; USER_GUIDE and README reflect won't do ✅
- `FLUSHTICKS` never read at runtime; coalescing replaces flush semantics
- Long sessions trim silently using `OUTPUTMAX` / `OUTPUTMIN` (or defaults)
- Diagnostics overlay available for beta dogfooding when enabled
- Combat-spam / overnight scenarios measurably improved vs pre-beta builds

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
4. ~~Story 23 — App Settings HIG audit~~ ✅
5. ~~Story 7 — World Picker HIG~~ ✅
6. ~~Story 12 — Sparkle 2 auto-updates~~ ✅ (*12.7* E2E install test remains)
7. ~~Story 13 — Help → Release Notes~~ ✅
8. ~~Story 14 — TelemetryDeck analytics~~ ✅
9. ~~Story 16 — In-app user guide (Help menu)~~ ✅
10. ~~Story 17 — Contextual ? help buttons~~ ✅
11. ~~Story 18 — Help → About Privacy~~ ✅
12. ~~Story 15 — Send Feedback (email)~~ ✅
13. ~~**Story 21 — About box with scrolling credits**~~ ✅
14. **Story 2** — *in progress* (remaining: 2.5 clicker; 2.6 won't do)
15. **Story 9 — User guide** — *in progress* (aliases 9.2e, clicker 9.2f when Stories 10–11 land; drag-to-create triggers TBD)
16. ~~**Story 6 — Events Window HIG audit**~~ ✅ — close-only chrome, center on first open, shared `EventsWindowController`
17. **Story 24 — Settings → Advanced maintenance** — *in progress* (24.1 factory reset ✅; 24.6 won't do; import/export, v1 re-import, log editor deferred)
18. ~~**Story 25 — Window menu HIG audit**~~ ✅ — tab bar removal, **Show World Picker**, window list hygiene
19. ~~**Story 26 — App-wide appearance**~~ ✅ — System / Light / Dark on **Input & Display**; Savitar Help dark-mode CSS
20. Story 10 — Command aliases
21. Story 11 — Macro Clicker (README beta; unblocks Story 2.5)
22. **Story 20 — Session word wrap (v2.1)** — live per-session toggle, per-world default; after 2.0 ships
23. ~~Story 19 — Savitar privacy page on heynow.com (cross-repo **W9**)~~ ✅
24. ~~Story 22 — Alpha news banner on heynow.com/savitar (cross-repo **W10**)~~ ✅ (*deploy* via W5 when ready)
25. Story 8 — SwiftUI Settings spike (optional, post-beta)
26. **Story 27 — Output scrollback & performance** — **beta kickoff**; phases 1–3 in [OutputPerformance.md](OutputPerformance.md) (honor `OUTPUTMAX`/`OUTPUTMIN`; `FLUSHTICKS` dead; diagnostics overlay)

Stories 10 and 11 are independent tracks; either can ship first.
**Stories 15 + 16** satisfy README *Add bug reporting support* (both ✅).
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
| Capture file editor | `logEditorName` | Deferred — [Story 24.5](Stories.md#story-24--settings-advanced-maintenance) |
| Events outline disclosure (v1 only) | `trigsClosed`, `varsClosed` | Import-only — won't do ([Story 2.6](Stories.md#story-2--wire-preference-flags-to-behavior)) |
| Output buffer / flush (v1 only) | `outputMax`, `outputMin`, `flushTicks` | `flushTicks` import-only, dead at runtime; `outputMax`/`outputMin` honored internally at beta ([Story 27](Stories.md#story-27--output-scrollback--performance), [OutputPerformance.md](OutputPerformance.md)) |
