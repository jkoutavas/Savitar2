# Savitar 2 — macOS Human Interface Guidelines

**Scope:** UI requirements and native-macOS patterns for Savitar 2 — windows, menus, controls, and chrome. Use this when adding or changing anything the user sees or clicks.

**Not in scope here:**

| Topic | Where |
|-------|--------|
| Implementation tasks, acceptance criteria, shipping status | [Stories.md](Stories.md) |
| End-user how-to prose | [USER_GUIDE.md](USER_GUIDE.md) |
| v1 feature parity checklist | [README.md](../README.md) |

When changing UI, check this doc, [.cursor/rules/macos-hig.mdc](../.cursor/rules/macos-hig.mdc), and [Apple HIG — Settings](https://developer.apple.com/design/human-interface-guidelines/settings).

---

## General principles

1. **System controls and terminology** — "Settings" not "Preferences" on macOS 13+.
2. **Modeless by default** — app Settings, Events, World Picker, and Macro Clicker (when shipped) must not block document interaction.
3. **Immediate feedback** — app Settings toggles apply at once and persist to prefs XML; World Settings use **OK** / **Cancel** on the sheet.
4. **Disable, don't hide** — unavailable features stay visible, grayed, with a tooltip.
5. **Keyboard shortcuts** — respect standard shortcuts (⌘,, ⌘W, ⌘Q, arrow keys in text, etc.).
6. **Window chrome** — only add minimize/zoom when content needs it; fixed-size utility windows and Settings panes stay close-only and non-resizable unless a pane scrolls.
7. **Menu bar accuracy** — menu labels match window titles and action names.

---

## App Settings window

One **modeless Settings window** (`AppSettingsWindowController`) with toolbar panes. v1 scattered prefs dialogs (`DoPreferences`, `DoSpeechPreferences`, `EditColors`) are consolidated here.

| Requirement | Implementation |
|-------------|----------------|
| App menu **Settings…** with **⌘,** | `Main.storyboard` |
| Modeless; no Save/Cancel/Apply | Live bindings + immediate `save()` |
| Close-only traffic lights | `NSWindow.configureAsSettingsWindow()` |
| Non-resizable per pane | `fitContentSize(_:centerIfNeeded:)` |
| Toolbar tabs for groups | `NSToolbar` + `.preference` style; **icon + label** |
| Window title = active pane name | e.g. "Colors", "Speech" |
| **Escape** and **⌘+.** dismiss | `AppSettingsWindowController.cancelOperation` + local key monitor |
| Center on first open | `fitContentSize` + `center()` |
| Deep links from menus | **Audio → Speech Settings…** → Speech pane; **Edit → ANSI Colors…** → Colors pane |

### Panes

| Pane | Toolbar symbol | Content |
|------|----------------|---------|
| Startup | `play.circle` | World Picker, Events, Macro Clicker (when shipped) at launch |
| Input & Display | `keyboard` | Keypad, mono fonts, default word wrap for new sessions |
| Colors | `paintpalette` | 24 ANSI palette wells + Restore Defaults |
| Audio | `speaker.wave.2` | Mute sound / speaking / bell / clicker (clicker when shipped) |
| Updates | `arrow.down.circle` | Sparkle automatic update checking |
| Speech | `person.wave.2` | Continuous speech voice, rate, enable; macOS 10.15+ footnote when needed |

Panes with larger content (Colors, Speech) may grow the window; `resizeToFitCurrentPane` keeps chrome tight.

### Code touchpoints

- `client/Savitar2/src/views/AppPreferences/AppSettingsWindowController.swift`
- `client/Savitar2/src/views/AppPreferences/AppPrefsViewController.swift`
- `client/Savitar2/src/views/AppPreferences/ColorsSettingsViewController.swift`
- `client/Savitar2/src/extensions/NSWindow+Extensions.swift`

---

## World Settings sheet

Per-world options belong in **World Settings** (sheet on the world document window), **not** app Settings.

| Requirement | Implementation |
|-------------|----------------|
| **World → Show World Settings…** (⇧⌘J) or title-bar control | `WindowController` + `WorldSettings.storyboard` |
| Modal sheet; **OK** / **Cancel** | `beginSheet`; changes staged until OK |
| Tabs: Starting, Appearance, Input, Output | `NSTabView`; MCP / Closing deferred |
| Contextual **?** per tab | `SavitarHelpButton.installInTopTrailingCorner` |

---

## Utility windows

Modeless auxiliary windows for ongoing tasks. They should feel lighter than document windows but still Mac-native.

### Events window

Triggers, macros, and (when shipped) aliases. Universal (app-wide) and per-world instances share the same storyboard.

| Requirement | Current | Target |
|-------------|---------|--------|
| Modeless; does not block sessions | ✅ | — |
| **Window → Show App-wide Events Window** (⇧⌘E) | ✅ | — |
| Contextual **?** in title bar | ✅ | — |
| Frame autosave | `EventsWindowFrame` | Revisit center-on-first-open vs restore ([Story 6](Stories.md#story-6--events-window-hig-audit)) |
| Resize chrome | Minimize + resize with fixed min=max | Enable sensible resize **or** close-only — no fake resize ([Story 6](Stories.md#story-6--events-window-hig-audit)) |
| **Window** menu listing when open | TBD | [Story 6](Stories.md#story-6--events-window-hig-audit) |
| Section collapse ↔ prefs (`trigsClosed` / `varsClosed`) | TBD | [Story 2.6](Stories.md#story-2--wire-preference-flags-to-behavior) |

Touchpoints: `EventsWindow.storyboard`, `AppContext.showUniversalEventsWindow`, per-world `WindowController`.

### World Picker

Startup / **File → New World Document…** entry point for choosing a world.

| Requirement | Current | Target |
|-------------|---------|--------|
| Modeless; close-only chrome | ✅ | — |
| Contextual **?** in title bar | ✅ | — |
| Frame autosave | `WorldPickerFrame` | Revisit position-only vs fixed size ([Story 7](Stories.md#story-7--world-picker-hig-audit)) |
| Center on first open (no saved frame) | TBD | [Story 7](Stories.md#story-7--world-picker-hig-audit) |
| **Escape** / **⌘W** when key | TBD | [Story 7](Stories.md#story-7--world-picker-hig-audit) |
| **Window** menu listing when open | TBD | [Story 7](Stories.md#story-7--world-picker-hig-audit) |

Touchpoints: `WorldPicker.storyboard`, `AppContext.showWorldPicker`.

### Macro Clicker (when shipped)

Floating button palette — modeless utility window, frame autosave, optional startup. See [Story 11](Stories.md#story-11--macro-clicker).

---

## World / document windows

World sessions are **document windows** (one `.world` per window). Plain-text notes use separate text-document windows.

- World-specific appearance and connection options → **World Settings**, not app Settings.
- Session window exposes contextual **?** → world menu / session help anchor.
- **Scroll lock** (⌃S) and title-bar control; see [USER_GUIDE.md](USER_GUIDE.md) Menus chapter.

---

## Menu bar

### Edit → Speech

HIG places speak-selection under **Edit → Speech** for text-display apps:

| Item | Purpose |
|------|---------|
| **Speak Selected Text** | Read selection in input or output (Savitar TTS; v1 **Start Speaking** parity) |

No **Stop Speaking** pair — stop queued Savitar speech with **Audio → Flush Speech Buffer** (⌘L).

### Edit → ANSI Colors…

Opens app Settings → **Colors** pane (v1 `EditColors()` consolidated into Settings).

### Edit → Find

| Item | Shortcut | Behavior |
|------|----------|----------|
| **Find…** | ⌘F | Input: system find panel. Output: find bar above output |
| **Find Next** | ⌘G | Continue in focused pane |
| **Find Previous** | ⌘⇧G | Search backward |
| **Use Selection for Find** | ⌘E | Seed find string from selection |

### Audio menu

Savitar-specific audio (not standard Edit → Speech):

| Item | Purpose |
|------|---------|
| Mute Sound Cues / Mute Speaking Cues | Mirror Settings → Audio |
| Flush Speech Buffer | Clear TTS queue (⌘L) |
| Speech Settings… | Opens Settings → Speech |

### File → Print

**Print…** (⌘P) via `printDocument:`. World documents print session **output as plain text** (monospace, no ANSI). Plain-text documents print editor contents. ANSI colors are not included in world print/PDF.

**Save** on a world document defaults the filename to the world's name.

### File → text documents

**New Text Document** (⇧⌘T) for `.txt` / `.text` / `.log`. **Open…** routes plain-text files to the text editor; `.world` files open as sessions.

### Help menu

| Item | Shortcut | Behavior |
|------|----------|----------|
| **Savitar Help** | ⌘? | Bundled guide in `HelpGuideWindowController` + `WKWebView` (offline) |
| **Savitar Guide on the Web…** | — | GitHub `USER_GUIDE.md` (interim) |
| **About Privacy…** | — | Savitar Help at `#privacy`; web copy at [heynow.com/savitar/privacy](https://www.heynow.com/savitar/privacy.html) |
| **Release Notes…** | — | GitHub Releases |

**Do not** route primary help through macOS Help Viewer (`NSHelpManager` / `helpd`) — unreliable for Xcode and non–`/Applications` builds. The `.help` bundle remains for indexing and possible future `registerBooks` integration.

**Send Feedback…** — planned ([Story 15](Stories.md#story-15--send-feedback-email)); place below Savitar Help when shipped.

### Savitar → About Savitar

Custom About box (`AboutWindowController`) — not the system About panel.

| Requirement | Implementation |
|-------------|----------------|
| **Savitar → About Savitar** | `AppDelegate.showAboutAction` / `Main.storyboard` |
| Medallion artwork | Asset catalog `AboutMedallion` (from Savitar 1 PICT) |
| Scrolling credits | “Special Heynows” roll in a band below the medallion (soft edge fade) |
| Version + copyright | `CFBundleShortVersionString` / `CFBundleVersion` / `NSHumanReadableCopyright` |
| Close-only chrome; click or Escape dismisses | titled/closable window; `cancelOperation` |

Touchpoint: `client/Savitar2/src/AboutWindowController.swift`.

---

## Contextual help (? buttons)

Major surfaces expose **?** → matching guide anchor via `SavitarHelp.show(anchor:)`:

| Surface | Placement |
|---------|-----------|
| World Picker, world session, Events, App Settings | Title bar trailing (`SavitarHelpButton.installInTitleBar`) |
| World Settings sheet | Top-trailing of sheet content |

App Settings updates the anchor when the toolbar pane changes; World Settings on tab change.

Anchor IDs: `SavitarHelp.Anchor` / `ContextualSurface`; HTML `id`s from `docs/USER_GUIDE.md` via `client/scripts/build_help_book.py`.

Touchpoints: `SavitarHelp.swift`, `SavitarHelpButton.swift`, `HelpGuideWindowController.swift`.

---

## Open HIG backlog

Remaining UI/HIG work is tracked as user stories — do not duplicate task lists here:

| Area | Story |
|------|-------|
| Events Window chrome, Window menu, section prefs | [Story 6](Stories.md#story-6--events-window-hig-audit) |
| World Picker centering, keyboard, Window menu | [Story 7](Stories.md#story-7--world-picker-hig-audit) |
| SwiftUI `Settings` scene evaluation (exploratory) | [Story 8](Stories.md#story-8--swiftui-settings-migration-exploratory) |

Stories 1, 4, and 5 (app Settings, Speech pane, ANSI Colors pane) are **shipped** — requirements live in the sections above.

---

## References

- [Apple HIG — Settings](https://developer.apple.com/design/human-interface-guidelines/settings)
- [Apple — Adding a settings interface](https://developer.apple.com/documentation/foundation/adding-a-settings-interface-to-your-app)
- [Stories.md](Stories.md) — implementation tracker
- [USER_GUIDE.md](USER_GUIDE.md) — player-facing documentation
