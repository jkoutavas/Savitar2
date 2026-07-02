# Savitar 2 — Settings & Preferences Stories

_User stories for bringing Savitar 1.x application settings into Savitar 2. See [Savitar2DevNotes](Savitar2DevNotes.md) for broader design history._

Savitar 1 spread settings across three surfaces:

| Surface | v1 location | v2 status |
|---------|-------------|-----------|
| **App Preferences** | `DoPreferences()` in `CViewAppMac.cp` | Done — grouped prefs window (`AppPrefsViewController`) |
| **Speech Preferences** | `DoSpeechPreferences()` | Mostly done (`SpeechPrefs.storyboard`) |
| **ANSI Color Settings** | `EditColors()` | Data layer only (`ColorMan` in prefs XML) |

The prefs **data model** already imports v1 flags and values. **Story 1** (App Preferences UI) is complete; **Story 2** is partially complete (see below).

---

## Story 1 — Expand App Preferences window ✅

**Goal:** Replace the single-checkbox Preferences window with v1-parity startup, input, audio, and update settings.

**Status:** Complete (July 2026).

**Sketch** (implemented in `AppPrefsViewController` — single column, no scrollbar):

```
┌─ Savitar Preferences ─────────────────────────────────────┐
│  Startup                                                  │
│  ☑ Show World Picker at startup                           │
│  ☐ Show Macro Clicker at startup         (grayed out)     │
│  ☐ Show Events Window at startup                          │
│                                                           │
│  Input & Display                                          │
│  ☐ Use keypad for macro entry                             │
│  ☐ Mono fonts only (in font menus)                        │
│  ☐ Default word wrap for new sessions    (grayed out)     │
│                                                           │
│  Audio (session cues)                                     │
│  ☐ Mute sound cues                                        │
│  ☐ Mute speaking cues                                     │
│  ☐ Mute clicker sounds                   (grayed out)     │
│  ☐ Mute terminal bell                                     │
│                                                           │
│  Updates                                                  │
│  ☐ Check for updates automatically       (grayed out)     │
└───────────────────────────────────────────────────────────┘
```

Unsupported rows are disabled, grayed, and show a tooltip on hover.

### Tasks

- [x] **1.1** Grow `AppPrefs.storyboard` with grouped sections (Startup, Input & Display, Audio, Updates)
- [x] **1.2** Expose `showStartupPicker` (done) and add bindings for remaining `PrefsFlags` in `AppPrefsPresenter`
- [x] **1.3** Add `SetShowEventsWindowAtStartupAction` wired to `startupEventsWindow` (fix misnamed `SetWorldPickerAtStartup` while here)
- [x] **1.4** Add ReSwift actions for `useKeypad`, `monoFontsOnly`, `defaultWordWrap`, `muteClicker`, `muteBell`; save prefs on change
- [x] **1.5** Mirror mute sound / mute speaking checkboxes with existing Audio menu bindings in `AppDelegate`
- [x] **1.6** Disable (gray out) unsupported rows until those features ship; show tooltips (Macro Clicker, word wrap, Mute clicker, Check for updates)
- [x] **1.7** Add `updatingEnabled` checkbox; keep disabled until Sparkle/updater exists

### Touchpoints

- `client/Savitar2/Base.lproj/AppPrefs.storyboard`
- `client/Savitar2/src/views/AppPreferences/AppPrefsViewController.swift`
- `client/Savitar2/src/state/App/AppPreferencesActions.swift`
- `client/Savitar2/src/AppPreferences.swift` (`PrefsFlags`)

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

## Story 4 — Speech Preferences polish (optional)

**Goal:** Minor cleanup; core speech prefs already work.

### Tasks

- [ ] **4.1** Confirm rate/voice/enabled persist and apply during continuous speech
- [ ] **4.2** Save speech prefs on change (match App Preferences live-save pattern)
- [ ] **4.3** Document macOS 10.15+ requirement in Help or prefs footnote (already in UI)

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

1. ~~Story 1 — App Preferences UI~~ ✅
2. ~~Story 2 — Wire flags~~ — *in progress* (remaining: word wrap, clicker, Events window sections)
3. Story 3 — ANSI Colors window (separate surface; README beta item)
4. Story 4 — Speech polish if needed

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
