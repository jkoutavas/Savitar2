# Savitar 2 — macOS Human Interface Guidelines

Ongoing reference for building UI that feels native on macOS. Primary source: [Apple HIG — Settings](https://developer.apple.com/design/human-interface-guidelines/settings).

When adding or changing windows, menus, or controls, check this doc and `.cursor/rules/macos-hig.mdc`.

---

## Settings window

Savitar 2 uses one **modeless Settings window** (`AppSettingsWindowController`) with toolbar panes.

| Requirement | Implementation |
|-------------|----------------|
| App menu item **Settings…** with **⌘,** | `Main.storyboard` |
| Modeless; no Save/Cancel/Apply | Live bindings + immediate `save()` |
| Close-only traffic lights (no minimize/zoom) | `NSWindow.configureAsSettingsWindow()` |
| Non-resizable for compact panes | `fitContentSize(_:centerIfNeeded:)` |
| Toolbar tabs for multiple groups | `NSToolbar` + `.preference` style; **icon + label**, wide enough to avoid overflow |
| Window title = active pane name | e.g. "Startup", "Speech" |
| **Escape** and **⌘+.** close the window | `AppSettingsWindowController.cancelOperation` |
| Center on first open | `fitContentSize` + `center()` |
| All app settings in one window | Speech pane embedded; **Audio → Speech Settings…** opens Settings → Speech |

### Panes

| Pane | Toolbar symbol | Content |
|------|----------------|---------|
| Startup | `play.circle` | World Picker, Events, Macro Clicker (when shipped) |
| Input & Display | `keyboard` | Keypad, mono fonts, word wrap (when shipped) |
| Audio | `speaker.wave.2` | Mute cues / bell / clicker |
| Updates | `arrow.down.circle` | Sparkle 2 (Story 12) |
| Speech | `waveform` | Continuous speech controls |

### Code touchpoints

- `client/Savitar2/src/views/AppPreferences/AppSettingsWindowController.swift`
- `client/Savitar2/src/views/AppPreferences/AppPrefsViewController.swift`
- `client/Savitar2/src/extensions/NSWindow+Extensions.swift`

---

## General macOS UI principles

1. **Use system controls and terminology** — "Settings" not "Preferences" on macOS 13+.
2. **Modeless by default** — preferences, tool palettes, and inspectors should not block document interaction unless there is a strong reason.
3. **Immediate feedback** — toggles and fields apply at once; persist to prefs XML / `UserDefaults` as appropriate.
4. **Disable, don't hide** — unavailable features stay visible but grayed with a tooltip explaining why.
5. **Keyboard shortcuts** — respect standard shortcuts (⌘,, ⌘W, ⌘Q, arrow keys in text, etc.).
6. **Window chrome** — only add minimize/zoom when content needs it (e.g. scrollable lists); settings panes stay fixed-size.
7. **Menu bar accuracy** — menu labels should match what the user sees (window titles, action names).

---

## World / document windows

World document windows are separate from app Settings. World-specific options belong in **World Settings** (sheet), not the app Settings window.

## Edit → Speech menu

HIG places speak-selection commands under **Edit → Speech** for apps that display text. Savitar 1 used the macOS **Start Speaking** item there; Savitar 2 keeps the same location with a clearer label:

| Item | Purpose |
|------|---------|
| **Speak Selected Text** | Read the current selection in the **input** or **output** pane (Savitar voice engine; v1 parity) |

Use **Speak Selected Text** instead of **Start Speaking** because Savitar has no **Stop Speaking** pair — stopping queued Savitar speech is **Audio → Flush Speech Buffer** (⌘L).

## Audio menu

Savitar-specific audio commands (not standard Edit → Speech):

| Item | Purpose |
|------|---------|
| Mute Sound Cues / Mute Speaking Cues | Quick toggles (mirror Settings → Audio) |
| Flush Speech Buffer | Clear Savitar TTS queue (⌘L) |
| Speech Settings… | Opens Settings → Speech pane |

## Edit → Find

| Item | Shortcut | Behavior |
|------|----------|----------|
| **Find…** | ⌘F | Input pane: system find panel. Output pane: find bar above output |
| **Find Next** | ⌘G | Continue search in the focused pane |
| **Find Previous** | ⌘⇧G | Search backward |
| **Use Selection for Find** | ⌘E | Seed find string from selection |

When the **input** field is focused, find uses the standard `NSTextView` panel. Otherwise find operates on the **output** pane (WebKit `window.find`).

## File → Print

**Print…** (⌘P) uses the standard `printDocument:` responder chain. **World** documents override printing to send session **output as plain text** using the world's monospace font, without re-wrapping lines, so ASCII art keeps its on-screen shape. **Plain-text** documents use the system default (editor contents). ANSI colors are not included in world print/PDF. Save as PDF defaults to the world's name (e.g. `Alter Aeon.pdf`). The in-world `@printsource` command remains a separate debug/logging action.

**Save** on a world document defaults the filename to the world's name when the save sheet appears.

## File → text documents

Savitar 1 supported standalone text windows (`.txt`, `.text`, `.log`). Savitar 2 restores this via `PlainTextDocument` and **File → New Text Document** (⇧⌘T). **Open…** routes plain-text files to the text editor; `.world` files open as sessions.

---

## Future HIG work

Tracked as user stories — see [Stories.md](Stories.md):

| Backlog item | Story |
|--------------|-------|
| Speech pane Auto Layout | [Story 4](Stories.md#story-4--speech-pane-polish) |
| ANSI Colors as Settings pane | [Story 5](Stories.md#story-5--ansi-colors-settings-pane-hig) |
| Events Window HIG audit | [Story 6](Stories.md#story-6--events-window-hig-audit) |
| World Picker HIG audit | [Story 7](Stories.md#story-7--world-picker-hig-audit) |
| SwiftUI `Settings` scene evaluation | [Story 8](Stories.md#story-8--swiftui-settings-migration-exploratory) |

---

## References

- [Apple HIG — Settings](https://developer.apple.com/design/human-interface-guidelines/settings)
- [Apple — Adding a settings interface](https://developer.apple.com/documentation/foundation/adding-a-settings-interface-to-your-app)
- [docs/Stories.md](Stories.md) — settings feature tracker
