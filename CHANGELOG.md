# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Help → Savitar Help** (⌘?) opens the bundled user guide offline in a Savitar window
- **Help → Savitar Guide on the Web…** opens the latest guide draft on GitHub
- **Help → About Privacy…** opens the Privacy & usage statistics chapter in Savitar Help
- Contextual **?** help on major windows — World Picker, world session window, Events, Settings (per pane), and World Settings (per tab)
- User Guide chapters for ANSI colors, Input & Display, Audio, Updates, and World Settings (Starting and Appearance tabs)

### Changed

- User Guide expanded with contextual-help callout, Help menu reference, and Getting help section updates

### Fixed

- Pasting into the input pane no longer retains font or color styling from the clipboard source

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

[Unreleased]: https://github.com/jkoutavas/Savitar2/compare/v2.0.18...HEAD
[2.0.18]: https://github.com/jkoutavas/Savitar2/releases/tag/v2.0.18
[2.0.17]: https://github.com/jkoutavas/Savitar2/releases/tag/v2.0.17
[2.0.16]: https://github.com/jkoutavas/Savitar2/releases/tag/v2.0.16
[2.0.15]: https://github.com/jkoutavas/Savitar2/releases/tag/v2.0.15
[2.0.14]: https://github.com/jkoutavas/Savitar2/pull/30
[2.0.13]: https://github.com/jkoutavas/Savitar2/releases/tag/v2.0.13
[2.0.12]: https://github.com/jkoutavas/Savitar2/releases/tag/v2.0.12
