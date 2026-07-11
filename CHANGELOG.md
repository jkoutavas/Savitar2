# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Local commands (2.0 set)** — `##history`, `##recall` / `##!n`, `##clear screen`, status bars (`##set status`, `##close stats`, per-pane close), world flags and markers, scratch variables (`##set macro`), trigger enable/disable and XML add, `##dump` listings (pretty-printed, HTML-safe), `##regex`, `##wait`, `##broadcast`, window select/close; live Events store for world triggers/macros
- **`##help`** — HTML local-command reference grouped by category; tap a command (`xch_cmd`) to drill into syntax and a short description; back link to the full list; works even when **Interpret HTML tags** is off
- **`##link`** — insert a colored hyperlink into the output pane: `##link <url> "<label>" #RRGGBB`
- **Pueblo `xch_cmd` links** — `<a xch_cmd="…">` in HTML output becomes a clickable link; clicks send the command to the session (local commands when prefixed with the world marker, otherwise to the server)
- **Session welcome banner** — Savitar 1–style opening block at connect: bold **Welcome to Savitar**, version/copyright, website link, and a hint to type `##help`; single tight HTML block with one blank line before server output
- **Session status bars** — Savitar 1's per-pane status bars return: `##set status output|input <message>` shows a one-line strip at the top of the pane (variables expand in the message); `##close stats` hides both; strips render in **inverse** session colors for contrast — configurable styling is planned for 2.1
- **Macro Clicker** — floating button palette (Story 11): Savitar 1–style **Macro Clicker** window — periwinkle compass rose, green up/down arrows, whimsical green-outlined grid (1–9, a–f); all 15 grid cells are functional (`MACRO_A` … `MACRO_F` for a–f); direction + number buttons send bound macros to the frontmost session; **Window → Show Macro Clicker**; **⌘-click** to bind; hover caption; startup + mute prefs; v1 `ALIAS` XML import/export (18-entry imports preserve `MACRO_10` on **a** when saved)

### Changed

- **Macro Clicker** — default letter-slot bindings use underscores (`MACRO_A` … `MACRO_F`) to match `MACRO_1` … `MACRO_9`; early hyphenated factory prefs upgrade on load
- **User guide** — documents `##link` and `##help`

### Fixed

- **Session welcome** — banner was emitted before the output pane existed and never appeared; now outputs after the session view is wired up
- **Session output HTML** — multiline HTML embedded in JavaScript no longer breaks WebKit (`SyntaxError: Unexpected token '<'`); `##help` and other HTML fragments render reliably
- **Output link clicks** — `http`/`https` links in HTML output activate correctly (`.linkActivated` navigation policy)
- **Resolution overlay** — yellow variable-resolution box no longer sticks when the app is backgrounded, the window loses key, split-pane resize ends (mouse-up), or window live resize ends
- **HTML bold/strong** — `<strong>` / `<b>` and welcome title render bold despite the global output stylesheet `font` shorthand
- **Session restoration** — closing a world document before quitting no longer causes it to reopen on relaunch; prefs now persist the live open-document list (#92)

## [2.0.22] - 2026-07-11

### Added

- **Events window HIG** — close-only utility chrome, center on first open, shared `EventsWindowController` for app-wide and per-world Events windows (Story 6)
- **App-wide appearance** — **Settings → Input & Display** popup: **System**, **Light**, or **Dark** for app chrome (Story 26; v2-only pref)
- **Savitar Help** — help book CSS supports light and dark appearance (`prefers-color-scheme`)
- **Window → Show World Picker** — reopen or bring forward the World Picker from the Window menu (Story 25)

### Changed

- **Events window** — list column (440pt, all columns visible) with detail editor filling the rest (~460pt); no split divider
- **Window menu** — no longer shows **Show/Hide Tab Bar** or **Merge All Windows** (Savitar does not use tabbed windows); **File → New World Document…** (⌘N) opens the World Picker (Story 25)

### Fixed

- **Events → Macros detail pane** — form built in code with standard bordered fields (Name, Hotkey, Value); hotkey displays assigned key and updates when selection changes
- **World session help** — contextual **?** opens the [Session window](docs/USER_GUIDE.md#session-window) chapter
- **World Picker** — layer-backed colors refresh when macOS Auto light/dark changes or appearance pref changes

## [2.0.21] - 2026-07-10

### Added

- **World Picker** — redesigned first-run layout: welcome header, two-line world rows (`host:port`), connection detail card, primary **Connect** button (Story 7)
- **Settings → Advanced** — **Restore Factory Defaults…** reloads bundled app settings, World Picker world list, universal triggers/macros, and ANSI colors; clears utility-window positions (Stories 23–24)
- **Mordor MUD** added to bundled default worlds (`mordormud.net:4000`)
- User guide **Advanced** chapter and contextual **?** anchor (`#settings-advanced`)

### Changed

- **Bundled world addresses** — FurToonia → `ft.furtoonia.net:9999`; The Builder's Academy → `tbamud.com:9091` (verified via MUD Connect)
- **World Picker** — position-only frame restore (`WorldPickerFrameOrigin`); **Escape** / **⌘W** dismiss; window sizes to world list
- **App Settings** — seventh toolbar pane **Advanced** (`gearshape.2`); **⌘.** dismisses Settings when key (Story 23)
- **World Settings** — tab picker appears in the sheet toolbar (Starting, Appearance, Input, Output, Closing)
- **World Settings dialog** — OK/Cancel (was Apply); Escape dismisses; modal child window with visible title (`Document — Tab`); resizes per tab; Appearance preview word-wraps; sample text copyright/URL updated
- **User guide** — World Picker, Advanced, and settings reference updated; help book rebuilt
- **Stories.md** / **HIG.md** — Story 7 (World Picker HIG) and Story 23 (App Settings HIG) marked complete; Story 24 tracks Advanced maintenance backlog

### Removed

- **Mediterranean Nights** removed from bundled default worlds (host offline)

### Fixed

- World Picker **?** opens the World Picker chapter (`#worlds-connection-world-picker`); WKWebView scrolls to the target section after load

## [2.0.20] - 2026-07-09

### Added

- **About Savitar** — custom About box with the classic medallion and scrolling “Special Heynows” credits (Savitar 1 parity)
- **Help → Send Feedback…** — pre-filled email to the Savitar team with version diagnostics; clipboard fallback when Mail is unavailable (Story 15)
- **Alpha welcome** — one-time announcement explaining the Savitar 2 alpha test and how to send feedback

### Changed

- **User guide** — Getting started, install, session depth, triggers, local commands, glossary, settings reference, Startup pane, tips (Story 9)
- **Privacy on the web** — user guide and in-app help link to [heynow.com/savitar/privacy](https://www.heynow.com/savitar/privacy.html) (Story 19 / heynow_websites W9)

### Fixed

- **Resolution overlay on launch** — yellow rows×columns box no longer appears (and sticks) when restored windows resize programmatically at startup

## [2.0.19] - 2026-07-08

### Added

- **Default word wrap for new sessions** — Settings → Input & Display applies word wrap to input and output panes when a world session opens (v1 `TVPrefFlag_t_DefaultWordWrap` parity)
- **Pane dimensions (rows/columns)** — World Settings → Output (columns, output rows) and Input (input rows); grow-box and split-divider resize with yellow size overlay; v1 `RESOLUTION` parity
- **Help → Savitar Help** (⌘?) opens the bundled user guide offline in a Savitar window
- **Help → Savitar Guide on the Web…** opens the latest guide draft on GitHub
- **Help → About Privacy…** opens the Privacy & usage statistics chapter in Savitar Help
- Contextual **?** help on major windows — World Picker, world session window, Events, Settings (per pane), and World Settings (per tab)
- User Guide chapters for ANSI colors, Input & Display, Audio, Updates, and World Settings (Starting and Appearance tabs)

### Changed

- User Guide expanded with contextual-help callout, Help menu reference, Getting help section updates, and Input & Display word-wrap documentation
- **Stories.md** and **HIG.md** refreshed to reflect shipped help, analytics, and settings work (July 2026 doc pass)

### Fixed

- **`RESOLUTION` XML attribute order** — parse and serialize as `columns×outputRows×inputRows` to match Savitar 1 (`CTVWorld.cp`)
- **Harper's Tale startup world** — connect to `moo.harpers-tale.com:7007` (was `harpers-tale.com`, which does not accept MOO connections)
- Pasting into the input pane no longer retains font or color styling from the clipboard source
- Unit tests no longer overwrite the live `Savitar2 Prefs` file when preference actions are exercised
- World Settings **Output** tab labels no longer truncate (“Logging Enabled”, logging mode radio buttons)

## [2.0.18] - 2026-07-07

### Added

- Anonymous install and usage analytics via [TelemetryDeck](https://telemetrydeck.com/) on official signed release builds — app version, build number, and macOS version only; no session text, world names, or account data
- User Guide section on privacy and usage statistics
- World Settings **Input** tab: configure variable (`%%`) and wildcard (`$$`) markers, and choose carriage-return-only vs CR/LF line endings when sending commands (v1 `CROnly` worlds import with the correct setting)
- User Guide chapter on **World Settings**, including the Input tab

## [2.0.17] - 2026-07-04

- Added Sparkle updater support

## [2.0.16] - 2026-07-04

### Added

- ANSI Colors settings pane for customizing the terminal color palette
- Find and Find Next in both the input and output panes
- Printing of session output
- Plain-text document support for opening and editing `.txt` and `.log` files
- Redesigned app Settings window with HIG toolbar panes: Startup, Input & Display, Audio, Updates, and Speech
- Text-to-speech: a Speech settings pane, Speak Selected Text, and Flush Speech Buffer
- "Starting" tab in World Settings for connection and startup options
- Input trigger variables
- Scroll lock for the output pane
- Sticky commands in the input pane
- `##history` local command for recalling previous commands
- Input line editing keys (left/right arrow, Control-A, Control-C) and terminal bell handling
- Window restoration on relaunch

### Changed

- Renamed the app from "Savitar2" to "Savitar"

## [2.0.15] - 2022-03-20

### Fixed

- Keypad macro detection
- Vertical layout constraints on the World Settings host/port field

## [2.0.14] - 2021-06-27

_Manual alpha build; never git-tagged (reconstructed from history)._

### Added

- Output tab in World Settings for configuring session logging

## [2.0.13] - 2021-02-11

### Changed

- Set the input pane's caret color to the world's foreground color
- The start of the Preferences window: Show World Picker at Startup

## [2.0.12] - 2021-01-17

- Initial first alpha test build

[Unreleased]: https://github.com/jkoutavas/Savitar2/compare/v2.0.22...HEAD
[2.0.22]: https://github.com/jkoutavas/Savitar2/releases/tag/v2.0.22
[2.0.21]: https://github.com/jkoutavas/Savitar2/releases/tag/v2.0.21
[2.0.20]: https://github.com/jkoutavas/Savitar2/releases/tag/v2.0.20
[2.0.19]: https://github.com/jkoutavas/Savitar2/releases/tag/v2.0.19
[2.0.18]: https://github.com/jkoutavas/Savitar2/releases/tag/v2.0.18
[2.0.17]: https://github.com/jkoutavas/Savitar2/releases/tag/v2.0.17
[2.0.16]: https://github.com/jkoutavas/Savitar2/releases/tag/v2.0.16
[2.0.15]: https://github.com/jkoutavas/Savitar2/releases/tag/v2.0.15
[2.0.14]: https://github.com/jkoutavas/Savitar2/pull/30
[2.0.13]: https://github.com/jkoutavas/Savitar2/releases/tag/v2.0.13
[2.0.12]: https://github.com/jkoutavas/Savitar2/releases/tag/v2.0.12
